# b0_a1 (kk-ken, round 1): ken-ki-style when near and not ahead, or behind and free

Slice: lead behind/even AND dj in/reach; OR lead behind AND ost free; OR mr low AND dj in. Strategy `:fn ken-ki-style`.
History: b0_a0 (lead behind/even, 0.98), b1_a0 (close and not ahead / mr low, 0.975), b2_a0 (behind/mr low/startup, 0.905): same mechanism
(style CPU stronger than the incumbent). Mine combines lead with range, dropping out/afar where b1 found the style CPU no better.
Probes: lead+mr low / lead+ost free 0.69; behind+close, even+startup/active 0.875; this slice 0.985 (own 0.37, z 9.7) on seed0 800 x100.
Not a repeat: a new conjunction of the lead and range cues; still the same strategy. Risk: whole-replacement in disguise; overfit small.
