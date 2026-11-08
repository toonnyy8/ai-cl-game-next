;; s3-zoner: spacing with the ranged / long NS. Walks to a wide range (x1.5 = 2.55-4.5 m), NS share high (0.9), backs off when he is
;; inside his J1 reach, steps out when inside my J1 reach, and uses the NS (b-sp) whenever he is at my NS's reach; a ranged kit (:wave)
;; shoots from afar. Kikon only when he is red (kikon x0.4 base, x1.6 vs red). Borrows: Ichigo's spacing (no exchange at 1.7-3.6 m, NS3a
;; at 4-5 m, Getsuga from 7.5 m+) and Kenpachi's NS1a from beyond J reach.
(:id :s3-zoner
 :base (:range 1.5 :ns 0.9 :hoho 1.1 :kikon 0.4 :cont 0.8
        :b-walk-out 0.02 :b-wait 0.02 :b-j1 -0.08 :b-walk-in -0.04)
 :rules
 ((((:dn :reach)) (:b-sp 0.15 :b-walk-in -0.05))
  (((:dn :out)) (:b-sp 0.1 :b-walk-in 0.04))
  (((:dn :afar) (:wave :yes)) (:b-sp 0.18 :b-walk-in -0.04))
  (((:do :in)) (:b-walk-out 0.12 :b-step-out 0.1 :b-j1 -0.05))
  (((:dj :in)) (:b-step-out 0.08 :b-j1 0.05))
  (((:ored :yes)) (:kikon 1.6))))
