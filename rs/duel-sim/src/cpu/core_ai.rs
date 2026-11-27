//! port: duel/lisp/core-ai.lisp — the core CPU: perceive, then hold the press in progress, or decide for the state he is in (the
//! exchange after a cancel, the clash, the late-match finish, a strategy's tactics, the MCTS neutral, a matchup style, the generic
//! CPU). Every chance is rolled once per event from the sim stream (`m.rng`, SIM-RND01), in the Lisp's order.
//!
//! Not ported here (each named where it would run): the MCTS neutral past its plan (`unported!("mc-neutral")`: Task 8). The matchup
//! styles are ken_ki.rs / ichigo_ki.rs (`style::resolve`; Hisagi's: M4). The strategies and their glue are strategy.rs / glue.rs (Task 5). `// rollout:` marks a
//! read of `*in-rollout*` / the rollout's `*cai-styles*` binding (no rollout runs before Task 8: both read as outside one).
use super::fuzzy::{fz_chance, Feats, FzRules, Kind};
use super::perceive::{ai_dash, ai_event_rolls, ai_press, ai_press_write, ai_strafe, ai_walk, brain_snap_ago, snap_dist, snap_near_p, Snap};
use super::xch_ai::{clash_opener, clash_window, xch_j_answer, xch_j_weights, xch_sa_now_p, xch_side, JAnswer};
use super::strategy::{self, Now};
use super::{glue, perceive, style, Brain, Search};
use glue::strat_reach;
use crate::cl::{floor_f32, fmt_fixed_f32, max_f32, min_f32, Num};
use crate::components::{Button, Cls, Contact, Phase, State, Sym};
use crate::core::core_as_sa_out_p;
use crate::core_sim::{core_next_as, core_seg_cancelled_p, core_switch_open_p};
use crate::ecs::Entity;
use crate::fighter::{awaken_ready_p, fighter, gauges_red_p, hoho_ready_p, kit_hook_sym, kit_of, mv, side_name};
use crate::flow::PilotInput;
use crate::kit::{kit_class, kit_command_move, kit_core_move, kit_sa_move, kit_sp_start_p, mv_name, mv_ns_next, mv_sa_move, mv_total, Role};
use crate::knobs::Knobs;
use crate::rules::cancel_open_p;
use crate::state::Match;
use duel_data::{Kit, Move, MoveClass};

const QUICK: Sym = Sym(":QUICK");
const STEP: Sym = Sym(":STEP");
const AWAKEN: Sym = Sym(":AWAKEN");
const ROLL: Sym = Sym(":ROLL");

/// port: CORE-BRAIN-STEP — one step of the core CPU: perceive, then hold the press in progress, or decide for the state he is in.
pub fn core_brain_step(m: &mut Match, s: &mut Search, input: &mut dyn PilotInput, e: Entity) {
    if m.fighter.get(e).and_then(|f| f.brain.as_ref()).is_some_and(|b| b.masher) {
        crate::unported!(m, "masher-step") // (masher.lisp, debug 81030+: M5)
    }
    let f = m.fighter.get(e).expect("a fighter");
    let (o, side) = (f.opp, f.side as usize);
    m.pilot.get_mut(e).expect("a pilot").vpad.begin_step();
    input.read(m, side); // (VPAD-BEGIN-STEP!'s reader: none in the game; the recorder's / replayer's mark)
    let (snap, d) = perceive::brain_perceive(m, e, o);
    let mut b = m.fighter.get_mut(e).and_then(|f| f.brain.take()).expect("a brain");
    think(m, s, e, &mut b, snap, d);
    m.fighter.get_mut(e).unwrap().brain = Some(b);
}

