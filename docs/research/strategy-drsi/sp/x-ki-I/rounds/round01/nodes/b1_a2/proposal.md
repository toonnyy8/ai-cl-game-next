# b1_a2 (x-ki-I, round 1, NS side of a cancel)
Parent b1_a1 (sa-p 1.5, carry-p 0, sa-wait 6; 0.9142). Seed0 300, 600 matches each:
- v1 sa-p 1.6, carry 0, wait 7: 0.9076 (mix 156/44, rest 191/9)
- v3 sa-p 1.6, carry 0, wait 5: 0.9076 (identical counts to v1: sa-p past the clamp, waits 5 and 7 play the same)
- v4 sa-p 1.6, carry 1.0, wait 6: 0.9043 (mix 159/41, rest 186/14)
- v2 FINAL sa-p 1.6, carry 0.5, wait 6: 0.9142 (anchor 200/0, mix 161/39, rest 190/10, 0 time-outs); baseline 0.759
Why: sa-p is clamped at 1 so 1.6 only guarantees the SA; a small carry-on chance is neutral-to-slightly-positive (+2 mix wins), more carry loses. Result equals parent within noise: the plateau is flat around wait 6.
