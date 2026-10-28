# B. Deterministic simulation, balance gates, CPU AI — lessons from SOUL DUEL

Source repo: this repo (/media/8tsp/projects/ai-cl-game-next) (CL → ECL → wasm; `duel/` = SOUL DUEL, 3D fighter, 5 characters,
15 CPU pairings). Paths below are repo-relative. "G" = generalizable, "S" = SOUL DUEL-specific.

---------------------------------------------------------------------------------------------------------------------
## 1. Determinism: why a seed replays the same match

### How (evidence)
- **Fixed step.** `engine/lisp/time.lisp` `run-fixed-steps`: accumulator of real dt, one `+step+` (1/60 s) per call, at
  most 6 per frame, backlog dropped (never snowballs). Turbo (debug 2102) runs up to 120 steps per frame with no scene
  drawn — same steps, faster. Slow motion = **step skipping** (`*slow-acc*` += scale, a sim step only when it reaches 1);
  hitstop = steps that read devices only (DUEL_GAMEPLAY.md "Time model").
- **Two RNG streams.** `engine/c/rng.c`: `rng_state` → `RND01` (cosmetics: particles, shake, camera) and `rng2_state` →
  `SIM-RND01` (everything the sim / AI decides). Seeding through murmur3 `fmix32` so seeds 1,2,3 start far apart;
  `sim-rnd-seed` in `engine/lisp/package.lisp`. `start-cvc` (gate.lisp) seeds the sim stream per match.
- **No wall clock in the sim.** Devices are read *inside* the step (`pilot-system`), the human stick is converted through
  a **sim-owned view**, not the lagging render camera; CPU pilots never read the view, so the camera option cannot change
  a CPU match. Cinematics run on the step clock. (DUEL_GAMEPLAY.md "Determinism".)
- **Single floats everywhere** (`math.lisp`: `(simple-array single-float)`, `f32`). Native sim built with
  `gcc -m32 -msse2 -mfpmath=sse -ffp-contract=off` so every f32 op rounds like wasm f32 (x87 80-bit / FMA would not)
  (`tools/simgate/build.lisp`, DEVLOG §38).
- **Matches start from nothing.** `spawn-pair` makes new entities; `start-match` reseeds, zeroes `*match-tick*`, timer,
  slow-mo clock (`reset-slow-clock`), `time-reset` clears hitstop.
- **Determinism hash.** `state-hash-line` (gate.lisp) every 600 ticks: positions in cm, yaw in 0.01 rad, every
  gauge, cooldowns, hazard count → `duel hash t=...`. Plus `duel -> RESULTS winner .. konpaku a-b ticks N secs S`.
  Comparing these lines between two runs is the whole determinism test.

### What broke it (each was a real bug found by the gates)
- **Leaked state across matches:** `*slow-acc*` kept a fraction (0.13, 0.5...) from a perfect Hoho's slow-mo into the
  next match → KK alone median 135.8 s, after YY+YK 140.8 s (DUEL_GAMEPLAY "Determinism"). Senjumaru's per-side `*sj*`
  state was documented "reset per match" but never reset → SR/SS rows depended on prior matches; found only when the
  native runner split seeds across processes (`--chunk`) (DEVLOG §38–§39, fixed: fresh state per fighter).
- **libm last-bit differences:** native glibc `sinf/expf` vs emscripten musl → 3/15 pairings drifted a few cm by t=7200,
  one row changed. Fix: compile the *same musl sources* from emsdk into `build/simgate/muslm.so` and `LD_PRELOAD` it
  (`tools/simgate.py` `build()`). After: 150/150 rows, 2693/2693 lines identical browser vs native.
