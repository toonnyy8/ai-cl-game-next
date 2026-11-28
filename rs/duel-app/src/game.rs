//! The game loop (M3a Task 10; ruling R17's driver grown into it): one frame = the screens' keys, then the loop's three calls,
//! `flow::frame` → `duel_look::draw_frame` → `flow::frame_end`, in rs/duel-tools/src/draw.rs's order, with the Scene as the look sink and
//! the keyboard as the pilots' device (`input::Keyboard`). Debug commands from `Module._debug_cmd(n)` go to the Match's command queue,
//! applied at the start of the frame they are due in. The page boots to the title; `start` plays a VS CPU match as the menus' START
//! does (flow.lisp SELECT-UPDATE: NEW-SEED, then START-MATCH), and after a K.O. Enter plays it again (RESULTS' REMATCH row).
//!
//! dt (ruling R17 amended for the page, concern 1 of Task 9): the frozen page's RUN-FRAME dt, `duel_sim::flow::PageClock` (whole-ms
//! Date.now through SDL's gettimeofday fallback on emscripten: 16 / 17 ms frames, a frame now and then with no step or two). The key's
//! `raw_dt` (the headless stub's 16666666 / 16666667 ns) puts the steps, the fx clock and the looks' timers on other frames than the
//! frozen page's (M3A_NOTES §9 "Concern 1"). `duel-tools draw` replays a page-dt scene with the same clock.
//!
//! Pacing (ruling R32, the frozen page's own loop): one game frame per browser frame. index.html's requestAnimationFrame loop bumps a
//! counter (`page::raf_frames`); an update runs a frame only when the counter moved since the last frame, so the extra Bevy updates of
//! one refresh (run.mjs's re-queued callbacks, an input event's) run nothing, and on a 120 Hz or 144 Hz screen every refresh is a
//! frame, as emscripten's main loop makes it one RUN-FRAME. The frame's dt is the page clock's (`PageClock`) at the update; the first
//! frame after the renderer is ready has dt 0 (no backlog of the load is played); a stall is one frame with a big dt, which RUN-FRAME's
//! 0.1 s clamp and RUN-FIXED-STEPS's 6-step cap bound. No `FixedUpdate`.
use crate::input::{Keyboard, CONFIRM, PAUSE};
use duel_data::Data;
use duel_look::canvas::{ui_scale, ui_verts};
use duel_look::{draw_frame, FrameOut, Scene, SceneInputs};
use duel_sim::components::{Character, Difficulty, Flow};
use duel_sim::cpu::Search;
use duel_sim::flow;
use duel_sim::state::Match;
use std::fmt::Write;

/// `?stills`' first-update bound (15 s of title frames).
pub const TITLE_CATCH_UP: u64 = 900;

/// A VS CPU match as the menus pick it (MODE's VS CPU row, SELECT's two picks and difficulty).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Start {
    pub p1: Character,
    pub p2: Character,
    pub cpu: Difficulty,
}

impl Default for Start {
    /// The page's default: human Kenpachi vs a NORMAL Ichigo.
    fn default() -> Start {
        Start { p1: Character::Kenpachi, p2: Character::Ichigo, cpu: Difficulty::Normal }
    }
}

pub struct Game {
    pub m: Match,
    pub s: Search,
    pub sc: Scene<'static>,
    /// The pilots' device and the screens' keys.
    pub kb: Keyboard,
    /// Frames run.
    pub frames: i64,
    /// The browser-frame counter at the last frame run (`refresh`); none before the first.
    raf: Option<u64>,
    /// `?stills`: the first update runs the title frames since the page's clock started (`refresh`).
    pub title_catch_up: bool,
    /// Debug commands that arrived since the last frame (reserved; a run.mjs script sends a few).
    pending: Vec<i64>,
    /// A match to start at the next frame (the page's start parameters).
    pub start: Option<Start>,
    /// The page clock (ms) NEW-SEED reads (`floor(now) mod 100000`), set by the page each update.
    pub now_ms: f64,
    /// Why the fight stopped (an unported path), logged once and drawn on the page.
    pub stopped: Option<&'static str>,
    /// The non-fatal unported camera seen (the menus', M3b).
    pub menu_camera: Option<&'static str>,
    /// Keep the combat log as the commands set it (`m.log` filled, as the frozen page prints it), and HASH-LOG's lines: the page's
    /// `?log` (a diagnostic: the lines allocate).
    pub log: bool,
    /// The dev text line (off under the page's `?stills`). // dev: M3b replaces
    pub dev: bool,
    /// The dev line's text, reserved once (formatted in place every frame). // dev: M3b replaces
    text: String,
    /// The frozen page's clock (its RUN-FRAME dt).
    clock: flow::PageClock,
}

