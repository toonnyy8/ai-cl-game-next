//! The draw core against the draw key (docs/bevy/M3A_NOTES.md §5): `duel-tools draw --check` on the quiet and slowmo scenes,
//! `fu` / `p` / `dq` with the lanes later tasks fill masked (the point lights: Task 6; the fighters: Task 7). Each fails when the key
//! is missing (`$ORACLE`, else `build/oracle`); none skips.
use std::process::Command;

fn oracle() -> String {
    std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into())
}

/// Runs `draw --check` on SCENE; asserts `draw OK` and 0 allocations a frame after frame 0.
fn check(scene: &str, arrays: &str, mask: &str) {
    let file = format!("{}/draw/{scene}.bin", oracle());
    assert!(std::path::Path::new(&file).exists(), "{file}: missing (set ORACLE)");
    let o = Command::new(env!("CARGO_BIN_EXE_duel-tools")).args(["draw", "--check", &file, "--arrays", arrays, "--mask", mask]).output().unwrap();
    let out = String::from_utf8_lossy(&o.stdout);
    println!("{out}");
    assert!(o.status.success() && out.starts_with(&format!("draw OK {scene} ")), "{scene}: {out}{}", String::from_utf8_lossy(&o.stderr));
    assert!(out.contains("; allocs 0 in ") && out.contains("draw_frame allocs 0 in "), "{scene}: allocations in steady state: {out}");
}

const QUIET: [&str; 12] = [
    "quiet-2500", "quiet-2501", "quiet-2502", "quiet-2503", "quiet-2394", "quiet-2395", "quiet-2396", "quiet-2397", "quiet-84000",
    "quiet-84001", "quiet-84004", "quiet-84005",
];

/// The camera, the environment, the post parameters and the stage's draws on the 12 quiet scenes (121 keyed frames each).
#[test]
fn quiet_core_matches() {
    for s in QUIET {
        check(s, "fu,p,dq", "lights,fighters");
    }
}

/// Review Focus 2: the slow motion's frames (2513 at frame 30: 0.2 for 3 s, easing back) drawn between sim frames (SLOW-DRAW), every
/// frame 0-239: the camera reads the drawn places.
#[test]
fn slowmo_frames_match() {
    check("slowmo-2513", "fu,p,dq", "lights,fighters");
}
