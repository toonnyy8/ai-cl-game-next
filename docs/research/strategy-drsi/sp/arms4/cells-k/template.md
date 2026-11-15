# Dream-RSI cell {CELL} of workspace cells-k/{WS} (SOUL DUEL, PLAN4 batch B3, round {ROUND})

You are one attempt ("cell") of a Dream-RSI search over CPU strategy arms for SOUL DUEL, a Common Lisp 3D arena fighter. Repo root (a git
worktree): `{R}`. Short names below: `SP` = `{R}/docs/research/strategy-drsi/sp`, `A4` = `SP/arms4`, `C` = `A4/cells-k`.

## The task
{TASK}

**Your branch's mechanism (stay inside it): {DIRECTION}.**

Why (read first): `SP/PLAN4.md` §3 (arms = one job each; "the scorer is the played policy") and §4 (T0); {SHEET}; `SP/KNOBS.md` §1, §6
(§6.1-§6.2 Kenpachi's 29 style keys, §6.3 + §6.7 Ichigo's); the code of the keys you touch ({CODE}). `C/score.py` (how you are scored).

## How a candidate is scored (`C/score.py`, the only scorer you run)
Your file is `{NODE}/arm.lisp`: ONE arm plist, `:id :{SLOT}`, `:apply (:{me})`, `:fn {FN}` kept, everything inline (no `:style` / `:data`
/ unit ids). Never name an exchange key (`:xch-*`, `:clash-*`, `:awaken-break-p`, `:awaken-kikon-p`): they come from the pairing's `:with`
unit and score.py refuses them. A plist key listed twice: the FIRST wins, so edit values in place. A `:rules` entry REPLACES `:base` for its
key where it fires (KNOBS §1); arm `:rules` see only `strat-feats` cues (KNOBS §1 "Cues").
score.py writes the side's T0 table with your arm in its slot ({JOBNOTE}) and runs eval.py (HARD, both seats, K.O. wins only: a time-out
scores 0) against {VSDESC}. Score = (K.O. wins + 1) / (matches + 2) per group, averaged; {SCOREPARTS}. Higher is better.
The arm is NOT scored whole: a job arm is expected to lose when it plays a whole match (PLAN4 P2). It is scored where its job rules put it.

Evaluate with (FOREGROUND, Bash timeout 600000 ms; about 30-90 s, longer when the machine is busy):
`{EVAL}`
**Budget: at most {NSCORE} score.py runs in this cell ({EVALCOST}).** It uses seeds 301-400 only; never pass another `--seed0`.

## The job must survive (the one-job proof at admission)
After the search the coordinator runs the pre-registered proof on seeds 1-100 (you never touch them): played whole against the opponent,
{DESCBAR}; distinct from the sibling arms; >= 50 % of matches ending by K.O. A candidate that scores well by drifting back to arm 0's play
fails admission. So run **at least 1 and at most 2 descriptor checks** (at least one on your FINAL arm.lisp; earlier cells skipped it and
left their job unverified) (not eval.py; seeds 301-320 only, 80 matches an arm), e.g.:
`{DESC}
(`--arms` = a scratch file you write with arm 0's plist first, then yours; arm 0 = the first plist of `A4/{ARMSFILE}`. The table it prints
shows arm 0's values and your differences. Write its output only under `{NODE}/scratch/`.)

## Dream-RSI exploration rules
You must read every historical proposal before proposing or implementing a new solution.

Paths: `{NODE}` is your own attempt directory: exclude it when scanning the sibling `b{BR}_a*/` directories of YOUR branch in `{NODES}`.
Do NOT read other branches' directories. PARENT_DIR: {PARENT}. HISTORY_DIRS: {HIST}. BASELINE_DIR: `{BASE}` (score {BSC}: the
assembled draft). Target file: `arm.lisp`.

1. Read the complete history first (proposal.md and the measured score of each sibling attempt and the baseline). Trust measured results
   over claims.
2. Learn from successes and failures (a flawed idea, or a sound idea let down by parameters or an inert key?). KNOBS §0 and §3 list keys
   that are inert for these styles: do not spend runs on them.
3. Don't converge into a local optimum inside your mechanism: try a structurally different setting of your keys before fine steps.
4. Implement in `{NODE}/arm.lisp`. Do not claim it beats anything until evaluated. The FINAL `arm.lisp` must be the one you report a
   score for (the coordinator re-runs score.py on it; an identical file is a cache hit).

## Files
Write only `{NODE}/proposal.md` (the keys changed and why, the evidence, each run's score and per-group K.O. counts vs the baseline's, the
descriptor check's numbers), `{NODE}/arm.lisp`{EXTRAFILES}, and anything under `{NODE}/scratch/`. Everything else is read-only.

## Rules
- The machine runs several cells at once: run score.py and proof.py in the FOREGROUND with the Bash tool's timeout set to 600000 ms. Never
  background them, never poll, never sleep-loop.
- Never execute `pkill`, `kill`, `killall`, `pgrep -f`, `pkill -f`, or terminate any process. Bounded waits only.
- No git commands. Do not edit any repo file outside `{NODE}`. Do not run eval.py directly (from this worktree it refuses on the build hash;
  score.py runs it from the main checkout where the round's pin `SP_BUILD=b835ac41b83b` holds).
- If score.py exits non-zero: read the error and fix the arm. If you cannot get a valid score, report the failure class (`compile_other` =
  a format / load error in your arm, `runtime` = a sim crash, `compile_env` = the SP_BUILD guard refused: then stop at once) and the exact
  error text.

## Report back (short)
The score of your FINAL arm.lisp exactly as score.py printed it (the `score` and each part's per-group K.O. wins / losses / time-outs), the
descriptor check's result, or the failure class and exact error text. Do not round or estimate.
