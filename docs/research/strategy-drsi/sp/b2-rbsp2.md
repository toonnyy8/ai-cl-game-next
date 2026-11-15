# B2: `:rb-sp2`, `:with`, the seat layer, `STRAT_ANCHOR` (PLAN4 §2, §3, §4 T0, §6; 2026-11-15)

Batch B2 of PLAN4. Everything here is off by default: no shipped table names `:rb-sp2` or `:with`, `*strat-layer*` stays NIL, and
`STRAT_ANCHOR` is a tool switch. G2 and the shipped lookup are bit for bit unchanged (Proofs, below).

## The rule base `:rb-sp2` (duel/lisp/strategy.lisp `*strat-rule-bases*`)

104 rules in 11 additive groups `(36 9 12 9 4 2 4 4 9 6 9)`, `:xfeats t`, no `:prev`, no `:gauge`:

| Group | Rules | Antecedents (cue: sets) |
|---|---|---|
| G0 | 36 | `:lead` behind / even / ahead x `:ored` no / yes x `:awst` no / yes / k2 x `:oawk` no / yes |
| G1 | 9 | `:form` no / yes / k2 x `:dm` m-close / m-mid / m-far |
| G2 | 12 | `:ost` free / atk / evade / down x `:dm` |
| G3 | 9 | `:mcell` x `:ocell` (no / yes / p2up) |
| G4 | 4 | `:mburst` x `:oburst` |
| G5 | 2 | `:xch` |
| G6 | 4 | `:wall` x `:owall` (w-near / w-open) |
| G7 | 4 | `:mr` x `:or` (r-low / r-high) |
| G8 | 9 | `:time` t-early / t-mid / t-late x `:lead` |
| G9 | 6 | `:swopen` no / yes x `:mptr` yes / k2 / k3 (pointer 1 / 2 / 3) |
| G10 | 9 | `:optr` yes / k2 / k3 x `:dm` |

The HUD check: **both SP pointers are shown, so G10 stays and the base has 104 rules.**
- `webhud.lisp` `webhud-side` writes each side's pointer at slot o+9. During a DRIVE switch it writes the switch's target instead.
- `lhud-plate.lisp` `lhud-plate` draws the seal row on both plates (`lhud-seal-row`).
- On the phone with the deck, P1's plate becomes a line with no seals (`lhud-plate-line`). P1's seals then sit around 爆 instead (`lhud-deck.lisp`).
- P2's plate, which is the CPU's, always shows its seals.

### Cues and their encodings

The new cues are built by `strat-sp2-cues` in strategy.lisp, which is pure and host-tested. `strat-xfeats` in strategy-glue.lisp calls it and adds the cues after the existing ones; it now takes the SNAP too (`(e f s d)`). They are read only at a judgement. They add no sim state and no snapshot root.

