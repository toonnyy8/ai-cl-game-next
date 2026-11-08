;;;; strategy.lisp — a CPU strategy as data (docs/duel/DUEL_AI_STRATEGY.md §2; the user, 2026-11-08: 「找出數種策略，在通過 fuzzy 與
;;;; Decoupled UCT 將這些策略結合在一起」). Plain CL over fuzzy.lisp, host-tested (tests/duel-rules/strategy.lisp).
;;;;
;;;; A strategy is a plist (:ID id :BASE (key value ...) :RULES ((((cue set) ...) (key value ...)) ...)): never code, so a search writes a data
;;;; file the evaluator loads into the shared build. Each output KEY is a zero-order Sugeno over the rules that name it (AND = min of the
;;;; cues' memberships, the values averaged by strength), its :BASE value when none fires, NIL when neither names it (the CPU's own value
;;;; then: no strategy changes nothing). The cues are relative to the kits (core-ai.lisp STRAT-FEATS), so a strategy runs for any character.
;;;; Outputs: :B-<action> a bias (value units) added to that macro action's estimate before the action layer ranks them; :RANGE the walk-to
;;;; range's scale; :NS the in-range NS share; :HOHO :TURN :CONT :KIKON :AWAKEN scales of the reactive layer's chances. + - x / only.
;;;; :FN (the user, 2026-11-08: 「策略可以包含程式」, DUEL_AI_STRATEGY §9): a function (e b f kit s d) -> T when it decided this step, run
;;;; first on every step the CPU is free to press (CORE-BRAIN-STEP), before the action layer: a strategy's own tactics (a matchup style CPU
;;;; is one: ken-ki-style, ichigo-ki-style).
(in-package :duel)

(defparameter *strat-bias-keys* #(:b-j1 :b-sp :b-hoho :b-step-in :b-step-out :b-step-side nil :b-wait :b-walk-in :b-walk-out)
  "Per macro action code (*MC-ACTIONS*' order; 6, the guard, has none): its bias key.")

(defun strat-ante (ante feats)
  "The strength of one antecedent ANTE ((CUE SET) ...) for the cue plist FEATS: AND = the minimum of the cues' memberships."
  (let ((w 1.0))
    (dolist (c ante w) (setf w (min w (fz-mu (getf feats (first c) 0) (second c)))))))

(defun strat-value (strat key feats)
  "STRAT's output KEY for the cue plist FEATS: the rules naming KEY by strength, else its :BASE value, else NIL."
  (let ((num 0.0) (den 0.0))
    (dolist (r (getf strat :rules))
      (let ((v (getf (second r) key)))
        (when v
          (let ((w (strat-ante (first r) feats)))
            (when (plusp w) (incf num (* w v)) (incf den w))))))
    (if (plusp den) (/ num den) (getf (getf strat :base) key))))

(defvar *strat-now* nil "While a core CPU with a strategy steps: (strategy . its cue plist this step) (CORE-BRAIN-STEP), else NIL.")

(defun strat-out (key default)
  "The active strategy's KEY now, or DEFAULT (no strategy, or it leaves KEY alone)."
  (or (and *strat-now* (strat-value (car *strat-now*) key (cdr *strat-now*))) default))

(defun strat-scale (key p)
  "Chance P times the active strategy's scale KEY (none: P), kept within 0-1."
  (let ((k (and *strat-now* (strat-value (car *strat-now*) key (cdr *strat-now*)))))
    (if k (max 0.0 (min 1.0 (* p k))) p)))

