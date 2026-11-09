# b0_a1 (round 1): parent b0_a0 (wake-up bait) plus a closing-in test that found nothing

Job (one line): same as b0_a0: hold at 2.3 m through Hisagi's knockdown/wake-up so his wake-up Hoho has nothing to hit, punish its end; else ken-ki-style.

## What was tried (direction: close on his chain range)
- v1: bind the KI code's `*kk-hoho-in-p*` to HARD 1.0 (Hoho in from out of reach). Dev seed0 300, scale 0.5: 0.8005 vs parent 0.8882
  (live 0.73 vs 0.87, iterates 0.75 vs 0.88). Flawed idea, not a bug: the arrival gets punished by his chain. Left as a knob, off.
- v2: widen `*kk-step-in-band*` (2.2 4.4) -> (2.2 5.6) so the free Step starts from mid range. Result identical to the parent to the digit
  (0.8882, same members): the Step-in does not fire beyond the old band in these matches, so no effect.
- Final file = parent behaviour (bait) with these two knobs bound around the delegate (hoho-in off, step band widened): effectively b0_a0.

## Measurement (seed0 300, scale 1, 950 matches)
score 0.8867 (live 0.8762, iterates 0.8564, arms 0.9275); identical to b0_a0's dev number. inc_live 0.255 (not moved). Host tests ALL PASS.

## Risks / not a new mechanism
No gain over b0_a0; the closing-in direction did not beat the bait. Same near-duplicate status as b0_a0 relative to the KI codes (bait state machine).
