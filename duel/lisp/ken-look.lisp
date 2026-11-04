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
  "L1+: three white streaks over an ink rim (0.08 m wide at L1, +0.03 a level; §21: 0.06 and no rim read faint) peeling off behind
TIP against its cut direction ST[D..], fanned out from his centre (PX PZ), longer by LV; K presence."
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
                     (* 1.6f0 (+ 0.05f0 (* 0.03f0 (i->f lv)))) :lens 0.04f0 (+ 420f0 fj dr) +pal-ink+ (* 0.6f0 k (- 1f0 (* 0.2f0 fj))) :push 0.08f0)
        (fx-crescent x0 y0 z0 x1 y1 z1 (+ (* 0.5f0 (+ x0 x1)) (* 0.12f0 ux)) (* 0.5f0 (+ y0 y1)) (+ (* 0.5f0 (+ z0 z1)) (* 0.12f0 uz))
                     (+ 0.05f0 (* 0.03f0 (i->f lv))) :lens 0.04f0 (+ 410f0 fj dr) +pal-hit+ (* k (- 1f0 (* 0.2f0 fj))) :push 0.12f0))))
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
        (when (< sf (+ to 7)) (%ke-streaks st d tip px pz lv (* 0.95f0 (f-min 1f0 (/ (i->f (- sf (- from 3))) 3f0))   ; (in over 3 f, out
                                                         (f-min 1f0 (/ (i->f (- (+ to 7) sf)) 5f0)))))       ;  over 5 after it)
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
          (ken-special-look e st o mv sf prev tip)
          (when (> lv 0)
            (dotimes (i (length hits))
              (let* ((hw (svref hits i)) (from (hw-from hw)) (to (hw-to hw)) (v (first (hw-vols hw))))
                (declare (fixnum from to))
                (when (and v (<= (- from 2) sf) (< sf (+ to *ke-wind-life*)))
                  (%ke-wind st (+ o 3) v (pos-of e) (yaw-of e) tip sf from to lv
                            (if (and (< prev from) (<= from sf)) 1 0)))))))))))

;;; ---------------------------------------------------------------- the special ASs' looks (DUEL_KEN_V3 §19)
;;; DAISHARIN (pointer 1, the full wheel): a tornado of white wind arcs round him while the cleaver whirls, a funnel widening
;;; upward and turning with the cuts, a dust ring on the floor; INSEKI-GIRI (pointer 2, the meteor cut): a yellow-white tail
;;; behind the falling blade, then the floor cratered under the far point (cracks, a yellow ring, rubble, a shake).
(defun-fast %ke-tornado (px pz tm k seed)
  "The wind funnel round (PX PZ) at TM frames into it (its turning), presence K: four rings of three arcs from 0.3 m up (r 1.1) to
2.7 m (r 2.3), each ring turning faster than the one below; a dust ring on the floor."
  (declare (single-float px pz tm k seed))
  (dotimes (lv 4)
    (let* ((fl (i->f lv)) (y (+ 0.3f0 (* 0.8f0 fl))) (r (+ 1.1f0 (* 0.4f0 fl))) (spin (* tm (+ 0.32f0 (* 0.06f0 fl)))))
      (declare (single-float fl y r spin))
      (dotimes (i 3)
        (let* ((a0 (+ spin (* 2.0944f0 (i->f i)) (* 0.7f0 fl))) (a1 (+ a0 1.6f0)) (am (+ a0 0.8f0)) (rb (* 1.22f0 r)))
          (declare (single-float a0 a1 am rb))
          (fx-crescent (+ px (* r (f-cos a0))) (+ y (* 0.12f0 (f-sin a0))) (+ pz (* r (f-sin a0)))
                       (+ px (* r (f-cos a1))) (+ y 0.1f0) (+ pz (* r (f-sin a1)))
                       (+ px (* rb (f-cos am))) (+ y 0.18f0) (+ pz (* rb (f-sin am)))
                       (* (+ 0.05f0 (* 0.025f0 fl)) k) :lens 0.05f0 (+ seed (* 3f0 fl) (i->f i)) +pal-hit+ (* k (- 0.95f0 (* 0.12f0 fl)))
                       :push 0.1f0)))))
  (dotimes (i 4)                                                   ; the dust ring dragged round on the floor
    (let* ((a0 (+ (* 0.4f0 tm) (* 1.5708f0 (i->f i)))) (a1 (+ a0 1.2f0)) (am (+ a0 0.6f0)))
      (declare (single-float a0 a1 am))
      (fx-crescent (+ px (* 1.6f0 (f-cos a0))) 0.05f0 (+ pz (* 1.6f0 (f-sin a0))) (+ px (* 1.6f0 (f-cos a1))) 0.05f0 (+ pz (* 1.6f0 (f-sin a1)))
                   (+ px (* 1.9f0 (f-cos am))) 0.1f0 (+ pz (* 1.9f0 (f-sin am))) (* 0.16f0 k) :lens 0.1f0 (+ seed 20f0 (i->f i)) +pal-dust+
                   (* 0.8f0 k) :push 0.05f0)))
  nil)

