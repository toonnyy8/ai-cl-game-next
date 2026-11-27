//! The cinematics' looks (docs/bevy/M3A_NOTES.md §8): engine/lisp/cine.lisp's shot (CINE-CAM), duel/lisp/cinema.lisp (the director's
//! look hooks, the shot helpers, the screen punctuation a script asks for, the generic scripts' look forms), camera.lisp's cinematic
//! branch of DUEL-CAMERA, and the kits' scripts (`ken`, `ichigo`). The sim half (the director, the forms that move actors) is
//! `duel_sim::cine`; it calls `CineLook::forms` right after a frame's sim forms (ruling R9): `Scene` in step mode (CINE-STEP's AT forms;
//! START-CINE's frame 0 from the queue), `CineDraw` in draw mode (CINE-DRAW's DURING forms, into the frame's arrays).
pub mod ichigo;
pub mod ken;

use crate::canvas::Bcap;
use crate::draw::FrameOut;
use crate::fx::{Ctx, Em};
use crate::scene::{push_sound, Scene, SoundReq};
use duel_sim::cine::CineName;
use duel_sim::cl::max_f32;
use duel_sim::ecs::Entity;
use duel_sim::fighter::{pos_of, yaw_of};
use duel_sim::look::CineLook;
use duel_sim::math::{deg, f_cos, f_hypot, f_max, f_min, f_sin, f_sqrt, fwd_x, fwd_z, hypot};
use duel_sim::state::Match;

/// A card beat's background (cinema.lisp CARD's KIND).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Card {
    Black,
    White,
}

/// The cinematic look state the Lisp keeps in specials (cinema.lisp, cine.lisp's shot, camera.lisp's `*cine-subject*`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CineLooks<'d> {
    /// `*draw-scale-e*` / `*draw-scale*` (CINE-SCALE), `*aura-off*`.
    pub draw_scale_e: Option<Entity>,
    pub draw_scale: f32,
    pub aura_off: Option<Entity>,
    /// `*cine-cam*`, `*cine-eye*`, `*cine-target*` (CINE-CAM).
    pub cam: bool,
    pub eye: [f32; 3],
    pub target: [f32; 3],
    /// `*dutch*` (degrees), `*lens-fov*` (radians), `*cine-close*`, `*cine-subject*`.
    pub dutch: f32,
    pub lens_fov: f32,
    pub close: bool,
    pub subject: Option<Entity>,
    /// `*card*`, `*card-only*`, `*cine-grade*` (an `*impact-presets*` key).
    pub card: Option<Card>,
    pub card_only: Option<Entity>,
    pub grade: Option<&'static str>,
    /// `*caption*`, `*caption-out*` (brush.lisp BCAPs: the canvas draws them).
    pub caption: Option<Bcap<'d>>,
    pub caption_out: Option<Bcap<'d>>,
    /// `*splash-args*`: the impact splash's cx cy r seed.
    pub splash: Option<[f32; 4]>,
}

impl Default for CineLooks<'_> {
    fn default() -> Self {
        CineLooks {
            draw_scale_e: None,
            draw_scale: 1.0,
            aura_off: None,
            cam: false,
            eye: [0.0; 3],
            target: [0.0; 3],
            dutch: 0.0,
            lens_fov: deg(60.0),
            close: false,
            subject: None,
            card: None,
            card_only: None,
            grade: None,
            caption: None,
            caption_out: None,
            splash: None,
        }
    }
}

/// cinema.lisp `*pt-close-shot*`: a SHOT-ON at most this far from its fighter is a close-up (portrait).
const PT_CLOSE_SHOT: f32 = 5.0;

/// DEFCINE's DURING (FROM TO): U 0..1 across it while FROM <= CF < TO (`(/ (float (- cf from)) (float (max 1 (- to from))))`).
#[inline]
pub(crate) fn during(cf: i64, from: i64, to: i64) -> Option<f32> {
    (from <= cf && cf < to).then(|| (cf - from) as f32 / (to - from).max(1) as f32)
}

impl<'d> Scene<'d> {
    // ------------------------------------------------------------ the director's look hooks (START-CINE ... CINE-END)

    /// port: engine/lisp/cine.lisp START-CINE's looks: the split grade off, no shot.
    pub(crate) fn cine_start_looks(&mut self) {
        self.draw.post.grade_split = 0.0;
        self.cine.cam = false;
    }

    /// port: cinema.lisp CINE-BEGIN's looks: no caption yet, the lens 60, no close-up, no subject.
    pub(crate) fn cine_begin_looks(&mut self) {
        let c = &mut self.cine;
        (c.caption, c.caption_out, c.lens_fov, c.close, c.subject) = (None, None, deg(60.0), false, None);
    }

    /// port: engine/lisp/cine.lisp END-CINE's looks: no shot, the grades off.
    pub(crate) fn cine_stop_looks(&mut self) {
        self.cine.cam = false;
        (self.draw.post.grade_desat, self.draw.post.grade_split) = (0.0, 0.0);
    }

