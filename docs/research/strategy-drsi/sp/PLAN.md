# Plan: DUEL_AI_STRATEGY §11, strategies re-collected under SP (2026-11-14)

Probes: main's `build/simgate/duel.fas` (post-SP), HARD, seeds 601-620, one seat, 20 matches a cell (one-off probe scripts, not kept). Guesses are marked.

## 1. What survives, what is redone

**Survives (machinery):**
- The format and runtime in `duel/lisp/strategy.lisp` (§10 units, composites, the `:fq` selector, `:event-arms`), `strategy-glue.lisp` and `fq-online.lisp`.
- The tools `strategy-switch.py` (`--raw`, `--vs-strat` pools), `strategy-matrix.py`, `strat-desc.lisp`.
- The fit script `docs/research/strategy-drsi/fq/switch/sw.py` and the evaluator pattern `khfn/eval.py`.
- Round 5 step 3's swap rule and the seed blocks.

**Redone (content):** every q value of the 18 tables, `*strat-lookup*`, `*strat-payoff*` and every whole-arm measurement.

**Probe results:**
- The old library loads and runs, but the live lookup stalls. Both seats on the lookup: 8 of 9 pairings have a median of 300.0 s (the time-out), II is 20 draws of 20, and most final forms are BASE (nobody awakens).
- With no strategy on either seat (`STRAT_P1=none STRAT_P2=none`) matches end: medians 168-272 s; Ichigo beats Kenpachi 17:3, Kenpachi Hisagi 18:2, Hisagi Ichigo 18:2.
- Whole arms against the plain CPU in mirrors win 20:0, but by the clock: `ken-ki-style` on Ichigo 20 time-outs of 20, on Hisagi 18, `hisagi-merged-style` 20, `:d-zoner` 11. Only `ken-ki-style` on Kenpachi K.O.s (0 time-outs, median 99 s).

**Evaluator defect:** `strategy-switch.py` counts a time-out lead as a win (`ROW` reads only `winner`; its docstring says 0). Under SP this rewards stalling.

**No longer meaningful:**
- The cue `:gauge` and `:hold-awaken` (the DRIVE threshold is gone; the switch costs only SP), `:dswitch`'s measurements, `:wave` as "beats every class", `*strat-payoff*`.
- The cues carry no flash-step gauge: `:hoho` is one bit, so no rule can say "bank a cell" or "he is at 0".

## 2. Co-evolution per pairing

**What an interaction strategy is:** an arm plus the opponent arm it answers, stated in one sentence on four axes.
- Triangle: which class it throws to cancel which (a cancel refunds, gives +30 and opens the steal).
- SP economy: spend or bank cells, keep the last cell for Hoho or BLUE, deny his cells by a breakthrough or the AS1 steal, cash out in a burst (free SP).
- Distance: reach bands, Hisagi's 3 m dead zone.
- Forms: when to awaken, KESSA's clones, the bind.

**The loop (PSRO-lite, one population per side and pairing):**
1. Seed both populations: `none` (the anchor), the generic arm, the old arms that still K.O.
2. Payoff matrix by `strategy-matrix.py` (arms whole, both seats) and its regret-matching mix.
3. Both sides search **in the same round** against the other's frozen population (the user's rule, round 5 step 3). Opponent weights: 1/3 anchor, 1/3 the equilibrium mix, 1/3 uniform over the rest.
4. Admit by §4's test: held-out confirmed, no duplicate fingerprint (§3), a best response to some column or a value gain ≥ 0.02; one job an arm (§10).
5. Stop a pairing when a round admits nothing on either side.

**Against cycling and overfitting:**
- Never score against the latest opponent alone, and never delete a population member.
- The anchor keeps strength against the shipped CPU; no cell sees held-out seeds.

**Mirrors (KK, II, HH):** one population on both seats. First rule 3's sufficiency check (the matrix from the cross-pairing arms); search only where it has no K.O.-ing equilibrium.

## 3. Dream-RSI

