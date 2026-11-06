#!/usr/bin/env python3
# brief.py — one KI matchup cell's brief (DUEL_MATCHUP_AI §7): the dream-rsi exploration prompt (assets/exploration_prompt.md,
# Listing 1 of arXiv:2609.14858) + this project's rules. Prints it.
# usage: brief.py <side ken|ichigo> <cell> <round> ['<work-order JSON>']     (step.sh calls it)
import json, os, sys

TOP = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(TOP)))
REL = os.path.relpath(TOP, REPO)
ECL = os.environ.get('ECL_HOST', '/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl')
FREEZE = open(os.path.join(TOP, 'FREEZE')).read().strip()
side, cell, rnd = sys.argv[1], sys.argv[2], int(sys.argv[3])
work = json.loads(sys.argv[4]) if len(sys.argv) > 4 else {}
other = 'ichigo' if side == 'ken' else 'ken'
WHO = {'ken': 'KENPACHI ZARAKI (roster 1) against ICHIGO KUROSAKI', 'ichigo': 'ICHIGO KUROSAKI (roster 3) against KENPACHI ZARAKI'}[side]
FILE = f'cpu-ki-{side}.lisp'
THEMES = {'ken': ['封印肉搏 the sealed brawl (brawl)', '解放攀升 the Shikai climb (shikai)', '卍解爆發 the Bankai cash-out (bankai)',
                  '破月牙 anti-Getsuga (antiwave)'],
          'ichigo': ['間合い管理 spacing (spacing)', '揮空反擊 whiff punish (whiff)', '指針三狩魂 pointer 3 (ptr3)', 'KESSA 強攻 (kessa)']}[side]
import re
branch = work['branch'] if 'branch' in work else int(re.match(r'b(\d+)', cell).group(1))
# structural hints only (DREAM_RSI §5.11): which approved theme this branch leans on; never a tactic
direction = work.get('direction') or f'lean on theme {THEMES[branch % 4]} while keeping the other three usable'
parent = work.get('parent_dir')
parent = os.path.abspath(parent) if parent else '(none: this cell opens a new direction from BASELINE_DIR)'
node = f'{REL}/{side}/rounds/round{rnd:02d}/nodes/{cell}'
hist = ' '.join(os.path.abspath(h) for h in work.get('history_dirs', [])) or '(none: round 1)'

