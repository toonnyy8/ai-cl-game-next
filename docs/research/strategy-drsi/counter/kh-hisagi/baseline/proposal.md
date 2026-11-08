# Baseline: the incumbent (hisagi vs kenpachi, HARD)

hisagi plays the shipped CPU: the generic core CPU + the in-game MCTS, no matchup style CPU, no strategy (= seeds/s0-generic.lisp).
The opponent plays its shipped CPU too (Hisagi HARD vs Ichigo plays s3-zoner by the lookup, DUEL_AI_STRATEGY 8.6).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.035 (score.json). A composite whose :own never fires scores exactly this.
