//! The picture against the draw key (docs/bevy/M3A_NOTES.md §5-§8): `duel-tools draw --check` on the quiet, slowmo, forms, portrait
//! cinematic and battle scenes, every array but `hb` / `hk` (M3b), the cosmetic RNG's state on every keyed frame. Each fails when the key is
//! missing (`$ORACLE`, else `build/oracle`); none skips.
use std::process::Command;

fn oracle() -> String {
    std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into())
}

/// The arrays every scene here compares (R11's `cosrng_draw_order`: `rng`; `ui`, the canvas words, since Task 8).
const ARRAYS: &str = "fu,p,dq,fxa,fxb,ui,ft,rng";

/// Runs `draw --check` on SCENE (bit for bit but one scene: below); asserts `draw OK` and 0 allocations a frame after frame 0.
fn check(scene: &str) {
    let file = format!("{}/draw/{scene}.bin", oracle());
    assert!(std::path::Path::new(&file).exists(), "{file}: missing (set ORACLE)");
    // bit for bit (`--exact`) but cine-ic-kessa-getsuga: its black C (VFX-IC-C-CUT) goes through the native image's 80-bit long-float
    // `pi` (sinl / powl), computed here in doubles: within 2.05e-7 of the key (fxa, frame 110 on), held by the 1e-5 tolerance (BEVY_PORT
    // §5.3; M3A_NOTES §8)
    let exact = if scene == "cine-ic-kessa-getsuga" { None } else { Some("--exact") };
    let o = Command::new(env!("CARGO_BIN_EXE_duel-tools")).args(["draw", "--check", &file, "--arrays", ARRAYS]).args(exact).output().unwrap();
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

/// Review Focus 4: the 2501 and 2005 battle scenes at 390x844 (a narrow desktop window): the portrait camera and lens, the intro's
/// portrait dolly, the words' portrait lanes.
#[test]
fn portrait_scene_matches() {
    check("portrait-2501");
    check("portrait-2005");
}

/// The cinematics, held at their last frames by CINE-AT / ICHIGO-CINE-AT or played through by KEN-CORE-DEBUG (draw-scenes.json): the
/// shots and the cinematic camera, the cards, lenses and dutch rolls, clips, holds, freezes, impact frames and grades, the scripts'
/// VFX, the forms that move the actors (inline, ruling R9).
const CINES: [&str; 20] = [
    "cine-ken-nozarashi", "cine-soul-break", "cine-intro", "cine-ko", "cine-ken-bankai", "cine-84094", "cine-84095", "cine-84096",
    "cine-84097", "cine-84006", "cine-84007", "cine-84008", "cine-ic-kikon", "cine-ic-kessa-kikon", "cine-ic-kessa",
    "cine-ic-kessa-getsuga", "cine-ic-heavy-kikon", "cine-ic-rush-kikon", "cine-ic-chain-kikon", "cine-ic-haste-kikon",
];

/// Every cinematic scene.
#[test]
fn cines_match() {
    for s in CINES {
        check(s);
    }
}

/// Review Focus 4: a cinematic at 390x844 (84094, the Shikai's pointer-1 Kikon): %PORTRAIT-DOLLY, the close-up rule, %KEEP-SUBJECT.
#[test]
fn cine_portrait_matches() {
    check("cine-84094-portrait");
}

/// The two full battles (debug 2005 / 2006, seeded CPU vs CPU drawn from the roster: Ichigo vs Kenpachi, Ichigo vs Ichigo): the intro,
/// every 10th frame of the first 60 s, the looks windows, the hitstop window (2005 frames 422-434, every frame: ruling R2), the slow
/// motions drawn between sim frames (SLOW-DRAW's places feed the camera: M3A_NOTES §8), the mid-match Kikons and the awakening, the
/// feedback, stamps, line cuts, hazard looks, words and world overlays: every look at once.
#[test]
fn battles_match() {
    check("battle-2005");
    check("battle-2006");
}

/// The page clock (M3A_NOTES §9, Task 9 fix round 2): the looks gate's cine-ken, cine-ko and cvc-ik scripts as the page runs them (their
/// title frames, the commands' frames), the native image fed the frozen page's whole-ms dt (stubs-draw.c DRAW_DT=page) and the port
/// `flow::PageClock`: ken-nozarashi through its hold, the K.O. stills, a turbo window's impact frame. Every array but hb / hk, bit for bit.
#[test]
fn page_dt_scenes_match() {
    for s in ["page-nozarashi", "page-ko", "page-turbo-ik"] {
        check(s);
    }
}
