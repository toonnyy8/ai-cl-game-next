# b0_a1 (round 1): wake-up back-off -- NEGATIVE RESULT

Job: after Hisagi's knockdown, walk away (stick back, no move, no Hoho) instead of letting the shared CPU spend the wake-up Hoho into Kenpachi's bait.
History read: baseline (merged style, dev 0.195); b0_a0 (roll / guard / SP at wake-up: all lose); b1_a0 (kite, live flat); b2_a0 (punish a whiffed recovery, live 0.04 -> 0.15 rescored); b3_a0 (DRIVE switch, neutral).
Not a repeat: b0_a0 pressed or rolled; this presses nothing (pure spacing). Not a KI-code duplicate (they never retreat).

Mechanism: HKS struct (includes HMS); one brain-roll per knockdown (*hkb-p* easy 0 / normal .5 / hard 1); on the first free frame, if Kenpachi is perceived :idle at 2.0-2.8 m (the bait's stand-off), hold the stick back for up to *hkb-frames* (16) steps, else leave it to the merged style.

Measurement (dev seed0 300):
| variant | scale | score | live / past / arms / standin |
|---|---|---|---|
| ungated, 40 f, any Kenpachi state | 0.5 | 0.048 | .020 / .015 / .137 / .019 |
| gated to idle 2.0-2.8 m, 16 f (final) | 0.5 | 0.122 | .039 / .119 / .309 / .019 |
| same (final) | 1.0 | 0.117 | .025 / .117 / .316 / .010 |

Baseline dev 0.195 (scale 1): strictly worse; live group unmoved (0.04 -> 0.025), stand-in collapses 0.24 -> 0.01.

Findings: walking back is not invulnerable and not a defence: Kenpachi (the KI code and most arms) closes and hits a retreating back; even a gated 16 f walk cost the stand-in group. With b0_a0 this says every replacement of the first free frame loses; the generic wake-up Hoho (invulnerable) is right against the meaty KI code. Gains here came from elsewhere (b1 kite, b2 punish). Do not keep. Untried: avoiding the knockdown (guard before the launcher).
