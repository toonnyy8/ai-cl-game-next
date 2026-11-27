//! Common Lisp (ECL 24.5) semantics the sim relies on: rounding, integer division, MIN / MAX, the single-float narrowing, and
//! the printer's float forms. Pinned by testdata/cl_vectors.txt (tools/port/cl-vectors.lisp on the frozen native image).
//! A bare float literal in the Lisp (`0.5`, `1e-8`) is a single-float: `*read-default-float-format*` is never changed.

/// port: ECL src/c/numbers/round.d round_double (CL ROUND of a float: floor(d + 0.5), a tie goes to the even neighbour).
fn round_double(d: f64) -> f64 {
    if d >= 0.0 {
        let d = d + 0.5;
        let q = libm::floor(d);
        if q == d && (libm::fmod(q, 10.0) as i32) & 1 != 0 {
            return q - 1.0;
        }
        q
    } else if d.is_nan() {
        d
    } else {
        -round_double(-d)
    }
}

/// port: ECL round.d ecl_round1, t_singlefloat (through round_double, stored back in a float).
pub fn round_f32(x: f32) -> i64 {
    round_double(x as f64) as f32 as i64
}
/// port: ECL round.d ecl_round1, t_doublefloat.
pub fn round_f64(x: f64) -> i64 {
    round_double(x) as i64
}
/// port: ECL floor.d ecl_floor1 (floorf).
pub fn floor_f32(x: f32) -> i64 {
    libm::floorf(x) as i64
}
/// port: ECL floor.d ecl_floor1 (floor).
pub fn floor_f64(x: f64) -> i64 {
    libm::floor(x) as i64
}
/// port: ECL truncate.d ecl_truncate1 (floorf above 0, ceilf below).
pub fn truncate_f32(x: f32) -> i64 {
    libm::truncf(x) as i64
}
/// port: CL FLOOR of two integers (the quotient rounds toward negative infinity).
pub fn floor_div(a: i64, b: i64) -> i64 {
    let q = a / b;
    if a % b != 0 && ((a < 0) != (b < 0)) {
        q - 1
    } else {
        q
    }
}
/// port: CL MOD of two integers (the result takes the divisor's sign).
pub fn modulo(a: i64, b: i64) -> i64 {
    a - b * floor_div(a, b)
}
/// port: CL REM of two integers (the result takes the dividend's sign).
pub fn rem(a: i64, b: i64) -> i64 {
    a % b
}

/// port: cpu-perceive.lisp %EXPT2 — CL's (EXPT X 2) of a single-float as ECL computes it: X x 2 for a zero, else C powf (X, 2.0).
/// The C powf is musl's (the wasm build's, and the native sim's preload): `musl_powf`, which is not X x X on ~0.04 % of inputs
/// (nor the `libm` crate's powf, whose y = 2 path returns X x X). Equal to musl on all 2^32 inputs (tests/cpu.rs).
pub fn expt2(x: f32) -> f32 {
    if x == 0.0 { x * 2.0 } else { musl_powf(x, 2.0) }
}

/// musl's `__exp2f_data.tab` (src/math/exp2f_data.c, EXP2F_TABLE_BITS 5): powf's and expf's 2^(i/32) table, as bits.
const EXP2_TAB: [u64; 32] = [
    0x3ff0000000000000, 0x3fefd9b0d3158574, 0x3fefb5586cf9890f, 0x3fef9301d0125b51, 0x3fef72b83c7d517b, 0x3fef54873168b9aa,
    0x3fef387a6e756238, 0x3fef1e9df51fdee1, 0x3fef06fe0a31b715, 0x3feef1a7373aa9cb, 0x3feedea64c123422, 0x3feece086061892d,
    0x3feebfdad5362a27, 0x3feeb42b569d4f82, 0x3feeab07dd485429, 0x3feea47eb03a5585, 0x3feea09e667f3bcd, 0x3fee9f75e8ec5f74,
    0x3feea11473eb0187, 0x3feea589994cce13, 0x3feeace5422aa0db, 0x3feeb737b0cdc5e5, 0x3feec49182a3f090, 0x3feed503b23e255d,
    0x3feee89f995ad3ad, 0x3feeff76f2fb5e47, 0x3fef199bdd85529c, 0x3fef3720dcef9069, 0x3fef5818dcfba487, 0x3fef7c97337b9b5f,
    0x3fefa4afa2a490da, 0x3fefd0765b6e4540,
];

