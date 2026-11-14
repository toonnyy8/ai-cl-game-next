# Re-collection ship test (PLAN3 §3 "Shipping", DUEL_AI_STRATEGY §11.27, 2026-11-15)

The held-out test of the six cross-pairing tables that the re-collection wrote (§11.22-§11.26). It ran once a side on seeds 601-800,
`ship.py` (usage below), and the results are lines 3-8 of `results.jsonl`.
- `--table`: the new `../final/<pair>-<side>.lisp` (`band.py fallback` of the side's final arm, `../final/README.md`).
- `--arm0`: **the table shipped today**, `git show HEAD:…/final/<pair>-<side>.lisp` at 8b9a1665. KI Ichigo's is the gaining band table.
- `--opp`: his new table and `none`.
  - Each side was tested against his **new** table, even where that side later failed.
  - IH Ichigo's row is therefore against the rejected `ih-hisagi` (arm 0 `a-hisagi-kite`), not the `c-ih-h-r1-b2a0` table that stays.

**Bars** (PLAN2 §3, PLAN3 §3):
1. Pooled paired z ≥ 1.96 in the new table's favour.
2. The new table's pooled K.O. rate ≥ 90 %. This is reported; KH may miss it.
3. The z against his `none` is not ≤ -1.96.

A side that fails bar 1 or bar 3 keeps today's row.

| Side | New table: arm 0 | Pooled b / c, z | vs his table z | vs `none` z | K.O. rate (t/o of 800) | Verdict |
|---|---|---|---|---|---|---|
| KI Kenpachi | `x-ki-k-r1-b0a2` | 185 / 50, **+8.81** | +5.39 | +7.39 | 98.62 % (11) | **ship** |
| KI Ichigo | `x-ki-i-r1-b0a2` | 182 / 13, **+12.10** | +12.10 | 0.00 | 100 % (0) | **ship** |
| KH Kenpachi | `x-kh-k-r1-b0a2` | 397 / 1, **+19.85** | +14.56 | +13.49 | 97.50 % (20) | **ship** |
| KH Hisagi | `x-kh-h-r2-b3a1` | 175 / 4, **+12.78** | +12.92 | +1.15 | 97.00 % (24) | **ship** |
| IH Ichigo | `x-ih-i-r1-b2a1` | 139 / 90, **+3.24** | +2.08 | +4.15 | 98.75 % (10) | **ship** |
| IH Hisagi | `a-hisagi-kite` | 171 / 85, +5.38 | +8.68 | **-4.99** | 92.87 % (57) | **keep today's** (bar 3) |

- **IH Hisagi fails bar 3.** Against Ichigo's `none`, `kite` gets 350 K.O. wins of 400 with 47 time-outs; today's `c-ih-h-r1-b2a0` gets
  387 with 4. This is the same stall that made the lead pick `b2a0` over `kite` on 2026-11-14.
  - Today's file is restored in `../final/`, so its raw file still equals the lookup.
  - The rejected table is `rejected/ih-hisagi.lisp` (+ `.arms`).
  - Not tested, and left to the lead: by the IH matrix, `x-ih-h-r2-b0a1` (mix 0.352) has the higher full score (0.677 against `kite`'s
    0.534, anchor K.O. share 1.000 against 0.900). Testing it would spend the held-out seeds on that side a second time.
- **KH reaches the 90 % bar on both sides** (97.5 % and 97.0 %). In the HEAD row, Hisagi's `pressd` timed out 248 of 400 against
  Kenpachi's new table.
- **KI Ichigo against `none`** is 400 / 400 for both tables, so bar 3 can only be a tie there.

## The rows

Each table gives K.O. wins / n, K.O. rate, time-outs and score. "HEAD" is the table shipped today.

**KI Kenpachi** (`--opp final/ki-ichigo.lisp none`)

| Opponent | b / c | z | New table | HEAD |
|---|---|---|---|---|
| `ki-ichigo` (new) | 29 / 0 | +5.39 | 29 / 400, 100 %, 0, 0.0746 | 0 / 400, 100 %, 0, 0.0025 |
| `none` | 156 / 50 | +7.39 | 274 / 400, 97.25 %, 11, 0.6841 | 168 / 400, 96.00 %, 16, 0.4204 |
| **Pooled** | 185 / 50 | **+8.81** | 303 / 800, 98.62 %, 11, 0.3791 | 168 / 800, 98.00 %, 16, 0.2107 |

**KI Ichigo** (`--opp final/ki-kenpachi.lisp none`)

| Opponent | b / c | z | New table | HEAD (the band table) |
|---|---|---|---|---|
| `ki-kenpachi` (new) | 182 / 13 | +12.10 | 371 / 400, 100 %, 0, 0.9254 | 202 / 400, 100 %, 0, 0.5050 |
| `none` | 0 / 0 | 0.00 | 400 / 400, 100 %, 0, 0.9975 | 400 / 400, 100 %, 0, 0.9975 |
| **Pooled** | 182 / 13 | **+12.10** | 771 / 800, 100 %, 0, 0.9626 | 602 / 800, 100 %, 0, 0.7519 |

**KH Kenpachi** (`--opp final/kh-hisagi.lisp none`)

| Opponent | b / c | z | New table | HEAD |
|---|---|---|---|---|
| `kh-hisagi` (new) | 212 / 0 | +14.56 | 212 / 400, 95.00 %, 20, 0.5299 | 0 / 400, 100 %, 0, 0.0025 |
| `none` | 185 / 1 | +13.49 | 397 / 400, 100 %, 0, 0.9900 | 213 / 400, 99.75 %, 1, 0.5323 |
| **Pooled** | 397 / 1 | **+19.85** | 609 / 800, 97.50 %, 20, 0.7606 | 213 / 800, 99.88 %, 1, 0.2668 |

**KH Hisagi** (`--opp final/kh-kenpachi.lisp none`)

| Opponent | b / c | z | New table | HEAD |
|---|---|---|---|---|
| `kh-kenpachi` (new) | 167 / 0 | +12.92 | 168 / 400, 95.00 %, 20, 0.4204 | 1 / 400, 38.00 %, 248, 0.0050 |
| `none` | 8 / 4 | +1.15 | 396 / 400, 99.00 %, 4, 0.9876 | 392 / 400, 99.25 %, 3, 0.9776 |
| **Pooled** | 175 / 4 | **+12.78** | 564 / 800, 97.00 %, 24, 0.7045 | 393 / 800, 68.63 %, 251, 0.4913 |

**IH Ichigo** (`--opp final/ih-hisagi.lisp none`, the new Hisagi table since rejected)

| Opponent | b / c | z | New table | HEAD |
|---|---|---|---|---|
| `ih-hisagi` (new, rejected) | 119 / 89 | +2.08 | 199 / 400, 97.50 %, 10, 0.4975 | 169 / 400, 87.25 %, 51, 0.4229 |
| `none` | 20 / 1 | +4.15 | 399 / 400, 100 %, 0, 0.9950 | 380 / 400, 100 %, 0, 0.9478 |
| **Pooled** | 139 / 90 | **+3.24** | 598 / 800, 98.75 %, 10, 0.7469 | 549 / 800, 93.63 %, 51, 0.6858 |

**IH Hisagi** (`--opp final/ih-ichigo.lisp none`), rejected

| Opponent | b / c | z | New table (`kite`) | HEAD (`c-ih-h-r1-b2a0`) |
|---|---|---|---|---|
| `ih-ichigo` (new) | 162 / 39 | +8.68 | 191 / 400, 97.50 %, 10, 0.4776 | 68 / 400, 99.75 %, 1, 0.1716 |
| `none` | 9 / 46 | **-4.99** | 350 / 400, 88.25 %, 47, 0.8731 | 387 / 400, 99.00 %, 4, 0.9652 |
| **Pooled** | 171 / 85 | +5.38 | 541 / 800, 92.87 %, 57, 0.6758 | 455 / 800, 99.38 %, 5, 0.5686 |

## Build and commands

**Sim build `3ee0d8730831`** (this checkout's `duel.fas`, sources at 8b9a1665). `SP_BUILD` was set to it for every `eval.py` /
`band.py` call. The round itself ran on 949a94db54fe.
- **Reproduction:** `eval.py --me hisagi --vs kenpachi --cand ../arms/x1/x-kh-h-r2-b3a1.lisp --seed0 300` matches the cell's recorded
  row exactly (`../arms/x1/x-kh-h-r2-b3a1.md`, §11.26): score 0.7359; anchor 200:0:0, mix 95:96:9, rest 148:7:45.
- **Identity** (before the ship runs): `band.py pair --a final/<new>.lisp --b <raw arm 0> --seed0 200` gives b = c = 0 and the same
  time-outs in every group for all six new tables. This also shows that the exchange keys of an arm inside an `:fq` table are honoured.

`ship.py` prints its line and does not append it. The lines in `results.jsonl` replace the scratch `arm0` path with
`HEAD(8b9a1665):final/<side>.lisp` and add `plan` and `verdict`.

Run from `docs/research/strategy-drsi/sp/`; `H/` holds the HEAD copies (`git show HEAD:…`).

```sh
for t in "kenpachi ichigo ki-kenpachi ki-ichigo" "ichigo kenpachi ki-ichigo ki-kenpachi" "kenpachi hisagi kh-kenpachi kh-hisagi" \
         "hisagi kenpachi kh-hisagi kh-kenpachi" "ichigo hisagi ih-ichigo ih-hisagi" "hisagi ichigo ih-hisagi ih-ichigo"; do
  set -- ${=t}; python3 ship.py --me $1 --vs $2 --table final/$3.lisp --arm0 H/$3.lisp --opp final/$4.lisp none -j 6
done
```

---

# KI ship test (PLAN2 §3, §5 checkpoint A, 2026-11-14)

The held-out test of each side's final table, on seeds 601-800. It runs once a side, after KI round 3's admission
(`../arms/r3/c-ki-i-r3-awake.md`, `.admission.json`).

**Verdict per side:**

| Side | Final table | Verdict |
|---|---|---|
| Ichigo | `../final/ki-ichigo.lisp`: arm 0 `r2-b2a2` everywhere, arm k `r3-b3a0-k` in band `awake` | **gaining table**: passes all three bars |
| Kenpachi | `../final/ki-kenpachi.lisp`: arm 0 `r2-b1a2` everywhere; `r1-b2a2`, `pilot-b0a0` and `none` at -0.05 | **fallback**: a fuzzy Q table in format only; it plays `r2-b1a2` |

No Lisp changed and `*strat-lookup*` is untouched. Shipping the tables is PLAN2 §5 step 5.

## `ship.py`

```sh
python3 ship.py --me C --vs D --table FILE --arm0 FILE --opp FILE|none [FILE|none ...] [-j 6]
```

- It is the only tool that plays seeds 601-800. The seeds are fixed (there is no `--seed0`), and `eval.py` and `band.py pair` still refuse
  that range.
- It plays the table and its arm 0 on the same seeds, both seats, 200 seeds a seat: 400 matches per opponent and candidate. It uses HARD
  and `eval.py`'s `mine` / `jobs` / `play` (the same sim path and cache).
- Each opponent is one strategy (a file, or `none`: his shipped CPU), not a population.
- **Paired statistic** (`band.paired`, shared with `band.py pair`): b = the table won by K.O. and arm 0 did not, c = the reverse,
  z = (b - c) / sqrt(b + c). **A positive z favours the table.** `band.py pair` and the admission files put arm 0 first, so their sign
  is the opposite.
- Per candidate: K.O. wins, K.O. rate = (K.O. wins + K.O. losses) / n, time-outs, score = (K.O. wins + 1) / (n + 2). These are given per
  opponent and pooled over the opponents.

**Bars** (PLAN2 §3):
1. Pooled paired z ≥ 1.96.
2. The table's pooled K.O. rate ≥ 90 %.
3. Not losing to his anchor: the paired z against `none` is not ≤ -1.96.

## Ichigo: the gaining table

Opponents: Kenpachi's final table (it plays `r2-b1a2`, see below) and his `none`.

| Opponent | b / c | z | Table: K.O. wins, K.O. rate, t/o, score | Arm 0: K.O. wins, K.O. rate, t/o, score |
|---|---|---|---|---|
| `ki-kenpachi` (final) | 79 / 46 | **+2.95** | 332 / 400, 100 %, 0, 0.8284 | 299 / 400, 100 %, 0, 0.7463 |
| `none` (anchor) | 1 / 4 | -1.34 | 396 / 400, 99.75 %, 1, 0.9876 | 399 / 400, 100 %, 0, 0.9950 |
| **Pooled** | 80 / 50 | **+2.63** | 728 / 800, 99.88 %, 1, 0.9090 | 698 / 800, 100 %, 0, 0.8716 |

- **Bar 1:** z +2.63 ≥ 1.96. Pass.
- **Bar 2:** K.O. rate 99.88 % ≥ 90 %. Pass.
- **Bar 3:** the anchor row is z -1.34, above -1.96. Pass.
  - It still leans toward arm 0: 3 K.O. wins fewer, and one time-out.
  - The anchor is near the ceiling for both (≥ 396 of 400), so it can't show a gain, only a loss. This one is within noise.
- The gain is the admission's again: the mix row there (his `r2-b1a2`) was 70 / 43, and here it is 79 / 46, on fresh seeds.

**Her q (PLAN2 §3: the measured paired gain).**
- The admitted table `../arms/r3/c-ki-i-r3-awake.lisp` was written with q 0.05.
- The shipped file carries the admission's measured gain instead: (c - b) / n = (85 - 52) / 1200 = **0.0275** (K.O. share, seeds 801-1000).
- It is regenerated by `band.py write --q 0.0275`. A text diff against the admitted file differs only in G1's q column, the `:id` and the
  comment line.
- **Offline play is the same for any q above `:margin` (0.02).**
  - G1 is form (crisp) x distance (fuzzy).
  - Every distance rule of a form row carries the same q, so the group's average is exactly ±q, and the other groups add 0.
- Proof: `sw.py measure` against `r2-b1a2`, seeds 501-600, both seats. `../fit/same.py ship-i-final ship-i-r3` gives 200 gate rows and
  4,200 hash lines, **identical**. Both play arm k on 0.398 of judgements.
- **q's size matters only to `fq-online.lisp`** (against a human):
  - The TD update moves only the played arm's q, each q within its offline value ± `*fq-online-cap*` (0.01).
  - Arm k's band q can fall to 0.0175, below the margin. A table that enters the band on arm 0 then stays on arm 0, so a human's results
    can switch the band off.
  - At 0.05 they could not do that within the cap from G1 alone.
  - This follows PLAN2 §3 as written. If the band should stay on against every human, write q 0.05 (same offline play).

## Kenpachi: the fallback

No band was admitted for him (round 3: no candidate survived block 200). So PLAN2 §3's fallback applies: his best pure arm, written as a
table.

**The table** (`band.py fallback`, `sw.write_table`):
- `:rb-sp`, `:xfeats t`, `:keep-state t`, `:margin 0.02`, `:period 30`.
- Arm 0 `../arms/r2/c-ki-k-r2-b1a2.lisp` is 0 in every rule.
- The alternates sit at -0.05 in every G0 rule, as `sw.py start` places its -1e-3. Because Q is the sum of the group averages, each
  alternate's Q is exactly -0.05 in every state.
- **Alternates** (by the KI matrix, `../pop/ki-matrix.json`, seeds 201-300):
  1. `r1-b2a2`: the only other member with a K.O. share against Ichigo's equilibrium (her pure `r2-b2a2`): 0.165, against arm 0's 0.28.
  2. `pilot-b0a0`: every other member scores 0 there, so the next is the best by row mean over her five columns (0.46).
  3. `none`, last.
- **Online, it leaves arm 0 only at the cap's extreme, and only through `none`.**
  - `fq-online.lisp` updates only the played arm's q, each within its offline value ± `*fq-online-cap*` (0.01). So an unplayed
    alternate's Q stays at -0.05, and arm 0's Q can fall to -0.05 at worst (0.01 a group, five groups).
  - Between `r1-b2a2` / `pilot-b0a0` and arm 0: the best they reach is a tie, which is under `:margin`, so arm 0 is kept. They never play.
  - `none` is different because of `:prev`. `strategy-glue.lisp` sets `:prev` to the position of the current sub in `:arms`, and before the
    first judgement the sub is NIL. That is the `none` arm's own entry, so `:prev` reads 3.
    - So on a match's first judgement `none` is kept while Q(arm 0) - Q(none) < 0.02, i.e. once a human's results have pushed arm 0's Q
      below -0.03. That needs arm 0's q near -0.01 in four or more groups.
    - From then on `none` plays and its own q learns, until arm 0 leads it by the margin again.
  - Offline (no learning) arm 0 always plays, as the proofs below show.
  - It is a fuzzy Q table in format only, and is **never counted as a gaining table**.

**Identity proof:** `sw.py measure` against Ichigo's `r2-b2a2`, seeds 501-600, both seats.
- `../fit/same.py ship-k-final ship-k-raw` gives 200 gate rows and 4,236 hash lines, **identical**.
- Arm share 1.0 / 0 / 0 / 0, 0 changes a match.

**Held-out rows** (`ship.py`, the table against its own arm 0; no gain verdict):

| Opponent | b / c | Table: K.O. wins, K.O. rate, t/o, score | Arm 0 (raw) |
|---|---|---|---|
| `ki-ichigo` (her final) | 0 / 0 | 68 / 400, 100 %, 0, 0.1716 | the same |
| `none` (her anchor) | 0 / 0 | 370 / 400, 100 %, 0, 0.9229 | the same |
| **Pooled** | 0 / 0 | 438 / 800, 100 %, 0, 0.5474 | the same |

- b = c = 0 in every row: a second identity check, on the held-out seeds, against two other opponents.
- His K.O. rate is 100 %. Against her final table he wins 17 % of matches, and against her `none` 92.5 %.

## Commands

Run from `docs/research/strategy-drsi/sp/`.
- Logs go to `../fq/switch/logs/spfit/band/` (gitignored), and the matches are cached in `build/strategy-eval-cache/`.
- The ship runs took about 36 s each at `-j 6`.

```sh
A=arms
python3 band.py fallback --me kenpachi --vs ichigo --inc $A/r2/c-ki-k-r2-b1a2.lisp \
    --alt $A/r1/c-ki-k-r1-b2a2.lisp $A/pilot/c-ki-k-pilot-b0a0.lisp none --out final/ki-kenpachi.lisp
python3 band.py write --me ichigo --vs kenpachi --inc $A/r2/c-ki-i-r2-b2a2.lisp --var $A/r3/c-ki-i-r3-awake-armk.lisp \
    --band awake --q 0.0275 --out final/ki-ichigo.lisp
R=band/run.sh                                                   # identity proofs, 501-600
$R measure k arms/r2/c-ki-k-r2-b1a2.lisp ship-k-raw 501-600; $R measure k final/ki-kenpachi.lisp ship-k-final 501-600
$R same ship-k-final ship-k-raw                                 # -> identical
$R measure i arms/r3/c-ki-i-r3-awake.lisp ship-i-r3 501-600;  $R measure i final/ki-ichigo.lisp ship-i-final 501-600
$R same ship-i-final ship-i-r3                                  # -> identical
python3 ship.py --me ichigo --vs kenpachi --table final/ki-ichigo.lisp --arm0 $A/r2/c-ki-i-r2-b2a2.lisp \
    --opp final/ki-kenpachi.lisp none                           # -> results.jsonl line 1
python3 ship.py --me kenpachi --vs ichigo --table final/ki-kenpachi.lisp --arm0 $A/r2/c-ki-k-r2-b1a2.lisp \
    --opp final/ki-ichigo.lisp none                             # -> results.jsonl line 2
```

**Sim build** `52247a56fb1c` on every row. It is the hash of `duel.fas`, which differs per checkout; the admission was recorded as
`db03158483a4`, built from the same sources (commit e5c19169).
- This build reproduces the admission exactly: `band.py pair` on 801-1000 gives b 52 / c 85, z -2.82, time-outs 1 / 1.
- That run also checks that `band.paired` (factored out of `band.py pair` for `ship.py`) counts as before.
