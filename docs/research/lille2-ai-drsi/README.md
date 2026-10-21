# lille2-ai-drsi — the dream-rsi workspace of Lille II's CPU search

The plan is DUEL_LILLE_V3 §22 (the user's request, 2026-10-12); the method and the last runs' lessons
`docs/guides/DREAM_RSI.zh-TW.md`; the old Lille's run (the model for these scripts) `docs/research/lille-ai-drsi/`.

- **Task**: SOUL DUEL Lille II CPU AI (`duel/lisp/barro.lisp` CPU parts), scored by `tools/aieval.py --char 6 --seeds 40`
  at the freeze commit (the last commit touching `tools/aieval.py`, `tests/duel-rules-test.lisp`, `tests/duel-rules/barro.lisp` or `baseline/score.json`;
  `FREEZE=<hash>` overrides).
- **Host test**: frozen except the `BARRO-CPU-TESTS` section (`splice-tests.py`).
- **Score**: (0.4 strength + 0.2 masher + 0.4 signature) × the NORMAL factor; 0 when pacing fails.
- **dream-rsi**: W = 2, round 1 = 4 × 2 cells, λ 0.25, `plan --beta 0.6`.

The loop (as the old Lille's README): `drsi.py plan`, `step.sh next` (briefs), dispatch each brief to an agent in its own
worktree at the freeze commit, `step.sh done <cell> <round> <worktree>` (copy, rescore at the freeze, record, next),
`step.sh fail ...`; the rescore worktree is `.claude/worktrees/rescore-lille2`.
