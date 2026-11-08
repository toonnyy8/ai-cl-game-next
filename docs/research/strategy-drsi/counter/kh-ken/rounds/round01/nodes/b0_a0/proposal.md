# b0_a0 (kenpachi vs hisagi HARD): ken-ki-style while ahead, or level and far with high Reiatsu

Slice (:own): (:lead :ahead) OR (:lead :even, :dj :afar, :mr :high). Strategy: `:fn ken-ki-style :base (:p 1.3)` (= frozen ki-ken's content).
Incumbent otherwise.

History: none (round 1, siblings empty). Baseline: incumbent 0.035 vs Hisagi's KI-style CPU.
Evidence (dev, seed0 800 unless noted; inc ~0.02-0.035):
- whole game ken-ki-style 0.525 (20 seeds), ichigo-ki-style 0.475: the incumbent is simply weak vs a KI style opponent, any KI style helps.
  (Ichigo style as slice strategy was worse in 50-seed slices: 0.12 vs ken 0.27 for lead behind|even.)
- own share is the constraint: lead behind|even / mr high / dj in|reach own 0.87-0.98 (capped). :lead :ahead alone owns 0.32, gain +0.22.
- adding "even and far" raises gain with own share: ahead|even&afar 0.46 (own 0.586); +mr high 0.43 (0.572); +mr low 0.26 (0.379);
  ahead|even&out 0.29 (0.41); ahead&mr high | even&afar only 0.12 (0.19).
- final cand: seed0 800 x100 seeds: 78/200 vs inc 4/200, gain 0.37, b/c 77/3, z 8.3, own_share 0.542. Second block seed0 900 x50: 0.47 vs
  inc 0.00 (gain 0.47, z 6.9) but own_share 0.5953 (just under the cap 0.6).
Risk: own_share 0.54-0.595 sits near the 0.6 cap; if the search seeds push it over, the score falls to the incumbent 0.035. Safer
fallback (own 0.40-0.43, gain 0.25-0.30): ahead | even&out | even&afar&mr low.
Not a repeat: no earlier cell. Mechanism: pressure with the same KI style CPU Hisagi plays, in the lead-and-far situations.