    /// port: cinema.lisp CINE-END's looks: a title still up slices out over what follows, the card, grade, dutch, lens, aura, subject,
    /// draw scale and time scale reset, the camera's up, the UI flash, the screen punctuation, STAGE-ENV. (UNSILHOUETTE: no in-scope
    /// script calls SILHOUETTE-BLACK.)
    pub(crate) fn cine_end_looks(&mut self) {
        let clock = self.draw.post.fx_clock;
        let c = &mut self.cine;
        c.caption_out = c.caption.take().map(|mut b| {
            b.exit(clock);
            b
        });
        (c.card, c.card_only, c.grade, c.dutch, c.aura_off, c.subject, c.draw_scale_e, c.draw_scale) =
            (None, None, None, 0.0, None, None, None, 1.0);
        self.draw.camera.fov = deg(60.0);
        self.cine_time_scale = 1.0;
        self.draw.camera.up = [0.0, 1.0, 0.0];
        self.fx.ui_flash = [0.0; 5];
        crate::fx::screen::screen_fx_clear(&mut self.draw, &mut self.sounds);
        self.draw.env.stage_env();
    }

    // ------------------------------------------------------------ the shot

    /// port: engine/lisp/cine.lisp CINE-CAM — the shot's eye and target (world metres).
    pub(crate) fn cine_cam(&mut self, ex: f32, ey: f32, ez: f32, tx: f32, ty: f32, tz: f32) {
        let c = &mut self.cine;
        (c.eye, c.target, c.cam) = ([ex, ey, ez], [tx, ty, tz], true);
    }

    /// onehand.lisp PORTRAIT-P.
    pub(crate) fn portrait_p(&self) -> bool {
        self.inputs.height > self.inputs.width
    }

    /// port: cinema.lisp SHOT-ON — the camera ANG degrees round E's facing, DIST away, H high, at his body LOOK up, AHEAD in front of
    /// him, OFF to the shot's left (a portrait screen brings OFF nearer the middle).
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn shot_on(&mut self, m: &Match, e: Entity, ang: f32, dist: f32, h: f32, look: f32, ahead: f32, off: f32) {
        let close = dist <= PT_CLOSE_SHOT;
        (self.cine.close, self.cine.subject) = (close, Some(e));
        let off = if off != 0.0 && self.portrait_p() { (if close { 0.25 } else { 0.5 }) * off } else { off };
        let (p, ye) = (pos_of(m, e), yaw_of(m, e));
        let yaw = ye + deg(ang);
        let (fx, fz) = (fwd_x(ye), fwd_z(ye));
        let tx = (p[0] + ahead * fx) - off * fwd_z(yaw);
        let tz = (p[2] + ahead * fz) + off * fwd_x(yaw);
        self.cine_cam(tx + dist * fwd_x(yaw), h, tz + dist * fwd_z(yaw), tx, look, tz);
    }

    /// port: cinema.lisp SHOT-PAIR — both fighters from the SIDE (+1 / -1) of the A -> V line, DIST from their midpoint.
    pub(crate) fn shot_pair(&mut self, m: &Match, a: Entity, v: Entity, side: f32, dist: f32, h: f32) {
        (self.cine.close, self.cine.subject) = (false, None);
        let (p, q) = (pos_of(m, a), pos_of(m, v));
        let (mx, mz) = (0.5 * (p[0] + q[0]), 0.5 * (p[2] + q[2]));
        let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
        let d = max_f32(0.01, hypot(dx, dz));
        self.cine_cam(mx + side * dist * (-dz / d), h, mz + side * dist * (dx / d), mx, 1.1, mz);
    }

    /// port: camera.lisp CAMERA-SIDE — for a SHOT-PAIR from A (None: P1) to the other, the side the duel camera is on.
    pub(crate) fn camera_side(m: &Match, a: Option<Entity>) -> f32 {
        let vs = m.view_side as f32;
        match a.and_then(|a| m.fighter.get(a)) {
            Some(f) if f.side == 1 => -vs,
            _ => vs,
        }
    }

    /// port: cinema.lisp LENS — the vertical field of view FOV (degrees) and the dutch ROLL (degrees).
    pub(crate) fn lens(&mut self, fov: f32, roll: f32) {
        self.draw.camera.fov = deg(fov);
        (self.cine.lens_fov, self.cine.dutch) = (self.draw.camera.fov, roll);
    }

    // ------------------------------------------------------------ the beat's looks

    /// port: cinema.lisp CARD — a black / white card behind the fighters (KIND None: the stage back); ONLY the one actor drawn on it.
    pub(crate) fn card(&mut self, kind: Option<Card>, only: Option<Entity>) {
        self.cine.card = kind;
        self.cine.card_only = kind.and(only);
        if kind.is_some() {
            self.fx_clear();
        }
        match kind {
            Some(k) => {
                let c = if k == Card::White { 0.955 } else { 0.031 };
                let e = &mut self.draw.env;
                (e.sky_top, e.fog_color, e.moon_color) = ([c; 3], [c; 3], [c; 3]);
                (e.fog_density, e.vignette, e.sun_glow) = (0.0, 0.0, 0.0);
            }
            None => self.draw.env.stage_env(),
        }
    }

