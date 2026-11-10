# b3_a2 (round 3): b3_a1 with the Reishi pot opened further (resource lever, tried and flat)

Job: rule 2 of three (hkb-step, the Reishi pot) retuned again; rules 1 (hkw wake-up punish / guard) and 3 (hkk kite) untouched, all separable.
Change: *HKB-BELOW* 0.95 -> 0.99, *HKB-RANGE* 3.0 -> 2.4 (drink whenever Reishi is not full and Kenpachi is seen >= 2.4 m away, not mid-move).

Direction (resources: Bankai/awaken, DRIVE, Burst, Reishi, the bell). History: round 1 awaken / DRIVE / Burst-always neutral or negative; the pot was
the only resource lever that moved. Two experiments this cell (dev 300, scale 1, deterministic; b3_a1 re-run = 0.527, identical to its claim):
1. NEW fourth rule "bell stall" (hkz-step: last 45 s, not behind on Konpaku nor Reishi %, back-step from a closing Kenpachi, one roll per event):
   score 0.5049 (live .406 past .470 arms .644 standin .500) vs 0.527: worse; dropped. Retreating from the KI code costs more than it saves.
2. This file, pot 0.99 / 2.4 m: score 0.5268 (live .4554 past .5124 arms .659 standin .4804, inc_live .125) vs b3_a1 0.527
   (live .4356 past .4801 arms .6628 standin .5294). Flat overall: live / past up, stand-in down, within per-group noise.
Conclusion: the pot is saturated at b3_a1's setting; no resource lever left beyond noise. Not a KI-code duplicate (the KI code never drinks).
Risks: stand-in dipped .53 -> .48 (single run); three rules in the file (needs the split into wake-up / pot / kite arms). Host tests ALL PASS.
Recommendation: prefer b3_a1 (pot 0.95 / 3.0) over this cell; no real gain here.
