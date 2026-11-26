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

**"0 DIVERGED on all 51" holds only under `--stubbed`** (the final review, finding 5). The mask turns H off. In the default mode the
21 Hisagi cvc traces report `replay DIVERGED at tick 1 (step 0, item 0): H: …`, not UNPORTED: `hashline.rs` (313, 383) leaves out the
kit's `:hash` hook and HSS / YSS without a marker (`state_hash_line` takes `&Match`, so it cannot call `unported!`). That is a missing
port, not a port bug. Carry to M4: port the `:hash` hook with Hisagi, or have the replayer report UNPORTED while a side's kit has a
`hash` hook. The Yamamoto traces stop UNPORTED as they should.

Since the final review's fix pass a stubbed or masked run says so on its outcome line, `replay OK (stubbed: HS-TICK,YAMA-TICK;
masked: hss-,yss-) N ticks`, and the gate's `--stubbed` rows read `OK-MASKED`, so a pasted row can't pass for the gate's verdict.

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

**The gate.** `tools/port/replay-gate.sh` (no flag) runs **22 traces**, all `replay OK` at their pinned step counts, exit 0:
- the 18 M1 traces: 12 cvc, 3 cvc-tag, 3 trials;
- since commit 1eec77f6, the four scripted outcome traces (M0_NOTES §4): scr-counter-stance-break 159, scr-bursts-chain-cut 179,
  scr-blocked-guard-crush-back 1659, scr-draw 36000.

scr-blocked-guard-crush-back first stopped at step 62 on PARRY-WATCH's mirror rim, which Task 14's follow-up ported. In a mirror
match P2's model rim is `*mirror-rim*`, and PARRY-WATCH saves it in `ics-rim`, which B prints. With that port, Rust replays BLOCKED
(ticks 74 and 539), GUARDLESS BLOCK + GUARD CRUSH (539) and GUARD BACK (1532) bit-exact on the first run; nothing else needed a
fix. `cargo test --workspace
--release` passes; `cargo clippy -p duel-sim --all-targets -- -D warnings` and `cargo clippy -p duel-tools --all-targets` are clean.

**Snapshots** (`duel-tools replay TRACE --snap N`; snaptest.lisp's idea): every N battle ticks, at a step's end after its comparison,
the live `Match` is cloned. Its sim stream is reseeded as snaptest reseeds (`(state ^ 0x5BD1E995) | 1`), it plays 40 sim steps (`flow::sim_step`, not
frames: a turbo frame is 120 steps) on the vpads as they hold (no reader), and then the clone is put back as a full replacement (`*m = saved`).

What this proves:
- **That nothing leaks: by construction, not by test.** duel-sim holds no `Rc` / `RefCell` / `Cell` / `Arc` and no statics, and
  `Data` is `&'static` and immutable.
- **What a pass does show:** 40 reseeded steps from each snapshot reach no panic and no `unported!`.

With `--snap 40` all 22 gate traces stay `replay OK`. The gate runs them that way with `tools/port/replay-gate.sh --snap`; the outcome
line stays first, and the summary `snap: N rollouts of 40 sim steps, K reached an unported path` follows it. cvc-ki-s1 is the brief's
case: `replay OK 21368 ticks`, 534 rollouts, none reaching `unported!`.

Since the final review's fix pass, a rollout that reaches an `unported!` path is never OK:
- the restored match keeps the name in `m.unported`;
- the run stops with `replay UNPORTED NAME in a --snap rollout from tick T (step S)` (exit 3);
- the gate fails that row as `SNAP-UNP`, even with `--allow-unported`.

Before the fix the count was only on the summary line, which the gate never read. Checked on cvc-kh-s1 (stubbed): `HS-MIN-REACH in a
--snap rollout from tick 40 (step 340)`, gate exit 1. A unit test covers it too (`snap_rollout_keeps_unported`).

**`cargo test` is not trace coverage.** The tests that read the answer key skip when `build/oracle` (or `ORACLE`) is absent: replay.rs's
intro test and `bench_allocs`, and the hashline trace-head test. Each skip leaves a note on stderr, which a passing `cargo test` hides.
So a green suite without the key, or with a mistyped `ORACLE`, says nothing about the traces. The verdict is
`tools/port/replay-gate.sh`.

