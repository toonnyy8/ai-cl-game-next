;;;; mcts-lite.lisp — the in-game MCTS's light model and search (docs/duel/DUEL_AI_TEACHER.md §9; the user, 2026-11-08: 「幫我實作遊戲中
;;;; 即時 MCTS，並用你先前建議的輕量模擬版本來減輕負擔」, 「全部取代」). Plain CL over the kit data (host-tested: tests/duel-rules/mcts.lisp);
;;;; the game's side (the perceived situation in, the press out) is cpu-mcts.lisp.
;;;;
;;;; The model is the neutral game to its first contact, on one axis: the distance (mm) and per fighter a state (free, wait, walk, guard,
;;;; a move at its frame, a Step, a Hoho, a reel, an invulnerable lie) with its frame. Moves come from the kit as records (startup, the
;;;; span of the hit windows, the whiff's end, reach, lunge, the triangle class, a wave's speed and range). Each step: the free fighters
;;;; pick (side 0's first pick is the root action, every later one the rollout policy *MC-PRIOR*), they move, a hit window or a wave that
;;;; reaches an open hurt circle connects, and the first contact ends the rollout with its outcome value (*MC-OUTCOMES*, measured in real
;;;; CPU matches by tools/simgate/contact.lisp: a contact's whole route, Kikons included, in the teacher's unit). A guard up takes it as a
;;;; block; two classed moves are judged by the triangle (CORE-VERDICT: a cancel ends at 0, an absorb lets the move go on). A fighter who is
;;;; threatened answers with a perfect Hoho (its counter's value) with the chance *MC-REACT-P*, rolled once per threat, when his Hoho is
;;;; ready (the gap that made Kenpachi's HARD teacher lose: DUEL_AI_TEACHER §8). No contact within *MC-HORIZON* steps: 0.
;;;; The search is UCB over the ten root actions (a flat MCTS: one bandit at the root, the rollout policy below it), a fixed number of
;;;; rollouts per difficulty (never a time budget: the native sim and the browser must agree), fixnum arithmetic only, its own Park-Miller
;;;; stream (Schrage's method: 30-bit fixnums never overflow) seeded per decision, no consing in a rollout.
(in-package :duel)

(defparameter *mc-actions* '(:j1 :sp :hoho :step-in :step-out :step-side :guard :wait :walk-in :walk-out)
  "The macro actions, codes 0-9 (the teacher's: DUEL_AI_TEACHER §3).")
(defparameter *mc-block-cont* nil
  "A blocked hit goes on (the defender in his blockstun, the attacker in his blocked recovery: BLOCKSTUN / MOVE-END-FRAME's numbers) with the
block's value added, rather than ending the rollout there (DUEL_AI_MCTS §8).")
(defparameter *mc-run* nil "The opponent in a rollout walking in from beyond *MC-RUN-FROM* runs (his kit's run speed), as the CPUs close in.")
(defparameter *mc-run-from* 3.0 "... from this far (m).")
(defparameter *mc-opp-model-on* nil
  "The opponent's picks in a rollout from *MC-OPP-MODEL* (what that character's fighters did in each situation) blended with *MC-PRIOR* by
*MC-OPP-PRIOR-N* pseudo-counts, rather than *MC-PRIOR* alone (DUEL_AI_MCTS §9).")
(defparameter *mc-opp-prior-n* 5 "Pseudo-counts of *MC-PRIOR* in each situation's row (data-biased response's ~5).")
(defparameter *mc-opp-model* nil
  "(character . counts): per distance band (< 2 / 4 / 7 m / beyond) x my state class (0 free or guarding, 1 a move's startup, 2 its active or
recovery frames, 3 a Step or Hoho, 4 reeling / down / blockstun) x the ten actions, what that character did (tools/simgate/oppmodel.lisp,
baked by tools/mc-oppmodel.py).")
(defvar *mc-w2* (make-array 200 :element-type (quote fixnum) :initial-element 0) "The opponent model's weights for this search: band x class x action (milli-counts).")
(defvar *mc-current-opp* nil "The opponent's character for MC-RELOAD-DYNAMIC.")

(defun mc-reload-dynamic ()
  "Load the opponent model of *MC-CURRENT-OPP* into *MC-W2* (and switch it on in *MC-G*) when *MC-OPP-MODEL-ON*, else off."
  (let ((row (and *mc-opp-model-on* (cdr (assoc *mc-current-opp* *mc-opp-model*)))) (psum (reduce #'+ *mc-prior*)))
    (setf (aref *mc-g* 10) (if row 1 0))
    (when row
      (dotimes (r 20)
        (dotimes (a 10)
          (setf (aref *mc-w2* (+ (* r 10) a))
                (+ (* 1000 (nth (+ (* r 10) a) row)) (floor (* 1000 *mc-opp-prior-n* (nth a *mc-prior*)) (max 1 psum)))))))))

(defparameter *mc-horizon* 60 "Steps a rollout plays at most (1 s): the neutral exchange to its first contact.")
(defparameter *mc-wait-busy* t "The horizon also covers the frames the opponent is still busy reeling or lying (at most *MC-HORIZON-MAX*).")
(defparameter *mc-horizon-max* 150 "... the longest horizon.")
(defparameter *mc-ucb-c* 0.15 "UCB's exploration weight (value units): mean + C x sqrt(N) / (1 + n).")
(defparameter *mc-react-p* '(:easy 0.0 :normal 0.02 :hard 0.05)
  "Chance the opponent in a rollout answers a threat with a perfect Hoho (his Hoho ready), once per threat, by the searcher's difficulty
(what it expects of him): measured, a free Hoho-ready defender within an NA / NS's reach + 1.35 m Hohoed it perfectly 1.6 % of the time at
NORMAL, 1.5 % (Ichigo) / 10.5 % (Kenpachi) at HARD (IK KK II, 10 seeds each, the CPUs under the MCTS, 2026-11-08, §9).")
(defparameter *mc-prior* '(14 10 0 5 5 4 12 16 24 10)
  "The rollout policy's weights per action code (a free fighter's every later pick): mostly walking in and waiting, J1 and SP, a guard,
now and then a Step; never a Hoho by choice (only as the answer above).")
(defparameter *mc-outcomes*
  '(((:hisagi :bankai) 0.109 0.135 0.377 0.073 0.121 0.042 -0.013)   ; n 1274
    ((:hisagi :bankai-bind) 0.143 0.127 0.280 0.073 0.104 0.051 -0.013)   ; n 231
    ((:hisagi :base) 0.156 0.066 0.232 0.073 0.105 0.048 -0.013)   ; n 2001
    ((:ichigo :base) 0.107 0.075 -0.002 0.085 0.101 0.063 -0.013)   ; n 3222
    ((:ichigo :kessa) 0.165 0.134 0.001 0.040 0.158 0.138 -0.013)   ; n 1921
    ((:kenpachi :bankai) 0.115 0.081 0.221 0.143 0.066 0.112 -0.009)   ; n 9
    ((:kenpachi :base) 0.087 0.091 0.221 0.143 0.062 0.113 -0.023)   ; n 3047
    ((:kenpachi :nozarashi) 0.151 0.061 0.220 0.143 0.073 0.110 -0.009)   ; n 1708
    ((:hisagi t) 0.143 0.116 0.280 0.073 0.104 0.051 -0.013)   ; n 3506
    ((:ichigo t) 0.136 0.096 0.001 0.071 0.121 0.104 -0.013)   ; n 5143
    ((:kenpachi t) 0.115 0.081 0.221 0.143 0.066 0.112 -0.009)   ; n 4764
    ((t t) 0.129 0.095 0.235 0.085 0.094 0.083 -0.013))   ; n 13413
  "What a neutral contact is worth to its attacker at EASY / NORMAL, per (character form): an NA hit, an NS hit under pointer 1 / 2 / 3, a turn
move's (AS / SA) hit, a perfect Hoho's counter, a blocked attack (tools/simgate/contact.lisp over IK KK II HK HI HH, 30 seeds each at
NORMAL, 2026-11-08, baked by tools/mc-outcomes.py; a slot under 30 samples takes the character's pooled mean, then everyone's).
(character T): any other form of his, (T T): anyone.")
(defparameter *mc-outcomes-hard*
  '(((:hisagi :bankai) 0.062 0.127 0.230 0.122 0.059 0.147 0.000)   ; n 1371
    ((:hisagi :bankai-bind) 0.125 0.145 0.137 0.122 0.125 0.100 0.000)   ; n 383
    ((:hisagi :base) 0.139 0.066 0.224 0.122 0.102 0.071 0.000)   ; n 2045
    ((:ichigo :base) 0.079 0.064 0.003 0.086 0.061 0.087 0.000)   ; n 2792
    ((:ichigo :kessa) 0.369 0.129 0.002 0.144 0.153 0.118 0.000)   ; n 1909
    ((:kenpachi :bankai) 0.202 0.085 0.276 0.158 0.101 0.213 0.000)   ; n 8
    ((:kenpachi :bankai-2) 0.202 0.085 0.276 0.158 0.101 0.213 0.000)   ; n 2
    ((:kenpachi :base) 0.235 0.078 0.341 0.158 0.072 0.242 0.000)   ; n 2435
    ((:kenpachi :nozarashi) 0.139 0.096 0.221 0.158 0.138 0.147 0.000)   ; n 1428
    ((:hisagi t) 0.125 0.113 0.219 0.122 0.096 0.100 0.000)   ; n 3799
    ((:ichigo t) 0.266 0.087 0.002 0.113 0.090 0.097 0.000)   ; n 4701
    ((:kenpachi t) 0.202 0.085 0.276 0.158 0.101 0.213 0.000)   ; n 3873
    ((t t) 0.212 0.094 0.221 0.123 0.096 0.140 0.000))   ; n 12373
  "... at HARD (the same 30 seeds at HARD: its CPUs convert more, e.g. Kenpachi's NA hit 0.087 -> 0.235, his counter 0.113 -> 0.242).")

(defun mc-outcomes-of (character form &optional (dif :normal))
  "The outcome row for CHARACTER in FORM at difficulty DIF (7 values), the nearest fallback when the form has none."
  (let ((tab (if (eq dif :hard) *mc-outcomes-hard* *mc-outcomes*)))
    (rest (or (assoc (list character form) tab :test #'equal) (assoc (list character t) tab :test #'equal) (assoc '(t t) tab :test #'equal)))))

;;; ---------------------------------------------------------------- records
(deftype mc-fv () '(simple-array fixnum (*)))
(defun mc-fv (n) (make-array n :element-type 'fixnum :initial-element 0))

;; a move record's fields
(defconstant +r-s+ 0) (defconstant +r-end+ 1) (defconstant +r-from+ 2) (defconstant +r-to+ 3) (defconstant +r-reach+ 4)
(defconstant +r-slide+ 5) (defconstant +r-cls+ 6) (defconstant +r-wave-v+ 7) (defconstant +r-wave-range+ 8) (defconstant +r-crush+ 9)
(defconstant +r-total+ 10) (defconstant +r-adv+ 11) (defconstant +r-end-blk+ 12) (defconstant +r-n+ 13)

(defvar *mc-recs* (make-hash-table :test 'eq) "MOVE -> its record (moves are shared definitions: built once).")
(defparameter *mc-cls-codes* #(nil :na :ns :as :sa))

(defun mc-move-rec (kit mv)
  "MV's record in KIT (cached): frames, the span of its hit windows, reach and lunge (mm), its class code, a wave (a hitless move whose
:params carry :speed and :range: the hazard it fires at S, mm per step and mm)."
  (or (gethash mv *mc-recs*)
      (setf (gethash mv *mc-recs*)
            (let* ((r (mc-fv +r-n+)) (hits (mv-hits mv)) (p (mv-params mv))
                   (wave (and (zerop (length hits)) (getf p :speed) (getf p :range))))
              (setf (aref r +r-s+) (mv-s mv)
                    (aref r +r-end+) (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) nil (zerop (length hits)) (mv-kind mv))
                    (aref r +r-from+) (if wave 9999 (mv-first-hit mv))
                    (aref r +r-to+) (if wave 0 (move-active-end mv))
                    (aref r +r-reach+) (round (* 1000 (mv-reach mv)))
                    (aref r +r-slide+) (max 0 (round (* 1000 (mv-slide mv))))
                    (aref r +r-cls+) (or (position (kit-class kit mv) *mc-cls-codes*) 0)
                    (aref r +r-wave-v+) (if wave (max 1 (round (* 1000 (getf p :speed)) 60)) 0)
                    (aref r +r-wave-range+) (if wave (round (* 1000 (getf p :range))) 0)
                    (aref r +r-crush+) (if (loop for w across hits thereis (intersection '(:guard-crush :unguardable) (hw-flags w))) 1 0)
                    (aref r +r-total+) (mv-total mv)                                          ; (blocked: the defender's blockstun is
                    (aref r +r-adv+) (- (if (integerp (mv-adv-block mv)) (mv-adv-block mv) 0)   ;  BLOCKSTUN of these, the attacker's end
                                        (if (eq (mv-kind mv) :quick) *quick-block-adv* 0))     ;  the blocked recovery: combat.lisp)
                    (aref r +r-end-blk+) (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) :block (zerop (length hits)) (mv-kind mv)))
              r))))

;;; ---------------------------------------------------------------- the state
;; a fighter's fields
(defconstant +f-kind+ 0) (defconstant +f-t+ 1) (defconstant +f-len+ 2) (defconstant +f-dir+ 3) (defconstant +f-slot+ 4)
(defconstant +f-spent+ 5) (defconstant +f-hoho+ 6) (defconstant +f-react+ 7) (defconstant +f-wave-x+ 8) (defconstant +f-wave-left+ 9)
(defconstant +f-start+ 10) (defconstant +f-hurt+ 11) (defconstant +f-walk+ 12) (defconstant +f-ptr+ 13) (defconstant +f-wave-v+ 14)
(defconstant +f-wave-o+ 15) (defconstant +f-cont+ 16) (defconstant +f-turn+ 17) (defconstant +f-run+ 18) (defconstant +f-n+ 19)
;; kinds
(defconstant +k-free+ 0) (defconstant +k-wait+ 1) (defconstant +k-walk+ 2) (defconstant +k-guard+ 3) (defconstant +k-move+ 4)
(defconstant +k-step+ 5) (defconstant +k-hoho+ 6) (defconstant +k-reel+ 7) (defconstant +k-lie+ 8) (defconstant +k-bstun+ 9)
;; outcome slots (*MC-OUTCOMES*' order)
(defconstant +o-na+ 0) (defconstant +o-ns1+ 1) (defconstant +o-turn+ 4) (defconstant +o-counter+ 5) (defconstant +o-block+ 6)

(defvar *mc-f* (vector (mc-fv +f-n+) (mc-fv +f-n+)) "The two fighters in a rollout (side 0 the searcher).")
(defvar *mc-i* (vector (mc-fv +f-n+) (mc-fv +f-n+)) "... and as the rollouts start.")
(defvar *mc-slots* (make-array 16 :initial-element nil)
  "Records: side x 8 + (0 his J1, 1 his NS under his pointer, 2 the move he is in, 3 / 4 the NS's next segments, 5 his SA, 6 / 7 the
segments after the move he is in).")
(defmacro mc-next-slot (k) "The slot of the NS segment after slot K's, or -1." `(case ,k (1 3) (3 4) (2 6) (6 7) (t -1)))
(defvar *mc-vals* (vector (mc-fv 7) (mc-fv 7)) "Per side, *MC-OUTCOMES*' row in milli-units.")
(defvar *mc-g* (mc-fv 11) "10 the opponent model on (*MC-W2*); 7 blocks go on (*MC-BLOCK-CONT*), 8 the opponent runs (*MC-RUN*), 9 a hazard's blockstun; 0 the starting distance (mm), 1 the rollout's react chance (per mille), 2 the RNG's state, 3 horizon, 4 the
opponent's answer delay (frames), 5 / 6 the chances (per mille) an NS goes on to its next segment / turns into the SA against an NA.")
(defvar *mc-w* (mc-fv 10) "*MC-PRIOR* as fixnums.")
(defvar *mc-n* (mc-fv 10) "Per root action: rollouts ...")
(defvar *mc-sum* (mc-fv 10) "... and their summed value (milli).")
(defvar *mc-legal* (mc-fv 10) "Per root action: 1 legal.")
(defvar *mc-n2* (mc-fv 100) "The tree's second level, per root action A and opponent reply B (10 A + B): rollouts ...")
(defvar *mc-sum2* (mc-fv 100) "... and side 0's summed value (milli).")
(defvar *mc-legal2* (mc-fv 10) "Per action of his: 1 legal.")
(defparameter *mc-opp-search* t
  "The tree's second level: the opponent's reply to each root action by its own UCB (he answers with his best response), else his first
pick is the policy's. (A decoupled bandit at the root, the replies blind to the root action, won HARD 5-6 of 40 against the matchup style
CPUs where this tree ...: §9.)")
(defparameter *mc-select* :tree   ; (bound per decision from *MC-SELECT-BY*, cpu-mcts.lisp)
  "How a search picks the two sides' first actions: :TREE (my action by UCB, then his reply to it by its own UCB: a 10 x 10 second level),
:DUCT (decoupled UCT: one UCB per side over its own actions, blind to the other's: 10 + 10 statistics), :DEEP (the event-driven tree, *MC-DEPTH*), :RM (simultaneous-move MCTS with
regret matching, outcome sampling: each side samples from its regret-matched strategy mixed with *MC-RM-GAMMA* exploration). Decoupled UCT was
the best of nine simultaneous-move games, regret matching the most robust, EXP3 the weakest (docs/research/ai-mcts-fuzzy-learning/notes-mcts.md
C; EXP3 also needs EXP, which the native sim and wasm may round apart: not offered).")
(defparameter *mc-depth* 4
  "The :DEEP search's depth: decisions down the tree (whoever decides next, as each fighter comes free in the rollout: an event-driven,
open-loop tree as Puppet-Master MCTS); below it the rollout policy. 2 is the :TREE's my action and his reply.")
(defconstant +mc-max-nodes+ 1024)
(defvar *mc-tn* (mc-fv (* +mc-max-nodes+ 20)) "The :DEEP tree: per node x side x action (20 a node): visits ...")
(defvar *mc-ts* (mc-fv (* +mc-max-nodes+ 20)) "... summed side-0 value (milli) ...")
(defvar *mc-tc* (mc-fv (* +mc-max-nodes+ 20)) "... and the child node it leads to (-1 none).")
(defvar *mc-tv* (mc-fv (* +mc-max-nodes+ 2)) "Per node x side: visits of that side's decision there.")
(defvar *mc-path* (mc-fv 96) "This rollout's tree decisions: (node side action) triples.")
(defvar *mc-tree* (mc-fv 4) "0 the node a rollout is at (-1 out of the tree), 1 the decisions taken, 2 nodes in use, 3 the depth.")
(defparameter *mc-rm-gamma* 0.1 "Regret matching's exploration: this share of each side's strategy spread evenly over its legal actions.")
(defvar *mc-r0* (mc-fv 10) "Regret matching: side 0's cumulative regrets (milli) ...")
(defvar *mc-r1* (mc-fv 10) "... and side 1's.")
(defparameter *mc-opp-delay* '(:easy 20 :normal 14 :hard 8)
  "Frames a free opponent takes to answer (his reply starts then), by the searcher's difficulty: what it expects of him (the CPUs' own
perception delays, *AI-DELAY*).")

(defun mc-seed (x) "Seed the search stream with integer X." (setf (aref *mc-g* 2) (1+ (mod x 268435398))))

(defmacro mc-rand (g n)
  "0 .. N-1 off the search stream in G (Park-Miller, m = 2^28 - 57, a = 16807, Schrage's q 15971 r 10802: no product past 2^29)."
  `(let* ((x (aref ,g 2)) (y (- (the fixnum (* 16807 (the fixnum (mod x 15971)))) (the fixnum (* 10802 (the fixnum (floor x 15971)))))))
     (declare (fixnum x y))
     (when (<= y 0) (incf y 268435399))
     (setf (aref ,g 2) y)
     (mod y ,n)))

(defun mc-init-fighter (v kind tt len hurt walk hoho ptr)
  "Fill fighter vector V: state KIND at frame TT of LEN, hurt radius and walk (mm, mm per step), HOHO 1 when his Hoho is ready, PTR his
SP pointer - 1 (0-2: which NS outcome his SP's hit is worth)."
  (fill v 0)
  (setf (aref v +f-kind+) kind (aref v +f-t+) tt (aref v +f-len+) len (aref v +f-hurt+) hurt (aref v +f-walk+) walk
        (aref v +f-hoho+) hoho (aref v +f-ptr+) ptr (aref v +f-wave-x+) -1 (aref v +f-start+) -1000 (aref v +f-slot+) 2)
  v)

;;; ---------------------------------------------------------------- one rollout
(defun mc-rollout (root root2)
  "Play one rollout from *MC-I*: side 0 starts action code ROOT, side 1's first pick is ROOT2 (-1: the policy's). Side 0's value (milli-units)."
  (declare (fixnum root root2) (optimize (speed 3) (safety 0)))
  (let* ((fs *mc-f*) (f0 (svref fs 0)) (f1 (svref fs 1)) (slots *mc-slots*) (g *mc-g*) (w *mc-w*)
         (v0 (svref *mc-vals* 0)) (v1 (svref *mc-vals* 1))
         (dist (aref g 0)) (react (aref g 1)) (horizon (aref g 3)) (tick 0) (first2 root2)
         (tn *mc-tn*) (ts *mc-ts*) (tc *mc-tc*) (tv *mc-tv*) (path *mc-path*) (tr *mc-tree*) (sq *mc-sqrt*) (uc (round (* 1000 *mc-ucb-c*)))
         (acc 0) (runfrom (round (* 1000 *mc-run-from*))) (w2 *mc-w2*))
    (declare (type mc-fv f0 f1 g w v0 v1 tn ts tc tv path tr sq w2) (simple-vector fs slots) (fixnum dist react horizon tick first2 uc acc runfrom))
    (replace f0 (the mc-fv (svref *mc-i* 0))) (replace f1 (the mc-fv (svref *mc-i* 1)))
    (when (and (or (>= root2 0) (= root2 -2)) (= (aref f1 +f-kind+) +k-free+))   ; a free opponent answers after his delay (standing till then)
      (setf (aref f1 +f-kind+) +k-wait+ (aref f1 +f-t+) 0 (aref f1 +f-len+) (max 1 (aref g 4))))
    (when (= (aref f1 +f-kind+) +k-move+)                       ; the move he is in: its rolls, this rollout's
      (setf (aref f1 +f-cont+) (if (< (mc-rand g 1000) (aref g 5)) 1 0) (aref f1 +f-turn+) (if (< (mc-rand g 1000) (aref g 6)) 1 0)))
    (macrolet ((rec (side k) `(the (or null mc-fv) (svref slots (+ (* 8 ,side) ,k))))
               (cur (me side) `(the mc-fv (rec ,side (aref ,me +f-slot+))))
               (val (side o) `(aref (if (= ,side 0) v0 v1) ,o))
               (signed (side v) `(if (= ,side 0) ,v (- ,v)))
               (legal (me side a) `(cond ((= ,a 6) nil) ((> ,a 2) t) ((= ,a 2) (= (aref ,me +f-hoho+) 1)) (t (rec ,side ,a))))   ; (no guard: the core system has none)
               (hit-slot (me r) `(case (aref ,r +r-cls+) (2 (+ +o-ns1+ (aref ,me +f-ptr+))) ((3 4) +o-turn+) (t +o-na+)))
               (invuln (op) `(let ((k (aref ,op +f-kind+)) (tt (aref ,op +f-t+)))
                               (or (= k +k-lie+) (and (= k +k-step+) (<= 3 tt 9)) (and (= k +k-hoho+) (<= 1 tt 14)))))
               (threat (op oside me)    ; does OP's move or wave threaten ME within the perfect Hoho's lead (12 f, 1 m inflate)?
                 `(or (and (= (aref ,op +f-kind+) +k-move+) (zerop (aref ,op +f-spent+))
                           (let* ((r (cur ,op ,oside)) (tt (aref ,op +f-t+)))
                             (and (< tt (aref r +r-to+)) (<= (- (aref r +r-from+) tt) 12)
                                  (<= dist (+ (aref r +r-reach+) (aref ,me +f-hurt+) 1000)))))
                      (and (>= (aref ,op +f-wave-x+) 0)
                           (<= (- dist (aref ,op +f-wave-x+)) (+ (* 12 (aref ,op +f-wave-v+)) (aref ,me +f-hurt+) 1000)))))
               (roll-react (me)        ; ME (side 1 only) rolls once whether he answers the threat just started with a perfect Hoho
                 `(setf (aref ,me +f-react+) (if (and (= (aref ,me +f-hoho+) 1) (< (mc-rand g 1000) react)) 1 0)))
               (start-slot (me side op k)   ; ME starts the move in slot K: its rolls (an NS's going on, its turn), his answer's
                 `(let ((k ,k))
                    (declare (fixnum k))
                    (setf (aref ,me +f-kind+) +k-move+ (aref ,me +f-slot+) k (aref ,me +f-spent+) 0 (aref ,me +f-start+) tick (aref ,me +f-t+) 0
                          (aref ,me +f-len+) (aref (the mc-fv (rec ,side k)) +r-end+)
                          (aref ,me +f-cont+) (if (< (mc-rand g 1000) (aref g 5)) 1 0) (aref ,me +f-turn+) (if (< (mc-rand g 1000) (aref g 6)) 1 0))
                    ,(if (eql side 0) `(roll-react ,op) nil)))
               (gap (me side op oside)      ; in an NS segment's gap: the SA against his NA coming, else the next segment
                 `(let* ((r (cur ,me ,side)) (tt (aref ,me +f-t+)))
                    (when (and (= (aref r +r-cls+) 2) (>= tt (aref r +r-to+)) (>= tt (aref r +r-s+)))
                      (cond ((and (= (aref ,me +f-turn+) 1) (rec ,side 5) (= (aref ,op +f-kind+) +k-move+) (zerop (aref ,op +f-spent+))
                                  (let ((ro (cur ,op ,oside)))
                                    (and (= (aref ro +r-cls+) 1) (< (aref ,op +f-t+) (aref ro +r-to+))
                                         (<= dist (+ (aref ro +r-reach+) (aref ,me +f-hurt+) 500)))))
                             (start-slot ,me ,side ,op 5))
                            ((and (= (aref ,me +f-cont+) 1) (>= (mc-next-slot (aref ,me +f-slot+)) 0) (rec ,side (mc-next-slot (aref ,me +f-slot+))))
                             (start-slot ,me ,side ,op (mc-next-slot (aref ,me +f-slot+))))))))
               (start (me side op oside a)
                 `(let ((a ,a))
                    (declare (fixnum a))
                    (unless (legal ,me ,side a) (setf a 7))
                    (setf (aref ,me +f-t+) 0 (aref ,me +f-dir+) 0)
                    (case a
                      ((0 1) (start-slot ,me ,side ,op a))
                      (2 (when (threat ,op ,oside ,me) (return-from mc-rollout (+ acc (signed ,side (val ,side +o-counter+)))))
                         (setf (aref ,me +f-kind+) +k-hoho+ (aref ,me +f-len+) 24 (aref ,me +f-hoho+) 0))
                      ((3 4 5) (setf (aref ,me +f-kind+) +k-step+ (aref ,me +f-len+) 24 (aref ,me +f-dir+) (case a (3 1) (4 -1) (t 0))))
                      (6 (setf (aref ,me +f-kind+) +k-guard+ (aref ,me +f-len+) 24))
                      ((8 9) (setf (aref ,me +f-kind+) +k-walk+ (aref ,me +f-len+) 20 (aref ,me +f-dir+) (if (= a 8) 1 -1)))
                      (t (setf (aref ,me +f-kind+) +k-wait+ (aref ,me +f-len+) 20)))))
               (pick (me side)          ; the rollout policy: *MC-PRIOR*, or for him the opponent model's row (*MC-W2*), over the legal actions
                 `(let ((tot 0) (pick 7) (ww w) (base 0))
                    (declare (fixnum tot pick base) (type mc-fv ww))
                    ,@(when (eql side 1)
                        `((when (= (aref g 10) 1)
                            (setf ww w2
                                  base (* 10 (+ (* 5 (cond ((< dist 2000) 0) ((< dist 4000) 1) ((< dist 7000) 2) (t 3)))
                                                (let ((k (aref f0 +f-kind+)))
                                                  (cond ((<= k +k-guard+) 0)
                                                        ((= k +k-move+) (if (< (aref f0 +f-t+) (aref (the mc-fv (rec 0 (aref f0 +f-slot+))) +r-s+)) 1 2))
                                                        ((<= k +k-hoho+) 3)
                                                        (t 4)))))))))
                    (dotimes (a 10) (when (legal ,me ,side a) (incf tot (aref ww (+ base a)))))
                    (let ((r (mc-rand g (max 1 tot))))
                      (declare (fixnum r))
                      (dotimes (a 10)
                        (when (legal ,me ,side a)
                          (decf r (aref ww (+ base a)))
                          (when (< r 0) (setf pick a) (return)))))
                    pick))
               (decide (me side op oside)
                 `(let ((k (aref ,me +f-kind+)))
                    ,@(when (eql side 1)   ; his answer to a threat: free, waiting or walking (the CPU's own are its next searches)
                        `((when (and (= (aref ,me +f-react+) 1) (<= k +k-walk+) (threat ,op ,oside ,me))
                            (return-from mc-rollout (+ acc (signed ,side (val ,side +o-counter+)))))))
                    (when (= k +k-move+) (gap ,me ,side ,op ,oside))
                    (when (= k +k-free+)
                      (start ,me ,side ,op ,oside
                             (if (and (= root2 -2) (>= (aref tr 0) 0)) (tree-pick ,me ,side)
                                 ,(if (eql side 0) `(if (= tick 0) root (pick ,me ,side)) `(if (>= first2 0) (prog1 first2 (setf first2 -1)) (pick ,me ,side))))))))
               (tree-pick (me side)       ; the :DEEP tree's decision for SIDE at its node: UCB over that side's legal actions, then down
                 `(let* ((nd (aref tr 0)) (base (+ (* nd 20) (* ,side 10))) (best 7) (bs most-negative-fixnum)
                         (root (aref sq (min 4095 (1+ (aref tv (+ (* nd 2) ,side)))))))
                    (declare (fixnum nd base best bs root))
                    (dotimes (a 10)
                      (when (legal ,me ,side a)
                        (let* ((k (aref tn (+ base a)))
                               (sc (if (zerop k) most-positive-fixnum
                                       (+ (* ,(if (eql side 0) 1 -1) (the fixnum (floor (aref ts (+ base a)) k))) (the fixnum (floor (* uc root) (1+ k)))))))
                          (declare (fixnum k sc))
                          (when (> sc bs) (setf bs sc best a)))))
                    (let ((d (aref tr 1)))
                      (setf (aref path (* 3 d)) nd (aref path (+ 1 (* 3 d))) ,side (aref path (+ 2 (* 3 d))) best (aref tr 1) (1+ d))
                      (let ((c (aref tc (+ base best))))
                        (cond ((>= c 0) (setf (aref tr 0) (if (>= (1+ d) (aref tr 3)) -1 c)))
                              ((< (aref tr 2) +mc-max-nodes+)            ; expansion: one new node, then out of the tree
                               (let ((new (aref tr 2)))
                                 (setf (aref tc (+ base best)) new (aref tr 2) (1+ new) (aref tr 0) -1)
                                 (fill tn 0 :start (* new 20) :end (* (1+ new) 20)) (fill ts 0 :start (* new 20) :end (* (1+ new) 20))
                                 (fill tc -1 :start (* new 20) :end (* (1+ new) 20))
                                 (setf (aref tv (* new 2)) 0 (aref tv (1+ (* new 2))) 0)))
                              (t (setf (aref tr 0) -1)))))
                    best))
               (move (me side)          ; this step's motion of ME (the distance) and of his wave
                 `(let ((k (aref ,me +f-kind+)) (tt (aref ,me +f-t+)) (dir (aref ,me +f-dir+)))
                    (declare (fixnum k tt dir))
                    (cond ((= k +k-walk+)
                           (decf dist (* dir ,(if (eql side 1)                       ; (he runs in from afar: *MC-RUN*)
                                                  `(if (and (= (aref g 8) 1) (= dir 1) (> dist runfrom) (plusp (aref ,me +f-run+)))
                                                       (aref ,me +f-run+) (aref ,me +f-walk+))
                                                  `(aref ,me +f-walk+)))))
                          ((= k +k-step+)
                           (cond ((and (/= dir 0) (< tt 12)) (decf dist (* dir (- (floor (* 2500 (1+ tt)) 12) (floor (* 2500 tt) 12)))))
                                 ((and (= dir 0) (= tt 6)) (setf dist (isqrt (+ (* dist dist) 6250000))))))
                          ((= k +k-move+)
                           (let* ((r (cur ,me ,side)) (s (aref r +r-s+)) (sl (aref r +r-slide+)))
                             (when (and (plusp sl) (< tt s) (> dist 950))
                               (setf dist (max 950 (- dist (- (floor (* sl (1+ tt)) s) (floor (* sl tt) s))))))
                             (when (and (= tt s) (plusp (aref r +r-wave-v+)))
                               (setf (aref ,me +f-wave-x+) 0 (aref ,me +f-wave-left+) (aref r +r-wave-range+)
                                     (aref ,me +f-wave-v+) (aref r +r-wave-v+) (aref ,me +f-wave-o+) (hit-slot ,me r))))))
                    (when (>= (aref ,me +f-wave-x+) 0)
                      (incf (aref ,me +f-wave-x+) (aref ,me +f-wave-v+))
                      (when (> (aref ,me +f-wave-x+) (aref ,me +f-wave-left+)) (setf (aref ,me +f-wave-x+) -1)))))
               (melee (me side op)      ; does ME's hit window reach OP this step?
                 `(and (= (aref ,me +f-kind+) +k-move+) (zerop (aref ,me +f-spent+))
                       (let ((r (cur ,me ,side)) (tt (aref ,me +f-t+)))
                         (and (<= (aref r +r-from+) tt) (< tt (aref r +r-to+)) (<= dist (+ (aref r +r-reach+) (aref ,op +f-hurt+)))))
                       (not (invuln ,op))))
               (wave (me op) `(and (>= (aref ,me +f-wave-x+) 0) (>= (aref ,me +f-wave-x+) (- dist (aref ,op +f-hurt+))) (not (invuln ,op))))
               (outcome (me side op oside m)   ; ME's contact (melee when M, else his wave): its value to side 0, or NIL (absorbed)
                 `(let ((crush (if ,m (aref (cur ,me ,side) +r-crush+) 0))
                        (o (if ,m (hit-slot ,me (cur ,me ,side)) (aref ,me +f-wave-o+))))
                    (declare (fixnum crush o))
                    (cond ((and (or (and (= (aref ,op +f-kind+) +k-guard+) (<= 4 (aref ,op +f-t+) 19)) (= (aref ,op +f-kind+) +k-bstun+))
                                (zerop crush))
                           (if (= (aref g 7) 1)                 ; the block goes on: his blockstun, my blocked recovery (*MC-BLOCK-CONT*)
                               (let ((stun (if ,m (let ((r (cur ,me ,side))) (max 1 (+ (- (aref r +r-total+) (aref ,me +f-t+)) (aref r +r-adv+))))
                                               (aref g 9))))
                                 (declare (fixnum stun))
                                 (incf acc (signed ,side (val ,side +o-block+)))
                                 (setf (aref ,op +f-kind+) +k-bstun+ (aref ,op +f-t+) 0 (aref ,op +f-len+) stun)
                                 (when ,m (setf (aref ,me +f-spent+) 1
                                                (aref ,me +f-len+) (max (1+ (aref ,me +f-t+)) (aref (cur ,me ,side) +r-end-blk+))))
                                 nil)
                               (signed ,side (val ,side +o-block+))))
                          ((and ,m (= (aref ,op +f-kind+) +k-move+) (plusp (aref (cur ,me ,side) +r-cls+))
                                (plusp (aref (cur ,op ,oside) +r-cls+)) (< (aref ,op +f-t+) (aref (cur ,op ,oside) +r-to+)))
                           (case (core-verdict (svref *mc-cls-codes* (aref (cur ,me ,side) +r-cls+)) (svref *mc-cls-codes* (aref (cur ,op ,oside) +r-cls+))
                                               :simul (melee ,op ,oside ,me) :att-t (aref ,me +f-start+) :def-t (aref ,op +f-start+))
                             (:hit (signed ,side (val ,side o)))
                             (:cancel 0)
                             (t (setf (aref ,me +f-spent+) 1) nil)))
                          (t (signed ,side (val ,side o))))))
               (advance (me op)
                 `(let ((tt (incf (aref ,me +f-t+))) (k (aref ,me +f-kind+)))
                    (declare (fixnum tt k))
                    (when (and (= k +k-hoho+) (= tt 6))   ; he reappears 1.6 m behind: the move he was dodging has lost him
                      (setf dist 1600 (aref ,op +f-spent+) 1 (aref ,op +f-wave-x+) -1))
                    (when (and (/= k +k-free+) (>= tt (aref ,me +f-len+)))
                      (setf (aref ,me +f-kind+) +k-free+ (aref ,me +f-slot+) 2)))))
      (loop while (< tick horizon)
            do (decide f0 0 f1 1)
               (decide f1 1 f0 0)
               (move f0 0) (move f1 1)
               (setf dist (max (+ (aref f0 +f-hurt+) (aref f1 +f-hurt+)) (min 20000 dist)))
               (let* ((m0 (melee f0 0 f1)) (m1 (melee f1 1 f0)) (w0 (and (not m0) (wave f0 f1))) (w1 (and (not m1) (wave f1 f0))))
                 (when (or m0 m1 w0 w1)
                   (when w0 (setf (aref f0 +f-wave-x+) -1))
                   (when w1 (setf (aref f1 +f-wave-x+) -1))
                   (let ((o0 (and (or m0 w0) (outcome f0 0 f1 1 m0))) (o1 (and (or m1 w1) (outcome f1 1 f0 0 m1))))
                     (when (or o0 o1) (return-from mc-rollout (+ acc (the fixnum (or o0 0)) (the fixnum (or o1 0))))))))
               (advance f0 f1) (advance f1 f0)
               (incf tick))
      acc)))

;;; ---------------------------------------------------------------- the search
(defvar *mc-sqrt* (let ((v (mc-fv 4096))) (dotimes (i 4096 v) (setf (aref v i) (isqrt i)))) "ISQRT 0-4095 (UCB in fixnums: no float boxing).")

(defun mc-search-deep (iters)
  "ITERS rollouts down the event-driven tree (*MC-DEPTH* decisions): each rollout starts at the root, each decision of either side as it
comes free takes that side's UCB pick at the node it is at, a new node is made at the first unvisited branch (then the rollout policy), and
the value is backed up along the path. *MC-N* / *MC-SUM*: the root's side-0 statistics (side 0 decides first: it is free)."
  (declare (fixnum iters) (optimize (speed 3) (safety 0)))
  (let ((tn *mc-tn*) (ts *mc-ts*) (tc *mc-tc*) (tv *mc-tv*) (path *mc-path*) (tr *mc-tree*) (n *mc-n*) (sum *mc-sum*))
    (declare (type mc-fv tn ts tc tv path tr n sum))
    (fill tn 0 :end 20) (fill ts 0 :end 20) (fill tc -1 :end 20) (setf (aref tv 0) 0 (aref tv 1) 0)
    (setf (aref tr 2) 1 (aref tr 3) (max 1 (min 32 *mc-depth*)))
    (dotimes (it iters)
      (setf (aref tr 0) 0 (aref tr 1) 0)
      (let ((v (mc-rollout 0 -2)))
        (declare (fixnum v))
        (dotimes (i (aref tr 1))
          (let* ((nd (aref path (* 3 i))) (sd (aref path (+ 1 (* 3 i)))) (a (aref path (+ 2 (* 3 i)))) (j (+ (* nd 20) (* sd 10) a)))
            (declare (fixnum nd sd a j))
            (incf (aref tn j)) (incf (aref ts j) v) (incf (aref tv (+ (* nd 2) sd)))))))
    (dotimes (a 10) (setf (aref n a) (aref tn a) (aref sum a) (aref ts a)))
    n))

(defun mc-search-rm (iters)
  "ITERS rollouts of simultaneous-move MCTS with regret matching at the root (outcome sampling): each side's strategy is its positive regrets
normalised (even when none), mixed with *MC-RM-GAMMA* over its legal actions; both sample, one rollout scores the pair (V for side 0, -V for
side 1), and every legal action's regret moves by [it was played] x V / its probability - V. Per-mille probabilities and milli values: fixnums
only (a regret stays under ~5e7 at 160 rollouts). *MC-N* / *MC-SUM* keep side 0's returns per action (the selection layer's values)."
  (declare (fixnum iters) (optimize (speed 3) (safety 0)))
  (let ((n *mc-n*) (sum *mc-sum*) (l0 *mc-legal*) (l1 *mc-legal2*) (r0 *mc-r0*) (r1 *mc-r1*) (g *mc-g*)
        (gam (round (* 1000 *mc-rm-gamma*))) (opp *mc-opp-search*))
    (declare (type mc-fv n sum l0 l1 r0 r1 g) (fixnum gam))
    (fill r0 0) (fill r1 0)
    (macrolet ((strat (r legal k pos)           ; side's probability (per mille) of action K
                 `(let ((k ,k))
                    (if (zerop (aref ,legal k)) 0
                        (+ (if (plusp ,pos) (floor (* (- 1000 gam) (max 0 (aref ,r k))) ,pos) (floor (- 1000 gam) cnt))
                           (floor gam cnt)))))
               (side (r legal)                  ; sample an action, return it and its probability; update nothing
                 `(let ((pos 0) (cnt 0))
                    (declare (fixnum pos cnt))
                    (dotimes (k 10) (when (= (aref ,legal k) 1) (incf cnt) (incf pos (max 0 (aref ,r k)))))
                    (if (zerop cnt) (values -1 1)
                        (let* ((tot 0) (x 0))
                          (declare (fixnum tot x))
                          (dotimes (k 10) (incf tot (strat ,r ,legal k pos)))
                          (setf x (mc-rand g (max 1 tot)))
                          (let ((pick -1) (p 1))
                            (declare (fixnum pick p))
                            (dotimes (k 10)
                              (let ((q (strat ,r ,legal k pos)))
                                (declare (fixnum q))
                                (when (and (plusp q) (< pick 0)) (decf x q) (when (< x 0) (setf pick k p q)))))
                            (values pick (max 1 p)))))))
               (regret (r legal a p u)          ; outcome-sampling regret update of one side
                 `(dotimes (k 10)
                    (when (= (aref ,legal k) 1)
                      (incf (aref ,r k) (- (if (= k ,a) (floor (* ,u 1000) ,p) 0) ,u))))))
      (dotimes (it iters)
        (multiple-value-bind (a pa) (side r0 l0)
          (declare (fixnum a pa))
          (when (< a 0) (return))
          (multiple-value-bind (b pb) (if opp (side r1 l1) (values -1 1))
            (declare (fixnum b pb))
            (let ((v (mc-rollout a b)))
              (declare (fixnum v))
              (incf (aref sum a) v) (incf (aref n a))
              (regret r0 l0 a pa v)
              (when (>= b 0) (regret r1 l1 b pb (- v))))))))
    n))

(defun mc-search (iters)
  "ITERS rollouts down a two-level tree: side 0's action A by UCB over *MC-LEGAL* (its value), then the opponent's reply B to A by UCB over
*MC-LEGAL2* (minus that value) when *MC-OPP-SEARCH*, else his policy's first pick; a rollout below. *MC-N* / *MC-SUM* per action of side 0.
UCB in milli-units and fixnums: mean + C x isqrt(N + 1) / (1 + n)."
  (declare (fixnum iters) (optimize (speed 3) (safety 0)))
  (let ((n *mc-n*) (sum *mc-sum*) (legal *mc-legal*) (n2 *mc-n2*) (sum2 *mc-sum2*) (legal2 *mc-legal2*) (sq *mc-sqrt*)
        (c (round (* 1000 *mc-ucb-c*))) (opp *mc-opp-search*))
    (declare (type mc-fv n sum legal n2 sum2 legal2 sq) (fixnum c))
    (fill n 0) (fill sum 0) (fill n2 0) (fill sum2 0)
    (macrolet ((ucb (n sum legal sign base total)
                 `(let ((best -1) (bs most-negative-fixnum) (root (aref sq (min 4095 (1+ ,total)))))
                    (declare (fixnum best bs root))
                    (dotimes (a 10)
                      (when (= (aref ,legal a) 1)
                        (let* ((k (aref ,n (+ ,base a)))
                               (s (if (zerop k)
                                      most-positive-fixnum
                                      (+ (* ,sign (the fixnum (floor (aref ,sum (+ ,base a)) k))) (the fixnum (floor (* c root) (1+ k)))))))
                          (declare (fixnum k s))
                          (when (> s bs) (setf bs s best a)))))
                    best)))
      (case *mc-select*
        (:duct                                                  ; one bandit per side, his blind to mine
         (dotimes (it iters)
           (let* ((a (ucb n sum legal 1 0 it)) (b (if opp (ucb n2 sum2 legal2 -1 0 it) -1)))
             (declare (fixnum a b))
             (when (< a 0) (return))
             (let ((v (mc-rollout a b)))
               (declare (fixnum v))
               (incf (aref sum a) v) (incf (aref n a))
               (when (>= b 0) (incf (aref sum2 b) v) (incf (aref n2 b)))))))
        (:rm (mc-search-rm iters))
        (:deep (mc-search-deep iters))
        (t
         (dotimes (it iters)
           (let* ((a (ucb n sum legal 1 0 it)) (b (if (and opp (>= a 0)) (ucb n2 sum2 legal2 -1 (* 10 a) (aref n a)) -1)))
             (declare (fixnum a b))
             (when (< a 0) (return))
             (let ((v (mc-rollout a b)))
               (declare (fixnum v))
               (incf (aref sum a) v) (incf (aref n a))
               (when (>= b 0) (incf (aref sum2 (+ (* 10 a) b)) v) (incf (aref n2 (+ (* 10 a) b))))))))))
    n))

(defun mc-mean (a)
  "Root action A's mean value (value units), or NIL when it was never played."
  (let ((k (aref *mc-n* a))) (and (plusp k) (/ (aref *mc-sum* a) (* 1000.0 k)))))
