# b1_a2: parent b1_a1 kept; its neighbourhood probed and no single change beat it
Mechanism: identical to b1_a1 (a-ichigo-press + :iks-mix-ptr3 0.6, :iks-mix-space 0.1, :iks-wait-max 40, :iks-gap-p 1.0, :iks-gap-fs 150, :iks-gap-wait 5.5).
Evidence: 16 one-change probes on the parent (seed0 300), none above 0.8119:
mix-kessa 0.4 0.764, 0.25 0.731, 0 0.767; mix-whiff 0 0.741, 0.5 0.776; mix-generic 0.3 0.642; meaty-p 1 + far 4 0.759; hoho-p/wake-hoho-p 1.0 0.782; hoho-p 0.6 0.784;
kikon-costly-p 1 0.804; steer-p 1 + kikon-p 1 0.766; :kikon 1.5 0.810; awaken-p 1 + retreat-p 0.5 0.807.
mix-ptr3 0.8, mix-space 0, wait-max 20 were byte-identical to the parent (duplicate key: the first occurrence wins, so my appended value was ignored; not a real test).
Not a repeat in intent (new knobs: kessa/whiff/generic mix, meaty, hoho, kikon), but the result is a null: the parent sits at a local optimum for these knobs.
Risk: same seed-300 overfit as the parent (about 1.5 SE over b3_a0); this cell adds no gain.
Measured (seed0 300): score 0.8119; anchor 167/31/2, mix 155/45/0, rest 167/33/0 (wins/losses/timeouts).
