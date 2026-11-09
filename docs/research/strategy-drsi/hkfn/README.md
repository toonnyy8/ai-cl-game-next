# hkfn — the dream-rsi workspace of Hisagi's style code against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7)

The user, 2026-11-10: 「用 dream-rsi 幫檜佐木寫新程式」 (khfn's twin for Hisagi; the search rule 「高內聚，低耦合」). A dream-rsi run (the skill's
`scripts/drsi.py`) writes `duel/lisp/cpu-hk-hisagi.lisp` (`hisagi-hk-style`, a strategy's `:fn`), scored against Kenpachi's whole pool. The
method, the evaluator and the keep rule are in DUEL_AI_STRATEGY §8.19 "Round 5, step 7". Hisagi's shared CPU stays unchanged.

| File | What |
|---|---|
| `eval.py` | the frozen evaluator: Hisagi playing `cand-hkfn.lisp` (`(:id :hkfn :fn hisagi-hk-style :ken-ranged t)`) whole against Kenpachi's pool, both seats: his live `:qks5-hisagi` (the bait layer on), his four earlier KH tables, his 13 whole arms (step 4's 11 + the bait + the stand-off breaker), his KI style stand-in; score = the mean of the four group shares; blocks seed0 200 search, 300 dev, 400 held-out; `inc_live` = the live HK lookup's own share (a tripwire) |
| `refs.sh`, `refs.jsonl` | the references before round 1: his four existing styles (merged = the baseline, Kenpachi's KI code, Ichigo's, the ranged style), his live HK table and his best step-4 whole arms, on the three blocks |
| `baseline/` | the starting `cpu-hk-hisagi.lisp` (his merged style unchanged), its search score, `proposal.md` (the references and the keep rule) |
| `brief.py`, `step.sh`, `rescore.sh`, `heldout.sh`, `dream.sh` | as khfn's: a cell's brief; the loop (`next`, `done <cell> <round> <worktree>`, `fail`); the rescore on the search block with the host tests and the tripwire; the keep rule's held-out measure; the dream step |
| `config.json`, `policy/`, `rounds/`, `trace_pool/`, `proposal_results/` | drsi.py's workspace (round 1 = the configured 4 x 3 grid, W = 4) |

Cells: Sonnet subagents, each in its own git worktree (the scaffold copied in: `eval.py`, `cand-hkfn.lisp`, the MANIFEST line, the parent's or
the baseline's `cpu-hk-hisagi.lisp`), its own native build, dev runs at seed0 300.

Round 1 kept nothing: b3_a2 (Reishi parity at the bell) cleared the score bar on the held-out block but missed the live-KH and stand-in
floors; every other cell missed the score bar (DUEL_AI_STRATEGY §8.19 "Round 5, step 7"). The scaffold (`duel/lisp/cpu-hk-hisagi.lisp`, its
MANIFEST line after `lisp/cpu-kh-ken.lisp`) was removed from the game again; a round 2 puts `baseline/cpu-hk-hisagi.lisp` back first, since
`rescore.sh` and `heldout.sh` swap the cell's file into the coordinator's checkout.
