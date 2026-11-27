//! port: duel/lisp/cpu-ki-ichigo.lisp, cpu-ki-ichigo-r2b2a1.lisp — Ichigo's matchup style CPUs: ICHIGO-KI-STYLE (against Kenpachi:
//! each neutral episode's mode from *IKS-MIX*, the whiff punish and confirm, the timed Hoho and its follow-up, pointer 2's Getsuga,
//! the shut-gauge lunge, KESSA's k-lunge, the steered strings, the Kikon rule, the meaty J1), and on it ICHIGO-KI-R2B2A1-STYLE (the
//! wake-up roll, the stale breaker, the far-lunge watch). A style runs on every step its CPU is free to press, before the generic CPU,
//! and says whether it decided this step. Its state is a struct in BRAIN-STYLE (IKST; IKW includes it). Every chance is rolled once
//! per event from the sim stream, in the Lisp's order; the opponent is read only through the perceived SNAP and distance.
//!
//! Not ported: cpu-ki-ichigo-r2b1a1.lisp (ICHIGO-KI-R2B1A1-STYLE, IR2): no `*cai-styles*` entry and no strategy's :FN names it, so
//! nothing reaches it. IKW-GAP-WATCH's gap-off arm (IKW-ALT: a fresh strategy plist swapped into BRAIN-NOW) is the arm it was made
//! from with `Now::gap_off` (never in a gate trace's play; reseeded `--snap` rollouts reach it).
use super::core_ai::{cai_class_of, cai_move_step, cai_neutral, cai_next_ok_p, cai_press, chance_roll, gauges_awakened_ok_p, mv_min_reach};
use super::glue::{strat_out, style_dif, style_knob, style_on};
use super::perceive::{ai_dash, ai_press, ai_strafe, ai_walk, snap_lead_seen, snap_live_p, snap_near_p, snap_punishable_p, snap_recovering_p, Snap};
use super::strategy::{Now, Strat};
use super::style::{take_style, StyleState};
use super::{Brain, Search};
use crate::cl::{expt2, floor_f32, fmt_fixed_f32, max_f32, min_f32, modulo, Num};
use crate::components::{Button, Character, Cls, Contact, Form, State, Sym};
use crate::core::{core_kikon_count, core_soul_break_count};
use crate::core_sim::core_next_as;
use crate::ecs::Entity;
use crate::fighter::{fighter, gauges_red_p, hoho_ready_p, kit_of, mv, pos_of, side_name};
use crate::hashline::Enc;
use crate::kit::{kit_command_move, kit_core_move, kit_sa_move, mv_name, mv_ns_next, Role};
use crate::knobs::{Knobs, KwNums, Plist};
use crate::rules::ai_hoho_spare_p;
use crate::state::Match;
use duel_data::tuning::{Knob, Value};
use duel_data::{Data, Kit, MoveClass};

const QUICK: Sym = Sym(":QUICK");
const STEP: Sym = Sym(":STEP");
const AWAKEN: Sym = Sym(":AWAKEN");
const HOHO: Sym = Sym(":HOHO");
// the rolls' results (ikst-punish / -awaken / -gap / -cross / -brk, ikw-roll)
const GO: Sym = Sym(":GO");
const NO: Sym = Sym(":NO");
const DONE: Sym = Sym(":DONE");
// IKST-PLAN's values (what her move is for)
const SHOT: Sym = Sym(":SHOT");
const LUNGE: Sym = Sym(":LUNGE");
const K_LUNGE: Sym = Sym(":K-LUNGE");
const G_SA: Sym = Sym(":G-SA");

// ---------------------------------------------------------------- the style's state (BRAIN-STYLE; a new match's brain starts NIL)

/// An episode's mode (*IKS-MIX*'s keys).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
    Generic,
    Space,
    Whiff,
    Ptr3,
    Kessa,
}

impl Mode {
    fn of(s: &str) -> Mode {
        // (no allocation: a new episode's pick is on the hot path)
        [Mode::Generic, Mode::Space, Mode::Whiff, Mode::Ptr3, Mode::Kessa]
            .into_iter()
            .find(|x| x.name().eq_ignore_ascii_case(s))
            .unwrap_or_else(|| panic!("no style mode {s}"))
    }
    /// `~(~a~)`: the keyword's name in lower case.
    pub fn name(self) -> &'static str {
        match self {
            Mode::Generic => "generic",
            Mode::Space => "space",
            Mode::Whiff => "whiff",
            Mode::Ptr3 => "ptr3",
            Mode::Kessa => "kessa",
        }
    }
}

impl Enc for Mode {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push(':');
        s.push_str(&self.name().to_ascii_uppercase());
    }
}

/// IKST-RETREAT: NIL (unmade), T (made, or done), :GO.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Retreat {
    Nil,
    T,
    Go,
}

impl Enc for Retreat {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str(match self {
            Retreat::Nil => "NIL",
            Retreat::T => "T",
            Retreat::Go => ":GO",
        });
    }
}

/// A *IKS-PUNISHERS* entry `(what first-hit-frame reach-m plan)` (IKST-PEND holds the entry itself).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Punisher {
    pub what: Sym,
    pub hit: i64,
    pub reach: f32,
    pub plan: Option<Sym>,
}

impl Enc for Punisher {
    fn enc(&self, d: &Data, s: &mut String) {
        s.push('(');
        for (i, x) in [&self.what as &dyn Enc, &self.hit, &self.reach, &self.plan].into_iter().enumerate() {
            if i > 0 {
                s.push(',');
            }
            x.enc(d, s);
        }
        s.push(')');
    }
}

/// A form's row of *IKS-PUNISHERS*.
#[derive(Debug, Clone, Default)]
pub struct Punishers(pub Vec<Punisher>);

impl Knob for Punishers {
    const KIND: &'static str = "a list of (what hit reach plan)";
    fn from_value(v: &Value) -> Option<Punishers> {
        let sym = |x: &Value| -> Option<Option<Sym>> {
            if x.is_null() {
                return Some(None);
            }
            Some(Some(match x.as_str()? {
                "j" => Sym(":J"),
                "ns1" => Sym(":NS1"),
                "ns2" => Sym(":NS2"),
                "ns3" => Sym(":NS3"),
                "lunge" => LUNGE,
                "k-lunge" => K_LUNGE,
                "g-sa" => G_SA,
                _ => return None,
            }))
        };
        let one = |p: &Value| match p.as_array()?.as_slice() {
            [w, h, r, pl] => {
                Some(Punisher { what: sym(w)??, hit: h.as_i64()?, reach: r.as_f64().filter(|_| r.is_f64())? as f32, plan: sym(pl)? })
            }
            _ => None,
        };
        v.as_array()?.iter().map(one).collect::<Option<Vec<_>>>().map(Punishers)
    }
}

/// port: (DEFSTRUCT IKST) — every slot in order.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Ikst {
    pub mode: Mode,
    pub ep_t: i64,
    pub last_st: Option<State>,
    /// A fixnum slot holding GAUGES-REISHI (a trial's float Reishi too).
    pub last_reishi: Num,
    pub dt: i64,
    pub retreat: Retreat,
    pub awaken: Option<Sym>,
    pub pkey: i64,
    pub punish: Option<Sym>,
    pub ckey: i64,
    pub pend: Option<Punisher>,
    pub pend_until: i64,
    pub rkey: i64,
    pub plan: Option<Sym>,
    pub skey: i64,
    /// The press count a steered string runs to (STYLE-KNOB of :iks-steer-to: an arm's float stays one).
    pub steer: Option<Num>,
    pub brk: Option<Sym>,
    pub hkey: i64,
    pub hoho: bool,
    pub hoho_t: i64,
    pub mode_mv: Mode,
    pub last_d: f32,
    pub down: bool,
    pub meaty: bool,
    pub gap: Option<Sym>,
    pub gap_t: i64,
    pub cross: Option<Sym>,
    pub his_hoho: i64,
}

impl Ikst {
    /// port: (MAKE-IKST).
    pub fn new() -> Ikst {
        Ikst {
            mode: Mode::Generic,
            ep_t: 0,
            last_st: None,
            last_reishi: Num::I(0),
            dt: 0,
            retreat: Retreat::Nil,
            awaken: None,
            pkey: -1,
            punish: None,
            ckey: -1,
            pend: None,
            pend_until: 0,
            rkey: -1,
            plan: None,
            skey: -1,
            steer: None,
            brk: None,
            hkey: -1,
            hoho: false,
            hoho_t: -1,
            mode_mv: Mode::Generic,
            last_d: 0.0,
            down: false,
            meaty: false,
            gap: None,
            gap_t: 0,
            cross: None,
            his_hoho: -999,
        }
    }
}

