//! The minimal frame driver (ruling R17; Task 10 owns the game loop's final shape): the game loop's three calls, `flow::frame` →
//! `duel_look::draw_frame` → `flow::frame_end`, in rs/duel-tools/src/draw.rs's order, with the Scene as the look sink, dt = the key's
//! `raw_dt(frame_n)` and no player input (CPU vs CPU, or what a debug command sets up). Debug commands from `Module._debug_cmd(n)`
//! go to the Match's command queue, applied at the start of the frame they are due in.
//!
//! dt (ruling R17 amended, concern 1 of Task 9): the page clock's, as the frozen page computes it: engine/c/platform.c pf_pump's
//! `(now - prev) * 1e-9f` over SDL_GetTicksNS (emscripten's `Math.round(performance.now() * 1e6)` ns), clamped as RUN-FRAME clamps it.
//! The key's `raw_dt` is the headless stub's clock (16666666 / 16666667 ns alternating, so a frame now and then runs no step); under
//! run.mjs --fixed-dt 16.666667 the page's is 16666667 ns (+STEP+) but for the virtual clock's own rounding, and the sim and the looks'
//! timers land on other frames than the frozen page's when fed raw_dt (M3A_NOTES §9 "Concern 1").
//!
//! Pacing: the page clock (performance.now: run.mjs's virtual clock under --fixed-dt) says how many 60 Hz frames are due; each Bevy
//! update runs the frames due since the last one (the first update after the renderer is ready catches up from the page's start), so
//! a game frame belongs to a page time, not to a count of Bevy updates (which varies at startup, M0_NOTES §2): the same script gives
//! the same frame at the same virtual time. No `FixedUpdate`.
use duel_data::Data;
use duel_look::{draw_frame, FrameOut, Scene, SceneInputs};
use duel_sim::cpu::Search;
use duel_sim::flow::{self, NoInput};
use duel_sim::state::Match;

/// One game frame's page time (ms): the frozen game's 60 Hz.
pub const FRAME_MS: f64 = 1000.0 / 60.0;
/// The frames one update may run once started; behind by more (a stall on the wall clock), the clock is rebased instead.
pub const CATCH_UP: i64 = 6;
/// The first update's catch-up bound (the page's start to the renderer ready); past it the clock is rebased.
pub const START_CATCH_UP: i64 = 900;

pub struct Game {
    pub m: Match,
    pub s: Search,
    pub sc: Scene<'static>,
    /// Frames run, and the page-clock frame they map to (`due - base` frames are due).
    pub frames: i64,
    base: i64,
    started: bool,
    /// Debug commands and the frame they apply in (reserved; a run.mjs script sends a few).
    pending: Vec<(i64, i64)>,
    /// Why the fight stopped (an unported path), logged once.
    pub stopped: Option<&'static str>,
    /// The non-fatal unported camera seen (the menus', M3b).
    pub menu_camera: Option<&'static str>,
    /// Keep the combat log as the commands set it (`m.log` filled, as the frozen page prints it): the page's `?log` (a diagnostic).
    pub log: bool,
    /// The page clock: the last update's time (ms) and the last frame's SDL_GetTicksNS (whole ns); this update's step per frame.
    clock: Option<(f64, u64)>,
    clock_step: f64,
}

impl Game {
    pub fn new(data: &'static Data, inputs: SceneInputs) -> Game {
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        Game { m, s: Search::new(), sc: Scene::new(data, inputs), frames: 0, base: 0, started: false, pending: Vec::with_capacity(64), stopped: None, menu_camera: None, log: false, clock: None, clock_step: 0.0 }
    }

    /// A debug command that arrived while the page clock read DUE frames: it applies at the start of the next frame run, and never
    /// earlier than the clock's frame (an update during a held clock and the resumed tick's agree).
    pub fn queue_cmd(&mut self, c: i64, due: i64) {
        let at = (self.frames + 1).max(due - self.base);
        self.pending.push((at, c));
    }

