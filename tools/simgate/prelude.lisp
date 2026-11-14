;;;; prelude.lisp — what every native-sim runner starts with (tools/simgate/*.lisp):
;;;;   (load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
;;;;   (in-package :duel)                                                               ; (a package switch stays in the loading file)
;;;; Reads the args after "--" (*SG-ARGS*: the duel.fas path, then the runner's own), loads the native SOUL DUEL and defines
;;;; CL-USER::SG-INIT (every startup step, as the page would; exit 2 on a failed step) and CL-USER::SG-QUEUE [ARGS] (queue the debug
;;;; commands, default all args after the fas); call them qualified, the loading file is in :duel.
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(defun cl-user::sg-init ()
  (loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2)))
(defun cl-user::sg-queue (&optional (args (rest cl-user::*sg-args*)))
  (dolist (c args) (engine::simgate-cmd (parse-integer c))))
;;; CL-USER::SG-STRAT-STEP, for a runner's *STEP-HOOK* (snaptest, fulltest): env STRAT_P1 / STRAT_P2 = a strategy file (one plist, READ) that
;;; seat's CPU plays from each match's first battle step; a plain arm (no :SWITCH / :FQ) also drops its character's matchup style CPU, as
;;; strat-run.lisp does (its pools, `none` and counters are not here). No such env: nothing.
(in-package :duel)
(defvar *sg-styles0* (copy-tree *cai-styles*))
(defvar *sg-strat-match* -1)
(defvar *sg-strat-on* (or (plusp (length (or (ext:getenv "STRAT_P1") ""))) (plusp (length (or (ext:getenv "STRAT_P2") "")))))
(defun cl-user::sg-strat-step ()
  (when (and *sg-strat-on* (battle-p) (/= *sg-strat-match* *match-seed*))
    (setf *sg-strat-match* *match-seed* *cai-styles* (copy-tree *sg-styles0*))
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (p (ext:getenv (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")))
             (st (and b p (plusp (length p)) (with-open-file (in p) (let ((*read-eval* nil)) (read in))))))
        (when st
          (setf (brain-strat b) st)
          (unless (or (getf st :switch) (getf st :fq)) (remf *cai-styles* (fighter-character f)))
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (getf st :id)))))))
