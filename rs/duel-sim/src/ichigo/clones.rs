//! port: ichigo.lisp's hazards — KESSA's clones 分身 (ICC, an :fx hazard with the ICHIGO-CLONE-HZ hook), their strikes and his echoes'
//! (:ic-hit hazards, ICHIGO-STRIKE-HZ), 残像's afterimages (ICE, ICHIGO-ECHO-HZ), the NS3 clones' replay of his J / AS, the Getsuga waves,
//! JUJISHO's cut, the vanish on a real hit and O's charge. An ICC is shared: the clone hazard and every strike it throws hold the same
//! struct (`Match.iccs`, `HzData::Icc(index)`). The look functions and the EMITs are looks; PACE is the gate's debug counter (not ported).
use crate::cl::{fmt_fixed_f32, max_f32, min_f32, round_f32};
use crate::components::{Cls, Contact, Few, HazardKind, HitWin, HzData, MoveId, Num, Phase, State, Sym};
use crate::ecs::Entity;
use crate::fighter::{fighter, fighter_mut, id_of, kit_of, mv, opp_of, pos_of, side_name, yaw_of};
use crate::hazards::{hazard_target, hazard_touches_p, spawn_hazard, spawn_look, HzArgs};
use crate::math::{angle_wrap, dir_yaw, fwd_x, fwd_z, hypot, turn_toward};
use crate::state::Match;
use duel_data::Move;

/// ICC-STATE.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IccState {
    Idle,
    Answer,
    Replay,
    Charge,
    Fade,
}

impl IccState {
    pub fn name(self) -> &'static str {
        match self {
            IccState::Idle => "IDLE",
            IccState::Answer => "ANSWER",
            IccState::Replay => "REPLAY",
            IccState::Charge => "CHARGE",
            IccState::Fade => "FADE",
        }
    }
}

/// ICC-SRC: what made the clone (NS3's right / left one; `:debug` is the debug commands').
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Src {
    NsA,
    NsB,
}

impl Src {
    pub fn name(self) -> &'static str {
        match self {
            Src::NsA => "NS-A",
            Src::NsB => "NS-B",
        }
    }
}

/// The answer weight of a press (CLONE-MOVE: :q a J, :f a K).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub enum Weight {
    #[default]
    Q,
    F,
}

/// port: ICC, a clone's state (slot order; printed `#ICC{…}`). `queued` holds the presses waiting for its next links (nothing pushes
/// them under the core system: the press answers left 2026-10-27); `rq` the moves of his it will replay, (tick move mult): a move
/// queued per start of his while the clone lives, taken after the clone's lag (`RQ_MAX`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Icc {
    pub state: IccState,
    pub born: i64,
    pub life: i64,
    pub fade: i64,
    pub src: Option<Src>,
    pub link: i64,
    pub mv: Option<MoveId>,
    pub sf: i64,
    pub queued: Few<Weight, 4>, // (never pushed, in the Lisp either: only POP and NIL)
    pub hit: Option<Contact>,
    pub touched: bool,
    pub rq: Few<(i64, MoveId, f32), RQ_MAX>,
    pub rmult: f32,
    pub rt: i64,
    pub sscale: f32,
}

impl Default for Icc {
    fn default() -> Self {
        Icc {
            state: IccState::Idle,
            born: 0,
            life: 0,
            fade: 0,
            src: None,
            link: 0,
            mv: None,
            sf: 0,
            queued: Few::new(),
            hit: None,
            touched: false,
            rq: Few::new(),
            rmult: 1.0,
            rt: -1,
            sscale: 1.0,
        }
    }
}

/// The most clone hazards one fighter has at once, live or fading, and the most moves a clone queues for its replay: fixed lists, more
/// panics. The Lisp's bounds: live clones <= `*clone-max*` (3, no debug command sets it), plus up to 3 charging (the O press) and the
/// fading ones (8 frames): about 8 hazards; CLONE-REPLAY-WATCH pushes at most one move per new `fighter-cls-t` (once a step) onto a live
/// NS3 clone and ICHIGO-CLONE-STEP takes one each step once its lag (`*clone-replay-lags*`: 4 / 8) has run, so `rq` <= lag + 1 = 9. The
/// 15 cvc gate traces, live: at most 3 clones and 1 queued move (M2_NOTES §9). A larger lag or clone max must re-derive these.
pub const CLONES_MAX: usize = 16;
pub const RQ_MAX: usize = 16;
/// A fighter's clone hazards (ICHIGO-CLONES' list), oldest first.
pub type Clones = Few<Entity, CLONES_MAX>;

const CLONE_HZ: &str = "ICHIGO-CLONE-HZ";
const STRIKE_HZ: &str = "ICHIGO-STRIKE-HZ";
const ECHO_HZ: &str = "ICHIGO-ECHO-HZ";
const ECHO: Sym = Sym(":ECHO");

fn icc(m: &Match, i: usize) -> &Icc {
    &m.iccs[i]
}
fn icc_mut(m: &mut Match, i: usize) -> &mut Icc {
    &mut m.iccs[i]
}
/// The clone index of hazard H's data, if it is an ICC (a clone or one of its strikes).
fn icc_of(m: &Match, h: Entity) -> Option<usize> {
    match m.hazard_of(h)?.data {
        HzData::Icc(i) => Some(i),
        _ => None,
    }
}

// ---------------------------------------------------------------- pure rules

