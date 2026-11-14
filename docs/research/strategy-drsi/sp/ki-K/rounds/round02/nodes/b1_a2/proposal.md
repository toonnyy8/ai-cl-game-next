# b1_a2 (round 2): parent b1_a1 (0.8878) + :other 10.0 + :kikon 0.3
Mechanism: ken-kh-standoff-style with b1_a1's knobs, plus two untried generic-fuzzy scales that the parent branch never touched: `:other` (scale on *fz-burst* / *fz-cancel*, the Burst and Kikon-cancel chance; scale clamps at 1 so >=5 = always) and `:kikon` (scale on *fz-kikon*, how often an SP is held into a Kikon; 0.3 = mostly tap).
Evidence (seed0 300, parent re-run 0.8878): :kikon 1.5 0.8845, 0.5 0.8993; :hold-awaken 0.3 0.7228; :kk-ns-stop-p 0.5 0.8927; :other 1.5 0.9076, 2.5 0.9175, 5 and 10 0.9323 (saturated); other 10 + kikon 0.7 0.9307, 0.5 0.934, 0.3 0.9422, 0.2 0.9356, 0.1 0.9356, 0.0 0.9389 (plateau); :hoho 1.0 / :cont 1.0 with other 4 + kikon .5 no help.
Not a repeat: parent and round 1 only moved :kk-* style chances; :other / :kikon are different mechanisms (defensive Burst/cancel, SP economy).
Risk: seed-300 overfit (SE ~0.02); kikon 0.1-0.5 all within noise, 0.3 chosen as the sampled maximum.
Measured: score 0.9422; anchor 187W/13L/0TO, mix 189/11/0, rest 192/8/0.
