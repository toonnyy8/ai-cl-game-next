# arms6 / HH: a Hisagi mirror table decided by K.O.s (batch p9-hh, 2026-11-17)

The lead's brief (p9 table batches, after DUEL_AI_STRATEGY §11.31): with B4's table (`:t0-hh-hisagi`, arms `:a-hk-pot :h4-range :h4-wake`)
HARD vs HARD reached the bell in all 80 bar D matches, and the lifted tier worlds sent 165-199 of 200 HH matches to the bell
(`diag/tier-r2.md` §6 block C). Target: bar D HH K.O. >= .60, H>N HH (.960) and N>E HH (.915) still passing, E>M HH (.325) reported.
Levers: the HH row's table only (its arms, job map, no exchange unit: a mirror). KH and IH tables untouched.

Build: main 717dc4c9 = sim `2d4bd5f5c371` for every probe; the shipped table = sim `6d72d8005f58` (only the HH entry differs). Seeds 141-180
(bar D) and 501-600 (dev ladder) only. The finish on, as shipped. Files: `arms6/hh/` (arms, maps, tables, tools).

## 1. Diagnosis

**Not a stare on today's build.** finish.md's "stare at 9-9 from the first exchange" was measured before the clash and perception changes.
`finish.py onset --row hh` on main: 80 time-outs, the last move start a median 0.7 s before the bell, no quiet stretch over 30 s; the
trailing side still at 3-8 of 9 Konpaku. The mirror is active and does almost no damage.

**Where the time goes** (`arms6/hh/phase.py`: the diag runner over the whole clock, Konpaku lost per form, both sides pooled; bar D block):

| table | K.O. | Shikai side-s / s per Konpaku | ranged Bankai | bind mode |
|---|---|---|---|---|
| shipped B4 | .000 | 61 850 / 264 | 9 116 / 217 | 846 / - |
| generic CPU + MCTS whole | .875 | 18 125 / 63 | 19 440 / 53 | 15 807 / 35 |
| t1 (generic, h5-all in the Shikai) | .650 | 19 022 / **500** | 21 703 / 52 | 20 317 / 39 |

- B4's arm 0 `a-hk-pot` is `hisagi-hk-style`, which in the Shikai and the bind mode plays Kenpachi's brawler (`ken-ki-style`, through
  `hisagi-merged-style`): two of them trade at 1.4-4.8 m and land a Konpaku every ~4 minutes. `a-hk-pot` played whole is the same: K.O. 0.
- Hisagi's own Shikai band (`h5-all`, arms5) against itself: both hold 3.4-4.2 m and wait for the other to walk in (NAGI fires only on
  his walk-in); the opener on the think timer lands rarely: 500 s a Konpaku. Played whole (its Bankai forms fall to `ken-ki-style`): .175.
- The generic CPU (no style, the MCTS on HARD's neutral) K.O.s the mirror .875 (.775 on 501-540); `c-ih-h-r1-b2a0` (the range style
  in the ranged mode, the generic CPU elsewhere) .850.
- So the stall is the borrowed brawler and the band facing themselves, not a rule: a table whose arm 0 is the generic CPU fights.

**The masher rung pulls the other way.** EASY's generic CPU loses to the masher (whole: E>M .140, the masher K.O.s 172 of 200). What
beats the masher is Hisagi's own style in the ranged Bankai (`h5-all` there: the range style with its default keys, `ken-ki-style` when it
declines): EASY's Konpaku pace against the masher in the ranged mode is 53 s dealt / 42 s lost under B4 vs 69 / 40 under `c-ih`.
No rule-base cue tells the masher from a HARD Hisagi (it awakens, attacks and closes too), so the arm that lifts E>M costs the
mirror's K.O.s; the job maps below trace that trade.

## 2. Tables measured (all against themselves; bar D = HARD vs HARD; the ladder's HH cells on 501-600, 200 a cell)

