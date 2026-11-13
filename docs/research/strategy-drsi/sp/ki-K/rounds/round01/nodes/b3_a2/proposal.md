# b3_a2: b3_a1 plus a wider brawl-read range (:kk-read-range 3.8)
Mechanism: b3_a1's arm (0.8746) with :kk-read-range 3.1 -> 3.8: the sealed brawl read (tame / J1 / NS1a on her move start) and the dodge's reach floor now answer her from farther out.
Evidence (seed0 300, one knob on b3_a1): brawl-p 1.0 0.8647, dodge-p 0 0.8663, meaty-p 0 0.5808, ns-stop-p 0 0.8696, link-p 0 0.8828, bk-ns-p 0.8 0.8663, climb-p 0 0.8713, lunge-p 0 0.8746; read-range 4.0 0.8878, 3.5 0.8894, 3.8 0.9092 (+ link-p 0 0.8828).
Not a repeat: a0/a1 moved only the back-Step and stance knobs; this is the read-range lever.
Measured: 0.9092; anchor 183W/13L/4TO, mix 174/25/1, rest 191/9/0.
Risk: seed-300 overfit (SE ~0.02); the 3.5 / 4.0 neighbours score 0.889, so the gain is partly noise.
