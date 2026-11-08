# b2_a0 (kenpachi vs hisagi HARD): ken-ki-style while ahead, or high Reiatsu + far + free

Slice: (:lead :ahead) OR (:mr :high, :dj :afar, :ost :free). Strategy: `:fn ken-ki-style :base (:p 1.3)`. Incumbent otherwise.
History: b0_a0 (same fn, slice ahead | even&afar&mr high, own 0.54-0.595) and b1_a0 (ichigo style, ahead | even far/out). Mine keeps the
only robust piece (ahead, own ~0.32) but replaces the "level" arm by a Reiatsu arm that ignores the lead (mr high & afar & free, any lead) and
needs :ost free to keep own share down: own 0.535-0.57 (margin >= 0.03 under the 0.6 cap) instead of 0.54-0.595.
Screens (40 seeds, seed0 800): mr high&afar|out alone: gain 0.04 (own 0.08, useless alone); ahead|mr high&afar|mr high&out: 0.40 (own 0.593);
ahead|mr high&afar: 0.47/0.43 (own 0.601/0.593, at the cap); ahead&free | mr high afar | mr high out free: 0.275 (own 0.41); ichigo style variant 0.24.
Final (seed0 800 x100): see dev.json (gain 0.355, z 8.1, own 0.535); second block seed0 900 x50: 0.42 vs 0.00, z 6.5, own 0.570.
Risk: the gain is mostly the :lead :ahead arm (same as siblings), so not additive with them; own share must stay < 0.6 on search seeds.
