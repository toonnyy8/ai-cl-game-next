# b1_a1 (round 3): b0_a2 + a wider range-control kite (third rule)

Job (kite rule): keep Kenpachi at poke range. When he closes inside 3.7 m (4.2 m in the Bankai), Hisagi backs off one Step (one roll per approach, HARD 1.0), then pokes with the pointer's NS from 2.6-6.5 m within 70 f.

Start: b1_a0 (b0_a2's wake-up punish/guard + Reishi pot, plus round 1 b1_a1's kite as rule 3). Only the kite knobs moved: *hkk-near* 3.3 -> 3.7, *hkk-poke-min* 2.9 -> 2.6, *hkk-poke-max* 6.0 -> 6.5, *hkk-window* 50 -> 70. Rules stay separable (own knobs, own step fn, own slots).

Evidence: b1_a0 rescored 0.4618 (live 0.436, standin 0.382); a knob-only retune of the kite, aimed at the weak stand-in group. Not a KI-code duplicate (Kenpachi's KI code never retreats).

Measurement (dev seed0 300, scale 1, single run): b1_a0 0.4977 (live 0.4109, past 0.4403, arms 0.6494, standin 0.4902); this cell 0.5251 (live 0.4455, past 0.4751, arms 0.6111, standin 0.5686); inc_live 0.125 unmoved. Host tests ALL PASS.

Risks: three rules, not one job (split into arms afterwards); arms fell 0.04 (cand-standoff 0.275 -> 0.15, k1-ken, k10-kends); single run, +-0.02 noise.
