# b0_a2 ki-near-reactive
Slice: same as b0_a1 (best so far, search score 0.38): (:dn :in/:reach) OR (:mr :low), ~54% of ticks.
Strategy: ichigo-ki-style (incumbent's style CPU) with walk-to range x0.7 (every past cell's winner) plus :kikon 1.6 and :turn 1.4 (stronger hold and AS/SA read).
History: all six earlier cells gain via range 0.7 (+0.05..+0.135 search); narrow/odd slices (b1_a0 punish-active 0.255) do nothing. Dev variants here
(seed0 800, 50 seeds): range 0.5 0.39; +awaken 3/cont 1.3 0.37; +ns 1.5/hoho 0.6 0.31; +down-bias rules 0.39; behind/even-only 0.37; kikon/turn 0.40.
All within noise of each other (~0.05); kikon/turn picked as the best, not a proven improvement over b0_a1. Risk: it is mostly a b0_a1 repeat with extra scales.
