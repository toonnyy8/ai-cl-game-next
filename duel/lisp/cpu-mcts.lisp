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
                     (if (hoho-open-p e) 1 0) (1- (mc-ptr f)))
    (setf (aref (svref *mc-i* side) +f-run+) (round (* 1000 (kit-run kit)) 60))))

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
              (aref *mc-g* 7) (if *mc-block-cont* 1 0) (aref *mc-g* 8) (if *mc-run* 1 0) (aref *mc-g* 9) *hazard-blockstun*
              (aref *mc-g* 5) (round (* 1000 (getf *cai-cont-p* dif 0.7))) (aref *mc-g* 6) (round (* 1000 (getf *cai-turn-p* dif 0.5)))
              (aref *mc-g* 3) (min *mc-horizon-max* (+ *mc-horizon* (if (and *mc-wait-busy* (member (aref v +f-kind+) (list +k-reel+ +k-lie+)))
                                                                      (- (aref v +f-len+) (aref v +f-t+)) 0))))
        (loop for x in *mc-prior* for i from 0 do (setf (aref *mc-w* i) x))
        (setf *mc-current-opp* (fighter-character fo)) (mc-reload-dynamic)
        (dotimes (a 10)
          (setf (aref *mc-legal* a) (if (case a (0 (svref *mc-slots* 0)) (1 (svref *mc-slots* 1)) (2 (hoho-open-p e)) (6 nil) (t t)) 1 0)
                (aref *mc-legal2* a) (if (case a (0 (svref *mc-slots* 8)) (1 (svref *mc-slots* 9)) (2 (hoho-open-p o)) (6 nil) (t t)) 1 0)))
        t))))

(defvar *mc-ws* (make-array 10 :element-type 'single-float :initial-element 0f0))
(defvar *mc-next* (mc-fv 2) "Per side, the match tick before which a search that deferred (*MC-SURE*) is not run again (sim state: sim-state.lisp).")
(defparameter *mc-defer-gap* 6 "Steps after a deferral before the next search (the CPU under it walks without a press: a search a step otherwise).")

(defun mc-neutral (e b f kit s d)
  "The MCTS neutral: T when it pressed (see the file header)."
  (when (and *mc-on* (or (eq *mc-on* t) (member (fighter-character f) *mc-on*)) (member (fighter-state f) '(:idle :run))
             (not (member (list (fighter-character f) (brain-difficulty b)) *mc-off-at* :test #'equal))
             (not (< *match-tick* (aref *mc-next* (fighter-side f)) (+ *match-tick* *mc-defer-gap* 1))) (<= d *mc-far*) (not (gauges-awakened-ok-p e)) (mc-setup e f kit s d (brain-difficulty b)))
    (mc-seed (logxor (sim-rnd-state) (+ (* 7919 *match-tick*) (fighter-side f) 1)))   ; (its own stream: the sim's is only read)
    (let ((*mc-select* (getf *mc-select-by* (brain-difficulty b) :tree))) (mc-search (getf *mc-iters* (brain-difficulty b) 96)))
    (let* ((dif (brain-difficulty b)) (tau (getf *mc-tau* dif 0.03))
           (best (loop for a below 10 for m = (mc-mean a) when m maximize m))
           (second (loop for a below 10 for m = (mc-mean a) when (and m (< m best)) maximize m))
           (lo (- best (getf *mc-budget* dif 0.05))) (ws *mc-ws*) (tot 0.0))
      (when (and second (< (- best second) (getf *mc-sure* dif 0.0)))   ; not decided enough: the CPU under it decides
        (setf (aref *mc-next* (fighter-side f)) (+ *match-tick* *mc-defer-gap*))
        (return-from mc-neutral nil))
      (dotimes (a 10)
        (let ((m (mc-mean a))) (setf (aref ws a) (if (and m (>= m lo)) (exp (/ (- m lo) tau)) 0f0)) (incf tot (aref ws a))))
      (let ((r (* tot (sim-rnd01))))
        (dotimes (a 10 (mc-press b (nth (loop for a below 10 when (eql (mc-mean a) best) return a) *mc-actions*)))
          (when (plusp (aref ws a))
            (decf r (aref ws a))
            (when (<= r 0) (mc-press b (nth a *mc-actions*)) (return)))))
      t)))
