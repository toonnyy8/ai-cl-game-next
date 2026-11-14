# x-kh-H2 r1 b2_a0 (clash / awakening breakers), seed0 300, HARD, 600 matches. Baseline 0.5693 (195-0-5 / 31-115-54 / 116-14-70)
Counts anchor / mix / rest = ko_wins-ko_losses-timeouts.
- v1 awaken-break-p 1.9, awaken-kikon-p 1.2 only: 0.5693 (191-0-9 / 33-119-48 / 118-13-69)
- v2 clash-p 1.7, clash-margin 1.6: 0.5908 (191-1-8 / 31-148-21 / 133-15-52)
- v3 clash-p 1.7, clash-margin 0.3: 0.571 (184-0-16 / 30-143-27 / 129-17-54)
- v4 clash-p 1.7, margin 1.6 + awaken 1.9/1.2 (FINAL cand.lisp): 0.604 (193-1-6 / 37-141-22 / 133-17-50)
Clash scale up cuts time-outs (rest 70 -> 50); awaken keys add a little on top. Gains are time-out conversions, mix losses rise (115 -> 141).
