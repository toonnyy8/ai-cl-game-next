;;;; arms4/hisagi.lisp — PLAN4 §3 (B3): Hisagi's five general arms as unit forms (the *STRAT-UNITS* form: :style + :data + own keys), not in
;;;; any table or in strategy.lisp's library yet. The record: arms4/hisagi.md. Raw (expanded) files for STRAT_P<n> / eval.py: arms4/expand.lisp
;;;; writes arms4/hisagi/<id>.lisp. Keys: KNOBS.md §6.1 (:kk-*, Kenpachi's KI code that the hk / merged styles play outside the close rule),
;;;; §6.6 (:hr-* the ranged mode's distance rule, :hkk-* the kite), §1 (the shared outputs and :dswitch).

;; all (arm 0): the HK style with the Reishi pot (PLAN4 §3's literal "hk + the pot" = :a-hk-pot)
(:id :h4-all :style :st-hisagi-hk :data (:d-hk-pot))

;; wake: the wake-up punish / guard alone (G2 down)
(:id :h4-wake :style :st-hisagi-hk :data (:d-hk-wake))

;; kite: the kite rule + the kite data (G2 attacking x close, G0 ahead); :d-kite's :b-* are near inert here (ken-ki-style takes the free
;; steps, KNOBS §0), its job is the kite rule's
(:id :h4-kite :style :st-hisagi-hk :data (:d-hk-kite :d-kite))

;; press: the brawler data + the Hoho in (x-kh-h-r1-b3a2's 6 m Hoho in), no back Step from her starts, and in the ranged mode the close rule
;; off (:hr-p 0: the close events go to Kenpachi's KI code, :ken-ranged) (G7 his Reishi low, G0 his red)
(:id :h4-press :style :st-hisagi-hk :data (:d-brawler)
 :base (:hr-p 0.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-step-p 0.0))

;; range: the ranged mode's distance rule alone (:st-hisagi-range: no KI code at range, so the MCTS / generic CPU decide there under the kite
;; data's outputs), the close rule stretched (the event from 4.5 m, the pointer home every string) and the DRIVE switch with no NS out of
;; reach (h1-range's data) (G1 form 1 x mid / far, G9). A second style function: the table needs :keep-state t.
(:id :h4-range :style :st-hisagi-range :data (:d-dswitch :d-no-far-ns :d-kite)
 :base (:hr-near 4.5 :hr-home-p 1.0))
