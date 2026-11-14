# b3_a1 (IH, Hisagi, round 1): parent b3_a0's data arm + a wider generic walk band (:range 1.5, :ns 2.0, :cont 2.0)

Parent = hisagi-range-style + :awaken 5.0 (0.3927). Added base keys the range style's base form reaches through cai-neutral / cai-move-step:
:range 1.5 (walk-in band scale), :ns 2.0 and :cont 2.0 (start NS routes and continue segments more).
Probes (seed0 300; score, anchor/mix/rest W/L/TO): :range 0.6 0.2426, 0.4 0.2657, 1.3 0.4225, 1.5 0.434, 2.0 0.4175;
:ns2+:cont2 0.4059; :range1.5+:cont2 0.4208; :kikon 0 0.2805; :hold-awaken 0.3 0.3597; :b-wait/:b-walk-in 0.3944; :b-step-out/:b-walk-out 0.3746;
hisagi-merged-style (kk keys) 0.11-0.23 (worse).
Final (range 1.5, ns 2, cont 2): score 0.4373; anchor 196/4/0, mix 4/195/1, rest 62/132/6. The gain is in rest (38 -> 62 wins); mix still unanswered (4/200).
Risk: single seed block; range response is non-monotone below 1, so the effect is a plateau for 1.3-2.0, not a tuned optimum.
