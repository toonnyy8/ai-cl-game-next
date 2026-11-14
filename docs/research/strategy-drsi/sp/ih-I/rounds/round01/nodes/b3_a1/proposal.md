# b3_a1: b3_a0 (baseline with :range 0.25), tested for stacking with other levers
Mechanism: cand.lisp is b3_a0's arm (ichigo-ki-style, :range 0.7 -> 0.25), id changed. Every stacked lever I tried failed to beat it.
Evidence (seed0 300, parent 0.9373): +meaty-p 1.0 0.9241; +punish/confirm 1.0 0.9224; +steer 1.0 hoho-p 0.5 0.8911; +hold-awaken 0 other 2.0 0.9208; +hoho-follow 80 getsuga-min 6.5 0.9191; +hoho 0.3 turn 1.5 0.9373 (rest 165/0/35, no gain); +ns-wait 16 meaty-far 3.5 0.8713; range 0.3 0.9307.
Not a repeat in spirit only: no improvement found; the arm equals the parent.
Risk: seed-300 overfit; the 33 rest time-outs remain.
Measured: 0.9373 (anchor 199/1/0, mix 199/1/0, rest 167/0/33).
