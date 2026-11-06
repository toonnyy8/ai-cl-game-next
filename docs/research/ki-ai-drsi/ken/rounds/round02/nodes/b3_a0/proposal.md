# b3_a0 (round 2): 破月牙 before the wave. No blind dash at her pointer 2, the Hoho that never came out, the close Hoho over the late one

Direction: 破月牙 (antiwave), keeping the other three themes usable.
- Parent: none. This cell opens from BASELINE_DIR, the round-1 champion b3_a1, re-measured at the second freeze against Ichigo's
  champion: 0.8334.
- Opponent: Ichigo's champion (b2_a1).
- Changed only `duel/lisp/cpu-ki-ken.lisp`. Every new knob is a `defparameter` with a docstring (old -> new where tuned).

## History read (proposal.md, score.json, score.rescored.json; the rescored number is the reference)

| Cell | Rescored (first freeze, vs her v0) | Mechanism | What it shows for 破月牙 |
|---|---|---|---|
| r1 b0_a0 | 0.6536 | sealed discipline, the dodge Hoho, the AS read | antiwave 5/15 |
| r1 b0_a1 | 0.8108 | + flash-step reserve, back Step, b3_a0's antiwave | 12/16 |
| r1 b1_a0 / b1_a1 | 0.6558 / 0.8349 | the climb, the Kikon pointer gate; + b0 + b3 | 5/12; 9/9 |
| r1 b2_a0 / b2_a1 | 0.4954 / 0.8712 | the Bankai cycle; b3_a1 + the L3 approach | 17/36; 6/7 |
| r1 b3_a0 | 0.4106 | antiwave rebuilt: `:late` 1.0 + `:chase`, plan by reach | 24/32. Logged `:close` from 4.4 m landing 2 of 12 and moved weight to `:late` |
| r1 b3_a1 (= baseline) | 0.8763; **0.8334 at the second freeze vs her b2_a1** | everything combined + the far answers (Hoho at once, cut, forward Step) | 7/8 vs v0; **2/3 vs her champion** |
| r2 siblings | (empty when I read them, and when I finished) | | |

- Against her champion, antiwave opens only about 3 times in 80 HARD matches. Her style shoots only from a perceived 7.5 m or more, and
  she reaches pointer 2 only about 10 times in 40 matches (AS2, mostly her red finisher). A theme rate on 1–4 situations is noise.
  - So I judged every change by **every Getsuga route of hers, at any distance**, from the saved logs (both HARD seats).
  - The test is the theme's own: the wave never hit him, and he hit her before her next non-route move.
  - I also counted the full waves (150) that hit him.
- b3_a0's "sealed `:close` landed 2 of 12" turned out to be a located bug (below), not a flaw in the idea.

## Diagnosis (b3_a1's file against her champion, 20 seeds a seat, HARD logs, plus a debug run of 10 matches)
1. **The blind dash.** All 5 full waves on him in the 10 debug matches came from one loop (I traced those 5; at 40 seeds the count of
   150s on him is 7, and 0 with this file):
   - her AS2b's point-blank wave puts him down;
   - she Steps and dashes back to 8.2 m and shoots from 7.5 m on;
   - the generic CPU (d > 7 m) dashes in at once: `AI-DASH` to 4.5 m, a Step hop (24 frames) and then a run, held as one press.
   - `core-brain-step` does not call the style while a press is held. So her route was first seen at the dash's end, at 4.5 m, about
     40 frames in, with JUJISHO already on him. Example: seed 10, IK seat, routes at 1544 / 1687 / 1832, three 150s in a row.
2. **A located bug: the Hoho pressed on the step a dash lets go never came out.**
   - `vpad-set!` stamps a press only on a down edge. The dash held Step, so a Hoho (mod + Step) pressed on the step the dash was
     released found Step still down: no press.
   - The plan then moved on to `:hit` and walked in. Logs: CLOSE at 4.5 m with no `hoho` line after it (6308, 1874), each followed by a 150.
   - The same engine edge existed in round 1, so this is consistent with b3_a0's "the sealed close from 4.4 m landed 2 of 12" (the
     reason it moved the weight to `:late`). I did not see b3_a0's logs.
   - With the fix, every one of the 20 `kk wave CLOSE` plans in the final's 40-seed HARD logs was followed by its Hoho or by the NS /
     J press where it already reached. No press was lost.
