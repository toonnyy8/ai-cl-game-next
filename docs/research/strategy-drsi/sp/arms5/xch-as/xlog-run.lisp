;;;; xlog-run.lisp — tools/simgate/strat-run.lisp, evaluated form by form as duct-run.lisp does, with the combat log on in battle (the
;;;; pairing gate turns it off), so xlog.py can count the ASs out of a cancel and the next real hit. Usage: as strat-run.lisp.
(let ((*package* *package*) (dir (merge-pathnames "tools/simgate/" (truename "."))))
  (with-open-file (in (merge-pathnames "strat-run.lisp" dir))
    (loop for form = (read in nil in) until (eq form in)
          do (cond ((and (consp form) (eq (car form) 'load))      ; (its prelude, relative to strat-run.lisp, not to this file)
                    (load (merge-pathnames "prelude.lisp" dir) :verbose nil))
                   ((and (consp form) (eq (car form) 'setf) (symbolp (second form)) (string= (symbol-name (second form)) "*STEP-HOOK*"))
                    (eval form)
                    (let ((sr (symbol-value (find-symbol "*STEP-HOOK*" "DUEL"))) (log (find-symbol "*COMBAT-LOG*" "DUEL")))
                      (setf (symbol-value (find-symbol "*STEP-HOOK*" "DUEL"))
                            (lambda () (funcall sr) (setf (symbol-value log) (funcall (find-symbol "BATTLE-P" "DUEL")))))))
                   (t (eval form))))))
