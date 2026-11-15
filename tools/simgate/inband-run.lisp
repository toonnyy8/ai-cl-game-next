;;;; inband-run.lisp — strat-run.lisp with PLAN4 §3 step 4's in-band randomisation (docs/research/strategy-drsi/sp/arms5/inband.md).
;;;; It evaluates strat-run.lisp form by form (that file stays byte for byte as it is, so its build hash and every cache keyed on it hold) and,
;;;; just before the matches start, puts its judge hook in front of strat-run's (STRAT_FQLOG's, when set).
;;;; STRAT_INBAND="<seat 1|2> <arm k> <salt>": on that seat's Q selector, every run of judgements whose table pick is arm K (a maximal stretch
;;;; of consecutive judgements with pick K) is played by arm K or by arm 0, a coin per run drawn from (match seed, tick, side, salt) with
;;;; strat-run's SR-FQ-U (never SIM-RND01). STRAT_INBAND="<seat> <arm k> <salt> <p>": the coin plays arm K with chance P or 1 - P,
;;;; one of the two per match (a second SR-FQ-U draw at tick -1, salt + 7919), so a match's share of arm K spreads toward 0 or 1.
;;;; One line per judgement of such a run: "ib <seed> <tick> P<n> <arm played>". Unset: strat-run.lisp exactly (checked by inband.py selftest; arm K = 0 is also strat-run exactly: its runs are arm 0 either way).
;;;; Usage: ecl-host --norc --load tools/simgate/inband-run.lisp -- <duel.fas> <cmd>...   (strat-run.lisp's)
(defvar cl-user::*ib-tail* nil)
(let ((path (merge-pathnames "strat-run.lisp" (directory-namestring *load-truename*))) (*package* *package*))
  (with-open-file (in path)
    (loop for form = (read in nil in) until (eq form in)
          do (if (or cl-user::*ib-tail* (equal form '(cl-user::sg-init)))
                 (push form cl-user::*ib-tail*)                      ; (from the startup on: run after the hook below)
                 (eval form))))
  (setf cl-user::*ib-tail* (nreverse cl-user::*ib-tail*)))
(in-package :duel)
(defvar *ib* (let ((l (ext:getenv "STRAT_INBAND"))) (and l (plusp (length l)) (with-input-from-string (in l) (list (read in) (read in) (read in) (read in nil nil))))))
(defvar *ib-run* (list nil nil) "Per side, the current run of pick-K judgements: (seed arm-played), or NIL.")
(defvar *ib-prev* *strat-judge-hook*)
(defun ib-p (side)
  "This match's chance that a run of pick-K judgements is played by arm K (0.5, or P / 1 - P by a per-match draw)."
  (let ((p (fourth *ib*)))
    (if (null p) 0.5d0 (if (< (sr-fq-u *match-seed* -1 side (+ (third *ib*) 7919)) 0.5d0) p (- 1 p)))))
(defun ib-judge (e b sw sub i feats)
  (multiple-value-bind (sub i) (if *ib-prev* (funcall *ib-prev* e b sw sub i feats) (values sub i))
    (let ((side (fighter-side (fighter e))) (k (second *ib*)))
      (cond ((/= side (1- (first *ib*))) (values sub i))
            ((/= i k) (setf (nth side *ib-run*) nil) (values sub i))
            (t (let ((run (nth side *ib-run*)))
                 (when (or (null run) (/= (first run) *match-seed*))
                   (setf run (list *match-seed* (if (< (sr-fq-u *match-seed* *match-tick* side (third *ib*)) (ib-p side)) k 0))
                         (nth side *ib-run*) run))
                 (format t "ib ~d ~d P~d ~d~%" *match-seed* *match-tick* (1+ side) (second run))
                 (if (= (second run) k) (values sub i) (values (first (getf (getf sw :fq) :arms)) 0))))))))
(when *ib* (setf *strat-judge-hook* #'ib-judge))
(dolist (form cl-user::*ib-tail*) (eval form))
