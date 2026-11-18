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
;;;; STRAT_LAYER=<character>[,<character>] (or "t", or a seat "P1" / "P2"): those CPUs under the strategy layer (*STRAT-LAYER*, DUEL_AI_STRATEGY §5, §8.4); its
;;;; RESULTS line "duel stratlayer ..." gives the cost and the picks. STRAT_SET=*knob*=value[,...]: set strategy-layer knobs (numbers) first.
;;;; A STRAT_P<n> / STRAT_<CHARACTER> value may also be `none` (that CPU plays with no strategy at all: BRAIN-STRAT NIL, so neither the
;;;; lookup's nor a file's; the shipped CPU with its style CPU, frozen against later lookup entries) or a comma list of files / none, a POOL:
;;;; the match with seed s plays member (s mod n) (DUEL_AI_STRATEGY §8.15: frozen opponents and the proxy pools). *CAI-STYLES* is restored at
;;;; every match's start before the strategies apply, so one match's plain strategy never strips another match's style CPU.
;;;; STRAT_DIF_P1 / STRAT_DIF_P2=easy|normal|hard: that seat's CPU difficulty (its perception delay, its lookup strategy) over the gate's
;;;; 81020+i, set at the match's first battle step before the strategies above (DUEL_AI_STRATEGY §11.17: EASY / NORMAL / HARD against HARD).
;;;; STRAT_DIF_P<n>=masher: that seat plays the seeded button-masher instead (duel/lisp/masher.lisp, PLAN4 §5; as debug 81030+s).
;;;; Usage: ecl-host --norc --load tools/simgate/strat-run.lisp -- <duel.fas> <cmd>...   e.g. 2102 81022 30000 31120 2132
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)

(defun sr-read (path) (and path (plusp (length path)) (cl-user::sg-read-strat path)))   ; (prelude: a :WITH table expanded, PLAN4 §3)
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
;;; STRAT_CLOG=1: the combat log (CLOG lines "[tick] ...") on in every match (the gate turns it off at START-MATCH); read only, the play is unchanged
;;; (docs/research/strategy-drsi/dmgsrc/: where the damage comes from).
(defvar *sr-clog* (plusp (length (or (ext:getenv "STRAT_CLOG") ""))))
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
;;; STRAT_FQBASE=<file> (docs/research/strategy-drsi/fq/online2.md): every Q-selector judgement outside rollouts is also judged by FILE's table
;;; (a strategy file, read as STRAT_P<n>) on the same cues, :PREV included; per match and side "fqbase <seed> P<n> judged J differ D", D = the
;;; judgements where FILE's arm index differs. It only reads (the played arm is unchanged); not with STRAT_FQLOG (one judge hook).
(defvar *sr-fqb* (let ((p (ext:getenv "STRAT_FQBASE"))) (and p (plusp (length p)) (sr-read p))) "STRAT_FQBASE's table (only a table of its :APPLY is judged).")
(defvar *sr-fqb-n* (list nil nil) "Per side: (seed judged differ) of this match, or NIL.")
(defun sr-fqb-flush ()
  (loop for side from 0 for r in *sr-fqb-n* when r do (format t "fqbase ~d P~d judged ~d differ ~d~%" (first r) (1+ side) (second r) (third r)))
  (setf *sr-fqb-n* (list nil nil)))
(defun sr-fqb-judge (e b sw sub i feats)
  (declare (ignore b))
  (when (equal (getf sw :apply) (getf *sr-fqb* :apply))
    (let* ((side (fighter-side (fighter e))) (r (or (nth side *sr-fqb-n*) (setf (nth side *sr-fqb-n*) (list *match-seed* 0 0)))))
      (incf (second r))
      (unless (= i (strat-fq-pick (getf *sr-fqb* :fq) feats)) (incf (third r)))))
  (values sub i))