/// musl's `__exp2f_data.poly` (powf's; expf scales it by powers of 2).
const EXP2_POLY: [u64; 3] = [0x3fac6af84b912394, 0x3fcebfce50fac4f3, 0x3fe62e42ff0c52d6];

/// port: musl src/math/expf.c (ARM's: EXP2F_TABLE_BITS 5, EXP2F_POLY_ORDER 3, TOINT_INTRINSICS 0, double_t double) — C expf, which
/// ECL's EXP of a single-float calls (ecl_exp: expf). The answer key's (the wasm build's, and the native sim's preload, tools/simlib.py
/// MUSL_MATH); the `libm` crate's expf is FreeBSD's, which differs on ~10 % of inputs. Equal to musl on all 2^32 inputs (tests/cpu.rs).
#[allow(clippy::assign_op_pattern)] // (the C's text: y = z * r2 + y)
pub fn expf(x: f32) -> f32 {
    let f = f64::from_bits;
    let top12 = |x: f32| x.to_bits() >> 20;
    let abstop = top12(x) & 0x7ff;
    if abstop >= top12(88.0) {
        if x.to_bits() == f32::NEG_INFINITY.to_bits() {
            return 0.0;
        }
        if abstop >= top12(f32::INFINITY) {
            return x + x;
        }
        if x > f32::from_bits(0x42b17217) {
            let big = f32::from_bits(0x70000000); // (__math_oflowf (0): 0x1p97f squared)
            return big * big;
        }
        if x < f32::from_bits(0xc2cff1b4) {
            let tiny = f32::from_bits(0x10000000); // (__math_uflowf (0): 0x1p-95f squared)
            return tiny * tiny;
        }
    }
    const N: f64 = 32.0;
    let shift = f(0x4338000000000000); // (0x1.8p+52)
    let z = f(0x3ff71547652b82fe) * N * x as f64; // (InvLn2N = 0x1.71547652b82fep+0 * N, exact)
    let mut kd = z + shift;
    let ki = kd.to_bits();
    kd -= shift;
    let r = z - kd;
    let t = EXP2_TAB[(ki % 32) as usize].wrapping_add(ki << (52 - 5));
    let s = f(t);
    let c = [f(EXP2_POLY[0]) / (N * N * N), f(EXP2_POLY[1]) / (N * N), f(EXP2_POLY[2]) / N]; // (poly_scaled: exact)
    let z = c[0] * r + c[1];
    let r2 = r * r;
    let mut y = c[2] * r + 1.0;
    y = z * r2 + y;
    y *= s;
    y as f32
}

