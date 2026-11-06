# b3_a1 (round 1): KESSA survives his Shikai — the Hoho timed into the perfect window, and no read into pointer 1

Direction: lean on KESSA 強攻 and keep the other three usable. Parent: b3_a0 (0.6827 at 40 seeds). Opponent: `ken/champion/cpu-ki-ken.lisp`.
Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
- **Baseline v0** (0.5781). Its known weak spots are the hover outside the whiff radius and the pointer-2 J string.
- **b0_a0** (spacing, 0.648). The pointer-2 back-dash re-armed per his move, and the pointer-1 hover moved into NS1a's reach.
  - Negative result: steering to AS2 for pointer-2 time costs more than it gains.
- **b1_a0** (whiff, 0.6583). A whiff confirm seen in the SNAP, and KESSA steered by red. Whiff rose 0.31 → 0.63.
- **b2_a0** (ptr3, 0.7151). The generic episodes take the Kikon rule, plus a Konpaku-aware finisher (it reads his Konpaku pips: a rule risk the cell itself named). Ptr3 rose to 0.95.
- **b3_a0** (parent, kessa, 0.6827). The awakening gap, KESSA strings to AS3, red → AS2.
  - Its own rejects: hovering against his Shikai in KESSA (v1d / v3a) and a safer or more aggressive KESSA mix.
- No round-1 a1 sibling had delivered when this was written. There is no HISTORY_DIR (round 1).
- I re-measured the parent on seeds 1–20: 0.6865, identical to its v2a row.
- Seeds 1–40 flatter it. At **100 seeds a seat** (HARD only) the parent scores raw 0.6634, kessa 131/200.
- So every A/B below was paired at 100 seeds a seat, from a scratch observer that reproduces the evaluator's HARD numbers exactly and adds the KESSA ledger.

## Diagnosis (the parent, 100 seeds a seat, HARD)
- The kessa theme is one situation a match, and it is a damage ledger from the awakening to the match end.
- She awakens in 200 of 200 matches, so every failure is a lost ledger.
- **The failed matches lose to his Shikai.** Damage she took in KESSA, per match (from the combat log):

  | Matches | Shikai NS | Shikai J | Shikai SP/AS | Shikai total |
  |---|---|---|---|---|
  | Failed (69) | 1361 | 1135 | 718 | 3214 |
  | Passed (131) | 479 | 329 | 135 | 943 |

  - Sealed and Bankai damage is small in both groups.
  - His Shikai lunge (KE-S-N1A, which reaches 4.6–5.6 m), his J strings into SP1, and the meaty J1 wake-up loop take her apart. One match: 5318 taken against a 4-Konpaku Kenpachi over 167 s.
- **Pointer 1 bleeds in KESSA against every form; pointer 3 wins** (time-weighted). Against his Shikai: pointer 1 −34.6k, pointer 3 +260k.
  - The k-lunge's SA, read into AS1 when he showed an NS, was one way in.

