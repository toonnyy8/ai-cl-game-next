;;;; paint-shapes.lisp — the paint stream's shapes and drawing state (docs/duel/DUEL_LISP_HUD.md §4.1, §10), after
;;;; paint.lisp (its vertex macro WITH-HUD-VERTS and text runs). Every emitter writes into *HUD-BATCH* (or *HUD-BACK* inside
;;;; WITH-PAINT-BACK) through the current transform and opacity, 0 B a frame: float inputs travel in f32vecs set by macros.
;;;;   - polygons (PAINT-POLY): convex or star-shaped about their fan centre, cut to a rectangle and the scissor, with analytic
;;;;     antialiasing: a fan from the centre, each triangle carrying the signed distance to its outer edge (exact under any affine
;;;;     transform, hud.frag.wgsl mode 0), the outline pushed out one screen pixel along the edges' miters; edges made by the cut
;;;;     are antialiased only where the cut's mask asks (a gradient split in two bands must not show a seam);
;;;;   - linear gradients along any axis (PAINT-GRAD!), radial fans with ring stops (PAINT-RADIAL!);
;;;;   - patterns on polygons (PAINT-DOTS! screen halftone, PAINT-STRIPES! lines fixed to the shape's local frame);
;;;;   - rounded boxes (PAINT-BOX!, mode 2) and ellipses / rings / arcs (PAINT-ELLIPSE!, mode 3) with a feather in screen pixels
;;;;     (1 = antialiased, more = a soft shadow / glow), cut by the scissor on the CPU (a disc cut from below = an ink level);
;;;;   - strokes (PAINT-STROKE!): one rotated mode-2 box a segment, round or butt ends, a drawn fraction;
;;;;   - the transform / scissor / pattern / opacity stack (PAINT-PUSH / PAINT-POP, PAINT-TRANSFORM!, PAINT-OPACITY!,
;;;;     PAINT-SCISSOR!), SVG path flattening at init (PATH-POINTS), the back layer (WITH-PAINT-BACK).
;;;; ponytail: opacity multiplies each primitive (CSS group opacity renders the group first: overlaps differ, e.g. a text's hard
;;;; shadow shows through at .3); the scissor is a rectangle in the emitters' local frame (no convex clip regions) and cuts
;;;; polygons, boxes and ellipses, not strokes or radial fans; strokes overlap at joints (translucent ones darken there); no
;;;; paper grain. Add each when a screen needs it.
(in-package :engine)

(defconstant +paint-max-pts+ 72 "Points a polygon may have after its cut.")
(defconstant +paint-depth+ 8 "Levels of PAINT-PUSH.")
(defconstant +paint-frame+ 17 "Floats a stack level holds: the transform and opacity (7), the scissor (4), the pattern (6).")
(defconstant +radial-segs+ 32 "Segments of a radial fan's full turn.")

(declaim (type f32vec *paint-opt* *paint-stack* *paint-l* *paint-ell* *paint-sa* *paint-sb* *paint-fa*
               *paint-fb* *paint-nv* *paint-mv* *paint-cs*)
         (type (simple-array fixnum (*)) *paint-sp*))
(defvar *paint-opt* (make-f32 8)
  "PAINT-POLY's options, reset by PAINT-CLIP!: [0..3] the gradient axis x0 y0 x1 y1 (C0 at the first point, C1 at the second;
PAINT-CLIP!'s GY0 GY1 or PAINT-GRAD!), [4] the cut's antialiasing mask (bits 1 x0, 2 y0, 4 x1, 8 y1: an edge the cut makes on that
side is antialiased), [5] 1 = fan from [6] [7] (PAINT-CENTRE!, a star-shaped polygon) instead of the points' average.")
;;; (*PAINT-SC* the scissor and *PAINT-PAT* the pattern live in paint.lisp: its glyph quads read them too)
(defvar *paint-stack* (make-f32 (* +paint-depth+ +paint-frame+)) "PAINT-PUSH's saved levels.")
(defvar *paint-sp* (make-array 1 :element-type 'fixnum :initial-element 0) "[0] the stack's depth.")
(defvar *paint-l* (make-f32 8) "PAINT-TRANSFORM!'s ox oy sx sy rot skew dx dy.")
(defvar *paint-ell* (make-f32 8) "PAINT-ELLIPSE!'s cx cy rx ry thick feather frac dir; PAINT-RADIAL!'s cx cy rx ry; PAINT-STROKE!'s width frac.")
(defvar *paint-sa* (make-f32 (* 2 +paint-max-pts+))) (defvar *paint-sb* (make-f32 (* 2 +paint-max-pts+)))   ; (cut points)
(defvar *paint-fa* (make-f32 +paint-max-pts+)) (defvar *paint-fb* (make-f32 +paint-max-pts+))               ; (edge AA flags)
(defvar *paint-nv* (make-f32 (* 2 +paint-max-pts+))) (defvar *paint-mv* (make-f32 (* 2 +paint-max-pts+)))   ; (normals, miters)
(defvar *paint-cs* (let ((v (make-f32 (* 2 (1+ +radial-segs+)))))
                     (dotimes (j (1+ +radial-segs+) v)
                       (let ((a (/ (* 2 pi j) +radial-segs+)))
                         (setf (aref v (* 2 j)) (f32 (cos a)) (aref v (1+ (* 2 j))) (f32 (sin a))))))
  "cos, sin of the radial fan's segment angles.")

(defun paint-shapes-init ()
  "The back layer's stream and its composite pipeline RP_COMP_AO (slot 20: fs_comp_a, premultiplied over; PAINT-INIT)."
  (make-pipeline 20 (wgsl "fullscreen.vert.wgsl") "vs_tri" (wgsl "composite.frag.wgsl") "fs_comp_a" 0 2 0 4 0)   ; RP_COMP_AO
  (setf *hud-back* (make-stream-buffer 16 8192))
  (paint-reset))

(defmacro with-paint-back (&body body)
  "BODY's emitters draw into the back layer: under the scene of a transparent frame (*RENDER-TRANSPARENT*), the composite blended
premultiplied over it (SELECT's cards behind the fighter, DUEL_LISP_HUD §4.1). Nothing shows on an opaque frame."
  `(let ((*hud-batch* *hud-back*)) ,@body))

;;; ---------------------------------------------------------------- state: transform, opacity, scissor, pattern, the stack
(defun-fast paint-reset ()
  "Identity transform, opacity 1, the scissor open, no pattern, an empty stack (once an element, before drawing)."
  (let ((m *paint-xf*) (s *paint-sc*) (p *paint-pat*))
    (setf (aref m 0) 1f0 (aref m 1) 0f0 (aref m 2) 0f0 (aref m 3) 1f0 (aref m 4) 0f0 (aref m 5) 0f0 (aref m 6) 1f0
          (aref s 0) -1f6 (aref s 1) -1f6 (aref s 2) 1f6 (aref s 3) 1f6 (aref p 0) 0f0 (aref p 1) 0f0
          (aref *paint-sp* 0) 0))
  nil)

(defun-fast paint-push ()
  "Save the transform, opacity, scissor and pattern (PAINT-POP restores them; 8 levels, deeper pushes are counted, not saved)."
  (let ((d (aref *paint-sp* 0)) (st *paint-stack*))
    (declare (fixnum d))
    (when (< d +paint-depth+)
      (let ((o (* d +paint-frame+)))
        (declare (fixnum o))
        (replace st *paint-xf* :start1 o :end2 7) (replace st *paint-sc* :start1 (+ o 7) :end2 4)
        (replace st *paint-pat* :start1 (+ o 11) :end2 6)))
    (setf (aref *paint-sp* 0) (1+ d)))
  nil)

(defun-fast paint-pop ()
  "Restore what the matching PAINT-PUSH saved."
  (let ((d (1- (aref *paint-sp* 0))) (st *paint-stack*))
    (declare (fixnum d))
    (when (>= d 0)
      (setf (aref *paint-sp* 0) d)
      (when (< d +paint-depth+)
        (let ((o (* d +paint-frame+)))
          (declare (fixnum o))
          (replace *paint-xf* st :start2 o :end2 (+ o 7)) (replace *paint-sc* st :start2 (+ o 7) :end2 (+ o 11))
          (replace *paint-pat* st :start2 (+ o 11) :end2 (+ o 17))))))
  nil)

(defmacro paint-xform! (ox oy sx sy rot dx dy &optional (opacity 1f0))
  "The current transform, absolute: scale SX SY and rotate ROT (radians, clockwise on screen) about (OX OY), then translate by
(DX DY); the current opacity OPACITY. Single-float forms."
  (let ((g (loop repeat 8 collect (gensym))))
    (destructuring-bind (gox goy gsx gsy grot gdx gdy gop) g
      `(let* ((,gox ,ox) (,goy ,oy) (,gsx ,sx) (,gsy ,sy) (,grot ,rot) (,gdx ,dx) (,gdy ,dy) (,gop ,opacity))
         (declare (single-float ,@g))
         (let* ((cs (f-cos ,grot)) (sn (f-sin ,grot)) (m *paint-xf*))
           (declare (single-float cs sn))
           (setf (aref m 0) (* cs ,gsx) (aref m 1) (* sn ,gsx) (aref m 2) (- (* sn ,gsy)) (aref m 3) (* cs ,gsy)
                 (aref m 4) (+ ,gox ,gdx (- (+ (* (aref m 0) ,gox) (* (aref m 2) ,goy))))
                 (aref m 5) (+ ,goy ,gdy (- (+ (* (aref m 1) ,gox) (* (aref m 3) ,goy))))
                 (aref m 6) ,gop))))))

(defmacro paint-transform! (ox oy &key (sx 1f0) (sy 1f0) (rot 0f0) (skew 0f0) (dx 0f0) (dy 0f0))
  "Compose onto the current transform (CSS order, about the origin (OX OY)): translate (DX DY), rotate ROT (radians, clockwise on
screen), scale SX SY, skewX by SKEW (x += SKEW y: the tangent of the CSS angle, negated for skewX(-a)). Single-float forms."
  `(progn (%f32-set *paint-l* ,ox ,oy ,sx ,sy ,rot ,skew ,dx ,dy) (%paint-compose)))

(defun-fast %paint-compose ()
  "Body of PAINT-TRANSFORM!: *PAINT-XF* = *PAINT-XF* x the local transform in *PAINT-L*."
  (let* ((l *paint-l*) (m *paint-xf*) (ox (aref l 0)) (oy (aref l 1)) (sx (aref l 2)) (sy (aref l 3)) (k (aref l 5))
         (cs (f-cos (aref l 4))) (sn (f-sin (aref l 4)))
         (la (* cs sx)) (lb (* sn sx)) (lc (- (* cs sx k) (* sn sy))) (ld (+ (* sn sx k) (* cs sy)))
         (le (- (+ ox (aref l 6)) (+ (* la ox) (* lc oy)))) (lf (- (+ oy (aref l 7)) (+ (* lb ox) (* ld oy))))
         (ma (aref m 0)) (mb (aref m 1)) (mc (aref m 2)) (md (aref m 3)) (me (aref m 4)) (mf (aref m 5)))
    (declare (type f32vec l m) (single-float ox oy sx sy k cs sn la lb lc ld le lf ma mb mc md me mf))
    (setf (aref m 0) (+ (* ma la) (* mc lb)) (aref m 1) (+ (* mb la) (* md lb))
          (aref m 2) (+ (* ma lc) (* mc ld)) (aref m 3) (+ (* mb lc) (* md ld))
          (aref m 4) (+ (* ma le) (* mc lf) me) (aref m 5) (+ (* mb le) (* md lf) mf)))
  nil)

(defmacro paint-opacity! (a)
  "Multiply the current opacity by A (a group's fade: PAINT-PUSH first)."
  (let ((m (gensym "M"))) `(let ((,m *paint-xf*)) (setf (aref ,m 6) (* (aref ,m 6) ,a)))))

(defmacro paint-scissor! (x0 y0 x1 y1)
  "The scissor (replaced, not intersected; PAINT-PUSH / PAINT-POP to nest): later polygons, boxes, ellipses and glyphs are cut to
the rectangle X0 Y0 X1 Y1, in their own local coordinates (set it after the transform it belongs to)."
  `(%f32-set *paint-sc* ,x0 ,y0 ,x1 ,y1))

(defmacro paint-dots! (pitch radius)
  "Later polygons and glyphs are a halftone: dots of RADIUS on a PITCH grid, screen pixels (CSS radial-gradient dots x the dpr)."
  `(%f32-set *paint-pat* ,radius ,pitch))

(defmacro paint-stripes! (ox oy dx dy pitch width)
  "Later polygons are only lines across the unit axis (DX DY): WIDTH wide every PITCH, from (OX OY), local units (CSS
repeating-linear-gradient; fixed to the shape, so they turn and scale with it). Glyphs ignore stripes."
  `(%f32-set *paint-pat* ,width (- ,pitch) ,ox ,oy ,dx ,dy))

(defmacro paint-pattern-off! () "No pattern." `(setf (aref *paint-pat* 1) 0f0))

