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

## 7. Iterating the continuation: the teacher CPU (2026-11-08)

Asked (§6's bias): iterate (recommended) / the player's own data / use the table as it is. **The user: 「反覆修正」.**

- **The teacher CPU** (`teach-policy`, tools/simgate/teacher.lisp; rollouts only): free (idle or running), it looks up (its character,
  the distance band < 2 / 4 / 7 m / beyond, the opponent's state, :move with its phase) in the last round's table and draws an action by a
  softmax over the values (temperature 0.03; env `TEACH_TAU`); anything else is the generic CPU's. It is a core-CPU style function, so the
  rollouts bind it through `*cai-styles*`. Its draw steps the sim stream's state in Lisp (`teach-rnd01`: SIM-RND01 is a C-INLINE macro the
  interpreted file can't run).
- **A round with a table** (env `TEACH_TABLE`): the side continues on the teacher CPU; the opponent is the teacher CPU / his style CPU /
  the generic CPU in turn (sample mod 3: the mixed model of §1 with the teacher added). Tables: `tools/teach-table.py` (situations with
  10+ points: 30 of 51), compared by `tools/teach-compare.py` (per situation with 40+ points, the best action and the ten actions' rank
  correlation). The three rounds' tables: `docs/research/ai-teacher/ki-table-r1.lisp` .. `-r3.lisp`.
- **Rounds** (IK seeds 1–20 each, 10,589 points, 1.69M rollouts, ~3 min 15 s on 16 processes):

| | Best action unchanged (of 26) | Mean rank correlation |
|---|---|---|
| round 1 -> 2 | 16 | 0.67 |
| round 2 -> 3 | 24 | 0.82 |

- **The bias faded**: far off, Kenpachi's best went from backing away to walking in (4–7 m: Step out +0.068 -> walk in +0.071 -> +0.049;
  beyond 7 m: walk out +0.124 -> walk in +0.075 -> +0.053); Ichigo's backing away beyond 7 m shrank to nothing (+0.077 -> +0.027 ->
  +0.004). The close-range reads held from round 1 (rank correlation 0.8–1.0: J1 on a stun, Kenpachi's Hoho against a move, SP on a
  wake-up; Kenpachi's mid-range SP +0.150 -> +0.128 -> +0.113).
- Round 3's table is the input to the next stage (the human-like CPU: reaction delay, the mistake budget, readability, §1).

## 8. The teacher CPU in the game: the KI neutral (2026-11-08)

Asked how it goes in: the KI pairing's neutral only, a pilot (recommended) / a tools-only option first. **The user: 「A」.**

- **`duel/lisp/cpu-ki-teacher.lisp`**: wraps the matchup style CPUs (`ken-kt-style`, `ichigo-kt-style`). Free (idle or running) and not
  able to awaken, a KI fighter's CPU looks up its situation **as perceived** (its character, its form, the perceived distance band, the
  opponent's SNAP state: the difficulty's perception delay `*ai-delay*` 24 / 14 / 8 f is its reaction time, kept rather than §1's
  proposed 24 / 16 / 10), keeps the actions within the difficulty's mistake budget of the best (`*kt-budget*` 0.10 / 0.05 / 0.02), and
  draws one by a softmax (`*kt-tau*` 0.05 / 0.03 / 0.015); a wait / guard / walk holds 20 f. Anything else (moves, combos, stun, the
  awakening, an unseen situation, e.g. Kenpachi's Bankai, too rare in the tables) stays the style CPU's. The tables are baked in.
- **Strength, first** (form-less tables, 40 IK seeds, wins Ichigo : Kenpachi; the baseline = both on the style CPUs: NORMAL 5 : 35,
  HARD 19 : 21): NORMAL Ichigo's teacher 32 : 8, Kenpachi's 2 : 38, both 26 : 14; HARD Ichigo's 6 : 34, Kenpachi's 34 : 6. Asked: EASY /
  NORMAL on the teacher, HARD on the style CPUs (recommended) / the teacher everywhere / everywhere and strengthen HARD / playtest first.
  **The user: 「全部用老師，並加強 HARD」.**
- **HARD's own table**: rounds at HARD with the opponent always on his style CPU (the strongest version; env `TEACH_OPP=style`, the game's
  teacher neutral off in the base match: `TEACH_KT_OFF`). Form-less: HARD Ichigo's teacher 31 : 9, Kenpachi's 40 : 0. Asked: put the form
  in the key and redo the tables before shipping (recommended) / ship with Kenpachi's HARD on his style CPU / Kenpachi all on his style
  CPU. **The user: 「分類加上型態、重算表再上線」.**
