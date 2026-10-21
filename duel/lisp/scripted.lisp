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
