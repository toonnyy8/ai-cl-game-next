# b0_a1 (x-ki-K2 r1)
Parent b0_a0: :xch-j 0 is the floor (already in baseline). So I added other exchange keys to baseline (seed0 300, baseline 0.4538, anchor 145:47:8, mix 21:179, rest 106:92:2):
- xch-sa-p 1.5: 0.4785 (anchor 148:43:9, mix 17, rest 122:77:1)
- xch-sa-p 0.0: 0.264 (bad; the NS-side SA matters)
- awaken-break-p 1.9: 0.4406 (worse)
- sa-p 1.5 + awaken-break-p 1.9: 0.4819
- sa-p 1.5 + xch-carry-p 4.0: 0.4983 (FINAL; anchor 142:48:10, mix 29:171, rest 128:...)
cand.lisp = baseline + `:xch-sa-p 1.5 :xch-carry-p 4.0`. Final score printed in scratch/final.json.
