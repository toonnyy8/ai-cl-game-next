#!/usr/bin/env python3
# brief.py — one cell's brief for the KH style-code search (DUEL_AI_STRATEGY §8.19 round 5, step 5): the dream-rsi exploration prompt
# (assets/exploration_prompt.md, Listing 1 of arXiv:2609.14858) + this project's rules. Prints it.
# usage: brief.py <cell> <round> ['<work-order JSON>']     (step.sh calls it)
import json, os, re, sys

TOP = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(TOP))))
REL = os.path.relpath(TOP, REPO)
ECL = os.environ.get('ECL_HOST', '/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl')
SCRATCH = os.environ.get('KHFN_SCRATCH', '/tmp/claude-1000/-media-8tsp-projects-ai-cl-game-next/ae4fc6c9-5486-4f14-9b2d-a6ec715b6738/scratchpad')
cell, rnd = sys.argv[1], int(sys.argv[2])
work = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
THEMES = ['closing on his chain range: getting in through the Shikai\'s mid range and the Bankai\'s ranged mode, and staying in',
          'two codes in one style: deciding by form and situation where Ichigo\'s KI code or his own plays (step 4: Ichigo\'s code won his '
          'base form), plus what neither does against Hisagi',
          'his Bankai\'s bind and ranged mode: escaping the bind, punishing WA / TABA / TATAKI and the DRIVE switch',
          'resources against Hisagi: when to awaken, how to climb L and when to cash out, Reishi and the Burst']
branch = work['branch'] if 'branch' in work else int(re.match(r'b(\d+)', cell).group(1))
direction = work.get('direction') or f'lean on: {THEMES[branch % 4]}'
parent = work.get('parent_dir')
parent = os.path.abspath(parent) if parent else '(none: this cell opens a new direction from BASELINE_DIR)'
node = f'{REL}/rounds/round{rnd:02d}/nodes/{cell}'
hist = ' '.join(os.path.abspath(h) for h in work.get('history_dirs', [])) or '(none: round 1)'
FILE = 'cpu-kh-ken.lisp'