Bar D note: in a mirror the two seat jobs of `finish.py bar` are the same matches (same characters, same table, same seeds), so its 80 rows
are 40 distinct matches counted twice (standard error ~.07); hence the second block and the H>H parity row (100 distinct matches).

| table | arms and jobs (`:rb-sp2`, q .06) | bar D 141-180 | 501-540 | H>N | N>E | E>M | changes a match (median) |
|---|---|---|---|---|---|---|---|
| shipped (B4) | a-hk-pot; h4-range form 1 mid/far; h4-wake his down | **.000** | | .960 | .915 | .325 | 28 |
| a-hk-pot whole | | .000 | | | | | |
| h5-all whole | | .175 | | .980 | .860 | .580 | |
| c-ih-h-r1-b2a0 whole | | .850 | | .995 | .955 | .200 | |
| generic whole | | .875 | .775 | .990 | .900 | .140 | |
| hh5 (arms5's t0-hh-hisagi) | h5-all, h5-cancel, h5-wake | .000 | | | | | |
| t1 | generic; h5-all in the Shikai | .650 | .650 (.725 on 541-580) | .995 | .915 | .060 | 1 |
| t2 | t1 + h4-range form 1 mid/far | .175 | | .995 | .870 | .025 | 21.5 |
| t3 | h5-all; generic while behind (G8) | .325 | | .980 | .900 | .125 | 2 |
| t4 | h5-all; generic in the bind mode | .425 | | 1.000 | .920 | .500 | 2.5 |
| t5 | h5-all; generic in the bind mode and form 1 mid/far | .550 | | .985 | .935 | .255 | 11 |
| t6 | h5-all; generic in the bind mode and form 1 close | .525 | | .980 | .930 | .395 | 15 |
| t7 | generic; h5-all in the Shikai far | .875 | | .990 | .935 | .070 | 11 |
| t8 | generic; c-ih in form 1 | .925 | | .995 | .905 | .170 | 2 |
| t9 | generic; h5-wake while he is down | .675 | | .990 | .960 | .285 | 82 |
| **t10** | generic; h5-all Shikai far; c-ih form 1 | **.900** | **.850** | 1.000 | .900 | .140 | 14 |
| t11 | t10 + h5-cancel while an exchange is open | .675 | .725 | .995 | .940 | .140 | 48 |
| t12 | t10, c-ih form 1 mid/far, h4-range form 1 close | .875 | | .995 | .920 | .090 | 29.5 |
| t13 | t12 + h5-all Shikai close | .725 | | .995 | .925 | .080 | 57 |
| t14 | generic; h5-all Shikai far and form 1 mid/far | .575 | .525 | .990 | .975 | .515 | 29 |
| t15 | generic; h5-all Shikai far and form 1 | .600 | .625 | 1.000 | .940 | .580 | 15 |
| t16 | generic; h5-all in form 1 | .725 | .775 | .990 | .915 | .530 | 4 |
| t18 | generic; form 1: h5-all ahead / even, c-ih behind (G8) | .925 | | .990 | .905 | .210 | 3 |
| t19 | generic; form 1: h5-all mid/far, c-ih close | .550 | .525 | .990 | .935 | .380 | 21 |
| **t21 (shipped)** | generic; form 1: h5-all while he attacks (G2 atk), c-ih otherwise | **.750** | **.775** | **1.000** | **.950** | **.470** | 36 / 30 |

(form 1 = the Bankai's ranged mode, `:form :yes`; the bind mode is `:k2`; "Shikai far" = `(:form :no) (:dm :m-far)`. t18 / t21 are
written by `arms6/hh/mk.py`, per-rule values: the arm at +.06 in form 1, -.12 in the other forms, +-.03 by the second group's cue; the rest
by `band.py t0`.)

Reading:
- Every arm that plays the band or the brawler in the Shikai or the bind mode slows the mirror (t1-t6, t13, t14); the generic CPU there is
  what K.O.s. h4-range in the ranged mode brings the stall back (t2: two kiters).
- In the ranged mode the choice is the trade: `c-ih` K.O.s the mirror (t8 .925, t10 .900 / .850) and loses EASY to the masher (.14-.17);
  `h5-all` keeps E>M at .53 (t16) and K.O.s .725 / .775. Splitting it by the lead (t18) gives the masher the trailing EASY (E>M .21); by
  distance (t19) slows the mirror. By his state (t21): `h5-all` while he attacks, `c-ih` while he is free / evading / down, keeps most of
  both and switches ~33 times a match.
- Dropped jobs: h5-cancel on an open exchange (t11: -.2 K.O.), h5-wake while he is down (t9: -.2), h4-range anywhere.

## 3. The shipped table: t21 as `:t0-hh-hisagi` (`arms6/hh/add.sh`, replaced in place)

- Arms: `:a-generic` (arm 0: the generic CPU + MCTS, 0 everywhere), `:h5-all` (Hisagi's own style, arms5: +.06 in form 1, -.12 in the
  Shikai and the bind mode, +.03 in G2 "he attacks", -.03 in G2's other rows), `:c-ih-h-r1-b2a0` (+.06 in form 1, -.12 elsewhere in G1,
  -.03 in G2 "he attacks", +.03 in G2's other rows). In the Shikai and the bind mode the generic CPU plays; in the ranged mode h5-all or
  c-ih by his state. `:rb-sp2`, `:keep-state`, `:margin 0.02`, `:period 30`, no `:with` (mirrors hold none). All three arms are existing units.
- Raw = lookup: bar D with no `STRAT_P*` reproduces the raw file exactly on both blocks (141-180: .750, mean 256.5 s, 36 changes;
  501-540: .775, 255.5 s, 30), and across the tiers the raw t21 ladder rows (H>N 200 : 0, N>E 190 : 10, E>M 94 : 106) equal the full
  ladder's lookup rows, so the lookup's `:a-generic` (entry.py drops the raw arm's `:p 1.0`) plays the same at every difficulty.
- Host test (`tests/duel-rules/strategy.lisp`, the T0 rows): the HH row now names arm 0 `a-generic`, its job cue (form 1, he attacks) and
  B4's checksum 101019 as its "before" (a player's online copy saved from B4's table loads fresh).

**HH cells, before (main 717dc4c9) -> after (`arms6/hh/lad.py`, seeds 501-600, both seats, 200 a cell):**

| cell | share | K.O. rate | K.O.s higher : lower | bell, the higher tier's : the lower's |
|---|---|---|---|---|
| H>N HH | .960 -> **1.000** (PASS) | .165 -> .980 | 33 : 0 -> 196 : 0 | 167 (159 : 8) -> 4 (4 : 0) |
| N>E HH | .915 -> **.950** (PASS) | .665 -> .905 | 128 : 5 -> 175 : 6 | 67 (55 : 12) -> 19 (15 : 4) |
| E>M HH | .325 -> **.470** (fail) | .590 -> .685 | 41 : 77 -> 68 : 69 | 82 (24 : 58) -> 63 (26 : 37) |
| N>N HH (parity) | .500 | .020 -> .920 | | 196 -> 16 |
| H>H HH (parity) | .500 | .000 -> .820 | | 200 -> 36 |

- Bar D (HARD vs HARD, 141-180): K.O. **.000 -> .750** (40 distinct matches; 501-540: .775), mean 300.0 -> 256.5 s; 20 of the 80 rows
  at the bell = 10 distinct time-outs (each shows once as "A ahead" and once as "B ahead"). The higher tier now wins its HH cells by K.O.
  (H>N 196 of 200, N>E 175), not at the bell.
- **Second block** (t21 was picked on 501-600 among ~25 tables; `lad.py --seed0 140 --seeds 40`, 80 a cell; "before" = B4's raw file
  `arms4/t0final/t0-hh-hisagi.lisp` for both seats, which reproduces main's lookup on 501-600 exactly, 192 : 8 / 183 : 17 / 65 : 135):

  | cell (141-180) | B4 share, K.O. rate, bell (hi : lo) | t21 share, K.O. rate, bell (hi : lo) |
  |---|---|---|
  | H>N HH | .975 (PASS), .225, 62 (60 : 2) | .975 (PASS), .950, 4 (4 : 0) |
  | N>E HH | .925 (PASS), .700, 24 (19 : 5) | .887 (PASS, Wilson .816), .950, 4 (3 : 1) |
  | E>M HH | .250, .713, 23 (6 : 17) | .450, .750, 20 (7 : 13) |

  E>M's gain repeats (+.20 here, +.145 on 501-600: ~2.6 and ~3 SE); N>E moves -.04 here and +.035 there (noise).
- The full dev ladder on the shipped build (`ladder.py --seed0 500 --seeds 100`): **17 of 27, as main**; the 24 non-HH cells are identical to
  `diag/tier/ladder-ring.txt` row for row (only the three HH rows differ, above). E>M HH .325 -> .470 is the one cell that moved toward a pass.
- No mirrored cell elsewhere: the HH table plays only the HH cells (KH / IH / HK / HI play their own rows).
- The parity rows are 100 distinct matches (both seats at one tier: the two seat jobs are the same); their share is .5 by construction.

**Checks** (sim `6d72d8005f58`): host tests (`tests/duel-rules-test.lisp`) 3742 checks ALL PASS; `tools/pkgcheck.sh duel` only the old
`DUEL::APP` note; `tools/simgate.py --cvc` PASS (II 39, IK 27, KK 22 lines, unchanged: the HH row is not a G2 pair). No browser build
(no game code besides the table).

## 4. What was not done

- E>M HH stays a fail (.470). The masher is beaten in the ranged mode by the arm that slows the mirror; t15 (.58) and t16 (.53) are the
  E>M-heavier points of the same trade (bar D .60 / .63 and .73 / .78). A cue that tells a masher from a CPU (e.g. a press-rate feature) would
  be a new rule-base feature, outside this batch's levers; so would per-difficulty tables (every tier plays the table, §11.28).
- t10 is the K.O.-heavy option (bar D .90 / .85, H>H .88, N>N .95) at E>M .14. No rule-base cue separates the masher from a CPU
  opponent, so t10 / t21 / t15-t16 is a choice for the lead, not more tuning of this map.
- No shared Hisagi unit, style file or rule changed; KH (`:t0-kh-hisagi`) and IH (`:t0-ih-hisagi`) are untouched, so their cells are not
  re-proved (the full ladder above shows them as on main).

## 5. Tools (research side)

Two findings about the shared tools (they affect numbers already quoted):
- **A mirror's bar D rows are half the matches they look like.** `finish.py bar` runs a mirror's two seat jobs as the same job when both
  seats play one table (the game's lookup included), so every mirror row (HH, KK, II in `diag/tier/bar-ring.txt` and earlier) is 40
  distinct matches counted twice (SE ~.07, not ~.05). The same holds for `lad.py`'s parity rungs (100 distinct).
- **finish.py's cache races on those duplicate jobs:** with `-j` above 1 the two identical jobs write one cache file (`os.replace`
  FileNotFoundError). Workaround here: `-j 1` (m.sh-style runs, `phase.py`). The fix (dedupe identical jobs) is a shared-tool change, left
  to the lead.

- `arms6/hh/lad.py`: the HH ladder cells with the bell / K.O. split and the parity rungs (ladder.py's job; a table file for both seats).
- `arms6/hh/phase.py`: Konpaku lost per form (finish.py's diag runner over the whole clock); `--env` for STRAT_DIF_P<n>.
- `arms6/hh/mk.py`: a T0 table from per-rule values (band.py's writer) for jobs split by a second group's cue.
- `arms5/finish/finish.py`: `diag` and `onset` take `--env K=V` (a table file per seat), as `bar` did.
- `arms6/hh/probe/`: the whole-arm probes; `arms6/hh/arms/`: one arm per file (band.py t0's input); `arms6/hh/t/`: maps, specs, tables.
