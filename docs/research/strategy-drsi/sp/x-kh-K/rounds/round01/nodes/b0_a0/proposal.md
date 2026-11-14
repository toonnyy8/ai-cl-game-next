# b0_a0 (x-kh-K round 1, :xch-j)
Baseline cand.lisp plus `:xch-j 0` in `:base` (J side of a cancel: always AS at once, never the next J). Id :x-kh-k-r1-b0a0.
Measured (seed0 300, SP_BUILD 949a94db54fe):
- k=0 (final): score 0.4835 (baseline 0.4357). anchor 199-1-0, mix 25-3 / 172 timeouts, rest 66-1 / 133 timeouts.
- k=2.5 (all J): score 0.2426. anchor 109-91, mix 3-128 / 69 timeouts, rest 32-82 / 86 timeouts. Far worse (J chains lose exchanges).
Time-outs at k=0 still 305 of 600; the lever moved score through more K.O. wins, not fewer stalls alone.
