# Every tier on the table: probe of the ladder (PLAN4 bar B, 2026-11-15)

The user (2026-11-15) asked 「為什麼會有模擬問題？不是在做 fuzzy Q table 嗎？」 and chose 「三個難度都用 Q 表」: EASY, NORMAL and HARD
all play the pairing's fuzzy Q table for the whole match. The tiers would then differ only by perception, the per-difficulty chances and the
table's strength. This note measures that world against the bar: 「hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」.
The bar is per cell, by the game's own result, with a draw counting half. The dev rule is PLAN4 §1 B: 151 of 200 (0.755) a cell.

The MCTS timing fix that was briefed first (mcfix) was dropped on the user's change of direction. `cpu-mcts.lisp` was never edited, so there
was nothing to revert. No game code changed here: every world is a load-time binding. Host tests and G2 therefore do not apply.

## Tools (this folder)

- `probe.py --lift 'to=from:knob,...;...'` (new). PROBE_LIFT copies each per-difficulty knob's FROM value into its TO slot. It runs at load,
  after PROBE_SET, and works on a copy of the list. The parts of a lift run in order.
- Knob groups (`probe.lisp` `*pr-groups*`):
  - `@eyes`: `*ai-delay*`.
  - `@cai`: the 14 generic per-difficulty CPU knobs: skill, think, turn / cont / Hoho, the clash's chance and delay, the exchange's three, the
    two awakening breaks, the DRIVE switch and `*strat-lambda*`.
  - `@clash`: `*cai-clash-p*` and `*cai-clash-delay*`.
  - `@style-k`, `@style-i`, `@style-h`: one character's style knobs (`*kk-* *kso-* *khf-*`, `*iks-* *ikw-* *ir2-*`, `*hk*- *hr-* *ihx-*`).
  - `@mc`: the MCTS's per-difficulty knobs.
- `probe.py` now prints a per-cell count of matches that went to the bell. `rungs.sh SEED0 SEEDS SPEC [RUNGS]` runs the ladder rungs per spec
  line (`name<TAB>set<TAB>lift`; PAIRS=... narrows the cells). `holds.py` prints each run's MCTS-hold steps.
- Seeds: dev only. Probes use 501-520 (40 a cell, about ± 0.07). The candidate was confirmed on 501-600 (200 a cell).
  - Spec files: `spec-at`, `-nbind`, `-ncai`, `-ncl`, `-ecl`, `-x`, `-n`, `-h`, `-e`, `-f`, `-g`, `-hh`, `-g3e`, `-g3w`, `-g3t`, `-dev`.
  - Runs: `runs/<hi>-<lo>-<name>-500.json`. The G3 / G3t75 files hold the 200-a-cell runs.
- Cell names: the higher tier's character first. In "EASY > masher" the cell IH means an EASY Ichigo against a masher Hisagi.

## 1. Table chance 1.0 at every tier, nothing else changed (T1; 40 a cell)

| rung | today (base) | T1 | T1 with the MCTS off (`*mc-on*` nil) | T1 with `*mc-sure*` 0.16 at every tier |
|---|---|---|---|---|
| EASY > masher | 0.072 | **0.153** (KK .03 KI .08 KH .78 IK 0 II .08 IH .18 HK 0 HI .13 HH .13) | 0.175 | 0.172 |
| NORMAL > masher | 0.556 | **0.747** (KK .05 IK .80 IH .50 HK .78) | 0.719 | 0.750 |
| HARD > masher | 0.994 | 0.994 | 0.994 | 0.994 |
| NORMAL > EASY | 0.981 | 0.928 (KI .73 HK .80) | 0.961 | 0.953 |
| HARD > NORMAL | 1.000 | 0.994 (HK .95) | 0.994 | 0.989 |

**The style CPUs still hand neutral to the MCTS.**
- In `core-brain-step`, a strategy's `:fn` (the arm's style) runs before `mc-neutral`. Every style returns NIL wherever it does not steer:
  - `cpu-kh-ken.lisp`, `cpu-hk-hisagi.lisp` and `cpu-hisagi-range.lisp` say so in their headers ("NIL leaves the step to the in-game MCTS");
  - the Ichigo styles fall through the same way.
- On a NIL step the MCTS decides, and at EASY / NORMAL (`*mc-sure*` 0) it holds for the perception delay. HARD stays out of it through
  `*mc-sure*` 0.16 and `*mc-off-at*` (Ichigo).
- Steps a match in MC-FULL-REQUEST's hold (probe `hold`):

| tier | today | T1 |
|---|---|---|
| EASY | 2290 (vs masher) / 2484 (vs NORMAL) | 841 / 647 |
| NORMAL | 1198 (vs masher) / 688 (vs HARD) | 440 / 299 |
| HARD | 7 | 3-7 |

- The hold is no longer what costs the most on the table. Turning the MCTS off entirely (T1off, 0 hold steps) moves EASY > masher only
  0.153 → 0.175 and NORMAL 0.747 → 0.719; the masher's openers just move to a free, awake CPU.