/// port: CLONE-KONPAKU: the Kikon's Konpaku with N clones at the O press, `(nth (max 0 (min 3 n)) table)` (TABLE: *CLONE-KONPAKU*).
pub fn clone_konpaku(table: &[i64], n: i64) -> i64 {
    table[n.clamp(0, 3) as usize]
}

/// port: CLONE-MOVE: the clone's move for WEIGHT at LINK (3: the ender's).
pub fn clone_move(m: &Match, weight: Weight, link: i64) -> MoveId {
    let n = match (weight, link == 3) {
        (Weight::Q, true) => "ic-c-heavy3",
        (Weight::Q, false) => "ic-c-heavy",
        (Weight::F, true) => "ic-c-light3",
        (Weight::F, false) => "ic-c-light",
    };
    id_of(m, crate::kit::find_move(m.data, n).expect("a clone move"))
}

/// port: CLONE-AFTER-STRING: a clone's string ended: fade when it touched him or its time is up, else idle.
pub fn clone_after_string(touched: bool, life: i64) -> IccState {
    if touched || life <= 0 { IccState::Fade } else { IccState::Idle }
}

/// port: CLONE-VANISH-P: a hit on Ichigo with result RES clears his clones (a real hit, not a block).
pub fn clone_vanish_p(res: Option<crate::rules::Res>) -> bool {
    crate::rules::contact_of(res) == Some(Contact::Hit)
}

/// port: CLONE-EVICT: making one more clone with live clones born at BORNS: the index of the one to replace (the oldest) at the cap.
pub fn clone_evict(borns: &[i64], max: i64) -> Option<usize> {
    if (borns.len() as i64) < max {
        return None;
    }
    let lo = *borns.iter().min()?;
    borns.iter().position(|&b| b == lo)
}

/// A data hit-window flag (`"ranged"`) as its keyword: every flag APPLY-HIT's `flag_bits` knows (any other panics there too).
fn flag_sym(f: &str) -> Sym {
    Sym(match f {
        "breaker" => ":BREAKER",
        "guard-crush" => ":GUARD-CRUSH",
        "unguardable" => ":UNGUARDABLE",
        "rend" => ":REND",
        "flat" => ":FLAT",
        "unscaled" => ":UNSCALED",
        "keep-bind" => ":KEEP-BIND",
        "spare" => ":SPARE",
        "ranged" => ":RANGED",
        "ender" => ":ENDER",
        "no-close" => ":NO-CLOSE",
        "parry" => ":PARRY",
        "ranged-ward" => ":RANGED-WARD",
        "stance" => ":STANCE",
        "step-branch" => ":STEP-BRANCH",
        "through" => ":THROUGH",
        "ice" => ":ICE",
        "blade" => ":BLADE",
        "thread" => ":THREAD",
        x => panic!("a hit window flag ECHO-HITWIN does not know: {x}"),
    })
}

/// port: ECHO-HITWIN: a copy of hit HW at MULT of its damage and guard value, with a blade's hit look (:blade adjoined: in front).
pub fn echo_hitwin(hw: &duel_data::HitWin, mult: f32) -> HitWin {
    assert!(hw.seg.is_none(), "a :seg-fn window copied (Hisagi's, M4)");
    let mut flags: Few<Sym, 4> = hw.flags.iter().map(|f| flag_sym(f)).collect();
    if !hw.flags.iter().any(|f| f == "blade") {
        flags.insert(0, Sym(":BLADE"));
    }
    HitWin {
        from: hw.from as i64,
        to: hw.to as i64,
        dmg: 1.max(round_f32(mult * hw.dmg as f32)),
        vols: hw.vols.iter().copied().collect(),
        react: Phase::from_name(&hw.react).unwrap_or_else(|| panic!("a react {}", hw.react)),
        kb: hw.kb,
        hs: hw.hs as i64,
        chip: hw.chip,
        stun: hw.stun.map(i64::from),
        guard: hw.guard.map(|g| Num::F(mult * g as f32)),
        seg: None,
        min: hw.min,
        steal: hw.steal.map(i64::from),
        flags,
    }
}

// ---------------------------------------------------------------- the clones

/// port: CLONE-P: is hazard HZ a clone (not one of its strikes, whose data is its clone too)?
pub fn clone_p(hz: &crate::components::Hazard) -> bool {
    hz.hook.is_some_and(|s| s.0 == CLONE_HZ) && matches!(hz.data, HzData::Icc(_))
}

/// port: ICHIGO-CLONES: E's clone hazards, oldest first (the Lisp's PUSHed list, in reverse slot order, stably sorted by birth).
pub fn ichigo_clones(m: &mut Match, e: Entity) -> Clones {
    let mut out = Clones::new();
    m.do_entities(|m, h| m.hazard.has(h), |m, h| {
        let hz = m.hazard.get(h).unwrap();
        if hz.owner == e && clone_p(hz) {
            out.push(h);
        }
    });
    out.reverse();
    out.sort_by_key(|&h| icc(m, icc_of(m, h).unwrap()).born);
    out
}

/// port: CLONE-LIVE-P.
pub fn clone_live_p(c: &Icc) -> bool {
    matches!(c.state, IccState::Idle | IccState::Answer | IccState::Replay)
}

/// port: CLONE-COUNT: E's live clones.
pub fn clone_count(m: &mut Match, e: Entity) -> i64 {
    live_clones(m, e).len() as i64
}

/// port: ICHIGO-LIVE-CLONES: E's live clone hazards, oldest first.
pub fn live_clones(m: &mut Match, e: Entity) -> Clones {
    let mut v = ichigo_clones(m, e);
    v.retain(|&h| clone_live_p(icc(m, icc_of(m, h).unwrap())));
    v
}

