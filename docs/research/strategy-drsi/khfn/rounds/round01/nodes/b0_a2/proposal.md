# b0_a2 (round 1): wake-up bait + stand-off breaker (closing-in direction found nothing structural)

Job (one line): do not feed Hisagi's wake-up Hoho (hold at 2.3 m while he is down, no meaty), and when a stand-off is old and the bell is not
Kenpachi's, drop the Hoho-safety hold so he attacks the idle opponent; everything else is ken-ki-style.

## Mechanism
Parent b0_a1 (= b0_a0's bait; its hoho-in / step-band knobs stay off/neutral) plus b2_a1's measured breaker: a gauge clock (frames since either
side's Reishi or Konpaku changed; HARD 120 / NORMAL 540 / EASY 900) and, if the stand-off is old and Kenpachi does not win the time-up tiebreak
(Konpaku, then Reishi %), `*kk-ns-safe-p*` is bound to 0 around the delegate. State in the `khs` struct (brain-style). Reads Hisagi only via SNAP / D / gauges.

## Evidence from history
b0_a0 / b0_a1 (bait) 0.88; b1_a1 0.93 (bait + combo breaker); b2_a1 breaker alone 0.67; b1_a0, b2_a0, b3_a0 ~0.45-0.48 (baseline 0.457).
b0_a1 already showed closing in fails (Hoho in 0.80 vs 0.89; wider Step band = identical). I did not repeat them. I composed the bait with the
stand-off breaker (a different event from the bait's), hoping to lift the remaining time-out losses.

## Measurement (dev seed0 300)
| run | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| parent b0_a1 | 0.5 | 0.8882 | 0.8725 | 0.8824 | 0.9098 |
| + breaker | 0.5 | 0.8784 | 0.8922 | 0.8333 | 0.9098 |
| + breaker (FINAL) | 1.0 | 0.8843 | 0.8812 | 0.8515 | 0.9203 |

b0_a0 / b0_a1 at scale 1 on this block: 0.8867. The breaker is neutral (inside the +-0.02 draw noise); hk-t2 dipped to 0.81, h7 / h11 rose
(0.88-0.90 vs 0.82). inc_live 0.255 (not moved). Host tests ALL PASS.

## Not a repeat / near-duplicate
Bait is credited to b0_a0; the breaker to b2_a1. This cell adds no measured gain: treat it as a near-duplicate of b0_a0; b1_a1 (0.93) is the better composite.

## Risks
Bait trusts Hisagi's wake-up Hoho trigger (2.4 m) inferred from logs; the breaker turns the Hoho-safety hold off, which can feed his Hoho in a stand-off.
