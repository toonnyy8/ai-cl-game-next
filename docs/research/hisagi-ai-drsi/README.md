# hisagi-ai-drsi — the dream-rsi workspace of Hisagi's CPU search

The plan is DUEL_HISAGI §25 (the user's request, 2026-10-18); the method and the last runs' lessons
`docs/guides/DREAM_RSI.zh-TW.md`; the model for these scripts: Lille II's run `docs/research/lille2-ai-drsi/`.

- **Task**: SOUL DUEL Hisagi CPU AI (`duel/lisp/hisagi.lisp` CPU parts), scored by `tools/aieval.py --char 7 --seeds 40`
  at the freeze commit (the last commit touching `tools/aieval.py`, `tests/duel-rules-test.lisp` or `baseline/score.json`;
  `FREEZE=<hash>` overrides). The opponents: the six other CPUs as they read there.
- **Host test**: frozen except the `HISAGI-CPU-TESTS` section (`splice-tests.py`).
- **Score**: (0.3 strength + 0.2 masher + 0.5 signature) × the NORMAL band factor ([0.30, 0.60], 0 at 0.15 outside); 0 when
  pacing fails. Signature: `SIG_HISAGI`'s three themes (chain / ranged / bind). Baseline 0.0 (raw 0.3803, NORMAL 0.115; re-frozen on DUEL_HISAGI §25.3's ranged reach, round 1 reopened).
- **dream-rsi**: W = 2, round 1 = 4 × 2 cells, λ 0.25, `plan --beta 0.6`; branch b0-b3's primary styles in `brief.py`'s
  STYLES (the user: 「請研究多種招牌風格，並使用機率將這些風格戰法互相結合」).

The loop (as Lille II's README): `drsi.py plan`, `step.sh next` (briefs), dispatch each brief to an agent in its own
worktree at the freeze commit, `step.sh done <cell> <round> <worktree>` (copy, rescore at the freeze, record, next),
`step.sh fail ...`; the rescore worktree is `.claude/worktrees/rescore-hisagi` (one 40-seed rescore ≈ 1 h at -j 2).
