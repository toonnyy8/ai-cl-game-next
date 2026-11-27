//! The look side's state and its per-step sink (docs/bevy/M3A_NOTES.md §4): `Scene` drains `Match.looks` at FEEDBACK-SYSTEM's place
//! (`flow::sim_step`) and keeps what the Lisp keeps in MODEL and the look globals: the model slots and clip player per fighter
//! (engine/lisp/anim.lisp, duel/lisp/fighter.lisp PLAY-CLIP / REFRESH-LOOK), SLOW-SNAPSHOT's places, the cinematic time scale, the
//! cosmetic RNG. It reads the match and never writes it (only the queue it drains).
use crate::anim::Anim;
use crate::fx::vfx::Trail;
use crate::rig::{Mat4, NJ};
use crate::rng::CosRng;
use duel_data::{Clip, Data, Kit};
use duel_sim::cl::{max_f32, min_f32};
use duel_sim::ecs::Entity;
use duel_sim::look::{Event, KitRef, LookEvent, LookSink};
use duel_sim::state::Match;
use duel_sim::time::STEP;

/// The page's fixed inputs (M3A_NOTES §1 "Fixed inputs"): what the draw key recorded, never constants buried in the port.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SceneInputs {
    /// `pf_width` / `pf_height` (CSS pixels) and `pf_density`.
    pub width: u32,
    pub height: u32,
    pub density: f32,
    /// The MSAA sample count (`r_sample_count`).
    pub msaa: u32,
    /// `*render-scale*`, `*pixel-lights*`.
    pub render_scale: f32,
    pub pixel_lights: u32,
    /// `*coarse*` and `*scene-scale-cap*` (the phone's; a desktop window: NIL, 1.0). `coarse` and `density` are carried but read by
    /// nothing in M3a (the touch deck's, M3b). `*one-hand*` is the sim's: `Match.settings.one_hand` (SET-CAM-BEHIND reads it).
    pub coarse: bool,
    pub scene_scale_cap: f32,
    /// The page's safe-area insets, CSS px (`pf_page_get` +PG-SAFE-TOP+ / -BOTTOM+: 0 on a desktop window and on the recorder):
    /// DECK-UPDATE's `*safe-top*` / `*safe-bot*`, which place the portrait frame (`*band*`).
    pub safe_top: f32,
    pub safe_bottom: f32,
}

/// A sound the looks asked for (feedback.lisp's SFX-AT / SFX-ON / PLAY-SFX, the Breaker hum's START-LOOP / STOP-LOOP, the silence
/// beat's end): collected in `Scene.sounds` for the player (M3b), which reads them after the frame's draw; the next frame's start
/// (`LookSink::frame_begin`) clears them.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum SoundReq {
    /// A positional sound KEY at P.
    At { key: &'static str, p: [f32; 3], gain: f32, pitch: f32 },
    /// PLAY-SFX: KEY unplaced.
    Play { key: &'static str, gain: f32 },
    /// The side's Breaker hum starts (`:breaker-hum`) / stops (0.1 s).
    HumStart { side: usize, gain: f32 },
    HumStop { side: usize },
    /// cinema.lisp SILENCE-END: the music and the sfx bus back to their levels.
    SilenceEnd,
}

/// `Scene.sounds`' bound: a frame's requests past it are dropped (a frame makes a few dozen at most).
pub const SOUNDS_MAX: usize = 256;

/// Push a sound request, dropped past `SOUNDS_MAX` (0 allocations: the vector is reserved once).
pub fn push_sound(v: &mut Vec<SoundReq>, r: SoundReq) {
    if v.len() < SOUNDS_MAX {
        v.push(r);
    }
}

/// MODEL-RIM's value.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Rim {
    None,
    /// `*mirror-rim*` (a mirror match's P2).
    Mirror,
    /// ICHIGO PARRY-RIM's level 0-7.
    Parry(u8),
}

