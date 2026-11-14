# b2_a0: whiff-punish mode weighted up

Baseline (r1-b0a2 on ichigo-ki-style, score 0.8993) with the episode mix changed: `:iks-mix-whiff 1.0` (default 0.26), `:iks-mix-ptr3 0.3` (was 0.6), `:iks-mix-space 0.1`, no `:iks-ns-wait` / `:iks-gap-wait` overrides. Rationale: the losses are time-outs vs Hisagi's passive population ("rest": 44 time-outs in baseline); whiff-punish converts his whiffs into K.O.s.

Measured (seed0 300): 0.9092; anchor/mix 194 W / 4 L / 2 TO of 200; rest 160 W / 3 L / 37 TO.
Variants tried (scratch/): kessa-heavy 0.8267, whiff 2.0 0.9026, whiff + wait-max 20 + punish/confirm 1.0 0.9076, adding retreat 0 / hoho 0.5 0.8779, KI round-2 styles (r2b2a1 0.769, r2b1a1 0.4307: do not transfer).
Risk: gain over baseline (+0.010) is within noise of 600 matches.
