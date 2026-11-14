# b3_a0 (x-ih-H2 round 1): Hisagi IH, ihx style keys re-tuned
Baseline x-ih-h-r1-b0a1 reproduced at block 300: 0.6172 (anchor 195/5/0, mix 67/128/5, rest 109/79/12).
Evidence from round 1's b3 (old rules): a larger :ihx-margin with a shorter :ihx-chase helped, :ihx-reishi flat.

Block 300 (win/loss/timeout per group):
- v1 :ihx-margin 0.1 -> 0.6, :ihx-chase 20 -> 6: 0.6551 (anchor 199/1/0, mix 73/124/3, rest 122/69/9) <- cand.lisp
- v2 :ihx-reishi 0.5 -> 1.0: 0.6089 (194/6/0, 78/119/3, 94/92/14)
- v3 :ihx-chase 20 -> 8 only (margin 0.1): 0.5957 (199/1/0, 65/132/3, 94/100/6): chase alone does not help; margin is the lever
- v4 :ihx-p 0.6: see below if measured
Differences of 0.03-0.04 are near noise (SE ~0.02); v1 is the best seen.
