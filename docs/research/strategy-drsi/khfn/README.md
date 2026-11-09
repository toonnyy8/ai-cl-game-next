# khfn — the dream-rsi workspace of Kenpachi's style code against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5)

The user, 2026-11-09: 「用 dream-rsi 寫新風格程式」 (and the search rule 「請再找策略的時候用全局性的觀點同時思考兩邊的策略，並將具有「高內聚，低耦合」特性的
策略保留下來」). A dream-rsi run (the skill's `scripts/drsi.py`) writes `duel/lisp/cpu-kh-ken.lisp` (`ken-kh-style`, a strategy's `:fn`),
scored against Hisagi's pool. The method, the evaluator and the keep rule are in DUEL_AI_STRATEGY §8.19 "Round 5, step 5".

| File | What |
|---|---|
| `eval.py` | the frozen evaluator: Kenpachi playing `cand-khfn.lisp` (`(:id :khfn :fn ken-kh-style)`) whole against Hisagi's pool (his live `:qhs-ken`, step 4's HK iterates, his 11 step-4 arms), both seats; score = (live + iterates + arms) / 3; blocks seed0 200 search, 300 dev, 400 held-out; `inc_live` = the live lookup's own share (a tripwire) |
| `refs.sh`, `refs.jsonl` | the references before round 1: his KI code (= the baseline), Ichigo's KI code on Kenpachi, the live KH table, on the three blocks |
| `baseline/` | the starting `cpu-kh-ken.lisp` (his KI code unchanged), its search score, `proposal.md` (the references and the keep rule) |
| `brief.py` | one cell's brief (the exploration prompt + this project's rules) |
| `step.sh` | the loop: `next` (the policy's batch, briefs), `done <cell> <round> <worktree>` (copy, rescore, record), `fail ...` |
| `rescore.sh` | a delivered cell re-measured in the coordinator's checkout on the search block (host tests, the tripwire) |
| `heldout.sh` | the keep rule's measure for one cell (seed0 400, scale 2) and the rule against `refs.jsonl` -> `NODE_DIR/heldout.json` |
| `dream.sh` | the dream step after round 1: three rewrites of the skill's adaptive template (beta 0.6 / 0.3 / 0.9, `policy/v1_adaptive.py`, `v2_narrow.py`, `v3_wide.py`) compared with the incumbent; `v3_wide` promoted (`policy/history/`) |
| `config.json`, `policy/`, `rounds/`, `trace_pool/`, `proposal_results/` | drsi.py's workspace (round 1 = the configured 4 x 3 grid, W = 4; `rounds/round01/nodes/<cell>/`: the cell's `cpu-kh-ken.lisp`, `proposal.md`, its dev `score.json`, the rescore `score.rescored.json`, `heldout.json` where measured) |

Round 1 kept b0_a0 (the wake-up bait) as `duel/lisp/cpu-kh-ken.lisp`; the numbers, the keep decision and the KH / HK fit that followed
(`fq/switch/khstyle/`) are in DUEL_AI_STRATEGY §8.19 "Round 5, step 5". Round 2 was not run.

Cells: Sonnet subagents, each in its own git worktree (the scaffold copied in: `eval.py`, `cand-khfn.lisp`, the MANIFEST line, the parent's or
the baseline's `cpu-kh-ken.lisp`), its own native build, dev runs at seed0 300.
