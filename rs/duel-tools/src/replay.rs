//! port: tools/port/oracle/replay.lisp — the replay of a trace, compared step by step: brainless (M1), or `--live` (M2: the brains
//! think, nothing injected but a vs trace's human).
use crate::trace::{self, Item, TLine};
use duel_sim::components::{Button, Character, Form};
use duel_sim::cpu::Search;
use duel_sim::ecs::Entity;
use duel_sim::flow::{self, PilotInput};
use duel_sim::hashline::{bits_line, state_hash_line};
use duel_sim::debug::{self, LispValue};
use duel_sim::state::Match;
use duel_sim::vpad::Vpad;

/// port: trace.lisp TR-APPLY-EVENT: one E line's WORDS (after `E`), applied now (the grammar: trace.lisp's header).
pub fn apply_event(m: &mut Match, srch: &mut Search, words: &[String]) -> Result<(), String> {
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
        "battle" => debug::ensure_battle(m, srch, ch(1)?, ch(2)?, true),
        "form" => {
            let (e, f) = (side(m, 1)?, Form::from_name(&kw(2)?).ok_or(format!("E {}: no form", words.join(" ")))?);
            debug::force_form(m, e, f)
        }
        "hisagi-reset" => duel_sim::unported!(m, "hisagi-reset", Ok(())), // (Hisagi's: M4)
        "vs-start" => {
            let dif = duel_sim::components::Difficulty::from_name(&kw(3)?).ok_or(format!("E {}: no difficulty", words.join(" ")))?;
            debug::vs_start(m, srch, ch(1)?, ch(2)?, dif, val(4)?.int()?)
        }
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
        "cmd" => debug::debug_command(m, srch, val(1)?.int()?),
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
    /// Per side, the buttons and stick last injected: a vs trace's device's held state (record.lisp REC-VS-DEVICE), which it writes
    /// again on every read that does not advance it (`rewrite`).
    pub held: [(u16, (f32, f32)); 2],
}

impl Injector {
    pub fn new() -> Self {
        Injector { last: [-1, -1], t: None, fail: None, held: [(0, (0.0, 0.0)); 2] }
    }

    /// The device's held state of side K written again (VPAD-SET! of every button in order, then the stick, unclamped): its call on a
    /// step without a new vpad tick (PILOT-READ) and inside a rollout.
    pub fn rewrite(&self, vp: &mut Vpad, k: usize) {
        let (downs, stick) = self.held[k];
        for bit in 0..vp.actions.len() {
            vp.set(bit, downs >> bit & 1 == 1);
        }
        (vp.sx, vp.sy) = stick;
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
        self.held[k] = (t.downs[k], t.stick[k]);
        // port: VPAD-SET! of each button in bit order, then (setf (vpad-sx vp) sx (vpad-sy vp) sy) — no clamp (not VPAD-STICK!)
        self.rewrite(vp, k);
        Some(t.rnd)
    }
}

impl PilotInput for Injector {
    fn read(&mut self, m: &mut Match, side: usize) {
        let e = if side == 0 { m.p1 } else { m.p2 };
        // (a CPU seat's vpad has no reader: the brain writes it; the replay reads only detached seats)
        if m.fighter.get(e).is_none_or(|f| f.has_brain()) {
            return;
        }
        let Some(p) = m.pilot.get_mut(e) else { return };
        if let Some(r) = self.inject(&mut p.vpad, side) {
            m.rng.set_state(r);
        }
    }
    fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
    fn rollout_read(&mut self, _m: &mut Match, _side: usize) {}
}

pub enum Outcome {
    Ok(u64),
    Diverged(String),
    Unported(String),
    Error(String),
    /// The flags do not fit the trace (exit 3, one line).
    Refused(String),
}

/// The trace's start (its S line's first word).
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Kind {
    Cmds,
    Trials,
    Vs,
}

/// `duel-tools replay`'s flags (`parse_args`).
#[derive(Debug, Default, Clone)]
pub struct Opts {
    pub trace: String,
    pub max: Option<u64>,
    pub snap: Option<i64>,
    pub stubs: Vec<String>,
    pub mask: Vec<String>,
    pub data: Option<String>,
    pub bench: bool,
    /// The brains think (replay.lisp's "live"): nothing injected, T compared right after BRAIN-SYSTEM, the whole A line too.
    pub live: bool,
    /// On a T / A mismatch: note it, write the recorded vpads, sim stream and plan, go on (exit 1 at the end).
    pub resync: bool,
    /// A vs trace's human side, whose recorded vpad is injected (its sim stream never is).
    pub inject_side: Option<usize>,
    /// At each step's end (where MC-FULL-STEP runs), the plan changes MC-FULL-STEP made, from the next record (`plan_copy`); the A
    /// comparison then skips the job sections.
    pub inject_plan: bool,
}

/// `replay`'s usage line (printed with every flag error).
pub const USAGE: &str = "usage: duel-tools replay <trace> [--max-steps N] [--data DIR] [--stub S,..] [--mask F,..] [--snap N] [--bench] \
[--live [--resync] [--inject-side N] [--inject-plan]]";

/// The flags after `replay`: the trace first. Err((2, message + usage)): an unknown token (a typo, two flags pasted into one), a flag
/// without its value or with a bad one, an M2 flag without `--live`, `--live` with `--stub` / `--mask` (a live run compares
/// everything: the stubbed mode is the brainless replay's).
pub fn parse_args(args: &[String]) -> Result<Opts, (u8, String)> {
    let bad = |m: String| (2, format!("replay: {m}\n{USAGE}"));
    let mut o = Opts { trace: args.first().filter(|t| !t.starts_with("--")).cloned().ok_or_else(|| bad("no trace".into()))?, ..Opts::default() };
    let mut it = args[1..].iter();
    while let Some(k) = it.next() {
        let mut val = || it.next().cloned().ok_or_else(|| bad(format!("{k} needs a value")));
        // a number flag: a missing, non-numeric or out-of-range value is a usage error, never ignored
        let num = |v: String, min: u64, max: u64| {
            v.parse::<u64>().ok().filter(|n| (min..=max).contains(n)).ok_or_else(|| bad(format!("{k} needs an integer {min}..{max}, got {v:?}")))
        };
        let list = |v: String| v.split(',').filter(|x| !x.is_empty()).map(String::from).collect();
        match k.as_str() {
            "--max-steps" => o.max = Some(num(val()?, 1, u64::MAX)?),
            "--snap" => o.snap = Some(num(val()?, 1, i64::MAX as u64)? as i64),
            "--inject-side" => o.inject_side = Some(num(val()?, 0, 1)? as usize),
            "--stub" => o.stubs = list(val()?),
            "--mask" => o.mask = list(val()?),
            "--data" => o.data = Some(val()?),
            "--bench" => o.bench = true,
            "--live" => o.live = true,
            "--resync" => o.resync = true,
            "--inject-plan" => o.inject_plan = true,
            _ => return Err(bad(format!("unknown argument {k:?}"))),
        }
    }
    if !o.live && (o.resync || o.inject_plan || o.inject_side.is_some()) {
        return Err(bad("--resync, --inject-plan and --inject-side need --live".into()));
    }
    if o.bench && (o.max.is_some() || o.snap.is_some() || o.resync || o.inject_plan || o.inject_side.is_some() || !o.stubs.is_empty() || !o.mask.is_empty()) {
        return Err(bad("--bench takes only --live and --data".into()));
    }
    if o.live && (!o.stubs.is_empty() || !o.mask.is_empty()) {
        return Err(bad("--live compares every field: no --stub / --mask (the brainless replay's stubbed mode)".into()));
    }
    Ok(o)
}

/// A run's outcome, its `--snap` counts (rollouts, cut ones) and its `--resync` mismatches (the first 20 printed, the count).
pub struct RunResult {
    pub out: Outcome,
    pub snaps: (u64, u64),
    pub mismatches: Vec<String>,
    pub n_mismatch: u64,
    /// The page at the run's end (`Search.page`: a vs trace's learner saves to it).
    pub page: std::collections::BTreeMap<i64, i64>,
}