**wasm32.** `cargo build --release -p duel-tools --target wasm32-wasip1` (the target was installed with `rustup target add wasm32-wasip1`)
gives a 6.7 MB `duel-tools.wasm` with the data embedded. `node tools/port/replay-wasm.mjs TRACE [args]` runs it under `node:wasi` with
the trace's directory preopened as `/t`, and passes the exit code through (a `--data DIR` is preopened as `/d`). All 22 gate traces give `replay OK` at the native counts (cvc-ik-s1: `replay OK 14268 ticks` in
0.35 s; trial-sp-xch-r3: 359); a broken trace exits 1. So native and wasm32 agree bit for bit on the whole gate (BEVY_PORT §6.3).

**Speed** (BEVY_PORT §6.4; the gate is ≥ 3× the Lisp native sim). Both sides do the same work:
- a cmds trace's match, with the brains detached;
- each sim frame's recorded inputs injected;
- no comparison, and the console or log off;
- the trace read and the commands' first frame run before the clock starts;
- on the Lisp side, its two hooks (the reader that injects, the step hook that detaches) compiled to native code first.

Each run checks it reproduced the trace (its step count and its last H line). The figures (fix round 1):
- Rust `--bench`: the median of 11 runs in one process, each from a fresh setup (one run is 15-22 ms; the spread across runs is
  under 1.5 %);
- Lisp: the median of 5 process runs (spread ±4 %).

| Trace | Lisp `tools/port/sim-bench.lisp` | Rust `replay --bench` | Ratio | Rust wasm32 (node) |
|---|---|---|---|---|
| cvc-kk-s1 (18133 steps) | 249,000 steps/s (0.073 s) | 1,200,000 (0.015 s) | **4.8×** | 649,000 |
| cvc-ki-s1 (21368) | 231,000 | 1,038,000 | **4.5×** | 578,000 |
| cvc-ii-s1 (19423) | 239,000 | 884,000 | **3.7×** | 500,000 |

The gate passes: 3.7-4.8× native. Rust in wasm32 under node runs at 2.1-2.6× the Lisp native sim.

**M2 re-runs this gate with the CPU on.** BEVY_PORT §6.4 defines the measure as "cvc turbo", i.e. with the CPUs playing. M1 has no
CPU, so both sides here run brainless on recorded inputs. The step counts include the intro
and the hitstop / slow-motion steps, the same on both sides.

How the gate was reached:
- **The first measure flattered Rust.** Its Lisp hooks were interpreted (ECL's `load` of a source file is bytecode) and its timer held
  the commands' frame. That gave 4.0-4.8×.
- **Made fair**, the same Rust code gave 2.7-3.3× (cvc-kk-s1 820k vs ~250k, cvc-ki-s1 685k vs 233k, cvc-ii-s1 607k vs ~225k): two of
  the three failed.
- **The time went to name lookups.** `kit_of` and `hurt_r` ran two `BTreeMap<String, _>` lookups by name on every call, many times a
  step.
- **The fix.** `fighter::KitTable` indexes the data's kits once per match by (character, form) with each body's `hurt_r`, held in
  `Match.kits`. `kit_of`, `hurt_r`, `set_form` and `spawn_fighter` read it. That brought Rust to the table's numbers.
- `id_of`'s 549-move scan per move start is still unindexed (M2).

The brief's literal method, `gen.py replay cvc-kk-s1` minus a zero-command image start (`tools/simgate/run.lisp` with no commands:
0.50 s), gives 20.6 s - 0.5 s, about 900 steps/s, which would put Rust at ~900×. That figure is not a sim speed. replay.lisp spends
almost all of its time interpreting TR-B-LINE (430 fields formatted per step) and reading the trace. The like-for-like replay with full
comparison is Rust `replay` at 0.20 s against Lisp `replay.lisp` at 20.6 s (~100×). For reference, `run.lisp 30000 31101 200110` (the
same match with the Lisp CPUs playing it) takes 0.63 s including the 0.50 s start.