/// musl's powf (src/math/powf.c, ARM's: POWF_LOG2_TABLE_BITS 4, EXP2F_TABLE_BITS 5, TOINT_INTRINSICS 0, double_t double), its
/// tables as bits. ponytail: Y finite and non-zero only (powf's zeroinfnan(y) branch is not ported: a panic); `expt2` is the caller.
#[allow(clippy::eq_op, clippy::assign_op_pattern)] // (the C's text: (x - x) / (x - x) is its NaN, q = p * r2 + q its order)
pub fn musl_powf(x: f32, y: f32) -> f32 {
    const LOG2_TAB: [(u64, u64); 16] = [
        (0x3ff661ec79f8f3be, 0xbfdefec65b963019),
        (0x3ff571ed4aaf883d, 0xbfdb0b6832d4fca4),
        (0x3ff49539f0f010b0, 0xbfd7418b0a1fb77b),
        (0x3ff3c995b0b80385, 0xbfd39de91a6dcf7b),
        (0x3ff30d190c8864a5, 0xbfd01d9bf3f2b631),
        (0x3ff25e227b0b8ea0, 0xbfc97c1d1b3b7af0),
        (0x3ff1bb4a4a1a343f, 0xbfc2f9e393af3c9f),
        (0x3ff12358f08ae5ba, 0xbfb960cbbf788d5c),
        (0x3ff0953f419900a7, 0xbfaa6f9db6475fce),
        (0x3ff0000000000000, 0x0000000000000000),
        (0x3fee608cfd9a47ac, 0x3fb338ca9f24f53d),
        (0x3feca4b31f026aa0, 0x3fc476a9543891ba),
        (0x3feb2036576afce6, 0x3fce840b4ac4e4d2),
        (0x3fe9c2d163a1aa2d, 0x3fd40645f0c6651c),
        (0x3fe886e6037841ed, 0x3fd88e9c2c1b9ff8),
        (0x3fe767dcf5534862, 0x3fdce0a44eb17bcc),
    ];
    const LOG2_POLY: [u64; 5] = [0x3fd27616c9496e0b, 0xbfd71969a075c67a, 0x3fdec70a6ca7badd, 0xbfe7154748bef6c8, 0x3ff71547652ab82b];
    const SHIFT_SCALED: u64 = 0x42e8000000000000; // (0x1.8p+52 / 32)
    const SIGN_BIAS: u64 = 1 << (5 + 11);
    let f = f64::from_bits;
    let checkint = |iy: u32| -> u32 {
        let e = iy >> 23 & 0xff;
        if e < 0x7f {
            0
        } else if e > 0x7f + 23 {
            2
        } else if iy & ((1 << (0x7f + 23 - e)) - 1) != 0 {
            0
        } else if iy & (1 << (0x7f + 23 - e)) != 0 {
            1
        } else {
            2
        }
    };
    let zeroinfnan = |i: u32| 2u32.wrapping_mul(i).wrapping_sub(1) >= 2u32.wrapping_mul(0x7f800000).wrapping_sub(1);
    let mut sign_bias: u64 = 0;
    let mut ix = x.to_bits();
    let iy = y.to_bits();
    assert!(!zeroinfnan(iy), "musl_powf: y {y} is zero, infinite or NaN (not ported)");
    if ix.wrapping_sub(0x00800000) >= 0x7f800000 - 0x00800000 {
        if zeroinfnan(ix) {
            let mut x2 = x * x;
            if ix & 0x80000000 != 0 && checkint(iy) == 1 {
                x2 = -x2;
            }
            return if iy & 0x80000000 != 0 { 1.0 / x2 } else { x2 };
        }
        if ix & 0x80000000 != 0 {
            match checkint(iy) {
                0 => return (x - x) / (x - x), // (__math_invalidf: a NaN)
                1 => sign_bias = SIGN_BIAS,
                _ => {}
            }
            ix &= 0x7fffffff;
        }
        if ix < 0x00800000 {
            ix = (x * f32::from_bits(0x4b000000)).to_bits() & 0x7fffffff; // (x * 0x1p23f: a subnormal normalized)
            ix = ix.wrapping_sub(23 << 23);
        }
    }
    // log2_inline
    let tmp = ix.wrapping_sub(0x3f330000);
    let i = ((tmp >> (23 - 4)) % 16) as usize;
    let top = tmp & 0xff800000;
    let iz = ix.wrapping_sub(top);
    let k = (top as i32) >> 23;
    let (invc, logc) = (f(LOG2_TAB[i].0), f(LOG2_TAB[i].1));
    let z = f32::from_bits(iz) as f64;
    let r = z * invc - 1.0;
    let y0 = logc + k as f64;
    let a = LOG2_POLY.map(f);
    let r2 = r * r;
    let mut lg = a[0] * r + a[1];
    let p = a[2] * r + a[3];
    let r4 = r2 * r2;
    let mut q = a[4] * r + y0;
    q = p * r2 + q;
    lg = lg * r4 + q;
    let ylogx = y as f64 * lg;
    if (ylogx.to_bits() >> 47 & 0xffff) >= 126.0f64.to_bits() >> 47 {
        if ylogx > f(0x405fffffffd1d571) {
            let big = f32::from_bits(0x70000000); // (__math_oflowf: 0x1p97f squared, signed)
            return if sign_bias != 0 { -big * big } else { big * big };
        }
        if ylogx <= -150.0 {
            let tiny = f32::from_bits(0x10000000); // (__math_uflowf: 0x1p-95f squared, signed)
            return if sign_bias != 0 { -tiny * tiny } else { tiny * tiny };
        }
    }
    // exp2_inline
    let shift = f(SHIFT_SCALED);
    let mut kd = ylogx + shift;
    let ki = kd.to_bits();
    kd -= shift;
    let r = ylogx - kd;
    let ski = ki.wrapping_add(sign_bias);
    let s = f(EXP2_TAB[(ki % 32) as usize].wrapping_add(ski << (52 - 5)));
    let c = EXP2_POLY.map(f);
    let z = c[0] * r + c[1];
    let r2 = r * r;
    let mut e = c[2] * r + 1.0;
    e = z * r2 + e;
    e *= s;
    e as f32
}

