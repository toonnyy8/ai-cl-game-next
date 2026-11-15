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

## 4. Results: the in-band test (`inband/ib.jsonl`, `inband/admit.json`; `inband.py ib`, `admit`, `report`)

53 tests (every arm of §2 in its row, the three slot alternatives in theirs), each **1,600 matches run** (seeds 141-180 x both seats x
salts 1-20, p .9), **414-1,462 distinct matches used** (two exceptions: KI `climb` 34, KI `keep` 29: their jobs fire on 1-4 % of the
judgements; KK `wake` / `red` / `climb` 123-142). 84,800 matches in all (about 70 min at 12 processes). Bar runs (eps 0) on the candidate T0s: `inband/bar/`.
Distinctness: `inband/desc/` (each arm whole against his `none`, 80 matches an arm).

One deviation, made after the in-band runs and named here: **distinctness is counted against the row's arms that pass in-band** (and
arm 0), not every candidate. As written, IH `brawl` (in-band z 1.10) was excluded for being within tolerance of `inside`, which itself fails
in-band and leaves the table; two arms that never share a table need not differ. It changes one arm (IH `brawl` in) and nothing else.
`admit.json` keeps both lists (`not_distinct_from`, `not_distinct_any`).

"margin z" = the same test on the end-of-match health margin (report only). "fire, in / out" = bar A's division on the candidate T0.
"z clustered" (a sensitivity check added after the runs, from the same cached matches; the verdicts stay the pre-registered z's): the se
clustered by (seed, seat), the 80 independent units under the salts. Four verdicts would flip: KH climb (-2.37 -> -1.73: KH Kenpachi
would keep a third arm), KH bait (2.05 -> 1.49: no targeted arm would pass), IH cancel (-2.94 -> -1.08), HH bind (-3.64 -> -1.74).
"descriptor": the pre-registered descriptor-whole test (report only, as the brief says): arms5's / arms4's proof on seeds 1-100, and
again on 141-180 (`inband/desc/`, against his `none`; getsuga's 1-100 test is against Ichigo's keep, its 141-180 run against her none).

| Row | Arm | G/T | n run / distinct used | slope (se), z | z clustered | MDE | margin z | distinct | fire, in / out | descriptor 1-100 / 141-180 (report only) | verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ki-kenpachi | k5-poke | G | 1600 / 1058 | -0.004 (0.005), **-0.84** | -0.83 | 0.01 | 3.79 | yes | 0.43, 0.64 / 0.007 | pass / pass | ADMIT |
| ki-kenpachi | k5-wake | G | 1600 / 1020 | -0.001 (0.007), **-0.18** | -0.16 | 0.014 | -3.46 | yes | 0.34, 0.69 / 0.000 | FAIL / FAIL | ADMIT |
| ki-kenpachi | k5-red | G | 1600 / 414 | -0.117 (0.027), **-4.29** | -2.97 | 0.054 | -9.15 | yes | 0.30, 0.65 / 0.002 | pass / pass | out: in-band |
| ki-kenpachi | k5-climb | G | 1600 / 34 | -0.072 (0.106), **-0.67** | -1.53 | 0.212 | -0.16 | yes | 0.01, 0.99 / 0.000 | pass / pass | ADMIT |
| ki-kenpachi | k5-getsuga | T | 1600 / 164 | 0.0 (0.0), **0.0** | 0.0 | None | -0.58 | yes | 0.04, 0.77 / 0.000 | FAIL / pass | out: in-band |
| ki-ichigo | a5-i-answer | G | 1600 / 1422 | 0.008 (0.007), **1.26** | 1.08 | 0.014 | -4.78 | yes | 0.48, 0.71 / 0.000 | FAIL / FAIL | ADMIT |
| ki-ichigo | a4-i-brawl | G | 1600 / 1316 | 0.006 (0.007), **0.87** | 0.88 | 0.014 | 0.7 | yes | 0.31, 0.61 / 0.000 | pass / pass | ADMIT |
| ki-ichigo | a5-i-economy | G | 1600 / 805 | 0.027 (0.01), **2.63** | 1.11 | 0.02 | -0.46 | yes | 0.19, 0.94 / 0.000 | FAIL / FAIL | ADMIT |
| ki-ichigo | a5-i-punish | G | 1600 / 930 | 0.009 (0.005), **1.85** | 1.36 | 0.01 | 0.83 | yes | 0.18, 0.54 / 0.007 | pass / FAIL | ADMIT |
| ki-ichigo | a5-i-kessa-lunge | G | 1600 / 587 | 0.001 (0.012), **0.05** | 0.04 | 0.024 | -0.15 | yes | 0.28, 0.47 / 0.001 | FAIL / FAIL | ADMIT |
| ki-ichigo@a4-i-kessa2 | a4-i-kessa2 | G | 1600 / 575 | 0.012 (0.012), **0.96** | 0.91 | 0.024 | 1.41 | yes | 0.25, 0.43 / 0.001 | pass / pass | ADMIT |
| ki-ichigo | a4-i-keep | T | 1600 / 29 | 0.0 (0.0), **0.0** | 0.0 | None | -0.15 | yes | 0.04, 0.26 / 0.001 | pass / pass | out: in-band |
| kh-kenpachi | k5-poke | G | 1600 / 1185 | 0.063 (0.033), **1.92** | 1.42 | 0.066 | 1.84 | yes | 0.79 VAC, 0.31 / 0.019 | pass / pass | out: division |
| kh-kenpachi | k5-wake | G | 1600 / 648 | 0.04 (0.048), **0.84** | 0.71 | 0.096 | -0.0 | yes | 0.20, 0.33 / 0.000 | FAIL / FAIL | ADMIT |
| kh-kenpachi@a4-k-bait | a4-k-bait | T | 1600 / 801 | 0.086 (0.042), **2.05** | 1.49 | 0.084 | 1.0 | yes | 0.20, 0.34 / 0.000 | pass / pass | ADMIT |
| kh-kenpachi | k5-red | G | 1600 / 633 | -0.261 (0.031), **-8.38** | -4.71 | 0.062 | -10.04 | yes | 0.48, 0.68 / 0.000 | pass / pass | out: in-band |
| kh-kenpachi | k5-climb | G | 1600 / 408 | -0.08 (0.034), **-2.37** | -1.73 | 0.068 | -1.82 | yes | 0.30, 0.98 / 0.000 | pass / pass | out: in-band |
| kh-kenpachi | k5-hug | T | 1600 / 1051 | 0.018 (0.032), **0.56** | 0.3 | 0.064 | 1.54 | yes | 0.12, 0.59 / 0.003 | FAIL / FAIL | out: in-band |
| kh-hisagi | h5-cancel | G | 1600 / 1299 | 0.008 (0.011), **0.69** | 0.22 | 0.022 | 2.3 | yes | 0.24, 0.52 / 0.000 | FAIL / FAIL | ADMIT |
| kh-hisagi | h5-tip | G | 1600 / 599 | -0.153 (0.045), **-3.39** | -3.06 | 0.09 | -3.4 | yes | 0.05, 0.75 / 0.000 | FAIL / FAIL | out: in-band |
| kh-hisagi | h5-bind | G | 1600 / 666 | 0.031 (0.022), **1.37** | 0.66 | 0.044 | 0.87 | yes | 0.78 VAC, 0.80 / 0.001 | FAIL / FAIL | out: division |
| kh-hisagi | h5-wake | G | 1600 / 981 | -0.038 (0.032), **-1.18** | -0.56 | 0.064 | -1.91 | yes | 0.10, 0.62 / 0.000 | pass / pass | ADMIT |
| kh-hisagi@h4-wake | h4-wake | G | 1600 / 986 | -0.022 (0.037), **-0.6** | -0.42 | 0.074 | -0.54 | yes | 0.10, 0.69 / 0.000 | pass / pass | ADMIT |
| kh-hisagi | h5-k1 | T | 1600 / 999 | 0.031 (0.029), **1.06** | 0.46 | 0.058 | 0.68 | yes | 0.25, 0.64 / 0.000 | pass / pass | out: in-band |
| ih-ichigo | a5-i-answer | G | 1600 / 1130 | 0.077 (0.029), **2.66** | 2.02 | 0.058 | 0.08 | yes | 0.18, 0.47 / 0.000 | FAIL / FAIL | ADMIT |
| ih-ichigo | a4-i-brawl | G | 1600 / 1368 | 0.03 (0.028), **1.1** | 0.71 | 0.056 | -1.65 | yes | 0.26, 0.47 / 0.000 | pass / pass | ADMIT |
| ih-ichigo | a5-i-economy | G | 1600 / 908 | 0.134 (0.033), **4.01** | 2.22 | 0.066 | 2.87 | yes | 0.12, 0.74 / 0.000 | FAIL / FAIL | ADMIT |
| ih-ichigo | a5-i-punish | G | 1600 / 1180 | 0.074 (0.026), **2.84** | 1.85 | 0.052 | 0.63 | yes | 0.43, 0.23 / 0.001 | FAIL / FAIL | ADMIT |
| ih-ichigo | a5-i-kessa-lunge | G | 1600 / 1292 | 0.043 (0.027), **1.58** | 1.2 | 0.054 | 2.51 | yes | 0.55, 0.77 / 0.004 | FAIL / FAIL | ADMIT |
| ih-ichigo@a4-i-kessa2 | a4-i-kessa2 | G | 1600 / 1299 | -0.005 (0.025), **-0.22** | -0.14 | 0.05 | -1.25 | yes | 0.46, 0.63 / 0.006 | pass / pass | ADMIT |
| ih-ichigo | a5-i-inside | T | 1600 / 1264 | -0.029 (0.03), **-0.96** | -0.7 | 0.06 | -1.5 | no (~a4-i-brawl) | 0.55, 0.27 / 0.018 | pass / pass | out: in-band, not distinct |
| ih-hisagi | h5-cancel | G | 1600 / 1365 | -0.057 (0.019), **-2.94** | -1.08 | 0.038 | 2.91 | yes | 0.35, 0.40 / 0.001 | FAIL / FAIL | out: in-band |
| ih-hisagi | h5-tip | G | 1600 / 1105 | 0.349 (0.034), **10.16** | 6.45 | 0.068 | 13.65 | yes | 0.46, 0.89 / 0.003 | FAIL / FAIL | ADMIT |
| ih-hisagi | h5-bind | G | 1600 / 575 | 0.237 (0.032), **7.32** | 4.08 | 0.064 | 9.57 | yes | 0.31, 0.24 / 0.002 | FAIL / FAIL | ADMIT |
| ih-hisagi | h5-wake | G | 1600 / 1200 | -0.042 (0.026), **-1.6** | -0.82 | 0.052 | 4.25 | yes | 0.33, 0.33 / 0.000 | FAIL / pass | ADMIT |
| ih-hisagi@h4-wake | h4-wake | G | 1600 / 1155 | -0.046 (0.031), **-1.47** | -1.21 | 0.062 | -1.27 | yes | 0.33, 0.34 / 0.000 | pass / pass | ADMIT |
| ih-hisagi | h5-i1 | T | 1600 / 947 | -0.058 (0.035), **-1.64** | -1.0 | 0.07 | -0.3 | yes | 0.42, 0.45 / 0.004 | FAIL / FAIL | out: in-band |
| ih-hisagi | h5-ihx | T | 1600 / 441 | -0.077 (0.05), **-1.55** | -1.2 | 0.1 | -0.08 | yes | 0.25, 0.21 / 0.002 | pass / pass | out: in-band |
| kk-kenpachi | k5-poke | G | 1600 / 702 | -0.05 (0.044), **-1.14** | -0.84 | 0.088 | 0.88 | yes | 0.98 VAC, 0.97 / 0.034 | pass / pass | out: division |
| kk-kenpachi | k5-wake | G | 1600 / 142 | 0.008 (0.108), **0.08** | 0.08 | 0.216 | 0.87 | yes | 0.03, 0.18 / 0.000 | FAIL / FAIL | ADMIT |
| kk-kenpachi | k5-red | G | 1600 / 123 | -0.335 (0.093), **-3.61** | -3.37 | 0.186 | -4.47 | yes | 0.09, 0.18 / 0.000 | pass / pass | out: in-band |
| kk-kenpachi | k5-climb | G | 1600 / 126 | -0.224 (0.119), **-1.89** | -1.38 | 0.238 | -1.87 | yes | 0.02, 0.99 / 0.000 | pass / pass | ADMIT |
| ii-ichigo | a5-i-answer | G | 1600 / 1294 | -0.051 (0.033), **-1.55** | -0.88 | 0.066 | -2.16 | yes | 0.36, 0.82 / 0.001 | FAIL / FAIL | ADMIT |
| ii-ichigo | a4-i-brawl | G | 1600 / 1405 | -0.193 (0.031), **-6.19** | -3.83 | 0.062 | -8.32 | yes | 0.42, 0.58 / 0.000 | pass / pass | out: in-band |
| ii-ichigo | a5-i-economy | G | 1600 / 953 | -0.026 (0.038), **-0.67** | -0.4 | 0.076 | -0.86 | yes | 0.24, 0.83 / 0.000 | FAIL / FAIL | ADMIT |
| ii-ichigo | a5-i-punish | G | 1600 / 934 | -0.041 (0.036), **-1.13** | -0.53 | 0.072 | -0.93 | yes | 0.12, 0.57 / 0.005 | FAIL / FAIL | ADMIT |
| ii-ichigo | a5-i-kessa-lunge | G | 1600 / 608 | 0.011 (0.041), **0.28** | 0.21 | 0.082 | -0.37 | yes | 0.38, 0.38 / 0.001 | FAIL / FAIL | ADMIT |
| ii-ichigo@a4-i-kessa2 | a4-i-kessa2 | G | 1600 / 593 | -0.04 (0.036), **-1.11** | -0.82 | 0.072 | -1.26 | yes | 0.39, 0.29 / 0.001 | pass / pass | ADMIT |
| hh-hisagi | h5-cancel | G | 1600 / 1462 | 0.012 (0.028), **0.44** | 0.17 | 0.056 | -1.03 | yes | 0.44, 0.34 / 0.001 | FAIL / FAIL | ADMIT |
| hh-hisagi | h5-tip | G | 1600 / 984 | -0.218 (0.037), **-5.83** | -4.87 | 0.074 | -6.9 | yes | 0.58, 0.92 / 0.004 | FAIL / FAIL | out: in-band |
| hh-hisagi | h5-bind | G | 1600 / 612 | -0.102 (0.028), **-3.64** | -1.74 | 0.056 | -1.3 | yes | 0.49, 0.26 / 0.001 | FAIL / FAIL | out: in-band |
| hh-hisagi | h5-wake | G | 1600 / 1040 | -0.027 (0.026), **-1.03** | -0.37 | 0.052 | -0.22 | yes | 0.28, 0.26 / 0.000 | FAIL / pass | ADMIT |
| hh-hisagi@h4-wake | h4-wake | G | 1600 / 964 | -0.051 (0.042), **-1.2** | -1.06 | 0.084 | 0.3 | yes | 0.30, 0.29 / 0.000 | pass / pass | ADMIT |

Reading:
- **KI Kenpachi**: Kenpachi loses nearly every match to Ichigo's T0 (points .004-.072), so for poke, wake, climb and getsuga the game's
  result has almost no variance (getsuga and keep: none at all, z 0 by §3's rule; a targeted arm then cannot pass). red is the one arm whose
  runs cost his few points (z -4.29).
- **red Kikon fails in every Kenpachi row** (KI -4.29, KH -8.38, KK -3.61): played in his job (his red, her Reishi low) it gives back
  .12-.34 points against arm 0 there. **climb** fails in KH (-2.37) and passes in KI / KK with little power (MDE .21-.24).
- **Hisagi's tip and bind** are the strongest arms of the batch against Ichigo (IH z +10.16, +7.32: +.35 / +.24 points when they play all
  of their job) and harmful in the mirror (HH -5.83, -3.64) and, for tip, against Kenpachi (KH -3.39). bind is VACUOUS in KH (fires .78:
  Hisagi is behind and awakened most of a KH match).
- **No targeted arm passes but bait** (KH, z 2.05): getsuga / keep (no variance), hug .56, k1 1.06, inside -.96, i1 -1.64, ihx -1.55.
- **Ichigo's brawl** helps against both opponents (z .87 / 1.10) and costs the mirror .19 points (II z -6.19).
- The arms4 alternatives pass where they were tried (kessa2 KI / IH / II, `h4-wake` KH / IH / HH, bait KH), but each slot's arms5 arm passes
  too, so §2's slot rule keeps the arms5 arm everywhere.

## 5. The final T0s (`arms5/t0/t0-<row>.lisp`, maps `.json`, arms `.arms`; bar A and bar D on seeds 141-180, `arms5/t0/bar/`)

Same recipe as the candidates (§2; Hisagi "on"); each table against the opponent's final table, mirrors against themselves; 80 matches a row.

| Row | final arms | changes median (zero) | shares | per job: in / out, fire | bar A | K.O. (bar D) | points |
|---|---|---|---|---|---|---|---|
| ki-kenpachi | k5-all, k5-poke, k5-wake, k5-climb | 55.0 (0) | 0.39 0.25 0.29 0.08 | k5-poke 0.63 / 0.006, 0.40; k5-wake 0.78 / 0.000, 0.37; k5-climb 0.99 / 0.000, 0.08 | pass | 1.000 | 0.113 |
| ki-ichigo | a4-i-all, a5-i-answer, a4-i-brawl, a5-i-economy, a5-i-punish, a5-i-kessa-lunge | 82.0 (0) | 0.09 0.33 0.20 0.18 0.08 0.12 | a5-i-answer 0.73 / 0.001, 0.46; a4-i-brawl 0.61 / 0.000, 0.33; a5-i-economy 0.93 / 0.000, 0.19; a5-i-punish 0.50 / 0.007, 0.19; a5-i-kessa-lunge 0.44 / 0.001, 0.31 | pass | 1.000 | 0.887 |
| kh-kenpachi | k5-all, k5-wake | 44.0 (0) | 0.80 0.20 | k5-wake 1.00 / 0.000, 0.20 | fail (three arms) | 0.287 | 0.975 |
| kh-hisagi | h5-all, h5-cancel, h5-wake | 75.0 (0) | 0.78 0.15 0.08 | h5-cancel 0.76 / 0.000, 0.20; h5-wake 1.00 / 0.000, 0.08 | fail (three arms) | 0.287 | 0.025 |
| ih-ichigo | a4-i-all, a5-i-answer, a4-i-brawl, a5-i-economy, a5-i-punish, a5-i-kessa-lunge | 97.0 (0) | 0.11 0.08 0.15 0.09 0.15 0.43 | a5-i-answer 0.47 / 0.000, 0.17; a4-i-brawl 0.56 / 0.000, 0.27; a5-i-economy 0.76 / 0.000, 0.11; a5-i-punish 0.42 / 0.005, 0.41; a5-i-kessa-lunge 0.77 / 0.004, 0.57 | pass | 0.550 | 0.175 |
| ih-hisagi | h5-all, h5-tip, h5-bind, h5-wake | 57.0 (0) | 0.30 0.43 0.15 0.12 | h5-tip 0.93 / 0.004, 0.47; h5-bind 0.49 / 0.002, 0.34; h5-wake 0.37 / 0.000, 0.34 | pass | 0.550 | 0.825 |
| kk-kenpachi | k5-all, k5-wake, k5-climb | 38.5 (0) | 0.41 0.30 0.28 | k5-wake 0.73 / 0.000, 0.42; k5-climb 0.99 / 0.000, 0.29 | pass | 1.000 | 0.5 |
| ii-ichigo | a4-i-all, a5-i-answer, a5-i-economy, a5-i-punish, a5-i-kessa-lunge | 65.5 (0) | 0.32 0.34 0.17 0.03 0.15 | a5-i-answer 0.92 / 0.001, 0.37; a5-i-economy 0.92 / 0.000, 0.18; a5-i-punish 0.51 / 0.002, 0.08; a5-i-kessa-lunge 0.72 / 0.002, 0.22 | pass | 0.475 | 0.5 |
| hh-hisagi | h5-all, h5-cancel, h5-wake | 89.0 (0) | 0.79 0.11 0.10 | h5-cancel 0.60 / 0.001, 0.19; h5-wake 1.00 / 0.000, 0.10 | fail (three arms) | 0.000 | 0.5 |

- **Bar A passes in six rows** (KI both, IH both, KK, II); **it fails in KH both and HH** on "three arms >= 10 %": arm 0 holds .78-.80 of the
  judgements (KH Kenpachi has one job arm left, wake; KH Hisagi cancel + wake; HH cancel + wake).
- **Bar D: KI 1.000 passes; KH .287 and IH .550 fail** (>= .90). Mirrors: KK 1.000, II .475, HH .000 (80 of 80 at the bell).
  For comparison, B4's shipped tables (501-580): KI 1.000, KH 1.000, IH .963-.975; KK .975-1.000, II .825-.925, HH .000-.025. Neither Hisagi's own arm 0 nor
  the clash explains the KH / IH stalls: §1's T0 setting stalls in every variant (KH K.O. .250 / .188 / .225, IH .487 / .512 / .450 for on /
  off / h4), and `h4-all` played whole against KH Kenpachi's candidate T0 K.O.s .237. What changed from B4 is the opponents' arms5 tables and
  Hisagi's h5 job arms. KH Hisagi trails at the bell (points .025), IH Hisagi leads at it (Ichigo's points .175).
