# b1_a0 (x-kh-K, round 1): NS-side cancel keys
Final arm = baseline + `:xch-sa-p 1.5 :xch-carry-p 0.0 :xch-sa-wait 3.0` (v4). Score 0.4488 (baseline 0.4357), seed0 300, 600 matches.
Groups: anchor 191/9/0 (ko_w/ko_l/to), mix 19/25/156 (baseline-less, a-hk-pot), rest 59/19/122.
Runs (all seed0 300): v1 sa-p 1.5 carry 0 -> 0.4488 (mix 11/21/168, rest 63/9/128); v2 sa-p 0 carry 5 -> 0.4043 (mix 6/71/123, rest 54/43/103: many losses);
v3 v1 + sa-wait 2.0 -> 0.4175 (mix 7/24/169, rest 50/13/137); v4 v1 + sa-wait 3.0 -> 0.4488 (mix 19/25/156, rest 59/19/122).
Reading: always SA on a cancel, never carry on, is the better direction; carry-heavy loses badly. sa-wait 3.0 adds mix K.O.s and fewer time-outs than v1 at equal score.
