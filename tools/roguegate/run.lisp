;;;; One DANGAI gate process (tools/roguegate.py): load the native SOUL DUEL (tools/simgate's build), start it as the page
;;;; would, run the debug command (84900 + 10c + p: the autopilot over roster c x seeds 1-20, pick policy p), then 1/60 s
;;;; frames until the autopilot's queue is done (it prints its "duel rogue gate ..." summary and goes to TITLE).
;;;; Usage: ecl-host --norc --load tools/roguegate/run.lisp -- <duel.fas> <cmd>
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)
(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
;; ponytail: 4e6 frames x 120 turbo steps, far past 20 runs of 10+ stages; a hung run exits 4
(unless (loop repeat 4000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *endless-auto*) (null *endless-queue*)))
  (ext:quit 4))
(finish-output)
(ext:quit 0)
