;;;; lhud-clock.lisp — the battle clock (docs/duel/DUEL_LISP_HUD.md §13, §14; hud.css .clock, hud.js render): the seconds (the last
;;;; ten in blood, hd-tick) or PRACTICE's ∞ (drawn by hd-write) over its caption; at the top centre on a desktop / landscape screen,
;;;; at the top-left of a phone in portrait without the deck, and on the deck as the clock tab that is the pause chip (a cut-corner
;;;; tab with II 止 PAUSE). LHUD-CLOCK-UPDATE is its system (when the ∞ starts drawing); LHUD-CLOCK the view.
(in-package :duel)

(defparameter +c-tab+ (rgba #x0b0b10 0.5)) (defparameter +c-tab-line+ (rgba #xeeeeea 0.28)) (defparameter +c-tab-dot+ (rgba #xeeeeea 0.35))
(defparameter +c-clock-shade+ (rgba #x000000 0.55))
(defparameter *lhud-write* (make-tween '((0 nil 0) (1 nil 1)) :dur 0.9 :curve +ease-cut+ :fill 3 :base '(1))
  "hd-write: the ∞'s stroke drawn 0 -> 1 (stroke-dashoffset 100 -> 0), .9 s ease-cut, both.")
(declaim (type f32vec *lhud-write* *lhud-ck-f*) (type (simple-array fixnum (*)) *lhud-ck-i*))
(defvar *lhud-ck-f* (make-f32 1) "[0] the ∞'s hd-write start.")
(defvar *lhud-ck-i* (make-array 1 :element-type 'fixnum :initial-element 0) "[0] the ∞ shown last frame (1 / 0).")
(defparameter *lhud-ck-round* (zh "ROUND · 決闘")) (defparameter *lhud-ck-prac* (zh "PRACTICE · 練習"))

(defun-fast lhud-clock-update ()
  "The clock's state: PRACTICE's ∞ restarts hd-write when it appears (.clock.inf)."
  (let* ((inf (and (hv-practice-p) (logtest (hv 0) 1))))
    (when (and inf (/= (aref *lhud-ck-i* 0) 1)) (setf (aref *lhud-ck-f* 0) (aref *ui-clock* 0)))
    (setf (aref *lhud-ck-i* 0) (if inf 1 0)))
  nil)

(defun-fast lhud-inf ()
  "PRACTICE's ∞ (hud.js INF, viewBox 66 x 32, stroke 2.6 round, a 2 px shadow) drawn by hd-write, its viewBox origin at X Y, K device
px a viewBox unit: *LHUD-A* x y k."
  (let* ((a *lhud-a*) (x (aref a 0)) (y (aref a 1)) (k (aref a 2)) (dpr (lay-dpr))
         (f (twv *lhud-write* (aref *lhud-ck-f* 0) (aref *ui-clock* 0) 0)) (np (floor (length *sh-inf*) 2)))
    (declare (single-float x y k dpr f) (fixnum np) (type f32vec a))
    (when (> f 0.001f0)
      (paint-push) (paint-transform! 0f0 0f0 :sx k :sy k :dx x :dy (+ y (* 2f0 dpr)))
      (paint-stroke! *sh-inf* np 2.6f0 +c-clock-shade+ :frac f :round t) (paint-pop)
      (paint-push) (paint-transform! 0f0 0f0 :sx k :sy k :dx x :dy y)
      (paint-stroke! *sh-inf* np 2.6f0 +c-paper+ :frac f :round t) (paint-pop))
    nil))

(defun-fast lhud-digits (t0)
  "The seconds T0 (two digits at least, tabular, a 3 px shadow; the last ten in blood with hd-tick's 1 s steps(1) dim half) at X on
the baseline BASE, TZ px: *LHUD-A* x base tz."
  (declare (fixnum t0))
  (let* ((a *lhud-a*) (x (aref a 0)) (base (aref a 1)) (tz (aref a 2)) (end (<= t0 10))
         (blink (and end (>= (f-mod (aref *ui-clock* 0) 1f0) 0.5f0))))
    (declare (single-float x base tz) (type f32vec a))
    (paint-push) (when blink (paint-opacity! 0.55f0))
    (paint-pen! (f-floor+ x) (+ base (* 3f0 (lay-dpr))) tz :spacing 0.01f0) (paint-int-tab t0 +f-display+ +c-clock-shade+ 2)
    (paint-pen! (f-floor+ x) base tz :spacing 0.01f0) (paint-int-tab t0 +f-display+ (if end +c-blood+ +c-paper+) 2)
    (paint-pop)
    nil))

(defun-fast lhud-clock ()
  "The clock (.clock), in .hudl (.3 paused, out in a cinematic). With the phone's deck: the clock tab = the pause chip (on Lisp's chip
6, 10.4 x 8.4u from its middle - 5.2u / 4.2u): a cut-corner tab (rgba(11,11,16,.5), an inset .28 line, a small ring top-right), the
seconds (800 3.4u) or ∞ (6.6 x 3.2u) and II 止 PAUSE; out when paused. Else a grid (gap .3u) of the seconds (800 4.3u / .85, phone
3.4u) or the ∞ (7 x 3.6u, phone 6.6 x 3.2u) over the caption (600 .62u mono, .3em, stone): ROUND · 決闘 / PRACTICE · 練習; centred at
the top (max(1.6u, st + .6u)) on a desktop, from 2.4u / 3.4u + st on a phone in portrait. Hidden when V1 < 0 outside PRACTICE."
  (let* ((u (lay-u 1f0)) (dpr (lay-dpr)) (w (lay-w)) (h (lay-h)) (phone (lay-portrait-p)) (deck (and phone (hv-deck-p)))
         (t0 (hv 1)) (prac (hv-practice-p)) (op (* (layer-op 0) (if deck (layer-op 2) 1f0))) (pts *lhud-pts*))
    (declare (single-float u dpr w h op) (fixnum t0) (type f32vec pts))
    (when (and (> op 0.002f0) (or prac (>= t0 0)))
      (paint-reset)
      (paint-opacity! op)
      (if deck
          (let* ((bx (- (/ (* w (i->f (hv 39))) 1000f0) (* 5.2f0 u))) (by (- (/ (* h (i->f (hv 40))) 1000f0) (* 4.2f0 u)))
                 (bw (* 10.4f0 u)) (bh (* 8.4f0 u)) (cx (+ bx (* 1.3f0 u))) (cy (+ by (* 1.1f0 u))))
            (declare (single-float bx by bw bh cx cy))
            ;; polygon(0 0, 100% 0, 100% 78%, 86% 100%, 0 100%) + its inset line, the ring at the top right
            (setf (aref pts 0) bx (aref pts 1) by (aref pts 2) (+ bx bw) (aref pts 3) by (aref pts 4) (+ bx bw) (aref pts 5) (+ by (* 0.78f0 bh))
                  (aref pts 6) (+ bx (* 0.86f0 bw)) (aref pts 7) (+ by bh) (aref pts 8) bx (aref pts 9) (+ by bh))
            (paint-clip! -1f6 -1f6 1f6 1f6) (paint-poly pts 5 +c-tab+ +c-tab+)
            (paint-rect bx by bw dpr +c-tab-line+) (paint-rect bx (+ by dpr) dpr (- bh (* 2f0 dpr)) +c-tab-line+)
            (paint-rect bx (- (+ by bh) dpr) (* 0.86f0 bw) dpr +c-tab-line+)
            (paint-rect (- (+ bx bw) dpr) (+ by dpr) dpr (- (* 0.78f0 bh) dpr) +c-tab-line+)
            (paint-ellipse! (- (+ bx bw) (* 0.95f0 u) (* 0.35f0 u)) (+ by (* 0.75f0 u) (* 0.35f0 u)) (* 0.35f0 u) (* 0.35f0 u) +c-tab-dot+ :thick dpr)
            (if prac
                (progn (lane! cx cy (* 0.1f0 u)) (lhud-inf))
                (let* ((tz (* 3.4f0 u)))
                  (declare (single-float tz))
                  (lane! cx (f-floor+ (+ cy (line-baseline +f-display+ tz 0.85f0))) tz) (lhud-digits t0)))
            ;; II 止 PAUSE at the bottom (align-content: space-between)
            (let* ((rh (* 1.45f0 u)) (ry (- (+ by bh) u rh)) (rc (+ ry (* 0.5f0 rh))) (x cx) (kz (* 1.45f0 u)) (pz u))
              (declare (single-float rh ry rc x kz pz))
              (paint-rect x (- rc (* 0.575f0 u)) (* 0.32f0 u) (* 1.15f0 u) +c-paper+)
              (paint-rect (+ x (* 0.56f0 u)) (- rc (* 0.575f0 u)) (* 0.32f0 u) (* 1.15f0 u) +c-paper+)
              (setf x (+ x (* 0.88f0 u) (* 0.55f0 u)))
              (paint-pen! (f-floor+ x) (f-floor+ (+ (- rc (* 0.5f0 kz)) (line-baseline +f-kanji+ kz 1f0))) kz) (paint-text (kj "止") +f-kanji+ +c-paper+)
              (setf x (+ x (text-w (kj "止") +f-kanji+ kz) (* 0.55f0 u)))
              (paint-pen! (f-floor+ x) (f-floor+ (+ (- rc (* 0.5f0 pz)) (line-baseline +f-mono+ pz 1f0))) pz :spacing 0.16f0)
              (paint-text "PAUSE" +f-mono+ +c-steel+)))
          ;; the grid: the seconds or the ∞, the caption .3u under it; centred (desktop) or from the left (phone)
          (let* ((tz (* (if phone 3.4f0 4.3f0) u)) (iw (* (if phone 6.6f0 7f0) u)) (ih (* (if phone 3.2f0 3.6f0) u))
                 (rz (* 0.62f0 u)) (cap (if prac *lhud-ck-prac* *lhud-ck-round*)) (rw (text-w cap +f-mono+ rz 0.3f0))
                 (tw (if prac iw (progn (paint-pen! 0f0 0f0 tz :spacing 0.01f0) (paint-measure-int-tab t0 +f-display+ 2) (aref *paint-pen* 7))))
                 (gw (f-max tw rw)) (r1 (if prac ih (* 0.85f0 tz)))
                 (top (if phone (+ (* 3.4f0 u) (lay-inset 0)) (f-max (* 1.6f0 u) (+ (lay-inset 0) (* 0.6f0 u)))))
                 (left (if phone (* 2.4f0 u) (* 0.5f0 (- w gw))))
                 (x1 (if phone left (+ left (* 0.5f0 (- gw tw))))) (x2 (if phone left (+ left (* 0.5f0 (- gw rw))))))
            (declare (single-float tz iw ih rz rw tw gw r1 top left x1 x2))
            (if prac
                (let* ((k (f-min (/ iw 66f0) (/ ih 32f0))))   ; (the svg's meet: scaled to fit, centred)
                  (declare (single-float k))
                  (lane! (+ x1 (* 0.5f0 (- iw (* 66f0 k)))) (+ top (* 0.5f0 (- ih (* 32f0 k)))) k) (lhud-inf))
                (progn (lane! x1 (f-floor+ (+ top (line-baseline +f-display+ tz 0.85f0))) tz) (lhud-digits t0)))
            (paint-pen! (f-floor+ x2) (f-floor+ (+ top r1 (* 0.3f0 u) (line-baseline +f-mono+ rz 1f0))) rz :spacing 0.3f0)
            (paint-text cap +f-mono+ +c-stone+)))
      (paint-reset))
    nil))
