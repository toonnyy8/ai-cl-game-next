# The KI fit probe: do switching fuzzy Q tables beat the best pure arm? (2026-11-14)

A checkpoint before KH and IH are searched (DUEL_AI_STRATEGY §11; PLAN.md §4). Both KI populations ended with a pure equilibrium: each side's
newest arm dominates its older arms against the other's newest (`sp/pop/ki-K.json`, `ki-I.json`, `ki-matrix.json`). The plan's tables are
worth building only if a table that switches between a side's admitted arms by situation beats that side's best pure arm. This probe asks
that question for KI only, HARD, K.O.-only.

**Verdict: no.** On the held-out block 400 neither side's table beats its best pure arm. Every row is "too close" (|z| < 1.96), and the
pooled direction is a loss for Ichigo (z -1.71) and a tie for Kenpachi (z -0.10). On the selection block 500, 28 table variants all scored at
or below the pure arm on the mean of the two opponents. The more a table switched, the worse it played.

## What changed in `fq/switch/sw.py` (one implementation, the old path kept)

- `--rb` (default `:rb-switch89`) picks the rule base. The antecedents and `:groups` are read from strategy.lisp's `*strat-rule-bases*`,
  the one definition, and written inline with `:groups` and `:xfeats t`: a raw file is never expanded, so a `:rule-base` key would play
  empty. `:rb-switch89` read this way equals the old hard-coded list string for string. Three old tables (`hi/hi2-r2-g966`,
  `hi2-r1-g98-pin`, `hi2-s0`) went through `read_q` and `write_table` and came back with their Lisp form byte-identical; only the header comment
  changed.
- `--ko` sets PLAN §4's outcome. At the end a K.O. pays +1 / -1, a time-out -1 to both sides, a draw before the bell 0. The health shaping
  (0.1 x Δbalance per window) is unchanged. `measure`'s `share`, `score` ((K.O. wins + 1) / (n + 2)) and `wins` then count K.O. wins only,
  so `sw.py pair` gives the paired b / c / z on K.O. wins. Each match's `ko` field is parsed from the gate row (simlib `row_ko`).
- The start table (arm 0 everywhere) is group-aware (G0 by `GROUP_OF`, not the first 72 rows).
- `run()` now does the following:
  - leaves a `none` opponent as `none` (it used to make it a path);
  - sends exactly strategy-switch.py's commands (the freed ASSIST commands 81000 / 81030 / 81040 dropped);
  - sets stdin to /dev/null (an ECL error no longer waits in its debugger);
  - keeps the `duel hash` lines for identity proofs.
  `--table none` plays my seat with no strategy (a reference run).
- `log` / `measure` / `fit` take no default seeds, so the pilot's 1-599 / 701-800 cannot run by accident. `-j` defaults to 6.
- `fit` changes:
  - `--margin M` writes `:margin`.
  - `--only 0,1` lets the table pick only those arms; the fit still uses every logged arm.
  - The fit and its bootstrap gate are one function, `gated()`, which `cues.py` reuses. It is a pure move of the old code: the same rng and
    the same order.
  - It prints the kept deltas per group.
- `measure` adds `by_rule` (each rule's firing-weighted arm shares), `ko_rate`, `timeouts`, `score`. The parsed judgement tuple gains `ored`,
  `ost`, `awk` at its end.

No Lisp changed (no game code, no `strat-run.lisp`), so G2, host tests and pkgcheck are not affected.

## Setup

- **Arms** (`ki-k.arms`, `ki-i.arms`): the pop files' members, the newest admitted arm first. `a-generic` is dropped: every styled arm beats it
  about 1.0 (`ki-matrix.json`). `nil` is `none`, the side's shipped CPU with its KI style CPU (a Q selector's NIL arm, strategy-glue.lisp
  `strat-switch-step`).
  - Kenpachi (6): `r2-b1a2`, `r1-b2a2`, the pilot, `a-ken-kh-standoff`, `a-ken-press`, `none`. Arms 0-3 share `ken-kh-standoff-style`;
    press and none are `ken-ki-style`.
  - Ichigo (4): `r2-b2a2` (`ichigo-ki-r2b2a1-style`), `r1-b3a2`, `a-ichigo-press` (both `ichigo-ki-style`), `none` (`ichigo-ki-style`).
    Every switch away from arm 0 changes her style function.
