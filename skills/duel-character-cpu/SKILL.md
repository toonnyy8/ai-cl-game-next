---
name: duel-character-cpu
description: Use when one fighter's CPU, ASSIST (AUTO COMBO / AUTO GUARD) or learning CPU must take a new move, ender or resource rule, or when the user wants that fighter's CPU rebuilt or given a style by a search (dream-rsi, 「風格化學習型 AI」) in an arena fighter like SOUL DUEL — or when a CPU never uses a move, uses the wrong route for its resources, or awaken A/B rows drop after a CPU change.
---

# A fighter's CPU: new moves and style searches

## Overview
From the new Lille's CPU work (`docs/duel/DUEL_LILLE_V3.md` §22 the search, §25.1 the O ender and the stance route),
the old Lille's search (`DUEL_LILLE.md` §24) and AI v2 (`docs/guides/DREAM_RSI.zh-TW.md`, its checklist §7). Core
principle: **the CPU follows the rules, never leads them; measure what a rule actually fires, and judge a search with an
evaluator frozen before the first cell.** Generic CPU rules (per-difficulty chances, roll once per event) live in
`sim-balance-gates`; the move grammar in `duel-move-modules`.

## When
- After the rules freeze. If the user defers the CPU (「晚點」) while rules move, report its wins each gate (Lille's fell
  to BK 1 / 60) and don't tune it in between.
- A rule change during a search costs a re-measure and a re-freeze (R18: the pick fell 0.9716 → 0.9102).

## Order: the catalogue first, then the strategy, then the CPU (the user, 2026-10-25)
「先從幀數表、取消規則、位移與量表消耗等資訊展開出可行的連段與攻擊手段，再思考如何將這些手段引用至對戰策略中」
(DEVLOG §369). Don't open a search on the CPU's knobs before the fighter's options are known:
1. **Data sheet** per form, from the kit (never from memory): S / A / R, advantage on hit and block, hitstun /
   reaction, volume and reach, lunge / chase / slide / push, every cancel (string links, L after J / K, SP cancels, the
   O ender, ORANGE's chain, the guard cancel, holds and releases), costs and gains (Reiatsu bars, flash step, the kit's
   own resource), the combo limits and scaling (unscaled windows, SPs).
2. **Catalogue** expanded from the sheet: the hit-confirmed combos (route, frames, damage after scaling, cost / gain,
   where both stand after, who is plus), and the non-combo means (pokes by range, whiff punishes, punishes by block
   disadvantage, safe pressure, anti-approach, zoning, setups, oki). Every entry **verified in the native sim** (a
   scripted input against a dummy), its measured numbers recorded; a frame-math entry that the sim refutes is dropped.
3. **Strategy**: situations (distance band, his state, both sides' resources) → which catalogue entries; styles are
   weightings over the catalogue. The user picks before any CPU code.
4. **CPU**: encode the strategy in the kit's CPU (the rules below); a search (dream-rsi or a grid) only tunes weights
   and thresholds of the chosen strategy, under the frozen evaluator.

## Teaching it one new move (the CPU, ASSIST, learner together)
1. **Where it looks**: a kit tick runs after the step's frame count, so a check "on the land frame" never fires: look on
   `land + 1` (the O ender). Prove it fires: a counter in the `duel <char>` gate line, counted over 20 sim matches (51).
2. **A resource rule is checked against the resource as it is in play.** Log the distribution first. "K only with
   spare specials and full gauges" almost never chose K: the base sits at 0 pips, the awakened form rarely above its 4
   kept wings. v2: K by default, J only when short (`BR-ROUTE-J-P`, `BR-SPARE`). One rule shared by the CPU's plan, its
   links and AUTO COMBO.
3. **ASSIST**: AUTO COMBO's route for it (the same rule), AUTO GUARD if it changes guarding; **learner**: a situation
   appended (keep existing indices: saved tables are keyed by them); the opponents' reflex key if it is a threat.
4. **Gates**: his pairings at 20 seeds, the awaken A/B on 3 streams, ASSIST, G2. If A/B rows drop, attribute with a
   parent-commit baseline (`git worktree add`): the O ender dropped four rows through his never-awakened base form.
   Report; the user decides (exception or narrower rule).

## Style search (dream-rsi or a plain grid)
Ask before the first cell (AskUserQuestion): weights, the signature themes, budget, rounds, parallelism. Fewer than 3
rounds or a few dozen cells: say "a grid with bookkeeping, no dreaming" (in all three runs here, dreaming's compare / promote changed little: DREAM_RSI §5.10, DUEL_LILLE_V3 §22).
- **Evaluator, frozen in one commit** (`tools/aieval.py --char C`): score = (w_str strength + w_mash masher + w_sig
  signature) × a NORMAL factor; 0 when NORMAL pacing fails. **NORMAL**: a drift gate against the baseline if the baseline
  is sane; a band (win share 0.30–0.60 → ×1, linear to 0 at 0.15) if it is broken. Retired roster slots excluded.
- **Signature = a whitelist of move names** (+ a combat-log tag for what a name can't show, e.g. a charge level);
  the user picks the themes (「蓄力招」「資源循環」「架勢連段」). Never generic moves (attack strings, Breaker, Kikon).
- **Seeds fixed**: 40 per cell, 80 for the final pick; differences inside ±0.03 at 20 seeds are noise.
- **Cell scope**: the character file's CPU parts and its own test section only (`splice-tests.py`); worktree at the
  freeze; the lead re-scores every cell before `record`. Each cell returns a STYLE paragraph in a player's words;
  relay it to the user as it lands.
- **What the evaluator misses, measure per finalist**: the awaken A/B (only one cell of eight passed it; the user took a
  combined candidate at 0.965 over the top 0.9733 for it).
- **Integrate**: a 3-way merge onto the current rules, the learner's situations, AUTO COMBO's routes, the manual's CPU tip,
  then the full gate. Workspace template: `docs/research/lille2-ai-drsi/` (README, `step.sh`, `rescore.sh`, `brief.py`).

## Red flags
- A CPU rule "added" with no counter showing it fired in the sim.
- A threshold set from intuition about the resource, not its logged distribution.
- New CPU behaviour HARD-only "so NORMAL stays identical" when NORMAL itself is broken.
- Comparing cells scored by different evaluator commits.
