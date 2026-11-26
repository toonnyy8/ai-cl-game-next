//! port: duel/lisp/round.lisp — the round's end: the souls the step's hits broke (combat.rs TAKE-BROKEN-SOULS), settled together at
//! connect time (SETTLE-KONPAKU, SETTLE-SOULS), then the reset (RESET-ROUND) or the finish (flow.rs MATCH-OVER).
use crate::cine::{start_cine, After, CineName};
use crate::combat::{KikonQ, Queue, SOULS_MAX};
use crate::components::State;
use crate::ecs::Entity;
use crate::fighter::{call_hook, callout, fighter, fighter_mut, gauges_red_p, kit_hook_sym, kit_of, mv, opp_of, pos_of, side_name, to_idle};
use crate::gauges::{awaken_fill, burst_end, pay_gauges, set_form, siphon_of};
use crate::hazards::clear_hazards;
use crate::rules::{awakening_gain, reset_placement, sub_attack_gain};
use crate::state::Match;

/// port: KIKON-WORTH: Konpaku E's Kikon would take now: a running rush's worth (fixed at its start), else the kit's :kikon-worth hook
/// (ICHIGO-KIKON-WORTH), else the kit's :kikon-konpaku. (None: the hook is unported, `m.unported` set.)
pub fn kikon_worth(m: &mut Match, e: Entity) -> Option<i64> {
    let f = fighter(m, e);
    if f.mv.is_some_and(|id| f.state == State::Move && mv(m, id).kind == "kikon") {
        return Some(f.kikon_n);
    }
    if let Some(h) = kit_hook_sym(m, e, "kikon-worth") {
        return match crate::fighter::ichigo_hook(h) {
            Some(crate::ichigo::Hook::KikonWorth) => Some(crate::ichigo::hooks::kikon_worth(m, e)),
            _ => crate::unported!(m, h, None),
        };
    }
    Some(kit_of(m, e).kikon_konpaku as i64)
}

/// port: KIKON-READY-P: is E's opponent red (would E's Kikon rush, connecting now with the button held, be the Kikon)?
pub fn kikon_ready_p(m: &Match, e: Entity) -> bool {
    gauges_red_p(&m.knobs, m.gauges.get(opp_of(m, e)).expect("gauges"))
}

/// port: SETTLE-KONPAKU: Konpaku at connect time: DEF loses the Kikon's count, or on a Soul Break ATT's worth + 1 (the core system's
/// counts: CORE-KONPAKU-RESULT); his Reishi refills; the gains. True when DEF is out of Konpaku (never in a bind: no binder before M4).
pub fn settle_konpaku(m: &mut Match, att: Entity, def: Entity, soul_break: bool) -> bool {
    let bound = crate::gauges::bind_of(m, def).is_some();
    // N is read first (KIKON-WORTH may call the kit's hook); every kit has a :core (Kit.core is required), so the count is
    // CORE-KONPAKU-RESULT's and KIKON-RESULT's branch (which would read N) is never taken
    if soul_break && kikon_worth(m, att).is_none() {
        return false;
    }
    let konpaku = m.gauges.get(def).unwrap().konpaku;
    let (left, lost, ko) = crate::core_sim::core_konpaku_result(m, konpaku, att, soul_break);
    let gd = m.gauges.get_mut(def).unwrap();
    (gd.konpaku, gd.reishi) = (left, crate::cl::Num::I(gd.reishi_max));
    if let Some(h) = kit_hook_sym(m, def, "settled")
        && !call_hook(m, def, h)
    {
        return false; // (no kit holds one: HookKey has no :settled)
    }
    if siphon_of(m, def).is_none() {
        let x = awakening_gain(&m.knobs, 0, 0, lost);
        let k = &m.knobs;
        awaken_fill(k, m.gauges.get_mut(def).unwrap(), x, 0.0);
    }
    if siphon_of(m, att).is_none() {
        let xs = sub_attack_gain(&m.knobs, 0, lost, 1.0);
        let k = &m.knobs;
        awaken_fill(k, m.gauges.get_mut(att).unwrap(), 0.0, xs); // (the Konpaku he took fills his SUBLIMATION / DRIVE)
    }
    m.gauges.get_mut(att).unwrap().kikons += 1;
    // look: emit :konpaku
    crate::clog!(m, "{} {} on {}: -{} konpaku, {} left ({})", side_name(m, att), if soul_break { "SOUL BREAK" } else { "KIKON" },
        side_name(m, def), lost, left, fighter(m, att).form);
    ko && !bound
}

/// The cinematic named SYM: the generic Soul Break's, or a kit's (an unknown one: `unported!`, None).
fn cine_named(m: &mut Match, sym: &'static str) -> Option<CineName> {
    match CineName::from_lisp(sym) {
        Some(c) => Some(c),
        None => crate::unported!(m, sym, None),
    }
}