;;; A composite (DUEL_AI_STRATEGY §8.7): (:ID id :SWITCH ((OWN . STRATEGY) ...) [:ELSE STRATEGY]). OWN = a list of antecedents (OR = the maximum
;;; over them, each as a :RULES entry's antecedent). The first entry whose OWN fires at >= 0.5 is the active sub-strategy, else :ELSE, else
;;; none (the shipped CPU, its lookup strategy and style CPU included). Re-judged every *STRAT-SWITCH-PERIOD* steps in neutral (core-ai.lisp
;;; STRAT-SWITCH-STEP); the composite replaces BRAIN-STRAT (so it replaces the lookup's, which is the fallback when no sub is active).
(defparameter *strat-switch-period* 90
  "Steps between a composite strategy's judgements while its CPU is in neutral (1.5 s, as *STRAT-PERIOD*); the first is on the match's first step.")

(defun strat-own (own feats)
  "OWN's strength for the cue plist FEATS: the maximum over its antecedents of STRAT-ANTE."
  (let ((w 0.0)) (dolist (a own w) (setf w (max w (strat-ante a feats))))))

(defun strat-judge (sw feats)
  "The composite SW's judgement for FEATS: (values sub index), the first :SWITCH entry with OWN >= 0.5 (index from 0), else (values its :ELSE -1).
A Q selector (:FQ): (values its chosen arm, the arm's index)."
  (let ((fq (getf sw :fq)) (i 0))
    (if fq
        (let ((k (strat-fq-pick fq feats))) (values (nth k (getf fq :arms)) k))
        (dolist (en (getf sw :switch) (values (getf sw :else) -1))
          (when (>= (strat-own (car en) feats) 0.5) (return (values (cdr en) i)))
          (incf i)))))

;;; A fuzzy Q selector (DUEL_AI_STRATEGY §7 step 8', §8.12; Glorennec & Jouffe 1997): (:ID id :FQ (:ARMS (S0 S1 ...) :RULES ((ANTE Q0 Q1 ...) ...)
;;; [:MARGIN M])), judged as a composite (STRAT-SWITCH-STEP). Q(a) = the rules' q(a) averaged by firing strength (STRAT-ANTE; an empty ANTE
;;; always fires); the arm = argmax Q (ties: the first; no rule firing: arm 0), kept as the previous arm while it trails the best by less
;;; than M. The cue :PREV (the previous arm's index, 0 before the first) lets the rules price a switch. Always an arm: never the lookup's
;;; fallback. No random draw; the same function in rollouts. Trained offline (docs/research/strategy-drsi/fq/).
(defun strat-fq-q (fq feats)
  "The Q selector FQ's value per arm for FEATS: a simple-vector, every q averaged by the rules' firing strengths (all 0 when none fires)."
  (let* ((n (length (getf fq :arms))) (num (make-array n :initial-element 0.0)) (den 0.0))
    (dolist (r (getf fq :rules))
      (let ((w (strat-ante (first r) feats)))
        (when (plusp w)
          (incf den w)
          (loop for q in (rest r) for k below n do (incf (svref num k) (* w q))))))
    (when (plusp den) (dotimes (k n) (setf (svref num k) (/ (svref num k) den))))
    num))

(defun strat-fq-pick (fq feats)
  "The Q selector FQ's arm index for FEATS: argmax Q (ties: the first), the previous arm (:PREV) while it trails by less than :MARGIN."
  (let* ((q (strat-fq-q fq feats)) (best 0) (p (getf feats :prev 0)) (m (getf fq :margin)))
    (dotimes (k (length q)) (when (> (svref q k) (svref q best)) (setf best k)))
    (if (and m (< p (length q)) (< (- (svref q best) (svref q p)) m)) p best)))

(defun strat-fingerprint (strat keys grid)
  "STRAT's outputs KEYS at each cue plist of GRID (NIL read as 0): the vector two strategies are compared by (§3)."
  (coerce (loop for feats in grid append (loop for k in keys collect (or (strat-value strat k feats) 0))) 'simple-vector))

(defun strat-similarity (a b)
  "1 - the mean absolute difference of fingerprints A and B, each value scaled by the larger magnitude of the pair (1 = the same)."
  (let ((n (length a)) (tot 0.0))
    (dotimes (i n) (let ((x (svref a i)) (y (svref b i)))
                     (incf tot (if (and (zerop x) (zerop y)) 0.0 (/ (abs (- x y)) (max (abs x) (abs y)))))))
    (if (zerop n) 1.0 (- 1.0 (/ tot n)))))

;;; ---------------------------------------------------------------- the strategy layer's library and its pure parts (DUEL_AI_STRATEGY §5, §8.4)
;;; The prototype of step 5: a few strategies in the build, an offline payoff matrix per pairing to seed the statistics, Decoupled UCT
;;; (one PUCT a side) over (my applicable strategies) x (his) refined by full-sim rollouts (cpu-mcts.lisp STRAT-...), a fuzzy prior per
;;; strategy (its key :P, a zero-order Sugeno over the same cues as its outputs; 1 when it names none). Nothing here runs unless
;;; *STRAT-LAYER* (cpu-mcts.lisp) is on. :APPLY (me vs): only for that character against that one (NIL = anyone).
(defparameter *strat-layer* nil
  "The strategy layer in play (DUEL_AI_STRATEGY §5): NIL (off: the CPUs exactly as before), T, or a list of characters. A core CPU under it
re-selects its strategy (BRAIN-STRAT) in neutral every *STRAT-PERIOD* steps and on coming back to neutral; its matchup style CPU then runs
only as one of the strategies (:FN ken-ki-style ...).")
(defparameter *strat-period* 90 "Steps between selections while he is in neutral (1.5 s).")
(defparameter *strat-regain* 60 "Out of neutral at least this many steps (a long exchange, a knockdown, a cinematic): a selection on coming back.")
(defparameter *strat-rolls* 8 "Full-sim rollouts per selection (one a step, at the steps' end, when no action-layer rollout is due).")
(defparameter *strat-h* 150 "A selection rollout's steps (no stop at a contact: a strategy's worth shows over an exchange or two).")
(defparameter *strat-n0* 6 "Pseudo-visits of each arm's seed (the payoff matrix: 40 matches a cell against ~1 in-game rollout a joint cell).")
(defparameter *strat-c* 1.0 "PUCT's exploration constant.")
(defparameter *strat-swing* 2.0 "Health units (mc-full-health) of half the 0-1 score's range: a rollout scores 0.5 + swing / (2 x this), clipped.")
(defparameter *strat-lambda* '(:easy 0.7 :normal 0.35 :hard 0.1) "The final pick's weight on the prior (the rest on the values) per difficulty.")
(defvar *strat-jobs* nil "The selections whose rollouts are running, oldest first (cpu-mcts.lisp STRAT-FULL-STEP; dropped at a match start).")
(defvar *strat-stats* (make-array 4 :initial-element 0) "This match: selections, rollouts, internal time in them, the worst step's.")
(defvar *strat-picks* (make-array 16 :initial-element 0) "This match: per side (8 slots each), how often each library entry was picked.")

(defparameter *strat-library*
  '((:id :s0-generic :base (:p 1.0)
     :rules ((((:lead :even)) (:p 1.2))))
    (:id :s1-brawler
     :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0
            :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05)
     :rules ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12))
             (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1))
             (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08))
             (((:ost :active) (:dj :in)) (:b-hoho -0.05))
             (((:lead :behind)) (:p 1.5)) (((:lead :ahead)) (:p 0.7)) (((:or :low)) (:p 1.4))))
    (:id :s3-zoner
     :base (:range 1.5 :ns 0.9 :hoho 1.1 :kikon 0.4 :cont 0.8 :p 1.0
            :b-walk-out 0.02 :b-wait 0.02 :b-j1 -0.08 :b-walk-in -0.04)
     :rules ((((:dn :reach)) (:b-sp 0.15 :b-walk-in -0.05))
             (((:dn :out)) (:b-sp 0.1 :b-walk-in 0.04))
             (((:dn :afar) (:wave :yes)) (:b-sp 0.18 :b-walk-in -0.04))
             (((:do :in)) (:b-walk-out 0.12 :b-step-out 0.1 :b-j1 -0.05))
             (((:dj :in)) (:b-step-out 0.08 :b-j1 0.05))
             (((:ored :yes)) (:kikon 1.6))
             (((:lead :ahead)) (:p 1.4)) (((:lead :behind)) (:p 0.6)) (((:mr :low)) (:p 1.3))))
    (:id :ki-ken :fn ken-ki-style :apply (:kenpachi :ichigo) :base (:p 1.3))
    (:id :ki-ichigo :fn ichigo-ki-style :apply (:ichigo :kenpachi) :base (:p 1.3))
    (:id :s7-kite :apply (:hisagi :kenpachi)           ; (the counter search's round 1, counter/kh-hisagi b1_a2, DUEL_AI_STRATEGY §8.8)
     :base (:range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0
            :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05)
     :rules ((((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05))
             (((:dn :out)) (:b-sp 0.15))
             (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06))
             (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1))
             (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))
             (((:ored :yes)) (:kikon 1.6))))
    (:id :c1-ichigo-ken :apply (:ichigo :kenpachi)    ; (a composite: the counter search's round 2, counter/ki-ichigo b0_a2, §8.10)
     :switch (((((:ost :free) (:lead :behind)) ((:ost :free) (:ored :yes))) . (:id :c1-own :fn ichigo-ki-style)))
     :else (:id :c1-ken :fn ken-ki-style)))
  "The strategies the layer chooses from (the seeds s0, s1, s3, s5, s6 of docs/research/strategy-drsi/seeds/, each with prior rules :P; s7
