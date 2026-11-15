# Checkpoint 2c tables: arms5's KH and IH T0s in the lookup (2026-11-16)

The user, 2026-11-16 (DUEL_AI_STRATEGY §11.29 "Checkpoint 2c", DEVLOG §797): 「KH、IH 換新表，HH 保留舊表 (Recommended)」. Both sides of KH
and IH now play arms5's final T0 tables (`t0/t0-kh-kenpachi`, `t0-kh-hisagi`, `t0-ih-ichigo`, `t0-ih-hisagi`) in place of B4's
(`arms4/t0final/`). HH keeps B4's table. Checkpoint 2b did the same for KI / KK / II (commit 66b2aff7). Everything below was measured
with the late-match finish on (`*cai-finish-at*` 0.6, `finish.md`), i.e. the game as shipped.

## 1. What changed

- `duel/lisp/strategy.lisp`, written by `t0/add.sh` (now covers both checkpoints and is idempotent):
  - a new style unit `:st-hisagi-own` (`hisagi-own-style`, `duel/lisp/cpu-hisagi-own.lisp`, from `hisagi.md`) with no `:ken-ranged`.
    His arms carry `:ken-ranged t` as their own key; `h5-tip` does not (`hisagi.md` §3).
  - five arm units: `h5-all`, `h5-cancel`, `h5-wake`, `h5-tip`, `h5-bind` (`sp/final/units.py`). KH Kenpachi's arms already existed
    (`k5-all` = `:c-ki-k-r2-b1a2`, `k5-wake` from 2b), as did IH Ichigo's (`a4-i-all`, `a4-i-brawl`, the `a5-i-*` arms from 2b).
  - `:t0-kh-kenpachi` (2 arms), `:t0-kh-hisagi` (3), `:t0-ih-ichigo` (6), `:t0-ih-hisagi` (4) replaced in place, keeping the same ids and
    lookup rows.
- Saved online copies are reset, because the checksums changed. B4's checksums were KH Kenpachi 575073, KH Hisagi 195522, IH Ichigo 812408
  and IH Hisagi 671538; the new ones are 115409, 722133, 179296 and 579477. HH (101019) and the 2b rows are unchanged.
- Host tests:
  - `tests/duel-rules/strategy.lisp`: the four lookup rows name their arm counts, arm 0, arm 1's job cue and B4's checksum as their
    "before". The cues are wake `(:ost 4)`, cancel `(:xch 1)` with base `(:ost 0)`, answer `(:xch 1)`, and tip `(:form 1 :dm 4.5)`.
  - `tests/duel-rules/style-knob.lisp`: allows the `H5-` prefix, and `:h5-cancel` holds exchange keys (`:xch-j`), as `:a5-i-answer` does.
- `finish/finish.py bar --switch` logs every judgement (STRAT_FQLOG "0 0", as `ladder.py --switch` does) and reports each side's median
  arm changes per match (bar A).

## 2. Proof: raw = lookup (`t0/proofs.sh` -> `t0/proofs-140.jsonl`)

Seeds 141-150, both seats; each raw file played through STRAT_P* against the other side's raw T0, compared line by line with the live
HARD lookup. **8 of 8 rows: 2 chunks identical, 0 differing.** The four 2b rows were rerun. Their line counts moved from 585 / 585 / 516
/ 762 to 616 / 616 / 514 / 786 because the finish changes play, and identity still holds. The new rows have 629 (KH, both seats) and 677
(IH, both seats) lines.

## 3. Bar rows, HARD vs HARD (`finish.py bar --set kh,ih,kh5,ih5 --switch`, sim build bed944b9ab50)

