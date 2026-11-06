# Kenpachi data sheet for KI (step 1, 2026-11-06)

The KI style search (docs/duel/DUEL_MATCHUP_AI.md), Kenpachi's side, at HEAD d2a5555. **The per-move rows are generated**:
`sheet-data.md`, written by `sheet.lisp` from the kit data (the host loads the duel's plain-CL files as tests/duel-rules-test.lisp does and
walks each form's `:core`: the J string from `:commands :q` through `:strings`, each pointer's NS chain by `:ns-next`, each segment's SA, the
`:core :as` entries and their chains). Regenerate after a kit change:

    $ECL_HOST --norc --load docs/research/ki-ai/kenpachi/sheet.lisp | grep -v "^;;; Loading" > docs/research/ki-ai/kenpachi/sheet-data.md

The rows hold S/A/R, base damage, the damage dealt to Ichigo per hit, the reaction, reach / arc, adv on hit (frame math), adv on block (the
data), slide, armour, hitstop, flags and the `:params` a strategy reads (`ns-next`, `sa`, `lv`, `lv-up`, `special-as`, `bankai-as`,
`burst`, `as-ptr`, `dmg-at`, `no-kikon`, the parry window). This page holds what the rows cannot show: how the forms are entered and
left, the unlock level L, which AS a press count starts, the Kikon, the stances. Trial names (A1, D12 …) are `trials.lisp` entries, each
verified in the native sim (`catalogue.md`).

## Damage: base vs dealt

A hit deals base × the form's × `*core-damage*` 0.42 × the kit's `:core :mult` 1.2 × the defender's taken × the combo scale (full for hits
1–3, then −15 % a hit, floor 20 %; an SP / AS hit is unscaled), × (1 + 0.2 × the SUBLIMATION / DRIVE fraction) dealt and × (1 − 0.2 × it)
taken. Per base point on Ichigo's Shikai (taken 0.8): sealed and Shikai **0.403**, Bankai 0.484; on KESSA (taken 1.0) × 1.25. So J1's 35
is 14 Reishi (A1), the sealed J1–J5 75 (A2). Ichigo has 1300 Reishi and 9 Konpaku. The catalogue's dmg column is Reishi actually lost.

## The forms: in and out