/// What `replay` prints and its exit code: the outcome line first (replay-gate.sh reads it), then the `--snap` summary and the
/// resynced mismatches. Exit 0 OK, 1 diverged / trace error / any mismatch, 3 unported or refused.
pub fn report(o: &Opts, r: &RunResult) -> (Vec<String>, u8) {
    let mut lines = vec![];
    let (line, mut code) = match &r.out {
        // (a stubbed / masked run says so on the outcome line: not the gate's full verdict)
        Outcome::Ok(n) if r.n_mismatch > 0 => (format!("replay RESYNCED {} mismatches in {n} ticks", r.n_mismatch), 1),
        Outcome::Ok(n) if !o.stubs.is_empty() || !o.mask.is_empty() => {
            (format!("replay OK (stubbed: {}; masked: {}) {n} ticks", o.stubs.join(","), o.mask.join(",")), 0)
        }
        Outcome::Ok(n) => (format!("replay OK {n} ticks"), 0),
        Outcome::Diverged(s) => (format!("replay DIVERGED at {s}"), 1),
        Outcome::Unported(s) => (format!("replay UNPORTED {s}"), 3),
        Outcome::Error(s) => (format!("replay: {s}"), 1),
        Outcome::Refused(s) => return (vec![format!("replay: {s}")], 3),
    };
    lines.push(line);
    if o.snap.is_some() {
        lines.push(format!("snap: {} rollouts of 40 sim steps, {} reached an unported path", r.snaps.0, r.snaps.1));
    }
    if r.n_mismatch > 0 {
        code = 1;
        lines.push(format!("resync: {} mismatches (the first {} below)", r.n_mismatch, r.mismatches.len()));
        lines.extend(r.mismatches.iter().map(|m| format!("  {m}")));
    }
    (lines, code)
}

/// The T fields now (tick, per side vpad tick / buttons / stick, the sim stream).
fn t_now(m: &Match) -> TLine {
    let side = |e| {
        m.pilot.get(e).map_or((0, 0, (0.0, 0.0)), |p| {
            let downs = p.vpad.downs.iter().enumerate().fold(0u16, |a, (i, &d)| a | ((d as u16 & 1) << i));
            (p.vpad.tick, downs, (p.vpad.sx, p.vpad.sy))
        })
    };
    let (s1, s2) = (side(m.p1), side(m.p2));
    TLine { tick: m.match_tick, vt: [s1.0, s2.0], downs: [s1.1, s2.1], stick: [s1.2, s2.2], rnd: m.rng.state() }
}

/// T as the trace writes it (TR-T-LINE; the sticks as Rust prints an f32, for messages).
fn t_text(t: &TLine) -> String {
    format!(
        "T {} {} {:03X} {:?} {:?} {} {:03X} {:?} {:?} {:08X}",
        t.tick, t.vt[0], t.downs[0], t.stick[0].0, t.stick[0].1, t.vt[1], t.downs[1], t.stick[1].0, t.stick[1].1, t.rnd
    )
}

/// Every T field equal (the sticks bit for bit: -0.0 is not 0.0).
fn t_equal(a: &TLine, b: &TLine) -> bool {
    let bits = |t: &TLine| t.stick.map(|(x, y)| (x.to_bits(), y.to_bits()));
    (a.tick, a.vt, a.downs, a.rnd, bits(a)) == (b.tick, b.vt, b.downs, b.rnd, bits(b))
}

/// `--resync`'s T repair: both sides' recorded vpad ticks, buttons (VPAD-SET! in bit order) and sticks, and the sim stream.
fn write_t(m: &mut Match, t: &TLine) {
    for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
        if let Some(p) = m.pilot.get_mut(e) {
            p.vpad.tick = t.vt[k];
            for bit in 0..p.vpad.actions.len() {
                p.vpad.set(bit, t.downs[k] >> bit & 1 == 1);
            }
            (p.vpad.sx, p.vpad.sy) = t.stick[k];
        }
    }
    m.rng.set_state(t.rnd);
}

/// The plan and mc-next of an A text (after `A `): its first 12 fields.
fn a_plan(a: &str) -> Result<[i64; 12], String> {
    let mut p = [0; 12];
    let mut w = a.split(' ');
    for x in p.iter_mut() {
        let v = w.next().ok_or("A: fewer than 12 fields")?;
        *x = v.parse().map_err(|_| format!("A: {v} is not an integer"))?;
    }
    Ok(p)
}

/// `--resync`'s A repair: the recorded `*mc-plan*` and `*mc-next*` written back (jobs and strategies are not: Search / the brain's own).
fn write_plan(m: &mut Match, a: &str) -> Result<(), String> {
    let p = a_plan(a)?;
    m.mc_plan.copy_from_slice(&p[..10]);
    m.mc_next.copy_from_slice(&p[10..]);
    Ok(())
}

/// `--inject-plan` (the controller's ruling): what MC-FULL-STEP would write at step k's end, taken from the next record's plan NEXT.
/// MC-FULL-STEP changes only a side whose plan state is 1 (a pending job): done, it writes 2, a1 / a2 and the two rounded scores; a
/// popped job or the snapshot-not-ok clear writes 0. So a side at 1 whose NEXT state is not 1 takes NEXT's 5 values; any other side is
/// left alone (NEXT at 1 is the brain's own new job; a 2 -> 0 at k+1 is the brain applying its plan in step k+1, Rust's brain's to do).
/// ponytail: the snapshot-not-ok clear also zeroes a side holding 2; that case is not mirrored (accepted, Task 8 removes the flag).
pub fn plan_copy(plan: &mut [i64; 10], next: &[i64]) {
    for k in [0, 5] {
        if plan[k] == 1 && next[k] != 1 {
            plan[k..k + 5].copy_from_slice(&next[k..k + 5]);
        }
    }
}

/// The A text before its job sections (`--inject-plan` compares only that: the jobs are the missing MC-FULL-STEP's Search state).
fn a_head(a: &str) -> &str {
    a.find(" |").map_or(a, |i| &a[..i])
}

/// port: replay.lisp's state: the step due now, the counts, the outcome once there is one (then reads and step ends are no-ops).
struct Replayer<I: Iterator<Item = Result<Item, String>>> {
    it: I,
    inj: Injector,
    fields: Vec<String>,
    a_fields: Vec<String>,
    mask: Vec<String>,
    cur: Option<Item>,
    steps: u64,
    items: u64,
    max: Option<u64>,
    kind: Kind,
    out: Option<Outcome>,
    /// `--snap N`: every N battle ticks a rollout on the live match, then restored from its snapshot (`snap_rollout`).
    snap: Option<i64>,
    /// `--snap`'s snapshot slot, reused by every snapshot after the first (`clone_from` into a used slot, as `cpu::POOL`'s are).
    snap_slot: Option<Match>,
    pub snaps: u64,
    pub snaps_unported: u64,
    live: bool,
    resync: bool,
    inject_side: Option<usize>,
    inject_plan: bool,
    /// Live: this step's T was compared at the brain hook (a sim frame).
    t_done: bool,
    /// The log's length at this step's first vpad read (the recorder's *rec-pre*: what is before it is not the CPUs'). Live: a CPU's
    /// vpad read only (the recorder's REC-READER sits on the brains' vpads), which a sim frame fires in CORE-BRAIN-STEP.
    pre: Option<usize>,
    /// Live: the CPUs' lines this step (C), taken at the brain hook.
    c_got: Vec<String>,
    /// Live vs: the injected side's fighter (a new match's resets its last injected tick).
    seat: Entity,
    /// Items read ahead of `cur` (`--inject-plan` looks for the next step's A).
    ahead: std::collections::VecDeque<Result<Item, String>>,
    mismatches: Vec<String>,
    n_mismatch: u64,
}

