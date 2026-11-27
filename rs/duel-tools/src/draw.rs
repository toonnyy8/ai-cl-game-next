//! `duel-tools draw --check FILE.bin [--arrays LIST] [--mask LANES] [--frames A-B] [--data DIR]`: replays a draw-key scene
//! (docs/bevy/M3A_NOTES.md §1, §5) with the key's inputs and compares each keyed frame's `FrameOut` with the key.
//!
//! The scene's commands, viewport and fixed inputs come from FILE's INDEX.json (same directory, entry named by FILE's stem). Each
//! frame is the game loop's three calls: `flow::frame` (dt `raw_dt` of the next pump), `duel_look::draw_frame`, `flow::frame_end`.
//! Key frame F is pump F + 1. (`duel_look::frame_begin` comes first, SCREEN-FX-UPDATE's place; the sounds are cleared after.) `--arrays`: the arrays compared (default `fu,p,dq,fxa,fxb,ui,ft,rng`; `hb` / `hk` are M3b's and never
//! compared here). `--mask`: lanes a later task fills, left out of both sides: `lights` (fu 70..=135: the point lights, vfx.lisp's
//! ADD-POINT-LIGHT), `fighters` (dq records of a body, weapon or the ink shadow mesh: DRAW-FIGHTER, Task 7; Ichigo's look bodies use
//! the same meshes, so they are in this lane too), `chips` (dq records of the stage's rubble chips and their hulls, ST-CHIPS: Task 6).
//! The cracks and marks draw into `ft` only and the hazards draw no dq record: there is no dq lane for them. A lane is chosen by
//! the mesh's registry path (tables.json `mesh_ids`, equal to the key's meshes.json), never by a record's place.
//! Tolerance: `|a - b| <= 1e-5 max(1, |b|)` per float; a record count, a stream length, a mesh id and the RNG state exactly.
//! Prints `draw OK <scene> <frames>` (exit 0) or the first mismatch (scene, frame, array, index, both values; exit 1), a line with
//! the largest error per array, and the heap allocations: the whole frame's (sink and draw included) in the frames after frame 0
//! that run no command (the combat log off after the commands' frame, as the sim's 0-alloc gate), and `draw_frame`'s alone in every
//! frame from frame 1 (command frames too). Exit 3: the replay reached an `unported!` sim path or a `look_unported`; exit 2: bad arguments.
use duel_data::Data;
use duel_look::{draw_frame, frame_begin, FrameOut, Scene, SceneInputs};
use duel_sim::cpu::Search;
use duel_sim::flow::{self, NoInput};
use duel_sim::state::Match;
use std::collections::BTreeMap;
use std::process::ExitCode;

pub const USAGE: &str = "duel-tools draw --check FILE.bin [--arrays fu,p,dq,fxa,fxb,ui,ft,rng] [--mask lights,fighters,chips] [--frames A-B] [--data DIR]";
const ARRAYS: [&str; 9] = ["fu", "p", "dq", "fxa", "fxb", "ui", "ft", "hb", "hk"];
const LANES: [&str; 3] = ["lights", "fighters", "chips"];

/// One keyed frame of the key: its number, `*tick*`, the RNG state and the nine arrays.
pub struct KeyFrame {
    pub frame: u32,
    pub tick: u32,
    pub rng: u32,
    pub arrays: [Vec<f32>; 9],
}

/// port: tools/port/oracle/stubs-draw.c's format (its header is authoritative): the viewport and the keyed frames (the meshes are
/// skipped: Task 3's test compares them).
pub fn read_key(path: &str) -> Result<(u32, u32, Vec<KeyFrame>), String> {
    let b = std::fs::read(path).map_err(|e| format!("{path}: {e}"))?;
    let mut o = 0usize;
    let u32_at = |o: &mut usize| -> Result<u32, String> {
        let v = b.get(*o..*o + 4).ok_or(format!("{path}: truncated at {o}"))?;
        *o += 4;
        Ok(u32::from_le_bytes(v.try_into().unwrap()))
    };
    if b.get(..8) != Some(b"SDDRW1\0\0".as_slice()) {
        return Err(format!("{path}: not a draw key"));
    }
    o += 8;
    let (w, h, nm, nf) = (u32_at(&mut o)?, u32_at(&mut o)?, u32_at(&mut o)?, u32_at(&mut o)?);
    for _ in 0..nm {
        let _id = u32_at(&mut o)?;
        o += 4 * u32_at(&mut o)? as usize;
    }
    let mut frames = Vec::with_capacity(nf as usize);
    for _ in 0..nf {
        let (frame, tick, rng) = (u32_at(&mut o)?, u32_at(&mut o)?, u32_at(&mut o)?);
        let mut arrays: [Vec<f32>; 9] = Default::default();
        for a in arrays.iter_mut() {
            let n = u32_at(&mut o)? as usize;
            let s = b.get(o..o + 4 * n).ok_or(format!("{path}: truncated in frame {frame}"))?;
            *a = s.as_chunks::<4>().0.iter().map(|c| f32::from_le_bytes(*c)).collect();
            o += 4 * n;
        }
        frames.push(KeyFrame { frame, tick, rng, arrays });
    }
    Ok((w, h, frames))
}

