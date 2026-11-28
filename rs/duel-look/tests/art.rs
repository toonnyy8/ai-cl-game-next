//! The looks' host checks M1 left for M3 (rs/duel-sim/tests/PORTED.md): tests/duel-rules/art.lisp's reach against the art for
//! the Kenpachi / Ichigo forms (its Hisagi / Yamamoto checks are M4), and the clip / look reads of triangle.lisp, core.lisp and
//! ken.lisp. Each check names its Lisp line; expected values are the Lisp test's.
use duel_data::{Data, Kit, Move};
use duel_look::anim::{fighter_stance_clip, kit_move_clip, sample, Pose, POSE_N};
use duel_look::rig::{joint_index, joint_point, pose_fk, Mat4, Proportions, NJ, WEAPON_R};
use duel_sim::kit::{core_routes, core_segment_sas, core_segments, find_kit, find_move, kit_command_move, kit_move, kit_next};
use duel_sim::knobs::Knobs;

/// tests/duel-rules/core.lisp *FORMS* (line 10).
const FORMS: [(&str, &str); 9] = [
    ("kenpachi", "base"),
    ("kenpachi", "nozarashi"),
    ("kenpachi", "bankai"),
    ("kenpachi", "bankai-2"),
    ("ichigo", "base"),
    ("ichigo", "kessa"),
    ("hisagi", "base"),
    ("hisagi", "bankai"),
    ("hisagi", "bankai-bind"),
];

/// art.lisp *STRIKERS* (line 25), the Kenpachi / Ichigo rows: clip -> the joint that strikes and a point down its -Y.
const STRIKERS: [(&str, &str, f32); 6] = [
    ("ke-kick", "foot-r", 0.0),
    ("ic-q1", "weapon-l", -0.90),
    ("ic-na1", "weapon-l", -0.90),
    ("ic-q2", "weapon-l", -0.90),
    ("ic-cross-j", "weapon-l", -0.90),
    ("ke-shoulder", "shoulder-l", 0.0),
];

/// art.lisp *REACH-ONE-SIDED* (line 33).
const REACH_ONE_SIDED: [(&str, &str); 4] = [("kenpachi", "base"), ("kenpachi", "nozarashi"), ("kenpachi", "bankai"), ("kenpachi", "bankai-2")];

fn kit<'d>(d: &'d Data, c: &str, f: &str) -> &'d Kit {
    find_kit(d, c, f)
}

/// port: tests/duel-rules/core.lisp LINK-MOVES — every string link reachable from J1 / K1: (move, link number), in the walk's order.
fn link_moves<'d>(d: &'d Data, k: &Kit) -> Vec<(&'d Move, usize)> {
    fn walk<'d>(d: &'d Data, k: &Kit, m: &'d Move, n: usize, out: &mut Vec<(&'d Move, usize)>) {
        out.push((m, n));
        for c in ["q", "f"] {
            if let Some(nx) = kit_next(d, k, &m.name, c) {
                walk(d, k, nx, n + 1, out);
            }
        }
    }
    let mut out = Vec::new();
    walk(d, k, kit_command_move(d, k, "q").expect("J1"), 1, &mut out);
    if let Some(k1) = kit_command_move(d, k, "f") {
        walk(d, k, k1, 1, &mut out);
    }
    out
}

/// port: tests/duel-rules/core.lisp TRACE-FORM-P — J1 has no hit window.
fn trace_form_p(d: &Data, k: &Kit) -> bool {
    kit_command_move(d, k, "q").expect("J1").hits.is_empty()
}