## The mechanism (`cpu-ki-ichigo.lisp` only; knobs `defparameter` + docstring)
1. **The KESSA Hoho** (`iks-kessa-hoho`, `*iks-kessa-hoho-p*` EASY 0 / NORMAL 0.1 / HARD 0.9, `*iks-kessa-hoho-lead*` (1 6)).
   - In KESSA, in a style mode, in neutral: his perceived NA / NS / SA / AS coming in reach is Hoho'd when its first active frame, as seen (`snap-lead-seen`, with her perception delay), is 1–6 frames away.
   - That is inside `*perfect-lead*` 12, so most of them are **perfect Hohos**: the counter strike, 60, and his 40 f lock.
   - The chance is rolled once per his move start. It also needs flash-step to spare (`ai-hoho-spare-p`, the shipped CPU's budget rule).
   - This is the shipped CPU's own Hoho (`*cai-hoho-p*` 0.25, an untimed roll as soon as his attack is live in reach), **retimed** into the perfect window while she is in KESSA. It is not a new style.
2. **The follow-up** (`iks-hoho-follow`, `*iks-hoho-follow*` 40 f, `*iks-hoho-j-reach*` 1.5 m).
   - Within 40 f of her Hoho, whatever mode the new episode rolled: if he is seen recovering or reeling, she walks in to 1.5 m and presses J1.
   - The string is tagged `:kessa`, so the KESSA steer runs it to J5 + SP (AS3, pointer 3).
3. **No read into pointer 1 in KESSA** (`*iks-kessa-read-min*` 2).
   - A steered KESSA string takes the AS read only when the AS it would start is at least AS2. So the read never writes pointer 1 there.
   - Outside KESSA the read is the v0's.

## Measurements
**HARD, 100 seeds a seat, paired** (raw = 0.4 str + 0.6 sig, no NORMAL factor). The ledger is the evaluator's KESSA Reishi sums over all 200 matches.

| Variant | Raw | HARD | Spacing | Whiff | Ptr3 | Kessa | KESSA taken | KESSA net |
|---|---|---|---|---|---|---|---|---|
| P0 parent b3_a0 | 0.6634 | 190/200 | 0.182 | 0.313 | 0.740 | 0.655 (131) | 293.7k | +66.8k |
| A: no k-chains / k-lunge vs his Shikai / Bankai (generic) | 0.6484 | 184 | 0.173 | 0.310 | 0.757 | 0.630 (126) | 301.4k | +51.1k |
| B: A + read floor 2 | 0.6617 | 187 | 0.179 | 0.297 | 0.787 | 0.655 (131) | 291.8k | +53.8k |
| **C: read floor 2** | 0.6708 | 190 | 0.189 | 0.293 | 0.742 | 0.715 (143) | 286.0k | +65.0k |
| **H: C + KESSA Hoho (1 6) + follow-up (final)** | **0.7113** | **194** | 0.195 | **0.356** | **0.789** | **0.815 (163)** | **204.7k** | **+158.3k** |
| H, lead (1 10) | 0.7008 | 190 | 0.190 | 0.354 | 0.779 | 0.815 (163) | 210.4k | +152.9k |
| H, lead (2 8) | 0.6930 | 190 | 0.184 | 0.359 | 0.783 | 0.760 (152) | 244.0k | +110.9k |
| H, lead (3 8) | 0.6933 | 191 | 0.183 | 0.356 | 0.780 | 0.755 (151) | 245.9k | +108.5k |
| H, lead (5 11) | 0.6889 | 191 | 0.187 | 0.351 | 0.793 | 0.715 (143) | 269.4k | +84.2k |

- **Damage from his Shikai while she is in KESSA:** 353k → 256k (C → H). Her damage on him rose 562k → 641k.
- **Her KESSA Hohos (H):** 575, of which 523 were perfect. She hit him within 60 f after 446 of them.
- **The early lead window (1 6):**
  - At lead 1, 221 Hohos were hit on the press frame, since the Hoho's iframes start at f1.
  - The later windows lose fewer Hohos to that, but answer far fewer of his moves (320–439 Hohos), and they score lower.
  - The window was picked once from these rows, then left.
- **Whiff** rose 0.29 → 0.36. His Hoho'd move whiffs inside 3.6 m and the follow-up lands in his recovery. That is a real punish, not a detector artifact.

**The evaluator on the final file:**

| Run | Score | HARD | Spacing | Whiff | Ptr3 | Kessa | NORMAL |
|---|---|---|---|---|---|---|---|
| 20 seeds a seat | 0.7116 (parent 0.6865) | 39/40 | 0.178 | 0.382 | 0.809 | 0.775 | 0.075 |
| **40 seeds a seat (score.json)** | **0.7241** | 79/80 | 0.176 | 0.377 | 0.803 | **0.838** (67/80) | 0.075 (band 0–0.138, factor 1) |

| Part (40 seeds) | Parent b3_a0 | Final |
|---|---|---|
| Score | 0.6827 | **0.7241** |
| Strength | 0.975 | 0.9875 |
| Signature | 0.488 | 0.548 |
| Spacing | 0.170 | 0.176 |
| Whiff | 0.324 | 0.377 |
| Ptr3 | 0.783 | 0.803 |
| Kessa | 0.675 | **0.838** |
| NORMAL | 0.0625 | 0.075 |

Host tests: 9843 checks, ALL PASS.

## Negative results (keep them)
- **Turning the KESSA bands off against his Shikai / Bankai fails.**
  - Variant A, which hands those steps to the generic CPU: −0.015 raw.
  - The same with a 4.9–5.3 m hover (20 seeds): 0.654 against 0.6865.
  - The per-action damage buckets blamed k-chains, but they bill everything after an action to it. The A/B says k-chains and k-lunge beat the generic CPU there.
  - The hover sits inside his Shikai lunge band (3.0–5.2 m, reaching 5.6 m) and outside KESSA's 3.4 m pointer-1 punisher. That is the same flaw b0 found in v0's hover, and it agrees with b3_a0's v1d.
- **The read floor alone helps only a little** (C: +0.007 raw, kessa +12 / 200). Fewer AS1 writes moved her time to pointer 2 rather than to 3. The Hoho is what turns the ledger.
- **Deferring the awakening** while he is in the Shikai was a hypothesis only. Awakening against his Shikai passed 26/48, against sealed 100/144. It was not built: the Hoho answers the Shikai directly.

## Why it is not a repeat
- No earlier cell used Hoho. b3_a0 changed where and when she awakens and which AS her KESSA strings end in. This cell changes how she survives in KESSA.
- The read floor is a targeted fix of a located leak: the k-lunge's SA read into AS1, which drops KESSA to pointer 1, its losing state.
- Nothing is taken from b1 (the confirm) or b2 (the generic Kikon, the Konpaku read).

## Expected benefit, risks
- **Benefit:** kessa 0.68 → 0.84, whiff +0.05, ptr3 +0.02, strength 0.99. Score 0.6827 → 0.7241 at 40 seeds; raw +0.048 at 100 seeds over the parent.
- **Risk (review):** the Hoho is a defensive tool shared by every fighter, not one listed in the KESSA 強攻 row of §4. It is framed as executing the style: it is the shipped CPU's Hoho, retimed, and only in KESSA. A reviewer may still read it as beyond "KESSA strings".
- **Risk (opponent):** it leans on his attacks being readable from the perceived SNAP. A Kenpachi champion that baits Hohos (a delayed second segment, or a move after her Hoho lockout of 84 f) or spends flash-step pressure would cut it.
  - The flash-step budget (100 a Hoho of 300, with the Burst reserve kept by `ai-hoho-spare-p`) limits how often she can do it.
- **Risk (NORMAL):** NORMAL's chance is 0.1, inside NORMAL's 12 % style episodes. NORMAL stayed at 0.075 (band 0–0.138). If it ever drifts up, NORMAL → 0 keeps EASY ≤ NORMAL ≤ HARD.
- **Rules:**
  - One roll per his move start.
  - He is read only through the SNAP and the distance. Her own gauges are read for the flash-step budget.
  - `sim-rnd01` only, through `brain-roll`.
  - Other pairings are untouched: the file only registers ichigo against ken.
- **Follow-ups for other cells:**
  - The same timed Hoho before the awakening, in the sealed Shikai. It is a separate mechanism, likely to raise whiff further, and it was not tested here, to keep this cell on KESSA.
  - Combine with b2's generic-Kikon piece (ptr3) and b1's confirm (whiff).
