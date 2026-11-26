;;;; defparams.lisp — the Bevy port extractor's tuning names (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Task 5):
;;;; CL-USER::SOURCE-DEFPARAMETERS (dirs) -> every symbol a source file names in a (DEFPARAMETER NAME ...) form, at top level or
;;;; inside PROGN / EVAL-WHEN, over each DIR's MANIFEST .lisp files in order (DIRS relative to *DEFAULT-PATHNAME-DEFAULTS*, e.g.
;;;; ("engine" "duel")). Read with *READ-EVAL* NIL; #. reads its form unevaluated (a placeholder: only names matter here).
;;;; IN-PACKAGE forms switch the reading package, as the build does. Needs the game's packages (load the image first).
(in-package :cl-user)

(defun manifest-lisp-files (dir)
  "DIR's MANIFEST .lisp entries in order (tools/simgate/build.lisp's rule)."
  (with-open-file (in (format nil "~a/MANIFEST" dir))
    (loop for l = (read-line in nil) while l
          for s = (string-trim " " l)
          when (and (plusp (length s)) (char/= (char s 0) #\#) (search ".lisp" s)) collect (format nil "~a/~a" dir s))))

(defun source-defparameters (dirs)
  (let ((rt (copy-readtable nil)) (out nil) (seen (make-hash-table :test 'eq)))
    (set-dispatch-macro-character #\# #\. (lambda (s c n) (declare (ignore c n)) (list 'read-eval (read s t nil t))) rt)
    (labels ((scan (form)
               (when (consp form)
                 (case (car form)
                   (defparameter (let ((name (second form))) (unless (gethash name seen) (setf (gethash name seen) t) (push name out))))
                   ((progn eval-when) (mapc #'scan (if (eq (car form) 'eval-when) (cddr form) (cdr form))))))))
      (dolist (f (loop for d in dirs append (manifest-lisp-files d)) (nreverse out))
        (with-open-file (in f :external-format :utf-8)
          (let ((*readtable* rt) (*read-eval* nil) (*package* (find-package :cl-user)))
            (loop for form = (read in nil in) until (eq form in)
                  do (if (and (consp form) (eq (car form) 'in-package))
                         (setf *package* (find-package (second form)))
                         (scan form)))))))))
