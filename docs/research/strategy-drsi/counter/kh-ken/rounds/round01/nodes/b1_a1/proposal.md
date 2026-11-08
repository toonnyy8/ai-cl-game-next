# b1_a1 (kenpachi vs hisagi HARD): ken-ki-style while ahead, or level and far

Slice: (:lead :ahead) OR (:lead :even, :dj :afar). Strategy: `:fn ken-ki-style :base (:p 1.3)`. Incumbent otherwise.
History read: b0_a0 (same fn; ahead | even&afar&mr high), b1_a0 (ichigo style; ahead | even far / out), b2_a0 (ahead | mr high&afar&free),
b2_a1 (ichigo style, same slice as b1_a0). All share the robust :lead :ahead arm (own ~0.32). Mine is the plain minimum of that family:
ahead | even&afar, no Reiatsu or state term. It is the same mechanism, not a new one; the only new evidence is the simpler slice.
Dev (seed0 800, 40 seeds): ahead|even&afar 0.425 (own 0.556); with :dswitch 1.0 identical (0.425; the switch has no effect under ken-ki-style);
+ (:ost :free) on the far arm 0.4125 (own 0.557, :free is most of the time so it does not cut own); + (even,out,mr high,free) 0.425 (0.562);
ahead&free | even&afar&free | ahead&in 0.375 (0.529).
Final: seed0 800 x100: 82/200 vs inc 4/200, gain 0.39, z 8.51, own 0.5523. Second block seed0 900 x50: 0.48 vs 0.00, gain 0.48, z 6.93, own 0.595.
Risk: own share 0.55-0.595 close to the 0.6 cap (second block at 0.595); if the search seeds exceed 0.6 the score falls to the incumbent 0.035.
A lower-own fallback is b1_a0's / b0_a0's (0.535-0.54). Not additive with the siblings.
