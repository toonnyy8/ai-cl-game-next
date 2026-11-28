//! Clip sampling and rig FK against the answer key's per-clip FK tables ($ORACLE/fk, tools/port/oracle/look.lisp's header), and
//! the player's crossfade (ANIM-ADVANCE / ANIM-EVAL) by hand.
use duel_data::{Clip, Data};
use duel_look::anim::{sample, Anim, Pose, POSE_N};
use duel_look::rig::{body_weapon_base, body_weapon_tip, pose_fk, Mat4, Proportions, NJ};
use serde::Deserialize;
use std::collections::BTreeMap;

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct FkFile {
    clip: String,
    dur: f32,
    #[serde(rename = "loop")]
    looping: Option<bool>,
    fps: u32,
    frames: usize,
    t: Vec<f32>,
    key_ease: u8,
    joint_names: Vec<String>,
    rigs: Vec<FkRig>,
    forms: Vec<FkForm>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct FkRig {
    bodies: Vec<String>,
    scale: f32,
    hunch: f32,
    props: Option<Vec<f32>>,
    /// Per frame 21 x 16.
    joints: Vec<Vec<f32>>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct FkForm {
    form: String,
    body: String,
    rig: usize,
    by: String,
    weapon: Option<String>,
    weapon_len: Option<f32>,
    weapon_base: Option<f32>,
    tip: Vec<[f32; 3]>,
    base: Vec<[f32; 3]>,
}

/// The key's tolerance (the plan's Global Constraints): |a - b| <= 1e-5 max(1, |b|); returns the relative error.
fn err(a: f32, b: f32) -> f32 {
    (a - b).abs() / b.abs().max(1.0)
}

#[test]
fn fk_matches_key() {
    let oracle = std::env::var("ORACLE").expect("ORACLE: the answer key's directory (build/oracle) must be set: the FK key is never skipped");
    let dir = std::path::Path::new(&oracle).join("fk");
    let d = Data::embedded();
    let mut files: Vec<_> = std::fs::read_dir(&dir)
        .unwrap_or_else(|e| panic!("{}: {e}", dir.display()))
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|x| x == "json") && p.file_stem().is_some_and(|s| s != "INDEX"))
        .collect();
    files.sort_by_key(|p| p.file_stem().unwrap().to_owned()); // (by clip name, as clips.json's keys: "a-b" < "a-b-c")
    let names: Vec<String> = files.iter().map(|p| p.file_stem().unwrap().to_string_lossy().into_owned()).collect();
    assert_eq!(names, d.clips.keys().cloned().collect::<Vec<_>>(), "the key's clip files are clips.json's clips");
    assert_eq!(files.len(), 400);
    let joint_names: Vec<&str> = d.rig.joints.iter().map(|j| j.name.as_str()).collect();
    let key_ease_game = d.rig.key_ease;

    let mut misses: Vec<String> = Vec::new();
    let (mut worst, mut worst_at) = (0f32, String::new());
    let (mut n_mats, mut n_points) = (0usize, 0usize);
    let mut pose: Pose = [0.0; POSE_N];
    let mut jm: [Mat4; NJ] = [[0.0; 16]; NJ];
    for (path, name) in files.iter().zip(&names) {
        let f: FkFile = serde_json::from_slice(&std::fs::read(path).unwrap()).unwrap_or_else(|e| panic!("{name}: {e}"));
        let clip: &Clip = &d.clips[name];
        assert_eq!(f.clip, *name);
        assert!(clip.poses.iter().all(|p| p.len() == POSE_N), "{name}: a key pose of {} floats, not +POSE-N+ {POSE_N}", clip.poses[0].len());
        assert_eq!((f.dur.to_bits(), f.looping.unwrap_or(false), f.fps), (clip.dur.to_bits(), clip.looping, 60), "{name}: dur / loop");
        assert_eq!(f.joint_names, joint_names, "{name}: joint order");
        assert_eq!(f.key_ease as i32, key_ease_game, "{name}: sampled under the game's *KEY-EASE*");
        let n = duel_sim::cl::floor_f32(f.dur * 60.0 + 0.001) as usize;
        assert_eq!((f.frames, f.t.len()), (n + 1, n + 1), "{name}: frames");
        for (i, &t) in f.t.iter().enumerate() {
            assert_eq!(t.to_bits(), (i as f32 / 60.0).to_bits(), "{name}: t[{i}]");
        }
        let mut miss: Option<String> = None;
        let mut check = |what: &dyn Fn() -> String, a: f32, b: f32, miss: &mut Option<String>| {
            let e = err(a, b);
            if e > worst || e.is_nan() {
                worst = e;
                worst_at = what();
            }
            if (e.is_nan() || e > 1e-5) && miss.is_none() {
                *miss = Some(format!("{} : port {a:e} key {b:e}", what()));
            }
        };
        // the rigs: proportions, scale and hunch from duel-data (the key's own, bit for bit), every frame's 21 matrices
        let props_of = |body: &str| {
            let b = &d.bodies[body];
            (Proportions::of(&d.rig, b), b.scale, b.hunch, b.props.clone())
        };
        let rigs: Vec<_> = f.rigs.iter().map(|r| props_of(&r.bodies[0])).collect();
        for (ri, (r, (props, scale, hunch, data_props))) in f.rigs.iter().zip(&rigs).enumerate() {
            for b in &r.bodies {
                let body = &d.bodies[b];
                assert_eq!((body.scale.to_bits(), body.hunch.to_bits()), (r.scale.to_bits(), r.hunch.to_bits()), "{name}: body {b}");
                assert_eq!(body.props.as_ref().map(|v| v.iter().map(|x| x.to_bits()).collect::<Vec<_>>()),
                           r.props.as_ref().map(|v| v.iter().map(|x| x.to_bits()).collect::<Vec<_>>()), "{name}: body {b} props");
            }
            assert_eq!(data_props.as_ref().map(|v| v.len()), r.props.as_ref().map(|v| v.len()));
            assert_eq!(r.joints.len(), n + 1);
            for (i, &t) in f.t.iter().enumerate() {
                sample(clip, t, f.key_ease, &mut pose);
                pose_fk(&pose, props, 0.0, 0.0, 0.0, 0.0, *scale, *hunch, &mut jm);
                assert_eq!(r.joints[i].len(), 16 * NJ);
                for j in 0..NJ {
                    for k in 0..16 {
                        n_mats += 1;
                        check(&|| format!("{name} rig {ri} ({}) frame {i} joint {} m[{k}]", r.bodies[0], joint_names[j]), jm[j][k], r.joints[i][16 * j + k], &mut miss);
                    }
                }
            }
        }
        // the forms: the held weapon's tip and base on each one's body
        for fo in &f.forms {
            let (c, fm) = fo.form.split_once('/').unwrap();
            let kit = &d.kits.kits[c][fm];
            assert_eq!(fo.body, kit.body, "{name} {}: body", fo.form);
            assert!(f.rigs[fo.rig].bodies.contains(&fo.body), "{name} {}: rig", fo.form);
            assert!(["kit", "prefix", "shared"].contains(&fo.by.as_str()));
            let Some(wn) = &fo.weapon else {
                assert!(fo.tip.is_empty() && fo.base.is_empty());
                continue;
            };
            assert_eq!(*wn, kit.weapon, "{name} {}: weapon", fo.form);
            let w = &d.weapons[wn];
            assert_eq!((fo.weapon_len, fo.weapon_base), (Some(w.len), Some(w.base)), "{name} {}: weapon len / base", fo.form);
            assert_eq!((fo.tip.len(), fo.base.len()), (n + 1, n + 1));
            let (props, scale, hunch, _) = &rigs[fo.rig];
            for (i, &t) in f.t.iter().enumerate() {
                sample(clip, t, f.key_ease, &mut pose);
                pose_fk(&pose, props, 0.0, 0.0, 0.0, 0.0, *scale, *hunch, &mut jm);
                let (tip, base) = (body_weapon_tip(&jm, w), body_weapon_base(&jm, w));
                for k in 0..3 {
                    n_points += 2;
                    check(&|| format!("{name} form {} frame {i} tip[{k}]", fo.form), tip[k], fo.tip[i][k], &mut miss);
                    check(&|| format!("{name} form {} frame {i} base[{k}]", fo.form), base[k], fo.base[i][k], &mut miss);
                }
            }
        }
        if let Some(m) = miss {
            misses.push(m);
        }
    }
    println!("fk_matches_key: {} clip files, {n_mats} matrix floats, {n_points} weapon floats; largest |a-b|/max(1,|b|) = {worst:e} at {worst_at}", files.len());
    assert!(misses.is_empty(), "{} of {} clip files miss the key (first miss each):\n{}", misses.len(), files.len(), misses.join("\n"));
}