/// A fighter's MODEL: its look slots and its clip player.
#[derive(Clone, Debug)]
pub struct Model<'d> {
    pub e: Entity,
    /// MODEL-BODY's name (the kit's :body; a cinematic may set another: Task 8), MODEL-WEAPON, MODEL-HIDE's tags (HIDE-SET of them).
    pub body: &'d str,
    pub weapon: &'d str,
    pub hide: &'d [String],
    pub alpha: f32,
    /// MODEL-TINT: `*mirror-tint*` when set (a mirror match's P2).
    pub tint: bool,
    pub rim: Rim,
    /// ICHIGO's ICS-RIM while the parry window's rim is up (ICS-RIM-SAVED).
    pub rim_saved: Option<Rim>,
    pub anim: Anim<'d>,
    /// The draw-time slots (components.lisp DEFCOMPONENT MODEL; DRAW-FIGHTER's, the feedback's looks): the posed joints (POSE-FK!), the
    /// hit flash and the SP super flash (real seconds left), the held pose, the one-drawing smear and its ground direction, the
    /// Hoho afterimage's joints and age (< 0: none), the held face and its seconds, the head-back beat, the move frame the last draw
    /// saw, the face drawn last, LOOKS ([0] the grip's ease, [1] the fx clock when the face changed).
    pub joints: [Mat4; NJ],
    pub flash: f32,
    pub sup: f32,
    pub hold: f32,
    pub smear: f32,
    pub smear_dir: [f32; 2],
    pub ghost: [Mat4; NJ],
    pub ghost_age: f32,
    pub face: Face,
    pub face_t: f32,
    pub beat: f32,
    pub last_sf: i64,
    pub face_was: Face,
    pub looks: [f32; 2],
    /// MAKE-BLADE: the sword trail's samples (BLADE-POINTS) and the comet smear held for the drawing (BLADE-SMEAR).
    pub trail: Trail,
    pub blade_smear: [f32; 12],
}

/// An expression (draw.lisp FACE-OF; `*face-hides*`' rows).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Face {
    Neutral,
    Shout,
    Hurt,
}

impl<'d> Model<'d> {
    /// port: fighter.lisp SPAWN-FIGHTER's MAKE-MODEL (the struct's defaults) and MAKE-BLADE.
    fn new(e: Entity, body: &'d str, mirror: bool) -> Model<'d> {
        Model {
            e,
            body,
            weapon: "",
            hide: &[],
            alpha: 1.0,
            tint: mirror,
            rim: if mirror { Rim::Mirror } else { Rim::None },
            rim_saved: None,
            anim: Anim::default(),
            joints: [[0.0; 16]; NJ],
            flash: 0.0,
            sup: 0.0,
            hold: 0.0,
            smear: 0.0,
            smear_dir: [0.0; 2],
            ghost: [[0.0; 16]; NJ],
            ghost_age: -1.0,
            face: Face::Neutral,
            face_t: 0.0,
            beat: 0.0,
            last_sf: -1,
            face_was: Face::Neutral,
            looks: [0.0; 2],
            trail: [0.0; 6 * crate::fx::vfx::TRAIL_N + 1],
            blade_smear: [0.0; 12],
        }
    }
}

/// The look side of one match (and of the page's matches after it: `CosRng` runs on).
pub struct Scene<'d> {
    pub data: &'d Data,
    pub inputs: SceneInputs,
    /// The fighters' models (at most 2 live; a model of a cleared entity stays until its slot is spawned again).
    pub models: Vec<Model<'d>>,
    /// SLOW-SNAPSHOT's `*slow-was*`: entity -> x y z yaw before the last sim frame.
    pub slow_was: Vec<(Entity, [f32; 4])>,
    /// `*cine-time-scale*` (CINE-SLOW: Task 8; CINE-END resets it).
    pub cine_time_scale: f32,
    pub cos: CosRng,
    /// The draw side (camera, environment, post globals, stage): `draw::draw_frame`'s.
    pub draw: crate::draw::DrawState,
    /// SLOW-DRAW's state.
    pub slow: crate::draw::slow::SlowDraw,
    /// The FX state (particles, rings, lights, auras, the stage's marks, stamps).
    pub fx: crate::fx::FxState<'d>,
    /// The sounds asked for since the loop last cleared them (M3b plays them), and feedback.lisp `*hums*` (a Breaker hum runs, per side).
    pub sounds: Vec<SoundReq>,
    pub hums: [bool; 2],
    /// The fighters' draw state outside MODEL (the mesh ids, proportions, knobs, the kits' per-side look state).
    pub fl: crate::draw::fighter::FighterLooks<'d>,
    /// A cinematic's draw scale and aura-off actor (CINE-SCALE, `*aura-off*`: Task 8 writes them).
    pub cine: crate::draw::fighter::CineLooks,
    /// `look_unported`: the first look path this port does not have yet (the page stops the fight and shows it).
    pub unported: Option<&'static str>,
}

