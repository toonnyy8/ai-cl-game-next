# Fuzzy inference for fighting-game and action-game AI: annotated bibliography (2026-11-08)

Scope: what the literature and the public implementations did with fuzzy logic in game agents: fuzzy reactive layers in
fighting games, fuzzy rules tuned by evolution or reinforcement, fuzzy evaluation inside a search, practical design advice
(set counts, rule explosion, defuzzification cost), and fuzzy difficulty adjustment or believable behaviour. Written for
SOUL DUEL's CPU (`duel/lisp/fuzzy.lisp`, DUEL_AI_MCTS stage 1). The CPU has (a) a reactive layer, which is zero-order
Sugeno rules over visible cues (distance, the opponent's move class and frame, gauges) whose output is a chance rolled once
per event and scaled by difficulty; (b) a fuzzy position score for MCTS rollouts that end without contact. Later the
outputs will be learned, offline from the sim and online from the player.

Rule: every entry was opened, as the paper text, the authors' slides, an abstract or record page, or the docs or code.
Each entry says how much was read: **full text**, **abstract / record only** or **slides only**.
Tiers: **T1** peer-reviewed (journal or conference); **T2** preprint (the arXiv version was read); **T3** slides, docs,
lecture notes, a book chapter, a vendor paper.

## A. Fuzzy agents in fighting games (FightingICE)

1. **Chu, C. Y., & Thawonmas, R. (c. 2015). *Applying fuzzy control in fighting game AI* [Slides]. Intelligent Computer
   Entertainment Lab, Ritsumeikan University.**
   https://www.slideshare.net/slideshow/applying-fuzzy-control-in-fighting-game-ai/47222862 (**T3, slides only**)
   The fuzzy layer fixes the cold start of MizunoAI, a k-NN opponent predictor. It has two inputs: `oppData` (how many of
   the opponent's actions are recorded, sets *insufficient* / *sufficient* over roughly 0–20) and the horizontal distance
   (*close* / *far* over roughly 0–360). There are **4 single-antecedent rules**: use k-NN or the rule base, and a close
   or a far attack. **Defuzzification is skipped: the memberships are used directly as the probabilities of a weighted
   random choice.** For example, oppData = 6 gives k-NN : rules = 1 : 9, and oppData = 13 gives 8 : 2. Test: 200
   three-round games on FightingICE 1.02 (KFM, k = 3). Against the crisp version (thresholds oppData 10, distance 60),
   the fuzzy one went **129 / 3 / 68 (W/D/L) in round 1**, 67 / 70 / 63 in round 2 and 83 / 52 / 65 in round 3. Against
   the original MizunoAI it went 174 / 0 / 26 in round 1. *Relevance:* the closest published match to our design (few
   sets, single-antecedent rules, membership read as a chance). Fuzzy beats crisp thresholds mostly where the crisp
   edge sits.

2. **Kanetsuki, Y., Thawonmas, R., & Nakata, S. (2015). Optimization and simplification of dynamic scripting with
   evolution strategy and fuzzy control in a fighting game AI. *Proc. IEEE 4th Global Conference on Consumer
   Electronics (GCCE)*, 330–331. https://doi.org/10.1109/GCCE.2015.7398536** (**T1, abstract only**)
   Record: https://search.isc.ac/inventory/49/3740844.htm. The paper improves CodeMonkey, a dynamic-scripting FightingICE
   AI. A **(1+1)-ES with the one-fifth rule** tunes its parameters, and fuzzy control supplies extra action rules. The
   result beats the original CodeMonkey without the hand-set parameters or the complex rule set. The abstract gives no
   numbers. *Relevance:* the cheapest offline tuner that has been shown to work on fuzzy rules in a fighting game.

3. **Zhang Yuqi (2020). *Fuzzy_ZYQAI* [Competition entry], in *2020 Fighting Game AI Competition* [Organizers'
   slides].** https://www.slideshare.net/ftgaic/2020-fighting-game-ai-competition (**T3, slides only**)
   This entry combines fuzzy control with an FSM. Its inputs are distance (x, y) and energy, through Gaussian-like
   low / middle / high sets, combined into a 0–1 "feeling value". A rule base maps that value to **action probabilities,
   and the action is drawn by weighted random** (nested switch statements). It plays ZEN only. The only claim is that it
   is better than the author's earlier FSM-only AI. It is not in the top 3 (ERHEA_PI, Tera Thunder, ButcherPudge).
   *Relevance:* a second instance of "fuzzy output = a chance", and a reminder that a hand-built fuzzy layer alone did
   not compete with search bots.

4. **Ishihara, M., Ito, S., Ishii, R., Harada, T., & Thawonmas, R. (2018). Monte-Carlo tree search for implementation
   of dynamic difficulty adjustment fighting game AIs having believable behaviors. *Proc. IEEE CIG 2018*.**
   https://www.ice.ci.ritsumei.ac.jp/~ruck/PAP/cig2018-ishihara.pdf (**T1, full text; ADJACENT: not fuzzy**)
   This is MCTS on FightingICE. Its rollout reward is `E = 1 − tanh(|HPmy − HPopp| / Scale)`, which aims at an HP
   difference near 0. A believability term `B = tanh((HPopp,before − HPopp,after) / Scale)` rewards aggression. The two
   are mixed by `eval = (1 − α)B + αE`, where **α = (tanh(ΔHP / Scale) + 1) / 2**. The CPU leans on difficulty adjustment
   when ahead, on aggression when behind, and 0.5 / 0.5 when even. The test had 38 subjects. The average HP difference
   was lower than two DDA baselines for beginners and intermediates (Friedman p < .01 / .05). Experts exploited the
   aggression. *Relevance:* α is a smooth, two-set membership blend of two objectives in an MCTS evaluation, which is
   the closest published thing to a "fuzzy evaluation" in fighting-game MCTS. It also names the believability failure
   that plain HP-balancing produces: the CPU fills the HP gap on purpose and repeats whiffs.

## B. Learning or tuning the fuzzy rules in game agents

5. **Glorennec, P. Y., & Jouffe, L. (1997). Fuzzy Q-learning. *Proc. 6th IEEE Int. Conf. on Fuzzy Systems*, vol. 2,
   659ff. https://doi.org/10.1109/FUZZY.1997.622790** (**T1, abstract only**)
   Record: https://search.isc.ac/inventory/49/2453571.htm. This paper adapts Watkins' Q-learning to a fuzzy inference
   system, with **both the actions and the Q-values inferred from fuzzy rules**. Each rule holds candidate consequents
   with q-values, and the firing strengths share the TD update. On cart-centering it is compared with a GA and reported
   effective. *Relevance:* this is the textbook route for "learn the consequent of each rule online". The update is
   strength-weighted, so it fits zero-order Sugeno directly.

6. **Shi, L., Jinyi, Y., Zhen, Y., & Zengqi, S. (2001). Multiple rewards fuzzy reinforcement learning algorithm in
   RoboCup environment. *Proc. IEEE CCA 2001*, 317–322. https://doi.org/10.1109/CCA.2001.973884** (**T1, abstract only**)
   Record: https://search.isc.ac/inventory/49/2062053.htm. Multi-reward fuzzy Q-learning for a RoboCup team. Several
   reward signals are combined by a **Takagi–Sugeno model** into one TD feedback. The abstract reports better learning
   efficiency and reconciled short- and long-term goals, but no numbers. *Relevance:* a fuzzy combiner of several
   reward terms, much like combining damage, position and gauge terms in our rollout score.

7. **Salem, M., Mora, A. M., Merelo, J. J., & García-Sánchez, P. (2018). *Evolving a TORCS modular fuzzy driver using
   genetic algorithms* [Slides].** https://www.slideshare.net/fergunet/ipmu-torcs (**T3, slides only**; the paper,
   EvoApplications 2018, https://doi.org/10.1007/978-3-319-77538-8_24, could not be opened)
   The driver is a Mamdani system with trapezoidal sets (High / Medium / Low). Its inputs are the front distance and two
   mid sensors (M5, M10), and its outputs are target speed and steering. There are **8 + 7 = 15 rules**. A real-coded GA
   tunes the membership functions: population 20 or 50, **50 generations**, crossover 0.7, mutation 0.3, 20 runs, trained
   on one track. Against the hand-tuned fuzzy driver, damage dropped to 0 in practice runs, and one variant gained top
   speed. In 5-lap races it placed 2nd on the known track and 3rd / 4th on unseen ones. The slides give no lap times.
   *Relevance:* a GA on breakpoints only, with the rules kept fixed, is enough to beat the hand-tuned version. The
   authors flag that the fitness function is the hard part.

8. **Ernest, N., Carroll, D., Schumacher, C., Clark, M., Cohen, K., & Lee, G. (2016). Genetic fuzzy based artificial
   intelligence for unmanned combat aerial vehicle control in simulated air combat missions. *Journal of Defense
   Management, 6*(1), 144. https://doi.org/10.4172/2167-0374.1000144** (**T1 with a caveat, full text**)
   Open copy: https://scholar.uc.edu/concern/articles/bc386t25c. The **Genetic Fuzzy Tree (GFT)** is many small FISs
   cascaded. For example, a two-tier threat branch has layer 1 (distance, altitudes → effective range) and layer 2
   (effective range, azimuth, turn rate → defensiveness). A GA trains every FIS in the tree at once. Breaking the
   problem into sub-decisions shrinks the search space, and the authors' stated cost is missed coupling between the
   pieces. Known optimal sub-solutions and plain heuristics sit beside the FISs. The authors report **154 Hz, 6.5 ms a
   full decision cycle for four aircraft on one 3.2 GHz core**, with most of that time spent on I/O, and transparency of
   the active rules for verification. A retired USAF colonel called a preliminary version the most credible AI he had
   seen. Caveat: OMICS journal, and the timing and performance claims are the authors' own. *Relevance:* this is the
   structural answer to rule explosion: chain small 2–3-input rule bases instead of one big table, and tune them jointly.

9. **Heinze, M., Ortiz-Arroyo, D., Larsen, H. L., & Rodriguez-Henriquez, F. (2005). Fuzzeval: A fuzzy controller-based
   approach in adaptive learning for backgammon game. *MICAI 2005, LNAI*, 224–233.**
   https://vbn.aau.dk/ws/files/77725705/MICAI05.pdf (**T1, full text of the authors' pre-print**)
   Listed in §C as well. The **online learning** is simple: after a match, every adjustable triangular membership
   function is moved toward the **average crisp input seen on the boards of won games**. *Relevance:* a cheap,
   interpretable online update ("re-centre the sets on what wins"), and the only verified game example of learning fuzzy
   sets from play.

10. **Hostetter, J. W., & Chi, M. (2025, v2 2026). Gradient-based neuroplastic adaptation for the concurrent optimization
    of neuro-fuzzy networks. arXiv:2506.21771.** https://arxiv.org/abs/2506.21771 (**T2; read the method overview, §5–6
    results and tables, not the whole text**)
    This trains both the structure (which rules exist, through a straight-through Gumbel estimator) and the parameters
    of TSK neuro-fuzzy networks by **online RL** on a CNN front end in ViZDoom. The best NFNs used **64–256 rules**. They
    were comparable to DNNs in BP (86.6 vs 85.4), HTL (25.4 vs 27.2) and DTC (16.6 vs 17.9). In BR the DNN was better
    (58.4 vs 37.2, p = .02). Entmax or softmax over the firing levels kept the rule activations sparse and readable.
    *Relevance:* modern evidence that a TSK rule base can be learned end to end by RL in an action game without losing
    much. It is far heavier than our budget allows, though.

11. **Rodgers, P., & Levine, J. (2017). Ensemble framework for real-time decision making. arXiv:1706.06952.**
    https://arxiv.org/abs/1706.06952 (**T2, full text**)
    Listed in §C too. A (1+1)-ES tuned the arbiter's voice weights over **1,000 steps × 100 games = 100,000 games** for
    about **+30 % average score**. The authors call it "slow and tedious", and the final agent does not use it.
    *Relevance:* a cost estimate. ES on a handful of weights works but needs on the order of 10⁵ games, which is fine
    for an offline native sim and impossible online.

12. **Annabestani, M., Abedi, A., Nematollahi, M. R., & Naghibi Sistani, M. B. (2021). A new soft computing method for
    integration of expert's knowledge in reinforcement learning problems. arXiv:2106.07088.**
    https://arxiv.org/abs/2106.07088 (**T2, full text; NOT a game: 10-armed bandit**)
    A single-input Sugeno map turns each action's Q into a selection weight. One knob **ξ ∈ [0,1]** spreads or collapses
    the output centres: ξ → 1 makes the actions near-equiprobable, ξ → 0 makes the choice greedy. ξ plays the role of a
    softmax temperature but is set through the rule base. Over 1,000 runs the median reward was 75.0 against softmax's
    65.5, and it converged at about 20 % of the run where softmax needed about 50 %. *Relevance:* one parameter that
    reshapes the rule outputs toward or away from random is a clean difficulty knob (EASY → high ξ). It is the same idea
    as our `:choice` pull toward 1/2.

## C. Fuzzy evaluation inside a search (any game)

13. **Heinze et al. (2005), Fuzzeval** (entry 9). (**T1, full text**)
    A fuzzy controller is the **board evaluation function** for backgammon move selection. It uses triangular sets,
    min for AND, and a defuzzified "BoardStrength". Inputs include ToBeHitFactor, SinglePiecesInHome, PointsOwned and
    StrongestConsecutiveBlockade. **15 rules → about 34 % wins vs Pubeval after only 100 games. 15 variables and 30 rules
    → about 42 %.** A TD-trained ANN pair (196-80-5) needed **75,000–85,000 self-play games to reach the same level**,
    and peaked at 59 % after 400,000. *Relevance:* a fuzzy evaluator is a strong prior when there is little data. It is
    beaten by a learned one given enough games, which supports the "fuzzy first, learned later" order.

14. **Rodgers & Levine (2017), Ensemble** (entry 11). (**T2, full text**)
    In Ms. Pac-Man each "voice" rates every legal move. The ratings are inverse distances, which the authors call
    "fuzzy logic", but there are no membership functions: it is graded voting. The arbiter computes
    `R_m = (Σ_i V_im W_i) · V_1m`, where V_1 is the ghost-dodger acting as a **multiplicative veto**. The arbiter takes
    the argmax and breaks ties at random. The ghost-dodger runs **10 ms** of random depth-8 samples. Results: final
    ensemble mean **102,238** points over 100 games, against MCTS 57,151–58,058. The MCTS benchmark **replaced rollouts
    with score deltas**, because rollouts played to death were uninformative: "how do you reward death, given that most
    roll-outs end in death?". *Relevance:* a direct precedent for our "rollout ends without contact → score the position
    instead" case. Graded ratings also avoid the ties that crisp votes produce.

15. **Rutko, D. (2011). Fuzzified tree search in real domain games. *MICAI 2011*.
    https://doi.org/10.1007/978-3-642-25324-9_13** (**T1, abstract only; a naming false positive**)
    Record: https://fitforthem.unipa.it/rep:6533b829fe1ef96bd1289791. "Fuzzified" here means approximate alpha-beta: it
    prunes early because the exact minimax value is not needed to find the best move, and reports about 10 % speed-up.
    There is **no fuzzy inference**. It is listed so it is not mistaken for evidence.

*Gap (searched, not found):* no opened source uses a fuzzy inference system as the **leaf or rollout evaluation of
MCTS**. Searches for fuzzy + MCTS / UCT / rollout in Go, RTS, Hearthstone, GVGAI and fighting games returned only
non-fuzzy heuristic evaluations. Fuzzeval (one-ply evaluator), Ishihara's tanh blend and Rodgers & Levine's score deltas
are the nearest.

## D. Practical guides, libraries, design advice

16. **Georgia Tech CS 4731 Game AI (Summer 2016). *Decision making: fuzzy logic* [Lecture slides].**
    https://faculty.cc.gatech.edu/~surban6/2016-cs4731/lectures/2016_06_28-DecisionMaking_FuzzyLogic.pdf
    (**T3, full text**; it summarizes **Buckland, *Programming Game AI by Example*, ch. 10** and **Millington, *AI for
    Games*, §5.5**. The book pages themselves returned 403 and are cited only through these slides.)
    - Membership shapes: triangle, trapezoid, shoulders, singleton, S-curve. Advice: "vertical lines should sum to 1"
      (a partition of unity).
    - Small sets (booleans, enums) take stored, precomputed memberships.
    - Operators: AND = min, OR = max, NOT = 1 − μ. Hedges: VERY = μ², FAIRLY = √μ.
    - Defuzzification: mean of maximum, centroid, average of maxima. Centroid "is often used, but is expensive";
      **"blending works about as well and is cheap"** (Millington). Blending means weighting each set's representative
      value by its membership, which is what zero-order Sugeno does.
    - The weakness is **combinatorial explosion**: a full table needs a rule for every combination of antecedent sets,
      and the slides' example is "10 inputs × 5 sets → about 10 million rules". The fix taught is the **Combs method**
      (Boeing, 1997): `IF far AND loads THEN desirable` is rewritten as `IF far THEN desirable OR IF loads THEN
      desirable`, so the rules grow linearly.
    - **Fuzzy state machines:** the machine can be in several states with a membership degree each. Transitions fire in
      decreasing order of degree, and a target's degree is the current state's degree ANDed with the transition's.
    - Pros: readable, smooth transitions, easier than a neural network. Cons: membership functions are hard to define,
      and debugging and defuzzification have subtleties.

17. **Mendel, J. M., Liang, Q., & Combs, W. E. (1999). Comments on "Combinatorial rule explosion eliminated by a fuzzy
    rule configuration" [and reply]. *IEEE Transactions on Fuzzy Systems*, 369–373.** (**T1, record only**)
    Record: https://search.isc.ac/inventory/10/395070.htm (keywords: Combs method, De Morgan's laws, modus ponens,
    union rule configuration). The record shows only that **a published critique of the Combs equivalence exists, with
    a reply**. Its content was not read. *Relevance:* treat Combs-style single-antecedent rules as a **different
    model** from the full intersection table, not as a free equivalent, and tune it as such.