- **With the form** (key (character form band ostate); round 1 rebuilt from round 1's logs, which had the form; NORMAL rounds 2–3:
  best unchanged 20 / 25 of 36, rank correlation 0.64 / 0.78; HARD h1–h2: 20 of 39, 0.60): NORMAL Ichigo's teacher 35 : 5, Kenpachi's
  4 : 36 (his style CPU 35), both 27 : 13; HARD Ichigo's 32 : 8, **Kenpachi's 35 : 4** (his style CPU 21), both 16 : 24. Kenpachi's
  HARD still loses: his searched CPU never starts a move Ichigo's timed perfect Hoho sees while it is ready (DUEL_MATCHUP_AI §11), and the
  key lacks her Hoho's readiness, so the table averages "she can" with "she can't".
- **Shipped**: the teacher in every difficulty for Ichigo, EASY / NORMAL for Kenpachi; Kenpachi's HARD stays on his style CPU
  (`*kt-off-at*`) until the key carries her Hoho's readiness (next). Tables: `docs/research/ai-teacher/ki-table-form-r1..r3.lisp`,
  `ki-table-form-hard-h1..h2.lisp` (the form-less ones kept beside them). G2 IK regenerated (24 lines, P1 5-0, 239.1 s; before 25, P2
  0-7, 244.5 s), browser = native; II KK identical. The manual's CPU VS CPU row says so. Playtest v355.

## 9. The in-game MCTS over a light model (2026-11-08)

The user: 「幫我實作遊戲中即時 MCTS，並用你先前建議的輕量模擬版本來減輕負擔」 (the light model and the evaluation cut-off proposed in the
session's speed-up list: an abstract model of distance, both states, frames and the moves' reach, read from the kits; a short rollout scored
by a position value). Asked where it goes: patch the teacher's gaps (recommended) / replace everything / HARD only / a switch first.
**The user: 「全部取代」**: every pairing, every difficulty; the KI teacher's tables leave the game (kept in `docs/research/ai-teacher/`).
After the first strength runs (HARD much weaker), asked: HARD as it is (recommended) / MCTS everywhere, HARD weaker for now / keep fixing
HARD. **The user: 「繼續修 HARD」.**

### 9.1 What it is

