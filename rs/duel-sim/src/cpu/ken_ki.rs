//! port: duel/lisp/cpu-ki-ken.lisp, cpu-kh-ken.lisp — Kenpachi's matchup style CPUs: KEN-KI-STYLE (against Ichigo: the sealed brawl,
//! the Shikai's climb, the Bankai, the answers to her Getsuga route), and on it KEN-KH-STYLE (the wake-up bait) and
//! KEN-KH-STANDOFF-STYLE (the stand-off breaker). A style runs on every step its CPU is free to press, before the generic CPU, and says
//! whether it decided this step. Its state is a struct in BRAIN-STYLE (KKS; KHS and KSO include it). Every chance is rolled once per
//! event from the sim stream, in the Lisp's order; the opponent is read only through the perceived SNAP and distance.
use super::core_ai::{cai_class_of, cai_move_step, cai_neutral, cai_next_ok_p, cai_own_rolls, cai_press, cai_sp, chance_roll, gauges_awakened_ok_p};
use super::glue::{strat_out, style_dif, style_knob};
use super::perceive::{ai_dash, ai_press, Snap};
use super::style::{take_style, StyleState};
use super::{Brain, Search};
use crate::cl::{floor_f32, fmt_fixed_f32, max_f32, min_f32, round_f32, Num};
use crate::components::{Button, Cls, Contact, Form, State, Sym};
use crate::core_sim::core_next_as;
use crate::ecs::Entity;
use crate::fighter::{fighter, gauges_red_p, hoho_ready_p, kit_of, mv, pos_of, reishi_frac, side_name, yaw_of};
use crate::hashline::Enc;
use crate::kit::{kit_command_move, kit_core_move, kit_sa_move, mv_name, mv_ns_next, mv_sa_move, Role};
use crate::knobs::KwNums;
use crate::math::{angle_wrap, deg, dir_yaw};
use crate::state::Match;
use duel_data::{Data, Kit, Move, MoveClass};

const QUICK: Sym = Sym(":QUICK");
const STEP: Sym = Sym(":STEP");
const AWAKEN: Sym = Sym(":AWAKEN");
const HOHO: Sym = Sym(":HOHO");
// KKS-PLAN's values
const CLOSE: Sym = Sym(":CLOSE");
const HIT: Sym = Sym(":HIT");
const CUT: Sym = Sym(":CUT");
const LATE: Sym = Sym(":LATE");
const STEP_PLAN: Sym = Sym(":STEP");
const CHASE: Sym = Sym(":CHASE");
const STEPIN: Sym = Sym(":STEPIN");
const HEND: Sym = Sym(":HEND");
const SDODGE: Sym = Sym(":SDODGE");
const DODGE: Sym = Sym(":DODGE");
// KK-READ's answers
const TAME: Sym = Sym(":TAME");
const J1: Sym = Sym(":J1");
const NS1A: Sym = Sym(":NS1A");

/// `~a` of a keyword: its name without the colon.
fn kw(s: Sym) -> &'static str {
    &s.0[1..]
}

// ---------------------------------------------------------------- the style's state (BRAIN-STYLE; a new match's brain starts NIL)

/// KKS-REACH: the approach's reach roll, `(or bk (style-roll ...))`: in a Bankai the MEMBER tail of `(:bankai :bankai-2)`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Reach {
    Nil,
    T,
    /// `(member form '(:bankai :bankai-2))`: FORM's tail.
    Tail(Form),
}

impl Enc for Reach {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str(match self {
            Reach::Nil => "NIL",
            Reach::T => "T",
            Reach::Tail(Form::Bankai) => "(:BANKAI,:BANKAI-2)",
            Reach::Tail(_) => "(:BANKAI-2)",
        });
    }
}

/// port: (DEFSTRUCT KKS) — every slot in order.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Kks {
    pub ev: i64,
    pub was: State,
    pub meaty: bool,
    pub form: Option<Form>,
    pub climb: bool,
    pub l3: bool,
    pub bankai: bool,
    pub bk_n: i64,
    pub gw: i64,
    pub plan: Option<Sym>,
    pub at: i64,
    pub sa_key: i64,
    pub aw: Option<Sym>,
    pub appr: bool,
    pub reach: Reach,
    pub hin: bool,
    pub safe: bool,
    pub sin: bool,
    pub pf: i64,
    pub pfr: bool,
    pub mine: State,
    pub pfw: bool,
    pub fresh: i64,
    pub msf: i64,
    pub mend: i64,
    pub hl: i64,
    pub tick: i64,
}

impl Kks {
    /// port: (MAKE-KKS).
    pub fn new() -> Kks {
        Kks {
            ev: -2,
            was: State::Idle,
            meaty: false,
            form: None,
            climb: false,
            l3: false,
            bankai: false,
            bk_n: 0,
            gw: -999,
            plan: None,
            at: -1,
            sa_key: -1,
            aw: None,
            appr: false,
            reach: Reach::Nil,
            hin: false,
            safe: false,
            sin: false,
            pf: -999,
            pfr: false,
            mine: State::Idle,
            pfw: false,
            fresh: -1,
            msf: 0,
            mend: 0,
            hl: -999,
            tick: 0,
        }
    }
}

impl Default for Kks {
    fn default() -> Self {
        Kks::new()
    }
}

/// The KKS slots, comma separated (a struct that includes KKS prints them first).
impl Enc for Kks {
    fn enc(&self, d: &Data, s: &mut String) {
        let v: [&dyn Enc; 27] = [
            &self.ev, &self.was, &self.meaty, &self.form, &self.climb, &self.l3, &self.bankai, &self.bk_n, &self.gw, &self.plan, &self.at,
            &self.sa_key, &self.aw, &self.appr, &self.reach, &self.hin, &self.safe, &self.sin, &self.pf, &self.pfr, &self.mine, &self.pfw,
            &self.fresh, &self.msf, &self.mend, &self.hl, &self.tick,
        ];
        for (i, x) in v.into_iter().enumerate() {
            if i > 0 {
                s.push(',');
            }
            x.enc(d, s);
        }
    }
}

/// port: (DEFSTRUCT (KHS (:INCLUDE KKS))) — KEN-KH-STYLE's state.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Khs {
    pub k: Kks,
    pub hw: State,
    pub bait: bool,
    pub last: i64,
}

impl Khs {
    /// port: (MAKE-KHS).
    pub fn new() -> Khs {
        Khs { k: Kks::new(), hw: State::Idle, bait: false, last: -999 }
    }
}

impl Default for Khs {
    fn default() -> Self {
        Khs::new()
    }
}

impl Enc for Khs {
    fn enc(&self, d: &Data, s: &mut String) {
        self.k.enc(d, s);
        for x in [&self.hw as &dyn Enc, &self.bait, &self.last] {
            s.push(',');
            x.enc(d, s);
        }
    }
}

/// port: (DEFSTRUCT (KSO (:INCLUDE KKS))) — KEN-KH-STANDOFF-STYLE's state.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Kso {
    pub k: Kks,
    pub so_at: i64,
    pub so_r0: f32,
    pub so_r1: f32,
    pub so_k0: i64,
    pub so_k1: i64,
    pub so_on: bool,
}

impl Kso {
    /// port: (MAKE-KSO).
    pub fn new() -> Kso {
        Kso { k: Kks::new(), so_at: 0, so_r0: 0.0, so_r1: 0.0, so_k0: 0, so_k1: 0, so_on: false }
    }
}

impl Default for Kso {
    fn default() -> Self {
        Kso::new()
    }
}

impl Enc for Kso {
    fn enc(&self, d: &Data, s: &mut String) {
        self.k.enc(d, s);
        for x in [&self.so_at as &dyn Enc, &self.so_r0, &self.so_r1, &self.so_k0, &self.so_k1, &self.so_on] {
            s.push(',');
            x.enc(d, s);
        }
    }
}

// ---------------------------------------------------------------- small readers

/// port: components.lisp BRAIN-ROLL of a chance plist.
fn brain_roll(m: &mut Match, b: &Brain, plist: fn(&crate::knobs::Knobs) -> &KwNums) -> bool {
    let p = plist(&m.knobs).chance(b.difficulty).f();
    chance_roll(m, p)
}

/// STYLE-ROLL of the style knob KEY over its plist.
fn sroll(m: &mut Match, b: &Brain, key: &str, plist: fn(&crate::knobs::Knobs) -> &KwNums) -> bool {
    let p = style_dif(&m.knobs, b, key, plist(&m.knobs)).f();
    chance_roll(m, p)
}