(defun-fast %ke-meteor-tail (st d tip k)
  "INSEKI-GIRI's falling blade: a yellow-white tail 1.8 m back from the held TIP against its cut direction ST[D..], an ink edge
under it; presence K."
  (declare (type f32vec st tip) (fixnum d) (single-float k))
  (let* ((x (aref tip 0)) (y (aref tip 1)) (z (aref tip 2)) (l 1.8f0)
         (x0 (- x (* l (aref st d)))) (y0 (- y (* l (aref st (+ d 1))))) (z0 (- z (* l (aref st (+ d 2))))))
    (declare (single-float x y z l x0 y0 z0))
    (fx-line x0 y0 z0 x y z 0.02f0 0.05f0 0.04f0 0.06f0 (* 0.7f0 k) :mode :alpha :end-width 0.5f0)
    (fx-line x0 y0 z0 x y z 0.01f0 1.0f0 0.86f0 0.45f0 (* 0.8f0 k) :end-width 0.36f0)
    (fx-line x0 y0 z0 x y z 0.005f0 1.0f0 0.97f0 0.85f0 k :end-width 0.14f0))
  nil)

(defun ke-meteor-impact (x z)
  "INSEKI-GIRI lands at (X Z): the floor cratered, a yellow ring, rubble, a shake (once, on the hit window's first frame)."
  (stage-crack-add x z 2.4)
  (vfx-shockwave x z 4.5 0.5 :rgb '(1.0 0.9 0.5))
  (stage-debris x z 10 1.2)
  (shake 0.35 0.45))

(defun-fast ken-special-look (e st o mv sf prev tip)
  "KEN-DRAW's special ASs (E in move MV at frame SF, PREV the frame at the last draw; the held TIP tracked in ST at O)."
  (declare (type f32vec st tip) (fixnum o sf prev))
  (let ((p (pos-of e)) (name (mv-name mv)))
    (declare (type f32vec p))
    (case name
      (:ke-s-sp1 (when (<= 4 sf 40)                                ; DAISHARIN: in over the wind-up, out over the recovery
                   (%ke-tornado (aref p 0) (aref p 2) (i->f sf)
                                (* (f-min 1f0 (/ (i->f (- sf 3)) 8f0)) (f-min 1f0 (/ (i->f (- 41 sf)) 10f0))) (+ 600f0 (drawing-no)))))
      (:ke-s-sp2 (when (<= 15 sf 21) (%ke-meteor-tail st (+ o 3) tip (f-min 1f0 (/ (i->f (- sf 14)) 3f0))))
                 (when (and (< prev 20) (<= 20 sf))                   ; (the hit window opens at 20)
                   (let ((v (first (hw-vols (svref (mv-hits mv) 0)))) (far *ke-far*))
                     (if (and v (%ic-far v p (yaw-of e) tip far))
                         (ke-meteor-impact (aref far 0) (aref far 2))
                         (ke-meteor-impact (aref tip 0) (aref tip 2))))))))
  nil)

;;; ---------------------------------------------------------------- the Shikai's Kikon cinematics (DUEL_KEN_V3 §19)
;;; One per pointer, its theme (§5.1): pointer 1 突進迴旋 dashes through him and spins back; pointer 2 扛肩柄擊: the hilt launches
;;; him, both hands cut him down.
(declaim (type f32vec *ke-kk*))
(defvar *ke-kk* (make-f32 4) "The Kikon cinematics' line: [0..1] the victim's x z, [2..3] the unit from him toward Kenpachi's side.")
(defun ke-kk-line (a v)
  "Keep the line V -> A for the cinematic's moves (its frame 0)."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2))) (d (max 0.01 (hypot dx dz))))
    (setf (aref *ke-kk* 0) (aref q 0) (aref *ke-kk* 1) (aref q 2) (aref *ke-kk* 2) (f32 (/ dx d)) (aref *ke-kk* 3) (f32 (/ dz d)))))
