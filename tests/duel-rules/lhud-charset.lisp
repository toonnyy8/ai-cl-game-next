;; ================================================================ the Lisp HUD's baked text (docs/duel/DUEL_LISP_HUD.md §4.2, §9)
;; duel/hud-font/metrics.bin (tools/sdf-bake.py) must hold every character the HUD can show, in the face and tier it is drawn in:
;;  - ASCII 32-126 in the display, mono and sans faces' body tiers;
;;  - every (kj / bigkj / big / zh "...") string of duel/lisp/lhud-*.lisp at its own (face, tier);
;;  - every non-ASCII character in a string literal (docstrings left out) of duel/lisp/lhud-*.lisp and of the model's writers
;;    (webhud.lisp, webui.lisp) in the sans or the Mincho, unless an (lhud-shape "...") form says the HUD draws it as a shape: the bake
;;    reads only the tag forms, so such a character must be in one;
;;  - every text the kits put on screen (each form's name, U tag and intro line, each move's callout): ASCII, or baked as above.
;;  What this static scan cannot see: strings made at run time elsewhere (FORMAT of numbers is ASCII), a kit hook's :hud-tag result
;;  (ASCII literals in the kit files, turned into kanji by LHUD-TAG-SEGMENTS), the intro's reading (brush.lisp *BRUSH-NAMES*, not
;;  loaded on the host; ASCII romaji).
;; A failure says to re-run `build/sdf-venv/bin/python -I tools/sdf-bake.py` (README in duel/hud-font/).
(in-package :duel)

