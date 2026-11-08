# Baseline round 2: the incumbent (kenpachi vs ichigo, HARD; DUEL_AI_STRATEGY 8.15)

kenpachi plays his shipped CPU: the generic core CPU + the in-game MCTS, with his KI matchup style CPU (duel/lisp/cpu-ki-ken.lisp, after the MCTS). He has no HARD lookup entry against Ichigo.
The opponent is FROZEN (`--vs-strat frozen/q1-ichigo-ken.lisp`): Ichigo plays her HARD lookup strategy, the fuzzy Q table :q1-ichigo-ken (frozen/q1-ichigo-ken.lisp: per situation Kenpachi's KI style or her own, DUEL_AI_STRATEGY 8.12-8.13). Round 1 of this workspace was against her old shipped CPU (0.755 then): its numbers are evidence about mechanisms, not on this round's scale (the incumbent now wins 0.095).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.095 (score.json; score 0.095, floored at 0.005).
A composite whose :own never fires scores exactly this. Rule (DUEL_AI_STRATEGY 8.9): a candidate owning more than 60 % of the judgements
scores as the incumbent.
