//! port: duel/lisp/core-sim.lisp — the core system's side of the sim (DUEL_CORE): what the two buttons start, the triangle's verdicts
//! applied, the SP pointer, the Kikon hold and its cancel. Pure rules are core.rs'.
use crate::components::Fighter;
use crate::core::core_seg_dead_p;
use crate::sp::{sp_exchange_open_p, sp_neutral_p};
use crate::state::Match;

/// port: CORE-DEAD-P (research R3: never while *CORE-CANCEL-DEAD* is off, nothing marks one).
pub fn core_dead_p(f: &Fighter) -> bool {
    core_seg_dead_p(f.mv, f.cls_t, f.dead_mv, f.dead_t)
}

/// port: CORE-XCH-STEP: an open exchange ends at the first step both fighters are back in neutral, or when a cinematic has begun.
pub fn core_xch_step(m: &mut Match) {
    let (Some(a), Some(b)) = (m.fighter.get(m.p1), m.fighter.get(m.p2)) else { return };
    let sliding = |e| m.motion.get(e).is_some_and(|mo| mo.kb_left > 0);
    if sp_exchange_open_p(a.xch, b.xch)
        && (m.cine.is_some() || (sp_neutral_p(a.state, sliding(m.p1)) && sp_neutral_p(b.state, sliding(m.p2))))
    {
        for e in [m.p1, m.p2] {
            let f = m.fighter.get_mut(e).unwrap();
            (f.xch, f.xch_done) = (-1, false);
        }
        crate::clog!(m, "exchange over");
    }
}
