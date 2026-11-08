# b0_a2 (kk-ken, round 1): ken-ki-style when behind, or even and near, or ahead with low Reiatsu and close
Slice: (lead behind) OR (lead even, dj in) OR (lead even, dj reach) OR (lead ahead, mr low, dj in). Strategy: `:fn ken-ki-style`.
History: b0_a0 behind/even, b0_a1 near+not-ahead, b1_a0 close+not-ahead/mr low, b1_a1 ichigo-ki-style (weaker), b2_a0 ost mix (0.905), b2_a1 narrow behind-near (0.955). One mechanism: the style CPU beats the incumbent mirror.
Mine: whole "behind" (no range test), even only when near, plus the one ahead pocket where the incumbent is weakest (low Reiatsu, close).
Dev seed0 800 x100: 0.99 (own 0.365). Second block seed0 900 x50: 0.97 (own 0.355, z 6.6). Probes: lead+mr low/ost free 0.685; behind/even+close 0.935; behind+near, even+close 0.97; behind OR even-near 0.98.
Not a repeat: new conjunction; same ceiling (~0.98). Risk: whole-replacement in disguise; a lookup entry would do.
