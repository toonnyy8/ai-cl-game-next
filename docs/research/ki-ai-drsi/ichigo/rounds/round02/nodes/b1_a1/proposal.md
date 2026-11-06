# b1_a1 (round 2, Ichigo): the patient sealed form + b3_a0's Hoho kit; pointer 2 waits for his whiff against his released forms; the meaty J1 on his wake-up

Direction: 揮空反擊 (whiff), keeping the other three usable. Parent: round 2's b1_a0 (0.584, HARD 58/80, whiff 0.807, kessa 0.139).
Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
Round 1: every cell's score.rescored.json, the history tables of the baseline's and the parent's proposals, and a grep of all eight
proposal.md files for wake-up / meaty / Getsuga (no cell timed a press onto his wake-up; pointer 2's Getsuga from 7.5 m is round-1
b0_a0's, measured against Kenpachi v0). Round 2: b0_a0's history and diagnosis sections, b1_a0 and b3_a0 whole, with their rescores. b3_a1 delivered while I worked (rescored 0.7865).
It builds on b3_a0 alone: the flash-step reserve off in KESSA, and a punish of his lock after her perfect Hoho. None of b1_a0's pieces
are in it and none of its pieces are in this file. b0_a1 and b2_a0 were still empty.

| Cell | Mechanism | Rescored | Used here |
|---|---|---|---|
| r2 b0_a0 | KESSA far k-lunge 5.05–5.5, all modes; b3_a1's timed Hoho | 0.4151 | far band for `:space` only (via b3_a0) |
| r2 b1_a0 (parent) | patient sealed form, NS whiff stop, timed Hoho both forms, untimed Hoho off, breaker, no Hoho after her Burst | 0.584 | whole |
| r2 b3_a0 | wake-up Hoho, his slide in the Hoho's reach, follow-up 64 f and after any perfect Hoho, read floor, far k-lunge `:space` | 0.7151 | all of it |
| r2 b3_a1 | KESSA Hoho without the Burst reserve, lock punish | 0.7865 | not combined (delivered late); the obvious next graft |

The two parents touch different code. b1_a0 named the combination as its refine. They disagree on one switch: the untimed generic Hoho
(b1_a0: off is +0.015; b3_a0: off is a loss twice). It is ablated below. No failure in either parent comes from a bug left in.

## Diagnosis (scratch runner over matchup-eval's own run / parse, HARD logs, 20 seeds a seat)
- After the merge, whiff was already 0.90–0.92, and the failures were spread thin: pointer 2 8 / 24, wake-up Hohos 10, and a few
  bursts. The whiff theme alone had no big leak left. The leaks were in what opened his combos on her.
- **Pointer 2's Getsuga against his released forms** (on c4, by the combo's first hit after ≥ 90 quiet ticks):
  - it opened 44 of his combos, 14.2k, in both forms;
  - nearly all were KE-S-N1A, his Shikai lunge (reach 2.6 + slide 3.0), landing on her charge;
  - his 破月牙 Hohos in and hits the charge from 7–12 m, so `*iks-getsuga-min*` 7.5 is no protection.
- **His wake-up after her AS3** (on c8):
  - the largest opener left in the sealed form: KE-S-N1A right after her IC-AS3C, 26 combos on seeds 21–40 and 12 on 1–20;
  - her AS3 knocks him down with her +46 at 1.8 m;
  - the patient form then walks back to its 3.7–4.2 m hover, inside his lunge's reach, and his first move on waking lands.
- His own meaty J1 shows what she can do instead: a J1 whose first active frame meets the opponent's first free frame can't be
  escaped (b0_a0 and b3_a0 confirmed this for her side).

## The change (the final file = c12)
From b3_a0, merged into the parent's functions (no duplicated knobs):
- his slide in the timed Hoho's reach (`*iks-hoho-slide*`);
- the follow-up window 40 → 64 f, after any perfect Hoho of hers (`*iks-follow-any-perfect*`, HARD), and the follow-up tagged `:kessa`
  so its string is steered;
- the wake-up Hoho (`iks-wake`, HARD 0.9);
- the KESSA read floor (`*iks-kessa-read-min*` HARD 2);
- the far k-lunge for `:space` in KESSA pointer 3 (`iks-proj`, `*iks-kessa-space-modes*`, `*iks-k-sa-reach*` 5.7, the 3.6–4.3 band kept
  for `:kessa` as `*iks-kessa-near-band*`).

Switches resolved by ablation:
- `*iks-untimed-hoho*` NIL → T.
- `*iks-break-awaken*` T → NIL: the awakening is neutral again.
- `*iks-break-p*` HARD 1.0 → 0: neutral on this file; the generic CPU's Burst roll is back.

