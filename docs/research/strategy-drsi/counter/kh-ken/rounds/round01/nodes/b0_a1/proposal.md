# b0_a1 (kenpachi vs hisagi HARD): ken-ki-style while ahead, or level + far + HIS Reiatsu high

Slice: (:lead :ahead) OR (:lead :even, :or :high, :dj :afar). Strategy: `:fn ken-ki-style` (no base). Incumbent otherwise.

History read: b0_a0 (parent: ahead | even&afar&MY mr high, ken style, :p 1.3; search score 0.35, own 0.49), b1_a0 (ichigo style, ahead | even far/out;
0.355, own 0.53), b2_a0 (ahead | my mr high&afar&free; 0.35, own 0.495). All three share the robust :lead :ahead arm (own ~0.32) and add a
"level and far" arm keyed on MY Reiatsu or distance. Baseline incumbent 0.035.
What differs: the second arm is keyed on the OPPONENT's Reiatsu (`:or` high) instead of mine (`:mr`). Same fn as the parent, so the delta is
only the slice.
Dev screens (40 seeds, seed0 800, ken style): :dswitch / :p in :base change nothing under this :fn (identical results, dropped);
awk-only 0.06, ored-only 0.01 (useless alone); ahead|even&or high (any distance) 0.54 gain but own 0.79 (over cap); +afar 0.41 gain own 0.556;
+out 0.29 own 0.43; ahead|even&or high&awk no 0.61 gain own 0.77; ichigo style on parent slice 0.30 (worse than ken 0.42).
Gain tracks own share almost linearly (~0.7-0.75 per unit above ~0.3): the lever is the cap, not the slice's content.
Final: seed0 800 x100: 82/200 vs inc 4/200, gain 0.39, z 8.5, own 0.551 (dev.json). Second block seed0 900 x50: 0.47 vs 0.00, z 6.9, own 0.587.
Risk: own share 0.55-0.59 is near the 0.6 cap (block 2 only 0.013 under); if the search seeds push it over, the score falls to 0.035.
Safer fallback: replace the afar arm by `(:dj :afar)(:or :high)(:awk :no)(:lead :even)` with own 0.54, or drop the arm (ahead only, own 0.32, gain ~0.22).
Not a repeat: different cue (opponent Reiatsu); but the gain is mostly the shared :ahead arm, so not additive with siblings.
