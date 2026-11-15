# b0_a0 kite: :hkk-* keys

Final arm = scratch/v3: `:hkk-near 2.8 :hkk-far 2.4 :hkk-poke-min 3.4 :hkk-window 70` added to `:base` (kite starts later and tighter, pokes from farther, longer window). Nothing else changed.

Measured (vs ichigo, seed block 300; baseline 0.6287: anchor 182/10/8, mix 127/70/3, rest 69/129/2):

| variant | keys | score | anchor | mix | rest |
|---|---|---|---|---|---|
| v1 | near 4.2 far 1.5 window 80 (earlier, wider kite) | 0.6155 | 179/10/11 | 124/72/4 | 67/130/3 |
| v2 | near 4.0 far 1.5 poke 2.2-5.0 window 40 | 0.6172 | 178/11/11 | 123/68/9 | 70/126/4 |
| v3 (final) | near 2.8 far 2.4 poke-min 3.4 window 70 | 0.6337 | 182/11/7 | 127/68/5 | 72/126/2 |
| v4 | near 3.0 far 2.6 poke 3.8-5.0 window 100 | 0.6304 | 185/10/5 | 125/72/3 | 69/129/2 |

Reading: kiting earlier/wider (v1, v2) is worse (-0.011 to -0.013, near noise edge); narrowing it (v3, v4) is +0.002 to +0.005, i.e. noise. The keys move play (counts differ) but none beats the baseline beyond noise. Mean distance not measured (coordinator's screen.json).
