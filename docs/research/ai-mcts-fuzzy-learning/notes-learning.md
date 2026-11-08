# Learning AI for fighting games: annotated bibliography and notes

Scope: opponent modelling, online adaptation / DDA, human-like play, RL agents, and shipped learning CPUs, read
for SOUL DUEL's planned learning layer (DUEL_AI_MCTS): (1) offline correction of the light MCTS model's action values
from full-sim data; (2) an online model of the human's habits used as the MCTS opponent model, kept across matches in
the browser. Collected 2026-11-08.

Verification rule: every entry below was opened (full text, or the abstract page where marked). The depth column says
which. Anything seen only in a search snippet is in "Excluded" at the end and is not used in the synthesis.

Tiers: **T1** peer-reviewed (conference / journal), **T2** preprint, **T3** blog / talk / product page.

## 1. Opponent modelling in fighting games

**[1] Kim, M.-J., Kim, K.-J. (2017). "Opponent Modeling based on Action Table for MCTS-based Fighting Game AI."**
3-page conference paper, Sejong University (index sites list IEEE CIG 2017; not confirmed on a page we could open).
https://cilab.gist.ac.kr/hp/wp-content/uploads/publications/international_conference/2017/opponent_modeling_based_on_action_table_for_mcts-based_fighting_game_ai.pdf
— **T1, full text.** FightingICE MCTS entries simulated only 5 random opponent actions because of the 16.6 ms budget.
They replace those with a per-opponent *action table*: the top-5 most frequent opponent actions in each of 6 buckets
(3 distance ranges x air / ground); the top 5 cover about 70% of the actions observed. Update **once per round**: the
round's most frequent actions either move up one rank or replace the lowest-ranked entry, **at most 2 entries change
per update** ("to minimize forgetting effect"). Cold start: a default table built from 100 games of a random AI against
each of the previous year's top three. Over 200 games (600 rounds) per opponent: 86% wins vs the basic MCTS sample,
76% vs the 2016 runner-up, 40% vs the 2016 winner. Relevance: the closest published analogue to our plan (frequency
table by situation feeding MCTS opponent moves), and it fits a tiny budget.

**[2] Yamamoto, K., Mizuno, S., Chu, C. Y., Thawonmas, R. (2014). "Deduction of Fighting-Game Countermeasures Using the
k-Nearest Neighbor Algorithm and a Game Simulator." Proc. IEEE CIG 2014, pp. 437–441.**
https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/ieeeCIG2014.pdf — **T1, full text.** MizunoAI: records every opponent
attack at its relative (x, y), mirrored to the facing direction, in 4 sets (ground/air x ground/air). If at least
`numAct` past attacks lie within `distThreshold` (40) of the current relative position, k-NN votes the predicted attack,
then a 1 s (60-frame) forward sim of each of 24 own actions against it picks the best damage difference; otherwise it
crouch-guards. 100 matches per k (1–11) vs the 2013 top three: beats all (best totals 1816 / 1869 / 1889 of 3000).
It **loses Round 1** to two of them at some k (no data yet) and recovers in rounds 2–3; the best k differs per
opponent. Relevance: per-situation memory of the opponent + forward-sim counter; documents the cold-start cost.

**[3] Tang, Z., Zhu, Y., Zhao, D., Lucas, S. M. (2020). "Enhanced Rolling Horizon Evolution Algorithm with Opponent
Model Learning: Results for the Fighting Game AI Competition." arXiv:2003.13949.**
https://arxiv.org/abs/2003.13949 (details from https://ar5iv.labs.arxiv.org/html/2003.13949) — **T2, full text.**
RHEA planning with an opponent model that is a **single linear layer + softmax** (18 inputs: HP, energy, positions,
one-hot states, relative distance; 56 outputs, one per action); MLP and LSTM did worse. Trained **once at the end of
each round** on that round's data (cleared each round) to protect the per-frame budget; SL (cross-entropy), Q-learning
and policy-gradient variants. Mean win rate vs the 2018 bots (GAR / LUD / ZEN): plain RHEA 84.5 / 69.6 / 73.4, with
the PG model 89.6 / 93.1 / 87.3; a *random* opponent model drops ZEN to 50.6. 2nd in FTGAIC 2019 (score 122 vs 133),
the only top-5 bot without MCTS. Relevance: a tiny opponent model learned between rounds measurably helps a planner;
a wrong model hurts.

