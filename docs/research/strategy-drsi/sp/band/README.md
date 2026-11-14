# Band-specialist tables: the generator, the identity proofs, the KI sim-only check (PLAN2 §5 step 1, 2026-11-14)

PLAN2.md §1 builds tables from band specialists: the side's best pure arm (arm 0) in every `:rb-sp` rule, and one arm k only in one
pre-registered band. Before any search cell runs, the sim-only check asks whether the one division of labour the fit probe saw
(`../fit/README.md`) gains with arms that already exist.

**Verdict: no band is admitted on either side.**

| Side | Band table | Admission result (seeds 801-1000) |
|---|---|---|
| Kenpachi | `r1-b2a2` in `nocell` | pooled z -1.17, 16 time-outs against arm 0's 0 |
| Ichigo | `none` in `myburst` | keep-state on (the test): z -1.31; off (record): z -1.17 |

Both tables lose to arm 0 on the fresh block. Block 300 and block 200 disagree about Kenpachi's band (+0.003, then -0.007), and the
admission block settles it: a loss.

No Lisp changed and the sim build was unchanged. G2, the host tests and pkgcheck are not affected.

## `band.py` (one implementation: sw.py's rule-base reader and table writer, imported)

```sh
python3 band.py bands                                    # each band's :rb-sp rule indices and antecedents
python3 band.py write --me C --vs D --inc ARM0 --var ARMK|none --band B --out FILE [--q 0.05] [--margin 0.02] [--period 30]
                      [--no-keep-state [--record]]
python3 band.py pair --me C --vs D --a FILE --b FILE --seed0 N [--seeds 100] [--spill] [-j 6]
```

- `write` produces a raw `:fq` file in the format `eval.py --cand` scores:
  - `:rb-sp` inline, with `:groups (18 9 9 4 2)` and `:xfeats t`;
  - the two arms inline;
  - `:margin 0.02`, `:period 30`, `:keep-state t` by default.

  It also writes `FILE.arms` beside the table, in the arms format `sw.py measure --arms` takes.
- `:keep-state` is required when arm k has another `:fn` or is `none`. `--no-keep-state` then needs `--record`: such a table is kept for the
  record only, never admitted.
- `pair` plays two candidates on the same seeds through `eval.py`'s own `groups` / `jobs` / `play`, so it shares eval.py's sim path and cache.
  - Output, per opponent group and pooled: b (A won by K.O. and B did not), c (the reverse), z = (b - c) / sqrt(b + c), and both sides'
    time-outs.
  - This is `sw.py pair`'s statistic over all three groups.
  - Its counts equal eval.py's counts on the same seeds (checked: `results/admission-801-1000.jsonl`).

**The q values** are written, not fitted (PLAN2 §3):

| Arm | The band's rules | The other rules of the band's group | Every other group |
|---|---|---|---|
| arm 0 | 0 | 0 | 0 |
| arm k | +q | -q | 0 |

- The -q is required. `strat-fq-pick` keeps the previous arm while it trails the best by less than `:margin`. If arm k were 0 outside the
  band (a tie with arm 0), the table would stay in arm k once it was picked.
- With a `none` arm this would also bite on the first judgement: `brain-sw-sub` starts NIL, so `:prev` reads 1, arm k's index.
- The band's groups are crisp (cells 0 / 1 / 2-3, bursts 0 / 1, the form index), so one state fires there. The gap between the arms is then
  +-q in every state.
- **Any q above `:margin` plays exactly the same.** q = 0.05 was used; it is not a knob for these bands.
- **For PLAN2 §3's merge**, where q is written as the measured gain:
  - In a single crisp band, a gain at or below `:margin` (0.02) could never switch, and `write` refuses one (it asserts q > margin).
  - The size of q matters only when merged bands from different groups are active at once: the larger q decides there. The merge step has
    to set q with that in mind.

**The bands** (`band.py bands`; rule indices in `:rb-sp` order: G0 0-17, G1 18-26, G2 27-35, G3 36-39, G4 40-41):