    /// port: cinema.lisp FREEZE — the effects stop for FRAMES 60 Hz frames.
    pub(crate) fn freeze(&mut self, frames: f32) {
        self.draw.screen_fx[6] = frames / 60.0;
    }

    /// port: draw.lisp HOLD-POSE of E's model.
    pub(crate) fn hold(&mut self, e: Entity, frames: f32) {
        if let Some(md) = self.md_mut(e) {
            crate::draw::fighter::hold_pose(md, frames);
        }
    }

    /// port: cinema.lisp HOLD-BOTH.
    pub(crate) fn hold_both(&mut self, a: Entity, v: Entity, frames: f32) {
        self.hold(a, frames);
        self.hold(v, frames);
        self.freeze(frames);
    }

    /// port: cinema.lisp IMPACT-FRAME.
    pub(crate) fn impact(&mut self, kind: &str, frames: f32) {
        crate::fx::screen::impact_frame(&mut self.draw, kind, frames);
    }

    /// port: cinema.lisp CINE-GRADE — the cinematic's base grade from now on (None: none), under its impact frames.
    pub(crate) fn cine_grade(&mut self, kind: Option<&'static str>) {
        self.cine.grade = kind;
        if self.draw.screen_fx[0] <= 0.0 {
            match kind {
                Some(k) => self.impact(k, 0.0),
                None => self.draw.post.grade_impact(0),
            }
        }
    }

    /// port: render.lisp WORLD-TO-SCREEN on the camera as it stands (window pixels, top-left origin; None behind the camera).
    pub(crate) fn world_to_screen(&self, x: f32, y: f32, z: f32) -> Option<[f32; 3]> {
        world_to_screen(&self.draw.camera.view_proj, self.inputs.width, self.inputs.height, x, y, z)
    }

    /// port: cinema.lisp FOCUS-LINES — ink focus lines for FRAMES, converging on world point AT (None: the screen centre).
    pub(crate) fn focus(&mut self, frames: f32, at: Option<[f32; 3]>) {
        crate::fx::screen::focus_lines(&mut self.draw, frames);
        if let Some([x, y, z]) = at
            && let Some(v) = self.world_to_screen(x, y, z)
        {
            (self.draw.screen_fx[4], self.draw.screen_fx[5]) = (v[0], v[1]);
        }
    }

    /// port: cinema.lisp SILENCE — the silence beat for FRAMES (the music down, the sfx bus muted: a sound request, M3b plays it).
    pub(crate) fn silence(&mut self, frames: f32) {
        self.draw.screen_fx[2] = frames / 60.0;
        push_sound(&mut self.sounds, SoundReq::Silence);
    }

    /// port: cinema.lisp BACK-RIM with its colour.
    pub(crate) fn back_rim(&mut self, frames: f32, rgb: [f32; 3]) {
        crate::fx::screen::back_rim(&mut self.draw, frames);
        self.draw.env.cin_rim = rgb;
    }

    /// port: cinema.lisp UI-FLASH.
    pub(crate) fn ui_flash(&mut self, r: f32, g: f32, b: f32, a: f32, fade: f32) {
        self.fx.ui_flash = [r, g, b, a, fade];
    }

    /// port: cinema.lisp CAPTION — the brush title, stamped in now.
    pub(crate) fn caption(&mut self, b: Bcap<'d>) {
        self.cine.caption = Some(b);
    }

    /// port: cinema.lisp CAPTION-EXIT.
    pub(crate) fn caption_exit(&mut self) {
        let clock = self.draw.post.fx_clock;
        if let Some(b) = self.cine.caption.as_mut() {
            b.exit(clock);
        }
    }