impl Default for Ikst {
    fn default() -> Self {
        Ikst::new()
    }
}

/// The IKST slots, comma separated (a struct that includes IKST prints them first).
impl Enc for Ikst {
    fn enc(&self, d: &Data, s: &mut String) {
        let v: [&dyn Enc; 28] = [
            &self.mode, &self.ep_t, &self.last_st, &self.last_reishi, &self.dt, &self.retreat, &self.awaken, &self.pkey, &self.punish,
            &self.ckey, &self.pend, &self.pend_until, &self.rkey, &self.plan, &self.skey, &self.steer, &self.brk, &self.hkey, &self.hoho,
            &self.hoho_t, &self.mode_mv, &self.last_d, &self.down, &self.meaty, &self.gap, &self.gap_t, &self.cross, &self.his_hoho,
        ];
        for (i, x) in v.into_iter().enumerate() {
            if i > 0 {
                s.push(',');
            }
            x.enc(d, s);
        }
    }
}

/// port: (DEFSTRUCT (IKW (:INCLUDE IKST))) — ICHIGO-KI-R2B2A1-STYLE's state. ALT is IKW-ALT, the gap-off arm, held as the arm it was
/// made from (`Now::gap_off` says how it reads); CELL the cons swapped into BRAIN-NOW, `(alt . cues)` (NIL: its fresh `(nil . nil)`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Ikw {
    pub k: Ikst,
    pub roll: Option<Sym>,
    pub lunge_t: i64,
    pub stepped: i64,
    pub alt: Option<Strat>,
    pub cell: Option<Now>,
    pub rsig: Num,
    pub ksig: i64,
    pub still_t: i64,
}

impl Ikw {
    /// port: (MAKE-IKW).
    pub fn new() -> Ikw {
        Ikw { k: Ikst::new(), roll: None, lunge_t: -999, stepped: 0, alt: None, cell: None, rsig: Num::I(-1), ksig: -1, still_t: 0 }
    }
}

impl Default for Ikw {
    fn default() -> Self {
        Ikw::new()
    }
}

impl Enc for Ikw {
    fn enc(&self, d: &Data, s: &mut String) {
        self.k.enc(d, s);
        for x in [&self.roll as &dyn Enc, &self.lunge_t, &self.stepped] {
            s.push(',');
            x.enc(d, s);
        }
        s.push(',');
        self.alt.enc(d, s);
        s.push(',');
        match &self.cell {
            Some(c) => c.enc(d, s),
            None => s.push_str("(NIL)"),
        }
        for x in [&self.rsig as &dyn Enc, &self.ksig, &self.still_t] {
            s.push(',');
            x.enc(d, s);
        }
    }
}

// ---------------------------------------------------------------- small readers

/// STYLE-ROLL of the style knob KEY over its plist.
fn sroll(m: &mut Match, b: &Brain, key: &str, plist: fn(&Knobs) -> &KwNums) -> bool {
    let p = style_dif(&m.knobs, b, key, plist(&m.knobs)).f();
    chance_roll(m, p)
}

/// STYLE-DIF of the style knob KEY over its plist.
fn sdif(m: &Match, b: &Brain, key: &str, plist: fn(&Knobs) -> &KwNums) -> Num {
    style_dif(&m.knobs, b, key, plist(&m.knobs))
}

/// STYLE-KNOB of KEY, else DEFAULT.
fn sknob(m: &Match, b: &Brain, key: &str, default: Num) -> Num {
    style_knob(&m.knobs, b, key, default)
}

/// port: components.lisp BRAIN-ROLL of a chance plist.
fn brain_roll(m: &mut Match, b: &Brain, plist: fn(&Knobs) -> &KwNums) -> bool {
    let p = plist(&m.knobs).chance(b.difficulty).f();
    chance_roll(m, p)
}

fn free(st: State) -> bool {
    matches!(st, State::Idle | State::Run)
}

/// `(<= a x b)` of a float X between two CL numbers.
fn within(a: Num, x: f32, b: Num) -> bool {
    !Num::F(x).lt(a) && !b.lt(Num::F(x))
}

fn stick(m: &mut Match, e: Entity, x: f32, y: f32) {
    m.pilot.get_mut(e).expect("a pilot").vpad.stick(x, y);
}

/// port: IKS-FORM-GET — TABLE's entry for opponent O: against Hisagi his row (*IKS-HISAGI-KEYS*) when TABLE has one (NIL included),
/// else his form's, else :nozarashi's.
fn form_get<'k, T>(m: &Match, table: &'k Plist<T>, o: Entity) -> Option<&'k T> {
    let fo = fighter(m, o);
    let k = (fo.character == Some(Character::Hisagi)).then(|| m.knobs.iks_hisagi_keys.getf(fo.form.name())).flatten();
    match k.and_then(|k| table.getf(k)) {
        Some(h) => h.as_ref(),
        None => table.get(fo.form.name()).or_else(|| table.get("nozarashi")),
    }
}

/// An F2 band of a form table (IKS-FORM-GET of a table every form finds a row in).
fn band_of(m: &Match, table: fn(&Knobs) -> &Plist<crate::knobs::F2>, o: Entity) -> (f32, f32) {
    let b = form_get(m, table(&m.knobs), o).expect("a band row");
    (b.0, b.1)
}

fn iks_log(m: &mut Match, e: Entity, st: &Ikst, action: &str, d: f32) {
    let f = fighter(m, e);
    crate::clog!(
        m,
        "{} ki-style {} {} d {} ptr {} form {}",
        side_name(m, e),
        st.mode.name(),
        action,
        fmt_fixed_f32(d, 1),
        f.ptr,
        f.form.name().to_ascii_lowercase()
    );
}

// ---------------------------------------------------------------- the episode and the hover bands

/// port: IKS-PICK — the key of weight plist PLIST that roll R in [0,1) falls on (weights normalised).
fn iks_pick(plist: &[(String, f32)], r: f32) -> Mode {
    let sum = plist.iter().fold(0.0f32, |a, (_, w)| a + w); // (LOOP's sum from 0: 0 + the first weight is the weight)
    let mut acc = 0.0f32;
    for (k, w) in plist {
        acc += w / sum;
        if r < acc {
            return Mode::of(k);
        }
    }
    Mode::of(&plist.last().expect("a mix").0)
}

/// port: IKS-MODE-PICK — this episode's mode for roll R: IKS-PICK over *IKS-MIX* at B's difficulty, its weights replaced by the arm's
/// :IKS-MIX-<MODE> keys when it names any (all weights 0: :generic).
fn iks_mode_pick(m: &mut Match, b: &Brain, r: f32) -> Mode {
    let k = &m.knobs;
    let mix = k.iks_mix.chance(b.difficulty).map_or(&[][..], |x| x.0.as_slice());
    let keys = &k.iks_mix_keys.0;
    if keys.chunks(2).all(|c| strat_out(k, b, &c[1]).is_none()) {
        return iks_pick(mix, r);
    }
    let w = |c: &[String]| style_knob(k, b, &c[1], Num::F(mix.iter().find(|(x, _)| x.eq_ignore_ascii_case(&c[0])).map_or(0.0, |x| x.1)));
    let sum = keys.chunks(2).fold(Num::I(0), |a, c| a + w(c));
    if !Num::I(0).lt(sum) {
        return Mode::Generic;
    }
    if let Num::I(_) = sum {
        // (every weight an integer: each (/ w sum) a CL ratio, converted to a single by ECL's own rule; no shipped arm or mix has one)
        crate::unported!(m, "iks-mode-pick integer weights", Mode::Generic)
    }
    let mut acc = 0.0f32;
    for c in keys.chunks(2) {
        acc += w(c).f() / sum.f();
        if r < acc {
            return Mode::of(&c[0]);
        }
    }
    Mode::Generic
}

/// port: IKS-TABLE-BAND — BAND moved by the arm's :iks-hover-add metres.
fn iks_table_band(m: &Match, b: &Brain, band: (f32, f32)) -> (f32, f32) {
    let a = sknob(m, b, "iks-hover-add", Num::I(0)).f();
    (band.0 + a, band.1 + a)
}

/// port: IKS-HOVER-BAND — *IKS-BAIT-HOVER* (moved by :iks-bait-hover-add) for *IKS-BAIT-MODES*, else TABLE's.
fn iks_hover_band(m: &Match, b: &Brain, o: Entity, mode: Mode, table: fn(&Knobs) -> &Plist<crate::knobs::F2>) -> (f32, f32) {
    let k = &m.knobs;
    let bait = if k.iks_bait_modes.chance(b.difficulty).is_some_and(|n| n.has(mode.name())) { form_get(m, &k.iks_bait_hover, o) } else { None };
    match bait {
        Some(bt) => {
            let a = sknob(m, b, "iks-bait-hover-add", Num::I(0)).f();
            (bt.0 + a, bt.1 + a)
        }
        None => iks_table_band(m, b, band_of(m, table, o)),
    }
}

