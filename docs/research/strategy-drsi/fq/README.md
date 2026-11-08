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

## Online learning against the player (DUEL_AI_STRATEGY §8.14)

The shipped table (`:q1-ichigo-ken`, = `fq-trained.lisp`) is the starting point of a per-player copy that learns between matches. The
runtime is `duel/lisp/strategy.lisp` (the pure math) and `ai-learn.lisp` (`fq-attach!`, `fq-note`, `fq-explore`, `fq-match-end`). The proof
lives in `online.py` and `online/`.

| File | What |
|---|---|
| `online.py` | `train` (learning runs against a player proxy, with frozen q1 on the same seeds for a paired curve) and `eval` (a frozen table against q1, held-out seeds, both seats) |
| `online/ken-istyle.lisp` | proxy 1: Kenpachi playing Ichigo's KI style CPU (`:fn ichigo-ki-style`) |
| `online/ken-wide.lisp` | proxy 2: Kenpachi's KI style CPU keeping a 1.4x range |
| `online/ken-close.lisp`, `online/ken-wide2.lisp` | proxies measured once and not used (q1 0.875 / 0.775 at 20 seeds a seat) |
| `online/out/<tag>/` | each training config: `train.json` (the curve, per block of 25 matches) and the tables `run<r>-<k>.lisp` (run r after chunk k; `-5` is the final one) |

- **The player proxy**: the learner's opponent is a CPU, marked as the human by `strat-run.lisp STRAT_FQLEARN` (`*fq-learn-force*`). Ichigo
  sits on P2, as in VS CPU. Training seeds 1-599 split into 4 runs of about 150 matches each, in order; each run starts from the shipped table.
  Chunks of 25 matches are chained through the table file. Held-out seeds are 601-800, both seats, with the tables frozen (learning off).
- **Identity**: with the learner attached, `eta 0` and `eps 0`, ten matches (601-610, P2, against proxy 1) give the same 313 `duel hash` /
  `duel state` / gate-row lines as with no learner. With learning on, the first match is identical, and the tables change from match 2 on.
