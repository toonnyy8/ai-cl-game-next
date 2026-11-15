;; anchor-kk.lisp — DUCT's anchor for kenpachi vs kenpachi (PLAN4 §6; STRAT_ANCHOR, tools/simgate/strat-run.lisp). PROVISIONAL: not frozen
;; (sp/duct/README-provisional.md). Written by sp/duct.py anchor. Library: each side's admitted arms (arms4/*.md), the pairing's exchange
;; unit laid under each (STRAT-WITH; sp/duct/arms/). Payoff: kenpachi's game-result share, each arm pair played whole, seeds
;; 201-300, both seats, 200 matches a cell (sp/duct/matrix-kk.json), and its zero-sum equilibrium mixes x / y.
;; Sim build b835ac41b83b.
(:library
 ((:id :dc-kk-k-all :apply (:kenpachi :kenpachi) :fn ken-kh-standoff-style :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))
  (:id :dc-kk-k-spend :apply (:kenpachi :kenpachi) :fn ken-kh-standoff-style :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 3.0 :kk-kikon-red-p 0.0 :kk-kikon-ptr-p 0.0))
  (:id :dc-kk-k-climb :apply (:kenpachi :kenpachi) :fn ken-kh-standoff-style :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-climb-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 1.0 :kk-bk-ns-p 0.25 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3)))
 :payoff
 ((:kenpachi :kenpachi (:dc-kk-k-all :dc-kk-k-spend :dc-kk-k-climb) (:dc-kk-k-all :dc-kk-k-spend :dc-kk-k-climb)
   ((0.5000 1.0000 0.5100) (0.0000 0.5000 0.0450) (0.4900 0.9550 0.5000))
   (1.0000 0.0000 0.0000) (1.0000 0.0000 0.0000))))
