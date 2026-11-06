# Ichigo's means against Kenpachi (KI matchup, steps 1–2; 2026-11-06)

**Context.** With both CPUs generic, Kenpachi wins 37 of 40 at HARD (DUEL_MATCHUP_AI §2). Every claim below names the trial in
`trials.lisp` that proves it (numbers: `catalogue.md`). Kenpachi's numbers are from `sheet.lisp -- kenpachi base nozarashi`.

## Corrections to DUEL_MATCHUP_AI §2's picture

- **"Ichigo never landed a Kikon" is a counting artefact.**
  - Diagnostic, not a gate: one native run of KI HARD, seeds 1–10 (`tools/simgate/run-log.lisp … 30000 31110 81000 81022 81030
    81040 200130`; Kenpachi won all 10).
  - Ichigo started **126** Kikon follow-ups. Kenpachi cancelled 97. **29 landed**: 13 of 13 on a red Kenpachi, 16 of 113 when
    he was not red. Konpaku taken: 18 x 1, 9 x 2, 2 x 3.
  - The landed Kikon line reads `P2 IC-N1A -> P1 KIKON 68`. aieval's hit regex (`-> P[12] (HIT|COUNTER)`) skips it.
- **Stun tolerance 26 is inert.** `*stun-blow-away*` has been NIL since 2026-10-10 (tuning.lisp), so no hidden stun blows
  anyone away. Ichigo's 11–15-hit routes all stay true combos on him (A12, B8, C8, D5).
- **`ken-armor`** is only his NS2's single armour hit, kept through the active frames.
  - It absorbs a wave: the damage counts, with no knockdown (M17 / M18, 97 dmg).
  - Against her J1 into his NS2a, both cancel and her AS1 lands (M12).
- **The same run shows Ichigo's charge habit.** Of 37 NS2 charge starts:
  - 18 were hit by Kenpachi before or after the charge, mostly his NS1a;
  - 10 ended in a wave hit;
  - 5 in an SA.

## The means, strongest first

1. **Own the 4–5 m band with NS3a (RANGETSU's lunge).** Needs pointer 3.
   - Her NS3a hits from 5.0 m (R5).
   - His sealed reach: NS1a 3.3 m (R11; misses at 3.6, M4), NS3b 3.6 m (M6; misses at 4.0, R13), J1 2.4 m (M1; misses at 2.7, R10).
   - From 4.6 m: NS3a SA J2–J5 AS3abc, 197, knockdown, +46 at 1.8 m (R25). Or AS2ab, 128, +69 at 4.3 m (R24).
   - The cleaver owns no band: her NS1a reaches 3.0–3.4 m (B3 / R1), the same as his NS1a.
   - Against his Shikai the band is gone: his NS1a (slide 3.0) reaches 4.6 m (R15).

2. **Punish his whiffs.** A whiff recovers R + 14: J1 28, NS1a 40, NS2a 42 frames after the active frames.
   - His J string whiffing at 3.2 m: NS1a at f2–f4, 37 (M23, M29), or NS3a at f8, 38 (M28).
   - His NS1a whiffing at 3.6 m: NS3a at f18 converts to **197** (M26, M27).
   - His NS2a whiffing at 4.0 m: NS1a at f6, or NS3a at f20 (M22, M30).
   - Her NS1a at 3.4 m also catches his walk-in (T14 / T15).
   - **Refuted**: NS3a at f10 runs into his active frames (M21). J1 can't reach a 3.2 m whiff (M24).

3. **Finish a Reishi bar at pointer 3.** A Soul Break while pointer 3 is in play takes **5** Konpaku. At pointer 1 or 2 it takes 3
   (Shikai) or 4 (KESSA).
   - Proof: the kill inside AS3, −5 (S1); a J kill at pointer 3, −5 (S4, S5); at pointer 1, −3 (S3); inside AS2, −3 (S2).
   - Every J5 + SP route writes pointer 3 and keeps it until the next AS (A12, B8, C8, D5, R25).
   - Two pointer-3 Soul Breaks are a K.O. from 9. The pointer survives Kikon and Soul Break resets (DUEL_CORE §2, default 6).
   - Pointer 3 also gives NS3a, means 1. The two combine.

4. **The Getsuga (JUJISHO, 82 dmg, knockdown, +55..+88) only where it can't be beaten.** Needs pointer 2.
   - Charging at 2 m loses: his J1 cancels the charge and his AS1 lands, 90 base (M13); his NS1a hits it (M14).
   - From 6.6 m it loses to a run-in (M15). From 7.5 m on it lands first: R17, R18, M16 (10 m), C4, C5 (13 m).
   - Against a walk-in it lands from 3.6–6.6 m (R19, R20, R28).
   - His Hoho goes through it (M19).
   - **Safe uses**: at ≥ 7.5 m, or point-blank inside a string.
     - AS2b's wave can't be escaped: he is still in hitstun, so a Hoho pressed then does nothing (R21).
     - J1–J4 AS2ab: 127, launch, +69 (A10).

5. **Hold for a Kikon when he is red, not before.**
   - Not red, his attack cancels the follow-up: NS1a's Kikon (E12) and the wave's Kikon (E15) both drop to 0 Konpaku.
   - The generic CPU cancels with `*cai-cancel-p*` 0.95 at HARD (0.7 NORMAL). In the diagnostic run, 16 of 113 non-red follow-ups
     landed.
   - Red, it can't be cancelled (E13; 13 of 13 in the run).
   - Pointer 2 against red takes the Soul Break's count: J1–J3 AS2a held = **−3** in the Shikai (E14), 4 in KESSA (the sheet's table).
   - Pointer 1 and 3 Kikons take 1 (E1, E9, E10), 2 in KESSA (K13, K16).

