# q2-ptr: SP pointer rules in the T0 tables (2026-11-17)

The user asked whether the Q tables read both fighters' SP pointers, then said 「都做」. They do read them, through two groups of
`:rb-sp2`:
- **G9**, rules 89-94: my pointer x the pointer switch open.
- **G10**, rules 95-103: his pointer x distance.

Until now, all 15 of those rows were 0 in the nine shipped `:t0-*` tables, except row 95 of t0-ki-kenpachi.

This batch looked, table by table, for an arm that does better at some pointer state, and filled those rows where it found one. Base:
main e16bda9c. Its tables equal p10's, and the dev ladder on this branch reproduces `diag/tier/ladder-p10.txt` exactly
(`ptr/ladder-base.txt`, 19 of 27 pass).

## Result: one table changed

**t0-ih-ichigo**, in G10 (his pointer x distance):

| row | pointer state | change |
|---|---|---|
| 99 | his pointer 2, mid | i6-punish +0.12 |
| 95 | his pointer 1, close | economy, punish and kessa-lunge -0.12, so brawl (arm 0) plays |

- Dev ladder (seeds 501-600):
  - **20 of 27 pass, was 19.** H>N IH .745 → .775: fail → PASS.
  - Every other cell of IH and HI moves by .005 or less. Every cell of the other seven pairings is identical.
- Second block (seeds 401-500): H>N IH .760 → .830.
- Bar A at HARD vs HARD passes before and after: median changes 78 → 65, shares .425 / .169 / .196 / .210 → .500 / .092 / .245 / .164.
- Bar D (IH, HARD vs HARD): K.O. .900 → .938, Ichigo's points .163 → .188.
- G2 (`--cvc`) is unchanged. IH is not a G2 pair.
- Saved online copies for IH Ichigo reset: checksum 76462 → 201095.
- `tests/duel-rules/strategy.lisp`:
  - The IH row now names 76462 as "before". Its cues sit at his pointer 3, where no q2-ptr row fires.
  - New checks show the pick move on the pointer cue alone. At his pointer 2, mid, punish plays. With his cells up, economy plays,
    except at his pointer 1, close, where it yields to brawl.

The evidence for this rule is modest:
- **The estimates.** At HARD vs HARD, row 99 alone gives z 5.1 and row 95 alone z 2.8, which is under the scan gate. Row 95's tab supports
  only "not kessa-lunge" (z -4.0), and the table picks kessa-lunge there 1 % of the time. In the populations of the cells it moved, the
  pair is near 0: z 0.9 at HARD vs NORMAL, z 1.2 at NORMAL vs EASY.
- **The ladder.** H>N IH rose on both blocks: +.03 on 501-600 and +.07 on 401-500. Pooled, that is 304 → 321 of 400, about 1.5 SE
  unpaired. The 501-600 pass (Wilson .723) is on the block the rules were selected on.
- **Which row carries it.** Row 99 alone, the row the estimate backs, gives no lift: H>N IH .748 on 501-600 and .735 on 401-500
  (`ladder-ih99.txt`, `ladder-401-ih99.txt`, `share-ih99.txt`). So the lift is row 95's: brawl at his pointer 1, close.
- **The cost.** Row 95 moves arm shares toward arm 0 at every tier:
  - HARD vs NORMAL: .554 → .655 (kessa-lunge .101, just over the 10 % line);
  - NORMAL vs EASY: .492 → .659;
  - EASY vs masher: .679 → .794. Bar A there failed before (two arms at 10 % or more) and fails after (arm 0 over 70 %).

Everything else was measured and dropped (below). On those tables the data either showed no gap that survives the ladder, or a rule that
works only by taking an arm out of the switching.

## The rule form

Each rule is one entry: ±2 x the table's largest |q|, at one pointer row for one arm, with 0 in the group's other rows. `*0` means every
arm but 0, so arm 0 plays there.