**No allocation per step** (`duel-tools` test `bench_allocs`, with a counting global allocator in the test binary that counts per
thread). Under `--bench`'s driver with the combat log off, cvc-kk-s1 allocates **0 times** in every frame that starts and ends in the
battle: its whole battle, ~17,800 steps, where the brief's bar is 600. The one allocation left is the gate's result push on the frame
that leaves the battle. Before Task 14 the same run allocated 258,646 times (~14 per step). What the counter found, and the fixes:
- `kit_of` lower-cased the kit keys into two Strings per call (1,822 of the 1,827 allocations in one battle frame). Now it reads
  `Match.kits` (the `KitTable` above); so do `gauges::set_form` and `spawn_fighter`.
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

**Dead by data for M1's kits** (ported, but no Kenpachi / Ichigo match can reach them; the scripted traces cover every other APPLY-HIT
outcome):
- **BLOWN AWAY**: `*stun-blow-away*` is NIL (the user, DEVLOG §173). The stun still adds and decays.
- **GUARD-BREAK**: a core kit never guards, and neither kit has a ranged hit that crushes a guard.

  No core-kit defender ever stands in `:guard-hit` (blockstun) either. DEFENDER-STATE maps that state to `:guard` (fighter.lisp 1054),
  but KESSA's `:parry-block` is a ward in APPLY-HIT (combat.lisp 115), and its `:blocked` branch gives no blockstun (266-270).
- **Kenpachi's KE-BUTTAGIRU (KEN-GROUND-CRACK), KE-CHARGE (KEN-CHARGE-TICK, `fighter-crush`) and KE-FLURRY**: never start in the 22
  gate traces. Their commands (`:sp1` / `:sp2`, ken.lisp 180) sit in MOVE-COMMANDS' dead clauses (DIVERGENCES §1), so no press reaches
  them; only a debug drive such as `:p2-start` could. Carried to M2 in case the CPU starts one. (KE-ZH-SP, TATEGOTO's split / cut,
  does start: 3 times.)
- **KEN-BANKAI-CINE**: never plays, although the Bankai is entered (cvc-ki-s1 tick 14108 `P2 form BANKAI`). Its one match caller,
  KEN-BURST (ken.lisp 365), calls `(bankai! e form nil nil)` with CINE NIL ("卍解的瞬間不再接入特寫", DUEL_KEN_V3 §32). Only debug
  commands play it: debug.lisp 387 (force-cine) and ken.lisp 931. Its director path (`ken/cine.rs`, 186 steps) is ported and read line
  by line (Task 11's review), but untraced. Carried to M3 with the cinematics' looks, or to M5 with the debug commands.

These wait for a kit, a knob or a debug drive that reaches them (M2 at the earliest).

**Coverage unknown:** the resumed Hoho (HOHO-RESUME) and CUT-HAZARDS print no log line, so a trace grep can't tell whether the 22
traces reach them. They are ported and read line by line (Tasks 10-11), and are carried to M2 for a coverage run.

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

**`unported!` is a replay-only mechanism** (the final review, findings 2 and 13). The macro (`lib.rs`) records the first unported path
in `m.unported`. Nothing else in the sim reacts to it:
- `flow::frame` still returns true;
- `flow::advance_sim` just stops stepping, while `ft` / `frame_n` keep counting;
- `flow::sim_step` has no guard of its own.

The replayer is the only reader: it reports UNPORTED, and since the fix pass a `--snap` rollout's cut fails the run too (§5). M2's game
loop and its rollouts must check `m.unported` themselves and surface it. A rollout cut short gives the MCTS a wrong value with no
signal; for example, `frame` returns false or names the path, and the rollout driver counts cut rollouts. In M3's playable page an
unported path would be a frozen fight with no message.

- **M2 (the CPU):**
  - check and surface `m.unported` in the game loop and the rollouts (above);
  - the brain branches (§7);
  - `id_of` scans the 549 moves per move start / latch / CHAIN-MORE-P (index it before rollouts; the speed gate passed without it);
  - the rollout clears `Match.pacing_log` (rollout.lisp binds `*pacing-log*` nil);
  - the CPU's Reishi readers need `cl::Num` if trials replay with brains (cpu-kh-ken.lisp:88, REISHI-FRAC, AI-BURST-WANTED-P /
    AI-HOHO-SPARE-P, FINISH-ROLE);
  - VIEW-STEP for a `cam_relative` pilot (§2);
  - input-test's device checks;
  - the clone allocations and the capacity-keeping restore (§5);
  - re-run the speed gate with the CPU on both sides (§5);
  - Kenpachi's KE-BUTTAGIRU / KE-CHARGE / KE-FLURRY if the CPU starts them;
  - a coverage run for the resumed Hoho and CUT-HAZARDS (§5).