6. **Never open with J against his J.** His sealed J1 is S6 against her S14 (the 14-frame coil). On the same frame his J1 wins (M7).

7. **The triangle answers work only against a non-reader** (the generic Kenpachi CPU reads).
   - **Her NS against his J (M8 / M9)**: his J1 cancels her NS1a. If he stops, her NS1a lands (44) and her SA follows (66).
     - But his AS after the cancel absorbs her NS1a and lands 90, knockdown (T1–T4, T13). Her SA can't come in time.
     - Only his plain J2 loses to her SA (T5).
     - The generic CPU always takes that AS: in `cai-move-step`'s NA branch, once its link has landed or been cancelled, an
       opponent seen in an NS means AS, with no roll.
   - **Her J against his NS (M11 / M12)**: his NS cancels her J1. If he does nothing more, her J1 lands, then her AS1 (54).
     - But his SA in his NS gap (f20 / f28) absorbs her J1 and hits her (T6, T7). Her chain never opens, so her AS press starts
       nothing (T11, T12).
     - Only his late SA (f36+, T8 / T9) or his NS1b continuation (T10) loses.
     - The generic CPU takes that SA on `*cai-turn-p*` 0.8 (HARD) when it sees an NA.
   - **So at 1.7–3.6 m, where both CPUs fight, Ichigo's slower openers (J1 S14, NS1a S22, the charges) lose the read.** Her
     answers to that are ranges he can't reach (means 1, 4) and his whiffs (means 2).

8. **The best damage is the charged string, but only off a safe start.** Needs pointer 2.
   - NS2a NS2b SA-g2 J2–J5 AS3abc: 365 (C8); 428 against his Shikai (H2); 342 in KESSA (K8).
   - It needs about 36 frames of charges (NS2a 20, NS2b 16) at ≤ 2.4 m before the SA-g2 starts. His J1 > AS1 punishes that (M13).
   - At most a read after a knockdown. Not measured against an acting opponent.

9. **KESSA**: the same means, plus 20 % Reishi healed on entry and Kikon base 3.
   - NS1 (the chains) reaches 3.4 m and ends +9 (K5, R8).
   - NS3a's SA lunges from 4.2 m and ends +11 (R27).
   - AS2 routes end at +79, 4.8 m (K3, K6).
   - A J kill at pointer 3 takes 5 (S5).
   - Enter it from neutral only (L1; inside a move it is refused, L3).

## The means are pointer states

The NS an SP from neutral starts is the pointer's, and every AS writes its own. So each means is a state Ichigo has to be in, not a
button.

