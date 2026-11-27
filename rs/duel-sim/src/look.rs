//! The sim's looks, told through a queue (docs/bevy/M3A_NOTES.md §4). Every presentation call the Lisp makes inside the sim (a clip,
//! a model slot, a cinematic's look, a sound, a camera cut, an EMIT for FEEDBACK-SYSTEM) is a `LookEvent` pushed onto `Match.looks`
//! at its `// look:` site. `flow::sim_step` hands the queue to a `LookSink` at FEEDBACK-SYSTEM's place (main.lisp SIM-STEP: after
//! GOD-UPDATE / PROBE-UPDATE, before HASH-LOG and MC-FULL-STEP); the sink drains it and reads the live state, never writes the match.
//! The sim reads nothing back, so its results are those of a run with no sink at all.
//!
//! - **Two kinds of call.** The Lisp applies a model / clip / camera / sound call at once (inside the step's systems) and queues an EMIT
//!   on `*events*` for FEEDBACK-SYSTEM. Both go into the one queue in program order; a sink applies every non-`Emit` event in order,
//!   then every `Emit` in order (`LookQueue::calls`, `LookQueue::events`), which is the Lisp's order: the calls during the systems,
//!   then DO-EVENTS oldest first.
//! - **Pre-step state rides in the payload.** A call that reads what a later system moves (SLOW-SNAPSHOT's places, a cinematic AT's
//!   actors before the script's sim forms, an EMIT's captured point, PLAY-CLIP's kit) carries what it read; the sink reads live state
//!   only where FEEDBACK-SYSTEM does.
//! - **A rollout is mute.** `Match::look` does nothing while `in_rollout` (rollout.lisp WITH-ROLLOUT: SIM-STEP-LEAN runs no feedback and
//!   drops `*events*`; the restore puts back the ECS, whose MODEL holds the clip, and the cinematic roots, sim-state.lisp 19-52), and
//!   SIM-STEP-LEAN's TAKE-EVENTS is `NoLook`.
use crate::cine::CineName;
use crate::components::Burst;
use crate::ecs::Entity;
use crate::state::Match;
use duel_data::Kit;

/// A kit by reference (equal when it is the same kit of the data; printed by its name).
#[derive(Clone, Copy)]
pub struct KitRef(pub &'static Kit);
impl PartialEq for KitRef {
    fn eq(&self, o: &KitRef) -> bool {
        std::ptr::eq(self.0, o.0)
    }
}
impl std::fmt::Debug for KitRef {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}/{}", self.0.character, self.0.form)
    }
}

