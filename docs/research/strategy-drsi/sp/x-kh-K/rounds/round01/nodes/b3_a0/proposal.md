# b3_a0: stand-off breaker fully on (style keys)
Deltas vs baseline c-ki-k-r2-b1a2 (all :base): :kso-stale 60->0, :kk-ns-safe-p 0.8->0.0, :kk-reach-p 0.5->0.0, :kk-step-p 1.0->0.0. Exchange keys untouched.
Why: stage 0 stalls (~2/3 time-outs); removing Hoho-safety and reach discipline makes Kenpachi start J1/NS at once.
Measured (seed0 300, 8-run budget, 5 used):
- v1 (stale 20, safe 0.3, reach 0.2, step 0.3): 0.6419 (mix to 54, rest to 50)
- v2 FINAL (all four at 0): 0.7162; anchor 188/12/0; mix 105 W/90 L/5 TO; rest 138/59/3 TO
- v3 (v2 + wave-p 0.9 + bankai-p 1.0): 0.637, 0 TO but losses up (mix 77/123)
- v4 (v2 + step-in-p 1.0): 0.7162, identical counts = inert
- v5 (v2 + bankai-p 1.0): 0.637 = v3, so bankai-p 1.0 is the harm; wave-p untested alone
Baseline 0.4357.
