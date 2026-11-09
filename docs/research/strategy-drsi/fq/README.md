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

- **Arms**: two strategy specs, each a file, a frozen library id (`../counter/frozen/<id>.lisp`) or `none`. A NIL arm is no strategy at all:
  the character's shipped CPU with its matchup style CPU, never the lookup (core-ai.lisp since §8.18; before, a NIL arm fell back to the
  lookup, which broke once the table was itself the entry). An incumbent that is a lookup strategy needs it as an explicit arm 0. An explicit arm 0 names the incumbent's
  strategy (e.g. `ki-ichigo`); both proved equal to the incumbent (below; `proof/ih-arm0.lisp`'s NIL arm 0 meant the lookup's `:ki-ichigo`
  before the §8.18 fix and is no longer that incumbent).
  - Limits: arms don't nest (a composite or a Q table as an arm is played as a plain plist, never judged), so IK's incumbent q1 cannot be an
    arm; and when a table itself becomes the lookup entry, a NIL arm falls back to the lookup = the table (as a plain plist). **A shipped table
    therefore needs an explicit arm 0.** Where the incumbent is the shipped CPU with no strategy and no matchup style CPU (Kenpachi vs Hisagi,
    the three mirrors), the empty strategy `(:id :shipped)` is that arm: proved bit-identical below. **Kenpachi vs Ichigo is the exception**:
    his shipped CPU runs his KI style CPU after the MCTS (`cai-defstyle`), which an empty arm stops and a `:fn ken-ki-style` arm runs before
    the MCTS; `proof/ki-shipped.lisp` (arm 0 `(:id :shipped)`) gives 0.005 against the incumbent's 0.095 (b / c 1 / 19). Shipping a KI table
    needs a small runtime change (e.g. an arm meaning "no strategy, no lookup": `cur` NIL so the style CPU runs). **Done in §8.18**: a NIL
    arm is now exactly that, so a NIL arm 0 ships (proved on the build with the entries, `pairs/proofs-600.jsonl`).
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

## Hisagi's three pairings (DUEL_AI_STRATEGY §8.17, `hisagi/`)
Arms: his merged style `seeds/s9-hisagi-merged.lisp` (`:hm1-merged`) and the old incumbent (`counter/frozen/s3-zoner.lisp` vs Ichigo,
`counter/frozen/ki-ken.lisp` vs Kenpachi, `hisagi/shipped.lisp` = `(:id :shipped)` in the mirror). Opponents: the frozen `:ki-ichigo`, the
pool `hisagi-kenpachi` of `pools.json`, the shipped CPU (`none`). `<p>`: hi (Hisagi vs Ichigo), hk (vs Kenpachi), hh (the mirror).

| File | What |
|---|---|
| `<p>-t0.lisp`, `identity-600.jsonl` | §8.15's plan: arm 0 the incumbent everywhere, proved equal to it (`proof/identity.py`) |
| `<p>-fq.lisp` / `.json`, `<p>-train.txt`, `<p>-fq-eval-{600,700}.json` | fitted from t0 (logs `logs/hisagi-<vs>/`); HI 0.0 / 0.0 |
| `<p>-m0.lisp`, `identity-m0-600.jsonl` | arm 0 the merged style everywhere, proved equal to it played whole (`identity.py --ref`) |
| `<p>-fqm.lisp` / `.json`, `<p>-trainm.txt`, `<p>-fqm-eval-{600,700}.json` | **shipped** (`:qh-ichigo` / `:qh-ken` / `:qh-mirror`): fitted from m0 (logs `logs/hisagi-<vs>-m/`) |
| `merged/` | the merged style's variants against Kenpachi's KI style whole and `:h1-range` whole, seeds 701-800, with STRAT_HRANGE stats |
| `shipped/` | the lookup live (the incumbent now) against the old incumbent run raw, and the opposite pairings (IH, KH) under it |

## The Q tables of §8.18 (Kenpachi or Ichigo as me), `pairs/`
DUEL_AI_STRATEGY §8.18 has the numbers. One folder per pairing (`ki kh kk ii ik ih`):

