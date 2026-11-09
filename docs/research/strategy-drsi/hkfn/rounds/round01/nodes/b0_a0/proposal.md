# b0_a0 (round 1): Hisagi's own knockdown / wake-up -- NEGATIVE RESULT

Job (one line): change what Hisagi does between his knockdown and his first free frames, against Kenpachi's wake-up bait.
History read: none (round 1, siblings empty at start); baseline = merged style, dev 0.195, search 0.216.

## Mechanism tried (three wake-up variants, one roll per knockdown, HARD 1.0 / NORMAL 0.5 / EASY 0; state in an HKS struct that includes HMS)
1. Wake-up roll: stick held back while he lies (:down) so the wake-up becomes the 4 m back roll (invulnerable, ends ~6 m off, outside the bait).
2. Wake-up guard: Guard held 30 f on the first free frame instead of whatever the MCTS / generic CPU does (the wake-up Hoho).
3. Wake-up SP: the pointer's NS on the first free frame (Shikai K1 clears its 2.0 m dead zone at the bait's 2.3 m); a second try gated to
   Kenpachi perceived :idle at 2.0-2.7 m (the bait's stand-off, not a Kenpachi coming in).

## Measurement (dev seed0 300, --scale 0.5, 610 matches; wrapper with all chances 0 = 0.216, the baseline within noise)
| variant | score | live | past | arms | standin |
|---|---|---|---|---|---|
| baseline-equivalent (all 0) | 0.216 | 0.039 | 0.149 | 0.408 | 0.269 |
| roll | 0.110 | 0.069 | 0.059 | 0.237 | 0.077 |
| guard | 0.051 | 0.039 | 0.010 | 0.134 | 0.019 |
| SP | 0.089 | 0.088 | 0.045 | 0.202 | 0.019 |
| SP gated to the bait stand-off | 0.116 | 0.039 | 0.099 | 0.305 | 0.019 |

## Findings
- Every deviation from the existing wake-up behaviour (whatever the shared CPU does on its first free frame) loses on the pool, most of all
  against the KI stand-in (0.27 -> 0.02-0.08): a meaty Kenpachi punishes a roll's landing, a held Guard and an NS startup.
- Only the ungated SP and the roll moved the live group up (0.039 -> 0.088 / 0.069; 40 matches, within noise), at a far larger cost elsewhere.
- Gating the SP to the bait's stand-off removed its live gain (the gate rarely fires against the live KH), so the bait is not beaten by an
  opener from the wake-up: the knockdown is not where this pairing is won with a one-action replacement.
- Not kept: the file ships with all three chances at 0 (identical play to the baseline), so it cannot pass the keep rule (a near-duplicate of the merged style).
- Untried ideas for siblings: avoid the knockdown (guard / back-step before the launching hit), or a delayed wake-up action.
- Final (all chances 0, scale 1, dev 300): 0.1947 = the baseline's dev 0.195.
