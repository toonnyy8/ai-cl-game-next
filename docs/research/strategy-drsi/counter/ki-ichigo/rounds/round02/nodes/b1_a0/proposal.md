# b1_a0 own-style-behind (ichigo vs kenpachi, HARD)

Slice: `:lead :behind` (my Konpaku behind), own_share ~0.11-0.14.
Strategy: `:fn ichigo-ki-style` (her own matchup style CPU), no :base. The incumbent is now Kenpachi's style (`ken-ki-style`), so this reverses
round 1: there ichigo-ki-style was the incumbent and slices of it only gained via :range 0.7 (b0/b2). Now the question was where her OWN style
beats the borrowed Kenpachi style.

History: round 1 b1_a2 (ken-style-all) won as a whole replacement; b0/b2 (ichigo-ki-style + range 0.7 on slices) were gains vs the OLD incumbent
and are the same lever, so not repeated. sitcheck shows kiichigo winning every behind bin of ichigo-vs-ken (+0.17..+0.35 over s0).
Dev probes (seed0 800, 100 seeds, vs inc 0.43): mr low+range 0.7 -0.10 (own .06); lead ahead -0.18 (own .10); mr high -0.07 (own .12);
lead behind +range 0.7 +0.22 (own .10); lead behind plain +0.18 (final). Range does not matter here (+0.22 vs +0.18, noise), so it is dropped.
Second block (seed0 900, 50 seeds, inc 0.47): behind+range 0.7 0.65 (+0.18, b32 c14, z 2.7); behind plain 0.66 (+0.19, b30 c11, z 3.0). Replicates.
Why it works (hypothesis): when behind, Kenpachi's brawl style keeps trading badly; her own style (spacing / reactive) recovers. When ahead the
borrowed brawl style is better (ichigo style -0.18 there), so the slice is one-sided, which is what a counter should be.
Risk: gain is large for 11% exposure, so partly butterfly (a switch changes the whole later match); still two blocks agree. Expect search share ~0.50-0.55.
