# b3_a1 (round 3, 破月牙, parent b3_a0): no NS pressed into a wave that is already out (a Hoho through it instead), and the Step-held Hoho fix merged at last

Direction hint: 破月牙 (antiwave), keeping the other three usable. Parent: b3_a0 (rescored 0.8609, HARD 80/80, antiwave 0/0 excluded).
Opponent: Ichigo's champion (her round-2 b1_a1). Only `duel/lisp/cpu-ki-ken.lisp` changed. The three new knobs (`*kk-wave-late*`,
`*kk-wave-w0*`, `*kk-wave-touch*`) are `defparameter`s with docstrings.

**Disclosed up front: against her champion the antiwave theme cannot open, so this cell cannot move the score through it.** The
champion score of the final file is identical to the parent's (below). What the cell delivers is an anti-Getsuga answer that is
measured against an Ichigo who does shoot (her generic CPU), with one located timing bug fixed and one located engine-edge bug merged.

## History read
- Every score.rescored.json of rounds 1–3 and the baseline. Summary / mechanism / measurement sections of: the four earlier 破月牙
  cells (r1 b3_a0 / b3_a1, r2 b3_a0 / b3_a1), the parent (r3 b3_a0, whole), and the round-3 siblings b0_a0, b1_a0, b2_a0 (headers,
  diagnosis, mechanism). The rest by headline and score.
- Lessons that shaped this cell:
  - r1 b3_a0: the plan by reach, `:late` + `:chase`; the AS on her route.
  - r1 b3_a1: the far answers (Hoho at once, cut, the timed forward Step), `kk-step-j`.
  - r2 b3_a0: **the Step-held bug** (a Hoho pressed on the step the dash lets go of Step has no down edge and never comes out), `kk-far`,
    `:close` 1.0. r2 b3_a1: the arrival gates (`kk-wave-arrive`, `*kk-close-dash-lead*`), `:step` in the released forms.
  - None of those r2 pieces is in this lineage: the round-2 champion was b0_a0, whose file came from r1 b3_a1, and round 3 started from it.
  - The parent (r3 b3_a0) beat her timed perfect Hoho (the brawl 0.27 -> 0.93, HARD 3 -> 80 of 80); it disclosed antiwave 0/0 in all its
    runs and made no rule aimed at the wave.
  - Round-3 siblings found the same Hoho leak independently; none touched the wave.

