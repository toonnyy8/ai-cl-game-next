(:id :kite
 :own (((:lead :even)) ((:lead :ahead)) ((:lead :behind)))
 :base (:range 2.6 :ns 1.0 :hoho 1.4 :kikon 0.4 :cont 0.7 :turn 1.2
        :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05)
 :rules
 ((((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05))
  (((:dn :out)) (:b-sp 0.15))
  (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06))
  (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1))
  (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))
  (((:ost :startup) (:do :reach)) (:b-hoho 0.15))
  (((:ored :yes)) (:kikon 1.6))))
