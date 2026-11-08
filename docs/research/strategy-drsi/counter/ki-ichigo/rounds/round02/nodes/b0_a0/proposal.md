# b0_a0 behind-own-style (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` (own_share ~0.10-0.13). Strategy: `:fn ichigo-ki-style` (Ichigo's own style CPU) with `:base (:range 0.7)`.
The new incumbent plays Kenpachi's KI style everywhere; round 1 found Ichigo's own style + range 0.7 gains over its old self.
Hypothesis: when behind, Ichigo's own style (its comeback / KESSA logic) beats the borrowed Kenpachi one. sitcheck also shows kiichigo
strongest in behind bins (+0.2..0.35 vs generic).
Dev (vs baseline-r02 incumbent 0.43): seed0 800 x100 comp 0.65 gain +0.22 z 5.5; seed0 900 x50 gain +0.18 z 2.65 (holds on the second block).
Variants (seed0 800): same fn without range: +0.18 (z 4.8; 900: +0.19); `:mr :low` -0.10/-0.07; `:lead :ahead` -0.18 (so the lead cue is the signal);
behind|even capped (own 0.69). Only ~6 variants tried, little selection.
Not a repeat: round 1 owned reach / Reishi slices over the old incumbent; here the slice is lead-behind with the strategy being the other kit's own style.
Risk: own share small, effect large for it (a 1.5 s hold change); may shrink on search seeds. Range 0.7 adds little over the plain fn.
