# b2_a1: Ichigo band `mycell`, arm k = arm 0 + more punish / bait mixing
Band: mycell (G2 rules 30-35, I hold >= 1 cell). Arm k: same :fn and base as arm 0, plus `:iks-punish-p 1.0 :iks-mix-ptr3 1.0 :iks-mix-whiff 3.0` (always punish a seen whiff, pointer-3 and whiff bait modes weighted up). Idea: a cell holder has the gauge to cash every punish.
Evidence (seed0 300, build db031584; score, mix wins): arm 0 table 0.8927; punish+confirm 1.0 + wait-max 20 0.901; hoho/wake-hoho 1.0 0.8828; gap-p 0 + meaty 1.0 0.8993; stale 200 + wait-max 20 0.8135; cont 2.0 + walk-in up 0.8828; range 1.0 + hoho-p 0 0.6634 (cliff); final 0.9026; adding confirm / wait-max 20 0.8861.
Measured (final): score 0.9026; anchor 200/0/0, mix 155/45/0, rest 189/11/0.
band.py pair vs arm 0 (block 300): pooled b 42, c 48, z -0.63; anchor b0 c1 z -1.0; mix b33 c40 z -0.82; rest b9 c7 z 0.5; time-outs 0 / 0. Gain is noise; not supported by the paired test.
