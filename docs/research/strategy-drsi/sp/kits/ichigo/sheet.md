# Ichigo: the data sheet (PLAN4's kit study, step 1; 2026-11-15)

Generated from the kit by `sheet.lisp` (host ECL, no build), main c15f9a55. Below the line is the script's output; this header is
hand-written. The sim's real damage, routes and advantages are in `catalogue.md` (845 trials, `trials.lisp`); a frame-math number the sim
contradicts is marked there. The opponents' sheets (same script) are in `opp-sheets.md`.

```sh
E=/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl
$E --norc --load docs/research/strategy-drsi/sp/kits/ichigo/sheet.lisp -- ichigo base kessa
```

## What changed since the KI sheet (docs/research/ki-ai/ichigo/sheet.md, 2026-11-06)

- **SP costs the flash-step gauge** (DUEL_SP): every NS / AS segment pays at its start (column "SP cost"; route totals in each form's
  header), a segment in a cancel is refunded, J hits earn +10, SA hits +15, J / SA in a cancel +30. Regen stops at one cell (100), so 100 is
  the realistic neutral level. At 0 a later NS segment is refused: NS2's charges then never reach JUJISHO (catalogue G).
- **`*core-damage*` 0.42** scales every core kit's hit: dealt = base x kit x core :mult 1.3 x 0.42 (J1 32 -> 17). The old sheet's
  "dmg x mult" left it out; this one includes it (the sim agrees: catalogue A1, B1).
- **Waves are in the triangle** (DUEL_SP §6): JUJISHO (NS2c) and AS2b fire with their segment's class. A J or an SA cancels JUJISHO
  (refunded), an AS absorbs it, an NS is hit. The old "a wave beats every class at range" is gone (catalogue X3, X4, N1).
- **The exchange** (DUEL_CORE §2.1-§2.1.2): a cancel opens an exchange; the first real hit takes everything of the victim's gauge above
  100 (the attacker gains half); no Hoho while it is undecided; an NS segment's SA starts at once after a cancel.
- **AS1 RAKUGA steals 40** (was 120), KESSA's KUSARI-BIKI 15 a lash (was 30), and a steal may take the last cell.
- **Unbound in the core system**: K / L / U / I / O. The 月待 stance (`ic-tsuki`), KESSA's parry, ZANZO, the old K string and the grid
  are unreachable; pointer 4 (the Getsuga under SPIRIT DRIVE), J6 and the 超速 string were taken out again (DUEL_SUBLIMATION §16). Not
  catalogued. **No clone on a Step or a Hoho** in the core system (ichigo.lisp: 「Step 不再產生分身」; catalogue K16).
- **The stun tolerance is inert**: `*stun-blow-away*` NIL (tuning.lisp), so the 11-15-hit routes stay true combos on both opponents.
- The pointer switch (stick left / right + SP in an NS gap, after the awakening gauge was full once; DUEL_SP §3) exists but the trial
  player has no side stick: not catalogued.

## How to read the core moves

- **Buttons**: J = attack, Mod + J = SP, Space = Step, Mod + Space = Hoho, P = Burst, Mod + P = the awakening (DUEL_CORE §1).
- **J string (NA)**: five links, each needs a hit or a cancel. SP after a landed J is the **AS**, by press count `(1 1 2 2 3)`: J1 / J2 >
  AS1, J3 / J4 > AS2, J5 > AS3. The AS writes that pointer and ends the combo.