/// STYLE-KNOB of a single-float knob: KEY's value, else DEFAULT.
fn sknob(m: &Match, b: &Brain, key: &str, default: f32) -> f32 {
    style_knob(&m.knobs, b, key, Num::F(default)).f()
}

/// port: ken.lisp KEN-LV.
fn ken_lv(m: &Match, e: Entity) -> i64 {
    crate::ken::hooks::lv(m, e)
}

fn q_move(m: &Match, kit: &Kit) -> Option<&'static Move> {
    kit_command_move(m.data, kit, "q")
}

fn kk_stick(m: &mut Match, e: Entity, toward: f32) {
    // port: KK-STICK — hold the stick TOWARD (1 in, 0 still, -1 back) this step
    m.pilot.get_mut(e).expect("a pilot").vpad.stick(0.0, toward);
}

/// port: KK-HOHO.
fn kk_hoho(b: &mut Brain) {
    ai_press(b, STEP, 1, true, HOHO);
}

fn free(st: State) -> bool {
    matches!(st, State::Idle | State::Run)
}

fn bankai_p(form: Form) -> bool {
    matches!(form, Form::Bankai | Form::Bankai2)
}

/// port: ken.lisp KEN-CLOSING — his perceived closing speed toward E (m/f, > 0: coming), from the SNAP S seen and the one before it.
pub fn ken_closing(m: &Match, e: Entity, b: &Brain, s: &Snap, d: f32) -> f32 {
    let n = b.ring.len() as i64;
    let s1 = b.ring[crate::cl::modulo(b.head - b.delay - 2, n) as usize];
    let Some(s1) = s1.filter(|_| d >= 0.01) else { return 0.0 };
    let p = pos_of(m, e);
    -((s1.x - s.x) * (s.x - p[0]) + (s1.z - s.z) * (s.z - p[2])) / d
}

// ---------------------------------------------------------------- her Getsuga route

/// port: KK-ROUTE-P — does S show her in a segment of the Getsuga route?
fn kk_route_p(m: &Match, s: &Snap) -> bool {
    s.state == State::Move
        && s.mv.is_some_and(|id| matches!(mv_name(mv(m, id)), "ic-n2a" | "ic-n2b" | "ic-n2c" | "ic-k-n2a" | "ic-k-n2b" | "ic-k-n2c"))
}

/// port: KK-JUJI-START — the tick JUJISHO starts (or started) in the route S shows.
fn kk_juji_start(m: &Match, s: &Snap) -> i64 {
    let t0 = s.start;
    match s.mv.map(|id| mv_name(mv(m, id))) {
        Some("ic-n2c" | "ic-k-n2c") => t0,
        Some("ic-n2b" | "ic-k-n2b") => t0 + 17,
        _ => t0 + 38,
    }
}

/// port: KK-WAVE-TICK — the tick to press an answer timed LEAD frames after JUJISHO starts at 5 m, shifted by the wave's travel to D.
fn kk_wave_tick(m: &Match, s: &Snap, d: f32, lead: i64) -> i64 {
    kk_juji_start(m, s) + lead + round_f32((d - 5.0) * (60.0f32 / 14.0f32))
}

/// port: KK-WAVE-MIX — *KK-WAVE-MIX*'s weight KEY, or the arm's :KK-WAVE-<KEY>.
fn kk_wave_mix(m: &Match, b: &Brain, key: &str) -> f32 {
    let arm = match key {
        "close" => "kk-wave-close",
        "cut" => "kk-wave-cut",
        "late" => "kk-wave-late",
        _ => "kk-wave-step",
    };
    let key = if matches!(key, "close" | "cut" | "late") { key } else { "step" };
    style_knob(&m.knobs, b, arm, m.knobs.kk_wave_mix.get_or(key, Num::F(0.0))).f()
}

/// port: KK-WAVE-PLAN — one roll for her Getsuga route, or NIL.
fn kk_wave_plan(m: &mut Match, e: Entity, b: &Brain, kit: &Kit, d: f32) -> Option<Sym> {
    let form = fighter(m, e).form;
    if d > m.knobs.kk_wave_band.1 {
        // (from afar: Hoho in at once, else the cut)
        return if !sroll(m, b, "kk-wave-p", |k| &k.kk_wave_p) {
            None
        } else if hoho_ready_p(m, e) {
            Some(CLOSE)
        } else if form != Form::Base {
            Some(CUT)
        } else if kk_wave_mix(m, b, "step") > 0.0 {
            Some(STEP_PLAN)
        } else {
            None
        };
    }
    let far = d >= m.knobs.kk_wave_band.0;
    let lunge = d <= kk_reach(m, e, kit, What::Ns);
    let hoho = hoho_ready_p(m, e);
    let wc = if !far || lunge {
        1.0
    } else if d > sknob(m, b, "kk-wave-close-max", m.knobs.kk_wave_close_max) {
        0.0
    } else {
        kk_wave_mix(m, b, "close")
    };
    let wk = if !far || lunge || form == Form::Base { 0.0 } else { kk_wave_mix(m, b, "cut") };
    let wl = if far && !lunge && hoho { kk_wave_mix(m, b, "late") } else { 0.0 };
    let ws = if far && !lunge && !hoho && form == Form::Base { kk_wave_mix(m, b, "step") } else { 0.0 };
    let sum = wc + wk + wl + ws;
    if sum > 0.0 && sroll(m, b, "kk-wave-p", |k| &k.kk_wave_p) {
        let r = sum * m.rng.rnd01();
        Some(if r < wc {
            CLOSE
        } else if r < wc + wk {
            CUT
        } else if r < wc + wk + wl {
            LATE
        } else {
            STEP_PLAN
        })
    } else {
        None
    }
}

/// port: KK-TRACK — the events, once each: a new form stay, L3 reached, her knockdown (chance MEATY), her Hoho, her Getsuga route.
#[allow(clippy::too_many_arguments)]
fn kk_track(m: &mut Match, e: Entity, b: &Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks, meaty: f32) {
    let form = fighter(m, e).form;
    let ss = s.state;
    if Some(form) != st.form {
        (st.form, st.l3, st.bankai, st.bk_n) = (Some(form), false, false, 0);
        st.climb = form == Form::Nozarashi && sroll(m, b, "kk-climb-p", |k| &k.kk_climb_p);
        if st.climb {
            crate::clog!(m, "{} kk climb", side_name(m, e));
        }
    }
    if form == Form::Nozarashi {
        if ken_lv(m, e) >= m.knobs.ken_lv_max {
            if !st.l3 {
                st.l3 = true;
                st.bankai = sroll(m, b, "kk-bankai-p", |k| &k.kk_bankai_p);
                if st.bankai {
                    crate::clog!(m, "{} kk bankai-plan", side_name(m, e));
                }
            }
        } else {
            (st.l3, st.bankai) = (false, false);
        }
    }
    if matches!(ss, State::Air | State::Down) && !matches!(st.was, State::Air | State::Down | State::Wakeup) {
        st.meaty = chance_roll(m, meaty);
        if st.meaty {
            crate::clog!(m, "{} kk meaty armed", side_name(m, e));
        }
    }
    if !matches!(ss, State::Air | State::Down | State::Wakeup) {
        st.meaty = false;
    }
    if ss == State::Hoho {
        // (her Hoho seen: its start)
        let (h0, q) = (s.start, q_move(m, kit));
        let lockout = m.knobs.kk_hoho_lockout;
        if h0 + lockout > st.hl {
            st.hl = h0 + lockout;
            if let Some(q) = q
                && st.plan.is_none()
                && brain_roll(m, b, |k| &k.kk_hend_p)
            {
                (st.plan, st.at) = (Some(HEND), h0 + m.knobs.hoho_frames + m.knobs.kk_hend_lead - q.s as i64);
                crate::clog!(m, "{} kk hoho-end plan at {}", side_name(m, e), st.at);
            }
        }
    }
    st.was = ss;
    if kk_route_p(m, s) {
        if s.start - st.gw > 45 && d <= m.knobs.kk_wave_far {
            st.plan = kk_wave_plan(m, e, b, kit, d);
            st.at = -1;
            if let Some(p) = st.plan {
                crate::clog!(m, "{} kk wave {} at {}", side_name(m, e), kw(p), fmt_fixed_f32(d, 1));
            }
        }
        st.gw = s.start;
    }
}

// ---------------------------------------------------------------- neutral

