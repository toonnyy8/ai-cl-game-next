# b2_a0: ichigo-ki-style when not ahead, or ahead but far (ii-ichigo, round 1)

Slice (:own): lead behind OR even OR opponent red OR (lead ahead AND dj afar). Own share 0.486 (cap 0.6).
Strategy: `:fn ichigo-ki-style`, no base/rules.
History: b0_a0 (ken-ki-style, not-ahead slice) dev 0.91; b1_a0 (ichigo-ki-style, same slice, own 0.28) dev 0.96.
This cell extends b1's slice with the one ahead state where the generic CPU is passive (opponent afar), keeping the same strategy.
Variants (dev 800): dj out/afar only 0.945 (own 0.59); free+not-ahead 0.855; b1 slice + ahead&dj out/afar 0.995 but own 0.72 (capped);
this slice 0.99 (own 0.49).
Dev seed0 800 x100: 0.99, gain +0.49, z 9.9, b/c 98/0. Second block seed0 900 x50: 0.99, gain +0.49, z 6.9, own 0.485.
Not a repeat of b1 in slice (adds the ahead-afar branch); the strategy is the same, so it is an extension, not a new mechanism.
Risk: ceiling effect (0.99, near 1.0); the gain is the style CPU out-playing the generic mirror CPU, so a lookup-level replacement may do as well.
