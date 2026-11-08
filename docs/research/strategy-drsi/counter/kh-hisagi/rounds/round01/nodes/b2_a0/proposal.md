# b2_a0: s3-zoner pushed wider (range 2.0, NS 1.0, stronger back-off), all leads

Slice (:own): all three lead sets (own_share 1.0): the composite is the candidate alone. Claiming a slice did not help: b0_a0's slice
runs (and the sitcheck bins) show no situation where s3 differs from s3 elsewhere beyond the ~0.05 noise.
History: baseline 0.035 (search), 0.09 (dev). b0_a0 = s3-zoner as shipped in the library: search 0.135 (z 3.43), dev 0.11. b1_a0 empty at
reading time. Mechanism of b0 (spacing + NS) is what works vs Kenpachi; s1/s2/s4 were no better than the incumbent there (b0 dev runs).
Not a pure repeat: b0 left the zoner's knobs as shipped; the spacing is the lever, so I scaled it. Variants on dev (seeds 800 / 850, 50 a seat,
incumbent 9 / 8 of 100): range 1.2 -> 4-5 (worse), 1.5 (b0) 11, 2.0 -> 17 / 16 (gain +0.08, z 1.9 / 1.7), 2.5 -> 11 / 10, 3.0 -> 14 / 15;
hoho 1.5 + turn 1.4 + cont 0.5 + awaken 2 -> 4-5 (worse); awaken 0.5 -> 16 / 9 (noise). Range 2.0 is the one consistently ahead on both streams;
the non-monotone 2.5 shows the noise level, so expect a gain of a few points, not the dev's 8.
Candidate: s3-zoner with :range 2.0 (walk-to band x2.0), :ns 1.0, b-sp +0.2/+0.15/+0.25 at NS reach/out/afar, back-off b-walk-out 0.15,
b-step-out 0.12, b-j1 -0.08 when inside his J1 reach.
Risk: the range effect may be partly noise; worst case ~ s3's own score (b0 0.135) minus a bit.
