# b2_a2: b2_a1's "not behind & (Hoho ready | Ichigo red)" core plus "ahead & Ichigo red" (ken-ki-style)

Slice: `:own` = even&hoho | ahead&hoho | even&ored | ahead&ored, `:fn ken-ki-style`. Incumbent wins 0/200, so every win is gain.
History read: b0_a0 0.04, b0_a1 0.045, b1_a0 0.01, b1_a1 0.015, b2_a0 0.02, b2_a1 0.085 (own 0.56, second block 0.08). All agree ken-ki-style only
beats the zoner when it runs most of the game, and gain is steep in own share, so the cap (0.6) is the constraint. b2_a1 is the best; I started from it.
Probes (50 seeds, seed0 800) adding one extra branch: +ahead&mr high 0.12 (own 0.5994, too near cap), +ahead&ost free 0.11 (0.575; second block own 0.6057, over),
+ahead&dj in 0.11 (0.571), +behind&ored&hoho 0.09, +ahead alone 0.20 but own 0.746 capped, +behind&hoho&mr high 0.12 but own 0.84 capped. The base b2_a1 gives ~0.09.
Chosen: +ahead&ored (the same "Ichigo red" trigger b2_a1 already uses, applied when ahead): own 0.547 on dev (0.5964 on block 2, uncapped by 0.004).
Dev (seed0 800, 100 seeds): 16 vs 0, gain 0.08, z 4.0, own 0.547. Second block (seed0 900, 50 seeds): 10 vs 0, gain 0.10, z 3.16, own 0.5964.
Not a big structural departure: a one-branch extension of b2_a1's slice; the gain is the same size as b2_a1's (0.08 vs 0.085, inside noise), so expect ~0.08.
Risk: own 0.5964 on block 2 leaves almost no margin to the cap; on the search seeds it may score as the incumbent (0.005). The fuller-slice variants
(0.11-0.12) were rejected for that reason. The real lever stays a whole-game ken-ki-style lookup replacement (49/100 whole-game per b2_a1).