/// A two-key clip of one channel: key 0 at 0 s (all 0), key 1 at `t1` (channel 0 = `v`).
fn two_keys(t1: f32, v: f32, snap: bool) -> Clip {
    let mut p1 = vec![0.0; POSE_N];
    p1[0] = v;
    Clip { dur: t1, looping: false, marks: BTreeMap::new(), poses: vec![vec![0.0; POSE_N], p1], snaps: vec![0.0, if snap { 1.0 } else { 0.0 }], times: vec![0.0, t1] }
}

#[test]
fn sample_key_ease_modes() {
    // CLIP-SAMPLE! half way between two keys: smoothstep (*KEY-EASE* 0) 0.5, ease-out cubic (1) 1 - 0.5^3, a :snap key linear
    let c = two_keys(1.0, 2.0, false);
    let mut p: Pose = [0.0; POSE_N];
    sample(&c, 0.5, 0, &mut p);
    assert_eq!(p[0], 1.0);
    sample(&c, 0.5, 1, &mut p);
    assert_eq!(p[0], 1.75);
    sample(&c, 0.25, 1, &mut p);
    assert_eq!(p[0], 2.0 * (1.0 - 0.75f32 * 0.75 * 0.75));
    sample(&two_keys(1.0, 2.0, true), 0.25, 1, &mut p);
    assert_eq!(p[0], 0.5);
    // clamps a one-shot, wraps a loop
    sample(&c, 3.0, 1, &mut p);
    assert_eq!(p[0], 2.0);
    sample(&c, -1.0, 1, &mut p);
    assert_eq!(p[0], 0.0);
    let mut l = two_keys(1.0, 2.0, false);
    l.looping = true;
    sample(&l, 1.5, 0, &mut p);
    assert_eq!(p[0], 1.0);
    sample(&l, -0.5, 0, &mut p);
    assert_eq!(p[0], 1.0);
}

