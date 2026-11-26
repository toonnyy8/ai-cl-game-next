//! bodies.json (duel/lisp/body.lisp DEFSTRUCT BODY, minus the mesh handles), weapons.json (built meshes), rig.json.
use crate::Datum;
use serde::Deserialize;
use std::collections::BTreeMap;

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Body {
    pub scale: f32,
    pub width: f32,
    pub hunch: f32,
    pub hurt_r: f32,
    pub hurt_h: f32,
    /// Ordered `[key, rgb]`; a variant prepends, the first wins.
    pub palette: Vec<(String, i64)>,
    /// `[part, shape...]`, a shape `["box", 0.34, ..., "at", [x, y, z], "c", "black"]` (positional, shape kinds typed in M1).
    pub spec: Vec<Vec<Datum>>,
    /// `[part, sx, sy, sz]`.
    pub girth: Option<Vec<(String, f32, f32, f32)>>,
    /// Alist `[key, value]` (T row: `true`).
    pub ink: Option<Vec<Vec<Datum>>>,
    pub rim: Option<Vec<f32>>,
    pub props: Option<Vec<f32>>,
    /// Shared clip → this body's clip.
    pub clips: BTreeMap<String, String>,
}

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Weapon {
    pub len: f32,
    pub base: f32,
    pub sections: Vec<Section>,
}

/// One mesh section: verts in 9s (position, normal, colour).
#[derive(Deserialize, Debug, Clone)]
#[serde(tag = "kind", rename_all = "lowercase", deny_unknown_fields)]
pub enum Section {
    Solid { ink: i32, ink_color: Option<i64>, verts: Vec<[f32; 9]> },
    Glow { emissive: f32, color: i64, verts: Vec<[f32; 9]> },
}

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Rig {
    pub aliases: BTreeMap<String, Vec<String>>,
    pub joints: Vec<RigJoint>,
    pub key_ease: i32,
    /// Joint index pairs `[right, left]`.
    pub mirror_pairs: Vec<[usize; 2]>,
}

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct RigJoint {
    pub name: String,
    pub parent: Option<String>,
    /// *RIG-OFF*: engine coordinates x = right, y = up, z = -forward.
    pub offset: [f32; 3],
    pub flex_sign: f32,
    pub mirror: f32,
}
