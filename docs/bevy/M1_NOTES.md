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
reset, round.lisp 78: Task 10 inherits the same rule) writes only
`*view-x*`, `*view-z*`, `*view-side*` and `*behind-yaw*`. Their readers: STICK-RELATIVE for a `cam-relative` pilot (a human seat;
CPU pilots keep `cam-relative` nil, M0_NOTES §4), camera.lisp (a look), sim-state.lisp's snapshot list (the CPU's rollouts, M2).
Neither `state-hash-line` (gate.lisp) nor the B line (trace.lisp `tr-b-line`: 29 globals, none of them) reads them. So in a
CPU-only match (every gate trace) VIEW-STEP is invisible to H and B; the port skips it and hits `unported!("view-step")` when a
`cam_relative` pilot exists (BEGIN-BATTLE and FIGHTER-SYSTEM; M2 ports it with the human input).

**RESET-SLOW-CLOCK** (main.lisp 13) is `(setf *slow-acc* 0.0)` and nothing else (a single-float 0); START-MATCH's call is
`m.slow_acc = 0.0` in `flow::start_match`.

## 3. The replay's stubbed mode (Task 8; Task 9 dropped the gauge stub)

The official gate (`tools/port/replay-gate.sh --allow-unported`) stops every cvc trace at `UNPORTED hazard-system` on step 301, before
any fighter code is compared, until Task 10 ports the hazards. The **stubbed mode** checks the fighter / core-sim / gauges port in the
meantime:

```sh
tools/port/replay-gate.sh --allow-unported --stubbed          # the 18 gate traces
NAMES="cvc-kh-s1 cvc-yi-s2" tools/port/replay-gate.sh --allow-unported --stubbed
rs/target/release/duel-tools replay TRACE --stub hazard-system,hit-system,ICHIGO-TICK,HS-TICK,YAMA-TICK --mask 'ics-,hss-,yss-'
```

Off by default: without `--stubbed` the gate and `duel-tools replay` are unchanged. It is not the gate's verdict.

**What it stubs** (`Match.stubs`, flow.rs): HAZARD-SYSTEM and HIT-SYSTEM at their entry points, and three forms' `:tick` hooks (called
by GAUGE-SYSTEM every step, gauges.rs), each by its name. A stub does nothing only while the real code provably writes nothing outside
the masked fields and logs nothing; otherwise it is `unported!` with its name, so the run reports the first UNPORTED it can't stub,
never a silent divergence:
- `hazard-system`: no-op while no hazard exists.
- `hit-system`: no-op unless a hazard exists, a perfect Hoho is on its counter-strike frame, both fighters are in Breaker phases
  (BREAKER-CLASH-P), or a fighter's move window would be collected (COLLECT-MELEE's own tests: `:move :main`, not a dead segment,
  open at SF, unused, the `:min` dead zone, WINDOW-TOUCHES-P; a window with `:min` of a form with a `:min-reach` hook stops
  with the hook's name, Hisagi's HS-MIN-REACH). So the run stops at the first contact (or a little before: an invulnerable defender's
  collected hit logs nothing).
- `ICHIGO-TICK` (Task 12): skipped outside KESSA, an `ic-tsuki*` move and with no hazard (ICHIGO-CUT); there it only attaches and
  writes his ICS. `HS-TICK` (M4): always skipped; it writes his HSS, and its move / log writes need states only his own (unported)
  hooks set, so a skip there would show as DIVERGED, not pass. `YAMA-TICK` (M4): skipped in the Shikai with the heat below the
  top (YA-FORM-NEXT is NIL). KEN-BK-TICK is not stubbed (the Bankai forms come only through Kenpachi's hooks, Task 11).

GAUGE-SYSTEM itself is real since Task 9 (the gauge stub and its `gauges-` mask are gone), so every gauge field is compared. Without the
three tick stubs every Ichigo / Hisagi / Yamamoto trace would stop at its `:tick` hook on step 301.

Every other `unported!` still stops the run: PERFECT-NOW-P (`hit-system`), the kit hooks and the kit cinematics (an awakening's
`KEN-NOZARASHI-CINE`, ...).

**What it masks** (`--mask`, replay.rs `masked`: B field-name prefixes after `pN.`, `!prefix` keeps one): the kit state the stubbed
ticks write, `ics-*` (Ichigo's ICS, attached and filled by ICHIGO-TICK from step 301: Task 12's), `hss-*` / `yss-*` (Hisagi's /
Yamamoto's kit state, M4). **H** is not compared while a mask is set: STATE-HASH-LINE (gate.lisp) hashes pos, yaw, state, form, kikon-n,
sp-paid, xch / xch-done, ptr, cd and the hazard count, all in B, plus gauge fields (r k f g ! w m, in B) and the kit `:hash` (Hisagi's
`hss-`); Task 7's review checked every item is in B or a masked field. B still compares the globals (`*timer*`, `*hitstop*`,
`*slow-acc*`, `*slowmo*`), T and the combat log on every step.

Proof (Task 8 part 0, on fbbed2bd): the mode reproduced Task 7's scratch check exactly (every one of the 51 cvc / cvctag traces ran to
`UNPORTED start-move` at the same step, with fs checked). Task 9: with the real GAUGE-SYSTEM and the new defaults, all 51 stop at the
same name and step as with Task 8's gauge stub (0 DIVERGED). Delete the mode once Task 10 ports the hazards and hits and the kit tasks
port the ticks.