fn clone_fade(c: &mut Icc) {
    (c.state, c.fade) = (IccState::Fade, 0);
}

/// port: ICHIGO-CLONE-SPAWN: a clone at (X Z) facing the opponent; at the cap the oldest live one fades out. Its ICC's index.
pub fn clone_spawn(m: &mut Match, e: Entity, x: f32, z: f32, src: Src) -> usize {
    let live = live_clones(m, e);
    let borns: Few<i64, CLONES_MAX> = live.iter().map(|&h| icc(m, icc_of(m, h).unwrap()).born).collect();
    let i = clone_evict(&borns, m.knobs.clone_max);
    let q = pos_of(m, opp_of(m, e));
    if let Some(i) = i {
        let c = icc_of(m, live[i]).unwrap();
        clone_fade(icc_mut(m, c)); // pace: :clone-evicted
    }
    m.iccs.push(Icc { born: m.match_tick, life: m.knobs.clone_life, src: Some(src), ..Icc::default() });
    let c = m.iccs.len() - 1;
    let args = HzArgs {
        x,
        z,
        yaw: dir_yaw(q[0] - x, q[2] - z),
        size: 0.5,
        life: 99999,
        look: Some(Sym("ICHIGO-CLONE-LOOK")),
        hook: Some(Sym(CLONE_HZ)),
        data: HzData::Icc(c),
        ..HzArgs::default()
    };
    spawn_hazard(m, HazardKind::Fx, e, args);
    m.emit(crate::look::Event::Sfx { key: "clone", e }); // look: emit :sfx :clone
    crate::clog!(m, "{} CLONE {} {}", side_name(m, e), src.name(), 1 + live.len() as i64 - i.map_or(0, |_| 1));
    c
}

/// port: ICHIGO-NS-CLONE-P: one of NS3's clones (it stays after a string, until its life is out)?
pub fn ns_clone_p(c: &Icc) -> bool {
    c.src.is_some()
}

/// port: ICHIGO-NS-SLOT: values x z of an NS3 clone's place at fighter-frame (PX PZ YAW): 0.5 m ahead and 1.1 m to SIDE (1 his right, -1
/// his left), inside the arena.
pub fn ns_slot(m: &Match, side: i64, px: f32, pz: f32, yaw: f32) -> (f32, f32) {
    let (s, c) = crate::math::sincosf(yaw); // (FWD-X / FWD-Z of one yaw: gcc's fused sincosf)
    let (fx, fz) = (-s, -c);
    let s = side as f32 * 1.1;
    crate::rules::clamp_to_circle(px + 0.5 * fx + s * -fz, pz + 0.5 * fz + s * fx, m.knobs.arena_radius - 0.4)
}

/// port: ICHIGO-NS-CLONE: NS3's clone at its place, swinging forward at once (the light answer, no lag), its summon segment's SP scale.
pub fn ns_clone(m: &mut Match, e: Entity, side: i64, src: Src) -> usize {
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    let (x, z) = ns_slot(m, side, p[0], p[2], yaw);
    let c = clone_spawn(m, e, x, z, src);
    clone_link(m, c, Weight::F, 1);
    let f = fighter(m, e);
    let sscale = crate::sp::sp_scale(f.sp_paid, f.sp_cost);
    let cc = icc_mut(m, c);
    (cc.sf, cc.sscale) = (0, sscale);
    c
}

/// port: ICHIGO-NS-CLONE-X: NS3's third press: both NS clones cut inward into an X; one gone is made again where it stood.
pub fn ns_clone_x(m: &mut Match, e: Entity) {
    for (src, side, name) in [(Src::NsA, 1, "ic-c-xa"), (Src::NsB, -1, "ic-c-xb")] {
        let live = live_clones(m, e);
        let found = live.iter().map(|&h| icc_of(m, h).unwrap()).find(|&c| icc(m, c).src == Some(src));
        let c = match found {
            Some(c) => c,
            None => ns_clone(m, e, side, src),
        };
        let x = id_of(m, crate::kit::find_move(m.data, name).expect("the X's move"));
        let cc = icc_mut(m, c);
        (cc.state, cc.mv, cc.link, cc.sf, cc.hit, cc.touched) = (IccState::Answer, Some(x), 3, -2, None, false);
        cc.queued.clear();
    }
}

/// port: ICHIGO-NS-X-MARK: the X's black mark where the two cuts cross (a look hazard).
pub fn ns_x_mark(m: &mut Match, e: Entity) {
    let (x, z) = ahead(m, e, 1.9);
    let yaw = yaw_of(m, e);
    spawn_look(m, e, Sym("ICHIGO-KX-LOOK"), Some(x), Some(z), yaw, 1.4, 18, 0, HzData::Nil);
}

/// port: CLONE-LINK: clone C starts answer LINK with WEIGHT (link 1 after the lag).
pub fn clone_link(m: &mut Match, c: usize, weight: Weight, link: i64) {
    let mv = clone_move(m, weight, link);
    let lag = m.knobs.clone_lag;
    let cc = icc_mut(m, c);
    (cc.state, cc.mv, cc.link, cc.sf, cc.hit) = (IccState::Answer, Some(mv), link, if link == 1 { -lag } else { 0 }, None);
    if link == 1 {
        cc.touched = false;
        cc.queued.clear();
    }
}

