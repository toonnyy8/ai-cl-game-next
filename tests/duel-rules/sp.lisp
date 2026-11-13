(in-package :duel)
;;; ================================================================ SP spending (duel/lisp/sp.lisp, docs/duel/DUEL_SP.md, batch S0)
;; knobs
(check (and (~= *fs-cell* 100.0) (~= *sp-cost-rate* 0.4) (~= *sp-cost-min* 10.0) (~= *sp-cost-max* 60.0)
            (~= *sp-gain-j* 10.0) (~= *sp-gain-sa* 15.0) (~= *sp-gain-cancel* 30.0) (~= *sp-break-share* 1.0) (~= *sp-break-gain* 0.5)))
;; sp-cost: damage x 0.4 x mult, rounded to 5, clamped 10 .. 60; an override wins
(check (~= (sp-cost 100) 40.0))
(check (~= (sp-cost 110) 45.0))                                    ; 44 -> 45
(check (~= (sp-cost 105) 40.0))                                    ; 42 -> 40
(check (~= (sp-cost 0) 10.0))                                      ; a setup segment: the minimum
(check (~= (sp-cost 10) 10.0))                                     ; 4 -> clamped up
(check (~= (sp-cost 150) 60.0))                                    ; 60 exactly
(check (~= (sp-cost 300) 60.0))                                    ; 120 -> clamped down
(check (~= (sp-cost 100 0.76) 30.0))                               ; 30.4 -> 30
(check (~= (sp-cost 100 0.51) 20.0))                               ; 20.4 -> 20
(check (~= (sp-cost 100 1.0 25.0) 25.0))                           ; an override is taken as it is
(check (~= (sp-cost 500 0.1 5.0) 5.0))                             ; ... also under the minimum
;; sp-start-p: AS always; NS when first, fs > 0 or bursting
(check (and (sp-start-p :as nil 0.0 nil) (sp-start-p :as nil 0.0 t) (sp-start-p :as t 50.0 nil)))
(check (sp-start-p :ns t 0.0 nil))                                 ; NSa at 0
(check (not (sp-start-p :ns nil 0.0 nil)))                         ; a later NS at 0: refused
(check (sp-start-p :ns nil 0.5 nil))                               ; any gauge above 0 starts
(check (sp-start-p :ns nil 0.0 t))                                 ; a burst: free
;; sp-pay
(check (multiple-value-bind (fs paid) (sp-pay 300.0 40.0 nil) (and (~= fs 260.0) (~= paid 40.0))))
(check (multiple-value-bind (fs paid) (sp-pay 30.0 40.0 nil) (and (~= fs 0.0) (~= paid 30.0))))   ; short: pays what is left
(check (multiple-value-bind (fs paid) (sp-pay 0.0 40.0 nil) (and (~= fs 0.0) (~= paid 0.0))))
(check (multiple-value-bind (fs paid) (sp-pay 120.0 40.0 t) (and (~= fs 120.0) (~= paid 0.0))))   ; a burst pays nothing
;; sp-scale: 0.5 + 0.5 paid / cost
(check (~= (sp-scale 40.0 40.0) 1.0))
(check (~= (sp-scale 0.0 40.0) 0.5))
(check (~= (sp-scale 30.0 60.0) 0.75))
(check (~= (sp-scale 0.0 0.0) 1.0))                                ; cost 0 (free in a burst): full damage
(check (~= (sp-scale 99.0 40.0) 1.0))                              ; never above 1
;; sp-refund: capped at the gauge maximum
(check (~= (sp-refund 100.0 40.0) 140.0))
(check (~= (sp-refund 290.0 40.0) *fs-max*))
(check (~= (sp-refund 300.0 0.0) 300.0))
;; sp-atk-gain
(check (and (~= (sp-atk-gain :na nil) 10.0) (~= (sp-atk-gain :sa nil) 15.0)))
(check (and (~= (sp-atk-gain :na t) 30.0) (~= (sp-atk-gain :sa t) 30.0)))
(check (and (zerop (sp-atk-gain :ns nil)) (zerop (sp-atk-gain :as nil)) (zerop (sp-atk-gain :ns t)) (zerop (sp-atk-gain :as t))
            (zerop (sp-atk-gain nil nil)) (zerop (sp-atk-gain :kikon nil))))
