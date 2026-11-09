;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. The search's starting program: his KI style CPU (cpu-ki-ken.lisp) unchanged.
;;;;
;;;; Cell b2_a1 (round 1): 膠着破り STAND-OFF BREAKER. The KI code was written against Ichigo's wake-up Hoho: an approach holds J1 / the NS
;;;; whenever the opponent stands idle and the move's startup is over *KK-HOHO-BLIND* (*KK-NS-SAFE-P*). Against Hisagi's CPU, which waits
;;;; too, that is a 1.4 m stare for the rest of the clock (seed 303: no hit from 14 s to 300 s), and the bell goes to Konpaku, then Reishi %,
;;;; which Kenpachi has often given up by releasing (6 against 9). KH-STALE clocks the frames since either side's gauges moved; once the
;;;; stand-off is old and Kenpachi is not winning the bell's tiebreak, the delegate runs with the Hoho-safety discipline off (and its
;;;; approach re-rolled), so he attacks the idle opponent. Winning the tiebreak he keeps his patience. Everything else is ken-ki-style's.
(in-package :duel)

(defparameter *kh-stale* '(:easy 900 :normal 540 :hard 120)
  "Frames (by difficulty) with no change of either side's Reishi or Konpaku before the stand-off is old. 2026-11-10, cell b2_a1.")
(defparameter *kh-lead* 0.0
  "Kenpachi counts as winning the bell when his Konpaku is higher, or equal and his Reishi fraction is higher by more than this.")

(defvar *kh-states* (make-hash-table :test 'eq) "Per brain: the stand-off clock (a KHS), reset when *MATCH-TICK* goes back.")
(defvar *kh-last* 0 "*MATCH-TICK* at the last call (a lower one: a new match, the table starts over).")

(defstruct (khs (:constructor make-khs ()))
  (at 0 :type fixnum)           ; the tick of the last gauge change
  (r0 0.0 :type single-float) (r1 0.0 :type single-float) ; the two Reishi then
  (k0 0 :type fixnum) (k1 0 :type fixnum) ; the two Konpaku then
  (on nil))                     ; the breaker is on (its onset re-rolls the approach)
(inline-readers khs)

(defun kh-state (b)
  (when (< *match-tick* *kh-last*) (clrhash *kh-states*))
  (setf *kh-last* *match-tick*)
  (or (gethash b *kh-states*) (setf (gethash b *kh-states*) (make-khs))))

(defun kh-winning-p (g0 g1)
  "Does the bell favour gauges G0 over G1 now (Konpaku, then Reishi % by more than *KH-LEAD*)?"
  (or (> (gauges-konpaku g0) (gauges-konpaku g1))
      (and (= (gauges-konpaku g0) (gauges-konpaku g1))
           (> (- (reishi-frac g0) (reishi-frac g1)) *kh-lead*))))

(defun kh-old-p (e b f st)
  "Tick the clock (any change of the four gauges restarts it); T when the stand-off is older than *KH-STALE*."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (r0 (f32 (gauges-reishi g0))) (r1 (f32 (gauges-reishi g1))) (k0 (gauges-konpaku g0)) (k1 (gauges-konpaku g1)))
    (unless (and (= r0 (khs-r0 st)) (= r1 (khs-r1 st)) (= k0 (khs-k0 st)) (= k1 (khs-k1 st)))
      (setf (khs-r0 st) r0 (khs-r1 st) r1 (khs-k0 st) k0 (khs-k1 st) k1 (khs-at st) *match-tick*))
    (and (> (- *match-tick* (khs-at st)) (getf *kh-stale* (brain-difficulty b) 300))
         (not (kh-winning-p g0 g1)))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let* ((st (kh-state b)) (old (kh-old-p e b f st)))
    (cond ((not old) (setf (khs-on st) nil) (ken-ki-style e b f kit s d))
          (t (unless (khs-on st)
               (setf (khs-on st) t)
               (let ((k (brain-style b))) (when (kks-p k) (setf (kks-appr k) nil)))   ; (the approach's Hoho-safety roll is made again)
               (clog "~a kh stand-off breaker at ~,1f" (side-name e) d))
             (let ((*kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 0.0)))
               (ken-ki-style e b f kit s d))))))
