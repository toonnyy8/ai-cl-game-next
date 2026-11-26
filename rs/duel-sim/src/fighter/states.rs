//! port: fighter.lisp "state changes" (START-STEP, START-RUN, START-HOHO) and "per-state steps" for the neutral states (idle,
//! guard, step, run, Hoho, down, wakeup), plus TURN-TO-OPP. Clips, alpha and events are looks (`// look:`).
use super::*;
use crate::cl::{fmt_fixed_f32, min_f32};
use crate::components::Queued;
use crate::math::{angle_wrap, deg, dir_yaw, fwd_x, fwd_z, hypot, turn_toward};
use crate::rules::{brake_speed, hoho_cost, hoho_destination, run_carry, run_stop_p, step_direction, track_step};

/// port: TURN-TO-OPP: E turned toward his opponent (F's OX OZ) by at most MAX-STEP radians (the zero-cons twins: %DIR-YAW,
/// %TURN-TOWARD, %ANGLE-WRAP are DIR-YAW, TURN-TOWARD, ANGLE-WRAP bit for bit).
pub fn turn_to_opp(m: &mut Match, e: Entity, max_step: f32) {
    let f = fighter(m, e);
    if f.dist > 0.01 {
        let (ox, oz) = (f.ox, f.oz);
        let t = m.transform.get_mut(e).expect("a transform");
        let to = dir_yaw(ox - t.pos[0], oz - t.pos[2]);
        t.yaw = angle_wrap(turn_toward(t.yaw, to, max_step));
    }
}

/// `(%deg *face-rate*)`.
fn face_step(m: &Match) -> f32 {
    deg(m.knobs.face_rate)
}

// ---------------------------------------------------------------- state changes

/// port: START-STEP: a hop in the stick direction (neutral = back), iframes *STEP-IFRAMES*, *STEP-FRAMES* f.
pub fn start_step(m: &mut Match, e: Entity) {
    let (to, st) = stick_relative(m, e);
    let (to, st) = step_direction(to, st, -1.0);
    let (dx, dz) = world_dir(m, e, to, st);
    if kit_of(m, e).hooks.contains_key("step-dist") {
        crate::unported!(m, "HS-STEP-DIST") // (a form's own landing: Hisagi's Bankai, M4)
    }
    set_slide(m, e, m.knobs.step_distance, 12, dx, dz);
    let f = fighter_mut(m, e);
    (f.state, f.sf, f.mv, f.queued) = (State::Step, 0, None, None);
    halt(m, e);
    // look: the :step hook (no live kit has one), the step clip
    crate::clog!(m, "{} step", side_name(m, e)); // (a brain's why: none in a brainless replay)
    // look: emit :step
}

/// port: RUN-YAW: the yaw a runner wants (the stick relative to the opponent, neutral = at him).
pub fn run_yaw(m: &mut Match, e: Entity) -> f32 {
    let (to, st) = stick_relative(m, e);
    let (to, st) = step_direction(to, st, 1.0);
    let (dx, dz) = world_dir(m, e, to, st);
    dir_yaw(dx, dz)
}

/// port: START-RUN: Step still held when the hop ends.
pub fn start_run(m: &mut Match, e: Entity) {
    let y = run_yaw(m, e);
    let f = fighter_mut(m, e);
    (f.state, f.sf, f.phase, f.run_yaw) = (State::Run, 0, Some(Phase::Run), y);
    // look: the run clip
    crate::clog!(m, "{} dash", side_name(m, e));
    // look: emit :step
}

/// port: combat.lisp PERFECT-NOW-P: an opponent hit volume (his move's, a hazard's) about to touch E, or his Breaker / Kikon dash
/// near its trigger. Both need a move or a hazard, which only START-MOVE makes: Task 10 ports the tests.
pub fn perfect_now_p(m: &mut Match, e: Entity) -> bool {
    let fo = fighter(m, opp_of(m, e));
    if (fo.state == State::Move && matches!(fo.phase, Some(Phase::Main | Phase::Dash))) || !m.hazard.is_empty() {
        crate::unported!(m, "hit-system", false) // (PERFECT-NOW-P's hit tests, HAZARD-THREAT-P: combat / hazards, Task 10)
    }
    false
}

