# b3_a1 (round 2, 破月牙, parent b3_a0): answers that can still land. The wave arrives first, so no late lunge or late dash; a Step through it instead of the cut; flash-step kept for the wave; every knockdown gets the meaty

Direction: 破月牙 (antiwave), keeping the other three themes usable.
- Parent: b3_a0 (0.887).
- Opponent: Ichigo's champion (her b2_a1).
- Only `duel/lisp/cpu-ki-ken.lisp` changed.
- The worktree is at 3d98bfa, not the freeze 2605e96. `git diff --stat 2605e96 HEAD` touches only `docs/research/ki-ai-drsi/`.
- Every new or changed knob is a `defparameter` whose docstring gives old -> new and the evidence.

## History read (summary, mechanism, measurement and score.rescored.json for each)

| Cell | Rescored | Mechanism | What it says here |
|---|---|---|---|
| r1 all 8, baseline | 0.41-0.876 (first freeze); baseline 0.8334 | b3_a1 = everything combined | r1 b3_a0: `:cut` never scores; a walk-in in place of the generic dash failed (reverted) |
| r2 b3_a0 (parent) | 0.887 | `kk-far`, the Step-edge fix, `:close` 1.0 | antiwave 4/4 at seeds 1-40; brawl 0.679 untouched |
| r2 b0_a0 | 0.9213 | `kk-link`, `kk-as-on`, meaty 1.0, dodge 1.0, Hoho in off | antiwave 1/1: her pointer-2 game nearly gone |
| r2 b1_a0 / b2_a0 | 0.8755 / 0.8698 | the Shikai lunge gate; the Bankai lunge + SA | |
| r2 b0_a1 (landed while I worked) | **0.7855** | b0_a0 + patience through her Hoho | brawl 0.892 and 80/80, but **antiwave 0/0** zeroed a theme |
| r2 b1_a1 (landed while I worked) | 0.9211 | b1_a0 + b0_a0's sealed pieces | antiwave 1/1 |

- **The antiwave cliff is the round's risk.** A theme with no situation scores 0, worth 0.15 of score. The stronger the brawl, the less
  she reaches pointer 2: one situation, or none, in 80 matches (b0_a0, b0_a1, b1_a1).
- So for this branch, the deliverable is a file whose antiwave holds up on seeds it was not tuned on. Pushing seeds 1-40 alone is not
  the goal: the parent is already 4/4 there.

## Method

Seeds 1-40 open antiwave 2-4 times, so I judged every change three ways. A scratch runner uses the frozen evaluator's own command line
plus debug 30000+k, edits nothing, and saves each job's log.
- **HARD seeds 101-300 a seat** (400 matches, raw = 0.4 strength + 0.6 signature). This is my **selection set**: I picked
  variants on it.
- **Seeds 301-500 a seat**: truly held out. They were run only on the parent, the final and the two siblings' files.
- **b3_a0's route proxy** over every Getsuga route of hers in those logs, at any distance:
  - ok when no wave of hers hit him and he hit her before her next non-route move (or within 200 steps);
  - also counted: the full waves (150) on him.
- **The EVAL_COMMAND at 20 / 40 seeds.**

## Diagnosis (the parent, held-out 101-300: antiwave 9/11, routes 49/62, 150s on him 5)
1. **A late dash** (KI seat, t 3294).
   - Sealed with no Hoho, after the generic step + dash (blind), the plan was rolled 14 frames before JUJISHO.
   - `:close` took its dash branch (`*kk-wave-close-dash*` 0.25), and NS1a started 2 frames before the 150 hit him.
   - The weight ignored time.
2. **A late lunge** (2 of the 150s at v4).
   - The plan was seen after the generic step + dash. `kk-wave-plan` makes the NS `:close` whenever it reaches.
   - The Shikai lunge (S16) was pressed 7 and 20 frames after JUJISHO started, and the wave hit him in its startup.
3. **`:cut` never scores against her champion:** 6 of 33 routes won, against 7 of 17 for `:step`, counted over five variants' held-out logs.
   - After the cut, her JUJISHO recovery ends at +46. She Steps back (invulnerable) and dashes out to shoot again, while his `:chase`
     walks.
   - With meaty 1.0 (v1m), three of the five antiwave situations at seeds 1-40 were Shikai / Bankai cuts with no hit: 2/5.
4. **The cut is chosen because no Hoho is open.** The Hoho in (HARD 0.8) spends the flash-step.
   - With it on, 8 of 64 routes drew `:cut`.
   - With it off, 1 of 57 did, and `:close` (a Hoho at once) became the answer: it won 35/48 (v3) and 34/43 (final) on 101-300, and
     45/51 on 301-500.
