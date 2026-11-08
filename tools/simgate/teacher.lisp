;;;; teacher.lisp — the offline MCTS teacher, stage 1: how good each macro action is in the situations a real match reaches
;;;; (docs/duel/DUEL_AI_TEACHER.md §6). One simgate process plays seeded CvC gate matches like tools/simgate/run.lisp (the matchup
;;;; style CPUs on where they exist). At a decision point of a side (it is free: idle or running, its brain holds no press, the sim
;;;; may be snapshotted; at most one per side every *TEACH-GAP* ticks) it snapshots the sim, then for each macro action and each of
;;;; *TEACH-K* samples: restore, reseed the sim RNG with the sample's seed (the same seeds for every action: common random numbers),
;;;; press the action through the side's brain (the CPU's own press fields: the input path the CPU uses), let the rest play with the
;;;; side on the generic CPU and the opponent on its style CPU in even samples, the generic CPU in odd ones (the mixed opponent model,
;;;; §1), for *TEACH-H* steps (cinematics skipped), and score it. Then it restores and the match goes on untouched (the snapshot's
;;;; pollution test, §5, is what makes that true).
;;;; Output: one "teach" line per decision point: seed tick side, the features (a player's view), then per action its mean and sd.
;;;; Usage: ecl-host --norc --load tools/simgate/teacher.lisp -- <duel.fas> <cmd>...   e.g. 30000 31101 2132 (IK seed 1)
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)

(defparameter *teach-k* 16 "Samples per action.")
(defparameter *teach-h* (parse-integer (or (ext:getenv "TEACH_H") "180")) "Rollout steps after the press (3 s; env TEACH_H): at 90 a point had 1.5 of its 10 actions tie another exactly, at 180 0.74 (IK seed 1).")
(defparameter *teach-gap* 20 "Ticks between two decision points of one side.")
(defparameter *teach-reishi-w* 1.5 "A full Reishi bar's worth in Konpaku (the score's unit): ~3 Konpaku cash out of a bar by Kikon / Soul Break, halved.")

(defparameter *teach-actions*
  '(:j1 :sp :hoho :step-in :step-out :step-side :guard :wait :walk-in :walk-out)
  "The macro actions (DUEL_AI_TEACHER §3).")

(defun teach-press (e action &optional (extra 1))
  "Start ACTION as E's brain's press. EXTRA 1 from a decision point (the press is written from the next brain step on, which decrements
first), 0 from inside the brain step (the teacher CPU: written this step)."
  (let ((b (brain e)))
    (flet ((dash (dir to) (setf (brain-dash b) (f32 dir) (brain-dash-to b) (f32 to)))
           (n (k) (+ k extra)))
      (ecase action
        (:j1 (ai-press b :quick (n 1)))
        (:sp (ai-press b :quick (n 1) :modded t))                          ; the pointer's NS, a tap (no Kikon hold)
        (:hoho (ai-press b :step (n 1) :modded t :act :hoho))
        (:step-in (ai-press b :step (n 1) :act :dash) (dash 1 0.0))        ; a Step's hop toward him
        (:step-out (ai-press b :step (n 1) :act :dash) (dash -1 99.0))
        (:step-side (ai-press b :step (n 1) :act :side-step) (setf (brain-strafe b) 1f0))
        (:guard (ai-press b :guard (n 20)))
        (:wait (ai-press b :none (n 20)))                                  ; (no such button: he stands)
        (:walk-in (ai-press b :none (n 20) :act :dash) (dash 1 0.0))       ; the stick alone: a walk
        (:walk-out (ai-press b :none (n 20) :act :dash) (dash -1 99.0))))))

;;; The teacher CPU (§7): the last round's table as a policy. Free (idle or running), it looks up its situation (its character, the
;;; distance band, the opponent's state) and draws an action by a softmax over the table's values (temperature *TEACH-TAU*, value units);
;;; anything else (inside a move, stunned, an unseen situation) is the generic CPU's. Used in the rollouts only (bound *CAI-STYLES*).
(defvar *teach-table* nil "(character band ostate) -> #(n mean...) in *TEACH-ACTIONS* order (tools/teach-table.py), from env TEACH_TABLE.")
(defparameter *teach-tau* (let ((v (ext:getenv "TEACH_TAU"))) (if v (read-from-string v) 0.03)) "The policy's softmax temperature (env TEACH_TAU).")
(let ((f (ext:getenv "TEACH_TABLE"))) (when f (load f)))
(defparameter *teach-opp-style* (equal (ext:getenv "TEACH_OPP") "style")
  "Env TEACH_OPP=style: the opponent always on his matchup style CPU (the HARD table's rounds, DUEL_AI_TEACHER §8).")
