//! clips.json: {name: CLIP} (engine/lisp/anim.lisp DEFSTRUCT CLIP); n = times.len().
use crate::lbool;
use serde::Deserialize;
use std::collections::BTreeMap;

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Clip {
    pub dur: f32,
    #[serde(rename = "loop", deserialize_with = "lbool")]
    pub looping: bool,
    /// Mark name → seconds.
    pub marks: BTreeMap<String, f32>,
    /// One 68-float pose per key.
    pub poses: Vec<Vec<f32>>,
    /// 1.0 = the key is reached with a linear snap.
    pub snaps: Vec<f32>,
    pub times: Vec<f32>,
}