There are 80 matches per row. "Shipped" is the game's lookup with no STRAT_; kh5 / ih5 are the same tables played raw through STRAT_
(finish.md's rows).

| row | block | K.O. | points A | bell A / B ahead | median changes A / B (matches with none) |
|---|---|---|---|---|---|
| kh (Kenpachi v Hisagi) | 141-180 | .975 | .975 | 1 / 1 | 63.5 / 89.5 (0 / 0) |
| ih (Ichigo v Hisagi) | 141-180 | .887 | .075 | 0 / 9 | 99.5 / 60.0 (0 / 0) |
| kh | 501-540 | .988 | .925 | 1 / 0 | 58.5 / 91.0 (0 / 0) |
| ih | 501-540 | .887 | .075 | 1 / 8 | 99.5 / 61.0 (0 / 0) |

- **Shipped = raw, exactly**: on both blocks, kh equals kh5 and ih equals ih5 in every column. They also equal finish.md §4's "after"
  columns (kh5 .975 / .975 and .988 / .925; ih5 .887 / .075 on both blocks), so STRAT_FQLOG leaves play unchanged.
- **Bar A holds**: every side switches, with no match lacking a change. The only earlier change counts are `t0/bar/bar-*.json` (proof.py,
  141-180, before the finish): KH Kenpachi 44 / Hisagi 75 (K.O. .287) and IH Ichigo 97 / Hisagi 57 (K.O. .55). Today's counts are
  higher even though matches are shorter, and the cause was not measured. That is a different build and runner, so it is not a
  like-for-like comparison.
- **Bar D**: KH passes (.975 / .988); IH stays short at .887 on both blocks (9 time-outs of 80, Hisagi ahead in 9 / 8), as finish.md
  found for ih5. The shipped IH's points also move further to Hisagi: Ichigo .338 → .075 on 141-180 and .263 → .075 on 501-540 (finish.md
  §4's shipped rows, B4's tables). No tuning was done (the brief).

## 4. The dev ladder (`sp/ladder.py --seed0 500 --seeds 100`, 200 matches a cell)

"Before" is main 5c8c4599's own sim build, run in a scratch worktree. That build equals the finish's "after" build (no change in duel /
engine / tools since c2c48d34 but the manual), and it reproduces finish.md §5's 15 of 27. "After" is this branch's build (bed944b9ab50).
Each entry is the higher tier's share, with the time-outs in brackets.

**15 → 15 of 27.** Seven cells move by more than one match; the other twenty are within one. Of those, 16 are identical in every column, three keep their share but change
their time-outs (H>N KH 0 → 7, N>E KH 0 → 108, E>M IH 33 → 18), and E>M HK moves by one match.

| rung | cell | before | after | pass |
|---|---|---|---|---|
| H>N | IH | .497 (53) | **.720** (74 FLAG) | fail / fail (Wilson .665) |
| H>N | HK | .460 (27) | **.665** (38) | fail / fail (Wilson .608) |
| N>E | IH | .790 (44) | **.608** (156 FLAG) | **PASS / fail** |
| N>E | HK | .695 (38) | **.790** (45) | **fail / PASS** |
| N>E | HI | .990 (3) | 1.000 (22) | PASS / PASS |
| E>M | KH | .690 (0) | .750 (0) | fail / fail (Wilson .697) |
| E>M | HI | .250 (99) | .290 (178 FLAG) | fail / fail |

- The two H>N cells that failed after the finish both gain about 20 points (IH .497 → .720, HK .460 → .665), but they still fail.
- N>E swaps its failing cell: HK passes again (.790), while IH drops to .608 and fails.
- **The time-outs rise wherever the new KH / IH tables meet**, even where the shares stay the same: N>E KH 0 → 108 (share 1.000 both),
  N>E IH 44 → 156, E>M HI 99 → 178, H>N KH 0 → 7, N>E HI 3 → 22. The lower tiers play the same tables (`*strat-table-chance*` is 1.0 at
  every difficulty, so STRAT-LOOKUP serves HARD's row), One possibility, not measured, is that arms5's Hisagi arms reach a stare like HH's. That is for the lead to check;
  nothing was tuned here.
- Cells away from KH / IH are untouched (KK, KI, IK, II and HH are identical in every rung), as they should be.
## 5. Checks

Host tests 3718 checks ALL PASS. `tools/pkgcheck.sh duel` reports only the old `DUEL::APP` look-alike. `./build.sh duel` then
`git checkout -- vendor`. The smoke run (8 s, heap 74.8 MB) shows no errors. G2 is identical to `tests/style-cvc-ref.txt`, as expected because KH and IH are not G2 pairs: II 40 lines P1 2-0
393.2 s, IK 37 P1 2-0 369.6 s, KK 26 P2 0-5 262.3 s.
