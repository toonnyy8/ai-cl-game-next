# x-kh-H r1 b0_a0: :xch-j 0 (J side always takes the AS)
Baseline a-hk-pot 0.5083. Arm = baseline + `:xch-j 0` in :base. Seed0 300, 5 evals (HARD):
| k | score | anchor W/L/T | mix W/L/T | rest W/L/T |
|---|---|---|---|---|
| 0 (final) | 0.5577 | 197/0/3 | 67/8/125 | 71/2/127 |
| 0.5 | 0.5544 | 195/0/5 | 67/12/121 | 71/3/126 |
| 1.5 | 0.4604 | 167/8/25 | 57/19/124 | 52/5/143 |
| 2.5 | 0.2162 | 49/109/42 | 46/13/141 | 33/17/150 |
Monotone: more J after a cancel is worse; k=0 best. Time-outs in mix/rest stay ~62-64% (not reduced by this key).
