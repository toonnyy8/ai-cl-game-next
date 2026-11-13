# b2_a0: baseline press arm with the style's chances pushed to 1.0
Mechanism: baseline a-ichigo-press (fn ichigo-ki-style) plus style tunables (KNOBS §6.3): :iks-hoho-p / punish-p / confirm-p / meaty-p / wake-hoho-p / steer-p / kikon-p all 1.0 (defaults 0.9-0.95), :iks-wait-max 30 (default 150).
Evidence: siblings empty. Mix reshuffles (v1 0.6105, v2 0.5858, v4 0.6535) did not beat baseline 0.6122 except ptr3-heavy; chance-to-1.0 + short hover helped (v3 0.6683, v5 0.6716, v6 0.6931, v8 0.698). Retreat/gap at 1.0 hurt (v9 0.6733).
Not a repeat: baseline only has :b-*/scale keys; this uses the §6 style keys, a different lever group.
Risk: seed-300 overfit; chance=1.0 draws no RNG so stream shifts.
Measured (seed0 300): score 0.698 (baseline 0.6122); anchor 157/40/3, mix 116/84/0, rest 147/53/0 (wins/losses/timeouts).
