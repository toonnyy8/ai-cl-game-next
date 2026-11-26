;;;; build-rec.lisp — the recorder's image (record.lisp): tools/simgate/build.lisp's unit (build/simgate/simgate-all.lisp, the stock
;;;; engine + duel sources) with ONE observation hook, a funcall of *ORACLE-BRAIN-HOOK* right after (BRAIN-SYSTEM) in SIM-SYSTEMS (the
;;;; only point where the brains' writes, the sim stream after them and the CPUs' own log lines can be told apart: BRAIN-SYSTEM is a
;;;; compiled direct call, so a runtime wrapper never runs). NIL by default, so the image plays exactly as the stock one; record.lisp
;;;; proves it per trace (its 600-tick hash lines and RESULTS against a plain tools/simgate/run.lisp run, gen.py). Compiled with
;;;; build.lisp's settings. The unit is a scratch copy in build/ (docs/bevy/BEVY_PORT.md §6.1: a recording hook only in a scratch copy
;;;; of the frozen build, never in duel/). Usage: ecl-host --norc --load tools/port/oracle/build-rec.lisp   (-> build/oracle/rec/duel.fas)
(require :cmp)
(defparameter *root* (truename (merge-pathnames "../../../" (directory-namestring *load-truename*))))
(defun root (p) (namestring (merge-pathnames p *root*)))
(setf *default-pathname-defaults* *root*)
(defun replace-once (s old new)
  (let ((i (search old s)))
    (unless (and i (null (search old s :start2 (1+ i)))) (error "build-rec: ~s must occur exactly once in the unit" old))
    (concatenate 'string (subseq s 0 i) new (subseq s (+ i (length old))))))
(let* ((src (root "build/simgate/simgate-all.lisp")) (out (root "build/oracle/rec/duel.fas"))
       (unit (root "build/oracle/rec/simgate-all.lisp"))
       (text (with-open-file (in src) (let ((s (make-string (file-length in)))) (subseq s 0 (read-sequence s in))))))
  (setf text (replace-once text "(defun sim-systems ()"
                           (format nil "(defvar *oracle-brain-hook* nil \"tools/port/oracle/record.lisp's hook after BRAIN-SYSTEM.\")~%(defun sim-systems ()"))
        text (replace-once text "  (brain-system)                        ; CPU players write their vpads"
                           "  (brain-system) (when *oracle-brain-hook* (funcall *oracle-brain-hook*))"))
  (ensure-directories-exist out)
  (with-open-file (o unit :direction :output :if-exists :supersede) (write-string text o))
  ;; tools/simgate/build.lisp's compile settings, as they are there
  (setf c::*cc-flags* (format nil "~a -msse2 -mfpmath=sse -ffp-contract=off -I~a -I~a -I~a" c::*cc-flags*
                              (root "tools/simgate/include") (namestring *root*) (root "vendor/sdl3-webgpu/include")))
  (setf ext:*register-with-pde-hook* nil si::*keep-documentation* nil)
  (let* ((pv si::+ecl-syntax-progv-list+) (i (position '*print-circle* (car pv))))
    (setf (nth i (cdr pv)) nil))
  (ext:quit (if (compile-file unit :output-file out) 0 1)))
