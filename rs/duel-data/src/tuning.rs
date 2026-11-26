//! tuning.json: every DEFPARAMETER, keyed by symbol name, lossless positional values (or {"kind":"skipped","why":…}).
//! Scalars are read through `knob` (typed by the JSON token); lists and plists stay `Value` until a system ports them.
pub use serde_json::Value;
use std::collections::BTreeMap;

pub type Tuning = BTreeMap<String, Value>;

/// A scalar knob type, chosen by the JSON token: a float token is f32, `{"f64":"…"}` f64, an integer token i64, `true` /
/// `null` (T / NIL) bool. No coercion: an integer where a float is expected is an error (Lisp's `/` would make a ratio).
pub trait Knob: Sized {
    const KIND: &'static str;
    fn from_value(v: &Value) -> Option<Self>;
}

impl Knob for f32 {
    const KIND: &'static str = "a float token (f32)";
    fn from_value(v: &Value) -> Option<f32> {
        // serde's f64 then `as f32`, as Datum (tests: serde_float_path_is_exact).
        v.as_number().filter(|n| n.is_f64()).and_then(|n| n.as_f64()).map(|x| x as f32)
    }
}

impl Knob for f64 {
    const KIND: &'static str = "{\"f64\":…}";
    fn from_value(v: &Value) -> Option<f64> {
        let o = v.as_object().filter(|o| o.len() == 1)?;
        o.get("f64")?.as_str()?.parse().ok()
    }
}

impl Knob for i64 {
    const KIND: &'static str = "an integer token (i64)";
    fn from_value(v: &Value) -> Option<i64> {
        v.as_i64()
    }
}

impl Knob for bool {
    const KIND: &'static str = "true / null (T / NIL)";
    fn from_value(v: &Value) -> Option<bool> {
        match v {
            Value::Bool(true) => Some(true),
            Value::Null => Some(false),
            _ => None,
        }
    }
}

/// The knob `key` (a symbol name, e.g. `*INPUT-BUFFER*`) as T, or an error naming the key.
pub fn knob<T: Knob>(t: &Tuning, key: &str) -> Result<T, String> {
    let v = t.get(key).ok_or_else(|| format!("tuning: {key} missing"))?;
    T::from_value(v).ok_or_else(|| format!("tuning: {key} is {v}, expected {}", T::KIND))
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn knob_types_by_token() {
        let t: Tuning = [
            ("*F*", json!(0.5)),
            ("*I*", json!(12)),
            ("*D*", json!({"f64": "0.1"})),
            ("*T*", json!(true)),
            ("*N*", json!(null)),
        ]
        .into_iter()
        .map(|(k, v)| (k.to_string(), v))
        .collect();
        assert_eq!(knob::<f32>(&t, "*F*"), Ok(0.5));
        assert_eq!(knob::<i64>(&t, "*I*"), Ok(12));
        assert_eq!(knob::<f64>(&t, "*D*"), Ok(0.1));
        assert_eq!(knob::<bool>(&t, "*T*"), Ok(true));
        assert_eq!(knob::<bool>(&t, "*N*"), Ok(false));
        assert!(knob::<f32>(&t, "*I*").unwrap_err().contains("*I*")); // no int → float coercion
        assert!(knob::<i64>(&t, "*F*").is_err());
        assert!(knob::<f32>(&t, "*D*").is_err());
        assert!(knob::<i64>(&t, "*N*").is_err());
        assert!(knob::<i64>(&t, "*X*").unwrap_err().contains("*X*"));
    }
}
