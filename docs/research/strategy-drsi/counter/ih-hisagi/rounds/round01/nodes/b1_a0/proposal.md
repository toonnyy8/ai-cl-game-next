# b1_a0: ken-ki-style on (lead even & ost free) OR opponent-busy states (ost active/evade/down)
Incumbent s3-zoner wins 0/200; the 8.10 mechanism (switch by state free/busy + lead) was never tried here (b0 used lead/distance only).
Cand: :own (((:lead :even) (:ost :free)) ((:ost :active)) ((:ost :evade)) ((:ost :down))) :fn ken-ki-style.
Dev (seed0 800, 100 seeds): 4/200 vs 0/200, gain 0.02, z 2.0, own 0.43, uncapped. Weak, noise-level; not confirmed on a second block.
50-seed probes (ken-ki-style, comp share / own): lead ahead only 0 (own 0.001, never fires); lead behind 0 (0.96 capped); lead even & mr high 0 (0.26);
mr high & dj reach|in 0 (0.93); ost free|startup 0.01 (0.91 capped); ost active|evade|down 0.01 (0.23); ored|down|even&out w/ kikon bias 0 (0.22); ahead|mr high 0.32 (0.98 capped).
Finding agrees with b0: only near-whole-game ken-ki-style beats the zoner (c: lead ahead|mr high 0.32, z 5.7, but capped). No slice under 60% yields more than ~0.02.
Recommendation: whole-game lookup replacement with ken-ki-style (lead ahead|mr high), as in 8.10.
Risk: near-incumbent, expected gain ~0.02.
