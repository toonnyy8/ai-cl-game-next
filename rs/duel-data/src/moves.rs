//! moves.json: every MOVE object (duel/lisp/kit.lisp DEFSTRUCT MOVE / HITWIN), id "<char>/<form>/<name>[#n]" or
//! "var/<variable>/<name>#<index>". Code fields (cine, tick, release, on_land, on_frame's function, a window's seg) are the
//! Lisp function's name, ported by hand.
use crate::{lbool, Datum};
use serde::Deserialize;

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
    /// The move's free plist (:params), typed.
    pub params: Params,
    pub enter: i32,
    pub clip_speed: f32,
    pub blend: f32,
    #[serde(deserialize_with = "lbool")]
    pub planted: bool,
}

/// A move's :params plist (kit.lisp DEFMOVE; read with GETF, so every key is per move: absent = NIL). Bool keys are only ever
/// T (absent → false). Keys used only by Hisagi / Yamamoto are typed too (the load must cover all 549 moves). Integer tokens
/// in `chain` stay integers in the data (read as f32).
#[derive(Deserialize, Debug, Clone, Default)]
#[serde(deny_unknown_fields, rename_all = "kebab-case")]
pub struct Params {
    pub aim: Option<f32>,
    #[serde(default, deserialize_with = "lbool")]
    pub armor_act: bool,
    pub as_ptr: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub as4: bool,
    pub aura: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub bankai_as: bool,
    #[serde(default, deserialize_with = "lbool")]
    pub bind_end: bool,
    #[serde(default, deserialize_with = "lbool")]
    pub bind_start: bool,
    pub burst: Option<[i32; 4]>,
    pub chain: Option<[f32; 5]>,
    pub charge_mult: Option<f32>,
    pub dash_max: Option<i32>,
    pub dash_speed: Option<f32>,
    pub dash_track: Option<f32>,
    pub delay: Option<i32>,
    pub dmg: Option<i32>,
    #[serde(rename = "dmg-2")]
    pub dmg_2: Option<i32>,
    pub dmg_at: Option<i32>,
    pub ender_dash: Option<i32>,
    pub far: Option<f32>,
    pub follow_cap: Option<f32>,
    pub follow_speed: Option<f32>,
    pub garb: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub gather: bool,
    pub guard: Option<i32>,
    pub hit_at: Option<i32>,
    pub hit_reach: Option<f32>,
    pub hits: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub hoden: bool,
    pub kb: Option<f32>,
    #[serde(default, deserialize_with = "lbool")]
    pub keep_bind: bool,
    pub kikon_strike: Option<String>,
    pub level: Option<i32>,
    pub life: Option<i32>,
    /// A look keyword or a look function's name.
    pub look: Option<String>,
    pub look_as: Option<String>,
    pub lv: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub lv_up: bool,
    pub mark: Option<i32>,
    pub melee_range: Option<f32>,
    pub near: Option<f32>,
    #[serde(default, deserialize_with = "lbool")]
    pub no_kikon: bool,
    #[serde(default, deserialize_with = "lbool")]
    pub no_tip: bool,
    pub ns_next: Option<String>,
    #[serde(default, deserialize_with = "lbool")]
    pub one_hand: bool,
    pub pull: Option<f32>,
    /// Commands that may cancel the recovery (e.g. `["q", "f"]`).
    pub r_cancel: Option<Vec<String>>,
    pub radius: Option<f32>,
    pub range: Option<f32>,
    pub react: Option<String>,
    pub ring_dmg: Option<i32>,
    pub sa: Option<String>,
    pub sfx: Option<String>,
    pub sp_cost: Option<i32>,
    #[serde(default, deserialize_with = "lbool")]
    pub special_as: bool,
    pub speed: Option<f32>,
    pub steal_fs: Option<i32>,
    pub stun: Option<i32>,
    pub throw: Option<f32>,
    pub track: Option<f32>,
    #[serde(default, deserialize_with = "lbool")]
    pub turn_armor: bool,
    pub width: Option<f32>,
    pub window: Option<[i32; 2]>,
    pub zan: Option<String>,
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