;;; ---------------------------------------------------------------- polygons
(defmacro %paint-px ()
  "One screen pixel in local units under the current transform (similarity: exact). In C: Lisp arithmetic here boxed (64 B a call)."
  `(ffi:c-inline (*paint-xf*) (t) :float
                 "{ float *m = #0->vector.self.sf; @(return) = 1.0f / sqrtf(fmaxf(fabsf(m[0] * m[3] - m[1] * m[2]), 1e-12f)); }"))

(defmacro paint-clip! (x0 y0 x1 y1 &optional (gy0 0f0) (gy1 1f0) (aa 0))
  "PAINT-POLY's cut rectangle (local coordinates), its vertical gradient from GY0 (colour C0) to GY1 (C1), and the cut's AA mask AA
(bits 1 x0, 2 y0, 4 x1, 8 y1). Resets PAINT-GRAD! and PAINT-CENTRE!; set those after it."
  `(progn (%f32-set *paint-clip* ,x0 ,y0 ,x1 ,y1)
          (%f32-set *paint-opt* 0f0 ,gy0 0f0 ,gy1 ,(if (integerp aa) (float aa 1f0) `(i->f ,aa)) 0f0)))

(defmacro paint-grad! (x0 y0 x1 y1)
  "PAINT-POLY's gradient along the axis (X0 Y0) -> (X1 Y1): colour C0 at the first point, C1 at the second, clamped beyond."
  `(%f32-set *paint-opt* ,x0 ,y0 ,x1 ,y1))

(defmacro paint-centre! (x y)
  "PAINT-POLY fans from (X Y), a point that sees the whole outline (a star-shaped polygon: the soul flame), until PAINT-CLIP!. Such
a fill is aliased (the per-triangle edge distance leaves pinholes near reflex vertices): draw its outline as a stroke over it, as
the SVG flame does."
  `(%f32-set *paint-opt* nil nil nil nil nil 1f0 ,x ,y))

(defmacro paint-rect (x y w h c0 &optional c1)
  "An axis-aligned rect, colour C0 at the top and C1 (default C0) at the bottom (through PAINT-POLY; it sets the cut)."
  (let ((x0 (gensym "X0")) (y0 (gensym "Y0")) (x1 (gensym "X1")) (y1 (gensym "Y1")) (k0 (gensym "C0")))
    `(let* ((,x0 ,x) (,y0 ,y) (,x1 (+ ,x0 ,w)) (,y1 (+ ,y0 ,h)) (,k0 ,c0))
       (declare (single-float ,x0 ,y0 ,x1 ,y1))
       (%f32-set *paint-q4* ,x0 ,y0 ,x1 ,y0 ,x1 ,y1 ,x0 ,y1)
       (paint-clip! ,x0 ,y0 ,x1 ,y1 ,y0 ,y1)
       (paint-poly *paint-q4* 4 ,k0 ,(or c1 k0)))))

(defun-fast %paint-cut (k)
  "Sutherland-Hodgman of the K points in *PAINT-SA* (edge flags in *PAINT-FA*) against the cut rectangle and the scissor, in place;
an edge the cut makes takes its side's bit of the AA mask (the scissor's never antialias). The count left."
  (declare (fixnum k))
  (let* ((cl *paint-clip*) (sc *paint-sc*) (mask (f->i (aref *paint-opt* 4))) (a *paint-sa*) (b *paint-sb*) (af *paint-fa*) (bf *paint-fb*))
    (declare (type f32vec cl sc a b af bf) (fixnum mask))
    (dotimes (side 4)                                     ; x >= x0, y >= y0, x <= x1, y <= y1
      (let* ((hi (>= side 2)) (lc (aref cl side)) (ls (aref sc side))
             (lim (if hi (f-min lc ls) (f-max lc ls))) (axis (logand side 1)) (m 0)
             (cf (if (and (logbitp side mask) (if hi (<= lc ls) (>= lc ls))) 1f0 0f0)))
        (declare (single-float lc ls lim cf) (fixnum axis m))
        (macrolet ((in (i) `(let ((v (aref a (+ (* 2 ,i) axis)))) (declare (single-float v)) (if hi (<= v lim) (>= v lim))))
                   (out (x y f) `(when (< m +paint-max-pts+)
                                   (setf (aref b (* 2 m)) ,x (aref b (1+ (* 2 m))) ,y (aref bf m) ,f) (incf m))))
          (dotimes (i k)
            (let* ((j (if (= (1+ i) k) 0 (1+ i))) (ii (in i)) (ij (in j)))
              (declare (fixnum j))
              (when ii (out (aref a (* 2 i)) (aref a (1+ (* 2 i))) (aref af i)))
              (unless (eq ii ij)                          ; the edge crosses the line: its crossing point
                (let* ((pi0 (aref a (+ (* 2 i) axis))) (pj0 (aref a (+ (* 2 j) axis)))
                       (u (/ (- lim pi0) (let ((dd (- pj0 pi0))) (declare (single-float dd)) (if (= dd 0f0) 1f0 dd)))))
                  (declare (single-float pi0 pj0 u))
                  (out (+ (aref a (* 2 i)) (* u (- (aref a (* 2 j)) (aref a (* 2 i)))))
                       (+ (aref a (1+ (* 2 i))) (* u (- (aref a (1+ (* 2 j))) (aref a (1+ (* 2 i))))))
                       (if ii cf (aref af i)))))))
          (rotatef a b) (rotatef af bf) (setf k m))))
    k))                                                   ; (four passes: the result is back in *PAINT-SA* / *PAINT-FA*)

(defun-fast paint-poly (pts n c0 c1)
  "A convex polygon (N points x y in the f32vec PTS, local coordinates; star-shaped about PAINT-CENTRE!) cut to *PAINT-CLIP*'s
rectangle and the scissor, flat, coloured C0 -> C1 along the gradient axis, antialiased (see %PAINT-FAN), patterned by
*PAINT-PAT*. Vertices: 3 x the points left after the cut."
  (declare (type f32vec pts c0 c1) (fixnum n))
  (let ((k (min n +paint-max-pts+)) (af *paint-fa*))
    (declare (fixnum k) (type f32vec af))
    (replace *paint-sa* pts :end2 (* 2 k))
    (dotimes (i k) (setf (aref af i) (if (> (aref *paint-opt* 5) 0.5f0) 0f0 1f0)))   ; (a star: aliased, see PAINT-CENTRE!)
    (%paint-fan (%paint-cut k) c0 c1))
  nil)

(defun-fast %paint-fan (k c0 c1)
  "The K points in *PAINT-SA* as a fan from their centre, K triangles. Each triangle's outer edge, when its flag in *PAINT-FA* is
set, is antialiased analytically: uv.x carries the signed distance to the edge's line (local units, > 0 inside; affine, so the
shader's division by its screen gradient gives exact pixels), and the outline is pushed out one screen pixel along the miters
(an edge without AA is not moved; miters capped at 3 px) so the half-pixel ramp outside the edge has fragments."
  (declare (fixnum k) (type f32vec c0 c1))
  (when (>= k 3)
    (let* ((a *paint-sa*) (af *paint-fa*) (nv *paint-nv*) (mv *paint-mv*) (o *paint-opt*) (pt *paint-pat*) (m *paint-xf*)
           (off (%paint-px))
           (area 0f0) (cx 0f0) (cy 0f0) (sgn 1f0)
           (g0x (aref o 0)) (g0y (aref o 1)) (gdx (- (aref o 2) g0x)) (gdy (- (aref o 3) g0y))
           (gl (+ (* gdx gdx) (* gdy gdy))) (ginv (if (> gl 1f-12) (/ 1f0 gl) 0f0))
           (pq (aref pt 0)) (pw (aref pt 1)) (pox (aref pt 2)) (poy (aref pt 3)) (pdx (aref pt 4)) (pdy (aref pt 5)))
      (declare (type f32vec a af nv mv o pt m) (single-float off area cx cy sgn g0x g0y gdx gdy gl ginv pq pw pox poy pdx pdy))
      (dotimes (i k)
        (let ((j (if (= (1+ i) k) 0 (1+ i))))
          (declare (fixnum j))
          (incf area (- (* (aref a (* 2 i)) (aref a (1+ (* 2 j)))) (* (aref a (* 2 j)) (aref a (1+ (* 2 i))))))
          (incf cx (aref a (* 2 i))) (incf cy (aref a (1+ (* 2 i))))))
      (setf sgn (if (>= area 0f0) 1f0 -1f0) cx (/ cx (i->f k)) cy (/ cy (i->f k)))
      (when (> (aref o 5) 0.5f0) (setf cx (aref o 6) cy (aref o 7)))
      (dotimes (i k)                                      ; outward unit normals (0 0 for a degenerate edge: no AA)
        (let* ((j (if (= (1+ i) k) 0 (1+ i))) (ex (- (aref a (* 2 j)) (aref a (* 2 i)))) (ey (- (aref a (1+ (* 2 j))) (aref a (1+ (* 2 i)))))
               (len (f-sqrt (+ (* ex ex) (* ey ey)))))
          (declare (fixnum j) (single-float ex ey len))
          (if (> len 1f-6)
              (setf (aref nv (* 2 i)) (/ (* sgn ey) len) (aref nv (1+ (* 2 i))) (/ (* sgn (- ex)) len))
              (setf (aref nv (* 2 i)) 0f0 (aref nv (1+ (* 2 i))) 0f0 (aref af i) 0f0))))
      (dotimes (j k)                                      ; miter points: n_a . d = o_a, n_b . d = o_b
        (let* ((i (if (= j 0) (1- k) (1- j)))
               (nax (aref nv (* 2 i))) (nay (aref nv (1+ (* 2 i)))) (nbx (aref nv (* 2 j))) (nby (aref nv (1+ (* 2 j))))
               (oa (if (> (aref af i) 0.5f0) off 0f0)) (ob (if (> (aref af j) 0.5f0) off 0f0))
               (den (- (* nax nby) (* nay nbx))) (dx 0f0) (dy 0f0))
          (declare (fixnum i) (single-float nax nay nbx nby oa ob den dx dy))
          (if (> (f-abs den) 1f-3)
              (setf dx (/ (- (* oa nby) (* ob nay)) den) dy (/ (- (* nax ob) (* nbx oa)) den))
              (if (>= oa ob) (setf dx (* oa nax) dy (* oa nay)) (setf dx (* ob nbx) dy (* ob nby))))
          (let ((dl (f-sqrt (+ (* dx dx) (* dy dy)))) (cap (* 3f0 off)))
            (declare (single-float dl cap))
            (when (> dl cap) (setf dx (* dx (/ cap dl)) dy (* dy (/ cap dl)))))
          (setf (aref mv (* 2 j)) (+ (aref a (* 2 j)) dx) (aref mv (1+ (* 2 j))) (+ (aref a (1+ (* 2 j))) dy))))
      (macrolet ((v (x y dist dp dn aa)
                   `(let* ((x ,x) (y ,y) (u (f-clamp (* (+ (* (- x g0x) gdx) (* (- y g0y) gdy)) ginv) 0f0 1f0)) (w (- 1f0 u)))
                      (declare (single-float x y u w))
                      (hvtx x y ,dist (+ (* (- x pox) pdx) (* (- y poy) pdy))
                            (+ (* w (aref c0 0)) (* u (aref c1 0))) (+ (* w (aref c0 1)) (* u (aref c1 1)))
                            (+ (* w (aref c0 2)) (* u (aref c1 2))) (+ (* w (aref c0 3)) (* u (aref c1 3)))
                            0f0 ,aa ,dp ,dn pq 0f0 0f0 pw))))
        (with-hud-verts ((* 3 k))
          (dotimes (i k)
            ;; the outer edge's distance, and the two neighbours' at convex corners (the fan triangle reaches past them there:
            ;; a flat triangle's ray to a pushed-out corner runs above the next edge for many pixels); 1e4 = no edge
            (let* ((j (if (= (1+ i) k) 0 (1+ i))) (ip (if (= i 0) (1- k) (1- i)))
                   (vx (aref a (* 2 i))) (vy (aref a (1+ (* 2 i)))) (wx (aref a (* 2 j))) (wy (aref a (1+ (* 2 j))))
                   (nox (aref nv (* 2 i))) (noy (aref nv (1+ (* 2 i)))) (npx (aref nv (* 2 ip))) (npy (aref nv (1+ (* 2 ip))))
                   (nnx (aref nv (* 2 j))) (nny (aref nv (1+ (* 2 j))))
                   (dc (- (+ (* nox (- cx vx)) (* noy (- cy vy)))))
                   (own (and (> (aref af i) 0.5f0) (> dc 0f0)))   ; (a centre behind the edge: a sliver outside the kernel)
                   (pre (and (> (aref af ip) 0.5f0) (> (* sgn (- (* npx noy) (* npy nox))) 0f0)))
                   (nxt (and (> (aref af j) 0.5f0) (> (* sgn (- (* nox nny) (* noy nnx))) 0f0)))
                   (aa (if (or own pre nxt) 1f0 0f0))
                   (x0 (aref mv (* 2 i))) (y0 (aref mv (1+ (* 2 i)))) (x1 (aref mv (* 2 j))) (y1 (aref mv (1+ (* 2 j)))))
              (declare (fixnum j ip) (single-float vx vy wx wy nox noy npx npy nnx nny dc aa x0 y0 x1 y1))
              (macrolet ((dist (x y) `(if own (- (+ (* nox (- ,x vx)) (* noy (- ,y vy)))) 1f4))
                         (dpre (x y) `(if pre (- (+ (* npx (- ,x vx)) (* npy (- ,y vy)))) 1f4))
                         (dnxt (x y) `(if nxt (- (+ (* nnx (- ,x wx)) (* nny (- ,y wy)))) 1f4)))
                (v cx cy (dist cx cy) (dpre cx cy) (dnxt cx cy) aa)
                (v x0 y0 (dist x0 y0) (dpre x0 y0) (dnxt x0 y0) aa)
                (v x1 y1 (dist x1 y1) (dpre x1 y1) (dnxt x1 y1) aa))))))))
  nil)

