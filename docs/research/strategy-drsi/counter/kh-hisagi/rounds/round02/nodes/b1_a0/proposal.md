# b1_a0: Ichigo's KI style CPU as Hisagi's counter, owning lead even / behind

Slice: (:lead :even) OR (:lead :behind). Strategy: `:fn ichigo-ki-style` (seeds/s6), no base/rules (data-only biases are inert under :fn).
History: round 1 was all kite/zoner tuning (spacing + NS + :cont + :awaken); the incumbent is that kite (0.375). Nobody tried a KI style CPU
of another character on Hisagi (round-1 briefs only listed it as possible). Not a repeat: a different mechanism (a whole different tactic set).
Dev 800 (100 seeds a seat, inc 0.40): brawler slices (ahead/red/low-mr/close/behind) -0.04..-0.2 (worse); ichigo-ki: behind 0.665 (own 0.26),
ahead 0.58 (0.36), even 0.85 (0.19), far 0.495, mr low 0.535; capped (>0.6 own): behind+ahead, near, mr high, even+ahead.
Final eb: see dev.json (0.835, gain +0.435, z 8.1, own_share 0.234). Second block seed0 900 (50 seeds): even 0.84, eb 0.87 vs inc 0.39.
Mechanism: the KI style plays from the first judgement (lead is even at the start) and takes the lead, after which the composite falls back
to the incumbent kite (own low); a few early judgements decide most matches. Risk: moderate overfit unlikely (two blocks agree, z 6-8);
whether the lookup should just use ichigo-ki-style for HARD h-vs-k is worth checking at the coordinator (the cap blocks that here).
