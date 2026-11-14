# x-kh-H2 r1 b0_a0: :xch-j 0.5 (J side mostly takes the AS)
Baseline x-kh-h-r1-b3a2 0.5693 (no exchange keys). Arm = baseline + `:xch-j k` in :base. Seed0 300, HARD, 4 evals.
| k | score | anchor W/L/T | mix W/L/T | rest W/L/T |
|---|---|---|---|---|
| 0 | 0.5941 | 193/0/7 | 39/106/55 | 125/15/60 |
| 0.25 | 0.5974 | 199/0/1 | 44/101/55 | 116/11/73 |
| 0.5 (final) | 0.6073 | 198/0/2 | 52/107/41 | 115/15/70 |
| 1.5 | 0.5577 | 190/2/8 | 31/127/42 | 114/19/67 |
Less J after a cancel helps a little (+0.02-0.04 over baseline); k 0-0.5 differ by noise, 1.5 is worse (monotone as in round 1). Mix (the new admitted K arm) stays mostly lost (K.O. losses ~100 of 200): this key does not fix it.