- **Table**: `:rb-sp` (42 rules, groups 18 9 9 4 2), `:xfeats t`, period 30 (0.5 s), no `:keep-state` unless named.
- **Opponents**: the other side's equilibrium mix, which is pure (Kenpachi `r2-b1a2`, Ichigo `r2-b2a2`), and its anchor `none`. The fit logs
  play the pool `mix,none` (member = seed mod 2).
- **Seeds**:
  - fit logs: 201-400 (blocks 200 + 300), 4 salts x both seats = 1,600 matches a round;
  - selection: 501-600 (block 500);
  - the deciding test: 401-500 (block 400), once.
  - 601-800 was never run.
- **Method**: §8.19's. Exploration in runs (eps 0.03 a judgement, runs of 6-18 judgements), a ridge V plus per-arm deltas (λ 300), and a
  match-bootstrap sign gate (20 replicates, 0.95).

## Identity proofs

- The start table `ki-<side>-s0.lisp` (arm 0 in every state) against arm 0 played raw, both seats, seeds 501-600:
  - against the mix and against `none`, both sides: 8 x 200 matches;
  - gate rows and `duel hash` lines identical: Kenpachi 200 + 4,236 / 200 + 3,928 lines, Ichigo 200 + 4,236 / 200 + 3,908.
  - Also on 501-510.
- A table whose arm 0 is `nil` against `none` played raw, 501-510, both sides: identical (20 rows + 400 / 374 hash lines). So a `none` arm
  inside a table plays exactly as the anchor.

## Selection (block 500, 200 matches an opponent, K.O.-only score)

Mean = the mean of the two scores (the pre-registered pick rule). "chg" = arm changes a match (mean of the two). Tags: r1 = fit on the
start table's logs; r2 = logs played by r1 (on-policy round 2); r2m = logs played by r1-m0.03; r12 = both rounds' logs. Options: `m` margin,
`g` gamma, `s0` no health shaping (pure outcome), `c99` λ 3000 / conf 0.99 / 100 replicates, `ks` `:keep-state`, `o01` picks only arms 0-1.

| Kenpachi table | mean | vs mix | vs none | time-outs | chg |
|---|---|---|---|---|---|
| **s0 (= `r2-b1a2` whole)** | **0.604** | 0.253 | 0.955 | 0 | 0 |
| r1-o01-g0.99-m0 (picked) | 0.599 | 0.292 | 0.906 | 2 | 67 |
| r1-o01-g0.966-m0 | 0.597 | 0.253 | 0.941 | 0 | 51 |
| r1 | 0.592 | 0.272 | 0.911 | 4 | 62 |
| r1-o01-g0.99-m0.02 | 0.584 | 0.248 | 0.921 | 1 | 24 |
| r1-ks | 0.567 | 0.228 | 0.906 | 4 | 61 |
| r1-c99 | 0.564 | 0.208 | 0.921 | 0 | 53 |
| r1-m0.01 | 0.562 | 0.228 | 0.896 | 1 | 42 |
| r1-o01-g0.966-m0.02 | 0.552 | 0.183 | 0.921 | 1 | 3 |
| r1-m0.03 | 0.540 | 0.154 | 0.926 | 1 | 11 |
| r1-g99 | 0.537 | 0.154 | 0.921 | 1 | 77 |
| r12m-m0.03 | 0.530 | 0.149 | 0.911 | 4 | 20 |
| r12 | 0.505 | 0.124 | 0.886 | 0 | 89 |
| r2 | 0.485 | 0.124 | 0.847 | 0 | 81 |
| r2m-m0.03 | 0.451 | 0.149 | 0.753 | 5 | 22 |
| r1-g995s0 | 0.391 | 0.059 | 0.723 | 0 | 86 |
| r1-g1s0 | 0.381 | 0.099 | 0.663 | 0 | 92 |

