# b1_a0: NS side of a cancel (:xch-sa-p 1.5, :xch-carry-p 3.0) on the baseline arm
Keys added to :base: `:xch-sa-p 1.5 :xch-carry-p 3.0` (HARD defaults 0.65 / 0.2, clamp at 1). Everything else = baseline c-ih-h-r1-b0a2.
Block 300, SP_BUILD 949a94db54fe (baseline 0.5396):
- v1 (final) sa-p 1.5, carry-p 3.0: 0.6518 (anchor 196-0-4, mix 85 W/108 L/7 TO, rest 111/67/22)
- v2 sa-p 0, carry-p 0: 0.3812 (so the NS-side SA matters in the other direction)
- v3 sa-p 1.5, carry-p 0, sa-wait 2.0: 0.6469 (carry adds little; sa-wait 2 no gain)
Idea: always SA the opponent's turn after a cancel; carry on when nothing seen.
