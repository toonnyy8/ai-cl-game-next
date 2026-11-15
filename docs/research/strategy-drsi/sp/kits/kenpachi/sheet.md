# Kenpachi data sheet (PLAN4 kit study, step 1, 2026-11-15)

PLAN4's last note (the user, 2026-11-15: 「你探索每個人物的時候請依據遊戲系統與該人物的特色、幀數表、攻擊範圍等等進行規劃」; the order of
DEVLOG §369). This replaces `docs/research/ki-ai/kenpachi/sheet.md` (2026-11-06, before the SP system, the exchange rules and the J1 / AS1
retiming of DUEL_KEN_V3 §48). Built at main c15f9a55.

**The per-move rows below the line are generated** by `sheet.lisp` (the host loads the duel's plain-CL files as
`tests/duel-rules-test.lisp` does and walks each form's `:core`). Regenerate after a kit change and paste them under the line:

    $ECL_HOST --norc --load docs/research/strategy-drsi/sp/kits/kenpachi/sheet.lisp | grep -v "^;;; Loading"
    $ECL_HOST --norc --load docs/research/strategy-drsi/sp/kits/kenpachi/sheet.lisp -- opp | grep -v "^;;; Loading" > docs/research/strategy-drsi/sp/kits/kenpachi/opp-data.md

`opp-data.md` holds Ichigo's and Hisagi's rows in the same columns (for the matchup tables; their own studies own their sheets).
Trial names (R5, Pz2, X…) are `trials.lisp` entries, every one verified in the native sim (`catalogue.md`). A whiff's real recovery is S + A + whiff R
plus about 10 frames (catalogue F). This header holds what the
rows cannot show; every line was re-checked against the code and the trials of 2026-11-15.

## Damage: base vs dealt

A hit deals base x the form's x `*core-damage*` 0.42 x the kit's `:core :mult` 1.2 (sealed / Shikai **0.504**, Bankai **0.605** per base
point) x the victim form's `:taken` (Ichigo's Shikai **0.8**, KESSA and every Hisagi form 1.0) x the combo scale (hits 1-3 full, then -15 %
a hit, floor 20 %; SP / AS hits unscaled), x (1 + 0.2 x the SUBLIMATION / DRIVE fraction). So a sealed J1 (35) is 14 Reishi on Ichigo's
Shikai, 18 on Hisagi (R1). Each side has 1300 Reishi and 9 Konpaku. **Hisagi hits Kenpachi harder** than Kenpachi hits him per base
point: his kits carry `:core :mult 1.7` (x1.15 form in the Shikai): his NS1a's 62 base is 51 Reishi off Kenpachi, Kenpachi's NS1a's 65 is
33 off him (Q-H2, Pz2).

## The forms: in and out

