(in-package :duel)
;;; ================================================================ SP spending (duel/lisp/sp.lisp, docs/duel/DUEL_SP.md, batch S0)
;; knobs
(check (and (~= *fs-cell* 100.0) (~= *sp-cost-rate* 0.4) (~= *sp-cost-min* 10.0) (~= *sp-cost-max* 60.0)
            (~= *sp-gain-j* 10.0) (~= *sp-gain-sa* 15.0) (~= *sp-gain-cancel* 30.0) (~= *sp-break-share* 0.5) (~= *sp-break-gain* 0.5)))
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
;; sp-break-take: 50 % of what is above the last cell; the attacker gains half of it
(check (multiple-value-bind (take gain) (sp-break-take 300.0) (and (~= take 100.0) (~= gain 50.0))))
(check (multiple-value-bind (take gain) (sp-break-take 140.0) (and (~= take 20.0) (~= gain 10.0))))
(check (multiple-value-bind (take gain) (sp-break-take 100.0) (and (zerop take) (zerop gain))))  ; the last cell is never taken
(check (multiple-value-bind (take gain) (sp-break-take 40.0) (and (zerop take) (zerop gain))))
(check (multiple-value-bind (take gain) (sp-break-take 0.0) (and (zerop take) (zerop gain))))
;; sp-exchange-open-p: the same live id on both
(check (sp-exchange-open-p 120 120))
(check (not (sp-exchange-open-p 120 121)))
(check (not (sp-exchange-open-p -1 -1)))                           ; no exchange
(check (sp-exchange-open-p 0 0))                                   ; tick 0 is a tick
;; sp-switch-ok-p: not switched, a second route, the awakening gauge was full, fs > 0
(check (sp-switch-ok-p 50.0 t nil 2))
(check (not (sp-switch-ok-p 0.0 t nil 2)))                         ; refused at 0
(check (not (sp-switch-ok-p 50.0 nil nil 2)))                      ; the gauge never was full
(check (not (sp-switch-ok-p 50.0 t t 2)))                          ; already switched
(check (not (sp-switch-ok-p 50.0 t nil 1)))                        ; one route only

;; ---------------------------------------------------------------- DUEL_SP §4's table, from the kits' real move data
;; A segment's damage: the sum of its hit windows, else a wave's :params :dmg (its Kikon strike is free), else 0 (a setup segment).
;; A route's cost: the sum of its segments' costs (each rounded). Kenpachi's multipliers are the doc's (a :sp-cost-mult on his kits, S2).
(defun sp-seg-damage (mv)
  (let ((h (reduce #'+ (map 'list #'hw-dmg (mv-hits mv)))))
    (cond ((plusp h) h) ((getf (mv-params mv) :dmg)) (t 0))))
(defun sp-route-cost (kit first mult)
  (reduce #'+ (mapcar (lambda (n) (sp-cost (sp-seg-damage (kit-move kit n)) mult nil)) (core-segments first))))
(defun sp-kit-costs (character form mult)
  "((:ns c1 c2 ..) (:as c1 c2 ..)): the route costs of a kit's :core grammar, in order."
  (let* ((k (kit character form)) (core (kit-core k)))
    (list (cons :ns (mapcar (lambda (n) (sp-route-cost k n mult)) (getf core :ns)))
          (cons :as (mapcar (lambda (n) (sp-route-cost k n mult)) (getf core :as))))))
;; (character form mult NS... | AS... as §4 prints them; NIL = a dash)
(defparameter *sp-table*
  '((:kenpachi :base 0.76 (55 55 60) (25 50 75))
    (:kenpachi :nozarashi 0.68 (100 120) (85 110 25 25))
    (:kenpachi :bankai 0.71 (90) (30 55 75 95))
    (:kenpachi :bankai-2 0.51 (85) (30 50 70 90))
    (:ichigo :base 1.0 (85 80 70) (20 45 90))
    (:ichigo :kessa 1.0 (75 80 30) (20 45 80))
    (:hisagi :base 1.0 (75 75 25) (25 45 80))
    (:hisagi :bankai 1.0 (40 80) (15 55 35))
    (:hisagi :bankai-bind 1.0 (65 80) (20 50 70))))
(let ((mism 0))
  (dolist (row *sp-table*)
    (destructuring-bind (c f mult ns as) row
      (let* ((got (sp-kit-costs c f mult))
             (gns (cdr (assoc :ns got))) (gas (cdr (assoc :as got))))
        (loop for role in '(:ns :as) for want in (list ns as) for have in (list gns gas)
              do (loop for w in want for h in have for i from 1
                       do (if (= w h)
                              (check t)
                              (progn (incf mism)
                                     (format t "SP-TABLE MISMATCH ~s ~s ~a~d: doc ~d, data ~d~%" c f role i w h)
                                     (check nil))))
                 ;; the table lists the kit's pointers only: the row's width must not exceed the kit's
                 (check (<= (length want) (length have)))))))
  (format t "sp cost table: ~d mismatches against DUEL_SP §4~%" mism))
