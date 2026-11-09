# b2_a1 (round 1): whiff punish, wake-up and neutral

Job: whenever Hisagi is free and Kenpachi is perceived recovering from a move (past its active frames) inside reach of J1 or the pointer's NS
and the recovery outlasts the move's startup, hit him with it. Builds on parent b2_a0 (the same punish, wake-up only); this adds the neutral.
Mechanism: hkw-any-step (not in the Bankai): one brain-roll per recovery event (*hkw-any-p* 0.3/0.6/1.0), hkw-fits-p gate reused, J1 else NS.
State in hks (includes hms). Everything else: parent's wake-up step, then the merged style. No globals, no cai-defstyle.
History: b0_a0 (wake-up roll/guard/SP) negative; b1_a0 kiting 0.256 but live flat; b3_a0 DRIVE switch ~neutral; b2_a0 wake-up punish live 0.15.
Not a KI-code duplicate: it only fires on a seen recovery (the KI code does not punish from Hisagi's reach), but it is close to b2_a0.
Measurement (dev 300): scale 0.5 0.2747 (live .235, past .178, arms .416, standin .269) vs b2_a0's 0.2681; scale 1 0.2408
(live .158, past .154, arms .435, standin .216) vs b2_a0's 0.2357: +0.005, inside noise. An any-lead of -4 changed nothing (hkw-fits-p's own lead gates first).
Risks: effect small; live KH ~0.16, far under the 0.2985 keep bar; the neutral addition is almost free. Stand-in not improved.
