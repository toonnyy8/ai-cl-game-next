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
