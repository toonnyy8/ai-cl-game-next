;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b3_a2, round 1: b3_a1 (combo breaker + wake-up bait) + b2_a1 stand-off breaker.
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
  (last -999 :type fixnum)      ; the last tick the SNAP showed him down / waking up
  (so-at 0 :type fixnum)         ; stand-off clock: the tick of the last gauge change
  (so-r0 0.0 :type single-float) (so-r1 0.0 :type single-float) ; the two Reishi then
  (so-k0 0 :type fixnum) (so-k1 0 :type fixnum) ; the two Konpaku then
  (so-on nil))                  ; the stand-off breaker is on
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

(defparameter *kh-stale* '(:easy 900 :normal 540 :hard 120)
  "Stand-off breaker (b2_a1): frames with no change of either side's Reishi or Konpaku before the stand-off is old. 2026-11-10, b3_a2.")
(defparameter *kh-lead* 0.0
  "Kenpachi counts as winning the bell when his Konpaku is higher, or equal and his Reishi fraction is higher by more than this.")

(defun kh-winning-p (g0 g1)
  "Does the bell favour gauges G0 over G1 now (Konpaku, then Reishi % by more than *KH-LEAD*)?"
  (or (> (gauges-konpaku g0) (gauges-konpaku g1))
      (and (= (gauges-konpaku g0) (gauges-konpaku g1))
           (> (- (reishi-frac g0) (reishi-frac g1)) *kh-lead*))))

(defun kh-old-p (e b f st)
  "Tick the resource clock (any change of the four gauges restarts it); T when the stand-off is older than *KH-STALE* and the bell is not his."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (r0 (f32 (gauges-reishi g0))) (r1 (f32 (gauges-reishi g1))) (k0 (gauges-konpaku g0)) (k1 (gauges-konpaku g1)))
    (unless (and (= r0 (khs-so-r0 st)) (= r1 (khs-so-r1 st)) (= k0 (khs-so-k0 st)) (= k1 (khs-so-k1 st)))
      (setf (khs-so-r0 st) r0 (khs-so-r1 st) r1 (khs-so-k0 st) k0 (khs-so-k1 st) k1 (khs-so-at st) *match-tick*))
    (and (> (- *match-tick* (khs-so-at st)) (getf *kh-stale* (brain-difficulty b) 300))
         (not (kh-winning-p g0 g1)))))

(defun kh-delegate (e b f kit s d st)
  "His KI code, with the Hoho-safety hold lifted while the stand-off is old and the bell is not his."
  (cond ((not (kh-old-p e b f st)) (setf (khs-so-on st) nil) (ken-ki-style e b f kit s d))
        (t (unless (khs-so-on st)
             (setf (khs-so-on st) t (kks-appr st) nil)   ; (the approach's Hoho-safety roll is made again)
             (clog "~a kh stand-off breaker at ~,1f" (side-name e) d))
           (let ((*kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (ken-ki-style e b f kit s d)))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU.
Resources first (the combo breaker), then the wake-up bait around his KI code."
  (let ((st (brain-style b)))
    (when (or (null st) (not (khs-p st)) (< *match-tick* (kks-tick st)))
      (setf st (make-khs) (brain-style b) st))
    (cond ((kh-break e b f) t)
          ((khf-bait-step e b f s d st) (setf (kks-tick st) *match-tick*) t)
          ((khs-bait st) (let ((*kk-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (kh-delegate e b f kit s d st)))
          (t (kh-delegate e b f kit s d st)))))
