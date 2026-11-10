;; ================================================================ the Lisp HUD's baked text (docs/duel/DUEL_LISP_HUD.md §4.2, §9)
;; duel/hud-font/metrics.bin (tools/sdf-bake.py) must hold every character the HUD can show, in the face and tier it is drawn in:
;;  - ASCII 32-126 in the display, mono and sans faces' body tiers;
;;  - every (kj / bigkj / big / zh "...") string of duel/lisp/lhud-*.lisp at its own (face, tier);
;;  - every non-ASCII character in a string literal of duel/web/hud.js and menu.js (the HTML UI the Lisp HUD replaces) in the sans or
;;    the Mincho, unless an (lhud-shape "...") form says the HUD draws it as a shape.
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
       (page (let ((acc nil))
               (dolist (f '("duel/web/hud.js" "duel/web/menu.js") acc)
                 (loop for c across (lc-strip (lc-text f) nil)
                       when (and (> (char-code c) 127) (not (member c shapes)) (not (member c acc))) do (push c acc)))))
       (miss nil))
  (multiple-value-bind (tab magic version n size want-size) (lc-glyphs)
    (flet ((has (ft c) (gethash (+ (* ft 65536) (char-code c)) tab))
           (need (what ft c) (unless (gethash (+ (* ft 65536) (char-code c)) tab) (push (list what ft c) miss))))
      (check (and (= magic #x4453) (= version 1) (> n 0) (= size want-size)))                 ; the file is what the header says
      (check (>= (length files) 2))                                                          ; lhud-battle and lhud-charset are read
      (check (> (length page) 300))                                                          ; the scan found the page's CJK (383 measured)
      (loop for code from 32 to 126
            do (dolist (ft '(0 1 3)) (need "ASCII" ft (code-char code))))
      (loop for (tag . s) in forms
            do (loop for c across s
                     unless (char= c #\Space)
                       do (cond ((string= tag "kj") (need "kj" 2 c))
                                ((string= tag "bigkj") (need "bigkj" 6 c))
                                ((string= tag "big") (need "big" 4 c))
                                ((string= tag "zh") (unless (or (has 3 c) (has 2 c)) (push (list "zh" 3 c) miss))))))
      (dolist (c page) (unless (or (has 3 c) (has 2 c)) (push (list "page script" 3 c) miss)))
      (dolist (m (reverse miss)) (format t "  missing: ~a, face/tier ~d: ~a (U+~4,'0x); re-run tools/sdf-bake.py~%" (first m) (second m) (third m) (char-code (third m))))
      (check (null miss)))))
