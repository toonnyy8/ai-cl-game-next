# Cell b0a1 (round 2, refines b0a0): "the marksman squares up" — every charge opened facing him, the base burst kept for the owl

Freeze 2eaf8b9. Parent b0a0 ("the marksman": the charged L aimed, the charge's Step as its re-aim): its `barro.lisp` copied,
its BARRO-CPU-TESTS section spliced in (`splice-tests.py`). Only `duel/lisp/barro.lisp` (his CPU parts: the base kit's
`:ai` gets `:sp-ender`; new BR-AI-KEEP-BURST / BR-AI-FACING-P and two knobs in the AI section; one extra condition in
BR-AI-EN, BR-AI-EXIT and BR-AI-REFLEX's window) and the `BARRO-CPU-TESTS` section of `tests/duel-rules-test.lisp` changed.
Host test 8368 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte):

| | baseline-r02 | b1a0 (sibling) | b0a0 (parent) | **b0a1 (delivered)** |
|---|---|---|---|---|
| score | 0.9102 | 0.9607 | 0.9696 | **0.9724** |
| strength (HARD, both seats) | 0.853 | 0.983 | 0.993 | **0.998** (399 / 400) |
| masher | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.919 | 0.932 | **0.933** |
| NORMAL share (band 0.30–0.60) | 0.36 | 0.3875 | 0.4325 | **0.4175** (Y 48, K 14, R 36, I 28, S 41 of 80) |
| pacing medians Y K R I S (cap 220, all 40 / 40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 136.3 129.6 150.6 159.4 147.1 | 134.1 127.2 152.6 163.4 147.7 | **130.2 130.4 160.3 160.3 153.0** |

sig_by (final): br-e-k 0.262, br-e-kl 0.158, br-k-hiren 0.093, charged 0.082, br-oe-k 0.081, br-rc 0.073, br-s-l1- 0.069,
plain-jk 0.059, br-oe-kl 0.048, br-s-j 0.020, br-w-nijushi-c 0.018; outside the whitelist besides plain-jk: counter 0.005,
the cuts / the level-1 dash 0.001 each.

Honest summary: +0.0028 over the parent, mostly strength (3 losses → 1 of 400) with the signature level. That is within
the reach of the evaluator's RNG-stream noise (my three other variants of the same parent measured strength 0.985–0.988 from
changes that do not touch HARD's fights much); the evidence below is why the facing piece is a real reduction of wasted
dashes, and why the signature is now at a structural ceiling (~0.94) for any CPU on these rules.

## History read (every proposal, score.json and score.rescored.json; round 1's numbers are pre-R18, mechanisms only)

- **round 1** (freeze 36e93c7): b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up),
  b1a0 0.6985 (routes on events; the missing turn), b2a0 0.915 (the opponent's reach envelope, the Kikon on openings),
  b3a0 0.9192 (the clock, the wings as armour: the reserve), b0a1 0.952 (b2a0 + b3a0's reserve + the wake-up shot), b1a1
  0.9529 (the Step-in interrupt, the stance exit, the let-go), **b0a2 0.9549 (the burst kept for the owl; three located dead
  ends: the dash's follow-up J1 is forced by frame data, "bare: back out first" a selection bias, NORMAL's ±0.05 noise)**,
  b1a2 0.9716 (every link into the stance, the pips cashed from range).
- **baseline-r02** 0.9102: b1a2 on R18 (the charged L no longer turns onto him).
- **round 2 b0a0** 0.9696 (my parent): the aim (the shot's line against his predicted feet; the charge's Step as the re-aim,
  his Hoho behind the charge answered at once), the charge floor, NORMAL x0.4.
- **round 2 b1a0** 0.9607: the line (release when his feet meet the frozen line), the envelope (the far snipe from 6 m),
  **the facing** (a charge's window opens only facing him). Its v3 / v4 were flat.
- Shared weak spots: Kenpachi at NORMAL (15 / 80, 11 / 80), the NORMAL margin, the never-awakened base form (A/B).

## Diagnosis (the combat log as aieval runs it: HARD, seeds 1–4 x 5 opponents x both seats = 40 matches; scratch parsers)

The parent's 40 diagnosis matches (all won; signature on this set 0.9335, the eval's 0.932). **Where the plain damage
(6.1 %) comes from**, by move and by his brain's reason:

| plain hit | reason | share of his damage |
|---|---|---|
| KIN J1 | FOLLOW-UP after the dash's cuts | 2.82 % |
| the owl's J1 | FOLLOW-UP after the dash's cuts | 0.79 % |
| base J1 | STEP-IN (b1a1's interrupt) / STEP-J (the generic Step → J) | 0.50 / 0.47 % |
| the owl's J1 / base J1 | CHAIN (ORANGE's restart) | 0.42 / 0.25 % |
| KIN / owl J1 | STEP-IN, PUNISH, STEP-J | ~0.6 % |
| J1 / K1 | ANTI-BREAKER | ~0.2 % |

- **The dash's follow-up is forced** (b0a2's finding, re-measured on R18): of 395 follow-up J1s, 199 come after a level-2
  dash (3 cut hits; the last cut lands 6 f BEFORE he is free, so ~22 f of stagger are left when he can act, facing away
  1.6 m past him), 170 after level 3 (the last cut 2 f after he is free: ~30 f left), 26 after level 1. The idle turn
  (18 °/f, ~8 f) + KIN J1 (S 8) fits both; the stance's opener does not: the turn into EN 12 f + EN K1 16 f (b0a2's v1:
  Perfect-Hoho'd 98 of 342), or EN J1 (S 8, but its 96 ° of track cannot turn him round) only after level 3 and into the J
  route (15 a hit instead of the K route's 46 / 46 / 66 + 70-a-wing lines: about a third of the combo's damage). The J1
  bridge (20) buys ~160–370 of signature behind it: dropping or replacing it costs far more strength than it gains.
- **The dashes (far window)**: JILLIEL's 570 far dashes — 364 hit, 85 blocked, 79 whiffed, 42 punished; the owl's 174 —
  105 / 33 / 30 / 6. A charged dash goes where he faces (R18), and the far window could open while he was still turned away
  (after a dash through him, after a Step).
- **The losses** (the parent's lineage at 40 seeds: Kenpachi seeds 36 / 39, Ichigo 11 / 15 / 34): spread over the base form's
  step-ins into Kenpachi's J1, Perfect-Hoho COUNTERs on HIRENKYAKU and on far dashes, the meteor; no single route.

## The action policy (行動方針): the parent's, plus

All of b0a0's routes and its aim stay (see its proposal). Two pieces, one from each recorded cell of the history, combined
on the marksman for the first time:

1. **Every charge is opened facing him** (the sibling b1a0's BR-AI-FACING-P, `*BR-AI-FACE-MAX*` 0.35 rad): R18's charge never
   turns, so the CPU opens a charge's window only when it squarely faces his perceived feet — the far window (the base's far
   snipe, KIN's far dash, the burst roll), EN's window plan beyond the stance K1's reach (EN's dash; the stance strings in
   reach are free, they track at 720 °/s), and the exit's armoured dash. Not facing, the window is not spent: the idle turn
   (18 °/f) squares him up within a few frames and the window opens then. The aim (the parent's) then only has to correct
   his movement during the charge, not a charge started off-line.
2. **The burst kept for the owl** (round 1 b0a2's BR-AI-KEEP-BURST, the base kit's `:sp-ender`, `*BR-AI-KEEP-BURST*` 0.2 /
   0.5 / 1.0, one roll a string end): in the base form, a string's end that his stance call did not cash (no L L line, no
   SP2) skips the generic SP2 cancel / ORANGE: the base's ORANGE is a plain chain J1 and costs the bar that only an
   awakened burst turns into the owl. Never in the awakened forms (their ORANGE is the owl's entry, and its chain J1 leads
   into the owl's stance K route).

Per form: **base** — the far snipe from 4.5 m, now opened facing him; the aim, the cash-out HIRENKYAKU, the gun-kata /
rifle confirms (parent); its strings end without the ORANGE chain, the flash step kept for JILLIEL's burst. **KIN / the owl
KIN** — the far dash's charge only once squared up (KIN's L held = the turn and the dash's charge at once, R13), the exit's
armoured dash only facing him (else the dash back); the rest the parent's. **EN / the owl EN** — the window plan: K / J in
reach at once, the dash only facing him (the window waits a few frames for the turn), the fast Step kept for the aim's
re-aim.

Difficulty: `*BR-AI-KEEP-BURST*` EASY ≤ NORMAL ≤ HARD (host-checked), one roll a string end (its first step: STRING-REFLEX's
`:sp-ender` call); the facing is a condition on existing one-per-window rolls (no new roll, the window is not consumed while
it waits). Randomness only SIM-RND01; the opponent only through the perceived SNAP (his feet for the facing).

Kept working: AI-AWAKEN-P / `:awaken` untouched; BARRO-TICK / BR-AI-BURST-P / `:burst` untouched (the burst roll's window
now also waits for the facing); the learner (BR-LEARN-* untouched, no new reflex: the facing only delays a window, the
reflex still returns NIL then); the ASSIST (`:sp-ender` returns NIL unless BR-TICK-BRAIN finds his own CPU: an assisted
human's AUTO COMBO and the gate's masher keep the generic ender; the difficulty read through AI-BRAIN); every debug / test
command; the `duel barro` counters (new: `ai-keep-burst`). No new BRS slot, no tick branch changed.

## The steps measured (aieval, 40 seeds; HARD diag = seeds 1–4, 5 opponents, both seats, 40 matches)

| step | change | score | str | mash | sig | NORMAL | diag sig / wins |
|---|---|---|---|---|---|---|---|
| b0a0 | parent (rescored) | 0.9696 | 0.993 | 1.0 | 0.932 | 0.4325 | 0.9335 / 40 |
| v1 | + keep-burst + the K route's L L lines paid below the wing reserve too (short of the armour's price) | 0.9684 | 0.985 | 1.0 | 0.936 | 0.395 | 0.9391 / 40 |
| v2 | the lines below the reserve alone | 0.9674 | 0.985 | 1.0 | 0.933 | 0.41 | — |
| v3 | keep-burst alone | 0.9686 | 0.988 | 1.0 | 0.934 | 0.39 | — |
| (diag) | v1 + the level-3 dash from 3 m (`*br-ai-dash-reach*` 4.5 → 3.0) | | | | | | 0.9401 / 39 |
| (diag) | v3 + the facing + the far snipe from 6 m (b1a0's envelope) | | | | | | 0.9200 / 40 |
| **v4** | **v3 + the facing (delivered)** | **0.9724** | **0.998** | 1.0 | 0.933 | 0.4175 | 0.9369 / 40 |

- The lines below the reserve (v2) moved the K route's cash from NIJUSHI-KO-C (0.017 → 0.006) to the KL lines (0.144 →
  0.182) without cutting the plain bridges (0.061 → 0.060): the damage needed for a K.O. is fixed, only fewer plain bridges
  raise the share. Dropped.
- The far snipe from 6 m (b1a0's envelope) on the marksman: the base form walked the 4.5–6 m gap into its melee bands
  (base J1 STEP-IN 0.9 %, STEP-J 0.6 % of his damage) — the parent's aim already answers the Hoho that motivated it. Dropped.
- The level-3 dash from 3 m: +0.001 on the diag set, one loss vs Kenpachi. Dropped (b1a2's v3 measured the same trade).
- The facing (v4 vs the parent, diag set): JILLIEL's far dashes 570 → 508, whiffed 79 → 48, punished 42 → 28, hits 364 → 343
  (the same hits from fewer dashes); EN-window dashes 31 → 16. Lille's ORANGE bursts in these 40 matches 91 → 82.

## Why it is not a repeat

The two pieces were each measured once, on other files: the facing on b1a0's line (whose release rule replaced the aim), the
kept burst on b0a2's pre-R18 file (flat there, +0.003). They were never combined with the marksman's aim, and the facing is
what the aim lacked: the aim corrects a charge whose start was on the line, but it cannot fix one started facing away (its
Step re-aims once; a dash charge started 180 ° off his line spent it). The two dead ends of this cell (the lines below the
reserve, the snipe from 6 m) and the located ceiling of the follow-up bridge are recorded so later cells skip them.

## Awaken A/B (the base form's burst use changed: the kept burst; the awakening itself untouched)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S:

| seed0 | b0a1 (Y K R I S) | b0a0 (parent; 100 only) | b1a0 (sibling) |
|---|---|---|---|
| 100 | 13 0 0 2 2 | 13 0 1 1 2 | 12 0 1 4 0 |
| 300 | 12 0 3 0 2 | — | 6 0 0 1 1 |
| 500 | 16 0 2 1 3 | — | 7 0 1 0 2 |

All 900 matches K.O. (medians 132.5–155.8 s). Unchanged in kind and far under the pass mark 20, as for every cell: these
rows measure his NORMAL base form alone against awakening opponents; the kept burst (NORMAL 0.5) only saves a bar the base
form cannot turn into the owl in these runs. The never-awakened base form stays the open problem it was (it never won those
pairings before R18 either).

## Expected benefit, risks

- Benefit: HARD 0.998 (Kenpachi / Ichigo the rows that lost before), the masher 1.0, signature 0.933; fewer whiffed and
  punished dashes (a human sees him square up before every charge: the charge is a readable, deliberate shot, never a
  dash into empty space after he crossed through).
- The +0.0028 is near the 40-seed noise of the strength part (±2–3 matches of 400 between RNG streams).
- The signature's ceiling: the dash's follow-up J1 (3.3–3.6 % of his damage) is forced by the cuts' timing (above); the rest
  of the plain share (~2.5 %) are the bridges that start his strings (Step-in, punish, chain). A further signature gain needs
  a rules change (recommendation below), not a CPU one.
- NORMAL 0.4175 (Kenpachi 14 / 80 the low row): 0.1175 over the floor. Pacing medians 130.2–160.3 s, ≥ 59 s under the cap.
- The facing makes his charges wait for the turn: against a human circling him the window opens later (a few frames at
  18 °/f); the window is not spent, so nothing is lost but those frames. A human may read "he squares up, then charges".
- The kept burst: his base form never ORANGEs off a string's end (HARD); the bar stays for JILLIEL's owl burst. A human
  who survives a base string is not chained into a second one.

## Shared-code / rules recommendations (not done)

- Rules (the user's call): with the dash's recovery and the cuts' stagger as they are, no CPU can start the stance from the
  dash without the attack state's J1 (b0a2, re-measured here: ~22 f left after a level-2 dash, ~30 f after level 3, facing
  away). If 「架勢連段」 should own that follow-up, letting the dash's recovery turn him toward the opponent (or letting a
  stance opener cancel the recovery on a hit) would move ~3.5 % of his damage onto the whitelist.
- ai.lisp: a documented `:sp-ender` value meaning "end the string here, no generic SP2 cancel / ORANGE" (the kept burst
  relies on AI-COMMAND pressing nothing for an unknown command); a kit key to veto the generic ORANGE on an L hit.
- Every round-1 recommendation stands (STRING-REFLEX's `:l-after-*` by difficulty, a generic Step-in reflex, the delay in
  the generic Hoho's frame test).