New:
1. **`*iks-p2-wait*`** (HARD), with `*iks-getsuga-his-forms*` (:base). At pointer 2, against any form of his but the sealed one, out
   of her J reach:
   - no Getsuga, no back dash;
   - she hovers at his form's whiff distance (`*iks-hover*`, 4.9–5.3 m against the Shikai);
   - the whiff confirm (J, or NS2a + its SA) and the timed Hoho do the rest.
   The 揮空反擊 style taken to pointer 2.
2. **The meaty J1** (`iks-meaty`, `*iks-meaty-p*` 0 / 0 / 0.9, forms both, `*iks-meaty-near*` 1.4, `*iks-meaty-far*` 3.0, lead 0).
   - One roll per knockdown of his, made as his perceived state turns `:air` / `:down`, within 3 m.
   - She stays in (stick toward him to 1.4 m, else still) and presses J1 when his perceived frames to his first free one equal her J1's
     startup. This mirrors his KK-MEATY-STEP, with `*reaction-frames*` and her perception delay.
   - The string is steered to AS3 (pointer 3 kept), which knocks him down again.
   - On c9's seeds 1–20 she pressed 472 meaty J1s and 408 landed; of the 64 that did not, about 14 met his read (a Hoho or a back
     Step on her J1 start).
   - `*iks-meaty-space-skip*` T: a KESSA pointer-3 episode of a `*iks-kessa-space-modes*` mode skips it and plays its far k-lunge (before
     the meaty, KESSA pointer 3 held 31 of the 35 spacing successes; the meaty everywhere took spacing 0.066 -> 0.017).

Rules:
- Every chance is EASY ≤ NORMAL ≤ HARD and rolled once per event: per his knockdown, per wake-up, per his move start.
- `*iks-p2-wait*` is not a chance.
- He is read only through the SNAP (state, frame, move), the perceived distance and his visible form; her own state and gauges as
  before.
- Randomness only through `brain-roll` / `sim-rnd01`. Every tunable is a `defparameter` with a docstring.
- The file registers only Ichigo against Kenpachi.
- Host tests: 9843 checks, ALL PASS.

## Measurements
Scratch runner = matchup-eval's `run` / `parse` / formula with the logs kept. Seeds 1–20 a seat: the full formula with NORMAL, except
where marked HARD-only. Seeds 21–40 a seat: HARD only, run with debug 30000+20 by a copy of `run` that only adds the offset. Each row adds
to the row named.

| Variant | 1–20: score / HARD | spacing | whiff | ptr3 | kessa | NORMAL | 21–40 HARD raw / HARD / kessa |
|---|---|---|---|---|---|---|---|
| parent b1_a0 (re-run) | 0.5737 / 29 | 0.049 | 0.809 | 0.945 | 0.088 | 0.075 | |
| c1 = parent + b3_a0's pieces | 0.7273 / 37 | 0.041 | 0.916 | 1.0 | 0.425 | 0.075 | |
| c2 = c1 + untimed Hoho T | 0.7354 / 38 | 0.057 | 0.912 | 1.0 | 0.400 | 0.075 | |
| c3 = c2 + neutral awakening | 0.7637 / 40 | 0.081 | 0.904 | 0.990 | 0.450 | 0.075 | 0.7825 / 39 / 0.625 |
| c4 = c3 − breaker | 0.7596 / 38 | 0.063 | 0.903 | 1.0 | 0.564 | 0.075 | 0.7937 / 39 / 0.718 |
| c5 = c3, breaker sealed form only | 0.7475 / 39 | 0.067 | 0.901 | 0.990 | 0.425 | 0.075 | 0.7635 / 38 / 0.575 |
| c6 = c4 + sealed `:space` lunge (HARD-only) | 0.7485 / 37 | 0.102 | 0.857 | 0.989 | 0.575 | | rejected |
| c7 = c4 + KESSA chains 2.8–3.4 (HARD-only) | 0.7556 / 38 | 0.065 | 0.900 | 1.0 | 0.538 | | rejected |
| **c8 = c4 + `*iks-p2-wait*`** | 0.7891 / 39 | 0.066 | **0.954** | 1.0 | 0.641 | 0.075 | 0.8121 / 39 / 0.821 |
| **c9 = c8 + meaty J1** | **0.8387 / 40** | 0.017 | 0.958 | 1.0 | **0.950** | 0.075 | **0.8252 / 40 / 0.846** |
| c10 = c9 + hover 4.0–4.6 (HARD-only) | 0.8335 / 40 | 0.056 | 0.959 | 1.0 | 0.875 | | level, rejected |
| c11 = c9 + breaker (HARD-only) | 0.8366 / 40 | 0.021 | 0.949 | 0.991 | 0.950 | | level, kept off |
| **c12 = c9 + meaty skip for KESSA `:space`** (final) | **0.8407 / 40** | 0.052 | 0.961 | 1.0 | 0.925 | 0.075 | 0.8257 / 40 / 0.821 (spacing 0.064) |

