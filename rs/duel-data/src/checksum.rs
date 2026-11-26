//! The extractor's float checksum (task-5-report.md "Float checksum"): one FNV-1a 64 state over the data files in name order;
//! in each file every float in document order, hashed as ECL's (integer-decode-float x) in 13 bytes.
//! A float = a number token holding '.', 'e' or 'E' (parsed exactly as f32), or an object whose only key is "f64" with a string
//! value (parsed as f64). Integer tokens and string contents are not floats.
use crate::Data;

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Float {
    F32(f32),
    F64(f64),
}

const BASIS: u64 = 0xcbf29ce484222325;
const PRIME: u64 = 0x100000001b3;

/// The float checksum of every data file, as the manifest's "float_checksum".
pub fn floats(d: &Data) -> u64 {
    let mut h = BASIS;
    for (_, text) in d.files() {
        for_each_float_token(text, |_, f| {
            for b in bytes(f) {
                h = (h ^ b as u64).wrapping_mul(PRIME);
            }
        });
    }
    h
}

/// CL's (integer-decode-float x) = (mantissa exponent sign), from the bits: denormals are normalised as ECL does.
pub fn integer_decode(f: Float) -> (u64, i32, i8) {
    let (neg, e, frac, mbits, bias) = match f {
        Float::F32(x) => {
            let b = x.to_bits();
            (b >> 31 == 1, ((b >> 23) & 0xff) as i32, (b & 0x7f_ffff) as u64, 23, 150)
        }
        Float::F64(x) => {
            let b = x.to_bits();
            (b >> 63 == 1, ((b >> 52) & 0x7ff) as i32, b & 0xf_ffff_ffff_ffff, 52, 1075)
        }
    };
    let sign = if neg { -1 } else { 1 };
    if e == 0 && frac == 0 {
        (0, 0, sign)
    } else if e == 0 {
        let k = frac.leading_zeros() as i32 - (63 - mbits); // the shift that sets the hidden bit
        (frac << k, 1 - bias - k, sign)
    } else {
        (frac | 1 << mbits, e - bias, sign)
    }
}

/// The 13 hashed bytes: sign (0 / 1), exponent i32 LE, mantissa u64 LE.
pub fn bytes(f: Float) -> [u8; 13] {
    let (m, e, s) = integer_decode(f);
    let mut out = [0u8; 13];
    out[0] = (s < 0) as u8;
    out[1..5].copy_from_slice(&e.to_le_bytes());
    out[5..].copy_from_slice(&m.to_le_bytes());
    out
}

/// Calls `f(token, value)` for each float of a JSON text in document order (`token` = the number, or the f64 tag's string).
pub fn for_each_float_token<'a>(text: &'a [u8], mut f: impl FnMut(&'a str, Float)) {
    let tok = |a: usize, b: usize| std::str::from_utf8(&text[a..b]).expect("utf-8 number");
    let mut i = 0;
    while i < text.len() {
        match text[i] {
            b'"' => i = string_end(text, i),
            b'{' => {
                if let Some((a, b, end)) = f64_tag(text, i) {
                    let s = tok(a, b);
                    f(s, Float::F64(s.parse().unwrap_or_else(|_| panic!("bad f64 tag {s}"))));
                    i = end;
                } else {
                    i += 1;
                }
            }
            b'-' | b'0'..=b'9' => {
                let a = i;
                while i < text.len() && matches!(text[i], b'-' | b'+' | b'.' | b'e' | b'E' | b'0'..=b'9') {
                    i += 1;
                }
                let s = tok(a, i);
                if s.bytes().any(|c| matches!(c, b'.' | b'e' | b'E')) {
                    f(s, Float::F32(s.parse().unwrap_or_else(|_| panic!("bad float {s}"))));
                }
            }
            _ => i += 1,
        }
    }
}

/// Index just past the string starting at the quote at `i`.
fn string_end(t: &[u8], mut i: usize) -> usize {
    i += 1;
    while i < t.len() {
        match t[i] {
            b'\\' => i += 2,
            b'"' => return i + 1,
            _ => i += 1,
        }
    }
    i
}

/// At a '{': `{"f64":"…"}` as its only key → (value start, value end, index past the '}').
fn f64_tag(t: &[u8], i: usize) -> Option<(usize, usize, usize)> {
    let ws = |mut j: usize| {
        while j < t.len() && t[j].is_ascii_whitespace() {
            j += 1;
        }
        j
    };
    let mut j = ws(i + 1);
    j = t[j..].starts_with(b"\"f64\"").then(|| ws(j + 5))?;
    j = (t.get(j) == Some(&b':')).then(|| ws(j + 1))?;
    if t.get(j) != Some(&b'"') {
        return None;
    }
    let end = string_end(t, j);
    let k = ws(end);
    (t.get(k) == Some(&b'}')).then_some((j + 1, end - 1, k + 1))
}
