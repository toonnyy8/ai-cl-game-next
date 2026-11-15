# arms4 / Hisagi: the code cell (PLAN4 §3, batch B3, 2026-11-15)

PLAN4 §3 gives Hisagi five general arms over `hisagi-hk-style` (`all`, `wake`, `kite`, `press`, `range`). `press` and `range` need his
range style's tunables as strategy keys, and the `kite` data cells need the kite's. This cell (one Opus code cell) routes them through
`style-knob` / `style-roll` (strategy-glue.lisp), the §11.6 pattern. It also drafts the five arms as unit forms and runs a first
descriptor probe. No table and no library entry changes. With no key set, play is identical (proofs below).

## 1. Every decision tunable (the list the cell started from)

| File | Special | Kind | Routed? |
|---|---|---|---|
| cpu-hisagi-range.lisp | `*hr-p*` | chance per close event (by difficulty) | **`:hr-p`** |
| | `*hr-close*` | m: the close event (and the TABA gap's TATAKI push) | **`:hr-close`** |
| | `*hr-near*` | m: a closing opponent's early event; the event ends past it | **`:hr-near`** |
| | `*hr-wa-pred*` | m: WA vs the back Step while he closes, pointer 1 | **`:hr-wa-pred`** |
| | `*hr-taba-p*` | chance: pointer 2's TABA > TATAKI (0 everywhere) | **`:hr-taba-p`** |
| | `*hr-edge*` | m from the wall: cornered | **`:hr-edge`** |
| | `*hr-home-p*` | chance per J string: AS1, back to pointer 1 | **`:hr-home-p`** |
| | `*hr-taba-band*`, `*hr-sa-band*` | lists (2.5 2.9), (2.5 4.5) | no: lists (the §6.4 precedent) |
| | the WA gap's DRIVE switch | `:dswitch` x `*cai-dswitch-dif*` | already a key (`:dswitch`, `:dswitch-map`) |
| | the WA gap's ŌGI roll | `*cai-cont-p*` (shared) | no: a shared knob (a plain BRAIN-ROLL), not this style's |
| | closing floor 0.004 m a step, WA's 14 frames | facts | no |
| | `hisagi-merged-style`: `:ken-ranged`, `:shikai-dswitch` | booleans by `getf` on the arm | already arm keys (booleans) |
| cpu-hk-hisagi.lisp | `*hkk-p*` | chance per approach event | **`:hkk-p`** |
| | `*hkk-near*`, `*hkk-near-bankai*` | m: the kite's start (Shikai / ranged) | **`:hkk-near`**, **`:hkk-near-bankai`** |
| | `*hkk-far*` | m: too late to back off | **`:hkk-far`** |
| | `*hkk-poke-min*`, `*hkk-poke-max*` | m: the poke's band after the back Step | **`:hkk-poke-min`**, **`:hkk-poke-max`** |
| | `*hkk-window*` | frames: the poke's window | **`:hkk-window`** |
| | `*hkw-p*`, `*hkw-margin*`, `*hkw-lead*`, `*hkw-guard-d*` | the wake rule | no: no searched arm of PLAN4 moves it |
| | `*hkb-below*`, `*hkb-range*`, `*hkb-p*` | the Reishi pot | no: same |
| cpu-ki-ken.lisp (played by the merged / hk styles) | the 25 `:kk-*` | KNOBS.md §6.1 | already keys (the brawler's Hoho in: `:kk-hoho-in-p`, `:kk-hin-fs`, `:kk-hoho-in-max`) |
| cpu-ih-hisagi-ihr1b2a0.lisp | `:ihx-*` | IH round 1's style | already keys (outside this cell) |

14 keys: KNOBS.md §6.6 (defaults, units, meaning, search ranges). Host check: `tests/duel-rules/style-knob.lisp` now scans the two Hisagi
files (67 keys: 53 + 7 `hr-` + 7 `hkk-`), the prefix list gains `hr-` and `hkk-` (never a bare `hk-`: `:hk-wake` / `:hk-pot` /
`:hk-kite` are the rules' on-keys), and the existing "no shipped unit, table, seed arm names a style key" check covers them: no unit names
one, so the allowed set did not widen.

## 2. Proofs (no play changes)

- Host tests: duel-rules 3591 checks ALL PASS; duel-control 124, input 33, touch 100 / 0 failures, cine 18 ALL PASS.
- `tools/pkgcheck.sh duel`: only `DUEL::APP`.
- `./build.sh duel` exit 0; the smoke (`tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 8`) exit 0.
- G2: `tools/simgate.py --cvc` PASS (ii 38, ik 27, kk 21 lines) and `tests/style-gates.py cvc dist/duel` PASS (the same three), against
  `tests/style-cvc-ref.txt` unchanged since 62d60a8c. G2's pairings (II IK KK) have no Hisagi, so G2 proves only that nothing shared moved; the next two proofs are the ones that see Hisagi.
- **Cross-build, the edited code running**: a baseline worktree at 62d60a8c against this branch, the native sim, seeds 501-510 HARD,
  `STRAT_HRANGE=1`; 16 jobs = 160 matches: KH and IH with both final tables (Hisagi each seat), and Hisagi's `a-hk-all`, `h1-range`,
  `a-hisagi-merged` against `none` (each seat). Every `duel hash` / `duel state` / gate row / `hrange` / `dswitch` line identical (5829
  lines). The edited code ran: 33 000-85 000 ranged-mode steps a job, 72-249 close events a job (the `hrange` counters), the kite on in
  `a-hk-all`.
- The shipped lookup, `fq/proof/identity.py` (raw file = the HARD lookup in one build), seeds 501-510, both seats: KH (Hisagi's row,
  `kh-hisagi` vs `kh-kenpachi`) 2 chunks identical, 0 differing, 666 lines; IH (`ih-hisagi` vs `ih-ichigo`) 2 identical, 0 differing, 500
  lines.
- snaptest, Hisagi vs Ichigo (pair gate 200730, HARD), seeds 1-4: P1 the draft `h4-range` (the new keys read) 1759 rollouts, and the
  shipped lookup (seeds 5-8) 1267 rollouts; straight = pollute but for the timing lines. fulltest, NORMAL: `h4-range` seeds 1-2 82 checks,
  the lookup seeds 11-12 64 checks, 0 differ.
- The sim build hash changes with the source text (222d63153e99 at 62d60a8c -> f9f904013360 here) though play does not: main re-pins
  `SP_BUILD` after this cell (PLAN4 §7).

## 3. The drafts (`arms4/hisagi.lisp`; raw files `arms4/hisagi/<id>.lisp` by `arms4/expand.lisp`)

| Arm | Style | Data | Own keys |
|---|---|---|---|
| `h4-all` (arm 0) | `:st-hisagi-hk` | `:d-hk-pot` (PLAN4 §3's literal "hk + the pot" = `:a-hk-pot`) | |
| `h4-wake` | `:st-hisagi-hk` | `:d-hk-wake` | |
| `h4-kite` | `:st-hisagi-hk` | `:d-hk-kite :d-kite` | |
| `h4-press` | `:st-hisagi-hk` | `:d-brawler` | `:hr-p 0` (the close rule off: the ranged mode's close events go to Kenpachi's KI code, `:ken-ranged`), the 6 m Hoho in (`:kk-hoho-in-p 1 :kk-hin-fs 100 :kk-hoho-in-max 6`), `:kk-step-p 0` |
| `h4-range` | `:st-hisagi-range` | `:d-dswitch :d-no-far-ns :d-kite` | `:hr-near 4.5 :hr-home-p 1` |

- Each job arm carries its own job only (no pot outside `all`), so the arms differ by job; a cell may add the pot back.
- `h4-range` is a second style function (no KI code anywhere: at range the MCTS and the generic CPU decide under the kite data, whose
  `:b-*` are live there). That was deliberate: with `:ken-ranged` (merged, hk) Kenpachi's code takes every step the close rule leaves and
  walks in, which would pull `range` back toward `all`. A table holding it needs `:keep-state t` (PLAN4 §3 already says 2-3 functions).
- `:d-brawler`'s and `:d-kite`'s `:b-*` are near inert over the hk style (Kenpachi's code returns T on free steps, KNOBS §0); `press`'s
  separation comes from `:hr-p` and the `:kk-*` keys.

## 4. Descriptor probe (dev seeds 1-20 x both seats = 40 matches a row (the brief's "seeds 1-40, 40 matches" read as 40 matches), HARD, the opponent's `none`; `strat-run.lisp` `STRAT_HRANGE`'s new `hdesc` line)

| Arm | vs | K.O. W-L-TO | mean distance (m) | share inside 3 m | ranged mode (share of steps) |
|---|---|---|---|---|---|
| `all` | Ichigo | 18-0-22 | 2.65 | 0.674 | 0.185 |
| `press` | Ichigo | 5-22-13 | 2.36 | 0.765 | 0.282 |
| `range` | Ichigo | 40-0-0 | 3.60 | 0.342 | 0.436 |
| `kite` | Ichigo | 32-0-8 | 3.31 | 0.449 | 0.193 |
| `wake` | Ichigo | 23-1-16 | 2.64 | 0.679 | 0.170 |
| `all` | Kenpachi | 34-0-6 | 2.26 | 0.764 | 0.212 |
| `press` | Kenpachi | 20-17-3 | 1.97 | 0.834 | 0.301 |
| `range` | Kenpachi | 30-3-7 | 2.92 | 0.553 | 0.690 |
| `kite` | Kenpachi | 24-2-14 | 2.62 | 0.659 | 0.163 |
| `wake` | Kenpachi | 40-0-0 | 2.32 | 0.747 | 0.225 |

Reading:
- `range` does its job: +0.95 / +0.66 m over `all`, half the time inside 3 m, two to three times the ranged-mode time. It also
  K.O.s Ichigo's `none` 40 of 40 (`all` 18).
- `press` moves the right way but by less than PLAN4's pre-registered bar (inside 3 m +0.09 / +0.07 against `all`'s +0.10). It loses
  whole: 5-22 against Ichigo, 20-17 against Kenpachi, so it fails proof 3 (K.O. >= 50 %) against Ichigo. That is the `press` cells' work,
  e.g. `:kk-reach-margin`, `:kk-step-in-p`, a softer Hoho in (`:kk-hin-fs` 200), or `:hr-p` by rule rather than 0.
- `kite` spaces out (+0.66 m against Ichigo) and keeps K.O.ing; `wake` plays like `all` on these descriptors, as expected. Its descriptor
  is the presses after a knockdown, which this probe does not count.
- The `hdesc` steps count both seats' whole match (cinematics included where `*flow*` is `:battle`). A ranged-mode step is a Hisagi
  `:bankai` step (`hrange`).

Reproduce: the baseline comparison and the probe were run by a scratch driver over `simlib.run_lisp('simgate/strat-run.lisp', [30000+s0,
31100+n, 81022, 200000+100*c1+10*c2])` with `STRAT_P1` / `STRAT_P2` = the raw arm file or `none` and `STRAT_HRANGE=1`.

## 5. The search cells (PLAN4 §3 B3, Hisagi side, 2026-11-15): set-up, written before any cell or proof run

Sim build: the pin `SP_BUILD=b835ac41b83b`. The worktree's own build hashed `c039496306c4`: same sources (`duel/`, `engine/`, the tools
identical to main's checkout), but the fas embeds its checkout's absolute path. So main's pinned `build/simgate/duel.fas` was copied in
(`cp`, newer than every source, so `simlib.build()` keeps it), and `build_hash()` = `b835ac41b83b`. Every eval, proof and bar run below used it.

**Targeted drafts** (`hisagi.lisp`, raw in `hisagi/`):
- `h4-hoho6` (vs K): x-kh-h-r1-b3a2's keys over the HK style (the pot, reach margin 1.0, the lunge, the 6 m Hoho in), no exchange keys.
- `h4-ihx` (vs I): `hisagi-ihr1b2a0-style` with c-ih-h-r1-b0a2's keys (`:ihx-reishi 0.5`: press into her shut-Hoho window when her Reishi
  is low). A third style function.

**T0 maps** (`cells-h/t0/*.json`, `band.py t0 --or`; Hisagi q 0.06, so a 2-group job leads by 0.03 > the 0.02 margin):

| Arm | KH job rules | IH job rules |
|---|---|---|
| `all` (arm 0) | everywhere else | everywhere else |
| `range` | G1 form 1 x mid, form 1 x far; G9 switch open | same |
| `press` | G7 his Reishi low; G0 his red | G7 **my Reishi low x his low**; G0 his red |
| `kite` | G2 attacking x close; G0 ahead | same |
| `wake` | G2 down | same |
| `hoho6` (KH) | G2 free x mid, free x far | |
| `ihx` (IH) | | G7 my Reishi high x hers low |
| HH mirror | KH's five general arms and jobs, no `:with` | |

PLAN4 gives both `press` and the IH targeted arm "her Reishi low" (G7). In IH the two split it by my Reishi, so neither ties the other.

**Opponents** (`cells-h/t0/`, built from their passing arms only):
- KH Kenpachi: all, spend, climb, bait (G2 down); q 0.075; `:with d-x-kh-k`. His rush / guard are being tuned by the other coordinator, so
  they are left out.
- IH Ichigo: all, brawl, keep, kessa2 with KI's v3 map; `:with d-x-ih-i`.
- Pop files `cells-h/pop-kh-K.json` and `pop-ih-I.json` hold his `none` and his T0, with no mix. So eval.py's groups are: anchor = `none`,
  mix = a 50/50 pool, rest = his T0.

**Scorer** (`cells-h/score.py`): the cell writes `arm.lisp`. The script puts it into its slot of Hisagi's T0 for the pairing, then runs
eval.py (K.O.-only) on block 300.
- General arms scored on both tables (`press`, `wake`): 50 seeds a seat each, score = the mean.
- `kite` (vs I first, as briefed) and the targeted arms: their one table at 100 seeds.

Baselines (the drafts' T0, block 300; K.O. W-L-TO by group anchor / mix / rest):

| Workspace | score | KH | IH |
|---|---|---|---|
| press, wake (both, 50 + 50) | 0.5686 | .5229: 95-1-4 / 57-35-8 / 5-81-14 | .6144: 89-6-5 / 67-31-2 / 29-70-1 |
| kite, ihx (IH, 100) | 0.6287 | | 182-10-8 / 127-70-3 / 69-129-2 |
| hoho6 (KH, 100) | 0.5016 | 194-1-5 / 100-84-16 / 7-163-30 | |

**Pre-registered one-job descriptors** (`proof.py` TESTS, `proof.py desc`): seeds 1-100, both seats, against his `none`, as T0 plays it,
measured against `h4-all`. A general arm must pass against both opponents. Pass = the descriptor + distinct from every sibling + K.O.
rate >= 0.50.

| Arm | Descriptor | Pass |
|---|---|---|
| press | share of steps inside 3 m | >= arm 0's + 0.10 (as registered in §4) |
| kite | mean distance | >= arm 0's + 0.5 m |
| range | mean distance **and** Bankai (ranged-mode) share | >= + 0.5 m **and** >= + 0.10 |
| wake | my action starts in his first 20 free steps after a knockdown, per knockdown | >= arm 0's x 1.3 (`hkw-step` presses J1 / NS when they fit) |
| hoho6 (vs K) | Steps + Hohos a match | >= arm 0's x 1.3 |
| ihx (vs I) | my move starts into his neutral (`nstart`) a match | >= arm 0's x 1.2 |

Bar A (on each T0, seeds 501-540, both seats, 80 matches, against the opponent's T0) and the HH mirror's (self-play) as PLAN4 §1 A.

## 6. The cells and the admission (2026-11-15)

**Cells: 14 of 14** (Sonnet 5.5; dream-rsi W = 4, `v1_rank_keep`, one round a workspace; workspaces `cells-h/ws-*`, each cell's
`proposal.md` and `scratch/`). press 2 x 2, kite 2 x 2, wake 1 x 2, ihx 1 x 2, hoho6 1 x 2. Every score was re-run by the coordinator from
the cell's `arm.lisp` before it was recorded (`score.json` in the node). One cell (kite b1_a0) never wrote `arm.lisp` and is recorded as
failed (its `COORDINATOR-NOTE.md`; its v1 is in its scratch). After batch 1 the coordinator measured each pick's descriptor (`screen.json`:
seeds 301-320, block 300, whole against `none`) and gave it to the batch-2 cells, which could also run the screen themselves.

| Workspace / cell | Change (over the draft) | block 300 | block 200 | screen (301-320) |
|---|---|---|---|---|
| draft T0 (both / IH / KH tables) | | .5686 / .6287 / .5016 | .5719 / .6072 / .4818 | |
| press b0_a0 | `:range 1.3 :b-walk-in 0.2 :kk-hoho-in-p 0.5` | .6014 | .5883 | close +.064 / +.038 |
| **press b0_a1** | `:range 0.6`, reach margin 1, lunge, Step in, no awakening press, Hoho safety 0 | .5964 | **.6079** | +.088 / +.070 |
| press b1_a0 | the close rule on and forward (`:hr-p 1 :hr-close 3.6 :hr-near 3.6 ...`) | .5964 | .5915 | +.015 / +.011 |
| press b1_a1 | `:hr-home-p 0 :hr-close 2 :hr-near 2` | .5736 | .5752 | +.075 / +.097 |
| kite b0_a0 | `:hkk-near 2.8 :hkk-far 2.4 :hkk-poke-min 3.4 :hkk-window 70` | .6337 | | mean d +.12 / +.66 |
| kite b0_a1 | the `:hkk-*` stretched (near 5 / 6, window 120) | .6304 | | +.25 / +.71 |
| kite b1_a0 | (failed: no arm.lisp) | fail | | (v1: +.22 / +.81) |
| **kite b1_a1** | the walk-in off, back Step to 6.5 m, `:hr-near 4.2 :hr-close 3.4`, `:hkk-near 4 / 5` | .6370 | .6172 (both tables .5817) | +.435 / +1.04 |
| wake b0_a0 | + the 6 m Hoho in, reach margin 1, `:kk-ns-safe-p 0.5` | .5948 | .5620 | wake / kd x1.30 / x1.32 |
| **wake b0_a1** | the same, `:kk-ns-safe-p 0.25` | .6079 | .5589 | x1.50 / x1.38 |
| **ihx b0_a0** | `:ihx-chase 0` | .6320 | .6072 | nstart x1.42 |
| ihx b0_a1 | + `:hoho 0.8` (inert: counts identical) | .6320 | | |
| hoho6 b0_a0 | none (six variants all .488-.502) | .5016 | | Steps + Hohos 30.6 vs 41.5 |
| **hoho6 b0_a1** | reach margin 3.5, no lunge, Step in, `:hoho 1.5`, back Step to 7 m, dodge | .5000 | .4884 | 60.1 vs 41.5 |

(Screens are vs Kenpachi / vs Ichigo. A bold cell = the one that went to the proof: its branch's best on block 200, or for one-branch
workspaces the one whose screen passed.)

- **No table score moved beyond noise on the held-out block.** The block-300 gains (press +.03, wake +.04) shrank to +.036 (press b0_a1) and
  **-.013** (wake) on block 200. kite, ihx and hoho6 stayed inside +-.015 on both blocks. A job arm plays a fraction of the judgements, and
  600 matches cannot resolve that.
- The cells moved the **descriptors** a lot once they were measured (wake x1.10 -> x1.50, hoho6 0.74 -> 1.45 of arm 0, kite vs K +.12 ->
  +.44). They did not move the scores.

**One-job proof** (`proof.py desc`, seeds 1-100 both seats, 200 matches an arm and opponent, against `none`; `proof/hisagi-vs-*.json`;
range and all also in `*-pre.json`; press b1_a0 in `*-press-b1.json`):

| Arm | vs Kenpachi | vs Ichigo | K.O. rate K / I | distinct | verdict |
|---|---|---|---|---|---|
| all | 2.19 m, close .770 | 2.37 m, close .749 | .99 / .565 | yes | arm 0 |
| range | mean d +.80, Bankai +.47 PASS | +.93, +.115 PASS | .925 / 1.00 | yes | **pass** |
| press (b0_a1) | close +.059 FAIL | +.053 FAIL | .98 / .98 | yes | **fail** (descriptor) |
| press (b1_a0) | close -.012 FAIL | -.004 FAIL | .995 / .935 | | **fail** |
| kite (b1_a1) | mean d **+.480 FAIL** | +1.06 PASS | .845 / .77 | yes | **fail** (vs K by 0.02 m) |
| wake (b0_a1) | wake / kd .707 vs .454 (x1.56) PASS | .666 vs .471 (x1.41) PASS | .965 / .895 | yes | **pass** |
| hoho6 (b0_a1, vs K) | Steps + Hohos 66.1 vs 39.5 (x1.67) PASS | | .905 | yes | **pass** |
| ihx (b0_a0, vs I) | | nstart 54.2 vs 38.0 (x1.43) PASS | 1.00 | yes | **pass** |

**Hisagi ends with three general arms (all, range, wake), the floor**, and one targeted arm a pairing (hoho6 vs K, ihx vs I). press does
not close in enough. Arm 0 is already inside 3 m for 75-77 % of the steps, and no key the cells found took it past +.09; b0_a1's own probes
put the rest in the base form. kite misses by 0.02 m against Kenpachi, whose `none` keeps the fight close. Neither bar moved after the run.

**T0s** (`cells-h/t0/`; arms in `cells-h/final/`; `band.py t0 --or`, q 0.06; bar A by `proof.py bar`, both seats, 80 matches; vs the
opponent's T0 of `cells-h/t0/`):

| T0 | arms (job) | seeds | changes median (mean), zero | arm shares | in / out of job | bar A | K.O. rate; Hisagi's K.O. wins |
|---|---|---|---|---|---|---|---|
| **KH** `t0-final-kh-hisagi` (v1 map) | all, range (G1 form 1 x mid / far, G9 switch open), wake (G2 down), hoho6 (G2 free x mid / far) | 501-540 | 35 (36.2), 0 | .230 / .466 / .271 / .032 | .89 / 0, .84 / 0, .29 / 0 | **pass** | .975; .013 |
| | | 541-580 (replication) | 36 (36.3), 0 | .143 / .527 / .296 / .034 | .90 / 0, .83 / 0, .27 / .0001 | **pass** | 1.00; .025 |
| IH `t0-final-ih-hisagi` (v1 map: as KH, ihx G7 my high x her low) | all, range, wake, ihx | 501-540 | 17, 0 | .171 / **.707** / **.096** / .025 | .89 / 0, .31 / 0, .17 / .0003 | **fail** (range > 70 %, two arms >= 10 %) | .975; .50 |
| **IH** `t0-final-ih-hisagi-v2` (range: G1 only) | all, range, wake, ihx | 501-540 | 40 (40.9), 0 | .330 / .505 / .109 / .057 | .94 / .017, .36 / 0, .42 / .004 | **pass** (selected) | 1.00; .30 |
| | | 541-580 (replication) | 42 (42.1), 0 | .352 / .443 / .137 / .068 | .93 / .012, .44 / 0, .47 / .005 | **pass** | 1.00; .287 |
| HH `t0-final-hh-hisagi` (general arms, KH jobs) | all, range, wake | 501-540 | 3 (6.3), **22** | **.963** / .021 / .016 | .95 / 0, .74 / 0 | **fail** (all four) | **.05** (76 of 80 at the bell) |
| HH `-v2` (range G1 only) | all, range, wake | 501-540 | 3 (7.0), 22 | .963 / .021 / .016 | .99 / .0002, .69 / 0 | **fail** | **.025** (78 of 80) |

For the record, the "full" tables (`t0-full-*`, with the cells' failing press and kite in): KH passes bar A (median 42.5; Hisagi's K.O. wins
.087), IH fails (range .629; K.O. wins .25), HH fails (all .703; self-play K.O. .25, 60 of 80 at the bell).

- **The IH v1 map failed, and v2 was designed after it on the same 80 matches**, so v2's 501-540 pass is a selected result. Why v1 failed:
  v1 gives range a G9 rule, "switch open". Once the gauge has been full, that rule fires on every judgement. Under `--or`, that keeps range
  at +0.03 over arm 0 everywhere. v2 drops the G9 rule. A replication on 541-580 (the table unchanged) passes too. KH keeps v1: it passes
  on both blocks, and range is under 70 % there.
- **The mirror stalls.** In self-play both seats sit in arm 0 at 96 % and 76-78 of 80 matches go to the bell. Range never gets its form
  (the ranged mode, 2 % of judgements) and wake has few knockdowns to act on. With three general arms there is nothing to switch to.
  The HH table needs a mirror-specific arm, or a fix for what stalls the mirror (PLAN4 §1 D: HH self-play 0 % with the 2026-11-15 arms).
  That is outside this batch.
- **Hisagi's tables lose to the opponents' T0s**: K.O. wins .013 / .025 against Kenpachi's KH T0, .30 / .29 against Ichigo's IH T0, as in
  the cells' scores (the rest group).

Files: the workspaces `cells-h/ws-*`; `cells-h/score.py` (the scorer) and `cells-h/admit/200-*.json` (block-200 rescores); the maps and
tables in `cells-h/t0/` (`bar-*.json` = bar A); the arms in `cells-h/final/` (press, kite = the failing picks); `proof/hisagi-vs-*.json`.