**[4] Thunputtarakul, W., Kotrajaras, V. (2007). "Data Analysis for Ghost AI Creation in Commercial Fighting Games."**
Venue per the reference list of [5]: GAME-ON 2007, Bologna.
https://www.cp.eng.chula.ac.th/~vishnu/gameProg/papers/wpj_vishnu07.pdf — **T1, full text.** Ghost AI for Street
Fighter Zero 3 (emulator testbed). Each frame where the player's animation set changes, the previous situation is
**packed into a 32-bit integer** (own state, distance in 9 bands, air/ground, opponent state, projectile, damage,
facing, corners) and stored with a ratio-weighted list of next actions. About 40 B per case, 1,000 cases = 40 KB,
O(log n) lookup; ~4 KB of log per minute; 180 cases after 2 min, 350 after 10. With 32 players: ghost-vs-player input
similarity 26.33% against a player-vs-own-replay ceiling of 34.96% ("75.31% close"); players rated likeness 72.2%.
Pitfalls they report: **"not doing anything" is never recorded** (a ghost that air-recovers 1 time in 10 does it every
time), and ghosts **do not unlearn** a changed style. Relevance: a working, tiny situation-key table; both pitfalls
apply directly to dodge / guard habits.

**[5] Lueangrueangroj, S., Kotrajaras, V. (2009). "Real-Time Imitation Based Learning for Commercial Fighting Games."**
Venue per the reference list of [2]: CGAT 09.
https://www.cp.eng.chula.ac.th/~vishnu/gameProg/papers/CGAT_Real%20Time%20Imitaion%20Based%20Learning.pdf —
**T1, full text.** Adds online learning to [4]: each imitated action has a frequency (imitation) and a weight
(dynamic scripting, updated when damage is dealt or taken); the pick mixes them, `Pa = Pw + C (Pf − Pw)`, C = 0.1.
9 players x 10 matches: players out-learned the plain ghost (its damage taken rose over time); the learning ghost's
results swung but stayed closer; players rated it more clever and human-like. No statistics. Relevance: pure imitation
is exploitable within a match; a small reward-driven reweighting on top of frequencies helps.

**[6] Thompson, T. (2017-10-13). "The Killer Groove: The Shadow AI of Killer Instinct." Game Developer.**
https://gamedeveloper.com/programming/the-killer-groove-the-shadow-ai-of-killer-instinct — **T3, full text.**
Shadow AI (Iron Galaxy, 2015): logs every action plus match state; a parser turns inputs into higher-level patterns
(setups, zoning, combos, counters), 400–700 patterns per match; three dojo matches give basic competence. Case-based
reasoning: nearest-neighbour retrieval over **40+ hand-designed metrics**, stored relative to the opponent; ranked by
value, occasionally picks a lower-ranked option to bluff; **re-ranks a tactic that keeps getting punished** during the
match. Up to 40 matches per shadow per opponent (up to 28,000 patterns). Limits: the metrics need an expert designer;
behaviours need repeated observations; the developer said 40 matches can be too few. Relevance: the commercial
reference for "learn the player, by situation, per matchup".

**[7] Hayles, B., Neal, D. (2016). "Designing AI for Competitive Games." GDC 2016.**
https://gdcvault.com/play/1022992/Designing-AI-for-Competitive — **T3, session listing only** (Shadow AI as the case
study). Cited only as the primary talk behind [6]; no content claimed from it.

**[8] Thompson, T. (2021-06-01). "How Forza's Drivatar Actually Works." Game Developer.**
https://www.gamedeveloper.com/design/how-forza-s-drivatar-actually-works — **T3, full text.** Adjacent genre. Original
Drivatar (MSR Cambridge, 2005): a small Bayesian neural net on the owner's console, generalised poorly. v2 (2013,
cloud): tracks split into 12 turn types and segments, data per race / segment / turn, **timestamped with older data
weighted less**; **rewinding discards that corner's training** (anti-gaming); a **designer layer** sits between the
learned model and the controller (suppresses aggression, donuts, collisions). Lesson stated: learned imitation copies
the owner's flaws and needs curation. Relevance: recency decay, anti-exploit rules, and a curation layer over a
persisted per-player model.

