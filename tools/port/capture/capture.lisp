;;;; capture.lisp — record real frames of the frozen game for the Bevy port's speed test (docs/bevy/plans/2026-11-26-m0a-speed-test.md,
;;;; Task 2): the native image built with tools/port/capture/stubs-capture.c, started as the page would, then the G3 scene (4003: seeded
;;;; CvC Ichigo vs Kenpachi; 2106: the perf log), real frames (ENGINE::%FRAME, drawn: not turbo) until the C recorder has written its
;;;; frames and exited 0. Exit 4: no capture within the frame budget.
;;;; Usage: ecl-host --norc --load tools/port/capture/capture.lisp -- build/port/capture.fas   (env CAP_F0 CAP_N CAP_OUT, see the .c)
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)
(ensure-directories-exist "build/port/capture/")
(cl-user::sg-init)
(cl-user::sg-queue '("4003" "2106"))
(loop repeat 20000 do (unless (engine::%frame) (ext:quit 3)))   ; ponytail: the recorder exits 0 long before this budget
(ext:quit 4)
