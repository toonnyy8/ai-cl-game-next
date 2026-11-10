;;;; paint.lisp — the paint stream: a second 2D batch (RP_HUD, slot 19) drawn after the UI batch in the swapchain pass
;;;; (docs/duel/DUEL_LISP_HUD.md §4.1). Phase 0, the spike: modes 0 flat, 1 SDF glyph, 2 rounded box (hud.frag.wgsl); one current
;;;; affine and opacity; convex polygons clipped to a rectangle with a vertical gradient; single-line text runs from the baked SDF
;;;; atlas. The RP_UI batch (ui.lisp) is not touched. Vertex: 16 floats = position xy + uv, colour (sRGB, straight alpha), p, q.
;;;; Coordinates are framebuffer pixels, origin top-left, y down. 0 B per frame: the emitters are DEFUN-FASTs whose float inputs
;;;; are read from f32vecs (the transform, the clip, the pen, the box) set by macros, so no float crosses a call boxed; strings
;;;; and colours (f32vec r g b a) go as objects.
;;;; ponytail: no transform / clip stack, no polygon fringe (aliased polygon edges), no wrap or vertical runs, no pattern flags:
;;;; phase 1b / 1c add them (DUEL_LISP_HUD §5).
(in-package :engine)

(declaim (type f32vec *paint-xf* *paint-clip* *paint-pen* *paint-box* *paint-q4* *paint-pa* *paint-pb* *glyph-f* *face-m*
               *ease-pts*)
         (type (simple-array fixnum (*)) *glyph-keys*))