- **`duel/lisp/mcts-lite.lisp`** (plain CL, host-tested `tests/duel-rules/mcts.lisp`): the light model and the search.
  - The neutral game to its first contact, on one axis: the distance (mm) and per fighter a state (free, wait, walk, guard, a move at its
    frame, a Step, a Hoho, a reel) with its frame.
  - Moves come from the kit as cached records (`mc-move-rec`): startup, the span of the hit windows, the whiff's end, reach and lunge, the
    triangle class, a wave's speed and range (a hitless move with `:params :speed :range`).
  - Each step the free fighters pick, move, and a hit window or a wave that reaches an open hurt circle connects; the first contact ends the
    rollout with its **outcome value**. A raised guard takes it as a block; two classed moves go through `core-verdict` (a cancel ends at 0, an
    absorb lets the move go on). An NS segment goes on to its next (`*cai-cont-p*`) and turns into the SA against an NA coming (`*cai-turn-p*`),
    by the searcher's difficulty. The opponent answers a threat with a perfect Hoho at `*mc-react-p*` (his Hoho ready). No contact within the
    horizon (60 steps + what the opponent still reels): 0.
  - **The search**: a two-level tree, side 0's action by UCB, then the opponent's reply to it by its own UCB (he starts it after
    `*mc-opp-delay*` 20 / 14 / 8 f: the CPUs' perception delays), the rollout policy `*mc-prior*` below. A fixed number of rollouts per
    difficulty (`*mc-iters*` 48 / 96 / 160; never a time: native = browser), fixnums only (UCB too: a float UCB consed ~1.3 KB a rollout),
    its own Park-Miller stream seeded per decision from the sim RNG's state (read, never drawn), no consing.
- **Outcome values** (`*mc-outcomes*`, `*mc-outcomes-hard*`): what a neutral contact is worth to its attacker per character form, measured in
  real CPU matches: `tools/simgate/contact.lisp` opens an exchange on the first contact after 20 quiet steps and closes it after 20 more, its
  value the health swing in the teacher's unit (Kikons and the whole route inside); IK KK II HK HI HH, 30 seeds each at NORMAL and HARD,
  25,786 contacts; baked by `tools/mc-outcomes.py` (NA hit, NS hit per pointer, AS / SA hit, perfect Hoho counter, block). HARD converts
  more (Kenpachi's NA hit 0.087 -> 0.235, his counter 0.113 -> 0.242), so the two difficulties have their own tables.
- **`duel/lisp/cpu-mcts.lisp`** (the game's side; was `cpu-ki-teacher.lisp`): `core-brain-step` asks `mc-neutral` first on every free step.
  Free (idle or running), within 7 m, not about to awaken, the opponent not airborne / down / waking: the start comes from what the CPU
  perceives (the SNAP: the perception delay is its reaction time; his form, pointer and Hoho's readiness from the HUD). The pick is the
  teacher's: within the mistake budget of the best (0.10 / 0.05 / 0.02), a softmax at 0.05 / 0.03 / 0.015, a wait / guard / walk held 20 f.
  At HARD it decides only when its best leads the second by `*mc-sure*` 0.16; else the CPU under it decides (and the search waits
  `*mc-defer-gap*` 6 steps; `*mc-next*` is sim state, a snapshot root). `*mc-off-at*` leaves Ichigo's HARD wholly on her style CPU. Anything
  else (moves, combos, stun, the opponent's knockdown and wake-up, the awakening, beyond 7 m) stays the matchup style CPU's or the generic one's.
- Cost (native): a search of 100 rollouts ~0.3 ms; over 10 IK matches the MCTS adds 1.2 s at NORMAL (~8 µs a frame on average) and 3.7 s
  at HARD (~29 µs: 160 rollouts, a search every 6 steps while it defers). Consing 48 KB a frame against 44 without it.

### 9.2 Fidelity against the full sim

`tools/simgate/teacher.lisp` with `TEACH_LITE=400` prints, at each decision point, the full sim's mean per action (16 rollouts of 180 steps,
the CPUs under the MCTS) and the light model's from the same situation; `tools/mc-fidelity.py` compares (best-action agreement, rank
correlation, the regret of the light model's pick, the teacher table's at the same points).
- NORMAL (IK seeds 21-32, 6,095 points): regret 0.099 (0.093 with no perfect-Hoho answer) against a uniform pick's 0.156 and the teacher
  table's 0.091; better than the table against a move in progress (0.069 / 0.083), worse against a lying opponent (worse than uniform: the
  reason his knockdown and wake-up stay with the CPU under it). The average value of each action matches the full sim's closely (j1 +0.027
  / +0.026, wait -0.018 / -0.019); per point it agrees weakly (rank r 0.21).
- HARD (the same seeds, 6,036 points): regret 0.210 against a uniform 0.235 and the table's 0.182; J1 overvalued (relative -0.060 in the
  full sim, +0.008 in the light model). Only its most decided fifth (margin >= 0.08) beats a uniform pick clearly (0.132 / 0.226): the
  reason for `*mc-sure*`.
- Variants tried (NORMAL): the horizon covering his reel (no change), 120 steps (no change), a uniform rollout policy (worse), the
  perfect-Hoho answer at 0 / 0.35 / 0.6 (0.093 / 0.099 / 0.102). Measured rate (a free, Hoho-ready defender within an NA / NS's reach +
  1.35 m): 1.6 % at NORMAL, 1.5 % (Ichigo) / 10.5 % (Kenpachi) at HARD; `*mc-react-p*` 0 / 0.02 / 0.05.

### 9.3 Strength (40 seeds, wins P1 : P2)

