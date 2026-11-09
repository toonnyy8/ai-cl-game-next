;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it. Written by the dream-rsi search in docs/research/strategy-drsi/khfn/.
;;;; Cell b2_a2 (round 1): three orthogonal disciplines around his KI code, each for one state of Hisagi's game:
;;;;  - knocked down: a wake-up BAIT (hold at 2.3 m, no meaty; his CPU Hohos on its first free frame; b0_a0);
;;;;  - reeling in his combo: pay the escape once per combo, awakening else Burst (b3_a0);
;;;;  - an old stand-off (nothing moved for 2 s and the bell is not his): lift the Hoho-safety hold and attack (b2_a1).
(in-package :duel)

(defvar *khc-store* (make-hash-table :test 'eq) "Per brain: a KHC (the bait's and the stand-off clock's state; BRAIN-STYLE stays ken-ki-style's).")
(defvar *khc-tick* 0 "The last MATCH-TICK seen by KEN-KH-STYLE (the store is cleared when it goes back: a new match).")

(defparameter *khc-bait-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Wake-up bait: per knockdown of Hisagi's (one roll as he goes down): do not press a meaty; stand at *KHC-BAIT-D* and wait. His CPU presses a
Hoho on its first free frame whenever Kenpachi is within 2.4 m, and a meaty J1 runs into a perfect Hoho. New 2026-11-10, b2_a2 (from b0_a0).")
(defparameter *khc-bait-d* 2.3 "Wake-up bait: the distance (m) held while he is down (inside his wake-up Hoho trigger, 2.4 m).")
(defparameter *khc-bait-after* 4
  "Wake-up bait: frames added to the brain's perception delay after the last perceived down / wake-up step during which Kenpachi still holds.")
(defparameter *khc-brk-p* '(:easy 0.0 :normal 0.3 :hard 1.0) "Combo breaker: chance (once per combo, at the reaction delay) of the awakening / Burst.")
(defparameter *khc-brk-fs* 200.0 "Combo breaker: the flash-step he must hold to Burst (the Burst costs 200).")
(defparameter *khc-brk-hits* 2 "Combo breaker: the combo hits he reels in before it is rolled.")
(defparameter *khc-stale* '(:easy 900 :normal 540 :hard 120)
  "Stand-off breaker: frames (by difficulty) with no change of either side's Reishi or Konpaku before the stand-off is old (from b2_a1).")

(defstruct (khc (:constructor make-khc ()))
  (hw :idle) (bait nil) (last -999 :type fixnum)
  (at 0 :type fixnum) (r0 0.0 :type single-float) (r1 0.0 :type single-float) (k0 0 :type fixnum) (k1 0 :type fixnum)
  (on nil))
(inline-readers khc)

(defun khc-bait-step (c e b f s d)
  "Hisagi down or just up with the bait roll yes: hold at *KHC-BAIT-D*. T when it decided."
  (let ((ss (snap-state s)) (now *match-tick*) (k (brain-style b)))
    (when (and (member ss '(:air :down :wakeup)) (not (member (khc-hw c) '(:air :down :wakeup))))
      (setf (khc-bait c) (brain-roll b *khc-bait-p*)))
    (setf (khc-hw c) ss)
    (when (member ss '(:down :wakeup)) (setf (khc-last c) now))
    (when (and (khc-bait c) (member (fighter-state f) '(:idle :run)) (not (and (kks-p k) (kks-plan k))))
      (cond ((or (member ss '(:down :wakeup))
                 (and (not (eq ss :hoho)) (<= (- now (khc-last c)) (+ (brain-delay b) *khc-bait-after*))))
             (cond ((> d (+ *khc-bait-d* 0.15)) (kk-stick e 1)) ((< d (- *khc-bait-d* 0.3)) (kk-stick e -1)) (t (kk-stick e 0)))
             t)
            (t (setf (khc-bait c) nil) nil)))))

(defun khc-break (e b f)
  (when (and (member (fighter-state f) '(:stun :air)) (zerop (fighter-kikon-lock f)) (>= (brain-burst-t b) (brain-delay b))
             (not (brain-burst-rolled b)) (>= (fighter-combo-hits f) *khc-brk-hits*))
    (setf (brain-burst-rolled b) t)
    (let ((g (gauges e)))
      (cond ((and (not (gauges-awakened g)) (>= (gauges-awaken g) *awaken-max*) (not (getf (kit-core (fighter-kit f)) :no-awaken))
                  (brain-roll b *khc-brk-p*))
             (ai-press b :awaken 1 :modded t) t)
            ((and (>= (gauges-fs g) *khc-brk-fs*) (burst-ok-p e) (brain-roll b *khc-brk-p*))
             (ai-press b :awaken 1) t)))))

(defun khc-old-p (c e b f)
  "Tick the clock (any change of the four gauges restarts it); T when the stand-off is older than *KHC-STALE* and the bell is not his."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (r0 (f32 (gauges-reishi g0))) (r1 (f32 (gauges-reishi g1))) (k0 (gauges-konpaku g0)) (k1 (gauges-konpaku g1)))
    (unless (and (= r0 (khc-r0 c)) (= r1 (khc-r1 c)) (= k0 (khc-k0 c)) (= k1 (khc-k1 c)))
      (setf (khc-r0 c) r0 (khc-r1 c) r1 (khc-k0 c) k0 (khc-k1 c) k1 (khc-at c) *match-tick*))
    (and (> (- *match-tick* (khc-at c)) (getf *khc-stale* (brain-difficulty b) 300))
         (not (or (> k0 k1) (and (= k0 k1) (> (reishi-frac g0) (reishi-frac g1))))))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (when (< *match-tick* *khc-tick*) (clrhash *khc-store*))
  (setf *khc-tick* *match-tick*)
  (let* ((c (or (gethash b *khc-store*) (setf (gethash b *khc-store*) (make-khc))))
         (old (khc-old-p c e b f)))
    (cond ((khc-break e b f) t)
          ((khc-bait-step c e b f s d) t)
          (old (unless (khc-on c)
                 (setf (khc-on c) t)
                 (let ((k (brain-style b))) (when (kks-p k) (setf (kks-appr k) nil))))
               (let ((*kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 0.0)))
                 (ken-ki-style e b f kit s d)))
          (t (setf (khc-on c) nil)
             (if (khc-bait c)
                 (let ((*kk-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (ken-ki-style e b f kit s d))
                 (ken-ki-style e b f kit s d))))))
