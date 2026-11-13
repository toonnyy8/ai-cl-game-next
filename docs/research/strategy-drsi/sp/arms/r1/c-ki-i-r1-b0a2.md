# b0_a2: b0_a1's arm plus a longer meaty reach (:iks-meaty-far 4.5)
Mechanism: b0_a1 (0.8053) unchanged, plus :iks-meaty-far 4.5 (default 3.0): Ichigo's meaty J1 chase after his knockdown now fires when Kenpachi goes down up to 4.5 m away, not 3 m.
Evidence (seed0 300): inert on 0.8053: :hold-awaken 0, :kikon 0.5, :iks-hoho-follow 50. Worse: mix-kessa 0.4 0.7525, mix-generic 0.3 0.7013, awaken-p 0.5 0.7574, hoho-p 0.6 0.8053 (no gain), mix-whiff/space 0 0.8036, getsuga-min 6.0 0.8152 (with meaty). meaty-far 3.8 0.802, 4.5 / 5.0 both 0.8234 (plateau).
Not a repeat: b0_a1 and its parent never touched the meaty knockdown chase (a different situation from the shut-gauge lunge and NS punish they tuned).
Risk: seed-300 only, +0.018 is under one SE (~0.02); the gain is mostly rest/anchor groups, mix group flat (153 vs 154 wins).
Measured final (seed0 300): score 0.8234; anchor 170W/29L/1TO, mix 153/47/0, rest 173/27/0.
