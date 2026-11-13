# b1_a1: b3_a0's style knobs plus the shut-gauge lunge waiting at 5.5 m
Mechanism: baseline a-ichigo-press (ichigo-ki-style) + :iks-mix-ptr3 0.6, :iks-mix-space 0.1, :iks-wait-max 40, :iks-gap-p 1.0, :iks-gap-fs 150 (b3_a0's set) + :iks-gap-wait 5.5 (default 6.5): the pointer-3 lunge backs off to 5.5 m, not 6.5, while his Hoho is shut.
Evidence (seed0 300, on the b3_a0 set 0.7772): awaken-p 0 0.4274 (awakening is essential), hold-awaken 0.5 0.670, break-p 1 0.734, ns-wait 20 0.7789, hoho-follow 90 0.7739, retreat-p 0 0.7673, getsuga-min 6 0.7756, confirm/punish 1.0 0.7607, gap-wait 5.5 0.8119; +ns-wait 20 0.7937, +hoho-follow 90 0.8069, gap-fs 200 0.8119.
Not a repeat: b3_a0 left gap-wait at default (it tried 5.5 only in a screen without its final combination being reported); other cells did not touch it.
Risk: seed-300 overfit, gain over b3_a0 (+0.035) is about 1.5 SE.
Measured (seed0 300): score 0.8119; anchor 167/31/2, mix 155/45/0, rest 167/33/0 (wins/losses/timeouts).
