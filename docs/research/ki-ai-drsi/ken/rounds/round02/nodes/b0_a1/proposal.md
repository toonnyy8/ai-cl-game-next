# b0_a1 (round 2, 封印肉搏, parent b0_a0): patience through her Hoho. He starts nothing while he still sees her in a Hoho she has not yet reappeared from

Direction: 封印肉搏, the sealed brawl, with the other three themes kept usable.
- Parent: b0_a0 (0.9213).
- Opponent: Ichigo's champion (her b2_a1).
- Only `duel/lisp/cpu-ki-ken.lisp` changed. Against the parent the diff is one function (`kk-hoho-wait`), two knobs (`*kk-hoho-wait-p*`,
  `*kk-hoho-seen*`) and two state slots.

## History read
- **Round 1, all eight cells, and the baseline.** I read them through b0_a0's and b1_a1's history tables and their score files. Every
  rescore matched its cell's own line.
- **Round 2 siblings.** I read each one's proposal opening and mechanism, plus score.json and score.rescored.json.
  - **b0_a0, 0.9213 (the parent).** The sealed follow-through: `kk-link`, `kk-as-on`, meaty 1.0, dodge 1.0, the Hoho in off.
    - Brawl 0.874, HARD 80/80, shikai 0.851, bankai 0.75.
    - Antiwave 1/1. That is one situation in 80 matches.
  - **b1_a0, 0.8755.** The gated lunge and the lunge pick in the Shikai, with b2_a0's Bankai pieces grafted on.
  - **b2_a0, 0.8698.** The Bankai NS a lunge, then the SA in its gap.
  - **b3_a0, 0.887.** `kk-far`, the edge fix for the Hoho pressed on the step a dash releases, and `:close`.
  - **b1_a1, 0.9211** (landed while I worked). b0_a0's sealed pieces grafted onto b1_a0's file. Its brawl line is identical to b0_a0's
    (541/619), and it also has antiwave 1/1.
  - b3_a1 was still empty when I finished.
- **Lesson from the history:** every real step came from a located bug or a missing follow-through. This cell looks for the next one
  inside the brawl, not for more knob drift.

## Diagnosis (the parent's file, HARD, 20 seeds a seat; scratch parsers over the frozen evaluator's own job logs)
- The parent's 20-seed run reproduced b0_a0's v6 row exactly: brawl 0.861 (267/310).
- Its 43 failed brawl exchanges, classed by the hit that closed them and by his move before it:

| Bucket | Fails |
|---|---|
| KESSA clones | 10 |
| her perfect Hoho, counter 60 (7 soon after her Burst) | 9 |
| her confirm J1 after his J3, which her Burst cut | 4 |
| her confirm after his NS1a, which followed a Hoho | 4 |
| his first move after her KESSA cinematic | 5 |
| the rest (back Step too late, AS absorbed, …) | 11 |

**The located cause: he attacks into her Hoho.**
- She reappears behind him on her frame 6. He sees it *BRAIN-DELAY* (8) frames later.
- Until then the SNAP shows her in a Hoho at her old position. The style and the generic CPU still started J1 / NS1a on that stale
  distance.
- I tallied every move of his started within 30 frames of her Hoho (parent, 20 seeds a seat):

| His move started after her Hoho | landed | she hit him first | whiffed |
|---|---|---|---|
| 5–14 frames | 2 | 13 | 3 |
| 15 frames or later | 72 | 3 | – |

- So the window where he still sees her before she reappears is a reliable loss: 2 landed of 18. A few frames later the same moves
  land 72 of 75.
- This shows up in several buckets above: the post-cinematic J1 (seed 5: her Hoho at 2936, his J1 at 2946), the NS1a whiffs, and part
  of the confirms.

## The mechanism
**`kk-hoho-wait` (`*kk-hoho-wait-p*` 0 / 0 / 1.0, `*kk-hoho-seen*` 6), first in `kk-neutral`.**
- It acts while the perceived SNAP shows her in a Hoho and she has not reappeared in what he sees (her frame < 6). He holds still and
  starts nothing. From her frame 6 on, the parent's play resumes.
- One roll per her Hoho. Her Hoho's start tick is derived from the SNAP (`*match-tick*` − delay − her frame).
- It reads only the perceived SNAP's state and frame. It uses SIM-RND01 only through `brain-roll`, which at 0 / 1 draws nothing.
- NORMAL 0 keeps the shipped CPU's play.
- No form check: it acts in every form. That is the likely source of the shikai / bankai changes below.

Why it is not a repeat:
- No earlier cell touched what he does during her Hoho.
- Round 1's dodges are his own Hohos through her moves. b0_a0's fixes come after his own hits (link, AS, meaty).
- This is a perception-timing bug of the same class as b0_a0's stale-distance Hoho in and b3_a0's dash edge. It is a new location,
  fixed with one guard.