the counter search's kite).")

(defparameter *strat-payoff*
  '((:kenpachi :ichigo (:s0-generic :s1-brawler :s3-zoner :ki-ken) (:s0-generic :s1-brawler :s3-zoner :ki-ichigo)
     ((1.0 0.75 1.0 0.0) (1.0 0.95 1.0 0.0) (0.9 0.975 0.925 0.0) (1.0 0.975 1.0 0.7))
     (0.0 0.0 0.0 1.0) (0.0 0.0 0.0 1.0))
    (:kenpachi :hisagi (:s0-generic :s1-brawler :s3-zoner) (:s0-generic :s1-brawler :s3-zoner)
     ((0.975 0.975 0.9) (0.975 1.0 1.0) (0.825 1.0 0.7))
     (0.0 1.0 0.0) (1.0 0.0 0.0))
    (:ichigo :hisagi (:s0-generic :s1-brawler :s3-zoner) (:s0-generic :s1-brawler :s3-zoner)
     ((0.325 0.625 0.125) (0.175 0.525 0.025) (0.25 0.5 0.025))
     (1.0 0.0 0.0) (0.0 0.0 1.0)))
  "Per pairing (A B rows cols M x y): A's HARD win share with row strategy against B's column strategy (tools/strategy-matrix.py, 20 seeds a
