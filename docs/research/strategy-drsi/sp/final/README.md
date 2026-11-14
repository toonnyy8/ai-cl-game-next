# The final tables (DUEL_AI_STRATEGY §11.15, PLAN2 §3, 2026-11-14)

One table per ordered pairing, HARD. Every file is `:rb-sp`, `:xfeats t`, `:keep-state t`, `:margin 0.02`, `:period 30`, as `band.py`
writes it, with its `.arms` beside it.
- **Gaining**: KI Ichigo only (`../ship/README.md`).
- **Fallback**: every other side (`band.py fallback`). Arm 0 is 0 in every rule. The alternates sit at Q -0.05 in every state, for
  `fq-online.lisp` to learn with against a human. It plays arm 0 bit for bit, so it is a fuzzy Q table in format only.

Sim build `476d19b6884e` (this checkout's `duel.fas`). Every score below is `eval.py`, block 200 (seeds 201-300), both seats, K.O.s only.
Counts are K.O. wins : K.O. losses : time-outs of 200.

| File | Side | Kind | Arm 0 | Alternates (Q -0.05) | What chose arm 0 |
|---|---|---|---|---|---|
| `ki-ichigo.lisp` | KI Ichigo | **gaining** | `r2-b2a2`, arm k `r3-b3a0-k` in `awake` | — | ship test z +2.63 (`../ship/README.md`) |
| `ki-kenpachi.lisp` | KI Kenpachi | fallback | `r2-b1a2` | `r1-b2a2`, `pilot-b0a0`, `none` | KI matrix + round 3 (`../ship/README.md`) |
| `kh-kenpachi.lisp` | KH Kenpachi | fallback | `c-ki-k-r2-b0a2` | `r1-b0a1`, `r1-b2a2`, `none` | vs Hisagi's pop 0.977 (`r1-b0a1` 0.959, `r1-b2a2` 0.924, `r2-b1a2` 0.546); vs `kh-hisagi` 196:0:4 (194:0:6, 187:0:13) |
| `kh-hisagi.lisp` | KH Hisagi | fallback | `a-hisagi-pressd` | `a-hisagi-kite`, `a-hisagi-dswitch`, `none` | vs `kh-kenpachi` every arm ≤ 2 K.O. wins of 200 (a tie); score 0.314 (anchor 187:6:7) over `kite` 0.304, `dswitch` 0.294 |
| `ih-ichigo.lisp` | IH Ichigo | fallback | `c-ih-i-r1-b0a1` | `r1-b1a1`, `c-ki-i-r1-b0a2`, `none` | vs Hisagi's pop 0.972 (`b1a1` 0.960, `ki-r1-b0a2` 0.746); vs `ih-hisagi` 200:0:0 (194:6:0, 166:31:3) |
| `ih-hisagi.lisp` | IH Hisagi | fallback | `c-ih-h-r1-b2a0` | `c-ih-h-r1-b0a2`, `a-hisagi-kite`, `none` | vs `ih-ichigo` 0:200:0 (a tie, see below); score 0.332 (anchor 198:1:1) over `b0a2` 0.317, `kite` 0.304 |
| `kk-kenpachi.lisp` | KK | fallback | `c-ki-k-r2-b0a2` | `c-ki-k-r2-b1a2`, `none` | beats `r2-b1a2` 143:57:0; both 200:0:0 vs `none` |
| `ii-ichigo.lisp` | II | fallback | `c-ki-i-r2-b2a2` | `c-ih-i-r1-b0a1`, `none` | beats `ih-r1-b0a1` 186:3:11; vs `none` 171:0:29 (`b0a1` 200:0:0) |
| `hh-hisagi.lisp` | HH | fallback | `c-ih-h-r1-b2a0` | `a-hisagi-pressd`, `none` | vs `pressd` 0:59:141, vs `none` 193:5:2; `pressd` vs `none` 60:0:140 |

## How the cross pairings were chosen

The order broke the loop between the two sides once:
1. The side at the ceiling was scored against the opponent's population file (`eval.py` default: anchor, mix, rest).
2. The other side was scored against that table.
3. The ceiling side got one confirmation pass against the new table.

The confirmation changed nothing: `r2-b0a2` and `ih-r1-b0a1` stay first.

**Against a single table**, `eval.py --pop` takes a scratch population:

```json
{"pair": "x", "side": "<opponent>", "vs": "x", "anchor": "none",
 "members": [{"id": "none", "file": "none"}, {"id": "<table>", "file": "docs/research/strategy-drsi/sp/final/<table>.lisp"}],
 "mix": {"<table>": 1.0}}
```

With it, group `anchor` is his `none` and groups `mix` and `rest` are the table. The table's share is the primary measure.

**Hisagi's tie rule.** Hisagi takes almost no K.O.s from either final table. Every KH arm got 0-2 of 200, and every IH arm 0-1, except
`a-hisagi-kite` with 7.
- So the primary measure ties: a difference under 0.04 counts as a tie.
- The tie rule set in advance was "fewer time-outs against the table". It would pick arms that never time out only because they lose
  every match: `none`, `h1-range` and `s7-kite` in KH, and `s7-kite` stalls 63 of 200 against `none`.
- So the rule used instead is the full `eval.py` score. Its difference then comes only from the anchor group, where a time-out already
  scores 0.
- **Open point, IH:** `a-hisagi-kite` is the only arm that takes K.O.s off `ih-ichigo`: 7 : 186 : 7 against 0 : 200 : 0, paired 7 / 0.
  But it stalls: 40 of 400 to the bell, against 2 for `b2a0`. It is an alternate, not arm 0.

**`b2a0`** is not a member of `ih-H.json`. It is round 1's code-cell arm (`../arms/ih-r1/`), and `b0a2` is built on it. It tied with
`b2a2` (0.3317 each) and was taken on time-outs (1 vs 2).

**The alternates** are the next arms by the same score, and then `none`. Two kinds of member are excluded:
- tables (`ki-ichigo` in `ih-I.json`);
- `a-generic` in KH and IH, which is `none` there (§11.13).

## Mirrors (PLAN2 §2 sufficiency check, sim only, no search)

**Candidates** are the character's cross-pairing arm 0s. Each played the other candidate and `none`, and itself.

`eval.py` with `--me` = `--vs` works: `jobs()` puts the same roster index on both seats. It needs `--pop`, since there is no
`kk-*.json`.

The pick is the best mean of the K.O. share against the other candidate and against `none`.

| Mirror | Pick | Self-play (pick vs itself) | K.O. rate | 90 % bar | Other candidate's self-play |
|---|---|---|---|---|---|
| KK | `r2-b0a2` | 100:100:0 | 100 % | pass | `r2-b1a2` 100:100:0, 100 % |
| II | `r2-b2a2` | 54:54:92 | **54 %** | **under** | `ih-r1-b0a1` 79:79:42, 79 % |
| HH | `ih-r1-b2a0` | 95:95:10 | 95 % | pass | `pressd` 0:0:200, 0 % |

The II mirror stalls under 90 % with either candidate. That is reported only: PLAN2 §2 allows ≤ 12 cells there, and §11.15 spends none.

## Checks

- **Identity.** `band.py pair --a <table> --b <raw arm 0> --seed0 200` gives b = c = 0, with the same time-outs, for all seven new
  tables (600 matches each; `--pop` the scratch population of the other candidate for the mirrors).
  - This also shows that `:apply (:X :X)` is honoured in a mirror.
- **`:fn`.** Every `:fn` in the nine files is defined in `duel/lisp/` and listed in `duel/MANIFEST`:
  - `ken-kh-standoff-style` (`cpu-kh-ken.lisp`);
  - `ichigo-ki-style`, `ichigo-ki-r2b2a1-style` (`cpu-ki-ichigo*.lisp`);
  - `hisagi-merged-style` (`cpu-hisagi-range.lisp`);
  - `hisagi-ihr1b2a0-style` (`cpu-ih-hisagi-ihr1b2a0.lisp`).

## Commands

Run from `docs/research/strategy-drsi/sp/`.

```sh
A=arms
python3 band.py fallback --me kenpachi --vs hisagi --inc $A/r2/c-ki-k-r2-b0a2.lisp --alt $A/r1/c-ki-k-r1-b0a1.lisp $A/r1/c-ki-k-r1-b2a2.lisp none --out final/kh-kenpachi.lisp
python3 band.py fallback --me hisagi --vs kenpachi --inc $A/a-hisagi-pressd.lisp --alt $A/a-hisagi-kite.lisp $A/a-hisagi-dswitch.lisp none --out final/kh-hisagi.lisp
python3 band.py fallback --me ichigo --vs hisagi --inc $A/ih-r1/c-ih-i-r1-b0a1.lisp --alt $A/ih-r1/c-ih-i-r1-b1a1.lisp $A/r1/c-ki-i-r1-b0a2.lisp none --out final/ih-ichigo.lisp
python3 band.py fallback --me hisagi --vs ichigo --inc $A/ih-r1/c-ih-h-r1-b2a0.lisp --alt $A/ih-r1/c-ih-h-r1-b0a2.lisp $A/a-hisagi-kite.lisp none --out final/ih-hisagi.lisp
python3 band.py fallback --me kenpachi --vs kenpachi --inc $A/r2/c-ki-k-r2-b0a2.lisp --alt $A/r2/c-ki-k-r2-b1a2.lisp none --out final/kk-kenpachi.lisp
python3 band.py fallback --me ichigo --vs ichigo --inc $A/r2/c-ki-i-r2-b2a2.lisp --alt $A/ih-r1/c-ih-i-r1-b0a1.lisp none --out final/ii-ichigo.lisp
python3 band.py fallback --me hisagi --vs hisagi --inc $A/ih-r1/c-ih-h-r1-b2a0.lisp --alt $A/a-hisagi-pressd.lisp none --out final/hh-hisagi.lisp
python3 eval.py --me hisagi --vs kenpachi --cand $A/a-hisagi-pressd.lisp --pop POP.json --seed0 200   # POP.json: the shape above
```
