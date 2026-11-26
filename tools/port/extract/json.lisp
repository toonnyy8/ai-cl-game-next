;;;; json.lisp — the Bevy port extractor's JSON writer (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Task 4). Plain CL, no
;;;; game image: CL-USER::EXTRACT-JSON (object stream). Rules:
;;;;   keyword -> lowercase string without the colon; other symbol -> its SYMBOL-NAME; T -> true; NIL -> null;
;;;;   a plist (even length, distinct keyword keys, not every element a keyword) -> an object, keys sorted; any other list or
;;;;   vector -> an array (a string -> a JSON string); a dotted list (a b . c) -> [a,b,c] (alists of conses, Task 5);
;;;;   a hash table -> an object, keys sorted;
;;;;   single-float -> shortest round-trip (~a under single-float), always with a '.' or an 'e'; double-float -> {"f64":"<repr>"}
;;;;   (a long-float, ECL's PI on x86_64, is coerced to a double first and counted in *JSON-LONG-FLOATS*);
;;;;   anything else -> *JSON-OTHER* (a function of the object: a replacement to write, or NIL), else
;;;;   {"kind":"unserialisable","type":...}, recorded in *JSON-UNSERIALISABLE*.
;;;; (JSON-OBJECT plist) forces an object (first key wins on a repeat, as GETF; the dropped keys go to *JSON-DROPPED*);
;;;; (JSON-ARRAY list) forces an array (NIL -> []).
;;;; Task 5 adds the float checksum (JSON-FNV-FLOAT, *JSON-FLOAT-HASH*), a reader for the written files (JSON-READ-FILE) and the
;;;; shape rule (JSON-SHAPE-CONFLICTS); see their sections below.
(in-package :cl-user)

(defvar *json-other* nil "NIL, or a function (object) -> a replacement to write, or NIL (unserialisable).")
(defvar *json-unserialisable* nil "Type names of the objects written as an unserialisable marker, one entry per object.")
(defvar *json-dropped* nil "(key . plist) of every repeated key a JSON-OBJECT dropped.")
(defvar *json-long-floats* 0 "Long-floats written as f64.")

(defstruct (json-forced (:constructor %json-forced (kind items))) kind items)
(defun json-object (plist) (%json-forced :object plist))
(defun json-array (list) (%json-forced :array list))

(defun json-key (k)
  (typecase k
    (keyword (string-downcase (symbol-name k)))
    (symbol (symbol-name k))
    (string k)
    (integer (format nil "~d" k))
    (t (error "json key ~s" k))))

(defun json-plist-p (x)
  (and (consp x) (null (cdr (last x))) (evenp (length x))
       (loop for (k) on x by #'cddr always (keywordp k))
       (notevery #'keywordp x)
       (let ((ks (loop for (k) on x by #'cddr collect k))) (= (length ks) (length (remove-duplicates ks))))))

(defun json-write-string (s out)
  (write-char #\" out)
  (loop for c across s
        do (case c
             (#\" (write-string "\\\"" out))
             (#\\ (write-string "\\\\" out))
             (t (if (< (char-code c) 32) (format out "\\u~4,'0x" (char-code c)) (write-char c out)))))
  (write-char #\" out))

(defun json-write-pairs (pairs out)
  "PAIRS: ((key-string . value) ...), written sorted by key."
  (write-char #\{ out)
  (setf pairs (sort (copy-list pairs) #'string< :key #'car))
  (loop for (a b) on pairs when (and b (string= (car a) (car b))) do (error "json: key ~s twice in one object (two keys name it)" (car a)))
  (loop for (k . v) in pairs for first = t then nil
        do (unless first (write-char #\, out)) (json-write-string k out) (write-char #\: out) (extract-json v out))
  (write-char #\} out))

(defun json-plist-pairs (plist)
  (let ((seen nil) (pairs nil))
    (loop for (k v) on plist by #'cddr
          do (if (member k seen) (push (cons k plist) *json-dropped*) (progn (push k seen) (push (cons (json-key k) v) pairs))))
    pairs))

(defun json-write-seq (seq out)
  (write-char #\[ out)
  (let ((first t)) (map nil (lambda (x) (unless first (write-char #\, out)) (setf first nil) (extract-json x out)) seq))
  (write-char #\] out))

(defun json-float-token (x)
  (let ((s (let ((*read-default-float-format* 'single-float)) (format nil "~a" x))))
    (unless (every (lambda (c) (or (digit-char-p c) (find c "-.e"))) s) (error "float ~s printed as ~a" x s))
    (if (or (find #\. s) (find #\e s)) s (concatenate 'string s ".0"))))

(defun json-unserialisable (x out)
  (let ((type (format nil "~a" (type-of x))))
    (push type *json-unserialisable*)
    (json-write-pairs (list (cons "kind" "unserialisable") (cons "type" type)) out)))

(defun json-nan-or-inf-p (x) (or (ext:float-nan-p x) (ext:float-infinity-p x)))

(defun extract-json (x out)
  "Write X to stream OUT as JSON (the rules above)."
  (cond ((null x) (write-string "null" out))
        ((eq x t) (write-string "true" out))
        ((keywordp x) (json-write-string (json-key x) out))
        ((symbolp x) (json-write-string (symbol-name x) out))
        ((integerp x) (format out "~d" x))
        ((typep x 'single-float)
         (if (json-nan-or-inf-p x) (json-unserialisable x out) (progn (json-note-float x) (write-string (json-float-token x) out))))
        ((floatp x)
         (when (typep x 'long-float) (unless (typep x 'double-float) (incf *json-long-floats*) (setf x (coerce x 'double-float))))
         (if (json-nan-or-inf-p x)
             (json-unserialisable x out)
             (progn (json-note-float x)
                    (json-write-pairs (list (cons "f64" (let ((*read-default-float-format* 'double-float)) (format nil "~a" x)))) out))))
        ((stringp x) (json-write-string x out))
        ((json-forced-p x)
         (if (eq (json-forced-kind x) :object)
             (json-write-pairs (json-plist-pairs (json-forced-items x)) out)
             (json-write-seq (json-forced-items x) out)))
        ((json-plist-p x) (json-write-pairs (json-plist-pairs x) out))
        ((and (consp x) (null (cdr (last x)))) (json-write-seq x out))
        ((consp x) (json-write-seq (append (butlast x 0) (list (cdr (last x)))) out))   ; dotted: (a b . c) -> [a,b,c]
        ((vectorp x) (json-write-seq x out))
        ((hash-table-p x)
         (json-write-pairs (loop for k being the hash-keys of x using (hash-value v) collect (cons (json-key k) v)) out))
        (t (let ((r (and *json-other* (funcall *json-other* x))))
             (if r (extract-json r out) (json-unserialisable x out))))))


;;; ---------------------------------------------------------------- the float checksum (Task 5, the controller's ruling 1)
;;; FNV-1a 64 over 13 bytes per float, from (INTEGER-DECODE-FLOAT x) = mantissa exponent sign: the sign as one byte (0 for +1, 1 for
;;; -1), the exponent as a two's-complement i32 little-endian, the mantissa as a u64 little-endian. ECL's triples: a zero is
;;; (0 0 sign); a normal single (2^23|frac, biased-150), a normal double (2^52|frac, biased-1075); a denormal is normalised (its
;;; mantissa shifted left until bit 23 / 52 is set, the exponent lowered by the shift: 1.4012985e-45 -> (8388608 -172 1)).
(defconstant +fnv-basis+ #xcbf29ce484222325)
(defconstant +fnv-prime+ #x100000001b3)
(defun json-fnv-bytes (h bytes)
  (dolist (b bytes h) (setf h (ldb (byte 64 0) (* (logxor h b) +fnv-prime+)))))
(defun json-float-bytes (x)
  (multiple-value-bind (m e s) (integer-decode-float x)
    (append (list (if (minusp s) 1 0))
            (loop for i below 4 collect (ldb (byte 8 (* 8 i)) e))     ; (LDB of a negative integer: two's complement)
            (loop for i below 8 collect (ldb (byte 8 (* 8 i)) m)))))
(defun json-fnv-float (h x) (json-fnv-bytes h (json-float-bytes x)))

(defvar *json-float-hash* nil "NIL, or the FNV state the writer folds every float it writes into (a file's write-time hash).")
(defun json-note-float (x) (when *json-float-hash* (setf *json-float-hash* (json-fnv-float *json-float-hash* x))))

;;; ---------------------------------------------------------------- the reader (verification only: written files read back)
;;; object -> (:object (key . value) ...) in document order; array -> (:array item ...); string; integer; a number token holding '.' or
;;; 'e' / 'E' -> a single-float; true / false / null -> :true / :false / :null. {"f64":"..."} stays an object (JSON-FLOATS reads it).
(defvar *jr-s* "")
(defvar *jr-i* 0)
(defun jr-ws () (loop while (and (< *jr-i* (length *jr-s*)) (member (char *jr-s* *jr-i*) '(#\Space #\Newline #\Tab #\Return))) do (incf *jr-i*)))
(defun jr-expect (c) (jr-ws) (unless (char= (char *jr-s* *jr-i*) c) (error "json read: ~a expected at ~d" c *jr-i*)) (incf *jr-i*))
(defun jr-string ()
  (jr-expect #\")
  (with-output-to-string (o)
    (loop for c = (char *jr-s* *jr-i*)
          do (incf *jr-i*)
             (cond ((char= c #\") (return))
                   ((char= c #\\)
                    (let ((e (char *jr-s* *jr-i*)))
                      (incf *jr-i*)
                      (case e
                        (#\u (write-char (code-char (parse-integer *jr-s* :start *jr-i* :end (+ *jr-i* 4) :radix 16)) o) (incf *jr-i* 4))
                        (#\n (write-char #\Newline o)) (#\t (write-char #\Tab o))
                        (t (write-char e o)))))
                   (t (write-char c o))))))
(defun jr-value ()
  (jr-ws)
  (let ((c (char *jr-s* *jr-i*)))
    (cond ((char= c #\{)
           (incf *jr-i*) (jr-ws)
           (if (char= (char *jr-s* *jr-i*) #\}) (progn (incf *jr-i*) (list :object))
               (cons :object (loop collect (let ((k (jr-string))) (jr-expect #\:) (cons k (jr-value)))
                                   do (jr-ws)
                                   until (char= (char *jr-s* *jr-i*) #\}) do (jr-expect #\,)
                                   finally (incf *jr-i*)))))
          ((char= c #\[)
           (incf *jr-i*) (jr-ws)
           (if (char= (char *jr-s* *jr-i*) #\]) (progn (incf *jr-i*) (list :array))
               (cons :array (loop collect (jr-value)
                                  do (jr-ws)
                                  until (char= (char *jr-s* *jr-i*) #\]) do (jr-expect #\,)
                                  finally (incf *jr-i*)))))
          ((char= c #\") (jr-string))
          ((alpha-char-p c)
           (let ((w (find-if (lambda (w) (string= w *jr-s* :start2 *jr-i* :end2 (min (length *jr-s*) (+ *jr-i* (length w))))) '("true" "false" "null"))))
             (unless w (error "json read: bad word at ~d" *jr-i*))
             (incf *jr-i* (length w))
             (intern (string-upcase w) :keyword)))
          (t (let* ((end (or (position-if-not (lambda (c) (find c "-+0123456789.eE")) *jr-s* :start *jr-i*) (length *jr-s*)))
                    (tok (subseq *jr-s* *jr-i* end)))
               (setf *jr-i* end)
               (if (find-if (lambda (c) (find c ".eE")) tok)
                   (let ((x (let ((*read-default-float-format* 'single-float) (*read-eval* nil)) (read-from-string tok))))
                     (unless (typep x 'single-float) (error "json read: float token ~a read as ~s" tok x))
                     x)
                   (parse-integer tok)))))))
(defun json-read-string (s)
  (let ((*jr-s* s) (*jr-i* 0)) (prog1 (jr-value) (jr-ws) (unless (= *jr-i* (length s)) (error "json read: trailing text at ~d" *jr-i*)))))
(defun json-read-file (path)
  (json-read-string (with-open-file (in path :external-format :utf-8)
                      (let ((s (make-string (file-length in)))) (subseq s 0 (read-sequence s in))))))

(defun json-f64-tag-p (v) (and (consp v) (eq (car v) :object) (= (length (cdr v)) 1) (equal (car (second v)) "f64") (stringp (cdr (second v)))))
(defun json-map-floats (fn tree)
  "Call FN on every float of TREE (a JSON-READ tree) in document order: single-float tokens and {\"f64\":...} doubles."
  (cond ((json-f64-tag-p tree)
         (funcall fn (let ((*read-default-float-format* 'double-float) (*read-eval* nil)) (coerce (read-from-string (cdr (second tree))) 'double-float))))
        ((floatp tree) (funcall fn tree))
        ((and (consp tree) (eq (car tree) :object)) (dolist (p (cdr tree)) (json-map-floats fn (cdr p))))
        ((and (consp tree) (eq (car tree) :array)) (dolist (v (cdr tree)) (json-map-floats fn v)))))
(defun json-floats (tree) (let ((out nil)) (json-map-floats (lambda (x) (push x out)) tree) (nreverse out)))
(defun json-tree-fnv (h tree) (json-map-floats (lambda (x) (setf h (json-fnv-float h x))) tree) h)

;;; ---------------------------------------------------------------- the shape rule (the controller's ruling 4, fix round 1)
;;; A path is the keys and array positions from the file's root joined by '.'. Every array index is written "[]", so all the elements of
;;; one array share one path; object keys at the depths in COLLAPSE (the entry levels: a name-keyed file's top-level key, kits.json's char
;;; and form) are written "*". TUPLES lists the paths of arrays that are genuine positional tuples ([antecedents, outputs]): their children
;;; keep literal indices. A conflict: one path holding an object somewhere and an array elsewhere. An {"f64":...} tag is a number.
(defun json-shape-conflicts (tree collapse &optional tuples)
  (let ((shapes (make-hash-table :test 'equal)))
    (labels ((walk (v path depth)
               (when (and (consp v) (member (car v) '(:object :array)) (not (json-f64-tag-p v)))
                 (let ((key (format nil "~{~a~^.~}" (reverse path))))
                   (pushnew (car v) (gethash key shapes))
                   (if (eq (car v) :object)
                       (dolist (p (cdr v)) (walk (cdr p) (cons (if (member depth collapse) "*" (car p)) path) (1+ depth)))
                       (let ((tuple (member key tuples :test #'string=)))
                         (loop for x in (cdr v) for i from 0 do (walk x (cons (if tuple i "[]") path) (1+ depth)))))))))
      (walk tree nil 0))
    (sort (loop for k being the hash-keys of shapes using (hash-value s) when (cdr s) collect k) #'string<)))
