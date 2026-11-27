//! The meshes: every Kenpachi / Ichigo / stage mesh the frozen build makes at startup, built in pure Rust into the ids of the
//! frozen image's own mesh registry (duel-data tables.json `mesh_ids`), so a draw record's mesh id is the Lisp's.
//! - `meshgen` (the brief's `gen.rs`: `gen` is a reserved word in edition 2024): engine/lisp/meshgen.lisp (the builder, its primitives, the ink hull);
//! - `body`: the bodies' parts, tagged parts, glows and hulls (engine/lisp/body.lisp BUILD-PARTS over bodies.json's spec);
//! - the weapons: weapons.json's section verts are the built meshes (the extractor ran each DEFWEAPON section on a fresh builder,
//!   as BUILD-WEAPON does), plus their hulls (duel/lisp/body.lisp BUILD-WEAPON);
//! - the ink shadow (body.lisp BODIES-INIT) and `stage` (stage.lisp STAGE-INIT).
//!
//! Hisagi's and Yamamoto's bodies and weapons and the skeleton stay empty: M4 (M3A_NOTES §3).
pub mod body;
pub mod meshgen;
pub mod stage;

use duel_data::Data;
use meshgen::{hexc, hull, Mb, V3};
use std::collections::BTreeMap;

/// The characters whose looks M3a ports: their bodies (the name or `<name>-…`) and their kits' weapons.
pub const PORTED: [&str; 2] = ["kenpachi", "ichigo"];

/// One mesh as `r_mesh_new` gets it: 9 floats a vertex (position, normal, sRGB colour).
pub struct MeshData {
    pub floats: Vec<f32>,
}

/// A body's meshes by the Lisp's indices: PARTS per joint, EXTRAS and HULLS in BUILD-PARTS' list order.
pub struct BodyIds {
    pub parts: Vec<Option<u32>>,
    pub extras: Vec<ExtraId>,
    pub hulls: Vec<HullId>,
}
/// BUILD-PARTS' EXTRAS #(joint mesh tint emissive tag): TINT None for a tagged solid part, the glow's colour for a glow.
pub struct ExtraId {
    pub joint: usize,
    pub id: u32,
    pub tint: Option<V3>,
    pub emissive: f32,
    pub tag: Option<String>,
}
/// BUILD-PARTS' HULLS #(joint mesh tag).
pub struct HullId {
    pub joint: usize,
    pub id: u32,
    pub tag: Option<String>,
}
/// BUILD-WEAPON's #(mesh tint emissive hull): TINT None for a solid section (toon like the body), the colour for a glow.
pub struct WeaponPartId {
    pub id: u32,
    pub tint: Option<V3>,
    pub emissive: f32,
    pub hull: Option<u32>,
}
/// stage.lisp's meshes.
pub struct StageIds {
    pub floor: u32,
    pub walls: u32,
    pub town: u32,
    pub burnt: u32,
    /// *ST-ROCKS*: (chip, its ink hull) x 3.
    pub rocks: Vec<(u32, u32)>,
}

/// The lookup the draw path uses: body part / weapon section / stage piece -> mesh id (keys: the data's lower-case names).
pub struct Ids {
    pub bodies: BTreeMap<String, BodyIds>,
    pub weapons: BTreeMap<String, Vec<WeaponPartId>>,
    pub shadow: u32,
    pub stage: StageIds,
}

/// The built meshes: a sparse table by Lisp mesh id, and the ids by piece.
pub struct Meshes {
    meshes: Vec<Option<MeshData>>,
    pub ids: Ids,
}

/// duel-data's registry: path -> id.
struct Registry(BTreeMap<String, u32>);

