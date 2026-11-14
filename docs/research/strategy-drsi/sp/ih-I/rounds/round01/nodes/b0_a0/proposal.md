# b0_a0 (IH round 1, Ichigo vs Hisagi)

Mechanism: the baseline arm (c-ki-i-r1-b0a2, 0.8993) with `:fn` swapped to the KI round-2 style `ichigo-ki-r2b2a1-style`
(it transfers to Hisagi), plus `:range 0.5` and `:awaken 2.0` (a closer, earlier-awakening generic fallthrough).
Why not a repeat: no history in this branch; the change is a different style function, not a knob tweak of the baseline.

Measured (seed0 300, build db031584):
- baseline (v0): 0.8993; r2b1a1 fn: 0.8977; r2b2a1 fn: 0.9571 (rest timeouts 44 -> 9);
  + wait-max 20 / ns-wait 18: 0.9554 (worse); + range 0.5 / awaken 2.0 (final): 0.9851.
- final: anchor 199 W / 1 L / 0 TO; mix 199 / 1 / 0; rest 196 / 1 / 3 (of 200 each).
Risk: the gain is mostly fewer time-outs vs the passive Hisagi arms; range/awaken tweaks were tried once each (noise possible).