18. **Rada-Vilela, J. (2018). *The FuzzyLite libraries for fuzzy logic control*. FuzzyLite Limited.**
    https://fuzzylite.com/downloads/FuzzyLite-Libraries.pdf; docs:
    https://fuzzylite.github.io/pyfuzzylite/fuzzylite/defuzzifier/WeightedAverage (**T3, a vendor paper, full text**)
    The paper benchmarks FuzzyLite, Matlab, Octave and jFuzzyLogic on 20 Mamdani and Takagi–Sugeno controllers. The cost
    split it measures:
    - **Integral defuzzifiers** (centroid, bisector, the max family) sample the aggregated output at resolution
      **r = 100** by default, as a trade-off between accuracy and speed.
    - **Takagi–Sugeno weighted average** is "a weighted average of a few values", so TS benchmarks optimise far better
      than Mamdani ones.
    - Membership shape barely matters for speed: apart from Constant and Linear terms, the differences between terms are
      negligible.
    - Since v8, the WeightedAverage defuzzifier aggregates multiple activations of the same term.
    *Relevance:* confirms zero-order Sugeno plus weighted average as the cheap path. Libraries are not needed: the whole
    method is a few lines.

19. **Dill, K. (2015). Dual-utility reasoning. In S. Rabin (Ed.), *Game AI Pro 2*, ch. 3.**
    http://www.gameaipro.com/GameAIPro2/GameAIPro2_Chapter03_Dual-Utility_Reasoning.pdf (**T3, full text; ADJACENT:
    utility, not fuzzy**)
    Each option gets a **rank** (absolute utility, picks the category) and a **weight** (relative utility). Options below
    the top rank are dropped, then **weight-based random** chooses among the rest. Absolute utility is "predictable";
    weighted random gives variety while preferring good options. *Relevance:* this is the industry's successor to fuzzy
    action selection. Its rank-then-weight split keeps a must-do reaction from being diluted by a soft average, a known
    weakness of a pure weighted-average rule base. None of the three Game AI Pro utility chapters checked (GAP1 ch. 9,
    GAP2 ch. 3, GAP3 ch. 13) mentions fuzzy logic.

