;;;; prelude.lisp — what every native-sim runner starts with (tools/simgate/*.lisp, tools/roguegate/run.lisp):
;;;;   (load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/roguegate/ uses "../simgate/prelude.lisp"
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
