;;;; hud.lisp — what the canvas UI stream still draws in a battle and around it (the HUD and the menus are the Lisp HUD's,
;;;; lhud-*.lisp, DUEL_LISP_HUD §16; the canvas battle HUD, its plates and gauges, left 2026-11-11): the big words (ANNOUNCE), the
;;;; world overlays (Kikon rush speed lines, the red soul flame over a Kikon-able fighter, PERFECT HINT's HOHO! and ASSIST's AUTO),
;;;; the canvas text helpers the frozen modes' screens use (HUD-TEXT; endless.lisp, rogue.lisp, hud-screens.lisp's ENDLESS SELECT),
;;;; the portrait block geometry the one-hand deck and those screens lay out by, and the refused-L clock the retired kits' meters read.
;;;; Cosmetic only: the fx clock (it stops while paused), RND01.
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

;;; DEFUN-FAST callers (the model, webhud.lisp; the stick ring): ROUND of a single float on unboxed floats.
(defmacro %hround (x) "(ROUND X) of a single float, 0 B: lrintf (nearest, ties to even, as ROUND; ROUND conses its remainder)."
  `(ffi:c-inline (,x) (:float) :int "lrintf(#0)" :one-liner t))

;;; ---------------------------------------------------------------- big words
(defstruct (word (:constructor make-word (text sub color secs small side)))
  text sub color secs small side (t0 (fx-clock))
  (col (list 1.0 1.0 1.0 1.0)))
(inline-readers word)                                   ; its colour (r g b 1)
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
  "Log once per string that the WHAT (callout / word) STR at (X0 Y0 X1 Y1) overlaps a HUD panel (docs/research/style-history/style-5-checks.py
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

;;; ---------------------------------------------------------------- the Konpaku shatter, the refused L
(declaim (type f32vec *hud-v*))
(defvar *hud-v* (make-f32 3) "WORLD-TO-SCREEN's out lane for the world overlays.")

(defun pips-shatter (v lost)
  "LOST of V's Konpaku pips break: the glass burst in the world and its sound (the plate's flames are the Lisp HUD's)."
  (multiple-value-bind (x y z) (actor-point v 1.6) (vfx-konpaku-shatter x y z lost))
  (play-sfx :konpaku-shatter))

(declaim (type f32vec *refused-t*))
(defvar *refused-t* (make-f32 2) "Per side: FX-CLOCK of the last refused L press (its bar, or the cold gauge's cost, flashes).")
(defun refused-flash (side tm) "SIDE's refused-press flash at fx time TM: 1 at the press, 0 after 0.25 s." (f32 (max 0.0 (- 1.0 (* 4.0 (- tm (aref *refused-t* side)))))))

(defun hud-refused (e cmd)
  "E pressed CMD while it was cooling or short of cold (the :refused event): L's bar flashes."
  (when (eq cmd :sig) (setf (aref *refused-t* (fighter-side (fighter e))) (f32 (fx-clock)))))

;;; ---------------------------------------------------------------- portrait blocks (docs/duel/DUEL_MOBILE_DESIGN.md §4.2)
;;; The portrait screen's bands: the opponent's block across the top under the safe-area inset, the player's across the bottom
;;; over the home indicator, 29 S tall each. The one-hand deck (onehand.lisp DECK-LAYOUT) and the frozen modes' screens
;;; (endless.lisp, rogue.lisp) lay out by them.
(defvar *safe-top* 0 "The safe-area inset at the top, CSS px (onehand.lisp DECK-UPDATE; 0 off a notched phone).")
(defvar *safe-bot* 0 "The safe-area inset at the bottom (the home indicator), CSS px (DECK-UPDATE).")
(defun portrait-block-h (s) "A portrait HUD block's height, px." (* 29 s))
(defun portrait-top-px (s) "Top edge of P2's block, px." (+ (* *safe-top* (pixel-density)) (* 2 s)))
(defun portrait-hud-bottom (s) "Bottom of P2's block at the top, px." (+ (portrait-top-px s) (portrait-block-h s)))
(defun portrait-p1-top (s h) "Top edge of P1's block at the bottom, px (over the home indicator, at least 8 CSS px up)."
  (- h (* (max 8 (+ *safe-bot* 4)) (pixel-density)) (portrait-block-h s)))

;;; ---------------------------------------------------------------- over the fighters
(defun-fast hud-world (e)
  "Over fighter E in the world: the red soul flame while he is red (a Kikon on him is live)."
  (let* ((p (pos-of e)) (top (+ (aref p 1) (the single-float (body-hurt-h (model-body (model e)))) 0.5f0)))
    (declare (type f32vec p) (single-float top))
    (when (gauges-red-p (gauges e))
      (vfx-soul-flame (aref p 0) top (aref p 2) (fx-clock)))))

(defvar *c-auto* (list 1.0 0.72 0.3 1.0) "ASSIST's AUTO tag.")
(defvar *c-hint* (list 0.6 0.95 1.0 1.0) "PERFECT HINT's HOHO!.")

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
  "What the canvas draws in a battle under the Lisp HUD: the speed lines, the red soul flame, HOHO! / AUTO, ENDLESS's tag."
  (do-sides (e) (when (entity-alive-p e) (hud-rush-lines e) (hud-world e) (hud-hint e h)))
  (when (eq *mode* :endless) (hud-endless-tag w h s)))   ; STAGE n (endless.lisp, frozen)
