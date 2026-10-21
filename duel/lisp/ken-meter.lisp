;;;; ken-meter.lisp — Kenpachi's two kit meters, each one's sim step and its HUD widgets: Nozarashi's NOME, the cup ladder
;;;; (docs/duel/DUEL_NOZARASHI_V2.md: KEN-NOME-STEP, %HUD-NOME) and the Bankai's arm UDE (docs/duel/DUEL_KEN_BANKAI.md §7:
;;;; KEN-ARM-STEP, %HUD-ARM, HUD-ARM-LABEL). Reached only through his kit (ken.lisp): the :tick hook KEN-TICK (combat.lisp
;;;; GAUGE-SYSTEM) and the meter's :draw KEN-HUD-METER / :label KEN-HUD-LABEL (hud.lisp's panel and portrait row). The arm's
;;;; spend / burst (ARM-SPEND! ARM-BURST!) and NOME's gain (NOME-GAIN!) stay in combat.lisp: the hit path calls them.
;;;; Loaded after hud.lisp, not host-loaded: CLOG is components.lisp's macro, HUD-TEXT hud.lisp's (refactor round 3 N8,
;;;; docs/engine/REFACTOR_NEXT.md).
(in-package :duel)

(defun ken-tick (e f g)
  "His :tick hook (GAUGE-SYSTEM, every step, after the form timers): the arm meter in a form with :pips (the Bankai), then
the NOME ladder in a form whose meter has a :ladder (the three cups). KIT is read once, before either step."
  (let ((kit (fighter-kit f)))
    (when (kit-pips kit) (ken-arm-step e f g))
    (let ((m (kit-meter kit)))
      (when (getf m :ladder) (ken-nome-step e f g m)))))

