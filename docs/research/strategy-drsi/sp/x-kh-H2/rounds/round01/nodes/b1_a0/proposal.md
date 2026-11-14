# b1_a0: x-kh-h-r2-b1a0 (NS side of a cancel)
Arm = baseline x-kh-h-r1-b3a2 + `:xch-sa-p 1.6 :xch-carry-p 0 :xch-sa-wait 3.0` (the round-1 winner b1_a2's values from sp/x-kh-H, carried over).
Baseline 0.5693. Final (seed0 300): 0.6964; anchor 200/0/0 TO, mix 80/109/11, rest 139/12/49.
Variants: sa-wait 1.75 -> 0.6799 (mix 68/124/8, rest 142/8/50); sa-wait 1.75 + carry 1.0 -> 0.6683 (mix 71/115/14, rest 134/9/57).
Finding: sa-p 1.6 / carry 0 carries over; mix (new x-kh-k-r1-b0a2) still loses 109 of 200; rest time-outs ~25%.
