# b0_a1 (ki-K-band, round 1): nocell specialist = arm 0 with :kk-meaty-p 0.0 :kk-link-p 0.5
Band: nocell. Arm k = arm 0 (r2-b1a2), same :fn; the two keys placed before the base (first wins): no meaty J1 chase onto her knockdown, and half of landed NS segments stop instead of linking.
Mechanism (hypothesis, not proven): with no cell on either side, a long chase / link overextends into her counter; the screen shows the gain only in the mix group (c-ki-i-r2-b2a2), a loss in anchor.
Screened 9 variants on block 300 (baseline band table 0.6518): step-in 1.0 0.6485; reach-p 1.0 0.6337; reach-margin 0.15 0.6435; dodge 0 + brawl 0 0.6535; kikon 1.0 0.6584; hold-awaken 0.6 0.6353; meaty 0 + link .5 0.67 (chosen). b0_a0's ns-safe 0 (0.7145) was not repeated, as another cell's pick.
Measured (final cand.lisp, seed0 300): score 0.67; anchor 179W/21L/0TO, mix 74/126/0, rest 150/50/0.
Paired vs arm 0 (band.py pair, b = arm 0 only, c = cand only): pooled b 72 c 83 z -0.88; anchor b 16 c 8 z 1.63; mix b 34 c 56 z -2.32; rest b 22 c 19 z 0.47; time-outs 0/0.
Risk: weak, within noise; pooled z -0.88 is not significant, anchor group is worse. Likely will not replicate.
