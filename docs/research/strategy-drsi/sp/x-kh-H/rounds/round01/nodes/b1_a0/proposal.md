# b1_a0: x-kh-h-r1-b1a0 (NS side of a cancel)
Arm = incumbent a-hk-pot + `:xch-sa-p 1.6 :xch-sa-wait 2.0` in :base. Baseline score 0.5083.
Final score 0.665 (anchor 195 W/0 L/5 TO; mix 112/10/78; rest 93/2/105).
Measured (seed0 300), score / TO anchor,mix,rest:
- xch-carry-p 5: 0.5165 / 12,124,135
- xch-sa-p 0 : 0.2443 / 61,140,154
- xch-sa-p 1.6: 0.6584 / 9,69,114
- sa-p 1.6 + carry-p 5: 0.6485 / 9,81,108
- sa-p 1.6 + sa-wait 2: 0.665 / 5,78,105 (final)
- sa-p 1.6 + sa-wait 3: 0.6568 / 7,79,108
Finding: SA after cancel is the lever (monotone in sa-p); carry-p hurts; sa-wait 2-3 ~ flat/slightly positive. Time-outs still ~50%.
