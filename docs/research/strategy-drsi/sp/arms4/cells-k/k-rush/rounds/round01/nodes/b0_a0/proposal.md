# b0_a0 (k-rush, approach)

Keys changed vs baseline: `:kk-reach-margin` 0.35 -> 0.05 (start J1/NS from farther), `:kk-hoho-in-max` 6.0 -> 3.5 (Hoho in only when close; saves flash-step gauge).

| run | arm | score | KI anchor/mix/rest (W-L-T of 200) | KH anchor/mix/rest |
|---|---|---|---|---|
| baseline | margin .35, hoho-in-max 6.0 | 0.6452 | 109-77-14 / 63-130-7 / 21-179-0 | ~0.967 |
| 1 | margin .05, hoho-in-max 7.0 | 0.646 (KI .3234, KH .9686) | 104-83-13 / 65-128-7 / 24-176-0 | 199-1-0 / 194-2-4 / 191-1-8 |
| 2 (final) | margin .05, hoho-in-max 3.5 | 0.6543 (KI .3367, KH .9719) | 107-80-13 / 68-125-7 / 26-174-0 | 200-0-0 / 195-1-4 / 191-1-8 |

Gain is small (+0.009, within noise for 200 matches/group). Approach keys barely move play. Descriptor check not run (runs take ~15 min each on a busy machine); nstart_r unverified.
