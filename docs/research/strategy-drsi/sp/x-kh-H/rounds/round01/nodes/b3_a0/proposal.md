# b3_a0: style keys (kk-*) for Hisagi vs Kenpachi
Final cand = scratch/v5.lisp: baseline + :kk-reach-margin 1.0, :kk-lunge-p 1.0, :kk-step-in-p 0.0, :kk-hoho-in-p 1.0, :kk-hin-fs 100, :kk-hoho-in-max 6.0.
Measured (seed0 300), score 0.5841 (baseline 0.5083): anchor 180:2:18, mix 77:61:62, rest 94:17:89 (ko_wins:ko_losses:timeouts).
Runs (score): v1 ns-safe 0 + dodge/step 0 = 0.269; v2 reach/lunge/step-in 0 = 0.4851; v3 ns-safe 0 + lunge = 0.3581; v4 v2 + hoho-in 0.5 fs 100 = 0.5082;
v5 = 0.5841; v6 v5 + brawl-p 1 / read-range 4 = 0.5743; v7 v5 with fs 200, dodge 0.5 = 0.5066.
Findings: Hoho-in (gauge 100, p 1) is the lever that cuts time-outs (mix 123 -> 62); kk-ns-safe-p 0 and dodge/step off lose to the mix.
