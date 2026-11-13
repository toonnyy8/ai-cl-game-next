;;;; strategy-glue.lisp — the strategy layer's glue between the strategies (strategy.lisp: the library as data, its pure math) and the
;;;; CPU that plays them (core-ai.lisp CORE-BRAIN-STEP, cpu-mcts.lisp): the cues a strategy's rules read (STRAT-FEATS, STRAT-XFEATS), the
;;;; :HOLD-AWAKEN read, the composite / Q selector's judgement (STRAT-SWITCH-STEP) and its event layer (STRAT-EVENT-STEP), and the strategy
;;;; layer's selections by full-sim rollouts (STRAT-REQUEST ... STRAT-LOG, DUEL_AI_STRATEGY §5). Out of core-ai.lisp and cpu-mcts.lisp on
;;;; 2026-11-13 (REFACTOR_2026-11 R12), verbatim; loads right after core-ai.lisp.
(in-package :duel)

(defun strat-reach (mv) "MV's reach plus its forward slide (m), 1 when there is no move." (if mv (+ (mv-reach mv) (max 0.0 (mv-slide mv))) 1.0))

(defun strat-feats (e f s d)
  "The strategies' cues for E (fighter F) seeing SNAP S at distance D (DUEL_AI_STRATEGY §2): relative to the kits, so a strategy runs
for anyone."
  (let* ((kit (fighter-kit f)) (o (fighter-opp f)) (okit (fighter-kit (fighter o))) (g (gauges e)) (go (gauges o))
         (rj (strat-reach (kit-command-move kit :q e))) (rn (strat-reach (kit-core-move kit :ns (mc-ptr f))))
         (ro (strat-reach (kit-command-move okit :q o))))
    (list :dj (/ d (max 0.5 rj)) :dn (/ d (max 0.5 rn)) :do (/ d (max 0.5 ro))
          :lead (- (gauges-konpaku g) (gauges-konpaku go))
          :mr (/ (gauges-reishi g) (float (gauges-reishi-max g))) :or (/ (gauges-reishi go) (float (gauges-reishi-max go)))
          :ored (cai-bit (gauges-red-p go)) :hoho (cai-bit (hoho-ready-p e))
          :ost (case (snap-state s) ((:idle :run :guard) 0) (:move (if (and (snap-move s) (< (snap-sf s) (snap-s s))) 1 2)) ((:step :hoho) 3) (t 4))
          :wave (cai-bit (nth (1- (mc-ptr f)) (getf (kit-core kit) :ns-range))) :awk (cai-bit (gauges-awakened g)))))
(defun strat-form-index (f)
  "F's form as a Q selector's cue: 0 the base form (Hisagi's Shikai), 2 Hisagi's bind mode (:bankai-bind), 1 any other (his ranged mode, an
awakened form)."
  (case (fighter-form f) (:base 0) (:bankai-bind 2) (t 1)))
(defun strat-xfeats (e f d)
  "A Q selector's extra cues (its :XFEATS, DUEL_AI_STRATEGY §8.19), read only at its judgements: :DM the perceived distance (m), :FORM mine
(STRAT-FORM-INDEX), :OAWK his awakening, :GAUGE the switch's gauge (DRIVE awakened, SUBLIMATION before, as a fraction), :WALL metres from me
to the arena's wall."
  (let* ((g (gauges e)) (o (fighter-opp f)) (p (pos-of e)) (x (aref p 0)) (z (aref p 2)))
    (list :dm d :form (strat-form-index f) :oawk (cai-bit (gauges-awakened (gauges o)))
          :gauge (if (gauges-awakened g) (/ (gauges-drive g) *drive-max*) (/ (gauges-sub g) *sub-max*))
          :wall (- *arena-radius* (sqrt (+ (* x x) (* z z)))))))

(defun strat-hold-awaken-p (e)
  "The active strategy's :HOLD-AWAKEN H (DUEL_AI_STRATEGY §8.19 round 4; the user, 2026-11-09: 「試「延後覺醒」」): the CPU keeps from awakening
while its SUBLIMATION is below H of its maximum (it fills once the awakening gauge is full), so the Shikai's DRIVE switch has a gauge to spend.
No :HOLD-AWAKEN (every shipped strategy) or no active strategy (a human): NIL."
  (let ((h (strat-out :hold-awaken nil)))
    (and h (< (/ (gauges-sub (gauges e)) *sub-max*) h))))

