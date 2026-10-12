# Cell b0a0 (round 2): "the marksman's line" — the charged L aimed after R18, the charge's Step as the re-aim

Freeze 2eaf8b9, a new direction from `baseline-r02` (the integrated b1a2 on R18's rules). Only `duel/lisp/barro.lisp` (his
CPU parts: two new BRS slots for CPU state, the CPU branch of the charge's hold phase via BR-AI-CHARGE-TICK, new BR-AI-AIM-*
functions and knobs, BR-AI-CHARGE-P's floor, `*BR-AI-DIFF*` NORMAL) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed. Host test 8358 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0. Final measure
(`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte, measured last):

| | baseline-r02 (re-measured here: the same JSON) | v1 (the aim) | **b0a0 = v4 (delivered)** |
|---|---|---|---|
| score | 0.9102 | 0.9696 | **0.9696** |
| strength (HARD, both seats) | 0.853 | 0.993 | **0.993** |
| masher | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.932 | **0.932** |
| NORMAL share (band 0.30–0.60) | 0.36 (Y 45, K 12, R 37, I 23, S 27 of 80) | 0.355 | **0.4325** (Y 41, K 15, R 53, I 32, S 32 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 124.2 142.9 139.4 159.3 155.7 | **134.1 127.2 152.6 163.4 147.7** |

sig_by (final): br-e-k 0.239, br-e-kl 0.144, br-oe-k 0.098, br-k-hiren 0.088, charged 0.084, br-rc 0.083, **br-s-l1- 0.067**
(the base snipe's level 2 / 3: 0.024 in the baseline), plain-jk 0.061 (0.067), br-oe-kl 0.059, br-s-j 0.024; outside the
whitelist besides plain-jk only counter 0.004 and the cuts / level-1 dash 0.001 each.

## History read (every proposal, score.json and score.rescored.json; the rescored numbers trusted, round 1's as mechanisms only)

- **round 1** (pre-R18 freeze 36e93c7): b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up),
  b1a0 0.6985 (routes on events; its gap the missing turn), b2a0 0.915 (the opponent's reach envelope, the Kikon on openings,
  the snipe let-go fix), b3a0 0.9192 (the clock, the wings as armour first), b0a1 0.952 (b2a0 + b3a0's reserve + the wake-up
  shot), b1a1 0.9529 (the Step-in interrupt, the stance exit, the let-go per charge), b0a2 0.9549 (the burst kept for the owl;
  three located dead ends: the dash's J1 bridge forced by frame data, "bare: back out first" a selection bias, NORMAL's
  ±0.05 RNG noise), b1a2 0.9716 (every link into the stance, the pips cashed from range). b2a1 / b3a1 never ran.
- **baseline-r02** (0.9102): b1a2 merged onto R18. Its proposal names the cause of the fall: the snipe that used to snap onto
  a side-stepping opponent. No round-1 cell had to aim: before R18 every charged L turned onto him at its release.
- Round 2's sibling b1a0 runs in parallel (no proposal yet).

So this cell does not tune a round-1 mechanism: it answers the rule that changed. **Diagnosis first** (the combat log as
aieval runs it, HARD, 4 seeds x 5 opponents x both seats = 40 matches, a scratch parser): 36 / 40 wins (Kenpachi 7/8, Ichigo
5/8); the base form dealt 32.8 k and took 41.4 k; **of 407 level-2 snipes 159 whiffed, 108 of them punished**, 75 of those
whiffs right after the opponent's **Hoho** (he reappears 1.6 m BEHIND Lille at its f6, facing him: the rooted charge can't
turn, the shot goes forward into nothing, his J1 PUNISH and a full string follow, ~250 a time); the snipe (L1-2 / L1 / L1-3)
was the opener on the base form 109 times of 163; the awakened dash (FAR-DASH) whiffed 360 of ~780 times, 101 punished, and
was the most common opener on JILLIEL EN (70).

## The action policy (行動方針)

All of b1a2's routes (see its proposal and baseline-r02's) stay. On top, one new mechanism and a fair NORMAL:

**1. The marksman's line** (`BR-AI-AIM-TICK`, pure core `BR-AI-AIM-PLAN` / `BR-AI-AIM-GAP`; called from BR-AI-CHARGE-TICK, the
CPU branch of BR-S-TICK's `:hold` phase, every charge of the base snipe and the awakened dash; one roll a charge,
`*BR-AI-AIM-P*` 0.2 / 0.6 / 1.0, with the let-go's). Every frame of the charge his CPU reads the shot's line (the level-2 / 3
snipe's capsule via X-LINE-GAP; the dash's sweep: from him to its length by the distance + 0.9 m, 0.7 m wide) against where
it predicts the opponent at the hit (the perceived SNAP + his perceived velocity x (perception delay + 1 + the shot's
startup), at most 30 f):
- **his Hoho perceived** (he is behind the charge now: HARD's 8 f delay is past the Hoho's f6 reappearance) → the charge's
  own Step at once (R18's: the stance's fast Step 飛廉脚 / EN's, iframes f0–7, 10 flash step, once a stance;
  BR-CHARGE-STEP-GO): it slides 5 m away from where he now stands, keeps the charge and snaps the aim onto him at its f9;
- **him predicted off the line at the planned release** (level ≥ 2) → the same Step, when the shot still reaches him from 5 m
  farther (the snipe's level 3 always; level 2 within 12 m; the dash within its level's longest);
- **back from that Step** (aimed by the sim at his real position, better than the perceived guess) → let go at once at
  level 2 / 3;
- **off the line with no Step left** → hold on (one frame at a time) for him to cross the line, to 3 f before the cap: a
  level-2 plan carried on becomes the 31 m level-3 萬物貫通 line (level-3 snipes 96 → 202 in the diagnosis set).
  The press is extended through the Step so the level is kept (≥ 20 f held after it).
- The let-go (his attack in reach) keeps priority; the learner's `:charge` read and BR-AI-RESTEP are unchanged (a read Step
  re-aims first; the aim's Step then finds it spent).

**2. The charge as his style at every difficulty** (`*BR-AI-CHARGE-FLOOR*` 0.3 / 0.6 / 1.0, in BR-AI-CHARGE-P): the chance an
L is charged is at least this, over `:stance :charge` x `*BR-AI-DIFF*`. NORMAL charged 0.21 of its L's and tapped the rest:
level-1 snipes (4 m, 16 f wind-up: 32 whiffs of 51 in 24 NORMAL matches vs Kenpachi / Ichigo). HARD unchanged (1.0).

**3. A fair NORMAL on R18's rules**: `*BR-AI-DIFF*` NORMAL 0.3 → 0.4 (b1a1 set 0.3 when NORMAL ran at 0.54–0.71 before R18;
R18 took it to 0.36). EASY / HARD unchanged.

Per form: **base** — the far snipe from ≥ 4.5 m (b1a2), now aimed: a Hoho behind the charge meets the 飛廉脚 and a re-aimed
shot from 6.6 m, a sidestep off the line meets the Step or a held level-3 line; the cash-out HIRENKYAKU at the pips' cap,
the gun-kata / rifle confirms (b1a2). **KIN / the owl KIN** — b1a2's (kite, exit, Step-in J1, the turn-wait, the R17 link,
the burst), the far dash aimed. **EN / the owl EN** — the window plan; its dash aimed, its fast Step kept for the re-aim when
unspent.

Difficulty: every new chance a table EASY ≤ NORMAL ≤ HARD (host-checked); the aim and the charge floor rolled once a charge /
press; the aim's per-frame calls are reactions of an aiming charge (no roll per step). Randomness only SIM-RND01; the
opponent only through the perceived SNAP (+ the ring's previous SNAP for his velocity); his own position / facing / flash step
/ the charge's frames are his own state.

Kept working: AI-AWAKEN-P / `:awaken` and the burst untouched; every debug / test command; the `duel barro` counters (new:
`ai-aim-step`, `ai-aim-fire`, `ai-aim-hold`; the existing `snipe-step` / `snipe-back` now also count the CPU's aim Steps);
the learner (BR-LEARN-* untouched; no new reflex; the aim runs only inside his own charge); the ASSIST (no hook it calls
changed: the aim lives in BR-S-TICK's CPU branch under BR-TICK-BRAIN, never for a human; BR-AI-SIG-HOLD reads the brain
through AI-BRAIN as before, the assist's brain is HARD, so the floor changes nothing there). New BRS slots: `ai-aim`,
`ai-aimed` (`ai-charge-key` -1 marks a charge back from its Step: its rolls kept).

## The steps measured

| step | change | score | str | mash | sig | NORMAL (40 seeds, both seats) |
|---|---|---|---|---|---|---|
| baseline-r02 | re-measured | 0.9102 | 0.853 | 1.0 | 0.923 | 0.36 |
| v1 | the aim (`*BR-AI-AIM-P*` 0.1 / 0.3 / 1.0) | 0.9696 | 0.993 | 1.0 | 0.932 | 0.355 |
| v2 | aim NORMAL 0.6 (NORMAL-only run) | | | | | 0.3675 |
| v3 | + the charge floor (NORMAL-only) | | | | | 0.385 |
| **v4** | **+ `*BR-AI-DIFF*` NORMAL 0.4 (delivered, full run)** | **0.9696** | 0.993 | 1.0 | 0.932 | **0.4325** |

v2–v4 change NORMAL / EASY only (the HARD rolls draw the same numbers): v4's HARD / masher / signature equal v1's to the digit.

Diagnosis set (40 HARD matches, baseline → v1): wins 36 → 40 / 40; level-2 snipes 407 → 465, whiffed 159 → 62 (punished 108
→ 47), hit 121 → 233; level-3 lines 96 → 202; the base form dealt / taken 32.8 k / 41.4 k → 48.3 k / 32.7 k; JILLIEL EN taken
17.6 k → 11.0 k; the far dash's punished whiffs 101 → 50; the snipe as the opener on him 109 → 75 (L1-2 alone 75 → 33).
The aim per 40 matches: 330 Steps (each a `snipe-step` / `snipe-back`), 260 shots let go at once after them, ~2200 frames held
for the line.

## Why it is not a repeat

No earlier cell aimed: every round-1 cell ran before R18, when the charged L snapped onto the opponent at its release, so the
aim was free. The mechanism is new on two counts: the CPU models the shot's own geometry (its line / sweep from his facing)
against the opponent's predicted position at the hit, and it uses R18's new charge Step (its re-aim) as the answer, including
to the Hoho behind a rooted charge, the one opponent action that made the R18 snipe a gift. The charge floor and NORMAL's
`*BR-AI-DIFF*` are calibration, taken because R18 moved NORMAL, and measured separately.

## Awaken A/B (informational: the awakening and the burst are untouched; the base form's charges now aim)

Not required (AI-AWAKEN-P, `:awaken`, BARRO-TICK and BR-AI-BURST-P untouched); one stream run for the record, since the
never-awakened base form is round 2's named open problem: `python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 100
--seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille II, NORMAL) wins of 60, all 300 matches K.O. (medians
133.6–157.5 s):

| seed0 100 | BY | BK | BR | BI | BS |
|---|---|---|---|---|---|
| b0a0 | 13 | 0 | 1 | 1 | 2 |
| b1a2 at round 1's freeze (pre-R18, its proposal) | 13 | 1 | 1 | 1 | 1 |

Unchanged and far under 20: the aim restores what R18 took from his NORMAL base form, but it never won those pairings
before R18 either; the base form alone at NORMAL is not a match for awakening opponents. The streams 300 / 500 were not run.

## Expected benefit, risks

- Benefit: strength 0.853 → 0.993 (Kenpachi and Ichigo the gainers), signature 0.923 → 0.932 (the base snipe's level 2 / 3
  0.024 → 0.067), NORMAL 0.36 → 0.4325 (mid-band, 0.13 above the floor: the 40-seed ±0.05 noise b0a2 measured no longer
  threatens it).
- Pacing: medians 127.2–163.4 s, ≥ 56 s under the 220 cap (no risk).
- The aim Step spends the stance's one fast Step and 10 flash step: a charge stepped for its aim has none left to dodge
  with afterwards (the stance ends after the shot anyway). The CPU now hardly ever fires a level-2 snipe into empty space;
  a human who Hohos behind the charge meets the 飛廉脚's iframes and a re-aimed shot from 6.6 m — the counter to that Hoho
  is now a second read (the Step is spent: a second Hoho or a sidestep after it).
- Holding for the line makes him stand rooted longer (to 57 f) when there is no Step: a human can walk in on the held charge;
  the let-go still fires on his attack in reach.
- NORMAL's `*BR-AI-DIFF*` 0.4 scales every kit chance; NORMAL vs Rukia rose to 53/80 (the band's top row), vs Kenpachi
  15/80 stays the low row.
- The learner's `:charge` read (a Step / backing off → BR-AI-RESTEP) still re-aims first; the aim adds the same Step for
  every CPU charge, so a human's read of "the Step after my Hoho" is learnable later.

## Shared-code recommendations (not done)

- ai.lisp: the generic threat reflexes treat a rooted :hold charge as a target for a Hoho behind it; a kit key telling the
  opponents' CPUs a charge can re-aim (its Step) is not needed now (his CPU answers it), but the human manual could mention
  the Step in the charge as the answer to a Hoho.
- Every round-1 recommendation stands (STRING-REFLEX's `:l-after-*` by difficulty; a generic Step-in reflex; kit keys for the
  guard-break and the neutral Kikon).