/// port: AHEAD: values x z of the point D metres in front of fighter E.
pub fn ahead(m: &Match, e: Entity, d: f32) -> (f32, f32) {
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    (p[0] + d * fwd_x(yaw), p[2] + d * fwd_z(yaw))
}

/// A strike's triangle keys (ICHIGO-STRIKE's SP): `None` = `'(:cls nil)` (classless, a clean hit); `Answer(cls)` = `(:cls cls)`, the rest
/// defaulted; `Replay(..)` = CLONE-REPLAY-SP's four keys.
#[derive(Clone, Copy, Debug)]
pub enum StrikeSp {
    None,
    Answer(Option<Cls>),
    Replay { cls: Option<Cls>, scale: f32, src: i64 },
}

/// port: ICHIGO-STRIKE: a clone's / an echo's hit: an :ic-hit hazard with HW at MULT (ECHO-HITWIN) in the frame (X Z YAW), for its active
/// frames; guarded facing Ichigo (:src); a hazard: no KOSEI, it counts in his combo.
#[allow(clippy::too_many_arguments)]
pub fn strike(m: &mut Match, e: Entity, x: f32, z: f32, yaw: f32, hw: &duel_data::HitWin, mult: f32, data: HzData, sp: StrikeSp) {
    let mut a = HzArgs {
        x,
        z,
        yaw,
        size: 0.5,
        life: 1.max((hw.to - hw.from) as i64),
        hw: Some(echo_hitwin(hw, mult)),
        src: true,
        hook: Some(Sym(STRIKE_HZ)),
        sp: Some(data == HzData::Kw(ECHO)), // (ZANZO's echoes ignore the combo scaling)
        data,
        ..HzArgs::default()
    };
    match sp {
        StrikeSp::None => a.cls = Some(None),
        StrikeSp::Answer(c) => a.cls = Some(c),
        StrikeSp::Replay { cls, scale, src } => {
            (a.cls, a.sp_paid, a.sp_scale, a.sp_src) = (Some(cls), Some(0.0), Some(scale), Some(src));
        }
    }
    spawn_hazard(m, HazardKind::IcHit, e, a);
}

/// port: ICHIGO-STRIKE-HZ's :touches: the volume is the hit window's own, in the frame it was struck in.
pub fn strike_touches(m: &Match, h: Entity, tx: f32, ty: f32, tz: f32, tr: f32, th: f32) -> bool {
    let hz = m.hazard.get(h).unwrap();
    let v = hz.hw.as_ref().and_then(|w| w.vols.first()).expect("a strike's volume");
    crate::hitvol::vol_hit_p(v, hz.x, 0.0, hz.z, fwd_x(hz.yaw), fwd_z(hz.yaw), tx, ty, tz, tr, th, 0.0)
}

/// port: CLONE-ANSWER-CLS: the class an answering clone's cut is judged as: E's classed move now, or NIL.
fn clone_answer_cls(m: &Match, e: Entity) -> Option<Cls> {
    let f = fighter(m, e);
    if f.state == State::Move { f.cls } else { None }
}

/// port: ICHIGO-THREAT (KESSA's :threat, PRACTICE's GUARD ALL dummy O): the soonest classed cut of E's clones still to come within its
/// move's edge + SLACK m of O: (frames, class), or None.
pub fn threat(m: &mut Match, e: Entity, o: Entity, slack: f32) -> Option<(i64, Cls)> {
    let (mut best, mut cls) = (None::<i64>, None);
    let q = pos_of(m, o);
    for h in live_clones(m, e) {
        let hz = m.hazard.get(h).unwrap();
        let c = icc(m, icc_of(m, h).unwrap());
        let mvd = mv(m, c.mv.expect("a live clone's move"));
        let sf = c.sf;
        let k = match c.state {
            IccState::Answer => (sf < mvd.s as i64).then(|| mvd.s as i64 - sf),
            IccState::Replay => mvd.hits.iter().filter(|w| w.from as i64 > sf).map(|w| w.from as i64 - sf).min().filter(|&k| k > 0),
            _ => None,
        };
        let kc = if c.state == IccState::Replay {
            crate::kit::kit_class(kit_of(m, e), Some(mvd)).map(Cls::from)
        } else {
            clone_answer_cls(m, e)
        };
        if let (Some(k), Some(kc)) = (k, kc)
            && best.is_none_or(|b| k < b)
            && hypot(q[0] - hz.x, q[2] - hz.z) <= crate::kit::move_edge(mvd) + slack
        {
            (best, cls) = (Some(k), Some(kc));
        }
    }
    best.zip(cls)
}

/// port: CLONE-ANSWER-STEP: an answering clone, one frame: the lag; its hit, struck where it stands; its next link once the chain opens;
/// at the string's end it fades if it touched him, else it idles (NS3's stay for the J / AS to come).
fn clone_answer_step(m: &mut Match, e: Entity, h: Entity, c: usize) {
    let mvd = mv(m, icc(m, c).mv.expect("an answer's move"));
    icc_mut(m, c).sf += 1;
    let (sf, s, a, r) = (icc(m, c).sf, mvd.s as i64, mvd.a as i64, mvd.r as i64);
    if sf < s {
        return;
    }
    if sf == s {
        let hz = m.hazard.get(h).unwrap();
        let (x, z, yaw) = (hz.x, hz.z, hz.yaw);
        let cls = clone_answer_cls(m, e);
        let scale = m.knobs.clone_scale;
        strike(m, e, x, z, yaw, &mvd.hits[0], scale, HzData::Icc(c), StrikeSp::Answer(cls));
        m.emit(crate::look::Event::Sfx { key: "whoosh-heavy", e }); // look: emit :sfx :whoosh-heavy
    }
    let cc = icc(m, c);
    let contact = cc.hit.or(cc.touched.then_some(Contact::Block)); // ((or hit touched): a T takes the block timing)
    if !cc.queued.is_empty() && cc.link < 3 && crate::rules::chain_open_p(&m.knobs, sf, s, a, r, contact) {
        let l = cc.link + 1;
        let w = icc_mut(m, c).queued.remove(0);
        clone_link(m, c, w, l);
    } else if sf >= s + a + r {
        // pace: :clone-whiff-strings
        let cc = icc(m, c);
        if clone_after_string(cc.touched, cc.life) == IccState::Fade && !(ns_clone_p(cc) && cc.life > 0) {
            clone_fade(icc_mut(m, c));
        } else {
            let cc = icc_mut(m, c);
            cc.state = IccState::Idle;
            cc.queued.clear();
        }
    }
}

