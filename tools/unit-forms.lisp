;;;; unit-forms.lisp — the pure-move check for the refactor: compares two concatenated build units
;;;; (build/<target>/game-all.lisp or build/simgate/simgate-all.lisp) as READ FORMS, not text.
;;;;   $ECL_HOST --norc --load unit-forms.lisp -- BASE.lisp NEW.lisp [MACRO ...]
;;;; Reads every top-level form of both files (defpackage / in-package forms are evaluated so symbols land in
;;;; the right package; everything else is data). Prints:
;;;;   1. forms only in BASE / only in NEW (multiset difference, EQUAL on the printed form with full package
;;;;      prefixes): empty for a pure move or a reorder;
;;;;   2. with MACRO names: every form in NEW whose head is one of them is MACROEXPAND-1'd first (the defmacro
;;;;      forms of those names are evaluated from NEW), so a mechanical sweep (mb-at, countdown!, hypot ...)
;;;;      compares equal to the text it replaced;
;;;;   3. definition-order warnings: a defmacro / defconstant / defstruct / defcomponent / deftype / define-modify-macro
;;;;      of NEW whose name is mentioned in an earlier top-level form of NEW (the one thing a reorder can break:
;;;;      a macro used before it is defined compiles as a function call; a constant read before its defconstant
;;;;      is a free variable). A name mentioned only inside a defun body is still flagged (ECL would warn too):
;;;;      check those by hand or move the definition up.
;;;; Exit status 1 when 1. is non-empty. Reading takes ~5 s per 3.7 MB unit.
(defvar *args* (cdr (member "--" ext:*command-args* :test #'string=)))
(defvar *macros* (mapcar (lambda (s) (string-upcase s)) (cddr *args*)))
(defvar *def-kinds* '(defmacro defconstant defstruct defcomponent deftype define-modify-macro define-symbol-macro))

(defun read-unit (path &key expand)
  "The top-level forms of PATH as (string . form) pairs, in order."
  (let ((out nil) (*package* (find-package :cl-user)) (*read-default-float-format* 'single-float) (*read-eval* t))
    (with-open-file (in path)
      (loop for form = (read in nil in) until (eq form in)
            do (cond ((and (consp form) (member (first form) '(defpackage in-package)))
                      (eval form))
                     ((and (consp form) (eq (first form) 'defmacro)
                           (member (string (second form)) *macros* :test #'string=))
                      (eval form) (push form out))
                     ((and expand (consp form) (symbolp (first form))
                           (member (string (first form)) *macros* :test #'string=))
                      (push (macroexpand-1 form) out))
                     (t (push form out)))))
    (nreverse out)))

(defun form-key (form)
  (let ((*package* (find-package :keyword)) (*print-pretty* nil) (*print-case* :upcase) (*print-circle* nil))
    (prin1-to-string form)))

(defun walk-expand (form)
  "Macroexpand-1 the listed macros anywhere inside FORM (a sweep rewrites sites inside defuns)."
  (cond ((atom form) form)
        ((member (car form) '(defmacro quote)) form)        ; (a macro's own definition, quoted data: not calls)
        ((and (symbolp (car form)) (member (string (car form)) *macros* :test #'string=))
         (walk-expand (macroexpand-1 form)))
        (t (let ((a (walk-expand (car form))) (d (walk-expand (cdr form))))
             (if (and (eq a (car form)) (eq d (cdr form))) form (cons a d))))))

(defun def-name (form)
  (when (and (consp form) (member (first form) *def-kinds*) (consp (cdr form)))
    (let ((n (second form))) (if (consp n) (first n) n))))

(defun order-warnings (forms)
  "Names of def-kind forms mentioned (as a symbol) in an earlier top-level form."
  (let ((seen (make-hash-table :test 'eq)) (warn nil))
    (labels ((mark (f) (cond ((symbolp f) (setf (gethash f seen) t))
                             ((consp f) (mark (car f)) (mark (cdr f))))))
      (dolist (f forms (nreverse warn))
        (let ((n (def-name f)))
          (when (and n (gethash n seen)) (push n warn)))
        (mark f)))))

(let* ((base (read-unit (first *args*)))
       (new (read-unit (second *args*) :expand t))
       (new (if *macros* (mapcar #'walk-expand new) new))
       (base (if *macros* (mapcar #'walk-expand base) base))   ; (both sides expanded: pre-existing sites too)
       (kb (mapcar #'form-key base)) (kn (mapcar #'form-key new))
       (hb (make-hash-table :test 'equal)) (hn (make-hash-table :test 'equal)))
  (dolist (k kb) (incf (gethash k hb 0)))
  (dolist (k kn) (incf (gethash k hn 0)))
  (let ((only-base (loop for k being the hash-keys of hb using (hash-value c)
                         when (> c (gethash k hn 0)) collect k))
        (only-new (loop for k being the hash-keys of hn using (hash-value c)
                        when (> c (gethash k hb 0)) collect k)))
    (format t "~&base ~d forms, new ~d forms; only in base ~d, only in new ~d~%" (length base) (length new) (length only-base) (length only-new))
    (dolist (k only-base) (format t "~&- BASE ~a~%" (subseq k 0 (min 160 (length k)))))
    (dolist (k only-new) (format t "~&+ NEW  ~a~%" (subseq k 0 (min 160 (length k)))))
    (let ((w (order-warnings new)))
      (when w (format t "~&order: ~d definitions mentioned before their definition in NEW: ~{~a~^ ~}~%" (length w) w)))
    (format t "~&forms ~a~%" (if (or only-base only-new) "DIFFER" "EQUAL"))
    (ext:quit (if (or only-base only-new) 1 0))))
