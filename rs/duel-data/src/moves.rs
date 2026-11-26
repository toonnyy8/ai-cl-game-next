//! moves.json: every MOVE object (duel/lisp/kit.lisp DEFSTRUCT MOVE / HITWIN), id "<char>/<form>/<name>[#n]" or
//! "var/<variable>/<name>#<index>". Code fields (cine, tick, release, on_land, on_frame's function, a window's seg) are the
//! Lisp function's name, ported by hand.
use crate::{lbool, Datum};
use serde::Deserialize;
use serde_json::{Map, Value};

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Move {
    pub id: String,
    pub name: String,
    pub kind: String,
    pub clip: String,
    pub clip2: Option<String>,
    pub callout: Option<String>,
    pub s: i32,
    pub a: i32,
    pub r: i32,
    pub whiff: i32,
    pub dmg: i32,
    pub adv_block: Option<AdvBlock>,
    /// Degrees per second; an integer in a few moves (read as f32).
    pub track: f32,
    pub reach: f32,
    pub hits: Vec<HitWin>,
    pub hold: Option<Vec<i32>>,
    pub slide: f32,
    pub flags: Vec<String>,
    pub armor_hits: i32,
    pub cooldown: i32,
    /// `[frame, FUNCTION-NAME, ...]` entries.
    pub on_frame: Vec<Vec<Datum>>,
    pub tick: Option<String>,
    pub release: Option<String>,
    pub on_land: Option<String>,
    pub cine: Option<String>,
    /// The move's free plist (typed knobs come in M1).
    pub params: Map<String, Value>,
    pub enter: i32,
    pub clip_speed: f32,
    pub blend: f32,
    #[serde(deserialize_with = "lbool")]
    pub planted: bool,
}

/// One active window: [from, to) in move frames.
#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct HitWin {
    pub from: i32,
    pub to: i32,
    pub dmg: i32,
    /// MAKE-VOL vectors: #(type p1 p2 p3 p4 p5), type 0 ARC, 1 CAP (a b h r yaw), 2 SPH, 3 TSPH (engine/lisp/hitvol.lisp).
    pub vols: Vec<[f32; 6]>,
    pub react: String,
    pub kb: f32,
    pub hs: i32,
    pub chip: Option<f32>,
    pub stun: Option<i32>,
    pub guard: Option<i32>,
    pub seg: Option<String>,
    pub min: Option<f32>,
    pub steal: Option<i32>,
    pub flags: Vec<String>,
}

/// A move's block advantage: frames, or a guard break.
#[derive(Deserialize, Debug, Clone, Copy, PartialEq)]
#[serde(untagged)]
pub enum AdvBlock {
    Frames(i32),
    Key(AdvKey),
}

#[derive(Deserialize, Debug, Clone, Copy, PartialEq)]
pub enum AdvKey {
    #[serde(rename = "guard-break")]
    GuardBreak,
}