## Why the theme cannot open against her champion (her file, read; HARD logs of the parent, 20 seeds a seat)
- The situation is her NS2a (or KESSA's) started at 3.6–6.6 m. She shoots only at pointer 2 (`iks-pointer-2`):
  - from a perceived 7.5 m or more (outside the band), and only against his sealed form (`*iks-p2-wait*`: against his released forms
    pointer 2 hovers and waits);
  - 3.6–7.5 m sealed: a back dash to 8.2 m (HARD 1.0, re-armed on each move of his), else the generic CPU (which can shoot from 3.6–6.6 m).
- She almost never is at pointer 2: her strings steer to AS3 (pointer 3). In the parent's 40 HARD matches her AS lines were AS3 78,
  AS1 1, **AS2 1** (that one against his Shikai, where she waits). No Getsuga route at all.
- Making her shoot is no target: a 0/1 antiwave would cost about 0.115 score, and baiting a pointer change (feeding her AS2 read with his
  NS) would trade into her SA. I did not try.
- **The shikai / bankai failures (0.61 / 0.72 at 20 seeds) are all K.O.s**: in the parent's 40 HARD matches all 24 failed Shikai stays
  and all 13 failed L3s ended with the match (a Soul Break or a pointer-2 Kikon in the Shikai, a Kikon in the Bankai). Lifting them would
  mean holding back a kill ("not yet" keyed to the theme's close), which the brief forbids. I left it, as b3_a0 did.

## The testbed (scratch only; the evaluator is untouched)
His HARD style against her **generic** HARD CPU (`SITU_GENERIC=ichigo`, matchup-eval's own command line, logs kept), seeds 1–40 both
seats: the situation detector's antiwave lines, and every route of hers at any distance judged the theme's way (the wave never hit him,
he hit her before her next non-route move, 200 steps). The generic CPU shoots from 3.6–6.6 m at pointer 2.

Parent on it: antiwave **7/9**; 84 routes; **full waves (150) on him: 3**, all in the Shikai. One of the three was a located bug:
- **The late press.** `:close` / `:hit` press the pointer's NS (KK-CLOSE-HIT) whenever he is free and in reach, however late. IK seed 4
  t 8129: plan at 2.3 m, he was busy until t 8178, then pressed the Shikai lunge (S16) 20 frames after JUJISHO started; the wave hit him
  at 8181. The other two are not it: KI seed 20's lunge (t 8171) was active before the wave was out and whiffed for reach; IK seed 16
  (t 7320) had no plan, he was busy through her Burst.
- The antiwave failures (2): KI seed 33, after her Burst his lunge went into her Hoho (her generic Hoho, unrelated to the wave); IK seed
  30, in the Bankai his J1 cancelled her charge and the AS read pressed AS1 into her charge's SA (IC-K-SA-G1). Neither is a timing bug I
  could fix without a new rule on her SA; left.

## The mechanism (HARD only: `*kk-wave-late*` NIL / NIL / T, so NORMAL plays exactly as the parent)
1. **`kk-wave-late-p` in KK-CLOSE-HIT.** At the press, his NS (or the sealed J1, which cannot cut a wave; the released forms' J1 is
   the cut and is left alone) is not pressed when its first active frame comes at or after JUJISHO's wave is out (`kk-juji-start` +
   `*kk-wave-w0*` 20, `:ic-juji` startup 20) while the wave has not yet passed him (+ 60/14 frames a metre beyond `*kk-wave-touch*` 1.9 m,
   + 2; fitted to the logged 150s: 2.3 m +23, 2.9 m +24). Instead:
   - Hoho open: **Hoho at once** (i-frames 1–14; he reappears 1.6 m behind her and the wave flies away from him), then `:chase` onto her
     JUJISHO recovery (J1, the fastest, else the NS);
   - no Hoho: the timed Step through the wave (`:step`, the existing `*kk-wave-step-lead*` timing; if its tick has passed, no answer).
   - A first version without the "not yet passed" bound also blocked presses after the wave had gone by (KI seat t 3186, at 0.9 m in her
     recovery): fixed by the bound.
2. **The Step-held wait** (r2 b3_a0's located bug, credited; gated by the same flag): while a wave plan is on and his Step is still down
   from the dash he just let go, wait one step so the Hoho / Step press has its edge. Only the wave plans (`:close :hit :cut :late :step
   :chase`), not the dodge plans (round-3 b0_a0 showed a one-step-late dodge loses to her meaty).
   It writes no log line: how often it fired is unmeasured in this cell.
- No new roll (a gate on the perceived SNAP; the roll is still `*kk-wave-p*`'s one per route). SIM-RND01 only. She is read through the
  SNAP (her route's move and start tick) and the distance. Only Kenpachi vs Ichigo is registered.

## Measurements
**Against her champion (the EVAL_COMMAND, paired seeds):**

| File | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| parent b3_a0 (reproduced) | 20 | 0.85 | 40/40 | .914 (254/278) | .613 (38/62) | .723 (34/47) | 0/0 excl. | 1.0 (factor 1) |
| **this file** | 20 | 0.85 | 40/40 | .914 (254/278) | .613 (38/62) | .723 (34/47) | 0/0 excl. | 1.0 (factor 1) |
| parent b3_a0 (its rescore) | 40 | 0.8609 | 80/80 | .931 | .646 | .727 | 0/0 excl. | .9375 |
| **this file (score.json)** | 40 | 0.8609 | 80/80 | .931 (513/551) | .646 (84/130) | .727 (72/99) | 0/0 excl. | .9375 (factor 1) |

The 20- and 40-seed lines are identical to the parent to the digit: no Getsuga route in those matches, and NORMAL is untouched by design.

**The testbed (his HARD style against her generic HARD CPU, both seats, paired):**

| File | seeds a seat | HARD wins | antiwave (ok/occ) | her routes, any distance, won by the theme's test | full waves (150) on him | late presses turned into a Hoho / Step |
|---|---|---|---|---|---|---|
| parent | 1–40 | 80/80 | 7/9 | 46/84 | 3 | – |
| this file, v1 (no "not passed" bound) | 1–40 | 80/80 | 7/9 | 45/85 | 4 | 4 |
| **this file** | 1–40 | 80/80 | 7/9 | 46/82 | **2** | 1 |
| parent | 1–80 | 160/160 | 13/17 | 92/177 | 8 | – |
| **this file** | 1–80 | 160/160 | **14/18** | 93/174 | **5** | 3 |

- The full waves on him fall 8 -> 5 at 80 seeds a seat, and the attribution is traced: the three late-press Hohos (KI seed 62 t 7487,
  IK seed 4 t 8178, IK seed 67 t 6116) sit exactly where the parent took a 150 (t 7499, 8181, 6127); the antiwave band itself is 13/17 -> 14/18 (too few to call).
- The four band failures left are not timing: two are the IK seat's J1 cancelling her charge then the route AS whiffing into her charge's
  SA (seeds 30, 54), one her generic Hoho after a Burst (seed 33), one a `:step` plan whose tick passed while he Stepped in (seed 58).

## Why it is not a repeat
- r2 b3_a1's `kk-wave-arrive` gated the **plan** (rolled once at the route's first sight); this gates the **press**, which is where the
  located failures are (the plan was right, he got free late). It also uses the wave's real out-frame (20) and a fitted touch distance.
- The Step-held wait is r2 b3_a0's fix, never merged into this lineage; credited, restricted to the wave plans.
- No earlier cell measured antiwave against an Ichigo who shoots in round 3; the parent's 0/0 left it unmeasured.

## Expected benefit and risks
- **Against her champion: none expected, none measured** (identical lines). The theme stays excluded.
- If a later Ichigo shoots from the band (her generic CPU does, so does any style that drops `*iks-p2-wait*`), the late NS no longer eats
  the wave: full waves on him 3 -> 2 at 40 seeds, see the table.
- Risk: the fit (`*kk-wave-w0*` 20, `*kk-wave-touch*` 1.9) is from a handful of logged hits; a wrong bound only turns a late NS into a
  Hoho (which is safe from the wave either way) or leaves the old press.
- Host tests: 9843 checks, ALL PASS.
