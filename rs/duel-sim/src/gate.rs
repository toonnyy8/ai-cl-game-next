//! port: duel/lisp/gate.lisp — seeded CPU vs CPU, the pairing gate and GATE-UPDATE. The hash line is hashline.rs; the gate's
//! pacing bookkeeping (cups, pace lines) and its log rows are debug output the sim never reads (not ported).
use crate::components::Character;
use crate::flow::start_match;
use crate::state::{Match, Mode};

/// port: START-CVC: seeded CPU vs CPU; PAIR None draws both from SEED (debug 2000+s: not ported).
pub fn start_cvc(m: &mut Match, seed: i64, pair: Option<[Character; 2]>) {
    m.match_seed = seed;
    m.mode = Mode::CpuCpu;
    // cpu: *difficulty* = *gate-difficulty* (the brains'); *blow-aways* 0 and the pacing resets: the gate's log rows
    m.rng.seed(seed);
    let Some(pair) = pair else { crate::unported!(m, "start-cvc random pairing") };
    m.picks = pair;
    start_match(m);
}

/// port: START-PAIR-GATE: seeds gate-seed0 + 1 .. + gate-seeds of roster C1 against roster C2, back to back.
pub fn start_pair_gate(m: &mut Match, c1: i64, c2: i64) {
    let roster = &m.data.kits.roster;
    let ch = |i: i64| roster.get(i as usize).and_then(|s| Character::from_name(s));
    let (Some(a), Some(b)) = (ch(c1), ch(c2)) else { crate::unported!(m, "start-pair-gate: no such roster slot") };
    (m.turbo, m.skip_cines, m.log_on, m.gate_busy) = (true, false, false, false);
    m.gate_results.clear();
    m.gate = (m.gate_seed0 + 1..=m.gate_seed0 + m.gate_seeds).map(|s| (s, [a, b])).collect();
    gate_update(m);
}

/// port: GATE-UPDATE (per frame): record a finished gate match, start the next, end the gate.
pub fn gate_update(m: &mut Match) {
    if m.gate_busy && m.flow == crate::components::Flow::Results {
        let ko = [m.p1, m.p2].iter().any(|&e| m.gauges.get(e).is_some_and(|g| g.konpaku == 0));
        m.gate_results.push((m.picks, ko));
        // log-msg: the gate row, the evo line, the cups / Ichigo / Hisagi lines
        m.gate_busy = false;
    }
    if !m.gate_busy {
        if let Some((seed, pair)) = m.gate.pop_front() {
            start_cvc(m, seed, Some(pair));
            m.gate_busy = true;
        } else if !m.gate_results.is_empty() {
            // log-msg: the per-pairing summary
            m.gate_results.clear();
            m.turbo = false;
        }
    }
}
