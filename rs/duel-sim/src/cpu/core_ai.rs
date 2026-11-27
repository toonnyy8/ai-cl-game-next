//! port: duel/lisp/core-ai.lisp — the core CPU (Task 4). Task 3 ports CORE-BRAIN-STEP's head: the masher's seat, the vpad's step
//! start (the CPU's reader fires there: the recorder's C split, ruling 1) and the perception; the rest is `unported!` until Task 4.
use super::{perceive, Search};
use crate::ecs::Entity;
use crate::flow::PilotInput;
use crate::state::Match;

/// port: CORE-BRAIN-STEP — one step of the core CPU: perceive, then hold the press in progress, or decide for the state he is in.
pub fn core_brain_step(m: &mut Match, _s: &mut Search, input: &mut dyn PilotInput, e: Entity) {
    if m.fighter.get(e).and_then(|f| f.brain.as_ref()).is_some_and(|b| b.masher) {
        crate::unported!(m, "masher-step") // (masher.lisp, debug 81030+: M5)
    }
    let f = m.fighter.get(e).expect("a fighter");
    let (o, side) = (f.opp, f.side as usize);
    m.pilot.get_mut(e).expect("a pilot").vpad.begin_step();
    input.read(m, side); // (VPAD-BEGIN-STEP!'s reader: none in the game; the recorder's / replayer's mark)
    let (_snap, _d) = perceive::brain_perceive(m, e, o);
    crate::unported!(m, "core-brain-step") // (Task 4: the strategy layer, the rolls, the decision, AI-PRESS-WRITE!)
}
