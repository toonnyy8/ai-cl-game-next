;;;; arms4/hisagi.lisp — PLAN4 §3 (B3): Hisagi's five general arms as unit forms (the *STRAT-UNITS* form: :style + :data + own keys), not in
;;;; any table or in strategy.lisp's library yet. The record: arms4/hisagi.md. Raw (expanded) files for STRAT_P<n> / eval.py: arms4/expand.lisp
;;;; writes arms4/hisagi/<id>.lisp. Keys: KNOBS.md §6.1 (:kk-*, Kenpachi's KI code that the hk / merged styles play outside the close rule),
;;;; §6.6 (:hr-* the ranged mode's distance rule, :hkk-* the kite), §1 (the shared outputs and :dswitch).
;;;; After the B3 cells (hisagi.md §6): wake, hoho6 and ihx below are the cells' picks (they expand to cells-h/final/h4-*.lisp, checked); the
;;;; raw files in hisagi/ stay the drafts the cells were scored against (not re-expanded). press and kite keep their drafts here: the cells'
;;;; picks (cells-h/final/h4-press.lisp, h4-kite.lisp) failed their one-job proof.

;; all (arm 0): the HK style with the Reishi pot (PLAN4 §3's literal "hk + the pot" = :a-hk-pot)
(:id :h4-all :style :st-hisagi-hk :data (:d-hk-pot))

;; wake: the wake-up punish / guard (G2 down). B3 cells (ws-wake b0_a1, hisagi.md §6): + the 6 m Hoho in, reach margin 1.0 and the Hoho
;; safety at 0.25, which get him into range of the downed opponent (the draft, :d-hk-wake alone, failed its descriptor)
(:id :h4-wake :style :st-hisagi-hk :data (:d-hk-wake)
 :base (:kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-reach-margin 1.0 :kk-ns-safe-p 0.25))

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

;; targeted, vs Kenpachi (KH only): the 6 m Hoho in of x-kh-h-r1-b3a2 (PLAN4 §3) over the HK style with the pot, the reach margin 1.0 and the
;; lunge (its keys, no exchange keys: those come from :with d-x-kh-h) (G2 his free state x mid / far)
;; B3 cells (ws-hoho6 b0_a1, hisagi.md §6): the draft walked in instead of Hohoing (Steps + Hohos below arm 0's); the reach margin 3.5 (J1 /
;; NS only close), no lunge, Step in, the shared :hoho 1.5, the back Step to 7 m and the dodge make the Hoho in the move from range
(:id :h4-hoho6 :style :st-hisagi-hk
 :base (:hk-pot 1.0 :hoho 1.5 :kk-reach-margin 3.5 :kk-lunge-p 0.0 :kk-step-in-p 1.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0
        :kk-step-p 1.0 :kk-step-max 7.0 :kk-dodge-p 1.0))

;; targeted, vs Ichigo (IH only): hisagi-ihr1b2a0-style (press into her shut-Hoho window, gated on her Reishi: :ihx-reishi 0.5), the keys of
;; c-ih-h-r1-b0a2 (PLAN3 IH round 1) (G7 my Reishi high x hers low). A third style function: the IH table needs :keep-state t.
(:id :h4-ihx :style :st-hisagi-ihr1b2a0 :dswitch-map ((:base 1 3))
 ;; B3 cells (ws-ihx b0_a0): :ihx-chase 20 -> 0 (no walk-in during her window); the table score did not move beyond noise
 :base (:dswitch 1.0 :awaken 3.0 :hoho 0.3 :range 1.75 :ns 0.9 :cont 2.0 :turn 2.0 :ihx-p 1.0 :ihx-margin 0.1 :ihx-chase 0.0 :ihx-reishi 0.5
        :hold-awaken 0.3)
 :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0))))