## E. Fuzzy difficulty adjustment and believable behaviour

20. **Paraschos, P. D., & Koulouriotis, D. E. (2025). Fuzzy logic-based dynamic difficulty adjustment for adaptive game
    environments. *Electronics, 14*(1), 146. https://doi.org/10.3390/electronics14010146** (**T1, abstract only**, read
    via the Semantic Scholar API; the MDPI page refused automated access)
    The test bed is a shoot 'em up with an adaptive opponent. Fuzzy rules over the player's behaviour and strategy tailor
    the challenge, and evaluation was by scenarios. The authors report "balanced challenges" and that behaviour is
    "easily defined ... through a set of rules". The abstract gives no numbers or user study. *Relevance:* weak evidence.
    It shows fuzzy DDA is still being proposed, not that it beats alternatives.

Also relevant here: entry 4 (Ishihara: believability as an explicit aggression term, a smooth blend by HP lead, and a
user study) and entry 12 (one ξ knob from greedy to random).

## Synthesis

**What worked**
- Fuzzy layers win over **crisp thresholds** in fighting games, mostly near the threshold (Chu & Thawonmas: 129–68 in
  round 1). Their outputs are used as **probabilities for weighted random** directly, with no defuzzification (Chu;
  Fuzzy_ZYQAI). Rule bases stay tiny: 4 rules (Chu), 15 (TORCS), 30 (Fuzzeval).
