---
name: sim-balance-gates
description: Use when changing game rules, frame data, damage, reach, tuning knobs or CPU AI in a deterministic game sim, before calling the change done — or when match pacing, win rates, awaken/transformation balance, seed-gate medians or reference hash lines move, or a CPU behaviour needs measuring.
---

# Gating a deterministic game sim

## Overview
A balance change is done when **measured** gates pass, not when it compiles. The exemplar (SOUL DUEL, this repo) runs a
fixed-step sim with a split RNG, so a seed replays the same match bit for bit; every gate below relies on that. Since the core
system (2026-10-27) only Kenpachi, Ichigo and Hisagi play: six pairings, KK IK II HK HI HH = `--pairs 2,7,9,29,31,35`. A
new roster member appends his pairings with every earlier member and his mirror (the order in `tools/simgate.py --help` and
gate.lisp `ROSTER-PAIRS`): count his indices from there, and his core pairings are the ones with K, I, H and himself. Details, numbers and evidence:
`reference.md`; the project's current policy text: `docs/duel/DUEL_GAMEPLAY.md` "Gate policy".

## Since 2026-10-29: no balance gates unless the user asks
- The user: 「以後不用跑平衡測試」 (DEVLOG §468). The seed / pacing gate, the edge rerun, the awaken A/B, `aieval`, `assistgate` and
  `roguegate` below run **only on request**. Every change still runs the host tests, `pkgcheck`, the build, a smoke and `--cvc`.
- The user: 「以後要測什麼招式就直接寫好指定的控制腳本，如非必要就不再依賴 CPU 賭機率」. Test a move with a **scripted scene**: both sides'
  inputs are keys in `tests/scripts/duel.py` (e.g. `duel-hisagi-bankai.json`, run with `tools/run.mjs --script`), or a debug setup.
  Each scene puts the distance and pointer in place, presses, and reads the combat log (`[tick] P1 … HIT n`, the kit's own log lines).
  Add a distance / state probe every 2–3 f when a link or a reach is in question.
- **The presentation-only proof** is that scripted smoke: its `grep -E "^\[ *[0-9]+\]|^duel hash"` lines must be identical to a
  baseline saved before the change, and `--cvc` must pass. A baseline is void once anyone changes the sim, a parallel session
  included (a shared gauge rescale moved every hash line). Regenerate it from current `main` before you compare.

## Implement so it can be audited
- One knob in `tuning.lisp` (`defparameter` + docstring: old → new value, date, who decided, doc §). Never bury a
  number in code; never retune other knobs to compensate for a deliberate change of the user's.
- A chance of 0 must not roll; instrumentation counts, never rolls; side systems get their own RNG.
- Encode geometry/frame relations as host-test invariants (e.g. grab reach < every light-attack reach; art reach
  within ±0.15 m of the hit volume).

## The gate stack — run every layer the change touches
(`E` = the 32-bit host ECL, in the exemplar `/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl`.)
| Layer | Exemplar command | Pass |
|---|---|---|
| Host tests | `$E --norc --load tests/<t>.lisp`: duel-rules, duel-control, input, touch (+ cine, learn if touched) | ALL PASS |
| Seed / pacing gate | `python3 tools/simgate.py [--pairs ..] --summary` (native, same sources) | every match K.O.; cross-pairing medians in 125–210 s; mirrors may exceed 210 |
| Quick first pass (optional) | `--seeds 10` | passes at once only if all K.O. and the median is inside 135–200 s; else run 20 |
| Edge rerun | `--pairs k --seeds 60` | a 20-seed median outside the window is rerun at 60 seeds; that is the verdict |
| Awaken A/B | `--pairs k --seed0 {100,300,500} --seeds 60 --cmd 39020` | when awakening rules change: the "never awaken" side wins ≥ 20/60 on **every** stream |
| G2 reference | `simgate.py --cvc` (native) or `tests/style-gates.py cvc dist/duel`; pairs II IK KK | identical lines; on an intended change rewrite `tests/style-cvc-ref.txt` with a header note "after X (the user, date). Before: …" and update every place the reference line is quoted |
| Shipping build | `./build.sh duel` last | `dist/*/index.wasm` newer than every edited source |

Match time excludes every cinematic since 2026-10-08 (`MATCH-PLAY-TICKS`, the frames the match timer ran; simgate sorts
by it and also prints the median with the cinematics). The 125–210 s window was measured with them; medians now read
30–60 s lower (DEVLOG §134). A presentation-only change must leave the scripted smoke's log and `--cvc` byte-identical
to a baseline saved before it (before 2026-10-29: `--seeds 10 --summary`).

Scope: a change inside one character's files, or a shared hook only he uses → his pairings (Ichigo `7,9,31`; the user,
2026-10-27, DEVLOG §424); shared rules (combat, fighter, core-sim, core-ai, rules, tuning, kit) → all six. A touch-only change
(the recogniser, the phone's mapping) moves no sim gate: the native sim has no touch; check it with `touch-test` and `run.mjs --mobile`.
ASSIST (`assistgate.py`), the learner and AI v2's `aieval.py` are frozen with the old system. Take a baseline on the parent commit (`git worktree add` → run the same gate) whenever
you need to attribute a shift.

## When a gate fails
1. Measure where the time/wins go (counters, logged runs: one log file per process).
2. Pull the design's named lever; record what was tried and dropped, with numbers.
3. Still failing → **stop and report to the user** with before/after numbers and 2–3 options. Do not quietly retune
   unrelated knobs. If the user accepts, quote their words and date in the gate policy, the design §, the DEVLOG
   and the commit.

## Noise (read numbers with it)
20 seeds ≈ ±2 wins, ±5 after any extra RNG roll reshuffles the stream; 60 seeds ≈ ±4. A/B on one stream overfits →
three disjoint streams. Choose a setting by "every constraint satisfied", not by the single best number.

## CPU AI rules that keep recurring
- A rule that reads input timing (a hold, a confirm window) changes the CPU's outcomes through its press lengths: check the CPU
  before blaming the rule (a 12-frame Kikon confirm moved IK 191.9 → 201.1 s until the CPU held through it; then identical).
- A reaction slower than the threat never fires → decide from what the CPU feels at once (its own state), read the
  opponent through the perception delay.
- Roll once per event, never per step (a per-step chance is a certainty).
- Use the real distance for the CPU's own movement, the perceived one for the opponent's intent.
- A held button can suppress the reflex path; add explicit exceptions.
- Every new mechanic gets a CPU rule (EASY ≤ NORMAL ≤ HARD chances) and a measurement (counts of uses and outcomes).
- Freeze the rules before a dream-rsi CPU search; each rule change mid-search forced a re-freeze and a 3-way merge of every cell.
- Feel numbers (dash distances, slow-motion scales) churn in playtests: settle the unit and trigger first, then tune by play, not by gate cycles.

## Report template (design §, DEVLOG, commit)
"Gate (native, 20 seeds): all N K.O.; cross medians a–b (list); mirrors (list); [60-seed rerun]; A/B rows (all ≥ 20);
host tests pass; G2: ii … ik … kk … identical (native == browser)". A change claimed inert shows bit-identical rows.
