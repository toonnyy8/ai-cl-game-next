;;;; paint.lisp — the paint stream: a second 2D batch (RP_HUD, slot 19) drawn after the UI batch in the swapchain pass
;;;; (docs/duel/DUEL_LISP_HUD.md §4.1). Phase 0, the spike: modes 0 flat, 1 SDF glyph, 2 rounded box (hud.frag.wgsl); one current
;;;; affine and opacity; convex polygons clipped to a rectangle with a vertical gradient; single-line text runs from the baked SDF
;;;; atlas. The RP_UI batch (ui.lisp) is not touched. Vertex: 16 floats = position xy + uv, colour (sRGB, straight alpha), p, q.
;;;; Coordinates are framebuffer pixels, origin top-left, y down. 0 B per frame: the emitters are DEFUN-FASTs whose float inputs
;;;; are read from f32vecs (the transform, the clip, the pen, the box) set by macros, so no float crosses a call boxed; strings
;;;; and colours (f32vec r g b a) go as objects.
;;;; Phase 1b moved the shapes (polygons with analytic AA, boxes, ellipses / rings / arcs, strokes, radial fans, gradients,
;;;; patterns), the transform / clip / opacity stack and the back layer to paint-shapes.lisp; wrapped and vertical text is
;;;; text.lisp (phase 1c), easing tween.lisp's EASE. Glyph quads (%GLYPH-QUAD, shared with text.lisp) follow 1b's transform and
;;;; opacity stack, are cut to its scissor, and take the pen's outline band and the pattern's halftone dots.
(in-package :engine)

(declaim (type f32vec *paint-xf* *paint-clip* *paint-pen* *paint-box* *paint-q4* *paint-pa* *paint-pb* *glyph-f* *face-m*)
         (type (simple-array fixnum (*)) *glyph-keys*))
