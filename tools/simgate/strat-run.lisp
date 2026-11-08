;;;; strat-run.lisp — gate matches with CPUs playing strategy files (docs/duel/DUEL_AI_STRATEGY.md §2, §4). Like run.lisp, and before
;;;; every match's first battle step a CPU gets the strategy its env names: STRAT_<CHARACTER> (e.g. STRAT_KENPACHI=path) for whichever
;;;; seat plays him, STRAT_P1 / STRAT_P2 for a seat (they win over the character's; a mirror needs them). The file holds one plist (READ).
;;;; A character given a strategy plays without his matchup style CPU (*CAI-STYLES*' entries for him removed), so the strategy alone
;;;; drives him. Output: run.lisp's lines, plus "strat P1 <id>" / "strat P2 <id>" once per match.
;;;; Usage: ecl-host --norc --load tools/simgate/strat-run.lisp -- <duel.fas> <cmd>...   e.g. 2102 81022 30000 31120 2132
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defun sr-read (path) (and path (plusp (length path)) (with-open-file (in path) (let ((*read-eval* nil)) (read in)))))
(defvar *sr-files* (make-hash-table :test 'equal))
(defun sr-strat (env) (let ((p (ext:getenv env))) (and p (plusp (length p)) (or (gethash p *sr-files*) (setf (gethash p *sr-files*) (sr-read p))))))
(defvar *sr-match* -1)
(defun sr-hook ()
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch)))))
        (when (and b st)
          (setf (brain-strat b) st)
          (remf *cai-styles* ch)
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (getf st :id)))))))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'sr-hook)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(finish-output)
(ext:quit 0)
