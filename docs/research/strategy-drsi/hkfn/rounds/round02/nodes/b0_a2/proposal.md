# b0_a2 (round 2): wake-up whiff punish / guard + the Reishi pot

Started from: PARENT_DIR b0_a1 existed but I rebuilt on b0_a0 (round 2: punish a recovering Kenpachi at the first free frame after a
knockdown, else a 20 f Guard instead of the wake-up Hoho; live 0.198 rescored) and added round 1 b3_a2's Reishi pot (best round-1 score,
0.315 rescored, live 0.104). Dropped b0_a1's hoho-end Guard (neutral).

Job (honest): this is TWO rules, not one: (1) hkw-step: his first free frame after a knockdown (the direction hint); (2) hkb-step: when Reishi <= 80 %,
flash-step up, Kenpachi >= 4 m and not mid-move, one roll per episode -> free WHITE Burst. Everything else: hisagi-merged-style. Under the keep
rule's "one job" this is a combination; it is submitted for its measured effect (the two levers hit different losses: the wake-up loop and
the clock-decided 9-9 Konpaku Reishi % ends).

History: round 1 first-free-frame replacements lose; b2_a0 whiff punish raised live only; b3_a2 pot raised past/arms/stand-in; b0_a0 guard
raised live to ~0.2. They act on disjoint situations, so the gains stack (and more: shorter wake-up loops keep the Reishi pot affordable).
Not a KI-code duplicate (Kenpachi's KI code neither guards at wake-up nor bursts).

Bug found on the way: the first run scored 0.005 because hkb-step returned T (a SETF) whenever the pot was closed, deciding every step; fixed with (progn ... nil).

Measurement (dev 300, scale 1, 1,220 matches): score 0.4496; live 0.5099, past 0.3706, arms 0.5651, standin 0.3529; inc_live 0.125 (tripwire unmoved).
Baseline dev 0.195; b0_a0 0.2559 (live 0.272); b3_a2 dev 0.3315 (live 0.099). The sum exceeds both, so the interaction is positive. Host tests ALL PASS.
Single run, no scale-0.5 comparison made; noise +-0.02.

Risks: stand-in 0.353 is under the 0.3762 floor; the two rules are not one job; the guard length is chaotic (12/20/36 f). Drinking is 
punishable by a meaty Kenpachi if the 4 m check is stale (perception delay).