// ---------------------------------------------------------------- the core system's replay

/// port: CLONE-REPLAY-WATCH: a J or an AS of E's (not AS3, not a Kikon's dash-in strike; an NS of a temporary route, not NS3) has just
/// started: queue it on every live NS3 clone, with its x.
pub fn clone_replay_watch(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let Some(id) = f.mv.filter(|_| f.state == State::Move) else { return };
    if f.cls_t == ics(m, e).rseen {
        return;
    }
    let t = f.cls_t;
    m.ics.get_mut(e).unwrap().rseen = t;
    let f = fighter(m, e);
    let mvd = mv(m, id);
    let kit = kit_of(m, e);
    let not_in = |names: &Vec<String>| {
        let third = names.get(2).expect("a third route");
        !crate::kit::core_segments_iter(m.data, third).any(|x| x == mvd.name)
    };
    let replay = !f.follow
        && ((matches!(f.cls, Some(Cls::Na | Cls::As)) && not_in(&kit.core.as_segs))
            || (f.cls == Some(Cls::Ns) && f.tmp > 0 && not_in(&kit.core.ns)));
    if !replay {
        return;
    }
    let mult = m.knobs.clone_replay_scale * crate::core_sim::core_charge_mult(f, Some(mvd), true, false);
    for h in live_clones(m, e) {
        let c = icc_of(m, h).unwrap();
        if ns_clone_p(icc(m, c)) {
            icc_mut(m, c).rq.push((t, id, mult));
        }
    }
}

/// port: CLONE-REPLAY-LAG: `(getf *clone-replay-lags* (icc-src c) 4)`.
fn clone_replay_lag(m: &Match, c: &Icc) -> i64 {
    c.src.map_or(4, |s| m.knobs.clone_replay_lags.get(s.name(), 4))
}

/// port: CLONE-REPLAY-NEXT: the queued move whose time has come: C plays it from its frame 0 (the :enter frame his started on).
fn clone_replay_next(m: &mut Match, c: usize) {
    let cc = icc(m, c);
    let Some(&(tick, id, mult)) = cc.rq.first() else { return };
    if m.match_tick < tick + clone_replay_lag(m, cc) {
        return;
    }
    let enter = mv(m, id).enter as i64;
    let cc = icc_mut(m, c);
    cc.rq.remove(0);
    (cc.state, cc.mv, cc.rmult, cc.rt, cc.sf, cc.hit) = (IccState::Replay, Some(id), mult, tick, enter - 1, None);
    let src = cc.src.map_or("NIL", Src::name);
    crate::clog!(m, "clone {} replays {} x{}", src, mv(m, id).name.to_uppercase(), fmt_fixed_f32(mult, 2));
}

/// port: CLONE-REPLAY-SP: the triangle keys of clone C's replayed hits and waves.
fn clone_replay_sp(m: &Match, e: Entity, c: usize) -> StrikeSp {
    let cc = icc(m, c);
    let cls = crate::kit::kit_class(kit_of(m, e), cc.mv.map(|id| mv(m, id))).map(Cls::from);
    StrikeSp::Replay { cls, scale: cc.sscale, src: cc.rt }
}

/// port: CLONE-WAVE: a clone's replay of his wave (MV's :params, as ICHIGO-WAVE) from (X Z) facing YAW, at MULT; never a Kikon's first
/// strike.
#[allow(clippy::too_many_arguments)]
fn clone_wave(m: &mut Match, e: Entity, x: f32, z: f32, yaw: f32, mvd: &'static Move, mult: f32, sp: StrikeSp) {
    let p = &mvd.params;
    let (s, c) = crate::math::sincosf(yaw); // (FWD-X / FWD-Z of one yaw: gcc's fused sincosf)
    let (fx, fz) = (-s, -c);
    let (speed, range) = (p.speed.expect(":speed"), p.range.expect(":range"));
    let hw = HitWin {
        from: 0,
        to: 0,
        dmg: 1.max(round_f32(mult * p.dmg.expect(":dmg") as f32)),
        vols: Few::new(),
        react: Phase::from_name(p.react.as_deref().expect(":react")).expect("a react"),
        kb: p.kb.expect(":kb"),
        hs: m.knobs.hitstop_heavy,
        chip: None,
        stun: None,
        guard: Some(Num::F(mult * p.guard.expect(":guard") as f32)),
        seg: None,
        min: None,
        steal: None,
        flags: [Sym(":BLADE")].into_iter().collect(),
    };
    let mut a = HzArgs {
        x: x + fx,
        z: z + fz,
        yaw,
        speed,
        size: 0.5 * p.width.expect(":width"),
        life: round_f32(60.0 * (range / speed)),
        look: p.look.as_deref().map(Sym),
        sp_mv: Some(None),
        hw: Some(hw),
        ..HzArgs::default()
    };
    if let StrikeSp::Replay { cls, scale, src } = sp {
        (a.cls, a.sp_paid, a.sp_scale, a.sp_src) = (Some(cls), Some(0.0), Some(scale), Some(src));
    }
    spawn_hazard(m, HazardKind::Wave, e, a);
    m.emit(crate::look::Event::Sfx { key: "getsuga", e }); // look: emit :sfx :getsuga
}

