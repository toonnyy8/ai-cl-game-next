# b0_a0 (round 2): the sealed brawl's follow-through against her champion. Every knockdown gets the meaty, the NS route goes by reach, the AS runs all its segments, the dodge always answers, and the Hoho in is off

Direction: 封印肉搏, the sealed brawl, with the other three themes kept usable. There is no parent. The start is BASELINE_DIR: b3_a1,
round 1's champion, re-measured at the second freeze at 0.8334. The opponent is Ichigo's champion, b2_a1 of her side (whiff confirm,
pointer 3 home, the 3.4–3.8 m hover under pointer 1). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every changed or new knob is a
`defparameter` whose docstring gives old → new and the evidence.

## History read
- **Round 1, all eight cells.** I read each proposal.md, score.json and score.rescored.json; each rescore reproduced its cell's line.
  - v0 0.3505.
  - b0_a0 0.654: the sealed discipline.
  - b0_a1 0.811: the FS reserve, the back Step and b3's antiwave.
  - b1_a0 0.656: awaken once, the Kikon pointer gate, the turn, the L3 SA.
  - b1_a1 0.835: b1 + b0 + b3, the gated lunge.
  - b2_a0 0.495: the Bankai cycle.
  - b2_a1 0.871: b3_a1 plus the approach, which was neutral there. It also measured the bankai ceiling: the failures are wins inside the
    Bankai.
  - b3_a0 0.411: antiwave rebuilt.
  - b3_a1 0.876: everything combined plus the far-wave answers. It is the baseline.
- **Baseline, re-measured against her champion** (BASELINE_DIR score.json): 0.8334.
  - HARD 74/80, NORMAL 0.9125.
  - Themes: brawl **0.681** (904/1328; 0.812 against her v0), shikai 0.93, bankai 0.812, antiwave 0.667 (2/3).
  - So the champion took 0.13 off the sealed brawl, the theme this branch leans on. No other theme lost that much.
