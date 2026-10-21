;;;; rukia-meter.lisp — Rukia's cold gauge (docs/duel/DUEL_RUKIA.md §4, §8), its sim step and its HUD widgets: the cold C
;;;; per step (RUKIA-COLD-STEP: the band is her form) and the two stacked bars with the band's pips and the 凍 label (%HUD-TEMP,
;;;; HUD-TEMP, HUD-TEMP-LABEL). Reached only through her kit (rukia.lisp :m18, inherited): the :tick hook RUKIA-TICK
;;;; (combat.lisp GAUGE-SYSTEM) and the meter's :draw RUKIA-HUD-METER / :label TEMP-LABEL (hud.lisp). The :temp flag stays on
;;;; the meter: combat.lisp COLD-ADD! (the hit path), onehand.lisp's frost arc and ai.lisp read it. Loaded after hud.lisp,
;;;; not host-loaded: HUD-TEXT / REFUSED-FLASH are hud.lisp's, *CRACK-T* feedback.lisp's (refactor round 3 N8,
;;;; docs/engine/REFACTOR_NEXT.md).
(in-package :duel)

(defun rukia-tick (e f g)
  "Her :tick hook (GAUGE-SYSTEM, every step, after the form timers): the cold gauge in a form with a :temp meter."
  (let ((kit (fighter-kit f)))
    (when (getf (kit-meter kit) :temp) (rukia-cold-step e f g kit))))

