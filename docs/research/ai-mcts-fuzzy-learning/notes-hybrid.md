# Hybrid MCTS: priors, opponent models, value corrections, rule-based knowledge (notes)

Literature notes for DUEL_AI_MCTS (the core CPU as MCTS + fuzzy + learning, DEVLOG §632). Collected 2026-11-08.

**Our setting, for reading every entry:** fixed 48–160 rollouts per decision, about 1 ms, fixnum math, a light abstract
forward model whose fidelity is weak at HARD. Plan: a fuzzy reactive layer, fuzzy leaf evaluation, offline-learned
corrections of the light model's values, and an online-learned opponent model of the human used inside the tree.

**Verification rule:** every source below was opened (abstract page, full text, or the PDF read as text). Numbers
come only from the opened text. Sources seen only in search snippets are listed under "Excluded" at the end.

**Tiers:** T1 = peer-reviewed (journal or conference proceedings). T2 = preprint, not peer-reviewed in the version read.
T3 = blog, talk write-up, trade press.

**Budget line:** each entry states the search budget its numbers were measured at, because most evidence comes from
budgets 1–3 orders of magnitude above ours.

---

## 1. Priors in the tree: offline knowledge, progressive bias, PUCT

**[1] Gelly, S. & Silver, D. (2007). Combining online and offline knowledge in UCT. ICML 2007, 273–280.
doi:10.1145/1273496.1273531.** https://mlanthology.org/icml/2007/gelly2007icml-combining (full text read from a
mirror PDF). **T1.**
- Three ways to bring offline knowledge into UCT in 9x9 Go. (a) A learned value function as the rollout (default)
  policy. (b) RAVE, a rapid action-value estimate blended with the UCT value. (c) The offline value as a prior,
  initialising a new node's value Q_prior with n_prior "equivalent experience" visits.
- Against GnuGo 3.7.10 level 8 at 3000 sims/move: plain UCT 1.84%, UCT with the handcrafted MoGo rollout policy 23.88%,
  plus RAVE 60.47%, plus the learned prior 69%. The best prior weight was M_eq = 50 visits, so the learned function was
  "worth about as much as 50 episodes".
- **The key negative result:** policies built from the learned value function beat MoGo's handcrafted policy *as players*
  by over 90%. Used as the rollout policy, though, UCT won only 9.38% vs 48.62% (5000 sims, level 0). If the rollout
  policy is too deterministic, Monte-Carlo simulation stops helping. Rollout accuracy (MSE against labelled positions)
  tracked strength; the rollout policy's own playing strength did not.
- Budget: 3000–5000 sims/move (up to 70,000).
- Relevance: the template for "fuzzy prior as virtual visits". The rollout result warns against using the fuzzy
  reactive layer as a near-deterministic rollout policy.

**[2] Chaslot, G., Winands, M., van den Herik, H. J., Uiterwijk, J. & Bouzy, B. (2008). Progressive strategies for
Monte-Carlo tree search. New Mathematics and Natural Computation 4(3), 343–357. doi:10.1142/S1793005708001094.**
https://cris.maastrichtuniversity.nl/en/publications/progressive-strategies-for-monte-carlo-tree-search (abstract). **T1.**
- Progressive bias adds a heuristic term to selection that fades as visits grow. Progressive unpruning first cuts the
  branching factor to the heuristically best moves, then widens it again.
- These let the search use time-expensive heuristic knowledge without slowing it. Both significantly improved Go program
  Mango, and the combination did better on larger boards.
- Budget: not in the abstract (Go engine with full-length searches).
- Relevance: the cheap substitute for a policy network. Score the fuzzy layer's action preference once per node, not
  once per rollout, and widen gradually.

**[3] Silver, D. et al. (2017). Mastering chess and shogi by self-play with a general reinforcement learning algorithm.
arXiv:1712.01815.** https://arxiv.org/abs/1712.01815 (text read via ar5iv). **T2** (preprint version read).
- Each simulation selects moves with "low visit count, high move probability and high value". The network evaluates the
  leaf with no rollout, and values are averaged rather than minimaxed. Dirichlet noise is added to the root priors.