/// port: engine/lisp/package.lisp F32 (a double narrowed to single, round to nearest).
pub fn f32(x: f64) -> f32 {
    x as f32
}
/// A single-float's IEEE bits (the B line's form).
pub fn f32_bits(x: f32) -> u32 {
    x.to_bits()
}
/// port: ECL src/c/numbers/minmax.d MIN of two singles: the first unless the second is strictly lower (or the first is a NaN).
pub fn min_f32(a: f32, b: f32) -> f32 {
    if a > b || a.is_nan() { b } else { a }
}
/// port: ECL minmax.d MAX of two singles: the first unless the second is strictly higher (or the first is a NaN).
pub fn max_f32(a: f32, b: f32) -> f32 {
    if a < b || a.is_nan() { b } else { a }
}

/// A Lisp number that is an integer or a single-float: GAUGES-REISHI, a fixnum slot a trial's `(setf (gauges-reishi g) (f32 x))`
/// fills with a float (the readers are untyped, so the arithmetic on it is CL's generic one). Contagion: integer ± float is the
/// float of the integer ± the float (exact at these magnitudes); MIN / MAX return the winning operand as it is, the first on a tie
/// (`(max 0 0.0)` = 0, `(min 1300 1300.0)` = 1300; ECL's minmax.d, checked compiled on the native image); comparisons are exact.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Num {
    I(i64),
    F(f32),
}

impl Num {
    fn exact(self) -> f64 {
        match self {
            Num::I(n) => n as f64,
            Num::F(x) => x as f64,
        }
    }
    /// The value as a single-float (`(float x)` / a single-float context: RED-P's compare, exact at these magnitudes).
    pub fn f(self) -> f32 {
        match self {
            Num::I(n) => n as f32,
            Num::F(x) => x,
        }
    }
    /// The integer, or None for a float.
    pub fn int(self) -> Option<i64> {
        if let Num::I(n) = self { Some(n) } else { None }
    }
    /// `(min self o)`.
    pub fn min(self, o: Num) -> Num {
        if o.exact() < self.exact() { o } else { self }
    }
    /// `(max self o)`.
    pub fn max(self, o: Num) -> Num {
        if o.exact() > self.exact() { o } else { self }
    }
    pub fn le(self, n: i64) -> bool {
        self.exact() <= n as f64
    }
    /// `(< self o)` (CL compares an integer and a float exactly).
    pub fn lt(self, o: Num) -> bool {
        self.exact() < o.exact()
    }
}

/// `(- x y)`: two integers stay one; else the singles' difference (an integer is converted to single first).
impl std::ops::Sub<Num> for Num {
    type Output = Num;
    fn sub(self, o: Num) -> Num {
        match (self, o) {
            (Num::I(a), Num::I(b)) => Num::I(a - b),
            _ => Num::F(self.f() - o.f()),
        }
    }
}

