//! port: fighter.lisp "reactions (called by combat.lisp)": the reactions and blockstun, the defender's side of the triangle, the
//! Breaker phase; and the per-state steps that run a reaction (STUN-STEP, AIR-STEP's :air).
use super::*;

/// port: BREAKER-PHASE: E's Breaker phase for BREAKER-CLASH-P: :aura :dash :strike (strike startup / active) or NIL.
pub fn breaker_phase(m: &Match, e: Entity) -> Option<Phase> {
    let f = fighter(m, e);
    let id = current_move(f)?;
    let mvd = mv(m, id);
    if mvd.kind != "breaker" {
        return None;
    }
    match f.phase {
        Some(p @ (Phase::Aura | Phase::Dash)) => Some(p),
        _ => (f.sf < (mvd.s + mvd.a) as i64).then_some(Phase::Strike),
    }
}
