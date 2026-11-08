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

## 4. Stage 1 built: the fuzzy reactive layer (2026-11-08)

- `duel/lisp/fuzzy.lisp` (plain CL, host-tested `tests/duel-rules/fuzzy.lisp`): zero-order Sugeno over trapezoid sets (resolved onto their
  symbols at load), min for AND, the weighted average; a `:must` rule holding at least half way answers alone (the rank step); difficulty as
  one knob: a `:skill` chance x `*fz-skill*` 0.3 / 0.62 / 1.0, a `:choice` pulled toward 1/2 by it. Cues are a plist read by `plist-get`.
- Rule bases (outputs = the HARD player's; first set to mirror the old fixed chances, to be tuned in stage 3): `*fz-as-now*` (end the combo in
  the AS: the read against an NS a `:must`), `*fz-ns-turn*` (the SA against his NA in my NS gap, a `:must` when near), `*fz-ns-cont*` (the next
  NS / AS segment), `*fz-kikon*` (hold the SP: red, Konpaku lead), `*fz-hoho*` (Hoho out of his attack: the margin beyond his reach, frames to
  his window), `*fz-cancel*` (cancel his Kikon follow-up: never while red), `*fz-burst*` (combo hits, red).
- `core-ai.lisp`: every one of those decisions asks `cai-fz` (the chance) against the brain's roll for that event, as before (one roll per
  event). The matchup style CPUs still answer first where they decide (until stage 5).
- Checks: host tests 9,875 ALL PASS; pkgcheck clean; G2 regenerated (II 42 lines, P1 1-1, 414.6 s; IK 33, P2 0-3, 325.7 s; KK 31, P2 0-3,
  309.2 s; before II 39, IK 27, KK 34), browser = native; playtest v358. Strength (40 seeds, every CPU on it, P1 : P2): IK NORMAL 16 : 24, HARD
  9 : 31 (v357: 18 : 22, 12 : 28); HK 2 : 38 / 1 : 39; HI 10 : 30 / 28 : 12: both sides changed at once, so this only shows the layer is in
  the old chances' range; its gains are the tuning's (stage 3).

## 5. Decoupled UCT and regret matching (2026-11-08)

The user: 「怎麼不使用 Decoupled UCT 或是 SM-MCTS 搭配 EXP3 或 Regret Matching」. The tree had been kept from one comparison confounded by the
wake-up handover (DUEL_AI_TEACHER §9.3); the literature favours decoupled UCT (best of nine simultaneous-move games) and regret matching
(robust), EXP3 the weakest; at 48-160 rollouts the tree's 10 x 10 reply level is mostly single visits, decoupled UCT needs 10 + 10.
- `*mc-select*` (mcts-lite.lisp): `:tree`, `:duct` (one UCB per side over its own first action), `:rm` (SM-MCTS with regret matching,
  outcome sampling, fixnum regrets, per-mille strategies mixed with `*mc-rm-gamma*` 0.1). EXP3 not offered (it needs EXP, which the native sim
  and wasm may round apart). Host-tested (every rollout played, the same seed the same values).
- 80 IK seeds, the MCTS side's wins (tree / DUCT / RM): Kenpachi HARD 51 / 63 / 53 (his CPU under it 60); Kenpachi NORMAL 76 / 71 / 71;
  Ichigo NORMAL 64 / 59 / 51; Hisagi NORMAL (HK) 13 / 5 / 11. DUCT at HARD by the margin gate: 0 -> 4, 0.08 -> 47, 0.16 -> 63. Ichigo HARD on
  DUCT 14 / 2 at 0.16 / 0.08 against 20 on her CPU: still off.
- `*mc-select-by*` (cpu-mcts.lisp): EASY / NORMAL the tree, HARD DUCT. G2 unchanged (NORMAL); playtest v359.

## 6. A deeper tree (2026-11-08)

The user: 「能把樹的層數增加嗎？」. `*mc-select*` `:deep` (mcts-lite.lisp): an event-driven, open-loop tree (as Puppet-Master MCTS): each
decision of either side as it comes free in the rollout goes one level down, `*mc-depth*` decisions in the tree, one node expanded per rollout
(preallocated, `+mc-max-nodes+` 1024), the root's side-0 statistics for the selection layer; host-tested.
- 80 IK seeds, the MCTS side's wins, depth 2 / 3 / 4 / 6 at 96 rollouts (and depth 4 at 192): Ichigo NORMAL 62 / 56 / 56 / 56 (48);
  Kenpachi NORMAL 77 / 74 / 74 / 74 (76); Kenpachi HARD (depth 3 / 4 / 6) 54 / 54 / 54 against DUCT's 63. Depth 2 matches the `:tree` (64,
  76); depths 3-6 agree exactly (a rollout ends at its first contact before a fourth decision); deeper or longer is worse: the search leans
  harder on the light model's errors. Kept as an option, not used; to be measured again after the offline correction (stage 3).