| Pointer | Its NS from neutral | Good for | Bad for | Written by |
|---|---|---|---|---|
| 1 | NS1 (the cleaver, 3.0–3.4 m) | his whiffs at ~3.2 m (M23, M29), his walk-in (T14) | no band of its own; loses the read up close (T1–T4) | AS1: J1 / J2 + SP, or SA (J2) + SP |
| 2 | NS2 (charges > JUJISHO) | the wave at ≥ 7.5 m (R17 / R18), a red Kikon of 3 (E14) | **anything inside ~3.6 m**: the charges are punished (M13, M14) | AS2: J3 / J4 + SP (A9, A10, B7, D4) |
| 3 | NS3 (RANGETSU's lunge, to 5.0 m) | the 4–5 m band (R5, R25), whiff punishes (M26–M30), the 5-Konpaku Soul Break (S1, S4) | his Shikai's 4.6 m NS1a (R15) | AS3: J5 + SP (A12, B8, C8, D5) |

- After any AS2 route Ichigo is at pointer 2. Inside 3.6 m her next NS is then the charge, the losing case. The point-blank wave
  is worth that only when the next exchange happens at range.
- Pointer 3 serves means 1, 2 and 3 at once: **the strongest state against the sealed form.**

## What the generic CPU (`duel/lisp/core-ai.lisp`) can never reach today

| Entry | Why not |
|---|---|
| Hoho off a hit (F1–F3) | The CPU never Hohos out of its own landed move (DUEL_CORE §8: "teaching the CPU this is left for later"). |
| A Kikon off a later segment: NS1b (E3), AS3c (E11), the wave Kikons (E6, E7, E8, K14, K15) | Only the first SP of a sequence can be held (`cai-sp`, 40 steps). Later NS / AS segments are always taps (`cai-press … 1 t` in `cai-move-step`). A ranged shot sets `brain-r-kikon` to 1, so it is never held. |
| NS3a from 4–5 m (R4, R5, R24, R25) | `cai-neutral` starts an NS only within `hi + 0.6` = 3.6 m (`*cai-range*` 1.7–3.0). |
| Whiff punishes (M20, M22, M23, M26–M30) | No whiff logic. Decisions come every 12–24 frames (HARD) whatever he does: these land only by chance. |
| The Getsuga from ≥ 7.5 m (R17, R18, M16, C4, C5) | Beyond 7 m the CPU dashes in to 4.5 m. It shoots only from 3.6–6.6 m (`:ns-range`), the band where a run-in beats it (M15). |
| Not charging in his face (M13 / M14 are its own habit) | Under pointer 2, inside 3.6 m the CPU starts its pointer's NS, the charges, with `*cai-ns-far*` 0.8 beyond 1.7 m. Kenpachi's CPU answers an NS with its AS (no roll) or its NS1a. 18 of 37 charges were hit in the diagnostic run. |
| Pointer steering: a 5-Konpaku Soul Break (S1, S4), a red pointer-2 Kikon (E14), keeping pointer 3 | The AS's number comes from how long the string ran: `*cai-cont-p*` rolls, 0.85 a link at HARD, so pointer 3 needs four in a row (≈ 0.52). The CPU never picks a pointer for the range or the Konpaku. |
| Kikon timing by red (E12 against E13) | It holds with `*cai-kikon-p*` 0.35 (HARD) when he is not red too, into his 0.95 cancel. Against red it rises to 0.6, which is the right direction. |
| The awakening at a chosen moment (L1) | `*cai-awaken-p*` 0.02 per decision once full. |

What it does reach:

- Its own reads: AS against his NS, SA against his NA, through `*cai-turn-p*`. They meet his identical reads (T1–T13).
- The charged SA (C6 / C7) when a charge's gap finds him inside 2.6 m. The x1.7 SA-g2 is rare: 0.2 (no turn at charge 1) x 0.85 x
  0.8 ≈ 0.14 a charge sequence.

## Not measured here

- Meaty starts on his wake-up:
  - after AS3 (+46, 1.8 m, pointer 3), NS3a;
  - after AS2 (+69, 4.3 m, pointer 2), the three-press wave lands about 76 f after the first press.

  Both need his CPU acting on wake-up to judge.
- The triangle answers at other timings than T1–T13. AS against SA is "later start wins", so a turn pressed later than his wins
  by the table. Not trialled.
- Kenpachi's Shikai routes against Ichigo, and his Bankai: the other agent's side.
