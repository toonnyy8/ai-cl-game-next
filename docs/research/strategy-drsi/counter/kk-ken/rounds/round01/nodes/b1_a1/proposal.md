# b1_a1 (kk-ken, round 1): ichigo-ki-style when behind or even on Konpaku

Slice: (:lead :behind) OR (:lead :even). Strategy: `:fn ichigo-ki-style` (Ichigo's KI style CPU, seeds/s6, played by Kenpachi).
History: b0_a0 uses the same slice with `ken-ki-style` (0.97 dev / 0.98 search); b1_a0 close+not-ahead+mr low with ken-ki-style (0.98);
b2_a0 behind/mr low/startup with ken-ki-style (0.94 dev, 0.905 search). All three use ken-ki-style. This cell swaps the strategy to the
other KI style CPU, to test whether the effect is "any KI style CPU" or specific to ken-ki-style.
Dev (seed0 800 x100): 0.935 (own 0.27, gain +0.435, z 8.7). Second block seed0 900 x50: 0.87 (own 0.29).
Scans with ichigo-ki-style (seed0 800): close+not-ahead+mr low 0.83; lead behind alone 0.655; lead even alone 0.91; behind/even/mr low 0.91;
dj in alone 0.925 (own 0.73, capped); with dj in+ahead added 0.98 but own 0.79 (capped).
Finding: a KI style CPU beats the mirror incumbent when not ahead; ichigo-ki-style is a little weaker than ken-ki-style (0.935 vs 0.97 on the same slice).
Not a repeat only in the strategy; the mechanism is the same. Risk: whole-replacement in disguise; ken-ki-style on the same slice is better.
