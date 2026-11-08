# b0_a1: ken-ki-style while ahead, or even with high reishi and (busy | not-close)  (hisagi vs ichigo, HARD, frozen ki-ichigo)
Incumbent s3-zoner wins 0/200 (baseline), so every win is gain.
History: b0_a0 (ken-ki on lead even | dj out | afar: 0.01, own 0.50), b1_a0 (even&free | opp busy: 0.02), b2_a0 (ichigo-ki while ahead: 0.02). All
found ken-ki-style beats the zoner only when it runs most of the game; none found an uncapped slice with real gain.
Mine (new): the lead-even slice is cut by MY reishi (:mr :high), which the earlier cells never used with lead even. Probes (50 seeds, seed0 800,
ken-ki-style, wins of 100 / own): ahead | even&mr high 23 (0.72, capped); ahead | even&busy 11 (0.62, capped); ahead | even&mr high&busy 5 (0.32);
ahead | even&mr high&(dj out|afar|reach) 10 (0.41); union of those two 22 (0.70, capped); + (:or :high) on the busy row 12 (0.56, uncapped).
Dead ends: awk, ored, or low, dj in, even&free, dswitch on ken-ki, hisagi-range (do in|reach): 0 wins.
Cand: :own ahead | even&mr high&busy&or high | even&mr high&dj out | afar | reach, :fn ken-ki-style.
Dev (seed0 800, 100 seeds): 22/200 vs 0/200, gain 0.11, b 22 c 0, z 4.69, own 0.577 (uncapped, close to the cap).
Second block (seed0 900, 50 seeds): 5 vs 0, gain 0.05, z 2.24, own 0.526. Effect holds, but shrinks.
Risk: own share near 0.6 (the cap may bite on the search seeds, then it scores as the incumbent); the slice was picked among ~40 probes (selection
bias); fuzzy memberships overlap so own shares are not additive. Whole-game ken-ki-style (lead ahead|mr high, 0.32) remains the bigger lever
(a lookup replacement, as in 8.10).
