# b3a2 + b2a2 (round 1, §25.15 freeze 3686d94): the combined candidate the user chose

b3a2's file (三味・空蝉 SANMI-UTSUSEMI: UTSUSEMI, b2a1's 絞首 KOSHU ported onto b3a0's ledger, the waking noose off) with
b2a2's own changes over its parent b2a1 laid on top (縛口 SHIBARI-GUCHI, the bind's bite; SANGE 0.5 at HARD; b3a1's RAIDEN
ender fix). Everything is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's `HISAGI-CPU-TESTS` section.

## The result in one table

| | b3a2 | b2a2 | **b3a2 + b2a2 (this file)** |
|---|---|---|---|
| aieval, 40 seeds (rescored) | 0.8281 | 0.8325 | **0.8239** |
| strength (HARD, 480) | 0.623 | 0.598 | **0.608** |
| masher | 1.000 | 0.996 | **1.000** |
| signature | 0.882 | 0.908 | **0.883** |
| NORMAL share (factor) | 0.5083 (1) | 0.5083 (1) | **0.5125 (1)**: Y 51, K 25, R 31, I 46, S 63, Lille 30 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 114.2-172.4 s | 109.7-167.8 s | **111.7-174.7 s** (Rukia 174.7) |
| **960 HARD, seeds 1-80** wins / signature / 0.3 s + 0.5 g | 610 / 0.884 / 0.6324 | 561 / 0.907 / 0.6290 | **596 / 0.884 / 0.6282** |
| 2880 HARD, seeds 1-240 | 1789 / 0.884 / 0.6283 | 1638 / 0.909 / 0.6250 | **1759 / 0.885 / 0.6256** |

`score.json` is the final evaluator line of this file (`python3 tools/aieval.py --char 7 --seeds 40 -j 2`, the native build
rebuilt from this file first).

**Verdict:** the merge works as built (the bite fires in 268 of 285 binds, his first hit in a bind 279 of 285, drained 166 ->
197 of the same ~285 binds), but it **does not beat b3a2**: -14 HARD wins of 960 (-30 of 2880, paired), all in matches with
a bind, mostly Rukia and Ichigo. Against b2a2 it wins more (+35 of 960, +121 of 2880) for 0.02-0.025 less signature, so the
proxy lands between the two on 2880 matches and a hair under both on the 960 (0.6282 vs 0.6290). No located bug was found
(below), so nothing was tuned. The 40-seed score (0.8239) is below both parents.

## Step 1: the merge

`git merge-file` with b3a2/hisagi.lisp as current, b2a1/hisagi.lisp as base, b2a2/hisagi.lisp as other: b2a2's diff over
b2a1 (62 changed lines) onto b3a2. Five conflicts, all resolved by keeping b3a2's structure and adding b2a2's bite:

| # | where | b3a2 side | b2a2 side | resolution |
|---|---|---|---|---|
| 1 | the bind's knobs | (b3a2 ported KOSHU's knobs `*HS-AI-B-ROUTE-P*` / `-CLOSE-P*` / `-TODOME-P*`, `*HS-AI-R-GUARD-WAIT-P*` elsewhere; no b2a0 bind plans) | b2a0's `*HS-AI-FREE-POOL*`, `-FREE-NEAR*`, `*HS-AI-BIND-PLANS*`, `-HANG-*`, `-SETTLE-POOL*`, KOSHU's knobs + the new `*HS-AI-BITE-P*` (0 / 0.5 / 1.0), `*HS-AI-BITE-WINDOW*` 40 | b3a2's, plus only the two bite knobs |
| 2 | the ranged styles | b1a0's route styles SENTAN / NAWAJI / KAISEN (`*HS-AI-R-STYLE-W*`) | b2a0's SANGE / SOKUBAKU with `*HS-AI-SANGE-P*` HARD 0.2 -> 0.5 | b3a2's (see "SANGE" below) |
| 3 | the HSS CPU slots | `ai-wake`, `ai-wake-t` (b3a0's waking noose) | `ai-bplan`, `ai-bplan-from` (b2a0's bind plan) + `ai-bite-from` | b3a2's + `ai-bite-from` (never hashed) |
| 4 | HS-AI-ENDER's docstring | b3a1's RAIDEN fix (its own text) | the same fix, ported by b2a2 | b3a2's; the code merged cleanly and is identical |
| 5 | HS-B-AI-REFLEX's release | b3a0's ledger (HS-REL-BAR, KAIBAKU-GEKI within reach, else the plain FREE) | b2a0's plan-based release (HS-RELEASE-DUE-P, HS-DRAIN-MARGIN) + the bite's call | b3a2's ledger, then b2a2's `(hs-b-ai-bite e b s)` call after it (as in b2a2: after the release, before the anti-Breaker / guard wait) |