(defun ke-kk-at (e s &optional (y 0.0))
  "Put E S metres from the victim along the line (S < 0: past him), Y up."
  (let ((p (pos-of e)) (k *ke-kk*))
    (setf (aref p 0) (+ (aref k 0) (* s (aref k 2))) (aref p 1) (f32 y) (aref p 2) (+ (aref k 1) (* s (aref k 3))))))
(defun ke-kk-streak (s0 s1 k)
  "A white and yellow streak along the line from S0 to S1 at 1.0 m, presence K."
  (let* ((l *ke-kk*) (x0 (+ (aref l 0) (* s0 (aref l 2)))) (z0 (+ (aref l 1) (* s0 (aref l 3))))
         (x1 (+ (aref l 0) (* s1 (aref l 2)))) (z1 (+ (aref l 1) (* s1 (aref l 3)))))
    (fx-line x0 1.0 z0 x1 1.0 z1 0.02 1.0 0.86 0.45 (* 0.6 k) :end-width 0.22)
    (fx-line x0 1.0 z0 x1 1.0 z1 0.01 1.0 0.97 0.9 k :end-width 0.08)))

(defcine ken-s-kikon1-cine (a v :len 170 :hold 112)
  "回天斬 KAITENZAN, the Shikai's pointer-1 Kikon (突進迴旋): beat 0, the stance held; a white card, low and dutch, the brush
回天斬 and the hanko, silence; side-on, the crouch deepening; the dash through him (a streak, a heavy cut as he passes), from
behind him Kenpachi skidding on, his back turned; he turns and spins back through him in the wind funnel, the heavy cut: a
negative, a manga page, the Konpaku; he laughs, his back to him; wide."
  (at 0 (cine-place a v 3.2) (ke-kk-line a v) (shot-on a 50 3.6 1.0 :look 1.1) (lens 50)
      (cine-clip a :ke-s-st-1 :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :white a) (shot-on a 25 3.0 0.5 :look 1.2 :off -0.8) (lens 44 -10) (silence 40)
      (caption "回天斬" :reading "KAITENZAN" :sub "KENPACHI  KIKON" :side 1 :ink t :hanko t))
  (at 52 (card nil) (caption-exit) (shot-pair a v 1 7.0 1.0) (lens 46)
      (cine-clip a :ke-s-p1a :blend 4 :speed 0.5) (play-sfx :awaken-rise :pitch 0.6))
  (at 76 (cine-clip a :ke-s-issen :blend 0 :time (/ 8.0 60.0)) (play-sfx :whoosh-cleaver))
  (during (76 90) (ke-kk-at a (- 3.2 (* 6.4 (min 1.0 (* 1.2 u))))))   ; through him
  (during (76 100) (ke-kk-streak 3.2 (max -3.2 (- 3.2 (* 6.4 (min 1.0 (* 2.0 u))))) (- 1.0 u)))
  (at 82 (cine-slash v :heavy) (cine-clip v :sh-stagger :blend 2) (impact-frame :negative 2) (shake 0.2 0.3))
  (at 90 (shot-on v 170 5.5 1.3 :look 1.1 :ahead -1.5) (lens 50))
  (at 98 (face-each-other a v) (cine-clip a :ke-s-wheel :blend 2 :time (/ 6.0 60.0)) (play-sfx :whoosh-cleaver :pitch 0.8)
      (shot-pair a v -1 7.5 1.4) (lens 46))
  (during (98 112) (ke-kk-at a (+ -3.2 (* 5.2 u))))                 ; spun back through him
  (during (98 116) (let ((p (pos-of a))) (%ke-tornado (aref p 0) (aref p 2) (f32 (* 1.5 (- cf 98))) 0.9f0 (+ 640f0 (drawing-no)))))
  (at 104 (cine-slash v :heavy) (play-sfx :cut-heavy))
  (at 112 (impact-frame :negative 2) (cine-clip v :sh-crumple :blend 3)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 0.0 16 0.07)
      (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (shake 0.35 0.45))
  (at 114 (impact-frame :manga 12))
  (at 124 (play-sfx :laugh) (cine-clip a :ke-s-st-1 :blend 10))
  (at 138 (shot-on a 160 6.0 1.6 :look 1.2) (lens 50)))

