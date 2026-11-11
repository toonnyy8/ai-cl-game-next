;;;; lhud-battle.lisp — the battle HUD drawn by Lisp (docs/duel/DUEL_LISP_HUD.md): the frame's layout and the order of the elements
;;;; (LHUD-DRAW: first every element's system, from the model, then the views back to front as hud.css stacks them), the atlas's
;;;; load step, and debug 2518's legibility card and phase 1c rows. The elements live in their own files: lhud-plate.lisp (the plates),
;;;; lhud-deck.lisp (the phone's deck, 爆, the stance ring, the clock tab), lhud-fx.lisp (the combo, the move name, the prompt, the
;;;; touch ink, the layers' fades); the model's access and the palette in lhud-model.lisp, the tables in lhud-data.lisp, the pure
;;;; geometry in lhud-geom.lisp. Phase 2 built the handheld portrait battle screen (and the desktop plates and combos); phases 3-4 the
;;;; landscape screen and the overlays (lhud-clock.lisp, lhud-overlay.lisp: the pause, the intro card, READY / 斬, the finish); the
;;;; menus are lhud-menu*.lisp (DUEL_LISP_HUD §5, §13-§16). The look reproduces the HTML HUD as it was at main 562acb37 (hud.js,
;;;; hud.css: `git show 562acb37:duel/web/hud.css`), removed 2026-11-11; the hud.js / hud.css names below point into that version.
;;;; Cosmetic, outside the sim step; 0 B a frame in steady state (debug 2519).
(in-package :duel)

(defvar *lhud-still* nil "Debug 2518: the Lisp HUD's still mode (phase 0: the legibility card).")
;;; (the tables and string tags: lhud-data.lisp; the palette, F-FLOOR+, TW: lhud-model.lisp)

;;; ---------------------------------------------------------------- units
(defmacro lhud-units ((w h u st dpr phone) &body body)
  "Bind the frame's device-pixel sizes: W H the window, U the battle unit (min(1vw, 1.7778vh); portrait 2.36vw), ST the safe top,
DPR the pixel density, PHONE portrait (hud.js's hphone)."
  `(let* ((,w (i->f (window-width))) (,h (i->f (window-height))) (,phone (> ,h ,w))
          (,dpr (ffi:c-inline () () :float "pf_density()" :one-liner t))
          (,u (if ,phone (* 0.0236f0 ,w) (f-min (* 0.01f0 ,w) (* 0.017778f0 ,h))))
          (,st (* ,dpr (i->f *safe-top*))))
     (declare (single-float ,w ,h ,u ,st ,dpr) (ignorable ,w ,h ,u ,st ,dpr ,phone))
     ,@body))

(defmacro line-a (face size lh)
  "The baseline's depth in a line box: half-leading + ascent (CSS), SIZE px, line-height LH (a ratio)."
  `(let ((sz ,size) (asc (face-ascent ,face)) (dsc (face-descent ,face)))
     (declare (single-float sz asc dsc))
     (+ (* 0.5f0 sz (- ,lh (+ asc dsc))) (* asc sz))))

;;; ---------------------------------------------------------------- the legibility card (debug 2518, phase 0's question)
(defparameter *lhud-card*
  ;; face, size (CSS px; < 0: -k = k / 100 u), string — the smallest sizes the HTML uses (DUEL_LISP_HUD §5 phase 0)
  (list (list +f-mono+ -62 (zh "ROUND · 決闘  0123456789"))                    ; the clock's caption, .62u
        (list +f-mono+ -72 "SHIKAI · BUNSHIN x3 · KAIHO L2")                   ; the plate's tag, .72u
        (list +f-mono+ 10 "PRESS J · CONFIRM   ESC · BACK   KEYS / PAD")      ; the menus' crumbs and hints, 10 px
        (list +f-sans+ 11 (zh "在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。"))   ; CONTROLS' phone page, 11 px
        (list +f-sans+ 12 (zh "鏡 鍵 鐮 觸 覺 鬥：最密的字，12 px 的說明文字。"))
        (list +f-sans+ -95 (zh "繼續 重來 放棄 換角色 回到標題 假人反擊"))         ; the pause rows' zh, .95u
        (list +f-kanji+ -95 (kj "鏡鍵鐮觸覺鬥 綴雷電 月牙天衝"))                ; the tag's kanji, .95u
        (list +f-kanji+ -125 (kj "更木 黒崎 檜佐木 鏡鍵鐮觸覺鬥"))))           ; the plates' kanji, 1.25u

(defun lhud-card-size (sz u dpr) (if (< sz 0) (* u (/ (- sz) 100f0)) (* dpr sz)))

(defun lhud-card ()
  "Debug 2518's card: each row of *LHUD-CARD* on an ink panel at 24 CSS px from the left, from 30 % of the height, a row every
1.9 em (line-height 1). tests: the same rows in HTML (build/lhud/ref, DUEL_LISP_HUD §8)."
  (lhud-units (w h u st dpr phone)
    (let* ((x (* 24f0 dpr)) (y (* 0.3f0 h)) (y0 y))
      (paint-reset)
      (paint-rect (* 12f0 dpr) (- y0 (* 12f0 dpr)) (- w (* 24f0 dpr)) (* 0.42f0 h) +c-card+)
      (dolist (row *lhud-card*)
        (destructuring-bind (face sz s) row
          (let ((size (f32 (lhud-card-size sz u dpr))))
            (paint-pen! (f32 (round x)) (f32 (round (+ y (line-a face size 1f0)))) size)
            (paint-text s face +c-paper+)
            (setf y (+ y (* 1.9 size)))))))))

;;; ---------------------------------------------------------------- the card's phase 1c rows (debug 2518): layout, text, tween, hot boxes
;;; Beside the card's rows on a desktop, under them in portrait: a wrapped zh paragraph (kinsoku), the handheld screen's pointer seals
;;; (hud.js FIGHTERS: Kenpachi's 「拖 · DRAG」 「肩 · SHOULDER」 「構 · CHUDAN」, a Mincho kanji and a letter-spaced mono word on one
;;; baseline, end-aligned), a vertical column (CJK upright, Latin turned), a tabular clock that pops (hd-stamp restarted by its value)
;;; and hover boxes (the mouse). 0 B a frame (debug 2519's "demo").
(defparameter *lhud-demo-para* (zh "在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。"))
(defparameter *lhud-demo-v* (kj "月牙天衝"))
(defparameter *lhud-demo-seals* (list (cons (kj "拖") " · DRAG") (cons (kj "肩") " · SHOULDER") (cons (kj "構") " · CHUDAN"))
  "The handheld screen's pointer seals of Kenpachi's sealed form (hud.js FIGHTERS ptr): (kanji . the rest).")
(defparameter *lhud-stamp* (make-tween '((0 nil 1.5 -6) (1 nil 1 0)) :dur 0.24 :curve +ease-snap+ :base '(1 0))
  "hd-stamp (hud.css): .24 s ease-snap from scale 1.5, rotate -6deg.")
(defvar *lhud-demo-st* (make-tween-slots 1)) (defvar *lhud-demo-se* (nth-value 1 (make-tween-slots 1)))
(declaim (type f32vec *lhud-demo-st*) (type (simple-array fixnum (*)) *lhud-demo-se*))

(defun-fast lhud-card-demo ()
  "The card's phase 1c rows (see above), placed with layout.lisp from the frame LHUD-FRAME set."
  (let* ((now (aref *ui-clock* 0)) (pen *paint-pen*) (dpr (lay-dpr)) (u (lay-u 1f0))
         (x (if (lay-portrait-p) (lay-css 24f0) (* 0.52f0 (lay-w))))
         (y (if (lay-portrait-p) (+ (* 0.3f0 (lay-h)) (* 16.5f0 u)) (* 0.3f0 (lay-h))))   ; (portrait: under the card's rows)
         (pw (if (lay-portrait-p) (lay-css 150f0) (lay-css 168f0)))   ; the paragraph's width
         (hov (hot-hit (mouse-x) (mouse-y))) (sec (fl-floor now)))
    (declare (single-float now dpr u x y pw) (fixnum hov sec))
    (paint-reset)
    (macrolet ((hot (id x0 y0 x1 y1)                      ; register a hot box; the hovered one gets a stone frame
                 `(let* ((%x0 ,x0) (%y0 ,y0) (%x1 ,x1) (%y1 ,y1)
                         (%cx (* 0.5f0 (+ %x0 %x1))) (%cy (* 0.5f0 (+ %y0 %y1))) (%hw (* 0.5f0 (- %x1 %x0))) (%hh (* 0.5f0 (- %y1 %y0))))
                    (declare (single-float %x0 %y0 %x1 %y1 %cx %cy %hw %hh))
                    (hot-add ,id %x0 %y0 %x1 %y1)
                    (when (= hov ,id) (paint-box! %cx %cy %hw %hh dpr 1f0 dpr +c-stone+)))))
      ;; 1. a wrapped paragraph, 11 CSS px, line-height 1.6
      (paint-pen! (f-floor+ x) (f-floor+ y) (lay-css 11f0))
      (paint-paragraph *lhud-demo-para* +f-sans+ +c-paper+ :width pw :lh 1.6f0)
      (hot 1 x y (+ x pw) (+ y (aref pen 7)))
      (setf y (+ y (aref pen 7) (lay-css 10f0)))
      ;; 2. the handheld seals: kanji .78u + " · " + the mono word .78u, .16em spaced, end-aligned at the paragraph's right edge,
      ;;    a row every 1.3 em; ATK (display, 1.6u, .3em spaced) on the first row's baseline at the left
      (let* ((kz (* 0.78f0 u)) (mz (* 0.78f0 u)) (right (+ x pw)) (y1 y))
        (declare (single-float kz mz right y1))
        (dolist (lab *lhud-demo-seals*)
          (let ((base (f-floor+ (+ y1 (line-baseline +f-kanji+ kz 1f0)))) (w 0f0))
            (declare (single-float base w))
            (paint-pen! 0f0 0f0 mz :spacing 0.16f0) (paint-measure (cdr lab) +f-mono+) (setf w (aref pen 7))
            (paint-pen! (f-floor+ (- right w)) base kz) (paint-text-aligned (car lab) +f-kanji+ +c-paper+ :end)
            (paint-pen! (f-floor+ (- right w)) base mz :spacing 0.16f0) (paint-text (cdr lab) +f-mono+ +c-stone+)
            (setf y1 (+ y1 (* 1.3f0 kz)))))
        (paint-pen! (f-floor+ x) (f-floor+ (+ y (line-baseline +f-kanji+ kz 1f0))) (* 1.6f0 u) :spacing 0.3f0)
        (paint-text "ATK" +f-display+ +c-steel+)
        (hot 2 x y right (f-max y1 (+ y (* 1.6f0 u))))
        (setf y (+ (f-max y1 (+ y (* 1.6f0 u))) (* 0.6f0 u))))
      ;; 3. the clock: tabular digits, 4.3u display, popping (hd-stamp) at each new second; PAUSE spaced .3em beside
      (let* ((cz (* 4.3f0 u)) (base (f-floor+ (+ y (line-baseline +f-display+ cz 1f0)))))
        (declare (single-float cz base))
        (tween-watch *lhud-demo-st* *lhud-demo-se* 0 sec now)
        (paint-pen! 0f0 0f0 cz) (paint-measure-int-tab 99 +f-display+ 2)
        (let* ((cw (aref pen 7)) (st (aref *lhud-demo-st* 0)) (sc (tween-value *lhud-stamp* st now 0))
               (rot (* 0.017453f0 (tween-value *lhud-stamp* st now 1))))
          (declare (single-float cw st sc rot))
          (paint-xform! (+ x (* 0.5f0 cw)) (- base (* 0.35f0 cz)) sc sc rot 0f0 0f0)
          (paint-pen! x base cz) (paint-int-tab (mod sec 100) +f-display+ +c-paper+ 2)
          (paint-reset)
          (paint-pen! (f-floor+ (+ x cw (* 0.8f0 u))) base (* 0.95f0 u) :spacing 0.3f0) (paint-text "PAUSE" +f-mono+ +c-steel+)
          (hot 3 x y (+ x cw) (+ y cz)))
        (setf y (+ y (* 5f0 u))))
      ;; 4. a vertical column at the right: 月牙天衝 upright, then K.O. turned (writing-mode: vertical-rl), 2.4u
      (let* ((vz (* 2.4f0 u)) (vx (+ x pw (if (lay-portrait-p) (lay-css 40f0) (lay-css 60f0)))) (vy (if (lay-portrait-p) (- y (* 9.2f0 u)) (* 0.3f0 (lay-h)))))
        (declare (single-float vz vx vy))
        (paint-pen! vx vy vz :spacing 0.08f0) (paint-vertical *lhud-demo-v* +f-kanji+ +c-paper+)
        (paint-pen! vx (+ (aref pen 1) (* 0.4f0 vz)) (* 0.6f0 vz) :spacing 0.3f0) (paint-vertical "K.O." +f-mono+ +c-blood+)
        (hot 4 (- vx (* 0.5f0 vz)) vy (+ vx (* 0.5f0 vz)) (aref pen 1))))
    nil))

(defvar *lhud-win* (make-array 4 :element-type 'fixnum :initial-element -1)
  "The window LHUD-FRAME last asked the page about (width, height) and its answers: the left / right safe-area insets (CSS px).")
(declaim (type (simple-array fixnum (*)) *lhud-win*))
(defun-fast lhud-frame ()
  "This frame's layout (layout.lisp): the window, the density, the four safe-area insets (top / bottom as DECK-UPDATE keeps them, left /
right page get 5 / 6) and reduced motion (page get 7, DUEL_LISP_HUD §4.4), the page asked again only when the window's size changed;
the hot boxes start over (LHUD-DRAW)."
  (let ((k *lhud-win*) (w (window-width)) (h (window-height)))
    (declare (fixnum w h))
    (unless (and (= w (aref k 0)) (= h (aref k 1)))
      (setf (aref k 0) w (aref k 1) h (aref k 2) (page-get 5) (aref k 3) (page-get 6) *reduced-motion* (= 1 (page-get 7))))
    (layout-frame! (i->f w) (i->f h) (ffi:c-inline () () :float "pf_density()" :one-liner t)
                   (i->f *safe-top*) (i->f *safe-bot*) (i->f (aref k 2)) (i->f (aref k 3))))
  (hot-begin-frame)
  nil)

;;; ---------------------------------------------------------------- every frame
(defun-fast lhud-systems (fresh)
  "Every element's system, once a frame before any view: the model's derived strings, then each element's state from the model at
the UI clock (the only mutation of the Lisp HUD outside the paint stream's buffers, and *GRADE-DESAT*: LHUD-LAYERS-UPDATE)."
  (lhud-model-update)
  (lhud-layers-update fresh)
  (lhud-plate-update 0) (lhud-plate-update 1)
  (lhud-combo-update 0) (lhud-combo-update 1)
  (lhud-callout-update 0) (lhud-callout-update 1)
  (lhud-prompt-update)
  (lhud-deck-update)
  (lhud-clock-update)
  (lhud-fx-update)
  (lhud-intro-update fresh)
  (lhud-finish-update)
  (lhud-pause-update)
  nil)

(defvar *lhud-v0* (make-array 1 :element-type 'fixnum :initial-element 0) "V0 at the last LHUD-DRAW (its battle bit off: the next frame is fresh).")
(declaim (type (simple-array fixnum (*)) *lhud-v0*))
(defun lhud-draw ()
  "The Lisp HUD of this frame (HUD-DRAW, after it advanced the UI clock) while a battle is up (V0 bit 1): the
systems, then the views back to front as hud.css stacks them: the paused scene's dimming (the canvas filter), the deck (z 9), .hudl
(z 10: the plates, the clock, the move names, the combos, the prompt; .3 paused, out in a cinematic), 爆 and the stance ring (z 14),
the touch ink (z 15), the intro card and the finish (z 18), READY / 斬 (z 19), the pause (z 20)."
  (let* ((v0 (aref *hud-sent* 0)) (phone (> (window-height) (window-width))) (deck (and phone (logtest v0 8)))
         (fresh (not (logtest (aref *lhud-v0* 0) 1))))
    (declare (fixnum v0))
    (setf (aref *lhud-v0* 0) v0)
    (lhud-frame)
    (when (logtest v0 1)
      (lhud-systems fresh)
      (lhud-dim)
      (when deck (lhud-deck))
      (when (> (layer-op 0) 0.002f0)
        (if deck (lhud-plate-line) (lhud-plate 0))
        (lhud-plate 1))
      (lhud-clock)
      (lhud-callout 0) (lhud-callout 1)
      (lhud-combo 0) (lhud-combo 1)
      (lhud-prompt)
      (when deck (lhud-dial) (lhud-ring) (lhud-fx))
      (lhud-intro) (lhud-finish) (lhud-ready) (lhud-pause))
    (when *lhud-still* (lhud-card) (lhud-card-demo))
    nil))

(defun lhud-init ()
  "The baked atlas (duel/hud-font, tools/sdf-bake.py): its metrics into the glyph table, its texels to the GPU (a :LOAD step)."
  (let ((n (ffi:c-inline () () :int "{ int n; lhud_font(1, &n); @(return) = n; }")))
    (when (plusp n)
      (let ((m (make-array n :element-type '(unsigned-byte 8))))
        (ffi:c-inline (m n) (t :int) :void "{ int k; memcpy(#0->vector.self.b8, lhud_font(1, &k), #1); }")
        (multiple-value-bind (aw ah) (paint-font-init m)
          (unless (ffi:c-inline (aw ah) (:int :int) :bool "{ int k; @(return) = r_hud_atlas_new(lhud_font(0, &k), #0, #1); }")
            (log-msg "lhud: the atlas texture failed")))))))
(ffi:clines "const unsigned char *lhud_font(int k, int *n);   /* duel/hud-font/lhud-font.c: 0 the atlas, 1 the metrics */")