/// CORE-BRAIN-STEP after BRAIN-PERCEIVE, with the brain B taken out of E's fighter (put back by the caller, also after a stop).
fn think(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, snap: Snap, d: f32) {
    if m.knobs.strat_layer {
        glue::strat_layer_step(m, s, e, b, &snap, d); // (the strategy layer's selection)
    }
    // (a composite: its active sub, else the lookup's strategy; a Q selector: its arm, its NIL arm no strategy at all, DUEL_AI_STRATEGY §8.18)
    let sw = b.strat.filter(|st| st.get("switch").is_some() || st.fq().is_some());
    let cur = match sw {
        Some(sw) => glue::strat_switch_step(m, e, b, &snap, d, sw).or_else(|| {
            if sw.fq().is_some() {
                return None;
            }
            let f = fighter(m, e);
            strategy::strat_lookup(m.data, &m.knobs, f.character?, fighter(m, f.opp).character?, b.difficulty)
        }),
        None => b.strat,
    };
    let ev = sw.filter(|sw| sw.fq().is_some()).and_then(|sw| glue::strat_event_step(m, b, &snap, sw)); // (the event layer's arm)
    b.now = ev.or(cur).map(|st| Now { st, cues: glue::strat_feats(m, e, &snap, d) }); // (read by STRAT-OUT's callers this step)
    let kit = kit_of(m, e);
    m.pilot.get_mut(e).unwrap().vpad.stick(0.0, 0.0);
    ai_event_rolls(&mut m.rng, b, &snap);
    let f = fighter(m, e);
    let (state, phase, hold, lock, combo_hits) = (f.state, f.phase, f.hold, f.lock, f.combo_hits);
    if matches!(state, State::Stun | State::Air) && combo_hits >= m.knobs.burst_min_hits {
        b.burst_t += 1;
    } else {
        (b.burst_t, b.burst_rolled) = (0, false);
    }
    if b.act == Some(Sym(":DASH")) && b.press_left > 0 && if b.dash > 0.0 { d <= b.dash_to } else { d >= b.dash_to } {
        (b.press_left, b.decide_t) = (0, 1);
    }
    if state == State::Move && phase == Some(Phase::Follow) && b.press == Some(QUICK) && b.press_left > 0 {
        b.press_left = b.press_left.max(1 + m.knobs.core_kikon_confirm - hold); // held at the hit: on through the confirm
    }
    if state == State::Move || mc_full_reel_p(state) {
        b.fin_t = m.match_tick; // (the finish's quiet)
    }
    if !(b.off || lock > 0 || state == State::Cine) {
        cai_xch_new(m, e, b);
        let free = matches!(state, State::Idle | State::Run);
        let _ = (b.press_left > 0 && {
            b.press_left -= 1;
            true
        }) || cai_xch_step(m, e, b, kit, &snap, d)
            || (free && cai_clash(m, e, b, kit, &snap, d))
            || (free && cai_finish(m, e, b, kit, &snap, d))
            || glue::strat_fn_step(m, s, e, b, snap, d, ev.is_some()) // a strategy's own tactics first (DUEL_AI_STRATEGY §9)
            || m.unported.is_some()
            || mc_neutral(m, e, b, d)
            || m.unported.is_some()
            // a matchup style (under the strategy layer only as its strategy; not while a strategy is active)
            || (!glue::strat_layer_p(m) && cur.is_none() && ev.is_none() && cai_style(m, s, e, b, &snap, d))
            || m.unported.is_some()
            || {
                generic(m, e, b, kit, &snap, d, state);
                true
            };
    }
    b.now = None; // (its step is over: a step-end snapshot holds NIL)
    b.was = fighter(m, e).state;
    if cai_hoho_hold_p(m, e, b, kit) {
        b.press_left = 0; // (an SP the Hoho's resume would have refused: dropped, R15d)
    }
    let vp = &mut m.pilot.get_mut(e).unwrap().vpad;
    ai_press_write(b, vp);
    if b.press_left > 0 {
        match b.act.map(|a| a.0) {
            Some(":SIDE-STEP" | ":SWITCH") => vp.stick(b.strafe, 0.0),
            Some(":DASH") => vp.stick(0.0, b.dash),
            _ => {}
        }
    }
}

/// The generic CPU's step by state (CORE-BRAIN-STEP's last clause).
fn generic(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, snap: &Snap, d: f32, state: State) {
    let f = fighter(m, e);
    let (kl, sf, hits) = (f.kikon_lock, f.sf, f.combo_hits);
    match state {
        State::Idle | State::Run => cai_neutral(m, e, b, kit, snap, d, false),
        State::Move => cai_move_step(m, e, b, kit, snap),
        State::Stun => {
            let pk = m.knobs.cai_awaken_kikon_p.chance(b.difficulty);
            if kl == 1 && sf == 1 && cai_awaken_break(m, e, b, "awaken-kikon-p", pk) {
                // (the awakening out of the Kikon's lock: §11.20)
            } else if kl == 1 && sf == 1 && {
                let red = gauges_red_p(&m.knobs, m.gauges.get(e).unwrap()) as i64;
                b.guard_roll < cai_fz(&m.knobs, b, &m.knobs.fz_cancel, "other", Kind::Skill, &[("red", red.into())])
            } {
                cai_press(b, QUICK, 1, false);
            } else if kl == 0 && b.burst_t >= b.delay && !b.burst_rolled {
                b.burst_rolled = true;
                burst_out(m, e, b, hits);
            }
        }
        State::Air if kl == 0 && b.burst_t >= b.delay && !b.burst_rolled => {
            b.burst_rolled = true;
            burst_out(m, e, b, hits);
        }
        _ => {}
    }
}

/// The stun / air branches' inner COND: the awakening out of his combo, else a Burst by the fuzzy roll.
fn burst_out(m: &mut Match, e: Entity, b: &mut Brain, hits: i64) {
    let pb = m.knobs.cai_awaken_break_p.chance(b.difficulty);
    if cai_awaken_break(m, e, b, "awaken-break-p", pb) {
        return;
    }
    let red = gauges_red_p(&m.knobs, m.gauges.get(e).unwrap()) as i64;
    let p = cai_fz(&m.knobs, b, &m.knobs.fz_burst, "other", Kind::Skill, &[("hits", hits.into()), ("red", red.into())]);
    if roll_p(m, p) && crate::gauges::burst_ok_p(m, e).is_some() {
        cai_press(b, AWAKEN, 1, false);
    }
}

// ---------------------------------------------------------------- the strategy's reads over the brain's NOW (strategy.rs)

/// port: strategy.lisp STRAT-SCALE over B's NOW — chance P times the active strategy's scale KEY (none: P), within 0-1.
pub(crate) fn strat_scale(k: &Knobs, b: &Brain, key: &str, p: f32) -> f32 {
    strategy::strat_scale(&k.fz_sets, b.now.as_ref(), key, p)
}
/// port: STRAT-MUL of a float V (a margin) over B's NOW.
pub(crate) fn strat_mul(k: &Knobs, b: &Brain, key: &str, v: f32) -> f32 {
    strategy::strat_mul(&k.fz_sets, b.now.as_ref(), key, v)
}
/// port: STRAT-MUL of an integer V (a wait) over B's NOW.
pub(crate) fn strat_mul_int(k: &Knobs, b: &Brain, key: &str, v: i64) -> i64 {
    strategy::strat_mul_int(&k.fz_sets, b.now.as_ref(), key, v)
}

