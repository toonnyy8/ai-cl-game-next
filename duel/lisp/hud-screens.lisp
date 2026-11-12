;;;; hud-screens.lisp — the per-frame UI entry HUD-DRAW (the canvas stream's flash, focus lines, cinematic letterbox and captions,
;;;; the battle's world overlays and the big words, then the Lisp HUD and menus in the paint stream, then the debug overlay). Every
;;;; screen is the Lisp HUD's (lhud-*.lisp, DUEL_LISP_HUD §16; the canvas title, mode, settings, controls, results and pause left
;;;; 2026-11-11, the frozen ENDLESS / DANGAI screens HUD-MENU / HUD-SELECT / RESULTS-CARD on 2026-11-13, REFACTOR_2026-11 R4).
;;;; Cosmetic only.
(in-package :duel)

(defvar *c-flash* (list 1.0 1.0 1.0 0.0))

(defun-fast aura-cap-update ()
  "Set vfx.lisp's *AURA-CAP* for the next frame: 0.5 while the fighters stand within 2.5 m, 1 from
3.5 m (two auras, or one over the other fighter, sum to a white blob up close). (Single floats, the generic ops: 8 B.)"
  (setf *aura-cap*
        (if (and *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*))
            (let* ((p (pos-of *p1*)) (q (pos-of *p2*))
                   (d (f-sqrt (+ (%pow2 (- (aref p 0) (aref q 0))) (%pow2 (- (aref p 2) (aref q 2)))))))
              (declare (type f32vec p q) (single-float d))
              (f-max 0.5f0 (f-min 1f0 (+ 0.5f0 (* 0.5f0 (- d 2.5f0))))))
            1.0)))

(declaim (special *web-caption* *lhud-shapes*))       ; (webhud.lisp's, lhud-shapes.lisp's)
(defun hud-draw ()
  "The UI of this frame: the canvas stream's part (a flash, the focus lines, a cinematic's letterbox and brush title but the intro's,
the K.O.'s and TIME's, which are the Lisp HUD's; the battle's world overlays; the big words), then the Lisp
HUD (LHUD-DRAW: the battle) and the Lisp menus (LHUD-MENU-DRAW, after LHUD-DRAW's frame), the paint shapes' card (debug 2509) and the
debug overlay."
  (let* ((w (window-width)) (h (window-height)) (s (ui-scale)) (f *ui-flash*))
    (aura-cap-update)
    (when (> (aref f 3) 0)
      (let ((c *c-flash*))
        (setf (first c) (aref f 0) (second c) (aref f 1) (third c) (aref f 2) (fourth c) (aref f 3))
        (ui-rect 0 0 w h c))
      (countdown! (aref f 3) (* (aref f 4) (hud-dt))))
    (draw-screen-fx w h)                                 ; focus lines (under the HUD)
    (when (and *cine* (not (webhud-cine-p *cine*)))     ; letterbox + the cinematic's brush title (not the intro's, the K.O.'s,
      (ui-rect 0 0 w (* 0.09 h) '(0 0 0 1)) (ui-rect 0 (* 0.91 h) w (* 0.09 h) '(0 0 0 1))   ; TIME's: the Lisp HUD's)
      (when *caption* (unless (draw-bcap *caption* w h) (setf *caption* nil))))
    (when (and *caption-out* (not (eq *caption-out* *web-caption*)))   ; an ended cinematic's title (not one the Lisp HUD drew)
      (unless (draw-bcap *caption-out* w h) (setf *caption-out* nil)))
    (when (and (member *flow* '(:battle :finish)) (not *cine*))   ; the battle's world overlays, the floating stick
      (hud-battle h) (when (and *one-hand* (portrait-p) (not *paused*)) (hud-stick)))
    (draw-words w h)
    (paint-clock-advance) (lhud-draw) (lhud-canvas-grade!)   ; the Lisp HUD (lhud-battle.lisp) and the composite grade it asks for
    (lhud-menu-draw)                                      ; the Lisp menus (lhud-menu.lisp; after LHUD-DRAW's frame)
    (when *lhud-shapes* (lhud-shapes-card))               ; debug 2509: the paint shapes' test card (lhud-shapes.lisp)
    (debug-hud w h s)))
