# b2_a2: KESSA-heavy mix + combo-breaking Burst
Mechanism: baseline press arm + :iks-mix-kessa 0.5, :iks-mix-ptr3 0.3, :iks-mix-space 0.1 (KESSA play and pointer-3 instead of spacing/whiff), :iks-wait-max 40, :iks-gap-p 1.0, :iks-gap-fs 150, and :iks-break-p 0.5 (default 0: break out of his combos by the Burst).
Evidence: sibling b2_a1 (0.7838) refined the ptr3/space mix with ns-wait; this cell moves weight to kessa and turns on an untouched key (break-p).
Variants (seed0 300): kessa 0.5 ptr3 0.3 space 0.1 alone 0.7673; kessa 0.8 0.7508; generic 0 + whiff 0.1 0.7640; break-p 0.3 0.7838, 0.5 0.7921, 0.7 0.7541, 1.0 0.7459; break 0.5 + ns-wait 24 + confirm/punish 1.0 0.7838.
Not a repeat: different mode weights (kessa) and a key b2_a1 never touched.
Risk: break-p response is non-monotone (noise ~0.03), seed-300 overfit; anchor timeouts rise to 11.
Measured (seed0 300): score 0.7921; anchor 169/20/11, mix 136/64/0, rest 172/27/1 (wins/losses/timeouts).