print(f"""You are one discovery cell of a Dream-RSI search (arXiv:2609.14858) tuning the matchup style CPU of {WHO} in SOUL DUEL
(the KI pairing). Reply to the coordinator in English; the user does not read your output directly.

You must read every historical proposal before proposing or implementing a new solution.

Direction hint: {direction}

# The cell
- Cell {cell}, round {rnd}. Target file (EVAL_PROGRAM): duel/lisp/{FILE} (the only file you may change).
- PARENT_DIR = {parent}
- Sibling attempts of this round: {TOP}/{side}/rounds/round{rnd:02d}/nodes/b*_a*/ (exclude your own NODE_DIR)
- HISTORY_DIR = {hist}
- BASELINE_DIR = {TOP}/{side}/baseline  (the round's starting style file, proposal.md, score.json)
- The opponent this round: {TOP}/{other}/champion/cpu-ki-{other}.lisp (the other side's best so far; the coordinator rescores with it)
- NODE_DIR (yours) = {node}  — RELATIVE TO YOUR OWN WORKTREE ROOT
- EVAL_COMMAND (in your worktree root): python3 tools/matchup-eval.py --side {side} --seeds 40 -j 4

You work in your own git worktree checked out at the freeze commit {FREEZE} (the evaluator and every rule are fixed there). First:
1. copy {TOP}/{other}/champion/cpu-ki-{other}.lisp over duel/lisp/cpu-ki-{other}.lisp in your worktree (the opponent this round);
2. if PARENT_DIR is a directory, copy PARENT_DIR/{FILE} over duel/lisp/{FILE}; else copy BASELINE_DIR/{FILE} there;
then `touch` both files (the native build goes by mtime).

# Step 1. Read the complete history first
Read every proposal.md under the sibling attempts, HISTORY_DIR and BASELINE_DIR in full, each with its score.rescored.json (the
coordinator's re-measure: THE number) and score.json. Trust the measured result over what a proposal claims. For each past attempt
note the mechanism and how it did; for a failure, work out whether the idea was flawed or let down by a bug or a parameter (locate the
bug in the code before retrying). Don't converge on small tweaks of one mechanism with flattening returns: prefer a structurally
different mechanism, a new combination of pieces that worked, or a targeted fix of a located bug. Never a repeat or a rename.

# Step 2. The game and the plan (read, don't skim)
- docs/duel/DUEL_MATCHUP_AI.md: §3 what the matchup turns on, §4 the four approved styles and the signature table, §5 the hook, §6 how
  each situation is detected and the baseline, §7 this search.
- docs/research/ki-ai/{side}/means.md, catalogue.md (sim-verified routes with trial names; tools/combo-trial.py replays any trial
  file), sheet.md; and the other side's means.md for what the opponent does.
- duel/lisp/core-ai.lisp (the generic CPU the style falls back to; `*cai-styles*`), duel/lisp/{FILE} (the style as it is).

# The score (tools/matchup-eval.py --side {side}; frozen)
score = (0.4 strength + 0.6 signature) x the NORMAL factor (the user: 「勝率 0.4 / 招牌 0.6」):
- strength: HARD, your CPU against the opponent file above, 40 seeds x both seats: your win share.
- signature: the mean of four situation success rates (the user: 「四種主題不用完全均衡，但請讓 CPU 能在需要的時候有效利用對應的工具」):
  {'; '.join(THEMES)}. A theme whose situation never came up scores 0. The JSON's "themes" gives rate / ok / occ each.
- NORMAL factor: NORMAL, your CPU against the opponent's GENERIC CPU, both seats: your win share inside the band around the shipped
  CPU's (JSON "normal") -> x1, falling to 0 at 0.15 outside. NORMAL must stay near the shipped CPU: the style lives at HARD.

# Step 3. Propose and implement, in duel/lisp/{FILE} ONLY
The four styles are the user's choice (DUEL_MATCHUP_AI §4): tune them and improve how they are carried out (knobs, thresholds, the mix,
the routes chosen, timing, fixing a located bug in the style's code). No new style, nothing outside this file. Every tunable stays a
`defparameter` with a docstring. Rules:
- every chance scales by difficulty EASY <= NORMAL <= HARD; roll ONCE PER EVENT (a move start, a situation's start), never per step (a
  per-step chance is a certainty within a second, DREAM_RSI §5.5); a reaction slower than the threat never fires.
- read the opponent only through the perceived SNAP and the distance the style function is given, plus your own fighter's state; no
  reading inputs, no debug knobs, no seed / tick special cases, nothing keyed to the evaluator or its situation detector.
- determinism: random numbers only via SIM-RND01 (or the brain's event rolls), never RND01 / RANDOM.
- other pairings must not change: your file only registers {side}'s style against {other}.

# Step 4. Evaluate honestly
1. {ECL} --norc --load tests/duel-rules-test.lisp must print ALL PASS.
2. touch duel/lisp/{FILE}, then compare variants at 20 seeds a seat (`--seeds 20`, the user's rule), PAIRED on the same seeds; a
   40-seed score moves about +-0.02 with the draw alone. The first run builds the native sim (~2 min). Three other cells of your side
   and four of the other side run on this machine at once: keep -j 4.
3. Your result is the LAST file you deliver and its LAST 40-seed JSON (`--seeds 40`); the coordinator re-measures it anyway.
Never edit tools/matchup-eval.py, tools/simgate/*, or anything they read.

# Deliverables (inside YOUR worktree at NODE_DIR; the coordinator copies them)
- NODE_DIR/{FILE}: your final duel/lisp/{FILE}
- NODE_DIR/proposal.md: the mechanism, the evidence from the history, why it is not a repeat, the measurement (each part, each theme,
  normal vs the baseline), the expected benefit and the risks.
- NODE_DIR/score.json: the exact JSON line the 40-seed EVAL_COMMAND printed for that final file.
Scratch files go under scratchpad/ki-{side}-{cell}/, never in NODE_DIR. Do not commit, push, merge or open PRs. Never run pkill / kill /
killall / pkill -f / pgrep -f; bounded waits only (wait on a PID or with a timeout).

# Report back
A short STYLE paragraph first (how this CPU plays, in a player's words, and what differs from earlier cells), then the exact JSON line of
the final evaluation (do not round or improve it), the path of your worktree, and on failure the failure class (compile_other,
correctness, runtime, resource) with the error text.
""")
