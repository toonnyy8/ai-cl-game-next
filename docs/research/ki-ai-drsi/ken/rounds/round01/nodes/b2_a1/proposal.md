# b2_a1 (round 1): the Bankai cash-out, carried onto the round's best file; what held b2_a0 back (red pointer-1 / 3 Kikons, b1_a0's finding) and the bankai theme's measured ceiling

Direction: 卍解爆發, the Bankai cash-out, with the other three themes kept usable. Parent: b2_a0 (rescored 0.4954). Opponent: Ichigo's
champion (= her v0). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every knob is a `defparameter` with a docstring.

**What is delivered.** I started from b2_a0. I deliver **b3_a1's file plus b2_a0's L3 / Bankai Hoho approach**, kept under b0_a1's
flash-step reserve, with a fix for a per-step re-roll. The reason: on paired seeds, the b2 line peaked at 0.700 after five grafts, and
the combined sibling files measured 0.83–0.89 on the same build. The rest of this cell is measurement. Two findings for the dream phase
follow:
- the leak that held b2_a0 back;
- why the bankai theme cannot pass about 0.6 on a file that wins 79 of 80.

## History read (proposal.md, score.json, score.rescored.json each)

| Cell | Rescored | Mechanism | What it shows |
|---|---|---|---|
| baseline v0 | 0.3505 (10/80) | the four styles | the plans pressed J into her NS |
| b0_a0 | 0.6536 (53/80) | sealed discipline: the reach gate, the whiff stop, the dodge Hoho, red-only Kikons, the AS read | brawl 0.706 |
| b1_a0 | 0.6558 (55/80) | awaken once, the Kikon pointer gate, the turn, the Bankai dash, the L3 SA | shikai 0.853, bankai 0.708 |
| b2_a0 (parent) | 0.4954 (22/80) | the Bankai cycle: cash-outs 0, the L3 / Bankai Hoho approach, the AS read, the J1 race, Kikons held on red | bankai 0.747, strength 22/80 |
| b3_a0 | 0.4106 (10/80) | antiwave rebuilt | antiwave 0.75 (24/32) |
| b0_a1 (landed while I worked) | 0.8108 (68/80) | b0_a0 + the FS reserve + the back Step + b3's antiwave | brawl 0.793 |
| b1_a1 (landed while I worked) | 0.8349 (70/80) | b1 + b0 + b3 + cash-outs 0, the reach-gated lunge, an L3 Hoho | bankai 0.649: 25 of 34 failures were wins inside the Bankai |
| b3_a1 (landed while I worked) | 0.8763 (79/80) | everything combined + far-wave answers + b0_a1's budget | bankai 0.615, its weakest |

## 1. What held the parent back: Kikons held on red that take 1 Konpaku

The cost itself is b1_a0's finding (its diagnosis: 27 of 33 landed Kikons at −1, the source of its pointer policy). What is
new here is that this cost is what held b2_a0 to 22 of 80, and that b0_a1 still pays it.


- b2_a0's `kk-move` held its string SPs into the Kikon on a red Ichigo (`*kk-kikon-red-p*` 0.95).
- With the red-only rule added (v1, 10 HARD matches a seat), **38 of its 43 landed Kikons took −1 Konpaku**
  (`P1 KIKON on P2: -1 konpaku`), and the other 5 took −3.
  - A red pointer-1 / 3 Kikon takes 1 and refills her Reishi. It throws away the Soul Break (3–5) that the next hits would make.
  - b1_a0's rule avoids this: keep the hold only at pointer 2, sealed or in the Shikai.
- **b0_a1 has the same leak.** Its rule taps only non-red holds. In 20 HARD matches a seat it landed 115 Kikons at −1 and 16 Bankai
  Kikons at −3. b3_a1 fixed it with b1's `*kk-kikon-ptr-p*`.

## 2. The b2 line, paired 20 seeds a seat (each row adds to the one above)

| Variant | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| parent b2_a0 (reproduced its 0.4774 exactly) | 0.4774 | 10/40 | .557 | .779 | .735 | .444 (8/18) | .975 |
| v1 + awaken once (b1) + b0's red-only rule on every SP (the style runs the generic step) | 0.4557 | 8/40 | .624 | .774 | .806 | .30 | .95 |
| (v1 with cash-outs 1) | 0.4543 | 10/40 | .624 | .777 | .761 | .20 | .95 |
| (v1 with the L3 Hoho approach off) | 0.4013 | 6/40 | .624 | .702 | .615 | .333 | .95 |
| **v4 + b1's pointer rule on every SP** | **0.678** | **28/40** | .658 | .838 | .657 | .50 | 1.0 |
| v5 + b1's L3 SA | 0.7022 | 27/40 | .658 | .880 | .676 | .667 | 1.0 |
| v6 + the Hoho-approach miss fix | 0.6647 | 27/40 | .658 | .852 | .676 | .444 | 1.0 |
| v7 + b0's dodge (lunge + KESSA clones) | 0.7004 | 32/40 | .703 | .860 | .687 | .286 | .95 |
| references: b1_a0 / b0_a1 / b3_a1 on this build | 0.652 / 0.833 / 0.889 | 27 / 34 / 39 | | | | | |

