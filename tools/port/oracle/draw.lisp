;;;; draw.lisp — drives the frozen native image (built with tools/port/oracle/stubs-draw.c) through one draw scene of the draw key
;;;; (docs/bevy/M3A_NOTES.md §1; gen.py draw runs it, twice per scene):
;;;;   env LD_PRELOAD=build/simgate/muslm.so DRAW_FRAMES=... DRAW_OUT=... [DRAW_W DRAW_H DRAW_DPR] \
;;;;     $ECL_HOST --norc --load tools/port/oracle/draw.lisp -- build/oracle/draw-img/duel.fas BUDGET CMD...
;;;; Starts as the page does (SG-INIT), names every mesh made so far, then runs real frames (ENGINE::%FRAME: drawn, not turbo). A CMD is
;;;; "C" (debug command C, queued before frame 0: it runs at the first frame's start, from the title) or "F:C" (queued before frame F).
;;;; When the recorder has written its file (it sets DRAW_DONE=1) the meshes made since are named too and it exits 0. Exit 4: BUDGET
;;;; frames ran out first; exit 3: %FRAME stopped.
;;;; Lines (stdout, besides the game's own log):
;;;;   draw mesh <id> <verts> <path>   per mesh: the shortest path to its MESH struct from a special variable of DUEL / ENGINE (BFS over
;;;;                                   conses, general vectors, hash tables (keys sorted by their printed form) and structure slots),
;;;;                                   (none: no line; gen.py names it "?" and fails); those made at startup first, then those made
;;;;                                   while it ran
;;;;   draw seed <frame> <seed>        *MATCH-SEED* at frame 0 and whenever it changes (after that frame)
;;;;   draw f <frame> <tick> <match-tick> <flow> <cine> <cf> <held> <hitstop>   after each frame: ENGINE::*TICK*, *MATCH-TICK*, *FLOW*,
;;;;                                   the running cinematic's name and frame (- -1: none), 1 when debug-held (CINE-HELD-P), ENGINE::*HITSTOP*
;;;;   draw inputs start|end render-scale R pixel-lights N scene-scale-cap C msaa M coarse B one-hand B   the fixed inputs, read
;;;;                                   after SG-INIT and at the end
;;;; (the recorder's own lines start "draw: ", stubs-draw.c's header.)
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defparameter *dw-args* (rest cl-user::*sg-args*))
(defparameter *dw-budget* (parse-integer (first *dw-args*)))
(defparameter *dw-cmds*   ; ((frame . cmd) ...)
  (mapcar (lambda (s) (let ((i (position #\: s)))
                        (if i (cons (parse-integer s :end i) (parse-integer s :start (1+ i))) (cons 0 (parse-integer s)))))
          (rest *dw-args*)))

;;; ---------------------------------------------------------------- the meshes' names
(defvar *dw-named* (make-hash-table) "mesh id -> T once its line is printed.")

(defun dw-key-string (k) (let ((*print-pretty* nil) (*package* (find-package :duel))) (prin1-to-string k)))

(defun dw-path (node)
  "NODE = (object parent label): the labels from the root down."
  (let ((parts nil))
    (loop for n = node then (second n) while n do (push (third n) parts))
    (format nil "~{~a~}" parts)))

(defun dw-children (x fn)
  "FN (child label) for each child of X the walk follows."
  (typecase x
    (cons (loop for c = x then (cdr c) for i from 0
                while (consp c) do (funcall fn (car c) (format nil "[~d]" i))
                finally (when c (funcall fn c "."))))
    (string nil)
    ((and vector (not simple-array)) (when (eq (array-element-type x) t) (dotimes (i (length x)) (funcall fn (aref x i) (format nil "[~d]" i)))))
    (simple-vector (dotimes (i (length x)) (funcall fn (svref x i) (format nil "[~d]" i))))
    (hash-table (let ((ks nil))
                  (maphash (lambda (k v) (push (cons (dw-key-string k) v) ks)) x)
                  (dolist (kv (sort ks #'string< :key #'car)) (funcall fn (cdr kv) (format nil "{~a}" (car kv))))))
    (structure-object (dolist (s (clos:class-slots (class-of x)))
                        (let ((n (clos:slot-definition-name s)))
                          (when (slot-boundp x n) (funcall fn (slot-value x n) (format nil ".~a" (symbol-name n)))))))))

(defun dw-name-meshes ()
  "Print a line for every mesh not named yet (the shortest path from a special variable, else ?)."
  (let ((seen (make-hash-table :test 'eq)) (queue nil) (tail nil) (found (make-hash-table)) (roots nil))
    (flet ((push-node (obj parent label)
             (unless (or (null obj) (symbolp obj) (numberp obj) (characterp obj) (functionp obj) (gethash obj seen))
               (setf (gethash obj seen) t)
               (let ((cell (list (list obj parent label))))
                 (if tail (setf (cdr tail) cell tail cell) (setf queue cell tail cell))))))
      (dolist (p '(:duel :engine))
        (do-symbols (s p) (when (and (eq (symbol-package s) (find-package p)) (boundp s) (not (constantp s))) (push s roots))))
      (dolist (s (sort (remove-duplicates roots) #'string< :key #'dw-key-string))
        (push-node (symbol-value s) nil (dw-key-string s)))
      (loop while queue
            do (let* ((node (pop queue)) (x (first node)))
                 (when (null queue) (setf tail nil))
                 (if (typep x 'engine::mesh)
                     (unless (gethash (engine::mesh-id x) found) (setf (gethash (engine::mesh-id x) found) (cons x node)))
                     (dw-children x (lambda (c label) (push-node c node label)))))))
    (let ((ids nil))
      (maphash (lambda (id v) (declare (ignore v)) (push id ids)) found)
      (dolist (id (sort ids #'<))
        (unless (gethash id *dw-named*)
          (setf (gethash id *dw-named*) t)
          (destructuring-bind (m . node) (gethash id found)
            (format t "draw mesh ~d ~d ~a~%" id (engine::mesh-count m) (dw-path node))))))))

;;; ---------------------------------------------------------------- the scene
(defun dw-inputs (when)
  (format t "draw inputs ~a render-scale ~a pixel-lights ~a scene-scale-cap ~a msaa ~a coarse ~a one-hand ~a~%" when
          engine::*render-scale* engine::*pixel-lights* engine::*scene-scale-cap* engine::*msaa-samples* *coarse* *one-hand*))

(cl-user::sg-init)
(dw-inputs "start")
(dw-name-meshes)
(let ((seed nil))
  (dotimes (f *dw-budget*)
    (dolist (c *dw-cmds*) (when (= (car c) f) (engine::simgate-cmd (cdr c))))
    (unless (engine::%frame) (ext:quit 3))
    (unless (eql seed *match-seed*) (setf seed *match-seed*) (format t "draw seed ~d ~d~%" f seed))
    (format t "draw f ~d ~d ~d ~a ~a ~d ~a ~d~%" f engine::*tick* *match-tick* *flow* (if *cine* (cine-name *cine*) "-")
            (if *cine* (cine-cf *cine*) -1) (if (cine-held-p) 1 0) engine::*hitstop*)
    (when (ext:getenv "DRAW_DONE")
      (dw-inputs "end")
      (dw-name-meshes)
      (finish-output)
      (ext:quit 0))))
(ext:quit 4)
