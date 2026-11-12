;;;; cpu-perceive.lisp — what every CPU player (the core CPU, core-ai.lisp, and the matchup style CPUs) shares: its delayed
;;;; perception of the opponent (a ring of SNAPs; reaction time is the difficulty: EASY 24, NORMAL 14, HARD 8 frames), the
;;;; readers over a SNAP, and its button presses (the brain's held press, written to its vpad by CORE-BRAIN-STEP). Every random
;;;; number comes from SIM-RND01: a seed replays the same match. Out of ai.lisp on 2026-11-12 (REFACTOR_2026-11 R3): the old AI
;;;; v2 (the generic reflex / intent / decide stack the retired kits played) left with them; what only the frozen ASSIST and old
;;;; learner still called (AI-COMMAND, STRING-REFLEX, AI-TABLE / *AI-STEPS*, RANGED-THREAT-IN ...) left with those on 2026-11-13 (R4).
(in-package :duel)

;;; (EXPT X 2) without boxing, beside fighter.lisp's zero-cons twins (here: fighter.lisp is loaded by the host tests, and the
;;; interpreter can't take FFI:CLINES)
(ffi:clines "static float duel_expt2(float x) { volatile float two = 2.0f; return x == 0.0f ? x * 2.0f : powf(x, two); }")
(defmacro %expt2 (x)
  "CL's (EXPT X 2) of a single-float as ECL computes it: X x 2 for a zero (ecl_times), else powf (X, 2.0) (ecl_expt_float;
the volatile 2 keeps the C compiler from turning it into X*X, which powf need not equal)."
  `(ffi:c-inline (,x) (:float) :float "duel_expt2(#0)" :one-liner t))

(defstruct snap
  "What the CPU sees of its opponent at one step."
  (x 0f0 :type single-float) (z 0f0 :type single-float)
  (state :idle) (kind nil) (phase nil)
  (sf 0 :type fixnum) (s 0 :type fixnum) (active-end 0 :type fixnum)
  (left 0 :type fixnum)                 ; frames left of his move (99 = still charging / dashing) or stun
  (start 0 :type fixnum)                ; tick his current move / guard began (one roll per event)
  (reach 0f0 :type single-float)
  (flags nil)                           ; his move's :flags (:parry :bind ...)
  (contact nil)                         ; what his move touched so far (NIL = nothing yet: a whiff when it ends)
  (move nil))
(inline-readers snap)                           ; his move (NIL: none): its volumes, params (SNAP-NEAR-P ...)

(defun snap-take! (s o)
  "Fill SNAP S with fighter O as he is now."
  (let* ((f (fighter o)) (p (pos-of o)) (mv (fighter-move f)) (st (fighter-state f)))
    (sim-fast (let* ((q p)) (declare (type f32vec q)) (%set-float (snap-x s) (aref q 0)) (%set-float (snap-z s) (aref q 2))))
    (setf (snap-state s) st (snap-sf s) (fighter-sf f))
    (if (and (eq st :move) mv)
        (let ((total (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) (fighter-contact f)
                                     (zerop (length (mv-hits mv))) (mv-kind mv))))
          (setf (snap-kind s) (mv-kind mv) (snap-phase s) (fighter-phase f) (snap-s s) (mv-s mv) (snap-flags s) (mv-flags mv)
                (snap-contact s) (fighter-contact f)
                (snap-active-end s) (+ (mv-s mv) (mv-a mv)) (snap-reach s) (f32 (mv-reach mv))
                (snap-left s) (if (eq (fighter-phase f) :main) (max 0 (- total (fighter-sf f))) 99)
                (snap-start s) (- *match-tick* (fighter-sf f) (fighter-hold f))
                (snap-move s) mv))
        (setf (snap-kind s) nil (snap-phase s) nil (snap-reach s) 0f0 (snap-flags s) nil (snap-contact s) nil (snap-move s) nil
              (snap-left s) (if (eq st :stun) (max 0 (- (fighter-stun f) (fighter-sf f))) 0)
              (snap-start s) (if (eq st :guard) (- *match-tick* (fighter-guard-t f)) -1)))
    s))

(defun snap-live-p (s)
  "Is his perceived move S still to hit: before the end of its active frames?"
  (< (snap-sf s) (snap-active-end s)))

(defun snap-recovering-p (s)
  "Is he, as perceived, recovering from a move (its main phase past its active frames)?"
  (and (eq (snap-state s) :move) (eq (snap-phase s) :main) (>= (snap-sf s) (snap-active-end s))))
(defun snap-punishable-p (s)
  "Is he, as perceived, recovering (SNAP-RECOVERING-P) or reeling?"
  (or (snap-recovering-p s) (eq (snap-state s) :stun)))
(defun snap-left-seen (s b) "His frames left as perceived S, less brain B's perception delay." (- (snap-left s) (brain-delay b)))
(defun snap-lead-seen (s b)
  "Frames from his perceived frame (S) to his move's first active frame, less brain B's perception delay."
  (- (snap-s s) (snap-sf s) (brain-delay b)))

(defun snap-seg-gap (s e)
  "How far E's feet are from his perceived move's :seg-fn capsules (kit.lisp SEG-GAP: their segment as his kit gives it now,
radius off), or NIL: no window of it has one (every move but those: the reach test, unchanged)."
  (let ((mv (snap-move s)) (p (pos-of e)))
    (and mv (seg-gap mv (opp-of e) (aref p 0) (aref p 2)))))

(defun snap-near-p (s e d margin)
  "Is E, at the perceived distance D, in reach of his perceived move S: D < its reach + MARGIN (a :seg-fn window: E's feet
within its capsule + E's hurt radius + MARGIN, SNAP-SEG-GAP)?"
  (let ((g (snap-seg-gap s e)))
    (if g (< g (+ (body-hurt-r (model-body (model e))) margin)) (< d (+ (snap-reach s) margin)))))

;;; ---------------------------------------------------------------- pressing buttons
(defun ai-press (b button frames &key modded (act button))
  "Hold BUTTON (with :MOD when MODDED) for FRAMES steps, starting now."
  (setf (brain-press b) button (brain-press-mod b) modded (brain-press-left b) (max 1 frames) (brain-act b) act))

(defun ai-dash (b dir to)
  "Hold Step (the hop, then the run) with the stick toward (DIR 1) or away from (-1) the opponent,
until the distance passes TO (CORE-BRAIN-STEP lets go)."
  (ai-press b :step *ai-dash-frames* :act :dash)
  (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to)))

(defun ai-event-rolls (b s)
  "One roll per opponent action (his SNAP S starts a new one): brain B's guard / Hoho / reaction rolls."
  (when (/= (snap-start s) (brain-roll-key b))
    (setf (brain-roll-key b) (snap-start s) (brain-guard-roll b) (sim-rnd01) (brain-hoho-roll b) (sim-rnd01)
          (brain-react-roll b) (sim-rnd01))))

(defun ai-strafe (e b)
  "The strafe's next side and how long it lasts (*AI-STRAFE-TIME*)."
  (declare (ignore e))
  (setf (brain-strafe-t b) (+ (first *ai-strafe-time*) (floor (* (second *ai-strafe-time*) (sim-rnd01))))
        (brain-strafe b) (if (< (sim-rnd01) 0.5) -1f0 1f0)))

(defun ai-walk (e b vp d lo hi)
  "The stick toward the range LO..HI, strafing inside it."
  (declare (ignore e))
  (vpad-stick! vp (if (<= lo d hi) (brain-strafe b) (* 0.3 (brain-strafe b)))
               (cond ((> d hi) 1f0) ((< d lo) -1f0) (t 0f0))))

;;; ---------------------------------------------------------------- perception
(defun brain-perceive (e b o)
  "Brain B of E sees opponent O this step: his SNAP goes into the ring; values the SNAP of BRAIN-DELAY steps ago and the
distance to it."
  (let* ((ring (brain-ring b)) (n (length ring))
         (cur (or (svref ring (brain-head b)) (setf (svref ring (brain-head b)) (make-snap)))))
    (snap-take! cur o)
    (let* ((s (or (svref ring (mod (- (brain-head b) (brain-delay b)) n)) cur))
           (p (pos-of e))
           (d (sim-fast                                     ; (SQRT of two EXPT 2s, as twins: bit-identical, no boxing)
                (let* ((sx (snap-x s)) (sz (snap-z s)) (q p))
                  (declare (single-float sx sz) (type f32vec q))
                  (let* ((v (%sqrt (+ (%expt2 (- sx (aref q 0))) (%expt2 (- sz (aref q 2)))))))
                    (declare (single-float v))
                    v)))))
      (setf (brain-head b) (mod (1+ (brain-head b)) n))
      (when (and (eq (snap-state s) :move) (eq (snap-kind s) :quick) (/= (snap-start s) (brain-jkey b)))   ; a J of his begins
        (setf (brain-jkey b) (snap-start s))
        (push *match-tick* (brain-jstarts b)))
      (when (brain-jstarts b)                               ; only the window's
        (setf (brain-jstarts b) (drop-old-jstarts (brain-jstarts b) *match-tick* *ai-mash-window*)))
      (values s d))))

(defun drop-old-jstarts (l now window)
  "(DELETE-IF (LAMBDA (T0) (> (- NOW T0) WINDOW)) L) without its closure and scratch cons: the ticks of L within WINDOW of
NOW, in order (L destroyed)."
  (loop while (and l (> (- now (car l)) window)) do (setf l (cdr l)))
  (when l
    (let ((prev l))
      (loop for c = (cdr prev) while c
            do (if (> (- now (car c)) window) (setf (cdr prev) (cdr c)) (setf prev c)))))
  l)

(defun ai-mash-p (b)
  "Is he mashing J, as brain B saw him: *AI-MASH-STARTS* J starts within *AI-MASH-WINDOW* frames?"
  (>= (length (brain-jstarts b)) *ai-mash-starts*))

(defun brain-system ()
  "Every CPU fighter decides this step (before FIGHTER-SYSTEM reads the vpads): the core CPU (core-ai.lisp CORE-BRAIN-STEP;
every playing kit has a :core)."
  (do-entities (e (b brain) (f fighter)) (core-brain-step e b)))
