;;;; lhud-overlay.lisp — the battle's overlays drawn by Lisp (docs/duel/DUEL_LISP_HUD.md §14; hud.css "pause", "the intro and the
;;;; finish", hud.js renderPause / renderCard): the pause (止 with its blood blot, the torn paper strip and its rows, hd-strip, the
;;;; phone's hd-fromtab, the scene dimmed under it), the intro card (letterbox, the fighter's vertical name column revealed by hd-brush,
;;;; his reading and line, the VS bar), READY / 斬 with the slash line, the finish (決着 / 時間切れ, the blood splat, K.O. / TIME / DRAW,
;;;; the winner with his Konpaku, best combo and Kikons). Above .hudl (z 18-20), so neither .3 paused nor out in a cinematic.
;;;; Each overlay: a system (…-UPDATE: the model's phase / kind / serial edges -> its animation starts and the strings it shows, made
;;;; only when they change) and a view (the model, that state, the UI clock -> paint calls). The pause rows are hot boxes (ids 700 +
;;;; row): LHUD-PAUSE-POINTER turns last frame's hits into the page's pause commands (WEBHUD-PAUSE-CMD). 0 B a frame in steady state.
(in-package :duel)

;;; ---------------------------------------------------------------- state (component data; mutated only by the systems below)
(declaim (type f32vec *lhud-ov-t* *lhud-pz-tr*) (type (simple-array fixnum (*)) *lhud-ov-i*) (type simple-vector *lhud-ov-s* *lhud-pz*))
(defvar *lhud-ov-t* (make-array 9 :element-type 'single-float :initial-element -1f30)
  "Animation starts: [0] the card on (the letterbox, the VS bar), [1] the name column's go (hd-brush, the side's hd-fade), [2] READY,
[3] 斬, [4] the slash line, [5] the finish on, [6] the pause opened (hd-strip, hd-fromtab); [7] [8] the mouse's position last frame
(LHUD-PAUSE-POINTER: it moved).")
(defvar *lhud-ov-i* (make-array 10 :element-type 'fixnum :initial-element 0)
  "[0] the card on (1 / 0), [1] the name column's side (1 P1, 2 P2: hud.js prev.side), [2] the intro phase last frame, [3] the finish
kind last frame, [4] paused last frame, [5] the pause rows' serial seen (-1 none), [6] the row under the mouse last frame (-1 none),
[7] the rows shown, [8] the finish's winner (0 / 1 / 2).")
(defvar *lhud-ov-s* (make-array 6 :initial-element "")
  "The overlays' strings: [0] the name column (the full name), [1] its reading (S30), [2] its line (CRY's kanji · S31), [3] 決着 /
時間切れ, [4] K.O. / TIME / DRAW, [5] Winner · 勝者 / Draw · 引き分け.")
(defvar *lhud-ov-w* (vector #() #()) "The name column's side as words (split at spaces when it changes): [0] the reading, [1] the line.")
(defvar *lhud-pz* (make-array 60 :initial-element nil) "The pause rows (up to 20): per row EN, its value (or NIL), its zh (or NIL).")
(defvar *lhud-pz-tr* (make-transitions 20) "Each pause row's cursor (0 / 1: .2 s ease-out, the English's colour and .6u shift).")
(setf (aref *lhud-ov-i* 5) -1 (aref *lhud-ov-i* 6) -1)

;;; the named animations (hud.css @keyframes), made once
(defparameter *lh-brush-kv* (make-tween '((0 nil 0) (1 nil 1)) :dur 1.1 :delay 0.2 :curve +ease-cut+ :fill 1 :base '(0))
  "The name column's hd-brush: clip-path inset(0 0 100% 0) -> inset(0), 1.1 s after .2 s, ease-cut, forwards.")
(defparameter *lh-fade-side* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.6 :delay 1.1 :fill 1 :base '(0)) "The side's hd-fade: .6 s after 1.1 s.")
(defparameter *lh-fade-vs* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.5 :delay 1.5 :fill 1 :base '(0)) "The VS bar's hd-fade: .5 s after 1.5 s.")
(defparameter *lh-ready-r*                                ; hd-ready: opacity, scale, blur (px); 75 % names no transform: its value there
  (make-tween '((0 nil 0 1.7 6) (0.18 nil 1 1 0) (0.75 nil 1 0.941 0) (1 nil 0 0.94 0)) :dur 0.7 :curve +ease-out+ :fill 1 :base '(0 1 0))
  "READY's hd-ready (.7 s, ease-out a segment, forwards): opacity 0 -> 1 at 18 % -> 1 at 75 % -> 0; scale 1.7 -> 1 -> .94; blur 6 px -> 0.")
(defparameter *lh-ready-k*
  (make-tween '((0 nil 0 1.7 6) (0.18 nil 1 1 0) (0.75 nil 1 0.941 0) (1 nil 0 0.94 0)) :dur 0.9 :curve +ease-out+ :fill 1 :base '(0 1 0))
  "斬's hd-ready (.9 s).")
(defparameter *lh-slash* (make-tween '((0 nil 0 1 0) (0.6 nil 1 1 0.37) (1 nil 1 0 0.5)) :dur 0.5 :curve +ease-cut+ :fill 1 :base '(0 0 0.5))
  "hd-slash (.5 s ease-cut, forwards): scaleX 0 -> 1 by 60 %, opacity 1 -> 0 after it, the transform origin from the left to the
middle (the 0 % keyframe's `left` interpolated to the element's centre).")
(defparameter *lh-brush-kk* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.7 :delay 0.15 :curve +ease-cut+ :fill 1 :base '(0)) "決着's hd-brush: .7 s after .15 s.")
(defparameter *lh-splat* (make-tween '((0 nil 0 0.2 -30) (1 nil 0.95 1 0)) :dur 0.35 :delay 0.55 :curve +ease-snap+ :fill 1 :base '(0 1 0))
  "hd-splat: opacity 0 -> .95, scale .2 -> 1, rotate -30deg -> 0, .35 s after .55 s, ease-snap.")
(defparameter *lh-fade-ko* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.4 :delay 0.9 :fill 1 :base '(0)) "K.O.'s hd-fade: .4 s after .9 s.")
(defparameter *lh-rise* (make-tween '((0 nil 0 2) (1 nil 1 0)) :dur 0.6 :delay 1.2 :curve +ease-out+ :fill 1 :base '(0 2))
  "The winner's hd-rise: opacity 0 -> 1, translateY 2u -> 0, .6 s after 1.2 s, ease-out.")
(defparameter *lh-strip* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.42 :curve +ease-out+ :fill 1 :base '(1))
  "hd-strip: the paper strip's right edge from its left to its place (clip-path), .42 s ease-out.")
(defparameter *lh-fromtab* (make-tween '((0 nil -12 -26 0.16 0.4) (1 nil 0 0 1 1)) :dur 0.42 :curve +ease-out+ :fill 3 :base '(0 0 1 1))
  "hd-fromtab (the phone with the deck): 止 from translate(-12vw, -26vh) scale(.16), opacity .4, to its place, .42 s ease-out, both.")
(declaim (type f32vec *lh-brush-kv* *lh-fade-side* *lh-fade-vs* *lh-ready-r* *lh-ready-k* *lh-slash* *lh-brush-kk* *lh-splat*
               *lh-fade-ko* *lh-rise* *lh-strip* *lh-fromtab*))

(defparameter +c-black+ (rgba #x000000)) (defparameter +c-shade5+ (rgba #x000000 0.5)) (defparameter +c-shade45+ (rgba #x000000 0.45))
(defparameter +c-fin0+ (rgba #x0b0b10 0f0)) (defparameter +c-fin1+ (rgba #x0b0b10 0.82))
(defparameter +c-pz-ey+ (rgba #x5b6070)) (defparameter +c-pz-no+ (rgba #x7c8190)) (defparameter +c-pz-rule+ (rgba #x0b0b10 0.12))
(defparameter +c-blot+ (rgba #xe81e3a 0.92)) (defparameter +c-dim+ (rgba #x000000 0.55))
(defparameter *lhud-blot* (let ((v (make-f32 24)))          ; .pause .big::after's clip-path (percent of its box)
                            (replace v '(0.5 0.0 0.62 0.3 1.0 0.18 0.72 0.5 0.96 0.86 0.58 0.7 0.4 1.0 0.34 0.66 0.0 0.72 0.26 0.46 0.04 0.14 0.38 0.3)) v))
(defparameter *lhud-splat-pts* (let ((v (make-f32 28)))     ; .fin .splat's clip-path
                                 (replace v '(0.5 0.0 0.6 0.32 0.96 0.1 0.7 0.46 1.0 0.62 0.64 0.64 0.74 1.0 0.48 0.72 0.2 0.96 0.32 0.62 0.0 0.56 0.3 0.42 0.08 0.12 0.4 0.3)) v))
(declaim (type f32vec *lhud-blot* *lhud-splat-pts*))
(defparameter *lhud-ey-pause* (zh "PAUSED · 一時停止")) (defparameter *lhud-ey-rotate* (zh "ROTATE TO PORTRAIT · 請轉成直向"))
(defparameter *lhud-fin-strs*
  (vector (kj "決着") (kj "時間切れ") "K.O." "TIME" "DRAW" (zh "WINNER · 勝者") (zh "DRAW · 引き分け"))
  "The finish's words (hud.js renderCard).")
(defparameter *lhud-fin-line* (vector (zh "魂魄 ") (zh " · 最長連段 ") (zh " · 毀魂 ") (zh "–")) "The winner's line, between its numbers.")

;;; ---------------------------------------------------------------- the dimmed scene under the pause (canvas filter, hud.css)
(defun-fast lhud-dim ()
  "body.hud-paused #canvas's brightness(.45) as an ink rect of .55 over the scene, under every HUD layer, on the canvas grade's
.5 s ease-out (the grade itself: LHUD-CANVAS-DESAT)."
  (let* ((g (layer-op 3)))
    (declare (single-float g))
    (when (> g 0.002f0)
      (paint-reset)
      (paint-opacity! g)
      (paint-rect 0f0 0f0 (lay-w) (lay-h) +c-dim+)
      (paint-reset))
    nil))

;;; ---------------------------------------------------------------- the intro card and READY / 斬: the system
(defun-fast lhud-intro-update (fresh)
  "hud.js renderCard: the card is on while the intro shows its phases 1-3 (V14) on the page's layer (V0 32); a new phase 1 / 2 restarts
the name column (P1's at the right, P2's at the left) with the fighter's full name, reading (S30) and line (S31); phase 3 restarts the
slash and READY; phase 4 (the FIGHT beat) or a skipped intro's start hides READY and restarts 斬 (and the slash unless READY ran).
FRESH (the HUD's first frame after being off): the letterbox shows at once (no transition out of display: none)."
  (let* ((now (aref *ui-clock* 0)) (ts *lhud-ov-t*) (iv *lhud-ov-i*) (ss *lhud-ov-s*) (ph (hv 14)) (pp (aref iv 2))
         (intro (and (<= 1 ph 3) (logtest (hv 0) 32))) (red *reduced-motion*))
    (declare (single-float now) (fixnum ph pp))
    (when (and intro (/= (aref iv 0) 1)) (setf (aref ts 0) (if fresh -1f30 now)))
    (setf (aref iv 0) (if intro 1 0))
    (when (and intro (<= ph 2) (/= (aref iv 1) ph))
      (let ((side (if (= ph 2) 1 0)))
        (setf (svref ss 0) (lhud-full-name (side-c side 2) (side-c side 0)) (svref ss 1) (or (hs 30) "")
              (svref ss 2) (lhud-cry-line (hs 31)) (aref ts 1) now
              (svref *lhud-ov-w* 0) (lhud-words (svref ss 1)) (svref *lhud-ov-w* 1) (lhud-words (svref ss 2)))))
    (when (<= 1 ph 2) (setf (aref iv 1) ph))
    (when (and (= ph 3) (/= pp 3) (not red)) (setf (aref ts 4) now (aref ts 2) now))
    (when (or (and (= ph 4) (/= pp 4)) (and (= ph 0) (<= 1 pp 3)))
      (setf (aref ts 2) -1f30)
      (unless red (setf (aref ts 3) now) (when (/= pp 3) (setf (aref ts 4) now))))
    (when (= ph 0) (setf (aref iv 1) 0))
    (setf (aref iv 2) ph)
    nil))

(defun lhud-words (s)
  "S split at its spaces (a simple-vector of strings; empty words dropped): the units a vertical line wraps at."
  (let ((out nil) (i 0) (n (length s)))
    (loop while (< i n)
          do (let ((j (or (position #\Space s :start i) n)))
               (when (> j i) (push (subseq s i j) out))
               (setf i (1+ j))))
    (coerce (nreverse out) 'simple-vector)))

(defun-fast lhud-vwords (words face col draw)
  "A vertical-rl text item of WORDS (a space between) packed into columns at most *LHUD-A* [4] long: the columns from the right edge
[0] leftwards, a line height (= the size [2], line-height 1) apart, from the top [1], letter spacing [3] em; DRAW nil only measures.
Out: [5] the item's length (its longest column), [6] the columns, [7] its min-content (the longest word)."
  (declare (simple-vector words) (fixnum face))
  (let* ((a *lhud-a*) (right (aref a 0)) (top (aref a 1)) (size (aref a 2)) (sp (aref a 3)) (mx (aref a 4)) (pen *paint-pen*)
         (spc (progn (paint-pen! 0f0 0f0 size :spacing sp) (paint-measure-vertical " " face) (aref pen 7)))
         (y 0f0) (len 0f0) (minw 0f0) (k 0))
    (declare (type f32vec a pen) (single-float right top size sp mx spc y len minw) (fixnum k))
    (dotimes (i (length words))
      (let* ((wd (svref words i)) (wl (progn (paint-pen! 0f0 0f0 size :spacing sp) (paint-measure-vertical wd face) (aref pen 7))))
        (declare (simple-string wd) (single-float wl))
        (setf minw (f-max minw wl))
        (when (and (> y 0f0) (> (+ y spc wl) (+ mx 0.5f0))) (incf k) (setf y 0f0))
        (when (> y 0f0) (incf y spc))
        (when draw
          (paint-pen! (- right (* size (+ 0.5f0 (i->f k)))) (+ top y) size :spacing sp) (paint-vertical wd face col))
        (incf y wl) (setf len (f-max len y))))
    (setf (aref a 5) len (aref a 6) (i->f (if (> (length words) 0) (1+ k) 0)) (aref a 7) minw)
    nil))

;;; ---------------------------------------------------------------- the intro card: the view
(defun-fast lhud-intro ()
  "The intro card (z 18): the letterbox (9 % each edge, black, scaleY .5 s ease-cut), the name column (P1's 8 % from the right, P2's
from the left, 12 % down; the phone 6 %, 10 %): the full name (800 7.2u Mincho, vertical, .08em, a 6 px shadow) revealed top to bottom
by hd-brush, beside it the reading (800 1.5u display, .5em, turned), a 1 px x 8u blood line and the line (600 .9u mono, .3em, steel),
hd-fade; the VS bar (6 % from the left, 14 % up; phone 12 %): P1 (900 1.9u, .16em), vs (900 italic 3.4u blood), P2 (steel), hd-fade."
  (when (= 1 (aref *lhud-ov-i* 0))
    (let* ((now (aref *ui-clock* 0)) (ts *lhud-ov-t*) (ss *lhud-ov-s*) (u (lay-u 1f0)) (w (lay-w)) (h (lay-h)) (dpr (lay-dpr))
           (phone (lay-portrait-p)) (pen *paint-pen*) (lb (if *reduced-motion* 1f0 (tw +ease-cut+ 0f0 1f0 (aref ts 0) 0.5f0 now)))
           (left (= (aref *lhud-ov-i* 1) 2)))
      (declare (single-float now u w h dpr lb) (type f32vec ts pen))
      (paint-reset)
      (paint-rect 0f0 0f0 w (* 0.09f0 h lb) +c-black+)
      (paint-rect 0f0 (- h (* 0.09f0 h lb)) w (* 0.09f0 h lb) +c-black+)
      ;; the name column: grid auto auto, gap 1.2u: the name (7.2u wide) and the side: a vertical flex of the reading, the line and
      ;; the cry, padding-top 1u, gap 1.4u, in the column's height (top 12 % to bottom 12 %; phone 10 % + 52 %); when they overflow
      ;; it each shrinks by its share of its length (flex-shrink 1), a text not below its longest word, so it wraps into more
      ;; columns, leftwards, and widens the side (the HTML's KUROSAKI / ICHIGO in two columns)
      (let* ((kz (* 7.2f0 u)) (rz (* 1.5f0 u)) (cz (* 0.9f0 u)) (a *lhud-a*) (rw (svref *lhud-ov-w* 0)) (cw (svref *lhud-ov-w* 1))
             (cryp (> (length cw) 0)) (top (* (if phone 0.1f0 0.12f0) h)) (avail (- (* h (if phone 0.52f0 0.76f0)) u))
             (rl (progn (lane! 0f0 0f0 rz 0.5f0 1f30) (lhud-vwords rw +f-display+ +c-paper+ nil) (aref a 5))) (rmin (aref a 7))
             (cl (if cryp (progn (lane! 0f0 0f0 cz 0.3f0 1f30) (lhud-vwords cw +f-mono+ +c-steel+ nil) (aref a 5)) 0f0)) (cmin (aref a 7))
             (il (if cryp (* 8f0 u) 0f0)) (gaps (if cryp (* 2.8f0 u) 0f0)) (sum (+ rl il cl))
             (over (f-max 0f0 (- (+ sum gaps) avail)))
             (rmx (f-max rmin (- rl (/ (* over rl) (f-max sum 1f0))))) (imx (- il (/ (* over il) (f-max sum 1f0))))
             (cmx (f-max cmin (- cl (/ (* over cl) (f-max sum 1f0)))))
             (rcols (progn (lane! 0f0 0f0 rz 0.5f0 rmx) (lhud-vwords rw +f-display+ +c-paper+ nil) (aref a 6)))
             (ccols (if cryp (progn (lane! 0f0 0f0 cz 0.3f0 cmx) (lhud-vwords cw +f-mono+ +c-steel+ nil) (aref a 6)) 0f0))
             (sidew (f-max (* rcols rz) (f-max (* ccols cz) dpr))) (colw (+ kz (* 1.2f0 u) sidew))
             (x0 (if left (* (if phone 0.06f0 0.08f0) w) (- (* (if phone 0.94f0 0.92f0) w) colw)))
             (kx (+ x0 (* 0.5f0 kz))) (sr (+ x0 colw)) (sx (- sr (* 0.5f0 sidew)))
             (kv (svref ss 0)) (rev (twv *lh-brush-kv* (aref ts 1) now 0)) (sop (twv *lh-fade-side* (aref ts 1) now 0)))
        (declare (single-float kz rz cz top avail rl rmin cl cmin il gaps sum over rmx imx cmx rcols ccols sidew colw x0 kx sr sx rev sop)
                 (simple-string kv) (type f32vec a) (simple-vector rw cw))
        (paint-pen! 0f0 top kz :spacing 0.08f0) (paint-measure-vertical kv +f-kanji+)
        (when (> rev 0f0)
          (paint-scissor! -1f6 -1f6 1f6 (+ top (* rev (aref pen 7))))
          (paint-pen! kx (+ top (* 6f0 dpr)) kz :spacing 0.08f0) (paint-vertical kv +f-kanji+ +c-shade45+)
          (paint-pen! kx top kz :spacing 0.08f0) (paint-vertical kv +f-kanji+ +c-paper+)
          (paint-reset))
        (when (> sop 0.002f0)
          (paint-opacity! sop)
          (let* ((y (+ top u)))
            (declare (single-float y))
            (lane! sr y rz 0.5f0 rmx) (lhud-vwords rw +f-display+ +c-paper+ t)
            (when cryp
              (setf y (+ y (f-min rl rmx) (* 1.4f0 u)))
              (paint-rect (- sx (* 0.5f0 dpr)) y dpr imx +c-blood+)
              (setf y (+ y imx (* 1.4f0 u)))
              (lane! sr y cz 0.3f0 cmx) (lhud-vwords cw +f-mono+ +c-steel+ t)))
          (paint-reset)))
      ;; the VS bar: flex, baseline, gap 1.4u
      (let* ((op (twv *lh-fade-vs* (aref ts 0) now 0)))
        (declare (single-float op))
        (when (> op 0.002f0)
          (let* ((nz (* 1.9f0 u)) (vz (* 3.4f0 u)) (a (or (side-c 0 3) "")) (b (or (side-c 1 3) ""))
                 (rowh (row-h (+f-display+ nz 1f0) (+f-display+ vz 1f0))) (base (- (* (if phone 0.88f0 0.86f0) h) (- rowh (aref *lhud-row* 0))))
                 (x (* 0.06f0 w)) (vk (/ vz (f-min vz +big-px+))))   ; ("vs" stays lower case: the body tier, scaled past 40 px)
            (declare (single-float nz vz rowh base x vk))
            (paint-opacity! op)
            (paint-pen! (f-floor+ x) (f-floor+ base) nz :spacing 0.16f0) (paint-text a +f-display+ +c-paper+)
            (setf x (+ (aref pen 0) (* 1.4f0 u)))
            (paint-push) (paint-transform! x base :sx vk :sy vk)
            (paint-pen! x base (/ vz vk) :skew 0.25f0) (paint-text "vs" +f-display+ +c-blood+)
            (setf x (+ x (* vk (- (aref pen 0) x)) (* 1.4f0 u)))
            (paint-pop)
            (paint-pen! (f-floor+ x) (f-floor+ base) nz :spacing 0.16f0) (paint-text b +f-display+ +c-steel+))))
      (paint-reset))
    nil))

;;; ---------------------------------------------------------------- READY / 斬 and the slash line: the view
(defun-fast lhud-ready ()
  "READY (900 9u display, .12em) and 斬 (800 15u Mincho) at the centre (hd-ready: in from scale 1.7 and a 6 px blur, held, out to .94;
a 6 px shadow), the slash line (3 px paper across 120 % of the width at the middle, rotate -8deg, hd-slash) (z 19)."
  (let* ((now (aref *ui-clock* 0)) (ts *lhud-ov-t*) (u (lay-u 1f0)) (w (lay-w)) (h (lay-h)) (dpr (lay-dpr)) (pen *paint-pen*))
    (declare (single-float now u w h dpr) (type f32vec ts pen))
    (let* ((s (twv *lh-slash* (aref ts 4) now 0)) (op (twv *lh-slash* (aref ts 4) now 1)) (o (twv *lh-slash* (aref ts 4) now 2)))
      (declare (single-float s op o))
      (when (and (> op 0.002f0) (> s 0.001f0))
        (let* ((x0 (* -0.1f0 w)) (ox (+ x0 (* o 1.2f0 w))) (cy (* 0.5f0 h)))
          (declare (single-float x0 ox cy))
          (paint-reset) (paint-opacity! op)
          (paint-transform! ox (+ cy (* 1.5f0 dpr)) :sx s :rot -0.13963f0)
          (paint-rect x0 cy (* 1.2f0 w) (* 3f0 dpr) +c-paper+)
          (paint-reset))))
    (macrolet ((word (anim start str face size spacing)
                 `(let* ((op (twv ,anim ,start now 0)) (sc (twv ,anim ,start now 1)) (bl (twv ,anim ,start now 2)))
                    (declare (single-float op sc bl))
                    (when (> op 0.002f0)
                      (let* ((sz ,size) (cx (* 0.5f0 w)) (cy (* 0.5f0 h)) (base (+ (- cy (* 0.5f0 sz)) (line-baseline ,face sz 1f0)))
                             (soft (+ 1f0 (* 2f0 bl dpr))))
                        (declare (single-float sz cx cy base soft))
                        (paint-reset) (paint-opacity! op) (paint-transform! cx cy :sx sc :sy sc)
                        (paint-pen! 0f0 0f0 sz :spacing ,spacing) (paint-measure ,str ,face)
                        (let ((x (- cx (* 0.5f0 (aref pen 7)))))
                          (declare (single-float x))
                          (paint-pen! x (+ base (* 6f0 dpr)) sz :spacing ,spacing :soft soft) (paint-text ,str ,face +c-shade5+)
                          (paint-pen! x base sz :spacing ,spacing :soft soft) (paint-text ,str ,face +c-paper+))
                        (paint-reset))))))
      (word *lh-ready-r* (aref ts 2) "READY" +f-display+ (* 9f0 u) 0.12f0)
      (word *lh-ready-k* (aref ts 3) (kj "斬") +f-kanji+ (* 15f0 u) 0f0))
    nil))

;;; ---------------------------------------------------------------- the finish: the system and the view
(defun-fast lhud-finish-update ()
  "hud.js renderCard's finish: when V15 turns on (1 K.O., 2 TIME with a winner, 3 a draw) its words and the winner (V16) are taken
and its animations start."
  (let* ((iv *lhud-ov-i*) (ss *lhud-ov-s*) (fs *lhud-fin-strs*) (fk (hv 15)))
    (declare (fixnum fk))
    (when (and (> fk 0) (/= fk (aref iv 3)))
      (let ((wn (hv 16)))
        (setf (svref ss 3) (svref fs (if (= fk 1) 0 1)) (svref ss 4) (svref fs (case fk (1 2) (2 3) (t 4)))
              (svref ss 5) (svref fs (if (= wn 2) 6 5)) (aref iv 8) wn)
        (when (= (aref iv 3) 0) (setf (aref *lhud-ov-t* 5) (aref *ui-clock* 0)))))
    (setf (aref iv 3) fk)
    nil))

(defun-fast lhud-finish ()
  "The finish (z 18): the bottom 42 % darkened (to ink .82), 決着 / 時間切れ (800 10.5u Mincho, vertical, 9 % from the right, 10 % down,
an 8 px shadow, hd-brush), the blood splat behind it (8u, hd-splat), K.O. / TIME / DRAW (600 1.1u mono, .6em, turned, hd-fade), the
winner bottom-left (6 %, 13 % up; hd-rise): Winner · 勝者 (600 .8u mono .3em steel), the name (900 4.6u / .9 display .04em), 魂魄 a–b ·
最長連段 n · 毀魂 n (500 1u sans steel, the numbers 600 1u mono paper). The phone: 7 % / 8 %, 9u, the winner 12 % up."
  (when (> (aref *lhud-ov-i* 3) 0)
    (let* ((now (aref *ui-clock* 0)) (t0 (aref *lhud-ov-t* 5)) (ss *lhud-ov-s*) (u (lay-u 1f0)) (w (lay-w)) (h (lay-h)) (dpr (lay-dpr))
           (phone (lay-portrait-p)) (pen *paint-pen*) (pts *lhud-pts*))
      (declare (single-float now t0 u w h dpr) (type f32vec pen pts))
      (paint-reset)
      (paint-rect 0f0 (* 0.58f0 h) w (* 0.42f0 h) +c-fin0+ +c-fin1+)
      ;; the splat (right 7 %, top 6 %, 8u; the phone keeps it) under 決着
      (let* ((op (twv *lh-splat* t0 now 0)) (sc (twv *lh-splat* t0 now 1)) (rot (* 0.017453f0 (twv *lh-splat* t0 now 2)))
             (sz (* 8f0 u)) (x0 (- (* 0.93f0 w) sz)) (y0 (* 0.06f0 h)))
        (declare (single-float op sc rot sz x0 y0))
        (when (> op 0.002f0)
          (dotimes (i 14) (setf (aref pts (* 2 i)) (+ x0 (* sz (aref *lhud-splat-pts* (* 2 i)))) (aref pts (1+ (* 2 i))) (+ y0 (* sz (aref *lhud-splat-pts* (1+ (* 2 i)))))))
          (paint-push) (paint-opacity! (f-min 1f0 op)) (paint-transform! (+ x0 (* 0.5f0 sz)) (+ y0 (* 0.5f0 sz)) :sx sc :sy sc :rot rot)
          (paint-clip! -1f6 -1f6 1f6 1f6) (paint-centre! (+ x0 (* 0.5f0 sz)) (+ y0 (* 0.5f0 sz))) (paint-poly pts 14 +c-blood+ +c-blood+)
          (paint-pop)))
      ;; 決着: vertical, revealed top to bottom
      (let* ((kz (* (if phone 9f0 10.5f0) u)) (right (* (if phone 0.93f0 0.91f0) w)) (top (* (if phone 0.08f0 0.1f0) h))
             (kx (- right (* 0.5f0 kz))) (s (svref ss 3)) (rev (twv *lh-brush-kk* t0 now 0)))
        (declare (single-float kz right top kx rev) (simple-string s))
        (when (> rev 0f0)
          (paint-pen! 0f0 top kz) (paint-measure-vertical s +f-kanji+)
          (paint-scissor! -1f6 -1f6 1f6 (+ top (* rev (aref pen 7))))
          (paint-pen! kx (+ top (* 8f0 dpr)) kz) (paint-vertical s +f-kanji+ +c-shade5+)
          (paint-pen! kx top kz) (paint-vertical s +f-kanji+ +c-paper+)
          (paint-reset)))
      ;; K.O.: right 9 % + 11.5u (phone 7 % + 10u), 12 % down, turned
      (let* ((op (twv *lh-fade-ko* t0 now 0)) (oz (* 1.1f0 u))
             (right (- (* (if phone 0.93f0 0.91f0) w) (* (if phone 10f0 11.5f0) u))))
        (declare (single-float op oz right))
        (when (> op 0.002f0)
          (paint-opacity! op)
          (paint-pen! (- right (* 0.5f0 oz)) (* 0.12f0 h) oz :spacing 0.6f0) (paint-vertical (svref ss 4) +f-mono+ +c-paper+)
          (paint-reset)))
      ;; the winner: grid, gap .6u, from 6 % / 13 % up, hd-rise
      (let* ((op (twv *lh-rise* t0 now 0)) (dy (* u (twv *lh-rise* t0 now 1))))
        (declare (single-float op dy))
        (when (> op 0.002f0)
          (let* ((lz (* 0.8f0 u)) (nz (* 4.6f0 u)) (sz u) (x (f-floor+ (* 0.06f0 w)))
                 (wn (aref *lhud-ov-i* 8)) (name (if (= wn 2) "DRAW" (or (side-c (if (= wn 1) 1 0) 3) "")))
                 (wo (side-o (if (= wn 1) 1 0))) (lo (side-o (if (= wn 1) 0 1)))
                 (bottom (+ (* (if phone 0.88f0 0.87f0) h) dy)) (sh (* 1.4f0 sz))
                 (y3 (- bottom sh)) (y2 (- y3 (* 0.6f0 u) (* 0.9f0 nz))) (y1 (- y2 (* 0.6f0 u) lz)) (fl *lhud-fin-line*))
            (declare (single-float lz nz sz x bottom sh y3 y2 y1) (fixnum wn wo lo))
            (paint-opacity! op)
            (paint-pen! x (f-floor+ (+ y1 (line-baseline +f-mono+ lz 1f0))) lz :spacing 0.3f0) (paint-text (svref ss 5) +f-mono+ +c-steel+)
            (paint-pen! x (f-floor+ (+ y2 (line-baseline +f-display+ nz 0.9f0))) nz :spacing 0.04f0) (paint-text name +f-display+ +c-paper+)
            (let* ((base (f-floor+ (+ y3 (line-baseline +f-sans+ sz 1.4f0)))))
              (declare (single-float base))
              (macrolet ((zh-run (i) `(progn (paint-pen! (aref pen 0) base sz) (paint-text (svref fl ,i) +f-sans+ +c-steel+)))
                         (num (n) `(progn (paint-pen! (aref pen 0) base sz) (paint-int ,n +f-mono+ +c-paper+))))
                (paint-pen! x base sz)
                (zh-run 0) (num (max 0 (hv (+ wo 3))))
                (paint-pen! (aref pen 0) base sz) (paint-text (svref fl 3) +f-mono+ +c-paper+) (num (max 0 (hv (+ lo 3))))
                (zh-run 1) (num (max 0 (hv (+ wo 17))))
                (zh-run 2) (num (max 0 (hv (+ wo 18)))))))))
      (paint-reset))
    nil))

;;; ---------------------------------------------------------------- the pause: the system
(defun-fast lhud-pause-update ()
  "hud.js renderPause: opening restarts hd-strip (and the phone's hd-fromtab); a new rows serial (V19) splits the rows (S10 + i, V18 of
them) into English / value / zh (allocation only then); each row's cursor (V17) eases in and out (.2 s ease-out)."
  (let* ((now (aref *ui-clock* 0)) (iv *lhud-ov-i*) (paused (logtest (hv 0) 4)) (cur (hv 17)) (pz *lhud-pz*))
    (declare (single-float now) (fixnum cur))
    (when (and paused (/= (aref iv 4) 1))                 ; (and the mouse where it is: a still pointer over a row moves nothing)
      (setf (aref *lhud-ov-t* 6) now (aref *lhud-ov-t* 7) (mouse-x) (aref *lhud-ov-t* 8) (mouse-y)))
    (setf (aref iv 4) (if paused 1 0))
    (when (and paused (/= (hv 19) (aref iv 5)))
      (let ((n (max 0 (min 20 (hv 18)))))
        (dotimes (i n)
          (multiple-value-bind (en val zh) (lhud-pause-row (hs (+ 10 i)))
            (setf (svref pz (* 3 i)) en (svref pz (+ 1 (* 3 i))) val (svref pz (+ 2 (* 3 i))) zh)))
        (setf (aref iv 5) (hv 19) (aref iv 7) n)))
    (dotimes (i 20) (trans-to *lhud-pz-tr* i (if (= i cur) 1f0 0f0) now 0.2f0 +ease-out+))
    nil))

;;; ---------------------------------------------------------------- the pause: the view
(declaim (type f32vec *lhud-pz-m*))
(defvar *lhud-pz-m* (make-f32 60) "The pause rows' measures this frame (LHUD-PZ-MEASURE): per row its content height, the third column's width, the English's lines.")
(defun-fast lhud-pz-measure (n)
  "Each of the N pause rows' grid (2.4u 1fr auto, gap 1u): the third column's width (the boxed value or the zh), the English wrapped in
what is left (the phone's narrow strip: CHARACTER / SELECT, as the HTML wraps it) and the row's content height (its tallest item) into
*LHUD-PZ-M*. *LHUD-A*: the content width, the English's size, the zh's, the number's, the value's, the value box's height, u, dpr.
Out: [0] the sum of the heights."
  (declare (fixnum n))
  (let* ((a *lhud-a*) (cw (aref a 0)) (enz (aref a 1)) (zhz (aref a 2)) (noz (aref a 3)) (vaz (aref a 4)) (vah (aref a 5)) (u (aref a 6))
         (dpr (aref a 7)) (pz *lhud-pz*) (m *lhud-pz-m*) (pen *paint-pen*) (sum 0f0))
    (declare (type f32vec a m pen) (single-float cw enz zhz noz vaz vah u dpr sum))
    (dotimes (i n)
      (let* ((en (svref pz (* 3 i))) (val (svref pz (+ 1 (* 3 i)))) (zh (svref pz (+ 2 (* 3 i))))
             (c3 (cond (val (+ (text-w val +f-mono+ vaz 0.12f0) (* 1.2f0 u) (* 2f0 dpr))) (zh (text-w zh +f-sans+ zhz)) (t 0f0)))
             (ew (- cw (* 4.4f0 u) c3))
             (lines (if (and en (find #\Space en) (> (text-w en +f-display+ enz 0.06f0) ew)) 2 1)))   ; ponytail: two lines at most (the rows are two words)
        (declare (single-float c3 ew) (fixnum lines))
        (setf (aref m (* 3 i)) (f-max (* enz (i->f lines)) (f-max noz (if val vah (if zh zhz 0f0))))
              (aref m (+ 1 (* 3 i))) c3 (aref m (+ 2 (* 3 i))) (i->f lines))
        (incf sum (aref m (* 3 i)))))
    (setf (aref a 0) sum)
    nil))

(defun-fast lhud-pause ()
  "The pause (z 20): 止 (800 13u Mincho / .9, vertical, a 6 px shadow; the phone 10u across, grown out of the clock tab by hd-fromtab)
with its blood blot (40 % of its box, 12 points, .92, behind it) and the paper strip (padding 2.2u 3u 2.2u 3.4u, polygon(0 2%, 100% 0,
98.6% 98%, 1.4% 100%), rotate -1.2deg about its left, at most 46u wide; revealed by hd-strip): the eyebrow (600 .8u mono .28em, #5b6070;
ROTATE TO PORTRAIT in blood when the phone is turned) and the rows (grid 2.4u 1fr auto, gap 1u, padding .75u, 1 px rules): the number
(600 .75u mono), the English (900 2.1u display .06em; the cursor's blood and .6u right), the zh (500 .95u sans) or the value (600 .8u
mono .12em, boxed). More than six rows: padding .42u, 1.5u. The phone: one column, 6u in, 止 over the strip; rows 2.6u (2u), zh 1.3u,
no 1u, value 1.1u. Desktop: 止 and the strip side by side (gap 3u, 8u in), both centred. Each row is a hot box (700 + row)."
  (when (logtest (hv 0) 4)
    (let* ((now (aref *ui-clock* 0)) (u (lay-u 1f0)) (w (lay-w)) (h (lay-h)) (dpr (lay-dpr)) (phone (lay-portrait-p))
           (pen *paint-pen*) (pts *lhud-pts*) (t0 (aref *lhud-ov-t* 6)) (n (aref *lhud-ov-i* 7)) (long (> n 6)) (pz *lhud-pz*)
           (rot (logtest (hv 0) 64))
           ;; sizes (hud.css, the phone's overrides)
           (enz (* u (if phone (if long 2f0 2.6f0) (if long 1.5f0 2.1f0)))) (zhz (* u (if phone 1.3f0 0.95f0)))
           (noz (* u (if phone 1f0 0.75f0))) (vaz (* u (if phone 1.1f0 0.8f0))) (eyz (* 0.8f0 u))
           (padv (* u (if long 0.42f0 0.75f0))) (vah (+ vaz (* 0.7f0 u) (* 2f0 dpr)))
           (bz (* u (if phone 10f0 13f0))) (bw (if phone bz (* 0.9f0 bz))) (bh (if phone (* 0.9f0 bz) bz))
           (sw (if phone (- w (* 12f0 u)) (f-min (* 46f0 u) (- w (* 16f0 u) bw (* 3f0 u)))))
           (rows (progn (lane! (- sw (* 6.4f0 u)) enz zhz noz vaz vah u dpr) (lhud-pz-measure n) (aref *lhud-a* 0)))
           (inner (+ eyz (* 0.8f0 u) (* 0.4f0 u) (* (i->f n) 2f0 padv) (* (i->f (max 0 (1- n))) dpr) rows))
           (sh (+ inner (* 4.4f0 u)))
           (gtop (* 0.5f0 (- h (+ bh (* 2f0 u) sh))))
           (bx (if phone (* 6f0 u) (* 8f0 u))) (by (if phone gtop (* 0.5f0 (- h bh))))
           (sx (if phone (* 6f0 u) (+ bx bw (* 3f0 u)))) (sy (if phone (+ gtop bh (* 2f0 u)) (* 0.5f0 (- h sh)))))
      (declare (single-float now u w h dpr t0 enz zhz noz vaz eyz padv vah bz bw bh sw rows inner sh gtop bx by sx sy)
               (fixnum n) (type f32vec pen pts))
      (paint-reset)
      ;; 止 and its blot (the phone with the deck: hd-fromtab out of the clock tab)
      (paint-push)
      (when (and phone (hv-deck-p))
        (let* ((tx (twv *lh-fromtab* t0 now 0)) (ty (twv *lh-fromtab* t0 now 1)) (s (twv *lh-fromtab* t0 now 2)) (o (twv *lh-fromtab* t0 now 3)))
          (declare (single-float tx ty s o))
          (paint-transform! bx by :sx s :sy s :dx (lay-vw tx) :dy (lay-vh ty)) (paint-opacity! o)))
      (let* ((d (* 0.4f0 bw)) (ox (- (+ bx bw (* 0.2f0 bw)) d)) (oy (- by (* 0.08f0 bh))))
        (declare (single-float d ox oy))
        (dotimes (i 12) (setf (aref pts (* 2 i)) (+ ox (* d (aref *lhud-blot* (* 2 i)))) (aref pts (1+ (* 2 i))) (+ oy (* d (aref *lhud-blot* (1+ (* 2 i)))))))
        (paint-clip! -1f6 -1f6 1f6 1f6) (paint-centre! (+ ox (* 0.5f0 d)) (+ oy (* 0.5f0 d))) (paint-poly pts 12 +c-blot+ +c-blot+))
      (if phone
          (let ((base (+ by (line-baseline +f-kanji+ bz 0.9f0))))
            (declare (single-float base))
            (paint-pen! bx (+ base (* 6f0 dpr)) bz) (paint-text (kj "止") +f-kanji+ +c-shade5+)
            (paint-pen! bx base bz) (paint-text (kj "止") +f-kanji+ +c-paper+))
          (progn (paint-pen! (+ bx (* 0.5f0 bw)) (+ by (* 6f0 dpr)) bz) (paint-vertical (kj "止") +f-kanji+ +c-shade5+)
                 (paint-pen! (+ bx (* 0.5f0 bw)) by bz) (paint-vertical (kj "止") +f-kanji+ +c-paper+)))
      (paint-pop)
      ;; the strip: rotated -1.2deg about its left centre, cut by hd-strip
      (let* ((k (twv *lh-strip* t0 now 0)) (cx0 (+ sx (* 3.4f0 u))) (cx1 (- (+ sx sw) (* 3f0 u))))
        (declare (single-float k cx0 cx1))
        (paint-transform! sx (+ sy (* 0.5f0 sh)) :rot -0.020944f0)
        (paint-scissor! (- sx 1f0) -1f6 (+ sx (* k sw)) 1f6)
        (setf (aref pts 0) sx (aref pts 1) (+ sy (* 0.02f0 sh)) (aref pts 2) (+ sx sw) (aref pts 3) sy
              (aref pts 4) (+ sx (* 0.986f0 sw)) (aref pts 5) (+ sy (* 0.98f0 sh)) (aref pts 6) (+ sx (* 0.014f0 sw)) (aref pts 7) (+ sy sh))
        (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly pts 4 +c-paper+ +c-paper+)
        (let* ((y (+ sy (* 2.2f0 u))))
          (declare (single-float y))
          (paint-pen! (f-floor+ cx0) (f-floor+ (+ y (line-baseline +f-mono+ eyz 1f0))) eyz :spacing 0.28f0)
          (paint-text (if rot *lhud-ey-rotate* *lhud-ey-pause*) +f-mono+ (if rot +c-blood+ +c-pz-ey+))
          (setf y (+ y eyz (* 0.8f0 u) (* 0.4f0 u)))
          (dotimes (i n)
            (let* ((cur (trans-value *lhud-pz-tr* i now)) (on (= i (hv 17)))
                   (en (svref pz (* 3 i))) (val (svref pz (+ 1 (* 3 i)))) (zh (svref pz (+ 2 (* 3 i))))
                   (m *lhud-pz-m*) (rowc (aref m (* 3 i))) (lines (fl-round (aref m (+ 2 (* 3 i)))))
                   (rowh (+ rowc (* 2f0 padv))) (cy (+ y padv (* 0.5f0 rowc))))
              (declare (single-float cur rowc rowh cy) (type f32vec m) (fixnum lines))
              (when (> i 0) (paint-rect cx0 y (- cx1 cx0) dpr +c-pz-rule+) (setf y (+ y dpr) cy (+ cy dpr)))
              (hot-add (+ 700 i) cx0 y cx1 (+ y rowh))
              (paint-pen! (f-floor+ cx0) (f-floor+ (+ (- cy (* 0.5f0 noz)) (line-baseline +f-mono+ noz 1f0))) noz)
              (paint-int-tab (1+ i) +f-mono+ (if on +c-blood+ +c-pz-no+) 2)
              (when en
                (let ((ex (f-floor+ (+ cx0 (* 2.4f0 u) u (* 0.6f0 u cur)))) (col (col-mix! *lhud-mix* +c-ink+ +c-blood+ cur)))
                  (declare (single-float ex))
                  (if (> lines 1)                         ; (wrapped in its 1fr column, line-height 1)
                      (progn (paint-pen! ex (f-floor+ (- cy (* 0.5f0 enz (i->f lines)))) enz :spacing 0.06f0)
                             (paint-paragraph en +f-display+ col :width (- cx1 cx0 (* 4.4f0 u) (aref m (+ 1 (* 3 i)))) :lh 1f0))
                      (progn (paint-pen! ex (f-floor+ (+ (- cy (* 0.5f0 enz)) (line-baseline +f-display+ enz 1f0))) enz :spacing 0.06f0)
                             (paint-text en +f-display+ col)))))
              (cond (val
                     (let* ((vw (+ (text-w val +f-mono+ vaz 0.12f0) (* 1.2f0 u) (* 2f0 dpr))) (vx (- cx1 vw)))
                       (declare (single-float vw vx))
                       (paint-box! (+ vx (* 0.5f0 vw)) cy (- (* 0.5f0 vw) (* 0.5f0 dpr)) (- (* 0.5f0 vah) (* 0.5f0 dpr)) 0f0 1f0 dpr +c-ink+)
                       (paint-pen! (f-floor+ (+ vx dpr (* 0.6f0 u))) (f-floor+ (+ (- cy (* 0.5f0 vaz)) (line-baseline +f-mono+ vaz 1f0))) vaz :spacing 0.12f0)
                       (paint-text val +f-mono+ +c-ink+)))
                    (zh
                     (paint-pen! 0f0 0f0 zhz) (paint-measure zh +f-sans+)
                     (paint-pen! (f-floor+ (- cx1 (aref pen 7))) (f-floor+ (+ (- cy (* 0.5f0 zhz)) (line-baseline +f-sans+ zhz 1f0))) zhz)
                     (paint-text zh +f-sans+ +c-pz-ey+)))
              (setf y (+ y rowh))))))
      (paint-reset))
    nil))

;;; ---------------------------------------------------------------- the pause rows' pointer (hud.js's strip listeners)
(defun-fast lhud-pause-pointer ()
  "Under :LISP, the pause rows' pointer presses as the page's queue would send them (WEBHUD-PAUSE-CMD): the mouse moved onto a row
(pointerover) puts the cursor there; a click or a tap on a row puts the cursor there and confirms. Hits are on last frame's hot boxes
(700 + row: what the player saw). Called by WEBHUD-COMMANDS before the flow reads the frame's presses."
  (let* ((iv *lhud-ov-i*) (ts *lhud-ov-t*) (n (aref iv 7)) (mx (mouse-x)) (my (mouse-y)) (hov (- (hot-hit mx my) 700))
         (moved (or (/= mx (aref ts 7)) (/= my (aref ts 8)))))   ; (the position, not SDL's relative motion: a synthetic event has none)
    (declare (fixnum n hov) (single-float mx my) (type f32vec ts))
    (setf (aref ts 7) mx (aref ts 8) my)
    (when (or (< hov 0) (>= hov n)) (setf hov -1))
    (when (and moved (>= hov 0) (/= hov (aref iv 6)) (/= hov (hv 17))) (webhud-pause-cmd 1 hov))
    (setf (aref iv 6) hov)
    (when (and (>= hov 0) (mouse-pressed :left)) (webhud-pause-cmd 1 hov) (webhud-pause-cmd 2 0))
    (when (tap-p)
      (let ((r (- (hot-hit (touch-tap-x *touch*) (touch-tap-y *touch*)) 700)))
        (declare (fixnum r))
        (when (< -1 r n) (webhud-pause-cmd 1 r) (webhud-pause-cmd 2 0))))
    nil))
