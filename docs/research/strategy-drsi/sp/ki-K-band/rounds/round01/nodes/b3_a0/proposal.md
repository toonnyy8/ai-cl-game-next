# b3_a0: band hisburst, arm k = arm 0 + a defensive/discipline knob set
Band: hisburst (G3 rules 37, 39). Arm k (ken-kh-standoff-style, same :fn, knob deltas only): :kk-ns-safe-p 1.0 (0.8), :kk-reach-p 1.0 (0.5), :kk-dodge-p 1.0, :kk-step-p 1.0, :kikon 0.0 (0.3). Idea: while Ichigo's burst runs, start nothing unsafe (full Hoho-safety and reach discipline), dodge, never hold an SP into a Kikon.
Variants tried (seed0 300, baseline 0.6518): reach0/safe1/stepmax7 0.6304; step-in+safe0 0.6551; bankai/wave/meaty0/nsstop0 0.6568; +brawl 0.6568; +wave/link 0.6667 (same as final); +stepmax7/meaty0/lunge0 0.6386; +reachmargin1.0 0.6584.
Measured (final cand.lisp): score 0.6667; anchor 197W/3L/0TO, mix 44/156/0, rest 160/40/0.
Arm 0 on same block: anchor 187, mix 52, rest 153 K.O. wins.
band.py pair (A=arm 0, B=cand, seeds 301-400): anchor b3 c13 z-2.5; mix b39 c31 z0.96; rest b12 c19 z-1.26; pooled b54 c63 z-0.83 (0 time-outs both). b = arm 0 won and cand did not, so negative z favours cand.
Risk: block-300 only, tuned on it; mix group is worse (-8), gain is all in anchor (+10).
