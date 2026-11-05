;;;; ken-meter.lisp — Kenpachi's two kit meters and their HUD widgets: the Shikai's unlock level L (DUEL_KEN_V3 §4: %HUD-LV; the
;;;; NOME cup ladder went with the cups, 2026-11-03) and the Bankai's arm UDE (docs/duel/DUEL_KEN_BANKAI.md §7:
;;;; KEN-ARM-STEP, %HUD-ARM, HUD-ARM-LABEL). Reached only through his kit (ken.lisp): the :tick hook KEN-TICK (combat.lisp
;;;; GAUGE-SYSTEM) and the meter's :draw KEN-HUD-METER / :label KEN-HUD-LABEL (hud.lisp's panel and portrait row). The arm's
;;;; spend / burst (ARM-SPEND! ARM-BURST!) and NOME's gain (NOME-GAIN!) stay in combat.lisp: the hit path calls them.
;;;; Loaded after hud.lisp, not host-loaded: CLOG is components.lisp's macro, HUD-TEXT hud.lisp's (refactor round 3 N8,
;;;; docs/engine/REFACTOR_NEXT.md).
(in-package :duel)


(defun ken-boss (e)
  "His base kit's :boss hook (rogue.lisp ROGUE-STAGE-START, after the ramp's KATATE): the Bankai at FIGHT, its arm full
(as BANKAI!, without its cinematic, its Konpaku -> 1 or its repel: the boss keeps his Konpaku); from here no pip is ever
spent (ARM-SPEND!) and none cracks (KEN-TICK), so no KATAUDE: the Bankai the whole fight (DUEL_ROGUE §5, the user
2026-10-22: 「BOSS 劍八卍解解除手臂（不扣臂、無時限）」). His CPU needs nothing more: the crack clock stays at 0, so the
:pip-hurry never fires."
  (let ((g (gauges e)) (was (fighter-form (fighter e))))
    (set-form e :bankai)
    (setf (gauges-meter g) (f32 (or (getf (kit-pips (kit-of e)) :n) 0)) (gauges-meter-idle g) 0 (gauges-arm-pending g) nil   ; (V3's Bankai: no arm)
          (gauges-arm-owed g) nil (gauges-reishi g) (gauges-reishi-max g))
    (refresh-look e)
    (log-msg "duel boss kenpachi ~(~a~)->~(~a~) ude ~d konpaku ~d reishi ~d" was (fighter-form (fighter e))
             (round (gauges-meter g)) (gauges-konpaku g) (gauges-reishi g))))

(defun ken-card-bankai (e free)
  "His cups' :p hook (fighter.lisp TRY-COMMAND :awaken, after the awakening and the cup-3 Bankai refused): DANGAI's 隨時卍解
card (:any-bankai, DUEL_ROGUE §4.3, the user 2026-10-22: 「卍解隨時可開，且不扣除魂魄」, 「覺醒後隨時、照樣回血」): FREE and
awakened in any cup, the Bankai at any Konpaku (BANKAI! keeps his Konpaku, refills his Reishi). Once a stage by
construction: after the Bankai comes KATAUDE, never a cup again. T when it took the press."
  (when (and free (rmod e :any-bankai nil) (gauges-awakened (gauges e))
             (eq (fighter-form (fighter e)) :nozarashi) (not (bind-of e)))
    (log-msg "duel runmod any-bankai from ~(~a~) konpaku ~d" (fighter-form (fighter e)) (gauges-konpaku (gauges e)))
    (bankai! e :bankai)
    t))


(defun-fast %hud-lv (x y w h lv mx right)
  "The Shikai's unlock level (DUEL_KEN_V3 §4) in the W x H slot at (X Y): MX square pips from the slot's inner end (RIGHT: mirrored), LV lit
REIATSU yellow."
  (declare (single-float x y w h) (fixnum lv mx))
  (let ((ps (f-max 3f0 (* 1.6f0 h))))
    (declare (single-float ps))
    (dotimes (i mx)
      (let* ((px (+ x (* 1.5f0 ps (i->f i)))) (px (if right (- (+ x w) (- px x) ps) px)))
        (declare (single-float px))
        (if (< i lv)
            (%hrect px (- y (* 0.3f0 h)) ps ps 1f0 0.85f0 0.3f0 1f0)
            (%hrect px (- y (* 0.3f0 h)) ps ps 0.3f0 0.3f0 0.28f0 0.8f0))))
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
    (cond ((getf meter :lv)                              ; the Shikai's unlock level L (DUEL_KEN_V3 §4): yellow pips
           (%hud-lv (f32 x) (f32 y) (f32 w) (f32 h) (round (gauges-meter g)) (getf meter :max) right)
           (when lx (hud-text (getf meter :name) lx ly ls '(1 0.85 0.3 0.95) :align (if right :right :left))))
          ((kit-pips kit)
           (%hud-arm (f32 x) (f32 y) (f32 w) (f32 h) (round (gauges-meter g)) (gauges-meter-idle g) right tm)   ; (no crack: idle stays 0)
           (when lx (hud-arm-label lx ly ls right))))))

(defun ken-hud-label (g kit)
  "His portrait label (the meter's :label): the meter's name, NOME or UDE."
  (declare (ignore g))
  (getf (kit-meter kit) :name))
