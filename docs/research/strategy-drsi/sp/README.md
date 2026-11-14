# The SP strategy search: scorer, populations, matrices (PLAN.md §7 step 5, 2026-11-14)

DUEL_AI_STRATEGY §11 re-collects the strategies for the SP system. This directory holds the plan (`PLAN.md`), step 2's baseline (`baseline/`) and step 5's machinery: the scorer every dream-rsi cell runs, the seed populations and their payoff matrices. This README covers the first pairing, Kenpachi vs Ichigo (KI).

## Layout

| Path | What |
|---|---|
| `eval.py` | The scorer: a candidate against the opponent's frozen population, K.O.s only. |
| `band.py` | Band-specialist tables (`write`), PLAN2 §3's fallback table (`fallback`), paired runs off the held-out set (`pair`): `band/README.md`. |
| `ship.py` | PLAN2 §3's ship test, the only tool that plays 601-800: `ship/README.md`. |
| `final/` | Each side's final table per pairing (`ship/README.md`). |
| `pop.py` | `screen` seeds a side's population from old arms; `matrix` builds the payoff matrix and both sides' mixes; `selftest` checks the solver and the mix pool. |
| `arms/*.lisp` | The arms written expanded, as raw files. `arms/dump.lisp` writes them from `*strat-units-expanded*` / `*strat-library*` and checks the round trip. |
| `pop/<pair>-<X>.json` | X's population in the pairing (e.g. `ki-K.json` = Kenpachi's against Ichigo), with its screen numbers and its mix. |
| `pop/<pair>-matrix.json` | The pairing's payoff matrix: every cell's counts, both mixes, the values and the convergence gaps. |

A pairing's letters are in roster order K I H: `ki`, `kh`, `ih` (a mirror later `kk`, `ii`, `hh`).

**Raw files are not expanded.** `strat-run.lisp` READs a `STRAT_P<n>` file straight into `BRAIN-STRAT`. Nothing at run time reads `:style`, `:data`, `:rule-base` or an arm id. A file written as `(:id :x :style :st-ken-ki :data (:d-kite))` would silently play the generic CPU. So:
- every arm here is written inline (`:fn`, `:base`, `:rules`);
- `eval.py` refuses a candidate that names `:style`, `:data`, `:rule-base` or a unit id (`:a-…`, `:st-…`, `:d-…`, `:rb-…`).

To write a new arm from the library: `$ECL_HOST --norc --load docs/research/strategy-drsi/sp/arms/dump.lisp -- build/simgate/duel.fas ID...`

## eval.py

```sh
python3 docs/research/strategy-drsi/sp/eval.py --me C --vs D --cand FILE --seed0 N [--seeds 100] [--pop POPFILE] [-j 6]
# as a dream-rsi --eval-command:
python3 docs/research/strategy-drsi/sp/eval.py --me kenpachi --vs ichigo --cand {node_dir}/cand.lisp --seed0 300
```

**The candidate.** FILE is a raw strategy plist: a plain arm, a composite or a Q selector, as `strategy-switch.py --raw` takes it. `--cand none` scores the anchor itself, for reference.

**What it plays.** C plays FILE against D's population, HARD, both seats. The population file defaults to `pop/<pair>-<D>.json`, so `--me kenpachi --vs ichigo` reads `ki-I.json`.

**The opponent groups** (PLAN §2 step 3, weight 1/3 each):

| Group | Opponent | Fallback |
|---|---|---|
| `anchor` | `none`: D's shipped CPU with no strategy (`BRAIN-STRAT` NIL, his matchup style CPU kept) | |
| `mix` | the population's equilibrium mix (the file's `mix`): a pool whose members are repeated by weight over 20 slots (largest remainder) | no `mix` in the file: uniform over every member |
| `rest` | uniform over every member but the anchor | a population of the anchor alone: the anchor |

A pool plays member (seed mod n) of its list, so all three groups play the same seeds.

**The score.** Each group scores (K.O. wins + 1) / (matches + 2). The score is the mean of the three: positive, higher is better. A time-out and a draw score 0, whoever leads at the bell.

**Output.** One JSON line:
- `score`;
- per group: `ko_wins`, `ko_losses`, `timeouts`, `draws`, `matches`, `share`, and the members with their slot counts;
- `pop`, `build` (the sim build hash), `wall_s`.

**Failure.** A bad candidate exits non-zero with a message:
- not exactly one balanced plist;
- unexpanded unit ids;
- a sim error, e.g. an undefined `:fn`: the native sim exits 3 and the run fails within a second.

stdin is set to /dev/null, so an ECL error never waits in its debugger.

**Seeds** (PLAN §3):

| `--seed0` | Seeds | Use |
|---|---|---|
| 200 | 201-300 | the coordinator's rescore (and `pop.py matrix`) |
| 300 | 301-400 | the cells' dev runs (and `pop.py screen`, 301-340) |
| 400 | 401-500 | held-out for admission |
| — | 601-800 | the final gates' held-out set (PLAN §6): `eval.py` and `band.py pair` refuse any range that touches it; only `ship.py` plays it |

