;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
;;;; Cell b3_a0 (round 1): ONE JOB, spending the DRIVE / SUBLIMATION gauge on a pointer switch in his own NS gap after a HIT (the user's
;;;; route, DUEL_SUBLIMATION §17), in every form, by his own roll (the strategy carries no :DSWITCH). Measured first (v1-v3): the Burst on every
;;;; combo 0.146, holding the awakening 0.155, no Burst at all 0.207 against the baseline's 0.216: the escapes are not where the score is.
(in-package :duel)

(defparameter *hk-switch-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "Per own NS segment whose gap is reached after a hit, the switch is open and a pointer reaches: spend the gauge on the switch (one roll per segment).")
(defparameter *hk-switch-min* 0.0 "Gauge fraction (DRIVE awakened, SUBLIMATION before) the switch needs on top of the rules' own floor.")

(defstruct (hks (:include hms) (:constructor make-hks ()))
  (sseg -1 :type fixnum)        ; the NS segment (its CLS-T) the switch roll was made for
  (tick 0 :type fixnum))        ; *MATCH-TICK* at the last call (a lower one: a new match)
(inline-readers hks)

(defun hk-gauge-frac (e)
  (let ((g (gauges e))) (if (gauges-awakened g) (/ (gauges-drive g) *drive-max*) (/ (gauges-sub g) *sub-max*))))

(defun hk-switch (e b f kit st)
  "In his own NS segment's gap after a hit, once per segment: the DRIVE switch. T when it pressed."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-state f) :move) (eq (fighter-cls f) :ns) (>= (fighter-sf f) (mv-s mv)) (/= (hks-sseg st) (fighter-cls-t f))
               (eq (fighter-contact f) :hit))
      (setf (hks-sseg st) (fighter-cls-t f))
      (when (and (core-switch-open-p e f) (>= (hk-gauge-frac e) *hk-switch-min*))
        (let ((to (cai-switch-target f kit (fighter-dist f))))
          (when (and to (brain-roll b *hk-switch-p*))
            (setf (brain-decided b) (fighter-cls-t f))
            (cai-switch-press e b f to)
            t))))))

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (let ((x (brain-style b))) (if (and (hks-p x) (>= *match-tick* (hks-tick x))) x (setf (brain-style b) (make-hks))))))
    (setf (hks-tick st) *match-tick*)
    (or (hk-switch e b f kit st)
        (hisagi-merged-style e b f kit s d))))
