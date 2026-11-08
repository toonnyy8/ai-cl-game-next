;;;; strat-run.lisp — gate matches with CPUs playing strategy files (docs/duel/DUEL_AI_STRATEGY.md §2, §4). Like run.lisp, and before
;;;; every match's first battle step a CPU gets the strategy its env names: STRAT_<CHARACTER> (e.g. STRAT_KENPACHI=path) for whichever
;;;; seat plays him, STRAT_P1 / STRAT_P2 for a seat (they win over the character's; a mirror needs them). The file holds one plist (READ).
;;;; A character given a strategy plays without his matchup style CPU (*CAI-STYLES*' entries for him removed), so the strategy alone
;;;; drives him. Output: run.lisp's lines, plus "strat P1 <id>" / "strat P2 <id>" once per match.
;;;; A composite (:SWITCH ((OWN . STRATEGY) ...) [:ELSE S], strategy.lisp, DUEL_AI_STRATEGY §8.7) keeps the character's style CPU (the runtime itself
;;;; stops it while a sub is active) and prints once per match and side "switch P<n> <id> judged <J> held <h1> <h2> ...", h_i = the judgements
;;;; entry i won (the rest of J went to :ELSE / none), when the next match starts and at the end.
;;;; A Q selector (:FQ, strategy.lisp) is kept like a composite (its "switch" line's h_i = the judgements arm i won); STRAT_FQLOG logs its
;;;; judgements for training (below); STRAT_FQLEARN runs the online fuzzy Q learner against a player proxy (below).
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
      (when (and b (brain-strat b) (or (getf (brain-strat b) :switch) (getf (brain-strat b) :fq)))
        (setf (nth (fighter-side (fighter e)) *sr-sw*)
              (list (getf (brain-strat b) :id) (brain-sw-n b)
                    (loop for i below (length (or (getf (brain-strat b) :switch) (getf (getf (brain-strat b) :fq) :arms)))
                          collect (if (brain-sw-won b) (svref (brain-sw-won b) i) 0))))))))
;;; STRAT_FQLOG="<salt> <eps>": the Q selector's training log (DUEL_AI_STRATEGY §8.12, docs/research/strategy-drsi/fq/). On each judgement of a
;;; :FQ strategy outside rollouts, with chance EPS the other arm (two arms) instead of the table's: drawn from a hash of (match seed, tick,
;;; side, salt), never SIM-RND01. One line a judgement: "fq <seed> <tick> P<n> lead L ored R ost S mr M or O dj D awk A prev P greedy G arm K
;;; h H oh OH" (H = mc-full-health, mine and his); "fqend <seed> P<n> h H oh OH" when the match ends (the last step's values).
(defvar *sr-fq* (let ((l (ext:getenv "STRAT_FQLOG"))) (and l (plusp (length l)) (with-input-from-string (in l) (list (read in) (read in))))))
(defun sr-fq-u (seed tick side salt)
  "A uniform 0-1 number from (SEED TICK SIDE SALT) alone: a Park-Miller generator stirred a few times."
  (let ((x (1+ (mod (+ (* seed 1000003) (* tick 7919) (* side 104729) (* salt 15485863)) 2147483646))))
    (dotimes (i 4) (setf x (mod (* x 48271) 2147483647)))
    (/ x 2147483647d0)))
(defvar *sr-fq-last* (list nil nil) "Per side, the last step's (seed h oh) of a logging CPU.")
(defun sr-fq-judge (e b sw sub i feats)
  (declare (ignore b))
  (let* ((f (fighter e)) (side (fighter-side f)) (arms (getf (getf sw :fq) :arms))
         (k (if (and arms (= 2 (length arms)) (< (sr-fq-u *match-seed* *match-tick* side (first *sr-fq*)) (second *sr-fq*))) (- 1 i) i)))
    (format t "fq ~d ~d P~d lead ~d ored ~d ost ~d mr ~,3f or ~,3f dj ~,2f awk ~d prev ~d greedy ~d arm ~d h ~,3f oh ~,3f~%"
            *match-seed* *match-tick* (1+ side) (getf feats :lead) (getf feats :ored) (getf feats :ost) (getf feats :mr) (getf feats :or)
            (getf feats :dj) (getf feats :awk) (getf feats :prev) i k (mc-full-health e) (mc-full-health (fighter-opp f)))
    (if (= k i) (values sub i) (values (nth k arms) k))))
(defun sr-fq-note ()
  (do-sides (e)
    (let ((b (brain e)))
      (when (and b (brain-strat b) (getf (brain-strat b) :fq))
        (setf (nth (fighter-side (fighter e)) *sr-fq-last*) (list *match-seed* (mc-full-health e) (mc-full-health (fighter-opp (fighter e)))))))))
(defun sr-fq-flush ()
  (loop for side from 0 for r in *sr-fq-last*
        when r do (format t "fqend ~d P~d h ~,3f oh ~,3f~%" (first r) (1+ side) (second r) (third r)))
  (setf *sr-fq-last* (list nil nil)))
(when *sr-fq* (setf *strat-judge-hook* #'sr-fq-judge))
;;; STRAT_FQLEARN="<in> <out>" (DUEL_AI_STRATEGY §8.14): every Q-selector CPU learns online as against a human (*FQ-LEARN-FORCE*), its table
;;; carried from match to match; IN (or "-": none) is a table written by an earlier run, OUT gets the table at the end: the strategy plist plus
;;; :matches, keyed by its :apply (me vs). A player proxy is the other seat's CPU (STRAT_<CHARACTER>); don't give the learner's seat a STRAT_.
(defvar *sr-fql* (let ((l (ext:getenv "STRAT_FQLEARN"))) (and l (plusp (length l)) l)))
(when *sr-fql*
  (let* ((l *sr-fql*) (sp (position #\Space l)) (in (subseq l 0 sp)) (out (subseq l (1+ sp))))
    (setf *sr-fql* out *fq-learn-force* t)
    (unless (string= in "-")
      (let* ((st (sr-read in)) (ap (getf st :apply)))
        (push (cons (cons (position (first ap) *roster*) (position (second ap) *roster*)) (cons st (getf st :matches 0))) *fq-tables*)))))
(defun sr-fql-dump ()
  (when *sr-fql*
    (with-open-file (o *sr-fql* :direction :output :if-exists :supersede)
      (dolist (en *fq-tables*)                                ; (one form a table; the evaluator reads the first)
        (let ((st (cadr en)) (*print-pretty* nil) (*read-default-float-format* 'single-float))
          (format o "~s~%" (list* :matches (cddr en) (loop for (k v) on st by #'cddr unless (eq k :matches) append (list k v)))))))))
(defun sr-hook ()
  (when (and *sr-win* (battle-p) (plusp *match-tick*) (zerop (mod *match-tick* 90))) (sr-win-lines))
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (sr-sw-flush)
    (sr-fq-flush)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch)))))
        (when (and b st)
          (setf (brain-strat b) st)
          (unless (or (getf st :switch) (getf st :fq)) (remf *cai-styles* ch))
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (getf st :id))))))
  (when (battle-p) (sr-sw-note) (when *sr-fq* (sr-fq-note))))   ; (after a new match's flush: else its first step's counts replace the last match's)

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
(sr-fq-flush)
(sr-fql-dump)
(finish-output)
(ext:quit 0)
