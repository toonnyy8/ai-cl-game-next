//! port: duel/lisp/debug.lisp DEBUG-COMMAND, the ranges the gate traces use. Any other code is `unported!("debug N")`.
use crate::components::Character::{Ichigo, Kenpachi};
use crate::gate::{start_cvc, start_pair_gate};
use crate::state::Match;

/// port: DEBUG-COMMAND (`*stats-log*` / `*learn-debug-off*` are the logs' and the learner's; `*cine-hold*` is never set by
/// these commands, so clearing it is moot).
pub fn debug_command(m: &mut Match, c: i64) {
    m.log_on = true;
    // log-msg: "debug cmd C"
    match c {
        2102 => m.turbo = !m.turbo,
        3000..=3999 => start_cvc(m, c - 3000, Some([Ichigo, Ichigo])),
        4000..=4999 => start_cvc(m, c - 4000, Some([Ichigo, Kenpachi])),
        5000..=5999 => start_cvc(m, c - 5000, Some([Kenpachi, Kenpachi])),
        30000..=30999 => m.gate_seed0 = c - 30000,
        31101..=31199 => m.gate_seeds = c - 31100,
        200000..=209999 => start_pair_gate(m, c / 100 % 10, c / 10 % 10),
        // ponytail: leaked once per run, on the path that stops it
        _ => crate::unported!(m, Box::leak(format!("debug {c}").into_boxed_str())),
    }
}
