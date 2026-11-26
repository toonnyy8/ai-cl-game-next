//! Plain data tables (kits, moves, clips, bodies, tuning ...) loaded bit-exact from the extractor's JSON (rs/duel-data/data,
//! tools/port/extract). Every typed struct denies unknown fields, so a schema drift fails the load. No Bevy, ever.
use serde::de::{self, Deserializer, MapAccess, SeqAccess, Visitor};
use serde::Deserialize;
use std::borrow::Cow;
use std::collections::BTreeMap;
use std::path::Path;

pub mod body;
pub mod checksum;
pub mod clips;
pub mod kits;
pub mod moves;
pub mod tables;
pub mod tuning;

pub use body::{Body, Rig, RigJoint, Section, Weapon};
pub use clips::Clip;
pub use kits::{Core, Kit, Kits, Meter, MoveClass};
pub use moves::{AdvBlock, HitWin, Move, Params};
pub use tables::{DebugRange, Glyph};

/// The data files, in the checksum's order (by name). manifest.json is read apart; hud-font/ is raw bytes for the HUD.
pub const FILES: [&str; 11] = [
    "bodies.json",
    "clips.json",
    "debug_ranges.json",
    "glyphs.json",
    "kits.json",
    "moves.json",
    "poses.json",
    "rig.json",
    "tables.json",
    "tuning.json",
    "weapons.json",
];