Seed-1–40 means of the HARD raw:

| Variant | HARD raw |
|---|---|
| c3 | 0.773 |
| c4 | 0.777 |
| c5 | 0.755 |
| c8 | 0.801 |
| c9 | 0.832 |
| **c12** | **0.833** (spacing back to 0.058) |

c8 and c9 each gained in both halves; c12 is level with c9 and gives spacing back. The switch rows (c2–c5, c10, c11) are within the ±0.02–0.03 noise.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 1.0, "signature": 0.7222, "themes": {"spacing": {"rate": 0.058, "ok": 30, "occ": 518}, "whiff": {"rate": 0.957, "ok": 786, "occ": 821}, "ptr3": {"rate": 1.0, "ok": 223, "occ": 223}, "kessa": {"rate": 0.873, "ok": 69, "occ": 79}}, "hard": "80/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8333, "score": 0.8333}`
(c9's 40-seed line, for comparison: score 0.8321, spacing 0.027, whiff 0.955, kessa 0.899.)

| Part (40 seeds) | Baseline | Parent b1_a0 | r2 b3_a0 | **b1_a1** |
|---|---|---|---|---|
| Score | 0.2877 | 0.584 | 0.7151 | **0.8333** |
| HARD | 6/80 | 58/80 | 65/80 | **80/80** |
| Spacing | 0.062 | 0.057 | 0.155 | 0.058 |
| Whiff | 0.556 | 0.807 | 0.711 | **0.957** |
| Ptr3 | 1.0 (31) | 0.957 (115) | 0.986 (139) | 1.0 (223) |
| Kessa | 0.100 | 0.139 | 0.750 | **0.873** |
| NORMAL | 0.100 | 0.075 | 0.100 | 0.075 (band 0–0.138, factor 1) |

## Not a repeat
- The merge is the combination b1_a0 named; no sibling made it. b3_a1 refined b3_a0 alone.
- `*iks-p2-wait*` takes back, against his released forms only, round-1 b0_a0's pointer-2 Getsuga game, which beat Kenpachi v0 and loses
  to this one's 破月牙.
- `*iks-p2-wait*` and the meaty J1 are new. Each rests on a located opener of his combos, not on a sweep. No Ichigo cell timed a press
  onto his wake-up.
- Rejected again on this file: the sealed `:space` lunge (b0_a1 / b3_a0; spacing up, whiff and strength down) and the KESSA chains
  (v0's, removed by b1_a0).

## Expected benefit, risks
- **Benefit:** 0.584 → 0.833 at 40 seeds, HARD 80/80, whiff 0.957, kessa 0.873.
- **Spacing is still the weakest theme (0.058, the baseline's level).** The meaty loop and the patient hover keep it there:
  - the 4–5 m band opens mostly while she hovers at 3.7–4.2 or between her loops;
  - her Hoho counters from there are no move start, so they don't count;
  - moving the hover out to 4.0–4.6 (c10) only traded spacing for kessa.
  A spacing cell could try the far k-lunge in the sealed form's released-Kenpachi matchup, or the NS3a meaty from 4–5 m after a
  pushing ender.
- **The meaty relies on an engine fact:** a J1 on the first free frame after the wake-up can't be beaten. Against it his style has his
  read (`kk-read` DODGE / SDODGE on her J1 start: about 14 of 472 here; 64 did not land). A Kenpachi given a wake-up Hoho (b3_a0's trick, which wins
  through the perfect Hoho's 40 f lock) would cut the loop. Kenpachi's next round may well find it.
- **Pointer 2's wait depends on his read of her stillness.** If he learns to Hoho in on a waiting pointer 2, the timed Hoho and the
  confirm are her only answers there.
- **Shared tools, as in both parents:** the timed and wake-up Hohos and the meaty J1 are the shipped CPU's presses retimed, not rows of
  §4's table, and all are HARD-only. NORMAL still reads 0.075. `*iks-k-sa-reach*` 5.7 acts at NORMAL in a `:kessa` k-lunge, as in
  b3_a0.
- **Next graft:** b3_a1's KESSA Hoho without the Burst reserve, and its lock punish. They touch `iks-timed-hoho` / the follow-up, and
  none of this file's new code.