- **M3 (looks):**
  - the `// look:` list (§8), the deferred look checks (§6), the event queue (`emit` / `take-events`);
  - KEN-BANKAI-CINE's looks (only debug commands play it, §5);
  - the mirror P2's look: `Data::mirror_rim()` (read once into `Match.mirror_rim` since the fix pass) and tables.json `mirror_tint`
    are extracted (fix round 1), never hand constants;
  - **the touch deck's sim branches** (the final review, finding 3). The phone's thumb pad changes the Kikon hold rule for P1 on
    `*one-hand*`, and the port stubs each branch to a constant, marked `// port: touch stub`: `core_sim.rs` `core_note_start`'s
    `sp_held` (never `:rearm`; core-sim.lisp 14), `core_hold_step` / `core_touch_p` / `core_touch_sp_p` (no `:rearm` arm, always NIL;
    418-431), `core_confirm_frames` (no `*core-kikon-confirm-touch*`; 463). `Match` has no `one_hand` field, so no `unported!` can
    fire. No trace has touch input, so the gate cannot see these: each needs its own test (a recorded touch trace or a host test);
  - `flow::frame` is the headless platform's frame (the final review, finding 12): it derives dt from `frame_n` (stubs.c's virtual
    clock, `raw_dt`) and drains the debug queue and the gate. A real loop needs dt as an argument.
- **M4 (Hisagi, Yamamoto):**
  - **before either kit: one hook table per kit** (the final review, finding 1; the lead's ruling: not fixed in M1, an M4
    prerequisite). BEVY_PORT §4 says kit hooks become per-kit function tables. M1 dispatches them by per-kit arms (`Ken` / `Ichigo`,
    `_ => unported!`) at the typed hook sites in about ten generic modules: `kit.rs` (`HookFn`, `resolve`, `hooks_of`, `kit_hook`),
    `fighter/moves.rs` (`call_hook`, `ken_hook`, `ichigo_hook`), `combat.rs`, `core_sim.rs`, `fighter/react.rs`, `fighter/mod.rs`,
    `round.rs`, `hazards.rs`, `cine.rs`. `kit::Hooks` (33 slots) is built in `Match::new` only to validate and then dropped, and the
    step path finds a hook through a `BTreeMap<String, String>` (`kit_hook_sym`) and string scans on every call. Replace that with one
    typed `Option<fn>` per hook key per kit, registered in one place and held per (character, form) next to `KitTable`; the generic
    sites call through it. Do it as its own gated task with the 22-trace gate as the net, before Hisagi;
  - their hooks, ticks and traces; delete the stubbed mode (§3) and the rest of the replay-era scaffolding with it: `flow::stub_tick`
    (called from the production `gauges.rs:450`), `Match.stubs` (cloned with every snapshot), the `m.unported` guards (about 38 reads in
    17 files, not only combat / hazards / gauges / round / ichigo: `grep -rn unported rs/duel-sim/src`), and the `unported!` macro
    with `Match.unported` once the last kit is ported;
  - the kit `:hash` hook and HSS / YSS in `hashline.rs` (313, 383): the Hisagi traces say DIVERGED at step 0 on H until then (§3);
  - `kit::find_move` returns the kit's copy, while Lisp FIND-MOVE returns the registry's (KE-Z-N2A hs 10 vs 8), and 7 Yamamoto names
    have a `var/` entry first;
  - `E core-start`'s lower-case key lookup is unverified for their moves;
  - SIPHON-OF / BIND-OF are no-ops until their hook keys exist;
  - PULL-OPP-TO moves to fighter;
  - `trial-sp-costs` and `trial-sp-kits-*` join the gate.
- **M5:** the `debug_ranges.json` name map and `tests/scripts/*.json`.

### Deferred minors (from the ledger; each line names its task)