- 800 simulations per MCTS in training. AlphaZero searches 80 thousand positions/s in chess vs 70 million for Stockfish.
- Budget: 800 sims (training). The large network is far from our cost model.
- Relevance: the reference design (prior in selection, learned value at the leaf), shown to beat a much faster search.
  Our analogue: a fuzzy prior plus a fuzzy and learned leaf value.

**[4] Danihelka, I., Guez, A., Schrittwieser, J. & Silver, D. (2022). Policy improvement by planning with Gumbel.
ICLR 2022.** https://mlanthology.org/iclr/2022/danihelka2022iclr-policy (abstract). **T1.**
- AlphaZero's policy can fail to improve when not all root actions are visited. Gumbel AlphaZero / MuZero instead sample
  root actions without replacement and replace the heuristic selection with a policy-improvement rule.
- They match state of the art on Go, chess and Atari, and "significantly improve prior performance when planning with few
  simulations".
- Budget: "few simulations" (the abstract gives no number).
- Relevance: a principled small-budget root rule. With 48–160 rollouts, sample a few prior-ranked root actions and give
  them the budget, rather than spreading UCB across the full action set.

## 2. Opponent models inside the search

**[5] Kim, M.-J. & Kim, K.-J. (2017). Opponent modeling based on action table for MCTS-based fighting game AI. IEEE CIG
2017, 178–180. doi:10.1109/CIG.2017.8080432.**
https://cilab.gist.ac.kr/hp/wp-content/uploads/publications/international_conference/2017/opponent_modeling_based_on_action_table_for_mcts-based_fighting_game_ai.pdf
(full text). **T1** (short paper).
- FightingICE, 16.6 ms response limit, about 40 actions per character. The baseline MCTS bots simulate only 5 random
  opponent actions. This paper replaces them with the opponent's top 5 actions per situation, from a table of 6 buckets
  (3 distance ranges × air/ground).
- The default table is built offline (100 games against the 2015 top three) to solve the cold start. After each round the
  table is updated from frequencies, changing at most 2 entries "to minimize forgetting effect". About 70% of opponent
  actions fell in the top five.
- Over 200 games each: 86% wins vs the sample MCTS bot, 76% vs the 2016 runner-up, 40% vs the 2016 winner Thunder01.
- Budget: 16.6 ms/frame (rollout count not stated).
- Relevance: the closest template for our opponent model. Situation-bucketed frequency tables, an offline prior, and
  slow updates.

**[6] Ishihara, M., Ito, S., Ishii, R., Harada, T. & Thawonmas, R. (2018). Monte-Carlo tree search for implementation of
dynamic difficulty adjustment fighting game AIs having believable behaviors. IEEE CIG 2018.**
http://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-ishihara.pdf (full text). **T1.**
- Open-loop MCTS in FightingICE. Nodes are the AI's actions only. The opponent's actions in rollouts come from Roulette
  Selection over the frequencies of actions the human actually played.
- The leaf value mixes eval = (1−α)·B + α·E. B rewards damage dealt (believability) and E = 1 − tanh(|HP diff|/Scale)
  targets an even fight. α = (tanh(HP lead/Scale)+1)/2, so the AI plays for parity when ahead and plays aggressively when
  behind. This removed "unnatural" acts (repeating no-hit attacks, backing off at range).
- Parameters: C 0.42, expand after N_max 7 visits, depth D_max 3, simulation 60 frames, T_max 16.5 ms. With beginner and
  intermediate humans it gave the best HP-difference tracking, and the best Challenge and Believability for intermediates.
- Budget: 16.5 ms per decision, depth 3.
- Relevance: (a) an online frequency opponent model used as the rollout policy, (b) a hand-built leaf evaluation that
  shapes difficulty and believability. A direct precedent for a fuzzy leaf evaluation that scales by difficulty.

**[7] Demediuk, S., Tamassia, M., Raffe, W. L., Zambetta, F., Li, X. & Mueller, F. (2017). Monte Carlo tree search based
algorithms for dynamic difficulty adjustment. IEEE CIG 2017, 53–59. doi:10.1109/CIG.2017.8080415.**
https://opus.lib.uts.edu.au/handle/10453/127485 (abstract). **T1.**
- Four DDA agents (Reactive and Proactive OSAS and their "True" variants) change MCTS action selection and playout
  evaluation to aim at a zero health difference in FightingICE. The Proactive variants keep fighting when the health
  difference is zero, which reads as more believable.
