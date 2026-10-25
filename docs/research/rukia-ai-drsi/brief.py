#!/usr/bin/env python3
# brief.py — one dream-rsi cell's brief for Rukia's CPU search (DUEL_RUKIA_TYBW §17): the skill's exploration prompt
# (assets/exploration_prompt.md, Listing 1 of arXiv:2609.14858) + this project's rules. Prints it.
# usage: brief.py <cell> <round> ['<work-order JSON>']     (step.sh calls it with next-batch's work item)
# (adapted from docs/research/hisagi-ai-drsi/brief.py; lessons: docs/guides/DREAM_RSI.zh-TW.md §5)
import json, os, sys

WS = os.path.dirname(os.path.abspath(__file__))                  # this workspace, in the coordinator's checkout
REPO = os.path.dirname(os.path.dirname(os.path.dirname(WS)))     # that checkout's root
REL = os.path.relpath(WS, REPO)                                   # docs/research/rukia-ai-drsi
ECL = os.environ.get('ECL_HOST', '/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl')
CFG = json.load(open(os.path.join(WS, 'config.json')))
EVAL = CFG.get('eval_command', 'python3 tools/aieval.py --char 2 --seeds 40 -j 2')
FREEZE = os.environ.get('FREEZE', '(the freeze commit: see the README)')

# The user (2026-10-25): explore the tactics by condition (the opponent, the distance, the gauges ...), planned from every
# character's frame data and reach, improved step by step; where several options pay, pick among them by probability
# weighted by their payoff. Structural hints only (DREAM_RSI §5.11): the condition axis a branch opens, no tactics.
STYLES = {0: 'primary axis: the opponent and his form (matchup tables from the frame data and reach)',
          1: 'primary axis: her resources and his state (layers, bars, flash step, red, the cash-out after a confirmed hit)',
          2: 'primary axis: the distance bands (spacing, the kido and the seal at mid range, neutral to close)',
          3: 'primary axis: the awakening and her three bands (when to awaken, each band\'s own tactics, the cold)'}

cell, rnd = sys.argv[1], int(sys.argv[2])
work = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
rel_node = f'{REL}/rounds/round{rnd:02d}/nodes/{cell}'
parent = work.get('parent_dir')
parent = os.path.abspath(parent) if parent else '(none: this cell opens a new direction from BASELINE_DIR)'
branch = work.get('branch', int(cell[1:cell.index('a')]) if cell.startswith('b') and 'a' in cell else 0)
direction = work.get('direction') or STYLES.get(branch % 4, '')
BASE = 'baseline' if rnd < 2 else f'baseline-r{rnd:02d}'

