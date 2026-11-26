//! port: tools/port/oracle/replay.lisp — the brainless replay of a trace, compared step by step.
use crate::trace::{self, Item, TLine};
use duel_sim::flow::{self, PilotInput};
use duel_sim::hashline::{bits_line, state_hash_line};
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
        // (a CPU seat's vpad has no reader: the brain writes it; the replay reads only detached seats)
        if m.fighter.get(e).is_none_or(|f| f.has_brain) {
            return;
        }
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

/// port: replay.lisp's state: the step due now, the counts, the outcome once there is one (then reads and step ends are no-ops).
struct Replayer<I: Iterator<Item = Result<Item, String>>> {
    it: I,
    inj: Injector,
    fields: Vec<String>,
    mask: Vec<String>,
    cur: Option<Item>,
    steps: u64,
    items: u64,
    max: Option<u64>,
    trials: bool,
    out: Option<Outcome>,
}

impl<I: Iterator<Item = Result<Item, String>>> Replayer<I> {
    /// The next item becomes the one due (a step's T goes to the injector).
    fn advance(&mut self) {
        self.cur = match self.it.next() {
            None => None,
            Some(Err(e)) => {
                self.out = Some(Outcome::Error(e));
                None
            }
            Some(Ok(item)) => {
                if let Item::Step { t, .. } = &item {
                    self.inj.t = Some(t.clone());
                }
                Some(item)
            }
        };
    }

    /// An `unported!` hit outside a step (a debug command, a gate between matches): UNPORTED at the step due.
    fn check_unported(&mut self, m: &Match) {
        if let (None, Some(n)) = (&self.out, m.unported) {
            self.out = Some(Outcome::Unported(format!("{n} at tick {} (step {})", m.match_tick, self.steps + 1)));
        }
    }

    fn fail(&mut self, m: &Match, what: String) {
        let s = format!("tick {} (step {}, item {}): {what}", m.match_tick, self.steps, self.items);
        self.out.get_or_insert(Outcome::Diverged(s));
    }

    /// port: RP-DETACH: both brains off once a match has spawned them; their vpads read the trace from their current tick.
    fn detach(&mut self, m: &mut Match) {
        for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
            let Some(f) = m.fighter.get_mut(e) else { continue };
            if !f.has_brain {
                continue;
            }
            f.has_brain = false;
            let vt = m.pilot.get(e).map_or(0, |p| p.vpad.tick);
            if !self.trials && vt > 0 {
                self.fail(m, format!("P{}'s brain ran {vt} sim frames before it could be detached", k + 1));
            }
            self.inj.last[k] = vt;
        }
    }
}

impl<I: Iterator<Item = Result<Item, String>>> PilotInput for Replayer<I> {
    fn read(&mut self, m: &mut Match, side: usize) {
        if self.out.is_none() {
            self.inj.read(m, side);
        }
    }

    /// port: RP-STEP.
    fn step_end(&mut self, m: &mut Match) {
        if self.out.is_some() {
            return;
        }
        if let Some(name) = m.unported {
            self.out = Some(Outcome::Unported(format!("{name} at tick {} (step {})", m.match_tick, self.steps + 1)));
            return;
        }
        m.log_on = true;
        let log = std::mem::take(&mut m.log);
        if let Some(f) = self.inj.fail.take() {
            return self.fail(m, f);
        }
        let want = match self.cur.take() {
            Some(it @ Item::Step { .. }) => it,
            Some(other) => return self.fail(m, format!("a step ran where the trace has {other:?}")),
            None => return self.fail(m, "the replay runs past the trace's end".into()),
        };
        let side = |e| {
            m.pilot.get(e).map_or((0, 0, (0.0, 0.0)), |p| {
                let downs = p.vpad.downs.iter().enumerate().fold(0u16, |a, (i, &d)| a | ((d as u16 & 1) << i));
                (p.vpad.tick, downs, (p.vpad.sx, p.vpad.sy))
            })
        };
        let (s1, s2) = (side(m.p1), side(m.p2));
        let t = TLine { tick: m.match_tick, vt: [s1.0, s2.0], downs: [s1.1, s2.1], stick: [s1.2, s2.2], rnd: m.rng.state() };
        let (h, b) = (state_hash_line(m), bits_line(m));
        if let Some(what) = compare(&self.fields, &self.mask, &want, &log, &t, &h, b.strip_prefix("B ").unwrap_or(&b)) {
            return self.fail(m, what);
        }
        self.steps += 1;
        self.items += 1;
        if !self.trials {
            self.detach(m);
        }
        if self.max.is_some_and(|n| self.steps >= n) {
            self.out.get_or_insert(Outcome::Ok(self.steps));
            return;
        }
        self.advance();
    }
}

