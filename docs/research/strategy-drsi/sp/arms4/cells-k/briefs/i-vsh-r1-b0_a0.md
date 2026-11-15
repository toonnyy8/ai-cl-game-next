# Dream-RSI cell b0_a0 of workspace cells-k/i-vsh (SOUL DUEL, PLAN4 batch B3, round 1)

You are one attempt ("cell") of a Dream-RSI search over CPU strategy arms for SOUL DUEL, a Common Lisp 3D arena fighter. Repo root (a git
worktree): `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f`. Short names below: `SP` = `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp`, `A4` = `SP/arms4`, `C` = `A4/cells-k`.

## The task
Find and build **Ichigo's targeted arm against Hisagi** (PLAN4 §3: 1-2 targeted arms a pairing, "vs H: found by the search"): a job her four general arms do not cover, in a situation Hisagi creates, that wins it. Her general arms (A4/ichigo.lisp): `all` (arm 0, the patient hover-and-punish), `brawl` (close pressure; job G2 he is free), `keep` (the pointer-2 Getsuga at range, distance held; job G8 she leads), `kessa2` (awakened KESSA pressure; job G0 awakened, G1 form 1). You choose BOTH the job rules (where your arm plays) and the arm's keys (KNOBS §6.3, §6.7; arm `:rules` on strat-feats cues allowed). Read what Hisagi does (A4/hisagi.md: his five arms and their jobs; his T0 `A4/t0/t0-ih-hisagi.lisp`; his ranged Bankai mode, the kite, the press while her Reishi is low) before choosing.

**Your branch's mechanism (stay inside it): (none: the whole arm).**

Why (read first): `SP/PLAN4.md` §3 (arms = one job each; "the scorer is the played policy") and §4 (T0); `A4/ichigo.md` (her arms and their proofs), `A4/hisagi.md` (his arms), `SP/diag/all-tiers-table.md` (IH is a hard cell); `SP/KNOBS.md` §1, §6
(§6.1-§6.2 Kenpachi's 29 style keys, §6.3 + §6.7 Ichigo's); the code of the keys you touch (`duel/lisp/cpu-ki-ichigo.lisp`, `duel/lisp/cpu-ki-ichigo-r2b2a1.lisp` (her style); Hisagi: `duel/lisp/cpu-hk-hisagi.lisp`, `duel/lisp/cpu-hisagi-range.lisp`, `duel/lisp/cpu-ih-hisagi-ihr1b2a0.lisp`). `C/score.py` (how you are scored).

