# Baseline: the incumbent (kenpachi vs hisagi, HARD; DUEL_AI_STRATEGY 8.15)

kenpachi plays his shipped CPU: the generic core CPU + the in-game MCTS (no matchup style CPU against Hisagi, no HARD lookup entry).
The opponent is FROZEN (`--vs-strat frozen/ki-ken.lisp`): Hisagi plays his HARD lookup strategy :ki-ken, Kenpachi's own KI style CPU as Hisagi's strategy (frozen/ki-ken.lisp, DUEL_AI_STRATEGY 8.10-8.11).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.035 (score.json; score 0.035, floored at 0.005).
A composite whose :own never fires scores exactly this. Rule (DUEL_AI_STRATEGY 8.9): a candidate owning more than 60 % of the judgements
scores as the incumbent.
