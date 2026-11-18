;;;; R4's scripted check (xch2.md §R4): P2 Kenpachi in his Shikai starts his AS1 (a written drive, :p2-start); P1 Hisagi in his Bankai's
;;;; ranged mode presses J into it (a cancel), then his next link; P2 presses J right after the cancel. R4 off: no SA out of an AS segment (the
;;;; press does nothing; his route's next segment or recovery). R4 on (STRAT_SET *core-as-sa-out*=t): the SA starts at once and absorbs the
;;;; next link. Several timings. Run: tools/simgate/trial.lisp with this file (xch/r4-trial-{off,on}.txt).
(:name "R4 AS1 at 0, Hisagi J at 2 / 18, Kenpachi J at 18, 1.0 m" :p1 :hisagi :form :bankai :p2 :kenpachi :p2-form :nozarashi :dist 1.0 :p2-start ((0 :ke-s-as1)) :p1-at ((2 :j) (18 :j) (24 :j)) :p2-at ((18 :j)) :script () :frames 100)
(:name "R4 AS1 at 0, Hisagi J at 4 / 20, Kenpachi J at 22, 1.0 m" :p1 :hisagi :form :bankai :p2 :kenpachi :p2-form :nozarashi :dist 1.0 :p2-start ((0 :ke-s-as1)) :p1-at ((4 :j) (20 :j) (26 :j)) :p2-at ((22 :j)) :script () :frames 100)
(:name "R4 AS1 at 0, Hisagi J at 0 / 16, Kenpachi J at 16, 1.6 m" :p1 :hisagi :form :bankai :p2 :kenpachi :p2-form :nozarashi :dist 1.6 :p2-start ((0 :ke-s-as1)) :p1-at ((0 :j) (16 :j) (22 :j)) :p2-at ((16 :j)) :script () :frames 100)
(:name "R4 AS1 at 0, Hisagi J at 2 / 18, Kenpachi J at 10 (latched before the cancel), 1.0 m" :p1 :hisagi :form :bankai :p2 :kenpachi :p2-form :nozarashi :dist 1.0 :p2-start ((0 :ke-s-as1)) :p1-at ((2 :j) (18 :j) (24 :j)) :p2-at ((10 :j)) :script () :frames 100)
