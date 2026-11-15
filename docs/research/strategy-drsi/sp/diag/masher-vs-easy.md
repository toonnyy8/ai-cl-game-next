# Why the masher beats EASY (and half of NORMAL): diagnosis, PLAN4 bar B (2026-11-15)

The user's bar (2026-11-15): 「hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」. B1's first dev ladder
(`b1-masher.md`): EASY > masher 0.00-0.06 in 8 of 9 cells, NORMAL > masher 0.53, HARD > masher 1.00. This note says why, with numbers, and
what knobs can and cannot do. Read-only on game code: every probe is a load-time binding (`PROBE_SET`) in a tool-side runner.

## Tools (this folder)

- `probe.lisp`: strat-run's pairing gate with `STRAT_DIF_P<n>` = easy / normal / hard / masher, the combat log on, and per match and side one
  `pstat` line:
  - steps by state;
  - the combos he opened, by what the victim was doing the step before (`on_*`): `deaf` = free, his CPU holding no button while an MCTS plan is
    pending (the reaction hold), `deafact` = free in an MCTS `:wait` / walk, `free`, a move's `up` / `act` / `rec` by class, or a state;
  - the steps he was deaf (`deaf`, of which `hold` = the MCTS reaction hold);
  - neutral first moves (`first`: the first to start a move out of a step where both were free) and how many led to his own opener (`firstwin`);
  - hits, starts and damage by the game's own class (`k_*`).
- `probe.py` parses that and the combat log (Kikon / Soul Break Konpaku, Bursts by mode, SP paid, cancels, clashes, refusals). `ablate.sh` runs one
  probe per line of a `spec-*.tsv`. `compare.py` prints runs side by side. Raw totals are in `runs/*.json`.
