# x-kh-H r1 b2_a0 (clash / awakening breakers), seed0 300, HARD, 600 matches each
Baseline 0.5083. Arm = hk-pot + exchange keys in :base. Counts: anchor / mix / rest as ko_wins-ko_losses-timeouts.
- v1 clash-p 1.7, clash-margin 1.6: 0.4851 (184-1-15 / 43-18-139 / 64-2-134)
- v2 v1 + awaken-break-p 1.9, awaken-kikon-p 1.2: 0.4835 (185-1-14 / 39-16-145 / 66-2-132)
- v3 clash-p 0 + awaken 1.9/1.2: 0.3465 (139-1-60 / 33-25-142 / 35-10-155)
- v4 clash-p 1.7, margin 0.3 + awaken: 0.4588 (189-0-11 / 38-15-147 / 48-1-151)
- v5 clash-p 1.7, margin 2.0: 0.4951 (189-0-11 / 44-16-140 / 64-4-132)
- v6 awaken-break-p 1.9, awaken-kikon-p 1.2 only (FINAL cand.lisp): 0.5049 (178-1-21 / 60-10-130 / 65-5-130)
No variant beat the baseline. Clash is worth keeping on (p 0 loses 0.16); more clash does not help. Awakening breakers raise mix KO wins (43->60) but time-outs stay ~65 percent. Mix/rest stall is not moved by these keys.