/// port: START-HOHO: flash-step spent, vanish (HOHO-STEP brings him back behind the opponent); PERFECT checked now.
pub fn start_hoho(m: &mut Match, e: Entity) {
    let g = m.gauges.get(e).expect("gauges");
    let cost = hoho_cost(&m.knobs, g.fs, g.burst, g.burn);
    spend_fs(m, e, cost);
    if m.gauges.get(e).unwrap().burst == Some(Burst::Blue) {
        burst_end(m, e); // BLUE's Hoho used up the burning cell
    }
    {
        let f = fighter_mut(m, e);
        let from = (f.state == State::Move && f.contact == Some(Contact::Hit) && matches!(f.cls, Some(crate::components::Cls::Na | crate::components::Cls::Sa | crate::components::Cls::Ns)))
            .then_some(f.mv)
            .flatten();
        (f.hoho_from, f.hoho_cls, f.hoho_presses, f.hoho_mult, f.hoho_left, f.queued) = (from, f.cls, f.presses, f.charge_mult, 0, None);
    }
    let perfect = perfect_now_p(m, e); // (before leaving the move: a cancel Hoho)
    let (tick, lock) = (m.match_tick, m.knobs.hoho_frames + m.knobs.hoho_lockout);
    let f = fighter_mut(m, e);
    (f.perfect, f.state, f.sf, f.mv, f.state_t, f.hoho_lock) = (perfect, State::Hoho, 0, None, tick, lock);
    halt(m, e);
    // look: emit :hoho-out
    crate::clog!(m, "{} hoho", side_name(m, e));
    if perfect {
        let o = opp_of(m, e);
        m.gauges.get_mut(e).unwrap().perfects += 1;
        fighter_mut(m, o).lock_next = m.knobs.perfect_lock;
        respect(m, o);
        let (sc, secs) = (m.knobs.perfect_slowmo_scale, m.knobs.perfect_slowmo_seconds);
        m.time.slowmo(sc, secs, false);
        // look: emit :perfect
        crate::clog!(m, "{} PERFECT HOHO", side_name(m, e));
    }
}

// ---------------------------------------------------------------- per-state steps

/// port: GUARD-HELD-P: Guard held and E may guard. ponytail: always NIL — the core system has no guard (`(not (kit-core …))`),
/// and every kit in the data has a :core (Kit.core is required).
pub fn guard_held_p(_m: &Match, _e: Entity) -> bool {
    false
}

/// port: NEUTRAL-STEP: idle / walk / strafe / guard: commands, then guard or walk, auto-facing.
pub fn neutral_step(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    if f.lock == 0 && f.kikon_lock == 0 {
        let started = if f.guard_exit > 0 || f.state == State::Guard {
            command(m, e, &GUARD_COMMANDS)
        } else {
            hoho_resume_press(m, e) || command(m, e, &NEUTRAL_COMMANDS)
        };
        if started {
            return;
        }
    }
    let f = fighter(m, e);
    if f.lock == 0 && f.kikon_lock < 2 && guard_held_p(m, e) {
        if f.state != State::Guard {
            let tick = m.match_tick;
            let f = fighter_mut(m, e);
            (f.state, f.guard_t, f.state_t) = (State::Guard, 0, tick);
            if m.pilot.get(e).unwrap().cam_relative {
                crate::clog!(m, "{} guard", side_name(m, e));
            }
            // look: the guard clip
        }
        fighter_mut(m, e).guard_t += 1;
        m.motion.get_mut(e).unwrap().vel = [0.0; 3];
    } else {
        let (to, st) = if f.lock == 0 && f.guard_exit == 0 && f.kikon_lock == 0 { stick_relative(m, e) } else { (0.0, 0.0) };
        if fighter(m, e).state == State::Guard {
            to_idle(m, e);
            fighter_mut(m, e).guard_exit = m.knobs.guard_exit;
        }
        fighter_mut(m, e).guard_t = 0;
        neutral_walk(m, e, to, st);
    }
    turn_to_opp(m, e, face_step(m));
}

/// port: NEUTRAL-WALK!'s single-float path (the sim's: sticks and walk speeds are single-floats): velocity at stick TO / ST, or
/// stand (a stick under 0.2).
pub fn neutral_walk(m: &mut Match, e: Entity, to: f32, st: f32) {
    let walk = kit_of(m, e).walk;
    let speed = sub_speed_mult(m, e) * walk;
    let mag = libm::sqrtf(to * to + st * st); // (%sqrt)
    if mag < 0.2 || walk <= 0.0 {
        m.motion.get_mut(e).unwrap().vel = [0.0; 3];
        // look: the stance clip
    } else {
        let (dx, dz) = world_dir(m, e, to, st); // (WITH-TOWARD-STRAFE-DIR: TOWARD-STRAFE-DIR's single-float path)
        let s = (speed * min_f32(1.0, mag)) * (1.0 / mag);
        let v = &mut m.motion.get_mut(e).unwrap().vel;
        (v[0], v[2]) = (s * dx, s * dz);
        // look: the walk / strafe clip
    }
}