**[9] Yuda, K., Kamei, S., Tanji, R., Ito, R., Wakana, I., Mozgovoy, M. (2021). "Identification of Play Styles in
Universal Fighting Engine." arXiv:2108.03599.** https://arxiv.org/abs/2108.03599 — **T2, full text.** A player's
"behaviour fingerprint" = probabilities of every **action trigram** (three consecutive actions), compared by cosine
similarity. Humans are self-consistent across matches (90%+ typical) while different players score 44–65%. A
Turing-style video survey (14 subjects, 4 clips): 37% correct, 41% wrong, the rest "not sure", i.e. observers could not
tell AI from human. Relevance: the only n-gram-style measure we could open; usable as a cheap human-likeness metric for
our CPU vs recorded human play.

## 2. Online adaptation and dynamic difficulty adjustment

**[10] Andrade, G., Ramalho, G., Santana, H., Corruble, V. (2005). "Challenge-Sensitive Action Selection: an
Application to Game Balancing." Proc. IEEE/WIC/ACM IAT 2005. DOI 10.1109/IAT.2005.52.**
Full text read from a third-party copy (https://docdrop.org/static/drop-pdf/01565536-7Y668.pdf). — **T1, full text.**
Q-learning fighter in Knock'em (13 actions), trained offline vs a random agent, keeps learning online (alpha 0.5,
gamma 0.9). DDA by **rank of the action value**: start at the 6th-best action; every **100 game cycles** a challenge
function on life difference (easy: agent behind; medium: within 10 of 100; else hard) moves it one rank up or down,
about 10 adjustments per fight. Over 30 fights each vs a state machine, random, and a trained RL agent, the adaptive
agent's mean life difference is not significantly different from zero against all three, while the plain RL agent
beats the first two (means 52.5, 55.5). Relevance: a cheap, deterministic difficulty knob on top of any action ranking
(our MCTS values), evaluated on a fixed cycle rather than per step.

**[11] Demediuk, S., Tamassia, M., Raffe, W. L., Zambetta, F., Li, X., Mueller, F. (2017). "Monte Carlo Tree Search
Based Algorithms for Dynamic Difficulty Adjustment." Proc. IEEE CIG 2017, pp. 53–59. DOI 10.1109/CIG.2017.8080415.**
https://opus.lib.uts.edu.au/handle/10453/127485 — **T1, abstract only, no numbers.** Four MCTS DDA agents in
FightingICE (Reactive / Proactive Outcome-Sensitive Action Selection and "True" variants) that change MCTS action
selection and playout evaluation to aim for equal health. Tested vs AIs and humans. Reports a trade-off: exact outcome
targeting (Reactive) vs proactive play that also fights when level, argued to be more believable.

