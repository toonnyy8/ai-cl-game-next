//! port: tools/port/oracle/replay.lisp — the brainless replay of a trace, compared step by step.
use crate::trace::{self, Item, TLine};
use duel_sim::flow::{self, PilotInput};
use duel_sim::hashline::{bits_line, state_hash_line};
use duel_sim::components::{Button, Character, Form};
use duel_sim::debug::{self, LispValue};
use duel_sim::state::Match;
use duel_sim::vpad::Vpad;

/// port: trace.lisp TR-APPLY-EVENT: one E line's WORDS (after `E`), applied now (the grammar: trace.lisp's header).
pub fn apply_event(m: &mut Match, words: &[String]) -> Result<(), String> {
    let w = |i: usize| words.get(i).map(String::as_str).ok_or(format!("E {}: too few words", words.join(" ")));
    let val = |i: usize| LispValue::parse(w(i)?);
    // port: TR-ENTITY: 0 is P1, any other integer P2
    let side = |m: &Match, i: usize| Ok::<_, String>(if val(i)?.int()? == 0 { m.p1 } else { m.p2 });
    let kw = |i: usize| -> Result<String, String> { Ok(val(i)?.kw()?.to_string()) };
    let ch = |i: usize| Character::from_name(&kw(i)?).ok_or(format!("E {}: no character", words.join(" ")));
    match w(0)? {
        "set" => {
            let s = match w(1)? {
                "-" => None,
                k => Some((k.parse::<i64>().map_err(|_| format!("E set: side {k}"))? != 0) as usize), // (TR-ENTITY's rule)
            };
            debug::set_field(m, s, w(2)?, &val(3)?)?
        }
        "battle" => debug::ensure_battle(m, ch(1)?, ch(2)?),
        "form" => {
            let (e, f) = (side(m, 1)?, Form::from_name(&kw(2)?).ok_or(format!("E {}: no form", words.join(" ")))?);
            debug::force_form(m, e, f)
        }
        "hisagi-reset" => duel_sim::unported!(m, "hisagi-reset", Ok(())), // (Hisagi's: M4)
        "place" => debug::place(m, val(1)?.real()?),
        "vpad-clear" => {
            let e = side(m, 1)?;
            m.pilot.get_mut(e).ok_or("vpad-clear: no pilot")?.vpad.clear()
        }
        "clear-hazards" => duel_sim::hazards::clear_hazards(m),
        "skip-cine" => duel_sim::cine::skip_cine(m),
        "burst-end" => {
            let e = side(m, 1)?;
            duel_sim::gauges::burst_end(m, e)
        }
        "full-gauges" => {
            let e = side(m, 1)?;
            let meter = match val(2)? {
                LispValue::Nil => None,
                v => Some(v.float()?), // (the meter slot is a single-float: an integer is never recorded)
            };
            debug::full_gauges(m, e, meter)
        }
        // (between frames, as the trial ran it: not queued for the next frame's start)
        "cmd" => debug::debug_command(m, val(1)?.int()?),
        "core-start" => {
            let e = side(m, 1)?;
            let key = kw(2)?.to_lowercase();
            let kit = duel_sim::fighter::kit_of(m, e);
            let mv = duel_sim::kit::kit_move(m.data, kit, &key).ok_or(format!("core-start: no move {key}"))?;
            let id = duel_sim::fighter::id_of(m, mv);
            duel_sim::core_sim::core_start(m, e, id, Some(Button::Quick));
        }
        a => return Err(format!("trace: unknown event {a}")),
    }
    Ok(())
}

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
    /// `--snap N`: every N battle ticks a rollout on the live match, then restored from its clone (`snap_rollout`).
    snap: Option<i64>,
    pub snaps: u64,
    pub snaps_unported: u64,
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
        if self.snap.is_some_and(|n| flow::battle_p(m) && m.match_tick % n == 0) {
            self.snaps += 1;
            if let Some(name) = snap_rollout(m) {
                // (kept on the restored match, so the sim stops too: a --snap run with a cut rollout is never OK)
                self.snaps_unported += 1;
                self.out = Some(Outcome::Unported(format!("{name} in a --snap rollout from tick {} (step {})", m.match_tick, self.steps)));
                return;
            }
        }
        if self.max.is_some_and(|n| self.steps >= n) {
            self.out.get_or_insert(Outcome::Ok(self.steps));
            return;
        }
        self.advance();
    }
}

