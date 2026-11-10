# b2_a1 (round 3): b2_a0 + hkd, a Hoho through his slow move start (fourth rule)

Job (one line): when Kenpachi starts a move that reaches Hisagi and whose hit is still >= 4 frames away as seen (past HARD's 8 frame delay), plan one Hoho
so its invulnerable frames cover the hit (perfect: counter 60, 40 frame lock) and let the merged style's pf J1 cash the lock.

Mechanism: step function hkd-step (knobs *hkd-p* .3/.6/1.0, *hkd-min-left* 4, *hkd-lead* 8, *hkd-margin* 0.5; slots hk-ev, hk-dat). Free (idle/run), Kenpachi
perceived in :move, a new move start (snap-start differs from the last rolled), d <= reach + slide + 0.5, Hoho open, one roll per move start; pressed at
hit - 8 frames. Starts from b2_a0 (= b0_a2's wake-up punish/guard hkw, Reishi pot hkb, + the Step-in answer hks); each rule keeps its own knobs/step fn/slots.
Idea from Kenpachi's own KI code (kk-read's dodge: Hoho through a move that cannot be beaten); it never fires on his J1 (startup 6, over before it is seen).

Evidence from history: every blind change to the first free frame after a knockdown lost; Hoho timing onto a Step's J1 (b2_a0) held the stand-in at 0.38;
the kite (siblings) lifts the stand-in via spacing. This is a different mechanism (a reaction to his slow NS/string-link starts), not the kite, not a
KI-code duplicate (it answers moves, the KI code answers nothing of Hisagi's by Hoho).

Measurement (dev seed0 300, scale 1, 1,220 matches): score 0.4604; live 0.4604, past 0.393, arms 0.5862, standin 0.402; inc_live 0.125 (tripwire unmoved).
b2_a0 on the same block: 0.4461 / 0.4505 / 0.3731 / 0.5785 / 0.3824. So stand-in +0.02 (above the 0.3762 floor, inside the noise of 50-100 matches), live +0.01.
Members: kh-t0 .46, ki-ken .40, k1-ken .45, k2-press .20, k10-kends .375. Host tests ALL PASS. I did not log how often the rule fires.

Risks: the gain is within the +-0.02-0.05 noise; a Hoho spent on a move that does not reach costs a third of the flash-step gauge; four rules in the file (split into one-job arms).
