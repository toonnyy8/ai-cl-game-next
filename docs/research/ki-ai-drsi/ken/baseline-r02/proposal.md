# b3_a1 (round 1): the round's working pieces combined, plus 破月牙 from afar (an immediate Hoho, a timed Step through the wave), plus b0_a1's flash-step budget

Direction: 破月牙 (antiwave), keeping the other three themes usable. Parent: b3_a0 (0.4106). I rebuilt the file on b0_a0's file and
put each piece back in, with credit below. Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob is a `defparameter` with a
docstring. Opponent: Ichigo's champion (= her v0).

## History read (proposal.md, score.json, score.rescored.json; the rescored numbers are the reference)

| Cell | Rescored | Mechanism | What it shows |
|---|---|---|---|
| baseline v0 | 0.3505 (10/80) | the four styles, first draft | the plans pressed J into her NS |
| b0_a0 | 0.6536 (53/80) | sealed discipline: reach-gated starts, whiff stop, dodge Hoho, red-only Kikon, Hoho-in; the AS read | brawl 0.706, the best. The AS read alone took it from 0.537 to 0.700 at 20 seeds. Antiwave 0.333 (5/15) |
| b1_a0 | 0.6558 (55/80) | awaken once a match, Kikon pointer gate, turn on her NS (= the AS read), Bankai dash, L3 SA | shikai 0.853, bankai 0.708; brawl untouched (0.561) |
| b2_a0 | 0.4954 (22/80) | the Bankai as a cycle: no cash-out, Hoho approach, AS read | bankai 0.747; cash-outs 1 -> 0 gave bankai +0.11 at 20 seeds |
| b3_a0 (parent) | 0.4106 (10/80) | antiwave rebuilt: reach-based plan, late Hoho + chase, route AS | antiwave 0.75 (24/32), strength untouched. It missed the AS read (its kk-move pressed J into her NS outside her route) |

- The three ~0.65 cells succeed through mechanisms that do not overlap: b0 in the sealed form, b1 in the Shikai / Bankai, b3 in the wave.
- Every cell found the same v0 bug: the plans ignored her NS. b3_a0's low strength was that bug, not its antiwave idea.
- So the first step here is a combination, which no earlier cell made. The new mechanisms come after it.
- **b0_a1 landed while I worked, rescored 0.8108 (68/80).**
  - What it added: b0_a0 + b3_a0's antiwave (the same graft as my v1, and the same rename), the flash-step reserve for the Hoho in
    (`*kk-hin-fs*` 200), and a back Step dodge when no Hoho is open (`:sdodge`).
  - Brawl 0.793, antiwave 0.75 (12/16).
  - It has none of b1's pieces and none of the far-wave answers. I added its two pieces as my last step (v7). Its `*kk-step-lead*` name
    clashed with mine, so mine is now `*kk-wave-step-lead*`.
- b1_a1 and b2_a1 had not delivered.

## Mechanism

### 1. The combination (each piece as its cell measured it)
- **b0_a0, the whole file:** `kk-pick` reach discipline and Hoho-in, `kk-ns-whiff`, the dodge, `kk-kikon-rule`, `*kk-as-read-p*`, climb / bankai 1.0.
- **b3_a0's 破月牙:**
  - `kk-wave-plan` by reach, `kk-close-hit`, `:chase`, `kk-route-as-p` (route AS as target 0 in `kk-move`).
  - Its `*kk-reach-margin*` 0.3 is renamed `*kk-wave-margin*`, because b0's neutral margin (0.5) already has that name.
- **b1_a0:**
  - the awakening as one roll a match;
  - `kk-l3-sa`;
  - the pointer policy as `*kk-kikon-ptr-p*`. On a red Ichigo, tap the hold unless the SP's pointer is 2, sealed or in the Shikai. This sits on top of b0's red-only rule.
- **b2_a0:** `*kk-bk-cashouts*` 1 -> 0.
- **A located interaction, fixed.** b1's awakening fired on the first free step with the gauge full and cleared `kks-plan`. That threw away a live wave answer, and b3_a0 had already logged one such failure: "a route during his awakening cinematic". Now the `:go` roll waits until no plan is open and her route is not live. It is still one roll a match; only the press moves.

### 2. 破月牙 from afar (`*kk-wave-far*` 12 m)
- **Diagnosis (logs of v2, 40 HARD matches).** Full Getsugas (150, knockdown) hit him **57 times**, mostly two to five in a row, and all from the same loop:
  1. her KESSA AS2's point-blank wave knocks him to about 8 m;
  2. she charges NS2 from 8–9 m, beyond the style's band (3.4–7 m);
  3. the generic CPU side-steps, then dashes in from beyond 7 m into JUJISHO.