(defun rukia-cold-step (e f g kit)
  "A :temp kit meter per step: the cold C (rules TEMP-NEXT) cools while she guards (:guard / :guard-hit; at absolute zero,
where the ward is always up, bracing: U held while free, which drains the guard gauge *ZERO-BRACE-DRAIN* per second and
ends in the CRACK when it runs out) and warms at the form's :warm otherwise. The THAW lock (GAUGES-METER-IDLE frames
after a CRACK) stops the cooling. The band (the form, rules TEMP-BAND-AT) follows C only while she is free, so a combo
(a string and everything chained to it) or a special finishes in the band it started in, and the band then re-resolves
from what is left (an overdrawn -273 combo at C 0 lands at -18)."
  (let* ((st (fighter-state f)) (free (member st '(:idle :guard :run))) (lock (gauges-meter-idle g))
         (brace (and free (passive-p e :ward) (not (gauges-guardless g)) (vpad-down (pilot-vpad (pilot e)) :guard)))
         (guarding (and (zerop lock) (or (member st '(:guard :guard-hit)) brace))))
    (when (plusp lock) (setf (gauges-meter-idle g) (1- lock)))
    (setf (gauges-meter g) (f32 (temp-next (gauges-meter g) guarding (kit-warm kit))))
    (if (and brace (drain-guard e (/ *zero-brace-drain* 60.0) :brace))
        (ward-drop e)                                   ; braced on credit until the gauge ran out: the CRACK
        (let ((band (temp-band-at (gauges-meter g) (fighter-form f) st)))   ; locked while she is in a combo
          (unless (eq band (fighter-form f))
            (set-form e band)
            (emit :sfx :frost-tick e))))))

(defun-fast %hud-temp (x y w h c band cost lock crack refused right tm)
  "Rukia's cold gauge (docs/duel/DUEL_RUKIA.md §8) in the W x H slot at (X Y): two stacked bars overlaid in one strip (the user's
decision 2026-09-28), bar 1 (cold C 0..100) steel-ice, bar 2 (100..200) white over it. BAND 0 / 1 / 2 (-18 / -50 /
zero): as many ice pips lit at the strip's inner end; at zero bar 2 pulses, flickering in its last tenth. COST: L's
cold, the part of the top bar it would spend dimmed (a hollow notch at the cost when C is short of it; REFUSED 0..1
flashes it). LOCK: the THAW lock after a CRACK (grey). CRACK 0..1: a BLOOD hairline across it. White on ink: ice is mono."
  (declare (single-float x y w h c cost crack refused tm) (fixnum band) (boolean lock))
  (let* ((bar (the single-float (f32 *cold-bar*)))
         (f1 (f-clamp (/ c bar) 0f0 1f0)) (f2 (f-clamp (/ (- c bar) bar) 0f0 1f0))
         (a2 (cond ((and (= band 2) (< f2 0.1f0)) (+ 0.35f0 (* 0.65f0 (%pulse tm 8.0))))
                   ((= band 2) (+ 0.75f0 (* 0.25f0 (%pulse tm 3.0))))
                   (t 1f0))))
    (declare (single-float bar f1 f2 a2))
    (%hrect x y w h 0.05f0 0.04f0 0.07f0 0.75f0)
    (if lock
        (%hbar x y w h f1 right 0.5f0 0.51f0 0.55f0 0.9f0 0.38f0 0.39f0 0.43f0 0.9f0)
        (progn (%hbar x y w h f1 right 0.55f0 0.66f0 0.8f0 1f0 0.34f0 0.43f0 0.56f0 1f0)
               (when (> f2 0f0) (%hbar x y w h f2 right 0.97f0 0.98f0 1f0 a2 0.8f0 0.86f0 0.95f0 a2))))
    (when (and (> cost 0f0) (not lock))                   ; L's cost on the top bar
      (let* ((top (if (> c bar) f2 f1)) (base (if (> c bar) bar 0f0))
             (lo (f-clamp (/ (- c cost base) bar) 0f0 1f0)) (k (f-max 0.45f0 refused)))
        (declare (single-float top base lo k))
        (if (>= c cost)
            (let ((sx (if right (+ x (* w (- 1f0 top))) (+ x (* w lo)))))
              (declare (single-float sx))
              (%hrect sx y (* w (- top lo)) h 0.05f0 0.04f0 0.07f0 (* 0.55f0 k)))
            (let ((cx (if right (+ x (* w (- 1f0 (/ cost bar)))) (+ x (* w (/ cost bar))))))
              (declare (single-float cx))
              (%hrect cx (- y 2f0) 1f0 (+ h 4f0) 1f0 1f0 1f0 (f-max 0.35f0 refused))))))
    (dotimes (i 3)                                        ; the band: -18 | -50 | -273
      (let* ((ps (f-max 2f0 (* 0.6f0 h))) (px (+ x (* 1.5f0 ps (i->f i)) 1f0)) (px (if right (- (+ x w) (- px x) ps) px)))
        (declare (single-float ps px))
        (%hrect (- px 1f0) (- (+ y (* 0.2f0 h)) 1f0) (+ ps 2f0) (+ ps 2f0) 0.05f0 0.05f0 0.08f0 1f0)   ; an ink box
        (if (<= i band)                                   ; lit: ice white; unlit: dark
            (%hrect px (+ y (* 0.2f0 h)) ps ps 0.85f0 0.93f0 1f0 1f0)
            (%hrect px (+ y (* 0.2f0 h)) ps ps 0.22f0 0.24f0 0.3f0 1f0))))
    (when (> crack 0f0)                                   ; the hand cracked: a BLOOD hairline across the strip
      (%hrect x (+ y (* 0.4f0 h)) w (f-max 1f0 (* 0.25f0 h)) 0.82f0 0.06f0 0.11f0 crack))
    nil))

(defun hud-temp (e kit x y w h right tm)
  "Draw E's cold gauge (KIT has a :temp meter) at (X Y), W x H: HUD-TEMP's numbers from the gauges and the form."
  (let* ((g (gauges e)) (side (fighter-side (fighter e))))
    (%hud-temp (f32 x) (f32 y) (f32 w) (f32 h) (gauges-meter g) (case (kit-form kit) (:m50 1) (:zero 2) (t 0))
               (f32 (cold-cost kit :sig)) (plusp (gauges-meter-idle g))
               (f32 (max 0.0 (- 1.0 (* 2.5 (- tm (aref *crack-t* side))))))
               (refused-flash side tm)
               right tm)))

(defparameter *temp-kanji* "凍")
(defparameter *c-ice* (list 0.9 0.94 1.0 1.0))
(defun temp-label (g kit) "The cold gauge's label: the band, or THAW in the lock after a CRACK."
  (if (plusp (gauges-meter-idle g)) "THAW" (kit-form-name kit)))

(defun hud-temp-label (x y s right name)
  "The cold gauge's label: the brush glyph 凍 and the band (-18C, -50C, -273C, or THAW in the lock), from X toward the
panel's outside."
  (let* ((em (* 8 s)))
    (brush-text *temp-kanji* (if right (- x (* 0.5 em)) (+ x (* 0.5 em))) (+ y (* 3.5 s)) em *c-ice*)
    (hud-text name (if right (- x em (* 2 s)) (+ x em (* 2 s))) y s *c-ice* :align (if right :right :left))))

(defun rukia-hud-meter (e kit x y w h right tm lx ly ls)
  "Her meter row (the kit meter's :draw: hud.lisp HUD-SIDE / HUD-SIDE-PORTRAIT): the cold gauge in the W x H slot at (X Y),
its label at (LX LY), scale LS (LX NIL: the portrait row, no label)."
  (hud-temp e kit x y w h right tm)
  (when lx (hud-temp-label lx ly ls right (temp-label (gauges e) kit))))
