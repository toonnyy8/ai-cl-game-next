# b1_a1 (round 1): the whiff confirm with the finisher, and standing still while he whiffs (揮空反擊)

Parent: b1_a0 (whiff confirm, 0.6583 at 40 seeds). Opponent: `ken/champion/cpu-ki-ken.lisp` (= Kenpachi's v0). Only
`duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
I read the baseline and every sibling's proposal, score.json and score.rescored.json. The rescores equal the cells' own lines.

| Cell | Mechanism | 40-seed score | Themes (spacing / whiff / ptr3 / kessa) |
|---|---|---|---|
| baseline v0 | five modes per episode | 0.5781 | 0.196 / 0.307 / 0.556 / 0.463 |
| b0_a0 | pointer-2 retreat re-armed per his move, retreat 1.0, mix, pointer-1 hover 3.4–3.8 | 0.648 | 0.274 / 0.415 / 0.585 / 0.512 |
| b1_a0 (parent) | whiff confirm off the SNAP, walk-in, KESSA AS by red | 0.6583 | 0.188 / **0.629** / 0.504 / 0.500 |
| b2_a0 | Konpaku-aware finisher, generic Kikon rule, awaken in every mode, mix | **0.7151** | 0.227 / 0.287 / **0.953** / 0.700 |
| b3_a0 | KESSA: awaken gap, AS3 / red AS2 steer, KESSA mix | 0.6827 | 0.170 / 0.324 / 0.783 / 0.675 |

- b1_a0 and b2_a0 touch disjoint code: b1 the neutral punish, b2 the SP hold and the string's target. b2 calls them
  complementary. b1's own open items are exactly b2's fixes: ptr3 at 0.50, kills at pointer 1, red Kikons.
- b0's negative results, kept: steering strings to AS2 costs more than it buys. Removing pointer 2's J costs −0.10.

## Mechanism (this cell)
1. **b2_a0's finisher, ported onto b1_a0's file** (a combination of two pieces that worked):
   - `iks-kikon-value`, `iks-finish-target`, `*iks-generic-kikon*`, `*iks-kikon-costly-p*`, `*iks-finish-steer*`, `*iks-finish-even*`
     and `*iks-awaken-modes*`;
   - b2's HARD mix (generic 0.04, space 0.26, whiff 0.26, ptr3 0.28, kessa 0.16), which also gives the confirm 96 % of HARD episodes
     instead of 88 % (the confirm runs only in a style mode);
   - b1's KESSA `(5 3)` steer stays, and b2's finish target overrides it against red.
2. **Hold ground (new): `iks-hold`, `*iks-hold-p*` 0 / 0.3 / 1.0.**
   - When: under pointer 1 or 3, his perceived J / NS is still live (`snap-live-p`) and started beyond his reach (the existing
     `*iks-his-reach*` table), so it will whiff.
   - What: she stands still (stick 0) instead of walking to her hover band. One roll per his move start.
   - **The located cause:** her whiff situations, logged by a scratch observer over the frozen situ.lisp (V1, 20 seeds a seat):
     - Her idle under pointer 1, sealed: 97 situations, 15 % punished. His sealed J1 at 3.2–3.3 m: 2 of 29. His NS1a: 0 of 21.
     - His J1 slid in while she walked back to the 3.7–4.2 m hover. By the time the 8 f delayed SNAP showed the recovery, the perceived
       distance was about 3.7 m. Her NS1a (hits 3.0–3.2, misses 3.4: catalogue R1) then needed a walk that didn't fit the window, and
       no confirm fired.
   - After the fix (V3): idle situations 0.42 → 0.65 punished. Pointer 1 J1: 10 of 14. Pointer 1 NS1a: 12 of 18. Pointer 3 NS1a:
     40 of 41.
3. **b0_a0's pointer-2 re-arm**, also ported: `*iks-retreat-rearm*` T, `*iks-retreat-p*` HARD 0.8 → 1.0. Here it is within noise
   (+0.004). It stays because it is b0's located fix, and pointer 2 is rarer now (KESSA strings go to AS3).

Rules: every chance is EASY ≤ NORMAL ≤ HARD and rolled once per event: the hold per his move start, the rest as in b1 / b2. The
opponent is read through the SNAP and the distance, his form (v0's tables) and `gauges-red-p`. The one exception is in "Risks".
Every tunable is a `defparameter` with a docstring.

## Measurements (matchup-eval, paired seeds 1–20 a seat, then 40)
| Variant | Seeds | Score | Strength | Spacing | Whiff | Ptr3 | KESSA | NORMAL |
|---|---|---|---|---|---|---|---|---|
| parent b1_a0 (re-measured) | 20 | 0.6554 | 38/40 | 0.201 | 0.618 | 0.518 | 0.500 | 0.05 |
| V1 = parent + b2's finisher | 20 | 0.7519 | 39/40 | 0.190 | 0.646 | 0.901 | 0.675 | 0.10 |
| V2 = V1 + confirm slack 3 → 5 | 20 | 0.7563 | 39/40 | 0.192 | 0.661 | 0.889 | 0.700 | 0.075 |
| V3 = V2 + hold ground | 20 | 0.7749 | 40/40 | 0.176 | 0.697 | 0.951 | 0.675 | 0.075 |
| V4a = V3 + b0's re-arm | 20 | 0.7787 | 40/40 | 0.181 | 0.692 | 0.951 | 0.700 | 0.05 |
| V4b = V4a + b0's pointer-1 hover 3.4–3.8 (rejected) | 20 | 0.7712 | 39/40 | 0.203 | 0.688 | 0.926 | 0.725 | 0.10 |
| **V5 = V4a, slack back to 3 (final)** | 20 | 0.7772 | 40/40 | 0.180 | 0.695 | 0.940 | 0.700 | 0.10 |
| V6 = V5 + `:whiff` takes the pointer-3 lunge (not delivered) | 20 | 0.7784 | 40/40 | **0.273** | 0.645 | 0.855 | 0.750 | 0.10 |
| **V5, final** | **40** | **0.7754** | **80/80** | **0.189** | **0.694** | **0.920** | **0.700** | **0.10 (factor 1)** |

- The slack (V2) is noise: +0.004, and the J1 failures didn't move with it (28 / 2 before and after). The hold fixed them. Slack is back
  at 3, which keeps its docstring's margin against his S6 J1.
- Attribution, honestly:
  - Most of the gain is b2's import: +0.097 at 20 seeds.
  - The hold adds about +0.02 (whiff +0.035, strength to 40/40).
  - b0's re-arm is within noise.
- Against the parent's 40-seed line:
  - score 0.6583 → 0.7754; strength 0.9625 → 1.0;
  - whiff 0.629 → 0.694, ptr3 0.504 → 0.920, kessa 0.500 → 0.700;
  - spacing 0.188 → 0.189;
  - NORMAL 0.075 → 0.10 (band 0–0.138, factor 1).
- Against the best sibling b2_a0 (0.7151): whiff 0.287 → 0.694 at about the same ptr3 / kessa.
- Host tests: 9843 checks, ALL PASS.

## Not a repeat
- The hold is a new mechanism from a located fault: the walk back during his whiff, measured per situation. It is not a reach or slack
  tweak: the slack change alone didn't fix the J1 cases.
- The finisher and re-arm ports combine pieces that worked in sibling cells, which the brief allows. Neither of their cells had the
  confirm, and b1_a0 had neither.

## What is left, for later cells
- **Whiff failures that look out of reach:**
  - Pointer 1, his N1C ending at about 3.57 m: 20 of 20 fail. NS1a's 22 f plus the walk to 3.2 m doesn't fit his 29 − 8 + 3 window.
  - His sealed N3A (15 f recovery): 0 of 7 with her idle.
  - Her down / wake-up: 11 / 44 situations (0 / 21 punished), since the style can't act in those states. All counts are V3 at 20
    seeds a seat.
- **Spacing is now the weakest theme (0.19).**
  - V6 shows the lever: let `:whiff` take pointer 3's NS3a lunge from 4–5 m. Spacing +0.09, whiff −0.05, ptr3 −0.085 (maybe noise),
    score equal at 20 seeds.
  - It isn't delivered because this cell's direction is whiff. A spacing cell could take it with a guard that keeps the whiff hover.
  - V6 is `iks-lunge-modes '(:whiff)`, a branch after `:space`'s at pointer 3.
- The far spacing situations (≥ 7.5 m, all of them opening at exactly 8.00 m after a reset) rarely convert at pointer 1 / 3: 10 of
  113 (V4a, 20 seeds a seat). Pointer 2, the Getsuga's pointer, opens only 12 of 656 spacing situations.

## Risks
- **The rule risk carried over from b2_a0:** `iks-kikon-value` reads his Konpaku pips (`gauges-konpaku` of the opponent), which goes
  beyond SNAP plus distance.
  - It is a HUD fact of the same class as `gauges-red-p`, and the coordinator rescored b2 with it.
  - If it is rejected, the `:ko` / `:tap` / `:even` split goes. Only the generic Kikon rule stands: about +0.08 of b2's gain.
- **The hold stands still near his reach edge** (sealed J 2.7 m, NS 3.65 m, the table's miss distances). A Kenpachi whose moves slide
  farther than the table, or a new form, could hit her where she stands.
  - Strength rose (80/80), so this opponent doesn't.
  - The roll is 0.3 at NORMAL, inside style episodes only (12 % there).
- NORMAL 0.10 sits inside the band (top 0.138). It moved 0.05–0.10 across the variants, which is the draw at 40 matches.
