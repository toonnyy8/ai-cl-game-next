;;;; probe.lisp — where Hisagi's CPU starts its moves (PLAN4 kit study, strategies.md §1): gate matches as run.lisp plays them, STRAT_P1 /
;;;; STRAT_P2 strategy files as prelude.lisp applies them; for each Hisagi seat every move start is tallied by form, move, start distance
;;;; band (< 3.0, 3.0-6.4, > 6.4 m) and its outcome (hit: his Reishi fell while it ran; touch: a contact without damage, i.e. a cancel or
;;;; armour; whiff: neither), and every free (idle / run) step by band.
;;;; Usage: ecl-host --norc --load docs/research/strategy-drsi/sp/kits/hisagi/probe.lisp -- <duel.fas> 30500 31120 81022 200710
;;;; (seeds from 501, 20 matches, HARD, Hisagi vs Kenpachi); output "probe ..." lines at the end. Reads the sim only (no state written).
(load (merge-pathnames "../../../../../../tools/simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)
(cl-user::sg-init)
(cl-user::sg-queue)
;;; PROBE_LOG=1: the combat log on, and a "probe-end SIDE MOVE BAND OUTCOME" line as each Hisagi move ends (probe.py attributes each NAGI
;;; start to the CPU decision line logged before it: kk pick / cpu clash / hr / hk, else none logged: the generic neutral or the MCTS).
(defvar *pr* (make-hash-table :test 'equal))
(defvar *pr-log* (plusp (length (or (ext:getenv "PROBE_LOG") ""))))
(when *pr-log* (setf *combat-log* t))
(defvar *pr-last* (vector nil nil))   ; per side: (move sf d contact form reishi0)
(defun pr-band (d) (cond ((< d 3.0) "<3.0") ((<= d 6.4) "3.0-6.4") (t ">6.4")))
(defun pr-close (k)
  (let ((l (svref *pr-last* k)))
    (when l (destructuring-bind (mv sf d contact form r0) l
              (declare (ignore sf))
              (let ((hit (< (gauges-reishi (gauges (opp-of (if (= k 0) *p1* *p2*)))) r0)))
                (incf (gethash (list form (mv-name mv) (pr-band d) (cond (hit :hit) (contact :touch) (t :whiff))) *pr* 0))
                (when *pr-log* (log-msg "probe-end P~d ~a ~a ~(~a~)" (1+ k) (mv-name mv) (pr-band d) (cond (hit :hit) (contact :touch) (t :whiff)))))))
    (setf (svref *pr-last* k) nil)))
(setf *step-hook*
      (lambda ()
        (cl-user::sg-strat-step)
        (when *pr-log* (setf *combat-log* t))             ; (the gate's start turns it off: gate.lisp)
        (when (and (battle-p) (eq *flow* :battle))
          (do-sides (e)
            (let* ((f (fighter e)) (k (fighter-side f)))
              (when (eq (fighter-character f) :hisagi)
                (let ((l (svref *pr-last* k)) (d (fighter-dist f)))
                  (if (eq (fighter-state f) :move)
                      (let ((mv (fighter-move f)) (sf (fighter-sf f)))
                        (if (and l (eq mv (first l)) (>= sf (second l)))
                            (setf (second l) sf (fourth l) (or (fourth l) (fighter-contact f)))
                            (progn (pr-close k)
                                   (setf (svref *pr-last* k) (list mv sf d (fighter-contact f) (fighter-form f)
                                                                   (gauges-reishi (gauges (opp-of e))))))))
                      (progn (pr-close k)
                             (when (member (fighter-state f) '(:idle :run))
                               (incf (gethash (list (fighter-form f) :free (pr-band d) nil) *pr* 0))))))))))))
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(maphash (lambda (k v) (format t "probe ~{~(~a~)~^ ~} ~d~%" k v)) *pr*)
(finish-output)
(ext:quit 0)
