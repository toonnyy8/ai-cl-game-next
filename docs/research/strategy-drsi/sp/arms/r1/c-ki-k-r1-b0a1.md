# b0_a1: parent b0_a0 (0.8366) + back-Step range (:kk-step-max 7.0, :kk-step-p 1.0)
Mechanism: b0_a0's arm (pilot base + :kk-step-in-p 0, :kk-awaken-p 0, :kk-reach-margin 0.35, :kk-wave-p 0, :kk-lunge-p 1.0, :kso-stale 60) plus b3_a0's untried-with-it defensive knobs: back Step answers her move from up to 7 m, always when no Hoho is open.
Evidence: b3_a0 measured step-max 7 / step-p 1.0 alone 0.784 on the baseline (0.7096); b0_a0 0.8366. Combined here (seed0 300): step-max 7 0.8564, 6 0.8498, 7 + step-p 1.0 0.8746; + dodge-p 0.9 0.8696. Reach-margin 0.4 and stale 90 / step-max 8 variants played byte-identically to the final (0.8746).
Not a repeat: merges two different lever groups (b0_a0's offence/awaken knobs, b3_a0's defence range).
Risk: seed-300 overfit (SE ~0.02, gain +0.038 is about 2 SE); anchor time-outs 8 (b0_a0: 0).
Measured (seed0 300): score 0.8746; anchor 175W/17L/8TO, mix 166/32/2, rest 186/13/1.