(defun ken-arm-step (e f g)
  "The arm meter per step (a form with :pips): the pip a finished J / K string owes is charged (rules STRING-PIP-DUE-P);
the crack clock (rules PIP-STEP: paused while locked) cracks a pip every *ARM-CRACK* frames without a spend; once the
last pip went, the pending burst fires when BURST-DUE-P says."
  (let ((mv (current-move f)) (pend (gauges-arm-pending g)))
    (when (string-pip-due-p (gauges-arm-owed g) (fighter-state f) (and mv (mv-kind mv)))
      (setf (gauges-arm-owed g) nil)
      (arm-spend! e mv))                                ; (a cancel out of the string: the burst waits for it too)
    ;; the last pip's move goes on as a chain (a latched link, SP2's punch, the O ender): the burst waits for the chain
    (when (and (typep pend 'move) mv (not (eq mv pend)) (move-follows-p (fighter-kit f) pend mv))
      (setf (gauges-arm-pending g) mv)))
  (let ((pend (gauges-arm-pending g)))
    (if pend
        (when (burst-due-p pend (fighter-move f) (fighter-state f)) (arm-burst! e))
        (multiple-value-bind (n idle cracked) (pip-step (round (gauges-meter g)) (gauges-meter-idle g) (plusp (fighter-lock f)))
          (setf (gauges-meter g) (f32 n) (gauges-meter-idle g) idle)
          (when cracked
            (when (zerop n) (setf (gauges-arm-pending g) (or (current-move f) :none)))
            (refresh-look e)
            (emit :arm-crack e n)
            (clog "~a UDE cracked, ~d left" (side-name e) n))))))

(defun ken-nome-step (e f g m)
  "A meter with a :ladder (Nozarashi's NOME, meter M): only while he is free (idle, walk, guard, run: never under
a string), the rung NOME asks for (LADDER-RUNG, several steps at once), which is his form; then the rung's drain
(METER-DRAIN; the rung is read before the drain, so a gain to exactly 100 is cup 3 on the first free frame)."
  (let* ((ladder (getf m :ladder)) (i (or (position (fighter-form f) ladder :key #'first) 0)))
    (when (member (fighter-state f) '(:idle :guard :run))
      (let ((j (ladder-rung (gauges-meter g) i ladder)))
        (unless (= i j)
          (set-form e (first (nth j ladder)))
          (emit :rung e (> j i))
          (setf i j))))
    (let ((r (nth i ladder)))
      (setf (gauges-meter g) (f32 (meter-drain (gauges-meter g) (second r) (third r) (gauges-meter-idle g)))
            (gauges-meter-idle g) (min 9999 (1+ (gauges-meter-idle g)))))))

(defun-fast %hud-nome (x y w h fill right rung floor tm)
  "Nozarashi's NOME bar: dark back, the REIATSU yellow FILL (pulsing while within 10 of the current cup's FLOOR,
where it would drop a cup), bright marks at a cup's entry (40, 100), dim floor ticks (25, 50), and three cup pips
inside the frame, RUNG + 1 of them lit."
  (declare (single-float x y w h fill floor tm) (fixnum rung))
  (let* ((near (and (> floor 0f0) (< fill (+ floor 0.1f0))))
         (a (if near (+ 0.55f0 (* 0.45f0 (%pulse tm 5.0))) 1f0)))
    (declare (single-float a))
    (%hrect x y w h 0.05f0 0.04f0 0.07f0 0.75f0)
    (%hbar x y w h fill right 1f0 0.88f0 0.3f0 a 0.9f0 0.62f0 0.1f0 a)
    (macrolet ((tick (v r g b al) `(let ((k (/ (the single-float (f32 ,v)) (the single-float (f32 *nome-max*)))))
                                     (declare (single-float k))
                                     (%hrect (if right (+ x (* w (- 1f0 k))) (+ x (* w k))) (- y 2f0) 1f0 (+ h 4f0) ,r ,g ,b ,al))))
      (tick *nome-up-t2* 1f0 1f0 0.9f0 0.95f0)
      (tick *nome-down-t2* 0.6f0 0.6f0 0.55f0 0.6f0)
      (tick *nome-down-t3* 0.6f0 0.6f0 0.55f0 0.6f0))
    (dotimes (i 3)                                        ; the cups, from the bar's inner end
      (let* ((ps (f-max 2f0 (* 0.6f0 h))) (px (+ x (* 1.5f0 ps (i->f i)) 1f0)) (px (if right (- (+ x w) (- px x) ps) px)))
        (declare (single-float ps px))
        (if (<= i rung)
            (%hrect px (+ y (* 0.2f0 h)) ps ps 1f0 1f0 0.95f0 1f0)
            (%hrect px (+ y (* 0.2f0 h)) ps ps 0.3f0 0.3f0 0.28f0 0.8f0))))
    nil))

(defun-fast %hud-arm (x y w h pips idle right tm)
  "Kenpachi's Bankai arm meter UDE (docs/duel/DUEL_KEN_BANKAI.md §7) in the W x H slot at (X Y): four BLOOD claw-slash pips from
the slot's inner end (RIGHT: mirrored), PIPS of them intact; a spent pip INK with a white crack line; under the next
pip to crack a thin line draining over the *ARM-CRACK* clock (IDLE frames of it gone), the pip flickering in its last
60 f."
  (declare (single-float x y w h tm) (fixnum pips idle))
  (let* ((pw (/ w 4.6f0)) (gap (* 0.2f0 pw)) (hh (* 2.4f0 h)) (y0 (- y (* 0.7f0 h))) (sl (* 0.35f0 pw))
         (left (- (the fixnum *arm-crack*) idle)) (fl (if (< left 60) (+ 0.35f0 (* 0.65f0 (%pulse tm 8.0))) 1f0)))
    (declare (single-float pw gap hh y0 sl fl) (fixnum left))
    (dotimes (i 4)
      (let* ((k (i->f i)) (px (if right (- (+ x w) (* (+ k 1f0) (+ pw gap))) (+ x (* k (+ pw gap)))))
             (lit (< i pips)) (nx (= i (1- pips))) (a (if nx fl 1f0)))
        (declare (single-float k px a))
        (if lit
            (%hq (+ px sl) y0 (+ px pw) y0 (- (+ px pw) sl) (+ y0 hh) px (+ y0 hh) 0.82f0 0.06f0 0.11f0 a 0.55f0 0.03f0 0.06f0 a)
            (progn (%hq (+ px sl) y0 (+ px pw) y0 (- (+ px pw) sl) (+ y0 hh) px (+ y0 hh) 0.05f0 0.05f0 0.07f0 0.85f0)
                   (%hq (+ px (* 0.55f0 pw)) (+ y0 (* 0.15f0 hh)) (+ px (* 0.62f0 pw)) (+ y0 (* 0.15f0 hh))
                        (+ px (* 0.4f0 pw)) (+ y0 (* 0.85f0 hh)) (+ px (* 0.33f0 pw)) (+ y0 (* 0.85f0 hh)) 0.9f0 0.9f0 0.92f0 0.8f0)))
        (when nx                                          ; the crack clock under the next pip
          (%hrect px (+ y0 hh 2f0) (* pw (f-clamp (/ (i->f left) (i->f *arm-crack*)) 0f0 1f0)) (f-max 1f0 (* 0.3f0 h))
                  0.95f0 0.9f0 0.85f0 0.9f0))))
    nil))

(defparameter *arm-kanji* "腕")
(defun hud-arm-label (x y s right)
  "The arm meter's label: the brush glyph 腕 and UDE, from X toward the panel's outside (RIGHT: the right panel)."
  (let* ((em (* 8 s)) (tw (text-width "UDE" s)))
    (brush-text *arm-kanji* (if right (- x (* 0.5 em)) (+ x (* 0.5 em))) (+ y (* 3.5 s)) em *c-blood*)
    (hud-text "UDE" (if right (- x em (* 2 s)) (+ x em (* 2 s))) y s *c-blood* :align (if right :right :left))
    tw))

(defun ken-hud-meter (e kit x y w h right tm lx ly ls)
  "His meter row (the kit meter's :draw: hud.lisp HUD-SIDE / HUD-SIDE-PORTRAIT) in the W x H slot at (X Y): NOME's cup
ladder (yellow) in a form with a :ladder, the arm UDE (BLOOD pips) in one with :pips; its label at (LX LY), scale LS
(LX NIL: the portrait row, no label)."
  (let ((meter (kit-meter kit)) (g (gauges e)))
    (cond ((getf meter :ladder)
           (let* ((ladder (getf meter :ladder)) (rung (or (position (kit-form kit) ladder :key #'first) 0))
                  (mx (getf meter :max)))
             (%hud-nome (f32 x) (f32 y) (f32 w) (f32 h) (f32 (/ (gauges-meter g) mx)) right rung
                        (f32 (/ (fifth (nth rung ladder)) mx)) tm)
             (when lx (hud-text (getf meter :name) lx ly ls '(1 0.85 0.3 0.95) :align (if right :right :left)))))
          ((kit-pips kit)
           (%hud-arm (f32 x) (f32 y) (f32 w) (f32 h) (round (gauges-meter g)) (gauges-meter-idle g) right tm)
           (when lx (hud-arm-label lx ly ls right))))))

(defun ken-hud-label (g kit)
  "His portrait label (the meter's :label): the meter's name, NOME or UDE."
  (declare (ignore g))
  (getf (kit-meter kit) :name))
