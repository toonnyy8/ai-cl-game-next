# Ichigo: the catalogue (PLAN4's kit study, step 2, sim-verified; 2026-11-15)

```sh
python3 docs/research/strategy-drsi/sp/kits/ichigo/gen.py > docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp
python3 tools/combo-trial.py docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp --events > trials-out.md
python3 docs/research/strategy-drsi/sp/kits/ichigo/grid.py < trials-out.md      # section P's matrices
```

**747 trials, every one run in the native sim** (main c15f9a55; this branch adds only tool-side output: `trial.lisp`'s end line gives P2's
gauge change `fs2`, `combo-trial.py --events` lists cancels, absorbs, breaks, steals, refusals and Kikon lines). Two full runs gave
byte-identical output (`trials-out.md` is the raw table). P1 is Ichigo pressing only her script; P2 is Kenpachi (K sealed `:base`, Ks his
Shikai `:nozarashi`) or Hisagi (H Shikai `:base`, Hb Bankai ranged `:bankai`). P2 stands unless the trial makes him press J / SP on
**sim frames** (`:p2-at`, hitstop not counted) or walk / run / Hoho (`:p2-press`). Every trial names both pointers and both gauges (one match
carries all trials). The trial names below carry their opponent: `A12/K`.

**Columns of trials-out.md**: dmg = his Reishi lost (after scaling; a Kikon or Soul Break reads negative: his Reishi refills with the
Konpaku lost, read the Konpaku column); gaps = his free frames before each later hit (0 = a true combo); adv = his first free frame minus
hers after the last hit (a knockdown counts his wake-up; ? = one was not free by the end); dist = the end distance; FS = her gauge change
(**capped at 300: at fs 300 the J / SA gains are lost**, so read section G at fs 100 for a route's net cost); fs2 = his gauge change.

**Damage is the same against Kenpachi and Hisagi** (both take x1.0 in their first forms; every route row below matches to the point).

## A-D, K. Hit-confirmed routes (all gaps 0), by where they start

| Route | Start | dmg | Ends | SP net at fs 100 (G) | Trial |
|---|---|---|---|---|---|
| NS2ab SA-g2 J2-J5 AS3abc (x1.7 charge) | 2.0 m, ptr 2 | **360** | knockdown, +46, 1.8 m, ptr 3 | -48 | C8 |
| NS1a-c SA J2-J5 AS3abc | 2.4 m, ptr 1 | 286 | knockdown, +46, 1.8 m, ptr 3 | (120 at fs 300) | B10 |
| NS1a SA J2-J5 AS3abc | 2.4 m, ptr 1 | 233 | knockdown, +46, ptr 3 | -53 | B8 |
| J1-J5 AS3abc | 1.6 m (J1 hits to 2.3 m) | 202 | knockdown, +46, ptr 3 | -30 | A12 |
| NS3a SA J2-J5 AS3abc | 3.0 m, ptr 3 | 197 | knockdown, +46, ptr 3 | | D5 |
| NS2ab SA-g2 J2 J3 AS2ab | 2.0 m, ptr 2 | 183 | launch, +69, 4.3 m, ptr 2 | | C7 |
| NS1ab SA J2 J3 AS2ab | 2.4 m | 176 | launch, +69, 4.3-4.5 m, ptr 2 | | B9 |
| NS2a SA-g1 J2 J3 AS2ab (x1.4) | 2.0 m | 149 | launch, +70, 4.5 m | | C6 |
| NS1a SA J2 J3 AS2ab | 2.4 m | 148 | launch, +69-70 | | B7 |
| NS3a SA J2 J3 AS2ab | 4.6 m, ptr 3 | 128 | launch, +69, ptr 2 | | D6 |
| J1-J4 AS2ab / J1-J3 AS2ab | 1.6 m | 127 / 111 | launch, +69, 4.2-4.3 m, ptr 2 | J1-J3 AS2ab: -6 | A10 / A9 |
| NS1a-c | 2.4-3.0 m | 116 | crumple, +1, 1.4-2.0 m, ptr 1 | -80 | B2 / B3 |
| NS1a SA AS1 | 2.4 m | 83 | knockdown, +41, 1.95 m; **steals 40** (he -40, she +20) | | B5 |
| J1-J5 (no AS) | 1.6 m | 82 | +5, 2.4-2.5 m | +50 | A5 |
| J1 J2 AS1 / J1 AS1 | 1.6 m | 61 / 44 | knockdown, +41, 1.8 m, steal 40 | +10 | A7 / A6 |
| NS3ab | 3.0 m | 76 | crumple, +6, 0.9 m | | D2 |
| KESSA NS2ab SA-g2 J2-J5 AS3abc | 2.0 m, ptr 2 | **328** | knockdown, +41, ptr 3 | | K9 |
| KESSA NS1a SA J2-J5 AS3abc | 2.6 m, ptr 1 | 213 | knockdown, +41 | | K6 |
| KESSA J1-J5 AS3abc (clone cuts) / NS3ab SA J2-J5 AS3abc (clone replays 3-4 each) | 1.6 / 2.6 m | 190 / 190 | knockdown, +41 | | K4 / K12 |
| KESSA J1-J3 AS2ab | 1.6 m | 105 | launch, **+79**, 4.7-4.8 m | | K3 |
| KESSA NS1a-c (the chains) | 2.6-3.3 m | 102 | crumple, **+9** (the best plus frames of any NS ender) | | K5 / K7 |
| KESSA J1 AS1 (whip: 4 lashes x 14) | 1.6 m | 44 | knockdown; **steals 4 x 15 = 60** | | K2 |

- **The charge pays only through a J string**: C8 (360) against the same string from J1 (A12, 202): the x1.7 multiplies J2..J5 and the
  AS. The charges cost 64 f standing still first (NS2a S20, NS2b S16 + the SA's S10) and need 20 SP for the two charges.
- **Hoho in a combo** (F1, F3): J1 > Hoho > J2 J3 (51) and J1 > Hoho > AS1 (44) still connect, at 100 SP: a gauge sink, not a damage gain.
- **Step / Hoho approach** (F4-F6): a forward Step (2.5 m) from 4.2 m then J1 at its end lands (17); a Hoho from 6 m then J1 / NS1a at its
  end lands (17 / 37, the Hoho costs 100).

## G. The gauge (fs 300 / 100 / 0)

| Route | fs 300 | fs 100 (net) | fs 0 | Trial |
|---|---|---|---|---|
| J1-J5 AS3abc | 202 | 202 (-30) | **177** (+10: the AS paid nothing, x0.5) | G A12 |
| NS1a SA J2-J5 AS3abc | 233 | 233 (-53) | 192 (+7) | G B8 |
| NS1a-c | 116 | 116 (-80) | **38: NS1b refused at 0** | G B2 |
| NS2ab SA-g2 J2-J5 AS3abc | 360 | 360 (-48) | **177: NS2b refused, the J presses start a J string** | G C8 |
| NS2abc at 6.6 m (JUJISHO) | 82 | 82 (-74) | **0: NS2b refused, no wave** | G C1 |
| J1-J3 AS2ab | 111 | 111 (-6) | 103 (+9) | G A9 |
| J1 AS1 against his 300 / his 100 | steal 40 / 40 (**the last cell**: his gauge 100 -> 68 with regen) | | | G A6 |

- **At 100 SP every route runs once**; the J-first routes are nearly free (J hits pay the AS: J1-J3 AS2ab nets -6, J1 AS1 nets +10).
- **At 0 SP the NS routes die after their first segment** (NS1, NS2) while J-first routes keep 87-92 % of their damage: the J string is
  the only full-damage play from an empty gauge. NS3a alone (30) is one segment and still starts.

## E, S. Kikon and Soul Break (both opponents identical)

| Trial | What | Konpaku | Note |
|---|---|---|---|
| E1 / E4 | NS1a held / J1 AS1 held (ptr 1) | -1 | HEAVY-KIKON-CINE |
| E5 / E6 / E7 | AS2a held / AS2b's wave held / JUJISHO held at 6.6 m (ptr 2) | -2 | the wave's flash-step strike lands from 6.6 m |
| E9 / E11 | NS3a held / J1-J5 AS3ab held (ptr 3) | -1 | a hold through AS3b's later SP press triggers on AS3b's hit (not AS3c) |
| E14 | AS2a held, he is red (ptr 2) | **-3** | pointer 2's "red = Soul Break" |
| E12 / E13 | NS1a held, he presses J in the follow-up / he is red | 0 (cancelled) / -1 | a non-red victim cancels it with any J |
| S1 / S4 | the kill (Reishi 0) at ptr 3: AS3 / a J | **-5** | pointer 3's Soul Break |
| S2 / S3 | the kill at ptr 2 / ptr 1 | -3 | |
| K14 / K15 | KESSA AS1 held / NS1a held (ptr 1) | -2 | KESSA's base 3 |

- **Pointer 2 for the Kikon, pointer 3 for the kill**: a Kikon takes 1 / 2 / 1 (red 1 / 3 / 1); a Soul Break 3 / 3 / 5. A non-red
  opponent who presses J cancels every Kikon (E12): the Kikon is a red-opponent tool, the Soul Break the general one.

## R, W. Reach (him / her standing, centre to centre; sim boundaries)

| Opener | hits at | misses at | Trial |
|---|---|---|---|
| her J1 (S14) | 2.3 | 2.6 | A14 / A15 |
| her NS1a (S22) | 3.0 | 3.2 | R |
| her NS2a SA-g1 (S20 + S8, the lunge) | 3.8 | 4.2 (4.0 hits Kenpachi, not Hisagi) | R, C11 |
| her NS3a (S18, the lunge) | 4.8 | 5.2 | R |
| her KESSA J1 (S8) | 2.0 vs Kenpachi | 2.0 vs Hisagi, 2.3 | R |
| her KESSA NS1a | 3.2 | 3.6 | R |
| her KESSA NS3a SA | 4.6 | | K13 |
| his sealed J1 (S9) | 2.6 | 3.0 (W: whiffs at 3.0) | W |
| his sealed NS1a (S14) / NS2a (S16, 1 armour hit) / NS3a SA | 2.9 / 2.4 / 2.4 | 3.6 / 3.3 / 3.2 | W |
| his Shikai J1 / NS1a / NS2a | 2.7 / **4.5** / 1.8 | 3.6 / 6.0 / 2.8 | W |
| Hisagi J1 (S14) | 2.1 | 2.5 | W |
| Hisagi NS1a (S20, the chain) | **3.4-6.0** (dead zone: whiffs at 2.6) | 6.8 | W |
| Hisagi NS2a (S16) / NS3a bind (S18) | 3.8 / **5.2** | | W |
| Hisagi Bankai J1 (S14, ranged) | **3.4-6.2** (whiffs at 2.6) | 6.8 | W |
| Hisagi Bankai NS1a (S14, 360°) / NS2a (S25) | 3.0 / 4.4 | 3.6 / 2.2 and 5.0 | W |

**Her reach advantage**: beyond 2.6 m only her NS1a (3.0), SA-g1 (3.8) and NS3a (4.8) touch sealed Kenpachi, whose longest is NS1a 2.9.
Hisagi out-ranges her everywhere from 3.4 m (his chain NS1a and bind NS3a, his Bankai J), and is blind inside 3.0 m with those moves.

## P. Both press their opener on the same frame (`grid.py`)

One letter per distance (1.6 / 2.4 / 3.2 / 4.2 / 5.4 m): I = her real hit first, H = his, c = a cancel first (then who hit, or -),
A = an absorb first, - = nobody hit. Her NS2a column is NS2a + the SA-g1 lunge; KESSA's NS3a column is NS3a + its SA at f10.

**vs Kenpachi sealed (K)**

| hers \ his | J1 | NS1a | NS2a | NS3a+SA |
|---|---|---|---|---|
| J1 | H H - - - | c- c- c- - - | c- c- c- - - | AH AH - - - |
| NS1a | cI cI I - - | H H H I - | H H I - - | c- c- c- - - |
| NS2a+SAg1 | cI cI I I - | H H H I - | H H I I - | H H I I - |
| NS3a | cI cI cI I I | H H H H H | H H H H I | cI cI cI cI cI |
| kJ1 | I I - - - | cH cH H - - | cH cH - - - | H H - - - |
| kNS1a | cI cI I - - | H H H I - | H H I I - | c- c- c- - - |
| kNS3a+SA | cI cI I I I | H H H I I | I I I I I | cI cI cI I I |

**vs Hisagi Shikai (H)**

| hers \ his | J1 | NS1a | NS2a | NS3a |
|---|---|---|---|---|
| J1 | c- c- - - - | cH - - H H | c- c- c- c- - | cH H H H H |
| NS1a | cI I I - - | I I H H H | H H H - - | H H H H - |
| NS2a+SAg1 | cI I I I - | I I H H H | H H H I - | H H H H - |
| NS3a | cI cI cI cI - | I I I I H | H H H H H | c- c- c- c- H |
| kJ1 | I - - - - | cH - H H H | cH cH H - - | cH H H H - |
| kNS1a | cI I I - - | I I H H H | H H H I - | H H H H - |
| kNS3a+SA | cI cI cI I I | I I I cI cI | I I I I I | I I cI cI cI |

**vs Kenpachi Shikai (Ks)** and **Hisagi Bankai ranged (Hb)**

| hers \ his (Ks) | J1 | NS1a | NS2a |
|---|---|---|---|
| J1 | H H H - - | c- c- c- c- c- | c- c- c- - - |
| NS1a | cI cI cI - - | H H H H H | H H I - - |
| NS2a+SAg1 | cI cI cI I - | H H H H H | H H I I - |
| NS3a | cI cI cI cI I | H H H H H | H H H H I |

| hers \ his (Hb) | J1 | NS1a | NS2a |
|---|---|---|---|
| J1 | I - - H H | c- c- c- - - | cH - H H H |
| NS1a | I I c- c- c- | H H H - - | I I H H - |
| NS2a+SAg1 | I I cI c- c- | H H H - - | c- c- c- c- c- |
| NS3a | I I cI I c- | H H H H H | I I I I H |

What the grid says (the triangle at work, reach deciding the rest):
- **Her NS beats his lone J** at 1.6-3.2 m against all four forms (cI): his J cancels her NS in its startup, her segment carries on and
  lands while his J recovers. A lone J against her NS is a loss for him unless he follows with the AS (X2 below).
- **Her J1 beats nothing** but Hisagi's Bankai J at 1.6 m (his 3 m dead zone): it is slower than Kenpachi's (S14 vs S9), ties Hisagi's
  S14 (c-), and only cancels NS.
- **NS vs NS = first hit wins**: Kenpachi's NS1a (S14) / NS2a (S16) beat all her NS openers inside his reach (H); her NS1a / NS2a+SA win
  only at 3.2-4.2 m where his miss. Against Hisagi her NS1a / NS3a beat his NS1a inside 3.2-4.2 m (his S20 and dead zone), and lose to
  his NS2a / NS3a bind.
- **KESSA's NS3a + SA** is the best single answer in the grid: it wins or cancels-then-wins 20 of 20 cells against Hisagi and 17 of 20
  against Kenpachi, losing only to his NS1a at 1.6-3.2 m (the SA is a turn move with super armour from f6; the summon is the NS).

## X. After a cancel (the exchange)

| Trial | Her choice after the cancel | his answer: none | his SA (reaction) | his next segment / his AS | his J2 |
|---|---|---|---|---|---|
| X1/K her J1 into his NS1a | AS1 at once | **I** 27 + BREAK 160 | **H** (SA absorbs AS1, SA 30 + BREAK 182) | **I** (NS1b) | |
| X1/K | J2 | **I** 34 + BREAK 200 | **I** | **I** | |
| X1/H her J1 into his NS1a (3 m dead zone: a cancel at 2.0 m) | AS1 at once | **I** | **H** (SA-KIRI 40) | **I** | |
| X1/H | J2 | I (17) | H at f24 / I at f30 | **H** (NS1b 56) | |
| X2/K her NS1a vs his J1 | SA at once | **I** 56 | | **I** (SA beats his AS) | **I** |
| X2/K | NS1b | I 70 | | **H** (AS1 90 + BREAK 180) | I |
| X2/H | SA at once | I 19 | | **H** (TSUMUJI's 4 hits beat the SA) | I |
| X2/H | NS1b | I 33 | | **H** (TSUMUJI) | I |

- **The breakthrough is the real prize**: every first hit after a cancel took 143-200 SP from the loser (all his gauge above 100 at fs
  300). One exchange won is worth two Hohos of gauge.
- **The triangle holds after a cancel**: her AS beats his next NS segment and loses to his reactive SA; her SA beats his AS and his J2,
  except Hisagi's AS1 TSUMUJI (16 active frames, it carries him away: DUEL_CORE §2.1.1's known exception). Against Kenpachi her J1's own hit
  still lands after the cancel (his NS1a is in recovery by then), so every X1/K row but AS-into-his-SA is hers.
- **The wave in the triangle** (X3, X4, N1): JUJISHO at 3.0 m into his J is cancelled (refunded: her gauge -20 = the two charges);
  at 6.6 m Hisagi's J1 cancelled it, Kenpachi's (later) was hit (82). A run-in from 8.5 m that ends in J cancels it and his J lands
  next (H, BREAK 182 from her); from 6.6 m his J cancels a charge segment and the wave then lands (BREAK 200 from him); from 10 m the wave
  hits him running. **JUJISHO is not a safe zoning tool against a J press**; it is a timing read.

## W. His whiff, her punish (her press after his move starts, frames)

| His whiff | her NS1a f10 | NS3a f14 | NS3a f24 | J1 (walk in, f14) |
|---|---|---|---|---|
| Kenpachi J1 at 3.0 m | **I** 37 | **I** 38 | **I** 38 | trade |
| Kenpachi NS1a at 3.4 m | H (he reaches: S14 + slide 1.2) | H | **I** 38 | H |
| Kenpachi NS2a at 3.6 m | **I** 37 | H | **I** 38 | H |
| Hisagi J1 at 2.8 m | **I** | **I** | **I** | trade |
| Hisagi NS2a at 4.0 m | **I** | H | **I** | H |
| Hisagi NS1a in its dead zone (2.2 m) | **I** | **I** | **I** | **I** (17) |
| Hisagi NS3a bind at 5.6 m | - (out of her reach) | H | - | H |

- **The robust whiff punish is NS3a late (f24)**: it lands on every whiff of his inside 4.8 m whatever he threw; NS1a at f10 punishes his
  J and NS2a. A J walk-in punish trades or loses: her J1 is too slow.
- Hisagi's chain moves have a 3 m dead zone (NS1a, Bankai J): inside 2.6 m they whiff and anything of hers punishes.

## N. Anti-approach (he comes in)

- **NS3a at 5.0-6.0 m as he walks in** (N2) and **NS1a at 5.0 m** (N3) catch the walk (38 / 37); J1 at 5-6 m never reaches (N4).
- **JUJISHO against a run-in** (N1): from 10 m it hits him running (82, his Hoho / Step not pressed); from 6.6 m his J cancels a charge and the wave
  still lands; from 8.5 m he cancels it and hits her. The wave at mid range is a coin flip against a J press.
- **His Hoho in from 6 m** (N5, N6): her blind J1 / NS1a hit nothing (he reappears behind her). Nothing of hers catches a Hoho-in except a
  later read; his Hoho costs him 100.

## Z. Wake-up (after her AS1 knockdown: +41)

- **Meaty timing**: her J1 30 f after she is free (61) and NS1a 20-30 f after (81) land on his wake-up; earlier ones whiff (Z1, Z2).
- **Against a wake-up J mash** (Z3, Z4) **every meaty of hers lost** (his J1 hits her; a meaty NS1a cancels and his J lands with BREAK 200):
  his J on the first wake frame beats her J1 (S14) and cancels her NS. The AS1 knockdown buys gauge (the steal 40) and position, not a
  free mix-up. After AS3c (+46) an NS3a 20 f after she is free lands (Z5, 212 total).

## L. The awakening

- Mod + P with the gauge at 100 from neutral: `AWAKEN from IDLE`, then the KESSA J string (L1). At 90 it is refused (L2).

## Corrections of the 2026-11-06 catalogue (docs/research/ki-ai/ichigo/)

- AS1 steals 40 (was 120); a steal can take the last cell (G A6: his 100 -> 68).
- JUJISHO no longer beats every class: a J cancels it (X3, X4), an AS absorbs it.
- Her NS vs his J1 is no longer "his AS wins": with the cancel's out (DUEL_CORE §2.1.1) her SA at once beats his AS (X2/K SA 19) except
  Hisagi's TSUMUJI.
- The routes' damage is unchanged (A12 202, B8 233, D5 197, C8 360 vs 365: SUBLIMATION is now 0 in every trial).
