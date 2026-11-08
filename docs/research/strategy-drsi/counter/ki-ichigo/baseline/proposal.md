# Baseline: the incumbent (ichigo vs kenpachi, HARD)

ichigo plays the shipped CPU: the generic core CPU + the in-game MCTS, with her KI matchup style CPU (duel/lisp/cpu-ki-ichigo.lisp; Ichigo HARD has the MCTS off past *mc-off-at*).
The opponent plays its shipped CPU too (Hisagi HARD vs Ichigo plays s3-zoner by the lookup, DUEL_AI_STRATEGY 8.6).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.245 (score.json). A composite whose :own never fires scores exactly this.
