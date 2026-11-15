# b0_a1 (wake): b0_a0's arm with :kk-ns-safe-p 0.5 -> 0.25
Final arm = b0_a0 (:hk-wake 1.0 Hoho in p1.0 fs100 max6 margin1.0) with :kk-ns-safe-p 0.25 (fewer safe-start refusals while he is down).
Runs (score; kh/ih), seed block 300:
- baseline .5686; b0_a0 .5948 (.5457/.6438)
- w1 + :kk-reach-p 0.3: .5817 (.5294/.6340) worse
- w2 + :kk-step-in-p 0: .5915 (.5327/.6503); screen FAIL both (0.519 / 0.524): step-in feeds the wake presses, keep it
- w3 + :hr-p 0.3: .5817 (.5425/.6209) worse
- w4 (FINAL) ns-safe 0.25: **.6079** (kh .5523, ih .6634). kh 99-0-1 / 60-36-4 / 7-83-10; ih 96-2-2 / 71-28-1 / 33-65-2
Descriptor screen (seeds 301-320 vs none): Kenpachi 0.7281 vs arm0 0.487 (x1.50) PASS, K.O. 1.0; Ichigo 0.6431 vs 0.4669 (x1.38) PASS, K.O. 0.875.
Gain +0.0131 over b0_a0 (noise level), +0.039 over baseline; the descriptor margin is the clear gain.
