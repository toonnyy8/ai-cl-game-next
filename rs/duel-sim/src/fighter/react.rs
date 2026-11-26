//! port: fighter.lisp "reactions (called by combat.lisp)": the reactions and blockstun, the defender's side of the triangle, the
//! Breaker phase; and the per-state steps that run a reaction (STUN-STEP, AIR-STEP's :air).
use super::*;

/// port: BREAKER-PHASE: E's Breaker phase for BREAKER-CLASH-P: :aura :dash :strike (strike startup / active) or NIL.
pub fn breaker_phase(m: &Match, e: Entity) -> Option<Phase> {
    let f = fighter(m, e);
    let id = current_move(f)?;
    let mvd = mv(m, id);
    if mvd.kind != "breaker" {
        return None;
    }
    match f.phase {
        Some(p @ (Phase::Aura | Phase::Dash)) => Some(p),
        _ => (f.sf < (mvd.s + mvd.a) as i64).then_some(Phase::Strike),
    }
}

// ---------------------------------------------------------------- the reaction steps

/// port: STUN-STEP: a reaction / blockstun counts down (Burst may be pressed), then neutral. Blockstun past its end waits while the
/// guard lock holds him; a combo's Hoho holds the reaction (HOHO-HOLDS-P). Under a Kikon lock no Burst; lock 1 (not red): an
/// attack cancels the follow-up (CORE-KIKON-CANCEL!).
pub fn stun_step(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    if f.kikon_lock == 1 && f.state == State::Stun && vpad(m, e).command_pressed_p(Button::Quick as usize, Mod::No) {
        vpad(m, e).consume(Button::Quick as usize);
        crate::core_sim::core_kikon_cancel(m, e);
        return;
    }
    let f = fighter(m, e);
    if f.lock == 0 && f.kikon_lock == 0 {
        command(m, e, &[Cmd::Burst, Cmd::Awaken]);
    }
    let f = fighter_mut(m, e);
    f.sf += 1;
    if f.sf >= f.stun && !(f.state == State::GuardHit && f.glock) && !hoho_holds_p(m, e) {
        to_idle(m, e);
        // ponytail: the guard raised after it (GUARD-HELD-P) never: NIL in the core system
    }
}

/// port: HOHO-HOLDS-P: does F's attacker hold F's reaction through a combo's Hoho (in it, its resume window, or the resumed move's
/// startup / active frames)?
pub fn hoho_holds_p(m: &Match, e: Entity) -> bool {
    let o = opp_of(m, e);
    let Some(fo) = m.ents.alive(o).then(|| m.fighter.get(o)).flatten() else { return false };
    (fo.hoho_from.is_some() && (fo.state == State::Hoho || fo.hoho_left > 0))
        || (fo.hoho_hold
            && fo.state == State::Move
            && fo.phase == Some(Phase::Main)
            && fo.mv.is_some_and(|id| fo.sf < (mv(m, id).s + mv(m, id).a) as i64))
}

/// port: GUARD-LOCKED-NOW-P: is F held past his blockstun's end by the guard lock right now?
pub fn guard_locked_now_p(f: &Fighter) -> bool {
    f.state == State::GuardHit && f.glock && f.sf >= f.stun
}

// ---------------------------------------------------------------- reactions (called by combat)

/// port: SET-REACTION: put E into reaction REACT (`:flinch :stagger :knockback :guard-break :crumple :clash :bind`, `:launch` /
/// `:knockdown` airborne; STUN frames for the grounded ones), pushed KB metres away from (FROM-X FROM-Z). Nothing while down.
pub fn set_reaction(m: &mut Match, e: Entity, react: Option<Phase>, stun: i64, from_x: f32, from_z: f32, kb: f32) {
    let p = pos_of(m, e);
    let (dx, dz) = (p[0] - from_x, p[2] - from_z);
    let f = fighter(m, e);
    let air = f.state == State::Air;
    if matches!(f.state, State::Down | State::Wakeup) {
        return;
    }
    let f = fighter_mut(m, e);
    (f.mv, f.sf, f.phase) = (None, 0, react);
    halt(m, e);
    let launch = matches!(react, Some(Phase::Launch | Phase::Knockdown));
    if air || launch {
        fighter_mut(m, e).state = State::Air;
        let vy = m.knobs.air_vy.get(if launch { react.unwrap().name() } else { "air" });
        let mo = m.motion.get_mut(e).unwrap();
        (mo.grounded, mo.vel[1]) = (false, vy);
        let d = if kb > 0.0 { m.knobs.air_slide * kb } else { 1.0 };
        set_slide(m, e, d, m.knobs.air_slide_frames, dx, dz);
        // look: the launch clip, emit :launch
    } else {
        let f = fighter_mut(m, e);
        (f.state, f.stun) = (State::Stun, stun);
        if kb > 0.0 {
            set_slide(m, e, kb, stun.min(m.knobs.knockback_slide_frames), dx, dz);
        }
        // look: the reaction's clip
    }
}

