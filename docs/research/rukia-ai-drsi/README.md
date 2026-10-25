# rukia-ai-drsi — the dream-rsi workspace of Rukia's CPU search

The plan is DUEL_RUKIA_TYBW §17 (the user's requests, 2026-10-25); the method and the earlier runs' lessons
`docs/guides/DREAM_RSI.zh-TW.md`; the scripts adapted from Hisagi's (`docs/research/hisagi-ai-drsi/`).

- **Task**: SOUL DUEL Rukia CPU AI (`duel/lisp/rukia-ai.lisp`: her four forms' :ai plists, RUKIA-AI-* functions, *AI-RU-*
  knobs; split out of rukia.lisp for this search), scored by `tools/aieval.py --char 2 --seeds 40` at the freeze commit (the
  last commit touching `tools/aieval.py`, `tests/duel-rules-test.lisp`, `tests/duel-rules/rukia.lisp` or
  `baseline/score.json`; `FREEZE=<hash>` overrides). The opponents: the six other CPUs as they read there.
- **The planning base** (the user: 「請先以每個角色的幀數表、攻防距離等等資訊為基礎來規劃策略並逐步改進」): `docs/research/rukia-cpu/`
  (data sheets of every form, the matchup sheet, the sim-verified catalogues of the Shikai and the bands, a first strategy).
- **Host test**: frozen except the `RUKIA-CPU-TESTS` section of `tests/duel-rules/rukia.lisp` (`splice-tests.py`).
- **Score**: (0.3 strength + 0.2 masher + 0.5 signature) × the NORMAL band factor ([0.30, 0.60], 0 at 0.15 outside); 0
  when pacing fails. Signature: `SIG_RUKIA`'s five themes (poke / burst / kido / seal / kstring; the sim's "ru-sig" tags).
  Baseline 0.5898 (strength 0.273: 0 of 80 vs Kenpachi, Lille, Hisagi; masher 1.0; signature 0.616; NORMAL 0.423).
- **dream-rsi**: W = 2, round 1 = 4 × 2 cells, λ 0.25; the branches' primary condition axes in `brief.py`'s STYLES (the
  opponent, her resources, the distance, the awakening and the bands); options chosen by probability weighted by payoff.

The loop: `drsi.py plan`, `step.sh next` (briefs), dispatch each brief to an agent in its own worktree at the freeze commit,
`step.sh done <cell> <round> <worktree>` (copy, rescore at the freeze, record, next), `step.sh fail ...`; the rescore
worktree is `.claude/worktrees/rescore-rukia`. Times (4 cores): a 40-seed eval ~10 min at -j 4, ~15–20 at -j 2.
