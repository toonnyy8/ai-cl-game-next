# b0_a0 (round 2): kite with a long reach and long chains, owned only while AHEAD

Slice (:own): ((:lead :ahead)) = my Konpaku above his, own_share ~0.32 (under the 0.6 cap).
Strategy: the incumbent s7 kite with :range 4.5 (3.2), :cont 1.8 (1.3), :awaken 0.0 (4.0): when ahead, stay further out and push every hit into a longer string, never spend Reishi on an early awaken.
History: round 1 only ever claimed everything (no slice separated; kite, cont and awaken were the levers); the incumbent is the round-1 kite. Not a repeat: a SITUATIONAL slice, with the levers pushed past the incumbent only where a lead makes patience and conversion pay.
Dev (200 matches, seed0 800): generic CPU in lead/mr slices lost or tied (ahead -0.065, behind -0.18, mr low +0.01); kite variants: behind+awaken 8 +0.025, ahead awaken 0 +0.025, ahead range 4.5 +0.055 (cont 1.3), cont 0.6 -0.105 (monotone: more cont is better), cont 1.8 +0.09 (z 2.5), cont 2.6 +0.06.
Second block (seed0 900, 100 matches): cont 1.8 +0.05 (0.44 vs 0.39), cont 2.6 0.0, cont 1.3 -0.02. Range 6.0 identical to 4.5.
Expected benefit: +0.03-0.05; risk: dev noise ~0.04, best of ~15 variants; the :cont direction held on both blocks.
