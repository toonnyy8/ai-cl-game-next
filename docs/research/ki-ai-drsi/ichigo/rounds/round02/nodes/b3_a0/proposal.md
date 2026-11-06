# b3_a0 (round 2, Ichigo): the perfect Hoho as KESSA's shield, from her wake-up on, and the follow-up that waits for his reeling

Direction: KESSA 強攻 (kessa), keeping the other three usable. Parent: none, so this starts from BASELINE_DIR (b2_a1, re-measured
against Kenpachi's champion b3_a1: 0.2877, HARD 6/80, kessa 8/80). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read round 1's eight proposals with their score.json / score.rescored.json (each rescore equals its cell's own line), the baseline,
and the one round-2 sibling that has delivered: **b0_a0** (spacing, rescored 0.4151). b1_a0 and b2_a0 were still empty when I wrote this.

| Cell | Mechanism | Rescored | Against the round-2 opponent |
|---|---|---|---|
| r1 b0_a0 / b0_a1 | pointer-2 re-arm, hover 3.4–3.8; lunge band 4.7–5.0 | 0.648 / 0.665 | re-arm in the baseline; b0_a1's band tested here (v13), no gain |
| r1 b1_a0 / b1_a1 | whiff confirm; hold ground | 0.658 / 0.775 | confirm in the baseline |
| r1 b2_a0 / b2_a1 | Konpaku finisher, generic Kikon; b2_a1 = the baseline | 0.715 / 0.783 | 0.2877 now |
| r1 b3_a0 / b3_a1 | KESSA-led: AS3 steer, red AS2; **the timed KESSA Hoho + J1 follow-up, the read floor** | 0.683 / 0.724 | not in the baseline: grafted here (v1) |
| r2 b0_a0 | b3_a1's Hoho + read floor (the same graft as my v1), KESSA far k-lunge 5.05–5.5 in all modes, `iks-proj`, SA reach 5.7 | 0.4151 (19/80) | its far band grafted here for `:space` only (v15) |

No round-1 failure was a bug left in. The baseline's collapse (78/80 against Kenpachi v0, 6/80 against b3_a1) is the opponent: his
reach-gated brawl, his Hoho / back Step through her lunge, and above all his **meaty J1 on her wake-up**.

## Diagnosis (scratch runner over matchup-eval's own run/parse, HARD logs, 20 seeds a seat)
Baseline + b3_a1's graft (v1), damage on her by the combo's opener:
1. **The meaty J1 loop**: 393 of his combos (89k of the 335k she took), 175 of them in KESSA (39k). He presses J1 so its first active frame
   meets her first free frame after the wake-up (`kk-meaty-step`, lead 0), then J1–J5 AS3 (about 230 a time), again and again.
2. **His Shikai lunge TOSSHIN (KE-S-N1A)** in KESSA: 202 combos, 48k of the 139k she took there. Reach 2.6 + **slide 3.0**: he lunges from
   3.6–5.6 m. b3_a1's Hoho test (`snap-near-p`, the reach + 1 m) never sees it coming from beyond 3.6 m: a **located bug** in the graft.
3. With the slide in, 117 of the lunges still found her with no Hoho: 88 Hoho-locked or under 100 flash-step, 29 under the Burst reserve.
4. **The follow-up never came**: in KESSA 132 of her timed Hohos were perfect (the counter strike lands at about +32 f, 36 f of hitstun),
   but only 21 J1 follow-ups started. The 8 f delayed SNAP shows his reeling at about +40, which is where `*iks-hoho-follow*` (40) closed:
   a **located bug** (a window shorter than the threat plus the perception delay).

## The change (the final file)
New in this cell:
1. **The wake-up Hoho** (`iks-wake`, `*iks-wake-hoho-p*` 0 / 0 / 0.9, `*iks-wake-hoho-near*` 2.2 m, both forms). On her first free frame
   after a wake-up with him within 2.2 m, Hoho at once (one roll per wake-up). The SNAP is 8 f late, so this is a guess from distance and
   her own state alone.
   - **What really happens** (v15, 40 HARD matches): the Hoho comes out and is flagged PERFECT on that frame. In 145 cases his J1 still
     hits her on that same frame (the Hoho's iframes start at f1). But the perfect Hoho locks his inputs for 40 f, so his string stops at
     that J1: in those 145 cases one more hit of his followed within 60 f, and 131 times he made no move at all.
   - So the gain is J1 (35) instead of J1–J5 AS3 (about 230). The meaty loop's damage fell 89k → 43k.
   - **This disagrees with b0_a0 (round 2), which reports the wake-up Hoho "dead, tested by trial"** (a K1 replay with presses buffered
     across the wake-up). In the evaluator's matches the style's press on her first idle frame does come out (log: `ki-style … wake-hoho`,
     `P1 hoho`, `P1 PERFECT HOHO` on one tick). Their trial drives the inputs another way, and they looked for the Hoho beating the J1,
     which it mostly doesn't; the lock is what pays.
2. **His slide in the Hoho's reach** (`*iks-hoho-slide*` T): `d < reach + slide + 1.0` as well as `snap-near-p`. His TOSSHIN and KYORAN's
   lunge are now Hoho'd from where they start.
3. **The timed Hoho in the sealed form too** (`*iks-hoho-forms*` (:kessa :base); b3_a1: KESSA only). Ablation on the final file, 40 seeds
   a seat: KESSA only 0.6981 (63/80, whiff 0.669) against 0.7151 (65/80, whiff 0.711).
4. **The follow-up's window 40 → 64 f** (`*iks-hoho-follow*`), from item 4 of the diagnosis. In KESSA the follow-ups went from 21 to 194,
   with 69k dealt and 0.8k taken (20 seeds a seat).
5. **The follow-up after any perfect Hoho of hers** (`*iks-follow-any-perfect*`, HARD only): read from her own fighter's PERFECT flag while
   she is in the Hoho, so the generic CPU's untimed Hoho and the wake-up Hoho get it too.

Grafted (credited):
- **Round 1's b3_a1:** `iks-kessa-hoho` (the lead window 1–6 f), `iks-hoho-follow`, `*iks-hoho-j-reach*`, `*iks-kessa-read-min*`. Made
  HARD-only here: `*iks-kessa-hoho-p*` NORMAL 0.1 → 0, and the read floor (:easy 1 :normal 1 :hard 2). With b3_a1's NORMAL values, the
  40-seed NORMAL share read 13 of 80 (band top 11, factor 0.83).
- **Round 2's b0_a0:** `*iks-kessa-lunge-band*` 5.05–5.5 m, `iks-proj` + `*iks-lead-vmax*`, `*iks-k-sa-reach*` 5.7, and its located
  `:space`-in-KESSA bug fixed. Here only `:space` takes the far band, at HARD only (`*iks-kessa-space-modes*` nil / nil / (:space)).
  `:kessa` keeps v0's 3.6–4.3 band (`*iks-kessa-near-band*`). b0_a0's all four modes lost the ledger on my file (v14 below).

Rules: every chance EASY ≤ NORMAL ≤ HARD, rolled once per event (the wake Hoho per wake-up, the timed Hoho per his move start).
Randomness only through `brain-roll` / `sim-rnd01`. He is read only through the SNAP and the perceived distance. Her own state, gauges and
PERFECT flag are read too. Every tunable is a `defparameter` with a docstring. The file registers only Ichigo against Kenpachi.
Host tests: 9843 checks, ALL PASS.

## Measurements
The 20-seed rows are paired on seeds 1–20 a seat. They come from a scratch runner (`ev2.py`) that imports `tools/matchup-eval.py`'s own
`run` and `parse`, runs the four jobs once, saves the HARD logs and applies the same formula. It reproduced the evaluator's HARD line
exactly: v2 / v3 at 40 seeds, and the final file below. Score = the full formula with the NORMAL factor.

| Variant (each row adds to the kept one above it) | 20 seeds: score | HARD | spacing | whiff | ptr3 | kessa |
|---|---|---|---|---|---|---|
| baseline (b2_a1) | 0.2979 | 4/40 | 0.054 | 0.540 | 1.0 | 0.125 |
| v1: + b3_a1's Hoho, follow-up, read floor | 0.4223 | 12/40 | 0.061 | 0.655 | 1.0 | 0.300 |
| v2: + the wake-up Hoho | 0.5264 | 20/40 | 0.102 | 0.599 | 1.0 | 0.475 |
| v4: + the slide (v3 = NORMAL-only fixes, HARD identical) | 0.5814 | 24/40 | 0.107 | 0.670 | 1.0 | 0.500 |
| v8: + the timed Hoho in the sealed form | 0.6481 | 29/40 | 0.086 | 0.648 | 0.953 | 0.700 |
| v11: + the follow-up window 64 | 0.6870 | 31/40 | 0.088 | 0.690 | 0.985 | 0.750 |
| v12: + the follow-up after any perfect Hoho | 0.7246 | 33/40 | 0.087 | 0.708 | 0.985 | 0.850 |
| **v15: + b0_a0's far k-lunge, `:space` only (final)** | **0.7271** | 33/40 | **0.160** | 0.702 | 0.986 | 0.800 |

40-seed checkpoints (seeds 1–40 a seat): v3 0.4888 (35/80, kessa 0.425), v8 0.5954 (50/80, 0.60), v11 0.6668 (59/80, 0.688),
v12 0.6793 (60/80, 0.738), **v15 0.7151 (65/80, 0.75)**.

Rejected (20 seeds, against the kept row they were added to):
- **v5a, the generic CPU's untimed Hoho skipped when the timed roll said yes** (to save flash-step), on v4: 0.5777 against 0.5814. On v8,
  as v9: 0.5933 against 0.6481. The untimed Hoho saves her in cases the timed window misses.
- **v5d, the awakening instead of the Hoho at a wake-up with the gauge full** (the cinematic is invulnerable): 0.5565. It came up only
  7 times.
- **v6, the wake-up Hoho spare-checked** (`ai-hoho-spare-p`): 0.5248 (18/40).
- **v7, the follow-up after the wake-up Hoho**: 0.5692 against 0.5814, but at the old 40 f window. v12's any-perfect follow-up now
  covers that case at 64 f. Read v7 as "not at 40 f", not as "no follow-up after the wake Hoho".
- **v10, the pointer-1 walk-in NS1a off** (79 sealed walk-ins: his hit first 45 times, hers 13): 0.5838 against 0.6481.
- **v13, b0_a1's base lunge band 4.7–5.0**: 0.6961 against 0.7246; spacing did not move.
- **v14, b0_a0's far band in all four modes**: 0.5632 (20/40, kessa 0.575, spacing 0.181) against 0.7246.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json; its HARD part equals ev2's v15 line):**
`{"side": "ichigo", "seeds": 40, "strength": 0.8125, "signature": 0.6502, "themes": {"spacing": {"rate": 0.155, "ok": 192, "occ": 1242}, "whiff": {"rate": 0.711, "ok": 656, "occ": 923}, "ptr3": {"rate": 0.986, "ok": 137, "occ": 139}, "kessa": {"rate": 0.75, "ok": 60, "occ": 80}}, "hard": "65/80", "normal": {"share": 0.1, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.7151, "score": 0.7151}`

| Part (40 seeds) | Baseline | r2 b0_a0 | **This cell** |
|---|---|---|---|
| Score | 0.2877 | 0.4151 | **0.7151** |
| HARD | 6/80 | 19/80 | **65/80** |
| Spacing | 0.062 | 0.171 | 0.155 |
| Whiff | 0.556 | 0.677 | **0.711** |
| Ptr3 | 1.0 (31) | 0.986 (70) | 0.986 (139) |
| Kessa | 0.100 | 0.300 | **0.750** |
| NORMAL | 0.100 | 0.1125 | 0.100 (band 0–0.138, factor 1) |

What moved in KESSA (20 seeds a seat):
- Damage she took there: 167k (v1) → 96k (v11).
- Her follow-up J1s there: 21 (v8) → 227 (v12), 81k dealt.
- Kessa: 5 / 40 matches → 32 / 40.

## Not a repeat
- The wake-up Hoho, the slide in the Hoho's reach, the follow-up window and the any-perfect follow-up are new. Each rests on a fault
  located in the logs (diagnosis 1, 2, 4), not on a sweep.
- The sealed-form Hoho was b3_a1's suggested follow-up. b0_a0 (r2) found it within noise on its file (v10). Here it is ablated on the
  final file (−0.017 without it).
- The two grafts are credited above. b0_a0 made the same b3_a1 graft independently, but it lacks the slide and window fixes; its far
  band is taken here for `:space` only, which its all-mode version (my v14) shows matters.
- Re-listed before writing: b1_a0 and b2_a0 are still empty.

## Risks
- **The wake-up Hoho's gain is an engine interaction.** It mostly loses its frame 0 to his J1 and wins only through the perfect Hoho's
  40 f input lock on him. If the perfect check or the lock changes, that gain goes with it. A Kenpachi that delays the meaty by a few frames
  would meet the Hoho's iframes instead, which is better for her, or he could stop the meaty and wait out her Hoho.
- **The timed Hoho is a defensive tool shared by every fighter,** not one listed in §4's KESSA row. b3_a1 carried the same review risk, and
  this cell spreads it to the sealed form and the wake-up. It is the shipped CPU's own Hoho, retimed: 0 at EASY and NORMAL.
- **Flash-step is the bottleneck.** In KESSA, 117 of his lunges found her with no Hoho available (20 seeds a seat, before v8). The Burst
  (300 a time, the generic CPU's) competes for the same gauge.
- **NORMAL headroom is 3 wins** (8 of 80; the band's top is 11). Every new piece here is 0 or HARD-only at NORMAL. `*iks-k-sa-reach*` 5.7
  is the one changed value that acts at NORMAL, in a :kessa episode's k-lunge.
- **Spacing is still the weakest theme (0.155).** His back Step and Hoho meet her lunges. Only `:space` takes the far band, because more
  modes cost the ledger.
- **Carried from the baseline:** the Konpaku-pip read (`iks-kikon-value`), his form for the band tables. `iks-move`'s SA test reads her own
  fighter's true distance (as v0 did; only the threshold changed).
- **Noise:** at 20 seeds a seat, near-neutral variants moved ±0.03–0.05. The final is judged at 40, and each kept step held at 40
  (v3 → v8 → v11 → v12 → v15).