**What this shows about today's tables** (item 4).
- Today's nine tables have constant q rows (`(0 -0.05 -0.05 -0.05)`), so "playing the table" means playing arm 0's style with its `:base`
  for the whole match. Arm 0 keys come in two kinds:
  - **Scales on the tier's own chance** (`cai-roll` / `strat-scale`): `:clash-p 1.7`, `:xch-sa-p`, `:xch-carry-p`, `:awaken-break-p`, `:hoho`,
    `:cont`. They keep the tier differences, multiplied.
  - **Replacements** (`style-dif` / `strat-out`): `:ns`, `:range` and the style keys (`:kk-step-p 1.0`, `:kk-lunge-p`, `:kk-reach-p 0.5`,
    `:kso-stale 60`, `:iks-gap-p 1.0`, `:iks-wait-max 40` ...). They are the same at every tier.
- So on the table the tiers differ only by:
  - their eyes;
  - the clash delay;
  - the generic chances' tier values (scaled);
  - the style knobs that arm 0 does not name (for Kenpachi's KI arm 0: `*kk-dodge-p*`, `*kk-wake-hoho-p*`, `*kk-ns-stop-p*`, `*kk-link-p*`,
    `*kk-meaty-p*` ... at 0 / 0-0.3 / 1.0);
  - the MCTS knobs, hold included.
- The table alone narrows NORMAL > EASY only slightly (0.98 → 0.93) and leaves HARD > NORMAL at 0.99. It lifts EASY and NORMAL against the
  masher by 0.08 and 0.19.
- **A weaker table for EASY cannot be emulated by arm choice.** With constant q, "arm 0 only" or "no none arm" is what every tier already
  plays. The cheap lever is `*strat-table-chance*` :easy strictly between 0 and 1: windows of 10 s, each arm 0 or the none arm (generic CPU
  plus MCTS), with one deterministic roll per window. That is G3t75 below.

## 2. The binding cells: the masher's Kenpachi rows (T1, 40 a cell)

NORMAL > masher Kenpachi (cells KK, IK, HK), with one part of HARD's at a time:

| NORMAL world | KK | IK | HK | all |
|---|---|---|---|---|
| T1 (eyes 14) | .05 | .80 | .78 | .542 |
| eyes 10 / 8 | .20 / .65 | .93 / .98 | .88 / 1.0 | .667 / .875 |
| HARD's `@cai` (eyes 14) | .88 | 1.0 | 1.0 | .958 |
| ... clash alone (chance and delay) / delay 8 / chance 0.6 | .70 / .33 / .20 | .98 / .95 / .90 | 1.0 / 1.0 / .98 | .892 / .758 / .692 |
| ... skill / think / exchange / turn-cont-Hoho / awakening | .10 / .18 / .23 / .05 / .10 | | | .51-.67 |
| HARD's `@style` (all three characters) | 1.0 | .98 | **.23** | .733 |
| HARD's `@mc` | .05 | .73 | .78 | .517 |
| eyes 8 + `@cai` / eyes 8 + `@style` | .95 / 1.0 | 1.0 | 1.0 | .983 / 1.0 |

- **NORMAL > masher ≥ 0.9 in every cell is reached** with HARD's `@cai` plus Kenpachi's and Ichigo's style knobs at eyes 14 (world Ne:
  0.994, every cell ≥ 0.95). It is also reached with eyes 8 plus `@cai` or `@style`.
- At eyes 14, Hisagi's HARD style knobs hurt (HK 0.23): they pay off only with fast eyes.
- The clash is the masher's counter. EASY with HARD's clash and nothing else (eyes 24) goes from 0.153 to **0.581**; with eyes 14 as well,
  0.761. The clash reads its own snapshot at `min(eyes, *cai-clash-delay*)`, so at a delay of 8 it is the CPU's fastest reaction.
- **EASY's binding cells are not only the masher Kenpachi rows** (a correction to the brief). IH (an EASY Ichigo against a masher Hisagi) is
  the worst: 0.18-0.53 until Ichigo's style knobs reach HARD's. II and HH are also weak while EASY's eyes are 18-24.

## 3. Whole tierings (EASY ≤ NORMAL ≤ HARD in every knob; no per-pairing knob; the masher untouched)

The best world found is **G3**. Written per tier (every tier on the table):

| knob | EASY | NORMAL | HARD | today |
|---|---|---|---|---|
| `*strat-table-chance*` | 1.0 (G3t75: 0.75) | 1.0 | 1.0 | 0 / 0.5 / 1 |
| `*ai-delay*` (frames) | 18 | 14 | **4** | 24 / 14 / 8 |
| the 14 `@cai` knobs | HARD's | HARD's | HARD's | per tier |
| ... e.g. `*fz-skill*` / `*cai-think*` / `*cai-clash-p*` / `*cai-clash-delay*` | 1.0 / 12 / 0.6 / 8 | same | same | .3 .62 1 / 34 22 12 / .15 .35 .6 / 24 10 8 |
| Kenpachi `@style-k` | today's NORMAL | HARD's | HARD's | per tier |
| Ichigo `@style-i` | HARD's | HARD's | HARD's | per tier |
| Hisagi `@style-h` | today's EASY | HARD's | HARD's | per tier |
| `@mc` (incl. `*mc-sure*` 0 / 0 / 0.16) | today's | today's | today's | |

