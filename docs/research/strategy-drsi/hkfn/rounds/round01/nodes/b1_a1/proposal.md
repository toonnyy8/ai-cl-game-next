# b1_a1 (round 1): Spacing, the kite in both forms

Job (one line): when Kenpachi walks in to the edge of Hisagi's reach, back off one Step, then poke with the pointer's NS from the new distance; now also in the Bankai's ranged mode (closing start 4.2 m instead of the range style's 3.4 m).

Mechanism: b1_a0's kite (parent) with the Bankai gate removed. The kite runs first when free (idle/run); one brain-roll per approach event
(HARD 1.0 / NORMAL 0.6 / EASY 0.25); window 50 f for the poke (2.9-6.0 m, not mid-move). New knob *hkk-near-bankai* 4.2: in the
Bankai the range style owns everything inside 3.4 m, so the early back Step covers 3.4-4.2 m while he closes. State in HKS (includes HMS).
Kenpachi read only via SNAP S and D; no globals, no cai-defstyle.

History: b0_a0 (wake-up variants) lost everywhere; b2_a0 punish-at-wake-up lifts live only (0.15); b3_a0 DRIVE switch neutral; b1_a0 kite 0.256 (rescored), gain in stand-in/arms, live flat. This is a targeted extension of the kite (the Bankai half my hint asked for), not a repeat: b1_a0 left the Bankai to the range rule. Not a KI-code duplicate: Kenpachi's KI code never retreats.

Measurement (dev seed0 300): scale 1 = 0.2833 (live 0.074, past 0.197, arms 0.510, standin 0.353); parent b1_a0 reported 0.2604 at scale 1
(0.284 at 0.5; this 0.2895 at 0.5). Noise +-0.02, so the Bankai half is a small, uncertain gain (arms 0.43 -> 0.51 is the visible part).
Host tests ALL PASS.

Risks: live-KH group stays ~0.07 (keep rule needs 0.2985), so it will not be kept alone; near-duplicate of b1_a0.
