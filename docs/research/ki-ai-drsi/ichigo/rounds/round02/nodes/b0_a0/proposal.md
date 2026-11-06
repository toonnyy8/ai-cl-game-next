# b0_a0 (round 2, Ichigo): KESSA pointer 3 is the spacing state; lunge from beyond his back Step, Hoho what still reaches her

Direction: 間合い管理 (spacing), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (b2_a1, re-measured
against Kenpachi's champion b3_a1: 0.2877, HARD 6/80). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp`
changed.

## History read
I read round 1's eight proposals, each with its score.json and score.rescored.json (every rescore equals the cell's own line), and the
baseline. When I started and again before writing this, the round-2 sibling folders were empty.

| Cell (round 1, scored against Kenpachi v0) | Mechanism | Rescored | What it means against the new opponent |
|---|---|---|---|
| b0_a0 | pointer-2 re-arm, pointer-1 hover 3.4–3.8 | 0.648 | in the champion |
| b0_a1 | base lunge band 4.7–5.0 (the true start is 0.64 m nearer), lunge in every mode, a new episode on a call gap | 0.665 | not in the champion. Against b3_a1, his back Step (≤ 5.0 m) and his Hoho dodge meet a lunge from that band, so I tried only the band (v11, below) |
| b1_a0 / b1_a1 | whiff confirm, walk-in; hold ground | 0.658 / 0.775 | confirm in the champion |
| b2_a0 / b2_a1 | Konpaku finisher, generic Kikon rule, awaken in every mode; b2_a1 = the champion | 0.715 / 0.783 | the baseline |
| b3_a0 / b3_a1 | KESSA led; the timed KESSA Hoho, its follow-up, the read floor | 0.683 / 0.724 | **not in the champion**. Two of its pieces are grafted here |

None of round 1's failures came from a bug that was left in. Against b3_a1 the champion drops to 0.2877: strength 0.075, spacing 0.062,
kessa 0.10. Round 1's numbers are on another scale.

## Diagnosis (the baseline against b3_a1, 10 seeds a seat, HARD)
Scratch tools: a copy of run-situ.lisp that adds her pointer, both forms and the distance to each Ichigo situation line, and logs every
spacing open. A trial file goes through `tools/combo-trial.py`.

1. **The spacing situations sit in KESSA pointer 3, and they fail there.** In KESSA at pointer 3 the 4–5 m band opens 122 of the 309
   spacing situations, and 7 of them succeed. Base pointer 1 has 69 situations with 1 success; it can't score, because no pointer-1 move
   starts from 4 m.
2. **What happens to her KESSA NS3a** (256 starts):
   - 91 met his back Step (`kk-read` `:sdodge`, rolled 0.9 within `*kk-step-max*` 5.0 m);
   - 71 met his Hoho dodge, which he rolls against any clone NS within 7 m;
   - about a quarter landed.
   - The style's k-lunge band was 3.6–4.3 m, inside the back Step's range. The SA after NS3a also started under 4 m, so even a landed
     lunge was no spacing hit.
3. **Located bug.** In KESSA, `:space` at pointer 3 ran the sealed form's lunge branch with plan `:lunge`. KESSA's NS3a has no hit of
   its own, and `iks-move` presses the SA only for plan `:k-lunge` or on a hit. So `:space` summoned a clone from 4–5 m and did nothing
   else. Also, `:whiff` hovered at his reach, and `:ptr3` left neutral to the generic CPU, which presses KESSA NS3a inside 3.6 m.
4. **Trials (X1–X5.8, against a standing Kenpachi):**
   - KESSA NS3a + SA lands from 4.6, 5.0, 5.4 and 5.6 m and misses at 5.8.
   - The SA always starts on NS3a's f18 from where NS3a started, so it counts as a hit from ≥ 4 m.
   - So a band of 5.05–5.5 m clears his back Step (≤ 5.0) and still lands.
5. **His openers.** 139 of about 600 are his meaty J1 on her wake-up (gap 0, `kk-meaty-step`). His Shikai lunge (KE-S-N1A, reaches
   5.6 m) is next: 100, 52 of them on her idle.
   - **Wake-up Hoho: dead, tested by trial.** In a K1 replay with her Hoho or Step presses buffered across the wake-up, nothing ever
     came out. His J1 lands on her first free frame, before her neutral step runs, so there is no window. Not built.

## The change (the final file)
1. **`*iks-kessa-lunge-band*` 3.6–4.3 → 5.05–5.5 m,** tested on the projected distance.
   - New `iks-proj`: the perceived distance plus its change since the last call times her perception delay. The change is clamped to
     `*iks-lead-vmax*` 0.07 m a step. Only perceived distances are used.
   - New `*iks-k-sa-reach*`: the SA is pressed under 5.7 m (was 4.6).