/// port: STEP-STEP: the hop; at its end a Step still held becomes a run. A J pressed in the hop is latched; from
/// *STEP-J-CANCEL* it cancels the rest into J1.
pub fn step_step(m: &mut Match, e: Entity) {
    let (_, jb, jm) = COMMANDS[5]; // (find :q *commands*)
    if fighter(m, e).lock == 0 && vpad(m, e).command_pressed_p(jb as usize, jm) {
        vpad(m, e).consume(jb as usize);
        fighter_mut(m, e).queued = Some(Queued::Q);
    }
    let f = fighter(m, e);
    if f.queued.is_some() && f.sf >= m.knobs.step_j_cancel && f.gc_left == 0 && try_command(m, e, Cmd::Q, Some(jb)) {
        return;
    }
    let frames = m.knobs.step_frames;
    let f = fighter_mut(m, e);
    f.sf += 1;
    if f.sf >= frames {
        f.queued = None;
        let free = f.lock == 0;
        if free && vpad(m, e).down(Button::Step as usize) {
            start_run(m, e);
        } else {
            to_idle(m, e);
        }
    }
}

/// port: RUN-VELOCITY: E moves at SPEED along YAW.
pub fn run_velocity(m: &mut Match, e: Entity, speed: f32, yaw: f32) {
    let v = &mut m.motion.get_mut(e).unwrap().vel;
    (v[0], v[2]) = (speed * fwd_x(yaw), speed * fwd_z(yaw));
}

/// port: RUN-CLOSING: the fraction (-1..1) of E's run heading that points at his opponent.
pub fn run_closing(m: &Match, e: Entity) -> f32 {
    let (p, f) = (pos_of(m, e), fighter(m, e));
    let (yaw, d) = (f.run_yaw, f.dist);
    if d < 0.01 { 0.0 } else { (fwd_x(yaw) * (f.ox - p[0]) + fwd_z(yaw) * (f.oz - p[2])) / d }
}

/// port: RUN-STEP: a command cancels the run (a move keeps RUN-CARRY), Guard stops it, releasing Step brakes; else run toward
/// the stick direction, facing the opponent.
pub fn run_step(m: &mut Match, e: Entity) {
    let [vx, _, vz] = m.motion.get(e).unwrap().vel;
    let speed = sub_speed_mult(m, e) * kit_of(m, e).run;
    let f = fighter_mut(m, e);
    f.sf += 1;
    let (sf, free, phase) = (f.sf, f.lock == 0, f.phase);
    if phase == Some(Phase::Brake) {
        let s = if run_stop_p(&m.knobs, fighter(m, e).dist, run_closing(m, e), speed) { 0.0 } else { brake_speed(&m.knobs, speed, sf) };
        turn_to_opp(m, e, face_step(m));
        if s <= 0.0 || sf >= m.knobs.run_brake {
            to_idle(m, e);
        } else {
            let y = fighter(m, e).run_yaw;
            run_velocity(m, e, s, y);
        }
    } else if free && command(m, e, if kit_of(m, e).run_awaken { &RUN_COMMANDS_P } else { &RUN_COMMANDS }) {
        if let Some(id) = current_move(fighter(m, e)) {
            let carry = run_carry(&m.knobs, fighter(m, e).dist);
            set_slide(m, e, carry, m.knobs.run_carry_frames, vx, vz);
            crate::clog!(m, "{} run -> {}, carry {} m", side_name(m, e), mv(m, id).name.to_uppercase(), fmt_fixed_f32(carry, 1));
        }
    } else if free && guard_held_p(m, e) {
        to_idle(m, e);
        neutral_step(m, e);
    } else if !(free && vpad(m, e).down(Button::Step as usize)) {
        let f = fighter_mut(m, e);
        (f.phase, f.sf) = (Some(Phase::Brake), 0);
        // look: the stance clip
    } else {
        let (want, turn) = (run_yaw(m, e), track_step(m.knobs.run_turn));
        let f = fighter_mut(m, e);
        f.run_yaw = angle_wrap(turn_toward(f.run_yaw, want, turn));
        turn_to_opp(m, e, face_step(m));
        if run_stop_p(&m.knobs, fighter(m, e).dist, run_closing(m, e), speed) {
            to_idle(m, e);
        } else {
            let y = fighter(m, e).run_yaw;
            run_velocity(m, e, speed, y);
            // look: the run clip
        }
    }
}

