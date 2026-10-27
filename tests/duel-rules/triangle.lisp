;; ================================================================ the core triangle (duel/lisp/core.lisp, docs/duel/DUEL_CORE.md)
(in-package :duel)
(setf *core-on* t)
;; the note's table (判定表), attacker's view: row = the attacker's class, column = the defender's
(dolist (r '((:na :na :hit) (:na :ns :cancel) (:na :as :cancel) (:na :sa :absorb)
             (:ns :na :cancel) (:ns :ns :hit) (:ns :as :absorb) (:ns :sa :cancel)
             (:as :na :cancel) (:as :ns :hit)
             (:sa :na :hit) (:sa :ns :cancel)))
  (check (eq (core-verdict (first r) (second r)) (third r))))
(check (eq (core-verdict :na nil) :hit))                          ; a defender outside a classed move: a clean hit
(check (eq (core-verdict :na :na :simul t) :cancel))              ; the same frame: cancel
(check (eq (core-verdict :ns :ns :simul t) :cancel))
(check (eq (core-verdict :na :ns :simul t) :cancel))
;; AS against SA: the later start wins, the same frame cancels
(check (eq (core-verdict :as :sa :att-t 20 :def-t 10) :hit))
(check (eq (core-verdict :as :sa :att-t 10 :def-t 20) :absorb))
(check (eq (core-verdict :sa :as :att-t 10 :def-t 10) :cancel))
(check (eq (core-verdict :sa :as :att-t 30 :def-t 10) :hit))
;; the parallel-play scenarios of the note: NA-NA-NA against NS-NS-NS cancels every step; a swap to AS beats NS, to SA beats NA
(check (and (eq (core-verdict :na :ns) :cancel) (eq (core-verdict :ns :na) :cancel)))
(check (and (eq (core-verdict :as :ns) :hit) (eq (core-verdict :ns :as) :absorb)))       ; the attacker swaps to AS at step 2
(check (and (eq (core-verdict :sa :na) :hit) (eq (core-verdict :na :sa) :absorb)))       ; the SP side swaps to SA
(check (and (eq (core-verdict :as :sa :att-t 5 :def-t 4) :hit) (eq (core-verdict :sa :as :att-t 4 :def-t 5) :absorb)))
;; a gap insert: the attacker's AS against the defender's NA cancels, against his NS wins; SA the other way round
(check (and (eq (core-verdict :as :na) :cancel) (eq (core-verdict :as :ns) :hit)
            (eq (core-verdict :sa :na) :hit) (eq (core-verdict :sa :ns) :cancel)))
;; only a same-class tie bounces
(check (and (core-bounces-p :na :na) (core-bounces-p :ns :ns) (not (core-bounces-p :na :ns))))
;; presses
(check (eq (core-press-class :neutral :attack nil) :na))
(check (eq (core-press-class :neutral :sp nil) :ns))
(check (null (core-press-class :na :attack nil)))                 ; an attack link needs a hit
(check (eq (core-press-class :na :attack t) :na-cont))
(check (null (core-press-class :na :sp nil)))                     ; an AS needs the attack to hit
(check (eq (core-press-class :na :sp t) :as))
(check (eq (core-press-class :ns :sp nil) :ns-cont))              ; an NS continues hit or not
(check (eq (core-press-class :ns :attack nil) :sa))
(check (eq (core-press-class :sa :sp t) :as))
(check (null (core-press-class :sa :sp nil)))
(check (null (core-press-class :as :attack t)))                   ; AS ends the combo
(check (null (core-press-class :as :sp t)))
(check (eq (core-class-after :na-cont) :na))
;; the pointer
(check (equal (mapcar #'core-as-pointer '(0 1 2 3 4)) '(1 1 2 3 3)))
;; the Kikon / Soul Break profiles (base worth 2, 3, 4)
(check (equal (mapcar (lambda (b) (core-kikon-count b 1 nil)) '(2 3 4)) '(1 2 3)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 1 t)) '(2 3 4)) '(1 2 3)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 2 nil)) '(2 3 4)) '(2 3 4)))
(check (equal (mapcar (lambda (b) (core-kikon-count b 2 t)) '(2 3 4)) '(3 4 5)))             ; red == a Soul Break
(check (equal (mapcar (lambda (b) (core-kikon-count b 3 nil)) '(1 2 3 4)) '(1 1 2 3)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 1)) '(2 3 4)) '(3 4 5)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 2)) '(2 3 4)) '(3 4 5)))
(check (equal (mapcar (lambda (b) (core-soul-break-count b 3)) '(2 3 4)) '(5 5 5)))          ; the finisher style, capped at 5
(check (= (core-kikon-count 2 2 t) (core-soul-break-count 2 2)))                             ; pointer 2: red = zero
(check (and (core-kikon-cancel-p nil t) (not (core-kikon-cancel-p t t)) (not (core-kikon-cancel-p nil nil))))
