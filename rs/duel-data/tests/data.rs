//! The loader's exactness proof against the extractor (Tasks 4-5): counts, the float checksum, the serde float path.
use duel_data::checksum::{self, Float};
use duel_data::{Data, Datum};
use std::path::Path;

fn dir() -> &'static Path {
    Path::new(concat!(env!("CARGO_MANIFEST_DIR"), "/data"))
}

fn data() -> Data {
    Data::load(dir()).expect("load")
}

#[test]
fn loads_every_file() {
    let d = data();
    let counts = d.counts();
    assert_eq!(counts, d.manifest.counts);
    assert_eq!(counts.len(), 11);
    assert_eq!(d.moves.len(), 549);
    assert_eq!(d.manifest.skipped_tuning, 3);
}

#[test]
fn embedded_equals_load() {
    let (a, b) = (Data::embedded(), data());
    assert_eq!(a.counts(), b.counts());
    assert_eq!(checksum::floats(&a), checksum::floats(&b));
}

#[test]
fn float_checksum_matches_manifest() {
    let d = data();
    assert_eq!(format!("{:016x}", checksum::floats(&d)), d.manifest.float_checksum);
    assert_eq!(d.manifest.float_checksum, "6640f0fd66ac0848");
}

/// The typed structs read numbers through serde_json (f64, then `as f32`); the checksum parses each token exactly
/// (`str::parse::<f32>`). Equal bits on every float token of every file = the typed fields hold the extractor's bits.
#[test]
fn serde_float_path_is_exact() {
    let d = data();
    let mut n = 0usize;
    for (name, text) in d.files() {
        checksum::for_each_float_token(text, |tok, f| {
            if let Float::F32(x) = f {
                let s: f32 = serde_json::from_str(tok).unwrap();
                assert_eq!(s.to_bits(), x.to_bits(), "{name}: token {tok}");
                n += 1;
            }
        });
    }
    assert!(n > 500_000, "{n}"); // 526441 f32 tokens in the 2026-11-26 extract
}

#[test]
fn edge_floats() {
    let text = br#"[1.4,-0.0,1.4012985e-45,{"f64":"3.141592653589793"},7,"1.5"]"#;
    let mut got = vec![];
    checksum::for_each_float_token(text, |_, f| got.push(f));
    assert_eq!(got.len(), 4);
    let typed: Vec<Datum> = serde_json::from_slice(text).unwrap();
    for (g, t) in got.iter().zip(&typed) {
        match (g, t) {
            (Float::F32(a), Datum::F32(b)) => assert_eq!(a.to_bits(), b.to_bits()),
            (Float::F64(a), Datum::F64(b)) => assert_eq!(a.to_bits(), b.to_bits()),
            _ => panic!("{g:?} vs {t:?}"),
        }
    }
    let bits: Vec<u64> = got
        .iter()
        .map(|f| match f {
            Float::F32(x) => x.to_bits() as u64,
            Float::F64(x) => x.to_bits(),
        })
        .collect();
    assert_eq!(bits, [0x3fb33333, 0x80000000, 0x00000001, 0x400921fb54442d18]);
    assert!(matches!(typed[4], Datum::Int(7)));
}