/// port: HOHO-PRESS: the first of SP / J pressed this step (in `*commands*` order).
pub fn hoho_press(m: &mut Match, e: Entity) -> Option<(Cmd, Button)> {
    COMMANDS
        .into_iter()
        .find(|&(c, b, md)| matches!(c, Cmd::Sp | Cmd::Q) && vpad(m, e).command_pressed_p(b as usize, md))
        .map(|(c, b, _)| (c, b))
}

/// port: HOHO-RESUME-PRESS!: neutral, inside the resume window after a combo's Hoho, J / SP resumes it.
pub fn hoho_resume_press(m: &mut Match, e: Entity) -> bool {
    let f = fighter(m, e);
    if f.hoho_left > 0 && f.hoho_from.is_some() && f.lock == 0
        && let Some((cmd, b)) = hoho_press(m, e)
        && hoho_resume(m, e, cmd)
    {
        vpad(m, e).consume(b as usize);
        return true;
    }
    false
}

/// port: HOHO-STEP: vanish, reappear behind the opponent on *HOHO-APPEAR* facing him; off a landed combo move a J / SP pressed
/// in it is latched and resumes the combo at its end.
pub fn hoho_step(m: &mut Match, e: Entity) {
    if fighter(m, e).hoho_from.is_some()
        && let Some((cmd, b)) = hoho_press(m, e)
    {
        vpad(m, e).consume(b as usize);
        fighter_mut(m, e).queued = Some(if cmd == Cmd::Sp { Queued::Sp } else { Queued::Q });
    }
    let f = fighter_mut(m, e);
    f.sf += 1;
    let sf = f.sf;
    let o = opp_of(m, e);
    // look: model-alpha
    if sf == m.knobs.hoho_appear {
        let q = pos_of(m, o);
        let (x, z, yaw) = hoho_destination(&m.knobs, q[0], q[2], yaw_of(m, o));
        let t = m.transform.get_mut(e).unwrap();
        (t.pos[0], t.pos[2], t.yaw) = (x, z, yaw);
        // look: the arrival clip, emit :hoho-in, the :hoho hook (no live kit has one)
    }
    // look: a perfect Hoho's counter pose
    if sf >= m.knobs.hoho_frames {
        to_idle(m, e);
        if fighter(m, e).hoho_from.is_some() {
            fighter_mut(m, e).hoho_left = m.knobs.hoho_resume_frames;
            if let Some(q) = fighter(m, e).queued {
                hoho_resume(m, e, if q == Queued::Sp { Cmd::Sp } else { Cmd::Q });
            }
        }
    }
}

/// port: AIR-STEP: airborne until landing (Burst Reverse may be pressed), then :down *REACTION-FRAMES* :down f and :wakeup (a back
/// roll with a stick), both invulnerable, facing the opponent.
pub fn air_step(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    if f.state == State::Air && f.lock == 0 {
        command(m, e, &[Cmd::Burst, Cmd::Awaken]);
    }
    let f = fighter_mut(m, e);
    f.sf += 1;
    let (sf, state, phase) = (f.sf, f.state, f.phase);
    match state {
        State::Air => {
            if m.motion.get(e).unwrap().grounded && sf > 2 {
                let f = fighter_mut(m, e);
                (f.state, f.sf) = (State::Down, 0);
                // look: the down clip, emit :land
            }
        }
        State::Down => {
            if sf >= m.knobs.reaction_frames.get("down", i64::MAX) {
                let f = fighter_mut(m, e);
                (f.state, f.sf) = (State::Wakeup, 0);
                let (to, st) = stick_relative(m, e);
                if hypot(to, st) < 0.3 {
                    // look: the wakeup clip
                } else {
                    let (to, st) = step_direction(to, st, -1.0);
                    let (dx, dz) = world_dir(m, e, to, st);
                    // a back roll whichever way: his back leads, then he turns to the opponent (DEVLOG §614)
                    fighter_mut(m, e).phase = Some(Phase::Roll);
                    m.transform.get_mut(e).unwrap().yaw = dir_yaw(-dx, -dz);
                    set_slide(m, e, m.knobs.roll_distance, m.knobs.roll_frames, dx, dz);
                    // look: the roll clip
                    crate::clog!(m, "{} roll", side_name(m, e));
                }
            }
        }
        State::Wakeup => {
            if !(phase == Some(Phase::Roll) && sf < m.knobs.roll_frames) {
                turn_to_opp(m, e, face_step(m));
            }
            if sf >= m.knobs.reaction_frames.get("wakeup", i64::MAX) {
                to_idle(m, e);
            }
        }
        _ => {}
    }
}
