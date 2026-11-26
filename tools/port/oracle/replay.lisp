;;;; replay.lisp — the answer key's replay check (docs/bevy/BEVY_PORT.md §6.1, M0 Task 7): one trace of record.lisp played back on the
;;;; STOCK native image (build/simgate/duel.fas) with both CPU brains DETACHED (their components removed: the sim alone, as M1's Rust sim
;;;; runs it). The trace's start (its S line) is run as the recorder ran it; on every sim frame each brainless pilot's vpad is read by
;;;; PILOT-SYSTEM (main.lisp SIM-STEP) just before BRAIN-SYSTEM / FIGHTER-SYSTEM, and that read (a vpad READER) writes the recorded
;;;; buttons (VPAD-SET! in *VPAD-ACTIONS* order, as the CPU's AI-PRESS-WRITE!), the stick and the sim stream. At every step's end
;;;; (*STEP-HOOK*) the step's sim log lines (C lines excepted), T's tick, vpad ticks and sim stream, and STATE-HASH-LINE must equal the
;;;; trace's. A cmds trace detaches the brains once (at the first step's end: the intro runs no sim frame, which is checked); a trials
;;;; trace runs trial.lisp's TRIAL-RUN, whose setup and between-frame drives read the brains, so they are detached around each frame
;;;; (ENGINE::%FRAME wrapped) and put back after it.
;;;; Prints "replay OK N ticks" (exit 0) or "replay DIVERGED at tick T (step I): what" (exit 1).
;;;; Usage: ecl-host --norc --load tools/port/oracle/replay.lisp -- <duel.fas> <trace>
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "trace.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defvar *rp-start* nil "The trace's S line, its words.")
(defvar *rp-recs* nil "Vector of steps: (sim-log-lines t-fields h-line).")
(defvar *rp-trials* nil "A trials trace: brains detached around each frame only.")
(defvar *rp-i* 0 "Steps checked.")
(defvar *rp-last* (vector -1 -1) "Per side, the vpad tick last injected.")
(defvar *rp-brains* (vector nil nil) "Per side, the brain taken off for the frame (a trials trace).")
(defvar *rp-real* *standard-output*)
(defvar *rp-cap* (make-string-output-stream))

(multiple-value-setq (*rp-start* *rp-recs*) (tr-read (second cl-user::*sg-args*)))
(setf *rp-trials* (string= (first *rp-start*) "trials"))

(defun rp-fail (fmt &rest args)
  (format *rp-real* "~&replay DIVERGED at tick ~d (step ~d): ~?~%" *match-tick* *rp-i* fmt args)
  (finish-output *rp-real*)
  (ext:quit 1))

(defun rp-rec ()
  (if (< *rp-i* (length *rp-recs*)) (aref *rp-recs* *rp-i*) (rp-fail "the replay runs past the trace's ~d steps" (length *rp-recs*))))

(defun rp-inject (vp k)
  "A sim frame's pilot read (VPAD-BEGIN-STEP! advanced the clock): side K's recorded buttons, stick and the sim stream."
  (let ((tf (second (rp-rec))))
    (destructuring-bind (vt downs sx sy) (tr-side tf k)
      (unless (= vt (vpad-tick vp)) (rp-fail "P~d vpad tick ~d, the trace's ~d" (1+ k) (vpad-tick vp) vt))
      (loop for a across *vpad-actions* for bit from 0 do (vpad-set! vp a (logbitp bit downs)))
      (setf (vpad-sx vp) sx (vpad-sy vp) sy)
      (setf (sim-rnd-state) (tr-rnd tf)))))

(defun rp-reader (k)
  (lambda (vp)
    (unless (= (vpad-tick vp) (svref *rp-last* k))   ; (PILOT-READ, a step without a sim frame, leaves the clock: nothing to write)
      (setf (svref *rp-last* k) (vpad-tick vp))
      (rp-inject vp k))))

(defun rp-detach ()
  "Both brains off the fighters (once a match has spawned them); their pilots' vpads read the trace."
  (do-sides (e)
    (let ((b (brain e)))
      (when b
        (remove-component e 'brain)
        (let ((k (fighter-side (fighter e))) (vp (pilot-vpad (pilot e))))
          (when (and (not *rp-trials*) (plusp (vpad-tick vp)))
            (rp-fail "P~d's brain ran ~d sim frames before it could be detached" (1+ k) (vpad-tick vp)))
          (setf (svref *rp-brains* k) b (svref *rp-last* k) (vpad-tick vp) (vpad-reader vp) (rp-reader k)))))))

(defun rp-attach ()
  "A trials trace, after a frame: the brains back for TRIAL-RUN's setup and drives (never stepped: BRAIN-SYSTEM runs inside frames)."
  (do-sides (e)
    (let ((k (fighter-side (fighter e))))
      (when (svref *rp-brains* k) (add-component e (svref *rp-brains* k)) (setf (svref *rp-brains* k) nil)))))

(defun rp-step ()
  (setf *combat-log* t)
  (let* ((rec (rp-rec)) (want (second rec)) (got-log (remove-if-not #'tr-log-p (tr-lines (get-output-stream-string *rp-cap*))))
         (tf (tr-t-fields)) (h (state-hash-line)))
    (unless (tr-log-equal (first rec) got-log)
      (rp-fail "combat log~%  want ~s~%  got  ~s" (first rec) got-log))
    (unless (and (= (first tf) (first want)) (= (nth 1 tf) (nth 1 want)) (= (nth 5 tf) (nth 5 want)) (= (tr-rnd tf) (tr-rnd want)))
      (rp-fail "T (tick, vpad ticks, sim stream)~%  want ~a~%  got  ~a" (tr-t-line want) (tr-t-line tf)))
    (unless (string= h (third rec)) (rp-fail "H~%  want ~a~%  got  ~a" (third rec) h))
    (incf *rp-i*))
  (unless *rp-trials* (rp-detach)))

(cond (*rp-trials*
       (tr-load-trial-lib)
       (setf *step-hook* #'rp-step)
       (tr-wrap-frame #'rp-detach #'rp-attach)
       (tr-run-trials (second *rp-start*) *rp-cap*))
      (t (cl-user::sg-init)
         (setf *step-hook* #'rp-step)
         (dolist (c (rest *rp-start*)) (engine::simgate-cmd (parse-integer c)))
         (tr-run-frames *rp-cap*)))
(if (= *rp-i* (length *rp-recs*))
    (progn (format *rp-real* "~&replay OK ~d ticks~%" *rp-i*) (finish-output *rp-real*) (ext:quit 0))
    (rp-fail "the run ended after ~d of the trace's ~d steps" *rp-i* (length *rp-recs*)))