| Ichigo table | mean | vs mix | vs none | time-outs | chg |
|---|---|---|---|---|---|
| **s0 (= `r2-b2a2` whole)** | **0.869** | 0.748 | 0.990 | 0 | 0 |
| r12m-m0.03 (picked) | 0.817 | 0.644 | 0.990 | 1 | 9 |
| r1-m0.01 | 0.809 | 0.673 | 0.946 | 13 | 17 |
| r1-ks | 0.787 | 0.579 | 0.995 | 0 | 40 |
| r1-m0.03 | 0.785 | 0.589 | 0.980 | 3 | 5 |
| r1-c99 | 0.772 | 0.634 | 0.911 | 19 | 51 |
| r1 | 0.748 | 0.555 | 0.941 | 19 | 42 |
| r1-g99 | 0.713 | 0.465 | 0.960 | 12 | 64 |
| r2m-m0.03 | 0.710 | 0.480 | 0.941 | 8 | 21 |
| r12 | 0.663 | 0.386 | 0.941 | 12 | 35 |
| r1-g995s0 | 0.631 | 0.317 | 0.946 | 16 | 71 |
| r1-g1s0 | 0.599 | 0.243 | 0.955 | 9 | 68 |
| r2 | 0.436 | 0.074 | 0.797 | 3 | 23 |

On-policy round 2 made both sides worse, not better. A longer horizon, or pure outcome without shaping, was worse still (as in §8.19).

## The deciding test (block 400, seeds 401-500, both seats, 200 matches a row)

Pre-registered before any block-400 run: the pick rule above, one table per side, each against its `s0` on the same seeds. A gain needs
z >= 1.96, a loss z <= -1.96; anything between is "too close". Ichigo's row against `none` can only be a non-inferiority check: her pure arm
sits at 0.99 there.

| Side, opponent | pure arm: K.O. wins, score | table: K.O. wins, score | K.O. rate (arm / table) | time-outs (arm / table) | b / c (table won only / arm won only) | z |
|---|---|---|---|---|---|---|
| Kenpachi vs mix | 59, 0.297 | 54, 0.272 | 1.000 / 1.000 | 0 / 0 | 37 / 42 | -0.56 |
| Kenpachi vs none | 184, 0.916 | 188, 0.936 | 1.000 / 0.995 | 0 / 1 | 15 / 11 | +0.78 |
| Ichigo vs mix | 141, 0.703 | 126, 0.629 | 1.000 / 1.000 | 0 / 0 | 36 / 51 | -1.61 |
| Ichigo vs none | 200, 0.995 | 199, 0.990 | 1.000 / 1.000 | 0 / 0 | 0 / 1 | -1.00 |

- Pooled over both opponents: Kenpachi b / c 52 / 53 (z -0.10), Ichigo 36 / 52 (z -1.71).
- Every row is too close. None is a gain, and Ichigo's table leans toward a loss against the mix.
- The summaries are in `results/`.

## What the tables do (block 400, pooled over both opponents; `picks.py`)

- **Kenpachi** (`r1-o01-g0.99-m0`, arms 0-1 only): r2-b1a2 0.40-0.43, r1-b2a2 0.57-0.60 of judgements.
  - 156-237 judgements a match and 52-82 arm changes a match: no match without one.
  - The clearest split is G2, the cells. With no cells on either side he plays `r1-b2a2` (0.93). Once he or she holds a cell he plays
    `r2-b1a2` (0.79-0.95). With his burst running he plays `r2-b1a2` (0.98).
  - That fits what the two arms are. `r2-b1a2` is `r1-b2a2` with three changes: SP-spending knobs that can only act with cells (`:other 10`
    always Burst / Kikon-cancel, `:kikon 0.3`, `:kk-ns-safe-p 0.8`), awakening on (`:kk-awaken-p 1`), and a shorter step (`:kk-step-max` 4.5
    against 7).
  - G0 is mostly `:prev` stickiness (prev :yes keeps arm 1 at 0.58-0.81). G1 (form x distance) is weak: arm 1 0.43-0.76 in every band.
- **Ichigo** (`r12m-m0.03`, margin 0.03): r2-b2a2 0.73-0.81, r1-b3a2 0.11, none 0.08-0.15, press 0.01-0.03.
  - 7.6-10.5 arm changes a match.
  - She plays `none` while her burst runs (0.88) and when both sides hold 2-3 cells (0.95).
  - G0 is almost all `:prev` (the arm held stays held: margin plus stickiness).
  - Distance and form barely move her: r2 0.62-0.86 in every form x band cell.

