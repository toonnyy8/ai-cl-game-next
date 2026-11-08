# b1_a1: ken-ki-style (+ DRIVE switch 0.5) while Mana-Reiatsu is high and the lead is even or ahead

Slice: `:own (((:mr :high) (:lead :even)) ((:mr :high) (:lead :ahead)))`, own ~0.40. Strategy: `:fn ken-ki-style`, `:base (:dswitch 0.5)`.
History: b0_a0 (lead even|dj out|afar, 0.01), b1_a0 (even&free | opponent busy, 0.02), b2_a0 (ichigo-ki when ahead, 0.02): all ~0 gain; every
cell found that only near-whole-game ken-ki-style wins (capped). Incumbent wins 0/200, so any win is gain.
New here: restrict the near-whole-game winner (lead ahead|mr high, 0.32 capped) by requiring mr high in both branches, and add the §8.16 DRIVE switch
at 0.5 (never combined with these slices before). hisagi-range-style probes: 0.0 on lead behind, dj in|reach, and their union (HI 0.0, as §8.16 says);
ken-ki + dswitch 1.0 on lead even|dj out|afar 0.01; mr high+dj out|afar|ahead 0.03; mr high&even|ahead any (dswitch 0.5) 0.21 but own 0.71 (capped), a
variant without dswitch 0.23 own 0.73 (capped); adding ahead&dj or ahead&ost slices 0.0.
Dev (seed0 800, 100 seeds): 7/200 vs 0/200, gain 0.035, z 2.65, own 0.395, uncapped. Second block (seed0 900, 50 seeds): gain 0.02, own 0.40.
Risk: effect small (3.5 pts, 2 on second block); likely ~0.02 on fresh seeds. The real gain sits in the capped union (0.21-0.23), whole-game
replacement territory: lookup candidate "ken-ki-style, :own lead ahead|even with mr high" (dev 50 seeds 0.21-0.23, own 0.71-0.73).
