# b0_a1: wide kite with full combo continuation (cont 1.0), claimed everywhere

Slice (:own): all three :lead sets (own_share 1.0): the composite is the strategy alone. Slicing showed nothing in b0_a0 (no slice beats the whole).
History read: baseline 0.035 (search); b0_a0 s3-zoner 0.135; b1_a0 kite (range 2.6, NS 1.0, j1 -0.3) 0.17; b2_a0 s3-wide (range 2.0) 0.12.
All three share one mechanism (spacing + NS) and all kept :cont at 0.7-0.8, below the default 1.0.
Strategy: b1_a0's kite pushed to range 3.2 with :cont 1.0 (the default combo-continuation scale; s3 / kite lowered it), :hoho 1.0, no :awaken override.
Dev (seeds 800 / 850, 50 a seat, inc 0.09 / 0.08), same base otherwise:
  cont 0.4 -> 0.05 (800); cont 0.7 -> 0.18 (awaken 0.3); cont 1.0 -> 0.26 / 0.21 (awaken 0.3), 0.34 / 0.26 (awaken default); cont 1.4 -> 0.22 / 0.28;
  awaken 0.0 -> 0.17 / 0.11; hoho 0.6 + wait 0.1 -> 0.16; range 2.6 + hoho 1.4 + turn 1.2 -> 0.13 / 0.12.
Not a repeat: the new lever is :cont (continue strings after a hit), monotone up 0.4 -> 1.0, with the awaken left to the CPU; earlier cells only moved spacing.
Final dev (800): 0.34 vs inc 0.09. Risk: dev noise ~0.05 and the 0.34 is the best of ~8 variants (selection bias); expect ~0.2-0.25.
