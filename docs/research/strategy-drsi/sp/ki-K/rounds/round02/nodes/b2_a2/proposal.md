# b2_a2: b2_a0/b2_a1 arm + :kikon 0.0 (never hold an SP into a Kikon)
Mechanism: ken-kh-standoff-style, parent's knob set (no Bankai, reach-p 0.5, step-p 1.0, dodge-p 0, brawl-p 0.2) plus the generic key :kikon 0.0, which scales every SP press's Kikon-hold chance (cai-sp) to zero: SPs are tapped, never held into a Kikon.
Evidence (seed0 300, new population; parent 0.8713 reproduced): kikon 0 0.8762, 0.5 0.8746, 2.0 0.8465; other 0 0.7954, 2.0 0.8135; hold-awaken 0.5 0.7624; turn 0.5 (+kikon 0) 0.835; wake-hoho-p 0 0.6287; kikon-ptr-p 0 0.3828; read-range 4.0 0.8317; hin-fs 100 + hoho-in 0.15 0.8581; inert: cont 1.0, kk-kikon-red-p under kikon 0, meaty/hoho-in-max/bk-ns-p.
Not a repeat: untried generic keys (:kikon, :other, :turn, :hold-awaken) on the round-2 arm; parent branch only tuned :kk-* keys.
Risk: +0.005 over parent is a tie (SE ~0.02); local optimum, every neighbour measured is lower or equal.
Measured (seed0 300): score 0.8762; anchor 188W/12L/0TO, mix 163/30/7, rest 177/20/3.