// ---------------------------------------------------------------- the reactive layer's helpers

/// port: CAI-CLASS-OF — the triangle class of the move the perceived S shows O in, or NIL.
pub fn cai_class_of(m: &Match, o: Entity, s: &Snap) -> Option<MoveClass> {
    if s.state != State::Move {
        return None;
    }
    kit_class(kit_of(m, o), Some(mv(m, s.mv?)))
}

/// A class as `~(~a~)` prints it (NIL: "nil").
fn cls_name(c: Option<MoveClass>) -> &'static str {
    c.map_or("nil", |c| match c {
        MoveClass::Na => "na",
        MoveClass::Ns => "ns",
        MoveClass::As => "as",
        MoveClass::Sa => "sa",
    })
}

/// port: CAI-PRESS — hold BUTTON for FRAMES steps (with :MOD when MODDED).
pub(crate) fn cai_press(b: &mut Brain, button: Sym, frames: i64, modded: bool) {
    ai_press(b, button, frames, modded, button);
}

/// port: CAI-FZ — RULES' chance at B's difficulty for the cues FEATS, times the active strategy's scale KEY (:hoho :turn :cont
/// :kikon, else :other).
fn cai_fz(k: &Knobs, b: &Brain, rules: &FzRules, key: &str, kind: Kind, feats: &Feats) -> f32 {
    strat_scale(k, b, key, fz_chance(k, rules, feats, b.difficulty, kind, 0.0))
}

/// CAI-FZ-ROLL's roll of its chance P: none drawn at 0 or 1.
fn roll_p(m: &mut Match, p: f32) -> bool {
    if p <= 0.0 {
        false
    } else if p >= 1.0 {
        true
    } else {
        m.rng.rnd01() < p
    }
}

/// port: components.lisp CHANCE-ROLL — one roll of P: none drawn at 0 or 1.
pub fn chance_roll(m: &mut Match, p: f32) -> bool {
    p > 0.0 && (p >= 1.0 || m.rng.rnd01() < p)
}

/// port: CAI-ROLL — CHANCE-ROLL of a chance P (PLIST's at B's difficulty) times the active strategy's KEY.
fn cai_roll(m: &mut Match, b: &Brain, key: &str, p: f32) -> bool {
    let p = strat_scale(&m.knobs, b, key, p);
    chance_roll(m, p)
}

/// port: CAI-MIX-ROLL — the active strategy's KEY as the chance itself, else CAI-ROLL of P scaled by ELSE-KEY.
fn cai_mix_roll(m: &mut Match, b: &Brain, key: &str, else_key: &str, p: f32) -> bool {
    match glue::strat_out(&m.knobs, b, key) {
        Some(v) => chance_roll(m, max_f32(0.0, min_f32(1.0, v.f()))),
        None => cai_roll(m, b, else_key, p),
    }
}

/// port: CAI-MARGIN — *cai-clash-margin* times the active strategy's :CLASH-MARGIN.
fn cai_margin(m: &Match, b: &Brain) -> f32 {
    strat_mul(&m.knobs, b, "clash-margin", m.knobs.cai_clash_margin)
}

/// port: CAI-OWN-ROLLS — the rolls of his own move, made once when it starts (its CLS-T).
pub(crate) fn cai_own_rolls(m: &mut Match, b: &mut Brain, cls_t: i64) {
    if b.own_key != cls_t {
        b.own_key = cls_t;
        b.r_turn = m.rng.rnd01();
        b.r_cont = m.rng.rnd01();
        b.r_kikon = m.rng.rnd01();
    }
}

/// port: CAI-SP — press SP: held into a Kikon when this SP's roll says so, else a tap of FRAMES; NO-KIKON a tap.
pub(crate) fn cai_sp(m: &Match, e: Entity, b: &mut Brain, frames: i64, no_kikon: bool) {
    let o = fighter(m, e).opp;
    let want = !no_kikon && {
        let go = m.gauges.get(o).unwrap();
        let red = gauges_red_p(&m.knobs, go) as i64;
        let lead = m.gauges.get(e).unwrap().konpaku - go.konpaku;
        b.r_kikon < cai_fz(&m.knobs, b, &m.knobs.fz_kikon, "kikon", Kind::Skill, &[("ored", red.into()), ("lead", lead.into())])
    };
    cai_press(b, QUICK, if want { 40 } else { frames }, true);
}

/// The :no-kikon of the AS an SP pressed now would start.
fn next_as_no_kikon(m: &Match, e: Entity, kit: &Kit) -> bool {
    kit_core_move(m.data, kit, Role::As, core_next_as(m, e)).is_some_and(|a| a.params.no_kikon)
}

/// port: MV-MIN-REACH — MVD's first window's dead zone (0 without one); with E, his kit's :min-reach hook's (Hisagi's: M4).
pub fn mv_min_reach(m: &mut Match, mvd: &Move, e: Option<Entity>) -> f32 {
    let mn = mvd.hits.first().and_then(|w| w.min);
    if let (Some(_), Some(e)) = (mn, e)
        && kit_hook_sym(m, e, "min-reach").is_some()
    {
        crate::unported!(m, "min-reach hook", 0.0) // (Hisagi's cancel unlock: M4)
    }
    mn.unwrap_or(0.0)
}

