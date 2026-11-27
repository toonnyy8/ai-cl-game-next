//! The CPU (M2). port: duel/lisp/components.lisp BRAIN, cpu-perceive.lisp BRAIN-SYSTEM; the oracle's CPU-state line A
//! (tools/port/oracle/trace.lisp TR-A-LINE). The snapshot boundary is Lisp's (docs/bevy/M2_NOTES.md §1): what SIM-SNAPSHOT reaches
//! is in `Match` (the brain on its fighter, `Match.mc_plan` / `mc_next`); every other runtime CPU state is in `Search`, which a
//! rollout's restore never touches.
use crate::components::{Difficulty, State, Sym};
use crate::hashline::Enc;
use crate::state::{Match, Mode};
use duel_data::Data;
use std::collections::BTreeMap;
pub use strategy::Strat;
use std::fmt::Write;

pub mod core_ai;
pub mod fq;
pub mod fuzzy;
pub mod glue;
pub mod ichigo_ki;
pub mod ken_ki;
pub mod mcts;
pub mod mcts_lite;
pub mod perceive;
pub mod strategy;
pub mod style;
pub mod xch_ai;

/// BRAIN-SW-WON: a judgement count per entry of the composite / Q selector, `(max 8 n)` slots.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Won {
    pub n: u8,
    pub v: [i64; strategy::MAX_ARMS],
}

impl Won {
    pub fn new(n: usize) -> Won {
        assert!(n <= strategy::MAX_ARMS, "a table with {n} entries");
        Won { n: 8.max(n) as u8, v: [0; strategy::MAX_ARMS] }
    }
}

impl Enc for Won {
    fn enc(&self, d: &Data, s: &mut String) {
        enc_vec(&self.v[..self.n as usize], d, s)
    }
}

/// BRAIN-SW-KEEP: the styles' states a :KEEP-STATE Q selector keeps, `((fn . style) ...)` newest first. Reserved at the brain's
/// making (a table has at most `MAX_ARMS` style functions), so a switch allocates nothing.
///
/// Lisp's entries hold the struct objects: a switch back to a style sets BRAIN-STYLE to its kept struct, the same object, so the
/// entry and BRAIN-STYLE stay EQ until the style makes a fresh struct (or the next switch). `Brain.style_live` marks that: the
/// entry of `sw_fn` then reads `Brain.style` (printed so), and `Brain::style_replaced` writes the old struct back into it.
#[derive(Clone, Debug, PartialEq)]
pub struct SwKeep(pub Vec<(style::StyleId, Option<style::StyleState>)>);

impl SwKeep {
    /// TR-B-ENC of the list, entry LIVE (the style function whose entry is EQ to BRAIN-STYLE) printed as STYLE.
    fn enc(&self, d: &Data, s: &mut String, live: Option<(style::StyleId, Option<style::StyleState>)>) {
        if self.0.is_empty() {
            return s.push_str("NIL");
        }
        s.push('(');
        for (i, (f, st)) in self.0.iter().enumerate() {
            if i > 0 {
                s.push(',');
            }
            s.push('(');
            f.enc(d, s);
            let st = match live {
                Some((lf, ls)) if lf == *f => ls,
                _ => *st,
            };
            if let Some(st) = st {
                s.push_str(",.");
                st.enc(d, s);
            }
            s.push(')');
        }
        s.push(')');
    }
}

