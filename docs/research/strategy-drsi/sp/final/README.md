# The final tables (DUEL_AI_STRATEGY §11.27, PLAN3 §3, 2026-11-15; first written §11.15, PLAN2 §3, 2026-11-14)

One table per ordered pairing, HARD. Every file is `:rb-sp`, `:xfeats t`, `:keep-state t`, `:margin 0.02`, `:period 30`, as `band.py`
writes it, with its `.arms` beside it.
- **Fallback**: every file since the re-collection (`band.py fallback`).
  - Arm 0 is 0 in every rule. The alternates sit at Q -0.05 in every state, for `fq-online.lisp` to learn with against a human.
  - It plays arm 0 bit for bit, so it is a fuzzy Q table in format only.
- KI Ichigo's gaining band table of 2026-11-14 was replaced by the re-collection's table, which passed its ship test against it. The old
  table is `../ship/head-2026-11-14/ki-ichigo.lisp`. It is still a member of Ichigo's IH population (`../pop/ih-I.json` points there), so
  later evaluations keep playing what the IH matrix measured.

**Re-collection (2026-11-15).** Five of the six cross-pairing sides were rewritten and shipped; one side kept today's table.
- **Arm 0** is the side's final arm from the re-collection (§11.24-§11.26). On a mixed side it is the mix's highest weight.
- Every side then passed or failed its held-out ship test against today's table (`../ship/README.md`, seeds 601-800).
- Sim build `3ee0d8730831`.

| File | Side | Arm 0 | Alternates (Q -0.05), in order | What chose them | Ship |
|---|---|---|---|---|---|
| `ki-kenpachi.lisp` | KI Kenpachi | `x1/x-ki-k-r1-b0a2` | `x1/x-ki-k-r1-b3a2`, `x1/x-ki-k-r1-b2a2`, `none` | pure arm; alternates by full score 0.284, 0.258 (arm 0 0.437) | **shipped** z +8.81 |
| `ki-ichigo.lisp` | KI Ichigo | `x1/x-ki-i-r1-b0a2` | `x1/x-ki-i-r1-b1a1`, `x1/x-ki-i-r1-b2a0`, `none` | pure arm; 0.912, 0.794 (arm 0 0.964) | **shipped** z +12.10 |
| `kh-kenpachi.lisp` | KH Kenpachi | `x1/x-kh-k-r1-b0a2` | `x1/x-kh-k-r1-b3a2`, `r2/c-ki-k-r2-b1a2`, `none` | pure arm; 0.607, 0.436 (arm 0 0.671) | **shipped** z +19.85 |
| `kh-hisagi.lisp` | KH Hisagi | `x1/x-kh-h-r2-b3a1` | `x1/x-kh-h-r2-b1a1`, `x1/x-kh-h-r1-b3a2`, `none` | pure arm (0.999); 0.671, 0.581 (arm 0 0.695) | **shipped** z +12.78 |
| `ih-ichigo.lisp` | IH Ichigo | `x1/x-ih-i-r1-b2a1` (mix 0.515) | `x1/x-ih-i-r1-b0a2` (0.328), `r2/c-ki-i-r2-b2a2`, `none` | the mix's weights; `ki-ichigo` (0.157) as the raw arm it plays (below) | **shipped** z +3.24 |
| `ih-hisagi.lisp` | IH Hisagi | `ih-r1/c-ih-h-r1-b2a0` (today's) | `a-hisagi-kite`, `ih-r1/c-ih-h-r1-b0a2`, `none` | unchanged: the new table failed bar 3 | **kept** (rejected: `../ship/rejected/ih-hisagi.lisp`) |
| `kk-kenpachi.lisp` | KK | `r2/c-ki-k-r2-b0a2` | `r2/c-ki-k-r2-b1a2`, `none` | unchanged (mirrors are report-only) | — |
| `ii-ichigo.lisp` | II | `r2/c-ki-i-r2-b2a2` | `ih-r1/c-ih-i-r1-b0a1`, `none` | unchanged | — |
| `hh-hisagi.lisp` | HH | `ih-r1/c-ih-h-r1-b2a0` | `a-hisagi-kite`, `a-hisagi-pressd`, `none` | unchanged | — |

Paths are under `../arms/`.

**The full score** used to rank the alternates of a pure side comes from that pairing's matrix (`../pop/<pair>-matrix.json`, block 200,
both seats), not from new runs. It is `eval.py`'s three groups at 1/3 each, over K.O. shares:
- the `none` column;
- the opponent population's mix (`../pop/<pair>-<his letter>.json`);
- every other column, uniformly.

Excluded from the alternates, as on 2026-11-14:
- tables;
- `a-generic` in KH and IH, which ties `none` in every cell there (§11.13).

