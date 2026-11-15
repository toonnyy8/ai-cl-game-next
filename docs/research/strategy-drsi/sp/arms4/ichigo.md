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

## Results (`proof.py desc`, sim build of 328ea625, seeds 1-100 both seats, 200 matches an arm; `proof/ichigo-vs-*.json`)

Differences from arm 0 (arm 0's row: values):

| vs | arm | mean d | close | mid | far | ptr 3 | awakened | SP a match | Step+Hoho | acts | clash | K.O. | K.O. win | test | not distinct from |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| K | all | 2.34 | .709 | .225 | .066 | .707 | .447 | 53.8 | 23.0 | 212 | 13.0 | 1.00 | 1.00 | | whiff, kessa |
| K | whiff | +.05 | -.006 | +.002 | +.004 | +.021 | +.007 | -0.5 | +2.9 | +1.6 | -1.3 | 1.00 | 1.00 | mid **FAIL** | all, ptr3, kessa |
| K | space | +.11 | -.020 | +.008 | +.013 | +.044 | -.006 | +0.7 | +4.3 | +6.0 | -1.5 | 1.00 | 1.00 | mean d **FAIL** | |
| K | ptr3 | +.04 | -.002 | -.004 | +.006 | +.023 | +.007 | -0.3 | +3.7 | +4.4 | -2.6 | 1.00 | 1.00 | ptr 3 **FAIL** | whiff |
| K | kessa | +.05 | -.006 | +.002 | +.004 | +.026 | +.012 | -0.2 | +2.6 | +4.1 | -0.5 | 1.00 | 1.00 | awakened **FAIL** | all, whiff |
| H | all | 3.02 | .569 | .323 | .107 | .681 | .603 | 55.4 | 66.6 | 275 | 29.1 | .99 | .875 | | whiff, kessa |
| H | whiff | +.04 | -.003 | +.001 | +.002 | -.015 | -.004 | 0.0 | +2.3 | +3.2 | -1.7 | .96 | .83 | mid **FAIL** | all, kessa |
| H | space | +.25 | -.068 | +.045 | +.023 | -.026 | +.053 | -2.4 | +7.5 | +10.6 | +4.1 | .94 | .84 | mean d **FAIL** | |
| H | ptr3 | -.10 | +.048 | -.046 | -.001 | -.027 | -.012 | +1.9 | -2.1 | +7.0 | +1.8 | .97 | .825 | ptr 3 **FAIL** | |
| H | kessa | -.02 | +.013 | -.016 | +.003 | -.009 | -.021 | +0.6 | -3.7 | +1.7 | -0.9 | .965 | .86 | awakened **FAIL** | all, whiff |

**Every job arm fails its descriptor against both opponents, and whiff / kessa are not distinct from arm 0.** All of them end their
matches (K.O. >= 0.94). Under PLAN4 §3 that leaves Ichigo with one general arm (`all`), under the floor of 3: **stop and report**.

**Why** (cpu-ki-ichigo.lisp): at HARD `*iks-patient-p*` is T and `*iks-patient-forms*` is `(:base)`. So in the sealed form every style
mode is patient: it hovers and answers through the whiff punish / confirm and the timed Hoho, the episode never goes to the generic CPU
(`:iks-wait-max` is not read), and `:ptr3` / `:kessa` "hover too" (IKS-NEUTRAL). The hover band is the one thing a mode picks there, and
`*iks-bait-modes*` gives whiff, ptr3 and kessa the same bait band (2.3-2.7 m); space alone keeps `*iks-hover*`. The modes differ only in
the KESSA form and in the in-move steering, too little to move any descriptor. The opponent also sets the distance: Kenpachi's `none` keeps
71 % of the steps inside 3 m whatever Ichigo plays. P2's whole-game scores were outcomes, not behaviour.

**One rewrite tried** (not kept): `space2` = space + `:iks-retreat-p 1 :iks-gap-wait 7.5 :iks-getsuga-min 6.0 :range 1.3`: mean distance
+0.44 m vs K, +0.23 m vs H, still under +0.5.

**Two pre-registration flaws**, kept as registered: ptr3's descriptor sits near a ceiling (arm 0 is at pointer 3 for 0.70 of its steps), and
whiff's "mid" share is the wrong sign for a mode that hovers at 2.3-2.7 m at HARD. A whiff test on the timed Hoho or punish count would
need a new counter.

**Diagnostic at NORMAL** (`proof.py desc --dif normal`, the same seeds; `proof/ichigo-vs-*-normal.json`; not a proof, which is HARD). At
NORMAL both `*iks-patient-p*` and `*iks-bait-modes*` are NIL, and arm 0's mix is 0.88 generic.
- Every job arm now differs from arm 0 by a lot: mean distance +0.47 to +0.55 m vs K, +1.0 to +1.2 m vs H; pointer 3 +0.26 to +0.38.
  whiff, space and ptr3 pass their tests against both opponents. kessa fails vs K (awakened +0.040).
- But the modes do not separate from one another: whiff ~ space ~ ptr3 vs K, and whiff ~ space ~ kessa vs H.
- With patience off, what separates is style against generic, not mode against mode. Whiff and space then share `*iks-hover*`, and the
  rest of what tells the modes apart is small.

**What would make them one-job**: more than patience. A code cell would need to expose:
- patience as a number key (`:iks-patient` 0 / 1, through `style-knob`);
- the per-mode hover bands as `-lo` / `-hi` keys (KNOBS.md §6.4 lists `*iks-hover*` / `*iks-bait-hover*` as split candidates);
- possibly the space lunge's band.

That is game code (an Opus code cell, as PLAN4 §3 plans for Hisagi), outside this batch. The other route is to define Ichigo's jobs by what
does separate: generic brawl against the patient style, the KESSA form, and the pointer-2 Getsuga keep-away (`:iks-retreat-p` /
`:iks-getsuga-min`, PLAN4's targeted vs K arm).

## T0 (KI, Ichigo's side; `t0/t0-ki-ichigo.lisp`, `band.py t0 --or`, q 0.06, `:with d-x-ki-i`)

Written from these five arms as they stand, so it measures the switching, not the jobs. Bar A on seeds 501-540 against Kenpachi's T0, both
seats, 80 matches (`t0/bar-ki-501-540.json`):
- changes a match: median 12, mean 12.4, no match without one; 122.7 judgements a match;
- arm shares: all .029, whiff .047, space .040, ptr3 .464, kessa .420. **Only 2 arms at >= 10 %: fails.** ptr3's G3 job (his cells 0)
  fires on 89 % of judgements and kessa's G0 job on every awakened one, so they crowd out arm 0;
- in-job vs out-of-job share: whiff .172 / .009, space .127 / .000, ptr3 .521 / .000, kessa .956 / .000 (all pass x2);
- K.O. rate 1.00 (Ichigo wins 0.95 by K.O.).
