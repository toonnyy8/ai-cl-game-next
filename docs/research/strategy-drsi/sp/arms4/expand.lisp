;;;; expand.lisp — PLAN4 B3: arms4/<char>.lisp's unit forms -> raw arm files arms4/<char>/<id>.lisp (STRAT-COMPOSE, as sp/arms/dump.lisp
;;;; writes the library's). Usage (repo root):
;;;;   $ECL_HOST --norc --load docs/research/strategy-drsi/sp/arms4/expand.lisp -- build/simgate/duel.fas hisagi
(defparameter cl-user::*args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*args*) :verbose nil)
(in-package :duel)
(let* ((ch (second cl-user::*args*)) (dir (format nil "docs/research/strategy-drsi/sp/arms4/~a/" ch)))
  (ensure-directories-exist dir)
  (with-open-file (in (format nil "docs/research/strategy-drsi/sp/arms4/~a.lisp" ch))
    (let ((*read-eval* nil) (*package* (find-package :duel)))
      (loop for u = (read in nil :eof) until (eq u :eof)
            do (let ((st (strat-compose u)) (path (format nil "~a~(~a~).lisp" dir (symbol-name (getf u :id)))))
                 (with-open-file (o path :direction :output :if-exists :supersede)
                   (let ((*print-pretty* nil) (*print-case* :downcase) (*read-default-float-format* 'single-float))
                     (format o ";; ~(~a~) expanded from arms4/~a.lisp (arms4/expand.lisp)~%~s~%" (getf u :id) ch st)))
                 (format t "~a fn ~(~a~)~%" path (getf st :fn)))))))
(ext:quit 0)
