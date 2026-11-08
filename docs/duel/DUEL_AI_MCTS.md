# The CPU as MCTS + fuzzy + learning (2026-11-08, in progress)

The next step after the in-game MCTS neutral (DUEL_AI_TEACHER §9): the whole core CPU replaced. The request: 「請繼續優化，將核心的 AI 系統全置換成
MCTS + fuzzy + 學習型 AI」.

## 1. Decisions (the user, 2026-11-08, asked with AskUserQuestion)

| Question | Options | The user's choice |
|---|---|---|
| How far "replace everything" goes (today only the neutral is MCTS; links, turns, the Kikon hold, defence, wake-up pressure and the awakening are the generic CPU's and the KI style CPUs') | every decision, the style CPUs kept as a fallback where they win (recommended) / every decision, the style CPUs removed / the in-move and defence decisions first | 「全部決策，移除風格 CPU」 |
| What it learns | both: offline (the light model's values corrected from sim matches) and online (the player's habits in a match, as the MCTS's opponent model) (recommended) / online only / offline only | 「兩者都做」 |
| Whether the player's habits are kept | per match (recommended) / across matches, in the browser | 「跨場保存在瀏覽器」 |
| What the fuzzy inference does | the fast reactive layer (Hoho, turns, links, the Kikon hold: rules whose output stays a chance rolled once per event) (recommended) / the MCTS's position value at a rollout's end / both | 「兩者都用」 |

## 2. Plan (stages, each gated: host tests, pkgcheck, build, playtest, G2; strength measured and reported, not gated)

1. **Fuzzy reactive layer**: `cai-move-step`'s continue / turn (AS, SA) / Kikon hold, the Hoho out of an attack, the Burst and the cancel of a
   Kikon follow-up become fuzzy rules over visible cues (distance, the opponent's class and frame, gauges, red, pointer), each rule's output
   a chance rolled once per event (the CPU's rule since AI v2), scaled by difficulty.
2. **Fuzzy position value + MCTS everywhere**: a rollout that ends without contact is scored by a fuzzy position value (distance band ×
   who acts first × gauges) instead of 0; the light model learns the opponent's knockdown and wake-up (the meaty), the awakening and the
   approach beyond 7 m, so no decision is left to the old CPUs.
3. **Offline learning**: corrections to the light model's values (per action × situation features, or the fuzzy rules' weights) fitted on
   the full sim (the teacher's rollouts, `TEACH_LITE`), baked as data; the target: the HARD regret (§9.2: 0.210 against a uniform 0.235).
4. **Online learning**: the human player's habits (what he does in which situation, how often he Hohos a threat, guards, turns) counted
   during play and used as the MCTS's opponent model and the react chances; kept across matches in the browser (with a reset); CPU against
   CPU, the gates and the replays never learn (determinism: the native sim and the browser agree).
5. **The old CPUs out**: `cpu-ki-ken.lisp`, `cpu-ki-ichigo.lisp` and `core-ai.lisp`'s hand rules removed; strength against v357 reported;
   G2 regenerated; the manual.
