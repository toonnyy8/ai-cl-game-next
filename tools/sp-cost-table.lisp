;;;; sp-cost-table.lisp — DUEL_DESIGN's "SP costs per segment" tables, generated from the kits' own SP cost tables (kit.lisp
;;;; BUILD-SP-COSTS / KIT-SP-COST, DUEL_SP §4, batch S9). Host only, no build:
;;;;   $ECL_HOST --norc --load tools/sp-cost-table.lisp            rewrites the block between the two markers in docs/duel/DUEL_DESIGN.md
;;;;   $ECL_HOST --norc --load tools/sp-cost-table.lisp -- print   prints it instead
;;;; The values are pinned by the host test (tests/duel-rules/sp.lisp, *SP-TABLE*); rerun this after a cost or a damage changes.
(dolist (f '("package" "math" "hitvol" "input" "fuzzy" "layout" "debug-ranges"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :duel (:use :cl :engine))
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(dolist (f '("tuning" "rules" "core" "sp" "fuzzy" "strategy" "kit" "ken" "ichigo" "hisagi"))
  (load (merge-pathnames (format nil "../duel/lisp/~a.lisp" f) *load-truename*)))
(in-package :duel)
(setf *print-pretty* nil)

(defparameter *sct-forms*
  '((:kenpachi :base "Kenpachi base") (:kenpachi :nozarashi "Kenpachi Shikai (NOZARASHI)") (:kenpachi :bankai "Kenpachi Bankai")
    (:kenpachi :bankai-2 "Kenpachi Bankai-2") (:ichigo :base "Ichigo Shikai") (:ichigo :kessa "Ichigo KESSA")
    (:hisagi :base "Hisagi Shikai") (:hisagi :bankai "Hisagi Bankai, ranged") (:hisagi :bankai-bind "Hisagi Bankai, bind"))
  "(character form title): every live core form, in DUEL_SP §4's order.")
(defparameter *sct-begin* "<!-- sp-cost-table begin (generated: tools/sp-cost-table.lisp; do not edit by hand) -->")
(defparameter *sct-end* "<!-- sp-cost-table end -->")

(defun sct-num (x) (if (= x (round x)) (format nil "~d" (round x)) (format nil "~,1f" x)))

(defun sct-block ()
  "The Markdown: one table per form, a row per NS / AS pointer: its segments as name damage / cost, and the route's total."
  (with-output-to-string (o)
    (format o "~a~%" *sct-begin*)
    (dolist (row *sct-forms*)
      (destructuring-bind (c f title) row
        (let* ((k (find-kit c f)) (core (kit-core k)) (mult (getf core :sp-cost-mult 1.0)))
          (format o "~%**~a** (`(find-kit ~(~s ~s~))`, cost multiplier ~a)~%~%| Pointer | Segments: move damage / cost | Total |~%|---|---|---|~%"
                  title c f (format nil "~,2f" mult))
          (dolist (role '(:ns :as))
            (loop for first in (getf core role) for i from 1
                  do (let* ((segs (core-segments first))
                            (costs (mapcar (lambda (n) (kit-sp-cost k (kit-move k n))) segs)))
                       (format o "| ~a~d | ~{~a~^, ~} | ~a |~%" role i
                               (loop for n in segs for cst in costs
                                     collect (format nil "~a ~a / ~a" n (sct-num (mv-sp-damage (kit-move k n))) (sct-num cst)))
                               (sct-num (reduce #'+ costs)))))))))
    (format o "~%~a" *sct-end*)))

(defun sct-splice (path block)
  "PATH's text with the part from the begin marker to the end marker replaced by BLOCK (both markers must be there)."
  (let* ((text (with-open-file (s path :external-format :utf-8)
                 (let ((str (make-string (file-length s)))) (subseq str 0 (read-sequence str s)))))
         (a (search *sct-begin* text)) (b (search *sct-end* text)))
    (unless (and a b) (error "~a: the sp-cost-table markers are missing" path))
    (with-open-file (s path :direction :output :if-exists :supersede :external-format :utf-8)
      (write-string (subseq text 0 a) s) (write-string block s) (write-string (subseq text (+ b (length *sct-end*))) s))
    (format t "sp-cost-table: ~a rewritten (~d forms)~%" path (length *sct-forms*))))

(if (member "print" ext:*command-args* :test #'string=)
    (write-string (sct-block))
    (sct-splice (merge-pathnames "../docs/duel/DUEL_DESIGN.md" *load-truename*) (sct-block)))
(terpri)
(ext:quit 0)
