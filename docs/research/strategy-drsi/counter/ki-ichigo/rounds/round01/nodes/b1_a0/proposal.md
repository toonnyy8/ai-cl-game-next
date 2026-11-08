# b1_a0 punish-active (ichigo vs kenpachi, HARD)

Slice: his move active/recovering (:ost :active) while he is out of / far from his J1 reach (:do :out/:afar) = a whiff-punish window.
Strategy: data only, no :fn (so the style CPU stops while it holds): :range 1.2, :hoho 1.8, :turn 1.4, rule on :ost :active -> :b-j1 +0.2,
:b-step-in +0.1, :b-wait -0.1 (seeds/s2-punisher's idea, restricted to a slice instead of replacing the incumbent).
History: siblings b0/b2 had no proposals when read; baseline is the shipped CPU 0.245. Whole-game seed strategies all won 0 against the
style CPU (seeds README), so a full replacement cannot help; I tried the incumbent's :fn with scaled outputs on slices (ored, behind, ahead,
ost down, mr low): all gain -0.01..+0.02, noise. Whiff-punish slice was the only structurally different one: +0.04 (b 8 / c 4, z 1.16).
Caveat: own_share is 0.0098 (about 1 judgement in 100), so the +0.04 is more likely butterfly noise than a real effect.
Risk: negligible (almost never fires). Expected benefit: ~0 to small.