struct Opts {
    file: String,
    arrays: Vec<String>,
    mask: Vec<String>,
    frames: Option<(u32, u32)>,
    data: Option<String>,
}

fn parse_args(a: &[String]) -> Result<Opts, String> {
    let mut o = Opts { file: String::new(), arrays: "fu,p,dq,fxa,fxb,ui,ft,rng".split(',').map(String::from).collect(), mask: vec![], frames: None, data: None };
    let mut it = a.iter();
    let list = |v: Option<&String>| -> Result<Vec<String>, String> { Ok(v.ok_or("a flag without its value")?.split(',').filter(|s| !s.is_empty()).map(String::from).collect()) };
    while let Some(x) = it.next() {
        match x.as_str() {
            "--check" => o.file = it.next().ok_or("--check without FILE")?.clone(),
            "--arrays" => o.arrays = list(it.next())?,
            "--mask" => o.mask = list(it.next())?,
            "--data" => o.data = Some(it.next().ok_or("--data without DIR")?.clone()),
            "--frames" => {
                let v = it.next().ok_or("--frames without A-B")?;
                let (a, b) = v.split_once('-').ok_or("--frames A-B")?;
                o.frames = Some((a.parse().map_err(|_| "--frames A-B")?, b.parse().map_err(|_| "--frames A-B")?));
            }
            _ => return Err(format!("unknown argument {x}")),
        }
    }
    if o.file.is_empty() {
        return Err("--check FILE is required".into());
    }
    for x in &o.arrays {
        if !(ARRAYS[..7].contains(&x.as_str()) || x == "rng") {
            return Err(format!("--arrays: {x} (one of fu p dq fxa fxb ui ft rng; hb / hk are M3b's)"));
        }
    }
    for x in &o.mask {
        if !LANES.contains(&x.as_str()) {
            return Err(format!("--mask: {x} (one of {})", LANES.join(" ")));
        }
    }
    Ok(o)
}

/// A scene's name, its commands (frame, command), its fixed inputs and `*one-hand*` (the sim's: `Match.settings.one_hand`).
type SceneEntry = (String, Vec<(u32, i64)>, SceneInputs, bool);

/// The scene's INDEX.json entry.
fn scene_entry(file: &str) -> Result<SceneEntry, String> {
    let p = std::path::Path::new(file);
    let name = p.file_stem().and_then(|s| s.to_str()).ok_or("FILE has no name")?.to_string();
    let ix = p.with_file_name("INDEX.json");
    let j: serde_json::Value = serde_json::from_str(&std::fs::read_to_string(&ix).map_err(|e| format!("{}: {e}", ix.display()))?).map_err(|e| e.to_string())?;
    let sc = j["scenes"].as_array().and_then(|v| v.iter().find(|s| s["name"] == name.as_str())).ok_or(format!("INDEX.json: no scene {name}"))?;
    let cmds = sc["cmds"]
        .as_array()
        .ok_or("cmds")?
        .iter()
        .map(|c| match c.as_array() {
            Some(fc) => (fc[0].as_u64().unwrap() as u32, fc[1].as_i64().unwrap()),
            None => (0, c.as_i64().unwrap()),
        })
        .collect();
    let vp = &sc["viewport"];
    let read = j["fixed_inputs"]["read_from_image"][0].as_str().ok_or("INDEX.json fixed_inputs.read_from_image")?;
    let w: Vec<&str> = read.split(' ').collect(); // "render-scale 1.0 pixel-lights 8 scene-scale-cap 1.0 msaa 1 coarse NIL one-hand NIL"
    let val = |k: &str| w.iter().position(|x| *x == k).map(|i| w[i + 1]).ok_or(format!("fixed input {k}"));
    let inputs = SceneInputs {
        width: vp[0].as_u64().ok_or("viewport")? as u32,
        height: vp[1].as_u64().ok_or("viewport")? as u32,
        density: vp[2].as_f64().ok_or("viewport")? as f32,
        msaa: val("msaa")?.parse().map_err(|_| "msaa")?,
        render_scale: val("render-scale")?.parse().map_err(|_| "render-scale")?,
        pixel_lights: val("pixel-lights")?.parse().map_err(|_| "pixel-lights")?,
        coarse: val("coarse")? != "NIL", // (read by nothing in M3a, as density: the touch deck's, M3b)
        scene_scale_cap: val("scene-scale-cap")?.parse().map_err(|_| "scene-scale-cap")?,
    };
    Ok((name, cmds, inputs, val("one-hand")? != "NIL"))
}