- Budget: not in the abstract (FightingICE frame limit).
- Relevance: difficulty as an evaluation target rather than injected mistakes. [6] compares against its TPOSAS variant.

**[8] Goodman, J. & Lucas, S. M. (2020). Does it matter how well I know what you're thinking? Opponent modelling in an
RTS game. IEEE CEC 2020.** https://arxiv.org/abs/2006.08659 (text read via ar5iv). **T1.**
- Ground War, a simple RTS. Both MCTS and RHEA got 50 iterations per decision (RHEA about 0.8 ms, MCTS about 1.6 ms),
  and any opponent model roughly doubled the time. Model accuracy was swept over 100 variants, 2000 games each.
- RHEA beat its no-model version only with a nearly exact model. MCTS improved with any opponent model, even inaccurate
  ones, and degraded gradually.
- "MCTS+MCTS", modelling the opponent inside the tree with no extra forward-model calls, had the best round-robin win
  rate (54.5%). It was weaker against a specific opponent than a well-matched model.
- Budget: **50 iterations / about 1.6 ms. This is the only verified source at our budget.**
- Relevance: at our budget, an imperfect learned opponent model inside MCTS is low-risk. Keep an in-tree (or default)
  fallback for unknown players.

**[9] Tang, Z., Zhu, Y., Zhao, D. & Lucas, S. M. (2020). Enhanced rolling horizon evolution algorithm with opponent model
learning: results for the Fighting Game AI Competition. arXiv:2003.13949.** https://arxiv.org/abs/2003.13949 (text read
via ar5iv). **T2.**
- RHEA plus an opponent model trained online from the opponent's state-action history at each round end (about 5 s of
  inter-round time), by SL (cross-entropy), Q-learning or policy gradient.
- Mean win rate vs the 2018 FTGAIC bots (GAR / LUD / ZEN): RHEA 84.5 / 69.6 / 73.4; with the PG model 89.6 / 93.1 / 87.3.
  A *random* opponent model dropped ZEN to 50.6%, misleading the rollout evaluation. Placed 2nd in FTGAIC 2019, the only
  non-MCTS bot in the top five.
- Budget: 16.67 ms/frame.
- Relevance: learned opponent models pay off in fighting games, and a bad model can hurt. Train between rounds, not per
  frame.

**[10] Johanson, M. & Bowling, M. (2009). Data biased robust counter strategies. AISTATS 2009, PMLR 5, 264–271.**
https://proceedings.mlr.press/v5/johanson09a.html (abstract). **T1.**
- A best response to an opponent model built from past data exploits well but is brittle when the data is misleading,
  sparse or stale. An equilibrium is safe but ignores the opponent.
