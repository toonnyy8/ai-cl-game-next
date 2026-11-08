# b1_a0 (kenpachi vs hisagi HARD): ichigo-ki-style while ahead, or level and far / out with high Reiatsu

Slice: (:lead :ahead) OR (:lead :even, :dj :afar) OR (:lead :even, :dj :out, :mr :high). Strategy: `:fn ichigo-ki-style` (no base). Incumbent otherwise.
History: sibling b0_a0 used the same kind of slice with `ken-ki-style :base (:p 1.3)` (dev 0.37 gain, own 0.54-0.595). Hisagi's frozen opponent plays
ken-ki-style, so b0_a0 mirrors the opponent; mine plays the other KI style (Ichigo's), a different strategy in a similar slice (not a repeat of the fn).
Evidence (dev, 40-seed screens, seed0 800): ichigo style free&behind|red slice (the ki-ichigo pattern) 0.025 (own 0.66, no use); ahead 0.20 (own 0.32);
ahead|even&afar 0.31 (0.485); +even&out 0.44 (0.601, over cap); +even&out&mr high 0.425 (0.587); +even&out&busy 0.34 (0.51).
Final cand, seed0 800 x100: comp 0.355 vs inc 0.02, gain 0.335, z 7.84, own 0.5345. Second block seed0 900 x50: 0.37 vs 0.00, gain 0.37, z 6.08, own 0.5376.
Safer fallback (own 0.48): replace the third antecedent's `(:mr :high)` by `(:ost :busy)`: gain 0.285 / 0.33.
Risk: own share ~0.535, under the 0.6 cap with margin 0.065. Gain is the same order as b0_a0 (ken style), so the two are alternatives, not additive.