// ---------------------------------------------------------------- presses

/// port: IKS-KIKON-VALUE — against red, what holding the SP of pointer PROFILE is worth against cashing its Soul Break.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Kv {
    Ko,
    Tap,
    Even,
    Costly,
}

fn iks_kikon_value(m: &Match, e: Entity, profile: i64) -> Kv {
    let o = fighter(m, e).opp;
    let k = m.gauges.get(o).expect("gauges").konpaku;
    let base = kit_of(m, e).kikon_konpaku as i64;
    let kn = core_kikon_count(&m.knobs, base, profile, true);
    let sb = k.min(core_soul_break_count(&m.knobs, base, profile));
    if kn >= k {
        Kv::Ko
    } else if sb >= 5 {
        Kv::Tap
    } else if kn >= sb {
        Kv::Even
    } else {
        Kv::Costly
    }
}

fn opp_red(m: &Match, e: Entity) -> bool {
    gauges_red_p(&m.knobs, m.gauges.get(fighter(m, e).opp).expect("gauges"))
}

/// port: IKS-SP-FRAMES — frames to hold this SP (one roll per SP): never into a Kikon when he is not red; against red by
/// IKS-KIKON-VALUE. Held = 40, else a tap.
fn iks_sp_frames(m: &mut Match, e: Entity, b: &Brain, profile: i64) -> i64 {
    let held = opp_red(m, e)
        && match iks_kikon_value(m, e, profile) {
            Kv::Ko | Kv::Even => sroll(m, b, "iks-kikon-p", |k| &k.iks_kikon_p),
            Kv::Costly => sroll(m, b, "iks-kikon-costly-p", |k| &k.iks_kikon_costly_p),
            Kv::Tap => false,
        };
    if held { 40 } else { 1 }
}

/// port: IKS-FINISH-TARGET — against red: the press count a string runs to before its SP (3: AS2 held, 5: AS3 tapped), else NIL.
fn iks_finish_target(m: &Match, e: Entity) -> Option<i64> {
    if !(m.knobs.iks_finish_steer && opp_red(m, e)) {
        return None;
    }
    let v2 = iks_kikon_value(m, e, 2);
    if v2 == Kv::Ko {
        Some(3)
    } else if iks_kikon_value(m, e, 3) == Kv::Tap {
        Some(5)
    } else if m.knobs.iks_finish_even && v2 == Kv::Even {
        Some(3)
    } else {
        None
    }
}

/// port: IKS-SP — press SP from neutral, tagged with PLAN (a :shot's / :g-sa's a tap). T.
fn iks_sp(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, action: &str, d: f32, plan: Option<Sym>) -> bool {
    (st.plan, b.own_key) = (plan, -1);
    iks_log(m, e, st, action, d);
    let frames = if matches!(plan, Some(SHOT | G_SA)) { 1 } else { iks_sp_frames(m, e, b, fighter(m, e).ptr) };
    cai_press(b, QUICK, frames, true);
    true
}

/// port: IKS-J — press J from neutral (a string's J1). T.
fn iks_j(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, action: &str, d: f32) -> bool {
    (st.plan, b.own_key) = (None, -1);
    iks_log(m, e, st, action, d);
    cai_press(b, QUICK, 1, false);
    true
}

/// port: IKS-WALK — walk toward the band LO..HI (strafing inside it) this step. T.
fn iks_walk(m: &mut Match, e: Entity, b: &mut Brain, d: f32, lo: f32, hi: f32) -> bool {
    b.strafe_t -= 1;
    if b.strafe_t <= 0 {
        ai_strafe(&mut m.rng, &m.knobs, b);
    }
    ai_walk(b, &mut m.pilot.get_mut(e).expect("a pilot").vpad, d, lo, hi);
    true
}

/// port: IKS-NEW-EPISODE-P — she was not neutral at the last call, or she was hit since.
fn iks_new_episode_p(m: &Match, e: Entity, st: &Ikst) -> bool {
    !matches!(st.last_st, Some(State::Idle | State::Run)) || m.gauges.get(e).expect("gauges").reishi.lt(st.last_reishi)
}

// ---------------------------------------------------------------- the whiff punish and confirm

/// port: IKS-WHIFF-START-P — does O's perceived move (class OC, SNAP S) start out of his reach at D?
fn iks_whiff_start_p(m: &mut Match, o: Entity, s: &Snap, d: f32, oc: MoveClass) -> bool {
    let k = &m.knobs;
    if k.iks_move_band_chars.has(fighter(m, o).character.map_or("", |c| c.name())) {
        let Some(id) = s.mv else { return false };
        let mvd = mv(m, id);
        let margin = k.iks_move_band_margin;
        d > s.reach + max_f32(0.0, mvd.slide) + margin || d < mv_min_reach(m, mvd, Some(o)) - margin
    } else {
        let key = if oc == MoveClass::Na { "na" } else { "ns" };
        form_get(m, &k.iks_his_reach, o).and_then(|row| row.0.iter().find(|(x, _)| x.eq_ignore_ascii_case(key))).is_some_and(|r| d > r.1)
    }
}

/// port: IKS-NS-WAIT — *IKS-NS-WAIT* (the arm's) for F's punish of his whiffing NS; under pointer 1 the arm's :iks-ns-wait-p1.
fn iks_ns_wait(m: &Match, e: Entity, b: &Brain) -> Num {
    let w = sdif(m, b, "iks-ns-wait", |k| &k.iks_ns_wait);
    if fighter(m, e).ptr == 1 { sknob(m, b, "iks-ns-wait-p1", w) } else { w }
}

/// Her punisher's reach by pointer (`(nth (1- ptr) *iks-punish-reach*)`).
fn punish_reach(m: &Match, ptr: i64) -> f32 {
    m.knobs.iks_punish_reach.0[(ptr - 1) as usize].f()
}

/// port: IKS-PUNISH — the whiff punish (every style mode). One roll per his move start. T when pressed.
#[allow(clippy::too_many_arguments)]
fn iks_punish(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32, o: Entity) -> bool {
    let oc = cai_class_of(m, o, s);
    let ptr = fighter(m, e).ptr;
    if let Some(c @ (MoveClass::Na | MoveClass::Ns)) = oc
        && ptr != 2
    {
        if st.pkey != s.start {
            st.pkey = s.start;
            st.punish = Some(if iks_whiff_start_p(m, o, s, d, c) && sroll(m, b, "iks-punish-p", |k| &k.iks_punish_p) { GO } else { NO });
        }
        if st.punish == Some(GO)
            && if c == MoveClass::Na {
                d <= punish_reach(m, ptr) // (his J's whiff: only within her punisher's reach)
            } else {
                !Num::I(m.match_tick - s.start).lt(iks_ns_wait(m, e, b)) // (his NS's slide brings him in: M20)
                    && (!m.knobs.iks_punish_ns_reach || d <= punish_reach(m, ptr))
            }
        {
            st.punish = Some(DONE);
            let action = if c == MoveClass::Na { "punish-j" } else { "punish-ns" };
            return iks_sp(m, e, b, st, action, d, (ptr == 3).then_some(LUNGE));
        }
    }
    iks_confirm(m, e, b, st, s, d, oc)
}

/// port: IKS-CONFIRM — the whiff confirm: his perceived move past its active frames with no contact, still recovering; once per his
/// move start roll *IKS-CONFIRM-P*, then press the fastest punisher that reaches D and lands inside his recovery. T when pressed.
fn iks_confirm(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32, oc: Option<MoveClass>) -> bool {
    if !(matches!(oc, Some(MoveClass::Na | MoveClass::Ns | MoveClass::Sa))
        && !(st.pkey == s.start && st.punish == Some(DONE))
        && st.ckey != s.start
        && snap_recovering_p(s)
        && s.contact.is_none()
        && !s.has_flag(m.data, "parry"))
    {
        return false;
    }
    st.ckey = s.start;
    let k = &m.knobs;
    let left = s.left - b.delay + k.iks_confirm_slack;
    let f = fighter(m, e);
    let ptr = f.ptr;
    let row = k.iks_punishers.get(if f.form == Form::Kessa { "kessa" } else { "base" }).map_or(&[][..], |r| r.0.as_slice());
    let mut pick: Option<(Punisher, i64, i64)> = None;
    for &p in row {
        // ((ceiling x y) of two singles: ECL's ceilf (x / y))
        let walk = 0.max(libm::ceilf((d - (p.reach - 0.1)) / k.iks_confirm_walk) as i64);
        let tot = p.hit + 1 + walk;
        let ok = match p.what.0 {
            ":J" => true,
            ":NS1" => ptr == 1,
            ":NS2" => ptr == 2,
            ":NS3" => ptr == 3,
            _ => false,
        };
        if tot <= left && ok && pick.is_none_or(|(_, t, _)| tot < t) {
            pick = Some((p, tot, walk));
        }
    }
    let Some((p, _, walk)) = pick else { return false };
    if !sroll(m, b, "iks-confirm-p", |k| &k.iks_confirm_p) {
        return false;
    }
    (st.pkey, st.punish) = (s.start, Some(DONE));
    if walk > 0 {
        (st.pend, st.pend_until) = (Some(p), m.match_tick + walk + 2);
        iks_log(m, e, st, "confirm-walk", d);
        iks_pend_step(m, e, b, st, d)
    } else {
        iks_confirm_press(m, e, b, st, d, p)
    }
}

