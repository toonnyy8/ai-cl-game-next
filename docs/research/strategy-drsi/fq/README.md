# fq — the offline fuzzy Q selector, Ichigo vs Kenpachi HARD (DUEL_AI_STRATEGY §7 step 8', §8.12)

A Q selector over two arms (0 = Kenpachi's KI style, 1 = her own KI style), trained offline on logged matches. It is compared against
the hand composite c1 (`:c1-ichigo-ken`), which ships now. Glorennec & Jouffe 1997 (`docs/research/ai-mcts-fuzzy-learning/notes-fuzzy.md` item 5).

## Files

| File | What |
|---|---|
| `fq.py` | `init` (writes `fq-c1.lisp`), `log` (the behaviour policy's matches into `logs/`, ignored by git), `train` (fitted Q iteration into a strategy file + `.json`) |
| `c1.lisp` | c1 as shipped, for proving the `--raw` path |
| `fq-c1.lisp` | the 48-rule table whose greedy policy is c1 in every cell |
| `fq-v1-1-500.lisp` / `.json` | trained on seeds 1-500, validated on 501-599 (`validation-1-500.json`) |
| `fq-trained.lisp` / `.json` | **the result**: the same settings refit on seeds 1-599. `train-1-599.txt` is the trainer's output |
| `proof-*.json`, `eval-600.json`, `eval-700.json` | `tools/strategy-switch.py --raw` runs (the incumbent arm is c1, from the lookup) |

## Method

- **Runtime** (`duel/lisp/strategy.lisp` `strat-fq-q` / `strat-fq-pick`, dispatched from `strat-judge`): `(:id ID :fq (:arms (S0 S1) :rules ((ANTE Q0 Q1) ...) [:margin M]))`.
  - Q(a) = Σ α_r q_r(a) / Σ α_r. The arm is the argmax (ties go to the first; with no rule firing, arm 0). It always returns an arm.
  - It is judged on the composite's schedule (`strat-switch-step`: every 90 ticks in neutral) and resets the style state (`sw-fn`) the same way.
  - The cue `:prev` is the previous arm's index, so the rules can price a switch.
  - No random draw. Inside rollouts it is the same function.
- **Rule base**: lead (behind / even / ahead) x ored x his state free (`:ost :free` / `:busy`, the new set) x awk x prev, 48 rules.
  - At the judgements' values (integer lead and ost, 0/1 flags) every set is crisp, so one rule fires at strength 1. **In effect the table is
    tabular**: the fuzzy averaging does nothing here. The format is kept so that per-player TD updates can later sit on it unchanged.
- **Behaviour policy**: `fq-c1.lisp` plus ε = 0.15. On each judgement outside rollouts it takes the other arm when
  u(match seed, tick, side, salt) < ε, where u is a Park-Miller hash in `strat-run.lisp` `STRAT_FQLOG`; it never draws from `sim-rnd01`.
  - The log is 4 salts x seeds 1-599 x both seats = 4,792 matches and 714,801 judgements, of which 15.6 % explored.
  - Seeds 601-800 were used for evaluation only. These are §8.7's blocks "600-699 / 700-799" (`--seed0 600` / `700` plays seeds
    601-700 / 701-800). Seeds 800-949 were not touched.
- **Reward** per window = 0.1 x Δ(my `mc-full-health` - his), and ±1 at the match end (by the gate row's winner; 0 for a draw; a time-out has a winner by the lead). γ = 0.9.
  - `mc-full-health` already holds Konpaku, so the lead term is scaled by 0.1 too. That keeps a match's shaped return near ±1 alongside
    the terminal reward. The logs store the raw health, so the scale (`--scale`) can be retuned without new matches.
- **Fit**: policy evaluation of the current policy (80 sweeps of grouped means), then improvement with a gate.
  - The gate: a cell leaves c1's arm only when the other arm's Q is higher in >= 95 % of 200 bootstrap replicates and that arm has >= 30 samples.
  - Replicates resample whole seeds, so all salts and both seats of a seed move together.
  - The loop starts from π0 = c1 and repeats until the policy is stable (round 3).
  - In the written q values, the argmax equals the gated policy (cells kept at c1 get their other q clamped 0.001 below).
- Only one setting was tried (γ 0.9, scale 0.1, conf 0.95). It was validated once on 501-599, then refit on 1-599 and evaluated once on
  600-699 and 700-799.

## Proofs

- The `--raw` path: `c1.lisp` run raw against the incumbent (the lookup's c1) on 601-700, both seats: 165 = 165, b = c = 0.
- `fq-c1.lisp`: also 165 = 165, b = c = 0, on the same seeds.
- `duel hash` / `duel state` / gate-row lines are byte-identical on seeds 601-610, P1, across four runs: the incumbent, c1 raw, fq-c1, and
  fq-c1 with the logging hook at ε = 0.

## Result (Ichigo's wins, both seats, 100 seeds a seat; b / c = paired seeds the table won and c1 lost / the reverse)

| Seeds | fq-trained | c1 | b / c | z |
|---|---|---|---|---|
| 501-599 (validation, the 1-500 table) | 0.929 | 0.859 | 27 / 13 | 2.21 |
| 601-700 | **0.905** | 0.825 | 32 / 16 | 2.31 |
| 701-800 | **0.895** | 0.825 | 29 / 15 | 2.11 |
| 601-800 pooled | 0.90 | 0.825 | 61 / 31 | 3.13 |

The table holds her own arm on 41 % of the judgements; c1 holds it on 12.9 %.

## Where it leaves c1 (16 of 48 cells; arm per cell, q0 / q1)

- **Awakened (awk), 10 cells: her own style instead of Kenpachi's.** This holds whenever he is busy (any lead, 7 cells), and while he is
  free and she is even (2 cells) or ahead (from Kenpachi's). The largest cell is "ahead, not red, free, awakened, prev Ken": 213k samples, 0.130 / 0.136.
- **Not awakened, he is free, she is behind (not red) or even and he is red: Kenpachi's style instead of her own**, which is c1's own
  trigger reversed. Examples: behind, not red, free, prev Ken: 0.052 / 0.028; even, red, free: 0.044 / 0.032.
- **Switching cost (`:prev`)**: even, not red, he is busy, not awakened, already on her own style keeps it (-0.014 / -0.003), while from
  Kenpachi's it stays Kenpachi's.
- Even, he is red and busy, not awakened, prev Kenpachi's: her own (0.045 / 0.055).
- Ahead, red, free, awakened, prev own: back to Kenpachi's (0.434 / 0.420).

## Caveats

- The Q values are short-horizon (γ 0.9 per ~1.5-3 s window) and dominated by the health shaping, so the per-cell gaps are small. The
  match result is the real test, and it holds on both held-out blocks.
- The step from 0.825 to 0.90 is beyond noise when the blocks are pooled (z 3.1). Each block alone sits at z ≈ 2.1-2.3.
- An earlier `strat-run.lisp` bug made the composite's `judged` / `held` counts cover only each chunk's last match. It is fixed here, so
  the own shares in §8.8-§8.10 (e.g. "~15 %") came from 8 matches. The win counts were unaffected.
