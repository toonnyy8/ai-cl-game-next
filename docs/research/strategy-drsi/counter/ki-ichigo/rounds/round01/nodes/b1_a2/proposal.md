# b1_a2 ken-style-all (ichigo vs kenpachi, HARD)

Slice: everything (all three :lead sets), own_share 1.0.
Strategy: `:fn ken-ki-style`, i.e. Ichigo plays KENPACHI's KI style CPU (seeds/s5), run before the action layer. No :base.

History read: b0/b1/b2 cells all use `:fn ichigo-ki-style` + `:base (:range 0.7)` on varying slices (search 0.28-0.38, gains +0.01..+0.135,
heavily shrunk from dev; b0_a2 dev +0.15 -> search +0.035). They are one lever (closer approach) with sliced exposure; returns flat and noisy.
New here: a different :fn. Kenpachi's brawl style (close pressure, J1 race) played by Ichigo's body.
Dev (seeds 800-849, ~100 matches): 0.47 vs 0.25, gain +0.22, z 3.1 (b/c see dev.json). Base keys (range 0.7/1.2, awaken, p, ns) are inert/within noise.
Finding: partial slices CRASH the sim (ikst struct handed to ken-ki-style's KKS accessor on a switch), so this strategy is only valid owned everywhere
(a hole in :own would be a runtime error). Hence the full :own.
Not a repeat: different strategy (:fn), not a slice of the ichigo-ki-style/range lever.
Risk: the full replacement is one idea measured on 50 dev seeds (~no selection among variants; the only variant tried was this one). Cross-style struct
mismatch makes it fragile if the incumbent's style state is ever read by the sim. Expected search share ~0.35-0.45.
