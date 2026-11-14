# b0_a0: Ichigo band `myburst`, defensive / Hoho arm k

Band: `myburst` (G3 rules 38, 39: my burst running). Arm k = arm 0 (`ichigo-ki-r2b2a1-style`) with `:ns 0.0 :cont 0.3 :hoho 1.2 :range 0.4` (arm 0: 0.35 / 1.3 / 0.5 / 0.7); id `:c-ki-i-r3-b0a0-k`.
Idea: while her burst runs, stop committing NS / strings and Hoho-step out instead.
Tried (seed0 300, eval.py): v1 :ns 0.8 :cont 2.0 = 0.8911; v2 :ns 0.1 :cont 0.5 :hoho 0.9 = 0.8977; v3 meaty-p 1.0 gap-p 0 = 0.8878; v4 :awaken 6 :range 1.2 :b-walk-in 0.2 = 0.8861; v5 (final) 0.8993. Baseline (arm k = arm 0) 0.8927.
Measured (final, seed0 300): score 0.8993; anchor 198/1/1 (wins/losses/timeouts), mix 151/49/0, rest 193/7/0.
band.py pair vs arm 0, block 300: pooled b 41, c 45, z -0.43 (B timeouts 1); anchor b1 c0; mix b36 c39 z -0.35; rest b4 c6 z -0.63.
Verdict: +0.0066 over baseline is within noise; the band fires (counts differ from arm 0) but the paired test shows no gain. Not claimed to beat arm 0.
