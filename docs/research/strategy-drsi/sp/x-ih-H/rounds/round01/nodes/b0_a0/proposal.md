# b0_a0: :xch-j scale on the J side of a cancel (x-ih-H r1)
Baseline (0.5396) + `:xch-j k` in `:base`; id `:x-ih-h-r1-b0a0`. 4 runs, seed0 300, SP_BUILD 949a94db54fe.
| k | score | anchor W/L/TO | mix W/L/TO | rest W/L/TO |
|---|---|---|---|---|
| 0.0 | 0.5181 | 191/0/9 | 43/141/16 | 77/86/37 |
| 0.5 | 0.5247 | 190/1/9 | 46/130/24 | 79/80/41 |
| 1.6 | 0.5627 | 191/3/6 | 60/129/11 | 87/88/25 |
| 2.5 | 0.6518 | 198/2/0 | 89/107/4 | 105/77/18 |
Final cand = k 2.5 (J share clamps to 1: always the next J, never the AS at once). Monotonic in k; the top of the range is best, so more J cuts time-outs and wins more against the mix. Not tried: k 2.0 (J share 0.8).