| Band | Group | Rules | Antecedents |
|---|---|---|---|
| `nocell` | G2 | 27 | (mcell no, ocell no) |
| `mycell` | G2 | 30-35 | mcell yes or p2up, any ocell |
| `bothrich` | G2 | 35 | (mcell p2up, ocell p2up) |
| `myburst` | G3 | 38, 39 | mburst yes, any oburst |
| `hisburst` | G3 | 37, 39 | oburst yes, any mburst |
| `awake` | G1 | 21-26 | form yes or k2 (my form >= 1), every distance |

## Identity proofs (PLAN2 §1 admission step 1)

- **Setup:**
  - the band table, with arm k a copy of arm 0;
  - against arm 0 played raw, through `sw.py measure`;
  - against the opponent's mix (his pure r2 arm), seeds 501-600, both seats;
  - compared with `../fit/same.py` on the gate rows and the `duel hash` lines.
- **Result:** all four proofs are identical.

| Table | Matches | Hash lines | Arm k share of judgements | Changes a match | Same as arm 0 raw |
|---|---|---|---|---|---|
| `id-k-nocell` (Kenpachi `r2-b1a2`, nocell, keep-state on) | 200 | 4,236 | 0.454 | 24.8 | identical |
| `id-k-nocell-ks0` (keep-state off) | 200 | 4,236 | 0.454 | 24.8 | identical |
| `id-i-myburst` (Ichigo `r2-b2a2`, myburst, keep-state on) | 200 | 4,236 | 0.060 | 6.5 | identical |
| `id-i-myburst-ks0` (keep-state off) | 200 | 4,236 | 0.060 | 6.5 | identical |

- **The proofs switch.** `by_rule` shows arm k at share 1.0 in every band rule and 0.0 in every other rule of the band's group, on both
  sides. That is the confinement check for the -q.
- **These proofs do not test `:keep-state`.** A copied arm has the same `:fn`, so the keep path never runs: on and off are the same here by
  construction.

## The KI sim-only check

**Tables:**
- Kenpachi: `ki-k-nocell-r1b2a2.lisp`. Arm 0 is `arms/r2/c-ki-k-r2-b1a2.lisp`, arm k is `arms/r1/c-ki-k-r1-b2a2.lisp` (the same
  `:fn`), band `nocell`.
- Ichigo: `ki-i-myburst-none.lisp` (keep-state on) and `ki-i-myburst-none-ks0.lisp` (off, `--record`). Arm 0 is
  `arms/r2/c-ki-i-r2-b2a2.lisp`, arm k is `none` (her shipped CPU, `ichigo-ki-style`), band `myburst`.

**How often the band is active** (`sw.py measure` against the mix, 501-600): Kenpachi plays arm k at 0.436 of judgements (22.5 changes a match).
Ichigo plays it at 0.059 / 0.065 (on / off; about 7 changes a match).

### Dev (block 300) and rescore (block 200)

`eval.py`, three opponent groups, 100 seeds a seat. K.O. wins of 200 a group; "t/o" = time-outs.

| Side | Candidate | Block 300 score | anchor / mix / rest (t/o) | Block 200 score | anchor / mix / rest (t/o) |
|---|---|---|---|---|---|
| Kenpachi | arm 0 `r2-b1a2` | 0.6518 | 187 / 52 / 153 (0) | **0.6733** | 195 / 56 / 154 (0) |
| Kenpachi | band `nocell` <- `r1-b2a2` | **0.6551** | 188 / 55 / 151 (6) | 0.6667 | 190 / 62 / 149 (9) |
| Kenpachi | arm k `r1-b2a2` raw (reference) | 0.5759 | 188 / 23 / 135 (18) | 0.5957 | 189 / 33 / 136 (14) |
| Ichigo | arm 0 `r2-b2a2` | **0.8927** | 199 / 148 / 191 (0) | 0.8828 | 200 / 144 / 188 (0) |
| Ichigo | band `myburst` <- `none`, keep-state on | 0.8762 | 199 / 146 / 183 (0) | 0.8680 | 200 / 140 / 183 (0) |
| Ichigo | band `myburst` <- `none`, keep-state off | 0.8861 | 198 / 152 / 184 (0) | **0.8861** | 200 / 147 / 187 (0) |

**Kenpachi:**
- The band beats arm 0 on the dev block by 0.003 and loses on the rescore by 0.007.
- It takes more K.O. wins from the mix (+3, +6) but times out against the `rest` pool (6, 8).
- Arm k alone times out too (15, 11 in `rest`). It never awakens (`:kk-awaken-p 0`).

