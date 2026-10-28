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
;;; orb gathering, the giant rope, the crack, the rain of chains). Debug 83965-83978 (HISAGI-CINE-DEBUG).

(defun hs-cine-of (e)
  "The B5 cinematic E is the actor A of right now: 1 the awakening, 2 the Shikai Kikon 刈れ, 3 KOSA, 4 KOSHU, 5 首掛
KUBIKAKE, 6 綴雷電 TSUZURI RAIDEN (the core Kikons, §26.6: their scripts draw his left sickle and its chain, HISAGI-DRAW
leaves them out), else 0."
  (let ((c *cine*))
    (if (and c (eq (cine-a c) e))
        (case (cine-name c) (hs-awaken-cine 1) (hs-kare-cine 2) (hs-kosa-cine 3) (hs-koshu-cine 4) (hs-kubikake-cine 5)
          (hs-raiden-cine 6) (t 0))
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

;;; ================================================================ the core Kikons 首掛 / 綴雷電 (DUEL_HISAGI §26.4, §26.6)
;;; The user, 2026-10-28, approved the storyboards (§26.4): pointer 2's 首掛 KUBIKAKE (the bind: the chain round the neck,
;;; the heave over his shoulder, the slam, the pin) and pointer 3's 綴雷電 TSUZURI RAIDEN (the chain wound round the
;;; victim, the lightning run down it). His left sickle was thrown: it hangs off the chain's coil on the victim, so these
;;; scripts draw it and its chain themselves after both bodies are posed (HS-CINE-OF 5 / 6: HISAGI-DRAW leaves them out).
;;; Debug 83969 (首掛) / 83977 (綴雷電) play them, 83970+b holds beat b (HISAGI-CINE-DEBUG).
(declaim (type f32vec *hs-k0* *hs-k1* *hs-k2* *hs-k3*))
(defvar *hs-k0* (make-f32 3) "The core Kikons' look: a chord's start (scratch).")
(defvar *hs-k1* (make-f32 3) "The core Kikons' look: a coil's start (where the chain from his fist reaches it).")
(defvar *hs-k2* (make-f32 3) "The core Kikons' look: a coil's end (the left sickle hangs there).")
(defvar *hs-k3* (make-f32 3) "The core Kikons' look: his left fist.")

(defun hs-cine-shown-p (e)
  "Actor E is drawn this frame: not left off a card that shows the other alone (CARD's ONLY)."
  (not (and *card-only* (not (eq e *card-only*)))))

(defun hs-cine-ink (a)
  "The chain's colour as HISAGI-DRAW's: solid black, P2's the original ink."
  (setf *hs-chain-black* 1 *hs-chain-ink* (if (eq a *p1*) 0 1)))

(defun hs-cine-fist (a)
  "His chain between the rods with the left sickle thrown: the right rod's butt to the left fist, slack; *HS-K3* := the
left fist."
  (let ((jm (model-joints (model a))) (w *hs-k0*) (q *hs-k3*))
    (joint-point! w jm (ji :weapon-r) 0f0 0f0 0.22f0)
    (joint-point! q jm (ji :weapon-l) 0f0 0f0 0f0)
    (vfx-hs-chain w q -0.4f0 0.9f0)))

(defun hs-cine-blade (a p yaw spin)
  "His left sickle drawn at P (an f32vec), turned to YAW, SPIN as %HS-PLACE!'s (1 tumbling, 4 point down at P)."
  (let ((fa *hs-cfa*) (m *hs-cm*))
    (setf (aref fa 0) (f32 yaw))
    (%hs-place! m p fa spin)
    (draw-weapon :kazeshini m :tint (model-tint (model a)))))

(defun hs-cine-bolt (p q k0 k1 seed)
  "TSUZURI RAIDEN's lightning (%HS-DRAW's: jade shards, a white core) from K0 to K1 (0-1) of the segment P -> Q, jagged,
redrawn on the fx clock."
  (let* ((dx (- (aref q 0) (aref p 0))) (dy (- (aref q 1) (aref p 1))) (dz (- (aref q 2) (aref p 2)))
         (l (max 0.01 (sqrt (+ (* dx dx) (* dy dy) (* dz dz))))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
         (hl (max 0.01 (sqrt (+ (* ux ux) (* uz uz))))) (sx (/ uz hl)) (sz (/ (- ux) hl))   ; (sideways, level)
         (n (max 1 (ceiling (* (- k1 k0) l) 0.3))) (dr (drawing-no 24f0)))
    (when (> k1 k0)
      (dotimes (i n)
        (let* ((s (* l (+ k0 (* (- k1 k0) (/ (+ i 0.5) n))))) (j (* 0.09 (sin (+ dr seed (* 2.3 i)))))
               (jy (* 0.07 (cos (+ (* 1.7 dr) (* 3.1 i)))))
               (x (f32 (+ (aref p 0) (* s ux) (* j sx)))) (y (f32 (+ (aref p 1) (* s uy) jy))) (z (f32 (+ (aref p 2) (* s uz) (* j sz))))
               (k (f32 (+ i 800 dr seed))))
          (fx-shard x y z (f32 ux) (f32 uy) (f32 uz) 0.42f0 0.05f0 0.12f0 k +pal-jade+ 0.95f0 :push 0.12f0)
          (fx-shard x y z (f32 ux) (f32 uy) (f32 uz) 0.38f0 0.016f0 0.08f0 (+ k 40f0) +pal-hit+ 0.95f0 :push 0.16f0))))))

(defun hs-cine-coil (jm j r ya yb turns k bolt)
  "K (0-1) of a coil of chain wound round joint J of the joints JM from its front: radius R, from YA to YB along the
joint's up axis, TURNS turns, 10 chords a turn (VFX-HS-CHAIN); BOLT (0-1) of it lit (HS-CINE-BOLT); *HS-K1* := its start,
*HS-K2* := its end so far."
  (let* ((n (max 1 (round (* 10 turns)))) (m (* k n)) (p *hs-k0*) (q *hs-k2*))
    (flet ((pt (o u) (let ((an (+ 3.1415927 (* 6.2831855 turns u))))
                       (joint-point! o jm j (f32 (* r (sin an))) (f32 (+ ya (* u (- yb ya)))) (f32 (* r (cos an)))))))
      (pt *hs-k1* 0.0) (pt q 0.0)
      (dotimes (i (ceiling m))
        (replace p q)
        (pt q (/ (min m (1+ i)) n))
        (vfx-hs-chain p q 0f0 0.9f0)
        (when (> bolt (/ i (float n))) (hs-cine-bolt p q 0.0 1.0 i))))))

(defun hs-cine-sparks (p n k)
  "N jade sparks crackling out of point P (an f32vec), redrawn on the fx clock, presence K."
  (let ((dr (drawing-no 24f0)))
    (dotimes (i n)
      (let* ((a0 (+ (* 2.39996 i) (* 1.3 dr))) (e (* 0.9 (sin (+ (* 1.7 i) dr))))
             (ux (* (cos e) (cos a0))) (uy (sin e)) (uz (* (cos e) (sin a0))) (s (+ 0.08 (* 0.05 (mod (+ i (floor dr)) 3)))))
        (fx-shard (f32 (+ (aref p 0) (* s ux))) (f32 (+ (aref p 1) (* s uy))) (f32 (+ (aref p 2) (* s uz)))
                  (f32 ux) (f32 uy) (f32 uz) 0.16f0 0.02f0 0.1f0 (f32 (+ i 870 dr)) +pal-jade+ (f32 k) :push 0.16f0)))
    (%light (aref p 0) (aref p 1) (aref p 2) 0.62f0 1f0 0.86f0 4f0 (f32 (* 2.5 k)) 8)))

(defun hs-cine-smoke (v n)
  "Smoke rising off V (up to N puffs a frame, the fx particles)."
  (let ((q (pos-of v)))
    (dotimes (i n)
      (when (< (rnd01) 0.5)
        (%t-blob (+ (aref q 0) (rnd-range -0.4f0 0.4f0)) (rnd-range 0.3f0 1.3f0) (+ (aref q 2) (rnd-range -0.4f0 0.4f0))
                 0f0 0.7f0 0f0 1.1f0 0.06f0 -0.06f0 0.1f0 +pal-black-smoke+)))))

;;; ---------------------------------------------------------------- their clips (his and the victim's)
;; 首掛: the haul: from the cast (the left arm out along the chain) yanked back, the fist by his left shoulder, the body
;; leant back on the braced front leg
(defpose :hs-cine-haul (:base :hs-s-stance)
  (:root :f -0.1 :u -0.16 :yaw 12) (:pelvis :twist 0) (:spine :flex -10) (:chest :twist 20) (:head :flex 6)
  (:arm-l :flex 52 :side 22 :twist 0) (:elbow-l :flex 118) (:hand-l :flex -30)
  (:arm-r :flex 24 :side 24) (:elbow-r :flex 40) (:hand-r :flex -80)
  (:thigh-l :flex 40 :side 8) (:knee-l :flex 30) (:thigh-r :flex -26 :side 12) (:knee-r :flex 26))
(defclip :hs-cine-kb-haul (0.6 :base :hs-s-stance)
  (0 :hs-s-nage-hit) (0.12 :snap :hs-cine-haul) (0.6 :hs-cine-haul (:root :u -0.18) (:spine :flex -12)))
;; 綴雷電: the left fist high on the taut chain, the right hand's two fingers set on it lower down, trembling
(defpose :hs-cine-rd-hold (:base :hs-s-stance)
  (:root :f 0.04 :u -0.12 :yaw -6) (:pelvis :twist 0) (:spine :flex 4) (:chest :twist -14) (:head :flex -6)
  (:arm-l :flex 150 :side 8 :twist 0) (:elbow-l :flex 10) (:hand-l :flex -20)
  (:arm-r :flex 112 :side -18 :twist 0) (:elbow-r :flex 50) (:hand-r :flex -10)
  (:thigh-l :flex 36 :side 8) (:knee-l :flex 38) (:thigh-r :flex -18 :side 10) (:knee-r :flex 16))
(defclip :hs-cine-rd-hold (0.2 :loop t :base :hs-cine-rd-hold)
  (0) (0.1 (:arm-l :flex 152) (:root :u -0.13)))
;; the victim wound in the chain: the arms pinned to his sides, straining; then the shock: up on his toes, the head thrown
;; back, shaking
(defpose :hs-cine-wound-v ()
  (:root :u -0.04) (:spine :flex -8) (:head :flex -18)
  (:arm-r :flex 6 :side 6 :twist 0) (:elbow-r :flex 14) (:arm-l :flex 6 :side 6 :twist 0) (:elbow-l :flex 14)
  (:thigh-l :flex 6 :side 6) (:knee-l :flex 10) (:thigh-r :flex -6 :side 6) (:knee-r :flex 8))
(defclip :hs-cine-wound-v (0.3 :loop t :base :hs-cine-wound-v)
  (0) (0.15 (:spine :flex -12 :twist 8) (:head :flex -24)))
(defclip :hs-cine-shock-v (0.1 :loop t :base :hs-cine-wound-v)
  (0 (:root :u 0.05) (:spine :flex -22 :twist 5) (:head :flex -38) (:arms :side 12) (:elbows :flex 30))
  (0.05 (:root :u 0.04) (:spine :flex -26 :twist -5) (:head :flex -44) (:arms :side 16) (:elbows :flex 24)))

;;; ---------------------------------------------------------------- 首掛 KUBIKAKE
(defun hs-kubi-look (a v cf)
  "首掛's chain (every frame): two turns round the victim's neck, wound on f20-36 and drawn tight f36-46; from it to his
left fist, slack until the snap (f8), then taut (through the heave, the slam and the pin); the left sickle hanging off
the coil (tumbling while it winds)."
  (hs-cine-ink a)
  (let* ((k (cond ((< cf 20) 0.3) ((< cf 36) (+ 0.3 (* 0.7 (/ (- cf 20) 16.0)))) (t 1.0)))
         (r (cond ((< cf 36) 0.17) ((< cf 46) (- 0.17 (* 0.085 (/ (- cf 36) 10.0)))) (t 0.085))))
    (when (hs-cine-shown-p v)
      (hs-cine-coil (model-joints (model v)) (ji :neck) r 0.0 0.09 2.0 k 0.0)
      (hs-cine-blade a *hs-k2* (yaw-of v) (if (< cf 36) 1 4)))
    (when (hs-cine-shown-p a)
      (hs-cine-fist a)
      (when (hs-cine-shown-p v)
        (if (< cf 8) (vfx-hs-chain *hs-k3* *hs-k1* -0.5f0 0.9f0) (%hs-chain2 *hs-k3* *hs-k1*))))))

(defun hs-kubi-arc (a v cf)
  "The heave (step mode, f58-81): the victim hauled up off the ground 3.4 m in front of him, over his shoulder (3.3 m
up at f71) and slammed down 1.9 m behind him (CINE-PLACE gives him his place back)."
  (let* ((k (min 1.0 (/ (- cf 58) 23.0))) (p (pos-of a)) (q (pos-of v)) (yaw (yaw-of a))
         (s (- 3.4 (* 5.3 k))) (h (if (< k 0.55) (/ (- k 0.55) 0.55) (/ (- k 0.55) 0.45))))
    (setf (aref q 0) (f32 (+ (aref p 0) (* s (fwd-x yaw)))) (aref q 2) (f32 (+ (aref p 2) (* s (fwd-z yaw))))
          (aref q 1) (f32 (* 3.3 (- 1.0 (* h h)))))))

(defcine hs-kubikake-cine (a v :len 150 :hold 125)
  "Pointer 2's Kikon 首掛 KUBIKAKE (§26.4): 1 low from behind him: the left fist hauls, the chain snaps taut over his
shoulder; 2 wide, side-on: the chain winds twice round the victim's neck and tightens; 3 low, the sky behind: he turns
his back and heaves the chain over his shoulder like a hawser, the victim leaves the ground; 4 the slam over his shoulder
into the plaza: the crack ring, the ink splash, the shake, the Konpaku; 5 he kneels on him, the sickle raised, a hand at
his throat: 首掛."
  (during (0 150) (hs-kubi-look a v cf))
  ;; 1 (0-20) low, from behind him: the haul, the snap (f8)
  (at 0 (hs-cine-stage a v 3.4) (cine-clip a :hs-cine-kb-haul :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 8) (freeze 8) (impact-frame :negative 2) (play-sfx :chain-rattle) (silence 20)
      (hs-shot a 160 2.6 0.45 1.6 :ahead 1.2) (lens 54))          ; (not a close-up: a phone dollies back to the victim)
  (at 8 (play-sfx :chain-snap) (shake 0.12 0.2) (cine-clip v :sh-flinch :blend 1) (face-beat v :hurt 2.5)
      (multiple-value-bind (x y z) (actor-point v 1.45) (focus-lines 8 x y z)))
  ;; 2 (20-50) wide, side-on: two turns round his neck (f20-36), drawn tight (f36-46)
  (at 20 (shot-pair a v 1 (if (portrait-p) 7.5 5.4) 1.5) (lens 40) (play-sfx :chain-rattle :pitch 1.2))
  (at 28 (play-sfx :chain-rattle :pitch 1.1))
  (at 36 (cine-clip a :hs-cine-kb-haul :blend 1 :time 0.04) (play-sfx :chain-snap :pitch 0.8) (shake 0.15 0.25)
      (multiple-value-bind (x y z) (actor-point v 1.5) (focus-lines 10 x y z)))
  (at 46 (cine-clip v :hs-cine-choke-v :blend 2))                 ; (his hands up only once the coil is drawn tight)
  ;; 3 (50-80) low, the sky behind: he turns his back, the chain over his shoulder; the heave (SHIBARI's clip f26-46)
  (at 50 (cine-clip a :hs-s-shibari :blend 4 :time (/ 26.0 60.0) :speed 0.64) (hs-shot a 90 6.8 0.25 2.4 :ahead 0.6)
      (lens 50) (play-sfx :whoosh-heavy :pitch 0.6))
  (at 58 (cine-clip v :sh-launch :blend 3) (play-sfx :chain-snap :pitch 0.7) (play-sfx :whoosh-heavy :pitch 0.8))
  (when (and step-p (<= 58 cf 81)) (hs-kubi-arc a v cf))
  (at 70 (play-sfx :whoosh-heavy :pitch 1.0))
  ;; 4 (80-100) the slam (f81): the crack ring, the ink splash, the shake, the Konpaku
  (at 80 (cine-clip a :hs-s-shibari :blend 0 :time (/ 45.0 60.0)) (shot-on a 225 5.6 1.5 :look 0.7 :ahead -1.0) (lens 46))
  (at 81 (cine-clip v :sh-down :blend 1) (impact-frame :negative 2) (shake 0.45 0.5)
      (play-sfx :ground-crack) (play-sfx :land) (play-sfx :explode :pitch 0.6 :gain 0.6)
      (let ((q (pos-of v))) (vfx-shockwave (aref q 0) (aref q 2) 3.0 0.5 :pal +pal-dust+)
        (stage-crack-add (aref q 0) (aref q 2) 2.2) (impact-splash (aref q 0) 0.0 (aref q 2) 12 0.09))
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 0.5) (play-sfx :konpaku-shatter))
  (at 83 (impact-frame :manga 8))
  ;; 5 (100-150) the pin (KUBIKAKE's clip, f18 held): down on his knee, the left hand at the throat, the sickle up; 首掛
  (at 100 (face-each-other a v 1.4) (cine-clip a :hs-s-kubikake :blend 0 :time (/ 18.0 60.0) :speed 0.0)
      (cine-clip v :sh-down :blend 0) (impact-frame :negative 1) (play-sfx :chain-snap :pitch 0.6)
      (if (portrait-p) (shot-on a 75 6.8 1.8 :look 0.6 :ahead 0.9) (shot-on a 75 4.6 1.3 :look 0.6 :ahead 0.9 :off -0.5))
      (lens 42))                                                   ; (a phone: not a close-up, dollied back to show him)
  (at 104 (caption "首掛" :reading "KUBIKAKE" :sub "KAZESHINI  KIKON" :side 1 :hanko t)))

;;; ---------------------------------------------------------------- 綴雷電 TSUZURI RAIDEN
(defun hs-raiden-look (a v cf)
  "綴雷電's chain (every frame): three turns round the victim's chest and arms, wound on f2-22; from it up to his raised
left fist, taut; the lightning from the fist down the chain (f48-70) and round the coil (f70-84), crackling there to
f120; sparks at his fingers (f25-70); from f120 slack: the coil gone, the chain run down to the sickle on the ground."
  (hs-cine-ink a)
  (let ((k (min 1.0 (max 0.0 (/ (- cf 2) 20.0)))) (run (min 1.0 (max 0.0 (/ (- cf 48) 22.0))))
        (lit (cond ((< cf 70) 0.0) ((< cf 84) (/ (- cf 70) 14.0)) ((< cf 120) 1.0) (t 0.0))))
    (if (< cf 120)
        (when (hs-cine-shown-p v)
          (hs-cine-coil (model-joints (model v)) (ji :chest) 0.45 -0.48 0.12 3.0 k lit)
          (hs-cine-blade a *hs-k2* (yaw-of v) (if (< k 1.0) 1 4))
          (when (>= cf 70)                                         ; lit
            (multiple-value-bind (x y z) (actor-point v 1.1)
              (%light (f32 x) (f32 y) (f32 z) 0.62f0 1f0 0.86f0 6f0 (f32 (if (< cf 90) 3.0 (* 0.5 (mod cf 3)))) 8))))
        (let ((q (pos-of v)) (g *hs-k1*))                         ; slack: run down to the sickle on the ground
          (setf (aref g 0) (aref q 0) (aref g 1) 0.05f0 (aref g 2) (aref q 2))
          (hs-cine-blade a g (yaw-of v) 4)))
    (when (hs-cine-shown-p a)
      (hs-cine-fist a)
      (when (hs-cine-shown-p v)
        (if (< cf 120) (%hs-chain2 *hs-k3* *hs-k1*) (vfx-hs-chain *hs-k3* *hs-k1* -1.0f0 0.9f0))
        (when (< 48 cf 120) (hs-cine-bolt *hs-k3* *hs-k1* (max 0.0 (- run 0.35)) run 0)))
      (when (< 25 cf 70) (hs-cine-sparks *hs-k3* 7 (if (< cf 48) 0.8 0.95))))))

(defun hs-raiden-track (a v cf)
  "綴雷電's tracking shot (f45-90): beside the chain, following the lightning's front from his raised hand down to the
victim, held on him from f70."
  (let* ((p (pos-of a)) (q (pos-of v)) (u (min 1.0 (/ (- cf 45) 25.0))) (e (* u u (- 3 (* 2 u))))
         (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2))) (d (max 0.5 (sqrt (+ (* dx dx) (* dz dz)))))
         (ux (/ dx d)) (uz (/ dz d)) (s (* d (+ 0.1 (* 0.9 e)))) (tx (+ (aref p 0) (* s ux))) (tz (+ (aref p 2) (* s uz)))
         (ty (+ 2.0 (* -0.9 e))))
    (cine-cam (+ tx (* 3.4 (- uz)) (* -1.2 ux)) (+ ty 0.4) (+ tz (* 3.4 ux) (* -1.2 uz)) tx ty tz)))

(defcine hs-raiden-cine (a v :len 150 :hold 128)
  "Pointer 3's Kikon 綴雷電 TSUZURI RAIDEN (§26.4): 1 orbiting the victim: the chain winds three times round him; 2 close:
his left hand high on the taut chain, two fingers of the right set on it (no incantation), sparks; 3 the lightning runs
from his hand down the chain to the victim, the camera tracking along the chain; 4 the victim lit and paralysed, black
and white silhouette flashes, the Konpaku; 5 the chain goes slack, the victim drops smoking: 破道の十一 綴雷電."
  (during (0 150) (hs-raiden-look a v cf))
  ;; 1 (0-25) orbiting him: three turns (f2-22)
  (at 0 (hs-cine-stage a v 4.0) (cine-clip a :hs-s-raiden :blend 2 :time (/ 23.0 60.0) :speed 0.0)
      (cine-clip v :sh-kikon-victim :blend 4) (hold-pose v 6) (impact-frame :negative 2) (play-sfx :chain-rattle) (lens 46))
  (at 6 (cine-clip v :hs-cine-wound-v :blend 3) (play-sfx :chain-snap :pitch 1.2))
  (at 13 (play-sfx :chain-snap :pitch 1.0))
  (at 20 (play-sfx :chain-snap :pitch 0.85) (shake 0.1 0.2))
  (during (0 25) (let* ((p (pos-of a)) (q (pos-of v))
                        (ang (+ (atan (- (aref p 2) (aref q 2)) (- (aref p 0) (aref q 0))) 0.9 (* 1.9 u))))
                   (cine-cam (+ (aref q 0) (* 4.4 (cos ang))) 1.7 (+ (aref q 2) (* 4.4 (sin ang))) (aref q 0) 1.1 (aref q 2))))
  ;; 2 (25-45) close: the hand on the chain, the fingers, the sparks; silence
  (at 25 (cine-clip a :hs-cine-rd-hold :blend 4) (hs-shot a 35 2.0 2.0 1.85 :ahead 0.35) (lens 44) (silence 20)
      (play-sfx :sizzle :pitch 1.8 :gain 0.6))
  (at 38 (play-sfx :breaker-hum :pitch 1.6 :gain 0.7))
  ;; 3 (45-90) the lightning down the chain (f48-70), round the coil (f70-84); the camera along the chain
  (at 45 (lens 50) (play-sfx :sizzle :pitch 1.3) (play-sfx :breaker-hum :pitch 1.2))
  (during (45 90) (hs-raiden-track a v cf))
  (at 70 (cine-clip v :hs-cine-shock-v :blend 1) (play-sfx :explode :pitch 1.5 :gain 0.5) (play-sfx :sizzle :pitch 0.9)
      (shake 0.2 0.5) (face-beat v :hurt 3.0) (impact-frame :negative 1))
  (at 80 (play-sfx :sizzle :pitch 1.1))
  ;; 4 (90-120) lit and paralysed: the black-and-white flashes (white cards, his silhouette), the Konpaku (f100)
  (at 90 (shot-on v 30 3.8 1.2 :look 1.2) (lens 46) (card :white v) (silhouette-black v) (impact-frame :negative 2)
      (play-sfx :sizzle :pitch 1.6))
  (at 93 (unsilhouette) (card nil))
  (at 97 (card :white v) (silhouette-black v) (play-sfx :sizzle :pitch 1.4))
  (at 100 (unsilhouette) (card nil) (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :konpaku-shatter) (play-sfx :explode :pitch 0.8 :gain 0.6) (shake 0.3 0.4))
  (at 102 (impact-frame :manga 10))
  (at 112 (card :white v) (silhouette-black v))
  (at 114 (unsilhouette) (card nil))
  ;; 5 (120-150) slack; he drops, smoking; 破道の十一 綴雷電
  (at 120 (cine-clip v :sh-crumple :blend 2) (cine-clip a :hs-s-stance :blend 12) (play-sfx :chain-rattle :pitch 0.6)
      (if (portrait-p) (shot-on a 150 6.8 2.0 :look 0.9 :ahead 2.0 :off -1.4) (shot-on a 80 6.0 1.3 :look 1.0 :ahead 2.0 :off -1.2))
      (lens 44))                                                   ; (a phone: down the line, him in front of the victim)
  (during (110 150) (hs-cine-smoke v 2))
  (at 124 (caption "綴雷電" :kanji2 "破道の十一" :reading "TSUZURI RAIDEN" :sub "KAZESHINI  KIKON" :side 1 :hanko t)))

;;; ================================================================ the core Kikon 刈 KARI (pointer 2, DUEL_HISAGI §27.3, §27.8)
;;; The user, 2026-10-28, approved the storyboard (§27.3: 「可以，照表做（推薦）」): the chain wound short, the sickles spun in
;;; his fists; flash-step cuts round the victim, ink lines opening on him; he stops behind him, the sickles crossed, then
;;; drawn (the Konpaku); the victim kneels, the blood flicked off: 刈. Both sickles stay in his fists (on their short
;;; let-outs in the cuts), so HISAGI-DRAW draws them, the wound chain (its lo 8192 list has these clips) and the let-outs
;;; as in the match: no HS-CINE-OF code. The script's own looks (the slashes, the flicked blood) are DEFUN-FAST on fixnums,
;;; derived from the cine frame alone (a held still and a play-through agree). Debug 83978 plays it, 83970+b holds beat b.
(defparameter *hs-kari-cuts*
  '((26 1 2.5 :hs-kr-tan 13) (34 -1 1.7 :hs-kr-ren 9) (42 1 2.4 :hs-kr-ko 5) (50 -1 2.4 :hs-kr-age 6)
    (58 1 3.0 :hs-kr-sen 13))
  "刈's flash-step cuts (cine frame, the side of the shot he lands on, distance = the clip's let-out reach, so its sickle
points land on him, the clip, its start frame = S - 3): each strike's S 3 f after the step (f29 37 45 53 61, the slashes'
frames in %HS-KARI-CUTS); he lands side-on to the orbiting camera (HS-KARI-ORBIT's bearing -/+ 90 degrees), on
alternate sides of the victim, so every cut crosses him.")
(defun hs-kari-bearing (cf)
  "刈's orbit (f25-70): the camera's bearing round the victim's facing at cine frame CF, degrees: from 70 (his front
left) round his front to -87.5 (his right), so the slashes on his chest stay in view."
  (- 70.0 (* 3.5 (- cf 25))))
