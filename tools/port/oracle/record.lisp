;;;; record.lisp — the answer key's recorder (docs/bevy/BEVY_PORT.md §6.1, M0 Task 7): one native run, a match from debug commands as
;;;; tools/simgate/run.lisp plays it, or a trial file as tools/simgate/trial.lisp plays it, with a trace in trace.lisp's format. The
;;;; console goes on to stdout unchanged (the 600-tick hash lines and RESULTS: gen.py's non-perturbation check and cvc-tag.txt).
;;;; Runs on the recorder's image (build-rec.lisp: the stock unit plus *ORACLE-BRAIN-HOOK* after BRAIN-SYSTEM, which a runtime wrapper
;;;; cannot reach: BRAIN-SYSTEM is a compiled direct call, a wrapped FDEFINITION saw 0 calls). Per step:
;;;;   - each CPU vpad's reader (only reads) runs first (the brain's VPAD-BEGIN-STEP!, or PILOT-READ): what was printed before it is the
;;;;     sim's / the trial runner's (between frames), and the sim stream there is compared with the last step's end (start-miss);
;;;;   - the brain hook: what was printed since the reader is the CPUs' (C lines), and T is taken (the vpads as the brains wrote them,
;;;;     the sim stream after their draws);
;;;;   - *STEP-HOOK*: the rest of the step's lines, T, H. A sim stream there that differs from the brain hook's counts as post-draw
;;;;     (a draw after BRAIN-SYSTEM: Ichigo's CPU-only parry / stance branches in his :tick hook).
;;;; Usage: ecl-host --norc --load tools/port/oracle/record.lisp -- <rec duel.fas> <out.trace> cmds <debug command> ...
;;;;                                                                                          trials <trial file>
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "trace.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defvar *rec-start* (cddr cl-user::*sg-args*) "\"cmds\" and the commands, or \"trials\" and the file.")
(defvar *rec-out* (open (second cl-user::*sg-args*) :direction :output :if-exists :supersede))
(defvar *rec-real* *standard-output*)
(defvar *rec-cap* (make-string-output-stream))
(defvar *rec-steps* 0)
(defvar *rec-pre* "" "This step's console before its first vpad read.")
(defvar *rec-cpu* "" "... between that and the brain hook.")
(defvar *rec-t* nil "This step's T fields at the brain hook (a sim frame), else NIL.")
(defvar *rec-start-rnd* nil "The sim stream at this step's first vpad read (NIL: none).")
(defvar *rec-prev-rnd* nil)
(defvar *rec-start-miss* nil "Steps (index) whose sim stream at the first vpad read differs from the last step's end.")
(defvar *rec-post-draw* nil "Steps (index) whose sim stream at the end differs from the brain hook's.")

(defun rec-drain ()
  (let ((s (get-output-stream-string *rec-cap*))) (write-string s *rec-real*) s))

(defun rec-write-lines (text &optional cpu)
  (dolist (l (tr-lines text))
    (cond ((tr-log-p l) (format *rec-out* "~:[~;C ~]~a~%" cpu l))
          ((tr-trial-p l) (format *rec-out* "# ~a~%" l)))))

(defun rec-reader (vp)
  (declare (ignore vp))
  (unless (or *in-rollout* *rec-start-rnd*)   ; (a CPU's rollout after the step's end reads the vpads too: not the step's)
    (setf *rec-start-rnd* (sim-rnd-state) *rec-pre* (rec-drain))))

(defun rec-readers ()
  "Every CPU vpad reads through REC-READER (once a match has spawned them)."
  (do-sides (e) (let ((vp (pilot-vpad (pilot e)))) (when (and (brain e) (null (vpad-reader vp))) (setf (vpad-reader vp) #'rec-reader)))))

(defun rec-brain ()
  (unless *in-rollout*
    (setf *rec-cpu* (rec-drain) *rec-t* (tr-t-fields))))

(defun rec-step ()
  (setf *combat-log* t)
  (let ((sim (rec-drain)) (tf (or *rec-t* (tr-t-fields))) (rnd (sim-rnd-state)))
    (rec-write-lines *rec-pre*)
    (rec-write-lines *rec-cpu* t)
    (rec-write-lines sim)
    (write-line (tr-t-line tf) *rec-out*)
    (format *rec-out* "H ~a~%" (state-hash-line))
    (when (and *rec-start-rnd* *rec-prev-rnd* (/= *rec-start-rnd* *rec-prev-rnd*)) (push *rec-steps* *rec-start-miss*))
    (when (and *rec-t* (/= rnd (tr-rnd *rec-t*))) (push *rec-steps* *rec-post-draw*))
    (setf *rec-pre* "" *rec-cpu* "" *rec-t* nil *rec-start-rnd* nil *rec-prev-rnd* rnd)
    (incf *rec-steps*))
  (rec-readers))

(format *rec-out* "# oracle trace v1: tools/port/oracle/record.lisp~%S~{ ~a~}~%" *rec-start*)
(unless (boundp '*oracle-brain-hook*) (format *rec-real* "record.lisp: not the recorder's image (build-rec.lisp)~%") (ext:quit 2))
(setf *oracle-brain-hook* #'rec-brain)
(cond ((string= (first *rec-start*) "cmds")
       (cl-user::sg-init)
       (setf *step-hook* #'rec-step)
       (dolist (c (rest *rec-start*)) (engine::simgate-cmd (parse-integer c)))
       (tr-run-frames *rec-cap*))
      (t (tr-load-trial-lib)
         (setf *step-hook* #'rec-step)
         (tr-wrap-frame #'rec-readers (lambda ()))
         (tr-run-trials (second *rec-start*) *rec-cap*)))
(rec-write-lines (rec-drain))
(close *rec-out*)
(format *rec-real* "~&rec steps ~d start-miss ~d~@[ (steps ~{~d~^ ~})~] post-draw ~d~@[ (steps ~{~d~^ ~})~]~%"
        *rec-steps* (length *rec-start-miss*) (subseq (reverse *rec-start-miss*) 0 (min 20 (length *rec-start-miss*)))
        (length *rec-post-draw*) (subseq (reverse *rec-post-draw*) 0 (min 20 (length *rec-post-draw*))))
(finish-output *rec-real*)
(ext:quit 0)
