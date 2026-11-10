;;;; lhud-geom.lisp — the handheld battle screen's geometry as pure functions of the model (docs/duel/DUEL_LISP_HUD.md §13): where
;;;; hud.js puts the deck, its line and your plate on it, 爆, the stance seals around it and the clock tab, from the permille numbers
;;;; webhud.lisp publishes (V30-V43) and the window. Plain CL (host-tested in tests/duel-rules/lhud-geom.lisp); DEFUN-FAST-INLINE so a
;;;; DEFUN-FAST view keeps the floats unboxed; results go into an f32vec OUT (0 B a frame). Device px, origin top-left, y down.
(in-package :duel)

;; sin / cos / atan / sqrt of a single-float: C under COMPILE-FILE (no generic call, no box), plain CL when LOADed (the host tests),
;; as layout.lisp's FL-FLOOR
(macrolet ((def (name c cl) `(defmacro ,name (&rest a) (if *compile-file-pathname* `(,',c ,@a) `(,',cl ,@a)))))
  (def lg-sin f-sin sin) (def lg-cos f-cos cos) (def lg-atan2 f-atan2 atan) (def lg-sqrt f-sqrt sqrt))

(defun-fast-inline lhud-deck-line! (out w h x0 y0 x1 y1 far near left)
  "hud.js renderDeck, draft C 界: the deck rect X0 Y0 X1 Y1 (permille of W x H), the line's heights FAR / NEAR (permille of the deck's
height, V34 / V35) at the far edge and the thumb's, LEFT the left hand. OUT: [0] the line's far point x, [1] its y, [2] its length,
[3] your plate's rotation (radians, clockwise on screen; the plate's origin is the far point), [4] the deck's left x, [5] top y,
[6] width, [7] height."
  (declare (type f32vec out) (single-float w h) (fixnum x0 y0 x1 y1 far near) (type boolean left))
  (let* ((dw (/ (* w (i->f* (- x1 x0))) 1000f0)) (dh (/ (* h (i->f* (- y1 y0))) 1000f0))
         (rise (* (/ (i->f* (- near far)) 1000f0) dh))
         (len (lg-sqrt (+ (* dw dw) (* rise rise)))) (ang (lg-atan2 rise dw)))
    (declare (single-float dw dh rise len ang))
    (setf (aref out 0) (/ (* w (i->f* (if left x1 x0))) 1000f0)
          (aref out 1) (+ (/ (* h (i->f* y0)) 1000f0) (* dh (/ (i->f* far) 1000f0)))
          (aref out 2) len (aref out 3) (if left (- ang) ang)
          (aref out 4) (/ (* w (i->f* x0)) 1000f0) (aref out 5) (/ (* h (i->f* y0)) 1000f0) (aref out 6) dw (aref out 7) dh)
    out))

(defparameter *lhud-seal-angles* (let ((v (make-f32 4))) (replace v '(304f0 270f0 236f0 202f0)) v)
  "hud.js: the stance seals' angles around 爆 (degrees, clockwise from the top: the far side, up-left to down for the right hand).")
(declaim (type f32vec *lhud-seal-angles*))

(defun-fast-inline lhud-seal-ring! (out cx cy r mirror)
  "hud.css .rvc .seal: the four stance seals' centres on a circle of R around (CX CY) at *LHUD-SEAL-ANGLES* (MIRROR: the left hand,
the angles negated): translate(-50%, -50%) rotate(a) translateY(-R) rotate(-a). OUT: x0 y0 .. x3 y3."
  (declare (type f32vec out) (single-float cx cy r) (type boolean mirror))
  (dotimes (i 4)
    (let ((a (* (aref *lhud-seal-angles* i) (if mirror -0.017453292f0 0.017453292f0))))
      (declare (single-float a))
      (setf (aref out (* 2 i)) (+ cx (* r (lg-sin a))) (aref out (1+ (* 2 i))) (- cy (* r (lg-cos a))))))
  out)

(defun-fast-inline lhud-deck-bottom (h y0 deck)
  "hud.css --deck as a y: the deck's top (permille Y0 of H) with the deck, else 4 % above the bottom (#hud.hphone.nodeck)."
  (declare (single-float h) (fixnum y0) (type boolean deck))
  (if deck (/ (* h (i->f* y0)) 1000f0) (* 0.96f0 h)))