/// port: CLONE-REPLAY-STEP: a replaying clone, one frame: where he stood its lag ago, at its side, facing the opponent; each hit window of
/// his move and each wave of it on his frames, at its x; the move over, it idles.
fn clone_replay_step(m: &mut Match, e: Entity, h: Entity, c: usize) {
    let mvd = mv(m, icc(m, c).mv.expect("a replay's move"));
    icc_mut(m, c).sf += 1;
    let cc = icc(m, c);
    let (sf, mult, lag, side) = (cc.sf, cc.rmult, clone_replay_lag(m, cc), if cc.src == Some(Src::NsA) { 1 } else { -1 });
    let (hx, hzz, hyaw) = hist_at(ics(m, e), lag);
    let (x, z) = ns_slot(m, side, hx, hzz, hyaw);
    let q = pos_of(m, opp_of(m, e));
    let yaw = dir_yaw(q[0] - x, q[2] - z);
    let hz = m.hazard.get_mut(h).unwrap();
    (hz.x, hz.z, hz.yaw) = (x, z, yaw);
    for w in mvd.hits.iter().filter(|w| w.from as i64 == sf) {
        let sp = clone_replay_sp(m, e, c);
        strike(m, e, x, z, yaw, w, mult, HzData::Icc(c), sp);
    }
    for x0 in &mvd.on_frame {
        let (fr, name) = (x0[0].as_f32().expect("a frame") as i64, x0[1].as_str().expect("a hook"));
        if fr == sf && (name == "ICHIGO-GETSUGA" || name == "ICHIGO-JUJI") {
            let sp = clone_replay_sp(m, e, c);
            clone_wave(m, e, x, z, yaw, mvd, mult, sp);
        }
    }
    if sf >= crate::kit::mv_total(mvd) {
        icc_mut(m, c).state = IccState::Idle;
    }
}

/// port: CLONE-REPLAY-HIT!: a replayed hit of clone C landed on DEF: his move's effects at its x (an AS's flash-step steal, the chain's
/// pull to the clone).
pub fn clone_replay_hit(m: &mut Match, att: Entity, def: Entity, c: usize) {
    let cc = icc(m, c);
    let (id, mult) = (cc.mv.expect("a replay's move"), cc.rmult);
    let mvd = mv(m, id);
    if crate::kit::kit_class(kit_of(m, att), Some(mvd)) == Some(duel_data::MoveClass::As) {
        crate::core_sim::core_on_hit(m, att, def, id, mult, None);
    }
    if let Some(pull) = mvd.params.pull
        && mvd.on_land.as_deref() == Some("ICHIGO-PULL")
        && let Some(h) = ichigo_clones(m, att).into_iter().find(|&h| icc_of(m, h) == Some(c))
    {
        let (hz, q) = (m.hazard.get(h).unwrap(), pos_of(m, def));
        let (dx, dz) = (hz.x - q[0], hz.z - q[2]);
        let d = hypot(dx, dz);
        if d > pull {
            crate::fighter::set_slide(m, def, mult * (d - pull), 10, dx, dz);
        }
    }
}

// ---------------------------------------------------------------- the clone's own step

/// port: ICHIGO-CLONE-HZ (:step: T, the generic step skipped) / ICHIGO-CLONE-STEP: its life, its facing, and its state: :idle,
/// :answer, :replay, :charge (runs at him at <= 40 m/s, bursts on O's strike frame or when the rush is over), :fade (8 f).
pub fn clone_hz_step(m: &mut Match, h: Entity) {
    let hz = m.hazard.get(h).unwrap();
    let (e, o) = (hz.owner, hazard_target(m, hz));
    let c = icc_of(m, h).unwrap();
    let Some(o) = o.filter(|&o| m.ents.alive(e) && m.ents.alive(o)) else {
        m.destroy(h);
        return;
    };
    m.hazard.get_mut(h).unwrap().age += 1;
    icc_mut(m, c).life -= 1;
    let q = pos_of(m, o);
    let hz = m.hazard.get(h).unwrap();
    let (dx, dz) = (q[0] - hz.x, q[2] - hz.z);
    let d = hypot(dx, dz);
    if icc(m, c).state != IccState::Fade {
        let ts = crate::rules::track_step(720.0);
        let hz = m.hazard.get_mut(h).unwrap();
        hz.yaw = angle_wrap(turn_toward(hz.yaw, dir_yaw(dx, dz), ts));
    }
    if !icc(m, c).rq.is_empty() && clone_live_p(icc(m, c)) {
        clone_replay_next(m, c);
    }
    match icc(m, c).state {
        IccState::Replay => clone_replay_step(m, e, h, c),
        IccState::Idle => {
            if icc(m, c).life <= 0 {
                clone_fade(icc_mut(m, c)); // pace: :clone-expired
            } else if fighter(m, e).state != State::Move && icc(m, c).rq.is_empty() {
                clone_fade(icc_mut(m, c)); // his attack is over: gone
            }
        }
        IccState::Answer => clone_answer_step(m, e, h, c),
        IccState::Charge => {
            let s = min_f32(40.0 * crate::time::STEP, max_f32(0.0, d - 1.0));
            if d > 0.01 {
                let hz = m.hazard.get_mut(h).unwrap();
                (hz.x, hz.z) = (hz.x + s * (dx / d), hz.z + s * (dz / d));
            }
            let f = fighter(m, e);
            let rush = f.state == State::Move
                && f.mv.is_some_and(|id| {
                    let x = mv(m, id);
                    x.kind == "kikon"
                        && (matches!(f.phase, Some(Phase::Aura | Phase::Dash)) || (f.phase == Some(Phase::Main) && f.sf < x.s as i64))
                });
            if !rush {
                clone_burst(m, e, h);
                m.destroy(h);
            }
        }
        IccState::Fade => {
            icc_mut(m, c).fade += 1;
            if icc(m, c).fade >= 8 {
                m.destroy(h);
            }
        }
    }
}

