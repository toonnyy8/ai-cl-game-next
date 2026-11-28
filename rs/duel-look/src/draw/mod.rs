//! The draw core (docs/bevy/M3A_NOTES.md §5): a rendered frame's picture as the arrays `r_frame` gets (`FrameOut`), made by
//! `draw_frame` in GAME-FRAME's order after the steps (duel/lisp/main.lisp GAME-FRAME, draw.lisp DRAW-SCENE, render.lisp END-FRAME).
pub mod camera;
pub mod fighter;
pub mod frame;
pub mod ichigo;
pub mod ken;
pub mod queue;
pub mod slow;
pub mod stage;

pub use frame::FrameOut;

use crate::scene::Scene;
use camera::{CamKnobs, CamState, Camera, Pair};
use duel_sim::components::Flow;
use duel_sim::ecs::Entity;
use duel_sim::state::Match;
use crate::fx::{self, Ctx};
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
    /// cinema.lisp `*impact-presets*`.
    pub presets: crate::fx::screen::Presets,
    /// draw.lisp `*form-grade*`: the form grade preset shown now (FORM-GRADE).
    pub form_grade: Option<&'static str>,
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
            presets: crate::fx::screen::Presets::new(d),
            form_grade: None,
        }
    }
}

/// port: flow.lisp BATTLE-P.
fn battle_p(m: &Match) -> bool {
    matches!(m.flow, Flow::Intro | Flow::Battle | Flow::Finish)
}

/// port: draw.lisp CINE-HELD-P — a debug-held cinematic stands at its hold frame.
pub fn cine_held_p(m: &Match) -> bool {
    m.cine.as_ref().is_some_and(|c| c.hold.is_some_and(|h| c.cf >= h))
}

/// port: draw.lisp FX-FROZEN-P — effect time stops: paused, a held beat (FREEZE, `*screen-fx*`[6]), or a debug-held cinematic at
/// its hold frame (CINE-HELD-P).
fn fx_frozen_p(sc: &Scene, m: &Match) -> bool {
    m.paused || sc.draw.screen_fx[6] > 0.0 || cine_held_p(m)
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

    /// port: camera.lisp DUEL-CAMERA (A = P1, B = P2 as PR gives them): a cinematic's shot (`Scene::cine_camera`, the caller's), the portrait camera (a tall
    /// window, whatever the mode) or the landscape ones. A path not ported yet sets `unported` (the page shows it) and leaves the camera where it was.
    pub(crate) fn duel_camera(&mut self, pr: &Pair, rdt: f32, snap: bool) {
        let aspect = self.aspect();
        let d = &mut self.draw;
        if self.inputs.height > self.inputs.width {
            let i = &self.inputs;
            let v = camera::View { w: i.width, h: i.height, density: i.density, safe_top: i.safe_top, safe_bottom: i.safe_bottom };
            camera::duel_camera_portrait(&mut d.cam, &mut d.camera, &d.knobs, pr, rdt, snap, &v);
            return;
        }
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
        if sc.cine.cam {
            sc.cine_camera(fdt);
        } else {
            let pr = sc.pair(m);
            sc.duel_camera(&pr, fdt, false);
        }
    } else {
        sc.unported_camera.get_or_insert("the menus' camera (camera.lisp MENU-CAMERA: M3b)");
    }
    {
        let d = &mut sc.draw;
        camera::shake_update(&mut d.cam, &mut d.camera, &d.knobs, &mut sc.cos, fdt);
    }
    let aspect = sc.aspect();
    sc.draw.camera.update(aspect);
    if !m.turbo {
        let cdt = if fx_frozen_p(sc, m) { 0.0 } else { rdt }; // (CINE-DT: unscaled)
        draw_scene(sc, m, fdt, cdt, out);
        // HUD-DRAW unless turbo: its first form, AURA-CAP-UPDATE (hud-screens.lisp), sets the next frame's `*aura-cap*` from the drawn
        // places (before SLOW-DRAW-END; ruling R4), then its canvas part (`canvas.rs`); the Lisp HUD it draws next is M3b
        let alive = |e: Entity| m.ents.alive(e) && m.fighter.get(e).is_some();
        let pq = (alive(m.p1) && alive(m.p2)).then(|| (sc.drawn_pos(m, m.p1), sc.drawn_pos(m, m.p2)));
        crate::fx::vfx::aura_cap_update(&mut sc.fx.aura_cap, pq);
        sc.hud_canvas(m, out, cdt); // (the canvas part of HUD-DRAW: its HUD-DT is CINE-DT's; the Lisp HUD is M3b)
    }
    slow::end(sc, m);
    end_frame(sc, out);
}

