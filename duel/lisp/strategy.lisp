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

;;; The DRIVE switch for a CPU (DUEL_AI_STRATEGY §8.16; the user, 2026-11-09: 「記得將消耗 drive 量表來臨時切換 NS 的戰術也安排到策略中」): a
;;; strategy's output :DSWITCH is the chance (its HARD value, core-ai.lisp *CAI-DSWITCH-DIF*) that a CPU switches in an NS segment's gap
;;; (DUEL_SUBLIMATION §17, the human's rules and press), one roll per segment; :DSWITCH-MAP ((form from to) ...) names the target pointer by
;;; his form and pointer, else the band rule below picks it. No :DSWITCH: never (the shipped CPU).
(defun strat-switch-to (ptr n d bands &optional to)
  "The pointer a switch from pointer PTR (of N) goes to at distance D: TO (an explicit target) when its NS opener reaches D, else the first
of the next, then the other pointers (cyclic) whose opener does; BANDS = a (lo hi) per pointer (index 0 = pointer 1, NIL: no NS). NIL: none."
  (flet ((ok (p) (and (<= 1 p n) (/= p ptr) (let ((bd (nth (1- p) bands))) (and bd (<= (first bd) d (second bd)))))))
    (if to
        (and (ok to) to)
        (loop for k from 1 below n for p = (1+ (mod (+ (1- ptr) k) n)) when (ok p) return p))))
(defun strat-switch-dir (ptr to n)
  "The stick's strafe sign that switches pointer PTR (of N) to TO: +1 the next (cyclic), -1 the previous (CORE-SWITCH-TARGET)."
  (if (= to (1+ (mod ptr n))) 1 -1))

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

;;; Online fuzzy Q against a human (DUEL_AI_STRATEGY §8.14; the user, 2026-11-09: 「對玩家的線上學習」). A CPU whose lookup strategy is a Q
;;; selector plays a per-player copy of it; each judgement of the match is recorded (firing vector, arm, health balance), and only at the match's
;;; end the copy takes Glorennec & Jouffe's TD updates, q_r(a) += eta x alpha_r x delta, delta = r + gamma x V(s') - Q(s, a), V(s) = sum_r
;;; alpha_r max_a q_r(a), each q clamped within the offline value +- cap and kept at the storage's resolution. Nothing changes during a match.
;;; The glue (who learns, the record, the page) is ai-learn.lisp.
(defparameter *fq-online-eta* 0.05
  "The online fuzzy Q's learning rate per transition (the user, 2026-11-09: 「對玩家的線上學習」, DUEL_AI_STRATEGY §8.14; new). Training seeds
against proxy 1 at cap 0.05: eta 0.05 187 wins of 599, 0.02 171, the offline table 89.")
(defparameter *fq-online-cap* 0.01
  "The most an online q may drift from its offline value, either way, so a few matches against an odd player cannot wreck the table (§8.14;
new). Training wins of 599 against proxy 1 / proxy 2 (offline table 89 / 387): cap 0.01 197 / 502, 0.02 174 / 487, 0.05 187 / 512, 0.1 70 / -;
the learned tables against the shipped Kenpachi (offline 0.905): cap 0.01 0.83-0.93, 0.05 0.35-0.96 (one proxy-1 table broke).")
(defparameter *fq-online-gamma* 0.9 "The online TD's discount per judgement window: the offline trainer's (fq.py, §8.12).")
(defparameter *fq-online-scale* 0.1 "The reward per window = this x the change of (my mc-full-health - his), as the offline trainer's; +-1 at the end.")
(defparameter *fq-unit* 100000 "An online q is kept as round(q x this) / this: the page stores those integers, so a table read back equals the one in memory.")
(defparameter *fq-online-eps* 0.0
  "The online fuzzy Q's chance that a judgement plays the other arm (two arms), drawn from FQ-U01 (match seed, tick, side), never SIM-RND01 (§8.14;
new). Off: the arm a state plays is the table's, and a losing arm's q falls until the other one leads, so a state explores where the player beats
it. Training seeds at cap 0.05, wins of 599 against the offline table's (proxy 1 89, proxy 2 387): eps 0 187 / 512, eps 0.05 242 / 354 (proxy 2
worse than no learning), eps 0.1 275 / not run.")
(defconstant +fq-format+ 1 "The saved online table's format version (its first entry).")

