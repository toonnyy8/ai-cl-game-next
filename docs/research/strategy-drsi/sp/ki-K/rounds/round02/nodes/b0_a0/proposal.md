# b0_a0 (round 2): r1-b2a2 with the sealed defensive reads cut (:kk-dodge-p 0, :kk-brawl-p 0.4)
Mechanism: start from admitted c-ki-k-r1-b2a2 (re-measured vs the new population: 0.8119; mix group 52 time-outs, the new Ichigo r1-b3a2 stalls). Time-outs were the loss, so the defensive reads were turned down: :kk-dodge-p 0 (no Hoho through her moves) and :kk-brawl-p 0.4 (down from 0.6), which makes Kenpachi trade instead of waiting.
Evidence (seed0 300): v0 0.8119 (mix 133/15/52 W/L/TO); ns-safe-p 0 0.7228 (worse: 107 TO); brawl .2+dodge .5 0.8333; brawl 0+dodge 0 0.8267 (TO gone, losses 55); brawl 0 dodge .5 0.8383; brawl .2 dodge 0 0.8713; brawl .1 dodge .25 0.8564; brawl .4 dodge 0 0.8746; +step-p .5 no change; +kikon-red-p .7 0.7343 (bad); reach-margin and reach-p inert here.
Not a repeat: round 1 tuned approach/step/Bankai levers; this is the first use of the brawl/dodge pair, aimed at the new stalling opponent.
Risk: seed-300 overfit (SE ~0.02); losses vs the mix rose 15 -> 32.
Measured (seed0 300): score 0.8746; anchor 188W/12L/0TO, mix 156/32/12, rest 183/16/1.