- **Configs** (training seeds only; `online/out/<tag>/train.json`; wins of 599, q1 89 against proxy 1, 387 against proxy 2):

  | tag | η | cap | ε | proxy | learner | b / c | z |
  |---|---|---|---|---|---|---|---|
  | istyle-e05-c01 (**shipped knobs**) | 0.05 | 0.01 | 0 | 1 | 197 | 131 / 23 | 8.7 |
  | istyle-e05-c02 | 0.05 | 0.02 | 0 | 1 | 174 | 107 / 22 | 7.48 |
  | istyle-e05-c05 | 0.05 | 0.05 | 0 | 1 | 187 | 157 / 59 | 6.67 |
  | istyle-e02-c05 | 0.02 | 0.05 | 0 | 1 | 171 | 148 / 66 | 5.61 |
  | istyle-e05-c10 | 0.05 | 0.1 | 0 | 1 | 70 | 60 / 79 | -1.61 |
  | istyle-e10-c10 | 0.1 | 0.1 | 0 | 1 | 114 | 96 / 71 | 1.93 |
  | istyle-e05-c05-p05 | 0.05 | 0.05 | 0.05 | 1 | 242 | 202 / 49 | 9.66 |
  | istyle-e05-c05-p10 | 0.05 | 0.05 | 0.1 | 1 | 275 | 235 / 49 | 11.04 |
  | istyle-e00-p10 (no learning: ε alone) | 0 | - | 0.1 | 1 | 113 | 91 / 67 | 1.91 |
  | wide-e05-c01 (**shipped knobs**) | 0.05 | 0.01 | 0 | 2 | 502 | 150 / 35 | 8.45 |
  | wide-e05-c02 | 0.05 | 0.02 | 0 | 2 | 487 | 149 / 49 | 7.11 |
  | wide-e05-c05 | 0.05 | 0.05 | 0 | 2 | 512 | 168 / 43 | 8.61 |
  | wide-e05-c05-p05 | 0.05 | 0.05 | 0.05 | 2 | 354 | 129 / 162 | -1.93 |
  | recover-run2 (istyle run 2's table, then 150 matches against the shipped Kenpachi) | 0.05 | 0.05 | 0 | shipped | 133 of 150 (q1 137) | | |

- **Held-out** (601-800, both seats, 400 matches a table, frozen; q1 in brackets): see DUEL_AI_STRATEGY §8.14's table for the shipped knobs.
  Cap 0.05, ε 0: proxy 1 0.4575, 0.4075, 0.02, 0.4475 (0.1625); proxy 2 0.795, 0.8975, 0.7875, 0.87 (0.685); against the shipped Kenpachi
  (601-800, 0.90) proxy 1's 0.6975, 0.8425, 0.34, 0.8525 and proxy 2's 0.935, 0.955, 0.92, 0.9525.
- **Against the shipped Kenpachi on 851-950** (200 matches a table, q1 0.905; the safety check the cap was chosen on): cap 0.01 finals, proxy 1
  0.83, 0.915, 0.905, 0.915, proxy 2 0.865, 0.925, 0.905, 0.93; after 25 matches (proxy 1) 0.855, 0.765, 0.67, 0.775. Cap 0.02 finals,
  proxy 1 0.81, 0.95, 0.91, 0.79, proxy 2 0.935, 0.945, 0.91, 0.94. Cap 0.05 finals, proxy 1 0.65, 0.8, 0.35, 0.82, proxy 2 0.94, 0.96,
  0.93, 0.94; after 25 matches (proxy 1) 0.8, 0.925, 0.35, 0.655.
  The ε 0.05 tables: proxy 1 0.4075, 0.395, 0.3825, 0.2775 (0.1625); proxy 2 0.5625, 0.2675, 0.5325, 0.4625 (0.685). The ε 0.1 tables against
  proxy 1: 0.3225, 0.39, 0.27, 0.39. Against the shipped Kenpachi, the proxy-1 ε 0.05 tables 0.78, 0.525, 0.5975, 0.7675 and the proxy-2 ones
  0.91, 0.625, 0.8125, 0.71 (0.90). `istyle-e05-c05-old/` is the first run of the shipped knobs, identical to `istyle-e05-c05/` (rerun after
  the ε code went in, the reproduction check).

## Any pairing (DUEL_AI_STRATEGY §8.15)

`fq.py` and `online.py` take `--char C --vs D`; their defaults are still Ichigo vs Kenpachi as above, and they reproduce it (below).

- **Arms**: two strategy specs, each a file, a frozen library id (`../counter/frozen/<id>.lisp`) or `none`. A NIL arm is the incumbent:
  the character's HARD CPU with its lookup strategy and style CPU (a composite's no-entry fallback). An explicit arm 0 names the incumbent's
  strategy (e.g. `ki-ichigo`); both prove equal to the incumbent (below).
  - Limits: arms don't nest (a composite or a Q table as an arm is played as a plain plist, never judged), so IK's incumbent q1 cannot be an
    arm; and when a table itself becomes the lookup entry, a NIL arm falls back to the lookup = the table (as a plain plist). **A shipped table
    therefore needs an explicit arm 0.** Where the incumbent is the shipped CPU with no strategy and no matchup style CPU (Kenpachi vs Hisagi,
    the three mirrors), the empty strategy `(:id :shipped)` is that arm: proved bit-identical below. **Kenpachi vs Ichigo is the exception**:
    his shipped CPU runs his KI style CPU after the MCTS (`cai-defstyle`), which an empty arm stops and a `:fn ken-ki-style` arm runs before
    the MCTS; `proof/ki-shipped.lisp` (arm 0 `(:id :shipped)`) gives 0.005 against the incumbent's 0.095 (b / c 1 / 19). Shipping a KI table
    needs a small runtime change (e.g. an arm meaning "no strategy, no lookup": `cur` NIL so the style CPU runs). This blocks only the lookup
    step, not the tooling or the search.
- **Rule base**: the 48 crisp rules (lead x ored x ost free x awk x prev) are `strat-feats` cues, the same for every character, so they carry
  over unchanged. Whether another pairing needs other cues (e.g. distance, his Reishi) shows only after its search names the alternative arm.
