;;;; replay.lisp — the answer key's replay check (docs/bevy/BEVY_PORT.md §6.1, M0 Task 7): one trace of record.lisp played back on the
;;;; STOCK native image (build/simgate/duel.fas) with both CPU brains DETACHED (their components removed: the sim alone, as M1's Rust sim
;;;; runs it). The trace's start (its S line) is run as the recorder ran it; on every sim frame each brainless pilot's vpad is read by
;;;; PILOT-SYSTEM (main.lisp SIM-STEP) just before BRAIN-SYSTEM / FIGHTER-SYSTEM, and that read (a vpad READER) writes the recorded
;;;; buttons (VPAD-SET! in *VPAD-ACTIONS* order, as the CPU's AI-PRESS-WRITE!), the stick and the sim stream. At every step's end
;;;; (*STEP-HOOK*) the step's sim log lines (C lines excepted), T's tick, vpad ticks and sim stream, and STATE-HASH-LINE must equal the
;;;; trace's, and so must the raw-bits B line (TR-B-LINE; the first differing field is named). A cmds trace detaches the brains once (at the first step's end: the intro runs no sim frame, which is checked). A trials
;;;; trace is self-describing: after SG-INIT and one frame its E lines are applied (TR-APPLY-EVENT; what each prints must equal its e
;;;; lines) and each F line runs one frame, the brains taken off before it (a new match's included). Neither trial.lisp nor its TRIAL-RUN
;;;; is loaded: R lines (the runner's own) and C lines (the CPUs') are skipped.
;;;; A vs trace (S vs) starts and is driven as a trials trace; P1 (no brain) reads the trace on every sim frame too, and, as the
;;;; recorder's device, writes his last recorded state again on every other read (a step without a sim frame, a rollout). The A line
;;;; (M2): a brainless replay compares its pilot fields (the brains' are gone); with "live" the brains stay on and think (no vpad but a
;;;; vs trace's P1 is injected, nor the sim stream) and the whole A line is compared, with T's tick and vpad ticks, H and B (not the log:
;;;; the CPUs' C lines print in it, nor T's buttons / stick / stream, taken mid-step by the recorder). A live vs replay that reaches the
;;;; page (vs-learn's reload) needs the recorder's image, whose ENGINE::*ORACLE-PAGE* it then turns on, as the recorder did.
;;;; Prints "replay OK N ticks" (exit 0) or "replay DIVERGED at tick T (step I): what" (exit 1).
;;;; Usage: ecl-host --norc --load tools/port/oracle/replay.lisp -- <duel.fas> <trace> [live]
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "trace.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)
(unless (tr-bits-selftest) (format t "replay.lisp: TR-BITS-SELFTEST failed~%") (ext:quit 2))
(unless (tr-a-selftest) (format t "replay.lisp: TR-A-SELFTEST failed~%") (ext:quit 2))

(defvar *rp-start* nil "The trace's S line, its words.")
(defvar *rp-recs* nil "The trace's items (TR-READ): steps, events, frames.")
(defvar *rp-b-names* nil "The trace header's B field names.")
(defvar *rp-a-names* nil "The trace header's A field names (NIL: a trace from before M2, no A lines).")
(defvar *rp-trials* nil "A trials or vs trace: E and F lines drive it.")
(defvar *rp-vs* nil "A vs trace: P1 is a device that reads the trace.")
(defvar *rp-live* (equal (third cl-user::*sg-args*) "live") "The brains stay on (the file header).")
(defvar *rp-held* (vector nil nil) "Per side, the (downs sx sy) last injected (a vs trace's P1 writes it again on every read).")
(defvar *rp-vp* (vector nil nil) "Per side, the vpad that reads the trace.")
(defvar *rp-i* 0 "Items consumed.")
(defvar *rp-steps* 0 "Steps checked.")
(defvar *rp-last* (vector -1 -1) "Per side, the vpad tick last injected.")
(defvar *rp-real* *standard-output*)
(defvar *rp-cap* (make-string-output-stream))

(multiple-value-setq (*rp-start* *rp-recs* *rp-b-names* *rp-a-names*) (tr-read (second cl-user::*sg-args*)))
(setf *rp-vs* (string= (first *rp-start*) "vs") *rp-trials* (or *rp-vs* (string= (first *rp-start*) "trials")))

(defun rp-fail (fmt &rest args)
  (format *rp-real* "~&replay DIVERGED at tick ~d (step ~d, item ~d): ~?~%" *match-tick* *rp-steps* *rp-i* fmt args)
  (finish-output *rp-real*)
  (ext:quit 1))

(defun rp-rec ()
  "The step record due now (the next item must be one), as (sim-log-lines t-fields h-line b-pos a-pos)."
  (let ((it (if (< *rp-i* (length *rp-recs*)) (aref *rp-recs* *rp-i*) (rp-fail "the replay runs past the trace's end"))))
    (unless (eq (first it) :step) (rp-fail "a step ran where the trace has ~s" (first it)))
    (rest it)))

(defun rp-write (vp held)
  "HELD (downs sx sy) onto VP: VPAD-SET! in *VPAD-ACTIONS* order, then the stick."
  (destructuring-bind (downs sx sy) held
    (loop for a across *vpad-actions* for bit from 0 do (vpad-set! vp a (logbitp bit downs)))
    (setf (vpad-sx vp) sx (vpad-sy vp) sy)))

(defun rp-inject (vp k)
  "A sim frame's pilot read (VPAD-BEGIN-STEP! advanced the clock): side K's recorded buttons, stick and (not live) the sim stream."
  (let ((tf (second (rp-rec))))
    (destructuring-bind (vt downs sx sy) (tr-side tf k)
      (unless (= vt (vpad-tick vp)) (rp-fail "P~d vpad tick ~d, the trace's ~d" (1+ k) (vpad-tick vp) vt))
      (rp-write vp (setf (svref *rp-held* k) (list downs sx sy)))
      (unless *rp-live* (setf (sim-rnd-state) (tr-rnd tf))))))

(defun rp-reader (k &optional device)
  ;; Injection is skipped when the vpad tick equals the last injected tick: VPAD-CLEAR! keeps the tick, so a re-read in one tick must not
  ;; rewrite (a CPU side: its brain wrote nothing then). A DEVICE (a vs trace's P1) writes its last state again on every such read, as the
  ;; recorder's device does, and never steps on in a rollout.
  (lambda (vp)
    (if (and (/= (vpad-tick vp) (svref *rp-last* k)) (not *in-rollout*))   ; (PILOT-READ, a step without a sim frame, leaves the clock)
        (progn (setf (svref *rp-last* k) (vpad-tick vp))
               (rp-inject vp k))
        (when (and device (svref *rp-held* k)) (rp-write vp (svref *rp-held* k))))))

(defun rp-detach ()
  "Both brains off the fighters (once a match has spawned them; live: kept); their pilots' vpads read the trace. A vs trace: P1's new vpad
(a new match) reads it as a device."
  (when *rp-vs*
    (let ((vp (pilot-vpad (pilot *p1*))))
      (unless (eq vp (svref *rp-vp* 0))
        (when (brain *p1*) (rp-fail "P1 of a vs trace has a brain"))
        (setf (svref *rp-vp* 0) vp (svref *rp-last* 0) (vpad-tick vp) (svref *rp-held* 0) nil (vpad-reader vp) (rp-reader 0 t)))))
  (do-sides (e)
    (let ((b (brain e)))
      (when (and b (not *rp-live*))
        (remove-component e 'brain)
        (let ((k (fighter-side (fighter e))) (vp (pilot-vpad (pilot e))))
          (when (and (not *rp-trials*) (plusp (vpad-tick vp)))
            (rp-fail "P~d's brain ran ~d sim frames before it could be detached" (1+ k) (vpad-tick vp)))
          (setf (svref *rp-last* k) (vpad-tick vp) (vpad-reader vp) (rp-reader k)))))))

(defun rp-step ()
  (setf *combat-log* t)
  (let* ((rec (rp-rec)) (want (second rec)) (got-log (remove-if-not #'tr-log-p (tr-lines (get-output-stream-string *rp-cap*))))
         (tf (tr-t-fields)) (h (state-hash-line)))
    (unless (or *rp-live* (tr-log-equal (first rec) got-log))
      (rp-fail "combat log~%  want ~s~%  got  ~s" (first rec) got-log))
    (unless (and (= (first tf) (first want)) (= (nth 1 tf) (nth 1 want)) (= (nth 5 tf) (nth 5 want)) (or *rp-live* (= (tr-rnd tf) (tr-rnd want))))
      (rp-fail "T (tick, vpad ticks~:[, sim stream~;~])~%  want ~a~%  got  ~a" *rp-live* (tr-t-line want) (tr-t-line tf)))
    (unless (fourth rec) (rp-fail "the trace has no B line for this step"))
    (let ((b (tr-b-line)))
      (let ((want (tr-b-at (second cl-user::*sg-args*) (fourth rec))))
        (unless (string= b want) (rp-fail "~a" (or (tr-b-diff *rp-b-names* want b) "B (equal fields, other text)")))))
    (when *rp-a-names*
      (unless (fifth rec) (rp-fail "the trace has no A line for this step"))
      (let ((a (tr-a-line)) (want (tr-b-at (second cl-user::*sg-args*) (fifth rec))))
        (if *rp-live*
            (unless (string= a want) (rp-fail "~a" (or (tr-a-diff *rp-a-names* want a) "A (equal fields, other text)")))
            (let ((d (tr-a-pilot-diff *rp-a-names* want a))) (when d (rp-fail "~a" d))))))
    (unless (string= h (third rec)) (rp-fail "H~%  want ~a~%  got  ~a" (third rec) h))
    (incf *rp-i*) (incf *rp-steps*))
  (unless (or *rp-trials* *rp-live*) (rp-detach)))

(defun rp-drive ()
  "A trials trace's driver: its E lines applied, its F lines run, in order (the steps are checked by RP-STEP inside the frames)."
  (loop while (< *rp-i* (length *rp-recs*))
        do (let ((it (aref *rp-recs* *rp-i*)))
             (incf *rp-i*)
             (ecase (first it)
               (:event (get-output-stream-string *rp-cap*)
                       (let ((*standard-output* *rp-cap*)) (tr-apply-event (second it)))
                       (let ((got (remove-if-not #'tr-log-p (tr-lines (get-output-stream-string *rp-cap*)))))
                         (unless (tr-log-equal (third it) got)
                           (rp-fail "event ~{~a~^ ~} printed~%  want ~s~%  got  ~s" (second it) (third it) got))))
               (:frame (rp-detach)
                       (get-output-stream-string *rp-cap*)
                       (let ((*standard-output* *rp-cap*)) (engine::%frame)))
               (:step (decf *rp-i*) (rp-fail "a step outside a frame"))))))

(when (and *rp-vs* (boundp 'engine::*oracle-page*)) (setf engine::*oracle-page* (make-hash-table)))   ; (the recorder's image: its page)
(cond (*rp-trials*
       (cl-user::sg-init)
       (engine::%frame)                                  ; (trial.lisp's start: one frame, no step)
       (setf *step-hook* #'rp-step)
       (rp-drive))
      (t (cl-user::sg-init)
         (setf *step-hook* #'rp-step)
         (dolist (c (rest *rp-start*)) (engine::simgate-cmd (parse-integer c)))
         (tr-run-frames *rp-cap*)))
(if (= *rp-i* (length *rp-recs*))
    (progn (format *rp-real* "~&replay OK ~d ticks~%" *rp-steps*) (finish-output *rp-real*) (ext:quit 0))
    (rp-fail "the run ended after ~d of the trace's ~d items" *rp-i* (length *rp-recs*)))
