//! M3a Task 10: the game loop's Review Focus 3 and 5 (docs/bevy/M3A_NOTES.md §10).
use duel_app::game::{Game, Start};
use duel_app::input::Keyboard;
use duel_data::Data;
use duel_look::{FrameOut, SceneInputs};
use duel_sim::components::{Character, Difficulty};
use duel_sim::cpu::Search;
use duel_sim::look::NoLook;
use duel_sim::state::Match;
use duel_sim::{cine, flow};

fn data() -> &'static Data {
    static D: std::sync::OnceLock<Data> = std::sync::OnceLock::new();
    D.get_or_init(Data::embedded)
}

fn inputs() -> SceneInputs {
    SceneInputs { width: 640, height: 360, density: 1.0, msaa: 4, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 }
}

/// Both fighters' places and facings, bit for bit.
fn actors(m: &Match) -> [u32; 8] {
    let t = |e| m.transform.get(e).expect("a fighter");
    let (a, b) = (t(m.p1), t(m.p2));
    [a.pos[0], a.pos[1], a.pos[2], a.yaw, b.pos[0], b.pos[1], b.pos[2], b.yaw].map(f32::to_bits)
}

/// Review Focus 3 (DIVERGENCES §1): a played Kikon's DURING forms move the actors once per rendered frame, after the frame's steps, so
/// the game loop must run CINE-DRAW once a frame, at any rate. Kenpachi's Bankai 狂嵐 Kikon (debug 84096: the victim blown away, KE-KK-AT
/// over cine frames 108-130) at dt 1/120 (a step every other frame) and 1/30 (two steps a frame): the page's `Game::frame` (draw_frame's
/// CINE-DRAW through the Scene) moves the actors as a hand loop of flow::frame, one `cine::cine_draw` and frame_end does, on every
/// frame. The forms set places from the cinematic frame (absolute, so a second call in one frame repeats the first; what the rate
/// changes is which cinematic frames get drawn: every one at 1/120, every second at 1/30). The mutation shows the window exercises
/// them: with no CINE-DRAW the victim stays where the steps put him.
#[test]
fn cine_draw_per_rendered_frame() {
    // a hand loop: per frame flow::frame, DRAWS CINE-DRAWs (unless turbo, as DRAW-SCENE), frame_end
    struct Hand {
        m: Match,
        s: Search,
        kb: Keyboard,
        draws: usize,
    }
    impl Hand {
        fn new(draws: usize) -> Hand {
            let mut m = Match::new(data());
            flow::go_title(&mut m);
            m.cmds.push_back(84096);
            Hand { m, s: Search::new(), kb: Keyboard::default(), draws }
        }
        fn frame(&mut self, rdt: f32) {
            assert!(flow::frame(&mut self.m, &mut self.s, &mut self.kb, &mut NoLook, rdt));
            for _ in 0..self.draws {
                if !self.m.turbo {
                    cine::cine_draw(&mut self.m, &mut NoLook);
                }
            }
            flow::frame_end(&mut self.m, &mut self.s);
        }
    }
    for rdt in [1.0f32 / 120.0, 1.0 / 30.0] {
        let mut g = Game::new(data(), inputs());
        let mut out = FrameOut::default();
        g.queue_cmd(84096, 1);
        let (mut one, mut none) = (Hand::new(1), Hand::new(0));
        let (mut in_cine, mut differ_none) = (0, false);
        for f in 1..=(8.0 / rdt) as i64 {
            assert!(g.frame(&mut out, rdt), "{:?}", g.stopped);
            one.frame(rdt);
            none.frame(rdt);
            assert_eq!(actors(&g.m), actors(&one.m), "dt {rdt}: frame {f}: the page's actors against one CINE-DRAW a frame");
            differ_none |= actors(&none.m) != actors(&one.m);
            in_cine += g.m.cine.is_some() as i64;
        }
        assert!(in_cine > 60, "dt {rdt}: the Kikon played ({in_cine} frames)");
        assert!(differ_none, "dt {rdt}: without CINE-DRAW the actors differ (the DURING forms ran in this window)");
    }
}

/// Review Focus 5: a pick the port has not got (Hisagi, M4) stops the fight with its reason, logged once by the page and drawn on it;
/// the frames after it return false at once (the page keeps drawing the stopped frame: no panic, no silent freeze). The page half,
/// `?p2=hisagi` under run.mjs, is tools/port/page-log-check.sh's.
#[test]
fn unported_surfaces_on_page() {
    let mut g = Game::new(data(), inputs());
    let mut out = FrameOut::default();
    (g.start, g.dev) = (Some(Start { p1: Character::Kenpachi, p2: Character::Hisagi, cpu: Difficulty::Normal }), true);
    let mut stop = None;
    for f in 1..=3600 {
        if !g.frame(&mut out, flow::raw_dt(f)) {
            stop = Some(f);
            break;
        }
    }
    let why = g.stopped.unwrap_or_else(|| panic!("Kenpachi vs Hisagi never stopped"));
    println!("stopped at frame {stop:?}: unported {why}");
    let ui = out.ui.clone();
    assert!(!ui.is_empty(), "the reason drawn into the canvas stream");
    for _ in 0..10 {
        assert!(!g.frame(&mut out, 1.0 / 60.0));
    }
    assert_eq!((g.stopped, &out.ui), (Some(why), &ui), "stopped stays, the frame is kept");
}
