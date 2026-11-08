# b1_a0: pure kiter (range 2.6, NS 1.0, no J1), claimed everywhere

Slice (:own): all three :lead sets (own_share 1.0), the composite is the strategy alone. History: baseline 0.035 (search seeds); sibling b0_a0
= s3-zoner everywhere (dev 800: 0.11 vs inc 0.09; coordinator's search-seed score 0.135, z 3.4). No slice beat the whole there, so I did
not slice; I pushed the one lever that worked (spacing + NS) further.
Strategy: s3-zoner pushed to an extreme kite: :range 2.6 (s3 1.5), :ns 1.0, :b-j1 -0.3 (never start a J1), strong walk-out / step-out inside
his J1 reach (:do :in 0.2/0.18, :do :reach 0.1/0.08), NS bias at every :dn set, Hoho x1.4 on his startup in reach, Kikon x1.6 on a red opponent.
Dev (seed0 850, 100 seeds a seat; inc 0.08): s3-like range 2.0 / j1 -0.15 = 0.10; range 2.6 / j1 -0.3 = 0.14 (z 1.85); range 3.2 = 0.155 (z 2.2);
Hoho 2.0 + cont 0.4 = 0.04 (worse: do not over-scale Hoho); s3 + punish rules (active/out -> J1) = 0.06 (worse: attacking hurts).
Final cand.lisp = the 2.6 variant, dev 800 (50 seeds): 0.17 vs 0.09 (gain +0.08, z 1.7).
Not a repeat: b0 is the unmodified library s3; this is a monotone extension of its levers with J1 suppressed and a retreat rule on his
reach, tuned on dev seeds only (600-699 never touched).
Benefit: roughly +0.05..0.08 over the incumbent, scale of the dev noise (~0.05). Risk: 3.2 looked as good, so the optimum is flat; the
incumbent is near a floor (Kenpachi wins ~90%), so absolute shares stay low.
