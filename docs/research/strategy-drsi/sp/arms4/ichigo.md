# Ichigo's arms (PLAN4 §3, batch B3, 2026-11-15)

Assembled, no search (PLAN4 §3: "Ichigo: none"). Arms: `ichigo.lisp`, one style function `ichigo-ki-r2b2a1-style`. Exchange units:
`x-units/d-x-ki-i.lisp` (KI, from `x-ki-i-r1-b0a2`) and `x-units/d-x-ih-i.lisp` (IH, from `x-ih-i-r1-b2a1`), the §6.5 exchange keys only.

## The arms

| Arm | Job (PLAN4 §3) | Keys | Job rules (T0) |
|---|---|---|---|
| `a4-i-all` (arm 0) | the mode mix | the common base, no `:iks-mix-*` key: the style's own mix for the tier (HARD 0.04 / 0.26 / 0.26 / 0.28 / 0.16) | everywhere else |
| `a4-i-whiff` | hover at his whiff distance | whiff 1, the other four 0 | G2 attacking x mid; G1 sealed x mid |
| `a4-i-space` | far spacing and the lunge | space 1, the rest 0 | G1 far; G6 my wall near |
| `a4-i-ptr3` | pointer-3 pressure, the shut-gauge lunge | ptr3 1, the rest 0 | G3 his cells 0; G9 pointer 3 |
| `a4-i-kessa` | awakened chains | kessa 1, the rest 0 | G0 awakened; G1 form 1 |

The common base is the KI table's 2026-11-15 arm 0 (`x-ki-i-r1-b0a2`) without its five exchange keys and its three mix keys: `:ikw-roll-*`,
`:b-*` and their four rules, `:range 0.7 ... :p 1.0`, `:iks-wait-max 40 :iks-gap-p 1 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5
:iks-meaty-p 0`. The IH arm (`x-ih-i-r1-b2a1`) differs in a few style keys (`:iks-meaty-far 4.5`, `:iks-gap-wait 5.5`, `:range 0.5`,
`:awaken 2.0`, no `:ikw-roll-*`, `:iks-getsuga-min` / `:iks-meaty-p` at the defaults). The general arms are shared by the three tables
(PLAN4 §3), so IH's table plays KI's style keys. That is a deviation from P2, whose arms were "the side's shipped arm with a few keys
changed".

**Arm 0's mix**: no mix key, so arm 0 follows the tier (HARD the mix above, EASY generic only, NORMAL 0.88 generic). The job arms name all
five, so they are the same at every tier.

## Pre-registered (before the first proof run)

Played whole against his `none`, HARD, seeds 1-100 both seats (200 matches), as T0 plays it: a 1-arm `:rb-sp2` table (keep-state, period 30)
with the pairing's `:with` unit. Opponents: Kenpachi (`d-x-ki-i`) and Hisagi (`d-x-ih-i`).

| Arm | Descriptor | Pass |
|---|---|---|
| whiff | share of steps at 3-6 m (`mid`) | >= arm 0's + 0.05 |
| space | mean distance | >= arm 0's + 0.5 m |
| ptr3 | share of steps at SP pointer 3 | >= arm 0's + 0.10 |
| kessa | share of steps awakened | >= arm 0's + 0.05 |

- **K.O.**: the share of matches that end by any K.O. (sw.py's `ko_rate`) >= 0.50. The K.O.-win share is reported beside it.
- **Distinct**: two arms are not distinct when they are within tolerance on every descriptor: mean distance 0.25 m; the shares (close, mid,
  far, awakened, Bankai, released) 0.03; pointer 3 0.05; the counts a match (SP moves, Bursts, Kikons, Burst + Kikon, Steps + Hohos,
  action starts, clashes) and wake presses per knockdown 15 % of the larger (at least 0.15).

## Results

(below)