    /// A brush caption starting now (brush.lisp MAKE-BCAP :layout :cine).
    pub(crate) fn bcap(&self, kanji: &'d str) -> Bcap<'d> {
        Bcap::new(kanji, self.draw.post.fx_clock)
    }

    /// port: cinema.lisp CINE-SCALE.
    pub(crate) fn cine_scale(&mut self, e: Entity, s: f32) {
        let c = &mut self.cine;
        (c.draw_scale_e, c.draw_scale) = if s == 1.0 { (None, 1.0) } else { (Some(e), s) };
    }

    /// port: cinema.lisp CINE-SLOW.
    pub(crate) fn cine_slow(&mut self, k: f32) {
        self.cine_time_scale = k;
    }

    /// port: cinema.lisp IMPACT-SPLASH — an ink splash at world (X Y Z) for FRAMES, R x the screen height.
    pub(crate) fn impact_splash(&mut self, x: f32, y: f32, z: f32, frames: f32, r: f32) {
        if let Some(v) = self.world_to_screen(x, y, z) {
            self.cine.splash = Some([v[0], v[1], r * self.inputs.height as f32, duel_sim::cl::mod_f32(13.7 * x, 50.0)]);
            self.draw.screen_fx[7] = frames / 60.0;
        }
    }

    /// port: cinema.lisp IMPACT-SPLASH-AT — at V's feet point (x, z), height Y.
    pub(crate) fn impact_splash_at(&mut self, m: &Match, v: Entity, y: f32, frames: f32, r: f32) {
        let q = pos_of(m, v);
        self.impact_splash(q[0], y, q[2], frames, r);
    }

    /// port: cinema.lisp CINE-SHATTER — the Konpaku shatter's look on V (N souls at UP above his feet, DY higher).
    pub(crate) fn shatter(&mut self, m: &Match, v: Entity, n: i64, up: f32, dy: f32) {
        let p = pos_of(m, v);
        crate::fx::stamps::vfx_konpaku_shatter(&mut self.em(), p[0], (p[1] + up) + dy, p[2], n.max(0) as usize);
    }

    /// The Kikon souls of A (FIGHTER-KIKON-N).
    pub(crate) fn kikon_n(m: &Match, a: Entity) -> i64 {
        m.fighter.get(a).map_or(0, |f| f.kikon_n)
    }

    /// port: ken.lisp CINE-SLASH — a cinematic cut landing on V: sparks, sound, flash.
    pub(crate) fn slash(&mut self, m: &Match, v: Entity, kind: &str) {
        let p = pos_of(m, v);
        crate::fx::stamps::vfx_hit(&mut self.em(), p[0], p[1] + 1.2, p[2], kind, 0.0, -1.0);
        self.sfx(if kind == "heavy" { "cut-heavy" } else { "cut" }, 1.0, 1.0);
        self.flash(v, 0.1);
    }

    /// `(setf (model-flash (model e)) secs)`.
    pub(crate) fn flash(&mut self, e: Entity, secs: f32) {
        if let Some(md) = self.md_mut(e) {
            md.flash = secs;
        }
    }

    /// port: draw.lisp FACE-BEAT of E: the shout held SECS (HEAD-BACK: the head thrown back too).
    pub(crate) fn shout(&mut self, e: Entity, secs: f32, head_back: bool) {
        if let Some(md) = self.md_mut(e) {
            crate::draw::fighter::face_beat(md, crate::scene::Face::Shout, secs, head_back);
        }
    }

    /// PLAY-SFX (M3b plays it).
    pub(crate) fn sfx(&mut self, key: &'static str, pitch: f32, gain: f32) {
        push_sound(&mut self.sounds, SoundReq::Play { key, gain, pitch });
    }

    /// port: engine/lisp/fx.lisp SHAKE.
    pub(crate) fn shake(&mut self, amp: f32, dur: f32) {
        crate::fx::screen::shake(&mut self.draw, amp, dur);
    }

    /// port: cinema.lisp CINE-CLIP (PLAY-CLIP with :restart t) of CLIP on actor E, through his kit now (CLIP-OR-FALLBACK: `resolve`).
    pub(crate) fn clip(&mut self, m: &Match, e: Entity, clip: &'d str, blend: f32, speed: f32, time: f32) {
        let kit = duel_sim::fighter::kit_of(m, e);
        let Some(body) = self.model(e).map(|md| md.body) else { return };
        if let Some(c) = self.resolve(body, kit, clip) {
            self.md_mut(e).unwrap().anim.play(c, blend, speed, time, true);
        }
    }

    /// E's kit's stance clip (KIT-STANCE).
    pub(crate) fn stance(m: &Match, e: Entity) -> &'static str {
        &duel_sim::fighter::kit_of(m, e).stance
    }

