# b0_a2 (round 3): wake-up against an idle (bait) Kenpachi -- NEGATIVE RESULT; delivered file = PARENT (b0_a1 = b0_a0) unchanged

Job tried (rule 4, hkn-step): first free frame after Hisagi's knockdown, Kenpachi seen idle / running at 1.8-3.2 m (later 2.0-2.6 m, and later
only if seen standing >= 30 consecutive steps while Hisagi was down = the bait), one roll per knockdown: the pointer's NS (ranged poke through
the stand-off) instead of the shared CPU's wake-up Hoho.
Measurements (dev 300, scale 0.5, parent 0.4688 [live .451 past .421 arms .580 standin .423]):
- NS at any idle Kenpachi 1.8-3.2 m: 0.2932 (live .441, standin 0.019: ki-ken 0, k1/k2/k10 0, standoff 0).
- gate "Kenpachi never non-idle during the knockdown": 0.4688, bit-identical to the parent (the rule never fired: he is always seen in a move at some point).
- gate "seen standing >= 30 consecutive steps while down": 0.2981 (live .451 unchanged, standin 0.019): it fires only against the KI-type codes and never changes the live bait result.
Reading: the bait and the KI codes look the same on Hisagi's first free frame, and a poke / guard into an idle Kenpachi is exactly what the KI codes punish
(same as b0_a1's guard). The live bait wins on its Hoho-end J1, later than the first free frame, so a first-frame change cannot touch it. The back-Step
mode was not run (same situation). Reverted; no new rule.
File delivered = parent, re-measured at scale 1 (dev 300): 0.4422 (live .4208 past .3831 arms .5824 standin .3824 vs floor 0.3762); a duplicate of b0_a0 / b0_a1.