/// One EMIT (feedback.lisp's header lists them): the event's data as the emitter captured it.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Event {
    /// `(:swing e kind)`: KIND the move's `mv-kind`.
    Swing { e: Entity, kind: &'static str },
    Super { e: Entity },
    Breaker { e: Entity },
    BreakerEnd { e: Entity },
    Rush { e: Entity },
    RushDash { e: Entity },
    KikonFollow { att: Entity, def: Entity },
    Step { e: Entity },
    /// `(:hit att def x y z hitstop counter-p dmg kind)`.
    Hit { att: Entity, def: Entity, x: f32, y: f32, z: f32, hs: i64, counter: bool, dmg: i64, kind: &'static str },
    Blocked { att: Entity, def: Entity, x: f32, y: f32, z: f32 },
    Armored { def: Entity, x: f32, y: f32, z: f32 },
    Absorbed { def: Entity, x: f32, y: f32, z: f32 },
    GuardCrush { att: Entity, def: Entity, x: f32, y: f32, z: f32 },
    GuardBack { e: Entity },
    GuardBreak { att: Entity, def: Entity, x: f32, y: f32, z: f32 },
    StanceBreak { att: Entity, def: Entity, x: f32, y: f32, z: f32 },
    Clash { x: f32, y: f32, z: f32 },
    Parried { att: Entity, def: Entity, x: f32, y: f32, z: f32 },
    /// `(:refused e cmd)`.
    Refused { e: Entity, cmd: crate::fighter::Cmd },
    SpBreak { att: Entity, def: Entity, take: f32, gain: f32 },
    HazardCut { x: f32, y: f32, z: f32 },
    HohoOut { e: Entity, x: f32, z: f32 },
    HohoIn { e: Entity, x: f32, z: f32 },
    Perfect { e: Entity, victim: Entity },
    Burst { e: Entity, attacker: Entity, mode: Burst },
    BurstEnd { e: Entity },
    Launch { e: Entity },
    Land { e: Entity },
    Konpaku { victim: Entity, lost: i64 },
    Kikon { att: Entity, victim: Entity },
    SoulBreak { att: Entity, victim: Entity },
    Awaken { e: Entity },
    Form { e: Entity, form: crate::components::Form },
    Evolution { e: Entity },
    /// `(:sfx key e)`: KEY the sound's keyword name (lower case, no colon, as the data names keywords).
    Sfx { key: &'static str, e: Entity },
    /// `(:ground-scar x z yaw ds r)`: DS the first N of `ds` (the Lisp's list: at most six in the data).
    GroundScar { x: f32, z: f32, yaw: f32, ds: [f32; 6], n: u8, r: f32 },
    Reset,
    /// `(:ken-bk-burst e kind)`: KIND `chigiri-draw` … `tategoto-cut`, `bankai`.
    KenBkBurst { e: Entity, kind: &'static str },
    Bankai { e: Entity },
}

/// A look call at a `// look:` site (M3A_NOTES §4's table names the Lisp call of each). `Copy`: no heap in the queue.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum LookEvent {
    // ---- the model (fighter.lisp SPAWN-FIGHTER / REFRESH-LOOK; MODEL's slots)
    /// SPAWN-FIGHTER's MAKE-MODEL (body of KIT, the mirror tint / rim of a mirror match's P2) and MAKE-BLADE.
    Model { e: Entity, kit: KitRef, mirror: bool },
    /// REFRESH-LOOK: body, weapon, hidden parts of KIT (the fighter's kit at the call), alpha 1.
    RefreshLook { e: Entity, kit: KitRef },
    /// `(setf (model-alpha (model e)) a)`.
    Alpha { e: Entity, a: f32 },
    /// ICHIGO PARRY-WATCH's rim: `Some(level)` = `(parry-rim k)`'s level 0-7 (the model's rim saved first), `None` = the saved rim back.
    Rim { e: Entity, parry: Option<u8> },
    // ---- the clip player (fighter.lisp PLAY-CLIP, MAIN-PHASE-STEP, RECOVERY-PACE, FIGHTER-STEP)
    /// PLAY-CLIP of CLIP on E with ANIM-PLAY's keywords; KIT the fighter's kit at the call (its :look-clips and the fallback stance).
    Clip { e: Entity, clip: &'static str, kit: KitRef, blend: f32, speed: f32, time: f32, restart: bool },
    /// `(setf (anim-speed …) speed)` (a pre-roll's clip back at its own speed on the hit pose).
    AnimSpeed { e: Entity, speed: f32 },
    /// RECOVERY-PACE past `S + A` outside a cinematic: RF the steps left (this one included), SPD the move's clip speed; it reads the
    /// clip player (the sink's).
    RecoveryPace { e: Entity, rf: f32, spd: f32 },
    /// ANIM-ADVANCE by DT (FIGHTER-STEP's +STEP+).
    AnimAdvance { e: Entity, dt: f32 },
    // ---- slow motion drawn smooth (main.lisp SLOW-SNAPSHOT, before PILOT-SYSTEM / SIM-SYSTEMS)
    /// SLOW-SNAPSHOT's start (its CLRHASH past 48 entries); a `SlowKeep` per fighter, then per hazard, follows.
    SlowSnapshot,
    /// SLOW-SNAPSHOT's KEEP: where E stood before this sim frame.
    SlowKeep { e: Entity, x: f32, y: f32, z: f32, yaw: f32 },
    // ---- cinematics (engine/lisp/cine.lisp, duel/lisp/cinema.lisp)
    /// START-CINE's looks (`*grade-split*` 0, `*cine-cam*` NIL) of NAME with actors A V.
    CineStart { name: CineName, a: Entity, v: Entity },
    /// CINE-BEGIN's looks (caption, lens, close-up flags).
    CineBegin { name: CineName, a: Entity, v: Entity },
    /// The script NAME's look forms at frame CF (AT on a step, the step-mode call): PRE the actors' x y z yaw before the script ran
    /// (its sim forms move them in the same frame).
    CineAt { name: CineName, cf: i64, a: Entity, v: Entity, pre: [[f32; 4]; 2] },
    /// `*cine-actor-hook*` (CINE-ACTOR-STEP): E's clip advances +STEP+ x `*cine-time-scale*`.
    CineActorStep { e: Entity },
    /// END-CINE's looks (`*cine-cam*` NIL, the grade reset).
    CineStop,
    /// CINE-END's looks (caption out, card, grade, dutch, fov, aura, draw scale, time scale, camera up, silhouette, UI flash, screen
    /// fx, STAGE-ENV).
    CineEndLook,
    /// `(setf *cam-cut* t)` (CINE-STAGE, SET-CAM-BEHIND).
    CamCut,
    // ---- the flow (flow.lisp)
    /// PLAY-MUSIC of TRACK (its keyword name) at GAIN.
    Music { track: &'static str, gain: f32 },
    /// MUSIC-STOP over FADE seconds (`*music*` NIL).
    MusicStop { fade: f32 },
    /// CLEAR-WORDS (START-MATCH).
    ClearWords,
    /// FX-CLEAR (SPAWN-PAIR).
    FxClear,
    /// STAGE-CLEAR-CRACKS (SPAWN-PAIR).
    StageClearCracks,
    /// BEGIN-BATTLE's `(duel-camera *p1* *p2* 0.0 :snap t)`, with what it reads of the sim then (a debug command may move the
    /// fighters before the sink applies it: PLACE after ENSURE-BATTLE): P1's and P2's places, `*behind-yaw*`, `*view-x*` / `*view-z*`,
    /// `*view-behind*`; HURT their bodies' hurt radii (BEHIND-CAMERA keeps the eye out of them).
    CameraSnap { p: [f32; 3], q: [f32; 3], hurt: [f32; 2], behind_yaw: f32, view_x: f32, view_z: f32, view_behind: bool },
    /// debug PLACE's looks: FX-CLEAR, `*punch-t*` 0, both models' flash and super 0.
    Place,
    // ---- a direct effect call inside the sim
    /// UI-FLASH r g b alpha fade (ICHIGO-CATCH).
    UiFlash { r: f32, g: f32, b: f32, a: f32, fade: f32 },
    // ---- EMIT
    Emit(Event),
}

/// `Match.looks`: the queue (`*events*` and the immediate calls, in program order).
#[derive(Clone, Debug, Default, PartialEq)]
pub struct LookQueue {
    pub v: Vec<LookEvent>,
}

/// The queue's reserve: one step's looks (it drains every step).
pub const LOOK_RESERVE: usize = 512;

impl LookQueue {
    pub fn with_reserve() -> LookQueue {
        LookQueue { v: Vec::with_capacity(LOOK_RESERVE) }
    }
    /// Queue EV (the caller's mute rule: `Match::look`).
    pub fn push(&mut self, ev: LookEvent) {
        self.v.push(ev);
    }
    /// Every event, oldest first, the queue emptied after (TAKE-EVENTS / DO-EVENTS).
    pub fn drain(&mut self) -> std::vec::Drain<'_, LookEvent> {
        self.v.drain(..)
    }
    pub fn clear(&mut self) {
        self.v.clear();
    }
    /// The immediate calls, in order (a sink's first pass).
    pub fn calls(&self) -> impl Iterator<Item = &LookEvent> {
        self.v.iter().filter(|e| !matches!(e, LookEvent::Emit(_)))
    }
    /// The EMITs, oldest first (a sink's second pass: DO-EVENTS).
    pub fn events(&self) -> impl Iterator<Item = &Event> {
        self.v.iter().filter_map(|e| if let LookEvent::Emit(ev) = e { Some(ev) } else { None })
    }
    /// port: engine/lisp/ecs.lisp TAKE-EVENTS as SPAWN-PAIR calls it: `*events*` dropped. The immediate calls stay (the Lisp made them
    /// already).
    pub fn take_events(&mut self) {
        self.v.retain(|e| !matches!(e, LookEvent::Emit(_)));
    }
    /// The immediate calls dropped, the EMITs kept (`LookSink::frame`'s end).
    pub fn take_calls(&mut self) {
        self.v.retain(|e| matches!(e, LookEvent::Emit(_)));
    }
}

/// What reads the looks: called by `flow::sim_step` at FEEDBACK-SYSTEM's place, once per sim step. It drains `m.looks` and reads the
/// state; it writes nothing else of the match.
pub trait LookSink {
    fn step(&mut self, m: &mut Match);
    /// The frame's start, inside `flow::frame` after its debug commands and before FLOW-UPDATE and the steps (main.lisp GAME-FRAME's
    /// SCREEN-FX-UPDATE place; the commands arrive between the Lisp's frames, so a pause they set already holds here). RDT the frame's
    /// real seconds. The default does nothing.
    fn frame_begin(&mut self, _m: &Match, _rdt: f32) {}
    /// Before the draw, after the frame's steps: the immediate calls still queued (a debug command's, a frame that ran no step: the
    /// Lisp made them at once, before this frame's draw) applied and removed; the EMITs stay for the next step's FEEDBACK-SYSTEM. The
    /// default drops the calls.
    fn frame(&mut self, m: &mut Match) {
        m.looks.take_calls();
    }
}

/// No looks (the headless tools, a rollout's SIM-STEP-LEAN): the queue cleared.
pub struct NoLook;
impl LookSink for NoLook {
    fn step(&mut self, m: &mut Match) {
        m.looks.clear();
    }
}

impl Match {
    /// Push EV unless this is a rollout's match (`*in-rollout*`: its looks never happen in the Lisp).
    pub fn look(&mut self, ev: LookEvent) {
        if !self.in_rollout {
            self.looks.push(ev);
        }
    }
    /// `(emit …)`.
    pub fn emit(&mut self, ev: Event) {
        self.look(LookEvent::Emit(ev));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn step(e: u32) -> LookEvent {
        LookEvent::Emit(Event::Step { e: Entity(e) })
    }

    /// tests/ecs-test.lisp's event-queue checks (lines 26-37) on `LookQueue`: TAKE-EVENTS oldest first and then empty; DO-EVENTS
    /// oldest first, one clause per kind, and then empty.
    #[test]
    fn ecs_test_lisp_events() {
        let mut q = LookQueue::with_reserve();
        q.push(LookEvent::Emit(Event::Land { e: Entity(1) }));
        q.push(step(3));
        assert_eq!(q.drain().collect::<Vec<_>>(), [LookEvent::Emit(Event::Land { e: Entity(1) }), step(3)]); // line 27
        assert_eq!(q.drain().count(), 0); // line 28
        q.push(LookEvent::Emit(Event::Kikon { att: Entity(1), victim: Entity(2) }));
        q.push(step(3));
        q.push(LookEvent::Emit(Event::Reset));
        q.push(LookEvent::Emit(Event::Launch { e: Entity(9) }));
        let out: Vec<String> = q
            .drain()
            .map(|ev| match ev {
                LookEvent::Emit(Event::Kikon { att, victim }) => format!("kikon {} {}", att.0, victim.0),
                LookEvent::Emit(Event::Step { e }) => format!("step {}", e.0),
                LookEvent::Emit(Event::Reset) => "reset".into(),
                other => format!("else {other:?}"),
            })
            .collect();
        assert_eq!(out, ["kikon 1 2", "step 3", "reset", "else Emit(Launch { e: Entity(9) })"]); // line 36
        assert!(q.v.is_empty()); // line 37
    }

    /// SPAWN-PAIR's TAKE-EVENTS drops the EMITs only; the two passes keep program order.
    #[test]
    fn take_events_keeps_calls() {
        let mut q = LookQueue::with_reserve();
        q.push(step(1));
        q.push(LookEvent::FxClear);
        q.push(step(2));
        q.push(LookEvent::CamCut);
        assert_eq!(q.calls().copied().collect::<Vec<_>>(), [LookEvent::FxClear, LookEvent::CamCut]);
        assert_eq!(q.events().copied().collect::<Vec<_>>(), [Event::Step { e: Entity(1) }, Event::Step { e: Entity(2) }]);
        q.take_events();
        assert_eq!(q.v, [LookEvent::FxClear, LookEvent::CamCut]);
    }
}
