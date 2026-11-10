;;;; layout.lisp — the 2D layout helpers of the paint stream's screens (docs/duel/DUEL_LISP_HUD.md §4.3, phase 1c): the frame's
;;;; units (device px, CSS px, the battle unit u, vw / vh), CSS clamp(), anchors with the four safe-area insets, ratio splits,
;;;; stacks, the mirror for P2 / the left hand, and the line breaker for wrapped text (CJK between any two characters, Latin at
;;;; spaces, kinsoku). No flexbox: the HTML screens are fixed compositions (§4.3). Plain CL (no C inlines), so the host tests
;;;; load it alone (tests/hud-engine-test.lisp); the float helpers are DEFUN-FAST-INLINE, so a DEFUN-FAST caller keeps them
;;;; unboxed. Coordinates are device pixels, origin top-left, y down.
(in-package :engine)

(declaim (type f32vec *lay*))
(defvar *lay* (make-f32 10)
  "The frame (LAYOUT-FRAME!): [0] width [1] height (device px) [2] the pixel density [3] the battle unit u [4..7] the safe-area
insets top, bottom, left, right (device px) [8] 1 when portrait (height > width), else 0 [9] the width in CSS px.")

(defun-fast-inline layout-frame! (w h dpr st sb sl sr)
  "Set *LAY* for this frame: the window W x H (device px), the density DPR, the safe-area insets ST SB SL SR (CSS px). u is hud.css's
--u: min(1vw, 1.7778vh), and 2.36vw in portrait (hud.js's hphone)."
  (declare (single-float w h dpr st sb sl sr))
  (let ((l *lay*) (portrait (> h w)))
    (declare (type f32vec l))
    (setf (aref l 0) w (aref l 1) h (aref l 2) dpr
          (aref l 3) (if portrait (* 0.0236f0 w) (let ((a (* 0.01f0 w)) (b (* 0.017778f0 h))) (if (< a b) a b)))
          (aref l 4) (* st dpr) (aref l 5) (* sb dpr) (aref l 6) (* sl dpr) (aref l 7) (* sr dpr)
          (aref l 8) (if portrait 1f0 0f0) (aref l 9) (/ w (if (> dpr 0f0) dpr 1f0)))
    nil))

(defmacro i->f* (i) "A fixnum as a single-float in plain CL (I->F is a C inline the host cannot run)." `(the single-float (float (the fixnum ,i) 1f0)))
;; Float -> fixnum without consing: ECL compiles FLOOR / ROUND / TRUNCATE / ABS of a float as generic (boxing) calls, and the host
;; tests cannot run a C inline, so these expand to C under COMPILE-FILE (the build) and to plain CL when a file is LOADed as source.
(defmacro fl-floor (x)
  (if *compile-file-pathname* `(ffi:c-inline (,x) (:float) :fixnum "(cl_fixnum)floorf(#0)" :one-liner t) `(values (floor ,x))))
(defmacro fl-round (x)
  "Round half up (floor (x + 0.5)), the same on both sides."
  (if *compile-file-pathname* `(ffi:c-inline (,x) (:float) :fixnum "(cl_fixnum)floorf((#0)+0.5f)" :one-liner t) `(values (floor (+ ,x 0.5f0)))))
(defmacro fl-abs (x) `(let ((%v ,x)) (declare (single-float %v)) (if (< %v 0f0) (- %v) %v)))
(defmacro lay-w () `(aref *lay* 0))
(defmacro lay-h () `(aref *lay* 1))
(defmacro lay-dpr () `(aref *lay* 2))
(defmacro lay-portrait-p () `(> (aref *lay* 8) 0.5f0))
(defmacro lay-u (k) "K battle units (device px)." `(* (aref *lay* 3) ,k))
(defmacro lay-css (k) "K CSS px (device px)." `(* (aref *lay* 2) ,k))
(defmacro lay-vw (k) "K vw (device px)." `(* 0.01f0 (aref *lay* 0) ,k))
(defmacro lay-vh (k) "K vh (device px)." `(* 0.01f0 (aref *lay* 1) ,k))
(defmacro lay-inset (side) "The safe-area inset of SIDE (0 top, 1 bottom, 2 left, 3 right), device px." `(aref *lay* (+ 4 ,side)))

(defconstant +form-desk+ 0) (defconstant +form-narrow+ 1) (defconstant +form-short+ 2)
(defun-fast lay-menu-form ()
  "menu.css's layout variant: +FORM-NARROW+ at most 760 CSS px wide, +FORM-SHORT+ at most 560 tall (and wider than 760), else
+FORM-DESK+."
  (let* ((l *lay*) (cw (aref l 9)) (ch (/ (aref l 1) (if (> (aref l 2) 0f0) (aref l 2) 1f0))))
    (declare (type f32vec l) (single-float cw ch))
    (cond ((<= cw 760f0) +form-narrow+) ((<= ch 560f0) +form-short+) (t +form-desk+))))

(defun-fast-inline css-clamp (lo pref hi)
  "CSS clamp(LO, PREF, HI) = max(LO, min(PREF, HI)): LO wins when LO > HI, as in CSS."
  (declare (single-float lo pref hi))
  (let ((m (if (< pref hi) pref hi))) (declare (single-float m)) (if (> lo m) lo m)))

(defun-fast-inline lay-safe (side a b)
  "max(A, inset + B): hud.css's top: max(2.4u, st + 1u) pattern, for SIDE 0 top, 1 bottom, 2 left, 3 right (device px)."
  (declare (fixnum side) (single-float a b))
  (let ((v (+ (aref *lay* (+ 4 side)) b))) (declare (single-float v)) (if (> a v) a v)))

(defun-fast-inline lay-anchor (edge off size extent)
  "Where a box of SIZE starts along an axis of EXTENT, placed from EDGE (0 the start, 0.5 the centre, 1 the end) with the offset
OFF (from that edge, inward; ignored for the centre's sign: + moves toward the end)."
  (declare (single-float edge off size extent))
  (cond ((< edge 0.25f0) off) ((> edge 0.75f0) (- extent off size)) (t (+ (* 0.5f0 (- extent size)) off))))

(defun-fast-inline lay-mirror (x w bx bw)
  "X (a box of width W inside the box BX..BX + BW) flipped left / right in that box: P2's plate, the left hand."
  (declare (single-float x w bx bw))
  (- (+ bx bw) (- x bx) w))

(defun-fast-inline lay-split! (out x w gap weights n)
  "grid-template-columns: W cut into N tracks of WEIGHTS (fr) with GAP between them, from X: OUT gets each track's x and width
(2 N floats)."
  (declare (type f32vec out weights) (single-float x w gap) (fixnum n))
  (let ((sum 0f0) (free (- w (* gap (i->f* (max 0 (1- n)))))))
    (declare (single-float sum free))
    (dotimes (i n) (incf sum (aref weights i)))
    (when (<= sum 0f0) (setf sum 1f0))
    (dotimes (i n)
      (let ((tw (* free (/ (aref weights i) sum))))
        (declare (single-float tw))
        (setf (aref out (* 2 i)) x (aref out (1+ (* 2 i))) tw x (+ x tw gap))))
    out))

(defun-fast-inline lay-stack! (out sizes n start gap align extent)
  "A single flex line: N children of SIZES along an axis, GAP apart, inside START..START + EXTENT aligned by ALIGN (0 start, 0.5
centre, 1 end): OUT gets each child's start (N floats); returns the stack's length."
  (declare (type f32vec out sizes) (fixnum n) (single-float start gap align extent))
  (let ((total (* gap (i->f* (max 0 (1- n))))))
    (declare (single-float total))
    (dotimes (i n) (incf total (aref sizes i)))
    (let ((p (+ start (* align (- extent total)))))
      (declare (single-float p))
      (dotimes (i n) (setf (aref out i) p p (+ p (aref sizes i) gap))))
    total))


;;; ---------------------------------------------------------------- line breaking (zh-TW wrap with kinsoku)
(defparameter *kinsoku-no-start* "。，、；：？！）」』】〕〉》…‥・ー’”%.,;:?!)]}"
  "Characters that never start a line (closing punctuation, as CSS line-break: strict for zh-TW, plus the Latin closers).")
(defparameter *kinsoku-no-end* "（「『【〔〈《‘“([{"
  "Characters that never end a line (opening brackets).")

(declaim (inline wide-char-p))
(defun wide-char-p (c)
  "CJK, kana, full-width forms and CJK punctuation: a break is allowed on either side (UAX #14's ID class, roughly)."
  (declare (fixnum c))
  (or (<= #x2E80 c #x9FFF) (<= #xF900 c #xFAFF) (<= #xFF00 c #xFFEF) (<= #x3000 c #x303F)))

(defun break-ok-p (codes i)
  "May a line break fall before index I of the fixnum vector CODES (between I - 1 and I)?"
  (declare (type (simple-array fixnum (*)) codes) (fixnum i))
  (let ((a (aref codes (1- i))) (b (aref codes i)))
    (declare (fixnum a b))
    (cond ((find (code-char b) *kinsoku-no-start*) nil)
          ((find (code-char a) *kinsoku-no-end*) nil)
          ((= b 32) nil)                                   ; (spaces stay on the line before; the break comes after them)
          ((= a 32) t)
          ((or (wide-char-p a) (wide-char-p b)) t)
          (t nil))))

(defun wrap-lines (codes adv n width)
  "Greedy line breaking of N characters (CODES, their advances ADV in any unit) into lines at most WIDTH long. Breaks fall where
BREAK-OK-P allows; a line with no allowed break is cut where it overflows; the spaces before a break hang (not counted, not drawn);
a newline (10) always breaks. Returns a fixnum vector of 2 k entries: each line's start and end (exclusive, hanging spaces left out)."
  (declare (type (simple-array fixnum (*)) codes) (type f32vec adv) (fixnum n) (single-float width))
  (let ((out '()) (start 0))
    (declare (fixnum start))
    (flet ((emit (s e)
             (let ((e e)) (loop while (and (> e s) (= 32 (aref codes (1- e)))) do (decf e)) (push s out) (push e out))))
      (loop while (< start n)
            do (let ((x 0f0) (i start) (last-ok -1))
                 (declare (single-float x) (fixnum i last-ok))
                 (loop while (< i n)
                       do (let ((c (aref codes i)))
                            (declare (fixnum c))
                            (when (= c 10) (return))
                            (when (and (> i start) (break-ok-p codes i)) (setf last-ok i))
                            (when (and (> (+ x (aref adv i)) width) (> i start) (/= c 32)) (return))
                            (incf x (aref adv i)) (incf i)))
                 (cond ((>= i n) (emit start n) (setf start n))
                       ((= 10 (aref codes i)) (emit start i) (setf start (1+ i)))
                       ((> last-ok start) (emit start last-ok) (setf start last-ok))
                       (t (emit start i) (setf start i)))
                 (loop while (and (< start n) (= 32 (aref codes start))) do (incf start)))))
    (coerce (nreverse out) '(simple-array fixnum (*)))))