print(f"""You are one discovery cell of a Dream-RSI search (arXiv:2609.14858) redesigning the CPU AI of KUCHIKI RUKIA (SOUL
DUEL, kit :rukia, roster index 2: the Shikai and her three awakened bands -18 / -50 / -273). Reply to the coordinator in
English; the user is not reading your output directly.

You must read every historical proposal before proposing or implementing a new solution.

# The cell
- Cell {cell}, round {rnd}. Target file (EVAL_PROGRAM): duel/lisp/rukia-ai.lisp (her whole CPU: the four forms' :ai
  plists *RU-AI-BASE* .. *RU-AI-ZERO*, the RUKIA-AI-* functions, the *AI-RU-...* knobs).
- PARENT_DIR = {parent}
- HISTORY_DIR = {WS}/rounds   (every earlier cell: proposal.md, score.json, score.rescored.json, rukia-ai.lisp)
- BASELINE_DIR = {WS}/{BASE}  (the frozen rukia-ai.lisp, score.json: the shipped CPU's parts at 40 seeds)
- NODE_DIR (yours) = {rel_node}  — a path RELATIVE TO YOUR OWN WORKTREE ROOT (see Deliverables)
- EVAL_COMMAND (in your worktree root): {EVAL}
- Direction hint: {direction or '(none)'}

You work in your own git worktree checked out at the freeze commit {FREEZE} (the evaluator, the opponents' CPUs and every
rule are fixed there). HISTORY_DIR and BASELINE_DIR are in the coordinator's checkout: read them there. If PARENT_DIR is a
directory, first copy PARENT_DIR/rukia-ai.lisp over duel/lisp/rukia-ai.lisp in your worktree and, when
PARENT_DIR/duel-rules-test.lisp exists, splice ONLY its RUKIA-CPU-TESTS section into your frozen tests/duel-rules/rukia.lisp:
python3 {REL}/splice-tests.py PARENT_DIR/duel-rules-test.lisp tests/duel-rules/rukia.lisp /dev/null ; then refine it; else
start from the worktree's files (= BASELINE_DIR/rukia-ai.lisp and the frozen test).

# Step 1. Read the complete history first
Read every proposal.md under HISTORY_DIR (all rounds, all cells except your own) and BASELINE_DIR, in full, with its
score.rescored.json (the coordinator's re-measure with the frozen evaluator: THE number) and score.json. Trust the measured
result over a proposal's claims. For every past attempt note the mechanism and how it did; for a failure work out whether
the idea was flawed or let down by a bug or a parameter (locate the bug in the code before retrying it). Don't converge on
small tweaks of one mechanism with flattening returns: prefer a structurally different mechanism, a new combination of
pieces that worked, or a targeted fix of a located bug. Never a repeat or a rename.

# Step 2. Plan from the frame data (the user's order: 「請先以每個角色的幀數表、攻防距離等等資訊為基礎來規劃策略並逐步改進」)
The planning base is in docs/research/rukia-cpu/ (read it before designing):
- sheet-shikai.md (her Shikai's data sheet: every move's frames, advantage, reach, cancels), opponents/<char>-<form>.md
  (every other form's sheet, and her bands' -m18 / -m50 / -zero), matchups-shikai.md (per opponent form: his J1 / K1 startup
  and far edge, his fastest hit, his longest reach, what her J1 punishes on his block, his safe pokes);
- catalogue-shikai.md and catalogue-awakened.md: her combos and means VERIFIED in the sim (damage, the gaps, the advantage
  after, the distance, the gauges) — e.g. K1 K2 K3 ORANGE K1 K2 K3 416, K1 K2 K3 SP2 at 3 layers 393, I K1 K2 K3 345, K1
  K2 K3 +L 白漣 331 with no bar, RIKUJOKORO -> O lands the Kikon from full health (the seal counts as red), a blocked K
  string is -26 in the Shikai; strategy-shikai.md: a first situation -> means table (a starting point, not a rule).
- You may verify a tactic of yours against a dummy with tools/combo-trial.py (its docstring; trials-*.lisp are examples).
Then the rules as they are: duel/lisp/rukia.lisp (her moves, 霜の層 and the bursts, the kido holds, the bands; RUKIA-OK
gates the bursts), docs/duel/DUEL_RUKIA_TYBW.md §4.4 (the Shikai's table), §8-§16 (the bind, the burst push, the chill,
the K1 / push changes, the combo scaling: SPs unscaled, ORANGE restarts it), duel/lisp/rukia-meter.lisp (the cold gauge and
the bands); duel/lisp/ai.lisp (AI-REFLEX's order, AI-DECIDE / AI-ATTACK and how :intents / :ranges / :moves press the
form's commands, STRING-REFLEX with :l-after-k / :l-after-j / :sp-ender, :sig-hold / :sp1-hold, AI-AWAKEN-P, the per-event
rolls). The baseline (BASELINE_DIR/score.json, "str_by_opp"): she wins 0 of 80 HARD matches against Kenpachi, Lille and
Hisagi, 29-58 of 80 against the others; diagnose with the combat log (tools/simgate/run-log.lisp, as aieval runs it)
before designing.

# The score (tools/aieval.py --char 2; frozen)
raw = 0.3 strength + 0.2 masher + 0.5 signature (the user: 「0.3/0.2/0.5 招牌至上」); score = raw x the NORMAL factor; 0
when pacing fails:
- strength: HARD Rukia vs the six other HARD CPUs, both seats: her win share ("str_by_opp" per opponent).
- masher: HARD Rukia (P2) vs the button-masher bot (P1, every character): her win share.
- signature: the share of her dealt damage (strength runs) in SIG_RUKIA's themes (the user: 「中近距離牽制與霜層的回收」
  「霜層爆開與收割」「鬼道」「封印毀魂」「K 連段與橙色爆氣」): poke (the openers J1 / K1 of every form, TSUKISHIRO's pillar, the
  bands' L hazards), burst (the six bursts, every SHIRAFUNE, the bands' SP1 wave), kido (BYAKURAI, SOKATSUI, RIKUJOKORO's
  bind), seal (the O that lands on a sealed victim), kstring (the K links K2 / K2s / K3 of every form, any hit under her
  ORANGE). Not signature: her J2 / J3 links, the Breaker, a plain O, counters. "sig_by" breaks it down.
- NORMAL factor: NORMAL Rukia vs each other NORMAL CPU, both seats: her win share in [0.30, 0.60] -> x1, falling linearly to
  0 at 0.15 outside. NORMAL plays a fair game; not a HARD copy.
- gate (score 0): pacing - NORMAL Rukia (P1) vs each other character: every match a K.O., median <= 220 s.

# Step 3. Propose and implement her tactics by condition, in character
The user (2026-10-25): explore which tactics suit which conditions (the opponent and his form, the distance, both sides'
gauges, his layers / red ...), and **where several options give an advantage, choose among them by probability weighted by
the advantage each brings** (not always the single best). Build the CPU as condition -> option tables with payoff weights
(read the opponent through his kit: (fighter-character / kit-form of the opponent) is fair, as is the perceived SNAP; never
his inputs), rolled with SIM-RND01 ONCE PER EVENT (a decision, a confirmed hit, an opponent action), never per step.
Implement it ONLY in duel/lisp/rukia-ai.lisp:
- allowed: the four :ai plists (*RU-AI-BASE* .. *RU-AI-ZERO*: keys ai.lisp reads, and her hook functions' names), every
  RUKIA-AI-* function and *AI-RU-...* knob, new functions / knobs there wired through the existing hook keys (:reflex
  :sp-ender :l-after-k :l-after-j :sig-hold :sp1-hold :assist-guard ...).
- forbidden: rukia.lisp (moves, rules, hooks, the cold gauge, the kits but their :ai symbol), rukia-meter.lisp, any other
  file (ai.lisp, tuning.lisp — its *AI-RU-L-AFTER-K* knobs stay; read them, don't edit), the other characters, anything an
  opponent's CPU reads. A shared change you believe is needed goes in proposal.md as a recommendation.
- keep working: AI-AWAKEN-P decides her awakening (the awaken A/B's debug modes 39000+10a+b force it on / off: time it only
  through what AI-AWAKEN-P allows, a kit gate, never around it); every debug mode (her 85000+ scenes, 2410+); the learning
  CPU reads on its own clock in AI-REFLEX before the kit's :reflex: a reflex that answers every free step starves AI-DECIDE
  (return NIL when there is nothing to do); the ASSIST borrows a HARD brain for a human (assist.lisp): hooks the ASSIST calls
  read the brain through (ai-brain e), never (brain e).
- difficulty layering: every new or changed chance scales with (brain-difficulty b) EASY <= NORMAL <= HARD.
- determinism: random numbers only via SIM-RND01 (or the brain's event rolls); a per-match roll lives in a CPU slot reset
  per match. No input reading, no debug knobs, no seed / tick special cases, nothing keyed to the evaluator.

# Step 4. Evaluate honestly
In your worktree:
1. {ECL} --norc --load tests/duel-rules-test.lisp must print ALL PASS. The section between ";;; >>> BEGIN
   RUKIA-CPU-TESTS" and ";;; <<< END RUKIA-CPU-TESTS" (end of tests/duel-rules/rukia.lisp) checks HER OWN CPU: edit THAT
   SECTION ONLY to match what your CPU now does (pin your own shipped values, don't delete a pin), and deliver the whole
   file (below); the coordinator splices only that section into the frozen test.
2. touch duel/lisp/rukia-ai.lisp, then the EVAL_COMMAND (the first run builds the native sim ~2 min; a 40-seed run ~12 min
   at -j 2). It prints one JSON line. Another cell runs at the same time: keep -j 2. Iterate with quicker passes (--seeds 10
   / 20, or tools/simgate.py --pairs 3,4,5,8,12,23,30 for her pairings); a 40-seed score moves ±0.01-0.02 with the seeds.
   Compare variants PAIRED (the same seeds and seats), in blocks of 240 HARD matches; stop once |difference| > 2 standard
   errors or after 960 matches (a tie: keep the simpler file). Report the blocks and the numbers.
3. The awaken A/B ONLY if you change what decides the awakening or NORMAL's Shikai play: python3 tools/simgate.py --pairs
   3,4,5 --seed0 S --seeds 60 --cmd 39020 -j 2 and --pairs 8,12,23,30 ... --cmd 39002 (she is P2 there) for S in 100, 300, 500;
   report the never-awaken side's wins per stream next to the baseline's; else say you didn't change it.
Never edit tools/aieval.py or anything it reads.

# Deliverables (inside YOUR worktree, at the fixed relative path NODE_DIR; the coordinator copies them)
- NODE_DIR/rukia-ai.lisp: your final duel/lisp/rukia-ai.lisp
- NODE_DIR/proposal.md: the condition -> tactic tables (by opponent, distance, gauges ...) and their payoff weights, the
  mechanisms, the evidence from the history and the catalogue, why it is not a repeat, the measurement (each part,
  str_by_opp, sig_by, normal and pacing vs the baseline), the risks, shared-code recommendations if any.
- NODE_DIR/score.json: the exact JSON line the EVAL_COMMAND printed for that final file.
- NODE_DIR/duel-rules-test.lisp (only if you edited its RUKIA-CPU-TESTS section): your whole tests/duel-rules/rukia.lisp.
Keep scratch files under a directory named after your cell (e.g. scratchpad/rukia-{cell}/), never in NODE_DIR. Do not
commit, push, merge or open PRs. Never run pkill / kill / killall / pkill -f / pgrep -f; bounded waits only.

# Report back
A short "STYLE" paragraph first (the user reads it): how this CPU plays, in a player's words: what it does against each
kind of opponent, at each distance, with which gauges; its favourite combos and cash-outs; how it uses the kido, the
seal, ORANGE and the awakening; what a human will notice, and what makes it different from the earlier cells. Then the
exact JSON line of the final evaluation (do not round or improve it), the path of your worktree, and on failure the
failure class (compile_other, correctness, runtime, resource) with the error text.
""")
