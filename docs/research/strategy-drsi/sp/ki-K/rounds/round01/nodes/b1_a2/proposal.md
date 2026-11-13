# b1_a2: b1_a1 (0.8746) + :kk-reach-p 0.5
Mechanism: b1_a1's arm plus :kk-reach-p 0.5 (half of approaches may start a move that does not reach her, rather than always walking in).
Evidence (seed0 300, parent 0.8746, reproduced): step-max 8 0.8746 (= no change), dodge-p 0.5 0.8713, ns-safe-p 0.5 0.8267, kikon-red-p 0.5 0.7822, meaty-p 0.5 0.6601, brawl 0.9 0.8663, hoho-in 0.5 + hin-fs 150 0.8251, reach-margin 0.2 0.8746; reach-p 0.5 0.8779; on top of it: margin 0.2 0.8779, climb-p 0.5 0.8416, bk-ns-p 0.6 0.8597, wake-hoho 0 0.599, link-p 0.7 0.8696, brawl+read 2.6 0.8449; rules (lead behind -> ns-safe 0; lead split reach-p; or high -> ns-safe 0) 0.8449 / 0.8383 / 0.7855.
Not a repeat: a different knob (reach-p) after the parent's step-range stacking; situational :rules on style chances tried and failed.
Result: +0.0033 over parent, inside noise (SE ~0.02): a tie. The parent sits at a local optimum on these knobs; every other move hurt or was inert.
Measured: score 0.8779; anchor 170W/26L/4TO, mix 174/25/1, rest 185/14/1.
