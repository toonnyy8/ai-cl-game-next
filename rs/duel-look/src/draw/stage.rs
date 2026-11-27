//! port: duel/lisp/stage.lisp STAGE-DRAW — the plaza, the walls, the town and the burnt ruins (four toon draws at the identity), then
//! the falling ash (ST-ASH-FX), the cracks, the marks and the chips (fx/crack.rs).
use super::queue::{draw_mesh, DrawOpts};
use crate::fx::{crack, Ctx, P_FEATHER};

/// The stage's four meshes (STAGE-INIT's `*st-floor*` `*st-walls*` `*st-town*` `*st-burnt*`), by their registry paths.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct StageMeshes {
    pub floor: u32,
    pub walls: u32,
    pub town: u32,
    pub burnt: u32,
    /// `*st-rocks*`: the three chips' (mesh . hull) ids.
    pub rocks: [(u32, u32); 3],
}

impl StageMeshes {
    /// From duel-data's mesh registry (tables.json `mesh_ids`, the frozen image's ids).
    pub fn new(d: &duel_data::Data) -> StageMeshes {
        let ids = d.mesh_ids();
        let id = |p: &str| ids.iter().find(|r| r.1 == p).unwrap_or_else(|| panic!("mesh {p}: not in the registry")).0;
        let rock = |i: usize| (id(&format!("*ST-ROCKS*[{i}][0]")), id(&format!("*ST-ROCKS*[{i}].")));
        StageMeshes { floor: id("*ST-FLOOR*"), walls: id("*ST-WALLS*"), town: id("*ST-TOWN*"), burnt: id("*ST-BURNT*"), rocks: [rock(0), rock(1), rock(2)] }
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

/// port: stage.lisp STAGE-DRAW (RDT the frame's effect seconds).
pub fn stage_draw(c: &mut Ctx, ids: &StageMeshes, st: &mut StageState, rdt: f32) {
    let ground = DrawOpts { toon: Some(TOON_GROUND), ..DrawOpts::default() };
    let far = DrawOpts { toon: Some(TOON_FAR), ..DrawOpts::default() };
    draw_mesh(c.out, ids.floor, &IDENTITY, &ground);
    draw_mesh(c.out, ids.walls, &IDENTITY, &far);
    draw_mesh(c.out, ids.town, &IDENTITY, &far);
    draw_mesh(c.out, ids.burnt, &IDENTITY, &far);
    if st.fx {
        st_ash_fx(c, st, rdt);
    }
    crack::draw_cracks(c);
    crack::draw_marks(c);
    crack::chips(c, &ids.rocks, rdt);
}

/// port: stage.lisp ST-ASH-FX — white ash drifting down around the camera target, 10 flakes a second (ST-EVERY), each one FX-EMIT
/// of a feather with its six cosmetic draws in argument order.
fn st_ash_fx(c: &mut Ctx, st: &mut StageState, dt: f32) {
    let tg = c.cam.target;
    st.acc += 10.0 * dt;
    while st.acc >= 1.0 {
        st.acc -= 1.0;
        let x = tg[0] + c.rr(-12.0, 12.0);
        let y = c.rr(5.0, 9.0);
        let z = tg[2] + c.rr(-12.0, 12.0);
        let (vx, vy, vz) = (c.rr(0.1, 0.3), c.rr(-0.3, 0.0), c.rr(-0.2, 0.2));
        c.fx.emit(P_FEATHER, x, y, z, vx, vy, vz, 6.0, 0.06, 1.0, 0.93, 0.94, 0.96);
    }
}
