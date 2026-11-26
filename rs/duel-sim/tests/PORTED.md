# Lisp host-test checks ported to Rust

Per Lisp test file: its checks (as its own runner counts them), ported, deferred (with the milestone). Each task adds its rows.

| Lisp test | Checks | Ported | Where | Deferred |
|---|---|---|---|---|
| `tests/input-test.lisp` | 33 | 26 | `rs/duel-sim/src/vpad.rs` tests (7 fns) | 7, M2: the device read through bindings (`vpad-read!`, `inputs-down-p`; 5 per-frame checks + the chord + the diagonal stick) is the app's input layer |
| `tests/ecs-test.lisp` | 12 | 8 | `rs/duel-sim/src/ecs.rs` `ecs_test_lisp` (spawn / getters / slot order / remove / destroy / slot reuse with a new generation / NIL handle / clear → top 0) | 4, not ported: the event queue (`emit` / `take-events` / `do-events`) only feeds the look side (feedback, sound): M3 if a look needs it |
