//! port: duel/lisp/control.lisp — its pure helpers. Not sim (skipped): the bindings, SETTINGS, the PRACTICE dummy
//! (`dummy-*`), ONE-HAND's device read (`one-hand-on-p`).
use crate::cl::max_f32;
use crate::components::State;
use crate::knobs::Knobs;
use crate::math::{f_abs, f_sqrt, fwd_x, fwd_z};

// port: control.lisp UP-FLICK-HOHO-P
pub fn up_flick_hoho_p(state: State, step_branch: bool, perfect: bool) -> bool {
    (state == State::Move && !step_branch) || perfect
}

// port: control.lisp RV-BUTTONS → (hold, tap)
pub fn rv_buttons(down: bool, hold: bool, tap: bool) -> (bool, bool) {
    (down && hold, down || tap)
}

// port: control.lisp WAVE-ARRIVAL (LEFT default most-positive-fixnum: i64::MAX) — (ceiling single single): an f32 divide
#[allow(clippy::too_many_arguments)]
pub fn wave_arrival(dx: f32, dz: f32, yaw: f32, step: f32, hw: f32, hl: f32, tr: f32, left: i64) -> Option<i64> {
    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
    let lx = f_abs(dx * -fz + dz * fx);
    let lz = dx * fx + dz * fz;
    let ex = max_f32(0.0, lx - hw);
    if !(ex <= tr && step > 0.0) {
        return None;
    }
    let k = ((lz - hl - f_sqrt(tr * tr - ex * ex)) / step).ceil() as i64;
    (k >= 1 && k <= left).then_some(k)
}

// port: control.lisp PRACTICE-REISHI — both fixnums (*practice-hp* holds integers), so an integer CEILING
pub fn practice_reishi(reishi_max: i64, pct: i64) -> i64 {
    1.max(-crate::cl::floor_div(-(reishi_max * pct), 100))
}

// port: control.lisp KONPAKU-STEP
pub fn konpaku_step(k: i64, dir: i64, kmax: i64) -> i64 {
    1 + crate::cl::modulo(k - 1 + dir, kmax)
}

// port: control.lisp KONPAKU-AT-STAKE
pub fn konpaku_at_stake(kn: &Knobs, konpaku: i64, count: i64) -> i64 {
    crate::rules::kikon_result(kn, konpaku, count, false).1
}
