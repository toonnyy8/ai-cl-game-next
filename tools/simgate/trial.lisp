;;;; trial.lisp: the combo trials (tools/combo-trial.py; the CPU work's step 2, skill duel-character-cpu "Order"). One
;;;; native process: load the native SOUL DUEL (tools/simgate/build.lisp), start it as the page would, then play each
;;;; trial of a trial file: P1 the trial player (habit :trial, scripted.lisp TRIAL-STEP) against a dummy P2 that stands or
;;;; holds a guard, from a set distance and resources, for a set number of 1/60 s frames. Output: the combat log between
;;;; "trial begin" and a "trial end" summary line per trial (combo-trial.py reads them).
;;;; Usage: ecl-host --norc --load tools/simgate/trial.lisp -- <duel.fas> <trials.lisp>
;;;; A trial: (:name S :p1 C :form F :p2 C :p2-form F :dist M :layers N :chill N :dummy :stand|:guard :frames N
;;;;           :script ((button frames &key modded wait on) ...) :bars N :fs N :meter X): the presses in order (scripted.lisp TRIAL-STEP)
;;;; A core kit's P1 (a :core: its CPU is CORE-BRAIN-STEP, which never reaches the :trial habit): its brain stays off and TRIAL-STEP is
;;;; called here before each sim frame (a frame that only froze, hitstop / slow motion, does not count; a :walk / :stick press is
;;;; written as the brain's :dash act, the stick its BRAIN-DASH). Optional keys (absent: as before): :ptr N P1's SP pointer, :p2-ptr N P2's, :p2-at ((sim-frame :j|:sp [frames]) ...) P2
;;;; presses J / SP (held FRAMES, default 1) on that sim frame of the trial (counted from 0), through his vpad. The end line's "more": P1's own Reishi change, both Konpaku changes (P1/P2),
;;;; P1's form, pointer and kit meter at the end.
(defparameter cl-user::*sg-args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*sg-args*) :verbose nil)
(in-package :duel)
(loop for r = (engine::%init-step) until (eql r 0) when (eql r 2) do (ext:quit 2))
(engine::%frame)
(setf *skip-cines* t)   ; (a Kikon's cinematic is skipped: the next trial starts on a plain stage)

(defun trial-free-p (e)
  "Can E act (neutral, guarding or running)?"
  (member (fighter-state (fighter e)) '(:idle :guard :run)))

(defun trial-run (tr)
  (destructuring-bind (&key name (p1 :rukia) (form :base) (p2 :kenpachi) (p2-form :base) (dist 2.0) (layers 0) (chill 0)
                         (dummy :stand) (frames 150) script (bars 3) (fs 100) (meter 0.0) ptr p2-ptr p2-at) tr
    (ensure-battle p1 p2 :cpu t)
    (force-form *p1* form) (force-form *p2* p2-form)
    (when ptr (setf (fighter-ptr (fighter *p1*)) ptr)) (when p2-ptr (setf (fighter-ptr (fighter *p2*)) p2-ptr))
    (place *p1* *p2* dist)
    (setf *timer* 36000)                                ; (no time-up mid-file: one match carries every trial)
    (when *cine* (skip-cine))
    (dolist (e (list *p1* *p2*)) (burst-end! e) (full-gauges! e 0f0) (setf (gauges-konpaku (gauges e)) *konpaku-max*)
      (let ((g (gauges e)))                             ; (SUBLIMATION / DRIVE scale the damage: none carried from the last trial)
        (setf (gauges-sub g) 0f0 (gauges-sub-s g) 0f0 (gauges-drive g) 0f0 (gauges-awaken g) 0f0
              (gauges-awakened g) (and (kit-awakening (kit-of e)) t))))
    (setf (gauges-meter (gauges *p1*)) (f32 meter))   ; (her kit meter: Rukia's cold, which picks her band)
    (setf (gauges-reiatsu (gauges *p1*)) (f32 (* bars *reiatsu-bar*)) (gauges-fs (gauges *p1*)) (f32 fs))
    (let ((f2 (fighter *p2*)) (b1 (brain *p1*)) (b2 (brain *p2*)))
      (setf (fighter-layers f2) layers (fighter-chill f2) chill (fighter-thaw f2) 0
            (brain-off b1) nil (brain-habit b1) :trial (brain-press-left b1) 0
            (brain-off b2) t (brain-press-left b2) 0)
      (when (eq dummy :guard)
        (setf (fighter-state f2) :guard (fighter-guard-t f2) 30 (brain-press b2) :guard (brain-press-left b2) 9999)))
    (trial-reset script) (setf *combat-log* t)
    (log-msg "trial begin ~a" name)
    (let* ((g1 (gauges *p1*)) (g2 (gauges *p2*)) (r0 (gauges-reishi g2)) (ra0 (gauges-reiatsu g1)) (fs0 (gauges-fs g1))
           (prev r0) (hits 0) (cmax 0) (gaps nil) (run2 0) (last-hit nil) (free1 nil) (free2 nil)
           (core (kit-core (fighter-kit (fighter *p1*)))) (vp1 (pilot-vpad (pilot *p1*))) (tick -1) (simf 0)
           (s0 (gauges-reishi g1)) (k1 (gauges-konpaku g1)) (k2 (gauges-konpaku g2)))
      (when core (setf (brain-off (brain *p1*)) t))                ; (its press fields still reach the vpad: CORE-BRAIN-STEP's last loop)
      (dotimes (i frames)
        (when (and core (/= tick (vpad-tick vp1)))       ; the last frame was a sim frame (or this is the first): a press step
          (setf tick (vpad-tick vp1))
          (let ((b2 (brain *p2*)))                       ; P2's presses: his vpad through his (off) brain's press fields
            (when (plusp (brain-press-left b2)) (decf (brain-press-left b2)))
            (dolist (a p2-at)
              (when (= (first a) simf) (ai-press b2 :quick (or (third a) 1) :modded (eq (second a) :sp) :act :hold))))
          (incf simf)
          (let ((st0 *trial-state*) (b1 (brain *p1*)))
            (trial-step *p1* b1)
            (let* ((cur (sixth *trial-state*)) (stick (and cur (getf (cddr cur) :stick (and (eq (first cur) :walk) 1.0)))))
              (when (and stick (or (plusp (second st0)) (/= (first st0) (first *trial-state*))))   ; (pressed this step)
                (when (eq (first cur) :walk) (setf (brain-press b1) :walk (brain-press-left b1) 1))   ; (no button: the stick only)
                (setf (brain-act b1) :dash (brain-dash b1) (f32 stick) (brain-dash-to b1) (if (> stick 0) -100f0 100f0))))))
        (engine::%frame)
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
        (log-msg "trial end ~a | dmg ~d | hits ~d | combo ~d | gaps ~{~d~^ ~} | last hit f~a | free P1 f~a P2 f~a | adv ~a | dist ~,2f | reiatsu ~@d | fs ~@d | layers ~d chill ~d | p1 ~(~a~) p2 ~(~a~) | more self ~@d konpaku ~@d/~@d form ~(~a~) ptr ~d meter ~d"
                 name (round (- r0 (gauges-reishi g2))) hits cmax (rest (reverse gaps)) last-hit free1 free2
                 (if (and free1 free2) (- free2 free1) "?")
                 (sqrt (+ (expt (- (aref q 0) (aref p 0)) 2) (expt (- (aref q 2) (aref p 2)) 2)))
                 (round (- (gauges-reiatsu g1) ra0)) (round (- (gauges-fs g1) fs0)) (fighter-layers f2) (fighter-chill f2)
                 (fighter-state (fighter *p1*)) (fighter-state f2)
                 (round (- (gauges-reishi g1) s0)) (- (gauges-konpaku g1) k1) (- (gauges-konpaku g2) k2)
                 (fighter-form (fighter *p1*)) (fighter-ptr (fighter *p1*)) (round (gauges-meter g1)))))
    (trial-reset nil) (setf (brain-habit (brain *p1*)) nil (brain-off (brain *p1*)) t)))

(with-open-file (in (second cl-user::*sg-args*))
  (let ((*package* (find-package :duel)))
    (loop for tr = (read in nil in) until (eq tr in) do (trial-run tr))))
(finish-output)
(ext:quit 0)
