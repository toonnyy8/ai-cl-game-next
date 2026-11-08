# b2_a0 ki-lowmr (ichigo vs kenpachi, HARD)

Slice: my Reishi low (`:mr :low`), about 39% of judgements.
Strategy: `:fn ichigo-ki-style` run first (as in b0) with `:base (:range 0.7)` (closer approach).

History: b0 owned every lead with the same fn + range 0.7 (+0.10 on dev). b1 (whiff-punish slice, data only) ~0. Data-only strategies score 0
against HARD Kenpachi, so :fn is required. Under :fn the bias keys (:b-*) and rules are inert (six bias variants gave byte-identical results);
only :range matters. Range sweep on all-lead: 0.5 -0.03, 0.6 +0.02, 0.7 +0.10, 0.8 +0.07.
New here: slicing b0's idea by Reishi. :mr :high is negative (-0.07, own 40%), :mr :low is the gain (+0.12, own 39%): the closer approach pays
when I am low on Reishi, not when high, so the composite keeps the incumbent where closing in hurts. Neighbours: range 0.8 +0.10, 0.6 +0.08;
low x (behind|even) +0.11 (own 29%); low x dj slices weaker. Distance slice alone +0.04, lead slice (behind|even) +0.08.
Risk: picked from ~25 dev variants, some optimism; z ~2 at best. Benefit: similar to b0 with less exposure (b 24 / c 12 vs b0 49 / c 29).