print(f"""You are one discovery cell of a Dream-RSI search (arXiv:2609.14858) writing a new STYLE FUNCTION for KENPACHI ZARAKI (roster 1)
against SHUHEI HISAGI (roster 7) in SOUL DUEL, HARD. Reply to the coordinator in English; the user does not read your output directly.

You must read every historical proposal before proposing or implementing a new solution.

Direction hint (structural, not a recipe): {direction}

# The cell
- Cell {cell}, round {rnd}. Target file (EVAL_PROGRAM): duel/lisp/{FILE} (the only source file you may change).
- PARENT_DIR = {parent}
- Sibling attempts of this round: {TOP}/rounds/round{rnd:02d}/nodes/b*_a*/ (exclude your own NODE_DIR)
- HISTORY_DIR = {hist}
- BASELINE_DIR = {TOP}/baseline  (the starting {FILE}: his KI style CPU unchanged; proposal.md, score.json; proposal.md also gives the
  references (Ichigo's KI code on Kenpachi, the live KH table) and THE KEEP RULE, fixed before round 1: read it)
- NODE_DIR (yours) = {node}  — RELATIVE TO YOUR OWN WORKTREE ROOT
- EVAL_COMMAND (in your worktree root): python3 {REL}/eval.py --seed0 300 -j 5

You work in your own git worktree (the main branch: every rule and the evaluator's opponents are fixed there). The search's scaffold is
not committed, so first, in your worktree root:
1. mkdir -p {REL} && cp {TOP}/eval.py {TOP}/cand-khfn.lisp {REL}/   (the evaluator and the strategy that plays the function)
2. insert the line lisp/{FILE} into duel/MANIFEST right after the line lisp/cpu-hisagi-range.lisp (edit that one line; don't copy
   another checkout's MANIFEST)
3. if PARENT_DIR is a directory, cp PARENT_DIR/{FILE} duel/lisp/{FILE}; else cp BASELINE_DIR/{FILE} duel/lisp/{FILE}; then touch it.

# Step 1. Read the complete history first
(Context budget: read each proposal's summary, mechanism and measurement first and its score.rescored.json; read whole files only for the
cells your direction builds on; grep big files rather than reading them end to end. Keep your proposal.md under about 150 lines.)
Read every proposal.md under the sibling attempts, HISTORY_DIR and BASELINE_DIR, each with its score.rescored.json (the coordinator's
re-measure on the search seeds: THE number). Trust the measured result over what a proposal claims. For a failure, work out whether the idea
was flawed or let down by a bug or a parameter (locate the bug before retrying). Don't converge on small tweaks of one mechanism with
flattening returns: prefer a structurally different mechanism, a new combination of pieces that worked, or a targeted fix. Never a repeat.

# Step 2. The game (read, don't skim)
- docs/duel/DUEL_AI_STRATEGY.md §2 (cues), §9 (strategies carry code: the :fn contract), §10 (style units), §8.19's "Round 5, step 4" (the
  joint KH / HK search: which whole arms won what; Kenpachi's best whole arm against Hisagi's live table was Ichigo's KI code, 0.205, his own
  0.105; Hisagi's tables lean on his press arm and on Kenpachi's KI code).
- docs/duel/DUEL_CORE.md (the two-button system: NA / NS / AS / SA, the SP pointer, the Kikon hold, Hoho, Burst, awakening);
  docs/duel/DUEL_HISAGI.md (his kit: the Shikai's chain-sickle range, the Bankai's ranged mode and bind, WA / TABA / TATAKI, the DRIVE
  switch); Kenpachi's docs docs/duel/DUEL_KEN_CORE.md, DUEL_KEN_V3.md, DUEL_KEN_BANKAI.md.
- duel/lisp/cpu-ki-ken.lisp (his KI style CPU, written against Ichigo: ken-ki-style and its helpers), duel/lisp/cpu-ki-ichigo.lisp (Ichigo's,
  ichigo-ki-style), duel/lisp/cpu-hisagi-range.lisp (Hisagi's ranged-mode code: what he does at range), duel/lisp/core-ai.lisp
  (core-brain-step: the :fn runs first; NIL falls to the MCTS, mc-neutral, then the generic CPU), duel/lisp/fuzzy.lisp, strategy.lisp
  (strat-feats: the cues).

# The task and the score (frozen: {REL}/eval.py)
Write ken-kh-style (e b f kit s d) -> T when it decided this step, NIL to leave the step to the MCTS / generic CPU. It may call any existing
function (ken-ki-style, ichigo-ki-style, their helpers, the core CPU's cai-* / ai-press / kk-* ...) and define its own helpers and knobs in
{FILE}. Its per-match state: (brain-style b) belongs to whichever style function owns it (ken-ki-style keeps a KKS struct there and resets it
when *match-tick* goes back); if you delegate to ken-ki-style keep your own state elsewhere (e.g. a hash table keyed by the brain, reset when
*match-tick* goes back), or don't delegate and own brain-style yourself.
score = (live + iterates + arms) / 3: Kenpachi (HARD, playing `(:id :khfn :fn ken-kh-style)` whole) against Hisagi's pool, both seats; each
group's share (wins + 1) / (matches + 2): his live table :qhs-ken (100 seeds a seat), step 4's two HK iterates (50 each), his 11 step-4
candidate arms played whole (25 each); 950 matches. The baseline (his KI code unchanged) scores in BASELINE_DIR/score.json. The JSON's
"members" gives each opponent's share. The keep rule after the search (the user: 「高內聚，低耦合」): one recognisable job, useful across the
whole pool (not against one table), not a near-duplicate of ken-ki-style / ichigo-ki-style; so a cell that only re-tunes one of them, or only
picks between them, will not be kept even if it scores.

# Step 3. Propose and implement, in duel/lisp/{FILE} ONLY
Rules:
- every chance scales by difficulty EASY <= NORMAL <= HARD (the brain's difficulty); roll ONCE PER EVENT (a move start, a situation's start),
  never per step (a per-step chance is a certainty within a second); a reaction slower than the threat never fires.
- read Hisagi only through the perceived SNAP S, the distance D and the brain's perception (no reading his inputs, no debug knobs, no seed /
  tick special cases, nothing keyed to the evaluator or its pool).
- determinism: random numbers only via SIM-RND01 or the brain's rolls (brain-roll / brain-chance), never RND01 / RANDOM.
- every tunable is a `defparameter` with a docstring; nothing outside {FILE} changes (no other pairing may move).
- {FILE} holds only defparameter / defvar / defconstant / defun / defmacro / defstruct / inline-readers forms: NO other top-level call, and in
  particular NO cai-defstyle (registering a matchup style would turn the style on for the shipped CPU and the live table's NIL arm; the
  coordinator's rescore checks that the live lookup's own share did not move, and a cell that moves it is recorded as a correctness failure).

# Step 4. Evaluate honestly
1. {ECL} --norc --load tests/duel-rules-test.lisp must print ALL PASS.
2. touch duel/lisp/{FILE}, then compare variants with EVAL_COMMAND (dev seeds, seed0 300); `--scale 0.5` for quick looks (475 matches).
   The first run builds the native sim (~2 min, again after every change). Three other cells run on this machine at once: keep -j 5. A
   score moves about +-0.02 between blocks with the draw alone; prefer a gain that holds at --scale 1.
3. Your result is the LAST file you deliver and its LAST full EVAL_COMMAND JSON; the coordinator re-measures it on the search seeds (seed0
   200); a held-out block exists that neither of you sees. Never edit eval.py, tools/, tests/ or anything the evaluator reads.

# Deliverables (inside YOUR worktree at NODE_DIR; the coordinator copies them)
- NODE_DIR/{FILE}: your final duel/lisp/{FILE}
- NODE_DIR/proposal.md: the job of the style in one line, the mechanism, the evidence from history, why it is not a repeat nor a
  near-duplicate of the KI codes, the measurement (score, groups, members vs the baseline), the expected benefit and the risks.
- NODE_DIR/score.json: the exact JSON line the final EVAL_COMMAND printed.
Scratch files go under {SCRATCH}/khfn-{cell}/ (if that is not writable from your worktree, a git-ignored dir inside it, e.g. build/khfn-{cell}/),
never in NODE_DIR or the repo root. If a shell command is refused as too complex, split it into plain commands or put it in a script file. Do not commit, push, merge or open PRs. Never run pkill /
kill / killall / pkill -f / pgrep -f; bounded waits only (wait on a PID or with a timeout).

# Report back
A short STYLE paragraph first (how this Kenpachi plays against Hisagi, in a player's words, and what differs from earlier cells), then the
exact JSON line of the final evaluation (do not round or improve it), the absolute path of your worktree, and on failure the failure class
(compile_other, correctness, runtime, resource) with the error text.
""")
