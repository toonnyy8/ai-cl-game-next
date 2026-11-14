# b1_a1: mycell band, Hoho-safety off only when behind on Konpaku
Band: `mycell` (G2 rules 30-35). Arm k = arm 0 + `:rules ((((:lead :behind)) (:kk-ns-safe-p 0.0)))` (same :fn, state kept).
Mechanism: with a cell in hand and behind on Konpaku, he cannot wait out her timed Hoho; start J1/NS at once (arm 0's :kk-ns-safe-p 0.8 otherwise). Sibling b1_a0 found plain ns-safe 0 as the one live knob; this is its situational form.
Screens (block 300, mycell band, 5 variants total, all single-mechanism): wave-p 1 0.6535, brawl-p 1 0.6535, ns-stop-p 0 0.6419, hoho-in 1 + hin-fs 100 + step-in 1 0.6534 (all ~ arm 0 0.6518 or worse); lead-behind ns-safe 0 (final) 0.67.
Measured (eval.py seed0 300, final cand.lisp): score 0.67; anchor 189W/11L/0TO, mix 55/145/0, rest 159/41/0 (arm 0: 187 / 52 / 153).
band.py pair (--a arm 0, --b cand, seeds 301-400): anchor b 3 c 5 z -0.71; mix b 25 c 28 z -0.41; rest b 12 c 18 z -1.1; pooled b 40 c 51 z -1.15 (b = arm 0 won, cand did not; negative z = cand ahead); time-outs 0/0.
Verdict: +0.018, within noise (SE ~0.02), not a demonstrated gain. The band fires (counts differ from arm 0) but the effect is small.