## How a candidate is scored (`C/score.py`, the only scorer you run)
Your file is `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/arm.lisp`: ONE arm plist, `:id :a4-i-vsh`, `:apply (:ichigo)`, `:fn ichigo-ki-r2b2a1-style (keep it: one style function, so a switch keeps her state)` kept, everything inline (no `:style` / `:data`
/ unit ids). Never name an exchange key (`:xch-*`, `:clash-*`, `:awaken-break-p`, `:awaken-kikon-p`): they come from the pairing's `:with`
unit and score.py refuses them. A plist key listed twice: the FIRST wins, so edit values in place. A `:rules` entry REPLACES `:base` for its
key where it fires (KNOBS §1); arm `:rules` see only `strat-feats` cues (KNOBS §1 "Cues").
score.py writes the side's T0 table with your arm in its slot (your arm joins her IH T0 (`A4/t0/ih-ichigo.json`'s four arms, `:with d-x-ih-i`) as a fifth arm with the job rules of `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/job.json`: +0.06 in the job rules, -0.06 / n in the rest of the n groups the job names, n <= 2 (score.py's table writer refuses 3: 0.02 = the margin). A job entry `[G, ["(:cue :set)", ...]]` selects the rules of group G whose antecedent contains every listed string; several entries OR. The :rb-sp2 rules:
- G0 (36 rules): `(:lead :behind|:even|:ahead) (:ored :no|:yes) (:awst :no|:yes|:k2) (:oawk :no|:yes)` (lead = my Konpaku minus his; ored = he is red; awst = my awakening not ready / ready / awakened; oawk = he is awakened)
- G1: `((:form :no) (:dm :m-close))`; `((:form :no) (:dm :m-mid))`; `((:form :no) (:dm :m-far))`; `((:form :yes) (:dm :m-close))`; `((:form :yes) (:dm :m-mid))`; `((:form :yes) (:dm :m-far))`; `((:form :k2) (:dm :m-close))`; `((:form :k2) (:dm :m-mid))`; `((:form :k2) (:dm :m-far))`
- G2: `((:ost :free) (:dm :m-close))`; `((:ost :free) (:dm :m-mid))`; `((:ost :free) (:dm :m-far))`; `((:ost :atk) (:dm :m-close))`; `((:ost :atk) (:dm :m-mid))`; `((:ost :atk) (:dm :m-far))`; `((:ost :evade) (:dm :m-close))`; `((:ost :evade) (:dm :m-mid))`; `((:ost :evade) (:dm :m-far))`; `((:ost :down) (:dm :m-close))`; `((:ost :down) (:dm :m-mid))`; `((:ost :down) (:dm :m-far))`
- G3: `((:mcell :no) (:ocell :no))`; `((:mcell :no) (:ocell :yes))`; `((:mcell :no) (:ocell :p2up))`; `((:mcell :yes) (:ocell :no))`; `((:mcell :yes) (:ocell :yes))`; `((:mcell :yes) (:ocell :p2up))`; `((:mcell :p2up) (:ocell :no))`; `((:mcell :p2up) (:ocell :yes))`; `((:mcell :p2up) (:ocell :p2up))`
- G4: `((:mburst :no) (:oburst :no))`; `((:mburst :no) (:oburst :yes))`; `((:mburst :yes) (:oburst :no))`; `((:mburst :yes) (:oburst :yes))`
- G5: `((:xch :no))`; `((:xch :yes))`
- G6: `((:wall :w-near) (:owall :w-near))`; `((:wall :w-near) (:owall :w-open))`; `((:wall :w-open) (:owall :w-near))`; `((:wall :w-open) (:owall :w-open))`
- G7: `((:mr :r-low) (:or :r-low))`; `((:mr :r-low) (:or :r-high))`; `((:mr :r-high) (:or :r-low))`; `((:mr :r-high) (:or :r-high))`
- G8: `((:time :t-early) (:lead :behind))`; `((:time :t-early) (:lead :even))`; `((:time :t-early) (:lead :ahead))`; `((:time :t-mid) (:lead :behind))`; `((:time :t-mid) (:lead :even))`; `((:time :t-mid) (:lead :ahead))`; `((:time :t-late) (:lead :behind))`; `((:time :t-late) (:lead :even))`; `((:time :t-late) (:lead :ahead))`
- G9: `((:swopen :no) (:mptr :yes))`; `((:swopen :no) (:mptr :k2))`; `((:swopen :no) (:mptr :k3))`; `((:swopen :yes) (:mptr :yes))`; `((:swopen :yes) (:mptr :k2))`; `((:swopen :yes) (:mptr :k3))`
- G10: `((:optr :yes) (:dm :m-close))`; `((:optr :yes) (:dm :m-mid))`; `((:optr :yes) (:dm :m-far))`; `((:optr :k2) (:dm :m-close))`; `((:optr :k2) (:dm :m-mid))`; `((:optr :k2) (:dm :m-far))`; `((:optr :k3) (:dm :m-close))`; `((:optr :k3) (:dm :m-mid))`; `((:optr :k3) (:dm :m-far))`) and runs eval.py (HARD, both seats, K.O. wins only: a time-out
scores 0) against Hisagi's groups (his `none`, his T0 `A4/t0/t0-ih-hisagi.lisp`; pop `C/pop-ih-H.json`: anchor = none, mix = none and T0 by seed, rest = T0). Score = (K.O. wins + 1) / (matches + 2) per group, averaged; one part. Baseline (her four-arm IH T0 without your arm) 0.8267: vs his none 159-32-9, mix 166-30-4, vs his T0 173-27-0 of 200 (K.O. wins-losses-time-outs). Higher is better.
The arm is NOT scored whole: a job arm is expected to lose when it plays a whole match (PLAN4 P2). It is scored where its job rules put it.

Evaluate with (FOREGROUND, Bash timeout 600000 ms; about 30-90 s, longer when the machine is busy):
`cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k && python3 score.py i-vsh /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0 -j 4`
**Budget: at most 8 score.py runs in this cell (each run = 1 eval.py call).** It uses seeds 301-400 only; never pass another `--seed0`.

