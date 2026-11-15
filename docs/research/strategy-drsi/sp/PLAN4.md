# Plan 4: tables that switch again, a difficulty ladder, DUCT as the anchor (DUEL_AI_STRATEGY §11, requested 2026-11-15)

The user (2026-11-15):
- 「為什麼規則又變這麼少？你還記得我之前對規則的要求嗎」, then 「完整重做」.
- 「不要與固定表比較，請設計讓勝率能做到 hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率。」
- 「然後以 DUCT 作為強度錨點」, read as "DUCT as a fixed reference" (not HARD playing DUCT, not a teacher).

Standing rules this plan restores (2026-11-09, DEVLOG §668-§671, DUEL_AI_STRATEGY §8.19; 2026-11-10, §697-§701):
1. a table switches strategies inside a match;
2. distance and the other state details are fuzzy rules inside the table;
3. a judgement every 0.5 s (`:period 30`);
4. per character 3-5 general arms, each owning one kind of situation, plus 1-2 targeted arms per pairing;
5. one arm, one job; an arm may switch on several single-job rule units.

PLAN.md, PLAN2.md and PLAN3.md stand only where this file does not replace them. It replaces the rule base, the arms, the fit, every
acceptance bar and the order. Guesses are marked. Nothing here is built.

## 0. Where we are, and the probes run for this plan

- Every shipped HARD table is constant in play (`band.py fallback`: arm 0 at 0, the rest at -0.05). `:rb-sp` has 42 rules; `:ored`, `:awk`,
  `:wall`, `:oawk`, `:gauge` were dropped on 2026-11-14 and never came back (§11.3, §11.4).
- The arms of PLAN / PLAN3 are whole-game refinements of one style (the newest dominates the older), so a table had nothing to choose (§11.10,
  `sp/fit/README.md`).

