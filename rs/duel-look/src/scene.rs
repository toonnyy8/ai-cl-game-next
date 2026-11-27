//! The look side's state and its per-step sink (docs/bevy/M3A_NOTES.md §4): `Scene` drains `Match.looks` at FEEDBACK-SYSTEM's place
//! (`flow::sim_step`) and keeps what the Lisp keeps in MODEL and the look globals: the model slots and clip player per fighter
//! (engine/lisp/anim.lisp, duel/lisp/fighter.lisp PLAY-CLIP / REFRESH-LOOK), SLOW-SNAPSHOT's places, the cinematic time scale, the
//! cosmetic RNG. It reads the match and never writes it (only the queue it drains).
use crate::anim::Anim;
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
    /// `*coarse*`, `*one-hand*`, `*scene-scale-cap*` (the phone's; a desktop window: NIL NIL 1.0).
    pub coarse: bool,
    pub one_hand: bool,
    pub scene_scale_cap: f32,
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
}

impl<'d> Scene<'d> {
    pub fn new(data: &'d Data, inputs: SceneInputs) -> Scene<'d> {
        Scene { data, inputs, models: Vec::with_capacity(8), slow_was: Vec::with_capacity(duel_sim::consts::MAX_ENTITIES), cine_time_scale: 1.0, cos: CosRng::default() }
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
                // port: SPAWN-FIGHTER's MAKE-MODEL (+ MAKE-BLADE: the blade's trail is Task 7's): the slot's earlier model goes
                self.models.retain(|m| m.e.slot() != e.slot());
                self.models.push(Model {
                    e,
                    body: &kit.body,
                    weapon: "",
                    hide: &[],
                    alpha: 1.0,
                    tint: mirror,
                    rim: if mirror { Rim::Mirror } else { Rim::None },
                    rim_saved: None,
                    anim: Anim::default(),
                });
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
            LookEvent::CamCut | LookEvent::CameraSnap => {} // task 7: the camera
            LookEvent::Music { .. } | LookEvent::MusicStop { .. } => {} // M3b: sound
            LookEvent::ClearWords => {}                                  // task 8: the canvas words
            LookEvent::FxClear | LookEvent::StageClearCracks | LookEvent::UiFlash { .. } => {} // task 6: FX
            LookEvent::Emit(_) => {}                                     // (the second pass)
        }
    }

    /// An EMIT (the sink's second pass: FEEDBACK-SYSTEM's DO-EVENTS, oldest first). Task 6 ports feedback.lisp.
    fn event(&mut self, _m: &Match, _ev: &Event) {}
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

    fn frame(&mut self, m: &mut Match) {
        for ev in m.looks.calls() {
            self.call(ev);
        }
        m.looks.take_calls();
    }
}