## 7. The full sim instead of the light model (2026-11-08, an experiment)

The user: 「如果不使用輕量模型，改成真實模擬呢？」. `tools/simgate/fullmc.lisp` (native, not in the game): one character's neutral by flat
Monte Carlo on the full sim between two steps (snapshot, K rollouts of H steps per macro action with common random numbers, the health swing in
the teacher's unit, restore, press the best); the in-game conditions (free, no press, within 7 m, not about to awaken, the opponent not down /
airborne / waking). The rollouts see the true state (no reaction delay): an upper bound. FMC_OPP: the opponent's real CPU in the rollouts (an
oracle) or the generic CPU (his style CPU off there). FMC_TOP=N: the hybrid, the light model ranks from the CPU's perceived view, the full sim
re-scores its top N.

40 IK seeds (HK for Hisagi), that character's wins, native ms per decision:

| | light MCTS (shipped) | full, K 2, H 90 | full, K 1, H 60 | hybrid top 2, K 1, H 60 |
|---|---|---|---|---|
| Kenpachi HARD | ~31 (63 of 80) | 38 (oracle 40), 10-12 ms | 37, 3.7 ms | 39, 1.2-2.0 ms |
| Ichigo HARD | ~10 (her CPU) | 39, 9-10 ms | | 40, 1.2 ms |
| Ichigo NORMAL | ~32 (64 of 80) | 39, 11-12 ms | | 40 (top 3: 36), 1.2-1.4 ms |
| Hisagi NORMAL (HK) | ~6.5 (13 of 80) | 22, 10-16 ms | | 16, 1.0-1.5 ms |
| Kenpachi NORMAL | ~38 (76 of 80) | 32, 12-13 ms | | 31, 1.0-1.4 ms |

The full sim's values are far stronger than the light model's everywhere but Kenpachi's NORMAL; the hybrid keeps nearly all of it at ~1.2 ms
natively (2 full rollouts of 60 steps; in wasm about 5 ms estimated: 0.04 ms a step). Not in the game yet: the search must run between two
steps, the rollouts see the true state (a reaction delay has to be added), the snapshot conses, and the browser cost must be measured.

### 7.1 Cheaper snapshot and restore (2026-11-08)

The user: 「有沒有方式能夠再減少存檔與還原的成本」. Measured natively mid-match (IK, 161 objects: 64 of them the brains' SNAP rings, 13 ECS
tables of 256, the components): snapshot 207 us, restore 32 us (12.8 KB consed each: every float of a float vector boxed by ROW-MAJOR-AREF),
a 60-step rollout 0.6 ms (10.2 us a step: the brains 26 %, the fighters 23 %, the gauges and hits 6 % each, the presentation-side systems
(feedback, slow-motion snapshot, hash log) ~1 % each).
- `engine/lisp/snapshot.lisp`: the visited set is one table cleared and reused (was a 4096-entry table made per snapshot); vectors are copied
  with REPLACE both ways (fill pointer set to the full size around it). Snapshot 207 -> 107 us, restore 32 -> 7.7 us; snapshot + restore
  226 -> 130 us in the pollution test, which passed (IK NORMAL, KK HARD, 4 seeds each: every hash, gate and pacing line identical).