5. Not fixable: IK seat t 670. Her AS2b wave put him down; he was free 21 frames after JUJISHO.
   - Close-range "routes" at 2.4-2.9 m are mostly her whiff confirm (NS2a then the charge's SA), not Getsuga shots.

## Mechanism
1. **`*kk-close-dash-lead*` 28 (new).**
   - The dash `:close` (no Hoho, his NS short of her) is rolled only while her perceived JUJISHO start is at least 28 frames off.
   - Later, its weight is 0. The sealed form then takes the forward Step through the wave; the Shikai / Bankai take `:step` / `:cut`.
2. **`kk-wave-arrive` + `*kk-wave-w0*` 8 + `*kk-close-late-margin*` 8 (new).**
   - In the band, the NS where it reaches is `:close` only when now + its startup + 8 is no later than her wave reaching him.
   - The arrival is JUJISHO start + 8 + 60/14 frames a metre beyond 1.7 m, fitted to two logged hits (exact / 4 frames early).
   - Otherwise the mix decides, as where the NS does not reach: a Hoho at once (through the wave) or the forward Step.
3. **`*kk-wave-step-raised*` 1.0 (new).**
   - In the Shikai / a Bankai with no Hoho open, `:step` (Step through the wave, then J1 out of the Step's J cancel, `kk-step-j`) gets
     weight 1.0, beside `:cut` 0.15. Before, it was sealed-only.
   - The far branch (beyond 7 m) keeps the cut: a Step there reaches nothing.
4. **`*kk-hoho-in-p*` 0 / 0.05 / 0.8 -> 0 / 0 / 0.** b0_a0 made the same change for the brawl; here the reason is the flash-step the wave
   answers need. `kk-far` still keeps the 200 reserve.
5. **`*kk-meaty-p*` HARD 0.7 -> 1.0.** b0_a0's located wake-up bug, credited.

Rules:
- No new roll; 1-3 are deterministic gates and weights on the perceived SNAP.
- EASY ≤ NORMAL ≤ HARD holds (the Hoho in's NORMAL goes to 0, so 0 / 0 / 0).
- SIM-RND01 only. Only Kenpachi vs Ichigo is registered.
- Host tests: 9843 checks, ALL PASS.

Tried and dropped (all measured, all on top of the parent):
- **`kk-link` + `kk-as-on` (b0_a0's).**
  - Without the meaty (v2a): held-out 0.835, antiwave 11/15, 150s 11.
  - On top of v4 (v5): held-out 0.8854 against 0.9062; seeds 1-40 **antiwave 0/0** (0.7626).
- **Dodge 1.0 (b0_a0's)** on the final file (v7):
  - held-out 0.9115, but routes fell 56 -> 30 and antiwave occ to 7 in 400;
  - seeds 1-40 **antiwave 0/0** (0.7637).
  - It is the same cliff, so I left the dodge at 0.8.

## Measurements

The selection set, HARD seeds 101-300 a seat (400 matches); every row is from my own runs:

| File | raw | wins | brawl | shikai | bankai | antiwave | routes ok | 150s |
|---|---|---|---|---|---|---|---|---|
| parent b3_a0 | 0.8369 | 362 | .651 | .904 | .793 | 9/11 | 49/62 | 5 |
| v1 + dash-lead | 0.8505 | 362 | .651 | .903 | .794 | 10/11 | 50/62 | 4 |
| v1m + meaty 1.0 | 0.8578 | 392 | .677 | .895 | .806 | 8/11 | 47/64 | 6 |
| v3 + Hoho in off | 0.9062 | 395 | .727 | .882 | .798 | 10/10 | 39/57 | 9 |
| v4 + step-raised | 0.9062 (same logs: 1 cut in 400) | | | | | | | |
| **v6 + late-lunge gate (final)** | **0.9050** | 394 | .727 | .883 | .797 | **10/10** | 40/56 (step 5/8) | **6** |
| final without meaty (v6nm) | 0.8865 | 378 | .696 | .899 | .794 | 9/9 | 32/38 | 1 |
| sibling b0_a0's file | 0.8274 | 400 | .873 | .872 | .772 | **2/6** | 14/23 | 6 |
| sibling b1_a1's file | 0.8168 | 400 | .873 | .870 | .786 | **1/4** | 10/20 | 7 |

Held out, seeds 301-500 a seat (no selection was made on these):

| File | raw | wins | brawl | shikai | bankai | antiwave | routes ok | 150s |
|---|---|---|---|---|---|---|---|---|
| parent | 0.8590 | 374 | .656 | .917 | .802 | 12/14 | 61/76 | 7 |
| **final** | **0.9032** | 394 | .736 | .869 | .789 | 9/9 | 52/67 | 6 |
| sibling b0_a0's file | 0.8762 | 397 | .866 | .861 | .754 | 5/7 | 24/36 | 10 |
| sibling b1_a1's file | 0.8562 | 399 | .866 | .880 | .802 | 2/4 | 12/21 | 6 |

**Where the gain comes from** (101-300):
- Of the +0.068, +0.056 is v1 -> v3: b0_a0's two knobs, the meaty and the Hoho in off.
- My own pieces:
  - the dash gate adds +0.014;
  - the late-lunge gate is about 0 on raw, though the full waves on him fell 9 -> 6;
  - `step-raised` is inert on held-out seeds (1 in-band cut in 400 matches).
- At seeds 1-40, the final's edge over v3 (0.8142 -> 0.8892) is one situation that `step-raised` flipped (1/2 -> 2/2).

**The route proxy did not rise.** It is b3_a0's "stronger evidence".
- Routes ok: 49/62 -> 40/56 on 101-300, and 61/76 -> 52/67 on 301-500.
- Full waves on him: 5 -> 6 and 7 -> 6.
- The in-band theme did rise (9/11 -> 10/10, 12/14 -> 9/9), but on small n.
- So the title's "answers that can still land" is shown for the in-band situations, not for her routes overall.
- With the Hoho in off, more of his Hohos go to the dodge. Fewer routes open, and more of them start late.

The EVAL_COMMAND (seeds 1-N, paired):

| File | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| parent | 20 | 0.8691 | 36/40 | .683 | .919 | .792 | 3/3 | .925 |
| v1 | 20 | 0.8691 | 36/40 | .683 | .919 | .792 | 3/3 | .925 |
| v2 (v1 + meaty + link + as-on) | 20 | 0.7514 | 39/40 | .698 | .897 | .815 | 0/0 | 1.0 |
| **final** | 20 | **0.8809** | 38/40 | .739 | .856 | .745 | 2/2 | .975 |
| parent (its score.json) | 40 | 0.887 | 74/80 | .679 | .944 | .823 | 4/4 | .9125 |
| v1m / v3 | 40 | 0.8062 / 0.8142 | 78 / 77 | .653 / .762 | | | 2/5 / 1/2 | |
| **final (score.json)** | 40 | **0.8892** | 77/80 | .762 | .841 | .758 | **2/2** | .9625 (factor 1) |

## Why it is not a repeat
- The two timing gates are new located bugs.
  - Neither the dash `:close` nor the in-reach lunge ever checked whether the wave arrives first.
  - `kk-wave-arrive` is the first model of the wave's arrival in this style.
- `:step` in the raised forms replaces the cut, which round 1's b3_a0 saw never score; no cell acted on that.
- The Hoho in and the meaty are b0_a0's changes, credited. They are kept for a different, measured reason (the wave answers' flash-step).
  - b0_a0's other pieces were tested and dropped, each because it emptied the antiwave theme at seeds 1-40.

## Expected benefit and risks
- **Seeds 1-40:** 0.8892, +0.002 on the parent. Under the round's best (b0_a0 0.9213, b1_a1 0.9211), which have antiwave 1/1.
- **Held out (seeds 301-500):** 0.9032.
  - +0.044 on the parent (0.859).
  - +0.027 on b0_a0's file (0.8762) and +0.047 on b1_a1's (0.8562). Their brawl and strength are higher; their antiwave (5/7, 2/4)
    is lower and rests on fewer situations.
  - On the selection set (101-300): +0.068 on the parent, +0.078 / +0.088 on the two siblings.
- Seeds 1-40 decide every file's score on 1-4 antiwave situations. That includes this one: its 2/2 is one situation above v3's 1/2.
- **Antiwave still opens rarely** (2 at seeds 1-40, 10 in 400 held-out). A run with none would zero it.
  - That is why I kept the dodge at 0.8 and `kk-link` / `kk-as-on` out: each raised held-out raw a little and emptied the theme at
    1-40.
- **HARD 77/80 at seeds 1-40** (3 losses; 394-395/400 held out).
- Shikai and bankai fall a little (he wins sooner), the known trade.
- **NORMAL** is in the band (0.9625 / 0.975). The NORMAL changes are the Hoho in 0.05 -> 0 and the mix weights under the NORMAL 0.15
  wave roll.
- **The model and the gates.**
  - `*kk-wave-w0*` comes from two logged hits; a wrong arrival estimate shifts some lunges to Steps.
  - The raised `:step` relies on J reach after a 2.5 m hop, which works from about 3.4-4.8 m. Held out it won 5 of 8 routes, and 7 of 9 on
    301-500.
  - The far branch still cuts (0 of 6 won on 301-500, all beyond 7 m and outside the theme's band).
