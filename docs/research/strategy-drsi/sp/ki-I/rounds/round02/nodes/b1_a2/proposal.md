# b1_a2: parent b1_a1 (ichigo-ki-r2b1a1-style) plus :iks-gap-wait 6.0 and :iks-mix-whiff 0.5

Mechanism: same fn and data as parent b1_a1 (wake-up roll, oki hold 2.0-2.6 m, :lead :ahead gap rule), with two style keys changed:
`:iks-gap-wait 6.0` (parent: default 6.5; the shut-gauge lunge backs off to 6.0 m) and `:iks-mix-whiff 0.5` (parent 0.3).

Evidence (seed0 300, parent re-measured 0.8647, 195/0/5 | 139/60/1 | 187/12/1): single changes: gap-wait 6.0 0.8746; mix-whiff 0.5 0.8729;
combined 0.8861 (kept); combined + whiff 0.7 0.8531; combined with gap-wait 7.0 0.8383; combined + oki-lo 1.6 0.8746.
No gain: oki-lo 1.0 0.8201, gap-fs 200 0.8333, hoho-p 0.6 0.8597, punish/confirm 1.0 0.8465, kikon-p 1.0 0.8597, ptr3 0.8 0.863, kessa 0.3 0.8581.
Byte-identical to parent (inert here): ir2-roll-near 3.5, ir2-oki-hi 2.8, wake-hoho-p 0.

Not a repeat: no new mechanism; a neighbourhood refinement of the parent. Honest reading: +0.02 is about 1 SE (seed 300 only), a plateau tweak.
Risk: seed-300 overfit; mix group still loses 54 of 200.

Measured (seed0 300): score 0.8861; anchor 195/0/5, mix 146/54/0, rest 193/7/0.
