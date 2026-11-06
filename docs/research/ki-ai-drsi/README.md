# ki-ai-drsi — the dream-rsi workspaces of the KI matchup style CPUs

The plan: docs/duel/DUEL_MATCHUP_AI.md §1, §4, §6–§8 (the user, 2026-11-06). Two workspaces, one a side: `ken/` (Kenpachi's
`duel/lisp/cpu-ki-ken.lisp` against Ichigo) and `ichigo/` (Ichigo's `cpu-ki-ichigo.lisp` against Kenpachi).

- **Evaluator**: `tools/matchup-eval.py --side <side> --seeds 40 -j 4` at the commit in `FREEZE` (with `tools/simgate/situ.lisp`,
  `run-situ.lisp`). Cells compare their variants at 20 seeds a seat; the record and the pick use 40 (the user's rule).
- **Opponent**: each side's `champion/` holds its best file so far (round 1: v0). A cell plays, and is rescored, against the OTHER side's
  champion. After each round the best rescored cell of each side becomes its champion (「每輪換上對方最佳版」), both champions are
  re-measured against each other, and that is the next round's baseline (`config.json` `baseline_score` updated).
- **Grid**: 3 rounds × 8 cells a side (4 branches × 2 attempts), W = 4; branch b0–b3 leans on one of the side's four approved themes
  (`brief.py`, a structural hint).
- **Loop**: `step.sh <side> next` (briefs), dispatch each brief to an agent in its own worktree, `step.sh <side> done <cell> <round> <wt>`
  (copy, rescore with the other side's champion, record, next), `step.sh <side> fail …`. Rescore worktrees `.claude/worktrees/rescore-ki-<side>`.