;; sp-break-take: everything above the last cell, the attacker gains half of it (the user 2026-11-13: 「這邊是要奪取第一格以上的全部，並以 50% 效率轉換成自身量表」)
(check (multiple-value-bind (take gain) (sp-break-take 300.0) (and (~= take 200.0) (~= gain 100.0))))
(check (multiple-value-bind (take gain) (sp-break-take 140.0) (and (~= take 40.0) (~= gain 20.0))))
(check (multiple-value-bind (take gain) (sp-break-take 100.0) (and (zerop take) (zerop gain))))  ; the last cell is never taken
(check (multiple-value-bind (take gain) (sp-break-take 40.0) (and (zerop take) (zerop gain))))
(check (multiple-value-bind (take gain) (sp-break-take 0.0) (and (zerop take) (zerop gain))))
;; sp-exchange-open-p: the same live id on both
(check (sp-exchange-open-p 120 120))
(check (not (sp-exchange-open-p 120 121)))
(check (not (sp-exchange-open-p -1 -1)))                           ; no exchange
(check (sp-exchange-open-p 0 0))                                   ; tick 0 is a tick
;; sp-neutral-p (Q11): no move, no reaction, not standing in a clash's push
(check (every (lambda (s) (sp-neutral-p s nil)) '(:idle :guard :step :run :hoho)))
(check (notany (lambda (s) (sp-neutral-p s nil)) '(:move :stun :guard-hit :air :down :wakeup)))
(check (not (sp-neutral-p :idle t)))                               ; a tie's / a Kikon cancel's bounce: still in the exchange
(check (sp-neutral-p :step t))                                     ; (a Step's own slide is movement, not the push)
;; sp-switch-ok-p: not switched, a second route, the awakening gauge was full, fs > 0
(check (sp-switch-ok-p 50.0 t nil 2))
(check (not (sp-switch-ok-p 0.0 t nil 2)))                         ; refused at 0
(check (not (sp-switch-ok-p 50.0 nil nil 2)))                      ; the gauge never was full
(check (not (sp-switch-ok-p 50.0 t t 2)))                          ; already switched
(check (not (sp-switch-ok-p 50.0 t nil 1)))                        ; one route only

;; hit-px (rules.lisp, the APPLY-HIT damage seam, REFACTOR_2026-11 §11.5.4): the old inline product bit for bit, SP-SCALE one more factor
(check (loop for (c s h) in '((1f0 0f0 1.0) (1.3f0 0.5f0 1.0) (1f0 1f0 0.8) (1.25f0 0.35f0 1.15) (2f0 0.1f0 0.6d0))
             always (let ((old (let ((px (* c (+ 1.0 (* *sub-dmg* s))))) (if (= h 1.0) px (* px h)))))
                      (and (eql (hit-px c s h) old) (eql (hit-px c s h 1.0) old)))))
(check (~= (hit-px 1f0 0f0 1.0 0.5) 0.5))
(check (~= (hit-px 1.3f0 0f0 1.0 (sp-scale 30.0 60.0)) (* 1.3 0.75)))

;; ---------------------------------------------------------------- DUEL_SP §4's table, from the kits' real move data
;; The kits' own SP cost tables (kit.lisp BUILD-SP-COSTS, batch S2): a segment's damage is the sum of its hit windows, else a wave's
;; :params :dmg (its Kikon strike is free), else 0 (a setup segment); a route's cost is the sum of its segments' costs (each rounded once,
;; after the kit's :core :sp-cost-mult). Every row lists every pointer the kit has: the table's columns and, past them, Kenpachi's
;; Shikai AS5-AS7 (DAISHARIN, INSEKI-GIRI, the Bankai burst) and his two Bankai's AS5 (CHIGIRI, TATE-GOTO), priced by the same rule.
(defun sp-route-cost (kit first)
  (reduce #'+ (mapcar (lambda (n) (kit-sp-cost kit (kit-move kit n))) (core-segments first))))
(defun sp-kit-costs (character form)
  "((:ns c1 c2 ..) (:as c1 c2 ..)): the route costs of a kit's :core grammar, in order."
  (let* ((k (kit character form)) (core (kit-core k)))
    (list (cons :ns (mapcar (lambda (n) (sp-route-cost k n)) (getf core :ns)))
          (cons :as (mapcar (lambda (n) (sp-route-cost k n)) (getf core :as))))))
;; (character form :sp-cost-mult NS... | AS...: §4's cells, then the extra AS pointers)
(defparameter *sp-table*
  '((:kenpachi :base 0.76 (55 55 60) (25 50 75))
    (:kenpachi :nozarashi 0.68 (100 120) (85 110 25 25 60 60 25))
    (:kenpachi :bankai 0.71 (90) (30 55 75 95 60))
    (:kenpachi :bankai-2 0.51 (85) (30 50 70 90 60))
    (:ichigo :base 1.0 (85 80 70) (20 45 90))
    (:ichigo :kessa 1.0 (75 80 30) (20 45 80))
    (:hisagi :base 1.0 (75 75 25) (25 45 80))
    (:hisagi :bankai 1.0 (40 80) (15 55 35))
    (:hisagi :bankai-bind 1.0 (65 80) (20 50 70))))
(let ((mism 0))
  (dolist (row *sp-table*)
    (destructuring-bind (c f mult ns as) row
      (let* ((got (sp-kit-costs c f))
             (gns (cdr (assoc :ns got))) (gas (cdr (assoc :as got))))
        (check (~= (getf (kit-core (kit c f)) :sp-cost-mult 1.0) mult))   ; the kit's multiplier is the doc's
        (loop for role in '(:ns :as) for want in (list ns as) for have in (list gns gas)
              do (check (= (length want) (length have)))                  ; every pointer the kit has is pinned
                 (loop for w in want for h in have for i from 1
                       do (if (= w h)
                              (check t)
                              (progn (incf mism)
                                     (format t "SP-TABLE MISMATCH ~s ~s ~a~d: doc ~d, data ~d~%" c f role i w h)
                                     (check nil))))))))
  (format t "sp cost table: ~d mismatches against DUEL_SP §4~%" mism))
;; every NS / AS classed move of every core kit has a cost, but a wave's Kikon strike (free, as the Kikon hold is); nothing else has one
(check (loop for row in *sp-table*
             always (let* ((k (kit (first row) (second row)))
                           (strikes (loop for mv being the hash-keys of (kit-cls k)
                                          for s = (getf (mv-params mv) :kikon-strike) when s collect s)))
                      (loop for mv being the hash-keys of (kit-cls k) using (hash-value cls)
                            always (if (and (member cls '(:ns :as)) (not (member (mv-name mv) strikes)))
                                       (typep (kit-sp-cost k mv) 'single-float)
                                       (null (kit-sp-cost k mv)))))))
(check (null (kit-sp-cost (kit :ichigo :base) (kit-move (kit :ichigo :base) (getf (kit-core (kit :ichigo :base)) :sa)))))   ; an SA: free
;; kit-sp-start-p (kit.lisp, S7): the one test CORE-START! refuses by and the CPU reads before it presses (core-ai CAI-NEXT-OK-P),
;; through the kits' own moves: NSa at 0 (also a switch's target NS1), a later NS at 0 refused, above 0 or in a burst started, Kenpachi's
;; tame -> thrust catch (KE-Z-N3B: an NS segment) refused at 0, an AS and a costless move (J1, the SA) always
(let* ((ic (kit :ichigo :base)) (ke (kit :kenpachi :base))
       (n1a (kit-move ic :ic-n1a)) (n1b (kit-move ic :ic-n1b)) (n2a (kit-core-move ic :ns 2)))
  (check (kit-sp-start-p ic n1a 0.0 nil))                           ; NSa from neutral at 0
  (check (kit-sp-start-p ic n2a 0.0 nil))                           ; the pointer switch's target NS1: first, so the helper passes it
                                                                    ;  (the switch's own gate SP-SWITCH-OK-P refuses at 0 before)
  (check (not (kit-sp-start-p ic n1b 0.0 nil)))                     ; NSb at 0 (a press, HOHO-RESUME!'s segment): refused
  (check (kit-sp-start-p ic n1b 0.5 nil))                           ; above 0: starts (scaled)
  (check (kit-sp-start-p ic n1b 0.0 :orange))                       ; in a burst: free
  (check (not (kit-sp-start-p ke (kit-move ke :ke-z-n3b) 0.0 nil))) ; the tame's catch at 0 (combat.lisp :parried): refused
  (check (kit-sp-start-p ke (kit-move ke :ke-z-n3b) 20.0 nil))
  (check (kit-sp-start-p ic (kit-core-move ic :as 3) 0.0 nil))      ; an AS: always
  (check (kit-sp-start-p ic (kit-move ic :ic-j1) 0.0 nil))          ; no cost: always
  (check (kit-sp-start-p ic (kit-sa-move ic) 0.0 nil)))