/// `(+ x y)`: two integers stay one; else the singles' sum.
impl std::ops::Add<Num> for Num {
    type Output = Num;
    fn add(self, o: Num) -> Num {
        match (self, o) {
            (Num::I(a), Num::I(b)) => Num::I(a + b),
            _ => Num::F(self.f() + o.f()),
        }
    }
}

/// `(* x n)`: a float times an integer is the float times the integer's single.
impl std::ops::Mul<i64> for Num {
    type Output = Num;
    fn mul(self, n: i64) -> Num {
        match self {
            Num::I(a) => Num::I(a * n),
            Num::F(x) => Num::F(x * n as f32),
        }
    }
}

/// `(+ x n)`.
impl std::ops::Add<i64> for Num {
    type Output = Num;
    fn add(self, n: i64) -> Num {
        match self {
            Num::I(a) => Num::I(a + n),
            Num::F(x) => Num::F(x + n as f32),
        }
    }
}
/// `(- x n)`.
impl std::ops::Sub<i64> for Num {
    type Output = Num;
    fn sub(self, n: i64) -> Num {
        match self {
            Num::I(a) => Num::I(a - n),
            Num::F(x) => Num::F(x - n as f32),
        }
    }
}
impl From<i64> for Num {
    fn from(n: i64) -> Num {
        Num::I(n)
    }
}
/// The integer N (a float is never equal: EQL, as the B line tells them apart).
impl PartialEq<i64> for Num {
    fn eq(&self, n: &i64) -> bool {
        *self == Num::I(*n)
    }
}

/// `~d` / `~a` / PRIN1 of the number: an integer in decimal, a float as `fmt_f32` (`300.0`).
impl std::fmt::Display for Num {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            Num::I(n) => write!(f, "{n}"),
            Num::F(x) => f.write_str(&fmt_f32(*x)),
        }
    }
}

/// port: ECL src/c/printer/float_to_digits.d (Burger-Dybvig) for a positive single: the fewest digits inside its rounding interval,
/// the nearest of them, an exact tie rounding up (21040.3125 → `21040.313`; Rust goes to even). Free format (PRIN1, `cut` 0)
/// never takes a boundary (low_ok = high_ok = 0: 5088799744 prints `5.0887997e9`, Rust's shortest says `5.0888e9`); a FORMAT
/// position (change_precision) widens both half-gaps to at least `cut` and takes the boundaries (low_ok = high_ok = 1).
/// Returns (digits, e): d1.d2d3… × 10^e.
/// ponytail: the nearest p-digit candidate is tried, not the other one on an asymmetric interval (a power of two); exact enough.
fn shortest_f32(a: f32, cut: f64) -> (String, i32) {
    // the interval's ends, exact in f64 when unwidened; a parsed candidate compares exactly (rounding never jumps an f64 end)
    let up = if a == f32::MAX {
        2.0 * a as f64 - a.next_down() as f64
    } else {
        a.next_up() as f64
    }; // past MAX: the same gap
    let (x, inclusive) = (a as f64, cut > 0.0);
    let (lo, hi) = (
        x - (x - (x + a.next_down() as f64) / 2.0).max(cut),
        x + ((x + up) / 2.0 - x).max(cut),
    );
    // the exact expansion (an f32 has at most 105 significant digits) finds the ties
    let exact = format!("{:.160e}", a as f64);
    let exact = exact[..exact.find('e').unwrap()].replace('.', "");
    let s = (0..9)
        .map(|p| {
            let t = &exact[p + 1..];
            let tie = t.starts_with('5') && t[1..].bytes().all(|c| c == b'0');
            format!("{:.p$e}", if tie { (a as f64).next_up() } else { a as f64 })
        })
        .find(|s| {
            s.parse::<f64>().is_ok_and(|v| {
                if inclusive {
                    lo <= v && v <= hi
                } else {
                    lo < v && v < hi
                }
            })
        })
        .unwrap();
    let (m, e) = s.split_once('e').unwrap();
    (m.replace('.', ""), e.parse().unwrap())
}