For an arm with a one-group job, +2q at row s is the same Q function as the "or" job map at preserved scale (+1.5q on the job rows, -0.5q
on the rest of both groups). The two are equal because each group's firing sums to 1, so per-group constants cancel.
- Outside s the table is exactly what it was.
- Inside s the arm wins where it was out of job: -q + 2q = q.
- An exact tie (q against another arm's in-job q) falls to keep-state, the previous arm. The ladder measured the rows as written.

## Method (`ptr.py`; logs in `build/ptr/`, ignored)

1. **`log TABLE --tiers MINE,HIS`** plays the pairing's gate on seeds 1-500.
   - The table's side sits on seat 1 and on seat 2, and both CPUs play the shipped lookup.
   - Only the logging seat explores: STRAT_FQLOG "salt .04 seat 6 18". At a judgement outside a run, a run starts with chance .04, with
     another arm drawn uniformly and held for 6-18 judgements.
   - HARD vs HARD for every table, then the populations of the failing cells:
     - ih-ichigo at hard,normal and at normal,easy;
     - kh-hisagi at normal,easy;
     - ki-kenpachi at hard,normal;
     - six tables at easy,masher: ki-ichigo, ki-kenpachi, ii-ichigo, ih-hisagi, hh-hisagi, kk-kenpachi.
2. **`tab`** gives A(s, k) per pointer row s and arm k (`ptr/tab-*.txt`): mean Y of the run starts with k, minus mean Y of the no-start
   judgements whose table pick is not k. A run of k starts only at those judgements, and whether it starts is a hash coin.
   - Y is sw.py's discounted shaped return: 0.1 x the change of the health difference per judgement, plus ±1 at the end by the game's
     result, with gamma 0.966.
   - The bootstrap resamples matches. `--by-greedy` splits A by the table's own pick.
3. **`scan` / `try`** take candidate deltas, written `ARM:ROW:MULT`.
   - They recompute STRAT-FQ-PICK on every logged state, with the margin and the logged prev. This matches the logged pick on .9955-1.0 of
     judgements, and the tool refuses to go on below .99.
   - Gain = (mean Y of the run starts whose arm is the new pick, minus mean Y of the no-start judgements, over the judgements whose pick
     changes) x the switched share.
   - Each estimate gets a match bootstrap and is checked in both seed halves.
   - Gate: z ≥ 3.3 and switched ≥ .03 (marked `*`). That is the Fable review's bar: about 100 candidates a table give 1-4 false positives
     at z 2.
   - The base q and the delta scale come from git ref e16bda9c, the logged tables (`BASE_REF`). Two scale bugs led to this; see "What went
     wrong".
4. **`share`** checks bar A (DUEL_AI_STRATEGY §11.28) on the table as built: every match changes arm, median ≥ 10 changes, ≥ 3 arms at
   ≥ 10 %, none over 70 %. Outputs: `ptr/share-*.txt`.
5. **Ladder.** Candidates went through the dev ladder (`ptr/ladder-r{A,B,C,D}.txt` etc.; compare with `ptr/cmp.py BASE NEW`). Survivors
   were rerun on seeds 401-500 (`ptr/ladder-401-*.txt`), a fresh sample of the ladder's matches that is not held out.

## What the data said, per table

- **Kenpachi's "my pointer" rows are switch rows.** He sits at pointer 1 about 92 % of the time (row 89 + row 92 in
  `tab-kh-kenpachi.txt` and `tab-ki-kenpachi.txt`). His pointers 2 and 3 never reach 100 weighted judgements, so no pointer contrast can be
  tested for him.
- **The HARD vs HARD z does not carry over to the ladder.** It measures a table's strength, but the ladder rewards tier separation. A rule
  that makes side X stronger helps the cells where X is the higher tier and hurts those where X is lower.
- **The run-start estimate measures a 3-9 s burst; a rule holds as long as its row fires.** On broad rows the two part ways.

Per table:
- **IH Ichigo**: shipped, see above.
- **KH Kenpachi** (`1:89:2,1:96:2`, z 4.5): HK H>N .895 → .845, N>E .715 → .650 (round A). Dropped.
- **KH Hisagi**:
  - `2:89:2,2:95:2` (z 2.7): no lift. HK went .900 / .690 / .905 against .895 / .715 / .915.
  - The normal,easy gate candidate `*0:96:-2` (z 3.3) took HK N>E .715 → .682 (round D). Dropped.
