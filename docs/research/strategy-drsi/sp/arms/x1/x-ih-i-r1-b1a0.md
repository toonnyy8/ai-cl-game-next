# b1_a0 (NS side of a cancel)
Baseline c-ih-i-r1-b0a1 (0.7706) + `:xch-sa-p 1.5 :xch-sa-wait 2` in :base. Final cand.lisp = scratch/v3.lisp.
All runs seed0 300 (anchor/mix/rest: wins-losses-timeouts):
- v1 sa-p 1.5, carry 0.5: 0.8185 (195-5-0 / 153-33-14 / 145-49-6)
- v2 sa-p 0.2, carry 4: 0.7294 (190-9-1 / 106-58-36 / 143-44-13)
- v3 sa-p 1.5, sa-wait 2 (FINAL): 0.8201 (195-4-1 / 149-33-18 / 150-43-7)
- v4 sa-p 1.6, carry 0.5, sa-wait 2: 0.8102 (200-0-0 / 130-45-25 / 158-33-9)
Finding: more SA after the cancel helps (+0.05); heavy carry-on hurts (v2, mostly mix time-outs). Baseline per-group counts were not rerun here.
