# An offline MCTS teacher for a human-like CPU (2026-11-07, in design)

The CPU's next step after the matchup style CPUs (DUEL_MATCHUP_AI): a search over the native sim that tells, per situation, how good
each option is, so that a CPU can be built to play like a person. Earlier talk: fuzzy rules and MCTS (DEVLOG §621–§622 context;
the answers in the session of 2026-11-07).

## 1. Decisions (the user, 2026-11-07, asked with AskUserQuestion)

| Question | Options | The user's choice |
|---|---|---|
| The CPU's main goal next | human-like and readable (recommended) / stronger / a character per pairing / a smooth difficulty curve | 「像人、讀得懂」 |
| Where to start | fuzzy rules in the generic CPU (recommended) / a sim snapshot + an offline MCTS / the next style CPU pairing / a design doc first | 「狀態存檔 + 離線 MCTS」 |
| The snapshot (§2) | fork for the offline teacher first (recommended) / the engine snapshot from the start | 「一開始就做引擎內建存檔」 |
| The opponent model in the rollouts | the generic CPU / the KI style CPUs / a mix (recommended) | 「混合」 |
| "Human-like" in numbers: reaction delay per difficulty, a mistake budget, readability (one cue, one behaviour; a tell before a big move) | add / change / drop any | 「OK」 |
| The pilot pairing | Kenpachi vs Ichigo (recommended: its evaluator and dream-rsi style CPUs to compare against) | 「OK」 |
| The ~60 subagent worktrees the KI search left | clear them | 「清除」: 63 removed with their branches (all merged; their dirty files were the cells' candidate CPUs, kept in `docs/research/ki-ai-drsi/`), 2026-11-07 |

## 2. The snapshot: fork, measured (2026-11-07)

- Native speed now: one simgate process plays ~154,000 steps a second (IK 20 seeds, turbo, both CPUs); 16 processes run at once.
- `fork()` from compiled Lisp in the native process (`ffi:c-inline`), mid-match with the whole game loaded: **1.74 ms** per fork + the
  child's `_exit` + the parent's `wait` (1000 cycles; 0.39 ms with a 4 MB heap). The child's writes never reach the parent.
- A 60-step rollout is ~0.4 ms of sim, so a forked rollout costs ~2.1 ms: ~470 a second a core, ~7,500 on 16 processes.
- The alternative, a snapshot inside the engine (copy every component, the hazards, the sim's globals, the C RNG `rng2_state`):
  rollouts at the sim's own speed (~5x more) and usable in the browser, but every piece of sim state must be listed, and a missed
  one corrupts the rollouts silently (its test: snapshot, restore, run must reproduce the straight run's hash lines).
- Proposed: fork for the offline teacher; an engine snapshot only if an online use comes. **Decided otherwise: the engine snapshot from
  the start** (§1), so the teacher runs at the sim's own speed and the browser can use the same snapshot later.

## 3. The teacher and the human-like CPU (proposal, under discussion)

- **Decision points**: the generic CPU's own (neutral, after a block, after a whiff, on wake-up, after a Hoho), not every frame.
- **Situation features**: only cues a player can see: the distance band, both fighters' states and frames, the HUD gauges (the HUD
  reads accepted in DUEL_MATCHUP_AI §9 / §11), pointer, form.
- **Macro actions**: J1, NS (the pointer's), the SA, Step in / out / sideways, Hoho, guard N frames, wait N frames, walk in / out.
- **Rollout**: fork, apply the action, play 60–120 steps with an opponent model, score (Reishi and Konpaku difference, who acts
  first); a mean and a spread over seeds.
- **Output**: a table situation x action -> value (mean, spread, samples).
- **From values to a person**: choose by a softmax over the values with a temperature per difficulty, a reaction delay from the cue,
  commitment (no frame-perfect switching), a few habits per character; mistakes that lose little are allowed, mistakes that lose
  much are not; each rule keyed on a visible cue (readable).

## 4. Open questions (answered 2026-11-07, §1)

1. Snapshot: the engine snapshot.
2. The opponent model in the rollouts: a mix of the generic CPU and the KI style CPUs.
3. "Human-like": reaction delay per difficulty, a mistake budget, readability, as proposed.
4. The pilot pairing: Kenpachi vs Ichigo.

## 5. The engine snapshot: scope, rule, pass condition (2026-11-07)

- **What it is**: `snapshot` saves the sim's state, `restore` puts it back, as many times as a search needs. Engine part:
  `engine/lisp/snapshot.lisp` (the walker, the ECS bookkeeping, the C sim RNG `rng2_state`); the game's part: `duel/lisp/sim-state.lisp`
  (its roots, its shared definition types, the rollout). Plain Lisp, no POSIX: the browser can use it later.
- **In place**: restore writes the saved contents back into the **same objects**, never fresh copies, so `eq` tests (a move compared
  with `eq`) and aliasing (a pilot's vpad is the one the brain writes) survive. The snapshot walks from the roots, memoised by identity:
  a struct's slots, an array's elements, a cons's car and cdr, a hash table's entries; it stops at shared definitions (kits, moves,
  hit windows, clips, bodies, weapons, meshes, glyphs; functions, symbols, strings, numbers), which the sim never writes.
- **Roots**: the ECS stores and bookkeeping (`*stores*`, `*used*`, `*generation*`, `*top*`: slot reuse decides the entity order and the
  handles, so a hazard spawned in a rollout leaves no trace), the C sim RNG, and the game's registered globals (the match clock, the
  flow, the cinematic, hitstop and slow motion, ...). The list grows by what the test finds; it is not classified by hand up front.
- **When**: only in battle and outside a cinematic (`snapshot` returns NIL otherwise).
- **A rollout**: `sim-step`s with the logs off (`*pacing-log*`, `*combat-log*`, `*gate-log*`, `*step-hook*`), ending when the flow leaves
  the battle. Since §6 it skips cinematics (`*skip-cines*`: one ends at once with its AFTER), so a Kikon's Konpaku is settled inside the
  rollout and it goes on (it used to stop at a cinematic's start, which left the Kikon's result out); the pollution test passed again
  with it (IK, KK, 4 seeds).
- **Pass condition (the pollution test, native sim)**: the same seeded matches run straight and with a rollout every ~40 ticks
  (snapshot, 60–120 steps on a reseeded sim RNG so the CPUs play differently, restore); every hash / gate / pacing line and every result
  must match the straight run. Pairings IK and KI (the KI style CPUs on: the rollout opponents chosen in §1), II and KK.
- **Speed target**: snapshot + restore well under the rollout itself (~0.4 ms for 60 steps natively); fork costs 1.74 ms (§2).
- **Inert**: nothing calls it in play; G2 `--cvc` identical, native and browser.

### 5.1 Built and passed (2026-11-08)

- `engine/lisp/snapshot.lisp` (the walker; engine roots: the ECS stores and bookkeeping, `*hitstop*` / `*tick*` / `*slowmo*`, `*cine*`; the
  C sim RNG), `duel/lisp/sim-state.lisp` (the shared types, the game's roots, `sim-snapshot-ok-p`, `sim-rollout`), `*log-mute*` in the
  engine's `log-msg` (a rollout prints nothing), `tools/simgate/snaptest.lisp` (the pollution test).
- The struct slot count is read in C (`instance.length`): compiled, `si:instancep` is only a predicate.
- **What the test found**: only one missing piece, the cinematic's start-up state. A rollout ends in the step that starts a cinematic,
  and that step already set `*cine-placed*` / `*cine-placed-e*` (where CINE-END gives the actors back): after the restore, the next
  real cinematic gave them back to the rollout's places (IK seed 1, tick 5868, the first divergence by the per-tick digest). Every
  global cinema.lisp sets at a cinematic's start is a root now.
- **Pass**: IK (the KI style CPUs on), KK, II, HK, HI, 20 seeds each: every line equal to the straight run; ~38,500 rollouts of 60–120
  steps (82 % of them ended in a different state from the match at the same tick: the rollouts play differently, IK seed 1, 205 of 251).
- **Speed** (native, IK mid-match, 173 objects): snapshot 217 us, **restore 33 us**, a 60-step rollout + restore 334 us: ~3,000
  rollouts a second a core, ~48,000 on 16 processes (fork: ~7,500). A teacher snapshots once per decision point and restores per
  rollout, so restore is the cost that counts.
- **Inert**: host tests, pkgcheck, G2 identical native and browser; nothing in play calls it. wasm 10.99 -> 11.00 MB.

## 6. The teacher, stage 1: action values (2026-11-08)

`tools/simgate/teacher.lisp` (offline only; not in the game). Asked: 「OK」 to the plan (a macro executor, a score, the KI pilot).

- **Decision points**: a side that is free (idle or running), its brain holding no press, the sim snapshottable; at most one per side
  every 20 ticks, from tick 2.
- **Macro actions** through the side's brain (the CPU's own press fields, so the input path is the CPU's): J1, SP (the pointer's NS, a
  tap), Hoho, Step in / out / sideways, guard 20 f, wait 20 f, walk in / out 20 f (the stick alone). A probe from one point (IK, tick 370,
  5.4 m) showed each doing its own thing: walk in 5.4 -> 3.9 m in 12 steps, wait 4.6 (he came in), Step out 6.9, Hoho to 1.4.
- **A sample**: restore, the sim RNG reseeded with the sample's seed (the same 16 seeds for every action: common random numbers), the
  press, then 180 steps (3 s) with the side on the generic CPU and the opponent on its style CPU in even samples, the generic CPU in odd
  ones (the mixed opponent model, §1), cinematics skipped.
- **The score**: the opponent's health lost minus the side's, health = Konpaku + 1.5 x the Reishi bar's fraction (~3 Konpaku cash out
  of a bar by Kikon / Soul Break, halved; a knob). 90 steps left too many ties: 1.5 of a point's 10 actions tied another exactly (the
  same seeds, no hit changed), 0.74 at 180.
- **Untouched match**: the match plays on after each point exactly as without the teacher (IK seed 1's gate row equal to the straight
  run's).
- **Cost**: IK seeds 1–20 on 16 processes in 3 min 5 s: 10,589 decision points, 1,694,240 rollouts.
- **The table** (P1 Ichigo, P2 Kenpachi; `tools/teach-summary.py`, situations with 40+ points; the best, the second, the worst by mean):

| Side | Distance | Opponent | n | Best | Second | Worst |
|---|---|---|---|---|---|---|
| Ichigo | < 2 m | idle | 1038 | J1 +0.020 | SP −0.022 | Step in −0.135 |
| Ichigo | < 2 m | in his move's active part | 634 | J1 +0.085 | Hoho +0.007 | wait −0.089 |
| Ichigo | < 2 m | stunned | 198 | J1 +0.110 | SP −0.008 | wait −0.118 |
| Ichigo | < 2 m | down | 170 | wait +0.048 | guard +0.047 | J1 −0.044 |
| Ichigo | < 2 m | waking up | 77 | SP +0.133 | walk in +0.062 | J1 −0.108 |
| Ichigo | 2–4 m | idle | 1535 | Step out −0.026 | Step side −0.037 | Step in −0.167 |
| Ichigo | 2–4 m | down | 145 | Hoho +0.092 | walk in +0.084 | Step out −0.036 |
| Ichigo | 7+ m | idle | 299 | walk out +0.077 | Hoho +0.035 | Step in −0.085 |
| Kenpachi | < 2 m | idle | 997 | J1 +0.085 | SP +0.068 | Step in −0.024 |
| Kenpachi | < 2 m | in Ichigo's move's active part | 349 | Hoho +0.079 | J1 +0.046 | wait −0.100 |
| Kenpachi | < 2 m | stunned | 307 | J1 +0.183 | SP +0.150 | Step side +0.007 |
| Kenpachi | 2–4 m | idle | 1566 | SP +0.150 | J1 +0.073 | Step in −0.031 |
| Kenpachi | 2–4 m | down | 493 | Step in +0.117 | wait +0.108 | SP +0.028 |
| Kenpachi | 2–4 m | waking up | 40 | SP +0.195 | walk in +0.074 | J1 −0.032 |
| Kenpachi | 4–7 m | idle | 411 | Step out +0.068 | walk out +0.029 | SP −0.012 |
| Kenpachi | 7+ m | idle | 301 | walk out +0.124 | walk in +0.114 | SP +0.014 |

- **Reads as**: a stun is punished with J1 on both sides; in his move's active part close, Kenpachi Hohos and waiting is the worst;
  a fallen opponent: Ichigo doesn't press into the wake-up, Kenpachi steps in for the meaty; the wake-up itself is SP's; mid range is
  Kenpachi's (his SP +0.150; Ichigo's every option there negative, Step in the worst), as the KI search found.
- **The bias to remember**: far off, backing away is best for both. The rollouts' continuation is the generic CPU, which walks into the
  other's reach, so whoever comes in loses. The values are "against these CPUs", not against a person; the next stage has to decide
  what the continuation and the opponent should be.