- Monotone in every knob. The generic chances are flat: the tiers differ by eyes, two characters' style knobs and the MCTS knobs.
- HARD's eyes go *faster* than today (8 → 4). Without that, HARD > NORMAL fails HK / HH as soon as NORMAL gets HARD's clash (Na 0.63, X2a
  0.63 / 0.73). HARD > masher stays 0.999.
- Resulting hold per match (G3, 40 a cell): EASY 386, NORMAL 142-197, HARD 2.

**G3 at dev size (seeds 501-600, 200 a cell, both seats; in brackets: matches at the bell, of 200 when over 25 %):**

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH | all |
|---|---|---|---|---|---|---|---|---|---|---|
| EASY > masher | .880 | .990 | 1.00 | 1.00 | 1.00 | .805 | 1.00 | .980 | .895 | .950 |
| NORMAL > masher | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | .995 | 1.00 | 1.00 | .920 | .991 |
| HARD > masher | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | .995 | .999 |
| NORMAL > EASY | .970 | .910 | 1.00 | .985 | .780 [123] | .980 | **.535** [71] | **.475** | .880 | .835 |
| HARD > NORMAL | .905 | 1.00 | 1.00 | 1.00 | .965 | .950 | .990 | .870 | **.690** | .930 |

**24 of the bar's 27 cells pass; 3 fail** (NORMAL > EASY HK and HI, HARD > NORMAL HH). Two more are flagged for time-outs (NORMAL > EASY II
62 %, HK 36 %).

**G3t75** (EASY on the table 75 % of the windows), 200 a cell:
- EASY > masher: KK .690, IH .600, the rest ≥ .90.
- NORMAL > EASY: HK .725, HI .720, II .910, the rest ≥ .84.
- HARD > NORMAL: as G3.
- So 22 of 27 pass. The table chance trades along one axis: at 0.5 (40 a cell), NORMAL > EASY passes every cell but EASY > masher KK falls
  to .475 and IH to .525.

**Why no world passes all 27** (the frontier, 40-a-cell probes):
- **Hisagi as the higher tier is the wall.** NORMAL Hisagi must beat EASY Kenpachi / Ichigo, and HARD Hisagi must beat NORMAL Hisagi /
  Ichigo / Kenpachi:
  - With NORMAL at eyes 14, NORMAL > EASY HK / HI stay 0.30-0.63, whatever EASY's eyes (18-24) or a weaker EASY generic set (G3e20-24, E6a-d).
  - With NORMAL at eyes 12 those pass (G1: .83 / .68), but HARD > NORMAL KH, HI and HH fall to .63 / .60 / .55. HARD's eyes 2 do not help
    (G1h2: .68 / .73 / .60).
- **The rungs pull on the same knobs.**
  - EASY needs the fast clash and Ichigo's HARD style knobs to beat the masher's Kenpachi and Hisagi (KK, IH).
  - Those same parts make EASY Kenpachi and EASY Ichigo strong against a NORMAL Hisagi.
  - Every lever tried that fixed NORMAL > EASY HK / HI (eyes 12, table chance 0.5, EASY's Ichigo style at today's NORMAL) broke EASY > masher
    IH / KK or HARD > NORMAL.
- Within the admissible, per-tier (not per-pairing) knobs probed here, the bar is reached in 24 of 27 cells, not all. What is left is a
  matchup gap: the Hisagi CPU is weaker than the Kenpachi and Ichigo CPUs at equal tier.
  - Closing it likely needs Hisagi's own CPU stronger: his arms, or style knobs that work at 14 frames. That is the T0 table search's job in
    PLAN4, not a tiering knob.
  - Alternatively, a new knob kind, eyes per character and tier, which would need the lead's decision.

## 4. Summary for the lead

- All tiers on today's tables: EASY > masher 0.153, NORMAL > masher 0.747, NORMAL > EASY 0.928, HARD > NORMAL 0.994. Neutral still reaches the
  MCTS (hold: EASY 841, NORMAL 440, HARD 7 steps a match), but turning it off moves the shares by ≤ 0.03.
- Binding cells: NORMAL > masher ≥ 0.9 everywhere is reachable (HARD's generic knobs plus Kenpachi's and Ichigo's style knobs at eyes 14, or
  eyes 8). EASY > masher ≥ 0.70 is reachable (G3: ≥ 0.805 every cell at 200 a cell) once EASY gets HARD's clash and Ichigo's style knobs.
- The tiering sketch G3 (EASY 18 / NORMAL 14 / HARD 4 frames; flat generic chances; style knobs EASY < NORMAL = HARD) passes 24 of 27 cells
  at dev size.
  - It fails NORMAL > EASY HK (.535) and HI (.475), and HARD > NORMAL HH (.690).
  - It is not a shippable set. It shows where the remaining gap is: the Hisagi rows.
