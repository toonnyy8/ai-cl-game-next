# b3_a0: Ichigo style knobs (pointer-3 mix, short hover, shut-gauge lunge)
Mechanism: baseline a-ichigo-press kept; adds :iks-mix-ptr3 0.6, :iks-mix-space 0.1 (others default), :iks-wait-max 40, :iks-gap-p 1.0, :iks-gap-fs 150. Ichigo plays pointer-3 more, hovers less before the generic CPU takes over, and lunges whenever Kenpachi's Hoho gauge is under 150.
Evidence: no sibling scores existed. My own screens (seed0 300): ptr3 0.6 alone 0.670, wait-max 60+punish 1.0 0.663, both 0.683, plus gap-p/gap-fs 130 and wait-max 40 0.777 (gap-fs 150 same 0.777); more ptr3 weight, gap-wait 5.5, wait-max 20, kessa/whiff-heavy mixes were equal or worse.
Not a repeat: baseline used no :iks-* keys.
Risk: seed-300 overfit (variants screened on the same seeds).
Measured: score 0.7772; anchor 165/33/2, mix 142/58/0, rest 161/39/0 (baseline 0.6122).
