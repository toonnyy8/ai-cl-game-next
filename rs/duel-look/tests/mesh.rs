//! The meshes against the draw key ($ORACLE/draw, tools/port/oracle/stubs-draw.c's header): every Kenpachi / Ichigo / stage mesh a
//! keyed scene draws equals, float for float (the key's tolerance), what the frozen build passed to r_mesh_new; duel-data's mesh
//! registry (tables.json mesh_ids) equals the key's meshes.json. The tests fail when ORACLE is unset; they never skip.
use duel_data::Data;
use duel_look::mesh::Meshes;
use std::collections::BTreeMap;
use std::io::Read;
use std::path::PathBuf;

fn draw_dir() -> PathBuf {
    let oracle = std::env::var("ORACLE").expect("ORACLE: the answer key's directory (build/oracle) must be set: the mesh key is never skipped");
    PathBuf::from(oracle).join("draw")
}

/// The key's meshes.json: id -> (name, verts).
fn key_names() -> BTreeMap<u32, (String, u32)> {
    let v: serde_json::Value = serde_json::from_slice(&std::fs::read(draw_dir().join("meshes.json")).unwrap()).unwrap();
    v["meshes"]
        .as_object()
        .unwrap()
        .iter()
        .map(|(id, m)| (id.parse().unwrap(), (m["made_by"].as_str().unwrap().to_string(), m["verts"].as_u64().unwrap() as u32)))
        .collect()
}

fn u32le(r: &mut impl Read) -> u32 {
    let mut b = [0u8; 4];
    r.read_exact(&mut b).unwrap();
    u32::from_le_bytes(b)
}

/// Every mesh any scene draws (the .bin files' mesh blocks; the frames are not read): id -> (scene, floats). A mesh in two scenes
/// must be the same bits (ids are per process, but every scene's image makes the same meshes in the same order).
fn key_meshes() -> BTreeMap<u32, (String, Vec<f32>)> {
    let mut out: BTreeMap<u32, (String, Vec<f32>)> = BTreeMap::new();
    let mut files: Vec<_> = std::fs::read_dir(draw_dir()).unwrap().map(|e| e.unwrap().path()).filter(|p| p.extension().is_some_and(|x| x == "bin")).collect();
    files.sort();
    assert_eq!(files.len(), 41, "41 scenes (M3A_NOTES §1)");
    for p in files {
        let scene = p.file_stem().unwrap().to_string_lossy().to_string();
        let mut r = std::io::BufReader::new(std::fs::File::open(&p).unwrap());
        let mut magic = [0u8; 8];
        r.read_exact(&mut magic).unwrap();
        assert_eq!(&magic, b"SDDRW1\0\0", "{scene}");
        let (_w, _h, n, _frames) = (u32le(&mut r), u32le(&mut r), u32le(&mut r), u32le(&mut r));
        for _ in 0..n {
            let (id, nf) = (u32le(&mut r), u32le(&mut r) as usize);
            let mut b = vec![0u8; nf * 4];
            r.read_exact(&mut b).unwrap();
            let f: Vec<f32> = b.as_chunks::<4>().0.iter().map(|c| f32::from_le_bytes(*c)).collect();
            match out.get(&id) {
                Some((s0, f0)) => assert!(f0.iter().map(|x| x.to_bits()).eq(f.iter().map(|x| x.to_bits())), "mesh {id}: {s0} and {scene} differ"),
                None => {
                    out.insert(id, (scene.clone(), f));
                }
            }
        }
    }
    out
}

/// The ids this task builds: the Kenpachi and Ichigo bodies, their kits' weapons, the stage and the ink shadow (Hisagi, Yamamoto and
/// the skeleton are M4).
fn in_scope(name: &str) -> bool {
    const WEAPONS: [&str; 5] = ["KEN-KATANA", "NOZARASHI", "KE-BROKEN", "ZANGETSU-LONG", "TENSA"];
    name.starts_with("*BODIES*{:KENPACHI")
        || name.starts_with("*BODIES*{:ICHIGO")
        || WEAPONS.iter().any(|w| name.starts_with(&format!("*WEAPONS*{{:{w}}}")))
        || name.starts_with("*ST-")
        || name == "*SHADOW-MESH*"
}

#[test]
fn mesh_table_matches_key() {
    let d = Data::embedded();
    let table: BTreeMap<u32, (String, u32)> = d.mesh_ids().into_iter().map(|(id, p, v)| (id, (p, v))).collect();
    let key = key_names();
    assert_eq!(table.len(), 670);
    assert_eq!(table, key, "duel-data's mesh_ids differ from the key's meshes.json");
}

#[test]
fn meshes_match_key() {
    let d = Data::embedded();
    let names = key_names();
    let key = key_meshes();
    let m = Meshes::build(&d);

    // the filled ids are exactly the in-scope names
    let want: Vec<u32> = names.iter().filter(|(_, (n, _))| in_scope(n)).map(|(id, _)| *id).collect();
    let got: Vec<u32> = m.filled().collect();
    assert_eq!(want.len(), 368);
    let extra: Vec<_> = got.iter().filter(|id| !want.contains(id)).map(|id| &names[id].0).collect();
    let missing: Vec<_> = want.iter().filter(|id| !got.contains(id)).map(|id| &names[id].0).collect();
    assert!(extra.is_empty() && missing.is_empty(), "{} filled but out of scope: {:?}; {} in scope but empty: {:?}", extra.len(), &extra[..extra.len().min(10)], missing.len(), &missing[..missing.len().min(10)]);

    let (mut drawn, mut floats, mut inexact, mut worst, mut worst_at) = (0usize, 0usize, 0usize, 0f32, String::new());
    for id in &want {
        let (name, verts) = &names[id];
        let ours = &m.get(*id).unwrap().floats;
        assert_eq!(ours.len(), *verts as usize * 9, "mesh {id} {name}: {} verts, the key's meshes.json {verts}", ours.len() / 9);
        let Some((scene, theirs)) = key.get(id) else { continue }; // undrawn: the count above is all the key holds
        drawn += 1;
        assert_eq!(ours.len(), theirs.len(), "mesh {id} {name} ({scene}): {} floats, the key {}", ours.len(), theirs.len());
        for (i, (a, b)) in ours.iter().zip(theirs).enumerate() {
            let e = (a - b).abs() / b.abs().max(1.0);
            assert!(
                e <= 1e-5,
                "mesh {id} {name} ({scene}): vertex {} slot {} ({}): ours {a} key {b}",
                i / 9,
                i % 9,
                ["x", "y", "z", "nx", "ny", "nz", "r", "g", "b"][i % 9]
            );
            inexact += (a.to_bits() != b.to_bits()) as usize;
            if e > worst {
                (worst, worst_at) = (e, format!("mesh {id} {name} vertex {} slot {}", i / 9, i % 9));
            }
        }
        floats += ours.len();
    }
    assert_eq!(drawn, 277, "the in-scope meshes the 41 scenes draw");
    println!("meshes_match_key: {drawn} drawn meshes, {floats} floats ({inexact} not bit-equal); {} undrawn by count only; largest |a-b|/max(1,|b|) {worst:e} at {worst_at}", want.len() - drawn);
}