/// port: CAI-SWITCH-PRESS — press SP with the stick sideways toward pointer TO: the human's own switch (CORE-SWITCH-TARGET); the act
/// :SWITCH marks the press (CORE-BRAIN-STEP writes the stick). ponytail: *cai-switch-counts* (a tool's counter, strat-run.lisp
/// STRAT_HRANGE, never read in play) is not kept.
fn cai_switch_press(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit, to: i64) {
    ai_press(b, QUICK, 1, true, Sym(":SWITCH"));
    let ptr = fighter(m, e).ptr;
    b.strafe = strategy::strat_switch_dir(ptr, to, kit.core.ns.len() as i64) as f32;
    crate::clog!(m, "{} cpu switch {} -> {}", side_name(m, e), ptr, to);
}

/// port: CAI-SWITCH-TARGET — the pointer the active strategy's switch goes to from E's NS gap at distance D (its :DSWITCH-MAP row for
/// his form and pointer, else STRAT-SWITCH-TO's band rule over the openers' reach), or NIL.
fn cai_switch_target(m: &mut Match, e: Entity, b: &Brain, kit: &Kit, d: f32) -> Option<i64> {
    let n = kit.core.ns.len();
    let f = fighter(m, e);
    let (form, ptr) = (f.form, f.ptr);
    let map = b.now.as_ref().and_then(|now| now.st.get("dswitch-map")).and_then(|v| v.as_array()).map_or(&[][..], |a| a.as_slice());
    let row = map.iter().find(|r| r[0].as_str().is_some_and(|x| x.eq_ignore_ascii_case(form.name())) && r[1].as_i64() == Some(ptr));
    let mut bands = [None; strategy::MAX_ARMS];
    for (p, band) in bands.iter_mut().enumerate().take(n) {
        if let Some(mvd) = kit_core_move(m.data, kit, Role::Ns, p as i64 + 1) {
            *band = Some((mv_min_reach(m, mvd, Some(e)), strat_reach(Some(mvd)) + m.knobs.cai_dswitch_slack));
        }
    }
    strategy::strat_switch_to(ptr, n as i64, d, &bands[..n], row.and_then(|r| r.get(2)).and_then(|v| v.as_i64()))
}

/// port: CAI-DSWITCH — in an NS segment's gap (once per segment): the active strategy's :DSWITCH, one roll when the switch is open and
/// a target reaches. T when it pressed. No :DSWITCH (every shipped CPU): no roll, NIL.
fn cai_dswitch(m: &mut Match, e: Entity, b: &mut Brain, kit: &Kit) -> bool {
    let Some(p) = glue::strat_out(&m.knobs, b, "dswitch").filter(|p| p.f() > 0.0) else { return false };
    if !core_switch_open_p(m, e) {
        return false;
    }
    let dist = fighter(m, e).dist;
    let Some(to) = cai_switch_target(m, e, b, kit, dist) else { return false };
    let roll = m.rng.rnd01() < p.f() * m.knobs.cai_dswitch_dif.chance(b.difficulty);
    if roll {
        cai_switch_press(m, e, b, kit, to);
    }
    roll
}

/// port: CAI-NEXT-OK-P — would an SP pressed now in NS segment MVD start the next one? Refused: logs `cpu holds` and NIL.
pub(crate) fn cai_next_ok_p(m: &mut Match, e: Entity, kit: &Kit, mvd: &Move) -> bool {
    let Some(nx) = mv_ns_next(m.data, kit, mvd) else { return false };
    let g = m.gauges.get(e).unwrap();
    let (fs, burst) = (g.fs, g.burst.is_some());
    if kit_sp_start_p(kit, nx, fs, burst) {
        return true;
    }
    crate::clog!(m, "{} cpu holds {} (fs {})", side_name(m, e), mv_name(nx).to_uppercase(), fmt_fixed_f32(fs, 1));
    false
}

/// port: CAI-HOHO-HOLD-P — is B's pending press an SP that would resume E's Hoho'd NS route into a segment the sim refuses?
fn cai_hoho_hold_p(m: &mut Match, e: Entity, b: &Brain, kit: &Kit) -> bool {
    let f = fighter(m, e);
    let Some(from) = f.hoho_from else { return false };
    if !(!b.off && b.press_left > 0 && b.press == Some(QUICK) && b.press_mod && f.hoho_cls == Some(Cls::Ns)) {
        return false;
    }
    if !(f.state == State::Hoho || f.hoho_left > 0) {
        return false;
    }
    !cai_next_ok_p(m, e, kit, mv(m, from))
}

// ---------------------------------------------------------------- his own move

