# arms5 / the in-band admission test (PLAN4 §3 step 4; "After the implementation batches"; 2026-11-15)

The lead's brief (2026-11-15): Hisagi's arm 0 with the clash restored first; a candidate T0 per row from every built arm of the user's sets
(「全部採用」; Hisagi's Shikai arm 0 his own, 「改成修兵自己的打法」); the in-band test of each arm inside its row's candidate T0 against the
opponent's candidate T0, on seeds 141-180 x salts, both seats, scored by the game's result (a draw half); a general arm passes at z > -2, a
targeted arm at z >= +2; also distinctness and bar A's in-job >= 2x out-of-job with vacuity; the final T0 per row from the arms that pass, bar A
and bar D on 141-180; a findings list for the lead to take to the user. Tables only (`arms5/t0/`); the game's lookup is not touched.

Sim build: the pin **`SP_BUILD=f0e2bb129de1`** (main's `build/simgate/duel.fas` copied in; fas + `strat-run.lisp`), checked by every
`inband.py` sim command. Seeds: **141-180** only (both seats), x salts 1-20 for the in-band runs.

Files: `arms5/inband.py` (the driver), `tools/simgate/inband-run.lisp` (the runner), `arms5/hisagi/arms-clash.lisp` (Hisagi's arms with the
clash restored), `arms5/inband/` (candidate tables and maps `t0/`, whole-arm tables `one/`, bar files `bar/`, distinctness `desc/`, the
in-band records `ib.jsonl`, Hisagi's arm 0 `h0-results.json`), the final tables `arms5/t0/`.

## 1. Hisagi's arm 0 with the clash restored

Every h5 arm set `:clash-p 0`, which beat the pairing's `:with` unit (`:clash-p 1.7` in KH and IH). `arms5/hisagi/arms-clash.lisp` is
`arms.lisp` with that key dropped from every plist and nothing else changed (checked form by form). The variants of the T0 setting give the
job arms arm 0's clash setting (an arm = arm 0's keys + its job's): **on** (every arm clash on), **off** (every arm `:clash-p 0`, as arms5
built them), **h4** (arm 0 the old `h4-all`, the job arms on; a reference only: the user ruled that arm 0 is his own play).

Seeds 141-180 both seats, 80 matches a cell; points = the game's result (a draw half); K.O. = ended before the bell; `inband/h0-results.json`.

| Arm 0, whole (a 1-arm table, the pairing's unit) | vs K `none`: points, K.O., K.O. wins | vs K T0 (kh-kenpachi) | vs I `none` | vs I T0 (ih-ichigo) |
|---|---|---|---|---|
| `h4-all` (old arm 0) | 1.000, .963, 77 | .269, .237, 16 | .613, .512, 27 | .000, .950, 0 |
| `h5-all` clash on | 1.000, .925, 74 | .250, .275, 17 | .825, .562, 39 | .212, .600, 2 |
| `h5-all` `:clash-p 0` (arms5's) | 1.000, .700, 56 | .250, .113, 8 | .988, .338, 27 | .062, .662, 0 |

| Hisagi's candidate T0, by variant (the T0 setting) | vs KH Kenpachi T0: points, K.O., K.O. wins | vs IH Ichigo T0 | HH mirror: K.O. rate |
|---|---|---|---|
| **on** | **.250**, .250, 12 | **.738**, .487, 33 | .025 (78 of 80 at the bell) |
| off | .150, .188, 7 | .544, .512, 22 | .000 |
| h4 (reference) | .188, .225, 10 | .600, .450, 18 | .000 |

- **The clash on raises arm 0's K.O. rate**: vs Kenpachi's `none` .700 -> .925 (K.O. wins 56 -> 74), vs Ichigo's `none` .338 -> .562 (27 -> 39;
  arms5's 1-100 run had .185). Against Ichigo's `none` it now K.O.s more than the old `h4-all` (.512) and wins more (.825 vs .613 points).
- **Pick (by the game's result in the T0 setting): on**, in both cross rows (KH .250 vs .150 / .188; IH .738 vs .544 / .600). Every Hisagi
  table below is the "on" variant (`inband/h0.json`).
- KH: every Hisagi variant loses to KH Kenpachi's candidate T0 (points .15-.25, 60-65 of 80 at the bell, Kenpachi ahead). The HH mirror
  stalls in every variant (K.O. .000-.025).

## 2. The candidate T0s (`inband.py tables`; `arms5/inband/t0/t0-<row>.lisp` + `.json` maps)

`band.py t0 --or` through `proof.py t0`: arm 0 = 0 in every rule, arm k = +q in its job rules and -q / n in the rest of its n groups;
`:rb-sp2 :xfeats t :keep-state t :margin 0.02 :period 30 :gamma 0.966 :scale 0.1`; `:with` the pairing's exchange unit (`arms4/x-units/`),
mirrors none.

| Row | Arms (arm 0 first; job = `:rb-sp2` rules) | q |
|---|---|---|
| KI Kenpachi | `k5-all`; poke (G1 sealed x close, G10 his ptr 1 x close); wake (G2 down x close / mid); red (G0 his red, G7 his Reishi low); climb (G0 even / ahead x awakened x **not his red**); getsuga* (G10 his ptr 2 x mid / far) | .075 |
| KH Kenpachi | as KI but hug* (G10 his ptr 1 x mid, G2 free x mid) for getsuga; slot alternative: bait* (`a4-k-bait`, G2 down) for wake | .075 |
| KK | `k5-all`, poke, wake, red, climb | .075 |
| KI Ichigo | `a4-i-all`; answer (G2 attacking x close, G5 exchange open); brawl (G2 free); economy (G3 my cells 0 x his >= 1); punish (G2 attacking x mid, evading x close / mid); kessa-lunge (G1 awakened x mid / far); keep* (G8 late x ahead); slot alternative: kessa2 (`a4-i-kessa2`, the same rules) for kessa-lunge | .06 |
| IH Ichigo | as KI but inside* (G1 sealed x mid, G10 his ptr 1 x mid) for keep | .06 |
| II | `a4-i-all`, answer, brawl, economy, punish, kessa-lunge (alternative kessa2) | .06 |
| KH Hisagi | `h5-all`; cancel (G2 attacking x close / mid, G5); tip (G1 form 1 x mid / far); bind (G0 behind x awakened, G7 my Reishi low x his high, G1 form 2 x close); wake (G2 down); k1* (G10 his ptr 1 x mid / far); slot alternative: `h4-wake` (G2 down) for wake | .075 |
| IH Hisagi | as KH but i1* (G10 her ptr 2 x mid / far, ptr 3 x mid) and ihx* (G7 my Reishi high x hers low) for k1 | .075 |
| HH | `h5-all`, cancel, tip, bind, wake (alternative `h4-wake`) | .075 |

\* targeted (z >= +2). Jobs as the arms5 records wrote them (`arms5/{kenpachi,ichigo}.md`, `arms5/hisagi/jobs.json`, `arms5/ichigo/jobs.py`).
Deviations, named before any in-band run:
- **Hisagi q .075** (B4: .06): bind's job spans 3 groups, and `--or` needs q / 3 above the margin .02.
- **climb without his red**: red's G0 job (his red: 18 rules, not the 12 that kenpachi.md says) and climb's (even / ahead x awakened: 8 rules)
  share 4 rules; a tie would fall to the arm index. Those 4 go to red (`inband.py check_jobs` refuses any rule in two jobs).
- **bait only in KH, as a targeted arm** (it was arms4's targeted arm vs Hisagi); kessa2 and `h4-wake` are general.
- **An arms4 alternative sits in its arms5 arm's slot** (same job), in a T0 variant `<row>@<id>`; it is tested there. Rule (written now): the
  arms5 arm goes into the final table if it is admitted; else the alternative if it is admitted; if both are, the arms5 arm (the user's newer
  pick).
- A mirror alternative's bar runs against the base mirror table (the alternative on one seat).

## 3. The in-band test (pre-registered here, before any in-band run)

- **Runner**: `tools/simgate/inband-run.lisp` = `strat-run.lisp` evaluated form by form (that file is unchanged, so the pin holds), with a
  judge hook in front of strat-run's: `STRAT_INBAND="<seat> <k> <salt> <p>"`. On ME's seat, every **run** of judgements whose table pick is arm
  k (a maximal stretch of consecutive pick-k judgements) is played by arm k or by arm 0, a coin per run from `sr-fq-u` (seed, tick, side, salt),
  never SIM-RND01. Everything else (the opponent, ME's other arms, every other judgement) plays the candidate tables as written.
  `inband.py selftest`: without STRAT_INBAND, and with k = 0, the runner's output equals strat-run.lisp's line for line (10 matches, 2877
  lines; only timing / memory lines differ).
- **Coin**: chance p = .9 or .1 that a run is arm k's, one of the two per match by a second hash (tick -1, salt + 7919). A 50/50 coin per run
  leaves a match's share s of arm k near .5 when the job fires 10-25 runs a match (bar runs below), so the slope's se would be ~3x larger.
- **Salts 1-20**, seeds 141-180, both seats: 1,600 matches run per arm.
- **Per match**: y = ME's game result (1 / .5 / 0), s = arm k's share of the pick-k judgements. A match with no pick-k judgement carries
  nothing and is left out. **Identical matches count once**: the sim is deterministic, so salts that drew the same coins replay the same match
  (keyed by seed, seat and the played sequence).
- **Effect**: the OLS slope of y on s with a fixed effect per (seed, seat) = "arm k plays all of its job" minus "arm 0 plays all of it", in
  match points; se classical (dof = n - groups - 1); z = slope / se. If y has no variance inside any (seed, seat) group (e.g. every match
  lost), slope 0, z 0: the game's result cannot see the arm. Reported beside it: n run / distinct / used, the minimal detectable effect
  (2 se), the raw means of y for s >= .5 and < .5, and the slope of the end-of-match health margin (report only).
- **Pass**: general z > -2; targeted z >= +2.
- **Admission into the final table** = in-band pass **and** distinct (proof.py's TOL fingerprint: no sibling of the row within tolerance on
  every descriptor, each arm whole against the opponent's `none`, seeds 141-180, `inband/desc/`) **and** bar A's division on the row's
  candidate T0 (in-job share >= 2x out-of-job, the job firing on <= 60 % of the judgements: else VACUOUS), seeds 141-180. The descriptor-whole
  tests (arms5's, 1-100; and again on 141-180 in `inband/desc/`) are report only.
- **Final T0** per row = arm 0 + the admitted arms (with the slot rule of §2), written by the same recipe; then bar A (no match without a
  change; median >= 10; >= 3 arms at >= 10 %, none > 70 %; in / out with vacuity) and bar D (HARD vs HARD K.O. >= .90 cross rows; mirrors
  reported) on seeds 141-180. A row left with no admitted job arm keeps arm 0 alone and is reported as failing bar A.
- **Findings list**: every arm left out of a final table with its z, distinctness and vacuity; the ones that fail in-band and are not
  distinct (or fail their descriptor) are the findings proper.
