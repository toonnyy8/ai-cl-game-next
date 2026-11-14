# Plan 3: the re-collection after the exchange rules (DUEL_AI_STRATEGY §11, requested 2026-11-15)

The user (2026-11-15): 「要，請重新蒐集」. Standing answers kept: both sides co-evolved per pairing (KI, KH, IH; mirrors only if needed),
K.O.-only scoring, `:keep-state` on, HARD + NORMAL, playtest first, no balance gates.
PLAN.md and PLAN2.md stand where this file does not replace them. It replaces what is searched (§2), the loop (§3) and the budget (§4).
Guesses are marked.

**Probes run for this plan** (2026-11-15, about 40 CPU-min, HARD, K.O.s only; scratch drivers, not kept):
- Build: the working tree's `duel.fas`, hash `6cd131d205f3`. It holds the uncommitted `*cai-clash-delay*` batch, which moves only
  NORMAL's clash delay (HARD's 8 is its brain delay), so the HARD rows should hold after its commit: not proved.
- **Probe A**, `eval.py`, block 200, both seats, 200 matches a cell: each shipped table (`final/*.lisp`) and `none` against the opponent's
  shipped table and his `none`.
- **Probe B**, `strat-run.lisp` with `STRAT_SET` (the knob set for **both** seats), seeds 301-350, both seats, 100 matches a row: shipped
  table against shipped table under 8 settings of the shared exchange knobs.

## 0. What the probes say

**A. The old order is gone.** Counts are K.O. wins : K.O. losses : time-outs of 200, the row's side first.

| Side (table) | vs his table, 2026-11-14 | vs his table, now | vs his `none`, now | `none` vs his table, now |
|---|---|---|---|---|
| KI Kenpachi | 28 % (17 % held-out) | 12 : 188 : 0 | 93 : 102 : 5 (was 92.5 %) | 0 : 200 : 0 |
| KI Ichigo | 72 % | 188 : 12 : 0 | 200 : 0 : 0 | 102 : 93 : 5 |
| KH Kenpachi | 196 : 0 : 4 | **10 : 101 : 89** | 106 : 94 : 0 | 1 : 197 : 2 |
| KH Hisagi | 0 : 196 : 4 | **101 : 10 : 89** | 197 : 1 : 2 | 94 : 106 : 0 |
| IH Ichigo | 200 : 0 : 0 | 156 : 40 : 4 | 187 : 13 : 0 | 3 : 197 : 0 |
| IH Hisagi | 0 : 200 : 0 | 40 : 156 : 4 | 197 : 3 : 0 | 13 : 187 : 0 |
| KK | 100 : 100 : 0 | 100 : 100 : 0 | 151 : 45 : 4 | |
| II | 54 : 54 : 92 | 70 : 70 : 60 | 181 : 0 : 19 | |
| HH | 95 : 95 : 10 | 99 : 99 : 2 | 123 : 71 : 6 | |

- KH flipped (Hisagi now wins, and 45 % of the matches go to the bell). KI widened to 94 : 6. IH narrowed to 78 : 20.
- `none` against `none` in KI: 12 : 83 : **105** time-outs. The plain CPUs stall there now.
- A table still beats its own `none` against the opponent's table in every row, so the arms are stale, not useless.

**B. The shared exchange knobs move a pairing by 15-35 points, even set for both seats.** First-named side's K.O. wins : the other's : time-outs of 100.

| Setting (HARD default) | KI (K : I : t/o) | KH (K : H : t/o) | IH (I : H : t/o) |
|---|---|---|---|
| default | 7 : 93 : 0 | 9 : 47 : 44 | 81 : 18 : 1 |
| `*cai-clash-p*` 0 (0.6) | 23 : 77 : 0 | 24 : 23 : 53 | 97 : 3 : 0 |
| `*cai-clash-p*` 1 | 5 : 95 : 0 | 4 : 53 : 43 | 47 : 33 : 20 |
| `*cai-xch-sa-p*` 0.2 (0.65) | 21 : 79 : 0 | 23 : 10 : 67 | 89 : 3 : 8 |
| `*cai-xch-sa-p*` 1 | 2 : 98 : 0 | 3 : 70 : 27 | 66 : 34 : 0 |
| `*cai-xch-j*` AS 1 (0.6 / 0.4) | 25 : 75 : 0 | 17 : 22 : 61 | 80 : 12 : 8 |
| `*cai-xch-j*` J 1 | 1 : 99 : 0 | 6 : 51 : 43 | 67 : 33 : 0 |
| awaken breakers 0 (0.55 / 0.85) | 6 : 94 : 0 | 10 : 44 : 46 | 92 : 7 : 1 |

