# b1_a0: :xch-sa-p 1.6, :xch-carry-p 1.0 (baseline arm + two exchange keys)
Baseline 0.3218 (anchor 86:106:8, mix 19:181:0, rest 87:112:1). Eight runs, seed0 300 (anchor w:l:t / mix w / rest w):
- A sa-p 1.6 carry 0: 0.3234 (75:112:13 / 24 / 94)
- B sa-p 0 carry 5: 0.1815 (38:150:12 / 5 / 64)
- C sa-p 1.0 carry 0 wait 2: 0.3069 (70:120:10 / 26 / 87)
- D sa-p 0.4 carry 2.5: 0.2492 (65:128:7 / 12 / 71)
- E sa-p 1.6 carry 0 wait 3: 0.3366 (83:106:11 / 25 / 93)
- **F sa-p 1.6 carry 1.0: 0.3564 (88:99:13 / 28 / 97), final cand.lisp**
- G sa-p 1.6 carry 0 wait 1.5: 0.3234 (81:105:14 / 21 / 91)
Reading: SA at the cancel is the strong side (sa-p 0 and 0.4 lose 10-17 pts); carry hurts when SA is low, small carry (1.0, i.e. 0.2) with max SA best. Wait k<1.5 no gain, 3 slightly mixed. Single block 300 only; noise ~0.02.