**[12] Ishihara, M., Ito, S., Ishii, R., Harada, T., Thawonmas, R. (2018). "Monte-Carlo Tree Search for Implementation
of Dynamic Difficulty Adjustment Fighting Game AIs Having Believable Behaviors." Proc. IEEE CIG 2018.**
https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-ishihara.pdf (videos: https://www.ice.ci.ritsumei.ac.jp/~ruck/dda-cig2018.htm)
— **T1, full text.** Their earlier DDA MCTS (eAI) evened HP by **unnatural actions** (repeated no-hit attacks,
standing still to take damage). BEAI adds a believability term (damage dealt) to the UCT evaluation, blended by
`alpha = f(tanh(HP difference))`: aggressive when level, more aggressive when losing. 38 subjects in 3 skill groups (k-means
on HP difference vs a fixed MCTS AI), metric AHDTG (mean |HP difference| over all frames) plus a 6-item questionnaire.
BEAI tracks beginners and intermediates significantly better (Friedman p = .006, .017); intermediates rate its
believability significantly higher (p = .042); **experts exploited its aggression** with counters, so it tracked them
worse. No significant difference in positive affect. Relevance: the DDA failure mode to avoid (visible throwing) and a
frame-level metric we can compute in the native sim.

**[13] Spronck, P., Ponsen, M., Sprinkhuizen-Kuyper, I., Postma, E. (2006). "Adaptive Game AI with Dynamic Scripting."
Machine Learning 63, 217–248. DOI 10.1007/s10994-006-6205-6.**
https://cris.maastrichtuniversity.nl/en/publications/adaptive-game-ai-with-dynamic-scripting — **T1, abstract only, no
numbers.** Adjacent genre (RPG; shipped in Neverwinter Nights). Online learning from an adaptive rulebase; states four
computational (speed, effectiveness, robustness, efficiency) and four functional (clarity, variety, consistency,
scalability) requirements for online game learning; a difficulty-scaling enhancement meets all eight. Relevance: a
checklist for our online learner, and the weighting scheme [5] reused.

## 3. Human-like and believable play

**[14] Lu, F., Yamamoto, K., Nomura, L. H., Mizuno, S., Lee, Y. M., Thawonmas, R. (2013). "Fighting Game Artificial
Intelligence Competition Platform." Proc. IEEE GCCE 2013, pp. 320–323.**
https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/gcce13-lu.pdf — **T1, full text.** FightingICE sends game data to AIs
**15 frames late** "to give more risks to the defense play style and simulate the reaction delay of human" (0.25 s per
[2]). Relevance: the research platform's fixed perception delay, one reference point for our per-difficulty delays.

**[15] Mendonça, M. R. F., Bernardino, H. S., Fonseca Neto, R. (2015). "Simulating Human Behavior in Fighting Games
Using Reinforcement Learning and Artificial Neural Networks." SBGames 2015. DOI 10.1109/SBGAMES.2015.25.**
https://microsoft.com/en-us/research/?p=871011 — **T1, abstract only, no numbers.** Two routes to a human-like fighter:
RL with a reward designed to encode human-like behaviour, and an ANN trained on a human's recorded fights; claimed
more enjoyable than two RL baselines.

(See also [4], [5], [9], [12] for the human-likeness measures actually reported: input-similarity vs own replay,
self-rated likeness, trigram fingerprint, observer guess rate, questionnaire believability.)

## 4. RL fighting agents

**[16] Graepel, T., Herbrich, R., Gold, J. (2004). "Learning to Fight." Proc. Int. Conf. on Computer Games: AI, Design
and Education, pp. 193–200.** https://www.cp.eng.chula.ac.th/~vishnu/gameResearch/AI_August_2005/graehergol04.pdf
(listing: https://www.microsoft.com/en-us/research/publication/learning-to-fight/) — **T1, full text.** SARSA with a
linear (and a 3-hidden-unit NN) Q-function in Tao Feng (Xbox). 15 features (distance as 3 Gaussians at 1/3/5 m,
4 wall flags, 6 bits of the opponent's previous action, opponent airborne / knocked down); macro-actions such as
`block25` (hold 25 frames) because single frames do nothing. **Softmax (Gibbs) policy with temperature beta**;
alpha 0.01, gamma 0.8; ~30,000 episodes. beta = 2 gets stuck defensive; beta = 1 explores and finds a winning policy
around episode 30,000. Reward weights shape style (aggressive 0.7 dHopp − 0.3 dHself vs "aikido"). Found exploits in
the built-in AI. They name timing as poorly captured by the MDP and suggest separate models of engine and opponent plus
search. Relevance: tiny linear RL is enough to bend values; reward weights give styles; softmax temperature is the
same knob we use.

**[17] Oh, I., Rho, S., Moon, S., Son, S., Lee, H., Chung, J. (2019). "Creating Pro-Level AI for a Real-Time Fighting
Game Using Deep Reinforcement Learning." arXiv:1904.03821 (v3, 2020).** https://arxiv.org/abs/1904.03821 — **T2, full
text.** Blade & Soul 1v1 (NCSOFT). LSTM agents, 10 decisions/s (1,800 steps = 3 min); three styles (aggressive /
balanced / defensive) by reward shaping, self-play from a **shared opponent pool**; each of six agents trained 5M steps
(~6 days). "Data skipping": dropping passive no-op frames reached 80% win rate vs the built-in AI in 70k steps instead
of 170k. **An average 230 ms delay was added to every AI decision** to match pro reaction time. 62% wins vs five pros;
3 of 7 at the 2018 World Championship blind match; testers said the aggressive agent gave no breaks between exchanges.
Relevance: the reaction-delay figure and the "style by reward" idea transfer; the training scale does not.

**[18] Takano, Y., Ouyang, W., Ito, S., Harada, T., Thawonmas, R. (2018). "Applying Hybrid Reward Architecture to a
Fighting Game AI." Proc. IEEE CIG 2018. DOI 10.1109/CIG.2018.8490437.**
https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-takano.pdf — **T1, full text.** DQN with two heads (offense,
defense) on a decomposed reward, trained 1,400 rounds vs Machete; beat the single-head DQN and placed 4th of 13 in the
2018 Standard League. Relevance: separate value components for offense / defense are a cheap way to keep values
interpretable for correction.

**[19] Nguyen, T. V., Dai, X., Khan, I., Thawonmas, R., Pham, H. V. (2022). "A Deep Reinforcement Learning Blind AI in
DareFightingICE." IEEE CoG 2022; arXiv:2205.07444.** https://arxiv.org/abs/2205.07444 — **T1, full text.** PPO + GRU
on sound only (1D-CNN / FFT / Mel encoders), trained 900 rounds vs a weakened MCTS AI (6.5 ms); evaluated over 90
rounds: Mel encoder 0.63 win ratio, +37 HP. Relevance: small-scale PPO on FightingICE needs hundreds of rounds to beat
a modest MCTS; little transfers to an in-browser CPU.

**[20] Palmas, A. (2022). "DIAMBRA Arena: a New Reinforcement Learning Platform for Research and Experimentation."
arXiv:2210.10595.** https://arxiv.org/abs/2210.10595 — **T2, full text.** Gym-compatible emulated commercial fighters
(Dead or Alive++, Tekken Tag, Street Fighter, ...), 1P / 2P, self-play, human-demo recording. Demo agents: PPO with
10M / 25M / 50M steps. Relevance: scale reference only; tens of millions of steps per character is out of reach for
per-player learning.

**[21] Sony / Polyphony Digital. "Gran Turismo Sophy: project." gran-turismo.com.**
https://www.gran-turismo.com/us/gran-turismo-sophy/project/ — **T3, product page.** Adjacent genre. Deep RL trained
on cloud PlayStation infrastructure; Race Together (2021-10-21) won 104–52 vs top drivers. The algorithm, control rate
and reaction limits are in the Nature paper (2022, DOI 10.1038/s41586-021-04357-7), which we could not open; none of
those details are used here.

## Synthesis

### What worked

- **Situation-bucketed frequency tables** are the working pattern for opponent models at small budgets: 6 buckets x
  top-5 actions [1], 4 position sets + k-NN on relative position [2], a 32-bit situation key + ratio list [4],
  40+-metric nearest neighbour [6], turn types x segments [8]. All key on relative geometry plus air/ground/state.
- **Feeding the model into search** beats a uniform opponent: [1] (86% wins vs the basic MCTS), [3] (ZEN mean win rate 73.4 → 87.3%),
  while a wrong model hurts ([3]'s random model, 50.6%).
- **Update between rounds, small steps**: once per round, at most 2 entries change [1]; train at round end [3]. Learning
  inside the frame is avoided by everyone who reports a budget.
- **Difficulty by moving down the value ranking** on a fixed evaluation cycle [10], or by blending an evenness term
  into the search evaluation [11, 12]. Both reuse the existing value estimates.
- **Human-likeness constraints that are cheap**: a fixed perception / decision delay (15 frames [14]; 230 ms [17]),
  softmax temperature [16], an occasional lower-ranked pick as a bluff [6], style by reward weights [16, 17].
- **Measurement**: AHDTG [12] and trigram fingerprints [9] can be computed offline from logs; player-rated likeness
  [4] and Friedman tests over small groups [12] are the human side.

### Limits

- Cold start: with no data, k-NN loses Round 1 [2]; [1] needs a population prior; KI needs 3 matches, more for full
  behaviour [6].
- Pure imitation is exploitable within a match [5] and copies flaws [8]; ghosts never unlearn [4]; "doing nothing" is
  invisible to an action logger [4].
- DDA that is visible reads as throwing [12]; experts exploit a predictable adaptive AI [12].
- Hand-designed situation features carry the method (KI's 40 metrics need an expert [6]).
- Deep RL results need millions of steps and days of compute per agent [17, 19, 20]; nothing reported is per-player.

### Gaps

- No opened source for an n-gram fighter or an open-source learning fighting CPU on GitHub; [9]'s trigram fingerprint
  is the nearest. Tekken / Virtua Fighter ghost internals are undocumented in sources we could open.
- No study of persisting a per-player model across sessions in a fighting game beyond KI's 40-match cap [6] and
  Drivatar's recency weighting [8]; no published numbers on how fast a player model goes stale.
- No paper combines an online habit model with an *offline-corrected* MCTS value model; [1] and [3] are the closest.
- Human-likeness constraints of GT Sophy are not verified here (paywalled).

## Implications for SOUL DUEL

1. **Key the habit table on a fixnum-sized situation code, store integer counts.** [4] packs a situation into 32 bits
   at ~40 B per case; our fixnums are 30-bit on wasm32, so the key must fit 29 bits (or be split into two fields).
   Buckets like [1]/[2] (distance band, air/ground, own and opponent state, facing) and integer counts per (bucket,
   response: dodge / guard / turn / attack / nothing) keep the hot path free of floats; probabilities are only formed
   (count / total) at decision time, or as fixed-point.
2. **Update the model between rounds, and treat the loaded table as match input.** Follow [1] and [3]: accumulate
   counts during the round, fold them into the persistent table only at round / match end, with a bounded change per
   update. Inside the step the table is read-only. The table loaded from browser storage becomes an input to the
   deterministic sim: snapshot it at match start, include it (or its hash) in the replay / state-hash header, and give
   the native sim and the gates either the same table or a fixed neutral prior, or native-vs-browser hashes will drift.
3. **Cold start = population prior + fallback.** Seed every new player's table from CPU-vs-CPU or pooled data (as [1]
   seeded from previous champions), blend the player's counts in as they accumulate (count-weighted), and fall back to
   the current generic behaviour when a bucket has fewer than N samples (as [2] guards below `numAct`).
4. **Record "did nothing", and decay old data.** For dodge / guard / turn habits, "did not dodge when they could" is the
   signal; log the opportunity, not only the action ([4]'s pitfall). Contrast: [17] dropped no-op frames for RL sample
   efficiency, which is the opposite need. Add recency decay (halve counts per K matches, or cap totals) since ghosts
   never unlearn [4] and Drivatar weights older data less [8]; KI-style re-ranking of punished tactics [6] is the
   in-match version.
5. **Calibrate reaction delays against the published numbers.** 230 ms ≈ 14 frames at 60 Hz matched pros in [17];
   FightingICE uses 15 frames [14]. Our HARD delay should sit near that floor; EASY / NORMAL longer. Keep the delay
   fixed per difficulty (deterministic), and keep the bluff / softmax randomness on `sim-rnd01` rolled once per event.
6. **Guard against players training the model and against visible throwing.** Drivatar discards data the player can
   game (rewinds) and filters the learned model through a designer layer [8]; experts exploited [12]'s predictable
   aggression. Ideas: ignore practice-mode / paused / debug inputs for the persistent table, cap how far the opponent
   model can bend an MCTS value, and adjust difficulty on a fixed cycle by value rank [10] or an evenness term [12]
   rather than by visibly bad actions. Measure with AHDTG [12] in the native sim.

## Excluded (could not open, or only seen in a search snippet)

- Andrade et al. (2006) "Dynamic Game Balancing: an Evaluation of User Satisfaction", AIIDE (AAAI OJS returned 520).
- Andrade et al. (2005) "Extending Reinforcement Learning to Provide Dynamic Game Balancing" and the AAMAS 2005 paper
  (HAL pages blocked).
- Saini, Dawson, Chung (2011) "Mimicking Player Strategies in Fighting Games" and Saini's 2014 thesis (403).
- Oh et al.'s IEEE Transactions on Games (2022) version of [17] (seen only in a library index).
- GT Sophy Nature paper details (paywalled).
- Tekken 8 "Super Ghost" Q-learning claim (pre-release coverage only).
- Chu and Thawonmas, fuzzy control for k-NN cold start, CIG 2014 (slides seen in search only).
- Ishii et al. (2018) MCTS fighting AIs with personas; Ishihara et al. (2016) applying and improving MCTS (not opened).