(defun lc-path (rel) (merge-pathnames (concatenate 'string "../../" rel) *load-truename*))
(defun lc-text (rel)
  (with-open-file (s (lc-path rel) :external-format :utf-8)
    (let ((str (make-string (file-length s))))
      (subseq str 0 (read-sequence str s)))))

(defun lc-strip (text lisp-p)
  "TEXT with its comments blanked and, for the scripts, only the string literals' characters kept (as one string)."
  (with-output-to-string (o)
    (let ((i 0) (n (length text)))
      (loop while (< i n)
            do (let ((c (char text i)))
                 (cond ((and lisp-p (char= c #\;)) (loop while (and (< i n) (char/= (char text i) #\Newline)) do (incf i)))
                       ((and (not lisp-p) (char= c #\/) (< (1+ i) n) (char= (char text (1+ i)) #\/))
                        (loop while (and (< i n) (char/= (char text i) #\Newline)) do (incf i)))
                       ((and (not lisp-p) (char= c #\/) (< (1+ i) n) (char= (char text (1+ i)) #\*))
                        (incf i 2) (loop while (and (< (1+ i) n) (not (and (char= (char text i) #\*) (char= (char text (1+ i)) #\/)))) do (incf i))
                        (incf i 2))
                       ((member c '(#\" #\' #\`) :test #'char=)           ; a string: its body is kept, between two quotes
                        (write-char c o) (incf i)
                        (loop while (and (< i n) (char/= (char text i) c) (or lisp-p (char/= c #\') (char/= (char text i) #\Newline)))
                              do (when (char= (char text i) #\\) (write-char #\\ o) (incf i))
                                 (when (< i n) (write-char (char text i) o) (incf i)))
                        (when (< i n) (write-char c o) (incf i)))
                       (t (unless lisp-p (write-char #\Space o)) (when lisp-p (write-char c o)) (incf i))))))))

(defun lc-walk (x fn)
  "Call FN on every string in the read form X but the tag forms' and the docstrings of DEFUN / DEFUN-FAST / DEFUN-FAST-INLINE / DEFMACRO (a string before a
body) and DEFVAR / DEFPARAMETER / DEFCONSTANT (the fourth element): what the code can put on screen, not what documents it."
  (let ((head (and (consp x) (symbolp (car x)) (symbol-name (car x)))))
    (cond ((stringp x) (funcall fn x))
          ((and head (member head '("KJ" "BIGKJ" "ZH" "BIG" "LHUD-SHAPE") :test #'string=)))   ; (a tag form: checked by its face below)
          ((and head (member head '("DEFUN" "DEFUN-FAST" "DEFUN-FAST-INLINE" "DEFMACRO") :test #'string=) (consp (cddr x)))
           (let ((body (cdddr x)))
             (when (and (stringp (car body)) (cdr body)) (setf body (cdr body)))
             (lc-walk (third x) fn) (dolist (y body) (lc-walk y fn))))
          ((and head (member head '("DEFVAR" "DEFPARAMETER" "DEFCONSTANT") :test #'string=)) (lc-walk (third x) fn))
          ((consp x) (loop for tail = x then (cdr tail) while (consp tail) do (lc-walk (car tail) fn) finally (when tail (lc-walk tail fn))))
          ((vectorp x) (map nil (lambda (y) (lc-walk y fn)) x)))))

(defun lc-literal-chars (rel)
  "The non-ASCII characters of the strings in the Lisp source REL (read, in DUEL) that are not docstrings (LC-WALK)."
  (let ((out nil) (eof (list nil)) (*package* (find-package :duel)) (*read-eval* nil))
    (with-open-file (s (lc-path rel) :external-format :utf-8)
      (loop for form = (read s nil eof) until (eq form eof)
            do (lc-walk form (lambda (str) (loop for c across str when (> (char-code c) 127) do (pushnew c out))))))
    out))

(defun lc-forms (text)
  "The (tag \"string\") forms of the stripped Lisp TEXT for the charset tags: a list of (tag . string)."
  (let ((out nil) (i 0) (n (length text)))
    (dolist (tag '("lhud-shape" "bigkj" "kj" "zh" "big") (nreverse out))
      (setf i 0)
      (loop
        (let* ((p (search (concatenate 'string "(" tag) text :start2 i)))
          (unless p (return))
          (let ((j (+ p 1 (length tag))))
            (setf i j)
            (when (and (< j n) (member (char text j) '(#\Space #\Newline #\Tab)))
              (loop while (and (< j n) (member (char text j) '(#\Space #\Newline #\Tab))) do (incf j))
              (when (and (< j n) (char= (char text j) #\"))
                (let ((e (1+ j)))
                  (loop while (char/= (char text e) #\") do (when (char= (char text e) #\\) (incf e)) (incf e))
                  (push (cons tag (subseq text (1+ j) e)) out)
                  (setf i e))))))))))

(defun lc-glyphs ()
  "The set of (tier * 4 + face) * 65536 + code keys of metrics.bin, and the header words."
  (with-open-file (s (lc-path "duel/hud-font/metrics.bin") :element-type '(unsigned-byte 8))
    (let* ((bytes (make-array (file-length s) :element-type '(unsigned-byte 8))) (tab (make-hash-table)))
      (read-sequence bytes s)
      (flet ((u16 (w) (logior (aref bytes (* 2 w)) (ash (aref bytes (1+ (* 2 w))) 8))))
        (let ((n (u16 2)) (g0 (+ 16 (* 4 (u16 8)))))
          (dotimes (k n) (setf (gethash (+ (* (u16 (+ g0 (* 9 k) 1)) 65536) (u16 (+ g0 (* 9 k)))) tab) t))
          (values tab (u16 0) (u16 1) n (length bytes) (+ 32 (* 8 (u16 8)) (* 18 n))))))))

(let* ((files (mapcar #'file-namestring (directory (lc-path "duel/lisp/lhud-*.lisp"))))
       (forms (loop for f in files
                    append (lc-forms (lc-strip (lc-text (concatenate 'string "duel/lisp/" f)) t))))
       (shapes (loop for (tag . s) in forms when (string= tag "lhud-shape") append (coerce s 'list)))
       (lit (let ((acc nil))                                ; the string literals' non-ASCII characters (docstrings left out)
              (dolist (f (append (mapcar (lambda (f) (concatenate 'string "duel/lisp/" f)) files) '("duel/lisp/webhud.lisp" "duel/lisp/webui.lisp")) acc)
                (dolist (c (lc-literal-chars f))
                  (unless (or (member c shapes) (member c acc)) (push c acc))))))
       (kit-text (let ((acc nil))                           ; what the kits put on screen
                   (maphash (lambda (ch forms)
                              (declare (ignore ch))
                              (dolist (f forms)
                                (let ((k (cdr f)))
                                  (dolist (s (list (kit-name k) (kit-form-name k) (kit-intro-callout k)))
                                    (when (stringp s) (push s acc)))
                                  (loop for mv being the hash-values of (kit-moves k)
                                        when (stringp (mv-callout mv)) do (push (mv-callout mv) acc)))))
                            *kits*)
                   acc))
       (miss nil))
  (multiple-value-bind (tab magic version n size want-size) (lc-glyphs)
    (flet ((has (ft c) (gethash (+ (* ft 65536) (char-code c)) tab))
           (need (what ft c) (unless (gethash (+ (* ft 65536) (char-code c)) tab) (push (list what ft c) miss))))
      (check (and (= magic #x4453) (= version 1) (> n 0) (= size want-size)))                 ; the file is what the header says
      (check (>= (length files) 2))                                                          ; lhud-battle and lhud-charset are read
      (check (member (code-char #xB7) (lc-literal-chars "duel/lisp/lhud-menu-front.lisp")))   ; the walk sees RESULTS' "DRAW · TIME UP"
      (check (> (length kit-text) 100))                                                      ; the kits' texts were read
      (loop for code from 32 to 126
            do (dolist (ft '(0 1 3)) (need "ASCII" ft (code-char code))))
      (loop for (tag . s) in forms
            do (loop for c across s
                     unless (char= c #\Space)
                       do (cond ((string= tag "kj") (need "kj" 2 c))
                                ((string= tag "bigkj") (need "bigkj" 6 c))
                                ((string= tag "big") (need "big" 4 c))
                                ((string= tag "zh") (unless (or (has 3 c) (has 2 c)) (push (list "zh" 3 c) miss))))))
      (dolist (c lit) (unless (or (has 3 c) (has 2 c)) (push (list "string literal" 3 c) miss)))
      (dolist (s kit-text)
        (loop for c across s
              when (and (> (char-code c) 127) (not (or (has 3 c) (has 2 c)))) do (push (list (format nil "kit text ~s" s) 3 c) miss)))
      (dolist (m (reverse miss)) (format t "  missing: ~a, face/tier ~d: ~a (U+~4,'0x); re-run tools/sdf-bake.py~%" (first m) (second m) (third m) (char-code (third m))))
      (check (null miss)))))
