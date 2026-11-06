# b0_a1 (round 2, Ichigo): the meaty on his knockdown. Sealed NS3a from 4-5 m, KESSA J1, both landing on his first free frame

Direction: 間合い管理 (spacing), keeping the other three usable. Opponent: `ken/champion/cpu-ki-ken.lisp`. Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

**Lineage (read first).** PARENT_DIR is round-2 b0_a0 (0.4151), but this cell's starting file is **round-2 b3_a0's final (v15)**,
copied over the parent: b3_a0 is a superset of b0_a0's working pieces. It already holds b0_a0's far k-lunge band (`:space` only),
`iks-proj`, the SA reach 5.7 and the read floor, plus b3_a0's own timed Hoho, slide, follow-up window and wake-up Hoho. My first
20-seed run of that file (v0: 0.7271, 33/40) reproduces b3_a0's 20-seed v15 line exactly. Everything below is added on top of it.

## History read
- Round 1: eight proposals with score.json and score.rescored.json, on the first freeze's scale.
- Baseline: b2_a1, 0.2877 against this opponent.
- Round 2 delivered: b0_a0 (0.4151; far band, all modes), b1_a0 (0.584; patient sealed form, NS whiff stop, breaker, timed Hoho in both
  forms) and b3_a0 (0.7151; wake-up Hoho, slide, window 64, the any-perfect follow-up).
- b1_a1, b2_a0 and b3_a1 were empty when I read them. Re-listed before the handback: b3_a1 has since delivered (rescored 0.7865,
  77/80). It spends her flash-step on the Hoho in KESSA and punishes the wake-up Hoho's lock. It has nothing on his wake-up (grep:
  no meaty), so it combines with this cell rather than overlapping it.
- Each cell's mechanism and outcome is summarised in b3_a0's and b1_a0's tables. I read them, and the code, rather than repeat them here.

## Diagnosis (b3_a0's file, 20 seeds a seat, HARD)
Scratch tools under `scratchpad/ki-ichigo-b0_a1/`:
- a copy of `situ.lisp` that logs each spacing situation's opening state (distance, her form / pointer / mode, both states) and how it
  closed;
- `ev.py`, which runs the evaluator's HARD jobs through it and reproduces matchup-eval's HARD numbers exactly;
- `lunge.py`, which classes each style press by what happened within 45 f.

1. **Spacing**: 620 situations, 99 ok.
   - KESSA pointer 3 holds 384 of them: `:space` 43/123, `:kessa` 20/55, `:ptr3` 10/42, `:whiff` 8/120.
   - The ≥ 7.5 m entries number 130, with 6 ok: the match start plus a reset to 8 m after every Soul Break / Kikon.
2. **What answers her lunges.** Outcomes within 45 f of the press:
   - KESSA k-lunge (`:space`): 49 hit, 58 his Hoho, 26 his back Step.
   - Sealed lunge: 5 hit of 57.
   - Pointer-1 walk-in: 9 hit of 86.
   - His dodge reads any clone NS within 7.0 m (Hoho at 0.8 with flash-step 100 or more) and his back Step anything within 5.0 m.
3. **His Hoho budget.** Clocked by his Hohos alone, her k-lunges under 400 f after his last Hoho hit 53 of 116 (his Hoho 19). At 400 f
   or more they hit 41 of 142 (his Hoho 73).
4. **The repeating fail.** Her AS3c knocks him down with her about 1.9 m off. She walks to her hover and waits. His get-up opens a
   4.3 m situation with both free. His Shikai lunge comes, she Hohos it perfectly and J1s from 1.5 m, and none of that counts. The
   pattern repeats dozens of times in a seat. **She never pressed anything on his wake-up**, while he loops a meaty J1 on hers
   (`kk-meaty-step`).

## The change: `iks-meaty` (new; all knobs are defparameters with docstrings)
- **The roll.** When she sees his knockdown begin (SNAP-STATE :DOWN, edge-detected each call), she rolls `*iks-meaty-p*` once per
  knockdown (0 / 0 / 0.9).
- **The timing.** She times her move off the perceived down / wakeup frames (`*reaction-frames*` 30 + 30, iframes in both; the same
  arithmetic as his `kk-meaty-step`). Its first hit meets his first free frame, where a Hoho or Step pressed on that frame does not beat it.
- **The move, by form** (`*iks-meaty-moves*`):
  - **Sealed form, pointer 3:** NS3a from 4.0–4.9 m. From 1.9 m she back-dashes out (`*iks-meaty-dash*`) and presses at 18 f to go. On
    a hit, the existing SA and the string follow. This is the spacing tool, used where his dodge can't act.
  - **KESSA: J1** (S8) from inside 1.6 m. KESSA's NS3a + SA hits only on f28, and the back dash from 1.9 m arrives about 16 f before he
    is free. That is too late (in the debug run the SA met his Hoho), so KESSA takes J1. Under pointer 1 / 2 the sealed form takes
    J1 too.
- **Dropped meaties.** If she is free to press only more than `*iks-meaty-slack*` (2) frames past the moment, she drops it.
- **Strings after it.** A meaty pressed in a `:generic` episode runs as a style string (steered to AS3).
- **The loop.** The AS3 ender knocks him down again, so the meaty loops: the mirror of his meaty loop on her.
- **Rules.** HARD only (0 at EASY / NORMAL). One roll per knockdown, with `brain-roll`. He is read only through the SNAP and the
  perceived distance.

