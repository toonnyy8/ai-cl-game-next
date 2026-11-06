# Ichigo's means against Kenpachi (KI matchup, steps 1–2; 2026-11-06)

**Context.** With both CPUs generic, Kenpachi wins 37 of 40 at HARD (DUEL_MATCHUP_AI §2), and Ichigo never landed a Kikon in 20
matches. Every claim below names the trial in `trials.lisp` that proves it (numbers: `catalogue.md`). Kenpachi's numbers are from
`sheet.lisp -- kenpachi base nozarashi`.

Two things the matchup doc lists as Kenpachi's assets are not what they seem:

- **Stun tolerance 26 is inert.** `*stun-blow-away*` has been NIL since 2026-10-10 (tuning.lisp), so no hidden stun ever blows
  anyone away. Ichigo's 11–15-hit routes all stay true combos on him (A12, B8, C8, D5).
- **`ken-armor`** is only his NS2's single armour hit, kept through the active frames.
  - It absorbs a wave: the damage still counts, with no knockdown (M17 / M18, 97 dmg).
  - Against her J1 it does nothing special: both moves cancel and her AS1 lands (M12).

## The means

1. **Never open with J against his J.** His sealed J1 is S6 against her S14 (the 14-frame coil); on the same frame his J1 wins
   (M7). Her J1 reaches 2.4 m, the same as his (A13 / R6, M1 / R10).

2. **Answer his NA with an NS, then the SA.**
   - His J into her NS1a cancels (NA against NS) and her NS goes on: 44 (M8).
   - The SA in the gap beats his next NA: 66 (M9, M10).
   - From the SA the string runs to an AS: NS1a SA J2–J5 AS3abc, 233 (B8).

3. **Answer his NS with a J, then the AS.**
   - Her J1 into his NS1a cancels, her chain opens, and AS1 beats his NS: 54, knockdown, +41 (M11).
   - The same works through his armoured NS2a (M12).

