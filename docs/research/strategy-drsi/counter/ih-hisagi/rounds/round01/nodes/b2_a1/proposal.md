# b2_a1: ken-ki-style while Hisagi is not behind AND (Hoho ready OR Ichigo red) — a 53 % slice that sits under the cap

Slice: `:own (((:lead :even) (:hoho :yes)) ((:lead :ahead) (:hoho :yes)) ((:lead :even) (:ored :yes)))`, strategy `:fn ken-ki-style`.
Incumbent s3-zoner wins 0/200 vs frozen :ki-ichigo, so every win is gain.

History read (b0_a0 0.04, b1_a0 0.01, b2_a0 0.02, baseline 0.0): all found that ken-ki-style beats the zoner only when it runs most of the game
(whole game, own 1.0: 49 wins / 100 matches, 50 seeds; lead even|ahead own 0.81: 0.31; own 0.98: 0.32; own ~0.9: 0.12-0.15; own <= 0.5: ~0.01-0.04).
The gain is steep in own share, so the cap bites. b0/b1 sliced by distance and opponent state (gain ~0); b2_a0 used ichigo-ki-style on "ahead" (tiny).

New here: take the lead-based "not behind" core (the part that converts: lead even|ahead) and thin it with a conjunct that keeps own just under
0.6 while losing as little as possible. 50-seed probes (seed0 800): not-behind & awk no 0.02 (own 0.43); & or high 0.01 (0.27); & dj out|afar 0 (0.13);
& mr high 0.05 (0.42); & ored no 0.11 (0.61, capped); & hoho yes 0.09 (0.52); + (even & ored yes) 0.10 (0.54); + ahead & mr high 0.12 (0.60, edge);
+ even & dj in 0.11 (0.58; second block 0.62 capped, rejected for margin); + even & mr low 0.11 (0.55, second block own 0.59, too close).
DRIVE switch (`:dswitch` 0.4 / 1.0) with the same slice: 0.07-0.08, no help (also 0 on lead ahead alone); hisagi-range-style slices (wave yes, lead even): 0.
ichigo-ki-style slices: ~0. Not a repeat: no earlier cell used the lead core or the hoho / red conjuncts.

Dev (seed0 800, 100 seeds, 200 matches): 17 vs 0, gain 0.085, z 4.1, own 0.533, uncapped (dev.json).
Second block (seed0 900, 50 seeds): 8 vs 0, gain 0.08, z 2.8, own 0.581, uncapped. Consistent across blocks.

Expected benefit: about +0.08 of win share over the incumbent's 0. Risk: own 0.58 on one block leaves ~0.02 to the cap; the slice is chosen from
probes on the dev block (selection among ~25 variants), so expect a bit lower on fresh seeds. Whole-game ken-ki-style (own 1.0, ~0.49) would be
the better lookup replacement (as in 8.10); this is the best under-the-cap composite found.