/// Replays PATH (at most MAX steps): replay.lisp's cmds start (SG-INIT, the S line's commands queued, TR-RUN-FRAMES' loop
/// until the gate and the match are over), or a trials trace's RP-DRIVE (one frame, then its E lines applied and F lines run in order).
/// STUBS / MASK: the stubbed mode (docs/bevy/M1_NOTES.md §3; both empty = the gate's full comparison).
#[cfg(test)]
pub fn run(path: &str, max: Option<u64>, data: &'static duel_data::Data, stubs: &[String], mask: &[String]) -> Outcome {
    run_snap(path, max, data, stubs, mask, None).0
}

/// `run` with `--snap N` (SNAP); also returns how many rollouts ran and how many reached an `unported!` path.
pub fn run_snap(path: &str, max: Option<u64>, data: &'static duel_data::Data, stubs: &[String], mask: &[String], snap: Option<i64>) -> (Outcome, (u64, u64)) {
    let mut snaps = (0, 0);
    let out = run_with(path, max, data, stubs, mask, snap, &mut snaps);
    (out, snaps)
}

fn run_with(path: &str, max: Option<u64>, data: &'static duel_data::Data, stubs: &[String], mask: &[String], snap: Option<i64>, snaps: &mut (u64, u64)) -> Outcome {
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
    let mut rp = Replayer { it: r, inj: Injector::new(), fields, mask: mask.to_vec(), cur: None, steps: 0, items: 0, max, trials, out: None, snap, snaps: 0, snaps_unported: 0 };
    let out = drive(&mut m, &mut rp, &start, trials);
    *snaps = (rp.snaps, rp.snaps_unported);
    out
}

fn drive<I: Iterator<Item = Result<Item, String>>>(m: &mut Match, rp: &mut Replayer<I>, start: &[String], trials: bool) -> Outcome {
    rp.advance();
    if trials {
        flow::frame(m, rp); // (trial.lisp's start: one frame, no step)
        rp.check_unported(m);
        while rp.out.is_none() {
            match rp.cur.take() {
                None => return Outcome::Ok(rp.steps),
                Some(Item::Event { words, e_lines }) => {
                    // port: RP-DRIVE's :event: what the action prints must equal its e lines
                    rp.items += 1;
                    m.log.clear();
                    if let Err(e) = apply_event(m, &words) {
                        return Outcome::Error(e);
                    }
                    rp.check_unported(m);
                    let got = std::mem::take(&mut m.log);
                    if rp.out.is_none() && !trace::log_equal(&e_lines, &got) {
                        rp.fail(m, format!("event {} printed: want {e_lines:?} got {got:?}", words.join(" ")));
                    }
                    rp.advance();
                }
                Some(Item::Frame) => {
                    rp.items += 1;
                    rp.detach(m);
                    rp.advance();
                    flow::frame(m, rp);
                    rp.check_unported(m);
                }
                Some(step) => {
                    rp.cur = Some(step);
                    rp.fail(m, "a step outside a frame".into());
                }
            }
        }
        return rp.out.take().unwrap();
    }
    for c in &start[1..] {
        match c.parse() {
            Ok(n) => m.cmds.push_back(n),
            Err(_) => return Outcome::Error(format!("trace: bad command {c} on the S line")),
        }
    }
    flow::frame(m, rp);
    rp.check_unported(m);
    for _ in 0..2_000_000 {
        if let Some(out) = rp.out.take() {
            return out;
        }
        if !flow::frame(m, rp) {
            return Outcome::Error("the frame stopped".into());
        }
        rp.check_unported(m);
        if let Some(out) = rp.out.take() {
            return out;
        }
        if m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(m) {
            return match rp.cur {
                None => Outcome::Ok(rp.steps),
                Some(_) => {
                    rp.fail(m, "the run ended before the trace's end".into());
                    rp.out.take().unwrap()
                }
            };
        }
    }
    Outcome::Error("no end after 2000000 frames".into())
}

