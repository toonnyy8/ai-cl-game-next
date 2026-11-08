# Baseline: the incumbent (kenpachi vs ichigo, HARD)

kenpachi plays the shipped CPU: the generic core CPU + the in-game MCTS, with his KI matchup style CPU (duel/lisp/cpu-ki-ken.lisp, after the MCTS, HARD margin gate).
The opponent plays its shipped CPU too (Hisagi HARD vs Ichigo plays s3-zoner by the lookup, DUEL_AI_STRATEGY 8.6).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.755 (score.json). A composite whose :own never fires scores exactly this.
