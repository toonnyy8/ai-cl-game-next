# b2_a1: b3_a0's style knobs plus :iks-ns-wait 24
Mechanism: baseline press arm + :iks-mix-ptr3 0.6, :iks-mix-space 0.1, :iks-wait-max 40, :iks-gap-p 1.0, :iks-gap-fs 150 (the b3_a0 point, reproduced at 0.7772) + :iks-ns-wait 24 (default 32: punish his whiffing NS sooner).
Evidence: sibling b3_a0 0.7772 was the best; I started from it. Variants on it (seed0 300): all chances 1.0 0.7211; gap-fs 200 + gap-wait 6 0.7673; mix-generic 0 + whiff 0.1 0.7475; meaty/wake-hoho/steer 1.0 0.7607; :lead rules on ptr3 / wait-max / hoho (0.7211-0.7723, none better); :hold-awaken 0 + :kikon 1 identical (inert); gap-wait 7 0.6931; meaty-far 4.5 0.7112; hoho-follow 50 identical (inert); ns-wait 24 0.7838.
Not a repeat: a local refinement of b3_a0; situational :lead rules on style keys were tried and did not help.
Risk: ns-wait gain (+0.007, anchor only, mix/rest identical) is within noise; seed-300 overfit.
Measured (seed0 300): score 0.7838; anchor 169/28/3, mix 142/58/0, rest 161/39/0 (wins/losses/timeouts).
