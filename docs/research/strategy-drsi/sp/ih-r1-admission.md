# IH round 1: admission (Ichigo vs Hisagi, 2026-11-14)

The KI admission rule (DUEL_AI_STRATEGY §11.7-§11.8), applied after IH round 1 (workspaces `ih-I`, `ih-H`), with PLAN2 §2's
stalling check. HARD, `eval.py` / `pop.py` as in README.md. Arms copied to `arms/ih-r1/` (`c-ih-<side>-r1-<node>.lisp` + the cell's
proposal as `.md`), including the non-admitted ones as records.

## Build

This worktree's `build/simgate/duel.fas` hashes to `95b02590`, not the round's `SP_BUILD` `5aac2ad2` (the hash is the compiled file's
bytes, which differ per checkout; same commit `b01a03d0`). Same sim: both initial programs reproduce their round scores exactly on block
300 (Ichigo `arms/r1/c-ki-i-r1-b0a2.lisp` 0.8993, Hisagi `arms/h1-range.lisp` 0.3647), and every candidate's block-300 score equals its
trace score. The matrix JSON records `95b02590`.

## Rescore (eval.py, three opponent groups, 600 matches a block, against the round's population files)

| arm | node | block 300 | block 200 | block 400 | time-outs 300 / 200 / 400 | holds |
|---|---|---|---|---|---|---|
| Ichigo `c-ih-i-r1-b0a1` | b0_a1 | 0.9917 | 0.9917 | 0.9917 | 2 / 1 / 2 | yes |
| Ichigo `c-ih-i-r1-b1a1` | b1_a1 | 0.9769 | 0.9752 | 0.9868 | 5 / 3 / 1 | yes |
| Ichigo `c-ih-i-r1-b3a0` | b3_a0 | 0.9373 | 0.9208 | 0.9109 | 33 / 43 / 49 | yes |
| Hisagi `c-ih-h-r1-b0a2` | b0_a2 | 0.7129 | 0.6683 | 0.6898 | 15 / 23 / 23 | borderline (200: -0.0446) |
| Hisagi `c-ih-h-r1-b2a2` | b2_a2 | 0.5281 | 0.5379 | 0.5165 | 43 / 56 / 38 | yes |
| Hisagi `c-ih-h-r1-b3a2` | b3_a2 | 0.5016 | 0.5049 | 0.4852 | 12 / 17 / 11 | yes |
| Hisagi `c-ih-h-r1-b2a0` | b2_a0 | 0.4851 | 0.4950 | 0.4769 | 24 / 29 / 30 | yes |

All seven went into the matrix. Hisagi `b0a2` is 0.0446 below its block-300 score on block 200 (about the "~0.04" limit, within two
standard errors of a difference) and 0.023 on block 400; it stays Hisagi's best arm on every block by 0.13 or more, so it was kept as a
candidate and the matrix decided.

## Matrix (`pop.py matrix --a ichigo --b hisagi --seed0 200 --seeds 100`, 200 matches a cell, both seats)

Cell = Ichigo's K.O. share / Hisagi's K.O. share (the rest went to the bell). Candidate matrix (16 x 10), before the drop:

| Ichigo \ Hisagi | none | a-generic | a-hisagi-kite | h1-range | a-zoner | s7-kite | h-r1-b0a2 | h-r1-b2a2 | h-r1-b3a2 | h-r1-b2a0 |
|---|---|---|---|---|---|---|---|---|---|---|
| none | .170/.775 | .170/.775 | .000/.835 | .180/.800 | .015/.860 | .000/.855 | .005/.945 | .000/.990 | .145/.840 | .005/.990 |
| a-generic | .170/.775 | .170/.775 | .000/.835 | .180/.800 | .015/.860 | .000/.855 | .005/.945 | .000/.990 | .145/.840 | .005/.990 |
| a-ichigo-ki | .890/.075 | .890/.075 | .260/.090 | .905/.085 | .710/.100 | .270/.000 | .735/.200 | .605/.155 | .540/.400 | .695/.160 |
| a-ichigo-press | .920/.045 | .920/.045 | .245/.050 | .965/.025 | .785/.045 | .390/.000 | .795/.145 | .685/.155 | .605/.365 | .735/.155 |
| a-ichigo-kite | .845/.070 | .845/.070 | .130/.150 | .870/.105 | .515/.085 | .170/.000 | .705/.195 | .575/.150 | .495/.480 | .580/.205 |
| a-ichigo-zoner | .815/.110 | .815/.110 | .190/.110 | .915/.070 | .625/.100 | .205/.000 | .715/.220 | .595/.230 | .490/.460 | .590/.225 |
| c-ki-i-r1-b0a2 | .970/.030 | .970/.030 | .520/.015 | .995/.005 | .925/.000 | .575/.000 | .385/.610 | .655/.290 | .880/.095 | .830/.155 |
| c-ki-i-r1-b2a2 | .885/.085 | .885/.085 | .230/.040 | .880/.090 | .765/.060 | .275/.000 | .630/.305 | .660/.165 | .545/.395 | .785/.105 |
| c-ki-i-r1-b3a2 | .720/.140 | .720/.140 | .355/.050 | .610/.345 | .400/.125 | .100/.000 | .190/.715 | .295/.345 | .190/.730 | .345/.450 |
| c-ki-i-r2-b1a2 | .555/.335 | .555/.335 | .295/.085 | .525/.445 | .350/.150 | .115/.020 | .130/.835 | .400/.455 | .200/.720 | .420/.465 |
| c-ki-i-r2-b2a2 | .775/.145 | .775/.145 | .770/.080 | .715/.230 | .585/.215 | .545/.080 | .220/.705 | .310/.390 | .275/.725 | .475/.355 |
| c-ki-i-r2-b3a2 | .600/.265 | .600/.265 | .610/.110 | .680/.265 | .340/.325 | .165/.105 | .490/.460 | .550/.315 | .155/.825 | .455/.450 |
| ki-ichigo | .775/.135 | .775/.135 | .765/.065 | .755/.195 | .655/.210 | .570/.090 | .260/.685 | .385/.375 | .160/.830 | .435/.400 |
| **i-r1-b0a1** | 1.000/.000 | 1.000/.000 | .930/.035 | 1.000/.000 | .995/.005 | 1.000/.000 | 1.000/.000 | 1.000/.000 | 1.000/.000 | 1.000/.000 |
| **i-r1-b1a1** | .985/.015 | .985/.015 | .965/.020 | .990/.005 | .990/.010 | .945/.000 | .820/.165 | .855/.140 | .990/.010 | .970/.030 |
| i-r1-b3a0 | .990/.005 | .990/.005 | .490/.015 | 1.000/.000 | .950/.005 | .550/.000 | .600/.395 | .800/.165 | .965/.030 | .890/.110 |