/// Replays PATH (at most MAX steps): replay.lisp's cmds start (SG-INIT, the S line's commands queued, TR-RUN-FRAMES' loop
/// until the gate and the match are over). A trials trace is driven by its F lines; its E lines are Task 13 (UNPORTED).
/// STUBS / MASK: the stubbed mode (docs/bevy/M1_NOTES.md §3; both empty = the gate's full comparison).
pub fn run(path: &str, max: Option<u64>, data: &'static duel_data::Data, stubs: &[String], mask: &[String]) -> Outcome {
    let mut r = match trace::open(path) {
        Ok(r) => r,
        Err(e) => return Outcome::Error(e),
    };
    let (start, fields) = match r.start() {
        Ok(x) => x,
        Err(e) => return Outcome::Error(e),
    };
    let trials = start.first().is_some_and(|w| w == "trials");
    let mut m = Match::new(data);
    m.stubs = stubs.to_vec();
    flow::go_title(&mut m); // (SG-INIT: START-GAME)
    let mut rp = Replayer { it: r, inj: Injector::new(), fields, mask: mask.to_vec(), cur: None, steps: 0, items: 0, max, trials, out: None };
    rp.advance();
    if trials {
        flow::frame(&mut m, &mut rp); // (trial.lisp's start: one frame, no step)
        rp.check_unported(&m);
        while rp.out.is_none() {
            match rp.cur.take() {
                None => return Outcome::Ok(rp.steps),
                Some(Item::Event { words, .. }) => {
                    let w = words.first().map_or("?", String::as_str);
                    return Outcome::Unported(format!("E {w} at tick {} (step {})", m.match_tick, rp.steps + 1));
                }
                Some(Item::Frame) => {
                    rp.items += 1;
                    rp.detach(&mut m);
                    rp.advance();
                    flow::frame(&mut m, &mut rp);
                    rp.check_unported(&m);
                }
                Some(step) => {
                    rp.cur = Some(step);
                    rp.fail(&m, "a step outside a frame".into());
                }
            }
        }
        return rp.out.unwrap();
    }
    for c in &start[1..] {
        match c.parse() {
            Ok(n) => m.cmds.push_back(n),
            Err(_) => return Outcome::Error(format!("trace: bad command {c} on the S line")),
        }
    }
    flow::frame(&mut m, &mut rp);
    rp.check_unported(&m);
    for _ in 0..2_000_000 {
        if let Some(out) = rp.out.take() {
            return out;
        }
        if !flow::frame(&mut m, &mut rp) {
            return Outcome::Error("the frame stopped".into());
        }
        rp.check_unported(&m);
        if let Some(out) = rp.out.take() {
            return out;
        }
        if m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
            return match rp.cur {
                None => Outcome::Ok(rp.steps),
                Some(_) => {
                    rp.fail(&m, "the run ended before the trace's end".into());
                    rp.out.unwrap()
                }
            };
        }
    }
    Outcome::Error("no end after 2000000 frames".into())
}

/// The stubbed mode's mask (docs/bevy/M1_NOTES.md §3): field-name prefixes after `pN.`; an entry `!prefix` keeps a field a plain
/// entry would mask. Non-empty: H is not compared either (it hashes masked fields).
pub fn masked(mask: &[String], field: &str) -> bool {
    let f = field.split_once('.').map_or(field, |(_, f)| f);
    let hit = |p: &str| f.starts_with(p);
    mask.iter().any(|p| !p.starts_with('!') && hit(p)) && !mask.iter().any(|p| p.strip_prefix('!').is_some_and(hit))
}

