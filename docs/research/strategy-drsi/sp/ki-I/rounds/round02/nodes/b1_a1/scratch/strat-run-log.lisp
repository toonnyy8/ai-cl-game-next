;;;; strat-run.lisp — gate matches with CPUs playing strategy files (docs/duel/DUEL_AI_STRATEGY.md §2, §4). Like run.lisp, and before
;;;; every match's first battle step a CPU gets the strategy its env names: STRAT_<CHARACTER> (e.g. STRAT_KENPACHI=path) for whichever
;;;; seat plays him, STRAT_P1 / STRAT_P2 for a seat (they win over the character's; a mirror needs them). The file holds one plist (READ).
;;;; A character given a strategy plays without his matchup style CPU (*CAI-STYLES*' entries for him removed), so the strategy alone
;;;; drives him. Output: run.lisp's lines, plus "strat P1 <id>" / "strat P2 <id>" once per match.
;;;; A composite (:SWITCH ((OWN . STRATEGY) ...) [:ELSE S], strategy.lisp, DUEL_AI_STRATEGY §8.7) keeps the character's style CPU (the runtime itself
;;;; stops it while a sub is active) and prints once per match and side "switch P<n> <id> judged <J> held <h1> <h2> ...", h_i = the judgements
;;;; entry i won (the rest of J went to :ELSE / none), when the next match starts and at the end. A Q selector with :EVENT-ARMS also prints
;;;; "event P<n> <id> fires <takeovers> steps <steps under the layer> ticks <match ticks>" (§8.19 round 5, step 6).
;;;; A Q selector (:FQ, strategy.lisp) is kept like a composite (its "switch" line's h_i = the judgements arm i won); STRAT_FQLOG logs its
;;;; judgements for training (below); STRAT_FQLEARN runs the online fuzzy Q learner against a player proxy (below).
;;;; STRAT_LAYER=<character>[,<character>] (or "t"): those CPUs under the strategy layer (*STRAT-LAYER*, DUEL_AI_STRATEGY §5, §8.4); its
;;;; RESULTS line "duel stratlayer ..." gives the cost and the picks. STRAT_SET=*knob*=value[,...]: set strategy-layer knobs (numbers) first.
;;;; A STRAT_P<n> / STRAT_<CHARACTER> value may also be `none` (that CPU plays with no strategy at all: BRAIN-STRAT NIL, so neither the
;;;; lookup's nor a file's; the shipped CPU with its style CPU, frozen against later lookup entries) or a comma list of files / none, a POOL:
;;;; the match with seed s plays member (s mod n) (DUEL_AI_STRATEGY §8.15: frozen opponents and the proxy pools). *CAI-STYLES* is restored at
;;;; every match's start before the strategies apply, so one match's plain strategy never strips another match's style CPU.
;;;; Usage: ecl-host --norc --load tools/simgate/strat-run.lisp -- <duel.fas> <cmd>...   e.g. 2102 81022 30000 31120 2132
(load "/media/8tsp/projects/ai-cl-game-next/.claude/worktrees/agent-a3e87ca10ffed49c4/tools/simgate/prelude.lisp" :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)

(defun sr-read (path) (and path (plusp (length path)) (with-open-file (in path) (let ((*read-eval* nil)) (read in)))))
(defvar *sr-files* (make-hash-table :test 'equal))
(defun sr-strat (env)
  "ENV's strategy for this match: NIL (unset), :NONE, or a plist; a comma list is a pool, member (match seed mod n)."
  (let ((p (ext:getenv env)))
    (when (and p (plusp (length p)))
      (let* ((parts (loop for start = 0 then (1+ q) for q = (position #\, p :start start) collect (subseq p start q) while q))
             (x (nth (mod *match-seed* (length parts)) parts)))
        (if (string= x "none") :none (or (gethash x *sr-files*) (setf (gethash x *sr-files*) (sr-read x))))))))
(defvar *sr-styles0* (copy-tree *cai-styles*) "The style CPUs as loaded: restored at every match's start (a plain strategy REMFs its character's).")
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
(defvar *sr-evout* (list nil nil) "Per side, the steps each table arm held outside the event layer this match (a vector, made at the first).")
(defun sr-sw-flush ()
  (loop for side from 0 for r in *sr-sw*
        when r do (format t "switch P~d ~a judged ~d held~{ ~d~}~%" (1+ side) (first r) (second r) (third r))
        when (and r (fourth r)) do (format t "event P~d ~a fires ~d steps ~d ticks ~d out~{ ~d~}~%" (1+ side) (first r) (first (fourth r))
                                           (second (fourth r)) (third (fourth r)) (coerce (nth side *sr-evout*) 'list)))
  (setf *sr-sw* (list nil nil) *sr-evout* (list nil nil)))   ; (the event layer, §8.19 round 5 step 6: takeovers, steps under it, match
                                                            ;  ticks, and the steps each arm of the table held outside the layer)
(defun sr-sw-note ()
  (do-sides (e)
    (let ((b (brain e)))
      (when (and b (brain-strat b) (or (getf (brain-strat b) :switch) (getf (brain-strat b) :fq)))
        (setf (nth (fighter-side (fighter e)) *sr-sw*)
              (list (getf (brain-strat b) :id) (brain-sw-n b)
                    (loop for i below (length (or (getf (brain-strat b) :switch) (getf (getf (brain-strat b) :fq) :arms)))
                          collect (if (brain-sw-won b) (svref (brain-sw-won b) i) 0))
                    (and (getf (getf (brain-strat b) :fq) :event-arms) (list (brain-ev-n b) (brain-ev-steps b) *match-tick*))))
        (let ((arms (getf (getf (brain-strat b) :fq) :arms)) (side (fighter-side (fighter e))))
          (when (and (getf (getf (brain-strat b) :fq) :event-arms) (not (brain-ev-on b)))
            (let ((v (or (nth side *sr-evout*) (setf (nth side *sr-evout*) (make-array (length arms) :initial-element 0))))
                  (i (position (brain-sw-sub b) arms)))
              (when i (incf (aref v i))))))))))
;;; STRAT_FQLOG="<salt> <eps> [<seat 1|2>]": the Q selector's training log (with a seat, only that seat's CPU logs and explores; any other
;;; Q selector, e.g. a frozen opponent, judges as usual) (DUEL_AI_STRATEGY §8.12, docs/research/strategy-drsi/fq/). On each judgement of a
;;; :FQ strategy outside rollouts, with chance EPS the other arm (two arms) instead of the table's: drawn from a hash of (match seed, tick,
;;; side, salt), never SIM-RND01. One line a judgement: "fq <seed> <tick> P<n> lead L ored R ost S mr M or O dj D awk A prev P greedy G arm K
;;; h H oh OH" (H = mc-full-health, mine and his); "fqend <seed> P<n> h H oh OH" when the match ends (the last step's values).
;;; STRAT_FQLOG="<salt> <eps> <seat> <rmin> <rmax>" (§8.19, any number of arms): exploration in runs: a judgement outside a run starts one with
;;; chance EPS, an arm drawn uniformly from the others, held for RMIN..RMAX judgements (the hash again), then the table's. A table with :XFEATS
;;; also logs its extra cues and the normalised firing vector: "... oh OH dm D form F oawk A gauge G wall W fire i:x,i:x,..." (nonzero only).
(defvar *sr-fq* (let ((l (ext:getenv "STRAT_FQLOG"))) (and l (plusp (length l)) (with-input-from-string (in l) (list (read in) (read in) (read in nil nil) (read in nil nil) (read in nil nil))))))
(defvar *sr-fq-run* (list nil nil) "Per side, an exploring run: (seed arm judgements-left), or NIL.")
(defun sr-fq-seat-p (side) "SIDE (0 / 1) logs: no seat given, or it is the given one." (or (null (third *sr-fq*)) (= (third *sr-fq*) (1+ side))))
(defun sr-fq-u (seed tick side salt)
  "A uniform 0-1 number from (SEED TICK SIDE SALT) alone: a Park-Miller generator stirred a few times."
  (let ((x (1+ (mod (+ (* seed 1000003) (* tick 7919) (* side 104729) (* salt 15485863)) 2147483646))))
    (dotimes (i 4) (setf x (mod (* x 48271) 2147483647)))
    (/ x 2147483647d0)))
(defvar *sr-fq-last* (list nil nil) "Per side, the last step's (seed h oh) of a logging CPU.")
(defun sr-fq-judge (e b sw sub i feats)
  (declare (ignore b))
  (if (not (sr-fq-seat-p (fighter-side (fighter e)))) (values sub i)
  (let* ((f (fighter e)) (side (fighter-side f)) (fq (getf sw :fq)) (arms (getf fq :arms)) (n (length arms)) (rmax (fifth *sr-fq*))
         (u (sr-fq-u *match-seed* *match-tick* side (first *sr-fq*)))
         (k (cond ((not rmax) (if (and arms (= 2 n) (< u (second *sr-fq*))) (- 1 i) i))
                  (t (let ((run (nth side *sr-fq-run*)))
                       (when (and run (/= (first run) *match-seed*)) (setf run nil))
                       (when (and (null run) (> n 1) (< u (second *sr-fq*)))   ; (a new run: another arm and a length from U / EPS, uniform
                         (let* ((v (* (/ u (second *sr-fq*)) (1- n))) (a (floor v)) (w (- v a)))   ;  in 0-1: a second hash of the same
                           (setf run (list *match-seed* (mod (+ i 1 a) n)                           ;  inputs is a linear map of U, so it
                                           (+ (fourth *sr-fq*) (floor (* w (1+ (- rmax (fourth *sr-fq*))))))))))   ;  would sit in a narrow band)
                       (if (and run (plusp (third run)))
                           (progn (decf (third run)) (setf (nth side *sr-fq-run*) (and (plusp (third run)) run)) (second run))
                           (progn (setf (nth side *sr-fq-run*) nil) i)))))))
    (format t "fq ~d ~d P~d lead ~d ored ~d ost ~d mr ~,3f or ~,3f dj ~,2f awk ~d prev ~d greedy ~d arm ~d h ~,3f oh ~,3f"
            *match-seed* *match-tick* (1+ side) (getf feats :lead) (getf feats :ored) (getf feats :ost) (getf feats :mr) (getf feats :or)
            (getf feats :dj) (getf feats :awk) (getf feats :prev) i k (mc-full-health e) (mc-full-health (fighter-opp f)))
    (when (getf fq :xfeats)
      (format t " dm ~,3f form ~d oawk ~d gauge ~,3f wall ~,2f fire~:{ ~d:~,4f~}" (getf feats :dm) (getf feats :form) (getf feats :oawk)
              (getf feats :gauge) (getf feats :wall)
              (loop for x across (strat-fq-fire fq feats) for j from 0 when (plusp x) collect (list j x))))
    (terpri)
    (if (= k i) (values sub i) (values (nth k arms) k)))))
(defun sr-fq-note ()
  (do-sides (e)
    (let ((b (brain e)))
      (when (and b (brain-strat b) (getf (brain-strat b) :fq) (sr-fq-seat-p (fighter-side (fighter e))))
        (setf (nth (fighter-side (fighter e)) *sr-fq-last*) (list *match-seed* (mc-full-health e) (mc-full-health (fighter-opp (fighter e)))))))))
(defun sr-fq-flush ()
  (loop for side from 0 for r in *sr-fq-last*
        when r do (format t "fqend ~d P~d h ~,3f oh ~,3f~%" (first r) (1+ side) (second r) (third r)))
  (setf *sr-fq-last* (list nil nil)))
(when *sr-fq* (setf *strat-judge-hook* #'sr-fq-judge))
;;; STRAT_FQLEARN="<in> <out>" (DUEL_AI_STRATEGY §8.14): every Q-selector CPU learns online as against a human (*FQ-LEARN-FORCE*), its table
;;; carried from match to match; IN (or "-": none) is a table written by an earlier run, OUT gets the table at the end: the strategy plist plus
;;; :matches, keyed by its :apply (me vs). A player proxy is the other seat's CPU (STRAT_<CHARACTER>); don't give the learner's seat a STRAT_.
;;; STRAT_FQLEARN="<in> <out> <seat 1|2>" (§8.15, any pairing): only that seat learns. Its Q selector comes from its STRAT_P<seat> (the offline
;;; table: the clamp's base; it must carry :apply (me vs)) and is attached here (FQ-ATTACH!: it plays IN's copy when IN is that pairing's);
;;; every other brain's record is dropped, so a frozen opponent that is a Q selector never learns; OUT gets the learner's table only.
(defvar *sr-fql* (let ((l (ext:getenv "STRAT_FQLEARN"))) (and l (plusp (length l)) l)))
(defvar *sr-fql-seat* nil "STRAT_FQLEARN's learner side (0 / 1), or NIL: every Q selector (the IK proof's form).")
(defvar *sr-fql-key* nil "The learner's (me . vs) roster indices once attached (with *SR-FQL-SEAT*).")
(when *sr-fql*
  (let* ((l *sr-fql*) (sp (position #\Space l)) (in (subseq l 0 sp)) (sp2 (position #\Space l :start (1+ sp)))
         (out (subseq l (1+ sp) sp2)))
    (when sp2 (setf *sr-fql-seat* (1- (parse-integer l :start (1+ sp2)))))
    (setf *sr-fql* out *fq-learn-force* t)
    (unless (string= in "-")
      (let* ((st (sr-read in)) (ap (getf st :apply)))
        (push (cons (cons (position (first ap) *roster*) (position (second ap) *roster*)) (cons st (getf st :matches 0))) *fq-tables*)))))
(defun sr-fql-dump ()
  (when *sr-fql*
    (with-open-file (o *sr-fql* :direction :output :if-exists :supersede)
      (dolist (en (if *sr-fql-seat* (remove *sr-fql-key* *fq-tables* :key #'car :test-not #'equal) *fq-tables*))   ; (one form a table; the evaluator reads the first)
        (let ((st (cadr en)) (*print-pretty* nil) (*read-default-float-format* 'single-float))
          (format o "~s~%" (list* :matches (cddr en) (loop for (k v) on st by #'cddr unless (eq k :matches) append (list k v)))))))))
;;; STRAT_HRANGE=1 (DUEL_AI_STRATEGY §8.16): per match and side, Hisagi's steps in the Bankai's ranged mode, their summed distance, those
;;; inside 3 m, his NS1a WA started beyond 3.2 m (it reaches 3.0: a whiff), and HISAGI-RANGE-STYLE's counters (cpu-hisagi-range.lisp
;;; *HR-COUNTS*): "hrange <seed> P<n> steps N dsum D close C wafar W cnt c0..c7"; then "dswitch <seed> P<n> S R B": the CPU's DRIVE switches
;;; in the Shikai, the ranged mode and the bind mode (core-ai.lisp *CAI-SWITCH-COUNTS*, §8.19).
(defvar *sr-hr* (plusp (length (or (ext:getenv "STRAT_HRANGE") ""))))
(defvar *sr-hr-acc* (make-array 8 :initial-element 0))   ; per side: steps, dsum (x1000), close, WA started beyond 3.2 m
(defvar *sr-hr-seed* nil)
(defun sr-hr-flush ()
  (when *sr-hr-seed*
    (dotimes (side 2)
      (format t "hrange ~d P~d steps ~d dsum ~,1f close ~d wafar ~d cnt~{ ~d~}~%" *sr-hr-seed* (1+ side) (aref *sr-hr-acc* (* 3 side))
              (/ (aref *sr-hr-acc* (+ 1 (* 3 side))) 1000.0) (aref *sr-hr-acc* (+ 2 (* 3 side))) (aref *sr-hr-acc* (+ 6 side))
              (loop for i below 8 collect (aref *hr-counts* (+ i (* 8 side)))))
      (format t "dswitch ~d P~d~{ ~d~}~%" *sr-hr-seed* (1+ side) (loop for i below 3 collect (aref *cai-switch-counts* (+ i (* 3 side)))))))   ; (§8.19: the CPU's DRIVE switches by form)
  (fill *sr-hr-acc* 0) (fill *hr-counts* 0) (fill *cai-switch-counts* 0) (setf *sr-hr-seed* nil))
(defun sr-hr-step ()
  (setf *sr-hr-seed* *match-seed*)
  (do-sides (e)
    (let ((f (fighter e)))
      (when (eq (fighter-form f) :bankai)
        (let ((side (fighter-side f)) (d (fighter-dist f)))
          (incf (aref *sr-hr-acc* (* 3 side))) (incf (aref *sr-hr-acc* (+ 1 (* 3 side))) (round (* 1000 d)))
          (when (< d 3.0) (incf (aref *sr-hr-acc* (+ 2 (* 3 side)))))
          (when (and (eq (fighter-state f) :move) (= (fighter-sf f) 1) (fighter-move f) (eq (mv-name (fighter-move f)) :hs-r-n1a) (> d 3.2))
            (incf (aref *sr-hr-acc* (+ 6 side)))))))))
(defun sr-hook ()
  (when (and *sr-win* (battle-p) (plusp *match-tick*) (zerop (mod *match-tick* 90))) (sr-win-lines))
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (when *sr-hr* (sr-hr-flush))
    (sr-sw-flush)
    (sr-fq-flush)
    (setf *cai-styles* (copy-tree *sr-styles0*))
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch)))))
        (when (and b st)
          (setf (brain-strat b) (if (eq st :none) nil st))
          (unless (or (eq st :none) (getf st :switch) (getf st :fq)) (remf *cai-styles* ch))
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (if (eq st :none) "none" (getf st :id))))
        (when (and b *sr-fql-seat*)                                ; (one designated learner, above)
          (setf (brain-fql b) nil)
          (when (and (= (fighter-side f) *sr-fql-seat*) (brain-strat b) (getf (brain-strat b) :fq))
            (fq-attach! e)
            (setf *sr-fql-key* (cons (position ch *roster*) (position (fighter-character (fighter (fighter-opp f))) *roster*))))))))
  (when (battle-p) (sr-sw-note) (when *sr-fq* (sr-fq-note)) (when (and *sr-hr* (eq *flow* :battle)) (sr-hr-step))))   ; (after a new match's flush: else its first step's counts replace the last match's)

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
(cl-user::sg-init)
(setf *step-hook* #'sr-hook)
(cl-user::sg-queue)
(engine::%frame) (setf *combat-log* t)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(sr-sw-flush)
(sr-fq-flush)
(when *sr-hr* (sr-hr-flush))
(sr-fql-dump)
(finish-output)
(ext:quit 0)
