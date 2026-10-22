;;;; rogue.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md), batch 1: the run is an ENDLESS run (endless.lisp: the carry,
;;;; STAGE CLEAR, RESULTS, the record) with *ROGUE* set; this file is the DOORS screen between steps (flow state :doors:
;;;; ROGUE-DOORS' doors, a rest or the next fight). The rules are rogue-rules.lisp. Debug 84000-84999 (debug.lisp:
;;;; ENDLESS-DEBUG with ROGUE). Log: "duel rogue door i step n kind [opponent]".
(in-package :duel)

(defvar *rogue-doors* nil "The DOORS screen's doors (ROGUE-DOORS' plists).")

(defun rogue-door-label (d)
  "A door's row: REST, or the opponent's name."
  (if (eq (getf d :kind) :rest) "REST" (kit-name (find-kit (getf d :opponent) :base))))

(defun rogue-door-note (d step)
  "What the selected door leads to: the rest's Konpaku, or the step's kind, CPU difficulty, the opponent's awakening
(awakened, or its gauge at FIGHT) and Reishi."
  (if (eq (getf d :kind) :rest)
      (format nil "KONPAKU +~d" *rogue-rest-konpaku*)
      (let ((r (rogue-ramp step)))
        (format nil "~@[~a  ~]~a~:[~;  AWAKENED~]~:[~*~;  AWAKENING ~d~]  REISHI ~d%"
                (case (rogue-step-kind step) (:elite "ELITE") (:boss "BOSS"))
                (ramp-difficulty *endless-floor* r *difficulties*) (fourth r)
                (and (not (fourth r)) (plusp (third r))) (third r) (fifth r)))))

(defun rogue-open-doors ()
  "After STAGE CLEAR's CONTINUE / REVERT (the carry made) or a rest: the next step's doors (the DOORS screen)."
  (let ((next (1+ *endless-stage*)))
    (setf *rogue-doors* (rogue-doors *endless-seed* next (first *endless-foes*) (playable-roster))
          *endless-lines* (vector (format nil "STAGE ~d" next)
                                  (format nil "KONPAKU  ~d" (getf *endless-carry* :konpaku))
                                  (mapcar #'rogue-door-label *rogue-doors*)
                                  (mapcar (lambda (d) (rogue-door-note d next)) *rogue-doors*)))
    (set-flow :doors)))

(defun rogue-take (i)
  "Door I: a rest (Konpaku +3, the step passed, the record checked, the next doors) or the next fight."
  (let ((d (nth i *rogue-doors*)))
    (log-msg "duel rogue door ~d step ~d ~(~a~)~@[ ~(~a~)~]" i (1+ *endless-stage*) (getf d :kind) (getf d :opponent))
    (if (eq (getf d :kind) :rest)
        (progn (incf *endless-stage*) (incf *endless-cleared*)
               (setf *endless-carry* (rogue-rest *endless-carry*))
               (endless-save-record)
               (rogue-open-doors))
        (progn (setf *rogue-next* (getf d :opponent)) (endless-next-stage)))))

(defun rogue-doors-update ()
  "DOORS per frame: the rows take input after 1 s, as STAGE CLEAR; the autopilot takes door 0."
  (cond (*endless-auto* (rogue-take 0))
        ((> *ft* 1.0) (let ((i (menu-nav (length *rogue-doors*)))) (when i (rogue-take i))))))

(defun hud-rogue-doors (w h s)
  "DOORS: the next stage, P1's Konpaku, the doors as rows with the selected one's note above them."
  (let ((l *endless-lines*))
    (multiple-value-bind (cx y pw) (results-card w h s)
      (ui-big-text (svref l 0) (round cx) (round (+ y (* 4 s))) (fit-scale (svref l 0) (* 3 s) (- pw (* 8 s)))
                   '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s :shear 0.0)
      (hud-text (svref l 1) cx (+ y (* 6 s) (* 11 (max 1 (round (* 1.5 s))))) (fit-scale (svref l 1) (* 1.5 s) (- pw (* 8 s)))
                *dim* :align :center)
      (when (> *ft* 1.0)
        (let* ((y0 (if (portrait-p) 0.8 0.72)) (note (nth *menu* (svref l 3))))
          (hud-text note cx (- (* y0 h) (* 14 s)) (fit-scale note (* 1.5 s) (- pw (* 8 s))) *ember* :align :center)
          (hud-menu (svref l 2) y0 w h s cx))))))