;;; ---------------------------------------------------------------- boxes, ellipses, strokes, radial fans

(defmacro %cut-quad ((cx cy ex ey) &body body)
  "BODY with X0 Y0 X1 Y1 = the axis-aligned quad (CX CY) +- (EX EY) cut to the scissor (skipped when nothing is left)."
  `(let* ((s *paint-sc*) (x0 (f-max (- ,cx ,ex) (aref s 0))) (y0 (f-max (- ,cy ,ey) (aref s 1)))
          (x1 (f-min (+ ,cx ,ex) (aref s 2))) (y1 (f-min (+ ,cy ,ey) (aref s 3))))
     (declare (type f32vec s) (single-float x0 y0 x1 y1))
     (when (and (< x0 x1) (< y0 y1)) ,@body)))

(defmacro paint-box! (cx cy hw hh radius feather border col)
  "A rounded box (mode 2) centred at (CX CY), half size HW HH, RADIUS, BORDER (0 = filled) in local units, FEATHER in screen
pixels (1 = antialiased, more = soft: a box-shadow's blur is about twice its value). 6 vertices; cut by the scissor."
  `(progn (%f32-set *paint-box* ,cx ,cy ,hw ,hh ,radius ,feather ,border) (%paint-box ,col)))

(defun-fast %paint-box (col)
  "Body of PAINT-BOX!: one quad grown by the feather, mode 2."
  (declare (type f32vec col))
  (let* ((b *paint-box*) (cx (aref b 0)) (cy (aref b 1)) (hw (aref b 2)) (hh (aref b 3)) (f (aref b 5))
         (ex (+ hw (* f (%paint-px)))) (ey (+ hh (* f (%paint-px)))) (r (aref col 0)) (g (aref col 1)) (bl (aref col 2)) (a (aref col 3))
         (rad (aref b 4)) (bord (aref b 6)))
    (declare (type f32vec b) (single-float cx cy hw hh f ex ey r g bl a rad bord))
    (%cut-quad (cx cy ex ey)
      (macrolet ((v (x y) `(hvtx ,x ,y (- ,x cx) (- ,y cy) r g bl a 2f0 hw hh rad f bord 0f0 0f0)))
        (with-hud-verts (6) (v x0 y0) (v x1 y0) (v x1 y1) (v x0 y0) (v x1 y1) (v x0 y1)))))
  nil)

(defmacro paint-ellipse! (cx cy rx ry col &key (thick 0f0) (feather 1f0) (frac 1f0) (ccw nil))
  "An ellipse (mode 3) centred at (CX CY), radii RX RY: filled, or a ring THICK wide inside them (local units); FEATHER in screen
pixels (1 = antialiased, more = a glow); only FRAC of it clockwise from the top (CCW: counter-clockwise; butt ends; another start
by PAINT-TRANSFORM!'s rotation). Circles are exact, ellipses close. 6 vertices; cut by the scissor (a disc cut from below = a level)."
  `(progn (%f32-set *paint-ell* ,cx ,cy ,rx ,ry ,thick ,feather ,frac ,(if ccw -1f0 1f0)) (%paint-ellipse ,col)))

(defun-fast %paint-ellipse (col)
  "Body of PAINT-ELLIPSE!."
  (declare (type f32vec col))
  (let* ((e *paint-ell*) (cx (aref e 0)) (cy (aref e 1)) (rx (aref e 2)) (ry (aref e 3)) (th (aref e 4)) (f (aref e 5))
         (fr (aref e 6)) (dir (aref e 7)) (ex (+ rx (* f (%paint-px)))) (ey (+ ry (* f (%paint-px))))
         (r (aref col 0)) (g (aref col 1)) (bl (aref col 2)) (a (aref col 3)))
    (declare (type f32vec e) (single-float cx cy rx ry th f fr dir ex ey r g bl a))
    (%cut-quad (cx cy ex ey)
      (macrolet ((v (x y) `(hvtx ,x ,y (- ,x cx) (- ,y cy) r g bl a 3f0 rx ry th f fr dir 0f0)))
        (with-hud-verts (6) (v x0 y0) (v x1 y0) (v x1 y1) (v x0 y0) (v x1 y1) (v x0 y1)))))
  nil)

(defmacro paint-stroke! (pts n width col &key (frac 1f0) (round nil))
  "An open polyline through the N points of PTS (f32vec x y ...), WIDTH wide (local units), antialiased: ROUND ends and joints, or
butt ends with square joints; only the first FRAC of its length (an SVG dashoffset tween). 6 vertices a segment; not scissored."
  `(progn (%f32-set *paint-ell* ,width ,frac) (%paint-stroke ,pts ,n ,col ,round)))

(defun-fast %paint-stroke (pts n col round)
  "Body of PAINT-STROKE!: each segment one mode-2 box in its own frame (radius = half the width when ROUND)."
  (declare (type f32vec pts col) (fixnum n))
  (let* ((e *paint-ell*) (hw (* 0.5f0 (aref e 0))) (px (%paint-px)) (total 0f0) (acc 0f0)
         (r (aref col 0)) (g (aref col 1)) (bl (aref col 2)) (a (aref col 3)) (rad (if round hw 0f0)))
    (declare (type f32vec e) (single-float hw px total acc r g bl a rad))
    (dotimes (i (1- n))
      (incf total (f-hypot (- (aref pts (* 2 (1+ i))) (aref pts (* 2 i))) (- (aref pts (1+ (* 2 (1+ i)))) (aref pts (1+ (* 2 i)))))))
    (let ((lim (* total (f-clamp (aref e 1) 0f0 1f0))))
      (declare (single-float lim))
      (dotimes (i (1- n))
        (let* ((x0 (aref pts (* 2 i))) (y0 (aref pts (1+ (* 2 i)))) (dx (- (aref pts (* 2 (1+ i))) x0)) (dy (- (aref pts (1+ (* 2 (1+ i)))) y0))
               (li (f-hypot dx dy)) (l (f-min li (- lim acc))))
          (declare (single-float x0 y0 dx dy li l))
          (when (and (> li 1f-6) (> l 0f0))
            (let* ((ux (/ dx li)) (uy (/ dy li)) (lst (or (= i (- n 2)) (>= (+ acc li) lim)))
                   (e0 (if (or round (= i 0)) 0f0 hw)) (e1 (if (or round lst) 0f0 hw))
                   (hl (+ (* 0.5f0 (+ l e0 e1)) rad)) (mid (* 0.5f0 (- (+ l e1) e0)))
                   (cx (+ x0 (* ux mid))) (cy (+ y0 (* uy mid))) (ex (+ hl px)) (ey (+ hw px)))
              (declare (single-float ux uy e0 e1 hl mid cx cy ex ey))
              (macrolet ((v (sx sy) `(let ((lu (* ,sx ex)) (lv (* ,sy ey)))
                                       (declare (single-float lu lv))
                                       (hvtx (+ cx (* ux lu) (- (* uy lv))) (+ cy (* uy lu) (* ux lv)) lu lv r g bl a
                                             2f0 hl hw rad 1f0 0f0 0f0 0f0))))
                (with-hud-verts (6) (v -1f0 -1f0) (v 1f0 -1f0) (v 1f0 1f0) (v -1f0 -1f0) (v 1f0 1f0) (v -1f0 1f0)))))
          (incf acc li)))))
  nil)

(defmacro paint-radial! (cx cy rx ry stops nstops)
  "A radial gradient (CSS radial-gradient) centred at (CX CY), radii RX RY: STOPS an f32vec of NSTOPS (t r g b a), t from 0 (the
centre) to 1 (the radii), increasing; nothing beyond the last stop. 32 segments: 96 + 192 (NSTOPS - 2) vertices; not scissored."
  `(progn (%f32-set *paint-ell* ,cx ,cy ,rx ,ry) (%paint-radial ,stops ,nstops)))

(defun-fast %paint-radial (st ns)
  "Body of PAINT-RADIAL!: a ring of quads (a fan of triangles at t = 0) between each two stops, vertex colours."
  (declare (type f32vec st) (fixnum ns))
  (let* ((e *paint-ell*) (cx (aref e 0)) (cy (aref e 1)) (rx (aref e 2)) (ry (aref e 3)) (cs *paint-cs*))
    (declare (type f32vec e cs) (single-float cx cy rx ry))
    (dotimes (s (1- ns))
      (let* ((o0 (* 5 s)) (o1 (+ o0 5)) (t0 (aref st o0)) (t1 (aref st o1)))
        (declare (fixnum o0 o1) (single-float t0 t1))
        (macrolet ((v (tt k j) `(let ((c (aref cs (* 2 ,j))) (sn (aref cs (1+ (* 2 ,j)))))
                                  (declare (single-float c sn))
                                  (hvtx (+ cx (* rx ,tt c)) (+ cy (* ry ,tt sn)) 0f0 0f0
                                        (aref st (+ ,k 1)) (aref st (+ ,k 2)) (aref st (+ ,k 3)) (aref st (+ ,k 4))
                                        0f0 0f0 0f0 0f0 0f0 0f0 0f0 0f0))))
          (if (<= t0 0f0)
              (with-hud-verts ((* 3 +radial-segs+))
                (dotimes (j +radial-segs+) (v 0f0 o0 j) (v t1 o1 j) (v t1 o1 (1+ j))))
              (with-hud-verts ((* 6 +radial-segs+))
                (dotimes (j +radial-segs+)
                  (v t0 o0 j) (v t1 o1 j) (v t1 o1 (1+ j)) (v t0 o0 j) (v t1 o1 (1+ j)) (v t0 o0 (1+ j)))))))))
  nil)

;;; ---------------------------------------------------------------- SVG paths, flattened once (init time: it conses)
(defun path-points (d &key (segs 6))
  "The first subpath of the SVG path data D (M L H V C S A Z, absolute and relative) as an f32vec of points x y ... (its own
units; a closing point equal to the first is dropped), each curve and arc flattened into SEGS pieces. For PAINT-POLY (with
PAINT-CENTRE! when it is not convex) and PAINT-STROKE!. tests: tests/paint-shapes-test.lisp."
  (let ((pos 0) (n (length d)) (out '()) (cmd #\M) (x 0.0) (y 0.0) (sx 0.0) (sy 0.0) (cx2 0.0) (cy2 0.0) (done nil))
    (labels ((skip () (loop while (and (< pos n) (find (char d pos) '(#\Space #\, #\Tab #\Newline #\Return))) do (incf pos)))
             (num () (skip)
               (let ((start pos) (dot nil) (ex nil))
                 (when (and (< pos n) (find (char d pos) "+-")) (incf pos))
                 (loop while (< pos n)
                       do (let ((c (char d pos)))
                            (cond ((digit-char-p c) (incf pos))
                                  ((and (char= c #\.) (not dot) (not ex)) (setf dot t) (incf pos))
                                  ((and (char-equal c #\e) (not ex)) (setf ex t) (incf pos)
                                   (when (and (< pos n) (find (char d pos) "+-")) (incf pos)))
                                  (t (return)))))
                 (let ((*read-default-float-format* 'double-float)) (float (read-from-string d t nil :start start :end pos) 1.0))))
             (emit (px py) (push (cons px py) out))
             (cubic (x1 y1 x2 y2 x3 y3)
               (loop for i from 1 to segs
                     for u = (/ i (float segs)) for mu = (- 1 u)
                     do (emit (+ (* mu mu mu x) (* 3 mu mu u x1) (* 3 mu u u x2) (* u u u x3))
                              (+ (* mu mu mu y) (* 3 mu mu u y1) (* 3 mu u u y2) (* u u u y3))))
               (setf cx2 x2 cy2 y2 x x3 y y3))
             (arc (rx ry phi large sweep x2 y2)  ; SVG 1.1 F.6.5: endpoint -> centre parameterisation
               (let* ((cp (cos phi)) (sp (sin phi)) (dx (/ (- x x2) 2)) (dy (/ (- y y2) 2))
                      (x1p (+ (* cp dx) (* sp dy))) (y1p (+ (* (- sp) dx) (* cp dy)))
                      (rx (abs rx)) (ry (abs ry)) (lam (+ (/ (* x1p x1p) (* rx rx)) (/ (* y1p y1p) (* ry ry)))))
                 (when (> lam 1) (setf rx (* rx (sqrt lam)) ry (* ry (sqrt lam))))
                 (let* ((num (- (* rx rx ry ry) (* rx rx y1p y1p) (* ry ry x1p x1p)))
                        (den (+ (* rx rx y1p y1p) (* ry ry x1p x1p)))
                        (co (* (if (eq large sweep) -1 1) (sqrt (max 0 (/ num den)))))
                        (cxp (* co (/ (* rx y1p) ry))) (cyp (* co (- (/ (* ry x1p) rx))))
                        (ccx (+ (- (* cp cxp) (* sp cyp)) (/ (+ x x2) 2))) (ccy (+ (* sp cxp) (* cp cyp) (/ (+ y y2) 2)))
                        (a1 (atan (/ (- y1p cyp) ry) (/ (- x1p cxp) rx)))
                        (da (- (atan (/ (- (- y1p) cyp) ry) (/ (- (- x1p) cxp) rx)) a1)))
                   (when (and sweep (< da 0)) (incf da (* 2 pi)))
                   (when (and (not sweep) (> da 0)) (decf da (* 2 pi)))
                   (loop for i from 1 to segs
                         for a = (+ a1 (* da (/ i (float segs))))
                         do (emit (+ ccx (* cp rx (cos a)) (- (* sp ry (sin a)))) (+ ccy (* sp rx (cos a)) (* cp ry (sin a)))))
                   (setf x x2 y y2 cx2 x cy2 y)))))
      (loop until (or done (progn (skip) (>= pos n)))
            do (let ((c (char d pos)))
                 (when (alpha-char-p c) (setf cmd c) (incf pos))
                 (let ((rel (lower-case-p cmd)) (bx x) (by y))
                   (flet ((ax (v) (if rel (+ bx v) v)) (ay (v) (if rel (+ by v) v)))
                     (case (char-upcase cmd)
                       (#\M (if out (setf done t)
                                (progn (setf x (ax (num)) y (ay (num)) sx x sy y cx2 x cy2 y) (emit x y)
                                       (setf cmd (if rel #\l #\L)))))
                       (#\L (setf x (ax (num)) y (ay (num)) cx2 x cy2 y) (emit x y))
                       (#\H (setf x (ax (num)) cx2 x cy2 y) (emit x y))
                       (#\V (setf y (ay (num)) cx2 x cy2 y) (emit x y))
                       (#\C (let* ((x1 (ax (num))) (y1 (ay (num))) (x2 (ax (num))) (y2 (ay (num))) (x3 (ax (num))) (y3 (ay (num))))
                              (cubic x1 y1 x2 y2 x3 y3)))
                       (#\S (let* ((x1 (- (* 2 x) cx2)) (y1 (- (* 2 y) cy2)) (x2 (ax (num))) (y2 (ay (num))) (x3 (ax (num))) (y3 (ay (num))))
                              (cubic x1 y1 x2 y2 x3 y3)))
                       (#\A (let* ((rx (num)) (ry (num)) (phi (* (num) (/ pi 180))) (large (/= 0 (num))) (sweep (/= 0 (num)))
                                   (x2 (ax (num))) (y2 (ay (num))))
                              (arc rx ry phi large sweep x2 y2)))
                       (#\Z (setf x sx y sy done t))
                       (t (error "path-points: unsupported command ~a in ~s" cmd d))))))))
    (let ((pts (nreverse out)))
      (when (and (cdr pts) (< (+ (abs (- (car (first pts)) (car (car (last pts))))) (abs (- (cdr (first pts)) (cdr (car (last pts)))))) 1d-6))
        (setf pts (butlast pts)))
      (let ((v (make-f32 (* 2 (length pts)))))
        (loop for (px . py) in pts for i from 0 do (setf (aref v (* 2 i)) (f32 px) (aref v (1+ (* 2 i))) (f32 py)))
        v))))
