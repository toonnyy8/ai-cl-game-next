;;;; hud-engine-test.lisp — host checks of the paint stream's pure layers (docs/duel/DUEL_LISP_HUD.md phase 1c): layout.lisp (units,
;;;; clamp, safe-area anchors, splits, stacks, the mirror, the menus' form, line breaking with kinsoku), tween.lisp (easing against
;;;; CSS's curves, keyframe animations with delay / iterations / direction / fill, restart on a serial, transitions, reduced motion)
;;;; and hot.lisp (hit tests through a transform, the focus order).
;;;;   $ECL_HOST --norc --load tests/hud-engine-test.lisp
(dolist (f '("package" "math" "layout" "tween"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defvar engine::*paint-xf* (engine:make-f32 7))           ; (paint.lisp's transform, which hot.lisp reads; identity below)
(load (merge-pathnames "../engine/lisp/hot.lisp" *load-truename*))
(defpackage :hud-engine-test (:use :cl :engine))
(in-package :hud-engine-test)

(defvar *fails* 0)
(defvar *checks* 0)
(defmacro check (form &optional (expect t) (eps 1e-3))
  `(let ((got ,form))
     (incf *checks*)
     (unless (if (eq ',expect t) got (if (numberp ',expect) (< (abs (- got ,expect)) ,eps) (equalp got ,expect)))
       (incf *fails*) (format t "FAIL: ~s~%   got ~s, want ~s~%" ',form got ',expect))))
(defun xf-identity () (replace engine::*paint-xf* '(1f0 0f0 0f0 1f0 0f0 0f0 1f0)))

;;; ---------------------------------------------------------------- units (hud.css --u, menu.css clamp)
(layout-frame! 1280f0 720f0 1f0 0f0 0f0 0f0 0f0)
(check (lay-u 1f0) 12.8)                                  ; min(1vw, 1.7778vh) at 1280 x 720
(check (lay-portrait-p) nil)
(check (lay-menu-form) +form-desk+)
(check (css-clamp 84f0 (lay-vw 17f0) 268f0) 217.6)        ; the wordmark's clamp(84px, 17vw, 268px)
(check (css-clamp 180f0 (lay-vh 46f0) 520f0) 331.2)       ; 魂's clamp(180px, 46vh, 520px)
(check (css-clamp 10f0 5f0 8f0) 10)                       ; CSS: MIN wins over MAX
(layout-frame! 1920f0 1080f0 1f0 0f0 0f0 0f0 0f0)
(check (lay-u 1f0) 19.2)
(layout-frame! 2560f0 1080f0 1f0 0f0 0f0 0f0 0f0)
(check (lay-u 1f0) 19.2)                                  ; ultrawide: the height bounds u
(layout-frame! 1170f0 2532f0 3f0 47f0 34f0 0f0 0f0)       ; 390 x 844 CSS at dpr 3, a notch of 47 / 34
(check (lay-u 1f0) 27.612)                                ; portrait: 2.36vw = 9.2 CSS px
(check (lay-portrait-p) t)
(check (lay-menu-form) +form-narrow+)
(check (css-clamp (lay-css 84f0) (lay-vw 17f0) (lay-css 268f0)) 252)   ; 17vw = 66.3 CSS px < 84: the minimum (252 device px)
(check (lay-safe 0 (lay-u 2.4f0) (lay-u 1f0)) 168.612)    ; top: max(2.4u, st + 1u) = 141 + 27.612
(check (lay-safe 2 (lay-u 2.6f0) (lay-u 1f0)) 71.791)     ; left without an inset: 2.6u
(layout-frame! 1280f0 500f0 1f0 0f0 0f0 0f0 0f0)
(check (lay-menu-form) +form-short+)
(layout-frame! 1280f0 720f0 1f0 0f0 0f0 44f0 30f0)
(check (lay-inset 2) 44)
(check (lay-safe 3 (lay-u 2.6f0) (lay-u 1f0)) 42.8)       ; right: max(2.6u, sr + 1u) = 30 + 12.8

;;; ---------------------------------------------------------------- anchors, mirror, splits, stacks
(check (lay-anchor 0f0 10f0 100f0 1280f0) 10)
(check (lay-anchor 1f0 10f0 100f0 1280f0) 1170)
(check (lay-anchor 0.5f0 0f0 100f0 1280f0) 590)
(check (lay-mirror 40f0 100f0 0f0 1280f0) 1140)           ; P2's plate: a box at 40 from the left lands 40 from the right
(let ((out (make-f32 4)) (w (make-f32 2)))
  (setf (aref w 0) 1.05f0 (aref w 1) 1f0)                 ; MODE's grid-template-columns: 1.05fr 1fr, gap 4vw
  (lay-split! out 0f0 1280f0 51.2f0 w 2)
  (check (aref out 0) 0) (check (aref out 1) 629.3854) (check (aref out 2) 680.5854) (check (aref out 3) 599.4146))
(let ((out (make-f32 3)) (sz (make-f32 3)))
  (replace sz '(10f0 20f0 30f0))
  (check (lay-stack! out sz 3 100f0 5f0 0.5f0 100f0) 70) ; length 60 + 2 gaps
  (check (aref out 0) 115) (check (aref out 1) 130) (check (aref out 2) 155)
  (lay-stack! out sz 3 100f0 5f0 1f0 100f0)
  (check (aref out 2) 170))

;;; ---------------------------------------------------------------- line breaking (zh-TW kinsoku)
(defun wrap (s width &optional (latin 0.5f0))
  "Lines of S wrapped at WIDTH em, CJK 1 em, other characters LATIN em: a list of strings."
  (let* ((n (length s)) (codes (make-array n :element-type 'fixnum)) (adv (make-f32 n)))
    (dotimes (i n) (let ((c (char-code (char s i)))) (setf (aref codes i) c (aref adv i) (if (wide-char-p c) 1f0 latin))))
    (let ((br (wrap-lines codes adv n (float width 1f0))))
      (loop for k below (length br) by 2 collect (subseq s (aref br k) (aref br (1+ k)))))))
(check (wrap "一二三四五六" 4) '("一二三四" "五六"))
(check (wrap "一二三。四五" 3) '("一二" "三。四" "五"))      ; 。 never starts a line: 三 goes down with it
(check (wrap "一二「三四" 3) '("一二" "「三四"))            ; 「 never ends a line
(check (wrap "在出招中，手指停" 4) '("在出招" "中，手指" "停"))   ; ， carries 中 down
(check (wrap "the quick brown fox" 5) '("the quick" "brown fox"))   ; Latin at spaces; the space before a break hangs
(check (wrap "abcdefghij" 3 1f0) '("abc" "def" "ghi" "j"))     ; no break opportunity: cut where it overflows
(check (wrap (format nil "一~%二三") 9) '("一" "二三"))                  ; a newline always breaks
(check (wrap "按 J 確認" 2.5) '("按 J" "確認"))              ; Latin next to CJK breaks either side
(check (wrap "40 ms 就算" 3) '("40 ms" "就算"))
(check (wrap "一二三" 0.5) '("一" "二" "三"))                ; narrower than a glyph: one a line, never an empty line
(check (wrap "" 4) '())

;;; ---------------------------------------------------------------- easing (CSS reference values, x -> y)
(macrolet ((curve (k &rest pairs) `(progn ,@(loop for (u y) on pairs by #'cddr collect `(check (ease ,k ,u) ,y 2e-3)))))
  (curve +ease-linear+ 0.3f0 0.3)
  (curve +ease+ 0.1f0 0.0948 0.25f0 0.40851 0.5f0 0.8024 0.75f0 0.96046 0.9f0 0.99432)
  (curve +ease-in+ 0.25f0 0.09346 0.5f0 0.31536 0.75f0 0.62186)
  (curve +ease-in-out+ 0.25f0 0.12916 0.5f0 0.5 0.75f0 0.87084)
  (curve +ease-out-css+ 0.25f0 0.37814 0.5f0 0.68464 0.75f0 0.90654)
  (curve +ease-out+ 0.1f0 0.49439 0.25f0 0.82562 0.5f0 0.97178)          ; the page's --ease-out (.16,1,.3,1)
  (curve +ease-cut+ 0.1f0 0.00786 0.25f0 0.06577 0.5f0 0.63577 0.75f0 0.9544)   ; --ease-cut (.7,0,.2,1)
  (curve +ease-snap+ 0.1f0 0.62129 0.25f0 1.02467 0.5f0 1.10042 0.75f0 1.03241)  ; --ease-snap overshoots
  (curve (+ +ease-steps+ 1) 0f0 0 0.99f0 0 1f0 1)                          ; steps(1): hd-tick's blink
  (curve (+ +ease-steps+ 4) 0.3f0 0.25 0.74f0 0.5)
  (curve +ease+ -1f0 0 2f0 1))                                              ; clamped

;;; ---------------------------------------------------------------- keyframe animations
;; hd-stamp: .24 s ease-snap, from { scale 1.5; rotate -6deg } to the element's own (1, 0)
(let ((a (make-tween '((0 nil 1.5 -6) (1 nil 1 0)) :dur 0.24 :curve +ease-snap+ :base '(1 0))))
  (check (tween-value a 10f0 9f0 0) 1)                    ; before it (fill none): the base
  (check (tween-value a 10f0 10f0 0) 1.5)
  (check (tween-value a 10f0 10.12f0 0) 0.94979)          ; 1.5 - 0.5 x snap(0.5)
  (check (tween-value a 10f0 10.12f0 1) 0.60251)          ; -6 + 6 x snap(0.5): past 0
  (check (tween-value a 10f0 11f0 0) 1)                   ; after: the base
  (check (tween-progress a 10f0 11f0) -1))
;; hd-brush .7 s with a .15 s delay, fill both: the keyframe's start during the delay, its end after
(let ((a (make-tween '((0 nil 0) (1 nil 1)) :dur 0.7 :delay 0.15 :fill 3 :curve +ease-linear+ :base '(0.5))))
  (check (tween-value a 0f0 0.1f0 0) 0)
  (check (tween-value a 0f0 0.5f0 0) 0.5)
  (check (tween-value a 0f0 5f0 0) 1))
;; a flame: 1.6 s infinite alternate with a negative delay (-.7 s), three keyframes with a middle one
(let ((a (make-tween '((0 nil 1) (0.5 nil 1.2) (1 nil 1)) :dur 1.6 :delay -0.7 :iter -1 :dir 2 :curve +ease-linear+)))
  (check (tween-value a 0f0 0f0 0) 1.175)                 ; 0.7 s in: p 0.4375 of the first leg: 1 + 0.2 x 0.875
  (check (tween-value a 0f0 0.9f0 0) 1)                   ; 1.6 s in: iteration 1 starts, reversed: p 1
  (check (tween-value a 0f0 1.7f0 0) 1.2)                 ; 2.4 s: the reversed iteration's middle
  (check (tween-value a 0f0 1000.1f0 0) 1.0 0.3))         ; still running (any value in range)
;; per-keyframe curves: steps(1) from 0 to 50 %, linear after
(let ((a (make-tween `((0 ,(+ +ease-steps+ 1) 0) (0.5 0 1) (1 nil 2)) :dur 1 :curve +ease-linear+)))
  (check (tween-value a 0f0 0.25f0 0) 0) (check (tween-value a 0f0 0.75f0 0) 1.5))
;; two iterations of an alternate animation with fill forwards end at progress 0
(let ((a (make-tween '((0 nil 0) (1 nil 1)) :dur 1 :iter 2 :dir 2 :fill 1 :curve +ease-linear+)))
  (check (tween-value a 0f0 9f0 0) 0) (check (tween-value a 0f0 1.25f0 0) 0.75))
;; reduced motion: an animation at its end state (fill forwards / both) or its base; a transition at its target
(let ((a (make-tween '((0 nil 0) (1 nil 1)) :dur 1 :fill 1 :curve +ease-linear+ :base '(0.3)))
      (b (make-tween '((0 nil 0) (1 nil 1)) :dur 1 :iter -1 :curve +ease-linear+ :base '(0.3))))
  (let ((*reduced-motion* t))
    (check (tween-value a 0f0 0f0 0) 1) (check (tween-value b 0f0 0.5f0 0) 0.3)))
;; restart on a serial: the first value seen only records it
(multiple-value-bind (st se) (make-tween-slots 2)
  (check (tween-watch st se 0 5 1f0) nil) (check (< (aref st 0) -1f29))
  (check (tween-watch st se 0 5 2f0) nil)
  (check (tween-watch st se 0 6 3f0) t) (check (aref st 0) 3)
  (tween-restart st 1 4f0) (check (aref st 1) 4))

;;; ---------------------------------------------------------------- transitions (the Reishi ghost: a drop waits .38 s, drains .55 s ease-cut; a refill snaps)
(let ((tr (make-transitions 1 1f0)))
  (check (trans-value tr 0 0f0) 1)
  (check (trans-to tr 0 0.6f0 10f0 0.55f0 +ease-cut+ 0.38f0) 1)
  (check (trans-value tr 0 10.3f0) 1)                    ; still in the delay
  (check (trans-value tr 0 10.655f0) 0.74569)            ; half way: 1 - 0.4 x cut(0.5)
  (check (trans-value tr 0 11f0) 0.6)
  (check (trans-to tr 0 0.8f0 12f0 0f0 0 0f0) 0.8)       ; a refill snaps
  (trans-to tr 0 0.2f0 13f0 1f0 +ease-linear+ 0f0)
  (check (trans-to tr 0 0.4f0 13.5f0 1f0 +ease-linear+ 0f0) 0.5)   ; retargeted mid-way: starts from where it is
  (check (trans-value tr 0 14f0) 0.45)
  (let ((*reduced-motion* t)) (check (trans-to tr 0 0.9f0 15f0 1f0 +ease-linear+ 0.5f0) 0.9)))

;;; ---------------------------------------------------------------- hot boxes
(xf-identity)
(hot-begin-frame)
(hot-add 7 10f0 10f0 110f0 40f0)
(hot-add 8 50f0 20f0 150f0 60f0)                          ; drawn later: on top where they overlap
(check (hot-hit 20f0 20f0) -1)                            ; this frame's boxes count from the next frame
(hot-begin-frame)
(check (hot-hit 20f0 20f0) 7)
(check (hot-hit 60f0 30f0) 8)
(check (hot-hit 140f0 55f0) 8)
(check (hot-hit 200f0 55f0) -1)
(check (hot-focus-step 7 1) 8) (check (hot-focus-step 8 1) 7) (check (hot-focus-step 7 -1) 8) (check (hot-focus-step 99 1) 7)
;; a box drawn rotated 90 degrees about the origin then moved to (100, 0): (x, y) -> (100 - y, x)
(replace engine::*paint-xf* '(0f0 1f0 -1f0 0f0 100f0 0f0 1f0))
(hot-add 3 0f0 0f0 40f0 10f0)                             ; lands on x 90..100, y 0..40
(xf-identity)
(hot-begin-frame)
(check (hot-hit 95f0 30f0) 3) (check (hot-hit 95f0 45f0) -1) (check (hot-hit 20f0 5f0) -1)
(hot-begin-frame)
(check (hot-focus-step 3 1) -1)                           ; an empty frame

(format t "hud-engine-test: ~d checks, ~a~%" *checks* (if (zerop *fails*) "ALL PASS" (format nil "~d FAILED" *fails*)))
(ext:quit (if (zerop *fails*) 0 1))