(defvar *strat-judge-hook* nil
  "NIL in the game; a tool's function (e b sw sub index feats) -> (values sub index) run on each composite judgement outside rollouts (the
Q selector's training log, tools/simgate/strat-run.lisp STRAT_FQLOG: logs, and may explore the other arm).")
(defun strat-switch-step (e b f s d sw)
  "The active sub-strategy of the composite or Q selector SW (strategy.lisp) for brain B: judged on the match's first step and every
*STRAT-SWITCH-PERIOD* steps in neutral, else held (no random draw). Outside rollouts it counts the judgements and each entry's wins (BRAIN-SW-N / -WON)."
  (when (or (< (brain-sw-t b) 0)
            (and (member (fighter-state f) '(:idle :run))
                 (>= (- *match-tick* (brain-sw-t b)) (or (getf (getf sw :fq) :period) *strat-switch-period*))))   ; (a Q selector's own :PERIOD, §8.19)
    (setf (brain-sw-t b) *match-tick*)
    (multiple-value-bind (sub i)
        (let* ((fq (getf sw :fq)) (feats (strat-feats e f s d))
               (feats (if (getf fq :xfeats) (append feats (strat-xfeats e f d)) feats))   ; (its extra cues, §8.19)
               (feats (if fq (list* :prev (or (position (brain-sw-sub b) (getf fq :arms)) 0) feats) feats)))   ; (the previous arm)
          (multiple-value-bind (sub i) (strat-judge sw feats)
            (multiple-value-bind (sub i) (if (and *strat-judge-hook* (not *in-rollout*)) (funcall *strat-judge-hook* e b sw sub i feats) (values sub i))
              (when (and fq (brain-fql b) (not *in-rollout*))   ; (the online fuzzy Q: its exploration and record, fq-online.lisp)
                (multiple-value-setq (sub i) (fq-explore e sw sub i))
                (fq-note e b feats i))
              (values sub i))))
      (let* ((st (or sub (and (not (getf sw :fq)) (strat-lookup (fighter-character f) (fighter-character (fighter (fighter-opp f))) (brain-difficulty b)))))   ; (a Q selector's NIL arm: no strategy)
             (x (if st (getf st :fn) (cai-style-fn f))) (fn (if (and x (symbolp x)) (symbol-function x) x)))
        (when (and fn (not (eq fn (brain-sw-fn b))))      ; (another style function takes over: its own state, not the last one's struct)
          (if (getf (getf sw :fq) :keep-state)              ; (a Q selector's :KEEP-STATE, §8.19: the leaving style's state is kept, the
              (let ((old (brain-sw-fn b)) (kept (brain-sw-keep b)))   ;  coming one resumes its own)
                (when old
                  (let ((c (assoc old kept))) (if c (setf (cdr c) (brain-style b)) (push (cons old (brain-style b)) (brain-sw-keep b)))))
                (setf (brain-style b) (cdr (assoc fn (brain-sw-keep b)))))
              (when (brain-sw-fn b) (setf (brain-style b) nil)))
          (setf (brain-sw-fn b) fn)))
      (setf (brain-sw-sub b) sub)
      (unless *in-rollout*
        (let ((won (or (brain-sw-won b)   ; (one slot per entry, at least 8: §8.19 round 5 step 10's HK table has 9 arms)
                       (setf (brain-sw-won b) (make-array (max 8 (length (or (getf (getf sw :fq) :arms) (getf sw :switch)))) :initial-element 0)))))
          (incf (brain-sw-n b))
          (when (>= i 0) (incf (svref won i)))))))
  (brain-sw-sub b))

;;; The event layer (DUEL_AI_STRATEGY §8.19 round 5, step 6; §10's :EVENT-ARMS; the user, 2026-11-10: 「做成倒地時觸發的事件層」). A Q selector
;;; may name (:EVENT-ARMS ((:KNOCKDOWN ARM) ...)): while the opponent is perceived down (launched, down, waking up) and for the brain's
;;; perception delay + *STRAT-EVENT-GRACE* frames after (his first free frames are not in the SNAP yet), ARM plays the step whatever arm the
;;; table holds; then the table's pick plays again. The table keeps judging underneath (STRAT-SWITCH-STEP and its online learner run as
;;; before, so a judgement during a takeover credits the arm it holds: the layer is part of every arm's world). ARM's style keeps its own
;;; state in BRAIN-EV-STYLE, swapped into BRAIN-STYLE only while it plays, so the table's style state is untouched. No random draw; off
;;; when the key is absent (every table before this step). The window itself is strategy.lisp STRAT-EVENT-ARM (pure, host-tested).
(defun strat-event-step (b s sw)
  "The event arm that plays this step for brain B under the Q selector SW (its :EVENT-ARMS, STRAT-EVENT-ARM), else NIL; counts the takeovers
outside rollouts."
  (multiple-value-bind (on last) (strat-event-arm (getf sw :fq) (snap-state s) *match-tick* (brain-ev-t b) (brain-delay b))
    (setf (brain-ev-t b) last)
    (unless *in-rollout*
      (when (and on (not (brain-ev-on b))) (incf (brain-ev-n b)))
      (when on (incf (brain-ev-steps b))))
    (setf (brain-ev-on b) on)))
(defun strat-event-call (fn e b f kit s d)
  "Run the event arm's style FN with its own state in BRAIN-STYLE (BRAIN-EV-STYLE), then put the table's back."
  (let ((mine (brain-style b)))
    (setf (brain-style b) (brain-ev-style b))
    (let ((r (funcall fn e b f kit s d)))
      (setf (brain-ev-style b) (brain-style b) (brain-style b) mine)
      r)))

;;; ---------------------------------------------------------------- the strategy layer (DUEL_AI_STRATEGY §5, §8.4; a prototype, off by default)
;;; With *STRAT-LAYER* (strategy.lisp) a core CPU in neutral re-selects its strategy every *STRAT-PERIOD* steps and on coming back to
;;; neutral: Decoupled UCT over (his applicable strategies) x (the opponent's), one PUCT a side, each arm's statistics seeded from the
;;; offline payoff matrix (*STRAT-PAYOFF*: its value against the opponent's equilibrium mix, *STRAT-N0* pseudo-visits) and refined by
;;; *STRAT-ROLLS* full-sim rollouts sliced as the action layer's (MC-FULL-STEP: one a step at the steps' end, when no action rollout is
;;; due; the live state snapshotted and put back; lean steps; *IN-ROLLOUT*). In a rollout both CPUs play their sampled strategies (BRAIN-STRAT;
;;; a brainless human gets the stand-in brain with his), *STRAT-H* steps, scored by the health swing mapped to 0-1. His prior: the fuzzy :P
;;; of each strategy for the cues now; the opponent's arms: a flat prior. The pick: (1 - lambda) x value + lambda x prior. Until the first
;;; selection's rollouts are done he plays the pick from the seeds and the prior alone.
(defstruct (stjob (:constructor make-stjob (e side dif mine his prior sums ns hsums hns hprior)))
  "A selection: E's side, difficulty, his arms (plists) and the opponent's, the prior and the statistics of both PUCTs (simple-vectors), the
snapshot it starts from (taken by its first rollout) and the seed of its rollouts (common random numbers), rollouts done."
  e side dif mine his prior sums ns hsums hns hprior (snap nil) (rng 0) (n 0))
(inline-readers stjob)

(defun strat-layer-p (f) "Is fighter F's CPU under the strategy layer?" (and *strat-layer* (or (eq *strat-layer* t) (member (fighter-character f) *strat-layer*))))

(defun strat-request (e b f s d)
  "A selection for E: its arms seeded, a job queued; with no strategy yet, the seeds' and the prior's pick at once."
  (let* ((me (fighter-character f)) (vs (fighter-character (fighter (fighter-opp f)))) (dif (brain-difficulty b))
         (mine (strat-arms me vs)) (his (strat-arms vs me)) (feats (strat-feats e f s d))
         (p (map 'simple-vector (lambda (st) (strat-prior st feats)) mine)) (ptot (reduce #'+ p))
         (prior (map 'simple-vector (lambda (x) (/ x ptot)) p))
         (ns (make-array (length mine) :initial-element (float *strat-n0*)))
         (sums (map 'simple-vector (lambda (st) (* *strat-n0* (strat-seed-value me vs (getf st :id)))) mine))
         (hns (make-array (length his) :initial-element (float *strat-n0*)))
         (hsums (map 'simple-vector (lambda (st) (* *strat-n0* (strat-seed-value vs me (getf st :id)))) his))
         (hprior (make-array (length his) :initial-element (/ 1.0 (max 1 (length his))))))
    (unless (brain-strat b) (setf (brain-strat b) (nth (strat-final sums ns prior (getf *strat-lambda* dif 0.35)) mine)))
    (setf *strat-jobs* (append *strat-jobs* (list (make-stjob e (fighter-side f) dif mine his prior sums ns hsums hns hprior))))
    (incf (svref *strat-stats* 0))))

(defun strat-layer-step (e b f s d)
  "In CORE-BRAIN-STEP, outside rollouts: a selection when he is free and one is due (the period is over, or he comes back to neutral
after *STRAT-REGAIN* steps out of it) and none of his is running."
  (when (and (strat-layer-p f) (not *in-rollout*) (member (fighter-state f) '(:idle :run)))
    (when (and (or (>= *match-tick* (brain-st-next b)) (> (- *match-tick* (brain-st-free b)) *strat-regain*))
               (not (find (fighter-side f) *strat-jobs* :key #'stjob-side)))
      (setf (brain-st-next b) (+ *match-tick* *strat-period*))
      (strat-request e b f s d))
    (setf (brain-st-free b) *match-tick*)))

(defun strat-roll (j)
  "Job J's next rollout from its snapshot: both arms by their PUCT, both CPUs on them (a stand-in brain for a brainless opponent), *STRAT-H*
lean steps. Returns his arm, the opponent's and the 0-1 score; records nothing (STRAT-FULL-STEP does; the pollution test runs it bare)."
  (let* ((e (stjob-e j)) (o (fighter-opp (fighter e))) (dif (stjob-dif j))
         (i (strat-puct (stjob-sums j) (stjob-ns j) (stjob-prior j) *strat-c*))
         (k (strat-puct (stjob-hsums j) (stjob-hns j) (stjob-hprior j) *strat-c*)))
    (sim-restore (stjob-snap j))
    (setf (sim-rnd-state) (logior 1 (logand #xFFFFFFF (+ (stjob-rng j) 7919))))   ; (common random numbers: one seed for every rollout)
    (unless (brain o)                                                     ; (the human, as MC-FULL-ROLL: the stand-in plays his strategy)
      (add-component o (make-brain :difficulty dif :delay (getf *ai-delay* dif 14)))
      (setf (pilot-cam-relative (pilot o)) nil))
    (setf (brain-strat (brain e)) (nth i (stjob-mine j)) (brain-strat (brain o)) (nth k (stjob-his j)))
    (let ((sw (mc-full-rollout e o *strat-h* dif nil)))
      (values i k (max 0.0 (min 1.0 (+ 0.5 (/ sw (* 2.0 *strat-swing*)))))))))

(defun strat-full-step ()
  "One rollout of the oldest selection (MC-FULL-STEP, when no action rollout is due); its first takes the live state as its start. After
*STRAT-ROLLS* the pick goes into his brain (after the live state is back: a restore would undo it)."
  (if (not (sim-snapshot-ok-p))
      (setf *strat-jobs* nil)                                             ; (a cinematic, the match's end: asked again on coming back)
      (let* ((t0 (get-internal-real-time)) (j (first *strat-jobs*)) (live (sim-snapshot)))
        (unless (stjob-snap j) (setf (stjob-snap j) live (stjob-rng j) (sim-rnd-state)))
        (multiple-value-bind (i k v) (strat-roll j)
          (sim-restore live)
          (incf (svref (stjob-sums j) i) v) (incf (svref (stjob-ns j) i))
          (incf (svref (stjob-hsums j) k) (- 1.0 v)) (incf (svref (stjob-hns j) k)))
        (incf (svref *strat-stats* 1))
        (when (>= (incf (stjob-n j)) *strat-rolls*)
          (pop *strat-jobs*)
          (let* ((e (stjob-e j)) (b (brain e))
                 (a (strat-final (stjob-sums j) (stjob-ns j) (stjob-prior j) (getf *strat-lambda* (stjob-dif j) 0.35))))
            (when b
              (setf (brain-strat b) (nth a (stjob-mine j)))
              (incf (svref *strat-picks* (+ (* (length *strat-library*) (stjob-side j)) (position (getf (brain-strat b) :id) *strat-library* :key (lambda (st) (getf st :id)))))))))
        (let ((dt (- (get-internal-real-time) t0)))
          (incf (svref *strat-stats* 2) dt) (setf (svref *strat-stats* 3) (max (svref *strat-stats* 3) dt))))))

(defun strat-log ()
  "The match's strategy-layer line (RESULTS, beside MC-FULL-LOG; not one of G2's lines): selections, rollouts, ms a selection, the worst
step's ms, and per side how often each library entry was picked."
  (let ((st *strat-stats*) (ms (/ 1000.0 internal-time-units-per-second)))
    (when (plusp (svref st 0))
      (log-msg "duel stratlayer selections ~d rollouts ~d ms ~,3f a selection, worst step ~,2f picks P1 ~{~a~^ ~} P2 ~{~a~^ ~}"
               (svref st 0) (svref st 1) (/ (* ms (svref st 2)) (svref st 0)) (* ms (svref st 3))
               (loop for k below (length *strat-library*) collect (svref *strat-picks* k))
               (loop with n = (length *strat-library*) for k below n collect (svref *strat-picks* (+ n k)))))))
