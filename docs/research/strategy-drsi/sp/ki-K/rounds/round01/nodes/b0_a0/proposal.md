# b0_a0: pilot + style-knob tuning (no awaken, no step-in, tighter reach, wave answer off, lunge on, stand-off 60)
Mechanism: baseline arm (ken-kh-standoff-style + press base/biases) plus 6 style knobs: :kk-step-in-p 0, :kk-awaken-p 0, :kk-reach-margin 0.35, :kk-wave-p 0, :kk-lunge-p 1.0, :kso-stale 60.
Evidence: sibling nodes had no proposals. One-at-a-time screens on the baseline (seed0 300): step-in-p 0 -> 0.7426; on top of it awaken-p 0 -> 0.7937, margin 0.35 -> 0.7591, wave-p 0 -> 0.736, lunge 1.0 -> 0.7162; combined 0.8267; + stale 60 -> 0.8366. Harmful (measured): ns-safe-p 0.5 (0.607), dodge/step-p low (0.611), hoho-in 0.5 (0.647), margin 0.8 (0.609) or 0.25 (0.630), wake-hoho-p 0 (0.386), meaty-p 0 (0.439), kikon-red-p 0 (0.517).
Not a repeat: first use of the style keys on top of the pilot (a different lever group from the pilot's :b-*/:range base).
Risk: seed-300 overfit (greedy coordinate search on the same 600 matches); small steps (margin 0.35 vs 0.25 is a cliff) suggest noisy interactions.
Measured (seed0 300): score 0.8366; anchor 175W/25L/0TO, mix 152/48/0, rest 177/23/0 (baseline 0.7096).
