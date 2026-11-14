# b3_a2 (IH, Hisagi, round 1): parent b3_a1's data arm + :hoho 3.0 + :hold-awaken 1.0

Parent b3_a1 = hisagi-range-style, :awaken 5 :range 1.5 :ns 2 :cont 2 (0.4373; anchor 196/4/0, mix 4/195/1, rest 62/132/6). Unread keys of that arm tried: :turn 3 (0.4125, worse), :hoho 3 (0.4521) and 6 (0.4488), :hoho3+:other 2 (0.4472), :hoho3+:kikon 0.5 (0.4208), :kikon 2 with hold-awaken 0.6 (0.4835, anchor drops to 150).
:hold-awaken (no awakening until Sublimation >= H x max) with :hoho 3: H 0.2 0.4686, 0.4 0.4505, 0.6 0.4851, 0.8 0.4653, 1.0 0.5016. Noisy and non-monotone, but all above 0.4521; the rest group gains most (62 -> 114 wins), mix 4 -> 13, anchor falls 196 -> 174.
Why not a repeat: parent never touched :hoho / :hold-awaken; b3_a0 only raised :awaken (awakening earlier); this holds the awakening until the gauge is full, the opposite.
Risk: single seed block; the anchor group loses 22 K.O.s; non-monotone in H.
(:id :c-ih-h-r1-b3a2 :fn hisagi-range-style :apply (:hisagi) :dswitch-map ((:base 1 3)) :base (:dswitch 1.0 :awaken 5.0 :range 1.5 :ns 2.0 :cont 2.0 :hoho 3.0 :hold-awaken 1.0) :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0))))
Final measured: score 0.5016; anchor 174/26/0, mix 13/184/3, rest 114/77/9.
