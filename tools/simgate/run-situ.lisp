;;;; run-situ.lisp: run-log.lisp plus the KI matchup evaluator's situation observer (situ.lisp; tools/matchup-eval.py). FROZEN with the
;;;; evaluator. Env SITU_GENERIC=<character> unregisters that character's matchup style (the NORMAL band runs against the generic CPU).
;;;; Usage: ecl-host --norc --load tools/simgate/run-situ.lisp -- <duel.fas> <cmd>...
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)
(load (merge-pathnames "situ.lisp" (directory-namestring *load-truename*)) :verbose nil)
(let ((g (ext:getenv "SITU_GENERIC")))
  (when (and g (plusp (length g)))
    (let ((c (intern (string-upcase g) :keyword)))
      (loop for (own m) on *cai-styles* by #'cddr
            do (when (eq own c) (loop for (opp) on m by #'cddr do (setf (getf (getf *cai-styles* own) opp) nil)))))))
(cl-user::sg-init)
(cl-user::sg-queue)
(engine::%frame) (setf *combat-log* t)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(situ-flush *situ*)
(finish-output)
(ext:quit 0)
