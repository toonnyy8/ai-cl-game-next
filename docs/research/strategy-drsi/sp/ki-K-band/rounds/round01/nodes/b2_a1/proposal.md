# b2_a1: bothrich specialist, Hoho-safety off + stand-off breaker at 30 frames

Band `bothrich` (both hold 2-3 cells). Arm k = arm 0 (`c-ki-k-r2-b1a2`) + `:kk-ns-safe-p 0.3 :kso-stale 30` (id `:c-ki-k-r3-b2a1-k`, same `:fn`).
Mechanism: with both sides SP-rich her Hoho is always available, so the Hoho-safety roll (start J1/NS only when her timed Hoho cannot read it)
mostly stalls him; cutting it to 0.3 and breaking the stand-off after 30 idle frames (arm 0: 60) makes him start J1/NS into her sooner.
Not tested in the logs beyond scores; sibling b2_a0 tried step/dodge 0 (defensive side), this is the offensive side.
Screened 3 variants on block 300 (brawl-p 1.0: 0.6567; reach-margin 0 : 0.6485; this one: 0.6815). Selected on block 300 only: overfit risk.

Final cand.lisp, eval.py seed0 300: score 0.6815 (arm 0 band baseline 0.6518); anchor 186/14/0 TO, mix 66/134/0, rest 158/42/0.
band.py pair vs arm 0 (seeds 301-400): anchor b 14 / c 13 z 0.19; mix b 39 / c 53 z -1.46; rest b 14 / c 19 z -0.87; pooled b 67 / c 85 z -1.46.