- **Tables carry `:apply (me vs)`** (the online learner keys IN by it).
- **Opponent**: `--opp` (fq.py log) / `--proxy` (online.py) take a spec or a comma list = a pool: `strat-run.lisp` plays member (match seed mod
  n). Only the character's seat logs and explores (`STRAT_FQLOG` "salt eps seat") and only P2 learns (`STRAT_FQLEARN` "in out seat"), so an
  opponent that is itself a Q selector (Ichigo's q1 against Kenpachi) stays frozen.
- **Logs** per pairing: `logs/<tag>/` (default `<char>-<vs>`; the §8.12 logs moved to `logs/ichigo-kenpachi/`; `log-args.txt` there records
  what each `log` call played). Online runs: `online/out/<char>-<vs>/<tag>/` (Ichigo vs Kenpachi keeps `online/out/<tag>/`).

### Steps for a pairing
1. `python3 fq.py init --char C --vs D --arms A0 A1 --policy arm0 --out T0.lisp` (arm 0 everywhere = the incumbent; prove it with
   `proof/identity.py C D VS_STRAT T0.lisp`).
2. `python3 fq.py log --char C --vs D --table T0.lisp --opp SPEC --salt k --eps 0.15 --seeds 1-599 [--tag C-D]` for salts 1-4 (SPEC: the
   frozen opponent from `../counter/workspaces.json`, or the pairing's pool from `pools.json` as a comma list).
3. `python3 fq.py train --init T0.lisp --seeds 1-599 --out T.lisp` (pi0 = T0's argmax; validate on a held-back block first, as §8.12 did).
4. Evaluate: `tools/strategy-switch.py --char C --vs D --vs-strat SPEC --cand T.lisp --raw --seed0 600` / `700`.
5. Online: `python3 online.py train --char C --vs D --table T.lisp --proxy SPEC --tag X --eta 0.05 --cap 0.01` and `online.py eval ...
   --learned out/.../runR-K.lisp`. Report each table's arm gaps: where they mostly exceed 0.02 the cap-0.01 learner cannot flip a cell (an
   init table's 1 / 0 gaps never flip).

### Reproduction of Ichigo vs Kenpachi through the generalised tools
- `fq.py init` (defaults) rewrites `fq-c1.lisp` identically (but for the added `:apply`).
- `fq.py train --seeds 1-599` on the moved logs gives `fq-trained.lisp` identically (q values of all 48 rules; only `:apply` added), and its
  JSON's cells, flips and stats equal `fq-trained.json`'s.
- `fq.py log --salt 1 --eps 0.15 --seeds 1-25 --opp none` (the seat token, `none` for Kenpachi) gives the same log lines as
  `logs/ichigo-kenpachi/fq-s1-e0.15-P{1,2}-1-25.out.gz` (4,007 / 4,330 lines, byte-identical).
- `online.py`'s new path (the table `frozen/q1-ichigo-ken.lisp` on P2, attached by `strat-run.lisp`, the proxy on `STRAT_P1`, the learner's seat
  given) reproduces `online/out/wide-e05-c01/run0-0.lisp` and `run0-1.lisp` byte for byte (21 and 22 wins of 25, as in its train.json; frozen 18).
- A KI smoke run (Kenpachi learning on P2 with `proof/ki-arm0.lisp`, the frozen q1 on P1, 3 matches): the out table is keyed (:kenpachi
  :ichigo), 17 cells moved, none beyond the cap 0.01. Its stdout has `duel fq learn 1 3` after each match and no `duel fq learn 3 1`: q1 on
  P1 does not learn (its copy is loaded by START-MATCH's attach under the force flag, then dropped by the runner).

### Identity: a table that always plays arm 0 equals the incumbent (`proof/identity.py`, `proof/identity-600.jsonl`)
Seeds 601-700, both seats, the frozen opponent; `duel hash` / `duel state` / gate-row lines of every match compared (the c1 method, §8.12):

| Pairing | Table | Arm 0 | Shares (table / incumbent) | Lines identical |
|---|---|---|---|---|
| Kenpachi vs Ichigo | `proof/ki-arm0.lisp` | NIL | 0.095 / 0.095 | 8 of 8 chunks, 5,783 lines |
| Ichigo vs Hisagi | `proof/ih-arm0.lisp` | NIL (= her lookup `:ki-ichigo`) | 1.0 / 1.0 | 8 of 8, 3,206 |
| Ichigo vs Hisagi | `proof/ih-arm0-explicit.lisp` | `:ki-ichigo` explicit | 1.0 / 1.0 | 8 of 8, 3,206 |
| Kenpachi mirror | `proof/kk-arm0.lisp` | NIL | 0.5 / 0.5 | 8 of 8, 5,474 |
| Hisagi vs Ichigo | `proof/hi-arm0-explicit.lisp` | `:s3-zoner` explicit | 0.0 / 0.0 | 8 of 8, 3,206 |
| Ichigo vs Kenpachi | `frozen/q1-ichigo-ken.lisp` raw (IK's incumbent is q1 itself) | - | 0.905 / 0.905 | 8 of 8, 5,783 |
| Kenpachi vs Hisagi | `proof/kh-shipped.lisp` | `(:id :shipped)` explicit | 0.035 / 0.035 | 8 of 8, 4,567 |
| Kenpachi mirror | `proof/kk-shipped.lisp` | `(:id :shipped)` explicit | 0.5 / 0.5 | 8 of 8, 5,474 |
| Ichigo mirror | `proof/ii-shipped.lisp` | `(:id :shipped)` explicit | 0.495 / 0.495 | 8 of 8, 6,304 |
| Hisagi mirror | `proof/hh-shipped.lisp` | `(:id :shipped)` explicit | 0.5 / 0.5 | 8 of 8, 5,226 |
| Kenpachi vs Ichigo | `proof/ki-shipped.lisp` | `(:id :shipped)` explicit | **0.005 / 0.095, differs** (his style CPU stops) | 0 of 8 |

IK is proved the other way (a NIL arm there is the lookup's q1 played as a plain plist, §8.11's limit): its table initialised from the
incumbent equals it (fq-c1 = c1, §8.12; q1 run explicitly = the lookup's q1, the sixth row).

## Proxy pools for the three pairings at the ceiling (`pools.json`, `pool/`)
Fixed before any training or measurement (2026-11-09). The opponent plays member (seed mod n). `pool/measure.py PAIRING` measures the
incumbent (the HARD CPU with its lookup) against each member on all 100 seeds a seat, and against the pool as a whole (seed mod n), seeds
601-700, both seats (`pool/<pairing>-600.json`). There is no KI style CPU for Hisagi.

| Member (opponent's strategy) | IK (q1) | HK (`:ki-ken`) | IH (`:ki-ichigo`) |
|---|---|---|---|
| none: his shipped CPU (IK, HK: the frozen opponent) | 0.905 | 0.965 | 1.0 (Hisagi's generic CPU) |
| `frozen/s3-zoner.lisp` (IH: the frozen opponent) | - | - | 1.0 |
| `frozen/ki-ken.lisp`: Kenpachi's KI style | 0.805 | 0.375 | 0.61 |
| `online/ken-istyle.lisp`: Ichigo's KI style (§8.14 proxy 1) | 0.135 | 0.435 | 0.02 |
| `online/ken-wide.lisp`: Kenpachi's KI style x1.4 range (proxy 2) | 0.655 | 0.625 | 0.485 |
| `frozen/s7-kite.lisp`: the kite | - | - | 1.0 |
| pool, seed mod n / mean of members | 0.615 / 0.625 | 0.575 / 0.6 | 0.71 / 0.686 |

- Members the incumbent already beats ~1.0 teach little: IH's s3-zoner, generic and kite (1.0 each), and the frozen opponents of IK / HK
  (0.905, 0.965). Kept, as fixed.
- Near 0.0: IH against Ichigo's KI style on Hisagi (0.02), IK against the same on Kenpachi (0.135): they teach only if the other arm wins
  there. The middle members (0.375-0.805) are where a table has room.
