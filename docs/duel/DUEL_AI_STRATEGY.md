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