/// art.lisp lines 59, 99, 100 for the Kenpachi / Ichigo forms (key ease 0: the host load keeps the engine default), and line 413.
#[test]
fn art_lisp_reach_matches_the_art() {
    let d = Data::embedded();
    let kn = Knobs::from(&d).unwrap();
    let hurt = d.bodies.iter().filter(|(n, _)| n.as_str() != "skeleton").map(|(_, b)| b.hurt_r);
    let min_hurt = hurt.fold(f32::INFINITY, f32::min);
    let max_hurt = d.bodies.values().map(|b| b.hurt_r).fold(f32::NEG_INFINITY, f32::max);
    // line 59: the lunge stops outside two hurt cylinders' push-apart
    assert!(kn.lunge_stop > 2.0 * max_hurt);
    let (mut pose, mut jm): (Pose, [Mat4; NJ]) = ([0.0; POSE_N], [[0.0; 16]; NJ]);
    let mut rows = 0;
    let mut bad = Vec::new();
    for (c, f) in FORMS.iter().filter(|(c, _)| *c != "hisagi") {
        let k = kit(&d, c, f);
        assert!(!trace_form_p(&d, k));
        let body = &d.bodies[&k.body];
        let props = Proportions::of(&d.rig, body);
        let wlen = d.weapons[&k.weapon].len;
        let mut lms: Vec<(&Move, bool)> = link_moves(&d, k)
            .into_iter()
            .filter(|(m, _)| !(m.hits.is_empty() || m.hits[0].seg.is_some()))
            .map(|(m, _)| (m, false))
            .collect();
        if let Some(br) = kit_command_move(&d, k, "breaker") {
            lms.push((br, true));
        }
        for (mv, breaker) in lms {
            let hw = &mv.hits[0];
            let vol = hw.vols[0];
            let cap = vol[0] > 0.5;
            let edge = if cap { vol[2] + vol[4] } else { vol[1] };
            let mclip = if breaker { mv.clip2.as_deref().expect("the Breaker's clip 2") } else { mv.clip.as_str() };
            let clip_name = kit_move_clip(k, mclip);
            let clip = &d.clips[clip_name];
            let st = STRIKERS.iter().find(|s| s.0 == clip_name);
            assert!(hw.from < hw.to, "{f} {}: an empty window", mv.name);
            let art = (hw.from..hw.to)
                .map(|sf| {
                    sample(clip, (sf as f32 * mv.clip_speed) / 60.0, 0, &mut pose);
                    pose_fk(&pose, &props, 0.0, 0.0, 0.0, 0.0, body.scale, body.hunch, &mut jm);
                    let v = match st {
                        Some((_, j, y)) => joint_point(&jm[joint_index(&d.rig, j)], [0.0, *y, 0.0]),
                        None => joint_point(&jm[WEAPON_R], [0.0, 0.0, 0.0 - wlen]),
                    };
                    if cap { -v[2] } else { (v[0] * v[0] + v[2] * v[2]).sqrt() }
                })
                .fold(f32::NEG_INFINITY, f32::max);
            let dd = art - edge;
            println!("{c} {f} {} {clip_name} art {art:.4} edge {edge:.4} d {dd:+.4}", mv.name);
            rows += 1;
            // line 99: a J follow-up's chase goal is inside its reach + the thinnest hurt radius
            if mv.kind == "quick" {
                assert!(kn.lunge_stop.max(mv.reach - kn.chase_margin) <= (mv.reach + min_hurt) - 0.02, "{f} {}", mv.name);
            }
            // line 100: within 0.15 m both ways, or short (never over) for the one-sided forms, the K (flash) and the Breaker
            let ok = dd <= 0.15 && (dd >= -0.15 || REACH_ONE_SIDED.contains(&(c, f)) || mv.kind == "flash" || mv.kind == "breaker");
            if !ok {
                bad.push(format!("{f} {}: the volume ends {edge:.2} m, the art {art:.2} m", mv.name));
            }
        }
    }
    println!("art_lisp_reach_matches_the_art: {rows} links");
    assert!(bad.is_empty(), "{}", bad.join("\n"));
}

