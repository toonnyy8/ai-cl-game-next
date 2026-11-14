# x-kh-H r1 b0_a1: :xch-j 0 core + :clash-margin 0.5
Parent b0_a0 (:xch-j 0) 0.5577 at seed0 300. Arm = parent + `:clash-margin 0.5` (both reads: clash distance test and J side's AS reach test).
| variant | score | anchor W/L/T | mix W/L/T | rest W/L/T |
|---|---|---|---|---|
| clash-p 0 | 0.3828 | 148/0/52 | 38/33/129 | 43/7/150 |
| clash-p 1.6 | 0.5396 | 191/0/9 | 66/12/122 | 67/1/132 |
| clash-margin 0 | 0.5247 | 187/0/13 | 61/5/134 | 67/1/132 |
| clash-margin 0.5 (final) | 0.566 | 191/0/9 | 81/5/114 | 68/0/132 |
| clash-margin 1.6 | 0.5643 | 197/0/3 | 73/12/115 | 69/2/129 |
| margin 0.5 + clash-p 1.3 | 0.538 | 195/0/5 | 62/8/130 | 66/2/132 |
Gain over parent (+0.008) is within likely noise; clash-margin is flat-ish, clash-p 1 (default) is best. Time-outs in rest stay ~66%.