/// port: IKS-CONFIRM-PRESS — press the confirm's punisher P. T.
fn iks_confirm_press(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, d: f32, p: Punisher) -> bool {
    st.pend = None;
    if p.what == Sym(":J") { iks_j(m, e, b, st, "confirm-j", d) } else { iks_sp(m, e, b, st, "confirm-sp", d, p.plan) }
}

/// port: IKS-PEND-STEP — a confirm walking in: press once inside the punisher's reach, walk on until the last tick, then drop it.
fn iks_pend_step(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, d: f32) -> bool {
    let Some(p) = st.pend else { return false };
    if d <= p.reach - 0.1 {
        iks_confirm_press(m, e, b, st, d, p)
    } else if m.match_tick > st.pend_until {
        st.pend = None;
        false
    } else {
        ai_walk(b, &mut m.pilot.get_mut(e).expect("a pilot").vpad, d, 0.0, p.reach - 0.2);
        true
    }
}

// ---------------------------------------------------------------- the timed Hoho, its follow-up

/// port: IKS-TIMED-HOHO — Hoho his perceived attack in reach, timed into the perfect-Hoho window. One roll per his move start.
fn iks_timed_hoho(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let o = fighter(m, e).opp;
    if !(cai_class_of(m, o, s).is_some()
        && s.phase == Some(crate::components::Phase::Main)
        && snap_live_p(s)
        && (snap_near_p(m, s, e, d, 1.0) || (m.knobs.iks_hoho_slide && s.mv.is_some_and(|id| d < s.reach + mv(m, id).slide + 1.0))))
    {
        return false;
    }
    if st.hkey != s.start {
        st.hkey = s.start;
        st.hoho = sroll(m, b, "iks-hoho-p", |k| &k.iks_hoho_p);
    }
    let lead = snap_lead_seen(s, b);
    let g = m.gauges.get(e).expect("gauges");
    let crate::knobs::Window(lo, hi) = m.knobs.iks_hoho_lead;
    if st.hoho && lo <= lead && lead <= hi && hoho_ready_p(m, e) && ai_hoho_spare_p(&m.knobs, g.fs, g.reishi, g.reishi_max) {
        (st.hoho, st.hoho_t) = (false, m.match_tick);
        iks_log(m, e, st, "hoho", d);
        ai_press(b, STEP, 1, true, HOHO);
        return true;
    }
    false
}

/// port: IKS-HOHO-FOLLOW — just after her timed Hoho: J1 on his seen recovery / reeling (walk in to *IKS-HOHO-J-REACH* first).
fn iks_hoho_follow(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    if !(st.hoho_t >= 0 && !sknob(m, b, "iks-hoho-follow", Num::I(m.knobs.iks_hoho_follow)).lt(Num::I(m.match_tick - st.hoho_t))) {
        return false;
    }
    if !snap_punishable_p(s) {
        false
    } else if d <= m.knobs.iks_hoho_j_reach {
        (st.hoho_t, st.mode_mv) = (-1, Mode::Kessa);
        iks_j(m, e, b, st, "hoho-j", d)
    } else if d < 3.0 {
        let r = m.knobs.iks_hoho_j_reach;
        iks_walk(m, e, b, d, 0.0, r)
    } else {
        false
    }
}

/// port: IKS-PROJ — the perceived distance D projected over her perception delay by its change since the last call.
fn iks_proj(m: &Match, b: &Brain, st: &Ikst, d: f32) -> f32 {
    let vmax = m.knobs.iks_lead_vmax;
    let v = max_f32(-vmax, min_f32(vmax, d - st.last_d));
    d + v * b.delay as f32
}

// ---------------------------------------------------------------- the shut-gauge lunge

/// port: IKS-HIS-HOHO-SHUT-P — is O's Hoho shut: his flash-step under FS (not for *IKS-GAP-LOCKOUT-ONLY*), or his last Hoho seen
/// within *IKS-GAP-LOCKOUT*?
fn iks_his_hoho_shut_p(m: &Match, o: Entity, st: &Ikst, fs: Num) -> bool {
    let g = m.gauges.get(o).expect("gauges");
    let k = &m.knobs;
    (Num::F(g.fs).lt(fs) && g.burst.is_none() && !k.iks_gap_lockout_only.has(fighter(m, o).character.map_or("", |c| c.name())))
        || m.match_tick - st.his_hoho < k.iks_gap_lockout
}

/// port: IKS-HIS-SHUT-LEFT — frames his Hoho stays shut at the least.
fn iks_his_shut_left(m: &Match, o: Entity, st: &Ikst, fs: Num) -> Num {
    let g = m.gauges.get(o).expect("gauges");
    let k = &m.knobs;
    let climb = if g.burst.is_some() || k.iks_gap_lockout_only.has(fighter(m, o).character.map_or("", |c| c.name())) {
        Num::I(0)
    } else {
        Num::F((fs - Num::F(g.fs)).f() / (k.fs_regen / 60.0))
    };
    climb.max(Num::I(k.iks_gap_lockout - (m.match_tick - st.his_hoho)))
}

/// port: IKS-CLOSING — his perceived approach speed (m a step, toward her), from the SNAP a step older than the one she sees,
/// measured from her own position now, clamped to -0.1..0.12; NIL without that SNAP.
fn iks_closing(m: &Match, e: Entity, b: &Brain, d: f32) -> Option<f32> {
    let n = b.ring.len() as i64;
    let q = b.ring[modulo(b.head - b.delay - 2, n) as usize]?;
    let p = pos_of(m, e);
    (b.delay + 2 < n).then(|| max_f32(-0.1, min_f32(0.12, libm::sqrtf(expt2(q.x - p[0]) + expt2(q.z - p[2])) - d)))
}

/// port: IKS-GAP — the shut-gauge lunge (*IKS-GAP-P*): at pointer 3, his Hoho shut, the episode's roll said yes, for *IKS-GAP-MAX*
/// frames. T when decided.
fn iks_gap(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let fs = sknob(m, b, "iks-gap-fs", Num::F(m.knobs.iks_gap_fs));
    let gw = sknob(m, b, "iks-gap-wait", Num::F(m.knobs.iks_gap_wait));
    let f = fighter(m, e);
    let (o, ptr, kessa) = (f.opp, f.ptr, f.form == Form::Kessa);
    if !(ptr == 3 && iks_his_hoho_shut_p(m, o, st, fs)) {
        return false;
    }
    if st.gap.is_none() {
        st.gap = Some(if sroll(m, b, "iks-gap-p", |k| &k.iks_gap_p) { GO } else { NO });
        st.gap_t = 0;
    }
    if st.gap != Some(GO) {
        return false;
    }
    st.gap_t += 1;
    if st.gap_t > m.knobs.iks_gap_max {
        return false;
    }
    let c0 = iks_closing(m, e, b, d);
    let c = c0.unwrap_or(0.0);
    let dl = b.delay;
    let walking = c0.is_some() && c >= m.knobs.iks_gap_cmin;
    let row = &m.knobs.iks_gap_band.get(if kessa { "kessa" } else { "base" }).expect("a gap band").0;
    let (lo, hi, hitf) = (row[0].f(), row[1].f(), row[2].int().expect("a hit frame"));
    let plo = lo + 2.0 * c * dl as f32;
    let phi = hi + c * (hitf + dl) as f32;
    if walking && free(s.state) && plo < d && d <= phi && st.dt <= 0 && fighter(m, e).state == State::Idle {
        return iks_sp(m, e, b, st, "gap-lunge", d, Some(if kessa { K_LUNGE } else { LUNGE }));
    }
    if s.state == State::Move {
        return false; // (his move live: no dash, the Hoho / punish / confirm keep it)
    }
    let below = if walking { d < plo } else { Num::F(d).lt(gw) };
    if !below {
        return true; // (out there: stand and let him come)
    }
    let dash = !Num::F(d).lt(gw)
        || (!iks_his_shut_left(m, o, st, fs).lt(Num::I(m.knobs.iks_gap_dash_need))
            && m.knobs.iks_gap_dash_his_forms.get(if kessa { "kessa" } else { "base" }).is_some_and(|n| n.has(fighter(m, o).form.name())));
    if !dash {
        return false;
    }
    iks_log(m, e, st, "gap-dash", d);
    let over = m.knobs.iks_gap_dash_over;
    ai_dash(&m.knobs, b, -1.0, gw.f() + over);
    st.dt = m.knobs.iks_gap_dash_dt; // (the lunge is this plan's own next press)
    true
}