/// port: CAI-MOVE-STEP — inside his own move: continue, turn or end it (once per move).
pub(crate) fn cai_move_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s: &Snap) {
    let f = fighter(m, e);
    let (mvid, cls, cls_t, o) = (f.mv, f.cls.map(MoveClass::from), f.cls_t, f.opp);
    let oc = cai_class_of(m, o, s);
    cai_own_rolls(m, b, cls_t);
    let (Some(mvid), Some(cls)) = (mvid, cls) else { return };
    if b.decided == cls_t {
        return;
    }
    let mvd = mv(m, mvid);
    let f = fighter(m, e);
    let (contact, sf, dist, presses, as_done) = (f.contact, f.sf, f.dist, f.presses, f.as_done);
    let k = &m.knobs;
    match cls {
        MoveClass::Na | MoveClass::Sa => {
            if contact != Some(Contact::Hit) {
                return; // (landed, or cancelled: it counts as a hit)
            }
            b.decided = cls_t;
            let len = kit.core.as_by_press.as_ref().map_or(3, |v| v.len()) as i64;
            let end = !as_done
                && (presses >= len // (the string's end)
                    || mvd.params.as_ptr == Some(3) // (§28.20's gathered J3)
                    || {
                        let ored = gauges_red_p(k, m.gauges.get(o).unwrap()) as i64;
                        let ons = Num::I((oc == Some(MoveClass::Ns)) as i64);
                        let feats = [("ons", ons), ("ored", ored.into()), ("press", Num::F(presses as f32 / len as f32))];
                        b.r_cont < cai_fz(k, b, &k.fz_as_now, "turn", Kind::Choice, &feats)
                    });
            if end {
                let nk = next_as_no_kikon(m, e, kit);
                cai_sp(m, e, b, 1, nk);
            } else {
                cai_press(b, QUICK, 1, false);
            }
        }
        MoveClass::Ns => {
            if sf < mvd.s as i64 {
                return; // (the segment is out: now is the gap to read)
            }
            b.decided = cls_t;
            if cai_dswitch(m, e, b, kit) {
                return;
            }
            // (a :charge-sa segment cashing in: no move has the key, Params would refuse it)
            let k = &m.knobs;
            let turn = kit_sa_move(m.data, kit).is_some() && {
                let ona = Num::I((oc == Some(MoveClass::Na)) as i64);
                let ownsa = Num::I(mv_sa_move(m.data, kit, mvd).is_some() as i64);
                b.r_turn < cai_fz(k, b, &k.fz_ns_turn, "turn", Kind::Skill, &[("ona", ona), ("d", Num::F(dist)), ("ownsa", ownsa)])
            };
            if turn {
                cai_press(b, QUICK, 1, false);
            } else if mv_ns_next(m.data, kit, mvd).is_some()
                && b.r_cont < cai_fz(k, b, &k.fz_ns_cont, "cont", Kind::Choice, &[("hit", Num::I(contact.is_some() as i64)), ("d", Num::F(dist))])
                && cai_next_ok_p(m, e, kit, mvd)
            {
                cai_press(b, QUICK, 1, true); // (refused at 0: no press, the route ends here, S7)
            }
        }
        MoveClass::As => {
            if sf >= mvd.s as i64 && mv_ns_next(m.data, kit, mvd).is_some() {
                b.decided = cls_t;
                let held = m.pilot.get(e).unwrap().vpad.down(Button::Quick as usize);
                let cue = [("hit", Num::I(contact.is_some() as i64)), ("d", Num::F(dist))];
                if !held && b.r_cont < cai_fz(k, b, &k.fz_ns_cont, "cont", Kind::Choice, &cue) {
                    cai_press(b, QUICK, 1, true);
                }
            }
        }
    }
}

// ---------------------------------------------------------------- the exchange after a cancel, the clash (§11.18)

/// port: CAI-XCH-NEW — his move in play just took part in a cancel: the event's key, its rolls to make, a held press let go.
fn cai_xch_new(m: &Match, e: Entity, b: &mut Brain) {
    let f = fighter(m, e);
    let cls = f.cls.map(MoveClass::from);
    if f.state == State::Move
        && !(b.xmove == f.cls_t && b.xkey == f.xch)
        && (xch_side(cls, f.contact, f.xch, f.cls_t).is_some() || core_as_sa_out_p(m.knobs.core_as_sa_out, cls, core_seg_cancelled_p(f)))
    {
        (b.xkey, b.xmove, b.xdone, b.xpick) = (f.xch, f.cls_t, false, Some(ROLL));
        (b.xown, b.press_left) = (f.hits > 0, 0);
    }
}