- **NS n** = SP from neutral under pointer n; its segments go on with a fresh SP, hit or not (from the end of the segment's active frames).
  A J in a segment's gap is the **SA** (super armour f6 to the end of its startup; at once after a cancel). The SA counts as one attack
  press, so SA J2 J3 + SP is AS2.
- **Pointer themes** (the stance shows the pointer): 1 the cleaver (heavy, close: NS1a S22, 3.0 m), 2 the Getsuga (two charges, then
  JUJISHO's 12 m wave; the charged SAs x1.4 / x1.7 for the rest of the string), 3 the rush (RANGETSU's 2.4 m lunge, 4.8 m).
- **Kikon**: hold the SP that lands (12 f after the hitstop). The Konpaku follow the pointer the SP started under (an AS's: before its
  write). A wave segment's hold (JUJISHO, AS2b) flash-steps in for the charged X. A non-red victim's attack cancels the follow-up.

## The key numbers (sheet, then the sim)

| | Shikai | KESSA |
|---|---|---|
| fastest opener | NS3a S18 (lunge) / J1 S14; J2-J4 S7 inside the string | **J1 S8** (the fastest bare J1 of the three: Kenpachi 9, Hisagi 14) |
| longest melee reach (sim, him standing) | NS3a hits at 4.8 m, misses 5.2; SA-g1 (NS2a's gap) 3.8 / 4.2; NS1a 3.0 / 3.2; J1 2.3 / 2.6 | AS1 whip line to 7.0 m (after a J only); NS3a's SA 4.6 m; NS1a 3.2 / 3.6; J1 2.0 vs Kenpachi only (Hisagi's hurt radius 0.36) |
| ranged | JUJISHO: 82 dealt, knockdown, 14 m/s, hits at 10 m; needs 80 SP (10 + 10 + 60) and ~57 f of charges | the black Getsuga: the same, 78 dealt |
| best routes (true combos) | NS2ab SA-g2 J2-J5 AS3abc **360** (2.0 m, ptr 2, 80 SP); NS1a-c SA J2-J5 AS3abc 286; NS1a SA J2-J5 AS3abc 233; J1-J5 AS3abc 202; NS3a SA J2-J5 AS3abc 197 (from 3.0 m) | NS2ab SA-g2 ... AS3abc 328; NS1a SA ... AS3abc 213; J1-J5 AS3abc 190 |
| knockdown enders | AS1 (+41, 1.8 m, steals 40), AS3c (+46, 1.8 m), AS2b launch (+69, 4.3 m) | AS3c (+41), AS2b (+79, 4.8 m) |
| SP routes (sheet) | NS 85 / 80 / 70, AS 20 / 45 / 90 | NS 75 / 80 / 30, AS 20 / 45 / 80 |
| walk / run | 4.2 / 10.0 m/s (Kenpachi 4.4 / 10.0, Hisagi 3.8 / 9.0) | 3.6 / 9.0 |
| taken x | 0.80 | 1.00 |

---

<!-- generated by docs/research/strategy-drsi/sp/kits/ichigo/sheet.lisp -- ichigo base kessa -->

## ICHIGO base

| | |
|---|---|
| walk / run | 4.2 / 10.0 m/s |
| Reishi | 1300 |
| x dealt (kit) / core :mult / taken | 1.00 / 1.30 / 0.80 |
| stun tolerance | 16.0 |
| Kikon Konpaku (base) | 2 |
| awakening | into kessa |
| passives | nil |
| :as-by-press | (1 1 2 2 3) |
| :ns-range (CPU) | (nil (3.6 6.6) nil) |
| stances by pointer | ic-st-heavy / ic-tsuki / ic-st-rush |
| Kikon cinematics by pointer | ic-heavy-kikon-cine / ic-kikon-cine / ic-rush-kikon-cine |
| SP route totals NS1 / NS2 / NS3 | 85 / 80 / 70 |
| SP route totals AS1 / AS2 / AS3 | 20 / 45 / 90 |

| Tag | Move | class | S/A/R | total hit / whiff | hits (frame: base dmg) | dmg x mult | last reaction / stun | hit adv | block adv | volume | touch d (/ + slide) | slide | super armour | SP cost | steal | params, on-frame |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 (NA) | `ic-j1` | na | 14/3/12 | 29 / 45 | 14–16:32 | 17 | flinch 18 | 3 | -2 | arc 1.40 m 100° | 1.75 / 2.35 | 0.6 | — | — | — |
| J2 (NA) | `ic-j2` | na | 7/3/13 | 23 / 39 | 7–9:32 | 17 | flinch 18 | 2 | -2 | arc 1.40 m 100° | 1.75 | — | — | — | — |
| J3 (NA) | `ic-na3` | na | 7/3/13 | 23 / 39 | 7–9:32 | 17 | flinch 18 | 2 | -2 | arc 1.40 m 100° | 1.75 | — | — | — | — |
| J4 (NA) | `ic-na4` | na | 7/3/12 | 22 / 38 | 7–9:34 | 19 | flinch 18 | 3 | -2 | arc 1.40 m 100° | 1.75 / 2.35 | 0.6 | — | — | — |
| J5 (NA) | `ic-j3` | na | 8/3/18 | 29 / 45 | 8–10:40 | 22 | stagger 26 | 5 | -4 | arc 1.44 m 200° | 1.79 | — | — | — | — |
| NS1a | `ic-n1a` | ns | 22/4/20 | 46 / 66 | 22–25:68 | 37 | stagger 26 | 2 | -3 | arc 2.70 m 150° | 3.05 | — | — | 25 | — |
| NS1b | `ic-n1b` | ns | 14/4/24 (enters f6) | 42 / 62 | 20–23:60 | 33 | stagger 26 | -2 | -3 | arc 2.70 m 90° | 3.05 | — | — | 25 | — |
| NS1c | `ic-n1c` | ns | 14/5/34 (enters f7) | 53 / 73 | 21–25:84 | 46 | crumple 40 | 1 | -20 | line 0.3–2.0 r0.35 | 2.35 / 3.95 | 1.6 | — | 35 | — |
| NS2a | `ic-n2a` | ns | 20/0/14 | 34 / 54 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA in NS2a's gap | `ic-sa-g1` | sa | 8/3/12 | 23 / 39 | 8–10:55 | 30 | flinch 18 | 3 | -2 | arc 2.40 m 100° | 2.75 / 4.15 | 1.4 | f6–7 | — | — |
| NS2b | `ic-n2b` | ns | 16/0/14 | 30 / 50 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA in NS2b's gap | `ic-sa-g2` | sa | 10/4/24 | 38 / 54 | 10–13:80 | 44 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | f6–9 | — | — |
| NS2c | `ic-n2c` | ns | 20/0/26 | 46 / 66 | WAVE 150 knockdown, 3.6 m wide, 14 m/s over 12 m, Kikon strike `ic-wave-strike` | 82 (wave) | — | — | — | — | — | — | — | 60 | — |
| NS2c wave Kikon strike | `ic-wave-strike` | ns | 10/4/24 | 38 / 54 | 10–13:80 | 44 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | — | — | — |
| NS3a | `ic-n3a` | ns | 18/12/18 | 48 / 68 | 18–18:18 21–21:18 24–24:18 27–29:18 | 39 | stagger 26 | 5 | -6 | arc 2.40 m 120° | 2.75 / 5.15 | 2.4 | — | 30 | — |
| NS3b | `ic-n3b` | ns | 18/4/30 | 52 / 72 | 18–21:100 | 55 | crumple 40 | 6 | -10 | arc 2.60 m 100° | 2.95 / 6.95 | 4.0 | — | 40 | — |
| SA (the kit's) | `ic-sa` | sa | 8/3/12 | 23 / 39 | 8–10:34 | 19 | flinch 18 | 3 | -2 | arc 2.40 m 100° | 2.75 / 4.15 | 1.4 | f6–7 | — | — |
| AS1a | `ic-as1` | as | 14/5/34 (enters f7) | 53 / 59 | 21–25:50 | 27 | knockdown down | — | -20 | line 0.3–2.0 r0.35 | 2.35 / 3.95 | 1.6 | f6–20 | 20 | 40 |
| AS2a | `ic-as2` | as | 18/4/26 | 48 / 54 | 18–21:50 | 27 | stagger 26 kb 2.5 | -4 | -14 | arc 2.60 m 140° | 2.95 / 7.95 | 5.0 | f6–17 | 20 | — |
| AS2b | `ic-as2b` | as | 12/0/34 | 46 / 52 | WAVE 60 launch, 3.0 m wide, 18 m/s over 6 m, Kikon strike `ic-wave-strike-as` | 33 (wave) | — | — | — | — | — | — | f6–11 | 25 | — |
| AS2b wave Kikon strike | `ic-wave-strike-as` | as | 10/4/24 | 38 / 54 | 10–13:80 | 44 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | f6–9 | — | — |
| AS3a | `ic-as3` | as | 8/3/18 | 29 / 35 | 8–10:45 | 25 | stagger 26 | 5 | -4 | arc 2.40 m 200° | 2.75 / 4.35 | 1.6 | f6–7 | 20 | — |
| AS3b | `ic-as3b` | as | 8/12/18 | 38 / 44 | 8–8:18 11–11:18 14–14:18 17–19:18 | 39 | stagger 26 | 5 | -6 | arc 2.40 m 120° | 2.75 / 5.15 | 2.4 | f6–7 | 30 | — |
| AS3c | `ic-as3c` | as | 18/4/30 | 52 / 58 | 18–21:100 | 55 | knockdown down | — | -10 | arc 2.60 m 100° | 2.95 / 6.95 | 4.0 | f6–17 | 40 | — |

Kikon / Soul Break Konpaku by pointer (CORE-KIKON-COUNT / CORE-SOUL-BREAK-COUNT, base 2):

| pointer | Kikon (not red) | Kikon (red) | Soul Break |
|---|---|---|---|
| 1 | 1 | 1 | 3 |
| 2 | 2 | 3 | 3 |
| 3 | 1 | 1 | 5 |

## ICHIGO kessa

| | |
|---|---|
| walk / run | 3.6 / 9.0 m/s |
| Reishi | 1300 |
| x dealt (kit) / core :mult / taken | 0.95 / 1.30 / 1.00 |
| stun tolerance | 16.0 |
| Kikon Konpaku (base) | 3 |
| awakening | this is it |
| passives | (parry-block) |
| :as-by-press | (1 1 2 2 3) |
| :ns-range (CPU) | nil |
| stances by pointer | ic-k-st-chain / ic-tsuki / ic-k-stance |
| Kikon cinematics by pointer | ic-chain-kikon-cine / ic-kessa-getsuga-cine / ic-kessa-kikon-cine |
| SP route totals NS1 / NS2 / NS3 | 75 / 80 / 30 |
| SP route totals AS1 / AS2 / AS3 | 20 / 45 / 80 |

| Tag | Move | class | S/A/R | total hit / whiff | hits (frame: base dmg) | dmg x mult | last reaction / stun | hit adv | block adv | volume | touch d (/ + slide) | slide | super armour | SP cost | steal | params, on-frame |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 (NA) | `ic-k-j1` | na | 8/3/12 | 23 / 39 | 8–10:30 | 16 | flinch 18 | 3 | -2 | arc 1.56 m 110° | 1.91 | — | — | — | — |
| J2 (NA) | `ic-k-j2` | na | 8/3/13 | 24 / 40 | 8–10:30 | 16 | flinch 18 | 2 | -2 | arc 1.56 m 110° | 1.91 | — | — | — | — |
| J3 (NA) | `ic-k-na3` | na | 8/3/12 | 23 / 39 | 8–10:30 | 16 | flinch 18 | 3 | -2 | arc 2.40 m 110° | 2.75 | — | — | — | — |
| J4 (NA) | `ic-k-na4` | na | 8/3/13 | 24 / 40 | 8–10:32 | 17 | flinch 18 | 2 | -2 | arc 2.80 m 110° | 3.15 | — | — | — | — |
| J5 (NA) | `ic-k-j3` | na | 9/3/18 | 30 / 46 | 9–11:40 | 21 | stagger 26 | 5 | -4 | arc 1.68 m 200° | 2.03 | — | — | — | — |
| NS1a | `ic-k-n1a` | ns | 22/4/18 | 44 / 64 | 22–25:60 | 31 | stagger 26 | 4 | — | arc 3.00 m 150° | 3.35 | — | — | 25 | — |
| NS1b | `ic-k-n1b` | ns | 14/4/18 | 36 / 56 | 14–17:55 | 29 | stagger 26 | 4 | — | arc 3.00 m 150° | 3.35 | — | — | 20 | — |
| NS1c | `ic-k-n1c` | ns | 18/5/26 | 49 / 69 | 18–22:80 | 41 | crumple 40 | 9 | — | arc 3.20 m 60° | 3.55 | — | — | 30 | — |
| NS2a | `ic-k-n2a` | ns | 20/0/14 | 34 / 54 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA in NS2a's gap | `ic-k-sa-g1` | sa | 8/3/12 | 23 / 39 | 8–10:55 | 29 | flinch 18 | 3 | -2 | arc 2.40 m 100° | 2.75 / 4.15 | 1.4 | f6–7 | — | — |
| NS2b | `ic-k-n2b` | ns | 16/0/14 | 30 / 50 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA in NS2b's gap | `ic-k-sa-g2` | sa | 10/4/24 | 38 / 54 | 10–13:80 | 41 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | f6–9 | — | — |
| NS2c | `ic-k-n2c` | ns | 20/0/26 | 46 / 66 | WAVE 150 knockdown, 3.6 m wide, 14 m/s over 12 m, Kikon strike `ic-k-wave-strike` | 78 (wave) | — | — | — | — | — | — | — | 60 | — |
| NS2c wave Kikon strike | `ic-k-wave-strike` | ns | 10/4/24 | 38 / 54 | 10–13:80 | 41 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | — | — | — |
| NS3a | `ic-k-n3a` | ns | 18/0/16 | 34 / 54 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA in NS3a's gap | `ic-k-sa` | sa | 10/3/12 | 25 / 41 | 10–12:50 | 26 | stagger 26 | 11 | -2 | arc 2.60 m 100° | 2.95 / 5.95 | 3.0 | f6–9 | — | — |
| NS3b | `ic-k-n3b` | ns | 14/0/16 | 30 / 50 | none | — | — | — | — | — | — | — | — | 10 | — |
| NS3c | `ic-k-n3c` | ns | 14/0/22 | 36 / 56 | none | — | — | — | — | — | — | — | — | 10 | — |
| SA (the kit's) | `ic-k-sa1` | sa | 8/3/12 | 23 / 39 | 8–10:34 | 18 | flinch 18 | 3 | -2 | arc 2.40 m 100° | 2.75 / 4.15 | 1.4 | f6–7 | — | — |
| AS1a | `ic-k-as1` | as | 12/18/20 | 50 / 56 | 12–12:14 16–16:14 20–20:14 25–29:14 | 29 | knockdown down | — | -14 | line 0.5–7.0 r0.30 | 7.35 | — | f6–11 | 20 | 15 |
| AS2a | `ic-k-as2` | as | 18/4/26 | 48 / 54 | 18–21:50 | 26 | stagger 26 kb 2.5 | -4 | -14 | arc 2.60 m 140° | 2.95 / 7.95 | 5.0 | f6–17 | 20 | — |
| AS2b | `ic-k-as2b` | as | 14/0/26 | 40 / 46 | WAVE 60 launch, 3.0 m wide, 18 m/s over 6 m, Kikon strike `ic-k-wave-strike-as` | 31 (wave) | — | — | — | — | — | — | f6–13 | 25 | — |
| AS2b wave Kikon strike | `ic-k-wave-strike-as` | as | 10/4/24 | 38 / 54 | 10–13:80 | 41 | stagger 26 | -2 | -3 | arc 2.40 m 90° | 2.75 / 4.15 | 1.4 | f6–9 | — | — |
| AS3a | `ic-k-as3` | as | 14/4/24 (enters f6) | 42 / 48 | 20–23:45 | 23 | stagger 26 | -2 | -3 | arc 2.70 m 90° | 3.05 | — | f6–19 | 20 | — |
| AS3b | `ic-k-as3b` | as | 8/3/18 | 29 / 35 | 8–10:45 | 23 | stagger 26 | 5 | -4 | arc 2.40 m 200° | 2.75 / 4.35 | 1.6 | f6–7 | 20 | — |
| AS3c | `ic-k-as3c` | as | 14/5/34 (enters f7) | 53 / 59 | 21–25:100 | 52 | knockdown down | — | -20 | line 0.3–2.0 r0.35 | 2.35 / 3.95 | 1.6 | f6–20 | 40 | — |
| clone cut | `ic-c-light` | — | 8/3/12 | 23 / 39 | 8–10:26 | 13 | flinch 18 | 3 | — | arc 2.40 m 110° | 2.75 | — | — | — | — |
| clone cut | `ic-c-xa` | — | 8/3/16 | 27 / 47 | 8–10:55 | 29 | stagger 26 | 7 | — | arc 2.80 m 120° | 3.15 | — | — | — | — |
| clone cut | `ic-c-xb` | — | 8/3/16 | 27 / 47 | 8–10:55 | 29 | stagger 26 | 7 | — | arc 2.80 m 120° | 3.15 | — | — | — | — |

Kikon / Soul Break Konpaku by pointer (CORE-KIKON-COUNT / CORE-SOUL-BREAK-COUNT, base 3):

| pointer | Kikon (not red) | Kikon (red) | Soul Break |
|---|---|---|---|
| 1 | 2 | 2 | 4 |
| 2 | 3 | 4 | 4 |
| 3 | 2 | 2 | 5 |

Columns: S = startup from the move's entry frame (a string link may enter its clip late, (enters f6): its hit frames stay in clip frames); total = S + A + R from the entry frame (a hit / a whiff: R + `*whiff-extra*` + kind's `*whiff-add*`); hit adv = the last window's stun - the frames he has left after it (nothing following, hitstop freezes both); touch d = the volume's far edge + 0.35 m (the default hurt radius), then + the move's slide; super armour = a turn move (AS / SA) from move frame 6 to the end of its startup (DUEL_CORE §2). Dmg x mult = base x kit x core :mult x `*core-damage*` (0.42), before his taken x, combo scaling, the SP shortfall scale and SUBLIMATION (the sim's damage: catalogue.md).

## Shared rules (tuning.lisp, read at generation)

| Rule | Value |
|---|---|
| hitstun by reaction | (:flinch 18 :stagger 26 :knockback 30 :launch 0 :knockdown 0 :guard-break 50 :crumple 40 :down 30 :wakeup 30) |
| counter-hit stun | +10 |
| hitstop light / heavy / block | 4 / 8 / 3 |
| whiff recovery | R + 6, + (:quick 8 :flash 8 :kikon 8) by kind |
| input buffer | 10 f |
| Step | 2.5 m over 24 f, invulnerable f3–9, J cancels it from f12 |
| Hoho | 100 SP (flash step), 24 f, invulnerable f1–14, reappears f6 1.6 m behind him; perfect = counter swing f10, strike f14; lockout 60 f; resumes a combo within 12 f; never while an exchange is open (DUEL_CORE §2.1.2) |
| flash-step (SP) gauge | 0–300, cells of 100; regen 4.5/s after 60 f only below one cell; taken x0.135 of damage |
| SP gains | J hit +10, SA hit +15, J / SA in a cancel +30; NS / AS / Kikon 0 |
| SP cost rule | dmg x 0.4 rounded to 5, 10–60; paid at the segment start; refunded if the segment takes part in a cancel; short: damage x (0.5 + 0.5 paid / cost); a later NS segment refused at 0 (NSa and every AS start at 0) |
| breakthrough | the first real hit in an exchange takes 100 % of the victim's SP above 100, the attacker gains 50 % of it |
| AS1 steal | per hit, may take the last cell, attacker gains 50 % |
| Burst | needs 100 SP; WHITE (neutral) / BLUE (reeling after hit 2) / ORANGE (in a move that hit); push 5.0 m, invulnerable 20 f; drain 54/s (BLUE burns one cell); SP attacks free while it runs; ORANGE cuts the next move's startup by 40 % for 12 f |
| awakening | gauge 100: x0.035 dealt, x0.049 taken, 10.5 a Konpaku lost; heals 20 % Reishi |
| Kikon follow-up | hold confirmed 12 f after the hitstop; knockback 2.5 m, reel 16 f, the strike 24 f after a non-red victim could act; a non-red victim's attack cancels it |
| pointer | 1–4, Kikon max 4, Soul Break max 5 |
| arena radius | 15.0 m |