// ---------------------------------------------------------------- the wake-up Hoho, the meaty, the cross

/// port: IKS-WAKE — her first free frame after a wake-up with him near: the Hoho (one roll per wake-up). T when pressed.
fn iks_wake(m: &mut Match, e: Entity, b: &mut Brain, st: &Ikst, d: f32) -> bool {
    let k = &m.knobs;
    if d <= k.iks_wake_hoho_near
        && k.iks_wake_hoho_forms.has(fighter(m, e).form.name())
        && hoho_ready_p(m, e)
        && sroll(m, b, "iks-wake-hoho-p", |k| &k.iks_wake_hoho_p)
    {
        iks_log(m, e, st, "wake-hoho", d);
        ai_press(b, STEP, 1, true, HOHO);
        return true;
    }
    false
}

/// port: IKS-MEATY — his knockdown, the roll said yes: in to *IKS-MEATY-NEAR*, and J1 to land on his first free frame. T while it
/// decides.
#[allow(clippy::too_many_arguments)]
fn iks_meaty(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let k = &m.knobs;
    let f = fighter(m, e);
    if !(st.meaty
        && matches!(s.state, State::Air | State::Down | State::Wakeup)
        && !(k.iks_meaty_space_skip
            && f.form == Form::Kessa
            && f.ptr == 3
            && k.iks_kessa_space_modes.chance(b.difficulty).is_some_and(|n| n.has(st.mode.name()))))
    {
        return false;
    }
    let q = kit_command_move(m.data, kit, "q");
    let rf = &k.reaction_frames;
    let sf = s.sf + b.delay;
    let left = match s.state {
        State::Down => rf.get("down", 30) + rf.get("wakeup", 30) - sf,
        State::Wakeup => rf.get("wakeup", 30) - sf,
        _ => 999,
    };
    if sknob(m, b, "iks-meaty-far", Num::F(k.iks_meaty_far)).lt(Num::F(d)) {
        st.meaty = false; // (he flew off: the style plays on)
        false
    } else if let Some(q) = q.filter(|q| left <= q.s as i64 + m.knobs.iks_meaty_lead) {
        st.meaty = false;
        if d <= q.reach + q.slide {
            st.mode_mv = Mode::Kessa;
            iks_j(m, e, b, st, "meaty-j", d)
        } else {
            false
        }
    } else if d > m.knobs.iks_meaty_near {
        stick(m, e, 0.0, 1.0);
        true
    } else {
        stick(m, e, 0.0, 0.0);
        true
    }
}

/// port: IKS-CROSS — inside his form's band (*IKS-CROSS-BAND*) with his hit not coming: the Hoho or a dash in to its TO (one roll
/// per episode). T when it pressed.
fn iks_cross(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32, o: Entity) -> bool {
    let Some(row) = form_get(m, &m.knobs.iks_cross_band, o).map(|r| (r.0[0].f(), r.0[1].f(), r.0[2].f())) else { return false };
    if !(row.0 < d && d < row.1 && st.dt <= 0 && !(s.state == State::Move && !snap_recovering_p(s))) {
        return false;
    }
    if st.cross.is_none() {
        st.cross = Some(if sroll(m, b, "iks-cross-p", |k| &k.iks_cross_p) { GO } else { NO });
    }
    if st.cross != Some(GO) {
        return false;
    }
    st.dt = m.knobs.iks_cross_dt;
    let g = m.gauges.get(e).expect("gauges");
    let (fs, r, rm) = (g.fs, g.reishi, g.reishi_max);
    if hoho_ready_p(m, e) && ai_hoho_spare_p(&m.knobs, fs, r, rm) && sroll(m, b, "iks-cross-hoho-p", |k| &k.iks_cross_hoho_p) {
        iks_log(m, e, st, "cross-hoho", d);
        ai_press(b, STEP, 1, true, HOHO);
    } else {
        iks_log(m, e, st, "cross", d);
        ai_dash(&m.knobs, b, 1.0, row.2);
    }
    true
}

// ---------------------------------------------------------------- neutral

/// port: IKS-POINTER-2 — pointer 2: the Getsuga from *IKS-GETSUGA-MIN*, a J string inside her J reach, no charge in between: back
/// dash (one roll per episode) or hover back. T when decided, NIL to hand over.
fn iks_pointer_2(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let k = &m.knobs;
    let gmin = sknob(m, b, "iks-getsuga-min", Num::F(k.iks_getsuga_min));
    let o = fighter(m, e).opp;
    if style_on(k, b, "iks-p2-wait", k.iks_p2_wait.chance(b.difficulty))
        && d > k.iks_j_reach
        && !k.iks_getsuga_his_forms.has(fighter(m, o).form.name())
    {
        let (lo, hi) = iks_table_band(m, b, band_of(m, |k| &k.iks_hover, o)); // (his released form: no Getsuga, wait)
        return iks_walk(m, e, b, d, lo, hi);
    }
    if !Num::F(d).lt(gmin) {
        if st.dt <= 0 {
            st.dt = m.knobs.iks_shot_gap;
            iks_sp(m, e, b, st, "getsuga", d, Some(SHOT));
        }
        return true;
    }
    let jr = k.iks_j_reach;
    if d <= jr {
        return if st.dt <= 0 { iks_j(m, e, b, st, "p2-j", d) } else { iks_walk(m, e, b, d, 0.0, jr) };
    }
    if k.iks_retreat_rearm && s.state == State::Move && st.rkey != s.start {
        (st.rkey, st.retreat) = (s.start, Retreat::Nil); // (his move: a new roll)
    }
    if st.retreat == Retreat::Nil {
        st.retreat = if sroll(m, b, "iks-retreat-p", |k| &k.iks_retreat_p) { Retreat::Go } else { Retreat::T };
    }
    if st.retreat == Retreat::Go {
        st.retreat = Retreat::T;
        iks_log(m, e, st, "retreat", d);
        let to = sknob(m, b, "iks-retreat-to", Num::F(m.knobs.iks_retreat_to)).f();
        ai_dash(&m.knobs, b, -1.0, to);
        true
    } else if d < m.knobs.iks_ns2_min {
        let lo = m.knobs.iks_ns2_min;
        iks_walk(m, e, b, d, lo, gmin.f()) // (never charge in his face)
    } else {
        false
    }
}

