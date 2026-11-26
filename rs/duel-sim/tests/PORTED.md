# Lisp host-test checks ported to Rust

Per Lisp test file: its checks (as its own runner counts them), ported, deferred (with the milestone). Each task adds its rows.

| Lisp test | Checks | Ported | Where | Deferred |
|---|---|---|---|---|
| `tests/input-test.lisp` | 33 | 26 | `rs/duel-sim/src/vpad.rs` tests (7 fns) | 7, M2: the device read through bindings (`vpad-read!`, `inputs-down-p`; 5 per-frame checks + the chord + the diagonal stick) is the app's input layer |
| `tests/ecs-test.lisp` | 12 | 8 | `rs/duel-sim/src/ecs.rs` `ecs_test_lisp` (spawn / getters / slot order / remove / destroy / slot reuse with a new generation / NIL handle / clear → top 0) | 4, not ported: the event queue (`emit` / `take-events` / `do-events`) only feeds the look side (feedback, sound): M3 if a look needs it |
| `tests/duel-rules/sp.lisp` | 75 | 70 | `rs/duel-sim/tests/sp.rs` (`sp_spending` lines 4-75: 56; `hit_px_sp_scale` lines 81-82: 2; `kit_sp_costs` lines 125, 133, 139-149: 12, the line-125 loop over the Kenpachi / Ichigo kits only) | 5: line 78 not ported (its 0.6d0 row makes HIT-PX a double; the sim's one caller, combat.lisp, passes singles); lines 114, 116, 119, 122 (the `*sp-table*` per-route cost table, rows for Hisagi included) deferred M4 |
| `tests/duel-rules/triangle.lisp` | 142 | 67 | `rs/duel-sim/tests/triangle.rs` (core.lisp's verdict / cancel / exchange / pointer checks, lines 6-104, the 12-row verdict `dolist` counting once; `first-land-p` lines 44-47) | 75 not in Task 5: the kit-data checks (Ichigo / Kenpachi / Hisagi moves, segments, stances, clips, `core-charge-mult`, `fighter-stance-clip`) are not ported yet: Ichigo / Kenpachi rows go with Tasks 7/8/12, Hisagi rows M4, `clip-n` M3 |
| `tests/duel-rules/core.lisp` | 309 | 40 | `rs/duel-sim/tests/core.rs` (`frames` lines 58, 90-96, 98-99, 103: 11 (line 103's contact T is passed as `:block`: T is not :hit, so CHAIN-OPEN-P gives it the block timing); `damage` lines 192, 195, 206-213, 217-218, 220, 222, 226: 15; `kikon_and_time_up` lines 283-289, 299-302, 304-306: 14) | 269 not triaged in Task 5 (context budget): the rest of the file spans fighter / combat / gauges / round / CPU / PRACTICE; lines 215 (`kit-atk-mods`), 216 and 219 (`*chip-fire*`, `*hellfire-burn*`: not sim knobs) are known open |
| `tests/duel-rules/systems.lisp` | 13 | 1 | `rs/duel-sim/tests/core.rs` `systems_lisp` (line 16) | 12 not triaged in Task 5 |

Counting: `grep -c '(check ' tests/duel-rules/<file>.lisp` (a `dolist` / `loop` / multi-line check counts once).
