# b1_a1 behind-red-extra (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` OR `:ored :yes` OR (`:ost :active` AND `:lead :even`) OR `:ost :evade`; own_share ~0.23.
Strategy: `:fn ichigo-ki-style` (her own style CPU; incumbent plays Kenpachi's), no :base (base keys are inert under :fn).

History read: round 1 = range-0.7 slices over the old incumbent (flat), ken-style-all won (now incumbent). Round 2 siblings: b0_a0/b1_a0 behind only,
b2_a0 behind OR ored (best, dev +0.325). I reproduced the behind and ored signals and probed other slices for her own style (dev seed0 800 x100, gain):
ost startup +0.015 (own .6%), ost evade +0.045 (own 2%), dj afar -0.045, mr high x behind +0.025, ost active x even +0.13 (own 1%),
behind x mr low +0.11 (capped smaller), generic s0 (no fn) on behind|ored -0.18 (data-only is far worse than the borrowed style).
Second block (seed0 900 x50): active-x-even -0.02 and evade -0.05, so neither replicates alone; added to the union they do not hurt
(u2 800: +0.34 b83 c15 z 6.9; 900: +0.23 z 3.2; vs behind|ored alone 800 +0.325, 900 +0.24).
Honest verdict: this is b2_a0's mechanism (behind + red-opponent -> own style) with two ~1-2 % extra clauses that are within noise; expect the same
search score as b2_a0. Not a structurally new counter: I found no other slice where her own style beats the incumbent
(ahead -0.18, even -0.04, far -0.045, generic -0.18).
Risk: butterfly effects; the extras are unproven. If the coordinator prefers, b2_a0 is the safer equal.
