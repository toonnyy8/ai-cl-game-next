# b0_a2 free-behind-or-red (ichigo vs kenpachi, HARD, round 2)

Slice: I am free (`:ost :free`, neutral) AND (`:lead :behind` OR `:ored :yes`); own_share ~0.13.
Strategy: `:fn ichigo-ki-style` (her own style CPU; the incumbent plays Kenpachi's), no `:base`.
History read: round 1 (old incumbent = her own style; only `:range 0.7` gained; ken-style-all won as replacement = now incumbent);
round 2 siblings b0_a0/b0_a1/b1_a0/b1_a1/b2_a0/b2_a1 all use "behind (| red)" with her own style (+0.18..+0.35 dev), unrestricted by state.
This cell adds the `:ost :free` gate: the swap only happens while she is in neutral, never mid-move, so the style hand-over does not cut a committed action.
Dev probes (seed0 800 x100, gain vs 0.43): behind-only-outside-dist-far/out +0.025 (own .05); mr high x behind +0.025; opp startup +0.015;
free x behind +0.315 (own .07; second block 900x50 +0.34); free x even -0.115; free x behind x mr low -0.005 (own 0); free x behind with s1 brawler base +0.015;
free x (behind | red) +0.415 (z 8.2, own .13; second block 900x50 +0.35, z 4.8); free x red alone +0.025; range 0.7 adds ~+0.025 only (noise).
Not a repeat: a refinement of the siblings' slice (free gate), same mechanism; the gate narrows own_share from ~0.16-0.2 to 0.13 and raised the gain.
Risk: butterfly shrinkage on fresh seeds (~10 probes selected); round 1 saw +0.1 dev shrink to ~0. Effect sizes here are large (z>4 on both blocks).
