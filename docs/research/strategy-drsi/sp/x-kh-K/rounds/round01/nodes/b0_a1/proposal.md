# b0_a1 (x-kh-K round 1, :xch-j)
Final: baseline + `:xch-j 0 :clash-margin 1.6` (id :x-kh-k-r1-b0a1). Sibling b0_a0 already measured xch-j 0 = 0.4835 and 2.5 = 0.2426.
Measured (seed0 300, SP_BUILD 949a94db54fe):
- :xch-j 0.5: 0.4604 (anchor 196-4, mix 15-12 / 173 to, rest 65-3 / 132 to). Monotone between baseline 0.4357 and k=0.
- :xch-j 0 :clash-margin 1.6: 0.4835 (anchor 199-1, mix 25-3 / 172 to, rest 66-1 / 133 to) -- identical to b0_a0.
- :xch-j 0 :clash-margin 0.5: 0.4835, identical counts. Margin is inert at J 0 (the J-side AS reach test never matters; clash-margin also moves clash b2 but counts identical => clash inert here too).
Conclusion: score rises as J share falls; optimum is k=0, no gain beyond b0_a0.
