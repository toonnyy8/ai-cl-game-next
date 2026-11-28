//! Concern 1 of Task 9 (M3A_NOTES §9): the page's frames match the frozen page's under run.mjs `--fixed-dt 16.666667`. The looks
//! gate's cvc-ik script (tests/style-gates.py: debug 2005 at virtual 4.0 s, then turbo windows of debug 2102) replayed through the
//! driver with the page clock (`Game::rdt_of`, vt += 16.666667 ms a frame, one frame a browser frame after `?stills`' title catch-up). The frozen
//! page, shot at frames 452 / 453 / 454 (w2-0's window right after a turbo window), shows the negative impact frame at 452 only; with
//! the stub's `raw_dt` the port drew it at 453 / 454 (the fx clock one frame off, so the Burst ring's beat fired a frame late).
use duel_app::game::Game;
use duel_data::Data;
use duel_look::{FrameOut, SceneInputs};

#[test]
fn impact_after_turbo_on_the_frozen_pages_frame() {
    let data: &'static Data = Box::leak(Box::new(Data::embedded()));
    let inputs = SceneInputs { width: 640, height: 360, density: 1.0, msaa: 4, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
    let mut g = Game::new(data, inputs);
    g.title_catch_up = true; // (the looks gate's script: the page's ?stills)
    let mut out = FrameOut::default();
    // cvc-ik's commands (virtual s) -> run.mjs holds the clock at the last frame not past them; the next frame applies them
    let cmds = [(4.0, 2005), (6.4, 2102), (6.437, 2102), (6.587, 2102), (6.725, 2102), (7.175, 2102), (7.445, 2102)];
    let dt = 16.666667f64;
    let (mut vt, mut grade) = (0.0f64, Vec::new());
    for frame in 1..=454i64 {
        vt += dt;
        // (the renderer is ready after ~15 browser frames: frame 15's update runs the 15 title frames since the clock started)
        if frame < 15 {
            continue;
        }
        for &(t, c) in &cmds {
            if ((t * 1000.0 + 1e-6) / dt).floor() as i64 == frame - 1 {
                g.queue_cmd(c);
            }
        }
        let n = g.refresh(frame as u64);
        for i in 1..=n {
            let rdt = g.rdt_of(vt, i, n);
            assert!(g.frame(&mut out, rdt), "{:?}", g.stopped);
        }
        grade.push((frame, out.p[11]));
    }
    let at = |f: i64| grade.iter().find(|x| x.0 == f).map(|x| x.1).unwrap();
    assert_eq!((at(452), at(453), at(454)), (1.0, 0.0, 0.0), "the negative impact frame after the turbo window (frozen page: 452 only)");
}