## Tried and dropped (20 seeds a seat, paired on the parent's seeds)
| Variant | brawl | shikai | bankai | HARD | why dropped |
|---|---|---|---|---|---|
| parent (reproduced) | .861 (267/310) | .827 | .763 | 40/40 | |
| repel wait, standing: after her Burst / awakening pushes him 5 m, press nothing until the slide is over + delay | .797 (255/320) | .851 | .794 | 40/40 | It removed the post-Burst perfect Hohos (7 → 0) but left him at the push's 5 m, in her KESSA lunge band: her clone hits 441 → 610, his back Steps 111 → 304, her NS3a → SA lunge hit him 7 times |
| repel wait, walking in | .814 (267/328) | .905 | .786 | 39/40 | Still below the parent. The first exchange after her Burst was already 127 ok / 12 failed in the parent (134 / 15 here): nothing to win |
| **hoho wait (delivered)** | **.908 (275/303)** | .871 | .815 | 40/40 | |
| hoho wait + J1 always first where both reach, sealed (`kk-ns-pick` HARD 0) | .887 (250/282) | .817 | .871 | 40/40 | His NS1a openers drew 8 perfect Hohos in 124 and J1 1 in 755, so J1-first looked right. But her perfect Hohos on his J1 after her Burst rose to 6, and brawl fell |

- The repel code was deleted, not left off.
- The final 40-seed run with that deletion reproduced the 40-seed run that still had the code at HARD 0, line for line. So the code
  was inert.
- Antiwave had 0 situations in all four variant rows. The parent's 20-seed run had 1/1.

## Measurement
**After the change, same seeds (20 a seat, HARD):**
- His moves started 5–14 frames after her Hoho: 2 landed, 3 she hit first.
- 15 frames or later: 88 landed, 4 she hit first, 2 whiffed. Five CANCELs (NA vs NS clashes) were left out of both counts.
- Her perfect-Hoho counters stay (7 in the 20-seed run). Those come after his move started, not during her Hoho.

**The final file at 40 seeds a seat** (score.json, the EVAL_COMMAND's own line):

| | final (b0_a1) | parent b0_a0 |
|---|---|---|
| strength (HARD) | 1.0 (80/80) | 1.0 (80/80) |
| brawl | **0.892 (547/613)** | 0.874 (541/619) |
| shikai | 0.857 (120/140) | 0.851 (126/148) |
| bankai | 0.82 (105/128) | 0.75 (105/140) |
| antiwave | **0 (0/0): no situation** | 1.0 (1/1) |
| NORMAL | 0.9375 (band 0.863–1.0, factor 1) | 0.9375 |
| signature / score | 0.6424 / **0.7855** | 0.8688 / 0.9213 |

**How to read it:**
- **The score falls only because antiwave never came up.** A theme with no situation scores 0. The arithmetic: with antiwave 0
  situations the score is 0.7855; with one won situation and the same other three it would be (0.892 + 0.857 + 0.82 + 1) / 4 × 0.6 + 0.4
  = **0.935**.
- **Antiwave is a lottery on this branch.**
  - Her Getsuga route started once in the parent's 40 HARD matches (20 seeds a seat), 0 times in this file's 40 at 20 seeds, and 0 times
    in its 80 at 40 seeds.
  - The baseline drew 22 starts in its 40. The strong sealed brawl keeps her off pointer 2, and she shoots only from a perceived 7.5 m.
  - I made no change aimed at her pointer 2 or at the 3.6–6.6 m band: that would be keyed to the detector. I also did not search
    variants for a 1/1 draw: that would be selecting on noise.
  - So I ranked variants as b0_a0 did: by brawl, shikai, bankai, HARD and NORMAL.
- **Brawl:** +0.047 at 20 seeds a seat paired (0.861 → 0.908), plus the bucket above (13 → 3). At 40 seeds it is +0.018 (0.874 → 0.892),
  inside the ±0.02 the draw alone moves. The paired 20-seed gap and the located bucket are the stronger evidence.
- **Bankai 0.75 → 0.82** comes from the same 105 successes on fewer L3s (140 → 128), not from more successes. That is a shift in the
  matches' course, not a Bankai mechanism.
- **Shikai** is flat (0.851 → 0.857).

## Expected benefit and risks
- **Expected:**
  - If her Getsuga route comes up in a rescore or against a new opponent, about 0.93.
  - With her current champion at seeds 1–40, 0.7855, the antiwave floor.
  - The brawl gain is small but located. Removing the attack into her Hoho also takes away a free punish from any opponent that Hohos.
- **Risks:**
  - The wait stands still for up to about 6 frames of what he sees of her Hoho (~14 real frames). An opponent that Hohos and then
    attacks at once from behind gets those frames uncontested. Her champion's follow-up after a Hoho is slower: 3 hits on him in that
    window after the change.
  - It acts in every form. In a Bankai, standing costs nothing (no Reishi drain), but its effect on the Bankai's tempo was not isolated.
  - Antiwave as above: the theme is close to never occurring on this branch. That is a structural tension in the score (a dominant brawl
    removes the antiwave situation), not something one style file can fix inside the brief.
- **Left for later:**
  - The KESSA clones (2–10 a run, mostly NS1a started before her NS3a can be seen).
  - Her perfect Hoho on his NS1a / J1 after her Burst. The repel wait fixed these, but it cost more than it won.
  - J3 after NS1 a b c SA J2 in KESSA misses 5 of 25 (her stun ends early). A KESSA-only SP there might fix it.
