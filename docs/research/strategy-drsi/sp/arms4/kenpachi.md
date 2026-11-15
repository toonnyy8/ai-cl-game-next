# Kenpachi's arms (PLAN4 §3, batch B3, 2026-11-15)

Assembled first (PLAN4 §3); `rush` and `guard` are the two branches PLAN4 gives tuning cells (8 Sonnet cells, 2 x 4). Arms:
`kenpachi.lisp`, style `ken-kh-standoff-style` (the bait arm: `ken-kh-style`). Exchange units: `x-units/d-x-ki-k.lisp` (KI, from
`x-ki-k-r1-b0a2`), `x-units/d-x-kh-k.lisp` (KH, from `x-kh-k-r1-b0a2`), the §6.5 exchange keys only.

## The arms

| Arm | Job (PLAN4 §3) | Keys over the base | Job rules (T0) |
|---|---|---|---|
| `a4-k-all` (arm 0) | | the base | everywhere else |
| `a4-k-rush` | close in | `:range 0.5`, Step in 1, Hoho in 1 (`:kk-hin-fs 100`, from 6 m), `:kso-stale 0`, back Step 0, `:kk-reach-p 1`, Hoho-safety 0 | G3 his cells 0; G2 down; G8 late |
| `a4-k-guard` | hold and answer | `:range 1.3`, brawl read 1 from 4 m, dodge 1, back Step to 7 m, no lunge, Step / Hoho in 0, Hoho-safety 1, `:kso-stale 600`, `:kk-reach-p 1` | G0 ahead; G4 his burst |
| `a4-k-spend` | cells into Burst / Kikon | `:kikon 3.0`, `:kk-kikon-red-p 0`, `:kk-kikon-ptr-p 0` (`:other 10` is the base's) | G3 my cells >= 1; G4 my burst |
| `a4-k-climb` | build to the Bankai and awaken | `:kk-climb-p 1`, `:kk-bankai-p 1`, `:kk-bk-ns-p 0.25` | G0 behind x not awakened; G9 switch not open |
| `a4-k-bait` (vs H) | the wake-up bait | `:fn ken-kh-style`, `:khf-bait-p 1`, `:khf-bait-d 2.3` | G2 down |
| `a4-k-wave` (vs I) | the wave answer | `:kk-wave-p 0.9` | G10 his pointer 2 (her Getsuga: NS2, `ichigo.lisp`) |

The base is the 2026-11-15 arm 0 of both the KI and the KH table: `x-ki-k-r1-b0a2` and `x-kh-k-r1-b0a2` share every key but the exchange keys
(`:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0`, Step in 0, awaken 1, reach margin 0.35, wave 0, lunge 1, `:kso-stale 60`,
back Step 1 to 4.5 m, Bankai 0, reach 0.5, Hoho-safety 0.8, `:other 10`, `:kikon 0.3`). No arm names an exchange key.

**The bait arm's state**: `ken-kh-style` keeps a KHS and the stand-off style a KSO, and each restarts the other's state at a switch, with
`:keep-state t` or not (both include the KI style's KKS, which restarts with them).

## Pre-registered (before the first proof run)

Played whole against his `none`, HARD, seeds 1-100 both seats (200 matches), as T0 plays it: a 1-arm `:rb-sp2` table with the pairing's
`:with` unit. General arms against Ichigo (`d-x-ki-k`) and Hisagi (`d-x-kh-k`); the targeted ones against their opponent only.

| Arm | Descriptor | Pass |
|---|---|---|
| rush | share of steps inside 3 m | >= arm 0's + 0.10 |
| guard | Steps + Hohos a match | >= arm 0's x 1.3 |
| spend | Bursts + Kikons a match (PLAN4's example "SP presses x 1.5" reported beside it) | >= arm 0's x 1.5 |
| climb | share of steps in the Bankai | >= arm 0's + 0.05 |
| bait (vs H) | my action starts in his first 20 free steps after a knockdown, per knockdown | <= arm 0's x 0.5 |
| wave (vs I) | Steps + Hohos a match | >= arm 0's x 1.2 |

K.O. (>= 0.50 of matches end by any K.O.) and distinctness: as `ichigo.md`.

## Results

(below)
