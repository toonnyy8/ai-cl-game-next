;;;; hem-spring.lisp — the lag spring that swings a pelvis-hung cloth (a haori hem, a cloak) about the obi, a look shared by
;;;; Ichigo's cloak (ichigo-look.lisp ICHIGO-CLOAK-POSE) and, until it left, Yamamoto's haori (DUEL_YAMA_TYBW §3.1). Moved
;;;; verbatim, names kept (%YA-HEM-*, *YA-HEM-*), out of yama-art.lisp by refactor batch B3 (REFACTOR_2026-11 §11.3 R2) so the
;;;; retired kits' files could leave main. It stays in the game: refactor R13 skipped the planned engine move (E2, anim.lisp
;;;; spring-chain-*): one live caller (Ichigo's cloak), and the pose bakes in the look (the obi's 0.06 m offset, the breath on
;;;; the fx clock, the swing's axis order), so an engine API would be ~8 arguments for one user. A look: nothing here is read by
;;;; the sim, no random number, 0 B a frame.
(in-package :duel)

(defparameter *ya-hem-k* 60.0 "The hem spring's stiffness (1/s^2, ~1.2 Hz). New 2026-10-13 (DUEL_YAMA_TYBW §3.1, the lead's look).")
(defparameter *ya-hem-c* 4.6 "Its damping (1/s): ~0.3 of critical, so the hem overshoots once when he stops.")
(defparameter *ya-hem-drag* 0.03 "The hem's trail per m/s of the obi's travel (rad): a run (~8 m/s) ~14 deg.")
(defparameter *ya-hem-turn* 0.05 "Its yaw lag per rad/s of the pelvis's turn (rad).")
(defparameter *ya-hem-max* 0.42 "The swing's cap (rad, ~24 deg) back / forward and sideways; the yaw lag's is 0.3.")
;; The state vector (ST of the functions below; Ichigo's is *IC-LOOK*), per side 16 floats: [0..2] the obi's world point at the last
;; step, [3] the pelvis heading then, [4 5] the back swing (rad) and its rate, [6 7] the side swing and rate, [8 9] the yaw lag and
;; rate, [10] 1 once primed, [11..13] the obi's point this frame, [14] the heading this frame.
(declaim (type f32vec *ya-hem-m*))
(defvar *ya-hem-m* (make-f32 16) "YAMA-POSE's scratch matrix: the swing about the obi.")

(defun-fast %ya-hem-pose (jm st o on)
  "Record the obi's world point and the pelvis heading in ST (the side's offset O); when ON is 1, swing the pelvis matrix
(JM 0..15) about the obi (its local (0 0.06 0)) by ST's angles plus a slow breath."
  (declare (type f32vec jm st) (fixnum o on))
  (setf (aref st (+ o 11)) (+ (* 0.06f0 (aref jm 4)) (aref jm 12))
        (aref st (+ o 12)) (+ (* 0.06f0 (aref jm 5)) (aref jm 13))
        (aref st (+ o 13)) (+ (* 0.06f0 (aref jm 6)) (aref jm 14))
        (aref st (+ o 14)) (f-atan2 (aref jm 8) (aref jm 10)))
  (when (= on 1)
    (let* ((c (fx-clock)) (r *ya-hem-m*) (yl (aref st (+ o 8)))
           (back (+ (aref st (+ o 4)) (* 0.02f0 (f-sin (* 1.3f0 c)))))
           (side (+ (aref st (+ o 6)) (* 0.012f0 (f-sin (* 0.9f0 c))))))
      (declare (single-float c yl back side) (type f32vec r))
      ;; Ry(yaw lag) Rx(-back: the hem's foot goes behind him, +z) Rz(side: its foot to his right), about the obi
      (%euler! r 0 0f0 0f0 0f0 yl (- back) side 1f0)
      (setf (aref r 12) (* -0.06f0 (aref r 4)) (aref r 13) (- 0.06f0 (* 0.06f0 (aref r 5))) (aref r 14) (* -0.06f0 (aref r 6)))
      (m4-mul! jm jm r)))
  nil)

(defmacro %ya-spring (st i tgt dt)
  "Step the angle ST[I] (its rate ST[I+1]) toward TGT over DT s (semi-implicit Euler), capped at *YA-HEM-MAX*."
  `(let* ((%a (aref ,st ,i)) (%r (+ (aref ,st (+ ,i 1))
                                   (* ,dt (- (* (the single-float (f32 *ya-hem-k*)) (- ,tgt %a))
                                             (* (the single-float (f32 *ya-hem-c*)) (aref ,st (+ ,i 1))))))))
     (declare (single-float %a %r))
     (setf (aref ,st (+ ,i 1)) %r
           (aref ,st ,i) (f-clamp (+ %a (* ,dt %r)) (- (the single-float (f32 *ya-hem-max*))) (the single-float (f32 *ya-hem-max*))))))

(defun-fast %ya-hem-step (st o dt)
  "Step side O's hem spring in ST by DT effect seconds (substeps of <= 1/60 s): targets from the obi's travel (the hem
trails it) and the pelvis's turn (it lags); a jump over 1.5 m (a reset, a cinematic's placing) re-primes it."
  (declare (type f32vec st) (fixnum o) (single-float dt))
  (when (> dt 0f0)
    (let* ((x (aref st (+ o 11))) (y (aref st (+ o 12))) (z (aref st (+ o 13))) (h (aref st (+ o 14)))
           (dx (- x (aref st o))) (dy (- y (aref st (+ o 1)))) (dz (- z (aref st (+ o 2))))
           (dh (- h (aref st (+ o 3)))))
      (declare (single-float x y z h dx dy dz dh))
      (when (> dh 3.1415927f0) (decf dh 6.2831855f0))
      (when (< dh -3.1415927f0) (incf dh 6.2831855f0))
      (if (or (< (aref st (+ o 10)) 0.5f0) (> (f-hypot dx dy dz) 1.5f0))
          (progn (setf (aref st (+ o 10)) 1f0)
                 (loop for i fixnum from (+ o 4) below (+ o 10) do (setf (aref st i) 0f0)))
          (let* ((bx (f-sin h)) (bz (f-cos h))           ; the pelvis's back (its local +z) on the ground
                 (vf (/ (- (+ (* dx bx) (* dz bz))) dt)) (vr (/ (- (* dx bz) (* dz bx)) dt)) (w (/ dh dt))
                 (drag (the single-float (f32 *ya-hem-drag*))) (mx (the single-float (f32 *ya-hem-max*)))
                 (tb (f-clamp (* drag vf) (- mx) mx)) (ts (f-clamp (* (- drag) vr) (- mx) mx))
                 (ty (f-clamp (* (- (the single-float (f32 *ya-hem-turn*))) w) -0.3f0 0.3f0))
                 (n (max 1 (min 4 (f->i (+ 0.999f0 (* 60f0 dt)))))) (sdt (/ dt (i->f n))))
            (declare (single-float bx bz vf vr w drag mx tb ts ty sdt) (fixnum n))
            (dotimes (k n)
              (%ya-spring st (+ o 4) tb sdt) (%ya-spring st (+ o 6) ts sdt) (%ya-spring st (+ o 8) ty sdt))))
      (setf (aref st o) x (aref st (+ o 1)) y (aref st (+ o 2)) z (aref st (+ o 3)) h)))
  nil)
