# b2_a2 (round 1): bait + combo breaker + stand-off breaker

Job (one line): three state-specific disciplines around his KI code: no meaty into Hisagi's wake-up Hoho (hold 2.3 m), pay the escape once per combo (awakening else Burst), lift the Hoho-safety hold when the stand-off is old and the bell is not his.

## Mechanism
`ken-kh-style` = `khc-break` (stun/air, >=2 combo hits, once per combo, HARD 1.0 / NORMAL 0.3 / EASY 0) -> `khc-bait-step` (one brain-roll per knockdown, hold at 2.3 m, `*kk-meaty-p*` 0 meanwhile)
-> stand-off breaker (`khc-old-p`: 120 frames HARD with no change of the four gauges and not winning Konpaku/Reishi tiebreak: `*kk-ns-safe-p*` 0 and approach re-rolled once) -> `ken-ki-style`.
State in a hash keyed by the brain (reset when *match-tick* goes back); brain-style stays ken-ki-style's. Hisagi read only via SNAP state and D (the gauges are HUD numbers, as in b2_a1).

## Evidence from history (seed0 200 rescored)
bait b0_a0 0.883; bait+breaker b1_a1/b3_a1 0.93; stand-off breaker b2_a1 0.669 (live 0.39, fixes time-outs); whiff punish b2_a0 0.483; sealed-form split b1_a0 0.453 (no help).
The bait and breaker act on knockdown/stun; the stand-off breaker on idle time-outs, so they compose. My assigned direction (bind/ranged mode) was not pursued: b2_a1 already showed Hoho-through-ranged-moves = baseline.

## Not a repeat
New combination (all three), the Ichigo split of b1_a1 dropped. Honest caveat: near-duplicate of b1_a1 on member shares (differences ~0.02-0.1); the added value is the stand-off piece.

## Measurement (dev seed0 300, scale 1, 950 matches)
score 0.9564: live 0.9554, iterates 0.9356, arms 0.9783 (b1_a1 on the same block 0.9163: 0.9208 / 0.8861 / 0.942). Weakest: hk-t2 0.89, hk-r1 0.96. inc_live 0.255 (not moved). Host tests ALL PASS.

## Risks
Bait relies on Hisagi's CPU Hohoing on wake-up within 2.4 m; breaker trusts Burst leaving one Hoho; stand-off breaker reads gauges.
