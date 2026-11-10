;;;; run-log.lisp: run.lisp with the combat log kept on after the commands (tools/aieval.py reads the hits). One sim-gate process (tools/simgate.py): load the native SOUL DUEL (tools/simgate/build.lisp), start it as the page
;;;; would (every startup step, no audio device), queue the debug commands, then run 1/60 s frames (ENGINE::%FRAME, the
;;;; real frame: flow, gate, turbo steps, camera, HUD; the scene is never drawn in turbo) until the seed gate has printed
;;;; its summary, or a single match (e.g. 2102 3007) has ended. Output = the page's console: "duel gate row ..." and
;;;; "duel gate A B: ..." lines among the rest.
;;;; Usage: ecl-host --norc --load tools/simgate/run.lisp -- <duel.fas> <cmd>...   e.g. 30000 31110 2126
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)
(cl-user::sg-init)
(cl-user::sg-queue)
(engine::%frame) (setf *combat-log* t)                                        ; the commands run at this frame's start
;; ponytail: 2e6 frames = 240M turbo steps, far past any gate; a hung sim exits 4 instead of spinning forever
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(finish-output)
(ext:quit 0)
