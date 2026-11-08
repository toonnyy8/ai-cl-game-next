# counter — the dream-rsi workspaces of the counter-strategy search (DUEL_AI_STRATEGY §8.7)

Four workspaces (`workspaces.json`), HARD, each against the opponent's shipped CPU: `ih-ichigo` (Ichigo vs Hisagi), `ki-ken`
(Kenpachi vs Ichigo), `ki-ichigo` (Ichigo vs Kenpachi), `kh-hisagi` (Hisagi vs Kenpachi). Grid 3 x 3 (3 branches x 3 attempts), W = 4,
two rounds (the user, 2026-11-08).

- **A cell** writes `NODE_DIR/cand.lisp`: a strategy plist plus `:own` (the situations it claims). Data only, no worktree, the shared native
  build. It compares its variants on the dev seeds (800-849).
- **The score**: `tools/strategy-switch.py ... --seed0 600 --seeds 100` (the composite's win share, both seats, 200 matches), re-measured
  by the coordinator (`score.json`). The baseline (`<ws>/baseline/`) is the incumbent's share on the same seeds.
- **Admission** (after the rounds): the gain confirmed on the held-out seeds 700-799, a real share of the judgements, a fingerprint unlike
  the library's.
- **Loop**: `step.sh <ws> next` (briefs from `brief.py`), dispatch each brief to a subagent, `step.sh <ws> done <cell> <round>` (rescore,
  record, next), `step.sh <ws> fail <cell> <round> <class> <error>`.
