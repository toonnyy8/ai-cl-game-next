# MCTS for real-time fighting games: annotated bibliography (2026-11-08)

Scope: what the literature and the public implementations did with Monte Carlo Tree Search in real-time fighting games
(budget, forward model, action abstraction, rollout depth, input delay, opponent modelling, learned priors), plus the
simultaneous-move and open-loop / macro-action work that bears on our tree. Written for SOUL DUEL's in-game MCTS
(light 1-D model, two-level UCB tree my action -> opponent reply after a reaction delay, 48/96/160 rollouts a decision,
first-contact termination).

Rule: every entry was opened (paper text, the authors' slides, an abstract page or the code). "Abstract only" says so.
Tiers: **T1** peer-reviewed (journal, conference, peer-reviewed workshop); **T2** preprint (arXiv version read);
**T3** slides, repository, thesis, unreviewed symposium paper.

## A. FightingICE / DareFightingICE (Ritsumeikan, Thawonmas lab) and its competition

The platform's rules, as the organizers state them every year (2017, 2019, 2020 slides): 60 FPS, **16.67 ms** to choose
one of **~40 actions**, the state arrives **15 frames late** (to model human reaction), a **forward model**
(`simulator.Simulator`) is provided to entrants. Every search bot below plans on that simulator: none uses an abstract
model.

1. **TeamFightingICE. (2023). *MctsAi23i* [Source code; official sample / baseline MCTS AI]. GitHub.**
   https://github.com/TeamFightingICE/MctsAi23i — and the 2018 sample `MctsAi` as shipped in an entrant's repo:
   https://github.com/Danielhp95/CIG-FightingICE-2018-entry/tree/master/javaAIs/2018_Sample_AIs/MctsAi — **T3**
   Read the code (`Node.java`, `MctsAi23i.java`). Open-loop UCT over **my actions only**, tree depth `UCT_TREE_DEPTH = 2`,
   expand a node after `UCT_CREATE_NODE_THRESHOULD = 10` visits, UCB1 with `UCB_C = 3` on the **raw HP difference**
   (my HP change minus the opponent's), playout = 5 of my actions (path + random) against **5 uniformly random
   opponent actions** for `SIMULATION_TIME = 60` frames on the full simulator, final pick = most visited root child.
   The 15-frame delay is handled by first simulating `FRAME_AHEAD = 14` frames of null input from the delayed state,
   then searching from that state. Budget: `UCT_TIME = 16.5 ms`; the **23i** variant also caps it at
   `ITERATION_LIMIT = 23` rollouts a decision (a deliberately weak DareFightingICE baseline; the 2018 sample has no
   iteration cap, time only). Ground actions 24, air 15, filtered by energy cost.
   *Relevance*: the reference MCTS in this field is shallow (depth 2), cheap (tens of rollouts), full-fidelity, and has
   **no opponent node**: the opponent is noise inside the playout. Our two-level my -> reply tree is structurally richer;
   our weakness is the model, theirs is the opponent.

2. **Yoshida, S., Ishihara, M., Miyazaki, T., Nakagawa, Y., Harada, T., & Thawonmas, R. (2016). Application of
   Monte-Carlo tree search in a fighting game AI. *IEEE 5th Global Conference on Consumer Electronics (GCCE 2016)*, 1–2.**
   Verified through the authors' slides: https://www.slideshare.net/slideshow/application-of-monte-carlo-tree-search-in-a-fighting-game-ai-gcce2016/68881168 — **T1** (content seen via slides)
   The paper behind the sample: C = 3, N_max = 10, D_max = 2, T_sim = 60 frames, all children expanded at once (large
   action set, short time), random opponent in simulation, node value = HP-difference change. 100 games against the
   2015 top five (rule-based): beat all except **Machete**, the 2015 winner, which the authors blame on Machete's short
   repeated actions that random opponent simulation models badly. The entry placed 3rd in 2016 (Thunder01 1st,
   Ranezi 2nd). The slides give scores only as a bar chart (no numbers). The slides conclude that random enemy
   simulation is not effective and name predicting the enemy as future work. *Relevance*: the first failure mode named for fighting-game MCTS is
   the **opponent model**, not the search.

3. **Kim, M.-J., & Kim, K.-J. (2017). Opponent modeling based on action table for MCTS-based fighting game AI.
   *IEEE Conference on Computational Intelligence and Games (CIG 2017)*.**
   https://cilab.gist.ac.kr/hp/wp-content/uploads/publications/international_conference/2017/opponent_modeling_based_on_action_table_for_mcts-based_fighting_game_ai.pdf — **T1** (full text read)
   Replaces the sample's 5 random opponent actions with a table of the opponent's **top 5 actions per condition**,
   **3 distance bands (x < 50, 50–85, 85–100) × air/ground** (beyond 100: plain MCTS). Cold start: a default table from
   100 games of a random AI vs each 2015 top-three AI; after each round the most frequent observed actions move up one
   rank or replace the lowest (at most two changes a round, to limit forgetting). Top-5 actions covered ~70 % of what
   opponents did. 200 games each: **86 % wins vs the basic MCTS sample, 76 % vs the 2016 runner-up, 40 % vs Thunder01**
   (the 2016 winner). *Relevance*: the cheapest opponent model that measurably helps; maps directly onto our second
   tree level (opponent reply) keyed by distance band and state.

4. **Ishihara, M., Ito, S., Ishii, R., Harada, T., & Thawonmas, R. (2018). Monte-Carlo tree search for implementation of
   dynamic difficulty adjustment fighting game AIs having believable behaviors. *IEEE CIG 2018*, 1–8.**
   http://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-ishihara.pdf (project page https://www.ice.ci.ritsumei.ac.jp/~ruck/dda-cig2018.htm) — **T1** (full text read)
   Open-loop MCTS with N_max = 7, D_max = 3, T_sim = 60 frames, T_max = **16.5 ms**. Opponent actions in simulation are
   drawn by **roulette selection over the frequencies the human opponent actually played**. Evaluation = mix of a
   difficulty term (rewards a near-zero HP difference, tanh-shaped) and a believability term (damage dealt, i.e.
   aggression), weighted by α = (tanh(HP diff / Scale) + 1) / 2: winning -> adjust difficulty, losing -> play aggressive.
   Motivated by the problem that pure HP-difference DDA agents look unnatural (repeated whiffs, back steps) when the
   difference is near zero. 38 subjects; compared to their eAI and Demediuk's True-POSAS. *Relevance*: (a) a frequency
   opponent model learned online from the player, (b) difficulty done by shaping the evaluation instead of by noise,
   with an explicit "don't look stupid" term.

5. **Ishii, R., Ito, S., Ishihara, M., Harada, T., & Thawonmas, R. (2018). Monte-Carlo tree search implementation of
   fighting game AIs having personas. *IEEE CIG 2018*.**
   http://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-ishii.pdf — **T1** (full text read)
   **Puppet-Master MCTS** (from Ito et al.): one open-loop tree controls both characters; **each node is a decision of
   whichever character can start a new action**, each edge the ongoing execution of the newly started action and the
   other character's earlier one, so the branching factor is one character's action count, not the product. Personas
   (Rushdown, Zoning) via the evaluation. C = 0.025 (normalized evaluation), N_max = 10, D_max = 10, T_sim = 60 frames;
   the 15-frame delay was **removed** (gameplay-video generation, not competition). 35 viewers named both characters'
   personas correctly far more often than with two independent MCTS agents (RushDown mirror 33/35 vs 17/35; Zoning
   mirror 16/35 vs 1/35; McNemar p < 0.01). *Relevance*: this
   event-driven alternating tree is the closest published analogue of our "my action -> opponent reply when he can act"
   structure, and it argues the opponent model is easier to place in one tree than in two.

6. **Ito, S., Ishihara, M., Tamassia, M., Harada, T., Thawonmas, R., & Zambetta, F. (2017). Procedural play generation
   according to play arcs using Monte-Carlo tree search. *Proc. GAME-ON 2017*, 67–71.**
   https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/gameon17-ito.pdf — **T1** (abstract and intro read)
   MCTS driven to hit target HP differences at given moments of a FightingICE match (play arcs). Preliminary results
   only. *Relevance*: shows the evaluation, not the search, is the knob for "how strong / what shape" a match is.

7. **Demediuk, S., Tamassia, M., Raffe, W. L., Zambetta, F., Li, X., & Mueller, F. (2017). Monte Carlo tree search based
   algorithms for dynamic difficulty adjustment. *IEEE CIG 2017*, 53–59. https://doi.org/10.1109/CIG.2017.8080415**
   https://opus.lib.uts.edu.au/handle/10453/127485 — **T1** (abstract only)
   Four DDA agents (Reactive / Proactive OSAS and "True" variants) that change MCTS's action selection and playout
   evaluation to steer toward zero HP difference, tested on FightingICE vs AIs and humans. Reactive OSAS hits the zero
   target exactly; Proactive keeps fighting at zero, judged more believable. *Relevance*: difficulty as an outcome
   target picked from the root's value distribution (choose the child closest to a target, not the best).

8. **Team FightingICE. (2017). *2017 Fighting Game AI Competition* [Results slides].**
   https://www.slideshare.net/slideshow/2017-fighting-game-ai-competition/79268222 — **T3**
   "MCTS is still dominant." 1st **GigaThunder**: MCTS with rule-based limits on the search space (cancels useless
   movements), six separate AIs (3 characters × 2 leagues). 2nd FooAI: the sample MCTS plus Thunder01 tweaks. 3rd
   JayBot_2017: MCTS + a **fixed** action table by distance band (kept static to stay robust to changing opponents).
   4th Mutagen: rule-based MCTS. Organizers' note: **standard MCTS rarely blocks**; Mutagen gave guard a constant weight
   in the tree and auto-guards 22 frames; for LUD, moves with **end lag > 45 frames are excluded** at close range.
   *Relevance*: the winning recipe was MCTS inside rules (prune bad moves, force guard), not purer search. The "rarely
   blocks" note is the same exploitability we see vs meaties.

9. **Team FightingICE. (2019). *2019 Fighting Game AI Competition* [Results slides].**
   https://www.slideshare.net/ftgaic/2019-fighting-game-ai-competition — **T3**
   1st ReiwaThunder: the 2018 champion with **MCTS replaced by minimax** + per-character heuristic rules (4th straight
   win for the author). 2nd RHEA_PI (RHEA + learned opponent model, entry 11). 3rd Toothless: minimax + MCTS + rules.
   Of 9 entries, 5 used MCTS in some mix. Organizers: **"60 FPS + introduced delay are challenging factors for MCTS."**
   One entry (TOVOR) simulated in 35-frame steps (ZEN's average action length) against a random opponent.
   The organizers' reference is an "open-loop MCTS" sample.

10. **Team FightingICE. (2020). *2020 Fighting Game AI Competition* [Results slides].**
    https://www.slideshare.net/ftgaic/2020-fighting-game-ai-competition — **T3**
    1st ERHEA_PI (enhanced RHEA + adaptive opponent model, reusing two ReiwaThunder simulation modules); 2nd Tera
    Thunder (predicts the opponent's **three most likely actions**, best response via its own simulator); 3rd
    ButcherPudge (SAC deep RL). Four entries used MCTS with rules or opponent models (e.g. NooBot: sample MCTS + **kNN
    opponent prediction**; Jitwisut: evaluation that detects stun and pursues combos). *Relevance*: by 2020 the top was
    "small opponent prediction (top-k) + best response on a simulator", not wide search.

11. **Tang, Z., Zhu, Y., Zhao, D., & Lucas, S. M. (2020). Enhanced rolling horizon evolution algorithm with opponent
    model learning: Results for the Fighting Game AI Competition. *arXiv:2003.13949*.**
    https://arxiv.org/abs/2003.13949 (read via https://ar5iv.labs.arxiv.org/html/2003.13949) — **T2**
    RHEA on the FightingICE simulator for the full 16.67 ms frame (sequence length 4, population 7, 1 elite, mutation
    0.85), rolled forward from the 15-frame-delayed observation. Opponent model: a **single linear layer** (18 state
    features -> softmax over 56 actions), trained online once per round by cross-entropy (SL), Q-learning or policy
    gradient. Mean win % vs the 2018 FTGAIC bots (GAR / LUD / ZEN): **RHEA 84.5 / 69.6 / 73.4 -> RHEAOM-PG 89.6 / 93.1 /
    87.3**; vs Thunder 89.8 / 89.3 / 76.4. Adding the same opponent models to Thunder also improved it. Reports MCTS bots
    "dominated" FTGAIC from 2016 and that RHEA_PI was the only non-MCTS bot in the 2019 top five. *Relevance*: a tiny
    online-learned opponent policy, refit between rounds, gave +5 to +24 points; the cheapest strong upgrade on record.

12. **Matera, M. R., & Basile, P. (2025). Genetic algorithms and reinforcement learning to develop agents for a fighting
    video game. *Proc. AI4HGI '25 (workshop at ECAI 2025)*, CEUR-WS Vol-4097.**
    https://ceur-ws.org/Vol-4097/paper2.pdf — **T1** (peer-reviewed workshop; full text read)
    GAMCTS: a GA proposes candidate actions, then MCTS (the sample's settings: 16.5 ms, **23 UCT iterations**, C = 3,
    depth 2, threshold 10, 60-frame simulation) picks among them; plus linear Q-learning agents, one a QDagger variant
    with **MCTS as teacher**. GAMCTS beat MCTSAI **90.9 % — but over 11 rounds only**; QDagger vs MCTSAI 54.5 %
    (11 rounds). 20-player user study: the MCTS-taught online learner rated most engaging. *Relevance*: MCTS as the
    teacher of a cheap learned policy (our stage "learning") is being tried; the evidence is thin.

## B. Learned priors and AlphaZero-style attempts in fighting games

13. **Mochida, N., & Nagata, Y. (2021). 自己対戦的手法を用いた格闘ゲームプレイヤの作成 [Creating a fighting game player
    using a self-playing method]. *SICE Intelligent Systems Symposium 2021* (paper 3).**
    https://www.sice.or.jp/org/i-sys/is48/paper/SICE-IS_2021_paper_3.pdf — **T3** (domestic symposium, not peer-reviewed
    to journal standard; full text read)
    AlphaZero-style policy/value net + open-loop search with a **capped tree depth**; the opponent's move in the tree is
    predicted by **kNN**, both sides treated as acting simultaneously. Search took **0.1 s a decision** (input every 6
    frames). **Negative result**: average end-of-match HP score vs MctsAi **−331.8** with search, −305.2 with the raw
    policy; vs Machete −338.6 / −241.1. Authors blame pure self-play (narrow policy) and the slow decision rate.
    *Relevance*: a learned prior trained only by self-play did not beat the 60-frame sample; decision latency matters
    more than search depth in this genre.

14. **Vu, N. Q. (2016). *Building a strong fighting game player* [Master's thesis, JAIST].**
    http://hdl.handle.net/10119/13735 (abstract PDF https://dspace.jaist.ac.jp/dspace/bitstream/10119/13735/4/abstract.pdf) — **T3** (abstract only)
    MCTS + RL on FightingICE: RL predicts promising moves, MCTS searches only those, and the search result is fed back
    to train the RL predictor. Better record than each of the previous year's top four (rule-based) in a 120-round test;
    weak state representation limited it. *Relevance*: the prior-narrows-search / search-trains-prior loop, earliest
    fighting-game instance found.

## C. Simultaneous-move MCTS

15. **Lanctot, M., Wittlinger, C., Winands, M. H. M., & Den Teuling, N. G. P. (2013). Monte Carlo tree search for
    simultaneous move games: A case study in the game of Tron. *BNAIC 2013*.**
    https://dke.maastrichtuniversity.nl/m.winands/documents/sm-tron-bnaic2013.pdf — **T1** (full text read)
    Sequential UCT vs stacked-matrix variants: Decoupled UCT (max / mix), Decoupled UCB1-Tuned, Exp3, and a new Regret
    Matching variant. 100,000 simulations (~1 s) a move, four boards. **DUCB1-Tuned(max) best, 62.3 % overall**; RM
    53.1 %; sequential (turn-taking) trees 51.4–54.3 %; Exp3 clearly worst (e.g. 22–47 % per pairing on board 1).
    *Relevance*: a sequential tree is not far behind; the decoupled gain is a few points, and the "max" (deterministic)
    final pick beat the "mix" pick in a game without much need to randomize.

16. **Tak, M. J. W., Lanctot, M., & Winands, M. H. M. (2014). Monte Carlo tree search variants for simultaneous move
    games. *IEEE CIG 2014*, 232–239. https://doi.org/10.1109/CIG.2014.6932889**
    https://cris.maastrichtuniversity.nl/portal/en/publications/monte-carlo-tree-search-variants-for-simultaneous-move-games(5e4c8118-4db7-49bf-b12d-d16ee90fe167).html — **T1** (abstract only)
    DUCT, Sequential UCT, Exp3 and RM on nine games: the best variant depends on game and opponent, tuning is harder than
    in sequential games, and **"Decoupled UCT performs best despite its theoretical shortcomings."**

17. **Lisý, V., Kovařík, V., Lanctot, M., & Bošanský, B. (2013). Convergence of Monte Carlo tree search in simultaneous
    move games. *Advances in Neural Information Processing Systems 26 (NIPS 2013)*. arXiv:1310.8613.**
    https://arxiv.org/abs/1310.8613 — **T1** (full text read)
    SM-MCTS template with any Hannan-consistent selector plus exploration (RM, Exp3) converges to an approximate
    subgame-perfect Nash equilibrium of the average strategy; UCB selection is excluded because it need not converge
    even in a one-stage game (citing Shafiei et al.). RM and Exp3 converge at similar rates; RM is the default.
    *Relevance*: if we ever want a mixed (unexploitable) reply distribution at a node, RM is the theory-backed choice.

18. **Bošanský, B., Lisý, V., Lanctot, M., Čermák, J., & Winands, M. H. M. (2016). Algorithms for computing strategies
    in two-player simultaneous move games. *Artificial Intelligence, 237*, 1–40.
    https://doi.org/10.1016/j.artint.2016.03.005**
    https://dke.maastrichtuniversity.nl/m.winands/documents/sm-journal.pdf — **T1** (full text read)
    Six games, offline and online. Online head-to-head: convergence speed offline is a poor predictor of play; SM-MCTS
    with **RM is often best and least sensitive to its exploration parameter**, but **UCT wins in games needing less
    randomized strategies**; **Exp3 is weakest** (cost, payoff normalization); a good evaluation function instead of
    random playouts helps every sampler; randomized tie-breaking matters for UCT. With 5× more time the differences
    between samplers shrink.

19. **Yu, K., & Sturtevant, N. R. (2019). Application of retrograde analysis on fighting games. *IEEE Conference on
    Games (CoG 2019)*.** Content read in Yu's thesis version (University of Denver, 2019):
    https://www.readkong.com/page/application-of-retrograde-analysis-to-fighting-games-1546620 ; abstract
    https://www.cs.du.edu/~sturtevant/papers/yu2019retrograde.html — **T1** (paper) / content verified via the thesis
    Simplified Rumble Fish mirror, 5 moves (walk, back step, punch 5 dmg short, kick 10 dmg long, block that beats only
    kick), 20 HP, distances 0–170 px; state = product of both FSMs + HP + spacing; solved by retrograde analysis with an
    LP Nash solve of a 5×5 matrix per state. Despite the RPS-like design the Nash player **mixes under 10 % of the time**
    (max 9.82 %): most states have a dominating move by distance. It beat random, always-punch, always-kick and a
    rule-based agent (95 wins vs rule-based; ε = 0.1 "human error" variant 85). Argues MCTS randomizes poorly in RPS-like
    spots. *Relevance*: in spacing-driven neutral, a deterministic best reply is nearly optimal; mixing matters only at
    the few genuine guess points (wake-up, block vs throw) — exactly where our CPU is exploited.

20. **Goodman, J., & Lucas, S. (2020). Does it matter how well I know what you're thinking? Opponent modelling in an RTS
    game. *IEEE WCCI 2020* (accepted). arXiv:2006.08659.** https://arxiv.org/abs/2006.08659 — **T2** (abstract read)
    Varying opponent-model accuracy in MCTS and RHEA: **RHEA is much more sensitive to model accuracy than MCTS**; MCTS
    does well even with an inaccurate model; at low budget against an unknown opponent, model the opponent inside the
    MCTS tree rather than with an explicit model in RHEA. *Relevance*: supports keeping an explicit opponent level in our
    tree and treating any learned opponent policy as a prior there, not as the truth.

## D. Open-loop search, macro-actions

21. **Perez Liebana, D., Dieskau, J., Hunermund, M., Mostaghim, S., & Lucas, S. (2015). Open loop search for general
    video game playing. *GECCO 2015*. https://doi.org/10.1145/2739480.2754811**
    https://repository.essex.ac.uk/14734/ — **T1** (abstract only)
    Open-loop (store action sequences, re-simulate from the root each iteration) depth-first, bandit tree search and
    RHEA on 29 + 10 GVG-AI games; a general heuristic works across algorithms; RHEA best of the evolutionary methods.
    *Relevance*: the open-loop formulation every FightingICE MCTS (entries 1, 4, 5) cites; needed whenever the model is
    stochastic or the opponent is noise.

22. **Perez, D., Powley, E. J., Whitehouse, D., Rohlfshagen, P., Samothrakis, S., Cowling, P. I., & Lucas, S. M. (2014).
    Solving the Physical Travelling Salesman Problem: Tree search and macro-actions. *IEEE Transactions on Computational
    Intelligence and AI in Games, 6*(1), 31–45. https://doi.org/10.1109/TCIAIG.2013.2263884**
    https://repository.falmouth.ac.uk/2259/ — **T1** (abstract only)
    The controller that won both 2012 PTSP competitions: MCTS over **macro-actions (an action repeated T steps)** to cut
    the real-time search space, with a physics-aware high-level planner. *Relevance*: the general justification for
    our "one node = one committed move until it ends" granularity; FightingICE does the same implicitly (an action runs
    to completion, TOVOR's 35-frame steps).

## Parameter table (as published / as coded)

| Source | Budget a decision | Rollouts | Tree | Rollout length | Opponent in search | Value | UCB C (scale) |
|---|---|---|---|---|---|---|---|
| MctsAi (2018 sample) | 16.5 ms | as many as fit | my actions, depth 2, expand at 10 | 60 frames, full simulator | 5 uniform random actions | HP diff change | 3 (raw HP) |
| MctsAi23i | 16.5 ms | ≤ 23 | same | same | same | same | 3 (raw HP) |
| Yoshida 2016 | 16.67 ms frame | n/a | depth 2, N_max 10 | 60 frames | random | HP diff change | 3 |
| Ishihara 2018 | 16.5 ms | n/a | depth 3, N_max 7 | 60 frames | roulette over human's action frequencies | difficulty + aggression mix | n/a (normalized) |
| Ishii 2018 (PM-MCTS) | n/a | n/a | both characters, event-driven, depth 10, N_max 10 | 60 frames | in the tree (alternating at action starts) | persona evaluation | 0.025 (normalized) |
| Kim & Kim 2017 | 16.6 ms | n/a | sample | sample | top-5 table per distance band × air/ground | HP gap | sample |
| Tang 2020 (RHEA) | 16.67 ms | as many as fit | population 7, length 4 | n/a | linear softmax policy, refit each round | HP-based score | — |
| SOUL DUEL (ours) | ~0.3 ms native | 48 / 96 / 160 | my action -> opp reply after reaction delay | to first contact, light 1-D model | UCB at level 2 | measured outcome values | — |

## Synthesis

**What worked**
- Shallow (depth 2–3), short-horizon (60 frames ≈ 1 s) MCTS on the **real game simulator**, a few dozen rollouts a
  frame: enough to beat rule-based bots and to dominate FTGAIC 2016–2018 (entries 1, 2, 8, 11).
- **Opponent prediction, even crude**: a top-5 action table by distance (86 % vs the sample, entry 3), roulette over
  observed frequencies (entry 4), kNN (entries 10, 13), a linear softmax refit each round (+5 to +24 win points,
  entry 11), top-3 likely actions + best response (Tera Thunder, entry 10).
- **Rules around the search**: prune moves with long end lag at close range, give guard a fixed weight or auto-guard,
  remove useless movement (GigaThunder, Mutagen, entry 8). The champion line eventually dropped MCTS for minimax +
  rules (ReiwaThunder 2019).
- Difficulty and style through the **evaluation** (target HP difference, aggression / believability terms, personas),
  not through injected randomness (entries 4–7).
- In simultaneous-move games generally: **decoupled UCT** empirically best (entries 15–16); RM robust (entry 18).

**What did not**
- Random opponent simulation vs short repeated rule-based patterns (Machete, entry 2) and vs the 2016 winner even
  with an action table (40 %, entry 3).
- Plain MCTS **rarely blocks** (entry 8); the organizers call 60 FPS + 15-frame delay "challenging for MCTS" (entry 9).
- AlphaZero-style self-play net + search at 0.1 s a decision: lost heavily to the sample (entry 13).
- Exp3 in every simultaneous-move comparison (entries 15, 18).

**Open gaps**
- **No published fighting-game MCTS uses an abstract / reduced forward model**; all use the game's simulator, so there
  is no literature number for "light model vs full sim" fidelity loss. Our weak point is unstudied.
- No fighting-game paper applies decoupled / RM selection; the closest (entry 19) suggests mixing matters only at a few
  states.
- Most results are bot-vs-bot on FightingICE's three characters; human-exploit studies (meaties, whiff punish) are
  absent. User studies exist only for DDA / persona believability (entries 4, 5, 12).
- Several key papers (Pinto & Coutinho 2019 HRL + MCTS options, Ishii et al. 2021 highlight cues, Ishihara et al. 2016
  ACE) could not be opened and are excluded below.

## Implications for SOUL DUEL's in-game MCTS

1. **Fidelity: re-score the finalists on the real sim.** The field's baseline wins with ≤ 23 *full-fidelity* rollouts
   (entry 1); we run 48–160 *light* rollouts that are barely better than random vs the full sim at HARD. A hybrid is
   the cheapest test: keep the light tree for ranking, then run k (2–4) short full-sim rollouts (to first contact, the
   sim snapshot / restore already exists for the teacher, DUEL_AI_TEACHER §5) for the top 2–3 root actions and pick
   on those. Measure the per-decision cost first; FightingICE spends the whole 16.5 ms frame.
2. **Put a learned opponent model in level 2.** Replace uniform / UCB opponent replies with a prior per (distance
   band, opponent state: grounded / airborne / waking / recovering) from observed frequencies (entry 3's table, entry
   4's roulette), or a tiny linear softmax refit between rounds (entry 11). Keep the UCB level and mix the prior in as
   PUCT-style weights or a playout distribution, because MCTS tolerates a wrong model better than a fixed belief does
   (entry 20). This is the learning stage's natural first deliverable and the strongest numbers in the literature.
3. **Fix timing exploits outside the search, as the winners did.** Wake-up meaties and whiff punishes are the "MCTS
   rarely blocks" failure (entry 8). Mutagen / LUD answers: a fixed guard weight or forced guard window on wake-up,
   and excluding moves with long recovery at close range. For us: a rule (or fuzzy) gate that forces / weights guard
   or a reversal when the opponent's active frames will overlap our wake-up, and that removes moves whose recovery
   exceeds the opponent's fastest punish at the current distance before the tree is built.
4. **Keep the sequential my -> reply tree; randomize only at guess points.** Decoupled UCT is a few points better in
   Tron (62.3 % vs 51.4–54.3 % for sequential trees, entry 15) and best across nine games (entry 16), but our reply
   level after a reaction delay is genuinely sequential, and a solved fighting game mixes < 10 % of the time
   (entry 19). Where both sides commit inside the reaction window (wake-up, close-range block vs throw), use a small
   decoupled / regret-matching node and sample from its mix (entries 17, 18); elsewhere pick the deterministic best.
5. **Difficulty via the evaluation and the root pick, not via a worse model.** EASY / NORMAL can choose the child
   whose value is nearest a target margin, or blend an aggression term (entries 4, 7); HARD takes the max. This keeps
   the CPU believable (no repeated whiffs) while weaker, which noise injection does not.
6. **Mirror the delay explicitly.** FightingICE models reaction as a 15-frame-late state plus a 14-frame null
   simulation before searching (entry 1). State our reaction delay in those terms and make sure the opponent node's
   reply is chosen from what the CPU could have seen, or the tree will "react" faster than the rule our CPU policy
   already forbids (a reaction slower than the threat never fires).

## Excluded (could not be opened; not cited above)

- HRL + MCTS-as-options on FightingICE, *IEEE Transactions on Games* 11(3), 2019 (IEEE page empty; authorship unconfirmed).
- Ishii, Fujimaki & Thawonmas (2021), fighting-game gameplay generation using highlight cues, *IEEE ToG* (no full text).
- Ishihara, Miyazaki, Chu, Harada & Thawonmas (2016), applying and improving MCTS in a fighting game AI, ACE 2016.
- Kim & Ahn (2018), hybrid GA + MCTS fighting game AI, GECCO companion (only its later use in entry 12 was read).
- "FighterZero" slides (fetch failed); Shafiei, Sturtevant & Schaeffer, UCT vs CFR in simultaneous games (404; cited
  only through entry 17); a CNN + DQN + MCTS FightingICE paper and a Hosei thesis whose numbers appeared only in search
  summaries.
