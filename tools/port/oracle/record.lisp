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
;;;; A trial file: trial.lisp's TRIAL-RUN is run as it is (its definitions evaluated, so its calls go through the symbols), and every
;;;; out-of-band action it takes between frames becomes an E line (trace.lisp's grammar): its sim actions (ENSURE-BATTLE, FORCE-FORM,
;;;; PLACE, CORE-START! ...: *REC-ACTIONS*, wrapped for its calls; the image's compiled callers never see the wrappers, and they record
;;;; only between frames) and the fields it sets (*TR-SIDE-FIELDS*, *TR-GLOBALS*: diffed before each action and each frame). What an
;;;; action prints is its e lines; the rest the runner prints between frames is R lines; each frame is an F line.
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

(defun rec-write-lines (text &optional (prefix ""))
  (dolist (l (tr-lines text))
    (cond ((tr-log-p l) (format *rec-out* "~a~a~%" prefix l))
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
    (rec-write-lines *rec-cpu* "C ")
    (rec-write-lines sim)
    (write-line (tr-t-line tf) *rec-out*)
    (format *rec-out* "H ~a~%" (state-hash-line))
    (when (and *rec-start-rnd* *rec-prev-rnd* (/= *rec-start-rnd* *rec-prev-rnd*)) (push *rec-steps* *rec-start-miss*))
    (when (and *rec-t* (/= rnd (tr-rnd *rec-t*))) (push *rec-steps* *rec-post-draw*))
    (setf *rec-pre* "" *rec-cpu* "" *rec-t* nil *rec-start-rnd* nil *rec-prev-rnd* rnd)
    (incf *rec-steps*))
  (rec-readers))

;;; ---------------------------------------------------------------- a trial file: E / R / F lines
(defvar *rec-in-frame* nil)
(defvar *rec-in-action* nil)
(defvar *rec-fields* nil "The tracked fields at the last E / F line (TR-FIELDS-NOW).")

(defun rec-between ()
  "Before an action or a frame: what the runner printed since (R lines), then an E set line per field it changed."
  (rec-write-lines (rec-drain) "R ")
  (let ((now (tr-fields-now)))
    (dolist (w (tr-fields-diff *rec-fields* now)) (format *rec-out* "E~{ ~a~}~%" w))
    (setf *rec-fields* now)))

(defparameter *rec-actions*
  (list (cons 'ensure-battle (lambda (c1 c2 &key cpu) (assert cpu) (list "battle" c1 c2)))
        (cons 'force-form (lambda (e form) (list "form" (tr-side-of e) form)))
        (cons 'hs-reset (lambda (e) (list "hisagi-reset" (tr-side-of e))))
        (cons 'place (lambda (a b dist) (assert (and (eql a *p1*) (eql b *p2*))) (list "place" dist)))
        (cons 'vpad-clear! (lambda (vp) (list "vpad-clear" (loop for (k . e) in (tr-sides) when (eq vp (pilot-vpad (pilot e))) return k
                                                                 finally (error "record: a vpad of no fighter")))))
        (cons 'clear-hazards (lambda () (list "clear-hazards")))
        (cons 'skip-cine (lambda () (list "skip-cine")))
        (cons 'burst-end! (lambda (e) (list "burst-end" (tr-side-of e))))
        (cons 'full-gauges! (lambda (e &optional meter) (list "full-gauges" (tr-side-of e) meter)))
        (cons 'debug-command (lambda (c) (list "cmd" c)))
        (cons 'core-start! (lambda (e mv) (list "core-start" (tr-side-of e) (tr-move-key e mv)))))
  "The sim actions TRIAL-RUN calls between frames and their E lines (trace.lisp's grammar; TR-APPLY-EVENT applies them).")

(defun rec-wrap-actions ()
  (loop for (sym . describe) in *rec-actions*
        do (let ((orig (fdefinition sym)) (describe describe))
             (setf (fdefinition sym)
                   (lambda (&rest args)
                     (if (or *rec-in-frame* *rec-in-action*)
                         (apply orig args)
                         (progn (rec-between)
                                (format *rec-out* "E~{ ~a~}~%" (mapcar (lambda (x) (if (stringp x) x (tr-print x))) (apply describe args)))
                                (multiple-value-prog1 (let ((*rec-in-action* t)) (apply orig args))
                                  (rec-write-lines (rec-drain) "e ")
                                  (setf *rec-fields* (tr-fields-now))))))))))

(defun rec-wrap-frame ()
  (let ((orig (fdefinition 'engine::%frame)))
    (setf (fdefinition 'engine::%frame)
          (lambda ()
            (rec-between) (write-line "F" *rec-out*) (rec-readers)
            (multiple-value-prog1 (let ((*rec-in-frame* t)) (funcall orig))
              (setf *rec-fields* (tr-fields-now)))))))

(defun rec-load-trial-lib ()
  "tools/simgate/trial.lisp as its runner starts (SG-INIT, the first frame, *SKIP-CINES* T, its definitions, evaluated: their calls go
through the symbols, so the wrappers are seen), without its prelude load (the image is loaded) and its file loop."
  (with-open-file (in (merge-pathnames "../../simgate/trial.lisp" (directory-namestring *load-truename*)))
    (let ((*package* (find-package :cl-user)))
      (loop for form = (read in nil in) until (eq form in)
            unless (and (consp form) (member (car form) '(load with-open-file finish-output ext:quit)))
              do (eval form)))))

(defun rec-run-trials (path)
  "trial.lisp's file loop over PATH, the console bound to *REC-CAP*."
  (with-open-file (in path)
    (let ((*package* (find-package :duel)))
      (loop for tr = (read in nil in) until (eq tr in) do (let ((*standard-output* *rec-cap*)) (trial-run tr))))))

(format *rec-out* "# oracle trace v1: tools/port/oracle/record.lisp~%S~{ ~a~}~%" *rec-start*)
(unless (boundp '*oracle-brain-hook*) (format *rec-real* "record.lisp: not the recorder's image (build-rec.lisp)~%") (ext:quit 2))
(setf *oracle-brain-hook* #'rec-brain)
(cond ((string= (first *rec-start*) "cmds")
       (cl-user::sg-init)
       (setf *step-hook* #'rec-step)
       (dolist (c (rest *rec-start*)) (engine::simgate-cmd (parse-integer c)))
       (tr-run-frames *rec-cap*))
      (t (rec-load-trial-lib)
         (setf *step-hook* #'rec-step)
         (rec-wrap-actions)
         (rec-wrap-frame)
         (rec-run-trials (second *rec-start*))))
(rec-write-lines (rec-drain) (if (string= (first *rec-start*) "cmds") "" "R "))
(close *rec-out*)
(format *rec-real* "~&rec steps ~d start-miss ~d~@[ (steps ~{~d~^ ~})~] post-draw ~d~@[ (steps ~{~d~^ ~})~]~%"
        *rec-steps* (length *rec-start-miss*) (subseq (reverse *rec-start-miss*) 0 (min 20 (length *rec-start-miss*)))
        (length *rec-post-draw*) (subseq (reverse *rec-post-draw*) 0 (min 20 (length *rec-post-draw*))))
(finish-output *rec-real*)
(ext:quit 0)