- Data-biased response solves a modified game that trades exploitation against exploitability, weighted by how much data
  supports the model. It is more broadly applicable than restricted Nash response and works with very little data
  (heads-up limit Texas Hold'em).
- Budget: offline equilibrium computation, not search.
- Relevance: the principle to copy. Weight the opponent model by its evidence per situation, and fall back to the default
  play where data is thin.

**[11] Ganzfried, S. & Sandholm, T. (2011). Game theory-based opponent modeling in large imperfect-information games
(DBBR). AAMAS 2011, 533–540.** https://www.cs.huji.ac.il/~jeff/aamas11/papers/B4_R56.pdf (full text). **T1.**
- Posterior action probabilities blend a precomputed equilibrium with observed counts through a Dirichlet prior of
  N_prior fictitious observations (N_prior = 5). Observations dominate quickly where data is dense, and the equilibrium
  rules where it is sparse.
- They play equilibrium for the first T = 1000 hands, then recompute the model every k = 50 hands. DBBR beat the
  equilibrium bot against all tested weak opponents.
- **Proposition 1:** you cannot exploit by deviating from equilibrium and still guarantee the game value. They also note
  the "get-taught-and-exploited" risk (an opponent baits a pattern, then punishes the exploit) and recommend exploiting
  only above a win-rate threshold.
- Budget: real-time, model recomputed every 50 hands.
- Relevance: the exact blending rule for our opponent model. Prior = the generic population model, counts = this player.
  Humans in fighting games do bait, so gate exploitation.

**[12] Devlin, S., Anspoka, A., Sephton, N., Cowling, P. I. & Rollason, J. (2016). Combining gameplay data with Monte
Carlo tree search to emulate human play. AIIDE 2016.**
https://cdn.aaai.org/ojs/12858/12858-52-16374-1-2-20201228.pdf (full text). **T1.**
- AI Factory Spades, 27,592 human games. A Bradley-Terry move model (44.96% test accuracy vs 29.39% random) enters ISMCTS
  selection as UCT(i) = X_i + 0.7·√(ln n / n_i) + C_BT·√(DR/(n+DR))·P(m_i).
- Best setting C_BT = 0.03, DR = 1000. KL divergence from human move distribution: baseline 0.1142, shipped AI Factory
  agent 0.0981, biased 0.0291. Win rate vs unbiased 49.6% ± 3.4%, response time within ±30 ms.
- Too strong a bias raised KL and lost strength ("like a novice imitating professionals").
- Budget: the shipped ISMCTS budget (iterations not given in the opened sections).
- Relevance: a learned human prior gives human-like play at equal strength. **Check at our budget:** with n ≤ 160 and
  DR = 1000 the decay factor √(1000/1160) ≈ 0.93, so this bias is almost constant through our whole search. DR must be
  re-tuned to our rollout count.

**[13] Baier, H., Sattaur, A., Powley, E. J., Devlin, S., Rollason, J. & Cowling, P. I. (2018). Emulating human play in a
leading mobile card game. IEEE Transactions on Games 11(4). doi:10.1109/TG.2018.2835764.**
https://repository.falmouth.ac.uk/2872/ (abstract). **T1.**
- Player model from gameplay data with neural networks and no domain knowledge, used to bias MCTS. The agents emulate
  human play "whilst maintaining strong, competitive performance" in AI Factory Spades.
- Budget: not in the abstract.
- Relevance: the follow-up to [12], showing the approach held up in the commercial codebase.

## 3. Heuristic / learned evaluation with rollouts; imperfect models

**[14] Lanctot, M., Winands, M. H. M., Pepels, T. & Sturtevant, N. R. (2014). Monte Carlo tree search with heuristic
evaluations using implicit minimax backups. IEEE CIG 2014 (expanded arXiv:1406.0486).**
https://arxiv.org/abs/1406.0486 (full text read from https://www.cs.du.edu/~sturtevant/papers/im-mcts.pdf). **T1.**
- Each node keeps two separate stores. One is the rollout win rate. The other is v^τ, the heuristic evaluation backed up
  by minimax: leaves get v0(s) at expansion, and each update sets v^τ_s to the max over children.
- Selection uses Q_IM = (1−α)·r/n + α·v^τ. Evaluations never replace playouts.
- Breakthrough at 1 s: im0.4 beat the tuned baseline in α ∈ [0.1, 0.6]. It won 82.3% without playout terminations and
  87.2% with fixed early terminations. It beat a constant-bias mix (1−α)Q + αv0 at 67.8% and a progressive-bias mix at
  65.5%, so the minimax *backup*, not the evaluation alone, carries the gain.
- With node priors as well: 77.9% vs 63.3% without, so the two combine. Kalah and LOA also gained. Safe α range
  [0.15, 0.4].
- Budget: 1 s and 5 s per move (thousands of simulations).
- Relevance: the strongest verified recipe for a fuzzy leaf evaluation. Store it next to rollout returns, back it up by
  max, mix with α of about 0.15–0.4.

**[15] Baier, H. & Winands, M. H. M. (2015). MCTS-minimax hybrids. IEEE Transactions on Computational Intelligence and AI
in Games 7(2), 167–179. doi:10.1109/TCIAIG.2014.2366555.**
https://dke.maastrichtuniversity.nl/m.winands/documents/mcts-minimax_hybrids_final.pdf (full text). **T1.**
- Selective MCTS with averaging backups can miss shallow traps. They embed shallow minimax in the rollouts (MR),
  selection/expansion (MS) or backpropagation (MB), with no evaluation function.
- Gains followed trap density: Catch the Lion > Breakthrough > Connect-4 > Othello (no gain). MR is best for branching
  factors up to about 10 but significantly weaker than baseline in Breakthrough. MS and MB are robust up to about 50.
  Combining hybrids gave no extra gain.
- Budget: time-based, with uniform-random rollouts.
- Relevance: a fighting game has "traps" (a whiffed SP punished in a few frames). A 1–2 ply exact check of our own move
  against the opponent's fastest punish, in selection or at expansion, is the cheap analogue. Rules hard-prune what
  sampling would miss.

**[16] Silver, D. & Tesauro, G. (2009). Monte-Carlo simulation balancing. ICML 2009, 945–952.
doi:10.1145/1553374.1553495.** https://mlanthology.org/icml/2009/silver2009icml-monte (abstract). **T1.**
- Learns the rollout policy for *balance* (an accurate spread of outcomes), not strength, with two gradient methods.
- 5x5 Go, softmax over about 100 patterns: half the MSE of uniform random, and overall performance equal to a sophisticated
  Go engine.
- Budget: not in the abstract.
- Relevance: if the fuzzy layer drives rollouts, tune it so rollout outcomes match real outcomes (an MSE target), not so it
  wins more on its own.

**[17] Kohankhaki, F., Aghakasiri, K., Zhang, H., Wei, T.-H., Gao, C. & Müller, M. (2023). Monte Carlo tree search in
the presence of transition uncertainty (UA-MCTS). arXiv:2312.11348.** https://arxiv.org/abs/2312.11348 (HTML full text).
**T2.**
- A given but imperfect model degrades MCTS. True uncertainty = squared state difference between model and environment.
  A network Û regresses it from real transitions.
- All four phases are modified. Selection scales exploration by (1−softmax(Û)), expansion drops uncertain children,
  rollouts are weighted by low cumulative uncertainty, and backups are weighted toward certain children.
- MinAtar Space Invaders: true-model MCTS 18.4, corrupted 16.3, offline UA-MCTS 23.8. **Caveat:** offline uses the true
  uncertainty, an oracle. Online UA-MCTS beats the corrupted model everywhere but does not always reach the true model
  (Freeway, Breakout).
- Budget: MinAtar, sims not in the read text.
- Relevance: the only verified method that targets our exact problem (a light model that is wrong in places). A cheap form
  for us is a per-situation error table (light model vs full sim, offline) that down-weights or corrects values in
  low-fidelity situations.

**[18] Świechowski, M., Tajmajer, T. & Janusz, A. (2018). Improving Hearthstone AI by combining MCTS and supervised
learning algorithms. IEEE CIG 2018, 445–452.** https://arxiv.org/abs/1808.04794 (content read from the arXiv
pre-camera-ready copy). **T1** by venue.
- A value network (750 inputs, 256-128-64 tanh) truncates random rollouts after at least k = 20 steps and backs up the
  predicted win probability. Trained iteratively on MCTS self-play (1M-sample FIFO buffer, 64 iterations).
