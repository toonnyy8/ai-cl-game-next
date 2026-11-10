;;;; hot.lisp — pointer targets of the paint stream's screens (docs/duel/DUEL_LISP_HUD.md §4.5, phase 1c): a per-frame registry of
;;;; hot boxes (an id and a quad in device px, in drawing order), hit tests against LAST frame's boxes (what the player saw: the canvas
;;;; menus' NOTE-MENU-ROW pattern), and the focus order for keys / pads (the registration order). A box registered while a transform
;;;; is current (PAINT-XFORM!) is stored as its transformed quad, so a rotated plate or a scaled card hits where it is drawn. The
;;;; pointer is the game's to read: MOUSE-X / MOUSE-Y (platform.lisp, device px) for hover and click, TOUCH-TAP-X / -Y for a tap.
;;;; 0 B per frame (fixed pools; floats travel in *HOT-IO*). Plain CL but *PAINT-XF* (paint.lisp): the host tests bind it.
(in-package :engine)

(defconstant +hot-max+ 96 "Hot boxes a frame (more are ignored).")
(declaim (type f32vec *hot-q* *hot-io*) (type (simple-array fixnum (*)) *hot-id* *hot-n*))
(defvar *hot-q* (make-f32 (* 2 +hot-max+ 8)) "Two frames' quads (8 floats: 4 corners x y), the current frame's half chosen by *HOT-N* [2].")
(defvar *hot-id* (make-array (* 2 +hot-max+) :element-type 'fixnum :initial-element -1) "Their ids.")
(defvar *hot-n* (make-array 3 :element-type 'fixnum :initial-element 0) "[0] boxes this frame, [1] last frame's, [2] this frame's half (0 / 1).")
(defvar *hot-io* (make-f32 8) "The hot macros' float lane: a rectangle's x0 y0 x1 y1, or a point x y.")

(defun-fast hot-begin-frame ()
  "Start this frame's registry (once a frame, before drawing): this frame's boxes become last frame's."
  (let ((n *hot-n*)) (declare (type (simple-array fixnum (*)) n))
    (setf (aref n 1) (aref n 0) (aref n 0) 0 (aref n 2) (- 1 (aref n 2))))
  nil)

(defun-fast %hot-add (id)
  "Register the rectangle in *HOT-IO* [0..3] (local coordinates) through the current transform as box ID."
  (declare (fixnum id))
  (let* ((n *hot-n*) (k (aref n 0)))
    (declare (type (simple-array fixnum (*)) n) (fixnum k))
    (when (< k +hot-max+)
      (let* ((slot (+ k (* +hot-max+ (aref n 2)))) (q *hot-q*) (o (* 8 slot)) (io *hot-io*) (m *paint-xf*)
             (x0 (aref io 0)) (y0 (aref io 1)) (x1 (aref io 2)) (y1 (aref io 3)))
        (declare (fixnum slot o) (type f32vec q io m) (single-float x0 y0 x1 y1))
        (macrolet ((pt (i x y) `(setf (aref q (+ o ,(* 2 i))) (+ (* (aref m 0) ,x) (* (aref m 2) ,y) (aref m 4))
                                      (aref q (+ o ,(1+ (* 2 i)))) (+ (* (aref m 1) ,x) (* (aref m 3) ,y) (aref m 5)))))
          (pt 0 x0 y0) (pt 1 x1 y0) (pt 2 x1 y1) (pt 3 x0 y1))
        (setf (aref *hot-id* slot) id (aref n 0) (1+ k))))
    nil))
(defmacro hot-add (id x0 y0 x1 y1)
  "Register box ID: the rectangle X0 Y0 .. X1 Y1 in the current transform's local coordinates (device px)."
  `(let ((io *hot-io*)) (setf (aref io 0) ,x0 (aref io 1) ,y0 (aref io 2) ,x1 (aref io 3) ,y1) (%hot-add ,id)))

(defun-fast %hot-hit ()
  "The id of last frame's topmost (latest drawn) box holding the point *HOT-IO* [4] [5], or -1."
  (let* ((n *hot-n*) (base (* +hot-max+ (- 1 (aref n 2)))) (q *hot-q*) (io *hot-io*) (px (aref io 4)) (py (aref io 5)))
    (declare (type (simple-array fixnum (*)) n) (fixnum base) (type f32vec q io) (single-float px py))
    (loop for k of-type fixnum from (1- (aref n 1)) downto 0
          do (let ((o (* 8 (+ base k))) (pos 0) (neg 0))
               (declare (fixnum o pos neg))
               (dotimes (i 4)                             ; inside a convex quad: on the same side of all four edges
                 (let* ((a (+ o (* 2 i))) (b (+ o (* 2 (mod (1+ i) 4))))
                        (cr (- (* (- (aref q b) (aref q a)) (- py (aref q (1+ a)))) (* (- (aref q (1+ b)) (aref q (1+ a))) (- px (aref q a))))))
                   (declare (fixnum a b) (single-float cr))
                   (if (> cr 0f0) (incf pos) (when (< cr 0f0) (incf neg)))))
               (when (or (= pos 0) (= neg 0)) (return-from %hot-hit (aref *hot-id* (+ base k))))))
    -1))
(defmacro hot-hit (x y)
  "The id of last frame's topmost box under the point X Y (device px), or -1."
  `(let ((io *hot-io*)) (setf (aref io 4) ,x (aref io 5) ,y) (%hot-hit)))

(defun-fast hot-focus-step (id dir)
  "The focus order for keys / pads: the id after ID (DIR 1) or before it (DIR -1) among last frame's boxes in drawing order,
wrapping; the first (or last) box when ID is not there; -1 when there are none."
  (declare (fixnum id dir))
  (let* ((n *hot-n*) (cnt (aref n 1)) (base (* +hot-max+ (- 1 (aref n 2)))) (at -1))
    (declare (type (simple-array fixnum (*)) n) (fixnum cnt base at))
    (cond ((= cnt 0) -1)
          (t (dotimes (k cnt) (when (= (aref *hot-id* (+ base k)) id) (setf at k) (return)))
             (aref *hot-id* (+ base (if (< at 0) (if (> dir 0) 0 (1- cnt)) (mod (+ at dir cnt) cnt))))))))
