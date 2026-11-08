;;;; fullmc.lisp — an experiment (docs/duel/DUEL_AI_MCTS.md §7; the user, 2026-11-08: 「如果不使用輕量模型，改成真實模擬呢？」): one character's
;;;; neutral decided by flat Monte Carlo on the full sim instead of the light model. Between two sim steps (the step hook: a rollout inside a
;;;; step would re-enter it), when that character's CPU is free with no press, within 7 m, not about to awaken and the opponent not down /
;;;; airborne / waking (the in-game MCTS's own conditions), it snapshots the sim, runs K rollouts of H steps for each of the ten macro actions
;;;; (common random numbers: the same seeds for every action), scores the health swing in the teacher's unit, restores, and presses the best
;;;; action (the in-game MCTS off for him; everything else his CPU's). The rollouts see the true state (no reaction delay): an upper bound.
;;;; Env: FMC_CHAR (kenpachi), FMC_K (2), FMC_H (90), FMC_OPP (cpu: the opponent's real CPU in the rollouts, an oracle; generic: his style
;;;; CPU off there). Usage: ecl-host --norc --load tools/simgate/fullmc.lisp -- <duel.fas> <cmd>...
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defparameter *fmc-char* (intern (string-upcase (or (ext:getenv "FMC_CHAR") "kenpachi")) :keyword))
(defparameter *fmc-k* (parse-integer (or (ext:getenv "FMC_K") "2")))
(defparameter *fmc-h* (parse-integer (or (ext:getenv "FMC_H") "90")))
(defparameter *fmc-opp* (or (ext:getenv "FMC_OPP") "cpu"))
(defparameter *fmc-top* (let ((v (ext:getenv "FMC_TOP"))) (and v (parse-integer v)))
  "Env FMC_TOP=N: the hybrid: the light model's search (its difficulty's rollouts) ranks the actions from the CPU's own view, the full sim
re-scores only its top N.")
(setf *mc-on* (remove *fmc-char* '(:kenpachi :ichigo :hisagi)))   ; (his in-game MCTS off; the others as shipped)
(defvar *fmc-n* 0) (defvar *fmc-us* 0)

(defun fmc-press (e action)
  "Start ACTION as E's brain's press from between two steps (the next brain step writes it: one more frame, as the teacher's)."
  (let ((b (brain e)))
    (flet ((dash (dir to) (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to))))
      (ecase action
        (:j1 (ai-press b :quick 2)) (:sp (ai-press b :quick 2 :modded t)) (:hoho (ai-press b :step 2 :modded t :act :hoho))
        (:step-in (ai-press b :step 2 :act :dash) (dash 1 0.0)) (:step-out (ai-press b :step 2 :act :dash) (dash -1 99.0))
        (:step-side (ai-press b :step 2 :act :side-step) (setf (brain-strafe b) 1f0))
        (:guard (ai-press b :guard 21)) (:wait (ai-press b :none 21))
        (:walk-in (ai-press b :none 21 :act :dash) (dash 1 0.0)) (:walk-out (ai-press b :none 21 :act :dash) (dash -1 99.0))))))

(defun fmc-health (e) (let ((g (gauges e))) (+ (gauges-konpaku g) (* 1.5 (/ (gauges-reishi g) (float (gauges-reishi-max g)))))))

(defun fmc-top (e)
  "The light model's top *FMC-TOP* actions from E's perceived view (its brain's SNAP ring, as the in-game MCTS)."
  (let* ((f (fighter e)) (b (brain e)) (o (fighter-opp f)) (sn (make-snap)))
    (snap-take! sn o)
    (if (mc-setup e f (fighter-kit f) sn (fighter-dist f) (brain-difficulty b))
        (let ((*mc-select* (getf *mc-select-by* (brain-difficulty b) :tree)))
          (mc-seed (sim-rnd-state)) (mc-search (getf *mc-iters* (brain-difficulty b) 96))
          (let ((l (loop for a below 10 for m = (mc-mean a) when m collect (cons m (nth a *mc-actions*)))))
            (mapcar #'cdr (subseq (sort l #'> :key #'car) 0 (min *fmc-top* (length l))))))
        *mc-actions*)))

(defun fmc-decide (e)
  (let* ((f (fighter e)) (o (fighter-opp f)) (s (sim-snapshot)) (seed0 (sim-rnd-state)) (h0 (fmc-health e)) (ho0 (fmc-health o))
         (t0 (get-internal-real-time)) (best nil) (bv -1d9))
    (dolist (a (if *fmc-top* (fmc-top e) *mc-actions*))
      (unless (or (and (eq a :hoho) (not (hoho-open-p e))) (and (eq a :sp) (not (kit-core-move (fighter-kit f) :ns (mc-ptr f)))))
        (let ((sum 0d0))
          (dotimes (k *fmc-k*)
            (sim-restore s)
            (setf (sim-rnd-state) (logior 1 (logand #xFFFFFFF (+ seed0 (* 7919 (1+ k))))))
            (fmc-press e a)
            (let ((*mc-on* nil) (*cai-styles* (if (equal *fmc-opp* "generic") nil *cai-styles*)))
              (sim-rollout *fmc-h*))
            (incf sum (- (- ho0 (fmc-health o)) (- h0 (fmc-health e)))))
          (when (> sum bv) (setf bv sum best a)))))
    (sim-restore s)
    (incf *fmc-n*) (incf *fmc-us* (- (get-internal-real-time) t0))
    (when best (fmc-press e best))))

(defun fmc-hook ()
  (when (sim-snapshot-ok-p)
    (do-sides (e)
      (let* ((f (fighter e)) (b (brain e)))
        (when (and b (eq (fighter-character f) *fmc-char*) (member (fighter-state f) '(:idle :run)) (zerop (brain-press-left b))
                   (<= (fighter-dist f) 7.0) (not (gauges-awakened-ok-p e))
                   (not (member (fighter-state (fighter (fighter-opp f))) '(:air :down :wakeup :cine))))
          (fmc-decide e))))))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'fmc-hook)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 4000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(format t "fullmc ~d decisions, ~,2f ms each (native)~%" *fmc-n* (if (plusp *fmc-n*) (/ (* 1000.0 (/ *fmc-us* internal-time-units-per-second)) *fmc-n*) 0))
(finish-output)
(ext:quit 0)