**Probes** (2026-11-15, native sim, HARD unless said, about 25 CPU-min; drivers were scratch files, not kept; sim build
`c8bc90c8381c` = strategy-switch's hash at 8eb1ce26; seeds 501-600, the spare block, now partly spent):

**P1. The ladder today** (tier against the tier right below; the pairing gate under `strat-run.lisp` with `STRAT_DIF_P1` / `_P2`;
seeds 501-520, both seats, 40 matches a cell; "higher" = the higher tier's character):

| Higher vs lower | HARD vs NORMAL: K.O. hi : lo, bell | NORMAL vs EASY: K.O. hi : lo, bell hi : lo | NORMAL's share, K.O.-only / bell lead counted |
|---|---|---|---|
| K vs K | 40 : 0 | 40 : 0 | 1.00 / 1.00 |
| K vs I | 40 : 0 | 38 : 0, 2 : 0 | 0.95 / 1.00 |
| K vs H | 40 : 0 | 39 : 0, 1 : 0 | 0.97 / 1.00 |
| I vs K | 40 : 0 | 37 : 0, 3 : 0 | 0.93 / 1.00 |
| I vs I | 39 : 0, 1 to HARD | 14 : 1, 24 : 1 | **0.35** / 0.95 |
| I vs H | 40 : 0 | 23 : 0, 15 : 2 | **0.57** / 0.95 |
| H vs K | 40 : 0 | 35 : 3, 2 : 0 | 0.88 / 0.93 |
| H vs I | 40 : 0 | 39 : 0, 1 : 0 | 0.97 / 1.00 |
| H vs H | 40 : 0 | 35 : 0, 5 : 0 | 0.88 / 1.00 |

  HARD beats NORMAL 359 of 360 by K.O. NORMAL beats EASY 93-100 % when a lead at the bell counts, but only 35 % (II) and 57 % (IH) by
  K.O.s alone. So the two upper rungs already clear 70:30 by a wide margin under the game's own result; the open rung is EASY against the
  masher, which does not exist.

**P2. Job arms, played whole** (`eval.py`, seeds 501-520, both seats, 40 matches a column; K.O. wins - losses - time-outs; "table" = the
opponent's shipped HARD table, "none" = his plain CPU). Each arm is the side's shipped arm with a few keys changed:

| Arm (keys over the incumbent) | vs K: none / table | vs I: none / table | vs H: none / table |
|---|---|---|---|
| Ichigo incumbent | 40-0-0 / 33-7-0 | | 40-0-0 / 38-2-0 |
| Ichigo, one episode mode at weight 1: `generic` | 40-0-0 / 38-2-0 | | 37-3-0 / 22-18-0 |
| `space` | 40-0-0 / 40-0-0 | | 24-5-11 / 29-11-0 |
| `whiff` | 40-0-0 / 35-5-0 | | 39-1-0 / 38-2-0 |
| `ptr3` | 40-0-0 / 34-6-0 | | 40-0-0 / 35-4-1 |
| `kessa` | 40-0-0 / 35-5-0 | | 39-0-1 / 37-2-1 |
| Kenpachi incumbent | | 31-8-1 / 7-33-0 | 40-0-0 / 20-20-0 |
| Kenpachi `rush` (Hoho in, Step in, safety off) | | 33-7-0 / 0-40-0 | 40-0-0 / 25-13-2 |
| `guard` (brawl read, dodge, back Step, no lunge) | | 25-10-5 / 8-32-0 | 40-0-0 / 21-10-9 |
| `bankai` (climb, Bankai, awaken) | | 14-26-0 / 1-39-0 | 36-4-0 / 16-24-0 |
| Hisagi `a-hisagi-merged` / `-press` / `-kite` | 37-3-0 / 0-7-33; 40-0-0 / 0-15-25; 32-3-5 / 0-14-26 | 25-2-13 / 7-32-1; 21-6-13 / 6-30-4; 39-0-1 / 18-19-3 | |
| Hisagi `-dswitch` / `-pressd` | 38-2-0 / 0-6-34; 39-1-0 / 0-18-22 | 35-1-4 / 10-29-1; 32-1-7 / 9-22-9 | |
| Hisagi `c-ih-h-r1-b2a0` (IH's shipped arm) | 36-4-0 / 0-40-0 | 40-0-0 / 2-38-0 | |
| Hisagi `x-kh-h-r2-b3a1` (KH's shipped arm) | 39-0-1 / 20-20-0 | 31-0-9 / 9-20-11 | |
| Hisagi `a-hk-all` / `h1-range` | 32-0-8 / 0-15-25; 30-10-0 / 0-40-0 | 16-0-24 / 7-29-4; 38-2-0 / 3-37-0 | |

  Reading (SE about 0.07 a cell): Ichigo has five one-job arms from one style function that all K.O.; Kenpachi's profiles are playable against
  Hisagi and are situational at best against Ichigo; Hisagi has one arm family that K.O.s Kenpachi's table (`hisagi-hk-style`) and none that
  beats Ichigo's (the best, `kite`, 18 of 40). Hisagi is where the arm work goes.

**P3. A hand-written job table plays as well as its arms and switches.** Ichigo vs Kenpachi, `:rb-sp`, arm 0 the incumbent; `whiff` owns
(sealed, mid), `space` (sealed, far), `kessa` (awakened); +0.06 in its rules, -0.06 in the rest of G1; `:keep-state t :margin 0.02 :period 30`.
Seeds 521-600, both seats, 160 matches a column:

| | vs K's `none` | vs K's shipped table |
|---|---|---|
| the job table | 160-0-0 | **148-12-0** |
| incumbent / `space` / `whiff` / `kessa` whole | 160-0-0 each | 144-16-0 / 149-11-0 / 151-9-0 / 145-15-0 |

  On 521-540 (`sw.py measure`, 40 matches): **38.4 arm changes a match** (median 37, no match without one), 131 judgements a match, arm
  shares 0.27 / 0.15 / 0.11 / 0.48. Arms that share a style function switch at no measurable cost.

**P4. Today's strategy layer (the DUCT of §5 / §8.4) is not an anchor as it stands.** `STRAT_LAYER=<character>` against the opponent's
shipped HARD table, seeds 501-510, 10 matches a row: Kenpachi's layer 0 of 20 (KI both seats), 0 of 10 (KH); Hisagi's 0 of 10 (HK), 0 of 10
(HI); Ichigo's 9, 9 (IK both seats), 7 (IH) of 10. It chooses among all 46 `*strat-library*` entries (old tables included) and is seeded
from the 2026-11-08 `*strat-payoff*` (old ids), so Kenpachi plays `:ki-ken` every selection. Cost: 7-10 ms a selection (8 rollouts x 150
steps), 54-83 selections a match, 0.6-1.2 CPU-s a match (a plain match: about 0.3). So no "today's tables against DUCT" number exists
that means anything; the first one comes at step D2 (§6).

## 1. Acceptance (replaces PLAN2 §3's and PLAN3's ship test)

No comparison with today's constant tables anywhere. A new table ships when all of A-D hold.

**A. It switches** (HARD, against the opponent's new HARD table, seeds 801-1000, both seats, 400 matches a row, all nine rows):
- no match without an arm change; median arm changes a match >= 10;
- at least 3 arms each hold >= 10 % of the judgements, none above 70 %;
- each arm's share inside its declared job rules is at least twice its share outside (the division of labour, §3);
- reported: arm shares by form x distance band, judgements and changes a match.

**B. The ladder** (the user's bar). 27 cells = 9 (higher's character, lower's character) x 3 rungs (HARD > NORMAL, NORMAL > EASY, EASY >
masher), mirrors included, each cell on both seats.
- A match's result is **the game's own**: a K.O., or at the bell more Konpaku, then Reishi %. A draw counts half. (Checkpoint Q1: P1 shows
  it matters for NORMAL > EASY in II and IH.)
- Final: seeds 801-1000, both seats, **400 matches a cell**, run once. Pass: the higher tier's share >= 0.70 with a one-sided 95 % Wilson
  lower bound >= 0.70, which is **>= 296 of 400** (0.74). Dev runs: seeds 501-600, 200 a cell (151 of 200 by the same rule), as often as needed.
- Time-outs are reported per cell. A cell with more than 25 % of its matches at the bell is flagged in the report, not failed.
- If the final fails a cell after a retune, the second look runs on 601-800 and is reported as a second look.

**C. Against DUCT** (§6): every tier's share against the frozen DUCT, per ordered pairing and both seats, 200 matches a cell on 801-1000
(seeds 801-900 x 2 seats), beside DUCT against DUCT on the same seeds. The target for HARD is checkpoint Q3.

**D. Health and determinism**:
- HARD against HARD, cross pairings: K.O. rate >= 90 % (mirrors reported; II is 5 % and HH 0 % in self-play with the 2026-11-15 arms);
- each raw table = the live lookup bit for bit (`sp/final/proofs.sh`); the start table of each fit = its arm 0 raw;
- host tests, pkgcheck, snaptest / fulltest (`FT_LAYER=t` too), `./build.sh duel`, smoke, G2 regenerated once (NORMAL plays the tables);
- EASY <= NORMAL <= HARD for every chance (a host check over every per-difficulty plist the ladder touches).
- No seed / pacing gate, awaken A/B or `aieval` (AGENTS.md); the ladder and DUCT runs are the measures the user asked for.

**Seed blocks**: 1-200 the masher's development; 201-400 fit logs (with salts) and cells; 401-500 table selection; 501-600 ladder and DUCT
dev; 601-800 spent (second look only); 801-1000 the final, once, for A, B and C together. No seed above 1024 exists (debug 30000+k).

## 2. The rule base `:rb-sp2`: 104 rules in 11 additive groups

| Group | Rules | Antecedents | Was |
|---|---|---|---|
| G0 | 36 | lead (behind / even / ahead) x his red x my awakening (not ready / ready / awakened) x his awakening | `:rb-switch89` G0 without `:ost` and `:prev`; `:awk` becomes three states; G4 `:oawk` joins as an interaction |
| G1 | 9 | my form (0 / 1 / 2) x distance (`:m-close` / `:m-mid` / `:m-far`) | kept |
| G2 | 12 | his state (free / attacking / evading / down) x distance | `:ost` was busy / free only, and not crossed with distance (whiff punish, okizeme) |
| G3 | 9 | my cells x his cells (0 / 1 / 2-3) | `:rb-sp` G2 |
| G4 | 4 | my burst x his burst | `:rb-sp` G3 |
| G5 | 2 | an exchange open | `:rb-sp` G4 |
| G6 | 4 | my wall x his wall (`:w-near` / `:w-open`) | `:wall` back, his added (cornering him) |
| G7 | 4 | my Reishi x his Reishi (`:low` / `:high`) | new (Hisagi's IH style keys on her Reishi under half; red is only the extreme) |
| G8 | 9 | the clock (early / mid / late) x lead | new: the bell is a loss for both under K.O.-only fitting |
| G9 | 6 | the pointer switch open (the awakening gauge has been full) x my SP pointer (1 / 2 / 3) | replaces `:gauge` (the DRIVE threshold is gone; DUEL_SP: the switch costs SP and opens once the gauge has been full) |
| G10 | 9 | his SP pointer x distance | new (his next NS's theme and reach) |

- **Not in it**: `:prev`. Which arm I hold is not a situation; the 2026-11-14 fit spent G0 on it ("G0 is almost all `:prev`", `fit/README.md`).
  Stickiness is `:margin` 0.02's job. `:awk` alone duplicated form >= 1 for all three fighters; inside G0 it now interacts with the lead and
  his awakening.
- **New cues** in `strat-xfeats` (judgement-only, no per-step cost, no new sim state, so no new snapshot root): `:awst` 0 / 1 / 2
  (`awaken-ready-p`, `gauges-awakened`), `:owall` (his metres to the wall), `:time` (`*match-tick*` over the match's steps), `:mptr` / `:optr`
  (the SP pointers; the HUD shows both: confirm in `webhud.lisp` before building, else G10 leaves), `:swopen` (`aw-full`). `:mr`, `:or`,
  `:ored`, `:ost`, `:lead` are `strat-feats`' already.
- **New fuzzy sets** (duel/lisp/fuzzy.lisp `*fz-sets*`, none changed): `:atk` (0.5 1 2 2.5: startup or active), `:t-early` (-99 -99 0.3 0.4),
  `:t-mid` (0.3 0.4 0.6 0.7), `:t-late` (0.6 0.7 99 99). Reused: `:no :yes :k2 :k3 :p2up`, `:m-*`, `:w-*`, `:low :high`, `:free :evade :down`,
  `:behind :even :ahead`.
- **Occupancy check before the base is frozen**: 400 matches a pairing on the T0 tables (§4); a rule whose firing-weighted share of
  judgements is under 0.5 % in all nine rows merges with its neighbour (pre-registered: G0's "ready" into "not ready", G8's `:t-mid` into
  `:t-early`, G10 into 3 rules by pointer). The final count is reported as measured, not padded.
- **Host checks** (as §11.3's): each group's firing sums to 1 on a grid over every cue's points and ramps; the antecedent count equals the
  groups' sum; a 2-arm test table's pick switches on each new cue alone; no table without `:xfeats` expands on it.
- **Cost**:
  - the page: 3 + 104 x arms integers, cap 999 (`fq-table`), so at most 9 arms; the plan uses at most 7 (731);
  - a judgement: 45 µs at 89 x 6 (§8.19); `fq/switch/bench.lisp` is rerun at 104 x 7 (guess: about 60 µs every 30 steps);
  - `fq-checksum` changes with the rules and arms, so **every player's nine saved online copies start fresh** (tell the user);
  - `fq-online.lisp` unchanged; its grouped V (max over arms of the summed Q, §8.19) already holds. With 11 groups one arm's Q can move
    0.11 at the cap 0.01, so `gaps.py` is rerun and the median gap reported; if under 0.03 the lead lowers the cap, not the groups.
- `:rb-sp` and `:rb-switch89` stay for the old tables' host tests, as superseded bases always have.

## 3. Arms: jobs first, the pairing's exchange keys underneath

**Structure.** An arm = a style unit + one job's data unit. The exchange keys PLAN3 found per pairing and side (§11.24-§11.26) are not arms
any more: they become one data unit per pairing-side (`:d-x-ki-k` ...) that the table lays under **every** arm with a new table key
`:with (unit ...)` (a pure change in `strat-expand`, host-tested; an arm's own keys win). So the general arms stay shared by a character's
three tables, and the 2026-11-15 gains stay in play.

| Character | General arms (job; the rules that are its job) | Source | Targeted (1-2 a pairing) |
|---|---|---|---|
| **Ichigo** (one function, `ichigo-ki-r2b2a1-style`) | `all` (arm 0, the shipped mode mix); `whiff` (hover at his whiff distance: G2 attacking x mid, G1 sealed x mid); `space` (far spacing and the lunge: G1 far, G6 my wall near); `ptr3` (pointer-3 pressure and the shut-gauge lunge: G3 his cells 0, G9 pointer 3); `kessa` (awakened chains: G0 awakened, G1 form 1) | assembled: `:iks-mix-*` at 1 / 0 (P2, P3); no search | vs K: the Getsuga keep-away (`:iks-retreat-p`, `:iks-getsuga-min`); vs H: found by the search |
| **Kenpachi** (`ken-kh-standoff-style`) | `all` (arm 0); `rush` (close in: G3 his cells 0, G2 down, G8 late); `guard` (hold and answer: G0 ahead, G4 his burst); `spend` (cells into Burst / Kikon-cancel: G3 my cells >= 1, G4 my burst; the one split the 2026-11-14 fit saw); `climb` (build to the Bankai and awaken: G0 not awakened x behind, G9) | assembled from `:kk-*` (KNOBS.md §6.1), then tuned in band by cells | vs H: the wake-up bait (`ken-kh-style`, G2 down); vs I: the wave answer (`:kk-wave-p`, G10) |
| **Hisagi** (`hisagi-hk-style` over the merged style; 2-3 functions, so `:keep-state t`) | `all` (arm 0: hk + the pot); `wake` (`:hk-wake`: G2 down); `kite` (`:hk-kite` + the kite data: G2 attacking x close, G0 ahead); `press` (the brawler data + Hoho in: G7 his Reishi low, G0 his red); `range` (the ranged mode's distance rule and the pointer switch: G1 form 1 x mid / far, G9) | the single-job rule units of §10 exist; `press` and `range` need the merged and range styles' tunables as keys: **one Opus code cell** (as §11.6), then data cells | vs I: `hisagi-ihr1b2a0-style` (press while her Reishi is under half: G7); vs K: the 6 m Hoho-in (`x-kh-h-r1-b3a2`'s keys) |

Mirrors use the general arms only.

**Proof that an arm does one job** (per arm, before it enters any table; `sp/arms4/<char>.md`):
1. *Descriptor*: played whole against the opponent's `none` (200 matches), its declared metric differs from arm 0's by a pre-registered
   amount (e.g. `rush`: share of steps inside 3 m >= arm 0's + 0.10; `kite`: mean distance >= + 0.5 m; `spend`: SP presses a match >= x 1.5;
   `wake`: presses in his first 20 free frames after a knockdown). Counters: `strat-run.lisp`'s `STRAT_HRANGE` lines generalised (tool only).
2. *Distinct*: no two arms of a character within tolerance on every descriptor (§3's fingerprint).
3. *It ends matches*: K.O. rate >= 50 % whole against his `none`.
4. *In band*: inside T0 (§4) with randomised runs restricted to its job rules, its run effect on the K.O. win is not negative at z <= -2
   (`cues.py`'s last block). A targeted arm must be positive at z >= 2.
An arm that fails 1-3 is rewritten or dropped; a character may end with 3 general arms (never fewer: then stop and report).

**Search** (dream-rsi; the skill's rule: plan, evaluator and budget settled with the user first, checkpoint Q4):
- Ichigo: none. Kenpachi: 8 Sonnet data cells (2 branches x 4: `rush`, `guard`). Hisagi: 1 Opus code cell + 12 Sonnet data cells (`press`,
  `range`, `kite` against Ichigo). Targeted arms: 2 cells a pairing-side, 12 in all. **Cap 36 cells, at most 3 Opus code cells.**
- **The scorer is the played policy** (PLAN2's lesson): a cell's candidate is T0 with its arm in its job rules, scored by `eval.py` (K.O.-only,
  his `none` and his T0 as the groups) on block 300; the lead rescores on block 200; one candidate a branch goes on. No whole-game
  admission, no matrix: a job arm is expected to lose whole (P2: `rush` 0-40 against Ichigo).
- W = 4, `v1_rank_keep`; a cell reads only its own branch; at most 8 `eval.py` calls a cell; `SP_BUILD` pinned.

## 4. The fit: a designed table first, then small measured steps

**Why 2026-11-14 gave nothing** (`fit/README.md`, §11.10-§11.12), and what changes:

| Cause | Change |
|---|---|
| The arms were dominated refinements; nothing to choose | job arms (§3); P3: a job table holds its arms' strength while switching 38 times a match |
| 1,600 logged matches a round: the kept deltas equalled a run-level placebo's | 6,400 matches a side-round (a match is about 0.3 CPU-s: 0.5 CPU-h); the gate is the placebo, not a fixed 0.95 |
| The fit estimated "a 3-9 s run of arm k, then arm 0" but the table played 50-90 switches of something else | the behaviour table already switches (T0), and a round may move only a few q a little, so the estimate is local to what is played |
| A switch to another style function reset its state | Ichigo and Kenpachi: one function a character; Hisagi: `:keep-state t` |
| Rare rules had no data | exploration runs start in every rule's band by quota; a rule under 2,000 logged rows keeps its prior |
| On-policy round 2 and longer horizons were worse | at most 2 rounds; gamma 0.966, scale 0.1, `--ko` terminal: unchanged |

**T0, the designed table** (`sp/band.py`'s writer generalised to a job map): arm 0 at 0 in every rule; arm k at +0.06 in its job rules
and -0.06 in the rest of those groups; `:rule-base :rb-sp2 :xfeats t :keep-state t :margin 0.02 :period 30 :gamma 0.966 :scale 0.1`,
`:with` the pairing's exchange unit. T0 must pass bar A on dev seeds before any fit. **T0 is the fallback that ships if the fit adds
nothing: it switches by construction.**

**Rounds** (`sw.py --rb :rb-sp2 --ko`, per pairing both sides together, at most 2):
1. Log: behaviour = the side's current table + runs (eps 0.03 a judgement, runs of 6-18 judgements), seeds 201-400 x 16 salts x both
   seats, against the pool {his current table, his `none`, his previous table} by seed.
2. Fit: ridge V + per-arm deltas shrunk **toward the current q** (`--prior` generalised), lambda 300; a delta is kept only in a group whose
   kept count exceeds the maximum of 20 run-level placebo fits (`cues.py`).
3. Step: the 6 largest kept deltas only, each clipped to +-0.03.
4. Select on 401-500 (400 matches, paired against the previous iterate on K.O. wins against the pool): accepted at z >= 1.0 with bar A
   still holding on those seeds; else the previous iterate stays.
The opponent's table moves between rounds, so round r of one side logs against round r-1 of the other.

**Mirrors**: T0 from the general arms on both seats; one round against itself; the table that ships is the one with the higher self-play
K.O. rate among T0 and the iterate.

**`:keep-state`**: on (§11.11's answer stands). **`:margin`** 0.02 fixed; if bar A's median falls under 10 changes a match the lead tries
0.01 once, on dev seeds.

## 5. The ladder and the masher

**What each tier plays** (today's shape; P1 says the upper rungs need no new mechanism):

| Tier | Table | Perception | Chances |
|---|---|---|---|
| HARD | the pairing's table, whole | `*ai-delay*` 8 | every per-difficulty plist at `:hard` |
| NORMAL | the same table in 10 s windows at chance 0.5 (`*strat-table-chance*`, `strat-window-step`), else no strategy | 14 | `:normal` |
| EASY | no table (chance 0) | 24 | `:easy` |
| masher | none: it is not a CPU tier | sees only where he is | none |

- A table's style keys replace the per-difficulty values and its exchange keys scale them (§11.6, §11.23), so NORMAL plays HARD's style
  knobs inside its "on" windows with NORMAL's eyes: as today.
- **Knobs if a rung fails, in this order, one at a time, on dev seeds**: `*strat-table-chance*` (NORMAL's 0.5; EASY's 0), `*ai-delay*`,
  then the shared chances of core-ai.lisp / tuning.lisp for that tier. Never a per-pairing knob, never a non-monotone plist.
- **Tuned bottom-up**: the masher is frozen before its first match; then EASY > masher, NORMAL > EASY, HARD > NORMAL. A change to EASY
  reruns the rung above it.
- HARD against NORMAL is 359 of 360 today; whether that is too steep is checkpoint Q2.

**The masher** (new file `duel/lisp/masher.lisp`, one job; pure pick + one mutating step):
- `masher-pick (u1 u2 u3 ready) -> (button frames gap stick)`, pure and host-tested. One decision per press event (never per step), three
  `sim-rnd01` draws inside the step:
  - button: J 0.50, Mod+J (SP) 0.15, Space (Step) 0.10, Mod+Space (Hoho) 0.07, P (Burst) 0.04, Mod+P (awaken) 0.04, nothing 0.10; a press
    the game refuses does nothing;
  - held 2-12 frames, then 0-10 frames idle;
  - stick: toward him 0.55, away 0.15, left 0.10, right 0.10, neutral 0.10, redrawn each event.
  These rates are pre-registered: they are not tuned to pass the rung.
- `masher-step` writes the vpad; a brain flag routes `core-brain-step` to it before any CPU clause. Its state (the event's end, the held
  button, the stick) lives in brain slots, snapshotted with the brain: snaptest and fulltest cover it. No perception, no MCTS, no strategy.
- Selected by debug **81030+s** (s 0 P1, 1 P2, 2 both; free since ASSIST left, to be claimed in DUEL_GAMEPLAY "Debug commands" with a
  `define-debug-range`), and in the native tools by `STRAT_DIF_P<n>=masher` (strat-run.lisp). No menu entry (checkpoint Q5).
- **Tool**: `sp/ladder.py` (this plan's P1 driver made permanent): the 27 cells, both seats, a seed block, the Wilson rule, time-outs.

## 6. DUCT, the frozen anchor

**What it is**: the strategy layer of §5 (`*strat-layer*`, `strat-request` ... `strat-full-step`): Decoupled UCT over my arms x his arms,
full-sim rollouts, seeded by an offline payoff matrix, at HARD's perception. Native only: a research and gating opponent. The game keeps
playing the fuzzy Q tables and runs no rollouts for this.

**What must be built** (tool side, plus one small off-by-default change):
- `strat-run.lisp STRAT_ANCHOR=<file>`: sets `*strat-library*` and `*strat-payoff*` for the run from `sp/duct/anchor-<pair>.lisp` (the
  PLAN4 arms of both sides written inline, `:with` applied; the matrix and its mixes). The game's library is not touched.
- `*strat-layer*` also takes a seat (0 / 1) so a mirror can put DUCT on one seat (`strat-layer-p`; NIL by default: G2 identical).
- `sp/duct.py`: the matrix (`pop.py matrix`'s runner over the arms, block 200, both seats, 200 matches a cell), the anchor files, the
  DUCT-vs-X runs, the fingerprint.

**Budget, decided once at step D1** (seeds 1-200; DUCT against DUCT, KI and KH, 400 matches a comparison):

| Setting | Rollouts x steps, period | Cost a selection | CPU-s a match (guess from P4) |
|---|---|---|---|
| today's | 8 x 150, 90 | 7-10 ms (measured) | 0.6-1.2 (measured) |
| standard | 16 x 240, 90 | about 26 ms | about 2 |
| heavy | 32 x 300, 60 | about 64 ms | about 8 |

  Rule (pre-registered): take the cheapest setting that the next one does not beat at >= 55 % of 400; `*strat-n0*` 6, `*strat-c*` 1,
  `*strat-swing*` 2, `*strat-lambda*` HARD 0.1 unchanged. A full report (4 tiers + DUCT itself, 9 rows, 200 matches a cell = 9,000 matches)
  costs about 5 CPU-h at "standard", 20 at "heavy".

**Frozen for the whole plan** (`sp/duct/ANCHOR.md`): the arms, the matrices, the knobs, the seeds, the sim build's hash.
- Every Lisp change of this plan (the masher, the cues, `:with`, the seat layer, Hisagi's knobs) lands **before** the freeze; after it only
  data changes (q tables, lookup rows, the ladder's tuning plists).
- **Fingerprint**: DUCT against DUCT, seeds 181-200, all nine rows: the gate rows and `duel hash` lines. It is rerun at every `SP_BUILD`
  re-pin and must be identical; if it is not, the build changed DUCT and the round stops.
- If the arm set must change after the freeze, DUCT is re-frozen once, every DUCT number is rerun, and the report says so.

**Does DUCT still reduce to a lookup, and does that weaken it?** (§8.4-§8.5: every matrix had a pure equilibrium, so the seeded layer
played the dominant arm and its rollouts added nothing measurable.)
- Mostly yes, by P2: played whole, Kenpachi's incumbent dominates his job arms against Ichigo, Hisagi has one arm that K.O.s Kenpachi, and
  Ichigo's five arms are within noise of each other (there the rollouts decide). Job arms are built to win a situation, not a match, so
  whole-game matrices will keep pointing at arm 0.
- That does not weaken it as an anchor. An anchor has to be fixed, reproducible, strong and not fitted against the tables; it does not
  have to switch. In practice DUCT will be "the best whole-game arm per pairing, plus look-ahead".
- Say it plainly: **HARD against DUCT is close to "the switching table against the best fixed arm"**, the comparison the user set aside for
  shipping. It comes back only as the reference scale the user chose, which is why its target is a question (Q3), not a bar set here.
- Character matchups are lopsided (KI is about 1 : 9), so a raw 50 % per row means nothing. The honest readings: per row, a tier's share
  against DUCT **beside DUCT's own share in that seat** (DUCT vs DUCT, same seeds); and pooled over the nine rows, where DUCT vs DUCT is
  50 % by symmetry.
- NORMAL, EASY and the masher will sit near 0 % against a HARD-eyed DUCT (P1: HARD already beats NORMAL 359 of 360). They are reported;
  the scale has little resolution down there.

## 7. Order, batches, checkpoints, budget

| Step | What | Who | Lisp? |
|---|---|---|---|
| 0 | **Checkpoint 0**: Q1-Q5 | main, the user | |
| B1 | the masher, debug 81030+s, `STRAT_DIF=masher`, `sp/ladder.py`; host tests, snaptest / fulltest | Opus, worktree | yes |
| B2 | `:rb-sp2` (cues, sets, base), `:with`, the seat layer, `STRAT_ANCHOR`, `sw.py` / `band.py` for the new base; off by default, G2 identical | Opus, worktree | yes |
| L1 | merge B2 then B1; pin `SP_BUILD`; the ladder on dev seeds with today's tables, masher included (27 cells x 200) | main, sim | |
| **CP1** | *Report*: the masher's first numbers, the 27 cells; ask only if EASY > masher fails by more than a knob can close | | |
| B3 | arms: Ichigo assembled (Sonnet); Kenpachi cells; Hisagi's code cell (merged first) and cells; targeted cells; the one-job proofs | main dispatches cells; Opus for the code cell | Hisagi's keys only |
| B4 | T0 for nine rows; bar A on dev seeds; the occupancy check; `:rb-sp2` frozen; **playtest Artifact of the T0 build** (AGENTS.md: playtest first) | Opus, worktree; main publishes | data |
| D1-D2 | DUCT: matrices, the budget rule, the freeze, the fingerprint; DUCT vs DUCT and T0 vs DUCT on dev seeds | Opus, worktree (tools only) | no |
| **CP2** | *Report*: the arm sheets, T0's switching, T0 against DUCT (the first real number for Q3's target); the user's playtest notes | | |
| B5 | fit rounds, three pairings in parallel (KI, KH, IH), mirrors after | 3 Opus subagents, worktrees; Sonnet for logs | data |
| B6 | the final on 801-1000 (A, B, C at once); ladder retune if a cell fails; `units.py` / `add.sh` / `proofs.sh`; G2 regenerated; docs; commit | main (Fable review before "done") | tuning plists |
| **CP3** | *Report*: the 27 cells, the DUCT table, the switching table per row, what resets (saved learning), the Artifact | | |

- B1 and B2 run in parallel (B1: `masher.lisp`, one clause in core-ai.lisp, gate / debug; B2: strategy.lisp, strategy-glue.lisp,
  fuzzy.lisp, tools). Grep each new top-level name first (AGENTS.md: one build unit).
- `SP_BUILD` is re-pinned at L1, after B3's code cell, and never again before B6; today's pin (`a27d7dfc717d`, §11.27) is already stale
  (`c8bc90c8381c` at 8eb1ce26). Main's Lisp stays frozen while cells or fits run.
- Subagents never push or deploy; bounded waits only, no `pkill -f` / `pgrep -f`, in every brief.
- **Budget**: at most 36 search cells (<= 3 Opus code cells) + 7 Opus batch agents + 2 Fable reviews (the fit's first accepted step; before
  "done"). Sims about 45 CPU-h (guess: fit logs 10, DUCT matrices and reports 20 at "standard", ladder 3, cells 6, proofs and selection 6).

## 8. Risks, and what shows each early

| Risk | Seen at | Then |
|---|---|---|
| EASY does not beat the masher 70:30 in some row (EASY's eyes are 24 frames late; the masher always attacks) | L1 | EASY's chances up one knob at a time; rerun NORMAL > EASY; the masher's rates stay |
| NORMAL > EASY passes only by the bell (II 35 %, IH 57 % by K.O.s) | P1 already; Q1 | the user's answer; if K.O.-only, Ichigo's NORMAL stall is a rework of its own |
| Kenpachi's or Hisagi's job arms are too weak even in band (P2: `rush` 0-40 whole against Ichigo) | B3's in-band scores; B4's T0 against `none` | the arm leaves; 3 general arms is the floor; below it, stop and report |
| Hisagi has no table that K.O.s Ichigo (best whole arm 18 of 40) | B3 | the code cell; if it fails: a balance matter, the user's |
| T0 switches but stalls (time-outs) | B4's K.O. rate | the stalling arm's job shrinks; bar D |
| The fit is noise again | round 1: no group clears its placebo | T0 ships; reported as designed, not fitted |
| 104 rules are too thin in places | the occupancy check | the pre-registered merges; the count reported as measured |
| DUCT drifts (a build change, an arm edit) | the fingerprint at each re-pin | stop; re-freeze once; rerun its numbers |
| DUCT is too strong or too weak to scale anything (HARD at 5 % or 95 %) | D2 | Q3's target is set from D2's number at CP2, not before |
| DUCT's cost blocks the reports | D1's CPU-s a match | the budget rule picks the cheaper setting; 200, not 400, a cell |
| Held-out seeds run out (601-800 spent, 801-1000 once) | B6 | one final; a second look on 601-800, named as such |
| A source edited under running cells | `SP_BUILD` guard | no Lisp edits in main during B3 and B5 |
| Saved online learning resets on all nine rows | by design | told at CP3 |

## 9. Checkpoint questions (only the user can answer)

| # | Question | Options (recommended first) |
|---|---|---|
| Q1 | On the ladder, how does a time-out count? | **the game's result** (a lead at the bell is a win; all 18 probed cells pass today); K.O.s only (II and IH NORMAL > EASY fail today at 35 % and 57 %); the game's result but a cell fails above 25 % time-outs |
| Q2 | HARD beats NORMAL 359 of 360 today. Is "at least 70:30" a floor only? | **floor only** (report the real gaps); a band, e.g. 70-90 %, which means making NORMAL stronger (`*strat-table-chance*` up) |
| Q3 | HARD's target against DUCT | **report it and decide at CP2 from T0's number**, with the working target "pooled over nine rows >= 50 %, no row more than 15 points under DUCT's own"; a blocking >= 50 % now; report only |
| Q4 | The arm search's budget (dream-rsi's rule) | **36 cells, <= 3 Opus code cells**; assembled arms only (0 cells; Hisagi likely ends with a weak table against Ichigo); 72 cells (a second round for Kenpachi and Hisagi) |
| Q5 | Is the masher only a test opponent? | **debug and native sim only**; also selectable in PRACTICE as a dummy that presses |

**Checkpoint 0 answers** (the user, 2026-11-15): Q1 「照遊戲判定」 (the game's result; a draw counts half; > 25 % time-outs flagged, not
failed); Q2 「只是下限」 (70:30 is a floor; the real gaps reported); Q3 「先報告，CP2 再定」 (working target pooled ≥ 50 %, no row more than
15 points under DUCT's own; set at CP2 from T0's number); Q4 「36 格」 (≤ 3 Opus code cells). Q5 not asked: the default (debug and native
sim only, no menu entry) stands.

**Checkpoint 1** (2026-11-15). The first dev ladder (seeds 501-600, 200 a cell): HARD > NORMAL and NORMAL > EASY pass in all nine cells,
EASY > masher fails in all nine (EASY's share 0.00-0.54). The diagnosis (`sp/diag/masher-vs-easy.md`): EASY never plays a table and NORMAL
plays one half the time. In neutral the in-game MCTS decides, and after its light search it holds still for the CPU's perception delay
(EASY 24, NORMAL 14 frames) while the full sim scores the best two (MC-FULL-REQUEST). That is a second reaction delay, with no clash,
exchange answer or Hoho during it. No monotone knob set passes EASY > masher. The user asked 「為什麼會有模擬問題？不是在做 fuzzy Q
table 嗎？」 and chose **「三個難度都用 Q 表」**: every tier plays the pairing's fuzzy Q table the whole match (the style functions press;
neutral no longer goes to the MCTS's light+full-sim decision). The tiers differ by perception, the per-difficulty chances and the
table's strength (e.g. EASY with fewer or weaker arms). §5's "What each tier plays" table is replaced by this. NORMAL's 10 s windows and
EASY's "no table" are to leave once the probe confirms. The MCTS timing fix was prototyped only as an option and is not taken.

**B3 merged, the cells' pin** (2026-11-15, main ddaae0f9): Hisagi's code cell (14 keys `:hr-*` / `:hkk-*`, KNOBS.md §6.6) and Ichigo's
(8 keys, §6.7: patience, hover, steer, KESSA chain) both leave play bit for bit. Passing general arms: Ichigo `all brawl keep kessa2`
(re-jobbed after `whiff space ptr3 kessa` failed: HARD's patience made every mode hover alike), Kenpachi `all spend climb` (+ `bait` vs
Hisagi), Hisagi drafts `all range` (+ `press kite wake` to tune). T0 KI Ichigo v3 switches (median 19 / 21 changes on 501-540 / 541-580).
Code cells used 2 of 3. **`SP_BUILD=b835ac41b83b`** (strategy-switch.py's build_hash at ddaae0f9) for B3's cells and D1-D2; main's Lisp
stays frozen until they hand back.

**The arms come from each fighter's kit** (the user, 2026-11-15: 「你探索每個人物的時候請依據遊戲系統與該人物的特色、幀數表、攻擊範圍等等進行規劃」;
the order they set on 2026-10-25, DEVLOG §369, skill `duel-character-cpu` "The order for a style search", which §3 skipped). §3's jobs were
picked from the style knobs, and most failed their proofs (Ichigo's four modes, Kenpachi's rush / guard / wave, Hisagi's press / kite):
jobs the kit does not separate. From here on, per character and form, in this order:
1. a **data sheet** generated from the kit (S / A / R, advantage, reactions, reach and hit volumes, movement and pushes, every cancel
   and latch, SP costs and gains, the exchange rules), regenerating `docs/research/ki-ai/*/sheet.lisp` (2026-11-06, before the SP
   system) and adding Hisagi;
2. a **catalogue** of combos and means (pokes by distance, whiff punishes, safe pressure, anti-approach, wake-up pressure, ranged
   pressure, the exchange after a cancel), each verified in the native sim by a scripted input, plus the matchup tables against the
   other two (who out-ranges whom where, whose whiff each punishes, which openers trade);
3. **strategies** = situations → catalogue entries, proposed as arms (general and targeted) whose jobs and descriptors come from the
   sheet; the user picks before any arm is built or searched;
4. arms, T0, search only to tune weights and thresholds.
Today's admitted arms stay as data until step 3 replaces or keeps them. B4 (nine T0s, the measures, the playtest build) and the
provisional DUCT continue as the pipeline's test bed.

**Checkpoint 2a: the user picks the strategies from the kit studies** (2026-11-15; `sp/kits/<char>/strategies.md`). All three proposed
sets were taken (「全部採用」 x3), and 「改成修兵自己的打法」 for Hisagi's Shikai arm 0:
- **Ichigo**: `all` (= the sealed band vs Kenpachi), S1 answer, S2 brawl, S3 economy, S4 punish, S5 kessa-lunge; targeted T2 keep
  (KI, ahead late only), T3 inside 3 m (IH).
- **Kenpachi**: `all`, out-range poke, wake-up by his cells (generalises `bait`), red Kikon on pointer 2 (replaces `spend`), climb (no
  Bankai route under half Reishi); targeted Getsuga close-in (vs Ichigo), dead-zone hug (vs Hisagi). Rush and guard are dropped.
- **Hisagi**: S1 the chain's band (kite merged), S2 J-side cancels, S3 chain tip (`range` sharpened), S4 bind to catch up, S5 `wake`;
  targeted K1 J1 into the lunge / K2 out of the sealed reach (replace `hoho6`), I1 the rush and the wave, `ihx` kept. `press` dropped.
  His Shikai arm 0 becomes his own (the chain's band), no longer Kenpachi's brawler.
- **The generic CPU fix** (the lead's): the clash never throws a move whose min reach (dead zone) covers the distance. 201 of the 224
  dead-zone NAGIs against Kenpachi came from it (`kits/hisagi/probe.md`).
These are implementation batches, one per character plus the shared fix (PLAN4 §6's order step 4: write the strategy into the CPU,
search only for weights). They are separate from the 36-cell search budget, of which 10 cells remain.
