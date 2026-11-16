# An AS out of a cancel waits 6 frames (DUEL_CORE §2.1.3, 2026-11-16)

The user (verbatim): 「檜佐木卍解後還是會被劍八壓著打，我發現是因為 NSa 的動作太久了，導致在他能切換成 SA 前，劍八就已經能從 J 換成 AS 以突破防線。是否應該要讓每一段在相消後就能換成 SA 或 AS？」
Shown the window below, the user chose 「相消後的 AS 前搖拉長」: every fighter, every form, +6 frames of startup for an AS started out of a
cancel (`*core-xch-as-delay*` 6, tuning.lisp).

Files: `sweep.py` (the scripted scenes, trial.lisp; `--fas` picks a build), `cpu-window.py` (the CPU as the NS side), the outputs
`*-before.txt` (main 203c7cb5's build) and `*-after.txt` (this change). `sweep-before.txt`'s combo section played Bankai Hisagi at 1.5 m
(inside his dead zone: no hit); `combo-before.txt` is that section again at 4.5 m, as `sweep-after.txt` plays it.

## Scenes: the SA's window (frames from the AS press to the SA press that still wins)

The J side's J1 cancels the NS side's first segment, the J side presses SP one sim frame after the cancel, the NS side presses J n frames
after that (n = 0, 2, ... 28). Every distance (1.2 / 1.8 / 2.4 m) and every Hisagi mode / pointer gave the same window.

| Scene | AS | Before | After |
|---|---|---|---|
| kh: Bankai Hisagi NSa (ranged / bind, pointer 1 / 2) x Kenpachi J1 | sealed KE-Z-AS1 | +2..+16 | +2..+22 |
| | Shikai KE-S-AS1 | +2..+14 | +2..+20 |
| | Bankai KE-KR-AS1 | +2..+12 (ranged pointer 2: +0..+12) | +2..+18 |
| hk: Hisagi J1 x Kenpachi NS1a, Kenpachi's SA | Bankai HS-R-AS1 vs sealed / Bankai Kenpachi | +2..+16 | +2..+22 |
| | HS-R-AS1 vs Shikai Kenpachi | +2..+14 | +2..+20 |
| | Shikai HS-AS1 TSUMUJI vs sealed / Bankai Kenpachi | none | none |
| | HS-AS1 TSUMUJI vs Shikai Kenpachi | none | +2..+6 |
| ki: Ichigo NS1a (base / KESSA) x Kenpachi J1 | KE-Z-AS1 / KE-S-AS1 / KE-KR-AS1 | +2..+16 / +14 / +12 | +2..+22 / +20 / +18 |
| combo: J1 really hits a standing dummy, SP on the hit | every fighter's AS1 | AS start / hit ticks | identical |

- The window grew by exactly 6 frames everywhere (0.30-0.37 s against 0.20-0.27 s).
- +0, the ranged pointer 2 case: the SA starts on the AS's own tick, a CORE-LATER tie (both cancel). Before, SA-G's later hit fell on the
  AS's recovery; now the AS's later active frames meet it, a second cancel. So +0 is a tie, as the rule says.
- TSUMUJI (16 active frames, four hits, a carry to 3-4 m) still beats the reactive SA, as in §2.1.1. Against the Shikai's SA it now loses
  to an SA pressed 2-6 frames after it.
- combo (the AS start / hit ticks, both builds): KE-Z 15 / 31, KE-S 16 / 30, KE-KR 14 / 26, HS 20 / 34, HS-R (4.5 m) 20 / 35, IC 20 / 34,
  IC-K 14 / 26.

## The CPU as the NS side (cpu-window.py)

P1 Kenpachi J1 (script) into P2 Bankai Hisagi's NSa (`:p2-start` 2 frames later, so his hit is the one judged), then her CPU plays; his AS
one frame after the cancel; seeds 1-20 per difficulty and form.

- Her SA was never pressed on seeing his AS (`cpu xch SA on his as`: 0 of 180 trials, both builds).
- She always pressed it on his "new NA" (`on his na`, 4-17 of 20 per row) at the tick his AS started: a CORE-LATER tie. Her follow-up
  (J2 or AS) then landed first, in every such trial of both builds.
- The cause (pre-existing, not touched): `snap-start` = tick - move frame - hold (cpu-perceive.lisp). During the cancel's hitstop and its
  0.2 slow motion, ticks run while move frames don't. So his J1's perceived start drifts past the cancel's tick, and XCH-TURN-SEEN-P's
  `(> ostart xch)` takes the old J1 for a new link.
- Had the watch seen the AS, its SA would press about BRAIN-DELAY + 1 frames after the AS starts: EASY 25, NORMAL 15, HARD 9.
  - Before: HARD inside every window, NORMAL only against the sealed AS1 (+16), EASY never.
  - After: HARD and NORMAL inside every window (+18 / +20 / +22), EASY still never.
- A negative start frame keeps `snap-start` steady through the AS (the tick of its move frame 0, 6 after the press). `snap-left` counts
  the 6 extra frames. The CPU's keyed rolls don't re-roll.

## HARD vs HARD bar (finish.py bar, seeds 141-180, both seats, the shipped lookup)

| Row | K.O. before | K.O. after | points A before | points A after | mean s before | after |
|---|---|---|---|---|---|---|
| KI | 1.000 | 1.000 | 0.250 | 0.013 | 187.9 | 156.6 |
| KH | 0.975 | 1.000 | 0.975 | 0.237 | 226.8 | 210.5 |
| IH | 0.887 | 0.887 | 0.075 | 0.113 | 246.9 | 244.6 |
| KK | 1.000 | 1.000 | 0.500 | 0.500 | 164.7 | 173.4 |
| II | 0.550 | 0.600 | 0.500 | 0.500 | 271.4 | 269.7 |
| HH | 0.000 | 0.000 | 0.500 | 0.500 | 300.0 | 300.0 |

Kenpachi's HARD loses most: KH flips from Kenpachi 0.975 to Hisagi 0.763, and KI goes 0.250 → 0.013. His tables lean on the J1 → AS out of
a cancel. Report only; nothing was tuned.

## Ladder (ladder.py --seed0 500 --seeds 100, 27 cells)

15 → 16 of 27 pass. Moved cells:

| Cell | Before | After |
|---|---|---|
| H>N HK | 0.665 fail | 0.975 PASS |
| H>N IH | 0.720 fail | 0.645 fail |
| N>E HK | 0.790 | 0.920 |
| N>E KI | 0.940 | 0.985 |
| E>M KH | 0.750 | 0.705 |
| E>M KI | 0.155 | 0.090 |
| E>M IH | 0.130 | 0.195 |

The other cells are within a few matches of before. The E>M row still fails throughout.
