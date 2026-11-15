# DUCT, the strength anchor: PROVISIONAL (PLAN4 §6, steps D1-D2; 2026-11-15)

The user: 「然後以 DUCT 作為強度錨點」, chosen as "DUCT 當固定基準": a frozen DUCT reference CPU, native only, that every tier reports its
win rate against. **This anchor is not frozen.** On main c15f9a55 the arms move to the kit-first order (PLAN4 "The arms come from each
fighter's kit"). Hisagi's arms may still change after checkpoint 2, and PLAN4 allows one re-freeze only. So everything below is built and
measured, and nothing is written to `ANCHOR.md`.

Pins: `SP_BUILD=b835ac41b83b` (strategy-switch.py's hash of `build/simgate/duel.fas` + `tools/simgate/strat-run.lisp`, both unchanged; the fas
was copied from main's build). Dev seeds only: 1-200 (D1, the fingerprint), 201-300 (the matrices), 501-550 (D2). `duct.py` refuses any
seed above 600.

## What was built (tools and research files only; no game Lisp)

- `sp/duct.py`: `arms`, `matrix`, `anchor`, `budget` (D1), `fingerprint`, `d2`. The usage is in its docstring. Every match goes through one
  job function, cached in `build/duct-cache/` and keyed by every env value's text (a file's contents), the fas, strat-run.lisp and the two
  duct files. `DUCT_NOCACHE=1` reruns.
- `tools/simgate/duct-run.lisp` + `duct-hook.lisp`: `strat-run.lisp` evaluated form by form, unedited, so the pin holds. It adds:
  - `DUCT_BUDGET_P1` / `_P2="rolls h period"`, a budget per seat, so that two budgets can play each other (D1). The rollout knobs are set
    from the side of the job that runs this step. The next selection is re-stamped to the seat's own period.
  - One `duct <seed> P<n> changes C held id:steps ...` line per match and layered side. Each step counts the live strategy id, outside
    rollouts. The steps include cinematic frames, so they sum above `secs x 60`.
  - Proof: a HARD-vs-DUCT KI job (seeds 501-502) through strat-run.lisp and through duct-run.lisp gives identical gate rows, hash lines,
    `stratlayer` picks and switch lines; only the `duct` lines are added.
- `sp/duct/write-arms.lisp`: lays the pairing's exchange unit (`arms4/x-units/`) under each arm with the game's own `strat-with`, then writes
  one inline plist per (pairing, arm) to `sp/duct/arms/` (33 files). A plain arm's top-level `:with` is not expanded by `sg-read-strat`, so
  this is done offline. The matrix then plays exactly the text that the anchor embeds. Mirrors get no unit.

## 1. The arms and the anchor files

| Character | Arms (each pairing's library) | Source |
|---|---|---|
| Ichigo | `all brawl keep kessa2` | `arms4/ichigo.lisp` |
| Kenpachi | `all spend climb`, + `bait` vs Hisagi | `arms4/kenpachi.lisp` |
| Hisagi | `all range wake`, + `hoho6` vs Kenpachi, + `ihx` vs Ichigo | `arms4/cells-h/final/h4-*.lisp` (the cells' picks for wake / hoho6 / ihx; `t0/*.arms` still hold the draft wake) |

**Anchor files**: `anchor-kk.lisp`, `-ki`, `-kh`, `-ii`, `-ih`, `-hh`. There is one file per unordered pairing, because a cross file holds
both sides: rows KI and IK both read `anchor-ki.lisp`.
- The library lists A's arms, then B's.
- The payoff row is `(A B rows cols M x y)`.
- M is A's **game-result share**: a K.O., or at the bell the lead, with a draw counted half. The strategy layer reads B's view as 1 - M
  (`strat-seed-value`, zero-sum), so a K.O.-only general-sum matrix (`pop.py`'s) would credit every time-out to the column side.
- x and y come from zero-sum regret matching (`pop.solve(M, 1 - M)`), and every gap is under 0.001.
- The K.O. counts are kept in `matrix-<pair>.json`.

## 2. The matrices (seeds 201-300, both seats, 200 matches a cell, each arm pair played whole; A's game-result share)

- Cost: 3,485 CPU-s for all six (about 0.27 CPU-s a match), 3.7 min of wall time.
- In a mirror, cell (k, i) is the same matches as cell (i, k) seen from the other side, so only i <= k is played and the diagonal is 0.5 by
  construction.

KK (Kenpachi rows x Kenpachi cols):

| | all | spend | climb |
|---|---|---|---|
| all | .500 | 1.000 | .510 |
| spend | .000 | .500 | .045 |
| climb | .490 | .955 | .500 |

KI (Kenpachi rows x Ichigo cols):

| | all | brawl | keep | kessa2 |
|---|---|---|---|---|
| all | .090 | .210 | .020 | .150 |
| spend | .000 | .000 | .025 | .000 |
| climb | .020 | .030 | .030 | .020 |

KH (Kenpachi rows x Hisagi cols):

| | all | range | wake | hoho6 |
|---|---|---|---|---|
| all | .990 | 1.000 | .980 | .985 |
| spend | .105 | .470 | .005 | .005 |
| climb | .770 | .925 | .670 | .800 |
| bait | .305 | 1.000 | .905 | .890 |

II (Ichigo rows x Ichigo cols):

| | all | brawl | keep | kessa2 |
|---|---|---|---|---|
| all | .500 | .885 | .855 | .520 |
| brawl | .115 | .500 | .790 | .105 |
| keep | .145 | .210 | .500 | .165 |
| kessa2 | .480 | .895 | .835 | .500 |

IH (Ichigo rows x Hisagi cols):

| | all | range | wake | ihx |
|---|---|---|---|---|
| all | .950 | .495 | .950 | .770 |
| brawl | .975 | .165 | .960 | .605 |
| keep | .455 | .130 | .485 | .400 |
| kessa2 | .960 | .455 | .980 | .655 |

HH (Hisagi rows x Hisagi cols):

| | all | range | wake |
|---|---|---|---|
| all | .500 | .985 | .670 |
| range | .015 | .500 | .080 |
| wake | .330 | .920 | .500 |

Equilibria:

| Pair | A's mix | B's mix | Value (A) |
|---|---|---|---|
| KK | all 1.0 | all 1.0 | .500 |
| KI | climb .876, all .124 | keep .875, all .125 | .029 |
| KH | all 1.0 | wake .999 | .980 |
| II | all 1.0 | all 1.0 | .500 |
| IH | all 1.0 | **range 1.0** | .495 |
| HH | all 1.0 | all 1.0 | .500 |

**Who dominates where.**
- **Arm 0 (`all`) is the pure equilibrium on every side but three.**
- **Hisagi vs Ichigo plays `range`.** It is the only Hisagi arm that holds Ichigo even (.505 for Hisagi against her `all`, where `all` gets
  .05 and `ihx` .23).
- **Hisagi vs Kenpachi plays `wake`.** Every Hisagi arm loses .98-1.0 to Kenpachi's `all`, so this mix is noise between losing arms.
- **KI is the same case.** Kenpachi's mix (climb .88 / all .12) and Ichigo's (keep .88 / all .12) are mixes of a 1-in-30 matchup: every
  Kenpachi row is .00-.21, and the value is .029. They are noise-level, not a strategic mix.
- So, as PLAN4 §6 expected, DUCT is mostly "the best whole-game arm per pairing, plus look-ahead".
- Bells: HH 829 of 1,200, KH 825 of 3,200, II 548 of 2,000. Hisagi's `all` stalls in self-play (all vs all: 0 K.O.s in 200).

## 3. D1, the budget rule (pre-registered in PLAN4 §6)

- DUCT against DUCT, the newer budget against the older.
- KI seeds 1-100 plus KH seeds 101-200, with the gate's Kenpachi on P1. The newer budget plays P1, then P2: 400 matches, so each budget
  plays each character equally and the matchup cancels.
- Pass for the newer budget is >= 220 points (55 %). The game's result decides each match, a draw counting half.

| Comparison | Newer's points / 400 | KI, new = Kenpachi | KI, new = Ichigo | KH, new = Kenpachi | KH, new = Hisagi | Verdict |
|---|---|---|---|---|---|---|
| standard (16 x 240, 90) vs today's (8 x 150, 90) | **198.0 (.495)** | 3 | 93 | 98 | 4 | does not beat |

- Only the rows carry information. Kenpachi wins 3 of 100 with the standard budget and 7 with today's; Ichigo 93 and 97. In KH Kenpachi
  wins 98 with standard and 96 with today's.
- **The per-seat budget took effect** (checked from the cached D1 jobs' `stratlayer` lines). Rollouts = 16 x picks(new seat) + 8 x
  picks(old seat), to within the unfinished jobs:
  - 354,315 against a predicted 354,232, and 383,008 against 382,936 (ratio 1.000);
  - both seats at 8 would give 237k / 255k, both at 16 would give 474k / 510k.
  - `*strat-h*` is set on the same code path, but it is not counted separately.
- **Choice: today's, 8 x 150 / 90** (`budget-provisional.json`). Heavy was not compared: by the rule, it plays only if standard wins.

Cost of each setting: DUCT on both seats, KI seeds 1-20, P1 Kenpachi, 40 matches:

| Setting | CPU-s a match (2 DUCT seats) | ms a selection | Selections a side and match |
|---|---|---|---|
| today's | **1.29** | 7.6 | 74.9 |
| standard | 3.90 | 23.7 | 78.4 |
| heavy | 13.44 | 59.2 | 110.6 |

A plain match costs about 0.27 CPU-s. One DUCT seat at today's costs about 0.8 CPU-s a match.

**Caveat:** both seats' selections share the one rollout a step, oldest job first. A heavier seat's jobs therefore also delay the other
seat's picks. That is how the layer runs; the comparison measures the pair as played.

## 4. Fingerprint (`fingerprint-provisional.txt`)

DUCT against DUCT, seeds 181-200, all nine rows (the P1 character first), today's budget. The file holds 180 gate rows and 4,953
`duel hash` lines. Its header records the build, the fas and strat-run.lisp hashes, and each anchor file's sha256.

**Determinism:** the fingerprint ran twice, the second time with `DUCT_NOCACHE=1` (every match replayed). The two files are byte-identical.
At every `SP_BUILD` re-pin, rerun `duct.py fingerprint --budget today` and diff it against this file.

## 5. D2: DUCT against DUCT, and HARD against DUCT (`d2-provisional.json`)

**Setup.**
- Seeds 501-550, both seats, today's budget.
- Row XY: X plays the tier, Y plays DUCT under `STRAT_LAYER=P<n>` (the seat layer). X's share is the game's result, a draw counting half.
- "HARD" is **today's shipped lookup tables** (`sp/final/<pair>-<character>.lisp`, the `:rb-sp` fallbacks that play arm 0 bit for bit),
  passed as `STRAT_P<n>`. Under `STRAT_ANCHOR`, `strat-lookup` sees only the anchor's entries, so without the file the HARD seat would play
  the plain CPU.
- Checked: the table seat prints its `switch P<n> KI-KENPACHI judged 131` line.
- B4's T0 tables had not landed on main (last checked: main = c15f9a55), so **T0 is not measured**. The B3 drafts in `arms4/t0/` cover 7
  of the 9 rows and are not B4's tables.
- The DUCT-vs-DUCT runs are 6 distinct sets: rows KI and IK are the same matches. A mirror's 50 matches are read from both seats.

| Row (X vs DUCT-Y) | DUCT-X share (P1 / P2) | HARD shipped-X share (P1 / P2) | HARD - DUCT | Bells DUCT / HARD (of 100) |
|---|---|---|---|---|
| KK | .500 (.30 / .70) | **.110** (.12 / .10) | -.39 | 0 / 0 |
| KI | .060 (.08 / .04) | .050 (.04 / .06) | -.01 | 0 / 1 |
| KH | .960 (.94 / .98) | .980 (.98 / .98) | +.02 | 0 / 1 |
| IK | .940 (.96 / .92) | .870 (.90 / .84) | -.07 | 0 / 0 |
| II | .500 (.52 / .48) | .540 (.52 / .56) | +.04 | 34 / 27 |
| IH | .410 (.44 / .38) | **.080** (.10 / .06) | -.33 | 8 / 0 |
| HK | .040 (.02 / .06) | **.280** (.26 / .30) | +.24 | 0 / 5 |
| HI | .590 (.62 / .56) | **.100** (.08 / .12) | -.49 | 8 / 1 |
| HH | .500 (.68 / .32) | **.070** (.08 / .06) | -.43 | 100 / 32 |
| **pooled** | **.500** (by construction: KI / IK and each mirror are the same matches read from both sides) | **.342** | | |

The determinism evidence is the fingerprint's byte-identical rerun, not this pool.

**Against the working target** (pooled >= 50 %, no row more than 15 points under DUCT's own), **today's shipped lookup, not T0**, fails.
CP2 sets the target from T0's number.
- pooled .342;
- four rows more than 15 points under: KK -39, IH -33, HI -49, HH -43.

**Reading.**
- **Where DUCT plays a different arm than the shipped table, DUCT wins.**
  - IH Hisagi plays `range` (the matrix's only even arm against Ichigo). Shipped HARD Ichigo goes 8 of 100 against it, against DUCT
    Ichigo's 41.
  - HI: shipped HARD Hisagi goes 10 against DUCT Ichigo, where DUCT Hisagi with `range` gets 59.
  - KK and HH: the mirror tables (`c-ki-k-r2-b0a2`, `c-ih-h-r1-b2a0`) lose to the PLAN4 arm 0s (`a4-k-all`, `h4-all`). The HH losses are
    mostly at the bell.
- **One row goes the other way: HK.** Shipped HARD Hisagi (`x-kh-h-r2-b3a1`) takes 28 of 100 from DUCT Kenpachi. DUCT Hisagi, which plays
  `wake` (the matrix mix against a 98 % loss), takes 4. The KH Hisagi arms in the anchor are weaker than today's shipped KH arm.
- **The HH self-play is all bells.** DUCT against DUCT in HH: 50 of 50 matches end at the bell, decided by the lead (P1 34 of 50).

**Cost** (CPU-s a match, measured under a shared machine at load about 34, so 1.5-2x the quiet D1 probe):
- HARD vs DUCT: 1.0-3.2.
- DUCT vs DUCT: 2.5-7.6. The bell-length mirrors are the dearest: HH 7.6, II 5.8.

## 6. How often DUCT switches arms

These are the row's DUCT side (Y). Selections are those completed, per match. Changes are changes of the live strategy, per match. The
shares are of battle frames.

| DUCT side (row) | Selections | Changes, mean (median) | Matches with no change | Arm shares |
|---|---|---|---|---|
| Kenpachi vs K (KK) | 85 | 14.5 (14) | 0 % | all .90, climb .10 |
| Ichigo vs K (KI) | 74-76 | 22-25 (21-23) | 0 % | all .76, keep .21, kessa2 .02 |
| Hisagi vs K (KH) | 75-82 | 0.7-1.0 (0) | 57-68 % | wake .99 |
| Kenpachi vs I (IK) | 67-70 | 0-0.2 (0) | 90-100 % | all 1.00 |
| Ichigo vs I (II) | 129-134 | 6.4 (6) | 3-5 % | all .97, kessa2 .03 |
| Hisagi vs I (IH) | 97-105 | 0.1-0.2 (0) | 92-95 % | range .999 |
| Kenpachi vs H (HK) | 77-100 | 36-46 (36-44) | 0 % | bait .56-.62, all .38-.44 |
| Ichigo vs H (HI) | 80-115 | 2.7-4.1 (2-4) | 11-36 % | all .98, kessa2 .02 |
| Hisagi vs H (HH) | 143-198 | 0 | 99-100 % | all 1.00 |

- As PLAN4 §6 expected, **DUCT mostly plays the best whole-game arm**: in five of nine rows one arm holds 97 % or more.
- It switches for real only in three places:
  - Ichigo vs Kenpachi (all / keep), where her arms are all near 1.0 against him and the rollouts decide;
  - Kenpachi vs Hisagi (bait / all), the two near-equal rows of KH;
  - the KK mirror (all / climb, .51 / .49 head to head).
- The initial pick (before the first selection's rollouts finish) is not in the picks; the frame shares include it.

## What blocks a freeze later

1. **The arms are not final.** Main c15f9a55 restarts the arms from the kit (data sheet, catalogue, the user's pick). Every arm change
   means new arm files, matrices, anchors and fingerprint. PLAN4 allows one re-freeze: spend it after the kit-first arms land, not now.
2. **The matrices barely move DUCT off arm 0.** Only IH Hisagi (`range`) and the noise mixes of losing sides (KI both sides, KH Hisagi)
   differ from arm 0. A weak arm set makes DUCT a weak anchor in those rows; that is a property of the arms, not of DUCT.
3. **D1 has little power.** The 55 % rule on a pooled, matchup-balanced 400 can only see a large budget effect. The per-row numbers (3 vs
   7, 93 vs 97, 98 vs 96) show none. Today's budget stands; if the user wants the rule re-registered with a finer test (paired by seed),
   that has to be decided before the freeze.
4. **The pin.** strat-run.lisp must stay byte-identical for the pin to hold, which is why duct-run.lisp wraps it instead of editing it. A
   strat-run edit, or any Lisp change, moves the hash; the fingerprint must then be rerun and must come out identical.
5. **The anchor is weaker than today's best known arm in places.** HK: shipped HARD Hisagi takes 28 % from DUCT Kenpachi, DUCT Hisagi 4 %.
   The anchor's Hisagi arms vs Kenpachi lose .98-1.0 to Kenpachi's `all`. "Strong" is one of PLAN4's anchor requirements.
   - Before the freeze, decide whether each side's library should also hold the strongest known whole-game arm (e.g. today's shipped arm
     0) as an extra entry.
   - That changes the arm set, so it belongs with the re-freeze in item 1.
6. **T0 against DUCT is still to measure.** B4's T0 tables were not on main. When they land, run
   `duct.py d2 --tier hard-shipped=sp/final --tier t0=<dir with <pair>-<character>.lisp>`. The DUCT and shipped rows are cached, so only T0
   plays.
7. **Mirror bells**: HH and II end at the bell a lot (section 2). Under the game's result a lead at the bell still decides, so the anchor
   works, but the HH mirror matrix is mostly bell decisions.