3. **`:late` can't meet her.**
   - The Hoho takes 24 frames. Pressed at JUJISHO + 19, his J1 hits at about + 49, and her JUJISHO recovery ends at + 46.
   - From 1.6 m behind her, at pointer 2, her style presses J1 at once (a new neutral episode, `ikst-dt` 0).
   - One failure (v1, IK seed 4): her J1 at + 47, his J1 started at + 45. The situation closed as a failure.
4. 3 of 13 routes in the debug run drew a failed `*kk-wave-p*` roll (0.9). All three ended in a 150 through the generic dash.

## The mechanism
1. **`kk-far` (`*kk-far-p*` 0 / 0 / 0.9, `*kk-far-min*` 7.0): Hoho in instead of the generic dash, at her pointer 2.**
   - It applies when she is seen at pointer 2 and he is beyond 7 m, where the generic CPU's next decision is the blind dash.
   - One roll per far approach. It needs a Hoho open and `*kk-hin-fs*` 200 flash-step, so b0_a1's reserve for the dodge is kept.
   - A Hoho reappears 1.6 m behind her from any distance, before her charge is up. At pointer 2 she has no punisher there (her J1 is S14,
     his S6).
   - Her pointer is read as he saw it written: `kks-iptr` = her last perceived AS n (IC-AS1/2/3, IC-K-AS1/2/3), or 2 on her NS2a. A
     match starts at 1. These are her perceived SNAP moves only; nothing reads her fighter's pointer.
   - No Hoho or no flash-step: the generic dash as before.
2. **The Step-held wait (the bug fix).** In `kk-wave-step`, while a plan is on and his Step button is still down from the dash he just let
   go, he waits that one step (stick still). The Hoho / Step press then has its edge. Every timed press keeps its +3-frame window.
