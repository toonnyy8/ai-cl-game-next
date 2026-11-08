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

## The second search: every HARD pairing against a frozen opponent (DUEL_AI_STRATEGY §8.15)

The user, 2026-11-09: 「為每個對戰組合搜尋第二輪策略，並建構出各自的 Q table 與 online fuzzy Q learning」, 「混合：弱組對現行、強組對代理」,
「要，九組全做」. The three weak pairings and the three mirrors search here; the three at the ceiling (IK, IH, HK) skip the search and train
their Q tables against a proxy pool (`../fq/pools.json`, `../fq/README.md`).

- **Frozen opponents.** `workspaces.json` `vs_strat` is the opponent seat's strategy, passed to the evaluator as `--vs-strat` in the cells'
  dev runs, the rescoring (`step.sh`) and `config.json`'s `eval_command`, so lookup changes that ship later cannot move a workspace's
  numbers. It is today's HARD opponent: its lookup strategy dumped from the library into `frozen/` (`frozen/dump.lisp`, which checks each
  file READs back EQUAL), or `none` = his shipped CPU with no strategy at all (`strat-run.lisp`: BRAIN-STRAT NIL, also immune to a later
  lookup entry). `tools/strategy-switch.py` puts it on the other seat in both arms; the cache key includes the seat and the text.
  - Reproduction (seeds 600-699, both seats; never-firing candidate): the frozen opponents give exactly the shares measured with the live
    lookup (IK 0.905, IH 1.0, HK 0.965, KI 0.095, KH 0.035, HI 0.0, KK 0.5, II 0.495, HH 0.5), and the incumbent arm's `duel hash` / `duel
    state` / gate-row lines are byte-identical to the pre-change runs in all 72 chunks (44,116 lines).
  - A mirror: the character's seat gets the candidate, the other seat the frozen opponent (`none` = the incumbent), both seats measured.
    The incumbent's share is about 0.5 by construction (draws count 0).
- **Rules** (`capped_from`, `second_from`): the five new workspaces use §8.9's rules from their round 1 (own share <= 0.6, dev seeds
  800-899 x 2 seats, a second dev block at 900); `ki-ken` continues at round 2. Search seeds 600-699, held-out 700-799, as before.
- **Policy**: every workspace starts from the allocation policy the dream step promoted in round 2 (ki-ichigo / kh-hisagi `policy/current.py`,
  "rank and momentum"). `ki-ken` promoted it with `drsi.py compare` on its own round-1 world (replay reward 0.527 against the baseline policy's
  -0.017, one world); the five new ones were initialised with it.

| Workspace | Pairing (HARD) | Frozen opponent | Baseline search 600-699 | Held-out 700-799 |
|---|---|---|---|---|
| `ki-ken` (round 2) | Kenpachi vs Ichigo | `frozen/q1-ichigo-ken.lisp` (her Q table) | 0.095 (`baseline-r02/`) | 0.105 |
| `kh-ken` | Kenpachi vs Hisagi | `frozen/ki-ken.lisp` (Kenpachi's KI style as Hisagi's) | 0.035 | 0.015 |
| `ih-hisagi` | Hisagi vs Ichigo | `frozen/ki-ichigo.lisp` (her KI style) | 0.0 (score 0.005) | 0.0 |
| `kk-ken` | Kenpachi mirror | none | 0.5 | 0.5 |
| `ii-ichigo` | Ichigo mirror | none | 0.495 | 0.5 |
| `hh-hisagi` | Hisagi mirror | none | 0.5 | 0.5 |

The older workspaces got `vs_strat` too (ih-ichigo `frozen/s3-zoner.lisp`, ki-ichigo and kh-hisagi `none`): the opponents they were run
against. Only the opponent is frozen: the character's own incumbent is its live lookup entry, which has changed for ki-ichigo (now q1, which a
composite cannot sit on, §8.11) and kh-hisagi (now `:ki-ken`), so their old cells would not rescore to their recorded numbers.

### Running a workspace
- New one: `drsi.py -w <ws> init --task ... --workers 4 --baseline-score <baseline score> --branches 3 --refines 2 --lam 0.05 --policy <policy>
  --eval-command "<the step.sh rescoring command>"`, its `workspaces.json` entry, `<ws>/baseline/score.json` (strategy-switch with a never-firing
  candidate `(:id :never :own ())`, `--vs-strat`, `--max-own 0.6`, `--out`) and `proposal.md`.
- Each round: `drsi.py -w <ws> plan`, then `step.sh <ws> next` writes the batch's briefs (`rounds/roundNN/nodes/<cell>.brief.md`); dispatch
  each to a subagent (Sonnet, W = 4 across workspaces), then `step.sh <ws> done <cell> <round>` (rescore on 600-699 with the frozen opponent and
  the cap, record, next batch) or `step.sh <ws> fail ...`. After the round: `drsi.py close-round`, the dream step (replay / compare /
  promote), admission on 700-799.
- State on 2026-11-09: all six planned (grid 3 x 3), the first batch's briefs written (b0_a0, b1_a0, b2_a0 each), no cell run.
