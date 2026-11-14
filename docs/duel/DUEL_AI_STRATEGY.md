# DUEL_AI_STRATEGY — a strategy library found by dream-rsi, combined by fuzzy rules and Decoupled UCT

The user, 2026-11-08: 「我希望能使用 dream-tsi 找出數種策略，在通過 fuzzy 與 Decoupled UCT 將這些策略結合在一起，藉此保持 AI 的強度與風格。」
(dream-tsi: the dream-rsi skill.) Builds on DUEL_AI_MCTS (the action layer: the light model, the full sim, the fuzzy reactive layer) and
DUEL_MATCHUP_AI (the KI style CPUs, the first dream-rsi search, its evaluator).

## 1. Decisions (asked with AskUserQuestion, 2026-11-08)

- **What a strategy is** (offered: three named styles per character / let dream-rsi discover them / per matchup). The user's own answer:
  > 1. 最開始每個對戰組合都嘗試找出幾種不同策略放進策略庫供 DUCT 挑選
  > 2. 確保被加入的策略具有其獨有的戰略意義
  > 3. 如果發現既有的策略庫已經足夠應戰新角色就不再搜尋新策略
  > 4. 通過 fuzzy 來減少變數造成的重複策略。
- **How they combine**: 「策略層在動作層之上 (Recommended)」: every 1-2 s (or back in neutral) Decoupled UCT over (my strategy x his strategy)
  with full-sim rollouts in which both play their strategies; fuzzy rules give each strategy a prior from the situation and the character's
  personality; the chosen strategy drives the CPU (the action layer's MCTS works inside it).
- **The search's score**: 「強度 0.5 + 風格指標 0.5 (Recommended)」. The style half was offered as each named style's own behavior metrics;
  with the user's library rule (2) it becomes the candidate's distinctness and strategic meaning (§4). **To be confirmed with the user before
  round 1**, with the parallelism W and the grid (the dream-rsi skill asks for them).
- **Budget**: 「三位角色一起做」 (Kenpachi, Ichigo, Hisagi; ~150-170 subagent calls at a 3 x 3 grid a workspace, 2 rounds).

## 2. A strategy: runtime-loaded data, character-agnostic

A strategy is a plist (`duel/lisp/strategy.lisp`), never compiled code, so a search cell writes a data file the evaluator loads into the
shared native build (no rebuild per cell, no clobbered builds, the rule against rebuilding `duel.fas` under running jobs kept):
`(:id ID :base (KEY VALUE ...) :rules (((CUE SET) ...) (KEY VALUE ...)) ...)`.
- **Cues** are relative to the kits (so a strategy found in one pairing runs for any character, rule 3): the distance over my J1's reach
  (`:dj`), over my NS's reach under my pointer (`:dn`), over his J1's reach (`:do`); my Konpaku lead (`:lead`); my and his Reishi fraction
  (`:mr`, `:or`), his red (`:ored`); my Hoho ready (`:hoho`); his state class (`:ost`: 0 free, 1 a move's startup, 2 its active / recovery
  frames, 3 a Step or Hoho, 4 reeling / down); my pointer's NS ranged (`:wave`); awakened (`:awk`).
- **Outputs** (each key: a zero-order Sugeno over the rules that name it, its `:base` when none fires; + - x / only, native = wasm):
  the action layer's prior weights for my side (`:w-j1 :w-sp :w-hoho :w-step-in :w-step-out :w-step-side :w-wait :w-walk-in :w-walk-out`),
  the walk-to range's scale (`:range`), the in-range NS share (`:ns`), and scales of the fuzzy reactive layer's chances (`:hoho` out of an
  attack, `:turn` the AS / SA read, `:cont` going on, `:kikon` the hold), the awakening's (`:awaken`).
- Read once per decision (cached by tick), one roll per event as every CPU chance. No strategy (`brain-strat` NIL): the CPU exactly as
  before (G2 proves it).

## 3. Fuzzy against duplicates (rule 4)

Each strategy has a **fingerprint**: its outputs over a fixed grid of situations (the cues' sets' centres). Two strategies whose
fingerprints agree within a fuzzy similarity θ are one strategy (the stronger kept): parameter variants that change nothing that matters
never enter as separate entries. The behaviour in matches (§4) is the second filter.

## 4. The library and the admission of a strategy (rules 1-3)

- **Per pairing** (KI, KH, IH first; then the mirrors), both characters, a dream-rsi workspace each (branches = candidate strategies,
  attempts = refinements). The opponent's pool and the evaluator are frozen per round.
- **Strategic meaning** (rule 2): the pairing's payoff matrix (my library's strategies x his, HARD, both seats, common seeds); a candidate is
  admitted when it is not a duplicate (§3, and its behaviour descriptors differ) and it is a best response to at least one of his
  strategies or raises my side's meta-game value (its weight in the matrix game's equilibrium, by regret matching) by at least ε.
- **Enough** (rule 3): before searching a new pairing, its payoff matrix is built from the library; a short search whose candidates all fail
  admission ends it.
- **The score a cell gets** (pending §1's confirmation): 0.5 x strength (the strategy alone driving his CPU, HARD, against the opponent's
  current CPU or the library's equilibrium mix, both seats) + 0.5 x style (distinctness of its behaviour descriptors from the library's
  entries: range kept, attack rate, Hoho rate, whiff punishes, AS / SA rate, waves, Kikons; scaled to 0-1), x the NORMAL band factor as
  DUEL_MATCHUP_AI's evaluator.

## 5. The strategy layer in the game

Decoupled UCT at the strategy level: my K strategies and his K, one UCB per side, full-sim rollouts (both CPUs on their sampled strategies,
the action layer's own search off in them) sliced one a step as the action layer's; its statistics seeded from the offline payoff matrix
(about one in-game sample per joint cell otherwise: noise); fuzzy rules give a prior per strategy (the situation, the character's
personality, the difficulty: EASY leans on the personality, HARD on the values). The chosen strategy holds until the next selection.

## 6. The bar, and what it retires

At HARD the strategy layer must at least match Kenpachi's KI style CPU (~60 of 80 IK, where the action layer's full sim failed without
the margin gate, DUEL_AI_MCTS §12). Cleared, it retires `cpu-ki-ken.lisp` / `cpu-ki-ichigo.lisp`, Ichigo's HARD exception (`*mc-off-at*`)
and the HARD margin gate (`*mc-sure*`): the stage-5 goal the user chose (「全部決策，移除風格 CPU」, DUEL_AI_MCTS §1).

## 7. Order of work

1. This doc and DEVLOG §645.
2. The strategy format and interpreter, off by default; G2 identical.
3. Seed strategies by hand: the generic core CPU as strategy 0, and the KI style CPUs' key behaviours as one or two more.
4. The evaluator: strength, behaviour descriptors, distinctness, the payoff matrix (reusing tools/matchup-eval.py, situ.lisp, the
   ki-ai-drsi scripts).
5. A strategy-layer prototype over the seeds: browser cost per step, and whether it beats the best fixed strategy. If it does not, the
   library has no consumer: stop and report.
   Done 2026-11-08 (§8.4): it ties the best fixed strategy at HARD in all six cells (every matrix has a pure equilibrium); stopped and
   reported, the next step is the user's call.
   Superseded 2026-11-08 by the user's choice (§8.6): 「查表＋搜克制策略，之後再上 Q」. The steps from here:
   6'. A (pairing, difficulty) lookup of the best fixed strategy, HARD only, where it beats the shipped CPU by far (§8.6).
   7'. Confirmed 2026-11-08 (§8.7). Dream-rsi for counter strategies: a candidate scores by the situations where it beats the incumbent
       best strategy (§8.5's binned check against the library, the margin and the share of windows it wins), not by strength alone.
   8'. Once the library has situational value (§8.5's oracle gain above the noise), an offline-trained fuzzy Q selector (Glorennec &
       Jouffe) replaces the lookup; the DUCT layer (§8.4) stays off.
6. Confirm the evaluator, W and the grid with the user.
7. A 2-cell pilot, end to end.
8. Full rounds, pairing by pairing (KI, KH, IH), the sufficiency check before each next pairing and the mirrors.

## 8. Log

### 8.1 Steps 1-2: the doc, the format and its interpreter (2026-11-08)

- `duel/lisp/strategy.lisp` (after fuzzy.lisp; host-tested, `tests/duel-rules/strategy.lisp`): `strat-value` (a key's Sugeno answer, the
  base, or NIL), `strat-out` / `strat-scale` (the active strategy's value or the CPU's own), `strat-fingerprint` / `strat-similarity` (§3).
  New fuzzy sets for the cues (`:in :reach :out :afar`, `:low :high`, the state classes `:free :startup :active :evade :down`).