/// A pilot input that reads nothing (the vpads keep what they hold) and counts the steps.
struct Null(u32);
impl PilotInput for Null {
    fn read(&mut self, _m: &mut Match, _side: usize) {}
    fn step_end(&mut self, _m: &mut Match) {
        self.0 += 1;
    }
}

/// `--snap`'s rollout (tools/simgate/snaptest.lisp's idea): clone the match, reseed the sim stream as snaptest does, play 40 sim steps on
/// the live match with the vpads as they are, then restore the clone. The replay must stay OK: the clone holds the whole sim state.
/// Returns the `unported!` path the rollout reached, if any, and keeps it in the restored match's `unported` (the restore would
/// otherwise forget it). The restore is a full replacement and duel-sim holds no Rc / RefCell / Cell / Arc or statics, so it cannot
/// leak by construction: what a pass proves is that 40 reseeded steps from each snapshot reach no panic and no `unported!`.
fn snap_rollout(m: &mut Match) -> Option<&'static str> {
    let saved = m.clone();
    m.rng.set_state((m.rng.state() ^ 0x5BD1_E995) | 1);
    let mut n = Null(0);
    for _ in 0..40 {
        if !flow::sim_running_p(m) || m.unported.is_some() {
            break;
        }
        flow::sim_step(m, &mut n); // (steps, not frames: a turbo frame is 120 steps)
    }
    let cut = m.unported;
    *m = saved;
    m.unported = m.unported.or(cut);
    cut
}

/// `--bench`'s input: the trace's T lines, read before the clock starts, injected as the replay does (RP-INJECT, RP-DETACH); no
/// comparison, no log.
pub struct BenchInput {
    inj: Injector,
    ts: Vec<TLine>,
    pub steps: usize,
}

impl PilotInput for BenchInput {
    fn read(&mut self, m: &mut Match, side: usize) {
        self.inj.t = self.ts.get(self.steps).cloned();
        self.inj.read(m, side);
    }
    fn step_end(&mut self, m: &mut Match) {
        self.steps += 1;
        for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
            if let Some(f) = m.fighter.get_mut(e).filter(|f| f.has_brain) {
                f.has_brain = false;
                self.inj.last[k] = m.pilot.get(e).map_or(0, |p| p.vpad.tick);
            }
        }
    }
}

/// A cmds trace read for `--bench`: the match after its S line's commands and first frame (the combat log off), its input, the
/// trace's last H.
pub fn bench_setup(path: &str, data: &'static duel_data::Data) -> Result<(Match, BenchInput, String), String> {
    use std::io::BufRead;
    let f = std::fs::File::open(path).map_err(|e| format!("{path}: {e}"))?;
    let (mut start, mut ts, mut h) = (vec![], vec![], String::new());
    for l in std::io::BufReader::with_capacity(1 << 20, f).lines() {
        let l = l.map_err(|e| e.to_string())?;
        if let Some(r) = l.strip_prefix("T ") {
            ts.push(trace::parse_t(r)?);
        } else if let Some(r) = l.strip_prefix("H ") {
            h = r.to_string();
        } else if let Some(r) = l.strip_prefix("S ") {
            start = r.split(' ').map(String::from).collect();
        }
    }
    if start.first().is_none_or(|w| w != "cmds") {
        return Err("--bench: a cmds trace only".into());
    }
    let mut m = Match::new(data);
    flow::go_title(&mut m);
    for c in &start[1..] {
        m.cmds.push_back(c.parse().map_err(|_| format!("bad command {c}"))?);
    }
    let mut inp = BenchInput { inj: Injector::new(), ts, steps: 0 };
    flow::frame(&mut m, &mut inp);
    m.log_on = false; // (DEBUG-COMMAND turns it on; the gate's matches run with it off)
    Ok((m, inp, h))
}

