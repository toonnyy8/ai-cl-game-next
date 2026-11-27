;;;; sim-bench.lisp — the Lisp side of M1's speed gate (docs/bevy/M1_NOTES.md §5), the same work as `duel-tools replay <trace> --bench`:
;;;; a cmds trace's match on the STOCK native image (build/simgate/duel.fas) with both CPU brains detached, each sim frame's recorded
;;;; buttons, stick and sim stream injected as tools/port/oracle/replay.lisp does, no comparison, the console dropped. The trace is read
;;;; before the clock starts; only the frame loop is timed (the commands' first frame runs before it, as the Rust bench does); the two
;;;; hooks are compiled to native code first (ECL's `load` of a source file would interpret them). Checks the run reproduced the trace
;;;; (its step count, its last H line).
;;;; Prints "lisp steps N secs S steps/s R" (exit 0) or "sim-bench: NOT the trace's run ..." (exit 1).
;;;; `brains` after the trace (M2's speed gate, docs/bevy/M2_NOTES.md §10; `duel-tools replay <trace> --live --bench`): the same match
;;;; with both CPU brains thinking, nothing injected; the combat and stats logs off after the commands' frame (the Rust bench's log is
;;;; off); the step hook only counts. Also prints the CPU rollouts (MC-FULL-STEP's and STRAT-ROLL's) a second.
;;;; Usage: LD_PRELOAD=build/simgate/muslm.so ecl-host --norc --load tools/port/sim-bench.lisp -- build/simgate/duel.fas <trace> [brains]
(load (merge-pathnames "../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "oracle/trace.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defvar *sb-start* nil)
(defvar *sb-recs* nil)
(multiple-value-setq (*sb-start* *sb-recs*) (tr-read (second cl-user::*sg-args*)))
(unless (string= (first *sb-start*) "cmds") (format t "sim-bench: a cmds trace only~%") (ext:quit 2))
(defvar *sb-i* 0 "Steps run.")
(defvar *sb-last* (vector -1 -1))
(defvar *sb-brains* (equal (third cl-user::*sg-args*) "brains") "Both CPUs think: no injection, no detaching.")

(defun sb-reader (k)
  (lambda (vp)
    (unless (= (vpad-tick vp) (svref *sb-last* k))
      (setf (svref *sb-last* k) (vpad-tick vp))
      (let ((tf (third (aref *sb-recs* *sb-i*))))
        (destructuring-bind (vt downs sx sy) (tr-side tf k)
          (declare (ignore vt))
          (loop for a across *vpad-actions* for bit from 0 do (vpad-set! vp a (logbitp bit downs)))
          (setf (vpad-sx vp) sx (vpad-sy vp) sy (sim-rnd-state) (tr-rnd tf)))))))

(defun sb-step ()
  (incf *sb-i*)
  (unless *sb-brains*
   (do-sides (e)
    (when (brain e)
      (remove-component e 'brain)
      (let ((k (fighter-side (fighter e))) (vp (pilot-vpad (pilot e))))
        (setf (svref *sb-last* k) (vpad-tick vp) (vpad-reader vp) (sb-reader k)))))))

(require :cmp)
(let ((*compile-verbose* nil) (*compile-print* nil)) (compile 'sb-reader) (compile 'sb-step))
(cl-user::sg-init)
(setf *step-hook* #'sb-step)
(dolist (c (rest *sb-start*)) (engine::simgate-cmd (parse-integer c)))
(let* ((out (make-broadcast-stream))
       (t0 (progn (let ((*standard-output* out)) (engine::%frame))
                  (when *sb-brains* (setf *combat-log* nil *stats-log* nil))
                  (get-internal-real-time))))
  (let ((*standard-output* out))   ; (tr-run-frames' loop, after its first frame)
    (unless (loop repeat 2000000
                  do (unless (engine::%frame) (ext:quit 3))
                  thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
      (ext:quit 4)))
  (let ((secs (/ (- (get-internal-real-time) t0) (float internal-time-units-per-second 1d0)))
        (n (length *sb-recs*)) (h (fourth (aref *sb-recs* (1- (length *sb-recs*))))))
    (if (and (= *sb-i* n) (string= (state-hash-line) h))
        (let ((r (+ (svref *mc-full-stats* 1) (svref *strat-stats* 1))))
          (format t "~&lisp steps ~d secs ~,3f steps/s ~d~@[ rollouts ~d rollouts/s ~d~]~%" *sb-i* secs (round *sb-i* secs)
                  (and *sb-brains* r) (and *sb-brains* (round r secs)))
          (finish-output) (ext:quit 0))
        (progn (format t "~&sim-bench: NOT the trace's run (steps ~d of ~d)~%" *sb-i* n) (finish-output) (ext:quit 1)))))
