# b2_a2: clash off, awaken-break off, awaken-kikon 1.2, clash-margin 2.0 (inert at clash-p 0)
cand.lisp = baseline + `:clash-p 0.0 :awaken-break-p 0.0 :awaken-kikon-p 1.2 :clash-margin 2.0`. Score 0.8812 (baseline 0.7706), seed0 300, build 949a94db54fe.
Groups: anchor 199/1/0, mix 165/31/4, rest 167/30/3 (identical counts to b2_a1: margin is inert with clash-p 0).
Runs (5 of 8, from b2_a1's cand): v1 margin 2.0 = 0.8812 (inert); v2 break-p 1.9 = 0.8663 (anchor 196/4, mix 159/38/3); v3 kikon 0 = 0.8779; v4 clash-p 0.15 = 0.8399 (mix 147/50/3); final re-run 0.8812.
Reading: no setting of these keys beats clash off; any clash worsens mix; strong breakers cost ~1.5 points; kikon is noise.
