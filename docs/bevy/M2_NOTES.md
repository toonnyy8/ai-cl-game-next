# M2 notes: the CPU in the Rust port

The working notes of M2 (the plan: `docs/bevy/plans/2026-11-27-m2-cpu.md`). Each task adds its section; M1's are in `M1_NOTES.md`.

## 1. The snapshot boundary (Task 2)

A Lisp rollout (cpu-mcts.lisp MC-FULL-ROLL, strategy-glue.lisp STRAT-ROLL) puts back only what SIM-SNAPSHOT reaches from its roots:
the engine's (`engine/lisp/snapshot.lisp:24`: `*stores*` `*used*` `*generation*` `*top*` `*hitstop*` `*tick*` `*slowmo*` `*cine*`)
and the game's (`duel/lisp/sim-state.lisp:11-25`). The port keeps the same split. Whatever the roots reach lives in `Match` (cloned
for a rollout, restored with `clone_from`). Every other global the CPU writes at runtime lives in `cpu::Search`, which a restore never
touches. A job's scores survive the restore. `strat-full-step` writes `brain-strat` after the restore and the write stays. A stand-in
brain added inside a rollout goes with the restore.

The census below covers every global that
`grep -n 'setf \*\|incf \*\|push .* \*' duel/lisp/{cpu-*,core-ai,xch-ai,strategy*,mcts-lite,fq-online}.lisp` finds. It also covers
the other runtime-written `defvar` / `defparameter` in those files (a script over each symbol's write sites, `setf (aref …)` and
`fill` included) and in the `// cpu:` call sites (`flow.rs`, `gate.rs`). Line numbers are at `lisp-freeze`.

### Roots: in `Match`

