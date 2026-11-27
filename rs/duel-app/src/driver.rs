//! The minimal frame driver (ruling R17; Task 10 owns the game loop's final shape): the game loop's three calls, `flow::frame` →
//! `duel_look::draw_frame` → `flow::frame_end`, in rs/duel-tools/src/draw.rs's order, with the Scene as the look sink, dt = the key's
//! `raw_dt(frame_n)` and no player input (CPU vs CPU, or what a debug command sets up). Debug commands from `Module._debug_cmd(n)`
//! go to the Match's command queue, applied at the start of the frame they are due in.
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
    /// dt = the page clock's frame instead of R17's raw_dt (a diagnostic: `?dt=clock`).
    pub clock_dt: bool,
}

impl Game {
    pub fn new(data: &'static Data, inputs: SceneInputs) -> Game {
        let mut m = Match::new(data);
        flow::go_title(&mut m);
        Game { m, s: Search::new(), sc: Scene::new(data, inputs), frames: 0, base: 0, started: false, pending: Vec::with_capacity(64), stopped: None, menu_camera: None, log: false, clock_dt: false }
    }

    /// A debug command that arrived while the page clock read DUE frames: it applies at the start of the next frame run, and never
    /// earlier than the clock's frame (an update during a held clock and the resumed tick's agree).
    pub fn queue_cmd(&mut self, c: i64, due: i64) {
        let at = (self.frames + 1).max(due - self.base);
        self.pending.push((at, c));
    }

    /// One frame: the commands due, then the loop's three calls. False once the fight stopped (`stopped` names the path).
    pub fn frame(&mut self, out: &mut FrameOut) -> bool {
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
        // ruling R17: the key's raw_dt (a hair under +STEP+, so a frame now and then runs no step); `clock_dt`: the page clock's frame
        // (1/60 s as f32 = +STEP+, the frozen page's dt under run.mjs --fixed-dt 16.666667), the page's `?dt=clock` (M3A_NOTES §9)
        let rdt = if self.clock_dt { (FRAME_MS / 1000.0) as f32 } else { flow::raw_dt(self.m.frame_n + 1) };
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
        assert_eq!(g.due_now(13), 13); // the first update catches up from the page's start
        let mut out = FrameOut::default();
        for _ in 0..13 {
            assert!(g.frame(&mut out), "{:?}", g.stopped);
        }
        g.queue_cmd(2005, 13); // arrived during a hold at frame 13: frame 14
        assert_eq!(g.due_now(14), 1);
        assert!(g.frame(&mut out));
        assert!(g.m.cmds.is_empty() && g.pending.is_empty());
        assert_eq!(g.due_now(100), CATCH_UP); // a stall: rebased
        for _ in 0..CATCH_UP {
            g.frame(&mut out);
        }
        assert_eq!(g.due_now(100), 0);
        assert_eq!(g.due_now(101), 1);
    }
}