**The rejected IH Hisagi table** had arm 0 `a-hisagi-kite` (the mix's 0.596), with `x-ih-h-r2-b0a1`, `x-ih-h-r2-b3a1`, `x-ih-h-r2-b1a0`
and `none` as alternates (the weight order).
- It stalls against Ichigo's `none` (47 time-outs of 400), so it failed bar 3.
- By the matrix, `x-ih-h-r2-b0a1` scores higher (0.677 against 0.534) and K.O.s `none` in every match. It was not tested; that is the
  lead's call.

**`ki-ichigo` in IH Ichigo's mix** is the old gaining table, and a table cannot be an arm.
- Its third alternate is the raw arm that table plays outside band `awake`: `r2/c-ki-i-r2-b2a2`.
- This drops the band's arm k (`r3-b3a0-k`). It changes no offline play: an alternate at -0.05 never plays offline.

**Against a single table**, `eval.py --pop` takes a scratch population:

```json
{"pair": "x", "side": "<opponent>", "vs": "x", "anchor": "none",
 "members": [{"id": "none", "file": "none"}, {"id": "<table>", "file": "docs/research/strategy-drsi/sp/final/<table>.lisp"}],
 "mix": {"<table>": 1.0}}
```

With it, group `anchor` is his `none` and groups `mix` and `rest` are the table.

## Mirrors (PLAN2 §2 sufficiency check, sim only, no search; 2026-11-15)

**Candidates** are the character's new cross-pairing arm 0s, the ones briefed for the re-collection:
- Kenpachi: `x-ki-k-r1-b0a2`, `x-kh-k-r1-b0a2`;
- Ichigo: `x-ki-i-r1-b0a2`, `x-ih-i-r1-b2a1`;
- Hisagi: `x-kh-h-r2-b3a1`, `a-hisagi-kite`.

Today's mirror arm 0 played the same set for comparison.

**Method.** One scratch population per opponent arm, `{none, arm}` with mix 1.0. Each arm ran `eval.py --me C --vs C --pop …
--seed0 200` against each.
- `--me` = `--vs` puts the same roster index on both seats.
- Counts are K.O. wins : K.O. losses : time-outs of 200, from the row arm's side.

The pick is the best mean K.O. share against the other candidate and against `none`.

| Arm (row) | vs `none` | vs itself (K.O. rate) | vs cand. 1 | vs cand. 2 | vs today's |
|---|---|---|---|---|---|
| **KK** cand. 1 `x-ki-k-r1-b0a2` | 200:0:0 | 100:100:0 (100 %) | — | 47:153:0 | 193:7:0 |
| KK cand. 2 `x-kh-k-r1-b0a2` (**pick**, mean 0.88) | 200:0:0 | 100:100:0 (100 %) | 153:47:0 | — | 200:0:0 |
| KK today's `c-ki-k-r2-b0a2` | 151:45:4 | 100:100:0 (100 %) | 7:193:0 | 0:200:0 | — |
| **II** cand. 1 `x-ki-i-r1-b0a2` (**pick**, mean 0.88) | 157:0:43 | 5:5:190 (**5 %**) | — | 194:1:5 | 77:9:114 |
| II cand. 2 `x-ih-i-r1-b2a1` | 200:0:0 | 66:66:68 (66 %) | 1:194:5 | — | 1:189:10 |
| II today's `c-ki-i-r2-b2a2` | 181:0:19 | 70:70:60 (70 %) | 9:77:114 | 189:1:10 | — |
| **HH** cand. 1 `x-kh-h-r2-b3a1` (**pick**, mean 0.43) | 142:18:40 | 0:0:200 (**0 %**) | — | 30:0:170 | 188:2:10 |
| HH cand. 2 `a-hisagi-kite` | 98:36:66 | 31:31:138 (31 %) | 0:30:170 | — | 85:73:42 |
| HH today's `c-ih-h-r1-b2a0` | 123:71:6 | 99:99:2 (99 %) | 2:188:10 | 73:85:42 | — |

**Verdict: the mirror tables and their lookup rows stay as they are.** This is reported only.
- **KK:** the pick `x-kh-k-r1-b0a2` K.O.s 100 % in self-play and beats today's arm 200:0:0.
  - Today's `c-ki-k-r2-b0a2` also K.O.s 100 % in self-play, so KK is sufficient either way.
  - It now loses to both new candidates and takes only 151 of 200 off `none`.
- **II:** under 90 % with every arm.
  - The pick `x-ki-i-r1-b0a2` stalls in self-play: 190 of 200 time-outs. Both always take the AS.
  - Today's `c-ki-i-r2-b2a2` reaches 70 %; it was 54 % on 2026-11-14, before the exchange rules.
- **HH:** the picks fail.
  - `x-kh-h-r2-b3a1` never ends a self-play match (0:0:200, 14 draws), and `kite` stalls too (31 %).
  - Today's `c-ih-h-r1-b2a0` still K.O.s 99 % in self-play. Against `none` it is 123:71:6, down from 193:5:2 on 2026-11-14.

## Checks

- **Identity.** `band.py pair --a <table> --b <raw arm 0> --seed0 200` gives b = c = 0 in every group, with the same time-outs, for the
  six new tables (600 matches each, against the side's population file).
  - This includes the rejected IH Hisagi one.
  - It shows that an arm's exchange keys (`:xch-j`, `:clash-*`, `:xch-sa-*` …) are honoured inside an `:fq` table, not only on a raw
    arm.
- **`units.py`** now bootstraps `entry.py` from `hh-hisagi.lisp`, a mirror table whose arms are all units.
  - Before, it used `kh-hisagi.lisp`, whose arm 0 is now an inline arm.
  - It runs on `final/*-*.lisp`: 13 new unit lines, for the `x-*` arms on `:st-ken-kh-standoff`, `:st-ichigo-ki-r2b2a1` and
    `:st-hisagi-hk`.
- **A host test now fails, by design.** `tests/duel-rules/style-knob.lisp` (§11.23 proof 4) asserts that no `sp/final/*.lisp` names an
  exchange key, and that no `*STRAT-UNITS*` entry does either.
  - The five shipped tables do: 3486 checks, 5 failed, one per file.
  - It has to be relaxed when the tables go into the game.

## Commands

Run from `docs/research/strategy-drsi/sp/`.

```sh
X=arms/x1
python3 band.py fallback --me kenpachi --vs ichigo --inc $X/x-ki-k-r1-b0a2.lisp --alt $X/x-ki-k-r1-b3a2.lisp $X/x-ki-k-r1-b2a2.lisp none --out final/ki-kenpachi.lisp
python3 band.py fallback --me ichigo --vs kenpachi --inc $X/x-ki-i-r1-b0a2.lisp --alt $X/x-ki-i-r1-b1a1.lisp $X/x-ki-i-r1-b2a0.lisp none --out final/ki-ichigo.lisp
python3 band.py fallback --me kenpachi --vs hisagi --inc $X/x-kh-k-r1-b0a2.lisp --alt $X/x-kh-k-r1-b3a2.lisp arms/r2/c-ki-k-r2-b1a2.lisp none --out final/kh-kenpachi.lisp
python3 band.py fallback --me hisagi --vs kenpachi --inc $X/x-kh-h-r2-b3a1.lisp --alt $X/x-kh-h-r2-b1a1.lisp $X/x-kh-h-r1-b3a2.lisp none --out final/kh-hisagi.lisp
python3 band.py fallback --me ichigo --vs hisagi --inc $X/x-ih-i-r1-b2a1.lisp --alt $X/x-ih-i-r1-b0a2.lisp arms/r2/c-ki-i-r2-b2a2.lisp none --out final/ih-ichigo.lisp
# rejected at the ship test (bar 3), kept as ship/rejected/ih-hisagi.lisp; final/ih-hisagi.lisp is the 2026-11-14 file:
python3 band.py fallback --me hisagi --vs ichigo --inc arms/a-hisagi-kite.lisp --alt $X/x-ih-h-r2-b0a1.lisp $X/x-ih-h-r2-b3a1.lisp $X/x-ih-h-r2-b1a0.lisp none --out ship/rejected/ih-hisagi.lisp
SP_BUILD=3ee0d8730831 python3 band.py pair --me kenpachi --vs ichigo --a final/ki-kenpachi.lisp --b $X/x-ki-k-r1-b0a2.lisp --seed0 200   # identity, each table
SP_BUILD=3ee0d8730831 python3 eval.py --me hisagi --vs hisagi --cand $X/x-kh-h-r2-b3a1.lisp --pop POP.json --seed0 200   # mirrors: POP.json = {none, arm}
```

The 2026-11-14 commands, and how those tables were chosen, are in this file's git history (commit 8b9a1665).

## Into the game (DUEL_AI_STRATEGY §11.16)

Run from the repo root.

```sh
python3 docs/research/strategy-drsi/sp/final/units.py docs/research/strategy-drsi/sp/final/*-*.lisp   # the arm units *STRAT-UNITS* lacks: paste them in
OUT=/tmp/x sh docs/research/strategy-drsi/sp/final/add.sh      # entry.py + add.py per table: :f-<file> in *STRAT-LIBRARY*, the HARD lookup row
sh docs/research/strategy-drsi/sp/final/proofs.sh              # raw file = the lookup, seeds 601-610 both seats -> proofs-600.jsonl
```
