# Baseline: the incumbent (hisagi vs ichigo, HARD; DUEL_AI_STRATEGY 8.15)

hisagi plays the CPU with his HARD lookup strategy :s3-zoner (the zoner data strategy, DUEL_AI_STRATEGY 8.4-8.6; seeds/s3-zoner.lisp).
The opponent is FROZEN (`--vs-strat frozen/ki-ichigo.lisp`): Ichigo plays her HARD lookup strategy :ki-ichigo, her KI style CPU as her strategy (frozen/ki-ichigo.lisp, DUEL_AI_STRATEGY 8.8-8.9). Hisagi's incumbent is his own lookup strategy s3-zoner.

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.0 (score.json; score 0.005, floored at 0.005).
A composite whose :own never fires scores exactly this. Rule (DUEL_AI_STRATEGY 8.9): a candidate owning more than 60 % of the judgements
scores as the incumbent.
