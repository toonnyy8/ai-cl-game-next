# b3_a1 (round 1): awaken at a safe moment (resource timing) -- NEUTRAL, not keep-worthy

Job (one line): hold the Shikai's awakening (kill the KI code's immediate awaken door, kks-aw :no) and spend it only at a safe moment:
Kenpachi perceived >= 5.0 m away or down / getting up / stunned / airborne; one brain-roll per free step while safe (HARD 1.0, NORMAL 0.5, EASY 0).

History: b0_a0 (wake-up replacements) all lose; b1_a0 (Shikai kiting) +0.06 mostly stand-in/arms, live flat; b2_a0 (wake-up punish) live 0.19 but total 0.236;
b3_a0 (Burst always/never worse; holding the awakening for SUBLIMATION loses, "the early Bankai matters"; DRIVE switch neutral).
So this is the untried middle: not holding, not instant, but awakening when the cinematic cannot be punished. Not a KI-code repeat (the KI code awakens on the first free step).

Measurement (dev seed0 300): scale 0.5 far 5.0: 0.2376 (live .029 / past .144 / arms .431 / standin .346); far 3.5: 0.2364 (same); baseline 0.2163 at 0.5.
Final scale 1: 0.2163 (live .020 / past .142 / arms .429 / standin .275) vs baseline dev 0.195 (+0.02, inside the +-0.02 noise). Host tests ALL PASS.
The scale-0.5 stand-in gain (.27 -> .35) did not hold at scale 1 (.275).
Far 5.0 vs 3.5 give identical arms/standin: the safe moment is nearly always the down/stun/air states, the distance rarely matters.

Risks / verdict: the live KH group stays at 0.02, far below the 0.2985 bar; the effect is noise-sized. Resources (awakening timing) are not where Hisagi loses to the bait.
Will not pass the keep rule.
