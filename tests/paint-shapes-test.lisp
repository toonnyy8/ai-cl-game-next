;;;; Host-side checks for engine/lisp/paint-shapes.lisp's PATH-POINTS (the SVG path flattener; the emitters need the wasm build's
;;;; FFI and are checked by debug 2509's card and 2519's probe):
;;;;   $ECL_HOST --norc --load engine/lisp/package.lisp --load engine/lisp/math.lisp --load tests/paint-shapes-test.lisp
(in-package :engine)

(defvar *hud-batch* nil) (defvar *hud-back* nil) (defvar *input* (make-f32 16))   ; (render.lisp / input.lisp's, not loaded here)
(load (merge-pathnames "../engine/lisp/paint.lisp" *load-truename*))
(load (merge-pathnames "../engine/lisp/paint-shapes.lisp" *load-truename*))

(defvar *fails* 0)
(defmacro check (form expect &optional (eps 1e-3))
  `(let ((got ,form) (want ,expect))
     (unless (and (= (length got) (length want)) (every (lambda (a b) (< (abs (- a b)) ,eps)) got want))
       (incf *fails*) (format t "~&FAIL: ~s~%   got ~s~%  want ~s~%" ',form got want))))

(check (path-points "M0 0L10 0 10 10z") #(0 0 10 0 10 10))                       ; implicit L, the closing point dropped
(check (path-points "m1 1h4v2l-1 1z") #(1 1 5 1 5 3 4 4))                         ; relative m h v l
(check (path-points "M0 0C0 10 10 10 10 0" :segs 2) #(0 0 5 7.5 10 0))            ; a cubic's midpoint
(check (path-points "M1-2.5.5.5" ) #(1 -2.5 0.5 0.5))                             ; numbers run together: "-2.5" ".5" ".5"
(check (path-points "M9.2 8.6A4.2 4.2 0 0 1 .8 8.6" :segs 2) #(9.2 8.6 5 12.8 0.8 8.6))   ; SVG sweep 1: through the bottom (y down)
(check (path-points "M9.2 8.6A4.2 4.2 0 0 0 .8 8.6" :segs 2) #(9.2 8.6 5 4.4 0.8 8.6))    ; sweep 0: through the top
(check (path-points "M0 0L4 0 4 4ZM9 9L10 10") #(0 0 4 0 4 4))                    ; only the first subpath
(check (let ((v (path-points "M5 .6C6.4 3 9.2 5.4 9.2 8.6A4.2 4.2 0 0 1 .8 8.6C.8 6.6 2.2 5.2 3 3.6 3.4 5 4 5.6 4.8 5.8 4.4 4 4.6 2.2 5 .6z" :segs 5)))
         (vector (length v) (aref v 0) (aref v 1)))
       #(50 5 0.6))                                                               ; hud.js SOUL: 25 points (1 + 5 x 5 - 1) from its tip

;; paint.lisp's GLYPH-FIND: the display face's display tier is upper case only (tools/sdf-bake.py), so a-z above +BIG-PX+ draw as
;; A-Z; the body tier keeps its lower case; another face's display tier is not touched (a table of three glyphs, sorted keys)
(let ((*glyph-keys* (make-array 3 :element-type 'fixnum
                                  :initial-contents (list (+ (* 0 65536) 97) (+ (* 4 65536) 65) (+ (* 6 65536) 97)))))
  (check (vector (glyph-find 0 97 t) (glyph-find 0 97 nil) (glyph-find 0 65 t) (glyph-find 2 97 t)) #(1 0 1 2)))

(format t "~&paint-shapes-test: ~:[ALL PASS~;~:*~d FAIL~]~%" (and (plusp *fails*) *fails*))
(ext:quit (if (zerop *fails*) 0 1))