- Player 1 vs plain MCTS: baseline 73.5% at 0.5 s, about 82.0% with the network; at 1.0 s 70.6% → about 76.0%. The
  heuristics helped more at the tighter budget.
- Budget: 0.5–1 s/move (simulator about 10K games/s).
- Relevance: learned leaf values help *more* when the budget is small. This supports investing in leaf evaluation over
  more rollouts.

**[19] Soemers, D. J. N. J., Sironi, C. F., Schuster, T. & Winands, M. H. M. (2016). Enhancements for real-time
Monte-Carlo tree search in general video game playing. IEEE CIG 2016, 436–443.** https://arxiv.org/abs/2407.03049
(content read from the green-OA arXiv copy). **T1** by venue.
- Eight enhancements over 60 GVG-AI games. Combined: 31.0% → 48.4% wins vs vanilla MCTS.
- Individually, Knowledge-Based Evaluations gave the most (+6.1, 30.0 → 36.1). These are distance-to-object features
  whose weights are learned *online* from score changes (α_i from 0.8 decaying to 0.1, applied only when rollouts end
  score-neutral). Loss Avoidance gave +3.3 but halved simulations per tick in Frogs. Novelty pruning gave +3.0.
- Budget: 40 ms/tick, 1 s initialisation.
- Relevance: an online-learned evaluation that only breaks ties when rollouts are flat. A model for the "fuzzy leaf value
  + learned correction" split.

