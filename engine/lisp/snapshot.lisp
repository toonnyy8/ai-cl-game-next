;;;; snapshot.lisp — the simulation's state saved and put back in place, for an offline search's rollouts
;;;; (docs/duel/DUEL_AI_TEACHER.md §5).
;;;;
;;;; SIM-SNAPSHOT walks from the roots (SNAPSHOT-ROOTS: symbols; the ECS's own are registered below) and keeps, for every mutable
;;;; object it reaches (memoised by identity), a copy of its contents: a struct's slots, an array's elements and fill pointer, a
;;;; cons's car and cdr, a hash table's entries. SIM-RESTORE writes those contents back into the same objects and the roots' values
;;;; back into their symbols, so EQ tests and aliasing survive (a fresh copy would break both). The walk stops at shared definitions
;;;; (SNAPSHOT-SHARED: struct type names the game never writes while it runs: kits, moves, clips ...) and at numbers, characters,
;;;; symbols, strings, functions and anything else that is not a struct, array, cons or hash table. The C sim RNG is saved too.
;;;; A snapshot can be restored any number of times. Objects made after it are simply dropped by a restore.
(in-package :engine)

(defvar *snapshot-roots* nil "Symbols whose values are sim state, in registration order (SNAPSHOT-ROOTS).")
(defvar *snapshot-shared* (make-hash-table :test 'eq) "Struct type names never walked (shared definitions: SNAPSHOT-SHARED).")

(defun snapshot-roots (&rest symbols)
  "Register SYMBOLS (special variables) as sim state: their values, and everything mutable reachable from them, are snapshotted."
  (dolist (s symbols) (unless (member s *snapshot-roots*) (setf *snapshot-roots* (append *snapshot-roots* (list s))))))

(defun snapshot-shared (&rest types)
  "Register struct TYPES as shared definitions: a snapshot keeps a reference to them and never their contents."
  (dolist (ty types) (setf (gethash ty *snapshot-shared*) t)))

(snapshot-roots '*stores* '*used* '*generation* '*top*    ; (slot reuse decides the entity order and the handles: ecs.lisp)
                '*hitstop* '*tick* '*slowmo*            ; time.lisp
                '*cine*)                                ; cine.lisp (the running cinematic)

(defstruct (simsnap (:constructor %make-simsnap))
  "A saved sim state: the roots' symbols and values, the walked objects and their saved contents, the sim RNG."
  (roots #() :type simple-vector) (vals #() :type simple-vector)
  (objs #() :type simple-vector) (saved #() :type simple-vector) (rng 0))

(declaim (inline snap-leaf-p))
(defun snap-leaf-p (x)
  (or (typep x '(or number character symbol function string))
      (not (or (consp x) (arrayp x) (hash-table-p x) (si::structurep x)))
      (and (si::structurep x) (gethash (type-of x) *snapshot-shared*))))

(defun snap-contents (x)
  "X's contents as a snapshot keeps them (X is a cons, array, hash table or non-shared struct)."
  (cond ((consp x) (cons (car x) (cdr x)))
        ((arrayp x)
         (let* ((n (array-total-size x)) (d (make-array n :element-type (array-element-type x))))
           (dotimes (i n) (setf (aref d i) (row-major-aref x i)))
           (cons (and (array-has-fill-pointer-p x) (fill-pointer x)) d)))
        ((hash-table-p x) (let (l) (maphash (lambda (k v) (push (cons k v) l)) x) (nreverse l)))   ; (put back in its own order)
        (t (let* ((n (ffi:c-inline (x) (:object) :fixnum "(#0)->instance.length" :one-liner t))   ; (SI:INSTANCEP gives it only
                  (v (make-array n)))                                                                 ;  interpreted: compiled, a T)
             (dotimes (i n) (setf (svref v i) (si:instance-ref x i)))
             v))))

(defun sim-snapshot ()
  "Save the sim's state (the roots, everything mutable they reach, the sim RNG). See the file header."
  (let ((memo (make-hash-table :test 'eq :size 4096)) (objs nil) (saved nil) (stack nil))
    (flet ((visit (x)
             (unless (or (snap-leaf-p x) (gethash x memo))
               (setf (gethash x memo) t)
               (let ((c (snap-contents x)))
                 (push x objs) (push c saved) (push (cons x c) stack)))))
      (let ((vals (mapcar #'symbol-value *snapshot-roots*)))
        (mapc #'visit vals)
        (loop while stack
              do (destructuring-bind (x . c) (pop stack)
                   (cond ((consp x) (visit (car c)) (visit (cdr c)))
                         ((arrayp x) (let ((d (cdr c))) (when (eq (array-element-type d) t) (loop for e across d do (visit e)))))
                         ((hash-table-p x) (dolist (p c) (visit (car p)) (visit (cdr p))))
                         (t (loop for e across c do (visit e))))))
        (%make-simsnap :roots (coerce *snapshot-roots* 'simple-vector) :vals (coerce vals 'simple-vector)
                       :objs (coerce objs 'simple-vector) :saved (coerce saved 'simple-vector) :rng (sim-rnd-state))))))

(defun sim-restore (s)
  "Put the sim back as SIM-SNAPSHOT saved it in S (in place: the same objects get their saved contents back)."
  (let ((objs (simsnap-objs s)) (saved (simsnap-saved s)))
    (dotimes (i (length objs))
      (let ((x (svref objs i)) (c (svref saved i)))
        (cond ((consp x) (setf (car x) (car c) (cdr x) (cdr c)))
              ((arrayp x) (let ((d (cdr c)))
                            (when (car c) (setf (fill-pointer x) (car c)))
                            (dotimes (j (length d)) (setf (row-major-aref x j) (aref d j)))))
              ((hash-table-p x) (clrhash x) (dolist (p c) (setf (gethash (car p) x) (cdr p))))
              (t (dotimes (j (length c)) (si:instance-set x j (svref c j)))))))
    (loop for sym across (simsnap-roots s) for v across (simsnap-vals s) do (setf (symbol-value sym) v))
    (setf (sim-rnd-state) (simsnap-rng s))
    s))

(defun simsnap-count (s) "How many objects S saved (a measure of its size)." (length (simsnap-objs s)))