/// The mesh ids of the masked dq lanes (by the registry's paths).
fn masked_ids(d: &Data, mask: &[String]) -> Vec<bool> {
    let ids = d.mesh_ids();
    let mut v = vec![false; ids.iter().map(|r| r.0 as usize + 1).max().unwrap_or(0)];
    for (id, path, _) in &ids {
        let lane = if path.starts_with("*BODIES*") || path.starts_with("*WEAPONS*") || path == "*SHADOW-MESH*" {
            "fighters"
        } else if path.starts_with("*ST-ROCKS*") {
            "chips"
        } else {
            continue;
        };
        v[*id as usize] = mask.iter().any(|m| m == lane);
    }
    v
}

fn close(a: f32, b: f32) -> (bool, f64) {
    let e = (a as f64 - b as f64).abs() / f64::max(1.0, (b as f64).abs());
    (e <= 1e-5 || (a.is_nan() && b.is_nan()), e)
}

/// The comparison's running result.
struct Cmp {
    first: Option<String>,
    worst: BTreeMap<&'static str, f64>,
    floats: u64,
    /// Floats compared per array.
    count: BTreeMap<&'static str, u64>,
}

impl Cmp {
    fn fail(&mut self, msg: String) {
        self.first.get_or_insert(msg);
    }
    fn floats(&mut self, scene: &str, frame: u32, arr: &'static str, got: &[f32], want: &[f32], skip: impl Fn(usize) -> bool) {
        if got.len() != want.len() {
            return self.fail(format!("{scene} frame {frame} {arr}: {} floats, key {}", got.len(), want.len()));
        }
        for (i, (a, b)) in got.iter().zip(want).enumerate() {
            if skip(i) {
                continue;
            }
            let (ok, e) = close(*a, *b);
            self.floats += 1;
            *self.count.entry(arr).or_insert(0) += 1;
            let w = self.worst.entry(arr).or_insert(0.0);
            *w = w.max(e);
            if !ok {
                return self.fail(format!("{scene} frame {frame} {arr}[{i}]: {a:?} key {b:?} (|a-b|/max(1,|b|) {e:.3e})"));
            }
        }
    }
}

pub fn draw_cmd(args: &[String]) -> ExitCode {
    let o = match parse_args(args) {
        Ok(o) => o,
        Err(e) => {
            eprintln!("{e}\nusage: {USAGE}");
            return ExitCode::from(2);
        }
    };
    let data: &'static Data = Box::leak(Box::new(match &o.data {
        Some(p) => match Data::load(p.as_ref()) {
            Ok(d) => d,
            Err(e) => {
                println!("draw: data: {e}");
                return ExitCode::FAILURE;
            }
        },
        None => Data::embedded(),
    }));
    match run(&o, data) {
        Ok(code) => ExitCode::from(code),
        Err(e) => {
            println!("draw: {e}");
            ExitCode::FAILURE
        }
    }
}