| Global | Written at runtime | Root? | Rust home |
|---|---|---|---|
| the BRAIN component | the CPU, every step (cpu-perceive, core-ai, strategy-glue …); MC-FULL-ROLL / STRAT-ROLL add a stand-in brain in a rollout | yes: an ECS store, `*stores*` (snapshot.lisp:24) | `Fighter.brain: Option<cpu::Brain>` |
| the PILOT component (vpad, `cam-relative`) | the brains' presses; MC-FULL-ROLL sets `cam-relative` NIL with the stand-in | yes: `*stores*` | `Match.pilot` (M1) |
| `*mc-plan*` (cpu-mcts.lisp:44) | 160, 174, 189, 193, 236 (inside the rollout: its planned action), 251, 267 | yes (sim-state.lisp:15) | `Match.mc_plan: [i64; 10]` |
| `*mc-next*` (cpu-mcts.lisp:113) | 137 (MC-NEUTRAL's deferral) | yes (sim-state.lisp:15) | `Match.mc_next: [i64; 2]` (MC-FULL-RESET does not reset it) |
| `*blow-aways*` (combat.lisp:11) | combat.lisp:205 (the sim); gate.lisp:87 (START-CVC, `// cpu:` in gate.rs) | yes (sim-state.lisp:12) | not ported: only the gate's log rows read it (gate.lisp:149) |

### Not roots, written by the CPU: in `Search`

| Global | Written at runtime (why never inside a rollout) | Root? | Rust home |
|---|---|---|---|
| `*mc-jobs*` (cpu-mcts.lisp:47) | 165 MC-FULL-REQUEST (reached only past MC-NEUTRAL's `(when *in-rollout* (return-from mc-neutral nil))`, 125); 193 MC-FULL-RESET; 251, 259, 265 MC-FULL-STEP (`(not *in-rollout*)`, 249) | no | `Search.mc_jobs` (each job's snapshot, slot 5: Task 8's preallocated slot) |
| `*mc-full-stats*` (cpu-mcts.lisp:48) | 166, 193, 263, 271 (the same guards) | no | `Search.mc_stats` |
| `*strat-jobs*` (strategy.lisp:255) | strategy-glue.lisp:206 STRAT-REQUEST (STRAT-LAYER-STEP's `(not *in-rollout*)`, 212); 239, 248 STRAT-FULL-STEP (MC-FULL-STEP's guard, 248); cpu-mcts.lisp:194 | no | `Search.strat_jobs` (STJOB-SNAP: Task 8) |
| `*strat-stats*` (strategy.lisp:256) | strategy-glue.lisp:207, 246, 255; cpu-mcts.lisp:194 | no | `Search.strat_stats` |
| `*strat-picks*` (strategy.lisp:257) | strategy.lisp:4437 (sized at load); strategy-glue.lisp:253 (after STRAT-FULL-STEP's restore); cpu-mcts.lisp:194 | no | `Search.strat_picks` (sized by the strategy layer's task) |
| `*fq-tables*` (fq-online.lisp:16) | fq-online.lisp:32 FQ-TABLE (from FQ-ATTACH! at START-MATCH); 37 FQ-RESET-ALL (SETTINGS); debug.lisp:578 (debug 2504) | no | `Search.fq_tables` (Task 9) |
| the page (PAGE-GET / PAGE-SET; the recorder's `ENGINE::*ORACLE-PAGE*`) | fq-online.lisp:40, 85-86 (FQ-RESET-ALL; FQ-MATCH-END from GO-RESULTS, which returns at once in a rollout, flow.lisp:189) | no | `Search.page: BTreeMap<i64, i64>` (M3 persists it) |
| `*cai-switch-counts*` (core-ai.lisp:339) | 343 `(unless *in-rollout* (incf …))` | no | `Search` (a log counter; the field comes with the task that ports CAI's switch count) |
| the light search's scratch: `*mc-g*` `*mc-w*` `*mc-legal*` `*mc-legal2*` `*mc-slots*` `*mc-i*` `*mc-f*` `*mc-vals*` `*mc-n*` `*mc-sum*` `*mc-n2*` `*mc-sum2*` (mcts-lite.lisp:113-128), `*mc-ws*` (cpu-mcts.lisp:112) | MC-SETUP (cpu-mcts.lisp:67-110), MC-SEED (mcts-lite.lisp:137), MC-SEARCH (`fill`, 309), MC-NEUTRAL: all past the return at cpu-mcts.lisp:125, so never in a rollout; each is rewritten at a search's start (`*mc-g*`[2], the search stream, is reseeded by MC-SEED at 129) | no | preallocated scratch for Task 8 (`Search` or the light model's own); never read across searches |
| `*mc-recs*` (mcts-lite.lisp:79) | 86 MC-MOVE-REC (from MC-SETUP, past the guard): a cache keyed by MOVE, a shared definition | no | Task 8: a table built from the data, or a `Search` cache (a pure function of the move) |

### Not roots, not CPU state: configuration, bindings, tools

| Global | Written | Rust home |
|---|---|---|
| `*difficulty*` (flow.lisp:27) | the menu (flow.lisp:255), START-CVC (gate.lisp:87), debug 2504; read at SPAWN-PAIR | `Match.difficulty` (configuration, as `mode` / `picks`) |
| `*gate-difficulty*` (gate.lisp:83) | debug 81020+ (not ported) | `Match.gate_difficulty` (always NORMAL until that command ports) |
| `*learn-debug-off*` (fq-online.lisp:8) | debug.lisp:478 and debug 2504 | Task 9 (FQ-ATTACH!'s test) |
| `*fq-learn-force*` (fq-online.lisp:17) | tools only (strat-run.lisp) | Task 9 (a tool's flag) |
| `*masher-seats*` (masher.lisp:75) | debug 81030+ | M5 (MASHER-APPLY! runs with no seat) |
| `*cai-styles*` (core-ai.lisp:25) | CAI-DEFSTYLE at load (28); `let`-bound NIL by MC-FULL-ROLLOUT (cpu-mcts.lisp:218), undone on exit | the style registry (`cpu::style::resolve`, data); the rollout's binding is a rollout flag (Task 8) |
| WITH-ROLLOUT's bindings (rollout.lisp:13): `*in-rollout*` `*log-mute*` `*pacing-log*` `*combat-log*` `*gate-log*` `*step-hook*` `*skip-cines*` | `let`-bound around every rollout, undone on exit | the rollout driver (Task 8); `pacing_log` / `log_on` / `skip_cines` are `Match` fields, so the restore puts them back as the unbinding does |
| `*strat-judge-hook*` (strategy-glue.lisp:100), `*cai-xch-hook*` (core-ai.lisp:201) | tools only (NIL in the game) | not ported |

The grep also lists knobs that sit on a line with a `setf` but are only read: `*cai-ranged-gap*` `*cai-think*` `*fq-unit*`, the
styles' `*iks-*` `*ikw-roll-p*` `*ir2-*` `*khf-bait-p*` `*kk-*`, `*mc-defer-gap*` `*mc-full-h*` `*mc-opp-delay*` `*mc-prior*`
`*mc-react-p*` `*strat-library*` `*strat-period*` `*strat-rolls*`, and `*match-tick*` / `*hoho-frames*`. They come from `duel-data`.

**Written in a rollout but not a root: none found.** Each write a rollout's steps could reach sits behind an `*in-rollout*` guard:
- MC-NEUTRAL's return (cpu-mcts.lisp:125) covers the light search, `*mc-jobs*`, `*mc-full-stats*`, `*mc-recs*` and `*mc-next*`.
- STRAT-LAYER-STEP (strategy-glue.lisp:212) covers `*strat-jobs*` and `*strat-stats*`.
- MC-FULL-STEP (cpu-mcts.lisp:248, 249) covers the job steps and `*strat-picks*`.
- Line 343 covers `*cai-switch-counts*`.
- GO-RESULTS (flow.lisp:189) covers the page and `*fq-tables*`.
- FQ-NOTE / FQ-EXPLORE (strategy-glue.lisp:120) write only BRAIN-FQL, which is a root.

The one deliberate cross-boundary write is STRAT-FULL-STEP's `brain-set-strat!` after `sim-restore live` (strategy-glue.lisp:252):
it writes `Match` from `Search`'s job after the restore, so it stays.

### What Task 2 built on this

- `cpu::Brain` has every BRAIN slot (60) in slot order. Slots whose values later tasks port (`ring`'s SNAPs, `style`, `now`,
  `sw-*`, `ev-on` / `ev-style`, `fql`) are `Option<NotYet>`, which can only hold NIL. `strat` is `Option<StratRef>`, an index into
  `strat_library`.
- `cpu::Search` holds the jobs (their A fields only), the stats, the picks, `fq_tables`, the page and `clock` (default: always 0).
- `cpu::a_line(&Match, &Search)` prints TR-A-LINE. On all 15 live gate traces it equals the recorded A line on the 300 intro steps.
  `cpu::brain_system` is `unported!("brain-system")` while a brain is attached. `start_match` runs STRAT-LOOKUP (ported now, since
  the first A line already holds the strategy) and FQ-ATTACH!'s test as a bail (`unported!("fq-attach!")` in a superset of the
  attaching cases). MASHER-APPLY! runs with no seat.
- `duel-tools replay --live` reports `UNPORTED brain-system at tick 1 (step 301)` on all 15 live gate traces. The two vs traces
  stop earlier: `vs-cpu` at `vs-start` (step 1; TR-VS-START is Task 9's) and `vs-learn` at `debug 2504` (step 1).
