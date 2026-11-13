;;;; dump.lisp — write strategy units as raw, READable arm files for the SP search (docs/research/strategy-drsi/sp/README.md).
;;;; A raw file (STRAT_P<n>, strategy-switch.py --raw) is READ straight into BRAIN-STRAT: nothing expands :STYLE / :DATA at run time, so an
;;;; arm must be written expanded. ID = an arm unit (*STRAT-UNITS-EXPANDED*, e.g. a-ken-ki) or a library entry (*STRAT-LIBRARY*, e.g. s1-brawler).
;;;; Usage (repo root): $ECL_HOST --norc --load docs/research/strategy-drsi/sp/arms/dump.lisp -- build/simgate/duel.fas ID...
(defparameter cl-user::*args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*args*) :verbose nil)
(in-package :duel)
(dolist (id (rest cl-user::*args*))
  (let* ((k (intern (string-upcase id) :keyword))
         (st (or (find k *strat-units-expanded* :key (lambda (s) (getf s :id))) (find k *strat-library* :key (lambda (s) (getf s :id)))))
         (path (format nil "docs/research/strategy-drsi/sp/arms/~(~a~).lisp" id)))
    (unless st (format t "no unit or library entry ~a~%" id) (ext:quit 1))
    (with-open-file (o path :direction :output :if-exists :supersede)
      (let ((*print-pretty* nil) (*print-case* :downcase) (*read-default-float-format* 'single-float) (*package* (find-package :duel)))
        (format o ";; ~(~a~) as expanded in strategy.lisp (sp/arms/dump.lisp)~%~s~%" id st)))
    (with-open-file (in path)
      (let ((*read-eval* nil) (*package* (find-package :duel)))
        (format t "~a ~a fn ~(~a~)~%" path (if (equal (read in) st) "round-trips" "DIFFERS") (getf st :fn))))))
(ext:quit 0)