    /// The model of E (mutable).
    pub(crate) fn md_mut(&mut self, e: Entity) -> Option<&mut crate::scene::Model<'d>> {
        self.models.iter_mut().find(|md| md.e == e)
    }

    /// `(setf (model-weapon (model e)) w)` (a weapon of the data).
    pub(crate) fn set_weapon(&mut self, e: Entity, w: &str) {
        let data: &'d duel_data::Data = self.data;
        let name = data.weapons.get_key_value(w).map(|(k, _)| k.as_str()).unwrap_or_else(|| panic!("no weapon {w}"));
        if let Some(md) = self.md_mut(e) {
            md.weapon = name;
        }
    }

    /// The frame's drawing context on OUT (CINE-DRAW's looks).
    pub(crate) fn ctx<'a>(&'a mut self, out: &'a mut FrameOut) -> Ctx<'a, 'd> {
        Ctx { out, cam: &self.draw.camera, cos: &mut self.cos, fx: &mut self.fx, clock: self.draw.post.fx_clock }
    }

    /// A frame's step-mode context for a script's starting looks (particles, stamps, marks).
    pub(crate) fn em(&mut self) -> Em<'_, 'd> {
        Em { cos: &mut self.cos, fx: &mut self.fx, clock: self.draw.post.fx_clock }
    }

    // ------------------------------------------------------------ the scripts

    /// A script's step-mode look forms (its AT forms and `(when step-p …)` forms) at frame CF.
    pub(crate) fn cine_at(&mut self, m: &Match, name: CineName, cf: i64, a: Entity, v: Entity) {
        match name {
            CineName::SoulBreak => self.soul_break_at(m, cf, a, v),
            CineName::Intro => self.intro_at(m, cf, a, v),
            CineName::Ko => self.ko_at(m, cf, a, v),
            CineName::Time => self.time_at(cf),
            CineName::Ken(k) => self.ken_at(m, k, cf, a, v),
            CineName::Ichigo(k) => self.ichigo_at(m, k, cf, a, v),
        }
    }

    /// A script's draw-mode look forms (its DURING forms) at frame CF, into OUT; DT is CINE-DT (0 while the effects are frozen, else
    /// the frame's real seconds).
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn cine_during(&mut self, m: &Match, name: CineName, cf: i64, a: Entity, v: Entity, out: &mut FrameOut, dt: f32) {
        match name {
            CineName::SoulBreak => {
                if during(cf, 0, 96).is_some() {
                    let p = pos_of(m, v);
                    vfx_soul_flame(&mut self.ctx(out), p[0], 2.2, p[2], cf as f32 / 60.0);
                }
            }
            CineName::Intro => {
                if let Some(u) = during(cf, 0, 120) {
                    self.shot_on(m, a, 25.0 + 20.0 * u, 3.6 - 0.6 * u, 1.5, 1.2, 0.0, -0.7);
                }
                if let Some(u) = during(cf, 120, 240) {
                    self.shot_on(m, v, -25.0 - 20.0 * u, 3.6 - 0.6 * u, 1.5, 1.2, 0.0, 0.7);
                }
                if let Some(u) = during(cf, 240, 300) {
                    self.shot_pair(m, a, v, Self::camera_side(m, None), 6.0 + 2.0 * u, 2.4);
                }
            }
            CineName::Ko => {
                if let Some(u) = during(cf, 20, 150) {
                    self.shot_on(m, v, 40.0 + 50.0 * u, 5.0 - 1.2 * u, 1.0 + 0.6 * u, 0.8, 0.0, 0.0);
                    let p = pos_of(m, v);
                    let (age, k) = ((cf - 20) as f32 / 60.0, f_min(0.9, (cf - 20) as f32 / 20.0));
                    vfx_rain(&mut self.ctx(out), p[0], p[2], age, k);
                }
            }
            CineName::Time => {
                if let Some(u) = during(cf, 0, 120) {
                    self.shot_pair(m, a, v, Self::camera_side(m, Some(a)), 8.0 + u, 2.6);
                }
            }
            CineName::Ken(k) => self.ken_during(m, k, cf, a, v, out, dt),
            CineName::Ichigo(k) => self.ichigo_during(m, k, cf, a, v, out, dt),
        }
    }

    /// port: cinema.lisp SOUL-BREAK-CINE's AT forms.
    fn soul_break_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.clip(m, v, "sh-crumple", 2.0, 1.0, 0.0);
                self.clip(m, a, Self::stance(m, a), 6.0, 1.0, 0.0);
                self.hold_both(a, v, 6.0);
                self.impact("negative", 2.0);
                self.sfx("kikon-slash", 1.0, 1.0);
            }
            6 => {
                self.shot_on(m, v, 60.0, 3.4, 0.8, 0.9, 0.0, -0.7);
                self.lens(50.0, -6.0);
                let mut b = self.bcap("魂");
                (b.reading, b.side) = (Some("SOUL BREAK"), 1);
                self.caption(b);
            }
            28 => {
                self.hold_both(a, v, 12.0);
                self.silence(12.0);
                self.shot_on(m, v, 60.0, 1.9, 0.45, 0.9, 0.0, 0.0);
                self.lens(82.0, 0.0);
            }
            40 => {
                self.shatter(m, v, 4, 1.1, 0.0);
                self.impact("negative", 2.0);
                self.lens(55.0, 0.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.shake(0.15, 0.3);
            }
            42 => self.impact("manga", 10.0),
            60 => {
                self.shot_pair(m, a, v, 1.0, 7.0, 2.2);
                self.lens(50.0, 0.0);
                self.caption_exit();
            }
            _ => {}
        }
    }

    /// port: cinema.lisp INTRO-CINE's AT forms and its step-mode INTRO-WEAPONs.
    fn intro_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        let data: &'d duel_data::Data = self.data;
        let kit = |e: Entity| duel_sim::fighter::kit_of(m, e);
        let or_stance = |s: &'static str, e: Entity| if s.is_empty() { Self::stance(m, e) } else { s };
        match cf {
            0 => {
                for e in [a, v] {
                    self.clip(m, e, Self::stance(m, e), 0.0, 1.0, 0.0);
                }
                self.clip(m, a, or_stance(&kit(a).intro, a), 0.0, 1.0, 0.0);
                self.shot_on(m, a, 25.0, 3.6, 1.5, 1.2, 0.0, -0.7);
                self.intro_weapon(m, a, 0);
                let (kanji, reading) = brush_name(data, &kit(a).character);
                let mut b = self.bcap(kanji);
                (b.reading, b.sub, b.side) = (Some(reading), kit(a).intro_callout.as_deref(), 1);
                self.caption(b);
            }
            120 => {
                self.clip(m, v, or_stance(&kit(v).intro, v), 0.0, 1.0, 0.0);
                self.impact("negative", 2.0);
                let (kanji, reading) = brush_name(data, &kit(v).character);
                let mut b = self.bcap(kanji);
                (b.reading, b.sub, b.side) = (Some(reading), kit(v).intro_callout.as_deref(), 0);
                self.caption(b);
            }
            _ => {}
        }
        self.intro_weapon(m, a, cf);
        self.intro_weapon(m, v, cf - 120);
        match cf {
            240 => self.caption_exit(),
            250 => self.sfx("fight", 1.0, 1.0),
            _ => {}
        }
    }

    /// port: cinema.lisp INTRO-WEAPON — the intro prop until the kit's hand-off frame (no in-scope kit has one: `unported`), then the
    /// weapon.
    fn intro_weapon(&mut self, m: &Match, e: Entity, _frame: i64) {
        let kit = duel_sim::fighter::kit_of(m, e);
        if kit.intro_weapon.is_some() {
            self.unported.get_or_insert("a kit's :intro-weapon (Yamamoto's cane: M4)");
            return;
        }
        self.set_weapon(e, &kit.weapon);
    }

    /// port: cinema.lisp KO-CINE's AT forms.
    fn ko_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.clip(m, v, "sh-lose", 8.0, 1.0, 0.0);
                let w: &'static str = &duel_sim::fighter::kit_of(m, a).win;
                self.clip(m, a, if w.is_empty() { Self::stance(m, a) } else { w }, 8.0, 1.0, 0.0);
                self.impact("two-tone", 3.0);
                self.hold(a, 20.0);
                self.sfx("ko", 1.0, 1.0);
                self.shot_on(m, a, 30.0, 3.0, 0.8, 1.3, 0.0, -0.8);
                self.lens(42.0, 0.0);
                let mut b = self.bcap("決着");
                (b.reading, b.side) = (Some("K.O."), 1);
                self.caption(b);
            }
            20 => self.lens(55.0, 0.0),
            _ => {}
        }
    }

    /// port: cinema.lisp TIME-CINE's AT forms.
    fn time_at(&mut self, cf: i64) {
        if cf == 0 {
            let mut b = self.bcap("時間切れ");
            (b.reading, b.side) = (Some("TIME"), 0);
            self.caption(b);
            self.impact("negative", 2.0);
            self.sfx("ko", 1.0, 1.0);
        }
    }
}

