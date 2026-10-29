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
               (progn (decf *slow-acc* 1.0) (slow-snapshot) (pilot-system) (sim-systems))
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

;;; ---------------------------------------------------------------- slow motion drawn smooth (a look)
;;; In slow motion a sim frame runs only every few steps, so the bodies, their clips and the waves moved in jumps while the camera
;;; and the effects ran on real time: the picture shook (the user, 2026-10-27: 「目前進入慢動作時，畫面會不自然的抖動，請幫我去除」).
;;; Each sim frame first keeps where every fighter and hazard stood; while the sim is slowed, the frame is drawn between that and now
;;; by *SLOW-ACC* (the way to the next sim frame), the clips one sim frame's share back in time, and everything is put back after
;;; the HUD. The sim never sees the drawn values (it runs before SLOW-DRAW-BEGIN and after SLOW-DRAW-END).
(defvar *slow-was* (make-hash-table :test 'eq) "Entity -> f32vec x y z yaw before the last sim frame (SLOW-SNAPSHOT).")
(defvar *slow-now* (make-hash-table :test 'eq) "Entity -> f32vec x y z yaw clip-time blend the frame drew over (SLOW-DRAW-END).")
(defvar *slow-drawn* nil "T while this frame's entities stand at drawn (interpolated) places.")

(defun slow-keep (table e n)
  "E's vector of N floats in TABLE (made once)."
  (or (gethash e table) (setf (gethash e table) (make-f32 n))))

(defun slow-snapshot ()
  "Before a sim frame: where each fighter and hazard is (for SLOW-DRAW-BEGIN)."
  (when (> (hash-table-count *slow-was*) 48) (clrhash *slow-was*))   ; (dead hazards' entries)
  (flet ((keep (e x y z yaw) (let ((v (slow-keep *slow-was* e 4))) (setf (aref v 0) x (aref v 1) y (aref v 2) z (aref v 3) yaw))))
    (do-sides (e) (let ((p (pos-of e))) (keep e (aref p 0) (aref p 1) (aref p 2) (yaw-of e))))
    (do-entities (h (hz hazard)) (keep h (hazard-x hz) (hazard-y hz) (hazard-z hz) (hazard-yaw hz)))))

(defun slow-mix (w i now a)
  "The drawn value of slot I: from the kept W toward NOW by A (a yaw, slot 3, the short way)."
  (f32 (+ (aref w i) (* a (if (= i 3) (angle-wrap (- now (aref w i))) (- now (aref w i)))))))

(defun slow-draw-begin ()
  "While the sim is slowed (not in a cinematic): stand each fighter / hazard between its last two sim frames, its clip as far back."
  (setf *slow-drawn* nil)
  (when (and (sim-running-p) (not *cine*) (< (slowmo-scale nil) 1f0))
    (let* ((a (f32 (min 1.0 (max 0.0 *slow-acc*)))) (back (* (- 1f0 a) (/ 1f0 60f0))))
      (do-sides (e)
        (let ((w (gethash e *slow-was*)))
          (when w
            (let ((n (slow-keep *slow-now* e 6)) (p (pos-of e)) (tf (transform e)) (anim (model-anim (model e))))
              (dotimes (i 3) (setf (aref n i) (aref p i) (aref p i) (slow-mix w i (aref p i) a)))
              (setf (aref n 3) (transform-yaw tf) (transform-yaw tf) (slow-mix w 3 (transform-yaw tf) a)
                    (aref n 4) (anim-time anim) (aref n 5) (anim-blend anim)
                    (anim-time anim) (f32 (- (anim-time anim) (* back (anim-speed anim)))))
              (when (> (anim-blend anim) 0f0)
                (setf (anim-blend anim) (f32 (min (anim-blend-dur anim) (+ (anim-blend anim) back)))))))))
      (do-entities (h (hz hazard))
        (let ((w (gethash h *slow-was*)))
          (when w
            (let ((n (slow-keep *slow-now* h 6)))
              (setf (aref n 0) (hazard-x hz) (aref n 1) (hazard-y hz) (aref n 2) (hazard-z hz) (aref n 3) (hazard-yaw hz)
                    (hazard-x hz) (slow-mix w 0 (hazard-x hz) a) (hazard-y hz) (slow-mix w 1 (hazard-y hz) a)
                    (hazard-z hz) (slow-mix w 2 (hazard-z hz) a) (hazard-yaw hz) (slow-mix w 3 (hazard-yaw hz) a))))))
      (setf *slow-drawn* t))))

(defun slow-draw-end ()
  "Put back what SLOW-DRAW-BEGIN moved."
  (when *slow-drawn*
    (do-sides (e)
      (let ((n (gethash e *slow-now*)))
        (when (and n (gethash e *slow-was*))
          (let ((p (pos-of e)) (anim (model-anim (model e))))
            (dotimes (i 3) (setf (aref p i) (aref n i)))
            (setf (transform-yaw (transform e)) (aref n 3) (anim-time anim) (aref n 4) (anim-blend anim) (aref n 5))))))
    (do-entities (h (hz hazard))
      (let ((n (gethash h *slow-now*)))
        (when (and n (gethash h *slow-was*))
          (setf (hazard-x hz) (aref n 0) (hazard-y hz) (aref n 1) (hazard-z hz) (aref n 2) (hazard-yaw hz) (aref n 3)))))
    (setf *slow-drawn* nil)))

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
  (slow-draw-begin)                                         ; slow motion: drawn between two sim frames (put back below)
  (let ((fdt (cond ((fx-frozen-p) 0.0) ((= *cine-time-scale* 1f0) rdt) (t (* rdt *cine-time-scale*)))))   ; (CINE-SLOW)
    (fx-clock-advance (f32 fdt))
    (setf (camera-shift-x *camera*) 0f0)                    ; (only SELECT's web framing shifts it: MENU-CAMERA)
    (if (member *flow* '(:intro :battle :finish))
        (duel-camera *p1* *p2* fdt)
        (menu-camera))
    (shake-update (f32 fdt))
    (update-camera)
    (perf-mark)                                             ; "queue" = scene + HUD
    (unless *turbo* (draw-scene fdt))
    (unless (svref *no-draw* 0) (hud-draw))
    (when *frame-probe* (frame-probe-step)))
  (slow-draw-end))

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

(run-game :title "SOUL DUEL NEXT"
          :load (append (list #'bodies-init) (body-load-steps) (list #'stage-init #'brush-init))
          :start #'start-game
          :frame #'game-frame
          :debug #'debug-command
          :stats #'stats-tail)