| Cue | Source | Encoding |
|---|---|---|
| `:awst` | `awaken-ready-p`, `gauges-awakened` | 0 not ready, 1 ready, 2 awakened (awakened wins) |
| `:owall` | the SNAP's x / z (`snap-x` / `snap-z`) | his metres to the arena's wall, where the CPU perceives him (BRAIN-DELAY steps late, like `:dm`); his position is not a HUD value |
| `:time` | `(match-frames-left)` over `60 x *match-seconds*` | the HUD timer's elapsed share, clamped 0-1 |
| `:mptr` / `:optr` | `strat-hud-ptr` (the HUD's value: a DRIVE switch's target while it runs, else `fighter-ptr`, `core-clamp-pointer`) | 1-3; a fourth pointer (KESSA's) reads 3 |
| `:swopen` | `aw-full-p` (the latch, awakened, or full) | 0 / 1 |

`:ost` is already in `strat-feats`. Its classes are 0 free (idle / run / guard), 1 startup, 2 the move past its startup (active **or recovery**), 3 step / Hoho, and 4 any other state. G2 maps them as follows:
- free = `:free` (0).
- attacking = the new `:atk` (0.5 1 2 2.5): startup, active or recovery. A whiff's recovery counts as attacking, which suits the whiff-punish job.
- evading = `:evade` (3).
- down = `:down` (4). This is honestly "any other state": hitstun, blockstun (guard-hit), stun, launched, down, waking up, and a cinematic.

### Fuzzy sets (duel/lisp/fuzzy.lisp; none changed)

New sets: `:atk` (0.5 1 2 2.5), `:t-early` (-99 -99 0.3 0.4), `:t-mid` (0.3 0.4 0.6 0.7), `:t-late` (0.6 0.7 99 99), and also
`:r-low` (-99 -99 0.45 0.55) and `:r-high` (0.45 0.55 99 99).

**Deviation:** PLAN4 said G7 reuses `:low` / `:high`. Those two sets do not cover the range: between 0.25 and 0.75 they sum to less than 1, and at Reishi 0.5 both read 0, so G7 would fall silent around half Reishi. The new pair splits at a half, where Hisagi's IH key sits.

### Host checks (tests/duel-rules/strategy.lisp)

- **Encodings**: `strat-sp2-cues` on three cases (not ready / ready / awakened, the clock clamp, pointer 4 read as 3).
- **Counts**: 104 antecedents = the groups' sum; no `:prev` or `:gauge` cue.
- **Coverage**: per group, a grid over that group's cues. Crisp cues take their points; continuous cues (`:dm :wall :owall :mr :or :time`) take points across their ramps. Wherever at most one cue sits on a ramp, the group's firing sums to 1; with two or more on a ramp, it is still >= 1, so there is no dead band.
  - AND is the minimum, so two cues half way fire four rules at 0.5 each and the group sums to 2. `strat-fq-q` and `strat-fq-fire` normalise each group, so play is unaffected.
  - The old `:low` / `:high` would fail this check.
- **Switching**: a 2-arm table (none, `:a-generic`) gives arm 1 a q of 1.0 in the rules that name one cue's set. Its pick moves when that cue alone moves, for each of `:awst` (yes, k2), `:owall`, `:time` (mid, late), `:mptr` k3, `:optr` k2, `:swopen`, `:mr` / `:or` r-low, and `:ost` atk (1 and 2), evade and down.
- **Page size**: a 2-arm `:rb-sp2` page is 3 + 2 x 104 integers.
- **Refusal**: a table without `:xfeats` is refused.

## `:with (unit ...)` (strategy.lisp `strat-with`, applied in `strat-expand`)

A Q table's `:with` lays data units under every arm of the table. The units are `*strat-data*` ids or inline plists. The rules:
- **The arm's own keys win.** A key the arm names anywhere is left out of every unit: a top-level key, a `:base` key, or a rule's output.
- Among the units, an earlier one wins over a later one.
- `:base` is the arm's, then the units'.
- `:rules` are the arm's, then the units'. A unit rule keeps only the outputs no earlier source names; a rule left with none is dropped.
- A NIL arm stays NIL. The none arm is no strategy, and a unit's keys would turn it into the generic CPU.
- `:with` itself is dropped from the expanded table.
- With no `:with` (or an empty one), `strat-with` returns the arm itself (EQ), so expansion is unchanged.
- Under `:with` every arm is a fresh copy, so `strat-expand`'s duplicate-arm assert (`eq`) no longer catches a table that names one arm id twice.
- `fq-checksum` hashes the arm ids and the q values, not the `:with` units. A player's saved online copy would still load after a unit edit that changes how the arms play. B4 and B6 should change an arm's or a unit's id, or the q, when they edit a unit.
- Event arms (`:event-arms`) are not touched.

Raw files: `strat-run.lisp`, `strat-desc.lisp` and the snaptest / fulltest prelude read a strategy file through `cl-user::sg-read-strat` (tools/simgate/prelude.lisp). No other runner reads `STRAT_P<n>`.
- It expands a file whose `:fq` names `:with`; every other raw file is played exactly as read.
- `sp/eval.py`'s raw-file guard ignores ids inside a `:with (...)` form. It still refuses unit ids anywhere else.

Host checks:
- `:with (:d-brawler)` over `(nil :a-ken-ki :a-zoner)`: NIL stays NIL.
- `:a-ken-ki` becomes its own keys plus the unit's `:base` and `:rules`.
- The zoner keeps its own `:range` 1.5 (the unit's is 0.7) and gains the unit's `:b-step-in` 0.03. No unit rule names a key the zoner's base names.
- An inline unit adds only its new key.
- No `:with` gives an EQUAL expansion, with the arms EQ to `strat-arm`'s.

## The seat layer (strategy-glue.lisp `strat-layer-p`)

`*strat-layer*` may be T, a list of characters (as before), or a seat 0 / 1. `integerp` is tested first, because `member` on an integer is an error. `strat-run.lisp` reads `STRAT_LAYER=P1` / `P2`.

Proof: a KK mirror with `STRAT_LAYER=P1` (seed 501) made 127 selections; the picks are all on P1 (16 / 76 / 35) and P2's are all 0.

## `STRAT_ANCHOR=<file>` (tools/simgate/strat-run.lisp)

The file holds one plist, `(:library (entry ...) :payoff (row ...))`. For the run it sets `*strat-library*` (each entry `strat-expand`ed, with the entry's own `:with` laid under it), `*strat-payoff*`, and `*strat-picks*` (re-sized to the library). It prints `anchor <file> entries <ids>`. The game's source library is not touched.

**Caveat (documented in the file's header):** `strat-lookup` then sees only the anchor's entries. A seat that should play a table must get it by `STRAT_P<n>` (a file), not by its difficulty's lookup. B1's `STRAT_DIF_P<n>` sits in another part of the file. My changes are `sr-read`, the `STRAT_LAYER` parse and a new `STRAT_ANCHOR` block, all placed before `sg-init`.

Example: `sp/duct/anchor-ki-example.lisp`. It holds two Kenpachi arms and two Ichigo arms inline (today's units; the second Ichigo arm carries `:with (:d-red-kikon)`) and a **flat placeholder matrix (0.5, uniform mixes), not measured**.

Smoke: KI, seeds 1-3, `STRAT_LAYER=P2`, P1 Ichigo playing the T0 file below:
- The anchor loaded its 4 entries.
- Only P2 was layered: P2's picks spread over the two anchor arms (48 / 21, 80 / 27, 72 / 9) and P1's were all 0.
- The selections cost 10.9-14.3 ms each.
- All 3 matches ended by K.O.; exit 0.

## Tools for the new base

- **`fq/switch/sw.py --rb :rb-sp2`**:
  - `rule_base()` reads 104 rules in groups `[36, 9, 12, 9, 4, 2, 4, 4, 9, 6, 9]` from the Lisp source. `:rb-switch89` (89) and `:rb-sp` (42) still parse.
  - `GROUP_DOC` and the docstring describe the new base.
  - The new common option `--with UNIT...` (ids, or files with one inline plist) makes every written table carry `:with`.
  - `pin` refuses a `:with` table unless `--with` is passed again, because the rewrite would drop the units.
  - The log parser reads the firing vector by index, so all 104 rules flow through the fit unchanged.
  - Proved end to end: `sw.py log --rb :rb-sp2 --ko` with the KI T0 (seeds 201-204, both seats, salt 1, eps 0.03) logged 8 matches and 1,057 judgements, using all five arms (224 / 67 / 88 / 293 / 385), with firing indices up to 103. Then `sw.py fit --rb :rb-sp2 --ko --with :d-red-kikon` (a loose `--boot 5 --conf 0.6`, a smoke only) reported kept deltas per group in 11 entries, `[37, 26, 42, 23, 11, 8, 11, 17, 25, 22, 24]`, and wrote a 104-rule table with `:groups (36 9 12 9 4 2 4 4 9 6 9) ... :with (:d-red-kikon)`.
- **`sp/band.py t0`**: PLAN4 §4's designed table, written from a job map (JSON):
  - `{"arms": [files, arm 0 first], "jobs": [null, [[G, [antecedent substrings]], ...], ...]}`.
  - Arm 0 is 0 everywhere. Arm k is +q (0.06) in its job rules and -q in the rest of the groups its job names.
  - The table carries `:keep-state t :margin 0.02 :period 30 :gamma 0.966 :scale 0.1`, plus `:with` from `--with`. It also writes the `.arms` file.
  - **Note for the lead:** with PLAN4's literal recipe, a job spread over n groups is an AND. One group firing nets +q - q = 0, a tie that arm 0 keeps, so the arm plays only where all n of its groups fire. In the KI smoke, `space` (G1 far **and** G6 wall near) held 0-13 judgements a match.
  - `--or` puts -q / n in the rest instead, so any one job group gives q / n (0.03 at n = 2, above the margin). The lead should pick one of the two before B4.
- **The KI T0 proof** (`sp/b2/t0-ki/`):
  - Ichigo's five arms are placeholders made of existing units, one style function each (`ichigo-ki-r2b2a1-style`): `all` = x-ki-i-r1-b0a2, `whiff` = c-ki-i-r2-b2a2, `space` = c-ih-i-r1-b1a1, `ptr3` = c-ki-i-r3-b3a0-k, `kessa` = x-ki-i-r1-b1a1.
  - The jobs are PLAN4 §3's, giving 2 / 5 / 5 / 15 job rules.
  - The table is written `:with (:d-red-kikon)`, a placeholder: the per-pairing exchange units are B3's.
  - Expanded, every arm carries the unit's red-Kikon rule.
  - Played raw against Kenpachi's HARD table (seeds 1-4, Ichigo P1), all four matches ended by K.O. The table switched among all five arms, for example `held 12 4 0 50 67` and `10 4 4 52 95` judgements by arm.
  - `t0or-ki-ichigo.lisp` is the same table written with `--or`.

## Bench (fq/switch/bench.lisp)

Host ECL, 20,000 calls of `strat-fq-pick`, with every group firing (two cues on a ramp). The bench had gone stale since R13 and needed the engine's fuzzy plus rules / core / sp loaded; it now also times today's HARD table.

| Table | µs a judgement (two runs) |
|---|---|
| old `:qh-ichigo` 48 x 2 | 106 / 124 |
| today's `:f-ki-ichigo` `:rb-sp` 42 x 4 | 53 / 65 |
| **`:rb-sp2` 104 x 7** (random q) | **179 / 178** |

The new table costs about 3x today's: roughly 0.18 ms every 30 steps per CPU, on this host. PLAN4 guessed about 60 µs.
- The cue plist is now long, and each antecedent's `getf` walks it.
- If the browser's cost matters, a cue vector would cut it. Not done.
- The 7-arm page is 3 + 104 x 7 = 731 integers, under `fq-table`'s cap of 999.

## Proofs

- These were rerun after `:owall` moved to the SNAP (the final commit): host tests, pkgcheck, the build and smoke, both G2 checks, snaptest, fulltest, and the T0 smoke (the same 4 rows). `identity.py` ran on the first version: shipped tables read no `:rb-sp2` cue.
- Host tests: `duel-rules-test` 3542 checks, ALL PASS; duel-control 124, input 33, touch 100 (0 failures), cine 18, all pass.
- `tools/pkgcheck.sh duel`: only the old DUEL::APP.
- `./build.sh duel` and the smoke (`run.mjs --secs 8`): exit 0.
- G2: `tests/style-gates.py cvc dist/duel` and `tools/simgate.py --cvc` PASS. II 39 lines, IK 32, KK 29; identical to `tests/style-cvc-ref.txt`.
- The shipped lookup still plays bit for bit. `identity.py` was run on seeds 501-510 (dev; `proofs.sh` uses 601-610, which this batch may not use) with both seats:
  - KI Ichigo against `ki-kenpachi`: 2 chunks identical, 0 differing, 532 lines.
  - KH Hisagi against `kh-kenpachi`: 2 / 0, 666 lines.
- snaptest, KI seeds 501-502, P1 = the T0 file (`:rb-sp2` cues and `:with` inside rollouts): straight = pollute, 75 lines identical (632 rollouts). Only the timing lines differ: the `stats:` line's cons/frame (the rollouts allocate) and the startup `brush:` milliseconds. No sim line differs.
- fulltest, KI seed 501, P1 = the T0 file: 0 checks, 0 differ (a table-playing CPU runs no action-layer jobs). With `FT_LAYER=t`: 571 checks, 0 differ.
- Seeds used: 1-4 and 501-510 only.
