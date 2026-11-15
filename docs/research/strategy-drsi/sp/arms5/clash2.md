# The clash without the dead-zone test (CLASH-FIT removed; 2026-11-15)

The user (2026-11-15, verbatim): 「就算在修兵的近距離死角相消，但隨後的 SA 或 AS 還是能造成攻擊啊？」

`arms5/clash.md` added CLASH-FIT (`xch-ai.lisp`): the CPU's clash refused an opener whose dead zone (`:min-reach`) covered the perceived
distance. Its premise was that the opener has to reach. It does not: a cancel is judged when the OTHER side's hit lands in the opener's
classed window, and both sides count as landed (DUEL_CORE §2.1). This batch checks that with written scenes, removes the test and
measures the change. KK-FITS-P (`cpu-ki-ken.lisp`, the brawler's real-hit pick) stays: a real attack does have to reach.

Files: `clash2/scenes.py` (the scenes), `clash2/measure.sh` (the cells), `clash2/table.py` (the tables below), `clash2/before/`,
`clash2/after/` (probe.py text + JSON per cell).

## 1. Scenes (scripted, both sides driven; Hisagi's Shikai P1 vs sealed Kenpachi P2)

`python3 docs/research/strategy-drsi/sp/arms5/clash2/scenes.py a0 b0 a b r awin reach --rows` (tools/simgate/trial.lisp; P2's presses
on sim frames through `:p2-at`; Hisagi's SA through the new `:p1-at`, the same sim-frame clock as his. Ticks in the rows are log ticks
from his first press; they include the AS's call-out freeze, so only the `+n` in a scene's name is in sim frames).

**(a) His J1 (sim frame 0), Hisagi's NAGI (pointer 1 NS, dead zone 3.0 m) into it 2 frames later.**
- 1.2 / 1.8 / 2.4 m (and 2.5 / 2.6): `KE-Z-J1 x P1: CANCEL` at tick 9. His J1 hit lands in NAGI's startup. Her KIN turns on (the cancel
  unlocks her close range, DUEL_HISAGI §29). If he does nothing, NAGI's own hit lands at tick 53-54 (`HS-N1A -> P2 HIT 62`, 25 dmg).
- 2.7 / 2.8 / 2.9 m: no cancel. His J1 (reach 1.8 + slide 0.6) does not reach her, and NAGI cannot hit inside 3 m. Both whiff.
- Then his AS at once (SP press 1 sim frame after the cancel) against her SA, pressed n sim frames after his SP press:

