# b1_a0: pilot + style-knob sweep (:kk-lunge-p 0.9)

Mechanism: the baseline arm (ken-kh-standoff-style, press params) plus one style tunable, :kk-lunge-p 0.5 -> 0.9 (NS1 lunge from 3.0-5.2 m while climbing at pointer 1).
Evidence (seed0 300, score vs baseline 0.7096): kso-stale 60 0.698; reach-margin 0.8 0.609, 0.3 0.654; hoho-in 0.5/hin-fs 150 0.616; ns-safe 0.5 + step-in 0.5 0.639; dodge/step 0.5 0.650; brawl 0.9 + read-range 3.6 0.667; wave 1.0 + meaty 0.7 0.515; lunge 0.9 0.7112, lunge 1.0 0.6997, lunge 0.9 + bk-ns 0.6 0.6865, lunge 0.9 + read-range 2.6 0.6931.
Not a repeat: first sweep of the style knobs on this side; the other sibling dirs had no proposals.
Result: +0.0016 over baseline, inside noise (SE ~0.02): effectively a tie. Most other knob moves hurt; the pilot sits near a local optimum on these knobs. Risk: seed-300 overfit.
Measured: score 0.7112; anchor 136W/64L/0TO, mix 124/76/0, rest 168/32/0.
