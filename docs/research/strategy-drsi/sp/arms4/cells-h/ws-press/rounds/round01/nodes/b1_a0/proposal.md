# b1_a0 (press): the ranged close rule switched ON, tuned to close in

Draft had `:hr-p 0.0` (close rule off; KI code owns it). Final arm = draft with `:hr-p 1.0 :hr-close 3.6 :hr-near 3.6 :hr-wa-pred 3.0 :hr-taba-p 1.0 :hr-edge 0.5` (6 m Hoho keys kept).

Why it keeps/raises the close share: the rule's closing events are WA (pointer 1, a lunge) and TABA + TATAKI push (pointer 2); the back Step only fires on his attack, pointer 2 without TABA, or near-and-predicted-far. `:hr-wa-pred 3.0` (max) makes WA beat the back Step at pointer 1, `:hr-taba-p 1` makes pointer 2 TABA instead of back Step, `:hr-edge 0.5` stops the cornered side-step, `:hr-close/near 3.6` starts the closing WA / TATAKI from farther. Close share not measured here (screen.json is the coordinator's).

Scores (seed block 300, 2 of 8 runs used):
- baseline 0.5686 (kh .5229, ih .6144)
- v1 (`:hr-p 1 :hr-near 3.0 :hr-wa-pred 3.0 :hr-taba-p 1 :hr-edge 0.5`) 0.5752 (kh .5065, ih .6438)
- v2 (final) 0.5964: kh .5131 (anchor 94-0-6, mix 57-34-9, rest 3-84-13); ih .6797 (anchor 88-6-6, mix 70-28-2, rest 47-53-0). Gain is all vs Ichigo `rest` (29 -> 47 K.O. wins); vs Kenpachi flat to slightly down. Counts changed, so the keys act.