- **Workspace:** one per (pairing, side), six for KI, KH, IH, under `docs/research/strategy-drsi/sp/<pair>-<side>/`.
- **Cell:** one agent attempt writing or mutating one arm: a data plist (no build), or a `:fn` in the cell's own worktree and native build (§9, about 2.5 min).
- **Initial program:** `(:id :s0-generic)`.
- **Grid:** 4 branches x 3 attempts, W = 4 (khfn's).
- **World pool:** every closed round of all six workspaces, one shared policy (§8.10's one world was weak evidence).
- **Scoring command:** a new `docs/research/strategy-drsi/sp/eval.py`, khfn's `eval.py` generalised:
  `eval.py --me C --vs D --cand {node_dir}/cand.lisp --seed0 200`
  - It calls `strategy-switch.py --raw --vs-strat <member>` per pool member.
  - Score = the mean over the three groups of (K.O. wins + 1) / (matches + 2): positive, higher is better. **A time-out scores 0** (a `--ko-only` flag).
- **Seed blocks:** 200 the coordinator's rescore, 300 the cells' dev runs, 400 held-out for admission.

## 4. Library to fuzzy Q tables

- **States:** a new rule base `:rb-sp`, grouped like `:rb-switch89`.
  - Kept: lead, his state, form, distance band, `:prev`.
  - New cues: my and his flash-step cells (0 / 1 / 2-3), a burst running, an exchange open after a cancel.
  - Dropped: `:gauge`.
- **Actions:** the admitted arms (about 4-8 a side) plus event arms.
- **Offline fit:** `sw.py` (ε-run logs, bootstrap-gated policy evaluation).
  - The start table is the best whole arm (identity proof).
  - It fits against the opponent's population mix plus his table iterates, both sides together (fictitious play, step 3's swap rule).
- **In game:** `*strat-lookup*`, HARD only as now.
- **Online:** `fq-online.lisp` unchanged (η 0.05, cap 0.01). New checksums reset saved copies.

**Changes from §8.12-§8.19:**
- The opponent is a population, not the live table (round 5 step 2's best-response chasing).
- The cues gain SP.
- A time-out's terminal reward is -1 for both sides (0.1 x Δbalance paid for sitting on a lead).
- `:margin` hysteresis on (KI and KH flapped every other judgement).

## 5. Budget (to confirm)

- **Per run:** one pairing, two workspaces, at most 8 cell agents at once plus one Opus coordinator. That keeps a run under 10 agents.
- **Agent calls:** 24 cells a pairing-round; at most 2 rounds x 3 pairings = 144 cells (Sonnet for data, Opus for code); mirrors at most 36; about 9 coordinators and 3-4 Fable reviews (evaluator, admissions, fits).
- **Sim cost:** a HARD match 0.15-0.35 CPU-s (probe); a cell's evaluation (about 600 matches) about 3 CPU-min; a table fit (3 x 4,792 matches) about 1 CPU-h; the project about 20-30 CPU-h (guess).
- **Ask the user:**
  1. The task as in §2-§3.
  2. The scoring command and time-out = 0.
  3. The 4 x 3 grid, 2 rounds, W = 4.
  4. HARD only, or NORMAL too.
  5. That saved learning resets.

## 6. Gates and done

- **Strength:** on held-out 601-800 (400 matches), each new table beats `none` and the old live table, paired z ≥ 1.96, and does not lose to the opponent's anchor.
- **K.O. rate:** at least 90 % (reported; the pacing window is not gated, by the no-balance-gates rule).
- **Style:** `strat-desc.lisp` descriptors per character against bands set before round 1 (Hisagi's ranged-mode share inside 3 m at most 0.45, §8.17; Kenpachi's and Ichigo's bands: guess).
- **G2:** the lookup is HARD only and G2 does not run HARD (§8.9), so `--cvc` stays identical if new cues and code are off without a strategy. Verify after every runtime batch. A NORMAL lookup regenerates `tests/style-cvc-ref.txt`.
- **Determinism:** raw file = lookup (8 of 8 chunks); `snaptest` / `fulltest` for new style state; no random draw in judgements; host tests, pkgcheck, `./build.sh duel`, the browser `duel fq load` smoke.

## 7. Order

1. Record the plan in §11 and the DEVLOG; ask §5's five questions.
2. Fix the evaluator (`--ko-only`); re-measure the 3 x 3 baseline (`none`, the old lookup).
3. The SP cues and `:rb-sp`, off by default; host tests, G2 identical.
4. Empty the HARD lookup of stalling tables (the user's call: the shipped HARD CPU times out today).
5. `sp/eval.py`, the seed populations, the matrices; a 2-cell pilot.
6. Rounds for KI, KH, IH, a dream step between rounds.
7. The mirrors' sufficiency check, searches where needed.
8. Fit nine tables jointly; proofs, the lookup, the online smoke.
9. §6's gates, the playtest Artifact, docs.

**Top risks:**
- Stalling arms win any score that tolerates time-outs.
- A pure equilibrium again (§8.4) leaves the tables nothing to choose.
- Code cells borrow `ken-ki-style`, which stalls on other kits.
- Cells overfit their dev seeds (§8.8).
- A stale `duel.fas` rebuilds under running jobs (stale by mtime tonight).