(defun hs-kari-orbit (v cf)
  "刈's orbiting shot (f25-70): round the victim at HS-KARI-BEARING (Hisagi lands up to 3 m to
his side), 1.6 m high, aimed at him (5.8 m; a phone 8.4)."
  (setf *cine-close* nil *cine-subject* nil)
  (let* ((q (pos-of v)) (yaw (+ (yaw-of v) (deg (hs-kari-bearing cf)))) (d (if (portrait-p) 8.4 5.8)))
    (cine-cam (+ (aref q 0) (* d (fwd-x yaw))) 1.6 (+ (aref q 2) (* d (fwd-z yaw))) (aref q 0) 1.1 (aref q 2))))

;; the spin (f0-25): the arms out wide on the long chain, yanked in to the 刈 stance at f6 (the chain wound short), then
;; both reverse-gripped sickles twirled in the fists (the wrists' flex a key every 90 degrees, faster and faster, the
;; left a quarter turn behind)
(defclip :hs-cine-kr-spin (0.42 :base :hs-st-kari)
  (0 (:root :u -0.1) (:spine :flex 8) (:arm-r :flex 30 :side 72 :twist 0) (:elbow-r :flex 12) (:hand-r :flex 10)
     (:arm-l :flex 30 :side 72 :twist 0) (:elbow-l :flex 12) (:hand-l :flex 10))
  (0.1 :snap :hs-st-kari)
  (0.17 (:hand-r :flex 194)) (0.23 (:hand-r :flex 284) (:hand-l :flex 194)) (0.28 (:hand-r :flex 374) (:hand-l :flex 284))
  (0.32 (:hand-r :flex 464) (:hand-l :flex 374) (:root :u -0.18)) (0.355 (:hand-r :flex 554) (:hand-l :flex 464))
  (0.39 (:hand-r :flex 644) (:hand-l :flex 554)) (0.42 (:hand-r :flex 734) (:hand-l :flex 644) (:root :u -0.2)))
