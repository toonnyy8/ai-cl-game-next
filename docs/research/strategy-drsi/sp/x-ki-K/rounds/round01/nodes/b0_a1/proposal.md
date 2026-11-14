# b0_a1: :xch-j 0.0 + :clash-margin 1.6
Parent b0_a0 (:xch-j 0.0, 0.5132) plus `:clash-margin 1.6` (one knob, two reads: the clash distance test and the J side's AS reach test).
Seed0 300 evals (all with :xch-j 0.0):
- margin 0.5: 0.5627 (anchor 141:54:5, mix 72:128:0, rest 125:73:2)
- margin 1.3: 0.5412 (130:65:5, 71:129:0, 124:75:1)
- margin 1.6 (FINAL): 0.6287 (anchor 130:67:3, mix 108:92:0, rest 140:57:3)
- margin 2.0: 0.5957 (140:54:6, 80:120:0, 138:61:1)
- margin 2.0 + clash-p 1.7: 0.6155 (143:52:5, 96:104:0, 131:67:2)
- clash-p 1.7 (margin 1): 0.566 (137:57:6, 64:136:0, 139:60:1)
- clash-p 0.0 (margin 1): 0.3861 (83:114:3, 54:146:0, 94:101:5)
Non-monotone in margin (noisy, +/-0.03 plausible); all margins != 1 beat parent 0.5132. clash-p 0 is clearly bad, so the clash is worth entering.
