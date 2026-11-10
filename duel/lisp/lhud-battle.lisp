;;;; lhud-battle.lisp — the battle HUD drawn by Lisp (docs/duel/DUEL_LISP_HUD.md), phase 0, the spike: the plates' name row and
;;;; Reishi bar, the combo with its hd-stamp pop, and a legibility card (debug 2518), drawn through the engine's paint stream
;;;; (paint.lisp) from the same model the HTML reads (*HUD-SENT* / *HUD-STRS*, webhud.lisp), placed and styled from hud.css's
;;;; rules. *HUD-RENDERER* :LISP (the URL flag ?hud=lisp, page get 8, or debug 2517) draws it and stops sending to the page;
;;;; :HTML (the default) leaves everything as it was. Phase 0 covers only these elements; the menus stay HTML.
;;;; Strings marked (kj "...") / (zh "...") / (big "...") are what tools/sdf-bake.py bakes (the Mincho, the sans, the display tier).
;;;; Cosmetic, outside the sim step; 0 B a frame in steady state (debug 2519).
(in-package :duel)

(defmacro kj (s) "A string drawn in the Mincho (the bake reads these)." s)
(defmacro zh (s) "A string drawn in, or falling back to, the sans (the bake reads these)." s)
(defmacro big (s) "Glyphs the display tier carries (the bake reads these)." s)
(big "0123456789")                                        ; (the combo count at 6.2u: 79 px at 1280 x 720)

(defvar *lhud-still* nil "Debug 2518: the Lisp HUD's still mode (phase 0: the legibility card).")
(defmacro f-floor+ (x) "Round to the nearest whole device pixel (text origins: crisper small text)." `(ffi:c-inline (,x) (:float) :float "floorf(#0+0.5f)" :one-liner t))

;;; ---------------------------------------------------------------- the look's constants (hud.css, menu.css :root)
(defparameter +c-paper+ (rgba #xeeeeea)) (defparameter +c-steel+ (rgba #xbcc1cc)) (defparameter +c-stone+ (rgba #x767d8e))
(defparameter +c-blood+ (rgba #xe81e3a)) (defparameter +c-jade+ (rgba #x7fe3c2)) (defparameter +c-white+ (rgba #xffffff))
(defparameter +c-shade+ (rgba #x000000 0.6))              ; the names' hard shadow
(defparameter +c-bar-bg+ (rgba #x0b0b10 0.48)) (defparameter +c-bar-line+ (rgba #xeeeeea 0.12))
(defparameter +c-fill-lo+ (rgba #xc9cbcf)) (defparameter +c-low-hi+ (rgba #xff6b7f))
(defparameter +c-grid+ (rgba #x0b0b10 (* 0.18 0.35)))     ; the Reishi grid: rgba(11,11,16,.18) at .35
(defparameter +c-slash+ (rgba #xe81e3a 0.9))
(defparameter +c-card+ (rgba #x0b0b10 1.0))
(defconstant +f-display+ 0) (defconstant +f-mono+ 1) (defconstant +f-kanji+ 2) (defconstant +f-sans+ 3)

(defparameter *lhud-names*                                ; roster index -> the plate's name (upper case, as the CSS shows it), kanji
  (vector (list "YAMAMOTO" (kj "山本")) (list "KENPACHI" (kj "更木")) (list "RUKIA" (kj "朽木")) (list "ICHIGO" (kj "黒崎"))
          (list "SENJUMARU" (kj "修多羅")) nil (list "LILLE" (kj "リジェ")) (list "HISAGI" (kj "檜佐木"))))

(declaim (type f32vec *lhud-f* *lhud-pts*) (type (simple-array fixnum (*)) *lhud-i*))
(defvar *lhud-f* (make-f32 40)
  "Per side s at 20 s: [0..2] the ghost's from / to / start, [3] last Reishi, [4..6] the combo's opacity from / to / start,
[7..9] its x shift (u) from / to / start, [10] the stamp's start, [11] shown at.")
(defvar *lhud-i* (make-array 12 :element-type 'fixnum :initial-element 0)
  "Per side s at 6 s: [0] the combo serial seen, [1] hits, [2] dmg, [3] scale %, [4] on (1 / 0), [5] a serial seen yet (1 / 0).")
(defvar *lhud-pts* (make-f32 16) "Polygon scratch.")
(defvar *lhud-tag* (vector nil nil nil nil nil nil) "Per side s at 3 s: the label and tag the parts were made from, and the parts (form . out).")

;;; ---------------------------------------------------------------- units
(defmacro lhud-units ((w h u st dpr phone) &body body)
  "Bind the frame's device-pixel sizes: W H the window, U the battle unit (min(1vw, 1.7778vh); portrait 2.36vw), ST the safe top,
DPR the pixel density, PHONE portrait (hud.js's hphone)."
  `(let* ((,w (i->f (window-width))) (,h (i->f (window-height))) (,phone (> ,h ,w))
          (,dpr (ffi:c-inline () () :float "pf_density()" :one-liner t))
          (,u (if ,phone (* 0.0236f0 ,w) (f-min (* 0.01f0 ,w) (* 0.017778f0 ,h))))
          (,st (* ,dpr (i->f *safe-top*))))
     (declare (single-float ,w ,h ,u ,st ,dpr) (ignorable ,w ,h ,u ,st ,dpr ,phone))
     ,@body))

