;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, steps 7-8). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. Round 2, cell b1_a0 (range control).
;;;; The job: the timed counter-Hoho. In the Shikai, a Kenpachi attack that starts inside Hisagi's reach is answered by a Hoho pressed so that
;;;; it is a PERFECT Hoho (Ichigo's IKS-TIMED-HOHO, the lead window of his first active frame), then J1 on the whiffed recovery from behind
;;;; (IKS-HOHO-FOLLOW). Every other step is the merged style unchanged. Hisagi keeps the distance of a reach he does not have: the Hoho
;;;; moves him out of the strike's range and the counter lands where the Shikai's chain-sickle is short.
(in-package :duel)

(defstruct (hkq (:include hms) (:constructor make-hkq ()))
  "The counter-Hoho's state: Ichigo's style struct (only its Hoho fields are used) beside the merged style's."
  (ik nil)                      ; an IKST
  (qtick 0 :type fixnum))       ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hkq)

(defparameter *hkq-forms* '(:base) "Hisagi's forms that take the counter-Hoho (the Shikai).")

(defparameter *hkq-j-reach* 2.0
  "The follow-up J1 after the counter-Hoho starts from within this (m) (Ichigo's *IKS-HOHO-J-REACH* 1.5: Hisagi's J1 reaches farther). 1.5 -> 2.0, round 2 b1_a0.")
(defparameter *hkq-lead* '(1 8)
  "The counter-Hoho's pressing window, frames before the move's first active frame as seen (Ichigo's *IKS-HOHO-LEAD* (1 6)). (1 6) -> (1 8), round 2 b1_a0.")

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (unless (hkq-p st) (setf st (make-hkq) (brain-style b) st))
    (when (or (null (hkq-ik st)) (< *match-tick* (hkq-qtick st))) (setf (hkq-ik st) (make-ikst)))
    (setf (hkq-qtick st) *match-tick*)
    (or (and (member (fighter-form f) *hkq-forms*)
             (member (fighter-state f) '(:idle :run))
             (let ((ik (hkq-ik st)) (*iks-hoho-j-reach* *hkq-j-reach*) (*iks-hoho-lead* *hkq-lead*))
               (or (iks-timed-hoho e b ik s d)
                   (iks-hoho-follow e b ik s d (pilot-vpad (pilot e))))))
        (hisagi-merged-style e b f kit s d))))
