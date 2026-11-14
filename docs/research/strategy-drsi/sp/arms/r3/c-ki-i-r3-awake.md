# b3_a0 (band awake): awakened Ichigo plays pure pointer-3 + whiff-punish episodes
Band: `awake` (form >= 1). Arm k = arm 0 (ichigo-ki-r2b2a1-style, same base/rules) with `:iks-mix-ptr3 6.0` (arm 0: 0.6) and `:iks-mix-whiff 0.3` (arm 0: 1.5), so the episode mix after awakening is ~95% pointer-3 and ~5% whiff. Same :fn, so a switch keeps state.
Why: awakened, pointer-3 (KESSA lunge/clones) is the damage route; spending episodes on whiff waiting just extends the stand-off.
Evidence (seed0 300, single-change screens on arm k; baseline 0.8927): kessa 1.5 0.901; kessa 3 + whiff 0.5 0.8399; ptr3 3 + whiff 0.3 0.901; ptr3 3 + whiff 0.6 0.9043; + kessa 0.6 0.8828; meaty-p 1 0.8746; gap-p 0 0.896; punish/confirm 1 0.8861; kikon-costly 1 0.8713; hoho-p 0 + wake-hoho 0 0.6518 (bad).
Measured (seed0 300): score 0.9241; anchor 198/2/0, mix 168/32/0, rest 191/9/0 (baseline 0.8927: 199/1/0, 148/52/0, 191/9/0).
band.py pair vs arm 0 (block 300, seeds 301-400): anchor b 2 c 1 z 0.58; mix b 19 c 39 z -2.63; rest b 4 c 4 z 0.0; pooled b 25 c 44 z -2.29 (negative z = candidate better; no time-outs).
Risk: tuned on seed 300 (SE ~0.02); gain is all in the mix group (one Kenpachi member).
