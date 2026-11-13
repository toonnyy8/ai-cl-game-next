# b0_a0: press parameters + Ichigo style knobs (shorter hover, shut-gauge threshold 150, no generic episodes, more whiff play)
Mechanism: baseline a-ichigo-press (fn ichigo-ki-style) plus four :iks-* keys: :iks-wait-max 30 (hover per episode, default 150), :iks-gap-fs 150 (96), :iks-mix-generic 0.0 (0.04), :iks-mix-whiff 0.5 (0.26).
Evidence (seed0 300, one change each on baseline 0.6122): wait-max 60 0.670, gap-fs 150 0.655, mix-generic 0 0.625, hoho-p 0/0.5 worse, punish/confirm 1.0 worse, wait-max 300 worse, getsuga-min/meaty/gap-p no effect. Combos: wait-max 60+gap-fs 150 0.7096; +mix-generic 0 0.7129; wait-max 30 0.7459; wait-max 10 0.7013; gap-fs 200 0.7294; +ptr3 0.5 0.7277; +whiff 0.5 0.7591.
Not a repeat: the baseline only set MCTS biases; the style's own pacing and mix were never searched.
Risk: tuned on seed 300 (overfit, small gains of the last steps are within noise); fewer hovers means more pressure.
Measured final: score 0.7591; anchor 159W/40L/1TO, mix 138W/62L/0TO, rest 160W/40L/0TO.