#[test]
fn anim_crossfade_blends() {
    // ANIM-PLAY a held pose (channel 0 = 1), then another (channel 0 = 3) with a 6-frame crossfade (0.1 s): ANIM-EVAL's weight is
    // 0 at the start, smoothstep(0.5) = 0.5 half way (0.05 s), 1 at the end; then the blend stays at +0
    let a = two_keys(1.0, 1.0, false);
    let b = Clip { poses: vec![vec![3.0; POSE_N]], snaps: vec![0.0], times: vec![0.0], ..two_keys(1.0, 3.0, false) };
    let a = Clip { poses: vec![a.poses[1].clone()], snaps: vec![0.0], times: vec![0.0], ..a };
    let mut an = Anim::default();
    an.play(&a, 0.0, 1.0, 0.0, true);
    assert_eq!(an.eval(1)[0], 1.0);
    an.play(&b, 6.0, 1.0, 0.0, true);
    assert_eq!((an.blend, an.blend_dur), (0.1, 0.1));
    assert_eq!(an.eval(1)[0], 1.0, "weight 0");
    an.advance(0.05);
    assert_eq!(an.blend, 0.05);
    assert_eq!(an.eval(1)[0], 2.0, "weight 0.5");
    an.advance(0.05);
    assert_eq!(an.blend, 0.0);
    assert!(!an.blend.is_sign_negative());
    assert_eq!(an.eval(1)[0], 3.0, "weight 1");
    assert_eq!(an.time, 0.1f32);
    an.advance(0.05);
    assert_eq!(an.blend.to_bits(), 0.0f32.to_bits());
    // RESTART NIL on the playing clip: no new fade, the speed still set
    an.play(&b, 6.0, 2.0, 0.0, false);
    assert_eq!((an.blend, an.speed), (0.0, 2.0));
    assert_eq!(an.time, 0.1f32 + 0.05f32);
    // a spun root yaw is wrapped into [-pi, pi) before the fade (F-WRAP)
    an.pose[66] = 7.0;
    an.play(&a, 4.0, 1.0, 0.0, true);
    assert_eq!(an.from[66], duel_look::anim::f_wrap(7.0));
    assert!((an.from[66] - (7.0 - std::f32::consts::TAU)).abs() < 1e-5);
}
