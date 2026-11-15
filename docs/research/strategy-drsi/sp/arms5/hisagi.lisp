;;;; arms5/hisagi.lisp — PLAN4 checkpoint 2a (the user, 2026-11-15: 「全部採用」, 「改成修兵自己的打法」): Hisagi's arms from his kit study
;;;; (kits/hisagi/strategies.md), written inline (:fn, so no style unit is needed in strategy.lisp: nothing in the game names them). The
;;;; style hisagi-own-style (duel/lisp/cpu-hisagi-own.lisp) plays hisagi-hk-style with his own rules under the :hb-* keys (KNOBS.md §6.8).
;;;; Arm 0 is the first form. Every job arm = arm 0's keys + its job's keys. The record: arms5/hisagi.md.

;; all (arm 0, S1 the chain's band): the Shikai at 3.4-5.0 m (NAGI on his approach / whiff / charge, NS3a / the pointer's NS on whiffs,
;; the back Step inside 3.4, never an NS in its dead zone, okizeme +40, the opener), the generic clash off (:clash-p 0: he is never the NS
;; side; S2's J clash is its own arm), the Reishi pot (as h4-all); the Bankai as h4-all (:ken-ranged)
(:id :h5-all :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0))

;; S2 J-side cancels: J1 into his NS / AS start (:hb-jclash), the AS on every cancel (:xch-j 0: TSUMUJI)
(:id :h5-cancel :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hb-jclash 1.0 :xch-j 0.0))

;; S3 the chain tip (h4-range sharpened): the ranged mode without Kenpachi's code (no :ken-ranged), h4-range's data and close rule, and
;; TABA from neutral at its tip (4.0-4.9 m, :hr-taba-n)
(:id :h5-tip :fn hisagi-own-style :apply (:hisagi) :dswitch-map ((:base 1 3))
 :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hr-taba-n 1.0 :hr-taba-lo 4.0 :hr-taba-hi 4.9
        :dswitch 1.0 :range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0 :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3
        :b-walk-in -0.08 :b-step-in -0.05 :hr-near 4.5 :hr-home-p 1.0)
 :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0)) (((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05))
         (((:dn :out)) (:b-sp 0.15)) (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06))
         (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1)) (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))))

;; S4 bind to catch up: behind by 300 Reishi the ranged strings run to J5 > AS3 (the bind), the bind seeks cancels; ahead never AS3
(:id :h5-bind :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hb-bind 1.0))

;; S5 wake (kept): h4-wake's rule and keys over arm 0
(:id :h5-wake :fn hisagi-own-style :ken-ranged t :apply (:hisagi)
 :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hk-wake 1.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-reach-margin 1.0
        :kk-ns-safe-p 0.25))

;; K1 (vs Kenpachi; K2 is arm 0's sealed play): against his released forms the band at 5.8-6.4 m (beyond the Shikai lunge's 5.7) and no
;; NS of his own inside 5.8; S2's J1 into the lunge and the AS on the cancel
(:id :h5-k1 :fn hisagi-own-style :ken-ranged t :apply (:hisagi)
 :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hb-jclash 1.0 :xch-j 0.0 :hb-olo 5.8 :hb-ohi 6.4 :hb-ons-min 5.8))

;; I1 (vs Ichigo): her NS3a rush answered by NS2a / J1 (then the AS: :xch-j 0), never NAGI; her Getsuga charge by NAGI in its first 20 f,
;; else a Hoho into the wave
(:id :h5-i1 :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0 :hb-ich 1.0 :xch-j 0.0))

;; ihx (vs Ichigo, kept): cells-h/final/h4-ihx.lisp verbatim but the id (its own style: its Shikai is the MCTS / generic CPU's)
(:id :h5-ihx :dswitch-map ((:base 1 3)) :fn hisagi-ihr1b2a0-style :apply (:hisagi)
 :base (:dswitch 1.0 :awaken 3.0 :hoho 0.3 :range 1.75 :ns 0.9 :cont 2.0 :turn 2.0 :ihx-p 1.0 :ihx-margin 0.1 :ihx-chase 0.0 :ihx-reishi 0.5
        :hold-awaken 0.3)
 :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0))))
