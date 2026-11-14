# b2_a1: clash off, awaken-break off, awaken-kikon 1.2
cand.lisp = baseline + `:clash-p 0.0 :clash-margin 0.3 :awaken-break-p 0.0 :awaken-kikon-p 1.2`. Score 0.8812 (baseline 0.7706; sibling b2_a0 0.8614), seed0 300, build 949a94db54fe.
Groups: anchor 199/1/0, mix 165/31/4, rest 167/30/3 (ko_wins/losses/timeouts of 200).
Runs (3 of 8): v1 clash 0 + break 0 + kikon 0 = 0.8779 (anchor 199/1/0, mix 163/33/4, rest 167/30/3); v2 clash-p 0.3 = 0.8597 (worse than 0); v3 = v1 with kikon 1.2 = 0.8812.
Reading: clash off is the main gain (a0's finding); breakers off costs nothing, kikon 1.2 is within noise of v1.
