;; anchor-hh.lisp — DUCT's anchor for hisagi vs hisagi (PLAN4 §6; STRAT_ANCHOR, tools/simgate/strat-run.lisp). PROVISIONAL: not frozen
;; (sp/duct/README-provisional.md). Written by sp/duct.py anchor. Library: each side's admitted arms (arms4/*.md), the pairing's exchange
;; unit laid under each (STRAT-WITH; sp/duct/arms/). Payoff: hisagi's game-result share, each arm pair played whole, seeds
;; 201-300, both seats, 200 matches a cell (sp/duct/matrix-hh.json), and its zero-sum equilibrium mixes x / y.
;; Sim build b835ac41b83b.
(:library
 ((:id :dc-hh-h-all :apply (:hisagi :hisagi) :fn hisagi-hk-style :ken-ranged t :base (:hk-pot 1.0))
  (:id :dc-hh-h-range :apply (:hisagi :hisagi) :fn hisagi-range-style :dswitch-map ((:base 1 3)) :base (:dswitch 1.0 :range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0 :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05 :hr-near 4.5 :hr-home-p 1.0) :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0)) (((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05)) (((:dn :out)) (:b-sp 0.15)) (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06)) (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1)) (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))))
  (:id :dc-hh-h-wake :apply (:hisagi :hisagi) :fn hisagi-hk-style :ken-ranged t :base (:hk-wake 1.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-reach-margin 1.0 :kk-ns-safe-p 0.25)))
 :payoff
 ((:hisagi :hisagi (:dc-hh-h-all :dc-hh-h-range :dc-hh-h-wake) (:dc-hh-h-all :dc-hh-h-range :dc-hh-h-wake)
   ((0.5000 0.9850 0.6700) (0.0150 0.5000 0.0800) (0.3300 0.9200 0.5000))
   (1.0000 0.0000 0.0000) (1.0000 0.0000 0.0000))))
