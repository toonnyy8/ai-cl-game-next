# b0_a1 kite: wide, always-on kite (:hkk-*)
Final arm = v1: `:hkk-near 5.0 :hkk-near-bankai 6.0 :hkk-far 1.0 :hkk-poke-min 2.0 :hkk-poke-max 7.0 :hkk-window 120` added to :base (back off from far, even when close, long poke window).
Measured vs ichigo (block 300): v1 0.6304 (anchor 186/8/6, mix 127/68/5, rest 66/130/4; baseline 0.6287 = noise). Screen v1: vs Kenpachi +0.25 m FAIL (2.527 vs 2.275), vs Ichigo +0.71 m PASS, K.O. 0.8.
v2 (near 6.0 / bankai 7.0 / far 0.5 / poke 3.5-8.0 / window 30): 0.6172 (181/11/8, 126/68/6, 64/131/5); screen K +0.30 FAIL, I +0.81, K.O. 0.6 (Ichigo) - worse score.
Reading: the :hkk-* keys saturate near +0.3 m vs Kenpachi (his none closes regardless); no setting reaches +0.5. Score unmoved beyond noise.
