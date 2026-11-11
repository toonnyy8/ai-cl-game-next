;;;; lhud-menu.lisp — the menus drawn by Lisp (docs/duel/DUEL_LISP_HUD.md §15, phases 5-6): the frame (LHUD-MENU-DRAW: the systems,
;;;; then the screen's view, the rails and the cut), the backdrop (menu.css #ui .wash over the scene; SELECT's #ui-back world in the
;;;; back layer), the rails (the mark, the crumb, the hints), the cut between screens, the pointer (hot boxes -> menu.js's commands
;;;; through webui.lisp's queue), the input kind (keys / pad / touch, menu.js's own
;;;; state), and the devices every screen shares: the brush behind a focused row, the red seal, the torn paper, the skewed option
;;;; slab, the key cap. The screens: lhud-menu-front.lisp (TITLE, MODE, RESULTS), lhud-menu-set.lisp (SETTINGS, CONTROLS),
;;;; lhud-menu-select.lisp (SELECT); the tables lhud-menu-data.lisp; the pure layout lhud-menu-geom.lisp. The look reproduces the HTML
;;;; menus as they were at main 562acb37 (menu.js, menu.css: `git show 562acb37:duel/web/menu.css`), removed 2026-11-11.
;;;; The model is webui.lisp's *UI-SENT* (V k, the 30000 block, DUEL_WEBUI §3), the one thing the views read of the game; each screen
;;;; keeps its component state (focus transitions, animation starts) in its own vectors, changed only by its system. Sizes are menu.css's
;;;; CSS px times the density (LAY-CSS). Cosmetic, outside the sim step; 0 B a frame in steady state (debug 2519's menus line).
(in-package :duel)

;;; ---------------------------------------------------------------- the model, the palette (menu.css literals), the faces' weights
(defmacro uv (k) "The menus' model value V K (webui.lisp *UI-SENT*: 30000 + K on the page)." `(aref (the (simple-array fixnum (*)) *ui-sent*) ,k))
(defparameter +c-cap-line+ (rgba #x3a3f4e)) (defparameter +c-cap-bg+ (rgba #x11131a)) (defparameter +c-rule+ (rgba #x23262f))
(defparameter +c-card-bg+ (rgba #x10121a)) (defparameter +c-card-foc+ (rgba #x191c26)) (defparameter +c-ptr-bg+ (rgba #x12141c))
(defparameter +c-lm-dim+ (rgba #x4b5162)) (defparameter +c-paper-eye+ (rgba #x6a7182)) (defparameter +c-tag-line+ (rgba #xb3b8c3))
(defparameter +c-desc+ (rgba #x2b2f3a)) (defparameter +c-ptrs-bg+ (rgba #x2b2f3c)) (defparameter +c-emb-foc+ (rgba #x2f3443))
(defparameter +c-world0+ (rgba #x222634))
(defparameter +c-press-line+ (rgba #xeeeeea 0.22)) (defparameter +c-paper-dot+ (rgba #x0b0b10 0.09))
(defparameter +c-seal-hi+ (rgba #xffffff 0.12)) (defparameter +c-set-wash+ (rgba #xeeeeea 0.06)) (defparameter +c-set-wash0+ (rgba #xeeeeea 0f0))
(defparameter +c-bind-foc+ (rgba #xeeeeea 0.07)) (defparameter +c-ink0+ (rgba #x0b0b10 0f0)) (defparameter +c-paper0+ (rgba #xeeeeea 0f0))
(defparameter +c-tone+ (rgba #xbcc1cc 0.16)) (defparameter +c-tone0+ (rgba #xbcc1cc 0f0))
;; SDF edges for the CSS weights each face is not baked at (the bake: display 900, mono 600, Mincho 800, sans 500; lower = bolder)
(defconstant +ed8+ 0.53f0) (defconstant +ed7+ 0.56f0) (defconstant +em4+ 0.55f0) (defconstant +es4+ 0.525f0) (defconstant +ek6+ 0.55f0)

;;; ---------------------------------------------------------------- the float lane and small text helpers (macros: no float crosses a call)
(declaim (type f32vec *lm-a* *lm-pts*))
(defvar *lm-a* (make-f32 16) "The menu views' float arguments (LM-LANE!) and results.")
(defvar *lm-pts* (make-f32 144) "Polygon scratch (72 points) for the torn paper, the brush, the slabs.")
(defmacro lm-lane! (&rest vals)
  (let* ((v (gensym "V"))) `(let* ((,v *lm-a*)) (setf ,@(loop for x in vals for i from 0 when x append `((aref ,v ,i) ,x))))))
(defmacro lma (i) `(aref *lm-a* ,i))
(defmacro lm-set! (vec &rest vals)
  "Store VALS into the f32vec VEC from index 0 (paint.lisp's %F32-SET for the menus: the points of a polygon or a stroke)."
  (let* ((v (gensym "V"))) `(let* ((,v ,vec)) (setf ,@(loop for x in vals for i from 0 append `((aref ,v ,i) ,x))))))
(defmacro css (k) "K CSS px (a single-float form) in device px." `(lay-css ,k))
(defconstant +wd8+ 0.94f0 "Big Shoulders Display's width at 800 against the baked 900 (Chrome's 800 runs about 6 % narrower: the rows,
the labels; measured on MODE's rows, VS CPU 136 vs 145 px at 54 px): such text is drawn condensed by this.")
(defconstant +wd7+ 0.9f0 "The same at 700 (CONTROLS' bindings).")
(defmacro lm-text (s face col x base size &key (spacing 0f0) (edge 0.5f0) (align :start))
  "Draw S with its baseline at BASE, from X (ALIGN :start / :center / :end), SIZE px, letter SPACING (em), the SDF EDGE (weight);
the display face at 800 / 700 condensed (+WD8+ / +WD7+) about X."
  (let* ((k (and (eq face '+f-display+) (case edge (+ed8+ '+wd8+) (+ed7+ '+wd7+)))))
    (if k
        `(let* ((%x ,x)) (declare (single-float %x))
           (paint-push) (paint-transform! %x 0f0 :sx ,k)
           (paint-pen! %x ,base ,size :spacing ,spacing :edge ,edge) (paint-text-aligned ,s ,face ,col ,align)
           (paint-pop))
        `(progn (paint-pen! ,x ,base ,size :spacing ,spacing :edge ,edge) (paint-text-aligned ,s ,face ,col ,align)))))
(defmacro lm-dw (s size spacing &optional (k '+wd8+)) "The width of display text S at 800 (condensed by K)." `(* ,k (text-w ,s +f-display+ ,size ,spacing)))
(defmacro lm-base (top face size lh) "The baseline of a CSS line box at TOP (line-height LH)." `(+ ,top (line-baseline ,face ,size ,lh)))

;;; ---------------------------------------------------------------- the layout's scratch (lhud-menu-geom.lisp, CSS px)
(declaim (type f32vec *lm-g* *lm-g2*))
(defvar *lm-g* (make-f32 32) "The screen's boxes from lhud-menu-geom.lisp (CSS px; [0..3] the content box).")
(defvar *lm-g2* (make-f32 16) "A second geometry lane (SETTINGS' help tweens, SELECT's weights).")
(defmacro lm-cw () "The window's width, CSS px." `(/ (lay-w) (lay-dpr)))
(defmacro lm-ch () "The window's height, CSS px." `(/ (lay-h) (lay-dpr)))
(defmacro lm-begin-geom ()
  "*LM-G* [0..3] := this frame's .screen content box (CSS px)."
  `(let* ((%d (lay-dpr))) (declare (single-float %d))
     (lm-content! *lm-g* (lm-cw) (lm-ch) (/ (lay-inset 2) %d) (/ (lay-inset 3) %d) (/ (lay-inset 0) %d) (/ (lay-inset 1) %d))))
(defmacro lmg (i) "Box value I of *LM-G* in device px." `(* (lay-dpr) (aref *lm-g* ,i)))
(defmacro lm-entered-p () "Did the screen come up this frame (transitions snap: a hidden element's style change does not animate)?"
  `(= (aref *lm-t* 1) (aref *ui-clock* 0)))

;;; ---------------------------------------------------------------- component state of the frame
(declaim (type (simple-array fixnum (*)) *lm-i*) (type f32vec *lm-t* *lm-ash*))
(defvar *lm-i* (make-array 8 :element-type 'fixnum :initial-element -1)
  "[0] the screen last drawn (V0), [1] the input kind (0 keys, 1 pad, 2 touch: menu.js `input`), [2] the hot id under the mouse last
frame, [3] the renderer frame count since the menus started drawing (0: the first frame takes no cut).")
(defvar *lm-t* (make-array 4 :element-type 'single-float :initial-element -100f0)
  "[0] the cut's start (UI clock), [1] when the screen came up, [2] the ash's last clock.")
(defmacro lm-input () `(aref *lm-i* 1))

(defconstant +ash-n+ 60)
(defvar *lm-ash* (make-f32 (* 6 +ash-n+)) "The title's ash: per particle x y (0..1 of the window), r (CSS px), v (per ms), s (sway phase), red (0 / 1).")
(declaim (type (simple-array fixnum (*)) *lm-rng*))
(defvar *lm-rng* (make-array 1 :element-type 'fixnum :initial-element 12345) "The ash's own LCG (cosmetic: not the sim's stream).")
(defmacro lm-rnd ()
  "A cosmetic random 0..1 from *LM-RNG* (menu.js Math.random; deterministic so stills repeat)."
  `(let* ((%r *lm-rng*)) (setf (aref %r 0) (logand (+ (* (aref %r 0) 1103) 12345) #xFFFFF)) (/ (i->f (aref %r 0)) 1048576f0)))
(defun lm-ash-init ()
  "menu.js startAsh's particles (x, y, r .4-2.2, v .00012-.00052, s, 6 % red), made once."
  (let* ((a *lm-ash*))
    (dotimes (i +ash-n+)
      (let* ((o (* 6 i)))
        (setf (aref a o) (lm-rnd) (aref a (+ o 1)) (lm-rnd) (aref a (+ o 2)) (+ 0.4f0 (* 1.8f0 (lm-rnd)))
              (aref a (+ o 3)) (+ 0.00012f0 (* 0.0004f0 (lm-rnd))) (aref a (+ o 4)) (* 6.28f0 (lm-rnd))
              (aref a (+ o 5)) (if (< (lm-rnd) 0.06f0) 1f0 0f0))))))
(lm-ash-init)

;;; ---------------------------------------------------------------- the systems
(defparameter *lm-cut-ink* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.38 :curve +ease-out+ :fill 1 :base '(1))
  "The cut's ink wipe: menu.js cut()'s clip-path, 380 ms cubic-bezier(.16,1,.3,1) over its three keyframes (progress 0..1; 1 = gone).")
(defparameter *lm-cut-line* (make-tween '((0 nil 0 1) (0.5 nil 1 1) (1 nil 1 0)) :dur 0.3 :curve +ease-cut+ :fill 1 :base '(1 0))
  "The cut's blood line: dashoffset 1 -> 0 by the middle, then the opacity out, 300 ms cubic-bezier(.7,0,.2,1) (drawn, opacity).")
(declaim (type f32vec *lm-cut-ink* *lm-cut-line*))

(defun-fast lm-ash-step ()
  "menu.js startAsh's tick on TITLE (reduced motion: still): rise, sway, wrap to the bottom at a new x. The UI clock's dt in ms (≤ 50)."
  (let* ((now (aref *ui-clock* 0)) (ts *lm-t*) (dt (f-min 50f0 (* 1000f0 (- now (aref ts 2))))) (a *lm-ash*))
    (declare (single-float now dt) (type f32vec ts a))
    (setf (aref ts 2) now)
    (when (and (> dt 0f0) (not *reduced-motion*))
      (dotimes (i +ash-n+)
        (let* ((o (* 6 i)))
          (declare (fixnum o))
          (decf (aref a (+ o 1)) (* (aref a (+ o 3)) dt))
          (incf (aref a (+ o 4)) (* dt 0.0011f0))
          (incf (aref a o) (* (f-sin (aref a (+ o 4))) 0.00025f0 dt))
          (when (< (aref a (+ o 1)) -0.02f0) (setf (aref a (+ o 1)) 1.02f0 (aref a o) (lm-rnd))))))
    nil))

(defun-fast lm-input-step ()
  "menu.js's input kind: a key -> keys, a pad button -> pad, a touch -> touch (a mouse click is keys)."
  (cond ((or (key-pressed :w) (key-pressed :s) (key-pressed :a) (key-pressed :d) (key-pressed :j) (key-pressed :k) (key-pressed :up)
             (key-pressed :down) (key-pressed :left) (key-pressed :right) (key-pressed :return) (key-pressed :escape) (key-pressed :space)
             (mouse-pressed :left))
         (setf (lm-input) 0))
        ((or (any-pad-pressed :a) (any-pad-pressed :b) (any-pad-pressed :start) (any-pad-pressed :dpad-up) (any-pad-pressed :dpad-down)
             (any-pad-pressed :dpad-left) (any-pad-pressed :dpad-right))
         (setf (lm-input) 1))
        ((tap-p) (setf (lm-input) 2)))
  nil)

(defun-fast lm-systems (scr)
  "The frame's own state: a new screen starts the cut (not the first frame the menus draw, not under reduced motion: menu.js show),
the input kind, the ash; then each screen's system."
  (declare (fixnum scr))
  (let* ((iv *lm-i*) (ts *lm-t*) (now (aref *ui-clock* 0)))
    (declare (type (simple-array fixnum (*)) iv) (type f32vec ts) (single-float now))
    (unless (= scr (aref iv 0))
      (when (and (plusp scr) (plusp (aref iv 0)) (not *reduced-motion*)) (setf (aref ts 0) now))
      (when (plusp scr) (setf (aref ts 1) now))
      (setf (aref iv 0) scr))
    (lm-input-step)
    (when (= scr 1) (lm-ash-step))
    (lm-mode-update) (lm-results-update) (lm-settings-update) (lm-controls-update) (lm-select-update)
    nil))

;;; ---------------------------------------------------------------- the pointer: hot boxes -> commands (menu.js bindPointer)
;;; Hot ids (DUEL_LISP_HUD §15): 10000 + kind x 1000 + n, kinds 1 a MODE row, 2 a RESULTS row, 3 a SETTINGS row, 4 a setting's option
;;; (n = 10 row + option), 5 its arrow (n = 10 row + 0 left / 1 right), 6 CONTROLS' column tab, 7 a binding row, 8 a SELECT card (n =
;;; roster index), 9 a difficulty, 10 the camera (n = 1 behind / 0 side), 11 START. The battle side's ids stay under 10000.
(defconstant +hot-menu+ 10000)
(defmacro lm-hot (kind n x0 y0 x1 y1) `(hot-add (+ +hot-menu+ (* 1000 ,kind) ,n) ,x0 ,y0 ,x1 ,y1))

(defun lm-select-row-of (kind)
  "menu.js rowOf: the row of SELECT's last page holding KIND (1 difficulty, 2 camera), from V8's bits."
  (let* ((rows (+ (if (logtest (uv 8) 1) 1 0) (if (logtest (uv 8) 2) 1 0))))
    (declare (ignorable rows))
    (if (and (= kind 2) (logtest (uv 8) 1)) 1 0)))

(defun lm-press (id tap)
  "A click (TAP nil) or a tap on hot box ID: menu.js's click handler, as commands."
  (declare (fixnum id))
  (let* ((scr (uv 0)) (k (if (>= id +hot-menu+) (floor (- id +hot-menu+) 1000) -1)) (n (if (>= id +hot-menu+) (mod (- id +hot-menu+) 1000) -1)))
    (cond ((and (/= (uv 11) 1) (member scr '(1 6))))                     ; Lisp's own timer: not yet
          ((= scr 1) (ui-send 2 0))
          ((and (= scr 4) (= (uv 10) 1)) (ui-send 2 0))                    ; the phone's gestures page: any tap returns
          ((member k '(1 2)) (ui-send 1 n) (ui-send 2 0))
          ((= k 3) (if (>= n (length *lm-settings*)) (progn (ui-send 1 n) (ui-send 2 0)) (ui-send 1 n)))
          ((= k 4) (ui-send 7 n))
          ((= k 5) (ui-send 1 (floor n 10)) (ui-send (if (zerop (mod n 10)) 4 5) 0))
          ((= k 6) (ui-send 8 n))
          ((= k 7) (ui-send 1 n) (ui-send 2 0))
          ((= k 8) (let* ((cur (if (= (uv 2) 1) (uv 4) (uv 3))))
                     (when (< (uv 2) 2)
                       (unless (= n cur) (ui-send 6 n))
                       (when (or (= n cur) (not tap)) (ui-send 2 0)))))
          ((= k 9) (ui-send 1 (lm-select-row-of 1))
                   (let* ((d (- n (uv 5)))) (loop repeat (abs d) do (ui-send (if (plusp d) 5 4) 0))))
          ((= k 10) (unless (= n (uv 7)) (ui-send 1 (lm-select-row-of 2)) (ui-send 5 0)))
          ((= k 11) (ui-send 2 0)))))

(defun lm-hover (id)
  "The mouse entered hot box ID: its row becomes the cursor (menu.js pointerover: MODE / RESULTS rows, settings, bindings)."
  (declare (fixnum id))
  (when (>= id +hot-menu+)
    (let* ((k (floor (- id +hot-menu+) 1000)) (n (mod (- id +hot-menu+) 1000)))
      (let* ((row (case k ((1 2 3 7) n) ((4 5) (floor n 10)) (t -1))))
        (when (and (>= row 0) (/= row (uv 1))) (ui-send 1 row))))))

(defun-fast lm-pointer ()
  "This frame's pointer against last frame's hot boxes (what the player saw): hover is edge-triggered on the mouse moving into a new
box (so W / S still move the cursor while the mouse rests on a row), a click or a tap presses (LM-PRESS)."
  (let* ((iv *lm-i*) (mx (mouse-x)) (my (mouse-y)) (moved (or (/= 0f0 (mouse-dx)) (/= 0f0 (mouse-dy)))))
    (declare (type (simple-array fixnum (*)) iv) (single-float mx my))
    (when moved
      (let* ((h (hot-hit mx my)))
        (declare (fixnum h))
        (unless (= h (aref iv 2)) (setf (aref iv 2) h) (when (>= h 0) (lm-hover h)))))
    (when (mouse-pressed :left) (lm-press (hot-hit mx my) nil))
    (when (tap-p) (lm-press (hot-hit (touch-tap-x *touch*) (touch-tap-y *touch*)) t))
    nil))

;;; ---------------------------------------------------------------- the backdrop
(declaim (type f32vec *lm-wash-st* *lm-world-st*))
(defvar *lm-wash-st* (let* ((v (make-f32 15)))
                       (replace v (list 0f0 (/ 11 255f0) (/ 11 255f0) (/ 16 255f0) 0.28f0  0.7f0 (/ 11 255f0) (/ 11 255f0) (/ 16 255f0) 0.74f0
                                        1f0 (/ 11 255f0) (/ 11 255f0) (/ 16 255f0) 0.74f0)) v)
  "#ui .wash's radial-gradient(120% 90% at 70% 30%, rgba(11,11,16,.28), rgba(11,11,16,.74) 70%) as stops.")
(defvar *lm-world-st* (let* ((v (make-f32 15)))
                        (replace v (list 0f0 (/ 34 255f0) (/ 38 255f0) (/ 52 255f0) 1f0  0.45f0 (/ 22 255f0) (/ 25 255f0) (/ 34 255f0) 1f0
                                         1f0 (/ 11 255f0) (/ 11 255f0) (/ 16 255f0) 1f0)) v)
  "#ui-back .world's radial-gradient(120% 80% at 78% 18%, #222634 0%, night 45%, ink 100%).")
(defparameter +c-grain+ (rgba #xffffff 0.037) "The world's paper grain as its mean (white feTurbulence alpha ~.5 x .07): a uniform +9 levels on the night.")
(defparameter +c-wash0+ (rgba #x0b0b10 0.25)) (defparameter +c-wash1+ (rgba #x0b0b10 0.55))

(defmacro lm-tone (alpha from to)
  "The screentone (7 px dots of rgba(188,193,204,.16) at ALPHA) masked by linear-gradient(170deg, transparent FROM, #000 TO) over the
window: a rect with the dot pattern and an alpha gradient along 170 degrees."
  `(let* ((w (lay-w)) (h (lay-h)) (dx 0.17365f0) (dy 0.98481f0) (len (+ (* w dx) (* h dy)))
          (x0 (- (* 0.5f0 w) (* 0.5f0 len dx))) (y0 (- (* 0.5f0 h) (* 0.5f0 len dy))))
     (declare (single-float w h dx dy len x0 y0))
     (with-col (c +c-tone+)
       (col-alpha! c (* 0.16f0 ,alpha))
       (lm-set! *lm-pts* 0f0 0f0 w 0f0 w h 0f0 h)
       (paint-clip! 0f0 0f0 w h)
       (paint-grad! (+ x0 (* ,from len dx)) (+ y0 (* ,from len dy)) (+ x0 (* ,to len dx)) (+ y0 (* ,to len dy)))
       (paint-dots! (css 7f0) (css 1.15f0))
       (paint-poly *lm-pts* 4 +c-tone0+ c)
       (paint-pattern-off!))))

(defun-fast lm-wash ()
  "#ui .wash (every screen but SELECT): the radial ink, the vertical ink, and its ::before screentone (.45, 25 % -> 80 %)."
  (let* ((w (lay-w)) (h (lay-h)))
    (declare (single-float w h))
    (paint-reset)
    (paint-radial! (* 0.7f0 w) (* 0.3f0 h) (* 1.2f0 w) (* 0.9f0 h) *lm-wash-st* 3)
    (paint-rect 0f0 0f0 w h +c-wash0+ +c-wash1+)
    (lm-tone 0.45f0 0.25f0 0.8f0)
    nil))

(defun-fast lm-world ()
  "#ui-back .world (SELECT, in the back layer under the transparent scene): the radial night and its screentone (.5, 20 % -> 75 %).
The paper grain (white feTurbulence at .07) is its mean, a flat white at .037 (the noise's texture is left out, §2.4)."
  (let* ((w (lay-w)) (h (lay-h)))
    (declare (single-float w h))
    (paint-reset)
    (paint-rect 0f0 0f0 w h +c-ink+)
    (paint-radial! (* 0.78f0 w) (* 0.18f0 h) (* 1.2f0 w) (* 0.8f0 h) *lm-world-st* 3)
    (lm-tone 0.5f0 0.2f0 0.75f0)
    (paint-rect 0f0 0f0 w h +c-grain+)                    ; (the paper grain's mean: white noise at .07)
    nil))

;;; ---------------------------------------------------------------- shared devices
(defun-fast lm-key-cap (s face)
  "menu.css .key at lane [0] x, [1] top (device px): min-width 22, height 22, padding 0 6, 1 px #3a3f4e border with a 2 px bottom,
radius 3, #11131a, the label 600 10px mono paper (S a string; FACE). Lane [2] := its width. A one-character shape label (⇧ ␣ ↺ ✚ ◀ ▶)
is drawn by LM-SHAPE-GLYPH instead."
  (declare (simple-string s) (fixnum face))
  (let* ((x (lma 0)) (y (lma 1)) (dpr (lay-dpr)) (fz (css 10f0)) (tw (text-w s face fz 0f0)) (shape (lm-shape-char-p s))
         (w (f-max (css 22f0) (+ (if shape (* (i->f (length s)) (css 10f0)) tw) (css 12f0)))) (h (css 22f0)) (r (css 3f0)))
    (declare (single-float x y dpr fz tw w h r))
    (paint-box! (+ x (* 0.5f0 w)) (+ y (* 0.5f0 h)) (* 0.5f0 w) (* 0.5f0 h) r 1f0 0f0 +c-cap-line+)
    (paint-box! (+ x (* 0.5f0 w)) (+ y (* 0.5f0 (- h dpr))) (- (* 0.5f0 w) dpr) (- (* 0.5f0 (- h dpr)) dpr) (f-max 0f0 (- r dpr)) 1f0 0f0 +c-cap-bg+)
    (if shape
        (dotimes (i (length s))                          ; (◀▶: two shapes side by side)
          (lm-lane! (+ x (* 0.5f0 w) (* (- (i->f i) (* 0.5f0 (i->f (1- (length s))))) (css 10f0))) (+ y (* 0.5f0 (- h dpr))) (css 10f0))
          (lm-shape-glyph s i +c-paper+))
        (lm-text s face +c-paper+ (f-floor+ (+ x (* 0.5f0 w))) (f-floor+ (+ y (* 0.5f0 (- h dpr)) (* 0.36f0 fz))) fz :align :center))
    (setf (lma 2) w)
    nil))

(defun lm-shape-char-p (s) "Is S made only of the glyphs no face carries (lhud-charset.lisp lhud-shape: ⇧ ␣ ▶ ◀ ✚ ↺)?"
  (and (plusp (length s)) (loop for ch across s always (find ch (lhud-shape "⇧␣▶◀✚↺")))))

(defun-fast lm-shape-glyph (s i col)
  "Character I of S, one of ⇧ ␣ ▶ ◀ ✚ ↺, as strokes / a polygon centred at lane [0] [1], its em lane [2] (device px)."
  (declare (simple-string s) (fixnum i) (type f32vec col))
  (let* ((cx (lma 0)) (cy (lma 1)) (e (lma 2)) (h (* 0.5f0 e)) (lw (f-max (lay-dpr) (* 0.11f0 e))) (p *lm-pts*) (c (char s i)))
    (declare (single-float cx cy e h lw) (type f32vec p))
    (case c
      (#\⇧ (lm-set! p cx (- cy h) (+ cx h) cy (+ cx (* 0.25f0 e)) cy (+ cx (* 0.25f0 e)) (+ cy h) (- cx (* 0.25f0 e)) (+ cy h)
                     (- cx (* 0.25f0 e)) cy (- cx h) cy (- cx 0f0) (- cy h))
           (paint-stroke! p 8 lw col :round t))
      (#\␣ (lm-set! p (- cx h) (- cy (* 0.15f0 e)) (- cx h) (+ cy (* 0.2f0 e)) (+ cx h) (+ cy (* 0.2f0 e)) (+ cx h) (- cy (* 0.15f0 e)))
           (paint-stroke! p 4 lw col))
      ((#\▶ #\◀) (let* ((d (if (char= c #\▶) 1f0 -1f0)))
                   (lm-set! p (- cx (* d 0.32f0 e)) (- cy (* 0.4f0 e)) (+ cx (* d 0.4f0 e)) cy (- cx (* d 0.32f0 e)) (+ cy (* 0.4f0 e)))
                   (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly p 3 col col)))
      (#\✚ (lm-set! p (- cx h) cy (+ cx h) cy) (paint-stroke! p 2 (* 1.6f0 lw) col)
           (lm-set! p cx (- cy h) cx (+ cy h)) (paint-stroke! p 2 (* 1.6f0 lw) col))
      (#\↺ (paint-ellipse! cx cy (* 0.38f0 e) (* 0.38f0 e) col :thick lw :frac 0.8f0)
           (lm-set! p (- cx (* 0.05f0 e)) (- cy (* 0.62f0 e)) (+ cx (* 0.18f0 e)) (- cy (* 0.38f0 e)) (- cx (* 0.05f0 e)) (- cy (* 0.14f0 e)))
           (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly p 3 col col)))
    nil))

;;; the brush (menu.js #brush: a 600 x 60 viewBox stretched over the row, preserveAspectRatio none; #tail fades the last 14 %)
(defparameter *lm-brush* (path-points "M10,30 C14,13 60,8 150,8 C290,7 430,9 560,13 C580,14 596,20 598,29 C597,38 584,44 560,46 C430,52 290,53 150,52 C64,52 16,48 10,30 Z" :segs 6)
  "The brush's body (convex), 600 x 60 units.")
(defparameter *lm-streak1* (path-points "M520,10 C560,9 590,11 600,14 L600,17 C584,15 556,14 520,14 Z" :segs 4) "Its upper dry streak (.55).")
(defparameter *lm-streak2* (path-points "M500,48 C548,49 584,48 600,45 L600,48 C584,52 548,53 500,52 Z" :segs 4) "Its lower dry streak (.45).")
(declaim (type f32vec *lm-brush* *lm-streak1* *lm-streak2*))
(defparameter +c-streak1+ (rgba #xeeeeea 0.55)) (defparameter +c-streak2+ (rgba #xeeeeea 0.45))

(defun-fast-inline lm-brush (k flip)
  "The brush behind a focused row (menu.css .row .brush): the box lane [0] x0 [1] y0 [2] x1 [3] y1 (the row's box grown by
inset -4px -10px -2px -14px), scaleX K from the left (FLIP: from the right, the right hand's narrow rows: mirrored too). The #dry
displacement is left out (a fixed contour: DUEL_LISP_HUD §2.4)."
  (declare (single-float k))
  (when (> k 0.002f0)
    (let* ((x0 (lma 0)) (y0 (lma 1)) (x1 (lma 2)) (y1 (lma 3)) (sx (/ (- x1 x0) 600f0)) (sy (/ (- y1 y0) 60f0)) (p *lm-pts*))
      (declare (single-float x0 y0 x1 y1 sx sy) (type f32vec p))
      (paint-push)
      (if flip
          (paint-transform! x1 0f0 :sx k)
          (paint-transform! x0 0f0 :sx k))
      (macrolet ((shape (src col0 col1 tail)
                   `(let* ((n (floor (length ,src) 2)))
                      (declare (fixnum n))
                      (dotimes (i n)
                        (let* ((ux (aref ,src (* 2 i))))
                          (declare (single-float ux))
                          (setf (aref p (* 2 i)) (if flip (- x1 (* sx ux)) (+ x0 (* sx ux)))
                                (aref p (1+ (* 2 i))) (+ y0 (* sy (aref ,src (1+ (* 2 i))))))))
                      ,(if tail
                           ;; (the gradient is per vertex: the solid part and the tail are cut apart at 86 %, the split not antialiased)
                           `(let* ((xs (if flip (- x1 (* sx 516f0)) (+ x0 (* sx 516f0)))) (xe (if flip (- x1 (* sx 600f0)) (+ x0 (* sx 600f0)))))
                              (declare (single-float xs xe))
                              (if flip (paint-clip! xs -1f6 1f6 1f6) (paint-clip! -1f6 -1f6 xs 1f6))
                              (paint-poly p n ,col0 ,col0)
                              (if flip (paint-clip! -1f6 -1f6 xs 1f6) (paint-clip! xs -1f6 1f6 1f6))
                              (paint-grad! xs 0f0 xe 0f0)
                              (paint-poly p n ,col0 ,col1))
                           `(progn (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly p n ,col0 ,col1))))))
        (shape *lm-brush* +c-paper+ +c-paper0+ t)
        (shape *lm-streak1* +c-streak1+ +c-streak1+ nil)
        (shape *lm-streak2* +c-streak2+ +c-streak2+ nil))
      (paint-pop)))
  nil)

(defun-fast-inline lm-seal (s sc rot)
  "menu.css .row .seal: a blood square, lane [0] cx [1] cy [2] size (device px), radius 3, the inset 2 px highlight, the kanji S
(800 Mincho, lane [3] its size) paper; scaled SC and turned ROT degrees about its centre."
  (declare (simple-string s) (single-float sc rot))
  (when (> sc 0.002f0)
    (let* ((cx (lma 0)) (cy (lma 1)) (hs (* 0.5f0 (lma 2))) (fz (lma 3)) (dpr (lay-dpr)))
      (declare (single-float cx cy hs fz dpr))
      (paint-push)
      (paint-transform! cx cy :sx sc :sy sc :rot (* 0.017453f0 rot))
      (paint-box! cx cy hs hs (css 3f0) 1f0 0f0 +c-blood+)
      (paint-box! cx cy (- hs dpr) (- hs dpr) (css 2f0) 1f0 (* 2f0 dpr) +c-seal-hi+)
      (lm-text s +f-kanji+ +c-paper+ (f-floor+ cx) (+ cy (* 0.36f0 fz)) fz :align :center)
      (paint-pop)))
  nil)

(defmacro lm-hash (a b)
  "A fixed hash of two small fixnums (A < 100, B < 100) to 0..1 (the torn edges' jitter); every product stays a fixnum on wasm32."
  `(/ (i->f (mod (* (+ (* (the fixnum ,a) 131) (* (the fixnum ,b) 977) 7) 1103) 1021)) 1020f0))

(defun-fast lm-torn (col dots seed)
  "Torn paper (menu.css .paper::before with filter: url(#torn)): the box lane [0] x0 [1] y0 [2] x1 [3] y1 as a polygon whose edges
are jittered by a fixed hash (±[4] device px: feTurbulence scale 7 stands in), filled COL, then DOTS (a 5 px halftone of
rgba(11,11,16,.09)). Star-shaped about its centre (aliased: DUEL_LISP_HUD §10.3)."
  (declare (type f32vec col) (fixnum seed))
  (let* ((x0 (lma 0)) (y0 (lma 1)) (x1 (lma 2)) (y1 (lma 3)) (j (lma 4)) (p *lm-pts*) (n 0) (side 8))
    (declare (single-float x0 y0 x1 y1 j) (type f32vec p) (fixnum n side))
    (macrolet ((pt (x y) `(progn (setf (aref p (* 2 n)) ,x (aref p (1+ (* 2 n))) ,y) (incf n))))
      (dotimes (i side) (let* ((u (/ (i->f i) (i->f side)))) (declare (single-float u)) (pt (+ x0 (* u (- x1 x0))) (+ y0 (* j (- (* 2f0 (lm-hash seed i)) 1f0))))))
      (dotimes (i side) (let* ((u (/ (i->f i) (i->f side)))) (declare (single-float u)) (pt (+ x1 (* j (- (* 2f0 (lm-hash seed (+ 20 i))) 1f0))) (+ y0 (* u (- y1 y0))))))
      (dotimes (i side) (let* ((u (/ (i->f i) (i->f side)))) (declare (single-float u)) (pt (- x1 (* u (- x1 x0))) (+ y1 (* j (- (* 2f0 (lm-hash seed (+ 40 i))) 1f0))))))
      (dotimes (i side) (let* ((u (/ (i->f i) (i->f side)))) (declare (single-float u)) (pt (+ x0 (* j (- (* 2f0 (lm-hash seed (+ 60 i))) 1f0))) (- y1 (* u (- y1 y0))))))
      (paint-clip! -1f6 -1f6 1f6 1f6) (paint-centre! (* 0.5f0 (+ x0 x1)) (* 0.5f0 (+ y0 y1)))
      (paint-poly p n col col)
      (when dots
        (paint-clip! -1f6 -1f6 1f6 1f6) (paint-centre! (* 0.5f0 (+ x0 x1)) (* 0.5f0 (+ y0 y1)))
        (paint-dots! (css 5f0) (css 0.9f0))
        (paint-poly p n +c-paper-dot+ +c-paper-dot+)
        (paint-pattern-off!))))
  nil)

(defun-fast-inline lm-slab (k col)
  "menu.css .opt::before: the skewed paper slab behind a current option: the option's box lane [0] x0 [1] y0 [2] x1 [3] y1 inset 2px
-4px, skewX(-14deg), scaleX K from its left, COL."
  (declare (single-float k) (type f32vec col))
  (when (> k 0.002f0)
    (let* ((x0 (- (lma 0) (css 4f0))) (y0 (+ (lma 1) (css 2f0))) (x1 (+ (lma 2) (css 4f0))) (y1 (- (lma 3) (css 2f0)))
           (sk (* 0.2493f0 0.5f0 (- y1 y0))) (xr (+ x0 (* k (- x1 x0)))) (p *lm-pts*))
      (declare (single-float x0 y0 x1 y1 sk xr) (type f32vec p))
      ;; skewX about the box's centre: the top edge shifts right by tan 14deg x half the height, the bottom left (scaleX from the
      ;; left: the right edge at XR)
      (lm-set! p (+ x0 sk) y0 (+ xr sk) y0 (- xr sk) y1 (- x0 sk) y1)
      (paint-clip! -1f6 -1f6 1f6 1f6)
      (paint-poly p 4 col col)))
  nil)

;;; ---------------------------------------------------------------- the rails (menu.css .rail)
(defun-fast lm-hints (scr)
  "The bottom rail's hints (menu.js renderHints) from x lane [0], the row's top lane [1]: MOVE, CHANGE, CONFIRM / START, BACK by the
input kind; narrow windows drop MOVE and BACK."
  (declare (fixnum scr))
  (let* ((x (lma 0)) (y (lma 1)) (k (lm-input)) (narrow (= (lay-menu-form) +form-narrow+)) (fz (css 10f0)) (gap (css 14f0)) (g2 (css 7f0)))
    (declare (single-float x y fz gap g2) (fixnum k))
    (macrolet ((hint (cap word)
                 `(progn (lm-lane! x y) (lm-key-cap ,cap +f-mono+)
                         (setf x (+ x (lma 2) g2))
                         (lm-text ,word +f-mono+ +c-stone+ (f-floor+ x) (f-floor+ (+ y (* 0.5f0 (css 22f0)) (* 0.36f0 fz))) fz :spacing 0.1f0 :edge +em4+)
                         (setf x (+ x (text-w ,word +f-mono+ fz 0.1f0) gap)))))
      (when (and (/= scr 1) (not narrow)) (hint (case k (1 (lhud-shape "✚")) (t "W S")) "MOVE"))
      (when (member scr '(3 5)) (hint (case k (1 (zh "◀▶")) (t "A D")) "CHANGE"))
      (hint (case k (1 "A") (2 "TAP") (t "J")) (if (= scr 1) "START" "CONFIRM"))
      (when (and (/= scr 1) (not narrow)) (hint (case k (1 "B") (2 "BACK") (t "K")) "BACK")))
    nil))

(defun-fast lm-rails (scr)
  "menu.css .rail.top (the blood tick and SOUL DUEL NEXT at the left, the crumb at the right: the screen's word, narrow: only its
kanji) and .rail.bottom (the hints), padded by the gutters + 8 and the safe areas + 14 (narrow top + 12)."
  (declare (fixnum scr))
  (let* ((w (lay-w)) (h (lay-h)) (narrow (= (lay-menu-form) +form-narrow+))
         (gl (+ (f-max (css 16f0) (lay-inset 2)) (css 8f0))) (gr (+ (f-max (css 16f0) (lay-inset 3)) (css 8f0)))
         (top (+ (lay-inset 0) (css (if narrow 12f0 14f0)))) (mz (css 15f0)) (cr (svref *lm-screens* (max 0 (min 6 scr)))))
    (declare (single-float w h gl gr top mz))
    (paint-reset)
    ;; the mark: a 22 x 2 blood tick turned -24deg, 10 px gap, the word 800 15px display .18em steel
    (paint-push) (paint-transform! (+ gl (css 11f0)) (+ top (* 0.5f0 mz)) :rot -0.4189f0)
    (paint-rect (+ gl 0f0) (- (+ top (* 0.5f0 mz)) (css 1f0)) (css 22f0) (css 2f0) +c-blood+)
    (paint-pop)
    (lm-text "SOUL DUEL NEXT" +f-display+ +c-steel+ (f-floor+ (+ gl (css 32f0))) (f-floor+ (lm-base top +f-display+ mz 1f0)) mz :spacing 0.18f0 :edge +ed8+)
    ;; the crumb: the kanji 800 13px Mincho steel .1em at the right, the word 400 10px mono stone .14em 10 px before it
    (when cr
      (let* ((kz (css 13f0)) (kw (text-w (car cr) +f-kanji+ kz 0.1f0)) (kx (- w gr kw)) (wz (css 10f0)) (cy (+ top (* 0.5f0 mz))))
        (declare (single-float kz kw kx wz cy))
        (lm-text (car cr) +f-kanji+ +c-steel+ (f-floor+ kx) (f-floor+ (lm-base (- cy (* 0.5f0 kz)) +f-kanji+ kz 1f0)) kz :spacing 0.1f0)
        (unless narrow
          (lm-text (cdr cr) +f-mono+ +c-stone+ (f-floor+ (- kx (css 10f0))) (f-floor+ (lm-base (- cy (* 0.5f0 wz)) +f-mono+ wz 1f0)) wz
                   :spacing 0.14f0 :edge +em4+ :align :end))))
    ;; the hints: 22 px caps, the row's bottom at the safe area + 14
    (lm-lane! gl (- h (lay-inset 1) (css 14f0) (css 22f0)))
    (lm-hints scr)
    nil))

;;; ---------------------------------------------------------------- the cut (menu.js cut(): an ink wipe and a blood diagonal)
(defun-fast lm-cut ()
  "The screen change's cut over everything (z 20): the ink polygon from the whole window (0) to its top-left corner at the top-right
(.55: a triangle) to nothing at the bottom-right (1), and the blood line from (104 %, -4 %) to (-4 %, 104 %), 3 px, drawn by its
middle, then faded."
  (let* ((now (aref *ui-clock* 0)) (st (aref *lm-t* 0)))
    (declare (single-float now st))
    (when (< (- now st) 0.4f0)
      (let* ((w (lay-w)) (h (lay-h)) (p (twv *lm-cut-ink* st now 0)) (q *lm-pts*)
             (dr (twv *lm-cut-line* st now 0)) (op (twv *lm-cut-line* st now 1)))
        (declare (single-float w h p dr op) (type f32vec q))
        (paint-reset)
        (if (< p 0.55f0)
            (let* ((u (/ p 0.55f0))) (declare (single-float u))   ; top-left -> top-right
              (lm-set! q (* u w) 0f0 w 0f0 w h 0f0 h) (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly q 4 +c-ink+ +c-ink+))
            (let* ((u (/ (- p 0.55f0) 0.45f0))) (declare (single-float u))   ; the triangle (w,0) (w,h) (0,h) -> (w,h)
              (when (< u 0.999f0)
                (lm-set! q w (* u h) w h (* u w) h) (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly q 3 +c-ink+ +c-ink+))))
        (when (and (> op 0.002f0) (> dr 0.002f0))
          (with-col (c +c-blood+)
            (col-alpha! c op)
            (lm-set! q (* 1.04f0 w) (* -0.04f0 h) (* -0.04f0 w) (* 1.04f0 h))
            (paint-stroke! q 2 (css 3f0) c :frac dr :round t))))))
  nil)

;;; ---------------------------------------------------------------- the frame
(declaim (type f32vec *lm-fit*))
(defvar *lm-fit* (make-f32 8)
  "[scr] the stack's height (CSS px, the geometry's [31]) screen SCR (V0: 2 MODE, 3 SETTINGS, 4 CONTROLS, 6 RESULTS) took last frame,
the next frame's fit (LM-FIT-K); [7] the density LM-ZOOM! put aside.")
(defun-fast lm-zoom! (scr)
  "The frame's density (*LAY* [2], [9] the CSS width) for screen SCR's view: shrunk by LM-FIT-K when its stack did not fit last frame
(a short phone, a landscape phone: DUEL_LISP_HUD §16). LM-UNZOOM! puts it back; the rails and the cut keep the real one."
  (declare (fixnum scr))
  (let* ((l *lay*) (d (aref l 2)) (k (lm-fit-k (aref *lm-fit* scr) (/ (aref l 1) d) (/ (aref l 4) d) (/ (aref l 5) d))))
    (declare (type f32vec l) (single-float d k))
    (setf (aref *lm-fit* 7) d (aref l 2) (* d k) (aref l 9) (/ (aref l 0) (* d k))))
  nil)
(defun-fast lm-unzoom! (scr)
  "Undo LM-ZOOM! and keep the stack's height screen SCR's geometry left in *LM-G* [31] for the next frame's fit."
  (declare (fixnum scr))
  (let* ((l *lay*) (d (aref *lm-fit* 7)))
    (declare (type f32vec l) (single-float d))
    (setf (aref *lm-fit* scr) (aref *lm-g* 31) (aref l 2) d (aref l 9) (/ (aref l 0) d)))
  nil)

(defun lhud-menu-draw ()
  "The Lisp menus of this frame (HUD-DRAW, after LHUD-DRAW set the frame's layout and started the hot boxes): the systems, the pointer
against last frame's boxes, then the screen (SELECT's back layer and world under the scene; MODE, SETTINGS, CONTROLS and RESULTS
shrunk to fit a short window: LM-ZOOM!), the rails and the cut."
  (let* ((scr (uv 0)))
    (declare (fixnum scr))
    (lm-systems scr)
    (when (plusp scr)
      (lm-pointer)
      (if (= scr 5) (lm-select-back) (lm-wash))
      (case scr
        (1 (lm-title)) (5 (lm-select))
        ((2 3 4 6) (lm-zoom! scr)
         (case scr (2 (lm-mode)) (3 (lm-settings)) (4 (lm-controls)) (t (lm-results)))
         (lm-unzoom! scr)))
      (lm-rails scr)
      (lm-cut))
    nil))
