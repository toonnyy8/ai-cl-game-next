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

Round 2 (the user: 「跑第二輪」; DUEL_AI_STRATEGY §8.19 "Round 5, step 8") ran under the promoted `v3_wide` policy, which planned 4 x 3 and
pruned branches 1 and 3 after their first cells (8 cells). A new direction started from round 1's b2_a0 (branches 0, 2) or from Ichigo's KI
code on Hisagi (`baseline/cpu-hk-hisagi-iki.lisp`, branches 1, 3; `brief.py` says which). It kept nothing: b0_a2 (the wake-up punish / guard
+ the Reishi pot) is the first code over the live-KH floor (held-out 0.388) but misses the stand-in floor (0.337) and bundles two rules.
`dream2.sh`: the dream step after it (`policy/r2/`; `v6_adaptive` promoted on a tie). The scaffold was removed from the game again.

Round 3 (the user: 「從 b0_a2 跑第三輪」; DUEL_AI_STRATEGY §8.19 "Round 5, step 9") ran the full 4 x 3 under `v6_adaptive` (every cell from
round 2's b0_a2, aimed at the stand-in group; `brief.py`'s round-3 section). Three bundles (the wake-up punish / guard + the Reishi pot + the
kite) clear every number of the keep rule, best b3_a1 (held-out 0.489 / live 0.478 / stand-in 0.406), but each is three rules. The split
test (`../fq/switch/hksplit/`) found that the three rules as one-job arms of HK's table don't keep the gain, so nothing ships; the scaffold
was removed again. `dream3.sh`: the dream step after it (`policy/r3/`; `v9_mid` promoted on a tie).

Step 10 (the user: 「新增一鍵開多條規則」; DUEL_AI_STRATEGY §8.19 "Round 5, step 10") put the split b3_a1 (`hksplit/split.py`) in the game as
`duel/lisp/cpu-hk-hisagi.lisp` for good, with its three rules as library units and an arm that turns all three on (`../fq/switch/hkmulti/`).
No table names them yet: the HK refit with them beat both KH tables but lost to the stand-in, so HK stays `:qhs-ken`. A new round would now
start from that file, not from `baseline/` (rescore.sh and heldout.sh restore `baseline/` into the checkout).
