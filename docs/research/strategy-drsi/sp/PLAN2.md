# Plan 2: tables that gain (DUEL_AI_STRATEGY §11, after the KI fit probe, 2026-11-14)

Replaces PLAN.md §2 step 4 (admission), §4 (the fit), §5 (what is left of the budget) and §7 steps 6-9. Everything else in PLAN.md stands.
Evidence: `fit/README.md`. Guesses are marked.

## 0. The diagnosis this plan acts on

- Whole-game admission breeds refinements: the newest arm dominates, so a table has only worse arms to switch to.
- The off-policy fit estimates "a short run of arm k, then arm 0", gates it with a test noise passes, and plays something else.
- So: **search the table itself, not arms for a later fit.** A cell's candidate is the table that would ship, scored whole-game, paired
  against the incumbent. No estimate stands between the search and the played policy.

## 1. The table's actions: band specialists on one style function

- **A band table** = `:rb-sp`, arm 0 (the side's best pure arm, the incumbent) in every rule, plus one arm k that out-scores arm 0 only
  in the rules of one band. Written by a new small generator `sp/band.py` (incumbent file, variant file, band → a raw `:fq` file that
  `eval.py` already scores). No Lisp change, no build.
- **Bands** (pre-registered, from the probe's only signals, each a set of `:rb-sp` rules):
  - `nocell` (no cells on either side), `mycell` (I hold ≥ 1), `bothrich` (both 2-3): group G2;
  - `myburst`, `hisburst`: G3;
  - `awake` (my form ≥ 1): G1. Distance splits and G4 are not searched (nothing showed).
  - `:ored` (Ichigo only) needs a 2-rule group in the rule base: a Lisp change, added only if a KI cell asks for it by name.
- **Arm k is a knob variant of arm 0's style function** (`:base` / `:rules` deltas only), so a switch keeps the style's state. An arm's own
  `:rules` cannot read cells or bursts (they are `strat-xfeats`, judgement-only), which is why this has to be a table.
- **`:keep-state` reopened**: on in every new table. An arm with a different `:fn` (or `none`) is allowed only with it. It supersedes
  2026-11-09's "drop it" for the new tables (then: no measured effect; now: 11 time-outs → 0). Technical, the lead's call; reported.
- **Admission of a specialist** (replaces "beats the population whole-game"):
  1. identity: the band table with arm k = a copy of arm 0 is byte-identical to arm 0 raw;
  2. the cell's dev score on block 300, the lead's rescore on block 200 (both `eval.py`, three opponent groups);
  3. per side and band, only the best by block 200 goes to the admission block: fresh seeds 801-1000, both seats, 1,200 matches, paired
     against arm 0 on the same seeds, pooled z ≥ 2.0, time-outs not above arm 0's. At most 6 tests a side.
- Admitted bands are merged into one table per side (bands in different groups add; two in one group keep the better z).

## 2. The search

- **KI, round 3 (specialist round)**: yes, and first, because both incumbents exist. Before any agent: a sim-only check (0 cells, about
  1 CPU-h) of the one division of labour the probe saw, Kenpachi `r1-b2a2` in `nocell` over `r2-b1a2`, and Ichigo `none` in `myburst`,
  through steps 1-3. Then 8 cells a side (the 3 most promising bands, `v1_rank_keep`), Sonnet, data only.
  - **Stop rule**: if the sim check and round 3 admit no band on either side, bands are a dead end at this effect size; KH / IH then get
    only a 4-cell specialist probe a side, and the user is told (§5).
- **KH, IH**: round 1 whole-game as PLAN §2 (it must produce a K.O.-ing incumbent a side), round 2 = the specialist round on that incumbent.
  - `none` is the plain CPU there, so no-`:fn` arms and the `:b-*` biases are live: the initial program per side is the best of `none`,
    `a-generic` and the old arms that pass the screen (K.O. rate ≥ 0.5).
  - Kenpachi starts with knobs (`ken-kh-standoff-style`, 29 keys). Hisagi's arms reach `:kk-*` through `hisagi-merged-style`; his ranged
    mode and Ichigo against Hisagi have no knobs. One Opus code cell a side is reserved for each: expose that style's tunables through
    `style-knob` (as §11.6) when two data cells report the same wall.
  - Stalling: K.O.-only scoring stays; a candidate with more time-outs than its parent in the mix group is not admitted, whatever its score.
  - Each side's round 1: 10 cells (`v1_rank_keep`); round 2: 8 cells.
- **Mirrors**: the sufficiency check only (sim). A mirror takes the cross-pairing incumbent on both seats; cells (≤ 12 a mirror, from
  the mirror allowance) only if that pair K.O.s under 90 %.
- **Budget**: KI 16 + KH 36 + IH 36 + code cells ≤ 6 + reserve 6 = **100 cells**. No change asked. Sim: about 10 CPU-h more (guess).

## 3. The fit, and the shipping bar

- **No off-policy fit decides an action.** The q values are written, not estimated: arm 0 = 0 everywhere, arm k = its measured paired
  gain (K.O. share) in its band's rules, `:margin` 0.02, period 30. On-policy rounds are dropped (they made both sides worse).
- `sw.py fit` stays as a diagnostic only: if two specialists compete inside one band, log ≥ 6,400 matches and keep a delta only where
  its group's kept count exceeds the maximum of 20 run-level placebo fits (`cues.py`), not a fixed 0.95.
- **Ship test**, once per side, held-out 601-800, both seats, against the opponent's final table (or pure arm) and his `none`: the merged
  table against its own arm 0, paired pooled z ≥ 1.96; K.O. rate ≥ 90 %; not losing to his anchor.
- **Fallback**: no gain → the lookup plays the best pure arm, written as a table: arm 0 everywhere, the runner-up arms and `none` present
  at q -0.05, so `fq-online.lisp` has something to learn with against a human. That is a fuzzy Q table in format only. It is **reported
  as such, per side, never counted as a gaining table.**

## 4. NORMAL

- An arm's knob values replace the per-difficulty ones (§11.6), so a table plays HARD knobs at any difficulty. NORMAL therefore plays the
  table for a share of the time: the match is cut into 10 s windows, one `sim-rnd01` roll at each window's start (an event, not a step):
  the table with chance 0.5 at NORMAL (1 at HARD, 0 at EASY), else the `none` arm, with `:keep-state`.
- Check: against the opponent's HARD `none`, the K.O. score is EASY ≤ NORMAL ≤ HARD per side (blocks 200 + 300); only the 0.5 moves.
- One runtime batch after the HARD tables: host tests, snaptest / fulltest, G2 regenerated once with its header note.

## 5. Order, checkpoints, reports

1. `band.py` + identity proofs; the KI sim-only check. *Report: does any existing-arm band gain.*
2. KI round 3; admission; merge; KI ship test. **Checkpoint A** (before KH / IH, as the user asked). *Report: the bands admitted, the
   ship test rows, gaining table or fallback per side, `:keep-state` back on.*
3. KH and IH round 1 (screens, populations, matrices). *Report: incumbents, K.O. rates, any stalling.*
4. KH and IH round 2 (specialists); admission; ship tests. **Checkpoint B.** *Report: six sides, gaining or fallback.*
5. Mirrors' sufficiency; the lookup replaced (the stalling tables leave here); online smoke; PLAN §6's gates.
6. NORMAL batch; G2 reference; playtest Artifact. *Report: the difficulty ordering, what to feel for at NORMAL.*

**Top risks**: a band is active too briefly to move a match (the paired test at 1,200 matches sees about 4 points, not less); cells
overfit block 300 (hence one candidate a band to the admission block); a chance knob moved to 0 / 1 shifts the random stream, so a
"gain" may be seed luck (the admission block is the answer).
