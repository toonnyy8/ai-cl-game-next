# b3_a1 (band awake): awakened Ichigo plays pointer-3 episodes, lunge distance 5.0 m
Band: `awake` (form >= 1). Arm k = arm 0 (ichigo-ki-r2b2a1-style, same base/rules) with `:iks-mix-ptr3 6.0` (arm 0: 0.6) and `:iks-getsuga-min 5.0` (arm 0: 6.5), prepended (first occurrence wins). Same :fn, state kept.
Why: awakened, pointer-3 (KESSA) is the damage route; ptr3-dominant episodes plus an earlier Getsuga range shorten the stand-off. Same direction as sibling b3_a0 (parent), not structurally new: other axes were inert or worse.
Evidence (seed0 300, baseline 0.8927; screens on arm k): gap-off-n 0 0.8927 (inert); getsuga-min 5.0 0.8944; ptr3 6 0.9076; ptr3 6 + kessa 0 0.8993; retreat-p 1 0.8927; steer-p 1 0.8845; whiff 4 0.8878; mix-generic 1 0.7508; wait-max 20 0.8597; ptr3 6 + getsuga-min 5.0 0.9092 (kept).
Measured (seed0 300): score 0.9092; anchor 199/1/0, mix 161/39/0, rest 188/12/0.
band.py pair vs arm 0 (block 300): anchor b1 c1 z 0.0; mix b25 c38 z -1.64; rest b6 c3 z 1.0; pooled b32 c42 z -1.16 (no time-outs).
Risk: tuned on seed 300 (SE ~0.02); gain is only the mix group; b3_a0 (ptr3 6 + whiff 0.3) scored 0.9241.
