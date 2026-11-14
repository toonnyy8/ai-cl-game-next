# b3_a0: Hisagi IH, style keys (ihx-*) re-tuned
Baseline c-ih-h-r1-b0a2: 0.5396 (:ihx-margin 0.1 :ihx-chase 20 :ihx-reishi 0.5).
Block 300 results (this cell):
- v1 :ihx-reishi 0.0: 0.5577 (anchor 197/1/2, mix 53/129/18, rest 85/87/28)
- v2 :ihx-reishi 1.0: 0.5627 (anchor 194/0/6, mix 62/123/15, rest 82/90/28)
- v3 :ihx-margin 0.6, :ihx-chase 6.0 (reishi 0.5): 0.5776 (anchor 197/1/2, mix 60/125/15) <- cand.lisp
- v4 margin 0.4, chase 8, reishi 1.0: 0.5264 (anchor 193/2/5)
All differences are about 0.02-0.04 (noise SE about 0.02): weak evidence the safer margin / shorter chase helps; reishi is flat.
