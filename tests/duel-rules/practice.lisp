(in-package :duel)
;;; ================================================================ PRACTICE's refill (practice.lisp PRACTICE-REFILL, REFACTOR_2026-11 R15c)
;; sim.lisp loaded practice.lisp (over components.lisp); the rows' Reishi rule PRACTICE-REISHI is control.lisp's
(load (merge-pathnames "../../duel/lisp/control.lisp" *load-truename*))

(defun pr-refill (o side g &optional (state :idle)) (multiple-value-list (practice-refill o side g state)))
(defun pr-g (&rest slots) (let ((g (make-gauges :reishi 500 :reishi-max 1300 :konpaku 3 :fs 40f0 :gg 20f0 :guardless t
                                                :awaken 10f0 :sub 5f0 :drive 7f0)))
                            (loop for (k v) on slots by #'cddr
                                  do (ecase k (:burst (setf (gauges-burst g) v)) (:awakened (setf (gauges-awakened g) v))))
                            g))
;; the defaults: the dummy's Konpaku at its row (9) and its Reishi full with HP REFILL AUTO; P1 untouched (GAUGES NORMAL, FLASH STEP KEEP)
(let ((o (make-practice-opts)))
  (check (equal (pr-refill o 1 (pr-g)) '(1300 9 nil nil nil nil nil)))
  (check (equal (pr-refill o 0 (pr-g)) '(nil nil nil nil nil nil nil)))
  (check (null (practice-fs-value o))))
;; HP REFILL waits out every hit / block reaction; the Konpaku row applies in each of them; OFF never refills
(let ((o (make-practice-opts)))
  (dolist (st '(:stun :air :down :wakeup :guard-hit))
    (check (equal (pr-refill o 1 (pr-g) st) '(nil 9 nil nil nil nil nil))))
  (check (equal (first (pr-refill o 1 (pr-g) :move)) 1300))
  (setf (po-refill o) nil)
  (check (equal (pr-refill o 1 (pr-g)) '(nil 9 nil nil nil nil nil))))
;; the rows: DUMMY HP 50 % of 1300, DUMMY KONPAKU 4; P1's rows are read for P1 only
(let ((o (make-practice-opts)))
  (setf (svref (po-rows o) 2) 50 (svref (po-rows o) 3) 4 (svref (po-rows o) 0) 25 (po-inf o) t)
  (check (equal (subseq (pr-refill o 1 (pr-g)) 0 2) '(650 4)))
  (check (equal (subseq (pr-refill o 0 (pr-g)) 0 2) '(325 nil))))
;; GAUGES INFINITE on P1: Reishi, guard (clears GUARDLESS), flash-step; not awakened: the awakening gauge and SUBLIMATION, awakened: DRIVE;
;; the knobs themselves come back (EQ: no float arithmetic); INFINITE never touches the dummy
(let ((o (make-practice-opts :inf t)))
  (destructuring-bind (r k gg fs aw sub dr) (pr-refill o 0 (pr-g))
    (check (and (= r 1300) (null k) (eq gg *gg-max*) (eq fs *fs-max*) (eq aw *awaken-max*) (eq sub *sub-max*) (null dr))))
  (destructuring-bind (r k gg fs aw sub dr) (pr-refill o 0 (pr-g :awakened t))
    (check (and (= r 1300) (null k) (eq gg *gg-max*) (eq fs *fs-max*) (null aw) (null sub) (eq dr *drive-max*))))
  (check (equal (pr-refill o 1 (pr-g)) '(1300 9 nil nil nil nil nil))))
;; a running burst keeps its flash-step (it burns down first), under INFINITE and under any FLASH STEP row
(let ((o (make-practice-opts :inf t :fs 1)))
  (check (null (fourth (pr-refill o 0 (pr-g :burst :blue)))))
  (check (null (fourth (pr-refill o 1 (pr-g :burst :white))))))
;; FLASH STEP not KEEP: both sides at FULL / ONE CELL / EMPTY, and it beats INFINITE's full flash-step
(loop for i from 1 to 3 for v in (list *fs-max* *fs-cell* 0f0)
      do (let ((o (make-practice-opts :fs i)))
           (check (= (practice-fs-value o) v))
           (check (= (fourth (pr-refill o 0 (pr-g))) v))
           (check (= (fourth (pr-refill o 1 (pr-g))) v))
           (setf (po-inf o) t)
           (check (= (fourth (pr-refill o 0 (pr-g))) v))))
;; the record outlives matches: one default instance, the pause rows' order and the levels' labels as the menu shows them
(check (and (equal (mapcar #'cdr *dummies*) '("STAND" "GUARD ALL" "GUARD AFTER HIT" "CPU"))
            (equal *practice-fs-levels* '("KEEP" "FULL" "ONE CELL" "EMPTY"))
            (equalp (po-rows (make-practice-opts)) (vector 100 *konpaku-max* 100 *konpaku-max*))))
