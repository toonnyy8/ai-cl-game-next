# b2_a0: Ichigo band `mycell`, arm k = arm 0 + `:ikw-stale 300`
Band: mycell (G2 rules 30-35, I hold >= 1 cell). Arm k: same :fn (ichigo-ki-r2b2a1-style) and base as arm 0, with the stale breaker 600 -> 300 frames (free steps go to the generic CPU sooner when nothing changes). Idea: a cell holder stalling in a stand-off should force the action sooner.
Evidence (seed0 300, build db031584): arm 0 table 0.8927; mix-space 0.1 -> 0.8845; gap-p 0 -> 0.8795; stale 300 -> 0.8993 (final). Later variants (whiff/ptr3 mix, wait-max, cont/awaken, punish/confirm) were not completed (shared CPU load).
Measured: score 0.8993; anchor 199/1/0, mix 156/44/0, rest 187/13/0.
band.py pair vs arm 0 (block 300): pooled b 18, c 22, z -0.63; anchor b1 c1; mix b11 c19 z -1.46; rest b6 c2 z 1.41; time-outs 0 / 0. Score gain is not supported by the paired test (noise).
