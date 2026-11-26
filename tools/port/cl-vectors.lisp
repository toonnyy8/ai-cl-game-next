;;;; cl-vectors.lisp — test vectors for rs/duel-sim's cl / math / hitvol / rng ports (Bevy port M1 Task 2), taken from the frozen
;;;; native image: CL rounding, printing, the sim stream, the engine's angle helpers and the hit volumes, every float as its IEEE bits.
;;;; Usage (repo root):
;;;;   LD_PRELOAD=build/simgate/muslm.so $ECL_HOST --norc --load tools/port/cl-vectors.lisp -- build/simgate/duel.fas | grep -v '^;' \
;;;;     > rs/duel-sim/testdata/cl_vectors.txt
;;;; Line format: NAME ARG... = RESULT...; a token is s:HEX (single bits), d:HEX (double bits), i:N (integer), b:T / b:NIL, or a bare
;;;; string (PRIN1 / FORMAT output, never with spaces).
(defparameter cl-user::*args* (cdr (member "--" ext:*command-args* :test #'string=)))
(load (first cl-user::*args*) :verbose nil)
(load (merge-pathnames "oracle/trace.lisp" (directory-namestring *load-truename*)) :verbose nil)   ; TR-F32-BITS
(in-package :duel)
;; SIM-RND01 is a C-INLINE macro (the interpreter refuses it): compile one call against the image's own rng2_state (the header gives
;; the inline rng2_float; the loaded fas exports the state), run from the repo root.
(require :cmp)
(setf c::*cc-flags* (format nil "~a -msse2 -mfpmath=sse -ffp-contract=off -I. -Itools/simgate/include -Ivendor/sdl3-webgpu/include -include engine/c/engine.h" c::*cc-flags*))
(setf (symbol-function 'sim-rnd01-fn) (compile nil '(lambda () (engine::sim-rnd01))))

(defun tok (x)
  (etypecase x
    (single-float (format nil "s:~8,'0x" (tr-f32-bits x)))
    (double-float (format nil "d:~16,'0x" (tr-f32-bits x)))
    (integer (format nil "i:~d" x))
    (string x)
    (symbol (format nil "b:~a" (if x "T" "NIL")))))
(defun row (name args &rest results)
  (format t "~a~{ ~a~} =~{ ~a~}~%" name (mapcar #'tok args) (mapcar #'tok results)))

;;; a deterministic stream for the bulk cases (integer LCG, host bignums are fine here)
(defvar *lcg* 12345)
(defun u01 () (setf *lcg* (mod (+ (* *lcg* 6364136223846793005) 1442695040888963407) (expt 2 64))) (/ (float (ash *lcg* -40) 1d0) (expt 2 24)))
(defun rs (lo hi) (float (+ lo (* (- hi lo) (u01))) 1f0))

;;; ---------------------------------------------------------------- the sim stream
(dolist (seed '(1 2 3 0 -5 12345 536870911))
  (engine::sim-rnd-seed seed)
  (let* ((s0 (engine::sim-rnd-state)) (r1 (sim-rnd01-fn)) (r2 (sim-rnd01-fn)) (r3 (sim-rnd01-fn)))
    (row "rng-seed" (list seed) s0 r1 r2 r3 (engine::sim-rnd-state))))
(setf (engine::sim-rnd-state) 0)
(row "rng-set-state" (list 0) (engine::sim-rnd-state))

;;; ---------------------------------------------------------------- CL rounding and integer division
(dolist (x '(0.5f0 1.5f0 2.5f0 -0.5f0 -1.5f0 -2.5f0 3.4999998f0 3.5f0 -3.5f0 0.49999997f0 7.0f0 -7.25f0 1234.5f0 16777215.0f0 0.0f0 -0.0f0))
  (row "round-f32" (list x) (round x))
  (row "floor-f32" (list x) (floor x))
  (row "truncate-f32" (list x) (truncate x)))
(dolist (x '(0.5d0 1.5d0 2.5d0 -0.5d0 -2.5d0 4.5000000001d0 1d15 -123.5d0 0.0d0))
  (row "round-f64" (list x) (round x))
  (row "floor-f64" (list x) (floor x)))
(dolist (ab '((-7 2) (7 2) (7 -2) (-7 -2) (6 3) (-6 3) (0 5) (-1 600) (599 600) (-75001 80)))
  (destructuring-bind (a b) ab
    (row "floor-div" ab (floor a b))
    (row "mod" ab (mod a b))
    (row "rem" ab (rem a b))))

;;; ---------------------------------------------------------------- printing
(dolist (x (list 0.3f0 -1.0f0 -0.0f0 0.70710677f0 1.0f10 1.0f7 9999999.0f0 1.0f-3 9.999999f-4 1.0f-4 123.456f0 0.1f0 1.0f0 0.0f0
                 3.1415927f0 1.5f-7 3.4028235f38 16777216.0f0 100.0f0 12345678.0f0 0.001f0 2.5f0 (/ 1f0 3f0)))
  (row "fmt-f32" (list x) (prin1-to-string x)))
(dolist (x '(0.25f0 0.35f0 0.05f0 0.15f0 1.05f0 2.5f0 -0.25f0 -0.04f0 0.0f0 -0.0f0 99.95f0 123.456f0 0.45f0 1.25f0 1.0f10))
  (dolist (d '(0 1 2 3))
    (row "fmt-fixed-s" (list x d) (format nil "~,vf" d x))))
(dolist (x '(0.25d0 0.35d0 0.05d0 0.15d0 1.05d0 2.5d0 -0.25d0 -0.04d0 0.0d0 99.95d0 123.456d0 0.45d0 1.25d0 0.5d0 1.5d0))
  (dolist (d '(0 1 2 3))
    (row "fmt-fixed-d" (list x d) (format nil "~,vf" d x))))

;;; ---------------------------------------------------------------- engine math, rules' dir-yaw
(dolist (x '(0 90 -45 180 360 30.0f0 -12.5f0 0.1f0 7.5d0))
  (row "deg" (list x) (engine::deg x)))
(dolist (a (list 0.0f0 1.0f0 -1.0f0 3.1415925f0 3.1415927f0 -3.1415927f0 -3.1415925f0 6.2831855f0 -6.2831855f0 10.0f0 -10.0f0
                 100.0f0 -1000.5f0 4.712389f0 1.0f-8))
  (row "angle-wrap" (list a) (engine::angle-wrap a)))
(dotimes (i 40) (let ((a (rs -20 20))) (row "angle-wrap" (list a) (engine::angle-wrap a))))
(dolist (y (list 0.0f0 -0.0f0 1.0f0 -1.0f0 3.1415927f0 1.5707964f0 0.7853982f0 -2.5f0 100.0f0))
  (row "fwd-x" (list y) (engine::fwd-x y))
  (row "fwd-z" (list y) (engine::fwd-z y)))
(dotimes (i 30) (let ((y (rs -7 7))) (row "fwd-x" (list y) (engine::fwd-x y)) (row "fwd-z" (list y) (engine::fwd-z y))))
(dolist (p '((0.0f0 1.0f0) (1.0f0 0.0f0) (0.0f0 -1.0f0) (-1.0f0 0.0f0) (0.0f0 0.0f0) (-0.0f0 0.0f0) (0.0f0 -0.0f0) (3.0f0 4.0f0)
             (-2.5f0 0.1f0) (1.0f-6 -5.0f0)))
  (row "dir-yaw" p (apply #'dir-yaw p))
  (row "yaw-to" p (apply #'engine::yaw-to p)))
(dotimes (i 40) (let ((p (list (rs -9 9) (rs -9 9)))) (row "dir-yaw" p (apply #'dir-yaw p)) (row "yaw-to" p (apply #'engine::yaw-to p))))
(dotimes (i 30)
  (let ((p (list (rs -7 7) (rs -7 7) (rs 0 0.5)))) (row "turn-toward" p (apply #'engine::turn-toward p))))
(dotimes (i 10)
  (let ((p (list (rs -7 7) (rs -7 7) (rs 0 1)))) (row "lerp" p (apply #'lerp p)) (row "clamp" p (clamp (first p) -1.0f0 (second p)))))

;;; ---------------------------------------------------------------- hit volumes
;;; Each function is called as (FN ARGS...) with the target's x at index TXI. A random case is printed; when it hits, TX is also bisected
;;; (in single-floats) toward a far miss down to two adjacent floats, and both are printed: the rows that catch a float slip.
(defun hit-rows (name args fn txi)
  (let ((hit (apply fn args)))
    (row name args hit)
    (when hit
      (let ((lo (nth txi args)) (hi 20f0))
        (flet ((at (x) (let ((a (copy-list args))) (setf (nth txi a) x) a)))
          (loop for mid = (float (/ (+ lo hi) 2) 1f0)
                until (or (= mid lo) (= mid hi))
                do (if (apply fn (at mid)) (setf lo mid) (setf hi mid)))
          (row name (at lo) (apply fn (at lo)))
          (row name (at hi) (apply fn (at hi))))))))
(dolist (spec '((:arc 2.0 90 0.2 1.6) (:arc 1.5f0 360 0 2) (:arc 2.6 200 0 2) (:cap 0.3 1.8 1.1 0.25) (:cap 0 2.5 1.0 0.3 -20)
                (:cap 0.5 2 0.9 0.4 35.5) (:sph 1.2 1.0 0.5) (:tsph 0.6)))
  (let ((v (coerce (engine::make-vol (first spec) (rest spec)) 'list)))
    (dotimes (i 120)
      (let ((yaw (rs -3.2 3.2)))
        (hit-rows "vol-hit-p" (append v (list (rs -2 2) (rs 0 0.6) (rs -2 2) (engine::fwd-x yaw) (engine::fwd-z yaw)
                                              (rs -3 3) (rs 0 1) (rs -3 3) (rs 0.2 0.5) (rs 1.2 1.9) (if (zerop (mod i 4)) (rs 0 0.6) 0f0)))
                  (lambda (&rest a) (apply #'engine::vol-hit-p (coerce (subseq a 0 6) '(simple-array single-float (*))) (nthcdr 6 a)))
                  11)))))
(dotimes (i 150)
  (let ((args (list (rs -3 3) (rs 0 2) (rs -3 3) (rs -3 3) (rs 0 2) (rs -3 3) (rs 0.05 0.6) (rs -3 3) (rs 0 1) (rs -3 3) (rs 0.2 0.5) (rs 1.2 1.9))))
    (when (zerop (mod i 10)) (setf (fourth args) (first args) (fifth args) (second args) (sixth args) (third args)))   ; a = b
    (when (= (mod i 10) 5) (setf (nth 11 args) 0f0 (nth 10 args) 0f0))                                                ; a flat cylinder
    (when (= (mod i 10) 7) (setf (fourth args) (first args) (sixth args) (third args)))                                ; a vertical capsule
    (hit-rows "capsule-cyl-hit-p" args #'engine::capsule-cyl-hit-p 7)))
(dotimes (i 150)
  (hit-rows "obox-cyl-hit-p" (list (rs -3 3) (rs 0 2) (rs -3 3) (rs -3.2 3.2) (rs 0.1 1.5) (rs 0.1 1.5) (rs 0.1 2) (rs -3 3) (rs 0 1) (rs -3 3)
                                   (rs 0.2 0.5) (rs 1.2 1.9))
            #'engine::obox-cyl-hit-p 7))
(dotimes (i 100)
  (hit-rows "cyl-cyl-hit-p" (list (rs -2 2) (rs 0 2) (rs -2 2) (rs 0.2 1) (rs 0.5 2) (rs -2 2) (rs 0 2) (rs -2 2) (rs 0.2 1) (rs 0.5 2))
            #'engine::cyl-cyl-hit-p 5))

;;; ---------------------------------------------------------------- printing, a sweep (every trace text line goes through PRIN1)
(dotimes (i 3000)
  (let ((x (scale-float (float (+ (expt 2 23) (floor (* (u01) (expt 2 23)))) 1f0) (- (floor (* (u01) 81)) 63))))
    (when (oddp i) (setf x (- x)))
    (row "fmt-f32" (list x) (prin1-to-string x))))
(dotimes (i 400)
  (let ((x (float (* (- (u01) 0.5d0) (expt 10 (floor (* (u01) 10)))) 1f0)))
    (dolist (d '(0 1 2 3)) (row "fmt-fixed-s" (list x d) (format nil "~,vf" d x)))))

;;; ---------------------------------------------------------------- the environment: a bare float literal is a single-float, musl's libm
(row "literal-single" nil (typep 0.5 'single-float) (typep 1e-8 'single-float))
(row "musl-loaded" nil (with-open-file (in "/proc/self/maps") (loop for l = (read-line in nil) while l thereis (and (search "muslm" l) t))))
(row "deg" (list 1) (engine::deg 1))
(finish-output)
(ext:quit 0)
