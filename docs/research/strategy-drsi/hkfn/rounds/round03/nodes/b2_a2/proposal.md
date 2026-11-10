# b2_a2 (round 3): b2_a1 + hkp, a stand-off poke (fifth rule) -- NEUTRAL / NEGATIVE, not keep-worthy

Job (one line): when Kenpachi stands idle at the stand-off (3.0-3.8 m, seen idle 24 frames) and Hisagi is free, one roll per episode, poke him with the pointer's NS.

Mechanism: hkp-step (knobs *hkp-p* .3/.6/1.0, *hkp-min* 3.0, *hkp-max* 3.8, *hkp-idle* 24; slot hk-idle, -1 = rolled this episode, reset when he moves or leaves the band).
Parent b2_a1 (hkw wake-up punish/guard, hkb Reishi pot, hks Step-in answer, hkd Hoho through a slow move start); each rule keeps its own knobs / step fn / slots.

History: round 1 b1_a2 (kite also vs a standing Kenpachi, weak; its zone poke dropped); round 1 b2_a1 neutral whiff punish lowered the stand-in; the kite (b1_a1/b3_a0) is the only stand-in lever.
Not a KI-code duplicate (nothing in the KI code pokes from range); it is a cousin of the kite's poke without the back-step.

Measurement (dev seed0 300): v1 band 2.6-3.8 / idle 12, scale .5: 0.4635 (live .431, standin .462) vs a parent-like block 0.4939 (live .510): worse, a poke into the bait that waits at 2.3 m costs the live KH.
v2 band 3.0-3.8 / idle 24, scale .5: 0.4854 (live .5098 and standin .4808 identical to the parent block: the rule almost never fires there).
Final scale 1: 0.4519 (live .4604, past .3284, arms .6169, standin .402); parent b2_a1 on the same block 0.4604 (.4604 / .393 / .5862 / .402). No change in live / stand-in; past moved by noise.
Host tests ALL PASS. Recommendation: drop; the stand-off is not an exploitable moment for a poke.
