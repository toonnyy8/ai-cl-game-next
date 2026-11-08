# The CPU as MCTS + fuzzy + learning (2026-11-08, in progress)

Research first (the user: 「在正式開始前請先使用 /academic-research-skills:deep-research 彙整這方面的相關資訊，包含研究論文與 GitHub 上的實作、
blog 上的說明等等。再依據這些資訊進行正式的實作。」): `docs/research/ai-mcts-fuzzy-learning/report.md` (85 sources in four notes); §3 is its
design, which the stages below follow.

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

## 3. The design after the research (report.md §4)

- **Fuzzy reactive layer**: zero-order Sugeno over trapezoids, the answer a chance rolled once per event (as the FightingICE fuzzy agent
  that beat its crisp version 129-3-68); 4-6 rules a decision; a veto / rank for must-do reactions; sets resolved at load, cues by
  `plist-get`; only + - x / in what the sim reads; difficulty one knob over the HARD outputs.
- **Generic timing rules replace the style CPUs' matchup code**: a wake-up gate, our own timed meaty, pruning of moves whose recovery exceeds
  his fastest punish at the distance (the FightingICE winners wrapped MCTS in such rules: "standard MCTS rarely blocks").
- **MCTS**: the sequential tree kept; the fuzzy layer as pruning and as a prior (virtual visits), never as a stronger rollout policy (a
  stronger rollout policy made MCTS weaker in Go: 9.4 % against 48.6 %); a fuzzy leaf value for rollouts that end without contact kept apart
  from the returns and mixed at selection (alpha 0.15-0.4), A/B against a crisp score; a mixed node only at guess points.
- **Offline learning**: light-model vs full-sim error per situation bucket -> distrust there; the fuzzy outputs tuned by a (1+1)-ES on the
  native sim, on seeds disjoint from the evaluation.
- **Online opponent model**: integer counts per (distance band x his state x my last action) and response (doing nothing included), a prior
  of ~5 pseudo-counts from CPU-vs-CPU data, the reply level's prior and his rollout policy; folded in at round / match end, bounded, decayed;
  practice inputs ignored (Kim & Kim's per-distance action table: 86 % against the sample MCTS; a refit softmax model: 73.4 -> 87.3 %; a wrong
  model: 50.6 %).
- **Determinism**: the table loaded from the browser is a match input (copied at match start, read-only in the step, its hash with the
  match); CPU vs CPU, the gates and the native sim use the fixed population prior.
