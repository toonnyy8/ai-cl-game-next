# b1_a0: h1-range with the generic string-continuation chance cut (:cont 0.3)

Mechanism: baseline h1-range (hisagi-range-style, Bankai distance control, DRIVE switch) plus `:cont 0.3` (default 1.0): the generic CPU links fewer string segments, so fewer of Hisagi's strings overextend into Ichigo's punish.
Evidence: no earlier attempts in this branch; baseline 0.3647. Probes (scratch/): :awaken 0 -> 0.1485 (awakening is needed); :hoho 0 / 2 -> 0.3564 / 0.363; :awaken 6 + :kikon 0 -> 0.2558; hisagi-merged kite arms trade losses for time-outs (mix 8 W / 101 L / 91 T) and stay at ~0.36; :cont 0.3 :hoho 2 -> 0.3614; :cont 0 :hoho 2 -> 0.368; adding :turn 2 :other 0 -> 0.132 (bad).
Honest reading: every variant lies within ~0.36-0.37; the +0.008 is probably noise. The wall is the mix group (Ichigo's c-ki-i-r1-b0a2: ~2% share); no exposed key moves it, so it needs code in hisagi-range-style (a ranged-mode rule vs the pointer-3 lunge).
Measured (seed0 300, final cand.lisp): score 0.373; anchor 171 W / 25 L / 4 T; mix 4 / 196 / 0; rest 48 / 145 / 7.