- Seeds: dev only. Base runs 501-540 (720 matches a tier, 9 pairings x 2 seats), probes 501-520 (360). One run takes 7-40 s at `-j 22`. Build:
  this branch (p4-b1-masher's code).
- `PROBE_SET` binds both seats, so a probe of a shared knob is the whole world after the change.

## 1. Base numbers (seeds 501-540, per match unless marked)

| | EASY | masher | NORMAL | masher | HARD | masher |
|---|---|---|---|---|---|---|
| tier's share | **0.071** | | **0.533** | | **0.997** | |
| combos opened | 37.5 | **84.3** | 53.2 | 68.6 | 42.7 | 19.8 |
| ... of which on a CPU in its MCTS reaction hold | | **44.5** | | 19.6 | | 0.1 |
| ... on a free, awake CPU | | 15.3 | | 17.2 | | 6.0 |
| ... punishing the CPU's NS recovery | | 8.3 | | 9.0 | | 2.5 |
| CPU's steps deaf (in the hold) | **2417 (2309)** | | 1330 (1190) | | 7 (7) | |
| CPU's idle steps | 3786 | 1682 | 3434 | 1792 | 2256 | 895 |
| neutral first moves (led to own opener) | 10.5 (5.6) | **66.4 (40.2)** | 15.0 (9.7) | 57.3 (28.9) | 8.4 (5.7) | 26.9 (7.2) |
| CPU's clashes (積極相消) | **0.1** | | 11.6 | | 13.1 | |
| CPU's exchange answers (`cpu xch`) | 6.0 | | 17.9 | | 16.1 | |
| Reishi damage dealt | 2575 | 4172 | 4641 | 3527 | 4674 | 1003 |
| ... by NA | 534 | **2158** | 1107 | 1883 | 1452 | 498 |
| Konpaku taken by Kikon / Soul Break | 1.3 / 1.0 | 0 / **8.6** | 4.7 / 2.3 | 0 / 6.2 | 4.7 / 4.3 | 0 / 0.3 |
| Hoho (perfect) | 4.8 (1.6) | 11.4 (0.5) | 3.8 (1.0) | 11.5 (0.6) | 2.5 (1.1) | 5.4 (0.8) |
| Burst blue / orange / white | 1.3 / 0 / 0 | 1.1 / 4.4 / 2.3 | 3.4 / 0 / 0.3 | 2.4 / 4.0 / 2.7 | 1.4 / 0 / 0.4 | 3.6 / 1.6 / 1.6 |
| SP refused | 0 | 3.8 | 0 | 4.0 | 0 | 2.1 |

**The masher's character** (seeds 501-540, the three cells in which he plays that character, 240 matches each):

| | vs masher Kenpachi | vs masher Ichigo | vs masher Hisagi |
|---|---|---|---|
| EASY | 0.000 | 0.013 | 0.200 |
| NORMAL | 0.225 | 0.746 | 0.629 |

- A masher Kenpachi beats NORMAL 78 % of the time.
- His NA hits do 23 Reishi each (Ichigo's 16).
- He reaches Nozarashi's AS3 / AS4 (`KE-S-BURST1` / `-2`, 100 dmg) about 4 times a match, from the press count alone.
- No per-pairing knob may touch this.

## 2. The causes, ranked

**C1. The MCTS reaction hold makes EASY and NORMAL deaf.** This is the mechanism; its root is a code path, not a chance.
- At EASY and NORMAL, `*mc-sure*` is 0, so the in-game MCTS takes every neutral decision. `mc-full-request` then holds no button for
  BRAIN-DELAY steps (24 / 14 / 8) while its full-sim rollouts run.
- In `core-brain-step`, a held press (`press-left > 0`) is the cond's first branch. It takes the whole step, so the exchange answer, the clash and
  the Hoho never run during the hold.
- That hold is a second reaction delay stacked on the perception's own: the CPU sees the masher 24 frames late, and on top of that cannot answer
  for 24 frames after each decision.
- EASY is deaf 2309 steps a match, 62 % of its free time. More than half of the masher's openers against EASY (44.5 of 84.3) land inside the
  hold. Against NORMAL it is 19.6 of 68.6; against HARD 0.1.
- HARD is shielded because its strategy table's style function decides before the MCTS (the cond runs `now`'s `:fn` first). With the table off
  (`*strat-lookup*` nil), `*mc-off-at*` for Ichigo and `*mc-sure*` 0.16 keep it out of the MCTS.
- Two walks measure it. The effects are order-dependent:
  - **HARD walked to EASY**, cumulative (`spec-walk.tsv`): HARD 0.997 → no table 0.978 → eyes 24: 0.911 → **`*mc-sure*` 0 (every decision the
    MCTS's, a 24-frame hold): 0.606** → **`*mc-off-at*` nil (Ichigo into it too): 0.381** → skill 0.3 and think 34: 0.178 → EASY's chances
    (clash, exchange, turn, cont, Hoho, awakening): 0.078 → MCTS iterations / tau / budget: 0.072 (= EASY's 0.071, so the walk is complete).
    Putting a 24-frame CPU under the MCTS costs 0.53 of the 0.92.
  - **EASY walked to HARD**, cumulative (`spec-rwalk.tsv`): EASY 0.071 → HARD's chances 0.133 → skill and think 0.328 → **eyes 8 (hold 8):
    0.929** → MCTS deferral 0.967 → MCTS iterations 0.964 → table 0.956.
  - Both walks say the same thing. Long eyes combined with an MCTS that holds for the eyes' length is what loses: 24 frames x MCTS costs -0.31
    to -0.60, whichever was added last.
- **Upper bound of a fix.** `*mc-full*` nil drops the full sim and with it the hold (a global switch, not a candidate; see §4). It raises EASY
  0.071 → 0.256 and **NORMAL 0.533 → 0.750**.
- With the hold gone, EASY's clash at NORMAL's values adds 0.11 (c1 0.369). The clash only helps once the CPU can hear.

**C2. EASY cannot answer a J at all; the threat is faster than its eyes.** This is what is left once the hold is removed.
- The masher's J1 hits about 9 frames after it starts. `*cai-clash-delay*` EASY 24 reads a snapshot older than the J's active end, so the
  clash's live-window test never passes: 0.1 clashes a match (NORMAL 11.6 with 10 frames, HARD 13.1 with 8).
- With the MCTS switched off entirely (`*mc-on*` nil, 0 deaf steps), EASY still scores 0.069. The masher's openers simply move to a free,
  awake EASY: `on_free` 15.3 → 58.4.
- One HARD part given to EASY, alone (`spec-hard-parts.tsv`): eyes 8 → **0.464**; skill 1.0 → 0.228; the table → 0.153; HARD's clash (delay 8,
  chance 0.6) → 0.114; think 12, turn, the exchange, the MCTS budget → 0.06-0.08 each.
- NORMAL's eyes alone (`spec-nd.tsv`): 14 → 12 / 10 / 8 gives NORMAL vs masher 0.606 / 0.706 / **0.853**. Its 14 frames are just slower than a
  J's 9 + 3.

**C3. Initiative.** The masher starts first and EASY never does.
- In a stretch where both are free, the masher makes the first move 66.4 times a match against EASY's 10.5. 60 % of those lead to his opener
  (NORMAL 50 %, HARD 27 %).
- The masher acts every 3-23 frames. EASY decides every 34 + U(0, 12) frames (`*cai-think*`), or after a 24-frame hold plus a 20-frame
  `:wait` / walk.
- Given NORMAL's think alone, EASY gains nothing (0.061 with think 12). Initiative is a consequence of C1 and C2, not a separate knob.

**C4. Damage sources: no CPU-only or hold advantage for the masher.**
- The masher wins on NA strings that chain on hit: 2158 of his 4172 Reishi a match. Reishi at 0 is a Soul Break, 8.6 Konpaku a match.
- He never lands a Kikon (0.0 a match): his 2-12 frame holds rarely outlast the 12-frame confirm. EASY lands 0.8.
- His SP is refused 3.8 times a match at 0 (DUEL_SP's rule, as for a human). His SP paid / cost is 83 %, the same as the CPUs'.
- His P presses do give him something every CPU tier leaves unused: orange Bursts 4.4 a match (free SP, startup cut) and white 2.3. The CPU
  never bursts orange and bursts white 0.0-0.4 times a match. This is real but second-order: HARD wins 1.00 against the same Bursts.
- **"The masher's own help" is killed.** It presses through the same vpad and rules, `brain-off` aside.

## 3. Candidate knobs (admissible: EASY <= NORMAL <= HARD in every chance; delay frames EASY >= NORMAL >= HARD; no per-pairing knob; masher frozen)

**The ceiling first.** EASY can be at most NORMAL on every knob, so its score against the masher is capped near NORMAL's.
- EASY with all of NORMAL's values (c4, with the hold removed) scores 0.553; NORMAL's own score is 0.533. **No EASY-only change can pass while
  NORMAL sits near 0.53.**
- So NORMAL must move up first, spending HARD > NORMAL's slack (1.00 today). EASY then follows, with NORMAL > EASY rechecked at each step.

Probes (seeds 501-520, 360 matches a rung, both seats bound; cells in ladder order KK KI KH IK II IH HK HI HH):

| world | EASY > masher | NORMAL > EASY | NORMAL > masher | HARD > NORMAL |
|---|---|---|---|---|
| today | 0.071 (0 .0 .58 0 0 0 0 .05 .03) | 0.92-1.00 (B1, 200 a cell) | 0.556 | 1.00 |
| W0: `*ai-delay*` (:easy 8 :normal 8 :hard 8) | 0.464 | 0.883 (IH .675) | 0.853 | 0.992 |
| W1: W0 + EASY `*fz-skill*` 0.3 → 0.62, `*cai-think*` 34 → 22 | 0.578 | 0.681 | 0.853 | 0.992 |
| W2: W0 + every EASY chance at NORMAL's (skill, think, clash 10 / 0.35, turn, cont, Hoho, exchange, awakening) | 0.711 (KK .40, IK .25, IH .475 fail) | 0.614 | 0.853 | 0.992 |
| W3: W2 with EASY's eyes 10 | 0.553 | 0.751 (IH .30) | 0.853 | 0.992 |
| W4: W2 + `*strat-table-chance*` :normal 0.5 → 1.0 | 0.711 | 0.761 (KI .65, IH .425) | 0.919 | 0.908 (HK .45) |

Ranked by expected effect:
1. **`*ai-delay*` :normal 14 → 8** (EASY's 24 → 8-10 with it). The one lever large enough: NORMAL vs masher 0.53 → 0.85, HARD > NORMAL still 0.99.
   - It works because it shortens the deaf hold as well as the eyes.
   - It erases the difference in eyes between NORMAL and HARD. Whether that is acceptable is the user's call: Q2 asked whether HARD > NORMAL
     is too steep.
2. **EASY's skill and think at NORMAL's** (`*fz-skill*` :easy 0.3 → 0.62, `*cai-think*` 34 → 22): +0.11 on top of W0, but NORMAL > EASY falls
   0.88 → 0.68.
3. **EASY's shared chances at NORMAL's** (W2): +0.13 more, NORMAL > EASY 0.61.
4. **`*strat-table-chance*` :normal 0.5 → 1.0** (and :easy stays 0). This widens NORMAL over EASY again (0.61 → 0.76) and NORMAL over the
   masher (0.92), but costs HARD > NORMAL in HK (0.45).

**No admissible knob world passes every cell.**
- The best one, W4, averages EASY > masher 0.71, NORMAL > EASY 0.76 and HARD > NORMAL 0.91.
- Even so, 3 cells fail on the first rung, 2 on the second and 1 on the third (n = 40 a cell, so each cell value is about ± 0.07).
- The masher Kenpachi cells (KK, IK, HK) are the wall: even NORMAL with eyes 8 takes KK only 0.475.
- And each step that lifts EASY narrows NORMAL > EASY by about as much, because the two rungs pull on the same knobs.

## 4. Recommendation

1. **Fix the hold in code (shared, needs the lead's decision; not a knob).** Let the reactive branches (`cai-xch-step`, `cai-clash`, the Hoho
   test) run while an MCTS reaction hold is pending, or drop the plan when a threat is perceived.
   - This removes C1 at every tier without touching any difficulty's chances or eyes, and keeps the user's §12 decision (the full sim at every
     difficulty).
   - `*mc-full*` nil is its upper-bound probe: EASY 0.256, NORMAL 0.750. It is a global switch that reverses DUEL_AI_MCTS §12 and moves G2
     (the gate plays NORMAL), so it is not offered as a knob.
2. **Then rerun this probe set on the fixed build**, and only then spend knobs in the order NORMAL up (eyes 14 → 10-8, the table chance), then
   EASY toward NORMAL (eyes, skill, clash), rechecking NORMAL > EASY at each step.
   - PLAN4 §5's knob order (table chance, eyes, chances) stays.
   - Its premise that one knob can close EASY > masher does not hold: the gap is 0.07 → 0.75, and today's NORMAL is only at 0.53.
3. **Report to the user at CP1** that the masher Kenpachi is about as strong as NORMAL (78 % of NORMAL's matches). The rung may need the fix in
   step 1 plus a stronger NORMAL, not a tuned EASY.

Nothing here touched game code; `git status` shows only this folder.