(defmacro line-a (face size lh)
  "The baseline's depth in a line box: half-leading + ascent (CSS), SIZE px, line-height LH (a ratio)."
  `(let ((sz ,size) (asc (face-ascent ,face)) (dsc (face-descent ,face)))
     (declare (single-float sz asc dsc))
     (+ (* 0.5f0 sz (- ,lh (+ asc dsc))) (* asc sz))))

(defmacro tw (k from to t0 dur now)
  "A CSS transition's value: FROM -> TO along curve K over DUR s from T0 (before T0: FROM)."
  `(let ((%tu (/ (- ,now ,t0) ,dur))) (declare (single-float %tu))
     (if (<= %tu 0f0) ,from (if (>= %tu 1f0) ,to (+ ,from (* (- ,to ,from) (ease ,k %tu)))))))

;;; ---------------------------------------------------------------- the plate's tag
(defun lhud-tag-parts (side)
  "Side SIDE's tag as (form . out), upper case (hud.js tagHTML's general case; its kanji tags come in phase 2), remade only when the
label or the tag string changed (EQ)."
  (let* ((tg *lhud-tag*) (o (* 3 side)) (label (svref *hud-strs* (* 4 side))) (tag (svref *hud-strs* (1+ (* 4 side)))))
    (unless (and (eq label (svref tg o)) (eq tag (svref tg (1+ o))))
      (let* ((l (or label "")) (cut (search "  " l))
             (form (if cut (string-upcase (string-trim " " (subseq l cut))) ""))
             (out (if (member tag '("NOME" "UDE" "KAIHO" "" nil) :test #'equal) "" (string-upcase tag))))
        (setf (svref tg o) label (svref tg (1+ o)) tag (svref tg (+ o 2)) (cons form out))))
    (svref tg (+ o 2))))