- What is left: the rollout itself (~0.6 ms of the hybrid's ~1.5 ms); skipping presentation in rollouts would save ~10-20 % at most. The
  bigger cut is stopping a rollout at its first contact and scoring it by the measured outcome values (as the light model does).

## 8. Light-model mechanics: blocks going on, the opponent running (2026-11-08)

The user (asked what would make the light model itself more accurate, offered: a light-start + full-sim dataset, an opponent model from
data, missing mechanics, a residual correction): 「先做 3」 (the mechanics).
- `*mc-block-cont*`: a blocked hit goes on (the defender in his blockstun, `+k-bstun+`, guarding; the attacker's blocked recovery: the
  move's `+r-total+` / `+r-adv+` / `+r-end-blk+` as combat.lisp's BLOCKSTUN and MOVE-END-FRAME give them; a hazard's `*hazard-blockstun*`),
  the block's value added, instead of ending the rollout. `*mc-run*`: the opponent walking in from beyond 3 m runs (his kit's run speed).
  Both default off; host-tested (a J1 into a raised guard still ends at the block's value with it off).
- Fidelity (teacher.lisp `TEACH_LITE_VARIANTS`: several light models from the same points; IK seeds 21-32 against the full sim, regret of the
  light pick; base / blocks / run / both, uniform): NORMAL 0.1093 / 0.1083 / 0.1089 / 0.1077, 0.1886; HARD 0.1866 / 0.1882 / 0.1866 /
  0.1864, 0.2407. Within the noise: these mechanics are not where the light model's error is. Left off; the opponent model (what he does in
  each situation) and the outcome values are the next suspects (the dataset to measure them first).

## 9. The dataset and the opponent model (2026-11-08)

The user (after asking whether decoupled UCT still leaves the opponent model inaccurate: yes, it searches only his first decision; every
later one is the fixed rollout policy): 「好，繼續 1 + 2」.
- **The dataset**: teacher.lisp with `TEACH_DUMP=file` writes, per decision point, the light model's whole start (records, both fighters, the
  globals, outcome values, legal actions, the prior) as integers with the full sim's ten action values. `tools/simgate/litefit.lisp` puts each
  start back and searches it again under variants (binding plists): seconds a variant, no full sim. IK seeds 21-32, NORMAL 5,499 points, HARD
  5,603.
- **The opponent model**: `tools/simgate/oppmodel.lisp` classes every decision of a free fighter in CPU matches as one of the ten macro
  actions, by distance band x the other's state class (IK KK II HK HI HH, 30 seeds at NORMAL and HARD: 179,317 decisions; baked by
  `tools/mc-oppmodel.py`); `*mc-opp-model-on*` draws the opponent's rollout picks from his character's row, blended with `*mc-prior*` by
  `*mc-opp-prior-n*` pseudo-counts (`*mc-w2*`, loaded per search by `mc-reload-dynamic`). Default off, the table not baked.
- **Fidelity** (litefit, 400 rollouts a point; regret of the light pick, uniform in brackets): fixed prior NORMAL 0.1081 (0.1886), HARD
  0.1846 (0.2407); the opponent model with 1 / 5 / 20 pseudo-counts NORMAL 0.1070 / 0.1075 / 0.1072, HARD 0.1838 / 0.1855 / 0.1853. The
  full sim's own sampling noise puts the floor near 0.02 (NORMAL) / 0.03 (HARD), so the light model's error is real, but neither the
  mechanics (§8) nor the opponent's rollout policy is where it lives. What is left: the scoring (a contact worth one value per class
  whatever the situation, the rollout ending there; the full sim plays 180 steps, the follow-up and what comes after included) and the
  opponent's first decision; the dataset can now test both in seconds.

## 10. No guard for the CPU either (2026-11-08)

Asked whether each node first drops what the state machine forbids: J1 / SP need the move, a Hoho `hoho-open-p` (flash-step gauge,
lockout, a rooted form), a Step had no rooted check (no playable form is rooted), and the guard was always legal — but the core system
unbound U (DUEL_CORE §2) while `guard-held-p` still read the vpad's :guard, so the CPU could guard and a player could not, and the light
model let the opponent guard. Asked: no guard for the CPU either (recommended) / keep it as the CPU's / give the guard back to players.
**The user: 「CPU 也不能防禦」.**
- `fighter.lisp` `guard-held-p`: a `:core` kit never guards (no input source); the light model drops action 6 (`legal`), both sides'
  root legality too. The rest of the state machine was already in the model's structure: a new action only when free (never inside a move,
  a reel, a blockstun, a Step, a Hoho, a lie), motion only by the state (a walk walks; a move only its own lunge; a Step only its hop),
  NS gaps by the triangle's rules. Not modelled: the Step's J cancel from frame 12, the run's 6-frame brake, a Burst out of a reel.
- Checks: host tests ALL PASS; G2 regenerated (II 39 lines, P1 3-2, 391.8 s; IK 27, P2 0-3, 265.3 s; KK 35, P2 0-4, 344.6 s; before II 42,
  IK 33, KK 31), browser = native; playtest v360. Strength (IK, 40 seeds, both on the shipped CPUs): NORMAL 21 : 19, HARD 8 : 32 (before
  16 : 24, 9 : 31).
