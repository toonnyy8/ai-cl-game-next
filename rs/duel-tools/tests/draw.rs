//! The picture against the draw key (docs/bevy/M3A_NOTES.md §5-§7): `duel-tools draw --check` on the quiet, slowmo, forms and
//! portrait scenes, every array but `ui` (the canvas words: Task 8) and `hb` / `hk` (M3b), the cosmetic RNG's state on every keyed
//! frame. Each fails when the key is missing (`$ORACLE`, else `build/oracle`); none skips.
use std::process::Command;

fn oracle() -> String {
    std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into())
}

/// The arrays every scene here compares (R11's `cosrng_draw_order`: `rng`).
const ARRAYS: &str = "fu,p,dq,fxa,fxb,ft,rng";

/// Runs `draw --check` on SCENE; asserts `draw OK` and 0 allocations a frame after frame 0.
fn check(scene: &str) {
    let file = format!("{}/draw/{scene}.bin", oracle());
    assert!(std::path::Path::new(&file).exists(), "{file}: missing (set ORACLE)");
    let o = Command::new(env!("CARGO_BIN_EXE_duel-tools")).args(["draw", "--check", &file, "--arrays", ARRAYS]).output().unwrap();
    let out = String::from_utf8_lossy(&o.stdout);
    println!("{out}");
    assert!(o.status.success() && out.starts_with(&format!("draw OK {scene} ")), "{scene}: {out}{}", String::from_utf8_lossy(&o.stderr));
    assert!(out.contains("; allocs 0 in ") && out.contains("draw_frame allocs 0 in "), "{scene}: allocations in steady state: {out}");
}

const QUIET: [&str; 12] = [
    "quiet-2500", "quiet-2501", "quiet-2502", "quiet-2503", "quiet-2394", "quiet-2395", "quiet-2396", "quiet-2397", "quiet-84000",
    "quiet-84001", "quiet-84004", "quiet-84005",
];

/// The 12 quiet scenes whole (121 keyed frames each): the camera, the stage, the FX and the fighters (bodies, weapons, shadows, the
/// kits' :pose / :draw hooks, KESSA's aura and wisps in 2395, the mirror P2's tint and rim in 2502 / 2503).
#[test]
fn quiet_full_matches() {
    for s in QUIET {
        check(s);
    }
}

/// Review Focus 2: the slow motion's frames (2513 at frame 30: 0.2 for 3 s, easing back) drawn between sim frames (SLOW-DRAW), every
/// frame 0-239: the fighters' clips one sim frame's share back, the camera on the drawn places.
#[test]
fn slowmo_frames_match() {
    check("slowmo-2513");
}

/// The draw-level FK (M0_NOTES §6): every Kenpachi / Ichigo form on screen, three frames each (the hooks, the grip, the beat, the
/// lift): P2 Kenpachi sealed -> Shikai L2 -> KYORAN -> ZANKAI against Ichigo's Shikai (2505, 2508), P1 Kenpachi's Shikai and
/// Bankai forms (84001, 84004, 84005), Ichigo's Shikai and KESSA (2394, 2395).
#[test]
fn forms_draw_matches() {
    for s in ["forms-ken-p2", "forms-ken-p1", "forms-ichigo"] {
        check(s);
    }
}

/// Review Focus 4: the 2501 battle scene at 390x844 (a narrow desktop window): the portrait camera and lens.
#[test]
fn portrait_scene_matches() {
    check("portrait-2501");
}
