# b3_a2 (r2): b3_a1's arm on the new style function ichigo-ki-r2b2a1-style, its lunge-off breaker disabled
Mechanism: parent b3_a1 (0.7607) unchanged except `:fn ichigo-ki-r2b2a1-style` (45-degree wake-up roll away from his knockdown, stale breaker, lunge-off after his far back Step) and `:ikw-gap-off-n 0` (the shut-gauge lunge is never switched off).
Evidence (seed0 300): parent arm on r2b2a1-style 0.8993 (anchor 200/0/0, mix 149/50/1); on r2b1a1-style 0.7673 (anchor 61 time-outs). On the r2b2a1 arm: roll-x 1.0 0.8696, -1.0 0.8515, roll-y 0 0.6799, gap-off-n 1 0.8779, gap-off-n 0 0.9224, stale 300 0.8614, stale 1200 0.8779 (time-outs), gap-wait 5.5 0.9092; roll-y -0.5, gap-fs/wait-max/ns-wait values: identical to 0.9224 (inert or duplicate keys).
Not a repeat: b3_a0/a1 only tuned :iks-* keys and rules on ichigo-ki-style; this changes the style function (new wake-up roll and stale breaker).
Risk: seed-300 overfit (SE ~0.02); the roll is a large part of the gain; mix still loses 31 of 200.
Measured (seed0 300, final cand.lisp): score 0.9224; anchor 200W/0L/0TO, mix 167/31/2, rest 189/11/0.
