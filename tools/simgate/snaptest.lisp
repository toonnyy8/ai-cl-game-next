;;;; The snapshot's pollution test (docs/duel/DUEL_AI_TEACHER.md §5): one simgate process plays seeded gate matches like
;;;; tools/simgate/run.lisp; in POLLUTE mode a rollout runs every ~40 ticks of a battle (snapshot, the sim RNG reseeded so the CPUs
;;;; play differently, 60-120 steps, restore). The output must equal the STRAIGHT run's line for line (the rollout count and timing
;;;; line apart, printed last as "snaptest ...").
;;;; The `duel mcfull` line (the in-game full sim's cost, DUEL_AI_MCTS §12) differs in its milliseconds: compare the rest.
;;;; Usage: ecl-host --norc --load tools/simgate/snaptest.lisp -- <duel.fas> straight|pollute <cmd>...   e.g. 30000 31104 2132
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)
(defvar *st-mode* (second cl-user::*sg-args*))
(defvar *st-n* 0)
(defvar *st-steps* 0)
(defvar *st-objs* 0)
(defvar *st-us* 0)
(cl-user::sg-init)
(defvar *st-digest* (and (fourth cl-user::*sg-args*) (string= (third cl-user::*sg-args*) "digest")
                          (open (fourth cl-user::*sg-args*) :direction :output :if-exists :supersede)))
(when *st-digest* (setf cl-user::*sg-args* (append (subseq cl-user::*sg-args* 0 2) (nthcdr 4 cl-user::*sg-args*))))
(defun st-digest ()   ; (with "digest FILE" after the mode: every battle tick's full hash line, to find the first divergence)
  (when (and *st-digest* (battle-p))
    (format *st-digest* "~d ~d ~a~%" *match-seed* *match-tick* (state-hash-line))))
(setf *step-hook* (lambda () (st-digest)))
(when (string= *st-mode* "pollute")
  (setf *step-hook*
        (lambda ()
          (st-digest)
          (when (and (sim-snapshot-ok-p) (zerop (mod *match-tick* 40)))
            (let* ((t0 (get-internal-real-time)) (s (sim-snapshot)) (t1 (get-internal-real-time)))
              (setf (sim-rnd-state) (logior 1 (logxor (sim-rnd-state) #x5BD1E995)))   ; another stream: the CPUs diverge
              (let ((tk *match-tick*) (n (sim-rollout (+ 60 (mod (floor *match-tick* 40) 61)))))
                (incf *st-steps* n)
                (when *st-digest*   ; ("R" lines: where the rollout ended, to check it played differently from the match)
                  (format *st-digest* "R ~d ~d ~a~%" *match-seed* *match-tick* (if (= *match-tick* (+ tk n)) (state-hash-line) "-"))))
              (let ((t2 (get-internal-real-time)))
                (sim-restore s)
                (incf *st-us* (+ (- t1 t0) (- (get-internal-real-time) t2))))
              (incf *st-n*) (incf *st-objs* (simsnap-count s)))))))
(cl-user::sg-queue (cddr cl-user::*sg-args*))
(engine::%frame)
(unless (loop repeat 2000000
              do (unless (engine::%frame) (ext:quit 3))
              thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
  (ext:quit 4))
(when (plusp *st-n*)
  (format t "snaptest ~d rollouts, ~d steps, ~,1f objects a snapshot, snapshot+restore ~,1f us each~%" *st-n* *st-steps*
          (/ *st-objs* *st-n*) (/ (* 1e6 (/ *st-us* internal-time-units-per-second)) *st-n*)))
(when *st-digest* (close *st-digest*))
(finish-output)
(ext:quit 0)
