;; s4-discipline: reach discipline + wake-up pressure + lead management. Never starts a move that cannot reach (J1 biased down beyond
;; my J1 reach, NS beyond my NS reach), walks in instead; Hoho only through what it cannot beat (his active move at my reach); presses
;; his knockdown; when ahead on Konpaku (lead) it plays safe (waits, backs off, Hoho), when behind it raises pressure and awakens.
;; Borrows: Kenpachi's reach discipline (cell b0_a0: start only a move that reaches), the meaty on wake-up, the Hoho dodge; Ichigo's
;; Konpaku-aware play. Differs from s1 (pressure at all times) and s3 (long range) by being state-switched on reach and lead.
(:id :s4-discipline
 :base (:range 1.0 :ns 0.55 :hoho 1.3 :turn 1.2 :cont 1.1 :awaken 1.5)
 :rules
 ((((:dj :out)) (:b-j1 -0.18 :b-walk-in 0.1 :b-step-in 0.04))
  (((:dj :afar)) (:b-j1 -0.22 :b-walk-in 0.12))
  (((:dn :out)) (:b-sp -0.15))
  (((:dn :afar)) (:b-sp -0.2))
  (((:dj :reach)) (:b-j1 0.1))
  (((:dn :reach)) (:b-sp 0.08))
  (((:ost :down)) (:b-walk-in 0.12 :b-j1 0.12 :b-wait -0.1))
  (((:ost :active) (:do :reach)) (:b-hoho 0.15 :b-step-out 0.08))
  (((:lead :ahead)) (:b-wait 0.06 :b-walk-out 0.04 :b-j1 -0.04 :awaken 0.5))
  (((:lead :behind)) (:b-walk-in 0.06 :b-j1 0.04 :awaken 3.0 :range 0.85))))
