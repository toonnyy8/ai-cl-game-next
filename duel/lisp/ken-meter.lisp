;;;; ken-meter.lisp — Kenpachi's kit hooks outside the hit path: the boss hook KEN-BOSS, DANGAI's any-time Bankai KEN-CARD-BANKAI
;;;; and the meter's :label KEN-HUD-LABEL (the plate's tag: webhud.lisp WEBHUD-TAG; the Lisp plate draws the KAIHO / UDE strip,
;;;; lhud-plate.lisp). The canvas widgets %HUD-LV / %HUD-ARM / KEN-HUD-METER left with the canvas HUD (2026-11-11, DUEL_LISP_HUD §16).
;;;; The arm's spend / burst (ARM-SPEND! ARM-BURST!) and NOME's gain (NOME-GAIN!) stay in combat.lisp: the hit path calls them.
;;;; Not host-loaded: CLOG is components.lisp's macro (refactor round 3 N8, docs/engine/REFACTOR_NEXT.md).
(in-package :duel)


(defun ken-boss (e)
  "His base kit's :boss hook (rogue.lisp ROGUE-STAGE-START, after the ramp's KATATE): the Bankai at FIGHT, its arm full
(as BANKAI!, without its cinematic, its Konpaku -> 1 or its repel: the boss keeps his Konpaku); from here no pip is ever
spent (ARM-SPEND!) and none cracks (KEN-TICK), so no KATAUDE: the Bankai the whole fight (DUEL_ROGUE §5, the user
2026-10-22: 「BOSS 劍八卍解解除手臂（不扣臂、無時限）」). His CPU needs nothing more: the crack clock stays at 0, so the
:pip-hurry never fires."
  (let ((g (gauges e)) (was (fighter-form (fighter e))))
    (set-form e :bankai)
    (setf (gauges-meter g) 0f0 (gauges-meter-idle g) 0 (gauges-reishi g) (gauges-reishi-max g))   ; (V3's Bankai: no arm)
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


(defun ken-hud-label (g kit)
  "His portrait label (the meter's :label): the meter's name, NOME or UDE."
  (declare (ignore g))
  (getf (kit-meter kit) :name))
