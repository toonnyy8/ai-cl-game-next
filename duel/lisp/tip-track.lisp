;;;; tip-track.lisp — a weapon tip's tracking and a hit volume's far point, shared by Ichigo's looks (ichigo-look.lisp) and
;;;; Kenpachi's (ken-look.lisp): %IC-FRAME, %IC-HELD-TIP, %IC-TRACK, %IC-FAR. Moved verbatim, names kept, out of ichigo-look.lisp
;;;; by refactor batch B3 (REFACTOR_2026-11 §11.3 R2). Cosmetic: nothing here is read by the sim; 0 B a frame.
(in-package :duel)

(defun-fast %ic-frame (st i sf)
  "ST[I] = the move frame SF; the frame it held before (a fixnum)."
  (declare (type f32vec st) (fixnum i sf))
  (prog1 (f->i (aref st i)) (setf (aref st i) (i->f sf))))

(defun-fast %ic-held-tip (jm tip len)
  "TIP = the held weapon's tip: the :weapon-r joint's point (0 0 -LEN), JOINT-POINT!'s sum inline (BODY-WEAPON-TIP's
call boxes the float)."
  (declare (type f32vec jm tip) (single-float len))
  (let ((o (* 16 (ji :weapon-r))))
    (declare (fixnum o))
    (dotimes (i 3) (setf (aref tip i) (- (aref jm (+ o 12 i)) (* len (aref jm (+ o 8 i)))))))
  nil)

(defun-fast %ic-track (st o d tip)
  "Track a blade's tip: ST[O..O+2] its last point; ST[D..D+2] the unit direction it last moved in (kept while it stands,
or across a jump over 1.5 m)."
  (declare (type f32vec st tip) (fixnum o d))
  (let* ((x (aref tip 0)) (y (aref tip 1)) (z (aref tip 2))
         (dx (- x (aref st o))) (dy (- y (aref st (+ o 1)))) (dz (- z (aref st (+ o 2)))) (l (f-hypot dx dy dz)))
    (declare (single-float x y z dx dy dz l))
    (when (and (> l 0.01f0) (< l 1.5f0))
      (setf (aref st d) (/ dx l) (aref st (+ d 1)) (/ dy l) (aref st (+ d 2)) (/ dz l)))
    (setf (aref st o) x (aref st (+ o 1)) y (aref st (+ o 2)) z))
  nil)

(defun-fast %ic-far (v p yaw tip out)
  "OUT = the far point of hit volume V for a fighter at P (his feet) facing YAW: an arc's rim on the bearing of TIP, a
capsule's end, a sphere's far side; its height the tip's, clamped to 0.1-1.5 m (a sphere's: its centre). NIL for none.
(No float crosses a call here or below: a boxed argument is a cons.)"
  (declare (type f32vec v p tip out) (single-float yaw))
  (let ((ty (f-clamp (aref tip 1) 0.1f0 1.5f0)) (k (aref v 0))
        (px (aref p 0)) (pz (aref p 2)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
    (declare (single-float ty k px pz fx fz))
    (cond ((< k 0.5f0)
           (let* ((bx (- (aref tip 0) px)) (bz (- (aref tip 2) pz)) (l (f-hypot bx bz)) (r (aref v 1)))
             (declare (single-float bx bz l r))
             (if (< l 0.05f0) (setf bx fx bz fz) (setf bx (/ bx l) bz (/ bz l)))
             (setf (aref out 0) (+ px (* r bx)) (aref out 1) ty (aref out 2) (+ pz (* r bz)))
             t))
          ((< k 1.5f0)
           (let* ((yo (aref v 5)) (c (f-cos yo)) (sn (f-sin yo))
                  (ux (+ (* fx c) (* fz sn))) (uz (- (* fz c) (* fx sn))) (b (aref v 2)))
             (declare (single-float yo c sn ux uz b))
             (setf (aref out 0) (+ px (* b ux)) (aref out 1) ty (aref out 2) (+ pz (* b uz)))
             t))
          ((< k 2.5f0)
           (let ((d (+ (aref v 1) (aref v 3))))
             (declare (single-float d))
             (setf (aref out 0) (+ px (* d fx)) (aref out 1) (aref v 2) (aref out 2) (+ pz (* d fz)))
             t))
          (t nil))))