/// port: (DEFCOMPONENT BRAIN): every slot, in slot order. Fixnums i64, single-floats f32, T / NIL flags bool, a keyword-or-NIL
/// slot `Option<Sym>` (`press` keeps :NONE apart from NIL: MC-FULL-REQUEST tests `(eq press :none)`).
#[derive(Debug, PartialEq)]
pub struct Brain {
    pub difficulty: Difficulty,
    pub delay: i64,
    pub ring: [Option<perceive::Snap>; 32],
    pub head: i64,
    pub fresh: bool,
    pub strafe: f32,
    pub strafe_t: i64,
    pub press: Option<Sym>,
    pub press_mod: bool,
    pub press_left: i64,
    pub decide_t: i64,
    pub roll_key: i64,
    pub guard_roll: f32,
    pub hoho_roll: f32,
    pub was: State,
    pub burst_t: i64,
    pub burst_rolled: bool,
    pub dash: f32,
    pub dash_to: f32,
    pub act: Option<Sym>,
    pub why: Option<Sym>,
    pub habit: Option<Sym>,
    pub jkey: i64,
    pub jstarts: Vec<i64>,
    pub own_key: i64,
    pub r_turn: f32,
    pub r_cont: f32,
    pub r_kikon: f32,
    pub decided: i64,
    pub xkey: i64,
    pub xmove: i64,
    pub xown: bool,
    pub xpick: Option<Sym>,
    pub xcarry: Option<Sym>,
    pub xdone: bool,
    pub clash_key: i64,
    pub fin_t: i64,
    pub style: Option<style::StyleState>, // a style's struct (its own; the event arm's while STRAT-EVENT-CALL runs it)
    pub strat: Option<Strat>,
    pub now: Option<strategy::Now>, // (strategy . cues) while the core CPU steps; NIL at a step's end
    pub sw_sub: Option<Strat>,
    pub sw_t: i64,
    pub sw_n: i64,
    pub sw_won: Option<Won>,
    pub sw_fn: Option<style::StyleId>,
    pub sw_keep: SwKeep,
    pub tw: i64,
    pub tw_off: bool,
    pub ev_t: i64,
    pub ev_on: Option<Strat>,
    pub ev_style: Option<style::StyleState>,
    pub ev_n: i64,
    pub ev_steps: i64,
    pub fql: Option<fq::Fql>, // the online learner's record (FQ-ATTACH!; NIL = not learning)
    pub st_next: i64,
    pub st_free: i64,
    pub masher: bool,
    pub m_left: i64,
    pub m_stick: Sym,
    pub off: bool,
    /// Not a slot: `style` is EQ to `sw_keep`'s entry of `sw_fn` (see `SwKeep`).
    pub style_live: bool,
}

/// A copy that keeps the two Vecs' reserves (JSTARTS' `*ai-mash-window*` + 2, SW-KEEP's `MAX_ARMS`), and `clone_from` (a rollout's
/// restore) that reuses them: no allocation per snapshot (every other slot is `Copy`, which the `..*src` updates check). FQL (a
/// learning brain's record: VS CPU against a human only) is cloned plainly: its new records allocate in each copy.
impl Clone for Brain {
    fn clone(&self) -> Brain {
        let mut jstarts = Vec::with_capacity(self.jstarts.capacity());
        jstarts.extend_from_slice(&self.jstarts);
        let mut keep = Vec::with_capacity(self.sw_keep.0.capacity());
        keep.extend_from_slice(&self.sw_keep.0);
        Brain { jstarts, sw_keep: SwKeep(keep), fql: self.fql.clone(), ..*self }
    }
    fn clone_from(&mut self, src: &Brain) {
        let mut jstarts = std::mem::take(&mut self.jstarts);
        jstarts.clone_from(&src.jstarts);
        let mut keep = std::mem::take(&mut self.sw_keep.0);
        keep.clone_from(&src.sw_keep.0);
        let mut fql = self.fql.take();
        fql.clone_from(&src.fql);
        *self = Brain { jstarts, sw_keep: SwKeep(keep), fql, ..*src };
    }
}

/// BRAIN's slot count (a fighter without a brain prints this many `:ABSENT`).
pub const BRAIN_SLOTS: usize = 60;
/// The A line's per-side fields: the brain's, then the pilot's (10 vpad slots but READER, cam-relative).
pub const A_SIDE: usize = BRAIN_SLOTS + 11;
/// `brain-strat`'s index among a side's A fields.
pub const A_STRAT: usize = 38;

impl Brain {
    /// port: (MAKE-BRAIN :difficulty DIFFICULTY :delay DELAY), the slots' defaults.
    pub fn new(difficulty: Difficulty, delay: i64) -> Brain {
        Brain::with_vecs(difficulty, delay, Vec::new(), Vec::with_capacity(strategy::MAX_ARMS))
    }

    /// MAKE-BRAIN into this one (a rollout's stand-in, reused): JSTARTS and SW-KEEP emptied, their reserves kept.
    pub fn reset(&mut self, difficulty: Difficulty, delay: i64) {
        let (mut jstarts, mut keep) = (std::mem::take(&mut self.jstarts), std::mem::take(&mut self.sw_keep.0));
        jstarts.clear();
        keep.clear();
        *self = Brain::with_vecs(difficulty, delay, jstarts, keep);
    }