seat, seeds 1-20, both seats, 2026-11-08), and the matrix game's equilibrium mixes x (A's) and y (B's). B's view is 1 - M transposed.")

(defun strat-arms (me vs)
  "The library's strategies ME may play against VS (their :APPLY), in library order."
  (remove-if-not (lambda (st) (let ((ap (getf st :apply))) (or (null ap) (and (eq (first ap) me) (eq (second ap) vs)))))
                 *strat-library*))

(defparameter *strat-lookup* '((:hisagi :ichigo :hard :s3-zoner) (:ichigo :hisagi :hard :ki-ichigo) (:ichigo :kenpachi :hard :c1-ichigo-ken)
                                (:hisagi :kenpachi :hard :ki-ken))
  "(me vs difficulty strategy-id): the strategy a CPU plays from the match's start (START-MATCH), the best fixed one where it beats the
shipped CPU by far (DUEL_AI_STRATEGY §8.6, the user, 2026-11-08: 「查表＋搜克制策略，之後再上 Q」). HARD only: EASY / NORMAL keep their designed
strength. Hisagi vs Ichigo HARD: s3 86 % (§8.5), 88 of 100 on seeds 301-350, against the shipped 50 of 80 (§8.4). The counter search's round 1
(§8.8, 「三筆都加」 2026-11-08; held-out seeds 700-799, both seats, the shipped CPU's share in brackets): Ichigo vs Hisagi her KI style
1.0 (0.13); Ichigo vs Kenpachi Kenpachi's KI style 0.415 (0.23); Hisagi vs Kenpachi the kite 0.47 (0.055). A strategy from here stops the
character's matchup style CPU (CORE-BRAIN-STEP), as in the search. Round 2 (§8.10, 「兩個都上」 2026-11-08): Ichigo vs Kenpachi the composite
:c1-ichigo-ken (Kenpachi's KI style, her own while he is free and she is behind or he is red) 0.825 (Kenpachi's style alone 0.415);
Hisagi vs Kenpachi Kenpachi's KI style 0.985 (the kite 0.47).")

(defun strat-lookup (me vs dif)
  "*STRAT-LOOKUP*'s strategy (a library plist) for ME against VS at difficulty DIF, or NIL."
  (let ((r (find-if (lambda (r) (and (eq (first r) me) (eq (second r) vs) (eq (third r) dif))) *strat-lookup*)))
    (and r (find (fourth r) *strat-library* :key (lambda (st) (getf st :id))))))

(defun strat-seed-value (me vs id)
  "ME's expected win share with strategy ID against VS's equilibrium mix (*STRAT-PAYOFF*), 0.5 when the pairing or ID is not in it."
  (dolist (row *strat-payoff* 0.5)
    (destructuring-bind (a b rows cols m x y) row
      (cond ((and (eq a me) (eq b vs) (member id rows))
             (return (loop for v in (nth (position id rows) m) for w in y sum (* v w))))
            ((and (eq a vs) (eq b me) (member id cols))
             (let ((c (position id cols))) (return (- 1.0 (loop for r in m for w in x sum (* w (nth c r)))))))))))

(defun strat-prior (st feats) "Strategy ST's fuzzy prior weight for the cues FEATS (its :P; 1 when it names none)." (or (strat-value st :p feats) 1.0))

(defun strat-puct (sums ns prior c)
  "Decoupled UCT's choice for one side: the arm maximising mean + C x prior x sqrt(N) / (1 + n) (SUMS, NS, PRIOR: simple-vectors, the
prior summing to 1; N = all visits; + - x / sqrt only, the same in the browser and natively). Ties: the first."
  (let* ((n (length ns)) (tot (loop for k below n sum (svref ns k))) (sq (sqrt (float (max 1 tot)))) (best 0) (bv nil))
    (dotimes (k n best)
      (let ((v (+ (/ (svref sums k) (max 1e-6 (svref ns k))) (/ (* c (svref prior k) sq) (+ 1.0 (svref ns k))))))
        (when (or (null bv) (> v bv)) (setf best k bv v))))))

(defun strat-final (sums ns prior lam)
  "The selection's pick: the arm maximising (1 - LAM) x mean + LAM x prior / the largest prior (EASY leans on the prior, HARD on the
values). Ties: the first."
  (let ((pm (max 1e-6 (reduce #'max prior))) (best 0) (bv nil))
    (dotimes (k (length ns) best)
      (let ((v (+ (* (- 1.0 lam) (/ (svref sums k) (max 1e-6 (svref ns k)))) (* lam (/ (svref prior k) pm)))))
        (when (or (null bv) (> v bv)) (setf best k bv v))))))