/// One step's comparison: the log, T's tick / vpad ticks / rnd, H, B (the first differing B field named). MASK: the stubbed mode's
/// (`masked`), empty = everything compared.
pub fn compare(fields: &[String], mask: &[String], want: &Item, log: &[String], t: &TLine, h: &str, b: &str) -> Option<String> {
    let Item::Step { log: wl, t: wt, h: wh, b: wb } = want else { return Some("not a step".into()) };
    if !trace::log_equal(wl, log) {
        return Some(format!("log: want {wl:?} got {log:?}"));
    }
    if (wt.tick, wt.vt, wt.rnd) != (t.tick, t.vt, t.rnd) {
        return Some(format!("T: want {} {:?} {:08X} got {} {:?} {:08X}", wt.tick, wt.vt, wt.rnd, t.tick, t.vt, t.rnd));
    }
    if mask.is_empty() && wh != h {
        return Some(format!("H: want {wh} got {h}"));
    }
    if wb != b {
        let (wv, gv): (Vec<&str>, Vec<&str>) = (wb.split(' ').collect(), b.split(' ').collect());
        let skip = |i: usize| fields.get(i).is_some_and(|n| masked(mask, n));
        if let Some(i) = (0..wv.len().max(gv.len())).find(|&i| wv.get(i) != gv.get(i) && !skip(i)) {
            let name = match fields.iter().position(|f| f == "|") {
                // a hazard's field: hz<n>.<slot> (the header names one hazard's slots after the bar)
                Some(bar) if i > bar && fields.len() > bar + 1 => {
                    let (k, n) = (i - bar - 1, fields.len() - bar - 1);
                    format!("hz{}.{}", k / n, fields[bar + 1 + k % n])
                }
                _ => fields.get(i).map_or("?", String::as_str).to_string(),
            };
            return Some(format!("B field {name}: want {} got {}", wv.get(i).unwrap_or(&"-"), gv.get(i).unwrap_or(&"-")));
        }
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

    /// The intro of cvc-ki-s1 (its first 14 steps): equal as recorded; a changed B field is named at its step; a run past
    /// the trace's end is a divergence.
    #[test]
    fn replay_intro_head_and_its_divergences() {
        let dir = std::env::var("ORACLE").unwrap_or_else(|_| "/media/8tsp/projects/ai-cl-game-next-bevy/build/oracle".into());
        let head: Vec<String> = {
            use std::io::BufRead;
            let f = std::fs::File::open(format!("{dir}/traces/cvc-ki-s1.trace")).expect("ORACLE trace");
            std::io::BufReader::new(f).lines().take(42).map(Result::unwrap).collect()
        };
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let run_with = |lines: &[String], max: Option<u64>| {
            let p = std::env::temp_dir().join(format!("replay-test-{}-{}.trace", std::process::id(), lines.len() + max.unwrap_or(0) as usize));
            std::fs::write(&p, lines.join("\n") + "\n").unwrap();
            let out = run(p.to_str().unwrap(), max, data, &[], &[]);
            let _ = std::fs::remove_file(&p);
            match out {
                Outcome::Ok(n) => format!("OK {n}"),
                Outcome::Diverged(s) => format!("DIVERGED {s}"),
                Outcome::Unported(s) => format!("UNPORTED {s}"),
                Outcome::Error(s) => format!("ERROR {s}"),
            }
        };
        assert_eq!(run_with(&head, Some(13)), "OK 13");
        assert_eq!(run_with(&head, None), "DIVERGED tick 14 (step 13, item 13): the replay runs past the trace's end");
        let mut bad = head.clone();
        let full_b = bad.iter().rev().find(|l| l.starts_with("B 18000")).unwrap().clone();
        bad[20] = full_b.replacen("B 18000", "B 17999", 1); // step 6's B line
        assert_eq!(run_with(&bad, Some(13)), "DIVERGED tick 6 (step 5, item 5): B field *timer*: want 17999 got 18000");
    }

    #[test]
    fn mask_prefixes_and_keeps() {
        let mask: Vec<String> = ["gauges-", "!gauges-fs", "ics-"].iter().map(|s| s.to_string()).collect();
        assert!(masked(&mask, "p1.gauges-gg") && masked(&mask, "p2.ics-hist"));
        assert!(!masked(&mask, "p1.gauges-fs") && !masked(&mask, "p1.gauges-fs-idle") && !masked(&mask, "p1.fighter-sf"));
        assert!(!masked(&[], "p1.gauges-gg"));
    }
}
