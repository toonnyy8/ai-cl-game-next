# Kenpachi vs Ichigo: the matchup table (PLAN4 kit study, step 2, 2026-11-15)

Every cell cites `trials.lisp` entries (results in `catalogue.md`; the rows of both kits in `sheet.md` and `opp-data.md`). Distances are
centre to centre; reaches include the victim's hurt radius (Ichigo 0.38 m, Kenpachi 0.45 m) and the moves' own slides. "I" = Ichigo's
Shikai (takes x0.8), "IK" = KESSA (x1.0).

## Distance bands

| Band | Out-ranges | Out-speeds | What happens | Trials |
|---|---|---|---|---|
| **0-2.0 m** | both J reach | sealed J1 S9 vs his J1 S14 (KESSA S8); NS1a S14 vs his S22 | my J1 beats his J1, my NS1a beats his NS1a; J vs NS cancels into the exchange; KESSA's J1 beats my sealed J1 | T 1.5 m rows, T IK |
| **2.0-2.4 m** | both J (KESSA's J1 stops at 2.0) | as above | as above; KESSA cannot J me here | Q-K1 / E |
| **2.4-2.6 m** | **only my J** (sealed 2.6, Shikai 3.4) | — | my J1 hits, his J1 whiffs; his J1 whiff here is punished by any of my openers pressed by f22 | P / E, T 2.5 m, W "J1 whiffs @2.6" |
| **2.6-3.1 m** | both NS1a (mine 3.3, his 3.1; KESSA's 3.4) | mine S14 vs S22 | my NS1a first; his J does nothing; the Shikai J1 still reaches (3.4) | P, Q, T |
| **3.1-3.4 m** | my NS1a (3.3), KESSA's NS1a (3.4) | | sealed NS1a lands on Ichigo's Shikai, trades reach with KESSA | E |
| **3.4-5.1 m** | **his NS3a rush (S18) to 5.1**; my Shikai lunge (S16) to 5.7, KYORAN lunge to 4.9; sealed: tame > thrust to 4.0 only | lunge S16 < rush S18 | sealed Kenpachi has no move here (his rush punishes my whiffs, S rows); in the Shikai my lunge lands first | Q-I3, P Ps2, S, W |
| **3-8 m+** | **his Getsuga route** (wave 82 / 78 Reishi, 60-81 ticks after its start) | — | his charges are NS windows with no hit: close in and hit them (Hoho f0 / Step in / walk 24 then NS1 a b c: 76 / 96); the Shikai lunge f0 from 5 m; any J at f48-60 cancels the wave; KYORAN's lunge from 5 m eats it | Q-IG, G |

## Whose whiffs each side punishes

| Whiffer | Whiff | Punished by | Trials |
|---|---|---|---|
| Ichigo | J1 at 2.4-2.6 m (37 frames on a whiff) | every opener of mine, pressed f14-23 (a J1 at f30 meets his next J1 in its startup and still wins) | W |
| Ichigo | NS1a at 3.2-3.6 m (58 frames) | only the Shikai lunge (pressed f30-36) and KYORAN's (f30-44); sealed nothing | W |
| Ichigo | NS3a rush past 5.1 m (60 frames) | the Shikai lunge (f22-38), KYORAN's (f30-46) | W |
| KESSA | J1 (31 frames) | my openers pressed f14-22 | W IK |
| Kenpachi | J1 at 3.1 m (sealed) / 3.6 m (Shikai) | not by his J1; by his NS1a and NS3a rush at f10 | S |
| Kenpachi | sealed NS1a at 3.8 m (47 frames) | his NS1a (f10-18), his rush (f18-26) | S |
| Kenpachi | Shikai lunge at 6.2 m (51 frames) | his rush (f18-26) | S |

## Openers that trade or cancel (both on frame 0)

| Me \ him | his J1 | his NS1a |
|---|---|---|
| sealed J1 | me (1.5-2.5 m); KESSA's J1 beats it | cancel, then the exchange (J side: me) |
| sealed NS1a | cancel (NS side: him) | me (S14 vs S22) to 2.5 m; at 3.5 m his NS1a hits |
| Shikai J1 | me to 3.5 m | cancel (J side) |
| Shikai lunge | cancel | me, 1.5-3.5 m |
| sealed NS2a (armour) | no hit either side (his NA cancels the drop) | me: the drop absorbs his NS hit, 34 |
| sealed NS3a (tame) | parried: thrust + men 66 | parried: 66 |

After a cancel (X): my AS at once beats his NS going on and his pre-latched SA, loses to his reactive SA; **my AS 6-10 frames after the
contact beats both**; as the NS side my SA beats his J2 and ties or loses to his AS.

## Pressure, wake-up, approach

- My hit-confirmed strings are true combos from J1 (S9) at up to 2.6 m: J1-J5 AS3 171 (IK 215), +56 knockdown (R5); after the knockdown the
  meaty J1 (free+28) loops J1 J2 AS1 for 64 a loop (R13). Only a **Hoho on his first free tick** (134-135 here) beats the meaty (a perfect
  counter); his buffered wake-up J and back Step lose, his wake-up NS1a is cancelled and my string still lands (K).
- His approach: a walk-in runs into my NS1a (3.3 m) and J1 (2.6 m); a Step in + J1 from 4.5 m loses to my J1 pressed f0-16 (A).
- His Hoho counters my J1 (pressed f0-6 before my hit), NS1a (f3-9), Shikai lunge (f6-9); mine counters his J1 (f6-10) and NS1a (f14-18).
- KESSA's NS3 clones are hazards: the tame never catches them (2026-11-06 catalogue F23, not re-run here).

## Resource races

| | Kenpachi | Ichigo |
|---|---|---|
| SP per route (DUEL_SP §4, x his `:sp-cost-mult`) | sealed NS1 55, AS3 75 (3 seg); Shikai NS1 100, NS2 120; Bankai segments also burn 40 of his Reishi | Shikai NS1 85, NS2 80, NS3 70; KESSA NS1 75, NS3 30 |
| Damage per base point dealt | 0.504 sealed / Shikai, 0.605 Bankai | his J1 32 base = 17 off me; NS1a 37; Getsuga 82 |
| Damage taken | x1.0 in every form | x0.8 Shikai, x1.0 KESSA: my routes do 25 % more to KESSA (R5 171 -> 215) |
| Kikon | ptr 2 on a red victim -3 Konpaku (C); non-red victims cancel the follow-up | |
| Breakthrough | the J side wins most exchanges (X): each first hit after a cancel takes up to 200 of the victim's flash-step | |

## The forms that change the picture

- **Kenpachi's Shikai** adds the only answer at 3.4-5.7 m (the lunge, S16, out-ranging and out-speeding his rush and hitting his Getsuga
  charge from 5 m) and a 3.4 m J1. Its strings need L (three lunges from L0, R23).
- **Kenpachi's Bankai** trades Reishi for damage (KYORAN J1-J4 AS 240 for -160 self; ZANKAI 319 for -160) and cannot leave without the
  special AS (-1 Konpaku to him). KYORAN's lunge (4.9 m) does not reach a 5 m Getsuga.
- **KESSA**: J1 S8 (beats my sealed J1), NS1a reach 3.4 (out-ranges my sealed NS1a by 0.1 m), and takes x1.0.