impl Game {
    /// The page at the title (START-GAME's GO-TITLE), no match queued.
    pub fn new(data: &'static Data, inputs: SceneInputs) -> Game {
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        Game {
            m,
            s: Search::new(),
            sc: Scene::new(data, inputs),
            kb: Keyboard::default(),
            frames: 0,
            raf: None,
            title_catch_up: false,
            pending: Vec::with_capacity(64),
            start: None,
            now_ms: 0.0,
            stopped: None,
            menu_camera: None,
            log: false,
            dev: false,
            text: String::with_capacity(256),
            clock: flow::PageClock::default(),
        }
    }

    /// A debug command: it applies at the start of the next frame run, as main.c's queue hands it to the next RUN-FRAME.
    pub fn queue_cmd(&mut self, c: i64) {
        self.pending.push(c);
    }

    /// This update's keys (`input::Key` bits held now and gone down since the last update). While no frame can run (the renderer not
    /// ready, the fight stopped) the presses are dropped: KEY-PRESSED sees only the presses of the frame it runs in, so an Enter during
    /// the load must not skip the intro on the first frame (the held keys are still taken).
    pub fn keys(&mut self, held: u32, pressed: u32, ready: bool) {
        if ready && self.stopped.is_none() {
            self.kb.set(held, pressed);
        } else {
            self.kb.set(held, 0);
            self.kb.take_pressed();
        }
    }

    /// port: flow.lisp NEW-SEED — a fresh match seed from the clock (`(mod (floor (now-ms)) 100000)`).
    fn new_seed(&self) -> i64 {
        (self.now_ms.max(0.0).floor() as i64) % 100000
    }

    /// One frame: the commands due and the page's start, the screens' keys, then the loop's three calls (and the dev line after the
    /// draw). False once the fight stopped (`stopped` names the path; the reason is drawn into OUT once, and OUT is kept).
    pub fn frame(&mut self, out: &mut FrameOut, rdt: f32) -> bool {
        if self.stopped.is_some() {
            return false;
        }
        self.frames += 1;
        if let Some(st) = self.start.take() {
            // port: SELECT-UPDATE's START (MODE set *mode* :vs-cpu; SELECT the picks and *difficulty*): NEW-SEED, START-MATCH
            let seed = self.new_seed();
            duel_sim::debug::vs_start(&mut self.m, &mut self.s, st.p1, st.p2, st.cpu, seed);
        }
        self.m.cmds.extend(self.pending.drain(..));
        self.screens();
        flow::frame(&mut self.m, &mut self.s, &mut self.kb, &mut self.sc, rdt);
        draw_frame(&mut self.sc, &mut self.m, rdt, out);
        if self.dev {
            self.dev_line(out);
        }
        flow::frame_end(&mut self.m, &mut self.s);
        if !self.log {
            self.m.log_on = false; // (a command turns the combat log on; its lines allocate: the page keeps it off unless asked)
            self.m.log.clear(); // (and drops the command frame's lines: never read here, and a CPU snapshot would clone them each step)
        }
        // the menus' camera (the title before a debug command starts a fight) is M3b's: not a stop, the frame keeps the camera it has
        // (as duel-tools replay reads and clears it after every frame)
        if let Some(u) = self.sc.unported_camera.take() {
            self.menu_camera.get_or_insert(u);
        }
        self.stopped = self.m.unported.or(self.s.cut.map(|_| "a cut CPU rollout")).or(self.sc.unported);
        if let Some(why) = self.stopped {
            stop_text(out, &mut self.text, why, &self.sc.inputs);
        }
        self.stopped.is_none()
    }

