# b2_a0: bothrich specialist, no defensive Step / Hoho dodge

Band: `bothrich` (G2 rule 35, both sides hold 2-3 cells).
Arm k = arm 0 (`c-ki-k-r2-b1a2`) + `:kk-step-p 0.0 :kk-dodge-p 0.0` (same `:fn`, knob variant). While both sides are SP-rich he stops
answering her move starts with the back Step / the Hoho dodge and keeps attacking (her Hoho is a flash-step that costs her cells too).

Evidence (seed0 300, eval.py score; baseline arm 0 = 0.6518): :kikon 1.0 / bankai+climb / hold-awaken 0 + kikon 0: 0.6518 (inert: band never
changed those decisions); hoho-in 1 + hin-fs 100: 0.6452; ns-safe 0 + reach-p 0: 0.6551; step 0 + dodge 0 + brawl 0: 0.6683; dodge 0 + brawl 0:
0.6683; step 0 + brawl 0: 0.6766; **step 0 + dodge 0: 0.6831**; + ns-safe 0: 0.6551; + reach-p 0: 0.6402; + wake-hoho 0 or hoho-in 0/meaty: 0.6831 (same);
+ step-in 1: 0.6815. Selected on block 300 only (overfit risk, SE ~0.02).

Final cand.lisp, eval.py seed0 300: score 0.6831; anchor 188 W / 12 L / 0 TO, mix 65 / 135 / 0, rest 158 / 42 / 0. No time-outs.
band.py pair vs arm 0 (block 300, seeds 301-400): anchor b 2 / c 3 z -0.45; mix b 13 / c 26 z -2.08; rest b 4 / c 9 z -1.39;
pooled b 19 / c 38 z -2.52 (b = arm 0 won only, c = candidate won only; the negative z means the candidate wins more).
