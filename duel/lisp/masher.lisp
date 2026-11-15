;;;; masher.lisp — the seeded random button-masher (亂按): the difficulty ladder's bottom rung, a test opponent only (debug 81030+s,
;;;; the native tools' STRAT_DIF_P<n>=masher; no menu entry). PLAN4 §5 (docs/research/strategy-drsi/sp/PLAN4.md), the user, 2026-11-15:
;;;; 「請設計讓勝率能做到 hard > normal > easy > 亂按，對上前一階難度的對手能獲得至少 70:30 的勝率」.
;;;; It is not a CPU tier: no perception, no MCTS, no strategy, no kit CPU help. One decision per press event, from three SIM-RND01
;;;; draws taken inside the step when the event starts: a button (or nothing) held 2-12 frames, every button up for the release step and
;;;; 0-10 idle frames after it (a press is a down edge: J then Mod+J with no step up between would be one press), and a stick held for the
;;;; whole event. Its state (the event's frames left, the stick; the button in the brain's PRESS slots, as AI-PRESS sets them for the core
;;;; CPU) lives in the brain, so a snapshot keeps it. The rates are pre-registered (PLAN4 §5): never tuned to pass a rung.
;;;;   (masher-pick u1 u2 u3 ready)   pure: NIL unless READY, else (button frames gap stick)
;;;;   (masher-next left draw)        pure: one step of the event clock -> (values pick-or-NIL left'); DRAW called 3 times per event only
;;;;   (masher-step e b)              the brain's step (CORE-BRAIN-STEP routes a masher brain here first)
;;;;   (masher-apply!)                *MASHER-SEATS* onto the live brains (START-MATCH; debug 81030+s)
(in-package :duel)

(defparameter *masher-buttons*
  '((:j 0.50 :quick nil) (:sp 0.15 :quick t) (:step 0.10 :step nil) (:hoho 0.07 :step t)
    (:burst 0.04 :awaken nil) (:awaken 0.04 :awaken t) (nil 0.10 nil nil))
  "The masher's buttons: (name chance vpad-action modded), *COMMANDS*' keys (J / Mod+J SP, Space Step / Mod+Space Hoho, P Burst / Mod+P
awaken), NIL = nothing pressed. Pre-registered (PLAN4 §5, 2026-11-15): never tuned.")
(defparameter *masher-sticks*
  '((:toward 0.55 0f0 1f0) (:away 0.15 0f0 -1f0) (:left 0.10 -1f0 0f0) (:right 0.10 1f0 0f0) (:neutral 0.10 0f0 0f0))
  "The masher's stick: (name chance strafe toward), relative to the opponent as every CPU's (CAM-RELATIVE NIL: VPAD-STICK! x = strafe,
-1 his left, y = toward). Pre-registered (PLAN4 §5).")
(defparameter *masher-hold* '(2 12) "Frames a press is held, uniform (PLAN4 §5).")
(defparameter *masher-gap* '(0 10) "Idle frames after the release step, uniform (PLAN4 §5).")

(defun masher-weighted (u table)
  "The entry of TABLE ((name chance ...) ...) that U in [0,1) falls in, by cumulative chance (the last one past rounding)."
  (let ((acc 0.0))
    (dolist (row table (car (last table)))
      (when (< u (incf acc (second row))) (return row)))))

(defun masher-pick (u1 u2 u3 ready)
  "One press event's decision from three uniforms in [0,1): (button frames gap stick) (button a *MASHER-BUTTONS* name, NIL = none; stick
a *MASHER-STICKS* name); NIL when not READY (no decision between events). U2 gives the hold and the gap together (k = floor(U2 n m)):
both uniform and independent."
  (when ready
    (destructuring-bind (h0 h1) *masher-hold*
      (destructuring-bind (g0 g1) *masher-gap*
        (let* ((nh (1+ (- h1 h0))) (ng (1+ (- g1 g0))) (k (min (1- (* nh ng)) (floor (* u2 nh ng)))))
          (list (first (masher-weighted u1 *masher-buttons*))
                (+ h0 (mod k nh)) (+ g0 (floor k nh))
                (first (masher-weighted u3 *masher-sticks*))))))))

(defun masher-next (left draw)
  "One step of the event clock, LEFT = the steps left in the event: (values NIL LEFT-1) inside one, else a new event: (values its pick,
frames + gap), the event lasting frames + 1 + gap steps (the hold, the release step, the idle). DRAW (a function of no argument
returning a uniform) is called three times per event and never otherwise."
  (if (> left 0)
      (values nil (1- left))
      (let ((p (masher-pick (funcall draw) (funcall draw) (funcall draw) t)))
        (values p (+ (second p) (third p))))))

(defun masher-step (e b)
  "Brain B's step as the masher: its event clock (MASHER-NEXT on SIM-RND01), a new event's press held through AI-PRESS (so it writes
the vpad as a CPU press does: AI-PRESS-WRITE!, Mod combos included), the event's stick. A brain switched off presses nothing."
  (let ((vp (pilot-vpad (pilot e))))
    (vpad-begin-step! vp)
    (if (brain-off b)
        (setf (brain-press-left b) 0 (brain-m-stick b) :neutral)
        (multiple-value-bind (p left) (masher-next (brain-m-left b) (lambda () (sim-rnd01)))
          (setf (brain-m-left b) left)
          (if p
              (let ((row (assoc (first p) *masher-buttons*)))
                (setf (brain-m-stick b) (fourth p))
                (if (third row)
                    (ai-press b (third row) (second p) :modded (fourth row) :act :mash)
                    (setf (brain-press-left b) 0)))
              (when (> (brain-press-left b) 0) (decf (brain-press-left b))))))
    (ai-press-write! b vp)
    (let ((st (assoc (brain-m-stick b) *masher-sticks*)))
      (vpad-stick! vp (if st (third st) 0f0) (if st (fourth st) 0f0)))))

;;; ---------------------------------------------------------------- selection
(defvar *masher-seats* nil "Debug 81030+s: the seats (0 P1, 1 P2) whose CPU is the masher from START-MATCH on; NIL none (every menu match).")

(defun masher-apply! ()
  "*MASHER-SEATS* onto both fighters' brains (a seat without a brain, a human's, stays human), their event clocks afresh; one log line
when a masher plays (none otherwise)."
  (do-sides (e)
    (let ((b (brain e)) (on (member (fighter-side (fighter e)) *masher-seats*)))
      (when b
        (setf (brain-masher b) (and on t) (brain-m-left b) 0 (brain-press-left b) 0)
        (when on (log-msg "duel masher ~a" (side-name e)))))))

(define-debug-range (81030 81033) (c)
  (setf *masher-seats* (nth (- c 81030) '((0) (1) (0 1) nil)))
  (when (and *p1* *p2*) (masher-apply!)))