- **Tuning breakpoints or consequents with the rule structure fixed** is enough to beat the hand-tuned version: a GA in
  TORCS, a (1+1)-ES in FightingICE, a GA over a whole fuzzy tree in ALPHA. Fuzzy Q-learning and TS-combined rewards are
  the standard online alternatives, but their game evidence is old and abstract-level.
- **A fuzzy evaluator is a data-efficient prior.** Fuzzeval matched an ANN that needed about 800× more games. The ANN won
  in the end (59 % vs 42 %).
- **Rule explosion is solved structurally:** Combs-style single-antecedent rules (with a published caveat), or cascades
  of small FISs (GFT).
- **Cost is not the problem** when the inference is Sugeno or weighted average: no integration, a few multiply-adds per
  rule.

**Limits**
- No verified fighting-game fuzzy agent was competitive with search bots. Fuzzy_ZYQAI was outside the top 3, and Chu
  used fuzzy only to patch a k-NN's cold start. Fuzzy is a good **reflex and blend layer**, not a strategy.
- The evidence base is thin and old. Most fuzzy-RL game work is visible only as abstracts, without numbers, and the
  recent fuzzy DDA paper reports no metrics.
- A weighted average dilutes a decisive rule by many weak ones. Dill's rank-then-weight and Rodgers' multiplicative veto
  are the two workarounds seen.