/// brush.lisp `*brush-names*`: CHARACTER's name in kanji and its reading (tuning.json).
fn brush_name<'d>(d: &'d duel_data::Data, character: &str) -> (&'d str, &'d str) {
    let rows = d.tuning["*BRUSH-NAMES*"].as_array().expect("tuning *BRUSH-NAMES*");
    let r = rows.iter().find(|r| r[0].as_str() == Some(character)).unwrap_or_else(|| panic!("*BRUSH-NAMES* {character}"));
    (r[1].as_str().unwrap(), r[2].as_str().unwrap())
}

/// port: render.lisp WORLD-TO-SCREEN through VIEW-PROJ on a W x H window.
pub(crate) fn world_to_screen(m: &[f32; 16], w: u32, h: u32, x: f32, y: f32, z: f32) -> Option<[f32; 3]> {
    let cx = m[0] * x + m[4] * y + m[8] * z + m[12];
    let cy = m[1] * x + m[5] * y + m[9] * z + m[13];
    let cz = m[2] * x + m[6] * y + m[10] * z + m[14];
    let cw = m[3] * x + m[7] * y + m[11] * z + m[15];
    (cw > 1e-5).then(|| [((cx / cw + 1.0) * 0.5) * w as f32, ((1.0 - cy / cw) * 0.5) * h as f32, cz / cw])
}

// ---------------------------------------------------------------- the generic scripts' VFX

