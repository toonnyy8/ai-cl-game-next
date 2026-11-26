//! tuning.json: every DEFPARAMETER, keyed by symbol name, lossless positional values (or {"kind":"skipped","why":…}).
//! ponytail: untyped until M1 types the knobs a system reads.
use serde_json::Value;
use std::collections::BTreeMap;

pub type Tuning = BTreeMap<String, Value>;
