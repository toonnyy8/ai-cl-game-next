;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
(in-package :duel)

;;; ---------------------------------------------------------------- the held wake-up Hoho (cell b0_a2, round 1)
;;; One job: Hisagi's own knockdown against Kenpachi's wake-up bait. The bait stands 2.3 m off, inside the 2.4 m where his KI code (the
;;; merged style) presses its wake-up Hoho on the first free frame, then punishes the Hoho's end (hoho-end J1). Siblings b0_a0 / b0_a1
;;; replaced that frame with a roll, a guard, an SP, a walk: all lost (they leave the KI code's reactive defence). Here nothing is
;;; replaced: only the wake-up Hoho is withheld while he is seen idle at the bait's stand-off, and the KI code plays on as it is (its own
;;; reactive dodge answers the move Kenpachi has to start once the bait's timer runs out).
(defparameter *hkh-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Held wake-up Hoho: per knockdown (one roll as he lands) the chance the wake-up Hoho is withheld when Kenpachi is seen idle at the bait's stand-off. New 2026-11-10, cell b0_a2.")
(defparameter *hkh-frames* 4 "Held wake-up Hoho: free frames after the knockdown during which the Hoho stays withheld.")
(defparameter *hkh-near* 2.15 "Held wake-up Hoho: nearest stand-off (m) at which the Hoho is withheld.")
(defparameter *hkh-far* 2.45 "Held wake-up Hoho: farthest stand-off (m) at which the Hoho is withheld.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hkh-on nil)                  ; this knockdown's roll said yes
  (hkh-left 0 :type fixnum)     ; free frames of withholding left
  (hkh-prev :idle)              ; his own state at the last step
  (hkh-tick 0 :type fixnum))    ; the last tick this style ran (a smaller tick: a new match)
(inline-readers hks)

(defun hkh-hold-p (b f s d st)
  "Track the knockdown (one roll as he lands); T while the wake-up Hoho is to be withheld on this step."
  (let ((fs (fighter-state f)))
    (when (and (member fs '(:down :wakeup)) (not (member (hks-hkh-prev st) '(:down :wakeup))))
      (setf (hks-hkh-on st) (brain-roll b *hkh-p*) (hks-hkh-left st) 0))
    (when (and (hks-hkh-on st) (member fs '(:idle :run)) (member (hks-hkh-prev st) '(:down :wakeup)))
      (setf (hks-hkh-left st) *hkh-frames*))
    (setf (hks-hkh-prev st) fs)
    (when (and (> (hks-hkh-left st) 0) (member fs '(:idle :run)))
      (decf (hks-hkh-left st))
      (and (eq (snap-state s) :idle) (<= *hkh-near* d *hkh-far*)))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hkh-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hkh-tick st) *match-tick*)
    (if (hkh-hold-p b f s d st)
        (let ((*kk-wake-hoho-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (hisagi-merged-style e b f kit s d))
        (hisagi-merged-style e b f kit s d))))
