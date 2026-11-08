# b1_a2: b2_a1's not-behind slice (hoho ready | ichigo red) with the DRIVE switch at 0.5

Slice: `:own` lead even & hoho yes | lead ahead & hoho yes | lead even & ored yes. Strategy: `:fn ken-ki-style`, `:base (:dswitch 0.5)`.
History read: b0_a0 0.04, b0_a1 0.045, b1_a0 0.01, b1_a1 0.015, b2_a0 0.02, b2_a1 0.085 (score.json); baseline 0.0. Everything
that wins is ken-ki-style on a lead-even core; gain rises steeply with own share, the 0.6 cap is the limit.
Probes (50 seeds, blocks 800 / 900, gain): b2_a1 as is 0.10 / 0.08; + dswitch 0.5 0.10 / 0.08 (no effect, own 0.53 / 0.56);
+ (ahead & mr high) 0.15 (own 0.61 capped) / 0.06; mr high gating of the hoho / red rows 0.09 / 0.02 (overfit); lead ahead all-in
0.23 / 0.19 but own 0.76 (capped); ahead | even&hoho&ored 0 (own ~0: "ahead" almost never fires, the ahead rows are inert);
hoho & ost free 0 / 0.02 (the busy states carry the gain); + ahead&dj out 0.08 / 0.04; + ahead&ored 0.09 / 0.10 (own 0.60 edge).
Dev (seed0 800, 100 seeds): 17 vs 0, gain 0.085, z 4.12, own 0.536, uncapped (dev.json).
Not a repeat in kind? Honestly it IS b2_a1's slice; the only change is :dswitch 0.5, which measured neutral and lowers own ~0.01-0.02
(more margin under the cap). Finding: no structurally different uncapped slice found; hisagi-range-style stays 0 here (b1_a1).
Risk/benefit: ~+0.08, selection bias small (carried from b2_a1); whole-game ken-ki-style (lead even|ahead, ~0.3-0.5) remains the
bigger lever as a lookup replacement.
