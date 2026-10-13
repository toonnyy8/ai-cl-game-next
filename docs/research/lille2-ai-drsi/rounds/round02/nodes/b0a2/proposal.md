# Cell b0a2 (round 2, refines b0a1): "the marksman who never lunges at air" — no follow-up after his own push, every shot reaches, no long guard for a Breaker

Freeze 2eaf8b9. Parent b0a1 ("the marksman squares up": b0a0's aim + the facing + the burst kept for the owl): its
`barro.lisp` copied, its BARRO-CPU-TESTS section spliced in. Only `duel/lisp/barro.lisp` (his CPU parts: every form's `:ai`
gets `:neutral-guard`; one BRS slot of CPU state; BR-S-CPU-CALL records a pushing string end; new BR-AI-PUSHED(-P), the
floor functions BR-AI-FLOOR-LEVEL / -PLAN-LEVEL / -SNIPE-FLOOR / -DASH-FLOOR and `*BR-AI-PUSHED-FOR*` / `*BR-AI-DASH-FLOOR*`
in the AI section; the three charge-level call sites (BR-AI-KAMAE, BR-AI-SIG-HOLD, the CPU branch of BR-TO-EN-LINK-TICK);
`*BR-AI-DIFF*` NORMAL) and the `BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed. Host test 8391 checks ALL
PASS (the section spliced into the frozen file with `splice-tests.py`: byte-identical to the delivered test);
`tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte):