/// Digits × 10^e in fixed notation: (integer part, fraction part without trailing padding).
fn fixed_parts(digits: &str, e: i32) -> (String, String) {
    let k = e + 1; // digits before the point
    if k <= 0 {
        ("0".into(), "0".repeat(-k as usize) + digits)
    } else if k as usize >= digits.len() {
        (
            digits.to_string() + &"0".repeat(k as usize - digits.len()),
            String::new(),
        )
    } else {
        (digits[..k as usize].into(), digits[k as usize..].into())
    }
}

/// ECL PRIN1 of a single-float (`*read-default-float-format*` single): fixed notation in [1e-3, 1e7), else `d.ddde±n`, always
/// a `.` in the mantissa (`1.0`, `-0.0`, `1.0e10`).
pub fn fmt_f32(x: f32) -> String {
    let sign = if x.is_sign_negative() { "-" } else { "" };
    if x == 0.0 {
        return format!("{sign}0.0");
    }
    let a = x.abs();
    let (digits, e) = shortest_f32(a, 0.0);
    if (1e-3..1e7).contains(&a) {
        let (i, f) = fixed_parts(&digits, e);
        format!("{sign}{i}.{}", if f.is_empty() { "0" } else { &f })
    } else {
        let (d0, rest) = digits.split_at(1);
        format!(
            "{sign}{d0}.{}e{e}",
            if rest.is_empty() { "0" } else { rest }
        )
    }
}

/// ECL FORMAT `~,Df` of a double: the exact binary value rounded to D places, an exact tie away from zero (0.25 → "0.3",
/// 2.5 with D = 0 → "3."); D = 0 keeps the point.
/// ponytail: a double whose own precision is coarser than D places (|x| ≳ 4.5e14 at D = 1) would print its shortest digits,
/// as fmt_fixed_f32 does; the sim never formats one.
pub fn fmt_fixed(x: f64, digits: u32) -> String {
    let y = x * libm::exp2((digits + 1) as f64);
    let tie = y.fract() == 0.0 && y.abs() < 9.0e15 && (y as i64) % 2 != 0;
    let x = if tie {
        x.abs().next_up().copysign(x)
    } else {
        x
    };
    let s = format!("{x:.*}", digits as usize);
    if digits == 0 { s + "." } else { s }
}

/// ECL FORMAT `~,Df` of a single: float_to_digits with the position D. When the single's own precision is finer than D places
/// that is fmt_fixed of its exact value; else its digits within its (inclusive) interval, padded (-409650.1f0 with D = 2 →
/// "-409650.10", not "-409650.09"; -58277608 with D = 0 → "-58277610.").
pub fn fmt_fixed_f32(x: f32, digits: u32) -> String {
    let a = x.abs();
    let cut = 0.5 * libm::pow(10.0, -(digits as f64));
    if a == 0.0 || (a.next_up() as f64 - a as f64) / 2.0 < cut {
        return fmt_fixed(x as f64, digits);
    }
    let (d, e) = shortest_f32(a, cut);
    let (i, f) = fixed_parts(&d, e);
    let sign = if x.is_sign_negative() { "-" } else { "" };
    format!(
        "{sign}{i}.{f}{}",
        "0".repeat((digits as usize).saturating_sub(f.len()))
    )
}

