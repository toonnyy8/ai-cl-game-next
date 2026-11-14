# b0_a0: :xch-j sweep (baseline already at the cap)
Baseline :xch-j 2.5 (J share 0.4 x 2.5 = 1.0, the clamp: always J). Sweep, seed0 300, SP_BUILD 949a94db54fe:
- 2.5 (baseline, final cand.lisp, only the id differs): 0.6172 (anchor 195/5/0, mix 67/128/5, rest 109/79/12 wins/losses/timeouts)
- 1.2: 0.566 (anchor 195/2/3, mix 66/128/6, rest 79/92/29)
- 0.0: 0.5082 (anchor 185/0/15, mix 51/132/17, rest 69/90/41)
Monotone in k; more AS means more time-outs. No headroom above 2.5 (clamped at 1). cand.lisp = baseline arm with id :x-ih-h-r2-b0a0; it does not beat the baseline.