| From → to | How | Kept / reset | Trials |
|---|---|---|---|
| Sealed (`:base`) → Shikai (`:nozarashi`) | the awakening: Mod+P with a full awakening gauge (once a match; the generic CPU presses it 2 % per decision once full) | Shikai at **L0**, pointer clamped to 1–2; the awakening heal and regen | (not trialled: the trial starts in a form) |
| Shikai → Bankai | **L3, J1–J7, SP**: `:ke-s-bankai` "BANKAI" (S12, 100 base, 3.2 m all round, knockdown, knockback 5 m, `:no-kikon`), the Bankai on its frame 15: **KYORAN** (`:bankai`) from pointer 1, **ZANKAI** (`:bankai-2`) from pointer 2 | nothing restored (§26.3); L stays 3 in the meter but the Bankai has no L | D41, D42, L4 |
| Bankai → Shikai | only the special AS (SP after the Bankai's J5): 千切 CHIGIRI (KYORAN) / TATE-GOTO (ZANKAI); when it is over, **−1 Konpaku** (none on his last), the Shikai on the pointer he came from, **L0** | Reishi as it is | E6, E25 (Konpaku −1, form back) |
| (none) | no timer, no other way out of the Bankai; every Bankai NS / AS segment burns **40 Reishi** of his own (floor 1) | | E2–E5 (self −40 a segment), L6 (−320) |

The Bankai entry leaves Ichigo knocked down **6.13 m** away with Kenpachi **+77** (D41). A KYORAN J1 that meets him before he is up whiffs
(D47: J1 40 frames after the Hoho); Hoho in and J1 44 frames after it (D43), or two Steps and J1 (D45), start a KYORAN string on his
first free frame (gap 0; 278 total with the entry string).

## The Shikai's unlock level L (DUEL_KEN_V3 §3–§13, as built)

- L 0–3, held in the kit meter; the awakening and the return from the Bankai start it at 0.
- **+1 once per combo** (the victim's combo, first hit to his return to neutral) that lands an NS segment (the temporary switch's
  included) or a same-pointer AS (`:lv-up`). A guarded, cancelled or armoured hit gives nothing. A level gained opens segments from the next
  route on (`core-snap-lv!` reads L at the route's / AS's start).
- **L0 → L3 in three combos**: three neutral NS1 lunges, each its own combo (D12: L0 → L3, 84 total). One combo with NS a, SA, J2, AS1 still
  gives one level (D10).
- **Reset to 0** by a burst (an AS that writes the other pointer) and by the Bankai's return. Nothing else drops it.
- Segments by L: pointer 1 NS a (L0), + b (L1), + c (L2), + d e (L3); pointer 2 NS a b (L0), + c (L1), + d (L2), + e (L3). The keeping AS:
  1 + L segments, its last at L3 a knockdown. J4–J7 only at L3 (`ken-link-ok`; at L2 the string stops at J3, D44).

## Which AS a press count starts

| Form | J presses + SP | AS | Pointer after |
|---|---|---|---|
| Sealed (`:as-by-press (1 1 2 2 3)`) | J1, J2 / SA | AS1 (1 seg, knockdown) | 1 |
| | J3, J4 | AS2 (2 seg, the last launches) | 2 |
| | J5 | AS3 (3 seg, the last knocks down, `:guard-crush`) | 3 |
| Shikai (`:as-by-press (1 1 2)`, `ken-as-pick`) | J1, J2 at pointer 1 | AS1, 1 + L segments | 1, L +1 if it lands |
| | J3 at pointer 1 | **burst** TOSSHIN-ISSEN (to pointer 2), 100 / 150 / 200 / 260 base by L | 2, L 0 |
| | J1, J2 at pointer 2 | **burst** ZANGAESHI (to pointer 1), 100 / 150 / 200 / 260 | 1, L 0 |
| | J3 at pointer 2 | AS2, 1 + L segments | 2, L +1 |
| | J4, J5, J6 (L3) | the pointer's special AS: DAISHARIN (pointer 1, 60 + 60 + 120, launch) / INSEKI-GIRI (pointer 2, 260, knockdown) | kept, L kept |
| | J7 (L3) | BANKAI (the entry, above) | the Bankai's one pointer |
| KYORAN / ZANKAI (`:as-writes (1 1 1 1 1)`, each J's `:as-ptr`) | Jn, n 1–4 | the one AS with n segments: NS a, b, c's cuts then the finisher (110 / 150 base, knockdown) | 1 |
| | J5 | the special AS (CHIGIRI 300 / TATE-GOTO 320, the damage on frame 40 / 34, `:dmg-at`) | back to the Shikai |

The SA (an attack pressed in an NS gap) counts as one attack press, and **a J after the SA goes on as J2** (DUEL_CORE: the SA "goes on into
J2"): NS … SA J2 … Jn + SP starts the AS of that press count (L1, L2, L5, L6), the Shikai's J4 / J7 too (L3 INSEKI-GIRI, L4 the Bankai).

## The Kikon

Hold the SP from its segment's start to its hit (the 12-frame confirm after it): the next strike is the Kikon. Konpaku taken =
`core-kikon-count` of the form's base and the struck SP's pointer: pointer 1 base − 1, pointer 2 base (base + 1 on a red victim), pointer 3
base − 1, at least 1. The Bankai's AS and special write pointer 1.

| Form (base) | Pointer 1 | Pointer 2 (red) | Pointer 3 | Off what (trials) |
|---|---|---|---|---|
| Sealed (2) | **1** | **2** (3) | **1** | AS1 C1, AS2b C2, AS3b C3, NS1a from neutral C4, NS2a C5, the tame's thrust C6 |
| Shikai (2) | 1 | 2 (3) | — | AS1 D50, AS2 D51, the lunge from 5 m D52, the burst to pointer 2 D53 (2), DAISHARIN D54 (1), INSEKI-GIRI D55 (2); not the BANKAI AS (`:no-kikon`, D56) |
| Bankai (4) | **3** | — | — | the AS E11 (3), CHIGIRI E7 / TATE-GOTO E26 (3, and Kenpachi −1 for the special) |

A held SP that never meets a hit, or a tap (C7), is an ordinary hit. The KESSA side's own Kikon base is 3 (not his concern here).

## Stances (the pointer's tell)

| Form | Pointer 1 | Pointer 2 | Pointer 3 |
|---|---|---|---|
| Sealed | the drag: one hand, tip on the floor (`:ke-z-st-1`) | the shoulder: blade on the shoulder, chest open (`:ke-z-st-2`) | chūdan, two hands (`:ke-z-st-3`) |
| Shikai | the cleaver slung, hilt low, half-crouched (`:ke-s-st-1`) | the blade's back on the shoulder, hilt forward (`:ke-s-st-2`) | — |
| Bankai | KYORAN: haft on the right shoulder (`:ke-b-kr-stance`) | ZANKAI: the low beast crouch (`:ke-b-zh-stance`) | — |

## Per-form traits a strategy reads

- **Sealed pointer 2's NS** (both drops) take one hit from frame 6 to the end of their active frames (`ken-armor`): an NS of his that the
  triangle lets land is absorbed, but **Kenpachi still loses its damage** (F5: self −37) and an NA of his cancels the drop (F6).
- **Sealed pointer 3's tame** (NS3a, no hit) catches a melee hit in frames 2–28 and answers with the thrust (`:parry`, before the triangle):
  his J1, NS1a and NS3 rush (F7–F9, 66 and +16). KESSA's NS clones are hazards: not caught (F23).
- **The Shikai and the Bankai cut projectiles** (`:projectile-cut`): an open hit window destroys a hazard it touches: J1 cuts the Getsuga
  wave (F28, F29, F32); the sealed form cannot (F31).
- **Reach**: sealed J 1.8 m (Ichigo's Shikai J1 1.1 m, KESSA's 1.56 m), the sealed NS1a 1.9 + a 1.2 slide, the thrust 2.3 + 1.5; the
  Shikai's J 2.4 m, its J3 / J7 3.85 m at 140°, NS1a 2.6 + a 3.0 lunge (hits from 5 m, D2), NS1 b / c 2.8 m all round, pointer 2's hilt
  only 1.4 (+ a 1.0 step); the Bankai 1.8–2.0 (KYORAN's NS a 1.8 + a 3.0 lunge, E10 from 4 m).
- **Startup**: sealed J1 **6** (the fastest press in KI; Ichigo's Shikai J1 is 14, KESSA's 8), NS1a 14; Shikai J1 9, NS1a 16; KYORAN J1 7,
  ZANKAI J1 9.
- Hitstop by base damage (`*ken-hs-dmg*`): 4 + (dmg − 30) / 10, 4–14 frames.
- The awakening, Burst, Step / Hoho and the temporary pointer switch (DUEL_SUBLIMATION §17; the CPU never switches: `core-switch-ready-p`
  wants no brain, so it is not trialled) are shared rules, not in the rows.
