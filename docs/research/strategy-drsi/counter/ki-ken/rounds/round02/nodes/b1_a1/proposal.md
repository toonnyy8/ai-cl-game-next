# b1_a1: even-or-ahead-reishi-duel (ichigo-ki-style)
Slice (:own): Konpaku lead :even, OR (lead :ahead AND her Reishi :high AND my Reishi :low). Strategy: :fn ichigo-ki-style (data only).
History read: round 1 (all ken-ki-style scales, noise; spacing :range the only lever that paid, +0.02); round 2 siblings found the lever
(swap to ichigo-ki-style): b0_a0 lead :even (0.49 search), b1_a0 her Reishi high or far-dry (0.425), b2_a0 even|behind&out (0.50).
Mine extends b0's even slice with a part of "ahead" that b0 left out. Ahead alone is weak (0.295), but ahead + her gauge full + mine empty
is a "she can cash specials, I cannot" duel where the incumbent's own style loses most. Dev seed0 800 x100 (inc 0.075):
even 0.55 (own 48%); even + :dswitch 1.0 0.55 (no effect, dropped); even|ahead&or high 0.695 (own 77%, capped);
 ...&mr low 0.60 (own 57.6%, b111/c6) = final; ...&dj out 0.62 (own 59.9%, too near the cap); ...&dj in 0.47 (capped);
 even|down 0.355 (worse than even alone); even|ahead&dj afar 0.545; even|behind&mr low 0.56; even with mr high / dj out 0.45 / 0.26.
Second block seed0 900 x50: 0.57 vs 0.13, gain +0.44, b51/c7, own 50% (holds; the dj-out variant 0.59).
Risk: own share 57.6% on dev sits near the 60% cap (50% on block 2); if search seeds push it over, it scores as the incumbent.
Slice picked among ~12 tries; gain over b0's slice (+0.05) is within noise, the difference is structural (adds ahead&duel).
A whole-game ichigo-ki-style (even|ahead) reads 0.80 but is capped: a lookup-entry candidate.
