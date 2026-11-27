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
DURING blocks; Rust ports only their endpoint KE-KK-AT calls (ken/cine.rs), so there is nothing to change. The 22 M1 traces stay OK.

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
