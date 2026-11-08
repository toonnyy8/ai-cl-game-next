# b2_a2 behind-red-awk-even (ichigo vs kenpachi, HARD, round 2)

Slice: `:lead :behind` OR `:ored :yes` (parent b2_a1/b2_a0 slice) OR (`:awk :yes` AND `:lead :even`); own_share ~0.21 (< 0.6 cap).
Strategy: `:fn ichigo-ki-style` (her own style CPU; incumbent plays Kenpachi's), no :base (inert under :fn; range 0.7 added ~0).

History read: all round-2 siblings are behind / red-opponent slices of the same strategy (+0.18..+0.355 dev); round 1 was range 0.7 on the old incumbent.
New cue: `:awk` (I am awakened), never probed by siblings. Probes (seed0 800 x100, gain vs 0.43):
awk alone +0.17 (own .48); awk x ahead -0.105 (own .04); awk x even alone +0.08 (own .02); behind|red|awk (all) +0.275 (own .59, worse than parent);
behind|red|(awk x even) +0.415 (b96 c13, z 7.95). Second block seed0 900 x50 (inc 0.47): 0.83, +0.36 (b48 c12, z 4.6) vs the parent's +0.24 there.
Mechanism guess: once awakened, her own style (finishers / Kikon logic) beats the borrowed brawl style when the lead is level; ahead it loses (consistent
with the "own style hurts when winning" finding). Not a repeat: adds a new, independently signed clause (awakened x even) to the parent union.
Risk: the awk x even clause is only ~2 % of judgements and its alone effect is small (+0.08), so the extra +0.07 over the parent is possibly butterfly;
~9 probes of selection. If it shrinks, it falls back to the parent's behind|red score.
