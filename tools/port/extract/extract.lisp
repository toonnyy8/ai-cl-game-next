;;;; extract.lisp — the Bevy port's data extractor (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Task 4): the frozen game's
;;;; moves and kits as JSON, read from the native image's structs (never retyped, never from MV-SPEC: a derived form's spec holds
;;;; the base numbers).
;;;;   $ECL_HOST --norc --load tools/port/extract/extract.lisp -- build/simgate/duel.fas MODE [OUT-DIR]
;;;; MODE: moves | kits | all (both) | census (exit 1 unless moves.json holds every MOVE object of the image, once, by identity).
;;;; OUT-DIR defaults to rs/duel-data/data. The image comes from simlib.build() (tools/simlib.py).
;;;; Move ids: "<char>/<form>/<name>[#n]" for a MOVE in a kit's KIT-MOVES (kits in sorted order, the first kit claims a shared
;;;; object); a MOVE only in a variable: "var/<variable>/<name>#<index>" (index = the vector position; in a hash table, the rank
;;;; among same-name objects sorted by their JSON). Hook / code fields are written as symbol names (the JSON writer's rule).
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "json.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defparameter *x-root* (truename (merge-pathnames "../../../" (directory-namestring *load-truename*))))
(defparameter *x-mode* (or (second cl-user::*sg-args*) "all"))
(defparameter *x-out* (if (third cl-user::*sg-args*)
                          (pathname (concatenate 'string (string-right-trim "/" (third cl-user::*sg-args*)) "/"))
                          (merge-pathnames "rs/duel-data/data/" *x-root*)))
(cl-user::sg-init)                                      ; every :load step, as the page starts (the state a match starts from)

;;; ---------------------------------------------------------------- helpers
(defun x-key (k) (cl-user::json-key k))
(defun x-json (x) (with-output-to-string (s) (cl-user::extract-json x s)))
(defun x-sorted-kits ()
  "((char form kit) ...) sorted by char then form name."
  (let ((rows nil))
    (maphash (lambda (c forms) (dolist (cf forms) (push (list c (car cf) (cdr cf)) rows))) *kits*)
    (sort rows (lambda (a b) (let ((ca (x-key (first a))) (cb (x-key (first b))))
                               (or (string< ca cb) (and (string= ca cb) (string< (x-key (second a)) (x-key (second b))))))))))
(defun x-slot-names (type) (mapcar #'clos:slot-definition-name (clos:class-slots (find-class type))))
(defun x-json-name (slot) (if (eq slot 'clip-2) "clip2" (substitute #\_ #\- (string-downcase (symbol-name slot)))))

;;; Code fields: every non-keyword symbol written, by field path (the report's list of names to port by hand).
(defvar *x-syms* (make-hash-table :test 'equal) "field path -> list of symbol names written there.")
(defun x-note-syms (x path)
  (cond ((and x (symbolp x) (not (keywordp x)) (not (eq x t))) (pushnew (symbol-name x) (gethash path *x-syms*) :test #'string=))
        ((consp x) (x-note-syms (car x) path) (when (listp (cdr x)) (x-note-syms (cdr x) path)))
        ((and (vectorp x) (not (stringp x)) (eq (array-element-type x) t)) (loop for y across x do (x-note-syms y path)))))
(defun x-note-plist (plist path)
  (loop for (k v) on plist by #'cddr do (x-note-syms v (format nil "~a.~a" path (x-key k)))))

;;; ---------------------------------------------------------------- move ids
(defvar *x-ids* (make-hash-table :test 'eq) "MOVE -> id.")
(defvar *x-id-owner* (make-hash-table :test 'equal) "id -> MOVE.")
(defvar *x-kit-collisions* 0 "Two objects under one name in one kit's table (never expected: a hash table).")
(defun x-claim (mv id)
  (unless (gethash mv *x-ids*)
    (let ((final (loop for n from 0 for try = (if (zerop n) id (format nil "~a#~d" id n))
                       unless (gethash try *x-id-owner*) return try)))
      (unless (string= final id) (incf *x-kit-collisions*))
      (setf (gethash mv *x-ids*) final (gethash final *x-id-owner*) mv))))
(defun x-claim-var (var objs)
  "Claim ids for OBJS ((index . MOVE) ...) from variable VAR not claimed yet."
  (loop for (i . mv) in objs
        unless (gethash mv *x-ids*)
          do (setf (gethash mv *x-ids*) (format nil "var/~a/~a#~d" (string-downcase (string-trim "*" (symbol-name var))) (x-key (mv-name mv)) i))
             (when (gethash (gethash mv *x-ids*) *x-id-owner*) (error "id clash ~a" (gethash mv *x-ids*)))
             (setf (gethash (gethash mv *x-ids*) *x-id-owner*) mv)))
(defun x-rank-by-content (objs)
  "OBJS (MOVEs from a hash table, not yet claimed) as ((rank . MOVE) ...): rank among same-name objects sorted by their JSON."
  (let* ((objs (remove-duplicates (remove-if (lambda (m) (gethash m *x-ids*)) objs)))
         (keyed (sort (mapcar (lambda (m) (list (x-key (mv-name m)) (x-json (x-move-object m)) m)) objs)
                      (lambda (a b) (or (string< (first a) (first b)) (and (string= (first a) (first b)) (string< (second a) (second b))))))))
    (loop with last = nil with n = 0 for (name nil m) in keyed
          do (setf n (if (equal name last) (1+ n) 0) last name)
          collect (cons n m))))
(defun x-vector-objs (v)
  "((position . MOVE) ...) of a vector of MOVEs or of lists of MOVEs (*YA-REACH-COPIES*: one list per level)."
  (loop for x across v for i from 0 append (if (listp x) (mapcar (lambda (m) (cons i m)) x) (list (cons i x)))))
(defun x-assign-ids ()
  (loop for (c f kit) in (x-sorted-kits)
        do (let ((names nil))
             (maphash (lambda (n mv) (unless (eq n (mv-name mv)) (error "kit ~s ~s: key ~s holds move ~s" c f n (mv-name mv))) (push n names)) (kit-moves kit))
             (dolist (n (sort names #'string< :key #'x-key))
               (x-claim (gethash n (kit-moves kit)) (format nil "~a/~a/~a" (x-key c) (x-key f) (x-key n))))))
  (x-claim-var '*moves* (x-rank-by-content (loop for m being the hash-values of *moves* collect m)))
  (x-claim-var '*cadence-moves* (x-rank-by-content (loop for k being the hash-keys of *cadence-moves* using (hash-value m)
                                                          collect (car k) collect m)))
  (x-claim-var '*ya-reach-copies* (x-vector-objs *ya-reach-copies*))
  (x-claim-var '*ya-garb-copies* (x-vector-objs *ya-garb-copies*))
  (x-claim-var '*hs-k1-scaled* (x-vector-objs *hs-k1-scaled*))
  (loop for (c f kit) in (x-sorted-kits)
        do (maphash (lambda (mv cls) (declare (ignore cls)) (unless (gethash mv *x-ids*) (error "kit ~s ~s classes an unclaimed move ~s" c f (mv-name mv))))
                    (kit-cls kit))))

;;; ---------------------------------------------------------------- dumps
(defparameter *x-move-objects* '(params) "Move slots written as a JSON object (a plist; NIL -> {}).")
(defparameter *x-kit-objects* '(hooks commands core clip-map look-clips meter) "Kit slots written as a JSON object.")
(defparameter *x-skip* '(spec) "Slots never written: the DEFMOVE / DEFKIT plist (a derived form's holds the base numbers).")
(defun x-shape (v objectp)
  "A slot value as written: a plist slot -> an object; any other list -> an array (NIL -> [] only for the list slots the caller
names; a scalar slot's NIL stays null)."
  (cond (objectp (cl-user::json-object v))
        ((consp v) (cl-user::json-array v))
        (t v)))
(defparameter *x-move-lists* '(hits flags on-frame) "Move slots that are lists: NIL -> [].")
(defparameter *x-hw-lists* '(vols flags))
(defparameter *x-kit-lists* '(strings passives hide enter-clips run-clips))

(defun x-hitwin-object (hw)
  (cl-user::json-object
   (loop for slot in (x-slot-names 'hitwin)
        for v = (slot-value hw slot)
        do (x-note-syms v (format nil "move.hits.~a" (x-json-name slot)))
        collect (x-json-name slot)
        collect (if (member slot *x-hw-lists*) (cl-user::json-array (coerce v 'list)) (x-shape v nil)))))
(defun x-move-object (mv)
  "MV as a JSON object (a forced plist with string keys), its id included when it has one."
  (cl-user::json-object
   (append
    (let ((id (gethash mv *x-ids*))) (and id (list "id" id)))
    (loop for slot in (x-slot-names 'move)
          for v = (slot-value mv slot)
          for key = (x-json-name slot)
          unless (member slot *x-skip*)
            do (if (eq slot 'params) (x-note-plist v "move.params") (unless (eq slot 'hits) (x-note-syms v (format nil "move.~a" key))))
            and collect key
            and collect (cond ((eq slot 'hits) (cl-user::json-array (map 'list #'x-hitwin-object v)))
                              ((member slot *x-move-lists*) (cl-user::json-array v))
                              (t (x-shape v (member slot *x-move-objects*))))))))
(defun x-kit-object (kit)
  (cl-user::json-object
   (loop for slot in (x-slot-names 'kit)
         for v = (slot-value kit slot)
         for key = (x-json-name slot)
         unless (member slot *x-skip*)
           collect key
           and collect (case slot
                         (cls (cl-user::json-object (loop for mv being the hash-keys of v using (hash-value c)
                                                          collect (gethash mv *x-ids*) collect c)))
                         (moves (cl-user::json-array (sort (loop for mv being the hash-values of v collect (gethash mv *x-ids*)) #'string<)))
                         (sp v)
                         (t (if (member slot *x-kit-objects*) (x-note-plist v (format nil "kit.~a" key)) (x-note-syms v (format nil "kit.~a" key)))
                            (cond ((member slot *x-kit-lists*) (cl-user::json-array v))
                                  ((and (member slot '(l-after-k l-after-j)) (consp v)) (cl-user::json-object v))
                                  (t (x-shape v (member slot *x-kit-objects*)))))))))

(defun x-other (x) (if (move-p x) (or (gethash x *x-ids*) (error "unclaimed move ~s in data" (mv-name x))) nil))

(defun x-write (name fn)
  (let ((path (merge-pathnames name *x-out*)))
    (ensure-directories-exist path)
    (with-open-file (out path :direction :output :if-exists :supersede :external-format :utf-8)
      (funcall fn out))
    (format t "wrote ~a~%" (namestring path))))

(defun x-write-moves ()
  (let ((ids (sort (loop for id being the hash-keys of *x-id-owner* collect id) #'string<)))
    (x-write "moves.json"
             (lambda (out)
               (write-line "[" out)
               (loop for (id . more) on ids
                     do (cl-user::extract-json (x-move-object (gethash id *x-id-owner*)) out)
                        (write-line (if more "," "") out))
               (write-line "]" out)))
    (format t "moves ~d~%" (length ids))))

(defun x-write-kits ()
  (let ((tree (make-hash-table :test 'equal)))
    (loop for (c f kit) in (x-sorted-kits)
          do (let ((forms (or (gethash (x-key c) tree) (setf (gethash (x-key c) tree) (make-hash-table :test 'equal)))))
               (setf (gethash (x-key f) forms) (x-kit-object kit))))
    (x-write "kits.json"
             (lambda (out)
               (cl-user::extract-json (cl-user::json-object (list "kits" tree "roster" (cl-user::json-array *roster*)
                                                                  "retired" (cl-user::json-array *retired*)))
                                      out)
               (terpri out)))))

;;; ---------------------------------------------------------------- census (its own walk: never the dump's)
(defun x-census-objects ()
  "Every distinct MOVE (EQ) the image holds in the places moves live: each kit's table and class keys, *MOVES*, *CADENCE-MOVES*'
keys and values, *YA-REACH-COPIES*, *YA-GARB-COPIES*, *HS-K1-SCALED*."
  (let ((seen (make-hash-table :test 'eq)) (out nil))
    (labels ((add (x) (cond ((move-p x) (unless (gethash x seen) (setf (gethash x seen) t) (push x out)))
                            ((consp x) (add (car x)) (add (cdr x)))
                            ((and (vectorp x) (not (stringp x))) (loop for y across x do (add y))))))
      (maphash (lambda (c forms) (declare (ignore c))
                 (dolist (cf forms)
                   (maphash (lambda (n m) (declare (ignore n)) (add m)) (kit-moves (cdr cf)))
                   (maphash (lambda (m cls) (declare (ignore cls)) (add m)) (kit-cls (cdr cf)))))
               *kits*)
      (maphash (lambda (n m) (declare (ignore n)) (add m)) *moves*)
      (maphash (lambda (k m) (add k) (add m)) *cadence-moves*)
      (add *ya-reach-copies*) (add *ya-garb-copies*) (add *hs-k1-scaled*))
    (values out seen)))

(defun x-sweep-moves (seen)
  "MOVE objects reachable from any bound symbol of DUEL / ENGINE / CL-USER (conses, general vectors, hash tables, structs) that
SEEN lacks: a copy kept somewhere the census list doesn't name."
  (let ((visited (make-hash-table :test 'eq)) (extra nil) (met 0))
    (labels ((walk (x)
               (loop
                 (cond ((or (null x) (numberp x) (symbolp x) (stringp x) (characterp x) (functionp x)) (return))
                       ((gethash x visited) (return)))
                 (setf (gethash x visited) t)
                 (cond ((consp x) (walk (car x)) (setf x (cdr x)))
                       (t (cond ((move-p x) (incf met) (unless (gethash x seen) (pushnew x extra)))
                                ((and (vectorp x) (eq (array-element-type x) t)) (loop for y across x do (walk y)))
                                ((hash-table-p x) (maphash (lambda (k v) (walk k) (walk v)) x))
                                ((typep x 'structure-object)
                                 (dolist (s (x-slot-names (type-of x))) (walk (slot-value x s)))))
                          (return))))))
      (dolist (p '(:duel :engine :cl-user))
        (do-symbols (s p)
          (when (and (eq (symbol-package s) (find-package p)) (boundp s)) (walk (symbol-value s))))))
    (values extra met)))

(defun x-census ()
  (multiple-value-bind (objs seen) (x-census-objects)
    (format t "census moves ~d~%" (length objs))
    (multiple-value-bind (extra met) (x-sweep-moves seen)
    (let ((owner (loop for m in objs when (find *perfect-hw* (mv-hits m)) collect (mv-name m)))
          (path (merge-pathnames "moves.json" *x-out*))
          (fail nil))
      (format t "census sweep reached ~d moves, extra ~d~%" met (length extra))
      (when extra (setf fail t) (format t "  not in the census places: ~s~%" (mapcar #'mv-name extra)))
      (format t "census perfect-hw owner ~:[none (a standalone hitwin, fighter.lisp *PERFECT-HW*)~;~:*~s~]~%" owner)
      (if (not (probe-file path))
          (progn (format t "census FAIL: no ~a~%" (namestring path)) (setf fail t))
          (let* ((text (with-open-file (in path :external-format :utf-8)
                         (let ((s (make-string (file-length in)))) (subseq s 0 (read-sequence s in)))))
                 (n (loop for i = (search "\"id\":\"" text) then (search "\"id\":\"" text :start2 (1+ i)) while i count t))
                 (missing (loop for m in objs for id = (gethash m *x-ids*)
                                unless (and id (search (format nil "\"id\":\"~a\"" id) text)) collect (or id (mv-name m)))))
            (format t "census moves.json ids ~d~%" n)
            (unless (= n (length objs)) (setf fail t) (format t "census FAIL: moves.json has ~d moves, the image ~d~%" n (length objs)))
            (when missing (setf fail t) (format t "census FAIL: missing ~d: ~s~%" (length missing) missing))
            (unless (= (hash-table-count *x-ids*) (length objs))
              (setf fail t) (format t "census FAIL: ~d ids claimed, ~d objects~%" (hash-table-count *x-ids*) (length objs)))))
      (format t "census ~:[PASS~;FAIL~]~%" fail)
      (finish-output)
      (ext:quit (if fail 1 0))))))

;;; ---------------------------------------------------------------- main
(let ((cl-user::*json-other* #'x-other))
  (x-assign-ids)
  (cond ((string= *x-mode* "census") (x-census))
        ((member *x-mode* '("moves" "kits" "all") :test #'string=)
         (when (member *x-mode* '("moves" "all") :test #'string=) (x-write-moves))
         (when (member *x-mode* '("kits" "all") :test #'string=) (x-write-kits))
         (format t "kit-name collisions ~d~%" *x-kit-collisions*)
         (format t "unserialisable ~d ~s~%" (length cl-user::*json-unserialisable*) (remove-duplicates cl-user::*json-unserialisable* :test #'string=))
         (format t "dropped keys ~d ~s~%" (length cl-user::*json-dropped*) (mapcar #'car cl-user::*json-dropped*))
         (format t "long-floats ~d~%" cl-user::*json-long-floats*)
         (let ((paths (sort (loop for p being the hash-keys of *x-syms* collect p) #'string<)))
           (dolist (p paths) (format t "code ~a: ~{~a~^ ~}~%" p (sort (copy-list (gethash p *x-syms*)) #'string<)))))
        (t (format t "unknown mode ~a~%" *x-mode*) (ext:quit 2))))
(finish-output)
(ext:quit 0)