/// port: CLONE-BURST: a charging clone bursts on O's strike frame (a look hazard).
fn clone_burst(m: &mut Match, e: Entity, h: Entity) {
    let hz = m.hazard.get(h).unwrap();
    let (x, z) = (hz.x, hz.z);
    spawn_look(m, e, Sym("ICHIGO-BURST-LOOK"), Some(x), Some(z), 0.0, 1.0, 16, 0, HzData::Nil);
    m.emit(crate::look::Event::Sfx { key: "clone", e }); // look: emit :sfx :clone
}

/// port: ICHIGO-VANISH: E was really hit: every clone, afterimage and their hits in the air vanish (a puff where each clone stood).
pub fn vanish(m: &mut Match, e: Entity) {
    let mut at = Few::<(f32, f32), CLONES_MAX>::new();
    m.do_entities(|m, h| m.hazard.has(h), |m, h| {
        let hz = m.hazard.get(h).unwrap();
        if hz.owner == e && (clone_p(hz) || matches!(hz.data, HzData::Ice { .. }) || hz.kind == Some(HazardKind::IcHit)) {
            if clone_p(hz) {
                at.push((hz.x, hz.z));
            }
            m.destroy(h);
        }
    });
    for &(x, z) in at.iter().rev() {
        // ((push … at) then DOLIST: newest first)
        spawn_look(m, e, Sym("ICHIGO-BURST-LOOK"), Some(x), Some(z), 0.0, 0.6, 12, 0, HzData::Nil);
    }
    if !at.is_empty() {
        crate::clog!(m, "{} CLONES GONE {}", side_name(m, e), at.len()); // pace: :clones-vanished
    }
}

/// port: ICHIGO-O-PRESS: O pressed: N = the live clones; they all charge; the strike gains *CLONE-BURST-DMG* x N; the Kikon is worth
/// CLONE-KONPAKU N.
pub fn o_press(m: &mut Match, e: Entity) {
    let mut n = 0;
    for h in ichigo_clones(m, e) {
        let c = icc_mut(m, icc_of(m, h).unwrap());
        if clone_live_p(c) {
            n += 1;
            c.state = IccState::Charge;
        }
    }
    // pace: O-RED / O-POKE n
    let (bonus, tick, worth) = (n * m.knobs.clone_burst_dmg, m.match_tick, clone_konpaku(&m.knobs.clone_konpaku.0, n));
    let f = fighter_mut(m, e);
    (f.kikon_n, f.dmg_bonus) = (worth, bonus);
    let st = m.ics.get_mut(e).unwrap();
    (st.o_at, st.o_n) = (tick, n);
    crate::clog!(m, "{} KAGE-UCHI clones {} konpaku {}", side_name(m, e), n, worth);
}

// ---------------------------------------------------------------- 残像 ZANZO, the afterimages

/// port: ZANZO-P: is E's afterimage state on (its look-only timer hazard)?
pub fn zanzo_p(m: &Match, e: Entity) -> bool {
    m.hazard.iter().any(|(_, hz)| hz.owner == e && hz.look.is_some_and(|l| l.0 == "ICHIGO-ZANZO-LOOK"))
}

/// port: ICHIGO-ZANZO-ON: ZANZO f12: the state for *ZANZO-LIFE* frames.
pub fn zanzo_on(m: &mut Match, e: Entity) {
    let life = m.knobs.zanzo_life;
    spawn_look(m, e, Sym("ICHIGO-ZANZO-LOOK"), None, None, 0.0, 1.0, life, 0, HzData::Nil);
    m.emit(crate::look::Event::Sfx { key: "clone", e }); // look: emit :sfx :clone
    crate::clog!(m, "{} ZANZO", side_name(m, e));
}

/// ICS of E (attached by ICHIGO-TICK's IC on his first step).
pub fn ics(m: &Match, e: Entity) -> &crate::components::Ics {
    m.ics.get(e).expect("Ichigo's ICS")
}

/// port: HIST-PUSH: his place and facing into the 16-step ring.
pub fn hist_push(m: &mut Match, e: Entity) {
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    let st = m.ics.get_mut(e).unwrap();
    st.hist_i = (st.hist_i + 1).rem_euclid(16);
    let i = 3 * st.hist_i as usize;
    st.hist[i..i + 3].copy_from_slice(&[p[0], p[2], yaw]);
}