- **M2:**
  - `--snap` read only the outcome line, so a cut rollout passed (T14): **fixed in the final review's fix pass** (§5);
  - `SimRng.state` is a pub field that bypasses `set_state`'s 0 → 1 rule; M2's rollouts reseed (T2);
  - `Params` f32 keys holding integer tokens lose integer-ness: audit each key when its reader is ported (T3; also M4);
  - `gen.py` with a names subset merges INDEX.json before the Lisp replay check: a failed replay leaves its entry, and a cvc-tag name
    in a subset leaves `cvc-tag.txt` stale; matters when M2 / M4 add traces (T14);
  - the wasm32 run is not in `replay-gate.sh` (a manual `replay-wasm.mjs` loop); add `--wasm` (final review 11);
  - B holds motion only partly (8 fields); the pilot / brain / model components are not in B (T1);
  - ICHIGO-AI-STANCE is untested (T12);
  - TIME-UP bails on a float Reishi before the Konpaku compare; the bail is needed only in the tie branch (T13);
  - a coverage run for Task 11's untraced Kenpachi list beyond §5 (the KR / ZH / Z2 Kikon cinematics, the stance / charge / flurry /
    cracks), now pinned only by hand-computed unit tests (T11).
- **M3:**
  - §1's anim table misses feedback.lisp:148 and draw.lisp:205 (looks only) (T7).
- **M4:**
  - the per-kit hook table: a prerequisite, not a minor (above, final review 1);
  - `cd[0]` / `Some(2)` hard-coded instead of `kit_command_index` (`fighter/mod.rs` ~332, ~430) (T8), and `refused_cue`'s kit branch
    hard-codes `"q"` (T12): both wait for a kit whose command order differs;
  - `HookFn::Cine` is `unreachable!` where an unported kit would want `unported!` (T12; goes with the hook table);
  - `tests/fighter.rs:195` `cancel_lands_for_both` runs a half step after Hisagi's `:clash` is unported (T8);
  - the YAMA-TICK stub's guard reads the kit meter's `:max`, not `*ya-heat-max*` (T9);
  - `kit.rs` (120, 130) takes `&mut Match` only to call `unported!` for Hisagi's `:seg-fn` (final review 14).
- **M5:**
  - `HwRef::Perfect` reads the knobs live where `*perfect-hw*` is built at load (differs only if a debug command changes knobs
    mid-run) (T10);
  - `control::wave_arrival` / `practice_reishi` are PRACTICE-only extras; sp.lisp:78 (the 0.6d0 row) is not ported (T5).
- **After the merge:** delete `build/oracle-glibc` (the pre-musl answer key, reference only; §4).
- **Any time (tidiness, no milestone):**
  - `rules.rs` is generic over `combat::Queue`: move `Queue` to `ecs.rs` or its own file (T10, final review 14);
  - `Str` does not escape `"` and `\` as PRIN1 does; the hazard owner's NIL arm; `Store::insert` has no alive check; `bits_line` /
    `hash64` allocate (T4);
  - `f_min` / `f_max`: the musl preload serves `fminf` / `fmaxf` now (§4); still add ±0 vectors before any signed-zero use (T2);
  - the test-vector file has no image provenance header, its parser lives in `cl.rs`, and it lacks clamp ±0 ties and hypot rows; the
    printer helpers lack `// port:` tags (T2);
  - the knob field list has no compile-time link to the Lisp names (`knobs_load` catches a mismatch) (T3);
  - no `tests/systems.rs` (its checks sit in core.rs / kit.rs, mapped in PORTED.md); `stun_weight` takes `&str` where `combo_step`
    takes a `Phase` (T5);
  - the replayer: check B before H (the Lisp's order), stop the turbo frame after a verdict, the injector finds a seat by side, not
    entity; a stale `#[allow(dead_code)]` in duel-tools `main.rs`; a machine-specific oracle path fallback in a test (T6);
  - `replay-gate.sh`'s empty array under `set -u` fails on bash < 4.4 (T8);
  - `gain_gauges_split` / `hit_system_lands_a_j1` compute their expectations with port functions; `hazards.rs:259` sets the state
    twice (T10);
  - `ken/mod.rs:80` `panic!` → `unreachable!`; `ken/hooks.rs:77-80` `nth_as` expects where Lisp's NTH past the end gives NIL (no live
    kit is short) (T11);
  - the oracle pin's commit field is the parent commit (documented, easy to misread) (T1);
  - `tools/simlib.py`: two tools building `muslm.so` at once write the same `.tmp` (fan-out tools call `build()` once first)
    (final review 16).