;;; ---------------------------------------------------------------- the plate: name row and Reishi bar (hud.css .plate .who .reishi)
(defun-fast lhud-plate (side)
  "Side SIDE's plate (desktop; the phone's P2): the name, its kanji and tag on one baseline, the Reishi bar with its ghost and grid."
  (declare (fixnum side))
  (lhud-units (w h u st dpr phone)
    (let* ((now (aref *ui-clock* 0)) (o (+ 50 (* 30 side))) (sent *hud-sent*) (fv *lhud-f*) (fo (* 20 side)) (mir (= side 1))
           (entry (let ((k (1- (aref sent o)))) (declare (fixnum k)) (and (<= 0 k 7) (svref *lhud-names* k))))
           (deck (and phone *one-hand*))
           (pw (* u (cond ((not phone) 36f0) ((and deck mir) 27f0) (t 30f0))))
           (top (if phone (+ (* 3.8f0 u) st) (f-max (* 2.4f0 u) (+ st u))))
           (left (if mir (- w (* (if phone 2.2f0 2.6f0) u) pw) (* 2.6f0 u)))
           (nm (* 2.3f0 u)) (kz (* 1.25f0 u)) (tz (* 0.72f0 u))
           (an (line-a +f-display+ nm 0.9f0)) (ak (line-a +f-kanji+ kz 1f0)) (at (line-a +f-mono+ tz 1f0))
           (amax (f-max an (f-max ak at)))
           (rowh (+ amax (f-max (- (* 0.9f0 nm) an) (f-max (- kz ak) (- tz at)))))
           (base (+ top amax)) (parts (lhud-tag-parts side)) (form (car parts)) (out (cdr parts))
           (pen *paint-pen*) (wn 0f0) (wk 0f0) (wt 0f0) (wf 0f0) (wo 0f0) (wd 0f0))
      (declare (fixnum o fo) (type f32vec fv pen) (type (simple-array fixnum (*)) sent)
               (single-float now pw top left nm kz tz an ak at amax rowh base wn wk wt wf wo wd))
      (paint-reset)
      ;; the name row: measure, then place (P2 row-reverse: the name at the right end, the tag at the left)
      (when entry
        (paint-pen! 0f0 0f0 nm :spacing 0.06f0) (paint-measure (first entry) +f-display+) (setf wn (aref pen 7))
        (paint-pen! 0f0 0f0 kz :spacing 0.15f0) (paint-measure (second entry) +f-kanji+) (setf wk (aref pen 7)))
      (paint-pen! 0f0 0f0 tz :spacing 0.16f0)
      (paint-measure form +f-mono+) (setf wf (aref pen 7))
      (paint-measure out +f-mono+) (setf wo (aref pen 7))
      (when (and (plusp (length form)) (plusp (length out))) (paint-measure " · " +f-mono+) (setf wd (aref pen 7)))
      (setf wt (+ wf wd wo))
      (let* ((xn (if mir (- (+ left pw) wn) left)) (xk (if mir (- xn (* 0.9f0 u) wk) (+ xn wn (* 0.9f0 u))))
             (xt (if mir left (- (+ left pw) wt))) (by (f-floor+ base)))
        (declare (single-float xn xk xt by))
        (when entry
          (paint-pen! (f-floor+ xn) (+ by (* 2f0 dpr)) nm :spacing 0.06f0) (paint-text (first entry) +f-display+ +c-shade+)
          (paint-pen! (f-floor+ xn) by nm :spacing 0.06f0) (paint-text (first entry) +f-display+ +c-paper+)
          (paint-pen! (f-floor+ xk) by kz :spacing 0.15f0) (paint-text (second entry) +f-kanji+ +c-steel+))
        (paint-pen! (f-floor+ xt) by tz :spacing 0.16f0)
        (paint-text form +f-mono+ +c-stone+)
        (when (> wd 0f0) (paint-text " · " +f-mono+ +c-jade+))
        (paint-text out +f-mono+ +c-stone+))
      ;; the Reishi bar: polygon(0 18%, 3% 0, 100% 0, 98.6% 100%, 1.2% 100%, 0 78%), P2 mirrored
      (let* ((bx left) (by (+ top rowh (* 0.55f0 u))) (bw pw) (bh (* 1.55f0 u)) (pts *lhud-pts*)
             (r (* 0.001f0 (i->f (max 0 (aref sent (+ o 1)))))) (low (= 1 (aref sent (+ o 2))))
             (gv 0f0) (fx0 0f0) (fx1 0f0))
        (declare (single-float bx by bw bh r gv fx0 fx1) (type f32vec pts))
        (macrolet ((pt (i x y) `(setf (aref pts ,(* 2 i)) (+ bx (* bw (if mir (- 1f0 ,x) ,x))) (aref pts ,(1+ (* 2 i))) (+ by (* bh ,y)))))
          (pt 0 0f0 0.18f0) (pt 1 0.03f0 0f0) (pt 2 1f0 0f0) (pt 3 0.986f0 1f0) (pt 4 0.012f0 1f0) (pt 5 0f0 0.78f0))
        ;; the ghost: a drop drains after .38 s over .55 s (ease-cut); a refill snaps (hud.js: transition only on a drop)
        (let ((g0 (aref fv fo)) (g1 (aref fv (+ fo 1))) (gt (aref fv (+ fo 2))))
          (declare (single-float g0 g1 gt))
          (setf gv (tw 3 g0 g1 gt 0.55f0 now))
          (cond ((< r (aref fv (+ fo 3))) (setf (aref fv fo) gv (aref fv (+ fo 1)) r (aref fv (+ fo 2)) (+ now 0.38f0)))
                ((> r (aref fv (+ fo 3))) (setf (aref fv fo) r (aref fv (+ fo 1)) r gv r)))
          (setf (aref fv (+ fo 3)) r))
        (paint-clip! bx by (+ bx bw) (+ by bh)) (paint-poly pts 6 +c-bar-bg+ +c-bar-bg+)
        ;; the ghost only beyond the fill (antialiased edges stacked under the fill would show a blood fringe)
        (setf fx0 (if mir (+ bx (* bw (- 1f0 gv))) (+ bx (* bw r))) fx1 (if mir (+ bx (* bw (- 1f0 r))) (+ bx (* bw gv))))
        (when (> gv r) (paint-clip! fx0 by fx1 (+ by bh) 0f0 1f0 (if mir 1 4)) (paint-poly pts 6 +c-blood+ +c-blood+))
        (setf fx0 (if mir (+ bx (* bw (- 1f0 r))) bx) fx1 (if mir (+ bx bw) (+ bx (* bw r))))
        (when (> r 0f0)
          (let ((end (if mir 1 4)))                       ; the fill's moving end is antialiased, the band split is not (no seam)
            (declare (fixnum end))
            (if low
                (progn (paint-clip! fx0 by fx1 (+ by bh) by (+ by bh) end) (paint-poly pts 6 +c-low-hi+ +c-blood+))
                (let ((ym (+ by (* 0.45f0 bh))))         ; #fff 0 -> paper 45 % -> #c9cbcf 100 %
                  (declare (single-float ym))
                  (paint-clip! fx0 by fx1 ym by ym end) (paint-poly pts 6 +c-white+ +c-paper+)
                  (paint-clip! fx0 ym fx1 (+ by bh) ym (+ by bh) end) (paint-poly pts 6 +c-paper+ +c-fill-lo+))))
          ;; the grid: 1 px every 23 CSS px from 9 px, fixed to the bar (DEVLOG §618), only where the fill is: one striped polygon
          (paint-clip! fx0 by fx1 (+ by bh))
          (paint-stripes! (if mir (- (+ bx bw) (* 9f0 dpr)) (+ bx (* 9f0 dpr))) by (if mir -1f0 1f0) 0f0 (* 23f0 dpr) dpr)
          (paint-poly pts 6 +c-grid+ +c-grid+)
          (paint-pattern-off!))
        (paint-box! (+ bx (* 0.5f0 bw)) (+ by (* 0.5f0 bh)) (* 0.5f0 bw) (* 0.5f0 bh) 0f0 1f0 dpr +c-bar-line+)))
    nil))


;;; ---------------------------------------------------------------- the combo (hud.css .combo, hud.js renderPlate)
(defun-fast lhud-combo (side)
  "Side SIDE's combo under its plate: the count with the blood slash and shadow, HITS, the DMG / SCALE line; on for 1.2 s after a
new serial (opacity .25 s ease, x 2u .35 s ease-out), each hit restarting hd-stamp (.24 s ease-snap from scale 1.5 rotate -6deg)."
  (declare (fixnum side))
  (lhud-units (w h u st dpr phone)
    (let* ((now (aref *ui-clock* 0)) (o (+ 50 (* 30 side))) (sent *hud-sent*) (fv *lhud-f*) (fo (* 20 side)) (iv *lhud-i*)
           (io (* 6 side)) (mir (= side 1)) (ser (aref sent (+ o 13))) (practice (eq *mode* :practice)) (pen *paint-pen*))
      (declare (single-float now) (fixnum o fo io ser) (type f32vec fv pen) (type (simple-array fixnum (*)) sent iv))
      (macrolet ((go-to (on)                              ; start the opacity / x transitions from where they are
                   `(let ((op (tw 1 (aref fv (+ fo 4)) (aref fv (+ fo 5)) (aref fv (+ fo 6)) 0.25f0 now))
                          (tx (tw 2 (aref fv (+ fo 7)) (aref fv (+ fo 8)) (aref fv (+ fo 9)) 0.35f0 now)))
                      (declare (single-float op tx))
                      (setf (aref fv (+ fo 4)) op (aref fv (+ fo 5)) ,(if on 1f0 0f0) (aref fv (+ fo 6)) now
                            (aref fv (+ fo 7)) tx (aref fv (+ fo 8)) ,(if on 0f0 '(if mir 2f0 -2f0)) (aref fv (+ fo 9)) now
                            (aref iv (+ io 4)) ,(if on 1 0)))))
        (cond ((= 0 (aref iv (+ io 5)))                  ; the first serial seen is not shown (hud.js: p.cser undefined)
               (setf (aref iv io) ser (aref iv (+ io 4)) 0 (aref iv (+ io 5)) 1
                     (aref fv (+ fo 7)) (if mir 2f0 -2f0) (aref fv (+ fo 8)) (if mir 2f0 -2f0)))
              ((/= ser (aref iv io))
               (setf (aref iv io) ser)
               (when (> ser 0)
                 (setf (aref iv (+ io 1)) (aref sent (+ o 10)) (aref iv (+ io 2)) (aref sent (+ o 11))
                       (aref iv (+ io 3)) (round (aref sent (+ o 12)) 10)
                       (aref fv (+ fo 10)) now (aref fv (+ fo 11)) now)
                 (when (= 0 (aref iv (+ io 4))) (go-to t)))))
        (when (and (= 1 (aref iv (+ io 4))) (not practice) (> (- now (aref fv (+ fo 11))) 1.2f0)) (go-to nil)))
      (let* ((op (tw 1 (aref fv (+ fo 4)) (aref fv (+ fo 5)) (aref fv (+ fo 6)) 0.25f0 now))
             (txu (tw 2 (aref fv (+ fo 7)) (aref fv (+ fo 8)) (aref fv (+ fo 9)) 0.35f0 now)))
        (declare (single-float op txu))
        (when (> op 0.002f0)
          (let* ((hits (aref iv (+ io 1))) (dmg (aref iv (+ io 2))) (sc (aref iv (+ io 3)))
                 (ns (* 6.2f0 u)) (hs (* 1.5f0 u)) (ds (* 0.95f0 u))
                 (an (line-a +f-display+ ns 0.8f0)) (ah (line-a +f-display+ hs 1f0)) (ad (line-a +f-mono+ ds 1f0))
                 (amax (f-max an ah)) (crowh (+ amax (f-max (- (* 0.8f0 ns) an) (- hs ah))))
                 (wn 0f0) (wh 0f0) (wd 0f0) (right (- w (* 2.6f0 u)))
                 (ctop (cond ((not phone) (+ (* 16.4f0 u) st))
                             (mir (+ (* 20.5f0 u) st))
                             (*one-hand* (- h (* 0.37f0 h) (* 9.6f0 u) crowh (* 0.2f0 u) ds))
                             (t (- h (* 0.04f0 h) (* 19f0 u) crowh (* 0.2f0 u) ds)))))
            (declare (fixnum hits dmg sc) (single-float ns hs ds an ah ad amax crowh wn wh wd right ctop))
            (paint-pen! 0f0 0f0 ns) (paint-measure-int hits +f-display+) (setf wn (aref pen 7))
            (paint-pen! 0f0 0f0 hs :spacing 0.18f0) (paint-measure "HITS" +f-display+) (setf wh (aref pen 7))
            (paint-pen! 0f0 0f0 ds :spacing 0.1f0)
            (paint-measure "DMG " +f-mono+) (incf wd (aref pen 7)) (paint-measure-int dmg +f-mono+) (incf wd (aref pen 7))
            (paint-measure " · SCALE " +f-mono+) (incf wd (aref pen 7)) (paint-measure-int sc +f-mono+) (incf wd (aref pen 7))
            (paint-measure "%" +f-mono+) (incf wd (aref pen 7))
            (let* ((cw (+ wn (* 0.6f0 u) wh)) (cx (if mir (- right cw) (* 2.6f0 u))) (base (+ ctop amax))
                   (tx (* txu u)) (pts *lhud-pts*) (sbw (if mir cw (f-max cw wd)))   ; (P1's grid stretches the row to the DMG line)
                   (sx (- cx (* 0.06f0 sbw))) (sw (* 1.2f0 sbw)) (sy (+ ctop (* 0.44f0 crowh))) (sh (* 0.34f0 crowh))
                   (oy (+ sy (* 0.5f0 sh))) (k 0.4452f0))   ; skewX(-24deg) about the slash's left centre: x - tan 24 (y - oy)
              (declare (single-float cw cx base tx sbw sx sw sy sh oy k) (type f32vec pts))
              (paint-xform! 0f0 0f0 1f0 1f0 0f0 tx 0f0 op)
              (macrolet ((pt (i x y) `(let ((yy (+ sy (* sh ,y))))
                                        (declare (single-float yy))
                                        (setf (aref pts ,(* 2 i)) (- (+ sx (* sw ,x)) (* k (- yy oy))) (aref pts ,(1+ (* 2 i))) yy))))
                (pt 0 0f0 0.3f0) (pt 1 1f0 0f0) (pt 2 0.96f0 1f0) (pt 3 0.02f0 0.8f0))
              (paint-clip! -1f5 -1f5 1f5 1f5) (paint-poly pts 4 +c-slash+ +c-slash+)
              ;; the count: hd-stamp about its box's centre, then the container's shift
              (let* ((e (ease +ease-snap+ (/ (- now (aref fv (+ fo 10))) 0.24f0))) (s (+ 1.5f0 (* -0.5f0 e)))
                     (rot (* -0.10472f0 (- 1f0 e))) (bx (+ cx (* 0.5f0 wn))) (byc (+ (- base an) (* 0.4f0 ns))))
                (declare (single-float e s rot bx byc))
                (paint-xform! bx byc s s rot tx 0f0 op)
                (paint-pen! cx (+ base (* 0.25f0 u)) ns :skew 0.25f0) (setf (aref pen 0) (+ cx (* 0.25f0 u)))
                (paint-int hits +f-display+ +c-blood+)
                (paint-pen! cx base ns :skew 0.25f0) (paint-int hits +f-display+ +c-paper+))
              (paint-xform! 0f0 0f0 1f0 1f0 0f0 tx 0f0 op)
              (paint-pen! (f-floor+ (+ cx wn (* 0.6f0 u))) (f-floor+ base) hs :spacing 0.18f0 :edge 0.53f0)
              (paint-text "HITS" +f-display+ +c-paper+)
              (let ((dx (if mir (- right wd) cx)) (dy (+ ctop crowh (* 0.2f0 u) ad)))
                (declare (single-float dx dy))
                (paint-pen! (f-floor+ dx) (f-floor+ dy) ds :spacing 0.1f0)
                (paint-text "DMG " +f-mono+ +c-steel+) (paint-int dmg +f-mono+ +c-paper+)
                (paint-text " · SCALE " +f-mono+ +c-steel+) (paint-int sc +f-mono+ +c-paper+) (paint-text "%" +f-mono+ +c-paper+))
              (paint-reset)))))))
  nil)

;;; ---------------------------------------------------------------- the legibility card (debug 2518, phase 0's question)
(defparameter *lhud-card*
  ;; face, size (CSS px; < 0: -k = k / 100 u), string — the smallest sizes the HTML uses (DUEL_LISP_HUD §5 phase 0)
  (list (list +f-mono+ -62 (zh "ROUND · 決闘  0123456789"))                    ; the clock's caption, .62u
        (list +f-mono+ -72 "SHIKAI · BUNSHIN x3 · KAIHO L2")                   ; the plate's tag, .72u
        (list +f-mono+ 10 "PRESS J · CONFIRM   ESC · BACK   KEYS / PAD")      ; the menus' crumbs and hints, 10 px
        (list +f-sans+ 11 (zh "在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。"))   ; CONTROLS' phone page, 11 px
        (list +f-sans+ 12 (zh "鏡 鍵 鐮 觸 覺 鬥：最密的字，12 px 的說明文字。"))
        (list +f-sans+ -95 (zh "繼續 重來 放棄 換角色 回到標題 假人反擊"))         ; the pause rows' zh, .95u
        (list +f-kanji+ -95 (kj "鏡鍵鐮觸覺鬥 綴雷電 月牙天衝"))                ; the tag's kanji, .95u
        (list +f-kanji+ -125 (kj "更木 黒崎 檜佐木 鏡鍵鐮觸覺鬥"))))           ; the plates' kanji, 1.25u

(defun lhud-card-size (sz u dpr) (if (< sz 0) (* u (/ (- sz) 100f0)) (* dpr sz)))

(defun lhud-card ()
  "Debug 2518's card: each row of *LHUD-CARD* on an ink panel at 24 CSS px from the left, from 30 % of the height, a row every
1.9 em (line-height 1). tests: the same rows in HTML (build/lhud/ref, DUEL_LISP_HUD §8)."
  (lhud-units (w h u st dpr phone)
    (let* ((x (* 24f0 dpr)) (y (* 0.3f0 h)) (y0 y))
      (paint-reset)
      (paint-rect (* 12f0 dpr) (- y0 (* 12f0 dpr)) (- w (* 24f0 dpr)) (* 0.42f0 h) +c-card+)
      (dolist (row *lhud-card*)
        (destructuring-bind (face sz s) row
          (let ((size (f32 (lhud-card-size sz u dpr))))
            (paint-pen! (f32 (round x)) (f32 (round (+ y (line-a face size 1f0)))) size)
            (paint-text s face +c-paper+)
            (setf y (+ y (* 1.9 size)))))))))

;;; ---------------------------------------------------------------- the card's phase 1c rows (debug 2518): layout, text, tween, hot boxes
;;; Beside the card's rows on a desktop, under them in portrait: a wrapped zh paragraph (kinsoku), the handheld screen's pointer seals
;;; (hud.js FIGHTERS: Kenpachi's 「拖 · DRAG」 「肩 · SHOULDER」 「構 · CHUDAN」, a Mincho kanji and a letter-spaced mono word on one
;;; baseline, end-aligned), a vertical column (CJK upright, Latin turned), a tabular clock that pops (hd-stamp restarted by its value)
;;; and hover boxes (the mouse). 0 B a frame (debug 2519's "demo").
(defparameter *lhud-demo-para* (zh "在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。"))
(defparameter *lhud-demo-v* (kj "月牙天衝"))
(defparameter *lhud-demo-seals* (list (cons (kj "拖") " · DRAG") (cons (kj "肩") " · SHOULDER") (cons (kj "構") " · CHUDAN"))
  "The handheld screen's pointer seals of Kenpachi's sealed form (hud.js FIGHTERS ptr): (kanji . the rest).")
(defparameter *lhud-stamp* (make-tween '((0 nil 1.5 -6) (1 nil 1 0)) :dur 0.24 :curve +ease-snap+ :base '(1 0))
  "hd-stamp (hud.css): .24 s ease-snap from scale 1.5, rotate -6deg.")
(defvar *lhud-demo-st* (make-tween-slots 1)) (defvar *lhud-demo-se* (nth-value 1 (make-tween-slots 1)))
(declaim (type f32vec *lhud-demo-st*) (type (simple-array fixnum (*)) *lhud-demo-se*))

(defun-fast lhud-card-demo ()
  "The card's phase 1c rows (see above), placed with layout.lisp from the frame LHUD-FRAME set."
  (let* ((now (aref *ui-clock* 0)) (pen *paint-pen*) (dpr (lay-dpr)) (u (lay-u 1f0))
         (x (if (lay-portrait-p) (lay-css 24f0) (* 0.52f0 (lay-w))))
         (y (if (lay-portrait-p) (+ (* 0.3f0 (lay-h)) (* 16.5f0 u)) (* 0.3f0 (lay-h))))   ; (portrait: under the card's rows)
         (pw (if (lay-portrait-p) (lay-css 150f0) (lay-css 168f0)))   ; the paragraph's width
         (hov (hot-hit (mouse-x) (mouse-y))) (sec (fl-floor now)))
    (declare (single-float now dpr u x y pw) (fixnum hov sec))
    (paint-reset)
    (macrolet ((hot (id x0 y0 x1 y1)                      ; register a hot box; the hovered one gets a stone frame
                 `(let* ((%x0 ,x0) (%y0 ,y0) (%x1 ,x1) (%y1 ,y1)
                         (%cx (* 0.5f0 (+ %x0 %x1))) (%cy (* 0.5f0 (+ %y0 %y1))) (%hw (* 0.5f0 (- %x1 %x0))) (%hh (* 0.5f0 (- %y1 %y0))))
                    (declare (single-float %x0 %y0 %x1 %y1 %cx %cy %hw %hh))
                    (hot-add ,id %x0 %y0 %x1 %y1)
                    (when (= hov ,id) (paint-box! %cx %cy %hw %hh dpr 1f0 dpr +c-stone+)))))
      ;; 1. a wrapped paragraph, 11 CSS px, line-height 1.6
      (paint-pen! (f-floor+ x) (f-floor+ y) (lay-css 11f0))
      (paint-paragraph *lhud-demo-para* +f-sans+ +c-paper+ :width pw :lh 1.6f0)
      (hot 1 x y (+ x pw) (+ y (aref pen 7)))
      (setf y (+ y (aref pen 7) (lay-css 10f0)))
      ;; 2. the handheld seals: kanji .78u + " · " + the mono word .78u, .16em spaced, end-aligned at the paragraph's right edge,
      ;;    a row every 1.3 em; ATK (display, 1.6u, .3em spaced) on the first row's baseline at the left
      (let* ((kz (* 0.78f0 u)) (mz (* 0.78f0 u)) (right (+ x pw)) (y1 y))
        (declare (single-float kz mz right y1))
        (dolist (lab *lhud-demo-seals*)
          (let ((base (f-floor+ (+ y1 (line-baseline +f-kanji+ kz 1f0)))) (w 0f0))
            (declare (single-float base w))
            (paint-pen! 0f0 0f0 mz :spacing 0.16f0) (paint-measure (cdr lab) +f-mono+) (setf w (aref pen 7))
            (paint-pen! (f-floor+ (- right w)) base kz) (paint-text-aligned (car lab) +f-kanji+ +c-paper+ :end)
            (paint-pen! (f-floor+ (- right w)) base mz :spacing 0.16f0) (paint-text (cdr lab) +f-mono+ +c-stone+)
            (setf y1 (+ y1 (* 1.3f0 kz)))))
        (paint-pen! (f-floor+ x) (f-floor+ (+ y (line-baseline +f-kanji+ kz 1f0))) (* 1.6f0 u) :spacing 0.3f0)
        (paint-text "ATK" +f-display+ +c-steel+)
        (hot 2 x y right (f-max y1 (+ y (* 1.6f0 u))))
        (setf y (+ (f-max y1 (+ y (* 1.6f0 u))) (* 0.6f0 u))))
      ;; 3. the clock: tabular digits, 4.3u display, popping (hd-stamp) at each new second; PAUSE spaced .3em beside
      (let* ((cz (* 4.3f0 u)) (base (f-floor+ (+ y (line-baseline +f-display+ cz 1f0)))))
        (declare (single-float cz base))
        (tween-watch *lhud-demo-st* *lhud-demo-se* 0 sec now)
        (paint-pen! 0f0 0f0 cz) (paint-measure-int-tab 99 +f-display+ 2)
        (let* ((cw (aref pen 7)) (st (aref *lhud-demo-st* 0)) (sc (tween-value *lhud-stamp* st now 0))
               (rot (* 0.017453f0 (tween-value *lhud-stamp* st now 1))))
          (declare (single-float cw st sc rot))
          (paint-xform! (+ x (* 0.5f0 cw)) (- base (* 0.35f0 cz)) sc sc rot 0f0 0f0)
          (paint-pen! x base cz) (paint-int-tab (mod sec 100) +f-display+ +c-paper+ 2)
          (paint-reset)
          (paint-pen! (f-floor+ (+ x cw (* 0.8f0 u))) base (* 0.95f0 u) :spacing 0.3f0) (paint-text "PAUSE" +f-mono+ +c-steel+)
          (hot 3 x y (+ x cw) (+ y cz)))
        (setf y (+ y (* 5f0 u))))
      ;; 4. a vertical column at the right: 月牙天衝 upright, then K.O. turned (writing-mode: vertical-rl), 2.4u
      (let* ((vz (* 2.4f0 u)) (vx (+ x pw (if (lay-portrait-p) (lay-css 40f0) (lay-css 60f0)))) (vy (if (lay-portrait-p) (- y (* 9.2f0 u)) (* 0.3f0 (lay-h)))))
        (declare (single-float vz vx vy))
        (paint-pen! vx vy vz :spacing 0.08f0) (paint-vertical *lhud-demo-v* +f-kanji+ +c-paper+)
        (paint-pen! vx (+ (aref pen 1) (* 0.4f0 vz)) (* 0.6f0 vz) :spacing 0.3f0) (paint-vertical "K.O." +f-mono+ +c-blood+)
        (hot 4 (- vx (* 0.5f0 vz)) vy (+ vx (* 0.5f0 vz)) (aref pen 1))))
    nil))

(defvar *lhud-win* (make-array 4 :element-type 'fixnum :initial-element -1)
  "The window LHUD-FRAME last asked the page about (width, height) and its answers: the left / right safe-area insets (CSS px).")
(declaim (type (simple-array fixnum (*)) *lhud-win*))
(defun-fast lhud-frame ()
  "This frame's layout (layout.lisp): the window, the density, the four safe-area insets (top / bottom as DECK-UPDATE keeps them, left /
right page get 5 / 6) and reduced motion (page get 7, DUEL_LISP_HUD §4.4), the page asked again only when the window's size changed;
the hot boxes start over. Under :LISP only (LHUD-DRAW)."
  (let ((k *lhud-win*) (w (window-width)) (h (window-height)))
    (declare (fixnum w h))
    (unless (and (= w (aref k 0)) (= h (aref k 1)))
      (setf (aref k 0) w (aref k 1) h (aref k 2) (page-get 5) (aref k 3) (page-get 6) *reduced-motion* (= 1 (page-get 7))))
    (layout-frame! (i->f w) (i->f h) (ffi:c-inline () () :float "pf_density()" :one-liner t)
                   (i->f *safe-top*) (i->f *safe-bot*) (i->f (aref k 2)) (i->f (aref k 3))))
  (hot-begin-frame)
  nil)

;;; ---------------------------------------------------------------- every frame
(defun lhud-draw ()
  "The Lisp HUD of this frame (HUD-DRAW, *HUD-RENDERER* :LISP, after it advanced the UI clock): the plates and combos while a battle
is up and no cinematic covers it (hud.css .hudl)."
  (let ((v0 (aref *hud-sent* 0)) (phone (> (window-height) (window-width))))
    (declare (fixnum v0))
    (lhud-frame)
    (when (and (logtest v0 1) (not (logtest v0 2)))
      (unless phone (lhud-plate 0))                      ; (the phone's P1 plate lies on the deck's line: phase 4)
      (lhud-plate 1)
      (lhud-combo 0) (lhud-combo 1))
    (when *lhud-still* (lhud-card) (lhud-card-demo))
    nil))

(defun lhud-init ()
  "The baked atlas (duel/hud-font, tools/sdf-bake.py): its metrics into the glyph table, its texels to the GPU (a :LOAD step)."
  (let ((n (ffi:c-inline () () :int "{ int n; lhud_font(1, &n); @(return) = n; }")))
    (when (plusp n)
      (let ((m (make-array n :element-type '(unsigned-byte 8))))
        (ffi:c-inline (m n) (t :int) :void "{ int k; memcpy(#0->vector.self.b8, lhud_font(1, &k), #1); }")
        (multiple-value-bind (aw ah) (paint-font-init m)
          (unless (ffi:c-inline (aw ah) (:int :int) :bool "{ int k; @(return) = r_hud_atlas_new(lhud_font(0, &k), #0, #1); }")
            (log-msg "lhud: the atlas texture failed")))))))
(ffi:clines "const unsigned char *lhud_font(int k, int *n);   /* duel/hud-font/lhud-font.c: 0 the atlas, 1 the metrics */")