/// port: CAI-XCH-STEP — play the cancel his move in play took part in: T while it owns the step (R4's AS side: only its SA's).
fn cai_xch_step(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s: &Snap, d: f32) -> bool {
    let f = fighter(m, e);
    let Some(mvid) = f.mv else { return false };
    if !(f.state == State::Move && b.xmove == f.cls_t && b.xkey == f.xch) {
        return false;
    }
    let cls = f.cls.map(MoveClass::from);
    let as_out = m.knobs.core_as_sa_out && cls == Some(MoveClass::As);
    let ns = as_out || cls == Some(MoveClass::Ns);
    let (xch, sf, land_sf, as_done, o) = (f.xch, f.sf, f.land_sf, f.as_done, f.opp);
    let mvd = mv(m, mvid);
    let mut pressed = false;
    if b.xpick == Some(ROLL) {
        // (the event's rolls, made on its first step)
        let (dif, k) = (b.difficulty, &m.knobs);
        let (sa_p, early_p, early_his_p) = (k.cai_xch_sa_p.chance(dif), k.cai_xch_early_p.chance(dif), k.cai_xch_early_his_p.chance(dif));
        let (carry_p, carry_watch_p) = (k.cai_xch_carry_p.chance(dif), k.cai_xch_carry_watch_p.chance(dif));
        if ns {
            let pick = cai_roll(m, b, "xch-sa-p", sa_p).then(|| {
                let early = if b.xown { cai_roll(m, b, "xch-early-p", early_p) } else { cai_mix_roll(m, b, "xch-early-his-p", "xch-early-p", early_his_p) };
                Sym(if early { ":EARLY" } else { ":WATCH" })
            });
            b.xpick = pick;
            let carry = if as_out {
                false
            } else if pick == Some(Sym(":WATCH")) {
                cai_mix_roll(m, b, "xch-carry-watch-p", "xch-carry-p", carry_watch_p)
            } else {
                cai_roll(m, b, "xch-carry-p", carry_p)
            };
            b.xcarry = carry.then_some(Sym("T"));
        } else {
            let r = m.rng.rnd01();
            let ws = xch_j_weights(m.knobs.cai_xch_j.get(dif), glue::strat_out(&m.knobs, b, "xch-j").map(Num::f));
            let reach = kit_core_move(m.data, kit, Role::As, core_next_as(m, e)).is_some_and(|a| !as_done && d <= strat_reach(Some(a)) + cai_margin(m, b));
            b.xpick = xch_j_answer(r, ws, reach).map(|a| Sym(if a == JAnswer::As { ":AS" } else { ":J" }));
        }
        // (*cai-xch-hook*: a research tool's, NIL in the game)
    }
    if !b.xdone {
        if ns {
            let oc = cai_class_of(m, o, s);
            let watch = matches!(b.xpick.map(|p| p.0), Some(":WATCH" | ":EARLY"));
            let wait = strat_mul_int(&m.knobs, b, "xch-sa-wait", m.knobs.cai_xch_sa_wait);
            if watch && xch_sa_now_p(oc, s.start, xch, b.xpick == Some(Sym(":EARLY")), m.match_tick, wait) {
                b.xdone = true;
                crate::clog!(m, "{} cpu xch SA on his {}", side_name(m, e), cls_name(oc));
                pressed = true;
                cai_press(b, QUICK, 1, false);
            } else if b.xcarry.is_some() && sf >= (mvd.s + mvd.a) as i64 - 1 {
                b.xcarry = None; // (his turn may still come: the watch goes on)
                if mv_ns_next(m.data, kit, mvd).is_some() && cai_next_ok_p(m, e, kit, mvd) {
                    cai_press(b, QUICK, 1, true);
                }
            }
        } else if b.xpick.is_none() || cancel_open_p(sf, land_sf, mv_total(mvd), true) {
            b.xdone = true;
            let pick = b.xpick.map_or("hold", |p| if p.0 == ":AS" { "as" } else { "j" });
            crate::clog!(m, "{} cpu xch {} at {}", side_name(m, e), pick, fmt_fixed_f32(d, 1));
            match pick {
                "as" => {
                    let nk = next_as_no_kikon(m, e, kit);
                    cai_sp(m, e, b, 1, nk);
                }
                "j" => cai_press(b, QUICK, 1, false),
                _ => {}
            }
        }
    }
    if as_out { pressed } else { true }
}

/// port: CAI-CLASH — 積極相消: free, he is seen in a classed move still live within his reach + the margin: one roll per such move,
/// and the CPU throws CLASH-OPENER's move into it. Its own reaction *cai-clash-delay*, never slower than the brain's. T when it pressed.
fn cai_clash(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s0: &Snap, d0: f32) -> bool {
    let dl = b.delay.min(m.knobs.cai_clash_delay.chance(b.difficulty));
    let ago = if dl < b.delay { brain_snap_ago(b, dl) } else { None };
    let (s, d) = match ago {
        Some(s) => (s, snap_dist(m, &s, e)), // (another ring slot than S0: never EQ)
        None => (*s0, d0),
    };
    let f = fighter(m, e);
    let (o, ptr, side) = (f.opp, f.ptr, f.side);
    let oc = cai_class_of(m, o, &s);
    let to = clash_opener(oc);
    let Some(mvd) = s.mv.map(|id| mv(m, id)) else { return false };
    let hits = mvd.hits.len() as i64;
    let win = clash_window(hits, s.active_end, s.reach, mvd.params.hit_at.map(i64::from), mvd.params.hit_reach);
    let (Some(to), Some((end, reach))) = (to, win) else { return false };
    if b.clash_key == s.start {
        return false;
    }
    let reach = reach.expect("a clash window's reach"); // (:hit-at without :hit-reach: the Lisp's PLUSP of NIL errors)
    if !(reach > 0.0 && !s.has_flag(m.data, "parry") && end - s.sf - dl >= 1) {
        return false;
    }
    let margin = cai_margin(m, b);
    let near = if hits > 0 { snap_near_p(m, &s, e, d, margin) } else { d < reach + margin };
    if !(near && (to == MoveClass::Na || kit_core_move(m.data, kit, Role::Ns, ptr).is_some())) {
        return false;
    }
    b.clash_key = s.start;
    let p = m.knobs.cai_clash_p.chance(b.difficulty);
    if !cai_roll(m, b, "clash-p", p) {
        return false;
    }
    m.mc_plan[5 * side as usize] = 0; // (MC-PLAN-DROP: a plan the MCTS made a reaction ago)
    crate::clog!(m, "{} cpu clash {} into his {} at {}", side_name(m, e), cls_name(Some(to)), cls_name(oc), fmt_fixed_f32(d, 1));
    (b.own_key, b.r_kikon) = (-1, 1.0); // (its own rolls made afresh; no Kikon hold on a clash)
    if to == MoveClass::Na {
        cai_press(b, QUICK, 1, false);
    } else {
        cai_sp(m, e, b, 1, false);
    }
    true
}

// ---------------------------------------------------------------- neutral