/// ECL's (integer-decode-float x) triples from docs/bevy/M0_NOTES.md §3 (tools/port/extract/json.lisp) and its two 13-byte vectors.
#[test]
fn decode_matches_ecl() {
    let f32s: [(u32, u64, i32, i8); 8] = [
        (0x00000000, 0, 0, 1),
        (0x80000000, 0, 0, -1),
        (0x00000001, 8388608, -172, 1),
        (0x007fffff, 16777214, -150, 1),
        (0x00800000, 8388608, -149, 1),
        (1.0f32.to_bits(), 8388608, -23, 1),
        (1.4f32.to_bits(), 11744051, -23, 1),
        (f32::MAX.to_bits(), 16777215, 104, 1),
    ];
    for (b, m, e, s) in f32s {
        assert_eq!(checksum::integer_decode(Float::F32(f32::from_bits(b))), (m, e, s), "{b:#x}");
    }
    let f64s: [(f64, u64, i32, i8); 4] = [
        (0.0, 0, 0, 1),
        (-0.0, 0, 0, -1),
        (std::f64::consts::PI, 7074237752028440, -51, 1),
        (f64::from_bits(1), 4503599627370496, -1126, 1),
    ];
    for (x, m, e, s) in f64s {
        assert_eq!(checksum::integer_decode(Float::F64(x)), (m, e, s), "{x}");
    }
    assert_eq!(
        checksum::bytes(Float::F32(1.0)),
        [0x00, 0xe9, 0xff, 0xff, 0xff, 0x00, 0x00, 0x80, 0, 0, 0, 0, 0]
    );
    assert_eq!(checksum::bytes(Float::F32(-0.0)), [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
}

/// Yamamoto's NS1c and its two garb copies (yama.lisp *YA-GARB-COPIES*): CAP volumes of length 4.5, 4.5 x 1.2, 4.5 x 1.4.
/// The last is 6.2999997 in f32 (the game's product), not 6.3f32.
#[test]
fn garb_copy_present() {
    let d = data();
    let mut lens: Vec<f32> = d
        .moves
        .iter()
        .filter(|m| m.name == "ya-e-n1c")
        .map(|m| {
            let v = m.hits[0].vols[0];
            assert_eq!(v[0], 1.0, "{}: not a CAP", m.id);
            v[2]
        })
        .collect();
    lens.sort_by(f32::total_cmp);
    assert_eq!(lens, [4.5, 4.5f32 * 1.2, 4.5f32 * 1.4]);
    assert_eq!(lens[2], 6.2999997);
    assert!(d.moves.iter().any(|m| m.id == "yamamoto/bankai/ya-e-n1c"));
}

/// Typed hit volumes carry the same bits as a serde_json::Value walk of the same move (arrays: no key-order question).
#[test]
fn typed_vols_match_walk() {
    let d = data();
    let raw: Vec<serde_json::Value> = serde_json::from_slice(d.file("moves.json")).unwrap();
    let mut n = 0;
    for (m, v) in d.moves.iter().zip(&raw) {
        assert_eq!(v["id"], m.id.as_str());
        for (h, hv) in m.hits.iter().zip(v["hits"].as_array().unwrap()) {
            let walk: Vec<u32> = hv["vols"]
                .as_array()
                .unwrap()
                .iter()
                .flat_map(|vol| vol.as_array().unwrap().iter().map(|x| (x.as_f64().unwrap() as f32).to_bits()))
                .collect();
            let typed: Vec<u32> = h.vols.iter().flatten().map(|x| x.to_bits()).collect();
            assert_eq!(typed, walk, "{}", m.id);
            n += typed.len();
        }
    }
    assert!(n > 2000, "{n}");
}

/// Move.params and Kit.core typed (Task 3, M1): every move and form loads, spot values per key kind.
#[test]
fn params_typed_for_every_move() {
    let d = data();
    assert_eq!(d.moves.len(), 549);
    let m = |id: &str| &d.moves.iter().find(|m| m.id == id).unwrap_or_else(|| panic!("{id}")).params;
    assert_eq!(m("kenpachi/nozarashi/ke-s-n1a").ns_next.as_deref(), Some("ke-s-n1b"));
    assert!(d.moves.iter().any(|x| x.params.burst == Some([100, 150, 200, 260])));
    assert!(d.moves.iter().any(|x| x.params.chain == Some([-70.0, 70.0, 3.0, 0.8, 1.4])));
    assert!(d.moves.iter().any(|x| x.params.window == Some([2, 25])));
    assert_eq!(d.moves.iter().filter(|x| x.params.lv_up).count(), 16);
    assert_eq!(d.moves.iter().filter(|x| x.params.melee_range.is_some()).count(), 109);
    let k = &d.kits.kits["kenpachi"]["nozarashi"].core;
    assert_eq!(k.ns, ["ke-s-n1a", "ke-s-n2a"]);
    assert!(k.sp_cost_mult.is_some() && !k.sp_free);
    assert_eq!(d.kits.kits["hisagi"]["bankai"].core.range, Some([3.0, 4.5]));
    assert!(d.kits.kits.values().flat_map(|f| f.values()).all(|k| !k.core.as_segs.is_empty() && k.core.mult > 0.0));
}
