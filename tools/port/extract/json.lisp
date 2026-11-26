;;;; json.lisp — the Bevy port extractor's JSON writer (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Task 4). Plain CL, no
;;;; game image: CL-USER::EXTRACT-JSON (object stream). Rules:
;;;;   keyword -> lowercase string without the colon; other symbol -> its SYMBOL-NAME; T -> true; NIL -> null;
;;;;   a plist (even length, distinct keyword keys, not every element a keyword) -> an object, keys sorted; any other list or
;;;;   vector -> an array (a string -> a JSON string); a hash table -> an object, keys sorted;
;;;;   single-float -> shortest round-trip (~a under single-float), always with a '.' or an 'e'; double-float -> {"f64":"<repr>"}
;;;;   (a long-float, ECL's PI on x86_64, is coerced to a double first and counted in *JSON-LONG-FLOATS*);
;;;;   anything else -> *JSON-OTHER* (a function of the object: a replacement to write, or NIL), else
;;;;   {"kind":"unserialisable","type":...}, recorded in *JSON-UNSERIALISABLE*.
;;;; (JSON-OBJECT plist) forces an object (first key wins on a repeat, as GETF; the dropped keys go to *JSON-DROPPED*);
;;;; (JSON-ARRAY list) forces an array (NIL -> []).
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
  (loop for (k . v) in (sort (copy-list pairs) #'string< :key #'car) for first = t then nil
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
         (if (json-nan-or-inf-p x) (json-unserialisable x out) (write-string (json-float-token x) out)))
        ((floatp x)
         (when (typep x 'long-float) (unless (typep x 'double-float) (incf *json-long-floats*) (setf x (coerce x 'double-float))))
         (if (json-nan-or-inf-p x)
             (json-unserialisable x out)
             (json-write-pairs (list (cons "f64" (let ((*read-default-float-format* 'double-float)) (format nil "~a" x)))) out)))
        ((stringp x) (json-write-string x out))
        ((json-forced-p x)
         (if (eq (json-forced-kind x) :object)
             (json-write-pairs (json-plist-pairs (json-forced-items x)) out)
             (json-write-seq (json-forced-items x) out)))
        ((json-plist-p x) (json-write-pairs (json-plist-pairs x) out))
        ((and (consp x) (null (cdr (last x)))) (json-write-seq x out))
        ((vectorp x) (json-write-seq x out))
        ((hash-table-p x)
         (json-write-pairs (loop for k being the hash-keys of x using (hash-value v) collect (cons (json-key k) v)) out))
        (t (let ((r (and *json-other* (funcall *json-other* x))))
             (if r (extract-json r out) (json-unserialisable x out))))))

