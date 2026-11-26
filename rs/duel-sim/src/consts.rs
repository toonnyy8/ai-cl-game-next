//! The sim-side defconstants, hand-ported (the extractor reads defparameters only; M0_NOTES §3). mcts-lite.lisp's ten are CPU
//! code (M2).

/// port: engine/lisp/input.lisp +NO-PRESS+ -1000000 (a press stamp: "no unconsumed press").
pub const NO_PRESS: i64 = -1_000_000;
/// port: duel/lisp/rules.lisp +PI+ `#.(float pi 1f0)`.
pub const PI: f32 = std::f32::consts::PI; // 0x40490FDB
/// port: duel/lisp/rules.lisp +TWO-PI+ `#.(float (* 2 pi) 1f0)` (also ANGLE-WRAP's TAU).
pub const TWO_PI: f32 = std::f32::consts::TAU; // 0x40C90FDB
/// port: engine/lisp/ecs.lisp +MAX-ENTITIES+ 256 (a handle = slot + 256 x generation).
pub const MAX_ENTITIES: usize = 256;
/// port: engine/lisp/ecs.lisp +MAX-COMPONENT-KINDS+ 64.
pub const MAX_COMPONENT_KINDS: usize = 64;
