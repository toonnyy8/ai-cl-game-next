;;;; cpu-kh-ken.lisp — Kenpachi's style CPU against Hisagi (DUEL_AI_STRATEGY §8.19 round 5, step 5). KEN-KH-STYLE is a strategy's :fn (§9),
;;;; run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off by
;;;; default: only a strategy that names it plays it (the §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/khfn/. Cell b1_a1 (round 1): two codes by form (Ichigo's KI code sealed, his own released) under a wake-up bait.
(in-package :duel)

(defvar *khc-store* (make-hash-table :test 'eq) "Per brain: a KHC (the two codes' own match state, which cannot share BRAIN-STYLE, and the bait's).")
(defvar *khc-tick* 0 "The last MATCH-TICK seen by KEN-KH-STYLE (the store is cleared when it goes back: a new match).")

(defparameter *khc-sealed-forms* nil
  "Kenpachi's forms in which Ichigo's KI code plays (the others play his own KI code). Step 4: Ichigo's code took 0.95 of the live table's
judgements in his base form and none released. NIL (b1_a1 final) = his own code always: with the bait on, the split measured 0.688 vs 0.88.")
(defparameter *khc-bait-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Wake-up bait: per knockdown of Hisagi's (one roll as he goes down): do not press a meaty; stand at *KHC-BAIT-D* and wait. His CPU presses a
Hoho on its first free frame whenever Kenpachi is within 2.4 m, and a meaty J1 runs into a perfect Hoho. New 2026-11-09, b1_a1 (from b0_a0).")
(defparameter *khc-bait-d* 2.3 "Wake-up bait: the distance (m) held while he is down (inside his wake-up Hoho trigger, 2.4 m).")
(defparameter *khc-bait-after* 4
  "Wake-up bait: frames added to the brain's perception delay after the last perceived down / wake-up step during which Kenpachi still holds.")
(defparameter *khc-stale* '(:easy 2700 :normal 2100 :hard 1500)
  "Frames (by difficulty) with no Konpaku change on either side before the sealed form's patient code hands the step to his own KI code
until something lands (two waiting codes draw time-outs; b1_a0).")

(defstruct (khc (:constructor make-khc ()))
  (kks nil) (iks nil)           ; the two codes' states
  (hw :idle) (bait nil) (last -999 :type fixnum)
  (seen nil)                    ; stalemate clock: (tick konpaku0 konpaku1)
  (g nil) (gat 0 :type fixnum) (on nil)) ; stand-off clock: the four gauges then, the tick they last changed, the breaker on
(inline-readers khc)

(defun khc-run (b c fn slot e f kit s d)
  "Run FN with BRAIN-STYLE swapped to C's SLOT (:kks or :iks) state, and keep what it leaves there."
  (setf (brain-style b) (if (eq slot :kks) (khc-kks c) (khc-iks c)))
  (prog1 (funcall fn e b f kit s d)
    (if (eq slot :kks) (setf (khc-kks c) (brain-style b)) (setf (khc-iks c) (brain-style b)))))

(defun khc-stale-p (c b e f)
  (let ((k0 (gauges-konpaku (gauges e))) (k1 (gauges-konpaku (gauges (fighter-opp f)))))
    (unless (and (khc-seen c) (= k0 (second (khc-seen c))) (= k1 (third (khc-seen c))))
      (setf (khc-seen c) (list *match-tick* k0 k1)))
    (> (- *match-tick* (first (khc-seen c))) (getf *khc-stale* (brain-difficulty b) 600))))

(defun khc-bait-step (c e b f s d)
  "Hisagi down or just up with the bait roll yes: hold at *KHC-BAIT-D*. T when it decided."
  (let ((ss (snap-state s)) (now *match-tick*) (k (khc-kks c)))
    (when (and (member ss '(:air :down :wakeup)) (not (member (khc-hw c) '(:air :down :wakeup))))
      (setf (khc-bait c) (brain-roll b *khc-bait-p*)))
    (setf (khc-hw c) ss)
    (when (member ss '(:down :wakeup)) (setf (khc-last c) now))
    (when (and (khc-bait c) (member (fighter-state f) '(:idle :run)) (not (and k (kks-plan k))))
      (cond ((or (member ss '(:down :wakeup))
                 (and (not (eq ss :hoho)) (<= (- now (khc-last c)) (+ (brain-delay b) *khc-bait-after*))))
             (cond ((> d (+ *khc-bait-d* 0.15)) (kk-stick e 1)) ((< d (- *khc-bait-d* 0.3)) (kk-stick e -1)) (t (kk-stick e 0)))
             t)
            (t (setf (khc-bait c) nil) nil)))))

;; Stand-off breaker (from b2_a1): nothing has moved for a while and the bell is not his: lift the KI code's Hoho-safety hold.
(defparameter *khc-so-stale* '(:easy 900 :normal 540 :hard 120)
  "Stand-off breaker: frames with no change of either side's Reishi or Konpaku before the stand-off is old. New 2026-11-10, b1_a2 (from b2_a1).")

(defun khc-standoff-p (c b e f)
  "Tick the clock (any change of the four gauges restarts it); T when it is older than *KHC-SO-STALE* and the bell (Konpaku, then Reishi %) is not his."
  (let* ((g0 (gauges e)) (g1 (gauges (fighter-opp f)))
         (now (list (gauges-reishi g0) (gauges-reishi g1) (gauges-konpaku g0) (gauges-konpaku g1))))
    (unless (equal now (khc-g c)) (setf (khc-g c) now (khc-gat c) *match-tick*))
    (and (> (- *match-tick* (khc-gat c)) (getf *khc-so-stale* (brain-difficulty b) 300))
         (not (or (> (gauges-konpaku g0) (gauges-konpaku g1))
                  (and (= (gauges-konpaku g0) (gauges-konpaku g1)) (> (reishi-frac g0) (reishi-frac g1))))))))

;; Combo breaker (from b3_a0): reeling in a combo, once per combo, the awakening (gauge full) or the Burst.
(defparameter *khc-brk-p* '(:easy 0.0 :normal 0.3 :hard 1.0) "Combo breaker: chance (once per combo, at the reaction delay) of the awakening / Burst.")
(defparameter *khc-brk-fs* 200.0 "Combo breaker: the flash-step he must hold to Burst (the Burst costs 200).")
(defparameter *khc-brk-hits* 2 "Combo breaker: the combo hits he reels in before it is rolled.")

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

(defun khc-ken (b c e f kit s d)
  "His own KI code; with the stand-off old the Hoho-safety hold is off (and its approach re-rolled once at the onset)."
  (if (khc-standoff-p c b e f)
      (progn (unless (khc-on c) (setf (khc-on c) t)
               (when (kks-p (khc-kks c)) (setf (kks-appr (khc-kks c)) nil)))
             (let ((*kk-ns-safe-p* '(:easy 0.0 :normal 0.0 :hard 0.0)))
               (khc-run b c 'ken-ki-style :kks e f kit s d)))
      (progn (setf (khc-on c) nil) (khc-run b c 'ken-ki-style :kks e f kit s d))))

(defun ken-kh-style (e b f kit s d)
  "Kenpachi's style against Hisagi: T when it decided this step, NIL for the MCTS / the generic core CPU. A wake-up bait first; then
Ichigo's KI code while sealed (unless the match has stood still), his own KI code released."
  (when (< *match-tick* *khc-tick*) (clrhash *khc-store*))
  (setf *khc-tick* *match-tick*)
  (let ((c (or (gethash b *khc-store*) (setf (gethash b *khc-store*) (make-khc)))))
    (cond ((khc-break e b f) t)
          ((khc-bait-step c e b f s d) t)
          ((and (member (fighter-form f) *khc-sealed-forms*) (not (khc-stale-p c b e f)))
           (khc-run b c 'ichigo-ki-style :iks e f kit s d))
          ((khc-bait c) (let ((*kk-meaty-p* '(:easy 0.0 :normal 0.0 :hard 0.0))) (khc-ken b c e f kit s d)))
          (t (khc-ken b c e f kit s d)))))