;; the pass (f70-100): landed low behind him, back to back, both forearms crossed before the chest, the reverse-gripped
;; sickles trailing past the elbows (the X), held in the silence; at f88 drawn apart, flung out and down to his sides,
;; the blades out
(defpose :hs-cine-kr-cross (:base :hs-st-kari)
  (:root :u -0.3 :f 0.0) (:spine :flex 24) (:head :flex -14)
  (:arm-r :flex 64 :side -40 :twist 0) (:elbow-r :flex 78) (:hand-r :flex 100)
  (:arm-l :flex 64 :side -40 :twist 0) (:elbow-l :flex 78) (:hand-l :flex 100)
  (:thigh-l :flex 62 :side 14) (:knee-l :flex 84) (:thigh-r :flex -24 :side 16) (:knee-r :flex 40))
(defpose :hs-cine-kr-drawn (:base :hs-cine-kr-cross)
  (:root :u -0.22) (:spine :flex 10) (:head :flex -8)
  (:arm-r :flex 24 :side 78 :twist 0) (:elbow-r :flex 4) (:hand-r :flex -90)
  (:arm-l :flex 24 :side 78 :twist 0) (:elbow-l :flex 4) (:hand-l :flex -90)
  (:thigh-l :flex 52) (:knee-l :flex 70) (:thigh-r :flex -20) (:knee-r :flex 34))
