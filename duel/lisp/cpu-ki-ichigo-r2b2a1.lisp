;;;; cpu-ki-ichigo-r2b2a1.lisp — dream-rsi KI round 2, Ichigo's cell b2_a1 (docs/research/strategy-drsi/sp, ki-I): a strategy arm's style
;;;; (:fn ichigo-ki-r2b2a1-style) built on ICHIGO-KI-STYLE. Nothing registers it as a matchup style; only an arm naming it plays it.
;;;; Three pieces over ICHIGO-KI-STYLE, answers to Kenpachi's round-1 champion (c-ki-k-r1-b2a2):
;;;;  1. The wake-up roll. About half his damage opened with his meaty J1 on her wake-up (KK-MEATY-STEP: he waits at *KK-MEATY-MIN*
;;;;     2.25-2.4 m, out of IKS-WAKE's 2.2 m Hoho, and lands J1 on her first free frame; then J2 AS1, the knockdown again). The wake-up roll
;;;;     (fighter.lisp AIR-STEP: the stick held as :down ends slides her *ROLL-DISTANCE* 4 m that way, invulnerable) takes her out of it; no
;;;;     CPU used it. On each knockdown of hers, one roll (:ikw-roll-p), and the stick held at (:ikw-roll-x strafe, :ikw-roll-y toward) through
;;;;     her :down, so the roll fires as it ends. Rolled forward-diagonally (0.7, 0.7) she ends ~2.9 m off at his flank: he still presses the
;;;;     meaty J1 (his view of her is 8 frames old), it whiffs, and her whiff punish (IKS-PUNISH, NS3a at pointer 3) lands into AS3. The
;;;;     angle is narrow: 40 / 50 degrees off toward measured well under 45 (cell b2_a1's proposal).
;;;;  3. The stale breaker (IKW-STALE-P): no Reishi / Konpaku change for :ikw-stale frames hands her free steps to the generic CPU.
;;;;  2. The shut-gauge lunge (IKS-GAP) turned off for the match once he is seen to back-Step it from far: his *KK-STEP-MAX* 7 m Step answers
;;;;     a lunge pressed at a perceived 6.3 m+ (his read 5.1-5.2), which *IKS-GAP-BAND* was built to clear for 5.0 m. Counted per lunge pressed
;;;;     at >= :ikw-gap-far with his Step seen within *IKW-GAP-WATCH* frames; at :ikw-gap-off-n such the style runs on the arm with
;;;;     :iks-gap-p 0 in front (an opponent whose Step stops at 5.0 m never trips it and keeps the lunge).
(in-package :duel)

(defparameter *ikw-roll-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "Per knockdown of hers (one roll as she goes down): hold the stick through :down so she rolls on waking (AIR-STEP), out of his meaty.")
(defparameter *ikw-roll-x* 0.0 "The wake-up roll's stick, strafe part (-1 .. 1).")
(defparameter *ikw-roll-y* -1.0 "The wake-up roll's stick, toward part (-1 away .. 1 toward him: through him, behind his back).")
(defparameter *ikw-gap-far* 6.3
  "A shut-gauge lunge pressed at this perceived distance (m) or more is one his read meets beyond 5.0 m (he walks in 2 x 8 frames of
0.07 m in between): a back Step on it means his Step reaches past *KK-STEP-MAX*'s 5.0.")
(defparameter *ikw-gap-watch* 30 "Frames after such a lunge in which his Step seen counts it.")
(defparameter *ikw-gap-off-n* 2 "Lunges so answered before the shut-gauge lunge is off for the match (0: never off).")
(defparameter *ikw-stale* 600
  "Frames with no Reishi / Konpaku change on either side after which her free steps go to the generic CPU (IKS-GENERIC: it walks in and
starts moves) until one changes: the patient hover against a Kenpachi waiting on his Hoho-safety froze matches at a lead (0: never).")

(defstruct (ikw (:include ikst) (:constructor make-ikw ()))
  "ICHIGO-KI-R2B2A1-STYLE's state: ICHIGO-KI-STYLE's IKST (it runs on it unchanged) plus the wake-up roll's and the lunge watch's."
  (roll nil)                             ; this knockdown's roll: NIL unmade, :go, :no
  (lunge-t -999 :type fixnum)            ; the tick of her last far shut-gauge lunge (-999: none watched)
  (stepped 0 :type fixnum)               ; far lunges he back-Stepped
  (alt nil)                              ; the arm with :iks-gap-p 0 in front, once the lunge is off
  (cell (cons nil nil))                  ; BRAIN-NOW's stand-in while ALT plays (reused: 0 B a step)
  (rsig -1 :type fixnum) (ksig -1 :type fixnum)   ; both Reishi, both Konpaku as last seen
  (still-t 0 :type fixnum))              ; the tick either last changed
(inline-readers ikw)

(defun ikw-roll-step (b f st vp)
  "Her knockdown: the roll's chance once as she goes down, then the stick held through :down (its end reads it). Cleared once she is up."
  (case (fighter-state f)
    ((:air :down)
     (unless (ikw-roll st) (setf (ikw-roll st) (if (style-roll b :ikw-roll-p *ikw-roll-p*) :go :no)))
     (when (and (eq (ikw-roll st) :go) (eq (fighter-state f) :down))
       (vpad-stick! vp (style-knob b :ikw-roll-x *ikw-roll-x*) (style-knob b :ikw-roll-y *ikw-roll-y*))))
    (:wakeup nil)
    (t (setf (ikw-roll st) nil))))

(defun ikw-gap-watch (e b st s d)
  "After ICHIGO-KI-STYLE's step: a far lunge pressed now starts the watch; his Step seen inside it counts one; at :ikw-gap-off-n the
lunge goes off (IKW-ALT)."
  (cond ((and (> (brain-press-left b) 0) (eq (brain-press b) :quick) (brain-press-mod b) (member (ikst-plan st) '(:lunge :k-lunge))
              (>= d (style-knob b :ikw-gap-far *ikw-gap-far*)))
         (setf (ikw-lunge-t st) *match-tick*))
        ((and (eq (snap-state s) :step) (<= (- *match-tick* (ikw-lunge-t st)) *ikw-gap-watch*))
         (setf (ikw-lunge-t st) -999)
         (incf (ikw-stepped st))
         (let ((n (style-knob b :ikw-gap-off-n *ikw-gap-off-n*)) (arm (car (brain-now b))))
           (when (and (null (ikw-alt st)) (plusp n) (>= (ikw-stepped st) n) arm)
             (setf (ikw-alt st) (list* :base (list* :iks-gap-p 0.0 (getf arm :base)) arm))   ; (the first :base / key wins: GETF)
             (clog "~a ki-style gap off d ~,1f" (side-name e) d))))))

(defun ikw-stale-p (e b f st)
  "Track both Reishi and Konpaku; T when none changed for :ikw-stale frames."
  (let* ((g (gauges e)) (og (gauges (fighter-opp f)))
         (r (+ (* 2048 (gauges-reishi g)) (gauges-reishi og))) (k (+ (* 16 (gauges-konpaku g)) (gauges-konpaku og)))
         (n (style-knob b :ikw-stale *ikw-stale*)))
    (unless (and (= r (ikw-rsig st)) (= k (ikw-ksig st)))
      (setf (ikw-rsig st) r (ikw-ksig st) k (ikw-still-t st) *match-tick*))
    (and (plusp n) (> (- *match-tick* (ikw-still-t st)) n))))

(defun ichigo-ki-r2b2a1-style (e b f kit s d)
  "ICHIGO-KI-STYLE (on the gap-off arm once IKW-GAP-WATCH says so) plus the wake-up roll (IKW-ROLL-STEP); a stale neutral goes to the
generic CPU (IKW-STALE-P). T when it decided."
  (let ((st (let ((x (brain-style b))) (if (ikw-p x) x (setf (brain-style b) (make-ikw)))))   ; (only its own IKW: another style's struct
        (state (fighter-state f)))                                                          ;  starts afresh, as IR2-P / HMS-P do)
    (when (and (ikw-alt st) (brain-now b))
      (let ((c (ikw-cell st)))
        (setf (car c) (ikw-alt st) (cdr c) (cdr (brain-now b)) (brain-now b) c)))
    (prog1 (if (and (ikw-stale-p e b f st) (member state '(:idle :run)))
               (progn (iks-generic e b f kit s d)                 ; (ICHIGO-KI-STYLE's tail bookkeeping, as it would)
                      (setf (ikst-last-st st) state (ikst-last-reishi st) (gauges-reishi (gauges e)) (ikst-last-d st) d)
                      t)
               (ichigo-ki-style e b f kit s d))
      (ikw-gap-watch e b st s d)
      (ikw-roll-step b f st (pilot-vpad (pilot e))))))
