# k-guard r1 b1_a0 (answer from distance)
Baseline 0.6452 (KI .3234, KH .967). Runs (seeds 301-400):
1. kk-wave-p 0.0->0.9: 0.6444 (KI .3218: 108-78-14 / 63-130-7 / 21-179-0; KH .967). No effect.
2. + kk-reach-margin .35->.1, kk-ns-safe-p 1->.3: 0.637 (KI .3086, rest 14-186; KH .9653). Worse.
3. wave .9, margin .7, ns-safe 1: 0.6444, identical to run 1 (margin inert in this range).
4. FINAL: wave .9, margin .7, ns-safe 1, kk-step-p 1.0->0.3: 0.6493 (KI .33: 112-75-13 / 64-129-7 / 21-179-0; KH .9686: 199-1-0 / 195-0-5 / 190-0-10). Gain within noise.
No descriptor check run (budget spent on scoring); the mean_d proof is unverified; fewer back Steps may cut the +0.33 m.
Rest group (vs her T0) stays 21-179: not moved by any key tried.