(defclip :hs-cine-kr-pass (0.6 :base :hs-cine-kr-cross)
  (0) (0.26 (:root :u -0.31) (:arm-r :flex 66) (:arm-l :flex 66))
  (0.3 :snap :hs-cine-kr-drawn) (0.42 :hs-cine-kr-drawn (:root :u -0.24) (:arm-r :flex 18) (:arm-l :flex 18))
  (0.6 :hs-cine-kr-drawn (:root :u -0.23)))
;; the flick (f100-150): wound up at the shoulders (f105), whipped down and out (f108: the blood flung off,
;; %HS-KARI-FLICK), then risen slowly into the 刈 stance, the head down
(defclip :hs-cine-kr-chiburi (0.8 :base :hs-cine-kr-drawn)
  (0)
  (0.08 (:root :u -0.16) (:arm-r :flex 70 :side 70) (:elbow-r :flex 60) (:hand-r :flex 40)
        (:arm-l :flex 70 :side 70) (:elbow-l :flex 60) (:hand-l :flex 40))
  (0.13 :snap (:root :u -0.2) (:arm-r :flex 6 :side 64) (:elbow-r :flex 2) (:hand-r :flex -110)
        (:arm-l :flex 6 :side 64) (:elbow-l :flex 2) (:hand-l :flex -110))
  (0.24 (:arm-r :flex 10 :side 60) (:hand-r :flex -96) (:arm-l :flex 10 :side 60) (:hand-l :flex -96))
  (0.8 :hs-st-kari (:head :flex -2)))

