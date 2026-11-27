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
//! Pacing: the page clock (performance.now: run.mjs's virtual clock under --fixed-dt) says how many 60 Hz frames are due; each Bevy
//! update runs the frames due since the last one (the first update after the renderer is ready catches up from the page's start), so
//! a game frame belongs to a page time, not to a count of Bevy updates (which varies at startup, M0_NOTES §2): the same script gives
//! the same frame at the same virtual time. No `FixedUpdate`.
use crate::input::{Keyboard, CONFIRM, PAUSE};
use duel_data::Data;
use duel_look::canvas::{ui_scale, ui_verts};
use duel_look::{draw_frame, FrameOut, Scene, SceneInputs};
use duel_sim::components::{Character, Difficulty, Flow};
use duel_sim::cpu::Search;
use duel_sim::flow;
use duel_sim::state::Match;
use std::fmt::Write;

/// One game frame's page time (ms): the frozen game's 60 Hz.
pub const FRAME_MS: f64 = 1000.0 / 60.0;
/// The frames one update may run once started; behind by more (a stall on the wall clock), the clock is rebased instead.
pub const CATCH_UP: i64 = 6;
/// The first update's catch-up bound (the page's start to the renderer ready); past it the clock is rebased.
pub const START_CATCH_UP: i64 = 900;

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
    /// Frames run, and the page-clock frame they map to (`due - base` frames are due).
    pub frames: i64,
    base: i64,
    started: bool,
    /// Debug commands and the frame they apply in (reserved; a run.mjs script sends a few).
    pending: Vec<(i64, i64)>,
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
            base: 0,
            started: false,
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

    /// A debug command that arrived while the page clock read DUE frames: it applies at the start of the next frame run, and never
    /// earlier than the clock's frame (an update during a held clock and the resumed tick's agree).
    pub fn queue_cmd(&mut self, c: i64, due: i64) {
        let at = (self.frames + 1).max(due - self.base);
        self.pending.push((at, c));
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
        let f = self.frames;
        if let Some(st) = self.start.take() {
            // port: SELECT-UPDATE's START (MODE set *mode* :vs-cpu; SELECT the picks and *difficulty*): NEW-SEED, START-MATCH
            let seed = self.new_seed();
            duel_sim::debug::vs_start(&mut self.m, &mut self.s, st.p1, st.p2, st.cpu, seed);
        }
        let m = &mut self.m;
        self.pending.retain(|&(at, c)| {
            if at <= f {
                m.cmds.push_back(c);
            }
            at > f
        });
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
    /// START-MATCH) where the frozen page shows RESULTS. Run before `flow::frame`, so before the commands and SCREEN-FX-UPDATE, where
    /// the Lisp runs FLOW-UPDATE after both: a pause press stops the screen effects' timers one frame later on the page than the
    /// Lisp's would (M3A_NOTES §10).
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

    /// The frames to run now, the page clock reading DUE frames since the page's start (and rebased when too far behind: the debug
    /// commands already queued keep the page frame they were stamped for, moved with the base and never into the past).
    pub fn due_now(&mut self, due: i64) -> i64 {
        let lag = due - self.base - self.frames;
        let cap = if self.started { CATCH_UP } else { START_CATCH_UP };
        self.started = true;
        if lag > cap {
            let k = lag - cap;
            self.base += k;
            let next = self.frames + 1;
            for p in &mut self.pending {
                p.0 = (p.0 - k).max(next);
            }
            return cap;
        }
        lag.max(0)
    }

    /// Frame I (1..=N) of this update's N frames: its dt, the page clock reading NOW_MS: the frozen page's RUN-FRAME dt
    /// (`duel_sim::flow::PageClock`: whole-ms Date.now through SDL's gettimeofday fallback, the first frame 0; M3A_NOTES §9).
    pub fn rdt_of(&mut self, now_ms: f64, i: i64, n: i64) -> f32 {
        self.clock.rdt(now_ms, i, n)
    }
}

/// Frames due at page time NOW_MS (ms since the page started).
pub fn due_at(now_ms: f64) -> i64 {
    (now_ms / FRAME_MS + 1e-6).floor() as i64
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

    #[test]
    fn pacing_and_command_frames() {
        assert_eq!(due_at(16.666667 * 240.0), 240); // (run.mjs's DT, a hair over 1000 / 60)
        let mut g = Game::new(data(), inputs());
        // the frozen page's clock under run.mjs --fixed-dt (Date.now = d0 + Math.round(vt), vt += 16.666667): whole ms, 17 16 17 ...
        let ms = |n: u64| (n * 1_000_000) as f32 * 1e-9f32;
        assert_eq!(g.rdt_of(16.666667 * 3.0, 1, 3), 0.0); // (the first update's catch-up: frame 1 has dt 0; its time 16.67 -> 17 ms)
        assert_eq!(g.rdt_of(16.666667 * 3.0, 2, 3), ms(16)); // (33.33 -> 33 ms)
        assert_eq!(g.rdt_of(16.666667 * 3.0, 3, 3), ms(17)); // (50.00 -> 50 ms)
        assert_eq!(g.rdt_of(16.666667 * 4.0, 1, 1), ms(17)); // (66.67 -> 67 ms)
        let mut g = Game::new(data(), inputs());
        assert_eq!(g.due_now(13), 13); // the first update catches up from the page's start
        let mut out = FrameOut::default();
        for f in 1..=13 {
            assert!(g.frame(&mut out, flow::raw_dt(f)), "{:?}", g.stopped);
        }
        g.queue_cmd(2005, 13); // arrived during a hold at frame 13: frame 14
        assert_eq!(g.due_now(14), 1);
        assert!(g.frame(&mut out, flow::raw_dt(14)));
        assert!(g.m.cmds.is_empty() && g.pending.is_empty());
        assert_eq!(g.due_now(100), CATCH_UP); // a stall: rebased
        for _ in 0..CATCH_UP {
            g.frame(&mut out, 1.0 / 60.0);
        }
        assert_eq!(g.due_now(100), 0);
        assert_eq!(g.due_now(101), 1);
    }

    /// Task 9's deferred minor: a load past START_CATCH_UP rebases the clock; a command stamped during the load keeps its page frame
    /// (moved with the base), and one whose frame is gone applies at the next frame run, never in the past.
    #[test]
    fn rebase_after_a_long_load_keeps_the_commands_page_frame() {
        let mut g = Game::new(data(), inputs());
        g.queue_cmd(2005, 1000); // (stamped at page frame 1000, during a 1200-frame load)
        g.queue_cmd(2102, 100); // (stamped at page frame 100: long gone after the rebase)
        assert_eq!(g.due_now(1200), START_CATCH_UP); // (rebased by 300: page frame 1000 is game frame 700)
        assert_eq!(g.pending, [(700, 2005), (1, 2102)]);
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