- No match without an arm change in any row; medians 38.5-97.

## 6. Findings for the lead (to take to the user)

**Fail in-band and show no distinct behaviour** (their pre-registered descriptor failed, arms5's 1-100 run and again on 141-180; or not
distinct): the findings proper.

| Strategy (arm) | Row: in-band z | Behaviour |
|---|---|---|
| Kenpachi Getsuga close-in (`k5-getsuga`, T) | KI: 0 (no variance: Kenpachi takes no point in 164 matches) | wave_taken x .645 vs keep (needs x .5), 1-100 |
| Kenpachi dead-zone hug (`k5-hug`, T) | KH: +.56 | mid +.002 (1-100), +.002 (141-180): Hisagi sets the distance |
| Hisagi S3 chain tip (`h5-tip`) | KH: -3.39; HH: -5.83 (IH: +10.16, admitted there) | mean d / TABA-at-tip parts fail both runs |
| Hisagi S4 bind (`h5-bind`) | HH: -3.64 (KH: +1.37 but VACUOUS .78; IH: +7.32, admitted) | bind share / BIND EVEN parts fail both runs |
| Hisagi S2 J-side cancels (`h5-cancel`) | IH: -2.94 (KH +.69, HH +.44: admitted there) | J-side share part fails both runs |
| Hisagi I1 rush and wave (`h5-i1`, T) | IH: -1.64 | charges answered .057 (needs .6); not distinct from cancel on 141-180 |
| Ichigo T3 inside 3 m (`a5-i-inside`, T) | IH: -.96 | not distinct from brawl (both runs) |

