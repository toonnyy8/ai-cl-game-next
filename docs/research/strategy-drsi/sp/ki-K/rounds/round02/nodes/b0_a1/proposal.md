# b0_a1 (round 2): parent b0_a0 (0.8746) with :kk-brawl-p 0.4 -> 0.3
Mechanism: parent arm (ken-kh-standoff-style, brawl/dodge reads cut: dodge-p 0, brawl-p now 0.3) so Kenpachi trades instead of waiting.
Evidence (seed0 300, one change each on parent): link-p .5 0.8548, ns-stop-p .5 0.8614, climb-p .3 0.6799, read-range 4.0 0.8251, meaty-p .6 0.7277, ns-safe-p .8 0.8515, hold-awaken .5 + awaken-p 1 0.7657, bankai-p 1 0.703, lunge-p .5 0.8515, reach-p 1 0.8234, reach-margin .45 0.8135, hoho 1.0 0.8597, wave-p .3 0.8762 (mix 156/33/11), brawl .3 + wave .3 0.8729. as-on-p, bk-ns-p, step-max 5 (key already present), kso-stale 30 were byte-identical to the parent (inert or first-occurrence).
Not a repeat: a small local refinement of the parent; honest finding is that the parent sits at a local optimum, every other single move was worse.
Risk: +0.0016 over parent is far under 1 SE (~0.02): effectively a tie, seed-300 overfit.
Measured (seed0 300): score 0.8762; anchor 187W/13L/0TO, mix 161/30/9, rest 180/17/3.