macro_rules! embed {
    ($($f:literal),*) => { [$(($f, include_bytes!(concat!(env!("CARGO_MANIFEST_DIR"), "/data/", $f)) as &'static [u8])),*] };
}
static EMBEDDED: [(&str, &[u8]); 12] = embed!(
    "bodies.json", "clips.json", "debug_ranges.json", "glyphs.json", "kits.json", "moves.json", "poses.json", "rig.json",
    "tables.json", "tuning.json", "weapons.json", "manifest.json"
);

#[derive(Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Manifest {
    pub counts: BTreeMap<String, usize>,
    pub float_checksum: String,
    pub skipped_tuning: usize,
}

#[derive(Debug)]
pub struct Data {
    pub moves: Vec<Move>,
    pub kits: Kits,
    pub clips: BTreeMap<String, Clip>,
    /// Named poses, 68 floats each (+POSE-N+).
    pub poses: BTreeMap<String, Vec<f32>>,
    pub rig: Rig,
    pub bodies: BTreeMap<String, Body>,
    pub weapons: BTreeMap<String, Weapon>,
    pub glyphs: Vec<Glyph>,
    pub debug_ranges: Vec<DebugRange>,
    pub tables: tables::Tables,
    pub tuning: tuning::Tuning,
    pub manifest: Manifest,
    /// The files' text in FILES order (the checksum's input; static when embedded).
    raw: Vec<Cow<'static, [u8]>>,
}

impl Data {
    /// tables.json `mirror_rim`: body.lisp `*mirror-rim*`, a mirror match P2's model rim (RIM-VEC, 3 linear-rgb floats; read as
    /// serde reads an f32: f64, then `as f32`, the float checksum's bits).
    pub fn mirror_rim(&self) -> [f32; 3] {
        let v = self.tables.get("mirror_rim").and_then(|v| v.as_array()).expect("tables.json mirror_rim");
        let f = |i: usize| v.get(i).and_then(|x| x.as_f64()).expect("mirror_rim: 3 floats") as f32;
        assert_eq!(v.len(), 3, "mirror_rim: 3 floats");
        [f(0), f(1), f(2)]
    }

    /// From the files on disk (development; hot reload later).
    pub fn load(dir: &Path) -> Result<Data, String> {
        Self::parse(|f| std::fs::read(dir.join(f)).map(Cow::Owned).map_err(|e| format!("{f}: {e}")))
    }

    /// From the files compiled into the binary (release / wasm).
    pub fn embedded() -> Data {
        Self::parse(|f| Ok(Cow::Borrowed(EMBEDDED.iter().find(|e| e.0 == f).unwrap().1))).expect("embedded data")
    }

    fn parse(read: impl Fn(&str) -> Result<Cow<'static, [u8]>, String>) -> Result<Data, String> {
        let raw = FILES.iter().map(|f| read(f)).collect::<Result<Vec<_>, _>>()?;
        let at = |f: &str| &*raw[FILES.iter().position(|x| *x == f).unwrap()];
        fn de<'a, T: Deserialize<'a>>(f: &str, b: &'a [u8]) -> Result<T, String> {
            serde_json::from_slice(b).map_err(|e| format!("{f}: {e}"))
        }
        let manifest = de("manifest.json", &read("manifest.json")?)?;
        Ok(Data {
            moves: de("moves.json", at("moves.json"))?,
            kits: de("kits.json", at("kits.json"))?,
            clips: de("clips.json", at("clips.json"))?,
            poses: de("poses.json", at("poses.json"))?,
            rig: de("rig.json", at("rig.json"))?,
            bodies: de("bodies.json", at("bodies.json"))?,
            weapons: de("weapons.json", at("weapons.json"))?,
            glyphs: de("glyphs.json", at("glyphs.json"))?,
            debug_ranges: de("debug_ranges.json", at("debug_ranges.json"))?,
            tables: de("tables.json", at("tables.json"))?,
            tuning: de("tuning.json", at("tuning.json"))?,
            manifest,
            raw,
        })
    }

    /// (file name, text) in FILES order.
    pub fn files(&self) -> impl Iterator<Item = (&'static str, &[u8])> {
        FILES.iter().copied().zip(self.raw.iter().map(|b| &**b))
    }

    pub fn file(&self, name: &str) -> &[u8] {
        self.files().find(|f| f.0 == name).map(|f| f.1).unwrap_or_else(|| panic!("no data file {name}"))
    }

    /// Entries per file, as the manifest counts them: kits.json = forms, rig.json = joints, else top-level entries.
    pub fn counts(&self) -> BTreeMap<String, usize> {
        let n = [
            self.bodies.len(),
            self.clips.len(),
            self.debug_ranges.len(),
            self.glyphs.len(),
            self.kits.kits.values().map(|c| c.len()).sum(),
            self.moves.len(),
            self.poses.len(),
            self.rig.joints.len(),
            self.tables.len(),
            self.tuning.len(),
            self.weapons.len(),
        ];
        FILES.iter().map(|f| f.to_string()).zip(n).collect()
    }
}

/// A free Lisp value in a positional list (body shapes, on-frame entries, a kit's blade): T → `true`, NIL → `null`, a
/// keyword → its name. A float token is a single-float, `{"f64":"…"}` a double (the same slot can hold either).
#[derive(Clone, Debug, PartialEq)]
pub enum Datum {
    Null,
    Bool(bool),
    Int(i64),
    F32(f32),
    F64(f64),
    Str(String),
    List(Vec<Datum>),
}

impl Datum {
    /// A number as f32 (a double rounds to nearest, as COERCE to single-float).
    pub fn as_f32(&self) -> Option<f32> {
        match *self {
            Datum::Int(i) => Some(i as f32),
            Datum::F32(x) => Some(x),
            Datum::F64(x) => Some(x as f32),
            _ => None,
        }
    }
    pub fn as_str(&self) -> Option<&str> {
        if let Datum::Str(s) = self { Some(s) } else { None }
    }
}

impl<'de> Deserialize<'de> for Datum {
    fn deserialize<D: Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
        struct V;
        impl<'de> Visitor<'de> for V {
            type Value = Datum;
            fn expecting(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                f.write_str("a Lisp datum")
            }
            fn visit_unit<E>(self) -> Result<Datum, E> {
                Ok(Datum::Null)
            }
            fn visit_bool<E>(self, b: bool) -> Result<Datum, E> {
                Ok(Datum::Bool(b))
            }
            fn visit_i64<E>(self, i: i64) -> Result<Datum, E> {
                Ok(Datum::Int(i))
            }
            fn visit_u64<E: de::Error>(self, u: u64) -> Result<Datum, E> {
                i64::try_from(u).map(Datum::Int).map_err(E::custom)
            }
            fn visit_f64<E>(self, x: f64) -> Result<Datum, E> {
                Ok(Datum::F32(x as f32)) // serde's own f32 path (tests: serde_float_path_is_exact)
            }
            fn visit_str<E>(self, s: &str) -> Result<Datum, E> {
                Ok(Datum::Str(s.to_owned()))
            }
            fn visit_seq<A: SeqAccess<'de>>(self, mut a: A) -> Result<Datum, A::Error> {
                let mut v = Vec::new();
                while let Some(x) = a.next_element()? {
                    v.push(x);
                }
                Ok(Datum::List(v))
            }
            fn visit_map<A: MapAccess<'de>>(self, mut a: A) -> Result<Datum, A::Error> {
                let (k, s): (String, String) = a.next_entry()?.ok_or_else(|| de::Error::custom("empty object"))?;
                if k != "f64" || a.next_key::<String>()?.is_some() {
                    return Err(de::Error::custom("an object in a datum other than {\"f64\":…}"));
                }
                s.parse().map(Datum::F64).map_err(de::Error::custom)
            }
        }
        d.deserialize_any(V)
    }
}

/// T / NIL as written (`true` / `null`; the writer has no `false`) → bool.
pub(crate) fn lbool<'de, D: Deserializer<'de>>(d: D) -> Result<bool, D::Error> {
    Ok(Option::<bool>::deserialize(d)?.unwrap_or(false))
}
