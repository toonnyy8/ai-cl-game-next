;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. Cell b3_a1 (round 1): the awakening's timing (one job: WHEN to spend the awakening gauge).
(in-package :duel)

(defparameter *hkr-far* 5.0
  "Cell b3_a1: Kenpachi at least this far (m) is a safe moment to awaken (the cinematic cannot be punished).")
(defparameter *hkr-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Cell b3_a1: chance that the held awakening is taken at a safe moment (one roll per safe event).")

(defun hkr-safe-p (s d)
  "Kenpachi, as seen, is far off or cannot act (down, getting up, stunned, airborne)."
  (or (>= d *hkr-far*) (member (snap-state s) '(:down :wakeup :stun :air))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (when (and (eq (fighter-form f) :base) (gauges-awakened-ok-p e))
    (let ((st (let ((x (brain-style b))) (if (hms-p x) x (setf (brain-style b) (make-hms))))))
      (unless (hms-ken st) (setf (hms-ken st) (make-kks)))
      (setf (kks-aw (hms-ken st)) :no)                    ; (hold: the KI code's own awakening door stays shut)
      (when (and (hkr-safe-p s d) (brain-roll b *hkr-p*))
        (ai-press b :awaken 1 :modded t)
        (return-from hisagi-hk-style t))))
  (hisagi-merged-style e b f kit s d))
