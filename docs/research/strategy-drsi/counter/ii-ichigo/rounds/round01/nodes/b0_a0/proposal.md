# b0_a0: Kenpachi's KI style while not ahead (ii-ichigo, round 1)

Slice (:own): lead behind OR even OR opponent red (~53 % of judgements, under the 60 % cap).
Strategy: `:fn ken-ki-style` (Kenpachi's KI matchup style CPU, runs for any character), no base/rules.
Evidence: history empty (siblings had no proposals). Baseline mirror ~0.5. Dev (seed0 800, 100 seeds): see dev.json,
share 0.91, gain +0.41, z 8.4, own 0.53. Second block (seed0 900, 50 seeds): see c3b result in the report.
Other variants on dev: behind-and-free only 0.615 (ichigo-ki-style) / 0.64 (ken-ki-style, 0.66 on block 900);
behind or red 0.87 (own 0.37). Widening the slice raises the share: the ken style simply out-plays the generic mirror CPU.
Not a repeat: first cell. Risk: it is nearly a whole-game replacement; near 60 % cap, a lookup-level replacement (ken-ki-style everywhere) may be better and is worth testing.
