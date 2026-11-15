# Kenpachi vs Hisagi: the matchup table (PLAN4 kit study, step 2, 2026-11-15)

Every cell cites `trials.lisp` entries (results in `catalogue.md`; both kits' rows in `sheet.md` and `opp-data.md`). Distances centre to
centre (Hisagi's hurt radius 0.36 m, Kenpachi's 0.45 m). "H" = Hisagi's Shikai, "Hr" = his Bankai ranged mode, "Hb" = his Bankai bind
mode (it reverts to ranged by itself after ~30-60 ticks). Every Hisagi form takes x1.0 and hits with `:core :mult 1.7`: **per base point he
deals about 1.5x what Kenpachi deals** (his NS1a 51 off Kenpachi, Kenpachi's NS1a 33 off him).

## Distance bands

| Band | Out-ranges | Out-speeds | What happens | Trials |
|---|---|---|---|---|
| **0-2.4 m** | both J (his J1 2.4, bind J1 2.2) | my sealed J1 S9 vs his S14; my NS1a S14 vs his NS2a S16 | my J1 and NS1a first; his Shikai NS1a and ranged J1 are **dead under 3.0 m** (a whiff I punish with anything, W) | T, Q / E |
| **2.4-2.6 m** | **only my J** (sealed 2.6, Shikai 3.4, KYORAN 2.8) | | my J1 hits, his J1 whiffs; his ranged NS1a (360°, S14) reaches 3.4 | P, Q-R2 |
| **2.6-3.0 m** | my NS1a (3.3), his NS2a (3.8, S16), ranged NS1a (3.4) | mine S14 | my NS1a first against NS2a; still inside his NS1a's dead zone | P, Q |
| **3.0-3.8 m** | his NS2a (3.8), NS1a (3.0-6.4, S20), ranged J1 (3.0-6.4, S14); my NS1a to 3.3 | his ranged J1 S14 = my NS1a S14 | sealed NS1a can still land to 3.3; past it every sealed opener is short | P, Q |
| **3.8-6.4 m** | **his NS1a and ranged J1 (to 6.4), bind (S18, to 5.2), ranged NS2a (2.5-4.9), bind-mode NS1a (to 6.7)**; my Shikai lunge to 5.7, KYORAN lunge to 4.9 | lunge S16 / S14 < his NS1a S20 and bind S18 | **his band**. Sealed: walk-in and NS1a lose (G); a Step in + J1 beats his NS1a and ranged J1 (the Step's iframes) but not the bind; a Hoho on f8 perfect-counters the bind, the ranged J1 and the bind-mode NS1a. Shikai: the lunge lands first on his NS1a and bind | Q, G |
| **6.4 m+** | nothing of either | | neutral; my Shikai lunge whiff at 6.2 m is punished by his NS1a / bind (S) | S |

## Whose whiffs each side punishes

| Whiffer | Whiff | Punished by | Trials |
|---|---|---|---|
| Hisagi | J1 at 2.4-2.6 m (free on tick 47) | every opener of mine pressed f15-30 | W, F |
| Hisagi | Shikai NS1a inside its dead zone (2.4 m, free on 68) | everything, pressed f22-44 (NS1a and the lunges from f14; a J1 at f14 meets his NS1a's window and cancels) | W |
| Hisagi | NS2a at 3.9-4.2 m (it slides him 1 m in; free on 54) | sealed NS1a, Shikai J1 and both lunges (f22-30) | W, F |
| Hisagi | NS3a bind past 5.2 m (free on 70) | only the Shikai lunge (f22-46) | W, F |
| Hisagi | ranged J1 inside 3.0 m (dead zone; free on 47) | everything (f14-30) | W Hr |
| Hisagi | ranged NS1a past 3.4 m (free on 57) | both lunges (f22-33) | W Hr |
| Kenpachi | J1 at 3.1 / 3.6 m (free on 42) | not by his J1 or NS1a (my slide leaves me in his dead zone); by his bind thrown f10-18 | S |
| Kenpachi | sealed NS1a at 3.8 m (free on 60) | his bind (f10-26) | S |
| Kenpachi | Shikai lunge at 6.2 m (free on 64) | his NS1a and bind (f10-26) | S |

## Openers that trade or cancel (both on frame 0)

| Me \ him | his J1 | his NS1a |
|---|---|---|
| sealed J1 | me (1.5-2.5 m) | cancel at 1.5-2.5 m, then the exchange (J side: me); at 3.5 m nothing (his dead zone after my slide) |
| sealed NS1a | cancel | me (1.5-2.5 m; at 3.5 m my slide carries me into his dead zone: no hit either side) |
| Shikai J1 | me to 3.5 m | cancel |
| Shikai lunge | cancel | me 1.5-3.5 m, and at 4.0-4.5 m against NS1a and bind (G) |
| sealed NS2a (armour) | no hit either side | me, 43 |
| sealed NS3a (tame) | parried: thrust + men 83 | (his NS1a at 2.0 m is in its dead zone) |
| vs Hr / Hb | J1 beats his ranged / bind J1; NS1a cancels his ranged NS1a, beats the bind NS1a | |

After a cancel (X, Y, Z), as against Ichigo: my AS beats his NS going on and any SA that started before it, loses to one started after
it; against his HARD CPU my AS lands first in 3 / 4 / 0 of 10 seeds at +0 / +6 / +10 (at +10 his NS lands first). A cancel also turns on
his close range (`KIN on`, Hisagi's own rule).

## Pressure, wake-up, approach

- Routes do x1.25 what they do on Ichigo's Shikai (taken 1.0): sealed J1-J5 AS3 215, NS1 a b c SA J2-J5 AS3 269, Shikai L2 ptr 2 route 315,
  ZANKAI NS route 577 (R).
- Wake-up: identical to Ichigo's (K): the meaty J1 loses only to his Hoho on his first free tick. The bait arm (hold at 2.3 m) is the
  answer to that Hoho (passed its proof, `arms4/kenpachi.md`).
- His walk-in from 4.5 m runs into my NS1a and J1; a Step in + J1 loses to my J1 f0-16 (A).
- My back Step from 2.5 m against his NS1a lands me at 5 m, in his band: his NS1a hits (A).

## Resource races

| | Kenpachi | Hisagi |
|---|---|---|
| SP per route (DUEL_SP §4) | sealed NS1 55, Shikai NS1 100 / NS2 120 | Shikai NS1 75, NS2 75, NS3 25; ranged NS1 40, NS2 80; bind NS1 65, NS2 80 |
| Damage | 0.504 / 0.605 a base point | ~0.82 a base point (x1.15 x 0.42 x 1.7 in the Shikai): NS1a 51, NS2a 37, bind 33, J1 25 off Kenpachi |
| His AS1 TSUMUJI | | steals 5 / 10 / 15 / 20 flash-step a hit (DUEL_SP §6) and carries him to 3-4 m (DUEL_CORE §2.1.1) |
| Awakening gauge (shared: +0.035 a point dealt, +0.049 a point taken, +10.5 a Konpaku lost; once a match; heals 20 % Reishi) | he deals ~1.5x a base point, so Kenpachi's gauge fills from what he takes faster than Hisagi's does | |
| What the awakening brings | the Shikai at L0 (the lunge, the only answer that lands first in his 3-6 m band) and later the Bankai | the Bankai's ranged mode (J1 3.0-6.4 m) and bind mode (NS1a 1.5-6.7 m, no dead zone) |
| Burst (shared: needs 100 flash-step, pushes the attacker 5 m, invulnerable 20 frames; SP attacks free while it runs) | a Burst and a Hoho draw on the same cell: after a breakthrough (up to 200 taken) neither may be left | his AS1 TSUMUJI's steal also takes from that cell |

## The forms that change the picture

- **Kenpachi's Shikai** is the only form with an answer in his 3-6 m band that lands first (the lunge, S16, to 5.7 m); KYORAN's lunge
  (S14, 4.9 m) too, at 40 Reishi a segment.
- **Hisagi's Bankai** splits his game: ranged (J1 3.0-6.4 m, dead under 3; NS1a 360° to 3.4) and bind (NS1a to 6.7 m from 1.5 m, no
  dead zone; it reverts to ranged by itself). Against bind there is no safe 3-6 m spacing; against ranged, under 3 m is safe from his J.
