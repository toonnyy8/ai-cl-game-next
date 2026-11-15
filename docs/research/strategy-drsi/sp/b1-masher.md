# B1: the masher, debug 81030+s, `STRAT_DIF_P<n>=masher`, `ladder.py` (PLAN4 §5, §7; 2026-11-15)

The user, 2026-11-15: 「請設計讓勝率能做到 hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」. Batch B1 builds the bottom
rung, a seeded random button-masher (亂按). It is a test opponent only: debug and the native sim, with no menu entry. It also builds the
ladder driver and runs the first dev ladder.

## What was built

**`duel/lisp/masher.lisp`** (new; in `duel/MANIFEST` right after `cpu-perceive.lisp`). It has one job:
- `masher-pick (u1 u2 u3 ready)` is pure and returns `(button frames gap stick)`, or NIL unless READY.
  - U1 picks the button from `*masher-buttons*`: J 0.50, SP (Mod+J) 0.15, Step 0.10, Hoho (Mod+Space) 0.07, Burst (P) 0.04,
    awaken (Mod+P) 0.04, nothing 0.10.
  - U2 gives the hold (2-12 frames) and the idle gap (0-10 frames) together, uniform and independent: k = floor(U2 x 11 x 11).
  - U3 picks the stick from `*masher-sticks*`: toward 0.55, away 0.15, left 0.10, right 0.10, neutral 0.10.
  - The rates are the pre-registered ones (PLAN4 §5). They were not tuned.
- `masher-next (left draw)` is pure: one step of the event clock. It calls DRAW three times when an event starts and never otherwise.
- `masher-step (e b)` is the brain's step:
  - It calls `vpad-begin-step!`, then runs the clock on `sim-rnd01`, drawing only at an event's first step.
  - A new event's button goes through `ai-press` (the core CPU's press). Every step writes the vpad through `ai-press-write!`, so a
    masher press is a CPU press, Mod combos included.
  - The stick is written as `(vpad-stick! strafe toward)`, because a CPU's pilot is not camera-relative. Left is strafe -1, right +1.
  - A brain switched off (`brain-off`) presses nothing.
- **What a press event is.** A press is a down edge (a vpad stamps a press only when the button goes down). An event is therefore the
  hold (2-12 steps), one release step with every button up, then the idle gap (0-10 steps). The stick is held for all of it.
  - Without the release step, a 0-frame gap followed by the same button would merge into one press, and J then Mod+J would lose the
    SP's press stamp.
  - So the idle time is effectively 1-11 frames. This is the definition of a press, not tuning.
- **State** sits in brain slots, so a snapshot keeps it:
  - `masher` is the flag;
  - `m-left` is the event's steps left;
  - `m-stick` is the stick's name;
  - the held button is in the existing `press` / `press-mod` / `press-left` slots.
  - All of these are fixnums or keywords.
- **Selection**: `*masher-seats*` and `masher-apply!`, called by `start-match` right after the fighters spawn, and the debug range
  `(define-debug-range (81030 81033) ...)` next to them. Each match with a masher logs one `duel masher P<n>` line, and nothing is logged
  otherwise.

**Small edits elsewhere:**
- `components.lisp`: the three brain slots (defaults NIL / 0 / `:neutral`). The MCTS's stand-in brains (`mc-full-roll`) stay CPUs.
- `cpu-perceive.lisp`: `ai-press-write!`, the vpad write loop that used to sit inline at the end of `core-brain-step`. It is the same
  code, now shared.
- `core-ai.lisp`: `core-brain-step` now starts with `(when (brain-masher b) (return-from core-brain-step (masher-step e b)))`, ahead of
  perception, the strategy layer, the exchange, the MCTS and the style CPUs. Its tail calls `ai-press-write!`.
