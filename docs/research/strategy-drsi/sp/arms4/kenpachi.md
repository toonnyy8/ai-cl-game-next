# Kenpachi's arms (PLAN4 §3, batch B3, 2026-11-15)

Assembled first (PLAN4 §3); `rush` and `guard` are the two branches PLAN4 gives tuning cells (8 Sonnet cells, 2 x 4). Arms:
`kenpachi.lisp`, style `ken-kh-standoff-style` (the bait arm: `ken-kh-style`). Exchange units: `x-units/d-x-ki-k.lisp` (KI, from
`x-ki-k-r1-b0a2`), `x-units/d-x-kh-k.lisp` (KH, from `x-kh-k-r1-b0a2`), the §6.5 exchange keys only.

## The arms

| Arm | Job (PLAN4 §3) | Keys over the base | Job rules (T0) |
|---|---|---|---|
| `a4-k-all` (arm 0) | | the base | everywhere else |
| `a4-k-rush` | close in | `:range 0.5`, Step in 1, Hoho in 1 (`:kk-hin-fs 100`, from 6 m), `:kso-stale 0`, back Step 0, `:kk-reach-p 1`, Hoho-safety 0 | G3 his cells 0; G2 down; G8 late |
| `a4-k-guard` | hold and answer | `:range 1.3`, brawl read 1 from 4 m, dodge 1, back Step to 7 m, no lunge, Step / Hoho in 0, Hoho-safety 1, `:kso-stale 600`, `:kk-reach-p 1` | G0 ahead; G4 his burst |
| `a4-k-spend` | cells into Burst / Kikon | `:kikon 3.0`, `:kk-kikon-red-p 0`, `:kk-kikon-ptr-p 0` (`:other 10` is the base's) | G3 my cells >= 1; G4 my burst |
| `a4-k-climb` | build to the Bankai and awaken | `:kk-climb-p 1`, `:kk-bankai-p 1`, `:kk-bk-ns-p 0.25` | G0 behind x not awakened; G9 switch not open |
| `a4-k-bait` (vs H) | the wake-up bait | `:fn ken-kh-style`, `:khf-bait-p 1`, `:khf-bait-d 2.3` | G2 down |
| `a4-k-wave` (vs I) | the wave answer | `:kk-wave-p 0.9` | G10 his pointer 2 (her Getsuga: NS2, `ichigo.lisp`) |

The base is the 2026-11-15 arm 0 of both the KI and the KH table: `x-ki-k-r1-b0a2` and `x-kh-k-r1-b0a2` share every key but the exchange keys
(`:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0`, Step in 0, awaken 1, reach margin 0.35, wave 0, lunge 1, `:kso-stale 60`,
back Step 1 to 4.5 m, Bankai 0, reach 0.5, Hoho-safety 0.8, `:other 10`, `:kikon 0.3`). No arm names an exchange key.

**The bait arm's state**: `ken-kh-style` keeps a KHS and the stand-off style a KSO, and each restarts the other's state at a switch, with
`:keep-state t` or not (both include the KI style's KKS, which restarts with them).

## Pre-registered (before the first proof run)

Played whole against his `none`, HARD, seeds 1-100 both seats (200 matches), as T0 plays it: a 1-arm `:rb-sp2` table with the pairing's
`:with` unit. General arms against Ichigo (`d-x-ki-k`) and Hisagi (`d-x-kh-k`); the targeted ones against their opponent only.

| Arm | Descriptor | Pass |
|---|---|---|
| rush | share of steps inside 3 m | >= arm 0's + 0.10 |
| guard | Steps + Hohos a match | >= arm 0's x 1.3 |
| spend | Bursts + Kikons a match (PLAN4's example "SP presses x 1.5" reported beside it) | >= arm 0's x 1.5 |
| climb | share of steps in the Bankai | >= arm 0's + 0.05 |
| bait (vs H) | my action starts in his first 20 free steps after a knockdown, per knockdown | <= arm 0's x 0.5 |
| wave (vs I) | Steps + Hohos a match | >= arm 0's x 1.2 |

K.O. (>= 0.50 of matches end by any K.O.) and distinctness: as `ichigo.md`.

## Results (`proof.py desc`, sim build of 328ea625, seeds 1-100 both seats, 200 matches an arm; `proof/kenpachi-vs-*.json`)

Differences from arm 0 (arm 0's row: values). "Kikon" counts Kikon follow-ups started: his Kikon lock set anew, when a held SP's strike
lands (combat.lisp sets it once a hit). The follow-up may then be undone (a let-go) or cancelled. A dump of seed 1 (spend vs Ichigo) shows the
edges 150-600 frames apart: separate attempts, not flicker. Most never become a Kikon cinematic.

| vs | arm | mean d | close | mid | Bankai | SP a match | Burst | Kikon | Step+Hoho | wake / kd | acts | clash | K.O. | K.O. win | test |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| I | all | 1.91 | .863 | .096 | 0 | 88.2 | 6.9 | 2.0 | 10.7 | .88 | 229 | 49.5 | .96 | .72 | |
| I | rush | -.09 | +.011 | -.010 | 0 | -6.1 | | | +0.4 | | -5.4 | -3.3 | 1.00 | .785 | close **FAIL** |
| I | guard | +.33 | -.099 | +.115 | 0 | -38.6 | | | -2.4 | | -64.6 | -19.5 | .61 | .37 | Step+Hoho **FAIL** |
| I | spend | +.35 | -.092 | +.090 | 0 | -60.6 | 8.4 | 24.0 | +3.1 | | -80.6 | +14.5 | .87 | **.00** | Burst+Kikon 32.4 vs 8.9 PASS |
| I | climb | +.08 | -.028 | +.024 | +.149 | -36.6 | | | 0.0 | | -41.6 | -8.2 | .98 | .31 | Bankai PASS |
| I | wave (targeted) | -.08 | +.019 | -.012 | 0 | -0.9 | | | -2.9 | | -6.3 | -0.9 | .965 | .735 | Step+Hoho **FAIL** |
| H | all | 1.91 | .858 | .111 | 0 | 108.0 | 3.0 | 2.3 | 3.1 | .97 | 236 | 49.9 | 1.00 | 1.00 | |
| H | rush | -.02 | +.004 | -.004 | 0 | -9.6 | | | +1.2 | | -10.5 | -6.2 | 1.00 | 1.00 | close **FAIL** |
| H | guard | +.09 | -.018 | +.019 | 0 | -2.4 | | | +0.9 | | +2.3 | +2.9 | 1.00 | .995 | Step+Hoho **FAIL** |
| H | spend | +.48 | -.148 | +.141 | 0 | -14.6 | 14.1 | 52.6 | +7.2 | | +59.8 | +99.9 | .95 | .18 | Burst+Kikon 66.7 vs 5.3 PASS |
| H | climb | +.05 | -.030 | +.027 | +.115 | -33.3 | | | +2.1 | | -23.0 | -5.5 | 1.00 | .97 | Bankai PASS |
| H | bait (targeted) | -.04 | -.005 | +.008 | 0 | +9.4 | | | +0.2 | .28 vs .97 | +38.0 | +16.0 | .995 | .985 | wake / kd PASS |

Every arm ends its matches (K.O. >= 0.61) and **no two arms are within tolerance of each other** against either opponent. An arm is
shared by its tables, so it **passes only if it passes against each opponent it plays**. spend's pass against Ichigo rests on the Kikon
follow-ups: its Bursts alone are 8.4 vs 6.9, x1.2.

| Arm | Verdict |
|---|---|
| spend | **pass**, but a losing arm whole (K.O. win .00 vs I, .18 vs H). Against Hisagi it starts 53 Kikon follow-ups a match and clashes 150 times (x3). Likely his bind cancels the follow-ups; not traced |
| climb | **pass**: Bankai 15 % / 12 % of the steps (arm 0: never, its `:kk-bankai-p` is 0) |
| bait (vs H) | **pass**: 0.28 action starts per knockdown in his first 20 free steps (arm 0: 0.97), and it wins as arm 0 does |
| rush | **fail**: the descriptor has a ceiling (arm 0 is already inside 3 m for 86 % of the steps against both) and the keys barely move play (6-10 fewer SP moves a match) |
| guard | **fail**: vs Ichigo it changes play a lot (mean distance +0.33 m, 65 fewer action starts, close -0.10) but it does so by doing less (Steps + Hohos -2.4, not up), and it is weak (K.O. .61, K.O. win .37); vs Hisagi it is almost arm 0 |
| wave (vs I) | **fail**: Steps + Hohos fall 2.9 a match. The answer by `*kk-wave-mix*` is mostly a cut or a Hoho in, and Ichigo's `none` rarely runs the Getsuga route at him |

**General arms that pass: all, spend, climb: exactly the floor of 3.** Targeted: bait passes, wave fails.

**Which need the tuning cells (note for the lead).** Both, but for different reasons:
- **guard** (4 cells): it has a working lever: distance up, starts down. It needs cells to stay in its job without losing (K.O. win .37 vs
  I) and to act at all against Hisagi. Its descriptor should become what it does: mean distance (+0.33 vs I already) or close share down,
  not Steps + Hohos.
- **rush** (4 cells): first a new descriptor, because "inside 3 m" is at its ceiling. A rate of contact would do: SP moves or action starts a
  match up, or the time from a free step to his guard / hit. Then cells for keys that change it. As assembled it is nearly arm 0.

## T0 (`band.py t0 --or`, **q 0.075**, keep-state, margin 0.02, period 30)

`rush` spans 3 groups. With `--or` a single firing group gives q / 3, and band.py asserts q / n > margin, which fails at q 0.06
(0.02 = 0.02). So Kenpachi's tables take q 0.075, which gives q / 3 = 0.025.

- **KI** (`t0/t0-ki-kenpachi.lisp`): arms all, rush, guard, spend, climb, wave; `:with d-x-ki-k`. Job rules per arm: 0 / 9 / 14 / 8 / 11 / 3.
- **KK** (`t0/t0-kk-kenpachi.lisp`): the five general arms, no `:with` (no mirror exchange arm exists).

Bar A on seeds 501-540, 80 matches (`t0/bar-ki-501-540.json`, `t0/bar-kk-501-540.json`):

| Row | changes a match (median / mean / zero) | judgements a match | arm shares | in vs out of job | K.O. rate | bar A |
|---|---|---|---|---|---|---|
| KI, Kenpachi vs Ichigo's T0 | 18.5 / 18.7 / 0 | 112.1 | all .064, rush .575, guard .013, spend .175, climb .117, wave .057 | rush .80 / .00, guard .23 / 0, spend .61 / 0, climb .31 / 0, wave .92 / 0 | 1.00 (he wins .05) | **all four pass** |
| KK, mirror | 33 / 34.4 / 0 | 168.7 | all .040, rush .494, guard .149, spend .211, climb .105 | rush .64 / .00, guard .36 / 0, spend .50 / 0, climb .27 / 0 | 1.00 | **all four pass** |

These tables carry the failing arms (rush, guard, wave) as assembled. The switching passes by construction; the jobs inside it are not yet
proved.

## Re-registered for the cells (cells-k, PLAN4 B3 search, 2026-11-15; written BEFORE any cell or baseline ran)

The search cells (`cells-k/`) tune `rush`, `guard` and `wave`. The two failing bars above are replaced here, before any cell ran, for the
reasons the proof gave. The bar values below do not move after the cells. `proof.py` TESTS / TOL carry them.

| Arm | Descriptor (against arm 0 `a4-k-all`) | Pass | Measured against | Why |
|---|---|---|---|---|
| rush | `nstart_r`: my move starts while he is `:idle` / `:run`, per 1000 steps, pooled over the 200 matches (new, tool only: `nstart` / `steps`) | >= arm 0's x 1.25 | Ichigo's and Hisagi's `none` (both) | "close in" = start contact more often. "Inside 3 m" sits at a ceiling (.86). A per-match count would fall when a rush shortens the match (vs Hisagi arm 0 already K.O.s 1.00), so the count is taken per step |
| guard | `mean_d`: mean distance | >= arm 0's + 0.30 m | Ichigo's and Hisagi's `none` (both) | "hold and answer" = keep him out. The assembled guard showed +0.33 m vs Ichigo (and +0.09 vs Hisagi) on the proof seeds 1-100 before this bar was set. 0.30 m is chosen to clear the distinctness tolerance on mean distance (0.25 m) |
| wave (vs I) | `evade`: Steps + Hohos a match | >= arm 0's x 1.2 (unchanged) | **Ichigo's `a4-i-keep` played whole** (1-arm table, `d-x-ki-i`; `proof.py desc --opp`) | the wave answer acts only on her pointer-2 Getsuga route, which her `none` rarely runs (the failure above). `keep` is her arm that runs it. **A deviation from PLAN4 §3.1** ("against his `none`") |

- K.O. (>= 0.50 of matches end by any K.O.) and distinctness from the siblings are measured against `none`, as for every sibling, wave
  included (a second desc run against `none`). Comparing wave-vs-keep with siblings-vs-none would mean nothing.
- An arm shared by tables passes only if it passes against each opponent it plays (rush, guard: Ichigo and Hisagi).
- The proof runs at admission: seeds 1-100 both seats, HARD, all of Kenpachi's general arms in one `desc` call per opponent (one build for
  the distinctness test).
- Job rules in T0 are unchanged (`t0/ki-kenpachi.json`, `t0/kk-kenpachi.json`). The new KH table (`t0/kh-kenpachi.json`) gives G2 down to
  bait and keeps rush on G3 his cells 0 and G8 late.
- Ichigo's targeted arm vs Hisagi (`cells-k/i-vsh`): its job is found by the search, so it cannot be registered here. Each cell writes its
  `job.json` (the job rules) and its descriptor and bar (in `proposal.md`, from proof.py's TOL descriptors, against Hisagi's `none` unless
  it names one of his arms) **before its first eval**. Admission tests the cell's own registration (`ichigo.md`).

## cells-k results (2026-11-15)

**Setup.**
- Four dream-rsi workspaces under `cells-k/`, each with W 4 and `v1_rank_keep`: `k-rush` (2 x 2), `k-guard` (2 x 2), `k-wave` (1 x 2),
  `i-vsh` (1 x 2). 12 Sonnet cells in all, and every cell is recorded.
- Scorer: `cells-k/score.py`. The side's T0 is written with the arm in its slot (the maps the cells saw: `cells-k/maps-at-search/`), then
  eval.py scores it K.O.-only against the opponent's `none` and his T0 (`cells-k/pop-*.json`). Cells ran on block 300. I rescored the best
  candidate of each branch on block 200 (`cells-k/admit/`).
- Sim builds:
  - eval.py ran from the main checkout at the pin `b835ac41b83b`. A worktree's `duel.fas` embeds its path, so its hash differs (be456569b50a)
    though duel/, engine/ and the tools are identical to main 59a9f779.
  - proof.py ran from the worktree build. Arm 0's proof rows reproduce the earlier sheets exactly (1.907 m, .863 vs Ichigo).

**Scores** (K.O.-only eval score: block 300 per cell, then block 200 for the best candidate of each branch):

| Arm | baseline 300 / 200 | b0 cells | b1 cells | best of each branch on 200 |
|---|---|---|---|---|
| rush | .6452 / .632 | a0 .6543, a1 .6518 | a0 .745, a1 .7459 | b0_a0 .6386; **b1_a1 .7409** (KI .52 vs .31) |
| guard | .6452 / .632 | a0 .6468, a1 .6567 | a0 .6493, a1 .6567 | b0_a1 .6345; b1_a1 .632 |
| wave (KI only) | .3234 / .3102 | a0 .3168, a1 .3432 | | b0_a1 **.3828** |

- rush b1's gain is real (block 200 replicates it). It comes from `:kikon 0.1` (with `:ns 0.5`, `:kk-reach-margin` 0-0.2), not from more
  contact. Cutting the Kikon hold to 0.1 of its chance inside rush's rules lifts Kenpachi's KI table from 18-21 to 64-78 K.O. wins of 200
  against Ichigo's T0. b1_a0 showed `:kikon 1.5` is a disaster (KI .04).
- guard: no score moved past noise. The only lever that moved distance was `:range`, which drops the K.O. rate.
- wave: the Hoho in from 8 m (`:kk-hin-fs 0`), Step in and the 1.0 answer. A gain on both blocks.

**One-job proofs** (seeds 1-100 both seats, 200 matches an arm, `cells-k/admit/proof*-kenpachi-vs-*.json`). By the rule set before the
proofs ran, the branch with the higher block-200 score was proved first and, if it failed, the other branch's best:

| Arm (candidate) | vs Ichigo `none` | vs Hisagi `none` | K.O. | distinct | verdict |
|---|---|---|---|---|---|
| rush b1_a1 | nstart_r 1.421 vs 1.291 (x1.10) FAIL | 1.126 vs 1.021 (x1.10) FAIL | 1.00 / 1.00 | yes | **fail** |
| rush b0_a0 | x1.125 FAIL | x1.26 PASS | 1.00 / 1.00 | yes | **fail** |
| guard b0_a1 | mean_d +0.356 PASS | +0.140 FAIL | .745 / 1.00 | yes | **fail** |
| guard b1_a1 | +0.372 PASS | +0.102 FAIL | .505 / 1.00 | yes | **fail** |
| wave b0_a1 | vs `a4-i-keep` (registered): evade 33.47 vs 32.37 (x1.03) FAIL. Against `none` (not the bar): x1.67, K.O. .97 | | .97 | yes | **fail** |

The style keys move nstart_r only x1.10-1.14 against Ichigo, which falls short of rush's x1.25. Against Hisagi's `none` he sets the distance
whatever guard does (+0.10-0.14 m). Against `keep`, wave's answer swaps Steps for Hoho-ins and dodges (Steps + Hohos flat). Its whole-match
win against `keep` is .33 against arm 0's .025, so it wins the situation, but not by the registered descriptor.

**Admitted: none.** Kenpachi keeps the general arms all, spend and climb (the floor of 3) and the bait vs Hisagi. The candidates stay in the
workspaces; `kenpachi.lisp` is unchanged. Note for the lead: the `:kikon 0.1` lever is a whole-table finding (perhaps arm 0's or spend's
key), not rush's job.

**T0s after the search** (only arms that passed their proof; `t0/ki-kenpachi.json`, `kk-kenpachi.json`, `kh-kenpachi.json`, q 0.075
`--or`). Bar A on seeds 501-540, both seats, 80 matches (`t0/bar-*-501-540-b3.json`):

| Row (side) | changes median (mean) / zero | judgements | arm shares | in / out of job | K.O. rate | bar A |
|---|---|---|---|---|---|---|
| KI Kenpachi (all, spend, climb) vs Ichigo's KI T0 | 14 (14.2) / 0 | 128.9 | .519 / .225 / .256 | .87 / 0, .83 / 0 | 1.00 (he wins .037) | pass |
| KI Ichigo (same run) | 21 (20.7) / 0 | 129.6 | .218 / .083 / .267 / .432 | .26 / 0, .39 / 0, 1.0 / 0 | 1.00 (.963) | pass |
| KK mirror | 34.5 (34.8) / 0 | 230.9 | .352 / .416 / .231 | .87 / 0, .73 / 0 | .975 | pass |
| KH Kenpachi (all, spend, climb, bait) vs Hisagi's KH T0 | 88 (80.2) / 0 | 268.7 | .249 / .238 / .226 / .288 | .60 / 0, .64 / 0, .98 / 0 | **.75** (he wins .738) | pass |
| KH Hisagi (opponent T0, five drafts) | 48 (45.9) / 0 | 236.4 | .252 / .173 / .114 / .290 / .171 | all x2 | .75 | pass |

KH has 25 % time-outs (spend loses whole against Hisagi, K.O. win .18).