/// art.lisp line 413: J short, K long — every K link reaches at least 0.5 m further than any J link at the same position (reach
/// + slide); the Kenpachi / Ichigo forms (Kenpachi's are all exempt, so Ichigo's two; Hisagi's base form is M4).
#[test]
fn art_lisp_j_short_k_long() {
    let d = Data::embedded();
    let mut checked = 0;
    for (c, f) in FORMS.iter().filter(|(c, f)| *c != "hisagi" && !(*c == "kenpachi" && (*f == "base" || *f == "nozarashi"))) {
        let k = kit(&d, c, f);
        if trace_form_p(&d, k) {
            continue;
        }
        let lm = link_moves(&d, k);
        for n in 1..=3 {
            let at = |kind: &'static str| lm.iter().filter(move |(m, l)| *l == n && m.kind == kind).map(|(m, _)| m.reach + m.slide);
            if *c == "kenpachi" && (*f == "bankai" || *f == "bankai-2") {
                continue; // (no K: the Lisp computes, never checks)
            }
            let j = at("quick").reduce(f32::max).unwrap_or_else(|| panic!("{f} link {n}: no J (the Lisp's MAXIMIZE would be NIL)"));
            let kk = at("flash").reduce(f32::min).unwrap_or_else(|| panic!("{f} link {n}: no K"));
            assert!(kk - j >= 0.5, "({c} {f}) link {n}: J {j:.2} K {kk:.2}");
            checked += 1;
        }
    }
    assert_eq!(checked, 6);
}

/// triangle.lisp lines 120, 121, 122, 124: FIGHTER-STANCE-CLIP by SP pointer; with no :stances, the kit's :stance.
#[test]
fn triangle_lisp_stance_clips() {
    let d = Data::embedded();
    let k = kit(&d, "ichigo", "base");
    assert_eq!(fighter_stance_clip(k, 1), "ic-st-heavy");
    assert_eq!(fighter_stance_clip(k, 2), "ic-tsuki");
    assert_eq!(fighter_stance_clip(k, 3), "ic-st-rush");
    let mut bare = k.clone();
    bare.core.stances.clear();
    assert_eq!(fighter_stance_clip(&bare, 3), k.stance);
}

/// port: duel/lisp/kit.lisp CORE-MOVE-NAMES — :also, every route's segments (+ a wave's :kikon-strike), the segment SAs, the SA.
fn core_move_names(d: &Data, core: &duel_data::Core) -> Vec<String> {
    let mut v: Vec<String> = core.also.clone().unwrap_or_default();
    for n in core_routes(core) {
        for m in core_segments(d, &n) {
            let ks = find_move(d, &m).and_then(|x| x.params.kikon_strike.clone());
            v.push(m);
            v.extend(ks);
        }
    }
    v.extend(core_segment_sas(d, core));
    v.push(core.sa.clone());
    v
}

/// triangle.lisp lines 155, 156 (DEFCLIP-MIRROR: key 3's right / left channels swapped, the chest's twist and the root's yaw
/// negated) and 167 (KESSA's core moves play no Shikai clip).
#[test]
fn triangle_lisp_mirror_and_kessa_clips() {
    let d = Data::embedded();
    let (a, b) = (&d.clips["ic-k-xa"], &d.clips["ic-k-xb"]);
    // line 155
    assert!(a.times.len() == b.times.len() && a.dur == b.dur);
    // line 156 (key 3: (* 3 +pose-n+))
    let (pa, pb) = (&a.poses[3], &b.poses[3]);
    assert!(pb[3 * 6] == pa[3 * 11] && pb[3 * 11 + 2] == pa[3 * 6 + 2] && pb[3 * 2 + 1] == -pa[3 * 2 + 1] && pb[63 + 3] == -pa[63 + 3]);
    // line 167
    let k = kit(&d, "ichigo", "kessa");
    let names = core_move_names(&d, &k.core);
    assert!(!names.is_empty());
    for n in &names {
        let c = &kit_move(&d, k, n).unwrap_or_else(|| panic!("kessa: no move {n}")).clip;
        assert!(c.is_empty() || c.contains("ic-k-") || c == "ic-tsuki", "kessa {n} plays {c}");
    }
}

/// port: duel/lisp/kit.lisp KIT-CLIPS — every clip the form uses: stance, intro / win, entry, run, :look-clips', its moves' (both
/// clips) through :clip-map.
fn kit_clips(d: &Data, k: &Kit) -> Vec<String> {
    let mut v: Vec<String> = vec![k.stance.clone(), k.intro.clone(), k.win.clone()];
    v.extend(k.enter_clips.iter().cloned());
    v.extend(k.run_clips.iter().cloned());
    v.extend(k.look_clips.values().cloned());
    for id in &k.moves {
        let mv = d.moves.iter().find(|m| &m.id == id).unwrap_or_else(|| panic!("no move {id}"));
        v.push(kit_move_clip(k, &mv.clip).to_string());
        v.extend(mv.clip2.as_deref().map(|c| kit_move_clip(k, c).to_string()));
    }
    v.retain(|c| !c.is_empty());
    v
}