    fn with_vecs(difficulty: Difficulty, delay: i64, jstarts: Vec<i64>, keep: Vec<(style::StyleId, Option<style::StyleState>)>) -> Brain {
        Brain {
            difficulty,
            delay,
            ring: [None; 32],
            head: 0,
            fresh: true,
            strafe: 1.0,
            strafe_t: 0,
            press: None,
            press_mod: false,
            press_left: 0,
            decide_t: 0,
            roll_key: -1,
            guard_roll: 1.0,
            hoho_roll: 1.0,
            was: State::Idle,
            burst_t: 0,
            burst_rolled: false,
            dash: 0.0,
            dash_to: 0.0,
            act: None,
            why: None,
            habit: None,
            jkey: -1,
            jstarts,
            own_key: -1,
            r_turn: 1.0,
            r_cont: 1.0,
            r_kikon: 1.0,
            decided: -1,
            xkey: -1,
            xmove: -1,
            xown: false,
            xpick: None,
            xcarry: None,
            xdone: false,
            clash_key: -1,
            fin_t: 0,
            style: None,
            strat: None,
            now: None,
            sw_sub: None,
            sw_t: -1,
            sw_n: 0,
            sw_won: None,
            sw_fn: None,
            sw_keep: SwKeep(keep),
            tw: -1,
            tw_off: false,
            ev_t: -1,
            ev_on: None,
            ev_style: None,
            ev_n: 0,
            ev_steps: 0,
            fql: None,
            st_next: 0,
            st_free: 0,
            masher: false,
            m_left: 0,
            m_stick: Sym(":NEUTRAL"),
            off: false,
            style_live: false,
        }
    }

    /// A style function puts a fresh struct in BRAIN-STYLE in place of OLD (taken out): an entry of `sw_keep` that was EQ to OLD
    /// keeps OLD (the Lisp's kept object), and is no longer EQ to the new one.
    pub fn style_replaced(&mut self, old: Option<style::StyleState>) {
        if std::mem::take(&mut self.style_live)
            && let Some(fid) = self.sw_fn
            && let Some(c) = self.sw_keep.0.iter_mut().find(|c| c.0 == fid)
        {
            c.1 = old;
        }
    }

    /// The brain's A fields (TR-A-ENC of each slot), each preceded by a space; BRAIN-STRAT with TR-A-STRAT's `/fq(...)` when it is a
    /// player's copy (one of CELLS'), BRAIN-FQL as TR-A-FQL (UNIT: `*fq-unit*`, its checksum's).
    fn enc(&self, d: &Data, s: &mut String, cells: &[fq::FqCell], unit: i64) {
        macro_rules! f {
            ($($x:expr),* $(,)?) => {$( s.push(' '); $x.enc(d, s); )*};
        }
        f!(self.difficulty, self.delay, self.ring, self.head, self.fresh, self.strafe, self.strafe_t, self.press, self.press_mod);
        f!(self.press_left, self.decide_t, self.roll_key, self.guard_roll, self.hoho_roll, self.was, self.burst_t, self.burst_rolled);
        f!(self.dash, self.dash_to, self.act, self.why, self.habit, self.jkey, self.jstarts, self.own_key, self.r_turn, self.r_cont);
        f!(self.r_kikon, self.decided, self.xkey, self.xmove, self.xown, self.xpick, self.xcarry, self.xdone, self.clash_key, self.fin_t);
        f!(self.style, self.strat);
        if let Some(st) = self.strat {
            fq::enc_copy(st, cells, unit, s);
        }
        f!(self.now, self.sw_sub, self.sw_t, self.sw_n, self.sw_won, self.sw_fn);
        s.push(' ');
        self.sw_keep.enc(d, s, self.sw_fn.filter(|_| self.style_live).map(|f| (f, self.style)));
        f!(self.tw, self.tw_off);
        f!(self.ev_t, self.ev_on, self.ev_style, self.ev_n, self.ev_steps);
        s.push(' ');
        match &self.fql {
            Some(l) => l.enc(d, unit, s),
            None => s.push_str("NIL"),
        }
        f!(self.st_next, self.st_free, self.masher, self.m_left);
        f!(self.m_stick, self.off);
    }
}

