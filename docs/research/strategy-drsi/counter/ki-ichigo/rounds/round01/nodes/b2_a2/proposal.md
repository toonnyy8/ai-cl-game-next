# b2_a2 ki-reach-or-low (ichigo vs kenpachi, HARD)

Slice: I am within his J1 reach (`:do :in`/`:reach`) OR my Reishi is low (`:mr :low`); own_share 0.88.
Strategy: `:fn ichigo-ki-style` first, `:base (:range 0.7)` (closer approach). Data only.

History read: every cell gains only via range 0.7 under the style CPU (bias keys inert; data-only strategies score 0). Best so far b0_a1
(`:dn in|reach` OR `:mr low`, search 0.38), b2_a1 (`:do in|reach`, 0.36), b2_a0 (`:mr low`, 0.32). b0_a2 (extra kikon/turn scales) 0.28 = noise/harm.
New here: the union of b2_a1's and b2_a0's slices (`:do` rather than b0_a1's `:dn`), i.e. the complement is only "far from his reach with Reishi not low".
Dev (seed0 800, 50 seeds): dn-union (b0_a1) 0.39 (+0.14); do-union (this) 0.41 (+0.16, b25 c9 z2.7); dn-union + behind 0.34; dn&low 0.35;
dn-union range 0.8 0.32; do-union range 0.6 0.33; do+dn+low 0.42 (superset, same own 0.88).
Not a repeat: different distance cue and union than b0_a1; but it largely overlaps b2_a1 (own 0.88 vs 0.81), so expect ~ b0_a1/b2_a1 (0.36-0.38).
Risk: picked from ~8 dev variants; range response non-monotone; gain vs b0_a1 within noise.
