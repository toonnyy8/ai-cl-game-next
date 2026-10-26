;;;; hud.lisp — the battle HUD (design-v1 §10; the flow's screens: title, mode, controls, select, results, pause,
;;;; are hud-screens.lisp). Per side, P2 mirrored: Reishi bar (red + pulsing below *RED-THRESHOLD*,
;;;; white damage trail), the guard gauge under it (steel, a white drain trail, 30 % darker while he guards below full
;;;; (GUARD HOLD: no refill; Bankai West's ward always); Bankai's is ember (East's pierce reads it); guardless: grey with
;;;; a red fill climbing back), *KONPAKU-MAX* Konpaku soul flames that shatter, Reiatsu 3 bars, the flash-step bar
;;;; (ticks at a Hoho's cost and the burst threshold; the part past it glows in the mode's colour while a burst is possible,
;;;; the fill is the running burst's colour as it drains), Awakening bar (EVOLUTION
;;;; blinks; drains in a timed awakening; WARD while Bankai West's ward is up), the kit meter
;;;; (Inferno; drains in Hellfire) or, for an awakened form whose L has a cooldown, the L cooldown bar (one cell; a thin
;;;; ember line under it while a Shift+L with a cooldown cools; a refused press flashes its bar), the timer, the
;;;; combo counter under the victim's bar, move-name callouts over the user, the HOLD O KIKON prompt, the red
;;;; soul flame over a Kikon-able victim, and the big words (ANNOUNCE). Cosmetic only: the fx clock (it stops
;;;; while paused, so the HUD's pulses and fades hold too), RND01.
;;;; Screen lanes (top to bottom): side panels + timer (0 .. ~0.22 h), small words (0.3 h), big words
;;;; (0.45 h), captions (0.8 h). Callouts float over the user's head and step out of a word's box.
;;;; Consing: the battle HUD runs every frame, so its strings are cached (timer, labels, combo), its
;;;; quads are written by DEFUN-FAST helpers with WITH-UI-VERTS (0 bytes), its text is drawn with
;;;; HUD-TEXT (block text, 16 B a call however long since refactor round 3, was ~200 B) and UI-BIG-TEXT, and colours are quoted lists (ELT on a literal
;;;; list conses nothing) or preallocated lists whose alpha is set in place. Since 2026-10-26 the panels themselves
;;;; (HUD-SIDE, HUD-SIDE-PORTRAIT) are DEFUN-FASTs on unboxed floats, the meters DEFUN-FAST-INLINEs expanded into them,
;;;; their labels %HUD-TEXT (a side cost ~1.2 KB landscape, ~2 KB portrait; what is left is mostly the callees: AT-STAKE,
;;;; a kit meter's :draw).
(in-package :duel)

(defparameter *white* '(1 1 1 1))
(defparameter *dim* '(0.72 0.7 0.78 1))
(defparameter *dim-ink* '(0.14 0.15 0.19 1) "Select screen: the unselected entries, dark ink on the mid-grey plaza (*DIM* vanished there).")
(defparameter *ember* '(1 0.55 0.2 1))
(defparameter *shade* '(0 0 0 0.75) "HUD-TEXT's drop shadow.")

(defmacro hud-dt () "This frame's HUD seconds: 0 while the effects are frozen (paused: nothing moves under the pause menu)." `(if (fx-frozen-p) 0.0 (frame-dt)))

(defun hud-pulse (hz)
  "0..1, HZ times a second (real time)."
  (+ 0.5 (* 0.5 (sin (* 6.2831855 (f32 hz) (the single-float (fx-clock)))))))

(defun alpha! (color a)
  "COLOR (a preallocated, mutable 4-list) with its alpha set to A: a pulsing colour without a
fresh list every frame."
  (setf (fourth color) a)
  color)

(defun hud-text (str x y scale color &key (align :left) (shadow *shade*))
  "UI-TEXT's look (the 5x7 font at integer SCALE, top edge Y, ALIGN relative to X) drawn as block
text on whole pixels: 16 B a call whatever the length (two UI-BLOCK-TEXT calls, 8 B each: the returned width; ~200 B before refactor round 3, 2026-10-21). SHADOW: colour or NIL. (The engine's
UI-TEXT no longer conses per glyph either; the HUD keeps its block look.)"
  (let* ((s (max 1 (round scale)))
         (x0 (round (ecase align (:left x) (:center (- x (/ (text-width str s) 2))) (:right (- x (text-width str s))))))
         (y0 (round y)))
    (when shadow (ui-block-text str (+ x0 s) (+ y0 s) s :color shadow))
    (ui-block-text str x0 y0 s :color color)))

;;; DEFUN-FAST callers (HUD-SIDE, the panels' float layout, 2026-10-26): the same operations on unboxed floats.
(defmacro %hround (x) "(ROUND X) of a single float, 0 B: lrintf (nearest, ties to even, as ROUND; ROUND conses its remainder)."
  `(ffi:c-inline (,x) (:float) :int "lrintf(#0)" :one-liner t))

(defmacro %hud-text (str x y scale color &key (align :left) (shadow '*shade*))
  "HUD-TEXT's body for DEFUN-FAST callers: X Y single-float forms, SCALE a fixnum form; the arguments evaluated in order,
as a call would. 16 B (the widths UI-BLOCK-TEXT returns) where HUD-TEXT called with floats costs 32 B plus the boxed X Y."
  (let ((sv (gensym "S")) (xv (gensym "X")) (yv (gensym "Y")) (sc (gensym "SC")) (cv (gensym "C")) (al (gensym "A"))
        (sh (gensym "SH")) (x0 (gensym "X0")) (y0 (gensym "Y0")))
    `(let* ((,sv ,str) (,xv ,x) (,yv ,y) (,sc (max 1 (the fixnum ,scale))) (,cv ,color) (,al ,align) (,sh ,shadow)
            (,x0 (%hround (cond ((eq ,al :center) (- ,xv (* 0.5f0 (i->f (text-width ,sv ,sc)))))   ; (COND: an ECASE
                                ((eq ,al :right) (- ,xv (i->f (text-width ,sv ,sc))))           ;  boxed its value)
                                (t ,xv))))
            (,y0 (%hround ,yv)))
       (declare (single-float ,xv ,yv) (fixnum ,sc ,x0 ,y0))
       (when ,sh (ui-block-text ,sv (+ ,x0 ,sc) (+ ,y0 ,sc) ,sc :color ,sh))
       (ui-block-text ,sv ,x0 ,y0 ,sc :color ,cv))))

(defmacro %q->f (p q)
  "F32 of the ratio P / Q of fixnum forms, 0 B: the double quotient rounded to single, as ECL converts a ratio (its
ratio_to_double differs only on an exact half, which a quotient of small integers never is: it is exact or it does
not terminate). (ECL's ratio arithmetic and conversion to a float cons.)"
  `(ffi:c-inline (,p ,q) (:int :int) :float "(float)((double)(#0)/(double)(#1))" :one-liner t))

(defmacro %hud-pulse (hz) "HUD-PULSE of a single-float HZ form, unboxed." `(+ 0.5f0 (* 0.5f0 (f-sin (* 6.2831855f0 ,hz (fx-clock))))))

;;; (The zero-cons quads %HQ %HRECT %HBAR %HOUTLINE %PULSE are the engine's: engine/lisp/ui.lisp.)

;;; ---------------------------------------------------------------- big words
(defstruct (word (:constructor make-word (text sub color secs small side)))
  text sub color secs small side (t0 (fx-clock))
  (col (list 1.0 1.0 1.0 1.0)))                                   ; its colour (r g b 1)
(defvar *words* nil "Big words on screen, newest first.")
(defun clear-words () (setf *words* nil))

(defun announce (text &key sub (color *white*) (secs 1.0) small side)
  "Show TEXT big in the middle (SMALL: smaller, upper lane; SIDE 0 / 1: over that side's panel),
with SUB under it."
  (let ((wd (make-word text sub color secs small side)))
    (setf (first (word-col wd)) (f32 (first color)) (second (word-col wd)) (f32 (second color))
          (third (word-col wd)) (f32 (third color)))
    (setf *words* (cons wd (remove-if (lambda (w) (and (not (word-side w)) (eq (word-small w) small))) *words*)))))

(defun word-layout (x w h)
  "Word X on a W x H screen. Values: centre x, the caps' middle y, the brush em in px (the pop-in shrinks it over
the first 0.08 s; a long word shrinks to 92 % of the width). A word whose box would overlap a HUD side panel
(*PANEL-BOX*) is moved down under it (Phase 5: e.g. NOMIHOSE! over the P2 labels)."
  (let* ((k (min 1.0 (/ (- (fx-clock) (word-t0 x)) 0.08)))
         (em (* h (cond ((word-side x) 0.05) ((word-small x) 0.085) (t (* 0.13 (+ 1.0 (* 0.5 (- 1 k))))))))
         (em (min em (/ (* 0.92 w) (max 0.1 (line-width (word-text x))))))
         (cx (case (word-side x) (0 (* 0.2 w)) (1 (* 0.8 w)) (t (* 0.5 w))))
         (cy (if (portrait-p)                                   ; portrait: in the arena band (§4.2 lanes)
                 (* h (if (or (word-side x) (word-small x)) (+ (aref *band* 0) 0.05) (* 0.5 (+ (aref *band* 0) (aref *band* 1)))))
                 (if (or (word-side x) (word-small x)) (* 0.3 h) (* 0.45 h))))
         (hw (* 0.5 em (line-width (word-text x)))) (pb *panel-box*))
    (dotimes (i 2)
      (let ((o (* 4 i)))
        (when (and (< (- cx hw) (aref pb (+ o 2))) (< (aref pb o) (+ cx hw)) (< (- cy (* 0.45 em)) (aref pb (+ o 3)))
                   (= (aref pb (+ o 1)) 0f0))                   ; (a panel at the bottom, portrait P1's, is under the lanes)
          (setf cy (+ (aref pb (+ o 3)) (* 0.012 h) (* 0.45 em))))))
    (values cx cy em)))

(defun word-box (x w h)
  "Screen box of word X (text + sub). Values: x0 y0 x1 y1."
  (multiple-value-bind (cx cy em) (word-layout x w h)
    (let ((hw (* 0.5 em (line-width (word-text x)))))
      (values (- cx hw) (- cy (* 0.45 em)) (+ cx hw) (+ cy (if (word-sub x) (* 1.05 em) (* 0.45 em)))))))

(defvar *hud-warned* nil "Strings already logged as drawn over a HUD panel (HUD-OVER-PANEL).")
(defun hud-over-panel (what str x0 y0 x1 y1 w h)
  "Log once per string that the WHAT (callout / word) STR at (X0 Y0 X1 Y1) overlaps a HUD panel (tests/style-5-checks.py
greps \"over the P\")."
  (let ((side (panel-hit (f32 x0) (f32 y0) (f32 x1) (f32 y1))))
    (when (and side (not (member str *hud-warned* :test #'equal)))
      (push str *hud-warned*)
      (log-msg "hud: ~a ~a over the P~d panel on the ~dx~d screen: ~d ~d ~d ~d" what str (1+ side) w h
               (round x0) (round y0) (round x1) (round y1)))))

(defun draw-words (w h)
  "The big words (ANNOUNCE) in brush Latin, fading out over their last 0.25 s."
  (setf *words* (delete-if (lambda (x) (> (- (fx-clock) (word-t0 x)) (word-secs x))) *words*))
  (dolist (x *words*)
    (multiple-value-bind (x0 y0 x1 y1) (word-box x w h) (hud-over-panel "word" (word-text x) x0 y0 x1 y1 w h))
    (let* ((age (- (fx-clock) (word-t0 x)))
           (fade (min 1.0 (/ (- (word-secs x) age) 0.25))) (col (word-col x)))
      (multiple-value-bind (cx cy em) (word-layout x w h)
        (brush-text (word-text x) cx cy em col fade)
        (when (word-sub x)
          (let ((se (max (* 0.032 h) (* 0.36 em))))
            (brush-text (word-sub x) cx (+ cy (* 0.55 em) (* 0.5 se)) se col fade)))))))

;;; ---------------------------------------------------------------- side panels: the meters
(declaim (type f32vec *trail-v* *pip-t* *hud-v*))
(defvar *trail-v* (make-f32 4) "Damage trail per side (fraction): [side] Reishi, [2 + side] the guard gauge.")
(defvar *pip-t* (make-f32 (* 2 *konpaku-max*)) "Per side x pip: ELAPSED-TIME it shattered (0 = intact).")
(defvar *hud-v* (make-f32 3))

(defun pips-shatter (v lost)
  "LOST more of V's Konpaku pips break (HUD shards + glass burst in the world)."
  (let* ((side (fighter-side (fighter v))) (left (gauges-konpaku (gauges v))))
    (loop for i from left below (min *konpaku-max* (+ left lost))
          do (setf (aref *pip-t* (+ (* side *konpaku-max*) i)) (f32 (fx-clock))))
    (multiple-value-bind (x y z) (actor-point v 1.6) (vfx-konpaku-shatter x y z lost))
    (play-sfx :konpaku-shatter)))

(defun-fast-inline %hud-reishi (x y bw bh frac trail right red tm grey)
  "The Reishi bar: dark back, white damage TRAIL, the fill (amber, lit from the top; red and
pulsing when RED), a thin outline (red and pulsing when RED). GREY (a fraction above FRAC, else 0): a bind's grey band,
what he lost since it started (BIND-SNAPSHOT-OF; DUEL_HISAGI §17.3)."
  (declare (single-float x y bw bh frac trail tm grey))
  (let* ((p (%pulse tm 3.0)))
    (declare (single-float p))
    (%hrect x y bw bh 0.05f0 0.04f0 0.07f0 0.75f0)
    (%hbar x y bw bh trail right 0.95f0 0.9f0 0.85f0 0.9f0)
    (when (> grey frac) (%hbar x y bw bh grey right 0.56f0 0.56f0 0.6f0 0.95f0 0.4f0 0.4f0 0.44f0 0.95f0))
    (if red
        (%hbar x y bw bh frac right 1f0 0.35f0 0.35f0 (+ 0.65f0 (* 0.35f0 p)) 0.8f0 0.05f0 0.1f0 (+ 0.65f0 (* 0.35f0 p)))
        (%hbar x y bw bh frac right 1f0 0.78f0 0.36f0 1f0 0.88f0 0.45f0 0.12f0 1f0))
    (if red
        (%houtline (- x 1f0) (- y 1f0) (+ bw 2f0) (+ bh 2f0) 1f0 0.2f0 0.2f0 p)
        (%houtline (- x 1f0) (- y 1f0) (+ bw 2f0) (+ bh 2f0) 1f0 1f0 1f0 0.4f0))))

(defun-fast-inline %hud-guard (x y bw bh frac trail right guardless mode tm)
  "The guard gauge: dark back, white drain TRAIL, the fill by MODE bits: 1 30 % darker (he guards below full: GUARD
HOLD, no refill; Bankai West's ward), 2 ember (Bankai: East's pierce reads it), else steel; GUARDLESS: a grey bar whose
red fill climbs back (pulsing) until it is full and he can guard again. Bit 4: LOCK, a pulsing blue rim (the guard lock
holds him past his blockstun: only BLUE breaks it)."
  (declare (single-float x y bw bh frac trail tm) (fixnum mode))
  (let* ((p (%pulse tm 3.0)) (k (if (logtest mode 1) 0.7f0 1f0)) (em (logtest mode 2))
         (r0 (* k (if em 1f0 0.84f0))) (g0 (* k (if em 0.62f0 0.88f0))) (b0 (* k (if em 0.25f0 0.94f0)))
         (r1 (* k (if em 0.78f0 0.48f0))) (g1 (* k (if em 0.24f0 0.55f0))) (b1 (* k (if em 0.06f0 0.66f0))))
    (declare (single-float p k r0 g0 b0 r1 g1 b1))
    (%hrect x y bw bh 0.05f0 0.04f0 0.07f0 0.75f0)
    (if guardless
        (progn (%hrect x y bw bh 0.32f0 0.32f0 0.35f0 0.9f0)
               (%hbar x y bw bh frac right 0.9f0 0.12f0 0.15f0 (+ 0.6f0 (* 0.4f0 p)) 0.6f0 0.02f0 0.05f0 (+ 0.6f0 (* 0.4f0 p))))
        (progn (%hbar x y bw bh trail right 1f0 1f0 1f0 0.95f0)
               (%hbar x y bw bh frac right r0 g0 b0 1f0 r1 g1 b1 1f0)))
    (when (logtest mode 4) (%houtline (- x 1f0) (- y 1f0) (+ bw 2f0) (+ bh 2f0) 0.35f0 0.6f0 1f0 (+ 0.5f0 (* 0.4f0 p))))))

(defun-fast-inline %hud-flash (x y w h fill right burst running tm)
  "The flash-step bar: dark back, a steel-blue FILL (0..1), white ticks at a Hoho's and a burst's threshold; while a
burst RUNNING (its mode) drains it, the fill is that burst's colour (BURST-COLOR) with a pulsing bright edge; while one is
possible (BURST: the mode a press would start) the part past the burst tick glows in that mode's colour."
  (declare (single-float x y w h fill tm))
  (let* ((hk (/ (the single-float (f32 *fs-hoho*)) (the single-float (f32 *fs-max*))))
         (bk (/ (the single-float (f32 *fs-burst*)) (the single-float (f32 *fs-max*))))
         (p (%pulse tm 4.0)))
    (declare (single-float hk bk p))
    (%hrect x y w h 0.05f0 0.04f0 0.07f0 0.75f0)
    (if running
        (let* ((c (burst-color running)) (r (f32 (first c))) (g (f32 (second c))) (b (f32 (third c))))
          (declare (single-float r g b))
          (%hbar x y w h fill right r g b 1f0 (* 0.7f0 r) (* 0.7f0 g) (* 0.7f0 b) 1f0)
          (%hrect (if right (+ x (* w (- 1f0 fill))) (+ x (* w fill) -2f0)) (- y 1f0) 2f0 (+ h 2f0) 1f0 1f0 1f0 (+ 0.4f0 (* 0.6f0 p))))
        (%hbar x y w h fill right 0.55f0 0.75f0 1f0 1f0 0.25f0 0.45f0 0.8f0 1f0))
    (when (and burst (> fill bk))
      (let* ((sw (* w (- fill bk))) (sx (if right (+ x (* w (- 1f0 fill))) (+ x (* w bk))))   ; (right: fills from the right edge)
             (c (burst-color burst)))
        (declare (single-float sw sx))
        (%hrect sx (- y 1f0) sw (+ h 2f0) (f32 (first c)) (f32 (second c)) (f32 (third c)) (+ 0.5f0 (* 0.5f0 p)))))
    (%hrect (if right (+ x (* w (- 1f0 hk))) (+ x (* w hk))) (- y 2f0) 1f0 (+ h 4f0) 1f0 1f0 1f0 0.9f0)
    (%hrect (if right (+ x (* w (- 1f0 bk))) (+ x (* w bk))) (- y 2f0) 1f0 (+ h 4f0) 1f0 1f0 1f0 0.9f0)))

(declaim (type f32vec *refused-t*))
(defvar *refused-t* (make-f32 2) "Per side: FX-CLOCK of the last refused L press (its bar, or the cold gauge's cost, flashes).")
(defun refused-flash (side tm) "SIDE's refused-press flash at fx time TM: 1 at the press, 0 after 0.25 s." (f32 (max 0.0 (- 1.0 (* 4.0 (- tm (aref *refused-t* side)))))))

(defmacro %soul-flame (cx cy r lean r0 g0 b0 a0 r1 g1 b1 a1)
  "A soul-flame glyph centred at (CX CY), radius R: a rounded base and a pointed tip leaning LEAN px;
colour 0 at the tip, colour 1 at the base, plus a pale core."
  `(let* ((fx ,cx) (fy ,cy) (fr ,r) (fl ,lean) (tx (+ fx fl)) (ty (- fy (* 2.1f0 fr))))
     (declare (single-float fx fy fr fl tx ty))
     (%hq tx ty tx ty (+ fx fr) fy (- fx fr) fy ,r0 ,g0 ,b0 ,a0 ,r1 ,g1 ,b1 ,a1)            ; tip
     (%hq (- fx (* 0.9f0 fr) (* 0.4f0 fl)) (- fy (* 1.25f0 fr)) (- fx (* 0.9f0 fr) (* 0.4f0 fl)) (- fy (* 1.25f0 fr))
          fx fy (- fx fr) (+ fy (* 0.2f0 fr)) ,r0 ,g0 ,b0 ,a0 ,r1 ,g1 ,b1 ,a1)                ; side lick
     (%hq (- fx fr) fy (+ fx fr) fy (+ fx (* 0.55f0 fr)) (+ fy (* 0.85f0 fr)) (- fx (* 0.55f0 fr)) (+ fy (* 0.85f0 fr))
          ,r1 ,g1 ,b1 ,a1)                                                                   ; round base
     (%hq (+ fx (* 0.5f0 fl)) (- fy (* 0.9f0 fr)) (+ fx (* 0.5f0 fl)) (- fy (* 0.9f0 fr))
          (+ fx (* 0.4f0 fr)) (+ fy (* 0.3f0 fr)) (- fx (* 0.4f0 fr)) (+ fy (* 0.3f0 fr))
          1f0 1f0 1f0 (* 0.2f0 ,a1) 1f0 1f0 1f0 (* 0.75f0 ,a1))))                           ; core

(defun-fast-inline %hud-pips (x py bw r side n right red tm pitch stake grey)
  "The Konpaku: N intact soul flames, blue but the last STAKE of them in blood red (what the opponent's Kikon would take
now: KONPAKU-AT-STAKE; they pulse while RED, i.e. while that Kikon is live), shattering ones (0.6 s of shards after
PIPS-SHATTER), grey ones up to GREY (a bind's grey souls: the Konpaku at its start, else 0), and dim embers for the
lost ones; PITCH radii apart (the landscape panel: 3.2)."
  (declare (single-float x py bw r tm pitch) (fixnum side n stake grey))
  (let* ((pt *pip-t*) (p (%pulse tm 2.0)))
    (declare (type f32vec pt) (single-float p))
    (dotimes (i *konpaku-max*)
      (let* ((fi (i->f i)) (d (* (+ fi 0.5f0) pitch r)) (cx (if right (- (+ x bw) d) (+ x d)))
             (j (+ (* side *konpaku-max*) i)) (t0 (aref pt j)) (u (/ (- tm t0) 0.6f0))
             (lean (* 0.3f0 r (f-sin (+ (* 7f0 tm) (* 1.7f0 fi))))))
        (declare (single-float fi d cx t0 u lean) (fixnum j))
        (cond ((< i n)
               (setf (aref pt j) 0f0)
               (if (>= i (- n stake))                            ; at stake: *C-BLOOD* at the base
                   (let ((a (if red (+ 0.7f0 (* 0.3f0 p)) 1f0)))
                     (declare (single-float a))
                     (%soul-flame cx py r lean 1f0 0.45f0 0.4f0 (* 0.6f0 a) 0.82f0 0.06f0 0.11f0 a))
                   (%soul-flame cx py r lean 0.75f0 0.95f0 1f0 0.45f0 0.35f0 0.7f0 1f0 1f0)))
              ((and (> t0 0f0) (< u 1f0))                      ; shattering: 4 shards fly apart
               (dotimes (k 4)
                 (let* ((a (* (i->f k) 1.5707964f0)) (sx (+ cx (* 14f0 (/ r 4.5f0) u (f-cos a))))
                        (sy (+ py (* 14f0 (/ r 4.5f0) u (f-sin a)))) (sr (* r 0.4f0 (- 1f0 u))))
                   (declare (single-float a sx sy sr))
                   (%hq sx (- sy (* 1.6f0 sr)) (+ sx sr) sy sx (+ sy sr) (- sx sr) sy
                        0.8f0 0.95f0 1f0 (- 1f0 u)))))
              ((< i grey) (%soul-flame cx py r lean 0.7f0 0.7f0 0.74f0 0.45f0 0.42f0 0.42f0 0.46f0 0.9f0))   ; grey (a bind)
              (t (%soul-flame cx py (* 0.5f0 r) 0f0 0.3f0 0.3f0 0.35f0 0.3f0 0.3f0 0.3f0 0.35f0 0.6f0)))))))

(defun at-stake (e)
  "E's Konpaku flames the opponent's Kikon would take if it landed now: its current worth (combat.lisp KIKON-WORTH:
the running rush's, a kit's :kikon-worth hook, else its :kikon-konpaku), capped (control.lisp KONPAKU-AT-STAKE)."
  (let ((o (fighter-opp (fighter e))))
    (if (and o (entity-alive-p o)) (konpaku-at-stake (gauges-konpaku (gauges e)) (kikon-worth o)) 0)))

(defun-fast-inline %hud-reiatsu (x y sw sh gap ra right)
  "Reiatsu: 3 bars of *REIATSU-BAR* each (full ones bright), from the panel's outer edge."
  (declare (single-float x y sw sh gap ra))
  (let* ((bar (the single-float (f32 *reiatsu-bar*))))
    (declare (single-float bar))
    (dotimes (i 3)
      (let* ((fi (i->f i)) (bx (if right (- x (* (+ fi 1f0) sw) (* fi gap)) (+ x (* fi (+ sw gap)))))
             (fill (f-clamp (/ (- ra (* fi bar)) bar) 0f0 1f0)))
        (declare (single-float fi bx fill))
        (%hrect bx y sw sh 0.05f0 0.04f0 0.07f0 0.75f0)
        (if (>= fill 1f0)
            (%hbar bx y sw sh fill right 0.6f0 0.92f0 1f0 1f0 0.25f0 0.65f0 1f0 1f0)
            (%hbar bx y sw sh fill right 0.2f0 0.45f0 0.7f0 1f0))))))


(defparameter *pool-tally* #("x3" "x4" "x5" "x6") "The tally of a bind's shared pool, by its full bars.")
(defun pool-tally (ra)
  "The tally of RA Reiatsu's full bars while it holds more than three bars' worth (a bind's shared pool: REIATSU-OF),
else NIL."
  (and (> ra *reiatsu-max*) (svref *pool-tally* (max 0 (min 3 (- (floor ra *reiatsu-bar*) 3))))))

(defun hud-refused (e cmd)
  "E pressed CMD while it was cooling or short of cold (the :refused event): L's bar flashes."
  (when (eq cmd :sig) (setf (aref *refused-t* (fighter-side (fighter e))) (f32 (fx-clock)))))

(defun-fast %hud-cd (x y w h fill flash right r g b)
  "One cooldown bar: dark back, the FILL (1 = ready) bright in (R G B) when ready, dim while cooling; FLASH (0..1)
washes it white (a refused press)."
  (declare (single-float x y w h fill flash r g b))
  (let* ((k (if (>= fill 1f0) 1f0 0.45f0)))
    (declare (single-float k))
    (%hrect x y w h 0.05f0 0.04f0 0.07f0 0.75f0)
    (%hbar x y w h fill right (* k r) (* k g) (* k b) 1f0)
    (when (> flash 0f0) (%hrect x (- y 1f0) w (+ h 2f0) 1f0 1f0 1f0 flash))))

(defun hud-cooldowns (f kit x y w h right tm)
  "An awakened form's L cooldown, W x H at (X Y): ONE bar (steel; L has one use per cooldown, so one cell: playtest 1,
2026-09-28). A refused press flashes it."
  (%hud-cd (f32 x) (f32 y) (f32 w) (f32 h)
           (f32 (max 0.0 (- 1.0 (/ (aref (fighter-cd f) (position :sig *kit-commands*))
                                   (float (mv-cooldown (kit-command-move kit :sig)))))))
           (refused-flash (fighter-side f) tm) right 0.84f0 0.88f0 0.94f0))

(defun-fast-inline %hud-thin (x y w h fill right r g b a0 hz tm)
  "A thin gauge (Awakening, the kit meter): dark back, FILL in (R G B), alpha A0, pulsing up to 1
at HZ when HZ > 0."
  (declare (single-float x y w h fill r g b a0 hz tm))
  (let* ((a (if (> hz 0f0) (+ a0 (* (- 1f0 a0) (+ 0.5f0 (* 0.5f0 (f-sin (* 6.2831855f0 hz tm)))))) a0)))
    (declare (single-float a))
    (%hrect x y w h 0.05f0 0.04f0 0.07f0 0.75f0)
    (%hbar x y w h fill right r g b a)))

;;; ---------------------------------------------------------------- KOSEI (攻勢): the tag and the motes (docs/duel/DUEL_STRINGS.md §5)
(declaim (type f32vec *kosei-v*))
(defvar *kosei-v* (make-f32 10) "Per side: FX-CLOCK of the last paying contact, its multiplier and its screen x y (the mote).")
(defparameter *kosei-kanji* "攻")
(defparameter *kosei-tags* (coerce (loop for i from 15 to 30 collect (format nil "x~,1f" (/ i 10.0))) 'simple-vector)
  "The tag's multiplier text, x1.5 .. x3.0 in tenths (no string made per frame).")
(defparameter *c-kosei* (list 1.0 0.55 0.2 1.0))

(defun kosei-mote (e m x y z)
  "A paying contact of E's (the :kosei event): one ember mote from the hit at (X Y Z) (its screen point now) to his
Reiatsu bar, sized by M; none when the hit is off screen."
  (let ((o (* 5 (fighter-side (fighter e)))) (v *kosei-v*))
    (setf (aref v o) (if (world-to-screen *hud-v* (f32 x) (f32 y) (f32 z)) (f32 (fx-clock)) 0f0) (aref v (+ o 1)) (f32 m)
          (aref v (+ o 2)) (aref *hud-v* 0) (aref v (+ o 3)) (aref *hud-v* 1))))

(defun kosei-tag-w (gg s &optional (ek 8))
  "The width, px, of HUD-KOSEI's tag at guard gauge GG (0 when it isn't shown: the multiplier below 1.5)."
  (let ((m (kosei-mult gg)))
    (if (>= m 1.5)
        (+ (text-width (svref *kosei-tags* (max 0 (min 15 (- (round (* 10 m)) 15)))) s) (* 2 s) (* ek s))
        0)))

(defun-fast-inline %kosei-mote (o tx ty s)
  "The mote of the paying contact at offset O of *KOSEI-V*, flying from its hit to (TX TY) over 0.35 s (0 B)."
  (declare (fixnum o) (single-float tx ty s))
  (let* ((v *kosei-v*) (t0 (aref v o)) (u (/ (- (fx-clock) t0) 0.35f0)))
    (declare (type f32vec v) (single-float t0 u))
    (when (and (> t0 0f0) (> u 0f0) (< u 1f0))
      (let* ((k (* u u)) (x (aref v (+ o 2))) (y (aref v (+ o 3)))
             (cx (+ x (* k (- tx x)))) (cy (+ y (* k (- ty y)))) (r (* s (+ 1.5f0 (* 1.5f0 (aref v (+ o 1)))))) (a (- 1f0 (* 0.5f0 u))))
        (declare (single-float k x y cx cy r a))
        (dotimes (i 12)                                   ; an ember disc (a 12-gon, drawn here: no boxed arguments)
          (let* ((a0 (* (i->f i) 0.5235988f0)) (a1 (+ a0 0.5235988f0)))
            (declare (single-float a0 a1))
            (%hq cx cy (+ cx (* r (f-cos a0))) (+ cy (* r (f-sin a0))) (+ cx (* r (f-cos a1))) (+ cy (* r (f-sin a1))) cx cy
                 1f0 0.55f0 0.2f0 a)))))))

(defun-fast-inline hud-kosei (side gg x y right tx ty s ek)
  "KOSEI on side SIDE's panel: at a multiplier >= 1.5 (his guard gauge GG) the ember 攻 xM tag ending at X (the inner
end of his guard bar, on the Konpaku row: its middle at Y), toward his side of the screen (RIGHT: the right panel), the
kanji EK x S px; the last paying contact's mote flying to (TX TY), his Reiatsu bar, 0.35 s. (Inlined into the panels,
the floats unboxed: the generic DEFUN's operations in its order.)"
  (declare (fixnum side s ek) (single-float x y tx ty))
  (let ((m (kosei-mult gg)))
    (when (>= m 1.5)
      (let* ((em (* ek s)) (str (svref *kosei-tags* (max 0 (min 15 (- (%hround (* 10f0 (the single-float m))) 15)))))
             (tw (text-width str s))
             (kx (if right (+ x (* 0.5f0 (i->f em))) (- x (i->f tw) (i->f (* 2 s)) (* 0.5f0 (i->f em))))))
        (declare (fixnum em tw) (single-float kx))
        (brush-text *kosei-kanji* kx y em *c-kosei*)
        (%hud-text str (if right (+ x (i->f em) (i->f (* 2 s))) x) (- y (* 3.5f0 (i->f s))) s *c-kosei*
                   :align (if right :left :right)))))
  (%kosei-mote (* 5 side) tx ty (i->f s)))

;;; ---------------------------------------------------------------- side panels: per-kit strings
(defvar *kit-hud* (make-hash-table :test 'eq) "KIT -> #(label meter u-tag): the panel name, the kit meter, U's tag.")

(defun kit-hud (kit)
  "The cached HUD data of KIT: the name label (\"YAMAMOTO  BANKAI\"), the kit meter (inherited
from the base form when this form has none) and the tag of what U does in the form (\"U: WEST\", \"WARD\", \"U: DRINK\")."
  (or (gethash kit *kit-hud*)
      (setf (gethash kit *kit-hud*)
            (vector (format nil "~a~@[  ~a~]" (kit-name kit) (and (not (eq (kit-form kit) :base)) (kit-form-name kit)))
                    (or (kit-meter kit) (kit-meter (find-kit (kit-character kit) :base)))
                    (cond ((kit-u-tag kit)) ((kit-guard-to kit) "U: WEST") ((member :ward (kit-passives kit)) "WARD")
                          ((member :drink (kit-passives kit)) "U: DRINK"))))))

;;; combo counter: per victim side, the last combo with dealt damage (knockdown zeroes the running
;;; total, so the counter keeps the last non-zero one) and its string, rebuilt when it changes
(defstruct (combo-show (:conc-name cs-)) (hits 0) (dmg 0) (t0 -10.0) (str ""))
(defvar *combo-show* (vector (make-combo-show) (make-combo-show)))

(defun combo-string (c hits dmg)
  (unless (and (= hits (cs-hits c)) (= dmg (cs-dmg c)))
    (setf (cs-hits c) hits (cs-dmg c) dmg (cs-str c) (format nil "~d HIT~:P  ~d" hits dmg)))
  (setf (cs-t0 c) (fx-clock))
  c)

(defvar *c-evo* (list 1.0 0.85 0.3 1.0))
(defvar *u-tag* (list 1.0 0.72 0.35 1.0))
(defvar *c-kikon* (list 1.0 0.2 0.25 1.0))
(defun burst-prompt (mode keys side)
  "The HUD prompt for burst MODE (:blue BURST, :orange CHAIN) of SIDE pressed with KEYS (:flick, else :pad / :key: his
bindings, CONTROLS-KEY-PROMPT)."
  (if (eq keys :flick)
      (if (eq mode :orange) "FLICK DOWN  CHAIN" "FLICK DOWN  BURST")
      (key-prompt *bind-pair* side keys (if (eq mode :orange) :chain :burst))))
(defvar *c-callout* (list 1.0 0.85 0.55 1.0))
(defvar *c-hint* (list 0.6 0.95 1.0 1.0) "PERFECT HINT's HOHO!.")

(defparameter *c-blood* (list 0.82 0.06 0.11 1.0))
(defun trail-step! (i target rate)
  "*TRAIL-V*[I], a damage trail, eases down to TARGET at RATE per second (HUD seconds), or snaps up to it."
  (let ((tr (aref *trail-v* i)))
    (setf (aref *trail-v* i) (f32 (if (> tr target) (max target (- tr (* rate (hud-dt)))) target)))))

(defun guard-gauge-bits (e f gf)
  "%HUD-GUARD's MODE bits for entity E, whose fighter component is F, at guard fraction GF: 1 guarding below full (or
warded), 2 pierce / ward, 4 the guard lock."
  (let ((ward (passive-p e :ward)))
    (logior (if (and (or ward (member (fighter-state f) '(:guard :guard-hit))) (< gf 1.0)) 1 0)
            (if (or ward (passive-p e :pierce)) 2 0) (if (guard-locked-now-p f) 4 0))))

(defun awaken-fill (g kit)
  "The Awakening bar's fill (0..1) for gauges G of KIT: the form's timer while a timed awakening runs, full in a form that is
an awakening, else the awakening gauge."
  (let ((timed (and (kit-awakening kit) (plusp (gauges-form-total g)))))
    (cond (timed (timer-fill (gauges-form-left g) (gauges-form-total g) 1.0))
          ((kit-awakening kit) 1.0) (t (/ (gauges-awaken g) *awaken-max*)))))

(defun prompt-alpha () "The KIKON / BURST / BANKAI prompts' pulsing alpha." (+ 0.5 (* 0.5 (hud-pulse 4.0))))

;;; HUD-SIDE runs twice a frame: a DEFUN-FAST since 2026-10-26 (was ~1.2 KB a side boxed). Its layout in single floats
;;; with the generic DEFUN's operations in its order (a fixnum x float product is the same float product, a MAX of a
;;; fixnum and a float the same value, and the fixnums are small: integer sums done in floats are exact); the meters
;;; inlined, the labels %HUD-TEXT. Calls out (a hook, a meter's :draw) get the values the generic code passed them.
(defun-fast hud-side (e w h s)
  "Side E's landscape panel on a W x H screen at UI scale S (P2 mirrored, at the right)."
  (declare (fixnum w h s))
  (let* ((f (fighter e)) (g (gauges e)) (kit (fighter-kit f)) (kh (kit-hud kit)) (side (fighter-side f)) (right (= side 1))
         (wf (i->f w)) (hf (i->f h))
         (m (* 0.03f0 wf)) (bw (* 0.36f0 wf)) (x (if right (- wf m bw) m)) (edge (if right (+ x bw) x))
         (align (if right :right :left)) (y (* 0.05f0 hf)) (bh (f-max (i->f (* 7 s)) (* 0.028f0 hf)))
         (ns (max 2 s)) (tm (fx-clock)) (ls s)
         (dt (if (fx-frozen-p) 0f0 (the single-float (frame-dt))))   ; (HUD-DT)
         (frac (the single-float (reishi-frac g))) (red (gauges-red-p g)))
    (declare (fixnum side ns ls) (single-float wf hf m bw x edge y bh tm dt frac))
    (macrolet ((%trail! (i target rate)                   ; TRAIL-STEP!
                 `(let* ((i ,i) (target ,target) (tr (aref *trail-v* i)))
                    (declare (fixnum i) (single-float target tr))
                    (setf (aref *trail-v* i) (if (> tr target) (f-max target (- tr (* ,rate dt))) target))))
               (%fs (form) `(i->f ,form))                 ; a fixnum product as a float
               (%palpha (hz) `(+ 0.5f0 (* 0.5f0 (%hud-pulse ,hz)))))   ; PROMPT-ALPHA
      ;; name + form
      (%hud-text (svref kh 0) edge (- y (%fs (* 8 ns)) (%fs s)) ns (if (kit-awakening kit) *ember* *white*)
                 :align align)
      ;; Reishi + trail
      (%trail! side frac 0.35f0)
      (%hud-reishi x y bw bh frac (aref *trail-v* side) right red tm (the single-float (bind-grey-frac e)))
      ;; the guard gauge, right under it
      (let* ((gf (/ (the single-float (gauges-gg g)) (the single-float *gg-max*))) (ti (+ 2 side))
             (gy (+ y bh (%fs (* 2 s)))) (gh (f-max (%fs (* 3 s)) (* 0.3f0 bh))))
        (declare (single-float gf gy gh) (fixnum ti))
        (%trail! ti gf 0.5f0)
        (%hud-guard x gy bw gh gf (aref *trail-v* ti) right (gauges-guardless g) (guard-gauge-bits e f gf) tm)
        (let ((hk (kit-hook kit :hud-guard)))            ; a form's own look of the bar (drawn over it)
          (when hk (funcall hk e x gy bw gh right s tm))))
      ;; KOSEI: the tag at the guard bar's inner end (on the Konpaku row, clear of the pips), the mote to the Reiatsu bars
      (let ((pr (f-max (* 4.5f0 (%fs s)) (* 0.013f0 hf))))   ; the flames' radius
        (declare (single-float pr))
        (hud-kosei side (gauges-gg g) (if right x (+ x bw)) (+ y bh (%fs (* 16 s)) (* 0.5f0 pr))
                   right (if right (- edge (* 0.12f0 wf)) (+ edge (* 0.12f0 wf))) (+ y bh (%fs (* 26 s))) s 8)
        ;; Konpaku soul flames
        (%hud-pips x (+ y bh (%fs (* 16 s))) bw pr side (gauges-konpaku g) right red tm 3.2f0
                   (at-stake e) (bind-grey-souls e)))
      ;; Reiatsu: 3 bars + label
      (let* ((sy (+ y bh (%fs (* 25 s)))) (sw (* 0.075f0 wf)) (sh (f-max (%fs (* 3 s)) (* 0.011f0 hf))) (gap (* 3 s))
             (row (* 11 s))
             (lx (if right (- edge (* 3f0 (+ sw (%fs gap))) (%fs (* 3 s))) (+ edge (* 3f0 (+ sw (%fs gap))) (%fs (* 3 s)))))
             (ly (- (+ sy (* 0.5f0 sh)) (* 3.5f0 (%fs s)))))
        (declare (single-float sy sw sh lx ly) (fixnum gap row))
        (%hud-reiatsu edge sy sw sh (%fs gap) (the single-float (f32 (reiatsu-of e))) right)
        (%hud-text "REIATSU" lx ly ls '(0.45 0.8 1 0.9) :align align)
        (let ((tl (pool-tally (reiatsu-of e))) (tw (+ (text-width "REIATSU" ls) (* 4 s))))   ; a bind's pool past 3 bars
          (declare (fixnum tw))
          (when tl (%hud-text tl (if right (- lx (%fs tw)) (+ lx (%fs tw))) ly ls '(0.45 0.8 1 0.9) :align align)))
        ;; flash-step (Hoho, Burst), Awakening (drains during a timed awakening), the kit meter (Inferno; drains in its form)
        (let* ((fy (+ sy (%fs row))) (ay (+ fy (%fs row))) (aw (+ (* 3f0 sw) (%fs (* 6 s))))
               (ah0 (* 3 s)) (ah1 (* 0.009f0 hf)) (ah (f-max (%fs ah0) ah1)) (ty (- (* 0.5f0 ah) (* 3.5f0 (%fs s))))
               (ax (if right (- edge aw) x)) (lx (if right (- edge aw (%fs (* 6 s))) (+ edge aw (%fs (* 6 s)))))
               (hot (or (gauges-evolution g) (kit-awakening kit)))
               (afill (the single-float (awaken-fill g kit))))
          (declare (fixnum ah0) (single-float fy ay aw ah1 ah ty ax lx afill))
          (%hud-flash ax fy aw ah (/ (the single-float (gauges-fs g)) (the single-float *fs-max*)) right (burst-ok-p e)
                      (gauges-burst g) tm)
          (%hud-text "FLASH STEP" lx (+ fy ty) ls '(0.6 0.78 1 0.9) :align align)
          (%hud-thin ax ay aw ah afill right 1f0 (if hot 0.85f0 0.75f0) 0.3f0
                     (if hot 0.6f0 1f0) (if hot 4f0 0f0) tm)
          (cond ((gauges-evolution g)
                 (%hud-text "EVOLUTION" lx (+ ay ty) ls (alpha! *c-evo* (%hud-pulse 3f0)) :align align))
                ((svref kh 2) (%hud-text (svref kh 2) lx (+ ay ty) ls *u-tag* :align align))   ; what this form's guard adds
                ((kit-awakening kit) (%hud-text (kit-form-name kit) lx (+ ay ty) ls *ember* :align align))
                (t (%hud-text "AWAKEN" lx (+ ay ty) ls '(0.95 0.8 0.4 0.9) :align align)))
          (let ((l (kit-command-move kit :sig)))   ; the L cooldown (+ Shift+L's line: HUD-COOLDOWNS)
            (when (and l (kit-awakening kit) (plusp (mv-cooldown l)))   ; (a form without an L: Rukia's THAW)
              (let ((my (+ ay (%fs row))))
                (declare (single-float my))
                (hud-cooldowns f kit ax my aw ah right tm)
                (%hud-text "COOLDOWN" lx (+ my ty) ls '(0.84 0.88 0.94 0.9) :align align))))
          (let ((meter (svref kh 1)))
            (when (getf meter :draw)                    ; a character's own meter (its :draw function, e.g. Senjumaru's)
              (funcall (getf meter :draw) e kit ax (+ ay (%fs row)) aw (if (< (%fs ah0) ah1) ah1 ah0)   ; (AH as MAX gave it)
                       right tm lx (+ ay (%fs row) ty) ls))
            (when (and meter (not (kit-awakening kit)) (not (getf meter :draw)))
              (let* ((my (+ ay (%fs row))) (burning (plusp (gauges-form-left g)))
                     (mfill (the single-float
                                 (f32 (if burning
                                          (timer-fill (gauges-form-left g) (gauges-form-total g) 1.0)
                                          (/ (gauges-meter g) (getf meter :max)))))))
                (declare (single-float my mfill))
                (%hud-thin ax my aw ah mfill right 1f0 (if burning 0.4f0 0.45f0) (if burning 0.1f0 0.12f0)
                           (if burning 0.7f0 1f0) (if burning 5f0 0f0) tm)
                (%hud-text (getf meter :name) lx (+ my ty) ls '(1 0.55 0.25 0.9) :align align))))))
      ;; combo counter under this side's bar (this side is the victim): the last total that dealt damage
      (let ((c (svref *combo-show* side)))
        (when (and (> (fighter-combo-hits f) (if (eq *mode* :practice) 0 1)) (plusp (fighter-combo-dmg f)))
          (combo-string c (fighter-combo-hits f) (fighter-combo-dmg f)))
        (when (or (< (- tm (the single-float (cs-t0 c))) 1.2f0) (eq *mode* :practice))   ; PRACTICE: the last combo stays up
          (%hud-text (cs-str c) edge (+ y bh (%fs (* 62 s))) (* 2 s) '(1 0.9 0.6 1) :align align)))
      ;; the panel's box (the callouts and words keep clear of it): its bars, labels and combo counter
      (let ((o (* 4 side)) (pb *panel-box*))
        (declare (fixnum o) (type f32vec pb))
        (setf (aref pb o) (- x (%fs (* 4 s))) (aref pb (+ o 1)) 0f0 (aref pb (+ o 2)) (+ x bw (%fs (* 4 s)))
              (aref pb (+ o 3)) (+ y bh (%fs (* 78 s)))))
      ;; KIKON / BURST prompts for a human
      (when (and (not (brain e)) (member *flow* '(:battle)))
        (let ((px (if right (* 0.75f0 wf) (* 0.25f0 wf))))
          (declare (single-float px))
          (cond ((bankai-ready-p e)                      ; cup 3, <= 4 Konpaku, free: P enters the Bankai (Kenpachi)
                 (let ((bp (getf (svref kh 1) :bankai-prompt)))   ; (a form's meter may rename it: its :bankai-prompt)
                   (%hud-text (cond ((pad-connected-p side) (getf bp :pad "BACK  BANKAI")) (right (getf bp :right "KP+  BANKAI"))
                                    (t (getf bp :key "P  BANKAI")))
                              px (* 0.72f0 hf) (* 3 s)
                              (alpha! (or (getf bp :rgb) *c-blood*) (%palpha 4f0))
                              :align :center))
                 (when (kikon-ready-p e)
                   (%hud-text (if (pad-connected-p side) "HOLD RT  KIKON" (if right "HOLD KP6  KIKON" "HOLD O  KIKON"))
                              px (* 0.78f0 hf) (* 3 s) (alpha! *c-kikon* (%palpha 4f0))
                              :align :center)))
                ((kikon-ready-p e)                       ; the opponent is red: the rush, held, Kiko's
                 (%hud-text (if (pad-connected-p side) "HOLD RT  KIKON" (if right "HOLD KP6  KIKON" "HOLD O  KIKON"))
                            px (* 0.78f0 hf) (* 3 s) (alpha! *c-kikon* (%palpha 4f0))
                            :align :center))
                ((member (burst-ok-p e) '(:blue :orange)) ; (WHITE: most of neutral; the bar's glow says it)
                 (%hud-text (burst-prompt (burst-ok-p e) (cond (*one-hand* :flick) ((pad-connected-p side) :pad) (t :key)) side)
                            px (* 0.78f0 hf) (* 2 s) (alpha! (burst-color (burst-ok-p e)) (%palpha 4f0))
                            :align :center))))))
    nil))

;;; ---------------------------------------------------------------- portrait blocks (P2, docs/duel/DUEL_MOBILE_DESIGN.md §4.2)
;;; A tall screen splits the HUD by fighter (the user's decision 2026-09-27): the opponent's (P2's) block across the top
;;; under the safe-area inset, the player's (P1's, the fighter near the camera) across the bottom over the home
;;; indicator, each full width so its bars and flames can be large. A block, in S units from its top edge: row 1 the name
;;; (1.4 s), the KOSEI tag after it, and at the right end ONE label (EVOLUTION, else the kit meter's name / COOLDOWN, else
;;; U's tag) and, on P2's block, the timer; Reishi (5 s tall); the guard gauge (2 s); the Konpaku flames at the left and a
;;; row of small unlabelled gauges beside them in the landscape panel's colours (Reiatsu cells, flash step, Awakening, the
;;; kit meter or the awakened form's L cooldown). The user's decisions 2026-09-28 (DUEL_MOBILE_DESIGN §15.2):
;;; the flames, larger (r up to 4 s), fill row 1 after the name (up to P2's timer); the small gauges are 4 s thick
;;; (were 2.5 s) on the last row, with the label and the KOSEI tag at its right end. The block stays 29 s.
;;; The combo counter hangs under P2's block / over P1's.
(defvar *safe-top* 0 "The safe-area inset at the top, CSS px (onehand.lisp DECK-UPDATE; 0 off a notched phone).")
(defvar *safe-bot* 0 "The safe-area inset at the bottom (the home indicator), CSS px (DECK-UPDATE).")
(defun portrait-block-h (s) "A portrait HUD block's height, px." (* 29 s))
(defun portrait-top-px (s) "Top edge of P2's block, px." (+ (* *safe-top* (pixel-density)) (* 2 s)))
(defun portrait-hud-bottom (s) "Bottom of P2's block at the top, px." (+ (portrait-top-px s) (portrait-block-h s)))
(defun portrait-p1-top (s h) "Top edge of P1's block at the bottom, px (over the home indicator, at least 8 CSS px up)."
  (- h (* (max 8 (+ *safe-bot* 4)) (pixel-density)) (portrait-block-h s)))

(defun portrait-label (g kit kh meter)
  "The one label of a portrait block, or NIL: EVOLUTION, the kit meter's name / COOLDOWN, U's tag."
  (cond ((gauges-evolution g) "EVOLUTION")
        ((getf meter :label) (funcall (getf meter :label) g kit))   ; a character's own meter
        ((and (kit-awakening kit) (kit-command-move kit :sig) (plusp (mv-cooldown (kit-command-move kit :sig)))) "COOLDOWN")
        ((and meter (not (kit-awakening kit))) (getf meter :name))
        (t (svref kh 2))))

;;; HUD-SIDE-PORTRAIT: a DEFUN-FAST since 2026-10-26 (was ~2 KB a side boxed on a phone), as HUD-SIDE: the float rows
;;; (Y and what hangs off it) in single floats with the generic code's operations in its order; the integer layout stays
;;; integer; what the generic code computed as a ratio and then converted (the small gauges' widths, the flames' pitch)
;;; is converted from its exact integer quotient (%Q->F), and a meter's :draw still gets the ratios themselves.
(defun-fast hud-side-portrait (e w h s)
  "Side E's portrait block on a W x H screen at UI scale S: P2's across the top, P1's across the bottom."
  (declare (fixnum w h s))
  (let* ((f (fighter e)) (g (gauges e)) (kit (fighter-kit f)) (kh (kit-hud kit)) (side (fighter-side f)) (top (= side 1))
         (tm (fx-clock)) (y (the single-float (if top (portrait-top-px s) (portrait-p1-top s h)))) (m (* 4 s)) (bw (- w m m))
         (ns (%hround (* 1.4f0 (i->f s)))) (tsc ns)       ; (ROUND (* 1.4 S)), twice
         (dt (if (fx-frozen-p) 0f0 (the single-float (frame-dt))))   ; (HUD-DT)
         (frac (the single-float (reishi-frac g))) (red (gauges-red-p g))
         (ry (+ y (i->f (* 7 ns)) (i->f (* 2 s)))) (bh (* 5 s)) (gy (+ ry (i->f bh) (i->f s)))
         (yb (+ gy (i->f (* 5 s)))) (bar (* 4 s))                       ; the last row: the small gauges
         (meter (svref kh 1)) (label (portrait-label g kit kh meter))
         (rx (- (+ m bw) (if top (+ (* 17 tsc) (* 4 s)) 0))))          ; the right end of row 1 (P2: left of the timer)
    (declare (fixnum side m bw ns tsc bh bar rx) (single-float tm y dt frac ry gy yb))
    (macrolet ((%trail! (i target rate)                  ; TRAIL-STEP!
                 `(let* ((i ,i) (target ,target) (tr (aref *trail-v* i)))
                    (declare (fixnum i) (single-float target tr))
                    (setf (aref *trail-v* i) (if (> tr target) (f-max target (- tr (* ,rate dt))) target))))
               (%fs (form) `(i->f ,form))                ; a fixnum as a float
               (%palpha (hz) `(+ 0.5f0 (* 0.5f0 (%hud-pulse ,hz)))))   ; PROMPT-ALPHA
      (if top                                            ; a soft ink backing: the block reads on a white card too
          (ui-gradient 0 0 w (+ y (%fs (portrait-block-h s)) (%fs (* 6 s))) '(0 0 0 0.5) '(0 0 0 0))
          (ui-gradient 0 (- y (%fs (* 6 s))) w (- (%fs h) (- y (%fs (* 6 s)))) '(0 0 0 0) '(0 0 0 0.5)))
      ;; row 1 (playtest 2, 2026-09-28: the last row's gauges span the Reishi bar, so its label and KOSEI tag moved up
      ;; here): the name, the label after it (not when it repeats the form's name: Rukia's band), the Konpaku flames in
      ;; what is left, the KOSEI tag at the row's right end (P2: left of the timer, HUD-BATTLE). The flames shrink to fit
      ;; (r <= fw / 2.4 n: never overlapping), so nothing overlaps them
      (let* ((str (svref kh 0)) (sc (fit-scale str ns (* 0.45 bw)))
             (lab (and label (not (and (kit-awakening kit) (string= label (kit-form-name kit)))) label))
             (kw (kosei-tag-w (gauges-gg g) s 7)))
        (flet ((fw () (- rx m (text-width str sc) (* 5 s) (if lab (+ (text-width lab s) (* 4 s)) 0) (if (plusp kw) (+ kw (* 3 s)) 0)))
               (short () (setf str (if (kit-awakening kit) (kit-form-name kit) (kit-name kit)) sc (fit-scale str ns (* 0.45 bw)))))
          (when (< sc s) (short))
          ;; a crowded row (P2's timer, a long name, the label and KOSEI): the flames keep r >= 3 s; the short name first,
          ;; then the label goes
          (let ((fmin (* 2.4 *konpaku-max* 3 s)))
            (when (< (fw) fmin) (short))
            (when (< (fw) fmin) (setf lab nil))))
        (%hud-text str (%fs m) y sc (if (kit-awakening kit) *ember* *white*))
        (let* ((lx (+ m (text-width str sc) (* 4 s)))
               (x0 (if lab (+ lx (text-width lab s) (* 4 s)) lx)) (fw (- rx x0 s (if (plusp kw) (+ kw (* 3 s)) 0)))
               (n *konpaku-max*) (r4 (* 4 s)) (rf (/ (%fs fw) (* 2.4f0 (%fs n))))
               (rfix (<= (%fs r4) rf))                    ; R = (MIN (* 4 S) (/ FW (* 2.4 N))): the fixnum (first on a tie)
               (r (if rfix (%fs r4) rf))
               (pitch (if rfix                            ; (MIN 4.5 (/ FW (* N R))): a ratio when R is the fixnum
                          (if (< (* 2 fw) (* 9 n r4)) (%q->f fw (* n r4)) 4.5f0)
                          (f-min 4.5f0 (/ (%fs fw) (* (%fs n) rf))))))
          (declare (fixnum lx x0 fw n r4) (single-float rf r pitch))
          (when lab
            (%hud-text lab (%fs lx) (+ y (%fs (* 7 ns)) (%fs (* -7 s))) s
                       (cond ((gauges-evolution g) (alpha! *c-evo* (%hud-pulse 3f0))) ((eq lab (svref kh 2)) *u-tag*)
                             (t '(1 0.62 0.3 0.95)))))
          (%hud-pips x0 (+ y (%fs (* 7 ns)) (* 1.5f0 (%fs s)) (* -0.85f0 r)) fw r side (gauges-konpaku g)
                     nil red tm pitch (at-stake e) (bind-grey-souls e))
          (hud-kosei side (gauges-gg g) (%fs (- rx s)) (+ y (* 3.5f0 (%fs ns))) nil (+ (%fs m) (* 0.1f0 (%fs bw)))
                     (+ yb (* 0.5f0 (%fs bar))) s 7)))
      ;; Reishi + trail, the guard gauge
      (%trail! side frac 0.35f0)
      (%hud-reishi m ry bw bh frac (aref *trail-v* side) nil red tm (the single-float (bind-grey-frac e)))
      (let* ((gf (/ (the single-float (gauges-gg g)) (the single-float *gg-max*))) (ti (+ 2 side)))
        (declare (single-float gf) (fixnum ti))
        (%trail! ti gf 0.5f0)
        (%hud-guard m gy bw (* 2 s) gf (aref *trail-v* ti) nil (gauges-guardless g) (guard-gauge-bits e f gf) tm)
        (let ((hk (kit-hook kit :hud-guard))) (when hk (funcall hk e m gy bw (* 2 s) nil s tm))))
      ;; the small gauges (the last row, as long as the Reishi bar): Reiatsu cells, flash step, Awakening, the kit meter /
      ;; cooldowns
      (let* ((x0 m) (a bw) (gap (* 3 s)) (cd (and (kit-awakening kit) (kit-command-move kit :sig)
                                                  (plusp (mv-cooldown (kit-command-move kit :sig)))))
             (kitp (or (getf meter :draw) cd (and meter (not (kit-awakening kit)))))
             (n (if kitp 4 3)) (an (- a (* (1- n) gap)))    ; a gauge's width GW = AN / N, a Reiatsu cell's (GW - 2 S) / 3:
             (gwf (%q->f an n)) (swf (%q->f (- an (* 2 s n)) (* 3 n)))   ; exact ratios, as F32 converts them (%Q->F)
             (hot (or (gauges-evolution g) (kit-awakening kit)))
             (afill (the single-float (awaken-fill g kit))))
        (declare (fixnum x0 a gap n an) (single-float gwf swf afill))
        (%hud-reiatsu x0 yb swf bar s (reiatsu-of e) nil)
        (let ((tl (pool-tally (reiatsu-of e)))) (when tl (%hud-text tl (%fs (+ x0 s)) (- yb (%fs s)) s '(0.45 0.8 1 0.9))))   ; a bind's pool
        (%hud-flash (%q->f (+ (* x0 n) an (* gap n)) n) yb gwf bar      ; (+ X0 GW GAP)
                    (/ (the single-float (gauges-fs g)) (the single-float *fs-max*)) nil (burst-ok-p e) (gauges-burst g) tm)
        (%hud-thin (%q->f (+ (* x0 n) (* 2 (+ an (* gap n)))) n) yb gwf bar afill nil 1f0 (if hot 0.85f0 0.75f0) 0.3f0   ; (* 2 (+ GW GAP))
                   (if hot 0.6f0 1f0) (if hot 4f0 0f0) tm)
        (when kitp
          (let ((kx (%q->f (+ (* x0 n) (* 3 (+ an (* gap n)))) n)))   ; (+ X0 (* 3 (+ GW GAP)))
            (declare (single-float kx))
            (cond ((getf meter :draw)                    ; its own meter: the exact ratios, as the generic code passed them
                   (let ((gw (/ an n))) (funcall (getf meter :draw) e kit (+ x0 (* 3 (+ gw gap))) yb gw bar nil tm nil nil nil)))
                  (cd (hud-cooldowns f kit kx yb gwf bar nil tm))   ; (it takes F32 of each)
                  (t (let ((burning (plusp (gauges-form-left g))))
                       (%hud-thin kx yb gwf bar
                                  (f32 (if burning (timer-fill (gauges-form-left g) (gauges-form-total g) 1.0) (/ (gauges-meter g) (getf meter :max))))
                                  nil 1f0 (if burning 0.4f0 0.45f0) (if burning 0.1f0 0.12f0) (if burning 0.7f0 1f0) (if burning 5f0 0f0) tm)))))))
      ;; the combo counter (this side is the victim): under P2's block, over P1's
      (let ((c (svref *combo-show* side)) (bh2 (portrait-block-h s)))
        (declare (fixnum bh2))
        (when (and (> (fighter-combo-hits f) (if (eq *mode* :practice) 0 1)) (plusp (fighter-combo-dmg f)))
          (combo-string c (fighter-combo-hits f) (fighter-combo-dmg f)))
        (when (or (< (- tm (the single-float (cs-t0 c))) 1.2f0) (eq *mode* :practice))   ; PRACTICE: the last combo stays up
          (%hud-text (cs-str c) (%fs m) (if top (+ y (%fs bh2) (%fs (* 2 s))) (- y (%fs (* 16 s)))) (* 2 s) '(1 0.9 0.6 1)))
        (let ((o (* 4 side)) (pb *panel-box*))           ; the block's box (+ the combo counter's lane)
          (declare (fixnum o) (type f32vec pb))
          (setf (aref pb o) 0f0 (aref pb (+ o 2)) (%fs w)
                (aref pb (+ o 1)) (if top 0f0 (- y (%fs (* 16 s)))) (aref pb (+ o 3)) (if top (+ y (%fs bh2) (%fs (* 16 s))) (%fs h)))))
      ;; KIKON / BURST prompts for a human: centred under P2's block (clear of the thumb and of the fighters' heads' lane)
      (when (and (not (brain e)) (member *flow* '(:battle)))
        (macrolet ((prompt (str col)
                     `(let* ((str ,str) (k (fit-scale str (* 2 s) (* 0.94 w))))
                        (%hud-text str (* 0.5f0 (%fs w)) (+ (the single-float (portrait-hud-bottom s)) (%fs (* 17 s))) k ,col
                                   :align :center))))
          (cond ((bankai-ready-p e)
                 (let ((bp (getf meter :bankai-prompt)))   ; (a form's meter may rename it: its :bankai-prompt)
                   (prompt (if *one-hand* (getf bp :one-hand "AWAKEN  BANKAI")
                               (if (pad-connected-p side) (getf bp :pad "BACK  BANKAI") (getf bp :key "P  BANKAI")))
                           (alpha! (or (getf bp :rgb) *c-blood*) (%palpha 4f0)))))
                ((kikon-ready-p e)
                 (prompt (if *one-hand* "HOLD O  KIKON" (key-prompt *bind-pair* side (if (pad-connected-p side) :pad :key) :kikon))
                         (alpha! *c-kikon* (%palpha 4f0))))
                ((member (burst-ok-p e) '(:blue :orange))
                 (prompt (burst-prompt (burst-ok-p e) (cond (*one-hand* :flick) ((pad-connected-p side) :pad) (t :key)) side)
                         (alpha! (burst-color (burst-ok-p e)) (%palpha 4f0))))))))
    nil))

;;; ---------------------------------------------------------------- over the fighters
(defvar *callout-box* (vector nil 0 0 0 0) "The callout drawn first this frame: #(drawn x0 y0 x1 y1).")

(defun boxes-overlap-p (ax0 ay0 ax1 ay1 bx0 by0 bx1 by1)
  (and (< ax0 bx1) (< bx0 ax1) (< ay0 by1) (< by0 ay1)))

(defun callout-y (x0 y0 x1 y1 w h s)
  "Top edge for a callout box (X0 Y0 X1 Y1) that steps out of the big words' boxes and the other
callout: above the box it hits, or below it when above would reach the side panels; last, below a HUD
side panel it would overlap (*PANEL-BOX*; Phase 5)."
  (let ((th (- y1 y0)) (gap (* 4 s)))
    (flet ((dodge (bx0 by0 bx1 by1)
             (when (boxes-overlap-p x0 y0 x1 y1 bx0 by0 bx1 by1)
               (let ((up (- by0 gap th)))
                 (setf y0 (if (>= up (* 0.22 h)) up (+ by1 gap)) y1 (+ y0 th))))))
      (dolist (wd *words*)
        (multiple-value-bind (bx0 by0 bx1 by1) (word-box wd w h) (dodge bx0 by0 bx1 by1)))
      (let ((cb *callout-box*))
        (when (svref cb 0) (dodge (svref cb 1) (svref cb 2) (svref cb 3) (svref cb 4))))
      (let ((pb *panel-box*))
        (dotimes (i 2)
          (let ((o (* 4 i)))
            (when (boxes-overlap-p x0 y0 x1 y1 (aref pb o) (aref pb (+ o 1)) (aref pb (+ o 2)) (aref pb (+ o 3)))
              (if (> (aref pb (+ o 1)) 0f0)                  ; a panel at the bottom (portrait P1): above it
                  (setf y0 (- (aref pb (+ o 1)) gap th) y1 (+ y0 th))
                  (setf y0 (+ (aref pb (+ o 3)) gap) y1 (+ y0 th))))))))
    y0))

(defvar *callout-seen* (vector nil nil 0 0) "Per side: the callout string last seen and its frames left then.")
(defvar *side-caps* (vector nil nil) "Per side: the brush callout (a BCAP, brush.lisp *BRUSH-CALLOUTS*) or NIL.")

(defun side-cap (e)
  "Fighter E's brush callout: a new callout (a new string, or its frames reset) of a move with a brush name
(*BRUSH-CALLOUTS*) starts one at his side of the screen; T while it is shown (the pixel callout then stays off)."
  (let* ((f (fighter e)) (side (fighter-side f)) (seen *callout-seen*) (str (fighter-callout f)) (ct (fighter-callout-t f)))
    (when (and str (> ct 0) (or (not (eq str (svref seen side))) (> ct (svref seen (+ 2 side)))))
      (let ((entry (and (fighter-move f) (assoc (mv-name (fighter-move f)) *brush-callouts*))))
        (setf (svref *side-caps* side)
              (and entry (destructuring-bind (kanji reading mark) (rest entry)
                           (make-bcap kanji :reading reading :mark mark :layout :callout :side side :secs 1.3))))))
    (setf (svref seen side) str (svref seen (+ 2 side)) ct)
    (let ((c (svref *side-caps* side)))
      (and c (or (draw-bcap c (window-width) (window-height)) (setf (svref *side-caps* side) nil))))))

(defun-fast hud-world (e w h s)
  "Over fighter E in the world: his move-name callout (or its brush column at his side); the red soul flame
when he is red. (TOP in a single float; the callout's layout stays generic.)"
  (let* ((f (fighter e)) (g (gauges e)) (p (pos-of e)) (v *hud-v*)
         (top (+ (aref p 1) (the single-float (body-hurt-h (model-body (model e)))) 0.5f0)))
    (declare (type f32vec p v) (single-float top))
    (when (and (not (side-cap e)) (> (fighter-callout-t f) 0) (fighter-callout f)
               (world-to-screen v (aref p 0) (+ top 0.3) (aref p 2)))
      (let* ((str (fighter-callout f)) (pt (portrait-p))   ; portrait: smaller, and kept on the screen
             (em (if pt (min (* 0.03 h) (/ (* 0.94 w) (line-width str))) (* 0.045 h)))
             (tw (round (* em (line-width str)))) (th (round (* 0.8 em)))
             (x0 (if pt
                     (round (max (* 0.03 w) (min (- (* 0.97 w) tw) (- (aref v 0) (* 0.5 tw)))))
                     (round (- (aref v 0) (* 0.5 tw)))))
             (y0 (callout-y x0 (round (aref v 1)) (+ x0 tw) (+ (round (aref v 1)) th) w h s))
             (cb *callout-box*))
        (setf (svref cb 0) t (svref cb 1) x0 (svref cb 2) (round y0) (svref cb 3) (+ x0 tw) (svref cb 4) (+ (round y0) th))
        (hud-over-panel "callout" str x0 y0 (+ x0 tw) (+ y0 th) w h)
        (brush-text str (+ x0 (* 0.5 tw)) (+ y0 (* 0.5 th)) em *c-callout* (min 1.0 (/ (fighter-callout-t f) 20.0)))))
    (when (gauges-red-p g)
      (vfx-soul-flame (aref p 0) top (aref p 2) (fx-clock)))))

(defvar *c-auto* (list 1.0 0.72 0.3 1.0) "ASSIST's AUTO tag.")

(defun hud-hint (e h)
  "PERFECT HINT (SETTINGS, the user 2026-10-01): HOHO! at human fighter E's head while a Hoho started now would be
perfect (PERFECT-UP-P: a free state, the Hoho affordable, PERFECT-NOW-P). ASSIST: AUTO at his feet for *ASSIST-TAG-FRAMES*
after the assist pressed for him."
  (let ((p (pos-of e)) (v *hud-v*))
    (when (and (plusp (svref *assist-tag* (fighter-side (fighter e))))
               (world-to-screen v (aref p 0) (- (aref p 1) 0.25) (aref p 2)))   ; at his feet (move callouts own the space over heads)
      (brush-text "AUTO" (aref v 0) (aref v 1) (* (if (portrait-p) 0.03 0.038) h) *c-auto*))
    (when (and (= 1 (setting :hint)) (not (cpu-p e)) (perfect-up-p e (state-of e))
               (world-to-screen v (aref p 0) (+ (aref p 1) (body-hurt-h (model-body (model e))) 0.15) (aref p 2)))
      (brush-text "HOHO!" (aref v 0) (aref v 1) (* (if (portrait-p) 0.035 0.045) h) *c-hint*))))

(defvar *timer-strings* (make-array 1000 :initial-element nil) "Seconds -> their string, made once.")

(declaim (type f32vec *hud-v2*))
(defvar *hud-v2* (make-f32 3))

(defun hud-rush-lines (e)
  "Speed lines along a Kikon rush's dash-in (RUSH-DASHING-P in its :follow phase), on the screen direction
from the rusher to his victim; and along Kenpachi's SP2 dash (§4.2 SP2 dash, Phase 5: its active frames), on his
facing."
  (let* ((f (fighter e)) (mv (fighter-move f))
         (charge (and mv (eq (fighter-state f) :move) (eq (mv-name mv) :ke-charge) (eq (fighter-phase f) :main)
                      (<= (mv-s mv) (fighter-sf f) (+ (mv-s mv) (mv-a mv) -1)))))
    (when (or charge (and (eq (fighter-state f) :move) (eq (fighter-phase f) :follow) (rush-dashing-p f)))
      (let ((p (pos-of e)) (a *hud-v*) (b *hud-v2*))
        (when (and (world-to-screen a (aref p 0) 1f0 (aref p 2))
                   (if charge
                       (world-to-screen b (f32 (+ (aref p 0) (* 2 (fwd-x (yaw-of e))))) 1f0 (f32 (+ (aref p 2) (* 2 (fwd-z (yaw-of e))))))
                       (world-to-screen b (fighter-ox f) 1f0 (fighter-oz f))))
          (ui-speed-lines (f32 (atan (- (aref b 1) (aref a 1)) (- (aref b 0) (aref a 0)))) 14 '(1 1 1 0.55)
                          (f->i (* 12f0 (fx-clock)))))))))

(defun hud-battle (w h s)
  (setf (svref *callout-box* 0) nil)
  (do-sides (e) (when (entity-alive-p e) (hud-rush-lines e)))
  (do-sides (e)                                                                   ; both panels first: the callouts
    (when (entity-alive-p e) (if (portrait-p) (hud-side-portrait e w h s) (hud-side e w h s))))
  (do-sides (e) (when (entity-alive-p e) (hud-world e w h s) (hud-hint e h)))  ; keep clear of them
  (when (eq *mode* :endless) (hud-endless-tag w h s))    ; STAGE n (endless.lisp)
  (when (eq *mode* :practice)                            ; no timer: PRACTICE's tag in its place (landscape)
    (unless (portrait-p) (hud-text "PRACTICE" (floor w 2) (* 0.06 h) (* 2 s) *dim* :align :center))
    (return-from hud-battle))
  (let* ((secs (min 999 (ceiling (max 0 *timer*) 60)))
         (str (or (svref *timer-strings* secs) (setf (svref *timer-strings* secs) (format nil "~d" secs)))))
    (if (portrait-p)                                     ; portrait: the right end of P2's name row
        (let ((k (round (* 1.4 s))))
          (ui-big-text str (- w (* 4 s) (* 8.5 k)) (+ (portrait-top-px s) (* 3.5 k)) k
                       (if (< secs 30) '(1 0.3 0.3 1) *white*) '(0 0 0 0.7) (ceiling s 2) :shear 0.0))
        (ui-big-text str (floor w 2) (* 0.07 h) (* 4 s)
                     (if (< secs 30) '(1 0.3 0.3 1) *white*) '(0 0 0 0.7) s :shear 0.0))))
