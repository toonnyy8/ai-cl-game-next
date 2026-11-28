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

/// The rematch on the real path: a VS CPU match on a 3 s timer runs to TIME-UP's cinematic and GO-RESULTS, the dev line says "K.O. -
/// Enter to rematch", an Enter before 2.5 s of RESULTS does nothing (RESULTS' masher guard), one after plays the same pairing again
/// from its intro with a new seed.
#[test]
fn rematch_after_the_match_ends() {
    use duel_app::input::CONFIRM;
    use duel_sim::components::Flow;
    let mut g = Game::new(data(), inputs());
    let mut out = FrameOut::default();
    std::sync::Arc::make_mut(&mut g.m.knobs).match_seconds = 3;
    (g.start, g.dev, g.now_ms) = (Some(Start::default()), true, 1000.0);
    let mut f = 0;
    while g.m.flow != Flow::Results {
        f += 1;
        assert!(g.frame(&mut out, flow::raw_dt(f)), "{:?}", g.stopped);
        assert!(f < 60 * 60, "never reached RESULTS");
    }
    assert_eq!(g.m.match_seed, 1000);
    let ui = out.ui.len();
    g.kb.set(0, CONFIRM);
    f += 1;
    g.frame(&mut out, flow::raw_dt(f));
    assert_eq!(g.m.flow, Flow::Results, "an Enter at once does nothing");
    assert!(ui > 0 && out.ui.len() >= ui, "the dev line and its K.O. line drawn");
    while g.m.ft <= 2.5 {
        f += 1;
        g.frame(&mut out, flow::raw_dt(f));
    }
    (g.now_ms, f) = (77777.0, f + 1);
    g.kb.set(0, CONFIRM);
    assert!(g.frame(&mut out, flow::raw_dt(f)));
    assert_eq!((g.m.flow, g.m.match_seed, g.m.picks), (Flow::Intro, 77777, [Character::Kenpachi, Character::Ichigo]));
}

/// Ruling R31 (DIVERGENCES §1, M3A_NOTES §11): a human's held keys reach a CPU's full-sim rollouts through the keyboard. Debug 2501
/// (human Kenpachi vs an idle NORMAL Ichigo, seed 1) then 2105 (the CPU's brain on), as page-log-check row 3 sends them, with W held
/// from the start; the frames run until the CPU's jobs have rolled out (`*mc-full-stats*`' rollouts). The keyboard is the page's own
/// `Keyboard` behind a counting wrapper (`Game::frame` hands the same `&mut Keyboard` to `flow::frame`): every P1 read inside a rollout
/// goes through `Keyboard::rollout_read` and leaves W on the stand-in's vpad (the stick straight up). With `rollout_read` emptied (the
/// mutation, checked and reverted) only the first of the 54 reads still shows W (the live vpad's copy) and the test fails.
#[test]
fn rollout_reads_the_held_keys() {
    use duel_app::input::Key;
    use duel_sim::flow::PilotInput;
    struct Counting {
        kb: Keyboard,
        reads: u64,
        held_seen: u64,
    }
    impl PilotInput for Counting {
        fn read(&mut self, m: &mut Match, side: usize) {
            self.kb.read(m, side);
        }
        fn step_end(&mut self, m: &mut Match, s: &mut Search) {
            self.kb.step_end(m, s);
        }
        fn rollout_read(&mut self, m: &mut Match, side: usize) {
            self.kb.rollout_read(m, side);
            if side == 0 {
                self.reads += 1;
                let vp = &m.pilot.get(m.p1).expect("P1's pilot in the rollout").vpad;
                self.held_seen += ((vp.sx, vp.sy) == (0.0, 1.0)) as u64;
            }
        }
    }
    let mut m = Match::new(data());
    let mut s = Search::new();
    flow::go_title(&mut m);
    m.cmds.extend([2501, 2105]);
    let mut kb = Counting { kb: Keyboard::default(), reads: 0, held_seen: 0 };
    kb.kb.set(Key::W.bit(), 0);
    let mut f = 0;
    while s.mc_stats[1] == 0 && f < 8000 {
        f += 1;
        assert!(flow::frame(&mut m, &mut s, &mut kb, &mut NoLook, flow::raw_dt(f)), "stopped: {:?} {:?}", m.unported, s.cut);
        flow::frame_end(&mut m, &mut s);
    }
    println!("first rollout by frame {f} (match tick {}): {} rollouts, {} P1 reads inside them, {} with W on the vpad", m.match_tick, s.mc_stats[1], kb.reads, kb.held_seen);
    assert!(s.mc_stats[1] > 0, "a rollout ran ({f} frames)");
    assert!(m.mode == duel_sim::state::Mode::VsCpu && kb.reads > 0, "the human's device was read inside the rollouts");
    assert_eq!(kb.held_seen, kb.reads, "every P1 read inside a rollout left the held W on the vpad");
}