/// port: IKS-NEUTRAL — a style mode's neutral step. T when decided.
fn iks_neutral(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let f = fighter(m, e);
    let (o, form, ptr) = (f.opp, f.form, f.ptr);
    let mode = st.mode;
    let kessa = form == Form::Kessa;
    let calm = free(s.state);
    let k = &m.knobs;
    let patient = style_on(k, b, "iks-patient-p", k.iks_patient_p.chance(b.difficulty)) && k.iks_patient_forms.has(form.name());
    let hoho_form = k.iks_hoho_forms.has(form.name());
    st.dt -= 1;
    if !k.iks_untimed_hoho && hoho_form && Num::F(0.0).lt(sdif(m, b, "iks-hoho-p", |k| &k.iks_hoho_p)) {
        b.hoho_roll = 1.0; // (the generic's untimed Hoho off: only the timed one)
    }
    if hoho_form && iks_timed_hoho(m, e, b, st, s, d) {
        return true;
    }
    if st.pend.is_some() && iks_pend_step(m, e, b, st, d) {
        return true;
    }
    if iks_punish(m, e, b, st, s, d, o) {
        return true;
    }
    // his attack live and in reach: the generic's Hoho roll (the identical test) takes the step
    if s.state == State::Move
        && s.left > 0
        && d < s.reach + 1.0
        && hoho_ready_p(m, e)
        && b.hoho_roll < m.knobs.cai_hoho_p.chance(b.difficulty)
    {
        return false;
    }
    // KESSA: awaken once full at a free moment
    let k = &m.knobs;
    if k.iks_awaken_modes.has(mode.name())
        && !(k.iks_break_awaken && Num::F(0.0).lt(sdif(m, b, "iks-break-p", |k| &k.iks_break_p)))
        && gauges_awakened_ok_p(m, e, Some(b))
        && (calm || d > s.reach + 1.5)
        && {
            if st.awaken.is_none() {
                st.awaken = Some(if sroll(m, b, "iks-awaken-p", |k| &k.iks_awaken_p) { GO } else { NO });
            }
            st.awaken == Some(GO)
        }
    {
        st.awaken = Some(NO);
        iks_log(m, e, st, "awaken", d);
        ai_press(b, AWAKEN, 1, true, AWAKEN);
        return true;
    }
    if iks_cross(m, e, b, st, s, d, o) {
        return true; // (his form's band: never stood in, crossed by a dash in)
    }
    if ptr == 2 {
        return iks_pointer_2(m, e, b, st, s, d); // (before the wait's end: never a charge in his face)
    }
    if iks_gap(m, e, b, st, s, d) {
        return true; // (pointer 3, his Hoho shut: the lunge beyond his back Step)
    }
    if sdif(m, b, "iks-wait-max", |k| &k.iks_wait_max).lt(Num::I(st.ep_t)) && !patient {
        return false; // waited long enough: the generic plays on
    }
    let k = &m.knobs;
    let chain_lo = strat_out(k, b, "iks-kessa-chain-lo").or(k.iks_kessa_chain_band.0.first().copied()); // (STYLE-KNOB: pure)
    if kessa && mode == Mode::Kessa && ptr != 3 && chain_lo.is_none() {
        // (no chains: wait)
        if d < 1.7 {
            return false;
        }
        let (lo, hi) = iks_hover_band(m, b, o, mode, |k| &k.iks_hover_p1);
        return iks_walk(m, e, b, d, lo, hi);
    }
    if kessa && ptr == 3 && k.iks_kessa_space_modes.chance(b.difficulty).is_some_and(|n| n.has(mode.name())) {
        // KESSA pointer 3: the k-lunge beyond his back Step (the arm's -lo / -hi move it)
        let clo = sknob(m, b, "iks-kessa-lunge-lo", Num::F(k.iks_kessa_lunge_band.0));
        let chi = sknob(m, b, "iks-kessa-lunge-hi", Num::F(k.iks_kessa_lunge_band.1));
        return if calm && within(clo, iks_proj(m, b, st, d), chi) && st.dt <= 0 {
            iks_sp(m, e, b, st, "k-lunge", d, Some(K_LUNGE))
        } else {
            iks_walk(m, e, b, d, clo.f(), chi.f())
        };
    }
    if kessa && mode == Mode::Kessa {
        let (clo, chi) = if ptr == 3 {
            (Num::F(k.iks_kessa_near_band.0), Num::F(k.iks_kessa_near_band.1))
        } else {
            let band = &k.iks_kessa_chain_band.0;
            (chain_lo.expect("a chain band"), sknob(m, b, "iks-kessa-chain-hi", band.get(1).copied().unwrap_or(Num::F(3.4))))
        };
        return if calm && within(clo, d, chi) && st.dt <= 0 {
            let action = if ptr == 3 { "k-lunge" } else { "k-chains" };
            iks_sp(m, e, b, st, action, d, (ptr == 3).then_some(K_LUNGE))
        } else if d > 7.0 {
            false
        } else {
            iks_walk(m, e, b, d, clo.f(), chi.f())
        };
    }
    if kessa && ptr == 3 && d < k.iks_k_sa_min && k.iks_close_j_chars.has(fighter(m, o).character.map_or("", |c| c.name())) {
        // (no clone in his face)
        return if st.dt <= 0 && (calm || snap_recovering_p(s)) { iks_j(m, e, b, st, "close-j", d) } else { true };
    }
    if mode == Mode::Ptr3 && !patient {
        return false; // neutral as the generic; the steering is in the move
    }
    if mode == Mode::Kessa && !kessa && !patient {
        return false; // (until full: as the generic)
    }
    if d > 7.0 {
        return false; // the generic dashes in to 4.5 m
    }
    if mode == Mode::Space && ptr == 3 && (k.iks_patient_lunge || !patient) {
        let (llo, lhi) = band_of(m, |k| &k.iks_lunge_band, o);
        return if calm && llo <= d && d <= lhi && st.dt <= 0 {
            iks_sp(m, e, b, st, "lunge", d, Some(LUNGE))
        } else if d < 1.7 {
            false // point-blank: the generic's J
        } else {
            iks_walk(m, e, b, d, llo, lhi)
        };
    }
    let wb = &k.iks_walkin_band.0;
    if mode == Mode::Space
        && ptr == 1
        && !wb.is_empty()
        && !patient
        && free(s.state)
        && within(wb[0], d, wb[1])
        && st.dt <= 0
    {
        return iks_sp(m, e, b, st, "walk-in", d, None);
    }
    if patient || matches!(mode, Mode::Space | Mode::Whiff) {
        if d < 1.7 {
            return false;
        }
        let table: fn(&Knobs) -> &Plist<crate::knobs::F2> = if ptr == 1 { |k| &k.iks_hover_p1 } else { |k| &k.iks_hover };
        let (lo, hi) = iks_hover_band(m, b, o, mode, table);
        return iks_walk(m, e, b, d, lo, hi);
    }
    false
}

// ---------------------------------------------------------------- her own move

/// port: IKS-MOVE — a style mode's step inside her own move (decides once per move, as CAI-MOVE-STEP: BRAIN-DECIDED). T when decided.
fn iks_move(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, st: &mut Ikst, s: &Snap, d: f32) -> bool {
    let f = fighter(m, e);
    let (Some(id), Some(cls)) = (f.mv, f.cls) else { return false };
    if b.decided == f.cls_t || st.mode_mv == Mode::Generic {
        return false;
    }
    let mvd = mv(m, id);
    let (o, cls_t, presses, kessa, sf) = (f.opp, f.cls_t, f.presses, f.form == Form::Kessa, f.sf);
    let oc = cai_class_of(m, o, s);
    match cls {
        Cls::Na | Cls::Sa => {
            if presses <= 1 && st.skey != cls_t {
                // a string's first link: its steer roll
                st.skey = cls_t;
                st.steer = if sroll(m, b, "iks-steer-p", |k| &k.iks_steer_p) {
                    Some(if kessa && st.mode_mv == Mode::Kessa {
                        let as_ = &m.knobs.iks_kessa_as.0;
                        Num::I(if opp_red(m, e) { as_[1] } else { as_[0] })
                    } else {
                        sknob(m, b, "iks-steer-to", Num::I(m.knobs.iks_steer_to))
                    })
                } else {
                    None
                };
            }
            let Some(to) = iks_finish_target(m, e).map(Num::I).or(st.steer) else { return false };
            let f = fighter(m, e);
            if !(f.contact == Some(Contact::Hit) && !f.as_done) {
                return false;
            }
            b.decided = cls_t;
            let read = || oc == Some(MoveClass::Ns);
            let take_as = !Num::I(presses).lt(to)
                || presses >= 5
                || (read()
                    && (!kessa || core_next_as(m, e) >= m.knobs.iks_kessa_read_min.get(b.difficulty.name(), 1))
                    && brain_roll(m, b, |k| &k.iks_read_p));
            if take_as {
                let as_ = core_next_as(m, e);
                if presses >= 5 {
                    crate::clog!(m, "{} ki-style {} as{}", side_name(m, e), st.mode_mv.name(), as_);
                }
                let frames = iks_sp_frames(m, e, b, as_);
                cai_press(b, QUICK, frames, true);
            } else {
                cai_press(b, QUICK, 1, false);
            }
            true
        }
        Cls::Ns => {
            if sf < mvd.s as i64 {
                return false;
            }
            let ns_next = mv_ns_next(m.data, kit, mvd).is_some();
            let is = |n: i64| kit_core_move(m.data, kit, Role::Ns, n).is_some_and(|x| std::ptr::eq(x, mvd));
            let contact = fighter(m, e).contact;
            if m.knobs.iks_ns_stop.chance(b.difficulty) && !mvd.hits.is_empty() && mvd.reach > 0.0 && contact.is_none() && ns_next {
                // its own NS out, no contact yet: wait; a whiff stops here
                if sf >= (mvd.s + mvd.a) as i64 {
                    b.decided = cls_t;
                    crate::clog!(m, "{} ki-style {} ns-stop {}", side_name(m, e), st.mode_mv.name(), mv_name(mvd).to_ascii_lowercase());
                }
                true
            } else if st.plan == Some(SHOT) && ns_next && mvd.hits.is_empty() {
                // the Getsuga's charges: on (refused at 0: the branch still decides, no press, S7)
                b.decided = cls_t;
                if cai_next_ok_p(m, e, kit, mvd) {
                    cai_press(b, QUICK, 1, true);
                }
                true
            } else if st.plan == Some(K_LUNGE) && is(3) && m.knobs.iks_k_sa_dodge_stop && matches!(s.state, State::Hoho | State::Step) {
                // his dodge seen: no SA into it, NS3a ends here (b2_a0)
                (b.decided, st.plan) = (cls_t, None);
                crate::clog!(m, "{} ki-style kessa k-sa-stop {} d {}", side_name(m, e), s.state.name().to_ascii_lowercase(), fmt_fixed_f32(d, 1));
                true
            } else if st.plan == Some(K_LUNGE) && is(3) && {
                let dd = if m.knobs.iks_k_sa_perceived { d } else { fighter(m, e).dist };
                dd < m.knobs.iks_k_sa_reach && dd >= m.knobs.iks_k_sa_min
            } {
                // KESSA NS3a > SA
                (b.decided, st.skey) = (cls_t, -1);
                crate::clog!(m, "{} ki-style kessa k-sa d {}", side_name(m, e), fmt_fixed_f32(d, 1));
                cai_press(b, QUICK, 1, false);
                true
            } else if st.plan == Some(G_SA) && is(2) {
                // the confirm's NS2a > its gap's SA
                (b.decided, st.skey, st.plan) = (cls_t, -1, None);
                cai_press(b, QUICK, 1, false);
                true
            } else if contact == Some(Contact::Hit) && kit_sa_move(m.data, kit).is_some() && (is(1) || is(3)) {
                // a landed NS1a / NS3a: the SA, a string
                (b.decided, st.skey) = (cls_t, -1);
                cai_press(b, QUICK, 1, false);
                true
            } else {
                false
            }
        }
        Cls::As => {
            // every segment of the AS (AS3c's kill is the 5-Konpaku one)
            let held = m.pilot.get(e).expect("a pilot").vpad.down(Button::Quick as usize);
            if sf >= mvd.s as i64 && mv_ns_next(m.data, kit, mvd).is_some() && !held {
                b.decided = cls_t;
                cai_press(b, QUICK, 1, true);
                true
            } else {
                false
            }
        }
    }
}