- No arm key reaches these knobs (§11.18: "No knob is a style key"). They are one hand-set value for nine pairings (§11.19: "No search").
- The settings pull the pairings in opposite directions (clash 0 helps Kenpachi and hurts Hisagi), so one global value cannot fit all.
- SE of a row is about 0.04-0.05. The big shifts are 3-5 SE; the awaken-breaker row in KI / KH is noise.

## 1. What carries over, what is void

**Carries over (no change):**
- `eval.py` (three opponent groups, K.O.-only, the cache), `pop.py` (`screen`, `matrix`), `band.py` (`write`, `fallback`, `pair`),
  `ship.py`, `final/units.py` / `add.sh` / `proofs.sh`, `arms/dump.lisp`.
- The runtime: `:rb-sp`, the band tables, `:keep-state`, the NORMAL windows (`*strat-table-chance*` 0.5, 600 steps), `fq-online.lisp`.
- The style knobs of §11.6 (KNOBS.md §6) and every style function merged in rounds 2 and IH 1.
- Every arm file in `arms/`, as population seeds. They load and play.
- The policy `policies/v1_rank_keep.py` and the world pool (82 closed cells in the six old workspaces). The pool's scores are the old
  rules', but the policy reads search dynamics (stagnation, depth), not scores. One dream step after the pilot adds the new traces.
- PLAN2's process rules: a cell reads only its own branch; only block 300 in a cell; block-200 rescoring before any admission; one
  candidate a branch to the admission block; few mechanism-driven variants; no off-policy fit decides an action.

**Void:**
- Every score, matrix and mix in `pop/*.json`, `final/README.md`, `ship/README.md`, `ih-r1-admission.md` (probe A).
- The one gaining table: KI Ichigo's `awake` band, z 0.00 on 1001-1200 (§11.18). It is not re-tested as a band.
- The ceilings that stopped two searches (KH Kenpachi 0.985, IH Ichigo 0.9917).
- The arm keys `:turn` / `:cont` and the styles' `*kk-as-read-p*` / `*iks-read-p*` inside a cancelled move (the shared clause owns it).
  Arms that differ only there now play alike: the fingerprint filter (§3) decides.
- The match cache: keyed by the build hash, so nothing stale can be read.

**The build guard:**
- `eval.py` rebuilds `duel.fas` when a source is newer (`simlib.build()`), then refuses to run unless the hash starts with `SP_BUILD`.
- The hash is of `duel.fas` and differs per checkout (ship/README.md). So `SP_BUILD` is set only in main's checkout; a code cell's worktree
  runs without it and the lead's rescore in main is the record.