impl<I: Iterator<Item = Result<Item, String>>> Replayer<I> {
    /// The next item becomes the one due (a step's T goes to the injector).
    fn advance(&mut self) {
        let next = self.ahead.pop_front().or_else(|| self.it.next());
        self.cur = match next {
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

    /// The A text of the next step record after `cur` (read ahead, kept for `advance`), or None at the end / in a trace without A.
    fn next_step_a(&mut self) -> Option<String> {
        if let Some(Item::Step { a, .. }) = &self.cur {
            return a.clone();
        }
        for i in 0.. {
            if i == self.ahead.len() {
                self.ahead.push_back(self.it.next()?);
            }
            match &self.ahead[i] {
                Ok(Item::Step { a, .. }) => return a.clone(),
                Err(_) => return None,
                _ => {}
            }
        }
        None
    }

    /// A CPU rollout (MC-FULL-STEP's, at the last step's end) cut short by an `unported!` path: its value was wrong, so the run is
    /// UNPORTED (never OK, as a `--snap` rollout's cut).
    fn check_cut(&mut self, s: &Search) {
        if let (None, Some((name, tick))) = (&self.out, s.cut) {
            self.out = Some(Outcome::Unported(format!("{name} in a rollout from tick {tick} (step {})", self.steps)));
        }
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

    /// A T or A mismatch: a divergence, or with `--resync` a note (the caller then writes the recorded values). True when resyncing.
    fn mismatch(&mut self, m: &Match, what: String) -> bool {
        if !self.resync {
            self.fail(m, what);
            return false;
        }
        self.n_mismatch += 1;
        if self.mismatches.len() < 20 {
            self.mismatches.push(format!("tick {} (step {}): {what}", m.match_tick, self.steps));
        }
        true
    }

    /// port: RP-DETACH: both brains off once a match has spawned them; their vpads read the trace from their current tick.
    fn detach(&mut self, m: &mut Match) {
        for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
            let Some(f) = m.fighter.get_mut(e) else { continue };
            if f.brain.take().is_none() {
                continue;
            }
            let vt = m.pilot.get(e).map_or(0, |p| p.vpad.tick);
            if self.kind == Kind::Cmds && vt > 0 {
                self.fail(m, format!("P{}'s brain ran {vt} sim frames before it could be detached", k + 1));
            }
            self.inj.last[k] = vt;
        }
    }

    /// Live vs: the injected side's vpad reads the trace from its current tick once a (new) match has spawned it (RP-DETACH's P1 part).
    fn seat_injected(&mut self, m: &Match) {
        let Some(k) = self.inject_side else { return };
        let e = if k == 0 { m.p1 } else { m.p2 };
        if e != self.seat {
            // (the device's RESET at a new match: everything released, from the new vpad's tick)
            self.seat = e;
            self.inj.last[k] = m.pilot.get(e).map_or(0, |p| p.vpad.tick);
            self.inj.held[k] = (0, (0.0, 0.0));
        }
    }

    /// Live: T now against the step's (a mismatch resynced with `--resync`).
    fn check_t(&mut self, m: &mut Match) {
        let Some(Item::Step { t: want, .. }) = &self.cur else { return };
        let (want, got) = (want.clone(), t_now(m));
        if !t_equal(&want, &got) && self.mismatch(m, format!("T: want {} got {}", t_text(&want), t_text(&got))) {
            write_t(m, &want);
        }
    }
}

impl<I: Iterator<Item = Result<Item, String>>> PilotInput for Replayer<I> {
    fn read(&mut self, m: &mut Match, side: usize) {
        if self.out.is_some() {
            return;
        }
        let e = if side == 0 { m.p1 } else { m.p2 };
        if !self.live || m.fighter.get(e).is_some_and(|f| f.has_brain()) {
            self.pre.get_or_insert(m.log.len());
        }
        if !self.live {
            return self.inj.read(m, side);
        }
        // (live: only a vs trace's human side; its sim stream is never injected, replay.lisp RP-INJECT)
        // (record.lisp REC-VS-DEVICE: it advances on a new vpad tick, and every call writes its held state)
        if self.inject_side == Some(side)
            && m.fighter.get(e).is_some_and(|f| !f.has_brain())
            && let Some(p) = m.pilot.get_mut(e)
            && self.inj.inject(&mut p.vpad, side).is_none()
        {
            self.inj.rewrite(&mut p.vpad, side);
        }
    }

    /// The vs device inside a CPU rollout: the human's held state written again on his vpad (the stand-in brain's VPAD-BEGIN-STEP!
    /// calls it before AI-PRESS-WRITE!), never advanced; no comparison.
    fn rollout_read(&mut self, m: &mut Match, side: usize) {
        let e = if side == 0 { m.p1 } else { m.p2 };
        if self.out.is_none()
            && self.live
            && self.inject_side == Some(side)
            && let Some(p) = m.pilot.get_mut(e)
        {
            self.inj.rewrite(&mut p.vpad, side);
        }
    }

    /// The recorder's brain hook: T is taken here on a sim frame, and the CPUs' lines (C) are those printed since the first vpad read.
    fn after_brain(&mut self, m: &mut Match, _s: &mut Search) {
        if self.out.is_some() || !self.live {
            return;
        }
        let from = self.pre.unwrap_or(0).min(m.log.len());
        self.c_got = m.log.drain(from..).collect();
        self.check_t(m);
        self.t_done = true;
    }

    /// port: RP-STEP.
    fn step_end(&mut self, m: &mut Match, s: &mut Search) {
        let (t_done, c_got) = (std::mem::take(&mut self.t_done), std::mem::take(&mut self.c_got));
        self.pre = None;
        self.check_cut(s);
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
        if !matches!(self.cur, Some(Item::Step { .. })) {
            return match self.cur.take() {
                Some(other) => self.fail(m, format!("a step ran where the trace has {other:?}")),
                _ => self.fail(m, "the replay runs past the trace's end".into()),
            };
        }
        if self.live {
            let Some(Item::Step { log: wl, c: wc, .. }) = &self.cur else { unreachable!() };
            if *wc != c_got {
                return self.fail(m, format!("C: want {wc:?} got {c_got:?}"));
            }
            if *wl != log {
                return self.fail(m, format!("log: want {wl:?} got {log:?}"));
            }
            if !t_done {
                self.check_t(m); // (no sim frame: the recorder took T at the step's end)
            }
            if self.out.is_some() {
                return;
            }
        }
        let want = self.cur.take().unwrap();
        let t = t_now(m);
        let (h, b) = (state_hash_line(m), bits_line(m));
        let b = b.strip_prefix("B ").unwrap_or(&b);
        let what = if self.live {
            // (T was compared above; the log too)
            let Item::Step { h: wh, b: wb, .. } = &want else { unreachable!() };
            if wh != &h {
                Some(format!("H: want {wh} got {h}"))
            } else if wb != b {
                b_diff(&self.fields, &[], wb, b).or(Some("B (equal fields, other text)".into()))
            } else {
                None
            }
        } else {
            compare(&self.fields, &self.mask, &want, &log, &t, &h, b)
        };
        if let Some(what) = what {
            return self.fail(m, what);
        }
        if self.live {
            let Item::Step { a, .. } = &want else { unreachable!() };
            let Some(wa) = a else { return self.fail(m, "the trace has no A line for this step".into()) };
            let got = duel_sim::cpu::a_line(m, s);
            let got = got.strip_prefix("A ").unwrap_or(&got);
            // (--inject-plan: the job sections are the missing MC-FULL-STEP's Search state, not compared)
            let (wa, got) = if self.inject_plan { (a_head(wa), a_head(got)) } else { (wa.as_str(), got) };
            let diff = trace::a_diff(&self.a_fields, wa, got).or((wa != got).then(|| "A (equal fields, other text)".into()));
            // (--resync: the plan written back; the brains' other slots are the CPU's own)
            if diff.is_some_and(|d| self.mismatch(m, d))
                && let Err(e) = write_plan(m, wa)
            {
                self.out = Some(Outcome::Error(e));
                return;
            }
        }
        self.steps += 1;
        self.items += 1;
        if self.kind == Kind::Cmds && !self.live {
            self.detach(m);
        }
        if self.snap.is_some_and(|n| flow::battle_p(m) && m.match_tick % n == 0) {
            self.snaps += 1;
            let mut slot = self.snap_slot.take();
            let cut = snap_rollout(m, s, self, &mut slot);
            self.snap_slot = slot;
            if let Some(name) = cut {
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
        // (--inject-plan: at step k's end, where MC-FULL-STEP runs, after the point the recorder printed A(k))
        if self.inject_plan
            && let Some(next) = self.next_step_a()
        {
            match a_plan(&next) {
                Ok(p) => plan_copy(&mut m.mc_plan, &p[..10]),
                Err(e) => self.out = Some(Outcome::Error(e)),
            }
        }
    }
}

/// Replays PATH (at most MAX steps) with M1's flags (`run_opts`' brainless replay).
#[cfg(test)]
pub fn run(path: &str, max: Option<u64>, data: &'static duel_data::Data, stubs: &[String], mask: &[String]) -> Outcome {
    let o = Opts { trace: path.into(), max, stubs: stubs.to_vec(), mask: mask.to_vec(), ..Opts::default() };
    run_opts(&o, data).out
}

/// Replays the trace: replay.lisp's cmds start (SG-INIT, the S line's commands queued, TR-RUN-FRAMES' loop until the gate and the
/// match are over), or a trials / vs trace's RP-DRIVE (one frame, then its E lines applied and F lines run in order). Brainless (both
/// brains detached, the recorded vpads and sim stream injected), or with `--live` the brains attached and nothing injected but a vs
/// trace's `--inject-side`. STUBS / MASK: the stubbed mode (docs/bevy/M1_NOTES.md §3; both empty = the gate's full comparison).
pub fn run_opts(o: &Opts, data: &'static duel_data::Data) -> RunResult {
    let mut r = RunResult { out: Outcome::Ok(0), snaps: (0, 0), mismatches: vec![], n_mismatch: 0, page: Default::default() };
    let mut rd = match trace::open(&o.trace) {
        Ok(r) => r,
        Err(e) => {
            r.out = Outcome::Error(e);
            return r;
        }
    };
    let (start, fields) = match rd.start() {
        Ok(x) => x,
        Err(e) => {
            r.out = Outcome::Error(e);
            return r;
        }
    };
    let kind = match start.first().map(String::as_str) {
        Some("trials") => Kind::Trials,
        Some("vs") => Kind::Vs,
        _ => Kind::Cmds,
    };
    let s_line = format!("S {}", start.first().map_or("", String::as_str));
    if o.live && kind == Kind::Trials {
        r.out = Outcome::Refused(format!("--live needs a cmds or vs trace, this one is {s_line}"));
        return r;
    }
    if o.inject_side.is_some() && kind != Kind::Vs {
        r.out = Outcome::Refused(format!("--inject-side needs a vs trace, this one is {s_line}"));
        return r;
    }
    let mut m = Match::new(data);
    m.stubs = o.stubs.clone();
    flow::go_title(&mut m); // (SG-INIT: START-GAME)
    let a_fields = rd.a_fields.clone();
    let mut rp = Replayer {
        it: rd,
        inj: Injector::new(),
        fields,
        a_fields,
        mask: o.mask.clone(),
        cur: None,
        steps: 0,
        items: 0,
        max: o.max,
        kind,
        out: None,
        snap: o.snap,
        snaps: 0,
        snaps_unported: 0,
        snap_slot: None,
        live: o.live,
        resync: o.resync,
        inject_side: o.inject_side,
        inject_plan: o.inject_plan,
        t_done: false,
        pre: None,
        c_got: vec![],
        seat: Entity::NIL,
        ahead: Default::default(),
        mismatches: vec![],
        n_mismatch: 0,
    };
    let mut s = Search::new();
    r.out = drive(&mut m, &mut s, &mut rp, &start);
    r.snaps = (rp.snaps, rp.snaps_unported);
    (r.mismatches, r.n_mismatch) = (rp.mismatches, rp.n_mismatch);
    r.page = std::mem::take(&mut s.page);
    r
}

fn drive<I: Iterator<Item = Result<Item, String>>>(m: &mut Match, s: &mut Search, rp: &mut Replayer<I>, start: &[String]) -> Outcome {
    rp.advance();
    if rp.kind != Kind::Cmds {
        flow::frame_headless(m, s, rp, &mut duel_sim::look::NoLook); // (trial.lisp's start: one frame, no step)
        rp.check_unported(m);
        while rp.out.is_none() {
            match rp.cur.take() {
                None => return Outcome::Ok(rp.steps),
                Some(Item::Event { words, e_lines }) => {
                    // port: RP-DRIVE's :event: what the action prints must equal its e lines
                    rp.items += 1;
                    m.log.clear();
                    if let Err(e) = apply_event(m, s, &words) {
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
                    if rp.live {
                        rp.seat_injected(m);
                    } else {
                        rp.detach(m);
                    }
                    rp.advance();
                    flow::frame_headless(m, s, rp, &mut duel_sim::look::NoLook);
                    rp.check_unported(m);
                    rp.check_cut(s);
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
    flow::frame_headless(m, s, rp, &mut duel_sim::look::NoLook);
    rp.check_unported(m);
    for _ in 0..2_000_000 {
        if let Some(out) = rp.out.take() {
            return out;
        }
        let go = flow::frame_headless(m, s, rp, &mut duel_sim::look::NoLook);
        rp.check_unported(m);
        rp.check_cut(s);
        if let Some(out) = rp.out.take() {
            return out;
        }
        if !go {
            return Outcome::Error("the frame stopped".into());
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

/// `--snap`'s rollout (tools/simgate/snaptest.lisp's: snapshot, SIM-ROLLOUT on the live match with the styles kept, every log off,
/// cinematics skipped, restore): the live match is snapshotted into SLOT (`clone_from` into the slot an earlier snapshot used, after
/// the first), its sim stream reseeded as snaptest does, 40 lean steps played on it on the vpads as they are, then restored from SLOT
/// by `clone_from` into the played-on match. So both directions of the game's restore path run on used storage, and a field
/// `clone_from` misses either way leaves the live match off the trace (M2 final review minor 4: the old copy-and-discard could not see
/// a restore hole). Returns the `unported!` path the rollout reached, if any, and keeps it in the restored match's `unported` (a run
/// with a cut rollout is never OK). The search S is the live one: inside a rollout nothing writes it (`*in-rollout*`'s guards). INPUT:
/// the live readers, whose in-rollout calls run (a vs trace's human: his held keys, PILOT-SYSTEM's read of a brainless seat).
fn snap_rollout(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput, slot: &mut Option<Match>) -> Option<&'static str> {
    let snap = match slot {
        Some(x) => {
            x.clone_from(m);
            x
        }
        None => slot.insert(m.clone()),
    };
    m.rng.set_state((m.rng.state() ^ 0x5BD1_E995) | 1);
    duel_sim::cpu::mcts::sim_rollout(m, s, &mut flow::InRollout(input), 40);
    let cut = m.unported;
    m.clone_from(snap);
    m.unported = m.unported.or(cut);
    cut
}

/// `--bench`'s input: the trace's T lines, read before the clock starts, injected as the replay does (RP-INJECT, RP-DETACH); no
/// comparison, no log. With `live` the brains stay on and nothing is injected (`--live --bench`: both CPUs think, M2_NOTES §10).
pub struct BenchInput {
    inj: Injector,
    ts: Vec<TLine>,
    live: bool,
    pub steps: usize,
}

impl PilotInput for BenchInput {
    fn read(&mut self, m: &mut Match, side: usize) {
        if !self.live {
            self.inj.t = self.ts.get(self.steps).cloned();
            self.inj.read(m, side);
        }
    }
    fn rollout_read(&mut self, _m: &mut Match, _side: usize) {} // (no device: brainless, or CPU against CPU)
    fn step_end(&mut self, m: &mut Match, _s: &mut Search) {
        self.steps += 1;
        if self.live {
            return;
        }
        for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
            if let Some(f) = m.fighter.get_mut(e).filter(|f| f.has_brain()) {
                f.brain = None;
                self.inj.last[k] = m.pilot.get(e).map_or(0, |p| p.vpad.tick);
            }
        }
    }
}

/// A cmds trace read for `--bench`: the match after its S line's commands and first frame (the combat log off), the search, its
/// input, the trace's last H.
pub fn bench_setup(path: &str, data: &'static duel_data::Data, live: bool) -> Result<(Match, Search, BenchInput, String), String> {
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
    let mut inp = BenchInput { inj: Injector::new(), ts, live, steps: 0 };
    let mut s = Search::new();
    flow::frame_headless(&mut m, &mut s, &mut inp, &mut duel_sim::look::NoLook);
    m.log_on = false; // (DEBUG-COMMAND turns it on; the gate's matches run with it off)
    Ok((m, s, inp, h))
}

/// One frame of the bench loop; false once the run is over (the replay's end test).
pub fn bench_frame(m: &mut Match, s: &mut Search, inp: &mut BenchInput) -> bool {
    let go = flow::frame_headless(m, s, inp, &mut duel_sim::look::NoLook);
    m.log.clear();
    go && !(m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(m))
}

/// `--bench`'s figures: the trace's steps, the runs' seconds (sorted), whether every run reproduced the trace (its step count and
/// final H), and the CPU rollouts of a run (MC-FULL-STEP's and STRAT-ROLL's; 0 brainless).
pub struct Bench {
    pub steps: usize,
    pub secs: Vec<f64>,
    pub same: bool,
    pub rollouts: i64,
}

/// `--bench`: the match run RUNS times in-process, each from a fresh setup (a clone would drop the stores' reserved capacity). A run is
/// 15-60 ms, so the median of several is the figure.
pub fn bench(path: &str, data: &'static duel_data::Data, runs: usize, live: bool) -> Result<Bench, String> {
    let mut b = Bench { steps: 0, secs: vec![], same: true, rollouts: 0 };
    for _ in 0..runs {
        let (mut m, mut s, mut inp, h) = bench_setup(path, data, live)?;
        let t0 = std::time::Instant::now();
        while bench_frame(&mut m, &mut s, &mut inp) {}
        b.secs.push(t0.elapsed().as_secs_f64());
        if let Some(n) = m.unported.or(s.cut.map(|c| c.0)) {
            return Err(format!("--bench: unported {n}"));
        }
        b.same &= inp.steps == inp.ts.len() && state_hash_line(&m) == h;
        (b.steps, b.rollouts) = (inp.steps, s.mc_stats[1] + s.strat_stats[1]);
    }
    b.secs.sort_by(f64::total_cmp);
    Ok(b)
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
    let Item::Step { log: wl, t: wt, h: wh, b: wb, .. } = want else { return Some("not a step".into()) };
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
        return b_diff(fields, mask, wb, b);
    }
    None
}

/// The first differing B field of WB and B, named (a hazard's as `hz<n>.<slot>`), MASK's fields skipped; None if only masked ones differ.
pub fn b_diff(fields: &[String], mask: &[String], wb: &str, b: &str) -> Option<String> {
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
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The live gate's 17 cmds rows: the 15 cvc gate traces, then KI seed 1 at HARD and at EASY (M2 final review I2).
    const CVC_GATE: [&str; 17] = ["cvc-kk-s1", "cvc-kk-s2", "cvc-kk-s3", "cvc-ki-s1", "cvc-ki-s2", "cvc-ki-s3", "cvc-ik-s1", "cvc-ik-s2",
        "cvc-ik-s3", "cvc-ii-s1", "cvc-ii-s2", "cvc-ii-s3", "cvctag-ii", "cvctag-ik", "cvctag-kk", "cvc-ki-s1-hard", "cvc-ki-s1-easy"];

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
                Outcome::Error(s) | Outcome::Refused(s) => format!("ERROR {s}"),
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
                Outcome::Error(s) | Outcome::Refused(s) => format!("ERROR {s}"),
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
        let (mut m, mut s, mut inp, _) = bench_setup(&path, data, false).unwrap();
        let (mut steps, mut allocs) = (0, 0);
        loop {
            let (s0, a0, before) = (inp.steps, crate::alloc_count::count(), flow::battle_p(&m));
            let go = bench_frame(&mut m, &mut s, &mut inp);
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

    /// The 0 B / step rule with both CPUs thinking (ruling R8): each of the 17 cvc rows' commands (its S line) run live (no
    /// reader, the combat log off after the commands' frame) allocate nothing in any frame that starts and ends in the battle: the styles, the strategies, the
    /// MCTS's snapshots into the preallocated slots and its rollouts on the scratch match, Ichigo's clones (fixed-capacity `Few` lists
    /// since Task 10). A learning VS match is outside it (M2_NOTES §9: BRAIN-FQL's records, FQ-NOTE's list, as the Lisp conses).
    #[test]
    fn live_allocs() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        for name in CVC_GATE {
            let Some(path) = oracle_trace(name) else { return };
            let s_line = std::io::BufRead::lines(std::io::BufReader::new(std::fs::File::open(&path).unwrap()))
                .map(Result::unwrap)
                .find_map(|l| l.strip_prefix("S cmds ").map(String::from))
                .unwrap();
            let mut m = Match::new(data);
            flow::go_title(&mut m);
            m.cmds.extend(s_line.split(' ').map(|c| c.parse::<i64>().unwrap()));
            let s = &mut Search::new();
            flow::frame_headless(&mut m, s, &mut flow::NoInput, &mut duel_sim::look::NoLook);
            m.log_on = false; // (as `--bench`: the debug commands turn the combat log on)
            let (mut allocs, mut steps) = (0, 0);
            for _ in 0..200_000 {
                let (a0, t0, before) = (crate::alloc_count::count(), m.match_tick, flow::battle_p(&m));
                flow::frame_headless(&mut m, s, &mut flow::NoInput, &mut duel_sim::look::NoLook);
                if before && flow::battle_p(&m) {
                    (allocs, steps) = (allocs + crate::alloc_count::count() - a0, steps + (m.match_tick - t0).max(0));
                }
                if m.unported.is_some() || m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
                    break;
                }
            }
            assert_eq!(m.unported, None);
            eprintln!("live_allocs {name}: {allocs} allocations in {steps} battle steps; {} decisions, {} rollouts", s.mc_stats[0], s.mc_stats[1]);
            assert!(steps > 10_000, "{name} {steps}");
            assert_eq!(allocs, 0, "{name}: allocations in {steps} battle steps");
        }
    }

    /// The 0 B / step rule with the look queue on (M3a Task 4): the 17 cvc rows as `live_allocs` runs them, with a counting sink at
    /// FEEDBACK-SYSTEM's place (every event's kind tallied into a fixed array, the queue drained): no allocation in any frame that starts
    /// and ends in the battle, and the sink saw the looks (not vacuous).
    #[test]
    fn look_queue_no_alloc() {
        use duel_sim::look::{LookEvent, LookSink};
        struct Tally([u64; 2]);
        impl LookSink for Tally {
            fn step(&mut self, m: &mut Match) {
                for ev in m.looks.drain() {
                    self.0[matches!(ev, LookEvent::Emit(_)) as usize] += 1;
                }
            }
        }
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        for name in CVC_GATE {
            let Some(path) = oracle_trace(name) else { panic!("no answer key (set ORACLE)") };
            let s_line = std::io::BufRead::lines(std::io::BufReader::new(std::fs::File::open(&path).unwrap()))
                .map(Result::unwrap)
                .find_map(|l| l.strip_prefix("S cmds ").map(String::from))
                .unwrap();
            let mut m = Match::new(data);
            flow::go_title(&mut m);
            let (s, t) = (&mut Search::new(), &mut Tally([0; 2]));
            t.frame(&mut m); // (the title's calls drained before the match starts, as the page's frames do: `warm`'s slots see less)
            m.cmds.extend(s_line.split(' ').map(|c| c.parse::<i64>().unwrap()));
            flow::frame_headless(&mut m, s, &mut flow::NoInput, t);
            m.log_on = false;
            let (mut allocs, mut steps) = (0, 0);
            for _ in 0..200_000 {
                let (a0, t0, before) = (crate::alloc_count::count(), m.match_tick, flow::battle_p(&m));
                flow::frame_headless(&mut m, s, &mut flow::NoInput, t);
                if before && flow::battle_p(&m) {
                    (allocs, steps) = (allocs + crate::alloc_count::count() - a0, steps + (m.match_tick - t0).max(0));
                }
                if m.unported.is_some() || m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
                    break;
                }
            }
            assert_eq!(m.unported, None);
            eprintln!("look_queue_no_alloc {name}: {allocs} allocations in {steps} battle steps; {} calls, {} events", t.0[0], t.0[1]);
            assert!(steps > 10_000 && t.0[0] > steps as u64 && t.0[1] > 0, "{name} {steps} {:?}", t.0);
            assert_eq!(allocs, 0, "{name}: allocations in {steps} battle steps");
        }
    }

    /// The real look sink (`duel_look::Scene`) on the 17 cvc gate rows: FEEDBACK-SYSTEM's port (stamps, particles, the shake, the
    /// stage's marks, the sounds) runs on every event of whole matches with no panic and no allocation in a battle frame. The draw key cannot check these looks before Task 8's battle scenes.
    #[test]
    fn scene_sink_no_alloc() {
        use duel_sim::look::LookSink;
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let inputs = duel_look::SceneInputs { width: 640, height: 360, density: 1.0, msaa: 1, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
        for name in CVC_GATE {
            let Some(path) = oracle_trace(name) else { panic!("no answer key (set ORACLE)") };
            let s_line = std::io::BufRead::lines(std::io::BufReader::new(std::fs::File::open(&path).unwrap()))
                .map(Result::unwrap)
                .find_map(|l| l.strip_prefix("S cmds ").map(String::from))
                .unwrap();
            let mut m = Match::new(data);
            flow::go_title(&mut m);
            let (s, sc) = (&mut Search::new(), &mut duel_look::Scene::new(data, inputs));
            sc.frame(&mut m);
            m.cmds.extend(s_line.split(' ').map(|c| c.parse::<i64>().unwrap()));
            flow::frame_headless(&mut m, s, &mut flow::NoInput, sc);
            m.log_on = false;
            let (mut allocs, mut steps, mut sounds) = (0, 0, 0);
            for _ in 0..200_000 {
                let (a0, t0, before) = (crate::alloc_count::count(), m.match_tick, flow::battle_p(&m));
                flow::frame_headless(&mut m, s, &mut flow::NoInput, sc);
                sounds += sc.sounds.len(); // (the frame's requests: the next frame's start clears them)
                if before && flow::battle_p(&m) {
                    (allocs, steps) = (allocs + crate::alloc_count::count() - a0, steps + (m.match_tick - t0).max(0));
                }
                if m.unported.is_some() || m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
                    break;
                }
            }
            assert_eq!(m.unported, None);
            eprintln!("scene_sink_no_alloc {name}: {allocs} allocations in {steps} battle steps; {sounds} sounds; look unported: {:?}", sc.unported);
            assert!(steps > 10_000 && sounds > 0, "{name} {steps} {sounds}");
            assert_eq!(allocs, 0, "{name}: allocations in {steps} battle steps");
        }
    }

    /// The draw side on battle data: the page's loop (`flow::frame`, `draw_frame`, `flow::frame_end`) with the real `Scene` on
    /// the 17 cvc gate rows, so STAMPS-DRAW, HAZARD-DRAW, the line cuts, chips, rings and every particle kind draw on whole matches: no
    /// panic, 0 allocations in a battle frame. Turbo is off after the commands (drawn frames, one step each). (`Scene.unported` is set
    /// at the first cinematic's camera, Task 8; drawing goes on.)
    #[test]
    fn scene_draw_no_alloc() {
        use duel_sim::look::LookSink;
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let inputs = duel_look::SceneInputs { width: 640, height: 360, density: 1.0, msaa: 1, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
        let mut out = duel_look::FrameOut::default();
        for name in CVC_GATE {
            let Some(path) = oracle_trace(name) else { panic!("no answer key (set ORACLE)") };
            let s_line = std::io::BufRead::lines(std::io::BufReader::new(std::fs::File::open(&path).unwrap()))
                .map(Result::unwrap)
                .find_map(|l| l.strip_prefix("S cmds ").map(String::from))
                .unwrap();
            let mut m = Match::new(data);
            flow::go_title(&mut m);
            let (s, sc) = (&mut Search::new(), &mut duel_look::Scene::new(data, inputs));
            sc.frame(&mut m);
            m.cmds.extend(s_line.split(' ').map(|c| c.parse::<i64>().unwrap()));
            let mut frame = |m: &mut Match, s: &mut Search, sc: &mut duel_look::Scene, out: &mut duel_look::FrameOut| {
                let rdt = flow::raw_dt(m.frame_n + 1);
                flow::frame(m, s, &mut flow::NoInput, sc, rdt);
                let d0 = crate::alloc_count::count();
                duel_look::draw_frame(sc, m, rdt, out);
                let d = crate::alloc_count::count() - d0;
                flow::frame_end(m, s);
                d
            };
            frame(&mut m, s, sc, &mut out);
            (m.log_on, m.turbo) = (false, false); // (drawn: one step a frame, as the page)
            let (mut allocs, mut frames, mut fx, mut dallocs) = (0, 0, 0, 0);
            for _ in 0..200_000 {
                let (a0, before) = (crate::alloc_count::count(), flow::battle_p(&m));
                let d = frame(&mut m, s, sc, &mut out);
                if before && flow::battle_p(&m) && d > 0 && dallocs == 0 {
                    eprintln!("  first draw_frame allocation: frame {} tick {} cine {:?} hazards {}", m.frame_n, m.match_tick, m.cine.is_some(), m.hazard.len());
                }
                dallocs += d;
                fx += out.fxa.len() + out.fxb.len() + out.ft.len();
                if before && flow::battle_p(&m) {
                    (allocs, frames) = (allocs + crate::alloc_count::count() - a0, frames + 1);
                }
                if m.unported.is_some() || m.gate.is_empty() && !m.gate_busy && m.gate_results.is_empty() && !flow::battle_p(&m) {
                    break;
                }
            }
            assert_eq!(m.unported, None);
            eprintln!("scene_draw_no_alloc {name}: {allocs} allocations in {frames} battle frames ({dallocs} in draw_frame); {fx} fx floats; dropped {}; look unported: {:?}", out.fx_dropped, sc.unported);
            assert!(frames > 10_000 && fx > 0, "{name} {frames} {fx}");
            assert_eq!(allocs, 0, "{name}: allocations in {frames} battle frames");
        }
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

    /// A `--snap` rollout that reaches an `unported!` path reports it and the restored match keeps it (Hisagi's `:tick` hook, M4);
    /// `flow::frame_headless` then returns false.
    #[test]
    fn snap_rollout_keeps_unported() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        debug::ensure_battle(&mut m, &mut Search::new(), Character::Hisagi, Character::Kenpachi, true);
        assert!(flow::sim_running_p(&m) && m.unported.is_none());
        let tick = m.match_tick;
        let cut = snap_rollout(&mut m, &mut Search::new(), &mut flow::NoInput, &mut None);
        assert!(cut.is_some());
        assert_eq!((m.unported, m.match_tick), (cut, tick));
        // (the game loop's frame says so, runs no step; so does a cut CPU rollout's)
        assert!(!flow::frame_headless(&mut m, &mut Search::new(), &mut flow::NoInput, &mut duel_sim::look::NoLook));
        assert_eq!(m.match_tick, tick);
        let (mut m2, mut s2) = (Match::new(data), Search::new());
        flow::go_title(&mut m2);
        debug::ensure_battle(&mut m2, &mut s2, Character::Kenpachi, Character::Kenpachi, true);
        let t2 = m2.match_tick;
        s2.cut = Some(("x", 1));
        assert!(!flow::frame_headless(&mut m2, &mut s2, &mut flow::NoInput, &mut duel_sim::look::NoLook));
        assert_eq!(m2.match_tick, t2);
    }

    fn args(s: &str) -> Vec<String> {
        s.split(' ').map(String::from).collect()
    }

    /// M2's flags; each of `--resync` / `--inject-plan` / `--inject-side` needs `--live`; a side is 0 or 1; `--live` takes no `--stub` /
    /// `--mask`; an unknown token, a flag without its value, `--bench` with a replay flag: exit 2, as M1's bad numbers.
    #[test]
    fn live_flags_parse() {
        let o = parse_args(&args("t.trace --live --resync --inject-side 0 --inject-plan")).unwrap();
        assert_eq!((o.trace.as_str(), o.live, o.resync, o.inject_side, o.inject_plan), ("t.trace", true, true, Some(0), true));
        let o = parse_args(&args("t.trace --max-steps 5")).unwrap();
        assert_eq!((o.live, o.resync, o.inject_side, o.inject_plan, o.max), (false, false, None, false, Some(5)));
        for bad in ["t --resync", "t --inject-plan", "t --inject-side 1", "t --live --inject-side 2", "t --live --inject-side", "t --snap 0",
                    "t --live --mask a", "t --live --stub HS-TICK", "t --bogus", "t --snap", "--live",
                    "t --bench --snap 40", "t 40"] {
            assert_eq!(parse_args(&args(bad)).err().map(|e| e.0), Some(2), "{bad}");
        }
        // (two flags pasted into one token)
        assert_eq!(parse_args(&["t".into(), "--live --inject-plan".into()]).err().map(|e| e.0), Some(2));
    }

    /// `--live` replays a cmds or a vs trace (brains attached as the build does); a trials trace is refused in one line, exit 3.
    #[test]
    fn live_needs_cmds_or_vs_trace() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let p = std::env::temp_dir().join(format!("replay-live-{}.trace", std::process::id()));
        std::fs::write(&p, "S trials f.lisp\nE set - *COMBAT-LOG* NIL\nF\n").unwrap();
        let o = parse_args(&args(&format!("{} --live", p.display()))).unwrap();
        let r = run_opts(&o, data);
        let _ = std::fs::remove_file(&p);
        let (lines, code) = report(&o, &r);
        assert_eq!(code, 3);
        assert_eq!(lines, ["replay: --live needs a cmds or vs trace, this one is S trials"]);
        // (--inject-side names a human: a vs trace only)
        let p = std::env::temp_dir().join(format!("replay-side-{}.trace", std::process::id()));
        std::fs::write(&p, "S cmds 1\n").unwrap();
        let o = parse_args(&args(&format!("{} --live --inject-side 0", p.display()))).unwrap();
        let r = run_opts(&o, data);
        let _ = std::fs::remove_file(&p);
        assert_eq!(report(&o, &r), (vec!["replay: --inject-side needs a vs trace, this one is S cmds".to_string()], 3));
    }

    /// `--live cvc-ki-s1`: the brains attached and nothing injected, every T / A / C / H / B equal from the intro to the end: both styles
    /// (Kenpachi's, Task 6; Ichigo's, Task 7), the MCTS's searches and its full-sim jobs (Task 8; the first at step 826, MC-SETUP's NIL
    /// before it at step 812), the A line's job sections included.
    #[test]
    fn live_ki_s1_replays_whole() {
        let Some(path) = oracle_trace("cvc-ki-s1") else { return };
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        // (--inject-plan reads one step record ahead each step: the order of the records must not change)
        for flags in ["--live", "--live --inject-plan", "--live --snap 40"] {
            let o = parse_args(&args(&format!("{path} {flags}"))).unwrap();
            let r = run_opts(&o, data);
            assert_eq!(report(&o, &r).0[0], "replay OK 21368 ticks", "{flags}");
        }
    }

    /// The two vs traces (a human P1 injected, the CPU live): vs-cpu (a NORMAL Kenpachi, VIEW-STEP for the human's stick, the
    /// played cinematics' draw-mode moves) and vs-learn (debug 2504 twice: FQ-ATTACH!, FQ-NOTE's records, FQ-MATCH-END's TD update and
    /// save, the second match's load from the page, all in the A lines) replay whole; vs-learn's page at the end holds what its R lines
    /// say the recorder's page-set wrote (the last write of each key). No vs trace queues an MCTS job (every A job section empty), so
    /// the stand-in brain and the device inside a rollout are host-tested (`tests/mcts.rs` `vs_device_writes_in_rollouts`).
    #[test]
    fn vs_traces_replay_whole() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        for (name, ticks) in [("vs-cpu", 12835), ("vs-learn", 22413)] {
            let Some(path) = oracle_trace(name) else { return };
            let o = parse_args(&args(&format!("{path} --live --inject-side 0"))).unwrap();
            let r = run_opts(&o, data);
            assert_eq!(report(&o, &r).0[0], format!("replay OK {ticks} ticks"), "{name}");
            let mut want = std::collections::BTreeMap::new();
            for l in std::fs::read_to_string(&path).unwrap().lines() {
                if let Some(kv) = l.strip_prefix("R page-set ") {
                    let (k, v) = kv.split_once(' ').unwrap();
                    want.insert(k.parse::<i64>().unwrap(), v.parse::<i64>().unwrap());
                }
            }
            assert_eq!(r.page, want, "{name}");
            if name == "vs-learn" {
                assert_eq!(r.page.get(&71000), Some(&627));
            }
        }
    }

    /// A CPU rollout cut short by an `unported!` path (`Search.cut`, MC-FULL-STEP's after the last step) fails the run at the next
    /// step's end, as UNPORTED naming it (never OK: its value was wrong).
    #[test]
    fn cut_rollout_fails_the_run() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let mut m = Match::new(data);
        let s = &mut Search::new();
        s.cut = Some(("hs-min-reach", 812));
        let mut rp = bare_replayer(true);
        rp.step_end(&mut m, s);
        assert!(matches!(&rp.out, Some(Outcome::Unported(x)) if x == "hs-min-reach in a rollout from tick 812 (step 0)"));
    }

    /// `--live cvc-kk-s1`: both Kenpachi CPUs think for the whole match (the strategies, their event arm and :KEEP-STATE swaps, the
    /// KH styles over the core CPU), every T / A / C / H / B equal to the key (Task 6).
    #[test]
    fn live_kk_s1_replays_whole() {
        let Some(path) = oracle_trace("cvc-kk-s1") else { return };
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        for flags in ["--live", "--live --inject-plan"] {
            let o = parse_args(&args(&format!("{path} {flags}"))).unwrap();
            let r = run_opts(&o, data);
            assert_eq!(report(&o, &r).0[0], "replay OK 18133 ticks", "{flags}");
        }
    }

    /// A live Replayer reading nothing (the C split's test).
    fn bare_replayer(live: bool) -> Replayer<std::iter::Empty<Result<Item, String>>> {
        Replayer {
            it: std::iter::empty(),
            inj: Injector::new(),
            fields: vec![],
            a_fields: vec![],
            mask: vec![],
            cur: None,
            steps: 0,
            items: 0,
            max: None,
            kind: Kind::Cmds,
            out: None,
            snap: None,
            snaps: 0,
            snaps_unported: 0,
            snap_slot: None,
            live,
            resync: false,
            inject_side: None,
            inject_plan: false,
            t_done: false,
            pre: None,
            c_got: vec![],
            seat: Entity::NIL,
            ahead: Default::default(),
            mismatches: vec![],
            n_mismatch: 0,
        }
    }

    /// Ruling 1 (the recorder's C split): live, the CPUs' lines are those after a brain's vpad read (REC-READER: the brains' vpads
    /// only); a line the frame logged before it (a debug command, GATE-UPDATE) stays a `[` line, and a human side's read (a vs trace's
    /// device) marks nothing.
    #[test]
    fn c_split_starts_at_the_cpu_read() {
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        duel_sim::gate::start_cvc(&mut m, &mut Search::new(), 1, Some([duel_sim::components::Character::Kenpachi, duel_sim::components::Character::Ichigo]));
        let s = &mut Search::new();
        let mut rp = bare_replayer(true);
        m.log = vec!["[     1] a frame line".into()];
        rp.read(&mut m, 0);
        m.log.push("[     1] P1 cpu line".into());
        rp.after_brain(&mut m, s);
        assert_eq!((rp.c_got.as_slice(), m.log.as_slice()), (&["[     1] P1 cpu line".to_string()][..], &["[     1] a frame line".to_string()][..]));
        let mut rp = bare_replayer(true);
        m.fighter.get_mut(m.p1).unwrap().brain = None; // (P1 a human, as in a vs trace)
        m.log = vec!["[     2] a frame line".into()];
        rp.read(&mut m, 0);
        m.log.push("[     2] P1 human line".into());
        rp.read(&mut m, 1);
        m.log.push("[     2] P2 cpu line".into());
        rp.after_brain(&mut m, s);
        assert_eq!(rp.c_got, ["[     2] P2 cpu line"]);
    }

    /// The CPU's first battle step against the key: each live gate trace (cmds) run to its first battle step (step 301), where each
    /// side's CORE-BRAIN-STEP perceives, judges its Q selector (STRAT-SWITCH-STEP) and runs its arm's style (Tasks 6-7: every K / I style
    /// runs, so every trace steps whole; a stop would still run P2's step on the stopped match). Every brain slot of both sides (the
    /// perception, the judgement, the style's struct and presses) equals the recorded A fields of that step, and each judgement's cues
    /// equal the native judgement dump's bit for bit (tests/fixtures/strat-judgements.txt).
    #[test]
    fn live_first_step_matches_the_key() {
        use duel_sim::cpu::{glue, perceive};
        let data: &'static duel_data::Data = Box::leak(Box::new(duel_data::Data::embedded()));
        let dump = std::fs::read_to_string(concat!(env!("CARGO_MANIFEST_DIR"), "/../duel-sim/tests/fixtures/strat-judgements.txt")).unwrap();
        let mut names: Vec<String> = ["kk", "ki", "ik", "ii"].iter().flat_map(|p| (1..=3).map(move |k| format!("cvc-{p}-s{k}"))).collect();
        names.extend(["cvctag-ii", "cvctag-ik", "cvctag-kk"].map(String::from));
        let mut checked = 0;
        for name in names {
            let Some(path) = oracle_trace(&name) else { return };
            let mut rd = trace::open(&path).unwrap();
            let (start, _) = rd.start().unwrap();
            let mut want = rd.by_ref().filter_map(|i| match i {
                Ok(Item::Step { a, .. }) => Some(a.expect("an A line")),
                _ => None,
            });
            let want = want.nth(300).expect("a 301st step");
            let mut m = Match::new(data);
            flow::go_title(&mut m);
            m.cmds.extend(start[1..].iter().map(|c| c.parse::<i64>().unwrap()));
            let s = &mut Search::new();
            // (the match right after the first battle step's BRAIN-SYSTEM, when no style stopped it: the run stops after that step)
            struct Tick1(Option<Box<Match>>);
            impl PilotInput for Tick1 {
                fn read(&mut self, _m: &mut Match, _side: usize) {}
                fn step_end(&mut self, _m: &mut Match, _s: &mut Search) {}
                fn rollout_read(&mut self, _m: &mut Match, _side: usize) {}
                fn after_brain(&mut self, m: &mut Match, _s: &mut Search) {
                    if m.match_tick == 1 && m.unported.is_none() {
                        self.0 = Some(Box::new(m.clone()));
                        m.unported = Some("tick 1");
                    }
                }
            }
            let mut t1 = Tick1(None);
            for _ in 0..1000 {
                if m.unported.is_some() {
                    break;
                }
                flow::frame_headless(&mut m, s, &mut t1, &mut duel_sim::look::NoLook);
            }
            if let Some(b) = t1.0 {
                m = *b;
                m.unported = Some("tick 1");
            }
            assert_eq!(m.match_tick, 1, "{name}");
            // (a side whose style is not ported would stop at it: none since Task 7)
            if m.unported != Some("tick 1") {
                assert!(m.unported.is_some_and(|u| u.starts_with("style ")), "{name}: {:?}", m.unported);
                m.unported = None;
                let p2 = m.p2;
                if m.fighter.get(p2).unwrap().brain.as_ref().unwrap().sw_t < 0 {
                    duel_sim::cpu::core_ai::core_brain_step(&mut m, s, &mut duel_sim::flow::NoInput, p2); // (P1 stopped: P2's step, to its style)
                }
            }
            let got = duel_sim::cpu::a_line(&m, s);
            let (w, g): (Vec<&str>, Vec<&str>) = (want.split(' ').collect(), got.strip_prefix("A ").unwrap().split(' ').collect());
            for (p, e) in [("p1", m.p1), ("p2", m.p2)] {
                for f in ["ring", "head", "fresh", "jkey", "jstarts", "strat", "sw-sub", "sw-t", "sw-n", "sw-won", "sw-fn", "sw-keep", "tw", "tw-off",
                          "ev-t", "ev-on", "ev-n", "ev-steps"] {
                    let i = rd.a_fields.iter().position(|n| *n == format!("{p}.brain-{f}")).unwrap();
                    assert_eq!(g[i], w[i], "{name} {p}.brain-{f}");
                }
                // (both steps ran whole on the real sim stream: every brain slot, the style's output too)
                for (i, n) in rd.a_fields.iter().enumerate().filter(|(_, n)| n.starts_with(&format!("{p}.brain-"))) {
                    assert_eq!(g[i], w[i], "{name} {n}");
                }
                // (the judgement's cues, rebuilt on the stopped match: the first judgement's :prev reads no previous arm)
                let b = m.fighter.get(e).unwrap().brain.as_ref().unwrap();
                let snap = perceive::brain_snap_ago(b, b.delay).unwrap();
                let d = perceive::snap_dist(&m, &snap, e);
                let feats = glue::judge_feats(&m, e, &snap, d, b.strat.unwrap(), None);
                let side = if p == "p1" { 0 } else { 1 };
                let line = dump.lines().find(|l| l.starts_with(&format!("{name} J {side} 1 "))).expect("a tick-1 judgement in the dump");
                let cues: Vec<String> = feats.as_slice().iter().map(|(k, v)| format!("{k}={}", lisp_num(*v))).collect();
                let dumped: Vec<&str> = line.split(" | ").next().unwrap().split(' ').skip(6).collect();
                assert_eq!(cues, dumped, "{name} {p} cues");
            }
            checked += 1;
        }
        assert_eq!(checked, 15);
    }

    /// A cue as the dump's `~S` prints it: an integer, or a single-float's shortest form (`3.3333333`, `0.0`, `1.0e-5`).
    fn lisp_num(v: duel_sim::cl::Num) -> String {
        match v {
            duel_sim::cl::Num::I(n) => n.to_string(),
            duel_sim::cl::Num::F(x) => duel_sim::cl::fmt_f32(x),
        }
    }

    /// `--inject-plan`'s copy rule: a side at 1 takes the next record's plan when it left 1 (done: 2, popped: 0); 1 -> 1 and 2 -> 0
    /// are left alone.
    #[test]
    fn plan_copy_follows_mc_full_step() {
        let mut p = [1, 3, 7, 0, 0, 1, 4, 2, 0, 0];
        plan_copy(&mut p, &[2, 7, 3, 412, -90, 0, 4, 2, 0, 0]);
        assert_eq!(p, [2, 7, 3, 412, -90, 0, 4, 2, 0, 0]); // (1 -> 2: scored; 1 -> 0: popped)
        let mut p = [1, 3, 7, 0, 0, 2, 4, 2, 100, 50];
        plan_copy(&mut p, &[1, 5, 6, 0, 0, 0, 4, 2, 100, 50]);
        assert_eq!(p, [1, 3, 7, 0, 0, 2, 4, 2, 100, 50]); // (1 -> 1: the brain's own job; 2 -> 0: the brain applies it)
        assert_eq!(a_head("0 NIL 1 | 0 1 2 | 1 2"), "0 NIL 1");
        let mut m = Match::new(Box::leak(Box::new(duel_data::Data::embedded())));
        write_plan(&mut m, "1 2 3 4 5 6 7 8 9 10 11 12 :NORMAL").unwrap();
        assert_eq!((m.mc_plan, m.mc_next), ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [11, 12]));
    }

    #[test]
    fn mask_prefixes_and_keeps() {
        let mask: Vec<String> = ["gauges-", "!gauges-fs", "ics-"].iter().map(|s| s.to_string()).collect();
        assert!(masked(&mask, "p1.gauges-gg") && masked(&mask, "p2.ics-hist"));
        assert!(!masked(&mask, "p1.gauges-fs") && !masked(&mask, "p1.gauges-fs-idle") && !masked(&mask, "p1.fighter-sf"));
        assert!(!masked(&[], "p1.gauges-gg"));
    }
}
