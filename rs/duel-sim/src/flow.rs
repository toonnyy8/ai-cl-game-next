//! port: main.lisp's frame and flow (ENGINE::%FRAME's sim part). Task 6 in progress: only the input interface is here;
//! `frame` is still unported (see the Task 6 report for what remains).
use crate::state::Match;

/// Where the pilots' vpads get their input: `read` is the vpad reader (PILOT-SYSTEM after VPAD-BEGIN-STEP!, and PILOT-READ
/// without it), `step_end` is `*step-hook*`.
pub trait PilotInput {
    fn read(&mut self, m: &mut Match, side: usize);
    fn step_end(&mut self, m: &mut Match);
}

/// port: ENGINE::%FRAME's sim part at rdt 1/60. False when the engine would stop.
pub fn frame(m: &mut Match, _input: &mut dyn PilotInput) -> bool {
    crate::unported!(m, "%frame", false)
}
