# Ichigo's arms (PLAN4 §3, batch B3, 2026-11-15)

Assembled, no search (PLAN4 §3: "Ichigo: none"). Arms: `ichigo.lisp`, one style function `ichigo-ki-r2b2a1-style`. Exchange units:
`x-units/d-x-ki-i.lisp` (KI, from `x-ki-i-r1-b0a2`) and `x-units/d-x-ih-i.lisp` (IH, from `x-ih-i-r1-b2a1`), the §6.5 exchange keys only.

**Status (2026-11-15, Ichigo's code cell)**: the four mode arms below failed. After the code cell's keys, the arms are `all`, `brawl`, `keep`
and `kessa2`, and all four pass. The registered T0 map (v1) fails bar A on switching. v3, chosen afterwards, passes on 501-540 and in a replication on 541-580. Both are in "Re-jobbed arms" at the end.

## The arms (first drafts)

| Arm | Job (PLAN4 §3) | Keys | Job rules (T0) |
|---|---|---|---|
| `a4-i-all` (arm 0) | the mode mix | the common base, no `:iks-mix-*` key: the style's own mix for the tier (HARD 0.04 / 0.26 / 0.26 / 0.28 / 0.16) | everywhere else |
| `a4-i-whiff` | hover at his whiff distance | whiff 1, the other four 0 | G2 attacking x mid; G1 sealed x mid |
| `a4-i-space` | far spacing and the lunge | space 1, the rest 0 | G1 far; G6 my wall near |
| `a4-i-ptr3` | pointer-3 pressure, the shut-gauge lunge | ptr3 1, the rest 0 | G3 his cells 0; G9 pointer 3 |
| `a4-i-kessa` | awakened chains | kessa 1, the rest 0 | G0 awakened; G1 form 1 |

The common base is the KI table's 2026-11-15 arm 0 (`x-ki-i-r1-b0a2`) without its five exchange keys and its three mix keys: `:ikw-roll-*`,
`:b-*` and their four rules, `:range 0.7 ... :p 1.0`, `:iks-wait-max 40 :iks-gap-p 1 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5
:iks-meaty-p 0`. The IH arm (`x-ih-i-r1-b2a1`) differs in a few style keys (`:iks-meaty-far 4.5`, `:iks-gap-wait 5.5`, `:range 0.5`,
`:awaken 2.0`, no `:ikw-roll-*`, `:iks-getsuga-min` / `:iks-meaty-p` at the defaults). The general arms are shared by the three tables
(PLAN4 §3), so IH's table plays KI's style keys. That is a deviation from P2, whose arms were "the side's shipped arm with a few keys
changed".

**Arm 0's mix**: no mix key, so arm 0 follows the tier (HARD the mix above, EASY generic only, NORMAL 0.88 generic). The job arms name all
five, so they are the same at every tier.

## Pre-registered (before the first proof run)

Played whole against his `none`, HARD, seeds 1-100 both seats (200 matches), as T0 plays it: a 1-arm `:rb-sp2` table (keep-state, period 30)
with the pairing's `:with` unit. Opponents: Kenpachi (`d-x-ki-i`) and Hisagi (`d-x-ih-i`).

| Arm | Descriptor | Pass |
|---|---|---|
| whiff | share of steps at 3-6 m (`mid`) | >= arm 0's + 0.05 |
| space | mean distance | >= arm 0's + 0.5 m |
| ptr3 | share of steps at SP pointer 3 | >= arm 0's + 0.10 |
| kessa | share of steps awakened | >= arm 0's + 0.05 |

- **K.O.**: the share of matches that end by any K.O. (sw.py's `ko_rate`) >= 0.50. The K.O.-win share is reported beside it.
- **Distinct**: two arms are not distinct when they are within tolerance on every descriptor: mean distance 0.25 m; the shares (close, mid,
  far, awakened, Bankai, released) 0.03; pointer 3 0.05; the counts a match (SP moves, Bursts, Kikons, Burst + Kikon, Steps + Hohos,
  action starts, clashes) and wake presses per knockdown 15 % of the larger (at least 0.15).

## Results (`proof.py desc`, sim build of 328ea625, seeds 1-100 both seats, 200 matches an arm; `proof/ichigo-vs-*.json`)

Differences from arm 0 (arm 0's row: values):

| vs | arm | mean d | close | mid | far | ptr 3 | awakened | SP a match | Step+Hoho | acts | clash | K.O. | K.O. win | test | not distinct from |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| K | all | 2.34 | .709 | .225 | .066 | .707 | .447 | 53.8 | 23.0 | 212 | 13.0 | 1.00 | 1.00 | | whiff, kessa |
| K | whiff | +.05 | -.006 | +.002 | +.004 | +.021 | +.007 | -0.5 | +2.9 | +1.6 | -1.3 | 1.00 | 1.00 | mid **FAIL** | all, ptr3, kessa |
| K | space | +.11 | -.020 | +.008 | +.013 | +.044 | -.006 | +0.7 | +4.3 | +6.0 | -1.5 | 1.00 | 1.00 | mean d **FAIL** | |
| K | ptr3 | +.04 | -.002 | -.004 | +.006 | +.023 | +.007 | -0.3 | +3.7 | +4.4 | -2.6 | 1.00 | 1.00 | ptr 3 **FAIL** | whiff |
| K | kessa | +.05 | -.006 | +.002 | +.004 | +.026 | +.012 | -0.2 | +2.6 | +4.1 | -0.5 | 1.00 | 1.00 | awakened **FAIL** | all, whiff |
| H | all | 3.02 | .569 | .323 | .107 | .681 | .603 | 55.4 | 66.6 | 275 | 29.1 | .99 | .875 | | whiff, kessa |
| H | whiff | +.04 | -.003 | +.001 | +.002 | -.015 | -.004 | 0.0 | +2.3 | +3.2 | -1.7 | .96 | .83 | mid **FAIL** | all, kessa |
| H | space | +.25 | -.068 | +.045 | +.023 | -.026 | +.053 | -2.4 | +7.5 | +10.6 | +4.1 | .94 | .84 | mean d **FAIL** | |
| H | ptr3 | -.10 | +.048 | -.046 | -.001 | -.027 | -.012 | +1.9 | -2.1 | +7.0 | +1.8 | .97 | .825 | ptr 3 **FAIL** | |
| H | kessa | -.02 | +.013 | -.016 | +.003 | -.009 | -.021 | +0.6 | -3.7 | +1.7 | -0.9 | .965 | .86 | awakened **FAIL** | all, whiff |

**Every job arm fails its descriptor against both opponents, and whiff / kessa are not distinct from arm 0.** All of them end their
matches (K.O. >= 0.94). Under PLAN4 §3 that leaves Ichigo with one general arm (`all`), under the floor of 3: **stop and report**.

**Why** (cpu-ki-ichigo.lisp): at HARD `*iks-patient-p*` is T and `*iks-patient-forms*` is `(:base)`. So in the sealed form every style
mode is patient: it hovers and answers through the whiff punish / confirm and the timed Hoho, the episode never goes to the generic CPU
(`:iks-wait-max` is not read), and `:ptr3` / `:kessa` "hover too" (IKS-NEUTRAL). The hover band is the one thing a mode picks there, and
`*iks-bait-modes*` gives whiff, ptr3 and kessa the same bait band (2.3-2.7 m); space alone keeps `*iks-hover*`. The modes differ only in
the KESSA form and in the in-move steering, too little to move any descriptor. The opponent also sets the distance: Kenpachi's `none` keeps
71 % of the steps inside 3 m whatever Ichigo plays. P2's whole-game scores were outcomes, not behaviour.

**One rewrite tried** (not kept): `space2` = space + `:iks-retreat-p 1 :iks-gap-wait 7.5 :iks-getsuga-min 6.0 :range 1.3`: mean distance
+0.44 m vs K, +0.23 m vs H, still under +0.5.

**Two pre-registration flaws**, kept as registered: ptr3's descriptor sits near a ceiling (arm 0 is at pointer 3 for 0.70 of its steps), and
whiff's "mid" share is the wrong sign for a mode that hovers at 2.3-2.7 m at HARD. A whiff test on the timed Hoho or punish count would
need a new counter.

**Diagnostic at NORMAL** (`proof.py desc --dif normal`, the same seeds; `proof/ichigo-vs-*-normal.json`; not a proof, which is HARD). At
NORMAL both `*iks-patient-p*` and `*iks-bait-modes*` are NIL, and arm 0's mix is 0.88 generic.
- Every job arm now differs from arm 0 by a lot: mean distance +0.47 to +0.55 m vs K, +1.0 to +1.2 m vs H; pointer 3 +0.26 to +0.38.
  whiff, space and ptr3 pass their tests against both opponents. kessa fails vs K (awakened +0.040).
- But the modes do not separate from one another: whiff ~ space ~ ptr3 vs K, and whiff ~ space ~ kessa vs H.
- With patience off, what separates is style against generic, not mode against mode. Whiff and space then share `*iks-hover*`, and the
  rest of what tells the modes apart is small.

**What would make them one-job**: more than patience. A code cell would need to expose:
- patience as a number key (`:iks-patient` 0 / 1, through `style-knob`);
- the per-mode hover bands as `-lo` / `-hi` keys (KNOBS.md §6.4 lists `*iks-hover*` / `*iks-bait-hover*` as split candidates);
- possibly the space lunge's band.

That is game code (an Opus code cell, as PLAN4 §3 plans for Hisagi), outside this batch. The other route is to define Ichigo's jobs by what
does separate: generic brawl against the patient style, the KESSA form, and the pointer-2 Getsuga keep-away (`:iks-retreat-p` /
`:iks-getsuga-min`, PLAN4's targeted vs K arm).

## T0 (KI, Ichigo's side; `t0/t0-ki-ichigo.lisp`, `band.py t0 --or`, q 0.06, `:with d-x-ki-i`)

Written from these five arms as they stand, so it measures the switching, not the jobs. Bar A on seeds 501-540 against Kenpachi's T0, both
seats, 80 matches (`t0/bar-ki-501-540.json`):
- changes a match: median 12, mean 12.4, no match without one; 122.7 judgements a match;
- arm shares: all .029, whiff .047, space .040, ptr3 .464, kessa .420. **Only 2 arms at >= 10 %: fails.** ptr3's G3 job (his cells 0)
  fires on 89 % of judgements and kessa's G0 job on every awakened one, so they crowd out arm 0;
- in-job vs out-of-job share: whiff .172 / .009, space .127 / .000, ptr3 .521 / .000, kessa .956 / .000 (all pass x2);
- K.O. rate 1.00 (Ichigo wins 0.95 by K.O.).

(The first drafts' map, `t0/ki-ichigo.json` at 1170f748: whiff G2 `(:ost :atk) (:dm :m-mid)` / G1 `(:form :no) (:dm :m-mid)`; space G1
`(:dm :m-far)` / G6 `(:wall :w-near)`; ptr3 G3 `(:ocell :no)` / G9 `(:mptr :k3)`; kessa G0 `(:awst :k2)` / G1 `(:form :yes)`. Its bar file
was `t0/bar-ki-501-540.json`, replaced below.)

## Re-jobbed arms (Ichigo's code cell, PLAN4 B3, 2026-11-15)

After the failure above, the lead's decision was to do both: expose the switches as style keys (KNOBS.md §6.7), and define the jobs by
what separates. The code cell's keys:
- `:iks-patient-p` and `:iks-p2-wait`: 0 / 1 switches, through STYLE-ON;
- `:iks-hover-add` / `:iks-bait-hover-add`: metres added to the hover tables;
- `:iks-retreat-to`;
- `:iks-steer-to`: the steered string's press count (5 = AS3, 3 = AS2);
- `:iks-kessa-chain-lo` / `-hi`: turn on KESSA pointer 1's chains.

The four failing drafts left `ichigo.lisp`. Their plists stay in git (`ichigo.lisp` and `t0/t0-ki-ichigo.arms` at 1170f748).

### Design probes (dev seeds 201-220, both seats, 40 matches an arm and opponent; not the proof seeds)

Differences from arm 0 (vs Kenpachi / vs Hisagi) in the probes that shaped the drafts:

| Candidate | Keys | close | mean d | p2 | awakened mean d (`k_d`) | K.O. | What it showed |
|---|---|---|---|---|---|---|---|
| brawl-p3 (kept) | patient 0, gap 0, ptr3 | +.17 / +.18 | -.68 / -.70 | | -.53 / -.54 | 1.0 / .95 | closes in, both forms |
| brawl-gen | gap 0, generic 1 | +.18 / | -.60 / | | | 1.0 / | pointer 3 lost (-.60) |
| brawl-p0 | patient 0, gap 0, the tier's mix | +.13 / +.08 | | | | | weaker vs Hisagi |
| keep-a | steer 3, p2-wait 0 | | +.80 / +1.65 | +.53 / +.66 | | 1.0 / **.50** | time-outs vs Hisagi (K.O. win .025) |
| keep-l (kept) | keep-a + behind: steer 5, retreat 0 | | +.79 / +.91 | +.52 / +.42 | | 1.0 / .73 | fights back when behind |
| keep-c, keep-g, keep-r | getsuga-min 6.0, 7.0; retreat 0.5 | | | | | .40-.70 vs H | no better |
| kessa (old), kessa + chains | kessa 1 (+ chain 2.8-3.4) | | -.02 / +.09 | | .00 / +.19 | | see note 1 |
| kessa + awakened gap 0 | rule `(:awk :yes)` -> gap 0 | | | | -.34 / -.20 | | the gap's share of KESSA |
| kessa2 (kept) | kessa 1; awakened: gap 0, wait-max 0 | | -.22 / -.27 | | -.49 / -.43 | 1.0 / 1.0 | KESSA's neutral goes to the generic at once |
| space-g, space-h | space 1, hover +1.0 (gap on / off) | | +.09 / +.32; -.06 | | | | see note 2 |

1. The shut-gauge lunge takes KESSA's pointer-3 steps in every mode, because the base has `:iks-gap-p 1` and `:iks-gap-fs 150`. Chains at
   pointer 1 are rare.
2. The hover is not where the time goes, so there is no fifth arm.

### Pre-registered (written before the proof run on seeds 1-100; `proof.py` TESTS)

Played as before: whole against his `none`, HARD, seeds 1-100 both seats (200 matches), a 1-arm `:rb-sp2` table (keep-state, period 30)
with the pairing's `:with` unit. Opponents: Kenpachi (`d-x-ki-i`) and Hisagi (`d-x-ih-i`). Arm 0 is re-run in this build.

| Arm | Job | Descriptor (against arm 0, both opponents) | T0 job rules (KI) |
|---|---|---|---|
| `a4-i-all` | the patient hover-and-punish | arm 0 | everywhere else |
| `a4-i-brawl` | close pressure | share of steps inside 3 m >= + 0.10 | G2 `(:ost :free) (:dm :m-close)` |
| `a4-i-keep` | the pointer-2 Getsuga at range, distance held | share of steps at pointer 2 >= + 0.20 **and** mean distance >= + 0.5 m | G8 `(:lead :ahead)` |
| `a4-i-kessa2` | awakened pressure (KESSA) | mean distance of the awakened steps (`k_d`, pooled) <= - 0.30 m | G0 `(:awst :k2)`, G1 `(:form :yes)` (as PLAN4 §3) |

- New descriptors, tool-only:
  - `strat-run.lisp`'s desc line gains `nstart`, `asp` and `adsum`, and `proof.py` reads `p2` too.
  - `p2`: share of steps at pointer 2.
  - `nstart`: my move starts while he is `:idle` / `:run`, a match.
  - `k_sp`: SP moves per 1000 awakened steps, pooled.
  - `k_d`: described in the table above.
- Distinctness tolerances for the new descriptors: `p2` 0.05, `k_d` 0.25 m, `nstart` and `k_sp` 15 % of the larger (at least 0.15). This
  widens the test for every character's later runs (one more way to differ). Kenpachi's sheet was written before it.
- K.O. >= 0.50 and the distinctness test work as before. Pass = the descriptor (both opponents) + distinct from every sibling + the K.O.
  rate.
- Need >= 3 passing general arms (all + 2). No bar moves after the run.

### Results (`proof.py desc`, sim build 84bd53aad9af, seeds 1-100 both seats, 200 matches an arm; `proof/ichigo-vs-*.json`, which replace the first drafts' files: those are in git at 1170f748)

Arm 0's row gives values. The other rows give differences from arm 0. Arm 0 plays as before: 2.343 m, .709 inside 3 m vs K, the same as the
first run.

| vs | arm | mean d | close | far | p2 | p3 | `k_d` | SP a match | Step+Hoho | K.O. | K.O. win | test | distinct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| K | all | 2.343 | .709 | .066 | .153 | .707 | 2.340 | 53.8 | 23.0 | 1.00 | 1.00 | | yes |
| K | brawl | -.695 | **+.179** | -.041 | -.043 | -.092 | -.598 | +3.0 | -19.7 | 1.00 | 1.00 | close PASS | yes |
| K | keep | **+.790** | -.118 | +.115 | **+.504** | -.586 | +.816 | -13.1 | +10.6 | 1.00 | .935 | p2 + mean d PASS | yes |
| K | kessa2 | -.210 | +.060 | -.008 | +.002 | +.008 | **-.494** | -0.2 | -8.1 | 1.00 | 1.00 | `k_d` PASS | yes |
| H | all | 3.016 | .569 | .107 | .102 | .681 | 3.107 | 55.4 | 66.6 | .99 | .875 | | yes |
| H | brawl | -.692 | **+.183** | -.061 | +.047 | -.125 | -.619 | +7.6 | -45.9 | .995 | .89 | close PASS | yes |
| H | keep | **+.863** | -.175 | +.097 | **+.427** | -.391 | +.762 | -15.1 | +25.9 | .79 | .375 | p2 + mean d PASS | yes |
| H | kessa2 | -.338 | +.105 | -.034 | +.037 | -.005 | **-.557** | +1.1 | -26.5 | .98 | .92 | `k_d` PASS | yes |

**All three new arms pass**: the descriptor against both opponents, distinct from every sibling, K.O. >= .79. With `all`, Ichigo has four
general arms (the floor is 3). Notes:
- brawl and kessa2 both close in while awakened (`k_d` -.60 / -.49 vs K). They differ on the close share (+.18 against +.06 vs K) and on
  everything sealed.
- keep loses whole to Hisagi's `none`. Hisagi K.O.s it in 41.5 % of the matches and 21 % are time-outs. Like Kenpachi's rush against
  Ichigo, a job arm may lose whole (PLAN4 §3).

### T0 (KI, Ichigo's side; `t0/t0-ki-ichigo.lisp`, `band.py t0 --or`, q 0.06, `:with d-x-ki-i`)

The job rules are the T0 design, not a registered bar. I wrote three maps in turn, and each was measured against bar A on seeds 501-540,
both seats (80 matches), against Kenpachi's KI T0 (`t0/t0-ki-kenpachi.lisp`, unchanged). Bar A itself did not move.

| Map | brawl's job | changes a match: median (mean) | zero | arm shares all / brawl / keep / kessa2 | in-job / out-of-job | Bar A |
|---|---|---|---|---|---|---|
| v1 (the one pre-registered above) | G2 `(:ost :free) (:dm :m-close)` | 6 (6.5) | 0 | .292 / .017 / .260 / .431 | .24 / .0001, .39 / 0, 1.0 / 0 | **fails** (median) |
| v2 | v1 + G7 `(:or :r-low)` | 7 (6.7) | 0 | .163 / .068 / .298 / .470 | .21 / .001, .42 / 0, 1.0 / 0 | **fails** (median) |
| **v3 (kept)** | G2 `(:ost :free)` (all three distances) | **19 (19.8)** | **0** | **.205** / .077 / **.271** / **.447** | .25 / 0, .39 / 0, 1.0 / 0 | **passes** |
| v3, replication on seeds 541-580 | (the same table) | **21 (20.9)** | **0** | **.219** / .081 / **.250** / **.449** | .27 / 0, .38 / 0, 1.0 / 0 | **passes** |

The registered map (v1) **fails**. v3 was designed after v1 and v2 on the same 80 matches and kept because it passed, so its 501-540 pass is a
selected result. The replication tests it: the v3 table unchanged, one run on seeds 541-580, a dev block this cell had not used
(`t0/bar-ki-541-580.json`). The map was not edited after it. Files: `t0/bar-ki-501-540-v1.json`, `-v2.json` (v1's table was overwritten by v3,
v2's was a scratch file), `t0/bar-ki-501-540.json` (v3).

v3's bar A (`t0/bar-ki-501-540.json`): no match without a change; median 19 >= 10; three arms >= 10 % (all, keep, kessa2; brawl .077), none
over 70 %; in-job >= 2x out-of-job for each arm. There were 132.4 judgements a match. K.O. rate 1.00, and Ichigo wins .938 by K.O.
Kenpachi's side in the same run: median 24, arm shares .069 / .536 / .022 / .129 / .099 / .145, and it passes bar A too.
- v1 and v2 failed on switching. keep (G8 ahead) and kessa2 (awakened) follow slow cues, and brawl's narrow job rarely won its rules
  (in-job share .21-.24), so few arm changes happened. His free state toggles with every move of his. That is what v3's switching comes
  from.
- brawl is under 10 % in every map: it wins only a quarter of its job's weight. A fit (B5) may widen it.
- kessa2 is not PLAN4's "KESSA chains". While awakened, `:iks-wait-max 0` hands KESSA's neutral to the generic CPU, and the chain keys are
  unused (the probes found no separation by them). Its job is KESSA pressure with the shut-gauge lunge off. Its bar (-0.30 m) was set after
  the 201-220 probes showed -0.49 / -0.43.

### Proofs (no play changes)

- **Host tests**:
  - duel-rules: 3607 checks, ALL PASS. `style-knob.lisp` scans `style-on` too and now finds 75 keys (32 `iks-`).
  - duel-control 124, input 33 and cine 18: ALL PASS.
  - touch: 100 checks, 0 failures.
- **pkgcheck**: only `DUEL::APP`.
- **Build**: `./build.sh duel` exit 0, then `git checkout -- vendor`. The smoke exits 0.
- **G2**: `tools/simgate.py --cvc` PASS (ii 38, ik 27, kk 21 lines) and `tests/style-gates.py cvc dist/duel` PASS. II and IK play Ichigo's
  matchup style, so G2 sees the edited code.
- **identity.py**, HARD lookup = raw final file, seeds 501-510, both seats:
  - KI (`ki-ichigo` vs `ki-kenpachi`): 2 chunks identical, 0 differing, 532 lines.
  - IH (`ih-ichigo` vs `ih-hisagi`): 2 identical, 0 differing, 500 lines.
- **Cross-build**: a baseline worktree at 1170f748 against this branch. Native sim, seeds 501-510 HARD, both seats, combat log on. 24 jobs
  (240 matches):
  - the KI and IH final tables;
  - the five first drafts (which name `:iks-mix-*`, so the mode pick, the hover bands and the patience read all run), against Kenpachi's
    and Hisagi's `none`.

  Every combat-log line, `duel hash`, `duel state`, gate row and per-match stats line was identical: 503 640 lines. The edited code ran:
  483-1233 `ki-style` action lines a job.
- **The desc counters only read**: `nstart`, `asp` and `adsum` are new. `a4-i-all` against Kenpachi's `none`, seeds 501-510, was run with
  and without `STRAT_DESC`: the hash, state and gate-row lines were identical (194 lines).
- **Build hash**: the sim build hash changes with the source text (c61156551c44 at 1170f748, 84bd53aad9af here) though play does not. Main
  re-pins `SP_BUILD` after this cell (PLAN4 §7).

## The targeted arm vs Hisagi: cells-k/i-vsh (PLAN4 B3 search, 2026-11-15)

Two Sonnet cells, one branch (1 x 2, W 4, `v1_rank_keep`). Each cell chose its own job rules and registered a descriptor in `job.json`
before its first eval (`kenpachi.md` "Re-registered for the cells"). It was scored as the fifth arm of her IH T0 (`t0/ih-ichigo.json`: KI's
v3 map on `d-x-ih-i`) against Hisagi's `none` and his IH T0 (`t0/t0-ih-hisagi.lisp`, built from his five drafts), K.O.-only, block 300.
The four-arm IH T0 is the baseline: .8267 on block 300, .8152 on block 200.

| Cell | job (registered) | descriptor (registered) | keys | block 300 |
|---|---|---|---|---|
| b0_a0 | G7 `(:mr :r-low)` (her Reishi low: he presses) | mean_d >= + 0.5 m | `:iks-hover-add 2.0 :iks-bait-hover-add 1.5 :iks-gap-p 0` | .8185 |
| b0_a1 | G10 `(:optr :k2) (:dm :m-far)` (his pointer 2, far) | mean_d <= - 0.3 m | `:iks-patient-p 0 :iks-wait-max 0 :iks-gap-p 1` (a close chase) | .8267 |

- b0_a1 scored .8201 on block 200 (baseline .8152), which is noise. Its job rule rarely fires: the T0 group's record equals the baseline's.
- **Proof** (seeds 1-100, both seats, against his `none`, with the four general arms in one run;
  `cells-k/admit/proof-ichigo-vs-hisagi.json`):
  - mean_d -0.184 m against the -0.30 registered: **fail**.
  - Distinct from all four general arms. K.O. .965.
- Not admitted. The IH T0 stays four arms (`t0/t0-ih-ichigo.lisp`).
- The search found:
  - the hover adds are inert against Hisagi, as note 2 found against Kenpachi;
  - a pointer-2 Getsuga arm at range loses (.754);
  - the close chase helps against his `none` but costs against his T0 once it fires at mid range.

**Bar A, IH** (her IH T0 against Hisagi's IH T0, seeds 501-540, both seats, 80 matches; `t0/bar-ih-501-540-b3.json`):
- changes: median 18 (mean 19.6), no match without a change; 183 judgements a match;
- arm shares .239 / .069 / .128 / .565; in-job vs out .28 / 0, .24 / 0, 1.0 / 0;
- K.O. rate .975 (she wins .875).
- **Passes.** KI (unchanged table, against Kenpachi's new KI T0): median 21, shares .218 / .083 / .267 / .432, K.O. 1.00 (she wins .963):
  passes.