(defvar *paint-xf* (make-f32 7) "The current transform: [0..5] a b c d e f (X = a x + c y + e, Y = b x + d y + f), [6] the opacity.")
(defvar *paint-clip* (make-f32 6) "PAINT-POLY's clip rectangle x0 y0 x1 y1 and its gradient's top and bottom y (PAINT-CLIP!).")
(defvar *paint-pen* (make-f32 9)
  "The text pen (PAINT-PEN!): [0] x, [1] the baseline y, [2] size (px per em), [3] letter spacing (em), [4] the SDF edge (0.5 =
the baked weight, lower = bolder), [5] the softness (1 = a one-pixel edge), [6] the skew (x per px of height: a synthetic oblique),
[7] the width PAINT-MEASURE / PAINT-MEASURE-INT found, [8] the outline band (SDF units; 0 = filled, > 0 = only a ring that wide
inside the edge: lower the edge to grow it outward). PAINT-TEXT and PAINT-INT advance [0].")
(defvar *paint-box* (make-f32 7) "PAINT-BOX's centre x y, half size w h, radius, feather, border (PAINT-BOX!).")
(defvar *paint-q4* (make-f32 8) "PAINT-RECT's corners.")
(defvar *paint-pa* (make-f32 64)) (defvar *paint-pb* (make-f32 64))   ; (clipping scratch: 32 points)
(declaim (type f32vec *paint-sc* *paint-pat*))
(defvar *paint-sc* (make-f32 4) "The scissor x0 y0 x1 y1 in the emitters' local coordinates (PAINT-SCISSOR!; PAINT-RESET opens it).")
(defvar *paint-pat* (make-f32 6)
  "The polygons' pattern (PAINT-DOTS!, PAINT-STRIPES!; glyphs take the dots only; off after PAINT-RESET): [0] the dot radius / line width, [1] 0 none, > 0 the
dot pitch (screen px), < 0 minus the stripe pitch (local units), [2] [3] the stripes' origin, [4] [5] their axis (a unit vector).")
(defvar *glyph-keys* (make-array 0 :element-type 'fixnum) "Sorted (tier * 4 + face) * 65536 + code of every baked glyph.")
(defvar *glyph-f* (make-f32 0) "Per glyph 9 floats: atlas u0 v0 u1 v1, cell left, cell top (above the baseline), w, h, advance (em).")
(defvar *face-m* (make-f32 8) "Per face: ascent, descent (em; the line box's, as Chrome's).")

(defun paint-init ()
  "The RP_HUD pipeline and the stream (ENGINE-INIT). The atlas comes later from the game (PAINT-FONT-INIT + r_hud_atlas_new)."
  (make-pipeline 19 (wgsl "hud.vert.wgsl") "vs_hud" (wgsl "hud.frag.wgsl") "fs_hud" #x4444 2 0 1 0)   ; RP_HUD
  (setf *hud-batch* (make-stream-buffer 16 32768))
  (paint-shapes-init))

(defun rgba (rgb &optional (a 1.0))
  "A colour for the emitters: #xRRGGBB and alpha -> f32vec (r g b a), sRGB 0..1."
  (let ((v (make-f32 4)))
    (setf (aref v 0) (/ (ldb (byte 8 16) rgb) 255f0) (aref v 1) (/ (ldb (byte 8 8) rgb) 255f0) (aref v 2) (/ (ldb (byte 8 0) rgb) 255f0)
          (aref v 3) (f32 a))
    v))

;;; ---------------------------------------------------------------- the text pen (a macro: float forms stay unboxed)
(defmacro %f32-set (vec &rest vals)
  "Store VALS into the f32vec VEC from index 0 (a NIL skips that index), in order. VEC is bound to a fresh name, so a caller's
variable is never captured (the paint macros' float lane: no float crosses a call)."
  (let ((v (gensym "V")))
    `(let ((,v ,vec)) (setf ,@(loop for x in vals for i from 0 when x append `((aref ,v ,i) ,x))))))

(defmacro paint-pen! (x y size &key (spacing 0f0) (edge 0.5f0) (soft 1f0) (skew 0f0) (outline 0f0))
  "The text pen at (X Y) (Y the baseline), SIZE px per em, letter SPACING (em), the SDF EDGE / SOFTness, the SKEW, the OUTLINE band."
  `(%f32-set *paint-pen* ,x ,y ,size ,spacing ,edge ,soft ,skew nil ,outline))

;;; ---------------------------------------------------------------- vertices
(defmacro with-hud-verts ((nverts) &body body)
  "Reserve NVERTS in the paint stream (skipped when it is full); inside BODY (HVTX x y u v r g b a p0 p1 p2 p3 q0 q1 q2 q3) appends
one vertex, X Y through the current transform, A times the current opacity. DEFUN-FAST code with float locals: 0 B."
  `(let* ((sb *hud-batch*))
     (when (stream-room-p sb ,nverts)
       (let* ((d (stream-buffer-data sb)) (o (stream-buffer-fill sb)) (m *paint-xf*)
              (xa (aref m 0)) (xb (aref m 1)) (xc (aref m 2)) (xd (aref m 3)) (xe (aref m 4)) (xf (aref m 5)) (op (aref m 6)))
         (declare (type f32vec d m) (fixnum o) (single-float xa xb xc xd xe xf op))
         (macrolet ((hvtx (x y u v r g b a p0 p1 p2 p3 q0 q1 q2 q3)
                      `(let ((lx ,x) (ly ,y))
                         (declare (single-float lx ly))
                         (setf (aref d o) (+ (* xa lx) (* xc ly) xe) (aref d (+ o 1)) (+ (* xb lx) (* xd ly) xf)
                               (aref d (+ o 2)) ,u (aref d (+ o 3)) ,v
                               (aref d (+ o 4)) ,r (aref d (+ o 5)) ,g (aref d (+ o 6)) ,b (aref d (+ o 7)) (* op ,a)
                               (aref d (+ o 8)) ,p0 (aref d (+ o 9)) ,p1 (aref d (+ o 10)) ,p2 (aref d (+ o 11)) ,p3
                               (aref d (+ o 12)) ,q0 (aref d (+ o 13)) ,q1 (aref d (+ o 14)) ,q2 (aref d (+ o 15)) ,q3
                               o (+ o 16)))))
           ,@body)
         (setf (stream-buffer-fill sb) o)
         t))))

;;; (the shapes, the transform / clip / opacity stack, gradients, patterns and the back layer: paint-shapes.lisp)

;;; ---------------------------------------------------------------- text: the baked atlas (tools/sdf-bake.py)
(declaim (type f32vec *glyph-dscale*))
(defvar *glyph-dscale* (make-f32 2) "Per tier (body, display): SDF units per em (em px / (2 spread)), from metrics.bin.")
(defun paint-font-init (bytes)
  "Read metrics.bin (an (unsigned-byte 8) vector, tools/sdf-bake.py's format) into the glyph table; the atlas's width and height."
  (flet ((u16 (i) (logior (aref bytes (* 2 i)) (ash (aref bytes (1+ (* 2 i))) 8)))
         (s16 (v) (if (>= v 32768) (- v 65536) v)))
    (let* ((n (u16 2)) (aw (u16 3)) (ah (u16 4)) (ems (vector (u16 5) (u16 6))) (nf (u16 8)) (g0 (+ 16 (* 4 nf)))
           (keys (make-array n :element-type 'fixnum)) (gf (make-f32 (* 9 n))))
      (dotimes (f (min nf 4))
        (setf (aref *face-m* (* 2 f)) (/ (s16 (u16 (+ 16 (* 4 f)))) 1000f0) (aref *face-m* (1+ (* 2 f))) (/ (s16 (u16 (+ 17 (* 4 f)))) 1000f0)))
      (dotimes (i n)
        (let* ((w (+ g0 (* 9 i))) (code (u16 w)) (ft (u16 (+ w 1))) (em (f32 (svref ems (floor ft 4))))
               (x (u16 (+ w 2))) (y (u16 (+ w 3))) (gw (u16 (+ w 4))) (gh (u16 (+ w 5))) (o (* 9 i)))
          (setf (aref keys i) (+ (* ft 65536) code)
                (aref gf o) (/ x (f32 aw)) (aref gf (+ o 1)) (/ y (f32 ah)) (aref gf (+ o 2)) (/ (+ x gw) (f32 aw)) (aref gf (+ o 3)) (/ (+ y gh) (f32 ah))
                (aref gf (+ o 4)) (/ (s16 (u16 (+ w 6))) em) (aref gf (+ o 5)) (/ (s16 (u16 (+ w 7))) em)
                (aref gf (+ o 6)) (/ gw em) (aref gf (+ o 7)) (/ gh em) (aref gf (+ o 8)) (/ (s16 (u16 (+ w 8))) (* 64 em)))))
      (setf *glyph-keys* keys *glyph-f* gf
            (aref *glyph-dscale* 0) (/ (f32 (svref ems 0)) (* 2 (max 1 (u16 7)))) (aref *glyph-dscale* 1) (/ (f32 (svref ems 1)) (* 2 (max 1 (u16 7)))))
      (values aw ah))))

(defun-fast glyph-find (face code big)
  "The glyph index of CODE in FACE (0 display, 1 mono, 2 kanji, 3 sans): the display tier first when BIG (the display face's
upper case there: a-z draw as A-Z, no string made), else the body tier; a
glyph missing from the face comes from the sans (as the browser's fallback), then the Mincho, then the sans's □; -1 when none."
  (declare (fixnum face code))
  (let ((keys *glyph-keys*))
    (declare (type (simple-array fixnum (*)) keys))
    (flet ((look (key)
             (declare (fixnum key))
             (let ((lo 0) (hi (1- (length keys))))
               (declare (fixnum lo hi))
               (loop while (<= lo hi)
                     do (let* ((mid (floor (+ lo hi) 2)) (k (aref keys mid)))
                          (declare (fixnum mid k))
                          (cond ((= k key) (return-from look mid)) ((< k key) (setf lo (1+ mid))) (t (setf hi (1- mid))))))
               -1)))
      (let ((g -1))
        (declare (fixnum g))
        (when big                                         ; (the display face's display tier is upper case only, as the CSS
          (setf g (look (+ (* (+ 4 face) 65536)           ;  shows those words: a-z draw as A-Z there; tools/sdf-bake.py)
                           (if (and (= face 0) (<= 97 code 122)) (- code 32) code)))))
        (when (< g 0) (setf g (look (+ (* face 65536) code))))
        (when (< g 0) (setf g (look (+ (* 3 65536) code))))
        (when (< g 0) (setf g (look (+ (* 2 65536) code))))
        (when (< g 0) (setf g (look (+ (* 3 65536) #x25A1))))
        g))))

(defconstant +big-px+ 40f0 "Glyphs drawn larger than this (px per em) use the display tier when it has them.")
;;; The small-text weight (the user, 2026-11-11: 「先加粗小字再看一次 (Recommended)」; DUEL_LISP_HUD §11): Chrome's
;;; hinted, gamma-boosted text is heavier than a plain SDF edge at a few device px per stem, so text below *TEXT-SMALL-CSS* CSS px
;;; grows by *TEXT-SMALL-BOLD* device px on each side of every stroke (an SDF edge shift; full strength at or below the size, fading
;;; out by 4 CSS px above it), with its antialiasing ramp scaled by *TEXT-SMALL-SOFT*. The shift is in device px, so a dense screen
;;; (dpr 3, where phase 0 found no difference) moves a third as much in CSS px.
(declaim (type single-float *text-small-css* *text-small-bold* *text-small-soft*))
(defparameter *text-small-css* 14f0
  "Below this many CSS px (per em) text gets the small-text weight; it fades out over the next 4 px. 14 (new, 2026-11-11, the user's
「先加粗小字再看一次」 for text under about 14 px).")
(defparameter *text-small-bold* 0.06f0
  "The small-text weight: device px added on each side of a stroke at full strength. 0 -> 0.06 (2026-11-11, the user: 「先加粗小字再看一次
(Recommended)」; tuned by matching the legibility card's ink to Chrome's: 8-12 px rows 0.84-0.93 -> 0.95-1.03 of Chrome's at dpr 1,
0.89-0.97 -> 0.94-1.01 at dpr 3; DUEL_LISP_HUD §11).")
(defparameter *text-small-soft* 1f0
  "The small-text antialiasing ramp, times the pen's softness, at full strength (1 = a one-pixel edge). 1 -> 1 (2026-11-11, with
*TEXT-SMALL-BOLD*: at 1 the 8-12 px rows already have as many fully lit pixels as Chrome's, more for the sans and the Mincho, so a
sharper ramp would only add contrast Chrome does not have).")

(defmacro with-small-text ((grow soft) size soft0 &body body)
  "Bind GROW (em added per side of a stroke, times a tier's SDF units per em = the edge shift) and SOFT (SOFT0 times the small-text
ramp) for text of SIZE device px per em (the knobs above), around BODY."
  `(let* ((%small (f-clamp (/ (- (+ *text-small-css* 4f0) (/ ,size (ffi:c-inline () () :float "pf_density()" :one-liner t))) 4f0) 0f0 1f0))
          (,grow (if (> ,size 0f0) (/ (* %small *text-small-bold*) ,size) 0f0))
          (,soft (* ,soft0 (+ 1f0 (* %small (- *text-small-soft* 1f0))))))
     (declare (single-float %small ,grow ,soft))
     ,@body))
(defmacro glyph-edge (edge grow gi)
  "The SDF edge of glyph GI: EDGE moved out by GROW em in its tier's units."
  `(- ,edge (* ,grow (aref *glyph-dscale* (if (>= (aref *glyph-keys* ,gi) #x40000) 1 0)))))

(defmacro %glyph-quad (x0 y0 x1 y1 u0 v0 u1 v1 k0 k1 side)
  "One glyph cell in mode 1 (inside the text runs, which bind R G B A EDGE SOFT): the local rectangle X0 Y0 X1 Y1 cut to the
scissor *PAINT-SC*, its atlas uv following the cut. SIDE nil: u along x, v along y, the top edge shifted right by K0 and the bottom
by K1 (the synthetic oblique); SIDE t: turned 90 degrees clockwise (u along y, v from V1 at X0 to V0 at X1). The pen's outline band
[8] goes to p.w, the pattern's halftone dots (*PAINT-PAT*, PAINT-DOTS!) to q.x / q.w (stripes are the polygons' only); the
transform and opacity come from WITH-HUD-VERTS. ponytail: with a skew the cut is made on the upright cell (off by up to the
skew's shift where a cut crosses an oblique glyph); cut on the parallelogram if a screen shows it."
  `(let* ((%s *paint-sc*) (%x0 ,x0) (%y0 ,y0) (%x1 ,x1) (%y1 ,y1)
          (%cx0 (f-max %x0 (aref %s 0))) (%cy0 (f-max %y0 (aref %s 1))) (%cx1 (f-min %x1 (aref %s 2))) (%cy1 (f-min %y1 (aref %s 3))))
     (declare (type f32vec %s) (single-float %x0 %y0 %x1 %y1 %cx0 %cy0 %cx1 %cy1))
     (when (and (< %cx0 %cx1) (< %cy0 %cy1))
       (let* ((%ix (/ 1f0 (f-max (- %x1 %x0) 1f-6))) (%iy (/ 1f0 (f-max (- %y1 %y0) 1f-6)))
              (%fx0 (* (- %cx0 %x0) %ix)) (%fx1 (* (- %cx1 %x0) %ix)) (%fy0 (* (- %cy0 %y0) %iy)) (%fy1 (* (- %cy1 %y0) %iy))
              (%u0 ,u0) (%v0 ,v0) (%u1 ,u1) (%v1 ,v1) (%k0 ,k0) (%k1 ,k1)
              (%ka (+ %k0 (* %fy0 (- %k1 %k0)))) (%kb (+ %k0 (* %fy1 (- %k1 %k0))))
              (%pt *paint-pat*) (%ow (aref *paint-pen* 8)) (%pq (aref %pt 0)) (%pw (f-max (aref %pt 1) 0f0)))
         (declare (type f32vec %pt) (single-float %ix %iy %fx0 %fx1 %fy0 %fy1 %u0 %v0 %u1 %v1 %k0 %k1 %ka %kb %ow %pq %pw))
         (macrolet ((gv (xx yy uu vv) `(hvtx ,xx ,yy ,uu ,vv r g b a 1f0 edge soft %ow %pq 0f0 0f0 %pw)))
           ,(if side
                `(let ((%ua (+ %u0 (* %fy0 (- %u1 %u0)))) (%ub (+ %u0 (* %fy1 (- %u1 %u0))))
                       (%va (+ %v1 (* %fx0 (- %v0 %v1)))) (%vb (+ %v1 (* %fx1 (- %v0 %v1)))))
                   (declare (single-float %ua %ub %va %vb))
                   (with-hud-verts (6)
                     (gv %cx0 %cy0 %ua %va) (gv %cx1 %cy0 %ua %vb) (gv %cx1 %cy1 %ub %vb)
                     (gv %cx0 %cy0 %ua %va) (gv %cx1 %cy1 %ub %vb) (gv %cx0 %cy1 %ub %va)))
                `(let ((%ua (+ %u0 (* %fx0 (- %u1 %u0)))) (%ub (+ %u0 (* %fx1 (- %u1 %u0))))
                       (%va (+ %v0 (* %fy0 (- %v1 %v0)))) (%vb (+ %v0 (* %fy1 (- %v1 %v0)))))
                   (declare (single-float %ua %ub %va %vb))
                   (with-hud-verts (6)
                     (gv (+ %cx0 %ka) %cy0 %ua %va) (gv (+ %cx1 %ka) %cy0 %ub %va) (gv (+ %cx1 %kb) %cy1 %ub %vb)
                     (gv (+ %cx0 %ka) %cy0 %ua %va) (gv (+ %cx1 %kb) %cy1 %ub %vb) (gv (+ %cx0 %kb) %cy1 %ua %vb)))))))))

(defun-fast %paint-run (s face col draw start end)
  "PAINT-TEXT / PAINT-MEASURE: characters START .. END (END < 0: the whole string) of the run S (a string) in FACE at the pen; DRAW
nil only measures (into pen [7])."
  (declare (simple-string s) (fixnum face start end) (type f32vec col))
  (let* ((p *paint-pen*) (gf *glyph-f*) (x (aref p 0)) (y (aref p 1)) (size (aref p 2)) (ls (* size (aref p 3)))
         (edge (aref p 4)) (soft0 (aref p 5)) (skew (aref p 6)) (big (> size +big-px+)) (x0 x)
         (r (aref col 0)) (g (aref col 1)) (b (aref col 2)) (a (aref col 3)))
    (declare (type f32vec p gf) (single-float x y size ls edge soft0 skew x0 r g b a))
    (with-small-text (grow soft) size soft0
    (loop for i of-type fixnum from start below (if (< end 0) (length s) (min end (length s)))
      do (let ((gi (glyph-find face (char-code (char s i)) big)))
        (declare (fixnum gi))
        (when (>= gi 0)
          (let ((o (* 9 gi)) (edge (glyph-edge edge grow gi)))
            (declare (fixnum o) (single-float edge))
            (when (and draw (> (aref gf (+ o 6)) 0f0))
              (let* ((gx0 (+ x (* size (aref gf (+ o 4))))) (gy0 (- y (* size (aref gf (+ o 5)))))
                     (gx1 (+ gx0 (* size (aref gf (+ o 6))))) (gy1 (+ gy0 (* size (aref gf (+ o 7)))))
                     (k0 (* skew (- y gy0))) (k1 (* skew (- y gy1))))
                (declare (single-float gx0 gy0 gx1 gy1 k0 k1))
                (%glyph-quad gx0 gy0 gx1 gy1 (aref gf o) (aref gf (+ o 1)) (aref gf (+ o 2)) (aref gf (+ o 3)) k0 k1 nil)))
            (setf x (+ x (* size (aref gf (+ o 8))) ls)))))))
    (if draw (setf (aref p 0) x) (setf (aref p 7) (- x x0)))
    nil))

(defun paint-text (s face col) "Draw the string S in FACE at the pen (it advances)." (%paint-run s face col t 0 -1))
(defun paint-measure (s face) "The advance of S in FACE at the pen's size and spacing, into pen [7]." (%paint-run s face *paint-q4* nil 0 -1))

(defvar *digit-strs* (coerce (loop for d below 10 collect (string (code-char (+ 48 d)))) 'simple-vector))
(defun-fast %paint-int (n face col draw)
  "PAINT-INT / PAINT-MEASURE-INT: the decimal digits of the fixnum N (0 B: no string is made)."
  (declare (fixnum n face))
  (let* ((p *paint-pen*) (x0 (aref p 0)) (div 1) (m (abs n)) (w 0f0))
    (declare (type f32vec p) (single-float x0 w) (fixnum div m))
    (loop while (>= m (* div 10)) do (setf div (* div 10)))
    (loop while (>= div 1)
          do (let ((s (svref *digit-strs* (mod (floor m div) 10))))
               (if draw (%paint-run s face col t 0 -1)
                   (progn (%paint-run s face col nil 0 -1) (setf w (+ w (aref p 7)))))
               (setf div (floor div 10))))
    (unless draw (setf (aref p 7) w (aref p 0) x0))
    nil))
(defun paint-int (n face col) "Draw the integer N in FACE at the pen (it advances)." (%paint-int n face col t))
(defun paint-measure-int (n face) "The advance of the integer N in FACE, into pen [7]." (%paint-int n face *paint-q4* nil))

(defmacro face-ascent (face) `(aref *face-m* (* 2 ,face)))
(defmacro face-descent (face) `(aref *face-m* (1+ (* 2 ,face))))

;;; (easing: tween.lisp's EASE, the one implementation of the CSS curves)

;;; ---------------------------------------------------------------- the UI clock (real time: hitstop, slow motion, pause do not stop it)
(declaim (type f32vec *ui-clock*))
(defvar *ui-clock* (make-f32 1) "[0] seconds of real (unscaled) frame time, advanced by PAINT-CLOCK-ADVANCE once a frame (DUEL_LISP_HUD §4.4).")
(defun-fast paint-clock-advance () "Advance *UI-CLOCK* by this frame's unclamped dt." (incf (aref *ui-clock* 0) (aref *input* 11)) nil)
