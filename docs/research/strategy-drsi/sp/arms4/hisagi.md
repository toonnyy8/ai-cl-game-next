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
