# The CPUs' perceived start, stamped when the action begins (DUEL_AI_STRATEGY §11.29, 2026-11-17)

The user approved fixing the bug that `../xch-as/notes.md` found (verbatim): 「Ok，下一步」.

## The bug

`cpu-perceive.lisp` SNAP-TAKE! derived the start of the opponent's action from the clock:
- a move's: `*match-tick* - fighter-sf - fighter-hold`;
- a guard's: `*match-tick* - fighter-guard-t`.

The CPU perceives once per sim frame (BRAIN-SYSTEM runs inside SIM-SYSTEMS), but `*match-tick*` counts every step. So the derived start
moved whenever ticks ran without frames, or a frame counter was reset mid-action.

| Case | Where | What the old read did |
|---|---|---|
| Hitstop: every real hit, block, Breaker hit, burst, cancel; Kenpachi's CHIGIRI / TATEGOTO stops; Ichigo's 12-frame stop | combat.lisp `hitstop`, gauges.lisp 179, core-sim.lisp 238 / 248 / 287 / 489, ken.lisp 340 / 356, ichigo.lisp 868 | every move (or guard) spanning it jumped by the hitstop length: one new key per hit |
| Slow motion: the cancel's 0.2, the perfect Hoho's, Ichigo's 0.4 | core-sim.lisp 239 / 288 / 490, fighter.lisp 398, ichigo.lisp 869 | a new start on every perceived frame (1/scale ticks a frame) |
| Super freeze (an `:sp` move freezes the opponent) | fighter.lisp START-MOVE, FIGHTER-STEP's early return | the frozen side's start moved 1 per frozen frame |
| A cinematic mid-move (a Kikon) | main.lisp SIM-STEP | the whole cinematic's ticks |
| A phase change resets the hold: the Breaker's aura → dash, the Kikon rush's phases, the Kikon `:follow` | fighter.lisp 587 / 623 / 738, combat.lisp 45 / 229 | one jump each |
| ENTER-MAIN (a hold move's frame back to 0) | fighter.lisp ENTER-MAIN | one jump |
| ORANGE's startup cut | fighter.lisp START-MOVE | started earlier by the cut (a wrong value, no new key) |
| An AS out of a cancel (DUEL_CORE §2.1.3) | core-sim.lisp CORE-PRE-ROLL | the tick of move frame 0, 6 after the press (an offset, no new key) |
| A Hoho, rebuilt by two style CPUs as `now - brain-delay - snap-sf` | cpu-ki-ken.lisp 367, cpu-ki-ichigo.lisp 812 | mixed ring steps (sim frames) with ticks; drifted in the perfect Hoho's own slow motion. KK's version rolled `*kk-hend-p*` on every "new" Hoho, so once per step until the roll succeeded |

A start that changes every step breaks every "one roll per event" key: the roll is redrawn each step, and a per-step chance is a
certainty. After a cancel it also made his old J1 look like a link started after the cancel (`(> ostart xch)`).

## The fix

fighter.lisp ACT-START gives the start as a fact recorded when the action began, read by SNAP-TAKE! into `snap-start`:
- a move: `fighter-cls-t`. CORE-NOTE-START! sets it in every START-MOVE, so it is the press tick, also for an AS's pre-roll, a hold
  move, a Breaker and an ORANGE start.
  - An SA latched before a cancel carries the cancel's tick (CORE-LATCH-STEP). XCH-TURN-SEEN-P reads `ostart` only for `:as` / `:na`
    (an SA is seen through OWN-HIT), so that stamp changes nothing there.
- a guard or a Hoho: a new fighter slot `state-t` (components.lisp, in the ECS store the snapshot copies). It is stamped at every entry:
  - the guard: fighter.lisp NEUTRAL-STEP, the guard cancel, STUN-STEP's re-raise, and debug 2306;
  - the Hoho: START-HOHO.
- anything else: -1, as before.

KI's two Hoho readers now read `snap-start` too. Before, a Hoho's `snap-start` was -1 (like idle), so his Hoho now re-keys
AI-EVENT-ROLLS twice, on entering and on leaving, as a guard already did. No chance, table or knob was changed.

Every reader of `snap-start`, and what it assumed:
- **Keys, compared for equality (no change needed):** AI-EVENT-ROLLS; BRAIN-PERCEIVE's J start (`brain-jstarts`, the masher read: the
  drift pushed a new "J start" on each hit's hitstop); CAI-CLASH; HB-REACT and Hisagi's clash (cpu-hisagi-own 86 / 189); KK's read key
  (cpu-ki-ken 511); IKS-PUNISH, IKS-CONFIRM, IKS-TIMED-HOHO and the retreat key (cpu-ki-ichigo 462 / 480 / 520 / 635).
- **Arithmetic, kept as written:**
  - `(> ostart xch)` in XCH-TURN-SEEN-P / XCH-SA-NOW-P;
  - KK-JUJI-START (start + 17 / 38, measured from the log's move ticks, which are these ticks) and its route gap (> 45);
  - IKS-PUNISH's `(- *match-tick* (snap-start s))` against `iks-ns-wait`. This now counts ticks since the real start, hitstop included.
  - With no drift the old read was the press tick + 1 - ENTER; the new one is the press tick. So these arithmetic readers moved by
    ENTER - 1 frames. Nothing was retuned for it.
- teacher.lisp takes a SNAP and reads no start.

## The harness (tools/simgate/trial.lisp)

xch-as's `cpu-window.py` reported 0 of 180 watches on his AS. Most of that came from the trial, not the drift:
- `:p2-cpu` set the difficulty but kept the match's BRAIN-DELAY (14) at every difficulty.
- One match carries every trial, so the SNAP ring kept the last trial's tail. A CPU saw the last trial's moves for its first DELAY
  frames, or P1 undelayed (empty slots fall back to the current SNAP) in a file's first trial.

Both are fixed: the difficulty's delay, and the ring filled with P1 as the trial starts. `:log-simf T` logs each sim frame so the SA's
timing is counted in frames across the slow motion. `tests/sp-costs-check.py` passes after it (116 PASS).

## cpu-window (this folder's `cpu-window.py`, the fixed harness)

The scene: P1 Kenpachi J1 into P2 Bankai Hisagi's NSa (her CPU); his AS1 on xch-as's frame; seeds 1-20 per row.
- "Before" is the old read on this branch's slot writes (`oldread.fas`, G2-identical to main).
- `cpu-before.txt` and `cpu-after.txt` hold the rows.

| Difficulty | watch on his AS, before → after | on his "new NA", before → after | SA press after his AS press | SA lands first |
|---|---|---|---|---|
| HARD (8) | 15 → 49 of 60 | 34 → 0 | on his AS +9 frames (every case); the old misread +7..+8; inside +2..+18/20/22 | every fired case, both builds |
| NORMAL (14) | 0 → 0 | 45 → 47 | +9 sealed / Shikai, +11 Bankai (own-hit branch, below), the same in both builds, inside the window | every fired case |
| EASY (24) | 0 → 0 | 0 → 0 | - | - |

- The old read fired HARD's SA one frame before the AS could be seen. At that frame the delayed SNAP showed his J1, with its start
  drifted past the cancel's tick, so the watch took it for a new NA link.
- NORMAL's SA comes after her NSa's later hit is ABSORBED by his AS. That hit counts in `fighter-hits`, so XCH-SA-NOW-P's OWN-HIT branch
  fires on the still-delayed view of his J1. It fires the same way with both reads, on the same frames (+9 / +9 / +11).
  - The name OWN-HIT says "the segment's own hit was the cancel's". An absorbed later hit satisfies the test too. This was not changed.
  - Her SA lands first in every such trial.

## G2

With the old read restored and the slot writes kept, the native run was identical to the reference line for line. Regenerated (native =
browser): II 30 lines P2 0-7 292.6 s, IK 18 lines P1 9-0 175.0 s, KK 21 lines P1 2-0 205.7 s. Before: II 32 P2 0-4 321.0 s, IK 24 P1 3-0
240.6 s, KK 28 P2 0-2 273.7 s.

## HARD vs HARD bar (finish.py bar, seeds 141-180, both seats, the shipped lookup)

`bar-before.txt` is the old-read build, identical to xch-as's `bar-after.txt` (main's code). `bar-after.txt` is this change.

| Row | K.O. before → after | points A before → after | mean s before → after |
|---|---|---|---|
| KI | 1.000 → 1.000 | 0.013 → 0.000 | 156.6 → 149.7 |
| KH | 1.000 → 0.963 | 0.237 → 0.200 | 210.5 → 217.4 |
| IH | 0.887 → 0.838 | 0.113 → 0.113 | 244.6 → 249.7 |
| KK | 1.000 → 1.000 | 0.500 → 0.500 | 173.4 → 164.3 |
| II | 0.600 → 0.425 | 0.500 → 0.500 | 269.7 → 279.9 |
| HH | 0.000 → 0.000 | 0.500 → 0.500 | 300.0 → 300.0 |

## Dev ladder (ladder.py --seed0 500 --seeds 100, 27 cells)

Before is xch-as's `ladder-after.txt` (main's code); after is `ladder-after.txt` here. 16 → 17 of 27 pass. Cells that moved by more
than 2 %:

