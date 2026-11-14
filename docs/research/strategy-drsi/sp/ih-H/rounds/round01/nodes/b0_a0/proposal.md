# b0_a0: h1-range with the generic walk/awaken/string scales retuned
Mechanism: baseline h1-range (fn hisagi-range-style, DRIVE switch map, no NS out of reach) plus base keys that reach the MCTS/generic fallthrough outside the ranged-mode steering: :awaken 3.0, :range 1.75 (walk band scale), :ns 0.9, :hoho 0.3, :cont 2.0, :turn 2.0.
Evidence (seed0 300, one-change steps): awaken 3 anchor 162 -> 190 wins (but rest 53 -> 40); hoho 0.3 +; range 1.5-2.0 lifted rest 41 -> 58-67; ns 0.9 and cont/turn 1.5-2.0 added to rest (77). range 0.5 collapses (0.25); awaken 5, kikon 2.0, hold-awaken 0.5 worse. Kite-style :b-* biases (arm v1) mostly gave time-outs.
Not a repeat: baseline sets only :dswitch; this is the generic-CPU scale group.
Risk: seed-300 tuning (SE ~0.02); the mix group (c-ki-i-r1-b0a2) is still lost 197/200: no knob tried touches it.
Measured: score 0.467; anchor 200/0/0, mix 3/197/0, rest 77/121/2 (baseline 0.3647).
