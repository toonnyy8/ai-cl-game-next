# b3_a0: back-Step range as the lever
Mechanism: baseline arm (ken-kh-standoff-style, press params) plus the style knobs :kk-step-max 7.0 (back Step answers her move from up to 7 m, default 5) and :kk-step-p 1.0 (default 0.9).
Evidence: one-knob screens vs baseline 0.7096: reach-margin 0.8 0.609, lunge-p 1.0 0.700, dodge/step down 0.658, hoho-in 0.5 0.647, margin 0.2 0.670 (all worse); margin 0.3 + step-max 6.5 0.736; step-max alone 6.5 0.772, 7.0 0.776, 9.0 0.776 (same as 7), + step-p 1.0 0.784. Inert here: hin-fs 100 (identical), kk-bk-ns-p 0.7 ~flat.
Not a repeat: the pilot searched :base/:rules biases; this moves an untouched defensive range knob.
Risk: seed-300 overfit (SE ~0.02); anchor time-outs rise to 11 with step-p 1.0 (step-p 0.9 gives 2).
