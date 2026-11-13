# The 3 x 3 baseline under SP (PLAN.md §7 step 2, 2026-11-14)

What the strategy search starts from, scored as it will be scored: **K.O. wins only**. A time-out scores 0 whoever leads; a draw scores 0.

## Conditions

- **Pairings:** Kenpachi, Ichigo, Hisagi, all 9 ordered pairings (the mirrors included).
- **Difficulty and seeds:** HARD, held-out seeds 601-800, 200 matches a pairing. Both seats are covered because KI and IK are separate rows.
- **Build:** the worktree after commit `8f2913f8` (the gate row's `ko` field). The sim build hash is in `baseline.json` (`build`).
- **`none`:** both seats with no strategy at all (`STRAT_P1=none STRAT_P2=none`): the shipped CPU, `BRAIN-STRAT` NIL.
- **`lookup`:** both seats on the shipped HARD `*strat-lookup*` (no `STRAT_` variable). All 9 pairings have an entry:
  - KK `:qks-ken`, KI `:qks3-ichigo`, KH `:qks5-hisagi`
  - IK `:q1-ichigo-ken`, II `:q1-ichigo-ichigo`, IH `:qis-hisagi`
  - HK `:qhs-ken`, HI `:qhs3-ichigo`, HH `:qhs4-mirror`
- **Score:** (K.O. wins + 1) / (matches + 2), per side.
- **What counts as a K.O.:** the gate row's last field `ko 1` (`duel/lisp/gate.lisp`), meaning the match ended before the bell.
  - `ko 0` is the time-out bell. A bind drained to 0 Konpaku at the bell counts as a time-out. It happened 0 times here (`bell_drains`).
  - `run.py` asserts `ko 0` exactly when `secs 300.0`.

## Commands

From the repo root:

```sh
python3 docs/research/strategy-drsi/sp/baseline/run.py -j 6     # -> baseline.json (summary + every match's [seed, secs, winner, ko])
```

`run.py` plays `tools/strategy-switch.py`'s own `run_job` (`tools/simgate/strat-run.lisp`, debug `30600 + 25 i`, `31125`, `81022`, `200000 + 100 c1 + 10 c2`). Its output is cached in `build/strategy-eval-cache/`.

The same score in the tools: `strategy-switch.py` / `strategy-eval.py` / `strategy-matrix.py --ko-only`.

## Results: `none` (both seats with no strategy)

| P1 v P2 | matches | K.O. wins P1 : P2 | time-outs (lead P1 : P2) | draws | median s | score P1 | score P2 |
|---|---|---|---|---|---|---|---|
| KK | 200 | 91 : 108 | 1 (1 : 0) | 0 | 165.6 | 0.455 | 0.540 |
| KI | 200 | 38 : 149 | 13 (1 : 12) | 0 | 219.9 | 0.193 | 0.743 |
| KH | 200 | 172 : 28 | 0 (0 : 0) | 0 | 174.3 | 0.856 | 0.144 |
| IK | 200 | 140 : 37 | 23 (23 : 0) | 0 | 220.8 | 0.698 | 0.188 |
| II | 200 | 92 : 89 | 19 (12 : 7) | 0 | 224.6 | 0.460 | 0.446 |
| IH | 200 | 27 : 159 | 14 (6 : 8) | 0 | 215.8 | 0.139 | 0.792 |
| HK | 200 | 32 : 167 | 1 (0 : 1) | 0 | 181.2 | 0.163 | 0.832 |
| HI | 200 | 138 : 49 | 13 (9 : 4) | 0 | 212.4 | 0.688 | 0.247 |
| HH | 200 | 73 : 58 | 69 (29 : 40) | 0 | 260.8 | 0.366 | 0.292 |

Both seats summed (400 matches a pair):

| pair (A v B) | A K.O. wins | B K.O. wins | time-outs | score A | score B |
|---|---|---|---|---|---|
| K v I | 75 | 289 | 36 | 0.189 | 0.721 |
| K v H | 339 | 60 | 1 | 0.846 | 0.152 |
| I v H | 76 | 297 | 27 | 0.192 | 0.741 |

## Results: `lookup` (both seats on the shipped HARD lookup)

| P1 v P2 | matches | K.O. wins P1 : P2 | time-outs (lead P1 : P2) | draws | median s | score P1 | score P2 |
|---|---|---|---|---|---|---|---|
| KK | 200 | 0 : 0 | 200 (92 : 94) | 14 | 300.0 | 0.005 | 0.005 |
| KI | 200 | 65 : 37 | 98 (46 : 52) | 0 | 292.4 | 0.327 | 0.188 |
| KH | 200 | 0 : 0 | 200 (191 : 9) | 0 | 300.0 | 0.005 | 0.005 |
| IK | 200 | 38 : 78 | 84 (54 : 30) | 0 | 268.4 | 0.193 | 0.391 |
| II | 200 | 1 : 1 | 198 (3 : 7) | 188 | 300.0 | 0.010 | 0.010 |
| IH | 200 | 0 : 0 | 200 (53 : 143) | 4 | 300.0 | 0.005 | 0.005 |
| HK | 200 | 0 : 0 | 200 (9 : 191) | 0 | 300.0 | 0.005 | 0.005 |
| HI | 200 | 0 : 0 | 200 (146 : 53) | 1 | 300.0 | 0.005 | 0.005 |
| HH | 200 | 0 : 0 | 200 (77 : 88) | 35 | 300.0 | 0.005 | 0.005 |

Both seats summed:

| pair (A v B) | A K.O. wins | B K.O. wins | time-outs | score A | score B |
|---|---|---|---|---|---|
| K v I | 143 | 75 | 182 | 0.358 | 0.189 |
| K v H | 0 | 0 | 400 | 0.002 | 0.002 |
| I v H | 0 | 0 | 400 | 0.002 | 0.002 |

## Reading

**Without strategies the matches end.**
- K.O. rates: KK 99.5 %, KH 100 %, HK 99.5 %, and 88.5-93.5 % in the KI / IK / II / IH / HI rows.
- The exception is the Hisagi mirror: 65.5 %, 69 time-outs, median 260.8 s.
- The plain CPUs form a cycle by K.O. score (both seats):
  - Ichigo beats Kenpachi, 0.72 against 0.19.
  - Kenpachi beats Hisagi, 0.85 against 0.15.
  - Hisagi beats Ichigo, 0.74 against 0.19.
- This matches the probe's 17:3 / 18:2 / 18:2 on seeds 601-620.

**The lookup stalls 7 of 9 pairings (6 completely).**
- KK, KH, HK, IH, HI and HH: 200 time-outs of 200, 0 K.O.s. II: 198 time-outs of 200 (188 draws).
- Only Kenpachi and Ichigo's tables against each other still K.O. (KI 102 K.O.s, IK 116). Even there about half the matches go to the bell (98 and 84 time-outs).
- The KI tables turn the plain cycle around: Kenpachi scores 0.36 against Ichigo's 0.19, against 0.19 vs 0.72 without them.

**The old evaluator rewarded this.**
- The time-out leads are lopsided: Kenpachi's `:qks5-hisagi` leads 191 of 200 at the bell as P1 and as P2.
- A time-out-tolerant share would have scored that table 0.955 against Hisagi. Its K.O. score is 0.002.
- This is the evaluator defect PLAN.md §1 names. `--ko-only` closes it.

**The anchor for the search is `none`.** Every lookup cell except KI / IK scores at the floor (0.002-0.010). Candidates for PLAN.md §7 step 4 (emptying the HARD lookup of stalling tables, the user's call): the seven entries KK KH HK IH HI HH II. KI / IK still K.O., but about half their matches reach the bell.