/// port: CAI-NEUTRAL — free: Hoho out of an attack at him, else walk to the range and now and then start a move. FINISH: the kit's
/// own range, no strategy's scale, and only a move out of its dead zone.
#[allow(clippy::too_many_arguments)]
pub(crate) fn cai_neutral(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s: &Snap, d: f32, finish: bool) {
    let ptr = fighter(m, e).ptr;
    let k = &m.knobs;
    let nr = kit.core.ns_range.as_ref().and_then(|v| v.get((1.max(k.core_pointer_max.min(ptr)) - 1) as usize).copied().flatten());
    let rg = kit.core.range.unwrap_or([k.cai_range.0, k.cai_range.1]);
    let sc = if finish { None } else { glue::strat_out(k, b, "range").map(Num::f) }; // (a strategy's range scale)
    let (lo, hi) = match sc {
        Some(sc) => (sc * rg[0], sc * rg[1]),
        None => (rg[0], rg[1]),
    };
    b.strafe_t -= 1;
    if b.strafe_t <= 0 {
        ai_strafe(&mut m.rng, &m.knobs, b);
    }
    let k = &m.knobs;
    if s.state == State::Move && s.left > 0 && d < s.reach + 1.0 && hoho_ready_p(m, e) && {
        let feats = [("margin", Num::F(d - s.reach)), ("frames", Num::I(0.max(s.s - s.sf)))];
        b.hoho_roll < cai_fz(k, b, &k.fz_hoho, "hoho", Kind::Skill, &feats)
    } {
        b.hoho_roll = 1.0;
        ai_press(b, STEP, 1, true, Sym(":HOHO"));
        return;
    }
    if d > 7.0 {
        b.decide_t = b.decide_t.min(1);
    }
    ai_walk(b, &mut m.pilot.get_mut(e).unwrap().vpad, d, lo, hi);
    b.decide_t -= 1;
    if b.decide_t > 0 {
        return;
    }
    b.decide_t = m.knobs.cai_think.get(b.difficulty.name(), 22) + floor_f32(12.0 * m.rng.rnd01());
    if d > 7.0 {
        ai_dash(&m.knobs, b, 1.0, 4.5);
    } else if gauges_awakened_ok_p(m, e, Some(b)) && m.rng.rnd01() < strat_scale(&m.knobs, b, "awaken", m.knobs.cai_awaken_p) {
        ai_press(b, AWAKEN, 1, true, AWAKEN);
    } else if nr.is_some_and(|[near, far]| d > hi + 0.6 && near <= d && d <= far) && m.rng.rnd01() < m.knobs.cai_ranged_p {
        (b.own_key, b.r_kikon, b.decide_t) = (-1, 1.0, m.knobs.cai_ranged_gap); // a shot from where he would walk in
        cai_sp(m, e, b, 1, false);
    } else if d <= hi + 0.6 {
        b.own_key = -1;
        let roll = m.rng.rnd01();
        let ns = kit_core_move(m.data, kit, Role::Ns, ptr).filter(|&ns| !finish || mv_min_reach(m, ns, Some(e)) <= d);
        let share = glue::strat_out(&m.knobs, b, "ns").map_or(if d > 1.7 { m.knobs.cai_ns_far } else { m.knobs.cai_ns_near }, Num::f);
        if ns.is_some() && roll < share {
            b.r_kikon = m.rng.rnd01();
            cai_sp(m, e, b, 1, false);
        } else if !finish || kit_command_move(m.data, kit, "q").is_some_and(|q| mv_min_reach(m, q, Some(e)) <= d) {
            cai_press(b, QUICK, 1, false);
        }
    }
}

/// port: CAI-FINISH — the late-match finish: past *cai-finish-at* a free CPU ahead at the bell (FINISH-ROLE) plays the generic
/// neutral; behind or level once it has been quiet for a decision gap. T when it took the step.
fn cai_finish(m: &mut Match, e: Entity, b: &mut Brain, kit: &'static Kit, s: &Snap, d: f32) -> bool {
    let o = fighter(m, e).opp;
    let (g, go, k) = (m.gauges.get(e).unwrap(), m.gauges.get(o).unwrap(), &m.knobs);
    let wait = k.cai_think.get(b.difficulty.name(), 22) + 12;
    let role = crate::rules::finish_role(
        k, m.timer, 60 * k.match_seconds, m.match_tick - b.fin_t, wait, g.konpaku, g.reishi, g.reishi_max, go.konpaku, go.reishi,
        go.reishi_max,
    );
    let Some(role) = role else { return false };
    if b.decide_t <= 1 {
        crate::clog!(m, "{} cpu finish {} at {}", side_name(m, e), role.name(), fmt_fixed_f32(d, 1));
    }
    cai_neutral(m, e, b, kit, s, d, true);
    true
}

/// port: CAI-AWAKEN-BREAK — the awakening out of his combo or Kikon: when E may awaken now, one roll of P scaled by KEY (CAI-ROLL).
/// T when it pressed Mod + P.
fn cai_awaken_break(m: &mut Match, e: Entity, b: &mut Brain, key: &str, p: f32) -> bool {
    if !(awaken_ready_p(m, e) && !glue::strat_hold_awaken_p(m, e, Some(b)) && cai_roll(m, b, key, p)) {
        return false;
    }
    let what = if fighter(m, e).kikon_lock > 0 { "the Kikon" } else { "the combo" };
    crate::clog!(m, "{} cpu awakens out of {}", side_name(m, e), what);
    cai_press(b, AWAKEN, 1, true);
    true
}

