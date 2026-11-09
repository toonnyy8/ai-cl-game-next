# b2_a1 (round 1): stand-off breaker

Job (one line): when nothing has been hit for a while and Kenpachi is not winning the bell's tiebreak, take the initiative (drop the
Hoho-safety discipline that makes the KI code stare at an idle opponent); winning the tiebreak he keeps his patience.

## Mechanism
`ken-kh-style` = `ken-ki-style` plus a clock (`kh-old-p`): frames since any of the four gauges (both Reishi, both Konpaku) last changed.
Past `*kh-stale*` (HARD 120 / NORMAL 540 / EASY 900 frames) AND not winning the time-up tiebreak (rules `time-up-winner`: Konpaku, then
Reishi %), the delegate runs with `*kk-ns-safe-p*` bound to 0 and its approach re-rolled once at the onset (`(kks-appr st)` cleared).
No dice (deterministic from the clock); own state in a hash keyed by the brain, reset when `*match-tick*` goes back.

## Evidence (why, from the logs; my assigned direction -- the Bankai bind -- was tried first and abandoned)
- First tried a Hoho through KUBIKAKE / the ranged-mode pokes then J1 into the recovery (v1/v2). Score = baseline +0.001: KUBIKAKE is thrown
  as a cancel off a landed hit (undodgeable) or on waking, and Kenpachi's Hoho is mostly closed. Dropped.
- Time-out anatomy of the pool (cache hash lines): ~30 % of matches run to 300 s; the lead at 80 s decides them (151/154 held). In the live
  table's matches Kenpachi often has Reishi 1300 against 260-900 yet loses the bell, because releasing costs Konpaku (6 vs 9); others sat at
  1.4 m for 290 s with Reishi unchanged (seed 303). Cause: `kk-pick`/`kk-decide` hold J1 (S9 > `*kk-hoho-blind*` 8) and the NS whenever the
  opponent is idle (`kk-ns-open-p`, `*kk-ns-safe-p*` 1.0 at HARD), a rule written against Ichigo's wake-up Hoho; Hisagi's CPU waits as well.
- With the breaker the live matches fight (K.O.s at 140-166 s, Bankai entries appear).

## Not a repeat / near-duplicate
Not a retune of either KI code and not a form picker: a new state (the stand-off clock + the bell's tiebreak) that switches one discipline.
b1_a0 also used a stalemate clock but to hand Ichigo's patient code over to this engaging one; here the baseline is already the engaging
code, and the cure is lifting its safety hold. The mechanism is independent of b0_a0's wake-up bait (different event) and composes with it.

## Measurement (dev block seed0 300)
| variant | scale | score | live | iterates | arms |
|---|---|---|---|---|---|
| baseline (parent, punish only) | 0.5 | 0.4452 | 0.029 | 0.588 | 0.718 |
| Hoho through ranged moves (v2) | 0.5 | 0.4222 | 0.039 | 0.588 | 0.639 |
| breaker, stale 300 | 0.5 | 0.6507 | 0.324 | 0.794 | 0.835 |
| breaker, stale 120 (FINAL) | 0.5 | 0.6623 | 0.382 | 0.755 | 0.850 |
| FINAL | 1.0 | **0.648** | 0.356 | 0.7525 | 0.835 |
Members at scale 1: hk-r1 .355, t1 .79, t2 .72; arms .44-1.0 (h3-press .46 and h6-pressd .44 are the only ones near the baseline's .42-.5;
h9-kenkite .25 -> .86, h5-kite .42 -> .90). Host tests ALL PASS; inc_live 0.255 (the live lookup untouched).

## Risks
- Reads both sides' Konpaku / Reishi (the HUD's numbers, not Hisagi's inputs); a pure-perception purist could object.
- The press arms (h3, h6) still ~0.45: against a Hisagi that presses, the breaker rarely fires and the loss is elsewhere (wake-up Hohos: see b0_a0).
- Attacking into Hisagi's Hoho at a stand-off can trade badly; the gain shows it pays on average. Threshold 120 vs 300 differ within noise.
- Winning-the-tiebreak side of the rule untested at large leads (the turtle is simply the KI code's own).