- **Extra dice rolls reshuffle everything downstream** (not a bug, a property): one more `sim-rnd01` call anywhere changes
  every later decision, so a feature's A/B difference partly tracks *the stream*, not the feature (DEVLOG §25: K→L at
  p 0.01 still moved RY/RK by +32/+31 over 180 seeds, vs +13/+13 with no roll). Mitigations used:
  - a chance of 0 must **not roll** (Rukia's `:l-after-k` at 0 keeps YY/YK/KK bit-identical, DEVLOG §25);
  - side systems get **their own RNG** seeded *from* the sim stream state without drawing (learner `learn-rnd`,
    DUEL_LEARNING §7) → full gate row-identical with the learner present-but-off (691/691 lines);
  - instrumentation is **counters only, no rolls** (Ichigo `duel ichigo` counters: 100/100 matches identical, DEVLOG §40);
  - rolls are **one per event**, keyed on the opponent's action start (`ai-event-rolls`, ai.lisp:169), never per step.
- **Real-time input on a loaded host** drops presses in browser scripts → run scripts with `--fixed-dt 16.666667`
  (DUEL_GAMEPLAY test-script table, duel-practice.json).
- Process structure matters when state leaks: one process plays a pairing's seeds back to back "as the page does";
  `--chunk` equality with that mode is itself a leak detector (simgate.py docstring).

### G — rules for any sim game on this engine
- Sim randomness only from `sim-rnd01` inside fixed steps; cosmetics only from `rnd01`. Never let render time, camera,
  frame rate, or device polling outside the step reach sim state.
- Reset *all* per-match state in one place; any global that survives `start-match` is a future leak. Test: a seed run
  alone == the same seed run after N other matches (2110/2111/2112 vs 2113 check).
- Emit a periodic quantized state hash + a result line from day one; diff them, don't eyeball.
- If you need a second runtime (native/host), compile the **same sources** (no fork, no `#+` guards in game files) and
  match float mode + libm; validate line-for-line against the reference runtime before trusting it.

---------------------------------------------------------------------------------------------------------------------
## 2. The gate stack

| Layer | Tool | Runtime | Speed | When |
|---|---|---|---|---|
| Host rules tests | `tests/duel-rules-test.lisp` (4431+ checks), `duel-control-test` (86), `learn-test` (100), `input-test` (33), `cine-test` (18) | host ECL, plain CL, no build | seconds | every change |
| G2 bit-exact refs | `tests/style-gates.py cvc dist/duel` vs `tests/style-cvc-ref.txt`; native self-check `tools/simgate.py --cvc` | browser wasm (+native) | ~1 min | every change; refreshed on any intended sim change |
| Seed / pacing gate | `tools/simgate.py` (the six core pairings 2,7,9,29,31,35 × seeds) | native, 1 core/process | 300 matches in ~14 s at -j16 | rule/AI/tuning changes |
| Awaken A/B | `simgate.py --pairs k --seed0 100 --seeds 60 --cmd 39020` | native | ~tens of s per stream | changes touching a character with an awakening |
| Touch recogniser | `tests/touch-test.lisp` (host) + `run.mjs --mobile --size 390x844` scripts | host / browser | seconds | phone input changes (the native sim has no touch) |
| Smoke / perf / stills | `style-gates.py smoke/perf/duelstill`, touch scripts | browser | minutes | render/build changes |

### Host rules tests — what they assert (S, but the *kinds* are G)
- Load pure files (`tuning rules kit <chars> endless-rules`) over the engine's plain-CL `math hitvol input`, stub
  cinematics (`defcine` → nil). `check` macro counts checks/fails; prints `ALL PASS`. (the runner `tests/duel-rules-test.lisp`'s prelude, lines 1–15; the checks are in `tests/duel-rules/*.lisp`)
- **Frame-math replay:** `free-steps` re-implements how fighters step and asserts every move's measured block
  advantage == its table value, for every move of every form (l.135–152). Headless twin in-game: frame probes
  2315+k → `duel probe ... advantage A (table T)`.
- **Combinatorial walks:** every string route of every form (`link-moves`, `route`): exactly the six routes JJJ..KJJ,
  link 3 is an ender, block gaps, "J beats K" frame budget, J ≤ own J1 gap.
- **Art-vs-hitbox reach check** (l.1630–1700): reads each `*-art.lisp`, poses the rig with real FK at the move's hit
  frames, measures weapon tip / striker joint vs the hit volume's far edge: J within ±0.15 m; K / Breaker may fall
  short but never over by > 0.15 m; documented exceptions (`*reach-one-sided*`, 片腕 ≤ 0.6). A deliberate over-reach
  fails it (DUEL_STRINGS §13 "The check").
- **Geometric relations as invariants:** `*lunge-stop*` > 2 × widest hurt radius; Breaker reach < every J1 reach and
  reach + thinnest hurt radius > trigger (防 > J > I > 防 loop, §14, re-asserted in §20 after J ≥ 1.4 m); K ≥ J + 0.5 m
  per link; "J beats I" window per form from closed-form frame math (`d ≤ R + 0.34 + v(S+A−1)`).
- Kit sanity (every form's commands/costs/derived numbers), AI helper functions, storage round-trips (learn-test).
- Shared files must contain no character names (a "name-leak grep" run with every batch; DEVLOG §29, §37).

### G2 reference regression
- Three seeded CvC matches (seed 7: YY / YK / KK via debug 3007/4007/5007 in turbo) → all `duel hash` lines + RESULTS
  stored in `tests/style-cvc-ref.txt`, compared line for line.
- **Contract** (DUEL_GAMEPLAY "Determinism"): any change to rules / AI / kit / tuning *changes* it; a refactor or engine
  move *must keep it* identical. So G2 doubles as "did my refactor change behaviour?".
- **Regeneration is documented, never silent:** the `#` header of style-cvc-ref.txt is a chain of
  "after <change> (the user, date): which of yy/yk/kk changed, new RESULTS line. Before: ..." going back ~30 changes;
  DUEL_GAMEPLAY "Reference" keeps the same history for YK; each DUEL_STRINGS § ends with "G2: yy ... yk ... kk ...".
  Partial-change notes are informative too ("yk changed, yy/kk unchanged": proves the change only touched what it should).
- Run both: browser G2 (`style-gates.py cvc`) and native `simgate.py --cvc` (proves the native runner is still exact).

### Native sim gate (`tools/simgate.py`, built 2026-09-29, DEVLOG §38)
- Same Lisp as `./build.sh duel`; C layer replaced by `tools/simgate/stubs.c` (real rng.c; headless leaves; virtual
  time `sg_frame * 50/3 ms`; debug-command queue). `run.lisp` runs the real `%FRAME` until the gate is done; a hung sim
  exits 4 after 2e6 frames (bounded). `run-log.lisp` = same with combat log on (aieval reads hits).
- Rebuilds `build/simgate/duel.fas` (~2 min) only when a source in the MANIFESTs is newer.
- Output = the page's console lines; Python merges rows and prints the browser's summary format plus
  `wins P1 n P2 m DRAW d blow b`.
- **It does not update `dist/duel`** — after any Lisp fix, `./build.sh duel` before handing to the user/browser harness
  (memory feedback-rebuild-dist: a native-only rebuild shipped "VPAD-INDEX is undefined" to the user's phone).

### Pacing gate criteria (DUEL_GAMEPLAY "Pacing gate", memory feedback-gate-policy)
- NORMAL CvC, turbo, cinematics included. Every match ends by **K.O.** before the 300 s timer.
- **Median 125–210 s per pairing** (was 125–180 until Reishi 1100 → 1300, user 2026-09-26: humans play faster than CvC).
- **Mirrors (YY KK RR II SS) exempt from the 210 ceiling** (user 2026-10-02: 「內戰的數據超時沒關係」); cross pairings must hold.
- Win rates "near even" (YK within ±3 of 10/10 at first; later read as a trend, not a gate).
- **Two stages:** 10 seeds (`31100+10`); pass at once if all K.O. and median in 135–200 s (10 s inside the window); else
  rerun 20 seeds = verdict. In practice a 20-seed median just outside → **rerun at 60 seeds** (e.g. §19 YK 124.4 at 20 →
  131.3 at 60; §20 YK 120.9 → 119.5 at 60, then user acceptance). aieval uses 220 s at 20 seeds because 20-seed medians
  are ~±10 s noisy; the real 210 check runs at 60.
- **Scope (the core system, 2026-10-27):** a change confined to one character's files, or a shared hook only he uses → his
  pairings (Ichigo 7, 9, 31; DEVLOG §424); shared rules (combat, fighter, core-sim, core-ai, rules, tuning, kit) → all six
  (2, 7, 9, 29, 31, 35). Before the core system: 5 pairings / all 15.

### Awaken A/B (DEVLOG §27, DUEL_STRINGS §13)
- P1 "never awaken" (debug 39020) vs opponent on its rule; **three disjoint 60-seed streams** (seed0 100/300/500 →
  seeds 101–160, 301–360, 501–560). Pass: "never" wins **≥ 20/60 on every stream** (user 2026-09-28: awakening may be
  stronger, just not mandatory). Older criterion |Δ| ≤ 9 dropped because a 60-seed count has ~±4 noise and knobs had
  been overfitted to one stream.
- Same pattern for Kenpachi's Bankai "gamble A/B" (31000+10a+b: rule / always / never / p=1).

### Masher & assist gate, learning gate, AI score (frozen)
ASSIST, the learner and AI v2's per-character search are frozen with the old system (DUEL_CORE §5); their tools stay. Their
sections: `git show e55304e:skills/sim-balance-gates/reference.md`.

### Rule-change gating template (DUEL_CORE's gate lines all end the same way)
"Gates (six pairings / his three; G2's three CPU matches unchanged, native == browser): KK a, HK b, HH c s (10 seeds),
IK d s (20 seeds, Ichigo w:l), …, all K.O.; [the mirror e s at 60 seeds, n time-outs: open / accepted]". Name what moved a
number before a fix (the CPU, a rule) and show the fix restores it. A change that is supposed to be inert states "bit-identical" with the
evidence (§18: cross pairings and G2 bit-identical, only mirrors moved).

---------------------------------------------------------------------------------------------------------------------
## 3. Tuning workflow

### tuning.lisp organisation (S; pattern is G)
- One file, ~330 `defparameter`s, sectioned by design-doc § (`§1 rules`, `§3 universal mechanics`, `§8 CPU AI`,
  `§14 budgets`); header states units (frames = 60 Hz steps, metres, m/s, fractions). Plain CL, loaded by host tests.
- Kits reference knobs by symbol (`:walk *walk-yamamoto*`); kit.lisp resolves `*EARMUFFED*` symbols at load, so
  per-character data still routes through the one knob file.
- **Docstrings carry history:** old → new value, date, who decided, why, and the doc §. Examples:
  - `*reishi-max*` "1100 -> 1300 (guard v3, the user's decision 2026-09-26: ... the seed gate's median window moved".
  - `*ai-o-ender*` "A pacing knob of the seed gate (DUEL_STRINGS §4, §6, §9: the design's 0.35 -> 0.15)".
  - guard refill "the user: 20 -> 12; then ... (大幅減少防禦量表的恢復速度): 12 -> 5.5".
  - `*red-threshold*` notes it's a weak lever ("0.10 .. 0.30 moved the gate medians by only ~10 s").
  - "Not a tuning knob: the spec's value." marks values that must not be used as levers.
- Difficulty tables are plists in the same file: `*ai-delay* '(:easy 24 :normal 14 :hard 8)`, `*ai-think*`,
  `*ai-j-beats-k-p*`, `*ai-burst-p*`, `*ai-wake-guard-p*`, `*ai-step-j-p*`... (tuning.lisp §8).

### Runtime knobs instead of rebuilds
- Integer-encoded debug commands set knobs before the gate: `24000+k … 29000+k` (string knobs = k/100), `2600+k`
  (`*red-threshold*`), `32000–38000` (Bankai), `39000+10a+b` (awaken mode per side), per-character ranges
  (`74000+`, `90000+` via `*char-debug*`). `simgate.py --cmd N` queues any of them. → a sweep is N gate runs, no build.
- Sweeps documented with numbers: DUEL_STRINGS §10 (K2/K3 at 100/90/80/70 % → medians 116/120/124/125 s, seed noise
  ±5 s; chosen set = "every median ≥ 129 s and YK within 8–12", not the argmax).

### Handling a failing gate (observed sequence)
1. **Measure where the time goes** before turning knobs: add counters / log lines (`duel cups`, `duel band`,
   `duel senju`, `duel ichigo`, `pace t=..` every 60 ticks via 2114+p). DEVLOG §31: counters showed the real cause was
   the CPU cashing out cup 3 itself, not the drain.
2. **Pull the design's named lever first** (DUEL_STRINGS §6 listed levers in advance; §9 table "Design | Built | Why").
3. **Rerun at more seeds** when the median is borderline (20 → 60).
4. **Try, record, and revert** what doesn't work ("試過但沒採用" lists in every DEVLOG §: e.g. cup-3 `:tempo` 0.7 fixed YK
   126.4 but broke KK 117.8 → kept old CPU).
5. **Escalate to the user** when no lever fixes it without breaking something else; user acceptance is recorded with
   quote + date: YK 121.1 s (「劍八那邊就這樣給過即可」), YK 119.5 s (「我接受這個節奏」, §20), Ichigo damage cut
   without a gate (「不用再做測試」 → rows marked stale; agent still ran it natively and reported II/SI > 210),
   Ichigo A/B failing (left to user, documented every gate since).
6. **When the target itself is wrong, say so**: assist gate's plan "masher wins ≥ 30 % with assist" was wrong because
   the masher already won 98 % — reported as a CPU weakness instead of tuning the assist (DUEL_ASSIST "What it says").

### Measure before claiming
- Every claim in docs carries the run: seeds, pairing list, debug command, medians, K.O. count, the G2 line.
- Read win counts with their noise: 20 seeds ≈ ±2 wins (±5 between near-identical builds after an RNG reshuffle,
  DEVLOG §40), 60 seeds ≈ ±4; prefer 60 for win-rate claims, 80 seeds to pick between close AI candidates
  (DUEL_AI_V2: 0.749 vs 0.747 at 80 seeds).
- One process per job, one log file per process (`style-gates.py` writes `build/style/cvc-<p>.log`; simgate captures
  each subprocess's stdout); parse rows by regex, never by tailing a shared log.
- Bounded waits only (no `pgrep -f`/`pkill -f`, no open-ended `until grep`) — memory feedback-no-self-matching-pgrep
  (orphaned loops ran 7 h and 16 h).
- Mechanism checks are counted, not assumed: "123 of 125 landed Breakers followed 11 f after the hit, 119 hit" (§17);
  "78 of 81 Step → J1 started at f12" (§18) — via throwaway scripted players, not kept.

---------------------------------------------------------------------------------------------------------------------
## 4. CPU AI design

### The core CPU (duel/lisp/core-ai.lisp, 2026-10-27)
- The CPU writes its fighter's **vpad exactly like a keyboard**, once per step; the same input pipeline as humans (buffers,
  latches, Mod in the same step). Generic: it plays any kit with a `:core` from the class table and the pointer.
- `core-brain-step`: perceive → hold the press in progress (`brain-press-left`) → decide by state (`cai-neutral`, `cai-move-step`,
  the stun's Kikon cancel). Three rolls per own move start (`cai-own-rolls`: turn, continue, Kikon), kept until the next start.
- A hold is a press length: the Kikon is SP held 40 frames; a held press is kept through the Kikon confirm (§440). A rule that
  changes how long a press must be down changes the CPU's outcomes: check this first when a timing rule moves the gates.
- Kit hints only for what the table can't see: `:core :ns-range` (a ranged band) with `*cai-ranged-gap*` after each shot.
- The old `ai.lisp` (intents, distance bands, heat, kit reflex hooks) still drives the four frozen characters.

### Difficulty = perception + probabilities
- **Perception delay** is the main difficulty axis: snap ring buffer, `*ai-delay*` EASY 24 / NORMAL 14 / HARD 8 f.
  The CPU feels its *own* state at once (own hit, own blockstun) — so block punishes use exact frames, reads of the
  opponent go through the delay (`brain-perceive`, l.649).
- Every chance is a per-difficulty plist with EASY ≤ NORMAL ≤ HARD (enforced as a rule in the AI-v2 brief).
- Tempo (`*ai-think*` 56/40/20) and turtling (`*ai-hold-guard*` 0.97/0.92/0.8: easier CPUs turtle and get crushed).

### Pitfalls found (G — each will recur in any action game AI)
- **Reflex slower than the threat → the rule never fires.** J-beats-K "as written could never fire: NORMAL's 14 f
  delay is longer than any K link's remaining startup, and a CPU holding guard through a string runs no reflex"
  (DUEL_STRINGS §9 #5). Fix: decide from what the CPU *feels at once* (its blockstun ending) instead of the delayed snap.
  Same in §74: J1 startup (7–9 f) < HARD delay → CPU did nothing in 852/1019 cases after a J3; fix = pre-emptive guard
  on its first free frame (`ai-wake-step`).
- **Held-button suppression.** A guard held through a string, or the Breaker's I hold, blocked the reflex path
  (`brain-step` "continue current press" branch). Explicit exceptions added: a landed Breaker no longer hides reflexes
  (§17); `:hold` acts vs guard/dash.
- **Perceived vs real distance.** Step→J used the perceived (delayed) distance: 46/132 J1s made no contact; with the
  CPU's *own* hop distance (real) and excluding a Hohoing target → 99/272 incl. interrupts (§19). Rule: geometry of
  your own movement = real; opponent's intent = perceived.
- **Per-step vs per-event probabilities.** A chance rolled every step is ~certain: SP cancel "used to press every step,
  so it was certain" → one roll on the hit's first step (§9 #4); Kenpachi's NORMAL per-step neutral rolls took his
  NORMAL win share 0.397 → 0.806 (DUEL_AI_V2). Use `ai-event-rolls` (one roll per opponent action).
- **Reach-blind picks are lost decisions.** Picking J out of reach wasted the decision; bands split at J reach +
  0.3–0.5 m and `ai-attack` refuses out-of-reach J/K (§13 "The CPU tables").
- **Exploit loops get used by the CPU first.** The guard-cancel J loop (§73) was also exploited by CvC; fixing it
  moved every median and G2. Gates catch degenerate loops as pacing shifts.
- **Takeover hooks starve shared layers.** Kit reflexes that reset `brain-decide-t` or return `:wait` stopped the
  learner's neutral read (reads 606 → 348); fix = learner on its own clock before kit reflexes (`learn-read-due`)
  (DUEL_AI_V2 "The learning CPU and the new AIs").
- **The model can't see the state the opponent decides on.** Learner vs CPU: bursts depend on Reishi, which the n-gram
  situation lacks → no bait ever planned (DUEL_ASSIST "Learning his habits"). Learners read humans' habits, not CPUs.
- **A counter the opponent can see is not a counter.** Predicted-guard → Breaker read lost (404 Breakers, J'd/Hoho'd
  on sight) → removed from the assist read (DUEL_ASSIST).

### Learning CPU, per-character AI search, assist (frozen)
Frozen with the old system; their lessons (bandit, scripted habits, the frozen evaluator, AUTO COMBO's tempo loss):
`git show e55304e:skills/sim-balance-gates/reference.md` §4. The search method itself lives on in `duel-character-cpu`
and `docs/guides/DREAM_RSI.zh-TW.md`.

## 5. Generalizable lessons (playbook candidates)

### Build order
1. Fixed-step sim + split RNG (sim vs cosmetic) + per-match reset + state-hash line + result line. Before content.
2. Integer debug-command channel (encode args in the int) + combat log with the AI's `why` tag. Every scenario, knob
   and gate is a command; scripts and the native runner just queue commands.
3. Pure rules in plain-CL files loadable on the host; host test harness with a `check` macro; frame-math replay and
   table-equality asserts from the first move.
4. Seeded CvC + a G2-style bit-exact reference (2–3 matches, hash every N ticks) with a documented-regeneration header.
5. A seed gate (pairings × seeds, median / K.O. / win counts) with a numeric pacing window agreed with the user.
6. A headless native runner compiled from the same sources (float mode + libm matched), validated line-for-line;
   one core per process, parallel over pairings. Do this *early* — the browser gate took ~1 h for 15 × 20; native 14 s.
7. Scripted "player models" (masher, habits) as gates for AI and accessibility features.

### Keeping balance work honest
- The gate criteria, scope rules and noise levels are written in the gameplay doc and memory, and quoted in every
  implementation brief ("only affected pairings, 10-seed first pass, rerun at 20/60").
- Knobs live in one file with history docstrings; runtime knob commands make sweeps cheap; record the whole sweep,
  choose by "all constraints satisfied", not by a single best number.
- Noise first: know ±wins at 20/60 seeds; use multiple disjoint seed streams for any A/B; never tune a knob on the same
  stream you validate it on.
- Mechanical invariants (reach vs art, RPS reach ordering, frame budgets) are host tests, so balance changes can't
  silently break feel; geometry changes re-assert the relations (§14 → §20).
- Every rule change ends with the same gate block (medians, mirrors, A/B, masher, host-test counts, new G2 lines) in
  the design doc §, the DEVLOG entry, and the G2 header. A change claimed inert must show bit-identical rows.
- The user owns pacing/balance targets: under-floor results, skipped gates and failing A/Bs are reported with numbers
  and their acceptance quoted with date; stale tables are marked stale.
- Instrumentation draws no random numbers; zero-probability features don't roll; side systems use their own RNG.
- Always rebuild the shipped target (`./build.sh duel`) after fixes validated on the native runner.

### S — SOUL DUEL specifics worth knowing (not to copy blindly)
- Pairing index k = gate.lisp `*pairs*` order (0 YY 1 YK 2 KK 3 RY 4 RK 5 RR 6 IY 7 IK 8 IR 9 II 10 SY 11 SK 12 SR
  13 SS 14 SI, then each later roster member with every earlier one and its mirror: Hisagi 28–35, HK 29 HI 31 HH 35); the
  core six: 2 7 9 29 31 35. Gate commands 2125+k, seeds 30000+k0 / 31100+n; RESULTS `ticks/60 = secs`.
- 300 s timer, 9 Konpaku, Reishi 1300; median window 125–210 s; awaken floor 20/60 per stream.
- Accepted exceptions (with the user's words) live in AGENTS.md "Tests and gates"; the core era's: the Ichigo mirror 221.4 s
  with 2 time-outs of 60 (2026-10-28, DEVLOG §445). Ichigo's damage and win rates stay the user's call.
- Babylon TS port frozen at 2026-10-05 (no parity kept) — Lisp is the only sim of record.