    /// One frame: the commands due, then the loop's three calls. False once the fight stopped (`stopped` names the path).
    pub fn frame(&mut self, out: &mut FrameOut, rdt: f32) -> bool {
        if self.stopped.is_some() {
            return false;
        }
        self.frames += 1;
        let f = self.frames;
        let m = &mut self.m;
        self.pending.retain(|&(at, c)| {
            if at <= f {
                m.cmds.push_back(c);
            }
            at > f
        });
        flow::frame(&mut self.m, &mut self.s, &mut NoInput, &mut self.sc, rdt);
        draw_frame(&mut self.sc, &mut self.m, rdt, out);
        flow::frame_end(&mut self.m, &mut self.s);
        if !self.log {
            self.m.log_on = false; // (a command turns the combat log on; its lines allocate: the page keeps it off unless asked)
        }
        // the menus' camera (the title before a debug command starts a fight) is M3b's: not a stop, the frame keeps the camera it has
        // (as duel-tools replay reads and clears it after every frame)
        if let Some(u) = self.sc.unported_camera.take() {
            self.menu_camera.get_or_insert(u);
        }
        self.stopped = self.m.unported.or(self.s.cut.map(|_| "a cut CPU rollout")).or(self.sc.unported);
        self.stopped.is_none()
    }

    /// The frames to run now, the page clock reading DUE frames since the page's start (and rebased when too far behind).
    pub fn due_now(&mut self, due: i64) -> i64 {
        let lag = due - self.base - self.frames;
        let cap = if self.started { CATCH_UP } else { START_CATCH_UP };
        self.started = true;
        if lag > cap {
            self.base += lag - cap;
            return cap;
        }
        lag.max(0)
    }
}

impl Game {
    /// Frame I (1..=N) of this update's N frames: its dt, Date.now() reading NOW_MS (whole ms). The frozen page's RUN-FRAME dt is
    /// engine/c/platform.c pf_pump's `(now - prev) * 1e-9f` over SDL_GetTicksNS, and on emscripten that is whole milliseconds: SDL's
    /// CLOCK_MONOTONIC_RAW (4) is refused by emscripten's clock_gettime (EINVAL above WASI's clock 3), so SDL falls back to
    /// gettimeofday, which reads Date.now(). So each frame's dt is 0.016 or 0.017 at 60 Hz (run.mjs --fixed-dt: Date.now = d0 +
    /// Math.round(vt)), and a frame now and then runs no step or two. Each frame here takes its whole-ms share of the clock since the
    /// last update (the last frame at NOW exactly: one frame an update is pf_pump's dt bit for bit), clamped to 0..0.1 as RUN-FRAME's;
    /// the page's first frame has dt 0.
    pub fn rdt_of(&mut self, now_ms: f64, i: i64, n: i64) -> f32 {
        let ns = |t: f64| t.round() as u64 * 1_000_000; // (gettimeofday's µs of a whole-ms Date.now, x 1000 by SDL_GetTicksNS)
        if i == 1 {
            let t0 = self.clock.map_or(0.0, |c| c.0);
            self.clock_step = (now_ms - t0) / n as f64;
            if self.clock.is_none() {
                self.clock = Some((0.0, ns(self.clock_step))); // (frame 1's own time: dt 0)
            }
        }
        let (t0, prev) = self.clock.unwrap();
        let t = if i == n { now_ms } else { t0 + self.clock_step * i as f64 };
        let raw = (ns(t).saturating_sub(prev)) as f32 * 1e-9f32;
        self.clock = Some((if i == n { now_ms } else { t0 }, ns(t)));
        #[allow(clippy::manual_clamp)] // (CL MIN / MAX, in their order)
        f32::min(0.1, f32::max(0.0, raw))
    }
}

/// Frames due at page time NOW_MS (ms since the page started).
pub fn due_at(now_ms: f64) -> i64 {
    (now_ms / FRAME_MS + 1e-6).floor() as i64
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pacing_and_command_frames() {
        assert_eq!(due_at(16.666667 * 240.0), 240); // (run.mjs's DT, a hair over 1000 / 60)
        let data: &'static Data = Box::leak(Box::new(Data::embedded()));
        let inputs = SceneInputs { width: 640, height: 360, density: 1.0, msaa: 1, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
        let mut g = Game::new(data, inputs);
        // the frozen page's clock under run.mjs --fixed-dt (Date.now = d0 + Math.round(vt), vt += 16.666667): whole ms, 17 16 17 ...
        let ms = |n: u64| (n * 1_000_000) as f32 * 1e-9f32;
        assert_eq!(g.rdt_of(16.666667 * 3.0, 1, 3), 0.0); // (the first update's catch-up: frame 1 has dt 0; its time 16.67 -> 17 ms)
        assert_eq!(g.rdt_of(16.666667 * 3.0, 2, 3), ms(16)); // (33.33 -> 33 ms)
        assert_eq!(g.rdt_of(16.666667 * 3.0, 3, 3), ms(17)); // (50.00 -> 50 ms)
        assert_eq!(g.rdt_of(16.666667 * 4.0, 1, 1), ms(17)); // (66.67 -> 67 ms)
        let mut g = Game::new(data, inputs);
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
}
