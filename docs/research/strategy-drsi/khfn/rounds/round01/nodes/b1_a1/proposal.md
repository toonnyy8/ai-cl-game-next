# b1_a1 (round 1): wake-up bait + combo breaker, his own code throughout

Job (one line): do not feed Hisagi's wake-up Hoho (hold at 2.3 m while he is down, no meaty) and pay for the escape when he combos Kenpachi (awakening if full, else Burst); everything else is ken-ki-style.

## Mechanism
- `khc-bait-step` (from b0_a0): one roll per knockdown (`*khc-bait-p*`), hold at `*khc-bait-d*`, the meaty bound to 0 meanwhile.
- `khc-break` (from b3_a0): once per combo (>=2 hits) at the reaction delay, awakening or Burst (FS>=200).
- Form split (the direction hint: Ichigo's KI code sealed, his own released, + stalemate clock) is implemented (`*khc-sealed-forms*`, `*khc-stale*`) but OFF (NIL).
  Measured with the bait on: 0.6882 at scale 0.5 (live 0.45, arms 0.87) vs b0_a0's 0.88; the patient code gives up the bait's wins.
  b1_a0 alone (split+stale) rescored 0.453, so the split is not what carries the score.

## Evidence
b0_a0 rescored 0.8828 (bait), b3_a0 0.45 (burst), b1_a0 0.453 (split), b2_a0 0.483 (punish). The bait carries; the breaker is an orthogonal addition.

## Measurement (dev seed0 300, scale 1, 950 matches)
0.9163: live 0.9208, iterates 0.8861, arms 0.942. b0_a0 on the same block: 0.8867 (live 0.876, iterates 0.856, arms 0.9275). inc_live 0.255 (not moved). Host tests ALL PASS.
Weakest members: h11-ids / h7-iki 0.78 (were 0.82), hk-t2 0.82.

## Not a repeat / near-duplicate
Combination of b0_a0 and b3_a0 (two orthogonal jobs). Honest caveat: the +0.03 over b0_a0 is near draw noise (+-0.02) and the bait is the same as b0_a0's; the splitting hint did not pay.

## Risks
The 2.4 m Hoho trigger is inferred from Hisagi's CPU; against a CPU not Hohoing on wake-up the bait gives up meaty pressure. Burst leaves one Hoho.
