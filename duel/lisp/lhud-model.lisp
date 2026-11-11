;;;; lhud-model.lisp — the Lisp HUD's view of the model and its shared look (docs/duel/DUEL_LISP_HUD.md §4.8, §13). The model is what
;;;; webhud.lisp writes: *HUD-SENT* (V k, fixnums) and *HUD-STRS* (S i, strings, EQ-stable until they change);
;;;; the Lisp HUD reads nothing else of the game. Here: the accessors, the per-side derived strings (name, kanji, tag segments, seals,
;;;; the callout's kanji: remade by LHUD-MODEL-UPDATE only when a source string changed, the one place this file mutates), the palette
;;;; (hud.css / menu.css :root and the literal colours) and the SVG shapes flattened once. Cosmetic; 0 B a frame in steady state.
(in-package :duel)

(defmacro hv (k) "The model's value V K (webhud.lisp *HUD-SENT*: 30100 + K on the page)." `(aref (the (simple-array fixnum (*)) *hud-sent*) ,k))
(defmacro hstr (i) "The model's string S I (30220 + I on the page; NIL until set)." `(svref *hud-strs* ,i))
(defmacro side-o (side) "The side's offset in the model (50 + 30 side)." `(+ 50 (* 30 ,side)))
(defmacro hv-deck-p () "Is the phone's deck up (V0 bit 8)?" `(logtest (hv 0) 8))
(defmacro hv-left-p () "The left hand (V42)?" `(= 1 (hv 42)))
(defmacro hv-practice-p () "PRACTICE (V0 bit 16)?" `(logtest (hv 0) 16))

;;; ---------------------------------------------------------------- the per-side derived strings (component data + its system)
(defvar *lhud-side* (vector (make-array 10 :initial-element :none) (make-array 10 :initial-element :none))
  "Per side: [0] the plate label and [1] the tag they were made from, [2] the fighter entry (*LHUD-FIGHTERS*), [3] the name, [4] the
tag segments ((string . jade) ...), [5] the seals ((glyph name) ...), [6] the callout romaji seen, [7] its kanji or NIL, [8] the
kit strip's kind (LHUD-KIT-KIND), [9] the roster value they were made from.")

(defun lhud-model-update ()
  "Refresh each side's derived strings when the model's label, tag, roster or callout changed (EQ: the model's strings are stable
until they change; allocation only then)."
  (dotimes (side 2)
    (let* ((c (svref *lhud-side* side)) (o (side-o side)) (label (hstr (* 4 side))) (tag (hstr (1+ (* 4 side)))) (r (hv o))
           (rom (hstr (+ 2 (* 4 side)))))
      (unless (and (eq label (svref c 0)) (eq tag (svref c 1)) (eql r (svref c 9)))
        (let ((entry (lhud-fighter r)))
          (setf (svref c 0) label (svref c 1) tag (svref c 9) r (svref c 2) entry
                (svref c 3) (if entry (first entry) (lhud-label-name label))
                (svref c 4) (lhud-tag-segments label tag)
                (svref c 5) (lhud-seals entry (lhud-label-form label) tag)
                (svref c 8) (lhud-kit-kind tag))))
      (unless (eq rom (svref c 6))
        (setf (svref c 6) rom (svref c 7) (lhud-move-kanji rom)))))
  nil)

(defmacro side-c (side k) `(svref (svref *lhud-side* ,side) ,k))

;;; ---------------------------------------------------------------- the layers' fades (component data; LHUD-LAYERS-UPDATE, lhud-fx.lisp)
(declaim (type f32vec *lhud-lay-tr*))
(defvar *lhud-lay-tr* (make-transitions 4 1f0)
  "[0] .hudl's opacity (cinematic 0, paused .3), [1] the deck / 爆 / stance ring's (0 in a cinematic or paused), [2] the phone's clock
tab's (0 paused), [3] the canvas's paused grade (0..1, .5 s ease-out).")
(defmacro layer-op (k) `(trans-value *lhud-lay-tr* ,k (aref *ui-clock* 0)))


;;; ---------------------------------------------------------------- the look (hud.css, menu.css :root)
(defparameter +c-paper+ (rgba #xeeeeea)) (defparameter +c-steel+ (rgba #xbcc1cc)) (defparameter +c-stone+ (rgba #x767d8e))
(defparameter +c-blood+ (rgba #xe81e3a)) (defparameter +c-jade+ (rgba #x7fe3c2)) (defparameter +c-white+ (rgba #xffffff))
(defparameter +c-ink+ (rgba #x0b0b10)) (defparameter +c-night+ (rgba #x161922)) (defparameter +c-reiatsu+ (rgba #xffd83a))
(defparameter +c-slate+ (rgba #x2c303d))
(defparameter +c-burst-w+ (rgba #xf2f5ff)) (defparameter +c-burst-b+ (rgba #x66a8ff)) (defparameter +c-burst-o+ (rgba #xff942e))   ; the burst modes' colours (爆's ink, the burning cell)
(defparameter +c-shade+ (rgba #x000000 0.6))              ; the names' hard shadow
(defparameter +c-bar-bg+ (rgba #x0b0b10 0.48)) (defparameter +c-bar-line+ (rgba #xeeeeea 0.12))
(defparameter +c-fill-lo+ (rgba #xc9cbcf)) (defparameter +c-low-hi+ (rgba #xff6b7f))
(defparameter +c-grid+ (rgba #x0b0b10 (* 0.18 0.35)))     ; the Reishi grid: rgba(11,11,16,.18) at .35
(defparameter +c-slash+ (rgba #xe81e3a 0.9))
(defparameter +c-card+ (rgba #x0b0b10 1.0))
(defconstant +f-display+ 0) (defconstant +f-mono+ 1) (defconstant +f-kanji+ 2) (defconstant +f-sans+ 3)

(defmacro with-col ((var src) &body body)
  "VAR: the scratch colour *LHUD-COL* set to the colour SRC (an f32vec), for BODY to change (an alpha, a blend) without consing."
  `(let ((,var *lhud-col*)) (declare (type f32vec ,var)) (replace ,var ,src) ,@body))
(declaim (type f32vec *lhud-col* *lhud-mix* *lhud-mix2*))
(defvar *lhud-col* (make-f32 4) "WITH-COL's scratch colour (owned by the WITH-COL form that binds it, read at once).")
(defvar *lhud-mix* (make-f32 4) "A blend's out colour (COL-MIX!; the caller names it: read at once, before the next blend into it).")
(defvar *lhud-mix2* (make-f32 4) "A second out colour, for a call that takes two blends at once (爆's ink: its two gradient stops).")
(defmacro col-mix! (out a b k)
  "OUT := the colour A blended toward B by K (0..1, every channel and the alpha): a CSS colour transition; returns OUT. The caller
owns OUT (*LHUD-MIX*, or *LHUD-MIX2* for a second blend alive at the same time). Inline (a float argument to a function is boxed)."
  (let ((ga (gensym "A")) (gb (gensym "B")) (gk (gensym "K")) (go (gensym "O")))
    `(let* ((,go ,out) (,ga ,a) (,gb ,b) (,gk ,k))
       (declare (type f32vec ,ga ,gb ,go) (single-float ,gk))
       (dotimes (i 4) (setf (aref ,go i) (+ (aref ,ga i) (* ,gk (- (aref ,gb i) (aref ,ga i))))))
       ,go)))
(defmacro col-alpha! (col a) "COL's alpha set to A (on a scratch colour)." `(setf (aref ,col 3) ,a))

;;; ---------------------------------------------------------------- shapes from hud.js's SVG (flattened once, at load)
(defparameter +soul-path+ "M5 .6C6.4 3 9.2 5.4 9.2 8.6A4.2 4.2 0 0 1 .8 8.6C.8 6.6 2.2 5.2 3 3.6 3.4 5 4 5.6 4.8 5.8 4.4 4 4.6 2.2 5 .6z"
  "hud.js SOUL: the soul flame, viewBox 0 0 10 14.")
(defparameter +inf-path+ "M33 16 C26 5 9 3 6 14 C3 25 22 29 33 16 C44 3 63 6 60 17 C57 27 40 27 33 16"
  "hud.js INF: the practice clock's infinity, viewBox 0 0 66 32 (a stroke).")
(defun closed-points (v)
  "The f32vec V of points with its first point appended (a closed outline for PAINT-STROKE!)."
  (let ((o (make-f32 (+ 2 (length v))))) (replace o v) (setf (aref o (length v)) (aref v 0) (aref o (1+ (length v))) (aref v 1)) o))
(declaim (type f32vec *sh-flame* *sh-flame-o* *sh-inf*))
(defvar *sh-flame* (path-points +soul-path+ :segs 3) "The soul flame's outline as points: 2509's shapes card (the plates draw the baked glyph +SOUL-GLYPH+).")
(defvar *sh-flame-o* (closed-points *sh-flame*) "The same, closed (its stroke).")
(defparameter +soul-glyph+ (string (code-char #xE000))
  "The soul flame as one baked SDF glyph in the sans (tools/sdf-bake.py SHAPES: +SOUL-PATH+, its em = the viewBox's 14 units).")
(defvar *sh-inf* (path-points +inf-path+ :segs 8) "The infinity's stroke.")

;;; ---------------------------------------------------------------- small helpers of every view
(defmacro f-floor+ (x) "Round to the nearest whole device pixel (text origins: crisper small text)." `(ffi:c-inline (,x) (:float) :float "floorf(#0+0.5f)" :one-liner t))
(defmacro tw (k from to t0 dur now)
  "A CSS transition's value: FROM -> TO along curve K over DUR s from T0 (before T0: FROM)."
  `(let ((%tu (/ (- ,now ,t0) ,dur))) (declare (single-float %tu))
     (if (<= %tu 0f0) ,from (if (>= %tu 1f0) ,to (+ ,from (* (- ,to ,from) (ease ,k %tu)))))))
(defmacro twv (a start now prop)
  "TWEEN-VALUE typed single-float (inside arithmetic its LET's untyped result went through generic, boxing math)."
  `(the single-float (tween-value ,a ,start ,now ,prop)))
(defmacro text-w (s face size &optional (spacing 0f0))
  "The advance of the string S in FACE at SIZE px with letter SPACING (em), from the pen's measure (pen [7])."
  `(progn (paint-pen! 0f0 0f0 ,size :spacing ,spacing) (paint-measure ,s ,face) (aref *paint-pen* 7)))
(defmacro row-h (&rest items)
  "A flex row's height with align-items: baseline: ITEMS are (FACE SIZE LH) line boxes (CSS line-height LH). Returns the height and
leaves the baseline's depth from the row's top in *LHUD-ROW* [0] (no second value: 0 B)."
  (let ((as (loop repeat (length items) collect (gensym "A"))) (amax (gensym "AMAX")))
    (flet ((fmax (forms) (reduce (lambda (a b) `(f-max ,a ,b)) forms)))
      `(let* (,@(loop for a in as for (f s l) in items collect `(,a (line-baseline ,f ,s ,l)))
              (,amax ,(fmax as)))
         (declare (single-float ,@as ,amax))
         (setf (aref *lhud-row* 0) ,amax)
         (+ ,amax ,(fmax (loop for a in as for (nil s l) in items collect `(- (* ,s ,l) ,a))))))))
(declaim (type f32vec *lhud-row*))
(defvar *lhud-row* (make-f32 2) "ROW-H's out lane: [0] the baseline's depth from the row's top.")
