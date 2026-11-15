# b0_a1 (k-rush, approach)
Final arm = run2: vs baseline `:kk-reach-margin` 0.35->0.05, `:kk-hoho-in-max` 6.0->3.0, `:kk-hin-fs` 100->200 (Hoho in only close, keep one Hoho in reserve).
| run | arm | score | KI W-L-T anchor/mix/rest | KH |
|---|---|---|---|---|
| 1 | no Hoho in (p 0), margin 0.0 | 0.6493 | 107-81-12 / 66-128-6 / 20-180-0 | .9752 |
| 2 (final) | margin .05, hoho-in-max 3.0, hin-fs 200 | 0.6518 (KI .33, KH .9736) | 106-82-12 / 67-127-6 / 24-176-0 | 199-1-0 / 196-0-4 / 192-0-8 |
| 3 | run2 with step-in-p 0 and max 3.5 | 0.6518 (identical to run2: step-in-p and max 3.0 vs 3.5 inert here) | | |
| 4 | margin 0.0, max 3.5, fs 200 | 0.6502 | 108-80-12 / 66-128-6 / 20-180-0 | .9752 |
Descriptor check (seeds 301-320 vs Ichigo none, 40 matches): final arm nstart_r = arm0 1.250 + 0.274 = 1.524 (< 1.25 x = 1.5625): FAIL by a hair; K.O. 1.000. Run 4's arm: +0.231 (worse). Approach keys move play little; gain over baseline (+0.006) is noise.