    /// port: flow.lisp FLOW-SCREENS' battle parts that read keys, on this frame's presses (the first frame of an update: the frames
    /// after it in the same update see none): BATTLE's PAUSE-P toggles `*paused*` (the pause screen's rows are M3b's); INTRO /
    /// FINISH's PAUSE-P or CONFIRM-P skips the running cinematic (SKIP-CINE); RESULTS' REMATCH row (CONFIRM-P after 2.5 s: NEW-SEED,
    /// START-MATCH) where the frozen page shows RESULTS. Run before `flow::frame`, so before the debug commands, SCREEN-FX-UPDATE and
    /// FLOW-UPDATE's `(incf *ft* rdt)`, where the Lisp runs FLOW-SCREENS after all three. The page is therefore one frame off on a
    /// human press (presentation only, ruling R30; M3A_NOTES §10): a pause stops the screen effects' timers and `ft` a frame earlier,
    /// and a resume restarts them a frame earlier; RESULTS' 2.5 s guard reads last frame's `ft`, so it opens a frame late; after a
    /// rematch or an intro skip `ft` holds this frame's rdt where the Lisp's is 0; a press on a debug command's frame acts on the flow
    /// before the command. Carried to M3b: a hook that runs these keys after `flow_update` (R30).
    fn screens(&mut self) {
        let p = self.kb.take_pressed();
        if p == 0 {
            return;
        }
        let (seed, m) = (self.new_seed(), &mut self.m);
        match m.flow {
            Flow::Battle if p & PAUSE != 0 => m.paused = !m.paused,
            Flow::Intro | Flow::Finish if m.cine.is_some() && p & (PAUSE | CONFIRM) != 0 => duel_sim::cine::skip_cine(m),
            Flow::Results if m.ft > 2.5 && p & CONFIRM != 0 => {
                m.match_seed = seed;
                flow::start_match(m, &mut self.s);
            }
            _ => {}
        }
    }

    /// The dev text line in place of the HUD: both fighters' gauges and the clock, "PAUSED", and "K.O. - Enter to rematch" at
    /// RESULTS. Formatted into the reserved `text` (no allocation), drawn as ui.lisp UI-TEXT into the canvas stream. // dev: M3b replaces
    fn dev_line(&mut self, out: &mut FrameOut) {
        let m = &self.m;
        if !flow::battle_p(m) && m.flow != Flow::Results {
            return;
        }
        let i = &self.sc.inputs;
        let s = ui_scale(i.width, i.height, i.density) as u32;
        let t = &mut self.text;
        t.clear();
        for (k, e) in [m.p1, m.p2].into_iter().enumerate() {
            let (Some(f), Some(g)) = (m.fighter.get(e), m.gauges.get(e)) else { continue };
            let name = f.character.map_or("?", |c| c.name());
            let _ = write!(t, "P{} {} {} R{} K{} FS{:.0} M{:.0}   ", k + 1, name, f.form, g.reishi, g.konpaku, g.fs, g.meter);
        }
        let _ = write!(t, "T{}", m.timer.max(0) / 60);
        let white = [1.0, 1.0, 1.0, 1.0];
        ui_text(&mut out.ui, t, 8.0, 8.0, s, white, true);
        let big = match m.flow {
            Flow::Results => "K.O. - Enter to rematch",
            _ if m.paused => "PAUSED",
            _ => return,
        };
        let (w, h) = (i.width as f32, i.height as f32);
        let bs = 2 * s;
        ui_text(&mut out.ui, big, ((w - text_w(big, bs)) * 0.5).floor(), (h * 0.4).floor(), bs, white, true);
    }

