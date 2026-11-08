# MCTS + fuzzy inference + learning for a fighting-game CPU: a literature review for SOUL DUEL

2026-11-08. Mode: lit-review (deep-research skill). Prepared for docs/duel/DUEL_AI_MCTS.md (the user: 「將核心的 AI 系統全置換成 MCTS + fuzzy +
學習型 AI」; 「在正式開始前請先使用 /academic-research-skills:deep-research 彙整這方面的相關資訊」). AI disclosure: the search, reading and
first drafts were done by AI research agents (Claude) that opened every cited source; the notes say how deeply each was read (full text /
abstract / slides / repository code). Sources that could not be opened are listed as excluded in each note and are not used here.

## 1. Question and method

**Question.** What do research papers, open implementations and practitioner write-ups say about building a fighting-game CPU from (1) MCTS,
(2) fuzzy inference, (3) learning (offline value correction, online opponent models, difficulty, human-likeness), and (4) their hybrids — and
what does that imply for a deterministic CPU with a ~1 ms per-decision budget in wasm, fixed iteration counts and fixnum hot loops?

**Method.** Four parallel searches (web, arXiv / alphaXiv, Semantic Scholar, IEEE / ACM records, GitHub), each writing an annotated, tier-graded
bibliography: `notes-mcts.md` (22 sources), `notes-fuzzy.md` (20), `notes-learning.md` (21), `notes-hybrid.md` (22); 85 entries, with
overlaps (Kim & Kim 2017, Ishihara 2018, Tang 2020 appear in two or three notes and agree on their numbers). Tier 1 = peer-reviewed, Tier 2 =
preprint, Tier 3 = blog / talk / repository / book excerpt. Citations below point to the notes (e.g. [M3] = notes-mcts entry 3, [F], [L], [H]).

## 2. Findings

### 2.1 MCTS in real-time fighting games

- **The standard is small but runs on the real simulator.** The FightingICE sample MCTS (code read): 16.5 ms per frame, depth 2 over its own
  actions only, 60-frame rollouts on the game's simulator against 5 uniformly random opponent actions, HP difference as the value; the 2023
  baseline caps at 23 rollouts [M1]. It handles the 15-frame input delay by simulating 14 null frames before searching.
- **No published fighting-game MCTS uses an abstract forward model** [M synthesis]; our light model's fidelity loss (DUEL_AI_TEACHER §9.2:
  barely better than random at HARD) is an unstudied problem. The only work on imperfect-model correction (UA-MCTS, Tier 2) down-weights
  uncertain transitions and needs the true uncertainty for its best result [H17].
- **Opponent prediction pays most**, even crude: a top-5 action table per 3 distance bands × air/ground, updated per round, won 86 % vs the
  sample MCTS and 76 % vs the 2016 runner-up, 40 % vs the 2016 winner [M3 = L1 = H5]; a one-layer softmax opponent model refit each round
  lifted RHEA from 84.5 / 69.6 / 73.4 % to 89.6 / 93.1 / 87.3 % mean wins on the three characters, while a random model dropped it to 50.6 %
  [M11 = L3 = H9].
- **Winners wrapped search in rules**: GigaThunder (2017) limited MCTS with rules; ReiwaThunder (2019) replaced MCTS with minimax + rules; the
  organizers noted "standard MCTS rarely blocks", fixed by a guard weight / 22-frame auto-guard and by excluding moves with > 45 frames of
  recovery at close range [M8]. This is our wake-up meaty / whiff-punish failure (§9.3 of DUEL_AI_TEACHER).
- **Simultaneous moves**: decoupled UCT best across 9 games and 62.3 % vs 51.4–54.3 % for sequential trees in Tron [M15, M16]; regret matching
  robust, Exp3 weakest [M18]. But a solved 5-move fighting game mixes in < 10 % of states [M19]: a sequential "my action → reply" tree is
  defensible, a mixed node pays only at guess points (wake-up).
- **Negative**: an AlphaZero-style net + search at 0.1 s per decision lost to the sample by −331.8 HP [M13, Tier 3].

### 2.2 Fuzzy inference for game agents

- **Fuzzy as chances**: Chu & Thawonmas (FightingICE, slides) used 4 single-condition rules whose memberships are the weighted-random
  probabilities, no defuzzification, and beat the crisp-threshold version 129-3-68 [F A]; Fuzzy_ZYQAI did the same but did not place [F A].
  **No fuzzy fighting agent was competitive with search bots**: fuzzy suits a reflex / blending layer, not strategy [F synthesis].
