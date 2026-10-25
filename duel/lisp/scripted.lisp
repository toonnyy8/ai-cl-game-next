;;;; scripted.lisp — the scripted players the sim calls (docs/duel/DUEL_LEARNING.md, docs/duel/DUEL_ASSIST.md): a CPU
;;;; brain with a habit (BRAIN-HABIT, set by the learning gate: gate.lisp *HABITS*, LEARN-GATE-SETUP) plays it from ai.lisp's
;;;; BRAIN-STEP / AI-DECIDE: HABIT-FIRE before the reflexes, HABIT-NEUTRAL at a neutral decision, DUMB-STEP (the button-masher,
;;;; ASSIST's gate) instead of the CPU's play. Loaded before ai.lisp; out of gate.lisp in refactor round 3 N10 (the user
;;;; 2026-10-21, docs/engine/REFACTOR_NEXT.md).
(in-package :duel)

(defparameter *dumb-delay* 24 "The button-masher sees as late as an EASY CPU (frames).")
(defparameter *dumb-guard-p* 0.5 "... and guards this share of the moves he sees coming.")

(defun habit-fire (e b s d)
  "A scripted player's habit before its reflexes (BRAIN-STEP): T when it pressed."
  (let* ((f (fighter e)) (g (gauges e)) (was (brain-was b))
         (hoho-ok (and (zerop (fighter-hoho-lock f)) (>= (gauges-fs g) *fs-hoho*))))
    (when (and (member (fighter-state f) '(:idle :guard :run)) (zerop (fighter-lock f)))
      (case (brain-habit b)
        (:wake-j (when (eq was :wakeup) (ai-press b :quick 1) (setf (brain-why b) :habit)))
        (:block-guard (when (eq was :guard-hit) (ai-press b :guard 40 :act :hold) (setf (brain-why b) :habit)))
        (:hoho (when (and hoho-ok (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker))
                          (< (snap-sf s) (snap-active-end s)) (< d (+ (snap-reach s) *ai-threat-margin*)))
                 (ai-press b :step 1 :modded t :act :hoho) (setf (brain-why b) :habit)))))))

(defvar *trial-script* nil
  "debug, the trial player (habit :trial, tools/combo-trial.py; the CPU work's step 2, skill duel-character-cpu \"Order\"):
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
  "The trial player (habit :trial): only *TRIAL-SCRIPT*'s presses, nothing of the CPU's play. T."
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

(defun dumb-step (e b s d)
  "The button-masher (habit :dumb, ASSIST's gate, docs/duel/DUEL_ASSIST.md): nothing of the CPU's play, only what a new player
does: hold U while a move of his comes, seen late (*DUMB-DELAY*) and only *DUMB-GUARD-P* of his moves, mash J (a press
every 8 f) within J1's reach, else walk at him.
Never a Step, Hoho, L, SP, Breaker, O, Burst or awakening of its own: those come from the assist (*ASSIST-DEBUG*). T."
  (let ((vp (pilot-vpad (pilot e))) (reach (mv-reach (kit-command-move (kit-of e) :q))))
    (setf (brain-press-left b) 0)                       ; every step decides afresh (a press lasts that step)
    (when (/= (snap-start s) (brain-roll-key b))        ; one guard roll per move of his
      (setf (brain-roll-key b) (snap-start s) (brain-guard-roll b) (sim-rnd01)))
    (cond ((and (eq (snap-state s) :move) (< (brain-guard-roll b) *dumb-guard-p*) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
                (< (snap-sf s) (snap-active-end s)) (< d (+ (snap-reach s) *ai-threat-margin*)))
           (ai-press b :guard 1 :act :guard))
          ((< d (+ reach 0.3)) (when (zerop (mod *match-tick* 8)) (ai-press b :quick 1)))
          (t (vpad-stick! vp 0f0 1f0)))
    (setf (brain-why b) :dumb)
    t))

(defun habit-neutral (e b kit d)
  "A scripted player's habit at a neutral decision (AI-DECIDE): T when it pressed."
  (let ((f (fighter e)) (g (gauges e)))
    (case (brain-habit b)
      (:grab (when (and (< d 2.6) (kit-command-ok-p e :breaker))
               (ai-command b kit :breaker d e) (setf (brain-why b) :habit)))
      (:hoho (when (and (< d 7.0) (zerop (fighter-hoho-lock f)) (>= (gauges-fs g) *fs-hoho*) (< (sim-rnd01) 0.5))
               (ai-command b kit :hoho d e) (setf (brain-why b) :habit))))))
