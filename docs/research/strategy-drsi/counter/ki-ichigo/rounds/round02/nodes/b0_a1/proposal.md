# b0_a1 behind-red-close (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` OR `:ored :yes` (own_share ~0.16). Strategy: `:fn ichigo-ki-style` (her own style CPU; incumbent plays Kenpachi's), `:base (:range 0.7)`.
History read: round 1 old-incumbent cells (range 0.7 on reach/Reishi slices; ken-style-all won as a whole replacement, now the incumbent); round 2
siblings b0_a0 (behind, own style, range 0.7: +0.22), b1_a0 (behind: +0.18), b2_a0 (behind|red: +0.325).
This cell combines b0_a0's range 0.7 with b2_a0's two-slice union; it is a variant, not a new mechanism (siblings already cover the mechanism).
Probes (seed0 800 x100, gain vs 0.43): +kikon 1.5 +0.32; adding `:ost :down` slice +0.235 (worse, own 0.28); adding even x Reishi-high +0.17 (worse, own 0.37);
range 0.7 +0.345 (z 6.7); range 0.7 + kikon 1.5 + turn 1.3 +0.34 (no gain from extras). Second block (900 x50) of the final: +0.24 (z 3.2), same as b2_a0's.
Range 0.7 adds ~+0.02, inside noise. Expect shrinkage on search seeds (butterfly effects, ~8 probes selection).
