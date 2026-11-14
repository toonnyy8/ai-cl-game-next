# b1_a1: NS side of a cancel, parent b1_a0 plus :xch-carry-p 5.0 :xch-sa-wait 1.5
Keys (in :base): :xch-sa-p 1.5, :xch-carry-p 5.0 (was 3.0), :xch-sa-wait 1.5 (6 frames). Block 300, SP_BUILD 949a94db54fe (baseline 0.5396, parent 0.6518).
- v1 carry 5.0: 0.6683 (anchor 197-1-2, mix 89/100/11, rest 116/74/10)
- v2 carry 3.0 + sa-wait 2.0: 0.665
- v3 sa-p 1.0, carry 3.0: 0.5412 (lower sa-p is clearly worse)
- v4 FINAL carry 5.0 + sa-wait 1.5: 0.6782 (anchor 199-0-1, mix 86/101/13, rest 123/62/15)
Gain over v1 is within noise; sa-p high is the real driver.
