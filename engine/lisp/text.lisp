;;;; text.lisp — text layout on the paint stream's SDF runs (docs/duel/DUEL_LISP_HUD.md §4.2, phase 1c): aligned runs, wrapped
;;;; paragraphs (LAYOUT.LISP's WRAP-LINES: CJK between any two characters, Latin at spaces, kinsoku) whose line breaks are cached
;;;; per string (EQ) / face / width / spacing, vertical columns (writing-mode: vertical-rl: CJK upright, Latin turned 90 degrees
;;;; clockwise), tabular digits (font-variant-numeric: tabular-nums) and the CSS line box's baseline. A face's missing glyph falls back
;;;; as in GLYPH-FIND (the sans, then the Mincho, then □), on the same baseline, as the browser does; a line of several faces is the
;;;; pen run through PAINT-TEXT once per face. 0 B per frame: a cached paragraph or a run draws without allocating; the cache
;;;; allocates only when a string, its face, width or spacing changes (and is cleared when it holds *TEXT-CACHE-MAX* strings).
;;;; Float inputs go through the pen (*PAINT-PEN*) and *TEXT-IO* (macros), as in paint.lisp. Every glyph goes through paint.lisp's
;;;; %GLYPH-QUAD: the transform / opacity stack (paint-shapes.lisp), the scissor, the pen's outline band and the halftone dots.
(in-package :engine)

(declaim (type f32vec *text-io* *tab-adv*))
(defvar *text-io* (make-f32 4) "The text macros' float lane: [0] the wrap width (px), [1] the line height (ratio), [2] the alignment, [3] the wrap width (em).")
(defvar *tab-adv* (make-array 8 :element-type 'single-float :initial-element -1f0)
  "Per face and tier (tier * 4 + face): the widest digit's advance (em), the tabular cell; -1 until first asked.")

(defmacro line-baseline (face size lh)
  "The baseline's depth in a CSS line box of line-height LH (a ratio) for SIZE px of FACE: half-leading + ascent."
  `(let ((%sz ,size) (%asc (face-ascent ,face)) (%dsc (face-descent ,face)))
     (declare (single-float %sz %asc %dsc))
     (+ (* 0.5f0 %sz (- ,lh (+ %asc %dsc))) (* %asc %sz))))

;;; ---------------------------------------------------------------- aligned runs, tabular digits
(defun-fast %paint-aligned (s face col align)
  (declare (simple-string s) (fixnum face align) (type f32vec col))
  (let ((p *paint-pen*))
    (declare (type f32vec p))
    (when (> align 0)
      (%paint-run s face col nil 0 -1)
      (decf (aref p 0) (if (= align 1) (* 0.5f0 (aref p 7)) (aref p 7))))
    (%paint-run s face col t 0 -1)
    nil))
(defmacro paint-text-aligned (s face col align)
  "Draw S with the pen's x at its start (ALIGN :start), centre (:center) or end (:end) (text-align); the pen advances."
  `(%paint-aligned ,s ,face ,col ,(ecase align (:start 0) (:center 1) (:end 2))))

(defun-fast %tab-fill (face big)
  "Fill *TAB-ADV* for FACE in the tier BIG picks: the widest advance of 0-9 (em)."
  (declare (fixnum face))
  (let ((w 0f0))
    (declare (single-float w))
    (dotimes (d 10)
      (let ((gi (glyph-find face (+ 48 d) big)))
        (declare (fixnum gi))
        (when (>= gi 0) (let ((a (aref *glyph-f* (+ 8 (* 9 gi))))) (declare (single-float a)) (when (> a w) (setf w a))))))
    (setf (aref *tab-adv* (+ face (if big 4 0))) w)
    nil))
(defmacro tab-cell (face big)
  "The tabular cell of FACE (em): the widest of 0-9 in the tier BIG picks (filled on first use)."
  `(let ((%k (+ ,face (if ,big 4 0))))
     (declare (fixnum %k))
     (when (< (aref *tab-adv* %k) 0f0) (%tab-fill ,face ,big))
     (aref *tab-adv* %k)))

(defun-fast %paint-int-tab (n face col digits draw)
  "PAINT-INT-TAB / its measure: N's decimal digits, zero-padded to DIGITS, each centred in the tabular cell (0 B, no string)."
  (declare (fixnum n face digits) (type f32vec col))
  (let* ((p *paint-pen*) (size (aref p 2)) (big (> size +big-px+)) (cell (+ (* size (tab-cell face big)) (* size (aref p 3))))
         (m (abs n)) (div 1) (nd 1) (x0 (aref p 0)))
    (declare (type f32vec p) (single-float size cell x0) (fixnum m div nd))
    (loop while (>= m (* div 10)) do (setf div (* div 10)) (incf nd))
    (loop while (< nd digits) do (setf div (* div 10)) (incf nd))
    (if (not draw)
        (setf (aref p 7) (* cell (i->f* nd)))
        (loop while (>= div 1)
              do (let* ((s (svref *digit-strs* (mod (floor m div) 10))) (x (aref p 0)))
                   (declare (single-float x))
                   (%paint-run s face col nil 0 -1)
                   (setf (aref p 0) (+ x (* 0.5f0 (- cell (aref p 7)))))
                   (%paint-run s face col t 0 -1)
                   (setf (aref p 0) (+ x cell) div (floor div 10)))))
    (unless draw (setf (aref p 0) x0))
    nil))
(defun paint-int-tab (n face col &optional (digits 1))
  "Draw the integer N in FACE at the pen in tabular figures (each digit centred in the widest digit's cell), zero-padded to DIGITS:
a clock that ticks without its digits shifting. The pen advances."
  (%paint-int-tab n face col digits t))
(defun paint-measure-int-tab (n face &optional (digits 1)) "The advance of PAINT-INT-TAB, into pen [7]." (%paint-int-tab n face *paint-q4* digits nil))

;;; ---------------------------------------------------------------- wrapped paragraphs (the line-break cache)
(defparameter *text-cache-max* 256 "Strings the paragraph cache holds before it starts over.")
(defvar *text-cache* (make-hash-table :test #'eq) "String -> its laid-out lines (TEXT-LAYOUT), EQ: a model string is stable until it changes.")

(defun-fast text-layout (s face)
  "S's lines in FACE when wrapped at *TEXT-IO* [3] em (<= 0: no wrap) with the pen's letter spacing (em): a simple-vector #(face
width-em spacing breaks widths) where BREAKS is WRAP-LINES's start / end pairs and WIDTHS each line's advance (em). Cached (EQ on S;
remade when the face, width or spacing changed)."
  (declare (simple-string s) (fixnum face))
  (let ((e (gethash s *text-cache*)) (w (aref *text-io* 3)) (sp (aref *paint-pen* 3)))
    (declare (single-float w sp))
    (if (and e (eql (svref e 0) face) (= (the single-float (svref e 1)) w) (= (the single-float (svref e 2)) sp))
        e
        (let* ((n (length s)) (codes (make-array n :element-type 'fixnum)) (adv (make-f32 n)))
          (dotimes (i n)
            (let* ((c (char-code (char s i))) (gi (glyph-find face c nil)))
              (setf (aref codes i) c (aref adv i) (if (>= gi 0) (+ (aref *glyph-f* (+ 8 (* 9 gi))) sp) 0f0))))
          (let* ((br (wrap-lines codes adv n (if (> w 0f0) w 1f30))) (nl (floor (length br) 2)) (ws (make-f32 nl)))
            (dotimes (l nl) (setf (aref ws l) (loop for i from (aref br (* 2 l)) below (aref br (1+ (* 2 l))) sum (aref adv i) of-type single-float)))
            (when (>= (hash-table-count *text-cache*) *text-cache-max*) (clrhash *text-cache*))
            (setf (gethash s *text-cache*) (vector face w sp br ws)))))))

(defun-fast %paint-paragraph (s face col)
  "Body of PAINT-PARAGRAPH: the cached lines of S drawn from the pen (x = the box's left, y = its top) a line height apart."
  (declare (simple-string s) (fixnum face) (type f32vec col))
  (let* ((p *paint-pen*) (io *text-io*) (size (aref p 2)) (x0 (aref p 0)) (top (aref p 1)) (width (aref io 0)) (lh (aref io 1))
         (align (aref io 2)) (lay (progn (setf (aref io 3) (if (> width 0f0) (/ width size) 0f0)) (text-layout s face)))
         (br (svref lay 3)) (ws (svref lay 4)) (base (+ top (line-baseline face size lh))))
    (declare (type f32vec p io ws) (type (simple-array fixnum (*)) br) (single-float size x0 top width lh align base))
    (dotimes (l (length ws))
      (setf (aref p 0) (+ x0 (* align (- width (* size (aref ws l))))) (aref p 1) (+ base (* lh size (i->f* l))))
      (%paint-run s face col t (aref br (* 2 l)) (aref br (1+ (* 2 l)))))
    (setf (aref p 0) x0 (aref p 1) top (aref p 7) (* lh size (i->f* (length ws))))
    nil))
(defmacro paint-paragraph (s face col &key (width 0f0) (lh 1.5f0) (align :start))
  "Draw S in FACE as a block: the pen's x / y = the box's left / top, WIDTH px to wrap at (0: no wrap; newlines always break),
line-height LH, text-align ALIGN (:start :center :end) inside WIDTH. Pen [7] := the block's height. 0 B once laid out."
  `(progn (%f32-set *text-io* ,width ,lh ,(ecase align (:start 0f0) (:center 0.5f0) (:end 1f0)))
          (%paint-paragraph ,s ,face ,col)))

;;; ---------------------------------------------------------------- vertical columns (writing-mode: vertical-rl)
(defun-fast %paint-vertical (s face col)
  "Body of PAINT-VERTICAL."
  (declare (simple-string s) (fixnum face) (type f32vec col))
  (let* ((p *paint-pen*) (gf *glyph-f*) (xc (aref p 0)) (y (aref p 1)) (size (aref p 2)) (ls (* size (aref p 3))) (edge0 (aref p 4))
         (big (> size +big-px+)) (asc (face-ascent face)) (dsc (face-descent face)) (y0 y)
         (r (aref col 0)) (g (aref col 1)) (b (aref col 2)) (a (aref col 3)))
    (declare (type f32vec p gf) (single-float xc y size ls edge0 asc dsc y0 r g b a))
    (with-small-text (grow soft) size (aref p 5)
      (dotimes (i (length s))
        (let* ((c (char-code (char s i))) (gi (glyph-find face c big)) (up (wide-char-p c)))
          (declare (fixnum c gi))
          (when (>= gi 0)
            (let* ((o (* 9 gi)) (edge (glyph-edge edge0 grow gi)) (adv (* size (aref gf (+ o 8))))
                   (gl (* size (aref gf (+ o 4)))) (gt (* size (aref gf (+ o 5)))) (gw (* size (aref gf (+ o 6)))) (gh (* size (aref gf (+ o 7))))
                   (u0 (aref gf o)) (v0 (aref gf (+ o 1))) (u1 (aref gf (+ o 2))) (v1 (aref gf (+ o 3))))
              (declare (fixnum o) (single-float edge adv gl gt gw gh u0 v0 u1 v1))
              (when (> gw 0f0)
                (if up
                    ;; upright: the ideographic em box (0.88 em over the baseline: the CJK faces' typo ascender, where their
                    ;; vmtx puts the vertical origin, as Chrome does) is the column's next em, centred on XC
                    (let* ((gx0 (+ (- xc (* 0.5f0 adv)) gl)) (base (+ y (* size 0.88f0))) (gy0 (- base gt)))
                      (declare (single-float gx0 base gy0))
                      (%glyph-quad gx0 gy0 (+ gx0 gw) (+ gy0 gh) u0 v0 u1 v1 0f0 0f0 nil))
                    ;; sideways: turned 90 degrees clockwise (local (lx along the advance, ly down) -> (bx - ly, y + lx)), the em
                    ;; box centred on XC
                    (let ((bx (- xc (* 0.5f0 size (- asc dsc)))))   ; the baseline's x
                      (declare (single-float bx))
                      (%glyph-quad (- bx (- gh gt)) (+ y gl) (+ bx gt) (+ y gl gw) u0 v0 u1 v1 0f0 0f0 t))))
              (setf y (+ y (if up size adv) ls)))))))
    (setf (aref p 7) (- y y0) (aref p 1) y)
    nil))
(defun paint-vertical (s face col)
  "Draw S down a column (writing-mode: vertical-rl): the pen's x = the column's centre, y = its top; CJK and kana upright one em
apart, other characters turned 90 degrees clockwise by their advance; letter spacing between. The pen's y advances; pen [7] := the
column's length."
  (%paint-vertical s face col))
(defun-fast paint-measure-vertical (s face)
  "The length of S's column at the pen's size and spacing, into pen [7]."
  (declare (simple-string s) (fixnum face))
  (let* ((p *paint-pen*) (size (aref p 2)) (big (> size +big-px+)) (len 0f0))
    (declare (type f32vec p) (single-float size len))
    (dotimes (i (length s))
      (let* ((c (char-code (char s i))) (gi (glyph-find face c big)))
        (declare (fixnum c gi))
        (when (>= gi 0) (incf len (+ (if (wide-char-p c) size (* size (aref *glyph-f* (+ 8 (* 9 gi))))) (* size (aref p 3)))))))
    (setf (aref p 7) len)
    nil))
