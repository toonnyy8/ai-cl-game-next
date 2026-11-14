# b1_a0 (x-ki-I, round 1, NS side of a cancel)
Baseline c-ki-i-r2-b2a2 (0.759) + `:xch-sa-p 1.5 :xch-carry-p 0.0 :xch-sa-wait 2` in `:base`. Measured at --seed0 300, 600 matches:
- v1 (sa-p 1.5, carry-p 0): 0.83 (anchor 200/0, mix 119/81, rest 181/19, 0 time-outs)
- v2 (sa-p 0, carry-p 5): 0.5611 (mix 18/182, rest 119/80, 1 time-out): flawed, always carrying on loses
- v3 FINAL (v1 + sa-wait 2): 0.8383 (anchor 200/0, mix 119/81, rest 186/14, 0 time-outs)
Why: always watching for his turn and SA-ing it (never carrying on blind) is better; wait 2 frames helps `rest` slightly (v3 vs v1 is 5 more wins, may be noise; the mix group is unchanged).