4. **Own the 4–5 m band with NS3a (RANGETSU's lunge).**
   - Her NS3a hits from 5.0 m (R5).
   - His sealed reach: NS1a 3.3 m (R11; misses at 3.6, M4), NS3b 3.6 m (M6; misses at 4.0, R13), J1 2.4 m.
   - From 4.6 m: NS3a SA J2–J5 AS3abc, 197, knockdown, +46 at 1.8 m (R25); or AS2ab, 128, +69 at 4.3 m (R24).
   - The cleaver doesn't own any band: her NS1a reaches 3.0–3.4 m (B3 / R1), the same as his NS1a.
   - Against his Shikai the band shrinks: his NS1a (slide 3.0) reaches 4.6 m (R15).

5. **Punish his whiffs.** A whiff recovers R + 14: J1 28, NS1a 40, NS2a 42 frames after the active frames.
   - His J string whiffing at 3.2 m: NS1a at f2–f4, 37 (M23, M29); or NS3a at f8, 38 (M28).
   - His NS1a whiffing at 3.6 m: NS3a at f18 converts to 197 (M26, **M27**).
   - His NS2a whiffing at 4.0 m: NS1a at f6 or NS3a at f20 (M22, M30).
   - **Refuted**: NS3a at f10 runs into his active frames (M21). J1 can't reach a 3.2 m whiff (M24).

6. **The Getsuga (JUJISHO, 82 dmg, knockdown, +55..+88) only where it can't be beaten.**
   - Charging at 2 m loses: his J1 cancels and his AS1 lands, 90 base (M13); his NS1a hits the charge (M14).
   - From 6.6 m it loses to a run-in (M15). From 7.5 m on it lands first: R17, R18, M16 (10 m), C4, C5 (13 m).
   - Against a walk-in it lands from 3.6–6.6 m (R19, R20, R28).
   - His Hoho goes through it (M19).
   - **The safe use is ≥ 7.5 m, or point-blank inside a string**: AS2b's wave can't be escaped. He is still in hitstun, so a
     Hoho pressed then does nothing (R21). J1–J4 AS2ab is 127, launch, +69 (A10).

7. **Hold for a Kikon only when he is red.**
   - Not red, his attack cancels the follow-up: NS1a's Kikon (E12) and the wave's Kikon (E15) both drop to 0 Konpaku.
   - The generic CPU cancels with `*cai-cancel-p*` 0.95 at HARD (0.7 NORMAL). **This is why Ichigo's Kikons never land.**
   - Red, the follow-up can't be cancelled (E13, −1).
   - Pointer 2 against a red victim takes the Soul Break's count: J1–J3 AS2a held = **−3** in the Shikai (E14), 4 in KESSA
     (the sheet's table).
   - Pointer 1 and 3 Kikons take only 1 (E1, E9, E10), 2 in KESSA (K13, K16).

8. **Finish a Reishi bar at pointer 3.** A Soul Break while pointer 3 is in play takes **5** Konpaku; at pointer 1 or 2 it takes 3
   (Shikai) or 4 (KESSA).
   - Proof: the kill inside AS3, −5 (S1); a J kill at pointer 3, −5 (S4, S5); at pointer 1, −3 (S3); inside AS2, −3 (S2).
   - Every J5 + SP route writes pointer 3 and keeps it until the next AS (A12, B8, C8, D5, R25).
   - Two pointer-3 Soul Breaks are a K.O. from 9. The pointer survives Kikon and Soul Break resets (DUEL_CORE §2, default 6).

9. **The best damage is the charged string, but only off a safe start.**
   - NS2a NS2b SA-g2 J2–J5 AS3abc: 365 (C8); 428 against his Shikai (H2); 342 in KESSA (K8).
   - It needs about 36 frames of charges (NS2a 20, NS2b 16) at ≤ 2.4 m before the SA-g2 starts. His J1 > AS1 punishes that (M13).
   - So it is a start for after a knockdown (AS1 / AS3 end at +41 / +46, 1.8 m), and even there it is a read, not a guarantee.
     It was not measured against an acting opponent.

10. **KESSA**: the same means, plus +20 % Reishi healed on entry and Kikon base 3.
    - NS1 (the chains) reaches 3.4 m and ends +9 (K5, R8). NS3a's SA lunges from 4.2 m and ends +11 (R27).
    - AS2 routes end at +79, 4.8 m (K3, K6).
    - Enter it from neutral only (L1; inside a move it is refused, L3).

## What the generic CPU (`duel/lisp/core-ai.lisp`) can never reach today

| Entry | Why not |
|---|---|
| Hoho off a hit (F1–F3) | The CPU never Hohos out of its own landed move (DUEL_CORE §8: "teaching the CPU this is left for later"). |
| Any Kikon off a later segment: NS1b (E3), AS3c (E11), the wave Kikons (E6, E7, E8, K14, K15) | Only the first SP of a sequence can be held (`cai-sp`, 40 steps). The next NS / AS segments are always taps (`cai-press … 1 t` in `cai-move-step`). A ranged shot sets `brain-r-kikon` to 1 (never held). |
| NS3a from 4–5 m (R4, R5, R24, R25) | `cai-neutral` starts an NS only within `hi + 0.6` = 3.6 m (`*cai-range*` 1.7–3.0). |
| Whiff punishes (M20, M22, M23, M26–M30) | No whiff logic. Decisions come every 12–24 frames (HARD) whatever he does, so these land only by chance. |
| The Getsuga from ≥ 7.5 m (R17, R18, M16, C4, C5) | Beyond 7 m the CPU dashes in to 4.5 m. It shoots only from 3.6–6.6 m (`:ns-range`), the band where a run-in beats it (M15). |
| Not charging in his face (M13 / M14 are the CPU's own habit) | Under pointer 2, inside 3.6 m the CPU starts the NS of its pointer, the charges, with `*cai-ns-far*` 0.8 (beyond 1.7 m). Kenpachi's CPU then turns with AS on seeing an NS (`oc :ns`, `*cai-turn-p*` 0.8 HARD). A loss pattern by construction. |
| Pointer steering for a 5-Konpaku Soul Break (S1, S4) or a red pointer-2 Kikon (E14) | The AS's number comes from how long the string ran: `*cai-cont-p*` rolls, 0.85 a link at HARD, so pointer 3 needs four in a row (≈ 0.52). The CPU never picks the pointer for the Konpaku. |
| Kikon timing by red (E12 against E13) | The CPU holds with `*cai-kikon-p*` 0.35 (HARD) when he is not red too, straight into his 0.95 cancel. Against red it rises to 0.6, which is the right direction. |
| The awakening at a chosen moment (L1) | `*cai-awaken-p*` 0.02 per decision once full. |

The reads it does have: SA against his NA (M9 / M10) and AS against his NS (M11) are reachable through `*cai-turn-p*`. The charged SA
(C6 / C7) is reachable when a charge's gap finds him inside 2.6 m. The x1.7 SA-g2 is rare: 0.2 (no turn at charge 1) x 0.85 x 0.8
≈ 0.14 a charge sequence.

## Not measured here

- Meaty starts on his wake-up:
  - after AS3 (+46, 1.8 m, pointer 3), NS3a;
  - after AS2 (+69, 4.3 m, pointer 2), the three-press wave lands about 76 f after the first press.
  
  Both need the CPU acting on wake-up to judge.
- Kenpachi's Shikai routes against Ichigo, and his Bankai: the other agent's side.
