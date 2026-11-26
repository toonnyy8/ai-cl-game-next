;;;; trace.lisp — what record.lisp and replay.lisp share: the trace format, its parser, the two ways a trace starts.
;;;; A trace (build/oracle/traces/<name>.trace), one record per sim step that advanced *MATCH-TICK* (BEGIN-BATTLE resets the tick to 0
;;;; after the intro and the trials share one match, so records are keyed by their order, not by the tick):
;;;;   # ...                                comments: how it was made; "# trial begin NAME" / "# trial end NAME | ..." (trial.lisp's lines)
;;;;   S cmds <debug command> ...           the start: a fresh image (SG-INIT), these commands queued, then run.lisp's frames, or
;;;;   S trials <file>                      tools/simgate/trial.lisp on that trial file (path from the repo root), one match for all
;;;;   [  tick] ...                         a combat log line (CLOG) of the sim, printed during the step (or since the last step)
;;;;   C [  tick] ...                       a combat log line the CPUs printed inside BRAIN-SYSTEM (kept for reference: a sim without the
;;;;                                        CPU cannot print it; never compared)
;;;;   T tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd
;;;;   H duel hash t=...                    STATE-HASH-LINE at the step's end
;;;; T: on a step that ran the sim's systems (a sim frame: the vpad ticks advance) the values right after BRAIN-SYSTEM, i.e. what the
;;;; brains wrote for FIGHTER-SYSTEM to read and the sim stream after their draws; on any other step (intro / cinematic / hitstop /
;;;; slow-motion wait) the values at the step's end. vtK = side K's vpad tick, downsK = its nine buttons as 3 hex digits (bit i =
;;;; *VPAD-ACTIONS* element i: bit 0 :mod, 1 :quick, 2 :flash, 3 :sig, 4 :guard, 5 :breaker, 6 :kikon, 7 :step, 8 :awaken), sxK / syK =
;;;; its stick as single-floats printed shortest round-trip (PRIN1 with single-float the default format: "0.3", "-1.0", "-0.0"; Rust's
;;;; f32::from_str reads them back exactly), rnd = (SIM-RND-STATE) as 8 hex digits. A replay writes downs with VPAD-SET! in bit order
;;;; (as the CPU's AI-PRESS-WRITE! does) after the step's VPAD-BEGIN-STEP!, so the press / since / modded stamps follow from the edges.
(in-package :duel)

(defparameter *tr-dir* (directory-namestring *load-truename*))

(defun tr-split (s)
  (loop for start = 0 then (1+ p) for p = (position #\Space s :start start)
        for w = (subseq s start p) when (plusp (length w)) collect w while p))

(defun tr-float (x) (let ((*read-default-float-format* 'single-float)) (prin1-to-string x)))
(defun tr-read-float (s) (let ((*read-default-float-format* 'single-float) (*read-eval* nil)) (coerce (read-from-string s) 'single-float)))

(defun tr-side-now (e)
  (let ((vp (pilot-vpad (pilot e))))
    (list (vpad-tick vp)
          (loop for a across *vpad-actions* for bit from 0 sum (if (vpad-down vp a) (ash 1 bit) 0))
          (vpad-sx vp) (vpad-sy vp))))

(defun tr-t-fields ()
  "The T fields now: (tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd)."
  (append (list *match-tick*) (tr-side-now *p1*) (tr-side-now *p2*) (list (sim-rnd-state))))

(defun tr-t-line (tf)
  (destructuring-bind (tick vt1 d1 x1 y1 vt2 d2 x2 y2 rnd) tf
    (format nil "T ~d ~d ~3,'0x ~a ~a ~d ~3,'0x ~a ~a ~8,'0x" tick vt1 d1 (tr-float x1) (tr-float y1) vt2 d2 (tr-float x2) (tr-float y2) rnd)))

(defun tr-parse-t (line)
  (destructuring-bind (tick vt1 d1 x1 y1 vt2 d2 x2 y2 rnd) (rest (tr-split line))
    (list (parse-integer tick) (parse-integer vt1) (parse-integer d1 :radix 16) (tr-read-float x1) (tr-read-float y1)
          (parse-integer vt2) (parse-integer d2 :radix 16) (tr-read-float x2) (tr-read-float y2) (parse-integer rnd :radix 16))))

(defun tr-side (tf k) "Side K's (vt downs sx sy) of T fields TF." (subseq tf (+ 1 (* 4 k)) (+ 5 (* 4 k))))
(defun tr-rnd (tf) (nth 9 tf))

(defun tr-read (path)
  "A trace -> (values start records): START the S line's words after S (\"cmds\" and integers, or \"trials\" and a path), RECORDS a
vector of (sim-log-lines t-fields h-line)."
  (with-open-file (in path)
    (let ((start nil) (log nil) (tf nil) (recs (make-array 0 :adjustable t :fill-pointer t)))
      (loop for l = (read-line in nil) while l
            do (cond ((zerop (length l)))
                     ((member (char l 0) '(#\# #\C)))
                     ((char= (char l 0) #\S) (setf start (rest (tr-split l))))
                     ((char= (char l 0) #\[) (push l log))
                     ((char= (char l 0) #\T) (setf tf (tr-parse-t l)))
                     ((char= (char l 0) #\H)
                      (vector-push-extend (list (nreverse log) tf (subseq l 2)) recs)
                      (setf log nil tf nil))))
      (values start recs))))

(defun tr-lines (text)
  (with-input-from-string (in text) (loop for l = (read-line in nil) while l collect l)))
(defun tr-log-p (l) "A combat log line (\"[  tick] ...\")?" (and (plusp (length l)) (char= (char l 0) #\[)))
(defun tr-trial-p (l) "trial.lisp's begin / end line?" (or (eql 0 (search "trial begin " l)) (eql 0 (search "trial end " l))))

(defun tr-log-equal (want got)
  "The recorded sim log WANT against a brainless replay's GOT: equal line for line, but a recorded move / step / dash line may end in its
brain's why (fighter.lisp: \" TRIAL\", scripted.lisp's only BRAIN-WHY), which a detached brain cannot print."
  (and (= (length want) (length got))
       (every (lambda (w g) (or (string= w g)
                                (and (> (length w) (length g)) (string= g w :end2 (length g)) (string= (subseq w (length g)) " TRIAL"))))
              want got)))

(defun tr-run-frames (cap)
  "tools/simgate/run.lisp's loop (the queued commands' frame, then frames until the gate or the match is over), the console bound to the
string stream CAP (the hooks drain it). Exits 3 / 4 as run.lisp does."
  (flet ((frame () (let ((*standard-output* cap)) (engine::%frame))))
    (frame)
    (unless (loop repeat 2000000
                  do (unless (frame) (ext:quit 3))
                  thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
      (ext:quit 4))))

(defun tr-load-trial-lib ()
  "tools/simgate/trial.lisp as its runner starts (SG-INIT, the first frame, *SKIP-CINES* T, its definitions, evaluated: their calls go
through the symbols, so a wrapped ENGINE::%FRAME is seen), without its prelude load (the image is loaded) and its file loop."
  (with-open-file (in (merge-pathnames "../../simgate/trial.lisp" *tr-dir*))
    (let ((*package* (find-package :cl-user)))
      (loop for form = (read in nil in) until (eq form in)
            unless (and (consp form) (member (car form) '(load with-open-file finish-output ext:quit)))
              do (eval form)))))

(defun tr-wrap-frame (before after)
  "ENGINE::%FRAME, as trial.lisp's evaluated TRIAL-RUN calls it, runs BEFORE (no arguments) first and AFTER last."
  (let ((orig (fdefinition 'engine::%frame)))
    (setf (fdefinition 'engine::%frame) (lambda () (funcall before) (prog1 (funcall orig) (funcall after))))))

(defun tr-run-trials (path cap)
  "trial.lisp's file loop over PATH, the console bound to CAP."
  (with-open-file (in path)
    (let ((*package* (find-package :duel)))
      (loop for tr = (read in nil in) until (eq tr in) do (let ((*standard-output* cap)) (trial-run tr))))))