/// KK-REACH's / KK-ATTACK-IN's WHAT: the pointer's NS, or J1.
#[derive(Clone, Copy, PartialEq, Eq)]
enum What {
    Ns,
    J,
}

/// port: KK-REACH — how far WHAT (:ns the pointer's NS, else J1) reaches for him now: reach + slide - *KK-WAVE-MARGIN*, + the run's
/// carry while he runs; 0 for a move that reaches nothing.
fn kk_reach(m: &Match, e: Entity, kit: &Kit, what: What) -> f32 {
    let f = fighter(m, e);
    let mvd = if what == What::Ns { kit_core_move(m.data, kit, Role::Ns, f.ptr) } else { q_move(m, kit) };
    match mvd {
        Some(mvd) if mvd.reach > 0.0 => {
            let k = &m.knobs;
            (mvd.reach + mvd.slide - k.kk_wave_margin) + if f.state == State::Run { k.kk_wave_carry } else { 0.0 }
        }
        _ => 0.0,
    }
}

/// port: KK-ATTACK-IN — press WHAT (:ns the pointer's NS, else J1) on her route.
fn kk_attack_in(m: &mut Match, e: Entity, b: &mut Brain, what: What) {
    b.own_key = -1;
    b.r_kikon = m.rng.rnd01();
    if what == What::Ns {
        cai_sp(m, e, b, 1, false);
    } else {
        cai_press(b, QUICK, 1, false);
    }
    kk_stick(m, e, 0.0);
}

/// port: KK-CLOSE-HIT — in on her charge: the pointer's NS once it reaches, J1 where the NS cannot hit. T when it pressed.
fn kk_close_hit(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks) -> bool {
    let juji = kk_route_p(m, s) && s.mv.is_some_and(|id| matches!(mv_name(mv(m, id)), "ic-n2c" | "ic-k-n2c"));
    let rn = if bankai_p(fighter(m, e).form) && juji { 0.0 } else { kk_reach(m, e, kit, What::Ns) };
    let hit = if rn > 0.0 { d <= rn } else { d <= kk_reach(m, e, kit, What::J) };
    if hit {
        st.plan = None;
        kk_attack_in(m, e, b, if rn > 0.0 { What::Ns } else { What::J });
    }
    hit
}

/// port: KK-CHASE-STEP — after a :cut / :late answer: in on her JUJISHO recovery and hit. T when it decided.
fn kk_chase_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, d: f32, st: &mut Kks) -> bool {
    let (rj, rn) = (kk_reach(m, e, kit, What::J), kk_reach(m, e, kit, What::Ns));
    if m.match_tick > st.at {
        st.plan = None;
        false
    } else if d <= rj {
        st.plan = None;
        kk_attack_in(m, e, b, What::J);
        true
    } else if d <= rn {
        st.plan = None;
        kk_attack_in(m, e, b, What::Ns);
        true
    } else if d > m.knobs.kk_chase_dash {
        ai_dash(&m.knobs, b, 1.0, 2.6);
        true
    } else {
        kk_stick(m, e, 1.0);
        true
    }
}

