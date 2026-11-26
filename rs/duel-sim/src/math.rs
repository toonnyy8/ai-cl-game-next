//! Scalar and facing math the sim reads (engine/lisp/math.lisp, package.lisp's F- macros, rules.lisp DIR-YAW), single-float
//! throughout. Yaw 0 faces -Z; the facing direction is (fwd_x, 0, fwd_z) = (-sin yaw, 0, -cos yaw).
use crate::cl::{max_f32, min_f32};

/// port: duel/lisp/rules.lisp +PI+ `#.(float pi 1f0)`.
pub const PI: f32 = std::f32::consts::PI; // 0x40490FDB
/// port: duel/lisp/rules.lisp +TWO-PI+ `#.(float (* 2 pi) 1f0)` (also ANGLE-WRAP's TAU).
pub const TWO_PI: f32 = std::f32::consts::TAU; // 0x40C90FDB
/// `#.(float (/ pi 180) 1f0)` from the image (the long-float pi, rounded once).
const DEG_PER_RAD: f32 = f32::from_bits(0x3C8E_FA35);

/// port: engine/lisp/math.lisp DEG (the argument is first made a single: `(float d 1f0)`, the caller's `as f32`).
pub fn deg(d: f32) -> f32 {
    d * DEG_PER_RAD
}
/// port: engine/lisp/math.lisp ANGLE-WRAP: a - tau·ffloor(a + pi, tau), FFLOOR being floorf of the single quotient.
pub fn angle_wrap(a: f32) -> f32 {
    a - TWO_PI * libm::floorf((a + PI) / TWO_PI)
}
/// port: engine/lisp/math.lisp FWD-X.
pub fn fwd_x(yaw: f32) -> f32 {
    -libm::sinf(yaw)
}
/// port: engine/lisp/math.lisp FWD-Z.
pub fn fwd_z(yaw: f32) -> f32 {
    -libm::cosf(yaw)
}
/// port: engine/lisp/math.lisp YAW-TO (atan2f in float C).
pub fn yaw_to(dx: f32, dz: f32) -> f32 {
    libm::atan2f(-dx, -dz)
}
/// port: duel/lisp/rules.lisp DIR-YAW: CL ATAN of two singles = ECL ecl_atan2, a double atan2 rounded to single. Not YAW-TO
/// (they differ in the last bit). A double argument in the Lisp would return a double: callers pass singles.
pub fn dir_yaw(dx: f32, dz: f32) -> f32 {
    libm::atan2(-dx as f64, -dz as f64) as f32
}
/// port: engine/lisp/math.lisp TURN-TOWARD.
pub fn turn_toward(cur: f32, target: f32, step: f32) -> f32 {
    cur + clamp(angle_wrap(target - cur), -step, step)
}
/// port: engine/lisp/package.lisp LERP (single arguments).
pub fn lerp(a: f32, b: f32, u: f32) -> f32 {
    a + (b - a) * u
}
/// port: engine/lisp/package.lisp CLAMP `(max lo (min hi x))`, CL's MIN / MAX (never panics, lo wins when lo > hi).
pub fn clamp(x: f32, lo: f32, hi: f32) -> f32 {
    max_f32(lo, min_f32(hi, x))
}
/// port: engine/lisp/package.lisp F-MIN = musl fminf (a NaN loses; of two zeros the negative one). Not `libm::fminf`, which
/// returns the second zero.
pub fn f_min(a: f32, b: f32) -> f32 {
    if a.is_nan() {
        b
    } else if b.is_nan() {
        a
    } else if a.is_sign_negative() != b.is_sign_negative() {
        if a.is_sign_negative() { a } else { b }
    } else if a < b {
        a
    } else {
        b
    }
}
/// port: engine/lisp/package.lisp F-MAX = musl fmaxf (a NaN loses; of two zeros the positive one).
pub fn f_max(a: f32, b: f32) -> f32 {
    if a.is_nan() {
        b
    } else if b.is_nan() {
        a
    } else if a.is_sign_negative() != b.is_sign_negative() {
        if a.is_sign_negative() { b } else { a }
    } else if a < b {
        b
    } else {
        a
    }
}
/// port: engine/lisp/package.lisp F-ABS (fabsf).
pub fn f_abs(a: f32) -> f32 {
    a.abs()
}
/// port: engine/lisp/package.lisp F-SQRT (sqrtf of fmaxf(a, 0)).
pub fn f_sqrt(a: f32) -> f32 {
    libm::sqrtf(f_max(a, 0.0))
}
/// port: engine/lisp/package.lisp F-SIN.
pub fn f_sin(a: f32) -> f32 {
    libm::sinf(a)
}
/// port: engine/lisp/package.lisp F-COS.
pub fn f_cos(a: f32) -> f32 {
    libm::cosf(a)
}
/// port: engine/lisp/package.lisp F-MOD (fmodf).
pub fn f_mod(x: f32, y: f32) -> f32 {
    libm::fmodf(x, y)
}
/// port: engine/lisp/math.lisp HYPOT of two singles: CL SQRT of (+ (* a a) (* b b)), in that order.
pub fn hypot(a: f32, b: f32) -> f32 {
    libm::sqrtf(a * a + b * b)
}
/// port: engine/lisp/math.lisp HYPOT of three singles.
pub fn hypot3(a: f32, b: f32, c: f32) -> f32 {
    libm::sqrtf(a * a + b * b + c * c)
}
/// port: engine/lisp/package.lisp F-HYPOT of two singles (F-SQRT of the same sum).
pub fn f_hypot(a: f32, b: f32) -> f32 {
    f_sqrt(a * a + b * b)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cl::vectors::rows;

    fn same(name: &str, got: f32, want: f32) {
        assert_eq!(
            got.to_bits(),
            want.to_bits(),
            "{name}: got {got} want {want}"
        );
    }

    #[test]
    fn math_matches_lisp() {
        for r in rows("deg") {
            same("deg", deg(r.args[0].as_f32()), r.out[0].s());
        }
        for r in rows("angle-wrap") {
            same("angle-wrap", angle_wrap(r.args[0].s()), r.out[0].s());
        }
        for r in rows("fwd-x") {
            same("fwd-x", fwd_x(r.args[0].s()), r.out[0].s());
        }
        for r in rows("fwd-z") {
            same("fwd-z", fwd_z(r.args[0].s()), r.out[0].s());
        }
        for r in rows("dir-yaw") {
            same(
                "dir-yaw",
                dir_yaw(r.args[0].s(), r.args[1].s()),
                r.out[0].s(),
            );
        }
        for r in rows("yaw-to") {
            same("yaw-to", yaw_to(r.args[0].s(), r.args[1].s()), r.out[0].s());
        }
        for r in rows("turn-toward") {
            same(
                "turn-toward",
                turn_toward(r.args[0].s(), r.args[1].s(), r.args[2].s()),
                r.out[0].s(),
            );
        }
        for r in rows("lerp") {
            same(
                "lerp",
                lerp(r.args[0].s(), r.args[1].s(), r.args[2].s()),
                r.out[0].s(),
            );
        }
        for r in rows("clamp") {
            same(
                "clamp",
                clamp(r.args[0].s(), -1.0, r.args[1].s()),
                r.out[0].s(),
            );
        }
    }

    #[test]
    fn constants() {
        assert_eq!(PI.to_bits(), 0x40490FDB);
        assert_eq!(TWO_PI.to_bits(), 0x40C90FDB);
        assert_eq!(f_min(0.0, -0.0).to_bits(), 0x8000_0000);
        assert_eq!(f_max(-0.0, 0.0).to_bits(), 0);
        assert_eq!(hypot(3.0, 4.0), 5.0);
    }
}