(when (and *sr-fqb* (not *sr-fq*)) (setf *strat-judge-hook* #'sr-fqb-judge))
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
;;; ... and "hdesc <seed> P<n> steps N dsum D close C" (PLAN4 §3's arm descriptors, B3): every battle step of the match, whatever the form.
(defvar *sr-hd-acc* (make-array 6 :initial-element 0))   ; per side: steps, dsum (x1000), steps inside 3 m
(defun sr-hr-flush ()
  (when *sr-hr-seed*
    (dotimes (side 2)
      (format t "hdesc ~d P~d steps ~d dsum ~,1f close ~d~%" *sr-hr-seed* (1+ side) (aref *sr-hd-acc* (* 3 side))
              (/ (aref *sr-hd-acc* (+ 1 (* 3 side))) 1000.0) (aref *sr-hd-acc* (+ 2 (* 3 side)))))
    (fill *sr-hd-acc* 0)
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
      (let ((side (fighter-side f)) (d (fighter-dist f)))
        (incf (aref *sr-hd-acc* (* 3 side))) (incf (aref *sr-hd-acc* (+ 1 (* 3 side))) (round (* 1000 d)))
        (when (< d 3.0) (incf (aref *sr-hd-acc* (+ 2 (* 3 side))))))
      (when (eq (fighter-form f) :bankai)
        (let ((side (fighter-side f)) (d (fighter-dist f)))
          (incf (aref *sr-hr-acc* (* 3 side))) (incf (aref *sr-hr-acc* (+ 1 (* 3 side))) (round (* 1000 d)))
          (when (< d 3.0) (incf (aref *sr-hr-acc* (+ 2 (* 3 side)))))
          (when (and (eq (fighter-state f) :move) (= (fighter-sf f) 1) (fighter-move f) (eq (mv-name (fighter-move f)) :hs-r-n1a) (> d 3.2))
            (incf (aref *sr-hr-acc* (+ 6 side)))))))))
;;; STRAT_DESC=1 (PLAN4 §3, the one-job proof, sp/arms4/proof.py): STRAT_HRANGE's counters generalised to every side and form, read from the
;;; state only. Per match and side, one line "desc <seed> P<n> steps N dsum D close C far F sp S burst B kikon K kd W wake P evade E acts A
;;; awk K clash X ptr p1 p2 p3 form <form>:<steps> ...": battle steps, their summed distance (m), those inside 3 m / beyond 6 m, SP moves
;;; started (kind :sp), Bursts, my Kikons (his FIGHTER-KIKON-LOCK set anew: the hold's strike landed), his knockdowns ended (out of :down / :wakeup) and my action starts (a move, Step or Hoho)
;;; in his first 20 steps after each, my Steps + Hohos, all my action starts, steps awakened, clashes (FIGHTER-CLASH-T stamped anew), steps at
;;; SP pointer 1 / 2 / 3 (4 reads 3), my move starts while he is :idle / :run (nstart: an attack into his neutral, not an answer to his move;
;;; Ichigo's code cell, PLAN4 B3), SP moves started while awakened (asp) and the summed distance of the awakened steps (adsum, m), steps per form. Reads only: 25 seeds with and without it gave
;;; identical gate rows and hash lines.
(defvar *sr-desc* (plusp (length (or (ext:getenv "STRAT_DESC") ""))))
;;; ---- begin: Ichigo's kit-strategy counters (PLAN4 checkpoint 2a, sp/arms5/ichigo.md), also under STRAT_DESC; read only.
;;; Per match and side, one line "idesc <seed> P<n> xn N xpost P xsa S asn A as1 A1 pun U nsk K nsk3 K3 b34 B": the cancels (a fresh
;;; FIGHTER-XCH tick), her first action start after each while the exchange is open (a move, Step or Hoho) and those that are the SA; her AS
;;; routes started (a first segment, KIT-CORE's :as) and those that are AS1; her move starts out of her neutral (:idle / :run the step
;;; before) while his move is past its active frames (his recovery: S4 punish); her NS routes started while awakened (KIT-CORE's :ns) and those that are NS3 (S5); steps at 3.4-6.0 m (T3).
(defparameter +sr-idesc-keys+ '(xn xpost xsa asn as1 pun nsk nsk3 b34))
(defvar *sr-idesc-acc* (list nil nil) "Per side: the counts vector, or NIL before the match's first battle step.")
(defvar *sr-idesc-edge* (list nil nil) "Per side: (last-xch pending last-state last-move).")
(defun sr-idesc-flush (seed)
  (loop for side from 0 for v in *sr-idesc-acc* when v
        do (format t "idesc ~d P~d~{ ~(~a~) ~d~}~%" seed (1+ side) (loop for k in +sr-idesc-keys+ for i from 0 append (list k (aref v i)))))
  (setf *sr-idesc-acc* (list nil nil) *sr-idesc-edge* (list nil nil)))
(defun sr-idesc-step ()
  (do-sides (e)
    (let* ((f (fighter e)) (side (fighter-side f)) (fo (fighter (fighter-opp f))) (kit (fighter-kit f))
           (v (or (nth side *sr-idesc-acc*) (setf (nth side *sr-idesc-acc*) (make-array 9 :initial-element 0))))
           (ed (or (nth side *sr-idesc-edge*) (list (fighter-xch f) nil nil nil)))
           (st (fighter-state f)) (mv (fighter-move f)) (d (fighter-dist f)) (x (fighter-xch f)) (pend (second ed))
           (mstart (and (eq st :move) mv (or (not (eq (third ed) :move)) (not (eq mv (fourth ed))))))
           (start (or mstart (and (member st '(:step :hoho)) (not (eq st (third ed)))))))
      (flet ((inc (i) (incf (aref v i))))
        (cond ((< x 0) (setf pend nil))
              ((/= x (first ed)) (inc 0) (setf pend t)))
        (when (and pend start)
          (inc 1) (when (and mstart (eq (fighter-cls f) :sa)) (inc 2)) (setf pend nil))
        (when mstart
          (let ((a (position (mv-name mv) (getf (kit-core kit) :as))) (n (position (mv-name mv) (getf (kit-core kit) :ns)))
                (mo (fighter-move fo)))
            (when a (inc 3) (when (= a 0) (inc 4)))
            (when (and (member (third ed) '(:idle :run)) (eq (fighter-state fo) :move) mo (eq (fighter-phase fo) :main)
                       (>= (fighter-sf fo) (+ (mv-s mo) (mv-a mo))))
              (inc 5))
            (when (and n (gauges-awakened (gauges e))) (inc 6) (when (= n 2) (inc 7)))))
        (when (<= 3.4 d 6.0) (inc 8)))
      (setf (nth side *sr-idesc-edge*) (list x pend st mv)))))
;;; ---- end: Ichigo's kit-strategy counters
(defvar *sr-desc-acc* (list nil nil) "Per side: (counts-vector form-alist), or NIL before the match's first battle step.")
(defvar *sr-desc-edge* (list nil nil) "Per side: (last-state last-move last-burst last-clash-t his-last-state wake-left his-last-kikon-lock).")
(defvar *sr-desc-seed* nil)
(defparameter +sr-desc-keys+ '(steps dsum close far sp burst kikon kd wake evade acts awk clash p1 p2 p3 nstart asp adsum))
(defvar *sr-desc-extra* nil
  "Functions (side) -> a flat list (key count ...) appended to that side's desc line before \"form\" (a batch's own counters, in its own
block below; proof.py's desc_vec reads any key) and resetting their own state: one per block, in load order.")
(defun sr-desc-flush ()
  (when *sr-desc-seed* (sr-idesc-flush *sr-desc-seed*))   ; (Ichigo's kit-strategy counters, the block above)
  (when *sr-desc-seed*
    (loop for side from 0 for a in *sr-desc-acc* when a
          do (format t "desc ~d P~d~{ ~(~a~) ~d~} form~:{ ~(~a~):~d~}~%" *sr-desc-seed* (1+ side)
                     (append (loop for k in +sr-desc-keys+ for i from 0 append (list k (aref (first a) i)))
                             (loop for fn in *sr-desc-extra* append (funcall fn side)))
                     (mapcar (lambda (c) (list (car c) (cdr c))) (reverse (second a))))))
  (setf *sr-desc-acc* (list nil nil) *sr-desc-edge* (list nil nil) *sr-desc-seed* nil))
(defvar *sr-desc-steps* nil "Functions run at the end of each SR-DESC-STEP (a batch's own counters, in its own block below).")
(defun sr-desc-step ()
  (sr-idesc-step)                                          ; (Ichigo's kit-strategy counters, the block above)
  (setf *sr-desc-seed* *match-seed*)
  (do-sides (e)
    (let* ((f (fighter e)) (side (fighter-side f)) (o (fighter-opp f)) (fo (fighter o))
           (a (or (nth side *sr-desc-acc*) (setf (nth side *sr-desc-acc*) (list (make-array 19 :initial-element 0) nil))))
           (v (first a)) (ed (or (nth side *sr-desc-edge*) (list nil nil nil (fighter-clash-t f) nil 0 0)))
           (st (fighter-state f)) (mv (fighter-move f)) (d (fighter-dist f)) (ost (fighter-state fo))
           (start (or (and (eq st :move) mv (or (not (eq (first ed) :move)) (not (eq mv (second ed)))))
                      (and (member st '(:step :hoho)) (not (eq st (first ed)))))))
      (flet ((inc (i) (incf (aref v i))))
        (inc 0) (incf (aref v 1) (round (* 1000 d))) (when (< d 3.0) (inc 2)) (when (> d 6.0) (inc 3))
        (when (and start (eq st :move) (eq (mv-kind mv) :sp)) (inc 4))
        (when (and (gauges-burst (gauges e)) (not (third ed))) (inc 5))
        (when (and (plusp (fighter-kikon-lock fo)) (zerop (seventh ed))) (inc 6))
        (when (and (member (fifth ed) '(:down :wakeup)) (not (member ost '(:air :down :wakeup)))) (inc 7) (setf (sixth ed) 20))
        (when (plusp (sixth ed)) (when start (inc 8)) (decf (sixth ed)))
        (when (and start (member st '(:step :hoho))) (inc 9))
        (when start (inc 10))
        (when (gauges-awakened (gauges e)) (inc 11) (incf (aref v 18) (round (* 1000 d))))
        (when (and (plusp (fighter-clash-t f)) (/= (fighter-clash-t f) (fourth ed))) (inc 12))
        (inc (+ 13 (1- (min 3 (max 1 (fighter-ptr f))))))
        (when (and start (eq st :move) (member ost '(:idle :run))) (inc 16))
        (when (and start (eq st :move) (eq (mv-kind mv) :sp) (gauges-awakened (gauges e))) (inc 17))
        (let ((c (assoc (fighter-form f) (second a)))) (if c (incf (cdr c)) (push (cons (fighter-form f) 1) (second a)))))
      (setf (nth side *sr-desc-edge*) (list st mv (gauges-burst (gauges e)) (fighter-clash-t f) ost (sixth ed) (fighter-kikon-lock fo)))))
  (dolist (fn *sr-desc-steps*) (funcall fn)))

;;; ---- STRAT_DESC, Hisagi's PLAN4 arms (arms5/hisagi.md; cpu-hisagi-own.lisp), read-only. Per side, appended to the desc line:
;;; bdsum the Shikai steps' summed distance (m); nagi / nagiin NAGI (:hs-n1a) starts, those inside 3.0 m; xc / xj / xja the cancels he took
;;; part in (XCH-SIDE :J or :NS), those as the J side, those J-side ones followed by an AS start within 60 steps (a J cancelled in its
;;; startup opens its AS window only after it: 45 steps in the dev logs); taba / tabat TABA
;;; (:hs-r-n2a) starts, those at 4.0-4.9 m; rbeh / rbehb steps behind in Reishi by >= 300, those in the bind (:bankai-bind); beven BIND
;;; EVEN (his HSS-EVEN-A stamped anew while bound); bina bind entries while ahead in Reishi; jlunge his J1 starts during Kenpachi's Shikai
;;; lunge's (:ke-s-n1a) startup at 2.5-5.7 m; nsin his route-opening NS starts in his own Shikai inside 5.7 m while Kenpachi is in his
;;; Shikai (:nozarashi);
;;; osk steps of that; klunge the lunges started; gch / gans Ichigo's Getsuga charges (NS2a starts), those answered (his NAGI landed, he
;;; Hohoed, or the charge took part in a cancel, before it ended); rush / rushn Ichigo's NS3a rush starts, those during whose startup he
;;; started NAGI. HSS read with HSS (never HS: that attaches one).
(defparameter +sr-hx-keys+ '(bdsum nagi nagiin xc xj xja taba tabat rbeh rbehb beven bina jlunge nsin osk klunge gch gans rush rushn))
(defvar *sr-hx* (list nil nil) "Per side: (counts edge), edge = a plist of the last step's reads.")
(defvar *sr-hx-seed* nil)
(defun sr-hx-step ()
  (unless (eql *sr-hx-seed* *match-seed*) (setf *sr-hx* (list nil nil) *sr-hx-seed* *match-seed*))
  (do-sides (e)
    (let* ((f (fighter e)) (side (fighter-side f)) (o (fighter-opp f)) (fo (fighter o)) (kit (fighter-kit f))
           (a (or (nth side *sr-hx*) (setf (nth side *sr-hx*) (list (make-array (length +sr-hx-keys+) :initial-element 0) (list :xch (fighter-xch f))))))
           (v (first a)) (ed (second a)) (st (fighter-state f)) (mv (fighter-move f)) (d (fighter-dist f))
           (ost (fighter-state fo)) (omv (fighter-move fo)) (name (and (eq st :move) mv (mv-name mv))) (oname (and (eq ost :move) omv (mv-name omv)))
           (start (and name (or (not (eq (getf ed :st) :move)) (not (eq mv (getf ed :mv))))))
           (ostart (and oname (or (not (eq (getf ed :ost) :move)) (not (eq omv (getf ed :omv))))))
           (r (gauges-reishi (gauges e))) (or* (gauges-reishi (gauges o))) (hs (hss e)))
      (flet ((inc (k) (incf (aref v (position k +sr-hx-keys+)))))
        (when (eq (fighter-form f) :base) (incf (aref v 0) (round (* 1000 d))))
        (when (and start (eq name :hs-n1a)) (inc 'nagi) (when (< d 3.0) (inc 'nagiin))
          (when (and (eq oname :ic-n3a) (< (fighter-sf fo) (mv-s omv)) (not (getf ed :rushn))) (inc 'rushn) (setf (getf ed :rushn) t)))
        ;; the cancels: classified on the step his exchange is stamped anew (or the next two, until his move shows its side)
        (let ((x (fighter-xch f)))
          (when (and (>= x 0) (/= x (getf ed :xch -1))) (setf (getf ed :xch) x (getf ed :xpend) 3))
          (when (plusp (getf ed :xpend 0))
            (let ((sd (and (eq st :move) (xch-side (fighter-cls f) (fighter-contact f) x (fighter-cls-t f)))))
              (if sd
                  (progn (inc 'xc) (setf (getf ed :xpend) 0) (when (eq sd :j) (inc 'xj) (setf (getf ed :xwatch) 61)))
                  (decf (getf ed :xpend))))))
        (when (plusp (getf ed :xwatch 0))
          (if (and start (eq (kit-class kit mv) :as)) (progn (inc 'xja) (setf (getf ed :xwatch) 0)) (decf (getf ed :xwatch))))
        (when (and start (eq name :hs-r-n2a)) (inc 'taba) (when (<= 4.0 d 4.9) (inc 'tabat)))
        (when (>= (- or* r) 300) (inc 'rbeh) (when (eq (fighter-form f) :bankai-bind) (inc 'rbehb)))
        (when hs
          (when (and (hss-bound hs) (/= (hss-even-a hs) (getf ed :even (hss-even-a hs)))) (inc 'beven))
          (setf (getf ed :even) (hss-even-a hs)))
        (when (and (eq (fighter-form f) :bankai-bind) (not (eq (getf ed :form) :bankai-bind)) (> r or*)) (inc 'bina))
        (when (and start (member name '(:hs-j1 :hs-j1-1h)) (eq oname :ke-s-n1a) (< (fighter-sf fo) (mv-s omv)) (<= 2.5 d 5.7)) (inc 'jlunge))
        (when (eq (fighter-form fo) :nozarashi)
          (inc 'osk)
          (when (and start (< d 5.7) (eq (fighter-form f) :base) (member name (getf (kit-core kit) :ns))) (inc 'nsin)))
        (when (and ostart (eq oname :ke-s-n1a)) (inc 'klunge))
        ;; Ichigo's Getsuga charge: open from his NS2a's start until his move leaves the charge / wave segments
        (when (getf ed :gch)
          (when (or (eq st :hoho) (and (eq name :hs-n1a) (eq (fighter-contact f) :hit)) (>= (fighter-xch fo) (getf ed :gch)))
            (setf (getf ed :gans) t))
          (unless (member oname '(:ic-n2a :ic-n2b :ic-n2c :ic-k-n2a :ic-k-n2b :ic-k-n2c))
            (when (getf ed :gans) (inc 'gans))
            (setf (getf ed :gch) nil (getf ed :gans) nil)))
        (when (and ostart (member oname '(:ic-n2a :ic-k-n2a))) (inc 'gch) (setf (getf ed :gch) *match-tick* (getf ed :gans) nil))
        (when (and ostart (eq oname :ic-n3a)) (inc 'rush) (setf (getf ed :rushn) nil)))
      (setf (getf ed :st) st (getf ed :mv) mv (getf ed :ost) ost (getf ed :omv) omv (getf ed :form) (fighter-form f))
      (setf (second a) ed))))
(push #'sr-hx-step *sr-desc-steps*)
(push (lambda (side)
        (let ((a (nth side *sr-hx*)))
          (loop for k in +sr-hx-keys+ for i from 0 append (list k (if a (aref (first a) i) 0)))))
      *sr-desc-extra*)
;;; ---- (end of Hisagi's PLAN4 block)
;;; ---------------------------------------------------------------- PLAN4 P5, Kenpachi's descriptors (sp/arms5/kenpachi.md), under STRAT_DESC
;;; One more line per match and side, "kdesc <seed> P<n> pfar N kikonk K wavet W", read from the state only:
;;;   pfar    my J / NS (class :na / :ns) started beyond 2.4 m (Ichigo's and Hisagi's J1 far edge, centre to centre) whose contact turned
;;;           :hit while his Reishi fell that step (a cancel also writes :hit but deals nothing): the out-range poke's hits, once a move;
;;;   kikonk  his Konpaku lost on a step after one with his FIGHTER-KIKON-LOCK set (my Kikon's follow-up was coming): Konpaku my Kikons took
;;;           (a Soul Break outside a Kikon's lock is not counted);
;;;   wavet   steps on which one of his :wave hazards connected (its hits-left fell, or it was spent the step it appeared) and my Reishi
;;;           fell: his Getsuga hits on me (a J's cancel of the wave deals nothing).
(defvar *sr-kd-acc* (list nil nil) "Per side: #(pfar kikonk wavet), or NIL before the match's first battle step.")
(defvar *sr-kd-edge* (list nil nil) "Per side: (pending-far-move my-move his-konpaku his-kikon-lock my-reishi his-reishi) at the last step.")
(defvar *sr-kd-waves* nil "Every :wave hazard at the last step: (handle owner hits-left).")
(defvar *sr-kd-seed* nil)
(defun sr-kd-flush ()
  (when *sr-kd-seed*
    (loop for side from 0 for a in *sr-kd-acc* when a
          do (format t "kdesc ~d P~d pfar ~d kikonk ~d wavet ~d~%" *sr-kd-seed* (1+ side) (aref a 0) (aref a 1) (aref a 2))))
  (setf *sr-kd-acc* (list nil nil) *sr-kd-edge* (list nil nil) *sr-kd-waves* nil *sr-kd-seed* nil))
(defun sr-kd-step ()
  (setf *sr-kd-seed* *match-seed*)
  (let ((waves nil))
    (do-entities (h (hz hazard))
      (when (eq (hazard-kind hz) :wave) (push (list h (hazard-owner hz) (hazard-hits-left hz)) waves)))
    (do-sides (e)
      (let* ((f (fighter e)) (side (fighter-side f)) (o (fighter-opp f)) (fo (fighter o)) (g (gauges e)) (go (gauges o))
             (a (or (nth side *sr-kd-acc*) (setf (nth side *sr-kd-acc*) (make-array 3 :initial-element 0))))
             (ed (or (nth side *sr-kd-edge*) (list nil nil (gauges-konpaku go) 0 (gauges-reishi g) (gauges-reishi go))))
             (st (fighter-state f)) (mv (and (eq st :move) (fighter-move f))) (pend (first ed)))
        (when (and mv (not (eq mv (second ed))) (member (fighter-cls f) '(:na :ns)))   ; (a new J / NS: far or not)
          (setf pend (and (> (fighter-dist f) 2.4) mv)))
        (unless (and pend (eq mv pend)) (setf pend nil))
        (when (and pend (eq (fighter-contact f) :hit))
          (when (< (gauges-reishi go) (sixth ed)) (incf (aref a 0)))
          (setf pend nil))
        (when (and (plusp (fourth ed)) (< (gauges-konpaku go) (third ed)))
          (incf (aref a 1) (- (third ed) (gauges-konpaku go))))
        (when (and (< (gauges-reishi g) (fifth ed))
                   (some (lambda (w) (and (eql (second w) o)
                                          (let ((old (assoc (first w) *sr-kd-waves*)))
                                            (if old (< (third w) (third old)) (<= (third w) 0)))))
                         waves))
          (incf (aref a 2)))
        (setf (nth side *sr-kd-edge*) (list pend mv (gauges-konpaku go) (fighter-kikon-lock fo) (gauges-reishi g) (gauges-reishi go)))))
    (setf *sr-kd-waves* waves)))
;;; ---- STRAT_XLOG="<salt> <eps> [<seat 1|2>]" (docs/research/strategy-drsi/sp/arms6/xch.md, q3-xch): every CPU exchange decision outside
;;; rollouts (core-ai.lisp *CAI-XCH-HOOK*, right after CAI-XCH-STEP's rolls) with its cues, and its outcome followed until the exchange is
;;; over (both FIGHTER-XCH negative: back in neutral, a cinematic, a reset), *SR-XCAP* ticks, or the match's end. With chance EPS (a seat
;;; given: only that seat's CPU explores) the option is replaced by one drawn uniformly from the side's legal ones, from SR-FQ-U over
;;; (seed tick side salt) alone (never SIM-RND01; the rolls are made as shipped first): J side :as (an AS left) / :j / hold; NS side
;;; watch x carry. EPS 0: logs only, the play unchanged. One line a decision, at its close:
;;; "xd <seed> <tick> P<n> <char> <j|ns> pick <o> ship <o> ex <0|1> <cues> out dt <ticks> dh <MC-FULL-HEALTH mine - his, its change: the
;;;  teacher's unit> ts <ticks until this exchange's own key changed (a fresh cancel or the end), -1 never> dhs <dh at that tick: the short
;;;  window> dk <his Konpaku lost - mine> dr <his Reishi lost - mine>
;;;  drf <the same as fractions of the bars> dfs <my flash-step change - his> brk <me|him|both|-: who hit first> bt <ticks to that hit, -1>
;;;  osa <0|1: he started an SA before it> end <x|cap|m> m1 <my first new action cls:name@tick> hs1 <his action / state then> h1 <his
;;;  first new action> hit <the first hit's source>". J options as / j / hold; NS options w<0|1>c<0|1>.
(defvar *sr-x* (let ((l (ext:getenv "STRAT_XLOG"))) (and l (plusp (length l)) (with-input-from-string (in l) (list (read in) (read in) (read in nil nil))))))
(defparameter *sr-xcap* 900 "Ticks after which an exchange decision's outcome is cut (KK rarely returns to neutral).")
;;; STRAT_XPOL="<seat> hold|own|ownj" (with STRAT_XLOG, xch.md's match-level check): that seat's CPU plays a fixed J-side rule in every
;;; exchange (not an explored one): hold = never the AS nor the J; own = the AS when his own J's hit was not the cancel's (BRAIN-XOWN NIL),
;;; else hold; ownj = the same with the J instead of hold; j = always the next J.
(defvar *sr-xpol* (let ((l (ext:getenv "STRAT_XPOL"))) (and l (plusp (length l)) (with-input-from-string (in l) (list (read in) (read in))))))
;;; STRAT_XNS="<character> <pick> <carry>" (xch2.md §NS-BR): that character's CPU plays a fixed NS-side answer at every exchange it is the NS
;;; side of (whatever its rolls gave): pick watch (the SA on his seen turn) | early (the SA *CAI-XCH-SA-WAIT* after the cancel) | main (early
;;; when its own hit made the cancel, else watch: main's rule with the watch always on) | none (no SA) | ship (its rolls); carry 1 | 0 | ship.
(defvar *sr-xns* (let ((l (ext:getenv "STRAT_XNS"))) (and l (plusp (length l)) (with-input-from-string (in l) (loop for x = (read in nil :eof) until (eq x :eof) collect x)))))
;;; ... or STRAT_XNS="<character> mix <p watch> <p early, own hit> <p early, his hit> <p carry>": a mix as per-event rolls, drawn from
;;; SR-FQ-U over (seed tick side) alone (three draws from its digits; never SIM-RND01): the SA watched with p watch, then early by whose hit.
;;; ... or STRAT_XNS="<character> arms <p early> <p watch+carry>": one of the fixed arms per event (the rest: main), keeping each arm's
;;; own carry (early and main: the rolled carry; watch: carry on): the equilibrium's mix as played, not as independent rolls.
(defvar *sr-xrecs* nil "The open exchange decisions (plists, every key set at the start: SR-X-STEP updates them in place).")
(defun sr-x-name (ns pick carry)
  (if ns (format nil "w~ac~d" (case pick (:watch 1) (:early "e") (t 0)) (if carry 1 0)) (case pick (:as "as") (:j "j") (t "hold"))))
(defun sr-x-hook (e b f kit d)
  (when *in-rollout* (return-from sr-x-hook nil))   ; (never logged nor explored there; no rollout of the in-game MCTS reaches an exchange
                                                     ;  decision: 0 calls in KI seeds 301-302, so a rule here equals one in the rollouts too)
  (let* ((side (fighter-side f)) (o (fighter-opp f)) (fo (fighter o)) (g (gauges e)) (go (gauges o))
         (ns (or (eq (fighter-cls f) :ns) (and *core-as-sa-out* (eq (fighter-cls f) :as)))) (now (brain-now b))   ; (R4: an AS side answers too)
         (as (and (not ns) (kit-core-move kit :as (core-next-as f))))
         (asok (and as (not (fighter-as-done f))))
         (reach (and asok (<= d (+ (strat-reach as) (cai-margin b)))))
         (ws (and (not ns) (xch-j-weights (brain-chance b *cai-xch-j*) (strat-out now :xch-j nil))))
         (tot (if ws (+ (getf ws :as 0.0) (getf ws :j 0.0)) 0.0))
         (pas (if (and reach (plusp tot)) (/ (getf ws :as 0.0) tot) 0.0))
         (pj (if (and reach (plusp tot)) (/ (getf ws :j 0.0) tot) 0.0))
         (pw (if ns (strat-scale now :xch-sa-p (brain-chance b *cai-xch-sa-p*)) 0.0))
         (pc (if ns (strat-scale now :xch-carry-p (brain-chance b *cai-xch-carry-p*)) 0.0))
         (ship (sr-x-name ns (brain-xpick b) (brain-xcarry b)))
         (u (sr-fq-u *match-seed* *match-tick* side (first *sr-x*)))
         (ex (and (or (null (third *sr-x*)) (= (third *sr-x*) (1+ side))) (< u (second *sr-x*)))))
    (when ex                                ; (the option from U / EPS, uniform in 0-1: a second hash would be a shift of U, SR-FQ-JUDGE)
      (let* ((opts (if ns '((:watch t) (:watch nil) (nil t) (nil nil)) (if asok '(:as :j nil) '(:j nil))))
             (k (nth (min (1- (length opts)) (floor (* (/ u (second *sr-x*)) (length opts)))) opts)))
        (if ns (setf (brain-xpick b) (first k) (brain-xcarry b) (second k)) (setf (brain-xpick b) k))))
    (when (and *sr-xns* ns (not ex) (string-equal (symbol-name (first *sr-xns*)) (symbol-name (fighter-character f))))   ; (STRAT_XNS)
      (case (second *sr-xns*)
        (watch (setf (brain-xpick b) :watch)) (early (setf (brain-xpick b) :early)) (none (setf (brain-xpick b) nil))
        (main (setf (brain-xpick b) (if (brain-xown b) :early :watch)))
        (mix (destructuring-bind (pw peo peh pc) (cddr *sr-xns*)
               (let* ((u (sr-fq-u *match-seed* *match-tick* side 4242)) (u2 (mod (* u 1000) 1)) (u3 (mod (* u 1000000) 1)))
                 (setf (brain-xpick b) (and (< u pw) (if (< u2 (if (brain-xown b) peo peh)) :early :watch))
                       (brain-xcarry b) (< u3 pc))))))
      (when (eq (second *sr-xns*) 'arms)
        (destructuring-bind (pa pb) (cddr *sr-xns*)
          (let ((u (sr-fq-u *match-seed* *match-tick* side 4242)))
            (cond ((< u pa) (setf (brain-xpick b) :early))
                  ((< u (+ pa pb)) (setf (brain-xpick b) :watch (brain-xcarry b) t))
                  (t (setf (brain-xpick b) (if (brain-xown b) :early :watch)))))))
      (unless (member (second *sr-xns*) '(mix arms))
        (case (third *sr-xns*) (1 (setf (brain-xcarry b) t)) (0 (setf (brain-xcarry b) nil)))))
    (when (and *sr-xpol* (not ns) (= (first *sr-xpol*) (1+ side)) (not ex))   ; (STRAT_XPOL: the J side's pick by the rule)
      (setf (brain-xpick b) (case (second *sr-xpol*) (hold nil) (own (if (or (brain-xown b) (not asok)) nil :as))
                                  (ownj (if (or (brain-xown b) (not asok)) :j :as)) (j :j))))
    (push (list :seed *match-seed* :t0 *match-tick* :side side :ns ns
                :head (format nil "xd ~d ~d P~d ~(~a~) ~a pick ~a ship ~a ex ~d fs ~,1f ofs ~,1f ptr ~d optr ~d red ~d ored ~d kon ~d okon ~d r ~,3f or ~,3f d ~,2f form ~(~a~) oform ~(~a~) awk ~d oawk ~d time ~,3f arm ~(~a~) own ~d asok ~d reach ~d pas ~,2f pj ~,2f pw ~,2f pc ~,2f mv ~(~a~) omv ~(~a~)"
                              *match-seed* *match-tick* (1+ side) (fighter-character f) (if ns "ns" "j")
                              (sr-x-name ns (brain-xpick b) (brain-xcarry b)) ship (if ex 1 0)
                              (gauges-fs g) (gauges-fs go) (strat-hud-ptr f) (strat-hud-ptr fo) (cai-bit (gauges-red-p g)) (cai-bit (gauges-red-p go))
                              (gauges-konpaku g) (gauges-konpaku go) (/ (gauges-reishi g) (float (gauges-reishi-max g)))
                              (/ (gauges-reishi go) (float (gauges-reishi-max go))) d (fighter-form f) (fighter-form fo)
                              (cai-bit (gauges-awakened g)) (cai-bit (gauges-awakened go))
                              (match-elapsed (match-frames-left) (* 60 *match-seconds*)) (and now (getf (car now) :id))
                              (cai-bit (brain-xown b)) (cai-bit asok) (cai-bit reach) pas pj pw pc
                              (and (fighter-move f) (mv-name (fighter-move f))) (and (eq (fighter-state fo) :move) (fighter-move fo) (mv-name (fighter-move fo))))
                :rm (gauges-reishi g) :rh (gauges-reishi go) :km (gauges-konpaku g) :kh (gauges-konpaku go)
                :mx (float (gauges-reishi-max g)) :hx (float (gauges-reishi-max go)) :fm (gauges-fs g) :fh (gauges-fs go)
                :dt 0 :dm 0 :dh 0 :lkm 0 :lkh 0 :brk nil :bt -1 :osa nil :ocls-t (fighter-cls-t fo)
                :xk (fighter-xch f) :h0 (- (mc-full-health e) (mc-full-health o)) :hs nil :ts -1
                :mv0 (fighter-move f) :omv0 (fighter-move fo) :st0 (fighter-state f) :ost0 (fighter-state fo) :m1 "-" :hs1 "-" :h1 "-" :hit "-"
                :hl (- (mc-full-health e) (mc-full-health o)) :fl (- (gauges-fs g) (gauges-fs go)))
          *sr-xrecs*)))
(defun sr-x-close (r why)
  "R's line, from the values SR-X-STEP last stored (a match's end is closed on the next match's first step: its gauges are not R's)."
  (format t "~a out dt ~d dh ~,4f ts ~d dhs ~,4f dk ~d dr ~d drf ~,4f dfs ~,1f brk ~a bt ~d osa ~d end ~a m1 ~a hs1 ~a h1 ~a hit ~a~%" (getf r :head) (getf r :dt)
          (- (getf r :hl) (getf r :h0)) (getf r :ts) (or (getf r :hs) (- (getf r :hl) (getf r :h0)))
          (- (getf r :lkh) (getf r :lkm)) (- (getf r :dh) (getf r :dm)) (- (/ (getf r :dh) (getf r :hx)) (/ (getf r :dm) (getf r :mx)))
          (- (getf r :fl) (- (getf r :fm) (getf r :fh)))
          (case (getf r :brk) (:me "me") (:him "him") (:both "both") (t "-")) (getf r :bt) (if (getf r :osa) 1 0) why (getf r :m1) (getf r :hs1) (getf r :h1) (getf r :hit)))
(defun sr-x-flush ()
  "Close every open decision of an earlier match (its last observed step's values)."
  (setf *sr-xrecs* (remove-if (lambda (r) (and (/= (getf r :seed) *match-seed*) (progn (sr-x-close r "m") t))) *sr-xrecs*)))
(defun sr-x-new-p (f mv0 st0)
  "Has F started an action other than the one in play at the decision (MV0, his state last step ST0): a new move, a Step / Hoho?"
  (or (and (eq (fighter-state f) :move) (not (eq (fighter-move f) mv0)))
      (and (member (fighter-state f) '(:step :hoho)) (not (eq st0 (fighter-state f))))))
(defun sr-x-act (f cls dt)
  "F's action now as cls:name@DT (CLS NIL: no @), else his state."
  (let ((mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (format nil "~(~a~)~@[@~d~]" (if mv (format nil "~a:~a" (or (fighter-cls f) "-") (mv-name mv)) (fighter-state f)) (and cls dt))))
(defun sr-x-step ()
  "After each battle step: every open decision's drops (Reishi refills and the reset are not counted), who was hit first, his SA; closed
when the exchange is over or at the cap."
  (setf *sr-xrecs*
        (remove-if
         (lambda (r)
           (and (= (getf r :seed) *match-seed*)
                (let* ((side (getf r :side)) (e (if (zerop side) *p1* *p2*)) (o (if (zerop side) *p2* *p1*)) (f (fighter e)) (fo (fighter o))
                       (rm (gauges-reishi (gauges e))) (rh (gauges-reishi (gauges o))) (km (gauges-konpaku (gauges e))) (kh (gauges-konpaku (gauges o)))
                       (dm (- (getf r :rm) rm)) (dh (- (getf r :rh) rh)) (lkm (- (getf r :km) km)) (lkh (- (getf r :kh) kh)))
                  (when (plusp dm) (incf (getf r :dm) dm))
                  (when (plusp dh) (incf (getf r :dh) dh))
                  (when (plusp lkm) (incf (getf r :lkm) lkm))
                  (when (plusp lkh) (incf (getf r :lkh) lkh))
                  (setf (getf r :rm) rm (getf r :rh) rh (getf r :km) km (getf r :kh) kh (getf r :dt) (- *match-tick* (getf r :t0))
                        (getf r :hl) (- (mc-full-health e) (mc-full-health o)) (getf r :fl) (- (gauges-fs (gauges e)) (gauges-fs (gauges o))))
                  (unless (getf r :brk)
                    (let ((hm (or (plusp lkm) (and (plusp dm) (mc-full-reel-p (fighter-state f)))))
                          (hh (or (plusp lkh) (and (plusp dh) (mc-full-reel-p (fighter-state fo))))))
                      (setf (getf r :brk) (cond ((and hm hh) :both) (hh :me) (hm :him)))
                      (when (member (getf r :brk) '(:me :him))   ; (the first hit's source: the hitter's move, else his state: a clone or wave)
                        (setf (getf r :hit) (sr-x-act (if (eq (getf r :brk) :me) f fo) nil (- *match-tick* (getf r :t0)))))
                      (when (getf r :brk) (setf (getf r :bt) (- *match-tick* (getf r :t0))))))
                  (when (and (equal (getf r :m1) "-") (sr-x-new-p f (getf r :mv0) (getf r :st0)))
                    (setf (getf r :m1) (sr-x-act f t (- *match-tick* (getf r :t0))) (getf r :hs1) (sr-x-act fo nil nil)))   ; (and his then)
                  (when (and (equal (getf r :h1) "-") (sr-x-new-p fo (getf r :omv0) (getf r :ost0)))
                    (setf (getf r :h1) (sr-x-act fo t (- *match-tick* (getf r :t0)))))
                  (setf (getf r :st0) (fighter-state f) (getf r :ost0) (fighter-state fo))
                  (when (and (not (getf r :brk)) (eq (fighter-state fo) :move) (eq (fighter-cls fo) :sa) (/= (fighter-cls-t fo) (getf r :ocls-t)))
                    (setf (getf r :osa) t))   ; (an SA of his before the first hit: his answer, not his combo's)
                  (when (and (null (getf r :hs)) (/= (fighter-xch f) (getf r :xk)))   ; (the short window: this exchange's own key gone, a fresh
                    (setf (getf r :hs) (- (mc-full-health e) (mc-full-health o) (getf r :h0))   ;  cancel or the end)
                          (getf r :ts) (- *match-tick* (getf r :t0))))
                  (cond ((and (minusp (fighter-xch f)) (minusp (fighter-xch fo))) (sr-x-close r "x") t)
                        ((>= (- *match-tick* (getf r :t0)) *sr-xcap*) (sr-x-close r "cap") t)))))
         *sr-xrecs*)))
(when *sr-x* (setf *cai-xch-hook* #'sr-x-hook))
(defun sr-hook ()
  (when (and *sr-win* (battle-p) (plusp *match-tick*) (zerop (mod *match-tick* 90))) (sr-win-lines))
  (when (and (battle-p) (/= *sr-match* *match-seed*))
    (setf *sr-match* *match-seed*)
    (when *sr-clog* (setf *combat-log* t))
    (when *sr-x* (sr-x-flush))
    (when *sr-hr* (sr-hr-flush))
    (when *sr-desc* (sr-desc-flush))
    (when *sr-desc* (sr-kd-flush))                                ; (PLAN4 P5, Kenpachi's kdesc line)
    (sr-sw-flush)
    (sr-fq-flush)
    (sr-fqb-flush)
    (setf *cai-styles* (copy-tree *sr-styles0*))
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)) (ch (fighter-character f))
             (st (or (sr-strat (if (zerop (fighter-side f)) "STRAT_P1" "STRAT_P2")) (sr-strat (format nil "STRAT_~:@(~a~)" ch))))
             (dv (ext:getenv (if (zerop (fighter-side f)) "STRAT_DIF_P1" "STRAT_DIF_P2"))))
        (when (and b (equal dv "masher"))                           ; (STRAT_DIF_P<n>=masher: the button-masher, masher.lisp; its difficulty unread)
          (setf (brain-masher b) t (brain-m-left b) 0 (brain-press-left b) 0 dv nil)
          (format t "strat P~d masher~%" (1+ (fighter-side f))))
        (when (and b dv (plusp (length dv)))                       ; (STRAT_DIF_P<n>=easy|normal|hard: that seat's difficulty, its delay and
          (let ((dif (intern (string-upcase dv) :keyword)))         ;  its lookup strategy as START-MATCH gives them; DUEL_AI_STRATEGY §11.17)
            (setf (brain-difficulty b) dif (brain-delay b) (getf *ai-delay* dif 14))
            (brain-set-strat! b (strat-lookup ch (fighter-character (fighter (fighter-opp f))) dif))))   ; (another strategy: its state afresh)
        (when (and b st)
          (setf (brain-strat b) (if (eq st :none) nil st))
          (unless (or (eq st :none) (getf st :switch) (getf st :fq)) (remf *cai-styles* ch))
          (format t "strat P~d ~a~%" (1+ (fighter-side f)) (if (eq st :none) "none" (getf st :id))))
        (when (and b *sr-fql-seat*)                                ; (one designated learner, above)
          (setf (brain-fql b) nil)
          (when (and (= (fighter-side f) *sr-fql-seat*) (brain-strat b) (getf (brain-strat b) :fq))
            (fq-attach! e)
            (setf *sr-fql-key* (cons (position ch *roster*) (position (fighter-character (fighter (fighter-opp f))) *roster*))))))))
  (when (and *sr-x* (battle-p)) (sr-x-step))
  (when (battle-p) (sr-sw-note) (when *sr-fq* (sr-fq-note)) (when (and *sr-hr* (eq *flow* :battle)) (sr-hr-step))
    (when (and *sr-desc* (eq *flow* :battle)) (sr-desc-step))   ; (after a new match's flush: else its first step's counts replace the last match's)
    (when (and *sr-desc* (eq *flow* :battle)) (sr-kd-step))))   ; (PLAN4 P5, Kenpachi's kdesc line)

(let ((l (ext:getenv "STRAT_LAYER")))
  (when (and l (plusp (length l)))
    (setf *strat-layer* (cond ((string-equal l "t") t)
                              ((member l '("p1" "p2") :test #'string-equal) (1- (parse-integer l :start 1)))   ; (a seat, PLAN4 §6)
                              (t (loop for start = 0 then (1+ p) for p = (position #\, l :start start)
                                       collect (intern (string-upcase (subseq l start p)) :keyword) while p))))))
;;; STRAT_ANCHOR=<file> (PLAN4 §6, DUCT the frozen anchor): for this run the strategy layer's library and payoff matrix come from FILE, one
;;; plist (:LIBRARY (entry ...) :PAYOFF (row ...)): each entry a library plist (arms of both sides, written inline or as units; an entry's
;;; :WITH (unit ...) is laid under it, STRAT-WITH), each row as *STRAT-PAYOFF*'s. The game's library is not touched; but STRAT-LOOKUP then
;;; sees only the anchor's entries, so a seat that should play a table gets it by STRAT_P<n> (a file), not by its difficulty's lookup.
(let ((a (ext:getenv "STRAT_ANCHOR")))
  (when (and a (plusp (length a)))
    (let ((an (with-open-file (in a) (let ((*read-eval* nil)) (read in)))))
      (setf *strat-library* (mapcar (lambda (st) (strat-with (strat-expand (loop for (k v) on st by #'cddr unless (eq k :with) append (list k v)))
                                                             (getf st :with)))
                                    (getf an :library))
            *strat-payoff* (getf an :payoff)
            *strat-picks* (make-array (* 2 (length *strat-library*)) :initial-element 0))
      (format t "anchor ~a entries~{ ~(~a~)~}~%" a (mapcar (lambda (st) (getf st :id)) *strat-library*)))))
(let ((l (ext:getenv "STRAT_SET")))
  (when (and l (plusp (length l)))
    (loop for start = 0 then (1+ p) for p = (position #\, l :start start)
          do (let* ((kv (subseq l start p)) (q (position #\= kv)))
               (setf (symbol-value (intern (string-upcase (subseq kv 0 q)) :duel)) (let ((*read-eval* nil)) (read-from-string (subseq kv (1+ q))))))
          while p)))
(cl-user::sg-init)
(setf *step-hook* #'sr-hook)
(cl-user::sg-queue)
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(sr-sw-flush)
(sr-fq-flush)
(sr-fqb-flush)
(when *sr-x* (setf *match-seed* -1) (sr-x-flush))
(when *sr-hr* (sr-hr-flush))
(when *sr-desc* (sr-desc-flush))
(when *sr-desc* (sr-kd-flush))
(sr-fql-dump)
(finish-output)
(ext:quit 0)