/// port: IKS-GENERIC — a style episode's step left to the generic CPU, with the style's Kikon rule on the SP it presses. T.
fn iks_generic(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s: &Snap, d: f32) -> bool {
    let neutral = free(fighter(m, e).state);
    if neutral {
        cai_neutral(m, e, b, kit, s, d, false);
    } else {
        cai_move_step(m, e, b, kit, s);
    }
    let f = fighter(m, e);
    let (ptr, cls) = (f.ptr, f.cls);
    if b.press == Some(QUICK)
        && b.press_mod
        && b.act == Some(QUICK)
        && b.press_left > 0
        && if neutral { ptr != 2 } else { matches!(cls, Some(Cls::Na | Cls::Sa)) }
    {
        let profile = if neutral { ptr } else { core_next_as(m, e) };
        b.press_left = iks_sp_frames(m, e, b, profile);
    }
    true
}

/// port: IKS-BREAK — in his combo: the awakening (a full gauge, *IKS-BREAK-AWAKEN*) or the Burst breaks out (one roll per combo).
fn iks_break(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst) -> bool {
    let f = fighter(m, e);
    if !(f.kikon_lock == 0 && f.combo_hits >= m.knobs.burst_min_hits && b.burst_t >= b.delay) {
        return false;
    }
    let hits = f.combo_hits;
    let g = m.gauges.get(e).expect("gauges");
    // ((getf core :no-awaken): no kit has the key)
    let aw = m.knobs.iks_break_awaken && !g.awakened && g.awaken >= m.knobs.awaken_max;
    let bu = crate::gauges::burst_ok_p(m, e).is_some();
    if (aw || bu) && st.brk.is_none() {
        st.brk = Some(if sroll(m, b, "iks-break-p", |k| &k.iks_break_p) { GO } else { NO });
    }
    if st.brk == Some(GO) && (aw || bu) {
        (st.brk, b.burst_rolled) = (Some(NO), true);
        crate::clog!(m, "{} ki-style break {} hits {}", side_name(m, e), if aw { "awaken" } else { "burst" }, hits);
        if aw {
            ai_press(b, AWAKEN, 1, true, AWAKEN);
        } else {
            cai_press(b, AWAKEN, 1, false);
        }
        return true;
    }
    false
}

/// port: ICHIGO-KI-STYLE's body over its state ST (the IKST, or the IKST an IKW includes).
fn ichigo_ki(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Ikst, s: Snap, d: f32) -> bool {
    let kit = kit_of(m, e);
    let f = fighter(m, e);
    let (state, form, invuln) = (f.state, f.form, f.invuln);
    if matches!(s.state, State::Air | State::Down | State::Wakeup) {
        // his knockdown: the meaty's roll, once as he goes down
        if !st.down {
            st.down = true;
            st.meaty = !sknob(m, b, "iks-meaty-far", Num::F(m.knobs.iks_meaty_far)).lt(Num::F(d))
                && m.knobs.iks_meaty_forms.has(form.name())
                && sroll(m, b, "iks-meaty-p", |k| &k.iks_meaty_p);
            if st.meaty {
                crate::clog!(m, "{} ki-style meaty armed d {}", side_name(m, e), fmt_fixed_f32(d, 1));
            }
        }
    } else {
        (st.down, st.meaty) = (false, false);
    }
    if s.state == State::Hoho {
        st.his_hoho = s.start; // (his Hoho seen: its start tick, for IKS-HIS-HOHO-SHUT-P)
    }
    if free(state) && invuln > 0 && m.knobs.iks_burst_no_hoho.chance(b.difficulty) {
        b.hoho_roll = 1.0; // (after her Burst: the stale SNAP's attack is not Hohoed)
    }
    let generic_kikon = m.knobs.iks_generic_kikon.chance(b.difficulty);
    let r = match state {
        State::Idle | State::Run => {
            if iks_new_episode_p(m, e, st) {
                let r = m.rng.rnd01();
                st.mode = iks_mode_pick(m, b, r);
                (st.mode_mv, st.plan, st.ep_t, st.pend, st.retreat, st.awaken, st.dt) =
                    (st.mode, None, 0, None, Retreat::Nil, None, 0);
                (st.gap, st.cross) = (None, None);
            }
            st.ep_t += 1;
            // (the follow-up after her timed Hoho, the meaty: whatever the new episode's mode)
            if (st.last_st == Some(State::Wakeup) && iks_wake(m, e, b, st, d))
                || iks_hoho_follow(m, e, b, st, &s, d)
                || iks_meaty(m, e, b, kit, st, &s, d)
            {
                true
            } else if st.mode == Mode::Generic {
                generic_kikon && iks_generic(m, e, b, kit, &s, d)
            } else {
                iks_neutral(m, e, b, st, &s, d) || iks_generic(m, e, b, kit, &s, d)
            }
        }
        State::Move => {
            if st.mode_mv == Mode::Generic {
                generic_kikon && iks_generic(m, e, b, kit, &s, d)
            } else {
                iks_move(m, e, b, kit, st, &s, d) || iks_generic(m, e, b, kit, &s, d)
            }
        }
        State::Stun | State::Air => iks_break(m, e, b, st),
        State::Hoho => {
            let f = fighter(m, e);
            if m.knobs.iks_follow_any_perfect.chance(b.difficulty) && f.perfect {
                st.hoho_t = m.match_tick - f.sf; // (any perfect Hoho: the follow-up's clock)
            }
            false
        }
        _ => false,
    };
    if !matches!(state, State::Stun | State::Air) {
        st.brk = None;
    }
    if free(state) && b.press_left > 0 && st.dt <= 0 {
        st.dt = m.knobs.cai_think.get(b.difficulty.name(), 22) + floor_f32(12.0 * m.rng.rnd01());
    }
    tail(m, e, st, state, d);
    r
}

/// ICHIGO-KI-STYLE's tail bookkeeping: her state, Reishi and the perceived distance at this call.
fn tail(m: &Match, e: Entity, st: &mut Ikst, state: State, d: f32) {
    (st.last_st, st.last_reishi, st.last_d) = (Some(state), m.gauges.get(e).expect("gauges").reishi, d);
}

/// port: ICHIGO-KI-STYLE — Ichigo's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU. An
/// IKST or a style's on it (IKW) is kept, across rounds and matches too (no tick test); another struct starts afresh.
pub fn ichigo_ki_style(m: &mut Match, _: &mut Search, e: Entity, b: &mut Brain, s: Snap, d: f32) -> bool {
    let mut st = take_style(b, |x| matches!(x, StyleState::Ikst(_) | StyleState::Ikw(_)), || StyleState::Ikst(Ikst::new()));
    let r = ichigo_ki(m, e, b, st.ikst_mut().expect("an IKST"), s, d);
    b.style = Some(st);
    r
}