Equilibrium (regret matching, own K.O. share): Ichigo `i-r1-b0a1` 0.812 + `i-r1-b1a1` 0.188 (value 0.9414); Hisagi `a-hisagi-kite`
0.834 + `h-r1-b0a2` 0.166 (value 0.032); gaps 0.0002.

## Admission

- **Admitted**: Ichigo `c-ih-i-r1-b0a1`, `c-ih-i-r1-b1a1`; Hisagi `c-ih-h-r1-b0a2` (all in the equilibrium mix).
- **Not admitted** (no weight, and no best response to an equilibrium column: against `i-r1-b0a1` Hisagi's best is `a-hisagi-kite`
  0.035, against `i-r1-b1a1` `h-r1-b0a2` 0.165; against `h-r1-b0a2` Ichigo's best is `i-r1-b0a1` 1.000): Ichigo `c-ih-i-r1-b3a0`;
  Hisagi `c-ih-h-r1-b2a2`, `c-ih-h-r1-b3a2`, `c-ih-h-r1-b2a0`. Records in `arms/ih-r1/`.
- **Flag for the lead**: Hisagi `h-r1-b3a2` is his best response to Ichigo's KI-style arms with zero weight here (`c-ki-i-r1-b3a2`,
  `c-ki-i-r2-b2a2`, `c-ki-i-r2-b3a2`, `ki-ichigo`: 0.73-0.83 K.O. share), the only Hisagi arm that wins those. Not admitted under
  the rule; a round-2 band might want it.
- **Stalling check** (PLAN2 §2: no more mix-group time-outs than the parent, block 300, the round's population files): Ichigo
  `b0a1` 0 vs parent `b0_a0` 0; `b1a1` 0 vs parent `b1_a0` 0; Hisagi `b0a2` 1 vs parent `b0_a1` 1 (the root `h1-range` 0). All pass.

## After admission (matrix rerun on the 15 x 7 populations; every cell identical, from the cache)

- **Ichigo** mix: `c-ih-i-r1-b0a1` 0.808 + `c-ih-i-r1-b1a1` 0.192, value 0.9413.
- **Hisagi** mix: `a-hisagi-kite` 0.839 + `c-ih-h-r1-b0a2` 0.161, value 0.0321. (Gaps 0.0003 / 0.0001.)
- **K.O. rates of the admitted arms** across their matrix row / column (block 200): Ichigo `b0a1` 0.995 (7 of 1,400 to the bell, all
  against `a-hisagi-kite`); `b1a1` 0.987 (18 of 1,400: `s7-kite` 11, `a-hisagi-kite` 3, `h-r1-b0a2` 3, `h1-range` 1); Hisagi `b0a2`
  0.948 (157 of 3,000; at most 20 a cell, against `a-ichigo-kite`; 0 against `i-r1-b0a1`, 3 against `i-r1-b1a1`).

## Notes

- IH is at Ichigo's ceiling: `i-r1-b0a1` K.O.s every Hisagi arm 93-100 % of the time and never loses but to `a-hisagi-kite` (7 of
  200). Hisagi's 0.84 weight on `a-hisagi-kite` rests on those 7 K.O.s (0.035 against 0.000 for the others); a round-2 Hisagi search
  is scored against this mix.
- Hisagi `h-r1-b0a2` is the strongest Hisagi arm against every older Ichigo arm but scores 0.000 against `i-r1-b0a1`: the round's
  Hisagi gain (0.365 → 0.71 on block 300) was measured against the pre-round Ichigo population.
