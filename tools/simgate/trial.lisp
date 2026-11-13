;;;; trial.lisp: the combo trials (tools/combo-trial.py; the CPU work's step 2, skill duel-character-cpu "Order"). One
;;;; native process: load the native SOUL DUEL (tools/simgate/build.lisp), start it as the page would, then play each
;;;; trial of a trial file: P1 the trial player (habit :trial, scripted.lisp TRIAL-STEP) against a dummy P2 that stands or
;;;; holds a guard, from a set distance and resources, for a set number of 1/60 s frames. Output: the combat log between
;;;; "trial begin" and a "trial end" summary line per trial (combo-trial.py reads them).
;;;; Usage: ecl-host --norc --load tools/simgate/trial.lisp -- <duel.fas> <trials.lisp>
;;;; A trial: (:name S :p1 C :form F :p2 C :p2-form F :dist M :layers N :chill N (ignored since 2026-11-12) :dummy :stand|:guard :frames N
;;;;           :script ((button frames &key modded wait on) ...) :bars N (ignored since 2026-11-13) :fs N :meter X): the presses in order (scripted.lisp TRIAL-STEP)
;;;; Optional (2026-11-06, the KI matchup search): :ptr N P1's SP pointer, :p2-ptr N his; :awaken X P1's awakening gauge;
;;;; :p2-press ((frame button frames &optional modded stick) ...) P2 presses BUTTON for FRAMES steps from trial frame FRAME (the opponent
;;;; acting, through the real input path). A core kit's P1 (its BRAIN-STEP goes to CORE-BRAIN-STEP, which never reads the :trial
;;;; habit) is driven here: its brain off, TRIAL-STEP called once per sim frame (the vpad is still written from the brain's press).
;;;; :burst M (2026-11-13) P1 begins in burst mode M (:white / :blue / :orange).
;;;; :p2-fs N P2's flash-step gauge (default full).
;;;; :p2-reishi X his Reishi (red under 30 %). The end line also gives his Konpaku change.
;;;; :p2-at ((sim-frame :j|:sp [frames]) ...): P2 presses J / SP (held FRAMES, default 1) on that SIM frame of the trial (from 0; hitstop /
;;;; slow-motion frames don't count; Kenpachi's file).
;;;; :p2-start ((sim-frame move-name) ...) (DUEL_SP S5, 2026-11-13): P2 starts MOVE-NAME (a move of his kit) through CORE-START! on that SIM
;;;; frame (a written debug drive: an AS or SA where no press of his could reach one, e.g. at a wave's range; he pays like a player).
;;;; :p2-cpu DIF (DUEL_SP S7, 2026-11-13): P2's CPU plays (CORE-BRAIN-STEP at difficulty DIF, no strategy: the generic CPU or the
;;;; pairing's matchup style), e.g. after a :p2-start; :seed N reseeds the sim's random stream first (one seed, the same rolls in two trials).
;;;; :p1-cmd (N ...) debug commands (DEBUG-COMMAND) run after the setup (KESSA's two NS3 clones: 74904). Every trial resets the match timer and both sides' SUBLIMATION / DRIVE / awakening
;;;; gauges (they carried over). The end line's "more": P1's own Reishi change, both Konpaku changes (P1/P2), P1's form, pointer, kit meter.
(load (merge-pathnames "prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; tools/simgate/prelude.lisp: *SG-ARGS*, the fas, CL-USER::SG-INIT, CL-USER::SG-QUEUE
(in-package :duel)
(cl-user::sg-init)
(engine::%frame)
(setf *skip-cines* t)   ; (a Kikon's cinematic is skipped: the next trial starts on a plain stage)

(defun trial-free-p (e)
  "Can E act (neutral, guarding or running)?"
  (member (fighter-state (fighter e)) '(:idle :guard :run)))

(defvar *trial-ticks* (list -1 -1) "The vpad ticks of P1 and P2 last seen by TRIAL-CORE-DRIVE / the :p2-press count.")
(defun trial-sim-frame-p (e k)
  "Has a sim frame run (its brain stepped: the vpad clock moved) since the last call for side K (0 / 1)? Hitstop, slow motion and
cinematic steps run none, so a scripted press keeps the brain's own timing (BRAIN-STEP runs only on a sim frame)."
  (let ((tk (vpad-tick (pilot-vpad (pilot e)))))
    (unless (= tk (nth k *trial-ticks*)) (setf (nth k *trial-ticks*) tk))))

(defun trial-core-drive (e b)
  "A core kit's trial player before a frame (BRAIN-STEP's :trial branch is never reached for a core kit): TRIAL-STEP once per sim
frame while it may act (BRAIN-STEP's test), the press's stick carried as a :dash act (CORE-BRAIN-STEP zeroes the stick, then sets it
from that act)."
  (let ((f (fighter e)) (vp (pilot-vpad (pilot e))))
    (when (and (trial-sim-frame-p e 0) (zerop (fighter-lock f)) (not (eq (fighter-state f) :cine)))
      (trial-step e b)
      (let ((st (vpad-sy vp)))   ; ponytail: only the forward / back stick (y) survives, no side stick
        (unless (zerop st)
          (when (zerop (brain-press-left b)) (setf (brain-press b) :walk (brain-press-left b) 1))
          (setf (brain-act b) :dash (brain-dash b) st (brain-dash-to b) (if (plusp st) -1f0 99f0)))))))

(defun trial-run (tr)
  (destructuring-bind (&key name (p1 :ichigo) (form :base) (p2 :kenpachi) (p2-form :base) (dist 2.0) (layers 0) (chill 0)
                         (dummy :stand) (frames 150) script (bars 0) (fs 100) (meter 0.0)
                         ptr p2-ptr awaken p2-press p2-reishi p2-at burst p2-fs p2-start p1-cmd p2-cpu seed) tr
    (declare (ignore layers chill bars))   ; (Rukia's layers, gone 2026-11-12, and the Reiatsu bars, 2026-11-13: a trial file may still name them)
    (ensure-battle p1 p2 :cpu t)
    (force-form *p1* form) (force-form *p2* p2-form)
    (dolist (e (list *p1* *p2*)) (setf (gauges-awakened (gauges e)) (kit-awakening (kit-of e))))   ; (an earlier trial's awakened form stays set)
    (place *p1* *p2* dist)
    (clear-hazards)                                     ; (no wave or clone carried from the last trial)
    (when *cine* (skip-cine))
    (setf *timer* 36000)                                ; (no time-up mid-file: one match carries every trial)
    (dolist (e (list *p1* *p2*)) (burst-end! e) (full-gauges! e 0f0) (setf (gauges-konpaku (gauges e)) *konpaku-max*)
      (setf (fighter-xch (fighter e)) -1 (fighter-xch-done (fighter e)) nil)   ; (no exchange carried from the last trial: DUEL_SP §6)
      (let ((g (gauges e)))                             ; (SUBLIMATION / DRIVE scale the damage: none carried from the last trial)
        (setf (gauges-sub g) 0f0 (gauges-sub-s g) 0f0 (gauges-drive g) 0f0 (gauges-awaken g) 0f0)))
    (setf (gauges-meter (gauges *p1*)) (f32 meter))   ; (her kit meter: Rukia's cold, which picks her band)
    (setf (gauges-fs (gauges *p1*)) (f32 fs))
    (when p2-fs (setf (gauges-fs (gauges *p2*)) (f32 p2-fs)))
    (when burst (setf (gauges-burst (gauges *p1*)) burst (gauges-burn (gauges *p1*)) 300f0))   ; (:burst :white|:blue|:orange: P1 starts the trial in that burst, DUEL_SP S3's "no gain")
    (when ptr (setf (fighter-ptr (fighter *p1*)) ptr))
    (when p2-ptr (setf (fighter-ptr (fighter *p2*)) p2-ptr))
    (when awaken (setf (gauges-awaken (gauges *p1*)) (f32 awaken)))
    (when p2-reishi (setf (gauges-reishi (gauges *p2*)) (f32 p2-reishi)))   ; (under 30 %: red, his Kikon can't be cancelled)
    (let ((f2 (fighter *p2*)) (b1 (brain *p1*)) (b2 (brain *p2*)))
      (setf (brain-off b1) nil (brain-habit b1) :trial (brain-press-left b1) 0
            (brain-off b2) (not p2-cpu) (brain-press-left b2) 0)
      (when p2-cpu (setf (brain-difficulty b2) p2-cpu (brain-strat b2) nil (brain-decided b2) -1)))   ; (:p2-cpu: his CPU plays, S7)
    (when seed (setf (sim-rnd-state) seed))
    (let ((f2 (fighter *p2*)) (b2 (brain *p2*)))
      (when (eq dummy :guard)
        (setf (fighter-state f2) :guard (fighter-guard-t f2) 30 (brain-press b2) :guard (brain-press-left b2) 9999)))
    (when (kit-core (kit-of *p1*)) (setf (brain-off (brain *p1*)) t))   ; (driven by TRIAL-CORE-DRIVE)
    (dolist (c p1-cmd) (debug-command c))
    (trial-reset script) (setf *combat-log* t)
    (log-msg "trial begin ~a" name)
    (let* ((g1 (gauges *p1*)) (g2 (gauges *p2*)) (r0 (gauges-reishi g2)) (fs0 (gauges-fs g1))
           (k0 (gauges-konpaku g2)) (core1 (kit-core (kit-of *p1*))) (b1 (brain *p1*)) (b2 (brain *p2*))
           (prev r0) (hits 0) (cmax 0) (gaps nil) (run2 0) (last-hit nil) (free1 nil) (free2 nil)
           (s0 (gauges-reishi g1)) (k1 (gauges-konpaku g1)) (vp2 (pilot-vpad (pilot *p2*))) (tick2 -1) (simf 0))
      (dotimes (i frames)
        (when core1 (trial-core-drive *p1* b1))
        (dolist (p p2-press)
          (destructuring-bind (at btn n &optional md st) p
            (when (= i at)
              (ai-press b2 btn n :modded md :act (if st :dash :hold))
              (when st (setf (brain-dash b2) (f32 st) (brain-dash-to b2) (if (plusp st) -1f0 99f0))))))
        (when (and (or p2-at p2-start) (/= tick2 (vpad-tick vp2)))     ; (:p2-at / :p2-start: once per sim frame, by his vpad clock)
          (setf tick2 (vpad-tick vp2))
          (when (and (not p2-cpu) (plusp (brain-press-left b2))) (decf (brain-press-left b2)))   ; (a live CPU counts its own)
          (dolist (a p2-at)
            (when (= (first a) simf) (ai-press b2 :quick (or (third a) 1) :modded (eq (second a) :sp) :act :hold)))
          (dolist (a p2-start)
            (when (= (first a) simf) (core-start! *p2* (gethash (second a) (kit-moves (kit-of *p2*))))))
          (incf simf))
        (engine::%frame)
        (when (and p2-press (trial-sim-frame-p *p2* 1) (plusp (brain-press-left b2))) (decf (brain-press-left b2)))   ; (his brain is off)
        (let ((r (gauges-reishi g2)) (c (fighter-combo-hits (fighter *p2*))))
          (when (< r prev) (incf hits) (setf last-hit i free1 nil free2 nil) (push run2 gaps))   ; his free frames before it
          (setf run2 (if (trial-free-p *p2*) (1+ run2) 0))
          (setf cmax (max cmax c) prev r)
          (when (and (eq (fighter-state (fighter *p2*)) :guard-hit) (not (eql last-hit i)))   ; a blocked hit: from here
            (setf last-hit i free1 nil free2 nil))
          (when last-hit
            (if (trial-free-p *p1*) (unless free1 (setf free1 i)) (setf free1 nil))
            (if (trial-free-p *p2*) (unless free2 (setf free2 i)) (setf free2 nil)))))
      (let* ((p (pos-of *p1*)) (q (pos-of *p2*)) (f2 (fighter *p2*)))
        (log-msg "trial end ~a | dmg ~d | hits ~d | combo ~d | gaps ~{~d~^ ~} | last hit f~a | free P1 f~a P2 f~a | adv ~a | dist ~,2f | fs ~@d | layers ~d chill ~d | p1 ~(~a~) p2 ~(~a~) | konpaku ~@d | more self ~@d konpaku ~@d/~@d form ~(~a~) ptr ~d meter ~d"
                 name (round (- r0 (gauges-reishi g2))) hits cmax (rest (reverse gaps)) last-hit free1 free2
                 (if (and free1 free2) (- free2 free1) "?")
                 (sqrt (+ (expt (- (aref q 0) (aref p 0)) 2) (expt (- (aref q 2) (aref p 2)) 2)))
                 (round (- (gauges-fs g1) fs0)) 0 0   ; (layers / chill: Rukia's, 0 since 2026-11-12)
                 (fighter-state (fighter *p1*)) (fighter-state f2) (- (gauges-konpaku g2) k0)
                 (round (- (gauges-reishi g1) s0)) (- (gauges-konpaku g1) k1) (- (gauges-konpaku g2) k0)
                 (fighter-form (fighter *p1*)) (fighter-ptr (fighter *p1*)) (round (gauges-meter g1)))))
    (trial-reset nil) (setf (brain-habit (brain *p1*)) nil (brain-off (brain *p1*)) t)))

(with-open-file (in (second cl-user::*sg-args*))
  (let ((*package* (find-package :duel)))
    (loop for tr = (read in nil in) until (eq tr in) do (trial-run tr))))
(finish-output)
(ext:quit 0)
