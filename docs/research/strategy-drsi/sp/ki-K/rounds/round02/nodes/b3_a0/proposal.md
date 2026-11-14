# b3_a0 (round 2): r1 arm + defensive read knobs (dodge 0.5, brawl 0.9, read-range 3.8)
Mechanism: round-1 admitted arm r1-b2a2 (ken-kh-standoff-style) plus :kk-dodge-p 0.5, :kk-brawl-p 0.9, :kk-read-range 3.8 (answer her move starts from farther out, less always-Hoho, more brawl read).
Evidence (seed0 300, new population): r1 arm re-measured 0.8119 (mix 133/15/52TO); baseline 0.4703. Single/combined variants on r1: read-range 3.8 0.8366, dodge .5+brawl .9 0.8531, all three 0.8597, + link-p .7 0.8366, + wake-hoho .5 0.7855, ns-safe .5 0.802 (fewer losses, more timeouts), hoho-in .3 0.8003. Variants appending a duplicate key (step-p, step-max, awaken, step-in) were inert (first key wins).
Not a repeat: round 1 b3 tuned back-Step/read-range on the old population; here the lever is cutting time-outs vs the new Ichigo by dodge/brawl mix.
Risk: seed-300 overfit (SE ~0.02); gain +0.048 over r1 is ~2 SE.
Measured: 0.8597; anchor 185W/13L/2TO, mix 153/21/26, rest 180/12/8.