    /// The frames this update runs, the browser-frame counter reading RAF: 1 on the first call (the renderer just became ready: no
    /// backlog of the load) and whenever the counter moved since the last frame, else 0. Several browser frames since the last update
    /// are one frame, with the whole gap as its dt: the frozen page would have run each, but a refresh with no Bevy update is a stall
    /// here (R32), and a frame per missed refresh would play time the player never saw. ponytail: never seen under run.mjs or a live
    /// page, where every refresh runs one Bevy update (winit's redraw request); M3A_NOTES §11.
    ///
    /// Under `?stills` (`title_catch_up`) the first call runs a title frame for every browser frame counted so far (at most
    /// `TITLE_CATCH_UP`). The frozen page's whole startup runs inside one browser frame under run.mjs (its virtual clock stands still
    /// within a frame, so main.c's STARTUP_FRAME_MS budget never runs out) and its title starts with the clock; Bevy's renderer is ready
    /// some 15 browser frames after its clock starts. The title frames carry the fx clock into the fight a debug command starts (the
    /// looks' beats: tests/page_clock.rs), so the stills scripts replay the frames the frozen page ran. Players never get it: the default
    /// page boots into the intro.
    pub fn refresh(&mut self, raf: u64) -> i64 {
        let n = match self.raf {
            None if self.title_catch_up => raf.clamp(1, TITLE_CATCH_UP) as i64,
            None => 1,
            Some(r) => (r != raf) as i64,
        };
        self.raf = Some(raf);
        n
    }

    /// Frame I (1..=N) of this update's N frames: its dt, the page clock reading NOW_MS: the frozen page's RUN-FRAME dt
    /// (`duel_sim::flow::PageClock`: whole-ms Date.now through SDL's gettimeofday fallback, the first frame 0, clamped to 0.1 s; N > 1
    /// only for `?stills`' first update, its frames spread evenly from the page's start; M3A_NOTES §9).
    pub fn rdt_of(&mut self, now_ms: f64, i: i64, n: i64) -> f32 {
        self.clock.rdt(now_ms, i, n)
    }
}

/// ui.lisp TEXT-WIDTH of one line at glyph scale S.
fn text_w(s: &str, sc: u32) -> f32 {
    (s.len() as u32 * 6 * sc).saturating_sub(sc) as f32
}

/// The stop's reason on the page, centred, drawn once on the frame that stopped (OUT keeps it while the page draws on).
fn stop_text(out: &mut FrameOut, t: &mut String, why: &str, i: &SceneInputs) {
    t.clear();
    let _ = write!(t, "STOPPED: unported {why}");
    let mut s = 2 * ui_scale(i.width, i.height, i.density) as u32;
    while s > 1 && text_w(t, s) > i.width as f32 - 8.0 {
        s -= 1; // (a long reason: smaller glyphs, down to scale 1)
    }
    let x = ((i.width as f32 - text_w(t, s)) * 0.5).max(4.0).floor();
    ui_text(&mut out.ui, t, x, (i.height as f32 * 0.5).floor(), s, [1.0, 0.35, 0.3, 1.0], true);
}

