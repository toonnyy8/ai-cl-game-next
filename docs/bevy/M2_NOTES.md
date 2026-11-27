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
| a player's fq copy in BRAIN-STRAT, and BRAIN-FQL (reached through the BRAIN store) | FQ-ATTACH! (START-MATCH, outside the battle); FQ-NOTE pushes onto BRAIN-FQL (strategy-glue.lisp:120, `(not *in-rollout*)`); FQ-MATCH-END sets BRAIN-FQL NIL and updates the copy in place (GO-RESULTS, which returns at once in a rollout, flow.lisp:189). No rollout writes either (ledger T2), so the snapshot's walk into their conses has nothing to undo | yes | `Brain.strat` (a leaked `&'static` copy, never written during a match: FQ-MATCH-END makes an updated one and repoints, §8) and `Brain.fql: Option<fq::Fql>` (cloned with the match) |
| `*view-x*` `*view-z*` `*view-side*` `*behind-yaw*` (fighter.lisp:223-226) | VIEW-STEP: FIGHTER-SYSTEM every step, BEGIN-BATTLE and RESET-ROUND with RESET | yes (sim-state.lisp:16) | `Match.view_x` / `view_z` / `view_side` / `behind_yaw` (Task 9) |
| `*blow-aways*` (combat.lisp:11) | combat.lisp:205 (the sim); gate.lisp:87 (START-CVC, `// cpu:` in gate.rs) | yes (sim-state.lisp:12) | not ported: only the gate's log rows read it (gate.lisp:149) |

### Not roots, written by the CPU: in `Search`