3. **`*kk-wave-mix*` `:close` 0.25 -> 1.0, `:late` 1.0 -> 0.25** (in the band, where his NS doesn't reach and a Hoho is open).
   - A Hoho at once puts him behind her during the charge, with the wave flying the other way. His NS lands on her charge (F11), as the
     far plan already did.
   - New `*kk-wave-close-dash*` 0.25: with no Hoho open, `:close` is the dash, so it keeps b3_a0's old weight rather than becoming
     more frequent.
4. **`*kk-wave-p*` HARD 0.9 -> 1.0.** NORMAL stays 0.15.

Rules kept:
- One roll per event: the far approach, her route.
- SIM-RND01 only (`brain-roll`).
- EASY ≤ NORMAL ≤ HARD; NORMAL 0 for `*kk-far-p*`.
- She is read through the SNAP and the distance only. The Step-held test reads his own vpad.
- Nothing reads the evaluator or its detector. The far Hoho fires only beyond 7 m. **Disclosed:** it does change how her routes open.
  - From behind her she retreats again (Step + dash) and shoots again.
  - Some of those shots start at a true 3.6–6.6 m, because her style shoots from a perceived 7.5 m, eight frames old, while she is
    still moving. Example: v1, IK seed 4, `kk far hoho at 7.1`, then her NS2a from a true 5.0 m.
  - So part of the theme's rise in occurrences (3 -> 4 at 40 seeds) comes from this. It is a side effect of the far Hoho, not a
    target: the rule is keyed to her pointer and the distance beyond 7 m. The coordinator should judge it.
- The style registers only Kenpachi vs Ichigo.
- Host tests: 9843 checks, ALL PASS.

## Measurements (matchup-eval --side ken; 20 seeds a seat paired, then 40; the route columns are from each run's saved HARD logs)

| Variant | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL | her routes ok (any distance) | 150s on him |
|---|---|---|---|---|---|---|---|---|---|---|
| baseline (b3_a1) | 20 | 0.8647 | 36/40 | .684 | .909 | .771 | 1/1 | .925 | 9/16 (.56) | 6 |
| v1 + `kk-far` + the Step-held wait | 20 | 0.7894 | 36/40 | .681 | .918 | .763 | 1/2 | .925 | 11/14 (.79) | 2 |
| v2 + `:close` 1.0 / `:late` 0.25 | 20 | 0.8657 | 36/40 | .680 | .918 | .773 | 2/2 | .925 | 12/14 (.86) | 2 |
| v3 + `*kk-wave-p*` 1.0 + `*kk-wave-close-dash*` (final; docstrings only after) | 20 | 0.8691 | 36/40 | .683 | .919 | .792 | 3/3 | .925 | 17/18 (.94) | 0 |
| baseline (b3_a1), logged | 40 | **0.8334** | 74/80 | .681 | .930 | .812 | 2/3 | .9125 | 15/24 (.62) | 7 |
| **final** | 40 | **0.887** | 74/80 | .679 | .944 | .823 | **4/4** | .9125 | **22/24 (.92)** | **0** |

- v2's 20-seed JSON line was lost from my wrapper's output. Its row was recomputed from its saved logs with the evaluator's own
  `parse()`, using band floor 0.863 (the evaluator's 0.8625). That makes no difference at NORMAL 0.925.
- v1's score dip is one antiwave situation: the late-Hoho failure of diagnosis 3, which v2 removes. Its route count and 150s improved.
- At 40 seeds, paired:
  - every one of the 7 full waves on him is gone;
  - her routes judged by the theme's rule went from 15/24 to 22/24;
  - the far Hoho fired 5 times;
  - strength, brawl and NORMAL did not move (74/80, brawl −3 of 1327, NORMAL 0.9125, factor 1);
  - shikai +2, bankai +2.
- Final, 40 seeds (score.json, the direct EVAL_COMMAND): **0.887**.
  - Strength 0.925, signature 0.8616 (brawl 0.679, shikai 0.944, bankai 0.823, antiwave 1.0 (4/4)).
  - +0.054 on the baseline's 0.8334 on the same seeds.
  - The logged re-run reproduced both JSON lines exactly.

## Why it is not a repeat
- No earlier cell looked at the generic dash as a press the style is blind through. b3_a0 tried a walk-in instead of the generic dash
  (1 of 40) and reverted it. Here it is replaced only at her pointer 2 beyond 7 m, and by a Hoho, which keeps the closing speed.
- The edge bug is new and located (`vpad-set!`'s edge, the dash's held Step). It also explains b3_a0's measured 2 of 12 for `:close`,
  so reversing that weight is a fix of the data it rested on, not a knob drift.
- Her pointer inferred from perceived AS / route moves is new in this style.

## Expected benefit and risks
- Expected: the antiwave theme near 1.0 whenever it comes up, and no full Getsuga chains on him. The score gain, about +0.05, is almost
  all antiwave: 0.667 -> 1.0, plus small shikai / bankai gains.
- **The antiwave count stays tiny (3–4 in 80 matches).** Her champion shoots in the band only when his own approach shortens a 7.5 m
  perceived shot, so the theme rate rests on a handful of situations. The route proxy (22/24) is the stronger evidence.
  - An occ of 0 would zero the theme. That happened in no run here (1–4 situations).
- Strength did not rise: the 6 HARD losses are not wave losses. The other themes' gaps (brawl 0.68) are untouched by this cell.
- **The 2 of 24 routes still failing (final, 40 seeds; neither started inside the theme's band):**
  - KI seat, t 9870: a point-blank route at 2.3 m in a Bankai. KYORAN's NA went into her charge and was read by the charge's SA
    (IC-K-SA-G1), then absorbed.
  - IK seat, t 6024: sealed with no Hoho open, after her AS2b. The forward Step from 8.7 m dodged that wave and the next one, but he did
    not hit her before her next route. The third route he beat (J1 > AS1, 90).
- **`kks-iptr` can go stale.** Her pointer can also drop outside an AS (`combat.lisp`: a form change clamps it to the form's NS
  count), which the inference does not see. The worst case is a wasted far Hoho, still under the 200 reserve.
- `kk-far` spends a Hoho at range. It is gated by the 200 flash-step reserve, and it fired only 5 times in 80 matches. An Ichigo that
  punishes his reappear point at pointer 2, or stops shooting from 8 m, would make it idle, not harmful.
- The Step-held wait costs one frame on a plan's first press after a dash. Timed presses keep their +3 window, and every pressed
  `:step` / `:late` still came out.
