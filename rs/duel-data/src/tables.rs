//! tables.json (27 load-time tables: stage, fuzzy sets, strategies, the mirror P2's rim / tint ...; typed when a system ports them), glyphs.json,
//! debug_ranges.json.
use serde::Deserialize;
use serde_json::Value;
use std::collections::BTreeMap;

pub type Tables = BTreeMap<String, Value>;

/// `[code point, advance, [contour [x0, y0, x1, y1 ...]]]`.
#[derive(Deserialize, Debug, Clone)]
pub struct Glyph(pub u32, pub i32, pub Vec<Vec<i32>>);

/// `[lo, hi, handler name | null]` (null: an inline lambda).
#[derive(Deserialize, Debug, Clone)]
pub struct DebugRange(pub i64, pub i64, pub Option<String>);
