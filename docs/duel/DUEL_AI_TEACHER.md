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
- **A rollout**: `sim-step`s with the logs off (`*pacing-log*`, `*combat-log*`, `*gate-log*`, `*step-hook*`), ending at a K.O.,
  time-up, a cinematic or the flow leaving battle.
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