## Do the `:rb-sp` groups carry signal? Are the left-out cues needed? (`cues.py`, offline, round-1 logs)

The kept-delta counts per group come from the real fit and from a placebo (the arm labels shuffled, the gate's false positives). The gate is
about a one-sided |z| > 1.65 test, and the groups are collinear (each group's firing sums to 1), so a count means something only against its
placebo.

| Group (cells = rules x arms) | Kenpachi kept / cells (placebo) | Ichigo kept / cells (placebo) |
|---|---|---|
| G0 lead x ost x prev | 30 / 108 (14) | 27 / 72 (11) |
| G1 form x distance | 11 / 54 (2) | 14 / 36 (7) |
| G2 my x his cells | 20 / 54 (11) | 9 / 36 (5) |
| G3 my x his burst | 11 / 24 (5) | 7 / 16 (5) |
| G4 exchange open | 4 / 12 (4) | 1 / 8 (0) |
| extra: `:ored` | 1 / 12 (2) | 6 / 8 (2) |
| extra: `:awk` | 10 / 12 (2) | 4 / 8 (0) |
| extra: `:oawk` | 2 / 12 (1) | 0 / 8 (1) |
| extra: `:wall` (< 2.5 m) | 6 / 12 (2) | 3 / 8 (0) |

Reading the counts against their placebos:
- G0, G1 and G2 carry more than the placebo on both sides. G3 does a little for Kenpachi only.
- **G4 carries nothing.** `:xch` is 1 at about 5 % of judgements and is at the placebo level on both sides.
- **`:awk` is not needed.** It equals G1's form >= 1 at every judgement for these two characters, so its "kept" deltas are G1's.
- `:oawk` is at the placebo level.
- `:wall` shows a little (6 vs 2, 3 vs 0). `:ored` shows a little for Ichigo (6 vs 2) and nothing for Kenpachi.

"Signal in the fit" is not "useful to the table": the tables built from these deltas lost. So none of the four looks needed for these
arms. `:wall` and Ichigo's `:ored` are the only candidates worth a small group if a later pairing's arms differ by situation.

**The randomised runs' effect on the outcome** (round 1: runs start at random, so this is causal for "a 3-9 s run of arm k, then arm 0"; match
K.O. win on the share of judgements explored into arm k, per unit share):

| Kenpachi arm | effect (se, z) | Ichigo arm | effect (se, z) |
|---|---|---|---|
| 1 `r1-b2a2` | +0.37 (0.14, **+2.72**) | 1 `r1-b3a2` | -0.24 (0.10, -2.32) |
| 2 pilot | -0.11 (0.14, -0.83) | 2 `a-ichigo-press` | +0.06 (0.11, +0.58) |
| 3 standoff | -0.23 (0.14, -1.65) | 3 `none` | -0.49 (0.11, **-4.48**) |
| 4 press | -0.23 (0.13, -1.79) | | |
| 5 `none` | -0.45 (0.13, **-3.59**) | | |

- Every deviation from arm 0 hurts on average, or does nothing, with one exception: Kenpachi's arm 1. Its z is 2.7 with five arms tested,
  so that result is tentative.
- The exception is why `--only 0,1` was tried. On block 400 it did not turn into a gain.

## Why the tables lose, as far as the data shows

1. **What the fit estimates is not what the table plays.** The fit estimates "a 3-9 s run of arm k from here, then back to arm 0". The greedy
   table plays a different policy: arm k wherever its delta wins, judged every 0.5 s, 50-90 changes a match. On-policy round 2 should
   correct that, but it made both sides worse (the arm picks are now confounded with state beyond the features).
2. **The switching itself has a cost.** Losses track arm changes a match: the most-switching variants are the worst on both sides.
3. **Ichigo's switches reset her style state.** Every switch away from arm 0 changes her style function. That shows up as time-outs
   against `none`: r1 has 11 of 200 and r1-ks 0. `:keep-state` removes them, but it does not fix the mix row (0.579 vs 0.748).
   - This reopens §8.19's "drop `:keep-state`" for tables whose arms use different style functions. That decision is the user's.
4. **The populations leave nothing to choose.** Against the opponent's newest arm, every older Kenpachi arm scores 0.00-0.17 (`ki-matrix.json`)
   and every older Ichigo arm loses too. The newest arms are refinements of the older ones, not specialists.

This negative result covers this fit method and this population. It does not show that no switching policy could gain.

## For KH / IH: an admission rule that gives the tables something to choose

The current rule admits an arm when it beats the population as a whole-game style. Each newest arm then dominates, and the table has only
worse whole-game styles to switch to. Instead:

- **Admit by the run-effect test.** Inside the incumbent's start table, give a candidate arm randomised runs (`sw.py log`, eps 0.03, runs
  6-18). Admit it if its run effect on the K.O. win is positive at z >= 2 (`cues.py`'s last block).
  - This measures exactly what a table can use: an arm that is better for a while somewhere.
  - It flagged Kenpachi's `r1-b2a2` here, the only arm whose runs helped.
- **Prefer knob-only arms that share the incumbent's style function**, or require `:keep-state` when the function differs. Every function
  change costs the style's state.
- **Search situational arms.** Score a dream-rsi cell on the windows of one cue band only, e.g. no cells on either side, both at 2-3 cells,
  or my burst running: the bands where the tables here did move.
  - Kenpachi's split by cells (`r1-b2a2` without cells, `r2-b1a2` with them) is the one division of labour this probe found.
  - Specialists searched for such a band, judged with K.O.-only scoring, would give a table a real choice.
- Keep PLAN §6's bar: a table ships only if it beats the best pure arm on held-out seeds. Otherwise the lookup plays the pure arm.

## Commands

Logs and summaries go to `fq/switch/logs/spfit/` and `fq/switch/spfit/` (both gitignored). Every sim runs simlib's `build()` first. About
24,000 matches in all, roughly 1 CPU-hour (a match is about 0.15 CPU-s).

```sh
F=docs/research/strategy-drsi/sp/fit
$F/run.sh start                                   # ki-k-s0.lisp, ki-i-s0.lisp (arm 0 everywhere, :rb-sp, period 30)
TMPDIR=<scratch> $F/run.sh identity 501-510       # start table = arm 0 raw; nil arm = none
$F/run.sh log k ki-k-s0.lisp r1-k 1 2 3 4         # round-1 logs, 201-400 x 4 salts x both seats, against mix,none
$F/run.sh log i ki-i-s0.lisp r1-i 1 2 3 4
$F/run.sh fit k r1-k ki-k-r1.lisp                 # + --margin M, --gamma G, --scale 0, --keep-state, --only 0,1, --lam / --conf / --boot
$F/run.sh log k ki-k-r1.lisp r2-k 1 2 3 4         # round 2 (on-policy), and r2m from ki-<side>-r1-m0.03.lisp
$F/run.sh fit k r1-k,r2m-k ki-k-r12m-m0.03.lisp --margin 0.03
$F/run.sh sel k ki-k-r1-o01-g0.99-m0.lisp         # block 500 against mix and none
$F/run.sh measure k ki-k-s0.lisp ho/ki-k-s0-mix 401-500 mix                 # the deciding test (and -none, and the picked table)
$F/run.sh measure k ../arms/r2/c-ki-k-r2-b1a2.lisp idraw-k-mix 501-600 mix   # the raw arm, then:
python3 $F/same.py spfit/sel-k-s0-mix spfit/idraw-k-mix                      # identity on 200 matches
(cd docs/research/strategy-drsi/fq/switch && python3 sw.py pair spfit/ho/ki-k-r1-o01-g0.99-m0-mix.json spfit/ho/ki-k-s0-mix.json)
python3 $F/cues.py --me kenpachi --vs ichigo --arms ../../sp/fit/ki-k.arms --ko --tag spfit/r1-k --seeds 201-400   # cues-r1-k.txt
python3 $F/picks.py spfit/ho/ki-k-r1-o01-g0.99-m0 r2 r1 pilot standoff press none
```

The block-500 rows for `s0` and `r1` came from `run.sh measure` under the tags `sel-<side>-<t>-<opp>`. The other rows came from `run.sh sel`.
The tables are the `ki-*.lisp` here, each with its fit summary `ki-*.json`.
