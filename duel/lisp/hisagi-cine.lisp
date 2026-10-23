;;;; hisagi-cine.lisp — Hisagi's four cinematics (batch B5, docs/duel/DUEL_HISAGI.md §22.5, §22.7: the awakening, the Shikai Kikon 刈れ, KOSA,
;;;; KOSHU): the scripts' shots and looks, their clips (his and the victim's), the scripts (split out of hisagi-art.lisp 2026-10-21,
;;;; refactor round 2). DEFCINE order is the numbering order: do not reorder.
(in-package :duel)

;;; ================================================================ the cinematics (batch B5, DUEL_HISAGI §22.5, §22.7)
;;; The user, 2026-10-18: 「覺醒跟毀魂技的動畫的記得要做」. Four scripts, built from §22.5's revised storyboards (the Shikai
;;; Kikon from §11.5's table): the awakening 卍解 風死絞縄 (the :bankai kit's :cine, combat.lisp AWAKEN!), the Shikai Kikon
;;; 刈れ, the ranged mode's 降鎖 KOSA and the bind's 絞首 KOSHU (the moves' :cine; also each form's Soul Break, KIT-KIKON-CINE).
;;; Presentation only: the rules settled the Konpaku before a script starts. The Kikons CINE-PLACE him (his place given
;;; back at the end); the awakening moves no one (its AFTER sends both to idle as every awakening's does). His draw hook
;;; reads the running script's frame (HS-CINE-OF, %HS-CINE-LOOK!, HS-KARE-CODES), so a skipped or aborted script leaves
;;; nothing behind; the scripts' own looks are the DURING functions below (the whirlpool, the black wind, the coils, the
;;; orb gathering, the giant rope, the crack, the rain of chains). Debug 83965-83976 (HISAGI-CINE-DEBUG).

(defun hs-cine-of (e)
  "The B5 cinematic E is the actor A of right now: 1 the awakening, 2 the Shikai Kikon 刈れ, 3 KOSA, 4 KOSHU, else 0."
  (let ((c *cine*))
    (if (and c (eq (cine-a c) e))
        (case (cine-name c) (hs-awaken-cine 1) (hs-kare-cine 2) (hs-kosa-cine 3) (hs-koshu-cine 4) (t 0))
        0)))