- The pointer rule alone took the line from 8/40 to 28/40.
- v6 changes only the antiwave count. Its six other numbers are identical to v5's, so it is noise.
- **The Hoho-approach miss fix.** b2_a0's own proposal disclosed a rule breach:
  - when a Hoho press did not come out, the decision timer stayed at 1, so `kk-approach` rolled again on the next free step;
  - now a press is remembered (`kks-hq`), and being free again within `*kk-hoho-miss*` 8 steps means it did not come out;
  - that decision does not roll again and falls through to the walk.

## 3. Grafts onto the combined files, paired 20 seeds a seat

| Base → variant | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| b0_a1 (reproduced 0.8333) | 0.8333 | 34/40 | .795 | .893 | .743 | .857 (6/7) | .95 |
| + b1's pointer rule + awaken once | 0.6841 (raw .746, factor .917) | 38/40 | .812 | .761 | .469 | .40 | .85 |
| + the pointer rule, the awakening reduced to the generic 0.02 a decision (b0's own 0.1 roll off) | 0.6456 | 37/40 | .739 | .60 (3/5) | 0 (0/5) | .889 | .85 |
| + awaken once alone | 0.7849 | 30/40 | .804 | .844 | .71 | .875 | .95 |
| + b1's L3 SA | 0.8265 | 36/40 | .795 | .902 | .746 | .667 | .95 |
| + cash-outs 0 (b2) | **0.8484** | 35/40 | .795 | .927 | .767 (112/146) | .833 | .95 |
| + the L3 / Bankai Hoho approach (FS reserve, miss fix) | 0.8299 | 38/40 | .795 | .934 | .770 | .50 (2/4) | .95 |
| b3_a1 (reproduced) | 0.8892 | 39/40 | .812 | .891 | .625 (55/88) | 1.0 (4/4) | .925 |
| **+ the approach (delivered)** | **0.896** | **40/40** | .812 | .901 | .593 (54/91) | 1.0 (2/2) | .925 |
| + the approach, pointer rule off (ablation) | 0.7233 | 29/40 | .806 | .932 | .750 | .40 | .95 |
| + the approach, the Bankai exit held into its Kikon on red (tried, dropped) | 0.8969 | 40/40 | .812 | .912 | .589 | 1.0 | .925 |

**The pointer rule's trade.** It makes him win faster, and the themes need match time.
- On b0_a1, with awaken-once added too (the clean row), the Shikai stays fell 121 -> 67 and the L3 situations 113 -> 64 while the
  wins rose 34 -> 38 of 40: shikai .893 -> .761, bankai .743 -> .469. NORMAL fell to 0.85, out of the band. (The row with the
  awakening nearly off, 5 Shikai stays and no Bankai, mostly shows the late awakening, not the kills.)
- With b3_a1's other pieces it is still strongly positive: without it, 29 of 40 against 40 of 40.
- So the pieces interact. Each must be judged on its target base, not carried over by its old row.

## 4. The bankai theme's ceiling (why this cell does not push it further)

- **The split.** b3_a1 plus the approach, 20 HARD matches a seat, wins 40 of 40, 37 failed L3 situations:
  - **27 are wins inside the Bankai.** `situ-flush` fails every L3 still open when the match ends.
  - **10 are L3 rises still open as he won in the Shikai,** before the entry.
  - **No failure comes from a loss.**
  - b1_a1 counted the same: 25 of 34.
- **The KO comes from the way back's own hit.** CHIGIRI / TATE-GOTO deal 300–320, and their delayed hit 183–247.
  - I tried holding that SP into its Kikon on red: E7 / E26, −3 to her, and he still returns to the Shikai.
  - It was pressed 27 times in 40 matches. In 18 of them the SP's own hit broke her bar first (`SOUL BREAK on P2 … 0 left (BANKAI)`),
    and every one of those 18 ended the match. Only 1 became a Kikon (both counts within 8 log lines of the press).
  - The score did not move (0.8969 against 0.896). It was removed.
- **The only remaining lever would be keyed to the detector.** Avoiding the kill inside the Bankai, or not reaching L3 late in the match,
  is exactly that, and the brief forbids it. So no such rule was made.
- **A note for the evaluator's next freeze.** A KO dealt by the Bankai's own way back (the special AS) arguably carries out the theme
  the user approved: 「back by the special AS」.
- **Where the bankai lever did work: open plans and slow entries.**
  - On the b2 line, the L3 SA cut the plans open at the match end from 12 to 6 (20 matches a seat, both seats).
  - The median L3 → entry fell to 159 frames: the L3 reached inside an NS combo goes SA J2–J7 + SP.
  - Cash-outs 0 gave +0.02 bankai and +0.025 shikai on b0_a1: more cycles complete before the match ends.
  - On b3_a1 (which already has both), the approach found little to change: 29 approach Hohos in 40 matches, and bankai did not move.

## 5. The mechanism delivered (b3_a1 + mine)

- **`kk-approach`** (`*kk-l3-hoho-p*` 0 / 0 / 0.9, `*kk-l3-hoho-band*` 3–7 m, `*kk-hoho-miss*` 8). When it applies:
  - at L3 with the Bankai plan, or in a Bankai;
  - outside the attack zone, at 3–7 m;
  - with a Hoho open and at least `*kk-hin-fs*` 200 flash-step (b0_a1's reserve, so the dodge keeps its Hoho).

  What it does:
  - one roll per neutral decision: Hoho in;
  - the next free step decides (J1 in reach);
  - a press that did not come out is not rolled again.

  It is b2_a0's lever, its largest there (0.286 without it, 0.410 with it), now inside the budget and the rules.
- **Rules.** One roll per event. SIM-RND01 only. EASY ≤ NORMAL ≤ HARD (NORMAL 0). She is read only through the SNAP and the distance.
  The style registers only Kenpachi against Ichigo.
- **Host tests:** 9843 checks, ALL PASS.

## 6. Measurement of the delivered file, 40 seeds a seat (score.json)

**score 0.8712.** strength 0.9875 (HARD 79/80), signature 0.7937. NORMAL 0.9125 (band 0.863–1.0, factor 1).

| Theme | This file | b3_a1, rescored |
|---|---|---|
| brawl | 0.812 (1094/1347) | 0.812 (1094/1347) |
| shikai | 0.901 (164/182) | 0.907 (165/182) |
| bankai | 0.605 (107/177) | 0.615 (107/174) |
| antiwave | 0.857 (6/7) | 0.875 (7/8) |

- **Against b3_a1's 0.8763 on the same seeds: −0.005.** One antiwave situation and three more L3 rises account for it.
- The graft is neutral on that base, and I report it as such.
- Against the parent b2_a0: +0.376.

## Why it is not a repeat
- **New:** b1_a0's −1 Konpaku Kikon cost shown as the cause of b2_a0's weak strength (the pointer rule alone: 8 -> 28 of 40 on the b2
  line), and still present in b0_a1 (115 at −1, 16 Bankai Kikons at −3, counted).
- **New:** the interaction finding, with exactly what was toggled: on b0_a1, adding the pointer rule and awaken-once together is −0.15
  (0.833 -> 0.684); on b3_a1 (+ the approach), removing the pointer rule alone, awaken-once kept in both arms, is −0.17 (0.896 ->
  0.723). A row measured on one base does not carry over.
- **New:** the bankai ceiling, measured.
  - The KO comes from the way back's own hit.
  - The held Kikon cannot pre-empt it.
  - That closes the "hold the exit" idea for later cells.
- **New:** b2's approach, under the flash-step reserve and with the per-step re-roll fixed. On b3_a1 it is neutral, and I state that
  rather than claiming a gain.

## Expected benefit and risks
- **Expected:** about b3_a1's level (0.87–0.88) against her v0. Against a stronger Ichigo round 2 may decide it: matches that last
  longer leave the Bankai cycle more room, and the approach starts it sooner.
- **Risks:**
  - **The approach spends a Hoho at L3.** The reserve keeps one for the dodge and 破月牙's :late. With 7–8 antiwave situations in 40
    seeds, any effect there is invisible.
  - **Strength is at 79 / 80.** Every theme failure left is a match the CPU won before the situation closed. Further search on this
    opponent has little room. The signature's remaining gaps (brawl 0.19, bankai 0.40) are mostly the match ending.
  - **NORMAL 0.9125.** It is inside the band but under the generic 0.9625. The NORMAL chances are b0 / b1 / b3's; mine are 0.