2. **`*iks-kessa-space-modes*`.** At HARD, every style mode (:space :kessa :whiff :ptr3) waits in that band in KESSA pointer 3 and
   lunges as he walks in. From beyond the band she walks in; she no longer hands off to the generic dash.
   - This fixes the `:space` bug in item 3 above.
   - NORMAL and EASY keep only `:kessa` there (it now uses the new band, the walk-in and the 5.7 m SA reach).
3. **b3_a1's KESSA Hoho, grafted:** `iks-kessa-hoho`, `iks-hoho-follow`, `*iks-kessa-hoho-p*` / `-lead*` / `*iks-hoho-follow*` /
   `*iks-hoho-j-reach*`.
   - His perceived attack is Hoho'd 1–6 f before its first active frame, so it falls in the perfect window. Then J1 from behind him.
   - It answers what still reaches the band (his Shikai lunge).
   - NORMAL 0.1 → 0 here.
4. **b3_a1's read floor, `*iks-kessa-read-min*`** (HARD 2; NORMAL / EASY 1): in KESSA a steered string never reads into AS1, so it
   never writes pointer 1.

Rules kept:
- Every chance is EASY ≤ NORMAL ≤ HARD and rolled once per event: the KESSA Hoho per his move start, the rest as before.
- Randomness only through `brain-roll` / `sim-rnd01`.
- He is read through the SNAP and the perceived distance.
- Every tunable is a `defparameter` with a docstring.

Host tests: 9843 checks, ALL PASS.

## Measurements
Paired seeds. The 20-seed rows are the full EVAL_COMMAND with `--seeds 20`. The 40-seed rows are HARD only (`--no-normal`, raw =
0.4 strength + 0.6 signature). The "41–80" column is a scratch scorer: it imports `matchup-eval.py`'s run and parse and adds only the
seed offset (debug 30000+k). I used it to check variants against seeds the comparisons had not used.

| Variant | 20 seeds: score / HARD | spacing | whiff | ptr3 | kessa | 40 seeds HARD raw (1–40) | 41–80 raw |
|---|---|---|---|---|---|---|---|
| baseline (b2_a1) | 0.2979 / 4 of 40 | 0.054 | 0.540 | 1.0 | 0.125 | 0.2877 (6/80) | 0.3101 (11/80) |
| v1: band 5.05–5.5 + SA reach + :space bug fixed (:space :kessa) | 0.3273 / 6 | 0.079 | 0.603 | 1.0 | 0.100 | | |
| v2: v1 + KESSA Hoho | 0.3437 / 7 | 0.083 | 0.610 | 0.957 | 0.175 | | |
| v3: v2, all four modes lunge | 0.3917 / 9 | 0.143 | 0.643 | 1.0 | 0.225 | 0.3552 (13/80) | 0.2909 (7/80) |
| v4: v2 + hover past his Shikai lunge (5.7–6.1) | 0.3641 / 8 | 0.082 | 0.597 | 0.964 | 0.250 | | |
| v5: v3 + that hover | 0.3220 / 5 | 0.124 | 0.631 | 0.958 | 0.100 | 0.3206 (10/80) | |
| v6: v3 + lunge only while his flash-step < 100 (a HUD read) | | | | | | 0.2704 (3/80) | |
| **v7: v3 + read floor (final)** | | | | | | **0.4151 (19/80)** | 0.3203 (7/80) |
| v8: v7 + wait in the band up to 600 f | | | | | | 0.3203 (7/80) | |
| v9: v7, band 5.15–5.55 | | | | | | 0.3602 (11/80) | |
| v10: v7 + the timed Hoho in the sealed form too | | | | | | 0.3441 (10/80) | 0.3609 (15/80) |
| v11: v7 + b0_a1's base lunge band 4.7–5.0 | | | | | | 0.3775 (14/80) | 0.3298 (8/80) |
| v7 without the KESSA Hoho (HARD 0.9 → 0) | | | | | | 0.3132 (9/80; whiff 0.586) | 0.3560 (14/80; whiff 0.584) |

**Averaged over 80 seeds a seat (1–80):**

| Variant | Raw |
|---|---|
| baseline | 0.299 |
| v3 | 0.323 |
| **v7** | **0.368** |
| v10 | 0.353 |
| v7 without the Hoho | 0.335 |
| v11 | 0.354 |

v7 is the best, though v10 and v11 are within noise of it. Strength at these win rates moves ±4–6 wins in 80 between seed sets, and
kessa has 80 situations. The signature gain holds on both seed sets:

| Seeds | Spacing | Whiff | Ptr3 |
|---|---|---|---|
| 1–40 | 0.062 → 0.171 | 0.556 → 0.677 | 1.0 → 0.986 |
| 41–80 | 0.073 → 0.134 | 0.579 → 0.630 | 0.911 → 1.0 |

Strength is not shown to improve. On seeds 41–80, v7 won 7 of 80 against the baseline's 11.

