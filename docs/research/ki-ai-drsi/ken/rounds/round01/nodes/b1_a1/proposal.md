# b1_a1 (round 1): the Shikai climb on a disciplined base. b0_a0's sealed discipline and b3_a0's 破月牙 (and b2_a0's quick Bankai exit) merged into b1_a0, plus a reach-gated lunge at 1.0 and an L3 Hoho approach

Direction: 解放攀升, the Shikai climb, with the other three themes kept usable. Parent: b1_a0 (0.6558). Opponent: Ichigo's champion
(= her v0). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every knob is a `defparameter` with a docstring.

## History read (each with its score.rescored.json)
- **Baseline v0, 0.3505.** Strength 10/80. Themes: brawl .568, shikai .768, bankai .312, antiwave .356.
- **b1_a0, 0.6558 (the parent).** Mechanisms: the awakening once per match, the Kikon pointer gate, the turn on her NS in planned
  strings, the Bankai dash, the L3 SA.
  - Strength 55/80. Themes: brawl .561 (the sealed play untouched), shikai .853, bankai .708, antiwave .417 (5/12).
- **b0_a0, 0.6536.** Mechanisms: reach-gated neutral starts, the whiff stop, the Hoho dodge of her lunge and KESSA clones, red-only
  Kikons, the AS read.
  - Strength 53/80. Themes: brawl .706, antiwave .333 (5/15).
  - Its proposal names the next cell: b1's Shikai / Kikon policy combined with b0's sealed discipline.
- **b2_a0, 0.4954.** Mechanisms: the Bankai as a cycle, the L3 / Bankai Hoho approach (b2's largest lever: 0.286 without it, 0.410
  with it).
  - Strength 22/80.
- **b3_a0, 0.4106.** Mechanisms: 破月牙 rebuilt around what lands (the plan by reach, :late 1.0 + :chase, the dash stopping at NS
  reach, the Bankai J1 at JUJISHO). Antiwave .75 (24/32). Strength stayed at 10/80.
- What I concluded:
  - b0's and b3's mechanisms are independent of b1's, and each one fixed a theme b1 had left alone. Nothing in the history failed from
    a bug that needed retrying.
  - The parent's own weak spot is the length of the climb. In its 20-seed logs, climb → L3 takes a median 714 frames (mean 969), and
    every failed Shikai stay is the match's last stay, ended before J4 landed.

## The mechanism
**Merged (credited, not mine):**
- **From b0_a0:**
  - `kk-pick`, the reach discipline: J1 or the NS only where it reaches against her perceived retreat, else walk in, or one Hoho in
    while sealed. Its rolls are made once per approach.
  - `kk-ns-whiff`, the whiff stop.
  - The dodge in `kk-read`, with the KESSA clone dodge.
  - Knobs: `*kk-reach-p*`, `*kk-reach-margin*` 0.5, `*kk-ns-stop-p*`, `*kk-dodge-*`, `*kk-hoho-in-*`, `*kk-clone-reach*`.
  - b1's Kikon pointer gate is kept and now also applies to `kk-pick`'s NS. It replaces b1's `kk-generic-attack` and b0's red-only rule.
- **From b3_a0:**
  - `kk-wave-plan` by reach, `kk-close-hit`, `kk-chase-step`, `*kk-wave-mix*` 0.25 / 0.15 / 1.0, `*kk-wave-close-max*`,
    `*kk-wave-carry*`, `*kk-chase-*`.
  - b3's `*kk-reach-margin*` 0.3 is renamed `*kk-wave-margin*`, so that b0's neutral margin keeps that name.
  - b3's route AS is not ported: b1's `*kk-turn-p*` already turns on every NS of hers, and her Getsuga segments are NS-class.
- **From b2_a0:** `*kk-bk-cashouts*` 1 → 0. The first Bankai string after the chase is the way back (J1–J5 + SP). Added last, as a
  paired test.

**Mine (cell b1_a1, the Shikai climb):**
1. **The climb lunge, reach-gated at 1.0.** `*kk-lunge-p*` HARD 0.5 → 1.0. The lunge is now pressed only where NS1's reach + slide −
   0.5 covers the distance, lengthened by her perceived retreat over delay + startup. That is the same test as `kk-pick`, applied to
   the lunge band 3.0–5.2 m that sits outside the attack zone.
   - In her KESSA hover (3.3–4.2 m) only his lunge reaches. 79 of 129 lunges hit in the final file's 20-seed logs, and each landed
     lunge is +1 L.
   - It is logged as `kk lunge`.
