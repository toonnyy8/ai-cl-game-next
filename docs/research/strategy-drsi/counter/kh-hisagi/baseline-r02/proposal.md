# Baseline round 2: the incumbent (hisagi vs kenpachi, HARD)

hisagi plays the CPU with the HARD lookup: the s7 kite (library :s7-kite in duel/lisp/strategy.lisp; round 1's counter/kh-hisagi b1_a2: range 3.2, NS 1.0, no J1, back off inside his reach, cont 1.3, awaken 4.0).
The opponent plays its shipped CPU.

Measured on the search seeds (600-699, both seats, 200 matches): win share 0.375 (score.json). A composite whose :own never fires scores exactly this.
Round 2 rule (DUEL_AI_STRATEGY 8.9): a candidate owning more than 60 % of the judgements scores as the incumbent.
