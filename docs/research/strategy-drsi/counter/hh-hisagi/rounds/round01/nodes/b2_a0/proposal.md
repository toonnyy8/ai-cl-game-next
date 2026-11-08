# b2_a0: ken-ki-style + DRIVE switch when the opponent is out of reach (hisagi vs hisagi, HARD)
Slice: `(:dj :out)` OR `(:dj :afar)` (own_share 0.26). Strategy: `:fn ken-ki-style` with `:base (:dswitch 1.0)`.
History: only b0_a0 (ken-ki when not ahead on Konpaku/red state, 0.97 search score). Mine slices by DISTANCE, not by score state: the generic
mirror CPU is weakest at spacing/approach in neutral, so the KI style owns the far-range neutral and hands back to the incumbent when close.
The DRIVE switch (user's 8.16 request) is on inside the slice. Not a repeat: different cue (:dj vs :lead/:ored), smaller own share, adds dswitch.
Dev tried (seed0 800, 100 seeds): ichigo-ki + dswitch close slice 0.665 (own 0.71, bad); ken-ki close slice 0.875 (own 0.59, near cap);
ken-ki close + dswitch 0.915 (own 0.55); ken-ki far + dswitch 0.865 (own 0.26, z 7.3). Second block seed0 900, 50 seeds: 0.84 (z 5.0, own 0.25).
Risk: far-range-only ownership leaves close fights to the weak incumbent; b0's state slice scores higher but owns 0.45. Ken-ki close slice
variants score higher yet sit near the 0.6 cap. Dev numbers did not shrink on the second block (0.865 -> 0.84).
