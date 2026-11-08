;;;; fulltest.lisp — the in-game full-sim rollouts leave nothing behind (docs/duel/DUEL_AI_MCTS.md §12): at every step end where a CPU's
;;;; job has its snapshot, an extra rollout of a copy of the job runs the way MC-FULL-STEP runs one (the live state snapshotted, the
;;;; rollout, the live state put back), and a digest is compared before and after: the state hash line plus every DUEL / ENGINE special
;;;; variable holding a number, symbol, character, string or a short float / fixnum vector (so state outside the snapshot roots, like the
;;;; view's *VIEW-X*, shows). Env FT_VS=1: the match is VS CPU (debug 2500-2503: human P1, idle) with P2's CPU switched back on, so the
;;;; rollouts give the brainless human a stand-in brain. Prints "fulltest N checks, M differ" and the variables that differed.
;;;; Usage: ecl-host --norc --load tools/simgate/fulltest.lisp -- <duel.fas> <cmd>...   e.g. 2102 4007 (G2's IK), FT_VS=1 2102 2500
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defparameter *ft-skip* '(*mc-full-stats* *snap-memo* *ft-n* *ft-bad* *ft-names*))
(defun ft-digest ()
  (let ((*print-length* 80) (*print-level* 3) (*print-circle* nil) (l nil))
    (dolist (p (list (find-package :duel) (find-package :engine)))
      (do-symbols (s p)
        (when (and (eq (symbol-package s) p) (boundp s) (not (constantp s)) (not (member s *ft-skip*)))
          (let ((v (symbol-value s)))
            (when (or (numberp v) (symbolp v) (characterp v) (stringp v)
                      (and (typep v '(simple-array single-float (*))) (<= (length v) 64))
                      (and (typep v '(simple-array fixnum (*))) (<= (length v) 64)))
              (push (cons s (prin1-to-string v)) l))))))
    (cons (state-hash-line) (sort l #'string< :key (lambda (x) (symbol-name (car x)))))))

(defvar *ft-n* 0) (defvar *ft-bad* 0) (defvar *ft-names* nil)
(defun ft-hook ()
  (when (and (equal (ext:getenv "FT_VS") "1") (battle-p) (brain *p2*)) (setf (brain-off (brain *p2*)) nil))   ; (P2's CPU back on)
  (let ((j (first *mc-jobs*)))
    (when (and (sim-snapshot-ok-p) j (svref j 5) (< (svref j 6) 2))
      (let* ((d1 (ft-digest)) (live (sim-snapshot)))
        (mc-full-roll (copy-seq j))
        (sim-restore live)
        (let ((d2 (ft-digest)))
          (incf *ft-n*)
          (unless (equal d1 d2)
            (incf *ft-bad*)
            (unless (equal (car d1) (car d2)) (pushnew :state-hash-line *ft-names*))
            (loop for (s . v) in (cdr d1) for (nil . w) in (cdr d2) unless (equal v w) do (pushnew s *ft-names*))))))))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(setf *step-hook* #'ft-hook)
(engine::%frame)
(unless (loop repeat 400000 do (unless (engine::%frame) (ext:quit 3))
              thereis (or (> *match-tick* 7200) (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p)))))
  (ext:quit 4))
(format t "fulltest ~d checks, ~d differ~@[: ~{~a~^ ~}~]~%" *ft-n* *ft-bad* *ft-names*)
(finish-output)
(ext:quit 0)