(defun-fast %hs-kari-cuts (vjm cf)
  "刈's slashes on the victim (the joints VJM) at cine frame CF: one opening at each cut's S (f29 + 8 i, i 0-4) across
his chest (0.24 m down the chest joint, on its front and its back: the cut goes through him), turned round by the
golden angle: drawn across over 3 f, the ink rim widening over 4,
a white core opening inside it, a spark at its end for 3 f; all flared wide f88-92 (the drawn sickles), faded f92-100.
A look. 0 B."
  (declare (type f32vec vjm) (fixnum cf))
  (when (< cf 100)
    (let ((p *hs-k0*) (q *hs-k1*) (b *hs-k2*) (j (ji :chest))
          (fl (if (and (>= cf 88) (< cf 92)) 1f0 0f0))
          (k (if (< cf 92) 0.95f0 (* 0.95f0 (- 1f0 (/ (i->f (- cf 92)) 8f0))))))
      (declare (type f32vec p q b) (fixnum j) (single-float fl k))
      (dotimes (i 5)
        (let ((age (- cf (+ 29 (* 8 i)))))
          (declare (fixnum age))
          (when (>= age 0)
            (let* ((fi (i->f i)) (fa (i->f age)) (th (+ 0.35f0 (* 2.39996f0 fi)))
                   (ca (* 0.38f0 (f-cos th))) (sa (* 0.38f0 (f-sin th)))
                   (cx (* 0.36f0 (- (hash01 fi 2.7f0) 0.5f0))) (cy (+ -0.24f0 (* 0.4f0 (- (hash01 fi 4.3f0) 0.5f0))))
                   (g (f-min 1f0 (/ (+ fa 1f0) 3f0))) (w (f-min 1f0 (/ (+ fa 1f0) 4f0)))
                   (c (f-clamp (/ (- fa 1f0) 5f0) 0f0 1f0)) (sd (+ 600f0 (* 7f0 fi))))
              (declare (single-float fi fa th ca sa cx cy g w c sd))
              (dotimes (s 2)                                ; (his front, -z, and through to his back)
                (let ((zs (if (= s 0) -1f0 1f0)))
                  (declare (single-float zs))
                  (joint-point! p vjm j (- cx ca) (- cy sa) (* zs 0.24f0))
                  (joint-point! q vjm j (+ (- cx ca) (* 2f0 g ca)) (+ (- cy sa) (* 2f0 g sa)) (* zs 0.24f0))
                  (joint-point! b vjm j (- cx (* ca (- 1f0 g))) (- cy (* sa (- 1f0 g))) (* zs 0.3f0))
                  (fx-crescent (aref p 0) (aref p 1) (aref p 2) (aref q 0) (aref q 1) (aref q 2) (aref b 0) (aref b 1) (aref b 2)
                               (* (+ 0.09f0 (* 0.04f0 fl)) w) :lens 0.03f0 sd +pal-ink+ k :push 0.3f0)
                  (when (> c 0f0)
                    (fx-crescent (aref p 0) (aref p 1) (aref p 2) (aref q 0) (aref q 1) (aref q 2) (aref b 0) (aref b 1)
                                 (aref b 2) (+ (* 0.034f0 c) (* 0.06f0 fl)) :lens 0.02f0 (+ sd 1f0) +pal-hit+ k :push 0.34f0))))
              (when (< age 3)
                (fx-star (aref q 0) (aref q 1) (aref q 2) 0.05f0 0.22f0 6 sd 0f0 0f0 0.08f0 (+ sd 2f0) +pal-hit+ 0.95f0
                         :push 0.4f0))))))))
  nil)