impl Meshes {
    pub fn get(&self, id: u32) -> Option<&MeshData> {
        self.meshes.get(id as usize).and_then(|m| m.as_ref())
    }
    /// The ids that hold a mesh, ascending.
    pub fn filled(&self) -> impl Iterator<Item = u32> + '_ {
        self.meshes.iter().enumerate().filter(|m| m.1.is_some()).map(|m| m.0 as u32)
    }

    fn put(&mut self, reg: &Registry, path: &str, floats: Vec<f32>) -> u32 {
        let id = *reg.0.get(path).unwrap_or_else(|| panic!("mesh {path}: not in the registry (tables.json mesh_ids)"));
        let slot = &mut self.meshes[id as usize];
        assert!(slot.is_none(), "mesh {path} (id {id}) built twice");
        *slot = Some(MeshData { floats });
        id
    }

    pub fn build(d: &Data) -> Meshes {
        let table = d.mesh_ids();
        let reg = Registry(table.iter().map(|(id, p, _)| (p.clone(), *id)).collect());
        let n = table.iter().map(|t| t.0 as usize + 1).max().unwrap_or(0);
        let mut m = Meshes {
            meshes: (0..n).map(|_| None).collect(),
            ids: Ids { bodies: BTreeMap::new(), weapons: BTreeMap::new(), shadow: 0, stage: StageIds { floor: 0, walls: 0, town: 0, burnt: 0, rocks: vec![] } },
        };
        let ported = |name: &str| PORTED.iter().any(|c| name == *c || name.starts_with(&format!("{c}-")));

        // port: duel/lisp/body.lisp BODIES-INIT: the ink shadow, a flat unit disc of 24 sides (a = 2 pi (k / 24), long-floats)
        let mut mb = Mb::with_color(hexc(0x14151C));
        let disc: Vec<V3> = (0..24)
            .map(|k| {
                let a = 2.0 * meshgen::PI * (k as f64 / 24.0);
                [duel_sim::math::cos_d(a) as f32, 0.0, duel_sim::math::sin_d(a) as f32]
            })
            .collect();
        mb.poly_out(&disc, None, [0.0, -1.0, 0.0]);
        m.ids.shadow = m.put(&reg, "*SHADOW-MESH*", mb.data);

        // port: duel/lisp/body.lisp BUILD-WEAPON (the ported characters' kits' weapons)
        let default_ink = d.tuning.get("*BODY-INK*").expect("tuning *BODY-INK*");
        let t_ink = body::Ink::from_value(default_ink);
        let mut weapons: Vec<&String> = d
            .kits
            .kits
            .iter()
            .filter(|(c, _)| PORTED.contains(&c.as_str()))
            .flat_map(|(_, forms)| forms.values())
            .map(|k| &k.weapon)
            .collect();
        weapons.sort();
        weapons.dedup();
        for name in weapons {
            let w = &d.weapons[name.as_str()];
            let key = format!("*WEAPONS*{{:{}}}.MESHES", name.to_uppercase());
            let mut parts = vec![];
            for (i, s) in w.sections.iter().enumerate() {
                let part = match s {
                    duel_data::Section::Solid { ink, ink_color, verts } => {
                        let floats: Vec<f32> = verts.iter().flatten().copied().collect();
                        let h = (*ink > 0).then(|| {
                            let mut h = vec![];
                            hull(&mut h, &floats, 0, floats.len(), *ink as f32, 0.8, hexc(ink_color.unwrap_or_else(|| t_ink.of(None))));
                            h
                        });
                        let id = m.put(&reg, &format!("{key}[{i}][0]"), floats);
                        WeaponPartId { id, tint: None, emissive: 0.0, hull: h.map(|h| m.put(&reg, &format!("{key}[{i}][3]"), h)) }
                    }
                    duel_data::Section::Glow { emissive, color, verts } => {
                        let id = m.put(&reg, &format!("{key}[{i}][0]"), verts.iter().flatten().copied().collect());
                        WeaponPartId { id, tint: Some(hexc(*color)), emissive: *emissive, hull: None }
                    }
                };
                parts.push(part);
            }
            m.ids.weapons.insert(name.clone(), parts);
        }

        // port: duel/lisp/body.lisp BUILD-BODY (BODY-LOAD-STEPS: every body is built at startup)
        for (name, b) in d.bodies.iter().filter(|(n, _)| ported(n)) {
            let ink = b.ink.as_ref().map_or_else(|| body::Ink::from_value(default_ink), |rows| body::Ink::parse(rows));
            let p = body::build_body(b, &d.rig, &ink);
            let key = format!("*BODIES*{{:{}}}", name.to_uppercase());
            let parts = p.parts.into_iter().enumerate().map(|(j, mesh)| mesh.map(|f| m.put(&reg, &format!("{key}.PARTS[{j}]"), f))).collect();
            let extras = p
                .extras
                .into_iter()
                .enumerate()
                .map(|(i, e)| ExtraId { joint: e.joint, id: m.put(&reg, &format!("{key}.EXTRAS[{i}][1]"), e.mesh), tint: e.tint, emissive: e.emissive, tag: e.tag })
                .collect();
            let hulls = p
                .hulls
                .into_iter()
                .enumerate()
                .map(|(i, h)| HullId { joint: h.joint, id: m.put(&reg, &format!("{key}.HULLS[{i}][1]"), h.mesh), tag: h.tag })
                .collect();
            m.ids.bodies.insert(name.clone(), BodyIds { parts, extras, hulls });
        }

        // port: duel/lisp/stage.lisp STAGE-INIT
        let table_f = |name: &str| -> Vec<Vec<f32>> {
            d.tables[name]
                .as_array()
                .unwrap_or_else(|| panic!("tables.json {name}"))
                .iter()
                .map(|r| r.as_array().unwrap().iter().map(|x| x.as_f64().unwrap() as f32).collect())
                .collect()
        };
        let ruins: Vec<[f32; 3]> = table_f("stage_ruins").iter().map(|r| [r[0], r[1], r[2]]).collect();
        let st = stage::build(&table_f("plaza_cracks"), &ruins);
        m.ids.stage.floor = m.put(&reg, "*ST-FLOOR*", st.floor);
        m.ids.stage.walls = m.put(&reg, "*ST-WALLS*", st.walls);
        m.ids.stage.town = m.put(&reg, "*ST-TOWN*", st.town);
        m.ids.stage.burnt = m.put(&reg, "*ST-BURNT*", st.burnt);
        for (k, (rock, h)) in st.rocks.into_iter().enumerate() {
            let pair = (m.put(&reg, &format!("*ST-ROCKS*[{k}][0]"), rock), m.put(&reg, &format!("*ST-ROCKS*[{k}]."), h));
            m.ids.stage.rocks.push(pair);
        }
        m
    }
}
