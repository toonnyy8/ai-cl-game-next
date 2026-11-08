;;;; fullmc.lisp — an experiment (docs/duel/DUEL_AI_MCTS.md §7; the user, 2026-11-08: 「如果不使用輕量模型，改成真實模擬呢？」): one character's
;;;; neutral decided by flat Monte Carlo on the full sim instead of the light model. Between two sim steps (the step hook: a rollout inside a
;;;; step would re-enter it), when that character's CPU is free with no press, within 7 m, not about to awaken and the opponent not down /
;;;; airborne / waking (the in-game MCTS's own conditions), it snapshots the sim, runs K rollouts of H steps for each of the ten macro actions
;;;; (common random numbers: the same seeds for every action), scores the health swing in the teacher's unit, restores, and presses the best
;;;; action (the in-game MCTS off for him; everything else his CPU's). The rollouts see the true state (no reaction delay): an upper bound.
;;;; Env: FMC_CHAR (kenpachi), FMC_K (2), FMC_H (90), FMC_OPP (cpu: the opponent's real CPU in the rollouts, an oracle; generic: his style
;;;; CPU off there). Cheaper rollouts (the user, 2026-11-08: 「1 + 2 + 4 + 6」, DUEL_AI_MCTS §11): FMC_LEAN=1 steps the rollouts without the
;;;; presentation (no slow-motion snapshot, no feedback: the events dropped, no hash log); FMC_STOP=1 ends a rollout at its first contact
;;;; and scores it as the swing so far plus the outcome table's value of that contact (contact.lisp's opening rule; the deciding CPU's
;;;; difficulty's table, the attacker's row, negated when the opponent attacks); FMC_SH=1 halves after the first pass (the better half
;;;; gets K more rollouts); FMC_SLICE=R runs R rollouts a step from the decision's snapshot (the live state snapshotted and put back
;;;; around them) and presses when they are done, if the CPU is still free: the cost spread over steps, the decision that much later.
;;;; Usage: ecl-host --norc --load tools/simgate/fullmc.lisp -- <duel.fas> <cmd>...
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defparameter *fmc-char* (intern (string-upcase (or (ext:getenv "FMC_CHAR") "kenpachi")) :keyword))
(defparameter *fmc-k* (parse-integer (or (ext:getenv "FMC_K") "2")))
(defparameter *fmc-h* (parse-integer (or (ext:getenv "FMC_H") "90")))
(defparameter *fmc-opp* (or (ext:getenv "FMC_OPP") "cpu"))
(defparameter *fmc-top* (let ((v (ext:getenv "FMC_TOP"))) (and v (plusp (length v)) (parse-integer v)))
  "Env FMC_TOP=N: the hybrid: the light model's search (its difficulty's rollouts) ranks the actions from the CPU's own view, the full sim
re-scores only its top N.")
(setf *mc-on* (remove *fmc-char* '(:kenpachi :ichigo :hisagi)))   ; (his in-game MCTS off; the others as shipped)
(defparameter *fmc-lite* (let ((v (ext:getenv "FMC_LITE"))) (and v (plusp (length v)) (parse-integer v)))
  "Env FMC_LITE=N: the hybrid's light search with N rollouts (default: its difficulty's).")
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
          (mc-seed (sim-rnd-state)) (mc-search (or *fmc-lite* (getf *mc-iters* (brain-difficulty b) 96)))
          (let ((l (loop for a below 10 for m = (mc-mean a) when m collect (cons m (nth a *mc-actions*)))))
            (mapcar #'cdr (subseq (sort l #'> :key #'car) 0 (min *fmc-top* (length l))))))
        *mc-actions*)))

(defparameter *fmc-lean* (equal (ext:getenv "FMC_LEAN") "1"))
(defparameter *fmc-stop* (equal (ext:getenv "FMC_STOP") "1"))
(defparameter *fmc-sh* (equal (ext:getenv "FMC_SH") "1"))
(defparameter *fmc-slice* (parse-integer (or (ext:getenv "FMC_SLICE") "0")))
(defvar *fmc-rolls* 0) (defvar *fmc-steps* 0) (defvar *fmc-contacts* 0) (defvar *fmc-slice-max* 0) (defvar *fmc-slices* 0)
(defvar *fmc-t-top* 0) (defvar *fmc-t-snap* 0) (defvar *fmc-t-roll* 0)
(defmacro fmc-timed (place form) `(let ((t0 (get-internal-real-time))) (prog1 ,form (incf ,place (- (get-internal-real-time) t0)))))
(defvar *fmc-late* 0 "Sliced decisions dropped: the CPU was no longer free when they were done.")

(defun fmc-step ()
  "SIM-STEP without the presentation: no slow-motion snapshot, no feedback (the events dropped: *EVENTS* is no snapshot root), no hash log."
  (incf *match-tick*)
  (cond (*cine* (pilot-read) (cine-step))
        ((not (time-step)) (pilot-read))
        (t (setf *slow-acc* (+ *slow-acc* (slowmo-scale nil)))
           (if (>= *slow-acc* 1.0)
               (progn (decf *slow-acc* 1.0) (pilot-system) (sim-systems))
               (pilot-read))))
  (god-update) (probe-update) (take-events))

(defun fmc-reel-p (st) (member st '(:stun :air :down :wakeup :guard-hit :cine)))

(defun fmc-contact-value (e a d dif)
  "The outcome table's value, for E, of the contact attacker A just opened on D (contact.lisp's classes)."
  (let* ((fa (fighter a)) (fd (fighter d)) (mv (and (eq (fighter-state fa) :move) (fighter-move fa)))
         (cls (cond ((and (eq (fighter-state fa) :hoho) (fighter-perfect fa)) :counter) (mv (kit-class (fighter-kit fa) mv))))
         (row (mc-outcomes-of (fighter-character fa) (fighter-form fa) dif))
         (v (cond ((eq (fighter-state fd) :guard-hit) (nth 6 row))
                  ((eq cls :counter) (nth 5 row))
                  ((eq cls :na) (nth 0 row))
                  ((eq cls :ns) (nth (max 1 (min 3 (fighter-ptr fa))) row))
                  ((member cls '(:as :sa)) (nth 4 row))
                  (t 0.0))))
    (if (eq a e) v (- v))))

(defun fmc-roll (e o h dif)
  "One rollout of up to H steps from the state now; E's score: the health swing, and at a first contact (FMC_STOP) the table's value."
  (let ((*log-mute* t) (*pacing-log* nil) (*combat-log* nil) (*gate-log* nil) (*step-hook* nil) (*skip-cines* t) (*mc-on* nil)
        (*cai-styles* (if (equal *fmc-opp* "generic") nil *cai-styles*))
        (h0 (fmc-health e)) (ho0 (fmc-health o)) (bonus 0.0)
        (pe (fighter-state (fighter e))) (po (fighter-state (fighter o))))
    (loop for i below h while (and (eq *flow* :battle) (not *cine*))
          do (if *fmc-lean* (fmc-step) (sim-step))
             (incf *fmc-steps*)
             (when *fmc-stop*
               (let ((se (fighter-state (fighter e))) (so (fighter-state (fighter o))))
                 (flet ((opened (d st prev) (and (member st '(:stun :air :down :guard-hit)) (not (fmc-reel-p prev)) d)))
                   (let ((d (or (opened o so po) (opened e se pe))))
                     (when d
                       (incf *fmc-contacts*)
                       (setf bonus (fmc-contact-value e (fighter-opp (fighter d)) d dif))
                       (return))))
                 (setf pe se po so))))
    (incf *fmc-rolls*)
    (+ bonus (- (- ho0 (fmc-health o)) (- h0 (fmc-health e))))))

(defun fmc-candidates (e)
  (let ((f (fighter e)))
    (remove-if (lambda (a) (or (eq a :guard)                                 ; (no guard for a core kit: the same as :wait)
                               (and (eq a :hoho) (not (hoho-open-p e))) (and (eq a :sp) (not (kit-core-move (fighter-kit f) :ns (mc-ptr f))))))
               (if *fmc-top* (fmc-timed *fmc-t-top* (fmc-top e)) *mc-actions*))))

(defun fmc-tasks (actions k0 k1)
  "Rollout tasks (action . seed index) for seeds K0 below K1 of each action."
  (loop for a in actions nconc (loop for k from k0 below k1 collect (cons a k))))

(defstruct fjob e s seed0 dif tasks sums (pass 0) t0)

(defun fmc-run-task (j task)
  (let ((e (fjob-e j)))
    (sim-restore (fjob-s j))
    (setf (sim-rnd-state) (logior 1 (logand #xFFFFFFF (+ (fjob-seed0 j) (* 7919 (1+ (cdr task)))))))
    (fmc-press e (car task))
    (incf (getf (fjob-sums j) (car task) 0.0) (fmc-timed *fmc-t-roll* (fmc-roll e (fighter-opp (fighter e)) *fmc-h* (fjob-dif j))))))

(defun fmc-next-pass (j)
  "After a pass: halve once (FMC_SH) or finish. Returns T while tasks remain."
  (when (and *fmc-sh* (zerop (fjob-pass j)))
    (let* ((l (loop for (a v) on (fjob-sums j) by #'cddr collect (cons a v)))
           (keep (subseq (sort l #'> :key #'cdr) 0 (max 1 (floor (1+ (length l)) 2)))))
      (setf (fjob-pass j) 1)
      (when (> (length l) 1)
        (setf (fjob-sums j) (loop for (a . v) in keep nconc (list a v))
              (fjob-tasks j) (fmc-tasks (mapcar #'car keep) *fmc-k* (* 2 *fmc-k*))))))
  (and (fjob-tasks j) t))

(defun fmc-best (j)
  (loop with b = nil with bv = nil for (a v) on (fjob-sums j) by #'cddr
        when (or (null bv) (> v bv)) do (setf b a bv v) finally (return b)))

(defun fmc-start (e)
  (let ((t0 (get-internal-real-time)) (acts (fmc-candidates e)))
    (make-fjob :e e :s (fmc-timed *fmc-t-snap* (sim-snapshot)) :seed0 (sim-rnd-state) :dif (brain-difficulty (brain e)) :t0 t0
               :tasks (fmc-tasks acts 0 *fmc-k*))))

(defvar *fmc-job* nil "A sliced decision in progress (FMC_SLICE).")

(defun fmc-decide (e)
  "All at once: the decision's rollouts, then the best action pressed."
  (let ((j (fmc-start e)))
    (loop do (loop while (fjob-tasks j) do (fmc-run-task j (pop (fjob-tasks j)))) while (fmc-next-pass j))
    (sim-restore (fjob-s j))
    (incf *fmc-n*) (incf *fmc-us* (- (get-internal-real-time) (fjob-t0 j)))
    (let ((best (fmc-best j))) (when best (fmc-press e best)))))

(defun fmc-free-p (e)
  (let* ((f (fighter e)) (b (brain e)))
    (and (member (fighter-state f) '(:idle :run)) (zerop (brain-press-left b)))))

(defun fmc-slice ()
  "This step's share of the sliced decision: R rollouts from its snapshot, the live state saved and put back around them."
  (let* ((j *fmc-job*) (t0 (get-internal-real-time)) (live (sim-snapshot)))
    (loop repeat *fmc-slice* while (or (fjob-tasks j) (fmc-next-pass j)) do (fmc-run-task j (pop (fjob-tasks j))))
    (sim-restore live)
    (let ((dt (- (get-internal-real-time) t0)))
      (incf *fmc-us* dt) (incf *fmc-slices*) (setf *fmc-slice-max* (max *fmc-slice-max* dt)))
    (unless (or (fjob-tasks j) (fmc-next-pass j))
      (setf *fmc-job* nil) (incf *fmc-n*)
      (let ((e (fjob-e j)) (best (fmc-best j)))
        (if (and best (fmc-free-p e)) (fmc-press e best) (incf *fmc-late*))))))

(defun fmc-hook ()
  (when (sim-snapshot-ok-p)
    (if *fmc-job*
        (fmc-slice)
        (do-sides (e)
          (let* ((f (fighter e)) (b (brain e)))
            (when (and b (eq (fighter-character f) *fmc-char*) (fmc-free-p e)
                       (<= (fighter-dist f) 7.0) (not (gauges-awakened-ok-p e))
                       (not (member (fighter-state (fighter (fighter-opp f))) '(:air :down :wakeup :cine))))
              (if (plusp *fmc-slice*)
                  (let ((t0 (get-internal-real-time))) (setf *fmc-job* (fmc-start e)) (incf *fmc-us* (- (get-internal-real-time) t0)))
                  (fmc-decide e)))))))
  (unless (battle-p) (setf *fmc-job* nil)))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'fmc-hook)
(dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
(engine::%frame)
(unless (loop repeat 4000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(flet ((ms (x) (/ (* 1000.0 x) internal-time-units-per-second)))
  (format t "fullmc ~d decisions, ~,2f ms each (native), ~,1f rollouts each, ~,1f steps a rollout, ~,0f % stopped at a contact~@[, slices: ~a~]~%"
          *fmc-n* (if (plusp *fmc-n*) (/ (ms *fmc-us*) *fmc-n*) 0) (/ *fmc-rolls* (max 1 *fmc-n*)) (/ *fmc-steps* (max 1 *fmc-rolls*))
          (/ (* 100.0 *fmc-contacts*) (max 1 *fmc-rolls*))
          (and (plusp *fmc-slice*) (format nil "~,2f ms mean ~,2f ms max, ~d late" (/ (ms *fmc-us*) (max 1 *fmc-slices*)) (ms *fmc-slice-max*) *fmc-late*)))
  (format t "fullmc per decision: light ~,3f ms, snapshot ~,3f ms, rollouts ~,3f ms (~,1f us a step)~%" (/ (ms *fmc-t-top*) (max 1 *fmc-n*))
          (/ (ms *fmc-t-snap*) (max 1 *fmc-n*)) (/ (ms *fmc-t-roll*) (max 1 *fmc-n*)) (/ (* 1000 (ms *fmc-t-roll*)) (max 1 *fmc-steps*))))
(finish-output)
(ext:quit 0)
