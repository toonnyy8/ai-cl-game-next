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
  (`mc-est`: the light estimate plus the strategy's bias, in the light pick and the full sim's top two).
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
