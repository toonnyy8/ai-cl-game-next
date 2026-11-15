# Ladder tiering on the T0 tables (PLAN4 bar B, 2026-11-15)

The user's bar (2026-11-15): 「hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」, judged by the game's own result
(「照遊戲判定」; a draw counts half). Every tier plays the pairing's fuzzy Q table (「三個難度都用 Q 表」, `*strat-table-chance*` 1 / 1 / 1).
The constraints:
- every chance is EASY ≤ NORMAL ≤ HARD (frames: EASY ≥ NORMAL ≥ HARD);
- no per-pairing knob;
- the masher's pre-registered rates are not touched.

This note probes that bar on the current main build: the T0 tables, the clash dead-zone fix (`arms5/clash.md`) and the three strategy
batches.

**Setup**
- Build: main 334b313b, sim build `f0e2bb129de1` (SP_BUILD pinned; main's `build/simgate/duel.fas` copied in).
- Seeds: dev 501-600 only, both seats, 200 matches a cell.
- No game code changed. Every world is a load-time binding: `probe.py --set` / `--lift` (PROBE_SET / PROBE_LIFT).
- Pass = ladder.py's rule: one-sided 95 % Wilson low ≥ .70, i.e. at least 151 of 200 points (share ≥ .755).
- Tables below: `*` = fail; `[n]` = matches at the bell when over 50 of 200 (25 %, flagged).
- Cells name the higher tier's character first: in E>M, IH = an EASY Ichigo against a masher Hisagi.

**Tools added here**
- `run-tier.sh SPEC [RUNGS]`: runs one spec line (`name<TAB>set<TAB>lift`) per world through probe.py at 200 a cell. Its JSON goes to
  `tier/<hi>-<lo>-<name>.json`.
- `tier-table.py NAME...`: renders those JSON files as the tables below.
- `probe.lisp`: the `@style` / `@style-h` groups now also hold Hisagi's new `*hb-*` knobs (`cpu-hisagi-own.lisp`).
- The `:x` slot in a SET plist (`*cai-clash-delay*=(... :x 14)` plus the lift `easy=x:*cai-clash-delay*`) carries a value past a group
  lift, because lifts run after the set.

**Parity check**: probe.py's E>M rung on the base build gives the same cell values as ladder.py's (0.140 overall, all nine equal), so the
worlds here are comparable to the ladder.

**Not tierable**: `*cai-clash-margin*` is a scalar (1.0), not a per-difficulty plist. "HARD's clash margin to EASY" is a no-op without a
code change; only `*cai-clash-p*` and `*cai-clash-delay*` are tiered.

## 1. Baseline (main as shipped; `ladder.py --seed0 500 --seeds 100`, `tier/base-501-600.json`)

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass |
|---|---|---|---|---|---|---|---|---|---|---|
| H>N | 1.000 | 1.000 | 1.000 | 1.000 | .995 | .780 [51] | **.200*** [86] | 1.000 | .940 [182] | 8 |
| N>E | .905 | .995 | 1.000 | 1.000 | .980 [54] | .910 [74] | .770 [64] | 1.000 | .932 [100] | 9 |
| E>M | .000* | .095* | .675* | .000* | .000* | .110* | .000* | .275* [100] | .105* | 0 |
| (N>M, context) | .090* | .920 | 1.000 | .115* | .415* [136] | .235* [83] | .305* | .980 | .350* | 3 |

**17 of 27 pass.** Compared with b4.md §7 (16 of 27, before the clash fix and the strategy batches):
- H>N IH now passes (.710 → .780).
- H>N HK fell (.345 → .200): HARD Hisagi against NORMAL Kenpachi.
- N>E HK is at .770, barely passing.
- E>M is still 0 of 9.
- NORMAL itself beats the masher in only 3 cells, so on today's knobs EASY's ceiling (EASY ≤ NORMAL) already fails six E>M cells.

## 2. EASY > masher

### 2.1 The worlds, cumulative as briefed (monotone, so a lift to EASY lifts NORMAL too)

| world | E>M | N>E | H>N | total |
|---|---|---|---|---|
| E0: EASY's clash at NORMAL's (.35 / 10), NORMAL untouched | 1 (.262) | 8 (HK .130) | 8 | 17 |
| E1: clash at HARD's (.6 / 8) at every tier | 2 (.431) | 8 (HK **.022**) | 7 (IH .730, HK **.005**) | 17 |
| E2: E1 + EASY's eyes = NORMAL's (14) | 3 (.540) | 7 | 7 | 17 |
| E3: E2 + every `@cai` knob at HARD's for EASY and NORMAL | 6 (.811) | 3 | 7 | 16 |
| G3n: all-tiers-table.md's G3 on this build (eyes 18 / 14 / 4, flat `@cai`, style-k E=N<H, style-i flat HARD, style-h E<N=H) | 7 | 6 | 7 | 20 |
| S6: eyes 18 / 14 / 4, clash flat HARD's, style-i flat HARD's, EASY's other `@cai` at NORMAL's | 5 | (not run) | | |
| **G3m22**: G3n with Hisagi's style as shipped per tier and EASY's eyes 22 | 7 | 6 | 8 | **21** |

The E>M rows, cell by cell:

| world | KK | KI | KH | IK | II | IH | HK | HI | HH |
|---|---|---|---|---|---|---|---|---|---|
| E1 | .575* | .940 | 1.000 | .070* | .035* [84] | .110* | .020* | .720* [118] | .410* [69] |
| E3 | .860 | .995 | 1.000 | .905 | .570* [122] | .420* | .750* | 1.000 | .800 |
| S2: E1 + style-i flat HARD's (eyes 24) | .575* | .940 | 1.000 | .990 | .990 [78] | .385* | .020* | .720* [118] | .410* [69] |
| G3n | .870 | .990 | 1.000 | 1.000 | 1.000 | .810 | .515* | 1.000 | .705* |
| G3m22 | .865 | .990 | 1.000 | 1.000 | 1.000 | .840 | .365* | 1.000 | .705* |

### 2.2 Answer: no monotone tiering reaches E>M ≥ .70 in all nine cells while N>E and H>N hold

Within these knobs, the best world passes 7 of the 9 E>M cells, with 6 of 9 N>E and 8 of 9 H>N. One structural block makes 27 of 27
impossible, and a second one shows up in every world measured.

**Block 1: the masher-Kenpachi column against the HK diagonal (structural; it rules out 27 of 27).**
- E>M against a masher Kenpachi (KK, IK, HK) needs EASY's clash to be both 8 frames and at chance ≥ .6, which is HARD's. Shares for the
  KK cell by EASY clash (chance / delay):
  - .6 / 8: .575 at eyes 24 (E1); .86-.87 at eyes 14-22 with flat `@cai` (E3, G3n, G3m22);
  - .35 / 8: .48 (HK .155); .15 / 8: .20 (HK .060). Both are in the G3m22 world (`spec-tier-d8`); there, H>N HK is .475 and .835;
  - .6 / 14: .085 (A14, eyes 14, flat `@cai`);
  - .35 / 10: .16;
  - .25 / 10: .16;
  - .15 / 10: .13 (all in the G3n world).
- So a rarer 8-frame clash that keeps H>N HK (.15 / 8: .835) loses KK and HK against the masher. A surer one that wins KK (.6 / 8) loses
  H>N HK (.045).
- The masher's J hits about 9 frames after it starts. A clash slower than 8 frames reads a snapshot older than the J's live window
  (masher-vs-easy.md C2).
- Even NORMAL cannot beat a masher Kenpachi without that clash: N>M KK .090, IK .115, HK .305 as shipped (.35 / 10); KK .18 and IK .185 at
  .6 / 14.
- Monotone forces NORMAL's clash ≥ EASY's. That fast clash in the lower tier's Kenpachi beats the higher tier's Hisagi in both HK cells. The
  higher-tier Hisagi's own clash is fenced by NAGI's 3.0 m dead zone (CLASH-FIT), so he has no answer:

| lower tier's clash (chance / delay) | N>E HK (the EASY Kenpachi's clash) | H>N HK (the NORMAL Kenpachi's clash) |
|---|---|---|
| .15 / 24 (shipped EASY) | .730-.770 | |
| .15 / 10 | | .870 |
| .35 / 14 | | .790 (R1a) |
| .35 / 10 (shipped NORMAL) | .130 (E0) | .200 (base) |
| .6 / 14 | .035 (R2) | .435 (R2) |
| .6 / 8 (HARD's) | .022 (E1); .025-.045 in every G3 world | .005 (E1); .045 (G3n, G3m) |

(In the G3n world, where NORMAL has HARD's generic chances, H>N HK is .950 at .35 / 14 and .930 at .6 / 14, but .375 at .35 / 10, .625 at .25 / 10
and .820 at .15 / 10: the 8-10 frame clash is what loses the cell. N>E HK stays .025-.140 there at every clash, because EASY's HARD generic
chances make the EASY Kenpachi stall the NORMAL Hisagi to the bell: 144-199 time-outs of 200.)

- Per match in H>N HK as shipped (`tier/hk-hn-base-full.json`):
  - NORMAL Kenpachi clashes 50.2 times, HARD Hisagi 21.0.
  - Kenpachi's AS starts 123.8 against 51.9, and his AS damage is 3852 Reishi against 1670.
  - Hisagi takes 5.8 Konpaku by Soul Break, against 0.8 for Kenpachi.
- With NORMAL's clash alone set to EASY's, H>N HK goes .200 → .950. With its delay alone 10 → 14, it goes to .790. Every other NORMAL part
  set to EASY's leaves HK at .20-.37 (`@style-k` .285, `@mc` .200, eyes 18 .372).
- **HARD-only levers do not compensate.** H>N HK with HARD's eyes 4 is .345, eyes 2 .415, clash 1.0 / 4 .185. Hisagi's HARD style set to
  NORMAL's is .155 (eyes 4: .340). His clash cannot fire inside the dead zone, so a faster or surer clash buys him nothing.
- So any world that passes the masher-Kenpachi column fails both HK diagonal cells: at most 25 of 27. A world that keeps the HK cells fails
  E>M KK and IK at least, and HK too: at most 24.

**Block 2: EASY Hisagi against the masher (E>M HK, HH).**
- E>M HK and HH reach the bar only in E3 (HK .750, which is 150 of 200, just under; HH .800), where EASY has NORMAL's eyes (14) and HARD's
  generic chances. That world drops N>E to 3 of 9.
- At eyes 18-24: HK .205-.515, HH .55-.705.
- Hisagi's HARD style knobs hurt him against the masher. In G3n, N>M HH is .375 with HARD's `@style-h`, against .705 for EASY with its own.
  That is why G3m keeps his style per tier as shipped.

**The Ichigo rows are solved by his style alone.**
- E>M IK / II go .070 / .035 → .990 / .990 with Ichigo's style flat at HARD's (S2), at any eyes.
- IH needs eyes ≤ 22 as well (.385 at eyes 24 in S2; .81-.85 in the G3 worlds).

**N>E is what pays for the lifts.**
- EASY's generic chances or Ichigo style at NORMAL's, without the fast clash (C1, C1b, R3), get E>M to only 1-5 cells and drop N>E to 2-6
  (KI .185-.77, IH .26-.60).
- The slow-clash family (R1a, R2, R5, C1) never passes more than 3 E>M cells.

## 3. HARD > NORMAL's failing cells (IH, HK)

- **IH** (HARD Ichigo against NORMAL Hisagi; .780 shipped, a pass now) falls to .640-.730 when NORMAL gets HARD's generic chances.
  - It is closed by keeping Hisagi's NORMAL style as shipped rather than HARD's: .850 in G3m / G3m22, .915 in C2.
  - HARD's eyes 4 alone moves it .780 → .745.
- **HK** (HARD Hisagi against NORMAL Kenpachi; .200 shipped) is closed only by a slower or rarer NORMAL clash (Block 1):
  - **`*cai-clash-delay*` :normal 10 → 14** (= its eyes): .790. This is world R1a, the smallest change. Every other H>N cell then passes (IH
    .795, HH .968).
  - `*cai-clash-p*` :normal .35 → .15: .870 (Ncp).
  - Both together (NORMAL's clash = EASY's): .950.
- None of these breaks N>E: R1a's N>E is 8 of 9, with HK at .730 against .770 shipped (145 vs 154 of 200; NORMAL Hisagi's own clash slows
  too).
- But they cap EASY > masher at 0-3 cells, because EASY's clash ≤ NORMAL's.

## 4. Recommended tierings (full 27-cell tables, 200 a cell)

Two tierings are close in count and differ in which rung they give up. Neither passes the bar.

**Two counts.**
- The pass rule above is ladder.py's: Wilson low ≥ .70, i.e. 151 of 200.
- Read at face value, as raw share ≥ .70 (the user's 「至少 70:30」), more cells pass:

| world | Wilson count | raw-share count | the cells that differ |
|---|---|---|---|
| baseline | 17 | 17 | |
| G3m22 | 21 | 23 | E>M HH .705, N>E IH .720 |
| G3m24 | 21 | 23 | E>M HH .700, N>E IH .735 |
| G3n | 20 | 21 | E>M HH .705 |
| R1a | 17 | 18 | N>E HK .730 |

### A. G3m22: 21 of 27 (the most cells; EASY beats the masher in 7 of 9)

| knob | EASY | NORMAL | HARD | shipped |
|---|---|---|---|---|
| `*strat-table-chance*` | 1.0 | 1.0 | 1.0 | same |
| `*ai-delay*` (frames) | 22 | 14 | **4** | 24 / 14 / 8 |
| `*cai-clash-p*` / `*cai-clash-delay*` | .6 / 8 | .6 / 8 | .6 / 8 | .15 .35 .6 / 24 10 8 |
| the other 12 `@cai` knobs (skill, think, turn, cont, Hoho, the exchange's three, the awakening breaks, DRIVE switch, `*strat-lambda*`) | HARD's | HARD's | HARD's | per tier (xch-carry stays a flat .2, today's direction) |
| Kenpachi `@style-k` | shipped NORMAL | HARD | HARD | per tier |
| Ichigo `@style-i` | HARD | HARD | HARD | per tier |
| Hisagi `@style-h` (with `*hb-*`) | shipped | shipped | shipped | per tier |
| `@mc` (incl. `*mc-sure*` 0 / 0 / .16) | shipped | shipped | shipped | |
| `*cai-clash-margin*` | 1.0 (a scalar) | | | |

Every plist is monotone (equality allowed). The generic chances are flat. The tiers differ by eyes, Kenpachi's style (EASY < NORMAL = HARD),
Hisagi's style and the MCTS knobs.

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass |
|---|---|---|---|---|---|---|---|---|---|---|
| H>N | 1.000 [55] | .990 | 1.000 | 1.000 | .995 | .850 | **.045*** [76] | 1.000 | .910 **[196]** | 8 |
| N>E | .995 | .810 | 1.000 | .990 | .780 **[87]** | **.720*** | **.025*** [63] | **.610*** | .823 **[179]** | 6 |
| E>M | .865 | .990 | 1.000 | 1.000 | 1.000 | .840 | **.365*** | 1.000 | **.705*** | 7 |

- Fails:
  - the HK diagonal (Block 1);
  - E>M HK and HH (Block 2);
  - N>E IH (144 of 200) and N>E HI (.610: NORMAL Hisagi against EASY Ichigo, whose HARD style makes him NORMAL's equal at eyes 22).
- Time-outs above 25 %: H>N HH 98 %, N>E HH 90 %, N>E II 44 %, H>N HK 38 %, N>E HK 32 %, H>N KK 28 %.
- EASY's eyes 24 (G3m24) is equally 21 of 27: E>M 7 (HK .205, HH .700) and N>E 6 (IH .735, HI .610). G3m, with EASY's eyes 18, is 20.

### B. R1a: 17 of 27 (one knob from main; the two upper rungs hold, EASY loses to the masher)

The world is main with **`*cai-clash-delay*` (:easy 24 :normal 14 :hard 8)**, i.e. NORMAL's 10 → 14. Everything else is shipped.

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | pass |
|---|---|---|---|---|---|---|---|---|---|---|
| H>N | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | .795 [53] | .790 [66] | 1.000 | .968 **[184]** | **9** |
| N>E | .845 | .965 | .995 | 1.000 | .990 [57] | .910 [74] | **.730*** [63] | 1.000 | .940 [78] | 8 |
| E>M | .000* | .095* | .675* | .000* | .000* | .110* | .000* | .275* [100] | .105* | 0 |

- H>N passes in all 9 cells and N>E in 8. N>E HK at .730 is 5 points short; it was .770 shipped.
- EASY > masher is as shipped, 0 of 9. NORMAL > masher is 3 of 9.
- R5 (R1a plus Ichigo's style flat at HARD's) is also 17: E>M II .875 passes, but N>E KI drops to .630.

**Choice for the lead.**
- A gives the masher rung most of what it can have, but leaves the HK diagonal and the Hisagi middle-rung cells (5 failures above EASY).
- B is the one-knob fix of the two upper rungs, and gives up the masher rung entirely.
- Neither passes the bar. Block 1 says no tiering under these rules can: with every chance EASY ≤ NORMAL ≤ HARD and no per-pairing knob,
  the clash that EASY needs against the masher's Kenpachi is the same clash that lets a lower-tier Kenpachi beat a higher-tier Hisagi.
- What would move the frontier (not a tier knob):
  - a Hisagi table / arm that does not stand in Kenpachi's clash range: his k1 arm passes against K (e947d86d), but it is not in the
    shipped table;
  - a clash rule that reads Hisagi's dead zone on the clashing side as well;
  - a per-character eyes or clash knob, which needs the user's decision because it is a per-character, not per-pairing, knob.

## Files

- Specs: `spec-tier-{e,2,b,h,nk,nk2,x,s,3,r,c,g,g24,d8}.tsv`. A14 (E>M, N>M) and A18 (E>M) from `spec-tier-3` were stopped there; B18 / C18 never ran.
- Runs: `tier/*.json`, and the logs `tier/{x,s,r,c,g,g24,d8}.log`.
- Baseline: `tier/base-501-600.json` (ladder.py). HK cause, per side: `tier/hk-hn-base-full.json`.
