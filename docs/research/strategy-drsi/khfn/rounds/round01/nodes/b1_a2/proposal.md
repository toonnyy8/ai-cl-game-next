# b1_a2 (round 1): wake-up bait + combo breaker + stand-off breaker (his own code throughout)

Job (one line): three orthogonal disciplines around his own KI code: do not feed Hisagi's wake-up Hoho (bait), pay for the escape when
combo'd (awakening / Burst), and when nothing has moved for 120 f and the bell is not his, lift the KI code's Hoho-safety hold (stand-off breaker).

## Mechanism
Parent b1_a1 (bait from b0_a0 + breaker from b3_a0; the form split to Ichigo's code stays OFF, `*khc-sealed-forms*` NIL) plus the
stand-off breaker of b2_a1 (`khc-standoff-p`, `khc-ken`): a clock over both Reishi and both Konpaku; past `*khc-so-stale*` (HARD 120 f) and
not winning the time-up tiebreak (Konpaku, then Reishi %), the delegate runs with `*kk-ns-safe-p*` 0 and its approach re-rolled once at onset.
No dice, own state in the KHC struct (hash keyed by brain, cleared when *match-tick* goes back). Hisagi is read only via SNAP / D.

## Evidence from history (rescored, seed0 200)
bait b0_a0 0.883; bait+breaker b1_a1 0.9305 (weak: h7-iki / h11-ids 0.82, hk-t2 0.87); stand-off alone b2_a1 0.669 (it fixed time-outs,
but the press arms lost to wake-up Hohos, which the bait removes); form split b1_a0 0.453 (0.688 with the bait). The parent's remaining
losses at h7 / h11 (Hisagi on Ichigo's patient code) are presumably time-outs, which the stand-off breaker targets (not verified per match).

## Not a repeat
Combination of three measured, orthogonal pieces in different states (his knockdown / his combo / a dead neutral); the new fact is that the
composition lifts the parent's weakest members. Not a retune or picker of the KI codes. Caveat: the bait carries most of the score.

## Measurement (dev seed0 300)
| variant | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| parent b1_a1 | 0.5 | 0.9216 | 0.8922 | 0.9216 | 0.9511 |
| + stand-off breaker | 0.5 | 0.9611 | 0.9314 | 0.9706 | 0.9812 |
| + stand-off breaker (FINAL) | 1.0 | 0.9564 | 0.9554 | 0.9356 | 0.9783 |
Parent at scale 1 (its own proposal): 0.9163. Members now 0.89-1.0 (h7 / h11 0.82 -> 0.96). inc_live 0.255 (not moved). Host tests ALL PASS.

## Risks
Reads both sides' Konpaku / Reishi (HUD numbers). Attacking an idle Hisagi at a stand-off can trade into his Hoho; threshold 120 f tuned
by b2_a1, not re-swept here. Bait trusts Hisagi's wake-up Hoho trigger (2.4 m) inferred from logs. Gain over the parent (+0.04) is ~2 noise units.
