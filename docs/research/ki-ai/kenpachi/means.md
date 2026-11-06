# Kenpachi's means against Ichigo (step 2's short list, 2026-11-06)

Every line cites `trials.lisp` entries (results in `catalogue.md`). dmg = Reishi Ichigo loses (his Shikai unless KESSA is named).

## What beats what Ichigo does

| Ichigo does | Kenpachi's means | Proof |
|---|---|---|
| **NA**: Shikai J1 (S14, 1.1 m), KESSA J1 (S8, 1.56 m) | his own J1: S6, 1.8 m; his J never lands. The Shikai's J1 (S9, 2.4 m) too | F1, F21, F27 |
| NA into Kenpachi's NS | the SA (J in the NS gap) absorbs it and hits; the pointer 3 tame parries it into the thrust (66, +16). Not pointer 2's armour: his NA cancels the drop | F4, F7; F6 |
| **NS** from neutral (NS1 a S22, the Getsuga charges, the NS3 rush's first cut on f18, KESSA's lash S22 3.0 m) | the sealed NS1 a (S14): NS against NS, the first hit wins: 76 with b c, +16 | F3, F24, F20 (KESSA 96) |
| | J1 to cancel his NS (NA vs NS), then an AS, which beats an NS: J1 J2 AS1, 36 and a knockdown (+56) | F2 |
| | the tame catches his NS1 a and his NS3 rush (66, +16) | F8, F9 |
| | pointer 2's NS a absorbs his NS hit and lands (34, +14), but Kenpachi still takes the damage (−37) | F5 |
| **Getsuga route at 3.6–6.6 m** (charge 20 f, charge 16 f, then JUJISHO; at 5 m the wave hits on f70, 82 to Kenpachi) | the charges are NS windows with no hit: close and hit with an NS. Hoho at once then NS1 a b c (76, +16; KESSA 96), Step in or walk 24 f then NS1 a b c (76) | F11, F22, F12, F13 |
| | Hoho, J1 J2 AS1 (the J cancels a charge, the AS lands): 36, +56 | F10 |
| | the Shikai's NS1 lunge reaches 5.6 m: from 5 m at once (28), from 6.6 m a Step first; KYORAN's lunge after a Hoho (39) | F15, F16, F18 |
| | **cut the wave**: the Shikai's or a Bankai's J1 pressed f49–f57 at 5 m (`:projectile-cut`), unhurt. Not the sealed form | F28, F29, F32; F30, F31 |
| | Hoho late (f55): through the wave | F17 |
| | not: the sealed NS1 a from 3.6 m stands short (1.9 + 1.2 m) and eats the wave | F25 |
| **KESSA clones** (NS3, Step / Hoho posts) | the tame does **not** catch a clone's hit (a hazard). NS-first (F20) and the J1 race (F21) work on KESSA as on the Shikai; the clones are otherwise not trialled | F23 |
| Wakes up after a knockdown | a meaty J1 on his first free frame loops J1 J2 AS1 (64 a loop, +56 each time; gap 0 when J1 starts 29 f after Kenpachi can move); after J1–J5 AS3 a Step and J1 J2 AS1 (235 in all); after the BANKAI AS (6.13 m, +77) Hoho or two Steps and a KYORAN string (278 in all) | K1, K3, D43, D45; 12 f late he acts first (K2); too early whiffs (D47) |

## Which form, which route

- **Sealed**: the J race and NS-first. Damage routes: J1–J5 AS3 171; NS1 a b c SA J2–J5 AS3 **214** (L1); NS2 a b SA J2 J3 AS2 173 with a launch
  (+77, L2). The cheapest 2-Konpaku Kikon: pointer 2 NS a held from neutral (C5).
- **Shikai**: L0 → L3 by three neutral lunges, one a combo (D12); at L2 the pointer 2 route NS a–d SA J2 J3 AS2 **251** ends at L3 and +2
  close (L5); at L3 J1–J3 AS2 (4 seg) 221 (D33), INSEKI-GIRI 174–198 (D39, D40), DAISHARIN 166–190 with a launch (D37, D38). Avoid the burst
  unless it ends the round: 94–159 and L back to 0 (D5–D34). The Shikai J1 also cuts the Getsuga (F28).
- **Bankai**: L3 J1–J7 + SP (145, +77 at 6.13 m), then KYORAN / ZANKAI strings: ZANKAI NS a–d SA J2–J4 AS **461** for 320 of his own
  Reishi (L6), J1–J4 AS 319 (E24); the way back is the special AS (CHIGIRI 247, TATE-GOTO 288, −1 Konpaku to him; its Kikon −3 to Ichigo,
  E7, E26).

## What the generic CPU (duel/lisp/core-ai.lisp) can never reach, and why

1. **J4–J7, the special AS, the Bankai.** `cai-move-step` ends an NA string with an SP once `fighter-presses` reaches the length of the
   kit's `:as-by-press` (or a link with `:as-ptr` 3): the Shikai's is `(1 1 2)`, so after J3 it always presses SP. J4 is never pressed, so
   neither the special AS (J4–J6 + SP: D37–D40) nor the BANKAI AS (J7 + SP: D41) can happen, whatever L is.
2. **L3 itself is rare.** Every forced J3 + SP at pointer 1 is a burst to pointer 2 (L back to 0), and at pointer 2 an SP after J1 / J2 (15 %
   a link at HARD, or whenever his NS shows) is the burst back. The CPU never aims for L (D12's three lunges are a deliberate plan).
3. **A CPU in the Bankai could never leave it.** The Bankai kits have no `:as-by-press`, so the default `(1 2 3)` forces the AS at J3
   (and KYORAN / ZANKAI's J3 has `:as-ptr 3`, the other forced case): J5 + SP, the only way back to the Shikai, never comes, while every
   NS / AS segment burns 40 of his Reishi.
4. **Ranged answers.** Kenpachi has no `:ns-range`, so between 3.6 and 6.6 m the CPU just walks in at `*cai-range*` (1.7–3.0 m): into the
   Getsuga. It never Hohos on purpose through the wave (its Hoho roll reads a move's reach, one roll per attack), never cuts it with J1
   (F28), never starts the Shikai lunge from 5 m (it starts moves only within 3.6 m).
5. **Timing it never does**: the meaty J1 on his wake-up (K1, D43), the tame as a read (it is just pointer 3's NS after AS3, K4), pointer 2
   NS held for the 2-Konpaku Kikon on purpose (its Kikon hold is a 35 % roll per SP at HARD, any pointer).
6. **The temporary pointer switch** (DUEL_SUBLIMATION §17) is closed to every CPU (`core-switch-ready-p` wants a fighter with no brain).
