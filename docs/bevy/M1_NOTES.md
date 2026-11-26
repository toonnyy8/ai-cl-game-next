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

## 4. The answer key's sin / cos: musl, but glibc's sincosf where gcc fused them (Task 12)

The native sim (`build/simgate/duel.fas`, and the recorder's image built the same way) preloads musl's math (tools/simlib.py
`MUSL_MATH`: sinf, cosf, …) so the host matches wasm. musl has no `sincosf` in that list, and gcc -O2 replaces a C function's `sinf(a)`
and `cosf(a)` of one value by one `sincosf(a)` call, which then resolves to the system glibc's (2.39 i686, the SSE2 IFUNC: ARM's
optimized-routines algorithm in strict double). It differs from musl's sinf / cosf in the last bit on ~2 % of arguments. So at those
sites the trace holds glibc's values: cvc-ik-s1 diverged at step 11399 on an NS3 clone's z (ICHIGO-NS-SLOT, 2 ulp).

`math::sincosf` ports glibc's routine (table and constants read off `/lib/i386-linux-gnu/libm.so.6`; 0 differences on 2M inputs against
it). The fused functions are the unit's calls to `sincosf` (`objdump -dr` of the object `compile-file` leaves with `c::*delete-files*`
nil). Sim ones and their port: VOL-HIT-P's yawed cap, OBOX-CYL-HIT-P (Task 12 moved both to `sincosf`), ICHIGO-NS-SLOT,
ICHIGO-HASTE-DASH, CLONE-WAVE. Not yet ported, use `sincosf` when they are: WAVE-ARRIVAL (control.lisp), STICK-TOWARD-STRAFE (a
human's stick, M2), RUN-CLIP and the looks (M3), Hisagi's and Yamamoto's (`_hs-*`, `yama-*`, `ya-*`: M4). Every other `(sin x)` /
`(cos x)` / FWD-X / FWD-Z stays musl's (`libm`): AHEAD, for one, computes both of one yaw but gcc did not fuse them there.

The image's other glibc math imports outside the preload (`objdump -T build/simgate/duel.fas | grep GLIBC`): `floorf`, `fmodf`,
`lrintf`, `sqrtf` (exact), `sincosl` (only in the load-time code, long double) and `fminf` / `fmaxf`. Those two differ from musl's for
(+0, -0) and NaN only: glibc's returns its second argument for two zeros, musl's the negative one (`math::f_min`'s choice). Their one sim
caller is FIGHTER-PHYSICS; no trace has diverged on them, a mixed-zero argument there would.