| | baseline-r02 | b0a1 (parent, rescored) | v3 | v4 | **b0a2 (delivered, v5)** |
|---|---|---|---|---|---|
| score | 0.9102 | 0.9724 | 0.97 | 0.9658 | **0.97** |
| strength (HARD, both seats) | 0.853 | 0.998 | 0.995 | 0.985 | **0.995** (398 / 400) |
| masher | 1.0 | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.933 | 0.93 | 0.93 | **0.93** |
| NORMAL share (band 0.30–0.60) | 0.36 | 0.4175 | 0.505 | 0.4375 | **0.49** |
| NORMAL by opponent Y K R I S (of 80) | 45 12 37 23 27 | 48 14 36 28 41 | 44 25 46 39 48 | 42 21 41 36 35 | **46 27 44 39 40** |
| pacing medians Y K R I S (cap 220, all 40 / 40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 130.2 130.4 160.3 160.3 153.0 | 124.2 128.5 149.1 160.3 163.7 | 125.7 130.7 162.1 160.8 161.1 | **123.8 128.6 152.6 160.1 167.9** |

v3 and v5 differ only in a NORMAL-only knob (the anti-Breaker NORMAL 0.4 / 0.3): their HARD and masher runs are the same
matches, to the digit. sig_by (final): br-e-k 0.258, br-e-kl 0.143, br-k-hiren 0.092, br-oe-k 0.087, charged 0.081, br-rc
0.075, br-s-l1- 0.070, plain-jk 0.061, br-oe-kl 0.049, br-w-nijushi-c 0.022, br-s-j 0.021; outside the whitelist besides
plain-jk: counter 0.005, the cuts 0.002, the level-1 dash 0.001.

**Honest summary**: the score is 0.0024 under the parent's, inside the evaluator's chaos (one HARD match of 400 and 0.003 of
signature; the parent's own lineage measured strength 0.985–0.998 for changes that hardly touch HARD, and v4 here, whose
HARD differs from v5's only by the neutral guard, measured 0.985). What the cell moves is the round's two named open problems
on NORMAL: **Kenpachi 14 → 27 of 80** (the parent's worst row, now the best Kenpachi of the search), the five rows' spread
14–48 → 27–46, the share 0.4175 → 0.49 (the band's middle third), from three located causes, not from a chance raised.

## History read (every proposal, score.json and score.rescored.json; round 1's numbers pre-R18: mechanisms only)

- **round 1** (freeze 36e93c7): b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up),
  b1a0 0.6985 (routes on events; its gap the missing turn), b2a0 0.915 (the reach envelope / kite, the Kikon on openings,
  the unguard), b3a0 0.9192 (the clock, the wings as armour), b0a1 0.952 (b2a0 + b3a0's reserve + the wake-up shot), b1a1
  0.9529 (the Step-in interrupt, the stance exit, the let-go), b0a2 0.9549 (the burst kept for the owl; located dead ends:
  the dash's J1 bridge forced by frame data, "bare: back out first" a selection bias, NORMAL's ±0.05 noise), b1a2 0.9716
  (every link into the stance, the pips cashed from range).
- **baseline-r02** 0.9102 (b1a2 on R18: the charged L no longer snaps onto him).
- **round 2**: b0a0 0.9696 (the aim: the charge's Step as its re-aim, the charge floor, NORMAL x0.4), b1a0 0.9607 (the line:
  release when he is on it; the envelope; the facing), **b0a1 0.9724** (my parent: the facing on the aim + the kept burst),
  b1a1 0.9645 (the line's length = the reach floor for every shot; the base form backed off to 6.5 m; NORMAL recalibrated,
  Kenpachi 19 / 80). The shared weak spots: Kenpachi at NORMAL (11–19 / 80), the never-awakened base form (the A/B), the
  signature's ~0.94 ceiling from the forced follow-up J1 after the dash.

## Diagnosis of the parent (combat logs as aieval runs them; scratch parsers)

HARD (seeds 1–6 x 5 opponents x both seats, 60 matches): 60 / 60; signature 0.936. His plain damage: the KIN / the owl's J1
FOLLOW-UP after the dash 2.95 % + 0.88 % (forced: b0a2 round 1, b0a1), the base's STEP-IN / STEP-J J1 0.43 / 0.42 %, counters
0.25 %, the rest under 0.15 % each. Nothing removable without a strength trade the history already measured as negative.

NORMAL (seeds 1–8, 80 matches): 32 / 80 (Kenpachi 2 / 16). Dealt / taken by form: JILLIEL KIN 38 k / 157 k, the base 47 k /
96 k, the owl KIN 12 k / 30 k, against JILLIEL EN 128 k / 12 k and the owl EN 38 k / 0.5 k: NORMAL loses in its attack states,
almost all of it to openers on an "idle" Lille (no move of his in the 60 f before). Three causes located in the logs:

1. **The follow-up after his own push.** Every stance string's last segment that hits pushes him out of its opener's reach
   (BR-S-END-PUSH, R12). ai.lisp's generic follow-up then presses J1 on the reeling opponent (his perceived distance is a
   perception delay old, from before the push): **405 KIN J1s after the stance K3, 403 whiffed, 44 punished; 156 base J1s
   after the gun-kata's J3, all whiffed; ~700 whiffed follow-ups in 80 matches.** HARD's exit reflex (1.0) runs first in
   KIN; NORMAL's (0.15) almost never, and the base form has none.
2. **The tap out of reach.** A failed `:charge` roll (NORMAL 40 %) is a tap: the level-1 snipe (4 m, S 16) from the far
   window's 4.5 m+: 283 snipe charges, ~85 released at level 1, 22 hits. (b1a1 located the same in b1a0's NORMAL.)
3. **The Breaker on his guard.** In 100 NORMAL matches with him P1 (this cell's code before the guard change), the opponents
   threw **725 Breakers at him, 523 of them their generic Breaker-a-guard (a guard of his held 24 f within 3 m), 408
   landed** (4.1 a match, 150 each + the string after: Kenpachi's GUARD-BREAK → K1 → ... the most common opener on him).
   His NORMAL guards long up close: ai.lisp's neutral guard within 3.4 m (the kit's `:guard`, 0.3–0.5) and the hold-guard
   after a block (NORMAL 0.92 of the blocks, the stun + 20 f; the kit cannot touch that one). At HARD 4 land in 30 matches.

## The action policy (行動方針): the parent's, plus three rules

All of b0a1's routes stay (b0a0's aim, the facing, the kept burst; b1a2's links and cash-out; see their proposals).

1. **No follow-up after his own push** (BR-AI-PUSHED, pure BR-AI-PUSHED-P, `*BR-AI-PUSHED-FOR*` 90 f): BR-S-CPU-CALL notes the
   tick his string ended on a pushing hit (an `:end` segment that hit, no L L line or SP2 called: BRS-AI-PUSHED); for the
   next 90 f, him reeling, his reflex answers `:WAIT` instead of letting ai.lisp's follow-up J1 whiff (the neutral picks once
   he is free; HARD's exit still runs first in KIN). A rule at every difficulty, no roll. NORMAL's ~700 whiffed follow-ups go.
2. **Every shot reaches** (round 2 b1a1's floor, re-implemented on the marksman: BR-AI-FLOOR-LEVEL / BR-AI-PLAN-LEVEL /
   BR-AI-SNIPE-FLOOR / BR-AI-DASH-FLOOR, `*BR-AI-DASH-FLOOR*` 6.4 / 8.4 m): the `:charge` roll decides the planned level; a
   failed one takes the lowest level whose line still reaches him (the snipe: level 1 inside its 4 m + his body, else 2; the
   dash: level 1 inside 6.4 m, 2 inside 8.4, else 3), in the base stance's pick, the awakened `:sig-hold` and the CPU's R17
   link. HARD's roll always passes (unchanged by it: the planned level is never under the floor, host-checked).
3. **No long guard up close** (every form's `:neutral-guard` 0.1, the kit key ai.lisp's neutral guard reads; the threat
   guard keeps `:guard` 0.3–0.5): the long neutral guard is what the opponents' generic Breaker-a-guard reads. NORMAL's
   landed Breakers 4.1 → 3.1 a match (the hold-guard after a block is ai.lisp's and remains the larger source).
4. **NORMAL recalibrated**: `*BR-AI-DIFF*` NORMAL 0.4 → 0.3 (b1a1's value). A small lever here (0.4 / 0.3 / 0.2 moved the
   400-match NORMAL share by under 0.02): his NORMAL's strength is in its rules, not its chances.

Per form: **base** — the far snipe from 4.5 m, squared up and aimed (parent), now always at a level that reaches; the gun-kata
/ rifle strings end in the push and he lets the man reel (no lunge at air), then picks again; he no longer stands guarding up
close. **KIN / the owl KIN** — the parent's (kite, exit, Step-in J1, the turn-wait, the R17 link, the burst); after the stance
string's push no blind J1; the dash from KIN always reaches. **EN / the owl EN** — the parent's window plan; the dash's level
floored by its reach.

Difficulty: no new chance (the pushed wait and the floor are rules; the neutral guard a kit value read by the generic
reflex); `*BR-AI-DIFF*` 0.2 / 0.3 / 1.5 stays EASY ≤ NORMAL ≤ HARD (host-checked). Randomness only SIM-RND01: the floor reuses
the same `:charge` roll (HARD draws the same numbers). The opponent only through the perceived SNAP (his state for the wait);
the push is his own state.

Kept working: AI-AWAKEN-P / `:awaken`, BARRO-TICK / BR-AI-BURST-P / `:burst` untouched; every debug / test command; the `duel
barro` counters; the learner (BR-LEARN-* untouched: BR-LEARN-CHARGE reads the floored level; the new reflex branch answers
only inside the 90 f after his own pushing end and otherwise returns NIL); the ASSIST (`:sig-hold` reads the brain through
AI-BRAIN as before, its HARD brain always passes the roll; BRS-AI-PUSHED is set only by his own CPU's BR-S-CPU-CALL, never for
an assisted human). New BRS slot: `ai-pushed`.

## The steps measured (aieval 40 seeds; NORMAL-only runs = the evaluator's own 400 NORMAL matches, seeds 1–40 both seats)

| step | change | score | str | sig | NORMAL (K of 80) |
|---|---|---|---|---|---|
| b0a1 | parent (rescored) | 0.9724 | 0.998 | 0.933 | 0.4175 (14) |
| v1 | + the pushed wait (NORMAL 80-match diag) | | | | 33 / 80 (parent 32) |
| v2 | v1 + the floor + KIN / base / owl-KIN intents to their charge ranges (diag) | | HARD diag 59 / 60, sig 0.9305 | | 27 / 80 — intents reverted |
| — | v1 + floor (seeds 1–20 / 41–80) | | | | 0.38 / 0.345 (7 of 40 / 14 of 80) |
| — | + NORMAL kite 0.03 → 0.15 (seeds 1–20) | | | | 0.405 — dropped |
| T1 | + `:neutral-guard` 0.1 (seeds 1–20) | | | | 0.445 (10 of 40) |
| T3 | T1 + anti-Breaker NORMAL 0.7, diff 0.3 | | | | 0.5225 (21) |
| T6 | T1 + anti-Breaker 0.5, diff 0.3 (seeds 41–80: 0.5175, 24) | | | | 0.515 (28) |
| T7 | `:neutral-guard` 0.2, anti-Breaker 0.5 | | | | 0.46 (18) |
| T8 | T6 + NORMAL turn-wait 0.15 | | | | 0.5175 (26) |
| **v3** | **floor + pushed + `:neutral-guard` 0.1 + anti-Breaker NORMAL 0.4 + diff 0.3 (full)** | **0.97** | 0.995 | 0.93 | 0.505 (25) |
| v4 | v3 without the neutral guard, anti-Breaker NORMAL 0.6 (full) | 0.9658 | 0.985 | 0.93 | 0.4375 (21) |
| **v5** | **v3 with anti-Breaker NORMAL 0.3 (the parent's) — delivered** | **0.97** | 0.995 | 0.93 | **0.49 (27)** |

(The NORMAL-only runs used a temporary load-time knob override for the tuning, removed before the full runs: v3 / v4 / v5
are plain builds. A NORMAL-only run's share equals the full evaluator's NORMAL to the digit: v3's T9 run and its aieval both
0.505.) The robustness check on new seeds (41–80): the guard change + the Breaker answer 0.5175 (Kenpachi 24 / 80) against
0.345 (14 / 80) without them.

## Why it is not a repeat

The three rules are located causes in the parent's own NORMAL logs, none of them a retune of a round's mechanism: (1) no cell
looked at what his CPU does after his own string's end push (R12 made the generic follow-up a guaranteed whiff; HARD's exit
hid it); (3) no cell looked at the opponents' Breakers on him (b2a0 / b1a1 answered *his* opponent's long guard, BR-AI-UNGUARD;
here it is his own guard that invites theirs). (2) is b1a1's floor, credited, combined with the marksman's aim for the first
time (b1a1 lacked the aim; b0a0 / b0a1 lacked the floor: their failed roll was still a tap). Dead ends recorded: the KIN /
base intents moved to the charge ranges (no NORMAL gain, HARD worse on the diag set), NORMAL's kite raised (flat), the
`*BR-AI-DIFF*` NORMAL lever (flat), the anti-Breaker NORMAL raised (moves the share, not Kenpachi).

## Awaken A/B (informational: AI-AWAKEN-P, the burst untouched; the base form's guard and follow-up changed)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S; all 900 matches K.O. (one BR match at 500 a double K.O., counted a draw); medians 129.8–158.1 s:

| seed0 | b0a2 | b0a1 (parent) |
|---|---|---|
| 100 | 12 3 3 5 2 | 13 0 0 2 2 |
| 300 | 14 1 3 5 5 | 12 0 3 0 2 |
| 500 | 23 0 2 4 6 | 16 0 2 1 3 |

A little better on every stream (the never-awaken side's wins 17 → 25, 17 → 28, 22 → 35; 56 → 88 of 900; BY at 500 reaches
23), still far under the pass mark 20 elsewhere: the never-awakened base form remains the open problem. Its NORMAL logs show why: dealt / taken
0.5 in the base form against ~9 in JILLIEL EN; what beats it is the opponents' awakened forms against a base whose damage
comes in 15s and a 4–12 m snipe.

## Expected benefit, risks

- Benefit: a fairer NORMAL — Kenpachi 14 → 27 of 80, every row 27–46 of 80, the share 0.49 (0.19 over the band's floor, 0.11 under
  its top; the parent 0.1175 over the floor); NORMAL no longer whiffs a J1 into the air after every string or taps a 4 m shot
  from 6 m; fewer Breakers on him. HARD and the masher as the parent within the evaluator's noise (strength 398 / 400).
- Risk: the score itself is 0.0024 under the parent's (noise-level, but it is the number). The NORMAL share moved +0.07:
  a later change that strengthens NORMAL's rules has 0.11 of room before the band's top.
- Pacing medians 123.8–167.9 s, ≥ 52 s under the cap (no risk).
- The pushed wait makes him stand for up to 90 f while the man reels out of reach (a human may see him "let go" after a
  string; HARD's exit dash still fires first in KIN). A human who recovers and walks in meets a free Lille, not a whiffing one.
- `:neutral-guard` 0.1 at every difficulty: his CPU guards less in neutral (the threat guard is unchanged); against a human
  who walks in with J pokes he guards less on spec.

## Shared-code recommendations (not done)

- ai.lisp's hold-guard after a block (`*AI-HOLD-GUARD*` NORMAL 0.92, the stun + 20 f, "no reflex drops it") is the main
  source of the long guards the opponents' Breaker-a-guard reads (853 GUARD-BREAK Breakers thrown at him in 200 NORMAL
  matches after this cell's change): a kit key to shorten it (or to let a kit's reflex answer an incoming Breaker during it)
  would help every kit; his NORMAL vs Kenpachi is still the low row.
- ai.lisp's generic follow-up (`:follow-up :q`, the perceived distance + 0.6 m) reads a perception-delayed distance: after any
  ender's push (the generic ENDER-PUSH too) it whiffs; testing the attacker's own push (as here) would fix it for every kit.
- Every earlier recommendation stands (STRING-REFLEX's `:l-after-*` by difficulty; a generic Step-in reflex; the delay in the
  generic Hoho's frame test; the dash's follow-up J1 is forced by frame data).
