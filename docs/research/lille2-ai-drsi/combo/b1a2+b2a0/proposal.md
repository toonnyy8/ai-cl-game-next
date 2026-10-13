# Combo b1a2+b2a0 (round 2 follow-up): the line-reader's charged L plus the rifleman's ladder for the never-awakened base form

Built on freeze 2eaf8b9. I started from round 2 b1a2's `barro.lisp` (copied over) and spliced its BARRO-CPU-TESTS section
into the frozen test (`splice-tests.py`). Then I ported b2a0's base-form plan onto it. Only `duel/lisp/barro.lisp` (his CPU
parts) and the `BARRO-CPU-TESTS` section changed. Re-splicing the delivered section into the freeze's test reproduces the
delivered test byte for byte. Host test: 8405 checks, ALL PASS. `tools/pkgcheck.sh duel`: 0 / 0 / 0.

## Result (the delivered file; `score.json` = `python3 tools/aieval.py --char 6 --seeds 40 -j 2` on these bytes)

| | baseline-r02 | b1a2 | b2a0 | **combo (delivered, v2)** |
|---|---|---|---|---|
| score | 0.9102 | 0.9733 | 0.9319 | **0.9663** (raw 0.9663) |
| strength (HARD) | 0.853 | 0.998 | 0.917 | **0.988** |
| masher | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.936 | 0.912 | **0.928** |
| NORMAL share | 0.36 | 0.5125 | 0.4625 | **0.5175** (Y 53, K 27, R 47, I 32, S 48 of 80) |
| pacing medians Y K R I S (40/40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 129.4 137.9 157.1 160.2 154.9 | 117.2 121.5 154.2 154.4 156.1 | **120.5 115.6 153.1 150.6 148.3** |
| awaken A/B rows passing (>= 20 / 60) | 0 / 15 | 0 / 15 | 14 / 15 | **14 / 15** (BK@300 19) |
| mirror A/B (27), never-awaken wins | 4 / 1 / 0 | — | — | **28 / 23 / 32** (all pass) |

A/B rows (Y K R I S, never-awaken P1's wins of 60): 100 **42 22 34 32 32**, 300 **38 19 28 31 34**, 500 **38 23 25 29 37**
(b1a2: 10 0 2 1 4 / 15 1 0 0 1 / 13 0 1 2 1; b2a0: 39 16 33 33 35 / 50 28 30 37 41 / 40 26 31 35 36). Full rows: `ab.txt`.

sig_by (top): br-e-k 0.250, br-e-kl 0.145, br-oe-k 0.086, **br-s-l1- 0.083** (b1a2 0.100), charged 0.075, br-rc 0.073,
br-k-hiren 0.072, **plain-jk 0.064** (b1a2 0.057), br-oe-kl 0.052, **br-s-k 0.043** (b1a2 0.006), **br-s-kl 0.027** (0.004).

## What was combined, piece by piece

From b1a2, everything as it stood: the line (BR-AI-LINE-CALL and the envelope's Step out), the step-fire, the far snipe
from 4.5 m, the 6.5 m back-off, the facing gate, the line's floor (BR-AI-FLOOR-LEVEL / -PLAN-LEVEL), the kept burst
(`:sp-ender`) and the Hoho-reader read. b1a1's NORMAL raises for the awakened forms were reverted (see v2 below).

From b2a0's base-form plan:

1. **Every confirm into the rifle.** Base kit: `:l-after-j` 1.0 -> 0.0, `:string-k` 0.8 -> 1.0, `:l-after-k` 1.0 kept.
   KIN and SHIN keep 1.0 / 1.0. Ported as is.
2. **BR-AI-P with the base form's own tables.** `:charge` 0.2 / 0.5 / 1.0, `:far-snipe :p` 0.2 / 0.5 / 1.0, `:follow`
   0.3 / 0.8 / 1.0, `:sp2` 0.3 / 0.6 / 1.0. Read in BR-AI-CALL, BR-AI-CHARGE-P, BR-AI-STANCE-PUNISH (`:punish` stays a
   plain 0.6) and the far window. Ported as is. Every plain value still reads x `*BR-AI-DIFF*`, so the awakened forms are
   unchanged.
3. **The snipe floor.** *Overlap, not duplicated.* b1a2 already has the line's floor:
   `(br-ai-snipe-floor e d)` = BR-AI-FLOOR-LEVEL (1 inside the level-1 reach, 2 inside 12 m + his body, else 3) through
   BR-AI-PLAN-LEVEL. b2a0's two-argument floor (1 inside the reach, else 2) is the same rule inside 12 m. I kept b1a2's
   version, dropped b2a0's function, and dropped b2a0's floor check (b1a2's BR-AI-FLOOR-LEVEL checks remain).
4. **BR-AI-LADDER** (`*BR-AI-LADDER-P*` 0.3 / 0.6 / 1.0, pure BR-AI-LADDER-INTENT: `:zone` short of the cap, `:pressure`
   at it). Ported as is, called at the top of BR-AI-REFLEX in the base form. It sits on top of b1a2's base intents
   (approach 1, pressure 1, zone 5, defend 1), which apply when the ladder's roll fails.
5. **BR-AI-SIGHT-P** (`*BR-AI-SIGHT-GAP*` 0.6 m, `*BR-AI-SIGHT-F*` 38 f + the delay). *Overlap, merged.* b1a2's facing
   gate (BR-AI-FACING-P, 0.35 rad) still opens every window. The sight then filters the base form's far snipe; when it
   fails, the window waits unspent (`brs-ai-t` -999), as in b2a0. b2a0's own BR-AI-LATERAL (his speed across the
   E -> him line over 4 ring steps) is not ported: the drift comes from b1a2's BR-AI-LINE-OF (his speed across Lille's
   facing line), with `*BR-AI-SIGHT-K*` = 4 steps. With the facing gate at 0.35 rad the two lines differ by under 6 %, so
   only one cross-line helper exists.
6. **The Hoho-triggered charge Step** (`*BR-AI-HOHO-STEP-P*` 0.1 / 0.4 / 1.0, BRS `ai-hoho-key`). *Overlap, resolved
   in the line's favour.* b1a2's line charges (`*BR-AI-LINE-P*` 0.2 / 0.5 / 1.0) already meet a perceived Hoho with the
   charge's Step out: the snipe's envelope clause, and the dash's `:lost` call. So b2a0's clause now applies only to
   charges the line does not read (`brs-ai-line` 0): NORMAL's other half and every level-1 floor tap. Like b1a2's
   step-out, it sets `ai-resume`, so the charge that comes back keeps its rolls and goes through b1a2's step-fire. I moved
   the step-fire clause above the "no line: nothing more" clause so these charges reach it. This changes nothing for
   b1a2's own charges, because `ai-stepped` is only set after a step-out and the line value survives the resume. b2a0's
   press extension over the Step (+11 f) is kept for these charges.
7. **Defence.** Base kit `:neutral-guard` 0.1 and stance `:j-share` 0.3 -> 1.0. Ported as is. Neither existed in b1a2.

Also ported: b2a0's base comment block in the policy header and the `ai-hoho-step` pace counter. b2a0's test checks were
adapted: the base is excluded from b1a2's "every form 0.7 / L 1.0" checks, the snipe floor is checked through b1a2's
BR-AI-FLOOR-LEVEL, and the sight's `*BR-AI-SIGHT-K*` is pinned.

## The steps measured (aieval, 40 seeds)

| step | change | score | str | sig | NORMAL (K of 80) | A/B |
|---|---|---|---|---|---|---|
| v1 | b1a2 + pieces 1-7 | 0.9018 (raw 0.9663) | 0.988 | 0.928 | **0.61** (35): out of band, factor 0.933 | 100: 42 22 34 32 32; 300: 38 19 28 31 34; 500: 38 23 25 29 37; mirror 100: 18 |
| **v2** | **v1 + the awakened forms' NORMAL tables back to the baseline's** (KIN / SHIN `:far-dash :p` 0.1 / 0.35 / 1.0 -> 0.05 / 0.15 / 1.0, `*BR-AI-EXIT-P*` the same; round 2 b1a1 had raised them) | **0.9663** | 0.988 | 0.928 | **0.5175** (27) | the same rows (his side never awakens; 300 re-measured on v2, identical); mirror 28 / 23 / 32 |
| v3 | v2 without the sight (gap 99) — not kept | 0.9632 | 0.978 | 0.931 | 0.535 (22) | |
| v4 | v2 without the ladder — not kept | 0.9677 | 0.993 | 0.927 | 0.5725 (21) | |

- v1 -> v2: b2a0's stronger NORMAL base form plus b1a2's NORMAL line pushed NORMAL above the band. The two NORMAL tables
  that only the awakened forms read go back to the freeze's values. This brings NORMAL back to 0.5175, leaves HARD
  unchanged (raw identical), and leaves the never-awaken A/B unchanged. It also makes the mirror pass: 18 -> 28 at
  seed0 100.
- v3: the sight pays its way with the line too (strength 0.978 without it).
- v4: without the ladder, score is +0.0014 (noise: strength 0.993 vs 0.988 is two matches of 400), but NORMAL rises to
  0.5725, 0.03 under the band's top. I kept the ladder for the NORMAL margin; b2a0 measured it flat on the A/B.

## The gap to b1a2's 0.9733 (-0.007)

- Signature 0.936 -> 0.928. The base form now deals more of his damage through the K route: br-s-k / br-s-kl 0.010 ->
  0.070, which counts as signature. But its K2s bridge is plain (plain-jk +0.007), and the snipe's share is lower because
  the zoning base form walks in at full pips (br-s-l1- 0.100 -> 0.083). This is the price of b2a0's piece 1, which is the
  A/B's main lever (b2a0: "the rifle confirm only" alone moved the A/B from 0-1 to 11-13 of 60). `:l-after-j` / `:string-k`
  are plain kit chances that ai.lisp reads, not difficulty tables, so they cannot be split HARD vs NORMAL without a
  shared-code change.
- Strength 0.998 -> 0.988 (399 -> 395 of 400). This is within the measured spread (v4: 0.993).

## Rules kept

- Every new chance is a table with EASY <= NORMAL <= HARD (host-checked), rolled once per event: per window, intent
  re-pick, charge, or string link.
- Randomness only through SIM-RND01. The sight and the step-fire are rules, not rolls.
- The opponent is seen only through the perceived SNAP and its ring.
- Untouched: AI-AWAKEN-P / `:awaken`, BARRO-TICK / BR-AI-BURST-P, the learner (BR-LEARN-*), the ASSIST hooks, and the
  debug commands.
- New `duel barro` counter: `ai-hoho-step`. New BRS slot: `ai-hoho-key`.

## Risks

- **BK at seed0 300: 19 of 60**, one short of the pass mark (b2a0 had BK@100 16). Kenpachi stays the never-awakened base
  form's hardest matchup (19-23 on the three streams).
- **NORMAL 0.5175** with ±0.05 RNG noise (v1-v4 spread 0.5175-0.5725 with the same NORMAL rules apart from the ladder).
  A later NORMAL strengthening could leave the band. The never-awakened side now wins most A/B rows (25-42 of 60), so at
  NORMAL the awakening is roughly break-even or worse against most opponents (b2a0's open question, now the user's call).
- **Pacing medians for Yamamoto and Kenpachi** are 120.5 / 115.6 s here (aieval), and the A/B's BY / BK are 113.8-124.2 s.
  These are under simgate's 125 s floor, as in b2a0 (the gate already lists Lille II's BY / BK as accepted or open
  exceptions). The seed / pacing gate (`simgate.py --summary` on pairings 21-27) was not run here.
- Score 0.9663 is under b1a2's 0.9733 by the signature cost above. A coordinator who scores only aieval would prefer b1a2;
  this combination trades 0.007 for 14 of 15 A/B rows and 3 of 3 mirror rows passing.