| File | What |
|---|---|
| `<p>/arm1.lisp` | arm 1 (the whole-game replacement or the best cell, without `:own`) |
| `<p>/<p>-t0.lisp` | the table initialised to the incumbent (arm 0 everywhere; IK: q1 renamed): `identity-600.jsonl` |
| `<p>/<p>-t1.lisp` | arm 1 everywhere: round 2's behaviour policy (KI KH KK II) |
| `<p>/<p>-v1-500.lisp`, `-v1b-500`, `-v2-500` | trained on 1-500: round 1 (π0 the incumbent), KI's round 1 with π0 arm 1, round 2; `validation-1-500*.json` (501-599) |
| `<p>/<p>-fit.lisp` / `.json`, `train-1-599.txt` | **the shipped tables**, refit on 1-599 (KI KK II round 2, KH IH round 1; IK keeps q1) |
| `<p>/heldout-700*.json`, `<p>/alt-700.json` | held-out 701-800: the table, the incumbent and arm 1 alone, paired |
| `ik/cands-0.jsonl`, `ih/cands-0.jsonl` | arm 1 for the ceiling pairings: every candidate against the pool, seeds 1-100 |
| `gaps.jsonl` | each table's arm gaps (`gaps.py`) |
| `proofs-600.jsonl` | on the build with the entries: each t0 = the earlier build's incumbent (`cross.py`), each fit raw = the live lookup |
| `negative-control-nofix.json` | the same t0 proof for KI on a build without the NIL-arm fix: 0 of 8 identical (0.005) |
| `live-600.jsonl` | every pairing with both seats on the lookup (`live.py`) |

