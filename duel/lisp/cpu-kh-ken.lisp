;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it: the §10 style unit :st-ken-kh (arm :a-ken-kh, Kenpachi vs Hisagi's Q table). Written by
;;;; the dream-rsi search in docs/research/strategy-drsi/khfn/: kept cell b0_a0 (round 1), one job, the wake-up bait, on his KI style CPU
;;;; (cpu-ki-ken.lisp). Held-out (seed0 400, 1,900 matches) 0.892 against Hisagi's pool; his KI code alone 0.429. Since step 6 it plays as
;;;; the KH table's :KNOCKDOWN event layer (core-ai.lisp STRAT-EVENT-STEP). The file's second style, KEN-KH-STANDOFF-STYLE (below), is the
;;;; stand-off breaker (:st-ken-kh-standoff), step 6.
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

(defstruct (khs (:include kks) (:constructor make-khs ()))
  (hw :idle)                    ; Hisagi's perceived state at the last step
  (bait nil)                    ; this knockdown's roll said yes
  (last -999 :type fixnum))     ; the last tick the SNAP showed him down / waking up
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

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (not (khs-p st)) (< *match-tick* (kks-tick st)))
      (setf st (make-khs) (brain-style b) st))
    (cond ((khf-bait-step e b f s d st) (setf (kks-tick st) *match-tick*) t)
          ((khs-bait st) (let ((*kk-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (ken-ki-style e b f kit s d)))
          (t (ken-ki-style e b f kit s d)))))

;;; ---------------------------------------------------------------- the stand-off breaker (KEN-KH-STANDOFF-STYLE, §8.19 round 5, step 6)
;;; Cell b2_a1 (round 1) of the same search, rewritten with its state in the brain (the user, 2026-11-10: 「重寫僵局破解，當第二個選項」): the
;;; style unit :st-ken-kh-standoff, one job. His KI code was written against Ichigo's wake-up Hoho: an approach holds J1 / the NS whenever the
;;; opponent stands idle and the move's startup is over *KK-HOHO-BLIND* (*KK-NS-SAFE-P*). Against Hisagi's CPU, which waits too, that is a
;;; stare for the rest of the clock, and the bell goes to Konpaku, then Reishi %. KSO-OLD-P clocks the frames since either side's gauges
;;; moved; once the stand-off is old and Kenpachi is not winning the bell, his KI code runs with the Hoho-safety discipline off (and its
;;; approach roll made again), so he attacks the idle opponent. Winning the bell he keeps his patience. The cell kept the clock in a
;;; process-global hash keyed by the brain, which the in-game MCTS rollouts never snapshot; here it is a KSO struct in BRAIN-STYLE (it
;;; includes his KI code's KKS), so a snapshot saves and restores it with the rest of the brain.

(defparameter *kso-stale* '(:easy 900 :normal 540 :hard 120)
  "Frames (by difficulty) with no change of either side's Reishi or Konpaku before the stand-off is old. 2026-11-10, cell b2_a1.")
(defparameter *kso-lead* 0.0
  "Kenpachi counts as winning the bell when his Konpaku is higher, or equal and his Reishi fraction is higher by more than this.")

(defstruct (kso (:include kks) (:constructor make-kso ()))
  (so-at 0 :type fixnum)                                ; the tick of the last gauge change (SO-: KKS has its own AT ...)
  (so-r0 0.0 :type single-float) (so-r1 0.0 :type single-float)   ; the two Reishi then
  (so-k0 0 :type fixnum) (so-k1 0 :type fixnum)         ; the two Konpaku then
  (so-on nil))                                          ; the breaker is on (its onset makes the approach roll again)
(inline-readers kso)

(defun kso-winning-p (g0 g1)
  "Does the bell favour gauges G0 over G1 now (Konpaku, then Reishi % by more than *KSO-LEAD*)?"
  (or (> (gauges-konpaku g0) (gauges-konpaku g1))
      (and (= (gauges-konpaku g0) (gauges-konpaku g1)) (> (- (reishi-frac g0) (reishi-frac g1)) *kso-lead*))))

(defun kso-old-p (e b f st)
  "Tick the clock (any change of the four gauges restarts it); T when the stand-off is older than *KSO-STALE* and the bell is not his."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (r0 (f32 (gauges-reishi g0))) (r1 (f32 (gauges-reishi g1))) (k0 (gauges-konpaku g0)) (k1 (gauges-konpaku g1)))
    (unless (and (= r0 (kso-so-r0 st)) (= r1 (kso-so-r1 st)) (= k0 (kso-so-k0 st)) (= k1 (kso-so-k1 st)))
      (setf (kso-so-r0 st) r0 (kso-so-r1 st) r1 (kso-so-k0 st) k0 (kso-so-k1 st) k1 (kso-so-at st) *match-tick*))
    (and (> (- *match-tick* (kso-so-at st)) (getf *kso-stale* (brain-difficulty b) 300))
         (not (kso-winning-p g0 g1)))))

(defun ken-kh-standoff-style (e b f kit s d)
  "Kenpachi's stand-off breaker against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (let ((st (brain-style b)))
    (when (or (null st) (not (kso-p st)) (< *match-tick* (kks-tick st)))
      (setf st (make-kso) (brain-style b) st (kso-so-at st) *match-tick*))
    (cond ((not (kso-old-p e b f st)) (setf (kso-so-on st) nil) (ken-ki-style e b f kit s d))
          (t (unless (kso-so-on st)
               (setf (kso-so-on st) t (kks-appr st) nil)            ; (the approach's Hoho-safety roll is made again)
               (clog "~a kh stand-off breaker at ~,1f" (side-name e) d))
             (let ((*kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 0.0)))
               (ken-ki-style e b f kit s d))))))
