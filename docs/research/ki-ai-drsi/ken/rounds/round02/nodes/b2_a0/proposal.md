# b2_a0 (round 2): the Bankai's way in. Lunge into her KESSA hover with the Bankai NS a, then SA J2–J5 + SP home

Direction: 卍解爆發 (bankai), keeping the other three themes usable. Parent: none, so this cell starts from BASELINE_DIR, the round-1
champion b3_a1 (re-measured 0.8334 against Ichigo's champion). Opponent: Ichigo's champion (her b2_a1). Only `duel/lisp/cpu-ki-ken.lisp`
changed.

The worktree was checked out at 3d98bfa, not the freeze 2605e96. `git diff --stat 2605e96 3d98bfa` touches only
`docs/research/ki-ai-drsi/` files, so the evaluator and the game code are the freeze's.

## History read (proposal.md, score.json, score.rescored.json each)

| Cell (round 1, first freeze) | Rescored | Mechanism | What it says for the Bankai |
|---|---|---|---|
| v0 | 0.3505 | the four styles | the CPU entered the Bankai and could not leave it well |
| b0_a0 | 0.654 | sealed discipline, dodge Hoho, red-only Kikon, AS read | Bankai through `kk-pick`: J1 within reach, else Hoho in or walk |
| b0_a1 | 0.811 | + FS reserve, back Step dodge, b3_a0's antiwave | — |
| b1_a0 | 0.656 | awaken once, Kikon pointer gate, the turn, Bankai dash, L3 SA | the Bankai stall (nobody attacked 3.1–3.6 m) is a located bug |
| b1_a1 | 0.835 | b1 + b0 + b3, reach-gated lunge, L3 Hoho | 25 of 34 bankai failures were wins inside the Bankai |
| b2_a0 | 0.495 | the Bankai cycle (cash-outs 0), L3 / Bankai Hoho approach | cash-outs 0 adds about 0.1 to bankai |
| b2_a1 | 0.871 | b3_a1 + the Hoho approach (neutral there) | the bankai ceiling: the K.O. comes from the way back's own hit; holding its Kikon changes nothing |
| b3_a0 | 0.411 | antiwave rebuilt | — |
| b3_a1 = baseline | 0.876, **0.8334** at the second freeze | everything combined | bankai 0.812 at the new freeze (a K.O. by the special AS now counts) |

- Since the second freeze, a K.O. by the special AS counts. So b2_a1's ceiling (wins inside the Bankai by the way back) no longer
  applies.
- The baseline's numbers against the new opponent: HARD 74/80, brawl 0.681, shikai 0.93, bankai 0.812, antiwave 2/3.
- Round 2 siblings: every sibling directory was still empty when I finished.

## Diagnosis (baseline logs, HARD, 20 seeds a seat, both seats; scratch parsers over the evaluator's own jobs)

The 22 failed bankai situations (of 96) fall into three classes (13 + 6 + 3):
- **13: she was K.O.'d inside the Bankai before the special AS started.**
  - 9 came on the clean meaty J1–J4 string (KI 1, 3, 7, 10, 11, 12; IK 7, 8, 14). This is the ceiling: her bar was lower than the hits
    before the SP.
  - 4 came from a KYORAN NS at the end of a long stay (KI 13; IK 11, 15, 18). They are kills too. I list them apart because the stay
    before them is the stall described below.
- **6: L3 was still open when he won in the Shikai,** before or on the entry. The L3 SA J2–J7, or the BANKAI AS itself, broke her
  (KI 2, 6, 18; IK 6, 12, 17). This is also a ceiling.
- **3: HARD losses that ended inside a Bankai** (KI 4, KI 9, IK 4). The 4th HARD loss, IK 5, came after it left a 2815-frame stay.
- **The stall behind the losses and the 4 late NS kills:**
  - Closed stays averaged 588 frames. A clean stay is 236: entry, meaty J1, J1–J5 + SP. 14 of 59 ran over 600 frames, and the longest
    ran 5510.
  - What he did in those stays:
    - In the Bankai, J1 starts only within 2.1 m (reach 1.8 + slide 0.8 − margin 0.5).
    - The Bankai NS was a 0.25 roll per neutral decision, behind a Reishi floor.
    - She hovers at 2–4.8 m and starts KESSA NS3a from there. Each start fired the style's read: 149 back Steps and 71 Hoho dodges in
      the Bankai over 40 matches.
    - Neither dodge was followed by an attack. A J1 into her NS3a was CANCELLED, and the clone's strike on the same frame flinched him.
  - What it cost him: her clones hit him 416 times inside Bankai stays.
  - **KI 9:** her Konpaku sat at 1 for 97 s while his Reishi drained to 13, and she won.
  - **IK 17:** 92 s inside one Bankai.

## Mechanism (cpu-ki-ken.lisp only; every knob a `defparameter` with a docstring)

1. **The Bankai NS a lunge as the way in** (`*kk-bk-lunge-p*` 0 / 0 / 0.9, `*kk-bk-lunge-max*` 3.3 m).
   - One roll per approach in `kk-pick`. In a Bankai the approach zone now starts at the NS a's reach (KYORAN 4.3 m).
   - It fires where J1 does not reach but the NS a does, against her perceived retreat, as for every `kk-pick` start. She must be
     perceived free (idle / run), and the perceived distance must be at most 3.3 m.
   - Where J1 reaches, J1 still goes first, straight into J1–J5 + SP.
2. **The SA in a landed Bankai NS segment** (`*kk-bk-sa-p*` 0 / 0 / 1.0, new `kk-bk-sa`).
   - One roll per segment, made once the segment's contact is a hit. The perceived distance is 8 frames stale after the lunge, so there
     is no distance test.
   - The SA counts as press 1, so `kk-move`'s Bankai target (J5) runs **SA J2–J5 + SP: the special AS, back in the Shikai**. Without it,
     the generic CPU ran NS b–d at 40 Reishi a segment, with no way out.
3. **Removed:** `kk-decide`'s Bankai branch (`*kk-bk-ns-p*`, `*kk-bk-ns-spare*`, `*kk-bk-ns-range*`).
   - That branch rolled per neutral decision, and its NS a–d route ended in the KYORAN / ZANKAI AS, a cash-out rather than the way back.
   - The Bankai NS is now rolled once per approach (no double roll).

**The route verified first** (`tools/combo-trial.py`, scratch trial file, P2 = Ichigo):

| Trial | Dealt | Hits | Ends |
|---|---|---|---|
| X1: KYORAN NS a from 4 m, SA J2–J5 CHIGIRI | 274 | KE-KR-NA 80, SA 40, J2 40, J3 45, J4 45, J5 65, SP 300 | back in the Shikai, −1 Konpaku |
| X2: the same from 2 m | 274 | | back in the Shikai |
| X3: ZANKAI NS a from 2 m, SA J2–J5 TATE-GOTO | 321 | | back in the Shikai, pointer 2 |

ZANKAI's NS a misses from 3.5 m; its reach comes from the move itself.

**Rules:**
- One roll per event: the approach, and the landed segment.
- SIM-RND01 only.
- She is read only through the SNAP (perceived state and distance) and her perceived retreat.
- EASY ≤ NORMAL ≤ HARD (NORMAL 0 on both new knobs).
- The style still registers only Kenpachi against Ichigo.
- Host tests: 9843 checks, ALL PASS.

## Measurements (matchup-eval --side ken; seeds paired)

| Variant | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| baseline (b3_a1) | 20 | 0.8647 | 36/40 | .684 (462/675) | .909 | .771 (74/96) | 1/1 | .925 |
| v1: lunge (no distance cap) + Bankai SA, `*kk-bk-ns-p*` folded in | 20 | 0.9144 | 40/40 | .684 | .933 | .812 (82/101) | 1/1 | .925 |
| v2: + `*kk-bk-lunge-max*` 3.3 (final) | 20 | 0.9102 | 40/40 | .684 | .933 | .784 (80/102) | 2/2 | .925 |
| baseline, rescored | 40 | 0.8334 | 74/80 | .681 (904/1328) | .930 | .812 (156/192) | .667 (2/3) | .9125 |
| **final (score.json)** | **40** | **0.8698** | **79/80** | .681 (904/1328) | .924 (194/210) | .811 (163/201) | .75 (3/4) | .9125 |

**Inside the Bankai (20 seeds a seat, HARD, both seats):**

| | baseline | v1 | v2 |
|---|---|---|---|
| closed stays | 59 | 64 | 64 |
| mean frames | 588 | 389 | 383 |
| stays over 600 | 14 | 9 | 7 |
| longest | 5510 | 2107 | 1573 |
| HARD losses | 4 (3 ended inside a Bankai, the 4th after a 2815-frame stay) | 0 | 0 |
| special AS started (the way back) | 72 | 80 | 78 |
| her clone hits on him in the Bankai | 416 | 64 | 81 |
| back Steps / Hoho dodges in the Bankai | 149 / 71 | 29 / 16 | 18 / 15 |

- **Lunges by perceived distance (v1, no cap).** From under 3.25 m, 24 of 29 hit. From 3.25–3.75 m, 5 of 11. From 3.75 m on, 0 of 3.
- **After the cap (v2):** 29 hits, 8 whiffs, 1 absorbed, 1 cancelled.
- **v1 against v2** (0.812 / 0.784 bankai at 20 seeds). Every failure in both runs is a kill in a match he won:
  - v1: 19 = 13 inside the Bankai before the special AS + 6 at L3 in the Shikai;
  - v2: 22 = 14 + 8.

  v2 keeps fewer whiffs (14 → 8), each of which cost him 40 Reishi and a punish, so v2 is the delivered file.
- **The 40-seed final against the rescored baseline, same seeds:** +0.036.
  - Strength went from 74/80 to 79/80. Bankai had more situations and more successes (156 → 163), at the same rate.
  - Brawl is byte-identical: the sealed play is untouched, and brawl situations come before the first Bankai.
  - NORMAL is unchanged at 0.9125 (band 0.863–1.0, factor 1).
  - Antiwave opened 4 times (3 ok): one situation is ±0.03 of score.

## What is left for 卍解爆發 (v1 logs, 20 seeds a seat: every one of the 19 failures is a match he won)

- **The kill before the special AS (13).** Her last bar broke on the meaty J1–J5, on the NS a / SA, or on J5 one hit before the SP.
- **L3 open in the Shikai (6).** She broke on the L3 SA J2–J7, or on the BANKAI AS itself.

Both are b2_a1's ceiling, minus what the second freeze now credits. The only levers left would avoid or delay the kill, or avoid L3 late in a match. Those are keyed to the detector, so I did not make them.

## Why it is not a repeat

- **No earlier cell gave the Bankai a way in against her hover.**
  - b0_a0's Bankai `kk-pick` started J1 only within reach and otherwise walked or Hohoed.
  - b1_a0's dash fixed a 3.1–3.6 m stall against her v0.
  - b2_a0's / b2_a1's Hoho approach puts him behind her (neutral on b3_a1).
- **No cell turned a Bankai NS into the way back.**
  - The removed `*kk-bk-ns-p*` NS route ran into the AS cash-out.
  - The SA in its gap (SA J2–J5 + SP) is new. It is verified by trial and counted in the logs: 25–26 SA a run, special AS starts 72 → 78–80.
- **The diagnosis is new:** against her KESSA champion, all four losses (three inside a Bankai, one just after a 2815-frame stay) and
  the stuck stays come from the Bankai's reactive dodge loop.
  Round 1's Ichigo v0 did not hover there.

## Expected benefit and risks

- **Expected:** about 0.86–0.88 against her champion. Strength sits at its ceiling (79/80), and the bankai rate holds at about 0.81
  while the cycle count rises.
- **Risks:**
  - **An Ichigo who punishes the lunge.** For example, she backs out of 3.3 m when he is in a Bankai, or answers his NS a with her SA in
    her own NS gap, which cancels it. Then the 8 whiffs a run grow, and each costs 40 Reishi.
  - **Bankai Reishi.** The lunge's NS a costs 40 on top of the exit's 40. A whiffed lunge then a walk-in is still far cheaper than the
    stuck stays it replaces: in KI 9 his Reishi ran down to 13.
  - **The bankai rate rests on kill timing.** Expect ±0.03 between runs: the 20-seed v1 / v2 rows differ by two kills.
  - **Antiwave rests on 3–4 situations in 40 seeds a seat.** A coordinator rescore may move the score ±0.03 on it alone.
