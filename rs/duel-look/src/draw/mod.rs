//! The draw core (docs/bevy/M3A_NOTES.md §5): a rendered frame's picture as the arrays `r_frame` gets (`FrameOut`), made by
//! `draw_frame` in GAME-FRAME's order after the steps (duel/lisp/main.lisp GAME-FRAME, draw.lisp DRAW-SCENE, render.lisp END-FRAME).
pub mod camera;
pub mod frame;
pub mod queue;
pub mod slow;
pub mod stage;

pub use frame::FrameOut;

use crate::scene::Scene;
use camera::{CamKnobs, CamState, Camera, Pair};
use duel_sim::components::Flow;
use duel_sim::ecs::Entity;
use duel_sim::state::Match;
use crate::fx::{self, vfx::AuraIn, Ctx};
use frame::{Env, Post};
use stage::{StageMeshes, StageState};

/// The draw side's state in `Scene`: the render camera, camera.lisp's state and knobs, the environment and the post globals, the
/// stage's, and `*screen-fx*` (cinema.lisp; its writers are Tasks 6 / 8).
pub struct DrawState {
    pub camera: Camera,
    pub cam: CamState,
    pub knobs: CamKnobs,
    pub env: Env,
    pub post: Post,
    pub stage: StageState,
    pub stage_meshes: StageMeshes,
    pub screen_fx: [f32; 8],
}

impl DrawState {
    /// The state at START-GAME (STAGE-ENV applied).
    pub fn new(d: &duel_data::Data) -> DrawState {
        let mut env = Env::default();
        env.stage_env();
        DrawState {
            camera: Camera::default(),
            cam: CamState::default(),
            knobs: CamKnobs::new(d),
            env,
            post: Post::new(d),
            stage: StageState::default(),
            stage_meshes: StageMeshes::new(d),
            screen_fx: [0.0; 8],
        }
    }
}

/// port: flow.lisp BATTLE-P.
fn battle_p(m: &Match) -> bool {
    matches!(m.flow, Flow::Intro | Flow::Battle | Flow::Finish)
}

/// port: main.lisp FX-FROZEN-P — effect time stops: paused, a held beat (FREEZE, `*screen-fx*`[6]), or a debug-held cinematic at
/// its hold frame (CINE-HELD-P: task 8, no Rust cinematic holds yet).
fn fx_frozen_p(sc: &Scene, m: &Match) -> bool {
    m.paused || sc.draw.screen_fx[6] > 0.0
}

impl Scene<'_> {
    /// WINDOW-ASPECT.
    pub fn aspect(&self) -> f32 {
        self.inputs.width as f32 / self.inputs.height.max(1) as f32
    }

    /// E's place as this frame draws it: SLOW-DRAW's drawn place while the sim is slowed, else the sim's.
    pub fn drawn_pos(&self, m: &Match, e: Entity) -> [f32; 3] {
        match self.slow.at.iter().find(|a| a.0 == e) {
            Some((_, a)) => [a[0], a[1], a[2]],
            None => duel_sim::fighter::pos_of(m, e),
        }
    }

    /// E's yaw as this frame draws it (see `drawn_pos`).
    pub fn drawn_yaw(&self, m: &Match, e: Entity) -> f32 {
        match self.slow.at.iter().find(|a| a.0 == e) {
            Some((_, a)) => a[3],
            None => duel_sim::fighter::yaw_of(m, e),
        }
    }

    /// port: camera.lisp DUEL-CAMERA (A = P1, B = P2 as PR gives them): a cinematic's shot (task 8), the portrait camera (task 7) or
    /// the landscape ones. A path not ported yet sets `unported` (the page shows it) and leaves the camera where it was.
    pub(crate) fn duel_camera(&mut self, pr: &Pair, rdt: f32, snap: bool) {
        if self.inputs.height > self.inputs.width {
            self.unported.get_or_insert("the portrait camera (camera.lisp %PORTRAIT-CAMERA: task 7)");
            return;
        }
        let aspect = self.aspect();
        let d = &mut self.draw;
        camera::duel_camera_landscape(&mut d.cam, &mut d.camera, &d.knobs, pr, rdt, snap, aspect);
    }

    /// DUEL-CAMERA's reads of the live match, at the places this frame draws.
    fn pair(&self, m: &Match) -> Pair {
        let (a, b) = (m.p1, m.p2);
        Pair {
            p: self.drawn_pos(m, a),
            q: self.drawn_pos(m, b),
            hurt: [duel_sim::fighter::hurt_r(m, a), duel_sim::fighter::hurt_r(m, b)],
            behind_yaw: m.behind_yaw,
            view_x: m.view_x,
            view_z: m.view_z,
            view_behind: m.view_behind,
        }
    }
}

