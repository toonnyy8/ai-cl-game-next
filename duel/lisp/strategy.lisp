;;;; strategy.lisp — a CPU strategy as data (docs/duel/DUEL_AI_STRATEGY.md §2; the user, 2026-11-08: 「找出數種策略，在通過 fuzzy 與
;;;; Decoupled UCT 將這些策略結合在一起」). Plain CL over fuzzy.lisp, host-tested (tests/duel-rules/strategy.lisp).
;;;;
;;;; A strategy is a plist (:ID id :BASE (key value ...) :RULES ((((cue set) ...) (key value ...)) ...)): never code, so a search writes a data
;;;; file the evaluator loads into the shared build. Each output KEY is a zero-order Sugeno over the rules that name it (AND = min of the
;;;; cues' memberships, the values averaged by strength), its :BASE value when none fires, NIL when neither names it (the CPU's own value
;;;; then: no strategy changes nothing). The cues are relative to the kits (core-ai.lisp STRAT-FEATS), so a strategy runs for any character.
;;;; Outputs: :B-<action> a bias (value units) added to that macro action's estimate before the action layer ranks them; :RANGE the walk-to
;;;; range's scale; :NS the in-range NS share; :HOHO :TURN :CONT :KIKON :AWAKEN scales of the reactive layer's chances. + - x / only.
;;;; :FN (the user, 2026-11-08: 「策略可以包含程式」, DUEL_AI_STRATEGY §9): a function (e b f kit s d) -> T when it decided this step, run
;;;; first on every step the CPU is free to press (CORE-BRAIN-STEP), before the action layer: a strategy's own tactics (a matchup style CPU
;;;; is one: ken-ki-style, ichigo-ki-style).
(in-package :duel)

(defparameter *strat-bias-keys* #(:b-j1 :b-sp :b-hoho :b-step-in :b-step-out :b-step-side nil :b-wait :b-walk-in :b-walk-out)
  "Per macro action code (*MC-ACTIONS*' order; 6, the guard, has none): its bias key.")

(defun strat-value (strat key feats)
  "STRAT's output KEY for the cue plist FEATS: the rules naming KEY by strength, else its :BASE value, else NIL."
  (let ((num 0.0) (den 0.0))
    (dolist (r (getf strat :rules))
      (let ((v (getf (second r) key)))
        (when v
          (let ((w 1.0))
            (dolist (c (first r)) (setf w (min w (fz-mu (getf feats (first c) 0) (second c)))))
            (when (plusp w) (incf num (* w v)) (incf den w))))))
    (if (plusp den) (/ num den) (getf (getf strat :base) key))))

(defvar *strat-now* nil "While a core CPU with a strategy steps: (strategy . its cue plist this step) (CORE-BRAIN-STEP), else NIL.")

(defun strat-out (key default)
  "The active strategy's KEY now, or DEFAULT (no strategy, or it leaves KEY alone)."
  (or (and *strat-now* (strat-value (car *strat-now*) key (cdr *strat-now*))) default))

(defun strat-scale (key p)
  "Chance P times the active strategy's scale KEY (none: P), kept within 0-1."
  (let ((k (and *strat-now* (strat-value (car *strat-now*) key (cdr *strat-now*)))))
    (if k (max 0.0 (min 1.0 (* p k))) p)))

(defun strat-fingerprint (strat keys grid)
  "STRAT's outputs KEYS at each cue plist of GRID (NIL read as 0): the vector two strategies are compared by (§3)."
  (coerce (loop for feats in grid append (loop for k in keys collect (or (strat-value strat k feats) 0))) 'simple-vector))

(defun strat-similarity (a b)
  "1 - the mean absolute difference of fingerprints A and B, each value scaled by the larger magnitude of the pair (1 = the same)."
  (let ((n (length a)) (tot 0.0))
    (dotimes (i n) (let ((x (svref a i)) (y (svref b i)))
                     (incf tot (if (and (zerop x) (zerop y)) 0.0 (/ (abs (- x y)) (max (abs x) (abs y)))))))
    (if (zerop n) 1.0 (- 1.0 (/ tot n)))))
