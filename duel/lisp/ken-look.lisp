;;;; ken-look.lisp — Kenpachi's Shikai looks on the posed body (his kit's :draw hook, KIT-HOOK): the sword wind by the unlock level L
;;;; (DUEL_KEN_V3 §5.3, §16; the user 2026-11-02: 「特效請用於增強斬擊演出，包含揮砍時引出的劍風等等」). On every hit window of a Shikai move,
;;;; drawn only (the hit volumes never grow): L0 the plain smear (draw.lisp's REIATSU comet); L1 wind streaks peeling off the edge behind
;;;; the tip; L2 + a wind crescent thrown along the cut past his reach and a dust line along the floor; L3 + a second, wider crescent, the
;;;; floor cracked under the far point with rubble and a camera shake. The level a cut shows is L now, a burst's the route's (L went back
;;;; to 0 as it started). The tip tracking and the far point are Ichigo's helpers (ichigo-look.lisp %IC-HELD-TIP / %IC-TRACK / %IC-FAR).
(in-package :duel)

(declaim (type f32vec *ke-look* *ke-tip* *ke-far*))
(defvar *ke-look* (make-f32 32)
  "Per side (16 floats): [0..2] the held tip at the last draw, [3..5] its cut direction (unit), [6] the move frame of the last draw
(-1: none).")
(defvar *ke-tip* (make-f32 3) "KEN-DRAW's held tip.")
(defvar *ke-far* (make-f32 5) "The hit volume's far point (%IC-FAR's layout; [3] / [4] unused).")
(defparameter *ke-wind-life* 10 "Frames the wind crescent flies after its hit window opens (and the streaks linger after it closes).")

(defun-fast-inline %ke-streaks (st d tip px pz lv k)
  "L1+: three thin white streaks peeling off behind TIP against its cut direction ST[D..], fanned out from his centre (PX PZ), longer
by LV; K presence."
  (declare (type f32vec st tip) (fixnum d lv) (single-float px pz k))
  (let* ((x (aref tip 0)) (y (aref tip 1)) (z (aref tip 2)) (dx (aref st d)) (dy (aref st (+ d 1))) (dz (aref st (+ d 2)))
         (rx (- x px)) (rz (- z pz)) (rl (f-max 0.05f0 (f-hypot rx rz))) (ux (/ rx rl)) (uz (/ rz rl))
         (len (* 0.6f0 (i->f (+ 1 lv)))) (dr (drawing-no)))
    (declare (single-float x y z dx dy dz rx rz rl ux uz len dr))
    (dotimes (j 3)
      (let* ((fj (i->f j)) (out (+ 0.08f0 (* 0.14f0 fj))) (l (* len (- 1f0 (* 0.22f0 fj))))
             (x0 (+ x (* out ux) (* (- l) dx))) (y0 (+ y (* (- 0.1f0 (* 0.1f0 fj)) 1f0) (* (- l) dy))) (z0 (+ z (* out uz) (* (- l) dz)))
             (x1 (+ x (* out ux))) (y1 (+ y (* (- 0.1f0 (* 0.1f0 fj)) 1f0))) (z1 (+ z (* out uz))))
        (declare (single-float fj out l x0 y0 z0 x1 y1 z1))
        (fx-crescent x0 y0 z0 x1 y1 z1 (+ (* 0.5f0 (+ x0 x1)) (* 0.12f0 ux)) (* 0.5f0 (+ y0 y1)) (+ (* 0.5f0 (+ z0 z1)) (* 0.12f0 uz))
                     (* 0.03f0 (i->f (+ 1 lv))) :lens 0.04f0 (+ 410f0 fj dr) +pal-hit+ (* k (- 1f0 (* 0.2f0 fj))) :push 0.12f0))))
  nil)

(defun-fast-inline %ke-crescent (st d tip far px pz t0 w k seed)
  "A wind crescent T0 of the way along its flight: thrown from TIP's bearing out of his centre (PX PZ) to 1.6 x FAR's distance, at the
tip's height (0.6-1.8 m) sinking toward 1.0 m; its chord the cut itself (along the cut direction ST[D..], 2.4 m), bulging ahead along the
flight: the blade's path flying on. A white lens W thick with an ink rim behind it."
  (declare (type f32vec st tip far) (fixnum d) (single-float px pz t0 w k seed))
  (let* ((fx (- (aref far 0) px)) (fz (- (aref far 2) pz)) (fl (f-max 0.1f0 (f-hypot fx fz))) (ux (/ fx fl)) (uz (/ fz fl))
         (dist (* fl (+ 0.6f0 (* 1.0f0 t0)))) (cx (+ px (* dist ux))) (cz (+ pz (* dist uz)))
         (ty (f-clamp (aref tip 1) 0.6f0 1.8f0)) (cy (+ ty (* t0 (- 1.0f0 ty))))
         (dx (aref st d)) (dy (aref st (+ d 1))) (dz (aref st (+ d 2)))
         (du (+ (* dx ux) (* dz uz))) (ax (- dx (* du ux))) (ay dy) (az (- dz (* du uz)))     ; the cut, across the flight
         (al (f-hypot ax ay az)))
    (declare (single-float fx fz fl ux uz dist cx cz ty cy dx dy dz du ax ay az al))
    (if (< al 0.2f0) (setf ax (- uz) ay 0f0 az ux) (setf ax (/ ax al) ay (/ ay al) az (/ az al)))   ; (a thrust: level across)
    (let* ((h 1.2f0) (b (* 0.4f0 h))
           (x0 (- cx (* h ax))) (y0 (f-max 0.1f0 (- cy (* h ay)))) (z0 (- cz (* h az)))
           (x1 (+ cx (* h ax))) (y1 (f-max 0.1f0 (+ cy (* h ay)))) (z1 (+ cz (* h az))))
      (declare (single-float h b x0 y0 z0 x1 y1 z1))
      (fx-crescent (- x0 (* 0.08f0 ux)) y0 (- z0 (* 0.08f0 uz)) (- x1 (* 0.08f0 ux)) y1 (- z1 (* 0.08f0 uz))
                   (+ cx (* (- b 0.08f0) ux)) cy (+ cz (* (- b 0.08f0) uz)) (* 1.35f0 w) :lens 0.05f0 seed +pal-ink+ (* 0.85f0 k) :push 0.08f0)   ; (the rim)
      (fx-crescent x0 y0 z0 x1 y1 z1 (+ cx (* b ux)) cy (+ cz (* b uz)) w :lens 0.05f0 (+ seed 7f0) +pal-hit+ k :push 0.14f0)))
  nil)

(defun-fast-inline %ke-dust-line (far px pz t0 k seed)
  "L2+: a dust line along the floor from his feet (PX PZ) toward the far point, running out with T0."
  (declare (type f32vec far) (single-float px pz t0 k seed))
  (let* ((fx (- (aref far 0) px)) (fz (- (aref far 2) pz)) (s (+ 0.4f0 (* 1.4f0 t0)))
         (x1 (+ px (* s fx))) (z1 (+ pz (* s fz))))
    (declare (single-float fx fz s x1 z1))
    (fx-crescent (+ px (* 0.3f0 fx)) 0.03f0 (+ pz (* 0.3f0 fz)) x1 0.03f0 z1 (* 0.5f0 (+ px x1)) 0.12f0 (* 0.5f0 (+ pz z1))
                 0.12f0 :lens 0.1f0 seed +pal-dust+ k :push 0.05f0))
  nil)

(defun-fast %ke-wind (st d v p yaw tip sf from to lv once)
  "One hit window's sword wind at move frame SF (window FROM-TO, volume V; his feet P facing YAW; the cut direction ST[D..]) at level
LV (1-3); ONCE 1 on the frame the window opens (the floor's crack, the rubble, the shake)."
  (declare (type f32vec st v p tip) (fixnum d sf from to lv once))
  (let ((far *ke-far*) (px (aref p 0)) (pz (aref p 2)) (life *ke-wind-life*))
    (declare (single-float px pz) (fixnum life))
    (when (%ic-far v p yaw tip far)
      (let* ((k (if (< sf (+ to 1)) 1f0 (f-max 0f0 (/ (i->f (- (+ to life) sf)) (i->f life)))))
             (t0 (f-clamp (/ (i->f (- sf from)) (i->f life)) 0f0 1f0)) (dr (drawing-no)))
        (declare (single-float k t0 dr))
        (when (< sf (+ to 4)) (%ke-streaks st d tip px pz lv (* 0.9f0 (f-min 1f0 (/ (i->f (- sf (- from 3))) 3f0)))))
        (when (and (>= lv 2) (>= sf from))
          (let ((kc (* 0.95f0 (- 1f0 (* t0 t0)))))
            (declare (single-float kc))
            (%ke-crescent st d tip far px pz t0 (if (>= lv 3) 0.22f0 0.15f0) kc (+ 430f0 dr))
            (when (>= lv 3) (%ke-crescent st d tip far px pz (* 0.7f0 t0) 0.3f0 (* 0.8f0 kc) (+ 450f0 dr)))
            (%ke-dust-line far px pz t0 (* 0.8f0 k) (+ 470f0 dr))))
        (when (= once 1)
          (cond ((>= lv 3) (stage-mark :crack (aref far 0) (aref far 2) 1.1) (stage-debris (aref far 0) (aref far 2) 6) (shake 0.1 0.22))
                ((= lv 2) (stage-debris (aref far 0) (aref far 2) 3)))))))
  nil)

(defun ken-draw (e rdt)
  "KIT-HOOK :draw (the Shikai): the sword wind on each hit window of the move he is in, by the level it shows (L now; a burst's the
route's)."
  (declare (ignore rdt))
  (let* ((f (fighter e)) (m (model e)) (o (* 16 (fighter-side f))) (st *ke-look*)
         (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (sf (if mv (fighter-sf f) -1)) (prev (%ic-frame st (+ o 6) sf)))
    (declare (fixnum o sf prev))
    (when (and mv (model-weapon m) (> (model-alpha m) 0.5))
      (let ((lv (min 3 (if (getf (mv-params mv) :burst) (fighter-lv-cap f) (ken-lv e)))))
        (declare (fixnum lv))
        (let ((jm (model-joints m)) (tip *ke-tip*) (hits (mv-hits mv)))
          (declare (simple-vector hits))
          (%ic-held-tip jm tip (weapon-len (find-weapon (model-weapon m))))
          (%ic-track st o (+ o 3) tip)
          (when (> lv 0)
            (dotimes (i (length hits))
              (let* ((hw (svref hits i)) (from (hw-from hw)) (to (hw-to hw)) (v (first (hw-vols hw))))
                (declare (fixnum from to))
                (when (and v (<= (- from 2) sf) (< sf (+ to *ke-wind-life*)))
                  (%ke-wind st (+ o 3) v (pos-of e) (yaw-of e) tip sf from to lv
                            (if (and (< prev from) (<= from sf)) 1 0)))))))))))