## 4. Industry practice

**[20] Whitehouse, D., Cowling, P. I., Powley, E. J. & Rollason, J. (2013). Integrating Monte Carlo tree search with
knowledge-based methods to create engaging play in a commercial mobile game. AIIDE 2013. doi:10.1609/aiide.v9i1.12679.**
https://aitopics.org/doc/conferences:59E1FFB4 (abstract). **T1.**
- AI Factory Spades (over 2.5M downloads). Adding knowledge-based methods to MCTS reduced moves human observers would
  see as blunders, which matters most when cooperating with an AI partner.
- The MCTS player is objectively stronger than the previous knowledge-based AI, customisable around a reusable core, and
  cheaper to develop.
- Budget: mobile, not in the abstract.
- Relevance: in a shipped game, rules are there to remove *visible* blunders that search occasionally makes. That is
  the same job as our fuzzy reactive layer.

**[21] Champandard, A. J. (2014). Monte-Carlo tree search in TOTAL WAR: ROME II's campaign AI. AiGameDev.com,
2014-08-12** (write-up of Tim Gosling and Piotr Andruszkiewicz's Game/AI Conference 2014 talk).
https://pdf.stafforini.com/champandard-2014-monte-carlo-tree.pdf (archived copy of
http://aigamedev.com/open/coverage/mcts-rome-ii/). **T3.**
- Divide and conquer. Task generation uses simple generators (not MCTS), resource allocation uses MCTS, and resource
  coordination uses an MCTS planner. A separate budgeting system prevents conflicts.
- Engineering: C++, cache-friendly tree layout, a stack allocator for nodes, "hard limits are imposed on the search", and
  search runs on "its own simplified copy of the game state".
- Domain knowledge: aggressive hard-coded pruning, removing duplicate options, and "soft restrictions" (biasing policy
  scores).
- Budget: "tens of thousands of search steps" per invocation.
- Relevance: AAA confirmation of an abstract state copy, hard caps, and rules as pruning plus soft bias.

**[22] Thompson, T. (2018). Revolutionary warfare: the AI of Total War (part 3). Game Developer, 2018-02-12.**
https://www.gamedeveloper.com/design/revolutionary-warfare-the-ai-of-total-war-part-3- **T3.**
- MCTS sits in task allocation, after viability filtering, and is run again for army movement and recruitment.
- Limits: "only capable of looking one turn ahead before starting random playouts". At launch, campaign turns took
  "several minutes", followed by weeks of patches.
- Budget: none stated (anytime).
- Relevance: shallow tree plus rollouts is what ships. Measured wall-clock cost was the launch problem, which supports
  our fixed rollout count.

---

## Synthesis

### What worked
- **Priors as virtual visits or a fading bias** ([1], [2], [12], [3]). This is the most replicated gain. Learned priors
  beat handcrafted ones ([1]: 60 → 69%), and a human-data prior changes *style* at equal strength ([12]: KL 0.114 →
  0.029, 49.6% win rate).
- **Heuristic leaf values kept separate from rollout returns and mixed at selection** ([14]: 65–87% in head-to-heads).
  This beats folding the evaluation into Q directly. Learned leaf values help more at tight budgets ([18]).
- **Online opponent models in fighting games** ([5], [6], [9]). Frequency tables bucketed by distance and air/ground,
  used as the opponent's rollout policy, gave 76–86% vs strong bots ([5]). Learned models raised RHEA's win rate by
  3–24 points ([9]).
- **Rules as pruning and blunder removal** ([15], [20], [21]). Shallow exact checks catch the traps that averaging misses.

### Limits
- **Budget mismatch.** Only [8] (50 iterations, about 1.6 ms) is at our scale. [5] and [6] (16.5–16.6 ms per frame,
  depth 3) are within about one order. Everything else is at 0.5 s–5 s or thousands of simulations. Weights such as
  M_eq = 50 ([1]) or DR = 1000 ([12]) cannot be copied: at 48–160 rollouts a 50-visit prior is a third to all of the
  search, and Devlin's bias barely decays.
- **A stronger rollout policy is not better** ([1], [16]). The rollout policy must stay stochastic and calibrated.
- **Opponent models can hurt.** A wrong model misleads rollouts ([9]: ZEN 73.4 → 50.6%). Exploitation is never
  free ([11], Prop. 1), and humans can bait a model (get-taught-and-exploited).
- **Imperfect-model correction is young.** [17] is one preprint with an oracle best case.

### Gaps (no verified source)
- Determinism, fixed-point / fixnum MCTS, and bit-exact replays.
- Learned *residual* corrections of an abstract forward model's values ([17] down-weights uncertainty, it does not correct
  values).
