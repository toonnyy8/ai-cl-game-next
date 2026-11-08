# b1_a1 ki-lowfree-trail (ichigo vs kenpachi, HARD)

Slice: my Reishi low AND I am free (:ost :free, neutral) AND my Konpaku not ahead (behind or even); ~16% of judgements.
Strategy: `:fn ichigo-ki-style` run first with `:base (:range 0.7)` (closer approach), as b0/b2.

History read: b0_a0 (all leads, +0.10 dev / +0.06 search), b1_a0 (whiff-punish, data only, ~0), b2_a0 (:mr :low, +0.12 dev / +0.075 search).
Data-only strategies score 0 vs HARD Kenpachi and the bias keys are inert under :fn, so only :range matters; this is a narrowing of the
b2 mechanism, not a new lever. Narrowing keeps the gain with a third of the exposure.
Dev variants (seeds 800-849, ~100 matches, gain / own): dj far|out +0.01/.53; dj in|reach +0.03/.45; ahead only +0.04/.15; mr low :p 1.3 +0.12/.39
(:p inert); mr low|behind +0.06/.77; mr low x free +0.11/.25; mr low x dj far +0.08/.21; mr high range 1.2 -0.06/.41;
mr low x free x (behind|even) +0.12/.16 (b 12-ish pairs, z 2.27) <- final.
Not a repeat: a strictly tighter slice than b2 (adds :ost :free and not-ahead). Risk: chosen from ~12 variants on dev; gain vs b2 is within noise,
benefit is mostly lower variance. Expect search score ~0.30-0.32.