| Pairing, who is on the MCTS | NORMAL before | NORMAL | HARD before | HARD |
|---|---|---|---|---|
| IK, Ichigo | 5 : 35 | 31 : 9 | 19 : 21 | (off: her style CPU) |
| IK, Kenpachi | 5 : 35 | 0 : 40 | 19 : 21 | 80 seeds: 30 : 50 before, 27 : 53 |
| IK, both (as shipped) | 5 : 35 | 18 : 22 | 19 : 21 | 12 : 28 |
| HK, Hisagi | 2 : 38 | 9 : 31 | 4 : 36 | 7 : 33 |
| HK, Kenpachi | 2 : 38 | 2 : 38 | 4 : 36 | 3 : 37 |
| HI, Hisagi | 25 : 15 | 19 : 21 | 27 : 13 | 29 : 11 |
| HI, Ichigo | 25 : 15 | 16 : 24 | 27 : 13 | (off) |

"Before": both on the CPUs under the MCTS (the KI style CPUs, the generic one elsewhere). Kenpachi is not weaker anywhere; Hisagi against
Ichigo at NORMAL is (25 -> 19). As shipped before (v355, the KI teacher's tables: §8), KI was NORMAL 27 : 13 and HARD 32 : 8; now 18 : 22
and 12 : 28: Ichigo's HARD went from the teacher's table to her style CPU (`*mc-off-at*`), asked: the teacher's table back for that one cell (recommended) / her style CPU / playtest first. **The user: 「維持風格 CPU」**
(2026-11-08): the tables stay out of the game.
Noise: changing only the UCB's arithmetic (floats to fixnums) moved Kenpachi's HARD 21 -> 13 of 40, hence the 80-seed comparison.
Browser cost (desktop, real time, `run.mjs` without turbo, KK at HARD / NORMAL, 75 s each): the sim 0.06-0.32 ms a frame on average; two
slow frames at HARD with the sim at 12.1 / 14.6 ms (t 29 and t 1057; warm-up suspected, not confirmed), one at NORMAL with the sim at 5.7;
no CPU-throttled (phone) run.

How HARD was found and fixed, in order (Kenpachi's HARD wins of 40 against Ichigo's HARD style CPU, his style CPU 21):
1. The first model (a free, random opponent): 1 win. A decoupled bandit for the opponent's first pick: 6. The two-level tree with his
   reply delay: 0. NS chains and SA turns in the model: 1. The knobs (temperature, budget, rollouts, the perfect-Hoho answer) changed nothing.
2. Counting the hits: with the MCTS he landed 62 hits on her free frames in 10 HARD matches against 251 with his style CPU: the MCTS had
   taken his free steps while she was down, so his timed meaty J1 (`kk-meaty-step`) never ran. Her knockdown and wake-up back to the CPU
   under it: 7.
3. Per-difficulty outcomes, the measured perfect-Hoho rates and the margin gate: 21 at 0.08 (40 seeds); on 80 seeds 27 / 42 / 53 / 54 at
   0.08 / 0.12 / 0.16 / 0.25 against his style CPU's 50: **0.16**. Ichigo's HARD MCTS stayed below her style CPU at every margin (5 / 14 /
   9 / 11 of 40 at 0.08 / 0.15 / 0.25 / 0.4, her style CPU 19): `*mc-off-at*`.

### 9.4 Checks

- Host tests 9,857 ALL PASS (the light model: records, a reeling opponent's J1 worth the NA hit exactly, a lying one nothing, NA into an NS
  startup the triangle's cancel, a Hoho into a J1's window the counter, a ready defender's answer minus his counter, the same seed the same
  values); pkgcheck clean.
- The snapshot's pollution test with the MCTS in the CPUs (IK NORMAL, KK HARD, 4 seeds each, ~1,800 rollouts): every hash, gate and pacing
  line identical (the `stats:` lines' consing apart: they count the rollouts' own).
- G2: all three pairs regenerated (II 39 lines, P1 4-2, 390.4 s; IK 27, P1 7-0, 263.8 s; KK 34, P2 0-1, 333.9 s; before II 38, P2 0-5,
  382.4 s; IK 24, P1 5-0, 239.1 s; KK 39, P2 0-4, 383.5 s), browser = native. The manual's CPU VS CPU row. Playtest v356.
