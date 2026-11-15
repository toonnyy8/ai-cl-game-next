# b0_a1 proposal: reach margin 3.5 makes the Hoho in fire; descriptor passes, table score unchanged
Draft failed its descriptor (30.6 vs arm 0's 41.5): margin 1.0 + lunge let J1/NS start from range, so the Hoho in (reached only when neither can-j nor can-n) rarely ran.
Keys changed vs draft: :kk-reach-margin 1.0 -> 3.5 (J1/NS start only close, so kk-pick's Hoho in is the move from 6 m), :kk-lunge-p 1 -> 0, :kk-step-in-p 0 -> 1, :hoho 1.5 (shared output), :kk-step-p 1.0 and :kk-step-max 7.0 (back Step), :kk-dodge-p 1.0; dropped :kk-kikon-ptr-p 0; kept :kk-hoho-in-p 1, :kk-hin-fs 100, :kk-hoho-in-max 6.
Screen (steps+hohos a match, arm 0 = 41.475, bar 53.9): v1 margin 2.0 = 47.5; v2 margin 3.0 = 52.4; v3 (final) margin 3.5 + :hoho 1.5 = 60.1 PASS, K.O. 0.95 (scratch/screen-v3).
Table score (block 300): 0.5 (anchor 194-1-5, mix 100-90-10, rest 6-165-29) vs baseline 0.5016 (194-1-5 / 100-84-16 / 7-163-30): noise. Runs used: 3 screens + 1 score.
