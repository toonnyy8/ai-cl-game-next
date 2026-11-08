#!/usr/bin/env python3
# brief.py — one counter-strategy cell's brief (DUEL_AI_STRATEGY §8.7): the dream-rsi exploration prompt (Listing 1 of
# arXiv:2609.14858) + this project's rules. Prints it.   usage: brief.py <ws> <cell> <round> '<work-order JSON>'
import json, os, re, sys
TOP = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(TOP))))
WS = json.load(open(os.path.join(TOP, 'workspaces.json')))
ws, cell, rnd = sys.argv[1], sys.argv[2], int(sys.argv[3])
work = json.loads(sys.argv[4]) if len(sys.argv) > 4 else {}
w = WS[ws]; me, vs = w['char'], w['vs']
node = os.path.join(TOP, ws, 'rounds', f'round{rnd:02d}', 'nodes', cell)
parent = os.path.abspath(work['parent_dir']) if work.get('parent_dir') else '(none: this cell opens a new direction)'
hist = ' '.join(os.path.abspath(h) for h in work.get('history_dirs', [])) or '(none: round 1)'
R2 = rnd >= 2
DEV = f"python3 tools/strategy-switch.py --char {me} --vs {vs} --cand <file> --seed0 800 --seeds {100 if R2 else 50} -j 5" + (" --max-own 0.6" if R2 else "")
BASE = os.path.join(TOP, ws, 'baseline-r02' if R2 else 'baseline')
print(f"""You are one discovery cell of a Dream-RSI search (arXiv:2609.14858) for COUNTER STRATEGIES in SOUL DUEL: {me.upper()} against
{vs.upper()}, HARD. Reply to the coordinator in English; the user does not read your output.

You must read every historical proposal before proposing or implementing a new solution.

# The cell
- Cell {cell}, round {rnd}. Repo root: {REPO} (work there; no worktree: you only write data files).
- NODE_DIR (yours) = {node}
- PARENT_DIR = {parent}
- Sibling attempts: {TOP}/{ws}/rounds/round{rnd:02d}/nodes/b*_a*/ (exclude your own NODE_DIR)
- HISTORY_DIR = {hist}
- BASELINE_DIR = {BASE} (the incumbent: what {me} plays now, its measured share, proposal.md)
- Library (read-only, existing strategies you may borrow from or name): docs/research/strategy-drsi/seeds/*.lisp and README.md

# What you are searching for
{me} at HARD now plays the shipped CPU (the incumbent, BASELINE_DIR). A COUNTER STRATEGY is a strategy file plus `:own`, the situations it
claims. In a match the CPU plays the incumbent everywhere, and switches to your strategy while `:own` fires (>= 0.5), judged every 90 ticks
(1.5 s) in neutral and held in between (DUEL_AI_STRATEGY §8.7). Your goal: find situations where something else beats the incumbent, and the
strategy that does, so the composite out-wins the incumbent. Claiming everything just replaces the incumbent (rarely better); claiming
nothing scores the incumbent exactly. The best counters own a slice where the incumbent is weak.

{('''# Round 2: what changed (DUEL_AI_STRATEGY 8.8, 8.9) — read this first
- The incumbent is NEW: round 1's best whole-game replacement went into the game's HARD lookup (BASELINE_DIR says which). Round-1 numbers
  were against the old incumbent: they are evidence about mechanisms, not on this round's scale.
- THE CAP: a candidate whose :own fires on more than 60 % of the judgements scores as the incumbent (JSON "capped": true). You are looking
  for a SITUATIONAL counter: a slice where something else beats the incumbent.
- Round 1's lessons: picked dev gains of +0.05-0.15 shrank to ~0 on fresh seeds (overfitting 100 matches); dev now has 200 matches, still
  prefer a candidate whose effect holds on a second dev block (seed0 900, 50 seeds) over the best of many; under a `:fn` the `:b-` biases
  and rules are inert and only `:range` acts; data-only strategies win ~0 against a KI style CPU; a sub may now use a different `:fn` from
  the incumbent's (the state crash is fixed). Distinct strategies are welcome: another character's KI style, a kite, a rush.

''' if R2 else '')}# Step 1. Read the complete history first
Read every proposal.md under the sibling attempts, HISTORY_DIR and BASELINE_DIR with its score.json (the coordinator's measure on the search
seeds: THE number). For each past attempt note the mechanism (which situations, which strategy) and how it did; for a failure work out
whether the idea was flawed or let down by a parameter. Don't converge on small tweaks of one mechanism with flattening returns: prefer a
structurally different slice or strategy, or a new combination of pieces that worked. Never a repeat or a rename. Keep reading lean
(summaries and measurements first); keep your proposal.md under ~120 lines.

# Step 2. The format (read, don't skim)
- docs/duel/DUEL_AI_STRATEGY.md §2 (format, cues, outputs), §8.3 (what data cannot express), §8.5 (the situation check: bins and what won
  where), §8.7 (this search), §9 (`:fn`).
- duel/lisp/strategy.lisp (`strat-value`, `strat-feats`: the cues and how they are computed) and duel/lisp/fuzzy.lisp (the fuzzy sets of
  each cue, e.g. :lead :behind/:even/:ahead, :mr :low/:high, :dj :in/:reach/:out/:afar, :ost :free/:startup/:active/:evade/:down).
- docs/research/strategy-drsi/sitcheck/analysis.txt (which fixed strategy won which bin, per pairing; a signal, not proof).
- A strategy may name an existing `:fn` (the KI style CPUs: `ken-ki-style` for Kenpachi vs Ichigo, `ichigo-ki-style` for Ichigo vs
  Kenpachi; see seeds/s5, s6 and duel/lisp/cpu-ki-*.lisp) plus `:base` / `:rules`. No new Lisp code: data only (the user's call).

# Step 3. Propose and implement: NODE_DIR/cand.lisp
One plist: `(:id :<short-name> :own (ANTECEDENT ...) [:fn F] :base (...) :rules (...))`; ANTECEDENT is a list of (CUE SET) pairs, AND within
one, OR across the list (the `:rules` antecedent format). Every value a number, no reader tricks.

# Step 4. Evaluate honestly
- Compare variants on the DEV seeds only: `{DEV}` (JSON: comp vs inc wins on the same seeds, gain, paired b / c and z, own_share).
  {'~200 matches: a gain under ~0.04 is noise there.' if R2 else '~100 matches: a gain under ~0.05 is noise there.'} The search seeds (seed0 600) are the coordinator's; held-out seeds exist that
  neither of you sees. Don't tune to them.
- Three other cells run on this machine at once: keep -j 5. The native build is shared: never rebuild it, never edit tools/, duel/,
  tests/ or anything the evaluator reads.
- The coordinator re-measures NODE_DIR/cand.lisp on the search seeds; that is your score (the composite's win share).

# Deliverables (in NODE_DIR)
- cand.lisp (your final candidate)
- proposal.md: the slice (`:own`) and why, the strategy and why, the evidence from history and the dev runs, why it is not a repeat,
  expected benefit and risk.
- dev.json: the exact JSON of the final dev run of cand.lisp.
Scratch files go under /tmp/claude-1000/-media-8tsp-projects-ai-cl-game-next/ae4fc6c9-5486-4f14-9b2d-a6ec715b6738/scratchpad/counter-{ws}-{cell}/,
never in NODE_DIR. Do not commit, push or deploy. Never run pkill / kill / killall / pkill -f / pgrep -f; bounded waits only (wait on a
PID or with a timeout).

# Report back
One paragraph: the slice, the strategy, what differs from earlier cells; then the exact final dev JSON (do not round or improve it); on
failure the failure class (correctness, runtime, resource) and the error text.
""")
