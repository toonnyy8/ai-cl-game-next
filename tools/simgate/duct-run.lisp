;;;; duct-run.lisp — strat-run.lisp, unchanged and evaluated form by form, plus DUCT's per-seat budget and arm counters (PLAN4 §6, D1-D2;
;;;; docs/research/strategy-drsi/sp/duct.py). strat-run.lisp is not edited, so the round's SP_BUILD pin (strategy-switch.py's hash of the fas
;;;; + strat-run.lisp) holds. Every env of strat-run.lisp works as there; added (tools/simgate/duct-hook.lisp):
;;;;   DUCT_BUDGET_P1 / DUCT_BUDGET_P2="<rolls> <h> <period>": that seat's strategy-layer budget (*STRAT-ROLLS* / *STRAT-H* set per selection
;;;;   job from the job's side, the next selection re-stamped to its own period), so two budgets can play each other; unset: the globals.
;;;;   Always: one "duct <seed> P<n> changes C held <id>:<steps> ..." line per match and layered side (the live strategy's id each battle step,
;;;;   outside rollouts).
;;;; Usage: as strat-run.lisp: ecl-host --norc --load tools/simgate/duct-run.lisp -- <duel.fas> <cmd>...
(let ((*package* *package*) (dir (directory-namestring *load-truename*)))
  (with-open-file (in (merge-pathnames "strat-run.lisp" dir))
    (loop for form = (read in nil in) until (eq form in)
          do (cond ((equal form '(cl-user::sg-init))                ; (after strat-run's definitions and env reads, before the run)
                    (load (merge-pathnames "duct-hook.lisp" dir) :verbose nil) (eval form))
                   ((and (consp form) (eq (car form) 'setf) (symbolp (second form)) (string= (symbol-name (second form)) "*STEP-HOOK*"))
                    (eval form) (funcall (find-symbol "DUCT-INSTALL" "DUEL")))
                   ((equal form '(finish-output))
                    (funcall (find-symbol "DUCT-FLUSH" "DUEL")) (eval form))
                   (t (eval form))))))