2. **The L3 Hoho approach.** New knobs: `*kk-l3-hoho-p*` 0 / 0.05 / 0.8 and `*kk-l3-zone*` 6.0.
   - At L3 with a plan, `kk-pick` runs from 6 m in, not 3.6 m. Outside J reach he Hohos in once per approach (one roll), so the plan's
     J1 starts from behind her.
   - At L3 he presses only J1 (the plan's string), and only where it reaches.
   - This is b2's L3 approach lever, now inside the reach discipline and limited to the Shikai.

**Tried and dropped (paired, 20 seeds a seat):**
- `*kk-burst-skip-p*`: when the turn's SP would be the burst (L ≥ 1), end the string instead. Score 0.828 against 0.853; strength,
  shikai and bankai were all a little lower. The turn's bursts are rare (8 of 26 lose any L in 40 matches), so it was removed.
- A smaller J1 margin at L3 (`*kk-l3-margin*` 0.2). Score 0.770: no gain in the stable themes, and NORMAL fell to 0.85 (factor 0.92).
  Reverted.

## Measurements (`matchup-eval --side ken`, against the champion, paired seeds)
| Variant | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| parent b1_a0 | 20 | 0.652 | 27/40 | .557 | .872 | .716 | .40 (2/5) | .975 |
| v1 = parent + b0's discipline | 20 | 0.738 | 34/40 | .696 | .810 | .649 | .50 (2/4) | .925 |
| A = v1 + the lunge (mine) | 20 | 0.808 | 38/40 | .696 | .830 | .663 | .67 (4/6) | .90 |
| B = v1 + the L3 Hoho (mine) | 20 | 0.782 | 37/40 | .696 | .798 | .652 | .60 (3/5) | .925 |
| C = v1 + b3's 破月牙 | 20 | 0.808 | 33/40 | .703 | .857 | .624 | 1.0 (1/1) | .90 |
| AC | 20 | 0.841 | 36/40 | .703 | .837 | .667 | 1.0 (5/5) | .875 |
| ABC | 20 | 0.853 | 37/40 | .703 | .873 | .646 | 1.0 (3/3) | .90 |
| ABC + burst skip | 20 | 0.828 | 35/40 | .703 | .866 | .620 | 1.0 (3/3) | .90 |
| ABC + L3 margin 0.2 | 20 | 0.770 | 36/40 | .703 | .833 | .667 | 1.0 (5/5) | .85 |
| AC | 40 | 0.8239 | 70/80 | .695 | .835 | .629 | 1.0 (10/10) | .9125 |
| ABC | 40 | 0.8346 | 71/80 | .695 | .876 | .627 | 1.0 (9/9) | .9375 |
| ABC + cashouts 0 | 20 | 0.863 | 37/40 | .703 | .936 | .651 | 1.0 (3/3) | .90 |
| **ABC + cashouts 0 (final)** | **40** | **0.8349** | **70/80** | **.695** | **.889** | **.649** | **1.0 (9/9)** | **.9375** |

**The final result (score.json): 0.8349.** It ties ABC's 0.8346 on the score; I kept it for the higher shikai and bankai.
- Strength 0.875 (HARD 70/80; parent 55/80).
- Signature 0.8082: brawl .695 (868/1249), shikai .889 (185/208), bankai .649 (131/202), antiwave 1.0 (9/9).
- NORMAL 0.9375 (band 0.863–1.0, factor 1).
- Host tests: 9843 checks, ALL PASS.

**Climb timing (20-seed logs, both seats):**

| | climb → L3 (frames) | L3 → Bankai entry (frames) | final stays without L3 |
|---|---|---|---|
| parent | median 714, mean 969 | median 133, mean 286 | 10 |
| ABC (before cashouts 0) | median 660, mean 813 | median 133, mean 304 | 7 |

## Why it is not a repeat
- It is the combination b0_a0 itself proposed: b1's Shikai / Bankai machine plus b0's sealed discipline, with b3's 破月牙 added.
- Its own Shikai pieces are new: the lunge gated by reach at 1.0, and the reach-disciplined L3 Hoho approach. No earlier cell gated
  the lunge, and b2's approach had no reach check and was not limited to the Shikai.

## Expected benefit and risks
- **Expected:** about 0.83 against her v0. Most of the gain is strength (55 → 71 of 80) and brawl (.56 → .70). Shikai stays at
  about .85–.88.
- **Bankai fell** (.708 → .649), and the cause is that he now wins the match before the Bankai situation closes.
  - ABC's 20-seed logs: of 34 failed L3 situations, 25 ended with Kenpachi winning inside the Bankai, 6 with him winning before
    the entry, and 3 lost.
  - Likewise, 10 of 13 failed Shikai stays were matches he won before J4.
  - I did not shape the last stay to make it "count": that would be keyed to the detector. The one change kept is the game-motivated
    quicker exit (cashouts 0, b2_a0's measured lever): the exit costs 40 Reishi against the cash-out's 160. Each exit still costs him
    a Konpaku (HARD 71 → 70 of 80).
- **Antiwave rests on 9 situations.** The rate is 1.0, but each situation moves the score by about 0.017, and a new opponent may change
  how often it comes up. The independent evidence is this file's 40-seed 9/9 and b3_a0's own 24/32. My 20-seed runs share seeds,
  so their counts overlap and aren't added here.
- **NORMAL moved between 0.85 and 0.94 across the variants** (the band floor is 0.863). The final 40-seed run is 0.9375. Against a
  new opponent, the coordinator may want to lower the NORMAL chances of the merged discipline knobs (`*kk-reach-p*` 0.3,
  `*kk-ns-stop-p*` 0.3, `*kk-dodge-p*` 0.1) if it dips.
- **The climb depends on her style.** The lunge works because her hover sits inside his 5.1 m and outside her own reach. An Ichigo that
  hovers at 5+ m, or punishes the lunge's recovery, would cut it. The L3 Hoho spends the Hoho that 破月牙's :late also wants.
- The style keeps reading her red bar (the Kikon gate), as b0 and b1 did.
