# Dream-RSI cell b0_a0 of workspace cells-k/k-wave (SOUL DUEL, PLAN4 batch B3, round 1)

You are one attempt ("cell") of a Dream-RSI search over CPU strategy arms for SOUL DUEL, a Common Lisp 3D arena fighter. Repo root (a git
worktree): `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f`. Short names below: `SP` = `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp`, `A4` = `SP/arms4`, `C` = `A4/cells-k`.

## The task
Tune Kenpachi's targeted arm against Ichigo, **`wave`**: the answer to her pointer-2 Getsuga route (`:kk-wave-p`, PLAN4 §3) and the keys that shape what he does around it. Start from BASELINE_DIR's arm.lisp (arm 0 with `:kk-wave-p 0.9`; arm 0 has 0) or your parent's. The answer's plan (cpu-ki-ken.lisp `kk-wave-plan`, `kk-wave-step`: :close / :cut / :late / :step by `*kk-wave-mix*`, a list, not a key) uses his Hoho, his Step and his NS reach: `:kk-hin-fs`, `:kk-step-*`, `:kk-reach-*`, `:kk-ns-safe-p`, `:range` etc. are in play. KNOBS §6.1-§6.2.

**Your branch's mechanism (stay inside it): (none: the whole arm).**

Why (read first): `SP/PLAN4.md` §3 (arms = one job each; "the scorer is the played policy") and §4 (T0); `A4/kenpachi.md` (the arms, their proof results, and "Re-registered for the cells"); `SP/KNOBS.md` §1, §6
(§6.1-§6.2 Kenpachi's 29 style keys, §6.3 + §6.7 Ichigo's); the code of the keys you touch (`duel/lisp/cpu-ki-ken.lisp` (`ken-ki-style`, the `*kk-*` specials), `duel/lisp/cpu-kh-ken.lisp` (`ken-kh-standoff-style`, `*kso-*`)). `C/score.py` (how you are scored).

## How a candidate is scored (`C/score.py`, the only scorer you run)
Your file is `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/arm.lisp`: ONE arm plist, `:id :a4-k-wave`, `:apply (:kenpachi)`, `:fn ken-kh-standoff-style` kept, everything inline (no `:style` / `:data`
/ unit ids). Never name an exchange key (`:xch-*`, `:clash-*`, `:awaken-break-p`, `:awaken-kikon-p`): they come from the pairing's `:with`
unit and score.py refuses them. A plist key listed twice: the FIRST wins, so edit values in place. A `:rules` entry REPLACES `:base` for its
key where it fires (KNOBS §1); arm `:rules` see only `strat-feats` cues (KNOBS §1 "Cues").
score.py writes the side's T0 table with your arm in its slot (wave's job rules: G10 her SP pointer 2 (all three distances; her pointer 2 is the Getsuga's) in the KI table. The other arms stay as assembled) and runs eval.py (HARD, both seats, K.O. wins only: a time-out
scores 0) against Ichigo's groups (her `none`, her T0 `A4/t0/t0-ki-ichigo.lisp`, whose arm `keep` runs the pointer-2 Getsuga at range; pop `C/pop-ki-I.json`: anchor = none, mix = none and T0 by seed, rest = T0). Score = (K.O. wins + 1) / (matches + 2) per group, averaged; one part (KI). Baseline (the assembled draft) 0.3234: vs her none 109-77-14, mix 63-130-7, vs her T0 21-179-0 of 200 (K.O. wins-losses-time-outs). Higher is better.
The arm is NOT scored whole: a job arm is expected to lose when it plays a whole match (PLAN4 P2). It is scored where its job rules put it.

Evaluate with (FOREGROUND, Bash timeout 600000 ms; about 30-90 s, longer when the machine is busy):
`cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k && python3 score.py k-wave /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0 -j 4`
**Budget: at most 8 score.py runs in this cell (each run = 1 eval.py call).** It uses seeds 301-400 only; never pass another `--seed0`.

## The job must survive (the one-job proof at admission)
After the search the coordinator runs the pre-registered proof on seeds 1-100 (you never touch them): played whole against the opponent,
`evade` (Steps + Hohos a match) >= arm 0's x 1.2 against Ichigo's `a4-i-keep` played whole (her arm that runs the Getsuga route); K.O. >= 50 % and distinctness against her `none` (pre-registered in kenpachi.md); distinct from the sibling arms; >= 50 % of matches ending by K.O. A candidate that scores well by drifting back to arm 0's play
fails admission. So you may run **at most 2 descriptor checks** (not eval.py; seeds 301-320 only, 80 matches an arm), e.g.:
`cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4 && python3 proof.py desc --me kenpachi --vs ichigo --arms /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/scratch/desc-arms.lisp --with x-units/d-x-ki-k.lisp --opp cells-k/opp-ki-ichigo-keep.lisp --seed0 300 --seeds 20 --out /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/scratch/desc-vs-keep.json -j 4`
(`--arms` = a scratch file you write with arm 0's plist first, then yours; arm 0 = the first plist of `A4/kenpachi.lisp`. The table it prints
shows arm 0's values and your differences. Write its output only under `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/scratch/`.)

## Dream-RSI exploration rules
You must read every historical proposal before proposing or implementing a new solution.

Paths: `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0` is your own attempt directory: exclude it when scanning the sibling `b0_a*/` directories of YOUR branch in `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes`.
Do NOT read other branches' directories. PARENT_DIR: none (a new direction). HISTORY_DIRS: none. BASELINE_DIR: `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/baseline` (score 0.3234: the
assembled draft). Target file: `arm.lisp`.

1. Read the complete history first (proposal.md and the measured score of each sibling attempt and the baseline). Trust measured results
   over claims.
2. Learn from successes and failures (a flawed idea, or a sound idea let down by parameters or an inert key?). KNOBS §0 and §3 list keys
   that are inert for these styles: do not spend runs on them.
3. Don't converge into a local optimum inside your mechanism: try a structurally different setting of your keys before fine steps.
4. Implement in `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/arm.lisp`. Do not claim it beats anything until evaluated. The FINAL `arm.lisp` must be the one you report a
   score for (the coordinator re-runs score.py on it; an identical file is a cache hit).

## Files
Write only `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/proposal.md` (the keys changed and why, the evidence, each run's score and per-group K.O. counts vs the baseline's, the
descriptor check's numbers), `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/arm.lisp`, and anything under `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0/scratch/`. Everything else is read-only.

## Rules
- The machine runs several cells at once: run score.py and proof.py in the FOREGROUND with the Bash tool's timeout set to 600000 ms. Never
  background them, never poll, never sleep-loop.
- Never execute `pkill`, `kill`, `killall`, `pgrep -f`, `pkill -f`, or terminate any process. Bounded waits only.
- No git commands. Do not edit any repo file outside `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/k-wave/rounds/round01/nodes/b0_a0`. Do not run eval.py directly (from this worktree it refuses on the build hash;
  score.py runs it from the main checkout where the round's pin `SP_BUILD=b835ac41b83b` holds).
- If score.py exits non-zero: read the error and fix the arm. If you cannot get a valid score, report the failure class (`compile_other` =
  a format / load error in your arm, `runtime` = a sim crash, `compile_env` = the SP_BUILD guard refused: then stop at once) and the exact
  error text.

## Report back (short)
The score of your FINAL arm.lisp exactly as score.py printed it (the `score` and each part's per-group K.O. wins / losses / time-outs), the
descriptor check's result, or the failure class and exact error text. Do not round or estimate.
