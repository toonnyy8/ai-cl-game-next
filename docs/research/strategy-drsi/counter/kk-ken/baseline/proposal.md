# Baseline: the incumbent (kenpachi vs kenpachi, HARD; DUEL_AI_STRATEGY 8.15)

kenpachi plays his shipped CPU: the generic core CPU + the in-game MCTS (no mirror style CPU, no HARD lookup entry).
The opponent is FROZEN (`--vs-strat none`): A mirror: your composite plays one seat (both seats are measured, 100 seeds each), the other seat is Kenpachi's shipped CPU (no strategy) = the incumbent, so the baseline is about 0.5 (draws count 0).

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.5 (score.json; score 0.5, floored at 0.005).
A composite whose :own never fires scores exactly this. Rule (DUEL_AI_STRATEGY 8.9): a candidate owning more than 60 % of the judgements
scores as the incumbent.
