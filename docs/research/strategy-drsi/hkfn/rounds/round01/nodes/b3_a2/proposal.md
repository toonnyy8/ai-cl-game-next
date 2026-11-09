# b3_a2 (round 1): the Reishi pot (a free WHITE Burst when Reishi is down)

Job (one line): when Hisagi is free, Kenpachi is >= 4 m away and not mid-move, his flash-step is >= *fs-burst* and his Reishi <= 80 % of max,
press the Burst (WHITE: +70 Reishi/s, ~390 over a full run); one roll per episode (HARD 1.0 / NORMAL 0.5 / EASY 0).

## Evidence
- Parsing the sim's gate rows and hash lines: against the live KH about half the matches reach the 300 s bell, and most of those are 9-9
  Konpaku decided by Reishi % (Kenpachi ~1300, Hisagi 100-1200). The bait never lets Hisagi score a Kikon, it out-chips him. A clock
  problem, not a damage problem. (Earlier cells all changed what he presses; none restored Reishi.)
- WHITE is free (idle / run / guard, flash-step >= 200); the shared CPU only bursts out of combos, so a free Reishi pot is unused.
- Earlier cells: b3_a0 found Burst-on-combo costs flash-step (-0.07), awakening hold loses, DRIVE switch neutral; b3_a1 awaken timing neutral.
  I first tried "hold the awakening to 45 s left" (20 % heal): no change (0.262 vs 0.255 at scale 0.5, live identical): that gauge is rarely full.

## Not a repeat / duplicate
It restores Reishi; no earlier cell did. It never picks a move or a distance. Kenpachi's KI code never uses the Burst.

## Measurement (dev seed0 300)
| variant | scale | score | live / past / arms / standin |
|---|---|---|---|
| parent (hold awaken until safe) | 0.5 | 0.255 | .029 / .144 / .576 / .269 |
| awaken held to 45 s left | 0.5 | 0.262 | .029 / .173 / .576 / .269 |
| pot, Reishi <= 0.8 (final) | 0.5 | 0.356 | .118 / .312 / .534 / .462 |
| pot <= 0.95 | 0.5 | 0.318 | .118 / .277 / .531 / .346 |
| pot <= 0.65 | 0.5 | 0.295 | .128 / .223 / .523 / .308 |
| final | 1.0 | 0.3315 | .099 / .318 / .556 / .353 (baseline dev 0.195) |
Host tests ALL PASS.

## Risks
Live-KH group 0.10 stays far under the keep rule's 0.2985, and the stand-in 0.353 under 0.376: Reishi parity at the bell gives a draw
or a narrow win, it does not beat the bait. Costs flash-step (no Step for ~4-5 s). The 0.8 threshold is a noise-wide sweet spot (+-0.03).
