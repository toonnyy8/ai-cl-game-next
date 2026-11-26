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
