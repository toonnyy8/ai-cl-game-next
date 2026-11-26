# M1 notes

Findings of the M1 sim-core tasks that later tasks rely on (the plan: `docs/bevy/plans/2026-11-26-m1-sim-core.md`).

## 1. Animation is a sink (Task 7, 2026-11-27)

The sim never reads the animation state, so `duel-sim` keeps none (no `Anim` component; `play-clip`, `anim-advance` and the
clip choices are looks, marked `// look:` in the port). Every read of `anim-time`, `anim-clip`, `anim-speed`, `clip-dur` (and
`model-anim`, `anim-blend`) in the frozen sources, grouped by file:

| Read | What it feeds |
|---|---|
| fighter.lisp 164 `PLAY-CLIP` (`anim-play` on `model-anim`) | the anim only (its return value is never used by a caller) |
| fighter.lisp 660 `MAIN-PHASE-STEP` `(setf anim-speed)` | the anim only (a pre-roll's clip speed back at the hit pose) |
| fighter.lisp 688-694 `RECOVERY-PACE` (`anim-clip`, `clip-dur`, `anim-time`, `anim-speed`) | writes `anim-speed` only; its docstring: "presentation only, the sim never reads it" |
| fighter.lisp 1141 `FIGHTER-STEP` `anim-advance` | the anim only |
| cinema.lisp 56 (the cinematic actors' `anim-advance`) | the anim only |
| main.lisp 91-97, 113-115 (SLOW-SNAPSHOT / SLOW-DRAW), 135 (the menus' idle clips) | the anim and the drawn transform between sim frames (restored before the next step) |
| ken.lisp 973, 1005, 1013 (GRIP-FRONT-CHECK, the grip rows of debug 2392) | `log-msg` lines of a debug command (not the sim, never in a trace) |
| hisagi.lisp 981 (HS-KAZA-K hold) | writes `anim-time` only (a look; Hisagi is M4) |
| hisagi-stills.lisp, hisagi-draw.lisp, yama-look.lisp, yama-art.lisp, debug.lisp 464 | stills / draw code (looks) |

Other model slots the sim writes but never reads: `model-alpha` (HOHO-STEP, REPEL!, REFRESH-LOOK), `model-rim` (ICHIGO's parry rim,
saved in `ics-rim`, a look: Task 4's ponytail note), `model-weapon` / `model-hide` (cinematics), `mv-clip-speed` (only into
`play-clip` / `anim-speed`). The one model read that feeds the sim is `body-hurt-r` / `body-hurt-h` of `model-body` (physics, the
fighters' separation, the hit tests, perfect Hoho): `model-body` is the kit's `:body` (SPAWN-FIGHTER, REFRESH-LOOK) or, in Kenpachi's
Bankai cinematic, the `:kenpachi` body (ken.lisp 564), and every body of a character has the same `hurt_r` / `hurt_h`
(bodies.json: kenpachi* 0.45 / 2.0, ichigo* 0.38 / 1.8, hisagi* 0.36 / 1.8, yamamoto* 0.36 / 1.65). So the port reads them from the
current kit's body (`fighter::hurt_r`) and the B line needs no anim field.

## 2. VIEW-STEP and RESET-SLOW-CLOCK (Task 7)

**VIEW-STEP** (fighter.lisp 229, called by FIGHTER-SYSTEM every step, and with RESET by BEGIN-BATTLE, flow.lisp 159, and the Kikon
reset, round.lisp 78: Task 10's `round::reset_round` follows the same rule) writes only
`*view-x*`, `*view-z*`, `*view-side*` and `*behind-yaw*`. Their readers: STICK-RELATIVE for a `cam-relative` pilot (a human seat;
CPU pilots keep `cam-relative` nil, M0_NOTES §4), camera.lisp (a look), sim-state.lisp's snapshot list (the CPU's rollouts, M2).
Neither `state-hash-line` (gate.lisp) nor the B line (trace.lisp `tr-b-line`: 29 globals, none of them) reads them. So in a
CPU-only match (every gate trace) VIEW-STEP is invisible to H and B; the port skips it and hits `unported!("view-step")` when a
`cam_relative` pilot exists (BEGIN-BATTLE, FIGHTER-SYSTEM and RESET-ROUND; M2 ports it with the human input).

**RESET-SLOW-CLOCK** (main.lisp 13) is `(setf *slow-acc* 0.0)` and nothing else (a single-float 0); START-MATCH's call is
`m.slow_acc = 0.0` in `flow::start_match`.

## 3. The replay's stubbed mode (Task 8; Task 9 dropped the gauge stub, Task 10 the hazard / hit stubs, Task 12 ICHIGO-TICK's)

Until Task 10 the official gate (`tools/port/replay-gate.sh --allow-unported`) stopped every cvc trace at `UNPORTED hazard-system` on
step 301. HAZARD-SYSTEM and HIT-SYSTEM are real since Task 10; since Task 12 every Kenpachi / Ichigo hook is ported and all 15 cvc /
cvc-tag gate traces replay whole matches `OK`. The **stubbed mode** runs past Hisagi's and Yamamoto's `:tick` hooks (M4) so the code
behind them is compared further on the other 36 cvc traces:

```sh
tools/port/replay-gate.sh --allow-unported --stubbed          # the 18 gate traces
NAMES="cvc-kh-s1 cvc-yi-s2" tools/port/replay-gate.sh --allow-unported --stubbed
rs/target/release/duel-tools replay TRACE --stub HS-TICK,YAMA-TICK --mask 'hss-,yss-'
```

Off by default: without `--stubbed` the gate and `duel-tools replay` are unchanged. It is not the gate's verdict.

**What it stubs** (`Match.stubs`, flow.rs `stub_tick`): two forms' `:tick` hooks (called by GAUGE-SYSTEM every step, gauges.rs), each
by its name. A stub does nothing only while the real hook provably writes nothing outside the masked fields and logs nothing; otherwise
it is `unported!` with its name, so the run reports the first UNPORTED it can't stub, never a silent divergence:
- `HS-TICK` (M4): always skipped. It writes his HSS (masked); each of its other writes (the K1 copy swapped into FIGHTER-MOVE, the
  SICKLE / KIN off / ZANDEN log lines) needs a state that only one of his own unported hooks sets first (`hss-kstr`: HS-KAZA-TICK /
  HS-KAZA-START; `:out`: HS-THROW-OUT; `hss-kin`: HS-CLASH; `zan-pend`: HS-HIT), and the run stops at that hook. So the skip is exact
  on every state the run can reach. It is not caught by B: the move swap puts in a same-named copy, and B prints a move by name only.
  Whoever ports one of those hooks (M4) must replace the skip with a bail first.
- `YAMA-TICK` (M4): skipped in the Shikai with the heat below the top (YA-FORM-NEXT is NIL).
- KEN-BK-TICK and ICHIGO-TICK are not stubbed (ported: Tasks 11, 12; ICHIGO-TICK's stub and the `ics-` mask left in Task 12).

Every other `unported!` stops the run: the kit hooks (HS-CLASH, YAMA-DMG-MULT, ...) and the kit cinematics. Until Task 11 every kit's hit called one of its hooks, so no trace finished an APPLY-HIT step; since Task 11 (Kenpachi's
hooks and cinematics, `rs/duel-sim/src/ken/`) the four Kenpachi mirrors replay whole matches bit-exact (cvc-kk-s1/s2/s3, cvctag-kk:
`replay OK`, with or without `--stubbed`), and the Kenpachi-vs-Ichigo / -Yamamoto traces run on to Ichigo's / Yamamoto's first hook.
The mode references nothing of Kenpachi's (KEN-BK-TICK runs as ported).

**What it masks** (`--mask`, replay.rs `masked`: B field-name prefixes after `pN.`, `!prefix` keeps one): the kit state the stubbed
ticks write, `hss-*` / `yss-*` (Hisagi's /
Yamamoto's kit state, M4). **H** is not compared while a mask is set: STATE-HASH-LINE (gate.lisp) hashes pos, yaw, state, form, kikon-n,
sp-paid, xch / xch-done, ptr, cd and the hazard count, all in B, plus gauge fields (r k f g ! w m, in B) and the kit `:hash` (Hisagi's
`hss-`); Task 7's review checked every item is in B or a masked field. B still compares the globals (`*timer*`, `*hitstop*`,
`*slow-acc*`, `*slowmo*`), T and the combat log on every step.

Proof (Task 8 part 0, on fbbed2bd): the mode reproduced Task 7's scratch check exactly. Task 9: with the real GAUGE-SYSTEM, all 51 cvc /
cvctag traces stopped at the same name and step as with Task 8's gauge stub (0 DIVERGED). Task 10: with the real HAZARD- / HIT-SYSTEM,
0 DIVERGED on all 51, each stopping at a kit hook (the per-trace table: `.superpowers/sdd/2026-11-26-m1-sim-core/task-10-report.md`).
Task 12: 0 DIVERGED on all 51 (the 15 Kenpachi / Ichigo traces `OK`, the rest stopping at a Hisagi / Yamamoto hook: Task 12's report).
Delete the mode once M4 ports their ticks.

## 4. sin / cos: musl everywhere; the answer key once took glibc's at gcc's fused sites (Task 12, fixed 2026-11-27)

**The finding (Task 12).** cvc-ik-s1 diverged at replay step 11399 on an NS3 clone's z (ICHIGO-NS-SLOT, `hz1.z` want 3E98FA3A got
3E98FA38). The native sim (`build/simgate/duel.fas`, and the recorder's image built the same way) preloads musl's math (tools/simlib.py
`MUSL_MATH`) so the host matches wasm, but the list had no `sincosf`. gcc -O2 replaces a C function's `sinf(a)` and `cosf(a)` of one
value by one `sincosf(a)` call, which then bound to the system glibc's (2.39 i686; 1 ulp off musl's on ~2 % of arguments); `fminf` /
`fmaxf` also bound to glibc's (a different zero for (+0, -0)). Task 12 first ported glibc's `sincosf` to match that key.

**The probe (the lead, 2026-11-27).** The shipped wasm is the game's truth, and emcc never fuses the pair: it calls musl's separate
`sinf` / `cosf`, whose values equal the Rust `libm` crate on 200,000 inputs. So the old key was wrong at the fused sites, not the port.

**The fix.**
- The preload serves musl's `sincosf`, `fminf` and `fmaxf` (commit e0666342). musl's `sincosf` equals its `sinf` / `cosf` bit for bit
  (0 differences on 6M inputs), so every native ECL run gives musl's bits at the fused sites from 2026-11-27 04:06.
- The answer key was re-recorded and re-pinned (M0_NOTES §4): cvc-ik-s1 (from step 11399) and cvc-ii-s3 (from 13587) changed by 1 ulp
  in NS3 clones' places; 388 FK clips by ≤ 8e-7. The old key is at `build/oracle-glibc` (reference only: against it the port now
  diverges at exactly those two steps).
- `math::sincosf` is `(libm::sinf(y), libm::cosf(y))`; the glibc port and its test are gone. **Rule: every transcendental f32 call goes
  through `libm`.** The fused sites keep calling `math::sincosf` only as a marker of where gcc fused them (VOL-HIT-P's yawed cap,
  OBOX-CYL-HIT-P, ICHIGO-NS-SLOT, ICHIGO-HASTE-DASH, CLONE-WAVE; unported: WAVE-ARRIVAL, STICK-TOWARD-STRAFE, RUN-CLIP, `_pose_fk_`,
  `m4_euler_`, FEEDBACK-SYSTEM, the looks, Hisagi's and Yamamoto's): a fused site, listed or found later (`objdump -d` callers of
  `sincosf`), calls `math::sincosf`; every other transcendental calls `libm` directly. The bits are the same either way; the marker
  keeps the fused-site list trustworthy.
- The ECL-pinned tests at the fused sites (`tests/ichigo.rs` `o_press_charges_and_bursts`, `haste_dash_and_renzan`) were re-run in ECL
  on the musl preload: the same bits as pinned (their inputs are not among the ~2 % where glibc and musl differ).

The image's glibc math imports the preload still does not serve (`objdump -T build/simgate/duel.fas | grep GLIBC`): `floorf`, `fmodf`,
`lrintf`, `sqrtf` (exact) and `sincosl` (load-time code only, long double). `fminf` / `fmaxf` are musl's now (`math::f_min` /
`f_max`'s choice); their sim callers are FIGHTER-PHYSICS (`fmaxf`) and SLOWMO-SCALE (`fminf`).


## 5. Closing numbers (Task 14, 2026-11-27)

Machine: i7-13700K (24 threads), one thread per run. The Lisp native sim is the host ECL 24.5.10 (32-bit i686) on
`build/simgate/duel.fas` with the musl preload (`LD_PRELOAD=build/simgate/muslm.so`); Rust is `rs/target/release/duel-tools` (x86_64)
and the same crate built for `wasm32-wasip1` under node 22.18.0.

**The gate.** `tools/port/replay-gate.sh` (no flag): the 18 M1 traces `replay OK` at their pinned step counts. Since commit 1eec77f6 the gate also runs the four scripted outcome traces (M0_NOTES §4): scr-counter-stance-break, scr-bursts-chain-cut
and scr-draw are OK. scr-blocked-guard-crush-back stops `UNPORTED ICHIGO parry rim (a mirror P2's *mirror-rim*)` at step 62, so the
script exits 1 until that hook is ported (open; it predates Task 14's changes, per that commit). `cargo test --workspace
--release` passes; `cargo clippy -p duel-sim --all-targets -- -D warnings` and `cargo clippy -p duel-tools --all-targets` are clean.

**Snapshots** (`duel-tools replay TRACE --snap N`; snaptest.lisp's idea): every N battle ticks, at a step's end after its comparison,
the live `Match` is cloned. Its sim stream is reseeded as snaptest reseeds (`(state ^ 0x5BD1E995) | 1`), it plays 40 steps on the vpads
as they hold (no reader), and then the clone is put back. The replay must stay OK, so the clone holds the whole sim state (no state
outside `Match`, no shallow copy). With `--snap 40` all 18 gate traces stay `replay OK`. cvc-ki-s1 is the brief's case: `replay OK 21368
ticks`, 534 rollouts. Every rollout moved the B line (so none was a no-op) and none reached an `unported!` path (which the restore
would forget).

**wasm32.** `cargo build --release -p duel-tools --target wasm32-wasip1` (the target was installed with `rustup target add wasm32-wasip1`)
gives a 6.7 MB `duel-tools.wasm` with the data embedded. `node tools/port/replay-wasm.mjs TRACE [args]` runs it under `node:wasi` with
the trace's directory preopened as `/t`, and passes the exit code through. `cvc-ik-s1` gives `replay OK 14268 ticks` (0.35 s) and
`trial-sp-xch-r3` gives `replay OK 359 ticks`; a broken trace exits 1. Native and wasm32 agree bit for bit (BEVY_PORT §6.3).

**Speed** (BEVY_PORT §6.4; the gate is ≥ 3× the Lisp native sim). Both sides do the same work: a cmds trace's match with the brains
detached, each sim frame's recorded inputs injected, no comparison, the console or log off, the trace read before the clock starts.
Each run checks it reproduced the trace (its step count and its last H line).

| Trace | Lisp `tools/port/sim-bench.lisp` | Rust `replay --bench` | Ratio | Rust wasm32 (node) |
|---|---|---|---|---|
| cvc-kk-s1 (18133 steps) | 172,000 steps/s (0.105 s) | 820,000 (0.022 s) | **4.8×** | 425,000 |
| cvc-ki-s1 (21368) | 163,000 | 685,000 | **4.2×** | 395,000 |
| cvc-ii-s1 (19423) | 153,000 | 607,000 | **4.0×** | 355,000 |

The gate passes: 4.0-4.8× native. Rust in wasm32 under node runs at 2.3-2.5× the Lisp native sim. The step counts include the intro
and the hitstop / slow-motion steps, the same on both sides. The Lisp hook (the reader that injects, the step hook that detaches) runs
interpreted, since `load` of a source file is ECL's bytecode. It is a few calls per step against the compiled sim, so the Lisp figure
is slightly pessimistic. Run three times, the spread is within 1 %.

The brief's literal method, `gen.py replay cvc-kk-s1` minus a zero-command image start (`tools/simgate/run.lisp` with no commands:
0.50 s), gives 20.6 s - 0.5 s, about 900 steps/s, which would put Rust at ~900×. That figure is not a sim speed. replay.lisp spends
almost all of its time interpreting TR-B-LINE (430 fields formatted per step) and reading the trace. The like-for-like replay with full
comparison is Rust `replay` at 0.20 s against Lisp `replay.lisp` at 20.6 s (~100×). For reference, `run.lisp 30000 31101 200110` (the
same match with the Lisp CPUs playing it) takes 0.63 s including the 0.50 s start.

**No allocation per step** (`duel-tools` test `bench_allocs`, with a counting global allocator in the test binary that counts per
thread). Under `--bench`'s driver with the combat log off, cvc-kk-s1 allocates **0 times** in every frame that starts and ends in the
battle: its whole battle, ~17,800 steps, where the brief's bar is 600. The one allocation left is the gate's result push on the frame
that leaves the battle. Before Task 14 the same run allocated 258,646 times (~14 per step). What the counter found, and the fixes:
- `kit_of` lower-cased the kit keys into two Strings per call (1,822 of the 1,827 allocations in one battle frame). Now `fighter::kit_for` lowers them on
  the stack; `gauges::set_form` uses it too.
- APPLY-HIT's and CORE-NOHIT!'s move name for the log line was built with the log off. It is built only with the log on.
- `core_next_as` collected `:as-by-press` into a Vec. It now widens on the stack (16 entries; more panics rather than truncates).
- `Store` grew its Vec when the hazards first exceeded its capacity. It now reserves `MAX_ENTITIES` (256).
- Ichigo's: `flag_bits` lower-cased every flag (it now compares in place) and `core_segments` built a Vec per CLONE-REPLAY-WATCH (it
  now walks `core_segments_iter`).

Still allocating, on Ichigo's clone events only (not per step; cvc-kk-s2 also gives 0). In the same battle-frame count they total 218 in
cvc-ii-s1's 19,200 battle steps and 215 in cvc-ki-s1's 21,240 (the two Ichigo fixes above took out about 1,100 in cvc-ii-s1): `echo_hitwin` (a HitWin's `flags` / `vols` Vecs, the `:BLADE` insert), `ichigo_clones` / `live_clones`
returning `Vec<Entity>`, `clone_spawn`'s `borns` Vec, the Icc arena and `rq` pushes, `wave` / `clone_wave`'s one-element `vec!`.
They need fixed-capacity HitWin fields (M2, before the CPU's rollouts). Also for M2: a `Match` clone has tight Vec capacities, so the
first growth after a restore allocates. Rollouts should restore with `clone_from` or a capacity-keeping clone.

## 6. Host tests: `rs/duel-sim/tests/PORTED.md` totals

Ten Lisp test files, **780 checks: 674 ported, 106 deferred or not ported**, each with its reason in PORTED.md. The deferred ones by
milestone: the CPU (M2: input-test's 7 device checks, core.lisp 307-317 / 466 / 468 / 471 / 576), the looks (M3: clip speeds, clip names,
stance clips, poses, the event queue, the cine's DURING / actor hook / eye / hold), Hisagi and Yamamoto (M4: 22 triangle checks plus
steal values, sim.lisp's test binder kit, sp.lisp's `*sp-table*` rows, core 203). Not ported, each for a stated reason: sp 78, triangle
269, core 216 / 219 / 648 / 663 / 751, sublimation 5, ken 122. Per file: input 26/33, ecs 8/12, sp 70/75, triangle 111/142, core 282/309,
sim 48/70, sublimation 31/32, systems 13/13, ken 74/76, cine 11/18.
Beyond the Lisp checks the port holds its own ECL-verified tests on untraced paths: Kenpachi's armoured / blocked hits, Ichigo's hooks,
the trial actions, and now `core_start_cmd_fixture` (below).

## 7. Brain branches left for M2 (decision 3)

Every path that reads `Fighter.has_brain` (in the Lisp, a BRAIN component). A replay detaches both brains, so in M1 none of these fired
on a trace:
- `unported!` until the CPU ports:
  - `flow::sim_systems`: BRAIN-SYSTEM with a brain attached (`"brain-system"`).
  - `round::reset_round`: the brain's clear (`"brain-clear"`: brain-press-left 0, brain-fresh t).
  - `ichigo::hooks::parry_from_blockstun`: a CPU's parry press (`"ichigo brain parry-from-blockstun"`: brain-off / -masher / -habit,
    AI-MASH-P, IC-P).
- Ported but never run on a trace (they need a brain): `ichigo::hooks::tsuki_dash`, where a brain's dash aims at the opponent with no
  stick, and `tsuki_step`, where a brain picks its stance command at f`up` through `ai_stance`, drawing from the sim stream.
- Log lines that differ with a brain: `fighter/moves.rs:125` (`P move X`) and `fighter/states.rs:42` (`P step`) print a brain's "why"
  suffix in the Lisp. With brains attached they need a `has_brain` branch.
- `// cpu:` markers where a CPU call sits in the step or the match flow: `flow.rs` (`mc-full-step`, `mc-full-reset`, `strat-lookup` /
  `fq-attach!` / `masher-apply!`, `fq-match-end` / `mc-full-log` / `strat-log`), `gate.rs` (the gate difficulty, `*blow-aways*`).
- `debug::ensure_battle`'s BRAIN-OFF; `fighter::spawn_fighter`'s brain (difficulty, delay).
- Hisagi's `hs-tick-brain` is M4.

## 8. `// look:` call sites (M3's list)

114 `// look:` markers in `rs/duel-sim/src`, each a Lisp call or write the sim skips because only the looks read it (clips, fx,
sound, cues, camera, HUD, music): `fighter/states.rs` 18, `flow.rs` 14, `cine.rs` 11, `combat.rs` 10, `gauges.rs` 9,
`fighter/moves.rs` 9, `core_sim.rs` 9, `fighter/mod.rs` 8, `ichigo/hooks.rs` 7, `ichigo/clones.rs` 6, `round.rs` 4, `ken/hooks.rs` 4,
`ichigo/mod.rs` 2, `fighter/react.rs` 2, `ken/mod.rs` 1 (`grep -rc '// look:' rs/duel-sim/src`). M3 wires each one to the look side,
or records why it stays out.

## 9. Task 14's other items

- **E core-start / cmd / skip-cine fixture** (`duel-tools` test `core_start_cmd_fixture`, `rs/duel-tools/tests/fixtures/core-start-cmd.*`):
  - A one-trial Kenpachi mirror recorded by `record.lisp`: P2 starts KE-Z-AS1 through CORE-START! at sim frame 2, and `E cmd 30007` runs
    between frames. The `move` / `SP … paid 25.0` e lines and the hit 16 frames later are compared step by step.
  - An `E skip-cine` was added by hand. No cinematic runs there (a trial runner calls SKIP-CINE only `(when *cine*)`, and
    `*skip-cines*` is T in trials), so it checks only that the line parses and is a no-op. No gate trial has one.
  - ECL's `replay.lisp` and the Rust replay both give `replay OK 29 ticks`, and without the core-start line the Rust replay diverges.
  - The scripted outcome traces (M0_NOTES §4 "Scripted outcome traces") cover the rest of the untraced combat outcomes.
- **Task 13's carries**: `E full-gauges` reads its meter with `float()`, so an integer is an error (the slot is a single-float and the
  recorder never prints one). Both `E` side readings (`side()` and `set`) follow TR-ENTITY's rule: 0 is P1, any other integer is P2.
- **M0's crash-as-OK** (Task 1): M0's `gen.py replay` counted an ECL crash as OK, because the debugger exits 0 at stdin's end, so two
  failures hid in M0's "63/63". It now needs a `replay OK` line, and all 63 truly pass.

## 10. What M1 hands on (from the ledger, `.superpowers/sdd/2026-11-26-m1-sim-core/progress.md`)

- **M2 (the CPU):**
  - the brain branches (§7);
  - `id_of` scans the 549 moves per move start / latch / CHAIN-MORE-P (index it before rollouts; the speed gate didn't need it);
  - the rollout clears `Match.pacing_log` (rollout.lisp binds `*pacing-log*` nil);
  - the CPU's Reishi readers need `cl::Num` if trials replay with brains (cpu-kh-ken.lisp:88, REISHI-FRAC, AI-BURST-WANTED-P /
    AI-HOHO-SPARE-P, FINISH-ROLE);
  - VIEW-STEP for a `cam_relative` pilot (§2);
  - input-test's device checks;
  - the clone allocations and the capacity-keeping restore (§5).
- **M3 (looks):** the `// look:` list (§8), the deferred look checks (§6), the event queue (`emit` / `take-events`).
- **M4 (Hisagi, Yamamoto):**
  - their hooks, ticks and traces; delete the stubbed mode (§3);
  - `kit::find_move` returns the kit's copy, while Lisp FIND-MOVE returns the registry's (KE-Z-N2A hs 10 vs 8), and 7 Yamamoto names
    have a `var/` entry first;
  - `E core-start`'s lower-case key lookup is unverified for their moves;
  - SIPHON-OF / BIND-OF are no-ops until their hook keys exist;
  - PULL-OPP-TO moves to fighter;
  - `trial-sp-costs` and `trial-sp-kits-*` join the gate.
- **M5:** the `debug_ranges.json` name map and `tests/scripts/*.json`.