Merged cleanly (no conflict): HS-B-BITE-CMD (pure) and HS-B-AI-BITE, the KOJO band held for the bite's window
(`(>= (- *match-tick* (hss-bind-from st)) *hs-ai-bite-window*)`), and the ender's code. Everything the bite calls exists in
b3a2 (HS-ROLL, `hss-bind-from`, `snap-left-seen`, FIGHTER-GC-LEFT, `:hs-b-j1`). b3a2's KOSHU port (HS-B-AI-MOVE as the bind
kit's `:move-reflex`, the walk-in, the bands) is kept as b3a2 wrote it; the bite sits on top.

**SANGE 0.5 at HARD is not in this file.** b2a2's knob re-weights b2a0's two ranged styles (SANGE / SOKUBAKU); b3a2's ranged
mode has b1a0's three route styles instead and no `*HS-AI-SANGE-P*`. The nearest analogue would be raising KAISEN (the J1-tip
spread route, the Reiatsu wheel) at HARD, but `*HS-AI-R-STYLE-W*` is one weight set for every difficulty, so that is a new
knob and a tuning choice, not a merge; left for the user (see Risks).

**Tests:** the HISAGI-CPU-TESTS section's three-way merge conflicted as a whole (b2a1's and b3a2's sections are different
structures), so the section is b3a2's plus b2a2's one new check (the bite's chance and window, HS-B-BITE-CMD's contract),
de-indented to top level. b2a2's SANGE pin is not taken (no SANGE). Spliced into the frozen file with `splice-tests.py
<merged> tests/duel-rules-test.lisp /dev/null`; the delivered file differs from b3a2's delivered test only by that check.

## Step 2: checks

- Host tests: duel-rules **9878 checks ALL PASS** (b3a2's 9877 + the bite's 1); control 89, learn 131, input 33, cine 18 ALL
  PASS; touch 64, 0 failures.
- `tools/pkgcheck.sh duel`: clean (0 / 0 / 0).
- **Awaken A/B** (`python3 tools/simgate.py --pairs 28,29,30,31,32,34 --seed0 100 --seeds 60 --cmd 39020 -j 2`; the
  never-awaken side's wins of 60, this file / b3a2's / b2a2's):

| seed0 | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 38 / 38 / 38 | 24 / 24 / 24 | 35 / 35 / 35 | 28 / 28 / 28 | 53 / 53 / 53 | 30 / 30 / 30 |

  Every row >= 24 of 60: passes (bar 20). All 360 K.O.; NORMAL medians 102.8-150.0 s. Identical to both parents (the
  never-awaken side is b3a1's NORMAL Shikai in all three files), so streams 300 / 500 are b3a1's by construction (HK 23 the
  lowest).

## Step 3: the 960-match comparison (and 1920 more)

As b2a2 / b3a2 measured: HARD, seeds 1-80, both seats, aieval's strength jobs with the combat log
(`tools/simgate/run-log.lisp`), one native build per file; signature by aieval's classifier (`hisagi_class`). The Shikai
plays the same matches to the frame in all three files (identical Shikai time and rates: 120.3 s a match, 35.3 dealt / 20.8
taken a second for b3a2 and this file; UTSUSEMI 2761 times in both), so the differences are the Bankai's.

| 960 HARD (seeds 1-80) | wins | sig | proxy | Y | K | R | I | S | Lille | binds | drained | his first hit in a bind | bind dealt / taken a s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b3a2 | **610** | 0.884 | **0.6324** | 137 | 57 | 152 | 105 | 157 | 2 | 286 | 166 | 246 | 43.3 / 23.3 |
| b2a2 | 561 | **0.907** | 0.6290 | 137 | 52 | 143 | 71 | 156 | 2 | 626 | 478 | 601 | 46.6 / 20.4 |
| **this file** | 596 | 0.884 | 0.6282 | 138 | 56 | 142 | 99 | 159 | 2 | 285 | 197 | 279 | **48.2 / 21.0** |

(b3a2's and b2a2's rows reproduce their proposals' numbers to the match.)

Because the merge came out under both on the 960's proxy, the same comparison was run on seeds 81-160 and 161-240:

| HARD wins of 960 | seeds 1-80 | 81-160 | 161-240 | 2880 | proxy (2880) |
|---|---|---|---|---|---|
| b3a2 | 610 | 593 | 586 | **1789** (0.621) | **0.6283** |
| b2a2 | 561 | 538 | 539 | 1638 (0.569) | 0.6250 |
| this file | 596 | 573 | 590 | 1759 (0.611) | 0.6256 |

Per opponent over 2880 (of 480): this file / b3a2 / b2a2: Yamamoto 417 / 415 / 396, Kenpachi 165 / 170 / 139, **Rukia
434 / 452 / 411**, **Ichigo 271 / 283 / 226**, Senjumaru 469 / 465 / 464, Lille 3 / 4 / 2.

### Why the merge trails b3a2 (looked for, not located)

- **Paired:** no match without a bind differs (1409 + 774 identical). In the 697 matches with a bind, b3a2 alone wins 83,
  this file alone 53 (2880 matches; about 2.6 standard errors). Rukia accounts for 18 of the 30, Ichigo for 12.
- **The bind itself is better with the bite**, as b2a2 measured: over 2880, the bind 43.9 / 21.7 -> 49.4 / 20.7 dealt / taken
  a second, drained 516 -> 570 of ~850 binds, the opponent's first hit in a bind 40 -> 6 (of 286 / 285, seeds 1-80); the
  early KOJO opener (b3a2: 80 binds, the opponent's first hit 23) is gone.
- **Not an interaction with UTSUSEMI:** UTSUSEMI is the Shikai's `:reflex` (HS-AI-REFLEX) only; after a bind he is in the
  ranged mode, and the Shikai's numbers and UTSUSEMI's count are identical in both files.
- **Not the bite's code:** traced binds show it as designed (J1 at f22, lands f30 inside the reel, J1 -> K2s -> K3, the rain
  when ahead). The `:wait` only holds while the reel fits and he is out of reach; a Burst ends the reel and the bite returns
  NIL.
- **Where the loss shows:** after the bind. Against Rukia (320 matches, seeds 1-160) the ranged mode after a bind deals 17.4 -> 15.7 and
  takes 17.2 -> 18.6 a second; flips follow the post-bind exchanges (her freeze strings, Bursts), with no single repeated
  cause. The opponent's Kikons on him inside binds are as many as before (151 / 157); in both files most follow his KOJO (71 /
  65) — a b2a1 / b3a2 knob, not the merge's. Released binds he was ahead in on the net (damage + 1300 a Konpaku) rose 39 -> 82 of 335 / 280 (the ledger
  releasing on the grey margin after the opponent's Kikon on him), which is b3a0's ledger reading a race the bite now makes
  closer to the drain; changing it is tuning.
- So by the brief's rule nothing was changed: the file is the plain merge.

## Expected benefit and risks

**Benefit:** the user's 「捆綁」 reads clearly: the noose closes and the short sickle is in at once (his first hit in 98 % of
binds), the drain share rises (0.61 -> 0.67 of binds, 2880 matches), the bind is his best form a second; the Shikai and its UTSUSEMI are b3a2's.

**Risks:**
- **It is weaker than b3a2 at HARD** (-30 of 2880, paired; Rukia / Ichigo) and scores 0.8239 on 40 seeds (b3a2 0.8281, b2a2
  0.8325). If the user wants the strongest CPU, b3a2 alone is it; if the bind's look is the point, this file shows it more.
- **SANGE 0.5 was not carried** (no SANGE in b3a2's ranged mode); a HARD-only KAISEN weight would be its analogue.
- **NORMAL:** the bite's NORMAL chance 0.5 acts in b3a2's lineage (NORMAL's noose 0.05), so NORMAL's share moved 0.5083 ->
  0.5125, in band. Pacing: Rukia's NORMAL median 174.7 s (cap 220).
- Lille stays 0-1 of 160 at HARD, as in every cell.