| her answer | result (same at 1.2 / 1.8 / 2.4 m) |
|---|---|
| none | his AS1 absorbs NAGI's late hit and lands (`KE-Z-AS1 -> P1 HIT 90`, knockdown) |
| SA +0 (same frame as his AS) | both start together: two cancels, no hit |
| SA +1 ... +16 | **her SA wins** (`HS-SA-KIRI -> P2 HIT 40`; from +8 his AS1's hit is absorbed by it) |
| SA +17 ... +32 | no SA starts (its window is over); his AS1 wins as with none |

  So the NS side's out is the reactive SA in a 16-frame window (timed from his SP press). The CPU's XCH-SA-NOW-P sees his AS
  BRAIN-DELAY late, and fires at `*cai-xch-sa-p*` .25 / .45 / .65 only:
  - HARD (8 frames): inside.
  - NORMAL (14 frames, plus a frame of press latency, about +15-16): at the edge, not measured. No measured cell has a NORMAL Hisagi on
    the NS side; in H>N KH her NS-clash exchanges are 0.00 a match.
  - EASY (24 frames): outside.

  In play, HARD wins its NS-clash exchanges 72 % of the time in H>N HK (7.47 of 10.43) and 60 % in bar D (10.1 of 16.95). Both are near
  HARD's .65.
- 2.9 m: no cancel, so no AS for him. Her SA press then starts SA-KIRI out of NAGI and hits (36). This needs no exchange.

**(b) His NS1a (sim frame 0), Hisagi's J1 into it.** 1.2-2.9 m: `KE-Z-N1A x P1: CANCEL` at tick 14, then `HS-J1 x P2: CANCEL` at 23.
Her AS1 TSUMUJI then wins against every answer at every distance: none, his SA +2 / +8 (absorbed), his NS1b +2, his J (an SA at once)
(catalogue §5, now at four distances). Her Shikai J1 has no dead zone, so CLASH-FIT never blocked this side.

**(r) The Bankai's ranged mode** (its J and NS both have dead zones). ra (his J1 into her ranged NS1a): a cancel at 1.2-2.4 m. His
instant AS wins against no answer, her SA +8 wins (`HS-R-SA`). rb (his NS1a, her ranged J1 into it): a cancel at 1.2-2.9 m. RANSA wins
against none, his SA +8 beats it (catalogue §5's ranged row). Ranged J2 against none wins too.

**Verdict.** The dead zone never decides whether a clash cancels. Whenever his hit reaches her (up to 2.6 m for his J1), her opener
cancels it, dead zone or not. The exchange is decided by the side and the timing: as the J side she wins with TSUMUJI against
everything; as the NS side she wins with an SA in his AS's first 16 frames and loses without one. CLASH-FIT's premise is wrong.

## 2. The change

- `core-ai.lisp` CAI-CLASH: the `to` binding reverts to the pre-CLASH-FIT form (the inverse of 1fc1015c's hunk): CLASH-OPENER's class;
  the NA opener always allowed; the NS opener only when the pointer has an NS (`(or (eq to :na) (kit-core-move kit :ns (fighter-ptr f)))`
  in the guard). The docstring records why there is no dead-zone test.
- `xch-ai.lisp` CLASH-FIT deleted, with its 10 host checks (`tests/duel-rules/xch-ai.lisp`). The CLASH-OPENER checks stay.
  `mv-min-reach` (other callers) and KK-FITS-P are untouched. No knob changed.
- Sim build `03aeeddd509d` (before, this worktree at main 3b49b99f) → `5607924a031c` (after).
- **Parity**: the before build reproduces `diag/tier-t0.md` §1 cell for cell (H>N HK .200 [86], IH .780 [51], N>E HK .770 [64], E>M
  KH .675, HK .000), so the worktree's own build stands in for main's pinned fas.

## 3. Measured (seeds 501-600, both seats, 200 a cell, the shipped lookup; `diag/probe.py`, the game's result, a draw half)

Pass = ladder.py's rule, at least 151 of 200 (share >= .755). Cells name the higher tier first (H>N HK = a HARD Hisagi vs a NORMAL
Kenpachi). [n] = matches at the bell.

| rung | cell | before | after | pass after |
|---|---|---|---|---|
| H>N | HK | .200 [86] | **.435 [47]** | no |
| H>N | KH | 1.000 [0] | 1.000 [0] | yes |
| N>E | HK | .770 [64] | .785 [63] | yes |
| N>E | KH | 1.000 [1] | 1.000 [1] (identical) | yes |
| E>M | HK | .000 [0] | .000 [0] (identical) | no |
| E>M | KH | .675 [1] | .675 [1] (identical) | no |
| H>N | HI | 1.000 [3] | .995 [6] | yes |
| H>N | IH | .780 [51] | .765 [49] | yes |
| **bar D**: KH HARD vs HARD, K.O. rate | | .665 (67 at the bell) | **.995** (1 at the bell) | yes (>= .90) |

- In bar D, Kenpachi wins either way (share .985 → .995). The time-outs became K.O.s, mostly his.
- E>M (both cells) and N>E KH are identical in every counter: an EASY Hisagi throws no NS clash under 3 m in either build (0.00 a match).

### The exchange accounting (per match; `probe.py`'s new counters)

The counters:
- `clash_<to>_<lt3|ge3>`: `cpu clash` by the class thrown and by d < / >= 3.0 m.
- An exchange is a run of cancels each within 60 ticks of the last, "from S's clash" when S logged a clash in the 40 ticks before it.
  It ends with the first real hit (CORE-BREAK!'s `BREAK fs` line, credited to the hitter's class) or with none.
- `xc_open / won / lost` count S's clash exchanges.

**H>N HK** (HARD Hisagi vs NORMAL Kenpachi):

| per match | Hisagi before | Kenpachi before | Hisagi after | Kenpachi after |
|---|---|---|---|---|
| clashes (all) | 20.95 | 50.17 | 29.41 | 48.88 |
| NS clash under 3 m (hers: NAGI into his J / SA) | 3.24 | 2.25 | **10.39** | 2.52 |
| NA clash (a J into the other's NS / AS), < 3 / >= 3 m | 15.48 / 1.79 | 19.87 / 17.88 | 16.83 / 1.76 | 20.47 / 16.64 |
| own NS-clash exchanges: opened / won / lost | 3.28 / 1.44 / 1.84 | 9.41 / 5.61 / 3.40 | **10.43 / 7.47 / 2.96** | 9.00 / 5.23 / 3.45 |
| own NA-clash exchanges: opened / won / lost | 14.57 / 13.55 / 0.96 | 29.05 / 25.07 / 3.46 | 12.29 / 11.23 / 1.04 | 29.02 / 24.89 / 3.69 |
| clashes that opened no exchange (clash − opened): NS / NA | 0.39 / 2.71 | 3.02 / 8.70 | 0.39 / 6.30 | 2.77 / 8.09 |
| first real hit of an exchange: J / AS / SA | 10.91 / 7.01 / 6.19 | 0.18 / 31.14 / 5.66 | 9.67 / 6.00 / **12.54** | 0.23 / 32.35 / 5.40 |
| AS starts / damage | 51.9 / 1670 | 123.8 / 3852 | 60.3 / 2008 | 127.8 / 3800 |
| SA starts / damage | 42.0 / 354 | 10.0 / 162 | 49.3 / 557 | 9.3 / 160 |
| damage dealt (all) | 3894 | 5541 | 4724 | 5219 |

- The new clashes are the NS side: NAGI under 3 m, 3.2 → 10.4 a match.
- She wins 7.5 of those 10.4 exchanges. They are the SA breakthroughs (6.2 → 12.5), which matches the scenes: HARD's 8-frame eyes
  answer his AS inside the 16-frame window.
- Her NS clashes that opened no exchange stay at 0.39 a match. Nearly every new NAGI clash cancels, so the 2.7-3.0 m band where nothing
  reaches (scene a) is rare in play. Her NA clashes with no exchange rose 2.71 → 6.30. That is observed here and not chased.
- Kenpachi still out-clashes her (48.9 to 29.4), and his J-side exchanges (29 a match, 86 % won with his AS) are unchanged. That is why
  the cell is still a fail at .435.

**bar D, KH HARD vs HARD** (Kenpachi / Hisagi, both seats):
- Her NS clash under 3 m went 4.3 → 17.2 a match, and those exchanges went won 1.8 / lost 2.4 → won 10.1 / lost 6.8.
- His AS starts went 107 → 150 (damage 2905 → 3760). Her damage went 1367 → 2323.
- Exchanges ended with no hit 4.2 → 1.0 a match. The matches end: K.O. .665 → .995.

**H>N KH** (HARD Kenpachi vs NORMAL Hisagi): her clashes 3.2 → 7.6, mostly J clashes under 3 m (2.4 → 6.6). CLASH-FIT refused a J only
when it had a dead zone, i.e. the Bankai's. Share stays 1.000.

**Hisagi vs Ichigo (H>N)**:
- HI: her clashes 5.5 → 6.9 (NS under 3 m 0.33 → 0.88; those exchanges won .17 → .51 a match). Share 1.000 → .995.
- IH (NORMAL Hisagi): her clashes 1.9 → 2.6 (NA under 3 m 1.7 → 2.4, won .53 → .74, lost .95 → 1.21). Share .780 → .765.
- Ichigo throws no clash in either cell (0.00).

## 4. Checks

- Host tests: duel-rules 3704 checks ALL PASS (CLASH-FIT's 10 removed); duel-control 124, input 33, touch 100 (0 failures), cine 18.
- pkgcheck: only DUEL::APP. `./build.sh duel` built (`git checkout -- vendor` after); smoke (run.mjs, 8 s) exit 0, heap 75.1 MB.
- **G2 unmoved** (`style-gates.py cvc dist/duel`): II 41 lines P2 2-5 403.6 s, IK 42 P2 1-2 421.7 s, KK 31 P1 3-0 307.2 s, identical to
  `tests/style-cvc-ref.txt`. Kenpachi and Ichigo have no `:min-reach`, so for them CLASH-FIT always returned CLASH-OPENER's class.
- No balance gates beyond the cells above (the user's rule).

## 5. Tool changes (tool side only)

- `tools/simgate/trial.lisp`: `:p1-at ((sim-frame :j|:sp [frames]) ...)`, P1's presses on the same sim-frame clock as `:p2-at`. The
  script's waits count only P1's unlocked frames, which the AS's call-out freeze stretches.
- `diag/probe.py`: the exchange counters above. `mclass` now reads a bare SA (`IC-SA`, `KE-S-SA`, `HS-SA-KIRI`, `HS-R-SA-G`) as SA and
  Hisagi's NA3 / NA4 as NA; both were 'other' before. So probe's SA / NA columns no longer compare with tier-t0.md's, while every share
  and bell does.