The default of 100 seeds a seat gives 3 groups x 2 seats x 100 = **600 matches**, exactly one block. More than 100 needs `--spill`.

**Noise.** Each group share rests on 200 matches (SE about 0.03), so the score's SE is about 0.02. Treat a difference under about 0.04 as a tie (`none` 0.345 vs `a-ken-zoner` 0.347 below is one).

**Cost.** One evaluation takes about 70-130 CPU-s (0.12-0.2 CPU-s a match): 10-18 s wall at `-j 6` on this machine. That is under PLAN §5's 3 CPU-min.

**Cache.** The matches are `strategy-switch.py --raw --ko-only`'s candidate arm: its `run_job`, `parse` and cache (`build/strategy-eval-cache/`), keyed by the sim build hash, the candidate's text, the characters, the seeds and the pool's texts. The incumbent arm (the shipped lookup) is left out because the score never reads it. A repeated call costs no sim (0.1 s). Every call runs simlib's `build()` first.

## Population files

```json
{"pair": "ki", "side": "kenpachi", "vs": "ichigo", "anchor": "none",
 "members": [{"id": "none", "file": "none", "why": "..."},
             {"id": "a-generic", "file": "docs/research/strategy-drsi/sp/arms/a-generic.lisp", "why": "..."}, ...],
 "mix": {"a-ken-kh-standoff": 1.0},
 "mix_source": "docs/research/strategy-drsi/sp/pop/ki-matrix.json (seeds 201-300, ...)",
 "screen": {"rule": "...", "margin": 0.05, "seeds": "301-340", "rows": {"<arm>": {"ko_wins": ..., "score": ..., "admitted": ...}}}}
```

- `members[].file` is repo-relative, or `none`.
- `id` is the file's base name, which is how `eval.py` and the matrix name a member.
- A round appends admitted arms to `members` and reruns `pop.py matrix`, which rewrites `mix`. No member is ever deleted (PLAN §2).

## pop.py

```sh
python3 docs/research/strategy-drsi/sp/pop.py screen --me C --vs D [--margin 0.05] [--seed0 300] [--seeds 40] ARM.lisp...
python3 docs/research/strategy-drsi/sp/pop.py matrix --a C --b D [--seed0 200] [--seeds 100]
python3 docs/research/strategy-drsi/sp/pop.py selftest
```

**`screen`** plays each ARM on C against D's `none`, and C's own `none` on the same seeds, both seats, K.O.s only.
- **Admission rule:** an arm is admitted if its K.O. rate (matches ended before the bell, either side) is at least 0.5 **and** its score is at least none's score + 0.05.
- The margin of 0.05 is about one standard error of a share at 80 matches. It is a seeding bar, not an admission test: the 400 block's held-out test comes later.
- `b`, `c` and `z` give the paired comparison against `none` on the same seed and seat.
- It writes `pop/<pair>-<C>.json` with `none`, `a-generic` and the admitted arms. It refuses an existing file unless given `--force`, because reseeding would drop members a round added.

**`matrix`** plays every member of A's population against every member of B's, both seats.
- Each cell keeps both sides' K.O. wins, the time-outs and the draws.
- Each side's mix comes from regret matching on its **own** K.O. share (general-sum). A time-out is worth 0 to both sides.
- `tools/strategy-matrix.py`'s zero-sum solve takes B's payoff as 1 - A's. That would hand the column player every time-out and lean its mix toward stalling.
- The output reports each side's gap: its best pure reply to the other's mix, minus its mix's payoff. A gap of 0 means an equilibrium.