| Global | Written at runtime (why never inside a rollout) | Root? | Rust home |
|---|---|---|---|
| `*mc-jobs*` (cpu-mcts.lisp:47) | 165 MC-FULL-REQUEST (reached only past MC-NEUTRAL's `(when *in-rollout* (return-from mc-neutral nil))`, 125); 193 MC-FULL-RESET; 251, 259, 265 MC-FULL-STEP (`(not *in-rollout*)`, 249) | no | `Search.mc_jobs` (each job's snapshot, slot 5: Task 8's preallocated slot) |
| `*mc-full-stats*` (cpu-mcts.lisp:48) | 166, 193, 263, 271 (the same guards) | no | `Search.mc_stats` |
| `*strat-jobs*` (strategy.lisp:255) | strategy-glue.lisp:206 STRAT-REQUEST (STRAT-LAYER-STEP's `(not *in-rollout*)`, 212); 239, 248 STRAT-FULL-STEP (MC-FULL-STEP's guard, 248); cpu-mcts.lisp:194 | no | `Search.strat_jobs` (STJOB-SNAP: Task 8) |
| `*strat-stats*` (strategy.lisp:256) | strategy-glue.lisp:207, 246, 255; cpu-mcts.lisp:194 | no | `Search.strat_stats` |
| `*strat-picks*` (strategy.lisp:257) | strategy.lisp:4437 (sized at load); strategy-glue.lisp:253 (after STRAT-FULL-STEP's restore); cpu-mcts.lisp:194 | no | `Search.strat_picks` (sized by the strategy layer's task) |
| `*fq-tables*` (fq-online.lisp:16) | fq-online.lisp:32 FQ-TABLE (from FQ-ATTACH! at START-MATCH); 37 FQ-RESET-ALL (SETTINGS); debug.lisp:578 (debug 2504); the cell's copy and count by FQ-MATCH-END (in place) | no | `Search.fq_tables: Vec<fq::FqCell>`, newest first (Task 9) |
| the page (PAGE-GET / PAGE-SET; the recorder's `ENGINE::*ORACLE-PAGE*`) | fq-online.lisp:40, 85-86 (FQ-RESET-ALL; FQ-MATCH-END from GO-RESULTS, which returns at once in a rollout, flow.lisp:189) | no | `Search.page: BTreeMap<i64, i64>` (M3 persists it) |
| `*cai-switch-counts*` (core-ai.lisp:339) | 343 `(unless *in-rollout* (incf …))` | no | `Search` (a log counter; the field comes with the task that ports CAI's switch count) |
| the light search's scratch: `*mc-g*` `*mc-w*` `*mc-legal*` `*mc-legal2*` `*mc-slots*` `*mc-i*` `*mc-f*` `*mc-vals*` `*mc-n*` `*mc-sum*` `*mc-n2*` `*mc-sum2*` (mcts-lite.lisp:113-128), `*mc-ws*` (cpu-mcts.lisp:112) | MC-SETUP (cpu-mcts.lisp:67-110), MC-SEED (mcts-lite.lisp:137), MC-SEARCH (`fill`, 309), MC-NEUTRAL: all past the return at cpu-mcts.lisp:125, so never in a rollout; each is rewritten at a search's start (`*mc-g*`[2], the search stream, is reseeded by MC-SEED at 129) | no | preallocated scratch for Task 8 (`Search` or the light model's own); never read across searches |
| `*mc-recs*` (mcts-lite.lisp:79) | 86 MC-MOVE-REC (from MC-SETUP, past the guard): a cache keyed by MOVE, a shared definition | no | Task 8: a table built from the data, or a `Search` cache (a pure function of the move) |

### Not roots, not CPU state: configuration, bindings, tools

| Global | Written | Rust home |
|---|---|---|
| `*difficulty*` (flow.lisp:27) | the menu (flow.lisp:255), START-CVC (gate.lisp:87), debug 2504; read at SPAWN-PAIR | `Match.difficulty` (configuration, as `mode` / `picks`) |
| `*gate-difficulty*` (gate.lisp:83) | debug 81020+ (not ported) | `Match.gate_difficulty` (always NORMAL until that command ports) |
| `*learn-debug-off*` (fq-online.lisp:8) | debug.lisp:478 (every command) and debug 2504 | `Search.learn_debug_off` (FQ-ATTACH!'s test; `debug_command` sets it) |
| `*fq-learn-force*` (fq-online.lisp:17) | tools only (strat-run.lisp) | `Search.fq_learn_force` (a tool's flag) |
| `(setting :learn)` (LEARNING CPU, 0 = on) | the SETTINGS menu (M3) | `Search.learn` (0) |
| `*view-behind*` (fighter.lisp:227) | SET-CAM-BEHIND at START-MATCH: `(and (or *cam-behind* *one-hand*) (vs-cpu-p) t)` | `Match.view_behind` (VS CPU / PRACTICE: `*cam-behind*` T and `*one-hand*` NIL in the recorder image, probed) |
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

## 2. Perception, presses and the brain branches (Task 3)

`cpu/perceive.rs` ports cpu-perceive.lisp: the SNAP (a `Copy` struct; KIND and FLAGS read from its move, since SNAP-TAKE! sets and
clears them with MOVE), SNAP-TAKE! (out of a move a reused slot keeps its S and ACTIVE-END, as the Lisp's struct does: the A line prints
them), BRAIN-PERCEIVE (the fresh fill of all 32 slots, each from its own old value; the SNAP of BRAIN-DELAY steps ago; JSTARTS newest
first), the SNAP readers, AI-PRESS / AI-PRESS-WRITE! / AI-DASH / AI-EVENT-ROLLS (guard, then Hoho) / AI-STRAFE (length, then side) /
AI-WALK, AI-MASH-P. `cpu::core_ai::core_brain_step` holds CORE-BRAIN-STEP's head: the masher seat (`unported!`, M5), the vpad's step
start, the CPU's vpad read (`PilotInput::read`), BRAIN-PERCEIVE, then `unported!("core-brain-step")` (Task 4 fills in below it).
`brain_system` takes the `PilotInput`.

**%EXPT2 is musl's powf.** SNAP-DIST squares through `duel_expt2` (powf (x, 2.0), a volatile 2 so the C compiler keeps the call).
musl's powf (ARM's, the wasm build's and the native preload's) is not x × x on 763,686 of the normal-range inputs, and the `libm`
crate's powf is FreeBSD's, whose y = 2 path returns x × x. `cl::expt2` ports musl's powf (tables as bits) and equals it on all 2^32
inputs: tests/cpu.rs `expt2_equals_musl_on_every_input` (`#[ignore]`, ~30 s in release) against a C harness's FNV hash over
build/simgate/muslm.so. cpu-ki-ichigo.lisp:601's `(expt … 2)` is the same call (Task 7).

**The same holds for exp and log (Tasks 4-8).** musl's `exp`, `expf`, `log`, `logf` are ARM's too (MUSL_MATH: `exp_data`,
`logf_data` ...), the `libm` crate's FreeBSD's. On 200,000 inputs the crate differs from build/simgate/muslm.so on exp 19,498, expf
19,576, log 3,755, logf 3,825. The CPU calls `exp` of a single-float (expf) at cpu-mcts.lisp:141 and :179. The plan's "exp / log
through libm" rule gives wrong bits there: port musl's expf like powf (`exp2f_data`'s table is already in `cl::musl_powf`).

**The C split (ruling 1).** The recorder's REC-READER sits only on the brains' vpads, and a sim frame fires it in CORE-BRAIN-STEP's
VPAD-BEGIN-STEP!. The live replayer marks the log there, on a brain side's `read` only. A line logged earlier in the frame (a debug
command, GATE-UPDATE, an earlier step's tail) stays a `[` line. Before, the mark came from any read, and on a cvc sim frame no read
happened (PILOT-SYSTEM skips brains), so every line since the last step went to C.

**The brain branches (M1_NOTES §7).** Ported: ROUND-RESET's brain clear (press-left 0, fresh t); the `P move` / `P step` / `P dash`
lines' why suffix (`fighter::why_suffix`; only scripted.lisp's trial player sets a why, so no gate trace has one); ENSURE-BATTLE's
BRAIN-OFF NIL. Already right from M1: SPAWN-FIGHTER's brain (`*difficulty*`, `*ai-delay*`), START-CVC's `*gate-difficulty*`. Left:
`ichigo::hooks::parry_from_blockstun`'s CPU parry (IC-P, AI-MASH-P: both readers exist now) for Task 4. Also fixed: TIME-UP reads a
float Reishi only on a Konpaku tie (M1 minor T13), and `--resync`'s T repair restores the vpad ticks.

**Where the live replay stops.** All 15 live gate traces: `UNPORTED core-brain-step at tick 1 (step 301)`, with no DIVERGED or T / A / C
mismatch before it (`--resync`: the same, since an unported path stops the run). `vs-learn` stops at `debug 2504` (step 1), `vs-cpu`
at `vs-start` (step 1). Step 301's perceive runs before the stop. `live_first_perceive_matches_the_key` checks P1's ring, head, fresh,
jkey and jstarts after it against the key on all 15 traces. Perception past step 301 is pinned only by unit tests until Task 4's
CORE-BRAIN-STEP lets the live replay go on.

## 3. Fuzzy, the core CPU, the exchange CPU (Task 4)

`cpu/fuzzy.rs` ports fuzzy.lisp and the engine's FZ-MU / FZ-INFER. A set's corners and a cue are `cl::Num`: `(:near -1 0 1.6 2.4)` mixes
integers and singles, and `(- x a)` of two integers stays exact before its division by a single. The rule bases and sets are knobs
(tuning.json). `cpu/xch_ai.rs` ports xch-ai.lisp and WEIGHTED-PICK. `cpu/style.rs` holds the style registry (`StyleFn`, `resolve`: None
for every name until Tasks 6-7). `cpu/core_ai.rs` ports CORE-BRAIN-STEP whole: the exchange (CAI-XCH-NEW / -STEP), the clash, the
finish, the generic CPU (CAI-NEUTRAL, CAI-MOVE-STEP, the stun / air bursts and awakenings), MC-PLAN-APPLY and MC-PRESS, the Hoho hold.
The brain is taken out of its fighter for the step and put back after it, also after a stop.

**What is not ported, and where it stops.**
- The strategy layer (`*strat-layer*`, a knob, NIL) and a brain's strategy: a Q selector or composite stops at
  `unported!("strat-switch-step")`, a plain strategy at `unported!("strat-feats")` (Task 5).
- So a brain's NOW is always NIL here, and STRAT-OUT / -SCALE / -MUL / STRAT-HOLD-AWAKEN-P are written over `Option<NotYet>`: they give
  the CPU's own value and draw nothing. CAI-DSWITCH is therefore NIL with no roll; its press and target come with Task 5.
- MC-NEUTRAL past its plan: its guard runs in the Lisp's order (mc-on, idle / run, `*mc-off-at*`, the `*mc-next*` window,
  `*mc-far*`, not awakened-ok), then `unported!("mc-neutral")` where MC-SETUP would run (Task 8). Lisp calls MC-NEUTRAL in every state, so
  a CPU in a move or a stun still reaches the generic CPU. `*in-rollout*` and the rollout's `*cai-styles*` binding are `// rollout:`
  markers (no rollout runs before Task 8).
- A matchup style (`*cai-styles*`: KI and IK only) stops at `unported!("style <NAME>")`.

**Where the live replay stops: step 301, at `strat-switch-step`, on all 15 gate traces** (with and without `--inject-plan`; no T / A /
C / `[` / H / B mismatch before it). Every gate CPU's STRAT-LOOKUP strategy is a `t0-*` Q selector, and CORE-BRAIN-STEP runs
STRAT-SWITCH-STEP in its first `let*`, before any of this task's code. No trace in the key has a brain without a strategy (`A` line slot
38 per side: every brain holds `#s::T0-…`), so **no answer-keyed trace covers core-ai yet**. Its evidence is the unit tests below, values
taken from the frozen native image (a scratch runner over build/simgate/duel.fas printing FZ-CHANCE, FINISH-ROLE, WEIGHTED-PICK,
AI-HOHO-SPARE-P, REISHI-FRAC, XCH-J-WEIGHTS with `~S`). Task 5 makes the traces reach this code.

**ECL's `(expt x 2)` is powf (ruling R7).** The host ECL compiles `(expt x 2)` to `ecl_expt(x, ecl_make_fixnum(2))` for every probe:
untyped, `(declare (single-float x))`, the same at speed 3 safety 0, a special's sum, a typed difference (`compile-file :c-file t` on a
probe; no inline `x*x`). ecl/src/c/numbers/expt.d: a zero base returns `ecl_times(x, y)`, a single-float base with a fixnum
exponent goes to `ecl_expt_float`, which is `powf(ecl_to_float(x), ecl_to_float(y))`. That is `cl::expt2`. combat.lisp:108 (APPLY-HIT's
`d2`, from single positions) and hazards.lisp:68 (a wave's arena test, `(expt (+ *arena-radius* 2.0) 2)` included) now use `cl::expt2`
(combat.rs, hazards.rs). The other `(expt … 2)` in M1-ported files are ken.lisp:729/773/835, inside the KR / ZH / Z Kikon cinematics'
DURING blocks; Task 9 ports those blocks (`ken::cine::draw`, §8) with `cl::expt2`. The 22 M1 traces stay OK.

**musl's expf (ruling R6).** `cl::expf` ports musl's src/math/expf.c (ARM's: the `__exp2f_data` table shared with powf, `shift`
0x1.8p52, `InvLn2N` and `poly_scaled` exact scalings by 32). MC-PLAN-APPLY's softmax calls it (cpu-mcts.lisp:179). It equals musl on all
2^32 inputs: tests/cpu.rs `expf_equals_musl_on_every_input` (`#[ignore]`) against `build/musl-hash expf` = `0xeae4f603b90fd236`.
tools/port/musl-hash.c is the harness for both exhaustive hashes (it dlopens build/simgate/muslm.so with RTLD_DEEPBIND, so musl's own
symbols win inside it as under the sim's LD_PRELOAD). `expt2` reproduces `0x6d43542f09460075`. Release time: about 31 s for the two
together.

**The CPU's Reishi readers over `cl::Num`** (M1 §10): REISHI-FRAC (`fighter::reishi_frac`), AI-BURST-WANTED-P, AI-HOHO-SPARE-P,
FINISH-ROLE (rules.rs). TIME-UP-WINNER now takes `Num` (CL's float × fixnum products and exact compares), so TIME-UP no longer bails on
a float Reishi in a Konpaku tie. AI-BURST-WANTED-P has no caller at lisp-freeze; its NEXT-HIT is taken as a `Num`.

**Tests.** tests/fuzzy.rs (fuzzy.lisp's 18 checks, plus 11 points of the shipped rule bases bit for bit); tests/xch_ai.rs (xch-ai.lisp's
58 checks, the unit ones over `*strat-data*` as tables.json holds it; WEIGHTED-PICK's edges); tests/cpu.rs `cpu_floor_round_edges`
(Review Focus 5), `reishi_readers_take_a_float_reishi`, `finish_role_cases`, `cpu_helpers_core_lisp` (core.lisp's deferred CPU checks),
`mc_plan_apply_picks_and_clears`, `generic_cpu_runs_to_the_mcts` (a KK match with the strategies cleared plays the generic neutral until
the MCTS's search, no panic), `time_up_reads_a_float_reishi_on_a_konpaku_tie`.

Carried items: a CPU's JSTARTS reserves `*ai-mash-window*` + 2 at spawn (BRAIN-PERCEIVE pushes before it drops).

## 4. The strategies and their glue (Task 5)

`cpu/strategy.rs` ports strategy.lisp's code (lines 1-843 and 4439-end), `cpu/glue.rs` strategy-glue.lisp, `cpu/style.rs` the style
registry. The library is never retyped: a strategy is the tables.json value itself.

**A strategy is `Strat(&'static Value)`.** It is compared by EQ (`std::ptr::eq`), as BRAIN-STRAT, -SW-SUB, -EV-ON and NOW hold the Lisp
plist. It is `Copy`, so a brain clones cheaply and a step allocates nothing. `plist_get` is GETF over a JSON plist: an object's key
(extract.lisp X-STRAT writes a plist as an object with GETF's first-wins rule; no shipped plist repeats a key, checked natively), or a
flat array's first match. A composite's `:switch` entry is a dotted cons `(OWN . plist)`, which the extractor writes `[OWN, k, v ...]`, so
`Strat::get` reads an odd-length array from its second element. NIL is `null`. A `:base` integer (`:kso-stale 60`, `:xch-j 0`) stays an
integer: STRAT-VALUE returns `cl::Num`; a rule average is a single. ponytail: a player's fq copy (FQ-TABLE, Task 9) is a fresh table
outside tables.json; Task 9 turns `Strat` into an enum with an owned case.

**The brain's strategy slots.** `now: Option<Now>` (the strategy and a fixed-capacity cue plist, `Cues`: 32 slots, first match, a missing
cue integer 0), `sw_sub` / `ev_on: Option<Strat>`, `sw_fn: Option<StyleId>` (a style's identity: Lisp compares SYMBOL-FUNCTIONs EQ,
which is the name; encoded `#FN`), `sw_won: Option<Won>` (`(max 8 n)` counts; the largest table has 8 arms), `sw_keep: SwKeep` (newest
first; reserved at the brain's making, so a switch allocates nothing; an entry with a NIL style prints `(#FN)`). `brain.style` stays
`Option<NotYet>` until Tasks 6-7.

**CORE-BRAIN-STEP's strategy part** (core_ai.rs `think`): the strategy layer's step (knob), the switch step, the event step and NOW run
on every step, before the `unless (off, lock, cine)`; NOW is cleared after it on every step. The clauses: the exchange, the clash, the
finish, then the strategy's :FN (`glue::strat_fn_step`, through the event arm's state when an event arm plays), the MCTS neutral, the
matchup style only when no strategy is active (`cur`, `ev` NIL, not under the layer), the generic CPU. CAI-DSWITCH is whole
(CAI-SWITCH-TARGET, -PRESS, STRAT-SWITCH-TO / -DIR). `*cai-styles*` is typed once (`Knobs.cai_styles`). The style registry lists the ten
style names a strategy or `*cai-styles*` names: `style::run` gives `unported!("style <NAME>")` for all of them until Tasks 6-7 (Hisagi's
M4); a name not in it panics (SYMBOL-FUNCTION's error).

**Not ported here.** STRAT-FULL-STEP / STRAT-ROLL (`glue::strat_full_step` is `unported!`: Task 8); FQ-EXPLORE / FQ-NOTE (their guard
is ported: `brain.fql` is `Option<NotYet>`, so the branch is `match x {}`; Task 9); STRAT-FINGERPRINT / -SIMILARITY (tools only);
`*cai-switch-counts*` (a tool's counter never read in play). STRAT-COMPOSE, -ARM, -WITH, -EXPAND are ported over owned JSON for the
load-time forms and the tests: `compose_reproduces_the_expanded_units` composes every `strat_units` entry back to `strat_units_expanded`.

**Where the live replay stops: step 301 on all 15 gate traces, at `style <NAME>`** (0 steps past 301; no T / A / C / `[` / H / B mismatch
before it, with and without `--inject-plan`): KK and KI's P1 at `style KEN-KH-STANDOFF-STYLE`, IK, II and the three cvctag at `style
ICHIGO-KI-R2B2A1-STYLE` (cvctag-kk: KEN-KH-STANDOFF). Every arm of the four K / I T0 tables names an M2 style, and on the first battle step
the CPU is free with nothing pending, so the :FN clause is reached at once. The replayer does not compare a stopped step's A line, so the
evidence is:
- `live_first_step_matches_the_key` (duel-tools): each trace run to the stop, then P2's CORE-BRAIN-STEP on the stopped match (P1's step
  changes nothing P2 perceives or judges by); both sides' ring, head, fresh, jkey, jstarts, strat, sw-sub / -t / -n / -won / -fn / -keep,
  tw, tw-off, ev-t / -on / -n / -steps equal the key's step-301 A fields, and each judgement's 28 cues equal the native dump bit for bit.
- `judgements_match_the_native_dump` (tests/strategy.rs): 155 judgements of the T0 tables dumped by `tests/fixtures/strat-judge-dump.lisp`
  (*STRAT-JUDGE-HOOK* over build/simgate/duel.fas: real cues, every 30 steps of four 1500-tick matches): Q per arm and the pick, bit for bit.
- `fq_checksum_matches_the_key`: FQ-CHECKSUM of t0-ki-ichigo = 179296, the vs-learn trace's `duel fq load 3 1 ... checksum 179296`.

**Task 4 code fixed** (it ran live for the first time): NOW was cleared only inside the `unless`; the switch / event steps and NOW now run
when off, locked or in a cinematic too; the matchup-style clause ran whatever the strategy; the :FN clause was missing; STRAT-OUT /
-SCALE / -MUL read `f32` (now `Num`: an integer key stays exact); the style stop leaked its name (`Box::leak`); `cai_style_fn` read
`*CAI-STYLES*` as raw JSON every step.

## 5. Kenpachi's matchup styles (Task 6)

`cpu/ken_ki.rs` ports cpu-ki-ken.lisp and cpu-kh-ken.lisp whole: KEN-KI-STYLE and everything it calls (the form / L3 / knockdown / Hoho /
Getsuga events, the plan's answers, the meaty chase, the read and its dodges, KK-DECIDE / KK-PICK, his strings, the NS whiff stop, the link,
the AS carry, the L3 SA, the Kikon rule), KEN-KH-STYLE (the wake-up bait) and KEN-KH-STANDOFF-STYLE (the stand-off clock). `style::resolve`
names the three; Ichigo's two stay `unported!` (Task 7), Hisagi's five too (M4). KEN-CLOSING (ken.lisp, read only by the CPU) is there too.

**The state.** `style::StyleState` is the BRAIN-STYLE slot: `Kks`, `Khs` (`k: Kks` + hw, bait, last), `Kso` (`k: Kks` + the clock). Every
slot is a scalar, so it is `Copy` and a step allocates nothing. It prints as TR-B-ENC prints a struct: `#KKS{…}` (27 slots), `#KHS{…}` (30),
`#KSO{…}` (33). One slot is not T / NIL: KKS-REACH is `(or bk (style-roll …))`, and `bk` is MEMBER's tail, so in a Bankai it holds
`(:BANKAI,:BANKAI-2)` (`(:BANKAI-2)` in the second form): `ken_ki::Reach`. KEN-KH-STYLE / -STANDOFF call KEN-KI-STYLE on their own struct;
the port takes the struct out of the brain for the step and hands KEN-KI-STYLE's body its included `Kks`, and puts it back after, also on
an early return.

**Knobs.** The styles' 77 defparameters are in `Knobs` (tuning.json, never retyped). A chance plist is a `KwNums` (keyword → `cl::Num`,
the token's type kept: `*kso-stale*` is integers, read by plain GETF with default 300); `*kk-cine-wait*` is a `KwBools` (BRAIN-CHANCE at
EASY is the present NIL, not NORMAL's). Carried from Task 5: `style_dif` now returns `cl::Num` over a `KwNums` (an integer arm value or
plist entry stays one), and `b.now.and_then(…)` became `.as_ref()` in `strat_fn_step` and `cai_switch_target` (no copy of NOW).

**Task 5 code fixed: :KEEP-STATE keeps the objects (EQ).** STRAT-SWITCH-STEP's keep stores BRAIN-STYLE's struct in BRAIN-SW-KEEP and, on the
way back, sets BRAIN-STYLE to the kept struct itself: from then on the entry and BRAIN-STYLE are one object, and every step's change shows in
both (the A line prints both). Task 5 stored copies (harmless while the slot could only be NIL). Now `Brain.style_live` (not a slot) marks
that the entry of `sw_fn` is EQ to `style`; the A line prints `style` for that entry, a switch writes it back, and `Brain::style_replaced`
gives the entry the old struct when a style makes a fresh one (MAKE-KHS on a NIL / other / later-tick slot). STRAT-EVENT-CALL clears the
mark around the event arm's call (its struct is never a kept one); BRAIN-SET-STRAT! clears it. Without it cvc-kk-s1 diverges at tick 312
(`p1.brain-sw-keep`).

**Where the live replay stops** (with and without `--inject-plan`, the same):
- cvc-kk-s1..3 and cvctag-kk: **replay OK, whole matches** (18133, 15866, 16860, 16354 ticks; every T / A / C / `[` / H / B equal). Both CPUs
  run the T0 Q selectors, their :KNOCKDOWN event arm (KEN-KH-STYLE) and :KEEP-STATE swaps, the styles and the core CPU under them (the
  exchange, the clash, the finish, CAI-NEUTRAL / CAI-MOVE-STEP). The MCTS is never reached on a Kenpachi side: KEN-KI-STYLE decides
  every idle / run / move step itself (it runs CAI-NEUTRAL / CAI-MOVE-STEP), and the strategy layer is off, so `--inject-plan` changes
  nothing there.
- cvc-ki-s1..3: step 301, P2 at `style ICHIGO-KI-R2B2A1-STYLE`. P1's Kenpachi step runs first on the real sim stream; the replayer does
  not compare a stopped step's A line, so `live_first_step_matches_the_key` compares every `p1.brain-*` field of it (the KSO, the press,
  the rolls) with the key's step-301 A line: equal on all three.
- cvc-ik-s1..3, cvc-ii-s1..3, cvctag-ii, cvctag-ik: step 301, P1 at `style ICHIGO-KI-R2B2A1-STYLE` (Task 7; see §6 for where they stop now).
- vs-learn: `debug 2504` (step 1); vs-cpu: `vs-start` (step 1) (Task 9).

**Reached by the key, and not.** The C lines of all 17 traces (counts over the files, IK's P2 included though not replayed yet): `kh
stand-off breaker` 474, `kk pick NS` 304 / `J1` 138, `khf bait armed` 86, `kk meaty armed` 58 / `J1` 41, `kk string SP after J1 J2 J4 J5 J7`,
`kk read SDODGE` 27 / `DODGE` 1, `kk step-dodge now` 19 / planned 8, `kk link NS` 15 / `SA` 11 / `stop` 1, `kk climb` 14, `kk awaken` 14,
`kk bankai-plan` 7, `kk l3 SA` 4, `kk dodge now` 1. **Never in any trace** (ported by reading, pinned only by the unit tests where noted):
her Getsuga route's answers (`kk wave`, :close / :hit / :cut / :late / :step / :chase), the Hoho-end J1 (`kk hoho-end`), the perfect
Hoho's follow-up (`kk pf J1`), his wake-up Hoho, the Step in and its J1 (`kk step-in`, `kk step J1`), the Hoho in (`kk hoho-in`: off at
every difficulty), the planned Hoho dodge (`kk dodge at`), the brawl's own answers (`kk read TAME / J1 / NS1A`), and KEN-KI-STYLE as a
style of its own (no `#KKS{` in any trace: every K arm plays a KH style, which runs KEN-KI-STYLE's body on its KHS / KSO). No shipped arm
sets `:kk-p2-or`, `:kk-lunge-any` or the `:kk-wave-*` keys.

**KE-BUTTAGIRU, KE-CHARGE, KE-FLURRY (M1_NOTES §5): still unreached with the CPU.** None starts in any of the 17 gate traces (0 `#m::KE-…`
of the three), and the four KK matches above run whole without them.

**Tests.** `ken_ki::tests`: `ken_c_tags_have_a_site` (each of the 28 CLOGs of the two files has exactly one Rust site with the same text, and
the census's 13 tags from them are among them), `standoff_clock_by_difficulty` (*KSO-STALE* 900 / 540 / 120: not old at the stale tick,
old one past it, a gauge change of either side restarts the clock, ahead at the bell never old), `kk_pick_with_a_fixed_rnd` (both picks
at 1.5 m with the approach's rolls made: NS under *CAI-NS-NEAR*, J1 over it, the draws and the press each takes). duel-tools:
`live_kk_s1_replays_whole` (cvc-kk-s1 OK with both flags); `live_ki_s1_reaches_brain_system` and `live_first_step_matches_the_key` now
expect Ichigo's stop (the latter checks KK's first step on the match right after BRAIN-SYSTEM, and every P1 brain slot of KI's); tests/cpu.rs
`brain_read_fires_inside_brain_system` sees both brains' reads.

## 6. Ichigo's matchup styles and his CPU hooks (Task 7)

`cpu/ichigo_ki.rs` ports cpu-ki-ichigo.lisp whole (ICHIGO-KI-STYLE and every callee: the episode's mode, the whiff punish and confirm with
the walk-in, the timed Hoho and its follow-up, pointer 2's Getsuga / retreat / wait, the shut-gauge lunge, KESSA's k-lunge and chains,
the cross band, the wake-up Hoho, the meaty J1, the steered strings and the AS read, the NS stop, the Kikon rule, IKS-GENERIC, the
breaker) and cpu-ki-ichigo-r2b2a1.lisp (ICHIGO-KI-R2B2A1-STYLE: the wake-up roll, the stale breaker, the far-lunge watch). `style::resolve`
names both; only Hisagi's five stay `unported!` (M4).

**Not ported, and why.**
- cpu-ki-ichigo-r2b1a1.lisp (ICHIGO-KI-R2B1A1-STYLE, its IR2 struct and the five `*ir2-*` knobs): no `*cai-styles*` entry and no
  strategy's :FN names it (tables.json names only ICHIGO-KI-STYLE and ICHIGO-KI-R2B2A1-STYLE), so nothing reaches it.
- IKW-GAP-WATCH's gap-off arm (IKW-ALT: once he back-Steps :ikw-gap-off-n far lunges, a fresh plist `(:base (:iks-gap-p 0.0 . base) . arm)`
  is swapped into BRAIN-NOW's car through IKW-CELL). It logs `ki-style gap off`, then stops at `unported!("ikw gap-off")`. A strategy
  that is not a tables.json value is Task 9's owned `Strat` (§4). No gate trace reaches it: there are 0 `gap off` lines in the 11
  Ichigo traces, and every IKW prints ALT NIL and CELL `(NIL)`. IKW therefore prints those two slots as constants.

**The state.** `StyleState::Ikst` (IKST, 28 slots) and `StyleState::Ikw` (IKW: the IKST, then roll, lunge-t, stepped, alt, cell, rsig, ksig,
still-t: 36). Every slot is a scalar or `Copy`, so a step allocates nothing:
- IKST-PEND holds a *IKS-PUNISHERS* entry. The port stores a `Punisher` copy, which prints as the list `(:NS1,22,4059999A,NIL)`.
- IKST-STEER is a `cl::Num`, because an arm's :iks-steer-to may be a float.
- IKST-LAST-REISHI and IKW-RSIG are `cl::Num`, because they hold GAUGES-REISHI.

ICHIGO-KI-STYLE keeps any IKST-family struct across rounds and matches, since it has no tick test (unlike KKS). ICHIGO-KI-R2B2A1-STYLE
keeps only an IKW. Its call to ICHIGO-KI-STYLE runs the body on the IKW's included IKST, never through the wrapper: the wrapper would
see the slot taken out and make a fresh struct, which clears the :KEEP-STATE mark.

**Carried from Task 6: `take_style` checks the variant first.** `style::take_style(b, ok, make)` is shared. Kenpachi's predicates test
the variant before KKS-TICK (`StyleState::kks()` now returns `Option`). Before, KEN-KI-STYLE's guard called `kks()` on any struct and
panicked on an IKST. Test `ken_style_over_another_styles_struct`.

**Knobs.** All 99 `*iks-*` / `*ikw-*` defparameters the two files define are in `Knobs` (tuning.json; a script compared the field list
with the files' DEFPARAMETERs: equal). `*cai-hoho-p*` is in `Knobs` too, read by the neutral's Hoho test. No extractor change, so the data
checksum is unchanged.

Two knob types are new in knobs.rs:
- `Plist<T>`: keyword → value or NIL, in GETF order. `getf` tells an absent key from a present NIL, which IKS-FORM-GET needs: against
  Hisagi, a present NIL row wins; otherwise `(or form's :nozarashi's)`. `chance` is BRAIN-CHANCE.
- `Nums`: a list of numbers keeping each token's type, NIL as the empty list.

Three lookup rules apply:
- BRAIN-CHANCE (NORMAL fallback) for `*iks-mix*`, `*iks-bait-modes*` and `*iks-kessa-space-modes*`.
- Plain GETF for `*iks-ns-stop*`, `*iks-generic-kikon*`, `*iks-follow-any-perfect*` and `*iks-burst-no-hoho*`. Every key is present,
  so this is the same as `KwBools::chance`.
- STYLE-KNOB over `cl::Num` for the arm keys. The shipped arms give :iks-gap-fs 150 / 300, :iks-ns-wait 24, :iks-ns-wait-p1 10,
  :iks-wait-max 0 / 40 / 150 and :iks-steer-to 2 / 3 / 5 as integers. IKS-HIS-SHUT-LEFT's MAX of a float climb and an integer lockout
  is `Num::max`.

**Floats.**
- IKS-CLOSING squares through `cl::expt2` (musl's powf, ruling R7), then takes `sqrtf`.
- IKS-CONFIRM's `(ceiling x 0.06)` of two singles is ECL's `ceilf(x / y)` (ceiling.d, SF / ANY).
- IKS-PICK sums its weights from LOOP's integer 0 (exact) and adds each `(/ w sum)` in order. ponytail: an all-integer arm weight set
  would make CL ratios in IKS-MODE-PICK, but every shipped :iks-mix-* is a float.

**Ichigo's brain branches (M1 §7).**
- PARRY-FROM-BLOCKSTUN's CPU part is ported (`cpu_parry_from_blockstun`, closing the `ichigo brain parry-from-blockstun` stop). It runs
  in FIGHTER-SYSTEM, where the brain sits on its fighter. A brain that is off or a masher gets no help.
- On a new blockstun it draws once when his move is :flash, with `ic_p` by difficulty. EASY's chance is the single-float product
  `0.6 * *ai-ic-parry-bs-p*`. A J masher's blocked :quick also draws once, a chance only at HARD (0.6).
- The parry frame is `(max 1 (- stun 6))`. L is pressed on it with `ai_press :sig 2`.
- TSUKI-DASH's brain aim and TSUKI-STEP's ICHIGO-AI-STANCE were already ported. They are now tested (`ai_stance_pick`: a roll at each
  band's edges, one draw each; this closes M1 minor T12).

**Where the live replay stops** (with and without `--inject-plan`, the same; no T / A / C / `[` / H / B mismatch before any stop):

| Trace | Result |
|---|---|
| cvc-kk-s1..3, cvctag-kk | replay OK, whole matches (unchanged) |
| cvc-ki-s1 / -s2 / -s3 | `mc-neutral` at step 812 / 3516 / 2434 |
| cvc-ik-s1 / -s2 / -s3 | `mc-neutral` at step 2411 / 2662 / 1666 |
| cvc-ii-s1..3, cvctag-ii | `mc-neutral` at step 326 |
| cvctag-ik | `mc-neutral` at step 1024 |

At seven stops the key opens a job at that step: cvc-ki-s2 / -s3, cvc-ik-s2, cvc-ii-s1..3 and cvctag-ii (for example cvc-ii-s1 step 326:
plan `1 3 8`, job `0 3 8 :NORMAL 0`). At the other four the key shows no plan, job or `*mc-next*` change: cvc-ki-s1 812, cvc-ik-s1 2411,
cvc-ik-s3 1666 and cvctag-ik 1024. At those steps MC-SETUP returns NIL in the Lisp, because the opponent's perceived state is none the
light model starts from (its `(t nil)` case: :air / :down / :wakeup).

The port stops earlier than MC-SETUP, so a check was run outside the commit. MC-NEUTRAL was given only that NIL case (return NIL on such
a SNAP state; MC-SIDE-SETUP's scratch is Search-only and rewritten at every search). With it, those four replays ran on with no
mismatch to steps 826 / 2413 / 1670 / 1079, and the key opens a job at each of those steps. So the style's NIL and the generic CPU after
it equal the key there too. Task 8 can take that case first.
Ichigo HARD is off the MCTS (`*mc-off-at*`), but every gate CPU is NORMAL. A NORMAL `:generic` episode returns NIL, because IKS-GENERIC
runs only under `*iks-generic-kikon*` (HARD), so it falls through to MC-NEUTRAL. `--inject-plan` cannot move these stops, because no
plan reaches 1 before Task 8 (ruling R5).

The C lines reached live before the stops:
- Ichigo: `ki-style ptr3 p2-j` 6, `confirm-j` 3, `punish-j` 2, `confirm-sp` 2, `as3` 2, `ki-style whiff punish-j` 1.
- Kenpachi's KI paths: `kk pick` 40, `kh stand-off` 22, `kk meaty` 10, `kk step-dodge` 5, `kk read` 5, `kk link` 2, `kk string` 1.
- The core CPU: `cpu xch` 71, `cpu clash` 48, `cpu holds` 5.

The IKW struct (mode picks, rolls, ep-t, the dt re-roll) is compared every step through the A line. **No earlier task's code broke** on
these first live runs of Kenpachi's KI paths, Ichigo's paths and Tasks 3-5 against Ichigo.

**Tests.** `ichigo_ki::tests`:
- `ichigo_c_tags_have_a_site`: each of the 8 CLOGs of the two files has exactly one Rust site with the same text, and the census's
  `ki-style <mode>` tags are IKS-LOG's line.
- `mode_pick_by_the_mix`: NORMAL's normalised mix at the band edges; EASY always :generic.
- `ikw_prints_its_slots`: a fresh IKW's 36 slots and a pending punisher's list.

`ichigo::hooks::tests`:
- `ai_stance_pick`.
- `cpu_parry_roll_by_difficulty`: both outcomes at each difficulty, one draw on a new blockstun, none in an old one, the press on the
  parry frame, the masher's J path, a brain off.

Updated:
- duel-tools `live_ki_s1_reaches_brain_system` is now `live_ki_s1_reaches_the_mcts` (step 812).
- `live_first_step_matches_the_key` compares every brain slot of both sides at step 301 on all 15 traces.
- tests/cpu.rs `brain_read_fires_inside_brain_system` expects no stop.
- `first_perceive_fills_the_ring` reads his position before the step that now moves him.

## 7. The light model, the full-sim MCTS and the strategy rollouts (Task 8)

`cpu/mcts_lite.rs` ports mcts-lite.lisp: `Lite` holds the light model's specials (`*mc-f*` `*mc-i*` `*mc-slots*` `*mc-vals*` `*mc-g*`
`*mc-w*` `*mc-n*` …) and is made afresh on the stack for each search, so none of it is CPU state (§1). `mc_move_rec` builds a record per
call (no `*mc-recs*` cache: a pure function of the move). `cpu/mcts.rs` ports the rest of cpu-mcts.lisp (MC-SETUP, MC-NEUTRAL past its
guard, MC-FULL-REQUEST, MC-FULL-STEP / -ROLL / -ROLLOUT / -CONTACT / -HEALTH / -RESET), rollout.lisp (`with_rollout`) and sim-state.lisp
(`sim_snapshot_ok_p`, `sim_rollout`; `flow::sim_step_lean`). `glue::strat_roll` / `strat_full_step` port STRAT-ROLL / STRAT-FULL-STEP
(ruling R4: host test only, `strat_full_step_picks_after_its_rolls`). MC-NEUTRAL now takes the SNAP and returns NIL on MC-SETUP's
`(t nil)` states (:air / :down / :wakeup …), Task 7's four stops.

**The snapshot boundary, as built.** A job's snapshot is a `cpu::Slot` (a boxed `Match`) taken from `Search.pool` and written with
`clone_from`; a rollout restores it into `Search.scratch` and plays there. The live match is never touched by a rollout, so Lisp's
`(sim-restore live)` after it has nothing to undo, and WITH-ROLLOUT's bindings are fields of the scratch match only: `Match.in_rollout`
(`*in-rollout*`), `Match.styles_off` (MC-FULL-ROLLOUT's `(*cai-styles* nil)`), `log_on`, `pacing_log` (M1 §10's carry), `skip_cines`.
What a rollout writes into `Search` (the job's two scores) stays, as in Lisp; a stand-in brain for a brainless opponent is added to the
scratch and vanishes with its next restore; `strat_full_step` writes the pick into the live brain. Two jobs made in one step each take
their own slot of the same state (Lisp shares one snapshot object; no rollout writes a snapshot, so it is the same). Every `*in-rollout*`
reader is ported: MC-NEUTRAL, MC-FULL-STEP, GO-RESULTS (a rollout's K.O. stops at :finish), STRAT-LAYER-STEP, STRAT-SWITCH-STEP's counts,
STRAT-EVENT-STEP's counts, the online learner's guard (Task 9). `Match`'s `Clone` is hand-written (`match_clone!`, an exhaustive
destructuring): `clone_from` restores every field but `knobs` (configuration, written only by `Match::new`), and every component with a
heap field restores in place (`Store`, `Fighter` / `Brain` (boxed since Task 10), `Pilot` / `Vpad`; the rest are `Copy`, which the
`..*src` updates check: `Hazard` / `HitWin` / `Icc` too since Task 10's fixed-capacity lists, §9). A clone keeps `Store`'s `MAX_ENTITIES`, the brain's JSTARTS / SW-KEEP reserves and `iccs`' `ICC_RESERVE` (1024).
`Search::warm` (end of START-MATCH) makes `cpu::POOL` = 4 slots and the scratch, outside the battle.

**Found in the Lisp: MC-SEARCH's UCB macro captures A** (DIVERGENCES §1). The capture is in the source (mcts-lite.lisp:310-340) and
happens in any Common Lisp: the macro's body loops with its own `(dotimes (a 10) …)`, and the tree's second level passes BASE as the form
`(* 10 a)`, which the expansion evaluates inside that loop, so it reads the macro's A, not the caller's. The opponent's reply B is
therefore scored from `n2` / `sum2` at index 11 B, while the update after the rollout writes 10 A + B. The port keeps it for parity
(`Lite::search`: BASE is a function of the loop variable). Found on cvc-ii-s1's first job (step 325: a2 8 in the key, 0 in the port):
single rollouts matched the native image for every (root, reply) pair from one seed, so the difference was in the search; a transcription
of MC-SEARCH that bound BASE once per call (my reading, not the source's expansion) reproduced the port's wrong numbers, and reading the
expansion showed the capture.

**Carried items done.** `SimRng.state` is private (`rng::crn_seed` is MC-FULL-ROLL's / STRAT-ROLL's seed). `start_match`, `start_cvc`,
`start_pair_gate`, `gate_update`, `debug_command` and `ensure_battle` take `&mut Search`, so MC-FULL-RESET's Search part runs at the match
start (it also sizes `strat_picks` to 2 × the library: strategy.lisp check 91). `fighter::id_of` is O(1) (the move's index from its
address in `data.moves`). A rollout that hits `unported!` stops; `Search.cut_rollouts` counts it, `Search.cut` keeps the first name, and
the live replay fails with `replay UNPORTED <name> in a rollout from tick T (step S)` (`cut_rollout_fails_the_run`). IKS-MODE-PICK with
every weight an integer is `unported!` (CL ratios; no shipped arm). `tsuki_dash_brain_aims_at_him` tests TSUKI-DASH's brain aim.
IKW-GAP-WATCH's gap-off arm (IKW-ALT) is ported: `Now::gap_off` reads the arm with `:iks-gap-p 0.0` first in its :BASE (the reseeded
`--snap` rollouts of cvctag-ii reached it at tick 9640). IKW's ALT and CELL are printed from it (`#s:<id>`, the cell through `Now`'s
encoder), ported but unverified: no compared trace reaches gap-off, and `Now`'s encoder has never been checked against a key.

**`--snap` is SIM-ROLLOUT now** (snaptest.lisp's): a scratch copy, WITH-ROLLOUT's bindings with the styles kept, 40 lean steps, stopping
when the flow leaves the battle or a cinematic runs; the live match is never touched. A plain sim step there would have run MC-NEUTRAL's
search and MC-FULL-STEP into the live `Search`.

**Data.** `*mc-outcomes*` and `*mc-outcomes-hard*` (and every other `*mc-*` knob) were already in tuning.json (the extractor writes every
source DEFPARAMETER): no extractor change, the data checksum stays `3ddcd77c9a34edf5` (`rs/duel-data/data/manifest.json`). New `Knobs`
fields: the `*mc-*` search knobs, `*strat-bias-keys*` (`OptNames`), `*cai-cont-p*` / `*cai-turn-p*`, `*strat-c*` / `-h*` / `-swing*` /
`-rolls*`; `McOutcomes` reads the outcome tables (T rows as `None`, ASSOC's first match).

**Where the live replay stands: all 15 gate traces `replay OK`, whole matches**, with and without `--snap 40` (0 rollouts reaching an
unported path), every T / A (the job sections included) / C / H / B equal; the M1 gate gives 22 OK with and without `--snap`; cvc-ii-s1
live also replays OK in wasm32 under node. `--inject-plan` is now redundant (MC-FULL-STEP writes the same plan) and still passes.
`vs-cpu` / `vs-learn` stop at step 1 (`vs-start`, `debug 2504`: Task 9). A cut CPU rollout prints `replay UNPORTED … in a rollout`,
which `replay-gate.sh --allow-unported` would accept (a `--snap` cut is always `SNAP-UNP`); the M1 gate's brainless traces run no CPU
rollout, but a live gate must fail that line as SNAP-UNP is failed (done in Task 10: `CPU-UNP`, §9).

**Allocations** (`duel-tools` `live_allocs`: the commands run live, no reader, the combat log off, every frame that starts and ends in the
battle). cvc-ki-s1: 210 in 21,120 battle steps (12 decisions, 24 rollouts), MC-FULL-STEP's share 0. cvc-ii-s1: 217 in 19,080 (66
decisions, 132 rollouts), MC-FULL-STEP's share 4: a slot, then the scratch, copying an Ichigo clone whose replay queue (`Icc.rq`, a Vec)
the slot never held, twice. The rest is M1's known Ichigo clone events (M1 §5); both go away with fixed-capacity `Icc` / `HitWin`
fields. Without `ICC_RESERVE` the slots also grew `iccs` (2 per new high-water mark). A brainless (vs) opponent's stand-in brain is a
fresh `Brain` per rollout (Task 9's case, not "both CPUs on"). (Task 10 took both to 0 on all 15 cvc traces: §9.)

**For Task 9.** In a vs rollout the Lisp's human device reader still runs (the stand-in brain's VPAD-BEGIN-STEP! calls it: it rewrites
his held state before AI-PRESS-WRITE! sets every button); the port's rollouts read nothing (`flow::NoInput`), which equals the cvc
recorder (REC-READER skips rollouts) but not necessarily a vs trace.

## 8. The online learner and the human side (Task 9)

**Gate.** `replay --live --inject-side 0`: vs-cpu `replay OK 12835 ticks`, vs-learn `replay OK 22413 ticks`, every T / A / C / H / B
equal. vs-learn's A lines carry the learner whole: the copy `#s::T0-KI-ICHIGO/fq(<matches>,<q codes>)` (TR-A-STRAT), BRAIN-FQL with its
record count and newest record (TR-A-FQL), the TD update at each match's end (the go-results step's A prints the updated codes), and the
second match's load from the page (`/fq(1,…)` from its first step). The page at the end equals the trace's `R page-set` lines (627 at
71000, `duel-tools` `vs_traces_replay_whole`). Both also replay OK with `--snap 40` (321 and 559 SIM-ROLLOUTs, none cut). The 15 live
gate traces stay OK with `--live` and with `--live --snap 40`; the M1 gate 22 OK; `live_allocs` unchanged (cvc-ki-s1 210, MC-FULL-STEP's
0; cvc-ii-s1 217, 4).

**fq.rs** (fq-online.lisp). `fq_table`, `fq_attach` (FQ-ATTACH!'s whole test: the table chance >= 1, HARD, `fq_learn_force` or VS CPU
against a brainless opponent with `Search.learn` 0 and no debug command), `fq_explore` / `fq_note` (in `glue::strat_switch_step`, outside
rollouts), `fq_reset_all`, and FQ-MATCH-END in two halves (below). `debug_command` sets `Search.learn_debug_off` for every command; debug
2504 and `E vs-start` (TR-VS-START) are ported (`debug::debug_vs_learner`, `debug::vs_start`).

**The copy's identity (ledger T5).** A player's copy is a fresh plist (COPY-TREE of the lookup's entry, or the page's q in one), EQ to no
library value, its arms new values too, and FQ-MATCH-END updates it in place. The port leaks each copy into a `&'static Value`, so `Strat`
stays a Copy pointer compared by `ptr::eq` (the library case unchanged, `Strat::get`'s 30-odd callers untouched) and the copy's arms are
new addresses, as COPY-TREE's. FQ-MATCH-END clones the cell's copy, applies the TD update, leaks the result and repoints the cell and every
brain holding the old one: the go-results step's A line then prints the updated codes as the Lisp's in-place update does. No owned enum
variant: `Strat::get` returns `&'static` and `Strat` sits in Copy structs (`Now`, `Cues`), so an owned or `Rc` case would touch every
caller for no behaviour. Ceiling: one table leaked per load and per learned match (tens of kB, a human's matches only); an arena of copies
in `Search` if a session's matches ever matter (`ponytail:` in fq.rs).

**FQ-MATCH-END's two halves.** GO-RESULTS runs deep inside the sim (a K.O. cinematic's end: `cine_step` → `end_cine` → `run_after`, or
`hit_system` → … → `start_cine` with `skip_cines`), where no `Search` is passed. `fq_match_end_take` (in `go_results`) does the Match half
then and there: each learning brain's record taken (BRAIN-FQL NIL), its health balance (MC-FULL-HEALTH) and result at that moment, queued in
`Match.fq_end`. `fq_match_end_apply` (at the end of `sim_step`, before `*step-hook*`'s A line) does the Search half: the TD update, the count,
the page writes (codes, then the length), the repointing. Between the two nothing reads the tables, the page or BRAIN-STRAT (the step's
rest after GO-RESULTS is a cinematic's end or the systems after HIT-SYSTEM; the flow is RESULTS, so no later step runs), so the result
equals the Lisp's.

**The snapshot boundary (ledger T2).** BRAIN-FQL lives in the brain (`Brain.fql`, cloned with the match: a learning match's snapshots
allocate its new records, VS CPU only); the copy is immutable during a match. Every writer is outside rollouts: FQ-NOTE's
`(not *in-rollout*)`, FQ-MATCH-END from GO-RESULTS (which returns in a rollout), FQ-ATTACH! at START-MATCH. §1's table has the row.

**VIEW-STEP** (`fighter::view_step`, M1 §2's carry) runs every FIGHTER-SYSTEM, and with RESET at BEGIN-BATTLE and RESET-ROUND, for every
match as the Lisp does (invisible to H and B in CvC); STICK-RELATIVE reads a `cam_relative` pilot through `behind_yaw` (`view_behind`) or
`dir_yaw(-view_x, -view_z)`. The three `unported!("view-step")` sites are gone. The recorder image, probed after `tr-vs-start` and debug
2504: `*one-hand*` NIL (M1 §10's touch stubs hold for the human), `*cam-behind*` T, `*view-behind*` T, `(setting :learn)` 0, debug 2504's
`*match-seed*` 1 (= `Match::new`'s).

**Found in the Lisp: a played cinematic's DURING forms write sim state** (DIVERGENCES §1). vs-cpu first diverged at step 6203 (KEN-Z-KIKON1,
P1's yaw) and vs-learn at step 2771 (the same cinematic, P2's yaw). CINE-DRAW runs the script's draw mode once per rendered frame, after
the frame's steps (DRAW-SCENE, skipped in turbo), and Kenpachi's KE-KK-AT / KE-KK-YAW in DURING move the actors' TRANSFORMs: the victim
looking round, blown away, Kenpachi through him. The CvC gate traces run in turbo with cinematics skipped, so M1 saw none of it.
`cine::cine_draw` (called by `flow::frame` unless `turbo`) runs `ken::cine::draw`: the DURING forms of KR / ZH / Z-1 / S-1 / S-2 that
write sim state, U as the macro computes it. Every other DURING (the generic cinematics', Ichigo's: VFX, cameras, `*ic-w*` scratch) and
the rest of the draw (SLOW-DRAW puts back what it moves; hazard draw functions write nothing of the sim) were checked to be looks.
Trace coverage: vs-cpu plays KEN-Z-KIKON1 once and KEN-S-KIKON1 twice, vs-learn KEN-Z-KIKON1 once (and NOZARASHI, Ichigo's, INTRO, KO);
KR-KIKON, ZH-KIKON and S-KIKON2's DURING ports are read from the Lisp, unchecked by any trace.

**The human's device inside a rollout (ledger T8).** The Lisp's stand-in brain (MC-FULL-ROLL / STRAT-ROLL's, for a brainless opponent)
runs CORE-BRAIN-STEP, whose VPAD-BEGIN-STEP! calls the vpad's reader: the human's device, which in a rollout writes its held state (every
button, then the stick) without advancing, before AI-PRESS-WRITE! sets every button; a rollout's PILOT-READ calls it too. So a held key is
pressed afresh in each rollout step (a new press stamp) and a button the stand-in holds is released and pressed again each step
(DIVERGENCES §1: not what the stand-in was for). The port does the same: `PilotInput::rollout_read` (required since Task 10; nothing for a CPU's vpad, which has no
reader: the recorder's REC-READER skips rollouts), called through `flow::InRollout`, which `mc_full_step` (now given the live input) passes
to MC-FULL-ROLL and STRAT-ROLL's lean steps, and `sim_rollout` (SIM-ROLLOUT: there a brainless human's PILOT-SYSTEM reads the device;
the replayer's `--snap` passes itself). The replayer's is the vs device: `Injector.held`, the buttons and stick last injected, written
again; the live reads also write it again on a step without a new vpad tick, as REC-VS-DEVICE does. Test `tests/mcts.rs`
`vs_device_writes_in_rollouts` (a held :sig moves its press stamp inside the rollout; with `NoInput` it stays).

**Ruling R3.** Neither vs trace queues an MCTS job (every A job section is empty on both), so no vs rollout runs in the gate: the stand-in
brain and the device inside a rollout are covered by `stand_in_brain_for_human` and `vs_device_writes_in_rollouts` only.

**Ledger T8 minor.** The stand-in brain is reused: `rollout_start` takes the last rollout's stand-in out of the scratch before the restore
(`Search.spare_brain`) and remakes it with `Brain::reset` (MAKE-BRAIN's slots, JSTARTS / SW-KEEP's reserves kept), so a vs rollout
allocates no brain (`brain_reset_is_make_brain`).

**Tests.** `tests/fq.rs`: `page_roundtrip` (FQ-TABLE's fresh copy, FQ-MATCH-END's save, the reload after the tables are forgotten: the
learned q, one match, the same checksum; another offline table loads fresh; FQ-RESET-ALL), `cvc_never_learns` (CPU vs CPU at HARD, VS CPU
after a debug command and at NORMAL: no learner; debug 2504 and `fq_learn_force`: learners), `a_line_prints_the_copy_and_the_record`.
`tests/mcts.rs`: `vs_device_writes_in_rollouts`, `brain_reset_is_make_brain`. `duel-tools`: `vs_traces_replay_whole`. The fq checks of
strategy.lisp were all ported by Task 5 (`online_fq_td_and_page`); none was left.

## 9. Closing the gate (Task 10, 2026-11-27)

The plan's Task 10 asked for "§1 boundary, §2 census, §3 rulings, §4 carries, §5 numbers"; those numbers predate the per-task sections
(§1-§8 above, which the ledger quotes), so the closing sections follow them: the boundary and its census are §1, the gate and the 0 B
rule here, the numbers §10, the coverage §11, the rulings, carries and deferred minors §12.

**The gate, all re-run on the final commit** (i7-13700K):

| Check | Result |
|---|---|
| `duel-tools cvc --check build/oracle/cvc-tag.txt` | `cvc OK seed 7 ii,ik,kk: 88 lines equal`, exit 0 |
| `tools/port/replay-gate.sh` (M1's 22, brainless) | 22 OK |
| `tools/port/replay-gate.sh --live` (the 15 cvc traces `--live`, vs-cpu / vs-learn `--live --inject-side 0`) | 17 OK |
| `tools/port/replay-gate.sh --live --snap` | 17 OK (no rollout cut) |
| `tools/port/replay-gate.sh --live --wasm` (wasm32-wasip1 under node) | 17 OK |
| `tools/port/replay-gate.sh --wasm` | 22 OK |
| `tools/port/replay-gate.sh --snap` (M1's 22) | 22 OK |
| `cargo test --release --workspace` (with `ORACLE`) | 246 passed, 0 failed (243 in duel-sim / duel-tools / duel-data) |
| `cargo clippy -p duel-sim -p duel-tools -p duel-data --all-targets --release -- -D warnings` | clean |

BEVY_PORT §7's M2 gate, "cvc II / IK / KK identical to `cvc-tag.txt` and to the key's extra seeds": the tag is the `cvc --check` row;
the extra seeds are the 12 cvc-* traces (seeds 1-3 of KK / KI / IK / II), replayed whole with the CPUs thinking (every T / A / C / H /
B equal), which is stronger than their RESULTS and hash lines.

**`duel-tools cvc [--seed N] [--pairs ii,ik,kk] [--check FILE]`** (`rs/duel-tools/src/cvc.rs`): per pair, debug 2102 (turbo) then
3000 / 4000 / 5000 + SEED (START-CVC), played by both CPUs to the end; prints GO-RESULTS's RESULTS line (built where the flow becomes
RESULTS, at `*step-hook*`'s place: its tick and Konpaku are that step's; secs `~,1f` of the single `(/ tick 60.0)` through
`cl::fmt_fixed_f32`) and HASH-LOG's 600-tick hash lines, after the pair's name. `--check` compares them with FILE's lines of the pairs run
(its `#` lines skipped), exit 1 at the first difference. Only seed 7 is checked against a key; another seed's `~,1f` on a tick ≡ 3 mod 6
(a tie at the second decimal) is untested. Test `cvc_equals_the_tag`.

**MC-FULL-LOG and STRAT-LOG** (GO-RESULTS's cost lines: decisions, rollouts, milliseconds) are never compared and are not G2's lines:
not ported. Task 8's unused `mc_full_log` is deleted; `Search.mc_stats` / `strat_stats` keep the counts (the speed bench reads the
rollouts from them). `Search.clock` stays the caller's (MC-FULL-STEP's and STRAT-FULL-STEP's time sums).

**The game loop's frame.** `flow::frame` returns false once the sim reached an `unported!` path, in the match (`m.unported`) or in a CPU
rollout (`Search.cut`). No step runs past either: `advance_sim`'s loops stop on both (the rest of the frame's steps are skipped, up to 119
in turbo), and a frame called again returns false at once without running anything. So M3's loop stops and shows the name instead of
freezing or playing on silently (M1 §10's carry; fix round 1). dt as an argument stays M3's. `PilotInput::rollout_read` is a required method (an M3 device can't forget its in-rollout write).

**Strict arguments.** `duel-tools` refuses an unknown token, a flag without its value or with a bad one, and two flags pasted into one
token (exit 2 with the usage); `replay --live` refuses `--stub` / `--mask` (a live run compares everything); `--bench` takes only `--live`
and `--data`. `replay-gate.sh` fails a CPU rollout cut short by an `unported!` path (`replay UNPORTED … in a rollout from tick …`) as
`CPU-UNP`, even with `--allow-unported`, as it fails a `--snap` cut (`SNAP-UNP`).

**0 allocations per battle step with both CPUs on** (ruling R8; `duel-tools` `live_allocs`): each of the 15 cvc gate traces' S-line
commands run live (no reader; the combat log off after the commands' frame, as `--bench`), counted over every frame that starts and ends
in the battle: **0 in each** (13,920-21,840 battle steps a trace; cvc-ii-s1 66 decisions / 132 rollouts, cvctag-ii 80 / 160). Before:
210 (cvc-ki-s1) and 217 (cvc-ii-s1). What went:
- a runtime HITWIN's `vols` / `flags`, an ICC's `queued` / `rq` and the clone lists (ICHIGO-CLONES, ICHIGO-LIVE-CLONES, CLONE-SPAWN's
  births, ICHIGO-VANISH's places) are `components::Few<T, N>`: inline, Deref to a slice, `push` / `insert` past N panic (never truncate).
  The caps: 2 volumes and 4 flags (the data's windows hold 1 and 2, ECHO-HITWIN adds :BLADE), 16 clones and 16 queued replays (the 15 cvc
  traces at most 3 clones and 1 queued move);
- with that `HitWin`, `Hazard` and `Icc` are `Copy`: their hand-written `clone_from` went, and with it MC-FULL-STEP's 4 (a slot, then the
  scratch, copying an `Icc.rq` Vec) and CORE-HAZARD-NOHIT!'s hazard copy;
- `Fighter.brain` is boxed (speed, §10); `Option<Box<Brain>>::clone_from` restores in place, so a snapshot still allocates nothing.

Outside the gate, as the Lisp conses: a learning VS match (vs-learn's) clones BRAIN-FQL's records with each snapshot and rollout
(`Brain.fql`, `clone_from`) and pushes a record per judgement (FQ-NOTE); the leaked copy per learned match (§12, M3).

## 10. Speed with both CPUs on (Task 10)

BEVY_PORT §6.4's measure is "cvc turbo": the CPUs playing. Both sides run a cvc trace's match from its S line with both brains thinking,
nothing injected, the combat log off after the commands' frame, the trace read and the first frame before the clock, no comparison; each
run checks it reproduced the trace (its step count and last H). Rust: `duel-tools replay TRACE --live --bench`, the median of 11 runs in
one process. Lisp: `tools/port/sim-bench.lisp … TRACE brains` (its new mode: the hooks only count; `*combat-log*` and `*stats-log*` off,
the port having no stats work), the median of 5 process runs, on `build/simgate/duel.fas` with the musl preload (M1 §5). Rollouts a
second = CPU rollouts (MC-FULL-STEP's and STRAT-ROLL's) over the match's wall time, not a rollout's own speed.

| Trace | Lisp brains on | Rust `--live --bench` | Ratio | Rust wasm32 (node) | Rollouts: count, Lisp / Rust a second |
|---|---|---|---|---|---|
| cvc-kk-s1 (18133 steps) | 142,427 steps/s (0.127 s) | 450,895 (0.040 s) | **3.17×** | 277,878 | 0 (n/a: KK queues no job) |
| cvc-ki-s1 (21368) | 118,099 | 402,225 | **3.41×** | 248,539 | 24, 133 / 452 |
| cvc-ii-s1 (19423) | 74,925 | 268,818 | **3.59×** | 169,972 | 132, 509 / 1,827 |

The gate (≥ 3×) passes. Lisp spread over 5 runs ±4 %; Rust's under 5 %. The brainless bench (M1's measure) on the same build: 1,177,064 /
1,033,146 / 877,893 steps/s, 4.7 / 4.5 / 3.7× M1's Lisp figures, unchanged. `duel-tools.wasm` is 7.29 MB (M1: 6.7).

How it got there (each step bit-exact on the 17 live rows): the first live measure, at Task 9's code, was 186k / 184k / 133k steps/s on KK / KI /
II (1.3-1.8×). A sampling profile (gdb as the parent sending SIGUSR2 every 2 ms: `perf` is not allowed on this machine) put the time in
name lookups, as M1's was:
- KIT-MOVE scanned the kit's ids, then the 549 moves by id, per call (STRAT-FEATS calls it three times a brain step): `Kit.move_ix`, a
  sorted name → move index built by `Data::parse` (derived, not data: no extractor change, the checksum `3ddcd77c9a34edf5` unchanged),
  and the match's `KitTable` now holds each kit's KIT-COMMAND-MOVE :q and KIT-CORE-MOVE :ns 1-3 for STRAT-FEATS. That gave 2.4-2.9×;
- the CPU took its 6.5 kB brain out of the fighter and put it back twice a brain step (CORE-BRAIN-STEP, BRAIN-PERCEIVE): `Fighter.brain`
  is boxed (made at a fighter's spawn, outside the battle);
- FZ-MU found a set by a case-folding scan of the 44 names for every antecedent of every rule: each name is also kept packed into a u64
  (`fuzzy::key8`, ≤ 8 bytes; every set name has ≤ 7), one integer compare a set;
- NOW's cues are written in place (no measurable change; kept).

**StyleState** (the ledger's M7): 1,400 bytes, of which the inline `Now` 1,048. On the three traces `take_style` is 0.5 % of the samples
and memory copies under a style function 0.2 %, so it stays unboxed (a box would allocate at each style switch, breaking the 0 B rule).
The big copy was the brain's. Where the time is now (KK / KI / II samples together): BRAIN-SYSTEM 59 %, the styles (STRAT-FN-STEP) 20 %,
MC-FULL-STEP's rollouts 13 % (most of it II's), the rest the sim. One more option, measured and not taken: `opt-level = 3` for duel-sim
(release is `z`, the page's setting) gave 4.6-5.5× after the KIT-MOVE index, before the brain box; it is the page's size trade, the lead's call.

## 11. Coverage of `cpu/` by the 17 live traces (Task 10)

Method: duel-tools built with `-C instrument-coverage` in its own target directory (`rustup component add llvm-tools`: the system's
llvm-profdata 18 cannot read rustc 1.99's LLVM 23 profiles), the 17 live rows run once plainly and once with `--snap 40`, merged with
`llvm-profdata`, functions and lines read from `llvm-cov export` / `llvm-cov show`. Function names are those whose first region starts on
their `fn` line (closures are not counted separately).

**`rs/duel-sim/src/cpu/`: 399 functions, 339 reached by the 17 live traces, 60 never.** Only `mcts::sim_rollout` is reached by the
`--snap` rollouts alone (it is SIM-ROLLOUT, the tool's). The 60, by file (trait impls `fmt` / `default` / `eq` / `get` / `enc` included):
- `core_ai.rs`: `cai_switch_press`, `cai_switch_target` (CAI-DSWITCH's: Hisagi arms only), `cai_style` (the matchup style without a
  strategy: every gate CPU has a strategy);
- `glue.rs`: `strat_feats` (the copying form; the step writes in place), `style_roll`, `cai_style_fn`, `strat_event_call` (an event arm
  running a style), the strategy layer (`brain_set_strat`, `strat_request`, `strat_layer_step`, `strat_roll`, `strat_full_step`: ruling R4,
  host test `strat_full_step_picks_after_its_rolls`);
- `ken_ki.rs`: `ken_ki_style` (KEN-KI-STYLE: the gate's Kenpachi plays the KH / stand-off styles), `kk_juji_start`, `kk_wave_tick`,
  `kk_wave_mix`, `kk_attack_in`, `kk_close_hit`, `kk_chase_step`, `kk_facing_p`, three `default`s;
- `ichigo_ki.rs`: `ichigo_ki_style` (the plain ICHIGO-KI-STYLE: the gate plays R2B2A1), two `default`s;
- `strategy.rs`: the strategy layer's and the tools' pure part (`strat_arms`, `strat_seed_value`, `strat_prior`, `strat_puct`,
  `strat_final`, `strat_library_pos`, `strat_switch_to` / `_dir`, `strat_own` (composites: every gate table is a Q selector),
  `strat_unit_find`, `strat_compose`, `strat_arm`, `rule_keys`, `strat_with`, `strat_expand`, `switch_entry_expand`, `event_arm_expand`,
  `pairs`, `object`), `strat_value` (callers use `strat_value_of`), `fmt`, `get`, `enc`; all host-tested in `tests/strategy.rs`;
- `fq.rs`: `fq_reset_all` (RESET LEARNING, host test `page_roundtrip`), `eq`; `perceive.rs`: `snap_left_seen`, `ai_mash_p` (the masher,
  M5); `mod.rs`: `Brain::reset` (the stand-in brain's reuse: no vs trace queues a job), `fmt`, `default`; `style.rs`: `kks_mut`,
  `ikst_mut`, `get`; `xch_ai.rs`: `get`.

**M1 §5's carried items:**
- HOHO-RESUME (`fighter/moves.rs` `hoho_resume`): **reached, 3 times**, by the latched path (a J pressed during the Hoho step, resumed at
  its end through KIT-NEXT :q from an NA / AS). Never: the NS route (MV-NS-NEXT / the SA), the SP command, the AS start, and
  HOHO-RESUME-PRESS! (the press in the neutral window after the Hoho: `fighter/states.rs` 0 past its test).
- CUT-HAZARDS (`combat.rs`): runs every step, Nozarashi's open windows 6,910 times, but **no Ichigo wave is ever inside one**: the cut's
  verdict (lines 860-877) never runs.
- Task 11's untraced Kenpachi list (M1 §10: "the KR / ZH / Z2 Kikon cinematics, the stance / charge / flurry / cracks"), item by item, in
  the 17 live rows with and without `--snap 40` (`ken/hooks.rs`, `ken/cine.rs`):
  - KE-BUTTAGIRU's `ground_crack`, KE-CHARGE's `charge_tick`, KE-FLURRY's `flurry`: **0** (no CPU starts them either: their `:sp1` /
    `:sp2` commands stay in MOVE-COMMANDS' dead clauses);
  - the stance: KEN-STANCE-RELEASE (`stance_release`, the stance's cut) **0**;
  - KR-KIKON and ZH-KIKON **never play**: their director scripts (`script`'s `(KrKikon, 0)` / `(ZhKikon, 0)` arms) are 0, and so their
    DURING draw arms;
  - Z-KIKON2 **plays**: its script's frame 0 runs twice (its DURING is looks only); Z-KIKON1 and S-KIKON1 play and their DURING draw
    arms run; S-KIKON2's script starts once but its DURING draw arm is 0 (no frame of it was drawn);
  - also 0, beyond the list: KEN-BK-SLAM (`bk_slam`), KEN-TATEGOTO-SPLIT (`tategoto_split`), KEN-TATEGOTO-CUT (`tategoto_cut`). M1 saw
    TATEGOTO start 3 times in its 22, so in the brainless trial / scripted rows, which are not live;
  - KEN-BANKAI-CINE: **0** (the Bankai is entered 6 times, without it, as M1 found).
  Their host tests (`tests/ken.rs`) stay the only check of every 0 here.

**HARD-only paths:** the only HARD CPU in the 17 is vs-learn's learner (the cvc gate is NORMAL, vs-cpu NORMAL), and its MC-NEUTRAL
(entered 897 times) never gets past the state test, so no HARD search runs: the decoupled UCT branch of `Lite::search` 0, the HARD outcome
table (`mc_outcomes_of`) 0 in vs-learn. Host tests `duct_search_matches_the_lisp` and `hard_defers_on_a_thin_margin` cover them.
FQ-ATTACH!'s HARD test and the HARD table chance are reached (vs-learn learns).

## 12. What M2 hands on (from the ledger, `.superpowers/sdd/2026-11-27-m2-cpu/progress.md`)

**Rulings:**

| | Ruling | Where it stands |
|---|---|---|
| R1 | Task 4 creates `cpu/style.rs` with `resolve()` naming no style (call site `unported!("style <NAME>")`); Task 5 fills the names | done: Tasks 6-7 ported the four gate styles; Hisagi's resolve to `unported!` (M4) |
| R2 | Task 3 may modify `gate.rs` (the `// cpu:` difficulty marker) | done |
| R3 | MCTS jobs are rare; the stand-in brain for a human stays host-tested (`stand_in_brain_for_human`), no extra trace | stands: no vs trace queues a job (§8, §11) |
| R4 | the strategy layer (STRAT-FULL-STEP) is unreached; ported with host tests | stands: its functions 0 in §11 |
| R5 | `--inject-plan` copies MC-FULL-STEP's plan changes from the next record; job sections not compared under it | done; redundant since Task 8, still passes |
| R6 | musl's expf in `cl.rs`, checked over all 2^32 inputs; libm's sinf / cosf / atan2f stay | done (hash `eae4f603b90fd236`, `tools/port/musl-hash.c`) |
| R7 | `(expt <single> 2)` is powf in ECL: every site through `cl::expt2` | done (combat.rs, hazards.rs) |
| R8 | 0 allocations per battle step with both CPUs on, measured on the cvc gate traces; the learner's consing stays outside | done: 0 on all 15 (§9) |

**Carries to M3:**
- the fq copies are leaked `&'static` values, one per load and per learned match (~85 kB each; 5-9 MB per 100 learned matches on a wasm
  heap that never shrinks): an owned arena in `Search` before the phone build (fq.rs `ponytail:`);
- `view_behind` is hard-wired to `*cam-behind*` T; SET-CAM-BEHIND is `(and (or *cam-behind* *one-hand*) (vs-cpu-p) t)`: the settings
  and the touch deck own it;
- the game loop calls `cine::cine_draw` once per rendered frame after the frame's steps (a played cinematic's DURING forms move the
  actors: DIVERGENCES §1); `flow::frame` does it today, M3's loop must keep the order (and skip it in turbo);
- FQ-MATCH-END runs in two halves (`fq_match_end_take` in GO-RESULTS inside `sim_core`, `fq_match_end_apply` at `sim_step`'s end, §8): a
  new caller of GO-RESULTS outside `sim_step` must apply the queued half;
- input-test.lisp's 7 device checks (PORTED.md) go with the touch deck's tests (the devices are the page's input);
- the loop stops when `flow::frame` returns false and shows `m.unported` / `Search.cut`; dt as an argument;
- each device implements `PilotInput::rollout_read` (the held keys written again inside a rollout, DIVERGENCES §1);
- M1's touch stubs (M1 §10) still hold for the human seat;
- the fixed-capacity lists' memory (fix round 1, measured): `size_of::<Icc>()` is 336 bytes (`rq`'s 16 inline entries are 256 of them;
  about 110 with the two Vecs, estimated, plus their heap), and every `Match` reserves `ICC_RESERVE` = 1024 of them: 344 kB a match, 2.06 MB for the six a CPU match
  holds (the live one, `cpu::POOL`'s 4 snapshot slots, the rollout scratch). Lowering the reserve needs a bound the Lisp does not give
  (ICCs are never freed inside a match and each NS3 / AS3 clone makes one), so it stays; M3's phone budget counts it (or the iccs could be
  reclaimed when their hazards die, a redesign).

**Carries to M4:** Hisagi's and Yamamoto's CPUs (`cpu-hisagi-*`, `cpu-ih-*`, `cpu-hk-*`, their styles resolve to `unported!`); CAI-NEUTRAL's
finish passes no E to KIT-COMMAND-MOVE, and STRAT-FEATS reads the :q move from the match's `KitTable` (no E either): both are wrong for a
kit with a `:command` hook (Hisagi only), so add an `unported!` guard there with Hisagi; CAI-DSWITCH (Hisagi arms only) untraced.

**Carries to M5:** the masher (`masher.lisp`, debug 81030+: `unported!("masher-step")`, `ai_mash_p` unreached); the debug commands the
scripts use.

**Deferred minors** (none blocks M2; each kept as it is unless its milestone touches it):
- Task 1: TR-A-STRAT collapses any keyword plist with an :ID to `#s:<id>` under `*tr-a*`; `*tr-a*` is a special read by TR-B-ENC (a
  hidden channel in the recorder); vs-learn.lisp's comment says "fq load 1 3", the trace and M0_NOTES say "3 1"; the `#FN` fields are never
  compared; the full no-name `gen.py sim` was not run.
- Task 2: `--resync` turns an UNPORTED exit into 1 after any mismatch. (`--live` with `--mask` / `--stub`: refused since Task 10.)
- Task 4: a nested `unported!` helper returns a default and THINK goes on (harmless: the replay stops at the step); `as_by_press` None
  reads 3 where the Lisp's present NIL would (not in the data).
- Task 5: a composite's NIL-arm sub becomes `Some([OWN])` (dead today); the "every shipped CPU" wording about CAI-DSWITCH overclaims;
  `event_arm_expand` assumes serde_json's sorted object order (load / test time only).
- Task 6: no scripted unit test of KK-WAVE-STEP's :cut → :chase hand-off (KK's waves are unreached, §11).
- Task 7: ICHIGO-KI-R2B1A1-STYLE is not ported (nothing names it); `IKW::enc` hard-codes `,NIL,(NIL)` where the gap-off arm prints.
- Task 8: IKW's ALT / CELL in the A line are unverified (no keyed trace reaches gap-off; a `--snap` rollout of cvctag-ii does).
- Task 9: the KR / ZH / S-KIKON2 DURING ports (0 in §11) and the replayer's `rollout_read` are matched by reading only.

**Ledger items closed in Task 10:** duel-tools' argument errors (T4 minor); `--live` with `--mask` / `--stub` (T2 minor); the cut CPU
rollout in the gate (T8 M3); `mc_full_log` / STRAT-LOG (T8 M5: deleted, never compared); StyleState's copy (T8 M7: measured, left);
the stale `Strat` comment (T9 M5); `rollout_read` required (T9 M7); the learning match's allocations documented (T9 M2); the live 0 B
count (T6 minor, R8); the plan's M1 carries owned by Task 10 (the loop surfacing `m.unported`, the speed gate with the CPU on, the
coverage run, wasm32 in the gate). Earlier tasks closed their own carries (T2-T9 lines in the ledger: jstarts / sw_keep capacity,
Search through `start_match`, the C split, the snapshot walk into the fq copy, MC-SETUP's NIL case, IKW gap-off, IKS-MODE-PICK's
ratios, TSUKI-DASH's test, the 77 defparameters, the KKS panic).