/// port: draw.lisp DRAW-SCENE (RDT the effect seconds; CDT a cinematic DURING's CINE-DT).
fn draw_scene(sc: &mut Scene, m: &mut Match, rdt: f32, cdt: f32, out: &mut FrameOut) {
    // (*scene-transparent*: SELECT's, M3b; *no-draw*: debug 2120+, not ported); a card beat hides the stage
    if sc.cine.card.is_none() {
        let d = &mut sc.draw;
        let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
        stage::stage_draw(&mut c, &d.stage_meshes, &mut d.stage, rdt);
    }
    if m.cine.is_none() {
        sc.draw.post.grade_desat = 0.0;
        form_grade(sc, m);
    }
    // (*no-draw*: debug 2120+, not ported); a card beat's one actor (*card-only*)
    let sides = fighter::Sides::of(sc, m);
    for (i, e) in sides.e.into_iter().enumerate() {
        if sides.alive[i]
            && sc.cine.card_only.is_none_or(|o| o == e)
            && let Some(u) = fighter::draw_fighter(sc, m, e, &sides, rdt, out)
        {
            sc.unported.get_or_insert(u);
        }
    }
    {
        // HAZARD-DRAW (*no-draw*: debug 2120+, not ported)
        let d = &mut sc.draw;
        let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
        let kn = c.fx.ken;
        let slow = &sc.slow;
        let at = |e: Entity| slow.at.iter().find(|a| a.0 == e).map(|a| a.1);
        let mut bodies = ichigo::HzBodies { models: &sc.models, fl: &mut sc.fl, data: sc.data };
        if let Some(u) = fx::hazard::hazard_draw(&mut c, m, &kn, at, &mut bodies, rdt) {
            sc.unported.get_or_insert(u);
        }
    }
    duel_sim::cine::cine_draw(m, &mut crate::cine::CineDraw { sc: &mut *sc, out: &mut *out, dt: cdt }); // (CINE-DRAW, its looks inline: R9)
    let d = &mut sc.draw;
    let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
    if let Some(u) = fx::stamps::stamps_draw(&mut c, rdt) {
        sc.unported.get_or_insert(u);
    }
    // (*impact-next*: only the retired NOME ladder's :rung queues one)
    if c.fx.stamps.burst_flag > 0.0 {
        // a Burst ring fired: its beat (a negative frame, the white back-rim)
        c.fx.stamps.burst_flag = 0.0;
        fx::screen::impact_frame(d, "negative", 1.0);
        fx::screen::back_rim(d, 3.0);
    }
    let mut c = Ctx { out: &mut *out, cam: &d.camera, cos: &mut sc.cos, fx: &mut sc.fx, clock: d.post.fx_clock };
    c.fx.update(rdt);
    fx::draw_particles(&mut c);
    fx::rings_update(&mut c, rdt);
    fx::vfx::lights_flush(&mut c);
}

/// port: draw.lisp FORM-GRADE — a form's world grade (kit :grade :spot: the composite's spot-keep mode 4) while the form is on, else
/// mode 0; an impact frame owns the composite while it runs. (No Kenpachi / Ichigo kit has a grade; Yamamoto's Bankai does.)
fn form_grade(sc: &mut Scene, m: &Match) {
    let spot = |e: Entity| m.ents.alive(e) && duel_sim::fighter::kit_of(m, e).grade.as_deref() == Some("spot");
    let want = (spot(m.p1) || spot(m.p2)).then_some("spot");
    let mode = if want.is_some() { 4 } else { 0 };
    let d = &mut sc.draw;
    if d.screen_fx[0] <= 0.0 && (d.post.grade_impact != mode || want != d.form_grade) {
        d.form_grade = want;
        match want {
            Some(k) => fx::screen::impact_frame(d, k, 0.0),
            None => d.post.grade_impact(0),
        }
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
