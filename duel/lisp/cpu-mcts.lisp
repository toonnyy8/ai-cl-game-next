;;;; cpu-mcts.lisp — the CPU's neutral by an in-game MCTS over the light model (docs/duel/DUEL_AI_TEACHER.md §9; the user, 2026-11-08:
;;;; 「幫我實作遊戲中即時 MCTS，並用你先前建議的輕量模擬版本來減輕負擔」, asked where: 「全部取代」: every pairing, every difficulty; the KI
;;;; teacher's tables (§8) leave the game, kept in docs/research/ai-teacher/). When a core CPU is free (idle or running), not about to
;;;; awaken and within *MC-FAR*, it builds the light model's start (mcts-lite.lisp) from what it perceives: the opponent's SNAP (the
;;;; difficulty's perception delay *AI-DELAY* 24 / 14 / 8 f is its reaction time), the perceived distance, what the HUD shows (his form,
;;;; pointer, Hoho's readiness); then a fixed number of rollouts per difficulty (*MC-ITERS*) value the ten macro actions, and it picks as
;;;; the teacher did: only actions within the difficulty's mistake budget of the best, drawn by a softmax at its temperature (readable: the
;;;; same cue, the same behaviour); a wait / guard / walk holds 20 frames (the commitment). Everything else (moves, combos, stun, wake-up,
;;;; the awakening, a state the model can't start from) stays with the matchup style CPU or the generic one (core-brain-step).
(in-package :duel)

(defparameter *mc-on* t "The MCTS neutral in play: T, or a list of characters (a tool narrows it, or NIL turns it off, to compare).")
(defparameter *mc-iters* '(:easy 48 :normal 96 :hard 160) "Rollouts per decision by difficulty (a count, never a time: native = browser).")
(defparameter *mc-tau* '(:easy 0.05 :normal 0.03 :hard 0.015) "Softmax temperature per difficulty (value units: Konpaku), the teacher's.")
(defparameter *mc-budget* '(:easy 0.10 :normal 0.05 :hard 0.02) "Mistake budget per difficulty: actions worse than the best by more are never drawn.")
(defparameter *mc-select-by* '(:easy :tree :normal :tree :hard :duct)
  "The search's selection per difficulty (*MC-SELECT*). 80 IK seeds each, the MCTS side's wins, tree / decoupled UCT / regret matching
(the user asked why not DUCT or SM-MCTS with EXP3 / regret matching, 2026-11-08): Kenpachi HARD 51 / 63 / 53 (his CPU under it 60),
Kenpachi NORMAL 76 / 71 / 71, Ichigo NORMAL 64 / 59 / 51, Hisagi NORMAL (HK) 13 / 5 / 11 (DUEL_AI_MCTS §5).")
(defparameter *mc-far* 7.0 "Beyond this (m) the generic CPU closes in (its run), as before.")
(defparameter *mc-off-at* '((:ichigo :hard))
  "(character difficulty) pairs left wholly on the CPU under the MCTS: Ichigo's HARD (her MCTS won 5 / 14 / 9 / 11 of 40 against Kenpachi's
HARD style CPU at the margins 0.08 / 0.15 / 0.25 / 0.4, her style CPU 19: §9), 2026-11-08; her style CPU rather than the teacher's table
(the user: 「維持風格 CPU」).")
(defparameter *mc-sure* '(:easy 0.0 :normal 0.0 :hard 0.16)
  "The margin (value units) the best action must lead the second by for the MCTS to decide; below it the style / generic CPU decides. At
HARD only the light model's most decided fifth beat a uniform pick (margin >= 0.08: regret 0.132 against 0.226; the other four 0.21-0.26
against 0.21-0.26), at NORMAL every fifth did. Kenpachi's HARD MCTS against Ichigo's HARD style CPU, 80 IK seeds: 27 / 42 / 53 / 54 wins
at 0.08 / 0.12 / 0.16 / 0.25, his style CPU 50 (§9).")

;;; ---------------------------------------------------------------- the full sim's say (DUEL_AI_MCTS §12)
;;; The user, 2026-11-08: 「放進遊戲，全難度」 (the cheaper full-sim rollouts of §11 in the game) and, for a human opponent, 「之後學玩家習慣」
;;; (a stand-in CPU plays him in the rollouts until the online player model of stage 4 learns his habits). With *MC-FULL*, a decision is
;;; made one reaction time ahead: the light model ranks the actions from what he perceives (*MC-FULL-LITE* rollouts), he holds what he
;;; was doing for his perception delay (BRAIN-DELAY 24 / 14 / 8 f), and meanwhile, one rollout a step at the steps' end
;;; (MC-FULL-STEP), the full sim plays the best two from the state of the decision: the hold, then the action, the rest by the generic
;;; CPUs, to the first contact or *MC-FULL-H* steps after the hold, scored as the swing plus the outcome table's value of that contact.
;;; When the hold is over, he takes the better (the difficulty's mistake budget and softmax between the two). He acts on what was true a
;;; reaction time ago, as before, and the rollouts cost no extra delay.
(defparameter *mc-full* t "The full sim scores the light model's best two (T; NIL: the light model alone, as before §12).")
(defparameter *mc-full-lite* '(:easy 16 :normal 16 :hard 16)
  "The light search's rollouts per difficulty when it only ranks for the full sim (§11: 16 kept NORMAL's strength of 96).")
(defparameter *mc-full-h* 40 "A full-sim rollout's steps after the hold (it stops at the first contact before; §11).")
(defvar *in-rollout* nil "T inside a search's rollout (SIM-ROLLOUT, MC-FULL-STEP): no search, no job, no match end (GO-RESULTS).")
(defvar *mc-plan* (mc-fv 10)
  "Per side, 5 slots: the state (0 none, 1 its rollouts running, 2 scored), the light model's best and second action codes (-1 none),
their full-sim values (x 1000). Sim state (sim-state.lisp): MC-NEUTRAL reads it when his hold is over.")
(defvar *mc-jobs* nil "The decisions whose rollouts are running, oldest first (MC-FULL-STEP; dropped at a match start).")
(defvar *mc-full-stats* (make-array 4 :initial-element 0) "This match: decisions, rollouts, internal time in rollouts, the worst step's.")

(defun mc-press (b action)
  "Start ACTION as the brain's press (written this step)."
  (flet ((dash (dir to) (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to))))
    (ecase action
      (:j1 (ai-press b :quick 1))
      (:sp (ai-press b :quick 1 :modded t))
      (:hoho (ai-press b :step 1 :modded t :act :hoho))
      (:step-in (ai-press b :step 1 :act :dash) (dash 1 0.0))
      (:step-out (ai-press b :step 1 :act :dash) (dash -1 99.0))
      (:step-side (ai-press b :step 1 :act :side-step) (setf (brain-strafe b) 1f0))
      (:guard (ai-press b :guard 20))
      (:wait (ai-press b :none 20))
      (:walk-in (ai-press b :none 20 :act :dash) (dash 1 0.0))
      (:walk-out (ai-press b :none 20 :act :dash) (dash -1 99.0)))))

(defun mc-ptr (f) "F's SP pointer clamped to his three NS (1-3)." (max 1 (min 3 (fighter-ptr f))))

(defun mc-side-setup (side e kit dif)
  "Side SIDE's records (J1, his NS under his pointer) and outcome values; its fighter vector's constants."
  (let* ((f (fighter e)) (q (kit-command-move kit :q e)) (ns (kit-core-move kit :ns (mc-ptr f))) (vals (svref *mc-vals* side)))
    (fill *mc-slots* nil :start (* 8 side) :end (* 8 (1+ side)))
    (let* ((ns2 (and ns (mv-ns-next kit ns))) (ns3 (and ns2 (mv-ns-next kit ns2))) (sa (kit-sa-move kit)))
      (loop for mv in (list q ns nil ns2 ns3 sa) for k from 0
            when mv do (setf (svref *mc-slots* (+ k (* 8 side))) (mc-move-rec kit mv))))
    (loop for v in (mc-outcomes-of (fighter-character f) (fighter-form f) dif) for i from 0 do (setf (aref vals i) (round (* 1000 v))))
    (mc-init-fighter (svref *mc-i* side) +k-free+ 0 0 (round (* 1000 (body-hurt-r (model-body (model e))))) (round (* 1000 (kit-walk kit)) 60)
                     (if (hoho-open-p e) 1 0) (1- (mc-ptr f)))))

(defun mc-setup (e f kit s d &optional (dif :normal))
  "Fill the light model's start from E's view (his SNAP S of the opponent at distance D). NIL when the opponent's perceived state is not
one the model starts from (a cinematic, an intro, his knockdown and wake-up ...). DIF: the difficulty (what he expects of the opponent)."
  (let* ((o (fighter-opp f)) (fo (fighter o)) (okit (fighter-kit fo)) (v (svref *mc-i* 1)) (left (max 1 (min 90 (snap-left s)))))
    (mc-side-setup 0 e kit dif)
    (mc-side-setup 1 o okit dif)
    (flet ((state (kind tt len) (setf (aref v +f-kind+) kind (aref v +f-t+) tt (aref v +f-len+) len) t))
      (when (case (snap-state s)
              ((:idle :run) t)
              (:move (if (and (snap-move s) (eq (snap-phase s) :main))
                         (let* ((r (mc-move-rec okit (snap-move s))) (n2 (mv-ns-next okit (snap-move s))) (n3 (and n2 (mv-ns-next okit n2))))
                           (setf (svref *mc-slots* 10) r (aref v +f-slot+) 2
                                 (svref *mc-slots* 14) (and n2 (mc-move-rec okit n2)) (svref *mc-slots* 15) (and n3 (mc-move-rec okit n3))
                                 )
                           (state +k-move+ (snap-sf s) (max (1+ (snap-sf s)) (aref r +r-end+))))
                         (state +k-reel+ 0 left)))
              (:stun (state +k-reel+ 0 left))
              ;; (:air / :down / :wakeup: NIL, the wake-up pressure stays the style / generic CPU's: their timed meaty J1. Taken by the
              ;;  MCTS, Kenpachi's hits on her free frames fell 251 -> 62 in 10 HARD IK matches and HARD fell to 0-8 of 40; the light model
              ;;  was worse than a uniform pick there anyway, §9)
              ((:guard :guard-hit) (state +k-guard+ 4 24))
              (:step (state +k-step+ (max 7 (snap-sf s)) 24))
              (:hoho (state +k-hoho+ (snap-sf s) 24))
              (t nil))
        (setf (aref *mc-g* 0) (round (* 1000 d)) (aref *mc-g* 1) (round (* 1000 (getf *mc-react-p* dif 0.1))) (aref *mc-g* 4) (getf *mc-opp-delay* dif 14)
              (aref *mc-g* 5) (round (* 1000 (getf *cai-cont-p* dif 0.7))) (aref *mc-g* 6) (round (* 1000 (getf *cai-turn-p* dif 0.5)))
              (aref *mc-g* 3) (min *mc-horizon-max* (+ *mc-horizon* (if (and *mc-wait-busy* (member (aref v +f-kind+) (list +k-reel+ +k-lie+)))
                                                                      (- (aref v +f-len+) (aref v +f-t+)) 0))))
        (loop for x in *mc-prior* for i from 0 do (setf (aref *mc-w* i) x))
        (dotimes (a 10)
          (setf (aref *mc-legal* a) (if (case a (0 (svref *mc-slots* 0)) (1 (svref *mc-slots* 1)) (2 (hoho-open-p e)) (6 nil) (t t)) 1 0)
                (aref *mc-legal2* a) (if (case a (0 (svref *mc-slots* 8)) (1 (svref *mc-slots* 9)) (2 (hoho-open-p o)) (6 nil) (t t)) 1 0)))
        t))))

(defvar *mc-ws* (make-array 10 :element-type 'single-float :initial-element 0f0))
(defvar *mc-next* (mc-fv 2) "Per side, the match tick before which a search that deferred (*MC-SURE*) is not run again (sim state: sim-state.lisp).")
(defparameter *mc-defer-gap* 6 "Steps after a deferral before the next search (the CPU under it walks without a press: a search a step otherwise).")

(defun mc-est (a)
  "Root action A's light estimate plus the active strategy's bias for it (strategy.lisp :B-...; none: the estimate), or NIL."
  (let ((m (mc-mean a)) (k (svref *strat-bias-keys* a)))
    (if (and m *strat-now* k) (+ m (strat-out k 0)) m)))

(defun mc-neutral (e b f kit s d)
  "The MCTS neutral: T when it pressed (see the file header)."
  (when (plusp (aref *mc-plan* (* 5 (fighter-side f))))                 ; a decision made a reaction time ago comes due
    (return-from mc-neutral (mc-plan-apply b f)))
  (when *in-rollout* (return-from mc-neutral nil))                       ; (a rollout's later decisions: the generic CPU's)
  (when (and *mc-on* (or (eq *mc-on* t) (member (fighter-character f) *mc-on*)) (member (fighter-state f) '(:idle :run))
             (not (member (list (fighter-character f) (brain-difficulty b)) *mc-off-at* :test #'equal))
             (not (< *match-tick* (aref *mc-next* (fighter-side f)) (+ *match-tick* *mc-defer-gap* 1))) (<= d *mc-far*) (not (gauges-awakened-ok-p e)) (mc-setup e f kit s d (brain-difficulty b)))
    (mc-seed (logxor (sim-rnd-state) (+ (* 7919 *match-tick*) (fighter-side f) 1)))   ; (its own stream: the sim's is only read)
    (let ((*mc-select* (getf *mc-select-by* (brain-difficulty b) :tree)))
      (mc-search (if *mc-full* (getf *mc-full-lite* (brain-difficulty b) 16) (getf *mc-iters* (brain-difficulty b) 96))))
    (let* ((dif (brain-difficulty b)) (tau (getf *mc-tau* dif 0.03))
           (best (loop for a below 10 for m = (mc-est a) when m maximize m))
           (second (loop for a below 10 for m = (mc-est a) when (and m (< m best)) maximize m))
           (lo (- best (getf *mc-budget* dif 0.05))) (ws *mc-ws*) (tot 0.0))
      (when (and second (< (- best second) (getf *mc-sure* dif 0.0)))   ; not decided enough: the CPU under it decides
        (setf (aref *mc-next* (fighter-side f)) (+ *match-tick* *mc-defer-gap*))
        (return-from mc-neutral nil))
      (when *mc-full* (return-from mc-neutral (mc-full-request e b f)))
      (dotimes (a 10)
        (let ((m (mc-est a))) (setf (aref ws a) (if (and m (>= m lo)) (exp (/ (- m lo) tau)) 0f0)) (incf tot (aref ws a))))
      (let ((r (* tot (sim-rnd01))))
        (dotimes (a 10 (mc-press b (nth (loop for a below 10 when (eql (mc-est a) best) return a) *mc-actions*)))
          (when (plusp (aref ws a))
            (decf r (aref ws a))
            (when (<= r 0) (mc-press b (nth a *mc-actions*)) (return)))))
      t)))

;;; ---------------------------------------------------------------- the full sim's decisions (§12)
(defun mc-full-request (e b f)
  "After the light search: the best two go to the full sim (a job), he holds for his reaction time. T (he pressed)."
  (let* ((side (fighter-side f)) (k (* 5 side)) (a1 -1) (a2 -1) (m1 0.0) (m2 0.0))
    (dotimes (a 10)
      (let ((m (mc-est a)))
        (when m
          (cond ((or (< a1 0) (> m m1)) (setf a2 a1 m2 m1 a1 a m1 m))
                ((or (< a2 0) (> m m2)) (setf a2 a m2 m))))))
    (cond ((< a1 0) nil)
          ((< a2 0) (mc-press b (nth a1 *mc-actions*)) t)                 ; (one legal action: no question)
          (t (setf (aref *mc-plan* k) 1 (aref *mc-plan* (+ k 1)) a1 (aref *mc-plan* (+ k 2)) a2
                   (aref *mc-plan* (+ k 3)) 0 (aref *mc-plan* (+ k 4)) 0)
             (if (and (eq (brain-press b) :none) (eq (brain-act b) :dash))  ; the hold: a walk goes on, else he stands
                 (ai-press b :none (brain-delay b) :act :dash)
                 (ai-press b :none (brain-delay b)))
             (setf *mc-jobs* (append *mc-jobs* (list (vector e side a1 a2 (brain-difficulty b) nil 0 0 0.0 0.0 0))))
             (incf (svref *mc-full-stats* 0))
             t))))

(defun mc-plan-apply (b f)
  "His hold is over: the plan's pick (both scored: the better within the difficulty's budget, a softmax between them; still running:
the light model's best), if he is still free. The plan is cleared either way. T when he pressed."
  (let* ((k (* 5 (fighter-side f))) (st (aref *mc-plan* k)) (a1 (aref *mc-plan* (+ k 1))) (a2 (aref *mc-plan* (+ k 2))))
    (setf (aref *mc-plan* k) 0)
    (when (and (member (fighter-state f) '(:idle :run)) (>= a1 0))
      (let ((a (if (and (= st 2) (>= a2 0))
                   (let* ((dif (brain-difficulty b)) (gap (/ (- (aref *mc-plan* (+ k 3)) (aref *mc-plan* (+ k 4))) 1000.0)))
                     (cond ((> gap (getf *mc-budget* dif 0.05)) a1)
                           ((< (* (+ 1.0 (exp (/ (- gap) (getf *mc-tau* dif 0.03)))) (sim-rnd01)) 1.0) a1)
                           (t a2)))
                   a1)))
        (mc-press b (nth a *mc-actions*))
        t))))

(defun mc-full-reset ()
  "A match starts: no plan, no job, no stats (START-MATCH); the strategy layer's selections too."
  (fill *mc-plan* 0) (setf *mc-jobs* nil) (fill *mc-full-stats* 0)
  (setf *strat-jobs* nil) (fill *strat-stats* 0) (fill *strat-picks* 0))

(defun mc-full-health (e)
  "The teacher's unit: Konpaku + 1.5 x the Reishi bar's fraction."
  (let ((g (gauges e))) (+ (gauges-konpaku g) (* 1.5 (/ (gauges-reishi g) (float (gauges-reishi-max g)))))))

(defun mc-full-reel-p (st) (member st '(:stun :air :down :wakeup :guard-hit :cine)))

(defun mc-full-contact (e a d dif)
  "The outcome table's value, for E, of the contact attacker A just opened on D (contact.lisp's classes)."
  (let* ((fa (fighter a)) (mv (and (eq (fighter-state fa) :move) (fighter-move fa)))
         (cls (cond ((and (eq (fighter-state fa) :hoho) (fighter-perfect fa)) :counter) (mv (kit-class (fighter-kit fa) mv))))
         (row (mc-outcomes-of (fighter-character fa) (fighter-form fa) dif))
         (v (cond ((eq (fighter-state (fighter d)) :guard-hit) (nth 6 row))
                  ((eq cls :counter) (nth 5 row))
                  ((eq cls :na) (nth 0 row))
                  ((eq cls :ns) (nth (mc-ptr fa) row))
                  ((member cls '(:as :sa)) (nth 4 row))
                  (t 0.0))))
    (if (eq a e) v (- v))))

(defun mc-full-rollout (e o steps dif &optional (stop t))
  "One rollout from the state now (lean steps): E's score, the health swing to the first contact (or STEPS) plus the table's value of it.
STOP NIL: no stop at a contact, the swing over all STEPS (the strategy layer's rollouts)."
  (let ((*in-rollout* t) (*log-mute* t) (*pacing-log* nil) (*combat-log* nil) (*gate-log* nil) (*step-hook* nil) (*skip-cines* t)
        (*cai-styles* nil)
        (h0 (mc-full-health e)) (ho0 (mc-full-health o)) (bonus 0.0)
        (pe (fighter-state (fighter e))) (po (fighter-state (fighter o))))
    (loop repeat steps while (and (eq *flow* :battle) (not *cine*))
          do (sim-step-lean)
             (let ((se (fighter-state (fighter e))) (so (fighter-state (fighter o))))
               (flet ((opened (st prev) (and stop (member st '(:stun :air :down :guard-hit)) (not (mc-full-reel-p prev)))))
                 (cond ((opened so po) (setf bonus (mc-full-contact e e o dif)) (return))
                       ((opened se pe) (setf bonus (mc-full-contact e o e dif)) (return))))
               (setf pe se po so)))
    (+ bonus (- (- ho0 (mc-full-health o)) (- h0 (mc-full-health e))))))

(defun mc-full-roll (j)
  "Job J's next rollout (its K-th action) from its snapshot: that action planned for him, a stand-in brain for a brainless opponent."
  (destructuring-bind (e side a1 a2 dif) (coerce (subseq j 0 5) 'list)
    (let* ((n (svref j 6)) (k (* 5 side)) (o (fighter-opp (fighter e))))
      (sim-restore (svref j 5))
      (setf (sim-rnd-state) (logior 1 (logand #xFFFFFFF (+ (svref j 10) 7919))))   ; (common random numbers: one seed for both)
      (setf (aref *mc-plan* k) 2 (aref *mc-plan* (+ k 1)) (if (zerop n) a1 a2) (aref *mc-plan* (+ k 2)) -1)
      (unless (brain o)                                                   ; (the human: 「之後學玩家習慣」; a CPU's stick is not the camera's)
        (add-component o (make-brain :difficulty dif :delay (getf *ai-delay* dif 14)))
        (setf (pilot-cam-relative (pilot o)) nil))
      (setf (svref j (+ 8 n)) (mc-full-rollout e o (+ (brain-delay (brain e)) *mc-full-h*) dif)
            (svref j 6) (1+ n)))))

(defun mc-full-step ()
  "At a step's end (SIM-STEP), outside every rollout: one rollout of the oldest job, the live state saved and put back around it; a job
both of whose actions are scored writes them into the plan, the better first. Jobs made this step start from this state. No action job:
a rollout of the strategy layer's oldest selection (STRAT-FULL-STEP; the action layer's jobs are due within a reaction time, a selection
is not), so the two share the one rollout a step."
  (when (and (null *mc-jobs*) *strat-jobs* (not *in-rollout*)) (strat-full-step))
  (when (and *mc-jobs* (not *in-rollout*))
    (if (not (sim-snapshot-ok-p))
        (progn (setf *mc-jobs* nil) (fill *mc-plan* 0))
        (let ((t0 (get-internal-real-time)) (fresh nil))
          (dolist (j *mc-jobs*)
            (unless (svref j 5)
              (unless fresh (setf fresh (sim-snapshot)))
              (setf (svref j 5) fresh (svref j 10) (sim-rnd-state))))
          (let* ((j (first *mc-jobs*)) (k (* 5 (svref j 1))))
            (if (/= (aref *mc-plan* k) 1)
                (pop *mc-jobs*)                                            ; (its plan is gone: he was hit, or it came due)
                (let ((live (if (eq (svref j 5) fresh) (svref j 5) (sim-snapshot))))
                  (mc-full-roll j)
                  (sim-restore live)
                  (incf (svref *mc-full-stats* 1))
                  (when (= (svref j 6) 2)
                    (pop *mc-jobs*)
                    (let* ((v1 (svref j 8)) (v2 (svref j 9)) (swap (< v1 v2)))
                      (setf (aref *mc-plan* k) 2
                            (aref *mc-plan* (+ k 1)) (if swap (svref j 3) (svref j 2)) (aref *mc-plan* (+ k 2)) (if swap (svref j 2) (svref j 3))
                            (aref *mc-plan* (+ k 3)) (round (* 1000 (max v1 v2))) (aref *mc-plan* (+ k 4)) (round (* 1000 (min v1 v2)))))))))
          (let ((dt (- (get-internal-real-time) t0)))
            (incf (svref *mc-full-stats* 2) dt) (setf (svref *mc-full-stats* 3) (max (svref *mc-full-stats* 3) dt)))))))

(defun mc-full-log ()
  "The match's cost line (RESULTS; not one of G2's lines): decisions, rollouts, ms a decision, the worst step's ms."
  (let ((st *mc-full-stats*) (ms (/ 1000.0 internal-time-units-per-second)))
    (when (plusp (svref st 0))
      (log-msg "duel mcfull decisions ~d rollouts ~d ms ~,3f a decision, worst step ~,2f"
               (svref st 0) (svref st 1) (/ (* ms (svref st 2)) (svref st 0)) (* ms (svref st 3))))))

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
