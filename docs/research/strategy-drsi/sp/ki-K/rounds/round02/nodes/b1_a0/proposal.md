# b1_a0 (round 2): r1-b2a2 with a shorter back-Step range and awakening on
Mechanism: ken-kh-standoff-style, r1-b2a2's knob set, with :kk-step-max 7.0 -> 4.5 (less retreating, fewer stalls) and :kk-awaken-p 0.0 -> 1.0.
Evidence (seed0 300, new population): r1-b2a2 re-evaluated 0.8119 (mix 133/15/52TO: Ichigo's r1 strategy stalls, so time-outs are the loss, not K.O. losses). One knob each on it: step-max 3.5 0.8399, 4.5 0.8416, 2.5 0.8333; step-p 0 0.7805; ns-safe-p 0 0.7228 (107 TO); kso-stale 30 0.7393; reach-margin 0.8 0.566; lunge 0 0.7937; brawl+dodge 0 0.8267 (TO gone, losses up); bankai-p 1 0.627; climb-p 0 0.589; kikon-red 0.5 0.660; reach-p 1 0.838. On step-max 4.5: awaken-p 1.0 0.8663; then +wave 0.9 0.8614, +reach-p 1 0.7822, +bankai 0.3 0.8053, +hoho-in 0.3 0.83; hold-awaken/awaken scale inert.
Not a repeat: r1 searched the old population's levers; here the lever is converting time-outs (new Ichigo waits) into K.O.s by shortening the retreat and awakening.
Risk: seed-300 overfit (SE ~0.02), +0.05 over r1 is ~2 SE; the first v1-v6 batch had duplicate keys and was discarded.
Measured: score 0.8663; anchor 185W/15L/0TO, mix 158/41/1, rest 179/21/0.
