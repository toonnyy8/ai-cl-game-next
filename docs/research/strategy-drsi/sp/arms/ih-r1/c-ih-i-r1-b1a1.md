# b1_a1: b1_a0's knobs on the KI round-2 roll style
Mechanism: `:fn` ichigo-ki-r2b2a1-style (the KI round-2 wake-up roll / gap-off detector / stale breaker, untried in IH) instead of ichigo-ki-style, with b1_a0's knobs (gap-fs 300, retreat-p 0, steer-p 1, mix-whiff 0.4), roll (0.7,0.7), mix-space 0.1.
Evidence (seed0 300): b1_a0 0.9274 (parent, same knobs on the old style); KI's own r2 knob set (whiff 1.5, gap-fs 150, meaty-p 0) transfers badly: 0.769; with the b1_a0 knobs 0.9653; whiff 1.0 0.962; meaty-p 0 0.8317 (bad here); space 0.1 0.9769.
Not a repeat: a different style function, not another knob nudge of ichigo-ki-style.
Risk: single seed block, SE ~0.02; roll angle is a cliff in KI (keep 0.7,0.7).
Measured: score 0.9769; anchor 198/2/0, mix 198/2/0, rest 193/2/5.
