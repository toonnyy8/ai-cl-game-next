;;;; hud-screens.lisp — every screen of the flow around the battle HUD (hud.lisp): the menus (HUD-MENU), controls, settings,
;;;; title, select (both orientations), the results card and table, the pause screen and the per-frame HUD entry
;;;; HUD-DRAW (which screen for *FLOW*, the battle HUD's sides, the debug overlay). Cosmetic only. Out of hud.lisp 2026-10-21.
(in-package :duel)

;;; ---------------------------------------------------------------- screens
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

(defun hud-controls (w h s)
  "CONTROLS (the user, 2026-10-01): each action's key and pad button for P1 and P2, the selected cell lit (blinking
while it waits for a key), then RESET DEFAULTS and BACK; the fixed combinations and the help below."
  (ui-rect 0 0 w h '(0 0 0 0.7))
  (ui-big-text "CONTROLS" (floor w 2) (* 0.08 h) (* 4 s) *white* '(0.7 0.25 0.05 1) s)
  (let* ((n (length *bind-actions*)) (dy (* 12 s)) (y0 (* 0.2 h)) (cols (list (* 0.42 w) (* 0.54 w) (* 0.68 w) (* 0.8 w)))
         (wait (and *capture* (< (mod (fx-clock) 0.6) 0.4))))
    (loop for t1 in '("P1 KEY" "P1 PAD" "P2 KEY" "P2 PAD") for x in cols
          do (ui-text t1 (round x) (- y0 dy) :scale s :align :center :color '(1 0.85 0.3 1)))
    (loop for a in *bind-actions* for label in *bind-row-names* for i from 0 for y = (+ y0 (* i dy))
          do (ui-text label (round (* 0.34 w)) y :scale s :align :right :color (if (= i *menu*) *white* *dim*))
             (loop for x in cols for c from 0
                   for sel = (and (= i *menu*) (= c *bind-col*))
                   for txt = (if (and sel *capture*) (if (evenp c) "PRESS A KEY" "PRESS A BUTTON")
                                 (bind-label (binding-name (svref *bind-pair* (floor c 2)) a (if (evenp c) :key :pad))))
                   do (when (and sel (not (and *capture* (not wait))))
                        (ui-rect (- x (* 0.055 w)) (- y (* 2 s)) (* 0.11 w) (* 11 s) '(0.8 0.3 0.05 0.8)))
                      (ui-text txt (round x) y :scale (fit-scale txt s (* 0.11 w)) :align :center :color *white*)))
    (loop for it in '("RESET DEFAULTS" "BACK") for i from n for y = (+ y0 (* (+ i 0.4) dy))
          do (when (= i *menu*)
               (ui-rect (- (* 0.5 w) (* 0.12 w)) (- y (* 2 s)) (* 0.24 w) (* 11 s) '(0.8 0.3 0.05 0.8)))
             (ui-text it (floor w 2) y :scale s :align :center :color *white*)))
  (let ((help (if *capture* "PRESS THE NEW KEY OR BUTTON    ESC / START: CANCEL"
                  "UP / DOWN: ACTION    LEFT / RIGHT: COLUMN    ENTER: CHANGE    ESC: BACK"))
        (combos "SP1 = REIATSU+FLASH   SP2 = REIATSU+SIGNATURE   HOHO = REIATSU+STEP   BURST = REIATSU+QUICK   DASH = HOLD STEP   PAUSE = ESC / START"))
    (ui-text combos (floor w 2) (- h (* 34 s)) :scale (fit-scale combos s (* 0.96 w)) :align :center :color *dim*)
    (ui-text help (floor w 2) (- h (* 20 s)) :scale (fit-scale help s (* 0.96 w)) :align :center :color *ember* :shadow t)))

(defun hud-settings (w h s)
  "SETTINGS: the rows (confirm, left / right or a tap changes one), BACK, the selected row's note and the help line."
  (ui-big-text "SETTINGS" (floor w 2) (* 0.2 h) (fit-scale "SETTINGS" (* 6 s) (* 0.8 w)) '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s)
  (hud-menu (settings-items) (if (portrait-p) 0.46 0.36) w h s (/ w 2) (/ (- h (* 38 s)) h))   ; above the note (7 rows since PERFECT HINT)
  (let ((note (settings-note)) (help (if (touch-tap-zones-p) "TAP A ROW TO CHANGE IT" "LEFT / RIGHT CHANGE    ESC BACK")))
    (ui-text note (floor w 2) (- h (* 34 s)) :scale (fit-scale note s (* 0.94 w)) :align :center :color *ember* :shadow t)
    (ui-text help (floor w 2) (- h (* 20 s)) :scale (fit-scale help s (* 0.94 w)) :align :center :color *dim* :shadow t)))

(defun hud-title (w h s)
  (ui-big-text "SOUL DUEL" (floor w 2) (* 0.34 h) (* 9 s) '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s)
  (when (portrait-p)                                    ; portrait: the credit on two lines
    (when (< (mod (fx-clock) 1.2) 0.8)
      (ui-text "TAP TO START" (floor w 2) (* 0.68 h) :scale (* 2 s) :align :center :color *white* :shadow t))
    (ui-text "A FAN STUDY INSPIRED BY" (floor w 2) (- h (* 30 s)) :scale s :align :center :color '(0.93 0.93 0.96 1) :shadow t)
    (ui-text "BLEACH: REBIRTH OF SOULS" (floor w 2) (- h (* 20 s)) :scale s :align :center :color '(0.93 0.93 0.96 1) :shadow t)
    (return-from hud-title))
  (when (< (mod (fx-clock) 1.2) 0.8)
    (ui-text "PRESS START" (floor w 2) (* 0.68 h) :scale (* 2 s) :align :center :color *white* :shadow t))
  (ui-text "A FAN STUDY INSPIRED BY BLEACH: REBIRTH OF SOULS" (floor w 2) (- h (* 16 s)) :scale s :align :center
           :color '(0.93 0.93 0.96 1) :shadow t))

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

(defparameter *results-rows* '("DAMAGE" "KIKONS" "PERFECT HOHOS" "BEST COMBO" "KONPAKU LEFT"))
(defvar *results-cache* (cons nil nil) "(match-tick . strings) of the results table, made once per match.")

(defvar *results-cap* (make-bcap "勝" :layout :results) "The results screen's 勝 stamp (white on the black card).")

(defun results-strings ()
  "The results table's strings: #(winner-line p1-values p2-values time-line), cached per match."
  (let ((c *results-cache*))
    (unless (eql (car c) *match-tick*)
      (flet ((values-of (e)
               (let ((g (gauges e)))
                 (mapcar (lambda (n) (format nil "~d" n))
                         (list (gauges-dealt g) (gauges-kikons g) (gauges-perfects g) (gauges-best-combo g) (gauges-konpaku g))))))
        (bcap-restart *results-cap*)                           ; a new result: the 勝 stamps in again
        (setf (car c) *match-tick*
              (cdr c) (vector (case *winner* (0 (format nil "~a  (P1)" (kit-name (kit-of *p1*))))
                                            (1 (format nil "~a  (P2)" (kit-name (kit-of *p2*)))))
                              (values-of *p1*) (values-of *p2*)
                              (format nil "~d S" (round (match-play-ticks) 60))))))
    (cdr c)))

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

(defun hud-results-portrait (w h s)
  "RESULTS on a tall screen: the winner in the top part (main.lisp MENU-CAMERA) under the 勝 stamp at the left, a black
card over the lower part with the winner's name, the stats table and the menu."
  (let* ((rs (results-strings)) (sc (max s (fit-scale "PERFECT HOHOS  00000  00000" (round (* 1.5 s)) (* 0.9 w)))) (row (* 11 sc))
         (top (* 0.42 h)) (cx (* 0.5 w)))
    (results-card w h s)
    (if (svref rs 0)
        (let ((c *results-cap*))
          (setf (aref (bcap-f c) 6) 0.2f0)
          (draw-bcap c w h)
          (hud-text (svref rs 0) cx (+ top (* 6 s)) (fit-scale (svref rs 0) (* 2 s) (* 0.92 w)) *white* :align :center))
        (brush-text "DRAW" cx (* 0.12 h) (* 0.13 h) *white*))
    (let* ((y0 (+ top (* 16 s))) (lx (* 0.06 w)) (c2 (* 0.9 w)) (c1 (- c2 (* 30 sc))))
      (hud-text "P1" c1 y0 sc '(1 0.6 0.3 1) :align :center)
      (hud-text "P2" c2 y0 sc '(0.5 0.7 1 1) :align :center)
      (loop for label in *results-rows* for a in (svref rs 1) for b in (svref rs 2) for i from 1
            for y = (+ y0 (* i row)) do
              (when (oddp i) (ui-rect 0 (- y (* 2 s)) w (+ row (* -2 s)) '(1 1 1 0.05)))
              (hud-text label lx y sc *dim*)
              (hud-text a c1 y sc *white* :align :center)
              (hud-text b c2 y sc *white* :align :center))
      (hud-text "TIME" lx (+ y0 (* 6 row)) sc *dim*)
      (hud-text (svref rs 3) (* 0.5 (+ c1 c2)) (+ y0 (* 6 row)) sc *white* :align :center))
    (when (> *ft* 2.5) (hud-menu *results-menu* 0.8 w h s cx))))

(defun hud-results (w h s)
  "RESULTS: a panel in the left part of the screen (the winner model stays visible on the right):
WINNER + name, the stats table (P1 / P2 columns), the match time, the menu."
  (when (eq *mode* :endless) (return-from hud-results (hud-endless-results w h s)))   ; the run's results (endless.lisp)
  (when (portrait-p) (return-from hud-results (hud-results-portrait w h s)))
  (let* ((rs (results-strings)) (sc (max 1 (round (* 1.5 s)))) (row (* 11 sc))
         (px (* 0.04 w)) (pw (+ (* 28 s) (* 131 sc))) (cx (+ px (* 0.5 pw))))   ; fits "PERFECT HOHOS" + 2 columns
    (results-card w h s)                                         ; a black card (§4.4)
    (if (svref rs 0)
        (let ((c *results-cap*))                                 ; the big brush 勝 replaces WINNER
          (setf (aref (bcap-f c) 6) (f32 (/ cx w)))
          (draw-bcap c w h)
          (hud-text (svref rs 0) cx (* 0.29 h) (fit-scale (svref rs 0) (* 2 s) (- pw (* 8 s))) *white* :align :center))
        (brush-text "DRAW" cx (* 0.12 h) (* 0.13 h) *white*))
    (let* ((y0 (* 0.36 h)) (lx (+ px (* 10 s))) (c1 (+ px (* 18 s) (* 89 sc))) (c2 (+ c1 (* 30 sc))))
      (hud-text "P1" c1 y0 sc '(1 0.6 0.3 1) :align :center)
      (hud-text "P2" c2 y0 sc '(0.5 0.7 1 1) :align :center)
      (loop for label in *results-rows* for a in (svref rs 1) for b in (svref rs 2) for i from 1
            for y = (+ y0 (* i row)) do
              (when (oddp i) (ui-rect px (- y (* 2 s)) pw (+ row (* -2 s)) '(1 1 1 0.05)))
              (hud-text label lx y sc *dim*)
              (hud-text a c1 y sc *white* :align :center)
              (hud-text b c2 y sc *white* :align :center))
      (hud-text "TIME" lx (+ y0 (* 6 row)) sc *dim*)
      (hud-text (svref rs 3) (* 0.5 (+ c1 c2)) (+ y0 (* 6 row)) sc *white* :align :center))
    (when (> *ft* 2.5) (hud-menu *results-menu* 0.72 w h s cx))))

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

(defun hud-draw ()
  "The UI of this frame, by screen."
  (let* ((w (window-width)) (h (window-height)) (s (ui-scale)) (f *ui-flash*))
    (fill *panel-box* 0f0)                               ; HUD-SIDE sets them when the panels are drawn
    (aura-cap-update)
    (when (> (aref f 3) 0)
      (let ((c *c-flash*))
        (setf (first c) (aref f 0) (second c) (aref f 1) (third c) (aref f 2) (fourth c) (aref f 3))
        (ui-rect 0 0 w h c))
      (countdown! (aref f 3) (* (aref f 4) (hud-dt))))
    (draw-screen-fx w h)                                 ; focus lines (under the HUD)
    (when *cine*                                         ; letterbox + the cinematic's brush title
      (ui-rect 0 0 w (* 0.09 h) '(0 0 0 1)) (ui-rect 0 (* 0.91 h) w (* 0.09 h) '(0 0 0 1))
      (when *caption* (unless (draw-bcap *caption* w h) (setf *caption* nil))))
    (when *caption-out* (unless (draw-bcap *caption-out* w h) (setf *caption-out* nil)))   ; an ended cinematic's title
    (case *flow*
      (:title (hud-title w h s))
      (:mode (ui-big-text "SOUL DUEL" (floor w 2) (* 0.2 h) (fit-scale "SOUL DUEL" (* 6 s) (* 0.8 w)) '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s)
       (hud-menu *mode-menu* (if (portrait-p) 0.52 0.42) w h s))   ; portrait: lower, toward the thumb
      (:settings (hud-settings w h s))
      (:controls (if (one-hand-offered-p) (hud-gestures w h s) (hud-controls w h s)))
      (:select (hud-select w h s))
      ((:battle :finish) (unless *cine* (hud-battle w h s) (when (and *one-hand* (portrait-p) (not *paused*)) (hud-deck s))))
      (:results (hud-results w h s))
      (:clear (hud-endless-clear w h s))
      ((:doors :reward) (hud-rogue-doors w h s)))
    (draw-words w h)
    (when (and *paused* (eq *flow* :battle))
      (ui-rect 0 0 w h '(0 0 0 0.55))
      (if (and *one-hand* (not (portrait-p)))
          (ui-big-text "ROTATE TO PORTRAIT" (floor w 2) (* 0.3 h) (fit-scale "ROTATE TO PORTRAIT" (* 4 s) (* 0.9 w)) *white* '(0.7 0.25 0.05 1) s)
          (ui-big-text "PAUSED" (floor w 2) (* 0.3 h) (* 5 s) *white* '(0.7 0.25 0.05 1) s))
      (hud-menu (pause-items) (if (eq *mode* :practice) 0.4 0.45) w h s (/ w 2) 0.9))   ; PRACTICE's long list: above P1's block
    (debug-hud w h s)))