impl<'d> Scene<'d> {
    pub fn new(data: &'d Data, inputs: SceneInputs) -> Scene<'d> {
        Scene {
            data,
            inputs,
            models: Vec::with_capacity(8),
            slow_was: Vec::with_capacity(duel_sim::consts::MAX_ENTITIES),
            cine_time_scale: 1.0,
            cos: CosRng::default(),
            draw: crate::draw::DrawState::new(data),
            slow: crate::draw::slow::SlowDraw::with_reserve(),
            fx: crate::fx::FxState::new(data),
            sounds: Vec::with_capacity(SOUNDS_MAX),
            hums: [false; 2],
            fl: crate::draw::fighter::FighterLooks::new(data),
            cine: crate::draw::fighter::CineLooks::default(),
            unported: None,
        }
    }

    pub fn model(&self, e: Entity) -> Option<&Model<'d>> {
        self.models.iter().find(|m| m.e == e)
    }

    fn model_mut(&mut self, e: Entity) -> Option<&mut Model<'d>> {
        self.models.iter_mut().find(|m| m.e == e)
    }

    /// port: fighter.lisp PLAY-CLIP's choice and CLIP-OR-FALLBACK: the form's :look-clips entry, else the body's variant (BODY-CLIPS),
    /// else CLIP; a clip the art lacks falls back to the kit's stance. ponytail: the Lisp's "missing clip" log line (once per name) is
    /// not kept; no in-scope clip is missing.
    fn resolve(&self, body: &str, kit: &'d Kit, clip: &'d str) -> Option<&'d Clip> {
        let data: &'d Data = self.data;
        let name = kit
            .look_clips
            .get(clip)
            .map(|s| s.as_str())
            .or_else(|| data.bodies.get(body).and_then(|b| b.clips.get(clip)).map(|s| s.as_str()))
            .unwrap_or(clip);
        data.clips.get(name).or_else(|| data.clips.get(kit.stance.as_str()))
    }

    /// An immediate call (the sink's first pass, in program order).
    fn call(&mut self, ev: &LookEvent) {
        match *ev {
            LookEvent::Model { e, kit: KitRef(kit), mirror } => {
                // port: SPAWN-FIGHTER's MAKE-MODEL and MAKE-BLADE: the slot's earlier model goes
                self.models.retain(|m| m.e.slot() != e.slot());
                self.models.push(Model::new(e, &kit.body, mirror));
            }
            LookEvent::RefreshLook { e, kit: KitRef(kit) } => {
                if let Some(m) = self.model_mut(e) {
                    (m.body, m.weapon, m.hide, m.alpha) = (&kit.body, &kit.weapon, &kit.hide, 1.0);
                }
            }
            LookEvent::Alpha { e, a } => {
                if let Some(m) = self.model_mut(e) {
                    m.alpha = a;
                }
            }
            LookEvent::Rim { e, parry } => {
                if let Some(m) = self.model_mut(e) {
                    match parry {
                        Some(l) => {
                            if m.rim_saved.is_none() {
                                m.rim_saved = Some(m.rim);
                            }
                            m.rim = Rim::Parry(l);
                        }
                        None => {
                            if let Some(r) = m.rim_saved.take() {
                                m.rim = r;
                            }
                        }
                    }
                }
            }
            LookEvent::Clip { e, clip, kit: KitRef(kit), blend, speed, time, restart } => {
                let Some(body) = self.model(e).map(|m| m.body) else { return };
                if let Some(c) = self.resolve(body, kit, clip) {
                    self.model_mut(e).unwrap().anim.play(c, blend, speed, time, restart);
                }
            }
            LookEvent::AnimSpeed { e, speed } => {
                if let Some(m) = self.model_mut(e) {
                    m.anim.speed = speed;
                }
            }
            LookEvent::RecoveryPace { e, rf, spd } => {
                // port: fighter.lisp RECOVERY-PACE's anim half (the sim checked SF past S + A and no cinematic)
                if let Some(m) = self.model_mut(e)
                    && let Some(c) = m.anim.clip
                    && !c.looping
                {
                    let an = &mut m.anim;
                    let rc = 60.0 * c.dur - 60.0 * an.time;
                    an.speed = if rc <= 0.0 || rf * spd <= rc + 0.5 { max_f32(an.speed, spd) } else { min_f32(spd, rc / rf) };
                }
            }
            LookEvent::AnimAdvance { e, dt } => {
                if let Some(m) = self.model_mut(e) {
                    m.anim.advance(dt);
                }
            }
            LookEvent::SlowSnapshot => {
                if self.slow_was.len() > 48 {
                    self.slow_was.clear(); // (dead hazards' entries)
                }
            }
            LookEvent::SlowKeep { e, x, y, z, yaw } => match self.slow_was.iter_mut().find(|w| w.0 == e) {
                Some(w) => w.1 = [x, y, z, yaw],
                None => self.slow_was.push((e, [x, y, z, yaw])),
            },
            LookEvent::CineActorStep { e } => {
                // port: cinema.lisp CINE-ACTOR-STEP
                let k = self.cine_time_scale;
                if let Some(m) = self.model_mut(e) {
                    m.anim.advance(STEP * k);
                }
            }
            LookEvent::CineEndLook => {
                self.cine_time_scale = 1.0; // task 8: the rest of CINE-END's looks
            }
            LookEvent::CineStart { .. } | LookEvent::CineBegin { .. } | LookEvent::CineAt { .. } | LookEvent::CineStop => {} // task 8
            LookEvent::CamCut => self.draw.cam.cut = true,
            LookEvent::CameraSnap { p, q, hurt, behind_yaw, view_x, view_z, view_behind } => {
                // port: BEGIN-BATTLE's (duel-camera *p1* *p2* 0.0 :snap t), on what the sim held then
                let pr = crate::draw::camera::Pair { p, q, hurt, behind_yaw, view_x, view_z, view_behind };
                self.duel_camera(&pr, 0.0, true);
            }
            LookEvent::Place => {
                self.fx_clear();
                self.draw.cam.punch_t = 0.0; // task 7: the models' flash / super 0
            }
            LookEvent::Music { .. } | LookEvent::MusicStop { .. } => {} // M3b: sound
            LookEvent::ClearWords => {}                                  // task 8: the canvas words
            LookEvent::FxClear => self.fx_clear(),
            LookEvent::StageClearCracks => self.fx.stage.clear_cracks(),
            LookEvent::UiFlash { r, g, b, a, fade } => self.fx.ui_flash = [r, g, b, a, fade],
            LookEvent::Emit(_) => {}                                     // (the second pass)
        }
    }

    /// An EMIT (the sink's second pass: FEEDBACK-SYSTEM's DO-EVENTS, oldest first): fx/feedback.rs.
    fn event(&mut self, m: &Match, ev: &Event) {
        self.feedback(m, ev);
    }

    /// port: engine/lisp/fx.lisp FX-CLEAR — every particle and ring gone, the shake stopped.
    fn fx_clear(&mut self) {
        self.fx.clear();
        self.draw.cam.shake = [0.0; 8];
        self.draw.camera.shake = [0.0; 3];
    }
}

impl LookSink for Scene<'_> {
    fn step(&mut self, m: &mut Match) {
        {
            let m: &Match = m;
            for ev in m.looks.calls() {
                self.call(ev);
            }
            for ev in m.looks.events() {
                self.event(m, ev);
            }
        }
        m.looks.clear();
    }

    /// port: main.lisp GAME-FRAME's first form, SCREEN-FX-UPDATE (cinema.lisp): last frame's impact frames, focus lines and silence
    /// run out by this frame's RDT (0 while paused). Last frame's sound requests are dropped first (the page's player took them after
    /// its draw; they stay readable until here). task 8: a debug-held cinematic (CINE-HELD-P) also stops the screen fx.
    fn frame_begin(&mut self, m: &Match, rdt: f32) {
        self.sounds.clear();
        let dt = if m.paused { 0.0 } else { rdt };
        crate::fx::screen::screen_fx_update(&mut self.draw, &mut self.sounds, dt);
    }

    fn frame(&mut self, m: &mut Match) {
        for ev in m.looks.calls() {
            self.call(ev);
        }
        m.looks.take_calls();
    }
}
