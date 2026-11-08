# b0_a0: ken-ki-style whenever not ahead (hisagi vs hisagi, HARD)
Slice: `:lead :behind` OR `:lead :even` OR `:ored :yes` (own_share 0.42, under the 0.6 cap). Strategy: `:fn ken-ki-style` (Kenpachi's KI style CPU,
a strong general tactic for any character). The incumbent keeps play when Hisagi is ahead on Konpaku and the opponent is not red.
No history existed (round 1, siblings empty). Not a repeat. Mechanism: the mirror incumbent is the weak generic core CPU + MCTS; the KI style CPU
is far stronger, so the composite uses it exactly where it must catch up or press, and leaves the incumbent when ahead (keeps own_share below cap).
Dev (seed0 800, 100 seeds): behind only 0.645 (inchigo-ki) / 0.895 (ken-ki); behind+even 0.955; final 0.985. Second block (seed0 900, 50 seeds):
behind-only ken 0.85, behind+even 0.94; final 0.96 (own 0.47). Risk: dev gains shrank on fresh seeds in other pairings; here effect is large (z>8).
Whole-game ken-ki replacement was not tried (capped anyway).