| From -> to | How | Kept / reset | Trials |
|---|---|---|---|
| Sealed (`:base`) -> Shikai (`:nozarashi`) | the awakening: Mod+P with a full awakening gauge (once a match) | Shikai at **L0**, pointer clamped to 1-2; the awakening heal (20 % Reishi) | — (a trial starts in a form) |
| Shikai -> Bankai | **L3, J1-J7, SP**: `:ke-s-bankai` (S12, 100 base, 3.2 m all round, knockdown, knocked 5 m), the Bankai on its frame 15: **KYORAN** (`:bankai`) from pointer 1, **ZANKAI** (`:bankai-2`) from pointer 2 | nothing restored; no Kikon off it (`:no-kikon`) | R33 (145 / 182, +77, he lands 6.1 m away) |
| Bankai -> Shikai | only the special AS (SP after the Bankai's J5): 千切 CHIGIRI / TATE-GOTO; when it is over **-1 Konpaku** to Kenpachi (none on his last), the Shikai on the pointer he came from, **L0** | Reishi as it is | R43, R48 (self K -1, back to the Shikai) |
| (in the Bankai) | no timer; every NS / AS segment burns **40 Reishi** of his own (floor 1) | | R41 (-80), R42 (-160), R49 (-320) |

## The Shikai's unlock level L (DUEL_KEN_V3 §3-§13)

- L 0-3 in the kit meter; the awakening and the return from the Bankai start it at 0.
- **+1 once per combo** (the victim's) that lands an NS segment or a same-pointer AS (`:lv-up`); a cancel, an armoured or blocked hit gives
  nothing. A gained level opens segments from the next route on. **L0 -> L3 in three neutral lunges**, each its own combo (R23, 84 / 105).
- **Reset to 0** by a burst (an AS that writes the other pointer: R22) and by the Bankai's return.
- Segments by L: pointer 1 NS a (L0), + b (L1), + c (L2), + d e (L3); pointer 2 NS a b (L0), + c (L1), + d (L2), + e (L3). The keeping AS
  has 1 + L segments, its last at L3 a knockdown (at L0 the AS is one stagger segment: R24 ends at adv 0). J4-J7 need L3.

## Which AS a press count starts

| Form | J presses + SP | AS | Pointer after |
|---|---|---|---|
| Sealed (`:as-by-press (1 1 2 2 3)`) | J1, J2 / SA | AS1 (1 seg, knockdown) | 1 |
| | J3, J4 | AS2 (2 seg, the last launches) | 2 |
| | J5 | AS3 (3 seg, the last knocks down, `:guard-crush`) | 3 |
| Shikai (`(1 1 2)`, `ken-as-pick`) | J1, J2 at pointer 1 | AS1, 1 + L segments | 1, L +1 if it lands |
| | J3 at pointer 1 | burst TOSSHIN-ISSEN (to pointer 2), 100 / 150 / 200 / 260 base by L | 2, L 0 |
| | J1, J2 at pointer 2 | burst ZANGAESHI (to pointer 1) | 1, L 0 |
| | J3 at pointer 2 | AS2, 1 + L segments | 2, L +1 |
| | J4-J6 (L3) | the pointer's special AS: DAISHARIN (ptr 1, 60 + 60 + 120, launch) / INSEKI-GIRI (ptr 2, 260, knockdown) | kept, L kept |
| | J7 (L3) | BANKAI (above) | the Bankai's one pointer |
| KYORAN / ZANKAI (`:as-writes (1 1 1 1 1)`, each J's `:as-ptr`) | Jn, n 1-4 | the one AS with n segments, its last the finisher (110 / 150, knockdown) | 1 |
| | J5 | the special AS (CHIGIRI 300 / TATE-GOTO 320, the damage on frame 40 / 34) | back to the Shikai |

The SA (an attack in an NS gap) counts as one attack press, and a J after it goes on as J2: NS … SA J2 … Jn + SP starts the AS of that
press count (R11 214 / 269, R12 173 / 218, R27 251 / 315, R49 461 / 577).

## Pointer themes and tells (DUEL_KEN_V3 §6 / §35, DUEL_CORE §5b)

| Form | Pointer 1 | Pointer 2 | Pointer 3 |
|---|---|---|---|
| Sealed | the drag (one hand, tip on the floor): NS1 a b c, rising cuts, the reach pointer (NS1a 3.3 m) | the shoulder (blade on the shoulder): NS2 a b take **one hit each from frame 6 to the end of their active frames** (`ken-armor`) | chūdan (two hands): NS3a the **tame**, no hit, catches a melee hit in frames 2-28 and answers with the thrust (`:parry`, before the triangle) |
| Shikai | the cleaver slung: the lunge (NS1a S16, slide 3.0, hits from **5.7 m**), the spins (360°) | the blade on the shoulder: the hilt jab (1.4 m + a 1.0 step), then the great-sword swings (NS2c 110 crumple) | — |
| KYORAN / ZANKAI | KYORAN: haft on the shoulder, fast (J1 S7, the lunge to 4.9 m) | ZANKAI: the low beast crouch, heavy (NS a 100 crumple, 2.2 m) | — |

- **Armour is no anti-J tool**: an NA cancels the armoured drop (Tz2 vs his J: no hit either side); it absorbs an NS hit and lands (Tz2 vs
  his NS: 34 / 43).
- **The tame catches J and NS** (Tz3: Ichigo's J1 and NS1a, Hisagi's J1 parried, thrust + men 66 / 83). Hisagi's NS1a at 2.0 m is inside
  its own dead zone (no hit to catch).
- **Projectiles are in the triangle** since 2026-11-13 (DUEL_SP §6): any J of any form cancels Ichigo's wave (G "J at f48-60" rows, the
  sealed J1 too). The Shikai's `:projectile-cut` is no longer a separation (the 2026-11-06 catalogue's F31 "the sealed form cannot cut" is
  refuted).

## The exchange (DUEL_CORE §2.1-§2.1.2, DUEL_SP §6) as it bears on Kenpachi

- A cross-class cancel (J x NS) counts as landed for both; an **exchange** opens; no Hoho for either side until its first real hit or
  both back in neutral; the cancel's slow motion (x0.2 for 0.7 s) stretches the display ticks.
- The first real hit is the **breakthrough**: it takes all of the victim's flash-step above the last cell (up to 200), the attacker gains
  half. A J / SA in a cancel gains +30, a cancelled SP segment is refunded.
- **J side** (his NS cancelled by my J): the AS beats his NS going on and any SA of his that started before it; it loses to an SA he
  starts after it, until the AS's hit (the later start wins). No AS delay escapes that: against his HARD CPU the AS lands first in 3-4 of
  10 seeds at +0 / +6 / +10 (Y, Z); 14 frames late his NS lands. J2 loses to everything (another cancel or his SA).
- **NS side** (my NS cancelled by his J): my SA at once beats his J2 and ties (cancels) or loses to his AS; NS1b loses to his AS; doing
  nothing loses to his AS. The J side keeps the edge (DUEL_CORE §2.1.1's finding, still true).

## Kikon

Hold the SP from its segment's start to its hit + the 12-frame confirm: the next strike is the Kikon. Konpaku taken = `core-kikon-count`
of the form's base (sealed / Shikai 2, Bankai 4) and the struck SP's pointer: pointer 1 base - 1, pointer 2 base (base + 1 on a red
victim), pointer 3 base - 1, at least 1. **A non-red victim cancels the follow-up with any attack** (C "he presses J1": `P2 cancels the
Kikon follow-up`, 0 Konpaku); a red one (under 30 % Reishi) cannot.

| Form (base) | Pointer 1 | Pointer 2 (red) | Pointer 3 | Trials |
|---|---|---|---|---|
| Sealed (2) | 1 (red 1) | 2 (**3**) | 1 | R15, R16, R17, C rows |
| Shikai (2) | 1 | 2 (3) | — | R35 (2), C INSEKI-GIRI (2); not the BANKAI AS |
| Bankai (4) | 3 | — | — | R46 (3), C TATE-GOTO (3, and Kenpachi -1 for the special) |

## SP costs, gains, Step / Hoho / Burst

- Segment costs (`kit-sp-cost`, DUEL_SP §4, x the form's `:sp-cost-mult`): in the rows' SP column. Route totals spent (FS column of R):
  sealed J1-J5 AS3 **75**, NS1 a b c SA AS1 65, NS2 a b SA J2 J3 AS2 70; Shikai L3 J1-J3 AS2 (4 seg) 110, L2 NS a-d SA J2 J3 AS2 115, the
  special AS 60, the Bankai entry 25; KYORAN J1-J4 AS 95 (+ 160 Reishi), ZANKAI NS a-d SA J2-J4 AS 129 (+ 320 Reishi). A full gauge is 300.
- The shared rules (Step, Hoho, the gauge, Burst, combo scale, awakening) are the table at the end of the rows.
- **Hoho**: a perfect one (his hit volume within 12 frames) counters 60 base and locks him 40 frames. My Hoho on f6-10 against his J1 and
  on f14-18 against his NS1a (f10 already on Hisagi) counters (A rows); his Hoho on f0-6 counters my sealed J1, f3-9 my NS1a, f6-9 my Shikai lunge.

---

# Generated rows

Generated by `sheet.lisp` from the kit data (`duel/lisp/ken.lisp`, `tuning.lisp`, `sp.lisp`). Frames at 60 Hz; S = startup (the hit lands on frame S),
A active, R recovery; whiff R = recovery after a whiff. "dealt": the move's summed base damage x the form's multipliers x the victim form's :taken, no combo scaling.
"adv on hit": frame math (*REACTION-FRAMES*: flinch 18, stagger 26, crumple 40) for the last hit on its first active frame; the catalogue measures the real value.
"adv on block": the data's :adv-block (a core kit never guards: unread). edge = reach + a capsule's radius (MOVE-EDGE). SP cost: KIT-SP-COST (DUEL_SP §4, x the form's :sp-cost-mult).

## Sealed form (the katana) (`:kenpachi :base`)

Form x 1.00, :core :mult 1.20, *CORE-DAMAGE* 0.42: a hit deals base x 0.504 (x the victim's :taken, x the combo scale from hit 4, SP hits unscaled). Taken x 1.00; walk 4.4 / run 10.0 m/s; stun tolerance 26.0; Kikon Konpaku base 2; :hs-dmg (4 30 10 4 14); :as-by-press (1 1 2 2 3); :as-writes (1 2 3); :sp-cost-mult 0.76; passives nil.

| move | class | S/A/R (total; whiff R) | hit windows (from-to base react) | dealt (sum, unscaled) vs I / IK / H / Hr / Hb | reach / edge, arc | slide | adv on hit (math) | adv on block | armour, hitstop, flags | SP cost | params |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ke-z-j1 | NA J1 | 9/3/12 (24; whiff R 20) | 9-12 35 flinch | 14 / 18 / 18 / 18 / 18 | 1.80 / 1.80 m, 100° | 0.6 | +3 | -2 | hs 4  | — |  |
| ke-z-j2 | NA J2 | 6/3/12 (21; whiff R 20) | 6-9 35 flinch | 14 / 18 / 18 / 18 / 18 | 1.80 / 1.80 m, 100° | 0.0 | +3 | -2 | hs 4  | — |  |
| ke-z-j3 | NA J3 | 7/3/12 (22; whiff R 20) | 7-10 40 flinch | 16 / 20 / 20 / 20 / 20 | 1.80 / 1.80 m, 100° | 0.6 | +3 | -2 | hs 5  | — |  |
| ke-z-j4 | NA J4 | 8/3/13 (24; whiff R 21) | 8-11 45 flinch | 18 / 23 / 23 / 23 / 23 | 1.80 / 1.80 m, 100° | 0.0 | +2 | -2 | hs 6  | — |  |
| ke-z-j5 | NA J5 | 10/4/18 (32; whiff R 26) | 10-14 55 stagger | 22 / 28 / 28 / 28 / 28 | 1.80 / 1.80 m, 120° | 0.8 | +4 | -4 | hs 6  | — |  |
| ke-z-n1a | NS1a | 14/4/20 (38; whiff R 32) | 14-18 65 stagger | 26 / 33 / 33 / 33 / 33 | 1.90 / 1.90 m, 100° | 1.2 | +2 | -4 | hs 8  | 20 | ns-next ke-z-n1b, sa ke-z-sa1 |
| ke-z-sa1 | SA (ptr 1) | 8/3/14 (25; whiff R 22) | 8-11 30 stagger kb1.5 | 12 / 15 / 15 / 15 / 15 | 1.40 / 1.40 m, 80° | 0.0 | +9 | -2 | hs 4  | — |  |
| ke-z-n1b | NS1b | 10/3/18 (31; whiff R 30) | 10-13 55 stagger | 22 / 28 / 28 / 28 / 28 | 1.80 / 1.80 m, 110° | 0.0 | +5 | -4 | hs 6  | 15 | ns-next ke-z-n1c, sa ke-z-sa1 |
| ke-z-n1c | NS1c | 12/4/20 (36; whiff R 32) | 12-16 70 crumple | 28 / 35 / 35 / 35 / 35 | 1.90 / 1.90 m, 180° | 0.0 | +16 | -4 | hs 8  | 20 | sa ke-z-sa1 |
| ke-z-n2a | NS2a | 16/4/22 (42; whiff R 34) | 16-20 85 crumple | 34 / 43 / 43 / 43 / 43 | 1.80 / 1.80 m, 100° | 1.0 | +14 | -4 | armour 1 hs 10  | 25 | armor-act, ns-next ke-z-n2b, sa ke-z-sa2 |
| ke-z-sa2 | SA (ptr 2) | 8/3/14 (25; whiff R 22) | 8-11 35 stagger kb1.0 | 14 / 18 / 18 / 18 / 18 | 1.40 / 1.40 m, 80° | 0.0 | +9 | -2 | hs 4  | — |  |
| ke-z-n2b | NS2b | 14/4/22 (40; whiff R 34) | 14-18 95 stagger | 38 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 110° | 0.6 | +0 | -4 | armour 1 hs 10  | 30 | armor-act, sa ke-z-sa2 |
| ke-z-n3a | NS3a | 14/0/16 (30; whiff R 28) | — (no hit) | 0 / 0 / 0 / 0 / 0 | 0.00 / 0.00 m, 90° | 0.0 | — | — | parry | 10 | ns-next ke-z-n3b, sa ke-z-sa3, parry 2–28 |
| ke-z-sa3 | SA (ptr 3) | 7/3/12 (22; whiff R 20) | 7-10 40 flinch | 16 / 20 / 20 / 20 / 20 | 1.80 / 1.80 m, 100° | 0.4 | +3 | -2 | hs 5  | — |  |
| ke-z-n3b | NS3b | 12/4/20 (36; whiff R 32) | 12-16 70 stagger | 28 / 35 / 35 / 35 / 35 | 2.30 / 2.30 m, 30° | 1.5 | +2 | -4 | hs 8  | 20 | ns-next ke-z-n3c, sa ke-z-sa3 |
| ke-z-n3c | NS3c | 14/4/20 (38; whiff R 32) | 14-18 95 crumple | 38 / 48 / 48 / 48 / 48 | 1.90 / 1.90 m, 70° | 0.0 | +16 | -4 | hs 10  | 30 | sa ke-z-sa3 |
| | | | | | | | | | | | `ke-z-n3a`'s catch (:land) starts `ke-z-n3b` |
| ke-z-as1 | AS entry 1a | 16/4/20 (40; whiff R 26) | 16-20 90 knockdown | 36 / 45 / 45 / 45 / 45 | 1.90 / 1.90 m, 100° | 1.2 | KD | -4 | hs 10  | 25 |  |
| ke-z-as2 | AS entry 2a | 14/4/22 (40; whiff R 28) | 14-18 60 stagger | 24 / 30 / 30 / 30 / 30 | 1.80 / 1.80 m, 100° | 1.0 | +0 | -4 | hs 7  | 20 | ns-next ke-z-as2b |
| ke-z-as2b | AS entry 2b | 12/4/20 (36; whiff R 26) | 12-16 100 launch | 40 / 50 / 50 / 50 / 50 | 1.90 / 1.90 m, 100° | 0.6 | LAUNCH | -4 | hs 11  | 30 |  |
| ke-z-as3 | AS entry 3a | 12/4/20 (36; whiff R 26) | 12-16 50 stagger | 20 / 25 / 25 / 25 / 25 | 2.30 / 2.30 m, 30° | 1.5 | +2 | -4 | hs 6  | 15 | ns-next ke-z-as3b |
| ke-z-as3b | AS entry 3b | 10/3/12 (25; whiff R 18) | 10-13 50 stagger | 20 / 25 / 25 / 25 / 25 | 1.80 / 1.80 m, 100° | 0.4 | +11 | -2 | hs 6  | 15 | ns-next ke-z-as3c |
| ke-z-as3c | AS entry 3c | 14/4/20 (38; whiff R 26) | 14-18 140 knockdown | 56 / 71 / 71 / 71 / 71 | 2.30 / 2.30 m, 30° | 1.5 | KD | -4 | hs 14 guard-crush | 45 |  |

## Shikai NOZARASHI (`:kenpachi :nozarashi`)

Form x 1.00, :core :mult 1.20, *CORE-DAMAGE* 0.42: a hit deals base x 0.504 (x the victim's :taken, x the combo scale from hit 4, SP hits unscaled). Taken x 1.00; walk 4.4 / run 10.0 m/s; stun tolerance 26.0; Kikon Konpaku base 2; :hs-dmg (4 30 10 4 14); :as-by-press (1 1 2); :as-writes (1 2 3); :sp-cost-mult 0.68; passives (projectile-cut).

| move | class | S/A/R (total; whiff R) | hit windows (from-to base react) | dealt (sum, unscaled) vs I / IK / H / Hr / Hb | reach / edge, arc | slide | adv on hit (math) | adv on block | armour, hitstop, flags | SP cost | params |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ke-s-j1 | NA J1 | 9/3/12 (24; whiff R 20) | 9-12 40 flinch | 16 / 20 / 20 / 20 / 20 | 2.40 / 2.40 m, 100° | 0.8 | +3 | -2 | hs 5  | — |  |
| ke-s-j2 | NA J2 | 9/3/13 (25; whiff R 21) | 9-12 40 flinch | 16 / 20 / 20 / 20 / 20 | 2.40 / 2.40 m, 100° | 0.0 | +2 | -2 | hs 5  | — |  |
| ke-s-j3 | NA J3 | 11/4/18 (33; whiff R 26) | 11-15 55 stagger | 22 / 28 / 28 / 28 / 28 | 3.85 / 3.85 m, 140° | 0.0 | +4 | -4 | hs 6  | — |  |
| ke-s-j4 | NA J4 | 9/3/12 (24; whiff R 20) | 9-12 45 flinch | 18 / 23 / 23 / 23 / 23 | 2.40 / 2.40 m, 100° | 0.0 | +3 | -2 | hs 6  | — | lv 3, special-as |
| ke-s-j5 | NA J5 | 9/3/13 (25; whiff R 21) | 9-12 45 flinch | 18 / 23 / 23 / 23 / 23 | 2.40 / 2.40 m, 100° | 0.0 | +2 | -2 | hs 6  | — | lv 3, special-as |
| ke-s-j6 | NA J6 | 10/3/12 (25; whiff R 20) | 10-13 50 flinch | 20 / 25 / 25 / 25 / 25 | 2.40 / 2.40 m, 100° | 0.0 | +3 | -2 | hs 6  | — | lv 3, special-as |
| ke-s-j7 | NA J7 | 12/4/18 (34; whiff R 26) | 12-16 70 stagger | 28 / 35 / 35 / 35 / 35 | 3.85 / 3.85 m, 140° | 0.0 | +4 | -4 | hs 8  | — | lv 3, bankai-as |
| ke-s-n1a | NS1a | 16/4/22 (42; whiff R 34) | 16-20 70 stagger | 28 / 35 / 35 / 35 / 35 | 2.60 / 2.60 m, 100° | 3.0 | +0 | -4 | hs 8  | 20 | ns-next ke-s-n1b |
| ke-s-n1b | NS1b | 12/4/20 (36; whiff R 32) | 12-16 60 stagger | 24 / 30 / 30 / 30 / 30 | 2.80 / 2.80 m, 360° | 0.0 | +2 | -4 | hs 7  | 15 | lv 1, ns-next ke-s-n1c |
| ke-s-n1c | NS1c | 12/4/20 (36; whiff R 32) | 12-16 65 stagger | 26 / 33 / 33 / 33 / 33 | 2.80 / 2.80 m, 360° | 0.0 | +2 | -4 | hs 8  | 20 | lv 2, ns-next ke-s-n1d |
| ke-s-n1d | NS1d | 10/8/16 (34; whiff R 28) | 10-12 35 flinch; 16-18 35 stagger | 28 / 35 / 35 / 35 / 35 | 2.40 / 2.40 m, 100° | 0.0 | +8 | -4 | hs 4/4  | 20 | lv 3, ns-next ke-s-n1e |
| ke-s-n1e | NS1e | 14/4/24 (42; whiff R 36) | 14-18 100 crumple | 40 / 50 / 50 / 50 / 50 | 2.80 / 2.80 m, 100° | 2.0 | +12 | -6 | hs 11  | 25 | lv 3 |
| ke-s-n2a | NS2a | 14/3/16 (33; whiff R 28) | 14-17 45 stagger | 18 / 23 / 23 / 23 / 23 | 1.40 / 1.40 m, 70° | 1.0 | +7 | -4 | hs 6  | 10 | ns-next ke-s-n2b |
| ke-s-n2b | NS2b | 10/3/16 (29; whiff R 28) | 10-13 50 stagger | 20 / 25 / 25 / 25 / 25 | 1.20 / 1.20 m, 80° | 0.6 | +7 | -4 | hs 6  | 15 | ns-next ke-s-n2c |
| ke-s-n2c | NS2c | 16/5/24 (45; whiff R 36) | 16-21 110 crumple | 44 / 55 / 55 / 55 / 55 | 2.80 / 2.80 m, 90° | 0.0 | +11 | -6 | hs 12  | 30 | lv 1, ns-next ke-s-n2d |
| ke-s-n2d | NS2d | 14/4/20 (38; whiff R 32) | 14-18 100 stagger | 40 / 50 / 50 / 50 / 50 | 2.80 / 2.80 m, 140° | 0.0 | +2 | -4 | hs 11  | 25 | lv 2, ns-next ke-s-n2e |
| ke-s-n2e | NS2e | 18/5/28 (51; whiff R 40) | 18-23 140 crumple | 56 / 71 / 71 / 71 / 71 | 3.00 / 3.00 m, 120° | 0.0 | +7 | -8 | hs 14  | 40 | lv 3 |
| ke-s-sa | SA (kit) | 8/3/12 (23; whiff R 20) | 8-11 40 flinch | 16 / 20 / 20 / 20 / 20 | 2.20 / 2.20 m, 100° | 1.4 | +3 | -2 | hs 5  | — |  |
| ke-s-as1 | AS entry 1a | 14/4/22 (40; whiff R 28) | 14-18 70 stagger | 28 / 35 / 35 / 35 / 35 | 2.60 / 2.60 m, 100° | 3.0 | +0 | -4 | hs 8  | 20 | lv-up, ns-next ke-s-as1b |
| ke-s-as1b | AS entry 1b | 12/4/20 (36; whiff R 26) | 12-16 60 stagger | 24 / 30 / 30 / 30 / 30 | 2.80 / 2.80 m, 360° | 0.0 | +2 | -4 | hs 7  | 15 | lv 1, lv-up, ns-next ke-s-as1c |
| ke-s-as1c | AS entry 1c | 12/4/20 (36; whiff R 26) | 12-16 65 stagger | 26 / 33 / 33 / 33 / 33 | 2.80 / 2.80 m, 360° | 0.0 | +2 | -4 | hs 8  | 20 | lv 2, lv-up, ns-next ke-s-as1d |
| ke-s-as1d | AS entry 1d | 14/4/24 (42; whiff R 30) | 14-18 110 knockdown | 44 / 55 / 55 / 55 / 55 | 2.80 / 2.80 m, 100° | 2.0 | KD | -6 | hs 12  | 30 | lv 3, lv-up |
| ke-s-as2 | AS entry 2a | 12/3/16 (31; whiff R 22) | 12-15 50 stagger | 20 / 25 / 25 / 25 / 25 | 1.40 / 1.40 m, 70° | 1.0 | +7 | -4 | hs 6  | 15 | lv-up, ns-next ke-s-as2b |
| ke-s-as2b | AS entry 2b | 16/5/24 (45; whiff R 30) | 16-21 110 stagger | 44 / 55 / 55 / 55 / 55 | 2.80 / 2.80 m, 90° | 0.0 | -3 | -6 | hs 12  | 30 | lv 1, lv-up, ns-next ke-s-as2c |
| ke-s-as2c | AS entry 2c | 14/4/20 (38; whiff R 26) | 14-18 100 stagger | 40 / 50 / 50 / 50 / 50 | 2.80 / 2.80 m, 140° | 0.0 | +2 | -4 | hs 11  | 25 | lv 2, lv-up, ns-next ke-s-as2d |
| ke-s-as2d | AS entry 2d | 18/5/28 (51; whiff R 34) | 18-23 150 knockdown | 60 / 76 / 76 / 76 / 76 | 3.00 / 3.00 m, 120° | 0.0 | KD | -8 | hs 14  | 40 | lv 3, lv-up |
| ke-s-burst1 | AS entry 3a | 14/5/26 (45; whiff R 32) | 14-19 100 knockdown | 40 / 50 / 50 / 50 / 50 | 2.80 / 2.80 m, 120° | 0.0 | KD | -8 | hs 11  | 25 | burst (100 150 200 260) |
| ke-s-burst2 | AS entry 4a | 12/5/26 (43; whiff R 32) | 12-17 100 knockdown | 40 / 50 / 50 / 50 / 50 | 2.60 / 2.60 m, 100° | 3.5 | KD | -8 | hs 11  | 25 | burst (100 150 200 260) |
| ke-s-sp1 | AS entry 5a | 12/14/26 (52; whiff R 32) | 12-14 60 stagger; 18-20 60 stagger; 24-26 120 launch | 97 / 121 / 121 / 121 / 121 | 3.00 / 3.00 m, 360° | 0.0 | LAUNCH | -10 | hs 7/7/13  | 60 |  |
| ke-s-sp2 | AS entry 6a | 20/4/30 (54; whiff R 36) | 20-24 260 knockdown | 105 / 131 / 131 / 131 / 131 | 3.00 / 3.00 m, 90° | 3.0 | KD | -12 | hs 14  | 60 |  |
| ke-s-bankai | AS entry 7a | 12/3/24 (39; whiff R 30) | 12-15 100 knockdown kb5.0 | 40 / 50 / 50 / 50 / 50 | 3.20 / 3.20 m, 360° | 0.0 | KD | -10 | hs 11  | 25 | no-kikon |

## Bankai KYORAN (from Shikai pointer 1) (`:kenpachi :bankai`)

Form x 1.20, :core :mult 1.20, *CORE-DAMAGE* 0.42: a hit deals base x 0.605 (x the victim's :taken, x the combo scale from hit 4, SP hits unscaled). Taken x 1.00; walk 4.4 / run 10.0 m/s; stun tolerance 26.0; Kikon Konpaku base 4; :hs-dmg (4 30 10 4 14); :as-by-press (1 2 3); :as-writes (1 1 1 1 1); :sp-cost-mult 0.71; passives (projectile-cut).

| move | class | S/A/R (total; whiff R) | hit windows (from-to base react) | dealt (sum, unscaled) vs I / IK / H / Hr / Hb | reach / edge, arc | slide | adv on hit (math) | adv on block | armour, hitstop, flags | SP cost | params |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ke-kr-j1 | NA J1 | 7/3/11 (21; whiff R 19) | 7-10 40 flinch | 19 / 24 / 24 / 24 / 24 | 1.80 / 1.80 m, 100° | 0.8 | +4 | -2 | hs 5  | — | as-ptr 1 |
| ke-kr-j2 | NA J2 | 7/3/12 (22; whiff R 20) | 7-10 40 flinch | 19 / 24 / 24 / 24 / 24 | 1.80 / 1.80 m, 100° | 0.0 | +3 | -2 | hs 5  | — | as-ptr 2 |
| ke-kr-j3 | NA J3 | 8/3/12 (23; whiff R 20) | 8-11 45 flinch | 22 / 27 / 27 / 27 / 27 | 1.80 / 1.80 m, 100° | 0.0 | +3 | -2 | hs 6  | — | as-ptr 3 |
| ke-kr-j4 | NA J4 | 8/3/13 (24; whiff R 21) | 8-11 45 flinch | 22 / 27 / 27 / 27 / 27 | 1.80 / 1.80 m, 100° | 0.0 | +2 | -2 | hs 6  | — | as-ptr 4 |
| ke-kr-j5 | NA J5 | 10/4/18 (32; whiff R 26) | 10-14 65 stagger | 31 / 39 / 39 / 39 / 39 | 1.80 / 1.80 m, 100° | 0.0 | +4 | -4 | hs 8  | — | as-ptr 5 |
| ke-kr-na | NS1a | 14/4/20 (38; whiff R 32) | 14-18 80 stagger | 39 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 100° | 3.0 | +2 | -4 | hs 9  | 25 | ns-next ke-kr-nb |
| ke-kr-nb | NS1b | 10/4/18 (32; whiff R 30) | 10-14 70 stagger | 34 / 42 / 42 / 42 / 42 | 1.90 / 1.90 m, 360° | 0.0 | +4 | -4 | hs 8  | 20 | ns-next ke-kr-nc |
| ke-kr-nc | NS1c | 10/4/18 (32; whiff R 30) | 10-14 70 stagger | 34 / 42 / 42 / 42 / 42 | 1.90 / 1.90 m, 360° | 0.0 | +4 | -4 | hs 8  | 20 | ns-next ke-kr-nd |
| ke-kr-nd | NS1d | 8/8/14 (30; whiff R 26) | 8-10 40 flinch; 13-15 40 crumple | 39 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 100° | 0.0 | +23 | -4 | hs 5/5  | 25 |  |
| ke-kr-sa | SA (kit) | 8/3/11 (22; whiff R 19) | 8-11 40 flinch | 19 / 24 / 24 / 24 / 24 | 1.80 / 1.80 m, 100° | 0.8 | +4 | -2 | hs 5  | — | as-ptr 1 |
| ke-kr-as1 | AS entry 1a | 12/4/22 (38; whiff R 28) | 12-16 110 knockdown | 53 / 67 / 67 / 67 / 67 | 1.80 / 1.80 m, 100° | 2.0 | KD | -6 | hs 12  | 30 |  |
| ke-kr-as2 | AS entry 2a | 12/4/20 (36; whiff R 26) | 12-16 80 stagger | 39 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 100° | 3.0 | +2 | -4 | hs 9  | 25 | ns-next ke-kr-fin |
| ke-kr-fin | AS entry 2b | 12/4/22 (38; whiff R 28) | 12-16 110 knockdown | 53 / 67 / 67 / 67 / 67 | 1.80 / 1.80 m, 100° | 2.0 | KD | -6 | hs 12  | 30 |  |
| ke-kr-as3 | AS entry 3a | 12/4/20 (36; whiff R 26) | 12-16 80 stagger | 39 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 100° | 3.0 | +2 | -4 | hs 9  | 25 | ns-next ke-kr-as3b |
| ke-kr-as3b | AS entry 3b | 10/4/18 (32; whiff R 24) | 10-14 70 stagger | 34 / 42 / 42 / 42 / 42 | 1.90 / 1.90 m, 360° | 0.0 | +4 | -4 | hs 8  | 20 | ns-next ke-kr-fin |
| ke-kr-as4 | AS entry 4a | 12/4/20 (36; whiff R 26) | 12-16 80 stagger | 39 / 48 / 48 / 48 / 48 | 1.80 / 1.80 m, 100° | 3.0 | +2 | -4 | hs 9  | 25 | ns-next ke-kr-as4b |
| ke-kr-as4b | AS entry 4b | 10/4/18 (32; whiff R 24) | 10-14 70 stagger | 34 / 42 / 42 / 42 / 42 | 1.90 / 1.90 m, 360° | 0.0 | +4 | -4 | hs 8  | 20 | ns-next ke-kr-as4c |
| ke-kr-as4c | AS entry 4c | 10/4/18 (32; whiff R 24) | 10-14 70 stagger | 34 / 42 / 42 / 42 / 42 | 1.90 / 1.90 m, 360° | 0.0 | +4 | -4 | hs 8  | 20 | ns-next ke-kr-fin |
| ke-kr-sp | AS entry 5a | 12/4/44 (60; whiff R 50) | 12-16 300 knockdown | 145 / 181 / 181 / 181 / 181 | 2.40 / 2.40 m, 360° | 0.0 | KD | -10 | hs 14  | 60 | dmg-at 40 |

## Bankai ZANKAI (from Shikai pointer 2) (`:kenpachi :bankai-2`)

Form x 1.20, :core :mult 1.20, *CORE-DAMAGE* 0.42: a hit deals base x 0.605 (x the victim's :taken, x the combo scale from hit 4, SP hits unscaled). Taken x 1.00; walk 4.4 / run 10.0 m/s; stun tolerance 26.0; Kikon Konpaku base 4; :hs-dmg (4 30 10 4 14); :as-by-press (1 2 3); :as-writes (1 1 1 1 1); :sp-cost-mult 0.51; passives (projectile-cut).

| move | class | S/A/R (total; whiff R) | hit windows (from-to base react) | dealt (sum, unscaled) vs I / IK / H / Hr / Hb | reach / edge, arc | slide | adv on hit (math) | adv on block | armour, hitstop, flags | SP cost | params |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ke-zh-j1 | NA J1 | 9/3/12 (24; whiff R 20) | 9-12 50 flinch | 24 / 30 / 30 / 30 / 30 | 1.90 / 1.90 m, 100° | 0.6 | +3 | -2 | hs 6  | — | as-ptr 1 |
| ke-zh-j2 | NA J2 | 10/3/13 (26; whiff R 21) | 10-13 55 flinch | 27 / 33 / 33 / 33 / 33 | 1.90 / 1.90 m, 100° | 0.0 | +2 | -2 | hs 6  | — | as-ptr 2 |
| ke-zh-j3 | NA J3 | 10/4/16 (30; whiff R 24) | 10-14 55 flinch | 27 / 33 / 33 / 33 / 33 | 1.90 / 1.90 m, 140° | 0.0 | -2 | -3 | hs 6  | — | as-ptr 3 |
| ke-zh-j4 | NA J4 | 11/3/16 (30; whiff R 24) | 11-14 60 flinch | 29 / 36 / 36 / 36 / 36 | 1.90 / 1.90 m, 100° | 0.0 | -1 | -3 | hs 7  | — | as-ptr 4 |
| ke-zh-j5 | NA J5 | 13/4/20 (37; whiff R 28) | 13-17 85 stagger | 41 / 51 / 51 / 51 / 51 | 1.90 / 1.90 m, 100° | 0.0 | +2 | -4 | hs 10  | — | as-ptr 5 |
| ke-zh-na | NS1a | 16/5/24 (45; whiff R 36) | 16-21 100 crumple | 48 / 60 / 60 / 60 / 60 | 1.90 / 1.90 m, 90° | 0.0 | +11 | -6 | hs 11  | 20 | ns-next ke-zh-nb |
| ke-zh-nb | NS1b | 12/4/20 (36; whiff R 32) | 12-16 90 stagger | 44 / 54 / 54 / 54 / 54 | 1.90 / 1.90 m, 140° | 0.0 | +2 | -4 | hs 10  | 20 | ns-next ke-zh-nc |
| ke-zh-nc | NS1c | 14/4/20 (38; whiff R 32) | 14-18 100 stagger | 48 / 60 / 60 / 60 / 60 | 2.00 / 2.00 m, 180° | 0.0 | +2 | -4 | hs 11  | 20 | ns-next ke-zh-nd |
| ke-zh-nd | NS1d | 16/5/26 (47; whiff R 38) | 16-21 130 crumple | 63 / 79 / 79 / 79 / 79 | 2.00 / 2.00 m, 120° | 0.0 | +9 | -6 | hs 14  | 25 |  |
| ke-zh-sa | SA (kit) | 9/3/12 (24; whiff R 20) | 9-12 50 flinch | 24 / 30 / 30 / 30 / 30 | 1.90 / 1.90 m, 100° | 0.6 | +3 | -2 | hs 6  | — | as-ptr 1 |
| ke-zh-as1 | AS entry 1a | 16/5/26 (47; whiff R 32) | 16-21 150 knockdown | 73 / 91 / 91 / 91 / 91 | 2.00 / 2.00 m, 120° | 0.0 | KD | -8 | hs 14  | 30 |  |
| ke-zh-as2 | AS entry 2a | 12/5/24 (41; whiff R 30) | 12-17 100 crumple | 48 / 60 / 60 / 60 / 60 | 1.90 / 1.90 m, 90° | 0.0 | +11 | -6 | hs 11  | 20 | ns-next ke-zh-fin |
| ke-zh-fin | AS entry 2b | 16/5/26 (47; whiff R 32) | 16-21 150 knockdown | 73 / 91 / 91 / 91 / 91 | 2.00 / 2.00 m, 120° | 0.0 | KD | -8 | hs 14  | 30 |  |
| ke-zh-as3 | AS entry 3a | 12/5/24 (41; whiff R 30) | 12-17 100 crumple | 48 / 60 / 60 / 60 / 60 | 1.90 / 1.90 m, 90° | 0.0 | +11 | -6 | hs 11  | 20 | ns-next ke-zh-as3b |
| ke-zh-as3b | AS entry 3b | 12/4/20 (36; whiff R 26) | 12-16 90 stagger | 44 / 54 / 54 / 54 / 54 | 1.90 / 1.90 m, 140° | 0.0 | +2 | -4 | hs 10  | 20 | ns-next ke-zh-fin |
| ke-zh-as4 | AS entry 4a | 12/5/24 (41; whiff R 30) | 12-17 100 crumple | 48 / 60 / 60 / 60 / 60 | 1.90 / 1.90 m, 90° | 0.0 | +11 | -6 | hs 11  | 20 | ns-next ke-zh-as4b |
| ke-zh-as4b | AS entry 4b | 12/4/20 (36; whiff R 26) | 12-16 90 stagger | 44 / 54 / 54 / 54 / 54 | 1.90 / 1.90 m, 140° | 0.0 | +2 | -4 | hs 10  | 20 | ns-next ke-zh-as4c |
| ke-zh-as4c | AS entry 4c | 14/4/20 (38; whiff R 26) | 14-18 100 stagger | 48 / 60 / 60 / 60 / 60 | 2.00 / 2.00 m, 180° | 0.0 | +2 | -4 | hs 11  | 20 | ns-next ke-zh-fin |
| ke-zh-sp | AS entry 5a | 20/4/30 (54; whiff R 36) | 20-24 320 knockdown | 155 / 194 / 194 / 194 / 194 | 2.40 / 2.40 m, 90° | 0.0 | KD | -12 | hs 14  | 60 | dmg-at 34 |

## Kikon Konpaku by pointer (CORE-KIKON-COUNT: base by form, the struck SP's pointer, red = the victim under 30 % Reishi)

| form | base | ptr 1 | ptr 1 red | ptr 2 | ptr 2 red | ptr 3 | ptr 3 red | Soul Break ptr 1 / 2 / 3 |
|---|---|---|---|---|---|---|---|---|
| base | 2 | 1 | 1 | 2 | 3 | 1 | 1 | 3 / 3 / 5 |
| nozarashi | 2 | 1 | 1 | 2 | 3 | 1 | 1 | 3 / 3 / 5 |
| bankai | 4 | 3 | 3 | 4 | 5 | 3 | 3 | 5 / 5 / 5 |
| bankai-2 | 4 | 3 | 3 | 4 | 5 | 3 | 3 | 5 / 5 / 5 |

## Shared movement and resource rules (tuning.lisp)

| rule | value |
|---|---|
| Step | 2.5 m over 24 f, invulnerable 3-9, J cancel from f12 |
| Hoho | 100 flash-step, 24 f, invulnerable 1-14, reappears 1.6 m behind him on f6, lockout 60 f; perfect = his hit volume within 12 f: counter 60 dmg, stun 36, his input locked 40 f; refused while an exchange is undecided (DUEL_CORE §2.1.2) |
| Flash-step gauge | 0-300 (cells of 100), regen 4.5 / s after 60 f only below one cell; a J hit +10, an SA hit +15, a J / SA in a cancel +30 (DUEL_SP §5); a breakthrough takes 100 % above the last cell, gains 50 % |
| Burst | needs 100 flash-step; pushes the attacker 5.0 m over 20 f, invulnerable 20 f; drains 54 / s; SP attacks free during it |
| Combo scale | hits 1-3 full, then -15 % a hit, floor 20 % (SP / AS hits unscaled); 1 launch, 3 air hits a combo |
| Kikon | hold the SP from its segment's start to its hit + 12 f confirm; the victim is knocked 2.5 m, the strike follows |
| Awakening | gauge 100: +0.035 / dealt, +0.049 / taken, +10.5 / Konpaku lost; heals 20 % Reishi; once a match |
| Kenpachi | walk 4.4, run 10.0 m/s; stun tolerance 26; the Bankai's NS / AS segments burn 40 of his own Reishi (floor 1) |
