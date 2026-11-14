# b1_a1 (x-kh-K, round 1): NS-side cancel keys
Final arm = baseline + `:xch-sa-p 1.6 :xch-carry-p 0.0 :xch-sa-wait 3.0` (v4). Score 0.4571 (baseline 0.4357; parent b1_a0 0.4488), seed0 300, 600 matches.
Groups: anchor 196/4/0, mix 12/16/172, rest 66/8/126 (ko_w/ko_l/to).
Runs (seed0 300): v1 parent + wait 4.0 -> 0.434; v2 parent + sa-p 1.0 -> 0.4059; v3 parent + carry 1.0 -> 0.4422; v4 parent + sa-p 1.6 -> 0.4571; v5 parent + carry 0.3 -> 0.4389.
Reading: more always-SA is better (sa-p 1.0 < 1.5 < 1.6); any carry hurts; wait 3.0 beats 4.0 and (parent's) 2.0.