- **Tuning with fixed rule structure works**: (1+1)-ES in FightingICE, GA on a 15-rule TORCS driver (beat hand-tuned), GA over a tree of
  small fuzzy systems (ALPHA) [F B]; cost: an ES gained ~30 % over 100,000 games [F B].
- **Fuzzy evaluation inside search**: only Fuzzeval (backgammon): 15 rules ≈ 34 %, 30 rules ≈ 42 % vs Pubeval; a neural net needed
  75–85 k games to match it, peaking at 59 % [F C]. **No source uses fuzzy inference as an MCTS leaf / rollout evaluation**: our "fuzzy
  position value" has no direct precedent.
- **Cost / structure**: zero-order Sugeno is a few multiply-adds; centroid defuzzification ~100 samples [F D]. Rule explosion is solved by
  single-antecedent (Combs) rules or cascades of small systems [F D]. A weighted average dilutes a decisive rule by weak ones: rank-then-weight
  (Dill) or a multiplicative veto (Rodgers & Levine) [F synthesis].

### 2.3 Learning: opponent models, adaptation, difficulty, human-likeness

- **Situation-bucketed frequency tables** are the working opponent model at small budgets (distance band + air/ground + state keys) [L1, L2,
  L4, L6]; updated between rounds, small steps (≤ 2 entries per round [L1]); cold start needs a population prior (Kim & Kim seed from past
  champions) or a guarded fallback (k-NN loses round 1 [L2]).
- **Ghost / imitation pitfalls**: "doing nothing" is never recorded, ghosts never unlearn, pure imitation is exploitable [L4, L5]; Killer
  Instinct's Shadow AI uses 40+ metric nearest neighbour, ≤ 40 matches per matchup, demotes punished tactics, bluffs with lower-ranked picks
  [L6, Tier 3]; Drivatar weights old data less and filters through a designer layer [L8].
- **Exploitation is never free**: data-biased response blends a default strategy with counts by ~5 pseudo-observations; a player can bait and
  punish an exploiter [H11].
- **Difficulty**: step down the value ranking on a fixed cycle (Andrade 2005) or add an evenness / believability term to the MCTS evaluation
  (Ishihara 2018: 38 subjects, closer fights for beginners / intermediates p = .006 / .017; experts exploited its aggression) [L10, L11/L12].
- **Human-likeness**: Blade & Soul added 230 ms (~14 frames) to every decision to match pros; FightingICE delays data 15 frames [L14, L17].
  Deep RL takes millions of steps / days per agent (Blade & Soul 5 M steps, ~6 days) — not per-player [L17].

### 2.4 Hybrids

- **Priors as virtual visits** (Gelly & Silver 2007: 60 → 69 % at 3000 simulations; best prior worth 50 visits) and fading biases (Devlin et
  al. 2016) [H1, H12] — but their weights do not transfer to 48–160 rollouts; re-tune at our budget.