/// port: KK-WAVE-STEP — carry out the plan (her route's answer, the Hoho-end J1, the dodges). T when it decided this step.
fn kk_wave_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks) -> bool {
    let (plan, route, tick) = (st.plan.expect("a plan"), kk_route_p(m, s), m.match_tick);
    match plan {
        CLOSE => {
            if kk_close_hit(m, e, b, kit, s, d, st) {
                true
            } else if hoho_ready_p(m, e) {
                st.plan = Some(HIT);
                kk_hoho(b);
                true
            } else {
                st.plan = Some(HIT);
                let rn = kk_reach(m, e, kit, What::Ns);
                let to = if rn > 0.0 { max_f32(1.6, rn - m.knobs.kk_wave_carry) } else { 2.2 };
                ai_dash(&m.knobs, b, 1.0, to);
                true
            }
        }
        HIT => {
            if !route || tick - st.gw > m.knobs.kk_wave_timeout {
                st.plan = None;
                false
            } else if kk_close_hit(m, e, b, kit, s, d, st) {
                true
            } else {
                kk_stick(m, e, 1.0);
                true
            }
        }
        CUT | LATE | STEP_PLAN => {
            if !route {
                st.plan = None;
                return false;
            }
            let k = &m.knobs;
            let lead = match plan {
                CUT => k.kk_cut_lead,
                LATE => k.kk_late_lead,
                _ => k.kk_wave_step_lead,
            };
            let at = kk_wave_tick(m, s, d, lead);
            if tick < at {
                kk_stick(m, e, 0.0);
                true
            } else if tick > at + 3 {
                st.plan = None; // (perceived too late: no answer)
                false
            } else {
                (st.plan, st.at) = (Some(CHASE), kk_juji_start(m, s) + m.knobs.kk_chase_frames);
                crate::clog!(m, "{} kk wave {} pressed at {}", side_name(m, e), kw(plan), fmt_fixed_f32(d, 1));
                let mut pressed = true;
                match plan {
                    CUT => {
                        b.own_key = -1;
                        cai_press(b, QUICK, 1, false);
                        kk_stick(m, e, 0.0);
                    }
                    LATE => {
                        if hoho_ready_p(m, e) {
                            kk_hoho(b);
                        } else {
                            pressed = false;
                            st.plan = None;
                        }
                        kk_stick(m, e, 0.0);
                    }
                    _ => {
                        ai_press(b, STEP, 1, false, STEP); // (:step: the hop toward her, through the wave)
                        kk_stick(m, e, 1.0);
                    }
                }
                pressed
            }
        }
        CHASE => kk_chase_step(m, e, b, kit, d, st),
        STEPIN => {
            st.plan = None;
            false
        }
        HEND => {
            if !matches!(s.state, State::Hoho | State::Idle | State::Run) {
                st.plan = None;
                false
            } else if tick < st.at {
                kk_stick(m, e, 0.0);
                true
            } else if !kk_facing_p(m, e, s) && tick <= st.at + 2 {
                kk_stick(m, e, 0.0); // (turn first)
                true
            } else {
                st.plan = None;
                if tick <= st.at + 2 && d <= kk_reach(m, e, kit, What::J) {
                    b.own_key = -1;
                    crate::clog!(m, "{} kk hoho-end J1 at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                    cai_press(b, QUICK, 1, false);
                    kk_stick(m, e, 0.0);
                    true
                } else {
                    false
                }
            }
        }
        SDODGE => {
            if s.state != State::Move {
                st.plan = None;
                false
            } else if tick < st.at {
                kk_stick(m, e, 0.0);
                true
            } else {
                st.plan = None;
                crate::clog!(m, "{} kk step-dodge at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                ai_press(b, STEP, 1, false, STEP);
                kk_stick(m, e, 0.0);
                true
            }
        }
        DODGE => {
            if s.state != State::Move {
                st.plan = None;
                false
            } else if tick < st.at {
                kk_stick(m, e, 0.0);
                true
            } else {
                st.plan = None;
                let ready = hoho_ready_p(m, e);
                if ready {
                    crate::clog!(m, "{} kk dodge at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                    kk_hoho(b);
                }
                ready
            }
        }
        _ => false,
    }
}

/// port: KK-STEP-J — the Step through the wave (or in): J1 two frames before its J cancel when she is in its reach. T when it pressed.
fn kk_step_j(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, d: f32, st: &mut Kks) -> bool {
    if matches!(st.plan, Some(CHASE | STEPIN))
        && fighter(m, e).sf == m.knobs.step_j_cancel - 2
        && d <= kk_reach(m, e, kit, What::J)
    {
        st.plan = None;
        b.own_key = -1;
        crate::clog!(m, "{} kk step J1 at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        cai_press(b, QUICK, 1, false);
        true
    } else {
        false
    }
}

/// port: KK-MEATY-STEP — her knockdown, the roll said yes: in, and J1 to land on her first free frame. T (it decided).
fn kk_meaty_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks) -> bool {
    let q = q_move(m, kit);
    let rf = &m.knobs.reaction_frames;
    let sf = s.sf + b.delay;
    let left = match s.state {
        State::Down => rf.get("down", 30) + rf.get("wakeup", 30) - sf,
        State::Wakeup => rf.get("wakeup", 30) - sf,
        _ => 999,
    };
    let k = &m.knobs;
    if let Some(q) = q.filter(|q| left <= q.s as i64 + k.kk_meaty_lead) {
        st.meaty = false;
        if d <= q.reach + q.slide + 0.2 {
            b.own_key = -1;
            crate::clog!(m, "{} kk meaty J1 left {}", side_name(m, e), left);
            cai_press(b, QUICK, 1, false);
        }
        kk_stick(m, e, 0.0);
    } else if d > k.kk_chase_hoho && left > 30 && hoho_ready_p(m, e) {
        kk_hoho(b);
    } else if d > k.kk_meaty_near {
        kk_stick(m, e, 1.0);
    } else if d < k.kk_meaty_min && left > k.kk_meaty_back {
        kk_stick(m, e, -1.0); // (out of her wake-up Hoho's reach)
    } else {
        kk_stick(m, e, 0.0);
    }
    true
}

/// port: KK-READ — the read on her new move start (the brawl's tame / J1 / NS1a, else the Hoho or back-Step dodge). T when it pressed
/// or planned.
fn kk_read(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks) -> bool {
    let f = fighter(m, e);
    let (form, o, ptr) = (f.form, f.opp, f.ptr);
    let Some(mvd) = s.mv.map(|id| mv(m, id)) else { return false };
    let rr = style_knob(&m.knobs, b, "kk-read-range", Num::F(m.knobs.kk_read_range));
    let route = kk_route_p(m, s);
    let clone = s.state == State::Move && cai_class_of(m, o, s) == Some(MoveClass::Ns) && mvd.hits.is_empty() && !route;
    let far = if clone { m.knobs.kk_clone_reach } else { rr.max(Num::F(mvd.reach + mvd.slide + m.knobs.kk_dodge_reach)).f() };
    if !(s.state == State::Move && s.start != st.ev && d <= far) {
        return false;
    }
    st.ev = s.start;
    let cls = cai_class_of(m, o, s);
    let left = s.s - s.sf - b.delay; // (frames to her hit)
    let Some(q) = q_move(m, kit) else { return false };
    if !matches!(cls, Some(MoveClass::Na | MoveClass::Ns)) {
        return false;
    }
    let mut how = None;
    if form == Form::Base && !clone && d <= rr.f() && sroll(m, b, "kk-brawl-p", |k| &k.kk_brawl_p) {
        b.own_key = -1;
        b.r_kikon = m.rng.rnd01();
        if ptr == 3 && (3..=27).contains(&left) && !route {
            cai_sp(m, e, b, 1, false); // (the tame catches it)
            how = Some(TAME);
        } else if left > q.s as i64 && d <= q.reach + q.slide {
            cai_press(b, QUICK, 1, false); // (J1 first)
            how = Some(J1);
        } else if ptr == 1 && cls == Some(MoveClass::Ns) && left > 14 {
            cai_sp(m, e, b, 1, false); // (NS1a first)
            how = Some(NS1A);
        }
    }
    if how.is_none() && !route && left >= 0 {
        // (her hit already past as seen: no dodge)
        let k = &m.knobs;
        let (dodge_lead, step_lead, clone_strike) = (k.kk_dodge_lead, k.kk_step_lead, k.kk_clone_strike);
        if hoho_ready_p(m, e) {
            if sroll(m, b, "kk-dodge-p", |k| &k.kk_dodge_p) {
                if 0 <= left && left <= dodge_lead {
                    // (due now: pressed on this step, not the next)
                    crate::clog!(m, "{} kk dodge now at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                    kk_hoho(b);
                } else {
                    (st.plan, st.at) = (Some(DODGE), m.match_tick + 0.max(left - dodge_lead));
                }
                how = Some(DODGE);
            }
        } else if d <= sknob(m, b, "kk-step-max", m.knobs.kk_step_max) && sroll(m, b, "kk-step-p", |k| &k.kk_step_p) {
            // (no Hoho open: the back Step)
            let sl = if clone { left - (s.s - clone_strike) } else { left };
            if 0 <= sl && sl <= step_lead {
                crate::clog!(m, "{} kk step-dodge now at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                ai_press(b, STEP, 1, false, STEP);
            } else {
                (st.plan, st.at) = (Some(SDODGE), m.match_tick + 0.max(sl - step_lead));
            }
            how = Some(SDODGE);
        }
    }
    let Some(how) = how else { return false };
    let cls = Cls::from(cls.expect("a class"));
    crate::clog!(m, "{} kk read {} {} left {} at {}", side_name(m, e), kw(how), cls.name(), left, fmt_fixed_f32(d, 1));
    kk_stick(m, e, 0.0);
    true
}

/// port: KK-LUNGE-ANY-P — the arm's :KK-LUNGE-ANY switch (>= 0.5; no key: off).
fn kk_lunge_any_p(m: &Match, b: &Brain) -> bool {
    strat_out(&m.knobs, b, "kk-lunge-any").is_some_and(|k| !k.lt(Num::F(0.5)))
}

/// port: KK-DECIDE — a neutral decision the generic CPU would make, taken by the style when a roll says so (SAFE: the Hoho-safety
/// chance). T when it decided.
fn kk_decide(m: &mut Match, e: Entity, b: &mut Brain, s: &Snap, d: f32, st: &mut Kks, safe: f32) -> bool {
    let f = fighter(m, e);
    let (form, vp_free, ptr) = (f.form, free(f.state), f.ptr);
    let kit = kit_of(m, e);
    let (ns, q) = (kit_core_move(m.data, kit, Role::Ns, ptr), q_move(m, kit));
    let safe = chance_roll(m, safe);
    let ns_ok = ns.is_none_or(|ns| !safe || kk_ns_open_p(m, b, s, st, ns)); // (not into her timed Hoho)
    let j_ok = q.is_none_or(|q| !safe || kk_ns_open_p(m, b, s, st, q));
    if !vp_free {
        return false;
    }
    let k = &m.knobs;
    match form {
        Form::Nozarashi => {
            let lv = ken_lv(m, e);
            let band = k.kk_lunge_band;
            if ns_ok
                && ((st.climb && lv < k.ken_lv_max) || kk_lunge_any_p(m, b))
                && ptr == 1
                && band.0 <= d
                && d <= band.1
                && sroll(m, b, "kk-lunge-p", |k| &k.kk_lunge_p)
            {
                b.own_key = -1;
                b.r_kikon = m.rng.rnd01();
                cai_sp(m, e, b, 1, false);
                true
            } else if lv >= m.knobs.ken_lv_max && (st.climb || st.bankai) && d <= m.knobs.kk_l3_range && j_ok {
                b.own_key = -1; // (at L3 with a plan: the J string)
                cai_press(b, QUICK, 1, false);
                true
            } else {
                false
            }
        }
        Form::Bankai | Form::Bankai2 => {
            let spare = reishi_frac(m.gauges.get(e).expect("gauges")) > k.kk_bk_floor + k.kk_bk_ns_spare;
            if ns_ok && spare && d <= k.kk_bk_ns_range && sroll(m, b, "kk-bk-ns-p", |k| &k.kk_bk_ns_p) {
                b.own_key = -1;
                b.r_kikon = m.rng.rnd01();
                cai_sp(m, e, b, 1, false);
                true
            } else {
                false // (else KK-PICK: J1 in reach, a Hoho or a walk in; no generic NS at 40 a segment)
            }
        }
        _ => false,
    }
}

/// port: KK-NS-OPEN-P — may his move MVD start now without her timed Hoho on it?
fn kk_ns_open_p(m: &Match, b: &Brain, s: &Snap, st: &Kks, mvd: &Move) -> bool {
    let ms = mvd.s as i64;
    ms <= m.knobs.kk_hoho_blind
        || st.hl - m.match_tick >= ms
        || match s.state {
            State::Move => s.left - b.delay > ms,
            State::Air | State::Down | State::Stun => true,
            _ => false,
        }
}

/// port: KK-FACING-P — does E face her perceived position within *KK-FACE-MAX* degrees?
fn kk_facing_p(m: &Match, e: Entity, s: &Snap) -> bool {
    let p = pos_of(m, e);
    let to = dir_yaw(s.x - p[0], s.z - p[2]); // (FACE-YAW-TO of two singles: %DIR-YAW)
    angle_wrap(to - yaw_of(m, e)).abs() <= deg(m.knobs.kk_face_max)
}

/// port: KK-PF-STEP — the follow-up after his own perfect Hoho: J1 where it reaches, else walk in, inside *KK-PF-WINDOW*.
fn kk_pf_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks) -> bool {
    if !st.pfr {
        return false;
    }
    let q = q_move(m, kit);
    match q {
        Some(q) if m.match_tick - st.pf <= m.knobs.kk_pf_window => {
            if !kk_facing_p(m, e, s) {
                kk_stick(m, e, 0.0); // (turn first)
            } else if d <= q.reach + q.slide {
                (st.pfr, b.own_key) = (false, -1);
                crate::clog!(m, "{} kk pf J1 at {}", side_name(m, e), fmt_fixed_f32(d, 1));
                cai_press(b, QUICK, 1, false);
                kk_stick(m, e, 0.0);
            } else {
                kk_stick(m, e, 1.0);
            }
            true
        }
        _ => {
            st.pfr = false;
            false
        }
    }
}

/// port: KK-REACH-OF — MVD's reach + slide less MARGIN; 0 for a move that reaches nothing.
fn kk_reach_of(mvd: &Move, margin: f32) -> f32 {
    if mvd.reach > 0.0 { mvd.reach + mvd.slide - margin } else { 0.0 }
}

/// port: KK-FITS-P — does MVD (E's) start a hit: its dead zone within D, and the predicted distance DP within KK-REACH-OF?
fn kk_fits_p(m: &mut Match, e: Entity, mvd: &Move, d: f32, dp: f32, margin: f32) -> bool {
    super::core_ai::mv_min_reach(m, mvd, Some(e)) <= d && dp <= kk_reach_of(mvd, margin)
}

/// KK-PICK's answer: T (it pressed), :WALK (in, and decide again soon).
#[derive(Clone, Copy, PartialEq, Eq)]
enum Pick {
    T,
    Walk,
}

/// port: KK-PICK — the discipline at a neutral decision inside the generic CPU's attack zone. The rolls are made once per approach.
#[allow(clippy::too_many_arguments)]
fn kk_pick(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks, safe: f32) -> Option<Pick> {
    let k = &m.knobs;
    let hi = kit.core.range.map_or(k.cai_range.1, |r| r[1]);
    let form = fighter(m, e).form;
    let bk = bankai_p(form);
    if d > if bk { max_f32(hi + 0.6, k.kk_bk_walk_range) } else { hi + 0.6 } {
        st.appr = false;
        return None;
    }
    if !st.appr {
        st.appr = true;
        st.reach = if bk {
            Reach::Tail(form)
        } else if sroll(m, b, "kk-reach-p", |k| &k.kk_reach_p) {
            Reach::T
        } else {
            Reach::Nil
        };
        st.hin = sroll(m, b, "kk-hoho-in-p", |k| &k.kk_hoho_in_p);
        st.safe = chance_roll(m, safe);
        st.sin = sroll(m, b, "kk-step-in-p", |k| &k.kk_step_in_p);
    }
    if st.reach == Reach::Nil {
        st.appr = false; // (this decision is the generic CPU's)
        return None;
    }
    let ptr = fighter(m, e).ptr;
    let (ns, q) = (kit_core_move(m.data, kit, Role::Ns, ptr), q_move(m, kit));
    let v = min_f32(0.0, ken_closing(m, e, b, s, d)); // (her perceived speed away: only ever stricter)
    let rm = sknob(m, b, "kk-reach-margin", m.knobs.kk_reach_margin);
    let can_j = match q {
        Some(q) => {
            kk_fits_p(m, e, q, d, d - v * (b.delay + q.s as i64) as f32, rm) && (!st.safe || kk_ns_open_p(m, b, s, st, q))
        }
        None => false,
    };
    let can_n = match ns {
        Some(ns) if !bk => {
            kk_fits_p(m, e, ns, d, d - v * (b.delay + ns.s as i64) as f32, rm) && (!st.safe || kk_ns_open_p(m, b, s, st, ns))
        }
        _ => false,
    };
    if can_n && (!can_j || m.rng.rnd01() < if d > 1.7 { m.knobs.cai_ns_far } else { m.knobs.cai_ns_near }) {
        b.own_key = -1;
        b.r_kikon = m.rng.rnd01();
        st.appr = false;
        crate::clog!(m, "{} kk pick NS at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        cai_sp(m, e, b, 1, false);
        Some(Pick::T)
    } else if can_j {
        (b.own_key, st.appr) = (-1, false);
        crate::clog!(m, "{} kk pick J1 at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        cai_press(b, QUICK, 1, false);
        Some(Pick::T)
    } else if st.hin
        && form != Form::Nozarashi
        && d <= sknob(m, b, "kk-hoho-in-max", m.knobs.kk_hoho_in_max)
        && hoho_ready_p(m, e)
        && m.gauges.get(e).expect("gauges").fs >= sknob(m, b, "kk-hin-fs", m.knobs.kk_hin_fs)
    {
        st.hin = false; // (one Hoho an approach)
        crate::clog!(m, "{} kk hoho-in at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        kk_hoho(b);
        Some(Pick::Walk)
    } else if st.sin && st.safe && form == Form::Base && m.knobs.kk_step_in_band.0 <= d && d <= m.knobs.kk_step_in_band.1 {
        (st.sin, st.plan) = (false, Some(STEPIN)); // (KK-STEP-J presses J1 out of the cancel)
        crate::clog!(m, "{} kk step-in at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        ai_press(b, STEP, 1, false, STEP);
        kk_stick(m, e, 1.0);
        Some(Pick::Walk)
    } else {
        kk_stick(m, e, 1.0);
        Some(Pick::Walk)
    }
}

/// port: KK-NEUTRAL — free: the awakening, the plan, the meaty chase, the pf follow-up, the read, then the decision hook. T when the
/// style decided.
#[allow(clippy::too_many_arguments)]
fn kk_neutral(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32, st: &mut Kks, safe: f32) -> bool {
    let base = fighter(m, e).form == Form::Base;
    if base && gauges_awakened_ok_p(m, e, Some(&*b)) && st.aw.is_none() {
        st.aw = Some(if sroll(m, b, "kk-awaken-p", |k| &k.kk_awaken_p) { Sym(":GO") } else { Sym(":NO") });
    }
    if st.aw == Some(Sym(":GO")) && base && gauges_awakened_ok_p(m, e, Some(&*b)) && st.plan.is_none() && !kk_route_p(m, s) {
        st.meaty = false;
        crate::clog!(m, "{} kk awaken", side_name(m, e));
        ai_press(b, AWAKEN, 1, true, AWAKEN);
        true
    } else if st.plan.is_some() {
        kk_wave_step(m, e, b, kit, s, d, st)
    } else if st.meaty {
        kk_meaty_step(m, e, b, kit, s, d, st)
    } else if kk_pf_step(m, e, b, kit, s, d, st) || kk_read(m, e, b, kit, s, d, st) {
        true
    } else if b.decide_t <= 1 {
        // (the generic CPU decides this step: the style may take it; no re-rolls on a retry)
        let how = if !st.appr && kk_decide(m, e, b, s, d, st, safe) { Some(Pick::T) } else { kk_pick(m, e, b, kit, s, d, st, safe) };
        match how {
            Some(Pick::Walk) => {
                b.decide_t = m.knobs.kk_reach_retry;
                true
            }
            Some(Pick::T) => {
                b.decide_t = m.knobs.cai_think.get(b.difficulty.name(), 22) + floor_f32(12.0 * m.rng.rnd01());
                true
            }
            None => false,
        }
    } else {
        false
    }
}

// ---------------------------------------------------------------- his strings

/// port: KK-P2-P — the arm's :KK-P2-OR: her Reishi fraction is under it (no key: never).
fn kk_p2_p(m: &Match, b: &Brain, e: Entity) -> bool {
    let o = fighter(m, e).opp;
    strat_out(&m.knobs, b, "kk-p2-or").is_some_and(|x| Num::F(reishi_frac(m.gauges.get(o).expect("gauges"))).lt(x))
}

/// port: KK-STRING-TARGET — the attack press his SP follows in this string, or NIL (the generic CPU's choice).
fn kk_string_target(m: &Match, e: Entity, b: &Brain, st: &Kks) -> Option<i64> {
    let f = fighter(m, e);
    let k = &m.knobs;
    match f.form {
        Form::Base => kk_p2_p(m, b, e).then_some(3),
        Form::Nozarashi => {
            if st.bankai {
                Some(7) // (set only at L3)
            } else if kk_p2_p(m, b, e) {
                Some(3)
            } else if ken_lv(m, e) < k.ken_lv_max {
                st.climb.then_some(if f.ptr == 1 { 2 } else { 3 })
            } else if st.climb {
                Some(4.max(6.min(k.kk_special_n)))
            } else {
                None
            }
        }
        Form::Bankai | Form::Bankai2 => {
            let low = reishi_frac(m.gauges.get(e).expect("gauges")) < k.kk_bk_floor;
            Some(if low || st.bk_n >= k.kk_bk_cashouts { 5 } else { 4 })
        }
        _ => None,
    }
}

/// port: KK-ROUTE-AS-P — her Getsuga route is live as his NA / SA lands: take the AS now?
fn kk_route_as_p(m: &Match, e: Entity, st: &Kks) -> bool {
    let f = fighter(m, e);
    match f.form {
        Form::Base => true,
        Form::Nozarashi => f.ptr == 1 || ken_lv(m, e) < m.knobs.ken_lv_max || !(st.climb || st.bankai),
        _ => false,
    }
}

/// port: KK-MOVE — in his own NA link or SA, as it lands: the next J or the SP by KK-STRING-TARGET; her NS seen, the SP at once.
fn kk_move(m: &mut Match, e: Entity, b: &mut Brain, s: &Snap, st: &mut Kks) -> bool {
    let f = fighter(m, e);
    if !(matches!(f.cls, Some(Cls::Na | Cls::Sa)) && f.contact == Some(Contact::Hit) && !f.as_done && b.decided != f.cls_t) {
        return false;
    }
    let (cls_t, o) = (f.cls_t, f.opp);
    let target = if kk_route_p(m, s) && kk_route_as_p(m, e, st) { Some(0) } else { kk_string_target(m, e, b, st) }; // (0: the SP now)
    let Some(target) = target else { return false };
    cai_own_rolls(m, b, cls_t);
    b.decided = cls_t;
    let f = fighter(m, e);
    let (presses, form) = (f.presses, f.form);
    let read = cai_class_of(m, o, s) == Some(MoveClass::Ns) && b.r_turn < m.knobs.kk_as_read_p.chance(b.difficulty).f();
    if presses < target && !read {
        cai_press(b, QUICK, 1, false);
    } else {
        if bankai_p(form) && target == 4 {
            st.bk_n += 1;
        }
        crate::clog!(m, "{} kk string SP after J{}", side_name(m, e), presses);
        cai_sp(m, e, b, 1, target == 7); // (the BANKAI AS holds no Kikon)
    }
    true
}

/// port: KK-NS-WHIFF — in his own NS: the next segment waits for the segment's contact, and a whiff stops the route (*KK-NS-STOP-P*,
/// the segment's own roll). T when it decided (waits or stops).
fn kk_ns_whiff(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap) -> bool {
    let f = fighter(m, e);
    let Some(mvd) = f.mv.map(|id| mv(m, id)) else { return false };
    let (cls_t, sf, o) = (f.cls_t, f.sf, f.opp);
    if !(f.cls == Some(Cls::Ns)
        && mvd.reach > 0.0
        && f.contact.is_none()
        && mv_ns_next(m.data, kit, mvd).is_some()
        && b.decided != cls_t
        && sf >= mvd.s as i64
        && cai_class_of(m, o, s) != Some(MoveClass::Na))
    {
        return false;
    }
    cai_own_rolls(m, b, cls_t);
    if b.r_turn < style_dif(&m.knobs, b, "kk-ns-stop-p", &m.knobs.kk_ns_stop_p).f() {
        if sf >= (mvd.s + mvd.a) as i64 {
            b.decided = cls_t;
        }
        true
    } else {
        false
    }
}

/// port: KK-LINK-REACH — MVD's reach + slide + *KK-LINK-MARGIN*; 0 for none.
fn kk_link_reach(m: &Match, mvd: &Move) -> f32 {
    if mvd.reach > 0.0 { mvd.reach + mvd.slide + m.knobs.kk_link_margin } else { 0.0 }
}

/// port: KK-LINK — after his own landed sealed NS segment: the next segment where it reaches, else the SA where it reaches, else
/// stop (one roll per segment). T when it decided.
fn kk_link(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, s: &Snap, d: f32) -> bool {
    let f = fighter(m, e);
    let Some(mvd) = f.mv.map(|id| mv(m, id)) else { return false };
    let (cls_t, o) = (f.cls_t, f.opp);
    if !(f.form == Form::Base
        && f.cls == Some(Cls::Ns)
        && f.contact == Some(Contact::Hit)
        && mvd.reach > 0.0
        && b.decided != cls_t
        && f.sf >= mvd.s as i64
        && cai_class_of(m, o, s) != Some(MoveClass::Na)
        && sroll(m, b, "kk-link-p", |k| &k.kk_link_p))
    {
        return false;
    }
    let nx = mv_ns_next(m.data, kit, mvd);
    let sa = mv_sa_move(m.data, kit, mvd).or_else(|| kit_sa_move(m.data, kit));
    b.decided = cls_t;
    if nx.is_some_and(|nx| d <= kk_link_reach(m, nx)) && cai_next_ok_p(m, e, kit, mvd) {
        crate::clog!(m, "{} kk link NS at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        cai_press(b, QUICK, 1, true);
    } else if sa.is_some_and(|sa| d <= kk_link_reach(m, sa)) {
        // (the next segment refused at 0, CAI-NEXT-OK-P: the style's own fallback, the SA where it reaches, S7)
        crate::clog!(m, "{} kk link SA at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        cai_press(b, QUICK, 1, false);
    } else {
        crate::clog!(m, "{} kk link stop at {}", side_name(m, e), fmt_fixed_f32(d, 1));
    }
    true
}

/// port: KK-AS-ON — in his own sealed AS: each segment presses the next once it lands; a whiff stops there (*KK-AS-ON-P*, the
/// segment's own roll). T when it decided.
fn kk_as_on(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit) -> bool {
    let f = fighter(m, e);
    let Some(mvd) = f.mv.map(|id| mv(m, id)) else { return false };
    let (cls_t, sf, contact) = (f.cls_t, f.sf, f.contact);
    if !(f.form == Form::Base
        && f.cls == Some(Cls::As)
        && mv_ns_next(m.data, kit, mvd).is_some()
        && sf >= mvd.s as i64
        && b.decided != cls_t
        && !m.pilot.get(e).expect("a pilot").vpad.down(Button::Quick as usize))
    {
        return false;
    }
    cai_own_rolls(m, b, cls_t);
    if b.r_cont < style_dif(&m.knobs, b, "kk-as-on-p", &m.knobs.kk_as_on_p).f() {
        if contact == Some(Contact::Hit) {
            b.decided = cls_t;
            cai_press(b, QUICK, 1, true);
        } else if sf >= (mvd.s + mvd.a) as i64 {
            b.decided = cls_t; // (a whiff: no more)
        }
        true
    } else {
        false
    }
}

/// port: KK-L3-SA — at L3 with a plan, in the Shikai's NS gap: the SA (one roll per segment). T when it pressed.
fn kk_l3_sa(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, d: f32, st: &mut Kks) -> bool {
    let f = fighter(m, e);
    let Some(mvd) = f.mv.map(|id| mv(m, id)) else { return false };
    let cls_t = f.cls_t;
    if !(f.cls == Some(Cls::Ns)
        && f.form == Form::Nozarashi
        && ken_lv(m, e) >= m.knobs.ken_lv_max
        && (st.climb || st.bankai)
        && f.sf >= mvd.s as i64
        && b.decided != cls_t
        && st.sa_key != cls_t
        && kit_sa_move(m.data, kit).is_some()
        && d < m.knobs.kk_l3_sa_range)
    {
        return false;
    }
    st.sa_key = cls_t; // (one roll a segment; a failed one leaves it to the generic CPU)
    if brain_roll(m, b, |k| &k.kk_l3_sa_p) {
        b.decided = cls_t;
        crate::clog!(m, "{} kk l3 SA", side_name(m, e));
        cai_press(b, QUICK, 1, false);
        true
    } else {
        false
    }
}

/// port: KK-KIKON-PTR — the pointer whose Kikon his next SP's hold would take.
fn kk_kikon_ptr(m: &Match, e: Entity) -> i64 {
    let f = fighter(m, e);
    if matches!(f.cls, Some(Cls::Na | Cls::Sa)) {
        if f.form == Form::Nozarashi && f.presses >= 4 { f.ptr } else { core_next_as(m, e) }
    } else {
        f.ptr
    }
}

/// port: KK-KIKON-RULE — an SP pressed this step held into a Kikon while she is not red (or red, but not pointer 2's): a tap instead.
fn kk_kikon_rule(m: &mut Match, e: Entity, b: &mut Brain) {
    if !(b.press == Some(QUICK) && b.press_mod && b.press_left > 1) {
        return;
    }
    let f = fighter(m, e);
    let (o, form) = (f.opp, f.form);
    let tap = if gauges_red_p(&m.knobs, m.gauges.get(o).expect("gauges")) {
        !(kk_kikon_ptr(m, e) == 2 && matches!(form, Form::Base | Form::Nozarashi)) && sroll(m, b, "kk-kikon-ptr-p", |k| &k.kk_kikon_ptr_p)
    } else {
        sroll(m, b, "kk-kikon-red-p", |k| &k.kk_kikon_red_p)
    };
    if tap {
        b.press_left = 1;
    }
}

/// port: KEN-KI-STYLE's body over its state ST (KKS, or the KKS a KHS / KSO includes). MEATY / SAFE: the chances a style built on it
/// passes (`'(:easy 0.0 :normal 0.0 :hard 0.0)`: Some(0.0)); None: STYLE-DIF of *KK-MEATY-P* / *KK-NS-SAFE-P*.
#[allow(clippy::too_many_arguments)]
fn ken_ki(m: &mut Match, e: Entity, b: &mut Brain, st: &mut Kks, s: Snap, d: f32, meaty: Option<f32>, safe: Option<f32>) -> bool {
    let k = &m.knobs;
    let meaty = meaty.unwrap_or_else(|| style_dif(k, b, "kk-meaty-p", &k.kk_meaty_p).f()); // (the two chances, once a step)
    let safe = safe.unwrap_or_else(|| style_dif(k, b, "kk-ns-safe-p", &k.kk_ns_safe_p).f());
    let tick = m.match_tick;
    let cine_wait = k.kk_cine_wait.chance(b.difficulty);
    if tick - st.tick > k.kk_cine_gap && cine_wait {
        st.fresh = tick + b.delay; // (a cinematic just ended)
    }
    let f = fighter(m, e);
    let state = f.state;
    match f.mv.map(|id| mv(m, id)) {
        Some(mvd) if state == State::Move => (st.msf, st.mend) = (f.sf, (mvd.s + mvd.a + mvd.r) as i64),
        _ => {
            // (his move cut short: a repel)
            if st.mine == State::Move && free(state) && st.msf < st.mend - 2 && cine_wait {
                st.fresh = st.fresh.max(tick + k.kk_repel_wait);
            }
            st.mend = 0;
        }
    }
    st.tick = tick;
    let kit = kit_of(m, e);
    kk_track(m, e, b, kit, &s, d, st, meaty);
    if tick < st.fresh && free(state) {
        kk_stick(m, e, 0.0);
        return true;
    }
    let p = fighter(m, e).perfect; // (his new perfect Hoho: one roll)
    if p && !st.pfw {
        st.pf = tick;
        st.pfr = brain_roll(m, b, |k| &k.kk_pf_p);
    }
    st.pfw = p;
    if !free(state) {
        st.appr = false;
    }
    if st.mine == State::Wakeup
        && free(state)
        && d <= m.knobs.kk_wake_hoho_near
        && hoho_ready_p(m, e)
        && s.state != State::Hoho
        && sroll(m, b, "kk-wake-hoho-p", |k| &k.kk_wake_hoho_p)
    {
        st.mine = state;
        crate::clog!(m, "{} kk wake-hoho at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        kk_hoho(b);
        return true;
    }
    st.mine = state;
    if state == State::Step && kk_step_j(m, e, b, kit, d, st) {
        return true;
    }
    if !matches!(state, State::Idle | State::Run | State::Move) {
        return false;
    }
    let decided = if state == State::Move {
        kk_l3_sa(m, e, b, kit, d, st)
            || kk_move(m, e, b, &s, st)
            || kk_link(m, e, b, kit, &s, d)
            || kk_as_on(m, e, b, kit)
            || kk_ns_whiff(m, e, b, kit, &s)
    } else {
        kk_neutral(m, e, b, kit, &s, d, st, safe)
    };
    if !decided {
        // (the generic CPU's step, as CORE-BRAIN-STEP)
        if state == State::Move { cai_move_step(m, e, b, kit, &s) } else { cai_neutral(m, e, b, kit, &s, d, false) }
    }
    kk_kikon_rule(m, e, b);
    true
}

/// A Kenpachi style's struct from a match not later than TICK (KKS-P and `(>= *match-tick* (kks-tick st))`; ISP: the type test).
fn ken_ok(st: &StyleState, tick: i64, isp: fn(&StyleState) -> bool) -> bool {
    isp(st) && st.kks().is_some_and(|k| tick >= k.tick)
}

/// port: KEN-KI-STYLE — Kenpachi's style against Ichigo: T when it decided this step, NIL for the generic core CPU.
pub fn ken_ki_style(m: &mut Match, _: &mut Search, e: Entity, b: &mut Brain, s: Snap, d: f32) -> bool {
    let tick = m.match_tick;
    let mut st = take_style(b, |x| ken_ok(x, tick, |_| true), || StyleState::Kks(Kks::new()));
    let r = ken_ki(m, e, b, st.kks_mut(), s, d, None, None);
    b.style = Some(st);
    r
}

// ---------------------------------------------------------------- cpu-kh-ken.lisp: the wake-up bait

/// port: KHF-BAIT-CELLS-P — the arm's :KHF-BAIT-FS: the bait only while her flash-step is at least this (no key: always).
fn khf_bait_cells_p(m: &Match, e: Entity, b: &Brain) -> bool {
    let o = fighter(m, e).opp;
    strat_out(&m.knobs, b, "khf-bait-fs").is_none_or(|x| !Num::F(m.gauges.get(o).expect("gauges").fs).lt(x))
}

/// port: KHF-BAIT-STEP — Hisagi down or just up with the bait roll yes: hold at *KHF-BAIT-D*. T when it decided.
fn khf_bait_step(m: &mut Match, e: Entity, b: &Brain, s: &Snap, d: f32, st: &mut Khs) -> bool {
    let (ss, now) = (s.state, m.match_tick);
    let down = |x: State| matches!(x, State::Air | State::Down | State::Wakeup);
    if down(ss) && !down(st.hw) {
        st.bait = khf_bait_cells_p(m, e, b) && sroll(m, b, "khf-bait-p", |k| &k.khf_bait_p);
        if st.bait {
            crate::clog!(m, "{} khf bait armed", side_name(m, e));
        }
    }
    st.hw = ss;
    if matches!(ss, State::Down | State::Wakeup) {
        st.last = now;
    }
    if !(st.bait && free(fighter(m, e).state) && st.k.plan.is_none()) {
        return false;
    }
    if matches!(ss, State::Down | State::Wakeup) || (ss != State::Hoho && now - st.last <= b.delay + m.knobs.khf_bait_after) {
        let bd = sknob(m, b, "khf-bait-d", m.knobs.khf_bait_d);
        let toward = if d > bd + 0.15 {
            1.0
        } else if d < bd - 0.3 {
            -1.0
        } else {
            0.0
        };
        kk_stick(m, e, toward);
        true
    } else {
        st.bait = false;
        false
    }
}

/// port: KEN-KH-STYLE — Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU.
pub fn ken_kh_style(m: &mut Match, _: &mut Search, e: Entity, b: &mut Brain, s: Snap, d: f32) -> bool {
    let tick = m.match_tick;
    let st = take_style(b, |x| ken_ok(x, tick, |x| matches!(x, StyleState::Khs(_))), || StyleState::Khs(Khs::new()));
    let StyleState::Khs(mut st) = st else { unreachable!() };
    let r = if khf_bait_step(m, e, b, &s, d, &mut st) {
        st.k.tick = tick;
        true
    } else if st.bait {
        ken_ki(m, e, b, &mut st.k, s, d, Some(0.0), None) // (no meaty roll while the bait holds)
    } else {
        ken_ki(m, e, b, &mut st.k, s, d, None, None)
    };
    b.style = Some(StyleState::Khs(st));
    r
}

// ---------------------------------------------------------------- the stand-off breaker (KEN-KH-STANDOFF-STYLE)

/// port: KSO-WINNING-P — does the bell favour gauges G0 over G1 now (Konpaku, then Reishi % by more than LEAD)?
fn kso_winning_p(g0: &crate::components::Gauges, g1: &crate::components::Gauges, lead: Num) -> bool {
    g0.konpaku > g1.konpaku || (g0.konpaku == g1.konpaku && lead.lt(Num::F(reishi_frac(g0) - reishi_frac(g1))))
}

/// port: KSO-OLD-P — tick the clock (a change of the four gauges restarts it); T when the stand-off is older than *KSO-STALE* and
/// the bell is not his.
fn kso_old_p(m: &Match, e: Entity, b: &Brain, st: &mut Kso) -> bool {
    let o = fighter(m, e).opp;
    let (g0, g1) = (m.gauges.get(e).expect("gauges"), m.gauges.get(o).expect("gauges"));
    let (r0, r1, k0, k1) = (g0.reishi.f(), g1.reishi.f(), g0.konpaku, g1.konpaku); // (F32 of a fixnum, or a trial's float Reishi)
    if !(r0 == st.so_r0 && r1 == st.so_r1 && k0 == st.so_k0 && k1 == st.so_k1) {
        (st.so_r0, st.so_r1, st.so_k0, st.so_k1, st.so_at) = (r0, r1, k0, k1, m.match_tick);
    }
    let k = &m.knobs;
    let stale = style_knob(k, b, "kso-stale", k.kso_stale.get_or(b.difficulty.name(), Num::I(300)));
    stale.lt(Num::I(m.match_tick - st.so_at)) && !kso_winning_p(g0, g1, style_knob(k, b, "kso-lead", Num::F(k.kso_lead)))
}

/// port: KEN-KH-STANDOFF-STYLE — Kenpachi's stand-off breaker against Hisagi: T when it decided this step, NIL for the MCTS / the
/// generic core CPU.
pub fn ken_kh_standoff_style(m: &mut Match, _: &mut Search, e: Entity, b: &mut Brain, s: Snap, d: f32) -> bool {
    let tick = m.match_tick;
    let st = take_style(b, |x| ken_ok(x, tick, |x| matches!(x, StyleState::Kso(_))), || {
        let mut n = Kso::new();
        n.so_at = tick;
        StyleState::Kso(n)
    });
    let StyleState::Kso(mut st) = st else { unreachable!() };
    let r = if !kso_old_p(m, e, b, &mut st) {
        st.so_on = false;
        ken_ki(m, e, b, &mut st.k, s, d, None, None)
    } else {
        if !st.so_on {
            (st.so_on, st.k.appr) = (true, false); // (the approach's Hoho-safety roll is made again)
            crate::clog!(m, "{} kh stand-off breaker at {}", side_name(m, e), fmt_fixed_f32(d, 1));
        }
        ken_ki(m, e, b, &mut st.k, s, d, None, Some(0.0)) // (the Hoho-safety discipline off)
    };
    b.style = Some(StyleState::Kso(st));
    r
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::components::{Character, Difficulty};

    fn kk_battle() -> Match {
        let mut m = Match::new(crate::hashline::tests::data());
        crate::flow::go_title(&mut m);
        crate::gate::start_cvc(&mut m, 1, Some([Character::Kenpachi, Character::Kenpachi]));
        m
    }

    /// Every CLOG of cpu-ki-ken.lisp / cpu-kh-ken.lisp has exactly one Rust log site with the same text (`~a` `~d` `~,1f` -> `{}`),
    /// and each `C` tag of the plan's census that comes from these files is one of them.
    #[test]
    fn ken_c_tags_have_a_site() {
        let lisp = [include_str!("../../../../duel/lisp/cpu-ki-ken.lisp"), include_str!("../../../../duel/lisp/cpu-kh-ken.lisp")];
        let rust = include_str!("ken_ki.rs");
        let rust = &rust[..rust.find("#[cfg(test)]").unwrap()];
        let mut fmts = vec![];
        for src in lisp {
            for (i, _) in src.match_indices("(clog \"") {
                let t = &src[i + 7..];
                let t = &t[..t.find('"').unwrap()];
                fmts.push(t.replace("~,1f", "{}").replace("~a", "{}").replace("~d", "{}"));
            }
        }
        assert_eq!(fmts.len(), 28);
        for f in &fmts {
            assert_eq!(rust.matches(&format!("\"{f}\"")).count(), 1, "{f}");
        }
        let census = [
            "kh stand-off", "kk pick", "kk meaty", "kk string", "khf bait", "kk read", "kk step-dodge", "kk link", "kk awaken", "kk climb",
            "kk bankai-plan", "kk l3", "kk dodge",
        ];
        for tag in census {
            let t = format!("{{}} {tag}");
            assert!(fmts.iter().any(|f| *f == t || f.starts_with(&format!("{t} "))), "{tag}");
        }
    }

    /// KEN-KI-STYLE given another style's struct (an Ichigo IKST) takes a fresh KKS: the type test comes before KKS-TICK (Task 6's
    /// guard read KKS-TICK of any struct and panicked).
    #[test]
    fn ken_style_over_another_styles_struct() {
        let mut m = kk_battle();
        let e = m.p1;
        let mut b = Brain::new(Difficulty::Hard, 8);
        b.style = Some(StyleState::Ikst(crate::cpu::ichigo_ki::Ikst::new()));
        ken_ki_style(&mut m, &mut Search::new(), e, &mut b, Snap::default(), 3.0);
        assert!(matches!(b.style, Some(StyleState::Kks(_))));
    }

    /// The stand-off clock: *KSO-STALE* frames by difficulty with no change of the four gauges, then old unless he wins the bell; a
    /// gauge change restarts it.
    #[test]
    fn standoff_clock_by_difficulty() {
        for (dif, stale) in [(Difficulty::Easy, 900), (Difficulty::Normal, 540), (Difficulty::Hard, 120)] {
            let mut m = kk_battle();
            let (e, o) = (m.p1, m.p2);
            let b = Brain::new(dif, 8);
            let mut st = Kso::new();
            m.match_tick = 5;
            assert!(!kso_old_p(&m, e, &b, &mut st));
            assert_eq!((st.so_at, st.so_k0, st.so_r0), (5, m.gauges.get(e).unwrap().konpaku, m.gauges.get(e).unwrap().reishi.f()));
            m.match_tick = 5 + stale;
            assert!(!kso_old_p(&m, e, &b, &mut st), "{dif:?} at {stale}");
            m.match_tick = 6 + stale;
            assert!(kso_old_p(&m, e, &b, &mut st), "{dif:?} past {stale}");
            m.gauges.get_mut(o).unwrap().konpaku += 1; // (his opponent's change restarts it)
            assert!(!kso_old_p(&m, e, &b, &mut st));
            assert_eq!(st.so_at, 6 + stale);
            m.match_tick = 7 + 2 * stale;
            assert!(kso_old_p(&m, e, &b, &mut st));
            m.gauges.get_mut(e).unwrap().konpaku += 2; // (ahead at the bell: patient)
            m.match_tick = 100_000;
            assert!(!kso_old_p(&m, e, &b, &mut st));
            m.match_tick = 200_000;
            assert!(!kso_old_p(&m, e, &b, &mut st));
        }
    }

    /// One KK-PICK inside the attack zone with the approach's rolls made: both J1 and the NS reach at 1.5 m, so the one roll is the
    /// generic CPU's NS share near (*CAI-NS-NEAR*): NS under it, J1 over it; the NS draws R-KIKON after it.
    #[test]
    fn kk_pick_with_a_fixed_rnd() {
        let mut seen = [false; 2];
        for seed in [1u32, 2, 3, 0x1234_5678, 0x9e37_79b9, 0xdead_beef] {
            let mut m = kk_battle();
            m.log_on = true;
            let e = m.p1;
            let kit = kit_of(&m, e);
            let mut b = Brain::new(Difficulty::Hard, 8);
            let mut st = Kks::new();
            (st.appr, st.reach) = (true, Reach::T); // (no approach rolls: the share's is the first draw)
            m.rng.set_state(seed);
            let mut r = m.rng;
            let roll = r.rnd01();
            let after_roll = r;
            let kikon = r.rnd01();
            let pick = kk_pick(&mut m, e, &mut b, kit, &Snap::default(), 1.5, &mut st, 0.0);
            assert!(pick == Some(Pick::T) && !st.appr);
            let ns = roll < m.knobs.cai_ns_near;
            seen[ns as usize] = true;
            let line = m.log.last().unwrap();
            assert!(line.ends_with(if ns { "P1 kk pick NS at 1.5" } else { "P1 kk pick J1 at 1.5" }), "{line}");
            assert_eq!((b.press, b.press_mod, b.own_key), (Some(QUICK), ns, -1));
            assert_eq!(m.rng, if ns { r } else { after_roll });
            if ns {
                assert_eq!(b.r_kikon, kikon);
            }
        }
        assert_eq!(seen, [true, true], "both picks");
    }
}