- Before step 1: commit the pending batch. During a round nobody edits `duel/lisp` or `engine/lisp` in main (a build was running under
  this plan's probes today). A deliberate merge re-pins `SP_BUILD` after the older arms are proved identical (§11.8).

## 2. What to buy: exchange behaviour per pairing, inside the arm

**Decision: the budget goes to the shared exchange layer's knobs as arm keys, searched per pairing and side together with the style
knobs. Tables are the shipping format, not the search.**

Evidence from this repo:
- Tables over whole-game arms gained on 1 of 9 sides (§11.15), and that gain died with the first rule change (§11.18: z +3.19 → 0.00).
- The fit probe: 28 switching variants at or below the pure arm (§11.10). Round 3: 1 of about 12 bands replicated (§11.12).
- What did move sides: knobs that had never been tuned (KI round 1: 0.71 → 0.94, 0.61 → 0.95, §11.7) and code cells at a wall (§11.8, §11.14).
- The exchange knobs are today's untuned knobs. Probe B: 15-35 points from one knob, more than any band gave (about 4 points).
- A match now holds 15-79 cancels (§11.18), all played by one global setting.
- The exchange is a guessing game (AS beats carry, the reactive SA beats the AS, §11.18's matrices). Its knobs are probabilities, so a
  mixed equilibrium is one arm with interior values. PLAN §2's population loop finally has something to mix. (Guess: last time every
  equilibrium was pure.)

**Not bought:** a new off-policy fit, more whole-game band rounds on the old keys, MCTS changes, new cues.

**Step X1, one Opus code batch by the lead before any cell** (like §11.6):
- Keys: `:xch-sa-p`, `:xch-carry-p`, `:xch-j` (the J's weight; the AS takes the rest), `:clash-p`, `:clash-margin`, `:xch-sa-wait`,
  `:awaken-break-p`, `:awaken-kikon-p`. Read in `cai-xch-new`, `cai-xch-step`, `cai-clash`, `cai-awaken-break`. `brain-now` is already
  set before those clauses (core-ai.lisp CORE-BRAIN-STEP), so no plumbing.
- **As scales on the per-difficulty value** (`strat-scale`, as `:turn` / `:cont`), not replacements: EASY ≤ NORMAL ≤ HARD then holds by
  construction, and NORMAL's table windows do not jump to HARD's exchange. The lead's call; `style-dif` (replace) is the alternative.
- Proofs: no key, no change (host tests with the `style-knob.lisp` scan extended, pkgcheck, G2 identical, three arms x block 300
  byte-identical as a multiset); each key live (one arm + one key moves a group); KNOBS.md §6 gets the rows and ranges.
- Limit: an arm's `:rules` do not see the SP cues (cells, bursts, `:xch`: judgement-only, KNOBS.md). A key that depends on cells needs a
  band table (stage 2 below), not a rule.

## 3. The loop

**Stage 0, sim only (0 cells, about 3 CPU-h, guess).**
1. Commit pending work, X1, pin `SP_BUILD`.
2. `pop.py screen` then `pop.py matrix` for ki, kh, ih on block 200. Members: every old member, each final table's arm 0, `none`.
   The files in `pop/` are rewritten in place (the 2026-11-14 ones are at commit eb35b393).
3. Per side: the incumbent = the top of its mix. **Report (checkpoint 1): the three matrices, the incumbents, K.O. rates.**

**Stage 1, exchange rounds.** New workspaces `sp/x-<pair>-<S>/` (S = K, I, H); the old six stay as records.
- **Cell**: one arm = its parent plus deltas on the 8 exchange keys and the style keys. Sonnet, data only, no build. At most 8 `eval.py`
  calls a cell, block 300.
- **Grid**: 4 branches x 3 attempts, W = 4, `v1_rank_keep` (four roots, then the top three to full depth: 10 cells a side-round).
- **Roots, pre-registered by mechanism** (so branches do not copy each other): b0 the J side (`:xch-j`), b1 the NS side (`:xch-sa-p`,
  `:xch-carry-p`, `:xch-sa-wait`), b2 the clash and the awakening breakers, b3 the style keys re-tuned under the new rules.
- **Who searches**: both sides in the same round against the other's frozen population. A side whose incumbent scores ≥ 0.95 gets no
  cells that round (§11.13's allocation); it searches again once the other's admission pulls it under 0.90.
- **Seed blocks**: 300 the cells; 200 the lead's rescore and the matrices; 400 admission (cells never see it); 500 the spare; 801-1000
  band admission; 601-800 `ship.py` only. Blocks 1-200 are not used (§11.18-§11.20's hand tuning ran on low seeds); 1001-1200 is spent.
- **Admission** (the lead, after the coordinator's hand-back):
  1. rescore on block 200; the best per branch only goes on;
  2. block 400, `band.py pair` against the incumbent on the same seeds: pooled z ≥ 2.0, time-outs not above the incumbent's;
  3. `pop.py matrix` with the candidates: admitted if in the mix's support or a best response to an admitted column;
  4. the fingerprint and behaviour filter (DUEL_AI_STRATEGY §3, §11.5). No member is ever deleted.
- **A cycle** (a side's new best returns within 0.1 on every exchange key to a member it already had): stop that pairing. The lead writes
  one arm with the mix-weighted key values, sim only, and admits it if its worst group score is not below either extreme's.
- **Stop a pairing**: a round admits nothing on either side; or 2 rounds a side (3 in the full option); or a cycle.
- **Code cells** (Opus, own worktree): only when two data cells of a side report the same wall (§11.8). Kept for Kenpachi in KI / KH
  (6 % and 5 % of K.O.s) and for KH's stall.

**Order: KI is the pilot.** No time-outs (clean signal, cheap matches), the largest headroom on one side (Kenpachi 6 %), a side at the
ceiling to test the allocation rule. Then KH and IH in parallel workspaces.

**Stage 2, band specialists on exchange keys** (PLAN2 §1-§2 unchanged: `band.py write`, arm k = the incumbent plus exchange-key deltas,
bands `mycell`, `nocell`, `hisburst`, `awake`; admission on 801-1000, z ≥ 2.0). Only on a pairing whose stage 1 admitted, 8 cells a side
at most. A gaining table needs this stage; without it every side ships a constant table again, and is reported so.

**Shipping.**
- Per side: the final arm as `band.py fallback` (alternates and `none` at -0.05), or the stage-2 band table.
- **Ship test**, `ship.py`, once a side, seeds 601-800: `--table` the new table, `--arm0` **the table shipped today**, `--opp` his new
  final and `none`. Bars: pooled paired z ≥ 1.96; K.O. rate ≥ 90 % (reported; KH may miss it); not losing to his anchor. A side that
  fails keeps today's row.
- Mirrors: PLAN2's sufficiency check, sim only (the cross-pairing incumbents on both seats). II (60 of 200 to the bell) is reported.
- Into the game: `units.py`, `add.sh`, `proofs.sh` (raw file = lookup). The checksum resets saved learning again: tell the user.
- **NORMAL**: nothing tuned (the user: leave its strength). Report §11.18's EASY / NORMAL / HARD table (40 matches a cell) and NORMAL's
  K.O.s of 180 against today's 127.
- **G2**: identical after X1 (the proof). It moves once the lookup rows change (G2 is NORMAL): regenerate `tests/style-cvc-ref.txt`
  once at the end, native = browser, header note, every quote updated.
- Checks: host tests, pkgcheck, snaptest / fulltest with one new arm, `./build.sh duel`, smoke; the playtest Artifact before the long sims.

**Checkpoints (the main session reports to the user):**

| # | When | Report | Ask? |
|---|---|---|---|
| 0 | before any spend | §4's options; "are the exchange rules settled for now?" | yes |
| 1 | after stage 0 | the new matrices, incumbents, where the headroom is | no |
| 2 | after KI round 1 | what was admitted, held-out rows, the stop rule's verdict | only if it fires |
| 3 | after KH / IH | six sides: gain or not, K.O. rates, KH's stall | if KH is under 90 % |
| 4 | shipped | the ship rows, NORMAL's table, G2's new lines, the Artifact | no |

## 4. Budget

Per cell about 0.3 CPU-h (8 evaluations of 2-4 CPU-min; guess). Lead sims about 2 CPU-h a pairing (matrices, rescores, admissions, ship).
Wall time is not the limit (24 cores). Every option includes X1 (one Opus batch) and stage 0.

| Option | What | Cells (cap) | Opus code cells in it | Coordinators / Fable reviews | CPU-h (guess) |
|---|---|---|---|---|---|
| **Lean** | stage 0; KI pilot round (trailing side 10 + a 4-cell probe on the other); KH, IH one round on the trailing side; ship | 40 | ≤ 2 | 3 / 1 | 20 |
| **Standard** | lean + the second round wherever the first admitted (both sides answer) + stage 2 on the pilot pairing | 90 | ≤ 6 | 6 / 2 | 35 |
| **Full** | standard + a third round, stage 2 on all three pairings, II and HH searched (12 each) | 160 | ≤ 10 | 9 / 3 | 60 |

- **Last time**: 84 cells run (82 in six workspaces + the 2-cell pilot; about 5 of them Opus code cells) of PLAN's 144 + 36; about 60
  left unspent at the user's stop (§11.15). CPU was not recorded; PLAN guessed 20-30 CPU-h.
- **Recommendation: Standard.** The stop rules make its expected spend 55-70 cells (guess). Lean finds each trailing side's first
  answer but never lets the leader respond, so it ships half a co-evolution: the next best response is unknown. Full buys mirrors and
  bands on evidence that does not exist yet; it can be bought at checkpoint 3.

## 5. Risks, and what shows them early

| Risk | Seen at | Then |
|---|---|---|
| The rules change again and void the collection (§773-§778: six changes in two days) | checkpoint 0's question; any merge touching `core*`, `xch-ai`, `combat`, a kit | finish the round on its pin; rerun stage 0 (sim only). A second time: pause and ask |
| Per-side exchange keys do not replicate (probe B set both seats) | KI round 1: nothing passes block 400 at z ≥ 2.0 with Kenpachi at 6 % | stop; ship stage 0's incumbents only (the lean floor); tell the user |
| A key at 0 or 1 shifts the random stream, so a gain is seed luck (PLAN2) | block 300 → 200 → 400 disagree | the paired test on 400 decides; ≤ 8 evaluations a cell |
| Stalling wins by denial (KH 45 % to the bell today) | time-outs per group in every `eval.py` line | not admitted with more time-outs than its parent; K.O. rate reported at checkpoint 3 |
| Best responses cycle | the cycle rule in §3 | the mixed arm, sim only |
| A side sits at the floor against the other's new arm (Hisagi last time) | two data cells report one wall | one code cell; if it fails, report: a balance matter, the user's |
| NORMAL moves although the user left it | checkpoint 4's table against 127 of 180 | scales keep the order; `*strat-table-chance*` is the one knob, the user's call |
| `duel.fas` rebuilt under running cells | `SP_BUILD` guard: the cell exits | no source edits in main during a round |
| The coordinator cannot spawn agents (§11.5) | — | the main session dispatches cells; an Opus subagent does rescoring and admission and hands back |

## 6. Order

1. Checkpoint 0: the option, the rules question.
2. Commit the pending batch. X1 with its proofs. Pin `SP_BUILD`. Record §11.21 and a DEVLOG §.
3. Stage 0: screens, matrices, incumbents. Checkpoint 1.
4. KI round 1 (pilot). Admission. One dream step. Checkpoint 2.
5. KH and IH round 1. Admission.
6. Second rounds where a first admitted (standard). Stage 2 on the pilot pairing. Checkpoint 3.
7. Final tables, ship tests, mirrors' sufficiency, the lookup rows, proofs.
8. NORMAL's table, G2 regenerated, checks, the playtest Artifact. Checkpoint 4. Docs, commit, push.
