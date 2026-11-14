# b0_a1: Ichigo band `myburst`, pressure arm k

Band: `myburst` (G3 rules 38, 39). Arm k = arm 0 (`ichigo-ki-r2b2a1-style`) with the first-wins keys `:iks-wait-max 0 :iks-ns-wait 8 :iks-mix-space 1.0 :iks-mix-ptr3 0.3` (arm 0: 40 / 24 / 0.0 / 0.6); id `:c-ki-i-r3-b0a1-k`. Idea: while her burst runs, stop waiting (no neutral wait, 8-frame NS wait) and play the Space mix, fewer pointer-3 plans. b0_a0 (defensive) was read: 0.8993, z -0.43.
Tried (seed0 300): ranged (getsuga-min 3.5, ptr3 1.5) 0.8845; ranged + wait-max 90 0.8762; gap-p 0 + getsuga-min 4.5 0.8927 (= baseline); no hoho/meaty + :b-j1/:b-walk-in 0.3 0.8944; final (pressure) 0.896. Baseline 0.8927.
Measured final: score 0.896; anchor 199/1/0, mix 150/50/0, rest 191/9/0.
band.py pair vs arm 0, block 300: pooled b 28, c 30, z -0.26 (timeouts 0/0); mix b24 c26 z -0.28; rest b4 c4; anchor b0 c0.
Verdict: +0.0033 over baseline, noise; the band fires (counts differ) but no gain. Not claimed to beat arm 0.
