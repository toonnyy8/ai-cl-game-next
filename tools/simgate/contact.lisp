;;;; contact.lisp — what a neutral contact is worth (docs/duel/DUEL_AI_TEACHER.md §9): the outcome values the in-game MCTS's light model
;;;; scores a rollout with (cpu-mcts.lisp *MC-OUTCOMES*). One simgate process plays seeded gate matches like tools/simgate/run.lisp
;;;; (the CPUs as shipped). An exchange opens on the first contact after both fighters were out of every reel for *CT-QUIET* steps: the
;;;; defender starts a reel (a hit: stun, air, down) or a blockstun (a block), or the attacker's perfect Hoho counter lands; it closes when
;;;; both have been out of every reel for *CT-QUIET* steps again (or after *CT-MAX*). Its value is the health swing in the teacher's unit
;;;; (Konpaku + 1.5 x the Reishi bar's fraction: TEACH-HEALTH) from the attacker's side, the Kikons and the combo's whole route inside it.
;;;; Output: "contact character form class pointer outcome value" per exchange (class :na :ns :as :sa, :counter for a perfect Hoho's,
;;;; :none for anything else, e.g. a wave whose move is over).
;;;; Usage: ecl-host --norc --load tools/simgate/contact.lisp -- <duel.fas> <cmd>...   e.g. 30000 31110 2132 (IK seeds 1-10)
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)

(defparameter *ct-quiet* 20 "Steps both fighters stay out of every reel to open or close an exchange.")
(defparameter *ct-max* 900 "An exchange closes after this many steps whatever happens.")
(defun ct-reel-p (st) (member st '(:stun :air :down :wakeup :guard-hit :cine)))
(defun ct-health (e)
  (let ((g (gauges e))) (+ (gauges-konpaku g) (* 1.5 (/ (gauges-reishi g) (float (gauges-reishi-max g)))))))

(defvar *ct-quiet-n* 0)
(defvar *ct-open* nil "NIL, or (attacker key h-att h-def ticks) of the exchange in progress.")
(defvar *ct-prev* (vector :idle :idle))
(defvar *ct-n* 0)

(defun ct-close ()
  (destructuring-bind (a key ha hd n) *ct-open*
    (declare (ignore n))
    (let ((d (fighter-opp (fighter a))))
      (format t "contact ~{~(~s~) ~}~,4f~%" key (- (- hd (ct-health d)) (- ha (ct-health a))))
      (incf *ct-n*)))
  (setf *ct-open* nil *ct-quiet-n* 0))

(defun ct-hook ()
  (when (battle-p)
    (let ((es nil)) (do-sides (e) (push e es)) (setf es (nreverse es))
      (let ((reel (some (lambda (e) (ct-reel-p (fighter-state (fighter e)))) es)))
        (cond (*ct-open*
               (incf (fifth *ct-open*))
               (if reel (setf *ct-quiet-n* 0) (incf *ct-quiet-n*))
               (when (or (>= *ct-quiet-n* *ct-quiet*) (>= (fifth *ct-open*) *ct-max*)) (ct-close)))
              ((>= *ct-quiet-n* *ct-quiet*)
               (dolist (d es)
                 (let* ((fd (fighter d)) (st (fighter-state fd)) (side (fighter-side fd))
                        (a (fighter-opp fd)) (fa (fighter a)) (prev (svref *ct-prev* side)))
                   (when (and (not *ct-open*) (member st '(:stun :air :down :guard-hit)) (not (ct-reel-p prev)))
                     (let* ((mv (and (eq (fighter-state fa) :move) (fighter-move fa)))
                            (cls (cond ((and (eq (fighter-state fa) :hoho) (fighter-perfect fa)) :counter)
                                       (mv (or (kit-class (fighter-kit fa) mv) :none))
                                       (t :none))))
                       (setf *ct-open* (list a (list (fighter-character fa) (fighter-form fa) cls (fighter-ptr fa)
                                                     (if (eq st :guard-hit) :block :hit))
                                             (ct-health a) (ct-health d) 0)))))))
              (t (if reel (setf *ct-quiet-n* 0) (incf *ct-quiet-n*)))))
      (dolist (e es) (setf (svref *ct-prev* (fighter-side (fighter e))) (fighter-state (fighter e))))))
  (unless (battle-p) (setf *ct-open* nil *ct-quiet-n* 0)))

(cl-user::sg-init)
(setf *step-hook* #'ct-hook)
(cl-user::sg-queue)
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(format t "contacts ~d~%" *ct-n*)
(finish-output)
(ext:quit 0)
