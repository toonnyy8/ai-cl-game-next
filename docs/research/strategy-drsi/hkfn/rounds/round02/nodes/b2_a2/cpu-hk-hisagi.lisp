;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it. Written by the dream-rsi search in docs/research/strategy-drsi/hkfn/.
;;;;
;;;; Cell b2_a2 (round 2). The one job: STEP THROUGH KENPACHI'S MOVE AND CANCEL INTO J1. When Kenpachi starts a move that reaches him
;;;; (the KI code's meaty J1, hoho-end J1, Step-in J1, stand-off attack), Hisagi (outside the Bankai) presses a Step toward him timed so the
;;;; Step's invulnerable frames (3-9) cover the first hit, then J1 out of the Step's J cancel (frame 12) onto the recovering Kenpachi. The
;;;; shared KI code's answers are a Hoho (no punish unless perfect) or a back Step (nothing to punish with). Everything else: the merged style.
(in-package :duel)

(defparameter *hkj-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Per Kenpachi move start that can reach him (one roll): step through it and J1 out of the cancel. New 2026-11-10, cell b2_a2.")
(defparameter *hkj-lead* 6
  "The Step is pressed when Kenpachi's perceived frames to his first hit (less the perception delay) are at most this (the Step's
invulnerable frames are 3-9 after the press).")
(defparameter *hkj-min* 3 "Not pressed when fewer frames than this are left (too late: the hit is in before the invulnerable frames).")
(defparameter *hkj-reach* 0.3 "The move is answered within its reach + slide + this (m).")
(defparameter *hkj-j* 0.2 "J1 out of the cancel when the distance is within J1's reach + slide + this (m).")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (hk-ev -2 :type fixnum)       ; Kenpachi's move start the roll was made for
  (hk-plan nil)                 ; :wait (Step to press at HK-AT) or :cancel (Step pressed: J1 at the cancel frame)
  (hk-at 0 :type fixnum)
  (hk-tick 0 :type fixnum))     ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hks)

(defun hkj-step (e b f kit s d st)
  "Step through Kenpachi's move start, J1 out of the Step's cancel. T when it decided."
  (let ((state (fighter-state f)) (q (kit-command-move kit :q e)))
    (cond
      ((eq (fighter-form f) :bankai) (setf (hks-hk-plan st) nil) nil)
      ((and (eq state :step) (eq (hks-hk-plan st) :cancel))
       (cond ((= (fighter-sf f) (- *step-j-cancel* 2))
              (setf (hks-hk-plan st) nil)
              (when (and q (<= d (+ (mv-reach q) (mv-slide q) *hkj-j*)))
                (clog "~a hk step-through J1 at ~,1f" (side-name e) d)
                (setf (brain-own-key b) -1)
                (cai-press b :quick 1)
                t))
             (t nil)))
      ((not (member state '(:idle :run))) (setf (hks-hk-plan st) nil) nil)
      ((eq (hks-hk-plan st) :wait)
       (let ((mv (snap-move s)))
         (cond ((not (and (eq (snap-state s) :move) mv (= (snap-start s) (hks-hk-ev st)))) (setf (hks-hk-plan st) nil) nil)
               ((>= *match-tick* (hks-hk-at st))
                (setf (hks-hk-plan st) :cancel)
                (clog "~a hk step-through at ~,1f" (side-name e) d)
                (kk-stick e 1)
                (ai-press b :step 1)
                t)
               (t (kk-stick e 0) t))))
      (t
       (let ((mv (snap-move s)))
         (when (and (eq (snap-state s) :move) mv (plusp (length (mv-hits mv))) (/= (snap-start s) (hks-hk-ev st))
                    (<= d (+ (mv-reach mv) (mv-slide mv) *hkj-reach*)))
           (setf (hks-hk-ev st) (snap-start s))
           (let ((left (- (snap-s s) (snap-sf s) (brain-delay b))))
             (when (and (>= left *hkj-min*) (brain-roll b *hkj-p*))
               (setf (hks-hk-plan st) :wait (hks-hk-at st) (+ *match-tick* (max 0 (- left *hkj-lead*))))
               (hkj-step e b f kit s d st)))))))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (not (hks-p st)) (< *match-tick* (hks-hk-tick st)))
      (setf st (make-hks) (brain-style b) st))
    (setf (hks-hk-tick st) *match-tick*)
    (or (hkj-step e b f kit s d st)
        (hisagi-merged-style e b f kit s d))))
