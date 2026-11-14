# b0_a1: parent b0_a0 (:xch-j 0, 0.83) plus :clash-p 0.3
Key added: :clash-p 0.3 (fewer clashes: fewer mix time-outs, 8 vs 36 of 200). :xch-j kept at 0 (edge).
Evidence (seed0 300, 600 matches; parent 0.83 = anchor 198/2/0, mix 136/37/27, rest 166/19/15):
- :clash-p 0.3  -> 0.8449 (anchor 194/6/0, mix 148/44/8, rest 167/31/2)  FINAL
- :clash-p 0 + :clash-margin 0.4 variants: p0 0.8251; margin 0.4 alone 0.8333; p 0.3 + margin 0.4 0.835
- :clash-margin 1.6 -> 0.7624; :clash-p 1.7 -> 0.736 (worse: more time-outs)
Gain is modest (+0.015, within noise likely): less clashing converts time-outs to wins/losses.
