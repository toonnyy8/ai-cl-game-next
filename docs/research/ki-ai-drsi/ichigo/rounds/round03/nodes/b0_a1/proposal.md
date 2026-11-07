# b0_a1 (round 3, Ichigo): the shut-gauge lunge made to fire. Dash out only on a shut that lasts, lunge on her next free frame, from a stand; under b2_a0's bait hover

Direction: 間合い管理 (spacing), keeping the other three usable. Parent: b0_a0 (the shut-gauge lunge, 0.8387 rescored). Opponent:
`ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
Every score.rescored.json of rounds 1–3. Read whole: the parent's proposal and file. Summary, mechanism and measurement sections: the
baseline, round 1's b0_a0 / b0_a1, round 2's b0_a0 / b0_a1, and the round-3 siblings b1_a0, b2_a0, b3_a0, b1_a1 and b2_a1 (delivered at the end: 0.8477 by its own run, spacing
0.115, a lunge on his Step tell over b2_a0).

| Cell | Mechanism | Rescored | Bearing here |
|---|---|---|---|
| r1 b0_a0 / b0_a1, r2 b0_a0 / b0_a1 | lunge bands, the far k-lunge, the meaty NS3a | 0.648–0.793 | every spacing push before the parent lost to his dodge (KK-READ) |
| r3 b0_a0 (parent) | lunge only while his Hoho is shut, from beyond his back Step, as he walks in | 0.8387, spacing 0.253, whiff 0.891 | the lunge works (47/51 clean in my logs); it fires too rarely |
| r3 b1_a0 | hold ground after 90 f of hovering (breaks the 3 m stand-off) | 0.8407 | not used (b1_a1 found the bait better) |
| r3 b2_a0 | bait hover 2.3–2.7 m in :whiff / :ptr3 / :kessa; the k-SA dodge-stop and its perceived distance | 0.8517, spacing 0.071 | grafted (both) |
| r3 b3_a0 | disciplined KESSA; the k-SA floor 2.0 m | 0.8343 | the floor grafted |
| r3 b1_a1 | b1_a0 + b2_a0's bait and k-SA fix + a dodge cover | 0.8472, spacing 0.075 | the bait's value confirmed |

No earlier cell located the flaws below; the parent named b1_a0 as composable. The bait hover and the shut-gauge lunge have never run
together: the siblings that kept the bait have no spacing tool (0.07), and the parent has no bait (whiff 0.89).

## Diagnosis (the parent, HARD, 20 seeds a seat)
Scratch runner: the parent's run-diag.lisp (situ.lisp + one line per spacing open with both gauges), a parser that buckets each situation by
what happened in it, and a runtime knob override, so a variant is a set of SETFs on one build (an override that restores the parent's
values reproduced its 0.8384 exactly). 102 of 401 situations succeed.

| Bucket | ok / situations |
|---|---|
| a gap lunge, not dodged / dodged | 47 / 51, 14 / 25 |
| **a dash-out with no lunge after it** | **15 / 122** (33 of them hit during or after the dash) |
| match start, 8 m, pointer 1 (nothing reaches) | 0 / 43 |
| pointer 2 against his Shikai (the wait) | 0 / 34 |
| his Hoho open, no tool | 2 / ~70 |

Located flaws in the dash-out:
1. **The cadence after the dash** (the main one). The lunge waits for `ikst-dt`, which the dash press itself sets to the generic think
   time (22–34 frames, counted only once she stands). He walks through the 0.55 m lunge band in 8 frames, so she found him inside it and
   dashed out again: 417 dashes for 105 lunges, runs of three dashes at a perceived 6.3 m.
2. **Dashes that can't pay.** Most came at his flash-step 91–95 (it reopened within 0.3 s) or on the 48 f lockout alone, shorter than the
   dash. Each one carried her across 4–5 m and opened a situation for nothing.
3. **His Shikai lunge on the step.** KE-S-N1A (2.6 + 3.0 m slide) catches the dash's step from 5.6 m. In KESSA that damage counts against
   the KESSA ledger.
4. **`iks-punish`'s NS branch had no reach test.** 24 of 28 NS punishes were pressed at 6.6–7.0 m once the wait ran out, whiffed into
   NS-STOP and ate his lunge or his dodge.
5. The parent still pressed KESSA NS3a's SA after his dodge, and read the true distance there (b2_a0's located bug).

## The change (final file)
- **`*iks-gap-dash-dt*` 1.** After her dash-out the next own decision comes on the next frame. The lunge is the same plan's next press.
  It still waits until she stands (`fighter-state :idle`): a lunge pressed out of her own run carries 1.0 m away from him and whiffed (v4).
- **`*iks-gap-dash-need*` 90 + `iks-his-shut-left`.** She dashes out only while his Hoho stays shut 90 more frames: his flash-step's climb
  to 96 at `*fs-regen*`, or the rest of his lockout. The lunge itself still fires on any shut. Under the gate she plays the patient
  hover / bait.
- **`*iks-gap-dash-his-forms*`, by her form.** Against his Shikai she dashes out only in the sealed form. In KESSA there is no dash
  against the Shikai.
- **`*iks-punish-ns-reach*`.** The NS punish presses only within her punisher's reach (`*iks-punish-reach*`), as the J punish does. Else
  it waits while his move lasts.
- **Grafts**: b2_a0's bait hover (`*iks-bait-hover*`, `*iks-bait-modes*`, `iks-hover-band`, HARD); its k-SA dodge-stop and perceived
  distance; b3_a0's k-SA floor 2.0 m (read from the perceived distance).
- `iks-closing` reads the brain's SNAP ring (the snap she sees and the one a step older). It equals the parent's value whenever the last
  call was the step before (v3r = v2 exactly), and is never NIL after a held press.

Rules: no new chance. The two dash rules are deterministic and only act inside the parent's gap (NORMAL 0). The NS reach and the k-SA rules act at every
difficulty; NORMAL was measured unchanged (below). His Hoho state is read as the parent read it (his flash-step on the HUD, the coordinator's
open ruling; his lockout from the SNAP). Every knob is a `defparameter` with a docstring. Host tests 9843 ALL PASS; pkgcheck clean. The
file registers only Ichigo against Kenpachi.

## Measurements
20 seeds a seat, HARD only, paired, through the diag runner (matchup-eval's own `parse`; raw = 0.4 strength + 0.6 signature).

| Variant | raw | HARD | spacing | whiff | ptr3 | kessa | lunges / dashes |
|---|---|---|---|---|---|---|---|
| parent b0_a0 | 0.8384 | 39 | 0.254 (102/401) | 0.904 | 0.980 | 0.850 | 105 / 417 |
| v1 = dash gate 90 + NS reach | 0.8337 | 38 | 0.249 (87/349) | 0.926 | 1.0 | 0.85 | 91 / 260 |
| v2 = v1 + k-SA grafts | 0.8274 | 38 | 0.240 (86/358) | 0.893 | 1.0 | 0.85 | 97 / 280 |
| v3 = v2 + a run-in lunge (rejected) | 0.8359 | 39 | 0.189 (65/344) | 0.934 | 1.0 | 0.85 | 67 / 249 |
| v4 = v2 + dash-dt 1 | 0.8276 | 39 | 0.215 (85/395) | 0.861 | 0.969 | 0.872 | 170 / 304 |
| v5 = v4, lunge from a stand only | 0.8361 | 38 | **0.290** (102/352) | 0.920 | 0.981 | 0.85 | 97 / 222 |
| v5a = v5, no dash against the Shikai | 0.8388 | 38 | 0.219 | 0.975 | 0.990 | 0.875 | 49 / 76 |
| v6 = v5 + bait hover | 0.8084 | 38 | 0.237 | 0.903 | 0.990 | 0.725 | 116 / 277 |
| v6a = v6, no dash against the Shikai | 0.8564 | 40 | 0.170 | 0.948 | 1.0 | 0.925 | 73 / 133 |
| **v6b = v6, Shikai dash in the sealed form only (final)** | **0.8723** | **40** | 0.233 (73/313) | 0.965 | 1.0 | 0.95 | 59 / 117 |
| v6a, seeds 21–40 | 0.8604 | 40 | 0.218 | 0.951 | 1.0 | 0.90 | |

- **v3, the run-in lunge (rejected, removed).** A move out of a run keeps 1.0 m of carry that his read doesn't count. But with his Hoho
  shut he was almost never standing far off. All 19 run-ins came at an 8 m reset, where he dashed in too.
- **v4 → v5** is the cadence fix's own bug, found in the logs. With dash-dt 1 she lunged out of her dash-out's run, and its carry is away
  from him.

**40 seeds a seat (matchup-eval, the final file):**

| Part | Baseline (r2 b1_a1, re-measured) | Parent b0_a0 (rescored) | b2_a0 (rescored, bait) | **b0_a1 (final)** |
|---|---|---|---|---|
| Score | 0.8104 | 0.8387 | 0.8517 | **0.8614** |
| HARD | 77/80 | 79/80 | 80/80 | **80/80** |
| Spacing | 0.062 (35/561) | 0.253 (209/827) | 0.071 (36/509) | **0.242 (153/633)** |
| Whiff | 0.978 | 0.891 | 0.983 | 0.951 (588/618) |
| Ptr3 | 0.99 | 0.99 | 0.995 | 0.995 (205/206) |
| KESSA | 0.805 | 0.825 | 0.963 | 0.887 (71/80) |
| NORMAL | 0.075 (factor 1) | 0.075 (factor 1) | 0.075 | 0.075 (factor 1) |

On seeds 1–20 the final build reproduces v6b exactly (0.8723), so seeds 21–40 alone come to about 0.85: KESSA 33/40 there
against 38/40. The search's 40-seed draw noise is ±0.02.

Also rejected after the final: the far k-lunge only while his Hoho is shut (v7, the parent's vB idea under the bait): 0.8553 against
0.8723 on seeds 1–20 (spacing 0.212, kessa 0.925). Removed.

## Expected benefit, risks
- **What the parts do.** The bait hover brings whiff and KESSA back (40 seeds, against the parent: whiff 0.891 → 0.951, kessa
  0.825 → 0.887, HARD 80/80). The dash fixes keep most of the parent's spacing under it: the bait cells have 0.07–0.12, this file 0.242. Situations with a
  dash-out: 47 of 68 succeed, where the parent had 77 of 204 (seeds 1–20).
- **Risks**:
  - The flash-step HUD read is still the coordinator's call (as in the parent). Without it only the lockout half is left, and the dash
    gate would almost never open.
  - 20-seed variants move ±0.02 with the draw. v6 against v6b differs only in the KESSA dash against the Shikai (kessa 0.725 against
    0.95), and v6a's seeds 21–40 reproduce v6a's level.
  - A Kenpachi that keeps one Hoho in reserve shrinks every shut-gauge tool.
- **What's left for spacing**:
  - the match start (pointer 1 at 8 m), about 10 % of situations;
  - pointer 2 against his Shikai;
  - his Hoho open.
  None of these has a tool that reaches from ≥ 4 m without meeting his dodge.
