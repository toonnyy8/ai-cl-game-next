# Hisagi: the data sheet (PLAN4 step 1, 2026-11-15)

The order the user set (2026-10-25, DEVLOG §369; again 2026-11-15: 「你探索每個人物的時候請依據遊戲系統與該人物的特色、幀數表、攻擊範圍等等進行規劃」):
data sheet → sim-verified catalogue (`catalogue.md`) → strategies the user picks (`strategies.md`) → CPU. Below this header, the tables
are generated from the kit by `sheet.lisp` (host, no build; main at c15f9a55):

    E=/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl; D=docs/research/strategy-drsi/sp/kits/hisagi
    (cat $D/sheet-head.md; $E --norc --load $D/sheet.lisp -- hisagi base bankai bankai-bind | grep -v '^;;; ') > $D/sheet.md
    $E --norc --load $D/sheet.lisp -- kenpachi base nozarashi bankai bankai-2 > opp-sheets.md   (and -- ichigo base kessa, appended)

The opponents' rows (Kenpachi sealed / Shikai / both Bankai, Ichigo Shikai / KESSA) are in `opp-sheets.md`, same script.

## What the sheet says, in one screen (sim-checked numbers in brackets: `catalogue.md`, `tables.md`)

Damage dealt = base x the form's x (kit x `*core-damage*` 0.42 x `:core :mult` 1.7): Shikai x0.821, both Bankai modes x0.714, against
Kenpachi's x0.504 and Ichigo's x0.546 (Ichigo's Shikai takes x0.8). Hisagi hits harder per hit than either opponent and takes x1.0 in
every form.

**Shikai (`:base`)**, walk 3.8 / run 9.0 m/s:
- J1 S14 (Kenpachi's sealed J1 S9, his Shikai's S9, Ichigo's S14, KESSA's S8), reach 1.7 + slide 0.3 [hits 1.0-2.4 m]. J2-J4 S8, J5 S9
  ender. J1-J5 +5 at 2.5 m, no SP [118 dmg vs sealed Kenpachi].
- **NS1a NAGI** S20, a 90° arc to 6.0 m with a **3.0 m dead zone** (`:min-reach`) [3.0-6.4 m, 51]; NS1b / NS1c sweep the same volume,
  stagger, NS1abc -13 at any distance in the band [163]. The only Shikai move that reaches past 5.2 m.
- **NS2a TAN-GARI** S16, reach 2.5 + slide 1.0 [1.0-3.8 m, 37]; NS2abc ends in a 360° knockdown [148, +59].
- **NS3a SHIBARI** S18, a 4.5 m line (r 0.35), **no dead zone**, a 40 f bind (+10 on hit) [1.0-5.2 m, 33]; its gap's SA YOSE drags him to
  1.6 m, then J2-J5 AS3abc [286 from 4.0 m]; NS3b CHIKUDEN + SA HODEN (x2.0 at 1.6 m, x1.0 at 6.5 m) [117 at 4.0, 134 at 2.0]; a
  CHIKUDEN with no HODEN or AS3c leaves 餘電 ZANDEN (+8 a J / NS / AS hit for 480 f).
- SA KIRI (every gap but NS3a's) S10, reach 2.4 + slide 1.4 [reaches from NAGI at 3.5 m, not 4.5 m].
- AS by press (1 1 2 2 3): AS1 TSUMUJI (hop back to 4.5 m, four cuts along the chain, steals 5 / 10 / 15 / 20, knockdown) [J1 AS1 77,
  ends 5.5 m, +56]; AS2 KO-GARI > KARI-AGE (launch) [J1-J3 AS2ab 161, +80]; AS3 MATOI > TAME > TSUZURI RAIDEN (6.5 m line, sets ZANDEN)
  [J1-J5 AS3abc 274, +53, 2.9 m].
- SP costs (DUEL_SP §4): NS1 25 / 20 / 30, NS2 20 / 20 / 35, NS3 15 / 10, AS1 25, AS2 20 / 25, AS3 20 / 15 / 45; Hoho 100.
- Kikon (base 2): ptr 1 / 3 take 1 Konpaku, ptr 2 takes 2 (3 on a red victim); Soul Break 3 / 3 / 5.

**Bankai ranged mode (`:bankai`, the awakening)**, walk 2.8 / run 8.5 m/s (the slowest walk of any form):
- J1 SENBEN S14, 3.0-6.0 m annulus [3.0-6.4 m]; the **chain tip** (the outer 0.5 m of a volume: 5.5-6.4 for J) deals x1.71 and ignores
  combo scaling [J1 14 → 23]; J1-J5 from the tip 110, from 4.5 m 57.
- NS1a WA S14, 360° 0-3.0 m, pushes him to 4.5 m [1.0-3.4 m, 19]: the only close-in move, and the only 360° neutral move of any of his
  forms. NS1abc [75, +41, ends 5.5 m].
- NS2a TABA S25 (from its :enter), a 4.15 m line, 2.5 m dead zone [2.5-4.9 m, tip 4.0-4.9: 36 → 61]; NS2a SA-g J2s AS2ab from the tip
  [**308**: the biggest route in the kit].
- AS3 NAGE > MAKI > KAKE: a real KAKE hit arms the **bind** (the form switch to `:bankai-bind`) [J1-J5 AS3abc 233 → bind, 2.0 m].
- Every 散 (pointer 1) move but WA has a 3.0 m dead zone, every 聚 (pointer 2) move 2.5 m; §29: a cancel he takes part in unlocks the
  dead zones for the route out of it (at x0.5 damage).

**Bankai bind mode (`:bankai-bind`)**, walk 3.8: J1 S14 1.5 m [1.0-2.2 m; x1.3 within 1.2 m at the hit: pressed from 1.4 m or nearer, the slide closes the rest]; NS1a KAGIYOSE S18, the hook along the chain
to 6.0 m, drags him to 1.5 m [1.0-6.7 m]; NS2a MATOI S20 line 2.6 m [1.0-3.3 m]; SA HIKIYOSE drags him to 1.5 m from anywhere; AS3
releases [J1-J5 AS3abc 271, back to the ranged mode]. **A cancel inside the bind evens 25 % of the Reishi gap** (half each way)
[300 vs 1300: 300 → 425, 1300 → 1175, `B` trials].

**Shared**: hitstop J 4 / else 8; a whiff recovers R + 6 + 8 (J / K kind); Step 2.5 m / 24 f (iframes 3-9; the ranged Step lands on a tip
band, 1.75-2.5 m); Hoho 24 f (iframes 1-14), reappears 1.6 m behind him, 100 SP, no Hoho while an exchange is undecided (DUEL_CORE §2.1.2).

### Corrections the sim made to the frame math / data reading

- NS3a's "4.5 m line" reaches **5.2 m** (line + radius + his hurt radius); KAGIYOSE's 6.0 m hook reaches **6.7 m**; NAGI's 6.0 m arc
  reaches **6.4 m** (vs Ichigo 6.3). Ranged J1's tip read is the centre distance: x1.71 from 5.5 m to its far edge 6.4 m [5.4 m: 14, 5.5 m: 23]; TABA's from 4.0 m.
- The CPU's `:ns-range` for NAGI is (3.6 6.2): the sim's band is 3.0-6.4 m.
- NS1a > SA KIRI combos only from **≤ 3.5 m** (from 4.5 m KIRI whiffs at 3.24 m, then -19).
- Ranged J1-J3 > AS2ab from the tip (5.8 m) **drops AS2** (its 2.5-4.5 m band): 63 dmg, -65; from 4.5 m it combos (127, +49).
- Kenpachi's Shikai J1 reaches **3.4 m** (2.4 + slide 0.8 + hurt), his Shikai lunge NS1a **5.7 m** (L0 = L3), his KYORAN lunge 4.9 m,
  Ichigo's NS3a rush **5.0 m**: these are what cover NAGI's band (`matchup-*.md`).
- After a cancel the *other* move's later hit windows still run: Hisagi's J1 cancelling Ichigo's slow NS1a (S22) still eats its hit at
  f22 unless TSUMUJI follows (X trials).

---

<!-- generated by docs/research/strategy-drsi/sp/kits/hisagi/sheet.lisp -- hisagi base bankai bankai-bind -->

## HISAGI base

| | |
|---|---|
| walk / run | 3.8 / 9.0 m/s |
| dealt x (kit x *core-damage* x :core :mult) / taken | 0.821 (1.15 x 0.42 x 1.70) / 1.00 |
| Kikon Konpaku base | 2 |
| awakening | into bankai |
| :as-by-press / :as-writes | (1 1 2 2 3) / (1 2 3) |
| CPU reads (:ns-range / :range) | ((3.6 6.2) nil nil) / nil |
| push reach (K ender) | 6.0 |

| Tag | Move | class | S/A/R (e = enter) | S eff | whiff R | hit windows (frame dmg reaction stun, min = dead zone m) | dmg x mult | hit adv (last window) | block adv | first volume | motion | SP cost | flags, params |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 (NA) | `hs-j1` | na | 14/3/12 | 14 | 28 | f14-16 30 flinch 18 | 25 | 3 | -2 | arc 1.70 m 110° (reach 1.70) | slide 0.3 | free |  |
| J2 (NA) | `hs-j2` | na | 8/3/13 | 8 | 29 | f8-10 30 flinch 18 | 25 | 2 | -2 | arc 1.70 m 110° (reach 1.70) |  | free |  |
| J3 (NA) | `hs-na3` | na | 8/3/12 | 8 | 28 | f8-10 30 flinch 18 | 25 | 3 | -2 | arc 1.70 m 110° (reach 1.70) | slide 0.3 | free |  |
| J4 (NA) | `hs-na4` | na | 8/3/13 | 8 | 29 | f8-10 30 flinch 18 | 25 | 2 | -2 | arc 1.70 m 110° (reach 1.70) |  | free |  |
| J5 (NA) | `hs-j3` | na | 9/3/18 | 9 | 34 | f9-11 38 stagger 26 | 31 | 5 | -4 | arc 1.70 m 200° (reach 1.70) |  | free | ender  |
| J link (from `hs-sa-kiri`) | `hs-sa-kiri` | sa | 10/3/12 | 10 | 28 | f10-12 40 stagger 26 | 33 | 11 | -2 | arc 2.40 m 110° (reach 2.40) | slide 1.4 | free |  |
| J link (from `hs-sa`) | `hs-sa` | sa | 10/3/12 | 10 | 28 | f10-12 40 stagger 26 | 33 | 11 | -2 | arc 2.40 m 110° (reach 2.40) | slide 1.4 on-frame (f0 hs-yose) | free | :pull 1.6 |
| J link (from `hs-sa-hoden`) | `hs-sa-hoden` | sa | 10/3/24 | 10 | 40 | f10-12 60 stagger 26 | 49 | -1 | -14 | chain to him (hs-core-seg) |  | free | :hoden |
| J link (from `hs-k1`) | `hs-k1` | na | 18/4/22 | 18 | 42 | f18-21 62 stagger 26 min 3.0 | 51 | 0 | -3 | arc 6.00 m 90° (reach 6.00) |  | free | ranged no-close  |
| J link after `hs-k1` | `hs-j2k` | na | 14/3/13 | 14 | 29 | f14-16 30 flinch 18 | 25 | 2 | -6 | arc 1.70 m 110° (reach 1.70) |  | free |  |
| J link (from `hs-k2`) | `hs-k2` | na | 20/4/24 e6 | 14 | 44 | f20-23 56 stagger 26 | 46 | -2 | -3 | chain to him (hs-foe-seg) |  | free | ranged  |
| J link after `hs-k2` | `hs-j3k` | na | 14/3/18 | 14 | 34 | f14-16 38 stagger 26 | 31 | 5 | -6 | arc 1.70 m 200° (reach 1.70) |  | free | ender  |
| J link (from `hs-j1-1h`) | `hs-j1-1h` | na | 14/3/12 | 14 | 28 | f14-16 24 flinch 18 | 20 | 3 | -2 | arc 1.70 m 110° (reach 1.70) | slide 0.3 | free | :one-hand |
| J link after `hs-j1-1h` | `hs-j2-1h` | na | 8/3/13 | 8 | 29 | f8-10 24 flinch 18 | 20 | 2 | -2 | arc 1.70 m 110° (reach 1.70) |  | free | :one-hand |
| J link after `hs-j2-1h` | `hs-j3-1h` | na | 9/3/18 | 9 | 34 | f9-11 30 stagger 26 | 25 | 5 | -4 | arc 1.70 m 200° (reach 1.70) |  | free | ender :one-hand |
| NS1a | `hs-n1a` | ns | 20/4/22 | 20 | 42 | f20-23 62 stagger 26 min 3.0 | 51 | 0 | -3 | arc 6.00 m 90° (reach 6.00) |  | 25 | ranged no-close  |
| NS1b | `hs-n1b` | ns | 20/4/24 e6 | 14 | 44 | f20-23 56 stagger 26 min 3.0 | 46 | -2 | -3 | arc 6.00 m 90° (reach 6.00) |  | 20 | ranged no-close  |
| NS1c | `hs-n1c` | ns | 24/5/34 e8 | 16 | 54 | f24-28 80 stagger 26 min 3.0 | 66 | -13 | -20 | arc 6.00 m 90° (reach 6.00) |  | 30 | ranged no-close  |
| NS2a | `hs-n2a` | ns | 16/3/13 | 16 | 33 | f16-18 45 stagger 26 | 37 | 10 | -2 | arc 2.50 m 110° (reach 2.50) | slide 1.0 | 20 |  |
| NS2b | `hs-n2b` | ns | 12/3/12 | 12 | 32 | f12-14 50 stagger 26 | 41 | 11 | -2 | arc 1.70 m 110° (reach 1.70) |  | 20 |  |
| NS2c | `hs-n2c` | ns | 16/3/18 | 16 | 38 | f16-18 85 knockdown | 70 | down | -4 | arc 3.00 m 360° (reach 3.00) |  | 35 |  |
| NS3a | `hs-n3a` | ns | 18/4/26 | 18 | 46 | f18-21 40 bind 40 | 33 | 10 | -14 | line 4.50 m r0.35 (reach 4.50) |  | 15 | :sa hs-sa |
| NS3b | `hs-n3b` | ns | 20/4/24 e6 | 14 | 44 | f20-23 25 stagger 26 | 21 | -2 | -3 | chain to him (hs-core-seg) |  | 10 | ranged :sa hs-sa-hoden :zan pend |
| AS1a | `hs-as1` | as | 14/16/20 | 14 | 26 | f14-14 16 flinch 18 steal 5; f18-18 16 flinch 18 steal 10; f22-22 16 flinch 18 steal 15; f26-28 16 knockdown steal 20 | 53 | down | -3 | chain to him (hs-core-seg) |  on-frame (f0 hs-as1-hop) | 25 | :steal-fs 5 |
| AS2a | `hs-as2` | as | 8/3/13 | 8 | 19 | f8-10 45 stagger 26 | 37 | 10 | -2 | arc 2.40 m 110° (reach 2.40) | slide 1.4 | 20 |  |
| AS2b | `hs-as2b` | as | 9/3/18 | 9 | 24 | f9-11 60 launch | 49 | down | -4 | arc 2.40 m 200° (reach 2.40) |  | 25 |  |
| AS3a | `hs-as3` | as | 9/3/18 | 9 | 24 | f9-11 45 stagger 26 | 37 | 5 | -4 | arc 2.40 m 200° (reach 2.40) | slide 1.4 | 20 |  |
| AS3b | `hs-as3b` | as | 20/4/24 e6 | 14 | 30 | f20-23 35 stagger 26 | 29 | -2 | -3 | chain to him (hs-core-seg) |  | 15 | ranged  |
| AS3c | `hs-as3c` | as | 16/3/24 | 16 | 30 | f16-18 110 knockdown | 90 | down | -14 | line 6.50 m r0.30 (reach 6.50) |  | 45 | ranged :zan set |

Kikon / Soul Break Konpaku by pointer (base 2): ptr 1 Kikon 1 (red 1), Soul Break 3; ptr 2 Kikon 2 (red 3), Soul Break 3; ptr 3 Kikon 1 (red 1), Soul Break 5.

## HISAGI bankai (awakened)

| | |
|---|---|
| walk / run | 2.8 / 8.5 m/s |
| dealt x (kit x *core-damage* x :core :mult) / taken | 0.714 (1.00 x 0.42 x 1.70) / 1.00 |
| Kikon Konpaku base | 3 |
| awakening | this is it |
| :as-by-press / :as-writes | (1 1 2 2 3) / (1 2 nil) |
| CPU reads (:ns-range / :range) | nil / (3.0 4.5) |
| push reach (K ender) | 7.5 |

| Tag | Move | class | S/A/R (e = enter) | S eff | whiff R | hit windows (frame dmg reaction stun, min = dead zone m) | dmg x mult | hit adv (last window) | block adv | first volume | motion | SP cost | flags, params |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 (NA) | `hs-r-j1` | na | 14/3/12 | 14 | 28 | f14-16 19 flinch 24 min 3.0 | 14 | 9 | -2 | arc 6.00 m 100° (reach 6.00) |  | free | ranged no-close  |
| J2 (NA) | `hs-r-j2` | na | 10/3/13 | 10 | 29 | f10-12 16 flinch 24 min 3.0 | 11 | 8 | -2 | arc 6.00 m 100° (reach 6.00) |  | free | ranged  |
| J3 (NA) | `hs-r-na3` | na | 10/3/13 | 10 | 29 | f10-12 16 flinch 24 min 3.0 | 11 | 8 | -2 | arc 6.00 m 100° (reach 6.00) |  | free | ranged  |
| J4 (NA) | `hs-r-na4` | na | 10/3/13 | 10 | 29 | f10-12 16 flinch 24 min 3.0 | 11 | 8 | -2 | arc 6.00 m 100° (reach 6.00) |  | free | ranged  |
| J5 (NA) | `hs-r-j3` | na | 10/3/18 | 10 | 34 | f10-12 22 stagger 26 min 3.0 | 16 | 5 | -4 | arc 6.00 m 100° (reach 6.00) |  on-land hs-r-j3-push | free | ender ranged  |
| J link (from `hs-r-sa`) | `hs-r-sa` | sa | 10/3/13 | 10 | 29 | f10-12 30 stagger 26 min 3.0 | 21 | 10 | -2 | arc 6.00 m 100° (reach 6.00) |  | free | ranged  |
| J link (from `hs-r-sa-g`) | `hs-r-sa-g` | sa | 13/3/16 | 13 | 32 | f13-15 45 stagger 26 min 2.5 | 32 | 7 | -2 | arc 4.50 m 90° (reach 4.50) |  | free | ranged :as-ptr 1 |
| J link (from `hs-r-j2s`) | `hs-r-j2s` | na | 19/3/16 | 19 | 32 | f19-21 29 flinch 24 min 2.5 | 21 | 5 | -2 | arc 4.50 m 90° (reach 4.50) |  | free | ranged :as-ptr 2 |
| J link after `hs-r-j2s` | `hs-r-j3g` | na | 19/3/21 | 19 | 37 | f19-21 39 stagger 26 min 2.5 | 28 | 2 | -4 | arc 4.50 m 90° (reach 4.50) |  on-land hs-r-j3-push | free | ender ranged :as-ptr 3 |
| NS1a | `hs-r-n1a` | ns | 14/3/18 | 14 | 38 | f14-16 26 stagger 26 | 19 | 5 | -4 | arc 3.00 m 360° (reach 3.00) |  on-land hs-r-wa-push | 10 | ranged :no-tip |
| NS1b | `hs-r-n1b` | ns | 21/4/24 e4 | 17 | 44 | f21-24 31 stagger 26 min 3.0 | 22 | -2 | -3 | arc 6.00 m 60° (reach 6.00) |  | 10 | ranged  |
| NS1c | `hs-r-n1c` | ns | 21/5/34 e7 | 14 | 54 | f21-25 48 knockdown min 3.0 | 34 | down | -20 | arc 6.00 m 160° (reach 6.00) |  | 20 | ranged  |
| NS2a | `hs-r-n2a` | ns | 30/10/27 e5 | 25 | 47 | f30-33 50 stagger 38 min 2.5 | 36 | 1 | -3 | line 4.15 m r0.35 (reach 4.15) |  | 20 | ranged :sa hs-r-sa-g :gather |
| NS2b | `hs-r-n2b` | ns | 30/10/27 e9 | 21 | 47 | f30-33 57 stagger 40 | 41 | 3 | -3 | arc 3.00 m 90° (reach 3.00) |  on-land hs-r-tataki-push | 25 | ranged :sa hs-r-sa-g :gather :no-tip |
| NS2c | `hs-r-n2c` | ns | 30/5/37 e7 | 23 | 57 | f30-34 86 knockdown min 2.5 | 61 | down | -20 | arc 4.50 m 360° (reach 4.50) |  | 35 | ranged :gather |
| AS1a | `hs-r-as1` | as | 21/5/34 e6 | 15 | 40 | f21-25 43 knockdown min 3.0 | 31 | down | -20 | arc 6.00 m 160° (reach 6.00) |  | 15 | ranged  |
| AS2a | `hs-r-as2` | as | 30/10/27 e9 | 21 | 33 | f30-33 57 stagger 36 min 2.5 | 41 | -1 | -3 | arc 4.50 m 90° (reach 4.50) |  | 25 | ranged :gather |
| AS2b | `hs-r-as2b` | as | 30/10/27 e12 | 24 | 33 | f36-39 70 knockdown min 2.5 | 50 | down | -3 | line 4.15 m r0.35 (reach 4.15) |  | 30 | ranged :gather |
| AS3a | `hs-r-as3` | as | 18/4/30 | 18 | 36 | f18-21 30 stagger 30 | 21 | -4 | -20 | line 7.00 m r0.35 (reach 7.00) |  | 10 | ranged no-close :no-kikon |
| AS3b | `hs-r-as3b` | as | 27/10/24 e12 | 15 | 30 | f27-30 30 stagger 26 | 21 | -8 | -3 | chain to him (hs-r-link-seg) |  | 10 | ranged :no-kikon |
| AS3c | `hs-r-as3c` | as | 24/4/30 e8 | 16 | 36 | f24-27 40 stagger 30 | 29 | -4 | -20 | chain to him (hs-r-link-seg) |  | 15 | ranged no-close :no-kikon :bind-start |

Kikon / Soul Break Konpaku by pointer (base 3): ptr 1 Kikon 2 (red 2), Soul Break 4; ptr 2 Kikon 3 (red 4), Soul Break 4.

## HISAGI bankai-bind (awakened)

| | |
|---|---|
| walk / run | 3.8 / 9.0 m/s |
| dealt x (kit x *core-damage* x :core :mult) / taken | 0.714 (1.00 x 0.42 x 1.70) / 1.00 |
| Kikon Konpaku base | 3 |
| awakening | this is it |
| :as-by-press / :as-writes | (1 1 2 2 3) / (1 2 nil) |
| CPU reads (:ns-range / :range) | nil / nil |
| push reach (K ender) | 2.95 |

| Tag | Move | class | S/A/R (e = enter) | S eff | whiff R | hit windows (frame dmg reaction stun, min = dead zone m) | dmg x mult | hit adv (last window) | block adv | first volume | motion | SP cost | flags, params |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 (NA) | `hs-b-na1` | na | 14/3/12 | 14 | 28 | f14-16 32 flinch 18 | 23 | 3 | -2 | arc 1.50 m 110° (reach 1.50) | slide 0.3 | free |  |
| J2 (NA) | `hs-b-na2` | na | 8/3/13 | 8 | 29 | f8-10 32 flinch 18 | 23 | 2 | -2 | arc 1.50 m 110° (reach 1.50) |  | free |  |
| J3 (NA) | `hs-b-na3` | na | 8/3/12 | 8 | 28 | f8-10 32 flinch 18 | 23 | 3 | -2 | arc 1.50 m 110° (reach 1.50) | slide 0.3 | free |  |
| J4 (NA) | `hs-b-na4` | na | 8/3/13 | 8 | 29 | f8-10 32 flinch 18 | 23 | 2 | -2 | arc 1.50 m 110° (reach 1.50) |  | free |  |
| J5 (NA) | `hs-b-na5` | na | 9/3/18 | 9 | 34 | f9-11 40 stagger 26 | 29 | 5 | -4 | arc 1.50 m 200° (reach 1.50) |  | free | ender  |
| J link (from `hs-b-sa`) | `hs-b-sa` | sa | 10/3/12 | 10 | 28 | f10-12 40 stagger 26 | 29 | 11 | -2 | arc 1.50 m 110° (reach 1.50) | slide 0.3 on-frame (f0 hs-b-yose) | free |  |
| NS1a | `hs-b-n1a` | ns | 18/4/20 | 18 | 40 | f18-21 35 stagger 26 | 25 | 2 | -3 | chain to him (hs-b-hook-seg) |  on-land hs-b-hook | 15 |  |
| NS1b | `hs-b-n1b` | ns | 20/4/24 e8 | 12 | 44 | f20-23 45 stagger 26 | 32 | -2 | -3 | arc 2.80 m 140° (reach 2.80) |  | 20 |  |
| NS1c | `hs-b-n1c` | ns | 14/3/18 | 14 | 38 | f14-16 75 knockdown | 54 | down | -4 | arc 1.50 m 200° (reach 1.50) |  | 30 |  |
| NS2a | `hs-b-n2a` | ns | 20/4/20 | 20 | 40 | f20-23 40 stagger 26 | 29 | 2 | -3 | line 2.60 m r0.35 (reach 2.60) |  on-land hs-b-drag | 15 |  |
| NS2b | `hs-b-n2b` | ns | 20/4/24 e4 | 16 | 44 | f20-23 60 stagger 26 | 43 | -2 | -3 | arc 2.80 m 140° (reach 2.80) |  | 25 |  |
| NS2c | `hs-b-n2c` | ns | 22/5/34 e4 | 18 | 54 | f22-26 95 knockdown | 68 | down | -20 | arc 3.00 m 120° (reach 3.00) |  | 40 |  |
| AS1a | `hs-b-as1` | as | 18/4/20 | 18 | 26 | f18-21 55 knockdown | 39 | down | -3 | chain to him (hs-b-hook-seg) |  on-land hs-b-hook | 20 |  |
| AS2a | `hs-b-as2` | as | 20/4/24 e4 | 16 | 30 | f20-23 55 stagger 26 | 39 | -2 | -3 | arc 2.80 m 140° (reach 2.80) |  | 20 |  |
| AS2b | `hs-b-as2b` | as | 22/5/34 e8 | 14 | 40 | f22-26 70 launch | 50 | down | -20 | arc 3.00 m 120° (reach 3.00) |  | 30 |  |
| AS3a | `hs-b-as3` | as | 20/4/24 e6 | 14 | 30 | f20-23 40 stagger 26 | 29 | -2 | -3 | arc 2.80 m 140° (reach 2.80) |  | 15 | :no-kikon |
| AS3b | `hs-b-as3b` | as | 9/3/18 | 9 | 24 | f9-11 40 stagger 26 | 29 | 5 | -4 | arc 3.00 m 200° (reach 3.00) |  | 15 | :no-kikon |
| AS3c | `hs-b-as3c` | as | 18/4/28 | 18 | 34 | f18-21 100 knockdown | 71 | down | -14 | arc 3.00 m 140° (reach 3.00) |  | 40 | :no-kikon :bind-end |

Kikon / Soul Break Konpaku by pointer (base 3): ptr 1 Kikon 2 (red 2), Soul Break 4; ptr 2 Kikon 3 (red 4), Soul Break 4.

Shared rules (tuning.lisp): stun by reaction (:flinch 18 :stagger 26 :knockback 30 :launch 0 :knockdown 0 :guard-break 50 :crumple 40 :down 30 :wakeup 30); hitstop J 4 / other 8; whiff R = R + 6, + (:quick 8 :flash 8 :kikon 8) by kind; a block adds (:quick 4 :flash 6 :kikon 6); a J link opens on a hit from S+A (on a block only the last 3 f of R).

Turn moves (AS / SA) carry super armour from move frame 6 to the end of their startup (DUEL_CORE §2). Combo scaling: hits 1-3 full, then -0.15 a hit, floor 0.20; SP and the ranged tip hits unscaled. SP: cost = dmg x 0.4 rounded to 5, 10-60; fs max 300, Hoho 100 (lockout 60 f), J hit +10, SA hit +15, an ATK in a cancel +30, breakthrough takes all above 100 (gain x0.5). Step 2.5 m / 24 f (iframes (3 9)); Hoho 24 f (iframes (1 14)), reappears 1.6 m behind.