- **A stronger rollout policy can make MCTS weaker** (learned policies won > 90 % as players but 9.4 % vs 48.6 % as rollout policies) [H1,
  H16]: rollouts must stay stochastic and calibrated (Silver & Tesauro's simulation balancing).
- **Leaf evaluation kept separate** from rollout returns and mixed at selection with α ≈ 0.15–0.4 (implicit minimax backups: 65–87 % in
  head-to-heads; folding it into Q did worse) [H14]; learned leaf values pay most at tight budgets (Hearthstone) [H18].
- **Only one source runs at our budget**: Goodman & Lucas (50 iterations, ~1.6 ms): MCTS improved with *any* opponent model, even an
  inaccurate one [H8].
- **Rules as hard pruning / blunder vetoes** catch shallow traps averaging misses (shallow minimax hybrids, Total War, AI Factory) [H15, H20,
  H21].

## 3. Devil's-advocate checkpoint

- **Bias in the sources**: most results are bot-vs-bot on FightingICE's three characters with 2D, 15-frame-delayed play; SOUL DUEL is 3D with
  a triangle system, Kikons and forms. Numbers transfer as directions, not magnitudes.
- **Budget mismatch**: everything but [H8] ran at ≥ 10× our budget; "MCTS beats rules" findings were at 16 ms on the real simulator. Our own
  measurement (HARD light model ≈ random vs the full sim) is the more relevant evidence, and it says: lean on rules / learned models where the
  light model is weak.
- **Contradiction**: the winners' lesson (wrap search in rules) vs the user's decision to remove the matchup style CPUs. Resolved: the rules
  that must stay are *generic* (wake-up guard, recovery-based pruning, punish checks) and live in the fuzzy / veto layer, not as per-matchup
  code; the user's decision stands (no style CPUs), and strength is measured and reported.
- **Unprecedented parts**: fuzzy leaf evaluation in MCTS, residual correction of an abstract model, persistent per-player models with
  deterministic replays. Treat each as an experiment with an A/B, not as a known gain.
- **Over-fitting risk** in offline tuning: tune on seeds disjoint from the evaluation seeds (the teacher tables were partly in-sample, §9.2).

## 4. Design recommendations for SOUL DUEL (mapped to DUEL_AI_MCTS's stages)

1. **Fuzzy reactive layer** (stage 1): zero-order Sugeno, trapezoids, min-AND, weighted average; the answer is a chance rolled once per event
   (Chu & Thawonmas); 4–6 rules per decision, 2–3 sets per cue; a **rank / veto** for must-do reactions (a sure punish, a lethal Burst) so one
   decisive rule is not averaged away; sets resolved to breakpoints at load, cues read with `plist-get`; only + − × ÷ (no `exp` / `tanh` in
   anything the sim reads); difficulty one knob over the HARD outputs (the existing :skill / :choice).
2. **Generic timing rules instead of the style CPUs** (stage 2 + 5): a wake-up gate (guard / Hoho / reversal weighted when his active frames
   will overlap our first free frame), an okizeme rule for us (a timed meaty when he lies), and pruning of moves whose recovery exceeds his
   fastest punish at the current distance — the FightingICE winners' fixes, written as fuzzy rules over frame data, for every kit.
3. **MCTS changes** (stage 2): keep the sequential tree; use the fuzzy layer as **pruning / prior (virtual visits, n_prior swept 2–16 at 48 and
   160 rollouts)**, not as a stronger rollout policy; add a **fuzzy leaf value** for no-contact rollouts kept separate and mixed at selection
   (α 0.15–0.4, fixed point), A/B against a crisp linear score; a mixed node only at guess points (wake-up). Optional experiment: re-score the
   top 2 root actions with 1–2 full-sim rollouts via the snapshot (cost to be measured in wasm first: a 60-step full rollout is ~2.4 ms there).
4. **Offline learning** (stage 3): log light-model vs full-sim error per situation bucket (the teacher's TEACH_LITE data) → per-bucket distrust
   (lean on rules / leaf value where the error is high); tune the fuzzy consequents (then breakpoints) with a (1+1)-ES on the native sim, on
   seeds disjoint from the evaluation; bake as data.
5. **Online opponent model** (stage 4): integer counts per (distance band × his state × my last action) bucket and response (attack class,
   Hoho, guard, Step, turn, **nothing** — log the opportunity); a Dirichlet prior of ~5 pseudo-counts from CPU-vs-CPU population data;
   used as the reply level's prior and the opponent's rollout policy (roulette); exploitation weighted by the bucket's evidence with the
   population prior as the floor; folded into the persistent table only at round / match end with a bounded change; recency decay (halve per
   K matches); practice / paused inputs ignored.
6. **Determinism of the persistent model**: the table loaded from browser storage is a match input — copied at match start, read-only inside
   the step, its hash written with the match; CPU vs CPU, the gates and the native sim use the fixed population prior; a reset in settings.
7. **Difficulty and human-likeness**: difficulty through the evaluation / root pick (value-rank step, an evenness term) rather than a worse
   model; reaction delays near the published floor at HARD (14–15 frames; ours is 8, below it — worth revisiting with the user), longer below.

## 5. Limitations

Many fighting-game sources were read only as abstracts or slides; several key papers could not be opened (the 2019 HRL + MCTS options paper,
Ishii 2021, Ishihara 2016, GT Sophy's Nature paper); commercial systems (Shadow AI, Tekken Ghost, Drivatar) are documented only by
interviews / articles. No verified source covers fixnum / deterministic MCTS, fuzzy MCTS leaf evaluation, or residual correction of an
abstract model, so those parts of the plan rest on our own measurements.
