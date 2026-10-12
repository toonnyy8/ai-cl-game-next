# Round 2 baseline: round 1's pick b1a2, integrated onto R18 (DUEL_LILLE_V3 §22.3)

- The CPU is round 1's b1a2 (see `rounds/round01/nodes/b1a2/proposal.md` and its parents b1a1, b1a0 for the mechanisms):
  every J / K link that hits into the stance (`:l-after-*` 1.0), the R17 link by his CPU (BR-AI-LINK-CMD), the base
  stance's full-pip cash-out (SP2 HIRENKYAKU from range, BR-AI-CASH-PLAN), the wing reserve (BR-AI-CALL `:keep`), the
  turn before the follow-up after the dash, the step-in interrupt, the stance exit, the charge let-go, the opponent's reach
  envelope (the kite), the Kikon only on openings, `*BR-AI-DIFF*` 0.2 / 0.3 / 1.5.
- Merged by the lead onto the rules as they are now (a 3-way merge from the old freeze 36e93c7): R18 (§23) the charged L
  never turns onto the opponent (snipe and dash: `:track` 0, no snap at the release), a Step during the charge keeps it and
  re-aims; the only overlap, BR-S-TICK's hold phase, runs his CPU's charge branch (BR-AI-CHARGE-TICK) and the human's Step.
- Added at the integration (not searched): the learner's `:charge` situation (BR-LEARN-CHARGE / -PLAN: a guard read ->
  level 3, Hoho / attack -> a tap, Step / back -> the charge's Step re-aims after his Step, BR-AI-RESTEP), AUTO COMBO's
  routes (R17's turn -> K1; a stance string's L L follow-up / SP2).
- Measured on R18 (40 seeds, `score.json`): 0.9102 (strength 0.853, masher 1.0, signature 0.923, NORMAL 0.36:
  Y 45/80, K 12/80, R 37/80, I 23/80, S 27/80; pacing medians 124.4–163.2 s). At the old freeze b1a2 scored 0.9716
  (strength 1.0, NORMAL 0.465): R18 took the snipe's snap onto a side-stepping opponent.
- Gates after the integration (simgate, 20 seeds, all K.O.): BY 131.7, BK 121.8 (60 seeds 122.3), BR 163.3, BI 155.3,
  BS 172.2, BB 213.2 s; Lille II's wins BY 10/20, BK 0/20 (60 seeds 9/60), BR 8, BI 5, BS 8; the mirror awaken A/B's
  never-awaken side 4 / 1 / 0 of 60. G2 identical.
