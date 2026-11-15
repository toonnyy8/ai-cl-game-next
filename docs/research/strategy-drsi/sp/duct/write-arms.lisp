;;;; write-arms.lisp — DUCT's arms with the pairing's exchange unit laid under them by the game's own STRAT-WITH (PLAN4 §3 :with, §6).
;;;; Run by sp/duct.py arms: ecl --norc --load docs/research/strategy-drsi/sp/duct/write-arms.lisp -- build/simgate/duel.fas SPEC
;;;; SPEC holds forms (OUT ARM-FILE ARM-ID UNIT-FILE-OR-NIL NEW-ID APPLY): ARM-ID is read from ARM-FILE (one or more plists), the unit (one
;;;; plist) laid under it, :id and :apply replaced (neither changes play), one inline plist written to OUT. A raw file is never expanded by
;;;; strat-run.lisp, so the matrix plays exactly the text the anchor embeds.
(load (merge-pathnames "../../../../../tools/simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)
(defun dw-forms (path)
  (with-open-file (in path) (let ((*read-eval* nil)) (loop for f = (read in nil in) until (eq f in) collect f))))
(dolist (s (dw-forms (second cl-user::*sg-args*)))
  (destructuring-bind (out file id unit new-id apply) s
    (let* ((arm (or (find id (dw-forms file) :key (lambda (f) (getf f :id))) (error "no arm ~s in ~a" id file)))
           (u (and unit (first (dw-forms unit))))
           (m (strat-with arm (and u (list u))))
           (m (list* :id new-id :apply apply (loop for (k v) on m by #'cddr unless (member k '(:id :apply)) append (list k v)))))
      (with-open-file (o out :direction :output :if-exists :supersede)
        (let ((*print-pretty* nil) (*print-case* :downcase) (*read-default-float-format* 'single-float) (*package* (find-package :duel)))
          (format o ";; ~(~s~) from ~a~@[ with the unit ~a laid under it (STRAT-WITH)~] (sp/duct.py arms)~%~s~%" id file unit m))))))
(ext:quit 0)
