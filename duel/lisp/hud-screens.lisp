;;;; hud-screens.lisp — the per-frame UI entry HUD-DRAW (the canvas stream's flash, focus lines, cinematic letterbox and captions,
;;;; the frozen modes' screens, the battle's world overlays and the big words, then the Lisp HUD and menus in the paint stream, then
;;;; the debug overlay) and the canvas screens only the frozen ENDLESS / DANGAI still use: their SELECT (HUD-SELECT), the black
;;;; card their STAGE CLEAR and results lay out on (RESULTS-CARD), the menu list (HUD-MENU). Every other screen is the Lisp HUD's
;;;; (lhud-*.lisp, DUEL_LISP_HUD §16; the canvas title, mode, settings, controls, results and pause left 2026-11-11). Cosmetic only.
(in-package :duel)

;;; ---------------------------------------------------------------- the frozen modes' canvas screens (refactor decision D2 archives them)
(defun hud-menu (items y0 w h s &optional (cx (/ w 2)) (bottom 0.97))
  "Vertical menu centred on CX from Y0 (fraction of H) down to at most BOTTOM (a long list, e.g. PRACTICE's pause, packs
its rows and shrinks its text to fit); *MENU* is highlighted."
  (let* ((k (min 1 (/ (* h (- bottom y0)) (* (length items) 22 s)))) (sc (max 1 (floor (* 2 s k)))) (dy (* 22 s k)))
    (loop for it in items for i from 0 do
      (let* ((sel (= i *menu*)) (y (+ (* h y0) (* i dy))) (sc (fit-scale it sc (* 0.94 w))) (tw (text-width it sc)))
        (when sel
          (ui-gradient (- cx (* 0.5 tw) (* 14 s)) (- y (* 3 s)) (+ tw (* 28 s)) (+ (* 7 sc) (* 6 s))
                       '(0.8 0.3 0.05 0.0) '(0.8 0.3 0.05 0.8) :vertical nil))
        (when (touch-tap-zones-p)                          ; the row as a tap target (onehand.lisp TAPPED-ROW)
          (note-menu-row i (- cx (max (* 0.5 tw) (* 0.3 w))) (- y (* 0.5 (- dy (* 7 sc)))) (+ cx (max (* 0.5 tw) (* 0.3 w)))
                         (+ y (* 7 sc) (* 0.5 (- dy (* 7 sc))))))
        (ui-text it (round cx) y :scale sc :align :center :color (if sel *white* '(0.8 0.78 0.85 1)) :shadow t)))))

(defun hud-select-portrait (w h s)
  "SELECT on a tall screen: the pair above (main.lisp MENU-CAMERA), P1's and P2's pick on two rows, the CPU difficulty,
and the tap help (left / right third: choose, the middle: confirm)."
  (ui-big-text "SELECT YOUR FIGHTER" (floor w 2) (* 0.08 h) (fit-scale "SELECT YOUR FIGHTER" (* 4 s) (* 0.9 w)) *white* '(0.7 0.25 0.05 1) s)
  (dolist (e (list *p1* *p2*))
    (let* ((side (fighter-side (fighter e))) (y (* h (if (zerop side) 0.6 0.7)))
           (active (= side (min 1 *select-phase*))) (cpu (or (eq *mode* :cpu-cpu) (and (= side 1) (vs-cpu-p))))
           (name (format nil "~:[  ~;< ~]~a~:[  ~; >~]" (and active (< *select-phase* 2)) (kit-name (kit-of e)) (and active (< *select-phase* 2)))))
      (ui-text (format nil "~a~a" (if (zerop side) "P1" "P2") (if cpu " CPU" "")) (floor w 2) y :scale s :align :center
               :color (if (zerop side) '(1 0.6 0.3 1) '(0.5 0.7 1 1)) :shadow t)
      (ui-text name (floor w 2) (+ y (* 10 s)) :scale (fit-scale name (* 3 s) (* 0.94 w)) :align :center
               :color (if active *white* *dim-ink*) :shadow active)))
  (when (and (/= *select-phase* 0) (/= *select-phase* 1) (not (eq *mode* :vs-player)))
    (let* ((rows (select-rows)) (row (nth (mod *menu* (length rows)) rows)))
      (ui-text (format nil "~a  < ~a >" (if (eq *mode* :endless) "START" "CPU") (symbol-name *difficulty*)) (floor w 2) (* 0.82 h) :scale (* 2 s)
               :align :center :color (if (eq row :difficulty) '(1 0.85 0.3 1) *dim-ink*) :shadow (eq row :difficulty))
      (when (member :rank rows)                         ; DANGAI's 靈壓階 (DUEL_ROGUE §6)
        (let ((str (format nil "< ~a >" (nth *rogue-rank* *rogue-rank-names*))))
          (ui-text str (floor w 2) (* 0.87 h) :scale (fit-scale str (* 1.5 s) (* 0.94 w))
                   :align :center :color (if (eq row :rank) '(1 0.85 0.3 1) *dim-ink*) :shadow (eq row :rank))))))
  (ui-text "TAP LEFT / RIGHT: CHOOSE" (floor w 2) (- h (* 30 s)) :scale s :align :center :color *white* :shadow t)
  (ui-text "TAP THE MIDDLE: CONFIRM" (floor w 2) (- h (* 20 s)) :scale s :align :center :color *white* :shadow t))

(defun hud-select (w h s)
  (when (portrait-p) (return-from hud-select (hud-select-portrait w h s)))
  (ui-big-text "SELECT YOUR FIGHTER" (floor w 2) (* 0.09 h) (* 4 s) *white* '(0.7 0.25 0.05 1) s)
  (dolist (e (list *p1* *p2*))
    (let* ((side (fighter-side (fighter e))) (x (if (zerop side) (* 0.25 w) (* 0.75 w)))
           (active (= side (min 1 *select-phase*))) (cpu (or (eq *mode* :cpu-cpu) (and (= side 1) (vs-cpu-p)))))
      (ui-text (format nil "~a~a" (if (zerop side) "P1" "P2") (if cpu " CPU" "")) x (* 0.72 h) :scale (* 2 s) :align :center
               :color (if (zerop side) '(1 0.6 0.3 1) '(0.5 0.7 1 1)) :shadow t)
      (ui-text (format nil "~:[  ~;< ~]~a~:[  ~; >~]" (and active (< *select-phase* 2)) (kit-name (kit-of e)) (and active (< *select-phase* 2)))
               x (* 0.78 h) :scale (* 3 s) :align :center :color (if active *white* *dim-ink*) :shadow active)))
  (when (and (/= *select-phase* 0) (/= *select-phase* 1) (not (eq *mode* :vs-player)))
    (let* ((rows (select-rows)) (row (nth (mod *menu* (length rows)) rows)) (three (> (length rows) 2))
           (y (case (length rows) (1 0.88) (2 0.85) (t 0.845))) (dy (if three 0.035 0.05)))
      (dolist (r rows)                                  ; the difficulty, DANGAI's RANK, VS CPU's camera: up / down picks
        (let ((on (eq r row)))
          (ui-text (case r
                     (:difficulty (format nil "~a  < ~a >" (if (eq *mode* :endless) "START" "CPU") (symbol-name *difficulty*)))
                     (:rank (format nil "< ~a >" (nth *rogue-rank* *rogue-rank-names*)))
                     (t (format nil "< ~a >" (camera-label))))
                   (floor w 2) (* y h) :scale (* (if (or three (eq r :rank)) 1.5 2) s)   ; (three rows: all smaller)
                   :align :center :color (if on '(1 0.85 0.3 1) *dim-ink*) :shadow on))
        (incf y dy))))
  (ui-text (if (and (= *select-phase* 2) (> (length (select-rows)) 1))
               "UP / DOWN ROW    LEFT / RIGHT CHOOSE    ENTER / J CONFIRM    ESC BACK"
               "LEFT / RIGHT CHOOSE    ENTER / J CONFIRM    ESC BACK")
           (floor w 2) (- h (* 12 s)) :scale s :align :center :color *white* :shadow t))

(defun results-card (w h s)
  "Draw the black card of the RESULTS (the left panel; portrait the lower part) and of the endless STAGE CLEAR / run RESULTS
(endless.lisp), which lay their lines out on it. Values: its centre x, top y, width."
  (if (portrait-p)
      (let ((top (* 0.42 h)))
        (ui-rect 0 top w (- h top) '(0.031 0.031 0.047 0.94))
        (ui-rect 0 top w (max 1 (round s 2)) '(0.96 0.96 0.94 0.8))
        (values (* 0.5 w) (+ top (* 8 s)) w))
      (let* ((sc (max 1 (round (* 1.5 s)))) (px (* 0.04 w)) (pw (+ (* 28 s) (* 131 sc))))
        (ui-rect px 0 pw h '(0.031 0.031 0.047 0.94))
        (ui-rect (+ px pw) 0 (max 1 (round s 2)) h '(0.96 0.96 0.94 0.8))
        (values (+ px (* 0.5 pw)) (* 0.2 h) pw))))

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
the K.O.'s and TIME's, which are the Lisp HUD's; a frozen mode's screen; the battle's world overlays; the big words), then the Lisp
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
    (case (if (webui-on-screen-p) :web *flow*)         ; (:WEB: the Lisp menus' screen; the rest: the frozen modes' and the battle)
      (:select (hud-select w h s))                       ; ENDLESS's
      (:results (hud-endless-results w h s))             ; ENDLESS's run (endless.lisp)
      ((:battle :finish) (unless *cine* (hud-battle w h s) (when (and *one-hand* (portrait-p) (not *paused*)) (hud-stick))))
      (:clear (hud-endless-clear w h s))
      ((:doors :reward) (hud-rogue-doors w h s)))
    (draw-words w h)
    (paint-clock-advance) (lhud-draw) (lhud-canvas-grade!)   ; the Lisp HUD (lhud-battle.lisp) and the composite grade it asks for
    (lhud-menu-draw)                                      ; the Lisp menus (lhud-menu.lisp; after LHUD-DRAW's frame)
    (when *lhud-shapes* (lhud-shapes-card))               ; debug 2509: the paint shapes' test card (lhud-shapes.lisp)
    (debug-hud w h s)))
