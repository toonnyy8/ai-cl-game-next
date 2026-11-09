# Baseline: hisagi-hk-style = his merged style unchanged

`duel/lisp/cpu-hk-hisagi.lisp` defines `hisagi-hk-style`, which calls `hisagi-merged-style` (cpu-hisagi-range.lisp: his ranged-mode style in
the Bankai, Kenpachi's KI code elsewhere; the strategy keeps `:ken-ranged t`). The search starts from it. `score.json` is the frozen
evaluator on the search block (seed0 200).

## References (refs.jsonl; groups live / past / arms / standin; the held-out block 400 at scale 2 = 2,440 matches)

| Strategy played whole | search 200 | dev 300 | held-out 400 (x2) | held-out groups: live / past / arms / standin |
|---|---|---|---|---|
| his merged style (this baseline) | 0.216 | 0.195 | 0.230 | 0.042 / 0.176 / 0.429 / 0.272 |
| Kenpachi's KI code on Hisagi (khjoint/h/h2-kenki.lisp) | 0.303 | 0.296 | 0.285 | 0.025 / 0.271 / 0.469 / 0.376 |
| Ichigo's KI code on Hisagi (h7-iki) | 0.125 | 0.117 | 0.136 | **0.299** / 0.121 / 0.120 / 0.005 |
| his ranged-mode style (h8-range) | 0.011 | 0.013 | 0.009 | 0.005 / 0.003 / 0.024 / 0.005 |
| (context) his live HK table :qhs-ken (corefit/hk-r1.lisp) | 0.586 | 0.623 | 0.596 | 0.090 / 0.616 / 0.813 / 0.866 |
| (context) Kenpachi's KI code + the kite's data (h9-kenkite) | 0.457 | 0.439 | 0.472 | 0.085 / 0.466 / 0.650 / 0.688 |
| (context) his merged style + press (h3-press) | 0.404 | 0.431 | 0.433 | 0.045 / 0.312 / 0.721 / 0.654 |

- Against the live KH (the bait as its event layer) every style but Ichigo's KI code wins under 0.1; Ichigo's code reaches 0.30 there and
  loses almost everything else (the stand-in 0.005). Kenpachi's KI code on Hisagi is the strongest pure style overall.
- The live table and his whole arms with data are stronger than any pure style (data matter for Hisagi), but still lose the live KH ~0.09.

## The keep rule (fixed before round 1)
A cell's code is kept only if, on the held-out block (seed0 400, scale 2, never shown to cells):
1. its score >= 0.3153 (the best existing style, Kenpachi's KI code on Hisagi, 0.2853 + 0.03; unpaired);
2. its live-KH group >= 0.2985 (the best style there, Ichigo's KI code);
3. its stand-in group >= 0.3762 (the best style there, Kenpachi's KI code);
4. it is not a near-duplicate: the mean |difference| of its 19 member shares >= 0.05 against each of the four existing styles;
5. it does one job (a bundle of independent rules is not admitted, the user: 「高內聚，低耦合」).
Of the codes that pass, the best is kept as one style unit (a second only if it passes and is no near-duplicate of the first).
