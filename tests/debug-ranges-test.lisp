;;;; debug-ranges-test.lisp — checks the engine's debug range registry (engine/lisp/debug-ranges.lisp) on the host: nesting
;;;; allowed and the narrowest range wins whatever the order, a partial overlap or a span claimed twice refused, an unclaimed
;;;; command a no-op.   $ECL_HOST --norc --load tests/debug-ranges-test.lisp
(dolist (f '("package" "debug-ranges"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :debug-ranges-test (:use :cl :engine))
(in-package :debug-ranges-test)

(defvar *fails* 0)
(defvar *checks* 0)
(defmacro check (form)
  `(progn (incf *checks*) (unless ,form (incf *fails*) (format t "FAIL: ~s~%" ',form))))
(defun refused-p (ranges lo hi)
  (handler-case (progn (engine::debug-ranges-add ranges lo hi :new #'identity) nil) (error () t)))

(let* ((rs (engine::debug-ranges-add nil 2200 2299 :generic #'identity))
       (rs (engine::debug-ranges-add rs 2209 2209 :specific #'identity))   ; inside: fine
       (rs (engine::debug-ranges-add rs 2300 2399 :later #'identity))
       (rs2 (engine::debug-ranges-add (engine::debug-ranges-add nil 2209 2209 :specific #'identity) 2200 2299 :generic #'identity)))
  (check (eq :specific (third (debug-range-find 2209 rs))))              ; the narrowest wins ...
  (check (eq :specific (third (debug-range-find 2209 rs2))))             ; ... in either load order
  (check (eq :generic (third (debug-range-find 2210 rs))))
  (check (eq :generic (third (debug-range-find 2200 rs))))               ; (the ends belong to the range)
  (check (null (debug-range-find 2199 rs)))
  (check (refused-p rs 2250 2350))                                       ; a partial overlap
  (check (refused-p rs 2209 2209))                                       ; the same span twice
  (check (refused-p rs 2200 2299))
  (check (not (refused-p rs 2100 2199)))                                 ; touching is apart
  (check (not (refused-p rs 2000 2999)))                                 ; holding them all: fine
  (check (refused-p rs 2400 2300))                                       ; lo > hi
  (let ((again (engine::debug-ranges-add rs 2209 2209 :specific #'list)))   ; the same name and span again: replaced (a reload)
    (check (and (= 3 (length again)) (eq #'list (fourth (debug-range-find 2209 again))))))
  (check (handler-case (progn (engine::debug-ranges-add (engine::debug-ranges-add nil 5 5 nil #'identity) 5 5 nil #'identity) nil)
           (error () t))))                                               ; two inline bodies on one span: refused

(let ((*debug-ranges* nil) (seen nil))
  (define-debug-range (10 19) (c) (push c seen))
  (check (and (debug-dispatch 12) (equal seen '(12))))
  (check (null (debug-dispatch 20)))                                     ; no range: NIL, nothing runs
  (check (equal seen '(12))))

(format t "debug-ranges-test: ~d checks, ~a~%" *checks* (if (zerop *fails*) "ALL PASS" (format nil "~d FAILED" *fails*)))
(ext:quit (if (zerop *fails*) 0 1))
