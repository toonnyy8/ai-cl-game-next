# b3_a0 (round 2): exchange keys on the style baseline, Hisagi vs Kenpachi
Final cand = scratch/v4.lisp = baseline x-kh-h-r1-b3a2 + :clash-p 1.7 :xch-sa-p 1.5 :awaken-break-p 1.9 :xch-carry-p 3 :clash-margin 1.6 (id :x-kh-h-r2-b3a0).
Measured (seed0 300): 0.7327; anchor 199:0:1, mix 97:100:3, rest 145:8:47 (ko_wins:losses:timeouts). Baseline 0.5693 (195:0:5 / 31:115:54 / 116:14:70).
Runs (score; anchor / mix / rest): v1 clash-p 1.7 + xch-sa-p 1.5 = 0.703 (199:0:1 / 82:111:7 / 142:7:51); v2 v1 + clash-margin 1.6 = 0.7228;
v3 v1 + awaken-break-p 1.9 + xch-carry-p 3 = 0.731 (98:98:4 mix); v4 = v3 + clash-margin 1.6 = 0.7327; v5 v3 + xch-sa-wait 1.5 = 0.7211;
v6 v4 + xch-j 2.0 + awaken-kikon-p 1.2 = 0.7096 (worse). Findings: the mix's Kenpachi arm (always AS after a cancel) was beating Hisagi in exchanges; scaling up the clash / SA chances cuts its time-outs and wins.
Style keys left as the baseline's; 6 runs used.
