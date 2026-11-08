;;;; strat-run.lisp — gate matches with CPUs playing strategy files (docs/duel/DUEL_AI_STRATEGY.md §2, §4). Like run.lisp, and before
;;;; every match's first battle step a CPU gets the strategy its env names: STRAT_<CHARACTER> (e.g. STRAT_KENPACHI=path) for whichever
;;;; seat plays him, STRAT_P1 / STRAT_P2 for a seat (they win over the character's; a mirror needs them). The file holds one plist (READ).
;;;; A character given a strategy plays without his matchup style CPU (*CAI-STYLES*' entries for him removed), so the strategy alone
;;;; drives him. Output: run.lisp's lines, plus "strat P1 <id>" / "strat P2 <id>" once per match.
;;;; A composite (:SWITCH ((OWN . STRATEGY) ...) [:ELSE S], strategy.lisp, DUEL_AI_STRATEGY §8.7) keeps the character's style CPU (the runtime itself
;;;; stops it while a sub is active) and prints once per match and side "switch P<n> <id> judged <J> held <h1> <h2> ...", h_i = the judgements
;;;; entry i won (the rest of J went to :ELSE / none), when the next match starts and at the end.
;;;; STRAT_LAYER=<character>[,<character>] (or "t"): those CPUs under the strategy layer (*STRAT-LAYER*, DUEL_AI_STRATEGY §5, §8.4); its
;;;; RESULTS line "duel stratlayer ..." gives the cost and the picks. STRAT_SET=*knob*=value[,...]: set strategy-layer knobs (numbers) first.
;;;; Usage: ecl-host --norc --load tools/simgate/strat-run.lisp -- <duel.fas> <cmd>...   e.g. 2102 81022 30000 31120 2132
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defun sr-read (path) (and path (plusp (length path)) (with-open-file (in path) (let ((*read-eval* nil)) (read in)))))
(defvar *sr-files* (make-hash-table :test 'equal))
(defun sr-strat (env) (let ((p (ext:getenv env))) (and p (plusp (length p)) (or (gethash p *sr-files*) (setf (gethash p *sr-files*) (sr-read p))))))
(defvar *sr-match* -1)
;;; STRAT_WIN=1: every 90 ticks, per strategy-playing CPU in :idle/:run, one "win" line of situation cues (sitcheck analysis).
(defvar *sr-win* (plusp (length (or (ext:getenv "STRAT_WIN") ""))))
(defun sr-win-lines ()
  (do-sides (e)
    (let* ((f (fighter e)) (b (brain e)) (o (fighter-opp f)) (fo (fighter o)))
      (when (and b (brain-strat b) (member (fighter-state f) '(:idle :run)))
        (let* ((g (gauges e)) (go (gauges o)) (p (pos-of e)) (q (pos-of o))
               (d (sqrt (+ (expt (- (aref p 0) (aref q 0)) 2) (expt (- (aref p 2) (aref q 2)) 2))))
               (rj (strat-reach (kit-command-move (fighter-kit f) :q e))))
          (format t "win ~d t ~d P~d ~a lead ~,1f mr ~,3f or ~,3f d ~,2f dj ~,2f form ~a oform ~a hp ~,3f ohp ~,3f~%"
                  *match-seed* *match-tick* (1+ (fighter-side f)) (getf (brain-strat b) :id)
                  (- (gauges-konpaku g) (gauges-konpaku go))
                  (/ (gauges-reishi g) (float (gauges-reishi-max g))) (/ (gauges-reishi go) (float (gauges-reishi-max go)))
                  d (/ d (max 0.5 rj)) (fighter-form f) (fighter-form fo) (mc-full-health e) (mc-full-health o)))))))
;;; per side, (id n won-copy) of the last step's composite counters (the brains die with their match)
(defvar *sr-sw* (list nil nil))
(defun sr-sw-flush ()
  (loop for side from 0 for r in *sr-sw*
        when r do (format t "switch P~d ~a judged ~d held~{ ~d~}~%" (1+ side) (first r) (second r) (third r)))
  (setf *sr-sw* (list nil nil)))
(defun sr-sw-note ()
  (do-sides (e)
    (let ((b (brain e)))
      (when (and b (brain-strat b) (getf (brain-strat b) :switch))
        (setf (nth (fighter-side (fighter e)) *sr-sw*)
              (list (getf (brain-strat b) :id) (brain-sw-n b)
                    (loop for i below (length (getf (brain-strat b) :switch)) collect (if (brain-sw-won b) (svref (brain-sw-won b) i) 0))))))))
(defun sr-hook ()
  (when (battle-p) (sr-sw-note))
  (when (and *sr-win* (battle-p) (plusp *match-tick*) (zerop (mod *match-tick* 90))) (sr-win-lines))
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (sr-sw-flush)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch)))))
        (when (and b st)
          (setf (brain-strat b) st)
          (unless (getf st :switch) (remf *cai-styles* ch))
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (getf st :id)))))))

(let ((l (ext:getenv "STRAT_LAYER")))
  (when (and l (plusp (length l)))
    (setf *strat-layer* (if (string-equal l "t") t
                            (loop for start = 0 then (1+ p) for p = (position #\, l :start start)
                                  collect (intern (string-upcase (subseq l start p)) :keyword) while p)))))
(let ((l (ext:getenv "STRAT_SET")))
  (when (and l (plusp (length l)))
    (loop for start = 0 then (1+ p) for p = (position #\, l :start start)
          do (let* ((kv (subseq l start p)) (q (position #\= kv)))
               (setf (symbol-value (intern (string-upcase (subseq kv 0 q)) :duel)) (let ((*read-eval* nil)) (read-from-string (subseq kv (1+ q))))))
          while p)))
(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'sr-hook)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(sr-sw-flush)
(finish-output)
(ext:quit 0)
