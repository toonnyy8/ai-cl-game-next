# b2_a0 (round 1): whiff punish

**Job (one line):** when the perceived Hisagi is in the recovery of a move that missed or was blocked, answer it with the move that reaches
inside the frames left (the pointer's NS, else J1); everything else is ken-ki-style.

## Mechanism
`kh-punish` runs before `ken-ki-style` on free steps (idle / run). Conditions: Hisagi perceived in `:move`, phase `:main`, past his active
end (`snap-sf >= snap-active-end`), contact not `:hit`, d <= 3.0 m. One roll per Hisagi move (`snap-start`) at `*kh-punish-p*`
(EASY 0.3 / NORMAL 0.7 / HARD 1.0). Frames left = `snap-left - brain-delay`; the move must have startup + walk + `*kh-slack*` (3) <= left.
NS (non-Bankai, roll `*kh-ns-p*` 0 / .3 / .6) else J1. Own state in a hash table keyed by the brain (reset when `*match-tick*` goes back);
ken-ki-style keeps brain-style. An optional walk-in (`*kh-walk-max*`) exists but is off (0.0).

## History
Round 1: no sibling proposals existed when I started (none to read). Baseline: KI code arms 0.66, live 0.13 (search block).

## Measurement (dev block seed0 300; "baseline" = this file with the punish chance 0)
| variant | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| baseline (p=0) | 0.5 | 0.4209 | 0.039 | 0.588 | 0.635 |
| v1 walk-in 7.5 m, blocks too | 0.5 | 0.441 | 0.020 | 0.608 | 0.696 |
| v2 no walk, blocks too (FINAL) | 0.5 | 0.4452 | 0.029 | 0.588 | 0.718 |
| v3 slack 10, whiffs only | 0.5 | 0.423 | 0.020 | 0.539 | 0.711 |
| v2 final | 1.0 | 0.4384 | 0.074 | 0.574 | 0.667 |

Reference dev 300 at scale 1 (baseline proposal): his KI 0.415 (live 0.074), Ichigo's KI 0.383 (live 0.223).
Final members: hk-r1 .07, hk-t1 .63, hk-t2 .52, h1 .68, h10 .60, h2 .60, h3 .42, h4 .62, h5 .58, h6 .44, h9 .40, h7/h8/h11 1.0.
The gain is mostly in the arms group; walk-in did not add; waiting for longer recoveries (slack 10) lost it.

## Honest read
+0.02 at full scale is inside the +-0.02 draw noise. The live group did not move (0.074; the keep rule needs >= 0.1716), so this cell
will probably NOT be kept: it is a thin additive layer on ken-ki-style, and its member shares differ little from his KI code.
Risk: perception delay against short recoveries; in the live table the punish may trade into follow-ups.
Not tried: dodging the bind entry (NAGE / MAKI / KAKE), a Hoho through TABA / TATAKI starts, anything for the live table's press arm.