// ---------------------------------------------------------------- cpu-ki-ichigo-r2b2a1.lisp

/// port: IKW-ROLL-STEP — her knockdown: the roll's chance once as she goes down, then the stick held through :down.
fn ikw_roll_step(m: &mut Match, e: Entity, b: &Brain, st: &mut Ikw) {
    match fighter(m, e).state {
        State::Air | State::Down => {
            if st.roll.is_none() {
                st.roll = Some(if sroll(m, b, "ikw-roll-p", |k| &k.ikw_roll_p) { GO } else { NO });
            }
            if st.roll == Some(GO) && fighter(m, e).state == State::Down {
                let x = sknob(m, b, "ikw-roll-x", Num::F(m.knobs.ikw_roll_x)).f();
                let y = sknob(m, b, "ikw-roll-y", Num::F(m.knobs.ikw_roll_y)).f();
                stick(m, e, x, y);
            }
        }
        State::Wakeup => {}
        _ => st.roll = None,
    }
}

/// port: IKW-GAP-WATCH — after ICHIGO-KI-STYLE's step: a far lunge pressed now starts the watch; his Step seen inside it counts one;
/// at :ikw-gap-off-n the lunge goes off (IKW-ALT).
fn ikw_gap_watch(m: &mut Match, e: Entity, b: &Brain, st: &mut Ikw, s: &Snap, d: f32) {
    if b.press_left > 0
        && b.press == Some(QUICK)
        && b.press_mod
        && matches!(st.k.plan, Some(LUNGE | K_LUNGE))
        && !Num::F(d).lt(sknob(m, b, "ikw-gap-far", Num::F(m.knobs.ikw_gap_far)))
    {
        st.lunge_t = m.match_tick;
    } else if s.state == State::Step && m.match_tick - st.lunge_t <= m.knobs.ikw_gap_watch {
        st.lunge_t = -999;
        st.stepped += 1;
        let n = sknob(m, b, "ikw-gap-off-n", Num::I(m.knobs.ikw_gap_off_n));
        if let Some(now) = b.now.filter(|_| st.alt.is_none() && Num::I(0).lt(n) && !Num::I(st.stepped).lt(n)) {
            st.alt = Some(now.st); // (the arm with :iks-gap-p 0.0 first in its :base; the first :base / key wins: GETF)
            crate::clog!(m, "{} ki-style gap off d {}", side_name(m, e), fmt_fixed_f32(d, 1));
        }
    }
}

/// port: IKW-STALE-P — track both Reishi and Konpaku; T when none changed for :ikw-stale frames.
fn ikw_stale_p(m: &Match, e: Entity, b: &Brain, st: &mut Ikw) -> bool {
    let (g, og) = (m.gauges.get(e).expect("gauges"), m.gauges.get(fighter(m, e).opp).expect("gauges"));
    let r = g.reishi * 2048 + og.reishi;
    let k = 16 * g.konpaku + og.konpaku;
    let n = sknob(m, b, "ikw-stale", Num::I(m.knobs.ikw_stale));
    if r.lt(st.rsig) || st.rsig.lt(r) || k != st.ksig {
        (st.rsig, st.ksig, st.still_t) = (r, k, m.match_tick);
    }
    Num::I(0).lt(n) && n.lt(Num::I(m.match_tick - st.still_t))
}

/// port: ICHIGO-KI-R2B2A1-STYLE — ICHIGO-KI-STYLE plus the wake-up roll; a stale neutral goes to the generic CPU. T when it decided.
pub fn ichigo_ki_r2b2a1_style(m: &mut Match, _: &mut Search, e: Entity, b: &mut Brain, s: Snap, d: f32) -> bool {
    let st = take_style(b, |x| matches!(x, StyleState::Ikw(_)), || StyleState::Ikw(Ikw::new()));
    let StyleState::Ikw(mut st) = st else { unreachable!() };
    let state = fighter(m, e).state;
    if let (Some(alt), Some(now)) = (st.alt, b.now) {
        let c = Now { st: alt, cues: now.cues, gap_off: true }; // (the cell: (car c) the alt, (cdr c) NOW's cues; NOW becomes it)
        (st.cell, b.now) = (Some(c), Some(c));
    }
    let r = if ikw_stale_p(m, e, b, &mut st) && free(state) {
        let kit = kit_of(m, e);
        iks_generic(m, e, b, kit, &s, d);
        tail(m, e, &mut st.k, state, d); // (ICHIGO-KI-STYLE's tail bookkeeping, as it would)
        true
    } else {
        ichigo_ki(m, e, b, &mut st.k, s, d)
    };
    ikw_gap_watch(m, e, b, &mut st, &s, d);
    ikw_roll_step(m, e, b, &mut st);
    b.style = Some(StyleState::Ikw(st));
    r
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::components::Difficulty;

    /// Every CLOG of cpu-ki-ichigo.lisp / cpu-ki-ichigo-r2b2a1.lisp has exactly one Rust log site with the same text (`~(~a~)` `~a`
    /// `~d` `~,1f` -> `{}`), and each `ki-style <mode>` tag of the plan's census is IKS-LOG's line with that mode (or a literal one).
    #[test]
    fn ichigo_c_tags_have_a_site() {
        let lisp = [include_str!("../../../../duel/lisp/cpu-ki-ichigo.lisp"), include_str!("../../../../duel/lisp/cpu-ki-ichigo-r2b2a1.lisp")];
        let rust = include_str!("ichigo_ki.rs");
        let rust = &rust[..rust.find("#[cfg(test)]").unwrap()];
        let mut fmts = vec![];
        for src in lisp {
            for (i, _) in src.match_indices("(clog \"") {
                let t = &src[i + 7..];
                let t = &t[..t.find('"').unwrap()];
                fmts.push(t.replace("~(~a~)", "{}").replace("~,1f", "{}").replace("~a", "{}").replace("~d", "{}"));
            }
        }
        assert_eq!(fmts.len(), 8);
        for f in &fmts {
            // (a format string may be split over the macro's lines: its text is one literal)
            assert_eq!(rust.matches(&format!("\"{f}\"")).count(), 1, "{f}");
        }
        let log = "{} ki-style {} {} d {} ptr {} form {}";
        assert!(fmts.iter().any(|f| f == log));
        for mode in ["ptr3", "space", "whiff", "kessa"] {
            assert_eq!(Mode::of(mode).name(), mode);
        }
        assert!(fmts.iter().any(|f| f.starts_with("{} ki-style kessa ")), "a literal kessa line");
    }

    /// IKS-MODE-PICK with no arm keys: IKS-PICK over the difficulty's *IKS-MIX* row, each weight normalised in order (NORMAL: generic
    /// 0.88, then 0.03 each), the roll's place deciding; EASY's single row is always :generic.
    #[test]
    fn mode_pick_by_the_mix() {
        let mut m = Match::new(crate::hashline::tests::data());
        let b = Brain::new(Difficulty::Normal, 14);
        for (r, want) in [(0.0, Mode::Generic), (0.8799, Mode::Generic), (0.8801, Mode::Space), (0.9101, Mode::Whiff), (0.9401, Mode::Ptr3),
                          (0.9701, Mode::Kessa), (0.9999, Mode::Kessa)] {
            assert_eq!(iks_mode_pick(&mut m, &b, r), want, "{r}");
        }
        let b = Brain::new(Difficulty::Easy, 14);
        assert_eq!(iks_mode_pick(&mut m, &b, 0.9999), Mode::Generic);
    }

    /// The struct prints as TR-B-ENC prints it: IKW's 36 slots, ALT NIL and CELL `(NIL)` among them (the key's first IKW, its fresh
    /// slots), a pending punisher as its list.
    #[test]
    fn ikw_prints_its_slots() {
        let d = crate::hashline::tests::data();
        let mut s = String::new();
        StyleState::Ikw(Ikw::new()).enc(d, &mut s);
        assert_eq!(s, "#IKW{:GENERIC,0,NIL,0,0,NIL,NIL,-1,NIL,-1,NIL,0,-1,NIL,-1,NIL,NIL,-1,NIL,-1,:GENERIC,00000000,NIL,NIL,NIL,0,NIL,-999,NIL,-999,0,NIL,(NIL),-1,-1,0}");
        let mut k = Ikst::new();
        k.pend = Some(Punisher { what: Sym(":NS1"), hit: 22, reach: 3.4, plan: None });
        let mut s = String::new();
        k.pend.enc(d, &mut s);
        assert_eq!(s, "(:NS1,22,4059999A,NIL)");
    }
}