**Why not `tools/strategy-matrix.py` itself:** its runner, `strat-desc.lisp`, cannot play `none`. Its no-strategy seat is the shipped HARD lookup, and it strips the style CPU even for a `:fq` / `:switch` strategy. `pop.py` plays the same `strat-run.lisp` matches as `eval.py` (it imports `eval.py`'s helpers) and takes nothing from `strategy-matrix.py`.

## KI numbers (build `14e22d37105e586d`, HARD)

**The generic arm** is `a-generic` (`:st-generic`: the generic CPU + the MCTS, no style CPU). `:s0-generic`, the dream-rsi initial program in PLAN §3, plays the same as a raw arm: its only extra, `:p`, is read only by the strategy layer. A cell starting from `(:id :s0-generic)` therefore starts from a population member.

### Screen

Seeds 301-340, both seats, 80 matches an arm, against the opponent's `none`. Columns: K.O. wins : K.O. losses, time-outs (draws).

**Kenpachi** (vs Ichigo's `none`):

| arm | K.O. W:L | time-outs (draws) | K.O. rate | score | z vs none | admitted |
|---|---|---|---|---|---|---|
| none | 19:56 | 5 (0) | 0.938 | 0.244 | | anchor |
| a-generic | 0:80 | 0 | 1.000 | 0.012 | -4.36 | the generic arm |
| a-ken-ki | 11:59 | 10 | 0.875 | 0.146 | -1.89 | no |
| **a-ken-press** | 36:44 | 0 | 1.000 | 0.451 | +2.72 | **yes** |
| a-ken-kite | 4:62 | 14 | 0.825 | 0.061 | -3.27 | no |
| a-ken-zoner | 17:39 | 24 | 0.700 | 0.220 | -0.36 | no |
| a-ken-kh | 4:60 | 16 | 0.800 | 0.061 | -3.27 | no |
| **a-ken-kh-standoff** | 32:47 | 1 | 0.988 | 0.402 | +2.41 | **yes** |
| a-ichigo-ki | 0:0 | 80 (76) | 0.000 | 0.012 | -4.36 | no |
| a-zoner | 0:80 | 0 | 1.000 | 0.012 | -4.36 | no |
| s1-brawler | 0:80 | 0 | 1.000 | 0.012 | -4.36 | no |
| s7-kite | 0:48 | 32 | 0.600 | 0.012 | -4.36 | no |

**Ichigo** (vs Kenpachi's `none`):

| arm | K.O. W:L | time-outs (draws) | K.O. rate | score | z vs none | admitted |
|---|---|---|---|---|---|---|
| none | 56:19 | 5 (0) | 0.938 | 0.695 | | anchor |
| a-generic | 0:80 | 0 | 1.000 | 0.012 | -7.48 | the generic arm |
| a-ichigo-ki | 55:17 | 8 | 0.900 | 0.683 | -0.20 | no |
| **a-ichigo-press** | 63:16 | 1 | 0.988 | 0.780 | +1.26 | **yes** |
| a-ichigo-kite | 35:17 | 28 | 0.650 | 0.439 | -3.28 | no |
| a-ichigo-zoner | 44:15 | 21 | 0.738 | 0.549 | -1.85 | no |
| a-ken-ki | 0:0 | 80 (0) | 0.000 | 0.012 | -7.48 | no |
| a-zoner | 0:80 | 0 | 1.000 | 0.012 | -7.48 | no |
| s1-brawler | 1:79 | 0 | 1.000 | 0.024 | -7.29 | no |
| s7-kite | 0:80 | 0 | 1.000 | 0.012 | -7.48 | no |

**How the candidates were chosen:**
- every arm unit any of the character's old tables played (Kenpachi's `qks*`, Ichigo's `q1-ichigo-*` / `qis-*`), the other character's KI style included;
- the character-free plain strategies (`a-zoner` = s3-zoner, `s1-brawler`, `s7-kite`).

**Reading:**
- Without a style function (`a-generic`, `a-zoner`, `s1-brawler`, `s7-kite`) either fighter loses nearly every match to the other's `none`, which keeps its KI style CPU.
- The other character's style function on a fighter (`a-ichigo-ki` on Kenpachi, `a-ken-ki` on Ichigo) never ends a match.

### Matrix

Seeds 201-300, both seats, 200 matches a cell. Each cell is Kenpachi's K.O. share / Ichigo's K.O. share; time-outs and draws are the rest.

| Kenpachi \ Ichigo | none | a-generic | a-ichigo-press |
|---|---|---|---|
| none | 0.230 / 0.720 | 1.000 / 0.000 | 0.190 / 0.800 |
| a-generic | 0.000 / 1.000 | 0.955 / 0.035 | 0.000 / 1.000 |
| a-ken-press | 0.395 / 0.605 | 1.000 / 0.000 | 0.325 / 0.675 |
| a-ken-kh-standoff | 0.410 / 0.585 | 1.000 / 0.000 | **0.360 / 0.640** |

**Mixes:** pure on both sides. Kenpachi plays `a-ken-kh-standoff` 1.0 (value 0.36), Ichigo `a-ichigo-press` 1.0 (value 0.64). Both gaps are 0.

**Reading:**
- The equilibrium is a pure saddle, PLAN's "pure equilibrium" risk. Group `mix` is a single arm for now.
- Every cell K.O.s at 95-100 % (`none` v `none` the lowest).

### Smoke

`--seed0 300`, 600 matches each.

| me | candidate | score | anchor | mix | rest | wall |
|---|---|---|---|---|---|---|
| kenpachi | none | 0.345 | 0.228 | 0.203 | 0.604 | 17.9 s cold |
| kenpachi | a-ken-zoner | 0.347 | 0.218 | 0.198 | 0.624 | 9.5 s cold, 0.1 s warm |
| kenpachi | a-ken-kh-standoff | 0.459 | 0.411 | 0.312 | 0.654 | 17.3 s cold |
| ichigo | none | 0.662 | 0.723 | 0.564 | 0.698 | 13.1 s cold |
| ichigo | a-ichigo-press | 0.749 | 0.792 | 0.688 | 0.767 | 11.6 s cold |

`a-ken-zoner`'s cold run found 25 of its anchor seeds already cached from the screen.