- Plain HP-balancing evaluations produce unbelievable play (Ishihara). Believability needs its own term.

**Gaps**
- No opened source uses fuzzy inference as an **MCTS leaf or rollout evaluation**. Our stage (b) has no direct
  precedent.
- No opened source learns fuzzy consequents **online from a human opponent** in a fighting game.
- No opened source measures fuzzy-versus-crisp **believability** with players.

## Implications for SOUL DUEL (deterministic sim, about 1 ms a decision in wasm)

1. **Keep zero-order Sugeno with trapezoids, min for AND and a weighted average, and use only + − × ÷ on the sim side.**
   FuzzyLite and the Millington-derived advice agree that this is the cheap path: no centroid at r = 100. It also avoids
   libm, which is where native and wasm drift (AGENTS.md). **Do not put `exp` or `tanh` into anything the sim or the
   rollout evaluation reads.** Ishihara's tanh blend should become a piecewise-linear shoulder. If the outputs ever move
   to integers, scale memberships to 0–1024 and bound rules × output scale so that Σ wᵢ·cᵢ stays under 2²⁹ (30-bit
   fixnums on wasm32). With ≤ 10 rules and outputs ≤ 1024 this holds easily. Today `fuzzy.lisp` uses floats, `assoc`
   per membership and `getf` per cue. For the hot path, resolve each set name to its four breakpoints once at load, and
   read cues with `plist-get` (the hot-plist rule in AGENTS.md).

