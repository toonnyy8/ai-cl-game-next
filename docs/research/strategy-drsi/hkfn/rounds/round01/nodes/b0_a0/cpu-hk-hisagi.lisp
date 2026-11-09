;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
(in-package :duel)

;;; ---------------------------------------------------------------- the wake-up roll (cell b0_a0, round 1)
;;; One job: Hisagi's own knockdown. Kenpachi's bait waits 2.3 m off for the wake-up Hoho (or a meaty J1). A roll out of the wake-up is
;;; invulnerable and slides *ROLL-DISTANCE* (4 m) away, so the stand-off Kenpachi set for the Hoho ends 6 m off, where the Shikai's
;;; chain and the Bankai's ranged mode are Hisagi's. The stick held back while he lies (the roll reads it as the wake-up begins).
(defparameter *hkw-roll-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Wake-up roll: per knockdown (one roll as he lands) the chance he holds the stick back so he rolls away out of the wake-up. New 2026-11-10.")

(defparameter *hkw-guard-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Wake-up guard: per knockdown, the chance he guards on his first free frames instead of the Hoho. New 2026-11-10.")
(defparameter *hkw-sp-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Wake-up SP: per knockdown, the chance his first free frame is the pointer's SP (a ranged NS from inside Kenpachi's bait) instead of the Hoho.")
(defparameter *hkw-sp-near* 2.0 "Wake-up SP: only when Kenpachi stands idle at least this far (m): outside the Shikai K1's dead zone it cannot reach.")
(defparameter *hkw-sp-far* 2.7 "Wake-up SP: ... and at most this far: the bait's stand-off (2.3 m); a Kenpachi coming in is not the bait.")
(defparameter *hkw-guard-frames* 30 "Wake-up guard: frames the Guard is held after the wake-up.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-roll nil)                 ; this knockdown's roll said yes
  (hk-prev :idle) (hk-guard nil) (hk-sp nil)
  (hk-tick 0 :type fixnum))     ; the last tick this style ran (a smaller tick: a new match)              ; his own state at the last step
(inline-readers hks)

(defun hkw-step (e b f kit s d st)
  "Lands (one roll per knockdown): the roll yes holds the stick back while he lies; the guard yes holds Guard on his first free frame."
  (let ((fs (fighter-state f)))
    (when (and (eq fs :down) (not (eq (hks-hk-prev st) :down)))
      (setf (hks-hk-roll st) (brain-roll b *hkw-roll-p*) (hks-hk-guard st) (brain-roll b *hkw-guard-p*) (hks-hk-sp st) (brain-roll b *hkw-sp-p*)))
    (setf (hks-hk-prev st) fs)
    (cond ((and (hks-hk-roll st) (eq fs :down)) (kk-stick e -1) t)
          ((and (hks-hk-sp st) (member fs '(:idle :run)))
           (setf (hks-hk-sp st) nil)
           (when (and (eq (snap-state s) :idle) (<= *hkw-sp-near* d *hkw-sp-far*) (kit-core-move kit :ns (fighter-ptr f)))
             (setf (brain-r-kikon b) 1f0)
             (cai-sp b f s)
             t))
          ((and (hks-hk-guard st) (member fs '(:idle :run)))
           (setf (hks-hk-guard st) nil)
           (ai-press b :guard *hkw-guard-frames* :act :hold)
           t))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (or (hkw-step e b f kit s d st)
        (hisagi-merged-style e b f kit s d))))