## Measurements (paired seeds; 20-seed rows are `ev.py`, HARD only, raw = 0.4 str + 0.6 sig)
| Variant (on b3_a0's file) | HARD | raw | spacing | whiff | ptr3 | kessa |
|---|---|---|---|---|---|---|
| v0 = b3_a0 v15 | 33/40 | 0.7271 | 0.160 (99/620) | 0.702 | 0.986 | 0.80 |
| v1 his-Hoho window opens the far k-lunge to `:whiff` / `:ptr3` | 30/40 | 0.6878 | 0.166 | 0.684 | 0.985 | 0.75 |
| v2 window gates `:space` / `:kessa` k-lunges (restrict only) | 29/40 | 0.6779 | 0.109 | 0.733 | 0.969 | 0.775 |
| v3 no sealed lunge / walk-in (HARD) | 31/40 | 0.6933 | 0.113 | 0.724 | 0.944 | 0.775 |
| **v5 meaty: sealed NS3a, KESSA J1 (final)** | **40/40** | **0.7936** | 0.111 (40/360) | 0.674 | 0.988 | 0.85 |
| v6 meaty: sealed J1 instead of NS3a | 40/40 | 0.7954 | 0.110 | 0.688 | 0.988 | 0.85 |
| v7 v5 with `*iks-meaty-p*` 1.0 | 40/40 | 0.7918 | 0.087 | 0.676 | 1.0 | 0.85 |
| v8 v5 + walk in from > 7 m at pointer 3 (`:space :whiff`), not the generic dash | 40/40 | 0.7945 | 0.112 | 0.68 | 0.988 | 0.85 |

Meaty outcomes in v5 (20 seeds a seat):
- KESSA J1: 257 hits of 268.
- Sealed NS3a: 169 of 174 presses landed a hit within 45 f. In 58 of those his Hoho was logged on the same frame, and none was
  followed by his COUNTER on her (`meaty.py`).

Seeds 41–80 (`ev.py` offset 40, HARD, 40 a seat): **final 80/80, raw 0.8024**; b3_a0's file 63/80, raw 0.7015.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json).** The same line was printed twice: before and after the pointer-1 / pointer-2 J1
row moved from literals into `*iks-meaty-moves*` (`:base-j` / `:kessa-j`, same values).
`{"side": "ichigo", "seeds": 40, "strength": 0.9875, "signature": 0.6627, "themes": {"spacing": {"rate": 0.106, "ok": 79, "occ": 745}, "whiff": {"rate": 0.663, "ok": 387, "occ": 584}, "ptr3": {"rate": 0.982, "ok": 165, "occ": 168}, "kessa": {"rate": 0.9, "ok": 72, "occ": 80}}, "hard": "79/80", "normal": {"share": 0.1, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.7926, "score": 0.7926}`

| Part (40 seeds) | Baseline | b3_a0 (r2) | **This cell** |
|---|---|---|---|
| Score | 0.2877 | 0.7151 | **0.7926** |
| HARD | 6/80 | 65/80 | **79/80** |
| Spacing | 0.062 | 0.155 | 0.106 |
| Whiff | 0.556 | 0.711 | 0.663 |
| Ptr3 | 1.0 | 0.986 | 0.982 |
| Kessa | 0.10 | 0.75 | **0.90** |
| NORMAL | 0.10 | 0.10 | 0.10 (factor 1) |

## Negative results (keep them)
- **His Hoho budget is not usable as a lunge gate.** Read from SNAP-STATE :HOHO, she caught 273 of his 359 Hohos.
  - Restricting the k-lunges to the 400 f after his Hoho (v2) costs spacing and wins.
  - Opening the far band to `:whiff` / `:ptr3` inside that window (v1) loses as well: his back Step takes those lunges (25 + 22 Steps
    against 21 hits). The far band is beyond his Step only on the perceived distance, and he walks in.
  - **This is not b0_a0's v6** (lunge only while his flash-step is under 100, a HUD read, 3/80). Mine is a perceived proxy, and it was
    also tested as an expansion. Both directions lose, so the mechanism, not the read, is what fails.
- **Removing the sealed lunge / walk-in on this file (v3) is within noise and costs spacing.** b1_a0's +0.08 came in its patient file.
- **Walking in from 8 m after a reset (v8)** moved the far band only from 5 to 9 ok. His back Step takes the sealed lunge from 5 m.
  Dropped.
- **`*iks-meaty-p*` 1.0 (v7)** equals 0.9 on the score and costs spacing (fewer neutral lunges). 0.9 kept.

## Not a repeat
- No earlier cell pressed anything on his wake-up. b3_a0's wake-up Hoho is hers, against his meaty. This is the offensive mirror,
  timed by the same perceived down / wakeup frames.
- It was found in the logs, as the 4.3 m post-knockdown situations her AS3c kept producing, not by a sweep.

## Expected benefit, risks
- **Benefit.** HARD 65 → 79 of 80 and kessa 0.75 → 0.90. The gain holds on seeds 41–80 (+0.10 raw over b3_a0's file).
- **Spacing falls (0.155 → 0.106) although the cell leans on it.**
  - The meaty sealed NS3a is a 4–5 m lunge, but its hit never scores for spacing: the situation can't open while he is down, and his
    first free frame is also the frame he is hit.
  - Matches are shorter and spent in her strings, so fewer neutral k-lunges remain (ok 192 → 79).
  - What remains are mostly the resets to 8 m. There every lunge meets his Hoho or Step.
- **His likely answer.** A Kenpachi that delays his get-up or reverses with an invulnerable move would break the loop. The evaluator's
  rules have neither today.
- **NORMAL measured 8 of 80 (0.10), the same as b3_a0.** The knockdown roll still runs below HARD, at probability 0.
- **Carried over.** b3_a0's risks (the perfect-Hoho lock, the shared Hoho tool, `iks-move` reading her own true distance for the SA).