- **IH Hisagi** (`1:95:2,1:96:2`, h5-tip, z 6.0): it makes the lower tier of the IH cells stronger, so H>N IH fell to .715 (round B).
  Nothing passes the gate at easy,masher. Dropped.
- **HH**:
  - `1:89:2` (z 4.2 HARD-HARD, 6.2 EASY-masher): E>M HH .470 → .350 / .365 (rounds A, B).
  - `2:92:-2,2:96:-2` (c-ih-h-r1-b2a0 yields; z 3.7 EASY-masher): E>M HH .470 → .540 / .490 → .575 on the two blocks. But arm 2's share
    went .168 → .001 and the median changes 30 → 4 (`share-wide.txt` against `share-base.txt`). It deletes an arm instead of switching,
    and bar D HH K.O. fell .750 → .650. Dropped.
  - HH's base already fails bar A, with arm 0 at .714.
- **KI Kenpachi** (k5-wake; z 5.5 HARD-HARD, 4.0 HARD-NORMAL, -3.4 EASY-masher):
  - 2q on rows 92-94: H>N KI .840 → .935 / .760 → .910. But bar A failed (wake .782, median changes 51 → 15). Bar D Kenpachi's points
    went .037 → .475. That is not itself a harm, since it moves a lopsided HARD pairing toward even; it is recorded as an observation and a
    lead for a tier-dependent mechanism.
  - 1.5q on row 92 only: wake .709 (bar A still fails), H>N KI .875 / .890, E>M KI .730 → .695 / .750 → .630 (-4 SE on 401-500)
    (`share-ki15.txt`, `ladder-ki15.txt`, `ladder-401-ki15.txt`). Dropped.
  - The wake arm is strong at HARD and weak at EASY, so no single row helps every tier. Changing wake's own job rows is a better lever
    than a pointer rule.
- **KK** (`1:95:2,1:97:2`, z 3.4): H>N KK .995 → .975 with 132 bells (was 0), E>M .530 → .465 (round C). Dropped.
- **KI Ichigo, II Ichigo**: no candidate passes the gate in any population.

## Numbers (final state)

Dev ladder: `ptr/ladder-final.txt` and `ptr/cmp-final.txt`. Second block: `ptr/ladder-401-base.txt` against `ladder-401-ki15.txt`.

The `*-ki15` files (`share-ki15.txt`, `bar-ki15.txt`, `ladder-ki15.txt`, `ladder-401-ki15.txt`) were measured on the build with KI's 1.5q
row. Only their IH and HI rows describe the final state, because KI's table does not play in those cells. `bar-final.txt` is the final
state.

| cell | 501-600 | bells | 401-500 |
|---|---|---|---|
| H>N IH | .745 → .775 | 118 → 101 | .760 → .830 |
| N>E IH | .960 → .955 | 54 → 50 | .940 → .955 |
| E>M IH | .995 → 1.000 | 3 → 7 | .985 → .995 |
| H>N HI | .995 → .995 | 6 → 3 | 1.000 → .995 |
| N>E HI | .877 → .882 | 105 → 112 | .865 → .875 |
| E>M HI | .445 → .445 | 196 → 196 | .505 → .505 |

Bar D (`ptr/bar-final.txt` against `diag/tier/bar-p10.txt`): IH K.O. .900 → .938, Ichigo's points .163 → .188, bell 0 / 8 → 2 / 3. Every
other row is identical.

Parity rows at N>N were not measured.

## What went wrong (for the next batch)

- **`try` read the working tree's q.** A candidate applied for a ladder run became the estimates' baseline, and the review's tries
  returned the same gain for every variant. The base now comes from a fixed ref, with the .99 assert.
- **`apply` took the delta scale from HEAD.** After the first commit HEAD held q2-ptr's own 0.15 and 0.24 rows, so the scale doubled.
  That made the "narrowed" round (`share-misscaled.txt`, `ladder-misscaled.txt`) test other tables than intended:
  - KI: row 92 +1q, rows 93-94 -2q;
  - HH: arm 2 +0.24 at row 92 and -0.24 at row 96.

  Both now use `BASE_REF`.
