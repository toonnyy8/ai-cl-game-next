# b2_a1: even-or-behind-out + DRIVE switch (ichigo-ki-style)
Slice: lead :even, OR (lead :behind AND dj :out). Strategy: :fn ichigo-ki-style with :base (:dswitch 0.5).
History read: round 1 (ken-ki-style scaling) was noise; round 2 siblings found the lever, Kenpachi playing ichigo-ki-style (b0_a0 even 0.55, b2_a0 even|behind&out 0.575, b1_a0 Reishi slice 0.46).
This cell is b2_a0's slice plus the new section 8.16 key :dswitch 0.5 (the only structurally new piece; the Ichigo mirror was -0.135 at 1.0, so half).
Dev 800x100: 0.58 vs 0.075 (gain +0.505, z 9.5, own 50.7%). b2_a0 same slice without switch 0.575: dswitch is noise-neutral here.
Second block 900x50: 0.57 vs 0.13 (b51/c7, own 44%); b2_a0 0.58. Holds.
Other tries (dev, all ichigo-ki-style): even|ahead&ored 0.515 (own 52%); even|ahead&prev = even 0.55; even|ahead&awk capped (90%); even|ahead&awk-no capped (65%); even|behind&out|ahead&ored 0.54 (54%).
Honest: statistically equal to b2_a0; ahead slices add nothing under the cap. Whole-game ichigo-ki-style (0.835 at even|ahead&awk, capped) is a lookup-entry candidate.
Risk: low; own ~45-51%, under the 60% cap.