Tools: `run-logs.py` (fq.py log, 4 salts, per pairing; tags `logs/<p>-<suffix>/`), `cands.py`, `heldout.py` (strategies paired with each
other and with the incumbent on one block; `HJ` = processes), `cross.py`, `proofs.py`, `live.py`, `gaps.py`, `lib-block.py` (the library
entries printed from the fits). Logs (gitignored): `ki-t0 kh-t0 kk-t0 ii-t0 ik-t0 ih-t0` (round 1), `ki-t1 kh-t1 kk-t1 ii-t1` (round 2),
`ik-v1-500` (IK's round 2).

## §8.19: the Hisagi vs Ichigo table that switches, `switch/`
DUEL_AI_STRATEGY §8.19 has the numbers. Opponent: Ichigo's frozen `:ki-ichigo`, HARD, both seats. The table has:
- six arms: five general, one aimed at Ichigo;
- 89 rules in five additive groups (`:groups`);
- a judgement every 30 steps (`:period 30`);
- each style's state kept across switches (`:keep-state`);
- extra cues read at the judgement (`:xfeats`).

The pilot is `hi-sw-pilot.lisp` (`:qhs-ichigo`). Round 2 (§8.19 "Round 2") rebuilt Hisagi's three tables:
- **HI**: `hi/qhs2-ichigo.lisp` (`:qhs2-ichigo`, in the lookup);
- **HK**: no swap, `:qh-ken` stays;
- **HH**: `hh/qhs-mirror.lisp` (`:qhs-mirror`, in the lookup).

Round 3 (§8.19 "Round 3"):
- HI keeps `:qhs2-ichigo`: the learnable Shikai preference lost.
- The Shikai's DRIVE switch (`:shikai-dswitch`) is written but not shipped: it never opens in a match.
- HH: `hh/qhs2-mirror.lisp` (`:qhs2-mirror`, in the lookup).

Round 4 (§8.19 "Round 4"):
- HI plays `hi/qhs3-ichigo.lisp` (`:qhs3-ichigo`, the learnable +0.08 Shikai preference).
- The delayed awakening (`:hold-awaken`) loses: not shipped.
- Kenpachi's three tables go into the lookup: `kenpachi/qks-ichigo.lisp`, `qks-hisagi.lisp`, `qks-ken.lisp`.

Round 5, step 1 (§8.19 "Round 5, step 1"; every fit and swap test against the opponent's live lookup table):
- Ichigo vs Hisagi plays `ichigo/qis-hisagi.lisp` (`:qis-hisagi`).
- Ichigo vs Kenpachi and the Ichigo mirror keep their shipped tables.

| File | What |
|---|---|
| `sw.py` | Common options `--me --vs --opp --arms` (the pairing, the opponent seat, the arms file; the pilot's by default). `start`: the start table (arm 0 everywhere, or `--embed` a 2-arm table's 48 rules). `log`: behaviour + run exploration (`STRAT_FQLOG "<salt> <eps> <seat> <rmin> <rmax>"`). `fit`: a ridge V + per-arm deltas on the discounted return, with the bootstrap sign gate. `measure`: at eps 0, shares, draws, per-seed wins, switch counts by form / distance band, STRAT_HRANGE, the DRIVE switches by form. `pin`: an arm's bonus in a form's G1 rows. `pair`: b / c |
| `hi-sw0.lisp`, `hi-sw0-p30.lisp` | the start table: `:qh-ichigo`'s 48 rules inside the grouped base, arms 2-5 below, new groups 0. Period 90 for the proof; period 30 is round 1's behaviour |
| `identity-start-600.jsonl`, `proofs-final.jsonl` | the start table = `:qh-ichigo` (8 of 8: before the entry, and on the final build with `--ref hisagi/hi-fqm.lisp`); the pilot run raw = the live lookup (8 of 8) |
| `arms/` | each arm played whole (`screen.py`): HI seeds 1-300; HK against the proxy pool and HH against the shipped CPU, seeds 1-50 (`*-hk-*`, `*-hh-*`); round 2: HK against `:q1-ken-hisagi` and HH against `:qh-mirror`, seeds 1-100 (`*-hkL-*`, `*-hhL-*`). `ship-qh-ken.lisp` / `ship-qh-mirror.lisp`: the shipped tables, copied. The arms files: `hi-pilot.arms`, `hi.arms` / `hi-d.arms` (arm 0 press / press + `:dswitch`), `hk.arms`, `hh.arms` |
| `fits/` | every round's tables (`r1`, `r2a`, `r2b`, `r3` x gamma); `press-all.lisp` (arm 3 everywhere: round 2b's behaviour); `r2a-g966-nokeep.lisp` (the kept-state check) |
| `ev/` | `measure` summaries: `sel-*` seeds 851-950 and `sel2-*` 801-1000 (the selection blocks), `ho601-*` / `ho701-*` held-out, `cost-*` (logged with the log on, so not the cost figure) |
| `hi-sw-pilot.lisp` | **shipped** (`:qhs-ichigo`): round 2a, gamma 0.966 per 0.5 s window, scale 0.1 |
| `gaps.py`, `bench.lisp` | the arm gaps at the logged judgements; the host cost of one judgement (34 -> 45 µs) |
| `live-ih-600.json` | Ichigo vs Hisagi with both seats on the lookup (0.405) |
| `hi/`, `hk/`, `hh/` | round 2. `<p>2-s0*.lisp`: the start tables. `<p>2-r<k>-g<gamma>[-pin|-pind|-pinr].lisp` + `.json`: the fits and their pins (HI `-pin` arm 0 in the Shikai; `-pind` the same with arm 0 = press + `:dswitch`; HK `-pinr` arm 0 in the ranged mode). `qhs2-ichigo.lisp`, `qhs-mirror.lisp`: **shipped**. `identity-s0-600.jsonl`: each start table = what it starts from, on the build before the entries |
| `proofs2.sh`, `proofs2-600.jsonl` | round 2 on the final build: the three start tables (HI = press whole, HK = `:qh-ken`, HH = the kite whole) and the two shipped tables run raw = the live lookup, 8 of 8 each |
| `report.py` | one line per measure (share, draws, changes, arms, the ranged mode's distance, DRIVE switches) and b / c against the first |
| `ev/hi-*`, `ev/hi2-*`, `ev/hk-*`, `ev/hk2-*`, `ev/hh-*`, `ev/hh2-*` | round 2's measures: `*-sel2-*` / `*-sel2b-*` seeds 801-1000 / 801-850, `*2-ho601-*` / `*2-ho701-*` held-out (`hh2-ho601-pick-vs-pick`: the new mirror table on both seats) |
| `live-ih2-600.json` | Ichigo vs Hisagi with both seats on the lookup after round 2 (0.13) |
| `prior.py` | sizing a learnable preference: the other arms' margin over one arm in one form (and band) at the logged judgements, and per bias how many states it wins and how many stay within the online learner's 0.05 reach |
| `hi/hi3-*` | round 3, HI: `hi3-r1-g98-b0.05` / `-b0.08` (round 1's fit + a learnable press bias in the Shikai; b 0.05 the pick, lost on held-out), `hi3-r2-g98-p05` / `-p08` (+ `.json`: the Shikai rows refit from round 2's data starting at that bias), `hi3-ds` (the live table with `:shikai-dswitch` on arm 0, `arms/hi-ds.arms`) |
| `hh/hh3-*`, `hh/qhs2-mirror.lisp` | round 3, HH: `hh3-b05` (the live table + 0.05 on merged at ranged close: round 3's behaviour), `hh3-r1-g966-p05` (+ `.json`: the refit with that prior) = **shipped** `qhs2-mirror.lisp`; `hh3-ds` (the live table with `:shikai-dswitch`, `arms/hh-ds.arms`) |
| `arms/a9-pressds.lisp` | press + the DRIVE switch + `:shikai-dswitch`, played whole |
| `proofs3.sh`, `proofs3-600.jsonl` | round 3 on the final build: `:qhs2-ichigo` and `:qhs2-mirror` run raw = the live lookup, 8 of 8 each |
| `hi/qhs3-ichigo.lisp`, `hi/hi4-h*.lisp`, `arms/hi-h*.arms`, `arms/a10-presshold*.lisp`, `hold.sh` | round 4, HI: the shipped +0.08 table; the delayed awakening (`:hold-awaken` 0.3 / 0.6) inside it and whole, on the selection block |
| `proofs4.sh`, `proofs4-600.jsonl` | round 4 on the final build: `:qhs3-ichigo`, `:qks-ichigo`, `:qks-hisagi`, `:qks-ken` run raw = the live lookup |
| `kenpachi/` | round 4, Kenpachi's three tables. `arms/k*.lisp` (+ `-ki` / `-kh` / `-kk` screens, seeds 1-100) and `screen.sh`. `ki.arms`, `kh.arms`, `kk.arms`. `start.sh` (start tables embedding each shipped `:q1-ken-*`, `identity-s0-600.jsonl`). `round1.sh`, `round2.sh`, `measure.sh`, `heldout.sh`. `<p>-r<k>-g<gamma>.lisp` / `.json` (fits; `-m01` with `:margin 0.01`, measured after the picks). `ki-press-all.lisp` (press in every state, for its form counts). `qks-*.lisp`: **shipped**. `live.sh`, `live-600.jsonl`: the cross effects with both seats on the lookup |
| `lineup.sh`, `run.sh`, `live9.sh` | round 5: each pairing's options against the other side's live table (`lineup.sh`: the opponent, the arms, the current table, the frozen stand-in); one pairing's steps (`run.sh P measure / log / fit / start / pin / all / heldout`); all nine pairings CPU vs CPU with both seats on the lookup (`live9.sh`) |
| `ichigo/` | round 5, Ichigo's three tables. `arms/i*.lisp` (+ `-ik` / `-ih` / `-ii` screens against the live opponents, seeds 1-100) and `screen.sh`. `ik.arms`, `ih.arms`, `ii.arms`. `start.sh` (start tables embedding each shipped `:q1-ichigo-*`, `identity-s0-600.jsonl`). `round.sh`, `round2.sh`, `fits.sh`. `<p>-r<k>-g<gamma>[-b05 / -b02].lisp` / `.json` (fits; IH's `-b05` with Kenpachi's code +0.05 in her base form). `ih-kenki-all.lisp` (Kenpachi's code in every state, for its form counts). `qis-hisagi.lisp`: **shipped**. `proof-600.jsonl` (`:qis-hisagi` run raw = the live lookup). `live9-600.jsonl` (all nine pairings, both seats on the lookup) |
| `corefit/` | round 5 step 2, the co-refit: `round.sh` (round 1, all nine) and `round2.sh` (round 2: KH, IK, HH), `select.sh` (the selection block), `frozen.sh` (each table against the frozen style CPUs, reported only), `proofs.sh` / `proofs-600.jsonl` (the four swapped tables run raw = the live lookup). `<p>-r<k>-fit.lisp` / `.json` (the fits), `<p>-r<k>.lisp` (with the prior put back), `hh-r1m.lisp` / `hk-r1m.lisp` (+0.25 on merged at ranged close), `hh-r1p.lisp` (the +0.05 learnable prior refit), `*.entry` (their unit-format library entries). `live9-r1-600.jsonl`, `live9-r2-600.jsonl` (the 3x3 after each round) |
| `joint/` | round 5 step 3, KI and IK optimised together: `iterate.sh` (one iteration: both sides logged from their current iterates against pools of the other side's past iterates + its frozen style CPU, then both refit), `run.sh` (the two iterations), `select.sh` / `select.json` (the candidate per side: the better iterate on 801-1000 against its last pool's members), `heldout.sh` / `heldout.json` (the 2x2 from each side's seat, the stand-ins and the fixed rule's verdict), `proofs.sh` / `proofs-600.jsonl` (HH :qhs4-mirror, KI :qks3-ichigo, IK :q1-ichigo-ken run raw = the live lookup), `live9-600.jsonl` (the 3x3 after step 3). `ki-t1/t2`, `ik-t1/t2` (+ `.json`): the iterates; `ki-t2` = **shipped** :qks3-ichigo (`qks3-ichigo.entry`) |
| `joint/run4.sh`, `joint/step4a.sh` | round 5 step 4, part A: KI and IK two more iterations from the live lookup (pools of every past iterate + the stand-in), the candidate per side (`select.sh` with `TS="3 4"` -> `select4.json`) and the held-out verdict against the live lookup (`heldout.sh` with `KIO=joint/ki-t2.lisp PFX=j4h` -> `heldout4.json`); `ki-t3/t4`, `ik-t3/t4` (+ `.json`): the iterates, none shipped. `select.sh` / `heldout.sh` take their step-4 settings from the environment (the defaults are step 3's) |
| `khjoint/` | round 5 step 4, part B: Kenpachi vs Hisagi, both sides at once. `cands.py` (each side's 11 candidate arms from the §10 units, played whole: `k/`, `h/`), `matrix.py` / `matrix.json` (the joint game: every Kenpachi strategy against every Hisagi strategy and Hisagi's against the stand-in, seeds 1-100, `m/` one JSON a cell), `extend.py` (a live table with arms appended 1 below every row: plays the old one bit for bit), `start.sh` (`kh.arms`, `hk.arms`: the live arms + the kept arm; `kh-t0`, `hk-t0` and `identity-t0-600.jsonl`: = the live lookup), `iterate.sh` / `run.sh` (two simultaneous iterations, `select.json`, `heldout.json` under step 3's rule), `proofs.sh` (`proofs-600.jsonl`: :qks2-hisagi run raw = the live lookup; `live9-600.jsonl`: the 3x3 after step 4). `kh-t1/t2`, `hk-t1/t2` (+ `.json`): the iterates; `kh-t2` = **shipped** :qks2-hisagi (`qks2-hisagi.entry`) |
| `khstyle/` | round 5 step 5: the KH / HK fit after the dream-rsi search (`../khfn/`). `start.sh` (`kh.arms`: KH's arms + `:a-ken-kh`; `kh-t0` = `:qks2-hisagi` extended, `hk-t0` = `:qhs-ken`; `identity-t0-600.jsonl`), `run.sh` (two simultaneous iterations through `khjoint/iterate.sh` with `OUT=khstyle TAGP=s`, `select.json`, `heldout.json`), `proofs.sh` (`proofs-600.jsonl`: :qks3-hisagi run raw = the live lookup; `live9-600.jsonl`: the 3x3). `kh-t1/t2`, `hk-t1/t2`: the iterates; `kh-t2` = **shipped** :qks3-hisagi (`qks3-hisagi.entry`) |
| `library/entry.py`, `library/add.py` | a research table (inline arms) as a unit-format library entry; appending it to the library with its lookup row |
| `ev/sjs-*`, `ev/sjh-*`, `ev/j5f-frozen-*` | step 5's measures: KH / HK selection and held-out, the live tables against the stand-ins |
| `ev/j4s-*`, `ev/j4h-*`, `ev/kjs-*`, `ev/kjh-*` | step 4's measures: KI / IK selection and held-out; KH / HK selection and held-out |
| `ev/js-*`, `ev/jh-*`, `ev/jf-frozen-*` | step 3's measures: the iterates' selection, the held-out 2x2 and stand-ins, the live tables against the stand-ins |
| `ev/cf-sel-*`, `ev/cf2-sel-*`, `ev/cf-frozen-*`, `ev/<p>-r5-ho*` | the co-refit's measures: selection (round 1, round 2), the frozen stand-ins, held-out (the pick's tag carries its file name; round 2's current table `-cur-vs-<opponent>`) |
| `ev/ik-*`, `ev/ih-*`, `ev/ii-*` | round 5's measures (`*-sel2-*` selection 801-1000, `*-r5-ho601-*` / `*-r5-ho701-*` held-out: `pick`, `cur` = the shipped table, `o1` = the best whole arm) |
| `ev/ki-*`, `ev/kh-*`, `ev/kk-*`, `ev/hi4-*` | round 4's measures (`*-sel2-*` selection 801-1000, `*-ho601-*` / `*-ho701-*` held-out) |
| `ev/hi3-*`, `ev/hh3-*` | round 3's measures (`*-sel2*` selection, `*-ho601-*` / `*-ho701-*` held-out; `hi3-ho*-b08-posthoc`: measured after the decision) |

Logs (gitignored, `switch/logs/`): `r1` (the start table, 4 salts), `r2a` / `r2b` (2 salts each), `r3` (4 salts), round 2's `hi2-r1`,
`hi2-r2`, `hk2-r1`, `hh2-r1`, `hh2-r2`, round 3's `hh3-r1`, round 4's `kki-r1`, `kki-r2`, `kkh-r1`, `kkh-r2`, `kkk-r1`, `kkk-r2`, round 5's `iik-r1`, `iik-r2`, `iih-r1`, `iii-r1` (4 salts each), the co-refit's `c<p>-r1` and `ckh-r2`, `cik-r2`, `chh-r2`, step 3's `jki-t0`, `jik-t0`, `jki-t1`, `jik-t1`, step 4's `jki-t2`, `jik-t2`, `jki-t3`, `jik-t3`, `jkh-t0`, `jhk-t0`, `jkh-t1`, `jhk-t1`, step 5's `skh-t0`, `shk-t0`, `skh-t1`, `shk-t1` (2 salts each; each fit's stdout as `fit-*.out`;
`hi3/` the HI prior fits'), `ev/*`.

## §10: the library's format, `switch/library/`
DUEL_AI_STRATEGY §10 describes the format. `duel/lisp/strategy.lisp` now defines style, data and arm units and rule bases, and
`*strat-library*` is expanded from them at load.

| File | What |
|---|---|
| `units.lisp`, `expand.lisp` | the units and the expansion as first written: the inputs of the one-time rewrite (now in strategy.lisp, edited there) |
| `refactor.py`, `sexp.py` | the one-time rewrite of the inline library into units: each arm mapped to the unit that plays the same, each Q table to `:arms` ids + `:rule-base` + `:q`, the listed plain strategies composed |
| `check.lisp` | the structural proof: the inline library (`OLD.lisp`, the commit before's strategy.lisp) and the unit library expanded are the same entry by entry, checksums included |
| `proofs.sh`, `proofs-600.jsonl` | the play proof: the nine live tables' research files run raw = the live lookup, 8 of 8 chunks each |

The research files written inline (the arms files, `hi/`, `hk/`, `hh/`, `kenpachi/`, `ichigo/`) still play raw; the runtime takes inline arms
as before.