- Hybrid evaluation at under about 200 rollouts beyond [8].
- Fable Legends' MCTS and Game AI Pro MCTS chapters (not found or not openable).
- Rules as rollout policy vs unbiased playouts in RTS (Yang & Ontañón 2019, excluded below).

## Implications for SOUL DUEL's core CPU

1. **Fuzzy prior = virtual visits, tuned at our budget.** Initialise each child with n_prior visits at the fuzzy layer's
   value ([1]), or add a fading term c·√(D/(n+D))·P ([12]) with D on the order of the rollout count (about 20–60), not 1000.
   Sweep n_prior over about 2–16 at 48 and at 160 rollouts. The prior should hold a minority of the visits.
2. **Fuzzy leaf evaluation as a separate implicit-minimax store** ([14]). Keep the integer rollout-return sum and a max-
   backed fuzzy value per node, and select on (1−α)·mean + α·v^τ with α about 0.15–0.4 in fixed point. Do not replace
   rollouts with it. The learned offline correction of the light model goes into v0 (and into a per-situation α), where
   [18] and [19] suggest it pays most at small budgets.
3. **Fuzzy reactive layer in rollouts: stochastic and calibrated, or not at all** ([1], [16]). If it drives rollouts, use
   softmax sampling over its scores, and tune temperature so light-model rollout outcomes match full-sim outcomes. Use
   its hard rules as pruning and blunder vetoes in selection and expansion instead ([15], [20], [21]), e.g. a 1-ply exact
   punish check on unsafe moves.
4. **Opponent model = bucketed frequency table blended by Dirichlet pseudo-counts.** Buckets: distance band × air/ground ×
   our last action ([5]). Posterior = (N_prior·p_default + counts)/(N_prior + n) ([11], N_prior about 5). Use it as the
   opponent's rollout policy (Roulette Selection, [6]) and to bias the opponent's nodes. Update between rounds or slowly,
   at most a few entries per update ([5], [9]). Persisted cross-match data is the prior's best source.
5. **Gate exploitation and keep a fallback** ([8], [10], [11]). Weight the model by evidence per bucket, exploit only when
   the bucket has enough samples (and, at HARD, a win-rate check). Keep the generic CPU's default distribution as the
   floor. [8] suggests MCTS tolerates a mediocre model at our budget, so the downside is bounded if the fallback stays.
6. **Low-fidelity situations get distrust, not just correction** ([17]). Offline, log light-model vs full-sim error per
   situation bucket. In high-error buckets, shrink exploration or the rollout weight there, or lean on the leaf evaluation
   and rules. This matters most for HARD, where the light model's fidelity is weakest.

## Excluded (seen only in search snippets or unreachable; not cited above)
- Yang, Z. & Ontañón, S. (2019). Guiding Monte Carlo tree search by scripts in real-time strategy games. AIIDE 2019. The
  snippet said unbiased playouts beat script-biased ones. AAAI OJS returned HTTP 520 on three tries and dblp blocked the
  fetch.
- Ganzfried, S. & Sandholm, T. (2015). Safe opponent exploitation. ACM TEAC 3(2). No openable copy found (the ε-safe
  content was seen only through citing papers).
- Gumbel MuZero training with n = 2 simulations (ICLR 2022 slides not opened; [4] is cited only for its abstract).
- The Baier et al. 2018 bias formula as quoted by the survey arXiv:2103.04931 (not opened). The Aghakasiri UAlberta
  thesis (2022, UA-MCTS). JayBot_2017's competition placing (slideshare snippet). The ICML 2017 Test-of-Time award for [1].
- Uriarte & Ontañón (AIIDE 2016), MCTS policies learned from StarCraft replays (AAAI OJS 520).
- Fable Legends MCTS talk: no source found.
