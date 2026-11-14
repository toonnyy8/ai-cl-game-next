# b0_a0: :xch-j 0.0 (J side of a cancel always answers AS, never the next J)
Baseline c-ki-k-r2-b1a2 plus `:xch-j 0.0` in :base. Seed0 300, 4 evals (k = 0, 0.5, 1 baseline, 2):
- k=2.0: 0.1848 (anchor 43:147:10, mix 3:197:0, rest 63:137:0)
- k=0.5: 0.4043 (anchor 105:87:8, mix 37:163:0, rest 100:98:2)
- baseline k=1: 0.3218 (anchor 86:106:8, mix 19:181:0, rest 87:112:1)
- k=0.0 (FINAL): 0.5132 (anchor 132:63:5, mix 55:145:0, rest 121:77:2)
Monotone: less J is better; the extreme is the best (AS reach test still applies as before).
