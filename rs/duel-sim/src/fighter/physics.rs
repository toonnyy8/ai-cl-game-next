//! port: fighter.lisp "physics" (FIGHTER-PHYSICS, SEPARATE-FIGHTERS, THROUGH-MOVE-P) and SET-SLIDE.
use super::*;
use crate::cl::max_f32;
use crate::math::{f_abs, f_hypot, hypot};
use crate::time::STEP;

/// port: SET-SLIDE: E slides DIST metres over FRAMES along (DX DZ): `(/ dist (max 1 frames) l)` left to right.
pub fn set_slide(m: &mut Match, e: Entity, dist: f32, frames: i64, dx: f32, dz: f32) {
    let l = max_f32(1e-4, hypot(dx, dz));
    let k = dist / frames.max(1) as f32 / l;
    let mo = m.motion.get_mut(e).expect("a motion");
    (mo.kb[0], mo.kb[2], mo.kb_left) = (dx * k, dz * k, frames);
}

/// port: FIGHTER-PHYSICS: walk / dash velocity, the slide, gravity and landing, the arena wall.
pub fn fighter_physics(m: &mut Match, e: Entity) {
    let r = m.knobs.arena_radius - hurt_r(m, e);
    let g = m.knobs.gravity;
    let dt = STEP;
    let mo = m.motion.get_mut(e).expect("a motion");
    let p = &mut m.transform.get_mut(e).expect("a transform").pos;
    p[0] += dt * mo.vel[0];
    p[2] += dt * mo.vel[2];
    if mo.kb_left > 0 {
        p[0] += mo.kb[0];
        p[2] += mo.kb[2];
        mo.kb_left -= 1;
    }
    if !mo.grounded {
        mo.vel[1] -= g * dt;
        p[1] += dt * mo.vel[1];
        if p[1] <= 0.0 && mo.vel[1] <= 0.0 {
            (p[1], mo.vel[1], mo.grounded) = (0.0, 0.0, true);
        }
    }
    let (x, z) = (p[0], p[2]);
    let d = f_hypot(x, z);
    if d > r {
        (p[0], p[2]) = (x * (r / d), z * (r / d));
    }
}

/// port: THROUGH-MOVE-P: E in a move flagged :through.
pub fn through_move_p(m: &Match, e: Entity) -> bool {
    let f = fighter(m, e);
    f.state == State::Move && f.mv.is_some_and(|id| mv(m, id).flags.iter().any(|x| x == "through"))
}

/// port: SEPARATE-FIGHTERS: two grounded fighters never overlap (pushed apart equally); not in a Hoho, a cinematic or a
/// :through move.
pub fn separate_fighters(m: &mut Match, a: Entity, b: Entity) {
    let skip = |s| matches!(s, Some(State::Hoho | State::Cine));
    if skip(state_of(m, a)) || skip(state_of(m, b)) || through_move_p(m, a) || through_move_p(m, b) {
        return;
    }
    let (p, q) = (pos_of(m, a), pos_of(m, b));
    let (ra, rb) = (hurt_r(m, a), hurt_r(m, b));
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let d = libm::sqrtf(dx * dx + dz * dz); // (%sqrt)
    let min_d = ra + rb;
    if d < min_d && f_abs(p[1] - q[1]) < 1.2 {
        let push = 0.5 * (min_d - d);
        let (ux, uz) = if d > 1e-3 { (dx / d, dz / d) } else { (1.0, 0.0) };
        let pa = &mut m.transform.get_mut(a).unwrap().pos;
        (pa[0], pa[2]) = (pa[0] - push * ux, pa[2] - push * uz);
        let pb = &mut m.transform.get_mut(b).unwrap().pos;
        (pb[0], pb[2]) = (pb[0] + push * ux, pb[2] + push * uz);
    }
}
