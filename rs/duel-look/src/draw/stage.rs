//! port: duel/lisp/stage.lisp STAGE-DRAW — the plaza, the walls, the town and the burnt ruins (four toon draws at the identity), then
//! the falling ash (ST-ASH-FX). The cracks, the marks and the chips (ST-DRAW-CRACKS, ST-DRAW-MARKS, ST-CHIPS) are Task 6's.
use super::frame::FrameOut;
use super::queue::{draw_mesh, DrawOpts};
use crate::CosRng;

/// The stage's four meshes (STAGE-INIT's `*st-floor*` `*st-walls*` `*st-town*` `*st-burnt*`), by their registry paths.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct StageMeshes {
    pub floor: u32,
    pub walls: u32,
    pub town: u32,
    pub burnt: u32,
}

impl StageMeshes {
    /// From duel-data's mesh registry (tables.json `mesh_ids`, the frozen image's ids).
    pub fn new(d: &duel_data::Data) -> StageMeshes {
        let ids = d.mesh_ids();
        let id = |p: &str| ids.iter().find(|r| r.1 == p).unwrap_or_else(|| panic!("mesh {p}: not in the registry")).0;
        StageMeshes { floor: id("*ST-FLOOR*"), walls: id("*ST-WALLS*"), town: id("*ST-TOWN*"), burnt: id("*ST-BURNT*") }
    }
}

/// duel/lisp/body.lisp `*toon-ground*`: the toon lanes of things lying on the stage (mode 1, full fog).
pub const TOON_GROUND: [f32; 4] = [1.0, 0.0, 1.0, 0.0];
/// stage.lisp `*st-toon-far*`: the ruins' lanes (mode 1, less fog than the plaza's).
const TOON_FAR: [f32; 4] = [1.0, 0.0, 0.6, 0.0];
const IDENTITY: [f32; 16] = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0];

/// stage.lisp's per-frame state: `*st-acc*` (the ash's emission accumulator), `*stage-fx*`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct StageState {
    pub acc: f32,
    pub fx: bool,
}

impl Default for StageState {
    fn default() -> Self {
        StageState { acc: 0.0, fx: true }
    }
}

/// port: stage.lisp STAGE-DRAW (RDT the frame's effect seconds; TG the camera target).
pub fn stage_draw(out: &mut FrameOut, ids: &StageMeshes, st: &mut StageState, cos: &mut CosRng, tg: [f32; 3], rdt: f32) {
    let ground = DrawOpts { toon: Some(TOON_GROUND), ..DrawOpts::default() };
    let far = DrawOpts { toon: Some(TOON_FAR), ..DrawOpts::default() };
    draw_mesh(out, ids.floor, &IDENTITY, &ground);
    draw_mesh(out, ids.walls, &IDENTITY, &far);
    draw_mesh(out, ids.town, &IDENTITY, &far);
    draw_mesh(out, ids.burnt, &IDENTITY, &far);
    if st.fx {
        st_ash_fx(st, cos, tg, rdt);
    }
    // task 6: ST-DRAW-CRACKS, ST-DRAW-MARKS (the toon stream), ST-CHIPS (their dq records)
}

/// port: stage.lisp ST-ASH-FX — white ash drifting down around the camera target, 10 flakes a second (ST-EVERY), each one FX-EMIT
/// of a feather with its six cosmetic draws in argument order.
fn st_ash_fx(st: &mut StageState, cos: &mut CosRng, tg: [f32; 3], dt: f32) {
    let mut rnd = |a: f32, b: f32| a + (b - a) * cos.rnd01();
    st.acc += 10.0 * dt;
    while st.acc >= 1.0 {
        st.acc -= 1.0;
        let (x, y, z) = (tg[0] + rnd(-12.0, 12.0), rnd(5.0, 9.0), tg[2] + rnd(-12.0, 12.0));
        let (vx, vy, vz) = (rnd(0.1, 0.3), rnd(-0.3, 0.0), rnd(-0.2, 0.2));
        // task 6: FX-EMIT +P-FEATHER+ x y z vx vy vz 6 0.06 1 0.93 0.94 0.96 into the particle pool (it draws nothing more)
        let _ = (x, y, z, vx, vy, vz);
    }
}
