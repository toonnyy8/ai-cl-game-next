;;;; fuzzy.lisp — zero-order Sugeno fuzzy inference over trapezoid sets: the arithmetic of a fuzzy rule layer, with no
;;;; game in it (SOUL DUEL's CPU, duel/lisp/fuzzy.lisp, holds the sets, the rule bases and the difficulty scaling). Moved
;;;; verbatim from duel/lisp/fuzzy.lisp by refactor R13 (docs/engine/REFACTOR_2026-11.md E1). Plain CL, host-tested
;;;; (tests/duel-rules/fuzzy.lisp); only + - x / (nothing the native sim and wasm may round apart).
;;;;   (fz-sets! '((:near -1 0 1.6 2.4) ...))   name the trapezoids (A B C D): 0 below A and above D, 1 from B to C
;;;;   (fz-mu x :near)                          X's membership in a named set
;;;;   (fz-infer rules feats &optional default) a rule base's answer for a feature plist
;;;; A rule is (ANTECEDENTS OUTPUT [:MUST]): ANTECEDENTS a list of (FEATURE SET), all must hold (AND = min of the
;;;; memberships). The answer is the outputs averaged by the rules' strengths, DEFAULT when none fires; a :MUST rule that
;;;; holds at least half way answers alone (one decisive rule is not averaged away by weak ones).
(in-package :engine)

(defun fz-sets! (sets)
  "Resolve SETS, a list of (NAME A B C D), onto their names (no ASSOC per membership): FZ-MU reads them. A name set again is
replaced."
  (dolist (e sets) (setf (get (first e) 'fz-trap) (coerce (rest e) 'simple-vector))))

(defun fz-mu (x set)
  "X's membership in SET (a name given to FZ-SETS!)."
  (let* ((v (get set 'fz-trap)) (a (svref v 0)) (b (svref v 1)) (c (svref v 2)) (d (svref v 3)))
    (cond ((or (< x a) (> x d)) 0.0)
          ((< x b) (/ (- x a) (float (- b a))))
          ((<= x c) 1.0)
          (t (/ (- d x) (float (- d c)))))))

(defun fz-infer (rules feats &optional (default 0.0))
  "RULES' answer for the feature plist FEATS (a cue missing reads 0): a :MUST rule holding at least half way alone, else the outputs averaged
by the rules' strengths, DEFAULT if none fires."
  (let ((num 0.0) (den 0.0))
    (dolist (r rules (if (plusp den) (/ num den) default))
      (let ((w (loop for (f set) in (first r) minimize (fz-mu (plist-get feats f 0) set))))
        (when (and (eq (third r) :must) (>= w 0.5)) (return (second r)))
        (incf num (* w (second r))) (incf den w)))))