- `flow.lisp`: one line in `start-match`, `(masher-apply!)`.
- `ichigo.lisp` and `hisagi.lisp`: the masher gets no CPU help from inside a kit.
  - `parry-from-blockstun` (KESSA's CPU parry roll in blockstun) and `hs-tick-brain` (the windmill's CPU brain) also exclude a masher
    brain, so the masher plays those as a human would.
  - The other brain checks in kit files sit on the old K / L moves (Ichigo's TSUKI stance), which the core buttons cannot reach.
- `tools/simgate/strat-run.lisp`: `STRAT_DIF_P<n>=masher` sets the flag at the match's first battle step and prints `strat P<n> masher`.
  It branches before the difficulty `intern`, so neither the brain's difficulty nor its lookup strategy changes (the masher reads
  neither).
- `debug.lisp`: the header line lists 81030+s.

**Debug range 81030-81033** (claimed in DUEL_GAMEPLAY "Debug commands"; it was ASSIST's 81030+i before 2026-11-13). 81030+s:
- s 0 P1, 1 P2, 2 both, 3 none;
- it applies from the next `start-match` on, and at once to the live brains;
- a seat without a brain (a human's) stays human.

**`docs/research/strategy-drsi/sp/ladder.py`** (the PLAN4 P1 probe made permanent; it imports `tools/simlib.py`):
- It runs the 27 cells (9 ordered pairings incl. mirrors x HARD>NORMAL, NORMAL>EASY, EASY>masher), each on both seats, through
  strat-run's pairing gate with `STRAT_DIF_P<n>`.
- Jobs hold at most 50 seeds. `31100+n` takes n <= 99, and a larger n is a silent no-op that falls back to 20 seeds. Each job's row count
  is asserted.
- A match's result is the gate row's winner, which is the game's own (a K.O., or at the bell more Konpaku, then Reishi %). A draw counts
  half.
- Pass = one-sided 95 % Wilson lower bound >= 0.70. The script asserts that 296/400 and 151/200 are the least that pass.
- Each cell also reports its time-outs (`ko 0`), flagged above 25 %, and the share on each seat.
- `SP_BUILD` pins the build.
- Two extra rungs, `nm` (NORMAL>masher) and `hm` (HARD>masher), are for context only and are not ladder cells.
- It prints a table and writes JSON. The default path is `build/ladder/`; this record's runs are under `sp/ladder/`.
- One full 27-cell dev run (5400 matches) takes about 2 min wall at `-j 20`.

## Proofs

- **Host tests**: `duel-rules-test` 3503 checks, ALL PASS. The 19 new checks in `tests/duel-rules/masher.lisp` cover:
  - the tables: the pre-registered rates, each button's command (`*commands*`), and the stick vectors;
  - the pick's distribution over an even 10 000-point grid, every rate within 0.002;
  - every (hold, gap) pair equally often: 121 pairs x 50, hold 2-12, gap 0-10;
  - the ends of [0, 1);
  - no decision when not ready;
  - over 20 000 clock steps, exactly three draws per event, only on an event's first step, each event lasting hold + 1 + gap.
- **Other tests**: duel-control-test 124 ALL PASS, input-test 33 ALL PASS, touch-test 100 / 0 failures, cine-test 18 ALL PASS,
  `tests/debug-ranges-check.py` 87 ranges / 0 errors.
- **Build and smoke**: `tools/pkgcheck.sh duel` (only the pre-existing `DUEL::APP`), `./build.sh duel`, and the smoke (exit 0).
- **G2**: `tests/style-gates.py cvc dist/duel` and `tools/simgate.py --cvc` both PASS (II 39 / IK 32 / KK 29 lines, identical).
  Nothing changes unless a masher is selected.
- **snaptest** (masher-dev seeds 1-8, the masher on one seat, HARD opposite):
  - `81031 81022 30000 31104 2132` (IK, P2 masher): 768 rollouts;
  - `81030 81022 30004 31104 2132` (P1 masher): 1118 rollouts;
  - straight = pollute line for line, apart from the `stats:` lines' cons/frame (rollout consing) and the `duel mcfull` timings.
- **fulltest**, 0 differ every time:
  - NORMAL, so that the in-game full-sim jobs run (HARD made none here): `81031 2102 4007` 35 checks, `81030 2102 4011` 12,
    `81031 2102 5013` 34, `81030 2102 3015` 51;
  - `FT_LAYER=t 81031 81022 2102 5013`: 377 checks (368 strategy).
  - In each, the opposing CPU's rollouts step the masher's brain from its snapshot.
- **It really presses**: in the native `81031 81020 2102 4007` run (EASY Ichigo vs masher Kenpachi, seed 7, combat log on), P2 logged:
  - 244 moves (`KE-Z` / `KE-S` / `KE-KR`) and 214 SP lines;
  - 33 steps, 8 + 5 Hoho;
  - 3 + 3 Bursts, and the awakening (Bankai).
  - The browser run of the same scene (`tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 75` with a script sending 81031, 81020 and
    4007 at 8 s) logged `duel masher P2` and, in its first 67 s, 88 P2 moves and 74 P2 SPs. Its six `duel hash` lines (t = 600-3600)
    equal the native run's bit for bit, so wasm and the native sim agree with the masher playing.

## The first ladder (dev seeds 501-600, 200 matches a cell = 100 seeds x 2 seats; today's tables, the build of this branch)

`python3 docs/research/strategy-drsi/sp/ladder.py --seed0 500 --seeds 100 -j 20` writes `sp/ladder/b1-dev-501-600.json`.

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH |
|---|---|---|---|---|---|---|---|---|---|
| HARD > NORMAL | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
| NORMAL > EASY | 0.990 | 1.000 | 1.000 | 1.000 | 0.985 (bell 107 FLAG) | 0.920 (bell 73 FLAG) | 0.940 | 1.000 | 0.970 |
| EASY > masher | **0.000** | **0.015** | **0.540** | **0.000** | **0.000** (bell 51 FLAG) | **0.005** | **0.000** | **0.055** (bell 95 FLAG) | **0.060** |

- The cells are (higher tier's character, lower tier's character); each value is the higher tier's share.
- 18 of 27 pass: every HARD>NORMAL and NORMAL>EASY cell passes, and every EASY>masher cell fails.
- The Wilson lower bounds on the passing rows run from 0.883 (IH N>E) to 0.987. KH E>M is 108:92 (Wilson 0.482).

**Context** (seeds 1-50, the masher's dev block, 100 matches a cell; `sp/ladder/b1-context-nm-hm-1-50.json`):

| rung | KK | KI | KH | IK | II | IH | HK | HI | HH |
|---|---|---|---|---|---|---|---|---|---|
| NORMAL > masher | 0.06 | 0.69 | 0.99 | 0.23 | 0.59 | 0.27 | 0.45 | 0.89 | 0.65 |
| HARD > masher | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 |

**What this says.** The masher is not a free win:
- HARD beats it 900 of 900.
- It beats EASY in 8 of 9 pairings, mostly 200 to 0, and NORMAL in about half its cells. The order is not transitive: NORMAL beats EASY
  0.92-1.00, yet loses to the masher in KK, IK, IH and HK.
- In the logged EASY-vs-masher match, the masher drained the EASY CPU's Reishi into Soul Breaks (-3, -5, -1 Konpaku) and kept all 9 of
  its own Konpaku.
- A guess at the mechanism (not measured): constant J pressure toward him, about one press every 13 steps, outpaces a CPU that sees
  24 frames late (EASY) or 14 frames late (NORMAL) and thinks slowly.
- Per PLAN4 §5, the knobs for a failing rung, in order: `*strat-table-chance*` for EASY (0 today), `*ai-delay*` (EASY 24), then
  EASY's shared chances in core-ai.lisp / tuning.lisp. Whether any of them can close 0.00 -> 0.70 is CP1's question for the lead and
  the user: the gap is far larger than one knob step.
