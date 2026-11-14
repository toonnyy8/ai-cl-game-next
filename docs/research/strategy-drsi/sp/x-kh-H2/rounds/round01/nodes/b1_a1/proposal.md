# b1_a1: x-kh-h-r2-b1a1 (NS side of a cancel)
Arm = baseline + `:xch-sa-p 1.6 :xch-carry-p 0 :xch-sa-wait 2.0`. Baseline 0.5693, parent b1_a0 (sa-wait 3.0) 0.6964.
FINAL (seed0 300): score 0.6997; anchor 199/0/1, mix 80/109/11, rest 142/9/49.
Variants (score; mix; rest): sa-wait 4.0 -> mix 87/107/6, rest 137/11/52 (anchor 0.99 share, score not read); sa-wait 5.0 -> mix 89/102/9, rest 133/12/55;
sa-wait 1.5 -> 0.6667 (63/126/11; 139/7/54); sa-p 1.3 wait 2.0 -> 0.632; sa-p 1.0 carry 3.0 wait 2.0 -> 0.5875; sa-p 0 carry 5 wait 1 -> 0.274.
Finding: carry 0 + max sa-p is right; sa-wait 2.0 (8 frames) a hair over 3.0; mix still loses 109 of 200, time-outs ~25% of rest are the ceiling here.
