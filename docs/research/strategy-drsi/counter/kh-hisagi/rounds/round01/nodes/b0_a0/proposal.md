# b0_a0: s3-zoner everywhere (all three lead sets)

Slice (:own): ((:lead :even)) ((:lead :ahead)) ((:lead :behind)) = always (own_share 1.0), so the composite is s3-zoner alone.
Strategy: seeds/s3-zoner (wide range 1.5, NS share 0.9, shoots from afar, backs off inside his J1 reach, Kikon on a red opponent).
History: no sibling proposals existed (all three cells ran in parallel); baseline 0.035 on search seeds, 0.09 on dev 800-849.
Dev runs (50 seeds a seat, incumbent 9/100): s1-brawler always 0.01, s2-punisher 0.03, s4-discipline 0.07, s3-zoner 0.11 (gain +0.02, z 0.47).
s3 slices (gain, own_share): behind -0.01+... 0.10 (+0.01, 0.75); ahead 0.08; even 0.07; dj afar/out 0.04; dj in/reach 0.08; mr high 0.08; mr low 0.06;
ost free/down 0.07; ost active/startup/evade 0.06. No slice beats the whole; every difference is inside the ~0.05 noise.
Why s3: the lookup found it best for Hisagi vs Ichigo and sitcheck/seed runs showed s3 2/10 vs 1/10 for none at HARD vs Kenpachi.
Expected benefit: at most a few points on a 0.035 base; risk: none beyond noise (it is one library strategy, not a repeat of the incumbent).
Honest read: the incumbent is near a floor (Kenpachi wins ~95%); no data-only slice found with a significant gain.
