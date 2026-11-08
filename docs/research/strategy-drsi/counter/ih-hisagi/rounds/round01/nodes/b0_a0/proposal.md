# b0_a0: ken-ki-style on lead-even / far-distance slice (hisagi vs ichigo, HARD, frozen ki-ichigo)
Incumbent s3-zoner wins 0 of 200 on search seeds, so any win is gain; the problem is the 60% cap.
Cand: :own lead:even OR dj:out OR dj:afar, :fn ken-ki-style. Dev (seed0 800, 100 seeds): 2/200 vs 0/200, gain 0.01, z 1.4, own 0.50, uncapped. Noise-level.
Dev probes (50 seeds, ken-ki-style unless noted; comp share, own share):
- whole-game-like (capped): lead ahead|even 0.31 (0.81); lead ahead|mr high 0.32 (0.98); lead even|behind 0.14 (0.94); mr high|dj reach 0.13 (0.91); mr high 0.09 (0.89); ichigo-ki-style all-game 0.01.
- uncapped slices: lead even 0.01 (0.42); dj out|afar 0; mr low 0 (0.49); dj reach 0 (0.07); lead even|dj out|afar|dj reach 0.04 (0.62, capped).
Finding: ken-ki-style (not ichigo-ki-style) beats the zoner incumbent only when it runs most of the game (own >= 0.8, share 0.3); every slice under the 60% cap gains ~0. Recommendation: Hisagi vs Ichigo whole-game lookup replacement with ken-ki-style (c5 :own lead ahead|mr high: 0.32, z 5.7, 50 seeds), as done in 8.10.
Risk: cand.lisp is near the incumbent; expected gain ~0.
