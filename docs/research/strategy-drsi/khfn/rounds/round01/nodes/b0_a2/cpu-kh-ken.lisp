;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b0_a0 (round 1): his KI style CPU (cpu-ki-ken.lisp) plus the wake-up bait.
(in-package :duel)

(defparameter *khf-bait-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Wake-up bait: per knockdown of Hisagi's (one roll as he goes down): do not press the meaty J1 of the KI code; stand at *KHF-BAIT-D* and
wait. Hisagi's wake-up Hoho (his CPU presses it on his first free frame whenever Kenpachi is seen within 2.4 m) turns the meaty J1 into a
perfect Hoho (his counter 60, Kenpachi locked 40 frames, his J1 J2 AS1 follow): 6 of 6 meaty J1s in seed 301 (HARD, live table). Standing
still gives the Hoho nothing to read; the KI code's hoho-end J1 (KKS-PLAN :hend) then lands on him as he reappears. New 2026-11-09, b0_a0.")
(defparameter *khf-bait-d* 2.3 "Wake-up bait: the distance (m) held while he is down (inside his wake-up Hoho trigger, 2.4 m, so it is spent on nothing).")
(defparameter *khf-bait-after* 4
  "Wake-up bait: frames added to the brain's perception delay after the last perceived down / wake-up step during which Kenpachi still
holds (his first free frame and Hoho press are not in the SNAP yet; a move started then runs into the Hoho).")

(defparameter *khf-hoho-in-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Closing in: the KI code's Hoho in. Bound on for Hisagi at HARD 1.0 it lost (seed0 300, scale 0.5: 0.8005 vs 0.8882, live 0.73 vs 0.87): his chain punishes the arrival. Off.")
(defparameter *khf-step-band* '(2.2 5.6)
  "Closing in: the KI code's Step-in band (m), widened from (2.2 4.4) so the free invulnerable Step starts from the Shikai chain's mid range.")

(defstruct (khs (:include kks) (:constructor make-khs ()))
  (hw :idle)                    ; Hisagi's perceived state at the last step
  (bait nil)                    ; this knockdown's roll said yes
  (last -999 :type fixnum)      ; the last tick the SNAP showed him down / waking up
  (soat 0 :type fixnum)           ; stand-off clock: the tick of the last gauge change
  (sor0 0.0 :type single-float) (sor1 0.0 :type single-float) (sok0 0 :type fixnum) (sok1 0 :type fixnum)
  (soon nil))                   ; the stand-off breaker is on
(inline-readers khs)

(defun khf-bait-step (e b f s d st)
  "Hisagi down or just up with the bait roll yes: hold at *KHF-BAIT-D*. T when it decided."
  (let ((ss (snap-state s)) (now *match-tick*))
    (when (and (member ss '(:air :down :wakeup)) (not (member (khs-hw st) '(:air :down :wakeup))))
      (setf (khs-bait st) (brain-roll b *khf-bait-p*))
      (when (khs-bait st) (clog "~a khf bait armed" (side-name e))))
    (setf (khs-hw st) ss)
    (when (member ss '(:down :wakeup)) (setf (khs-last st) now))
    (when (and (khs-bait st) (member (fighter-state f) '(:idle :run)) (null (kks-plan st)))
      (cond ((or (member ss '(:down :wakeup))
                 (and (not (eq ss :hoho)) (<= (- now (khs-last st)) (+ (brain-delay b) *khf-bait-after*))))
             (cond ((> d (+ *khf-bait-d* 0.15)) (kk-stick e 1)) ((< d (- *khf-bait-d* 0.3)) (kk-stick e -1)) (t (kk-stick e 0)))
             t)
            (t (setf (khs-bait st) nil) nil)))))

;; Stand-off breaker (from b2_a1's measured mechanism, composed with the bait): an old stand-off while the bell is not his -> attack.
(defparameter *khf-stale* '(:easy 900 :normal 540 :hard 120)
  "Stand-off breaker: frames with no change of either side's Reishi or Konpaku before the stand-off is old (b2_a1, 2026-11-10).")

(defun khf-winning-p (g0 g1)
  "Does the bell favour gauges G0 over G1 now (Konpaku, then Reishi %)?"
  (or (> (gauges-konpaku g0) (gauges-konpaku g1))
      (and (= (gauges-konpaku g0) (gauges-konpaku g1)) (> (reishi-frac g0) (reishi-frac g1)))))

(defun khf-old-p (b f st e)
  "Tick the gauge clock; T when the stand-off is older than *KHF-STALE* and the bell is not Kenpachi's."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (r0 (f32 (gauges-reishi g0))) (r1 (f32 (gauges-reishi g1))) (k0 (gauges-konpaku g0)) (k1 (gauges-konpaku g1)))
    (unless (and (= r0 (khs-sor0 st)) (= r1 (khs-sor1 st)) (= k0 (khs-sok0 st)) (= k1 (khs-sok1 st)))
      (setf (khs-sor0 st) r0 (khs-sor1 st) r1 (khs-sok0 st) k0 (khs-sok1 st) k1 (khs-soat st) *match-tick*))
    (and (> (- *match-tick* (khs-soat st)) (getf *khf-stale* (brain-difficulty b) 300))
         (not (khf-winning-p g0 g1)))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (not (khs-p st)) (< *match-tick* (kks-tick st)))
      (setf st (make-khs) (brain-style b) st))
    (cond ((khf-bait-step e b f s d st) (setf (kks-tick st) *match-tick*) t)
          (t (let ((*kk-ns-safe-p* (if (khf-old-p b f st e) '(:easy 0.0 :normal 0.0 :hard 0.0) *kk-ns-safe-p*))
                   (*kk-meaty-p* (if (khs-bait st) '(:easy 0.0 :normal 0.0 :hard 0.0) *kk-meaty-p*))
                   (*kk-hoho-in-p* *khf-hoho-in-p*) (*kk-step-in-band* *khf-step-band*))
               (ken-ki-style e b f kit s d))))))