fn run(o: &Opts, data: &'static Data) -> Result<u8, String> {
    let (name, cmds, inputs, one_hand) = scene_entry(&o.file)?;
    let (w, h, key) = read_key(&o.file)?;
    if (w, h) != (inputs.width, inputs.height) {
        return Err(format!("{name}: the key's viewport {w}x{h} is not INDEX's {}x{}", inputs.width, inputs.height));
    }
    let key: Vec<&KeyFrame> = key.iter().filter(|k| o.frames.is_none_or(|(a, b)| a <= k.frame && k.frame <= b)).collect();
    let last = key.last().map_or(0, |k| k.frame);
    let masked = masked_ids(data, &o.mask);
    let is_masked = |id: f32| masked.get(id as usize).copied().unwrap_or(false);
    let mask_lights = o.mask.iter().any(|m| m == "lights");
    let want = |a: &str| o.arrays.iter().any(|x| x == a);

    let mut m = Match::new(data);
    m.settings.one_hand = one_hand; // (the key's `*one-hand*`: its one holder)
    flow::go_title(&mut m);
    let mut s = Search::new();
    let mut sc = Scene::new(data, inputs);
    let mut out = FrameOut::default();
    let mut cmp = Cmp { first: None, worst: BTreeMap::new(), floats: 0, count: BTreeMap::new() };
    let (mut allocs, mut counted, mut compared, mut ki, mut draw_allocs) = (0u64, 0u64, 0u32, 0usize, 0u64);
    let (mut got_dq, mut want_dq): (Vec<f32>, Vec<f32>) = (Vec::new(), Vec::new());
    for f in 0..=last {
        let has_cmd = cmds.iter().any(|c| c.0 == f);
        m.cmds.extend(cmds.iter().filter(|c| c.0 == f).map(|c| c.1));
        let a0 = crate::alloc_count::count();
        let rdt = flow::raw_dt(m.frame_n + 1);
        frame_begin(&mut sc, &m, rdt);
        flow::frame(&mut m, &mut s, &mut NoInput, &mut sc, rdt);
        let d0 = crate::alloc_count::count();
        draw_frame(&mut sc, &mut m, rdt, &mut out);
        if f > 0 {
            draw_allocs += crate::alloc_count::count() - d0; // (draw_frame alone, every frame from 1, command frames too)
        }
        flow::frame_end(&mut m, &mut s);
        sc.sounds.clear(); // (the page's player takes them here: M3b)
        if f > 0 && !has_cmd {
            (allocs, counted) = (allocs + crate::alloc_count::count() - a0, counted + 1);
        }
        if has_cmd {
            m.log_on = false; // (the commands turn the combat log on; its lines are the log's allocations, not the frame's)
        }
        if let Some(u) = m.unported.or(sc.unported) {
            println!("draw UNPORTED {name} frame {f}: {u}");
            return Ok(3);
        }
        if ki >= key.len() || key[ki].frame != f {
            continue;
        }
        let k = key[ki];
        ki += 1;
        compared += 1;
        if want("rng") && sc.cos.state() != k.rng {
            cmp.fail(format!("{name} frame {f} rng: {:#010x} key {:#010x}", sc.cos.state(), k.rng));
        }
        if want("fu") {
            cmp.floats(&name, f, "fu", &out.fu, &k.arrays[0], |i| mask_lights && (70..=135).contains(&i));
        }
        if want("p") {
            cmp.floats(&name, f, "p", &out.p, &k.arrays[1], |_| false);
        }
        if want("dq") {
            got_dq.clear();
            want_dq.clear();
            got_dq.extend(out.dq.iter().filter(|r| !is_masked(r[23])).flatten());
            want_dq.extend(k.arrays[2].as_chunks::<32>().0.iter().filter(|r| !is_masked(r[23])).flatten());
            if got_dq.len() != want_dq.len() {
                cmp.fail(format!("{name} frame {f} dq: {} records, key {} (unmasked)", got_dq.len() / 32, want_dq.len() / 32));
            }
            for (i, (a, b)) in got_dq.as_chunks::<32>().0.iter().zip(want_dq.as_chunks::<32>().0).enumerate() {
                if a[23] != b[23] {
                    cmp.fail(format!("{name} frame {f} dq record {i} (unmasked): mesh {} key {}", a[23], b[23]));
                    break;
                }
            }
            cmp.floats(&name, f, "dq", &got_dq, &want_dq, |_| false);
        }
        for (i, arr, v) in [(3, "fxa", &out.fxa), (4, "fxb", &out.fxb), (5, "ui", &out.ui), (6, "ft", &out.ft)] {
            if want(arr) {
                cmp.floats(&name, f, arr, v, &k.arrays[i], |_| false);
            }
        }
        if let Some(e) = cmp.first.take() {
            cmp.first = Some(format!("{e} (key tick {}, sim tick {})", k.tick, m.match_tick));
            break;
        }
    }
    let worst: Vec<String> = cmp.worst.iter().map(|(a, e)| format!("{a} {e:.2e} ({} floats)", cmp.count[a])).collect();
    let per = if counted > 0 { allocs as f64 / counted as f64 } else { 0.0 };
    let tail = format!("largest error: {}; {} floats; allocs {allocs} in {counted} frames after frame 0 ({per:.2} per frame; commandless frames), draw_frame allocs {draw_allocs} in {last} frames from frame 1", worst.join(", "), cmp.floats);
    let masks = if o.mask.is_empty() { String::new() } else { format!(" (masked: {})", o.mask.join(",")) };
    match cmp.first {
        Some(e) => {
            println!("draw MISMATCH {e}");
            println!("{tail}");
            Ok(1)
        }
        None => {
            println!("draw OK {name} {compared}{masks} [{}]", o.arrays.join(","));
            println!("{tail}");
            Ok(0)
        }
    }
}