(defvar *paint-xf* (make-f32 7) "The current transform: [0..5] a b c d e f (X = a x + c y + e, Y = b x + d y + f), [6] the opacity.")
(defvar *paint-clip* (make-f32 6) "PAINT-POLY's clip rectangle x0 y0 x1 y1 and its gradient's top and bottom y (PAINT-CLIP!).")
(defvar *paint-pen* (make-f32 8)
  "The text pen (PAINT-PEN!): [0] x, [1] the baseline y, [2] size (px per em), [3] letter spacing (em), [4] the SDF edge (0.5 =
the baked weight, lower = bolder), [5] the softness (1 = a one-pixel edge), [6] the skew (x per px of height: a synthetic oblique),
[7] the width PAINT-MEASURE / PAINT-MEASURE-INT found. PAINT-TEXT and PAINT-INT advance [0].")
(defvar *paint-box* (make-f32 7) "PAINT-BOX's centre x y, half size w h, radius, feather, border (PAINT-BOX!).")
(defvar *paint-q4* (make-f32 8) "PAINT-RECT's corners.")
(defvar *paint-pa* (make-f32 64)) (defvar *paint-pb* (make-f32 64))   ; (clipping scratch: 32 points)
(defvar *glyph-keys* (make-array 0 :element-type 'fixnum) "Sorted (tier * 4 + face) * 65536 + code of every baked glyph.")
(defvar *glyph-f* (make-f32 0) "Per glyph 9 floats: atlas u0 v0 u1 v1, cell left, cell top (above the baseline), w, h, advance (em).")
(defvar *face-m* (make-f32 8) "Per face: ascent, descent (em; the line box's, as Chrome's).")

(defun paint-init ()
  "The RP_HUD pipeline and the stream (ENGINE-INIT). The atlas comes later from the game (PAINT-FONT-INIT + r_hud_atlas_new)."
  (make-pipeline 19 (wgsl "hud.vert.wgsl") "vs_hud" (wgsl "hud.frag.wgsl") "fs_hud" #x4444 2 0 1 0)   ; RP_HUD
  (setf *hud-batch* (make-stream-buffer 16 32768)))

(defun rgba (rgb &optional (a 1.0))
  "A colour for the emitters: #xRRGGBB and alpha -> f32vec (r g b a), sRGB 0..1."
  (let ((v (make-f32 4)))
    (setf (aref v 0) (/ (ldb (byte 8 16) rgb) 255f0) (aref v 1) (/ (ldb (byte 8 8) rgb) 255f0) (aref v 2) (/ (ldb (byte 8 0) rgb) 255f0)
          (aref v 3) (f32 a))
    v))

;;; ---------------------------------------------------------------- state setters (macros: float forms stay unboxed)
(defun paint-reset ()
  "Identity transform, opacity 1 (once a frame, before drawing)."
  (let ((m *paint-xf*)) (setf (aref m 0) 1f0 (aref m 1) 0f0 (aref m 2) 0f0 (aref m 3) 1f0 (aref m 4) 0f0 (aref m 5) 0f0 (aref m 6) 1f0)))

(defmacro paint-xform! (ox oy sx sy rot dx dy &optional (opacity 1f0))
  "The current transform: scale SX SY and rotate ROT (radians, clockwise on screen) about (OX OY), then translate by (DX DY);
the current opacity OPACITY. Single-float forms."
  `(let* ((ox ,ox) (oy ,oy) (sx ,sx) (sy ,sy) (rot ,rot) (cs (f-cos rot)) (sn (f-sin rot)) (m *paint-xf*))
     (declare (single-float ox oy sx sy rot cs sn))
     (setf (aref m 0) (* cs sx) (aref m 1) (* sn sx) (aref m 2) (- (* sn sy)) (aref m 3) (* cs sy)
           (aref m 4) (+ ox ,dx (- (+ (* (aref m 0) ox) (* (aref m 2) oy))))
           (aref m 5) (+ oy ,dy (- (+ (* (aref m 1) ox) (* (aref m 3) oy))))
           (aref m 6) ,opacity)))

(defmacro paint-clip! (x0 y0 x1 y1 &optional (gy0 0f0) (gy1 1f0))
  "PAINT-POLY's clip rectangle (local coordinates) and its gradient's top / bottom y."
  `(let ((c *paint-clip*)) (setf (aref c 0) ,x0 (aref c 1) ,y0 (aref c 2) ,x1 (aref c 3) ,y1 (aref c 4) ,gy0 (aref c 5) ,gy1)))

(defmacro paint-pen! (x y size &key (spacing 0f0) (edge 0.5f0) (soft 1f0) (skew 0f0))
  "The text pen at (X Y) (Y the baseline), SIZE px per em, letter SPACING (em), the SDF EDGE / SOFTness, the SKEW."
  `(let ((p *paint-pen*))
     (setf (aref p 0) ,x (aref p 1) ,y (aref p 2) ,size (aref p 3) ,spacing (aref p 4) ,edge (aref p 5) ,soft (aref p 6) ,skew)))

(defmacro paint-box! (cx cy hw hh radius feather border col)
  "A rounded box (mode 2) centred at (CX CY), half size HW HH, RADIUS, FEATHER (1 = antialiased), BORDER (0 = filled)."
  `(let ((b *paint-box*))
     (setf (aref b 0) ,cx (aref b 1) ,cy (aref b 2) ,hw (aref b 3) ,hh (aref b 4) ,radius (aref b 5) ,feather (aref b 6) ,border)
     (%paint-box ,col)))

(defmacro paint-rect (x y w h c0 &optional c1)
  "An axis-aligned rect, colour C0 at the top and C1 (default C0) at the bottom (flat, through PAINT-POLY; it sets the clip)."
  `(let* ((x0 ,x) (y0 ,y) (x1 (+ x0 ,w)) (y1 (+ y0 ,h)) (q *paint-q4*) (c0 ,c0))
     (declare (single-float x0 y0 x1 y1))
     (setf (aref q 0) x0 (aref q 1) y0 (aref q 2) x1 (aref q 3) y0 (aref q 4) x1 (aref q 5) y1 (aref q 6) x0 (aref q 7) y1)
     (paint-clip! x0 y0 x1 y1 y0 y1)
     (paint-poly q 4 c0 ,(or c1 'c0))))

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

(defun-fast paint-poly (pts n c0 c1)
  "A convex polygon (N points x y in the f32vec PTS, local coordinates) clipped to *PAINT-CLIP*'s rectangle, flat, coloured C0 at
the clip's gradient top and C1 at its bottom (linear in y). Sutherland-Hodgman, then a fan."
  (declare (type f32vec pts c0 c1) (fixnum n))
  (let* ((cl *paint-clip*) (a *paint-pa*) (b *paint-pb*) (k n))
    (declare (type f32vec cl a b) (fixnum k))
    (replace a pts :end2 (* 2 n))
    (dotimes (side 4)                                     ; x >= x0, y >= y0, x <= x1, y <= y1
      (let ((lim (aref cl side)) (axis (logand side 1)) (hi (>= side 2)) (m 0))
        (declare (single-float lim) (fixnum axis m))
        (macrolet ((in (i) `(let ((v (aref a (+ (* 2 ,i) axis)))) (declare (single-float v)) (if hi (<= v lim) (>= v lim)))))
          (dotimes (i k)
            (let* ((j (if (= (1+ i) k) 0 (1+ i))) (ii (in i)) (ij (in j)))
              (declare (fixnum j))
              (when ii (when (< m 31) (setf (aref b (* 2 m)) (aref a (* 2 i)) (aref b (1+ (* 2 m))) (aref a (1+ (* 2 i)))) (incf m)))
              (unless (eq ii ij)                          ; the edge crosses the line: its crossing point
                (let* ((pi0 (aref a (+ (* 2 i) axis))) (pj0 (aref a (+ (* 2 j) axis)))
                       (u (/ (- lim pi0) (let ((dd (- pj0 pi0))) (declare (single-float dd)) (if (= dd 0f0) 1f0 dd)))))
                  (declare (single-float pi0 pj0 u))
                  (when (< m 31)
                    (setf (aref b (* 2 m)) (+ (aref a (* 2 i)) (* u (- (aref a (* 2 j)) (aref a (* 2 i)))))
                          (aref b (1+ (* 2 m))) (+ (aref a (1+ (* 2 i))) (* u (- (aref a (1+ (* 2 j))) (aref a (1+ (* 2 i)))))))
                    (incf m))))))
          (rotatef a b) (setf k m))))
    (when (>= k 3)
      (let* ((gy0 (aref cl 4)) (gh (let ((h (- (aref cl 5) gy0))) (declare (single-float h)) (if (= h 0f0) 1f0 h))))
        (declare (single-float gy0 gh))
        (macrolet ((v (i) `(let* ((x (aref a (* 2 ,i))) (y (aref a (1+ (* 2 ,i))))
                                  (u (f-clamp (/ (- y gy0) gh) 0f0 1f0)) (w (- 1f0 u)))
                             (declare (single-float x y u w))
                             (hvtx x y 0f0 0f0 (+ (* w (aref c0 0)) (* u (aref c1 0))) (+ (* w (aref c0 1)) (* u (aref c1 1)))
                                   (+ (* w (aref c0 2)) (* u (aref c1 2))) (+ (* w (aref c0 3)) (* u (aref c1 3)))
                                   0f0 0f0 0f0 0f0 0f0 0f0 0f0 0f0))))
          (with-hud-verts ((* 3 (- k 2)))
            (loop for i of-type fixnum from 1 below (1- k) do (v 0) (v i) (v (1+ i)))))))
    nil))

(defun-fast %paint-box (col)
  "Body of PAINT-BOX!: one quad grown by the feather, mode 2."
  (declare (type f32vec col))
  (let* ((b *paint-box*) (cx (aref b 0)) (cy (aref b 1)) (hw (aref b 2)) (hh (aref b 3)) (f (aref b 5))
         (ex (+ hw f)) (ey (+ hh f)) (r (aref col 0)) (g (aref col 1)) (bl (aref col 2)) (a (aref col 3))
         (rad (aref b 4)) (bord (aref b 6)))
    (declare (type f32vec b) (single-float cx cy hw hh f ex ey r g bl a rad bord))
    (macrolet ((v (sx sy) `(hvtx (+ cx (* ,sx ex)) (+ cy (* ,sy ey)) (* ,sx ex) (* ,sy ey) r g bl a 2f0 hw hh rad f bord 0f0 0f0)))
      (with-hud-verts (6) (v -1f0 -1f0) (v 1f0 -1f0) (v 1f0 1f0) (v -1f0 -1f0) (v 1f0 1f0) (v -1f0 1f0)))
    nil))