| Cell | Before | After |
|---|---|---|
| E>M KH | 0.705 fail | 0.755 PASS |
| N>E KK | 0.965 | 0.925 |
| N>E HK | 0.920 | 0.870 |
| E>M KI | 0.090 | 0.050 |
| E>M IH | 0.195 | 0.125 |
| E>M HI | 0.260 | 0.230 |
| E>M II | 0.120 | 0.100 |

Report only; nothing was tuned.

## Checks

- Host tests: 3742 checks, ALL PASS (9 new in tests/duel-rules/sim.lisp: ACT-START keeps a J1's tick through a cancel's hitstop, its
  slow motion and a hold reset where the old read drifts, an AS's pre-roll starts on its press, guard / Hoho read STATE-T).
- pkgcheck: only DUEL::APP, which was already reported before this change.
- sp-costs-check: all pass.
- snaptest 30000 31104 2132: straight = pollute.
- fulltest on 2102 4007: 0 differ (1 check; with FT_LAYER=t, 686 checks, 0 differ).
- `./build.sh duel` and the smoke run: no error.

Still open, not changed here:
- The real game's first BRAIN-DELAY frames of a match see the opponent undelayed, because empty ring slots fall back to the current
  SNAP.
- After a round reset, the ring still holds the previous round's tail.