(when (ext:getenv "TEACH_MC_OFF") (setf *mc-on* nil))   ; (the game's MCTS neutral off: the style / generic CPUs under it)

(defun teach-key (e)
  "E's situation key, as tools/teach-table.py buckets it: (character band ostate)."
  (let* ((f (fighter e)) (fo (fighter (fighter-opp f))) (d (round (* 10 (fighter-dist f)))) (st (fighter-state fo)))
    (list (fighter-character f) (fighter-form f)                     ; (the form since §8: Kenpachi's three play apart)
          (cond ((< d 20) :close) ((< d 40) :mid) ((< d 70) :far) (t :out))
          (if (eq st :move) (intern (format nil "MOVE-~a" (fighter-phase fo)) :keyword) st))))

(defun teach-rnd01 ()
  "Uniform [0, 1) off the sim stream's state (SIM-RND01 is a C-INLINE macro, which this interpreted file can't run): one xorshift32
step on SIM-RND-STATE, written back."
  (let ((x (sim-rnd-state)))
    (setf x (logand #xFFFFFFFF (logxor x (ash x 13))) x (logxor x (ash x -17)) x (logand #xFFFFFFFF (logxor x (ash x 5))))
    (setf (sim-rnd-state) (max 1 x))
    (/ x 4294967296d0)))

(defun teach-policy (e b f kit s d)
  "The teacher CPU as a core-CPU style function (CAI-STYLE-FN's contract: T when it decided)."
  (declare (ignore b kit s d))
  (when (member (fighter-state f) '(:idle :run))
    (let ((row (gethash (teach-key e) *teach-table*)))
      (when row
        (let* ((mx (loop for i from 1 below (length row) maximize (aref row i)))
               (ws (loop for i from 1 below (length row) collect (exp (/ (- (aref row i) mx) *teach-tau*))))
               (r (* (reduce #'+ ws) (teach-rnd01))))
          (loop for w in ws for a in *teach-actions*
                do (decf r w) (when (<= r 0) (teach-press e a 0) (return t))
                finally (teach-press e (car (last *teach-actions*)) 0) (return t)))))))

(defun teach-health (e)
  "E's health in the score's unit: Konpaku + *TEACH-REISHI-W* x the Reishi bar's fraction."
  (let ((g (gauges e))) (+ (gauges-konpaku g) (* *teach-reishi-w* (/ (gauges-reishi g) (float (gauges-reishi-max g)))))))

(defun teach-styles (self-char opp-char k)
  "The *CAI-STYLES* sample K plays with. No table (round 1): the side on the generic CPU, the opponent on his style CPU in even samples,
the generic CPU in odd ones. With a table (§7): the side on the teacher CPU, the opponent on the teacher CPU / his style CPU / the
generic CPU in turn (K mod 3)."
  (if *teach-table*
      (let ((opp-fn (if *teach-opp-style*                                   ; (env TEACH_OPP=style: the HARD table, §8)
                        (getf (getf *cai-styles* opp-char) self-char)
                        (case (mod k 3) (0 #'teach-policy) (1 (getf (getf *cai-styles* opp-char) self-char)) (t nil)))))
        (list self-char (list opp-char #'teach-policy) opp-char (and opp-fn (list self-char opp-fn))))
      (and (evenp k) (list opp-char (getf *cai-styles* opp-char)))))

(defun teach-features (e)
  "What a player sees of the situation, as a plist printed on the line."
  (let* ((f (fighter e)) (o (fighter-opp f)) (fo (fighter o)) (g (gauges e)) (go (gauges o)) (mv (fighter-move fo)))
    (list :char (fighter-character f) :ochar (fighter-character fo)
          :d (round (* 10 (fighter-dist f))) :st (fighter-state f) :ptr (fighter-ptr f) :form (fighter-form f)
          :r (gauges-reishi g) :k (gauges-konpaku g) :fs (round (gauges-fs g)) :hoho (and (hoho-open-p e) t)
          :ost (fighter-state fo) :osf (fighter-sf fo) :omv (and (eq (fighter-state fo) :move) mv (mv-name mv))
          :ocls (and (eq (fighter-state fo) :move) (fighter-cls fo)) :ophase (fighter-phase fo)
          :optr (fighter-ptr fo) :oform (fighter-form fo) :or (gauges-reishi go) :ok (gauges-konpaku go) :ofs (round (gauges-fs go))
          :ored (and (gauges-red-p go) t) :red (and (gauges-red-p g) t))))

(defvar *teach-next* (vector 0 0) "Per side, the first tick a decision point may come.")
(defvar *teach-n* 0)
(defvar *teach-rollouts* 0)

(defun teach-point (e)
  "Score every action for E here and print the line."
  (let* ((s (sim-snapshot)) (o (fighter-opp (fighter e))) (oc (kit-character (fighter-kit (fighter o))))
         (h0 (teach-health e)) (ho0 (teach-health o)) (seed0 (sim-rnd-state)) (feat (teach-features e)) (res nil))
    (dolist (a *teach-actions*)
      (let ((sum 0d0) (sq 0d0))
        (dotimes (k *teach-k*)
          (sim-restore s)
          (setf (sim-rnd-state) (logior 1 (logand #xFFFFFFF (+ seed0 (* 7919 (1+ k))))))
          (teach-press e a)
          (let ((*cai-styles* (teach-styles (kit-character (fighter-kit (fighter e))) oc k)))
            (sim-rollout *teach-h*))
          (let ((v (- (- ho0 (teach-health o)) (- h0 (teach-health e)))))
            (incf sum v) (incf sq (* v v)) (incf *teach-rollouts*)))
        (let ((m (/ sum *teach-k*))) (push (list a m (sqrt (max 0d0 (- (/ sq *teach-k*) (* m m))))) res))))
    (sim-restore s)
    (incf *teach-n*)
    (let ((*print-pretty* nil))   ; (one line)
     (format t "teach ~d ~d ~d ~s |~{ ~(~a~) ~,3f ~,3f~}~%" *match-seed* *match-tick* (fighter-side (fighter e)) feat
            (loop for (a m sd) in (setf res (nreverse res)) append (list a m sd))))
    (when *teach-lite*   ; (env TEACH_LITE=N: the in-game MCTS's light model from the same situation, seen now, N rollouts: §9's fidelity)
      (let ((sn (make-snap)) (f (fighter e)))
        (snap-take! sn o)
        (when (and *teach-dump* (mc-setup e f (fighter-kit f) sn (fighter-dist f) (brain-difficulty (brain e))))
          (let ((*print-pretty* nil))   ; (env TEACH_DUMP: the light model's start, every array as integers, for tools/simgate/litefit.lisp)
            (format *teach-dump* "~s ~s ~s ~s ~s~{ ~a~} |~{ ~s~} |~{ ~s~} |~{ ~s~} |~{ ~s~} |~{ ~s~} |~{ ~s~} |~{ ~s~} |~{ ~,4f~}~%"
                    (brain-difficulty (brain e)) (fighter-character f) (fighter-character (fighter o)) seed0 *match-tick*
                    (loop for r across *mc-slots* collect (if r (format nil "~{~a~^,~}" (coerce r 'list)) "-"))
                    (coerce (svref *mc-i* 0) 'list) (coerce (svref *mc-i* 1) 'list) (coerce *mc-g* 'list)
                    (coerce (svref *mc-vals* 0) 'list) (coerce (svref *mc-vals* 1) 'list)
                    (append (coerce *mc-legal* 'list) (coerce *mc-legal2* 'list)) (coerce *mc-w* 'list)
                    (loop for (a m) in res collect m))))
        (loop for vars in (or *teach-lite-variants* (list nil)) for k from 0   ; (env TEACH_LITE_VARIANTS: a list of binding plists,
              do (progv (loop for (v nil) on vars by #'cddr collect v) (loop for (nil x) on vars by #'cddr collect x)   ; lines lite, lite1 ...)
                   (format t "lite~[~:;~:*~d~]~{ ~,3f~}~%" k
                           (if (mc-setup e f (fighter-kit f) sn (fighter-dist f) (brain-difficulty (brain e)))
                               (let ((*mc-select* (getf *mc-select-by* (brain-difficulty (brain e)) :tree)))
                                 (mc-seed seed0) (mc-search *teach-lite*) (loop for a below 10 collect (or (mc-mean a) -9.0)))
                               (make-list 10 :initial-element -9.0)))))))))
(defparameter *teach-lite-variants* (let ((v (ext:getenv "TEACH_LITE_VARIANTS"))) (and v (read-from-string v))))
(defparameter *teach-dump* (let ((f (ext:getenv "TEACH_DUMP"))) (and f (open f :direction :output :if-exists :supersede))))
(defparameter *teach-lite* (let ((v (ext:getenv "TEACH_LITE"))) (and v (parse-integer v))))

(defun teach-hook ()
  (when (sim-snapshot-ok-p)
    (do-sides (e)
      (let* ((f (fighter e)) (side (fighter-side f)) (b (brain e)))
        (when (and b (>= *match-tick* (max 2 (svref *teach-next* side))) (member (fighter-state f) '(:idle :run))   ; (tick 0-1: no distance yet)
                   (zerop (brain-press-left b)) (sim-snapshot-ok-p))
          (setf (svref *teach-next* side) (+ *match-tick* *teach-gap*))
          (teach-point e))))))

(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(setf *step-hook* #'teach-hook)
(let ((t0 (get-internal-real-time)))
  (dolist (c (rest cl-user::*sg-args*)) (engine::simgate-cmd (parse-integer c)))
  (engine::%frame)
  (unless (loop repeat 2000000
                do (unless (engine::%frame) (ext:quit 3))
                thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
    (ext:quit 4))
  (when *teach-dump* (close *teach-dump*))
  (format t "teacher ~d decision points, ~d rollouts, ~,1f s~%" *teach-n* *teach-rollouts*
          (/ (- (get-internal-real-time) t0) internal-time-units-per-second 1.0)))
(finish-output)
(ext:quit 0)
