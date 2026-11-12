;;;; ken-meter.lisp — Kenpachi's kit hooks outside the hit path: the Shikai's :p KEN-P (a no-op that keeps P in his run)
;;;; and the meter's :label KEN-HUD-LABEL (the plate's tag: webhud.lisp WEBHUD-TAG; the Lisp plate draws the KAIHO / UDE strip,
;;;; lhud-plate.lisp). The canvas widgets %HUD-LV / %HUD-ARM / KEN-HUD-METER left with the canvas HUD (2026-11-11, DUEL_LISP_HUD §16).
;;;; The arm's spend / burst (ARM-SPEND! ARM-BURST!) and NOME's gain (NOME-GAIN!) stay in combat.lisp: the hit path calls them.
;;;; Not host-loaded: CLOG is components.lisp's macro (refactor round 3 N8, docs/engine/REFACTOR_NEXT.md).
(in-package :duel)


(defun ken-p (e free)
  "The Shikai's :p hook: nothing. Its only use, DANGAI's 隨時卍解 card, left with the frozen modes (2026-11-13, REFACTOR_2026-11 R4);
the hook stays so the Shikai's run still takes P, the awakening from a run (fighter.lisp RUN-STEP's *RUN-COMMANDS-P*), as it did.
ponytail: drop it, and :p from the kit, if the awakening from a run should go."
  (declare (ignore e free))
  nil)

(defun ken-hud-label (g kit)
  "His portrait label (the meter's :label): the meter's name, NOME or UDE."
  (declare (ignore g))
  (getf (kit-meter kit) :name))