#[cfg(test)]
pub(crate) mod vectors {
    //! testdata/cl_vectors.txt (tools/port/cl-vectors.lisp, run on the frozen native image): `NAME ARG... = RESULT...`.
    pub enum Tok {
        S(f32),
        D(f64),
        I(i64),
        B(bool),
        Str(String),
    }
    impl Tok {
        pub fn s(&self) -> f32 {
            match self {
                Tok::S(x) => *x,
                _ => panic!("not a single"),
            }
        }
        pub fn d(&self) -> f64 {
            match self {
                Tok::D(x) => *x,
                _ => panic!("not a double"),
            }
        }
        pub fn i(&self) -> i64 {
            match self {
                Tok::I(x) => *x,
                _ => panic!("not an integer"),
            }
        }
        pub fn b(&self) -> bool {
            match self {
                Tok::B(x) => *x,
                _ => panic!("not a boolean"),
            }
        }
        pub fn str(&self) -> &str {
            match self {
                Tok::Str(x) => x,
                _ => panic!("not a string"),
            }
        }
        /// A number as Lisp's `(float x 1f0)`.
        pub fn as_f32(&self) -> f32 {
            match self {
                Tok::S(x) => *x,
                Tok::D(x) => *x as f32,
                Tok::I(x) => *x as f32,
                _ => panic!("not a number"),
            }
        }
    }
    pub struct Row {
        pub name: &'static str,
        pub args: Vec<Tok>,
        pub out: Vec<Tok>,
    }
    pub const TEXT: &str = include_str!("../testdata/cl_vectors.txt");
    fn tok(t: &str) -> Tok {
        match t.split_once(':') {
            Some(("s", h)) => Tok::S(f32::from_bits(u32::from_str_radix(h, 16).unwrap())),
            Some(("d", h)) => Tok::D(f64::from_bits(u64::from_str_radix(h, 16).unwrap())),
            Some(("i", n)) => Tok::I(n.parse().unwrap()),
            Some(("b", v)) => Tok::B(v == "T"),
            _ => Tok::Str(t.to_string()),
        }
    }
    pub fn all() -> Vec<Row> {
        TEXT.lines()
            .map(|l| {
                let (a, o) = l.split_once(" =").unwrap_or_else(|| panic!("bad row {l}"));
                let mut a = a.split(' ');
                let name = a.next().unwrap();
                Row {
                    name,
                    args: a.map(tok).collect(),
                    out: o.split(' ').filter(|t| !t.is_empty()).map(tok).collect(),
                }
            })
            .collect()
    }
    pub fn rows(name: &str) -> Vec<Row> {
        let r: Vec<Row> = all().into_iter().filter(|r| r.name == name).collect();
        assert!(!r.is_empty(), "no {name} rows");
        r
    }
}

#[cfg(test)]
mod tests {
    use super::vectors::{all, rows};
    use super::*;

    /// Reishi as a float, the native image's answers (host ECL on build/simgate/duel.fas: DEAL-DAMAGE, HEAL!, BURN on P2's
    /// GAUGES-REISHI set to a float; STATE-HASH-LINE's `r300.0`).
    #[test]
    fn num_contagion_as_ecl() {
        use crate::rules::burn;
        let (z, f) = (Num::I(0), Num::F);
        assert_eq!(z.max(f(40.0) - 10), f(30.0)); // DEAL-DAMAGE 10: 30.0
        assert_eq!(z.max(f(40.0) - 40), Num::I(0)); // 40: the integer 0 (the first on a tie)
        assert_eq!(Num::I(1300).min(f(300.0) + 5), f(305.0)); // HEAL! 5: 305.0
        assert_eq!(Num::I(1300).min(f(1299.0) + 1), Num::I(1300)); // to the cap: 1300
        assert_eq!(Num::I(1300).min(f(1299.5) + 1), Num::I(1300));
        assert_eq!((burn(f(300.0), 10), burn(f(5.0), 10), burn(f(1.0), 3)), (f(290.0), Num::I(1), f(1.0)));
        assert_eq!((f(300.0).to_string(), Num::I(1300).to_string()), ("300.0".to_string(), "1300".to_string()));
    }

    #[test]
    fn round_half_even() {
        for (x, n) in [
            (0.5f32, 0),
            (1.5, 2),
            (2.5, 2),
            (-0.5, 0),
            (-1.5, -2),
            (3.4999998, 3),
        ] {
            assert_eq!(round_f32(x), n, "{x}");
        }
    }

    #[test]
    fn floor_and_mod_negative() {
        assert_eq!(floor_div(-7, 2), -4);
        assert_eq!(modulo(-7, 2), 1);
        assert_eq!(rem(-7, 2), -1);
    }

