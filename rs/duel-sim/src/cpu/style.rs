//! The style CPUs' registry (ruling R1): a style function's Lisp name (`*cai-styles*`, a strategy's :FN) to its port. A style runs
//! on every step its CPU is free to press, before the generic CPU, and says whether it decided this step.
use super::{perceive::Snap, Brain, Search};
use crate::ecs::Entity;
use crate::state::Match;

/// A style function: (e b f kit s d) -> T when it decided this step. The brain is taken out of its fighter while the CPU steps.
pub type StyleFn = fn(&mut Match, &mut Search, Entity, &mut Brain, Snap, f32) -> bool;

/// The port of the style named NAME (upper case, `KEN-KI-STYLE`), or None (not ported: its caller is `unported!`).
pub fn resolve(_name: &str) -> Option<StyleFn> {
    None // (Kenpachi's: Task 6; Ichigo's: Task 7; Hisagi's: M4)
}