(defun-fast %hs-kari-flick (pa pv cf)
  "刈's blood flicked off (f108-150; PA his feet, PV the victim's behind his back, so his facing is PV -> PA): seven drops
from each sickle (0.8 m out to each side, 0.3 m ahead, 0.6 m up) flung forward and a little out, falling under gravity
(dark red shards along their flight), each a streak on the ground where it lands (along its flight), there to the end.
From the cine frame alone. A look. 0 B."
  (declare (type f32vec pa pv) (fixnum cf))
  (when (>= cf 108)
    (let* ((dx (- (aref pa 0) (aref pv 0))) (dz (- (aref pa 2) (aref pv 2))) (l (f-max 0.01f0 (f-hypot dx dz)))
           (fx (/ dx l)) (fz (/ dz l)) (rx (- fz)) (rz fx) (tt (/ (i->f (- cf 108)) 60f0)))
      (declare (single-float dx dz l fx fz rx rz tt))
      (dotimes (s 2)
        (let ((sg (if (= s 0) 1f0 -1f0)))
          (declare (single-float sg))
          (dotimes (i 7)
            (let* ((fi (+ (i->f i) (* 10f0 (i->f s)))) (h0 (hash01 fi 7.1f0)) (h1 (hash01 fi 3.3f0)) (h2 (hash01 fi 5.9f0))
                   (vo (* sg (+ 0.2f0 (* 0.9f0 h0)))) (vf (+ 2.0f0 (* 1.8f0 h1))) (vu (+ 0.3f0 (* 1.4f0 h2)))
                   (ox (+ (aref pa 0) (* sg 0.8f0 rx) (* 0.3f0 fx))) (oz (+ (aref pa 2) (* sg 0.8f0 rz) (* 0.3f0 fz)))
                   (tl (/ (+ vu (f-sqrt (+ (* vu vu) 11.76f0))) 9.8f0)) (te (f-min tt tl))
                   (x (+ ox (* te (+ (* vo rx) (* vf fx))))) (z (+ oz (* te (+ (* vo rz) (* vf fz)))))
                   (y (+ 0.6f0 (* vu te) (* -4.9f0 te te))) (sd (+ 640f0 fi)))
              (declare (single-float fi h0 h1 h2 vo vf vu ox oz tl te x z y sd))
              (let* ((ux (+ (* vo rx) (* vf fx))) (uz (+ (* vo rz) (* vf fz))) (hl (f-max 0.01f0 (f-hypot ux uz))))
                (declare (single-float ux uz hl))
                (if (< tt tl)
                    (let* ((uy (- vu (* 9.8f0 tt))) (ul (f-max 0.01f0 (f-hypot ux uy uz))))
                      (declare (single-float uy ul))
                      (fx-shard x y z (/ ux ul) (/ uy ul) (/ uz ul) (+ 0.12f0 (* 0.08f0 h1)) 0.03f0 0.05f0 sd +pal-blood+ 0.95f0
                                :push 0.15f0))
                    (fx-shard x 0.02f0 z (/ ux hl) 0f0 (/ uz hl) (+ 0.16f0 (* 0.14f0 h0)) 0.032f0 0.08f0 sd +pal-blood+ 0.9f0
                              :push 0.05f0)))))))))
  nil)

