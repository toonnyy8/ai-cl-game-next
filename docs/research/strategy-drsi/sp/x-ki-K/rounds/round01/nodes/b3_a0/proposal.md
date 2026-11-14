# b3_a0: style keys re-tuned (KI Kenpachi), baseline c-ki-k-r2-b1a2 (0.3218)
Deltas on :base: :kk-ns-safe-p 0.8 -> 0.0, :kk-reach-p 0.5 -> 1.0, :kk-lunge-p 1.0 (unchanged, v6 vs v1: 1.0 already), :kk-step-max 4.5 -> 3.5. (v1 = first two only.)
Why: under the new exchange rules the "safe" gating (wait for Hoho-proof starts) was passive; dropping it and always requiring reach raised anchor/rest shares.
Runs (seed0 300, SP_BUILD 949a94db54fe), score; groups ko_w:ko_l:to of 200:
- v1 ns-safe 0, reach-p 1: 0.3878
- v2 ns-safe 0, step-in 1, margin 0.7: 0.3432
- v3 step-p 0, dodge-p 0: 0.2409
- v4 bankai-p 1, wave-p 0.9: 0.1716
- v5 = v1 (margin 0.35 already): 0.3878 (inert)
- v6 v1 + step-max 3.5: 0.3894 (FINAL) anchor 106:92:2, mix 27:173:0, rest 100:100:0
- v7 v1 + awaken/kikon/brawl up: 0.2508
- v8 v6 + hin-fs 100: 0.3894 (identical counts: inert, hoho-in-p is 0)
Baseline: anchor 86:106:8, mix 19:181:0, rest 87:112:1. Gain +0.068 (about 3 SE); mix still weak. v6 vs v1 within noise.
