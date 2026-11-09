# b3_a0 (round 1): the DRIVE switch after a hit, in every form

Job: spend the DRIVE (awakened) / SUBLIMATION (Shikai) gauge on a pointer switch in his own NS gap after a hit (one roll per segment,
*HK-SWITCH-P* by difficulty, target by CAI-SWITCH-TARGET's band rule); everything else is the merged style. The strategy carries no
:DSWITCH, so the merged style never spends the gauge; this style does.

## History
Siblings' proposals were empty when read. Baseline = merged style (0.195 dev full, 0.2163 at scale 0.5).

## Measured (dev seed0 300; scale 0.5 unless noted)
| variant | score | live / past / arms / standin |
|---|---|---|
| baseline | 0.2163 | .039 / .149 / .408 / .269 |
| v1 Burst-or-awaken on every combo + free-step awakening held | 0.1552 | .059 / .134 / .332 / .096 |
| v2 Burst on every combo (HARD 1.0) | 0.1464 | .020 / .134 / .336 / .096 |
| v3 never Burst (generic Burst roll swallowed) | 0.2071 | .039 / .139 / .420 / .231 |
| v4 DRIVE switch after a hit (this file) | 0.2424 | .059 / .149 / .416 / .346 |
| v4 at scale 1 | 0.2149 | .045 / .137 / .423 / .255 |

Findings: the Burst costs flash-step and is worth nothing here (always: -0.07, never: -0.01); holding the awakening loses (stand-in 0.27 ->
0.10: the early Bankai matters). The switch is neutral-to-slightly-positive (about +0.02 over the dev-full baseline 0.195, inside the
+-0.02 noise); the live KH group stays at 0.04-0.06.

## Not a repeat / near-duplicate
It never picks a move; it only converts gauge into a pointer switch inside the merged style's gaps. Members differ from the baseline by
well under 0.05 on average, so it would likely fail the keep rule's near-duplicate and live-group tests.

## Risks
Small effect; the live group (0.045) is far below the 0.2985 bar. Resources are not where Hisagi loses to the KH bait: that is neutral and wake-up play.