(defun ke-kk-cut (k off drop seed)
  "TSUITENZAN's cut (after ch. 577's meteor cleave, its style only): the arc in the vertical plane of the line, from 8 m over
Kenpachi's side down through the victim to the floor past him, OFF metres to the side (a half of the split air peeling away),
DROP metres down, presence K; a white core over a yellow body."
  (let* ((l *ke-kk*) (ox (* off (aref l 3))) (oz (* off (- (aref l 2)))) (y1 (max 0.05 (- 0.1 drop)))
         (x0 (+ (aref l 0) (* 1.4 (aref l 2)) ox)) (z0 (+ (aref l 1) (* 1.4 (aref l 3)) oz))
         (x1 (+ (aref l 0) (* -1.2 (aref l 2)) ox)) (z1 (+ (aref l 1) (* -1.2 (aref l 3)) oz))
         (bx (+ (aref l 0) (* -0.4 (aref l 2)) ox)) (bz (+ (aref l 1) (* -0.4 (aref l 3)) oz)))
    (fx-crescent x0 (- 8.0 drop) z0 x1 y1 z1 bx (- 6.4 drop) bz (* 0.55 k) :lens 0.06 seed +pal-gold+ k :push 0.2)
    (fx-crescent x0 (- 8.0 drop) z0 x1 y1 z1 bx (- 6.4 drop) bz (* 0.25 k) :lens 0.05 (+ seed 7.0) +pal-hit+ k :push 0.3)))
(defun ke-kk-tail (e k)
  "Kenpachi falling with the cut like a meteor: a yellow-white tail 3 m up from E's head, presence K."
  (let* ((p (pos-of e)) (x (aref p 0)) (y (+ (aref p 1) 1.8)) (z (aref p 2)))
    (fx-line x (+ y 3.0) z x y z 0.02 1.0 0.86 0.45 (* 0.7 k) :end-width 0.5)
    (fx-line x (+ y 3.0) z x y z 0.01 1.0 0.97 0.85 k :end-width 0.2)))

