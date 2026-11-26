//! kits.json: {"kits": {character: {form: KIT}}, "roster": [...], "retired": [...]} (duel/lisp/kit.lisp DEFSTRUCT KIT).
//! Hooks, cines, aura and the meter's label are the Lisp function's name.
use crate::{lbool, Datum};
use serde::Deserialize;
use std::collections::BTreeMap;

#[derive(Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Kits {
    pub kits: BTreeMap<String, BTreeMap<String, Kit>>,
    pub roster: Vec<String>,
    pub retired: Vec<String>,
}

#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields)]
pub struct Kit {
    pub character: String,
    pub form: String,
    pub inherit: Option<String>,
    pub name: String,
    #[serde(deserialize_with = "lbool")]
    pub awakening: bool,
    pub awaken_form: Option<String>,
    pub duration: Option<f32>,
    pub burn: f32,
    pub mult: f32,
    pub taken: f32,
    pub cornered: f32,
    pub cornered_max: f32,
    pub passives: Vec<String>,
    pub walk: f32,
    pub run: f32,
    pub run_clips: Vec<String>,
    pub reishi: i32,
    pub body: String,
    pub weapon: String,
    pub stance: String,
    pub hide: Vec<String>,
    pub aura: Option<String>,
    pub lift: f32,
    pub intro: String,
    pub win: String,
    pub intro_callout: Option<String>,
    /// `[weapon, frame]`.
    pub intro_weapon: Option<Vec<Datum>>,
    pub callout: Option<String>,
    pub swing_sfx: Option<String>,
    pub absorb_sfx: Option<String>,
    pub enter_clips: Vec<String>,
    pub enter_hook: Option<String>,
    pub exit_hook: Option<String>,
    pub meter: Meter,
    pub cine: Option<String>,
    /// `[look, scale]`.
    pub blade: Option<Vec<Datum>>,
    pub grade: Option<String>,
    pub smear: Option<i32>,
    pub kikon_konpaku: i32,
    pub form_name: String,
    pub respect_callout: Option<String>,
    pub reset_form: Option<String>,
    #[serde(deserialize_with = "lbool")]
    pub calm: bool,
    pub face: Option<String>,
    pub stun_tolerance: Option<f32>,
    pub gg_regen: f32,
    /// A move name (T or a plist would fail the load: none in the data).
    pub l_after_k: Option<String>,
    pub l_after_j: Option<String>,
    #[serde(deserialize_with = "lbool")]
    pub run_awaken: bool,
    /// Hook point → function name.
    pub hooks: BTreeMap<String, String>,
    pub clip_map: BTreeMap<String, String>,
    pub push_reach: Option<f32>,
    pub look_clips: BTreeMap<String, String>,
    /// The core system's plist (:core).
    pub core: Core,
    pub open_s: Option<i32>,
    /// `[base, per, min, max]`.
    pub hs_dmg: Option<Vec<i32>>,
    /// Move id → its triangle class.
    pub cls: BTreeMap<String, MoveClass>,
    /// Move name → the SP an NS / AS segment costs.
    pub sp: BTreeMap<String, f32>,
    /// Command → move name.
    pub commands: BTreeMap<String, Option<String>>,
    /// `[from-move, command, to-move]`.
    pub strings: Vec<[String; 3]>,
    /// This form's move ids (sorted).
    pub moves: Vec<String>,
}

/// A form's :core plist (DUEL_CORE). The six keys every form has are required; the rest are per kit (absent = NIL; Lisp
/// defaults such as :sp-cost-mult 1 stay at the reader).
#[derive(Deserialize, Debug, Clone)]
#[serde(deny_unknown_fields, rename_all = "kebab-case")]
pub struct Core {
    pub ns: Vec<String>,
    #[serde(rename = "as")]
    pub as_segs: Vec<String>,
    pub sa: String,
    pub stances: Vec<String>,
    pub kikon_cines: Vec<String>,
    pub mult: f32,
    pub as_by_press: Option<Vec<i32>>,
    pub as_writes: Option<Vec<Option<i32>>>,
    /// Per NS pointer: `[near, far]` or NIL.
    pub ns_range: Option<Vec<Option<[f32; 2]>>>,
    pub range: Option<[f32; 2]>,
    pub sp_cost_mult: Option<f32>,
    #[serde(default, deserialize_with = "lbool")]
    pub sp_free: bool,
    pub also: Option<Vec<String>>,
}

/// The form's gauge (empty when the form has none).
#[derive(Deserialize, Debug, Clone, Default)]
#[serde(deny_unknown_fields, default)]
pub struct Meter {
    pub name: Option<String>,
    pub label: Option<String>,
    pub max: Option<i32>,
    pub start: Option<i32>,
    pub lv: Option<bool>,
}

#[derive(Deserialize, Debug, Clone, Copy, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum MoveClass {
    Na,
    Ns,
    As,
    Sa,
}