/// port: vfx.lisp VFX-SOUL-FLAME — the red soul flame over a Kikon-able victim (x y z its base; AGE bobs it).
pub(crate) fn vfx_soul_flame(c: &mut Ctx, x: f32, y: f32, z: f32, age: f32) {
    use crate::fx::shapes::{flow01, flow_ph, toon_a, toon_ribbon, Toon, PAL_BLOOD, PAL_HIT, TOON_FLAME};
    let y = y + 0.05 * f_sin(3.0 * age);
    let (fp, seed) = (flow_ph(c.clock), 11.0);
    let h = 0.9 + 0.12 * flow01(c.clock, 0.0, 2.7);
    let lean = 0.08 * (flow01(c.clock, 0.0, 4.1) - 0.5);
    let k = toon_a(PAL_BLOOD + TOON_FLAME, 0.95);
    toon_ribbon(c, [x, y, z], [lean, h, 0.0], 0.22, 0.0, &Toon { ph: 2.0 * fp, sway: 0.07, ..Toon::new(-seed, k) });
    toon_ribbon(c, [x + 0.1, y + 0.05, z], [0.1 + lean, 0.55 * h, 0.0], 0.1, 0.0, &Toon { ph: 1.0 + fp, sway: 0.05, segs: 4, ..Toon::new(-3.0 - seed, k) });
    let k2 = toon_a(PAL_HIT + TOON_FLAME, 0.95);
    toon_ribbon(c, [x, y + 0.04, z], [0.5 * lean, 0.5 * h, 0.0], 0.035, 0.0, &Toon { wob: 0.1, ph: 2.0 * fp, sway: 0.03, segs: 3, ..Toon::new(-5.0 - seed, k2) });
}

/// port: vfx.lisp VFX-RAIN — the K.O.'s rain round (CX CZ), AGE s since it began, K presence.
pub(crate) fn vfx_rain(c: &mut Ctx, cx: f32, cz: f32, age: f32, k: f32) {
    use crate::fx::shapes::{drawing_no, fx_shard, hash01, sage, tring, PAL_HIT};
    let a = sage(c.clock, age, 3.0);
    let dr = drawing_no(c.clock, 8.0);
    let l = f_sqrt(1.0 + 0.0225 + 0.0025);
    let (dx, dy, dz) = (0.15 / l, -1.0 / l, 0.05 / l);
    for i in 0..110 {
        let f = i as f32;
        let y = 9.0 - duel_sim::math::f_mod(9.0 * hash01(f, 1.3) + 14.0 * a, 9.0);
        fx_shard(c, cx + 14.0 * (hash01(f, 2.7) - 0.5), y + 0.2, cz + 14.0 * (hash01(f, 5.9) - 0.5), dx, dy, dz, 0.9, 0.018, 0.0, f, PAL_HIT, k, 0.0);
    }
    for i in 0..10 {
        let f = i as f32 + 10.0 * dr;
        tring(c, cx + 12.0 * (hash01(f, 3.3) - 0.5), 0.0, cz + 12.0 * (hash01(f, 7.1) - 0.5), 0.12, 0.02, PAL_HIT, 0.9 * k, f, 12);
    }
}

// ---------------------------------------------------------------- the cinematic camera

/// camera.lisp's cinematic knobs (tuning.json): `*pt-cine-fov*`, `*pt-dolly-max*`, `*cine-keep*`, `*pt-cine-keep*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CineCamKnobs {
    pub pt_cine_fov: f32,
    pub pt_dolly_max: f32,
    pub keep: f32,
    pub pt_keep: f32,
    /// The rig's pelvis joint (%KEEP-SUBJECT's `(ji :pelvis)`).
    pub pelvis: usize,
}

impl CineCamKnobs {
    pub fn new(d: &duel_data::Data) -> CineCamKnobs {
        let k = |n: &str| duel_data::tuning::knob::<f32>(&d.tuning, n).unwrap_or_else(|e| panic!("{e}"));
        CineCamKnobs {
            pt_cine_fov: k("*PT-CINE-FOV*"),
            pt_dolly_max: k("*PT-DOLLY-MAX*"),
            keep: k("*CINE-KEEP*"),
            pt_keep: k("*PT-CINE-KEEP*"),
            pelvis: crate::rig::joint_index(&d.rig, "pelvis"),
        }
    }
}