/// port: SETTLE-SOULS: the souls broken during this step, settled together so no side goes first: KK every confirmed Kikon, SB every
/// Reishi that reached 0, both in the order queued. Then one cinematic (the first Kikon's move :cine, else its pointer's or the kit's;
/// a Soul Break: its attacker's pointer's), then the reset, or the finish (a draw when both souls ran out). The hazards are cleared first.
pub fn settle_souls(m: &mut Match, kk: &Queue<KikonQ, SOULS_MAX>, sb: &Queue<(Entity, Entity), SOULS_MAX>) {
    if kk.is_empty() && sb.is_empty() {
        return;
    }
    m.do_entities(|m, e| m.fighter.has(e), burst_end); // the reset ends every burst, before the Kikon's refund
    let mut paid: Queue<Entity, 4> = Queue::default();
    for att in kk.iter().map(|k| k.att).chain(sb.iter().map(|s| s.0)) {
        if !paid.iter().any(|x| x == att) {
            paid.push(att); // (REMOVE-DUPLICATES: each fighter once; the order is immaterial, the gains are independent)
        }
    }
    let refund = m.knobs.kikon_fs_refund;
    for att in paid.iter() {
        pay_gauges(m, att, refund); // a flash-step bar back
    }
    let mut kos: Queue<Entity, 4> = Queue::default();
    for k in kk.iter() {
        if settle_konpaku(m, k.att, k.def, false) {
            kos.push(k.def);
        }
        if m.unported.is_some() {
            return;
        }
    }
    for (att, def) in sb.iter() {
        if settle_konpaku(m, att, def, true) {
            kos.push(def);
        }
        if m.unported.is_some() {
            return;
        }
    }
    let (a, v) = match kk.get(0) {
        Some(k) => (k.att, k.def),
        None => sb.get(0).unwrap(),
    };
    for k in kk.iter() {
        if let Some(c) = &mv(m, k.mv).callout {
            callout(m, k.att, c);
        }
        // look: emit :kikon
    } // look: emit :soul-break for each of SB
    clear_hazards(m);
    crate::cine::cine_stage(m, a, v); // (both set down mid-stage for its shots, given back at its end)
    let sym: &'static str = match kk.get(0) {
        Some(k) => mv(m, k.mv)
            .cine
            .as_deref()
            .or_else(|| crate::core_sim::core_kikon_cine(m, a))
            .unwrap_or_else(|| crate::kit::kit_kikon_cine(m.data, kit_of(m, a))),
        None => crate::core_sim::core_soul_break_cine(m, a),
    };
    let Some(name) = cine_named(m, sym) else { return };
    let after = match kos.len() {
        0 => After::ResetRound(a, v),
        1 => After::MatchOver(Some(opp_of(m, kos.get(0).unwrap()))),
        _ => After::MatchOver(None),
    };
    start_cine(m, name, a, v, Some(after));
}

/// port: RESET-ROUND: after a Kikon / Soul Break: both placed *RESET-DISTANCE* apart facing, *RESET-NEUTRAL* frames of neutral, hazards
/// cleared, the guard gauges full for everyone, the hidden stun cleared, the forms kept (but a kit's :reset-form), flash-step kept, the
/// kit's :reset hook.
pub fn reset_round(m: &mut Match, a: Entity, v: Entity) {
    let (p, q) = (pos_of(m, a), pos_of(m, v));
    let (ax, az, bx, bz) = reset_placement(&m.knobs, p[0], p[2], q[0], q[2]);
    m.transform.get_mut(a).unwrap().pos = [ax, 0.0, az];
    m.transform.get_mut(v).unwrap().pos = [bx, 0.0, bz];
    crate::cine::face_each_other(m, a, v, None);
    if m.pilot.iter().any(|(_, p)| p.cam_relative) {
        crate::unported!(m, "view-step") // (VIEW-STEP with RESET: only a human's stick reads it, docs/bevy/M1_NOTES.md §2; M2)
    }
    clear_hazards(m);
    for e in [a, v] {
        let (lock, gg) = (m.knobs.reset_neutral, m.knobs.gg_max);
        let mo = m.motion.get_mut(e).unwrap();
        (mo.grounded, mo.kb_left) = (true, 0);
        let f = fighter_mut(m, e);
        (f.lock, f.combo_dmg, f.xch, f.xch_done) = (lock, 0, -1, false); // (the reset ends an exchange: DUEL_SP Q11)
        let g = m.gauges.get_mut(e).unwrap();
        (g.gg, g.gg_idle, g.guardless, g.stun) = (gg, 0, false, 0.0);
        if let Some(rf) = kit_of(m, e).reset_form.as_deref() {
            let form = crate::components::Form::from_name(rf).unwrap_or_else(|| panic!("a reset form {rf}"));
            if !set_form(m, e, form) {
                return;
            }
            let g = m.gauges.get_mut(e).unwrap();
            (g.meter, g.meter_idle) = (0.0, 0);
        }
        m.motion.get_mut(e).unwrap().vel = [0.0; 3];
        m.pilot.get_mut(e).expect("a pilot").vpad.clear();
        if fighter(m, e).has_brain {
            crate::unported!(m, "brain-clear") // (the brain lets go of what it held: brain-press-left 0, brain-fresh t; M2)
        }
        if let Some(h) = kit_hook_sym(m, e, "reset")
            && !call_hook(m, e, h)
        {
            return; // (the form's own reset: Hisagi's sickle, M4)
        }
        to_idle(m, e);
    }
    // look: emit :reset
}
