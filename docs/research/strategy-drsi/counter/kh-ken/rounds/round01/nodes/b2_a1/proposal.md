# b2_a1 (kenpachi vs hisagi HARD): ken-ki-style while ahead, or level and far (no Reiatsu cue)

Slice: (:lead :ahead) OR (:lead :even, :dj :afar). Strategy: `:fn ken-ki-style :base (:p 1.3)` (= frozen ki-ken). Incumbent otherwise.
History: b0_a0 (ahead | even&afar&mr high, dev 0.37, own 0.54-0.595), b1_a0 (ichigo style, ahead | even far/out, 0.335), b2_a0 (ahead | mr high&afar&free, 0.355).
All share the robust piece (:lead :ahead, own ~0.35, gain 0.24) plus a far arm; mine drops the Reiatsu/state conjuncts: the plain
even&afar arm is what carries the gain (40-seed screens, seed0 800): ahead 0.2375 (own .35); +even&afar 0.4125 (.556); +even&afar&free 0.40 (.557);
+behind&afar 0.225 (.35, useless); +behind&afar&mr high 0.4125 (.563); ahead&free|even&afar 0.3125 (.42, safer); +even&out&free 0.4375 (.5965, at cap);
whole "even" 0.65 but own 0.93 (capped). :dswitch had zero effect on ken-ki-style (identical results).
Final dev (seed0 800 x100): gain 0.39, z 8.5, own 0.552. Second block seed0 900 x50: 0.48 vs 0.00, z 6.9, own 0.595 (near the cap).
Not a repeat in kind: b0_a0 is a near-neighbour (same fn, same far arm without mr high); it is a simplification, essentially the same mechanism.
Risk: own share 0.55-0.595 vs cap 0.6; fallback `((:lead :ahead) (:ost :free))` for the first arm (own 0.42, gain 0.31).
