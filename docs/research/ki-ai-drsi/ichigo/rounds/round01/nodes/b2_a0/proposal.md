# b2_a0 (round 1, Ichigo): the Konpaku-aware finisher (theme 指針三狩魂 pointer 3)

## Mechanism
Each SP Ichigo holds or taps is now chosen by what it is worth against Kenpachi's Konpaku. The approved style (DUEL_MATCHUP_AI §4:
"hold a Kikon only when he is red", "finish at pointer 3") is applied to every episode at HARD, :generic ones included.

1. **`*iks-generic-kikon*` (HARD only).** A :generic episode's steps go through `iks-generic`, so the shipped CPU's SPs follow the style's
   Kikon rule. Before, `cai-sp` held 0.35 of them against a non-red Kenpachi. He cancels those, and each one was a failed ptr3 situation.
2. **`iks-kikon-value` / `iks-sp-frames`.** Against red, the hold is decided by core.lisp's own counts (`core-kikon-count`,
   `core-soul-break-count`) and his Konpaku pips:
   - `:ko`: the red Kikon takes his last Konpaku. Hold.
   - `:tap`: the Soul Break would take 5 (a pointer-3 SP, ≥ 5 left). Tap.
   - `:even`: the Kikon takes what the Soul Break would (pointer 2). Hold.
   - `:costly`: `*iks-kikon-costly-p*`, 0 (left as a knob).
   - Not red: never hold.

   This replaces `*iks-kikon-profiles* '(2)`, which was the `:even` case alone.
3. **`iks-finish-target` (`*iks-finish-steer*`, `*iks-finish-even*`).** Against red, a style string runs to the finisher whatever its steer
   roll says:
   - AS2 held when that Kikon K.O.s him, or when it is `:even` with no 5-Konpaku kill in reach (Konpaku 4 in the Shikai);
   - AS3 tapped when its Soul Break takes 5.

   KESSA's AS2 steer now becomes AS3 when he has ≥ 5 left, so the kill is 5 instead of 4.
4. Two tweaks outside ptr3:
   - `*iks-mix*` HARD :generic 0.12 → 0.04 (space / whiff 0.26, ptr3 0.28);
   - `*iks-awaken-modes*`: every style mode, not only :kessa, takes the awaken roll once the gauge is full.

## Evidence (my diagnostics: the baseline at 20 seeds a seat, the combat log split by the episode's mode)
- ptr3 situations at baseline: 95. Failures: 40.
  - **17 Kikon follow-ups against a non-red Kenpachi, all from :generic episodes.** A temporary per-episode log line showed it; the line
    was removed before delivery.
  - 16 capped Soul Breaks: the kill came with < 5 Konpaku left, so −4 / −3 counted as failures (9 of them KESSA, −4).
  - 6 KESSA Soul Breaks at pointer 1 / 2 (−4) and 1 Shikai −3.
- A Soul Break counts ok only at −5, and he has 9. So after the first pointer-3 kill (9 → 4), every later Soul Break is a failure by
  construction. The only successes left are red Kikons, and with ≤ 4 left a red AS2 Kikon (3, KESSA 4) usually K.O.s him outright.
- No history exists yet, since this is round 1. The sibling directories were empty when I started.
- b1_a0 delivered while I worked (whiff confirm, 0.6583 at 40 seeds). I read it before finishing. It takes a different route:
  - a whiff reaction seen in the SNAP, plus KESSA steered by red to AS3 / AS2;
  - it does not touch the :generic episodes' Kikon or read his Konpaku;
  - its ptr3 fell to 0.50, and it names "kills at pointer 1" and "red Kikons" as open follow-ups.

  This cell fixes exactly those, so the two are complementary. A later round could combine b1's confirm with this finisher.
- The baseline's proposal lists its weak spots: the hover outside the whiff radius, the J at pointer 2, a time-out. None of them is the
  ptr3 leak found here.

## Measurement (20 seeds a seat, paired on seeds 1–20; the same opponent, ken/champion)
| Step | score | HARD | spacing | whiff | ptr3 | kessa | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline v0 | 0.5877 | 34/40 | 0.208 | 0.339 | 0.579 (55/95) | 0.525 | 0.075 |
| + generic Kikon rule | 0.6692 | 39/40 | 0.188 | 0.312 | 0.761 (67/88) | 0.600 | 0.075 |
| + Konpaku value (no steer) | 0.6772 | 40/40 | 0.200 | 0.314 | 0.734 (58/79) | 0.600 | 0.075 |
| + finisher steer | 0.6941 | 40/40 | 0.195 | 0.318 | 0.897 (70/78) | 0.550 | 0.075 |
| + `:even` → AS2 | 0.7015 | 40/40 | 0.194 | 0.315 | 0.925 (74/80) | 0.575 | 0.075 |
| + mix (generic 0.04) | 0.7064 | 39/40 | 0.229 | 0.309 | 0.972 (69/71) | 0.600 | 0.075 |
| + awaken in every style mode | 0.7128 | 39/40 | 0.229 | 0.289 | 0.958 (69/72) | 0.675 | 0.025 |

**Final, 40 seeds a seat (score.json):**
- score **0.7151**, against the baseline's 0.5781;
- strength 0.975 (78/80), signature 0.542;
- themes: spacing 0.227, whiff 0.287, ptr3 **0.953** (141/148), kessa 0.700;
- NORMAL 0.0625, inside the band 0–0.138, factor 1.

The last two steps are each within the ±0.02 noise of a 20-seed comparison. They are kept because each moved its own theme in the expected
direction.

## Expected benefit, risks
- Most of the gain is the ptr3 theme (0.56 → 0.95). Strength rose too: fewer cancelled Kikons, and the finisher K.O.s in one go. ptr3 is
  near its ceiling. The remaining failures are kills by a J link or a later segment before the SP lands.
- **A rule risk.** `iks-kikon-value` reads his **Konpaku pips** (`gauges-konpaku` of the opponent), which goes beyond SNAP + distance.
  - It is a HUD-visible fact of the same class as `GAUGES-RED-P`, which v0 and the generic `cai-sp` already read through the opponent's
    gauges.
  - No own-state substitute exists. A tally of the Konpaku she has taken drifts, because his special AS (CHIGIRI / TATE-GOTO) costs him a
    Konpaku of his own, and his style uses it on purpose.
  - If the read is rejected, the `:ko` / `:tap` / `:even` split goes with it, and only piece 1 stands (the generic Kikon rule, about
    +0.08 at 20 seeds).
- Whiff dips slightly (0.31 → 0.29), because the finisher steer runs strings longer and the extra awakenings change the KESSA play. The dip
  is within noise, but whiff is the theme to watch.
- NORMAL: piece 1 is off below HARD. The value rule and the awaken modes do reach NORMAL's 12 % style episodes, and NORMAL stayed in the
  band (0.025–0.075).
