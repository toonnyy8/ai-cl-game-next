;;;; scripted.lisp — the trial player (tools/simgate/trial.lisp, tools/combo-trial.py: the CPU work's combo trials) and the
;;;; learning gate's masher delay (gate.lisp). The habit players the old AI ran (HABIT-FIRE, HABIT-NEUTRAL, DUMB-STEP) left with it
;;;; on 2026-11-12 (REFACTOR_2026-11 R3): a :core kit's CPU never read a habit. Out of gate.lisp in refactor round 3 N10.
(in-package :duel)

(defparameter *dumb-delay* 24 "The learning gate's button-masher sees as late as an EASY CPU (frames; gate.lisp LEARN-GATE-SETUP).")
(defvar *trial-script* nil
  "debug, the trial player (tools/simgate/trial.lisp drives it, tools/combo-trial.py; the CPU work's step 2, skill duel-character-cpu \"Order\"):
its presses in order, each (button frames &key modded wait on stick): BUTTON held FRAMES steps (:walk: no button), the stick
STICK toward him meanwhile (1 forward, -1 back); the next press waits until this one
started a new move (or *TRIAL-GIVE-UP* steps), then WAIT more steps; ON :hit until that new move has hit, ON :free until
she can act (neutral).")
(defvar *trial-state* nil "... (next-index held-left wait-left move-at-press steps-since-press current-press), TRIAL-RESET.")
(defparameter *trial-give-up* 90 "... a press that starts nothing lets the next go after this many steps.")
(defun trial-reset (script)
  (setf *trial-script* script *trial-state* (list 0 0 (getf (cddr (first script)) :wait 0) :none 0 nil)))
(defun trial-press (e b p)
  "One step of trial press P: its button (none for :walk) and its stick."
  (unless (eq (first p) :walk) (ai-press b (first p) 1 :modded (getf (cddr p) :modded) :act :hold))
  (vpad-stick! (pilot-vpad (pilot e)) 0f0 (f32 (getf (cddr p) :stick (if (eq (first p) :walk) 1.0 0.0)))))
(defun trial-step (e b)
  "The trial player: only *TRIAL-SCRIPT*'s presses, nothing of the CPU's play. T."
  (destructuring-bind (i held wait at since cur) *trial-state*
    (let* ((f (fighter e)) (mv (and (eq (fighter-state f) :move) (fighter-move f))) (p (nth i *trial-script*)))
      (setf (brain-press-left b) 0)
      (vpad-stick! (pilot-vpad (pilot e)) 0f0 0f0)
      (incf since)
      (cond ((plusp held) (decf held) (trial-press e b cur))
            ((and p (or (null cur) (> since (second cur)))                        ; (a step released: a new press)
                  (or (and (> since *trial-give-up*) (not (getf (cddr p) :on)))   ; (an :on waits as long as it takes)
                      (case (getf (cddr p) :on)
                        (:hit (and (not (eq mv at)) (eq (fighter-contact f) :hit)))   ; its move landed: a cancel
                        (:free (member (fighter-state f) '(:idle :guard :run)))      ; she is neutral again
                        (t (or (zerop i) (not (eq mv at)))))))                    ; the last press started its move
             (if (plusp wait)
                 (decf wait)
                 (progn (trial-press e b p)
                        (clog "~a press ~(~a~)~:[~; mod~] x~d (~(~a~))" (side-name e) (first p) (getf (cddr p) :modded) (second p)
                              (fighter-state f))
                        (setf held (1- (second p)) cur p at mv since 0 i (1+ i)
                              wait (getf (cddr (nth i *trial-script*)) :wait 0))))))
      (setf *trial-state* (list i held wait at since cur))))
  (setf (brain-why b) :trial)
  t)
