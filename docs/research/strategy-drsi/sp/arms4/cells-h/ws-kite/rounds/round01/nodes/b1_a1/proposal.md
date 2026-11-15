# b1_a1 kite: walk-in keys off + wider close rule + wider kite

Final arm = scratch/v2 (= arm.lisp): added to :base `:kk-lunge-p 0.0 :kk-step-in-p 0.0 :kk-reach-margin 0.9 :kk-step-max 6.5 :hr-near 4.2 :hr-close 3.4 :hkk-near 4.0 :hkk-near-bankai 5.0 :hkk-window 80`.

Table score (block 300, vs ichigo): 0.637 (baseline 0.6287): anchor 185/10/5, mix 127/67/6, rest 71/126/3 (baseline 182/10/8, 127/70/3, 69/129/2). Within noise-edge (+0.008).

Descriptor screens (mean distance gain vs arm 0; bar +0.5 vs both; seeds 301-320):
| variant | keys | vs Kenpachi | vs Ichigo |
|---|---|---|---|
| v1 | walk-in keys only (lunge 0, step-in 0, reach-margin 0.9, step-max 6.5) | +0.335 | +1.03 |
| v2 (final) | v1 + hr-near 4.2 / hr-close 3.4 + hkk-near 4.0 / -bankai 5.0 / window 80 | +0.435 | +1.04 |
| v3 | wider still (hr 5.0/4.0, hkk-near 4.8, far 1.5, window 100, margin 1.0, step-max 7) | +0.39 | +0.98 |
| v4 | v2 + meaty-p 0, wake-hoho-p 0, reach-p 0.3 | +0.35 | +0.98 (K.O. 0.6) |
| v5 | v2 + step-p 1.0, hr-wa-pred 2.0, brawl-p 0.2 | +0.41 | +1.04 |

Reading: the kk walk-in keys moved Kenpachi's distance most (+0.26 -> +0.335); the wider kite adds ~+0.1. Nothing reached +0.5 vs Kenpachi: the arm still FAILS the one-job proof against Kenpachi (best +0.435). Screen noise is about 0.05-0.1 m.
