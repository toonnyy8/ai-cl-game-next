# b2_a0: Kenpachi's KI style CPU as Hisagi's counter, owning lead even / behind

Slice: (:lead :even) OR (:lead :behind). Strategy: `:fn ken-ki-style` (seeds/s5), no base/rules (inert under :fn).
History: round 1 was all kite/zoner/brawler data tuning (the incumbent s7 kite is its winner, 0.375); data-only never beats a KI style.
Round 1's Ichigo-vs-Kenpachi win was Kenpachi's KI style as her strategy; here the same borrowed style goes to Hisagi. Sibling b1_a0 used
Ichigo's style (0.835 dev); this uses Kenpachi's, a different function and tactic set. Not a repeat.
Dev 800 (100 seeds/seat, inc 0.40): even 0.725 (own 0.31), behind 0.845 (0.26), ahead 0.555 (0.38), even+behind 0.905 (own 0.40, gain +0.505, z 9.3).
Second block seed0 900 (50 seeds): 0.90 vs inc 0.39 (own 0.38, z 7.0). Two blocks agree.
Mechanism: the style plays from the early judgements and while not ahead; once Hisagi leads, the incumbent kite protects it.
Risk: low overfit (effect size huge); ahead slice excluded because it is weakest; own well under the 0.6 cap.
