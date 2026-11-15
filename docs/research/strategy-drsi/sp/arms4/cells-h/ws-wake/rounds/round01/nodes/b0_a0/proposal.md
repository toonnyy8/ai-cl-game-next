# b0_a0 (wake): keys around :hk-wake 1.0
Final arm = scratch/v6: :base (:hk-wake 1.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-reach-margin 1.0 :kk-ns-safe-p 0.5)
Idea: while he is down, get in range fast (Hoho in, longer start reach, fewer safe-start refusals).
Runs (score; kh/ih): baseline .5686 (.5229/.6144)
- v1 :kk-meaty-p 1.0 alone: .5686, counts identical = inert (arm is not in control at the knockdown event)
- v2 hoho-in 1.0, fs 100, max 6, margin 1.0: .5817 (.5327/.6307)
- v3 v2 + :kk-lunge-p 1.0 :hr-p 0: .5670 (.5000/.6340) worse
- v4 v2 + max 7 + ns-safe 0: .5866 (.5163/.6569); v5 max 6 + ns-safe 0: identical to v4 (max 7 vs 6 inert)
- v6 v2 + ns-safe 0.5: .5948 (.5457/.6438) final. kh 99-0-1 / 61-36-3 / 4-80-16; ih 92-3-5 / 69-28-3 / 33-66-1
Gain +0.026 over baseline; one seed block, so only partly above noise. One-job descriptor not measured.
