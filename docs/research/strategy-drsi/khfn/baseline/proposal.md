# Baseline: ken-kh-style = his KI style CPU unchanged

`duel/lisp/cpu-kh-ken.lisp` defines `ken-kh-style`, which calls `ken-ki-style` (cpu-ki-ken.lisp, written against Ichigo). The search starts
from it. `score.json` is the frozen evaluator on the search block (seed0 200).

## References (refs.jsonl, the same evaluator; the held-out block 400 at scale 2 = 1,900 matches)

| Strategy played whole | search 200 | dev 300 | held-out 400 (x2) | live group (200 / 300 / 400) |
|---|---|---|---|---|
| his KI code (this baseline) | 0.457 | 0.415 | 0.429 | 0.134 / 0.074 / 0.114 |
| Ichigo's KI code on Kenpachi (khjoint/k/k5-iki.lisp) | 0.339 | 0.383 | 0.371 | 0.139 / 0.223 / 0.172 |
| the live KH table :qks2-hisagi (khjoint/kh-t2.lisp: both codes + data arms, switched every 0.5 s) | 0.593 | 0.590 | 0.555 | 0.272 / 0.257 / 0.192 |

- His KI code wins the arms group (0.63-0.66) and Ichigo's wins the live table (0.14-0.22): neither alone does both; the live table, which
  switches between them by form, beats both. Its numbers are what a style that will become one of its arms has to add to.
- Against Hisagi's 11 whole arms his KI code loses most to `h9-kenkite` (0.22) and the press arms (0.48-0.52) and beats Ichigo's code /
  the ranged style on Hisagi (1.0).

## The keep rule (fixed before round 1)
A cell's code is kept only if, on the held-out block (seed0 400, scale 2, never shown to cells):
1. its score >= 0.4586 (the better KI code's 0.4286 + 0.03; unpaired: the evaluator has no per-seed pairing across candidates);
2. its live group >= 0.1716 (the better KI code on the live table, Ichigo's);
3. it is not a near-duplicate: the mean |difference| of its 14 member shares >= 0.05 against both his and Ichigo's KI code.
Of the codes that pass, the best is kept as one style unit (a second only if it passes and is no near-duplicate of the first).
