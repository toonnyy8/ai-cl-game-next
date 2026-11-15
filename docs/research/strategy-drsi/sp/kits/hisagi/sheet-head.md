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
- Kenpachi's Shikai J1 reaches **3.4 m** (2.4 + slide 0.8 + hurt), his Shikai lunge NS1a **5.7 m** (L0; L3 hits at 5.5 on the 0.5 m grid), his KYORAN lunge 4.9 m,
  Ichigo's NS3a rush **5.0 m**: these are what cover NAGI's band (`matchup-*.md`).
- After a cancel the *other* move's later hit windows still run: Hisagi's J1 cancelling Ichigo's slow NS1a (S22) still eats its hit at
  f22 unless TSUMUJI follows (X trials).

---