/// port: GAUGES-AWAKENED-OK-P — may E awaken now (the gauge full, not yet awakened, free; not held by a strategy)?
pub fn gauges_awakened_ok_p(m: &Match, e: Entity, b: Option<&Brain>) -> bool {
    let (g, f) = (m.gauges.get(e).unwrap(), fighter(m, e));
    // ((getf core :no-awaken): no kit has the key)
    !g.awakened && g.awaken >= m.knobs.awaken_max && matches!(f.state, State::Idle | State::Run) && !glue::strat_hold_awaken_p(m, e, b)
}

/// port: cpu-mcts.lisp MC-FULL-REEL-P.
pub fn mc_full_reel_p(st: State) -> bool {
    matches!(st, State::Stun | State::Air | State::Down | State::Wakeup | State::GuardHit | State::Cine)
}

// ---------------------------------------------------------------- the MCTS neutral's plan (cpu-mcts.lisp; its search: Task 8)

/// port: cpu-mcts.lisp MC-NEUTRAL — a plan made a reaction time ago comes due (MC-PLAN-APPLY); else, past its guard, the light
/// search (`unported!`: Task 8). T when it pressed.
fn mc_neutral(m: &mut Match, e: Entity, b: &mut Brain, d: f32) -> bool {
    let f = fighter(m, e);
    let (side, state, ch) = (f.side as usize, f.state, f.character);
    if m.mc_plan[5 * side] > 0 {
        return mc_plan_apply(m, e, b);
    }
    // rollout: (when *in-rollout* (return-from mc-neutral nil))
    let k = &m.knobs;
    let (tick, next) = (m.match_tick, m.mc_next[side]);
    if k.mc_on
        && matches!(state, State::Idle | State::Run)
        && !k.mc_off_at.has(ch.map_or("", |c| c.name()), b.difficulty.name())
        && !(tick < next && next < tick + k.mc_defer_gap + 1)
        && d <= k.mc_far
        && !gauges_awakened_ok_p(m, e, Some(b))
    {
        crate::unported!(m, "mc-neutral", false) // (MC-SETUP, the light search, MC-FULL-REQUEST: Task 8)
    }
    false
}

/// port: cpu-mcts.lisp MC-PLAN-APPLY — his hold is over: the plan's pick (both scored: the better within the budget, a softmax
/// between them; still running: the light model's best), if he is still free. The plan is cleared either way. T when he pressed.
pub fn mc_plan_apply(m: &mut Match, e: Entity, b: &mut Brain) -> bool {
    let f = fighter(m, e);
    let (k, state) = (5 * f.side as usize, f.state);
    let (st, a1, a2) = (m.mc_plan[k], m.mc_plan[k + 1], m.mc_plan[k + 2]);
    m.mc_plan[k] = 0;
    if !(matches!(state, State::Idle | State::Run) && a1 >= 0) {
        return false;
    }
    let a = if st == 2 && a2 >= 0 {
        let dif = b.difficulty.name();
        let gap = (m.mc_plan[k + 3] - m.mc_plan[k + 4]) as f32 / 1000.0;
        if gap > m.knobs.mc_budget.get_or(dif, 0.05) || (1.0 + crate::cl::expf(-gap / m.knobs.mc_tau.get_or(dif, 0.03))) * m.rng.rnd01() < 1.0 {
            a1
        } else {
            a2
        }
    } else {
        a1
    };
    let action = m.knobs.mc_actions.0[a as usize].as_str();
    if action == "hoho" && !hoho_ready_p(m, e) {
        return false; // (a Hoho picked a reaction ago, an exchange opened since)
    }
    mc_press(b, action);
    true
}

/// port: cpu-mcts.lisp MC-PRESS — start ACTION (a `*mc-actions*` name) as the brain's press.
pub fn mc_press(b: &mut Brain, action: &str) {
    let none = Sym(":NONE");
    let dash = |b: &mut Brain, dir: f32, to: f32| (b.dash, b.dash_to) = (dir, to);
    match action {
        "j1" => ai_press(b, QUICK, 1, false, QUICK),
        "sp" => ai_press(b, QUICK, 1, true, QUICK),
        "hoho" => ai_press(b, STEP, 1, true, Sym(":HOHO")),
        "step-in" => {
            ai_press(b, STEP, 1, false, Sym(":DASH"));
            dash(b, 1.0, 0.0);
        }
        "step-out" => {
            ai_press(b, STEP, 1, false, Sym(":DASH"));
            dash(b, -1.0, 99.0);
        }
        "step-side" => {
            ai_press(b, STEP, 1, false, Sym(":SIDE-STEP"));
            b.strafe = 1.0;
        }
        "guard" => ai_press(b, Sym(":GUARD"), 20, false, Sym(":GUARD")),
        "wait" => ai_press(b, none, 20, false, none),
        "walk-in" => {
            ai_press(b, none, 20, false, Sym(":DASH"));
            dash(b, 1.0, 0.0);
        }
        "walk-out" => {
            ai_press(b, none, 20, false, Sym(":DASH"));
            dash(b, -1.0, 99.0);
        }
        _ => panic!("mc-press: no action {action}"), // (ECASE)
    }
}

// ---------------------------------------------------------------- the matchup style (DUEL_MATCHUP_AI)

/// CORE-BRAIN-STEP's style clause: E's style against his opponent (CAI-STYLE-FN), run when it is ported. T when it decided.
fn cai_style(m: &mut Match, s: &mut Search, e: Entity, b: &mut Brain, snap: &Snap, d: f32) -> bool {
    let Some(st) = glue::cai_style_fn(m, e) else { return false };
    style::run(m, s, st, e, b, *snap, d)
}
