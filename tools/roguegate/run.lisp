;;;; One DANGAI gate process (tools/roguegate.py): load the native SOUL DUEL (tools/simgate's build), start it as the page
;;;; would, run the debug command (84900 + 10c + p: the autopilot over roster c x seeds 1-20, pick policy p), then 1/60 s
;;;; frames until the autopilot's queue is done (it prints its "duel rogue gate ..." summary and goes to TITLE).
;;;; Usage: ecl-host --norc --load tools/roguegate/run.lisp -- <duel.fas> <cmd>
(load (merge-pathnames "../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)
(cl-user::sg-init)
(cl-user::sg-queue)
(engine::%frame)
;; ponytail: 4e6 frames x 120 turbo steps, far past 20 runs of 10+ stages; a hung run exits 4
(unless (loop repeat 4000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *endless-auto*) (null *endless-queue*)))
  (ext:quit 4))
(finish-output)
(ext:quit 0)