- **Round 2 siblings.** Their directories were empty when I started. Two landed while I worked, and I read both with their rescores:
  - **b2_a0, 0.8698** (79/80, brawl 0.681): the Bankai's way in. The Bankai NS a lunge into her KESSA hover, then the SA in its gap,
    SA J2–J5 + SP home. Bankai stays went from 588 to 383 frames on average.
  - **b3_a0, 0.887** (74/80, brawl 0.679, antiwave 4/4):
    - `kk-far`: a Hoho in, instead of the generic dash, at her pointer 2 from beyond 7 m;
    - a located edge bug: the Hoho pressed on the step a dash releases never came out;
    - `:close` 1.0 over `:late`.
  - Neither touches the sealed brawl (both at the baseline's 0.68), so their mechanisms and mine do not overlap.
  - b1_a0 was still empty when I finished.
  - The merge test is below.
- **What round 1 says about method.**
  - Every big step came from a located bug or a missing follow-through: the plans' AS read, the Kikon pointer rule, the FS budget.
    Knob drift on one mechanism gained little.
  - The shikai / bankai failures are mostly matches he wins before the situation closes (b1_a1, b2_a1). A faster win costs those two
    themes, and the brief forbids shaping play around the detector.

## Diagnosis (my own logs: the baseline file against her champion, HARD, 20 seeds a seat)
I bucketed all 213 failed brawl exchanges by the hit that closed them, and by what he had pressed before it.

| Bucket | Fails | What happens |
|---|---|---|
| J1 into her wake-up | 35 (+7) | His AS1 / AS3c knocks her down. The meaty roll (HARD 0.7) fails, and the generic CPU starts NS1a / J1 at 0.9 m on her invulnerable wake-up. It whiffs, and her whiff confirm J1 lands. |
| SA after a landed NS1a | 14 | The generic CPU takes the segment SA within 2.6 m at 0.8. The sealed SA reaches 1.0 m (no slide), and the NS1a's 1.2 m slide leaves her 1.9–2.2 m off. The SA whiffs, and her confirm J1 lands. |
| KESSA clones | 30 | NS3a / b / c clones strike on f15 / f11 / f11. A single Hoho covers clone A only. |
| her NS3a lunge / NS1a | 27 / 22 | Some of these come from the Hoho in (below), some from her walk-in NS1a with no dodge rolled (HARD 0.8). |
| her perfect Hoho, her SA, the rest | ~85 | |

Two more causes are located in the code:
- **The Hoho in (b0_a0's, HARD 0.8) now loses.** He reappears 1.6 m behind her. The next decision trusts a perceived distance that
  predates her back-off (her hover walks at 4.2 m/s; the SNAP is 8 frames old, plus J1's 6). His J1 then started at a real 2.8–3.0 m,
  into her `punish-j`. The exchanges after a Hoho in went 42 ok / 33 failed (0.56), under the theme's mean.
- **The generic CPU drops his sealed AS halfway.** It rolls `*cai-cont-p*` 0.85 on every AS segment, so AS2a / AS3a / AS3b were left
  there 36 / 53 / 49 times in 20 HARD matches a seat. He is then free ~44 frames later at a perceived 1.85 m with her perceived still
  (v = 0). Her hover has already backed off, and his J1 whiffs at a real 2.8 m into her punish.

## The mechanism (all inside 封印肉搏; every roll once per event, SIM-RND01 only, EASY ≤ NORMAL ≤ HARD)
1. **`*kk-meaty-p*` HARD 0.7 → 1.0.** Every knockdown of hers gets the meaty: walk in, then J1 timed onto her first free frame (K1).
   He never starts a move into her wake-up.
2. **`kk-link` (new, `*kk-link-p*` 0 / 0.3 / 1.0, `*kk-link-margin*` 0).** After his own landed sealed NS segment, in the gap the
   generic CPU reads, one roll per segment:
   - the next NS segment where it reaches (NS1 a b c, F3);
   - else the SA where it reaches (… c SA J2–J5 AS3, L1);
   - else stop (+2 or better on a hit, never a whiff).

   Her NA in his gap (the SA's read) stays the generic CPU's.
3. **`kk-as-on` (new, `*kk-as-on-p*` 0 / 0 / 1.0).** In his own sealed AS, each segment presses the next once it lands. A whiffed
   segment stops there. The roll is the segment's own `brain-r-cont`, made once at its start. NORMAL 0 leaves the shipped CPU's roll.
4. **`*kk-dodge-p*` HARD 0.8 → 1.0.** The existing dodge, a Hoho, else the back Step, now answers every reachable move she starts that
   the brawl read cannot beat (one roll per her move start, as before).
5. **`*kk-hoho-in-p*` 0 / 0.05 / 0.8 → 0 / 0 / 0.** The Hoho in is off. He walks into reach instead.
   - `*kk-hin-fs*` and `*kk-hoho-in-max*` are now inert; the code stays for the search.
   - The FS it used to spend now feeds the dodge.

Tried and dropped:
- **A J-string twin of `kk-link`** (the next J or the AS by reach). Its J whiffs sat at a perceived 0.8 m, mostly her Burst, so the
  distance could not tell them apart: its AS branch fired 3 times in 40 matches. It was removed before v2; v1's score drop
  (0.8647 → 0.8023) is mostly antiwave noise (1/1 → 1/2).
- **`*kk-reach-margin*` 0.5 → 0.65**: brawl 0.746 against 0.754 (no gain). Reverted.
- **`*kk-brawl-p*` HARD 0.6 → 1.0**: +0.018 brawl on one pair, −0.007 on another. That is noise, so the knob stays 0.6.

Rules: she is read only through the SNAP and the perceived distance, plus his own fighter's state (his move, its contact, his presses).
Nothing reads inputs, debug state, seeds or the evaluator. The style registers only for Kenpachi against Ichigo. Host tests: 9843 checks,
ALL PASS.

## Measurements (`matchup-eval --side ken` against her champion; the per-variant runs saved each job's log by importing the frozen evaluator)

20 seeds a seat, paired (the same seeds); each row adds to the one above unless marked.

| Variant | score | HARD | brawl (ok/occ) | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline b3_a1 (reproduced) | 0.8647 | 36/40 | .684 (462/675) | .909 | .771 | 1.0 (1/1) | .925 |
| v1 + `kk-link` (with the J twin, later dropped) | 0.8023 | 38/40 | .702 (441/628) | .835 | .778 | .5 (1/2) | .925 |
| v2 + meaty 1.0 | 0.8916 | 39/40 | .672 (328/488) | .897 | .775 | 1.0 (1/1) | 1.0 |
| v3 + the Hoho in off | 0.7727 | 40/40 | .754 (358/475) | .900 | .831 | 0 (0/0) | 1.0 |
| (v3 + margin 0.65) | 0.7608 | 39/40 | .746 (349/468) | .910 | .816 | 0 (0/0) | .90 |
| (v3 + brawl-p 1.0) | 0.9088 | 40/40 | .747 (337/451) | .874 | .771 | 1.0 (4/4) | 1.0 |
| v4 + brawl-p 1.0 + dodge 1.0 (failed exchanges 114 in the brawl-p row above → 71) | 0.7528 | 39/40 | .829 (344/415) | .843 | .747 | 0 (0/0) | 1.0 |
| v5 + `kk-as-on` | 0.7623 | 40/40 | .879 (270/307) | .819 | .716 | 0 (0/0) | 1.0 |
| **v6 = v5 with brawl-p back to 0.6 (final)** | 0.9177 | 40/40 | .861 (267/310) | .827 | .763 | 1.0 (1/1) | 1.0 |
| (ablation: v6 with `*kk-link-p*` HARD 0) | 0.7659 | 40/40 | .845 (272/322) | .822 | .773 | 0 (0/0) | .975 |
| (v6 + b2_a0's Bankai lunge / SA + b3_a0's `kk-far` / edge fix / mix, merged) | 0.9172 | 40/40 | .861 (267/310) | .850 | .737 | 1.0 (1/1) | .975 |

- From v1 on, the J twin is gone and `kk-link` is NS-only.
- **The score column is dominated by antiwave.** It has 0–4 situations per 20 seeds, and a theme with none scores 0, so it swings the
  score by 0.15. I ranked variants by brawl, the other two themes, HARD and NORMAL instead.
- **The brawl failures fell 213 → 43**, on fewer, mostly won exchanges:
  - J1 into her wake-up 35 → 0;
  - clones 30 → 2–8;
  - the SA after NS1a 14 → 0 (4 come back in the `kk-link` ablation);
  - the Hoho-in whiffs gone.
- **The merge of the two landed siblings was tested and not delivered.**
  - Their pieces are compatible with this file, and the merged file passed the host tests. It measured equal to v6 at 20 seeds a seat:
    the same brawl, shikai +0.023, bankai −0.026, NORMAL 0.975.
  - On this file the pieces are nearly idle. In its 40 HARD matches `kk-far` never fired, the Bankai lunge fired 6 times and the
    Bankai SA 5, and her Getsuga route started twice. The stronger brawl keeps her off pointer 2, and his Bankai stays are short.
  - Round 3 can combine them if a new opponent revives her pointer-2 game. This file keeps to its branch.
- **AS segments left halfway** (v5): AS3a 3 / 352, AS3b 3 / 349 (v4: 51 / 342, 45 / 291).

**The final file at 40 seeds a seat (score.json, the EVAL_COMMAND's own line):** score **0.9213** against the baseline's 0.8334, on the
same seeds.

| | final | baseline |
|---|---|---|
| strength (HARD) | 1.0 (80/80) | 0.925 (74/80) |
| signature | 0.8688 | 0.7724 |
| brawl | **0.874 (541/619)** | 0.681 (904/1328) |
| shikai | 0.851 (126/148) | 0.93 (185/199) |
| bankai | 0.75 (105/140) | 0.812 (156/192) |
| antiwave | 1.0 (1/1) | 0.667 (2/3) |
| NORMAL | 0.9375 (band 0.863–1.0, factor 1) | 0.9125 |

## Why it is not a repeat
- No earlier cell played against her champion's whiff confirm, and none touched the four located causes:
  - the meaty roll that let the generic CPU attack her wake-up;
  - the generic SA after a landed NS from out of the SA's reach;
  - the generic CPU dropping his AS segments;
  - the Hoho in's stale-distance J1.
- `kk-link` and `kk-as-on` are new mechanisms: the brawl's follow-through by reach, after the hit rather than before it.
- Turning the Hoho in off reverses a round-1 piece (b0_a0) on new evidence against the new opponent. It is not a knob tweak of the same
  mechanism.

## Expected benefit and risks
- **Expected:** about 0.90–0.92 against her champion. Strength is at its ceiling (80/80), and brawl is up about 0.19 (0.68 → 0.87).
- **Antiwave is the risk** (disclosed).
  - The stronger brawl keeps her off pointer 2: she starts the Getsuga route (IC-N2A / IC-K-N2A, any distance) 22 times in the
    baseline's 40 HARD matches (20 seeds a seat), 1 in v6's 40, and 4 in the final file's 80.
  - Matches are also shorter: about 132 s → 88 s on average.
  - So the theme opens about once in 40 seeds a seat. One situation is worth 0.15 of score, and a run where it never opens scores the
    theme 0.
  - I made no rule aimed at the 3.6–6.6 m band: that would be keyed to the detector. The far / band answers are b3_a1's, unchanged,
    and the one situation that came up was won.
- **Shikai (0.93 → 0.85) and bankai (0.81 → 0.75) fall** because he wins sooner.
  - Every failed stay or L3 at 20 seeds closed with a match he won (`stay.py`: 13 / 19 of 13 / 19 in v5).
  - This is round 1's known trade (b1_a1, b2_a1). There is no lever for it outside the detector.
- **The meaty at 1.0** leaves her knockdowns to his timed J1. An Ichigo that Bursts or Hohos on wake-up would beat it. Her champion does
  not.
- **The dodge at 1.0** spends a Hoho on every reachable move. The FS the Hoho in used to spend covers it, but an opponent that baits the
  dodge (a feint, then the real hit) would profit.
- **`kk-link`'s distance is the perceived one.** NS at up to 2.0 m and the SA3 at 2.0 m landed in the logs, so the perceived distance
  reads short during her knockback. Margin 0 was not swept.
- **NORMAL 0.9375–1.0** across runs, inside the band. The new NORMAL chances are `*kk-link-p*` 0.3 and `*kk-as-on-p*` 0; the meaty,
  dodge and Hoho-in NORMAL values are unchanged, except the Hoho in's 0.05 → 0.
- **Left for later:** the KESSA NS3 chain (clone B after a Hoho through clone A, about 2–8 a run), and her perfect Hoho against his J1
  (about 9–13).
