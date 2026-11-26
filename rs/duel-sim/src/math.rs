//! Scalar and facing math the sim reads (engine/lisp/math.lisp, package.lisp's F- macros, rules.lisp DIR-YAW), single-float
//! throughout. Yaw 0 faces -Z; the facing direction is (fwd_x, 0, fwd_z) = (-sin yaw, 0, -cos yaw).
use crate::cl::{max_f32, min_f32};

pub use crate::consts::{PI, TWO_PI};
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
/// The answer key's `sincosf` (glibc 2.39 i686, the SSE2 IFUNC of sysdeps/ieee754/flt-32/s_sincosf.c, ARM's optimized-routines
/// algorithm in strict double): (sin x, cos x). gcc -O2 fuses a C function's `sinf(a)` and `cosf(a)` of one value into one
/// `sincosf` call, and the native sim's musl preload (tools/simlib.py MUSL_MATH) has no sincosf, so those sites take glibc's
/// values while every lone `sinf` / `cosf` is musl's (`libm`). The fused sim sites (calls to sincosf in the unit's object,
/// Task 12): VOL-HIT-P's yawed cap, OBOX-CYL-HIT-P, ICHIGO-NS-SLOT, ICHIGO-HASTE-DASH, CLONE-WAVE (and looks / CPU / Hisagi /
/// Yamamoto code: WAVE-ARRIVAL, STICK-TOWARD-STRAFE, RUN-CLIP, …, ported with them). Table and constants read off the binary.
pub fn sincosf(y: f32) -> (f32, f32) {
    struct T {
        sign: [f64; 4],
        hpi_inv: f64,
        hpi: f64,
        c0: f64,
        c1: f64,
        s1: f64,
        c2: f64,
        s2: f64,
        c3: f64,
        s3: f64,
        c4: f64,
    }
    const fn t(neg: f64) -> T {
        T {
            sign: [1.0, -1.0, -1.0, 1.0],
            hpi_inv: f64::from_bits(0x4164_5F30_6DC9_C883),
            hpi: f64::from_bits(0x3FF9_21FB_5444_2D18),
            c0: neg * 1.0,
            c1: neg * f64::from_bits(0xBFDF_FFFF_FD0C_621C),
            s1: f64::from_bits(0xBFC5_5554_5995_A603),
            c2: neg * f64::from_bits(0x3FA5_5553_E106_8F19),
            s2: f64::from_bits(0x3F81_1076_0523_0BC4),
            c3: neg * f64::from_bits(0xBF56_C087_E89A_359D),
            s3: f64::from_bits(0xBF29_94EB_3774_CF24),
            c4: neg * f64::from_bits(0x3EF9_9343_027B_F8C3),
        }
    }
    const TABLE: [T; 2] = [t(1.0), t(-1.0)];
    const INV_PIO4: [u32; 24] = [
        0xa2, 0xa2f9, 0xa2f983, 0xa2f9836e, 0xf9836e4e, 0x836e4e44, 0x6e4e4415, 0x4e441529, 0x441529fc, 0x1529fc27, 0x29fc2757,
        0xfc2757d1, 0x2757d1f5, 0x57d1f534, 0xd1f534dd, 0xf534ddc0, 0x34ddc0db, 0xddc0db62, 0xc0db6295, 0xdb629599, 0x6295993c,
        0x95993c43, 0x993c4390, 0x3c439041,
    ];
    const PI63: f64 = f64::from_bits(0x3C19_21FB_5444_2D18);
    fn poly(x: f64, x2: f64, p: &T, n: u32) -> (f32, f32) {
        let x4 = x2 * x2;
        let x3 = x2 * x;
        let c2 = p.c3 + x2 * p.c4;
        let s1 = p.s2 + x2 * p.s3;
        let c1 = p.c0 + x2 * p.c1;
        let x5 = x3 * x2;
        let x6 = x4 * x2;
        let s = x + x3 * p.s1;
        let c = c1 + x4 * p.c2;
        let (a, b) = ((s + x5 * s1) as f32, (c + x6 * c2) as f32);
        if n & 1 == 1 { (b, a) } else { (a, b) } // (the quadrant swaps sin and cos)
    }
    let xi = y.to_bits();
    let top = (xi >> 20) & 0x7ff;
    let x = y as f64;
    if top < 0x3f3 {
        // |y| < pi/4
        if top < 0x397 {
            return (y, 1.0); // |y| < 2^-12
        }
        poly(x, x * x, &TABLE[0], 0)
    } else if top < 0x42f {
        // |y| < 120: reduce_fast (hpi_inv prescaled by 2^24)
        let r = x * TABLE[0].hpi_inv;
        let n = ((r as i32).wrapping_add(0x80_0000)) >> 24;
        let x = x - n as f64 * TABLE[0].hpi;
        let s = TABLE[0].sign[(n & 3) as usize];
        let p = if n & 2 != 0 { &TABLE[1] } else { &TABLE[0] };
        poly(x * s, x * x, p, n as u32)
    } else if top < 0x7f8 {
        // reduce_large
        let sign = xi >> 31;
        let arr = &INV_PIO4[((xi >> 26) & 15) as usize..];
        let shift = (xi >> 23) & 7;
        let xm = ((xi & 0xff_ffff) | 0x80_0000) << shift;
        let res0 = xm.wrapping_mul(arr[0]) as u64;
        let res1 = xm as u64 * arr[4] as u64;
        let res2 = xm as u64 * arr[8] as u64;
        let mut res0 = (res2 >> 32) | (res0 << 32);
        res0 = res0.wrapping_add(res1);
        let n = res0.wrapping_add(1 << 61) >> 62;
        res0 = res0.wrapping_sub(n << 62);
        let x = res0 as i64 as f64 * PI63;
        let q = (n as u32).wrapping_add(sign);
        let s = TABLE[0].sign[(q & 3) as usize];
        let p = if q & 2 != 0 { &TABLE[1] } else { &TABLE[0] };
        poly(x * s, x * x, p, n as u32)
    } else {
        (f32::NAN, f32::NAN) // inf / NaN (y - y)
    }
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

    /// glibc's sincosf on inputs where musl's sinf / cosf differ by an ulp (rows of a 2M-input comparison against the i386 glibc 2.39
    /// libm, 0 differences; Task 12), the large-argument reduction, the tiny path; and the cvc-ik-s1 tick 11100 yaw (ICHIGO-NS-SLOT).
    #[test]
    fn sincosf_is_glibc() {
        for [x, s, c] in [
            [0xc0dfff6d, 0xbf282cd0, 0x3f4102c2],
            [0xc03ef798, 0xbe20d8ee, 0xbf7cd274],
            [0x3f3b1b37, 0x3f2ae320, 0x3f3e9d18],
            [0x40905fb3, 0xbf7adc6c, 0xbe4c2597],
            [0xc02ac142, 0xbee97eda, 0xbf63d42c],
        ] {
            let (gs, gc) = sincosf(f32::from_bits(x));
            assert_eq!((gs.to_bits(), gc.to_bits()), (s, c), "{x:08x}");
        }
        assert_ne!(libm::sinf(f32::from_bits(0xc02ac142)).to_bits(), 0xbee97eda); // (musl's: one ulp off)
        assert_eq!(sincosf(1e-5), (1e-5, 1.0));
        let (s, c) = sincosf(1000.0);
        assert!((s - 0.82687956).abs() < 1e-6 && (c - 0.5623791).abs() < 1e-6);
    }
}
