;;;; R3's scripted check (xch2.md §R3): P1 Ichigo's J1 meets P2 Kenpachi's Shikai NS1a (startup 16, active 4) early in its startup: a
;;;; cancel. P1's J2 (pressed into J1's chain) then comes while NS1a is still in its startup / active frames. R3 off: the J2 is a second
;;;; CANCEL. R3 on (STRAT_SET *core-cancel-dead*=t): NS1a died with the first cancel, so the J2 is a clean hit (and the breakthrough).
;;;; Run: tools/simgate/trial.lisp with this file (xch/r3-trial-{off,on}.txt). Several timings of P2's SP against P1's J1.
(:name "R3 P2 SP at 10, J1 at 4, J2 pressed 14 / 18 / 22, 1.6 m" :p1 :ichigo :p2 :kenpachi :p2-form :nozarashi :dist 1.6 :p2-at ((10 :sp)) :p1-at ((4 :j) (14 :j) (18 :j) (22 :j)) :script () :frames 90 :log-simf t)
(:name "R3 P2 SP at 14, J1 at 4, J2 pressed 14 / 18 / 22, 1.6 m" :p1 :ichigo :p2 :kenpachi :p2-form :nozarashi :dist 1.6 :p2-at ((14 :sp)) :p1-at ((4 :j) (14 :j) (18 :j) (22 :j)) :script () :frames 90 :log-simf t)
(:name "R3 P2 SP at 8, J1 at 4, J2 pressed 14 / 18 / 22, 1.6 m" :p1 :ichigo :p2 :kenpachi :p2-form :nozarashi :dist 1.6 :p2-at ((8 :sp)) :p1-at ((4 :j) (14 :j) (18 :j) (22 :j)) :script () :frames 90 :log-simf t)
(:name "R3 P2 SP at 0, J1 at 4, J2 pressed 16, 1.6 m (the farm's shape: NS1a's own hit cancels, J1 re-cancels when R3 is off)" :p1 :ichigo :p2 :kenpachi :p2-form :nozarashi :dist 1.6 :p2-at ((0 :sp)) :p1-at ((4 :j) (16 :j)) :script () :frames 90)