/// port: engine/lisp/ui.lisp UI-TEXT (one line, :left) and %GLYPH-RUN: STR's printable ASCII as quads of the 5x7 atlas (cells 6 x 8 of
/// a 96 x 48 texture, `render::ui`), top-left at (X Y) in window pixels, glyph scale S, colour C; SHADOW a 1-scale drop shadow
/// (0 0 0 0.75) first. A full stream drops the glyph (STREAM-ROOM-P). // dev: M3b replaces (its HUD draws its own text)
pub fn ui_text(ui: &mut Vec<f32>, str: &str, x: f32, y: f32, s: u32, c: [f32; 4], shadow: bool) {
    if shadow {
        ui_text(ui, str, x + s as f32, y + s as f32, s, [0.0, 0.0, 0.0, 0.75], false);
    }
    let (w, h) = ((5 * s) as f32, (7 * s) as f32);
    let (du, dv) = (5.0 / 96.0f32, 7.0 / 48.0f32);
    let (y1, mut cx) = (y + h, x);
    for ch in str.bytes() {
        let gl = if (32..=126).contains(&ch) { (ch - 32) as u32 } else { 31 }; // (31 = #\?)
        if gl != 0 {
            let u = ((gl % 16) * 6) as f32 / 96.0;
            let v = ((gl / 16) * 8) as f32 / 48.0;
            let (u1, v1, x1) = (u + du, v + dv, cx + w);
            if let Some(o) = ui_verts(ui, 6) {
                for (px, py, pu, pv) in [(cx, y, u, v), (x1, y, u1, v), (x1, y1, u1, v1), (cx, y, u, v), (x1, y1, u1, v1), (cx, y1, u, v1)] {
                    o.extend_from_slice(&[px, py, pu, pv, c[0], c[1], c[2], c[3]]);
                }
            }
        }
        cx += (6 * s) as f32;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn inputs() -> SceneInputs {
        SceneInputs { width: 640, height: 360, density: 1.0, msaa: 1, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 }
    }

    fn data() -> &'static Data {
        static D: std::sync::OnceLock<Data> = std::sync::OnceLock::new();
        D.get_or_init(Data::embedded)
    }

    /// Ruling R32: one frame per browser frame (the counter moved), none for the extra updates of one refresh; the first frame has
    /// dt 0 however long the load took (review I1: no backlog); a command applies at the next frame run.
    #[test]
    fn one_frame_per_refresh_and_no_load_backlog() {
        let mut g = Game::new(data(), inputs());
        let mut out = FrameOut::default();
        // the frozen page's clock under run.mjs --fixed-dt (Date.now = d0 + Math.round(vt), vt += 16.666667): whole ms, 17 16 17 ...
        let ms = |n: u64| (n * 1_000_000) as f32 * 1e-9f32;
        assert_eq!(g.refresh(40), 1); // the renderer ready at browser frame 40, 6.5 s into the page: one frame, dt 0
        assert_eq!(g.rdt_of(6500.0, 1, 1), 0.0);
        assert_eq!(g.refresh(40), 0, "a second update in the same refresh runs nothing");
        assert_eq!(g.refresh(41), 1);
        assert_eq!(g.rdt_of(6500.0 + 16.666667, 1, 1), ms(17)); // (6500 -> 6516.67, rounded 6517)
        assert_eq!(g.refresh(43), 1, "two refreshes since the last update: one frame");
        assert_eq!(g.rdt_of(6500.0 + 16.666667 * 3.0, 1, 1), ms(33)); // (the whole gap, 6517 -> 6550)
        assert!(g.frame(&mut out, 0.0));
        // ?stills: the first update runs the title frames since the clock started, spread from 0 (the frozen page's title runs
        // from its clock's start)
        let mut st = Game::new(data(), inputs());
        st.title_catch_up = true;
        assert_eq!(st.refresh(15), 15);
        assert_eq!((st.rdt_of(250.0, 1, 15), st.rdt_of(250.0, 2, 15)), (0.0, ms(16))); // (16.67 -> 17, 33.33 -> 33 ms)
        assert_eq!(st.refresh(16), 1);
        g.queue_cmd(2005);
        assert!(g.frame(&mut out, ms(17)));
        assert!(g.m.cmds.is_empty() && g.pending.is_empty() && g.m.flow != Flow::Title, "2005 applied at the next frame");
    }

    /// Review I3: a stall is one frame whose dt RUN-FRAME clamps to 0.1 s, and RUN-FIXED-STEPS runs at most 6 steps of it (engine/lisp/
    /// time.lisp: the rest of the backlog is dropped), through `rdt_of` as the page calls it: after a 200 ms and a 2 s gap the same
    /// steps as the Lisp's, where the grid driver ran 12 and 36. (6 from any accumulator left, checked on time.lisp's RUN-FIXED-STEPS
    /// in the host ECL: rdt 0.1 over residues 0..STEP.)
    #[test]
    fn a_stall_is_one_clamped_frame() {
        // RUN-FIXED-STEPS over single floats, from the accumulator ACC: (incf acc rdt), a step per whole +STEP+ up to 6, then a backlog
        // of a step or more is dropped
        let lisp_steps = |mut acc: f32, rdt: f32| {
            acc += rdt;
            let mut n = 0;
            while acc >= duel_sim::time::STEP && n < 6 {
                acc -= duel_sim::time::STEP;
                n += 1;
            }
            n
        };
        let mut g = Game::new(data(), inputs());
        let mut out = FrameOut::default();
        g.queue_cmd(2005);
        let (mut vt, mut raf) = (1000.0f64, 0u64);
        let mut frame = |g: &mut Game, gap: f64| {
            vt += gap;
            raf += 1;
            assert_eq!(g.refresh(raf), 1);
            let (rdt, acc, t0) = (g.rdt_of(vt, 1, 1), g.m.time.step_acc, g.m.time.tick);
            assert!(g.frame(&mut out, rdt), "{:?}", g.stopped);
            (rdt, acc, g.m.time.tick - t0)
        };
        for _ in 0..600 {
            frame(&mut g, 16.666667); // (into the fight: the intro's 300 frames, then the battle)
        }
        assert!(duel_sim::flow::sim_running_p(&g.m) && !g.m.turbo);
        for (gap, lisp) in [(200.0, 6), (2000.0, 6)] {
            let (rdt, acc, steps) = frame(&mut g, gap);
            assert_eq!(rdt, 0.1, "a {gap} ms gap: RUN-FRAME's clamp");
            assert_eq!((steps, lisp_steps(acc, rdt)), (lisp, lisp), "a {gap} ms gap from step_acc {acc}");
            let (_, _, after) = frame(&mut g, 16.666667);
            assert!(after <= 2, "the frame after the stall plays on at 60 Hz");
        }
    }

    /// Review F3: an Enter pressed while the page loads (no frame runs) is dropped, so the first frame plays the intro.
    #[test]
    fn a_press_during_the_load_is_dropped() {
        let mut g = Game::new(data(), inputs());
        let mut out = FrameOut::default();
        g.start = Some(Start::default());
        g.keys(0, crate::input::Key::Return.bit(), false);
        g.keys(0, 0, true);
        for _ in 0..3 {
            g.frame(&mut out, 1.0 / 60.0);
        }
        assert!(g.m.flow == Flow::Intro && g.m.cine.is_some(), "the intro plays");
    }

    #[test]
    fn start_screens_and_rematch() {
        let mut g = Game::new(data(), inputs());
        let mut out = FrameOut::default();
        g.start = Some(Start::default());
        g.now_ms = 123456.7;
        assert!(g.frame(&mut out, 1.0 / 60.0));
        assert_eq!((g.m.mode, g.m.picks, g.m.difficulty, g.m.match_seed), (duel_sim::state::Mode::VsCpu, [Character::Kenpachi, Character::Ichigo], Difficulty::Normal, 23456));
        assert!(g.m.fighter.get(g.m.p1).unwrap().brain.is_none() && g.m.fighter.get(g.m.p2).unwrap().brain.is_some());
        // Enter skips the intro cinematic
        assert_eq!(g.m.flow, Flow::Intro);
        g.kb.set(0, crate::input::Key::Return.bit());
        for _ in 0..3 {
            g.frame(&mut out, 1.0 / 60.0);
        }
        assert_eq!(g.m.flow, Flow::Battle);
        // Esc pauses and resumes; the frames between run no step
        g.kb.set(0, PAUSE);
        g.frame(&mut out, 1.0 / 60.0);
        let t = g.m.match_tick;
        assert!(g.m.paused);
        g.dev = true;
        g.frame(&mut out, 1.0 / 60.0);
        assert_eq!(g.m.match_tick, t);
        assert!(!out.ui.is_empty(), "the dev line and PAUSED drawn");
        g.kb.set(0, PAUSE);
        g.frame(&mut out, 1.0 / 60.0);
        assert!(!g.m.paused);
        // at RESULTS (forced here), Enter after 2.5 s plays the same match again with a new seed
        g.m.flow = Flow::Results;
        g.m.ft = 3.0;
        g.now_ms = 500.0;
        g.kb.set(0, CONFIRM);
        g.frame(&mut out, 1.0 / 60.0);
        assert_eq!((g.m.flow, g.m.match_seed, g.m.picks), (Flow::Intro, 500, [Character::Kenpachi, Character::Ichigo]));
    }
}
