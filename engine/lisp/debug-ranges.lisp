;;;; debug-ranges.lisp — the registry of a game's debug command ranges (Module._debug_cmd(n), app.lisp's :debug): each module
;;;; claims LO..HI with DEFINE-DEBUG-RANGE next to its handler, and DEBUG-DISPATCH hands a command to the narrowest claimed
;;;; range holding it. Ranges nest (a specific range inside a generic one wins: 2209 inside 2200-2299, whatever the load
;;;; order) but never overlap in part, and a span is claimed once: either is an error at load. Plain CL (host-tested:
;;;; tests/duel-rules-test.lisp loads it before the character files). REFACTOR_2026-11 R11 (D7), 2026-11-13.
(in-package :engine)

(defvar *debug-ranges* nil "(lo hi name fn) per claimed range (DEFINE-DEBUG-RANGE; NAME the handler's symbol, NIL inline), the newest first.")

(defun debug-ranges-add (ranges lo hi name fn)
  "RANGES with LO..HI claimed for FN (a function of the command). NAME: the handler's symbol, or NIL for an inline body; the
same span claimed again under the same NAME replaces it (a file loaded twice: the host tests). Pure: a new list. An error
when the span is claimed already or overlaps a claimed range in part (one inside the other is fine: the narrower one wins)."
  (check-type lo integer) (check-type hi integer)
  (assert (<= lo hi) () "debug range ~a: ~d > ~d" name lo hi)
  (setf ranges (remove-if (lambda (r) (and name (eq name (third r)) (= lo (first r)) (= hi (second r)))) ranges))
  (dolist (r ranges (cons (list lo hi name fn) ranges))
    (let ((a (first r)) (b (second r)))
      (unless (or (< hi a) (< b lo)                                          ; apart
                  (and (not (and (= a lo) (= b hi)))                         ; or nested, not the same span
                       (or (and (<= a lo) (<= hi b)) (and (<= lo a) (<= b hi)))))
        (error "debug range ~d-~d (~a) overlaps ~d-~d (~a): claim another span (DUEL_GAMEPLAY \"Debug commands\")"
               lo hi (or name "inline") a b (or (third r) "inline"))))))

(defun debug-range-find (c &optional (ranges *debug-ranges*))
  "The narrowest claimed range (lo hi name fn) holding command C, or NIL."
  (let ((best nil))
    (dolist (r ranges best)
      (when (and (<= (first r) c (second r))
                 (or (null best) (< (- (second r) (first r)) (- (second best) (first best)))))
        (setf best r)))))

(defun debug-dispatch (c)
  "Hand debug command C to its range's handler: T, or NIL when no range claims it (a silent no-op)."
  (let ((r (debug-range-find c)))
    (when r (funcall (fourth r) c) t)))

(defmacro define-debug-range ((lo hi) handler &body body)
  "Claim debug commands LO..HI (at load; an overlap fails there). HANDLER is a function name that gets the command, or a
lambda list (C) whose BODY runs with C bound to it."
  (if (and (symbolp handler) (null body))
      `(setf *debug-ranges* (debug-ranges-add *debug-ranges* ,lo ,hi ',handler ',handler))
      `(setf *debug-ranges* (debug-ranges-add *debug-ranges* ,lo ,hi nil
                                              (lambda ,handler (declare (ignorable ,@handler)) ,@body)))))