- **The answer, the same one roll (`*kk-wave-p*`)** for routes seen beyond the band:
  - **Hoho at once.** A Hoho reappears 1.6 m behind her from any distance. Her charges are NS windows with no hit (F11 / F14 / F22), and from behind her JUJISHO's wave flies away from him. Then `:hit` presses the pointer's NS or J1 on her.
  - Without a Hoho: the Shikai / Bankai **J1 cut** (`:cut`, F28 / F32).
  - Sealed without a Hoho: mechanism 3.
- b3_a0's reverted 9.5 m band was a different answer, the late Hoho from far, with `:close` barred beyond 5.6 m.

### 3. 破月牙 without a Hoho: `:step` (`*kk-wave-step-lead*` 21, `*kk-wave-mix*` :step 1.0; sealed, Hoho not open)
- **Diagnosis (v4, 80 HARD matches).** 28 of the remaining 37 full waves came with no plan at all. In 19 of them his flash-step was 16–70, under a Hoho's 100, mostly after a Burst, and he was sealed (no cut).
- **The answer.**
  - A Step forward, pressed at JUJISHO + 21 frames at 5 m, plus 1 frame per 0.233 m farther (the wave's 14 m/s).
  - The wave's box is 1 m long (`*wave-box*` half-length 0.5). Closing at 14 m/s against his hop's ~12 m/s, it passes him in about 4–5 frames, inside the Step's invulnerable frames 3–9.
  - Then `:chase`.
- **`kk-step-j`.** On the Step's frame 10, J1 is pressed if she is in its reach, so the latch starts it at the Step's J cancel (frame 12) and he does not wait out all 24 frames.
  - In one v5 sample his J1 came out one frame after her next move started, and the antiwave situation was lost.
  - It is one press per Step (that one frame).

### 4. b0_a1's flash-step budget (v7)
- `*kk-hin-fs*` 200: the Hoho in only with a Hoho in reserve.
- `*kk-step-p*` / `*kk-step-lead*` 7 / `*kk-step-max*` 5 / `*kk-clone-strike*` 15: a back Step through her lunge or clones when no Hoho is
  open.
- Both are taken verbatim, credited to b0_a1.
- They feed 破月牙 too: the reserve keeps a Hoho open for the far Hoho and the late Hoho.
  - Full waves on him: v6 20 -> v7 7 in 80 HARD matches.
  - The far plans in v7: Hoho 21, cut 5, Step 5. The Step is needed less often, since FS is now spared.

Rules kept:
- One roll per event (her route, a match's awakening, an SP).
- SIM-RND01 only.
- She is read only through the SNAP and the perceived distance, plus her red bar, which b0 / b1 / `cai-sp` already read.
- EASY ≤ NORMAL ≤ HARD for every chance.
- The style registers only Kenpachi vs Ichigo.
- Host tests: 9843 checks, ALL PASS.

## Measurements (matchup-eval --side ken; seeds paired; each row adds to the one above)

| Variant | seeds | score | HARD | brawl | shikai | bankai | antiwave | NORMAL | full waves on him |
|---|---|---|---|---|---|---|---|---|---|
| parent b3_a0 (reproduced exactly) | 20 | 0.4048 | 5/40 | .565 | .700 | .373 | .727 (8/11) | .95 | |
| b0_a0's final (its own row, the same seeds) | 20 | 0.708 | 30/40 | .720 | .851 | .717 | .429 | .925 | |
| v1 = b0_a0 + b3_a0's 破月牙 | 20 | 0.7749 | 28/40 | .720 | .856 | .723 | 1.0 (6/6) | .875 | |
| v2 + b1's awakening once (not into her route), L3 SA, Kikon pointer gate | 20 | 0.8479 | 36/40 | .704 | .892 | .656 | 1.0 (5/5) | .925 | 57 |
| v3 + the far Hoho / cut | 20 | 0.8138 | 36/40 | .702 | .857 | .667 | .8 (4/5) | .925 | 18 |
| v4 + cash-outs 0 (b2) | 20 | 0.8352 | 36/40 | .702 | .939 | .694 | .833 (5/6) | .90 | |
| v4 | 40 | 0.7774 | 68/80 | .694 | .926 | .671 | .625 (5/8) | .925 | 36 |
| v5 + `:step` | 40 | 0.7566 | 70/80 | .690 | .921 | .671 | .429 (3/7) | .925 | 21 |
| v6 + `kk-step-j` | 40 | 0.7787 | 70/80 | .691 | .921 | .675 | .571 (4/7) | .925 | 20 |
| **v7 + b0_a1's FS reserve and back Step (final)** | 40 | **0.8763** | **79/80** | **.812** | .907 | .615 | **.875 (7/8)** | .9125 | **7** |

- **Seeds.** v1–v4 were compared at 20 seeds a seat (the user's rule), paired.
  - v4 onward were compared at 40, still paired (seeds 1–40). At 20 seeds antiwave opened only about 5 times, so one flip moved the
    score 0.03.
  - The per-variant logs came from a scratch wrapper that only saves each job's stdout. `tools/matchup-eval.py` was imported, not
    edited.
  - The final JSON is a direct EVAL_COMMAND run.
- **v3 / v5's score dips are antiwave single situations.** With 5–8 situations, one flip moves the rate 0.13–0.2, which is 0.02–0.03 of score. The mechanisms were judged in the logs:
  - Full waves on him (both seats, HARD): 57 -> 18 at 20 seeds; 36 -> 21 -> 20 at 40.
  - Every `:step` pressed dodged the wave: 24 of 24 in v5's 80 HARD matches, 22 of 22 in v6's, 9 of 9 in v7's.
  - Wave plans in v6's 80 HARD matches:
    - in the band: CLOSE 61, LATE 6, CUT 2, STEP 10;
    - from afar: CLOSE (the Hoho) 30, CUT 25, STEP 12.
- **Final file (v7), 40 seeds a seat (score.json): score 0.8763.**
  - Strength 0.9875 (HARD 79/80). Signature 0.8022: brawl 0.812, shikai 0.907, bankai 0.615, antiwave 0.875 (7/8).
  - NORMAL 0.9125, factor 1. Baseline NORMAL 0.9625; parent 0.9375.
  - Against the round's best rescored, b0_a1's 0.8108, on the same seeds: +0.066.
  - Bankai fell 0.675 -> 0.615, with 174 situations against 209. Matches end sooner, and more of them end with the Bankai's own exit string
    KOing her (see risks).

## The antiwave failures left (v4–v6 logs, 40 seeds; v7 has 1 of 8), disclosed
- **The Bankai's Reishi cost (two of three failures in v4, the same ones in v5 / v6).** In both cases he hit her (ZANKAI's NS a–d, 420; KYORAN J1 + AS1, 150), and her wave never touched him. The situation still closed occ:
  - `situ.lisp` sets "the wave hit him" on any Reishi drop of his while she is in IC-N2C (or her wave is alive);
  - a Bankai NS / AS segment costs 40 Reishi, and the first one fell on her JUJISHO's start frame.
  - b3_a0 disclosed this interaction. I did not add a rule to dodge the detector: in game terms these were his best outcomes. The coordinator may want it noted for the evaluator's next freeze.
- **One sample: a Hoho then the Shikai NS2a whiffed during her blue Burst.** It is not systematic.
- **Antiwave opens only 7–8 times in 40 seeds a seat** (b0 had 15, b3_a0 32). The sealed brawl and the Bankai keep her from shooting at 3.6–6.6 m. Her own shots come from ≥ 7.5 m, which the far answers handle but the theme does not count. Expect ±0.15 on its rate between runs.

## Why it is not a repeat
- **No earlier cell combined b1's pieces with b0's and b3's.** b0_a1 made the b0 + b3 graft. This file adds b1's pieces, b2's cash-out
  value and b0_a1's budget on top.
- **The first cell to combine these pieces this way.** b0 named "b0 + b1" as the next step. Here b3's 破月牙 is added and the interaction it creates is fixed: the awakening that cleared the wave plan.
- **New mechanisms:**
  - the far-route answer, the Hoho at once from beyond the band, a different answer from b3_a0's reverted far late Hoho;
  - the Step forward timed through the wave, the first answer for a sealed Kenpachi without a Hoho;
  - J1 out of the Step's J cancel.
- These are measured by what the wave did to him, not only by the noisy theme rate.

## Expected benefit and risks
- **Expected:** about 0.85–0.88 against her v0.
  - Strength is near its ceiling (79/80). Brawl is at b0_a1's level, shikai at b1's.
  - Full Getsugas on him fall from 57 in 40 matches (v2, 20 seeds) to 7 in 80 (v7, 40 seeds).
- **Risks:**
  - **The Step through the wave depends on the hurt radius and the wave box.** The timing has a 3–4 frame window, and every one of 55 pressed (v5–v7) dodged. A press up to 3 frames late is still allowed (the shared `:cut` / `:late` window). If the wave box or the Step's iframes change, `*kk-wave-step-lead*` needs re-timing.
  - **A smarter Ichigo could punish the reappear point** of the far Hoho, or stop shooting from 8 m. The far answers matter only while she does.
  - **NORMAL** was 0.875 in v1's 20-seed run (band floor 0.863) and 0.90–0.925 in every later run. The NORMAL chances are b0's / b1's (reach 0.3, Kikon pointer 0.5, wave 0.15, ...).
  - **Brawl** is 0.81 with b0_a1's budget; it was 0.69 without it. The awakening at once means fewer, harder sealed exchanges.
  - **Bankai (0.62–0.69):** most failures are matches won by the Bankai's own exit string (TATE-GOTO's Soul Break KOs her before he is back in the Shikai), so the situation stays open at the match end.