/// port: HIST-AT: values x z yaw of Ichigo LAG steps ago (at most 15).
pub fn hist_at(st: &crate::components::Ics, lag: i64) -> (f32, f32, f32) {
    let i = 3 * (st.hist_i - lag.min(15)).rem_euclid(16) as usize;
    (st.hist[i], st.hist[i + 1], st.hist[i + 2])
}

/// port: ECHO-WATCH: a new attack of E's (a move with hits, not the Breaker; a Kikon rush at its strike) while ZANZO is on: its echo.
pub fn echo_watch(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let mvid = crate::fighter::current_move(f);
    let main = mvid.is_some() && f.phase == Some(Phase::Main);
    let st = ics(m, e);
    if mvid == st.seen && main == st.seen_main {
        return;
    }
    let st = m.ics.get_mut(e).unwrap();
    (st.seen, st.seen_main) = (mvid, main);
    let Some(id) = mvid.filter(|_| main) else { return };
    let mvd = mv(m, id);
    if mvd.hits.is_empty() || mvd.kind == "breaker" || !zanzo_p(m, e) {
        return;
    }
    let (p, yaw, sf) = (pos_of(m, e), yaw_of(m, e), fighter(m, e).sf);
    let data = HzData::Ice { mv: id, sf: sf - m.knobs.zanzo_lag, end: crate::kit::mv_total(mvd) };
    let args = HzArgs {
        x: p[0],
        z: p[2],
        yaw,
        size: 0.5,
        life: 99999,
        look: Some(Sym("ICHIGO-ECHO-LOOK")),
        hook: Some(Sym(ECHO_HZ)),
        data,
        ..HzArgs::default()
    };
    spawn_hazard(m, HazardKind::Fx, e, args);
}

/// port: ICHIGO-ECHO-HZ (:step: T): an afterimage replays his move *ZANZO-LAG* frames behind, where he stood then, and strikes each of
/// its hit windows at *ZANZO-MULT*.
pub fn echo_hz_step(m: &mut Match, h: Entity) {
    let hz = m.hazard.get_mut(h).unwrap();
    let e = hz.owner;
    let HzData::Ice { mv: id, sf, end } = &mut hz.data else { panic!("ICHIGO-ECHO-HZ's data") };
    *sf += 1;
    let (id, sf, end) = (*id, *sf, *end);
    hz.age += 1;
    if !m.ents.alive(e) || sf >= end {
        m.destroy(h);
        return;
    }
    let (x, z, yaw) = hist_at(ics(m, e), m.knobs.zanzo_lag);
    let hz = m.hazard.get_mut(h).unwrap();
    (hz.x, hz.z, hz.yaw) = (x, z, yaw);
    let mult = m.knobs.zanzo_mult;
    for w in mv(m, id).hits.iter().filter(|w| w.from as i64 == sf) {
        strike(m, e, x, z, yaw, w, mult, HzData::Kw(ECHO), StrikeSp::None);
    }
}

// ---------------------------------------------------------------- waves and the cut

/// port: ICHIGO-WAVE: a crescent :wave from the move's :params, 1 m in front of E facing his yaw, drawn by LOOK; a blade's hit.
pub fn wave(m: &mut Match, e: Entity, look: Sym) {
    let p = crate::ichigo::hooks::move_param(m, e);
    let speed = p.speed.expect(":speed");
    let (x, z) = ahead(m, e, 1.0);
    let hw = HitWin {
        from: 0,
        to: 0,
        dmg: p.dmg.expect(":dmg") as i64,
        vols: Few::new(),
        react: Phase::from_name(p.react.as_deref().expect(":react")).expect("a react"),
        kb: p.kb.expect(":kb"),
        hs: m.knobs.hitstop_heavy,
        chip: None,
        stun: None,
        guard: p.guard.map(|g| Num::I(g as i64)),
        seg: None,
        min: None,
        steal: None,
        flags: [Sym(":BLADE")].into_iter().collect(),
    };
    let args = HzArgs {
        x,
        z,
        yaw: yaw_of(m, e),
        speed,
        size: 0.5 * p.width.expect(":width"),
        life: round_f32(60.0 * (p.range.expect(":range") / speed)),
        look: Some(look),
        hw: Some(hw),
        ..HzArgs::default()
    };
    spawn_hazard(m, HazardKind::Wave, e, args);
}

/// port: ICHIGO-CUT: JUJISHO's cross wave CUTS every opponent wave it touches.
pub fn cut(m: &mut Match, e: Entity) {
    m.do_entities(|m, h| m.hazard.has(h), |m, h| {
        let hz = m.hazard.get(h).unwrap();
        if !(hz.owner == e && hz.look.is_some_and(|l| l.0 == "ICHIGO-JUJI-LOOK") && hz.delay <= 0 && hz.age < hz.life) {
            return;
        }
        m.do_entities(|m, o| m.hazard.has(o) && m.hazard.has(h), |m, o| {
            let oz = m.hazard.get(o).unwrap();
            if oz.owner != e && oz.kind == Some(HazardKind::Wave) && oz.delay <= 0 {
                let (x, z, s) = (oz.x, oz.z, max_f32(0.5, oz.size));
                let kind = oz.kind.unwrap();
                if hazard_touches_p(m, h, x, 0.0, z, s, 1.8) {
                    let y = m.hazard.get(o).unwrap().y;
                    m.emit(crate::look::Event::HazardCut { x, y: 1.0 + y, z }); // look: emit :hazard-cut
                    crate::clog!(m, "{} cuts {}", side_name(m, e), kind.name());
                    m.destroy(o);
                }
            }
        });
    });
}
