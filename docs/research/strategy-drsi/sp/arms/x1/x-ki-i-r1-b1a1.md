# b1_a1 (x-ki-I, round 1, NS side of a cancel)
Parent b1_a0 (sa-p 1.5, carry-p 0, sa-wait 2; 0.8383) with only :xch-sa-wait changed (k = frames/4; scripted wins at 4-8 => k 1-2, but k up to 12 searched). Seed0 300, 600 matches:
- wait 2.5: 0.8498 (mix 131/69, rest 182/18)
- wait 4: 0.8614 (mix 132/68, rest 187/13)
- wait 8: 0.9010 (mix 153/47, rest 190/10)
- wait 12: 0.8927 (mix 148/52, rest 190/10)
- wait 8 with sa-p 1.0: 0.7937 (mix 106/94, rest 173/27): sa-p 1.5 is needed
- wait 6 FINAL: 0.9142 (anchor 200/0, mix 159/41, rest 192/8, 0 time-outs); baseline 0.759
Why: a longer wait before the SA lets the opponent's turn show, so the SA lands; peak around 6-8, falls by 12. Single seed block: 6 vs 8 may be noise.
