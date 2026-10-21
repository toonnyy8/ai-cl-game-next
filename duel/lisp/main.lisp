;;;; main.lisp — SOUL DUEL's entry and the whole frame at a glance (design-v1 §12):
;;;;   per frame:  flow (menus, pause) → fixed steps → camera → draw (stage, fighters, hazards, fx)
;;;;               → HUD
;;;;   per step:   devices → vpads (humans) ; then either the running cinematic (CINE-STEP) or the
;;;;               sim: brain → fighter → hazard → hit → gauge → match ; then feedback
;;;; Hitstop freezes the sim (TIME-STEP); slow motion runs the sim on a fraction of the steps
;;;; (SLOW-ACC), so a sim frame is always a whole frame and the same seed replays the same match at
;;;; any frame rate.
(in-package :duel)

;;; ---------------------------------------------------------------- the fixed step
(defvar *slow-acc* 0.0 "Slow motion: sim frames owed (a sim frame runs each time it reaches 1).")
(defun reset-slow-clock ()
  "A new match owes no slow-motion frames (START-MATCH). A perfect Hoho leaves a fraction here; carried
over, it shifted the next match's first slow motion by a step: a seed's result then depended on the
matches run before it in the page."
  (setf *slow-acc* 0.0))

(defun sim-systems ()
  "One sim frame: the systems in order (a Kikon / Soul Break may start a cinematic mid-way; the
rest of the frame then waits for it)."
  (brain-system)                        ; CPU players write their vpads
  (assist-system)                       ; ASSIST presses for a human (assist.lisp)
  (fighter-system)                      ; vpad → commands → state machine → physics
  (unless *cine* (hazard-system))       ; projectiles, pillars, South's grab and hands
  (unless *cine* (hit-system))          ; collect every hit, then apply them together
  (unless *cine* (gauge-system))        ; regen, burns, form timers, Hellfire, EVOLUTION
  (unless *cine* (match-system)))       ; timer, time-up

(defun sim-step ()
  "One fixed 1/60 s step of a running match."
  (incf *match-tick*)
  (cond (*cine* (pilot-read) (cine-step))
        ((not (time-step)) (pilot-read))                  ; hitstop: devices only
        (t (setf *slow-acc* (+ *slow-acc* (slowmo-scale nil)))
           (if (>= *slow-acc* 1.0)
               (progn (decf *slow-acc* 1.0) (pilot-system) (sim-systems))
               (pilot-read))))
  (god-update)
  (probe-update)
  (feedback-system)
  (hash-log))

(defun pilot-read ()
  "A step without a sim frame (hitstop, slow motion, cinematic): the humans' devices are read into
their vpads without advancing the vpad clock, so a press made now is still buffered afterwards."
  (do-entities (e (pl pilot))
    (let ((r (vpad-reader (pilot-vpad pl)))) (when r (funcall r (pilot-vpad pl))))))

(defun advance-sim (rdt)
  "This frame's fixed steps: the engine's RUN-FIXED-STEPS (at most 6 per frame, stopping when the
match leaves the running state), or 120 steps in turbo (debug fast-forward)."
  (if *turbo*
      (dotimes (i 120) (when (sim-running-p) (sim-step)))
      (run-fixed-steps rdt #'sim-step :while #'sim-running-p)))

;;; ---------------------------------------------------------------- the frame
(defun game-frame (rdt)
  "One frame (the engine runs it between BEGIN-FRAME and END-FRAME; RDT = real seconds). The effects run
on FDT: RDT, or 0 while paused (the fx clock, particles, stamps, shake, camera and HUD animation stop)."
  (screen-fx-update (if (or *paused* (cine-held-p)) 0.0 rdt))   ; last frame's impact frames / lines / silence run out
  (onehand-frame)                                           ; the page, the deck, this frame's fingers
  (flow-update rdt)
  (gate-update)
  (perf-mark)                                               ; stats: "sim" = the fixed steps
  (if (sim-running-p)
      (advance-sim rdt)
      (progn (setf *step-acc* 0.0)
             (unless (or *paused* (not (entity-alive-p *p1*)))       ; menus: fighters idle on real time
               (do-sides (e) (anim-advance (model-anim (model e)) (f32 rdt))))))
  (let ((fdt (cond ((fx-frozen-p) 0.0) ((= *cine-time-scale* 1f0) rdt) (t (* rdt *cine-time-scale*)))))   ; (CINE-SLOW)
    (fx-clock-advance (f32 fdt))
    (if (member *flow* '(:intro :battle :finish))
        (duel-camera *p1* *p2* fdt)
        (menu-camera))
    (shake-update (f32 fdt))
    (update-camera)
    (perf-mark)                                             ; "queue" = scene + HUD
    (unless *turbo* (draw-scene fdt))
    (unless (svref *no-draw* 0) (hud-draw))
    (when *frame-probe* (frame-probe-step))))

(defun stats-tail ()
  (if (entity-alive-p *p1*)
      (format nil " | ~a t ~d p1 ~a ~d p2 ~a ~d | heap ~,1f MB" *flow* *match-tick*
              (state-of *p1*) (gauges-reishi (gauges *p1*)) (state-of *p2*) (gauges-reishi (gauges *p2*))
              (/ (ffi:c-inline () () :int "(int)GC_get_heap_size()" :one-liner t) 1048576.0))
      ""))

(defun start-game ()
  "After loading: the dusk plaza, keyboard-friendly pointer, the title screen."
  (setf *pointer-lock* nil
        *key-ease* 1 *shake-hz* 12f0)                       ; pose-to-pose easing, a drawn (stepped) shake
  (stage-env)
  (onehand-init)
  (go-title))

(run-game :title "SOUL DUEL"
          :load (append (list #'bodies-init) (body-load-steps) (list #'stage-init #'brush-init))
          :start #'start-game
          :frame #'game-frame
          :debug #'debug-command
          :stats #'stats-tail)