(defun hs-kari-look (a v cf)
  "刈's looks (every frame): the slashes on the victim, the blood flicked off (from f108)."
  (when (hs-cine-shown-p v) (%hs-kari-cuts (model-joints (model v)) cf))
  (when (hs-cine-shown-p a) (%hs-kari-flick (pos-of a) (pos-of v) cf)))

(defun hs-kari-cut (a v c i)
  "刈's cut C (an *HS-KARI-CUTS* row, the I-th) at its step: the flash step round the victim (an afterimage where he
was) to the clip's reach, facing him, the clip from 3 f before its S."
  (destructuring-bind (f side d clip t0) c
    (start-ghost a) (hs-round a v d (- (hs-kari-bearing f) (* side 90)))
    (cine-clip a clip :blend 0 :time (/ t0 60.0))
    (play-sfx :hoho-out :pitch (+ 0.9 (* 0.06 i)))))

(defcine hs-kari-cine (a v :len 150 :hold 128)
  "Pointer 2's Kikon 刈 KARI (§27.3): 1 low: the chain yanked short, the sickles spinning in his fists; 2 round him: five
flash-step cuts, one on each of 刈's clips at its reach, an ink line opening on him at each; 3 behind him, back to back:
the sickles crossed, the silence, drawn apart: the slashes flare, the Konpaku; 4 wide: the victim kneels, he flicks the
blood off: 刈."
  (during (0 150) (hs-kari-look a v cf))
  ;; 1 (0-25) low, in front of him to his left, pushing in: the yank (f6), the spin
  (at 0 (hs-cine-stage a v 2.2) (cine-clip a :hs-cine-kr-spin :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-pose v 8) (freeze 8) (impact-frame :negative 2) (play-sfx :chain-rattle) (lens 54))
  (during (0 25) (hs-shot a 80 (- (if (portrait-p) 5.4 3.8) (* 0.4 u)) 0.3 1.0 :ahead 0.7))   ; (side-on: the victim whole)
  (at 6 (play-sfx :chain-snap) (shake 0.1 0.15))
  (at 12 (play-sfx :whoosh-heavy :pitch 1.3))
  (at 17 (play-sfx :whoosh-heavy :pitch 1.5))
  (at 21 (play-sfx :whoosh-heavy :pitch 1.7))
  ;; 2 (25-70) orbiting the victim round his front: the cuts (steps f26 34 42 50 58, S 3 f later), side-on to the shot
  (at 25 (lens 46))
  (during (25 70) (hs-kari-orbit v cf))
  (when step-p
    (loop for c in *hs-kari-cuts* for i from 0
          do (cond ((= cf (first c)) (hs-kari-cut a v c i))
                   ((= cf (+ 3 (first c)))
                    (cine-clip v (if (evenp i) :sh-flinch :sh-stagger) :blend 1) (play-sfx :cut :pitch (+ 0.9 (* 0.05 i)))
                    (hs-cine-hit v 1.2 :cut) (shake 0.12 0.15)))))
  ;; 3 (70-100) behind him, back to back, from in front of Hisagi: crossed, the silence; drawn (f88); the Konpaku (f90)
  (at 70 (hs-round a v 1.7 180)                                   ; (no afterimage: it stood in the shot's foreground)
      (let ((tf (transform a))) (setf (transform-yaw tf) (f32 (+ (transform-yaw tf) 3.1415927))))
      (cine-clip a :hs-cine-kr-pass :blend 0) (cine-clip v :sh-stagger :blend 2) (hold-pose v 16) (play-sfx :hoho-in)
      (silence 18)
      (if (portrait-p) (shot-on a 28 6.6 0.8 :look 1.0 :ahead -0.6) (shot-on a 28 5.2 0.7 :look 1.0 :ahead -0.6 :off -0.5))
      (lens 44))
  (at 88 (impact-frame :negative 2) (play-sfx :cut-heavy) (shake 0.3 0.4) (cine-clip v :sh-stagger :blend 0))
  (at 90 (cine-shatter v (fighter-kikon-n (fighter a))) (play-sfx :konpaku-shatter) (impact-frame :manga 10)
      (multiple-value-bind (x y z) (actor-point v 1.2) (focus-lines 10 x y z)))
  (at 94 (cine-clip v :sh-lose :blend 10))
  ;; 4 (100-150) wide, from his left: the victim kneeling behind him; the flick (f108); 刈
  (at 100 (cine-clip a :hs-cine-kr-chiburi :blend 2)
      (if (portrait-p) (shot-on a 70 7.0 1.4 :look 0.9 :ahead -0.8) (shot-on a 70 5.4 1.1 :look 0.9 :ahead -0.8 :off -0.9))
      (lens 42))
  (at 108 (play-sfx :whoosh-heavy :pitch 1.4) (play-sfx :chain-snap :pitch 1.3))
  (at 112 (caption "刈" :reading "KARI" :sub "KAZESHINI  KIKON" :side 1 :hanko t)))

