# b2_a0: style CPU + rush data, claimed outside my J1 reach

History read: b0_a0 (ichigo-ki-style alone, claimed everywhere: search score 1.0, suspiciously perfect), b1_a0 (data-only rush
claimed at :dj afar/out/reach: search 0.565), baseline 0.105.

Slice: :dj afar OR out OR reach (~80% of judgements); the incumbent keeps the close (:in) fights.
Strategy: :fn ichigo-ki-style plus b1's rush data (range 0.5, ns 0.1, cont 1.4, awaken 2.0, walk-in/step-in bias).
Different from earlier cells: b0 claims everything with the fn only; b1 has no fn. This combines both pieces on a narrowed slice.

Dev (seeds 800, 50/seat): composite 100/100 vs incumbent 11/100, b=89 c=0, own_share 0.795. Narrower slice (:dj afar only):
0.49, own_share 0.33, so claim size matters: the effect is tied to how much of the match the style CPU plays.
Risk: same as b0 (style CPU may exploit the s3 zoner; check held-out seeds / replay). Benefit over b0: none measurable on dev
(both saturate); a smaller slice leaves the incumbent in close fights as insurance if the fn's close play ever turns out weak.
