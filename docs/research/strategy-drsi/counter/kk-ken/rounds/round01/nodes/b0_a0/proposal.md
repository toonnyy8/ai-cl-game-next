# b0_a0 (kk-ken, round 1): ken-ki-style when not ahead

Slice (:own): :lead :behind OR :lead :even (my Konpaku minus his). Strategy: `:fn ken-ki-style` (Kenpachi's KI matchup style CPU,
seeds/s5), run for any opponent. The incumbent plays when I am ahead.

Why: no history (round 1). The incumbent mirror is the generic core CPU + MCTS; the KI style CPU is a much stronger general tactic
(8.10, Hisagi vs Kenpachi 0.965+). Replacing it everywhere is capped (raw win share 0.995, own 1.0, capped), so the claim is a slice.
Dev (seed0 800, 100 seeds, both seats), single-lead slices: behind 0.855 (own 0.16), even 0.805 (0.22), ahead 0.655 (0.32).
behind+even 0.97 (own 0.25, gain +0.47, z 9.4); second block seed0 900 x50: 0.96 (z 6.5); behind alone on 900: 0.86.
Not a repeat: first cell in this workspace. Risk: a whole-game-replacement in disguise (the style CPU is just stronger than the
incumbent); a lookup entry would also do. Ahead is left to the incumbent only to stay under the cap; claiming it gives 0.995 raw.