/// port: SET-BLOCKSTUN: blockstun of STUN frames, pushed back from (FROM-X FROM-Z) (its clip a look).
pub fn set_blockstun(m: &mut Match, e: Entity, stun: i64, from_x: f32, from_z: f32) {
    let p = pos_of(m, e);
    let f = fighter_mut(m, e);
    (f.state, f.sf, f.stun, f.mv) = (State::GuardHit, 0, stun, None);
    halt(m, e);
    set_slide(m, e, m.knobs.block_pushback, 6, p[0] - from_x, p[2] - from_z);
}

/// port: OWN-ARMOR-P: is E's move ID armoured now: its :armor-hits left (from *ARMOR-FROM* to its startup's end, or a Kikon rush's
/// dash), or the kit's :armor hook (KEN-ARMOR)?
pub fn own_armor_p(m: &mut Match, e: Entity, id: MoveId) -> bool {
    let (f, mvd) = (fighter(m, e), mv(m, id));
    let own = f.armor_left > 0
        && if mvd.kind == "kikon" {
            f.phase == Some(Phase::Dash)
        } else {
            f.phase == Some(Phase::Main) && m.knobs.armor_from <= f.sf && f.sf < mvd.s as i64
        };
    own || match kit_hook_sym(m, e, "armor") {
        None => false,
        Some(h) => match ken_hook(h) {
            Some(crate::ken::Hook::Armor) => crate::ken::hooks::armor(m, e, mvd),
            _ => crate::unported!(m, h, false),
        },
    }
}

/// port: DEFENDER-STATE: E's side of the triangle for RESOLVE-CONTACT.
pub fn defender_state(m: &mut Match, e: Entity) -> crate::rules::DefState {
    use crate::rules::DefState as D;
    let f = fighter(m, e);
    let sf = f.sf;
    if f.invuln > 0 {
        return D::Invuln; // after a Burst
    }
    match f.state {
        State::Idle | State::Run => D::Neutral,
        State::Guard => {
            let g = m.gauges.get(e).unwrap();
            if f.guard_t >= m.knobs.guard_raise && crate::rules::can_guard_p(g.gg, g.guardless) { D::Guard } else { D::Neutral }
        }
        State::GuardHit => D::Guard,
        State::Step => {
            if crate::rules::invulnerable_frame_p(sf, Some((m.knobs.step_iframes.0, m.knobs.step_iframes.1))) { D::Invuln } else { D::Neutral }
        }
        State::Hoho => {
            if crate::rules::invulnerable_frame_p(sf, Some((m.knobs.hoho_iframes.0, m.knobs.hoho_iframes.1))) { D::Invuln } else { D::Neutral }
        }
        State::Down | State::Wakeup | State::Cine | State::Intro | State::Win | State::Lose => D::Invuln,
        State::Air => if f.phase == Some(Phase::Knockdown) { D::Invuln } else { D::Neutral }, // the combo limits' knockdown
        State::Move => {
            let id = f.mv.expect("a move in :move");
            let mvd = mv(m, id);
            let (phase, hold) = (f.phase, f.hold);
            if mvd.kind == "breaker" && (matches!(phase, Some(Phase::Aura | Phase::Dash)) || sf < mvd.s as i64) {
                D::Breaker
            } else if own_armor_p(m, e, id) {
                D::Armor
            } else if mvd.flags.iter().any(|x| x == "stance") && phase == Some(Phase::Hold) {
                if hold < m.knobs.stance_in { D::StanceIn } else { D::Stance }
            } else if mvd.flags.iter().any(|x| x == "parry")
                && phase == Some(Phase::Main)
                && crate::rules::parry_frame_p(&m.knobs, sf, mvd.params.window.map(|[a, b]| (a as i64, b as i64)))
            {
                D::Parry
            } else {
                D::Neutral
            }
        }
        State::Stun => D::Neutral,
    }
}
