;;;; tween.lisp — CSS-style animation for the paint stream's screens (docs/duel/DUEL_LISP_HUD.md §4.4, phase 1c): easing curves
;;;; (cubic-bézier and steps), keyframe animations (several properties, delay, iterations, direction, fill mode), start / restart on
;;;; a model change (a serial watched), and transitions retargeted from wherever they are. Everything reads a time NOW the caller
;;;; passes (the real-time UI clock *UI-CLOCK*, paint.lisp, advanced by the caller once a frame: a probe calling a draw 100 times
;;;; does not move it). Animations are f32vecs made once at load; the slot pools are f32vecs / fixnum vectors.
;;;; 0 B per frame: the API is macros that put their float arguments into *TW-IO* and call a DEFUN-FAST that leaves its result
;;;; there (a float passed to or returned from a compiled function would be boxed).
;;;; *REDUCED-MOTION* = the sheets' prefers-reduced-motion rule (durations ~0, delays 0, one iteration): every animation is at its end
;;;; state, every transition at its target. Plain CL (no C inlines but layout.lisp's FL-FLOOR / FL-ROUND): the host tests load it
;;;; (tests/hud-engine-test.lisp).
;;;; EASE is the one implementation of the curves (phase 0's EASE-CURVE in paint.lisp folded into it at the phase 1 merge: the
;;;; same five curves at the same indices, lhud-battle.lisp's callers moved over).
(in-package :engine)

(defvar *reduced-motion* nil "T: animations sit at their end state and transitions at their target (prefers-reduced-motion).")
(declaim (type f32vec *tw-io* *curves*))
(defvar *tw-io* (make-f32 8) "The tween macros' float lane: [0] progress in / value out, [1] start, [2] now, [3] target, [4] duration, [5] delay.")

;;; ---------------------------------------------------------------- easing
(defconstant +ease-linear+ 0) (defconstant +ease+ 1) (defconstant +ease-out+ 2) (defconstant +ease-cut+ 3) (defconstant +ease-snap+ 4)
(defconstant +ease-in+ 5) (defconstant +ease-in-out+ 6) (defconstant +ease-out-css+ 7)
(defconstant +ease-steps+ 100 "Curve 100 + n = steps(n) (jump-end, the CSS default): steps(1) is 101.")
(defvar *curves*
  (let ((v (make-f32 32)))
    (replace v '(0f0 0f0 1f0 1f0  0.25f0 0.1f0 0.25f0 1f0  0.16f0 1f0 0.3f0 1f0  0.7f0 0f0 0.2f0 1f0  0.2f0 1.6f0 0.4f0 1f0
                 0.42f0 0f0 1f0 1f0  0.42f0 0f0 0.58f0 1f0  0f0 0f0 0.58f0 1f0))
    v)
  "Curve k's x1 y1 x2 y2: 0 linear, 1 ease, 2 the page's --ease-out (.16,1,.3,1), 3 --ease-cut (.7,0,.2,1), 4 --ease-snap
(.2,1.6,.4,1), 5 ease-in, 6 ease-in-out, 7 CSS's own ease-out (0,0,.58,1).")

(defun-fast %ease (k)
  "*TW-IO* [0] := curve K at the progress in [0] (clamped to 0..1)."
  (declare (fixnum k))
  (let* ((io *tw-io*) (u (aref io 0)) (u (if (< u 0f0) 0f0 (if (> u 1f0) 1f0 u))))
    (declare (type f32vec io) (single-float u))
    (setf (aref io 0)
          (cond ((>= k +ease-steps+)
                 (let ((n (- k +ease-steps+)))
                   (declare (fixnum n))
                   (if (>= u 1f0) 1f0 (/ (i->f* (fl-floor (* u (i->f* n)))) (i->f* (max 1 n))))))
                ((= k 0) u)
                (t (let* ((c *curves*) (o (* 4 k)) (x1 (aref c o)) (y1 (aref c (+ o 1))) (x2 (aref c (+ o 2))) (y2 (aref c (+ o 3))) (tt u))
                     (declare (type f32vec c) (fixnum o) (single-float x1 y1 x2 y2 tt))
                     (macrolet ((bx (s) `(let ((m (- 1f0 ,s))) (declare (single-float m)) (+ (* 3f0 m m ,s x1) (* 3f0 m ,s ,s x2) (* ,s ,s ,s)))))
                       (dotimes (i 8)                     ; Newton on x(t) = u
                         (let* ((m (- 1f0 tt)) (dx (+ (* 3f0 m m x1) (* 6f0 m tt (- x2 x1)) (* 3f0 tt tt (- 1f0 x2)))))
                           (declare (single-float m dx))
                           (when (> (fl-abs dx) 1f-5)
                             (setf tt (- tt (/ (- (bx tt) u) dx)) tt (if (< tt 0f0) 0f0 (if (> tt 1f0) 1f0 tt))))))
                       (when (> (fl-abs (- (bx tt) u)) 1f-4)   ; (Newton stalled: bisect, x(t) is monotone)
                         (let ((lo 0f0) (hi 1f0))
                           (declare (single-float lo hi))
                           (dotimes (i 24) (setf tt (* 0.5f0 (+ lo hi))) (if (< (bx tt) u) (setf lo tt) (setf hi tt))))))
                     (let ((m (- 1f0 tt))) (declare (single-float m)) (+ (* 3f0 m m tt y1) (* 3f0 m tt tt y2) (* tt tt tt)))))))
    nil))

(defmacro ease (k u)
  "Curve K (see *CURVES*, or +EASE-STEPS+ + n) at progress U (clamped to 0..1): the cubic-bézier's y at x = U, or steps(n)."
  `(progn (setf (aref *tw-io* 0) ,u) (%ease ,k) (aref *tw-io* 0)))

;;; ---------------------------------------------------------------- keyframe animations
;;; An animation is an f32vec: [0] duration [1] delay [2] iterations (< 0: infinite) [3] direction (0 normal, 1 reverse, 2 alternate,
;;; 3 alternate-reverse) [4] fill (0 none, 1 forwards, 2 backwards, 3 both) [5] the default curve [6] properties P [7] keyframes K,
;;; then P base values (the element's own style, shown outside the animation when the fill does not cover it), then per keyframe
;;; its offset, its curve (to the next keyframe; < 0 = the default) and P values.
(defun make-tween (keys &key (dur 1f0) (delay 0f0) (iter 1) (dir 0) (fill 0) (curve +ease+) base)
  "An animation from KEYS, a list of keyframes (OFFSET CURVE V1 .. VP) sorted by offset (CURVE nil = CURVE, the animation's
timing function; a keyframe's curve runs to the next one, as CSS's per-keyframe animation-timing-function). BASE: the P values
outside the animation (default: the first keyframe's). ITER < 0 is infinite. Made once (load time)."
  (let* ((np (- (length (first keys)) 2)) (nk (length keys)) (v (make-f32 (+ 8 np (* nk (+ 2 np))))))
    (setf (aref v 0) (f32 dur) (aref v 1) (f32 delay) (aref v 2) (f32 iter) (aref v 3) (f32 dir) (aref v 4) (f32 fill)
          (aref v 5) (f32 curve) (aref v 6) (f32 np) (aref v 7) (f32 nk))
    (loop for i below np for b = (if base (nth i base) (nth (+ 2 i) (first keys))) do (setf (aref v (+ 8 i)) (f32 b)))
    (loop for k in keys for o from (+ 8 np) by (+ 2 np)
          do (setf (aref v o) (f32 (first k)) (aref v (1+ o)) (f32 (or (second k) -1)))
             (loop for i below np do (setf (aref v (+ o 2 i)) (f32 (nth (+ 2 i) k)))))
    v))

(defun-fast %tween-progress (a)
  "*TW-IO* [0] := where the animation A started at [1] stands at [2]: the iteration's progress 0..1 (direction applied), or -1 when
it does not apply (before it under fill none / forwards, after it under none / backwards: the base values show)."
  (declare (type f32vec a))
  (let* ((io *tw-io*) (dur (aref a 0)) (iter (if *reduced-motion* 1f0 (aref a 2))) (dir (fl-round (aref a 3))) (fill (fl-round (aref a 4)))
         (el (if *reduced-motion* 1f30 (- (aref io 2) (aref io 1) (aref a 1)))) (p 0f0) (it 0))
    (declare (type f32vec io) (single-float dur iter el p) (fixnum dir fill it))
    (block nil
      (cond ((< el 0f0) (if (logtest fill 2) (setf p 0f0 it 0) (return (setf (aref io 0) -1f0))))
            ((or (<= dur 0f0) (and (>= iter 0f0) (>= el (* dur iter))))
             (unless (logtest fill 1) (return (setf (aref io 0) -1f0)))
             (let ((n (if (<= iter 0f0) 0f0 iter)))     ; the end: progress 1 of the last iteration (a fraction stops mid-way)
               (declare (single-float n))
               (setf it (max 0 (1- (- (fl-floor (- n))))) p (if (= n (i->f* (fl-floor n))) 1f0 (- n (i->f* (fl-floor n)))))))
            (t (setf it (fl-floor (/ el dur)) p (/ (- el (* dur (i->f* it))) dur))))
      (when (or (= dir 1) (and (= dir 2) (oddp it)) (and (= dir 3) (evenp it))) (setf p (- 1f0 p)))
      (setf (aref io 0) p))
    nil))

(defun-fast %tween-value (a prop)
  "*TW-IO* [0] := property PROP of the animation A started at [1], at [2]."
  (declare (type f32vec a) (fixnum prop))
  (%tween-progress a)
  (let* ((io *tw-io*) (p (aref io 0)) (np (fl-round (aref a 6))) (nk (fl-round (aref a 7))) (o0 (+ 8 np)) (st (+ 2 np)))
    (declare (type f32vec io) (single-float p) (fixnum np nk o0 st))
    (setf (aref io 0)
          (if (< p 0f0)
              (aref a (+ 8 prop))
              (let ((k 0))
                (declare (fixnum k))
                (loop while (and (< (+ k 2) nk) (>= p (aref a (+ o0 (* (1+ k) st))))) do (incf k))
                (let* ((ok (+ o0 (* k st))) (o1 (+ ok st)) (f0 (aref a ok)))
                  (declare (fixnum ok o1) (single-float f0))
                  (if (or (< nk 2) (<= p f0))
                      (aref a (+ ok 2 prop))
                      (let* ((f1 (aref a o1)) (c (aref a (1+ ok))) (span (- f1 f0))
                             (v0 (aref a (+ ok 2 prop))) (v1 (aref a (+ o1 2 prop))))
                        (declare (single-float f1 c span v0 v1))
                        (setf (aref io 0) (if (> span 0f0) (/ (- p f0) span) 1f0))
                        (%ease (if (< c 0f0) (fl-round (aref a 5)) (fl-round c)))
                        (+ v0 (* (aref io 0) (- v1 v0)))))))))
    nil))

(defmacro tween-progress (a start now)
  "The animation A started at START, at NOW: its iteration's progress 0..1 (direction applied), or -1 when it does not apply."
  `(let ((io *tw-io*)) (setf (aref io 1) ,start (aref io 2) ,now) (%tween-progress ,a) (aref io 0)))
(defmacro tween-value (a start now prop)
  "Property PROP of the animation A started at START, at NOW: the keyframes interpolated (each segment eased by its curve), or
the base value where the animation does not apply (fill)."
  `(let ((io *tw-io*)) (setf (aref io 1) ,start (aref io 2) ,now) (%tween-value ,a ,prop) (aref io 0)))

(defun make-tween-slots (n)
  "N animation slots: an f32vec of start times (far in the past: finished) and a fixnum vector of the serials TWEEN-WATCH saw (none yet)."
  (values (make-array n :element-type 'single-float :initial-element -1f30)
          (make-array n :element-type 'fixnum :initial-element most-negative-fixnum)))

(defmacro tween-restart (starts i now) "Start (or restart: the page's class toggle) the animation of slot I at NOW." `(setf (aref ,starts ,i) ,now))

(defun-fast %tween-watch (starts serials i serial)
  (declare (type f32vec starts) (type (simple-array fixnum (*)) serials) (fixnum i serial))
  (let ((old (aref serials i)))
    (declare (fixnum old))
    (cond ((= old serial) nil)
          (t (setf (aref serials i) serial)
             (unless (= old most-negative-fixnum) (setf (aref starts i) (aref *tw-io* 2)) t)))))
(defmacro tween-watch (starts serials i serial now)
  "Restart slot I at NOW when the model's SERIAL changed (the combo's hit count, a callout's serial: hud.js's change detection); the
first serial seen only records it (hud.js shows nothing for a value present before it loaded). T when it restarted."
  `(progn (setf (aref *tw-io* 2) ,now) (%tween-watch ,starts ,serials ,i ,serial)))

;;; ---------------------------------------------------------------- transitions
;;; A transition pool is an f32vec of 6 floats a slot: from, to, start, duration, curve, delay.
(defun make-transitions (n &optional (v 0f0))
  "N transition slots, each resting at V."
  (let ((tr (make-f32 (* 6 n))))
    (dotimes (i n) (setf (aref tr (* 6 i)) (f32 v) (aref tr (+ 1 (* 6 i))) (f32 v) (aref tr (+ 2 (* 6 i))) -1f30))
    tr))

(defun-fast %trans-value (tr i)
  "*TW-IO* [0] := slot I's value at [2]: FROM until start + delay, then eased toward TO over the duration."
  (declare (type f32vec tr) (fixnum i))
  (let* ((io *tw-io*) (o (* 6 i)) (from (aref tr o)) (to (aref tr (1+ o))) (dur (aref tr (+ o 3)))
         (u (if (or *reduced-motion* (<= dur 0f0)) 2f0 (/ (- (aref io 2) (aref tr (+ o 2)) (aref tr (+ o 5))) dur))))
    (declare (type f32vec io) (fixnum o) (single-float from to dur u))
    (cond ((<= u 0f0) (setf (aref io 0) from))
          ((>= u 1f0) (setf (aref io 0) to))
          (t (setf (aref io 0) u) (%ease (fl-round (aref tr (+ o 4)))) (setf (aref io 0) (+ from (* (- to from) (aref io 0))))))
    nil))

(defun-fast %trans-to (tr i curve)
  "Retarget slot I to *TW-IO* [3] when it changed (from its value at [2], over [4] s after [5] s along CURVE); [0] := its value."
  (declare (type f32vec tr) (fixnum i curve))
  (let* ((io *tw-io*) (o (* 6 i)) (target (aref io 3)))
    (declare (type f32vec io) (fixnum o) (single-float target))
    (when (/= target (aref tr (1+ o)))
      (%trans-value tr i)
      (setf (aref tr o) (aref io 0) (aref tr (1+ o)) target (aref tr (+ o 2)) (aref io 2) (aref tr (+ o 3)) (aref io 4)
            (aref tr (+ o 4)) (i->f* curve) (aref tr (+ o 5)) (aref io 5)))
    (%trans-value tr i)
    nil))

(defmacro trans-value (tr i now) "Slot I's value at NOW." `(progn (setf (aref *tw-io* 2) ,now) (%trans-value ,tr ,i) (aref *tw-io* 0)))
(defmacro trans-to (tr i target now dur curve &optional (delay 0f0))
  "Retarget slot I to TARGET when it changed: from the value it shows at NOW, over DUR s after DELAY s along CURVE (a CSS transition
on a style change; DUR 0 snaps). Returns the value at NOW."
  `(let ((io *tw-io*)) (setf (aref io 3) ,target (aref io 2) ,now (aref io 4) ,dur (aref io 5) ,delay) (%trans-to ,tr ,i ,curve) (aref io 0)))