/// One frame of the bench loop; false once the run is over (the replay's end test).
pub fn bench_frame(m: &mut Match, inp: &mut BenchInput) -> bool {
    flow::frame(m, inp);
    m.log.clear();
    !(m.unported.is_some() || m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(m))
}

/// `--bench`: the match run RUNS times in-process, each from a fresh setup (a clone would drop the stores' reserved capacity);
/// (steps, the runs' seconds sorted, whether every run reproduced the trace: its step count and final H equal). A run is 15-25 ms, so
/// the median of several is the figure.
pub fn bench(path: &str, data: &'static duel_data::Data, runs: usize) -> Result<(usize, Vec<f64>, bool), String> {
    let (mut secs, mut same, mut steps) = (vec![], true, 0);
    for _ in 0..runs {
        let (mut m, mut inp, h) = bench_setup(path, data)?;
        let t0 = std::time::Instant::now();
        while bench_frame(&mut m, &mut inp) {}
        secs.push(t0.elapsed().as_secs_f64());
        if let Some(n) = m.unported {
            return Err(format!("--bench: unported {n}"));
        }
        same &= inp.steps == inp.ts.len() && state_hash_line(&m) == h;
        steps = inp.steps;
    }
    secs.sort_by(f64::total_cmp);
    Ok((steps, secs, same))
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

    /// An answer-key trace's path: `ORACLE`, else this checkout's git-ignored build/oracle; None (the test skips, with a note) when
    /// it is absent.
    fn oracle_trace(name: &str) -> Option<String> {
        let dir = std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into());
        let p = format!("{dir}/traces/{name}.trace");
        if std::path::Path::new(&p).exists() {
            Some(p)
        } else {
            eprintln!("skipped: no answer key at {p} (set ORACLE)");
            None
        }
    }

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
        let Some(path) = oracle_trace("cvc-ki-s1") else { return };
        let head: Vec<String> = {
            use std::io::BufRead;
            let f = std::fs::File::open(path).expect("ORACLE trace");
            // (the M1 grammar's lines: the M2 `A` lines and their header are left out, as the reader skips them)
            std::io::BufReader::new(f).lines().map(Result::unwrap).filter(|l| !l.starts_with('A') && !l.starts_with("# A ")).take(42).collect()
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

    /// RP-DRIVE's events: what an E action prints is compared with its e lines (a trial file's start, as trial-sp-xch-r3's).
    #[test]
    fn event_log_compared() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let run_str = |name: &str, s: &str| {
            let p = std::env::temp_dir().join(format!("replay-event-{}-{name}.trace", std::process::id()));
            std::fs::write(&p, s).unwrap();
            let out = run(p.to_str().unwrap(), None, data, &[], &[]);
            let _ = std::fs::remove_file(&p);
            match out {
                Outcome::Ok(n) => format!("OK {n}"),
                Outcome::Diverged(s) => format!("DIVERGED {s}"),
                Outcome::Unported(s) => format!("UNPORTED {s}"),
                Outcome::Error(s) => format!("ERROR {s}"),
            }
        };
        let head = "S trials f.lisp\nE set - *COMBAT-LOG* NIL\nE battle :ICHIGO :KENPACHI\nE form 1 :NOZARASHI\nE place 1.6\nE set - *COMBAT-LOG* T\n";
        assert_eq!(run_str("ok", &format!("{head}E form 0 :BASE\ne [     0] P1 form BASE\n")), "OK 0");
        assert_eq!(
            run_str("bad", &format!("{head}E form 0 :BASE\ne [     0] P1 form KESSA\n")),
            "DIVERGED tick 0 (step 0, item 6): event form 0 :BASE printed: want [\"[     0] P1 form KESSA\"] got [\"[     0] P1 form BASE\"]"
        );
        assert_eq!(
            run_str("none", &format!("{head}E form 0 :BASE\n")),
            "DIVERGED tick 0 (step 0, item 6): event form 0 :BASE printed: want [] got [\"[     0] P1 form BASE\"]"
        );
        assert!(run_str("err", &format!("{head}E set 0 GAUGES-NOPE 1\n")).starts_with("ERROR set: no field GAUGES-NOPE"));
    }

    /// The 0 B / step rule: cvc-kk-s1 under `--bench`'s driver (the combat log off) allocates nothing in any frame that starts and
    /// ends in the battle (its ~17,800 battle steps; the brief's bar is 600). The final frame's gate result push is outside it.
    #[test]
    fn bench_allocs() {
        let Some(path) = oracle_trace("cvc-kk-s1") else { return };
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let (mut m, mut inp, _) = bench_setup(&path, data).unwrap();
        let (mut steps, mut allocs) = (0, 0);
        loop {
            let (s0, a0, before) = (inp.steps, crate::alloc_count::count(), flow::battle_p(&m));
            let go = bench_frame(&mut m, &mut inp);
            if before && flow::battle_p(&m) {
                (steps, allocs) = (steps + inp.steps - s0, allocs + crate::alloc_count::count() - a0);
            }
            if !go {
                break;
            }
        }
        assert!(!m.log_on && steps >= 600, "log {} steps {steps}", m.log_on);
        assert_eq!(allocs, 0, "allocations in {steps} battle steps");
    }

    /// `E core-start`, `E cmd`, `E skip-cine` (a recorded trial, rs/duel-tools/tests/fixtures/core-start-cmd.*): P2 starts KE-Z-AS1
    /// through CORE-START! (its move and SP log lines, then its hit, compared step by step), a debug command between frames; the
    /// skip-cine line was added by hand (no cinematic runs there: ECL's replay.lisp passes the same file). Without the core-start
    /// line (and its e lines, the fixture's only ones) the run diverges.
    #[test]
    fn core_start_cmd_fixture() {
        let path = concat!(env!("CARGO_MANIFEST_DIR"), "/tests/fixtures/core-start-cmd.trace");
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        assert!(matches!(run(path, None, data, &[], &[]), Outcome::Ok(29)));
        let cut: String = std::fs::read_to_string(path).unwrap().lines().filter(|l| !l.starts_with("E core-start") && !l.starts_with("e ")).map(|l| l.to_string() + "\n").collect();
        let p = std::env::temp_dir().join(format!("replay-fixture-{}.trace", std::process::id()));
        std::fs::write(&p, cut).unwrap();
        let out = run(p.to_str().unwrap(), None, data, &[], &[]);
        let _ = std::fs::remove_file(&p);
        assert!(matches!(out, Outcome::Diverged(_)), "a run without the core-start line still passed");
    }

    /// A `--snap` rollout that reaches an `unported!` path reports it and the restored match keeps it (Hisagi's `:tick` hook, M4).
    #[test]
    fn snap_rollout_keeps_unported() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        debug::ensure_battle(&mut m, Character::Hisagi, Character::Kenpachi);
        assert!(flow::sim_running_p(&m) && m.unported.is_none());
        let tick = m.match_tick;
        let cut = snap_rollout(&mut m);
        assert!(cut.is_some());
        assert_eq!((m.unported, m.match_tick), (cut, tick));
    }

    #[test]
    fn mask_prefixes_and_keeps() {
        let mask: Vec<String> = ["gauges-", "!gauges-fs", "ics-"].iter().map(|s| s.to_string()).collect();
        assert!(masked(&mask, "p1.gauges-gg") && masked(&mask, "p2.ics-hist"));
        assert!(!masked(&mask, "p1.gauges-fs") && !masked(&mask, "p1.gauges-fs-idle") && !masked(&mask, "p1.fighter-sf"));
        assert!(!masked(&[], "p1.gauges-gg"));
    }
}