**Fail in-band, behaviour distinct** (descriptor passes): out of the tables on the in-band bar alone.

| Strategy (arm) | Row: in-band z |
|---|---|
| Kenpachi red Kikon on pointer 2 (`k5-red`) | KI -4.29, KH -8.38, KK -3.61 (all three rows: in no final table) |
| Kenpachi climb (`k5-climb`) | KH -2.37 (KI -.67, KK -1.89: admitted there) |
| Ichigo S2 brawl (`a4-i-brawl`) | II -6.19 (KI .87, IH 1.10: admitted there) |
| Ichigo T2 keep (`a4-i-keep`, T) | KI 0 (no variance: Ichigo wins all 29 distinct matches with a keep run; its job fires 4 %) |
| Hisagi K1 (`h5-k1`, T) | KH +1.06 (needs +2) |
| Hisagi ihx (`h5-ihx`, T) | IH -1.55 |

**Pass in-band, left out by bar A's vacuity**: Kenpachi out-range poke in KH (z 1.92, fires .79) and KK (fires .98); Hisagi bind in KH (fires
.78). poke stays in KI (fires .43).

**Admitted but displaced by the slot rule** (§2: the arms5 arm wins when both pass): bait in KH (the only targeted arm that passed, z
2.05; k5-wake z .84), kessa2 (KI / IH / II), `h4-wake` (KH / IH / HH).