/// A job's snapshot (SIM-SNAPSHOT's SIMSNAP): a preallocated `Match` from `Search.pool`, written with `clone_from` (no allocation
/// while its capacities hold) and given back to the pool when the job ends.
pub struct Slot(pub Box<Match>);

impl std::fmt::Debug for Slot {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "#<snapshot tick {}>", self.0.match_tick)
    }
}

/// One `*mc-jobs*` decision (cpu-mcts.lisp MC-FULL-REQUEST's vector): slot 0 the entity, 1-4 side a1 a2 dif, 5 the snapshot, 6 the
/// rollouts done, 8 / 9 their values, 10 the sim stream's state at the snapshot (slot 7 is never written).
#[derive(Debug)]
pub struct McJob {
    pub e: crate::ecs::Entity,
    pub side: i64,
    pub a1: i64,
    pub a2: i64,
    pub dif: Difficulty,
    pub snap: Option<Slot>,
    pub n: i64,
    pub v1: f32,
    pub v2: f32,
    pub rng: u32,
}

/// One `*strat-jobs*` selection (strategy-glue.lisp STJOB): E's side, difficulty, his arms and the opponent's, the prior and both
/// PUCTs' statistics, rollouts done, the snapshot and the sim stream's state at it (STJOB-SNAP, -RNG).
#[derive(Debug)]
pub struct StratJob {
    pub e: crate::ecs::Entity,
    pub side: i64,
    pub dif: Difficulty,
    pub mine: Vec<Strat>,
    pub his: Vec<Strat>,
    pub prior: Vec<f32>,
    pub sums: Vec<f32>,
    pub ns: Vec<f32>,
    pub hsums: Vec<f32>,
    pub hns: Vec<f32>,
    pub hprior: Vec<f32>,
    pub n: i64,
    pub snap: Option<Slot>,
    pub rng: u32,
}

/// The CPU state Lisp keeps outside its snapshot roots (M2_NOTES §1): a rollout's restore never touches it, so a job's scores
/// survive it. Never cloned with a `Match`.
#[derive(Debug)]
pub struct Search {
    /// `*mc-jobs*`, oldest first.
    pub mc_jobs: Vec<McJob>,
    /// `*strat-jobs*`, oldest first.
    pub strat_jobs: Vec<StratJob>,
    /// `*mc-full-stats*`: decisions, rollouts, internal time in rollouts, the worst step's.
    pub mc_stats: [i64; 4],
    /// `*strat-stats*`: the same for the strategy layer.
    pub strat_stats: [i64; 4],
    /// `*strat-picks*`: per side a slot per library entry (sized by MC-FULL-RESET).
    pub strat_picks: Vec<i64>,
    /// `*fq-tables*`: the players' copies, newest first (FQ-TABLE pushes).
    pub fq_tables: Vec<fq::FqCell>,
    /// Not Lisp's: the copies' leaked structures, one per (me, vs, library entry) ever made (`fq::fq_table`; a cell made again after a
    /// reset reuses its own, a learned match adds none: ruling R27).
    pub fq_pool: Vec<fq::FqShape>,
    /// fq-online.lisp `*learn-debug-off*`: a debug command ran, so no CPU learns (DEBUG-COMMAND sets it; debug 2504 clears it).
    pub learn_debug_off: bool,
    /// `*fq-learn-force*`: a tool's T (every Q-selector CPU learns, whoever its opponent); false in the game.
    pub fq_learn_force: bool,
    /// `(setting :learn)`: the LEARNING CPU setting, 0 = on (the default; the settings page is M3's).
    pub learn: i64,
    /// The page store (PAGE-GET / PAGE-SET; M3 persists it).
    pub page: BTreeMap<i64, i64>,
    /// GET-INTERNAL-REAL-TIME for the stats lines' milliseconds (never compared): the caller's clock, else always 0.
    pub clock: fn() -> u64,
    /// Not Lisp's: spare snapshot slots (a job takes one, its end gives it back; `warm` fills it at a match's start).
    pub pool: Vec<Slot>,
    /// Not Lisp's: the match a rollout plays on (a job's snapshot restored into it; the live match is never touched).
    pub scratch: Option<Slot>,
    /// Not Lisp's: the last rollout's stand-in brain for a brainless opponent, made again (`Brain::reset`) by the next rollout that
    /// needs one, so a vs rollout allocates no brain.
    pub spare_brain: Option<Box<Brain>>,
    /// Rollouts cut short by an `unported!` path (`m.unported` of the rollout's match): their value is wrong, so the replay fails.
    pub cut_rollouts: u64,
    /// The first such path and the live tick of its rollout.
    pub cut: Option<(&'static str, i64)>,
}

/// Snapshot slots made at a match's start (`Search::warm`): the jobs alive at once (one per side, a second while a job finishes).
pub const POOL: usize = 4;

impl Search {
    pub fn new() -> Search {
        Search {
            mc_jobs: Vec::new(),
            strat_jobs: Vec::new(),
            mc_stats: [0; 4],
            strat_stats: [0; 4],
            strat_picks: Vec::new(),
            fq_tables: Vec::new(),
            fq_pool: Vec::new(),
            learn_debug_off: false,
            fq_learn_force: false,
            learn: 0,
            page: BTreeMap::new(),
            clock: || 0,
            pool: Vec::new(),
            scratch: None,
            spare_brain: None,
            cut_rollouts: 0,
            cut: None,
        }
    }

