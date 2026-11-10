# b3_a0 (round 2): Reishi pot on Ichigo's KI code -- NEGATIVE RESULT

Started from: Ichigo's KI code on Hisagi (live 0.30, stand-in 0.005). Job: when Reishi <= 0.8, flash-step up, Kenpachi >= 4 m and not mid-move,
press the free WHITE Burst once per episode (HARD 1.0 / NORMAL 0.5 / EASY 0); everything else is ichigo-ki-style (state: HKB includes IKST).
History read: round 1 all negative; b3_a2 (Reishi pot on the merged style) was the best score (0.32 held-out) but live 0.12; b3_a0/a1 (DRIVE
switch, awaken timing) neutral; every first-free-frame change after a knockdown loses. This combines "the only code at the live floor" with
"the only resource lever that moved the clock-decided matches"; not a repeat of either.

Measurement (dev seed0 300, scale 0.5, 610 matches): score 0.142; live 0.284 / past 0.158 / arms 0.107 / standin 0.019.
Ichigo's KI code alone: live ~0.30, stand-in 0.005 (held-out) -> the pot changes nothing measurable (live within noise, stand-in +0.01).

Finding: Ichigo's code reaches the live floor by its own neutral/meaty play, not on the clock; its stand-in/arms collapse is its Ichigo-specific
reach tables misfiring on Hisagi's kit, which a Reishi resource lever cannot touch. Do not keep: fails the stand-in floor, score 0.142 far under 0.3153.
Not run: host tests (file only adds a struct and a wrapper; eval compiled and ran it).