    #[test]
    fn contagion_mul_half() {
        let x = 0.1f32;
        assert_eq!(
            f32_bits(f32(x as f64 * 0.5)),
            f32_bits((0.1f32 as f64 * 0.5f64) as f32)
        );
        assert_eq!(f32_bits(f32(x as f64 * 0.5)), 0x3D4CCCCD);
        // a bare 0.5 in this code base is a single-float (the image's literal-single row): the f32 product, same bits here
        assert_eq!(f32_bits(0.5f32 * x), 0x3D4CCCCD);
    }

    #[test]
    fn fmt_f32_matches_trace() {
        for s in ["0.3", "-1.0", "-0.0", "0.70710677"] {
            assert_eq!(fmt_f32(s.parse().unwrap()), s);
        }
    }

    #[test]
    fn min_max_keep_the_first_on_ties() {
        assert_eq!(f32_bits(min_f32(0.0, -0.0)), 0);
        assert_eq!(f32_bits(max_f32(-0.0, 0.0)), 0x8000_0000);
        assert_eq!(max_f32(f32::NAN, 1.0), 1.0);
    }

    #[test]
    fn vectors_known_and_counted() {
        let known = [
            "rng-seed",
            "rng-set-state",
            "round-f32",
            "floor-f32",
            "truncate-f32",
            "round-f64",
            "floor-f64",
            "floor-div",
            "mod",
            "rem",
            "fmt-f32",
            "fmt-fixed-s",
            "fmt-fixed-d",
            "deg",
            "angle-wrap",
            "fwd-x",
            "fwd-z",
            "dir-yaw",
            "yaw-to",
            "turn-toward",
            "lerp",
            "clamp",
            "vol-hit-p",
            "capsule-cyl-hit-p",
            "obox-cyl-hit-p",
            "cyl-cyl-hit-p",
            "literal-single",
            "musl-loaded",
        ];
        let all = all();
        for r in &all {
            assert!(known.contains(&r.name), "unknown row {}", r.name);
        }
        assert_eq!(all.len(), 6916);
        assert!(rows("literal-single")[0].out.iter().all(|t| t.b()));
        assert!(rows("musl-loaded")[0].out[0].b());
    }

    #[test]
    fn vectors_cl() {
        for r in rows("round-f32") {
            assert_eq!(round_f32(r.args[0].s()), r.out[0].i());
        }
        for r in rows("floor-f32") {
            assert_eq!(floor_f32(r.args[0].s()), r.out[0].i());
        }
        for r in rows("truncate-f32") {
            assert_eq!(truncate_f32(r.args[0].s()), r.out[0].i());
        }
        for r in rows("round-f64") {
            assert_eq!(round_f64(r.args[0].d()), r.out[0].i());
        }
        for r in rows("floor-f64") {
            assert_eq!(floor_f64(r.args[0].d()), r.out[0].i());
        }
        for r in rows("floor-div") {
            assert_eq!(floor_div(r.args[0].i(), r.args[1].i()), r.out[0].i());
        }
        for r in rows("mod") {
            assert_eq!(modulo(r.args[0].i(), r.args[1].i()), r.out[0].i());
        }
        for r in rows("rem") {
            assert_eq!(rem(r.args[0].i(), r.args[1].i()), r.out[0].i());
        }
    }

    #[test]
    fn vectors_fmt() {
        for r in rows("fmt-f32") {
            assert_eq!(
                fmt_f32(r.args[0].s()),
                r.out[0].str(),
                "{:08x}",
                r.args[0].s().to_bits()
            );
        }
        for r in rows("fmt-fixed-s") {
            let (x, d) = (r.args[0].s(), r.args[1].i() as u32);
            assert_eq!(fmt_fixed_f32(x, d), r.out[0].str(), "{x} {d}");
        }
        for r in rows("fmt-fixed-d") {
            let (x, d) = (r.args[0].d(), r.args[1].i() as u32);
            assert_eq!(fmt_fixed(x, d), r.out[0].str(), "{x} {d}");
        }
    }
}
