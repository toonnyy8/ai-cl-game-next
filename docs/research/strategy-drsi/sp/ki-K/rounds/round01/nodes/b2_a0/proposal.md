# b2_a0: pilot + NS1 lunge chance 0.5 -> 0.8
Mechanism: the baseline (ken-kh-standoff-style, press params) plus the style knob :kk-lunge-p 0.8 (default 0.5): more NS1 lunges at 3.0-5.2 m.
Evidence (seed0 300): baseline 0.7096; knob variants tried on the baseline: lunge 1.0 0.6997, lunge 0.8 + reach-margin 0.6 0.6766, lunge 0.8 + stale 240 0.6056, wave 1.0 + brawl 0.8 0.6931, reach-margin 0.3 0.6535, dodge 0.8 + hin-fs 150 0.6914. From scratch on plain knobs (no press params): 0.34-0.48, all worse.
Not a repeat: first knob search on top of the baseline; the sibling dirs were empty.
Benefit/risk: gain +0.005 is within noise; the baseline looks near a local optimum for single knobs.
Measured: score 0.7145; anchor 139W/61L/0T, mix 123/77/0, rest 168/32/0.
