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
