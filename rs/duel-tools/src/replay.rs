//! port: tools/port/oracle/replay.lisp — the brainless replay of a trace, compared step by step.
use crate::trace::{self, Item, TLine};
use duel_sim::flow::{self, PilotInput};
use duel_sim::state::Match;
use duel_sim::vpad::Vpad;

/// port: RP-INJECT / RP-READER. Injects side K's recorded buttons (VPAD-SET! in bit order), stick and the sim stream, only
/// when the vpad tick moved since the last injection for that side (VPAD-CLEAR! keeps the tick; PILOT-READ leaves it).
pub struct Injector {
    pub last: [i64; 2],
    pub t: Option<TLine>,
    pub fail: Option<String>,
}

impl Injector {
    pub fn new() -> Self {
        Injector { last: [-1, -1], t: None, fail: None }
    }

    /// Returns the new sim stream state when it injected.
    pub fn inject(&mut self, vp: &mut Vpad, k: usize) -> Option<u32> {
        if vp.tick == self.last[k] {
            return None;
        }
        self.last[k] = vp.tick;
        let t = self.t.as_ref()?;
        if t.vt[k] != vp.tick && self.fail.is_none() {
            self.fail = Some(format!("P{} vpad tick {}, the trace's {}", k + 1, vp.tick, t.vt[k]));
        }
        for bit in 0..vp.actions.len() {
            vp.set(bit, t.downs[k] >> bit & 1 == 1);
        }
        // port: (setf (vpad-sx vp) sx (vpad-sy vp) sy) — no clamp (not VPAD-STICK!)
        (vp.sx, vp.sy) = t.stick[k];
        Some(t.rnd)
    }
}

impl PilotInput for Injector {
    fn read(&mut self, m: &mut Match, side: usize) {
        let e = if side == 0 { m.p1 } else { m.p2 };
        let Some(p) = m.pilot.get_mut(e) else { return };
        if let Some(r) = self.inject(&mut p.vpad, side) {
            m.rng.set_state(r);
        }
    }
    fn step_end(&mut self, _m: &mut Match) {}
}

pub enum Outcome {
    Ok(u64),
    Diverged(String),
    Unported(String),
    Error(String),
}

/// Replays PATH (at most MAX steps). ponytail: `frame` is unported until the rest of Task 6 lands, so a trace stops at its
/// first frame with UNPORTED; the step comparison below is what the frame loop will call.
pub fn run(path: &str, max: Option<u64>, data: &'static duel_data::Data) -> Outcome {
    let mut r = match trace::open(path) {
        Ok(r) => r,
        Err(e) => return Outcome::Error(e),
    };
    let (start, fields) = match r.start() {
        Ok(x) => x,
        Err(e) => return Outcome::Error(e),
    };
    let _ = (start, fields);
    let mut m = Match::new(data);
    let mut inj = Injector::new();
    let mut steps = 0u64;
    let mut it = r.peekable();
    while let Some(item) = it.peek() {
        if max.is_some_and(|n| steps >= n) {
            break;
        }
        match item {
            Err(e) => return Outcome::Error(e.clone()),
            Ok(Item::Event { words, .. }) => {
                let w = format!("E {}", words[0]);
                return Outcome::Unported(format!("{w} at tick {} (step {})", m.match_tick, steps + 1));
            }
            Ok(Item::Frame) | Ok(Item::Step { .. }) => {
                if matches!(item, Ok(Item::Frame)) {
                    it.next();
                }
                let tick = m.match_tick;
                if !flow::frame(&mut m, &mut inj) || m.unported.is_some() {
                    let name = m.unported.unwrap_or("frame stopped");
                    return Outcome::Unported(format!("{name} at tick {tick} (step {})", steps + 1));
                }
                steps += 1; // the frame loop will compare each step's record via `compare`
            }
        }
    }
    Outcome::Ok(steps)
}

/// One step's comparison: the log, T's tick / vpad ticks / rnd, H, B (the first differing B field named).
pub fn compare(fields: &[String], want: &Item, log: &[String], t: &TLine, h: &str, b: &str) -> Option<String> {
    let Item::Step { log: wl, t: wt, h: wh, b: wb } = want else { return Some("not a step".into()) };
    if !trace::log_equal(wl, log) {
        return Some(format!("log: want {wl:?} got {log:?}"));
    }
    if (wt.tick, wt.vt, wt.rnd) != (t.tick, t.vt, t.rnd) {
        return Some(format!("T: want {} {:?} {:08X} got {} {:?} {:08X}", wt.tick, wt.vt, wt.rnd, t.tick, t.vt, t.rnd));
    }
    if wh != h {
        return Some(format!("H: want {wh} got {h}"));
    }
    if wb != b {
        let (wv, gv): (Vec<&str>, Vec<&str>) = (wb.split(' ').collect(), b.split(' ').collect());
        let i = (0..wv.len().max(gv.len())).find(|&i| wv.get(i) != gv.get(i)).unwrap_or(0);
        let name = fields.get(i).map_or("?", String::as_str);
        return Some(format!("B field {name}: want {} got {}", wv.get(i).unwrap_or(&"-"), gv.get(i).unwrap_or(&"-")));
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn replay_skips_injection_without_sim_frame() {
        let t = trace::parse_str(
            "S cmds 1\nT 1 1 003 0.5 0.0 1 000 0.0 0.0 0000ABCD\nH h\nB 1\nT 2 1 000 0.0 0.0 1 000 0.0 0.0 00001234\nH h\nB 1\n",
        )
        .unwrap();
        let mut vp = Vpad::new(&["mod", "quick", "flash"], Some("mod"), 4).unwrap();
        let mut inj = Injector::new();
        let mut injected = Vec::new();
        for (i, item) in t.items.iter().enumerate() {
            let Item::Step { t, .. } = item else { panic!() };
            inj.t = Some(t.clone());
            if i == 0 {
                vp.begin_step(); // a sim frame: the clock moves to 1; the second step has none
            }
            injected.push(inj.inject(&mut vp, 0));
        }
        assert_eq!(injected, [Some(0xABCD), None]);
        assert!(vp.down(0) && vp.down(1) && !vp.down(2));
        assert_eq!((vp.sx, inj.fail), (0.5, None));
    }
}
