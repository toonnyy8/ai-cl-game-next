# b3_a1: b0_a0's tuned style knobs + back-Step range (step-max 7.0, step-p 1.0)
Mechanism: b0_a0 (step-in-p 0, awaken-p 0, reach-margin 0.35, wave-p 0, lunge-p 1.0, kso-stale 60) combined with b3_a0's back-Step levers :kk-step-max 7.0 :kk-step-p 1.0. Inert :b-* biases dropped (style returns T, KNOBS 2.1).
Evidence: b0_a0 0.8366 (measured), b3_a0 step-max/step-p lifted baseline 0.7096 -> 0.784. Untried combination of the two branches.
Measured (seed0 300): v1 step-max 7 only 0.8564; step-max 6 0.8498; final (7.0 + step-p 1.0) 0.8746.
Final groups: anchor 175W/17L/8TO, mix 166/32/2, rest 186/13/1.
Risk: seed-300 overfit; anchor time-outs rise (8) with step-p 1.0.