;;; ---------------------------------------------------------------- text: the baked atlas (tools/sdf-bake.py)
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
      (setf *glyph-keys* keys *glyph-f* gf)
      (values aw ah))))

(defun-fast glyph-find (face code big)
  "The glyph index of CODE in FACE (0 display, 1 mono, 2 kanji, 3 sans): the display tier first when BIG, else the body tier; a
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
        (when big (setf g (look (+ (* (+ 4 face) 65536) code))))
        (when (< g 0) (setf g (look (+ (* face 65536) code))))
        (when (< g 0) (setf g (look (+ (* 3 65536) code))))
        (when (< g 0) (setf g (look (+ (* 2 65536) code))))
        (when (< g 0) (setf g (look (+ (* 3 65536) #x25A1))))
        g))))

(defconstant +big-px+ 40f0 "Glyphs drawn larger than this (px per em) use the display tier when it has them.")

(defun-fast %paint-run (s face col draw)
  "PAINT-TEXT / PAINT-MEASURE: the run S (a string) in FACE at the pen; DRAW nil only measures (into pen [7])."
  (declare (simple-string s) (fixnum face) (type f32vec col))
  (let* ((p *paint-pen*) (gf *glyph-f*) (x (aref p 0)) (y (aref p 1)) (size (aref p 2)) (ls (* size (aref p 3)))
         (edge (aref p 4)) (soft (aref p 5)) (skew (aref p 6)) (big (> size +big-px+)) (x0 x)
         (r (aref col 0)) (g (aref col 1)) (b (aref col 2)) (a (aref col 3)))
    (declare (type f32vec p gf) (single-float x y size ls edge soft skew x0 r g b a))
    (dotimes (i (length s))
      (let ((gi (glyph-find face (char-code (char s i)) big)))
        (declare (fixnum gi))
        (when (>= gi 0)
          (let ((o (* 9 gi)))
            (declare (fixnum o))
            (when (and draw (> (aref gf (+ o 6)) 0f0))
              (let* ((gx0 (+ x (* size (aref gf (+ o 4))))) (gy0 (- y (* size (aref gf (+ o 5)))))
                     (gx1 (+ gx0 (* size (aref gf (+ o 6))))) (gy1 (+ gy0 (* size (aref gf (+ o 7)))))
                     (k0 (* skew (- y gy0))) (k1 (* skew (- y gy1)))
                     (u0 (aref gf o)) (v0 (aref gf (+ o 1))) (u1 (aref gf (+ o 2))) (v1 (aref gf (+ o 3))))
                (declare (single-float gx0 gy0 gx1 gy1 k0 k1 u0 v0 u1 v1))
                (macrolet ((v (xx yy uu vv) `(hvtx ,xx ,yy ,uu ,vv r g b a 1f0 edge soft 0f0 0f0 0f0 0f0 0f0)))
                  (with-hud-verts (6)
                    (v (+ gx0 k0) gy0 u0 v0) (v (+ gx1 k0) gy0 u1 v0) (v (+ gx1 k1) gy1 u1 v1)
                    (v (+ gx0 k0) gy0 u0 v0) (v (+ gx1 k1) gy1 u1 v1) (v (+ gx0 k1) gy1 u0 v1)))))
            (setf x (+ x (* size (aref gf (+ o 8))) ls))))))
    (if draw (setf (aref p 0) x) (setf (aref p 7) (- x x0)))
    nil))

(defun paint-text (s face col) "Draw the string S in FACE at the pen (it advances)." (%paint-run s face col t))
(defun paint-measure (s face) "The advance of S in FACE at the pen's size and spacing, into pen [7]." (%paint-run s face *paint-q4* nil))

(defvar *digit-strs* (coerce (loop for d below 10 collect (string (code-char (+ 48 d)))) 'simple-vector))
(defun-fast %paint-int (n face col draw)
  "PAINT-INT / PAINT-MEASURE-INT: the decimal digits of the fixnum N (0 B: no string is made)."
  (declare (fixnum n face))
  (let* ((p *paint-pen*) (x0 (aref p 0)) (div 1) (m (abs n)) (w 0f0))
    (declare (type f32vec p) (single-float x0 w) (fixnum div m))
    (loop while (>= m (* div 10)) do (setf div (* div 10)))
    (loop while (>= div 1)
          do (let ((s (svref *digit-strs* (mod (floor m div) 10))))
               (if draw (%paint-run s face col t)
                   (progn (%paint-run s face col nil) (setf w (+ w (aref p 7)))))
               (setf div (floor div 10))))
    (unless draw (setf (aref p 7) w (aref p 0) x0))
    nil))
(defun paint-int (n face col) "Draw the integer N in FACE at the pen (it advances)." (%paint-int n face col t))
(defun paint-measure-int (n face) "The advance of the integer N in FACE, into pen [7]." (%paint-int n face *paint-q4* nil))

(defmacro face-ascent (face) `(aref *face-m* (* 2 ,face)))
(defmacro face-descent (face) `(aref *face-m* (1+ (* 2 ,face))))

;;; ---------------------------------------------------------------- easing (CSS cubic-bézier curves)
;;; ponytail: Newton on x(t) at each call (6 steps) and a fixed list of curves; phase 1c's tween.lisp makes tables and keyframes.
(defvar *ease-pts* (let ((v (make-f32 20)))
                     (replace v '(0f0 0f0 1f0 1f0  0.25f0 0.1f0 0.25f0 1f0  0.16f0 1f0 0.3f0 1f0  0.7f0 0f0 0.2f0 1f0  0.2f0 1.6f0 0.4f0 1f0))
                     v)
  "Curve k's x1 y1 x2 y2: 0 linear, 1 ease, 2 ease-out (.16,1,.3,1), 3 ease-cut (.7,0,.2,1), 4 ease-snap (.2,1.6,.4,1).")

(defun-fast-inline ease-curve (k u)
  "CSS cubic-bezier K (see *EASE-PTS*) at progress U (clamped 0..1)."
  (declare (fixnum k) (single-float u))
  (let* ((e *ease-pts*) (o (* 4 k)) (x1 (aref e o)) (y1 (aref e (+ o 1))) (x2 (aref e (+ o 2))) (y2 (aref e (+ o 3)))
         (u (f-clamp u 0f0 1f0)) (tt u))
    (declare (type f32vec e) (fixnum o) (single-float x1 y1 x2 y2 u tt))
    (dotimes (i 6)
      (let* ((mt (- 1f0 tt)) (x (+ (* 3f0 mt mt tt x1) (* 3f0 mt tt tt x2) (* tt tt tt)))
             (dx (+ (* 3f0 mt mt x1) (* 6f0 mt tt (- x2 x1)) (* 3f0 tt tt (- 1f0 x2)))))
        (declare (single-float mt x dx))
        (when (> (f-abs dx) 1f-5) (setf tt (f-clamp (- tt (/ (- x u) dx)) 0f0 1f0)))))
    (let ((mt (- 1f0 tt))) (declare (single-float mt)) (+ (* 3f0 mt mt tt y1) (* 3f0 mt tt tt y2) (* tt tt tt)))))

;;; ---------------------------------------------------------------- the UI clock (real time: hitstop, slow motion, pause do not stop it)
(declaim (type f32vec *ui-clock*))
(defvar *ui-clock* (make-f32 1) "[0] seconds of real (unscaled) frame time, advanced by PAINT-CLOCK-ADVANCE once a frame (DUEL_LISP_HUD §4.4).")
(defun-fast paint-clock-advance () "Advance *UI-CLOCK* by this frame's unclamped dt." (incf (aref *ui-clock* 0) (aref *input* 11)) nil)
