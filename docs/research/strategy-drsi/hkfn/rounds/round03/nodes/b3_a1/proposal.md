# b3_a1 (round 3): b3_a0 (b0_a2 + the Shikai kite) with the Reishi pot opened up

Job: rule 2 of three (hkb-step, the Reishi pot) retuned; rules 1 (hkw wake-up punish / guard) and 3 (hkk kite) untouched, all still separable
(own knobs, step fns). Change: *HKB-BELOW* 0.8 -> 0.95, *HKB-RANGE* 4.0 -> 3.0: a free WHITE Burst refills Reishi whenever the gauge is under 95 %
and Kenpachi is seen >= 3 m away and not mid-move (one roll per episode, HARD 1.0).
Evidence: b3_a0 notes 64 of 65 stand-in losses' wins/losses are bell matches decided on Konpaku 9-9 / Reishi %; round 1 b3_a2's pot was the
only resource lever that moved the clock-decided matches. Awaken timing / DRIVE switch / Burst-always were neutral or negative (round 1 b3_a0/a1).
So the pot is the resource lever worth widening. Not a KI-code duplicate (the KI code never drinks the pot).
Measurement (dev 300): scale 0.5 0.543; scale 1: score 0.527 (b3_a0 dev 0.4977): live .4356 (.411), past .480 (.440), arms .663 (.649),
standin .529 (.490); inc_live .125 (tripwire unmoved). Host tests ALL PASS. Single dev run, ~+-0.02 noise; gain +0.03 spans all four groups.
Risks: pot costs a flash-step third more often; thresholds untuned beyond one point.
