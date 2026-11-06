# Ichigo vs Kenpachi: the catalogue (KI matchup, step 2, sim-verified; 2026-11-06)

`python3 tools/combo-trial.py docs/research/ki-ai/ichigo/trials.lisp` (HEAD d2a5555 + this branch's `tools/simgate/trial.lisp`).
Every trial ran in the native sim. P1 is Ichigo pressing only its script. P2 is Kenpachi: his sealed form (`:base`) unless the
trial says Shikai (`:nozarashi`). He stands still unless `:p2-press` makes him act.

All 174 trials are deterministic: two full runs gave byte-identical tables.

**Columns**
- **dmg**: Reishi he lost, after scaling. The sim's damage against sealed Kenpachi is about 0.53 x the kit's base (J1 32 → 17,
  JUJISHO 150 → 82). This includes the 1.3 core :mult, his taken factor and SUBLIMATION 0.
- **gaps**: per hit after the first, the frames he could act before it. 0 = a true combo.
- **adv**: his first free frame minus Ichigo's, after the last hit. A knockdown counts his wake-up. `?` = one of them was not free
  by the trial's end.
- **dist**: centre to centre at the end.
- **FS**: Ichigo's flash-step change.
- **Konpaku**: his Konpaku change. A Kikon shows dmg ≤ 0, because his Reishi refills with the Konpaku lost.
- **log**: the hits, base damage. `[n] P2 …` = his hits on Ichigo.

## Findings

### Hit-confirmed routes (every gap 0), Shikai vs sealed Kenpachi

| Route | Starts at | dmg | Ends | Notes |
|---|---|---|---|---|
| NS2a NS2b SA-g2 J2 J3 J4 J5 AS3abc (C8) | 2.0 m, pointer 2 | **365** | knockdown, **+46**, 1.8 m, pointer 3 | the x1.7 charge through the whole string; 428 vs his Shikai (H2); 64 f of charging first (see M13 / M14) |
| NS1a SA J2–J5 AS3abc (B8) | 2.4 m, pointer 1 | 233 | knockdown, +46, 1.8 m, pointer 3 | the cleaver's opener into the long string |
| NS3a SA J2–J5 AS3abc (D5) | 3.0 m, pointer 3 | 217 | knockdown, +46, 1.8 m, pointer 3 | the same from 4.6 m: 197 (R25); off his whiff: 197 (M27) |
| J1–J5 AS3abc (A12) | 1.6 m | 202 | knockdown, +46, 1.8 m, pointer 3 | 243 vs his Shikai (H1) |
| NS2ab SA-g2 J2 J3 AS2ab (C7) | 2.0 m, pointer 2 | 183 | launch, **+69**, 4.3 m, pointer 2 | |
| NS1a NS1b SA J2 J3 AS2ab (B9) | 2.4 m | 176 | launch, +69, 4.3 m, pointer 2 | |
| NS2a SA-g1 J2 J3 AS2ab (C6) | 2.0 m | 149 | launch, +70, 4.5 m | x1.4 |
| NS1a SA J2 J3 AS2ab (B7) | 2.4 m | 148 | launch, +69, 4.3 m | |
| NS3a SA J2 J3 AS2ab (D4) | 3.0 m | 140 | launch, +69, 4.3 m | from 4.6 m: 128 (R24) |
| NS1a-c SA (B10) | 2.4 m | 132 | +3, 0.9 m | NS1c's crumple (40 f) leaves room for the SA, then J2 … |
| J1–J4 AS2ab (A10) / J1–J3 AS2ab (A9) | 1.6 m | 127 / 111 | launch, +69, 4.3 m | AS2b's point-blank wave can't be Hoho'd (he is still in hitstun: R21) |
| NS1a-c (B2) | 2.4–3.0 m | 116 | crumple, +1, 1.4 m | |
| J1–J5 AS3a (A11) | 1.6 m | 107 | +5, 1.9 m | AS3a alone: the string goes on (no knockdown) |
| NS1a SA J2 AS1 (B6) / NS1a SA AS1 (B5) | 2.4 m | 100 / 83 | knockdown, +41, 1.95 m, pointer 1 | AS1 steals 120 flash step |
| NS3ab (D2/D3) | 3.0–4.2 m | 80–83 | crumple, +6, 0.9 m | |
| J1–J5 (A5) | 1.6 m | 82 | **+5**, 2.5 m | no SP: the pointer stays |
| J1 J2 AS1 (A7) / J1 AS1 (A6) | 1.6 m | 61 / 44 | knockdown, +41, 1.8 m | |

**KESSA** (`:form :kessa`, the same dummy):

| Route | dmg | Ends | Notes |
|---|---|---|---|
| NS2ab SA-g2 J2–J5 AS3abc (K8) | **342** | knockdown, +41, 1.9 m | his AS3 with the clones (18, 38 + 38) |
| NS3ab SA J2–J5 AS3abc (K11) | 204 | +41, 1.9 m | the clones replay every J / AS at x0.1 (3–5 a hit) |
| J1–J5 AS3abc (K4) | 193 | +41, 1.9 m | |
| NS3abc SA J2 J3 AS2ab (K10) | 163 | launch, +65, 5.0 m | |
| NS1a SA J2 J3 AS2ab (K6) / J1–J3 AS2ab (K3) | 139 / 105 | launch, **+79**, 4.8 m | |
| NS1a-c, the chains (K5) | 104 | **+9**, 2.8 m | reach 3.0–3.4 m (R8 at 3.4 hits, R9 at 3.8 misses) |
| NS3abc, the clones' X (K9) | 59 | +1, 1.8 m | |
| J1 AS1, the whip (K2) | 44 | knockdown, +55 | |
| NS3a SA (K12 / R27) | 28 / 26 | **+11** | the SA's 3 m lunge: hits from 4.2 m |

### The Kikon (a held SP), by pointer

| Trial | Hold | Konpaku | Notes |
|---|---|---|---|
| E1 / E2 NS1a held 80 / 40 | pointer 1 | −1 | 40 steps from the press is enough (the hold runs only on sim frames, not in the hitstop) |
| E3 NS1a NS1b held | 1 | −1 | the second segment's hit is a Kikon too |
| E4 J1 AS1 held | 1 (written) | −1 | |
| E5 J1–J3 AS2a held | 2 | **−2** | |
| E6 J1–J3 AS2a AS2b held | 2 | −2 | the wave's Kikon: `IC-WAVE-STRIKE-AS` 80 |
| E7 / E8 NS2abc held at 6.6 / 10 m | 2 | −2 | JUJISHO's Kikon: he flash-steps in from 10 m |
| E9 NS3a / E10 AS3a / E11 AS3c held | 3 | −1 | |
| **E12** NS1a held, **he attacks** in the follow-up | 1 | **0** | `P2 cancels the Kikon follow-up` |
| **E15** NS2abc held, he attacks | 2 | **0** | the wave's Kikon is cancelled the same way |
| **E13** NS1a held, he is **red** and attacks | 1 | −1 | red: no cancel |
| **E14** J1–J3 AS2a held, red | 2 | **−3** | pointer 2 against red = the Soul Break's count |
| K13 / K17 KESSA NS1a / AS1 held | 1 | −2 | KESSA base 3 |
| K14 / K15 KESSA wave Kikons | 2 | **−3** | |
| K16 KESSA AS3a held (千影) | 3 | −2 | |

### The triangle against him (`:p2-press`)

- **M7**: J1 against his J1 on the same frame, 1.6 m. **His J1 wins**: S6 against S14.
- **M8 / M9**: his J1 (f8) into her NS1a cancels: NA against NS, no damage, both go on. If he stops there, her NS1a lands (44)
  and her SA follows (66).
- **But he can turn (T1–T4, T13)**: his AS1 pressed after that cancel (f15 / f20 / f30) absorbs her NS1a and lands (90 base,
  knockdown) every time.
  - Her SA can't come in time: NS1a's gap opens after f26.
  - Only if he goes on with a plain J2 does her SA win (T5, 34).
  - The generic CPU always turns here: it presses the AS when it sees an NS after its link landed or cancelled.
- **M10** does not isolate SA against his NA: her NS1a hit him first.
- **M11 / M12**: her J1 into his NS1a (or his armoured NS2a) cancels, then her J1 lands and her AS1 follows (54 / 33). Only when
  he does nothing in his NS gap.
- **His SA in his NS gap (T6, T7)**, pressed at f20 / f28, absorbs her J1 and hits her (30). Her J1 never lands, so her chain never
  opens: an AS press then starts nothing (T11, T12).
  - Only a late SA (f36, f44) loses to her J1 > AS1 (T8, T9).
  - His NS1b continuation loses to her AS1 (T10).
  - The generic CPU takes that SA on its turn roll (`*cai-turn-p*` 0.8 HARD) when it sees an NA.
- **T14 / T15**: her NS1a at 3.4 m catches his walk-in (36; then the SA, 54).
- **M13**: her NS2 charge at 2.0 m. His J1 cancels it and his AS1 lands (**90 base, knockdown**). **M14**: his NS1a simply hits
  the charge (65). Charging near him is punished; the generic CPU does exactly this, since it turns to the AS on seeing an NS.
- **M15**: NS2abc at 6.6 m. He runs in at f0 (Step held) and his NS1a hits before the wave leaves.
  - **R17** (7.5 m), **R18** (8.5 m), **M16** (10 m): run in, and the wave lands first (82).
  - **R19 / R20**: walking in from 6.6 m, the wave lands.
  - **R28**: at 3.6 m, his J1 (f10) whiffed and his later SP never started. The wave lands.
- **M17 / M18**: his armoured NS2a on the wave. `WAVE ARMORED`: the damage counts (97), with no knockdown, so he goes on.
  **M19**: his Hoho goes through the wave (0).
- **M25**: his J1 AS1 held. Her J press in the follow-up cancels his Kikon (she is not red).

### Means 1–2 against an opponent who keeps acting (U1–U12)

- **NS3a from 4.6 m into his J1**, at f8 / f12 / f16: his J1 cancels her first cut, and her later cuts still land (38 / 30 / 10)
  (U1, U2, U5).
- **With his AS read after that cancel**, his AS1 absorbs all her cuts and lands 90 (U3).
- **Into his NS1a at f4**: both cancel, nothing lands (U4).
- **His NS whiff with the next segment pressed**:
  - NS1a > NS1b: her NS3a at f18 is hit by NS1b, 55 (U6); NS1c follows, 70 (U8). Waiting until f32 lands it (U7).
  - NS2a > NS2b: her NS1a at f6 hits armoured NS2a (36, no reaction) (U10); her NS3a at f20 is hit by NS2b, 95 (U11).
  - His NS1a > his SA (whiffing at 3.6 m): her NS3a lands (U9).
- **His J whiff can't chain** (no contact, `chain-open-p`): a J2 pressed after a whiffed J1 starts nothing, and her NS1a lands (U12).

### The range band (centre to centre, a standing target)

| Move | Hits at | Misses at |
|---|---|---|
| her J1 | 2.4 (A13) | 2.6 (R6) |
| his J1 (sealed) | 2.4 (M1) | 2.7 (R10), 3.0 (M2) |
| her NS1a | 3.0 (B3) | 3.4 (R1) |
| his NS1a (sealed) | 3.3 (R11) | 3.6 (M4) |
| his NS2a (sealed) | — | 3.2 (R12), 3.6 (M5) |
| his NS3b (sealed) | 3.6 (M6) | 4.0 (R13) |
| her NS3a (RANGETSU's lunge) | **5.0 (R5)** | 5.4 (R22) |
| her charged SA-g1 (the lunge) | 3.5 (C10) | |
| KESSA NS1a (chains) / SA lunge | 3.4 (R8) / 4.2 (R27) | 3.8 (R9) |
| his Shikai NS1a / J1 | 4.6 (R15) / 3.0 (R16) | |
| JUJISHO's wave | 2.4–13 m (C1–C5) | |

The cleaver (NS1a) and his NS1a reach about the same, 3.0–3.4 m. Against the sealed form, **only her NS3a reaches 4.0–5.0 m**,
and only the wave reaches past that. His Shikai NS1a (slide 3.0) reaches 4.6.

### His whiffs, punished

His whiff recovery is R + 6 + 8 (`*whiff-extra*` + `*whiff-add*`): J1 28, NS1a 40, NS2a 42 frames after the active frames
(sheet: `sheet.lisp -- kenpachi base`).

| Trial | Whiff | Her answer | dmg |
|---|---|---|---|
| M23 | his J1–J3 at 3.2 m | NS1a at f4 | 37 |
| M29 | his J1 at 3.2 m | NS1a at f2 | 37 |
| M28 | his J1 at 3.2 m | NS3a at f8 | 38 |
| M20 | his NS1a at 3.6 m | NS1a at once (his slide brings him in) | 44 |
| M26 / M27 | his NS1a at 3.6 m | NS3a at f18 / then SA J2–J5 AS3abc | 38 / **197** |
| M22 | his NS2a at 4.0 m | NS1a at f6 | 44 |
| M30 | his NS2a at 4.0 m | NS3a at f20 | 38 |

### Refuted or limited (kept in the file as proofs, not as means)

- **M8–M12 as answers to his moves**: they hold only if he takes no turn himself. His AS after his J's cancel (T1–T4, T13) and
  his SA in his NS gap (T6, T7, T11, T12) beat them.
- **M21**: NS3a at f10 against his NS1a whiff. Her lunge runs into his active frames and his NS1a hits her. Wait until f18 (M26).
- **M24**: J1 against his J1 whiff at 3.2 m. Out of her J1's reach.
- **L3**: the awakening pressed inside the J string does nothing. Only from neutral (L1).
- **R1–R3, R6/R7, R9, R22/R23**: beyond reach, as in the band above.
- **G1 / G2**: the `:dummy :guard` still blocks (J1–J3 −16, NS1a −9), but the core system has no guard input. **Unreachable in
  play**; no entry is built on block advantage.

### The Soul Break by pointer (his Reishi set low, `:p2-reishi`)

| Trial | The kill | Konpaku |
|---|---|---|
| S1 | J1–J5 AS3abc, the kill inside AS3 (pointer 3 written) | **−5** |
| S2 | J1–J4 AS2ab, the kill inside AS2 | −3 |
| S3 | a J kill at pointer 1 | −3 |
| S4 | a J kill at **pointer 3** (an earlier AS3) | **−5** |
| S5 / S6 | KESSA, a J kill at pointer 3 / 1 | **−5** / −4 |

Once the pointer is 3, any kill takes 5 of his 9 Konpaku: two such Soul Breaks are a K.O. At pointer 1 or 2 a kill takes 3
(Shikai) or 4 (KESSA).

### Hoho off a hit (DUEL_CORE §8)

- F1 J1 Hoho J2 J3: 63, gaps 0.
- F2 NS1a Hoho NS1b: 84, gaps 0.
- F3 J1 Hoho AS1: 54, gaps 0.

Each costs 100 flash step (−84 with the regen).

## All trials

| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | Konpaku | log |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A1 J1 | 17 | 1 | 1 | — | 3 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32 |
| A2 J1 J2 | 34 | 2 | 2 | 0 | 2 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32 |
| A3 J1-J3 | 51 | 3 | 3 | 0 0 | 2 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32 |
| A4 J1-J4 | 67 | 4 | 4 | 0 0 0 | 3 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34 |
| A5 J1-J5 | 82 | 5 | 5 | 0 0 0 0 | 5 | 2.50 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40 |
| A6 J1 AS1 (flash step 150: the steal) | 44 | 2 | 2 | 0 | 41 | 1.83 | +0 | +149 | 0 / 0 | +0 | IC-J1 HIT 32; IC-AS1 HIT 50 |
| A7 J1 J2 AS1 | 61 | 3 | 3 | 0 0 | 41 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-AS1 HIT 50 |
| A8 J1-J3 AS2a | 78 | 4 | 4 | 0 0 0 | -4 | 3.33 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50 |
| A9 J1-J3 AS2a AS2b | 111 | 5 | 5 | 0 0 0 0 | 69 | 4.27 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| A10 J1-J4 AS2a AS2b | 127 | 6 | 6 | 0 0 0 0 0 | 69 | 4.27 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-AS2 HIT 50; WAVE HIT 60 |
| A11 J1-J5 AS3a | 107 | 6 | 6 | 0 0 0 0 0 | 5 | 1.90 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45 |
| A12 J1-J5 AS3a-c | 202 | 11 | 11 | 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| A13 J1 at 2.4 m | 17 | 1 | 1 | — | 3 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32 |
| B1 NS1a | 37 | 1 | 1 | — | 2 | 2.40 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| B2 NS1a-c | 116 | 3 | 3 | 0 0 | 1 | 1.41 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60; IC-N1C HIT 84 |
| B3 NS1a-c at 3.0 m | 116 | 3 | 3 | 0 0 | 1 | 2.01 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60; IC-N1C HIT 84 |
| B4 NS1a SA | 56 | 2 | 2 | 0 | 3 | 1.18 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34 |
| B5 NS1a SA AS1 | 83 | 3 | 3 | 0 0 | 41 | 1.95 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34; IC-AS1 HIT 50 |
| B6 NS1a SA J2 AS1 | 100 | 4 | 4 | 0 0 0 | 41 | 1.95 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34; IC-J2 HIT 32; IC-AS1 HIT 50 |
| B7 NS1a SA J2 J3 AS2ab | 148 | 6 | 6 | 0 0 0 0 0 | 69 | 4.34 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| B8 NS1a SA J2-J5 AS3abc | 233 | 12 | 12 | 0 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| B9 NS1a NS1b SA J2 J3 AS2ab | 176 | 7 | 7 | 0 0 0 0 0 0 | 69 | 4.34 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| B10 NS1a-c SA (after the crumple) | 132 | 4 | 4 | 0 0 0 | 3 | 0.88 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60; IC-N1C HIT 84; IC-SA HIT 34 |
| C1 NS2abc at 2.4 m | 82 | 1 | 1 | — | 55 | 3.60 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| C2 NS2abc at 4 m | 82 | 1 | 1 | — | 62 | 5.20 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| C3 NS2abc at 6.6 m | 82 | 1 | 1 | — | 73 | 7.80 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| C4 NS2abc at 10 m | 82 | 1 | 1 | — | 88 | 11.20 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| C5 NS2abc at 13 m | 82 | 1 | 1 | — | 88 | 14.20 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| C6 NS2a SA-g1 J2 J3 AS2ab (x1.4) | 149 | 5 | 5 | 0 0 0 0 | 70 | 4.53 | +0 | +0 | 0 / 0 | +0 | IC-SA-G1 HIT 55; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| C7 NS2ab SA-g2 J2 J3 AS2ab (x1.7) | 183 | 5 | 5 | 0 0 0 0 | 69 | 4.32 | +0 | +0 | 0 / 0 | +0 | IC-SA-G2 HIT 80; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| C8 NS2ab SA-g2 J2-J5 AS3abc (x1.7) | 365 | 11 | 11 | 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-SA-G2 HIT 80; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| C9 NS2ab SA-g2 AS1 (x1.7) | 95 | 2 | 2 | 0 | 41 | 1.88 | +0 | +0 | 0 / 0 | +0 | IC-SA-G2 HIT 80; IC-AS1 HIT 50 |
| C10 NS2a SA-g1 at 3.5 m (the lunge) | 32 | 1 | 1 | — | 3 | 2.28 | +0 | +0 | 0 / 0 | +0 | IC-SA-G1 HIT 55 |
| D1 NS3a at 3.0 m | 39 | 4 | 4 | 0 0 0 | 5 | 0.87 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| D2 NS3ab at 3.0 m | 80 | 5 | 5 | 0 0 0 0 | 6 | 0.87 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3B HIT 100 |
| D3 NS3ab at 4.2 m | 83 | 5 | 5 | 0 0 0 0 | 6 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3B HIT 100 |
| D4 NS3a SA J2 J3 AS2ab | 140 | 9 | 9 | 0 0 0 0 0 0 0 0 | 69 | 4.31 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| D5 NS3a SA J2-J5 AS3abc | 217 | 15 | 15 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| D6 NS3ab SA (after the crumple) | 97 | 6 | 6 | 0 0 0 0 0 | 3 | 0.87 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3B HIT 100; IC-SA HIT 34 |
| E1 NS1a held (ptr 1) | 0 | 1 | 1 | — | -115 | 8.00 | +0 | +0 | 0 / 0 | -1 | IC-N1A HIT 68; IC-N1A KIKON 68 |
| E2 NS1a held 40 | 0 | 1 | 1 | — | 0 | 8.00 | +0 | +0 | 0 / 0 | -1 | IC-N1A HIT 68; IC-N1A KIKON 68 |
| E3 NS1a NS1b held | 0 | 2 | 2 | 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -1 | IC-N1A HIT 68; IC-N1B HIT 60; IC-N1B KIKON 60 |
| E4 J1 AS1 held (ptr 1 written) | 0 | 2 | 2 | 0 | -115 | 8.00 | +0 | +0 | 0 / 0 | -1 | IC-J1 HIT 32; IC-AS1 HIT 50; IC-AS1 KIKON 50 |
| E5 J1-J3 AS2a held | 0 | 4 | 4 | 0 0 0 | -83 | 8.00 | +0 | +0 | 0 / 0 | -2 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; IC-AS2 KIKON 50 |
| E6 J1-J3 AS2a AS2b held (the wave's Kikon) | 0 | 5 | 5 | 0 0 0 0 | -83 | 8.00 | +0 | +0 | 0 / 0 | -2 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60; IC-WAVE-STRIKE-AS KIKON 80 |
| E7 NS2abc held at 6.6 m (JUJISHO's Kikon) | 0 | 1 | 1 | — | -83 | 8.00 | +0 | +0 | 0 / 0 | -2 | WAVE HIT 150; IC-WAVE-STRIKE KIKON 80 |
| E8 NS2abc held at 10 m | 0 | 1 | 1 | — | 0 | 8.00 | +0 | +0 | 0 / 0 | -2 | WAVE HIT 150; IC-WAVE-STRIKE KIKON 80 |
| E9 NS3a held (ptr 3) | 0 | 1 | 1 | — | -117 | 5.73 | +0 | +0 | 0 / 0 | -1 | IC-N3A HIT 18; IC-N3A KIKON 18 |
| E10 J1-J5 AS3a held | 0 | 6 | 6 | 0 0 0 0 0 | -117 | 5.73 | +0 | +0 | 0 / 0 | -1 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3 KIKON 45 |
| E11 J1-J5 AS3abc, AS3c held | 0 | 7 | 7 | 0 0 0 0 0 0 | -117 | 5.73 | +0 | +0 | 0 / 0 | -1 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B KIKON 18 |
| E12 NS1a held, he attacks in the follow-up | 45 | 1 | 1 | — | 0 | 6.81 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| E13 NS1a held, he is red and attacks | -1000 | 1 | 1 | — | -115 | 8.00 | +0 | +0 | 0 / 0 | -1 | IC-N1A HIT 68; IC-N1A KIKON 68 |
| E14 J1-J3 AS2a held, red (ptr 2: red = zero) | -1000 | 4 | 4 | 0 0 0 | -83 | 8.00 | +0 | +0 | 0 / 0 | -3 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; IC-AS2 KIKON 50 |
| E15 NS2abc held at 6.6 m, he attacks | 98 | 1 | 1 | — | 70 | 8.67 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| F1 J1 Hoho J2 J3 | 63 | 3 | 3 | 0 0 | 2 | 1.60 | +0 | -84 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32 |
| F2 NS1a Hoho NS1b | 84 | 2 | 2 | 0 | -2 | 1.60 | +0 | -84 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60 |
| F3 J1 Hoho AS1 | 54 | 2 | 2 | 0 | 41 | 1.91 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-AS1 HIT 50 |
| G1 J1-J3 / guard | 0 | 0 | 0 | — | -16 | 2.24 | +0 | +0 | 0 / 0 | +0 | IC-J1 BLOCKED 32; IC-J2 BLOCKED 32 |
| G2 NS1a / guard | 0 | 0 | 0 | — | -9 | 3.00 | +0 | +0 | 0 / 0 | +0 | IC-N1A BLOCKED 68 |
| H1 J1-J5 AS3abc / Shikai | 243 | 11 | 11 | 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| H2 NS2ab SA-g2 J2-J5 AS3abc / Shikai | 428 | 11 | 11 | 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-SA-G2 HIT 80; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| H3 NS2abc at 6.6 m / Shikai | 98 | 1 | 1 | — | 73 | 7.80 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| H4 NS1a-c / Shikai | 139 | 3 | 3 | 0 0 | 1 | 1.41 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-N1B HIT 60; IC-N1C HIT 84 |
| K1 KESSA J1-J5 | 77 | 5 | 5 | 0 0 0 0 | 5 | 2.06 | +0 | +0 | 0 / 0 | +0 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-NA4 HIT 32; IC-K-J3 HIT 40 |
| K2 KESSA J1 AS1 (the whip) | 44 | 5 | 5 | 0 0 0 0 | 55 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-K-J1 HIT 30; IC-K-AS1 HIT 14; IC-K-AS1 HIT 14; IC-K-AS1 HIT 14; IC-K-AS1 HIT 14 |
| K3 KESSA J1-J3 AS2ab | 105 | 5 | 5 | 0 0 0 0 | 79 | 4.83 | +0 | +0 | 0 / 0 | +0 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-AS2 HIT 50; WAVE HIT 60 |
| K4 KESSA J1-J5 AS3abc (clones) | 193 | 10 | 12 | 0 0 0 0 0 0 0 0 0 | 41 | 1.86 | +0 | +0 | 0 / 0 | +0 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-NA4 HIT 32; IC-K-J3 HIT 40; IC-HIT HIT 18; IC-K-AS3 HIT 45; IC-K-AS3B HIT 45; IC-HIT HIT 18; IC-HIT HIT 38; IC-HIT HIT 38; IC-K-AS3C HIT 100 |
| K5 KESSA NS1a-c (chains) at 2.8 m | 104 | 3 | 3 | 0 0 | 9 | 2.80 | +0 | +0 | 0 / 0 | +0 | IC-K-N1A HIT 60; IC-K-N1B HIT 55; IC-K-N1C HIT 80 |
| K6 KESSA NS1a SA J2 J3 AS2ab | 139 | 6 | 6 | 0 0 0 0 0 | 79 | 4.83 | +0 | +0 | 0 / 0 | +0 | IC-K-N1A HIT 60; IC-K-SA1 HIT 34; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-AS2 HIT 50; WAVE HIT 60 |
| K7 KESSA NS2abc at 6.6 m | 81 | 1 | 1 | — | 73 | 7.80 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| K8 KESSA NS2ab SA-g2 J2-J5 AS3abc (x1.7) | 342 | 10 | 12 | 0 0 0 0 0 0 0 0 0 | 41 | 1.86 | +0 | +0 | 0 / 0 | +0 | IC-K-SA-G2 HIT 80; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-NA4 HIT 32; IC-K-J3 HIT 40; IC-HIT HIT 18; IC-K-AS3 HIT 45; IC-K-AS3B HIT 45; IC-HIT HIT 18; IC-HIT HIT 38; IC-HIT HIT 38; IC-K-AS3C HIT 100 |
| K9 KESSA NS3abc (the clones' X) at 1.8 m | 59 | 3 | 4 | 0 0 | 1 | 1.80 | +0 | +0 | 0 / 0 | +0 | IC-HIT HIT 18; IC-HIT HIT 18; IC-HIT HIT 38; IC-HIT HIT 38 |
| K10 KESSA NS3abc SA J2 J3 AS2ab (replays) | 163 | 14 | 16 | 0 0 0 0 0 0 0 0 0 0 0 0 0 | 65 | 5.04 | +0 | +0 | 0 / 0 | +0 | IC-HIT HIT 18; IC-HIT HIT 18; IC-HIT HIT 38; IC-HIT HIT 38; IC-K-SA HIT 50; IC-K-J2 HIT 30; IC-HIT HIT 3; IC-K-NA3 HIT 30; IC-HIT HIT 3; IC-HIT HIT 3; IC-K-AS2 HIT 50; IC-HIT HIT 5; IC-HIT HIT 5; WAVE HIT 60; WAVE HIT 6; WAVE HIT 6 |
| K11 KESSA NS3ab SA J2-J5 AS3abc (replays) | 204 | 19 | 21 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 | 41 | 1.86 | +0 | +0 | 0 / 0 | +0 | IC-HIT HIT 18; IC-HIT HIT 18; IC-K-SA HIT 50; IC-K-J2 HIT 30; IC-HIT HIT 3; IC-K-NA3 HIT 30; IC-HIT HIT 3; IC-HIT HIT 3; IC-K-NA4 HIT 32; IC-HIT HIT 3; IC-HIT HIT 3; IC-K-J3 HIT 40; IC-HIT HIT 4; IC-HIT HIT 4; IC-HIT HIT 18; IC-K-AS3 HIT 45; IC-K-AS3B HIT 45; IC-HIT HIT 18; IC-HIT HIT 38; IC-HIT HIT 38; IC-K-AS3C HIT 100 |
| K12 KESSA NS3a SA at 3.5 m (the lunge) | 28 | 1 | 1 | — | 11 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-K-SA HIT 50 |
| K13 KESSA NS1a held (ptr 1) | 0 | 1 | 1 | — | -113 | 8.00 | +0 | +0 | 0 / 0 | -2 | IC-K-N1A HIT 60; IC-K-N1A KIKON 60 |
| K14 KESSA J1-J3 AS2a AS2b held (the wave's Kikon) | 0 | 5 | 5 | 0 0 0 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -3 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-AS2 HIT 50; WAVE HIT 60; IC-K-WAVE-STRIKE-AS KIKON 80 |
| K15 KESSA NS2abc held at 6.6 m | 0 | 1 | 1 | — | -83 | 8.00 | +0 | +0 | 0 / 0 | -3 | WAVE HIT 150; IC-K-WAVE-STRIKE KIKON 80 |
| K16 KESSA J1-J5 AS3a held (ptr 3: 千影) | 0 | 8 | 8 | 0 0 0 0 0 0 0 | -83 | 8.00 | +0 | +0 | 0 / 0 | -2 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30; IC-K-NA4 HIT 32; IC-K-J3 HIT 40; IC-HIT HIT 18; IC-K-AS3 HIT 45; IC-HIT HIT 18; IC-K-AS3 KIKON 45 |
| K17 KESSA J1 AS1 held (the whip's Kikon) | 0 | 2 | 2 | 0 | -113 | 8.00 | +0 | +0 | 0 / 0 | -2 | IC-K-J1 HIT 30; IC-K-AS1 HIT 14; IC-K-AS1 KIKON 14 |
| L1 awaken (gauge 100) then J1-J3 | 57 | 3 | 3 | 0 0 | 3 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30 |
| L2 awaken (gauge 50: refused) | 0 | 0 | 0 | — | ? | 1.60 | +0 | +0 | 0 / 0 | +0 |  |
| L3 J1 J2, awaken in the string (100) | 63 | 3 | 2 | 0 13 | 3 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-J1 HIT 32 |
| M1 his J1 at 2.4 m | 0 | 0 | 0 | — | ? | 0.83 | +0 | +0 | 0 / 0 | +0 | [ 17776] P2 KE-Z-J1 HIT 35 |
| M2 his J1 at 3.0 m | 0 | 0 | 0 | — | ? | 2.50 | +0 | +0 | 0 / 0 | +0 |  |
| M3 his NS1a at 3.0 m | 0 | 0 | 0 | — | ? | 1.89 | +0 | +0 | 0 / 0 | +0 | [ 17904] P2 KE-Z-N1A HIT 65 |
| M4 his NS1a at 3.6 m | 0 | 0 | 0 | — | ? | 2.49 | +0 | +0 | 0 / 0 | +0 |  |
| M5 his NS2a at 3.6 m | 0 | 0 | 0 | — | ? | 2.66 | +0 | +0 | 0 / 0 | +0 |  |
| M6 his NS3a-b at 3.6 m | 0 | 0 | 0 | — | ? | 2.22 | +0 | +0 | 0 / 0 | +0 | [ 18132] P2 KE-Z-N3B HIT 70 |
| M7 J1 vs his J1, same frame, 1.6 m | 0 | 0 | 0 | — | ? | 0.83 | +0 | +0 | 0 / 0 | +0 | [ 18196] P2 KE-Z-J1 HIT 35 |
| M8 NS1a vs his J1 (f8), 2.4 m | 44 | 1 | 1 | — | 2 | 1.90 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| M9 NS1a vs his J1 (f8), then the SA | 66 | 2 | 2 | 0 | 3 | 0.85 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34 |
| M10 NS1a, his J1 in its gap (f30), SA | 66 | 2 | 2 | 0 | 3 | 0.95 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34 |
| M11 J1 into his NS1a, then AS1 | 54 | 2 | 2 | 0 | ? | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-AS1 HIT 50 |
| M12 J1 into his NS2a (armoured), then AS1 | 33 | 1 | 1 | — | ? | 1.91 | +0 | +0 | 0 / 0 | +0 | IC-AS1 HIT 50 |
| M13 NS2a at 2.0 m, his J1 (f6) > AS1 (f20) | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [ 18907] P2 KE-Z-AS1 HIT 90 |
| M14 NS2a at 2.0 m, his NS1a (f2) | 0 | 0 | 0 | — | ? | 0.89 | +0 | +0 | 0 / 0 | +0 | [ 18996] P2 KE-Z-N1A HIT 65 |
| M15 NS2abc at 6.6 m, he runs in at f0 | 0 | 0 | 0 | — | ? | 0.83 | +0 | +0 | 0 / 0 | +0 | [ 19164] P2 KE-Z-N1A HIT 65 |
| M16 NS2abc at 10 m, he runs in at f0 | 97 | 1 | 1 | — | 54 | 3.33 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| M17 NS2abc at 6.6 m, his armoured NS2a on the wave (f64) | 97 | 1 | 0 | — | 44 | 5.66 | +0 | +0 | 0 / 0 | +0 | WAVE ARMORED 150 |
| M18 NS2abc at 6.6 m, his armoured NS2a on the wave (f68) | 97 | 1 | 0 | — | 48 | 5.66 | +0 | +0 | 0 / 0 | +0 | WAVE ARMORED 150 |
| M19 NS2abc at 6.6 m, his Hoho on the wave (f70) | 0 | 0 | 0 | — | ? | 1.60 | +0 | +0 | 0 / 0 | +0 |  |
| M20 his NS1a whiffs at 3.6 m, her NS1a at once | 44 | 1 | 1 | — | 2 | 2.49 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| M21 his NS1a whiffs at 3.6 m, her NS3a at f10 | 0 | 0 | 0 | — | ? | 1.95 | +0 | +0 | 0 / 0 | +0 | [ 20084] P2 KE-Z-N1A HIT 65 |
| M22 his NS2a whiffs at 4.0 m, her NS1a at f6 | 44 | 1 | 1 | — | ? | 3.06 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| M23 his J1-J3 whiff at 3.2 m, her NS1a at f4 | 37 | 1 | 1 | — | 2 | 2.70 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| M24 his J1 whiffs at 3.2 m, her J1 at f6 | 0 | 0 | 0 | — | ? | 2.14 | +0 | +0 | 0 / 0 | +0 |  |
| M25 his J1 AS1 held, her J in the follow-up | 0 | 0 | 0 | — | ? | 5.60 | +0 | +0 | 0 / 0 | +0 | [   196] P2 KE-Z-J1 HIT 35; [   213] P2 KE-Z-AS1 HIT 90 |
| R1 NS1a at 3.4 m | 0 | 0 | 0 | — | ? | 3.40 | +0 | +0 | 0 / 0 | +0 |  |
| R2 NS1a at 3.6 m | 0 | 0 | 0 | — | ? | 3.60 | +0 | +0 | 0 / 0 | +0 |  |
| R3 NS1a at 3.8 m | 0 | 0 | 0 | — | ? | 3.80 | +0 | +0 | 0 / 0 | +0 |  |
| R4 NS3a at 4.6 m | 38 | 4 | 4 | 0 0 0 | 5 | 2.33 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| R5 NS3a at 5.0 m | 38 | 4 | 4 | 0 0 0 | 5 | 2.73 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| R6 J1 at 2.6 m | 0 | 0 | 0 | — | ? | 2.04 | +0 | +0 | 0 / 0 | +0 |  |
| R7 J1 at 2.8 m | 0 | 0 | 0 | — | ? | 2.24 | +0 | +0 | 0 / 0 | +0 |  |
| R8 KESSA NS1a at 3.4 m | 31 | 1 | 1 | — | 4 | 3.40 | +0 | +0 | 0 / 0 | +0 | IC-K-N1A HIT 60 |
| R9 KESSA NS1a at 3.8 m | 0 | 0 | 0 | — | ? | 3.80 | +0 | +0 | 0 / 0 | +0 |  |
| R10 his J1 at 2.7 m | 0 | 0 | 0 | — | ? | 2.20 | +0 | +0 | 0 / 0 | +0 |  |
| R11 his NS1a at 3.3 m | 0 | 0 | 0 | — | ? | 2.19 | +0 | +0 | 0 / 0 | +0 | [  1074] P2 KE-Z-N1A HIT 65 |
| R12 his NS2a at 3.2 m | 0 | 0 | 0 | — | ? | 2.26 | +0 | +0 | 0 / 0 | +0 |  |
| R13 his NS3a-b at 4.0 m | 0 | 0 | 0 | — | ? | 2.63 | +0 | +0 | 0 / 0 | +0 | [  1232] P2 KE-Z-N3B HIT 70 |
| R14 his Shikai NS1a at 4.0 m | 0 | 0 | 0 | — | ? | 1.19 | +0 | +0 | 0 / 0 | +0 | [  1306] P2 KE-S-N1A HIT 70 |
| R15 his Shikai NS1a at 4.6 m | 0 | 0 | 0 | — | ? | 1.79 | +0 | +0 | 0 / 0 | +0 | [  1376] P2 KE-S-N1A HIT 70 |
| R16 his Shikai J1 at 3.0 m | 0 | 0 | 0 | — | ? | 0.83 | +0 | +0 | 0 / 0 | +0 | [  1439] P2 KE-S-J1 HIT 40 |
| R17 NS2abc at 7.5 m, he runs in at f0 | 82 | 1 | 1 | — | 54 | 0.83 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| R18 NS2abc at 8.5 m, he runs in at f0 | 82 | 1 | 1 | — | 54 | 0.83 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| R19 NS2abc at 6.6 m, he walks in, NS1a at f40 | 82 | 1 | 1 | — | 56 | 3.75 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| R20 NS2abc at 6.6 m, he walks in, NS1a at f50 | 82 | 1 | 1 | — | 55 | 3.53 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| R21 J1-J3 AS2ab, his Hoho pressed at f60 (in hitstun) | 111 | 5 | 5 | 0 0 0 0 | 69 | 4.27 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| R22 NS3a at 5.4 m | 0 | 0 | 0 | — | ? | 3.13 | +0 | +0 | 0 / 0 | +0 |  |
| R23 NS3a at 5.8 m | 0 | 0 | 0 | — | ? | 3.53 | +0 | +0 | 0 / 0 | +0 |  |
| R24 NS3a SA J2 J3 AS2ab from 4.6 m | 128 | 9 | 9 | 0 0 0 0 0 0 0 0 | 69 | 4.27 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-AS2 HIT 50; WAVE HIT 60 |
| R25 NS3a SA J2-J5 AS3abc from 4.6 m | 197 | 15 | 15 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| R26 his NS3a-b at 4.6 m, her NS3a at f30 | 0 | 0 | 0 | — | ? | 2.56 | +0 | +0 | 0 / 0 | +0 | [  3235] P2 KE-Z-N3B HIT 70 |
| R27 KESSA NS3a SA at 4.2 m | 26 | 1 | 1 | — | 11 | 1.50 | +0 | +0 | 0 / 0 | +0 | IC-K-SA HIT 50 |
| R28 NS2abc at 3.6 m, he walks in, J1 at f10 | 82 | 1 | 1 | — | 55 | 3.57 | +0 | +0 | 0 / 0 | +0 | WAVE HIT 150 |
| M26 his NS1a whiffs at 3.6 m, her NS3a at f18 | 38 | 4 | 4 | 0 0 0 | 5 | 0.89 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| M27 his NS1a whiffs at 3.6 m, her NS3a at f18 > SA J2-J5 AS3abc | 197 | 15 | 15 | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 | 46 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-SA HIT 34; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| M28 his J1 whiffs at 3.2 m, her NS3a at f8 | 38 | 4 | 4 | 0 0 0 | 5 | 0.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| M29 his J1 whiffs at 3.2 m, her NS1a at f2 | 37 | 1 | 1 | — | 2 | 2.70 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| M30 his NS2a whiffs at 4.0 m, her NS3a at f20 | 38 | 4 | 4 | 0 0 0 | 5 | 0.93 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| S1 J1-J5 AS3abc, his Reishi 150 (the kill in the AS3) | -1150 | 10 | 10 | 0 0 0 0 0 0 0 0 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -5 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-J3 HIT 40; IC-AS3 HIT 45; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3B HIT 18; IC-AS3C HIT 100 |
| S2 J1-J4 AS2ab, his Reishi 110 (the kill in the AS2) | -1190 | 5 | 5 | 0 0 0 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -3 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32; IC-NA4 HIT 34; IC-AS2 HIT 50; WAVE HIT 60 |
| S3 J1-J3 at pointer 1, his Reishi 40 (the kill by a J) | -1260 | 2 | 2 | 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -3 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32 |
| S4 J1-J3 at pointer 3, his Reishi 40 (the kill by a J) | -1260 | 2 | 2 | 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -5 | IC-J1 HIT 32; IC-J2 HIT 32; IC-NA3 HIT 32 |
| S5 KESSA J1-J3 at pointer 3, his Reishi 40 | -1260 | 2 | 2 | 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -5 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30 |
| S6 KESSA J1-J3 at pointer 1, his Reishi 40 | -1260 | 2 | 2 | 0 | 0 | 8.00 | +0 | +0 | 0 / 0 | -4 | IC-K-J1 HIT 30; IC-K-J2 HIT 30; IC-K-NA3 HIT 30 |
| T1 NS1a vs his J1 (f8) > his AS1 (f15) | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [  5771] P2 KE-Z-AS1 HIT 90 |
| T2 NS1a vs his J1 (f8) > his AS1 (f20) | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [  5892] P2 KE-Z-AS1 HIT 90 |
| T3 NS1a vs his J1 (f8) > his AS1 (f30) | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [  6014] P2 KE-Z-AS1 HIT 90 |
| T4 NS1a vs his J1 (f8) > his AS1 (f15), her SA at f12 | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [  6131] P2 KE-Z-AS1 HIT 90 |
| T5 NS1a vs his J1 (f8) > his J2 (f15) | 18 | 1 | 1 | — | ? | 0.85 | +0 | +0 | 0 / 0 | +0 | IC-SA HIT 34 |
| T6 J1 into his NS1a > his SA (f20) > her AS1 | 0 | 0 | 0 | — | ? | 2.39 | +0 | +0 | 0 / 0 | +0 | [  6368] P2 KE-Z-SA1 HIT 30 |
| T7 J1 into his NS1a > his SA (f28) > her AS1 | 0 | 0 | 0 | — | ? | 2.39 | +0 | +0 | 0 / 0 | +0 | [  6498] P2 KE-Z-SA1 HIT 30 |
| T8 J1 into his NS1a > his SA (f36) > her AS1 | 44 | 2 | 2 | 0 | ? | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-AS1 HIT 50 |
| T9 J1 into his NS1a > his SA (f44) > her AS1 | 44 | 2 | 2 | 0 | ? | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-J1 HIT 32; IC-AS1 HIT 50 |
| T10 J1 into his NS1a > his NS1b (f20) | 27 | 1 | 1 | — | ? | 1.89 | +0 | +0 | 0 / 0 | +0 | IC-AS1 HIT 50 |
| T11 J1 into his NS1a > her AS1 at once (f15) > his SA (f28) | 0 | 0 | 0 | — | ? | 2.39 | +0 | +0 | 0 / 0 | +0 | [  7018] P2 KE-Z-SA1 HIT 30 |
| T12 J1 into his NS1a > his SA (f20) > her AS1 later (f24) | 0 | 0 | 0 | — | ? | 2.39 | +0 | +0 | 0 / 0 | +0 | [  7148] P2 KE-Z-SA1 HIT 30 |
| T13 NS1a vs his J1 (f8) > his AS1 (f20) > her SA (f30) | 0 | 0 | 0 | — | ? | 1.90 | +0 | +0 | 0 / 0 | +0 | [  7282] P2 KE-Z-AS1 HIT 90 |
| T14 NS1a at 3.4 m catches his walk-in (his J1 at f28 never starts), SA | 54 | 2 | 2 | 0 | 3 | 0.87 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68; IC-SA HIT 34 |
| T15 NS1a at 3.4 m catches his walk-in | 36 | 1 | 1 | — | 2 | 1.92 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
| U1 NS3a from 4.6 m, his J1 at f8 | 38 | 4 | 4 | 0 0 0 | 5 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| U2 NS3a from 4.6 m, his J1 at f12 | 30 | 3 | 3 | 0 0 | 5 | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| U3 NS3a from 4.6 m, his J1 at f12 > AS1 at f20 | 0 | 0 | 0 | — | ? | 1.93 | +0 | +0 | 0 / 0 | +0 | [  7846] P2 KE-Z-AS1 HIT 90 |
| U4 NS3a from 4.6 m, his NS1a at f4 | 0 | 0 | 0 | — | ? | 5.22 | +0 | +0 | 0 / 0 | +0 |  |
| U5 NS3a from 4.6 m, his J1 at f16 | 10 | 1 | 1 | — | ? | 1.83 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18 |
| U6 his NS1a > NS1b whiff at 3.6 m, her NS3a at f18 | 0 | 0 | 0 | — | ? | 1.15 | +0 | +0 | 0 / 0 | +0 | [  8148] P2 KE-Z-N1B HIT 55 |
| U7 his NS1a > NS1b whiff at 3.6 m, her NS3a at f32 | 38 | 4 | 4 | 0 0 0 | 5 | 0.89 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| U8 his NS1a > NS1b > NS1c at 3.6 m, her NS3a at f18 | 0 | 0 | 0 | — | ? | 1.15 | +0 | +0 | 0 / 0 | +0 | [  8398] P2 KE-Z-N1B HIT 55; [  8419] P2 KE-Z-N1C HIT 70 |
| U9 his NS1a > SA at 3.6 m, her NS3a at f18 | 35 | 4 | 4 | 0 0 0 | 5 | 0.89 | +0 | +0 | 0 / 0 | +0 | IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18; IC-N3A HIT 18 |
| U10 his NS2a > NS2b at 4.0 m, her NS1a at f6 | 36 | 1 | 0 | — | 22 | 2.51 | +0 | +0 | 0 / 0 | +0 | IC-N1A ARMORED 68 |
| U11 his NS2a > NS2b at 4.0 m, her NS3a at f20 | 0 | 0 | 0 | — | ? | 0.95 | +0 | +0 | 0 / 0 | +0 | [  8774] P2 KE-Z-N2B HIT 95 |
| U12 his J1 whiff at 3.2 m > his J2 press, her NS1a at f2 | 36 | 1 | 1 | — | 2 | 2.70 | +0 | +0 | 0 / 0 | +0 | IC-N1A HIT 68 |
