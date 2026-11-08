;;;; oppmodel.lisp — what fighters actually do when free, by situation (docs/duel/DUEL_AI_MCTS.md §9): the counts the light model's opponent
;;;; model is baked from (tools/mc-oppmodel.py -> mcts-lite.lisp *MC-OPP-MODEL*). One simgate process plays seeded gate matches (the CPUs as
;;;; shipped); every decision of a free (idle / running) fighter is classed as one of the ten macro actions: an NA started -> j1, an NS -> sp,
;;;; a Hoho, a guard, a Step (in / out / side by the distance it changed over its hop), and while he stays free, every 20 steps: walk-in /
;;;; walk-out / wait by the distance's change (0.5 m). The situation: the distance band (< 2 / 4 / 7 m / beyond) and the opponent's state
;;;; class (0 free, guarding; 1 a move's startup; 2 its active or recovery frames; 3 a Step or Hoho; 4 reeling, down, waking, blockstun).
;;;; Output: "opp character band state action" per decision. Usage: ecl-host --norc --load tools/simgate/oppmodel.lisp -- <duel.fas> <cmd>...
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defun om-band (d) (cond ((< d 2.0) 0) ((< d 4.0) 1) ((< d 7.0) 2) (t 3)))
(defun om-class (fo)
  (case (fighter-state fo)
    ((:idle :run :guard) 0)
    (:move (let ((mv (fighter-move fo))) (if (and mv (< (fighter-sf fo) (mv-s mv))) 1 2)))
    ((:step :hoho) 3)
    (t 4)))
(defvar *om* (vector nil nil) "Per side: (state-was free-ticks d0 band class step-d0) bookkeeping.")
(defvar *om-n* 0)
(defun om-out (f band cls action) (incf *om-n*) (format t "opp ~(~a~) ~d ~d ~(~a~)~%" (fighter-character f) band cls action))

(defun om-hook ()
  (when (battle-p)
    (do-sides (e)
      (let* ((f (fighter e)) (side (fighter-side f)) (fo (fighter (fighter-opp f))) (st (fighter-state f)) (d (fighter-dist f))
             (m (or (svref *om* side) (setf (svref *om* side) (list :idle 0 d 0 0 nil)))))
        (destructuring-bind (was n d0 band cls sd0) m
          (when (and (eq was :step) (not (eq st :step)) sd0)                                       ; a Step's end: which way it went
            (destructuring-bind (sd sb sc) sd0
              (om-out f sb sc (cond ((< (- d sd) -0.8) :step-in) ((> (- d sd) 0.8) :step-out) (t :step-side))))
            (setf sd0 nil))
          (let ((free (member st '(:idle :run))) (wfree (member was '(:idle :run))))
            (cond ((and free (not wfree)) (setf n 0 d0 d band (om-band d) cls (om-class fo)))     ; came free: a new window
                  (free (incf n)
                        (when (>= n 20)
                          (om-out f band cls (cond ((< (- d d0) -0.5) :walk-in) ((> (- d d0) 0.5) :walk-out) (t :wait)))
                          (setf n 0 d0 d band (om-band d) cls (om-class fo))))
                  (wfree                                                                            ; left the free state: what for
                   (case st
                     (:move (let ((c (kit-class (fighter-kit f) (fighter-move f))))
                              (case c (:na (om-out f band cls :j1)) (:ns (om-out f band cls :sp)))))
                     (:hoho (om-out f band cls :hoho))
                     (:guard (om-out f band cls :guard))
                     (:step (setf sd0 (list d band cls)))))))
          (setf (svref *om* side) (list st n d0 band cls sd0)))))))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'om-hook)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 4000000 do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(format t "oppmodel ~d decisions~%" *om-n*)
(finish-output)
(ext:quit 0)
