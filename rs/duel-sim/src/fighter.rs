//! port: duel/lisp/fighter.lisp — creation (SPAWN-FIGHTER), HALT!, TO-IDLE. The state machine (FIGHTER-SYSTEM) is Tasks 7-8.
use crate::components::{Character, Fighter, Form, Gauges, KitId, Motion, Pilot, State, Transform};
use crate::ecs::Entity;
use crate::state::Match;
use crate::vpad::Vpad;

/// port: HALT!: E's velocity zeroed.
pub fn halt(m: &mut Match, e: Entity) {
    if let Some(mo) = m.motion.get_mut(e) {
        mo.vel = [0.0; 3];
    }
}

/// port: SPAWN-FIGHTER: SIDE's fighter playing CHARACTER's :base kit at (X 0 Z) facing YAW; CPU seats get a brain
/// (`has_brain`: its difficulty and delay are the CPU's, M2) and no device reader (`cam_relative` false).
pub fn spawn_fighter(m: &mut Match, side: i64, character: Character, x: f32, z: f32, yaw: f32, cpu: bool) -> Entity {
    let kit = crate::kit::find_kit(m.data, &character.name().to_lowercase(), "base");
    let e = m.spawn();
    m.transform.insert(e, Transform { pos: [x, 0.0, z], yaw });
    m.motion.insert(e, Motion::default());
    // look: model (body, mirror tint / rim), blade
    m.fighter.insert(
        e,
        Fighter {
            side,
            character: Some(character),
            kit: Some(KitId { character, form: Form::Base }),
            has_brain: cpu,
            ..Fighter::default()
        },
    );
    let reishi = kit.reishi as i64;
    m.gauges.insert(e, Gauges { reishi, reishi_max: reishi, konpaku: m.knobs.konpaku_max, ..Gauges::new(&m.knobs) });
    let vpad = Vpad::duel(m.data, &m.knobs).unwrap_or_else(|err| panic!("vpad: {err}"));
    m.pilot.insert(e, Pilot { vpad, cam_relative: !cpu });
    // look: refresh-look, the stance clip
    e
}

/// port: TO-IDLE: back to neutral, the combo over (the stance clip is a look).
pub fn to_idle(m: &mut Match, e: Entity) {
    if let Some(f) = m.fighter.get_mut(e) {
        f.state = State::Idle;
        f.sf = 0;
        f.phase = None;
        f.mv = None;
        f.crush = false;
        f.dmg_bonus = 0;
        f.combo_hits = 0;
        f.combo_launches = 0;
        f.combo_air = 0;
        f.combo_from = 0;
        f.cls = None;
        f.presses = 0;
        f.as_done = false;
        f.charge_mult = 1.0;
        f.tmp = 0;
        f.csa = None;
    }
    halt(m, e);
    // look: play-clip of the stance
}

/// FIGHTER-SYSTEM (Tasks 7-8).
pub fn fighter_system(m: &mut Match) {
    crate::unported!(m, "fighter-system")
}