/// port: GAME-FRAME after its steps, then END-FRAME (duel/lisp/main.lisp 133-149, engine/lisp/render.lisp END-FRAME): SLOW-DRAW-BEGIN,
/// the effect seconds (FDT), the fx clock, the camera (DUEL-CAMERA, SHAKE-UPDATE), DRAW-SCENE unless turbo, SLOW-DRAW-END, then the
/// post parameters, the lights and the frame uniforms into OUT. RDT is the frame's real seconds (the one `flow::frame` stepped by).
/// M is `&mut` only for DRAW-SCENE's CINE-DRAW (a script's DURING forms move the actors: DIVERGENCES §1); nothing else writes it.
/// The live match only: a CPU rollout never draws.
pub fn draw_frame(sc: &mut Scene, m: &mut Match, rdt: f32, out: &mut FrameOut) {
    out.begin(); // (BEGIN-FRAME's queues; its UPDATE-CAMERA is redone below before anything reads the camera)
    // dev: the menus' idle clips (ANIM-ADVANCE by RDT when the sim does not run) are the page's (ruling R10: Task 10 / M3b)
    slow::begin(sc, m);
    let fdt = if fx_frozen_p(sc, m) { 0.0 } else if sc.cine_time_scale == 1.0 { rdt } else { rdt * sc.cine_time_scale };
    sc.draw.post.fx_clock += fdt; // (FX-CLOCK-ADVANCE)
    sc.draw.camera.shift_x = 0.0;
    if battle_p(m) {
        if m.cine.is_some() {
            sc.unported.get_or_insert("a cinematic's camera (cinema.lisp's shots: task 8)");
        } else {
            let pr = sc.pair(m);
            sc.duel_camera(&pr, fdt, false);
        }
    } else {
        sc.unported.get_or_insert("the menus' camera (camera.lisp MENU-CAMERA: M3b)");
    }
    {
        let d = &mut sc.draw;
        camera::shake_update(&mut d.cam, &mut d.camera, &d.knobs, &mut sc.cos, fdt);
    }
    let aspect = sc.aspect();
    sc.draw.camera.update(aspect);
    if !m.turbo {
        draw_scene(sc, m, fdt, out);
        // HUD-DRAW (M3b) unless turbo; its first form, AURA-CAP-UPDATE (hud-screens.lisp), sets the next frame's `*aura-cap*` from
        // the drawn places (before SLOW-DRAW-END), HUD or not (ruling R4)
        let alive = |e: Entity| m.ents.alive(e) && m.fighter.get(e).is_some();
        let pq = (alive(m.p1) && alive(m.p2)).then(|| (sc.drawn_pos(m, m.p1), sc.drawn_pos(m, m.p2)));
        crate::fx::vfx::aura_cap_update(&mut sc.fx.aura_cap, pq);
    }
    slow::end(sc, m);
    end_frame(sc, out);
}

/// port: draw.lisp DRAW-SCENE (RDT the effect seconds).
fn draw_scene(sc: &mut Scene, m: &mut Match, rdt: f32, out: &mut FrameOut) {
    // (*scene-transparent*: SELECT's, M3b; *no-draw*: debug 2120+, not ported; a card beat: task 8)
    {
        let d = &mut sc.draw;
        let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
        stage::stage_draw(&mut c, &d.stage_meshes, &mut d.stage, rdt);
    }
    if m.cine.is_none() {
        sc.draw.post.grade_desat = 0.0;
        form_grade(sc, m);
    }
    for e in [m.p1, m.p2] {
        if m.ents.alive(e) && m.fighter.get(e).is_some() {
            // task 7: DRAW-FIGHTER's body, weapon, blade, hooks before its auras
            let Some(md) = sc.model(e) else { continue };
            let a = AuraIn { e, p: sc.drawn_pos(m, e), body: md.body, alpha: md.alpha, aura_off: false }; // (*aura-off*: task 8)
            let d = &mut sc.draw;
            let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
            if let Some(u) = fx::vfx::fighter_auras(&mut c, m, &a, rdt) {
                sc.unported.get_or_insert(u);
            }
        }
    }
    // task 6: HAZARD-DRAW
    duel_sim::cine::cine_draw(m); // (CINE-DRAW: task 8 adds the look hook here, ruling R9)
    let d = &mut sc.draw;
    let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
    // task 6: STAMPS-DRAW; task 8: the queued impact frame and the Burst beat
    c.fx.update(rdt);
    fx::draw_particles(&mut c);
    fx::rings_update(&mut c, rdt);
    fx::vfx::lights_flush(&mut c);
}

/// port: draw.lisp FORM-GRADE — a form's world grade (kit :grade :spot, the composite's mode 4) while the form is on; else mode 0.
/// No Kenpachi / Ichigo kit has a grade (Yamamoto's Bankai does: M4, `unported`).
fn form_grade(sc: &mut Scene, m: &Match) {
    let spot = |e: Entity| m.ents.alive(e) && duel_sim::fighter::kit_of(m, e).grade.as_deref() == Some("spot");
    let want = spot(m.p1) || spot(m.p2);
    if want {
        sc.unported.get_or_insert("a form's :spot grade (IMPACT-FRAME: M4)");
    } else if sc.draw.screen_fx[0] <= 0.0 && sc.draw.post.grade_impact != 0 {
        sc.draw.post.grade_impact(0); // (*form-grade* stays NIL: no in-scope kit sets it)
    }
}

/// port: render.lisp END-FRAME: UPDATE-CAMERA, `*rp*`, SELECT-LIGHTS, FILL-FRAME-UNIFORMS (`r_frame` is the caller's: OUT is its
/// arguments).
fn end_frame(sc: &mut Scene, out: &mut FrameOut) {
    let aspect = sc.aspect();
    let inp = sc.inputs;
    let d = &mut sc.draw;
    d.camera.update(aspect);
    frame::fill_post(out, &d.env, &mut d.post, inp.width, inp.height, inp.render_scale, inp.scene_scale_cap);
    let nl = frame::select_lights(out, &d.camera);
    frame::fill_frame_uniforms(out, &d.env, &d.post, &d.camera, nl, inp.pixel_lights, inp.msaa);
}