2. **Use the inferred chance directly and roll it once per event.** Chu and Fuzzy_ZYQAI did exactly that, and it matches
   the AI v2 rule "roll once per event, never per step". For must-do reactions (a sure punish, a lethal Burst), add a
   **rank** in front of the soft average, as in Dill, or a **multiplicative veto**, as in Rodgers & Levine. Then one
   strong rule is not averaged away by weak ones firing beside it.

3. **Fight rule explosion by structure, not by bigger tables.** Use 2–3 sets per cue and single- or two-antecedent rules
   (Combs-style; tune it as its own model per Mendel & Liang). Where a cue depends on two others (effective reach from
   distance and the move's reach), use a **two-tier cascade** as in ALPHA: one small FIS feeds a derived cue to the
   next. The verified rule counts are 4–30, and our 4–6 rules per decision sit in that range.

4. **Make difficulty one knob on the outputs, not separate rule sets.** Our `:skill` multiply and `:choice` pull toward
   1/2 are already Annabestani's ξ in spirit. Keep the HARD outputs as the learned quantity and derive EASY / NORMAL from
   it, so learning one table improves all three.

5. **Learn in this order.**
   - *Offline:* a (1+1)-ES with the one-fifth rule (Kanetsuki) or a small GA (TORCS: population 20–50, 50 generations)
     over the **consequents first, then the breakpoints**, with the rule structure fixed, on the native sim. Budget about
     10⁵ games (Rodgers & Levine's +30 % cost 100,000). The fitness function is the hard part (Salem et al.).
   - *Online, from the player:* use strength-weighted updates of the consequents, as in fuzzy Q-learning, or Fuzzeval's
     cheap step of **re-centring a set on the average cue seen in winning exchanges**.
   - Apply every update **between matches or outside the sim step**, and clamp it. Determinism and the state-hash lines
     stay intact.

6. **For rollouts that end without contact, score the position with a small fuzzy evaluator, and test it against a
   crisp one.** Rodgers & Levine and Fuzzeval show that a position score beats rollouts played to an uninformative end,
   and Fuzzeval shows it works with little data. There is no precedent for fuzzy leaf evaluation in MCTS, so treat it as
   an experiment. A/B it with a scripted control (the project's rule) against a crisp linear score over the same cues
   (spacing, frame advantage, gauges, corner). Add Ishihara's lesson: a pure "keep it even" term needs an aggression or
   believability term beside it.

## Excluded (seen only in search snippets or behind a login; not cited above)

- Buckland ch. 10 itself (O'Reilly, 403): the "9 → 27 rules" example, the MaxAv value 57.16, and the claim that the
  classes need no change for Combs. Used only through entry 16.
- Combs & Andrews (1998), *IEEE TFS*, the original Combs paper: record seen, not read. Mendel & Liang's arguments: no
  abstract available.
- Preuss, M., Kozakowski, D., Hagelbäck, J., & Trautmann, H. (2013), "Reactive strategy choice in StarCraft by means of
  fuzzy control", CIG 2013, https://doi.org/10.1109/CIG.2013.6633627. The Münster record page showed a summarized
  abstract only: fuzzy control chooses among a pool of strategies in the BTHAI bot and improves on the original. No
  numbers were seen. It is borderline, so it is listed here and not relied on.
- Salem et al. EvoApplications 2018 / IPMU 2018 full papers (Springer login). Only the slides (entry 7) were read.
- Peng et al. 2008 (fuzzy Q-learning coordination in RoboCup); Sawa & Watanabe 2011 (keepaway, fuzzy Q-learning);
  Guadarrama & Vázquez 2008 (racing car tuned by coevolution); Onieva et al. 2009 / 2012 (the AUTOPIA driver; its opened
  abstract never mentions fuzzy logic); Desouky & Schwartz 2009 (ANFIS NPCs).
- The Pac-Man / Ms. Pac-Man fuzzy papers (Shaout et al. 2012, IAJIT, 503; the Hiroshima evolutionary-fuzzy work, 404 /
  403); Zapirain & Massa (fuzzy zombie enemies, the server refused the connection); the Sugeno Mario-like "100 %" claim
  (snippet only).
- Iwashima (Hosei bachelor's thesis, FightingICE imitation AI): opened, but it is Q-learning plus a random forest, not
  fuzzy.
