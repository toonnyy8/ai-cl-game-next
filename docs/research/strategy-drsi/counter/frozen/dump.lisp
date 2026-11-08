;;;; dump.lisp — write library strategies (duel/lisp/strategy.lisp *STRAT-LIBRARY*) to frozen files, one READable plist each, so a pairing's
;;;; opponent stays what it was when frozen whatever later becomes of the library or the lookup (DUEL_AI_STRATEGY §8.15, counter/README.md).
;;;; Usage (repo root): $ECL_HOST --norc --load docs/research/strategy-drsi/counter/frozen/dump.lisp -- build/simgate/duel.fas ID...
(defparameter cl-user::*args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*args*) :verbose nil)
(in-package :duel)
(dolist (id (rest cl-user::*args*))
  (let ((st (find (intern (string-upcase id) :keyword) *strat-library* :key (lambda (s) (getf s :id))))
        (path (format nil "docs/research/strategy-drsi/counter/frozen/~(~a~).lisp" id)))
    (unless st (format t "no library entry ~a~%" id) (ext:quit 1))
    (with-open-file (o path :direction :output :if-exists :supersede)
      (let ((*print-pretty* nil) (*print-case* :downcase) (*read-default-float-format* 'single-float) (*package* (find-package :duel)))
        (format o ";; ~(~a~) as in *strat-library* (frozen 2026-11-09 by frozen/dump.lisp)~%~s~%" id st)))
    (with-open-file (in path)
      (let ((*read-eval* nil) (*package* (find-package :duel)))
        (format t "~a ~a~%" path (if (equal (read in) st) "round-trips" "DIFFERS"))))))
(ext:quit 0)
