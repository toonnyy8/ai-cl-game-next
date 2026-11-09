# b3_a1 (round 1): combo breaker by resources + wake-up bait

Job (one line): economy of the defensive state plus a wake-up discipline: break Hisagi's combos with the awakening / Burst once per combo,
and never press a meaty into his wake-up Hoho; everything else is ken-ki-style.

## Mechanism
`ken-kh-style` = `kh-break` (parent b3_a0: stun/air, >=2 combo hits, at the reaction delay, once per combo; awakening if gauge full else Burst
at >=200 FS; HARD 1.0, NORMAL 0.3, EASY 0) -> `khf-bait-step` (sibling b0_a0, credited: per knockdown one brain-roll, hold at 2.3 m, `*kk-meaty-p*`
zero around the delegate) -> `ken-ki-style` unchanged. State: struct `khs` (includes `kks`) in brain-style. Reads Hisagi only via SNAP/D.

## Evidence from history (measured, score.rescored.json, seed0 200)
- b0_a0 bait alone: 0.8828 (live 0.891). b3_a0 breaker alone: 0.45 (live 0.168, arms 0.667), versus baseline 0.457.
- The breaker lifted the press arms but cost the HK iterates; the bait removes the actual leak (6 of 6 meaty J1s eaten by Hisagi's wake-up
  Hoho), so the two act in different states (stun vs his knockdown). b1_a0 (sealed patience) and b2_a0 (whiff punish) stayed ~0.45-0.48.

## Not a repeat
A combination of two measured pieces (parent + b0_a0); the resource job (breaker) is the part I own, the bait is borrowed. Because the bait
carries the score, this cell is a near-duplicate of b0_a0 on member shares; the coordinator should judge whether the breaker's marginal
contribution is worth keeping.

## Measurement (dev seed0 300)
| run | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| combo, final | 0.5 | 0.9216 | 0.8922 | 0.9216 | 0.9511 |
| combo, final | 1.0 | 0.9163 | 0.9208 | 0.8861 | 0.942 |
b0_a0 on the same block at scale 1: 0.8867 (live 0.876). inc_live 0.255 (tripwire ok). Host tests ALL PASS.

## Risks
Burst leaves one Hoho (ranged punish, hk-t2 0.82); bait trusts Hisagi's wake-up Hoho trigger inferred from logs; the +0.03 over b0_a0 is
only ~1.5 draw-noise units. No variant sweep was run (one combination, two evals).
