;; s2-punisher: whiff-punish and counter. Hovers just outside his J1 reach (range x1.2, walk-out when inside his reach), waits for his
;; move to commit (state class startup/active) and answers: Hoho more often (x1.8), the AS / SA read more often (turn x1.4), J1 or a
;; Step-in the moment his move is in its active / recovery frames while he is not close enough to have hit (:do out/afar = he whiffed).
;; Starts nothing itself in the neutral (waits, NS share low). Borrows: Ichigo's whiff punish and 2.3-2.7 m bait hover into the timed
;; Hoho; Kenpachi's "never start a move she can see in time" (patience). The exact punish distance/timing is NOT expressible (README).
(:id :s2-punisher
 :base (:range 1.2 :ns 0.3 :hoho 1.8 :turn 1.4 :cont 0.9 :kikon 0.8
        :b-wait 0.07 :b-j1 -0.05 :b-sp -0.05 :b-walk-in -0.03)
 :rules
 ((((:ost :active) (:do :out)) (:b-j1 0.2 :b-step-in 0.12 :b-sp 0.1 :b-wait -0.15))
  (((:ost :active) (:do :afar)) (:b-step-in 0.15 :b-sp 0.1 :b-wait -0.15))
  (((:ost :down)) (:b-walk-in 0.1 :b-j1 0.1 :b-wait -0.1))
  (((:do :in)) (:b-step-out 0.1 :b-walk-out 0.08 :b-hoho 0.08))
  (((:ost :startup) (:do :reach)) (:b-hoho 0.12 :b-step-out 0.05))))
