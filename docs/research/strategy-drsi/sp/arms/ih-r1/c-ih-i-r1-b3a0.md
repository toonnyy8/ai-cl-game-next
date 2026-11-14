# b3_a0: baseline with the walk-in band collapsed (:range 0.25)
Mechanism: baseline b0a2 (ichigo-ki-style) with :base :range 0.7 -> 0.25. The scale shrinks the generic fallthrough's walk band, so Ichigo closes on kiting Hisagi instead of hovering.
Evidence (seed0 300, baseline 0.8993; rest group 154 wins / 44 time-outs): mix variants (kessa/whiff/space heavy) 0.878-0.898, wait-max 20 0.906, gap-wait 7.0 0.876, generic mix 0.3 0.919, getsuga/retreat 0.908, punish 1.0 0.896, range 0.4 0.929, range 0.25 0.9373, range 0.1 0.901 (too low).
Not a repeat: baseline untouched except the one lever; a sweep shows range is the only key that cut rest time-outs (44 -> 33).
Risk: seed-300 overfit; range < 0.2 degrades.
Measured: 0.9373 (anchor 199/1/0, mix 199/1/0, rest 167/0/33 K.O. wins/losses/time-outs).