**Ichigo:**
- Keep-state on loses on both blocks.
- Keep-state off loses on block 300 and beats arm 0 on block 200 (0.8861 against 0.8828). That makes it the side's best by block 200.

### Admission (seeds 801-1000, both seats, 1,200 matches, paired against arm 0 on the same seeds)

The test is one table a side, the best by block 200 among the admissible tables.
- Kenpachi: his only band.
- Ichigo: keep-state on, her only admissible table. PLAN2 §1 allows a `none` arm only with `:keep-state`, and the keep-state-off table was
  written `--record`.

Ichigo's off table scored higher on block 200 and was run as well, **for the record only**.

| Table vs arm 0 | anchor b / c | mix b / c | rest b / c | Pooled b / c | Pooled z | Time-outs (table / arm 0) | eval.py score (table / arm 0) | Admitted |
|---|---|---|---|---|---|---|---|---|
| Kenpachi `nocell` <- `r1-b2a2` | 16 / 20 | 72 / 76 | 34 / 45 | 122 / 141 | **-1.17** | 16 / 0 | 0.6434 / 0.6592 | no (z < 2.0; time-outs above arm 0's) |
| Ichigo `myburst` <- `none`, keep-state on (the test) | 0 / 1 | 63 / 78 | 23 / 25 | 86 / 104 | **-1.31** | 1 / 1 | 0.8690 / 0.8839 | no (z < 2.0) |
| Ichigo `myburst` <- `none`, keep-state off (record) | 0 / 1 | 71 / 88 | 26 / 25 | 97 / 114 | -1.17 | 1 / 1 | 0.8698 / 0.8839 | (record; not admissible) |

- Neither side gains. Both point toward a loss, within noise: |z| < 1.96.
- Kenpachi's band also fails the stalling bar: 13 of its 16 time-outs come from the `rest` pool.
- **Keep-state on vs off for Ichigo:** it makes no measurable difference here.
  - The scores are 0.8690 / 0.8698 on the admission block, with the same time-outs.
  - On block 300 off is ahead by 0.010; on block 200 by 0.018.
  - Her `none` plays about 6 % of judgements in this band, so the style reset rarely fires. The probe's 11 time-outs came from tables
    that switched far more.

**What this says for KI round 3** (PLAN2 §2): the existing arms do not make a band specialist.
- Kenpachi's `r1-b2a2` without cells gives a few more K.O. wins against the mix, and pays for them with stalls against the older pool.
- Ichigo's `none` in her burst costs mix wins.
- A specialist has to be searched for its band, as round 3 plans. If round 3 admits none either, PLAN2 §2's stop rule applies.

## Commands

Run from the repo root. Logs go to `fq/switch/logs/spfit/band/` and measure summaries to `fq/switch/spfit/band/` (both gitignored). eval.py
caches its matches in `build/strategy-eval-cache/`. About 15,000 matches in all, a few CPU-minutes.

```sh
R=docs/research/strategy-drsi/sp/band/run.sh
$R tables                                                            # the seven tables here (+ their .arms)
$R measure k arms/r2/c-ki-k-r2-b1a2.lisp id-k-raw 501-600             # arm 0 raw (and i: arms/r2/c-ki-i-r2-b2a2.lisp id-i-raw)
$R measure k band/id-k-nocell.lisp id-k-nocell 501-600                # the identity tables (-ks0 too; i: band/id-i-myburst.lisp)
$R same id-k-nocell id-k-raw                                         # -> identical (4 proofs)
$R eval k band/ki-k-nocell-r1b2a2.lisp 300                           # and 200; arm 0 and the Ichigo tables alike -> results/eval-b300-b200.jsonl
$R pair k band/ki-k-nocell-r1b2a2.lisp arms/r2/c-ki-k-r2-b1a2.lisp 800 200 --spill   # admission -> results/admission-801-1000.jsonl
$R eval k band/ki-k-nocell-r1b2a2.lisp 800 200 --spill               # eval.py accepts 801-1000 with --spill (same counts as pair)
```

Sim build `9fc5577e8ca4` (every row).