    /// Preallocate the snapshot slots and the rollout match from M (outside the battle: the battle steps then allocate nothing).
    pub fn warm(&mut self, m: &Match) {
        self.mc_jobs.reserve(POOL);
        self.pool.reserve(2 * POOL);
        while self.pool.len() < POOL {
            self.pool.push(Slot(Box::new(m.clone())));
        }
        if self.scratch.is_none() {
            self.scratch = Some(Slot(Box::new(m.clone())));
        }
    }

    /// A slot holding M now (from the pool, else a new one).
    pub fn snapshot(&mut self, m: &Match) -> Slot {
        match self.pool.pop() {
            Some(mut s) => {
                (*s.0).clone_from(m);
                s
            }
            None => Slot(Box::new(m.clone())),
        }
    }

    /// A job's slot back to the pool.
    pub fn give_back(&mut self, s: Option<Slot>) {
        if let Some(s) = s {
            self.pool.push(s);
        }
    }

    /// The oldest action job ends (POP).
    pub fn pop_mc_job(&mut self) {
        let j = self.mc_jobs.remove(0);
        self.give_back(j.snap);
    }

    /// `(setf *mc-jobs* nil)` / `(setf *strat-jobs* nil)`: their slots back to the pool.
    pub fn drop_mc_jobs(&mut self) {
        while !self.mc_jobs.is_empty() {
            self.pop_mc_job();
        }
    }
    pub fn drop_strat_jobs(&mut self) {
        while !self.strat_jobs.is_empty() {
            let j = self.strat_jobs.remove(0);
            self.give_back(j.snap);
        }
    }
}

impl Default for Search {
    fn default() -> Self {
        Search::new()
    }
}

/// port: BRAIN-SYSTEM — every CPU fighter decides this step, before FIGHTER-SYSTEM reads the vpads (CORE-BRAIN-STEP: every playing
/// kit has a :core). INPUT is the vpads' reader: a CPU's fires in CORE-BRAIN-STEP's VPAD-BEGIN-STEP! (the recorder's C split).
pub fn brain_system(m: &mut Match, s: &mut Search, input: &mut dyn crate::flow::PilotInput) {
    m.do_entities(|m, e| m.fighter.get(e).is_some_and(|f| f.has_brain()), |m, e| {
        if m.unported.is_none() {
            core_ai::core_brain_step(m, s, input, e);
        }
    });
}

/// port: START-MATCH's CPU part after SPAWN-PAIR: each CPU's strategy from STRAT-LOOKUP (VS CPU / CPU vs CPU), FQ-ATTACH!,
/// MASHER-APPLY!.
pub fn start_match_cpu(m: &mut Match, s: &mut Search) {
    if matches!(m.mode, Mode::VsCpu | Mode::CpuCpu) {
        for (e, o) in [(m.p1, m.p2), (m.p2, m.p1)] {
            let (Some(me), Some(vs)) = (m.fighter.get(e).and_then(|f| f.character), m.fighter.get(o).and_then(|f| f.character)) else {
                continue;
            };
            let d = m.data;
            let dif = m.fighter.get(e).and_then(|f| f.brain.as_ref()).map(|b| b.difficulty);
            let st = dif.and_then(|dif| strategy::strat_lookup(d, &m.knobs, me, vs, dif));
            if let Some(b) = m.fighter.get_mut(e).unwrap().brain.as_mut() {
                b.strat = st;
            }
        }
        for e in [m.p1, m.p2] {
            fq::fq_attach(m, s, e); // (a Q selector facing a human plays the player's copy)
        }
    }
    // port: MASHER-APPLY! with no seat (*masher-seats*: debug 81030+, M5)
    for e in [m.p1, m.p2] {
        if let Some(b) = m.fighter.get_mut(e).and_then(|f| f.brain.as_mut()) {
            (b.masher, b.m_left, b.press_left) = (false, 0, 0);
        }
    }
}

/// A Lisp vector `[a,b]` of a slice.
pub(crate) fn enc_vec<T: Enc>(v: &[T], d: &Data, s: &mut String) {
    s.push('[');
    for (i, x) in v.iter().enumerate() {
        if i > 0 {
            s.push(',');
        }
        x.enc(d, s);
    }
    s.push(']');
}

/// port: TR-A-LINE — the CPU state now, as the trace's A line (with its "A" word; full, never "A =").
pub fn a_line(m: &Match, s: &Search) -> String {
    let d = m.data;
    let mut o = String::with_capacity(2048);
    o.push('A');
    for x in m.mc_plan.iter().chain(&m.mc_next) {
        write!(o, " {x}").unwrap();
    }
    for e in [m.p1, m.p2] {
        match m.fighter.get(e).and_then(|f| f.brain.as_ref()) {
            Some(b) => b.enc(d, &mut o, &s.fq_tables, m.knobs.fq_unit),
            None => (0..BRAIN_SLOTS).for_each(|_| o.push_str(" :ABSENT")),
        }
        let p = m.pilot.get(e).expect("pilot");
        let v = &p.vpad;
        o.push_str(" [");
        for (i, a) in v.actions.iter().enumerate() {
            if i > 0 {
                o.push(',');
            }
            o.push(':');
            o.push_str(&a.to_uppercase());
        }
        o.push(']');
        write!(o, " {} {} {} ", v.mod_index.map_or(-1, |i| i as i64), v.buffer, v.tick).unwrap();
        for (i, x) in [&v.downs, &v.since, &v.press, &v.modded].into_iter().enumerate() {
            if i > 0 {
                o.push(' ');
            }
            enc_vec(x, d, &mut o);
        }
        for x in [v.sx, v.sy] {
            o.push(' ');
            x.enc(d, &mut o);
        }
        o.push(' ');
        p.cam_relative.enc(d, &mut o);
    }
    o.push_str(" |");
    for j in &s.mc_jobs {
        o.push(' ');
        j.side.enc(d, &mut o);
        for x in [j.a1, j.a2] {
            write!(o, " {x}").unwrap();
        }
        o.push(' ');
        j.dif.enc(d, &mut o);
        write!(o, " {}", j.n).unwrap();
        for x in [j.v1, j.v2] {
            o.push(' ');
            x.enc(d, &mut o);
        }
    }
    o.push_str(" |");
    for j in &s.strat_jobs {
        write!(o, " {} {}", j.side, j.n).unwrap();
        for x in [&j.sums, &j.ns, &j.hsums, &j.hns] {
            o.push(' ');
            enc_vec(x, d, &mut o);
        }
    }
    o
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::components::Character;

    #[test]
    fn brain_prints_its_slot_count() {
        let mut s = String::new();
        Brain::new(Difficulty::Normal, 14).enc(crate::hashline::tests::data(), &mut s, &[], 100000);
        assert_eq!(s.split(' ').skip(1).count(), BRAIN_SLOTS);
        assert!(s.starts_with(" :NORMAL 14 [NIL,"));
    }

    #[test]
    fn strat_lookup_reads_the_hard_row() {
        let d = crate::hashline::tests::data();
        let k = crate::knobs::Knobs::from(d).unwrap();
        let st = strategy::strat_lookup(d, &k, Character::Kenpachi, Character::Ichigo, Difficulty::Normal).unwrap();
        assert_eq!(st.id(), Some("t0-ki-kenpachi"));
        assert_eq!(strategy::strat_lookup(d, &k, Character::Yamamoto, Character::Ichigo, Difficulty::Hard), None);
    }
}