**Admitted although their descriptor failed** (report only by the brief; named so nothing is kept quietly): Ichigo answer (sa_x), economy
(sp), kessa-lunge (k_sp, k_p3), punish (vs Hisagi on 1-100; vs both on 141-180); Kenpachi wake (wake_kd); Hisagi cancel (KH, HH), h5-wake vs Ichigo (x1.27
on 1-100; passes on 141-180).

**Below PLAN4 §3's floor** ("never fewer than 3 general arms: then stop and report"): KH Kenpachi has one general arm (wake), KH Hisagi two
(cancel, wake), HH two (cancel, wake). **Fit to integrate (bar A and bar D both pass): KI Kenpachi, KI Ichigo, KK, II** (II's K.O. .475 is a
mirror, reported). IH Ichigo / IH Hisagi pass bar A but fail bar D (.550). KH both sides and HH: stop and report.

**The table ids** (`:t0-ki-kenpachi` ...) are B4's shipped library ids: `t0final/add.sh` would replace them; the lead decides the names.

**Rows that fail bar A or D with the admitted arms**: KH (both sides: two / three arms, arm 0 at .80 / .78; K.O. .287), IH (K.O. .550), HH
(three arms; K.O. .000). Options for the user are not decided here: e.g. KH Hisagi's or Kenpachi's arm 0, the clash setting of Hisagi's
arm 0 (§1: "off" stalled more), bait in KH Kenpachi's wake slot (still two arms), or the mirror tables of B4.