- The brain's `strat` slot; `core-brain-step` binds `*strat-now*` (the strategy and `strat-feats`, its cues this step) when it has one.
  Read by `cai-fz` (the reactive layer's scales), `cai-neutral` (the range, the NS share, the awakening) and the action layer's ranking
  (`mc-est`: the light estimate plus the strategy's bias, in the light pick and the full sim's top two). (Since 2026-11-13, REFACTOR_2026-11
  R12: the brain's `now` slot holds it instead of the special, and `strat-out` / `strat-scale` / `mc-est` take it as an argument; the glue,
  `strat-feats` / `strat-xfeats`, `strat-hold-awaken-p`, `strat-switch-step`, the event layer and the strategy layer of §8.4, moved from
  core-ai.lisp / cpu-mcts.lisp to `strategy-glue.lisp`, which also names the cross-style reads.)
- No strategy anywhere yet: host tests ALL PASS (9849), pkgcheck, G2 identical (II 32, IK 34, KK 33 lines).

### 8.2 Step 4: the evaluator (2026-11-08)

Three new tools, no edit to any existing file; they use the shared native build (`build/simgate/duel.fas`) and never rebuild it. Raw match output is
cached in `build/strategy-eval-cache/` by (the strategy files' hashes, seats, difficulty, seeds, build hash), so a repeated call costs nothing.
- `tools/simgate/strat-desc.lisp`: strat-run.lisp's loader (STRAT_P1 / STRAT_P2 / STRAT_<CHARACTER>) plus `DESC_GENERIC=<char>[,<char>]` (those
  characters play their generic CPU) and a per-step observer that prints, per match and side, `desc P1 kenpachi <seed> k=v ...`: the share of free
  time in the distance bands over the side's own J1 reach (`in reach out afar`, the fuzzy sets of fuzzy.lisp), `dist`, attack starts per minute by
  class (`na ns as sa atk`), `hoho` and `perf` (the perfect share), `wp` (whiff punishes made: the opponent hit while in a move's recovery) and
  `punished`, `kik` (Kikon holds), `wav` (damaging hazards first seen). Minutes count play steps only (cinematics left out).
- `tools/strategy-eval.py --char C [--vs D] --strat FILE [--opp FILES|DIRS|@cpu|@generic] [--seeds 20] [--seed0 0] [--library DIR] [--save-desc]
  [--no-normal] [-j 4]`: JSON with strength (HARD, both seats, common seeds, against the opponent's current CPU by default or the equal-weight mix
  of `--opp`), the averaged descriptors, style (nearest library entry's relative descriptor distance / 0.25, clipped; 1 for an empty library), the
  NORMAL band factor (as matchup-eval; the generic-vs-generic base is measured once and cached) and score = max(0.01, (0.5 strength + 0.5 style) x
  factor). `--save-desc` writes `FILE.desc.json`, the entry format of a library dir (compare entries measured under the same `--opp` / seeds).
- `tools/strategy-matrix.py --a A --b B --rows ... --cols ... [--cand FILE] [--eps 0.02]`: A's win-share matrix (HARD, both seats), the regret-matching
  equilibrium (both mixes, the value and its bounds) and the admission test of §4 for a candidate row: a best response to some column, or a value gain
  >= eps. A cell with draws / time-outs counts them as 0 for A.
- Measured (s0 = the empty plist `docs/research/strategy-drsi/tmp-eval/s0.lisp`, `(:id :s0-generic)`; Kenpachi in KI, 10 seeds a seat, `-j 6`, cold
  cache): 4.1 s wall for the six sim processes (HARD x2 seats, NORMAL x2, the NORMAL base x2). A strategy with no rules is exactly the generic CPU
  (the NORMAL share equals the base, 0.65).
```
{"char": "kenpachi", "vs": "ichigo", "strat": "docs/research/strategy-drsi/tmp-eval/s0.lisp", "seeds": 10, "seed0": 0, "strength": 0.0, "hard": {"@cpu": "0/20"}, "desc": {"in": 0.2759, "reach": 0.2268, "out": 0.2941, "afar": 0.2031, "dist": 2.2185, "na": 6.2745, "ns": 12.4945, "as": 2.1925, "sa": 1.207, "atk": 22.1685, "hoho": 1.4275, "perf": 0.1741, "wp": 0.5635, "punished": 4.689, "kik": 1.2075, "wav": 0.0}, "style": 1.0, "nearest": null, "nearest_dist": null, "normal": {"share": 0.65, "base": 0.65, "band": [0.55, 0.75], "factor": 1.0, "matches": 20}, "raw": 0.5, "score": 0.5}
```
  s0 loses every HARD match (0/20) to Ichigo's KI style CPU: the generic Kenpachi is no match for it, so a candidate has room to show strength.

### 8.3 Step 3: the seeds, and what the format cannot say (2026-11-08)

Five seeds (`docs/research/strategy-drsi/seeds/`, their README: ideas, wins, the missing keys): s0 generic (empty), s1 brawler, s2 punisher,
s3 zoner, s4 reach discipline. All run for Kenpachi, Ichigo and Hisagi (character-agnostic). 10 seeds a cell, the strategy's character's wins:
- HARD against the opponent's current CPU (the KI style CPUs where they exist): Kenpachi 9 on his style CPU, **0 on every seed**; Ichigo 1 /
  0; Hisagi 1 / 0-2. Against a generic opponent: every seed within noise of s0.
- NORMAL: the seeds do play apart (Kenpachi: s1 10, s0 6, s4 6, s3 3, s2 2).
The format reaches only the generic CPU's level: what makes the style CPUs strong is not expressible — the meaty on a wake-up, a whiff
punish with the fastest move that lands in his recovery, the perfect Hoho's timing, a form's entry and cash-out, the pointer chosen, a
Kikon only when it K.O.s, a bait hover band, a reactive back-Step dodge. The format must grow before the strategy layer can reach §6's bar.

### 8.4 Step 5: the strategy-layer prototype (2026-11-08)

Built, off by default (`*strat-layer*` NIL; G2 identical, host tests ALL PASS 9860, pkgcheck):
- `strategy.lisp`: the library in the build (`*strat-library*`: s0 generic, s1 brawler, s3 zoner, `:ki-ken` / `:ki-ichigo` with `:apply (me vs)`,
  each with prior rules on the key `:p`), the payoff matrices (`*strat-payoff*`: KI 4 x 4, KH and IH 3 x 3, HARD, 20 seeds a seat, seeds 1-20, with
  their equilibrium mixes; B's view 1 - M transposed), the pure parts (`strat-arms`, `strat-seed-value`: an arm's value against the opponent's
  equilibrium mix, `strat-puct`, `strat-final`), the knobs (`*strat-period*` 90, `*strat-regain*` 60, `*strat-rolls*` 8, `*strat-h*` 150,
  `*strat-n0*` 6, `*strat-c*` 1, `*strat-swing*` 2, `*strat-lambda*` EASY 0.7 / NORMAL 0.35 / HARD 0.1).
- `cpu-mcts.lisp` (the end): a selection per side every 1.5 s in neutral and on coming back after 1 s out of it (`strat-layer-step` in
  `core-brain-step`, brain slots `st-next` / `st-free`); Decoupled UCT, one PUCT a side over the applicable arms, seeded with n0 pseudo-visits at
  the matrix value; 8 full-sim rollouts a selection, sliced one a step in `mc-full-step` when no action-layer rollout is due (the action layer's
  jobs are due within a reaction time; a selection is not); in a rollout both CPUs play their sampled arms (`brain-strat`; a brainless human gets the
  stand-in brain with his), 150 lean steps, no stop at a contact (`mc-full-rollout`'s new STOP argument), scored 0.5 + swing / 4 clipped to 0-1.
  The pick: (1 - λ) value + λ prior / max prior; before the first selection's rollouts finish, the seeds' and prior's pick. Under the layer a CPU's
  matchup style runs only as its strategy (`:fn`). The RESULTS line `duel stratlayer` (cost, picks per side).
- Pollution: `*cam-cut*`, `*lens-fov*`, `*dutch*` became snapshot roots (a 150-step rollout reaches a Kikon's first beat; fulltest found the first
  two). `fulltest.lisp` checks the layer's rollouts too (FT_LAYER=t) and the camera: CvC 2102 4000 / 4007 (G2's IK) / 4001 674 / 711 / 697 checks (640 / 684 / 658 of them
  strategy rollouts), VS CPU 2500-2503 385-520, all identical; the same layer-on match twice: every hash and gate line identical.
- Cost, native, one process alone: 6.9-7.9 ms a selection (8 rollouts, ~0.9-1.0 ms a rollout step with its snapshot and two restores), the worst step
  6.0-6.7 ms; ~105 selections a match a side (HARD), ~6 % of the steps carry one. Browser (x3.7, estimated): ~3.5 ms a rollout step, the worst
  ~23-25 ms (over a frame), ~3.5x the action layer's.
- Strength (80 matches a cell: seeds 101-140, both seats; the character's wins against the opponent's shipped CPU):

| | HARD layer | HARD best fixed | HARD shipped | NORMAL layer | NORMAL best fixed | NORMAL shipped |
|---|---|---|---|---|---|---|
| Kenpachi vs Ichigo | 61 (always :ki-ken) | 61 (:ki-ken) | 61 | 32 | 54 (s1) | 53 |
| Ichigo vs Kenpachi | 20 (:ki-ichigo) | 20 (:ki-ichigo) | 19 | 30 | 28 (:ki-ichigo) | 27 |
| Kenpachi vs Hisagi | 79 | 78 (s0, s1) | 78 | 68 | 78 (s1) | 69 |
| Hisagi vs Kenpachi | 5 | 6 (s3) | 2 | 9 | 11 (s0) | 11 |
| Ichigo vs Hisagi | 27 | 30 (s0) | 30 | 45 | 70 (s1) | 40 |
| Hisagi vs Ichigo | 72 | 74 (s3) | 50 | 33 | 40 (s0, s1) | 40 |

  The other fixed arms at HARD: s0 / s1 / s3 0 of 80 in KI on both sides. Variants (HARD): n0 1 and 16 rollouts (the rollouts weigh more) 57 / 17 / 79
  / 6 / 33 / 65; no matrix (flat seeds, n0 1, 16 rollouts: the in-game DUCT alone) 0 / 7 / 78 / 5 / 19 / 58.
- Reading: every matrix has a pure equilibrium (one row and one column dominate: KI :ki-ken / :ki-ichigo, KH s1 / s0, IH s0 / s3), so a layer
  seeded from them reduces to "play the dominant entry": at HARD it ties the best fixed strategy in all six cells (within the noise) and Kenpachi's
  KI style CPU (61 of 80) by playing it every time (the layer and :ki-ken alone give the same 28 / 33 per seat: also a proof that the rollouts leave
  nothing behind), and gains over shipped only where the dominant entry is not the shipped CPU (Hisagi vs Ichigo 72 against 50, s3 alone 74). By
  §7 step 5's rule the library has no consumer yet. The in-game rollouts add nothing measurable, and alone they rank wrongly: with no matrix KI
  Kenpachi mostly picks s1 and wins 0 of 80, though :ki-ken (an `:fn`, which does run in the rollouts) wins 61, so the 150-step health swing does
  not track the match where the gap is widest (not verified which: the horizon is short for a patient whiff-punish style, the `:b-` biases do
  not act in rollouts (the action layer is off there), a switch every 1.5 s breaks a style's continuity). At NORMAL the HARD-only matrix picks the
  wrong entry (Kenpachi KI 32 against s1's 54, Ichigo IH 45 against 70): a confound of the seed table, not evidence against DUCT.
- So whether a library search pays can be decided offline with `tools/strategy-matrix.py` alone: only a pairing / difficulty whose equilibrium
  mixes two or more strategies gives the layer something to choose; otherwise a (pairing, difficulty) lookup does its job at no runtime cost.

### 8.5 Does the best strategy depend on the situation? (2026-11-08)

The user, on the prototype's result: 「改成 q learning + 策略 + fuzzy 呢」 (an offline-trained fuzzy Q selector over the library: no in-game
rollouts, so no frame cost, and it learns from whole matches; Glorennec & Jouffe 1997, `docs/research/ai-mcts-fuzzy-learning/notes-fuzzy.md`
item 5). A Q table over situation cues can only beat the best fixed strategy where the best strategy changes with the situation, so that was
measured first (`docs/research/strategy-drsi/sitcheck/`: `drive.py`, `analyze.py`, `analysis.txt`; strat-run.lisp `STRAT_WIN=1` logs the cues
every 90 ticks in neutral):
- 28 cells (each fixed strategy against the opponent's shipped CPU: IH HARD, KI NORMAL and HARD, KH NORMAL), seeds 201-240 both seats, 2,240
  matches, ~130k windows; bins: lead sign x own Reishi (< / > 0.5) x distance band (distance / own J reach: < 0.8, 0.8-1.5, > 1.5), then x form.
- Wins of 80 per strategy (s0 / s1 / s3 / KI style): Hisagi vs Ichigo HARD 66 / 34 / **86**; Ichigo vs Hisagi HARD **34** / 19 / 17; Hisagi vs
  Kenpachi NORMAL 8 / **19** / 8; Kenpachi vs Hisagi NORMAL 92 / **98** / 63; Kenpachi vs Ichigo NORMAL 46 / **68** / 28 / 44, HARD 0 / 0 / 0 / **67**;
  Ichigo vs Kenpachi NORMAL 17 / 27 / 3 / **40**, HARD 0 / 0 / 0 / **35** (%, about ±5).
- The global best is the argmax in nearly every bin with ≥ 30 windows for two strategies: 0-4 bins a group differ on the win, none at z ≥ 2
  against the global best; on the swing over the next 3 windows one bin in the whole run reaches z ≥ 2. The oracle gain (each bin's best
  minus the global best, window-weighted) is 0.000-0.002 of win rate, 0.012-0.015 with form: under the selection noise (~0.03-0.05). The one
  pattern: Hisagi vs Ichigo HARD, close and low Reishi, s0 beats s1 (z 3.0-3.7), but s3 (the global best) rarely visits those bins.
- Caveat: each fixed strategy visits its own states, so a bin can lack the strategy that would win it; a signal, not proof.
- Reading: with this library a situation-conditioned selector, DUCT or Q, learns a (pairing, difficulty) lookup. The library is what lacks
  situational value, not the selector.

### 8.6 The lookup (2026-11-08)

The user, on §8.5: 「查表＋搜克制策略，之後再上 Q」. First the lookup (`*strat-lookup*` in strategy.lisp, `strat-lookup`; START-MATCH sets a
CPU's `brain-strat` from it in VS CPU and CPU VS CPU):
- HARD only: EASY and NORMAL keep their designed strength (the NORMAL band; the best fixed strategy at NORMAL is much stronger than the
  shipped CPU in places, e.g. Ichigo vs Hisagi s1 70 of 80 against 40).
- Only where the gain is far over the noise: Hisagi vs Ichigo HARD plays s3 (86 % in §8.5; 88 of 100 on seeds 301-350, identical to s3 from
  the seed file; the shipped CPU 50 of 80 in §8.4). The other HARD cells are within the noise of the shipped CPU (Ichigo vs Hisagi s0 30
  against 30, Hisagi vs Kenpachi s3 6 against 2) or are the shipped CPU already (Kenpachi vs Ichigo: the KI style CPUs).
- G2 identical native and browser (its pairings have no Hisagi), host tests ALL PASS 9864 (the lookup's four checks), smoke.

### 8.7 The counter-strategy search: what it scores (2026-11-08)

Asked before round 1 (§1 left the score, W and the grid to confirm). The user's answers:
- **Score**: 「只看切換增益 (Recommended)」. Replaces §1's 「強度 0.5 + 風格指標 0.5」 for this search. A candidate is a strategy plus `:own`,
  the situations it claims (fuzzy antecedents over the cues: lead x own Reishi x distance, §8.5's bins). It is played live as a
  **composite**: the incumbent (the shipped CPU, with the lookup) everywhere, the candidate while its `:own` fires, re-judged every 90
  ticks in neutral. Score = the composite's win share against the opponent's shipped CPU (HARD, both seats, 100 search seeds a seat);
  the incumbent's share on the same seeds is the baseline. Distinctness moves to admission: a fuzzy fingerprint unlike every library
  entry, the candidate holding a real share of the windows, and the gain confirmed on 100 held-out seeds a seat. The composite is the
  fuzzy Q selector's executor (step 8'), so it carries over.
- **Scope**: 「四組都搜，先只改資料 (Recommended)」. HARD: Ichigo vs Hisagi (15 % now: re-measured 12 of 80, since Hisagi HARD plays s3
  by the lookup), Kenpachi vs Ichigo (~70 %), Ichigo vs Kenpachi (~30 %), Hisagi vs Kenpachi (~5 %). Cells write data files only; a
  candidate may name an existing `:fn` (the KI style CPUs). Code cells only if data stalls.
- **Budget**: 「W=4，每組 3×3，兩輪 (Recommended)」. Four subagents at a time, a 3 x 3 grid a workspace (36 cells a round), two rounds,
  after a 2-cell pilot.
- **Built** (off by default; host tests ALL PASS 9873, G2 identical):
  - Runtime (strategy.lisp `strat-ante` / `strat-own` / `strat-judge`, `*strat-switch-period*` 90; core-ai.lisp `strat-switch-step`; brain
    slots `sw-sub sw-t sw-n sw-won`): a composite `(:id ID :switch ((OWN . STRATEGY) ...) [:else STRATEGY])` in `brain-strat`; the first
    entry whose OWN fires >= 0.5 is the active sub; none and no `:else` = the lookup's strategy or none (the shipped CPU, its style CPU
    included). The style CPU stops while a sub is active. No random draw; judgements counted outside rollouts.
  - `tools/strategy-switch.py --char C --vs D --cand FILE [--seed0 0-999] [--seeds 100]`: the composite (the candidate's `:own` as its one
    entry) against the incumbent on the same seeds, both seats; JSON with both shares, the gain, the paired b / c and z, the candidate's
    share of the judgements, score = the composite's share. One evaluation (100 seeds a seat, both arms) ~15 s at -j 5.
    strat-run.lisp prints `switch P<n> <id> judged J held h1 ...` per match.
  - Proofs (10 seeds a seat): an OWN that never fires is byte-identical to the incumbent (KI with the style CPU; Hisagi vs Ichigo with the
    lookup); one that always fires equals the candidate alone (Ichigo s0; Kenpachi `:fn ken-ki-style` = seeds/s5 run directly).
- **Seeds and baselines** (debug 30000+k takes k <= 999): search 600-699 (the score), held-out 700-799 (admission), dev 800-849 (the cells'
  own comparisons). The incumbents' shares, search / held-out: Ichigo vs Hisagi 0.105 / 0.13, Kenpachi vs Ichigo 0.755 / 0.77, Ichigo vs
  Kenpachi 0.245 / 0.23, Hisagi vs Kenpachi 0.035 / 0.055. Workspaces: `docs/research/strategy-drsi/counter/` (README).

### 8.8 Counter search, round 1 (2026-11-08)

36 cells planned, 30 run (Sonnet 5.5 subagents, W = 4): Ichigo vs Hisagi stopped after its first batch of 3, at the score's ceiling (1.0).
Every cell rescored on the search seeds (600-699); the best of each workspace then on the held-out seeds (700-799). Shares are the
character's wins, both seats, 200 matches; "inc" = the incumbent (the shipped CPU) on the same seeds.

| Workspace | Best candidate (`:own` share) | Search (inc) | Held-out (inc) | z held-out |
|---|---|---|---|---|
| Ichigo vs Hisagi | her KI style CPU as the strategy (`:fn ichigo-ki-style`), everywhere / off his J1 reach (0.79) | 1.0 (0.105) | 1.0 (0.13) | 13.2 |
| Ichigo vs Kenpachi | **Kenpachi's** KI style CPU as her strategy (`:fn ken-ki-style`), everywhere | 0.43 (0.245) | 0.415 (0.23) | 4.1 |
| Hisagi vs Kenpachi | a wide kite (`:range` 3.2, `:ns` 1, no J1, back off in his reach, `:cont` 1.0-1.4, `:awaken` 2.5-4), everywhere | 0.375-0.415 (0.035) | 0.375-0.47 (0.055) | 7.2-8.6 |
| Kenpachi vs Ichigo | his KI style keeping range (x1.4) while his Reishi is low (0.11-0.15) | 0.77-0.775 (0.755) | 0.77-0.775 (0.77) | 0-0.15 |

- **No situational counter survived.** Partial slices that rescored above the incumbent fell back on the held-out seeds (Ichigo vs
  Kenpachi: her style + `:range 0.7` on 55-82 % of the judgements, 0.36-0.38 search, 0.255-0.27 held-out against 0.23). The three
  confirmed gains replace the incumbent everywhere: new (pairing, HARD) lookup entries, not situational value. So §7 step 8' (the Q
  selector) still has nothing to choose between.
- Lessons for round 2: a cell's 100 dev matches overfit (picked dev gains of +0.05-0.15 shrank to about 0 on the search seeds); under a
  `:fn` the `:b-` biases and rules are inert and only `:range` acts; data-only strategies win 0 against a KI style CPU (as §8.3).
- **A composite bug found and fixed**: a sub whose `:fn` differs from the style CPU it replaces got the other style's state struct
  (`brain-style`) and crashed the sim (Ichigo with `ken-ki-style` on part of the game). Brain slot `sw-fn`: the style function that owns
  `brain-style`; another one taking over starts afresh. Scores of same-function candidates unchanged (76 / 49 before and after).

### 8.9 Round 1 into the lookup, and round 2's rules (2026-11-08)

Asked after round 1. The user: 「三筆都加 (Recommended)」 and 「換新現行＋限制接手比例 (Recommended)」.
- `*strat-lookup*` (HARD only) gains Ichigo vs Hisagi `:ki-ichigo`, Ichigo vs Kenpachi `:ki-ken` (Kenpachi's KI style CPU as her strategy),
  Hisagi vs Kenpachi `:s7-kite` (new library entry, counter/kh-hisagi b1_a2). A strategy from the lookup now stops the character's matchup
  style CPU, as a composite's sub does (else Ichigo's own style would run on Kenpachi's style state); the composite's style-state owner
  (`sw-fn`) counts the lookup's `:fn` when no sub is active. The game reproduces the search exactly: the held-out shares 1.0, 0.415,
  0.47. G2 identical (it does not run HARD), host tests 9875 ALL PASS.
- Round 2: the incumbent is the CPU with the lookup; a candidate counts only if it owns at most 60 % of the judgements (over the cap it
  scores as the incumbent), to force situational strategies; the cells' dev seeds double to 100 a seat (800-899). Ichigo vs Hisagi (1.0
  now) and Kenpachi vs Ichigo (no gain in round 1) are skipped: round 2 searches Ichigo vs Kenpachi and Hisagi vs Kenpachi.

### 8.10 Counter search, round 2 (2026-11-08)

The dream step promoted a rewritten allocation policy in both workspaces (replay reward +0.313 against the baseline policy's -0.017, one
world: weak evidence). 15 cells (Sonnet 5.5): Ichigo vs Kenpachi the full 3 x 3; Hisagi vs Kenpachi stopped after its first batch of 3.
Incumbents (the HARD lookup, §8.9): Ichigo vs Kenpachi 0.43 search / 0.415 held-out; Hisagi vs Kenpachi 0.375 / 0.47.

- **The first situational counter: Ichigo vs Kenpachi.** Incumbent: Kenpachi's KI style as her strategy; counter: her own KI style while
  he is free (`:ost :free`) and she is behind on Konpaku or he is red (`:ored :yes`), about 15 % of the judgements
  (`counter/ki-ichigo/rounds/round02/nodes/b0_a2/cand.lisp`): **0.825 search, 0.825 held-out (z 8.1)**. Both of its parts alone are far
  weaker (Kenpachi's style alone 0.415, her own alone 0.23): the two styles win different situations. The branch's steps on held-out:
  behind only 0.62, behind or red 0.685, with `:range 0.7` 0.73, gated on his free state 0.825. A variant adding "awakened and even"
  0.775.
- **Hisagi vs Kenpachi is not situational.** The counters (a KI style CPU while the lead is even or behind, 21-40 % of the judgements)
  reached 0.87-0.915 held-out, but either KI style everywhere is stronger: Kenpachi's 0.985, Ichigo's 0.965 (against the kite's 0.47).
  The cap only measures weaker slices of a whole replacement, so the workspace stopped.
- The KI style CPUs, written for the KI pairing, are strong general tactics: with any of the three characters, against the generic CPU,
  they win far more than the generic CPU's own play or the data strategies.

### 8.11 Round 2 into the game; next the offline fuzzy Q (2026-11-08)

Asked after round 2. The user: 「兩個都上 (Recommended)」 and 「離線 fuzzy Q (Recommended)」.
- `*strat-lookup*` (HARD): Ichigo vs Kenpachi plays the composite `:c1-ichigo-ken` (library entry with `:switch` and `:else`: Kenpachi's KI
  style, her own while he is free and she is behind or he is red); Hisagi vs Kenpachi plays `:ki-ken` (Kenpachi's KI style) in place of
  the kite. The game reproduces the search: held-out 0.825 and 0.985. G2 identical native and browser, host tests 9877 ALL PASS, Artifact
  v364.
- Known limit: `tools/strategy-switch.py` against an incumbent that is itself a composite falls back to the composite plist as a plain
  strategy (no `:fn`), so a candidate measured on top of `:c1-ichigo-ken` is wrong; the fuzzy Q step brings its own evaluator.
- Next (§7 step 8'): an offline-trained fuzzy Q selector over the two KI styles in Ichigo vs Kenpachi; the bar is the hand composite (0.825).

### 8.12 The offline fuzzy Q selector, Ichigo vs Kenpachi HARD (2026-11-08)

§8.11's next step. Everything lives in `docs/research/strategy-drsi/fq/` (README, `fq.py`, the tables, the runs). Nothing ships yet:
the lookup still plays c1.
- **Runtime** (off by default: no `:fq` anywhere and G2 is identical, II 32, IK 34, KK 33 lines):
  - The form is `(:id ID :fq (:arms (S0 S1 ...) :rules ((ANTE Q0 Q1 ...) ...) [:margin M]))`. strategy.lisp `strat-fq-q` /
    `strat-fq-pick`, dispatched from `strat-judge`.
  - Q(a) = the rules' q(a) averaged by firing strength. The arm is the argmax (ties go to the first; with no rule firing, arm 0). It is kept
    as `:prev` while it trails by less than M. It is always an arm, never the lookup's fallback.
  - It is judged on the composite's schedule (`strat-switch-step`: the `sw-fn` reset, the counters). The cue `:prev` is the previous arm.
    No random draw; the same function in rollouts.
  - A new fuzzy set `:busy` (his state class not free). A tool hook `*strat-judge-hook*` (core-ai.lisp; NIL in the game).
  - `tools/strategy-switch.py --raw` passes a composite or a Q selector unwrapped. `strat-run.lisp STRAT_FQLOG` logs the judgements and
    explores (ε from a hash of seed, tick, side and salt).
  - Fixed: the composite's `judged` / `held` counts covered only each chunk's last match. So §8.8-§8.10's own shares came from 8
    matches; c1's real own share is 12.9 % on 601-700.
- **Training**: behaviour = the table initialised to c1 + ε 0.15. 4 salts x seeds 1-599 x both seats = 4,792 matches, 714,801 judgements.
  - Reward per window: 0.1 x Δ(`mc-full-health` difference), ±1 at the end; γ 0.9.
  - 48 crisp rules (lead x ored x his state free x awk x prev; tabular in effect).
  - Policy evaluation with a gate: a cell leaves c1 only when the other arm is better in >= 95 % of 200 seed-bootstrap replicates.
- **Proofs**: c1 run raw = the incumbent; the table initialised to c1 = c1 (601-700: 165 = 165, b = c = 0). Hash lines are byte-identical
  (601-610, also with the logging hook at ε 0).
- **Result** (both seats, 100 seeds a seat, against c1; 601-700 / 701-800 are §8.7's blocks "600-699 / 700-799", `--seed0 600` / `700`):
  - 601-700: 0.905 against 0.825 (b / c 32 / 16, z 2.3).
  - 701-800: 0.895 against 0.825 (29 / 15, z 2.1).
  - Pooled: z 3.1.
  - Validation (the 1-500 table on 501-599): 0.929 against 0.859.
- **What moved** (16 of 48 cells): awakened, her own style in place of Kenpachi's in 10 cells. Not awakened, with him free and her behind
  (or even with him red), Kenpachi's style in place of her own, which reverses c1's trigger. `:prev` keeps her own style in one busy cell.

### 8.13 The fuzzy Q table into the game; next its online learning against the player (2026-11-09)

Asked after §8.12. The user: 「取代手寫規則 (Recommended)」 and 「對玩家的線上學習 (Recommended)」 (their earlier question: 「能讓 fuzzy Q learning
也在對局中學習玩家的習慣嗎？」).
- `*strat-library*` gains `:q1-ichigo-ken` (the trained table inlined); `*strat-lookup*` Ichigo vs Kenpachi HARD plays it in place of c1
  (c1 stays in the library). The game reproduces the evaluation: 0.905 / 0.895 on seeds 600-699 / 700-799. G2 identical native and
  browser, host tests 9890 ALL PASS, Artifact v365.
- Next: the table as the starting point against a human, bounded TD updates by firing strength between matches, saved per player; CPU vs
  CPU never updates (G2 unchanged); Ichigo vs Kenpachi first.

### 8.14 The fuzzy Q table learns against the player (2026-11-09)

§8.13's next step. The user: 「能讓 fuzzy Q learning 也在對局中學習玩家的習慣嗎？」, then 「對玩家的線上學習」. Ichigo vs Kenpachi first. CPU vs CPU
never learns, so G2 is identical (II 32, IK 34, KK 33 lines, native and browser).
- **Who learns** (ai-learn.lisp `fq-attach!`, from START-MATCH after the lookup):
  - the CPU's lookup strategy is a Q selector (`:fq`; today only `:q1-ichigo-ken`, HARD Ichigo vs Kenpachi);
  - its opponent has no brain (a human), in VS CPU;
  - LEARNING CPU is on (the old learner's setting, default ON; shown in SETTINGS again, see "Settings (2026-11-09)" below);
  - no debug command has run (except 2504, below).
  The brain then plays the player's copy of the table (`*fq-tables*`, per (me, vs) roster indices). The copy is made with copy-tree, so the
  library entry never changes.
- **During the match**, each judgement outside rollouts (core-ai.lisp `strat-switch-step` → `fq-note`) records three things: the rules'
  normalised firing vector (strategy.lisp `strat-fq-fire`, `:prev` included), the arm played, and the balance (my `mc-full-health` - his).
  No random draw, and the table stays fixed until the end, so a match is a function of its inputs and the table it started with.
- **At the match's end** (`go-results` → `fq-match-end`) the transitions are built as the offline trainer's (`fq-transitions`):
  - r = 0.1 x the balance's change to the next judgement;
  - the last one ends at the final balance, +1 a win, -1 a loss, 0 a draw;
  - γ = 0.9.
  Then Glorennec & Jouffe's update runs once, in order (`fq-td-update!`): q_r(a) += η α_r δ, δ = r + γ Σ_r α'_r max_a q_r(a) - Q(s, a).
  Each q is clamped within its offline value ± cap and kept at 1e-5 (the stored resolution). A match the player quits never reaches
  `go-results` and teaches nothing.
- **Saved** through the page (pwa.js) as `soulduel.fq.<me>.<vs>` (get / set 40000 + 1000 (10 me + vs), the learner tables' protocol).
  - Entries: format 1, a polynomial checksum of the offline table, the matches learned, then the 96 q x 100000 (99 integers).
  - A different format, checksum or size on load starts the player fresh from the library's table, so a retrained table resets everyone.
  - A table read back is identical to the one in memory. Natively nothing is stored.
- **Knobs** (strategy.lisp; chosen on the training seeds and on the shipped-CPU check below, never on held-out):
  - `*fq-online-eta*` 0.05.
  - `*fq-online-cap*` **0.01**.
  - `*fq-online-gamma*` 0.9 and `*fq-online-scale*` 0.1: the offline trainer's.
  - `*fq-online-eps*` 0.0.
- **Why cap 0.01.** Most offline arm gaps are 0.001-0.025, so a cap of 0.05 lets nearly every cell flip.
  - At cap 0.05, 25 matches against proxy 1 took the table to 0.35-0.925 against the shipped Kenpachi (offline 0.905, seeds 851-950). One
    run broke from its first block: 1-2 wins of 25 throughout, and 0.34 against the shipped CPU.
  - Training wins of 599, proxy 1 / proxy 2 (offline 89 / 387):

    | cap | 0.01 | 0.02 | 0.05 | 0.1 |
    |---|---|---|---|---|
    | wins | 197 / 502 | 174 / 487 | 187 / 512 | 70 / - |

  - The final tables against the shipped Kenpachi (851-950, offline 0.905): cap 0.01 0.83-0.93, cap 0.02 0.79-0.95, cap 0.05 0.35-0.96.
- **Exploration: none by default.** The arm is always the table's. A state where the player beats the CPU lowers the played arm's q until the
  other arm leads, so states explore where the CPU is losing.
  - A hash ε (FQ-U01 of the match seed, tick and side; never `sim-rnd01`) is built and was measured at cap 0.05.
  - Training seeds: proxy 1 gained (ε 0.05 242 wins, ε 0.1 275; ε 0.1 with no learning 113), proxy 2 lost (ε 0.05 354, below no learning's
    387).
  - Held-out, the ε 0.05 tables: proxy 1 0.28-0.41 (offline 0.16), proxy 2 0.27-0.56 (offline 0.685).
  - So it stays off.
- **Host tests** (tests/duel-rules/strategy.lisp, 9890 → 9914): the firing vector, the transitions, one TD step by hand, split firing, the clamp
  both ways, a no-op match (and δ = 0) leaving the table equal, the page round trip and its refusals, and an update of the shipped table's copy
  leaving the library entry alone.
- **The proof** (docs/research/strategy-drsi/fq/online.py, README there):
  - The "player" is a proxy CPU on Kenpachi's seat, treated as the human (`strat-run.lisp STRAT_FQLEARN`). Ichigo plays on P2, as in VS CPU.
  - Proxy 1: Kenpachi playing Ichigo's KI style CPU. Proxy 2: Kenpachi's KI style at 1.4x range. Both were picked before any learning ran.
    The data strategies s0 / s1 / s3 already lose to the offline table about 1.0, so they leave no room.
  - Four runs of about 150 matches on seeds 1-599, each from the shipped table, with frozen q1 played on the same seeds (a paired curve).
    Then the final tables are frozen and played on 601-800, both seats, 400 matches a table.
  - Identity, on the final build: learner attached with η 0 gives 313 hash / state / row lines identical to no learner (seeds 601-610, P2,
    proxy 1). With learning on, match 1 is identical, and the tables move from match 2.

At the shipped knobs (η 0.05, cap 0.01, ε 0):

| | proxy 1 (Ichigo's KI style) | proxy 2 (Kenpachi's, range 1.4) |
|---|---|---|
| live, learner / q1, wins of 599 (b / c, z) | 197 / 89 (131 / 23, 8.7) | 502 / 387 (150 / 35, 8.5) |
| curve, 4 runs pooled, per block of 25 matches a run (learner / q1) | 46/8, 45/16, 23/11, 36/27, 22/9, 25/18 | 83/65, 88/65, 81/64, 80/63, 84/63, 86/67 |
| final tables frozen, held-out vs the proxy (q1) | 0.163, 0.178, 0.168, 0.178 (0.163) | 0.843, 0.893, 0.698, 0.893 (0.685); z 5.5, 8.0, 0.5, 8.0 |
| final tables vs the shipped Kenpachi, 851-950 (q1 0.905) | 0.83, 0.915, 0.905, 0.915 | 0.865, 0.925, 0.905, 0.93 |
| after 25 matches vs the shipped Kenpachi, 851-950 | 0.855, 0.765, 0.67, 0.775 | - |

- **Against proxy 2 it learns a table.** Three of four frozen tables beat the offline one on held-out, and they are no worse against the
  shipped CPU. The same cells flip in 3-4 runs, all from her own style to Kenpachi's:
  - behind or even, he is red and free (rules "behind, red, free, not awakened, prev Kenpachi's" and "even, red, free, not awakened, prev own");
  - ahead, awakened, he is free.
- **Against proxy 1 the gain lives in the learning itself.** The live CPU wins twice as often as the offline table (most in the first 50
  matches of a run: 46 and 45 of 100). But its final tables, frozen, play like the offline one: 2-3 flips each, 0.16-0.18. The table keeps
  shifting cells from match to match. Against this proxy, which beats both arms alone (0-1 of 20), the shifting is what wins.
- **The cost to other players is bounded, not zero.** Frozen after 25 matches against proxy 1, the table loses 5-24 points against the shipped
  Kenpachi. It adapts back the same way: at cap 0.05, the broken table learning 150 more matches against the shipped Kenpachi went 13/22 (q1)
  in its first 25, then level, and reached 0.92 held-out (q1 0.90).
- Cap 0.05 learned more persistent tables against proxy 1 (held-out 0.458, 0.408, 0.448, and one broken at 0.02; q1 0.163) at the price
  above. `docs/research/strategy-drsi/fq/README.md` lists every configuration.
- **Browser** (debug 2504: two matches in a row, an idle human Kenpachi, Konpaku 2, cinematics skipped):
  - Match 1: `duel fq load 3 1 fresh`, then `duel fq learn 3 1 matches 1 judgements 28`. `localStorage soulduel.fq.3.1` holds 99 integers
    starting `1,346947,1`.
  - Match 2: `duel fq load 3 1 page matches 1`; afterwards the store's third integer is 2.
  - Both matches replay seed 1 and come out the same (75.4 s): the 7 moved rules flipped no arm against an idle player, so the arms were the
    same.
  - No page error; heap 74.2 MB.
- Open for the user:
  - show LEARNING CPU and a reset in SETTINGS again (this is the first learner live under the core system);
  - whether the bounded cost to other players on the same browser is acceptable;
  - cap 0.01 (safer, gain mostly live) or 0.05 (more persistent, can break).

**Settings (2026-11-09).** The user, asked whether to show LEARNING CPU in SETTINGS again: 「Show it and add a reset (Recommended)」.
- `*settings-hidden*` (flow.lisp) no longer lists `:learn`: the row is back in both menus (HTML `menu.js`, canvas fallback), note "VS CPU HARD: THE CPU LEARNS YOUR HABITS".
  SETTINGS now has 7 option rows, then the action row RESET LEARNING, then BACK (the page's `Settings` card says "7 OPTIONS").
- RESET LEARNING calls `fq-reset-all` (ai-learn.lisp): clears `*fq-tables*` and writes length 0 to the page for every playable (me, vs) pair
  (`soulduel.fq.<me>.<vs>` becomes an empty table, which `fq-decode` reads as no table, so the next match logs `duel fq load <me> <vs> fresh`);
  logs `duel fq reset`; plays the confirm sound (CONTROLS' RESET DEFAULTS has no visible acknowledgement either).

### 8.15 Every pairing: a second search, a Q table and the online learner (2026-11-09)

Asked after §8.14. The user: 「Show it and add a reset (Recommended)」 (LEARNING CPU and a reset back in SETTINGS), 「Keep 0.01
(Recommended)」 (the cap stays), and for the next step, in their own words: 「為每個對戰組合搜尋第二輪策略，並建構出各自的 Q table 與 online fuzzy Q
learning」. Then, on the opponent and the mirrors: 「混合：弱組對現行、強組對代理 (Recommended)」 and 「要，九組全做 (Recommended)」.

- **Where every pairing stands** (HARD, seeds 600-699, both seats, 200 matches; the incumbent with every lookup entry live, d806377). The
  lookup applies on both seats, so each entry also changes the opposite pairing's opponent:

| Me vs | Share | The opponent it met |
|---|---|---|
| Ichigo vs Kenpachi | 0.905 | Kenpachi's shipped CPU |
| Ichigo vs Hisagi | 1.0 | Hisagi's lookup `:s3-zoner` |
| Hisagi vs Kenpachi | 0.965 | Kenpachi's shipped CPU |
| Kenpachi vs Ichigo | 0.095 | Ichigo's `:q1-ichigo-ken` (0.77 against her old CPU, §8.8) |
| Kenpachi vs Hisagi | 0.035 | Hisagi's `:ki-ken` |
| Hisagi vs Ichigo | 0.0 | Ichigo's `:ki-ichigo` |
| the three mirrors | 0.5, 0.495, 0.5 | itself |

- **The plan**:
  - The three weak pairings and the three mirrors search against the opponent's HARD CPU frozen as it is today (its lookup strategy passed
    explicitly, not read from the live lookup), so the order in which new entries ship cannot change the numbers.
  - The three at the ceiling (Ichigo vs Kenpachi, Ichigo vs Hisagi, Hisagi vs Kenpachi) skip the search. Their Q tables train against a
    proxy pool (the opponent playing other styles: the KI styles and its other strategies), so the online learner has something to move to.
  - Each pairing's table has two arms, the incumbent and the best alternative, and starts equal to the incumbent (proved per pairing, as
    with c1), so a first shipped table is never worse. Cap 0.01 stays; each table's arm gaps are reported (where they mostly exceed 0.02,
    the learner cannot flip a cell).
  - A mirror's table plays both seats in CPU vs CPU; against a player it learns as any other.
  - Order: generalise the tooling (fq.py, online.py, strat-run, the frozen opponents, the proxy pool); the searches (Sonnet cells, 3 x 3,
    W = 4); the fitted Q tables and their proofs; the lookup.

- **The searches' results** (each workspace's best cell, its search score, then held-out seeds 700-799, 100 a seat, HARD, the opponent
  frozen as in the plan; `docs/research/strategy-drsi/counter/heldout2/`):

| Pairing | Best cell | Search | Held-out | Incumbent | Whole-game replacement (held-out, uncapped) |
|---|---|---|---|---|---|
| Kenpachi mirror | kk-ken b0_a0 | 0.98 | 0.98 | 0.5 | |
| Ichigo mirror | ii-ichigo b2_a0 | 0.995 | 0.99 | 0.5 | |
| Hisagi mirror | hh-hisagi b0_a0 | 0.97 | 0.96 | 0.5 | |
| Kenpachi vs Ichigo | ki-ken r2 b1_a1 (`ichigo-ki-style` when level) | 0.615 | 0.555 | 0.105 | `ichigo-ki-style` 0.81 |
| Kenpachi vs Hisagi | kh-ken b1_a0 (`ken-ki-style` when ahead / level and far) | 0.355 | 0.33 | 0.015 | `ken-ki-style` (:p 1.3) 0.58 |
| Hisagi vs Ichigo | ih-hisagi b2_a2 (`ken-ki-style` when not behind with Hoho / red) | 0.09 | 0.07 | 0.0 | `ken-ki-style` 0.42 |

  The mirrors saturated at once (a KI style CPU over the generic CPU) and were closed after attempt 0-2; KI and KH converged on the 0.6
  cap (the gain rises with the own share) and were closed after attempt 1; HI ran its 3 x 3. `:dswitch` gained nothing under a KI style;
  `hisagi-range-style` won 0 in HI.
- **The user's decisions on the results** (2026-11-09), in their words: 「整場替換 (Recommended)」 (each weak pairing's second arm is its
  whole-game replacement, not the capped slice) and, for Hisagi, whose strongest arm (Kenpachi's KI style) ignores the distance rule of §8.16,
  「合併兩種風格 (Recommended)」: one style that plays `hisagi-range-style` in the Bankai's ranged mode and Kenpachi's KI style elsewhere.

### 8.16 Hisagi's distance control in the Bankai's ranged mode, and the CPU's DRIVE switch (2026-11-09)

The user: 「檜佐木要注意控制距離，尤其是卍解後遠距模式的近身戰非常不利，需要主動後撤或是利用 NS1a 與 NS2b 來拉開與對手的距離。」, then
「記得將消耗 drive 量表來臨時切換 NS 的戰術也安排到策略中」. Built as a strategy with code (§9), `:h1-range` in the library
(`duel/lisp/cpu-hisagi-range.lisp` `hisagi-range-style`; seed `docs/research/strategy-drsi/seeds/s8-hisagi-range.lisp`), **not in the lookup and
not a registered style CPU: the shipped CPU is unchanged** (G2 `--cvc` identical).

- **The style** (the code acts in the ranged mode `:bankai` only; elsewhere it returns NIL and the MCTS and the generic CPU decide, but the
  strategy's data applies in every form: `:dswitch` with the band rule and the Shikai map, the `:dn` rules). Every chance by difficulty, one roll
  per event, `sim-rnd01`, its state in `brain-style`:

| When | What | Knob (EASY / NORMAL / HARD) |
|---|---|---|
| free, the opponent perceived inside 2.9 m (J1's and every 散 volume's 3 m dead zone), or inside 3.4 m while he closes in (his view is 8-24 f old) | one roll per close event: his attack starting at him: the back Step (invulnerable 3-9; the ranged Step lands in a tip band, `hs-step-dist`); pointer 1: NS1a 環 WA (0-3 m, a hit pushes him to 4.5 m; closing in, only when his distance predicted at WA's hit is within 2.8 m); else the back Step; cornered at the wall: WA, else a side Step | `*hr-p*` 0.25 / 0.6 / 1.0 |
| pointer 2 at 2.5-2.9 m | NS2a TABA, then NS2b 叩 TATAKI in its gap | `*hr-taba-p*` 0 / 0 / 0 (0.5 at HARD lost in scene 83802's first version: TABA's S 30, Kenpachi's J1 cancelled it and his AS1 hit 90 one frame before TATAKI) |
| his WA's gap (after its active frames, the contact known) | a hit: the DRIVE switch to pointer 2's TABA (the user's route, DUEL_SUBLIMATION §17.7) when `:dswitch` rolls and the gauge allows, else NS1b ŌGI (`*cai-cont-p*`); a whiff with him still inside 3 m: stop | `:dswitch` x `*cai-dswitch-dif*` 0.3 / 0.6 / 1.0 |
| his TABA's gap | inside 2.9 m: NS2b TATAKI (the push to 3.5 m); 2.5-4.5 m: J, the gathered SA (TABA > SA > J2, §17.7's 150) | |
| a ranged J string's J2 lands | the SP there: AS1 RANSA (3-6 m), writing pointer 1, so WA stays his close tool (pointer 2's damage through the switch); else the string runs on (J3 > AS2, J5 > AS3's bind) | `*hr-home-p*` 0 / 0.4 / 0.7 |
| data (`:rules`) | no NS out of its reach: `:dn :out` / `:afar` -> `:b-sp -0.3`, `:ns 0` (the shipped CPU opens the ranged WA, 0-3 m, from 3.7-5 m: 1063 times in 200 HK matches) | |

- **The CPU's DRIVE switch, for any strategy** (core-ai.lisp `cai-dswitch`, strategy.lisp `strat-switch-to`): an output key `:dswitch`, the
  chance per NS segment's gap (its HARD value, x `*cai-dswitch-dif*`), one roll when the switch is open and a target reaches; the target from
  `:dswitch-map ((form from to) ...)`, else the first other pointer (next, then the rest) whose NS opener reaches the distance (its dead zone to
  its reach + slide + 0.4 m). The press is the human's: SP with the stick sideways (`cai-switch-press`, act `:switch`), through
  `core-move-sp!` / `core-switch-target` / `core-latch-step`; `core-switch-ready-p` takes a CPU only for that press, its rules  (Since DUEL_SP S6, 2026-11-13, `core-switch-ready-p` is gone: the sim reads only the vpad and the gauges, DUEL_SUBLIMATION §17.8.)
  (`core-switch-open-p`: 0.25 of the gauge, SPIRIT DRIVE awakened, SUBLIMATION before, no second switch) shared with the human. No `:dswitch`:
  no roll (every shipped CPU). `:h1-range` carries `:dswitch 1.0` and `:dswitch-map ((:base 1 3))` (the Shikai's NS1 > NS3a, §17.7).
- Shared edits: `*strat-picks*` 16 -> 32 slots (a ninth library entry wrote out of bounds in the strategy layer's counter); `strat-arms` takes
  `:apply (me)` (me against anyone).
- **Checks by script** (debug 83800-83808, DUEL_GAMEPLAY "Debug commands"; P1 a HARD CPU Hisagi with `:h1-range`, P2 a HARD CPU Kenpachi):
  - 83800 (pointer 1, DRIVE 60, Kenpachi idle 2.0 m off): f1 `hr WA at 2.0`, f15 WA hits 26 and pushes him (2.00 m at f24, 4.50 m at f42),
    f27 `cpu switch 1 -> 2`, `NS pointer 1 -> 2 (DRIVE)`, DRIVE 62.1 -> 37.1, f52 TABA 50, f84 the gathered SA 45, f89 AS1 (pointer 1).
  - 83801 (DRIVE 20): WA 26 > ŌGI 31 > ISSEI 48, no switch at WA's gap (DRIVE 22.0); after ISSEI the hits had filled DRIVE to 28.1 and the generic
    band rule switched (28.1 -> 3.1). 83805 (no `:dswitch`) and 83804 (no strategy: the shipped CPU, WA > ŌGI > ISSEI) never switch.
  - 83806 (the Shikai, SUBLIMATION 60, 4.5 m): NS1a 62, `cpu switch 1 -> 3` (SUBLIMATION 60 -> 35), NS3a 40, NS3b 25; 83807 (SUBLIMATION 20):
    NS1a 62 > NS1b 56 > NS1c 80, no switch.
  - 83803 (Kenpachi 1.8 m off starting J1): f1 `hr back-step (his attack) at 1.8` (1.80 -> 3.75 m), then J1 > J2 > AS1 from the band.
  - 83802 (pointer 2, Kenpachi walking in from 2.0 m for 200 f): back Steps every 26 f (each nets ~0.8 m against his walk), side Steps at
    the wall, no hit taken while he walks; once he stops, TABA > TATAKI and Kenpachi's NS1a 65 + SA 30 + J2 35 land.
  - 83808 (pointer 1, Kenpachi walking in from 5 m): J1 at 5 m, J2, `hr home: AS1` (pointer 1 kept), AS1's Kikon.
- **Measured** (tools/strategy-switch.py `--raw`, HARD, seeds 601-700 both seats = 200 matches; STRAT_HRANGE=1: Hisagi's steps in the ranged
  mode, the mean distance, the share inside 3 m, WA started beyond 3.2 m; "generic" = Hisagi with no strategy (`(:id :s0-empty)`), the shipped
  CPU without the lookup):

| Pairing (opponent) | `:h1-range` | without the switch | generic | the incumbent (lookup) | ranged mode: mean d / inside 3 m / WA from afar, generic -> `:h1-range` |
|---|---|---|---|---|---|
| Hisagi vs Ichigo (frozen `:ki-ichigo`) | 0.0 | — | 0.0 | 0.0 (`:s3-zoner`) | 2.29 -> 2.48 m / 0.71 -> 0.655 / 740 -> 34 |
| Hisagi vs Kenpachi (shipped) | 0.125 | 0.06 | 0.035 | 0.965 (`:ki-ken`) | 2.41 -> 2.98 m / 0.71 -> 0.53 / 1063 -> 138 |
| Hisagi mirror (shipped) | 0.645 (b 52, c 23, z 3.3) | 0.59 (z 2.8) | 0.5 | 0.5 | 3.73 -> 3.87 m / 0.305 -> 0.25 / 2848 -> 290 |
| Hisagi vs Kenpachi proxy 1 (`online/ken-istyle`) | 0.025 | | | 0.435 | (`:ki-ken` -> `:h1-range`) 4.53 -> 3.14 m / 0.04 -> 0.48 |
| Hisagi vs Kenpachi proxy 2 (`online/ken-wide`) | 0.0 | | | 0.625 | (`:ki-ken` -> `:h1-range`) 2.55 -> 2.27 m / 0.99 -> 0.74 |

  - Fire rates (200 matches, `:h1-range`): HK 2986 close events (all taken at HARD): 1235 WA, 1635 back Steps, 117 side Steps, 367 switches, 156
    TATAKI; HH 1538 events: 823 WA, 672 back Steps, 458 switches; HI 831 events: 447 WA, 350 back Steps, 52 switches.
  - The switch's share: HK 0.06 -> 0.125, HH 0.59 -> 0.645 (with and without, the same file but `:dswitch 0`).
  - Time in the ranged mode (its steps / the match's, the gate rows' secs x 60): HK generic 0.42, without the switch 0.53, `:h1-range` 0.33 (with
    the proxies' matches); HI generic 0.31, `:h1-range` 0.35; the mirror 0.36 (shipped) -> 0.26. The switch's route (TABA > SA > J2 > J3 > AS3)
    ends in the bind more often.
  - NS2b TATAKI: 156 / 69 / 24 times (HK / HH / HI), always in TABA's gap (after the switch, or a TABA the MCTS started); the neutral TABA >
    TATAKI is off (`*hr-taba-p*` 0, above). NS1a WA is the close push the style uses.
  - The plain data strategy `(:id :d1-switch :base (:dswitch 1.0))` on the shipped CPU (band rule only), mirrors against the shipped CPU: Kenpachi
    0.455 (b 37, c 46, z -1.0), Ichigo 0.365 (b 26, c 52, z -2.9): an always-on switch by the band rule hurts Ichigo's generic CPU.
- **Reading**: the rule does what the user asked (he backs off or pushes out instead of fighting inside 3 m; the time inside 3 m falls 0.71 ->
  0.53 against Kenpachi, his WA from afar nearly stops) and beats the generic CPU in every pairing it can (HK +0.09, the mirror +0.145), but it
  is far below Kenpachi's KI style as Hisagi's strategy (0.965 HK, the lookup) and does not move Hisagi vs Ichigo (0 of 200, her KI style keeps
  him inside 3 m 65 % of the time). It stays out of the lookup; it is one more arm for §8.15's searches and Q tables (Hisagi vs Ichigo, the mirror).

### 8.17 Hisagi's merged style and his three Q tables in the lookup (2026-11-09)

§8.15's decisions for Hisagi. The user, on Hisagi: 「檜佐木要注意控制距離，尤其是卍解後遠距模式的近身戰非常不利，需要主動後撤或是利用 NS1a 與 NS2b
來拉開與對手的距離。」 and 「記得將消耗 drive 量表來臨時切換 NS 的戰術也安排到策略中」; on the search results: 「整場替換」 (a weak pairing's second
arm is the whole-game replacement) and, for Hisagi, 「合併兩種風格」 (one style: `hisagi-range-style` in the Bankai's ranged mode, Kenpachi's
KI style elsewhere). Everything lives in `docs/research/strategy-drsi/fq/hisagi/` (tables, fits, proofs, evaluations; `merged/` the style's
measurements, `shipped/` the lookup's).

- **The merged style** (cpu-hisagi-range.lisp `hisagi-merged-style`; library `:hm1-merged`, seed `seeds/s9-hisagi-merged.lisp`, Hisagi against
  anyone). In the ranged mode (`:bankai`) `hisagi-range-style` runs first, so the distance rule (§8.16) owns every close event; with the strategy
  key `:ken-ranged` (on in `:hm1-merged`) Kenpachi's `ken-ki-style` decides the steps the rule leaves; in the Shikai and the bind mode only
  `ken-ki-style`. Each keeps its own state (`brain-style` holds an `hms` with both), so a form change resumes the other where it stopped.
  No `:dswitch` (measured below).
- **Measured** (`tools/strategy-switch.py`, whole game (`:own` every lead, `--max-own 1.01`, as `heldout2/hi-whole.lisp`), held-out seeds
  701-800, 100 a seat, HARD; opponents as in §8.15: HI the frozen `:ki-ichigo`, HK Kenpachi's shipped CPU, HH the shipped CPU; the incumbent
  HI `:s3-zoner`, HK `:ki-ken`, HH the shipped CPU):

| Hisagi's strategy | HI | HK | HH |
|---|---|---|---|
| the incumbent | 0.0 | 0.985 | 0.5 |
| Kenpachi's KI style whole | 0.42 | 0.985 (= the incumbent) | 0.995 |
| `:h1-range` whole (§8.16) | 0.005 | 0.13 | 0.67 |
| merged, literal (the ranged mode only the rule, the MCTS / generic CPU the rest of it), `:h1-range`'s data | 0.055 | 0.93 | 1.0 |
| the same without data | 0.05 | 0.915 | 0.95 |
| **merged with `:ken-ranged` (`:hm1-merged`)** | **0.42** | **1.0** | **1.0** |
| + `:dswitch 1.0` (`:dswitch-map ((:base 1 3))`) | 0.355 | 0.985 | 1.0 |
| + `:dswitch 0.3` | 0.34 | 0.995 | 1.0 |
| + `:dswitch 1.0` and `:h1-range`'s `:dn` rules | 0.355 | 0.985 | 1.0 |

  The ranged mode (STRAT_HRANGE=1, 200 matches; mean distance / share inside 3 m / WA started beyond 3.2 m; the rule's close events, all taken
  at HARD: WA, back Steps, side Steps):

| Pairing | the incumbent | Kenpachi's KI style whole | merged, literal | `:hm1-merged` |
|---|---|---|---|---|
| HI | 2.57 m / 0.651 / 854 | 4.00 m / 0.220 / 3 | 2.44 m / 0.682 / 138 | 4.00 m / 0.220 / 673; 4,840 events: 2,369 WA, 2,125 back, 478 side |
| HK | 2.90 m / 0.593 / 38 | (the incumbent) | 3.05 m / 0.517 / 236 | 3.43 m / 0.425 / 40; 5,547 events: 3,541 WA, 1,875 back, 135 side |
| HH | 3.78 m / 0.280 / 3,849 | 3.71 m / 0.355 / 5 | 3.89 m / 0.247 / 321 | 4.02 m / 0.237 / 140; 2,667 events: 1,357 WA, 1,228 back, 95 side |

  - The literal merge loses HI (0.42 -> 0.05): the gap is not the rule, it is who plays the ranged mode at range. Kenpachi's KI style there
    already keeps him out (4.0 m, 22 % inside 3 m against the generic CPU's 2.57 m, 65 %); handing those steps to the MCTS / generic CPU
    brings him back in. With `:ken-ranged` the rule still takes every close event and the merged style matches or beats Kenpachi's KI
    style everywhere, with the least time inside 3 m of any arm (HK 0.593 -> 0.425).
  - The DRIVE switch costs here (HI 0.42 -> 0.355 at 1.0, 0.34 at 0.3; HK 1.0 -> 0.985; HH even), as under a KI style in §8.15. It stays a
    strategy key (`:h1-range` carries it); the merged style plays without it.
- **Q tables, as §8.15's plan first** (arm 0 the incumbent, arm 1 `:hm1-merged`, every cell arm 0; `fq.py`, 4 salts x seeds 1-599 x both
  seats = 4,792 matches each, ε 0.15; HK against the proxy pool `pools.json` hisagi-kenpachi, HI the frozen `:ki-ichigo`, HH the shipped CPU):
  - Identity (seeds 601-700, both seats, `proof/identity.py`; `hisagi/identity-600.jsonl`): HI 0.0 = 0.0 (8 of 8 chunks, 3,206 lines), HK
    0.965 = 0.965 (8 of 8, 4,567), HH 0.5 = 0.5 (8 of 8, 5,226).
  - Fitted (cells flipped to the merged style): HI 7, HK 5, HH 24. Held-out 601-700 / 701-800: **HI 0.0 / 0.0** (the merged arm on 43 %
    of the judgements), HK 0.985 / 0.99 (the merged arm on 7 %: the rule fired 0 times), HH 0.965 / 0.97.
  - So in HI the table cannot reach the merged style: mixed by the 1.5-3 s windows the merged arm wins nothing; its 0.42 comes from playing
    it all game. The tables' value is short-horizon (γ 0.9 a window, health-shaped, §8.12's caveat), which no cell-by-cell gate can see.
- **Q tables initialised to the merged style** (the whole-game replacement as the start, 「整場替換」; arm 0 `:hm1-merged`, arm 1 the old
  incumbent, every cell arm 0; the same logs' settings under their own tags `<pairing>-m`):
  - Identity against the merged style played whole (`identity.py --ref seeds/s9-hisagi-merged.lisp`, 601-700; `hisagi/identity-m0-600.jsonl`):
    HI 0.325 = 0.325 (8 of 8, 6,943 lines), HK 0.975 = 0.975 (8 of 8, 4,481), HH 1.0 = 1.0 (8 of 8, 4,511).
  - Fitted: HI 1 cell to `:s3-zoner` (even, he is red and free, awakened), HK 12 cells to Kenpachi's KI style (mostly behind and awakened, or
    even), HH 3 (ahead and awakened, back to the shipped CPU).

| Held-out, both seats, 100 seeds a seat (601-700 / 701-800) | HI | HK | HH |
|---|---|---|---|
| the old incumbent | 0.0 / 0.0 | 0.965 / 0.985 | 0.5 / 0.5 |
| `:hm1-merged` whole | 0.325 / 0.42 | 0.975 / 1.0 | 1.0 / 1.0 |
| table from the incumbent, fitted | 0.0 / 0.0 | 0.985 / 0.99 | 0.965 / 0.97 |
| **table from the merged style, fitted (shipped)** | **0.335 / 0.415** (b / c 67 / 0, 83 / 0) | **0.99 / 0.99** (7 / 2, 3 / 2) | **0.985 / 1.0** (100 / 3, 100 / 0) |

  - Arm gaps (|q0 - q1| per cell; the online cap 0.01 can flip a cell whose gap is under 0.02): from the merged style HI median 0.023, 21
    cells under 0.02 holding 14 % of the judgements; HK 0.003, 41 cells / 96 %; HH 0.014, 31 cells / 80 %. (From the incumbent: HI 0.006,
    57 %; HK 0.011, 88 %; HH 0.008, 99 %.) HI's table is the stiffest: the learner can move only its rare cells.
- **Into the lookup** (HARD, `*strat-lookup*`): Hisagi vs Ichigo `:qh-ichigo` (was `:s3-zoner`), Hisagi vs Kenpachi `:qh-ken` (was `:ki-ken`,
  now its arm 1), Hisagi mirror `:qh-mirror` (new; CPU vs CPU both seats play it). Each is its fitted table inlined (`:apply (me vs)`), so the
  online learner (§8.14) attaches against a player with its knobs unchanged (η 0.05, cap 0.01, ε 0). The game reproduces the evaluation:
  HI 0.335 / 0.415, HK 0.99 / 0.99, HH 0.985 / 1.0 against the old incumbent's 0.0 / 0.0, 0.965 / 0.985, 0.5 / 0.5 (`hisagi/shipped/`).
  - The lookup applies on both seats: Ichigo vs Hisagi (her `:ki-ichigo`) falls from 1.0 to 0.655 / 0.57, Kenpachi vs Hisagi (his shipped
    CPU) from 0.035 to 0.01 (601-700).
  - Online smoke: `online.py train` on HK, 25 matches against proxy 1 (`online/ken-istyle.lisp`): the table keyed (:hisagi :kenpachi), 52 q
    moved, none beyond 0.01, 5 cells changed arm; 19 wins against the frozen table's 22 (noise at 25).
- Tooling: `fq.py read_table` cut an arm carrying its own `:rules` (`:s3-zoner`) at that word; it now cuts at the table's rules. `identity.py
  --ref FILE` compares a table with FILE played raw instead of the incumbent.
- Checks: host tests 9936 ALL PASS (the lookup's three entries, each table's arm 0 the merged style); `tools/pkgcheck.sh duel` clean (one old
  note, `DUEL::APP`); G2 `--cvc` identical natively (II 32, IK 34, KK 33 lines); `./build.sh duel` and an 8 s browser smoke without errors.
- Open: the HI table is 0.335 / 0.415 (the merged style's level, far from the mirrors' and HK's); a longer-horizon value (a whole-match arm
  choice, or γ nearer 1) is what could beat a whole-game style there.
- **The user's decisions on the two deviations (2026-11-09).**
  - Who plays the ranged mode's other steps: 「交給劍八 KI 風格 (Recommended)」. `:ken-ranged` stays on in `:hm1-merged`. The literal
    reading (generic CPU / MCTS there) scored HI 0.055, HK 0.93.
  - The tables' starting arm: 「從合併風格出發 (Recommended)」. Arm 0 = the merged style, arm 1 = the old entry, as shipped. Starting from
    the incumbent scored HI 0.0 / 0.0.

### 8.18 The Q tables with Kenpachi or Ichigo as me, into the lookup (2026-11-09)

§8.15's next step for six pairings (Hisagi's three are another batch, §8.17). The user's words: 「為每個對戰組合搜尋第二輪策略，並建構出各自的 Q table 與
online fuzzy Q learning」, 「混合：弱組對現行、強組對代理 (Recommended)」, 「要，九組全做 (Recommended)」, 「Keep 0.01 (Recommended)」 and, on the search
results, 「整場替換 (Recommended)」. Everything is in `docs/research/strategy-drsi/fq/pairs/` (README there: `fq/README.md` "§8.18").

- **A runtime fix: a Q selector's NIL arm is no strategy at all** (core-ai.lisp `core-brain-step`, `strat-switch-step`). Before, a NIL arm fell
  back to the lookup, which is the table itself once the table ships: Kenpachi vs Ichigo's arm 0 then played the generic CPU without his KI style
  CPU (0.005 instead of 0.095). Now it plays the shipped CPU with its matchup style CPU, which is that pairing's incumbent. A composite's
  no-entry fallback is still the lookup. No shipped table had a NIL arm, so nothing else moves (G2 identical).
- **The arms** (two a table: arm 0 the incumbent, arm 1 the alternative):

| Pairing | Opponent while fitting | Arm 0 | Arm 1 |
|---|---|---|---|
| Kenpachi vs Ichigo | frozen `q1-ichigo-ken` | NIL (his shipped CPU, KI style after the MCTS) | `ichigo-ki-style`, whole game (`heldout2/ki-whole`) |
| Kenpachi vs Hisagi | frozen `ki-ken` | NIL | `ken-ki-style :p 1.3`, whole game (`heldout2/kh-whole`) |
| the Kenpachi mirror | his shipped CPU | NIL | `ken-ki-style` (kk-ken b0_a0's strategy) |
| the Ichigo mirror | her shipped CPU | NIL | `ichigo-ki-style` (ii-ichigo b2_a0's strategy) |
| Ichigo vs Kenpachi | the proxy pool (`pools.json`) | q1's own two arms (her incumbent is q1) | |
| Ichigo vs Hisagi | the proxy pool | `:ki-ichigo` | `ken-ki-style` (`:ki-ken`) |

  - The ceiling pairings' arm 1 is the best other strategy against the pool (seeds 1-100, both seats). Ichigo vs Hisagi: `:ki-ken` 0.65 against
    the incumbent's 0.67 (b / c 29 / 33); c1 0.66, s1 0.135, the generic CPU 0.07, s3 0.045, s7 0.015. Ichigo vs Kenpachi: every single strategy
    is far below q1 (0.645): Kenpachi's KI style 0.275, the shipped CPU 0.26, her KI style 0.25, s0 / s1 / s3 0.0, c1 0.575. c1 is a composite
    of q1's own two arms, so her table is a refit of q1's 48 cells against the pool.
- **Identity** (each table initialised to arm 0 everywhere, or q1 itself for Ichigo vs Kenpachi; run raw against the incumbent, seeds 601-700, both
  seats; `duel hash` / `duel state` / gate-row lines): all six identical, 8 of 8 chunks. Shares: 0.095, 0.035, 0.5, 0.495, 0.615 (pool), 0.71 (pool).
- **Fit** (fq.py: logs of 4 salts x seeds 1-599 x both seats at ε 0.15, 48 crisp rules, γ 0.9, scale 0.1, the 95 % bootstrap gate). Each config
  was trained on 1-500 and validated on 501-599, then refit on 1-599:
  - Round 1, behaviour = the incumbent + ε, π0 = the incumbent.
  - Round 2, where round 1 fell short: behaviour = the alternative everywhere + ε, π0 = the alternative.
  - Round 2 for Ichigo vs Kenpachi: behaviour = round 1's table + ε.

  Validation (501-599, both seats, 198 matches):

| Pairing | Incumbent | Arm 1 alone | Round 1 | Round 2 | Shipped |
|---|---|---|---|---|---|
| Kenpachi vs Ichigo | 0.086 | 0.803 | 0.263 (8 cells arm 1) | **0.823** (vs arm 1 alone b / c 30 / 26) | round 2 |
| Kenpachi vs Hisagi | 0.015 | 0.556 | **0.626** (vs arm 1 alone 46 / 32) | 0.530 | round 1 |
| the two mirrors | 0.5 | 1.0 | 0.995 | **1.0** (no flip: arm 1 everywhere) | round 2 |
| Ichigo vs Kenpachi, pool / his shipped CPU | 0.636 / 0.914 | | 0.328 / 0.631 | 0.621 / 0.859 | **q1 kept** |
| Ichigo vs Hisagi | | | no flip (arm 0 everywhere) | | round 1 |

  - The window-by-window fit misjudges an arm it only sees in single explored windows. A style CPU's state resets at each switch, so one window
    of a style is not that style kept up. Kenpachi vs Ichigo's round 1 kept arm 0 where his own style looked better for a window (0.263 against
    the alternative's 0.803). Ichigo vs Kenpachi's round 1 gave Kenpachi's style to "behind, free, awakened" (29 % of the judgements) and fell to
    0.33 against the pool. Data logged under the policy being judged (round 2) fixes most of it.
  - Kenpachi vs Ichigo's 1-599 refit did not settle in 4 improvement rounds (two sets of 9 / 11 cells alternate). The table is round 3's: 9 cells
    on arm 0, 39 on arm 1.
- **Held-out** (seeds 701-800, 100 a seat, HARD, the opponent frozen as in the fit; b / c paired):

| Pairing | Table | Incumbent | Arm 1 alone | Table vs incumbent | Table vs arm 1 alone |
|---|---|---|---|---|---|
| Kenpachi vs Ichigo | 0.745 | 0.105 | 0.81 | 131 / 3 (z 11.1) | 22 / 35 (z -1.7) |
| Kenpachi vs Hisagi | 0.645 | 0.015 | 0.58 | 127 / 1 (z 11.1) | 46 / 33 (z 1.5) |
| the Kenpachi mirror | 1.0 | 0.5 | 1.0 | 100 / 0 | identical |
| the Ichigo mirror | 1.0 | 0.5 | 1.0 | 100 / 0 | identical |
| Ichigo vs Hisagi, s3-zoner / pool | 1.0 / 0.69 | 1.0 / 0.69 | 0.885 / 0.635 | identical | 23 / 0, 36 / 25 |

  Kenpachi vs Ichigo's shipped table (the 1-599 refit, unsettled) has one clean measurement: held-out 0.745 against arm 1 alone 0.81 (b / c
  22 / 35, z -1.7). Validation's 0.823 belongs to the 1-500 round-2 table. The drop-in alternative is a table with arm 1 in every cell: it
  plays bit for bit as arm 1 alone (the mirrors' tables show it), so it holds 0.81. The choice is the user's; no more held-out was run on it.
  Ichigo vs Kenpachi keeps `:q1-ichigo-ken`: its refit never beat it on validation, and a new table would reset every player's saved copy
  (the checksum).
- **Arm gaps** (`pairs/gaps.jsonl`; a cap-0.01 learner flips a cell only under a 0.02 gap; "clamp" = the trainer set the arm against the data
  and wrote the other q 0.001 below; "no data" = an arm never sampled):

| Table | Arm 1 cells | Clamp | No data | Data cells: < 0.02 / 0.02-0.05 / > 0.05 (median) | Cells the learner can flip |
|---|---|---|---|---|---|
| Kenpachi vs Ichigo | 39 | 10 | 3 | 23 / 11 / 1 (0.011) | 35 of 48 |
| Kenpachi vs Hisagi | 20 | 11 | 6 | 18 / 11 / 2 (0.016) | 32 |
| the Kenpachi mirror | 48 | 0 | 1 | 7 / 18 / 22 (0.047) | 7 |
| the Ichigo mirror | 48 | 2 | 1 | 9 / 18 / 18 (0.041) | 11 |
| Ichigo vs Hisagi | 0 | 8 | 0 | 23 / 14 / 3 (0.014) | 31 |
| Ichigo vs Kenpachi (q1, unchanged) | 24 | 10 | 4 | 26 / 6 / 2 (0.014) | 40 |

  The mirrors' gaps mostly exceed 0.02, so the online learner barely moves them. In the other tables most cells can flip.
- **Into the game**: five library entries, inlined from `pairs/<p>/<p>-fit.lisp`: `:q1-ken-ichigo`, `:q1-ken-hisagi`, `:q1-ken-ken`,
  `:q1-ichigo-ichigo`, `:q1-ichigo-hisagi`. The HARD lookup now holds Kenpachi vs Ichigo / Hisagi / Kenpachi, the Ichigo mirror, and Ichigo vs
  Hisagi (replacing `:ki-ichigo`, the table's arm 0). Ichigo vs Kenpachi stays q1. Each carries `:apply (me vs)`, so `fq-attach!` gives a human
  the online learner with no other change (page keys `soulduel.fq.<me>.<vs>`). G2 plays NORMAL and stays identical.
- **Proofs on the build with the entries** (601-700, both seats):
  - Each arm-0 table (KI, KH, both mirrors, IH) gives lines identical to the incumbent of the build before the entries (8 of 8 chunks each): arm 0
    plays the old incumbent while the table is itself the lookup entry.
  - Without the runtime fix, Kenpachi vs Ichigo's arm-0 table on the same lookup plays 0.005 with 0 of 8 chunks identical: the negative control.
  - Each fitted table run raw equals the live lookup (8 of 8): the lookup path plays the table.
- **Both seats live** (every CPU on the lookup, seeds 601-700, both seats; §8.15's column in brackets; Hisagi as of this build, before §8.17's
  entries):

| Me vs | Share |
|---|---|
| Kenpachi vs Ichigo | 0.765 (0.095) |
| Ichigo vs Kenpachi | **0.235 (0.905)** |
| Kenpachi vs Hisagi | 0.68 (0.035) |
| Hisagi vs Kenpachi | **0.32 (0.965)** |
| Ichigo vs Hisagi | 1.0 (1.0) |
| Hisagi vs Ichigo | 0.0 (0.0) |
| the Kenpachi mirror | 0.485 (0.5); median 300 s, 3 draws of 100 |
| the Ichigo mirror | **0.025 (0.495): 95 draws of 100**, time-outs (both seats on her KI style) |
| the Hisagi mirror | 0.5 |

  - Kenpachi playing Ichigo's KI style is §8.14's proxy 1, which q1 already lost to (0.135). With Kenpachi's table live, Ichigo vs Kenpachi falls
    from 0.905 to 0.235. Her library has no counter: every arm was far below q1 against the pool. The same holds the other way for Hisagi vs
    Kenpachi.
  - The HARD Ichigo mirror between two CPUs becomes a stalemate.
- Kenpachi vs Hisagi's and Ichigo vs Hisagi's numbers are measured against Hisagi's entries before §8.17 (`:ki-ken`, `:s3-zoner`). §8.17
  replaces them (`:qh-ken`, `:qh-ichigo`, `:qh-mirror`), so these two and the Hisagi rows above are to be measured again after the merge.
- Checks: host tests 9926 → 9956 ALL PASS (the lookup's new entries: ids, `:apply`, 2 arms x 48 rules, NIL arm 0 where the incumbent has no
  strategy; `strat-arms` now lists the tables, as it listed q1), pkgcheck (only the existing DUEL::APP, sim-state.lisp), G2 `--cvc` identical
  (II 32, IK 34, KK 33 lines), `./build.sh duel`.
- Open for the user:
  - the cross effect on Ichigo vs Kenpachi (0.905 → 0.235) and Hisagi vs Kenpachi;
  - the HARD Ichigo mirror's draws in CPU vs CPU;
  - Kenpachi vs Ichigo's table (0.745 held-out) or a table with arm 1 in every cell (0.81).
- **Merged on main and measured with every lookup entry live (seeds 601-700, HARD, CPU vs CPU, Hisagi's §8.17 tables included):** IK 0.235 /
  KI 0.765; HK 0.76 / KH 0.24; IH 0.655 / HI 0.335; KK 0.485 (median 300 s); II 0.025 (95 time-outs of 100); HH 0.295 (about 41 %
  draws). `*strat-picks*` widened to 32 a side (the library holds 18; a host test keeps it within 32). Artifact v371.
- **The user's decisions (2026-11-09).**
  - Kenpachi vs Ichigo's entry: 「留著 (Recommended)」. It stays, and IK in CPU vs CPU falls as above.
  - The three mirror entries: 「全留，不改」. They stay on both seats, and CPU vs CPU mirrors often time out.
  - Kenpachi vs Ichigo's table: 「維持擬合版」. The fitted table (0.745) ships, not arm 1 in every cell (0.81).
  - None of the three changes code.

### 8.19 Q tables that really switch: arms by situation, kept style state, a longer horizon, distance and state in the rules (2026-11-09)

The user asked: 「你的 Q 表怎麼怪怪的？為什麼會整場用同樣策略？理論上在對戰中的每個時間點不是都能切換不同策略才對嗎？」

- **The finding.** The selector does re-judge every 90 steps in neutral (`strat-switch-step`, about 86 judgements a match). But six of the
  nine shipped tables pick one arm in (nearly) every cell. Out of 48 cells, the count that pick arm 1:
  - KK 48, II 48, IH 0, HI 1, HH 3, HK 12;
  - mixed: KI 39, KH 20, IK 24.
- **Why they learnt not to switch:**
  - each table has two arms, both whole-game styles, with no division of labour;
  - a switch to another style function clears its state;
  - the value looks about 15 s ahead (a reward per window from the health change, γ 0.9 per 1.5 s window);
  - the data holds one arm played on and the other only in single explored windows.
- **The user's decision:** 「重做：分工選項＋保留狀態＋看更長 (Recommended)」 + 「將距離與其他狀態細節都以模糊規則展開成 Q table 的一部分」.
  1. Arms divided by situation, 3–4 a pairing.
  2. Each style keeps its state across switches.
  3. Training led by the match's outcome.
  4. Distance and the other state details expanded as fuzzy rules inside the Q table.
  5. The starting table proved equal to the shipped one.
- A pilot on one pairing comes first: Hisagi vs Ichigo, the weakest table (0.335 / 0.415) and the one where distance matters most. The other
  eight follow its method.
- **The judgement period (the user, 2026-11-09: 「每 0.5s 就判斷一次」).** The new tables judge every 30 steps (0.5 s) in neutral, not 90.
  - It is a per-table key (`:period`), defaulting to `*strat-switch-period*` 90, so the shipped tables, the composite c1 and G2 stay
    bit-identical.
  - The start table's identity proof runs at 90; the pilot then plays at 30.
  - γ, the health shaping and the online learner's per-window values are rescaled to the 0.5 s window.
- **The arm set (the user, 2026-11-09: 「每個角色設計多個通用策略與少量的針對性對敵策略」).**
  - Each character gets several general strategies (aim 3–5, `:apply (me)`), each with a situational job, and a few strategies aimed at
    one opponent (1–2 a pairing, `:apply (me vs)`).
  - A pairing's table chooses among the character's general strategies plus that pairing's targeted ones.
  - The general ones are shared by the character's three tables. The pilot checks Hisagi's against Kenpachi and the mirror too.

**The pilot: Hisagi vs Ichigo (2026-11-09).** Everything is in `docs/research/strategy-drsi/fq/switch/` (`sw.py`, README: `fq/README.md`
"§8.19"). The opponent is always Ichigo's frozen `:ki-ichigo`, HARD, both seats.

- **Runtime** (every key off by default; every shipped table, c1 and G2 unchanged: `--cvc` identical, II 32, IK 34, KK 33 lines):
  - `:period N` in a table's `:fq`: judged every N steps in neutral (`strat-switch-step`; default `*strat-switch-period*` 90).
  - `:keep-state t`: a switch between two style functions keeps the leaving style's state in a new brain slot `sw-keep` ((fn . state) ...)
    and the coming style resumes its own. Without the key it is cleared, as before.
  - `:groups (n0 n1 ...)`: the rules in order form groups. Each group is averaged by its own firing strengths and Q is the sum (an additive
    fuzzy Q; a group with no rule firing adds 0). `strat-fq-fire` normalises per group, so the online learner's `fq-q-at` is the same sum.
    No `:groups`: the old code path.
  - `:xfeats t`: extra cues, read only at a judgement (`strat-xfeats`, core-ai.lisp; `strat-feats` is unchanged, it runs every step):
    `:dm` the perceived distance (m), `:form` (0 the base form / Shikai, 1 the ranged mode or any awakened form, 2 the bind mode),
    `:oawk` his awakening, `:gauge` DRIVE (awakened) or SUBLIMATION (before) as a fraction, `:wall` metres to the arena's wall.
  - `:gamma` / `:scale`: the online learner's per-window discount and reward scale for this table (`fq-match-end`); default the globals.
  - New fuzzy sets (fuzzy.lisp; no existing set changed): `:k2` `:k3` (index points), `:p2up` (a previous arm of 2 or more); distance
    `:m-close` (full to 2.9 m, gone by 3.4: J1's / the ranged volumes' 3.0 m dead zone and §8.16's 2.9 / 3.4 m), `:m-mid` (2.9-3.4 up, 4.5-6.0
    down: where WA's hit puts him, the 3-6 m bands of RANSA / ŌGI), `:m-far` (from 4.5-6.0); `:g-low` / `:g-high` about the switch's 0.25;
    `:w-near` / `:w-open` at 2-3 m (the ranged rule's cornered 2.0 m).
  - Tooling: `strat-run.lisp STRAT_FQLOG "<salt> <eps> <seat> <rmin> <rmax>"` explores in runs for any number of arms. A judgement outside
    a run starts one with chance eps; the arm (uniform among the others) and the length (rmin..rmax judgements) come from u / eps. A second
    hash of the same inputs is a linear map of the first, and the first version's arms sat in a narrow band. With `:xfeats` the log adds the
    extra cues and the normalised firing vector.
- **The rule base** (89 rules, 5 groups; 534 q at 6 arms):

| Group | Rules | Antecedents |
|---|---|---|
| G0 | 72 | lead x ored x ost (free / busy) x awk x prev: the shipped 48 (prev arm 0 / 1) + 24 with prev `:p2up` |
| G1 | 9 | my form (Shikai / ranged / bind) x distance (`:m-close` / `:m-mid` / `:m-far`): the user's distance rule is one interaction group |
| G2 | 4 | the switch's gauge (low / high) x awk |
| G3 | 2 | the wall (near / open) |
| G4 | 2 | his awakening (KESSA) |

  Ichigo's pointer and form beyond her awakening, his red / busy beyond G0 and a full cross product were left out.
- **Arms** (6). Five are general (`:apply (:hisagi)` or none) and one is aimed at Ichigo (`(:hisagi :ichigo)`). All are data over the existing
  style functions: no new Lisp. Each arm was played whole first (`switch/arms/screen.py`; HI seeds 1-300, 600 matches; HK against the proxy
  pool, HH against the shipped CPU, seeds 1-50, 100 matches; HARD):

| # | Arm | Kind | Job | HI | HK (pool) | HH |
|---|---|---|---|---|---|---|
| 0 | `:hm1-merged` | general | all-round; the ranged mode's distance rule | 0.407 | 0.56 | 1.0 |
| 1 | `:s3-zoner` (the shipped arm 1) | general | the zoner | 0.0 | 0.01 | 0.53 |
| 2 | `:hm2-dswitch`: merged + `:dswitch 1.0` `:dswitch-map ((:base 1 3))` | general | the DRIVE switch route | 0.372 | 0.57 | 1.0 |
| 3 | `:hm3-press`: merged + the brawler's data | general | close pressure | **0.713** | **0.82** | 1.0 |
| 4 | `:hm4-kite`: merged + s7-kite's data | general | the kite | 0.272 | 0.70 | 1.0 |
| 5 | `:ht1-ki`: Kenpachi's KI style code | targeted (written against Ichigo) | | 0.458 | 0.61 | 0.99 |
| | the shipped table (`:qh-ichigo` / `:qh-ken` / `:qh-mirror`) | | | 0.402 | 0.75 | 0.99 |
| | dropped: the brawler's data alone; `:h1-range` | | | 0.0; 0.0 | 0.0; 0.04 | 0.31; 0.71 |

  The generic-CPU arms (data with no style function) lose to her KI style; data on top of the merged code changes a lot (press: HI 0.41 ->
  0.71, HK 0.56 -> 0.82).
- **Training** (`sw.py log / fit`): each round logs 2-4 salts x seeds 1-599 x both seats (2,396-4,792 matches) with the behaviour table +
  runs (eps 0.03 a judgement, runs of 6-18 judgements = 3-9 s, ~26 % of the windows). Fit: the return per window, gamma per 0.5 s window, health
  shaping 0.1 x Δ(balance), ±1 at the end. A ridge V over all rows (the state's value), per arm a ridge delta on the residuals (λ 300: shrunk
  to no preference). A delta survives only where 20 match-bootstrap replicates agree on its sign >= 95 %; no surviving delta means arm 0.
  - Rounds: r1 from the start table; r2a from r1 (gamma 0.966); r2b from press everywhere; r3 from r2a. Variants were picked on seeds
    851-950, then confirmed on 801-1000 (400 matches). 601-800 was not touched until the pick was frozen.

| Table (selection, share) | 851-950 | 801-1000 |
|---|---|---|
| shipped `:qh-ichigo` / the start at period 30 / merged whole / press whole / Kenpachi's KI style whole | 0.355 / 0.36 / 0.36 / 0.675 / 0.39 | - / - / - / 0.672 / - |
| r1, gamma 0.966 / 0.99 / 1.0 | 0.58 / 0.45 / 0.365 | |
| **r2a, gamma 0.966 (the pilot)** / 0.99 | **0.70** / 0.605 | **0.685** / 0.59 |
| r2b (from press), gamma 0.966 / 0.99 | 0.35 / 0.63 | - / 0.593 |
| r3 (from r2a), gamma 0.95 / 0.966 / 0.98 | 0.58 / 0.605 / 0.64 | - / 0.583 / 0.637 |

  - The pilot against press whole on 801-1000: b / c 79 / 74 (they win different seeds). With `:keep-state` removed: 0.69 (b / c 39 / 41):
    **kept state measured no effect**.
  - **The horizon.** Per window the old gamma 0.9 per 1.5 s is 0.966 per 0.5 s (0.966³ = 0.901): the same ~15 s. The shaping is a telescoping Δ,
    so 0.1 per window is unchanged. Longer horizons measured worse (gamma 0.99: 0.45-0.605; 1.0: 0.365), and round 3 did not improve on round 2.
    The longer view the pilot has comes from judging arms in 3-9 s runs and on-policy rounds, not from gamma.
- **Proofs** (`identity.py`, seeds 601-700, both seats, 8 of 8 chunks):
  - The start table (`switch/hi-sw0.lisp`: the shipped 48 rules inside the grouped base, arms 2-5 below, every new group 0, `:xfeats` /
    `:keep-state` / `:groups` on, period 90) against `:qh-ichigo` run raw: 0.335 = 0.335, 6,940 lines identical. Measured twice: on the build
    before the entry (against the lookup) and on the final build (`--ref hisagi/hi-fqm.lisp`).
  - At period 30 the start table is its own row (0.325 / 0.41, the one flipped cell judged three times as often).
  - On the final build, the pilot run raw = the live lookup: 0.595 = 0.595, 6,647 lines identical.
- **Held-out** (seeds 601-700 / 701-800, 100 a seat; the list fixed before running; b / c = the pilot won and the other lost / the reverse):

| | 601-700 | 701-800 | the pilot's b / c |
|---|---|---|---|
| shipped `:qh-ichigo` (period 90) | 0.335 | 0.415 | 72 / 20, 85 / 24 (z 5.4, 5.8) |
| the start table, period 30 | 0.325 | 0.41 | 74 / 20, 86 / 24 |
| merged whole | 0.325 | 0.42 | 74 / 20, 84 / 24 |
| press whole (`:hm3-press`) | **0.755** | **0.725** | 29 / 61, 38 / 39 (pooled z -2.5) |
| **the pilot** (`:qhs-ichigo`) | **0.595** | **0.72** | |

- **How it switches** (held-out, both blocks, 400 matches):
  - 449 judgements a match (shipped 166); **48 arm changes a match** (median 39-44.5, no match without one; shipped 0.2-0.6).
  - Arm shares: merged 0.155, s3-zoner 0.003, DRIVE switch 0.073, press 0.012, kite 0.04, Kenpachi's KI style 0.718.
  - By form and distance band (`:dm` < 2.9 / 4.5 m), the shares over 0.05:

| | close | mid | far |
|---|---|---|---|
| Shikai | merged 0.55, DRIVE switch 0.40, press 0.05 (16,672) | DRIVE switch 0.49, merged 0.43, KI 0.08 (1,705) | merged 0.54, kite 0.36, DRIVE switch 0.09 (5,811) |
| ranged mode | **merged 0.78**, press 0.13, KI 0.08 (2,563) | KI 0.96 (83,491) | KI 0.87, merged 0.07, DRIVE switch 0.05 (54,535) |
| bind mode | kite 0.57, merged 0.38 (5,197) | merged 0.72, kite 0.16, KI 0.06 (7,513) | merged 0.45, kite 0.42, s3 0.06, KI 0.06 (2,307) |

  - The division of labour matches the user's rules. In the ranged mode, close in, it plays the merged style, whose distance rule backs off or
    pushes out; at range it plays Kenpachi's KI style, which keeps him out. The DRIVE switch route runs in the Shikai up close.
  - The ranged mode (STRAT_HRANGE): mean distance 4.29-4.30 m, share inside 3 m **0.118** (shipped 0.211-0.220, merged whole 0.213-0.220,
    press whole 0.32-0.35). Close events: 3,992; 1,724 WA; 2,053 back Steps; 358 side Steps; 45 DRIVE switches.
- **Cost of 0.5 s judging.** One judgement on the native host (`switch/bench.lisp`): 34 µs (the shipped 48 x 2) -> 45 µs (89 x 6). Native
  sim, 200 matches: 44.1 -> 46.5 s of CPU from period 90 to 30, about 276 more judgements a match at ~43 µs each. That is about 1.5 µs a
  frame amortised natively. Both are measured on the host; in wasm, one judgement in a frame is estimated (not measured) far below the 16.7 ms
  frame.
- **Arm gaps** (best Q - second at the held-out judgements, `switch/gaps.py`): median 0.030. 31 % under 0.02 (one q at cap 0.01 flips it);
  83 % under 0.05; 100 % under 0.10 (with 5 groups an arm's Q moves up to 0.05 at cap 0.01). The online learner can move most choices
  (§8.17's HI table was the stiffest).
- **The online learner's V for a grouped table** (strategy.lisp `fq-v-at`): Glorennec & Jouffe's Σ_r α_r max_a q_r(a) equals max_a Q for one
  crisp group, but with `:groups` it sums per-group maxima and sits above max_a Q. At the pilot's held-out judgements it was 0.048 above at
  the median (mean 0.053, p90 0.077): more than the arm gaps' median 0.030. So it would push the played arm's q toward +cap whatever the
  player did. A grouped table now takes max_a Q(s′, a); a table without `:groups` keeps the old formula (host check: two groups that disagree).
- **The online learner** keeps η 0.05, cap 0.01 and ε 0. The pilot carries `:gamma 0.966 :scale 0.1`: the old 0.9 per 1.5 s scaled to the
  0.5 s window, the scale unchanged. The globals `*fq-online-gamma*` 0.9 / `*fq-online-scale*` 0.1 stay for every other table.
  - Smoke on the final build (`fq/online.py train`, 25 matches, her KI style as the "player", cap 0.01): 189 of 534 q moved (59 at the cap,
    max 0.01), 8 rules' argmax changed, 15 wins against the frozen table's 16 (b / c 5 / 6: noise at 25). Before the V fix the same smoke
    had 148 q moved and 20 / 16 wins.
  - The page entry `soulduel.fq.7.3` grows from 99 to **537 integers** (3 + 534; FQ-TABLE reads at most 999, the stride per pair is 1000).
    `pwa.js` maps any entry j < 1000 (no length cap). The checksum changes, so every player's saved Hisagi vs Ichigo copy starts fresh.
- **Into the lookup:** `*strat-library*` gains `:qhs-ichigo` (the pilot inlined); `*strat-lookup*` Hisagi vs Ichigo HARD plays it in place of
  `:qh-ichigo`, which stays in the library (19 entries, within the 32 slots).
  - Both seats live (601-700): Ichigo vs Hisagi falls to 0.405 (0.655 against `:qh-ichigo`, §8.18).
  - Host tests 9983 ALL PASS: groups, per-group firing, a grouped table with zero extra groups = the shipped picks on every crisp cell; the new
    entry's 6 arms / 89 rules / keys / page round trip.
- **What carries over to the other eight pairings:**
  - Unchanged: the runtime keys and the rule base; G1's forms are Hisagi's (form index 0 / 1 / 2; for Kenpachi and Ichigo 0 / 1).
  - `sw.py`: its pairing, opponent and arm list become arguments.
  - The five general arms are Hisagi's for his other two tables (screened above).
  - The method: arms screened whole, 2 rounds of run exploration, selection on 801-1000, held-out last.
  - Per pairing about an hour of compute on 20 cores: a round's logs 3-10 min, a fit 3 min, selection 2-3 min a table, held-out and proofs a
    few minutes. Plus the arms (a general set per character; targeted ones per opponent).
- **Open for the user:**
  - Press whole (merged + the brawler's data) beats the pilot here (pooled 0.74 vs 0.658, b / c 67 / 100) but stands inside 3 m in the ranged
    mode 3x as often (0.32-0.35 vs 0.118). Three options: keep the switching table; play press whole; or put press in as arm 0 and refit.
  - Press as a whole-game style or arm 0 for Hisagi's other two tables (HK pool 0.82 against the shipped table's 0.75).
  - Kept state measured no effect: keep `:keep-state`?
  - s3-zoner is almost never picked (0.3 %). It stays only for the start table's identity with `:qh-ichigo`; drop it in the next table?
- **The user's three answers (2026-11-09):**
  - 「press 當 arm 0 重擬合 (Recommended)」: Hisagi vs Ichigo gets press (merged + the brawler's data) as arm 0 and is refit, to keep the
    switching and reach press's 0.74. `:qhs-ichigo` stays in the lookup until the refit matches or beats it on held-out seeds.
  - 「照試做方式重做，含 press (Recommended)」: Hisagi vs Kenpachi and the mirror are rebuilt the same way, over Hisagi's general arms with
    press among them.
  - 「兩個都拿掉 (Recommended)」: the new tables drop `:keep-state` and the s3-zoner arm. The keys stay in the code, off by default. Without
    s3-zoner the start table is no longer `:qh-ichigo`, so the identity proof is replaced by "the start table plays arm 0 whole".

**Round 2: Hisagi's three tables rebuilt (2026-11-09).** Files are in `docs/research/strategy-drsi/fq/switch/` (`hi/`, `hk/`, `hh/`, `arms/*.arms`; `fq/README.md` "§8.19").

**Shared setup.**
- The method is the pilot's:
  - the same 89 rules in 5 groups;
  - a judgement every 30 steps (0.5 s);
  - exploration in runs (eps 0.03 per judgement, runs of 6-18 judgements);
  - the ridge fit with the bootstrap sign gate;
  - picks made on seeds 801-1000 (400 matches);
  - a held-out list fixed before 601-800 was run.
- No table has `:keep-state` or s3-zoner. Each table has 5 arms, so the page holds 3 + 5 x 89 = **448 integers** (the pilot held 537).
- `sw.py` now takes the pairing, the opponent and an arms file as options. `arms/hi-pilot.arms` reproduces the pilot's start table byte for byte.
- `sw.py pin` gives one arm a bonus in a form's G1 rows.
- A new tool counter counts the CPU's DRIVE switches by form:
  - `*cai-switch-counts*` in core-ai.lisp;
  - a `dswitch` line in `strat-run.lisp STRAT_HRANGE`.
- Opponents:
  - HI: Ichigo's frozen `:ki-ichigo`;
  - HK: Kenpachi's HARD lookup table `:q1-ken-hisagi` (`pairs/kh/kh-fit.lisp`), passed explicitly;
  - HH: the shipped `:qh-mirror` on the other seat.
- Arms, played whole (HK seeds 1-100 against `:q1-ken-hisagi`, HH seeds 1-100 against `:qh-mirror`, 200 matches each; HI as in the pilot):

| Arm | Kind | HK | HH |
|---|---|---|---|
| press (merged + the brawler's data) | general | 0.47 | 0.35 |
| merged | general | 0.34 | 0.29 |
| merged + the DRIVE switch | general | 0.375 | 0.30 |
| merged + kite | general | **0.545** | **0.60** |
| Kenpachi's KI style code | targeted | 0.34 | 0.295 |
| s7-kite (data only, the HK counter search's) / `:h1-range` | | 0.015 / 0.01 | - / 0.035 |
| the shipped table (`:qh-ken` / `:qh-mirror`) | | **0.78** | 0.28 (~44 % draws) |

  No style code is aimed at Kenpachi or at Hisagi himself. HK and HH reuse the KI style code as the targeted arm, labelled `(:hisagi :kenpachi)` /
  `(:hisagi :hisagi)`.

**HI: press as arm 0.**
- Arms: press (arm 0), merged, merged + the DRIVE switch, merged + kite (general), and the KI style code aimed at Ichigo.
- The start table (arm 0 everywhere) run raw = press whole: 0.755 = 0.755, 8 of 8 chunks, 6,671 lines.
- Selection, seeds 801-1000 (press whole 0.672, the pilot 0.685):

| Table | Share | Arm changes a match | Note |
|---|---|---|---|
| round 1, gamma 0.966 / 0.98 / 0.995 / 1.0 | 0.547 / 0.677 / 0.698 / 0.645 | 60 / 60 / 71 / 30 | press played 1.6 % (gamma 0.98) |
| round 1 gamma 0.98, arm 0 pinned in the Shikai | 0.833 | 16 | b / c against press whole 82 / 18 |
| the same with arm 0 = press + `:dswitch 1.0` (**the pick**) | **0.835** | 16 | |
| round 1 gamma 0.966 / 0.995 pinned | 0.82 / 0.77 | | |
| round 2 (behaviour: the pinned table) gamma 0.98 / 0.966, pinned / unpinned | 0.72 / 0.78, 0.425 / 0.417 | | |

- **Why the pin.** Press whole stays in the Shikai: 161,448 of 200,344 judgements on 801-1000, against about 22,000 for every unpinned fit.
  - The unpinned fits leave press for other arms in 3-9 s runs, and those arms take him into the Bankai.
  - A 0.5 s window value, even at gamma 0.995, does not see what leaving the Shikai costs later.
  - The pin is a hand rule, not a fit: G1's three Shikai rows give arm 0 +1.0. The table decides the ranged mode and the bind mode.
- **The DRIVE switch in the Shikai never fires** under the merged code: 0 Shikai switches in every table, the pilot included.
  - `ken-ki-style` decides the Shikai's NS gaps itself, so `cai-dswitch` is never reached there.
  - The switches counted are in the ranged mode (`hr-gap`'s WA hit) and the bind mode.
- **Held-out** (both seats, 100 seeds a seat; b / c = the pick won and the other lost / the reverse):

| | 601-700 | 701-800 | the pick's b / c |
|---|---|---|---|
| `:qhs-ichigo` (the pilot) | 0.595 | 0.72 | 70 / 16, 47 / 16 (z 5.8, 3.9) |
| press whole | 0.755 | 0.725 | 29 / 7, 36 / 6 (z 3.7, 4.6) |
| round 1 gamma 0.995 unpinned (the best unpinned) | 0.68 | 0.75 | 52 / 15, 43 / 18 |
| **the pick, `:qhs2-ichigo`** | **0.865** | **0.875** | |

- How the pick plays (held-out, 400 matches):
  - **15.1 arm changes a match; 136 matches without one**, all of which never left the Shikai.
  - Arm shares: press 0.786, KI style 0.175, the DRIVE switch 0.018, merged + kite 0.016, merged 0.005.
  - By form and band: the Shikai is press (1.00). Ranged mode: close is the DRIVE switch 0.46, kite 0.19, merged 0.16, press 0.13; mid is KI
    0.96; far is KI 0.83. Bind mode: kite 0.50-0.60, the DRIVE switch 0.22-0.44.
  - The ranged mode's share inside 3 m: 0.173 / 0.179 (the pilot 0.119 / 0.118, press whole 0.32 / 0.35).
  - DRIVE switches 0.31 a match (ranged 100, bind 22, Shikai 0; the pilot 0.17).
- **Arm gaps** (`gaps.py`, held-out judgements): the Shikai's median is 0.981 (the pin), out of the online learner's reach. The ranged mode's
  median is 0.044 (91 % under 0.05) and the bind mode's 0.024 (71 % under 0.05). Against a player only the Bankai's choices adapt.
- Online smoke (25 matches, her KI style as the "player", cap 0.01): 103 of 445 q moved (44 at the cap), 12 rules' argmax changed, 21 wins
  against the frozen table's 21.
- The pick run raw = the live lookup: 0.865 = 0.865, 8 of 8 chunks, 6,579 lines.
- With both seats on the lookup (601-700), Ichigo vs Hisagi falls to **0.13** (0.405 against the pilot).

**HK: no swap; `:qh-ken` stays.**
- Arms: merged, KI style code (`:qh-ken`'s two, whose 48 rules embed as the start table), press, merged + the DRIVE switch, merged + kite.
- The start table run raw = `:qh-ken`: 0.76 = 0.76, 8 of 8 chunks, 6,344 lines.
- Every fit lost to the start on 801-1000 (shipped 0.78):
  - round 1, gamma 0.966 / 0.98: 0.662 / 0.665;
  - pinned to arm 0 in the Shikai: 0.40;
  - pinned to arm 0 in the ranged mode: 0.657.
- On held-out the best fit (gamma 0.98) scored 0.74 / 0.765 against `:qh-ken`'s 0.76 / 0.805 (b / c 30 / 34, 30 / 38).
- That fit plays the KI style code in the ranged mode (0.96 there), so the ranged mode's share inside 3 m is 0.94-0.96 (`:qh-ken` 0.37-0.38).
  It stands next to Kenpachi.
- Press whole: 0.505 / 0.55.

**HH: swapped to `:qhs-mirror`.**
- Arms: the kite (arm 0, the best whole arm against `:qh-mirror`), merged, press, merged + the DRIVE switch, and the KI style code.
- The start table run raw = the kite whole: 0.645 = 0.645, 8 of 8 chunks, 6,036 lines.
- Selection, 801-1000:
  - round 1, gamma 0.966 / 0.98: **0.578** / 0.338;
  - round 2: 0.393;
  - `:qh-mirror`'s self-play: 0.302 (158 draws of 400);
  - the kite whole: 0.637 (4 draws).
- The pin was not tried: unlike HI, the fit spends more of its time in the Shikai than its arm 0 whole does (277,101 ranged-mode steps
  against the kite's 810,773).
- Held-out:

| | 601-700 | 701-800 | draws | the pick's b / c |
|---|---|---|---|---|
| `:qh-mirror` (self-play) | 0.295 | 0.295 | 82, 82 | 76 / 22, 75 / 23 (z 5.5, 5.3) |
| the kite whole | 0.645 | 0.655 | 8, 3 | 34 / 50, 33 / 53 (z -1.8, -2.2) |
| **the pick, `:qhs-mirror`** | **0.565** | **0.555** | 51, 45 | |

- How the pick plays:
  - 57 arm changes a match, none without one;
  - Shikai close: the DRIVE switch arm 0.69, KI 0.28;
  - ranged close: KI 0.97;
  - bind: press, kite, the DRIVE switch.
- The ranged mode's share inside 3 m: 0.67 / 0.54 (`:qh-mirror` 0.30 / 0.37, the kite whole 0.27 / 0.23). It sits close in the ranged mode,
  against the user's distance rule.
- Arm gaps: median 0.0008, 98 % under 0.02, so the online learner can flip almost every choice.
- New table against new table (CPU vs CPU, 601-700): 0.28, **88 draws of 200** (`:qh-mirror`'s self-play: 82).
- The pick run raw = the live lookup: 0.565 = 0.565, 8 of 8 chunks, 6,194 lines.

**Checks.**
- The library holds 21 entries; `:qhs-ichigo`, `:qh-ichigo` and `:qh-mirror` stay in it.
- Host tests 9995 ALL PASS: the new entries' arms, keys, the Shikai pin and the 448-integer page round trip.
- pkgcheck, G2 and the build are in the handback.

**Open for the user:**
- HI's Shikai is a hand pin:
  - 136 of 400 held-out matches never switch, because they never leave the Shikai;
  - the online learner cannot change the Shikai.
- The DRIVE switch never fires in the Shikai under the merged code. Making it fire needs new style code in `ken-ki-style`'s Shikai NS gap.
- HH beats `:qh-mirror` but loses to the kite whole and breaks the distance rule in the ranged mode. A pin of merged in the ranged mode, or
  the kite whole, is untried.
- With HI at 0.865, Ichigo vs Hisagi in CPU vs CPU falls to 0.13.
- **The user's four answers on round 2 (2026-11-09):**
  - 「改成可學的偏好」: HI's Shikai pin becomes a learnable preference, not a fixed rule: a prior towards press in the Shikai that the
    online learner can move. It is measured against `:qhs2-ichigo`, which stays live until then.
  - 「寫，量過再決定上線 (Recommended)」: write the DRIVE switch into the Shikai's NS gap (it never fires there today, because
    `ken-ki-style` handles that gap itself), measure it, and ship it only if it beats the live table.
  - 「遠距固定合併風格再重擬合 (Recommended)」: HH pins merged in the ranged mode at close range, the way HI's ranged-close rule backs off,
    and is refit against kite whole and `:qhs-mirror`.
  - 「接受，之後重做一護的表時再追 (Recommended)」: Ichigo vs Hisagi CPU vs CPU at 0.13 is accepted; Ichigo's tables answer it when they
    are rebuilt.

**Round 3: a learnable Shikai preference, the Shikai's DRIVE switch, HH's ranged close (2026-11-09).**
- Results:
  - HI keeps `:qhs2-ichigo`: the learnable preference picked beforehand lost significantly on held-out.
  - The Shikai's DRIVE switch is written and proven by a script, but it never opens in a match: not shipped.
  - HH swaps to `:qhs2-mirror`. It is ahead of `:qhs-mirror` on both held-out blocks but not significantly, and it restores the distance rule.
- Files: `docs/research/strategy-drsi/fq/switch/` (`prior.py`, `proofs3.sh`, `hi/hi3-*`, `hh/hh3-*`, `hh/qhs2-mirror.lisp`, `arms/hi-ds.arms`,
  `arms/hh-ds.arms`). `sw.py` gains `fit --prior FORM ARM B [--prior-band]` (the ridge shrinks toward the preference; the gate acts on the
  move away from it) and `pin --band`.

**A. HI: a learnable Shikai preference.**
- **What the learner can reach.** The online learner keeps each q within 0.01 of its offline value (`*fq-online-cap*`; the cap is a total,
  not a step).
  - In the Shikai only press is played (eps 0), so only press's q move: by at most 0.01 in each of the 5 groups' rules.
  - So Q(press) can fall by at most 0.05, and a Shikai state can flip only where the preference's lead there is under 0.05.
  - Speed is not the limit: one match has about 400 Shikai judgements at eta 0.05, so the q reach the cap within a match or two.
- **The size** (`prior.py`, round 1's unpinned γ 0.98 fit on round 2's training logs, 314,081 Shikai judgements). The other arms' margin
  over press has median 0.019 and p90 0.071. A bias b on press in G1's Shikai rows then gives:

| b | press greedy | of those, learnable (lead < 0.05) |
|---|---|---|
| 0.04 | 0.83 | 0.98 |
| 0.05 | 0.86 | 0.77 |
| 0.08 | 1.0 | 0.24 |

- **Selection** (seeds 801-1000; the live `:qhs2-ichigo` 0.835):
  - round 1's fit + b 0.05: 0.840 (27 arm changes a match, 50 matches without one), b / c against live 34 / 36;
  - round 1's fit + b 0.08: 0.838 (plays as the pin, b / c 0 / 1);
  - **refitting the Shikai rows from data, starting at that bias** (round 2's logs, `--prior 0 0 B`): b 0.05 0.412, b 0.08 0.417. The data
    pulls the Shikai off press: the window fit's bias of §8.19 round 2 again.
  - The pick, fixed before held-out: b 0.05.
- **Held-out** (seeds 601-700 / 701-800): the pick 0.815 / 0.81 against `:qhs2-ichigo` 0.865 / 0.875 (b / c 12 / 22, 14 / 27; pooled z -2.7).
  **A significant loss: `:qhs2-ichigo` stays.**
  - The pick played 26 changes a match (63 of 400 matches without one, all of them Shikai-only).
  - The ranged mode's share inside 3 m: 0.16.
  - Arm gaps: Shikai median 0.031 (73 % under 0.05), ranged 0.044, bind 0.026.
  - Post hoc, not used for the decision: b 0.08 plays as the pin (0.87 / 0.875, b / c 1 / 0, 0 / 0) with 24 % of its Shikai states in reach.
- **Online smoke** (25 matches, her KI style as the "player", cap 0.01): the Shikai does change, and fast.
  - b 0.05: press greedy in 86 % of the training Shikai states before, 31 % after; 19 wins against the frozen table's 19.
  - b 0.08: 100 % before, 49 % after; **16 wins against 21** (b / c 1 / 6).
  - The online TD sees the same short window as the offline fit, so a learnable preference is unlearned even against a player the table
    beats about 85 % of the time.

**B. A DRIVE switch in the Shikai's NS gap** (new style code, off by default).
- **The code** (cpu-hisagi-range.lisp):
  - the strategy key `:shikai-dswitch`;
  - `hms-shikai-switch`: outside the ranged mode, in his own NS segment's gap, once per segment (a new `hms` slot `dseg`), `cai-dswitch`
    gets the gap before `ken-ki-style`.
  - Without the key nothing is called, so every shipped table, c1 and G2 stay identical.
- **Scripted test:** debug 83809 / 83810 (DUEL_GAMEPLAY "Debug commands"), `tests/scripts/duel-shikai-dswitch.json`. P1 is a HARD CPU
  Hisagi in the Shikai, SUBLIMATION 60, 4.5 m from an idle Kenpachi, NS1 started.
  - With the key: `[29] P1 cpu switch 1 -> 3`, `[32] P1 NS pointer 1 -> 3 (DRIVE)`.
  - Without it: no switch, the KI style's NS links.
- **In matches it never opens:** SUBLIMATION is at or above the switch's 0.25 in 0.0 % of 161,448 Shikai judgements (seeds 801-1000).
  SUBLIMATION fills only once the awakening gauge is full, and then he awakens.
  - HI's table with the key on arm 0: identical to live (b / c 0 / 0, 801-1000; 0 Shikai switches).
  - HH's table with the key on its DRIVE-switch arm: identical outcomes (801-850); the hook also covers the bind mode, where 3 more switches fired.
  - Press + the DRIVE switch with the key, played whole: 0 Shikai switches.
  - **Not shipped.** The key and the scenes stay.

**C. HH: merged preferred at ranged close, and a refit.**
- **The preference.** The same mechanism as A: +0.05 on merged in G1's ranged-close row. `prior.py` on round 2's logs: margin median 0.022;
  at 0.05 merged is greedy in 100 % of those states and all are within the learner's reach.
- **The refit:** 4 salts on that table + runs, refit with `--prior 1 1 0.05 --prior-band close`.
  - Selection: the preference alone 0.573 (ranged inside 3 m 0.27); the refit **0.610** (`:qhs-mirror` 0.578, the kite whole 0.637).
  - The refit moved merged's +0.05 to press at ranged close (press 0.90 there). Press runs the same merged code, so the distance rule still
    owns those close events.
- **Held-out:**

| | 601-700 | 701-800 | draws | ranged inside 3 m | the pick's b / c |
|---|---|---|---|---|---|
| `:qhs-mirror` | 0.565 | 0.555 | 51, 45 | 0.67, 0.54 | 21 / 16, 21 / 17 (pooled z 1.0) |
| the kite whole | 0.645 | 0.655 | 8, 3 | 0.27, 0.23 | 29 / 40, 34 / 50 |
| **the pick, `:qhs2-mirror`** | **0.59** | **0.575** | 53, 47 | **0.27, 0.26** | |

  - **Into the lookup:** ahead of `:qhs-mirror` on both blocks, though not significantly, and back inside the distance rule.
  - It still loses to the kite whole. Following the brief, the kite whole was not switched in.
- **How it plays:** 70 arm changes a match.
  - Shikai close: the DRIVE switch arm 0.61 (in effect the merged code; its switch never opens), KI 0.29, merged 0.11.
  - Ranged: close press 0.90; far press 0.67, KI 0.19.
  - Bind: the kite.
- Arm gaps: median 0.0001 (Shikai), 0.007 (ranged). Almost everything is within the learner's reach.
- New table against new table (601-700): 88 draws of 200, as before (b / c 18 / 18 against round 2's).
- Proofs (`proofs3.sh`, 8 of 8 chunks each): `:qhs2-mirror` run raw = the live lookup (0.59, 6,105 lines). `:qhs2-ichigo` run raw = the live
  lookup on this build (0.865, 6,579 lines).

**Checks.**
- Page storage: `:qhs2-mirror` holds 448 integers.
- The library holds 22 entries; `:qhs-mirror` stays.
- Host tests 9996 ALL PASS.

**Open for the user:**
- A learnable Shikai preference loses or gets unlearned. Three options: keep the hard pin (now); ship b 0.08, which plays as the pin with a
  quarter of its Shikai states in the learner's reach; or freeze the Shikai rows against online learning.
- The Shikai's DRIVE switch can only matter if SUBLIMATION reaches 0.25 in the Shikai. That would need the CPU to hold back its awakening.
- HH still loses to the kite whole (pooled b / c 63 / 90).
- **The user's three answers on round 3 (2026-11-09):**
  - 「偏好 0.08，線上可學掉」: HI ships the learnable Shikai prior at 0.08 (held-out 0.87 / 0.875, the same as the pin), and the online
    learner may unlearn it (in the 25-match smoke the Shikai's press share fell from 100% to 49%, with 16 wins against 21).
  - 「試「延後覺醒」」: try a delayed awakening, so the CPU stays in the Shikai long enough to bank SUBLIMATION, then measure whether the
    Shikai DRIVE switch (`:shikai-dswitch`) helps. It moves the awakening's timing, so it ships only if it beats the live table.
  - 「就這樣，接著做劍八與一護 (Recommended)」: HH stays `:qhs2-mirror`. Kenpachi's and Ichigo's six tables are rebuilt the same way next
    (general arms per character plus targeted ones, the 0.5 s period, the distance and state rules).

**Round 4: the 0.08 preference shipped, a delayed awakening, Kenpachi's three tables (2026-11-09).**
- Results:
  - HI plays `:qhs3-ichigo`, the learnable +0.08 Shikai preference.
  - The delayed awakening makes the Shikai DRIVE switch fire, but it loses badly: not shipped.
  - Kenpachi's three tables are rebuilt and all three go into the lookup:
    - `:qks-ichigo` and `:qks-hisagi` win clearly;
    - `:qks-ken` only matches the shipped table.
- Files: `docs/research/strategy-drsi/fq/switch/` (`hi/qhs3-ichigo.lisp`, `hi/hi4-*`, `hold.sh`, `arms/hi-h*.arms`, `arms/a10-*`, `proofs4.sh`, `kenpachi/`).

**A. HI: `:qhs3-ichigo`** (round 3's `hi3-r1-g98-b0.08`: press +0.08 in G1's Shikai rows instead of the +1.0 pin).
- Run raw = the live lookup: 0.87 = 0.87, 8 of 8 chunks, 6,583 lines.
- Held-out: **0.87 / 0.875**; against `:qhs2-ichigo` b / c 1 / 0 and 0 / 0. Offline it plays as the pin.
- Online:
  - a quarter of its Shikai states are within the learner's 0.05 reach;
  - round 3's smoke: the press share in the Shikai fell from 100 % to 49 % in 25 matches.
- Page: 448 integers.

**B. A delayed awakening** (new: core-ai.lisp `strat-hold-awaken-p`).
- The strategy's `:hold-awaken H` (a `:base` key) keeps `gauges-awakened-ok-p` false while SUBLIMATION is below H of its maximum. That gate is
  what the KI style CPU's awakening, the generic CPU's and the MCTS's skip all read. No key or no strategy: unchanged.
- The arm: press + the DRIVE switch + `:shikai-dswitch` + `:hold-awaken` 0.3 / 0.6. Selection, seeds 801-1000 (live `:qhs3-ichigo` 0.838):

| | share | Shikai DRIVE switches | leaves the Shikai (median) / never |
|---|---|---|---|
| live | 0.838 | 0 | 216 s / 131 |
| H 0.3 in the table | 0.720 (b / c 21 / 68) | 176 (0.44 a match) | 235 s / 161 |
| H 0.6 in the table | 0.733 (25 / 67) | 457 (1.14) | 257 s / 187 |
| H 0.3 / 0.6 whole | 0.613 / 0.647 | 177 / 458 | - |
| press + the switch whole, no hold | 0.657 | 0 | - |

- Held-out (H 0.6, picked on selection):
  - in the table: 0.71 / 0.705 against the live 0.87 / 0.875 (b / c 10 / 42, 7 / 41; z -4.4, -4.9);
  - whole: 0.685 / 0.605;
  - Shikai switches 1.3 a match;
  - leaving the Shikai moves from 223 / 212 s to 268 / 248 s (median), and the matches never leaving it rise from 68 / 69 to 97 / 94.
- **Not shipped.** Banking SUBLIMATION in the Shikai costs more than the switch gives. The key stays off.

**C. Kenpachi's three tables.**
- **Opponents:**
  - KI: Ichigo's frozen `:ki-ichigo`;
  - KH: Hisagi's live `:qh-ken`;
  - KK: the shipped `:q1-ken-ken` on the other seat.
- **G1's forms:** 0 his sealed base, 1 the Shikai or the Bankai.
- **Arms**, played whole (seeds 1-100, 200 matches; the live `:q1-ken-*` in the last row):

| Arm | Kind | KI | KH | KK |
|---|---|---|---|---|
| his KI style code (`ken-ki-style`) | general | 0.71 | 0.245 | 0.43 |
| + the brawler's data (press) | general | **0.78** | 0.165 | 0.425 |
| + s7-kite's data | general | 0.56 | 0.305 | 0.425 |
| + s3-zoner's data | general | 0.645 | **0.39** | 0.385 |
| Ichigo's KI style code | targeted vs Ichigo | 0.035 | 0.31 | 0.0 |
| the generic CPU (no style code) | | 0.0 | 0.0 | 0.0 |
| the live `:q1-ken-*` | | 0.415 | 0.22 | 0.43 |

  No style code aims at Hisagi or at Kenpachi himself.
- **Tables:**
  - each embeds its shipped `:q1-ken-*` (arm 0 NIL = his shipped CPU, arm 1 the shipped arm 1), then adds the other general arms;
  - KI has 6 arms (page 537), KH and KK 5 (page 448);
  - each start table run raw = the shipped table: KI 0.4, KH 0.24, KK 0.485, 8 of 8 chunks each.
- **No priors.** A prior goes only where the short window is known to mislead, and the HI awakening pattern did not appear here: KI's fit stays
  in the base form longer than press whole (52,150 against 31,397 judgements).
- Rounds: round 1 (4 salts, the start table + runs) and round 2 (4 salts, round 1's pick + runs), γ 0.966 / 0.98. Picks on 801-1000.

| Selection (801-1000) | KI | KH | KK |
|---|---|---|---|
| the shipped table | 0.425 | 0.22 | 0.463 (30 draws) |
| best whole arm | press 0.772 | zone 0.422 | - |
| round 1, γ 0.966 / 0.98 | 0.705 / 0.68 | 0.318 / 0.33 | **0.463** / 0.427 |
| round 2, γ 0.966 / 0.98 | 0.682 / **0.797** | 0.417 / **0.507** | 0.453 / 0.453 |

- **Held-out** (601-700 / 701-800; b / c of the pick):

| | the pick | shipped `:q1-ken-*` | best whole | pick vs shipped | pick vs whole |
|---|---|---|---|---|---|
| KI (round 2, γ 0.98) | **0.885 / 0.81** | 0.40 / 0.445 | press 0.795 / 0.805 | 105 / 8, 89 / 16 | 38 / 20, 28 / 27 |
| KH (round 2, γ 0.98) | **0.625 / 0.47** | 0.24 / 0.195 | zone 0.425 / 0.455 | 95 / 18, 78 / 23 | 70 / 30, 50 / 47 |
| KK (round 1, γ 0.966) | 0.52 / 0.45 (draws 17, 11) | 0.485 / 0.455 (draws 6, 18) | press 0.50 / 0.445 | 44 / 37, 37 / 38 | 8 / 4, 4 / 3 |

  All three match or beat the shipped table, so all three go into the lookup: `:qks-ichigo`, `:qks-hisagi`, `:qks-ken`. The KK table is
  press about 97 % of the time, so it only ties.
- **How they switch** (held-out):
  - **KI**: 186 judgements a match, **94 arm changes**. Arm shares: KI style 0.40, press 0.06, kite 0.11, zone 0.20, NIL 0.14, Ichigo's
    code 0.10. Base close: KI style 0.69, zone 0.23. Base far: press 0.82. Released close: zone 0.41, kite 0.37. Released far: Ichigo's code
    0.45, NIL 0.27.
  - **KH**: 391 judgements, **205 arm changes**. Press 0.56, KI style 0.37. Base close: press 0.71. Released close: KI style 0.56, press
    0.34. Released mid: press 0.91.
  - **KK**: 556 judgements, 10.5 arm changes, press 0.97.
- **The switching in KI and KH is mostly flapping.** They change arm about every other judgement, between arms that run the same style
  code with different data.
  - The G0 rules' previous-arm cue can make a 2-cycle.
  - A `:margin 0.01` (keep the previous arm while it trails by less) cut the changes from 92 to 72 (KI) and from 220 to 160 (KH) on
    801-1000 at an equal share (b / c 54 / 50, 57 / 69). That was measured after the picks, so it is not shipped.
- **Arm gaps** (median; under 0.05): KI 0.0095 (95 %), KH 0.022 (69 %), KK 0.0145 (100 %).
- **Proofs** (`proofs4.sh`, 8 of 8 chunks each): `:qhs3-ichigo`, `:qks-ichigo`, `:qks-hisagi` and `:qks-ken` each run raw = the live lookup.
- The library holds 26 entries.
- **Cross effects, both seats on the lookup** (seeds 601-700; `kenpachi/live-600.jsonl`; §8.18's merged numbers in brackets):

| Pairing | Kenpachi's share | the other's share |
|---|---|---|
| Kenpachi vs Ichigo | **0.40** (0.765) | Ichigo vs Kenpachi 0.60 (0.235) |
| Kenpachi vs Hisagi | 0.625 (0.24) | Hisagi vs Kenpachi 0.375 (0.76) |
| the Kenpachi mirror | 0.485 (0.485) | - |

  `:qks-ichigo` was fitted and held out against Ichigo's frozen `:ki-ichigo`, as this round asked. Against her live table `:q1-ichigo-ken`
  it does worse than the `:q1-ken-ichigo` it replaced (0.40 against 0.765), so the swap is a regression in CPU vs CPU.
- **Open for the user:**
  - Kenpachi vs Ichigo. Which opponent should decide the swap: her frozen KI style (the brief's; `:qks-ichigo` wins, 0.885 / 0.81 against
    0.40 / 0.445) or her live `:q1-ichigo-ken` (`:qks-ichigo` loses, 0.40 against 0.765)? Options: keep the swap; go back to `:q1-ken-ichigo`;
    or refit against a pool of both.
  - KI's and KH's flapping. Should a table carry `:margin` (0.01 measured equal on selection), with its own held-out run?
  - The delayed awakening loses; the Shikai DRIVE switch stays off.
- **The user's two answers on round 4 (2026-11-09):**
  - 「每個對戰組合都重新擬合雙方的新表」: every pairing is refit against the other side's new table, not a frozen style CPU. Order: Ichigo's
    three tables are built first (against the live new Hisagi / Kenpachi tables). Then each of the nine tables is refit with its opponent on
    its live lookup table (both seats on the lookup), and the round is repeated while it still moves. The frozen style CPUs are reported
    alongside as a stand-in for a human player, without gating the swap. (`:qks-ichigo` was fit against Ichigo's frozen KI style, so in
    CPU vs CPU it fell to 0.40.)
  - 「不加」: no `:margin`. The KI / KH flapping between arms that share one style function stays.

**Round 5, step 1: Ichigo's three tables (2026-11-09).**
- Results:
  - IH swaps to `:qis-hisagi`.
  - IK keeps `:q1-ichigo-ken`: the refit only ties.
  - II keeps `:q1-ichigo-ichigo`: the refit plays identically.
  - Step 2 (the co-refit of all nine) has not run yet; this hand-back is after step 1.
- Files: `docs/research/strategy-drsi/fq/switch/` (`ichigo/`, `lineup.sh`, `run.sh`, `live9.sh`).
- **Opponents (all live lookup tables):**
  - IK: Kenpachi's `:qks-ichigo`;
  - IH: Hisagi's `:qhs3-ichigo`;
  - II: the shipped `:q1-ichigo-ichigo` on the other seat.
- **G1's forms:** 0 the Shikai, 1 KESSA.
- **Arms**, played whole against those opponents (seeds 1-100, 200 matches; the live `:q1-ichigo-*` in the last row):

| Arm | IK | IH | II |
|---|---|---|---|
| her KI style code (`ichigo-ki-style`) | 0.17 | 0.14 | 0.03 |
| + the brawler's data | 0.215 | 0.23 | 0.035 |
| + s7-kite's data | 0.265 | 0.08 | 0.03 |
| + s3-zoner's data | 0.215 | 0.10 | 0.035 |
| Kenpachi's KI style code on her | 0.27 | **0.42** | 0.06 |
| the generic CPU | 0.0 | 0.0 | 0.0 |
| the live table | **0.61** | 0.14 | 0.03 (mostly draws) |

- **Tables:**
  - each embeds its shipped table's two arms (IK: Kenpachi's code, her code; IH: her code, Kenpachi's code; II: NIL, her code), then three
    general arms;
  - 5 arms each, page 448 integers;
  - each start table run raw = the shipped table: IK 0.6, IH 0.125, II 0.025, 8 of 8 chunks each.
  - Round 1: 4 salts against the live opponent, γ 0.966 / 0.98. IK also ran a round 2. Picks were made on 801-1000.
- **IK:**
  - selection: round 1 0.568 / 0.56, round 2 0.557 / 0.575, against the shipped `:q1-ichigo-ken` 0.60;
  - held-out (the pick, round 2 γ 0.98): 0.565 / 0.635 against 0.60 / 0.645 (b / c 42 / 49, 44 / 46; pooled z -0.7).
  - A tie, slightly below: **`:q1-ichigo-ken` stays**. Swapping in a tie would also reset every player's saved IK copy.
- **IH:**
  - the round-1 fits (0.105 / 0.13) lost to the shipped table (0.163) and far more to Kenpachi's code whole (0.427);
  - Kenpachi's code whole never leaves her Shikai (400 of 400 selection matches), while the fits awaken and fall. This is the short-window
    misjudgement round 2 found in HI.
  - So the fit gets a learnable prior: +0.05 on Kenpachi's code in her base form (`prior.py`: greedy in 100 % of the base-form states, 98 %
    within the learner's 0.05 reach).
  - With it, the table plays Kenpachi's code all match (0 arm changes; she never awakens): 0.427 on selection, the same as the code whole.
  - A smaller +0.02 lets about one switch a match through and falls to 0.207 with 168 draws.
  - Held-out: **0.405 / 0.42** against the shipped table's 0.125 / 0.125 (b / c 70 / 14, 76 / 17; z 6.1, 6.1). **Into the lookup as
    `:qis-hisagi`.**
  - Run raw = the live lookup: 8 of 8 chunks.
- **II:**
  - the fits play her code about 99 % of the time, as the shipped table does: 0.035-0.037 on selection against 0.04, 368 draws of 400;
  - held-out: identical (b / c 0 / 0; 190 and 184 draws of 200);
  - **`:q1-ichigo-ichigo` stays** (an identical swap changes nothing);
  - Kenpachi's code whole against it: 0.08 / 0.095 with almost no draws. Her own code beats it about 90 % of the time.
- **Both seats on the lookup after step 1** (seeds 601-700, the row character's share against the column; `ichigo/live9-600.jsonl`):

| me \ vs | Hisagi | Kenpachi | Ichigo |
|---|---|---|---|
| Hisagi | 0.28 | 0.375 | 0.575 |
| Kenpachi | 0.625 | 0.485 | 0.40 |
| Ichigo | **0.405** | 0.60 | 0.025 |

  Hisagi vs Ichigo was 0.87 against Ichigo's old table (`:qhs3-ichigo`'s held-out). With `:qis-hisagi` it is 0.575 / 0.405.
- The library holds 27 entries. This is the lineup step 2 starts from (`lineup.sh`'s defaults).
- **The user's three answers on round 5 step 1 (2026-11-09):**
  - 「接受 (Recommended)」: IH's `:qis-hisagi` may play one arm the whole match (it wins 0.41 against 0.125; the online learner can still
    move it). Step 2 swaps it only for a table that switches and doesn't lose.
  - 「打平不換 (Recommended)」: step 2 swaps a table only on a significant held-out win against the live opponent; a tie keeps the live table
    (and the players' saved online copies).
  - 「不設上限，但將相似的策略合併，或將策略解耦成更小的單位，確保策略庫的『高內聚、低耦合』」: the library has no size cap. Instead it is
    restructured: similar strategies are merged, and strategies are decoupled into smaller units, so that the library is "highly cohesive,
    loosely coupled". Today every Q table carries full copies of its arms, so the same arm (merged, press, KI style...) is written out again
    in table after table. The plan: each arm becomes one named unit (a character's general arms, a pairing's targeted arms), defined once;
    a Q table holds only its rules and the arm ids it chooses among; the 32-entry cap (`*strat-picks*`, 32 slots a side) becomes dynamic.
    Superseded tables stay, in the small form. The refactor must not change play: every live table run raw equals the lookup before and
    after, and G2 stays identical. It comes before step 2.

**Round 5, step 2: the co-refit of all nine (2026-11-09).** The library refactor ran first (§10). Files: `docs/research/strategy-drsi/fq/switch/`
(`corefit/`, `lineup.sh`, `run.sh`, `live9.sh`, `library/entry.py`, `library/add.py`). The new tables are in the unit format.

- **Method:**
  - Each pairing is refit against the other side's live table from the round's start lineup (`lineup.sh`). The behaviour is its current
    table plus runs, or a grouped start embedding it where the current table has 48 rules (HK, IK, II).
  - 2 salts, one fit at γ 0.98.
  - HI's and IH's learnable priors are put back (press +0.08 in the Shikai; Kenpachi's code +0.05 in her base form).
  - Selection is on 801-1000, held-out on 601-800 against the current table.
  - A swap needs a significant held-out win. All accepted swaps of a round apply together.
  - Round 2 refits only the pairings whose opponent changed in round 1 (KH, IK, HH). The others' round-1 refits had already met that opponent.
- **Round 1:**

| Pairing | Selection: candidate / current | Held-out 601-700 / 701-800: candidate vs current (b / c) | Decision |
|---|---|---|---|
| HI | 0.56 / 0.56 (identical: both stay in the Shikai against `:qis-hisagi`) | - | keep `:qhs3-ichigo` |
| HK | 0.902 / 0.492 | 0.86 / 0.92 vs 0.375 / 0.53 (107 / 10, 86 / 8) | **`:qhs-ken`** |
| HH | 0.580 / 0.307 (the merged pin, below) | 0.595 / 0.55 vs 0.28 / 0.265 (84 / 21, 80 / 23) | **`:qhs3-mirror`** |
| KI | 0.545 / 0.40 | 0.445 / 0.555 vs 0.40 / 0.355 (51 / 42, 67 / 27; pooled z 3.6) | **`:qks2-ichigo`** |
| KH | 0.583 / 0.507 | 0.54 / 0.53 vs 0.625 / 0.47 (42 / 59, 61 / 49) | keep `:qks-hisagi` |
| KK | 0.415 / 0.477 | - | keep `:qks-ken` |
| IK | 0.635 / 0.60 | 0.56 / 0.615 vs 0.60 / 0.645 (40 / 48, 42 / 48) | keep `:q1-ichigo-ken` |
| IH | 0.427 / 0.427 (identical, no switching) | - | keep `:qis-hisagi` |
| II | 0.037 / 0.04 (368 draws of 400 each) | - | keep `:q1-ichigo-ichigo` |

  - **HH and round 3's merged rule.** The plain refit put Kenpachi's KI style code at ranged close: its lead over merged there has median
    0.127, and the learnable +0.05 prior did not hold it. That would undo round 3's 「遠距固定合併風格」.
    - The swapped table keeps merged there with a +0.25 bonus in the ranged-close G1 row (`corefit/hh-r1m.lisp`). That is beyond the
      online learner's reach.
    - It scores the same as the plain refit (0.580 against 0.578, b / c 15 / 14), and the ranged mode's share inside 3 m falls from 0.44 to
      0.37-0.41.
  - **HK sits close.** It plays press 0.75-0.78 with the ranged mode inside 3 m 0.97 of the time (`:qh-ken` 0.47-0.54). The same merged pin
    (`corefit/hk-r1m.lisp`) cuts that to 0.76 at 0.882 against 0.902 on selection (b / c 2 / 10). The swap follows the brief's rule (the
    tested `hk-r1`); the pin is an open question.
- **Round 2** (against the new HK, KI and HH):
  - KH: 0.045 against its current table's 0.095 (b / c 7 / 27): no table of its arms answers the new HK. **Keep.**
  - IK: 0.748 against 0.455 on selection; held-out 0.74 / 0.76 against `:q1-ichigo-ken`'s 0.545 / 0.445 (b / c 70 / 31, 83 / 20). **`:qis-ken`.**
  - HH: 0.247 against 0.40. **Keep.**
- **Both seats on the lookup** (seeds 601-700; the row character's share; start / after round 1 / after round 2; `ichigo/live9-600.jsonl`,
  `corefit/live9-r1-600.jsonl`, `corefit/live9-r2-600.jsonl`):

| me \ vs | Hisagi | Kenpachi | Ichigo |
|---|---|---|---|
| Hisagi | 0.28 / 0.375 / 0.375 | 0.375 / **0.86** / 0.86 | 0.575 / 0.575 / 0.575 |
| Kenpachi | 0.625 / **0.14** / 0.14 | 0.485 / 0.485 / 0.485 | 0.40 / 0.445 / **0.26** |
| Ichigo | 0.405 / 0.405 / 0.405 | 0.60 / 0.545 / **0.74** | 0.025 / 0.025 / 0.025 |

- **Not converged: the round-2 move is best-response chasing.**
  - Round 1's KI table beat Ichigo's old table (0.40 → 0.445), and round 2's IK answer took it back further (0.445 → 0.26).
  - Hisagi's HK gain (0.375 → 0.86) has no answer in Kenpachi's arms.
  - The stop rule is two rounds, and a third round would refit KI against the new IK.
- **Against the frozen style CPUs** (a stand-in for a human, reported only; seeds 601-700):
  - **Hisagi:** HI 0.87 against Ichigo's KI style, unchanged; HK 0.89 against Kenpachi's KI style (`:qh-ken` 0.375 against the same member
    in §8.15's pool).
  - **Kenpachi vs Ichigo:** KI **0.34** against her KI style (round 4's `:qks-ichigo` 0.885).
  - **Ichigo vs Kenpachi:** IK **0.47** against his KI style (`:q1-ichigo-ken` 0.805 in §8.15's pool).
  - Hisagi has no style CPU, so HH, KH, IH and the mirrors have no stand-in.
  - Fitting against the other CPU table trades robustness against the style CPUs for the CPU vs CPU pairing.
- **The new tables:**

| Table | Arms | Switches / match | Page integers |
|---|---|---|---|
| HK `:qhs-ken` | 5 | 14 | 448 |
| HH `:qhs3-mirror` | 5 | 55 | 448 |
| KI `:qks2-ichigo` | 6 | 93 | 537 |
| IK `:qis-ken` | 5 | 72-75 | 448 |

  - **Saved copies:** each has a new checksum, so the players' saved copies of those four pairings start fresh. That includes Ichigo vs
    Kenpachi's `:q1-ichigo-ken`, the oldest learner (since §8.14).
  - **Proofs** (`corefit/proofs.sh`): each run raw = the live lookup, 8 of 8 chunks.
  - The library holds 31 entries (no cap).

- **Decisions on round 5, step 2 (the user, 2026-11-09):**
  - HK's close range: 「以表訓練出來的結果為準，不刻意處理」. `:qhs-ken` stays as fitted (the ranged mode inside 3 m 0.97); no merged pin.
  - A third round: 「請同時優化，不是一個做完再優化另一個」. KI and IK are optimised together, not one best response after the other.
  - The frozen stand-in: 「加上，KI/IK 回原表」. A swap must also not lose significantly to the frozen style CPU where one exists. KI goes back
    to `:qks-ichigo` (0.885 against her KI style), IK to `:q1-ichigo-ken` (0.805), so their saved copies keep their checksums. HK stays (0.89).
  - HH's +0.25 merged pin: 「拿掉，照資料用 KI 風格」. HH takes the plain round-1 refit (`corefit/hh-r1.lisp`, Kenpachi's KI style code at
    ranged close), after its own held-out test against `:qhs2-mirror`. This replaces round 3's fixed merged style at ranged close for HH.

**Round 5, step 3: KI and IK optimised together (2026-11-09).** Files: `docs/research/strategy-drsi/fq/switch/joint/`.
- **Lookup changes first:**
  - KI goes back to `:qks-ichigo` and IK to `:q1-ichigo-ken` (their checksums, so the saved copies, are as before).
  - HH plays `:qhs4-mirror` = `corefit/hh-r1.lisp`, the plain round-1 refit. Its held-out test against `:qhs2-mirror` is round 1's (the
    table on one seat, `:qhs2-mirror` on the other): 0.605 / 0.55 against `:qhs2-mirror`'s self-play 0.28 / 0.265 (b / c 83 / 18, 79 / 22).
    A significant win.
  - `:qks2-ichigo`, `:qis-ken` and `:qhs3-mirror` stay in the library, superseded.
- **The method** (fixed before any held-out run): two iterations of simultaneous fictitious play with the stand-in in the pool.
  - Each iteration logs both sides at once from their current iterates: KI_t + runs, IK_t + runs, 2 salts x seeds 1-599 x both seats. Then it
    refits both (γ 0.98) into KI_{t+1} and IK_{t+1}.
  - Each side's opponent is a pool, member = seed mod n:
    - every past iterate of the other side, the old live table included;
    - plus the other side's frozen style CPU: Ichigo's KI style for KI, Kenpachi's KI style for IK.
  - So no side fits a best response to the other's latest table alone.
  - KI_0 = `:qks-ichigo`. IK_0 = `:q1-ichigo-ken`, its behaviour the grouped start embedding it (`ichigo/ik-s0-p30.lisp`).
  - **The candidate per side:** of its two iterates, the one with the higher mean share on seeds 801-1000 against the members of its last pool.
- **The acceptance rule** (fixed before the held-out runs; seeds 601-700 + 701-800, both seats; b / c pooled over the two blocks, paired by
  seed and seat):
  - The 2×2 is measured from each side's seat: old / new KI × old / new IK.
  - KI_new replaces `:qks-ichigo` only if all three hold:
    1. it beats KI_old significantly against IK_old (z ≥ 1.96);
    2. it beats KI_old significantly against IK_new (z ≥ 1.96);
    3. it does not lose significantly to KI_old against Ichigo's frozen KI style (z > -1.96).
  - IK_new replaces `:q1-ichigo-ken` likewise: against KI_old and KI_new, and against Kenpachi's frozen KI style.
  - Each side is decided on its own, so one, both or neither may swap; a tie keeps the old table.
  - Beating the old table against both the old and the new opponent is what a pure best response to the latest opponent cannot pass.
- **The iterates** (selection, seeds 801-1000, the mean share against the last pool's three members):
  - KI_1 0.549 (against `:q1-ichigo-ken`, IK_1 and the stand-in: 0.415, 0.517, 0.715); **KI_2 0.672** (0.507, 0.635, 0.873).
  - IK_1 0.577 (0.52, 0.482, 0.73); **IK_2 0.588** (0.53, 0.525, 0.708).
  - So the candidates are KI_2 and IK_2.
- **Held-out** (601-800 pooled, 400 matches a cell):

| 2×2, Kenpachi's share | IK_old (`:q1-ichigo-ken`) | IK_new (IK_2) |
|---|---|---|
| KI_old (`:qks-ichigo`) | 0.378 | 0.448 |
| KI_new (KI_2) | **0.548** | **0.598** |

| 2×2, Ichigo's share | KI_old | KI_new |
|---|---|---|
| IK_old | 0.623 | 0.453 |
| IK_new | 0.553 | 0.403 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the frozen stand-in | verdict |
|---|---|---|---|---|
| KI | 128 / 60, 4.96 | 127 / 67, 4.31 | 52 / 41, 1.14 (0.875 vs 0.848) | **swap** |
| IK | 71 / 99, -2.15 | 61 / 81, -1.68 | 35 / 72, -3.58 (0.718 vs 0.81) | keep |

  - **KI → `:qks3-ichigo`** (`joint/ki-t2.lisp`).
    - About 79 arm changes a match. Arms: Ichigo's code 0.385, Kenpachi's code 0.24, kite 0.15, zoner 0.15, press 0.04, NIL 0.025.
    - Page 537 integers. Its checksum is new, so the saved Kenpachi vs Ichigo copies start fresh.
  - **IK stays `:q1-ichigo-ken`.** It loses on all three counts, most of all against Kenpachi's KI style.
- **Proofs** (`joint/proofs.sh`, 8 of 8 chunks each):
  - `:qhs4-mirror` run raw = the live lookup (self-play 0.375);
  - `:qks3-ichigo` (0.555 against `:q1-ichigo-ken`);
  - `:q1-ichigo-ken` (0.445 against `:qks3-ichigo`).
- **Both seats on the lookup after step 3** (seeds 601-700, the row's share; `joint/live9-600.jsonl`; after step 2's round 2 in brackets):

| me \ vs | Hisagi | Kenpachi | Ichigo |
|---|---|---|---|
| Hisagi | 0.375 (0.375) | 0.86 (0.86) | 0.575 (0.575) |
| Kenpachi | 0.14 (0.14) | 0.485 (0.485) | **0.555** (0.26) |
| Ichigo | 0.405 (0.405) | **0.445** (0.74) | 0.025 (0.025) |

- **Each live table against its frozen stand-in** (seeds 601-700):

| Table | Score | Before |
|---|---|---|
| HI `:qhs3-ichigo` (vs Ichigo's KI style) | 0.87 | - |
| HK `:qhs-ken` (vs Kenpachi's KI style) | 0.89 | - |
| KI `:qks3-ichigo` (vs Ichigo's KI style) | **0.865** | `:qks-ichigo` 0.885, step 2's `:qks2-ichigo` 0.34 |
| IK `:q1-ichigo-ken` (vs Kenpachi's KI style) | 0.805 | - |

- The library holds 33 entries, two of them new: `:qhs4-mirror` and `:qks3-ichigo` (no cap).
- `:qks2-ichigo`, `:qis-ken` and `:qhs3-mirror` stay in the library as superseded.

- **Decisions on round 5, step 3 (the user, 2026-11-09):**
  - IK: 「繼續同時優化 2 次」. KI and IK run two more simultaneous fictitious-play iterations from the current lookup (`:qks3-ichigo`,
    `:q1-ichigo-ken`), under step 3's fixed rule (win against the old and the new opponent at z ≥ 1.96; not lose to the frozen stand-in).
  - KH 0.14: 「新選項＋兩邊同時優化」. First a dream-rsi search for a Kenpachi arm targeted at Hisagi, then KH and HK optimised simultaneously in
    the same way. HK still must not lose to its stand-in (Kenpachi's KI style CPU); KH has none (Hisagi has no style CPU).

- **How to search for strategies from now on (the user, 2026-11-09):** 「請再找策略的時候用全局性的觀點同時思考兩邊的策略，並將具有「高內聚，低耦合」特性的策略保留下來」.
  - **Global, both sides at once.** A strategy (arm) search for a pairing runs over both characters' arms together, judged in the joint game.
    It does not look for a counter to one fixed opponent table. Each candidate is scored against the other side's whole pool of plausible
    replies: its live table, past iterates, new candidate arms and its frozen stand-in where one exists.
  - **Keep only high-cohesion, low-coupling strategies.**
    - A kept arm does one recognisable job: one style unit plus data units that all serve one plan.
    - It is built from existing §10 units where it can, adding at most a small new unit.
    - It earns its place across the pool, not against a single opponent table.
    - Near-duplicates of an existing arm are merged into it.
    - Candidates that fail these tests are dropped, not stored as superseded.
  - Applies to step 4's Kenpachi-vs-Hisagi arm, which becomes a joint KH / HK arm search, and to any later search.

**Round 5, step 4: two more KI / IK iterations; the joint KH / HK search (2026-11-09).** Files: `docs/research/strategy-drsi/fq/switch/joint/`
(`run4.sh`, `step4a.sh`), `docs/research/strategy-drsi/fq/switch/khjoint/`.

*Part A: KI and IK, two more iterations* (「繼續同時優化 2 次」).
- **The method is step 3's, unchanged:**
  - The iterations start from the live lookup: KI_2 = `:qks3-ichigo`, and IK = `:q1-ichigo-ken` (logged through its start embedding).
  - Each pool holds every past iterate of the other side (step 3's included) plus its frozen style CPU. The pool has five members by iteration 4.
  - The candidate per side is the better of iterates 3 and 4 on seeds 801-1000 against the last pool's members.
  - The held-out runs use the fixed rule unchanged. "Old" is the live lookup: KI `:qks3-ichigo`, IK `:q1-ichigo-ken`.
- **Selection** (801-1000, the share against each pool member in order, then the mean):
  - KI_3: 0.583 against `:q1-ichigo-ken`, 0.713 / 0.65 / 0.647 against IK_1 / IK_2 / IK_3, 0.325 against Ichigo's KI style; mean **0.584**.
  - KI_4: 0.242, 0.583, 0.583, 0.5, 0.64; mean 0.510.
  - IK_3: 0.58 against `:qks-ichigo`, 0.56 / 0.438 / 0.35 against KI_1 / KI_2 / KI_3, 0.723 against Kenpachi's KI style; mean **0.530**.
  - IK_4: 0.242, 0.31, 0.13, 0.578, 0.022; mean 0.256.
  - So the candidates are KI_3 and IK_3.
- **Held-out** (601-800 pooled, 400 matches a cell):

| 2×2, Kenpachi's share | IK_old (`:q1-ichigo-ken`) | IK_new (IK_3) |
|---|---|---|
| KI_old (`:qks3-ichigo`) | 0.548 | 0.558 |
| KI_new (KI_3) | 0.583 | 0.69 |

| 2×2, Ichigo's share | KI_old | KI_new |
|---|---|---|
| IK_old | 0.453 | 0.418 |
| IK_new | 0.443 | 0.308 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the frozen stand-in | verdict |
|---|---|---|---|---|
| KI | 102 / 88, 1.02 | 120 / 67, 3.88 | 11 / 255, -14.96 (0.265 vs 0.875) | keep |
| IK | 72 / 76, -0.33 | 61 / 105, -3.42 | 36 / 77, -3.86 (0.708 vs 0.81) | keep |

- **Neither side swaps.** KI stays `:qks3-ichigo` and IK stays `:q1-ichigo-ken`, so their checksums and saved copies are unchanged.
  - The iterates now chase each other. KI_3 beats Ichigo's iterates but collapses against her KI style (0.325 on selection, 0.265 held out).
  - IK_4 loses almost everywhere (mean 0.256), worst against Kenpachi's KI style (0.022).
  - The stand-in clause is what stops KI_3. Against `:q1-ichigo-ken` alone it is a tie (z 1.02).

*Part B: Kenpachi vs Hisagi, both sides at once* (「新選項＋兩邊同時優化」, under the search rule above).
- **1. The joint arm search** (`khjoint/cands.py`, `matrix.py`, `matrix.json`).
  - **Candidates:** every arm the §10 units build for each side, played whole, no new code. The data-only keys a KI style reads are `:range`
    and the DRIVE switch (§8.8), so each candidate is one style + data units.
    - Kenpachi, 11: the shipped CPU; his KI style alone and with the brawler / kite / zoner data; Ichigo's KI style the same four ways; each
      KI style + `:dswitch 1.0`.
    - Hisagi, 11: the five HK arms (merged, Kenpachi's KI style, press, the DRIVE switch, kite); merged + switch + press; Ichigo's KI style
      alone and + switch; the ranged-mode style; Kenpachi's KI style + the kite's data, and + the switch.
  - **Each scored in the joint game against the other side's whole pool** (seeds 1-100, both seats, 200 matches a cell; 169 cells, plus
    Hisagi's 11 against the stand-in).
    - Kenpachi's pool: Hisagi's live `:qhs-ken`, his past `:qh-ken`, and Hisagi's 11 new candidates.
    - Hisagi's pool: Kenpachi's live `:qks-hisagi`, his past `:q1-ken-hisagi`, the stand-in (Kenpachi's KI style CPU), and Kenpachi's 11
      new candidates.
    - "pool" = the mean of the live table, the past table and the candidates' mean (+ the stand-in for Hisagi).
    - Hisagi's share in a cell is 1 - Kenpachi's. Draws are 0-3 in 200, so this is off by at most about 0.015.
  - **The method:** a one-round enumeration of these 22 unit combinations, not dream-rsi subagent cells. Under a KI `:fn` only `:range` and
    `:dswitch` act, so a cell could do little but pick among these combinations.

| Arm (whole) | pool | vs live | vs past | vs the candidates | stand-in |
|---|---|---|---|---|---|
| Kenpachi: live `:qks-hisagi` (reference) | 0.417 | 0.095 | 0.47 | 0.685 | - |
| Kenpachi: his KI style (`:a-ken-ki`, in the table) | 0.341 | 0.105 | 0.245 | 0.673 | - |
| Kenpachi: Ichigo's KI style (`:a-ichigo-ki`) | 0.304 | **0.205** | 0.31 | 0.396 | - |
| Kenpachi: Ichigo's KI style + brawler (`:a-ichigo-press`) | 0.300 | 0.24 | 0.28 | 0.381 | - |
| Kenpachi: Ichigo's KI style + switch | 0.297 | 0.175 | 0.32 | 0.397 | - |
| Kenpachi: best other (his zoner, in the table) | 0.306 | 0.005 | 0.39 | 0.524 | - |
| Hisagi: live `:qhs-ken` (reference) | 0.898 | 0.905 | 0.895 | 0.895 | - |
| Hisagi: Kenpachi's KI style + kite (`:a-ken-kite`) | **0.686** | 0.755 | 0.585 | 0.717 | 0.685 |
| Hisagi: press (in the table) | 0.593 | 0.55 | 0.47 | 0.767 | 0.585 |
| Hisagi: Kenpachi's KI style (in the table) | 0.408 | 0.40 | 0.34 | 0.561 | 0.33 |
| Hisagi: Ichigo's KI style; the ranged style | 0.167; 0.012 | 0.0; 0.0 | 0.13; 0.01 | 0.537; 0.036 | 0.0; 0.0 |

  - **One arm a side went into the fit.** Both are existing units, so no new unit is needed.
    - Kenpachi: `:a-ichigo-ki` = `:st-ichigo-ki` alone. It is the best whole arm against Hisagi's live table: 0.205 against his best in-table
      arm's 0.105. Against the past table it also beats his KI style (0.31 vs 0.245).
      - Its two variants are near-duplicates and merge into it: + brawler (0.24 / 0.28 / 0.381) and + switch (0.175 / 0.32 / 0.397), all
        within noise of it on every pool member.
    - Hisagi: `:a-ken-kite` = `:st-ken-ki` + `:d-kite`. It is the best whole arm across Kenpachi's pool (0.686), beating his best in-table
      arm, press (0.593), on the live table, the past table and the stand-in.
      - Its nearest existing arms: the same style without the kite's range (0.408), and the kite with the merged style (0.544).
  - **Dropped:** the rest, including the near-duplicates above.
    - Each KI style + switch matches the style alone: Kenpachi 0.334 vs 0.341, Hisagi 0.399 vs 0.408.
    - Ichigo's KI style on Hisagi and the ranged-mode style win nothing against Kenpachi's tables.
- **2. KH and HK optimised together** (`khjoint/start.sh`, `iterate.sh`, `run.sh`).
  - Each live table gets its kept arm appended as arm 5 (`extend.py`: the new arm 1 below every row's minimum).
  - **Proved** = the live lookup (`identity-t0-600.jsonl`, 8 of 8 chunks): KH 0.14, HK 0.86.
  - Then step 3's method: two iterations, 2 salts x 1-599 x both seats a side. The pools:
    - KH's: Hisagi's past iterates (no stand-in: Hisagi has no style CPU);
    - HK's: Kenpachi's past iterates + his KI style CPU.
  - The same fixed rule; for KH only the two z ≥ 1.96 wins.
  - **Selection** (801-1000):
    - KH_1 0.311 (0.10 against HK_0, 0.522 against HK_1); **KH_2 0.508** (0.295, 0.72).
    - HK_1 0.439 (0.46, 0.468, 0.39 against the stand-in); **HK_2 0.543** (0.60, 0.50, 0.53).
  - **Held-out** (601-800, 400 matches a cell):

| 2×2, Kenpachi's share | HK_old (`:qhs-ken`) | HK_new (HK_2) |
|---|---|---|
| KH_old (`:qks-hisagi`) | 0.108 | 0.473 |
| KH_new (KH_2) | **0.21** | 0.74 |

| 2×2, Hisagi's share | KH_old | KH_new |
|---|---|---|
| HK_old | 0.89 | 0.788 |
| HK_new | 0.508 | 0.245 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the stand-in | verdict |
|---|---|---|---|---|
| KH | 75 / 34, 3.93 | 153 / 46, 7.59 | (none) | **swap** |
| HK | 24 / 177, -10.79 | 24 / 241, -13.33 | 15 / 212, -13.08 (0.408 vs 0.90) | keep |

  - **KH → `:qks2-hisagi`** (`khjoint/kh-t2.lisp`; arms NIL, `:a-ken-ki`, `:a-ken-press`, `:a-ken-kite`, `:a-ken-zoner`, `:a-ichigo-ki`).
    - Held out against `:qhs-ken`, Ichigo's KI style takes 0.25 of the judgements. It plays on 0.95 of the judgements in his base form and on
      none in the released form. In the released form the arms are press 0.54, his KI style 0.34 and kite 0.11.
    - About 263 arm changes a match (the old table: about 132).
    - Clause 2 was passed against HK_2, which collapses against everything, so it is weak evidence. The support is clause 1 (0.21 vs 0.108
      against the live `:qhs-ken`) and the 3×3 below.
    - Its checksum is new, so the saved Kenpachi vs Hisagi copies start fresh.
    - The new arm is **kept**: one job (Ichigo's KI code while Kenpachi is sealed). It does not top the pool mean (0.304 against
      `:a-ken-ki`'s 0.341), because Hisagi's whole candidate arms beat it. It earns its place as the best arm against Hisagi's live table
      (it also beats his KI style against the past one), and through the table test.
  - **HK stays `:qhs-ken`.** Its refit with `:a-ken-kite` lost on all three counts, so under the rule the arm is **dropped**. Nothing is
    stored, and the unit stays as Kenpachi's.
    - The whole-arm matrix favoured the arm. The failure is the refit's: HK_2 collapses against everything.

*After step 4.*
- **The lookup:** only KH changes, to `:qks2-hisagi`. `:qks-hisagi` stays in the library as superseded, and the library holds 34 entries.
- **Proof** (`khjoint/proofs-600.jsonl`): `khjoint/kh-t2.lisp` run raw = the live lookup against `:qhs-ken`, 0.25 = 0.25, 8 of 8 chunks
  (6,449 lines).
- **Both seats on the lookup** (seeds 601-700, the row's share; `khjoint/live9-600.jsonl`; after step 3 in brackets):

| me \ vs | Hisagi | Kenpachi | Ichigo |
|---|---|---|---|
| Hisagi | 0.375 (0.375) | **0.745** (0.86) | 0.575 (0.575) |
| Kenpachi | **0.25** (0.14) | 0.485 (0.485) | 0.555 (0.555) |
| Ichigo | 0.405 (0.405) | 0.445 (0.445) | 0.025 (0.025) |

- **Each live table against its frozen stand-in** (seeds 601-700, `ev/j4f-frozen-*`): HI `:qhs3-ichigo` 0.87, HK `:qhs-ken` 0.89, KI
  `:qks3-ichigo` 0.865, IK `:q1-ichigo-ken` 0.805. None of the four tables changed, so the numbers equal step 3's.
- Host tests 10107 ALL PASS; G2 identical (II 32, IK 34, KK 33).

- **Decisions on round 5, step 4 (the user, 2026-11-09):**
  - KI / IK: 「停在這裡」. `:qks3-ichigo` and `:q1-ichigo-ken` stay. No more fictitious-play iterations for this pair.
  - KH 0.25: 「用 dream-rsi 寫新風格程式」. Step 4's arm was an enumeration of existing units, not a dream-rsi search. Now a real dream-rsi run
    writes new style-function code for Kenpachi against Hisagi. Both sides are searched together under the search rule above, with a worktree
    and a native build per cell. The kept code becomes a §10 style unit, and then KH and HK are optimised simultaneously under step 3's rule.
  - HK's collapsed refit with `:a-ken-kite`: 「維持現狀」. `:qhs-ken` stays.

**Round 5, step 5: a dream-rsi search for Kenpachi's style code against Hisagi (2026-11-09).** Workspace:
`docs/research/strategy-drsi/khfn/` (README there).
- **The program:** `duel/lisp/cpu-kh-ken.lisp`, `ken-kh-style (e b f kit s d)`, a strategy's `:fn` (§9). It is off by default: nothing
  registers it, and only a strategy that names it plays it.
  - The search starts from his KI code unchanged (`ken-kh-style` calls `ken-ki-style`).
  - The file holds only definitions. A `cai-defstyle` there would turn the code on for the shipped CPU, so the rescore checks that the live
    lookup's own share stays put.
- **The evaluator, fixed before round 1** (`khfn/eval.py`): Kenpachi plays `(:id :khfn :fn ken-kh-style)` whole, HARD, both seats, against
  Hisagi's pool.
  - The pool:
    - his live `:qhs-ken`, 100 seeds a seat;
    - step 4's HK iterates 1 and 2, 50 each;
    - his 11 step-4 candidate arms played whole, 25 each.
  - score = (live + iterates + arms) / 3, each group's share (wins + 1) / (matches + 2). That is 950 matches, positive and higher-is-better.
  - Blocks: search seed0 200 (the coordinator's rescore, the number recorded), the cells' dev runs seed0 300, held-out seed0 400 at scale 2
    (1,900 matches; never shown to cells). The table fit's held-out stays 601-800.
- **Hisagi's side** enters through that pool and through the joint KH / HK fit afterwards. No Hisagi code branch: the pool already holds his
  live table, his step-4 iterates and every whole arm his units build.
- **Grid** (the user's budget): 4 branches x 3 attempts, W = 4, at most 2 rounds, with dream / compare / promote between them. Sonnet cells,
  each in its own git worktree with its own native build. Every cell is recorded, failures included.
  - Branch hints (structural): closing on his chain range; two codes in one style by form and situation; his Bankai's bind and ranged
    mode; resources (awakening, L, cash-out, Reishi, the Burst).
- **References** (the same evaluator; search / dev / held-out x2):
  - his KI code (the baseline): 0.457 / 0.415 / 0.429;
  - Ichigo's KI code on Kenpachi: 0.339 / 0.383 / 0.371;
  - the live KH table `:qks2-hisagi`: 0.593 / 0.590 / 0.555.
- **The keep rule** (fixed before round 1). A code is kept only if, on the held-out block, all three hold:
  1. its score ≥ 0.4586: the better KI code's 0.4286 + 0.03. The test is unpaired, since the evaluator has no per-seed pairing across
     candidates.
  2. its live group ≥ 0.1716: the better KI code on the live table, Ichigo's.
  3. it is not a near-duplicate: the mean |difference| of its 14 member shares is ≥ 0.05 against both KI codes.
  - Of the codes that pass, the best becomes one style unit. A second is kept only if it passes and is not a near-duplicate of the first.
  - Then it goes in as KH's arm, KH and HK are optimised together under step 3's rule, and the held-out is 601-800.
- **Round 1** (12 cells, Sonnet 5.5, each in its own worktree; every cell recorded). Search score = the coordinator's rescore on seed0 200;
  the baseline is 0.457.

| Cell | The code (around his KI code) | Search | Held-out (x2) |
|---|---|---|---|
| b0_a0 | **the wake-up bait**: at Hisagi's knockdown no meaty J1; hold 2.3 m (inside his CPU's 2.4 m wake-up Hoho trigger) and punish the Hoho's end | **0.883** | **0.892** (live 0.908) |
| b1_a0 | Ichigo's KI code while sealed, his own released, a stalemate clock | 0.453 | - |
| b2_a0 | punish his whiffed / blocked chain moves within 3 m | 0.483 | - |
| b3_a0 | the combo breaker: awaken or Burst once a combo | 0.450 | - |
| b0_a1 | b0_a0 + two closing-in knobs (both off: no gain) | 0.883 | - |
| b1_a1, b3_a1 | the bait + the combo breaker | 0.931, 0.931 | b3_a1 0.925 |
| b2_a1 | **the stand-off breaker**: when no gauge has moved for 2 s and the bell is not his, lift his KI code's Hoho-safety hold and attack | **0.669** | **0.638** (live 0.40) |
| b0_a2 | the bait + the stand-off breaker | 0.878 | - |
| b1_a2, b2_a2, b3_a2 | the bait + the combo breaker + the stand-off breaker | 0.947 each | b1_a2 0.955 |

  - The coordinator's mistakes, both re-recorded with FORCE:
    - b0_a0 was first recorded as a runtime failure because `rescore.sh` was not executable.
    - b1_a0 was first recorded as a correctness failure because the new host test wrongly required frame thresholds to rise with
      difficulty. It now checks chances only.
  - **The dream step** (one world; weak evidence, as §8.10):
    - The incumbent policy (the configured grid's parallel refine) replays at reward -0.0125 (auc 0.0, parallel penalty 0.25; beta
      degenerate).
    - The three rewrites (the skill's adaptive template at beta 0.6 / 0.3 / 0.9) all replay at 0.4649 (auc 0.4887, penalty 0.475). The
      first batch already held 0.93 of the world's best.
    - `v3_wide` was promoted (a tie, so the later one).
    - **Round 2 was not run:** round 1 gave a clear result, as the coordinator allowed.
- **The keep decision.**
  - Five codes pass the three numeric clauses: b0_a0, b2_a1, b3_a1, b1_a2 (and its twins).
  - The combinations (b1_a1 / b3_a1, b*_a2) bundle two or three state rules. One of them, the combo breaker, failed on its own (0.450).
    Under the user's rule (「高內聚，低耦合」: one recognisable job), "the best that passes" ranges over one-job codes only.
  - **Kept: b0_a0, the wake-up bait**, as the style unit `:st-ken-kh` (`ken-kh-style`, `duel/lisp/cpu-kh-ken.lisp`, 45 lines) and the arm
    `:a-ken-kh`.
    - Its state sits in `brain-style` (a `khs` struct including his KI code's `kks`). It rolls once per knockdown (HARD 1.0, NORMAL 0.5,
      EASY 0).
    - The nearest existing styles: his KI code at mean |Δ| 0.36 over the 14 members, Ichigo's at 0.52.
  - **b2_a1, the stand-off breaker, passes but is not admitted.** It does one job (0.638 held-out, |Δ| 0.20 from the bait). But it keeps
    its state in a process-global hash keyed by the brain, which the in-game MCTS rollouts do not snapshot, and its names clash with b0_a0's.
    Admitting it means rewriting it and measuring again. A second unit is kept only *if* it passes, so it waits for the user.
  - The three-rule combination (b1_a2) scores 0.955 held out against the bait's 0.892 (|Δ| 0.06).
- **KH and HK optimised together** (`fq/switch/khstyle/`: `start.sh`, `run.sh`).
  - The kept arm is appended to `:qks2-hisagi` as arm 6. The start is proved = the live lookup, 0.25 = 0.25, 8 of 8 chunks.
  - HK starts from `:qhs-ken`. Step 3's method and rule apply as in step 4.
  - **Selection** (801-1000):
    - KH_1 0.531 (0.425 against HK_0, 0.637 against HK_1); **KH_2 0.641** (0.372, 0.91).
    - HK_1 0.384 (0.092, 0.352, 0.708 against the stand-in); **HK_2 0.515** (0.48, 0.347, 0.718).
  - **Held-out** (601-800, 400 matches a cell):

| 2×2, Kenpachi's share | HK_old (`:qhs-ken`) | HK_new (HK_2) |
|---|---|---|
| KH_old (`:qks2-hisagi`) | 0.21 | 0.55 |
| KH_new (KH_2) | **0.335** | 0.863 |

| 2×2, Hisagi's share | KH_old | KH_new |
|---|---|---|
| HK_old | 0.788 | 0.663 |
| HK_new | 0.435 | 0.138 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the stand-in | verdict |
|---|---|---|---|---|
| KH | 97 / 47, 4.17 | 152 / 27, 9.34 | (none) | **swap** |
| HK | 48 / 189, -9.16 | 19 / 229, -13.34 | 27 / 109, -7.03 (0.695 vs 0.90) | keep |

  - **KH → `:qks3-hisagi`** (`khstyle/kh-t2.lisp`; the arms of `:qks2-hisagi` + `:a-ken-kh`). Its checksum is new, so the saved copies
    start fresh.
  - **The fit hardly uses the new arm.** Held out against `:qhs-ken` it plays `:a-ken-kh` on 0.012 of the judgements, and his KI code on
    0.77 (0.905 of the base form). About 61 changes a match.
    - The bait's value arrives at a knockdown and the wake-up after it. The per-window fit, judged every 0.5 s and switching the style state
      with the arm, does not credit it.
    - **The arm played whole beats the table by far:** 0.91 against `:qhs-ken` on the held-out block (seeds 401-600), against the table's
      0.30-0.37 on 601-800.
  - HK stays `:qhs-ken`: its refit loses on all three counts again.
- **After step 5.**
  - The lookup changes only KH, to `:qks3-hisagi`. `:qks2-hisagi` stays as superseded, and the library holds 35 entries.
  - New units: the style `:st-ken-kh` and the arm `:a-ken-kh`. Off by default: only `:qks3-hisagi`'s arm 6 plays it.
  - **Proof** (`khstyle/proofs-600.jsonl`): `khstyle/kh-t2.lisp` run raw = the live lookup against `:qhs-ken`, 0.30 = 0.30, 8 of 8
    chunks (6,306 lines).
  - **Both seats on the lookup** (seeds 601-700, the row's share; `khstyle/live9-600.jsonl`). Only KH / HK moved: **Kenpachi vs Hisagi
    0.30** (0.25 after step 4) and **Hisagi vs Kenpachi 0.695** (0.745). The other seven are as after step 4: HH 0.375, HI 0.575, KK 0.485,
    KI 0.555, IH 0.405, IK 0.445, II 0.025.
  - **Each live table against its stand-in** (`ev/j5f-frozen-*`): HI 0.87, HK 0.89, KI 0.865, IK 0.805, unchanged.
  - Host tests 10116 ALL PASS. The new check reads `cpu-kh-ken.lisp`: only definitions, the :fn contract's six arguments, and chances
    rising EASY ≤ NORMAL ≤ HARD. The arm and style units are checked too. G2 identical (II 32, IK 34, KK 33).

- **Decisions on round 5, step 5 (the user, 2026-11-10):**
  - The wake-up bait: 「做成倒地時觸發的事件層」.
    - It becomes an event layer above the table. Whenever Hisagi is knocked down, the bait takes over until his wake-up is over, whatever
      arm the table holds. Then the table's pick resumes.
    - The table keeps switching its other arms as before and is refit with the layer on (KH and HK simultaneously, step 3's rule).
    - The layer is off by default; a table turns it on by a key.
  - Hisagi's wake-up Hoho habit (Hoho on his first free frame within 2.4 m): 「先不動」. Hisagi's CPU is not changed. The bait's exploit is
    recorded as a known limit: there is no Hisagi stand-in to test it against human-like play.
  - The stand-off breaker (b2_a1): 「重寫僵局破解，當第二個選項」. Rewrite its state rollout-safe (in the brain, snapshotted like the
    others, no process-global hash), measure it again under the keep rule, and add it as a second KH arm if it passes. The three-rule
    bundle is not admitted (one job per arm).

**Round 5, step 6: the bait as an event layer; the stand-off breaker; KH / HK refit (2026-11-10).** Files: `fq/switch/khevent/`,
`khfn/standoff.sh`, `khfn/standoff.jsonl`.
- **The event layer** (§10 "The event layer"): `:event-arms ((:knockdown :a-ken-kh))` on a Q table.
  - From Hisagi's perceived knockdown (launched, down, waking up) through the brain's delay + 4 frames after, the bait plays the step whatever
    arm the table holds. Then the table's pick resumes.
  - The bait keeps its state in the brain slot `ev-style`. The table's judgement and learner run underneath, crediting the arm they hold.
  - Code: strategy.lisp `strat-event-arm` (pure) and the `:event-arms` expansion; core-ai.lisp `strat-event-step`, `strat-event-call`;
    brain slots `ev-t ev-on ev-style ev-n ev-steps`.
  - strat-run.lisp prints its `event` line, and sw.py keeps it and takes `--event` for the tables it writes. No other table has the key.
- **The stand-off breaker, rewritten** (`ken-kh-standoff-style`, style unit `:st-ken-kh-standoff`, arm `:a-ken-kh-standoff`): its clock is
  a `kso` struct in `brain-style`, including his KI code's `kks`, with no global hash. The slots are prefixed `so-` because `kks` has its
  own `at`.
  - It plays exactly as the cell did: search 0.6686, held-out 0.638 (live 0.4005), the same numbers to the digit.
  - The keep rule passes: 0.638 ≥ 0.4586, live 0.40 ≥ 0.1716. Its distance is 0.158 from his KI code, 0.36 from Ichigo's and 0.20 from the
    bait. **Kept**, as KH's arm 7.
- **KH and HK optimised together** (`khevent/start.sh`, `run.sh`):
  - KH starts from `:qks3-hisagi` + the stand-off arm with the layer on. Without the layer the start is proved = the live lookup (0.30 =
    0.30, 8 of 8 chunks).
  - HK starts from `:qhs-ken`. Step 3's method and rule, as in steps 4-5.
  - **Selection** (801-1000):
    - KH_1 0.697 (0.693 against HK_0, 0.70 against HK_1); **KH_2 0.907** (0.875, 0.938).
    - **HK_1 0.432** (0.165, 0.29, 0.84 against the stand-in); HK_2 0.425 (0.075, 0.26, 0.94).
  - **Held-out** (601-800, 400 matches a cell; KH_old = the live `:qks3-hisagi`, no layer):

| 2×2, Kenpachi's share | HK_old (`:qhs-ken`) | HK_new (HK_1) |
|---|---|---|
| KH_old | 0.335 | 0.883 |
| KH_new (KH_2, layer on) | **0.843** | 0.945 |

| 2×2, Hisagi's share | KH_old | KH_new |
|---|---|---|
| HK_old | 0.663 | 0.158 |
| HK_new | 0.118 | 0.055 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the stand-in | verdict |
|---|---|---|---|---|
| KH | 218 / 15, 13.3 | 45 / 20, 3.1 | (none) | **swap** |
| HK | 21 / 239, -13.52 | 19 / 60, -4.61 | 29 / 63, -3.54 (0.815 vs 0.90) | keep |

  - **The reference** (the layer on over `:qks3-hisagi` + the stand-off arm, no refit = KH_0) against HK_old: **0.915** (against KH_old
    244 / 12, z 14.5).
    - **KH_2 loses to it** against the live HK: 0.843 vs 0.915, b / c 29 / 58, z -3.11.
    - The refit chased Hisagi's iterates (KH_2 0.938 against HK_1 on selection). The rule's candidates are the iterates 1-2, so KH_0 was
      not one.
  - **KH → `:qks4-hisagi`** (`khevent/kh-t2.lisp`). Arms: `:qks3-hisagi`'s + `:a-ken-kh-standoff`, with `:event-arms ((:knockdown
    :a-ken-kh))`. Its checksum is new, so the saved copies start fresh.
  - HK stays `:qhs-ken`: its refit loses on all three counts again.
  - **The layer at work** (against the live HK, 601-800, 400 matches; `khevent/events.json`):

| | takeovers a match | the layer's share of match time | the table's arms outside the layer (NIL, KI, press, kite, zoner, Ichigo's KI, the bait, stand-off) |
|---|---|---|---|
| KH_2 `:qks4-hisagi` | 11.1 | 0.057 | 0.021, 0.086, 0.019, 0.033, 0.012, 0.133, **0.679**, 0.017 |
| KH_0 (the reference) | 6.8 | 0.034 | 0.028, **0.607**, **0.238**, 0.011, 0.002, 0.080, 0.034, 0 |

    - KH_2 also holds the bait as a table arm 0.68 of the time outside the layer, so it plays the bait code almost everywhere. KH_0 keeps
      his KI code and press between knockdowns.
    - The stand-off arm is rarely held: 0.017 in KH_2, never in KH_0.
- **After step 6.**
  - The lookup changes only KH, to `:qks4-hisagi`. `:qks3-hisagi` stays as superseded, and the library holds 36 entries.
  - **Proof** (`khevent/proofs-600.jsonl`): `khevent/kh-t2.lisp` run raw = the live lookup against `:qhs-ken`, 0.815 = 0.815, 8 of 8 chunks
    (6,306 lines).
  - **Both seats on the lookup** (seeds 601-700, the row's share; `khevent/live9-600.jsonl`). Only KH / HK moved: **Kenpachi vs Hisagi
    0.815** (0.30 after step 5) and **Hisagi vs Kenpachi 0.185** (0.695). The other seven are unchanged: HH 0.375, HI 0.575, KK 0.485,
    KI 0.555, IH 0.405, IK 0.445, II 0.025.
  - **Each live table against its stand-in** (`ev/j6f-frozen-*`): HI 0.87, HK 0.89, KI 0.865, IK 0.805, unchanged.
  - **Rollout safety:**
    - `tools/simgate/fulltest.lisp` on a KH HARD match finds no full-sim job (0 checks): every arm's style decides each free step, so the
      in-game full sim never starts one there.
    - So `khevent/snap.sh` runs `tools/simgate/snaptest.lisp` instead: a KH match (seeds 601-604) played straight, and with a rollout every
      ~40 ticks (snapshot, reseeded play, restore).
    - Result: 1,839 rollouts (163,622 steps). The two outputs are identical but for the timing / consing lines; every hash line and gate
      row matches.
  - Host tests 10132 ALL PASS, with new checks:
    - the window fires on a knockdown, holds through the wake-up + delay + 4, then hands back;
    - it does nothing without the key, and forgets an earlier match's tick;
    - `:event-arms` expands;
    - the stand-off unit and arm exist; KH's table has the layer and the stand-off arm, and it is the only table with a layer.
  - G2 identical (II 32, IK 34, KK 33).

- **Decisions on round 5, step 6 (the user, 2026-11-10):**
  - KH: 「沒重擬合的表 0.915」. KH ships the no-refit reference: `:qks3-hisagi` + the stand-off arm with the layer on. It scores 0.915 vs 0.843
    against the live HK (z 3.11), and between knockdowns it plays mostly his KI code (0.61) and press (0.24). The swap rule now also admits
    the start table with the new layer or arm and no refit, as a candidate beside the refit iterates.
  - Hisagi (KH 0.815 / HK 0.185 through his wake-up Hoho habit; HK's refit lost three times): 「用 dream-rsi 幫檜佐木寫新程式」. A dream-rsi
    search writes one-job style code for Hisagi against Kenpachi, scored against Kenpachi's whole pool, including the bait tables and his
    KI style stand-in. Only HK's strategy changes; the shared CPU (his wake-up habit) stays.

**Round 5, step 7: KH ships the no-refit table; a dream-rsi search for Hisagi's style code (2026-11-10).** Files:
`fq/switch/khevent/` (`proofs7.sh`, `qks5-hisagi.entry`), `docs/research/strategy-drsi/hkfn/` (README there).
- **The swap rule, amended** (the user: 「沒重擬合的表 0.915」). Beside the refit iterates, a side's candidates now include its start table:
  the live table with the new layer or arm added and no refit. The fixed rule (z ≥ 1.96 against the old and the new opponent; for a side
  with a stand-in, z > -1.96 against it) applies to it unchanged.
- **KH → `:qks5-hisagi`** = `khevent/kh-t0.lisp`: `:qks3-hisagi`'s q with the stand-off arm's column 1 below every row, and the bait as the
  `:knockdown` event layer. `:qks4-hisagi` stays as superseded, and the library holds 37 entries.
  - **Checksum:** its q differ from `:qks4-hisagi`'s and from `:qks3-hisagi`'s (one more column), so the checksum is new and the saved
    Kenpachi vs Hisagi copies reset again.
  - **Proof** (`khevent/proofs7-600.jsonl`): `kh-t0.lisp` run raw = the live lookup against `:qhs-ken`, 0.915 = 0.915, 8 of 8 chunks
    (6,314 lines).
  - **Both seats on the lookup** (seeds 601-700; `khevent/live9-7-600.jsonl`): Kenpachi vs Hisagi **0.915** (0.815 with `:qks4-hisagi`),
    Hisagi vs Kenpachi **0.085** (0.185). The other seven are unchanged: HH 0.375, HI 0.575, KK 0.485, KI 0.555, IH 0.405, IK 0.445, II 0.025.
  - Each live table against its stand-in (`ev/j7f-frozen-*`): HI 0.87, HK 0.89, KI 0.865, IK 0.805, unchanged.
  - Host tests 10137 ALL PASS (a new check: `:qks5-hisagi` = `:qks3-hisagi`'s q + the stand-off column below every row). pkgcheck shows
    only `DUEL::APP`, the build and the 8 s smoke pass, and G2 is identical (II 32, IK 34, KK 33).
  - The layer's firing with this table is step 6's reference row: 6.8 takeovers a match, 3.4 % of match time. Between knockdowns it plays
    his KI code 0.61 and press 0.24.
- **The Hisagi search** (khfn's twin; workspace `hkfn/`). Hisagi's shared CPU stays unchanged; the code changes only what Hisagi does in his
  own strategy.
  - **The program:** `duel/lisp/cpu-hk-hisagi.lisp`, `hisagi-hk-style`, a strategy's `:fn`. It is off by default and holds only definitions.
    The search starts from his merged style unchanged, played as `(:id :hkfn :fn hisagi-hk-style :ken-ranged t)`.
  - **The evaluator, fixed before round 1** (`hkfn/eval.py`): Hisagi plays it whole, HARD, both seats, against Kenpachi's whole pool, in four
    groups:
    - the live KH `:qks5-hisagi`, 100 seeds a seat;
    - his earlier KH tables `:qks4-hisagi`, `:qks3-hisagi`, `:qks2-hisagi`, `:qks-hisagi`, 50 each;
    - his 13 whole arms: step 4's 11, the bait and the stand-off breaker, 20 each;
    - his KI style stand-in, 50.
  - score = the mean of the four groups' shares, each (wins + 1) / (matches + 2): 1,220 matches. The blocks are as khfn's: search 200, dev
    300, held-out 400 at scale 2. A tripwire checks that the live HK lookup's own share never moves.
  - **References** (search / dev / held-out ×2):
    - his merged style (the baseline): 0.216 / 0.195 / 0.230;
    - Kenpachi's KI code on Hisagi: 0.303 / 0.296 / 0.285;
    - Ichigo's KI code on Hisagi: 0.125 / 0.117 / 0.136 (but 0.30 against the live KH);
    - the ranged style: 0.011 / 0.013 / 0.009;
    - for context, the live HK table 0.586 / 0.623 / 0.596, and his best step-4 arms (Kenpachi's KI code + kite 0.47, press 0.43 held
      out).
  - **The keep rule** (fixed before round 1). On the held-out block, all five must hold:
    1. score ≥ 0.3153: the best existing style, Kenpachi's KI code on Hisagi, 0.2853 + 0.03; unpaired.
    2. live-KH group ≥ 0.2985: the best style there, Ichigo's KI code.
    3. stand-in group ≥ 0.3762: the best style there, Kenpachi's KI code.
    4. mean |difference| of the 19 member shares ≥ 0.05 against each of the four existing styles.
    5. one job: a bundle of independent rules is not admitted.
    - Then it becomes an HK arm. The candidates are the start table with the arm and no refit, and the simultaneous KH / HK refit iterates,
      under step 3's rule as amended above. HK must not lose to its stand-in.
  - **Grid:** 4 branches x 3 attempts, W = 4, at most 2 rounds, Sonnet 5.5 cells in their own worktrees with native builds.
    - Branch hints: his own knockdowns against a waiting Kenpachi; range control in the Shikai and the ranged mode; punishing Kenpachi's KI
      code; resources.
- **Round 1** (12 cells, every one recorded). Search = the coordinator's rescore on seed0 200; the baseline is 0.216.

| Cell | The code (around his merged style) | Search | Held-out x2: score / live / stand-in |
|---|---|---|---|
| b0_a0 | replace the wake-up's first free frame (roll, guard, SP): all lost, shipped with the chances at 0 | 0.216 | - |
| b1_a0 | the Shikai kite: one back Step as Kenpachi walks into 3.3 m, then the pointer's NS poke from 2.9-6 m | 0.256 | - |
| b2_a0 | at the first free frame after his knockdown, punish Kenpachi's whiffed recovery with J1 / NS | 0.245 | - |
| b3_a0 | the DRIVE switch after his own NS hits | 0.221 | - |
| b0_a1 | walk back for 16 frames when Kenpachi waits at the bait's stand-off | 0.129 | - |
| b1_a1 | the kite in both forms (the ranged mode from 4.2 m) | 0.277 | 0.252 / 0.077 / 0.322 |
| b2_a1 | the whiff punish also in neutral | 0.255 | - |
| b3_a1 | hold the awakening until Kenpachi is far or down (started from the baseline: it missed its parent) | 0.220 | - |
| b0_a2 | hold the wake-up Hoho for 4 frames at the bait's stand-off | 0.125 | - |
| b1_a2 | the kite also on an idle Kenpachi inside 2.9 m | 0.258 | - |
| b2_a2 | the whiff punish with his KI code's move-start race off | 0.282 | 0.257 / 0.169 / 0.243 |
| b3_a2 | Reishi parity at the bell: the free White Burst when he is far and below 80 % Reishi | **0.315** | **0.320** / 0.117 / 0.332 |

  - **No code is kept.**
    - b3_a2 clears the score bar (0.320 ≥ 0.3153) but misses the live-KH floor (0.117 vs 0.2985) and the stand-in floor (0.332 vs 0.3762).
    - Every other cell misses the score bar too.
  - What the cells found:
    - **Every change to his first free frame after a knockdown loses.** At that frame the bait and his KI code's meaty J1 look the same
      (Kenpachi idle about 2.3 m away), and the shared CPU's invulnerable wake-up Hoho is the right answer to the meaty J1 (b0_a0, b0_a1,
      b0_a2).
    - Against the live KH the best gain is the whiff punish after his knockdown (live 0.17-0.19 against the baseline's 0.04). Only
      Ichigo's KI code reaches the 0.30 floor there, and it loses everything else.
  - `duel/lisp/cpu-hk-hisagi.lisp` and its MANIFEST line are removed again: nothing ships. The search's starting file stays in
    `hkfn/baseline/` for a round 2.
  - **The dream step** (one world; weak evidence):
    - The incumbent policy replays at reward -0.0125 (auc 0, penalty 0.25, beta degenerate).
    - The three template rewrites (beta 0.6 / 0.3 / 0.9) all replay at 0.4246 (auc 0.4446, penalty 0.40). `v3_wide` was promoted.
    - **Round 2 was not run:** the coordinator allowed a hand-back after round 1 when the result is clear.
  - So HK stays `:qhs-ken`, and the HK arm and refit step had nothing to add.

- **Decisions on round 5, step 7 (the user, 2026-11-10):**
  - Hisagi (KH 0.915 / HK 0.085; round 1 kept nothing, the best live-KH group 0.17-0.19 against the 0.2985 floor): 「跑第二輪」. A dream-rsi
    round 2 runs on `hkfn/` under the promoted policy (`v3_wide`). The cells may start from the whiff punish (b2_a0) or Ichigo's KI code
    on Hisagi as a base, and the keep rule stays as written before round 1. A kept code becomes an HK arm, and HK and KH refit
    simultaneously (the step 3 rule, with the step 6 amendment). The shared CPU stays unchanged.

**Round 5, step 8: the Hisagi search, round 2 (2026-11-10).** Workspace `hkfn/` (`rounds/round02/`, `dream2.sh`).
- **Setup.** The scaffold (`cpu-hk-hisagi.lisp`, the MANIFEST line, the host check of the file) went back in for the round and came out again
  after it.
  - The promoted `v3_wide` policy planned 4 x 3. It ran each branch's first cell, then continued only branches 0 and 2: 8 cells, all
    recorded.
  - A new direction started from round 1's b2_a0 (the whiff punish; branches 0, 2) or from Ichigo's KI code on Hisagi (branches 1, 3).
  - The evaluator, the blocks and the keep rule are unchanged.

| Cell | Start | The code | Search | Held-out x2: score / live / stand-in |
|---|---|---|---|---|
| b0_a0 | b2_a0 | the whiff punish after his knockdown + a 20-frame guard instead of the wake-up Hoho when nothing fits and Kenpachi is within 1.6 m | 0.258 | 0.280 / 0.231 / 0.272 |
| b1_a0 | Ichigo's | his merged style + Ichigo's timed counter-Hoho on Kenpachi's attack in reach, J1 on the whiff | 0.209 | - |
| b2_a0 | b2_a0 | the whiff punish also after his own Hoho / Step | 0.244 | - |
| b3_a0 | Ichigo's | Ichigo's code + the Reishi pot (live 0.28, stand-in 0.02 on dev) | 0.132 | - |
| b0_a1 | b0_a0 | + a guard as his wake-up Hoho ends | 0.247 | - |
| b2_a1 | b2_a0 | the whiff punish after any busy state | 0.245 | - |
| b0_a2 | b0_a0 | **b0_a0's wake-up punish / guard + round 1 b3_a2's Reishi pot** (two rules) | **0.393** | **0.406 / 0.388** / 0.337 |
| b2_a2 | b2_a1 | a forward Step through Kenpachi's first hit, then J1 (its firing unconfirmed) | 0.217 | - |

- **No code is kept.**
  - b0_a2 is the first code over the live-KH floor (0.388 ≥ 0.2985) and the score bar (0.406 ≥ 0.3153). It misses the stand-in floor
    (0.337 vs 0.3762), and it bundles two rules, which clause 5 does not admit.
  - Its parts alone miss: the wake-up punish / guard (b0_a0) scores 0.280, live 0.231; the Reishi pot (round 1 b3_a2) scores 0.320, live
    0.117.
  - Together they gain against the live KH: Hisagi no longer feeds the bait at his wake-up, and the bell's Reishi tie-break turns toward
    him.
  - Every other cell misses the score bar. Ichigo's KI code stays strong against the live KH only (b1_a0, b3_a0).
- **The dream step** (two worlds now):
  - The incumbent `v3_wide` replays at reward 0.3267 (auc 0.3473, penalty 0.4125; beta non-degenerate).
  - Its three template rewrites (beta 0.45 / 0.15 / 0.6) tie it exactly. `v6_adaptive` was promoted on the tie rule (the later candidate).
- So HK stays `:qhs-ken`, and no game code changed in this step. Host tests, pkgcheck, the build, the smoke and G2 were re-run on the
  unchanged sources.
- **Decisions on round 5, step 8 (the user, 2026-11-10):**
  - b0_a2 (wake-up punish / guard + the Reishi pot; held-out 0.406, live 0.388, stand-in 0.337 vs the 0.376 floor; two rules): 「從 b0_a2
    跑第三輪」. A dream-rsi round 3 runs on `hkfn/` under the promoted `v6_adaptive`, with cells starting from b0_a2 and aimed at the
    stand-in group (Kenpachi's KI style). The keep rule is unchanged, one job included: a code that passes is still split into one-job
    arms (or brought back to the user as an exception) before it joins HK.

**Round 5, step 9: the Hisagi search, round 3, and the split test (2026-11-10).** Workspace `hkfn/` (`rounds/round03/`, `dream3.sh`),
`fq/switch/hksplit/`.
- **Setup.** The scaffold went back in for the step.
  - The promoted `v6_adaptive` planned 4 x 3 and ran all 12 cells, all recorded.
  - Every cell started from round 2's b0_a2 and aimed at the stand-in group. The brief asked each cell to keep its rules as separable pieces.

| Cell | The code (on b0_a2: the wake-up punish / guard + the Reishi pot) | Search | Held-out x2: score / live / stand-in |
|---|---|---|---|
| b0_a0 | + the kite (round 1's: a back Step off a closing Kenpachi, then the NS poke), Shikai only | 0.433 | - |
| b1_a0 | + the kite in both forms | 0.462 | 0.457 / 0.428 / 0.406 |
| b2_a0 | + a Hoho timed through his Step-in J1 | 0.422 | - |
| b3_a0 | b1_a0's code (only a comment differs) | 0.462 | - |
| b0_a1 | b0_a0 unchanged (a guard at the bait was tried and reverted) | 0.433 | - |
| b1_a1 | b1_a0 with a wider kite (from 3.7 m, poke 2.6-6.5 m, 70 frames) | 0.496 | 0.484 / 0.428 / 0.386 |
| b2_a1 | b2_a0 + a perfect Hoho read on his slow move starts | 0.428 | - |
| b3_a1 | b3_a0 with the pot opened (below 95 % Reishi, from 3 m) | 0.498 | **0.489 / 0.478 / 0.406** |
| b0_a2 | b0_a1 unchanged (the NS at the bait was tried and reverted) | 0.433 | - |
| b1_a2 | b1_a1 + b3_a1's pot | **0.528** | 0.484 / 0.488 / 0.347 |
| b2_a2 | b2_a1 + a stand-off poke (a fifth rule) | 0.413 | - |
| b3_a2 | b3_a1 with the pot at 99 % / 2.4 m | 0.495 | - |

  - **Three bundles clear every number:** b3_a1, b1_a0 and b1_a1. Each is the wake-up punish / guard + the Reishi pot + the kite, three
    rules. The best is b3_a1 (held-out 0.489, live 0.478, stand-in 0.406).
  - What failed again: every change to his first free frame at the bait (b0_a1, b0_a2), a stand-off poke, and a fourth rule of any kind.
  - The kite is what lifted the stand-in: about +0.14 on dev against b0_a2.
  - **The dream step** (three worlds): the incumbent replays at 0.3440 (auc 0.3625, penalty 0.3702). The three template rewrites (beta
    0.3 / 0.9 / 0.75) tie it. `v9_mid` was promoted on the tie rule.
- **The split test** (`hksplit/`, the user's rule: one job per arm; the bundle is never shipped as one arm).
  - `split.py` turns b3_a1 into one `hisagi-hk-style` whose three rules each act only under their own strategy key (`:hk-wake`,
    `:hk-pot`, `:hk-kite`). Every rule's tracking runs on every call, so the state carries across switches between the split arms.
  - Three one-job arms are style + key: wake, pot, kite.
  - **Fidelity:** the style with all three keys on plays the bundle seed for seed: 400 of 400 identical against the live KH (601-800),
    0.4575 = 0.4575. This configuration is research-only and never in a table. **Invalid (step 11):** both runs played round 3's b1_a2
    from a stale build, so they matched themselves; step 11's check is the valid one.
  - **The bundle's reference** (played whole, 601-800): 0.4575 against the live KH, 0.405 against the stand-in. **Invalid (step 11):**
    these are b1_a2's numbers; b3_a1 played whole gives 0.445 and 0.4225 (`ev/s11b-*`).
  - **Diagnostic, not a candidate:** HK's table + the three arms, pinned by distance band (close → wake, mid → kite, far → pot, G1 bonus
    10 in every form).
    - Against the live KH 0.48 (b / c 104 / 95 against the bundle, z 0.64; against the true bundle, step 11: 104 / 90, z 1.01): the split
      keeps the gain there.
    - Against the stand-in 0.2975 (70 / 113, z -3.18; against the true bundle, step 11: 65 / 115, z -3.73): **it loses there**. The pinned table holds the wake arm 0.66-0.89 of the time and the
      kite only 0.06-0.30, while the bundle runs all three rules together.
  - **The rule's candidates:** HK (`hk8-t0` = `:qhs-ken` + the three arms, proved = the live lookup, 0.085 = 0.085, 8 of 8 chunks) and KH
    (the live `:qks5-hisagi`) refit together.
    - Two iterations, step 3's rule with the step 6 amendment. The no-refit starts equal the old tables, so the iterates are the
      candidates.
    - Selection (801-1000): KH_1 0.743, KH_2 0.657; HK_1 0.108, HK_2 0.258 (0.312, 0.255, 0.207 against the stand-in).
    - Held-out (601-800, 400 matches a cell):

| 2×2, Hisagi's share | KH_old (`:qks5-hisagi`) | KH_new (KH_1) |
|---|---|---|
| HK_old (`:qhs-ken`) | 0.085 | 0.298 |
| HK_new (HK_2, with the split arms) | **0.318** | 0.24 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the stand-in | verdict |
|---|---|---|---|---|
| HK | 117 / 24, 7.83 | 64 / 87, -1.87 | 7 / 296, -16.6 (0.178 vs 0.90) | keep |
| KH | 25 / 117, -7.72 | 85 / 55, 2.54 | (none) | keep |

    - HK_2 holds Kenpachi's KI code 0.45 and press 0.27 of the time against the live KH, and the split arms only 0.19 (wake 0.13, pot
      0.06, kite 0.01). Against the stand-in it holds Kenpachi's KI code 0.92 and collapses (0.16 on 601-700).
- **The split does not keep the gain.**
  - Switched by distance, the arms keep the live-KH gain (0.48) but lose the stand-in (0.30 against the bundle's 0.405; the true bundle's
    0.4225, step 11).
  - Refit, they win against the live KH (0.318 against 0.085) but collapse against the stand-in.
  - The bundle's gain needs all three rules running at once, which a table that holds one arm at a time cannot give.
- **Nothing ships.** The scaffold and its host check came out again, and HK stays `:qhs-ken`. No game code changed in this step. Host tests,
  pkgcheck, the build, the smoke and G2 were re-run on the unchanged sources.
- **For the user:**
  - b3_a1 as one arm (wake-up punish / guard + Reishi pot + kite, held-out 0.489 / live 0.478 / stand-in 0.406) is an exception to the
    one-job rule, and only the user can grant it.
  - Or a split that runs the rules together: a table key that turns several one-job rules on at once, so each stays its own unit. That
    would be a new runtime feature.
- **Decisions on round 5, step 9 (the user, 2026-11-10):**
  - Asked 「檜佐木對劍八（HK 0.085）接下來怎麼做？」 with three options: (1) a runtime feature, a table key that turns several one-job rules
    on together, each rule still its own unit; (2) ship b3_a1 whole as an exception; (3) stop. The user: 「新增一鍵開多條規則 (Recommended)」.
  - So an arm may name several one-job rule units that are on together. The rules stay separate units in the library (§10, 「高內聚、低耦合」),
    and the arm is only a list of units. HK and KH refit simultaneously with the new arms under the swap rule (step 3, step 6 amendment).

**Round 5, step 10: several rules on in one arm, and the refit (2026-11-10).** Workspace `fq/switch/hkmulti/` (`start.sh`, `run.sh`).
- **The design** (§10 "Several rules on at once"):
  - `duel/lisp/cpu-hk-hisagi.lisp` is back in the game for good: `hksplit/split.py` applied to round 3's b3_a1. `hisagi-hk-style` holds the
    three rules, and each acts only under its own key (`:hk-wake`, `:hk-pot`, `:hk-kite`).
  - strategy.lisp gains the style unit `:st-hisagi-hk`, one data unit per rule (`:d-hk-wake`, `:d-hk-pot`, `:d-hk-kite`, each
    `:base (key 1.0)`) and four arm units: `:a-hk-wake`, `:a-hk-pot`, `:a-hk-kite`, and `:a-hk-all` = the style + all three rule units.
  - The arm composition already appends the data units' `:base` lists, so **no new arm form was needed**: an arm naming several rule units
    turns them on together. No table names the new units, so every shipped pairing plays as before.
  - One runtime fix: the Q selector's judgement counter (`brain-sw-won`) had 8 slots, and the first 9-arm table indexed past it (a sim
    fatal). It is sized from the table now (at least 8).
  - Host test: `:a-hk-all` expands to exactly `hksplit/allon.arms`' plist; each one-job arm carries only its key; `strat-out` reads exactly
    the named rules under each arm, and none without a strategy.
- **Fidelity on this build** (live KH, seeds 601-700): the `:a-hk-all` arm played whole and b3_a1 played whole (its file swapped in,
  rebuilt) give the same winner on 200 of 200 seeds, with equal judgement counts (82647; `ev/s10a-kh-601`, `ev/s10b-kh-601`). Their logs
  (every judgement's cues, arm and health, every match's end and result: 84447 lines in 8 chunks) are identical but for the table's name.
  - **Uncertain:** neither reproduces step 9's records of the same runs (`ev/hsa-*`, `ev/hsb-*`: 85030 judgements; the same winner on 287
    of 400 seeds against the live KH, 228 of 400 against the stand-in).
  - The committed b3_a1 on the HEAD sources without this step's changes gives this build's 82647 too (`ev/s10c-kh-601`), and so does neither
    b3_a0. The old tables reproduce step 9 exactly (`s10h-*-o-vs-*o` = `s9h-*`, 400 of 400 each for HK vs KH, KH vs HK, HK vs the stand-in).
  - So step 9's bundle and split runs are not reproduced from the committed b3_a1; the cause is unknown. Step 9's fidelity (400 of 400),
    its pinned diagnostic (0.2975 against the stand-in) and its HK_2 (0.318) therefore ran on code this step could not verify; step 10's
    refit is the first on the verified split. **Resolved in step 11:** only `hsa-*` / `hsb-*` ran stale code (round 3's b1_a2); step 9's
    pinned diagnostic and its refit ran the split and reproduce exactly.
  - On this build the all-on arm scores 0.445 against the live KH (step 9: 0.4575) and 0.4225 against the stand-in (0.405), 601-800
    (`ev/s10a-*`).
- **The arms** (`hk9.arms`): HK's five + the three one-job arms + the all-on arm (9).
  - The pairs were left out: the log's run exploration spreads over every arm, and step 9 found the gain needs all three rules at once.
  - `hk9-t0` (`:qhs-ken` + the four, each 1 below every row) = the live HK lookup: 8 of 8 chunks, 0.085 = 0.085 (`identity-t0-600.jsonl`).
    It is the no-refit start with the new arms, so it equals the old table and the candidates are the iterates.
- **The refit** (`run.sh` = hksplit's procedure: two iterations, gamma 0.98, logs 2 salts x seeds 1-599 x both seats).
  - Selection (801-1000, `select.json`):
    - KH_1 0.734 (0.693 / 0.775 against HK_old / HK_1); KH_2 0.87 (0.787 / 0.953). The pick is KH_2.
    - HK_1 0.219 (0.128 / 0.223 / 0.307 against KH_old / KH_1 / the stand-in); HK_2 0.486 (0.46 / 0.522 / 0.477). The pick is HK_2.
  - HK_1's fit put the all-on arm first on 0.44 of its own data's judgements, HK_2's on 0.105 (`hk-t1.json`, `hk-t2.json`).
  - Held-out (601-800, 400 matches a cell, `heldout.json`):

| 2×2, Hisagi's share | KH_old (`:qks5-hisagi`) | KH_new (KH_2) |
|---|---|---|
| HK_old (`:qhs-ken`) | 0.085 | 0.1625 |
| HK_new (HK_2, with the rule arms) | **0.5175** | 0.4825 |

| New vs old (b / c, z) | against the old opponent | against the new opponent | against the stand-in | verdict |
|---|---|---|---|---|
| HK | 190 / 17, 12.02 | 166 / 38, 8.96 | 18 / 193, -12.05 (0.4625 vs 0.90) | keep |
| KH | 26 / 57, -3.4 | 108 / 95, 0.91 | (none) | keep |

  - HK_2 against the live KH holds Kenpachi's KI code 0.46-0.48, the kite data arm 0.21, the Reishi pot 0.10-0.12, the wake-up rule
    0.08-0.09, the kite rule 0.02-0.03 and the all-on arm 0.02-0.03.
  - Against the stand-in it holds Kenpachi's KI code 0.81-0.82 and the all-on arm 0.006. HK_old there holds the press arm 0.81-0.85 and wins
    0.90 (`ev/s10h-*`).
- **Nothing swaps.**
  - HK_2 beats both KH tables by far (0.5175 against the live KH where HK had 0.085), but loses the stand-in (0.4625 against the old
    table's 0.90). The stand-in clause decides, as in step 9.
  - KH_2 loses to the old HK (z -3.4).
  - Ties keep the old tables: HK stays `:qhs-ken` and KH `:qks5-hisagi`, and the 3x3 is unchanged.
- **What ships:** the feature, off by default. That is `cpu-hk-hisagi.lisp`, the three rule units and four arms, and the counter sized from
  the table. No table names them.
  - Host tests 10149 ALL PASS, pkgcheck (only `DUEL::APP`), the build, the smoke, and G2 `--cvc` native and browser identical (II 32, IK 34,
    KK 33).
- **Decisions on round 5, step 10 (the user, 2026-11-10):**
  - The main session offered three options: (1) list the stand-in clause as an exception for HK and swap in HK_2; (2) keep the rule and
    close; (3) first find out why step 9 does not reproduce. It recommended 3, then 1 or 2. The user: 「按你說的繼續」.

**Round 5, step 11: why step 9 did not reproduce (2026-11-10).** Measures `fq/switch/ev/s11*` (`s11-repro.json` holds the line-by-line
checks).
- **The cause: a stale native build.**
  - `fq/switch/sw.py` ran `build/simgate/duel.fas` as it was and never rebuilt it. `fq.py` and `online.py` did the same. `tools/strategy-switch.py`
    (`eval.py`, `identity.py`) does rebuild.
  - In the coordinator's checkout, the last build before the split test came from round 3's last held-out run: b1_a2 (`heldout.sh` ended
    11:50:11). `bundle.sh` (11:51) copied b3_a1 in and measured without a build, and so did `start.sh`'s fidelity runs (11:52).
  - So `hsb-*` (the bundle) and `hsa-*` (the split, all keys on) both played **b1_a2**. The fidelity check compared one stale build with
    itself.
  - The next build started at 11:53:33 and finished at 11:56:08. Its source (`build/simgate/simgate-all.lisp`, still in that checkout) holds
    the split file, the same as main's but for the header comment. Every later step-9 run used it: the pinned table from 11:57, the refit
    logs from 11:58, the selection, the held-out.
- **The evidence.** Every run below is a fresh build of main (a8df70cf) with the named file in place.
  - b1_a2 played whole gives every `hsb-*` record (kh / fz, 601 / 701) and every `hsa-kh-*` record exactly: the same judgement counts
    (85030 on kh-601) and the same winners, 200 of 200 a block. The raw logs (every judgement, every match end) are identical line for line
    but for the table's name (`ev/s11x-b1a2-*`).
  - Rerun on main's split file, all 34 of step 9's post-build runs are identical line for line in their raw logs: `hsq-*` (4), the
    selection `s9s-*` (10) and the held-out `s9h-*` (20).
  - Hypotheses 2 (other source differences) and 3 (a determinism leak from load order) are ruled out by these exact reproductions; no
    MANIFEST move was needed.
- **Round 3's keep-rule numbers stand.** `heldout.sh` on main reproduces b3_a1's, b1_a0's and b1_a1's `heldout.json` exactly, every member
  (b3_a1: 0.4889 / live 0.4776 / stand-in 0.4059; keep true). Rounds 1-3 scored through `eval.py`, which rebuilds and caches by the build's
  hash, so they were never exposed to this bug.

| Step 9 number | Status | Value |
|---|---|---|
| The bundle's reference, 601-800 (`hsb-*`): 0.4575 against the live KH, 0.405 against the stand-in | **invalid** (b1_a2) | b3_a1: **0.445** / **0.4225** (`ev/s11b-*`) |
| Fidelity, the split with all keys on = the bundle, 400 of 400 (`hsa-*`) | **invalid** (both b1_a2) | valid now: step 10's all-on arm (`s10a-*`) = b3_a1 whole (`s11b-*`), 400 of 400 against the live KH and 400 of 400 against the stand-in, equal judgement counts in every block |
| Pinned diagnostic: 0.48 against the live KH, 0.2975 against the stand-in (`hsq-*`) | valid (reproduced) | |
| Pinned vs the bundle: b / c 104 / 95, z 0.64; 70 / 113, z -3.18 | **invalid** (paired with b1_a2) | against b3_a1: **104 / 90, z 1.01**; **65 / 115, z -3.73** |
| The refit: selection, the 2×2 (HK_2 0.318 against the live KH, 0.24 against KH_1), the verdicts, HK_2 0.178 against the stand-in | valid (reproduced) | |
| hkfn round 3: b3_a1 0.489 / 0.478 / 0.406, b1_a0, b1_a1 | valid (reproduced) | |

  - Step 9's conclusions hold on the corrected numbers. Switched by distance, the split keeps the live-KH gain (0.48 against 0.445) and loses
    the stand-in (0.2975 against 0.4225, z -3.73). Refit, HK_2 wins against the live KH and collapses against the stand-in.
  - Step 10's "Uncertain" bullet is resolved, and its numbers stand: its all-on runs match a fresh build of b3_a1.
- **The fix (research scripts only).** `sw.py` (`play`), `fq.py` (`log`) and `online.py` call `simgate.build()` before any sim now. It is a
  no-op unless a source is newer than the build. It checks mtimes only, so a file copied in with `cp -p` still slips past.
  - Two caches stay as they were. sw.py reuses a tag's logs whatever build made them, so use a new tag per build. strategy-switch.py keys
    its cache on the build's hash, so it was safe.
- **Blast radius.** Among the committed scripts, only `hksplit/bundle.sh` and `hksplit/start.sh` measure with sw.py after a file change
  and before any build. In `start.sh`, every sw.py measure (`hsa`, then `hsq`) precedes its only build (`identity.py`, last). `hsq` ran
  clean only because an unscripted build ran between the script's two runs (11:53:33, cause not shown).
  - khstyle, khevent and hkmulti's `start.sh` run no sw.py measure; `khjoint/extend.py` only writes tables. Manual runs are not
    auditable.
- No game code changed. `duel/lisp/cpu-hk-hisagi.lisp` was swapped only during the runs and restored, so no G2 was needed.
- **For the user:** the step-10 question stands unchanged, on verified numbers. HK_2 beats both KH tables (0.5175 against the live KH) but
  loses the stand-in (0.4625 against the old table's 0.90). The choice is still option 1 (list the stand-in clause as an exception and swap
  in HK_2) or option 2 (keep the rule and close).
- **Decisions on round 5, step 11 (the user, 2026-11-10):** asked how to handle HK now that step 9's gap is explained (HK_2 0.085 → 0.5175
  against the live KH, 0.90 → 0.4625 against the stand-in; options: keep the rule and do not swap; list the stand-in clause as an exception
  for HK and swap in HK_2; one more refit with the stand-in's matches in the fit data), the user chose 「維持規則，不換表 (Recommended)」.
  HK keeps `:qhs-ken` (0.085), KH keeps `:qks5-hisagi` (0.915); the swap rule stands with no exception. The multi-rule arms
  (`:a-hk-all` and the three one-job arms) stay in the library, named by no table. The Hisagi vs Kenpachi line of round 5 is closed.

## 9. Strategies may carry code (2026-11-08)

Asked how the format grows to reach the style CPUs' HARD play (tactic modules in the core CPU switched by data / strategies that carry
code / the style CPUs as opaque strategies). **The user: 「策略可以包含程式」.**
- A strategy file may name `:fn`, a function (e b f kit s d) -> T when it decided, run first on every step the CPU is free to press
  (`core-brain-step`, before the action layer's MCTS, which fills what it leaves: §7 of DUEL_AI_MCTS found that order strongest), beside its
  data (`:base` / `:rules`). The function lives in the build: a search cell writes Lisp in its own git worktree and builds its own native
  sim (~2.5 min a cell; the KI search's scripts, docs/research/ki-ai-drsi/, did the same); the library's admitted functions ship in the game.
- The KI style CPUs are the first two such strategies: `seeds/s5-ki-ken.lisp` (`:fn ken-ki-style`), `seeds/s6-ki-ichigo.lisp`
  (`:fn ichigo-ki-style`). IK HARD, 20 seeds (Ichigo : Kenpachi): as shipped (the styles after the MCTS, HARD's margin gate) 3 : 17; his as a
  strategy first 7 : 13; hers 4 : 16; both 7 : 13 (within the noise, ±4).
- No strategy: G2 identical.

## 10. The library's format: units defined once (2026-11-09)

The user (on §8.19 round 5, step 1): 「不設上限，但將相似的策略合併，或將策略解耦成更小的單位，確保策略庫的『高內聚、低耦合』」. There is no cap. Instead,
strategies are composed from small units defined once, and `*strat-library*` is expanded from them at load (strategy.lisp `strat-expand`).
The runtime sees exactly the plists it saw before, so nothing downstream changed.

- **The units:**

| Unit | Holds | Examples |
|---|---|---|
| style (`*strat-styles*`) | a style function and its own keys; `:apply` = whose style it is | `:st-ken-ki`, `:st-ichigo-ki`, `:st-hisagi-merged` (+ `:ken-ranged t`), `:st-hisagi-range`, `:st-hisagi-hk` (three rules under keys), `:st-generic` (no function) |
| data (`*strat-data*`) | outputs (`:base`), `:rules`, other keys (`:dswitch-map`); no code | `:d-brawler`, `:d-kite`, `:d-zoner`, `:d-dswitch`, `:d-no-far-ns`, and the extras `:d-brawler-prior`, `:d-zoner-extra`, `:d-red-kikon`; one rule each: `:d-hk-wake`, `:d-hk-pot`, `:d-hk-kite` |
| arm (`*strat-units*`) | a named style + data units in order: what a Q table chooses among | `:a-ken-ki`, `:a-hisagi-pressd` = merged + `:d-dswitch` + `:d-brawler`, `:a-ichigo-kite`, `:a-hk-all` = `:st-hisagi-hk` + its three rule units |
| rule base (`*strat-rule-bases*`) | a Q table's antecedents in order (+ `:groups`) | `:rb-crisp48` (fq.py's 48 cells), `:rb-switch89` (§8.19's 89 in 5 groups), `:rb-sp` (§11.3's 42 in 5 groups, SP cues) |

- **A Q table** holds only `:arms` (arm ids; NIL = no strategy, the shipped CPU with its matchup style CPU), `:rule-base`, `:q` (a list of q
  per arm, one per antecedent) and its keys (`:xfeats :period :gamma :scale :keep-state ...`). A composite's `:switch` subs and `:else`
  may name arm ids.
- **The event layer** (§8.19 round 5, step 6; the user: 「做成倒地時觸發的事件層」): a Q table may name `:event-arms ((:knockdown ARM))`, where ARM
  is an arm id or plist, expanded like `:arms`. It is off when the key is absent, which holds for every table before step 6.
  - While the opponent is perceived launched, down or waking up, and for the brain's perception delay + `*strat-event-grace*` (4) frames
    after, ARM plays the step whatever arm the table holds. Then the table's pick plays again (strategy.lisp `strat-event-arm`, core-ai.lisp
    `strat-event-step`).
  - ARM's style state lives in the brain slot `ev-style`, swapped into `style` only while it plays. So the table's style state is untouched,
    and a sim snapshot saves both.
  - The table keeps judging underneath, and its online learner keeps running. A judgement made during a takeover credits the arm the table
    holds. The layer is part of every arm's world: the table learns each arm's value with the layer on, the same world its offline refit
    sees. This is the simpler choice, and it is correct for a layer that fires for every arm alike.
  - `tools/simgate/strat-run.lisp` prints `event P<n> <id> fires F steps S ticks T out <steps per arm outside the layer>` once a match.
- **A plain strategy** may name `:style` and `:data`. For example s3-zoner is `:d-zoner` + `:d-zoner-extra`: its zoning plus its red Kikon and
  priors, while the tables' zoner arms take only `:d-zoner`. s7-kite is `:d-kite` + `:d-red-kikon`. h1-range is `:st-hisagi-range` +
  `:d-dswitch` + `:d-no-far-ns`.
- **Composition order:** the style's keys, the entry's own keys, the data's keys; `:base` = the data units' lists then its own; `:rules`
  likewise. That order is a strategy's meaning: `strat-value` averages the rules in order, and `getf` takes a `:base` key's first occurrence.
- **Inline plists still work** everywhere. The research files that `strat-run.lisp` plays raw are inline. A new table may name arms
  either way.
- **Granularity.** An arm is a style function plus data units, because both vary independently:
  - the same three data units (pressure, kite, zoning) ride on all three characters' style functions;
  - the DRIVE switch is a data unit added to any Hisagi arm.
  - Smaller than that (a data unit per output key) would split what tunes one job together, so the units stop at one job each.
- **Several rules on at once** (§8.19 round 5, step 10; the user, 2026-11-10: 「新增一鍵開多條規則」). A style function may hold several one-job
  rules, each acting only under its own strategy key (the rule's tracking runs on every call, so turning a rule on mid-match finds its state
  current). Each rule is then a data unit of one key, and an arm turns on every rule whose unit it names:
  - `:st-hisagi-hk` (`hisagi-hk-style`, cpu-hk-hisagi.lisp) with `:d-hk-wake` (`:base (:hk-wake 1.0)`), `:d-hk-pot`, `:d-hk-kite`;
  - the one-job arms `:a-hk-wake`, `:a-hk-pot`, `:a-hk-kite`, and `:a-hk-all` = the style + all three units (round 3's b3_a1).
  - The arm composition above already does this (the data units' `:base` lists are appended in order), so there is no new arm form and
    `strat-expand` is unchanged. A rule with no unit named reads NIL (`strat-out`), so no strategy, or any other arm, plays none of them.
  - The one runtime change: a Q selector's judgement counter (`brain-sw-won`, core-ai.lisp `strat-switch-step`) had 8 slots, and a table
    with 9 arms indexed past it. It now has one slot per arm, at least 8, so every table of 8 arms or fewer is untouched.
  - Host test: `:a-hk-all` expands to the plist step 9's fidelity run played, each one-job arm carries only its own key, and with each arm
    active `strat-out` reads exactly the rules it names.
- **Merged duplicates.** The 18 tables carried inline copies of 16 distinct arms, written under 30 different ids. They are 15 arm units now,
  plus NIL. For example, Kenpachi's KI style code appeared as `:c1-ken`, `:kh-whole`, `:kk-ki-bo`, `:ki-ken`, `:ht1-ki`, `:ht3-ki`, `:kp1-ken`,
  `:ip5-kenki` and `:it1-kenki`; it is `:a-ken-ki` now.
  - An arm's `:id`, `:apply` and `:base`'s `:p` are not behaviour inside a table: nothing reads a table arm's `:id` or `:apply`, and
    `strat-prior` reads `:p` only on library entries, for the strategy layer.
  - Merged arms lost their per-table `:apply` (the general / targeted label of round 2). That label now lives in each table's comment and in
    the research arms files.
- **No cap:** `*strat-picks*` is sized from the library at load (two slots an entry), and cpu-mcts indexes it by the library's length.
  - The online page (`soulduel.fq.<me>.<vs>`) is keyed by roster indices, not library positions.
  - Its checksum (`fq-checksum`) reads only a table's q values. The refactor changes neither, so **no player's saved copy resets**: every
    table's checksum is unchanged, e.g. `:q1-ichigo-ken` 346947, as its page's second integer since §8.14.
- **Proofs** (`docs/research/strategy-drsi/fq/switch/library/`):
  - **Structural** (`check.lisp`): the inline library of the commit before (64b4531f) and the unit library, expanded, are the same entry by
    entry. 27 entries, 18 tables, 0 problems: every table's `:rules` EQUAL (every antecedent and q), its keys and checksum equal, each arm
    the same keys and EQUAL values but `:id` / `:apply` / `:p`; every plain strategy the same plist with EQUAL values, `:p` included.
  - **Negative control:** one kite base value changed gives 10 problems, the tables and s7-kite using it.
  - **Play** (`proofs.sh`): each of the nine live tables' research file run raw = the live lookup, 8 of 8 chunks, at the shares of their last
    proofs: HI 0.87, HK 0.76, HH 0.59, KI 0.885, KH 0.625, KK 0.52, IK 0.6, IH 0.405, II 0.025 (seeds 601-700, each against the opponent of
    its last proof). G2 `--cvc` identical.
- Host tests: the old ≤ 32 check is replaced by checks that unit ids are unique, that no two arm units play the same, that every table's arms
  resolve once each with a q per arm and rule (and its groups add up), and that `*strat-picks*` is sized from the library.
- The file shrinks from 180 KB to about 109 KB.

## 11. Re-collecting the strategies for the SP system, both sides co-evolved, into fuzzy Q tables (requested 2026-11-14)

The user, 2026-11-14: 「M5 完成後幫我以目前的新系統重新收集策略，一樣基於 /anthropic-skills:dream-rsi 並同時考量對戰組合中 雙方角色的互動策略要如何設計與演化。最終目標是要將這些策略建構成 fuzzy Q table。」

- **When**: after refactor round 4's M5 (REFACTOR_2026-11 §11.4 step 15).
- **What changes from §8**: §8's library, counter searches and Q tables (§8.12-§8.19) were found before the SP system (DUEL_SP, S0-S9 built 2026-11-13: costs, refusals at 0, refunds, gains, the steal). They are re-collected on the current rules for the three fighters that play (Kenpachi, Ichigo, Hisagi) and their pairings.
- **Both sides together**: a pairing's strategies are designed and evolved as an interaction, each side's library searched against the other's current one, not against a fixed opponent.
- **The end product**: a fuzzy Q table per pairing and side over the collected strategies (the §8.12 / §8.14 selector and the online learner, `fq-online.lisp`).
- The plan, the evaluator, the per-round budget and the parallelism are settled with the user before round 1 (the dream-rsi skill's rule) and recorded here.

### 11.1 The plan and the user's answers (2026-11-14)

The plan (Fable, unanchored; full text `docs/research/strategy-drsi/sp/PLAN.md`):
- **Survives from §8**: the machinery (the format and runtime in `strategy.lisp`, `strategy-glue.lisp`, `fq-online.lisp`, the switch / matrix / descriptor tools, the fit script `sw.py`). **Redone**: every q value, `*strat-lookup*`, `*strat-payoff*`, every whole-arm measurement.
- **Probe on main (post-SP, HARD, seeds 601-620)**: with both seats on the live lookup, 8 of 9 pairings median 300.0 s (time-outs), II 20 draws of 20; with no strategy the matches end (medians 168-272 s); the old whole arms beat the plain CPU by the clock. `tools/strategy-switch.py` counts a time-out lead as a win: the new score counts K.O.s only (a time-out scores 0). The cues have no flash-step gauge; `:gauge` / `:hold-awaken` mean nothing under SP.
- **Co-evolution (PSRO-lite)**: one population per side and pairing, seeded with `none` (the anchor), the generic arm and the old arms that still K.O.; a payoff matrix and its regret-matching mix; both sides searched in the same round against the other's frozen population (opponent weights 1/3 anchor, 1/3 the equilibrium mix, 1/3 the rest); §4's admission test; no member deleted; a pairing stops when a round admits nothing. Mirrors: one population on both seats, searched only where the cross-pairing arms give no K.O.-ing equilibrium.
- **Dream-RSI**: a workspace per (pairing, side) under `docs/research/strategy-drsi/sp/`; a cell is one agent attempt writing or mutating one arm (data, or a `:fn` with its own native build); grid 4 branches x 3 attempts, W = 4; one shared policy over every closed round; the scorer `sp/eval.py` (khfn's `eval.py` generalised): the mean over the opponent groups of (K.O. wins + 1) / (matches + 2). Seed blocks: 200 the coordinator's rescore, 300 the cells' dev runs, 400 held-out for admission.
- **Fuzzy Q tables**: a new rule base `:rb-sp` (lead, his state, form, distance band, `:prev`, plus my / his flash-step cells 0 / 1 / 2-3, a burst running, an exchange open after a cancel; `:gauge` dropped); the admitted arms as actions; fitted with `sw.py` against the opponent's population mix and his table iterates, both sides together; a time-out's terminal reward -1 for both; `:margin` hysteresis on; `fq-online.lisp` unchanged (new checksums reset the saved copies).
- **Done**: on held-out seeds 601-800 each new table beats `none` and the old table (paired z >= 1.96) and does not lose to the opponent's anchor; K.O. rate >= 90 % (reported); style descriptors inside bands set before round 1; determinism (raw file = lookup, snaptest / fulltest, host tests, the browser `duel fq load` smoke).

The user's answers (AskUserQuestion, 2026-11-14):
- Budget: 「Fable's plan (Recommended)」: the three cross pairings KI, KH, IH, at most about 144 cell agents, mirrors at most 36 more where needed, 2 rounds a pairing, W = 4, the first pairing checked before the rest; native sim about 20-30 CPU-hours (an estimate).
- Difficulty: 「NORMAL too」: the strategy selection also plays at NORMAL, scaled by difficulty as every CPU chance (EASY <= NORMAL <= HARD). G2 runs NORMAL, so `tests/style-cvc-ref.txt` is regenerated when the NORMAL lookup lands (a header note and "Before:"), and every quote of its lines updated. How NORMAL scales a table (a softer selection, or a share of judgements on the plain CPU) is decided in the fit step and recorded here.
- The current HARD lookup (stalls CPU vs CPU): 「Keep it for now」: it stays until the new tables replace it.

### 11.2 Step 2: K.O.-only scoring and the baseline (2026-11-14)

- **The gate row** (`gate.lisp`) gains a last field `ko 1|0`: 1 = the match ended before the bell (a K.O., or a lethal trade's draw), 0 = the time-out bell (a bind drained to 0 at the bell included). The existing fields are byte-identical; `simgate.py`'s summary read `blow` as the last field and now finds it by name. G2 identical (the reference holds no gate row).
- **`--ko-only`** in `strategy-switch.py`, `strategy-eval.py`, `strategy-matrix.py` (helpers `row_win` / `row_ko` in `simlib.py`): a win counts only if it was a K.O.; a time-out lead and a draw score 0. Off by default, so every older score is unchanged; a row without the field under the flag exits. Still counting a time-out lead: `matchup-eval.py`, `aieval.py`, and the terminal reward of `fq.py` / `sw.py` (step 8 changes `sw.py` to §4's -1 for both).
- **Baseline** (HARD, seeds 601-800, 200 matches an ordered pairing, score (K.O. wins + 1) / 202; `docs/research/strategy-drsi/sp/baseline/`):
  - **No strategy** (`none` on both seats): K.O. rate 88.5-100 % but the Hisagi mirror (65.5 %, 69 time-outs); medians 165.6-260.8 s. The plain CPUs form a cycle, both seats summed: Ichigo beats Kenpachi 0.72 : 0.19, Kenpachi beats Hisagi 0.85 : 0.15, Hisagi beats Ichigo 0.74 : 0.19.
  - **The shipped HARD lookup** on both seats: KK, KH, HK, IH, HI, HH 200 time-outs of 200, II 198 (188 draws); only KI / IK reach K.O.s (102 and 116 of 200, about half still to the bell), and there the tables turn the cycle round (Kenpachi 0.36, Ichigo 0.19). Under the old count Kenpachi's `:qks5-hisagi` would score 0.955 (it leads 382 of 400 at the bell); K.O.-only it scores 0.002.
- **Step 4** (empty the stalling lookup entries) is not done: the user kept the lookup until the new tables replace it (§11.1).

### 11.3 Step 3: the SP cues and the rule base `:rb-sp`, off by default (2026-11-14)

PLAN §4 / §7 step 3. A new rule base for the step 8 tables; no table names it yet, so nothing plays it.

- **The cues** (strategy.lisp `strat-sp-cues`: pure, host-tested; strategy-glue.lisp `strat-xfeats` appends them, so they are read only at
  a Q selector's judgements, never on the per-step path):

| Cue | Value | Sets in `:rb-sp` |
|---|---|---|
| `:mcell` / `:ocell` | my / his full flash-step cells: floor(fs / `*fs-cell*`), 0-3 (100.0 = one cell, where regen stops) | `:no` 0, `:yes` 1, `:p2up` 2-3 (crisp on integers: no gap between bands) |
| `:mburst` / `:oburst` | my / his burst running (`gauges-burst` non-NIL), 0 / 1: both kept, because mine means my SP attacks are free and his is a threat | `:no` / `:yes` |
| `:xch` | an exchange open after a cancel (DUEL_SP §6: `sp-exchange-open-p` over both fighters' `fighter-xch`), 0 / 1 | `:no` / `:yes` |

- **How the CPU perceives them:** it reads them the way the existing cues read the opponent's gauges. `:lead`, `:ored`, `:or` and `:oawk` read his
  gauges live, because the HUD shows them, and only his motion state (`:ost`) comes through the delayed SNAP ring (cpu-perceive.lisp).
  - The HUD also shows his cells and his burst (the three cells and the 爆 dial, DUEL_SP §7), so `:ocell` and `:oburst` read his gauges live too.
  - The exchange is shared state that a visible clash opens; it is read from both fighters' slots.
  - No random draw. No new state: every slot read is already in the sim snapshot, so snaptest and fulltest are not needed.
- **`:rb-sp`** (`*strat-rule-bases*`): 42 rules in 5 additive groups `(18 9 9 4 2)`:
  - G0 lead x his state (`:busy` / `:free`) x `:prev` (`:no` / `:yes` / `:p2up`)
  - G1 my form x distance in metres (`:m-close` / `:m-mid` / `:m-far`)
  - G2 my cells x his cells
  - G3 my burst x his burst
  - G4 the exchange
  - Dropped from `:rb-switch89`: `:gauge` (the DRIVE threshold is gone under SP).
  - Also left out, because PLAN §4's kept list does not name them: `:ored`, `:awk` (G0's other two cues there), `:wall`, `:oawk`. Each can
    come back as a small group before the fit if step 8 wants it (2-4 rules each).
- **Opting in:** a table names `:rule-base :rb-sp` and carries `:xfeats t`.
  - The rule base says `:xfeats t`, and `strat-expand` refuses a table on it without the key. Without `:xfeats`, every SP cue would read 0
    and the table would always see "no cells".
  - `strat-expand` takes the groups from the rule base, as for `:rb-switch89`.
  - `fq-checksum` hashes only the rule count and the q values, not the antecedents. A `:rb-sp` table therefore gets its own checksum from its
    42-rule shape and its q, and the saved online copies of the old tables reset only when the lookup names the new tables (PLAN §4).
    `fq-online.lisp` is unchanged.
- **Off by default:** `strat-xfeats` now also returns the five SP cues to every `:xfeats` table. No existing antecedent names them, so every
  firing vector, every pick and every checksum is unchanged.
- **Proofs** (main fe859124 + this step):
  - **Host checks** (tests/duel-rules/strategy.lisp, 3020 -> 3034, ALL PASS):
    - The cell bands at 0 / 99.9 / 100 / 199.9 / 200 / 299.9 / 300 give 0 0 1 1 2 2 3.
    - The burst and exchange cues are correct.
    - `:rb-sp` has 42 antecedents, equal to the sum of its groups, and none reads `:gauge`.
    - On a grid over every cue's points and the distance's ramps, each group's firing adds up to 1, so no band is dead.
    - A hand-written 2-arm test table on `:rb-sp` (not shipped) expands, and its pick switches on `:mcell` alone and on `:xch` alone.
      `strat-judge` returns its arm, its page holds 87 integers, and it is refused without `:xfeats`.
  - **Determinism, shipped HARD lookup on both seats:** all 9 ordered pairings, seeds 601-608 (72 matches, `strategy-switch.py`'s
    `run_job`). The gate rows and the `duel hash` lines (2123) are identical before and after (sim builds 0aa1f9bd -> 481c8065).
  - **G2** `--cvc`: identical. `pkgcheck`: only DUEL::APP.
- **For step 8 (the fit):**
  - `sw.py`'s `rules()` / `GROUPS` hard-code `:rb-switch89`'s 89 rules, and it writes inline `:rules`. It needs a `:rb-sp` mirror: these
    42 antecedents in this order, groups `(18 9 9 4 2)`, with `:xfeats t` kept in the written keys.
  - Its log parser can stay as it is: strat-run.lisp's `fq` line carries the fire vector over the table's own rules, which is all the fit
    reads. That line was left unchanged, because a field inserted before ` fire` would silently break the regex's optional tail. If the
    SP cues' values are wanted in summaries, print them on a separate line.
  - `strat-desc.lisp` names no rule base or cue, so it needs no change.
  - `:xch` will fire rarely at a judgement. A judgement needs me in `:idle` / `:run`, and an exchange closes once both fighters are back in
    neutral (`sp-neutral-p`). So it is 1 only during a clash's bounce slide or while he is still busy.

### 11.4 Before the KI rounds: the no-`:fn` arms, the initial programs, the round's build (2026-11-14)

- **The no-`:fn` arms' 0:80 in KI is not a bug.** In KI, `none` (no strategy) plays the matchup style CPUs `ken-ki-style` / `ichigo-ki-style`: `core-brain-step` runs `cai-style-fn` only when no strategy is active, and `*cai-styles*` registers exactly those two (KI only). An arm without `:fn` (`a-generic`, `a-zoner`, `s1-brawler`, `s7-kite`, `:s0-generic`) turns the style CPU off and plays the plain generic CPU + MCTS, which the KI styles beat almost every time. Checked where no style exists: Kenpachi on `a-generic` against Hisagi's `none` (both plain) K.O.s 33 : 7 over 40 matches (seeds 301-320, both seats), like the baseline's KH 172 : 28 (§11.2). So in KH and IH `none` is the plain CPU and the no-`:fn` arms are live search material; in KI they are a floor.
- **Initial programs** (the lead, a deviation from PLAN §3's `(:id :s0-generic)`): each (pairing, side) workspace starts from that side's strongest seed member, since `:s0-generic` is KI's floor. KI: Kenpachi `a-ken-kh-standoff` (eval.py 0.4588 at seed0 300), Ichigo `a-ichigo-press` (0.7492). KH / IH decide theirs from their own screens.
- **A round pins its sim build**: `eval.py` refuses to score when `SP_BUILD` is set and the build hash differs (a source edited under running cells rebuilt `duel.fas`, and the step-3 agent saw the reverse: edits made while a build read the sources, an older build newer than them). Main's Lisp sources stay frozen while a round runs; code cells build in their own worktrees. `strategy-switch.py`'s cache temp names are unique per process and thread (parallel identical jobs).
- **`:rb-sp`'s cue list** (§11.3 left out `:ored`, `:awk`, `:oawk`, `:wall`): decided before step 8's fit from the arms the rounds admit; `:ored` first in line (the victim's red changes what a pointer-2 Kikon takes, R15d).

### 11.5 The KI pilot and its admitted arm (2026-11-14)

- **Pilot**: one Sonnet data cell a side in throw-away workspaces (1 x 1 grid), from the initial programs of §11.4. The mechanics held: eval.py, recording from the lead's own re-score, the cache, the `SP_BUILD` guard.
- **Kenpachi**: `c-ki-k-pilot-b0a0` = `ken-kh-standoff-style` (the stand-off breaker) with `a-ken-press`'s `:base` / `:rules`: 0.7096 (block 300), 0.6617 (block 200) against `a-ken-kh-standoff`'s 0.4588 / 0.4852. Admission (§4): block 400 0.7013 against `a-ken-press` 0.4736, `a-ken-kh-standoff` 0.4686, `none` 0.3334; a best response to every Ichigo column; its matrix row unlike the others' (against `a-ichigo-press` 0.590 against 0.325 / 0.360). The params fingerprint (§3) cannot tell it from `a-ken-press` (only `:fn` differs), so the behaviour filter decided. Added to `pop/ki-K.json`; the KI matrix (block 200) recomputed: Kenpachi's mix pure on it (value 0.59), Ichigo's still pure on `a-ichigo-press` (0.41). The workspaces' baselines: Kenpachi 0.7096, Ichigo 0.6122.
- **Ichigo**: no gain (0.7492 = the baseline); its `:lead` rules changed no match, which led to KNOBS.md: the KI style CPUs read almost no arm keys (`:b-*` inert under a style), hence §11.6.
- **Coordinator**: a subagent cannot spawn agents here, so the main session dispatches the cells itself and records from its own re-score (a deviation from AGENTS.md's Opus coordinator).

### 11.6 Style knobs: the KI / KH style CPUs' tunables as arm keys (2026-11-14)

The KI search writes arms as data, but the style CPUs read almost no arm key (sp/KNOBS.md §0-§3): their play lived in ~155 `*kk-*` / `*kso-*` / `*khf-*` / `*iks-*` specials, so every idea needed a code cell and its own build. Now the 53 decision tunables that matter most are read through one accessor in strategy-glue.lisp:

- `(style-knob b key default)` = `(strat-out (brain-now b) key default)`: the active arm's `:base` value or its firing `:rules`' average (as every other key), else the style's own value. `style-dif` resolves a per-difficulty plist first (`brain-chance`) and the arm's value replaces that; `style-roll` rolls it through `chance-roll` (split out of `brain-roll`: no random draw at 0 or 1). With no strategy, or one that does not name the key, it is the default with no float math (0 B); each knob is read once per decision.
- Keys are the specials' names without stars, a style prefix on each: Kenpachi `:kk-*` 25 (`ken-ki-style`, also under the KH styles), `:kso-stale :kso-lead :khf-bait-p :khf-bait-d` (cpu-kh-ken), Ichigo `:iks-*` 24, five of them the episode mode mix's weights (`iks-mode-pick`). Tables, units, defaults and search ranges: sp/KNOBS.md §6, with the knobs left out (frame timings, engine facts, lists, booleans, bug fixes, second-tier geometry).
- Precedence: a code argument beats the arm (`ken-kh-standoff-style`'s `:safe 0`, `ken-kh-style`'s `:meaty 0`). Only an arm whose `:fn` is the style reaches them; under `none` they are inert.

**Proof, no behaviour change without a key.** Host tests 3160 ALL PASS (+126: `tests/duel-rules/style-knob.lisp` scans the sources for the keys, checks that a `:base` value and a firing rule override each and that their absence returns the default `eq`, that no library unit / table and no sp/arms file names one, and that KNOBS.md lists each). `pkgcheck` only DUEL::APP. Native G2 `--cvc` identical (II 36 / IK 40 / KK 38). `sp/eval.py` at seed0 300, 50 seeds, on the base build (8e3af00e) and this one (f4e19e10): Kenpachi `none` against Ichigo's population (her `none` and `a-ichigo-press`, an `ichigo-ki-style` arm), Ichigo `none` against Kenpachi's (`a-ken-press`, `a-ken-kh-standoff`, the pilot), and the pilot against Ichigo's: the 36 raw outputs (900 matches, 20,889 `duel hash` lines) byte-identical as a multiset.

**The keys are live** (the pilot arm plus one key, same seeds; anchor / mix / rest K.O. wins of 100): the pilot 72 / 61 / 83 (score 0.7157); `:kk-reach-margin 0.15` 63 / 61 / 83 (0.6863: the anchor moved; mix and rest stayed byte-identical, 200 matches; at 1.5 every group moved); `:kk-reach-margin 1.5` 25 / 34 / 70 (0.4314, 34 time-outs); `:kk-dodge-p 0` 68 / 60 / 87 (0.7124). Ichigo: `a-ichigo-press` 76 / 39 / 61 (0.585), the same with `:iks-mix-generic 0.5` 70 / 34 / 66 (0.5654).

### 11.7 KI round 1 (2026-11-14)

- **Grid**: per side 4 branches x 3 attempts (W = 4), 24 Sonnet data cells, the default parallel-refine policy, scores recorded from the lead's own re-score (block 300, `SP_BUILD` 29a3fe99). Briefs: the exploration prompt + KNOBS.md. One brief error, fixed mid-round: cells read every branch, and in Kenpachi's second batch all four branches copied one arm (0.8746); from then on a cell reads only its own branch, and the third batch found four different refinements.
- **Kenpachi** (start 0.7096): best `c-ki-k-r1-b2a2` = the stand-off arm with `:kk-step-in-p 0`, `:kk-awaken-p 0`, `:kk-reach-margin 0.35`, `:kk-wave-p 0`, `:kk-lunge-p 1`, `:kso-stale 60`, `:kk-step-max 7`, `:kk-step-p 1`, `:kk-bankai-p 0`, `:kk-reach-p 0.5`: block 300 0.9389, 200 0.9307, 400 0.9274. The read-range gains of two other branches (0.909 / 0.888 at 300) fell back to about 0.875 at 200: noise.
- **Ichigo** (start 0.6122): best `c-ki-i-r1-b3a2` = `a-ichigo-press` with `:iks-mix-ptr3 0.6`, `:iks-mix-space 0.1`, `:iks-wait-max 40`, `:iks-gap-p 1`, `:iks-gap-fs 150`, `:iks-ns-wait 24`, `:iks-getsuga-min 6.5`, `:iks-meaty-p 0`, `:iks-mix-whiff 1.5`: block 300 0.9488, 200 0.9439, 400 0.9323 (`a-ichigo-press` 0.6122 at 400).
- **Admission** (§4, the block-200 matrix with five candidates): Kenpachi's `r1-b2a2` beats every Ichigo arm (against `r1-b3a2` 0.640 : 0.085, 55 of 200 to the bell) and is his whole mix; Ichigo's `r1-b3a2` beats every older Kenpachi arm (0.925-0.990) and is most of hers. Admitted: those two. Not admitted (dominated, no best response to an admitted column): Kenpachi `r1-b0a1`, Ichigo `r1-b0a2`, `r1-b2a2` (kept in `sp/arms/r1/` as records). Mixes after admission: Kenpachi pure `r1-b2a2` (value 0.673), Ichigo `r1-b3a2` 0.878 + `a-ichigo-press` 0.122 (value 0.085).
- **Watch**: the two new arms against each other go to the bell 27.5 % of the time; round 2 scores K.O.s only, so stalling earns nothing, but PLAN §6's K.O.-rate check applies to the final tables.

### 11.8 KI round 2 (2026-11-14)

- **Policy**: `v1_rank_keep` (the dream step after round 1, `sp/policies/`): four roots, then the top three branches by anchor to full depth: 10 cells a side. Scores against the populations after round 1's admissions; the round re-pinned once to `SP_BUILD` f5048d03 when its code cells merged (every older arm's score identical).
- **Kenpachi** (round 1's arm now 0.8119 against Ichigo's new population: 52 of 200 mix matches to the bell): his cells cut the time-outs by trading instead of waiting (`:kk-dodge-p 0`, lower `:kk-brawl-p`), then `c-ki-k-r2-b1a2` = `:kk-ns-safe-p 0.8` + `:other 10` (always Burst / Kikon-cancel) + `:kikon 0.3` (SP mostly tapped): block 300 0.9422, 200 0.9389, 400 0.9175, 500 0.9422. A rule `(((:lead :ahead)) (:kk-ns-safe-p 0))` (b0_a2) scored 0.934 / 0.893 / 0.906 (300 / 200 / 500; the cell used block 400 itself, against the brief, so 500 stood in).
- **Ichigo** (round 1's arm now 0.6155: Kenpachi's new arm beat it 127 : 17 with 56 time-outs): her data cells reached 0.62-0.76 and two of them diagnosed the wall: her pointer-3 shut-gauge lunge whiffs ~100 times a match into his 7 m back Step, without it his meaty J1 loop on her wake-up K.O.s her (half his damage), and nobody fills the awakening gauge. The two **code cells** (Opus, worktrees) both found the game's wake-up roll, which no CPU used: `ichigo-ki-r2b1a1-style` (roll away, hold off over his knockdown: 0.8647) and `ichigo-ki-r2b2a1-style` (a 45° forward roll to his side so his meaty J1 whiffs into her punish, the lunge off once his far back Step is seen, a 10 s stale breaker: 0.929). Both merged into main as additive files (22a69ada). Best: `c-ki-i-r2-b2a2` = r2b2a1-style without the space mode: block 300 0.9472, 200 0.9307, 400 0.9389. The roll angle is a cliff (40° 0.77, 50° 0.72).
- **Admission** (the block-200 matrix with five candidates): Ichigo's `r2-b2a2` beats every Kenpachi arm (against his `r2-b1a2` 0.720 : 0.280) and is her whole mix; Kenpachi's `r2-b1a2` is his best response to every admitted column and his whole mix. Admitted: those two. Not admitted (dominated against the admitted columns): Kenpachi `r2-b0a2` (a best response only to Ichigo's non-admitted `r2-b3a2`), Ichigo `r2-b3a2`, `r2-b1a2` (records in `sp/arms/r2/`). Mixes: both pure, value Kenpachi 0.28, Ichigo 0.72: the pairing flipped from round 1's 0.67 : 0.09.
- **KI's search stops here** (PLAN §5: two rounds a pairing). What the tables get: Kenpachi's arms `none`, `a-ken-press`, `a-ken-kh-standoff`, the pilot, `r1-b2a2`, `r2-b1a2`; Ichigo's `none`, `a-ichigo-press`, `r1-b3a2`, `r2-b2a2`. Each population's latest arm dominates its older ones against the other's latest; the tables' value is choosing by situation (§4 of PLAN), which the fit measures.
- **Process notes for KH / IH**: a cell reads only its own branch; one arm key, first occurrence wins; no polling loops; only block 300 in a cell; code cells pay off where a style CPU's data knobs saturate (a wall found by two data cells is the signal); main's Lisp stays frozen while a round runs, except a deliberate merge that re-pins `SP_BUILD` after proving the older arms identical.

### 11.9 The KI checkpoint: style-state guards (2026-11-14)

- A table switches `:fn` inside a match, so each style function must never be handed another's struct (R15d's FT_LAYER crash class). `ichigo-ki-r2b2a1-style` and `ichigo-ki-style` reused any `brain-style`; they now take theirs only when `ikw-p` / `ikst-p` (the latter accepts the two wrappers' `ir2` / `ikw`, which include `ikst`), as `ir2-p`, `hms-p`, `hrs-p` already did. Proof: six arms x blocks 300 and 200 identical before / after, G2 identical; instrumented, 350 matches never entered r2b2a1 with a foreign struct; `strat-switch-step` already keeps one struct per style (`brain-sw-fn`, `:keep-state` via `brain-sw-keep`), and a Q selector over the three Ichigo styles with forced switches (2694 hand-offs) never mismatched. A foreign struct would have been a checked type error (exit 3), not undefined behaviour. snaptest / fulltest gained `STRAT_P1` / `STRAT_P2` (prelude `sg-strat-step`): r2-b2a2 against Kenpachi r2-b1a2 straight = pollute, FT_LAYER fulltest 644 / 287 checks, 0 differ.
- A misreading corrected: `r2-b2a2`'s 0.9472 → 0.8927 came from the population file (round 2's admission made Kenpachi's `r2-b1a2` the mix), not from the guard; the arm scores 0.9472 exactly on the pre-admission file with either code.

### 11.10 The KI fit probe: switching between whole-game arms does not gain (2026-11-14)

- `sw.py` gained `--rb` (the rule base read from `*strat-rule-bases*`, the one definition; `:rb-switch89` equals the old list) and `--ko` (PLAN §4: a K.O. +1 / -1, a time-out -1 to both, health shaping kept), `--margin`, `--only`, a `gated()` fit, `none` opponents, stdin closed. Identity: the start table (arm 0 everywhere, `:rb-sp`) plays its arm raw bit for bit (800 matches, 16,308 hash lines); a NIL arm plays as `none`. No Lisp changed. Tools and every table: `sp/fit/`.
- **Block 400** (pre-chosen tables, 200 matches a row, K.O.-only): Kenpachi table vs his `r2-b1a2` against Ichigo's mix 0.272 vs 0.297 (z -0.56), against `none` 0.936 vs 0.916 (+0.78); Ichigo table vs her `r2-b2a2` against Kenpachi's mix 0.629 vs 0.703 (z -1.61), against `none` 0.990 vs 0.995 (-1.00). All 28 variants on block 500 were at or below the pure arm; the more a variant switched, the worse.
- **Why**: most of the fit is noise at 1,600 logged matches a round (placebo fits with randomly redrawn runs reach the same deltas, except Kenpachi's SP-cells group, Ichigo's burst group and her `:ored`); the fit estimates "run arm k for 3-9 s then return", not the table's policy; switching across style functions resets style state (`:keep-state` removed Ichigo's 11 time-outs against `none` but not the mix loss); and the populations hold dominated whole-game refinements, so there is little to choose. The exchange group carries nothing; `:awk` duplicates the form cue; `:oawk`, `:wall` are noise.
- **Consequence**: PLAN §2's admission (a best response to an equilibrium column) builds dominance chains; the tables need actions that differ by situation. The revised plan (Fable, `sp/PLAN2.md`) decides the actions, the admission rule, KH / IH and the fit before more cells run.

### 11.11 PLAN2 step 1: band tables, the user's `:keep-state` answer (2026-11-14)

- **`:keep-state` reopened** for the new tables (AskUserQuestion, 2026-11-14: 「重新打開 (Recommended)」). It supersedes 2026-11-09's 「兩個都拿掉」 for tables built under PLAN2, because the KI fit probe measured an effect (Ichigo's style reset by switches: 11 time-outs against `none`, 0 with it). On in every new table; an arm with a different `:fn` or `none` is allowed only with it. The shipped lookup is unchanged.
- **`sp/band.py`** (imports sw.py's rule-base reader and writer, eval.py's runner): `bands` prints each band's `:rb-sp` rules (`nocell` 27; `mycell` 30-35; `bothrich` 35; `myburst` 38-39; `hisburst` 37, 39; `awake` 21-26); `write` makes a raw `:fq` table, arm 0 everywhere, arm k at +q in the band's rules and -q in the rest of its group (otherwise the margin keeps arm k once picked, and a `none` arm k would start the match: `:prev` reads arm 1); `pair` gives the paired b / c / z on K.O. wins through eval.py's cache. The groups are crisp, so any q above `:margin` plays the same; a merged q must exceed 0.02.
- **Identity**: a band table with arm k a copy of arm 0 plays its arm raw bit for bit (Kenpachi `nocell`, Ichigo `myburst`, keep-state on and off; 200 gate rows and 4,236 hash lines each).
- **The sim-only check** (the probe's two divisions of labour) admits nothing on seeds 801-1000 (1,200 matches, paired against arm 0): Kenpachi `r1-b2a2` in `nocell` z -1.17, time-outs 16 vs 0; Ichigo `none` in `myburst` (keep-state on) z -1.31. Keep-state on vs off made no measurable difference there (the band is active 6 % of judgements). PLAN2 §2's stop rule now rests on round 3.

### 11.12 KI round 3 and checkpoint A (2026-11-14)

- **Round 3** (PLAN2 §2, band specialists; workspaces `sp/ki-K-band`, `sp/ki-I-band`, 4 branches x 2 attempts, one band a branch, `v1_rank_keep`; 15 Sonnet data cells). Each cell wrote a band table with `band.py` (arm 0 = the side's incumbent, arm k a knob variant) and was scored with eval.py on block 300; the lead rescored the promising ones paired against arm 0 on block 200, and the best per band went to seeds 801-1000.
- **Kenpachi** (incumbent `r2-b1a2`, 0.6518 against Ichigo's population): his best block-300 bands (`nocell` with `:kk-ns-safe-p 0`, z -3.28; `bothrich` without back Steps / dodges, z -2.52) did not replicate on block 200 (z +0.52, +0.40); nor did `mycell`, `hisburst` or the second attempts (block 200 pooled z between -0.32 and +1.73). Each had been picked as the best of ~12-20 variants on 600 matches: selection found noise. A warning in the second-attempt briefs (few, mechanism-driven variants) gave honest but null results. No band admitted.
- **Ichigo** (incumbent `r2-b2a2`, 0.8927): `awake` (after awakening, almost only pointer-3 episodes: `:iks-mix-ptr3 6`, `:iks-mix-whiff 0.3`): block 300 0.9241 (paired z -2.29), block 200 z -2.24, **admitted** on 801-1000 (1,200 matches: b 52 / c 85, z -2.82 for the table, time-outs 1 / 1; against Kenpachi's mix 298 → 325 K.O. wins). `myburst`, `hisburst`, `mycell` stayed within noise.
- **Ship test** (`sp/ship.py`, the only tool on 601-800; z > 0 favours the table): Ichigo's table `sp/final/ki-ichigo.lisp` against her arm 0: vs Kenpachi's final 79 / 46, z +2.95 (332 vs 299 K.O. wins of 400); vs his `none` 1 / 4, z -1.34; pooled z +2.63, K.O. rate 99.88 %, 1 time-out: **passes** (z ≥ 1.96, K.O. ≥ 90 %, not losing to his anchor). Its band q is the measured gain 0.0275 (PLAN2 §3; any q above the 0.02 margin plays the same offline; against a human `fq-online` may switch the band off, which is its job) — the lead's call.
- **Kenpachi ships the fallback** `sp/final/ki-kenpachi.lisp`: `r2-b1a2` in every rule, alternates `r1-b2a2`, the pilot and `none` at Q -0.05 (in G0), `:keep-state`; plays `r2-b1a2` bit for bit (501-600: 4,236 hash lines; 601-800: b = c = 0). A fuzzy Q table in format only; reported as such, not as a gaining table.
- **Checkpoint A verdict**: bands can gain (Ichigo's passes held-out), so PLAN2's stop rule does not fire; KH and IH proceed (round 1 whole-game, round 2 specialists). Lessons carried: one candidate a band to the admission block, block-200 rescoring before any admission, cells told to screen few mechanism-driven variants.

### 11.13 KH / IH seeds and the lead's allocation (2026-11-14)

- **Seeds** (`sp/pop/kh-*.json`, `ih-*.json`, matrices on block 200; build db031584; `none` = `a-generic` here, as §11.4 said): KH Kenpachi's mix is KI's `r2-b0a2` (value 0.975; his initial program, block 300 0.985), Hisagi's best K.O. share against it 0.010; Hisagi's initial program `a-hisagi-kite` 0.343 with 118 time-outs in 600 (~80 % K.O.). IH: Ichigo's mix KI's `r1-b0a2` (value 0.97; initial 0.899), Hisagi's initial `h1-range` (`hisagi-range-style`) 0.365, 10 time-outs. The old Hisagi arms stall against Ichigo (52-77 of 80 to the bell) but K.O. Kenpachi's plain CPU; KI's arms transfer unevenly (KI's incumbents are not KH / IH's best).
- **Allocation** (the lead, within PLAN2's budget): KH Kenpachi is at the ceiling (0.985 of ~0.99), so no search there: he ships his best pure arm as a fallback table, and those cells go to Hisagi. IH runs first (both sides in the same round, PLAN2 §2); KH Hisagi follows alone against Kenpachi's frozen population. Hisagi's ranged mode exposes no knobs, so each Hisagi side starts with two Opus code cells (b2, b3) beside two data cells.

### 11.14 IH round 1 (2026-11-14)

- **Ichigo** (start KI's `r1-b0a2`, 0.8993): moving her to KI's `ichigo-ki-r2b2a1-style` (the 45° wake-up roll) with `:range 0.5`, `:awaken 2`, `:iks-mix-generic 0.6` reached 0.9917 on blocks 300 / 200 / 400 alike (598 of 600 K.O. wins): the ceiling. Her round closed after two batches (no headroom left to measure).
- **Hisagi** (start `h1-range`, 0.3647): his data cells met a wall (Ichigo's equilibrium arm beat every knob variant ~196 : 4); a code cell found that Ichigo's timed Hoho stays shut while her Reishi is under half and her flash-step is at the regen cap, and `hisagi-ihr1b2a0-style` presses into that window (0.4851); a second added a hold outside her pointer-3 lunge band (`hisagi-ihr1b2a1-style`, 0.5247); both merged into main as additive files. Best: `c-ih-h-r1-b0a2` = the b2a0 style + `:ihx-chase 20` + `:hold-awaken 0.3`: blocks 300 / 200 / 400 0.713 / 0.668 / 0.690 (against Ichigo's old equilibrium arm 3 → 130 K.O. wins of 200).
- **Admission** (block-200 matrix, 16 x 10): admitted Ichigo `ih-r1-b0a1` (beats every Hisagi arm, 0.93-1.00) and `ih-r1-b1a1`, Hisagi `ih-r1-b0a2` (strongest against every older Ichigo arm, 0 against her new `b0a1`). Mixes: Ichigo b0a1 0.81 + b1a1 0.19 (value 0.94); Hisagi `a-hisagi-kite` 0.84 + b0a2 0.16 (value 0.03). Records: `sp/ih-r1-admission.md`, `sp/arms/ih-r1/`.

### 11.15 The user's call: wrap up and ship (2026-11-14)

- Asked at the checkpoint-B threshold (fewer than half of six sides gaining): KI Ichigo's band table gains on held-out seeds; KI Kenpachi found no band that replicates; KH Kenpachi (0.985) and IH Ichigo (0.9917) sit at the ceiling, where a band cannot show a gain; Hisagi takes almost no K.O.s from the searched opponents (IH 0 against Ichigo's new arm, KH ~1 % against Kenpachi's). Options: wrap up and ship / finish the plan (~30 cells) / look at Hisagi's balance first. The user (AskUserQuestion, 2026-11-14): 「收尾出貨 (Recommended)」.
- **What ships** (HARD): KI Ichigo `sp/final/ki-ichigo.lisp` (gaining); every other side its best pure arm against the opponent's final, written as a constant table (PLAN2 §3 fallback: alternates and `none` at Q -0.05 for `fq-online.lisp`), reported as tables in format only. Mirrors by PLAN2's sufficiency check (the cross-pairing incumbents on both seats). The stalling lookup leaves. Then NORMAL (PLAN2 §4: the table in 10 s windows at chance 0.5, else `none`), G2's reference regenerated, the gates, the playtest Artifact. The unused search budget (~60 cells) is not spent.

### 11.16 The shipped tables (HARD) (2026-11-14)

**The nine tables** (`docs/research/strategy-drsi/sp/final/`, README there): one per ordered pairing, every one `:rb-sp` (42 rules in 5 groups), `:xfeats t`, `:keep-state t`, `:margin 0.02`, `:period 30`.
- **Gaining**: KI Ichigo `ki-ichigo` (arm 0 `c-ki-i-r2-b2a2`, arm 1 `c-ki-i-r3-b3a0-k` in `awake`).
- **Fallback** (arm 0 in every rule, alternates and `none` at Q -0.05 for `fq-online.lisp`): KI Kenpachi `c-ki-k-r2-b1a2`; KH Kenpachi and KK `c-ki-k-r2-b0a2`; KH Hisagi `a-hisagi-pressd`; IH Ichigo `c-ih-i-r1-b0a1`; II `c-ki-i-r2-b2a2` (54 % self-play K.O., kept: the stronger); IH and HH Hisagi `c-ih-h-r1-b2a0`.
- **The lead's call on Hisagi** (2026-11-14): IH arm 0 `c-ih-h-r1-b2a0` over `a-hisagi-kite` (full score 0.332 vs 0.304, K.O. rate 398 / 400; `kite`'s 7 K.O. wins against `ih-ichigo` cost 33 time-outs against her `none`); HH the same arm (95 % self-play K.O., beats `none` 193:5:2), alternates `kite`, `pressd`, `none`. Both rewritten by `band.py fallback` and proved to play arm 0 raw (`band.py pair`, block 200: b = c = 0 in every group, the same time-outs).

**Into the library: §10's path, one implementation.** `entry.py` maps each raw table's inline arms to arm units and its rules to a rule base; the arms the search made were not units yet:
- Two style units: `:st-ichigo-ki-r2b2a1` (`ichigo-ki-r2b2a1-style`), `:st-hisagi-ihr1b2a0` (`hisagi-ihr1b2a0-style`).
- Twelve arm units (`:c-ki-i-r2-b2a2` ... `:c-ih-h-r1-b0a2`), written by `sp/final/units.py` (each arm's keys over its style unit's; an id seen twice must be the same arm).
- `sp/final/add.sh` runs `entry.py` + `add.py` per table: nine entries `:f-<file>` (`:f-ki-ichigo` ... `:f-hh-hisagi`; the prefix because `:ki-ichigo` is round 1's strategy). `:keep-state` and `:xfeats` pass through `strat-expand` (host-checked).
- `strat-lookup`'s library find became `strat-by-id`, which the host tests share.

**The lookup.** Every HARD row now names a final table:

| Row | Was | Now |
|---|---|---|
| Ichigo vs Kenpachi | `:q1-ichigo-ken` | `:f-ki-ichigo` |
| Kenpachi vs Ichigo | `:qks3-ichigo` | `:f-ki-kenpachi` |
| Kenpachi vs Hisagi | `:qks5-hisagi` | `:f-kh-kenpachi` |
| Hisagi vs Kenpachi | `:qhs-ken` | `:f-kh-hisagi` |
| Ichigo vs Hisagi | `:qis-hisagi` | `:f-ih-ichigo` |
| Hisagi vs Ichigo | `:qhs3-ichigo` | `:f-ih-hisagi` |
| Kenpachi mirror | `:qks-ken` | `:f-kk-kenpachi` |
| Ichigo mirror | `:q1-ichigo-ichigo` | `:f-ii-ichigo` |
| Hisagi mirror | `:qhs4-mirror` | `:f-hh-hisagi` |

- **The old tables stay in the library**, as the superseded ones always have: the host tests read them by id (the event layer's `:knockdown` arm, `:qks5-hisagi` = `:qks3-hisagi` + the stand-off column, the online learner's `:keep` path on `:q1-ichigo-ken`), and research scripts name them (`hkfn/`, `khfn/`, `fq/switch/lineup.sh`, `proofs4.sh`, `hksplit/start.sh`). Their removal, with `:rb-switch89` and the units only they use, is a refactor batch of its own.
- **A player's saved online copy** (`fq-online.lisp` FQ-TABLE → `fq-decode`) loads only at the same length and checksum. The old tables have 89 or 48 rules, the new 42, so every saved copy loads fresh (host check per row: the old table's copy is NIL, a right-size copy with another checksum is NIL, the new table's own copy reads back with its match count).
  - Caveat: the checksum covers the q values only. Every fallback table with the same arm count has the same q, so a later rewrite that changes only its arms (as Step 0's IH Hisagi did in research) would keep a player's copy learned on the old arms. Folding the arm ids into the checksum would cost no extra reset now, since every saved copy is reset by this release anyway. Not done (not asked).
- The style-knob host check now allows knobs in the searched arms the tables ship (units `:c-*`, tables `:f-*`) and nowhere else.

**Proofs** (sim build of this branch):
- Raw = lookup: each raw file through `STRAT_P*` (`fq/proof/identity.py` via `sp/final/proofs.sh`) against the other side's final raw file (a mirror against itself), seeds 601-610 both seats: 2 of 2 chunks identical, 0 differing, b = c = 0, for all nine (`sp/final/proofs-600.jsonl`).
- G2 (`simgate.py --cvc`, NORMAL; the lookup is HARD-only): II 36 / IK 40 / KK 38 lines, PASS, identical to the old reference.
- Host tests ALL PASS (3274 checks); `pkgcheck.sh duel`: only DUEL::APP.
- The live lookup's tables leave nothing behind (HARD, seed 601, KI and IH through the pairing gate): snaptest straight = pollute (KI 38 lines, 302 rollouts; IH 34 lines, 247 rollouts; 0 differ); fulltest with `FT_LAYER=t` 0 differ (KI 553 checks, IH 526).
- `./build.sh duel`; smoke desktop and `--mobile --size 390x844` exit 0.

**HARD CvC with the new lookup** (seeds 601-620, reported, not gated). Every gate starts its matches through gate.lisp START-CVC, which reads `*gate-difficulty*` (debug 81022 = HARD).
- One seat: `python3 tools/simgate.py --pairs 2,7,9,29,31,35 --seed0 600 --seeds 20 --cmd 81022` (KK IK II HK HI HH, the first-named character as P1).
- The other seat of the cross pairings: the pairing gate, `tools/simgate/run.lisp` with `30600 31120 81022 C` and C = 200130 (KI), 200170 (KH), 200370 (IH) (200000 + 100 c1 + 10 c2).

| Pairing | Matches | K.O. | Median s | K.O. wins |
|---|---|---|---|---|
| KK | 20 | 20 | 141.0 | — |
| KI | 40 | 40 | 152.2 | Ichigo 37, Kenpachi 3 |
| II | 20 | 12 | 294.8 | — (8 time-outs) |
| KH | 40 | 40 | 144.8 | Kenpachi 40 |
| IH | 40 | 40 | 106.5 | Ichigo 40 |
| HH | 20 | 17 | 228.3 | — (3 time-outs) |
