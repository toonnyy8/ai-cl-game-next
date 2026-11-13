# b1_a0: pointer-3 only episodes
Mechanism: baseline a-ichigo-press (ichigo-ki-style, press :base/:rules) plus style keys: `:iks-mix-ptr3 1.0` with every other episode mode 0 (generic/space/whiff/kessa), `:iks-wait-max 45` (shorter hover), `:iks-awaken-p 1.0 :iks-gap-p 1.0 :iks-meaty-p 1.0`.
Evidence: no sibling proposals existed. Own scratch sweep (seed0 300): baseline 0.6122; mix toward kessa 0.6238; more ptr3 0.6551 (0.3 ptr3) -> 0.6865 (0.6) -> 0.6914 (0.8) -> 0.7244 (1.0). Raising kessa / whiff / space weights did not help; the gain is in the `mix` group (vs the pilot Kenpachi: 77-86 wins at baseline mixes to 135).
Not a repeat: baseline only varied :b-* biases, which are mostly inert for Ichigo at HARD; this uses the §6 style keys (episode mode mix) instead.
Risk: dev-seed overfit (SE ~0.02); a single-mode Ichigo is predictable.
Measured (seed0 300): score 0.7244 (baseline 0.6122); anchor 151 W / 44 L / 5 TO, mix 135 / 65 / 0, rest 150 / 50 / 0.
