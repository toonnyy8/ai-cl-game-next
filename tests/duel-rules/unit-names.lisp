;; ================================================================ one name, one definition in the build unit
;; The engine's and the game's .lisp files (engine/MANIFEST, duel/MANIFEST) become ONE ECL unit: a top-level DEFUN / DEFMACRO /
;; DEFUN-FAST of the same name twice is silently the later one (the Lisp HUD's macro HS over Hisagi's function HS, 2026-11-11:
;; "not a lisp data object" the moment a human Hisagi's battle began; ALPHA! likewise). The scan reads column-0 forms by text.
(in-package :duel)

(defun un-lines (rel)
  (with-open-file (s (concatenate 'string (directory-namestring *load-truename*) "../../" rel) :external-format :utf-8)
    (loop for l = (read-line s nil) while l collect l)))

(defun un-sources (manifest dir)
  "The .lisp paths (relative to the repo) of MANIFEST, in order."
  (loop for l in (un-lines manifest)
        for tl = (string-trim " " l)
        when (and (> (length tl) 5) (char/= (char tl 0) #\#) (string= ".lisp" (subseq tl (- (length tl) 5))))
          collect (concatenate 'string dir tl)))

(defun un-defs (path)
  "The names of PATH's column-0 (defun|defmacro|defun-fast NAME ...) forms (lower case)."
  (loop for l in (un-lines path)
        for sp = (position #\Space l)
        when (and sp (> (length l) 1) (char= (char l 0) #\()
                  (member (subseq l 1 sp) '("defun" "defmacro" "defun-fast") :test #'string-equal))
          collect (let* ((rest (subseq l (1+ sp))) (end (position-if (lambda (c) (member c '(#\Space #\( #\)))) rest)))
                    (string-downcase (subseq rest 0 end)))))

(let ((seen (make-hash-table :test 'equal)) (dups nil))
  (dolist (f (append (un-sources "engine/MANIFEST" "engine/") (un-sources "duel/MANIFEST" "duel/")))
    (dolist (n (remove "" (un-defs f) :test #'string=))   ; ((setf x)) forms read as ""
      (when (gethash n seen) (push (list n (gethash n seen) f) dups))
      (setf (gethash n seen) f)))
  (check (> (hash-table-count seen) 2000))      ; the scan reads the whole unit
  (check (null dups))
  (when dups (format t "defined twice: ~s~%" dups)))

;; Variables too, anywhere in a line (several definitions can share one): the +c-dim+ case (2026-11-11), where the pause's
;; dim rect drew the menus' slate colour. A name must be followed by a space, so a forward declaration (defvar *x*) is no definition.
(defun un-var-names (l kw &optional (from 0))
  "The names that the prefix KW (e.g. \"(defvar \") introduces in line L from FROM on (lower case)."
  (let ((p (search kw l :start2 from)))
    (when p
      (let* ((start (+ p (length kw)))
             (end (position-if (lambda (c) (member c '(#\Space #\( #\)))) l :start start)))
        (append (when (and end (char= (char l end) #\Space)) (list (string-downcase (subseq l start end))))
                (un-var-names l kw start))))))

(defun un-vars (path)
  "The names of PATH's defparameter / defvar / defconstant forms (comment lines skipped)."
  (loop for l in (un-lines path)
        for tl = (string-left-trim " " l)
        unless (or (= (length tl) 0) (char= (char tl 0) #\;))
          nconc (loop for kw in '("(defparameter " "(defvar " "(defconstant ")
                      nconc (un-var-names l kw))))

(let ((seen (make-hash-table :test 'equal)) (dups nil))
  (dolist (f (append (un-sources "engine/MANIFEST" "engine/") (un-sources "duel/MANIFEST" "duel/")))
    (dolist (n (un-vars f))
      (unless (member n '("*fire-density*" "*weave-pass*") :test #'string=)   ; known harmless same-value pairs
        (when (gethash n seen) (push (list n (gethash n seen) f) dups))
        (setf (gethash n seen) f))))
  (check (null dups))
  (when dups (format t "defined twice: ~s~%" dups)))
