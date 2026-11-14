# b0_a1 (IH round 1, Ichigo vs Hisagi)
Mechanism: parent b0_a0 (r2b2a1 style, 0.9851) plus :range 0.5 kept, :iks-mix-generic 0.6 (raises the generic-episode weight; the style's other modes keep their weights, normalised), so more episodes use the generic CPU + MCTS, which closes the passive Hisagi arms faster.
Evidence: generic 0.3 -> 0.9901, 0.6 -> 0.9917. Tried and not kept: :range 0.3 (0.9769), :awaken 1.0 (0.9851, identical to parent: awaken inert here), wait-max 90 (0.9901).
Why not a repeat: a different knob group (the :iks-mix-* weights) from the parent's range/awaken tweaks.
Risk: gains are 1-3 matches of 600, within noise; the ceiling is ~1.0.
Measured final (seed0 300): score 0.9917; anchor 200/0/0, mix 200/0/0, rest 198 W / 0 L / 2 TO (of 200 each).