What the logs say about the lunge (v3, 10 seeds a seat):
- Of 195 style k-lunges, about 70 hit him (his perceived d 4.3–5.5).
- 73 met his Hoho dodge and about 35 his back Step. The Step mostly comes when he walks in fast, so the projection falls short of the
  true distance.
- KESSA pointer-3 spacing in the 4–5 m band rose from 7/122 (baseline) to 49/190.

**NORMAL.** With every round-2 piece active at NORMAL too, the full 40-seed run read 11 of 80 (0.1375), at the band's top (0.138). So
the modes and the read floor are HARD-only, and the KESSA Hoho is 0 at NORMAL. The HARD play is identical (same HARD numbers), and
NORMAL reads 9 of 80 (0.1125).

**Final, 40 seeds a seat (EVAL_COMMAND, score.json).** The same line was printed before and after a docstring-only fix (the lunge
band's back-Step note):
`{"side": "ichigo", "seeds": 40, "strength": 0.2375, "signature": 0.5336, "themes": {"spacing": {"rate": 0.171, "ok": 257, "occ": 1500}, "whiff": {"rate": 0.677, "ok": 619, "occ": 914}, "ptr3": {"rate": 0.986, "ok": 69, "occ": 70}, "kessa": {"rate": 0.3, "ok": 24, "occ": 80}}, "hard": "19/80", "normal": {"share": 0.1125, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.4151, "score": 0.4151}`

| Part | Baseline (40 seeds) | Final |
|---|---|---|
| Score | 0.2877 | **0.4151** |
| HARD | 6/80 | 19/80 |
| Spacing | 0.062 | **0.171** |
| Whiff | 0.556 | 0.677 |
| Ptr3 | 1.0 (31) | 0.986 (70) |
| Kessa | 0.100 | 0.300 |
| NORMAL | 0.100 | 0.1125 (band 0–0.138, factor 1) |

## Negative results (keep them)
- **Hovering past his Shikai lunge (5.7–6.1 m) and lunging as he walks in loses** once every mode lunges (v5, −0.035 at 40 seeds).
  Waiting inside his lunge range with the Hoho armed does better.
- **Gating the lunge on his flash-step (no Hoho open) is much worse** (v6, 3/80). She waits instead of lunging, and the generic CPU
  takes over. It would also have read his flash-step gauge, so it is dropped on both counts.
- **A longer wait in the band (600 f) is worse** (v8). So are a band 0.1 m farther out (v9), the timed Hoho in the sealed form (v10)
  and b0_a1's base band (v11), though v10 and v11 are within the noise.
- **The wake-up Hoho / Step against his meaty is impossible:** gap 0, no free frame before the hit (trial W1 / W5).

## Not a repeat
- No earlier cell moved KESSA's lunge beyond his back Step's range. Round 1's opponent had no back Step, so the 5.05–5.5 band and its
  projection are new.
- No earlier cell found that KESSA's NS3a + SA counts as a ≥ 4 m hit from up to 5.6 m (trials X1–X5.8).
- No earlier cell found the located `:space`-in-KESSA bug.
- The two b3_a1 pieces are grafts, which the brief allows. The champion never had them, and each was A/B'd here:
  - **The read floor** (v3 → v7) gains on both seed sets: +0.06 on 1–40, +0.03 on 41–80.
  - **The KESSA Hoho**: its 20-seed step (v1 → v2, +0.016) is inside the noise. The 80-seed ablation is mixed. Without it, seeds 1–40
    fall 0.4151 → 0.3132, but seeds 41–80 rise 0.3203 → 0.3560; the mean is 0.368 with it, 0.335 without. Only its whiff contribution
    is consistent: 0.677 / 0.630 with it, 0.586 / 0.584 without. So its effect on the score is not separated from noise; it stays for
    the mean and the whiff.

## Risks
- **Noise.** At 6–19 wins in 80, strength is ±0.05 between seed sets. The final's 19/80 on seeds 1–40 is the high end: v7 had 7/80 on
  seeds 41–80, and the baseline 11/80 there. The signature gain holds on both seed sets; the strength gain is not established.
- **The band leans on `*kk-step-max*` 5.0 and his dodge rolls.** If his next champion widens the back Step or always Hohos the clone,
  the k-lunge loses its edge. 73 of 195 already meet his Hoho.
- **The Hoho piece** is a defensive tool shared by every fighter, not one listed in §4's spacing / KESSA rows (b3_a1's review risk,
  carried over). It is the shipped CPU's Hoho, retimed, in KESSA only, and 0 at NORMAL.
- **`iks-move`'s SA test reads `fighter-dist`,** her own fighter's true distance, as v0's line already did (at 4.6 m). Only the
  threshold changed here.
- **Carried from the baseline:** the Konpaku-pip read (`iks-kikon-value`) and his form for the band tables.
