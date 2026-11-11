;;;; lhud-menu-geom.lisp — the Lisp menus' pure layout (docs/duel/DUEL_LISP_HUD.md §15): menu.css's grids worked out by hand for each
;;;; screen and form, in CSS px, from the window's size and safe-area insets (CSS px) and the few measured inputs a CSS layout takes
;;;; from its content (a paragraph's line count, a row's text width). Each function writes its boxes into an f32vec (a calling
;;;; convention for the 0 B rule: the views multiply by the density). Plain CL, no C inlines: tests/duel-rules/lhud-menu.lisp checks
;;;; the boxes against Chrome's getBoundingClientRect of the HTML menus at 1280 x 720 and 390 x 844 (build/lhud/p56/dom.py).
;;;; Every .screen is inset by the gutters max(16px, safe left / right) and padding-block safe-top + 64 / safe-bottom + 60 (the narrow
;;;; media query's 52 / 52 loses to #ui .screen's specificity: the HTML keeps 64 / 60 there too).
(in-package :duel)

(defmacro fmx (a b) "max of two single-floats, inline (CL MAX of floats is a generic call that boxes; F-MAX is C: not on the host)."
  `(let* ((%a ,a) (%b ,b)) (declare (single-float %a %b)) (if (> %a %b) %a %b)))
(defmacro fmn (a b) "min of two single-floats, inline." `(let* ((%a ,a) (%b ,b)) (declare (single-float %a %b)) (if (< %a %b) %a %b)))
(defconstant +lm-narrow+ 760f0 "menu.css @media (max-width: 760px): the narrow (phone) form.")
(defmacro lm-narrow-p (cw) `(<= ,cw +lm-narrow+))

(defun-fast-inline lm-content! (out cw ch sl sr st sb)
  "The .screen's content box in CSS px for a window CW x CH and insets SL SR ST SB: OUT [0] x0 [1] y0 [2] x1 [3] y1."
  (declare (type f32vec out) (single-float cw ch sl sr st sb))
  (setf (aref out 0) (if (> sl 16f0) sl 16f0) (aref out 1) (+ st 64f0)
        (aref out 2) (- cw (if (> sr 16f0) sr 16f0)) (aref out 3) (- ch sb 60f0))
  out)

;;; ---------------------------------------------------------------- the fit
(defun-fast-inline lm-fit-k (need ch st sb)
  "The zoom (at most 1) that fits a screen whose stack is NEED CSS px tall (its geometry's [31]; 0 = not measured: 1) into a window CH
CSS px tall with the safe-area insets ST SB: the content box's paddings (64 + 60) shrink with it. The HTML scrolled a screen taller
than the window (SETTINGS below about 750 px, a landscape phone); a phone has no keys to scroll by focus, so the Lisp menus shrink the
whole screen instead (DUEL_LISP_HUD §16)."
  (declare (single-float need ch st sb))
  (if (> need 0f0) (fmn 1f0 (/ (- ch st sb) (+ need 124f0))) 1f0))

;;; ---------------------------------------------------------------- TITLE
(defun-fast-inline lm-title-geom! (out cw ch)
  "TITLE (menu.css #s-title, .wordmark, .t-kanji) in CSS px from the content box OUT [0..3]: [4] the wordmark's font size, [5] its top,
[6] the big kanji's size, [7] its left, [8] its top, [9] the vertical line's centre x (narrow: -1, hidden), [10] its top, [11] the
t-sub's top, [12] the press's top. The wordmark sits at the left, bottom-aligned with the t-sub and PRESS under it (gap 26,
padding-bottom 2vh); the kanji column on the right is centred (big 46vh / .9, gap 2vh, the line 9 x 20.8); narrow: the kanji
absolute at the right gutter and 8vh, the line hidden."
  (declare (type f32vec out) (single-float cw ch))
  (let* ((narrow (lm-narrow-p cw)) (wf (if narrow (* 0.31f0 cw) (fmx 84f0 (fmn (* 0.17f0 cw) 268f0))))
         (wh (+ (* 2f0 0.76f0 wf) (* 0.26f0 wf) (* 0.3f0 0.26f0 wf)))
         (kz (if narrow (* 0.46f0 ch) (fmx 180f0 (fmn (* 0.46f0 ch) 520f0))))
         (bottom (- (aref out 3) (* 0.02f0 ch))) (press (- bottom 54f0)) (sub (- press 26f0 20.8f0)) (top (- sub 26f0 wh)))
    (declare (single-float wf wh kz bottom press sub top))
    (setf (aref out 4) wf (aref out 5) top (aref out 6) kz (aref out 11) sub (aref out 12) press)
    (if narrow
        (setf (aref out 7) (- (aref out 2) kz) (aref out 8) (* 0.08f0 ch) (aref out 9) -1f0 (aref out 10) 0f0)
        (let* ((col (+ (* 0.9f0 kz) (* 0.02f0 ch) 187.2f0)) (y (+ (aref out 1) (* 0.5f0 (- (- (aref out 3) (aref out 1)) col)))))
          (declare (single-float col y))
          (setf (aref out 7) (- (aref out 2) kz) (aref out 8) y (aref out 9) (- (aref out 2) (* 0.5f0 kz))
                (aref out 10) (+ y (* 0.9f0 kz) (* 0.02f0 ch)))))
    out))

;;; ---------------------------------------------------------------- MODE
(defun-fast-inline lm-mode-geom! (out cw ch lines tagrows)
  "MODE (menu.css #s-mode, .m-hero, .m-desc, .list .row) in CSS px from the content box OUT [0..3]; LINES the description's line
count, TAGROWS the tags' rows: [4] the kanji's size, [5] its left, [6] its top, [7] the card's left, [8] its top, [9] its width,
[10] its height, [11] the list's left, [12] its top, [13] its width, [14] a row's height, [15] the row font (.en), [16] the
paragraph's size, [17] its line height (px), [18] the heading shown (1 / 0), [31] the stack's height (LM-FIT-K). Desktop: two columns 1.05fr 1fr, gap 4vw, centred;
narrow: one column, the hero over the list, bottom-aligned, gap 18."
  (declare (type f32vec out) (single-float cw ch) (fixnum lines tagrows))
  (let* ((narrow (lm-narrow-p cw)) (x0 (aref out 0)) (y0 (aref out 1)) (x1 (aref out 2)) (y1 (aref out 3))
         (en (if narrow 32f0 (fmx 30f0 (fmn (* 0.044f0 cw) 54f0)))) (rowh (+ (* 0.92f0 en) (if narrow 18f0 24f0)))
         (listh (+ (* 7f0 rowh) 12f0)) (kz (if narrow 76f0 (fmx 96f0 (fmn (* 0.22f0 ch) 230f0)))) (kh (* 2f0 0.96f0 kz))
         (pz (if narrow 13f0 15f0)) (plh (* pz (if narrow 1.65f0 1.75f0)))
         (cardh (+ 22f0 10f0 (if narrow 0f0 60f0) (* (i->f* lines) plh) 16f0 (* 24f0 (i->f* tagrows)) (* 8f0 (i->f* (max 0 (1- tagrows)))) 24f0))
         (heroh (fmx kh cardh)))
    (declare (single-float x0 y0 x1 y1 en rowh listh kz kh pz plh cardh heroh))
    (setf (aref out 4) kz (aref out 14) rowh (aref out 15) en (aref out 16) pz (aref out 17) plh (aref out 18) (if narrow 0f0 1f0)
          (aref out 10) cardh (aref out 31) (if narrow (+ listh 18f0 heroh) (fmx listh heroh)))
    (if narrow
        (let* ((htop (fmx y0 (- y1 listh 18f0 heroh))) (ltop (+ htop heroh 18f0)))   ; (align-content: safe end)
          (declare (single-float ltop htop))
          (setf (aref out 5) x0 (aref out 6) (+ htop (* 0.5f0 (- heroh kh))) (aref out 7) (+ x0 kz 14f0) (aref out 8) (+ htop (* 0.5f0 (- heroh cardh)))
                (aref out 9) (- x1 (+ x0 kz 14f0)) (aref out 11) x0 (aref out 12) ltop (aref out 13) (- x1 x0)))
        (let* ((gap (* 0.04f0 cw)) (free (- x1 x0 gap)) (c1 (* free (/ 1.05f0 2.05f0))) (c2 (- free c1))
               (htop (+ y0 (* 0.5f0 (- (- y1 y0) heroh)))) (cx (+ x0 kz (* 0.03f0 cw))))
          (declare (single-float gap free c1 c2 htop cx))
          (setf (aref out 5) x0 (aref out 6) (+ htop (* 0.5f0 (- heroh kh))) (aref out 7) cx (aref out 8) (+ htop (* 0.5f0 (- heroh cardh)))
                (aref out 9) (fmn 349.9f0 (- (+ x0 c1) cx)) (aref out 11) (+ x0 c1 gap)
                (aref out 12) (+ y0 (fmx 0f0 (* 0.5f0 (- (- y1 y0) listh)))) (aref out 13) c2)))
    out))

;;; ---------------------------------------------------------------- SETTINGS
(defconstant +lm-set-rows+ 9 "SETTINGS' rows: the seven settings, RESET LEARNING, BACK.")
(defun-fast-inline lm-set-row-h (i narrow helpk)
  "Row I's height (CSS px) of menu.css .set: padding-block 2 x 14 (narrow 2 x 9; desktop at most 820 tall: 2 x 10: the compaction made
for the HUD row, 2026-11-11, kept after the row left as room on short windows), the label 22 (narrow 19) or the choices (31; drops 28), the help line's row (gap 6 + 12px x
1.6 x HELPK, its max-height tween) where there is one, the 1 px rule."
  (declare (fixnum i) (single-float narrow helpk))
  (let* ((pad (if (>= narrow 1f0) 18f0 (if (> narrow 0f0) 20f0 28f0))) (drops (or (= i 2) (= i 6))) (setting (< i 7))
         (main (if setting (if drops 28f0 31f0) (if (>= narrow 1f0) 19f0 22f0))))
    (declare (single-float pad main))
    (+ pad main 1f0 (if (< i 8) (+ 6f0 (* 19.2f0 helpk)) 0f0))))
(defun-fast-inline lm-set-geom! (out cw ch helps)
  "SETTINGS (menu.css #s-settings, .side-title, .setlist .set) in CSS px from the content box OUT [0..3]; HELPS an f32vec of each
row's help tween (0..1): [4] the list's left, [5] its width, [6] the first row's top, [7] the side title's left, [8] its top (the
kanji's line box), [9] the h1's font size, [10] the paragraph's width (narrow: 0, hidden), [11] the compaction (0 none, .5
desktop, 1 narrow), then [16 + i] each row's top, [31] the stack's height (LM-FIT-K). Desktop: 1fr 1.25fr, gap 5vw, both centred (a list taller than the content starts
at its top); narrow: one column, the title over the list, bottom-aligned, gap 18."
  (declare (type f32vec out helps) (single-float cw ch))
  (let* ((narrow (lm-narrow-p cw)) (x0 (aref out 0)) (y0 (aref out 1)) (x1 (aref out 2)) (y1 (aref out 3))
         (cmp (if narrow 1f0 (if (<= ch 820f0) 0.5f0 0f0))) (gap (if (> cmp 0f0) 2f0 4f0)) (listh 0f0)
         (h1 (if narrow 64f0 (fmx 56f0 (fmn (* 0.09f0 cw) 140f0)))) (kz (if narrow 28f0 (fmx 28f0 (fmn (* 0.04f0 cw) 52f0))))
         (titleh (+ kz 18f0 (* 0.8f0 h1) (if narrow 0f0 (+ 18f0 73.5f0)))))
    (declare (single-float x0 y0 x1 y1 cmp gap listh h1 kz titleh))
    (dotimes (i +lm-set-rows+) (incf listh (+ (lm-set-row-h i cmp (aref helps i)) (if (< i (1- +lm-set-rows+)) gap 0f0))))
    (setf (aref out 9) h1 (aref out 11) cmp (aref out 31) (if narrow (+ listh 18f0 titleh) (fmx listh titleh)))
    (let* ((top 0f0))
      (declare (single-float top))
      (if narrow
          (let* ((ttop (fmx y0 (- y1 listh 18f0 titleh))))   ; (align-content: safe end: from the top when it overflows)
            (declare (single-float ttop))
            (setf top (+ ttop titleh 18f0) (aref out 4) x0 (aref out 5) (- x1 x0) (aref out 7) x0 (aref out 8) ttop (aref out 10) 0f0))
          (let* ((g (* 0.05f0 cw)) (free (- x1 x0 g)) (c1 (/ free 2.25f0)))
            (declare (single-float g free c1))
            (setf top (+ y0 (fmx 0f0 (* 0.5f0 (- (- y1 y0) listh))))
                  (aref out 4) (+ x0 c1 g) (aref out 5) (- free c1) (aref out 7) x0
                  (aref out 8) (+ y0 (* 0.5f0 (- (fmx (- y1 y0) listh) titleh))) (aref out 10) (fmn 279.7f0 c1))))
      (setf (aref out 6) top)
      (dotimes (i +lm-set-rows+)
        (setf (aref out (+ 16 i)) top top (+ top (lm-set-row-h i cmp (aref helps i)) gap))))
    out))

;;; ---------------------------------------------------------------- CONTROLS
(defun-fast-inline lm-ctl-geom! (out cw ch phone)
  "CONTROLS (menu.css #s-controls: the side title as SETTINGS', .ctl-body) in CSS px from the content box OUT [0..3]: [4] the body's
left, [5] its width, [6] its top, [7] the title's left, [8] its top, [9] the h1's size, [10] the paragraph's width (narrow 0), [11]
the keyboard map's scale (its 640 x 196 viewBox at the body's width, at most 1), [31] the stack's height (LM-FIT-K). Desktop body: tabs 38 + 14, the map 196 x scale,
14, the combos 22, 14, the bindings 5 x 52.4 + 4 x 2; PHONE: the 560 x 330 card at the body's width (at most 560)."
  (declare (type f32vec out) (single-float cw ch) (fixnum phone))
  (let* ((narrow (lm-narrow-p cw)) (x0 (aref out 0)) (y0 (aref out 1)) (x1 (aref out 2)) (y1 (aref out 3))
         (h1 (if narrow 52f0 (fmx 56f0 (fmn (* 0.09f0 cw) 140f0)))) (kz (if narrow 28f0 (fmx 28f0 (fmn (* 0.04f0 cw) 52f0))))
         (bx 0f0) (bw 0f0) (bh 0f0) (sc 1f0))
    (declare (single-float x0 y0 x1 y1 h1 kz bx bw bh sc))
    (if narrow
        (setf bx x0 bw (- x1 x0))
        (let* ((g (* 0.05f0 cw)) (free (- x1 x0 g)) (c1 (/ free 2.25f0))) (declare (single-float g free c1))
          (setf bx (+ x0 c1 g) bw (- free c1) (aref out 10) (fmn 279.7f0 c1))))
    (setf sc (fmn 1f0 (/ bw (if (= phone 1) 560f0 640f0))))
    (setf bh (if (= phone 1) (* 330f0 sc) (+ 38f0 14f0 (* 196f0 sc) 22f0 14f0 (* 5f0 52.4f0) 8f0)))
    (setf (aref out 4) bx (aref out 5) bw (aref out 9) h1 (aref out 11) sc)
    (let* ((titleh (+ kz 18f0 (* 0.8f0 h1) (if narrow 0f0 (+ 18f0 98f0)))))
      (declare (single-float titleh))
      (setf (aref out 31) (if narrow (+ bh 18f0 titleh) (fmx bh titleh)))
      (if narrow
          (let* ((ttop (fmx y0 (- y1 bh 18f0 titleh)))) (declare (single-float ttop))
            (setf (aref out 6) (+ ttop titleh 18f0) (aref out 7) x0 (aref out 8) ttop (aref out 10) 0f0))
          (setf (aref out 6) (+ y0 (fmx 0f0 (* 0.5f0 (- (- y1 y0) bh)))) (aref out 7) x0
                (aref out 8) (+ y0 (* 0.5f0 (- (fmx (- y1 y0) bh) titleh))))))
    out))

;;; ---------------------------------------------------------------- SELECT
(defun-fast-inline lm-select-geom! (out cw ch weights last)
  "SELECT (menu.css #s-select: rows auto 1fr auto, gap 18; .sel-head, .fighters, .sel-foot) in CSS px from the content box OUT [0..3];
WEIGHTS the three cards' flex-grow (tweened, 1 -> 2.6, narrow 4), LAST the last page shown (the foot's rows): [4] the head's top,
[5] the cards' top, [6] the cards' bottom, [7] the foot's top, [8 + 2k] card k's left / top and [14 + 2k] its width / height (desktop
side by side, gap 10; narrow stacked), [20] the head's height."
  (declare (type f32vec out weights) (single-float cw ch) (fixnum last))
  (let* ((narrow (lm-narrow-p cw)) (x0 (aref out 0)) (y0 (aref out 1)) (x1 (aref out 2)) (y1 (aref out 3))
         (headh (if narrow 114f0 (+ 10f0 10f0 (* 0.9f0 (fmx 30f0 (fmn (* 0.04f0 cw) 48f0))))))
         (footh (if (= last 1) (if narrow (+ 38f0 16f0 54f0) 54f0) 44f0))   ; (.sel-foot min-height 44; narrow, the rows wrap)
         (top (+ y0 headh 18f0)) (bot (- y1 footh 18f0))
         (sum (+ (aref weights 0) (aref weights 1) (aref weights 2))))
    (declare (single-float x0 y0 x1 y1 headh footh top bot sum))
    (setf (aref out 4) y0 (aref out 5) top (aref out 6) bot (aref out 7) (+ bot 18f0) (aref out 20) headh)
    (if narrow
        (let* ((free (- bot top 20f0)) (y top))
          (declare (single-float free y))
          (dotimes (k 3)
            (let* ((hk (* free (/ (aref weights k) sum))))
              (declare (single-float hk))
              (setf (aref out (+ 8 (* 2 k))) x0 (aref out (+ 9 (* 2 k))) y (aref out (+ 14 (* 2 k))) (- x1 x0) (aref out (+ 15 (* 2 k))) hk
                    y (+ y hk 10f0)))))
        (let* ((free (- x1 x0 20f0)) (x x0))
          (declare (single-float free x))
          (dotimes (k 3)
            (let* ((wk (* free (/ (aref weights k) sum))))
              (declare (single-float wk))
              (setf (aref out (+ 8 (* 2 k))) x (aref out (+ 9 (* 2 k))) top (aref out (+ 14 (* 2 k))) wk (aref out (+ 15 (* 2 k))) (- bot top)
                    x (+ x wk 10f0))))))
    out))
