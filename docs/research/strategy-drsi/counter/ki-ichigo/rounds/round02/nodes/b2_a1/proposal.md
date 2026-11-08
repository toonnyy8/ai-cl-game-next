# b2_a1 (id :v4) behind-or-red + range 0.7 (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` OR `:ored :yes` (own_share 0.156, under the 0.6 cap). Strategy: `:fn ichigo-ki-style` with `:base (:range 0.7)`
(her own style CPU, walk-to range closer; the incumbent plays Kenpachi's style).

History read: b0_a0 / b1_a0 (own style when behind, +0.18..0.22), b2_a0 (behind OR ored, +0.325 dev; held-out 0.685), round 1 (range 0.7 helped the old incumbent).
This cell starts from b2_a0's union and probes what else could extend it (dev seed0 800 x100, gain vs 0.43):
- add opp Reishi low (:or :low): +0.31 (no gain); add opp down: +0.235 (worse, own 0.28); add my Reishi low x even: +0.185 (worse);
  add near-his-reach x even: +0.285 (worse). Own style only helps when not winning / opp is red; widening to even states hurts.
- range 1.3: +0.26 (worse); range 0.7: +0.345 (b87 c18, z 6.7); second block seed0 900 x50: +0.24 (z 3.15).
Not a repeat? Honest answer: it is b2_a0's slice with the b0_a0 range knob; the extension probes all failed, so the range tweak is the only
difference and +0.02 over b2_a0 is within noise. Expect the same score as b2_a0 (~0.65-0.7 on search seeds). Risk: butterfly shrinkage.
