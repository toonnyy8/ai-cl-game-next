;;;; ken-meter.lisp — Kenpachi's kit hooks outside the hit path: the meter's :label KEN-HUD-LABEL (the plate's tag: webhud.lisp
;;;; WEBHUD-TAG; the Lisp plate draws the KAIHO / UDE strip, lhud-plate.lisp). (The Shikai's :p KEN-P, a no-op that kept P in his run,
;;;; became the kit key :run-awaken, 2026-11-13, REFACTOR_2026-11 R11.) The canvas widgets %HUD-LV / %HUD-ARM / KEN-HUD-METER left with the canvas HUD (2026-11-11, DUEL_LISP_HUD §16).
;;;; The arm's spend / burst (ARM-SPEND! ARM-BURST!) and NOME's gain (NOME-GAIN!) stay in combat.lisp: the hit path calls them.
;;;; Not host-loaded: CLOG is components.lisp's macro (refactor round 3 N8, docs/engine/REFACTOR_NEXT.md).
(in-package :duel)

(defun ken-hud-label (g kit)
  "His portrait label (the meter's :label): the meter's name, NOME or UDE."
  (declare (ignore g))
  (getf (kit-meter kit) :name))