(defun fq-u01 (seed tick side)
  "A uniform 0-1 number from (SEED TICK SIDE) alone: a Park-Miller generator stirred four times (the offline log's, strat-run.lisp SR-FQ-U)."
  (let ((x (1+ (mod (+ (* seed 1000003) (* tick 7919) (* side 104729)) 2147483646))))
    (dotimes (i 4) (setf x (mod (* x 48271) 2147483647)))
    (/ x 2147483647d0)))

(defun fq-quant (q) "Q at the storage's resolution (*FQ-UNIT*)." (/ (round (* q *fq-unit*)) (float *fq-unit*)))

(defun strat-fq-fire (fq feats)
  "The Q selector FQ's rules' firing strengths for FEATS, normalised to sum 1 (a simple-vector; all 0 when none fires)."
  (let* ((w (map 'simple-vector (lambda (r) (strat-ante (first r) feats)) (getf fq :rules))) (den (reduce #'+ w)))
    (when (plusp den) (dotimes (k (length w)) (setf (svref w k) (/ (svref w k) den))))
    w))

(defun fq-q-at (fq fire a) "Q(s, A) of FQ at the normalised firing vector FIRE." (loop for r in (getf fq :rules) for x across fire sum (* x (nth (1+ a) r))))
(defun fq-v-at (fq fire) "V(s) = sum_r alpha_r max_a q_r(a) of FQ at FIRE." (loop for r in (getf fq :rules) for x across fire sum (* x (reduce #'max (rest r)))))

(defun fq-transitions (recs h-end won &optional (scale *fq-online-scale*))
  "A match's transitions from RECS, its judgements in order ((fire arm h) ...; H = my health balance then): ((fire arm r next-fire) ...),
r = SCALE x the change of H to the next judgement (to H-END at the last, plus WON: 1 a win, -1 a loss, 0 a draw), next-fire NIL at the last."
  (loop for (cur nxt) on recs
        collect (destructuring-bind (fire arm h) cur
                  (list fire arm (+ (* scale (- (if nxt (third nxt) h-end) h)) (if nxt 0.0 won)) (and nxt (first nxt))))))

(defun fq-td-update! (fq base trans &key (eta *fq-online-eta*) (gamma *fq-online-gamma*) (cap *fq-online-cap*))
  "Apply TRANS (FQ-TRANSITIONS, in order) to the Q selector FQ in place: per transition q_r(a) += ETA x alpha_r x delta, clamped within BASE's
(the offline table's) q +- CAP, at the storage's resolution. Returns FQ."
  (dolist (tr trans fq)
    (destructuring-bind (fire a r nfire) tr
      (let ((delta (- (+ r (if nfire (* gamma (fq-v-at fq nfire)) 0.0)) (fq-q-at fq fire a))))
        (loop for rule in (getf fq :rules) for b0 in (getf base :rules) for x across fire
              when (plusp x)
                do (let ((q0 (nth (1+ a) b0)))
                     (setf (nth (1+ a) rule) (fq-quant (max (- q0 cap) (min (+ q0 cap) (+ (nth (1+ a) rule) (* eta x delta))))))))))))

(defun fq-checksum (fq)
  "A small checksum of the Q selector FQ's q values (a saved online table is kept only while its offline table is the same)."
  (let ((s (length (getf fq :rules))))
    (dolist (r (getf fq :rules) s)
      (dolist (q (rest r)) (setf s (mod (+ (* 31 s) (round (* q *fq-unit*))) 999983))))))   ; (a polynomial hash: a weighted sum let opposite moves cancel)

(defun fq-encode (fq base n)
  "The page's integers for the online table FQ grown from BASE over N matches: format, BASE's checksum, N, then every q x *FQ-UNIT*."
  (list* +fq-format+ (fq-checksum base) n (loop for r in (getf fq :rules) append (mapcar (lambda (q) (round (* q *fq-unit*))) (rest r)))))

(defun fq-decode (codes base)
  "The online table saved as CODES for the offline Q selector BASE: (values a fresh copy of BASE carrying the saved q, its match count), or NIL
when CODES is empty, another format, another offline table's or the wrong size (the player then starts from BASE)."
  (let ((nq (loop for r in (getf base :rules) sum (length (rest r)))))
    (when (and (= (length codes) (+ 3 nq)) (eql (first codes) +fq-format+) (eql (second codes) (fq-checksum base)))
      (let ((fq (copy-tree base)) (qs (cdddr codes)))
        (dolist (r (getf fq :rules)) (loop for c on (rest r) do (setf (car c) (/ (pop qs) (float *fq-unit*)))))
        (values fq (third codes))))))

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
(defvar *strat-picks* (make-array 32 :initial-element 0) "This match: per side (16 slots each), how often each library entry was picked.")

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
     :else (:id :c1-ken :fn ken-ki-style))
    ;; the offline fuzzy Q table over the same two arms (§8.12, docs/research/strategy-drsi/fq/fq-trained.lisp; 「取代手寫規則」 2026-11-08)
    (:id :q1-ichigo-ken :apply (:ichigo :kenpachi) :fq (:arms ((:id :c1-ken :fn ken-ki-style) (:id :c1-own :fn ichigo-ki-style))
         :rules ((((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.0395 0.0304)
              (((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.0374 0.0312)
              (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.0436 0.0480)
              (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0362 0.0337)
              (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.0519 0.0284)
              (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.0356 0.0309)
              (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.0378 0.0389)
              (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.0259 0.0269)
              (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.1807 0.1633)
              (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.1827 0.1665)
              (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.1928 0.2367)
              (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.1882 0.2055)
              (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.1650 0.1660)
              (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.1667 0.1677)
              (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.1860 0.2042)
              (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.1628 0.1871)
              (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) -0.0141 -0.0151)
              (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) -0.0137 -0.0028)
              (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.0946 0.1128)
              (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0834 0.0747)
              (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0091 -0.0284)
              (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) -0.0205 -0.0264)
              (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.0778 0.0880)
              (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.0706 0.1054)
              (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.0449 0.0551)
              (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.0606 0.0596)
              (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.2019 0.2726)
              (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.2007 0.1997)
              (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.0438 0.0323)
              (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.0311 0.0321)
              (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.1866 0.2122)
              (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.1796 0.1806)
              (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.0086 0.0006)
              (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.0090 0.0021)
              (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.1479 0.1658)
              (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.1329 0.1256)
              (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0119 -0.0270)
              (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) -0.0247 -0.0257)
              (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.1302 0.1357)
              (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.1257 0.1138)
              (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.0000 -0.0010)
              (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.0000 -0.0010)
              (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.4566 0.5387)
              (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.4505 0.4495)
              (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) -0.0010 0.0000)
              (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) -0.0010 0.0000)
              (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.4457 0.4846)
              (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.4342 0.4199))))
    ;; Hisagi's distance control in the Bankai's ranged mode, with the DRIVE switch (§8.16; seeds/s8-hisagi-range.lisp): code, Hisagi
    ;; against anyone; not in the lookup (the shipped CPU unchanged)
    (:id :h1-range :fn hisagi-range-style :apply (:hisagi) :base (:dswitch 1.0) :dswitch-map ((:base 1 3))
     :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0))))   ; (no NS out of its reach: the ranged WA 0-3 m)
    ;; Hisagi's merged style (§8.17, 「合併兩種風格」 2026-11-09; seeds/s9-hisagi-merged.lisp): the distance rule owns every close event in the
    ;; ranged mode, Kenpachi's KI style the rest (:ken-ranged) and the other forms; no :dswitch (measured: it cost)
    (:id :hm1-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi))
    ;; Hisagi's three fitted Q tables (§8.17, docs/research/strategy-drsi/fq/hisagi/<p>-fqm.lisp): arm 0 the merged style (the init:
    ;; every cell arm 0, proved bit-identical to the merged style played whole), arm 1 the old incumbent (s3-zoner / Kenpachi's KI style /
    ;; the shipped CPU); fitted on seeds 1-599 (vs Ichigo: her frozen :ki-ichigo; vs Kenpachi: the proxy pool, fq/pools.json; the mirror:
    ;; the shipped CPU)
    (:id :qh-ichigo :apply (:hisagi :ichigo) :fq (:arms ((:id :hm1-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi)) (:id :s3-zoner :base (:range 1.5 :ns 0.9 :hoho 1.1 :kikon 0.4 :cont 0.8 :p 1.0 :b-walk-out 0.02 :b-wait 0.02 :b-j1 -0.08 :b-walk-in -0.04) :rules ((((:dn :reach)) (:b-sp 0.15 :b-walk-in -0.05)) (((:dn :out)) (:b-sp 0.1 :b-walk-in 0.04)) (((:dn :afar) (:wave :yes)) (:b-sp 0.18 :b-walk-in -0.04)) (((:do :in)) (:b-walk-out 0.12 :b-step-out 0.1 :b-j1 -0.05)) (((:dj :in)) (:b-step-out 0.08 :b-j1 0.05)) (((:ored :yes)) (:kikon 1.6)) (((:lead :ahead)) (:p 1.4)) (((:lead :behind)) (:p 0.6)) (((:mr :low)) (:p 1.3)))))
     :rules ((((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) -0.1046 -0.1047)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) -0.1080 -0.1090)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) -0.1263 -0.1535)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) -0.1216 -0.1539)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0943 -0.1184)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) -0.0991 -0.1191)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) -0.1103 -0.1688)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) -0.1282 -0.1593)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) -0.0927 -0.0990)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) -0.0968 -0.0995)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) -0.0967 -0.0978)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) -0.1112 -0.1122)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) -0.0882 -0.1289)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) -0.1027 -0.1037)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) -0.0957 -0.1080)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) -0.0998 -0.1121)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.0108 -0.0284)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) -0.0197 -0.0601)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) -0.0669 -0.1025)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0618 -0.0744)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0009 -0.0377)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.0056 -0.0494)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) -0.0636 -0.1065)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) -0.0872 -0.1024)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.0363 -0.0133)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) -0.0012 -0.0689)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) -0.0084 -0.0108)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0236 -0.1375)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.0226 -0.0260)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.0416 -0.0165)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) -0.0077 0.0052)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) -0.0226 -0.0236)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) -0.0461 -0.0622)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) -0.0516 -0.0773)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) -0.0687 -0.0868)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0675 -0.0945)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0464 -0.0882)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) -0.0699 -0.0919)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) -0.0634 -0.0870)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) -0.0772 -0.0981)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) -0.0128 -0.0360)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) -0.0396 -0.0406)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) -0.0205 -0.0215)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0169 -0.0309)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.0047 -0.0378)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) -0.0188 -0.0676)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) -0.0261 -0.0271)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) -0.0335 -0.0345))))
    (:id :qh-ken :apply (:hisagi :kenpachi) :fq (:arms ((:id :hm1-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi)) (:id :ki-ken :fn ken-ki-style :apply (:kenpachi :ichigo) :base (:p 1.3)))
     :rules ((((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) -0.0463 -0.0473)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) -0.0475 -0.0494)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) -0.0766 -0.0666)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0673 -0.0588)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) -0.0394 -0.0452)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) -0.0493 -0.0319)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) -0.0692 -0.0702)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) -0.0705 -0.0715)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.0466 0.0456)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.0488 0.0478)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.0233 0.0489)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0454 0.0444)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.0540 0.0342)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.0286 0.0276)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.0403 0.0574)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.0369 0.0795)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.0415 0.0508)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.0511 0.0457)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) -0.0523 -0.0439)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) -0.0402 -0.0432)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.0436 0.0290)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.0155 0.0562)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) -0.0334 -0.0367)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) -0.0361 -0.0371)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.1080 0.1273)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.1282 0.1242)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.0523 0.0305)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0536 0.0526)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.0993 0.0726)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.0573 0.1111)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.0345 0.0335)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.0344 0.0334)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.0626 0.0616)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.0642 0.0640)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.0720 0.0732)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0761 0.0751)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.0502 0.0480)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.0482 0.0433)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.0671 0.0624)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.0640 0.0614)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.2204 0.2194)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.2218 0.2208)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.3146 0.2980)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.3047 0.3037)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.2278 0.2268)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.1941 0.0000)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.2996 0.2920)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.2933 0.2923))))
    (:id :qh-mirror :apply (:hisagi :hisagi) :fq (:arms ((:id :hm1-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi)) (:id :shipped))
     :rules ((((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.1134 0.0941)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.1035 0.0821)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.0859 0.0736)
          (((:lead :behind) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0884 0.0701)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.0924 0.0651)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.1056 0.1046)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.0874 0.0808)
          (((:lead :behind) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.0835 0.0825)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.1928 0.1731)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.1945 0.1446)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.2204 0.2004)
          (((:lead :behind) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.2207 0.1840)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.1874 0.1751)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.2089 0.0000)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.2171 0.2161)
          (((:lead :behind) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.2287 0.1898)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.1412 0.1245)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.1347 0.1241)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.0761 0.0751)
          (((:lead :even) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.0735 0.0723)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.1304 0.1189)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.1341 0.1194)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.0757 0.0747)
          (((:lead :even) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.0677 0.0667)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.2020 0.1737)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.1940 0.1689)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.2421 0.2411)
          (((:lead :even) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.2260 0.2250)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.2023 0.1642)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.2001 0.1751)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.2397 0.1762)
          (((:lead :even) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.2182 0.2041)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :no)) 0.1474 0.1313)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :no) (:prev :yes)) 0.1425 0.1306)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :no)) 0.1627 0.1658)
          (((:lead :ahead) (:ored :no) (:ost :busy) (:awk :yes) (:prev :yes)) 0.1599 0.1596)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :no)) 0.1367 0.1275)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :no) (:prev :yes)) 0.1422 0.1232)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :no)) 0.1606 0.1652)
          (((:lead :ahead) (:ored :no) (:ost :free) (:awk :yes) (:prev :yes)) 0.1615 0.1561)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :no)) 0.2723 0.2440)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :no) (:prev :yes)) 0.2917 0.2398)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :no)) 0.4120 0.4416)
          (((:lead :ahead) (:ored :yes) (:ost :busy) (:awk :yes) (:prev :yes)) 0.4095 0.4085)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :no)) 0.2718 0.2236)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :no) (:prev :yes)) 0.2900 0.2337)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :no)) 0.4063 0.3928)
          (((:lead :ahead) (:ored :yes) (:ost :free) (:awk :yes) (:prev :yes)) 0.4051 0.4038)))))
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
  "The library's strategies ME may play against VS (their :APPLY (me vs), or (me): ME against anyone), in library order."
  (remove-if-not (lambda (st) (let ((ap (getf st :apply))) (or (null ap) (and (eq (first ap) me) (or (null (cdr ap)) (eq (second ap) vs))))))
                 *strat-library*))

