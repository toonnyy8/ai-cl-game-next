# b2_a0 behind-or-red (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` (own ~0.11) OR `:ored :yes` (opponent red, own ~0.05); union own_share 0.17 (< 0.6 cap).
Strategy: `:fn ichigo-ki-style` (her own style CPU; the incumbent plays Kenpachi's), no :base.

History read: round 1 (old incumbent = ichigo-ki-style) gained only via :range 0.7 on reach/Reishi slices, ken-style-all won as a whole replacement
(now the incumbent). Round 2 siblings b0_a0 / b1_a0 found "behind -> own style" (+0.18..0.22 dev, replicated on seed0 900).
I reproduced that signal and probed what ELSE her own style wins, to add a second, different slice (dev seed0 800 x100 unless noted; gain vs inc 0.43):
- even alone -0.04; even x low/high/far -0.03/-0.07/-0.11; ahead -0.18 (siblings): own style only helps when not winning.
- opp down (`:ost :down`) +0.125 (900: +0.12) but it is a behind proxy: down x (even|ahead) gives 0.00. opp active +0.07 / evade +0.045 (own 2%, noise).
- behind x near his reach +0.165 (carries all of behind's gain); behind x far -0.04 (1% exposure); behind x Reishi high +0.025.
- `:ored :yes` alone +0.11 (z 2.3, own 4.9 %); second block (900 x50) +0.08; ored x (even|ahead) (not behind) +0.06 / +0.07 on both blocks. Replicates in sign.
  Mechanism guess: her own style carries the red-opponent finish logic (Kikon / K.O. check) that Kenpachi's style lacks for her kit.
- behind OR ored: dev +0.325 (b82 c17, z 6.5); second block 900 x50 +0.24 (z 3.2). Gains roughly add (0.22 + 0.11), so the slices are independent.
Not a repeat: same strategy as b0/b1 on their behind slice, but adds the red-opponent slice as a second, independently replicating claim (union, not a retune).
Risk: butterfly effects (a switch changes the later match), so expect shrinkage on the search seeds (guess 0.55-0.65); ored's part alone is z ~1.2-2.3.
Selection: ~20 probes total on dev, the final was chosen from a short list of two principled slices, then confirmed on the second block.
