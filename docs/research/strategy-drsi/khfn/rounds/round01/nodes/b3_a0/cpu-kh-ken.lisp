;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b3_a0, round 1: 資源 (resources): when a combo breaker is worth its price (the awakening, the Burst).
(in-package :duel)

(defparameter *kh-brk-awaken-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "Reeling in a combo (once per combo, at the reaction delay): the awakening as the breaker when the gauge is full (free, heals, no
flash-step) instead of waiting for a neutral step. b3_a0 2026-11-09.")
(defparameter *kh-brk-burst-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "Reeling in a combo: the Burst (200 flash-step) when *KH-BRK-FS* allows. One roll per combo (the generic 0.5 / 0.2 / red 0.9).")
(defparameter *kh-brk-fs* 200.0 "The flash-step he must hold to Burst (the Burst costs 200; a Hoho 100).")
(defparameter *kh-brk-hits* 2 "The combo hits he reels in before the breaker is rolled.")

(defun kh-break (e b f)
  "Reeling in a combo: once per combo at the reaction delay, the awakening (gauge full) or the Burst breaks it. T when pressed."
  (when (and (member (fighter-state f) '(:stun :air)) (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b))
             (not (brain-burst-rolled b)) (>= (fighter-combo-hits f) *kh-brk-hits*))
    (setf (brain-burst-rolled b) t)
    (let ((g (gauges e)))
      (cond ((and (not (gauges-awakened g)) (>= (gauges-awaken g) *awaken-max*) (not (getf (kit-core (fighter-kit f)) :no-awaken))
                  (brain-roll b *kh-brk-awaken-p*))
             (ai-press b :awaken 1 :modded t) t)
            ((and (>= (gauges-fs g) *kh-brk-fs*) (burst-ok-p e) (brain-roll b *kh-brk-burst-p*))
             (ai-press b :awaken 1) t)))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (or (kh-break e b f) (ken-ki-style e b f kit s d)))