impl Scene<'_> {
    /// port: camera.lisp DUEL-CAMERA's `*cine-cam*` branch: the punch-in's clock, the shot's eye and target, %PORTRAIT-DOLLY on a tall
    /// window, %KEEP-SUBJECT, `*cam-cut*`; the dutch roll (%ROLL-UP) or the world's up; the camera placed and updated.
    pub(crate) fn cine_camera(&mut self, rdt: f32) {
        let aspect = self.aspect();
        let d = &mut self.draw;
        d.cam.punch_t = max_f32(0.0, d.cam.punch_t - rdt);
        (d.cam.eye, d.cam.at) = (self.cine.eye, self.cine.target);
        if self.portrait_p() {
            self.portrait_dolly(aspect);
        }
        self.keep_subject(aspect);
        let d = &mut self.draw;
        d.cam.cut = true;
        let (e, c) = (d.cam.eye, d.cam.at);
        if self.cine.dutch != 0.0 {
            // port: camera.lisp %ROLL-UP
            let (fx, fz) = (c[0] - e[0], c[2] - e[2]);
            let l = f_max(1e-4, f_hypot(fx, fz));
            let r = self.cine.dutch * 0.017453292;
            let s = f_sin(r);
            d.camera.up = [s * (-fz / l), f_cos(r), s * (fx / l)];
        } else {
            d.camera.up = [0.0, 1.0, 0.0];
        }
        (d.camera.pos, d.camera.target) = (e, c);
        d.camera.update(aspect);
    }

    /// port: camera.lisp %PORTRAIT-DOLLY — a portrait shot's lens at least `*pt-cine-fov*`, no shift, the eye backed off the target to
    /// hold a landscape frame's middle (a close-up keeps the script's lens and eye), kept inside the arena ring.
    fn portrait_dolly(&mut self, aspect: f32) {
        let kn = self.cine_knobs;
        let rr = self.draw.knobs.max_r;
        let (lens, close) = (self.cine.lens_fov, self.cine.close);
        let d = &mut self.draw;
        let (e, at) = (d.cam.eye, d.cam.at);
        let clamp = crate::fx::shapes::f_clamp;
        let fov = if close { lens } else { f_max(lens, 0.017453292 * kn.pt_cine_fov) };
        let mut k = if close { 1.0 } else { clamp((f_sin(0.5 * lens) / f_cos(0.5 * lens)) / (aspect * (f_sin(0.5 * fov) / f_cos(0.5 * fov))), 1.0, kn.pt_dolly_max) };
        let (vx, vy, vz) = (e[0] - at[0], e[1] - at[1], e[2] - at[2]);
        let (ex, ez) = (at[0] + k * vx, at[2] + k * vz);
        if ex * ex + ez * ez > rr * rr {
            let a = vx * vx + vz * vz;
            let b = at[0] * vx + at[2] * vz;
            let cc = (at[0] * at[0] + at[2] * at[2]) - rr * rr;
            let disc = b * b - a * cc;
            k = if a > 1e-6 && disc >= 0.0 { clamp((-b + f_sqrt(disc)) / a, 1.0, k) } else { 1.0 };
        }
        d.cam.eye = [at[0] + k * vx, at[1] + k * vy, at[2] + k * vz];
        d.cam.pt_lens = true;
        if d.camera.fov != fov {
            d.camera.fov = fov;
        }
        if d.camera.shift_y != 0.0 {
            d.camera.shift_y = 0.0;
        }
    }

    /// port: camera.lisp %KEEP-SUBJECT — slide the eye and target sideways so the SHOT-ON's subject's posed pelvis (its last drawn
    /// joints) stays within `*cine-keep*` of the frame's half-width at his depth.
    fn keep_subject(&mut self, aspect: f32) {
        let Some(e) = self.cine.subject else { return };
        let Some(md) = self.model(e) else { return };
        let kn = self.cine_knobs;
        let pel = md.joints[kn.pelvis];
        let keep = if aspect < 1.0 { kn.pt_keep } else { kn.keep };
        let d = &mut self.draw;
        let (eye, at) = (d.cam.eye, d.cam.at);
        let (dx, dz) = (at[0] - eye[0], at[2] - eye[2]);
        let l = f_hypot(dx, dz);
        if l > 1e-3 {
            let (ux, uz) = (dx / l, dz / l);
            let (sx, sz) = (pel[12] - eye[0], pel[14] - eye[2]);
            let depth = sx * ux + sz * uz;
            let side = sz * ux - sx * uz;
            let fov = d.camera.fov;
            let lim = keep * depth * aspect * (f_sin(0.5 * fov) / f_cos(0.5 * fov));
            let sh = if side > lim { side - lim } else if side < -lim { side + lim } else { 0.0 };
            if depth > 0.3 && sh != 0.0 {
                let (mx, mz) = (-(sh * uz), sh * ux);
                d.cam.eye[0] += mx;
                d.cam.eye[2] += mz;
                d.cam.at[0] += mx;
                d.cam.at[2] += mz;
            }
        }
    }
}

/// port: engine/lisp/cine.lisp CINE-DRAW's look half: the running script's DURING forms, drawn into the frame (DRAW-SCENE's place).
pub struct CineDraw<'a, 'd> {
    pub sc: &'a mut Scene<'d>,
    pub out: &'a mut FrameOut,
    /// CINE-DT: 0 while the effects are frozen, else the frame's real seconds.
    pub dt: f32,
}

impl CineLook for CineDraw<'_, '_> {
    fn forms(&mut self, m: &mut Match, name: CineName, cf: i64, a: Entity, v: Entity, _step: bool) {
        self.sc.cine_during(m, name, cf, a, v, self.out, self.dt);
    }
}

impl CineLook for Scene<'_> {
    /// CINE-STEP's inline call (ruling R9): the step's immediate calls still queued first (in the Lisp they were made before the script
    /// ran), then the script's step-mode look forms.
    fn forms(&mut self, m: &mut Match, name: CineName, cf: i64, a: Entity, v: Entity, _step: bool) {
        self.apply_calls(m);
        self.cine_at(m, name, cf, a, v);
    }
}