## The job must survive (the one-job proof at admission)
After the search the coordinator runs the pre-registered proof on seeds 1-100 (you never touch them): played whole against the opponent,
the descriptor and bar YOU pre-register before your first score.py run (in `job.json` and in proposal.md's first section): one of proof.py's TOL descriptors (`mean_d close mid far awk p2 p3 sp burst kikon spend wake_kd evade acts clash nstart nstart_r k_sp k_d`), against arm 0 `a4-i-all`, an op (`+` / `-` / `x` / `x<`) and an amount, measured against Hisagi's `none` (or, if your job only shows against one of his arms, that arm from `A4/hisagi/` played whole, named in job.json's "opp"); plus distinct from all four general arms (proof.py's `~` mark). A later attempt of your branch may keep or change the job; it re-registers before its own first run; distinct from the sibling arms; >= 50 % of matches ending by K.O. A candidate that scores well by drifting back to arm 0's play
fails admission. So you may run **at most 2 descriptor checks** (not eval.py; seeds 301-320 only, 80 matches an arm), e.g.:
`cd /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4 && python3 proof.py desc --me ichigo --vs hisagi --arms /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/scratch/desc-arms.lisp --with x-units/d-x-ih-i.lisp --seed0 300 --seeds 20 --out /media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/scratch/desc-vs-hisagi.json -j 4` (put the four general arms of `A4/ichigo.lisp` first, `a4-i-all` first, then yours: proof.py marks with `~` an arm not distinct from another)
(`--arms` = a scratch file you write with arm 0's plist first, then yours; arm 0 = the first plist of `A4/ichigo.lisp`. The table it prints
shows arm 0's values and your differences. Write its output only under `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/scratch/`.)

## Dream-RSI exploration rules
You must read every historical proposal before proposing or implementing a new solution.

Paths: `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0` is your own attempt directory: exclude it when scanning the sibling `b0_a*/` directories of YOUR branch in `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes`.
Do NOT read other branches' directories. PARENT_DIR: none (a new direction). HISTORY_DIRS: none. BASELINE_DIR: `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/baseline` (score 0.8267: the
assembled draft). Target file: `arm.lisp`.

1. Read the complete history first (proposal.md and the measured score of each sibling attempt and the baseline). Trust measured results
   over claims.
2. Learn from successes and failures (a flawed idea, or a sound idea let down by parameters or an inert key?). KNOBS §0 and §3 list keys
   that are inert for these styles: do not spend runs on them.
3. Don't converge into a local optimum inside your mechanism: try a structurally different setting of your keys before fine steps.
4. Implement in `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/arm.lisp`. Do not claim it beats anything until evaluated. The FINAL `arm.lisp` must be the one you report a
   score for (the coordinator re-runs score.py on it; an identical file is a cache hit).

## Files
Write only `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/proposal.md` (the keys changed and why, the evidence, each run's score and per-group K.O. counts vs the baseline's, the
descriptor check's numbers), `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/arm.lisp`, `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/job.json` (`{"job": [[G, ["(:cue :set)", ...]], ...], "descriptor": "...", "op": "+", "amount": 0.3, "opp": "none"}`, written BEFORE your first score.py run), and anything under `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0/scratch/`. Everything else is read-only.

## Rules
- The machine runs several cells at once: run score.py and proof.py in the FOREGROUND with the Bash tool's timeout set to 600000 ms. Never
  background them, never poll, never sleep-loop.
- Never execute `pkill`, `kill`, `killall`, `pgrep -f`, `pkill -f`, or terminate any process. Bounded waits only.
- No git commands. Do not edit any repo file outside `/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-ab58407965fd9cc0f/docs/research/strategy-drsi/sp/arms4/cells-k/i-vsh/rounds/round01/nodes/b0_a0`. Do not run eval.py directly (from this worktree it refuses on the build hash;
  score.py runs it from the main checkout where the round's pin `SP_BUILD=b835ac41b83b` holds).
- If score.py exits non-zero: read the error and fix the arm. If you cannot get a valid score, report the failure class (`compile_other` =
  a format / load error in your arm, `runtime` = a sim crash, `compile_env` = the SP_BUILD guard refused: then stop at once) and the exact
  error text.

## Report back (short)
The score of your FINAL arm.lisp exactly as score.py printed it (the `score` and each part's per-group K.O. wins / losses / time-outs), the
descriptor check's result, or the failure class and exact error text. Do not round or estimate.