(defparameter *strat-lookup* '((:hisagi :ichigo :hard :qh-ichigo) (:ichigo :hisagi :hard :ki-ichigo) (:ichigo :kenpachi :hard :q1-ichigo-ken)
                                (:hisagi :kenpachi :hard :qh-ken) (:hisagi :hisagi :hard :qh-mirror))
  "(me vs difficulty strategy-id): the strategy a CPU plays from the match's start (START-MATCH), the best fixed one where it beats the
shipped CPU by far (DUEL_AI_STRATEGY §8.6, the user, 2026-11-08: 「查表＋搜克制策略，之後再上 Q」). HARD only: EASY / NORMAL keep their designed
strength. Hisagi vs Ichigo HARD: s3 86 % (§8.5), 88 of 100 on seeds 301-350, against the shipped 50 of 80 (§8.4). The counter search's round 1
(§8.8, 「三筆都加」 2026-11-08; held-out seeds 700-799, both seats, the shipped CPU's share in brackets): Ichigo vs Hisagi her KI style
1.0 (0.13); Ichigo vs Kenpachi Kenpachi's KI style 0.415 (0.23); Hisagi vs Kenpachi the kite 0.47 (0.055). A strategy from here stops the
character's matchup style CPU (CORE-BRAIN-STEP), as in the search. Round 2 (§8.10, 「兩個都上」 2026-11-08): Ichigo vs Kenpachi the composite
:c1-ichigo-ken (Kenpachi's KI style, her own while he is free and she is behind or he is red) 0.825 (Kenpachi's style alone 0.415);
Hisagi vs Kenpachi Kenpachi's KI style 0.985 (the kite 0.47). The fuzzy Q table (§8.12, 「取代手寫規則」 2026-11-08) replaces c1 for Ichigo vs
Kenpachi: 0.905 / 0.895 against c1's 0.825 on seeds 600-699 / 700-799. Hisagi's three (§8.17, the user 2026-11-09: 「整場替換」,
「合併兩種風格」): fitted Q tables over his merged style and the old entry, seeds 601-700 / 701-800 both seats: vs Ichigo 0.335 / 0.415
(s3-zoner 0.0 / 0.0), vs Kenpachi 0.99 / 0.99 (Kenpachi's KI style 0.965 / 0.985), the mirror 0.985 / 1.0 against the shipped CPU.")

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
