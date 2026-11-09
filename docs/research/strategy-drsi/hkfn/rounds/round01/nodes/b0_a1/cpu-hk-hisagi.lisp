;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
(in-package :duel)

;;; ---------------------------------------------------------------- the wake-up back-off (cell b0_a1, round 1)
;;; One job: Hisagi's own knockdown against Kenpachi's wake-up bait. The bait stands 2.3 m off, inside the 2.4 m where the shared CPU
;;; presses its wake-up Hoho, then punishes the Hoho's end. Sibling b0_a0 replaced that first free frame with a roll, a guard or an SP:
;;; all lost. Here no move is pressed at all: for a short while after he gets up he only walks away (stick back), so the Hoho is never
;;; spent, he commits nothing the bait can punish, and the bait's own timer runs out; then the merged style plays on from a longer range.
(defparameter *hkb-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Wake-up back-off: per knockdown (one roll as he lands) the chance he walks away on his first free frames instead of the shared CPU's wake-up Hoho. New 2026-11-10, cell b0_a1.")
(defparameter *hkb-frames* 16 "Wake-up back-off: frames he walks away after his first free frame.")
(defparameter *hkb-abort-d* 1.8 "Wake-up back-off: a perceived Kenpachi move this close (m) hands the step back to the MCTS (defence).")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hkb-on nil)                  ; this knockdown's roll said yes
  (hkb-left 0 :type fixnum)     ; walk-away frames left once free
  (hkb-prev :idle)              ; his own state at the last step
  (hkb-tick 0 :type fixnum))    ; the last tick this style ran (a smaller tick: a new match)
(inline-readers hks)

(defun hkb-step (e b f s d st)
  "Lands (one roll per knockdown); on his free frames walk away for *HKB-FRAMES*. T when it decided."
  (declare (ignorable b))
  (let ((fs (fighter-state f)))
    (when (and (member fs '(:down :wakeup)) (not (member (hks-hkb-prev st) '(:down :wakeup))))
      (setf (hks-hkb-on st) (brain-roll b *hkb-p*) (hks-hkb-left st) 0))
    (when (and (hks-hkb-on st) (member fs '(:idle :run)) (member (hks-hkb-prev st) '(:down :wakeup)))
      (setf (hks-hkb-left st) *hkb-frames*))
    (setf (hks-hkb-prev st) fs)
    (cond ((not (member fs '(:idle :run))) nil)
          ((<= (hks-hkb-left st) 0) (setf (hks-hkb-on st) nil) nil)
          ((not (and (eq (snap-state s) :idle) (<= 2.0 d 2.8))) (setf (hks-hkb-left st) 0) nil)   ; only against the bait: idle at its stand-off
          (t (decf (hks-hkb-left st)) (kk-stick e -1) t))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hkb-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hkb-tick st) *match-tick*)
    (or (hkb-step e b f s d st)
        (hisagi-merged-style e b f kit s d))))