(defcine ken-s-kikon2-cine (a v :len 290 :hold 168)
  "墜天斬 TSUITENZAN, the Shikai's pointer-2 Kikon (扛肩柄擊), in the style of ch. 577's meteor cleave (the leap skyward, one
blow, the halves falling apart; the user, 2026-11-04: 「不是真的要劈開隕石，只是要用那招的風格而已」), paced slow so each beat
reads: beat 0, the shoulder rest held; a white card, low and dutch, the brush 墜天斬 and the hanko, silence; the hilt sunk slowly
and flicked up into him: he goes up tumbling, seen from below; Kenpachi crouches and leaps skyward after him (wide), arched over
him with both hands on the hilt, held, his reiatsu flaring; the one cut down through him: a negative, focus lines, slow motion
seen down the line (the swing itself 3 frames at full speed, a 6-frame hit-stop), the arc of the cut splitting into two halves that peel apart to either side; they fall, his tail like a
meteor's; the floor cratered under him and the halves landing on both sides (a manga page, the Konpaku); he laughs; wide."
  (at 0 (cine-place a v 2.0) (ke-kk-line a v) (shot-on a 50 3.4 1.0 :look 1.2) (lens 50)
      (cine-clip a :ke-s-st-2 :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :white a) (shot-on a 25 3.0 0.6 :look 1.3 :off -0.8) (lens 44 -10) (silence 40)
      (caption "墜天斬" :reading "TSUITENZAN" :sub "KENPACHI  KIKON" :side 1 :ink t :hanko t))
  (at 52 (card nil) (caption-exit) (shot-on a 70 3.4 0.7 :look 1.2) (lens 46)
      (cine-clip a :ke-s-flick :blend 3 :speed 0.4))                ; (its hit at clip frame 10: f77)
  (at 77 (cine-slash v :heavy) (cine-clip v :sh-launch :blend 2) (impact-frame :negative 2) (play-sfx :cut-heavy) (shake 0.25 0.3))
  (during (77 125) (ke-kk-at v 0.0 (* 5.0 (- 1.0 (expt (- 1.0 u) 2)))))                    ; up ...
  (during (125 196) (ke-kk-at v 0.0 (+ 5.0 (* 0.2 (min 1.0 (/ u 0.6))))))                 ; ... hung at the top
  (during (196 228) (ke-kk-at v 0.0 (* 5.2 (- 1.0 (* u u)))))                              ; cut down
  (during (79 122) (let* ((q (pos-of v)) (l *ke-kk*))                                       ; from below: up at him
                     (cine-cam (+ (aref l 0) (* 4.2 (aref l 2)) (* 3.2 (aref l 3))) 0.4 (+ (aref l 1) (* 4.2 (aref l 3)) (* -3.2 (aref l 2)))
                               (aref q 0) (+ (aref q 1) 0.8) (aref q 2))))
  (at 79 (lens 50))
  ;; Kenpachi: INSEKI-GIRI's clip at 0.3: the crouch (its key 6) at f122, the leap (9) f132, arched (13) f145; held arched at 0.25
  ;; to f165, then the cut at full speed (the user: 「斬下去的瞬間速度加快，讓演出更有魄力」): 17 -> S 20 in 3 frames, S on f168
  (at 102 (cine-clip a :ke-s-meteor :blend 6 :speed 0.3))
  (at 150 (cine-clip a :ke-s-meteor :blend 4 :time (/ 13.0 60.0) :speed 0.25))
  (at 165 (cine-clip a :ke-s-meteor :blend 0 :time (/ 17.0 60.0)) (lens 62 10) (play-sfx :whoosh-cleaver :pitch 0.8))
  (during (165 168) (ke-kk-cut (+ 0.3 (* 0.7 u)) 0.0 0.0 (+ 690.0 (drawing-no))))           ; the smear of the swing
  (at 122 (play-sfx :whoosh-heavy :pitch 0.7))
  (during (122 152) (ke-kk-at a (- 2.0 (* 0.9 u)) (* 5.8 (- 1.0 (expt (- 1.0 u) 2)))))     ; the leap skyward
  (during (152 196) (ke-kk-at a 1.1 (+ 5.8 (* 0.1 u))))                                      ; arched over him, the cut, held
  (during (196 228) (ke-kk-at a (- 1.1 (* 0.3 u)) (* 5.9 (- 1.0 (* u u)))))                 ; and down with him
  (during (122 152) (let* ((p (pos-of a)) (q (pos-of v)) (l *ke-kk*)                       ; wide side-on: up after him
                            (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2))))
                            (my (+ 1.0 (* 0.5 (+ (aref p 1) (aref q 1))))))
                       (cine-cam (+ mx (* 11.0 (aref l 3))) (+ 0.4 my) (- mz (* 11.0 (aref l 2))) mx (+ 0.8 my) mz)))
  (at 122 (lens 46))
  (during (152 168) (let* ((p (pos-of a)) (l *ke-kk*))                                    ; low and close: arched against the sky
                      (cine-cam (+ (aref p 0) (* 2.8 (aref l 3)) (* 1.2 (aref l 2))) (- (aref p 1) 0.4)
                                (+ (aref p 2) (* -2.8 (aref l 2)) (* 1.2 (aref l 3)))
                                (aref p 0) (+ (aref p 1) 1.7) (aref p 2))))
  (at 152 (lens 52 6) (play-sfx :awaken-rise :pitch 0.7))
  (during (148 170) (let ((p (pos-of a)))                                                   ; his reiatsu flaring
                      (fx-billboard (aref p 0) (+ (aref p 1) 1.6) (aref p 2) (* 1.6 (min 1.0 (* 2.0 u))) 1.0 0.85 0.3
                                    (* 0.5 (- 1.0 (* u u))))))
  (at 168 (cine-slash v :heavy) (impact-frame :negative 3) (focus-lines 24) (cine-slow 0)       ; a hit-stop ...
      (play-sfx :kikon-slash) (play-sfx :cut-heavy) (play-sfx :explode :pitch 0.7) (shake 0.55 0.6)
      (lens 40))
  (at 174 (cine-slow 0.25))                                                                     ; ... then slow motion
  (during (168 196) (let ((l *ke-kk*))                                                      ; down the line: the halves part
                      (cine-cam (+ (aref l 0) (* -10.0 (aref l 2))) 3.6 (+ (aref l 1) (* -10.0 (aref l 3)))
                                (+ (aref l 0) (* 0.5 (aref l 2))) 5.0 (+ (aref l 1) (* 0.5 (aref l 3))))))
  (during (168 176) (ke-kk-cut (- 1.0 (* 0.3 u)) 0.0 0.0 (+ 700.0 (drawing-no))))           ; the cut whole ...
  (during (172 228) (let ((d (* 2.4 (sqrt u))) (dr (* 6.0 (expt (max 0.0 (/ (- u 0.4) 0.6)) 2))) (k (- 1.0 (* 0.5 u))))
                      (ke-kk-cut k d dr (+ 710.0 (drawing-no)))                          ; ... split, peeling apart, then falling
                      (ke-kk-cut k (- d) dr (+ 720.0 (drawing-no)))))
  (at 196 (cine-slow 1) (lens 44) (cine-clip a :ke-s-meteor :blend 4 :time (/ 24.0 60.0) :speed 0.5))
  (during (196 228) (let* ((p (pos-of a)) (q (pos-of v)) (l *ke-kk*)                       ; side-on at their height
                           (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2)))) (my (* 0.5 (+ (aref p 1) (aref q 1)))))
                      (cine-cam (+ mx (* 9.0 (aref l 3))) (+ my 1.2) (- mz (* 9.0 (aref l 2))) mx (+ my 1.0) mz)))
  (during (196 228) (ke-kk-tail a (- 1.0 (* 0.4 u))))
  (at 228 (cine-clip v :sh-down :blend 2) (cine-clip a :ke-s-meteor :blend 2 :time (/ 38.0 60.0))
      (let ((q (pos-of v)) (l *ke-kk*))
        (ke-meteor-impact (aref q 0) (aref q 2))
        (dolist (sd '(2.4 -2.4))                                                            ; the halves land on both sides
          (let ((x (+ (aref l 0) (* -0.6 (aref l 2)) (* sd (aref l 3)))) (z (+ (aref l 1) (* -0.6 (aref l 3)) (* sd (- (aref l 2))))))
            (stage-crack-add x z 1.4) (stage-debris x z 6 1.0))))
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 0.4 :dy 0.1)
      (impact-splash-at v 0.0 16 0.08)
      (play-sfx :ground-crack) (play-sfx :explode :pitch 0.5) (play-sfx :konpaku-shatter) (shake 0.5 0.7))
  (at 230 (impact-frame :manga 12))
  (at 246 (play-sfx :laugh) (cine-clip a :ke-s-st-2 :blend 12))
  (at 260 (shot-on a 150 6.5 1.8 :look 1.2) (lens 50)))
