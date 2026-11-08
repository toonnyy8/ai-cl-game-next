;;;; fulltest.lisp — the in-game full-sim rollouts leave nothing behind (docs/duel/DUEL_AI_MCTS.md §12): at every step end where a CPU's
;;;; job has its snapshot, an extra rollout of a copy of the job runs the way MC-FULL-STEP runs one (the live state snapshotted, the
;;;; rollout, the live state put back), and a digest is compared before and after: the state hash line plus every DUEL / ENGINE special
;;;; variable holding a number, symbol, character, string or a short float / fixnum vector (so state outside the snapshot roots, like the
;;;; view's *VIEW-X*, shows). Env FT_VS=1: the match is VS CPU (debug 2500-2503: human P1, idle) with P2's CPU switched back on, so the
;;;; rollouts give the brainless human a stand-in brain. Prints "fulltest N checks, M differ" and the variables that differed.
;;;; Env FT_LAYER=t (or a character list): the strategy layer on (*STRAT-LAYER*, DUEL_AI_STRATEGY §5); the oldest selection's rollout is
;;;; checked the same way (STRAT-ROLL bare, as STRAT-FULL-STEP runs it) once it has its snapshot: "strategy checks K" counts those.
;;;; Usage: ecl-host --norc --load tools/simgate/fulltest.lisp -- <duel.fas> <cmd>...   e.g. 2102 4007 (G2's IK), FT_VS=1 2102 2500
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defparameter *ft-skip* '(*mc-full-stats* *strat-stats* *strat-picks* *snap-memo* *ft-n* *ft-bad* *ft-names* *ft-sn*))
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
    (cons (list (state-hash-line) (camera-fov *camera*) (camera-shift-x *camera*) (camera-shift-y *camera*))   ; (the camera: a shared struct, never walked)
          (sort l #'string< :key (lambda (x) (symbol-name (car x)))))))

(defvar *ft-n* 0) (defvar *ft-bad* 0) (defvar *ft-names* nil) (defvar *ft-sn* 0)
(defun ft-check (roll)
  "Digest, the live state saved, ROLL (one rollout), the live state put back, digest again: count a difference."
  (let* ((d1 (ft-digest)) (live (sim-snapshot)))
    (funcall roll)
    (sim-restore live)
    (let ((d2 (ft-digest)))
      (incf *ft-n*)
      (unless (equal d1 d2)
        (incf *ft-bad*)
        (unless (equal (car d1) (car d2)) (pushnew (if (equal (caar d1) (caar d2)) :camera :state-hash-line) *ft-names*))
        (loop for (s . v) in (cdr d1) for (nil . w) in (cdr d2) unless (equal v w) do (pushnew s *ft-names*))))))
(defun ft-hook ()
  (when (and (equal (ext:getenv "FT_VS") "1") (battle-p) (brain *p2*)) (setf (brain-off (brain *p2*)) nil))   ; (P2's CPU back on)
  (let ((j (first *mc-jobs*)))
    (when (and (sim-snapshot-ok-p) j (svref j 5) (< (svref j 6) 2))
      (ft-check (lambda () (mc-full-roll (copy-seq j))))))
  (let ((j (first *strat-jobs*)))
    (when (and (sim-snapshot-ok-p) j (stjob-snap j))
      (incf *ft-sn*)
      (ft-check (lambda () (strat-roll j))))))

(let ((l (ext:getenv "FT_LAYER")))
  (when (and l (plusp (length l)))
    (setf *strat-layer* (if (string-equal l "t") t
                            (loop for start = 0 then (1+ p) for p = (position #\, l :start start)
                                  collect (intern (string-upcase (subseq l start p)) :keyword) while p)))))
(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(setf *step-hook* #'ft-hook)
(engine::%frame)
(unless (loop repeat 400000 do (unless (engine::%frame) (ext:quit 3))
              thereis (or (> *match-tick* 7200) (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p)))))
  (ext:quit 4))
(format t "fulltest ~d checks (strategy checks ~d), ~d differ~@[: ~{~a~^ ~}~]~%" *ft-n* *ft-sn* *ft-bad* *ft-names*)
(finish-output)
(ext:quit 0)
