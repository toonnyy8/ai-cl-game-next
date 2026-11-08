# b1_a0: Ichigo's own KI style CPU while not ahead (ii-ichigo, round 1)

Slice (:own): lead behind OR even OR opponent red (own share ~0.28, well under the 60 % cap).
Strategy: `:fn ichigo-ki-style` (Ichigo's KI matchup style CPU, runs for any opponent), no base/rules.
History: sibling b0_a0 owns the same slice with `ken-ki-style` (dev 0.91). This cell swaps the style CPU: ichigo-ki-style, a different
strategy, higher dev share at roughly half the slice.
Dev (seed0 800, 100 seeds): share 0.96, gain +0.46, z 9.1. Second block (seed0 900, 50 seeds): 0.99, gain +0.49, z 6.9, own 0.30.
Variants (dev 800): behind/even only 0.925 (own 0.22); behind only 0.855 (own 0.14); ken-ki-style on dist out/afar 0.875 (own 0.43);
ken-ki-style on busy ost 0.895 (own 0.83, capped).
Risk: the effect is a style CPU simply out-playing the generic mirror CPU, so it likely suits a lookup-level replacement too.