(defun-fast %hs-cine-look! (code cf)
  "*HS-CL* for HISAGI-DRAW at cine frame CF of B5 cinematic CODE (HS-CINE-OF; 0: the match's 1 1 1 0 0); returns the flags:
1 the Shikai's look (the awakening before 卍解's coils: the ink chain, no orb), 2 no orb at all (the awakening to f100), 4
the noose drawn whatever the bind (KOSHU). The awakening's orb grows f100-116, its curtain drops f114-126, the neck bundle
comes down f118-130 and ties; KOSA's curtain is hauled up into the orb f28-44 (the rope) and drops back f120-134; KOSHU's
orb sinks 3.4 m f70-86. 0 B."
  (declare (fixnum code cf))
  (let ((cl *hs-cl*) (f (i->f cf)))
    (declare (type f32vec cl) (single-float f))
    (macrolet ((ramp (a b) `(f-clamp (/ (- f ,a) ,(- b a)) 0f0 1f0)))
      (setf (aref cl 0) 1f0 (aref cl 1) 1f0 (aref cl 2) 1f0 (aref cl 3) 0f0 (aref cl 4) (if (= code 0) 0f0 1f0))
      (case code
        (1 (cond ((< cf 70) 3)
                 ((< cf 100) 2)
                 (t (let ((g (ramp 100f0 116f0)))
                      (declare (single-float g))
                      (setf (aref cl 0) (* g g (- 3f0 (* 2f0 g))) (aref cl 1) (ramp 114f0 126f0) (aref cl 2) (ramp 118f0 130f0))
                      0))))
        (3 (setf (aref cl 1) (if (< cf 120) (- 1f0 (ramp 28f0 44f0)) (ramp 120f0 134f0))) 0)
        (4 (setf (aref cl 3) (* -3.4f0 (ramp 70f0 86f0))) 4)
        (t 0)))))

(defun-fast %hs-fr-from (n)
  "1 when the clip frame HISAGI-DRAW read (*HS-FR*) is at least N, else 0. 0 B."
  (declare (fixnum n))
  (if (>= (aref *hs-fr* 0) (i->f n)) 1 0))

(defun-fast hs-kare-codes (cf fa kubi)
  "The left sickle in the Shikai Kikon 刈れ at cine frame CF (HISAGI-DRAW's draw codes A B N D, and LO bits): in his fist,
then thrown at f30 (the strike's S) along his facing as the flat spinning disc on its chain (68: the disc, through the left
fist) past the victim 3 m out to 6 m (f40), drifting to 7 m, pulled back from f58 through his back (f63) into the fist
(f68); KUBI 1 (KUBIKAKE's clip, the victim within 1.8 m, before the slam): the garrote (8). FA[1] := the flight's reach. 0 B."
  (declare (fixnum cf kubi) (type f32vec fa))
  (cond ((< cf 30) (values 0 0 0 1 0))
        ((< cf 40) (setf (aref fa 1) 6.0f0) (values 0 1 (- cf 30) 10 68))
        ((< cf 58) (setf (aref fa 1) (+ 6.0f0 (/ (i->f (- cf 40)) 18f0))) (values 1 1 0 1 68))
        ((< cf 68) (setf (aref fa 1) 7.0f0) (values 1 0 (- cf 58) 10 68))
        (t (values 0 0 0 1 (if (= kubi 1) 8 0)))))

;;; ---------------------------------------------------------------- the scripts' shots and looks
(declaim (type f32vec *hs-c0* *hs-c1* *hs-c2* *hs-cfa* *hs-cm*))
(defvar *hs-c0* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-c1* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-c2* (make-f32 3) "A cinematic look's point (scratch).")
(defvar *hs-cfa* (make-f32 4) "A flying blade's facing for %HS-PLACE! ([0] its yaw).")
(defvar *hs-cm* (m4) "A flying blade's world matrix.")

(defun hs-shot (e ang dist h look &key (ahead 0.0) (right 0.0))
  "SHOT-ON's camera (ANG degrees round fighter E's facing, DIST m out, H high, aimed LOOK m up, AHEAD m in front of him and
RIGHT m to his right) with no subject kept in frame: a tilt that leaves his body (camera.lisp %KEEP-SUBJECT)."
  (setf *cine-close* nil *cine-subject* nil)
  (let* ((p (pos-of e)) (y0 (yaw-of e)) (yaw (+ y0 (deg ang)))
         (tx (+ (aref p 0) (* ahead (fwd-x y0)) (* right (cos y0)))) (tz (+ (aref p 2) (* ahead (fwd-z y0)) (* right (- (sin y0))))))
    (cine-cam (+ tx (* dist (fwd-x yaw))) h (+ tz (* dist (fwd-z yaw))) tx look tz)))

(defun hs-cine-stage (a v gap)
  "A Kikon cinematic's frame 0: A staged GAP m from V (CINE-PLACE; both set down mid-stage first, combat.lisp CINE-STAGE,
and given back however the cinematic ends)."
  (cine-place a v gap))

(defun hs-face (a v)
  "Turn A to face V (a cinematic look; V unturned)."
  (let ((p (pos-of a)) (q (pos-of v)))
    (setf (transform-yaw (transform a)) (f32 (dir-yaw (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))))))

(defun hs-round (a v d deg)
  "Put A D m from V, DEG degrees round V's facing (0 in front of him, 180 behind his back), facing him (刈れ's flash steps:
CINE-PLACE gives A his place back)."
  (let* ((q (pos-of v)) (p (pos-of a)) (yaw (+ (yaw-of v) (deg deg))))
    (setf (aref p 0) (f32 (+ (aref q 0) (* d (fwd-x yaw)))) (aref p 1) 0f0 (aref p 2) (f32 (+ (aref q 2) (* d (fwd-z yaw)))))
    (hs-face a v)))

(defun hs-cine-hit (v up kind)
  "A hit spark on V, UP m over his feet (a look)."
  (multiple-value-bind (x y z) (actor-point v up) (vfx-hit x y z kind)))

(defun hs-top-shot (v)
  "Steep, nearly top-down on V (刈れ's flash steps): 6.4 m up, 2.0 m off to the side."
  (setf *cine-close* nil *cine-subject* nil)
  (let ((q (pos-of v)) (yaw (yaw-of v)))
    (cine-cam (+ (aref q 0) (* 2.0 (cos yaw))) 6.4 (+ (aref q 2) (* 2.0 (- (sin yaw)))) (aref q 0) 0.6 (aref q 2))))

(defun hs-lane-shot (a v dist h look)
  "Side-on to the A -> V lane (on A's right: the orb's side), DIST m from its middle, H high, aimed LOOK m up: KOSA's long
lens."
  (setf *cine-close* nil *cine-subject* nil)
  (let* ((p (pos-of a)) (q (pos-of v)) (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2))))
         (yaw (yaw-of a)))
    (cine-cam (+ mx (* dist (cos yaw))) h (+ mz (* dist (- (sin yaw)))) mx look mz)))

(defun-fast %hs-aw-whirl (pos cf)
  "The awakening's whirlpool (f32-70): both Kazeshini flung up over him (POS his feet), tumbling round a rim rising from
2.2 to 3.5 m and widening to 1.25 m, their chain twisting down from each into a funnel above his head and back up: the
Shikai's ink chain. 0 B but the weapon draws."
  (declare (type f32vec pos) (fixnum cf))
  (let* ((u (f-clamp (/ (i->f (- cf 32)) 14f0) 0f0 1f0)) (e (* u u (- 3f0 (* 2f0 u))))
         (h (+ 2.2f0 (* 1.3f0 e))) (r (+ 0.25f0 (* 1.0f0 e))) (th (* 0.26f0 (i->f cf)))
         (x (aref pos 0)) (z (aref pos 2)) (a *hs-c0*) (b *hs-c1*) (fa *hs-cfa*) (m *hs-cm*))
    (declare (single-float u e h r th x z) (type f32vec a b fa m))
    (dotimes (k 2)
      (let ((an (+ th (* 3.1415927f0 (i->f k)))))
        (declare (single-float an))
        (setf (aref a 0) (+ x (* r (f-cos an))) (aref a 1) (+ h (* 0.25f0 (i->f k))) (aref a 2) (+ z (* r (f-sin an)))
              (aref fa 0) (- an))
        (%hs-place! m a fa 1)
        (draw-weapon :kazeshini m)))
    (dotimes (i 29)
      (let* ((s (/ (i->f i) 28f0)) (d (f-abs (- 1f0 (* 2f0 s))))
             (an (+ th (* 3.1415927f0 s) (* 7.853982f0 (- 1f0 d))))
             (rr (+ 0.08f0 (* r d))) (y (+ 2.05f0 (* (- h 2.05f0) d) (* 0.25f0 s))))
        (declare (single-float s d an rr y))
        (setf (aref b 0) (+ x (* rr (f-cos an))) (aref b 1) y (aref b 2) (+ z (* rr (f-sin an))))
        (when (> i 0) (vfx-hs-chain a b 0f0 0.9f0))
        (replace a b))))
  nil)

(defun %hs-aw-wind (pos cf from k0)
  "The black wind round him (POS his feet) from cine frame FROM: 22 dark streaks, spiralling round the whirlpool (K0 0) or
bursting out from him to 8 m and fading (K0 1: 卍解)."
  (let* ((u (min 1.0 (max 0.0 (/ (- cf from) 20.0)))) (x (aref pos 0)) (z (aref pos 2)))
    (dotimes (i 22)
      (let* ((a0 (+ (* i 0.2856) (* 0.13 (mod (* i 7) 5)) (if (= k0 0) (* 0.2 cf) 0.0)))
             (y (+ 0.25 (* 0.42 (mod (* i 3) 7))))
             (r0 (if (= k0 0) (+ 1.6 (* 0.12 (mod i 4))) (+ 0.6 (* 7.0 u))))
             (r1 (if (= k0 0) r0 (+ r0 0.4 (* 1.8 (- 1.0 u)))))
             (a1 (if (= k0 0) (+ a0 0.7) a0)) (al (if (= k0 0) 0.55 (* 0.9 (- 1.0 u)))))
        (fx-line (+ x (* r0 (cos a0))) y (+ z (* r0 (sin a0))) (+ x (* r1 (cos a1))) (+ y (if (= k0 0) 0.35 0.1)) (+ z (* r1 (sin a1)))
                 (if (= k0 0) 0.07 0.14) 0.03 0.03 0.05 al :mode :alpha :end-width 0.015 :end-alpha (* 0.2 al))))))

(defun-fast %hs-coil-run (jm j r ya yb turns n upto)
  "The first UPTO of N links of a coil of chain winding round joint J of the joints JM (radius R, from YA to YB along its
up axis, TURNS turns): solid black (%HS-BLACK-KITE), each along the helix. 0 B but its float arguments."
  (declare (type f32vec jm) (fixnum j n upto) (single-float r ya yb turns))
  (let ((p *hs-c0*) (q *hs-c1*))
    (declare (type f32vec p q))
    (dotimes (i (min n upto))
      (let* ((u0 (/ (+ 0.5f0 (i->f i)) (i->f n))) (u1 (/ (+ 1.5f0 (i->f i)) (i->f n)))
             (a0 (* 6.2831855f0 turns u0)) (a1 (* 6.2831855f0 turns u1)))
        (declare (single-float u0 u1 a0 a1))
        (joint-point! p jm j (* r (f-sin a0)) (+ ya (* u0 (- yb ya))) (* r (f-cos a0)))
        (joint-point! q jm j (* r (f-sin a1)) (+ ya (* u1 (- yb ya))) (* r (f-cos a1)))
        (let* ((dx (- (aref q 0) (aref p 0))) (dy (- (aref q 1) (aref p 1))) (dz (- (aref q 2) (aref p 2)))
               (l (f-max 1f-4 (f-hypot dx dy dz))))
          (declare (single-float dx dy dz l))
          (%hs-black-kite (aref p 0) (aref p 1) (aref p 2) (/ dx l) (/ dy l) (/ dz l) 0.045f0 (if (evenp i) 0.02f0 0.009f0))))))
  nil)

(defun hs-aw-coil (a cf)
  "The awakening's coils winding on (f74-90, then the :hisagi-bankai body's): his chain up the right forearm from the
wrist, the upper arm, then round his neck (the body variant's three coils, 113 links, a little proud of them)."
  (let* ((jm (model-joints (model a))) (n (floor (* 113 (min 1.0 (/ (- cf 74) 15.0))))))
    (%hs-coil-run jm (ji :lower-arm-r) 0.064 -0.235 -0.02 4.0 40 n)
    (%hs-coil-run jm (ji :upper-arm-r) 0.073 -0.27 -0.04 3.5 40 (- n 40))
    (%hs-coil-run jm (ji :neck) 0.069 0.0 0.125 3.0 33 (- n 80))))

(defun hs-aw-gather (cf)
  "The orb forming (f100-116): six black chains spiralling in from 4.6 m round to its centre (*HS-OC*, the draw hook's)."
  (let ((c *hs-oc*) (p *hs-c2*) (u (min 1.0 (/ (- cf 100) 16.0))))
    (setf *hs-chain-black* 1)
    (dotimes (i 6)
      (let ((an (+ (* i 1.0472) (* 0.12 cf))) (rr (+ 0.6 (* 4.0 (- 1.0 u)))))
        (setf (aref p 0) (f32 (+ (aref c 0) (* rr (cos an)))) (aref p 1) (f32 (- (aref c 1) (* 0.45 rr) -0.6))
              (aref p 2) (f32 (+ (aref c 2) (* rr (sin an)))))
        (%hs-chain2 p c)))
    (setf *hs-chain-black* 0)))

(defun hs-aw-tilt (a cf)
  "The awakening's tilt (f100-135): from low behind his left shoulder (the opponent out of the frame), up past the frame's top to the orb forming (f100-112),
held on it, then down with the chains and the bundle to him (f118-132)."
  (let* ((k (cond ((< cf 112) (let ((x (/ (- cf 100) 12.0))) (* x x (- 3 (* 2 x)))))
                  ((< cf 118) 1.0)
                  (t (let ((x (min 1.0 (/ (- cf 118) 14.0)))) (- 1.0 (* x x (- 3 (* 2 x)))))))))
    (hs-shot a 150 6.2 0.8 (+ 1.3 (* 6.9 k)) :right (* 1.5 k))))

(defun hs-kosa-tilt (a cf)
  "KOSA's tilt (f25-60): low behind him, up from his raised crescent to the orb (to f42), held there."
  (let* ((x (min 1.0 (/ (- cf 25) 17.0))) (k (* x x (- 3 (* 2 x)))))
    (hs-shot a 160 3.2 0.5 (+ 2.0 (* 5.6 k)) :right (* 1.4 k) :ahead (* -0.5 k))))

(defun hs-kosa-rope (a v cf)
  "KOSA's giant rope (f25-112): every hanging chain hauled up (the draw hook's curtain) and twisted into one rope of eight
under the orb, lowered (f30-52); swung back over him (f60-68); whipped down to the ground 2 m ahead (f68-76); its end run
along the ground to the victim as a wave of black (f76-90), the ground blackened behind it; on him (to f100), then hauled
back up (f100-112)."
  (let* ((c *hs-oc*) (top *hs-c0*) (b *hs-c1*) (p (pos-of a)) (q (pos-of v))
         (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2))) (d (max 0.5 (hypot dx dz))) (ux (/ dx d)) (uz (/ dz d)))
    (setf (aref top 0) (aref c 0) (aref top 1) (- (aref c 1) (* 0.75 *hs-orb-scale*)) (aref top 2) (aref c 2))
    (flet ((at (s y) (setf (aref b 0) (f32 (+ (aref p 0) (* s ux))) (aref b 1) (f32 y) (aref b 2) (f32 (+ (aref p 2) (* s uz)))))
           (ease (x) (let ((x (min 1.0 (max 0.0 x)))) (* x x (- 3 (* 2 x))))))
      (cond ((< cf 60) (let ((l (* 5.2 (ease (/ (- cf 30) 22.0)))))
                         (setf (aref b 0) (aref top 0) (aref b 1) (f32 (- (aref top 1) l)) (aref b 2) (aref top 2))))
            ((< cf 68) (let ((k (ease (/ (- cf 60) 8.0)))) (at (* -2.6 k) (- (aref top 1) 5.2 (* -1.6 k)))))
            ((< cf 76) (let ((k (ease (/ (- cf 68) 8.0)))) (at (+ -2.6 (* 4.6 k)) (+ (* (- 1 k) (- (aref top 1) 3.6)) (* k 0.15)))))
            ((< cf 90) (at (+ 2.0 (* (- d 2.0) (ease (/ (- cf 76) 14.0)))) 0.15))
            ((< cf 100) (at d 0.5))
            (t (let ((k (ease (/ (- cf 100) 12.0))))
                 (setf (aref b 0) (f32 (+ (aref q 0) (* k (- (aref top 0) (aref q 0)))))
                       (aref b 1) (f32 (+ 0.5 (* k (- (aref top 1) 0.5))))
                       (aref b 2) (f32 (+ (aref q 2) (* k (- (aref top 2) (aref q 2)))))))))
      (setf *hs-chain-black* 1)
      (when (> (- (aref top 1) (aref b 1)) 0.1) (%hs-bundle top b 8 2.5f0 0.32f0 1.1f0))
      (setf *hs-chain-black* 0)
      (when (and (>= cf 76) (< cf 120))                  ; the wave: the ground blackened along the lane behind its end
        (let* ((s1 (if (< cf 90) (+ 2.0 (* (- d 2.0) (ease (/ (- cf 76) 14.0)))) d))
               (al (if (< cf 100) 0.9 (* 0.9 (- 1.0 (/ (- cf 100) 20.0))))))
          (dotimes (i 3)
            (let ((o (* 0.22 (- i 1))))
              (fx-line (+ (aref p 0) (* 1.2 ux) (* o (- uz))) 0.04 (+ (aref p 2) (* 1.2 uz) (* o ux))
                       (+ (aref p 0) (* s1 ux) (* o (- uz))) 0.04 (+ (aref p 2) (* s1 uz) (* o ux))
                       (if (= i 1) 0.3 0.16) 0.03 0.03 0.05 al :mode :alpha :end-width 0.45)))
          (when (< cf 92)                                ; black spray thrown up at its front
            (dotimes (i 7)
              (let* ((sp (* 0.9 (- i 3))) (hh (+ 0.6 (* 0.5 (mod (* i 5) 3)) (* 0.08 (mod cf 4)))))
                (fx-line (+ (aref p 0) (* s1 ux)) 0.1 (+ (aref p 2) (* s1 uz))
                         (+ (aref p 0) (* (- s1 0.4) ux) (* sp 0.35 (- uz))) hh (+ (aref p 2) (* (- s1 0.4) uz) (* sp 0.35 ux))
                         0.09 0.03 0.03 0.05 0.85 :mode :alpha :end-width 0.01)))))))))

(defun hs-kosa-crack (a v cf)
  "KOSA's crack (f90-150): a jagged black line split along the ground from 1.2 m ahead of him to the victim, fading from
f130."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (max 1.5 (hypot dx dz))) (ux (/ dx d)) (uz (/ dz d)) (k (if (< cf 130) 0.95 (* 0.95 (- 1.0 (/ (- cf 130) 20.0)))))
         (n 18) (x0 0.0) (z0 0.0))
    (dotimes (i (1+ n))
      (let* ((s (+ 1.2 (* (- d 1.0) (/ i (float n))))) (o (* 0.16 (sin (* 2.7 i))))
             (x (+ (aref p 0) (* s ux) (* o (- uz)))) (z (+ (aref p 2) (* s uz) (* o ux))))
        (when (> i 0)
          (fx-line x0 0.03 z0 x 0.03 z 0.07 0.02 0.02 0.03 k :mode :alpha)
          (when (zerop (mod i 3))                         ; a branch every third kink
            (fx-line x 0.03 z (+ x (* 0.5 (- uz)) (* 0.2 ux)) 0.03 (+ z (* 0.5 ux) (* 0.2 uz)) 0.04 0.02 0.02 0.03 k
                     :mode :alpha :end-width 0.005)))
        (setf x0 x z0 z)))))

(defun hs-koshu-rain (v cf)
  "KOSHU's rain of chains (f80-150): eight black chains dropped from the sunk orb's underside (*HS-OC*) onto the victim,
one every 2 f, their ends round his body 0.5-1.4 m up; from f96 three turns of chain bind him standing (%HS-COIL)."
  (let ((c *hs-oc*) (top *hs-c0*) (b *hs-c1*) (q (pos-of v)))
    (setf (aref top 0) (aref c 0) (aref top 1) (f32 (- (aref c 1) (* 0.75 *hs-orb-scale*))) (aref top 2) (aref c 2))
    (setf *hs-chain-black* 1)
    (dotimes (i 8)
      (let ((k (min 1.0 (/ (- cf 80 (* 2 i)) 7.0))) (an (* i 0.7854)))
        (when (> k 0.0)
          (setf (aref b 0) (f32 (+ (aref top 0) (* k (- (+ (aref q 0) (* 0.4 (cos an))) (aref top 0)))))
                (aref b 1) (f32 (+ (aref top 1) (* k (- (+ 0.5 (* 0.13 i)) (aref top 1)))))
                (aref b 2) (f32 (+ (aref top 2) (* k (- (+ (aref q 2) (* 0.4 (sin an))) (aref top 2))))))
          (%hs-chain2 top b))))
    (when (>= cf 96) (%hs-coil q))
    (setf *hs-chain-black* 0)))

;;; ---------------------------------------------------------------- the cinematics' clips (his and the victim's)
;; the awakening: head bowed, eyes shut, the rods hanging in front of his thighs, the chain slack between them (CFYOW
;; III ch. 24's stillness before the release)
(defpose :hs-aw-still (:base :hs-s-stance)
  (:root :u -0.03 :f 0.0) (:pelvis :twist 0) (:spine :flex 8) (:chest :twist 0) (:neck :twist 0) (:head :flex 28)
  (:arm-r :flex 22 :side 6 :twist 0) (:elbow-r :flex 26) (:hand-r :flex -96)
  (:arm-l :flex 22 :side 6 :twist 0) (:elbow-l :flex 26) (:hand-l :flex -96)
  (:thigh-l :flex 4 :side 8) (:knee-l :flex 6) (:thigh-r :flex -4 :side 8) (:knee-r :flex 6))
(defclip :hs-aw-still (1.0 :loop t :base :hs-aw-still)
  (0) (0.5 (:root :u -0.04) (:head :flex 30)))
;; both Kazeshini flung up (cine f20 + 12 = f32): sunk low with the rods swung back, then the whole body thrown up, the
;; arms straight overhead, the face up to the whirlpool, held
(defclip :hs-aw-throw (1.3 :base :hs-aw-still)
  (0)
  (0.14 (:root :u -0.26) (:spine :flex 30) (:head :flex 12) (:arms :flex -36 :side 34) (:elbows :flex 30) (:hands :flex -60)
        (:thighs :flex 46) (:knees :flex 60))
  (0.2 :snap (:root :u 0.06) (:spine :flex -24) (:head :flex -44) (:arms :flex 178 :side 16) (:elbows :flex 4)
       (:hands :flex -10) (:thigh-l :flex 4) (:thigh-r :flex -8) (:knees :flex 4))
  (0.36 (:root :u 0.03) (:spine :flex -28) (:head :flex -48) (:arms :flex 170 :side 30) (:elbows :flex 10) (:hands :flex -20))
  (1.3 (:root :u 0.0) (:spine :flex -24) (:head :flex -46) (:arms :flex 160 :side 44) (:elbows :flex 22) (:hands :flex -30)))
;; f70: the blades fall back into his hands (caught low, the knees giving), then the right arm held out and down, his
;; head turned to it, as the chain winds up it; into the CFYOW stance
(defclip :hs-aw-catch (1.0 :base :hs-k-stance)
  (0 (:spine :flex -20) (:head :flex -40) (:arms :flex 160 :side 34) (:elbows :flex 20))
  (0.07 :snap (:root :u -0.16) (:spine :flex 14) (:head :flex 4) (:arms :flex 50 :side 24) (:elbows :flex 50) (:hands :flex -60)
        (:knees :flex 34) (:thighs :flex 20))
  (0.25 (:root :u -0.06) (:spine :flex 6) (:head :flex 26) (:neck :twist -34) (:arm-r :flex 34 :side 44 :twist 0)
        (:elbow-r :flex 46) (:hand-r :flex -40) (:arm-l :flex 8 :side 14) (:elbow-l :flex 12) (:hand-l :flex -82))
  (0.5 (:root :u -0.05) (:spine :flex 5) (:head :flex 28) (:neck :twist -38) (:arm-r :flex 36 :side 46 :twist 0)
       (:elbow-r :flex 50) (:hand-r :flex -36) (:arm-l :flex 8 :side 14) (:elbow-l :flex 12) (:hand-l :flex -82))
  (1.0 :hs-k-stance (:head :flex 12)))
;; f100: the face up to the orb forming, held; down again into the stance with the chains (f118-132)
(defclip :hs-aw-rise (1.2 :base :hs-k-stance)
  (0 (:head :flex 10))
  (0.2 (:spine :flex -8) (:head :flex -40))
  (0.3 (:spine :flex -9) (:head :flex -42))
  (0.6 (:spine :flex 2) (:head :flex 6))
  (1.2 :hs-k-stance))
;; KOSHU: the victim's choke (both hands at his throat, the head back, up on his toes, straining), and Hisagi's: the right
;; crescent straight up, his left hand at his own throat, the head back (the noose bites both: the shared pain), then
;; standing on, hunched a little, shaking (f150)
(defpose :hs-cine-choke-v ()
  (:root :u 0.04) (:spine :flex -14) (:head :flex -36)
  (:arm-r :flex 70 :side -28 :twist 0) (:elbow-r :flex 125) (:hand-r :flex -10)
  (:arm-l :flex 70 :side -28 :twist 0) (:elbow-l :flex 125) (:hand-l :flex -10)
  (:thigh-l :flex 6 :side 6) (:knee-l :flex 10) (:thigh-r :flex -6 :side 6) (:knee-r :flex 8))
(defclip :hs-cine-choke-v (0.2 :loop t :base :hs-cine-choke-v)
  (0) (0.1 (:root :u 0.05) (:spine :flex -18) (:head :flex -40) (:arm-r :flex 74) (:arm-l :flex 66)))
(defpose :hs-cine-raise (:base :hs-k-stance)
  (:root :u -0.04) (:spine :flex -12) (:head :flex -28)
  (:arm-r :flex 176 :side 12 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -10)
  (:arm-l :flex 120 :side -26 :twist 0) (:elbow-l :flex 150) (:hand-l :flex -10)
  (:thigh-l :flex 16 :side 8) (:knee-l :flex 18) (:thigh-r :flex -12 :side 8) (:knee-r :flex 14))
(defclip :hs-cine-raise (0.2 :loop t :base :hs-cine-raise)
  (0) (0.1 (:head :flex -32) (:arm-r :flex 179) (:root :u -0.05)))
(defclip :hs-cine-shake (0.14 :loop t :base :hs-k-stance)
  (0 (:root :u -0.07) (:spine :flex 12) (:head :flex 16) (:arm-l :flex 104 :side -20 :twist 0) (:elbow-l :flex 140)
     (:hand-l :flex -10))
  (0.07 (:root :u -0.08) (:spine :flex 14) (:chest :twist 3) (:head :flex 19) (:arm-l :flex 108 :side -22 :twist 0)
        (:elbow-l :flex 136) (:hand-l :flex -10)))

;;; ---------------------------------------------------------------- the scripts
(defcine hs-awaken-cine (a v :len 168 :hold 150)
  "The awakening 卍解 風死絞縄 (§22.5): 1 close on his face, eyes shut, the chain slack between the two Kazeshini in his
hands, silence; 2 low, looking up: both flung up (f32), their chain twisting into a whirlpool overhead; 3 wide: 卍解, the
black wind bursts out (a negative frame, the shockwave, the stamp); 4 medium: silence, the world greys, the blades fall
back into his hands, his chain winds up his right arm and round his neck; 5 the tilt up past the frame's top to the orb
forming, the black chains dropping round him, the four-chain bundle coming down and tying round his neck, the pale patch;
6 wide, both: the CFYOW stance under the curtain, 風死絞縄 / ふしのこうじょう. Nothing reaches the opponent (the bind starts
only from KUBIKAKE)."
  ;; 1 (0-20) close on the face
  (at 0 (setf (model-body (model a)) (find-body :hisagi) (model-weapon (model a)) :kazeshini)
      (cine-clip a :hs-aw-still :blend 0) (cine-clip v (kit-stance (kit-of v)) :blend 6) (face-beat a :neutral 0.55)
      (hold-pose v 12) (freeze 12) (impact-frame :negative 2) (silence 20)
      (shot-on a 16 1.25 1.62 :look 1.6) (lens 36))
  (during (0 20) (shot-on a 16 (- 1.25 (* 0.18 u)) 1.62 :look 1.6))
  ;; 2 (20-50) low, looking up: both flung up, the whirlpool
  (at 20 (cine-clip a :hs-aw-throw :blend 2) (shot-on a 34 3.1 0.3 :look 2.1) (lens 74) (play-sfx :whoosh-heavy :pitch 0.8))
  (at 32 (setf (model-weapon (model a)) nil) (play-sfx :chain-rattle) (play-sfx :whoosh-heavy :pitch 1.1))
  (at 42 (play-sfx :chain-rattle :pitch 0.8))
  (during (32 70) (%hs-aw-whirl (pos-of a) cf))
  (during (36 50) (%hs-aw-wind (pos-of a) cf 36 0))
  ;; 3 (50-70) wide: 卍解, the black wind, the negative, the shockwave, the stamp
  (at 50 (impact-frame :negative 2) (shot-on a 62 9.5 1.3 :look 2.2 :off -1.4) (lens 50) (shake 0.35 0.5)
      (play-sfx :awaken-boom) (play-sfx :explode :pitch 0.6 :gain 0.6)
      (let ((p (pos-of a))) (vfx-shockwave (aref p 0) (aref p 2) 6.0 0.6 :pal +pal-dust+))
      (caption "卍解" :reading "BANKAI" :side 1))
  (at 52 (impact-frame :manga 6))
  (during (50 70) (%hs-aw-wind (pos-of a) cf 50 1))
  ;; 4 (70-100) medium: silence, the world greys; the blades caught; the coils wind on
  (at 70 (setf (model-weapon (model a)) :kazeshini) (cine-clip a :hs-aw-catch :blend 1) (caption-exit) (silence 30)
      (shot-on a 38 3.3 1.35 :look 1.3) (lens 42) (play-sfx :clang :pitch 0.7))
  (during (70 168) (setf *grade-desat* (min 0.7 (* 0.05 (- cf 70)))))
  (at 74 (play-sfx :chain-rattle :pitch 0.6))
  (during (74 90) (hs-aw-coil a cf))
  (at 90 (setf (model-body (model a)) (find-body :hisagi-bankai)) (play-sfx :chain-snap :pitch 0.8))
  ;; 5 (100-135) the tilt up past the frame's top: the orb forms, the chains drop, the bundle ties his neck
  (at 100 (cine-clip a :hs-aw-rise :blend 6) (lens 54) (play-sfx :awaken-rise :pitch 0.6))
  (during (100 135) (hs-aw-tilt a cf))
  (during (100 116) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-aw-gather cf))
  (at 114 (play-sfx :chain-rattle :pitch 0.5))
  (at 130 (play-sfx :chain-snap) (shake 0.15 0.25))
  ;; 6 (135-168) wide, both: the CFYOW stance under the curtain; 風死絞縄
  (at 135 (cine-clip a :hs-k-stance :blend 10) (impact-frame :negative 1)
      (let* ((p (pos-of a)) (q (pos-of v)) (d (hypot (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))))
        (shot-on a 30 (+ 7.0 (* 0.6 d)) 1.4 :look 2.0 :ahead (* 0.5 d) :off (- (+ 1.0 (* 0.3 d))))) (lens 44)
      (caption "風死絞縄" :kanji2 "ふしのこうじょう" :reading "FUSHI NO KOJO" :sub "BANKAI" :side 1)))

(defcine hs-kare-cine (a v :len 180 :hold 160)
  "The Shikai Kikon 刈れ (§11.5, the Findorr fight, ch. 325): 1 side and low, 3 m apart: the victim reels, Hisagi whirls the
chain overhead, the blade across his face; 2 over his shoulder: the throw, the sickle nicks the victim and flies past; 3
low in front: he drops and pulls, the blade comes back through the victim's back (a white card, his silhouette, 2
drawings); 4 side-on: KUBIKAKE, the chain round his neck, the yank, the slam (dust ring, crack); 5 nearly top-down: flash
steps round him (afterimages), behind him, the reaping cut across: the Konpaku; 6 the white card: the chain slack, the
half-step back, 刈れ / 風死."
  ;; 1 (0-24) side, low, 3 m apart
  (at 0 (hs-cine-stage a v 3.0) (cine-clip a :hs-s-kari-aim :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 8) (freeze 8) (impact-frame :negative 2) (play-sfx :chain-rattle) (silence 24)
      (shot-on a 90 5.2 1.0 :look 1.3 :ahead 1.5) (lens 38))
  ;; 2 (24-54) over his shoulder: the throw (S at f30), the nick (f34), past him
  (at 24 (cine-clip a :hs-s-kari-o :blend 1 :time (/ 14.0 60.0)) (shot-on a 160 5.3 1.75 :look 1.35 :ahead 3.0) (lens 38))
  (at 30 (play-sfx :whoosh-heavy))
  (at 34 (cine-clip v :sh-flinch :blend 1) (play-sfx :cut) (hs-cine-hit v 1.25 :cut))
  (at 41 (play-sfx :chain-snap :pitch 1.2))
  ;; 3 (54-84) low in front: the pull (S at f60), the blade back through his back (f63): the white card, 2 drawings
  (at 54 (cine-clip a :hs-s-hiki :blend 2 :time (/ 14.0 60.0)) (hs-shot a 62 4.2 0.4 1.0 :ahead 1.5) (lens 60))
  (at 58 (play-sfx :chain-snap))
  (at 63 (card :white v) (silhouette-black v) (cine-clip v :sh-stagger :blend 0) (hold-pose v 4)
      (play-sfx :cut-heavy) (shake 0.2 0.25))
  (at 67 (unsilhouette) (card nil) (hs-cine-hit v 1.2 :heavy))
  ;; 4 (84-120) side-on: KUBIKAKE (S at f90), the yank, the slam (f98)
  (at 84 (face-each-other a v 1.4) (cine-clip a :hs-s-kubikake :blend 1 :time (/ 2.0 60.0))
      (cine-clip v :sh-kikon-victim :blend 3) (shot-pair a v 1 4.4 1.3) (lens 46) (play-sfx :hoho-out))
  (at 90 (play-sfx :chain-snap) (cine-clip v :sh-crumple :blend 1)
      (multiple-value-bind (x y z) (actor-point v 1.45) (focus-lines 8 x y z)))
  (at 98 (cine-clip v :sh-down :blend 3) (impact-frame :negative 2) (shake 0.35 0.4) (play-sfx :ground-crack) (play-sfx :land)
      (let ((q (pos-of v))) (vfx-shockwave (aref q 0) (aref q 2) 2.5 0.5 :pal +pal-dust+)
        (impact-splash (aref q 0) 0.0 (aref q 2) 10 0.07)))
  (at 100 (impact-frame :manga 6))
  ;; 5 (120-156) nearly top-down: the flash steps round him, behind him the reaping cut (S at f142): the Konpaku
  (at 120 (cine-clip v :sh-crumple :blend 6 :time 0.3) (cine-clip a :hs-s-stance :blend 0) (start-ghost a) (hs-round a v 1.6 60)
      (hs-top-shot v) (lens 50) (play-sfx :hoho-out))
  (at 124 (start-ghost a) (hs-round a v 1.6 120) (play-sfx :hoho-out :pitch 1.1))
  (at 128 (start-ghost a) (hs-round a v 1.4 180) (cine-clip a :hs-s-kari :blend 0 :time (/ 8.0 60.0)) (play-sfx :hoho-in))
  (at 136 (silence 6))
  (at 142 (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :konpaku-shatter) (play-sfx :cut-heavy) (shake 0.3 0.4))
  (at 144 (impact-frame :manga 12))
  ;; 6 (156-180) the white card: the chain slack, the half-step back; 刈れ / 風死
  (at 156 (card :white a) (cine-clip a :hs-s-win :blend 6) (shot-on a 30 5.2 1.1 :look 1.15 :off -1.1) (lens 36)
      (caption "刈れ" :kanji2 "風死" :reading "KARE, KAZESHINI" :sub "KIKON" :side 1 :ink t :hanko t)))

(defcine hs-kosa-cine (a v :len 150 :hold 130)
  "The ranged mode's Kikon 降鎖 KOSA (§22.5): 1 low behind him: one crescent raised, the neck bundle hauled up off his
back; 2 the tilt up: the orb turning, every hanging chain hauled up into one giant twisted rope; 3 side-on, a long lens:
the rope whipped down along the lane, a wave of black down the ground to the victim; 4 on the victim: the impact, the
ground cracked in a line, a white card with his silhouette (2 drawings), the Konpaku; 5 wide: the chains fall back into
the curtain, he lowers the blade, unmoved: 降鎖."
  ;; 1 (0-25) low, behind him: the windup (KOSA's clip slowed, held at its peak f17 from f38)
  (at 0 (hs-cine-stage a v 7.0) (cine-clip a :hs-k-kosa :blend 2 :speed 0.45) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 10) (freeze 10) (impact-frame :negative 2) (silence 25) (play-sfx :chain-rattle :pitch 0.7)
      (shot-on a 165 3.0 0.5 :look 2.0) (lens 50))
  (at 38 (cine-clip a :hs-k-kosa :blend 0 :time (/ 17.0 60.0) :speed 0.0))
  ;; 2 (25-60) the tilt up: the rope gathered under the orb
  (at 25 (play-sfx :chain-rattle :pitch 0.5) (lens 54))
  (during (25 60) (hs-kosa-tilt a cf))
  (during (25 112) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-kosa-rope a v cf))
  (at 44 (play-sfx :chain-rattle :pitch 0.4))
  ;; 3 (60-90) side-on, a long lens: the whip (KOSA's S at f61), the wave down the lane
  (at 58 (cine-clip a :hs-k-kosa :blend 0 :time (/ 17.0 60.0)))
  (at 60 (hs-lane-shot a v 15.5 2.6 3.4) (lens 32) (play-sfx :whoosh-heavy :pitch 0.6))
  (at 74 (play-sfx :chain-snap :pitch 0.6) (play-sfx :ground-crack) (shake 0.25 0.3))
  (at 82 (play-sfx :ground-crack :pitch 0.8))
  ;; 4 (90-120) on the victim: the impact, the crack, the white card (2 drawings), the Konpaku
  (at 90 (shot-on v 35 3.8 0.8 :look 1.1) (lens 48) (impact-frame :negative 2) (cine-clip v :sh-crumple :blend 1)
      (play-sfx :explode :pitch 0.7) (shake 0.4 0.5) (hs-cine-hit v 1.0 :heavy))
  (at 92 (card :white v) (silhouette-black v) (hold-pose v 4))
  (at 96 (unsilhouette) (card nil) (cine-shatter v (fighter-kikon-n (fighter a))) (play-sfx :konpaku-shatter))
  (at 98 (impact-frame :manga 10))
  (during (90 150) (hs-kosa-crack a v cf))
  ;; 5 (120-150) wide: the curtain back, the blade lowered; 降鎖
  (at 120 (cine-clip a :hs-k-stance :blend 14) (shot-on a 125 8.0 1.5 :look 2.4 :off -1.3) (lens 46)
      (caption "降鎖" :reading "KOSA" :sub "FUSHI NO KOJO  KIKON" :side 1 :hanko t)))

(defcine hs-koshu-cine (a v :len 180 :hold 150)
  "The bind's Kikon 絞首 KOSHU (§22.5): 1 he zips along the noose chain (flash steps, afterimages); 2 behind the victim:
the chain drawn across his throat; 3 the orb sinks, chains rain onto him: bound standing; 4 he raises a blade, the noose
tightens on both necks: both choke (the shared pain); 5 the victim drops, the Konpaku; Hisagi stays up, shaking: 絞首."
  ;; 1 (0-30) the zip: hops along the line every 4 f, an afterimage each
  (at 0 (hs-cine-stage a v 6.0) (cine-clip a :hs-kb-koshu-run :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 6) (impact-frame :negative 2) (play-sfx :hoho-out) (play-sfx :chain-snap) (lens 44))
  (when (and step-p (<= 4 cf 24) (zerop (mod cf 4)))
    (start-ghost a) (face-each-other a v (- 6.0 (* 5.0 (/ (- cf 4) 20.0)))) (play-sfx :hoho-out :pitch (+ 0.9 (* 0.01 cf))))
  (during (0 30) (shot-pair a v -1 7.0 1.4))
  ;; 2 (30-70) behind the victim: the garrote (KOSHU's S at f38)
  (at 30 (hs-round a v 0.75 180) (cine-clip a :hs-kb-koshu :blend 0) (cine-clip v :hs-cine-choke-v :blend 4)
      (shot-on v 32 3.7 1.45 :look 1.4) (lens 46) (play-sfx :hoho-in) (silence 40))
  (at 38 (play-sfx :chain-snap) (shake 0.15 0.2) (face-beat v :hurt 3.0))
  ;; 3 (70-110) the orb sinks; the rain of chains; bound standing
  (at 70 (shot-on v 35 5.8 0.45 :look 2.6) (lens 62) (cine-clip v :sh-bound :blend 6) (play-sfx :chain-rattle :pitch 0.5))
  (during (80 150) (setf *hs-chain-ink* (if (eq a *p1*) 0 1)) (hs-koshu-rain v cf))
  (at 82 (play-sfx :chain-rattle))
  (at 96 (play-sfx :chain-snap) (shake 0.2 0.3))
  ;; 4 (110-150) the blade raised; the noose bites both necks
  (at 110 (cine-clip a :hs-cine-raise :blend 6) (cine-clip v :hs-cine-choke-v :blend 4) (face-beat a :hurt 4.0)
      (shot-on v 68 3.8 1.5 :look 1.6) (lens 46))
  (at 128 (impact-frame :negative 1) (play-sfx :chain-snap :pitch 0.7) (shake 0.25 0.6)
      (multiple-value-bind (x y z) (actor-point v 1.45) (focus-lines 20 x y z)))
  (at 132 (shot-on a 80 1.9 1.6 :look 1.55) (lens 44))
  ;; 5 (150-180) the victim drops; Hisagi stays up, shaking; 絞首
  (at 150 (cine-clip v :sh-crumple :blend 1) (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :konpaku-shatter) (shake 0.3 0.4) (cine-clip a :hs-cine-shake :blend 6)
      (shot-on a 95 5.6 1.3 :look 1.4 :off -0.9) (lens 46))
  (at 152 (impact-frame :manga 12))
  (at 156 (caption "絞首" :reading "KOSHU" :sub "FUSHI NO KOJO  KIKON" :side 1 :hanko t)))