/// core.lisp *CLIPS-5* (line 670), read off the frozen test file itself (its keywords, comments stripped).
fn clips_5() -> std::collections::BTreeSet<String> {
    let src = include_str!("../../../tests/duel-rules/core.lisp");
    let start = src.find("(defparameter *clips-5*").expect("core.lisp *CLIPS-5*");
    let mut out = std::collections::BTreeSet::new();
    for line in src[start..].lines().skip(1) {
        let code = line.split(';').next().unwrap();
        out.extend(code.split_whitespace().filter_map(|w| w.strip_prefix(':')).map(|w| w.trim_end_matches(')').to_string()));
        if code.contains("))") {
            break;
        }
    }
    out
}

/// core.lisp lines 185, 186 (MV-CLIP-SPEED), 738 (the clip names are exactly *CLIPS-5*), 740 (KIT-WEAPON), 746 (KIT-BLADE),
/// 747 (MV-BLEND).
#[test]
fn core_lisp_clip_reads() {
    let d = Data::embedded();
    let near = |a: f32, b: f32| (a - b).abs() < 1e-3; // core.lisp ~=
    let mv = |c, f, n| kit_move(&d, kit(&d, c, f), n).unwrap_or_else(|| panic!("no move {n}"));
    // lines 185, 186
    assert!(near(mv("kenpachi", "nozarashi", "ke-s-j1").clip_speed, 1.0));
    assert!(near(mv("kenpachi", "base", "ke-j1").clip_speed, 1.0));
    // line 738
    let mut used: std::collections::BTreeSet<String> = FORMS.iter().flat_map(|(c, f)| kit_clips(&d, kit(&d, c, f))).collect();
    let hb = kit(&d, "hisagi", "base");
    for m in [
        "ic-c-xa", "ic-c-xb", "hs-modoshi", "hs-k2s", "hs-r-kubikake", "hs-b-unwind", "hs-r-sp2c", "hs-b-sp1", "hs-r-l", "hs-r-sp1",
        "hs-b-l", "hs-r-k1", "hs-b-k1", "hs-r-k2s", "hs-r-k3",
    ] {
        let x = find_move(&d, m).unwrap_or_else(|| panic!("no move {m}"));
        used.extend(x.clip2.clone());
        used.insert(kit_move_clip(hb, &x.clip).to_string());
    }
    let c5 = clips_5();
    assert!(c5.len() > 100, "{} clips read off *CLIPS-5*", c5.len());
    let extra: Vec<_> = used.difference(&c5).collect();
    let unused: Vec<_> = c5.difference(&used).collect();
    assert!(extra.is_empty() && unused.is_empty(), "clips not in §5: {extra:?}, §5 clips unused: {unused:?}");
    // line 740
    let weapons: Vec<&str> = FORMS.iter().map(|(c, f)| kit(&d, c, f).weapon.as_str()).collect();
    assert_eq!(weapons, ["ken-katana", "nozarashi", "ke-broken", "ke-broken", "zangetsu-long", "tensa", "kazeshini", "kazeshini", "kazeshini"]);
    // line 746
    assert!(kit(&d, "kenpachi", "base").blade.is_none());
    // line 747
    assert!(near(find_move(&d, "ke-stance").expect("ke-stance").blend, 6.0));
}

/// ken.lisp line 52: J1 played at 6/9 (authored strike 6, hit frame 9), AS1 at 0.75, J2 at its own 1.
#[test]
fn ken_lisp_clip_speeds() {
    let d = Data::embedded();
    let k = kit(&d, "kenpachi", "base");
    let m = |n| kit_move(&d, k, n).unwrap_or_else(|| panic!("no move {n}"));
    assert!((m("ke-z-j1").clip_speed - 6.0f32 / 9.0).abs() < 1e-6 && (m("ke-z-as1").clip_speed - 0.75).abs() < 1e-6 && m("ke-z-j2").clip_speed == 1.0);
}
