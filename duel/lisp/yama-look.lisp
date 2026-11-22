;;;; yama-look.lisp — YAMAMOTO's Bankai looks, art batch K1 (docs/duel/DUEL_YAMA_CORE.md §15.2.1 L1-L11, §16): the dead of 南 (the hands, the
;;;; swarm, the skeleton tower, its topple and shatter (§34 A), the pile), KYOKUJITSUJIN's void line, KYOKKO's lance, 西's flare and armour, 北's band. Each look sits
;;;; on its sim footprint (the hazard's disc / box, the move's volume) and its frames; the sim never reads any of it.
;;;; Colour (§15.2, the user's D4 「只有西和北有火」): charcoal / ink + bone-ash white + one ember hairline; orange flame (+PAL-FLAME+) only in
;;;; 西 (L8, L9) and 北's rim (L10). The dead (D1 「焦黑骷髏配上紅色高光」): the :skeleton body (yama-art.lisp), black with thin red highlights.
;;;; Rules: hazard looks are pure functions of HAZARD-AGE / HAZARD-DELAY (hitstop freezes the age: no one-shot keyed on it), never write the
;;;; hazard; the moves' looks (YAMA-BK-MOVES, from the :draw hook) are pure functions of the move frame; 0 B a frame (DEFUN-FAST + the toon
;;;; macros; debug 87448 measures every look).
(in-package :duel)

;;; ---------------------------------------------------------------- the dead: posed :skeleton bodies
;;; One scratch pose + joint buffer (DRAW-MESH copies each part's matrix as it queues it), at most *YA-DEAD-CAP* bodies a frame (YAMA-DRAW
;;; resets the count before the hazards draw). The pose is FK'd at the origin and then turned / moved in place (%YA-PLACE!), and the clip
;;; time is a frame index into *YA-TM*'s floats, so no float is boxed.
(declaim (type f32vec *ya-dead-pose* *ya-dead-jm* *ya-dead-at*))
(defvar *ya-dead-pose* (make-f32 +pose-n+) "YA-DEAD's sampled pose.")
(defvar *ya-dead-jm* (make-f32 (* 16 +nj+)) "YA-DEAD's posed joints.")
(defvar *ya-dead-at* (make-f32 4) "Where YA-DEAD draws the next body: x y z yaw (its caller writes them).")
(defvar *ya-dead-n* (make-array 1 :element-type 'fixnum :initial-element 0) "Bodies of the dead drawn this frame.")
(defparameter *ya-dead-cap* 8 "The most bodies of the dead drawn in one frame (§15.3.4 flag 3); the vector ink of each look still draws.")
(defvar *ya-tm* (let ((v (make-array 128))) (dotimes (i 128 v) (setf (svref v i) (/ i 60f0)))) "Frame i's clip time (s), boxed once.")

(defun-fast %ya-place! (jm at)
  "Turn every joint matrix of JM (posed at the origin, facing yaw 0) by AT's yaw and move it to AT's x y z, as POSE-FK! would have. 0 B."
  (declare (type f32vec jm at))
  (let* ((x (aref at 0)) (y (aref at 1)) (z (aref at 2)) (c (f-cos (aref at 3))) (s (f-sin (aref at 3))))
    (declare (single-float x y z c s))
    (dotimes (j +nj+)
      (let ((o (* 16 j)))
        (declare (fixnum o))
        (dotimes (col 4)
          (let* ((b (+ o (* 4 col))) (vx (aref jm b)) (vz (aref jm (+ b 2))))
            (declare (fixnum b) (single-float vx vz))
            (setf (aref jm b) (+ (* c vx) (* s vz)) (aref jm (+ b 2)) (- (* c vz) (* s vx)))))
        (setf (aref jm (+ o 12)) (+ x (aref jm (+ o 12))) (aref jm (+ o 13)) (+ y (aref jm (+ o 13)))
              (aref jm (+ o 14)) (+ z (aref jm (+ o 14)))))))
  nil)

(defun ya-dead (clip frame)
  "Draw one of the dead (the :skeleton body) posed at FRAME (60 Hz, 0-127) of CLIP (a clip name) at *YA-DEAD-AT*; nothing past the cap."
  (declare (fixnum frame))
  (let ((n (aref *ya-dead-n* 0)))
    (declare (fixnum n))
    (when (< n *ya-dead-cap*)
      (setf (aref *ya-dead-n* 0) (1+ n))
      (let ((b (find-body :skeleton)) (jm *ya-dead-jm*))
        (clip-sample! *ya-dead-pose* (find-clip clip) (svref *ya-tm* (min 127 (max 0 frame))))
        (pose-fk! jm *ya-dead-pose* 0f0 0f0 0f0 0f0 (body-scale b) (body-hunch b) (body-props b))
        (%ya-place! jm *ya-dead-at*)
        (draw-body b jm 0f0 0f0 0f0 0f0 :shadow nil)))))

(defun ya-dead-reset () "A new frame for the dead: none drawn yet (YAMA-DRAW, before the hazards draw)." (setf (aref *ya-dead-n* 0) 0))

(defmacro %ya-at (x y z yaw)
  "Write where YA-DEAD draws next (single-float forms)."
  `(let ((%a *ya-dead-at*)) (declare (type f32vec %a)) (setf (aref %a 0) ,x (aref %a 1) ,y (aref %a 2) ,z (aref %a 3) ,yaw)))

(defmacro %ya-crack-star (x z r k pulse seed)
  "The ground broken round a disc of radius R at (X Z): an INK ring on its edge with an EMBER hairline inside it (PULSE its presence: the
tell), six radial INK cracks with ember cores. Single-float forms; 0 B."
  `(progn
     (%tring ,x 0f0 ,z ,r 0.08f0 +pal-ink+ ,k (+ ,seed 1f0))
     (%tring ,x 0.006f0 ,z (* 0.94f0 ,r) 0.022f0 +pal-ember+ (* ,k ,pulse) (+ ,seed 2f0))
     (dotimes (%i 6)
       (let* ((%f (i->f %i)) (%a (+ (* 1.0472f0 %f) (hash01 %f ,seed))) (%c (f-cos %a)) (%s (f-sin %a))
              (%r2 (* ,r (+ 1.1f0 (* 0.5f0 (hash01 %f 3.1f0))))))
         (declare (single-float %f %a %c %s %r2))
         (toon-ground-seg (+ ,x (* 0.3f0 ,r %c)) (+ ,z (* 0.3f0 ,r %s)) (+ ,x (* %r2 %c)) (+ ,z (* %r2 %s)) 0.01f0 0.045f0 1f0 0.3f0
                          (+ ,seed %f) 0.2f0 (toon-a +pal-ink+ ,k))
         (toon-ground-seg (+ ,x (* 0.3f0 ,r %c)) (+ ,z (* 0.3f0 ,r %s)) (+ ,x (* 0.8f0 %r2 %c)) (+ ,z (* 0.8f0 %r2 %s)) 0.013f0 0.012f0 1f0
                          0.3f0 (+ ,seed %f 9f0) 0.1f0 (toon-a +pal-ember+ (* ,k ,pulse)))))))

;;; ---------------------------------------------------------------- L1 the dead hands (NS3a, AS3a: :ya-col via YAMA-COLUMN-FIRE)
(defun-fast yama-hands-look (hz rdt)
  "南's hands (L1): the crack star on the hit's disc (r = HAZARD-SIZE), its ember hairline pulsing through the delay (NS3a's 17 f: the tell a
Step reads); three of the dead clawing up out of it (:sk-grab, started 8 f before the clench so it lands on the hit), sinking after 18 f;
dust as they break out, ash as they go. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (d (hazard-delay hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (dr (drawing-no)) (seed (+ x (* 3f0 z)))
         (k (if (> d 0) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- life age)) 12f0)) 0f0 0.98f0)))
         (pulse (if (> d 0) (if (evenp (f->i dr)) 0.98f0 0.5f0) 0.45f0))
         (fr (if (> d 0) (- 8 d) (+ 8 age))))
    (declare (single-float x z r dr seed k pulse) (fixnum d age life fr))
    (%ya-crack-star x z r k pulse seed)
    (when (>= fr 0)
      (dotimes (i 3)
        (let* ((f (i->f i)) (a (+ (* 2.0944f0 f) (* 0.6f0 (hash01 f seed)))) (c (f-cos a)) (s (f-sin a))
               (sink (- (* 0.07f0 (i->f (max 0 (- age 18)))) 0.3f0)))   ; (+0.3 m: the skull and arms clear the floor)
          (declare (single-float f a c s sink))
          (%ya-at (+ x (* 0.7f0 r c)) (- sink) (+ z (* 0.7f0 r s)) (f-atan2 c s))   ; facing the centre
          (ya-dead :sk-grab fr))))
    (when (and (<= d 0) (< age 5))
      (dotimes (i (n-of 40f0 rdt))
        (let* ((a (rnd-range 0f0 6.2832f0)))
          (declare (single-float a))
          (%t-blob (+ x (* 0.7f0 r (f-cos a))) 0.1f0 (+ z (* 0.7f0 r (f-sin a))) (rnd-range -0.6f0 0.6f0) (rnd-range 0.3f0 1f0)
                   (rnd-range -0.6f0 0.6f0) (rnd-range 0.4f0 0.7f0) (rnd-range 0.12f0 0.22f0) -0.2f0 0.25f0 +pal-dust+))))
    (when (> age 18)
      (dotimes (i (n-of 24f0 rdt))
        (%t-blob (+ x (rnd-range (- r) r)) (rnd-range 0.1f0 0.7f0) (+ z (rnd-range (- r) r)) 0f0 (rnd-range 0.4f0 0.9f0) 0f0
                 (rnd-range 0.6f0 1f0) (rnd-range 0.04f0 0.08f0) -0.1f0 0.2f0 +pal-ash+)))
    (%light x 0.3f0 z 1f0 0.25f0 0.15f0 2f0 (* 0.8f0 k pulse) 6)
    nil))

;;; ---------------------------------------------------------------- L2 the swarm (NS3b, AS3b: the :wave)
(defun-fast yama-swarm-look (hz rdt)
  "南's swarm (L2): four of the dead crawling abreast (:sk-crawl on twos) across the wave's box (2 x HAZARD-SIZE wide), their reaching hands at
its front edge; an ASH strip dragged behind over the ground it crossed. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx)
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0))
         (trav (f-min 2.5f0 (* 0.1f0 (i->f age)))) (seed (* 7f0 yaw)))   ; (ponytail: 6 m/s; AS3b's 8 m/s trail lags a little.
                                                                       ;  HAZARD-SPEED / -PX reads boxed a float here: 16 B a draw)
    (declare (single-float x z w yaw fx fz px pz k trav seed) (fixnum age life))
    (when (> trav 0.1f0)
      (toon-ground-seg (- x (* trav fx)) (- z (* trav fz)) (+ x (* -0.5f0 fx)) (+ z (* -0.5f0 fz)) 0.012f0 (* 0.55f0 w) 0.2f0 1f0 seed 0.3f0
                       (toon-a +pal-ash+ (* 0.45f0 k))))
    (dotimes (i 4)
      (let* ((f (i->f i)) (u (* w (- (* 0.5f0 f) 0.75f0))) (lag (* 0.3f0 (hash01 f 7.1f0))) (back (+ 0.75f0 lag)))
        (declare (single-float f u lag back))
        (%ya-at (+ x (* u px) (* (- back) fx)) -0.04f0 (+ z (* u pz) (* (- back) fz)) yaw)
        (ya-dead :sk-crawl (mod (+ (logand age -2) (* 9 i)) 36))))
    (dotimes (i (n-of 20f0 rdt))
      (let* ((u (rnd-range (- w) w)))
        (declare (single-float u))
        (%t-blob (+ x (* u px) (* -0.6f0 fx)) 0.1f0 (+ z (* u pz) (* -0.6f0 fz)) 0f0 (rnd-range 0.2f0 0.6f0) 0f0
                 (rnd-range 0.5f0 0.9f0) (rnd-range 0.06f0 0.12f0) -0.1f0 0.25f0 +pal-ash+)))
    nil))

;;; ---------------------------------------------------------------- 南's skeleton tower (§30.3, §34 A: 「錐形骷髏堆」), its topple, the shatter
;;; A tapering heap of black-ink skeletons climbing on each other (Ep 372's slope of raised hands, the Sedlec skull pillars): rings of
;;; climbers (%YA-CLIMBER: an ink torso and skull with one blood-red eye spot, pale ribs, two arms reaching up) round a
;;; charcoal core, a crown of splayed hands on top. One drawer (%YA-CONE-DRAW, its arguments in *YA-CONE*) serves the standing tower, the
;;; topple's first frames, the shatter's burst and AS3b's hollow ring, so the hand-off from the spent :ya-tower to :ya-fall does not pop.
(defconstant +ya-tower-h+ 3f0 "*YA-TOWER-H* (host-checked): the tower's height a level (m).")
(defconstant +ya-tower-ahead+ 1.5f0 "*YA-TOWER-AHEAD* (host-checked): where the shatter's heap stands before him (m; 2.5 until §35).")
(defconstant +ya-cone-r1+ 0.5f0 "The tower's base radius at level 1 (m; 0.95 until 2026-11-22, the user: 「通過縮小半徑讓骷髏塔變得更密集一些」, §34.2: 0.7; 「再更密集」, §34.3: 0.5).")
(defconstant +ya-cone-r2+ 0.65f0 "... at level 2 (m; 1.25 until 2026-11-22, §34.2: 0.9, §34.3: 0.65).")
(defconstant +ya-tower-raise2+ 114
  "NSb's raise sets the tower's life to its age + this (host-checked: NSb's frames after its S + *YA-TOWER-STAND*): frames since the
climb to level 2 = this - (life - age), a pure function of the hazard (no look state).")

(defmacro %ya-climber (px py pz ax ay az tx ty tz sc k seed ph hand)
  "One of the dead climbing (a vector-ink figure about 0.65 SC m tall) standing at (PX PY PZ) along the unit axis A, its arms spread along
the unit tangent T: a small INK torso crossed by two pale ASH ribs, two INK arms reaching up and out (PH swings them), an INK skull with
one BLOOD eye spot; HAND true: three ink fingers splayed off each arm's end. Single-float forms (HAND a boolean form); 66 toon verts (+72
with hands); 0 B."
  `(let* ((%ox ,px) (%oy ,py) (%oz ,pz) (%ax ,ax) (%ay ,ay) (%az ,az) (%tx ,tx) (%ty ,ty) (%tz ,tz) (%sc ,sc) (%k ,k) (%sd ,seed)
          (%ph ,ph) (%sx (+ %ox (* 0.32f0 %sc %ax))) (%sy (+ %oy (* 0.32f0 %sc %ay))) (%sz (+ %oz (* 0.32f0 %sc %az))))
     (declare (single-float %ox %oy %oz %ax %ay %az %tx %ty %tz %sc %k %sd %ph %sx %sy %sz))
     (fx-disc (+ %ox (* 0.18f0 %sc %ax)) (+ %oy (* 0.18f0 %sc %ay)) (+ %oz (* 0.18f0 %sc %az)) (* 0.12f0 %sc) 0.15f0 %sd
              +pal-ink+ %k :push 0.05f0)                                                                ; the torso
     (dotimes (%b 2)                                                                                    ; two pale ribs across it
       (let ((%u (+ 0.13f0 (* 0.09f0 (i->f %b)))))
         (declare (single-float %u))
         (fx-shard (+ %ox (* %u %sc %ax)) (+ %oy (* %u %sc %ay)) (+ %oz (* %u %sc %az)) %tx %ty %tz (* 0.22f0 %sc) (* 0.016f0 %sc)
                   0.05f0 (+ %sd 1f0 (i->f %b)) +pal-ash+ %k :push 0.12f0)))
     (dotimes (%b 2)                                                                                    ; the arms
       (let* ((%sg (if (= %b 0) -1f0 1f0)) (%w (+ 0.24f0 (* 0.14f0 (f-sin (+ %ph (* 1.7f0 %sg))))))
              (%vx (* %sc (+ (* 0.5f0 %ax) (* %sg %w %tx)))) (%vy (* %sc (+ (* 0.5f0 %ay) (* %sg %w %ty))))
              (%vz (* %sc (+ (* 0.5f0 %az) (* %sg %w %tz)))) (%l (f-max 0.01f0 (f-sqrt (+ (* %vx %vx) (* %vy %vy) (* %vz %vz)))))
              (%dx (/ %vx %l)) (%dy (/ %vy %l)) (%dz (/ %vz %l)))
         (declare (single-float %sg %w %vx %vy %vz %l %dx %dy %dz))
         (fx-shard (+ %sx (* 0.4f0 %vx)) (+ %sy (* 0.4f0 %vy)) (+ %sz (* 0.4f0 %vz)) %dx %dy %dz %l (* 0.045f0 %sc)
                   0.05f0 (+ %sd 2f0 %sg) +pal-ink+ %k :push 0.08f0)
         (when ,hand                                                                                    ; the splayed fingers
           (dotimes (%g 3)
             (let* ((%e (* 0.6f0 (- (i->f %g) 1f0))) (%fx (+ %dx (* %e %tx))) (%fy (+ %dy (* %e %ty))) (%fz (+ %dz (* %e %tz)))
                    (%fl (f-max 0.01f0 (f-sqrt (+ (* %fx %fx) (* %fy %fy) (* %fz %fz))))) (%n (* 0.15f0 %sc)))
               (declare (single-float %e %fx %fy %fz %fl %n))
               (fx-shard (+ %sx %vx (* 0.4f0 %n (/ %fx %fl))) (+ %sy %vy (* 0.4f0 %n (/ %fy %fl))) (+ %sz %vz (* 0.4f0 %n (/ %fz %fl)))
                         (/ %fx %fl) (/ %fy %fl) (/ %fz %fl) %n (* 0.022f0 %sc) 0.05f0 (+ %sd 4f0 %sg (i->f %g)) +pal-ink+ %k
                         :push 0.1f0))))))
     (fx-disc (+ %ox (* 0.47f0 %sc %ax)) (+ %oy (* 0.47f0 %sc %ay)) (+ %oz (* 0.47f0 %sc %az)) (* 0.12f0 %sc) 0.08f0 (+ %sd 6f0)
              +pal-ink+ %k :push 0.16f0)                                                                ; the skull
     (fx-disc (+ %ox (* 0.47f0 %sc %ax) (* 0.035f0 %sc %tx)) (+ %oy (* 0.49f0 %sc %ay) (* 0.035f0 %sc %ty))
              (+ %oz (* 0.47f0 %sc %az) (* 0.035f0 %sc %tz)) (* 0.034f0 %sc) 0f0 (+ %sd 7f0) +pal-blood+ %k :push 0.24f0)))   ; its eye

(declaim (type f32vec *ya-cone*))
(defvar *ya-cone* (make-f32 17)
  "%YA-CONE-DRAW's arguments (%YA-CONE! writes them): base x z, the lean's unit direction ux uz, the lean (rad, about the base), height h
(m along the axis), base radius r0, presence k, crumble 0..1 (the top first), the climbers' scale, seed, the swarm's swirl (rad), core
(1 a charcoal core, 0 hollow), the arms' phase.")

(defmacro %ya-cone! (bx bz ux uz th h r0 k crum sc seed swirl core ph &key (lo 0f0) (hi 1f4) (gap 0f0))
  "Write *YA-CONE* (single-float forms) and draw the heap (%YA-CONE-DRAW). LO / HI: only the part of the heap between those heights (its
shape still the whole H's), the lean pivoting at LO (§34.4: the stump below the break, HI the break; the section above it, LO the break,
lifted GAP m along its axis off the crack). 0 B."
  `(let ((%a *ya-cone*))
     (declare (type f32vec %a))
     (setf (aref %a 0) ,bx (aref %a 1) ,bz (aref %a 2) ,ux (aref %a 3) ,uz (aref %a 4) ,th (aref %a 5) ,h (aref %a 6) ,r0 (aref %a 7) ,k
           (aref %a 8) ,crum (aref %a 9) ,sc (aref %a 10) ,seed (aref %a 11) ,swirl (aref %a 12) ,core (aref %a 13) ,ph
           (aref %a 14) ,lo (aref %a 15) ,hi (aref %a 16) ,gap)
     (%ya-cone-draw)))

(defmacro ya-tower-break (h)
  "Where the tower breaks before it topples (§34.4, the user 2026-11-22: 「塔請在下面斷裂開後，上截才往前傾倒」): 0.14 of its height H
(0.42 m at level 1, 0.84 m at level 2; 0.28 until §34.5: 「斷裂處改成在目前斷裂處的一半」). A macro: a function would box the float (0 B rule)."
  `(* 0.14f0 ,h))

(defun-fast %ya-cone-draw ()
  "The heap of the dead from *YA-CONE*: rings of climbers every 0.34 x scale m up the axis (0.5 until §34.2, 0.42 until §34.3) (its radius r0 (1 - q)(1 + 0.3 q) + 0.1 x scale
at height share q, so a heap that grows widens as it climbs), as many round each ring as fit 0.4 x scale apart (0.62 until §34.2, 0.5 until §34.3), the far side left out
(the camera sees the near half); the top two rings and the bottom one with splayed hands (the crown; the hands that bind); a charcoal
core of discs up the axis (core 1). The axis leans by the lean toward (ux uz), pivoting at the height LO (the base by default); only the
rings from LO up to HI drawn; nothing drawn below 6 cm. Crumble c: the
climbers above (1 - 1.15 c) h fade and drop. A look; 0 B."
  (let* ((a *ya-cone*) (bx (aref a 0)) (bz (aref a 1)) (ux (aref a 2)) (uz (aref a 3)) (th (aref a 4)) (h (aref a 5)) (r0 (aref a 6))
         (k (aref a 7)) (crum (aref a 8)) (sc (aref a 9)) (seed (aref a 10)) (swirl (aref a 11)) (core (aref a 12)) (ph (aref a 13))
         (lo (aref a 14)) (hi (aref a 15)) (gap (aref a 16))
         (s (f-sin th)) (c (f-cos th)) (ax (* s ux)) (ay c) (az (* s uz)) (ppx (- uz)) (ppz ux) (qx (* c ux)) (qy (- s)) (qz (* c uz))
         (e (camera-eye *camera*)) (ex (- (aref e 0) bx)) (ez (- (aref e 2) bz)) (el (f-max 0.01f0 (f-hypot ex ez)))
         (dy (* 0.34f0 sc)) (yc (* h (- 1f0 (* 1.15f0 crum)))) (nr (f->i (/ h dy))))
    (declare (type f32vec a e) (single-float bx bz ux uz th h r0 k crum sc seed swirl core ph lo hi gap s c ax ay az ppx ppz qx qy qz ex ez el dy yc)
             (fixnum nr))
    (when (> h 0.05f0)
      (when (and (> core 0.5f0) (< th 0.3f0))            ; the core: a charcoal mass up the axis behind the climbers (off once it leans
                                                         ;  past 17 deg: the climbers carry the shape; each puff kept off the floor)
        (dotimes (j (1+ (f->i (/ h (* 0.4f0 sc)))))
          (let* ((y (* 0.4f0 sc (+ 0.4f0 (i->f j)))) (q (f-min 1f0 (/ y h))) (r (+ (* 0.42f0 r0 (- 1f0 q) (+ 1f0 (* 0.3f0 q))) (* 0.06f0 sc)))
                 (kj (if (> y yc) (* k (f-clamp (- 1f0 (/ (- y yc) (* 0.25f0 h))) 0f0 1f0)) k)))
            (declare (single-float y q r kj))
            (when (and (< y h) (>= y lo) (< y hi) (> kj 0.02f0))
              (let ((yl (+ (- y lo) gap)))
                (declare (single-float yl))
                (fx-disc (+ bx (* yl ax)) (f-max (* 0.85f0 r) (+ lo (* yl ay))) (+ bz (* yl az)) r 0.25f0 (+ seed (i->f j) 20f0)
                         +pal-black-smoke+ kj :push 0f0))))))
      (dotimes (j (1+ nr))
        (let* ((fj (i->f j)) (y0 (* dy (+ 0.45f0 fj))) (q0 (f-min 1f0 (/ y0 h)))
               (r (+ (* r0 (- 1f0 q0) (+ 1f0 (* 0.3f0 q0))) (* 0.1f0 sc)))
               (m (max 1 (f->i (/ (* 6.2832f0 r) (* 0.4f0 sc))))) (hand (or (= j 0) (>= j (- nr 1)))))
          (declare (single-float fj y0 q0 r) (fixnum m))
          (when (and (< y0 (- h (* 0.15f0 sc))) (>= y0 lo) (< y0 hi))
            (dotimes (i m)
              (let* ((fi (i->f i)) (hs (hash01 (+ fi (* 7f0 fj)) seed))
                     (an (+ (* 6.2832f0 (/ (+ fi (* 0.5f0 (i->f (logand j 1))) (* 0.3f0 hs)) (i->f m))) (* swirl (- 1f0 q0))))
                     (ca (f-cos an)) (sa (f-sin an))
                     (y (+ y0 (* dy 0.25f0 (- hs 0.5f0))))
                     (f (if (> y yc) (f-clamp (/ (- y yc) (* 0.25f0 h)) 0f0 1f0) 0f0)) (kf (* k (- 1f0 f))) (yy (+ (- y (* 0.8f0 f) lo) gap))
                     (rx (+ (* ca ppx) (* sa qx))) (ry (* sa qy)) (rz (+ (* ca ppz) (* sa qz))))
                (declare (single-float fi hs an ca sa y f kf yy rx ry rz))
                (when (and (> kf 0.02f0) (> (+ (* rx ex) (* rz ez)) (* -0.2f0 el)))   ; (the near half and its rims)
                  (%ya-climber (+ bx (* yy ax) (* r rx)) (f-max 0.06f0 (+ lo (* yy ay) (* r ry))) (+ bz (* yy az) (* r rz))
                               (+ ax (* 0.25f0 rx)) (+ ay (* 0.25f0 ry)) (+ az (* 0.25f0 rz))
                               (- (* ca qx) (* sa ppx)) (* ca qy) (- (* ca qz) (* sa ppz))
                               (* sc (+ 0.9f0 (* 0.25f0 hs))) kf (+ seed (* 13f0 fj) fi) (+ ph (* 6.2832f0 hs)) hand)))))))))
  nil)

(defmacro %ya-tower-ash (bx bz h r0 crum rdt)
  "Ash shed off the crumbling band of a heap (above (1 - 1.15 CRUM) H) at (BX BZ). Single-float forms; 0 B."
  `(let* ((%yc (* ,h (- 1f0 (* 1.15f0 ,crum)))))
     (declare (single-float %yc))
     (dotimes (%i (n-of (* 90f0 ,crum) ,rdt))
       (let* ((%y (rnd-range (f-max 0f0 %yc) ,h)) (%r (* ,r0 (- 1f0 (/ %y (f-max 0.1f0 ,h))))) (%a (rnd-range 0f0 6.2832f0)))
         (declare (single-float %y %r %a))
         (%t-blob (+ ,bx (* %r (f-cos %a))) %y (+ ,bz (* %r (f-sin %a))) (rnd-range -0.4f0 0.4f0) (rnd-range -0.6f0 0.3f0)
                  (rnd-range -0.4f0 0.4f0) (rnd-range 0.6f0 1.1f0) (rnd-range 0.07f0 0.15f0) 0.3f0 0.25f0 +pal-ash+)))))

(defmacro %ya-tower-break-fx (x z hb fx fz r0 th rdt)
  "The break (§34.4): bones and ash spitting out of the crack at height HB round (X Z), most while the lean is young (TH small). 0 B."
  `(dotimes (%i (n-of (* 120f0 (f-clamp (- 1f0 (* 1.2f0 ,th)) 0.15f0 1f0)) ,rdt))
     (let* ((%a (rnd-range 0f0 6.2832f0)) (%ca (f-cos %a)) (%sa (f-sin %a)))
       (declare (single-float %a %ca %sa))
       (%t-blob (+ ,x (* ,r0 %ca)) ,hb (+ ,z (* ,r0 %sa)) (+ (* 1.4f0 %ca) (* 0.8f0 ,fx)) (rnd-range -0.2f0 0.9f0) (+ (* 1.4f0 %sa) (* 0.8f0 ,fz))
                (rnd-range 0.5f0 0.9f0) (rnd-range 0.06f0 0.13f0) 0.4f0 0.25f0 (if (< (rnd01) 0.35f0) +pal-ink+ +pal-ash+)))))

(defun-fast yama-tower-look (hz rdt)
  "南's tower (§34 A: the :ya-tower *YA-TOWER-AHEAD* (1.5 m since §35) before him, its level in its data): the heap swarming up out of the ground over 16 f to
*YA-TOWER-H* x level (3 / 6 m; the climb 3 -> 6 over 16 f from NSb's raise, +YA-TOWER-RAISE2+), the crown's two dead clawing out of its tip
(:sk-grab); while NSc winds up it creaks and leans toward the victim (to 50 deg at its S: YAMA-TOPPLE-LOOK takes it over from there);
crumbling to ash from the top over its last 14 f when nothing spent it. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (age (hazard-age hz)) (life (hazard-life hz)) (lv (or (getf (hazard-data hz) :level) 1))
         (since (if (>= lv 2) (max 0 (- +ya-tower-raise2+ (- life age))) -1))   ; frames since the climb to level 2
         (u1 (f-min 1f0 (/ (i->f (if (>= since 0) since age)) 16f0)))
         (e1 (- 1f0 (* (- 1f0 u1) (- 1f0 u1))))
         (h (if (>= since 0)
                (let ((h0 (if (= since age) 0f0 +ya-tower-h+)))   ; (life = its age + 114 from its first frame: NSb raised it, 0 -> 6)
                  (declare (single-float h0))
                  (+ h0 (* (- (* 2f0 +ya-tower-h+) h0) e1)))
                (* +ya-tower-h+ e1)))
         (big (>= lv 2)) (sc (if big 1.2f0 1f0)) (r0 (if big +ya-cone-r2+ +ya-cone-r1+))
         (crum (f-clamp (/ (i->f (- 14 (- life age))) 14f0) 0f0 1f0)) (seed (+ (* 3f0 x) z 50f0))
         (dr (drawing-no)) (fx 0f0) (fz -1f0) (th 0f0))
    (declare (single-float x z u1 e1 h sc r0 crum seed dr fx fz th) (fixnum age life lv since))
    (let ((o (hazard-owner hz)))                         ; NSc's wind-up: the lean toward the victim (YA-TOPPLE-DIR's rule)
      (when (and o (entity-alive-p o))
        (let* ((f (fighter o)) (mv (fighter-move f)))
          (when (and mv (eq (mv-name mv) :ya-e-n3c))
            (let* ((u (f-clamp (/ (i->f (- (fighter-sf f) 2)) 16f0) 0f0 1f0)) (v (opp-of o)) (q (pos-of v)) (p (pos-of o))
                   (dx (- (aref q 0) x)) (dz (- (aref q 2) z)) (d (f-hypot dx dz)))
              (declare (single-float u dx dz d) (type f32vec q p))
              (setf th (+ (* 1.05f0 u u u) (if (and (> u 0f0) (evenp (f->i dr))) 0.015f0 0f0)))
              (if (> d 0.5f0)
                  (setf fx (/ dx d) fz (/ dz d))
                  (let* ((px (- x (aref p 0))) (pz (- z (aref p 2))) (pl (f-max 0.01f0 (f-hypot px pz))))
                    (declare (single-float px pz pl))
                    (setf fx (/ px pl) fz (/ pz pl)))))))))
    (if (> th 0f0)                                       ; NSc's wind-up (§34.4): broken low, the stump stands, the section above leans
        (let ((hb (ya-tower-break h)))
          (declare (single-float hb))
          (%ya-cone! x z fx fz 0f0 h r0 0.98f0 crum sc seed 0f0 1f0 (* 0.9f0 dr) :hi hb)
          (%ya-cone! x z fx fz th h r0 0.98f0 crum sc seed 0f0 0f0 (* 0.9f0 dr) :lo hb :gap (* 0.45f0 (f-min 1f0 (/ th 0.4f0))))
          (%ya-tower-break-fx x z hb fx fz r0 th rdt))
        (%ya-cone! x z fx fz th h r0 0.98f0 crum sc seed (* 1.4f0 (- 1f0 e1)) 1f0 (* 0.9f0 dr)))
    (when (and (< th 0.05f0) (< crum 0.2f0) (> e1 0.6f0))   ; the crown: two of the dead clawing out of the tip
      (dotimes (b 2)
        (let ((ya (+ (* 3.1416f0 (i->f b)) (* 6.2832f0 (hash01 (i->f b) seed)))))
          (declare (single-float ya))
          (%ya-at (+ x (* 0.12f0 (f-sin ya))) (- h (* 0.55f0 sc)) (+ z (* 0.12f0 (f-cos ya))) ya)
          (ya-dead :sk-grab (min 40 (+ (* 6 b) (if (>= since 0) since age)))))))
    (when (< age 10)                                     ; the ground breaking as they swarm up
      (dotimes (i (n-of 50f0 rdt))
        (let ((a (rnd-range 0f0 6.2832f0)))
          (declare (single-float a))
          (%t-blob (+ x (* r0 (f-cos a))) 0.1f0 (+ z (* r0 (f-sin a))) (* 0.8f0 (f-cos a)) (rnd-range 0.3f0 1.2f0) (* 0.8f0 (f-sin a))
                   (rnd-range 0.4f0 0.7f0) (rnd-range 0.12f0 0.22f0) -0.2f0 0.25f0 +pal-dust+))))
    (%ya-tower-ash x z h r0 crum rdt)
    (%light x (* 0.5f0 h) z 1f0 0.2f0 0.12f0 3f0 (* 0.6f0 (- 1f0 crum)) 6)
    nil))

(defun-fast yama-topple-look (hz rdt)
  "南's topple (§34 A: :ya-fall, a 2 m wide line from the tower's base, HAZARD-SIZE half its length, hot 4): the heap carried on from the
tower's lean (50 deg) down onto the line, 72 deg at age 0 and 86 at 1 (the hit's hitstop freezes the crash), then broken along the line:
whole dead lying reaching toward the far end, skulls and bones bouncing, two crawling on (:sk-crawl), an ASH bed and cloud over the
line, an INK crack down its middle; eroding from 18 f to 30. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (half (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (ll (* 2f0 half)) (bx (- x (* half fx))) (bz (- z (* half fz)))
         (big (> ll 4.5f0)) (sc (if big 1.2f0 1f0)) (r0 (if big +ya-cone-r2+ +ya-cone-r1+)) (seed (+ (* 2f0 x) z 70f0)) (dr (drawing-no))
         (k (f-clamp (* 0.98f0 (/ (i->f (- 30 age)) 12f0)) 0f0 0.98f0)))
    (declare (single-float x z half yaw fx fz px pz ll bx bz sc r0 seed dr k) (fixnum age))
    (let ((hb (ya-tower-break ll)))                     ; the stump below the break stands, then crumbles (§34.4)
      (declare (single-float hb))
      (%ya-cone! bx bz fx fz 0f0 ll r0 0.98f0 (+ 0.6f0 (* 0.4f0 (f-clamp (/ (i->f (- age 2)) 18f0) 0f0 1f0))) sc seed 0f0 1f0 (* 0.9f0 dr)
                 :hi hb)
      (when (< age 2) (%ya-cone! bx bz fx fz (if (= age 0) 1.25f0 1.5f0) ll r0 0.98f0 0f0 sc seed 0f0 0f0 (* 0.9f0 dr) :lo hb :gap 0.45f0)))
    (if (< age 2)
        nil
        (let ((t1 (/ (i->f (- age 2)) 60f0)))
          (declare (single-float t1))
          (toon-ground-seg bx bz (+ bx (* ll fx)) (+ bz (* ll fz)) 0.01f0 0.95f0 1f0 0.4f0 seed 0.3f0 (toon-a +pal-ash+ (* 0.6f0 k)))
          (toon-ground-seg bx bz (+ bx (* ll fx)) (+ bz (* ll fz)) 0.014f0 0.09f0 1f0 0.3f0 (+ seed 1f0) 0.25f0 (toon-a +pal-ink+ k))
          (dotimes (i (if big 6 4))                      ; whole dead thrown along the line, reaching on toward its end
            (let* ((fi (i->f i)) (u (* ll (+ 0.12f0 (* 0.8f0 (/ fi (if big 6f0 4f0))) (* 0.08f0 (hash01 fi seed)))))
                   (v (* 0.7f0 (- (* 2f0 (hash01 (+ fi 3f0) seed)) 1f0))))
              (declare (single-float fi u v))
              (%ya-climber (+ bx (* u fx) (* v px)) 0.12f0 (+ bz (* u fz) (* v pz)) fx 0.15f0 fz px 0f0 pz (* 1.1f0 sc) k
                           (+ seed (* 9f0 fi)) (+ (* 0.9f0 dr) fi) t)))
          (dotimes (i (if big 22 14))                    ; skulls and bones bouncing out of the crash, settling inside the line
            (let* ((fi (i->f i)) (u (* ll (hash01 fi seed))) (v (* 0.9f0 (- (* 2f0 (hash01 (+ fi 5f0) seed)) 1f0)))
                   (vy (+ 1.2f0 (* 2.2f0 (hash01 (+ fi 9f0) seed)))) (y0 (+ 0.1f0 (* 0.6f0 r0 (- 1f0 (/ u ll)))))
                   (y (f-max 0.07f0 (- (+ y0 (* vy t1)) (* 4.9f0 t1 t1)))) (cx (+ bx (* u fx) (* v px))) (cz (+ bz (* u fz) (* v pz)))
                   (sp (+ (* 6.2832f0 (hash01 (+ fi 2f0) seed)) (* 0.5f0 (i->f (min age 14))))))
              (declare (single-float fi u v vy y0 y cx cz sp))
              (if (= (mod i 3) 0)
                  (progn (fx-disc cx (+ y 0.05f0) cz (* 0.12f0 sc) 0.08f0 (+ seed fi 30f0) +pal-ink+ k :push 0.12f0)
                         (fx-disc (+ cx (* 0.03f0 px)) (+ y 0.07f0) (+ cz (* 0.03f0 pz)) (* 0.032f0 sc) 0f0 (+ seed fi 31f0) +pal-blood+ k
                                  :push 0.2f0))
                  (fx-shard cx y cz (* (f-cos sp) fx) (* 0.3f0 (f-sin sp)) (* (f-cos sp) fz) (* 0.36f0 sc) (* 0.04f0 sc) 0.05f0
                            (+ seed fi 32f0) (if (= (mod i 3) 1) +pal-ink+ +pal-ash+) k :push 0.1f0))))
          (when (< age 26)                               ; two crawling on toward the far end
            (dotimes (b 2)
              (%ya-at (+ bx (* ll (+ 0.45f0 (* 0.35f0 (i->f b))) fx) (* (if (= b 0) 0.4f0 -0.35f0) px))
                      (* -0.03f0 (i->f (max 0 (- age 16))))
                      (+ bz (* ll (+ 0.45f0 (* 0.35f0 (i->f b))) fz) (* (if (= b 0) 0.4f0 -0.35f0) pz)) yaw)
              (ya-dead :sk-crawl (mod (+ (logand age -2) (* 11 b)) 36))))
          (when (< age 9)                                ; the ash cloud thrown up along the line
            (dotimes (i (n-of 90f0 rdt))
              (let* ((u (rnd-range 0f0 ll)) (v (rnd-range -1f0 1f0)))
                (declare (single-float u v))
                (%t-blob (+ bx (* u fx) (* v px)) 0.15f0 (+ bz (* u fz) (* v pz)) (* 1.2f0 v px) (rnd-range 0.4f0 1.8f0) (* 1.2f0 v pz)
                         (rnd-range 0.6f0 1.1f0) (rnd-range 0.1f0 0.2f0) -0.2f0 0.25f0 +pal-ash+))))))
    nil))

(defun-fast yama-shatter-look (hz rdt)
  "南's shatter (§34 A: the SA's hitless :fx, 3 m before him along his facing, HAZARD-SIZE 3): the heap +YA-TOWER-AHEAD+ ahead bursting (age 0), its
dead flung forward over the 60 deg fan out to 6 m from him (ch. 509's pile shedding shards; the heap gone by age 4): six whole dead tumbling, skulls and bones,
an ink streak behind each while it flies; most of the way out by age 1 (the hit's hitstop holds the burst), down on the ground by 14, ash
from 18 to 30. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (sz (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (ox (- x (* sz fx))) (oz (- z (* sz fz))) (rng (* 2f0 sz))
         (bx (+ ox (* +ya-tower-ahead+ fx))) (bz (+ oz (* +ya-tower-ahead+ fz))) (seed (+ (* 5f0 x) z 90f0)) (dr (drawing-no))
         (tt (f-min 1f0 (/ (i->f (1+ age)) 7f0))) (e (- 1f0 (* (- 1f0 tt) (- 1f0 tt) (- 1f0 tt))))
         (tp (f-min 1f0 (/ (i->f age) 7f0))) (ep (- 1f0 (* (- 1f0 tp) (- 1f0 tp) (- 1f0 tp))))
         (land (f-clamp (/ (i->f (- age 8)) 6f0) 0f0 1f0)) (k (f-clamp (* 0.98f0 (/ (i->f (- 30 age)) 12f0)) 0f0 0.98f0)))
    (declare (single-float x z sz yaw fx fz ox oz rng bx bz seed dr tt e tp ep land k) (fixnum age))
    (when (< age 4)                                      ; the heap coming apart as its dead leave: 2.4 m -> gone over 4 f
      (let ((u (* 0.25f0 (i->f age))))
        (declare (single-float u))
        (%ya-cone! bx bz fx fz 0f0 (* 2.4f0 (- 1f0 u)) +ya-cone-r1+ 0.98f0 (+ 0.35f0 (* 0.65f0 u)) 1f0 seed 0f0 1f0 (* 0.9f0 dr))))
    (dotimes (i 24)
      (let* ((fi (i->f i)) (an (* 0.5f0 (- (* 2f0 (hash01 fi seed)) 1f0))) (ca (f-cos an)) (sa (f-sin an))
             (dx (- (* ca fx) (* sa fz))) (dz (+ (* sa fx) (* ca fz)))   ; (FX FZ) turned by AN: inside +-28.6 deg
             (r1 (+ 3.4f0 (* (- rng 3.6f0) (hash01 (+ fi 4f0) seed)))) (r (+ 2.1f0 (* (- r1 2.1f0) e))) (rp (+ 2.1f0 (* (- r1 2.1f0) ep)))
             (y0 (+ 0.4f0 (* 2.2f0 (hash01 (+ fi 7f0) seed)))) (yf (+ (* y0 (- 1f0 (* 0.5f0 e))) (* 0.9f0 (f-sin (* 3.1416f0 e)))))
             (y (+ (* yf (- 1f0 land)) (* 0.08f0 land))) (cx (+ ox (* r dx))) (cz (+ oz (* r dz)))
             (sp (+ (* 6.2832f0 (hash01 (+ fi 2f0) seed)) (* 0.45f0 (i->f (min age 14))))))
        (declare (single-float fi an ca sa dx dz r1 r rp y0 yf y cx cz sp))
        (when (and (< age 6) (> (- r rp) 0.05f0))         ; the streak behind it
          (fx-shard (+ ox (* 0.5f0 (+ r rp) dx)) y (+ oz (* 0.5f0 (+ r rp) dz)) dx 0f0 dz (* 1.6f0 (- r rp)) 0.02f0 0.05f0 (+ seed fi 40f0)
                    +pal-ink+ (* 0.7f0 k) :push 0.05f0))
        (cond ((< i 6) (%ya-climber cx y cz (* (f-cos sp) dx) (f-sin sp) (* (f-cos sp) dz) (- dz) 0f0 dx 1f0 k (+ seed (* 9f0 fi))
                                    (+ (* 0.9f0 dr) fi) t))
              ((< i 14) (fx-disc cx (+ y 0.05f0) cz 0.12f0 0.08f0 (+ seed fi 30f0) +pal-ink+ k :push 0.12f0)
                        (fx-disc (- cx (* 0.03f0 dz)) (+ y 0.07f0) (+ cz (* 0.03f0 dx)) 0.032f0 0f0 (+ seed fi 31f0) +pal-blood+ k :push 0.2f0))
              (t (fx-shard cx y cz (* (f-cos sp) dx) (f-sin sp) (* (f-cos sp) dz) 0.36f0 0.04f0 0.05f0 (+ seed fi 32f0)
                           (if (evenp i) +pal-ink+ +pal-ash+) k :push 0.1f0)))))
    (when (< age 4)                                      ; the burst's ash thrown into the fan
      (dotimes (i (n-of 160f0 rdt))
        (let* ((an (rnd-range -0.5f0 0.5f0)) (ca (f-cos an)) (sa (f-sin an)) (sp (rnd-range 2f0 7f0)))
          (declare (single-float an ca sa sp))
          (%t-blob bx (rnd-range 0.3f0 2.4f0) bz (* sp (- (* ca fx) (* sa fz))) (rnd-range -0.3f0 1f0) (* sp (+ (* sa fx) (* ca fz)))
                   (rnd-range 0.4f0 0.8f0) (rnd-range 0.1f0 0.22f0) -0.2f0 0.25f0 +pal-ash+))))
    (when (and (>= age 18) (< age 30))                   ; the landed dead going to ash
      (dotimes (i (n-of 40f0 rdt))
        (let* ((an (rnd-range -0.5f0 0.5f0)) (rr (rnd-range 3.4f0 rng)))
          (declare (single-float an rr))
          (%t-blob (+ ox (* rr (- (* (f-cos an) fx) (* (f-sin an) fz)))) 0.1f0 (+ oz (* rr (+ (* (f-sin an) fx) (* (f-cos an) fz)))) 0f0
                   (rnd-range 0.3f0 0.8f0) 0f0 (rnd-range 0.6f0 1f0) (rnd-range 0.05f0 0.1f0) -0.1f0 0.2f0 +pal-ash+))))
    nil))

(defun-fast yama-as3b-look (hz rdt)
  "AS3b's tower round him (§34 A: the :ya-col at the victim, r HAZARD-SIZE 1.4, hot 6): the crack star on its disc and a hollow heap of
the dead (no core: he shows through) swarming up round him to 2.4 m in 5 f, crumbling to ash over its last 10 f. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (u (f-min 1f0 (/ (i->f (+ 2 age)) 7f0))) (h (* 2.4f0 (- 1f0 (* (- 1f0 u) (- 1f0 u)))))
         (crum (f-clamp (/ (i->f (- 10 (- life age))) 10f0) 0f0 1f0)) (seed (+ x (* 3f0 z) 110f0)) (dr (drawing-no)))
    (declare (single-float x z r u h crum seed dr) (fixnum age life))
    (%ya-crack-star x z r (* 0.98f0 (- 1f0 crum)) 0.45f0 seed)
    (%ya-cone! x z 0f0 -1f0 0f0 h (* 0.75f0 r) 0.98f0 crum 0.8f0 seed (* 1.4f0 (- 1f0 u)) 0f0 (* 0.9f0 dr))
    (%ya-tower-ash x z h (* 0.75f0 r) crum rdt)
    nil))

;;; ---------------------------------------------------------------- L5 the pile (AS3c)
(defun-fast yama-pile-look (hz rdt)
  "南's pile (L5: AS3c, a disc of HAZARD-SIZE at the victim, hot 6 f): the dead close in from three sides (three bodies clawing in at the
disc's edge, three charcoal heaps sliding to its centre and climbing to 1.8 m) in 8 f, the mound bursting to ash from 16 f; the ink ring
on the disc's edge with an ember hairline while it is hot. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (seed (+ x (* 5f0 z)))
         (u (f-min 1f0 (/ (i->f (+ 2 age)) 8f0))) (k (f-clamp (* 0.98f0 (/ (i->f (- 30 age)) 14f0)) 0f0 0.98f0)))
    (declare (single-float x z r seed u k) (fixnum age))
    (%tring x 0f0 z r 0.07f0 +pal-ink+ k (+ seed 1f0))
    (when (< age 6) (%tring x 0.006f0 z (* 0.95f0 r) 0.02f0 +pal-ember+ 0.9f0 (+ seed 2f0)))
    (dotimes (i 3)
      (let* ((f (i->f i)) (a (+ 0.5f0 (* 2.0944f0 f))) (c (f-cos a)) (s (f-sin a)) (rr (* r (- 1f0 (* 0.6f0 u)))))
        (declare (single-float f a c s rr))
        (when (< age 18)
          (%ya-at (+ x (* 0.85f0 r c)) (* -0.05f0 (i->f (max 0 (- age 10)))) (+ z (* 0.85f0 r s)) (f-atan2 c s))
          (ya-dead :sk-grab (+ 8 age)))
        (dotimes (j 3)                                   ; a heap: three bodies stacked, sliding in and climbing
          (let* ((g (i->f j)) (hh (* u (+ 0.3f0 (* 0.5f0 g)))))
            (declare (single-float g hh))
            (fx-disc (+ x (* (- rr (* 0.25f0 g)) c)) hh (+ z (* (- rr (* 0.25f0 g)) s)) (- 0.34f0 (* 0.06f0 g)) 0.2f0 (+ seed f g)
                     (if (evenp j) +pal-black-smoke+ +pal-ink+) k)))))
    (when (> u 0.7f0)                                    ; the crest over him, a skull on top
      (fx-disc x (* 1.35f0 u) z 0.36f0 0.2f0 (+ seed 7f0) +pal-ink+ k)
      (fx-disc x (* 1.68f0 u) z 0.13f0 0.08f0 (+ seed 8f0) +pal-ink+ k :push 0.2f0)
      (fx-disc (- x 0.045f0) (+ 0.02f0 (* 1.68f0 u)) z 0.022f0 0f0 (+ seed 9f0) +pal-blood+ k :push 0.35f0)
      (fx-disc (+ x 0.045f0) (+ 0.02f0 (* 1.68f0 u)) z 0.022f0 0f0 (+ seed 10f0) +pal-blood+ k :push 0.35f0))
    (when (and (>= age 16) (< age 24))
      (dotimes (i (n-of 120f0 rdt))
        (let* ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 1f0 3f0)))
          (declare (single-float a sp))
          (%t-blob x (rnd-range 0.3f0 1.6f0) z (* sp (f-cos a)) (rnd-range 0.3f0 1.5f0) (* sp (f-sin a)) (rnd-range 0.6f0 1f0)
                   (rnd-range 0.08f0 0.16f0) -0.2f0 0.25f0 +pal-ash+))))
    nil))

;;; ---------------------------------------------------------------- 天地灰尽's white band (AS4's last segment, art batch D; was L10 北's band)
(defmacro %ya-band (x z ux uz w y0 rise bw pal k seed)
  "A flat toon band standing across the line (X Z) - W (UX UZ) .. (X Z) + W (UX UZ) (a unit vector): its lower edge rising from Y0 at the
first end by RISE to the other, BW tall; field across its height (both long edges inked), heat 1 at the low end .. 0.4 at the high one (it
erodes from there as K fades). 8 panels. Single-float forms; 0 B."
  `(let* ((%x ,x) (%z ,z) (%ux ,ux) (%uz ,uz) (%w ,w) (%y0 ,y0) (%ri ,rise) (%bw ,bw) (%pk (toon-a ,pal ,k)) (%sd (- -1f0 (f-abs ,seed))))
     (declare (single-float %x %z %ux %uz %w %y0 %ri %bw %pk %sd))
     (with-fx-verts (%d %o :toon 48)
       (dotimes (%i 8)
         (let* ((%u0 (* 0.125f0 (i->f %i))) (%u1 (+ %u0 0.125f0)) (%a (* %w (- (* 2f0 %u0) 1f0))) (%b (* %w (- (* 2f0 %u1) 1f0)))
                (%x0 (+ %x (* %a %ux))) (%z0 (+ %z (* %a %uz))) (%x1 (+ %x (* %b %ux))) (%z1 (+ %z (* %b %uz)))
                (%ya (+ %y0 (* %u0 %ri))) (%yb (+ %y0 (* %u1 %ri))) (%h0 (- 1f0 (* 0.6f0 %u0))) (%h1 (- 1f0 (* 0.6f0 %u1))))
           (declare (single-float %u0 %u1 %a %b %x0 %z0 %x1 %z1 %ya %yb %h0 %h1))
           (vtx %x0 %ya %z0 -1f0 0f0 %h0 %sd 0.12f0 %pk)
           (vtx %x1 %yb %z1 -1f0 0f0 %h1 %sd 0.12f0 %pk)
           (vtx %x1 (+ %yb %bw) %z1 1f0 0f0 %h1 %sd 0.12f0 %pk)
           (vtx %x0 %ya %z0 -1f0 0f0 %h0 %sd 0.12f0 %pk)
           (vtx %x1 (+ %yb %bw) %z1 1f0 0f0 %h1 %sd 0.12f0 %pk)
           (vtx %x0 (+ %ya %bw) %z0 1f0 0f0 %h0 %sd 0.12f0 %pk))))))

;;; ---------------------------------------------------------------- 殘日獄衣 (L8; batch J2, DUEL_YAMA_CORE §28)
;;; The TYBW kit's garb (vfx.lisp %GARB-AURA: orange FLAME tongues from the feet up, two wings of three ribbons at the shoulders, a molten
;;; double ring, scraps, a warm light), with its camera-side tongues and wings shown (the user, 2026-11-20: 「ai-cl-game-test 的原版就做的
;;; 不錯阿？只要把面對鏡頭的火焰也顯示出來就很好了」). It replaced batch Z1's traced mantle (§27). Drawn at 西's stance (K 1), the flares of
;;; NS2a / NS2b / AS2b (K > 1) and the 西 Kikon cinematic (yama-cine.lisp %YA-GARB).
(defconstant +ya-garb-h+ 1.815f0 "The garb's height: 1.1 x his hurt height 1.65 m, as DRAW-AURA passes a form's aura.")
(declaim (type f32vec *ya-garb-args*))
(defvar *ya-garb-args* (make-f32 6)
  "YA-GARB's arguments: x z k, and [3] [4] the trailing lean x z (metres back per metre of tongue at its tip, §29.2: YAMA-LEAN-USE sets it for the
fighter whose garb is drawn next), [5] how flat the wings lie (0 .. 1: 70 deg off upright, the 西 Kikon's walk only, §29.6; YAMA-LEAN-USE
zeroes it). YA-GARB-DRAW reads them: no boxed float.")

;;; The garb trails behind him (§29.1, the user, 2026-11-21: 「請讓火衣在行走時會向反方向自然飄蕩」): a damped spring per side on his drawn
;;; velocity (his posed pelvis frame to frame), stepped in YAMA-DRAW every frame; its lean bends the garb's tongues and wings away from
;;; where he goes (each root stays where it is, the wings' on his shoulders, §29.2; the tips go furthest) and settles back upright, with a small overshoot, when he stops.
(declaim (type f32vec *ya-lean*))
(defvar *ya-lean* (make-f32 16)
  "The garb's trailing spring, 8 slots a side (at 8 x side): his pelvis's last drawn x z, his filtered velocity x z (m/s), the lean x z
(the tips' trail per metre) and its rate x z. Cosmetic: the sim never reads it.")

(defun-fast-inline yama-lean-step (side x z dt vt)
  "Step side SIDE's garb spring (*YA-LEAN*) to his pelvis at X Z after DT effect seconds (0 while frozen: hitstop, a pause; nothing moves,
the place is still kept). The velocity is the drawn delta over VT, the frame's seconds without a cinematic's slow motion (the 西 Kikon's
walk moves its actors at the script's rate while CINE-SLOW halves DT: over DT it read twice as fast and pinned the lean at its cap), its speed clamped to 10 m/s, low-passed (25 / s, so a render rate above
the sim's 60 Hz steps reads as a mean), and a jump over 0.6 m in a frame (a placement, CINE-PLACE / CINE-STAGE, a round reset, a teleport)
is not a velocity at all. Target lean: -0.09 x the velocity (the tips' trail per metre), at most 0.6 (31 deg: reached from 6.7 m/s, his run is 8; his walk
3.2 m/s leans 0.29, 16 deg). The spring: omega 10 / s, damping 0.4 (about a 25 % overshoot on a stop), semi-implicit Euler in steps of at
most 1/60 s. 0 B."
  (declare (fixnum side) (single-float x z dt vt))
  (let* ((v *ya-lean*) (o (* 8 side)) (dx (- x (aref v o))) (dz (- z (aref v (+ o 1)))) (d (f-hypot dx dz)))
    (declare (type f32vec v) (fixnum o) (single-float dx dz d))
    (setf (aref v o) x (aref v (+ o 1)) z)
    (when (> dt 0f0)
      (unless (> d 0.6f0)                                ; (a jump: no velocity this frame)
        (let* ((sp (/ d vt)) (s (if (> sp 10f0) (/ 10f0 sp) 1f0)) (a (f-min 1f0 (* 25f0 dt))))
          (declare (single-float sp s a))
          (setf (aref v (+ o 2)) (+ (aref v (+ o 2)) (* a (- (* s (/ dx vt)) (aref v (+ o 2)))))
                (aref v (+ o 3)) (+ (aref v (+ o 3)) (* a (- (* s (/ dz vt)) (aref v (+ o 3))))))))
      (let* ((tx (* -0.09f0 (aref v (+ o 2)))) (tz (* -0.09f0 (aref v (+ o 3)))) (tl (f-hypot tx tz))
             (c (if (> tl 0.6f0) (/ 0.6f0 tl) 1f0)) (n (min 4 (max 1 (f->i (+ 0.99f0 (* 60f0 dt)))))) (h (/ dt (i->f n))))
        (declare (single-float tx tz tl c h) (fixnum n))
        (setf tx (* c tx) tz (* c tz))
        (dotimes (i n)
          (setf (aref v (+ o 6)) (+ (aref v (+ o 6)) (* h (- (* 100f0 (- tx (aref v (+ o 4)))) (* 8f0 (aref v (+ o 6))))))
                (aref v (+ o 7)) (+ (aref v (+ o 7)) (* h (- (* 100f0 (- tz (aref v (+ o 5)))) (* 8f0 (aref v (+ o 7))))))
                (aref v (+ o 4)) (+ (aref v (+ o 4)) (* h (aref v (+ o 6))))
                (aref v (+ o 5)) (+ (aref v (+ o 5)) (* h (aref v (+ o 7)))))))))
  nil)

(defun-fast yama-lean-draw (jm side)
  "YAMA-DRAW's every frame: step side SIDE's garb spring to his posed pelvis (JM his joints) on this frame's effect seconds (*YA-RDT*),
then make it the lean of the garbs he draws (YAMA-LEAN-USE). The velocity's seconds: those over *CINE-TIME-SCALE* (1 out of a
cinematic). 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let* ((o (* 16 (ji :pelvis))) (dt (aref *ya-rdt* 0)) (vt (/ dt (f-max 0.05f0 (the single-float *cine-time-scale*)))))
    (declare (fixnum o) (single-float dt vt))
    (yama-lean-step side (aref jm (+ o 12)) (aref jm (+ o 14)) dt vt))
  (yama-lean-use side)
  nil)

(defun-fast yama-lean-use (side)
  "The next garbs drawn (YA-GARB) lean as side SIDE's spring says (*YA-LEAN* into *YA-GARB-ARGS* [3] [4]). 0 B."
  (declare (fixnum side))
  (let ((v *ya-lean*) (ar *ya-garb-args*) (o (* 8 side)))
    (declare (type f32vec v ar) (fixnum o))
    (setf (aref ar 3) (aref v (+ o 4)) (aref ar 4) (aref v (+ o 5)) (aref ar 5) 0f0))   ; ([5] the wings flat: the 西 Kikon only, §29.6)
  nil)

(defmacro ya-garb (x z k)
  "Draw 殘日獄衣 (YA-GARB-DRAW) at his feet (X Z), K its presence (< 1) or flare (> 1: taller x K, wider). Single-float forms, written
into *YA-GARB-ARGS*: 0 B."
  `(let ((%a *ya-garb-args*))
     (declare (type f32vec %a))
     (setf (aref %a 0) ,x (aref %a 1) ,z (aref %a 2) ,k)
     (ya-garb-draw)))

(defun-fast ya-garb-draw ()
  "殘日獄衣 from *YA-GARB-ARGS* (YA-GARB): %GARB-AURA at the floor, +YA-GARB-H+ tall, the scraps on this frame's effect seconds (*YA-RDT*,
kept by YAMA-DRAW), bent back by the trailing lean in [3] [4] (YAMA-LEAN-USE, §29.1-§29.2). A look; 0 B."
  (let* ((ar *ya-garb-args*) (x (aref ar 0)) (z (aref ar 1)) (k (aref ar 2)) (dt (aref *ya-rdt* 0)) (sx (aref ar 3)) (sz (aref ar 4))
         (wf (aref ar 5)))
    (declare (type f32vec ar) (single-float x z k dt sx sz wf))
    (%garb-aura x 0f0 z +ya-garb-h+ k dt sx sz wf))
  nil)

;;; ---------------------------------------------------------------- the moves' own looks (the :draw hook: YAMA-DRAW)
(defmacro %ya-flare (x z u k seed)
  "西's flare (L8; batch J2, §28: 殘日獄衣 flared) at his feet (X Z), U frames after its pulse, K its fade: the garb (YA-GARB) flares from
the stance's K 1 to 1.9 x K over 2 frames (1 + 0.9 x the growth; the old kit's flare), so as K fades it shrinks back to its stance size,
then fades; the molten ring on the burn's 2.0 m edge; a white-hot ring on the pulse's first two frames. Single-float forms; 0 B."
  `(let* ((%g (f-min 1f0 (/ (+ ,u 1f0) 3f0))) (%k ,k))
     (declare (single-float %g %k))
     (ya-garb ,x ,z (* %k (+ 1f0 (* 0.9f0 %g))))
     (%tring ,x 0f0 ,z 2.0f0 0.06f0 +pal-flame+ %k (+ ,seed 3f0))
     (when (< ,u 2f0)
       (%tring ,x 0.01f0 ,z 2.0f0 0.025f0 +pal-hit+ 0.98f0 (+ ,seed 4f0))
       (%tring ,x 0.01f0 ,z 0.45f0 0.05f0 +pal-hit+ 0.98f0 (+ ,seed 5f0)))))

(defun-fast-inline yama-tear (ax az fx fz len w0 w1 sl g n m seed pk)
  "東's void as a ragged radial tear (L6 and the 東 Kikon; the user, 2026-11-20, DUEL_YAMA_CORE §20 / §20.1): flat ink on the floor
(1.2 cm up) from the origin AX AZ (where the tip touched) LEN m along the unit FX FZ, its body W0 m to each side there and W1 at the far
end; N spikes on each side of the line and M fanned round each end (behind the origin, beyond the far end). A spike's base sits at an
uneven station, its tip between its two neighbours; its length out of the body is G x (SL + 0.9 x the local width) x 0.2..2.2 (cubed: most
short, a few long; the fans' x0.7); every point leans forward by 0.15..0.95 of its distance out (more toward the far end, a slow wobble +-0.3),
one smooth shear, so the spikes fan out from the origin and never cross. G 0..1 grows them out of the body (the void opening). A pure
function of SEED: no per-frame roll. One toon fan shape (PK: palette + presence + 16; heat 0 on the line, 1 on the ragged outline, where
the shader's wobble breaks it like dry brush). 24N + 12M vertices; inline, 0 B."
  (declare (single-float ax az fx fz len w0 w1 sl g seed pk) (fixnum n m))
  (let* ((px (- fz)) (pz fx) (nn (* 2 n)) (dn (i->f nn)) (dw (- w1 w0)) (il (/ 1f0 (f-max len 0.05f0)))
         (ns (+ 1f0 (f-mod (f-abs seed) 900f0))))
    (declare (single-float px pz dn dw il ns) (fixnum nn))
    (macrolet ((v (s l h u)                             ; a vertex at along S, signed lateral L, heat H, uv.x U - 2 (uv.y > 1: no INK
                                                        ;  core; uv.x < -1.6: no shade band, one flat black)
                 `(let* ((%s ,s) (%l ,l) (%c (f-clamp (* %s il) 0f0 1f0))
                         (%s2 (+ %s (* (f-abs %l) (+ 0.15f0 (* 0.8f0 %c) (* 0.3f0 (f-sin (+ (* 6f0 %c) seed))))))))
                    (declare (single-float %s %l %c %s2))
                    (vtx (+ ax (* %s2 fx) (* %l px)) 0.012f0 (+ az (* %s2 fz) (* %l pz)) (- ,u 2f0)
                         (+ 2f0 (* 0.7f0 %s2)) ,h ns 0.14f0 pk)))
               (spike (w f)                             ; a tip's length out of the body at local width W (hash index F)
                 `(let ((%h (hash01 (+ ,f 307f0) seed))) (declare (single-float %h))
                    (* g (+ sl (* 0.9f0 ,w)) (+ 0.2f0 (* 2f0 %h %h %h)))))
               (side-pt (((s l) j sk) &body body)       ; station J of side SK: along S, out L (unsigned)
                 `(let* ((%j ,j) (%f (+ (i->f %j) (* 53f0 (i->f ,sk))))
                         (%t (if (< 0 %j nn) (+ (/ (i->f %j) dn) (/ (* (if (evenp %j) 0.6f0 0.9f0) (- (hash01 %f seed) 0.5f0)) dn))
                                 (/ (i->f %j) dn)))
                         (%w (+ w0 (* dw %t))) (,s (* len %t))
                         (,l (cond ((or (= %j 0) (= %j nn)) (* 0.8f0 %w))
                                   ((evenp %j) (* %w (+ 0.5f0 (* 0.45f0 (hash01 (+ %f 211f0) seed)))))
                                   (t (+ (* 0.8f0 %w) (spike %w %f))))))
                    (declare (fixnum %j) (single-float %f %t %w ,s ,l))
                    ,@body))
               (fan-pt (((s l) i sc e w) &body body)    ; point I of the fan round along SC (E -1 behind, +1 beyond), body W
                 `(let* ((%i ,i) (%f (+ 500f0 (i->f %i) (* 40f0 ,e)))
                         (%a (if (< 0 %i (* 2 m))
                                 (* 1.5707964f0 (/ (+ (i->f %i) (* (if (evenp %i) 0.5f0 0.6f0) (- (hash01 %f seed) 0.5f0))) (i->f m)))
                                 (* 1.5707964f0 (/ (i->f %i) (i->f m)))))
                         (%r (cond ((or (= %i 0) (= %i (* 2 m))) (* 0.8f0 ,w))
                                   ((evenp %i) (* ,w (+ 0.5f0 (* 0.45f0 (hash01 (+ %f 211f0) seed)))))
                                   (t (+ (* 0.8f0 ,w) (* 0.7f0 (spike ,w %f))))))
                         (,s (+ ,sc (* ,e %r (f-sin %a)))) (,l (* %r (f-cos %a))))
                    (declare (fixnum %i) (single-float %f %a %r ,s ,l))
                    ,@body)))
      (with-fx-verts (d o :toon (+ (* 24 n) (* 12 m)))
        (dotimes (sk 2)                                   ; the two sides: a quad strip from the line out to the outline
          (let ((sg (if (= sk 0) 1f0 -1f0)))
            (declare (single-float sg))
            (dotimes (j nn)
              (side-pt ((s0 l0) j sk)
                (side-pt ((s1 l1) (1+ j) sk)
                  (v s0 0f0 0f0 0f0) (v s0 (* sg l0) 1f0 (* 0.4f0 sg)) (v s1 (* sg l1) 1f0 (* 0.4f0 sg))
                  (v s0 0f0 0f0 0f0) (v s1 (* sg l1) 1f0 (* 0.4f0 sg)) (v s1 0f0 0f0 0f0))))))
        (dotimes (k 2)                                    ; the fans round the origin (behind it) and the far end (beyond it)
          (let ((e (if (= k 0) -1f0 1f0)) (sc (if (= k 0) 0f0 len)) (w (if (= k 0) w0 w1)))
            (declare (single-float e sc w))
            (dotimes (i (* 2 m))
              (fan-pt ((s0 l0) i sc e w)
                (fan-pt ((s1 l1) (1+ i) sc e w)
                  (v sc 0f0 0f0 0f0) (v s0 l0 1f0 0.4f0) (v s1 l1 1f0 0.4f0)))))))))
  nil)

(defun yama-bk-flare-p (code sf)
  "T while YAMA-BK-MOVES' garb flare CODE (4 SHONETSU f16-35, 5 the advance S14-23, 6 the throw S12-21) draws at move frame SF: then
西's K 1 form garb is left out (YAMA-DRAW, J2's follow-up, §28.4). Fixnums; pure (a function: yama-art.lisp's YAMA-DRAW, compiled
before this file, calls it)."
  (declare (fixnum code sf))
  (case code (4 (<= 16 sf 35)) (5 (<= 14 sf 23)) (6 (<= 12 sf 21)) (t nil)))

(defun-fast yama-bk-moves (pos yaw code sf rdt)
  "The Bankai moves' own looks at his feet POS facing YAW, frame SF of the move CODE (YAMA-DRAW's table): 1 KYOKKO's lance (L7, S20-22), 2
KYOKUJITSUJIN's slit and void line (L6, S18: the full 6 m at once as a ragged tear, YAMA-TEAR, held 20 f, then filled by ash), 3 AS1's
notch (L6, S10), 4 SHONETSU's two pulses (L8, f16 and f26), 5 / 6 the advance's / the throw's flare (L8, S14 / S12); AS4 (art batch D, §34): 9 the ash grip's puff at the pommel (S10), 10 the ash
cut's ash off the rising arc (S10), 11 the ash line's thin white line at chest height (S10); 天地灰尽's band is YAMA-AS4-LOOK (it outlasts
the move). RDT: the frame's effect seconds (the ash). The flares' windows: YAMA-BK-FLARE-P. A look;
0 B."
  (declare (type f32vec pos) (single-float yaw rdt) (fixnum code sf))
  (let* ((x (aref pos 0)) (z (aref pos 2)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (drawing-no))
         (sd (i->f (mod (f->i dr) 5))) (seed (+ (* 3f0 x) z)))
    (declare (single-float x z fx fz px pz dr sd seed))
    (case code
      (1 (when (<= 20 sf 25)                             ; the lance: a white hairline in an ember lens from the cap's start to its end,
           (let* ((k (if (<= sf 22) 0.98f0 (* 0.98f0 (/ (i->f (- 26 sf)) 4f0))))   ; an ink sun r 0.3 there (its edge = the volume's 4.9)
                  (x0 (+ x (* 0.2f0 fx))) (z0 (+ z (* 0.2f0 fz))) (x1 (+ x (* 4.6f0 fx))) (z1 (+ z (* 4.6f0 fz))))
             (declare (single-float k x0 z0 x1 z1))
             (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.12f0 (* 0.5f0 (+ z0 z1)) 0.1f0 :lens 0.06f0 (+ 30f0 sd) +pal-ember+ k
                          :push 0.2f0)
             (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.12f0 (* 0.5f0 (+ z0 z1)) 0.03f0 :lens 0.03f0 (+ 35f0 sd) +pal-hit+ k
                          :push 0.24f0)
             (fx-disc x1 1.1f0 z1 0.3f0 0.1f0 (+ 40f0 sd) +pal-ink+ k :push 0.1f0)
             (fx-disc x1 1.1f0 z1 0.2f0 0.1f0 (+ 41f0 sd) +pal-ember+ k :push 0.14f0)
             (%light x1 1.1f0 z1 1f0 0.4f0 0.25f0 4f0 (* 1.6f0 k) 7))))
      ((2 3) (let* ((s (if (= code 2) 18 10)) (len (if (= code 2) 6f0 1.6f0)) (hw (if (= code 2) 0.4f0 0.3f0)))
               (declare (fixnum s) (single-float len hw))
               (when (and (>= sf s) (< sf (+ s 4)))     ; the white down-cut slit (%ST-SLIT's shape)
                 (fx-crescent (+ x (* 0.5f0 fx)) 2.3f0 (+ z (* 0.5f0 fz)) (+ x (* 1.6f0 fx)) 0.05f0 (+ z (* 1.6f0 fz))
                              (+ x (* 1.5f0 fx)) 1.6f0 (+ z (* 1.5f0 fz)) 0.1f0 :lens 0.1f0 (+ 50f0 sd) +pal-hit+ 0.98f0 :push 0.3f0))
               (when (>= sf s)                          ; the void: a ragged radial tear of flat black on the floor (D3, §20), its
                                                        ;  spikes out in 4 f; one fixed shape a move (a constant seed: nothing he
                                                        ;  does mid-cast can re-roll it)
                 (let* ((k (if (< sf (+ s 20)) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- (+ s 31) sf)) 11f0)) 0f0 0.98f0)))
                        (g (f-min 1f0 (/ (i->f (+ 1 (- sf s))) 4f0))))
                   (declare (single-float k g))
                   (yama-tear (+ x (* 0.2f0 fx)) (+ z (* 0.2f0 fz)) fx fz (- len 0.2f0) (* 0.7f0 hw) hw 0.15f0 g
                              (if (= code 2) 12 4) (if (= code 2) 4 3) (if (= code 2) 32f0 46f0) (toon-a +pal-ink+ k t))
                   (dotimes (i (n-of (if (< sf (+ s 20)) 18f0 60f0) rdt))   ; ash falling in (more as it fills)
                     (let* ((u (rnd-range 0.2f0 len)) (v (rnd-range (- hw) hw)))
                       (declare (single-float u v))
                       (%t-blob (+ x (* u fx) (* v px)) (rnd-range 0.6f0 1.6f0) (+ z (* u fz) (* v pz)) 0f0 (rnd-range -0.9f0 -0.4f0) 0f0
                                (rnd-range 0.8f0 1.2f0) (rnd-range 0.04f0 0.08f0) 0.2f0 0.2f0 +pal-ash+)))))))
      (4 (when (yama-bk-flare-p 4 sf) (%ya-flare x z (i->f (if (< sf 26) (- sf 16) (- sf 26))) (if (< sf 26) (if (< sf 23) 0.98f0 0.6f0)
                                                                                         (f-clamp (* 0.98f0 (/ (i->f (- 36 sf)) 6f0)) 0f0 0.98f0))
                                   seed)))
      (5 (when (yama-bk-flare-p 5 sf) (%ya-flare x z (i->f (- sf 14)) (f-clamp (* 0.98f0 (/ (i->f (- 24 sf)) 6f0)) 0f0 0.98f0) seed)))
      (6 (when (yama-bk-flare-p 6 sf) (%ya-flare x z (i->f (- sf 12)) (f-clamp (* 0.98f0 (/ (i->f (- 22 sf)) 6f0)) 0f0 0.98f0) seed)))
      (9 (when (<= 10 sf 24)                             ; the ash grip: a grey puff bursting out of the chest where the pommel went in
           (let* ((u (/ (i->f (- sf 10)) 14f0)) (e (- 1f0 (* (- 1f0 u) (- 1f0 u)))) (k (* 0.95f0 (- 1f0 u)))   ; (1.55 m ahead, 1.2 up)
                  (cx (+ x (* 1.55f0 fx))) (cz (+ z (* 1.55f0 fz))))
             (declare (single-float u e k cx cz))
             (when (<= sf 12)                             ; the blow: a small ink star on it
               (fx-star cx 1.2f0 cz 0.08f0 0.22f0 7 (* 6.2831855f0 (hash01 1.7f0 seed)) 0f0 0f0 0.1f0 (+ 70f0 sd) +pal-ink+ 0.98f0 :push 0.4f0))
             (dotimes (i 8)
               (let* ((f (i->f i)) (a (* 6.2831855f0 (hash01 f (+ seed 3f0)))) (d (* e (+ 0.25f0 (* 0.35f0 (hash01 f 9.1f0)))))
                      (ox (* d (f-cos a))) (oy (- (* d (f-sin a) 0.8f0) (* 0.25f0 u u))) (ah (+ (* 0.3f0 e) (* 0.1f0 (hash01 f 4.4f0)))))
                 (declare (single-float f a d ox oy ah))
                 (fx-disc (+ cx (* ah fx) (* ox px)) (+ 1.2f0 oy) (+ cz (* ah fz) (* ox pz)) (+ 0.06f0 (* 0.14f0 e)) 0.25f0 (+ 72f0 f)
                          +pal-ash+ k :push 0.2f0))))))
      (10 (when (<= 10 sf 28)                            ; the ash cut: an ash comet on the rising arc (f9 low right > S > f13 high left,
           (let* ((u (/ (i->f (- sf 10)) 18f0)) (k (* 0.9f0 (- 1f0 u))) (dn (* 0.5f0 u u))   ;  the clip's tip; the control so it
                  (ax (+ x (* 1.52f0 fx) (* 0.7f0 px))) (az (+ z (* 1.52f0 fz) (* 0.7f0 pz)))  ;  passes S's 2.0 m)
                  (bx (+ x (* 1.21f0 fx) (* -0.94f0 px))) (bz (+ z (* 1.21f0 fz) (* -0.94f0 pz)))
                  (cx (+ x (* 2.64f0 fx) (* 0.12f0 px))) (cz (+ z (* 2.64f0 fz) (* 0.12f0 pz))))
             (declare (single-float u k dn ax az bx bz cx cz))
             (when (<= sf 18)
               (fx-crescent ax (- 0.26f0 dn) az bx (- 2.16f0 dn) bz cx (- 1.29f0 dn) cz 0.13f0 :comet 0.15f0 (+ 80f0 sd) +pal-ash+
                            (* 0.9f0 (- 1f0 (/ (i->f (- sf 10)) 9f0))) :push 0.15f0))
             (dotimes (i 14)                              ; ash flakes peeling off the arc, drifting down
               (let* ((f (i->f i)) (v (hash01 f 2.3f0)) (w (- 1f0 v))
                      (bx2 (+ (* w w 0.7f0) (* 2f0 v w 0.12f0) (* v v -0.94f0))) (by2 (+ (* w w 0.26f0) (* 2f0 v w 1.29f0) (* v v 2.16f0)))
                      (ba2 (+ (* w w 1.52f0) (* 2f0 v w 2.64f0) (* v v 1.21f0)))
                      (sx (* (- (hash01 f 5.7f0) 0.5f0) 0.6f0 u)) (fall (* (+ 0.3f0 (* 0.5f0 (hash01 f 6.1f0))) u)))
                 (declare (single-float f v w bx2 by2 ba2 sx fall))
                 (fx-disc (+ x (* ba2 fx) (* (+ bx2 sx) px)) (- by2 fall) (+ z (* ba2 fz) (* (+ bx2 sx) pz)) (+ 0.025f0 (* 0.02f0 (hash01 f 8f0)))
                          0.3f0 (+ 90f0 f) (if (< (hash01 f 3.3f0) 0.25f0) +pal-ember+ +pal-ash+) k :push 0.15f0))))))
      (11 (when (<= 10 sf 22)                            ; the ash line: one thin white line along the level arc at chest height, his
           (let* ((k (if (<= sf 14) 0.98f0 (* 0.98f0 (/ (i->f (- 23 sf)) 9f0))))       ;  left to his right (r 2.0, 140 deg: the
                  (ax (+ x (* 0.68f0 fx) (* -1.88f0 px))) (az (+ z (* 0.68f0 fz) (* -1.88f0 pz)))   ;  volume), held 4 f, then eroding
                  (bx (+ x (* 0.68f0 fx) (* 1.88f0 px))) (bz (+ z (* 0.68f0 fz) (* 1.88f0 pz)))
                  (cx (+ x (* 3.32f0 fx))) (cz (+ z (* 3.32f0 fz))))
             (declare (single-float k ax az bx bz cx cz))
             (fx-crescent ax 1.3f0 az bx 1.25f0 bz cx 1.32f0 cz 0.035f0 :lens 0.03f0 (+ 100f0 sd) +pal-ink+ k :push 0.1f0)
             (fx-crescent ax 1.3f0 az bx 1.25f0 bz cx 1.32f0 cz 0.014f0 :lens 0.02f0 (+ 101f0 sd) +pal-hit+ k :push 0.14f0)))))
    nil))

(defun yama-bk-code (mv)
  "YAMA-BK-MOVES's code for the Bankai move MV, or 0."
  (case (mv-name mv)
    (:ya-e-n1a 1) (:ya-e-n1c 2) (:ya-e-as1 3) (:ya-e-n2a 4) (:ya-e-n2b 5) (:ya-e-as2b 6) (:ya-e-as4a 9) (:ya-e-as4b 10) (:ya-e-as4c 11)
    (t 0)))

;;; ---------------------------------------------------------------- 天地灰尽's band and the victim's ash (art batch D, DUEL_YAMA_CORE §34)
;;; The user, 2026-11-22: 「斜向白色斬帶」: the last segment leaves a broad white diagonal band along the cut (ch. 509's panel), the victim's
;;; body greys to ash (the Pompeii casts: the pose kept, the detail gone) with cinders falling off him for about a second, then fades back.
;;; The look outlasts the move (S10 + 32 f), so the hit is noted once (YAMA-AS4-NOTE, from YAMA-DRAW: his FIGHTER-CLS-T, the *MATCH-TICK*
;;; it was first drawn on, where he stood) in a per-side cosmetic store, and every look is a pure function of the age since (hitstop and a
;;; pause: the sim's tick). None while a cinematic runs (the held AS4's Kikon places the actors); an old entry (another round, battle) is
;;; past its life or before the tick. The grey is the victim's draw tint through the kit hook :victim-look (DRAW-FIGHTER): never written
;;; into his model, so nothing is left to restore (a cinematic's SILHOUETTE-BLACK saves and gives back MODEL-TINT; a mirror match keeps P2's
;;; tint there). The sim never reads any of it.
(declaim (type (simple-array fixnum (4)) *ya-as4-hit*) (type f32vec *ya-as4-at*))
(defvar *ya-as4-hit* (make-array 4 :element-type 'fixnum :initial-element -1)
  "天地灰尽's hit per side (2 slots a side): the FIGHTER-CLS-T of the AS4 last segment whose hit was noted, the *MATCH-TICK* it was first drawn
on (-1: none). YAMA-AS4-NOTE writes it; cosmetic.")
(defvar *ya-as4-at* (make-f32 6) "天地灰尽's hit per side (3 a side): where he stood (x z) and his yaw. Cosmetic.")
(defconstant +ya-as4-life+ 66 "Frames 天地灰尽's look lasts after the hit: the band 44, the ash held to 54 and faded back by 66 (about 1.1 s).")
(defconstant +ya-band-ahead+ 1.9f0 "The white band's distance ahead of his feet at the hit (the cut's arc, r 1.2-2.4 m: just behind the victim).")
(defparameter *ya-ash-tints*
  (coerce (loop for i below 8 collect (let ((g (- 1.0 (* 0.06 i)))) (list g g (min 1.0 (+ g 0.02))))) 'simple-vector)
  "The victim's ash by level 0-7 (YA-ASH-LEVEL): his draw tint, x his colours, grey and a touch cool at 7 (0.58), with *YA-ASH-FLASH* lifting
it toward white, so a black robe and a white haori both read as pale grey ash (TOON.FRAG multiplies the tint, then the flash mixes to white).")
(defparameter *ya-ash-flash* (coerce (loop for i below 8 collect (* 0.07 i)) 'simple-vector)
  "The victim's ash by level: the draw flash (0 .. 0.49), boxed once.")
(declaim (type simple-vector *ya-ash-tints* *ya-ash-flash*))

(defun-fast-inline ya-ash-level (age)
  "The victim's ash level 0-7 at AGE frames after 天地灰尽's hit: 0 through the hit's own flash (2 f), up to 7 by 8, held to 53, back to 0
by 66. Pure."
  (declare (fixnum age))
  (cond ((or (< age 2) (>= age +ya-as4-life+)) 0)
        ((< age 9) (- age 1))
        ((< age 54) 7)
        (t (max 0 (- 7 (floor (* 7 (- age 53)) 12))))))

(defun-fast-inline ya-as4-age (side)
  "Frames since side SIDE's last noted 天地灰尽 hit, or -1 (none, or before it: a new battle)."
  (declare (fixnum side))
  (let ((tk (aref *ya-as4-hit* (+ 1 (* 2 side)))))
    (declare (fixnum tk))
    (if (< tk 0) -1 (let ((a (- (the fixnum *match-tick*) tk))) (declare (fixnum a)) (if (< a 0) -1 a)))))

(defun yama-as4-note (e f)
  "YAMA-DRAW's every frame: note fighter F's (entity E) 天地灰尽 hit once (the move AS4's last segment, its contact :HIT, a CLS-T not yet
noted or a store from before this battle) into *YA-AS4-HIT* / *YA-AS4-AT*. Cosmetic."
  (let ((mv (fighter-move f)))
    (when (and mv (eq (fighter-state f) :move) (eq (mv-name mv) :ya-e-as4) (eq (fighter-contact f) :hit))
      (let* ((sd (fighter-side f)) (h *ya-as4-hit*) (o (* 2 sd)))
        (declare (fixnum sd o))
        (when (or (/= (aref h o) (fighter-cls-t f)) (< (ya-as4-age sd) 0))
          (setf (aref h o) (fighter-cls-t f) (aref h (1+ o)) *match-tick*)
          (let ((p (pos-of e)) (a *ya-as4-at*) (q (* 3 sd)))
            (declare (type f32vec p a) (fixnum q))
            (setf (aref a q) (aref p 0) (aref a (+ q 1)) (aref p 2) (aref a (+ q 2)) (f32 (yaw-of e)))))))))

(defun-fast yama-as4-band (at q age)
  "天地灰尽's white band (AGE frames after the hit, he stood at x z facing yaw: AT's floats Q, Q+1, Q+2, read here so no float is boxed
into the call): a broad white band standing across his front +YA-BAND-AHEAD+
ahead, 3 m wide, its lower edge rising from the floor at his right to 2.2 m at his left (the cut, low right behind to high left in front),
0.72 m tall, on an ink edge a hair larger just behind it and an ember hairline under it (a backing set further back read as a board from
the behind camera); it runs out from his right end over 3 f, holds 12, erodes
by 44. A look; 0 B."
  (declare (type f32vec at) (fixnum q age))
  (when (< -1 age 44)
    (let* ((x (aref at q)) (z (aref at (+ q 1))) (yaw (aref at (+ q 2))) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (ux (- (f-cos yaw))) (uz (f-sin yaw))   ; (U: his right to his left, -PX)
           (g (f-min 1f0 (/ (i->f (+ age 1)) 3f0))) (hw (* 1.5f0 g))
           (k (if (< age 12) 0.98f0 (* 0.98f0 (/ (i->f (- 44 age)) 32f0))))
           (rx (+ x (* +ya-band-ahead+ fx) (* -1.5f0 ux))) (rz (+ z (* +ya-band-ahead+ fz) (* -1.5f0 uz)))   ; (his right end)
           (cx (+ rx (* hw ux))) (cz (+ rz (* hw uz))) (ri (* 2.2f0 g)))
      (declare (single-float x z yaw fx fz ux uz g hw k rx rz cx cz ri))
      (%ya-band (+ cx (* 0.015f0 fx)) (+ cz (* 0.015f0 fz)) ux uz (+ hw 0.04f0) -0.05f0 ri 0.82f0 +pal-ink+ k 41f0)   ; the ink edge
      (%ya-band cx cz ux uz hw 0.0f0 ri 0.72f0 +pal-hit+ k 51f0)                                                      ; the white band
      (%ya-band (- cx (* 0.02f0 fx)) (- cz (* 0.02f0 fz)) ux uz hw -0.01f0 ri 0.035f0 +pal-ember+ k 46f0)              ; the ember hairline
      (%light cx 1.2f0 cz 1f0 0.95f0 0.85f0 5f0 (* 1.4f0 k) 7)))
  nil)

(declaim (type (simple-array fixnum (9)) *ya-ash-joints*))
(defparameter *ya-ash-joints*
  (make-array 9 :element-type 'fixnum :initial-contents (list (ji :pelvis) (ji :chest) (ji :head) (ji :upper-arm-r) (ji :upper-arm-l)
                                                             (ji :thigh-r) (ji :thigh-l) (ji :shin-r) (ji :shin-l)))
  "The victim's joints the cinders fall from (YAMA-AS4-CINDERS).")

(defun-fast yama-as4-cinders (jm age)
  "The victim's cinders and ash (AGE frames after 天地灰尽's hit; JM his posed joints): 18 cinders, short curved ember streaks with a bright
point on every third, and 10 grey ash flakes, each born at a hashed frame 4-30 by one of his joints (*YA-ASH-JOINTS*), falling slowly (0.6
m/s, the flakes 0.4) with a little sway, gone in 36 f (the flakes 44): a slow rain off a body turned to ash, never an explosion
(sp30-art-refs §2). A pure function of AGE (no per-frame roll). A look; 0 B."
  (declare (type f32vec jm) (fixnum age))
  (when (< 3 age +ya-as4-life+)
    (dotimes (i 28)
      (let* ((f (i->f i)) (b (+ 4 (f->i (* 26f0 (hash01 f 1.3f0))))) (tt (- age b)) (flake (>= i 18)) (life (if flake 44 36)))
        (declare (single-float f) (fixnum b tt life))
        (when (< -1 tt life)
          (let* ((o (* 16 (aref *ya-ash-joints* (mod i 9)))) (t1 (i->f tt))
                 (u (/ t1 (i->f life))) (k (* 0.95f0 (- 1f0 (* u u))))
                 (x (+ (aref jm (+ o 12)) (* 0.3f0 (- (hash01 f 2.9f0) 0.5f0)) (* 0.05f0 (f-sin (+ (* 0.2f0 t1) f)))))
                 (y (- (+ (aref jm (+ o 13)) (* 0.2f0 (- (hash01 f 4.1f0) 0.5f0))) (* (if flake 0.0067f0 0.01f0) t1)))
                 (z (+ (aref jm (+ o 14)) (* 0.3f0 (- (hash01 f 6.7f0) 0.5f0)))))
            (declare (fixnum o) (single-float t1 u k x y z))
            (when (> y 0.02f0)
              (if flake
                  (fx-disc x y z (+ 0.03f0 (* 0.025f0 (hash01 f 7.3f0))) 0.3f0 (+ 110f0 f) +pal-ash+ k :push 0.1f0)
                  (let ((l (+ 0.1f0 (* 0.08f0 (hash01 f 8.9f0)))) (cv (* 0.04f0 (- (hash01 f 9.7f0) 0.5f0))))
                    (declare (single-float l cv))
                    (fx-crescent x y z (+ x (* 0.3f0 cv)) (+ y l) z (+ x cv) (+ y (* 0.5f0 l)) (+ z cv) 0.022f0 :comet 0.05f0 (+ 120f0 f)
                                 +pal-ember+ (if (evenp (+ i (the fixnum (floor age 4)))) k (* 0.6f0 k)) :push 0.12f0)
                    (when (zerop (mod i 3))
                      (fx-disc x y z 0.022f0 0.1f0 (+ 130f0 f) +pal-hit+ k :push 0.14f0))))))))))
  nil)

(defun yama-as4-look (e f)
  "YAMA-DRAW's every frame (any form, any state): note 天地灰尽's hit (YAMA-AS4-NOTE), then while its look lasts, the white band where he
cut (YAMA-AS4-BAND) and the cinders off the victim (YAMA-AS4-CINDERS, on his drawn joints). A held last segment's Kikon follow-up (his
phase :follow) or any cinematic ends it at once (the store's tick cleared: the victim is told to guard, then the cinematic places the
actors; nothing of it comes back after). A look."
  (when (or *cine* (eq (fighter-phase f) :follow))
    (setf (aref *ya-as4-hit* (+ 1 (* 2 (fighter-side f)))) -1)
    (return-from yama-as4-look nil))
  (yama-as4-note e f)
  (let ((age (ya-as4-age (fighter-side f))))
    (declare (fixnum age))
    (when (and (<= 0 age) (< age +ya-as4-life+))
      (let ((a *ya-as4-at*) (q (* 3 (fighter-side f))) (o (opp-of e)))
        (declare (type f32vec a) (fixnum q))
        (yama-as4-band a q age)
        (when o (yama-as4-cinders (model-joints (model o)) age))))))

(defun yama-victim-look (att v)
  "His kit hook :victim-look (DRAW-FIGHTER, the victim V's body; ATT = Yamamoto): V's draw tint and flash while 天地灰尽's ash lasts (by
YA-ASH-LEVEL: constants, 0 B), else NIL NIL (his own tint)."
  (declare (ignore v))
  (let* ((age (ya-as4-age (fighter-side (fighter att)))) (lv (if (and (>= age 0) (null *cine*)) (ya-ash-level age) 0)))
    (declare (fixnum age lv))
    (if (> lv 0) (values (svref *ya-ash-tints* lv) (svref *ya-ash-flash* lv)) (values nil nil))))

;;; ---------------------------------------------------------------- the pointer stances' looks (art K2, §17: YAMA-DRAW)
(defun-fast yama-stance-look (pos yaw an)
  "The Bankai's pointer stances, while his idle clip AN plays one (art K2, DUEL_YAMA_CORE §15.2.2 / §17), at his feet POS: :YA-ST-MINAMI
南's faint ember cracks (six thin ink cracks out to 0.45-0.7 m with ember cores pulsing with the stance clips' 2.4 s breath, no ring).
西's garb left this look in J2's follow-up (§28.4): it is 西's form aura now (YAMA-GARB-AT, every frame under the pointer). 東 has the
blade's smoke thread only (YAMA-DRAW). YAW unused (kept for the callers). A look; 0 B."
  (declare (type f32vec pos) (single-float yaw))
  (let* ((c (anim-clip an)) (nm (and c (clip-name c))))
    (when (eq nm :ya-st-minami)
      (let* ((x (aref pos 0)) (z (aref pos 2)) (seed (+ (* 3f0 x) z))
             (b (+ 0.5f0 (* 0.5f0 (f-sin (* 2.618f0 (fx-clock)))))))   ; the breath 0..1 (2.4 s, the stance clips' loop)
        (declare (single-float x z seed b))
        (dotimes (i 6)                                   ; six thin cracks out from under his feet, no ring (faint: not L1's tell)
          (let* ((f (i->f i)) (a (+ (* 1.0472f0 f) (hash01 f seed))) (co (f-cos a)) (si (f-sin a))
                 (r2 (+ 0.45f0 (* 0.25f0 (hash01 f 3.1f0)))))
            (declare (single-float f a co si r2))
            (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* r2 co)) (+ z (* r2 si)) 0.01f0 0.022f0 1f0 0.3f0
                             (+ seed f) 0.2f0 (toon-a +pal-ink+ 0.6f0))
            (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* 0.85f0 r2 co)) (+ z (* 0.85f0 r2 si)) 0.013f0 0.008f0
                             0.3f0 0.3f0 (+ seed f 9f0) 0.1f0 (toon-a +pal-ember+ (* 0.6f0 (+ 0.45f0 (* 0.4f0 b))))))))))
  nil)

(declaim (type f32vec *ya-garb-p*))
(defvar *ya-garb-p* (make-f32 3) "YAMA-GARB-AT's pelvis point.")
(declaim (type f32vec *ya-garb-sizes*))
(defparameter *ya-garb-sizes* (let ((a (make-f32 3))) (setf (aref a 0) 0.6f0 (aref a 1) 1.0f0 (aref a 2) 1.4f0) a)
  "西's garb in play by 西's charge level 0 / 1 / 2 (§30.2, the user 2026-11-21: 「縮小基礎狀態下的火衣大小」, then NSa / NSb grow it): its K
at the base 0.6 (1.0 until §30.2), after NSa 1.0, after NSb 1.4 (YAMA-GARB-K). The 西 Kikon's sizes (§29) stay. A look.")
(defun-fast-inline yama-garb-k (f)
  "西's garb K now for fighter F (§30.2; *YA-GARB-SIZES* by level): through NSa level 0 -> 1 over its startup, through NSb 1 -> 2, NSc 2
(its level baked in), else the charge his string carries (FIGHTER-CHARGE-MULT's level, YA-CHARGE-LEVEL's thresholds: 0 again at
neutral). 0 B."
  (let* ((mv (fighter-move f)) (nm (and mv (eq (fighter-state f) :move) (mv-name mv))) (sz *ya-garb-sizes*)
         (cm (fighter-charge-mult f))
         (lv (case nm
               (:ya-e-n2a (f-min 1f0 (/ (i->f (fighter-sf f)) (i->f (max 1 (mv-s mv))))))
               (:ya-e-n2b (+ 1f0 (f-min 1f0 (/ (i->f (fighter-sf f)) (i->f (max 1 (mv-s mv)))))))
               (:ya-e-n2c 2f0)
               (t (cond ((>= cm 1.65f0) 2f0) ((>= cm 1.35f0) 1f0) (t 0f0))))))   ; (YA-CHARGE-LEVEL's, yama.lisp; YAMA-WEST-FLAME's: keep the three equal)
    (declare (type f32vec sz) (single-float cm lv))
    (if (<= lv 1f0)
        (+ (aref sz 0) (* lv (- (aref sz 1) (aref sz 0))))
        (+ (aref sz 1) (* (- lv 1f0) (- (aref sz 2) (aref sz 1)))))))
(defun-fast yama-garb-at (jm f)
  "西's form aura (J2's follow-up, §28.4; the lead, 2026-11-21: the TYBW kit drew the garb as the West form's aura through every move):
殘日獄衣 at K 1 on the floor under his pelvis (JM his posed joints), so it goes with him when a clip lunges (NS2c, AS2a carry the body
about 1 m ahead of his sim position; the old form aura stayed at the sim position). YAMA-DRAW calls it every frame he is in the Bankai
under 西, but while a flare draws it flared, while the 西 Kikon cinematic draws its own, and while his body is hidden. Its K: fighter F's
西 charge (YAMA-GARB-K, §30.2). A look; 0 B."
  (declare (type f32vec jm))
  (let ((v *ya-garb-p*))
    (declare (type f32vec v))
    (joint-point! v jm (ji :pelvis) 0f0 0f0 0f0)
    (ya-garb (aref v 0) (aref v 2) (yama-garb-k f)))
  nil)

;;; ---------------------------------------------------------------- 西's flame on the charged swings (art batch C, §34, §30.2)
;;; The user, 2026-11-22 (「跟著蓄力等級變大」): while 西's charge rides his string, every swing (the charged SA copies, the J / AS links of
;;; *YA-REACH-MOVES*, NS2c's level-2 cut) throws the garb's flame along the blade's path: a flame arc in the cut's plane with curled tongues
;;; on its outer edge (Rengoku's 昇り炎天, sp30-art-refs.md §3), its edge 0.8 / 1.6 m past the drawn tip (*YA-CHARGE-REACH*: the reach the
;;; copies add, so the flame shows where the volume now ends). AS2b's 360 deg burn throws a ring of tongues out to its reach instead.
;;; The arc is sampled from the move's clip by FK (as tests/duel-rules/art.lisp measures the reach): a pure function of the move frame, so
;;; hitstop, slow motion and a cancel need no history. Colour: the garb's +PAL-FLAME+ (flame class: the 0.8 flame layer). A look; 0 B.
(declaim (type f32vec *ya-arc-pose* *ya-arc-jm* *ya-arc-v* *ya-arc-o* *ya-arc-pts*))
(defvar *ya-arc-pose* (make-f32 +pose-n+) "YA-WEST-ARC's sampled pose (its own: YA-DEAD poses in the same frame).")
(defvar *ya-arc-jm* (make-f32 (* 16 +nj+)) "YA-WEST-ARC's sampled joints, FK'd at the origin facing yaw 0.")
(defvar *ya-arc-v* (make-f32 3) "YA-WEST-ARC's sampled point.")
(defvar *ya-arc-o* (make-f32 3) "YA-FLAME-OUT!'s point.")
(defconstant +ya-arc-n+ 24 "The most samples of one arc (half frames: S-2 .. S+A+1 is 2 (A + 3) + 1).")
(defvar *ya-arc-pts* (make-f32 (* 9 +ya-arc-n+))
  "YA-WEST-ARC's samples, oldest first, 9 floats each (world): the inner point (along the blade), the striking point, the flame's edge.")
(declaim (type f32vec *ya-arc-sm*))
(defvar *ya-arc-sm* (make-f32 (* 12 +ya-arc-n+)) "YA-WEST-ARC's path smoothed (2n - 1 points, 6 floats each: the striking point, the span to the edge).")
(defvar *ya-tm2* (let ((v (make-array 256))) (dotimes (i 256 v) (setf (svref v i) (/ i 120f0))))
  "Half frame i's clip time (s), boxed once (*YA-TM*'s halves: the arc's samples).")

(defun-fast-inline ya-flame-out! (out vx vy vz add)
  "西's flame edge (§34 C) for a striking point (VX VY VZ) from his feet (FK at the origin, facing -Z): OUT = the point ADD m further out on
the floor plane, away from his axis (the arc volume's radial measure: the edge sits where the charged copy's volume ends, tip + ADD), raised
or lowered along the cut's lean from his chest (0.6 x the point's slope from 1.25 m up, at most 45 deg) but kept 0.1 m off the floor. A
point on his axis (< 5 cm) goes ahead. Pure; host-checked (tests/duel-rules/art.lisp). 0 B."
  (declare (type f32vec out) (single-float vx vy vz add))
  (let* ((q (f-hypot vx vz)) (ux (if (> q 0.05f0) (/ vx q) 0f0)) (uz (if (> q 0.05f0) (/ vz q) -1f0))
         (e (f-clamp (/ (* 0.6f0 (- vy 1.25f0)) (f-max q 0.3f0)) -1f0 1f0)))
    (declare (single-float q ux uz e))
    (setf (aref out 0) (+ vx (* add ux)) (aref out 1) (f-max 0.1f0 (+ vy (* add e))) (aref out 2) (+ vz (* add uz))))
  nil)

(defun %ya-arc-fk (clip ti body)
  "YA-WEST-ARC's sample: CLIP's pose at half frame TI (*YA-TM2*) FK'd at the origin facing yaw 0 into *YA-ARC-JM* (YA-DEAD's way: the time
boxed once, the origin literal, BODY's numbers read here). 0 B."
  (declare (fixnum ti))
  (clip-sample! *ya-arc-pose* clip (svref *ya-tm2* (min 255 (max 0 ti))))
  (pose-fk! *ya-arc-jm* *ya-arc-pose* 0f0 0f0 0f0 0f0 (body-scale body) (body-hunch body) (body-props body))
  nil)

(defun-fast ya-west-arc (e clip mv sf add hand body weapon an)
  "西's flame arc (§34 C) for E's charged swing MV (its CLIP, at move frame SF; BODY his body, WEAPON the held weapon), ADD the charge's
reach (m). HAND 1: the free hand strikes (AS2a's grab, the blade planted), else the blade's tip. The path is sampled every half frame from
S-2 to now (at most S+A+1, then held and gone over 6 frames; now = his drawn clip's time, AN his anim, so the flame leaves the blade
he is seen holding: the clip runs a step ahead of SF, FIGHTER-STEP advances it after the move frame; SF while AN plays another clip), each
sample's inner point (0.55 along the blade / the forearm), striking point and edge (YA-FLAME-OUT!). Drawn: the arc, the path smoothed (a
Catmull-Rom point between two samples) with a camera-facing flame tongue at every point from 0.3 of the way out to the edge, hooked back
along the cut and up, and a short one back in past the striking point, overlapping into a band with a ragged hooked edge (Rengoku's arc),
thinner and fainter toward its tail; the newest blade sheathed in flame from its middle to the edge (the reach reads edge-on too); a warm light. A look; 0 B."
  (declare (fixnum sf hand) (single-float add))
  (let* ((s (mv-s mv)) (a (mv-a mv)) (sp (the single-float (mv-clip-speed mv)))
         (cur (if (eq (anim-clip an) clip) (/ (* 60f0 (the single-float (anim-time an))) sp) (i->f sf)))   ; (move frames)
         (lo (- s 2)) (top (+ s a 1)) (hi2 (min (f->i (+ 0.5f0 (* 2f0 cur))) (* 2 top)))
         (fade (if (> cur (i->f top)) (- 1f0 (/ (- cur (i->f top)) 6f0)) 1f0)))
    (declare (fixnum s a lo top hi2) (single-float sp cur fade))
    (when (and (>= cur (i->f lo)) (> fade 0f0))
      (let* ((p (pos-of e)) (yaw (the single-float (yaw-of e))) (c (f-cos yaw)) (sn (f-sin yaw))
             (px (aref p 0)) (py (aref p 1)) (pz (aref p 2))
             (wl (if (= hand 0) (the single-float (weapon-len weapon)) 0f0))
             (jm *ya-arc-jm*) (v *ya-arc-v*) (o *ya-arc-o*) (pts *ya-arc-pts*) (n 0))
        (declare (type f32vec p jm v o pts) (single-float yaw c sn px py pz wl) (fixnum n))
        (loop for h of-type fixnum from (* 2 (max 0 lo)) to hi2
              while (< n +ya-arc-n+)
              do (%ya-arc-fk clip (f->i (+ 0.5f0 (* sp (i->f h)))) body)
                 (let ((b (* 9 n)))
                   (declare (fixnum b))
                   (macrolet ((put (k) `(let ((vx (aref v 0)) (vz (aref v 2)))   ; (V turned to his yaw at his feet, as POSE-FK!)
                                          (declare (single-float vx vz))
                                          (setf (aref pts (+ b ,k)) (+ px (* c vx) (* sn vz)) (aref pts (+ b ,(+ k 1))) (+ py (aref v 1))
                                                (aref pts (+ b ,(+ k 2))) (+ pz (- (* c vz) (* sn vx)))))))
                     (if (= hand 0)
                         (joint-point! v jm (ji :weapon-r) 0f0 0f0 (* -0.55f0 wl))
                         (joint-point! v jm (ji :lower-arm-r) 0f0 -0.1f0 0f0))
                     (put 0)
                     (if (= hand 0)
                         (joint-point! v jm (ji :weapon-r) 0f0 0f0 (- wl))
                         (joint-point! v jm (ji :hand-r) 0f0 0f0 0f0))
                     (ya-flame-out! o (aref v 0) (aref v 1) (aref v 2) add)
                     (put 3)
                     (setf (aref v 0) (aref o 0) (aref v 1) (aref o 1) (aref v 2) (aref o 2))
                     (put 6)))
                 (incf n))
        (let* ((k (* 0.95f0 fade)) (pk (toon-a +pal-flame+ k)) (fp (flow-ph)) (wt (+ 0.07f0 (* 0.05f0 add)))
               (sm *ya-arc-sm*) (m (1- (* 2 n))) (im (/ 1f0 (i->f (max 1 (1- m))))))
          (declare (single-float k pk fp wt im) (type f32vec sm) (fixnum m))
          (macrolet ((pt (j i) `(aref pts (+ (* 9 ,j) ,i))))
            (dotimes (kk m)                               ; the path smoothed: each sample, and a Catmull-Rom point between two (6 floats:
              (let* ((j (the fixnum (floor kk 2))) (b (* 6 kk)) (j0 (max 0 (1- j))) (j1 (min (1- n) (1+ j))) (j2 (min (1- n) (+ j 2))))
                (declare (fixnum j b j0 j1 j2))           ;  the striking point, the span to the edge)
                (dotimes (i 3)
                  (if (evenp kk)
                      (setf (aref sm (+ b i)) (pt j (+ 3 i)) (aref sm (+ b 3 i)) (- (pt j (+ 6 i)) (pt j (+ 3 i))))
                      (setf (aref sm (+ b i)) (- (* 0.5625f0 (+ (pt j (+ 3 i)) (pt j1 (+ 3 i)))) (* 0.0625f0 (+ (pt j0 (+ 3 i)) (pt j2 (+ 3 i)))))
                            (aref sm (+ b 3 i)) (* 0.5f0 (+ (- (pt j (+ 6 i)) (pt j (+ 3 i))) (- (pt j1 (+ 6 i)) (pt j1 (+ 3 i)))))))
                  nil)))
            (dotimes (kk m)                               ; the arc: a tongue at every point, rooted 0.3 of the way out from the striking
              (let* ((b (* 6 kk)) (ba (* 6 (max 0 (- kk 2)))) (u (* im (i->f kk)))   ;  point, its tip on the edge (every other one 0.7 as
                     (sx (aref sm (+ b 3))) (sy (aref sm (+ b 4))) (sz (aref sm (+ b 5)))  ;  long), hooked back along the cut (toward the
                     (rx (+ (aref sm b) (* 0.3f0 sx))) (ry (+ (aref sm (+ b 1)) (* 0.3f0 sy))) (rz (+ (aref sm (+ b 2)) (* 0.3f0 sz)))
                     (lk (* 0.7f0 (if (oddp (- m kk)) 1f0 0.7f0) (+ 0.85f0 (* 0.3f0 (flow01 (i->f kk) 3.3f0)))))   ;  older point) and up, and a
                     (ax (* lk sx)) (ay (* lk sy)) (az (* lk sz)) (al (f-hypot ax ay az))   ;  short one back in past the blade's path (no
                     (tx (- (aref sm ba) (aref sm b))) (ty (- (aref sm (+ ba 1)) (aref sm (+ b 1))))   ;  blunt root): the overlapping
                     (tz (- (aref sm (+ ba 2)) (aref sm (+ b 2)))) (tl (f-max 1f-3 (f-hypot tx ty tz)))   ;  tongues make the band, their
                     (cu (if (= kk 0) 0f0 (/ (* 0.4f0 al) tl)))                                          ;  tips its ragged edge;
                     (w (* wt (+ 0.45f0 (* 0.55f0 u)))) (pq (toon-a +pal-flame+ (* k (+ 0.55f0 (* 0.45f0 u))))))   ;  thinner and shorter-
                (declare (fixnum b ba) (single-float u sx sy sz rx ry rz lk ax ay az al tx ty tz tl cu w pq))   ;  lived (heat) toward the tail
                (toon-ribbon (rx ry rz) (ax ay az) (w 0f0) :heat (1f0 (+ 0.1f0 (* 0.15f0 u))) :seed (- -530f0 (i->f kk))
                             :wob 0.3f0 :k pq :ph (+ fp (i->f kk)) :sway 0.05f0 :segs 5
                             :bend ((* cu tx) (+ (* cu ty) (* 0.25f0 al)) (* cu tz)))
                (toon-ribbon (rx ry rz) ((* -0.38f0 sx) (* -0.38f0 sy) (* -0.38f0 sz)) ((* 0.8f0 w) 0f0) :heat (1f0 0.3f0) :seed (- -590f0 (i->f kk))
                             :wob 0.25f0 :k pq :ph (+ fp (i->f kk) 0.5f0) :sway 0.03f0 :segs 3)))
            (let* ((j (1- n)) (ix (pt j 0)) (iy (pt j 1)) (iz (pt j 2)))   ; the newest blade sheathed: its middle out to the edge
              (declare (fixnum j) (single-float ix iy iz))
              (toon-ribbon (ix iy iz) ((- (pt j 6) ix) (- (pt j 7) iy) (- (pt j 8) iz)) ((* 1.2f0 wt) 0f0) :seed -560f0 :wob 0.25f0 :k pk
                           :ph fp :sway 0.04f0 :segs 6)
              (%light (pt j 3) (pt j 4) (pt j 5) 1f0 0.58f0 0.28f0 3.5f0 k 7)))))))
  nil)

(defun-fast ya-west-ring (e mv sf)
  "西's flame for AS2b's charged throw (§34 C): its burn is round him (arc 360, the copy's reach the charge's further), so the flame is a
ring of curled tongues on the floor whose tips stand at that reach (MV-REACH of the copy in play), the garb's molten ring at 2.0 m
(%YA-FLARE) inside it. Rises over S-1 .. S+1 (from 0.6 of the radius), holds to S+A+1, gone over 6 frames. A look; 0 B."
  (declare (fixnum sf))
  (let* ((s (mv-s mv)) (a (mv-a mv)) (top (+ s a 1)) (r (the single-float (mv-reach mv)))
         (g (f-clamp (/ (i->f (- sf (- s 2))) 3f0) 0f0 1f0))
         (fade (if (> sf top) (- 1f0 (/ (i->f (- sf top)) 6f0)) 1f0)))
    (declare (fixnum s a top) (single-float r g fade))
    (when (and (>= sf (- s 1)) (> fade 0f0))
      (let* ((p (pos-of e)) (x (aref p 0)) (z (aref p 2)) (rr (* r (+ 0.6f0 (* 0.4f0 g)))) (k (* 0.95f0 fade))
             (pk (toon-a +pal-flame+ k)) (fp (flow-ph)) (b0 (- rr 0.45f0)))
        (declare (type f32vec p) (single-float x z rr k pk fp b0))
        (%tring x 0f0 z (- rr 0.3f0) 0.12f0 +pal-flame+ k 7f0 48)
        (dotimes (i 20)
          (let* ((f (i->f i)) (an (+ (* 0.31416f0 f) (* 0.2f0 (hash01 f 5.3f0)))) (co (f-cos an)) (si (f-sin an))
                 (lk (+ 0.8f0 (* 0.4f0 (flow01 f 2.7f0)))))
            (declare (single-float f an co si lk))
            (toon-ribbon ((+ x (* b0 co)) 0.04f0 (+ z (* b0 si))) ((* 0.45f0 co) (* 0.6f0 lk) (* 0.45f0 si)) (0.1f0 0f0)
                         :seed (- -570f0 f) :wob 0.3f0 :k pk :ph (+ fp f) :sway 0.05f0 :segs 5
                         :bend ((* -0.18f0 si) (* 0.15f0 lk) (* 0.18f0 co)))))
        (%light x 0.6f0 z 1f0 0.58f0 0.28f0 (+ r 1f0) (* 0.9f0 k) 7))))
  nil)

(defun yama-west-flame (e f m mv)
  "YAMA-DRAW's 西 flame (§34 C) for E's Bankai move MV: the charge level the swing carries (a charged SA copy its own :charge-mult, NS2c its
baked level 2, a move of *YA-REACH-MOVES* the string's FIGHTER-CHARGE-MULT; YA-CHARGE-LEVEL's thresholds), then YA-WEST-RING for AS2b,
YA-WEST-ARC from the free hand for AS2a, from the blade for the rest. Nothing at level 0, out of the main phase or while his body is hidden.
A look."
  (let* ((n (mv-name mv)) (cm (plist-get (mv-params mv) :charge-mult))
         (lv (cond (cm (ya-charge-level cm))
                   ((eq n :ya-e-n2c) 2)
                   ((member n *ya-reach-moves*) (let ((c (fighter-charge-mult f)))   ; (YA-CHARGE-LEVEL's thresholds, inline: no
                                                  (cond ((>= c 1.65) 2) ((>= c 1.35) 1) (t 0))))   ;  boxed float; YAMA-GARB-K's too: keep the three equal)
                   (t 0))))
    (when (and (plusp lv) (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (> (model-alpha m) 0.5))
      (let ((add (nth (1- lv) *ya-charge-reach*)) (w (model-weapon m)))
        (cond ((eq n :ya-e-as2b) (ya-west-ring e mv (fighter-sf f)))
              ((or w (eq n :ya-e-as2))
               (ya-west-arc e (find-clip (kit-move-clip (fighter-kit f) (mv-clip mv))) mv (fighter-sf f) add (if (eq n :ya-e-as2) 1 0)
                            (model-body m) (and w (find-weapon w)) (model-anim m))))))))

;;; ---------------------------------------------------------------- art K3 (§18): the planted blade, 北's burn
(defparameter *ya-plants*
  '((:ya-e-as2 4 26 (0.14f0 0.5f0)) (:ya-e-as2b 0 30 (0.14f0 0.5f0) :carried)   ; the grab / the throw: at his right (YA-E-PLANT-R)
    (:ya-e-as3b 0 24 (0.79f0 0.2f0)) (:ya-e-as3c 0 6 (0.79f0 0.2f0) :carried)      ; the dead's AS: by his front foot (YA-E-AS3A-HIT)
    (:ya-b-j3 2 24 (0.14f0 0.5f0)))                                                 ; 爆炎's IKKOTSU: at his right (YA-IKKOTSU-PLANT, art S4)
  "The moves whose blade stands in the plaza, the hand off it (the Bankai's; 爆炎's IKKOTSU since art S4, the Shikai's and 爆炎's :planted
hook too): (move from to (ahead right) [:carried]), planted from frame FROM up
to TO (the clip's hand leaves the hilt after FROM, or it was left by the segment before: :CARRIED; it is back on it at TO), at (ahead
right) m from his feet. The spots are the clips' grips by FK (the planted weapon's grip stands 0.76 m up, BODY.LISP DRAW-PLANTED-WEAPON;
host-checked in tests/duel-rules/art.lisp).")
(defun yama-planted (e f mv)
  "His KIT-HOOK :planted (DRAW.LISP PLANTED-SPOT; every form since art S4): the constant (ahead right) of *YA-PLANTS* while MV's main phase
is inside its window, else NIL (the blade in his hand). A look; 0 B."
  (declare (ignore e))
  (let ((p (and mv (eq (fighter-phase f) :main) (assoc (mv-name mv) *ya-plants*))))
    (and p (<= (the fixnum (second p)) (fighter-sf f)) (< (fighter-sf f) (the fixnum (third p))) (fourth p))))

(defun-fast %ya-blade-burn (tip base sf)
  "北's NS gather (§15.2.2: the blade trailing low behind him, the only time the Bankai's blade burns; D4: 北 has fire): five orange tongues
rising off the blade from BASE to TIP, building over f0-15 and gone through the coil (f16-20). SF the move frame. A look; 0 B."
  (declare (type f32vec tip base) (fixnum sf))
  (when (<= sf 20)
    (let* ((k (if (<= sf 15) (f-min 0.98f0 (+ 0.35f0 (* 0.045f0 (i->f sf)))) (* 0.98f0 (/ (i->f (- 20 sf)) 5f0))))
           (fp (flow-ph)) (bx (aref base 0)) (by (aref base 1)) (bz (aref base 2))   ; (flowing, one seed a tongue: the blade moves,
           (dx (- (aref tip 0) bx)) (dy (- (aref tip 1) by)) (dz (- (aref tip 2) bz)))   ;  so no seed from its position, §15.7)
      (declare (single-float k fp bx by bz dx dy dz))
      (dotimes (i 5)
        (let* ((f (i->f i)) (u (+ 0.2f0 (* 0.19f0 f))) (h (* (+ 0.32f0 (* 0.08f0 f)) (+ 0.75f0 (* 0.5f0 (flow01 f 7.7f0))))))
          (declare (single-float f u h))
          (%tongue (+ bx (* u dx)) (+ by (* u dy)) (+ bz (* u dz)) (* -0.25f0 dx h) h (* -0.25f0 dz h) 0.08f0 +pal-flame+ k
                   (+ 80f0 f) (+ fp f) 0.03f0 :segs 4)))))
  nil)

;;; ---------------------------------------------------------------- L9 西's armour (FEEDBACK-SYSTEM's :armored event, the kit hook :armored-fx)
(defun yama-armored-fx (def x y z)
  "The Bankai's :armored-fx hook: an NA absorbed on 西's armour (NS2b / NS2c's :turn-armor, the core verdict :absorb) shows the garb's
block, the fire hexagon facing the attacker (VFX-GARB-BLOCK), and the scorch on the attacker's sword hand (VFX-SCORCH). L9, a look."
  (when (eq (fighter-form (fighter def)) :bankai)
    (let ((att (opp-of def)))
      (multiple-value-bind (dx dz) (hit-dir def att)
        (vfx-garb-block x y z dx dz))
      (let ((v *ya-tip*))                               ; (the attacker's sword hand)
        (joint-point! v (model-joints (model att)) (ji :hand-r) 0f0 0f0 0f0)
        (vfx-scorch (aref v 0) (aref v 1) (aref v 2))))))

;;; ================================================================ the Shikai's looks (art batch S1: DUEL_YAMA_CORE §21.2, §22)
;;; SL0-SL9, Ryujin Jakka's fire on the Shikai's (and 爆炎's) footprints. Colour (§21.2): FIRE orange the mass, EMBER the backing and every
;;; floor mark, INK the shadow side of the big shapes; white-hot (HIT) only as the core of a segment that paid heat, by its tier. The fire's
;;; shapes are ribbons with low heat lanes (0.3 .. 0.12), so FIRE's own pale core never shows: the only core is the tier's. Heat (§21.8 Q1
;;; 「明顯但適中」): T0 60 % of the height and of the tongues, no core; T1 80 %, a white core 30 % wide; T2 100 %, the core 60 %, an EMBER
;;; scorch on the floor 30 f. The ground edge never moves with heat: every floor mark is the sim's footprint (a :wave's box is 2 x size
;;; across and 2 x +YA-WAVE-HALF+ along, centred on the hazard). Every look's hit frame (a hazard's age 0 after its delay, the move's S)
;;; draws the full hit extent: hitstop freezes it there (§22.2). Pure functions of the hazard's age / delay / hits left or the move frame;
;;; reads heat (a hazard's :heat, YAMA-SEG-HEAT, the form), never writes; 0 B (debug 87449).
(defconstant +ya-wave-half+ 0.5f0 "A :wave's box half-length along its travel (tuning.lisp *WAVE-BOX*'s second, host-checked).")
(defconstant +ya-spiral-speed+ 14f0 "NS1a's :speed (host-checked): the spiral's tail and scorch.")
(defconstant +ya-lance-speed+ 18f0 "NS2a's :speed (host-checked): the lance's scorch line.")
(defconstant +ya-tornado-speed+ 10f0 "NS1c's :speed (host-checked; 爆炎's too): T2's scorch.")
(defconstant +ya-ring-band+ 0.25f0 "*YA-RING-BAND* (host-checked): the burning ring's half width.")
(defconstant +ya-col-delay+ 13f0 "NS1b's :delay (host-checked): the ghost lights' clock.")
(defconstant +ya-fire-h+ 2.4f0 "*YA-FIRE-H* (host-checked): how high his ground fire hits, the column's and the dome's height at T2.")

(defun ya-heat-tier (paid blaze)
  "The heat tier his fire draws at (§21.2): 2 in 爆炎 (BLAZE) or for a full spend (PAID 25, *YA-HEAT-NS*: host-checked), 1 for part of it,
0 for none (NS2b's ring, an AS, the SA, a refunded segment). Pure."
  (cond ((or blaze (>= paid 24.99)) 2) ((> paid 0.001) 1) (t 0)))

(defun ya-hz-tier (hz)
  "The tier of his fire hazard HZ: its data's :heat (what its segment paid at its fire frame; 0 once refunded), 2 while its owner is in 爆炎.
Reads only."
  (let ((o (hazard-owner hz)))
    (ya-heat-tier (plist-get (hazard-data hz) :heat 0f0) (and o (entity-alive-p o) (eq (fighter-form (fighter o)) :blaze)))))

(defmacro %ya-k (k)
  "A fade K (0 .. 0.98) as the presence of a low-heat ribbon: the toon shader erodes an along shape from its low-heat end, and with heat lanes
of 0.3 .. 0.12 the whole shape is gone below 0.7, so the fade runs over 0.69 .. 0.97 (the tips go first, then the rest)."
  `(+ 0.69f0 (* 0.29f0 ,k)))
(defmacro %ya-hf (tier) "The tier's share of the height and of the tongues (fixnum form)." `(case ,tier (0 0.6f0) (1 0.8f0) (t 1f0)))
(defmacro %ya-core (tier) "The tier's white core, a share of the width." `(case ,tier (0 0f0) (1 0.3f0) (t 0.6f0)))

(defmacro %ya-tongue (x y z ax ay az w tier k seed ph &key (segs 4) (back t) (pal '+pal-fire+))
  "One tongue of his fire from (X Y Z) along (AX AY AZ), base half-width W: an EMBER backing behind it (BACK), the PAL mass, and for TIER 1 / 2
a white (HIT) core 30 / 60 % of its width in front, over its lower half (the root burns hottest). Low heat lanes: no palette core but the tier's. Single-float forms (TIER fixnum); 0 B."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%ax ,ax) (%ay ,ay) (%az ,az) (%w ,w) (%k (%ya-k ,k)) (%sd (- -1f0 (f-abs ,seed))) (%ph ,ph) (%ti ,tier))
     (declare (single-float %x %y %z %ax %ay %az %w %k %sd %ph) (fixnum %ti))
     ,@(when back
         `((let ((%bx %x) (%by %y) (%bz %z))
             (declare (single-float %bx %by %bz))
             (%away-from-eye (%bx %by %bz) 0.05f0
               (toon-ribbon (%bx %by %bz) ((* 1.12f0 %ax) (* 1.12f0 %ay) (* 1.12f0 %az)) ((* 1.25f0 %w) 0f0) :heat (0.3f0 0.12f0)
                            :seed (- %sd 300f0) :wob 0.3f0 :pal +pal-ember+ :k %k :ph %ph :sway 0.04f0 :segs ,segs)))))
     (toon-ribbon (%x %y %z) (%ax %ay %az) (%w 0f0) :heat (0.3f0 0.12f0) :seed %sd :wob 0.3f0 :pal ,pal :k %k :ph %ph :sway 0.04f0
                  :segs ,segs)
     (when (> %ti 0)
       (let ((%cw (if (= %ti 1) 0.3f0 0.6f0)) (%cx %x) (%cy %y) (%cz %z))
         (declare (single-float %cw %cx %cy %cz))
         (%away-from-eye (%cx %cy %cz) -0.03f0
           (toon-ribbon (%cx %cy %cz) ((* 0.5f0 %ax) (* 0.5f0 %ay) (* 0.5f0 %az)) ((* %cw %w) 0f0) :heat (0.3f0 0.12f0)
                        :seed (- %sd 600f0) :wob 0.2f0 :pal +pal-hit+ :k %k :ph %ph :sway 0.04f0 :segs 3))))))

(defmacro %ya-seg (x0 y0 z0 x1 y1 z1 w0 w1 tier k seed ph &key (pal '+pal-fire+))
  "A strand of his fire from (X0 Y0 Z0) to (X1 Y1 Z1), half-widths W0 .. W1: the PAL mass, the tier's white core inside. 0 B."
  `(let* ((%x ,x0) (%y ,y0) (%z ,z0) (%ax (- ,x1 %x)) (%ay (- ,y1 %y)) (%az (- ,z1 %z)) (%w0 ,w0) (%w1 ,w1) (%k (%ya-k ,k))
          (%sd (- -1f0 (f-abs ,seed))) (%ph ,ph) (%ti ,tier))
     (declare (single-float %x %y %z %ax %ay %az %w0 %w1 %k %sd %ph) (fixnum %ti))
     (toon-ribbon (%x %y %z) (%ax %ay %az) (%w0 %w1) :heat (0.3f0 0.2f0) :seed %sd :wob 0.25f0 :pal ,pal :k %k :ph %ph :sway 0.02f0 :segs 2)
     (when (> %ti 0)
       (let ((%cw (if (= %ti 1) 0.3f0 0.6f0)))
         (declare (single-float %cw))
         (%away-from-eye (%x %y %z) -0.03f0
           (toon-ribbon (%x %y %z) (%ax %ay %az) ((* %cw %w0) (* %cw %w1)) :heat (0.3f0 0.2f0) :seed (- %sd 600f0) :wob 0.15f0
                        :pal +pal-hit+ :k %k :ph %ph :sway 0.02f0 :segs 2))))))

(defmacro %ya-floor-box (x z fx fz w k seed)
  "A :wave's footprint on the floor (its box: 2 W across, 2 x +YA-WAVE-HALF+ along, centred on (X Z), facing (FX FZ)): an
EMBER patch. 0 B."
  `(toon-ground-seg (- ,x (* +ya-wave-half+ ,fx)) (- ,z (* +ya-wave-half+ ,fz)) (+ ,x (* +ya-wave-half+ ,fx)) (+ ,z (* +ya-wave-half+ ,fz))
                    0.013f0 ,w 1f0 0.5f0 ,seed 0.2f0 (toon-a +pal-ember+ ,k)))

;;; ---------------------------------------------------------------- SL1 NS1a's spiral (the :wave, 2.0 m, 14 m/s)
(defun-fast yama-spiral-look (hz rdt)
  "NS1a's spiral stream (SL1: the :wave 2 x HAZARD-SIZE wide): a corkscrew of two FIRE strands wound round the lane's axis over an EMBER
backing, a rolling head whose front is the box's, a tail that thins 2.5 m behind it (over the lane it crossed only); on the floor an EMBER
strip as wide as the box from its front back under the tail. By tier: the strands' height and share, the white core; T2 the scorch 30 f
back. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (flow-ph))   ; (DR: a flowing phase, §15.7)
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0))
         (tail (f-min 2.5f0 (* (i->f age) (/ +ya-spiral-speed+ 60f0)))) (len (+ +ya-wave-half+ tail))
         (hx (+ x (* +ya-wave-half+ fx))) (hz2 (+ z (* +ya-wave-half+ fz)))
         (rv (* 0.75f0 hf)) (yc (+ 0.2f0 rv)) (spin (flow-ph 18.849556f0)) (seed (* 7f0 yaw)))   ; (spin: 90 deg a drawing, now turning smoothly)
    (declare (single-float x z w yaw hf fx fz px pz dr k tail len hx hz2 rv yc spin seed) (fixnum age life ti))
    (toon-ground-seg hx hz2 (- hx (* len fx)) (- hz2 (* len fz)) 0.012f0 w 1f0 0.3f0 (+ 20f0 seed) 0.2f0 (toon-a +pal-ember+ (* 0.5f0 k)))
    (when (= ti 2)                                     ; T2: the scorch over the last 30 f of the lane
      (let ((sc (* (i->f (min age 30)) (/ +ya-spiral-speed+ 60f0))))
        (declare (single-float sc))
        (when (> sc len)
          (toon-ground-seg (- hx (* len fx)) (- hz2 (* len fz)) (- hx (* sc fx)) (- hz2 (* sc fz)) 0.011f0 (* 0.6f0 w) 0.8f0 0.1f0
                           (+ 21f0 seed) 0.3f0 (toon-a +pal-ember+ (* 0.5f0 k))))))
    (let ((sx (- hx (* len fx))) (sy yc) (sz (- hz2 (* len fz))))   ; the backing: a dark-red streak along the axis
      (declare (single-float sx sy sz))
      (%away-from-eye (sx sy sz) 0.35f0
        (toon-ribbon (sx sy sz) ((* len fx) 0f0 (* len fz)) ((* 0.2f0 rv) (* 0.8f0 rv)) :heat (0.3f0 0.25f0) :seed (- -40f0 (f-abs seed))
                     :wob 0.3f0 :pal +pal-ember+ :k (%ya-k (* 0.9f0 k)) :ph dr :sway 0.05f0 :segs 5)))
    (dotimes (st 2)                                    ; the two strands, wound round the axis (turning continuously since §15.7; on twos before)
      (dotimes (i 10)
        (let* ((u0 (* 0.1f0 (i->f i))) (u1 (+ u0 0.1f0)) (ph (* 3.1416f0 (i->f st)))
               (s0 (- +ya-wave-half+ 0.12f0 (* u0 len))) (s1 (- +ya-wave-half+ 0.12f0 (* u1 len)))
               (a0 (+ spin ph (* 2.6f0 s0))) (a1 (+ spin ph (* 2.6f0 s1)))
               (r0 (* 0.85f0 w (- 1f0 (* 0.55f0 u0)))) (r1 (* 0.85f0 w (- 1f0 (* 0.55f0 u1))))
               (v0 (* rv (- 1f0 (* 0.45f0 u0)))) (v1 (* rv (- 1f0 (* 0.45f0 u1))))
               (c0 (* r0 (f-cos a0))) (c1 (* r1 (f-cos a1))))
          (declare (single-float u0 u1 ph s0 s1 a0 a1 r0 r1 v0 v1 c0 c1))
          (when (<= (hash01 (+ (i->f i) (* 11f0 (i->f st))) 5.3f0) hf)     ; the tier's share of the strand
            (%ya-seg (+ x (* s0 fx) (* c0 px)) (+ yc (* v0 (f-sin a0))) (+ z (* s0 fz) (* c0 pz))
                     (+ x (* s1 fx) (* c1 px)) (+ yc (* v1 (f-sin a1))) (+ z (* s1 fz) (* c1 pz))
                     (* 0.12f0 (- 1f0 (* 0.7f0 u0))) (* 0.12f0 (- 1f0 (* 0.7f0 u1))) ti k (+ seed (* 13f0 (i->f st)) (i->f i)) (+ dr (i->f i)))))))
    (dotimes (j 6)                                     ; the rolling head: a ball of tongues, its front the box's
      (let* ((f (i->f j)) (an (+ (* 1.0472f0 f) (* 0.5f0 spin))) (l (* (+ 0.32f0 (* 0.18f0 (flow01 f 4.7f0))) (+ 0.5f0 (* 0.5f0 hf))))
             (ca (f-cos an)) (sa (f-sin an)))
        (declare (single-float f an l ca sa))
        (when (<= (hash01 f 6.1f0) hf)
          (%ya-tongue (- x (* 0.12f0 fx)) yc (- z (* 0.12f0 fz)) (* l (- (* 0.7f0 ca) 0.3f0) fx) (* l sa) (* l (- (* 0.7f0 ca) 0.3f0) fz)
                      0.13f0 ti k (+ 50f0 f seed) (+ dr f)))))
    (%light x yc z 1f0 0.45f0 0.12f0 3f0 (* 0.7f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- SL4 NS2a's stream (the :wave, 1.2 m, 18 m/s): batch 1's fire wave
(defmacro %ya-up (tier)
  "Batch J1 (§28.3): the tier's growth over batch 1's silhouette (05acf777, which T0 draws as it was): x1.0 / x1.15 / x1.3 for T0 / T1 / T2
(and every 爆炎 segment), from %YA-HF's steps. The ring, the dome and NS2a's wave grow by it; their white core is %YA-CORE's."
  `(+ 0.55f0 (* 0.75f0 (%ya-hf ,tier))))

(defmacro %ya-wave-line (x z sx sz fx fz hw ox oz)
  "Fill *WAVE-XS* / *WAVE-ZS* with NS2a's wave base (batch 1's %WAVE-LINE): 9 points along its crescent, the middle at (X Z), the ends
bowed back 0.7 m, HW either side across (SX SZ), shifted by (OX OZ). 0 B."
  `(dotimes (%i 9)
     (let* ((%u (- (* 0.25f0 (i->f %i)) 1f0)) (%b (* 0.7f0 %u %u)))
       (declare (single-float %u %b))
       (setf (aref *wave-xs* %i) (+ ,x ,ox (* ,sx %u ,hw) (- (* %b ,fx)))
             (aref *wave-zs* %i) (+ ,z ,oz (* ,sz %u ,hw) (- (* %b ,fz)))))))

(defun-fast yama-lance-look (hz rdt)
  "NS2a's stream (the :wave 2 x HAZARD-SIZE = 1.2 m wide): batch 1's fire wave back (05acf777 VFX-FIRE-WAVE, re-ported by batch J1, the
user 2026-11-20: 「NS 跟 AS 的 城郭炎上 反而是重作前的版本更有魄力」, §28.3; SL4's 1.1 m lens before). ONE FIRE wall on a crescent as
wide as the box, its middle on the box's front and its ends bowed back 0.7 m (inside the box), 2.6 m tall x %YA-UP in the middle, its top
cut into 6 tongues flowing (§15.7; re-drawn every drawing before) (seen edge-on, 5 camera-facing tongues give it body); an EMBER backing wall 20 % taller behind
it (away from the eye); a FIRE lens riding it at 1.2 m; an EMBER scorch on the floor behind; T光 along the base; flame scraps flung ahead.
Envelope (1 3 hold 18) over its life: a white flash on its first drawing, it grows, holds, erodes. Passing the lens (the behind camera)
it sinks to 0.4 of its height. T1 / T2 (and 爆炎): a white (HIT) wall inside, %YA-CORE of the height. A look; 0 B (scraps by RDT)."
  (declare (single-float rdt))
  (let* ((yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz)) (size (hazard-size hz)) (x0 (hazard-x hz)) (z0 (hazard-z hz))
         (width (* 2f0 size)) (ti (ya-hz-tier hz)) (up (%ya-up ti)) (cw (%ya-core ti))   ; (the reads bound typed first: 0 B)
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (sx (- fz)) (sz fx)
         (x (+ x0 (* +ya-wave-half+ fx))) (z (+ z0 (* +ya-wave-half+ fz)))   ; (the box's front)
         (dr (drawing-no)) (fp (flow-ph)) (a (sage (/ (i->f age) 60f0) 2f0))   ; (DR: the flash drawing; FP: the flowing fire, §15.7)
         (hold (f-max 0f0 (- (i->f life) 22f0))) (e (camera-eye *camera*))
         (vx (- x (aref e 0))) (vz (- z (aref e 2))) (vl (f-max 0.01f0 (f-hypot vx vz)))
         (ox (* 0.35f0 (/ vx vl))) (oz (* 0.35f0 (/ vz vl))) (sd 0f0))
    (declare (type f32vec e) (fixnum age life ti)
             (single-float yaw size x0 z0 width up cw fx fz sx sz x z dr fp a hold vx vz vl ox oz sd))
    (fx-envelope (es k fl ph) (a 1 3 hold 18)
      (let* ((hw (* 0.5f0 width es))                   ; the eye's nearest point of the wall: passing the lens it sinks to 0.4
             (al (f-clamp (+ (* sx vx) (* sz vz)) (- hw) hw))
             (hgt (* 2.6f0 up es (+ 0.4f0 (* 0.6f0 (%near-cam (- x (* sx al)) (- z (* sz al)) 1.0f0 3.5f0))))))
        (declare (single-float hw al hgt))
        (when (= ph 1)                                 ; the flash drawing: a jagged white burst
          (fx-star x 1.2f0 z 0.48f0 0.69f0 12 (* 6.2831855f0 (hash01 0.3f0 dr)) 0f0 0f0 0.1f0 dr +pal-hit+ 0.98f0 :push 0.45f0))
        (%ya-wave-line x z sx sz fx fz hw ox oz)       ; the backing, then the mass, then the tier's core in front
        (fx-wall *wave-xs* *wave-zs* 9 (* 1.2f0 hgt) 6 0.25f0 (+ 20f0 sd) +pal-ember+ k)
        (%ya-wave-line x z sx sz fx fz hw 0f0 0f0)
        (fx-wall *wave-xs* *wave-zs* 9 hgt 6 0.2f0 (+ 3f0 sd) +pal-fire+ k)
        (when (> ti 0)
          (%ya-wave-line x z sx sz fx fz (* 0.85f0 hw) (* -0.3f0 ox) (* -0.3f0 oz))
          (fx-wall *wave-xs* *wave-zs* 9 (* cw hgt) 6 0.2f0 (+ 5f0 sd) +pal-hit+ k)
          (%ya-wave-line x z sx sz fx fz hw 0f0 0f0))
        (let* ((edge (f-abs (/ (+ (* sx vx) (* sz vz)) vl))) (tw (* 0.5f0 es (f-clamp (/ (- edge 0.35f0) 0.5f0) 0f0 1f0))))
          (declare (single-float edge tw))
          (when (> tw 0f0)                             ; seen along the wall (edge-on): camera-facing tongues give it body
            (dotimes (j 5)
              (let* ((i (+ 1 (floor (* 6 j) 4))) (f (i->f j)) (tsd (- -60f0 f sd))
                     (th (* hgt (+ 0.55f0 (* 0.35f0 (flow01 f 4.3f0))))) (tl (* 0.3f0 (- (flow01 f 6.7f0) 0.5f0))))
                (declare (fixnum i) (single-float f tsd th tl))
                (toon-ribbon ((aref *wave-xs* i) 0.02f0 (aref *wave-zs* i)) ((* tl fx) th (* tl fz)) (tw 0f0) :seed tsd :wob 0.25f0
                             :pal +pal-fire+ :k k :ph (+ fp f) :sway 0.08f0)))))
        (fx-crescent (aref *wave-xs* 0) 1.2f0 (aref *wave-zs* 0) (aref *wave-xs* 8) 1.2f0 (aref *wave-zs* 8)
                     (+ x (* 0.7f0 fx)) 1.2f0 (+ z (* 0.7f0 fz)) (* 0.16f0 es) :lens 0.05f0 9f0 +pal-fire+ k :push 0.5f0)
        (toon-ground-seg x z (- x (* 1.4f0 fx)) (- z (* 1.4f0 fz)) 0.03f0 (* 0.3f0 hw) 1f0 0.2f0 (+ 40f0 sd) 0.3f0
                         (toon-a +pal-ember+ (* 0.9f0 k)))
        (fx-ribbon x 0.05f0 z (* sx hw) 0f0 (* sz hw) 0.02f0 0.02f0 1f0 0.7f0 0.3f0 (* -0.4f0 k) 1f0 0.7f0 0.3f0 (* -0.4f0 k)
                   0f0 0f0 :segs 1)                    ; T光 along the base (a thin additive line)
        (fx-ribbon x 0.05f0 z (* (- sx) hw) 0f0 (* (- sz) hw) 0.02f0 0.02f0 1f0 0.7f0 0.3f0 (* -0.4f0 k) 1f0 0.7f0 0.3f0
                   (* -0.4f0 k) 0f0 0f0 :segs 1)
        (when (> k 0.3f0)
          (dotimes (i (n-of 14f0 rdt))                 ; scraps: flames flung ahead off the crests
            (let* ((u (rnd-range -0.9f0 0.9f0)) (b (* 0.7f0 u u)) (sp (rnd-range 3f0 6f0)))
              (declare (single-float u b sp))
              (%t-blob (+ x (* sx u hw) (- (* b fx))) (* hgt (rnd-range 0.5f0 0.9f0)) (+ z (* sz u hw) (- (* b fz)))
                       (* sp fx) (rnd-range 0.5f0 1.5f0) (* sp fz) (rnd-range 0.25f0 0.4f0) (rnd-range 0.08f0 0.15f0)
                       -1f0 0.3f0 +pal-fire+))))
        (%light x 1.2f0 z 1f0 0.45f0 0.12f0 6f0 2.5f0 7)))
    nil))

;;; ---------------------------------------------------------------- SL2 NS1b's ghost lights and column (:ya-col, r 1.2)
(defun-fast yama-column-look (hz rdt)
  "NS1b's 'unknown fire' (SL2: the :ya-col disc of HAZARD-SIZE at his bearing, :delay 13, hot 6, life 30). Through the delay the tell: an
EMBER ring on the disc's edge pulsing (6 Hz, smooth since §15.7) and five small flames (不知火, ghost lights) hovering 0.3-0.8 m over it, circling in. On the
eruption (age 0, the hit frame: full at once) one FIRE column as wide as the disc at its foot, tapering, a crown of tongues, *YA-FIRE-H* x
the tier's share high (2.4 m at T2: the hit's height), EMBER behind it, the tier's white core; it holds through the hot frames and erodes
from 12 to 30. The ring on the edge stays (the footprint). A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (d (hazard-delay hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (cw (%ya-core ti)) (dr (flow-ph)) (seed (+ x (* 3f0 z)))   ; (DR: a flowing phase, §15.7)
         (q (%near-cam x z 2f0 8f0)) (ws (f-max 0.15f0 (%near-cam x z 0f0 9f0)))
         (k (if (> d 0) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- life age)) 18f0)) 0f0 0.98f0))))
    (declare (single-float x z r dr seed hf cw q ws k) (fixnum d age life ti))
    (if (> d 0)
        (let ((p (- 1f0 (/ (i->f d) +ya-col-delay+))) (pulse (+ 0.75f0 (* 0.2f0 (f-cos (flow-ph 37.699112f0))))))   ; (6 Hz as before, smooth)
          (declare (single-float p pulse))
          (%tring x 0f0 z r 0.05f0 +pal-ember+ pulse (+ seed 1f0))
          (dotimes (i 5)                               ; the ghost lights circling in
            (let* ((f (i->f i)) (an (+ (* 1.2566f0 f) (* 3f0 p))) (rr (* r (- 0.95f0 (* 0.6f0 p))))
                   (y (+ 0.3f0 (* 0.5f0 (hash01 f seed)) (* 0.06f0 (f-sin (+ dr f))))) (lx (+ x (* rr (f-cos an)))) (lz (+ z (* rr (f-sin an)))))
              (declare (single-float f an rr y lx lz))
              (%ya-tongue lx (- y 0.06f0) lz 0f0 (* 0.22f0 (+ 0.7f0 (* 0.3f0 pulse))) 0f0 0.06f0 0 (* 0.9f0 pulse) (+ 80f0 f seed) (+ dr f)
                          :back nil :segs 3))))
        (let* ((h (* +ya-fire-h+ hf (+ 0.4f0 (* 0.6f0 q))))  ; (near the lens a column shortens and thins: the behind camera keeps the fight)
               (sd (- -3f0 (f-abs seed))))
          (declare (single-float h sd))
          (%tring x 0f0 z r 0.06f0 +pal-ember+ k (+ seed 1f0))
          (when (= ti 2) (%tring x 0f0 z (* 0.5f0 r) (* 0.5f0 r) +pal-ember+ (* 0.45f0 k) (+ seed 2f0)))   ; T2: the scorch, its life (30 f)
          (let ((bx x) (by 0f0) (bz z))
            (declare (single-float bx by bz))
            (%away-from-eye (bx by bz) 0.15f0
              (toon-ribbon (bx by bz) (0f0 (* 1.08f0 h) 0f0) ((* 1.08f0 r ws) (* 0.3f0 r ws)) :heat (0.3f0 0.15f0) :seed (- sd 20f0)
                           :wob 0.25f0 :pal +pal-ember+ :k (%ya-k k) :ph dr :sway 0.05f0 :segs 6)))
          (toon-ribbon (x 0f0 z) (0f0 h 0f0) ((* r ws) (* 0.22f0 r ws)) :heat (0.3f0 0.15f0) :seed sd :wob 0.25f0 :pal +pal-fire+ :k (%ya-k k) :ph dr
                       :sway 0.04f0 :segs 6)
          (when (> ti 0)
            (let ((cx x) (cy 0f0) (cz z))
              (declare (single-float cx cy cz))
              (%away-from-eye (cx cy cz) -0.1f0
                (toon-ribbon (cx cy cz) (0f0 (* 0.85f0 h) 0f0) ((* cw 0.6f0 r ws) (* cw 0.15f0 r ws)) :heat (0.3f0 0.15f0) :seed (- sd 40f0)
                             :wob 0.2f0 :pal +pal-hit+ :k (%ya-k k) :ph dr :sway 0.04f0 :segs 5))))
          (dotimes (j 6)                               ; the crown
            (let* ((f (i->f j)) (an (+ (* 1.0472f0 f) (* 0.5f0 (flow01 f 5.1f0)))) (hc (* 0.35f0 h (+ 0.6f0 (* 0.4f0 (flow01 f 2.3f0))))))
              (declare (single-float f an hc))
              (when (<= (hash01 f 8.3f0) hf)
                (%ya-tongue (+ x (* 0.2f0 r ws (f-cos an))) (* 0.85f0 h) (+ z (* 0.2f0 r ws (f-sin an))) (* 0.5f0 hc (f-cos an)) hc
                            (* 0.5f0 hc (f-sin an)) (* 0.14f0 ws) ti k (+ 90f0 f seed) (+ dr f) :back nil))))
          (%light x 1.2f0 z 1f0 0.45f0 0.12f0 3.5f0 (* 0.7f0 k) 7)))
    nil))

;;; ---------------------------------------------------------------- SL3 NS1c's tornado (the :wave, 3.5 m, 10 m/s)
(defun-fast yama-tornado-look (hz rdt)
  "NS1c's tornado (SL3: the :wave 2 x HAZARD-SIZE = 3.5 m wide): four stacked, tilted bands of fire turning (smoothly since §15.7; on twos before), FIRE on the camera's
side and INK on the far one, gaps between them (the foe in view from behind); the lowest band is the box (an ellipse 2 x size across, 2 x
+YA-WAVE-HALF+ along), the upper ones narrow across, up to 3.2 m x the tier's share; an EMBER stripe climbing round them; on the floor the
box as an EMBER patch (the footprint: never the round funnel's). Near the lens the bands shorten. By tier: height, share, core; T2 the scorch
30 f back. 爆炎's tornado (its data's :track: it turns after the victim, art S4) leans its upper bands toward the victim's side of its
travel, up to 1.0 m at the top (its turn rate is not stored; the lowest band, the footprint, never leans). A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (e (camera-eye *camera*))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (flow-ph)) (seed (* 9f0 yaw))   ; (DR: a flowing phase, §15.7)
         (ex (- (aref e 0) x)) (ez (- (aref e 2) z)) (el (f-max 0.01f0 (f-hypot ex ez)))
         (q (%near-cam x z 1.5f0 6f0)) (hs (* hf (+ 0.45f0 (* 0.55f0 q))))
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0))
         (tg (and (plist-get (hazard-data hz) :track) (hazard-target hz))) (lean 0f0))   ; (the Shikai's: no :track, LEAN 0)
    (declare (single-float x z w yaw hf fx fz px pz dr seed ex ez el q hs k lean) (type f32vec e) (fixnum age life ti))
    (when tg                                           ; the victim's side of the travel: the lateral share of his bearing
      (let* ((tq (pos-of tg)) (bx (- (aref tq 0) x)) (bz (- (aref tq 2) z)) (bl (f-max 0.01f0 (f-hypot bx bz))))
        (declare (type f32vec tq) (single-float bx bz bl))
        (setf lean (/ (+ (* bx px) (* bz pz)) bl))))
    (%ya-floor-box x z fx fz w (* 0.55f0 k) (+ 24f0 seed))
    (when (= ti 2)
      (let ((sc (* (i->f (min age 30)) (/ +ya-tornado-speed+ 60f0))))
        (declare (single-float sc))
        (when (> sc +ya-wave-half+)
          (toon-ground-seg (- x (* +ya-wave-half+ fx)) (- z (* +ya-wave-half+ fz)) (- x (* sc fx)) (- z (* sc fz)) 0.011f0 (* 0.7f0 w) 0.8f0
                           0.1f0 (+ 25f0 seed) 0.3f0 (toon-a +pal-ember+ (* 0.5f0 k))))))
    (dotimes (b 4)
      (let* ((bf (i->f b)) (ra (* w (- 1f0 (* 0.22f0 bf)))) (rl (if (= b 0) +ya-wave-half+ (f-min ra (+ 0.5f0 (* 0.2f0 bf)))))
             (yb (* hs (+ 0.18f0 (* 0.85f0 bf)))) (tk (* 0.17f0 hs)) (spin (+ (flow-ph 6.6f0) (* 0.9f0 bf))) (tilt (* 0.18f0 hs))
             (lb (* lean (/ bf 3f0))) (x (+ x (* lb px))) (z (+ z (* lb pz))))   ; (this band's centre, leaned: band 0 never)
        (declare (single-float bf ra rl yb tk spin tilt lb x z))
        (dotimes (i 12)
          (let* ((a0 (+ spin (* 0.5236f0 (i->f i)))) (a1 (+ a0 0.5236f0))
                 (ca0 (f-cos a0)) (sa0 (f-sin a0)) (ca1 (f-cos a1)) (sa1 (f-sin a1))
                 (ox0 (+ (* ra ca0 px) (* rl sa0 fx))) (oz0 (+ (* ra ca0 pz) (* rl sa0 fz)))
                 (ox1 (+ (* ra ca1 px) (* rl sa1 fx))) (oz1 (+ (* ra ca1 pz) (* rl sa1 fz)))
                 (far (< (/ (+ (* ex (+ ox0 ox1)) (* ez (+ oz0 oz1))) el) 0f0)))
            (declare (single-float a0 a1 ca0 sa0 ca1 sa1 ox0 oz0 ox1 oz1))
            (when (<= (hash01 (+ (i->f i) (* 17f0 bf)) 2.9f0) hf)
              (if far
                  (%ya-seg (+ x ox0) (+ yb (* tilt sa0)) (+ z oz0) (+ x ox1) (+ yb (* tilt sa1)) (+ z oz1) tk tk 0 k
                           (+ seed (* 12f0 bf) (i->f i)) (+ dr (i->f i)) :pal +pal-ink+)
                  (%ya-seg (+ x ox0) (+ yb (* tilt sa0)) (+ z oz0) (+ x ox1) (+ yb (* tilt sa1)) (+ z oz1) tk tk ti k
                           (+ seed (* 12f0 bf) (i->f i)) (+ dr (i->f i)))))))
        (when (< b 3)                                  ; the EMBER stripe climbing to the next band
          (let* ((a (+ spin 0.8f0)) (ra2 (* w (- 0.78f0 (* 0.22f0 bf)))) (x0 (+ x (* ra (f-cos a) px))) (z0 (+ z (* ra (f-cos a) pz)))
                 (x1 (+ x (* ra2 (f-cos (+ a 0.9f0)) px))) (z1 (+ z (* ra2 (f-cos (+ a 0.9f0)) pz))))
            (declare (single-float a ra2 x0 z0 x1 z1))
            (%ya-seg x0 yb z0 x1 (+ yb (* 0.85f0 hs)) z1 (* 0.4f0 tk) (* 0.3f0 tk) 0 (* 0.9f0 k) (+ seed 70f0 bf) dr :pal +pal-ember+)))))
    (%light x 1.5f0 z 1f0 0.45f0 0.12f0 4f0 (* 0.8f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- SL5 the burning ring (:ya-ring, r 1.6, band ±0.25, 90 f, 2 hits)
(defmacro %ya-pillar (x z age life height w0 tier dt)
  "One pillar of fire at ground (X Z): batch 1's VFX-FIRE-PILLAR (05acf777, the old Ennetsu Jigoku pillar) re-ported by batch J1 (§28.3).
A FIRE column HEIGHT m over an EMBER backing 8 % taller, an EMBER stripe twisting up its front, a crown of 6 tongues flaring out of its top,
an EMBER scorch ring at its foot (inside W0), flame scraps off the crown (by DT: none at 0). It rises on ones in 3 drawings, the first
already up at AGE 0 (s; the hit frame shows it, §22.2), and erodes from the tip over the last 0.25 s of LIFE (s). W0 the base half-width
(the old 0.32; the caller keeps it inside its footprint). TIER 1 / 2: a white (HIT) core up its lower part (heat's own, §21.2). Near the
lens it shortens and thins. Single-float forms (TIER fixnum); 0 B."
  `(let* ((%x ,x) (%z ,z) (%age ,age) (%life ,life) (%hgt ,height) (%w0 ,w0) (%ti ,tier) (%dt ,dt)
          (%a1 (sage %age 1f0)) (%rise (f-clamp (/ (i->f (1+ (f->i (* 24f0 %a1)))) 3f0) 0f0 1f0)) (%dr (flow-ph))   ; (%DR: a flowing phase, §15.7)
          (%k (* 0.98f0 (f-clamp (/ (- %life %age) 0.25f0) 0f0 1f0))) (%q (%near-cam %x %z 2f0 8f0))
          (%ws (* (/ %w0 0.32f0) (f-max 0.1f0 (%near-cam %x %z 0f0 9f0))))
          (%h (* %hgt %rise (+ 0.4f0 (* 0.6f0 %q)) (+ 0.9f0 (* 0.1f0 (flow01 0f0 (* 0.37f0 %x))))))
          (%sd (+ (f-abs (* 3.1f0 %z)) (f-abs (* 1.3f0 %x)))))
     (declare (single-float %x %z %age %life %hgt %w0 %dt %a1 %rise %dr %k %q %ws %h %sd) (fixnum %ti))
     (when (> %k 0.02f0)
       (%tring %x 0f0 %z (- %w0 0.08f0) 0.08f0 +pal-ember+ (* 0.9f0 %k) %sd 16)
       (let ((%bx %x) (%by 0f0) (%bz %z))
         (declare (single-float %bx %by %bz))
         (%away-from-eye (%bx %by %bz) 0.12f0           ; the dark-red backing, 8 % taller and wider
           (toon-ribbon (%bx %by %bz) (0f0 (* 1.08f0 %h) 0f0) ((* 0.4f0 %ws) (* 0.26f0 %ws)) :heat (1f0 0.35f0) :seed (- -20f0 %sd)
                        :pal +pal-ember+ :k %k :ph %dr :sway 0.05f0 :segs 7)))
       (toon-ribbon (%x 0f0 %z) (0f0 %h 0f0) ((* 0.32f0 %ws) (* 0.2f0 %ws)) :heat (1f0 0.35f0) :seed (- -3f0 %sd) :wob 0.25f0
                    :pal +pal-fire+ :k %k :ph %dr :sway 0.04f0 :segs 7)
       (let ((%sx %x) (%sy 0.1f0) (%sz %z))             ; the spiral stripe, in front of the column
         (declare (single-float %sx %sy %sz))
         (%away-from-eye (%sx %sy %sz) -0.1f0
           (toon-ribbon (%sx %sy %sz) (0f0 (* 0.95f0 %h) 0f0) ((* 0.07f0 %ws) (* 0.045f0 %ws)) :heat (1f0 0.4f0) :seed (- -9f0 %sd)
                        :wob 0.1f0 :pal +pal-ember+ :k %k :ph (* 2f0 %dr) :sway 0.25f0 :segs 8)))
       (when (> %ti 0)                                  ; the tier's white core, in front
         (let ((%cw (if (= %ti 1) 0.3f0 0.6f0)) (%cx %x) (%cy 0f0) (%cz %z))
           (declare (single-float %cw %cx %cy %cz))
           (%away-from-eye (%cx %cy %cz) -0.14f0
             (toon-ribbon (%cx %cy %cz) (0f0 (* 0.7f0 %h) 0f0) ((* %cw 0.32f0 %ws) (* %cw 0.15f0 %ws)) :heat (1f0 0.35f0)
                          :seed (- -30f0 %sd) :wob 0.2f0 :pal +pal-hit+ :k %k :ph %dr :sway 0.04f0 :segs 5))))
       (when (and (>= %rise 1f0) (> %q 0.5f0))          ; the crown: 6 tongues flaring out of the top
         (dotimes (%j 6)
           (let* ((%f (i->f %j)) (%an (+ (* 1.0472f0 %f) (* 0.5f0 (flow01 %f 5.1f0))))
                  (%hc (* 0.18f0 %hgt (+ 0.7f0 (* 0.5f0 (flow01 %f 2.3f0))))))
             (declare (single-float %f %an %hc))
             (%tongue (+ %x (* 0.16f0 (f-cos %an))) (* 0.94f0 %h) (+ %z (* 0.16f0 (f-sin %an))) (* 0.6f0 %hc (f-cos %an)) %hc
                      (* 0.6f0 %hc (f-sin %an)) 0.11f0 +pal-fire+ %k (+ 60f0 %f %sd) (+ %dr %f) 0.03f0 :segs 4))))
       (dotimes (%i (n-of (* 10f0 %rise %q) %dt))
         (%t-blob (+ %x (rnd-range -0.3f0 0.3f0)) (* %h (rnd-range 0.85f0 1f0)) (+ %z (rnd-range -0.3f0 0.3f0)) (rnd-range -0.8f0 0.8f0)
                  (rnd-range 1.5f0 3f0) (rnd-range -0.8f0 0.8f0) (rnd-range 0.3f0 0.5f0) (rnd-range 0.08f0 0.15f0) -1f0 0.3f0 +pal-fire+)))))

(defun-fast yama-ring-look (hz rdt)
  "城郭炎上's burning ring (:ya-ring, radius HAZARD-SIZE, band ±+YA-RING-BAND+; NS2b, AS2a's snap): batch 1's six low pillars back
(05acf777, re-ported by batch J1, the user 2026-11-20: 「NS 跟 AS 的 城郭炎上 反而是重作前的版本更有魄力」, §28.3; SL5's tongue wall
before): an EMBER ring on the floor exactly the band (the footprint: the fire burns between the pillars too) and six %YA-PILLAR columns on
the circle, 1.4 m x %YA-UP high, their bases inside the band, rising in 3 drawings from the first frame. It shows its charge
(HAZARD-HITS-LEFT): 2 full, 1 lower (x0.7) and thinner, 0 only the embers (a spent ring cannot burn). Its last 15 f gutter. A look; 0 B
(scraps by RDT)."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz)) (hl (hazard-hits-left hz))
         (ti (ya-hz-tier hz)) (up (%ya-up ti)) (seed (+ x (* 5f0 z)))
         (g (f-clamp (/ (i->f (- life age)) 15f0) 0f0 1f0)) (k (* 0.98f0 (f-min 1f0 (* 2f0 g))))
         (as (/ (i->f age) 60f0)) (ls (/ (i->f life) 60f0))
         (ch (case hl (0 0f0) (1 0.7f0) (t 1f0))) (h (* 1.4f0 up ch)) (w0 (* +ya-ring-band+ (if (= hl 1) 0.8f0 1f0))))
    (declare (single-float x z r up seed g k as ls ch h w0) (fixnum age life hl ti))
    (%tring x 0f0 z r +ya-ring-band+ +pal-ember+ (* (if (= hl 0) 0.6f0 0.75f0) k) (+ seed 1f0))
    (when (> ch 0f0)
      (dotimes (i 6)
        (let ((an (* 1.0472f0 (i->f i))))
          (declare (single-float an))
          (%ya-pillar (+ x (* r (f-cos an))) (+ z (* r (f-sin an))) as ls h w0 ti rdt))))
    (%light x 0.8f0 z 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k ch) 6)
    nil))

;;; ---------------------------------------------------------------- SL6 the dome (:ya-dome, r 1.6, hot 4, life 40): batch 1's Jokaku Enjo
(defun-fast yama-dome-look (hz rdt)
  "The dome (:ya-dome, radius HAZARD-SIZE; NS2c, AS2b, 爆炎's NS2b): batch 1's Jokaku Enjo back (05acf777 VFX-FIRE-DOME from its seethe on,
re-ported by batch J1, the user 2026-11-20: 「NS 跟 AS 的 城郭炎上 反而是重作前的版本更有魄力」, §28.3; SL6's 12 leaning tongues before),
a function of the hazard's age (no *DOME-LAST*, no stamp). Ages 0-2 (the hit frame and the hot ones): three tiers of FIRE tongues (12 + 9
+ 6, the outer over EMBER backings) leaning in, closed, boiling (flowing since §15.7; on twos before), 1.15 r x %YA-UP high; from age 3 the detonation: a white flash,
a 14-spike FIRE star over an EMBER one with a white core for 2 drawings (batch 1's :boom), a FIRE shockwave ring running out (its :ring),
flame / smoke / ember scraps over ages 3-5 (by RDT), a 16 m light fading in 9 f. An EMBER ring inside the disc's edge (the footprint);
T1 / T2 (and 爆炎) a white core in each tongue; T2 an EMBER scorch disc to the end. A look; 0 B."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (up (%ya-up ti)) (cw (%ya-core ti)) (big-h (* 1.15f0 r up))
         (drawing (drawing-no)) (fp (flow-ph)) (sd 0f0) (seed (+ (* 3f0 x) z))   ; (the tongues flow, §15.7; the :boom's stars keep DRAWING)
         (kl (f-clamp (* 0.98f0 (/ (i->f (- life age)) 14f0)) 0f0 0.98f0)))
    (declare (single-float x z r up cw big-h drawing fp sd seed kl) (fixnum age life ti))
    (when (= ti 2) (%tring x 0f0 z (* 0.5f0 r) (* 0.5f0 r) +pal-ember+ (* 0.45f0 kl) (+ seed 2f0)))
    (if (< age 3)
        (let* ((ua (+ 0.8f0 (sage (/ (i->f age) 60f0) 1f0))) (seethe (f-clamp (/ (- ua 0.7f0) 0.15f0) 0f0 1f0)))
          (declare (single-float ua seethe))
          (%tring x 0f0 z (- r 0.07f0) 0.07f0 +pal-ember+ 0.9f0 sd)
          (dotimes (tier 3)
            (let* ((tf (i->f tier)) (n (- 12 (* 3 tier))) (nf (i->f n))
                   (rad (* r (- 1f0 (* 0.27f0 tf)))) (y0 (* big-h 0.3f0 tf)) (lean (+ 0.45f0 (* 0.25f0 tf)))
                   (spin (* 0.7f0 tf)) (w (* 0.3f0 (/ (* 6.2832f0 rad) nf))))
              (declare (fixnum n) (single-float tf nf rad y0 lean spin w))
              (dotimes (i n)
                (let* ((f (i->f i)) (an (+ spin (/ (* 6.2832f0 f) nf))) (ca (f-cos an)) (sa (f-sin an))
                       (bx (+ x (* rad ca))) (bz (+ z (* rad sa)))
                       (hh (* big-h (- 0.95f0 (* 0.25f0 tf)) 0.7f0
                              (+ (- 0.8f0 (* 0.15f0 seethe)) (* (+ 0.4f0 (* 0.5f0 seethe)) (flow01 f (+ 3.7f0 tf))))))
                       (ax (* (- lean) rad ca)) (az (* (- lean) rad sa)) (tsd (+ (* 13f0 tf) f sd)))
                  (declare (single-float f an ca sa bx bz hh ax az tsd))
                  (when (= tier 0)
                    (let ((kx bx) (ky y0) (kz bz))
                      (declare (single-float kx ky kz))
                      (%away-from-eye (kx ky kz) 0.1f0
                        (%tongue kx ky kz (* 1.1f0 ax) (* 1.15f0 hh) (* 1.1f0 az) (* 1.2f0 w) +pal-ember+ 0.95f0 (+ 100f0 tsd) (+ fp f) 0.05f0))))
                  (%tongue bx y0 bz ax hh az w +pal-fire+ 0.95f0 tsd (+ fp f) 0.05f0)
                  (when (> ti 0)                       ; the tier's white core, the lower half of each tongue, in front
                    (let ((cx bx) (cy y0) (cz bz))
                      (declare (single-float cx cy cz))
                      (%away-from-eye (cx cy cz) -0.05f0
                        (%tongue cx cy cz (* 0.5f0 ax) (* 0.5f0 hh) (* 0.5f0 az) (* cw w) +pal-hit+ 0.95f0 (+ 200f0 tsd) (+ fp f) 0.05f0))))))))
          (dotimes (i (n-of 40f0 rdt))
            (let* ((an (rnd-range 0f0 6.2832f0)) (rr (* r (rnd-range 0.3f0 1f0))))
              (declare (single-float an rr))
              (%t-blob (+ x (* rr (f-cos an))) (* big-h (rnd-range 0.3f0 0.9f0)) (+ z (* rr (f-sin an))) (rnd-range -0.4f0 0.4f0)
                       (rnd-range 1.2f0 2.4f0) (rnd-range -0.4f0 0.4f0) (rnd-range 0.3f0 0.45f0) (rnd-range 0.1f0 0.18f0) -1f0 0.3f0 +pal-fire+)))
          (%light x 1.5f0 z 1f0 0.35f0 0.08f0 10f0 1.8f0 8))
        (let* ((b (/ (i->f (- age 3)) 60f0)) (a (sage b 2f0)) (ar (sage b 2f0)) (sc r) (rs (* 1.2f0 r)) (v (f-clamp (/ b 0.15f0) 0f0 1f0)))
          (declare (single-float b a ar sc rs v))
          (fx-envelope (es k fl ph) (a 1 3 6 24)       ; batch 1's :boom
            (cond ((= ph 1) (%flash x 1.3f0 z (* 0.6f0 sc) seed))
                  ((< ph 5)
                   (%star x 1.3f0 z (* 0.5f0 sc) (* 1.55f0 sc es) 14 0f0 0f0 0.12f0 (+ seed 3f0) +pal-ember+ k 0.2f0)
                   (%star x 1.3f0 z (* 0.45f0 sc) (* 1.3f0 sc es up) 14 0f0 0f0 0.12f0 seed +pal-fire+ k 0.3f0)
                   (when (< ph 4) (%star x 1.3f0 z (* 0.15f0 sc) (* 0.4f0 sc es) 9 0f0 0f0 0.08f0 (+ seed 5f0) +pal-hit+ k 0.4f0)))))
          (fx-envelope (es k fl ph) (ar 0 2 3 14)      ; batch 1's :ring stamp in FIRE: the shockwave running out
            (when (< ph 5)
              (%tring x 0f0 z (* rs (+ 0.4f0 (* 7f0 ar))) (* rs 0.12f0) +pal-fire+ k seed)
              (%tring x 0f0 z (* rs (+ 0.3f0 (* 4.5f0 ar))) 0.04f0 +pal-fire+ k (+ seed 1f0))))
          (when (< age 6)                              ; the scraps over ages 3-5 (batch 1's 26 + 10 + 16 at once)
            (dotimes (i (n-of 520f0 rdt))
              (let* ((an (rnd-range 0f0 6.2832f0)) (sp (rnd-range 3f0 7f0)))
                (declare (single-float an sp))
                (%t-blob x (rnd-range 0.6f0 2f0) z (* sp (f-cos an)) (rnd-range 1f0 4f0) (* sp (f-sin an)) (rnd-range 0.4f0 0.7f0)
                         (rnd-range 0.25f0 0.45f0) -1f0 0.3f0 +pal-fire+)))
            (dotimes (i (n-of 200f0 rdt))
              (let* ((an (rnd-range 0f0 6.2832f0)) (sp (rnd-range 1f0 2.5f0)))
                (declare (single-float an sp))
                (%t-blob (+ x (* r 0.5f0 (f-cos an))) (rnd-range 0.5f0 2f0) (+ z (* r 0.5f0 (f-sin an))) (* sp (f-cos an)) (rnd-range 0.8f0 1.8f0)
                         (* sp (f-sin an)) (rnd-range 0.9f0 1.4f0) (rnd-range 0.4f0 0.7f0) -0.3f0 0.3f0 +pal-black-smoke+)))
            (dotimes (i (n-of 320f0 rdt))
              (let* ((an (rnd-range 0f0 6.2832f0)) (sp (rnd-range 5f0 10f0)))
                (declare (single-float an sp))
                (%t-shard x 1.3f0 z (* sp (f-cos an)) (rnd-range 1f0 5f0) (* sp (f-sin an)) (rnd-range 0.5f0 0.8f0) (rnd-range 0.12f0 0.22f0)
                          6f0 +pal-ember+))))
          (when (< v 1f0) (%light x 1.5f0 z 1f0 0.5f0 0.2f0 16f0 (* 3.5f0 (- 1f0 v)) 9))))
    nil))

;;; ---------------------------------------------------------------- the moves' own looks (YAMA-DRAW): SL0 the blade, SL7-SL9
(defun-fast yama-blade-fire (tip base mode ti rdt)
  "SL0, Ryujin Jakka engulfed (canon: the blade lit from the tip down; %BLADE-FIRE's drawing, revived): a FIRE sheath along the blade BASE ..
TIP, three tongues licking up (flowing since §15.7; on twos before), a thin warm line in it, the tier's white core; flame scraps only inside a move (MODE 1: none at rest,
so the cosmetic stream stays as it was there). Power: 0.5 at rest (MODE 0), 1.0 in a move's startup to S + A (MODE 1), the tier's share in
an NS (MODE 2), x 1.3 in 爆炎 (MODE + 10, always cored). A look; 0 B."
  (declare (type f32vec tip base) (fixnum mode ti) (single-float rdt))
  (let* ((blaze (>= mode 10)) (m (mod mode 10)) (tier (if blaze 2 ti))
         (p (* (if blaze 1.3f0 1f0) (case m (0 0.5f0) (1 1f0) (t (%ya-hf tier)))))
         (x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (bx (- (aref tip 0) x0)) (by (- (aref tip 1) y0)) (bz (- (aref tip 2) z0))
         (fp (flow-ph)) (sd -3f0) (cw (if (= m 0) (if blaze 0.4f0 0f0) (%ya-core tier))))   ; (flowing, one seed: §15.7)
    (declare (single-float p x0 y0 z0 bx by bz fp sd cw) (fixnum m tier))
    (toon-ribbon (x0 y0 z0) (bx by bz) ((* 0.075f0 p) (* 0.045f0 p)) :heat (0.3f0 0.15f0) :seed sd :wob 0.2f0 :pal +pal-fire+ :k 0.95f0 :ph fp
                 :sway 0.01f0 :segs 4)
    (when (> cw 0f0)
      (let ((cx x0) (cy y0) (cz z0))
        (declare (single-float cx cy cz))
        (%away-from-eye (cx cy cz) -0.02f0
          (toon-ribbon (cx cy cz) ((* 0.9f0 bx) (* 0.9f0 by) (* 0.9f0 bz)) ((* cw 0.06f0 p) (* cw 0.03f0 p)) :heat (0.3f0 0.15f0)
                       :seed (- sd 30f0) :wob 0.15f0 :pal +pal-hit+ :k 0.95f0 :ph fp :segs 3))))
    (dotimes (j 3)
      (let* ((f (i->f j)) (u (+ 0.25f0 (* 0.27f0 f))) (h (* p (+ 0.26f0 (* 0.26f0 (flow01 f 3.1f0)))))
             (lx (* 0.14f0 (- (flow01 f 5.3f0) 0.5f0))) (lz (* 0.14f0 (- (flow01 f 7.9f0) 0.5f0)))
             (tx (+ x0 (* u bx))) (ty (+ y0 (* u by))) (tz (+ z0 (* u bz))))
        (declare (single-float f u h lx lz tx ty tz))
        (%away-from-eye (tx ty tz) 0.04f0
          (toon-ribbon (tx ty tz) (lx h lz) ((* 0.09f0 p) 0f0) :heat (0.3f0 0.12f0) :seed (- sd (* 7f0 (+ f 1f0))) :wob 0.25f0 :pal +pal-fire+
                       :k 0.95f0 :ph (+ fp f) :sway 0.03f0 :segs 5))))
    (fx-ribbon x0 y0 z0 bx by bz 0.01f0 0.006f0 1f0 0.55f0 0.25f0 -0.25f0 1f0 0.5f0 0.2f0 -0.15f0 0f0 0f0 :segs 1)   ; the warm line (no white centre)
    (when (> m 0)
      (dotimes (i (n-of (* 10f0 p) rdt))               ; scraps peeling off the swing (inside a move only)
        (let* ((u (rnd-range 0.2f0 1f0)))
          (declare (single-float u))
          (%t-blob (+ x0 (* u bx)) (+ y0 (* u by) 0.05f0) (+ z0 (* u bz)) (rnd-range -0.4f0 0.4f0) (rnd-range 0.8f0 1.6f0)
                   (rnd-range -0.4f0 0.4f0) (rnd-range 0.3f0 0.5f0) (* p (rnd-range 0.035f0 0.06f0)) -2f0 0.3f0 +pal-fire+)))))
  nil)

(defun-fast %ya-pommel-fire (v)
  "SL9's burning pommel (J3 TSUKABI, the user's 「右手刀柄回擊」): a fist-sized flame on the handle's end V, two tongues. A look; 0 B."
  (declare (type f32vec v))
  (let* ((x (aref v 0)) (y (aref v 1)) (z (aref v 2)) (fp (flow-ph)))   ; (flowing: §15.7)
    (declare (single-float x y z fp))
    (dotimes (j 2)
      (let ((f (i->f j)))
        (declare (single-float f))
        (%ya-tongue x (- y 0.04f0) z (* 0.06f0 (- (flow01 f 2.7f0) 0.5f0)) (+ 0.16f0 (* 0.08f0 (flow01 f 1.9f0))) 0f0 0.06f0 0 0.95f0
                    (+ 140f0 f) (+ fp f) :segs 3))))
  nil)

;;; the pointer stances' fire on the blade (art S3, DUEL_YAMA_CORE §21.3 / §24; out of a move, over SL0's rest sheath; 撫斬's stance has none)
(defun-fast yama-stance-fire (tip base code ti)
  "The Shikai's stance looks on the blade BASE .. TIP, at the tier TI of the heat his next segment would pay (YA-STANCE-TIER): CODE 1 不知火,
a slow corkscrew of fire, two strands wound 1.5 turns round the blade, turning once in 4 s; CODE 2 城郭炎上, a drip of fire off the point: a
flame hanging 0.26 m from the tip and three drops falling from it 0.8 m in turn, one every 0.4 s, thinning as they fall. By tier: the size
and the white core (%YA-SEG). CODE 3 撫斬 (batch J3, DUEL_YAMA_CORE §28.5; TI ignored): still no fire, a thin EMBER line down the blade
and a small EMBER ring where the point meets the plaza, breathing (continuously, §15.7), so the blade reads from the behind camera. Pure of the fx clock (no random stream). A look; 0 B."
  (declare (type f32vec tip base) (fixnum code ti))
  (let* ((x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (tx (aref tip 0)) (ty (aref tip 1)) (tz (aref tip 2))
         (bx (- tx x0)) (by (- ty y0)) (bz (- tz z0)) (c (fx-clock)) (dr (flow-ph)) (hf (%ya-hf ti)))   ; (DR: a flowing phase, §15.7)
    (declare (single-float x0 y0 z0 tx ty tz bx by bz c dr hf))
    (case code
      (1 (let* ((bl (f-max 0.01f0 (f-sqrt (+ (* bx bx) (* by by) (* bz bz)))))   ; a frame round the blade: N1 = B x up, N2 = N1 x B
                (ax (/ bx bl)) (ay (/ by bl)) (az (/ bz bl))
                (n1x (- az)) (n1z ax) (nl (f-max 0.01f0 (f-sqrt (+ (* n1x n1x) (* n1z n1z))))) (n1x (/ n1x nl)) (n1z (/ n1z nl))
                (n2x (* n1z ay)) (n2y (- (* n1x az) (* n1z ax))) (n2z (- (* n1x ay)))
                (r (* 0.075f0 hf)) (spin (* 1.5708f0 c)))
           (declare (single-float bl ax ay az n1x n1z nl n2x n2y n2z r spin))
           (dotimes (s 2)
             (dotimes (i 8)
               (let* ((u0 (* 0.125f0 (i->f i))) (u1 (+ u0 0.125f0)) (ph (* 3.1416f0 (i->f s)))
                      (a0 (+ spin ph (* 9.42f0 u0))) (a1 (+ spin ph (* 9.42f0 u1)))
                      (r0 (* r (+ 0.6f0 (* 0.4f0 u0)))) (r1 (* r (+ 0.6f0 (* 0.4f0 u1))))
                      (c0 (* r0 (f-cos a0))) (s0 (* r0 (f-sin a0))) (c1 (* r1 (f-cos a1))) (s1 (* r1 (f-sin a1))))
                 (declare (single-float u0 u1 ph a0 a1 r0 r1 c0 s0 c1 s1))
                 (%ya-seg (+ x0 (* u0 bx) (* c0 n1x) (* s0 n2x)) (+ y0 (* u0 by) (* s0 n2y)) (+ z0 (* u0 bz) (* c0 n1z) (* s0 n2z))
                          (+ x0 (* u1 bx) (* c1 n1x) (* s1 n2x)) (+ y0 (* u1 by) (* s1 n2y)) (+ z0 (* u1 bz) (* c1 n1z) (* s1 n2z))
                          (* 0.022f0 hf) (* 0.016f0 hf) ti 0.95f0 (+ 200f0 (* 9f0 (i->f s)) (i->f i)) (+ dr (i->f i))))))))
      (2 (%ya-tongue tx (+ ty 0.03f0) tz 0f0 (* -0.26f0 hf) 0f0 (* 0.055f0 hf) ti 0.95f0 210f0 dr :segs 3)   ; the flame hanging off the point
         (dotimes (j 3)
           (let* ((p (+ (* 0.833f0 c) (* 0.3333f0 (i->f j)))) (ph (- p (i->f (f->i p))))   ; (each drop's phase, 1.2 s a fall)
                  (y (- ty 0.12f0 (* 0.8f0 ph ph))) (w (* 0.04f0 hf (- 1f0 (* 0.6f0 ph)))))
             (declare (single-float p ph y w))
             (%ya-seg tx (+ y (* 0.13f0 hf)) tz tx y tz w (* 0.5f0 w) ti (- 0.95f0 (* 0.5f0 ph)) (+ 220f0 (i->f j)) (+ dr (i->f j))))))
      (3 (let ((b (+ 0.8f0 (* 0.15f0 (f-sin (* 2.618f0 c))))))   ; 撫斬 (J3, §28.5): no fire, an EMBER line down the edge (the blade reads
           (declare (single-float b))                     ;  from behind), breathing (continuously since §15.7: on twos before)
           (let ((ex x0) (ey y0) (ez z0))
             (declare (single-float ex ey ez))
             (%away-from-eye (ex ey ez) -0.03f0
               (toon-ribbon (ex ey ez) (bx by bz) (0.016f0 0.01f0) :heat (0.3f0 0.2f0) :seed -230f0 :wob 0.1f0 :pal +pal-ember+ :k (%ya-k b)
                            :ph dr :segs 3)))
           (%tring tx 0f0 tz 0.07f0 0.025f0 +pal-ember+ (* 0.8f0 b) 231f0 8))))   ; (where the point meets the plaza)
    nil))

(defun ya-stance-tier (e blaze)
  "The tier his pointer stance's fire draws at (YAMA-STANCE-FIRE): the heat his next NS segment would pay, the gauge (GAUGES-METER) up to
25 (*YA-HEAT-NS*, host-checked; yama.lisp loads after this file); 2 in 爆炎 (BLAZE). Reads only."
  (ya-heat-tier (min (gauges-meter (gauges e)) 25f0) blaze))

(defun-fast yama-sk-moves (pos yaw code sf ti)
  "The Shikai's (and 爆炎's) moves' own looks at his feet POS facing YAW, frame SF of the move CODE (YAMA-SK-CODE), tier TI: 1 NADEGIRI (SL7,
S14): one INK hairline across the cut's arc (r 2.4, 100 deg) at neck height on S and S+1, nothing else; from S + 24 (f38) the seam of fire
along his facing from 0.6 m to the reach, two walls of flame parting left and right (a V), tallest at 2.4 m, by tier; aftermath, not a hit
(no spark), gone by f52 (the Shikai's last frame). 2 / 3 TAIMATSU's halo (SL8, S16 A8; 2.4 m / 爆炎's 3.2 m): tongues igniting round him over
f12-15 and reaching the edge by S (the hit's frame: full), standing to S + A, fading to f27; an EMBER ring on the reach's edge, INK behind
him. 5 AS1's burst (SL9, S10-12, fading to 14): SL1's corkscrew from 0.2 m out to its reach 1.6 m at the blade's height. 8 爆炎's true
NADEGIRI (art S4): code 1's hairline, then from f38 the seam to 8 m (§21.4), its V tallest at the reach, lower past it, gone by f65. 9 NS2a's
flame fan (SL4b, art batch B, DUEL_YAMA_CORE §34; 爆炎's too): the slash's 120 deg (arc 120, reach 2.4) as three arcs of fire at the blade's
height round him (RoS's spiral arcs; the opponent stays seen through them), the outer one at 2.35 m over an EMBER backing with curled tongues
leaning out off it (Rengoku's 昇り炎天), the middle at 1.85 m, an EMBER one at 1.3 m, a hooked tongue at the front: on f19 behind the
blade (+60 .. +38 deg), from S to S + A the whole hit (+60 .. -60: the fire thrown ahead of the blade; hitstop freezes it there), then
burning out from its +60 end f23-30, the tongues rising; 10 NS2b's f0-8 (it starts on NS2a's S+A): code 9's f22-30, so the burn-out
survives the link. The radius never moves with heat (the hit's): the tier sets the widths, the
tongues' height and share and the white core. A look; 0 B."
  (declare (type f32vec pos) (single-float yaw) (fixnum code sf ti))
  (let* ((x (aref pos 0)) (z (aref pos 2)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (flow-ph))   ; (DR: a flowing phase; the tongues'
         (hf (%ya-hf ti)) (seed (+ (* 3f0 x) z)))                                                 ;  seeds no longer his position: §15.7)
    (declare (single-float x z fx fz px pz dr hf seed))
    (case code
      (1 (when (<= 14 sf 15)                            ; the unseen cut: a hairline, 2 frames
           (fx-crescent (+ x (* 1.54f0 fx) (* -1.84f0 px)) 1.45f0 (+ z (* 1.54f0 fz) (* -1.84f0 pz))
                        (+ x (* 1.54f0 fx) (* 1.84f0 px)) 1.45f0 (+ z (* 1.54f0 fz) (* 1.84f0 pz))
                        (+ x (* 3.26f0 fx)) 1.45f0 (+ z (* 3.26f0 fz)) 0.03f0 :lens 0.02f0 (+ 150f0 seed) +pal-ink+ 0.98f0 :push 0.2f0))
         (when (<= 38 sf 52)                            ; the late split: the seam and its V
           (let* ((g (f-min 1f0 (/ (i->f (- sf 37)) 3f0))) (k (f-clamp (* 0.98f0 (/ (i->f (- 53 sf)) 7f0)) 0f0 0.98f0)))
             (declare (single-float g k))
             (toon-ground-seg (+ x (* 0.6f0 fx)) (+ z (* 0.6f0 fz)) (+ x (* 2.4f0 fx)) (+ z (* 2.4f0 fz)) 0.012f0 0.05f0 1f0 0.6f0 (+ 151f0 seed)
                              0.15f0 (toon-a +pal-ink+ k))
             (toon-ground-seg (+ x (* 0.6f0 fx)) (+ z (* 0.6f0 fz)) (+ x (* 2.4f0 fx)) (+ z (* 2.4f0 fz)) 0.014f0 0.02f0 1f0 0.6f0 (+ 152f0 seed)
                              0.1f0 (toon-a +pal-ember+ k))
             (dotimes (j 14)                            ; 7 a side, rising toward 2.4 m, leaning out
               (let* ((sd (if (< j 7) -1f0 1f0)) (i (i->f (mod j 7))) (u (/ (+ i 0.5f0) 7f0)) (along (+ 0.6f0 (* 1.8f0 u)))
                      (off (* sd (+ 0.05f0 (* 0.3f0 g u)))) (hh (* hf g (+ 0.4f0 (* 1.4f0 u)) (+ 0.8f0 (* 0.3f0 (flow01 (+ i (* 8f0 sd)) 4.1f0))))))
                 (declare (single-float sd i u along off hh))
                 (when (<= (hash01 (+ i (* 3f0 sd)) 6.3f0) hf)
                   (%ya-tongue (+ x (* along fx) (* off px)) 0.02f0 (+ z (* along fz) (* off pz)) (* sd 0.35f0 hh px) hh (* sd 0.35f0 hh pz)
                               0.13f0 ti k (+ 160f0 i (* 8f0 sd)) (+ dr i)))))
             (%light (+ x (* 1.6f0 fx)) 0.8f0 (+ z (* 1.6f0 fz)) 1f0 0.45f0 0.12f0 3f0 (* 0.7f0 k) 7))))
      ((2 3) (when (<= 12 sf 27)                        ; the halo: full on S16, to S + A (23), fading to 27
               (let* ((rr (if (= code 3) 3.2f0 2.4f0)) (g (f-clamp (/ (i->f (- sf 11)) 5f0) 0f0 1f0))
                      (k (if (<= sf 23) 0.98f0 (* 0.98f0 (/ (i->f (- 28 sf)) 5f0)))) (rad (+ 0.6f0 (* (- rr 0.6f0) g)))
                      (n (min 18 (+ 6 (* 3 (max 0 (- sf 11)))))))   ; (the tongues ignite round him, following the turn)
                 (declare (single-float rr g k rad) (fixnum n))
                 (when (>= sf 14) (%tring x 0f0 z rr 0.05f0 +pal-ember+ k (+ seed 1f0)))
                 (let ((ix x) (iy 1.05f0) (iz z))           ; INK behind him: his silhouette dark in the fire
                   (declare (single-float ix iy iz))
                   (%away-from-eye (ix iy iz) 0.7f0
                     (fx-disc ix iy iz 0.85f0 0.25f0 (+ 170f0 seed) +pal-ink+ (* 0.9f0 k) :push 0f0)))
                 (dotimes (i 18)
                   (when (< i n)
                     (let* ((f (i->f i)) (an (+ (f-atan2 fz fx) (* 0.349f0 f))) (c (f-cos an)) (s (f-sin an))
                            (tx (+ x (* rad c))) (tz (+ z (* rad s)))
                            (nq (%near-cam tx tz 1.5f0 4.5f0))
                            (hh (* hf (+ 0.75f0 (* 0.5f0 (flow01 f 4.9f0))) (+ 0.08f0 (* 0.92f0 nq nq)))))
                       (declare (single-float f an c s tx tz nq hh))
                       (when (<= (hash01 f 3.7f0) hf)
                         (%ya-tongue tx 0.03f0 tz (* 0.35f0 hh c) hh (* 0.35f0 hh s) 0.17f0 ti k (+ 180f0 f) (+ dr f))))))
                 (%light x 1.2f0 z 1f0 0.45f0 0.12f0 (* 1.5f0 rr) (* 1.1f0 k) 7))))
      (8 (when (<= 14 sf 15)                            ; 爆炎's true NADEGIRI (art S4): code 1's hairline on S and S+1
           (fx-crescent (+ x (* 1.54f0 fx) (* -1.84f0 px)) 1.45f0 (+ z (* 1.54f0 fz) (* -1.84f0 pz))
                        (+ x (* 1.54f0 fx) (* 1.84f0 px)) 1.45f0 (+ z (* 1.54f0 fz) (* 1.84f0 pz))
                        (+ x (* 3.26f0 fx)) 1.45f0 (+ z (* 3.26f0 fz)) 0.03f0 :lens 0.02f0 (+ 150f0 seed) +pal-ink+ 0.98f0 :push 0.2f0))
         (when (<= 38 sf 64)                            ; the seam from 0.6 m to 8 m (§21.4), its V tallest at the reach (2.4 m), lower
           (let* ((g (f-min 1f0 (/ (i->f (- sf 37)) 3f0))) (k (f-clamp (* 0.98f0 (/ (i->f (- 65 sf)) 8f0)) 0f0 0.98f0)))   ;  beyond it
             (declare (single-float g k))
             (toon-ground-seg (+ x (* 0.6f0 fx)) (+ z (* 0.6f0 fz)) (+ x (* 8f0 fx)) (+ z (* 8f0 fz)) 0.012f0 0.05f0 1f0 0.6f0 (+ 151f0 seed)
                              0.15f0 (toon-a +pal-ink+ k))
             (toon-ground-seg (+ x (* 0.6f0 fx)) (+ z (* 0.6f0 fz)) (+ x (* 8f0 fx)) (+ z (* 8f0 fz)) 0.014f0 0.02f0 1f0 0.6f0 (+ 152f0 seed)
                              0.1f0 (toon-a +pal-ember+ k))
             (dotimes (j 20)                            ; 10 a side
               (let* ((sd (if (< j 10) -1f0 1f0)) (i (i->f (mod j 10))) (u (/ (+ i 0.5f0) 10f0)) (along (+ 0.6f0 (* 7.4f0 u)))
                      (rise (if (<= along 2.4f0) (+ 0.4f0 (* 0.78f0 (- along 0.6f0))) (- 1.8f0 (* 0.21f0 (- along 2.4f0)))))
                      (off (* sd (+ 0.05f0 (* 0.3f0 g (f-min 1f0 (* 3f0 u)))))) (hh (* hf g rise (+ 0.8f0 (* 0.3f0 (flow01 (+ i (* 12f0 sd)) 4.1f0))))))
                 (declare (single-float sd i u along rise off hh))
                 (%ya-tongue (+ x (* along fx) (* off px)) 0.02f0 (+ z (* along fz) (* off pz)) (* sd 0.35f0 hh px) hh (* sd 0.35f0 hh pz)
                             0.13f0 ti k (+ 160f0 i (* 12f0 sd)) (+ dr i) :back nil)))
             (%light (+ x (* 2.4f0 fx)) 0.8f0 (+ z (* 2.4f0 fz)) 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k) 7))))
      (9 (when (<= 19 sf 30)                            ; NS2a's flame fan (SL4b, art batch B): the slash's 120 deg at the waist
           (let* ((full (>= sf 20)) (k (if (<= sf 22) 0.98f0 (* 0.98f0 (/ (i->f (- 31 sf)) 9f0))))
                  (b0 (if (<= sf 22) 1.0472f0 (- 1.0472f0 (* 0.2618f0 (i->f (- sf 22))))))   ; (the burnt end: +60 deg, eroding from f23
                  (b1 (if full -1.0472f0 0.6632f0))            ;  toward the blade) the fire's front: -60 on S (the whole hit), +38 on f19
                  (lift (* 0.06f0 (i->f (max 0 (- sf 22))))))  ; (the tongues rise as it burns out)
             (declare (single-float k b0 b1 lift))
             (dotimes (i 10)                            ; three arcs, a shallow cone rising toward him (RoS's spiral arcs round the arm):
               (let* ((u0 (/ (i->f i) 10f0)) (u1 (/ (i->f (1+ i)) 10f0)) (a0 (+ b0 (* u0 (- b1 b0)))) (a1 (+ b0 (* u1 (- b1 b0))))   ;  r 1.3
                      (c0 (f-cos a0)) (s0 (f-sin a0)) (c1 (f-cos a1)) (s1 (f-sin a1))                                               ;  EMBER,
                      (dx0 (+ (* c0 fx) (* s0 px))) (dz0 (+ (* c0 fz) (* s0 pz))) (dx1 (+ (* c1 fx) (* s1 px))) (dz1 (+ (* c1 fz) (* s1 pz)))   ;  1.85
                      (tx (- (* c0 px) (* s0 fx))) (tz (- (* c0 pz) (* s0 fz)))   ; (the trailing way along the arc: toward +bearing)  ;  and 2.35
                      (y0 (- 0.98f0 (* 0.1f0 (/ a0 1.0472f0)))) (y1 (- 0.98f0 (* 0.1f0 (/ a1 1.0472f0))))   ; (the blade's path rises to his left)
                      (w0 (* hf (+ 0.05f0 (* 0.15f0 (f-sin (* 3.1416f0 u0)))))) (w1 (* hf (+ 0.05f0 (* 0.15f0 (f-sin (* 3.1416f0 u1)))))))   ; FIRE
                 (declare (single-float u0 u1 a0 a1 c0 s0 c1 s1 dx0 dz0 dx1 dz1 tx tz y0 y1 w0 w1))
                 (let ((bx (+ x (* 2.35f0 dx0))) (by y0) (bz (+ z (* 2.35f0 dz0)))   ; the outer arc's EMBER backing (the bright edge read),
                       (ex (+ x (* 2.35f0 dx1))) (ey y1) (ez (+ z (* 2.35f0 dz1))))  ;  both ends behind it
                   (declare (single-float bx by bz ex ey ez))
                   (%away-from-eye (bx by bz) 0.06f0
                     (%away-from-eye (ex ey ez) 0.06f0
                       (%ya-seg bx by bz ex ey ez (* 1.4f0 w0) (* 1.4f0 w1) 0 k (+ 200f0 (i->f i)) dr :pal +pal-ember+))))
                 (%ya-seg (+ x (* 2.35f0 dx0)) y0 (+ z (* 2.35f0 dz0)) (+ x (* 2.35f0 dx1)) y1 (+ z (* 2.35f0 dz1)) w0 w1 ti k
                          (+ 210f0 (i->f i)) (+ dr (i->f i)))
                 (%ya-seg (+ x (* 1.85f0 dx0)) (+ y0 0.12f0) (+ z (* 1.85f0 dz0)) (+ x (* 1.85f0 dx1)) (+ y1 0.12f0) (+ z (* 1.85f0 dz1))
                          (* 0.55f0 w0) (* 0.55f0 w1) ti (* 0.95f0 k) (+ 220f0 (i->f i)) (+ dr (i->f i)))
                 (%ya-seg (+ x (* 1.3f0 dx0)) (+ y0 0.24f0) (+ z (* 1.3f0 dz0)) (+ x (* 1.3f0 dx1)) (+ y1 0.24f0) (+ z (* 1.3f0 dz1))
                          (* 0.35f0 w0) (* 0.35f0 w1) 0 (* 0.9f0 k) (+ 230f0 (i->f i)) (+ dr (i->f i)) :pal +pal-ember+)
                 (when (and (> i 0) (<= (hash01 (i->f i) 9.7f0) hf))   ; curled tongues off the outer edge, leaning out and trailing the
                   (let ((hh (* hf (+ 0.5f0 lift) (+ 0.7f0 (* 0.6f0 (flow01 (i->f i) 6.1f0))))))   ;  sweep (Rengoku's hooks)
                     (declare (single-float hh))
                     (%ya-tongue (+ x (* 2.3f0 dx0)) y0 (+ z (* 2.3f0 dz0)) (* hh (+ (* 0.3f0 dx0) (* 0.45f0 tx))) hh (* hh (+ (* 0.3f0 dz0) (* 0.45f0 tz)))
                                 (* 0.13f0 hf) ti k (+ 240f0 (i->f i)) (+ dr (i->f i)) :segs 4)))))
             (let* ((c (f-cos b1)) (s (f-sin b1)) (dx (+ (* c fx) (* s px))) (dz (+ (* c fz) (* s pz))) (hh (* hf 0.55f0)))   ; the front's
               (declare (single-float c s dx dz hh))                                                                         ;  hook
               (%ya-tongue (+ x (* 2.3f0 dx)) (- 0.98f0 (* 0.1f0 (/ b1 1.0472f0))) (+ z (* 2.3f0 dz)) (* 0.3f0 hh (- dz)) hh (* 0.3f0 hh dx)
                           (* 0.12f0 hf) ti k 250f0 dr :segs 4))
             (%light (+ x (* 1.6f0 fx)) 1f0 (+ z (* 1.6f0 fz)) 1f0 0.45f0 0.12f0 3.5f0 (* 0.9f0 k) 7))))
      (10 (when (<= sf 8) (yama-sk-moves pos yaw 9 (+ sf 22) ti)))   ; NS2b (reached from NS2a's S+A): the fan burns out across the link (debug
                                                                      ;  87414's NS2b alone draws that burn-out too)
      (5 (when (<= 10 sf 14)                            ; AS1: the point-blank corkscrew to the reach
           (let* ((k (if (<= sf 12) 0.98f0 (* 0.98f0 (/ (i->f (- 15 sf)) 3f0)))) (spin (flow-ph 18.849556f0)))
             (declare (single-float k spin))
             (dotimes (st 2)
               (dotimes (i 5)
                 (let* ((u0 (* 0.2f0 (i->f i))) (u1 (+ u0 0.2f0)) (ph (* 3.1416f0 (i->f st)))
                        (s0 (+ 0.2f0 (* 1.4f0 u0))) (s1 (+ 0.2f0 (* 1.4f0 u1))) (a0 (+ spin ph (* 4f0 s0))) (a1 (+ spin ph (* 4f0 s1)))
                        (r0 (* 0.3f0 hf (- 1f0 (* 0.5f0 u0)))) (r1 (* 0.3f0 hf (- 1f0 (* 0.5f0 u1)))))
                   (declare (single-float u0 u1 ph s0 s1 a0 a1 r0 r1))
                   (%ya-seg (+ x (* s0 fx) (* r0 (f-cos a0) px)) (+ 1.1f0 (* r0 (f-sin a0))) (+ z (* s0 fz) (* r0 (f-cos a0) pz))
                            (+ x (* s1 fx) (* r1 (f-cos a1) px)) (+ 1.1f0 (* r1 (f-sin a1))) (+ z (* s1 fz) (* r1 (f-cos a1) pz))
                            (* 0.09f0 (- 1f0 (* 0.5f0 u0))) (* 0.09f0 (- 1f0 (* 0.5f0 u1))) ti k (+ 190f0 (* 7f0 (i->f st)) (i->f i))
                            (+ dr (i->f i))))))))))
    nil))

(defun yama-sk-code (mv)
  "YAMA-SK-MOVES's code for the Shikai / 爆炎 move MV, or 0."
  (case (mv-name mv)
    ((:ya-n3c :ya-as3c :ya-b-as3c) 1) (:ya-sa 2) (:ya-b-sa 3) ((:ya-as1 :ya-b-as1) 5) (:ya-b-n3c 8) ((:ya-n2a :ya-b-n2a) 9) ((:ya-n2b :ya-b-n2b) 10) (t 0)))

(defun ya-sk-tier (e f mv)
  "The tier of E's own move MV (fighter F) for SL0 / SL7-SL9: 2 in 爆炎; in the Shikai the heat his NS segment in play paid (YAMA-SEG-HEAT),
0 for an AS, the SA or J. Reads only."
  (ya-heat-tier (if (and mv (eq (fighter-cls f) :ns)) (yama-seg-heat e) 0f0) (eq (fighter-form f) :blaze)))

;;; ================================================================ 爆炎's looks (art batch S4: DUEL_YAMA_CORE §21.4, §25)
;;; The scars by heat, ENNETSU's ground fire round him (art batch B, §34; rows of pillars until §30.1), NS2b's ring closing before its
;;; dome, the entry pose's fire, IKKOTSU's fist; the tornado's lean is in YAMA-TORNADO-LOOK, the true NADEGIRI's seam YAMA-SK-MOVES code 8, the flame trail VFX-SMEAR look 5. Every 爆炎
;;; fire is T2 (white-cored). Read only, 0 B (debug 87449's rows), cosmetics on the fx clock / HASH01 / RND.
(defconstant +ya-dome-near+ 0f0 "爆炎 NS2b's :near (host-checked): the ring's predicted spot (YAMA-RING-CLOSE). 3 until batch J1 (§28.3).")
(defconstant +ya-dome-far+ 3f0 "爆炎 NS2b's :far (host-checked). 8 until §30.1 (2026-11-21: pointer 2 close).")
(defconstant +ya-arena-in+ 14.5f0 "*ARENA-RADIUS* less 0.5 (host-checked): YA-BEARING-POINT's circle.")

(declaim (type f32vec *ya-scar-v* *ya-sc0* *ya-sc1*))
(defvar *ya-scar-v*
  (let ((v (make-f32 (* 6 (length *ya-scars*)))))
    (loop for (p x y z len a) in *ya-scars* for o from 0 by 6
          do (let ((r (* a (/ pi 180))) (h (* 0.5 len)))
               (setf (aref v o) (float (joint-index p) 1f0) (aref v (+ o 1)) (float x 1f0) (aref v (+ o 2)) (float y 1f0)
                     (aref v (+ o 3)) (float (+ z (* 0.004 (signum z))) 1f0)            ; (4 mm off the skin, along its normal)
                     (aref v (+ o 4)) (float (* h (cos r)) 1f0) (aref v (+ o 5)) (float (* h (sin r)) 1f0))))
    v)
  "*YA-SCARS* as floats, 6 a scar: joint index, the centre x y z (z 4 mm out along the surface's normal), the half-length's x y.")
(defvar *ya-sc0* (make-f32 3) "YAMA-SCAR-GLOW's scratch end.")
(defvar *ya-sc1* (make-f32 3) "YAMA-SCAR-GLOW's scratch end.")

(defun-fast yama-scar-glow (jm heat)
  "爆炎's scars by heat (§21.4): over each of the 12 dull-red glowing scars (*YA-SCARS*, posed by JM) an additive fire hairline, its
brightness and width the heat's share above 25 (full at 100, gone by 25), white-cored from 70 up; in the last 10 a dull ember pulse (3 a
second, the fx clock): the form is about to end. A look; 0 B."
  (declare (type f32vec jm) (single-float heat))
  (let* ((g (f-clamp (/ (- heat 25f0) 75f0) 0f0 1f0)) (on (> (f-sin (* 18.85f0 (fx-clock))) 0f0))
         (v *ya-scar-v*) (a *ya-sc0*) (b *ya-sc1*)
         (w (+ 0.005f0 (* 0.006f0 g))) (gg (+ 0.4f0 (* 0.3f0 g))) (bb (+ 0.12f0 (* 0.1f0 g)))
         (al (if (>= heat 70f0) (+ 0.5f0 (* 0.5f0 g)) (- (+ 0.3f0 (* 0.6f0 g))))))   ; (a positive alpha whitens the line's centre)
    (declare (single-float g w gg bb al) (type f32vec v a b))
    (when (or (> g 0f0) (and (<= heat 10f0) on))
      (when (= g 0f0) (setf w 0.008f0 gg 0.25f0 bb 0.08f0 al -0.85f0))   ; the pulse
      (dotimes (i 12)
        (let* ((o (* 6 i)) (j (f->i (aref v o))) (x (aref v (+ o 1))) (y (aref v (+ o 2))) (z (aref v (+ o 3)))
               (hx (aref v (+ o 4))) (hy (aref v (+ o 5))))
          (declare (fixnum o j) (single-float x y z hx hy))
          (joint-point! a jm j (- x hx) (- y hy) z)
          (joint-point! b jm j (+ x hx) (+ y hy) z)
          (let ((x0 (aref a 0)) (y0 (aref a 1)) (z0 (aref a 2)))
            (declare (single-float x0 y0 z0))
            (fx-ribbon x0 y0 z0 (- (aref b 0) x0) (- (aref b 1) y0) (- (aref b 2) z0) w w 1f0 gg bb al 1f0 gg bb al 0f0 0f0 :segs 1))))))
  nil)

(defun-fast yama-ennetsu-look (hz rdt)
  "爆炎 NS2c ENNETSU JIGOKU, the ground fire round him (art batch B, DUEL_YAMA_CORE §34; §30.1's disc: the :ya-col of HAZARD-SIZE r 2.5 on
his feet, hot 6, life 30; it was rows of pillars down a :wave's lane until §30.1, then the column's look). Kilauea's fissure curtain and
RoS's ring (sp30-art-refs §4): a bed of low tongues spread unevenly over the disc (none inside 0.7 m: he stands in it), the rim a curtain of
taller tongues leaning out and six fountains (%YA-PILLAR) to *YA-FIRE-H* (the hit's height) throwing sparks up (streaks: shards by RDT,
ages 0-14), a FIRE line on the rim over the EMBER footprint ring (the disc's edge at every tier and age), a patchy EMBER scorch disc. It
erupts on the hit frame (age 0: the bed and the curtain 70 % high, the fountains' first drawing; full by age 3: hitstop freezes the first),
stands to age 14, then dies down over 16 f to embers (the heights and the presence fall together). Near the lens the rim shortens (the
behind camera stands 2 m past the rim). T2 in 爆炎. A look; 0 B (sparks and scraps by RDT)."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (dr (flow-ph)) (seed (+ (* 3f0 x) z))
         (rise (f-min 1f0 (+ 0.7f0 (* 0.1f0 (i->f age)))))
         (die (f-clamp (/ (i->f (- life age)) 16f0) 0f0 1f0)) (k (* 0.98f0 die)) (hs (* hf rise (+ 0.3f0 (* 0.7f0 die)))))
    (declare (single-float x z r hf dr seed rise die k hs) (fixnum age life ti))
    (%tring x 0f0 z (* 0.5f0 r) (* 0.5f0 r) +pal-ember+ (* 0.3f0 k) (+ seed 2f0))   ; the scorch disc (patchy: low presence)
    (%tring x 0f0 z (- r 0.08f0) 0.08f0 +pal-ember+ (f-max 0.6f0 k) (+ seed 1f0))   ; the footprint's edge (stays to the end)
    (%tring x 0.03f0 z (- r 0.1f0) 0.03f0 +pal-fire+ k (+ seed 3f0) 48)             ; the bright line on the rim
    (dotimes (i 32)                                    ; the bed: low tongues at hashed spots 0.7 .. r - 0.2, leaning a little
      (let* ((f (i->f i)) (an (* 6.2832f0 (hash01 f (+ seed 4.1f0)))) (rr (+ 0.7f0 (* (- r 0.9f0) (f-sqrt (hash01 f (+ seed 7.3f0))))))
             (bx (+ x (* rr (f-cos an)))) (bz (+ z (* rr (f-sin an))))
             (hh (* hs (+ 0.35f0 (* 0.5f0 (flow01 f 3.3f0))))) (lx (* 0.3f0 hh (- (flow01 f 5.1f0) 0.5f0))) (lz (* 0.3f0 hh (- (flow01 f 6.7f0) 0.5f0))))
        (declare (single-float f an rr bx bz hh lx lz))
        (when (<= (hash01 f 5.9f0) hf)
          (%ya-tongue bx 0.02f0 bz lx hh lz 0.2f0 ti k (+ 400f0 f) (+ dr f) :back nil :segs 3))))
    (dotimes (i 24)                                    ; the rim: a curtain of tongues leaning out
      (let* ((f (i->f i)) (an (+ (* 0.2618f0 f) (* 0.12f0 (hash01 f (+ seed 1.7f0))))) (c (f-cos an)) (s (f-sin an))
             (bx (+ x (* (- r 0.15f0) c))) (bz (+ z (* (- r 0.15f0) s))) (q (%near-cam bx bz 2f0 6f0))
             (hh (* hs (+ 0.15f0 (* 0.85f0 q)) +ya-fire-h+ (+ 0.3f0 (* 0.45f0 (flow01 f 4.7f0))))))
        (declare (single-float f an c s bx bz q hh))
        (when (<= (hash01 f 8.9f0) hf)
          (%ya-tongue bx 0.02f0 bz (* 0.22f0 hh c) hh (* 0.22f0 hh s) 0.22f0 ti k (+ 430f0 f) (+ dr f) :back nil :segs 4))))
    (let ((as (/ (i->f age) 60f0)) (ls (/ (i->f life) 60f0)) (ph (* +ya-fire-h+ hf (+ 0.3f0 (* 0.7f0 die)))))
      (declare (single-float as ls ph))
      (dotimes (i 6)                                   ; six fountains on the rim to the hit's height, throwing sparks (Kilauea)
        (let* ((an (+ 0.2618f0 (* 1.0472f0 (i->f i)))) (c (f-cos an)) (s (f-sin an))
               (bx (+ x (* (- r 0.3f0) c))) (bz (+ z (* (- r 0.3f0) s))) (q (%near-cam bx bz 2f0 8f0)))
          (declare (single-float an c s bx bz q))
          (%ya-pillar bx bz as ls ph 0.3f0 ti rdt)
          (when (< age 15)                             ; the sparks: streaks up and out, falling back
            (dotimes (j (n-of (* 60f0 q) rdt))
              (%t-shard bx (* ph (rnd-range 0.4f0 0.9f0)) bz (+ (* c (rnd-range 0.5f0 2f0)) (rnd-range -0.8f0 0.8f0)) (rnd-range 5f0 9f0)
                        (+ (* s (rnd-range 0.5f0 2f0)) (rnd-range -0.8f0 0.8f0)) (rnd-range 0.6f0 1f0) (rnd-range 0.1f0 0.16f0)
                        7f0 +pal-fire+))))))
    (%light x 1f0 z 1f0 0.45f0 0.12f0 5.5f0 (* 1.1f0 k) 7)
    nil))

(defun-fast yama-ring-close (e sf)
  "爆炎 NS2b, the ring closing at once (§21.4): through the move's last 4 frames before S (f12-15) the burning ring coils in round the spot
its dome will take (his live ring's, else the victim's bearing 0-8 m, YA-BEARING-POINT's rule, read now: the victim may still step), low
tongues on SL5's band; on S the dome hazard stands closed (the hit frame draws it full: §22.2). T2. A look; 0 B."
  (declare (fixnum sf))
  (let* ((ring (yama-live-ring e)) (p (pos-of e)) (q (pos-of (opp-of e))) (x 0f0) (z 0f0))
    (declare (type f32vec p q) (single-float x z))
    (if ring
        (let ((h (hazard ring))) (setf x (hazard-x h) z (hazard-z h)))
        (let* ((dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2))) (d (f-hypot dx dz))
               (rr (f-clamp d +ya-dome-near+ +ya-dome-far+)) (ux (if (> d 1f-4) (/ dx d) 0f0)) (uz (if (> d 1f-4) (/ dz d) 1f0))
               (cx (+ (aref p 0) (* rr ux))) (cz (+ (aref p 2) (* rr uz))) (cd (f-hypot cx cz)))
          (declare (single-float dx dz d rr ux uz cx cz cd))
          (if (<= cd +ya-arena-in+) (setf x cx z cz) (setf x (* cx (/ +ya-arena-in+ cd)) z (* cz (/ +ya-arena-in+ cd))))))
    (let* ((coil (f-min 1f0 (/ (i->f (- sf 11)) 4f0))) (dr (flow-ph)) (seed 3.7f0)   ; (flowing; one seed: the spot may follow the victim, §15.7)
           (a0 (f-atan2 (- (aref p 2) z) (- (aref p 0) x))))   ; (from the point nearest him, both ways round)
      (declare (single-float coil dr seed a0))
      (%tring x 0f0 z 1.6f0 +ya-ring-band+ +pal-ember+ 0.8f0 (+ seed 1f0))
      (dotimes (i 24)
        (let* ((f (i->f i)) (u (/ f 24f0)) (an (+ a0 (* 6.2832f0 (if (evenp i) (* 0.5f0 u) (- 1f0 (* 0.5f0 u))))))
               (c (f-cos an)) (s (f-sin an)) (hh (* 0.55f0 (+ 0.7f0 (* 0.3f0 (flow01 f seed))))))
          (declare (single-float f u an c s hh))
          (when (<= u coil)
            (%ya-tongue (+ x (* 1.6f0 c)) 0.02f0 (+ z (* 1.6f0 s)) (* 0.1f0 hh c) hh (* 0.1f0 hh s) (* 0.8f0 +ya-ring-band+) 2 0.95f0
                        (+ 100f0 f seed) (+ dr f)))))
      (%light x 0.6f0 z 1f0 0.45f0 0.12f0 3f0 0.7f0 6)))
  nil)

(defun-fast yama-blaze-in-look (tip base sf)
  "爆炎's entry pose (§21.4, :YA-BLAZE-IN): the point in the plaza at his right; over f7-10 the fire runs down the edge from the guard to
the point (a white-cored strand growing along the blade BASE .. TIP), and from f10 a ring of fire runs out over the floor from where the
point stands, to 2.5 m by f16, guttering by f21. A look; 0 B."
  (declare (type f32vec tip base) (fixnum sf))
  (when (<= 7 sf 21)
    (let* ((x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (tx (aref tip 0)) (tz (aref tip 2))
           (bx (- tx x0)) (by (- (aref tip 1) y0)) (bz (- tz z0)) (dr (flow-ph)) (seed (+ (* 3f0 tx) tz))   ; (DR: flowing, §15.7)
           (u (f-min 1f0 (/ (i->f (- sf 6)) 4f0))) (k (if (<= sf 16) 0.98f0 (* 0.98f0 (/ (i->f (- 22 sf)) 6f0)))))
      (declare (single-float x0 y0 z0 tx tz bx by bz dr seed u k))
      (when (<= sf 16)                                 ; down the edge
        (%ya-seg x0 y0 z0 (+ x0 (* u bx)) (+ y0 (* u by)) (+ z0 (* u bz)) 0.05f0 0.08f0 2 0.98f0 (+ 230f0 seed) dr))
      (when (>= sf 10)                                 ; the ring running out from the point
        (let ((rr (+ 0.3f0 (* 2.2f0 (f-min 1f0 (/ (i->f (- sf 10)) 6f0))))))
          (declare (single-float rr))
          (%tring tx 0f0 tz rr 0.07f0 +pal-ember+ k (+ seed 1f0))
          (dotimes (i 16)
            (let* ((f (i->f i)) (an (+ (* 0.3927f0 f) (* 0.2f0 (hash01 f seed)))) (c (f-cos an)) (s (f-sin an))
                   (hh (* (- 0.75f0 (* 0.15f0 rr)) (+ 0.7f0 (* 0.3f0 (flow01 f seed))))))
              (declare (single-float f an c s hh))
              (%ya-tongue (+ tx (* rr c)) 0.02f0 (+ tz (* rr s)) (* 0.25f0 hh c) hh (* 0.25f0 hh s) 0.12f0 2 k (+ 240f0 f seed) (+ dr f)))))
        (%light tx 0.5f0 tz 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k) 7))))
  nil)

(defun-fast %ya-fist-fire (v yaw sf)
  "爆炎 IKKOTSU's fist (§21.4): a short FIRE burst on the fist V on S (f9, full: the hit frame), driven along his facing YAW, to S+A,
fading by f13. White-cored (T2). A look; 0 B."
  (declare (type f32vec v) (single-float yaw) (fixnum sf))
  (when (<= 9 sf 13)
    (let* ((x (aref v 0)) (y (aref v 1)) (z (aref v 2)) (dr (flow-ph)) (k (if (<= sf 11) 0.98f0 (* 0.98f0 (/ (i->f (- 14 sf)) 3f0))))
           (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
      (declare (single-float x y z dr k fx fz))
      (dotimes (j 6)
        (let* ((f (i->f j)) (an (* 1.0472f0 f)) (l (* 0.32f0 (+ 0.6f0 (* 0.4f0 (flow01 f 3.9f0))))) (c (f-cos an)) (s (f-sin an)))
          (declare (single-float f an l c s))
          (%ya-tongue x y z (* l (+ fx (* 0.45f0 c fz))) (* l 0.45f0 s) (* l (- fz (* 0.45f0 c fx))) 0.06f0 2 k (+ 250f0 f) (+ dr f) :segs 3)))
      (%light x y z 1f0 0.5f0 0.15f0 2.5f0 (* 0.8f0 k) 7)))
  nil)

;;; ---------------------------------------------------------------- the consing probe (debug 87448)
(defvar *ya-dq-n* (find-symbol "*DQ-N*" :engine) "The engine's draw count (render.lisp, not exported): the probe rewinds it.")
(defmacro %ya-cons-per (name form &optional each)
  "The consing probes' row (87448, 87449): bytes consed by 10 runs of FORM after 10 unmeasured ones, as \"NAME n\" (debug.lisp's CONS-PER,
which loads after this file, plus a warm-up: the engine's draw queue doubles at a new high-water mark, so the measured draws get the room
the warm-up made: the steady state; art K4: the fx batches are rewound too, so no look is measured on a full batch's skip path:
\"(dropped)\" if one still overflowed; rewound after every run, so each run has the whole batch, as a frame does). The probe's
draws are taken off the frame's queue again. EACH (art S5's flag for a cinematic's busiest frames) is kept for its callers (every run is
rewound anyway)."
  (declare (ignore each))
  `(let ((n0 (symbol-value *ya-dq-n*))
         (f0 (stream-buffer-fill *fx-toon*)) (f1 (stream-buffer-fill *fx-add*))
         (f2 (stream-buffer-fill *fx-alpha*)) (d0 *fx-dropped*))
     (flet ((rewind () (setf (symbol-value *ya-dq-n*) n0 (stream-buffer-fill *fx-toon*) f0
                             (stream-buffer-fill *fx-add*) f1 (stream-buffer-fill *fx-alpha*) f2)))
       (dotimes (i 10) ,form (rewind))
       (let* ((c0 (cons-bytes)) (d1 *fx-dropped*) (b (progn (dotimes (i 10) ,form (rewind)) (- (cons-bytes) c0))))   ; (the bytes before the
         (prog1 (format nil "~a ~d~:[~; (dropped)~]" ,name b (/= d1 *fx-dropped*))                       ;  row's name: a computed
           (rewind) (setf *fx-dropped* d0))))))                                                         ;  name conses)

(defun yama-look-consing ()
  "Debug 87448: bytes consed by 10 draws of each Bankai look (0 B each wanted), on stand-in hazards mid-life (made before the count),
after 10 unmeasured draws; the probe's draws are taken off the frame's queue again (a debug line, not a picture). Art K2 adds the
stances' garb / cracks (YAMA-STANCE-LOOK on stand-in anims) and the smear (VFX-SMEAR look 3 on a stand-in trail); art K3 the planted blade
(DRAW-PLANTED-WEAPON at a *YA-PLANTS* spot), 北's burn (%YA-BLADE-BURN on stand-in ends) and the :planted hook itself; art K4 the
three Kikon cinematics' looks (YAMA-HIGASHI-LOOK / -NISHI- / -MINAMI-, yama-cine.lisp) at their busiest frames, P1 and P2 as the actors;
art K5 the 東 tear (YAMA-TEAR) while its spikes grow (void-grow, east-open) and at full (east-full); art D AS4's segment looks (codes 9-11),
天地灰尽's band (running out, full), the cinders on P2's joints, the whole YAMA-AS4-LOOK and the victim's ash (YAMA-VICTIM-LOOK) on a stand-in
hit 20 f old (the north band and the crescent left: no move draws them since §33 / art D)."
  (let ((hands (make-hazard :kind :ya-col :x 0f0 :z -5f0 :size 1.2f0 :life 30 :age 3))
        (tell (make-hazard :kind :ya-col :x 0f0 :z -5f0 :size 1.2f0 :life 30 :delay 5))
        (swarm (make-hazard :kind :wave :x 0f0 :z -4f0 :px 0f0 :pz -3.9f0 :size 1f0 :life 80 :age 20 :speed 6f0))
        (tw-rise (make-hazard :kind :ya-tower :x 0f0 :z -2.5f0 :size 1.6f0 :life 127 :age 6 :data (list :level 1)))
        (tw-1 (make-hazard :kind :ya-tower :x 0f0 :z -2.5f0 :size 1.6f0 :life 127 :age 40 :data (list :level 1)))
        (tw-climb (make-hazard :kind :ya-tower :x 0f0 :z -2.5f0 :size 1.6f0 :life 155 :age 49 :data (list :level 2)))
        (tw-2 (make-hazard :kind :ya-tower :x 0f0 :z -2.5f0 :size 1.6f0 :life 155 :age 80 :data (list :level 2)))
        (tw-ash (make-hazard :kind :ya-tower :x 0f0 :z -2.5f0 :size 1.6f0 :life 155 :age 148 :data (list :level 2)))
        (tw-lean (make-hazard :kind :ya-tower :owner *p1* :x 0f0 :z -2.5f0 :size 1.6f0 :life 155 :age 90 :data (list :level 2)))
        (mv-n3c (kit-move (find-kit :yamamoto :bankai) :ya-e-n3c))
        (fall-0 (make-hazard :kind :ya-fall :x 0f0 :z -5.5f0 :size 3f0 :life 30 :age 0))
        (fall (make-hazard :kind :ya-fall :x 0f0 :z -5.5f0 :size 3f0 :life 30 :age 5))
        (shat-0 (make-hazard :kind :fx :x 0f0 :z -3f0 :size 3f0 :life 30 :age 0))
        (shat (make-hazard :kind :fx :x 0f0 :z -3f0 :size 3f0 :life 30 :age 3))
        (as3b (make-hazard :kind :ya-col :x 0f0 :z -3f0 :size 1.4f0 :life 30 :age 8))
        (pile (make-hazard :kind :ya-col :x 0f0 :z -1f0 :size 1.4f0 :life 30 :age 17))
        (pos (pos-of *p1*)) (yaw (yaw-of *p1*))
        (an-m (let ((a (make-anim))) (anim-play a :ya-st-minami :blend 0) a))
        (an-q2 (let ((a (make-anim))) (anim-play a :ya-e-q2 :blend 0 :time (/ 8 60f0)) a))   ; (art C: the drawn clip's time)
        (tr (let ((tr (make-trail))) (dotimes (i 5 tr) (trail-push tr 0f0 1f0 (- -0.3f0 (* 0.1f0 i)) (* 0.25f0 i) 1.5f0 -1.2f0))))
        (sm (make-f32 12))
        (px (aref (pos-of *p1*) 0)) (pz (aref (pos-of *p1*) 2)) (sp (fourth (first *ya-plants*)))   ; (art K3: boxed once, as DRAW-FIGHTER's)
        (tp (let ((v (make-f32 3))) (setf (aref v 0) 0.4f0 (aref v 1) 0.2f0 (aref v 2) 0.6f0) v))
        (bs (let ((v (make-f32 3))) (setf (aref v 0) 0.3f0 (aref v 1) 0.8f0 (aref v 2) 0.1f0) v))
        (fp (fighter *p1*)) (mv-as2 (kit-move (find-kit :yamamoto :bankai) :ya-e-as2))
        (bk (find-kit :yamamoto :bankai)) (j2c (ya-reach-copy :ya-e-j2 2)) (as2bc (ya-reach-copy :ya-e-as2b 1))   ; (art C: 西's flame,
        (sac (kit-move (find-kit :yamamoto :bankai) :ya-e-sa-c1)) (zb (find-body :yamamoto-tybw)) (zw (find-weapon :zanka)))   ;  stand-ins)
    (setf (aref *ya-as4-hit* 0) -2 (aref *ya-as4-hit* 1) (- *match-tick* 20))   ; (a stand-in 天地灰尽 hit 20 f ago, cleared below)
    (macrolet ((cons-per (name form) `(%ya-cons-per ,name ,form)))
     (flet ((fresh () (ya-dead-reset)))
      (log-msg "yama look consing (10 draws, B): ~{~a~^, ~}"
               (list (cons-per "hands" (progn (fresh) (yama-hands-look hands 0.016f0)))
                     (cons-per "tell" (progn (fresh) (yama-hands-look tell 0.016f0)))
                     (cons-per "swarm" (progn (fresh) (yama-swarm-look swarm 0.016f0)))
                     (cons-per "tower-rise" (progn (fresh) (yama-tower-look tw-rise 0.016f0)))   ; (§34 A: the tower, its climb, its
                     (cons-per "tower" (progn (fresh) (yama-tower-look tw-1 0.016f0)))           ;  crumble, the topple, the shatter,
                     (cons-per "tower-climb" (progn (fresh) (yama-tower-look tw-climb 0.016f0))) ;  AS3b's ring)
                     (cons-per "tower-2" (progn (fresh) (yama-tower-look tw-2 0.016f0)))
                     (cons-per "tower-ash" (progn (fresh) (yama-tower-look tw-ash 0.016f0)))
                     (let ((m0 (fighter-move fp)) (s0 (fighter-sf fp)))   ; (NSc's wind-up: the lean read off P1's move, frame 12)
                       (unwind-protect (progn (setf (fighter-move fp) mv-n3c (fighter-sf fp) 12)
                                              (cons-per "tower-lean" (progn (fresh) (yama-tower-look tw-lean 0.016f0))))
                         (setf (fighter-move fp) m0 (fighter-sf fp) s0)))
                     (cons-per "topple-fall" (progn (fresh) (yama-topple-look fall-0 0.016f0)))
                     (cons-per "topple" (progn (fresh) (yama-topple-look fall 0.016f0)))
                     (cons-per "shatter-0" (yama-shatter-look shat-0 0.016f0))
                     (cons-per "shatter" (yama-shatter-look shat 0.016f0))
                     (cons-per "as3b-tower" (yama-as3b-look as3b 0.016f0))
                     (cons-per "pile" (progn (fresh) (yama-pile-look pile 0.016f0)))
                     (cons-per "lance" (yama-bk-moves pos yaw 1 21 0.016f0))
                     (cons-per "void" (yama-bk-moves pos yaw 2 30 0.016f0))
                     (cons-per "void-grow" (yama-bk-moves pos yaw 2 19 0.016f0))   ; (art K5: the tear's spikes growing)
                     (cons-per "notch" (yama-bk-moves pos yaw 3 12 0.016f0))
                     (cons-per "flare" (yama-bk-moves pos yaw 4 17 0.016f0))
                     (cons-per "rise" (yama-bk-moves pos yaw 7 12 0.016f0))
                     (cons-per "as4-grip" (yama-bk-moves pos yaw 9 14 0.016f0))   ; (art D: AS4's segment looks, the band, the cinders,
                     (cons-per "as4-cut" (yama-bk-moves pos yaw 10 14 0.016f0))   ;  the victim's ash tint: the store set to a hit 20 f ago)
                     (cons-per "as4-line" (yama-bk-moves pos yaw 11 12 0.016f0))
                     (cons-per "as4-band" (yama-as4-band *ya-as4-at* 0 1))
                     (cons-per "as4-band-full" (yama-as4-band *ya-as4-at* 0 20))
                     (cons-per "as4-cinders" (yama-as4-cinders (model-joints (model *p2*)) 20))
                     (cons-per "as4-look" (yama-as4-look *p1* fp))
                     (cons-per "victim-ash" (yama-victim-look *p1* *p2*))
                     (cons-per "garb" (yama-garb-at (model-joints (model *p1*)) (fighter *p1*)))   ; (J2: 殘日獄衣 at K 1, 西's form aura)
                     (cons-per "garb-lean" (progn (setf (aref *ya-lean* 4) 0.4f0 (aref *ya-lean* 5) 0.2f0)   ; (§29.1: the spring stepped,
                                                  (yama-lean-draw (model-joints (model *p1*)) 0)               ;  the garb bent)
                                                  (yama-garb-at (model-joints (model *p1*)) (fighter *p1*))))
                     (cons-per "garb-flare" (yama-bk-moves pos yaw 5 17 0.016f0))   ; (batch J2: 殘日獄衣 flared, NS2b's)
                     (cons-per "garb-throw" (yama-bk-moves pos yaw 6 13 0.016f0))   ; (AS2b's, growing)
                     (cons-per "west-arc-2" (ya-west-arc *p1* (find-clip (kit-move-clip bk (mv-clip j2c))) j2c 9 1.6f0 0 zb zw an-m))   ; (art C, §34:
                     (cons-per "west-arc-anim" (ya-west-arc *p1* (find-clip :ya-e-q2) j2c 7 1.6f0 0 zb zw an-q2))
                     (cons-per "west-arc-sa1" (ya-west-arc *p1* (find-clip (kit-move-clip bk (mv-clip sac))) sac 8 0.8f0 0 zb zw an-m))   ;  J2 at level
                     (cons-per "west-arc-hand" (ya-west-arc *p1* (find-clip :ya-e-grab) mv-as2 13 0.8f0 1 zb nil an-m))           ;  2, the SA's 1,
                     (cons-per "west-ring" (ya-west-ring *p1* as2bc 13))
                     (let ((st (fighter-state fp)) (ph (fighter-phase fp)) (mv0 (fighter-move fp)) (sf0 (fighter-sf fp))   ; (the whole hook,
                           (cm0 (fighter-charge-mult fp)))                                                                  ;  P1 put in a
                       (setf (fighter-state fp) :move (fighter-phase fp) :main (fighter-move fp) j2c (fighter-sf fp) 8   ;  charged J2 and
                             (fighter-charge-mult fp) 1.7f0)                                                             ;  back: no sim step
                       (prog1 (cons-per "west-flame" (yama-west-flame *p1* fp (model *p1*) j2c))                         ;  runs between)
                         (setf (fighter-state fp) st (fighter-phase fp) ph (fighter-move fp) mv0 (fighter-sf fp) sf0
                               (fighter-charge-mult fp) cm0)))                                                       ;  the grab, the throw)
                     (cons-per "cracks" (yama-stance-look pos yaw an-m))
                     (cons-per "smear" (vfx-smear tr sm 3))
                     (cons-per "planted" (draw-planted-weapon :zanka px pz yaw :ahead (first sp) :right (second sp)))   ; (art K3)
                     (cons-per "burn" (%ya-blade-burn tp bs 9))
                     (cons-per "plant-spot" (yama-planted *p1* fp mv-as2))
                     (cons-per "dead x8" (progn (fresh) (dotimes (j 8) (ya-dead :sk-grab 10))))
                     (cons-per "east-void" (yama-higashi-look *p1* *p2* 90))   ; (art K4: the Kikon cinematics' looks, yama-cine.lisp)
                     (cons-per "east-open" (yama-higashi-look *p1* *p2* 86))   ; (art K5: the tear opening, then at full)
                     (cons-per "east-full" (yama-higashi-look *p1* *p2* 120))
                     (cons-per "west-ash" (yama-nishi-look *p1* *p2* 46))
                     (cons-per "west-leap" (yama-nishi-look *p1* *p2* 58))   ; (§29: the garb at the stance's size, then
                     (cons-per "west-step1" (yama-nishi-look *p1* *p2* 116))   ;  each footfall's step up, ring and print)
                     (cons-per "west-step2" (yama-nishi-look *p1* *p2* 165))
                     (cons-per "west-walk" (yama-nishi-look *p1* *p2* 140))   ; (§29.3: the walk at 南's pace, the lean set)
                     (cons-per "west-step3" (yama-nishi-look *p1* *p2* 214))
                     (cons-per "west-pass" (yama-nishi-look *p1* *p2* 220))
                     (cons-per "west-column" (yama-nishi-look *p1* *p2* 232))
                     (cons-per "south-dead" (yama-minami-look *p1* *p2* 90))
                     (cons-per "south-pile" (yama-minami-look *p1* *p2* 130))
                     (cons-per "south-burst" (yama-minami-look *p1* *p2* 150))))))
    (setf (aref *ya-as4-hit* 0) -1 (aref *ya-as4-hit* 1) -1)
    (ya-dead-reset)
    (log-msg "yama garb: the Kikon wings flat at ~,1f deg off upright (~,1f above the horizontal; want >= 65 / <= 25)"   ; (§29.6)
             (* 57.29578 (garb-tilt-angle 1f0)) (- 90 (* 57.29578 (garb-tilt-angle 1f0))))))

(defun yama-shikai-consing ()
  "Debug 87449 (art S1, DUEL_YAMA_CORE §22): bytes consed by 10 draws of each Shikai / 爆炎 look (0 B each wanted), per tier, on stand-in
hazards mid-life (their data's :heat 0 / 12 / 25: T0 / T1 / T2; the ring by its hits left), the moves' looks at their frames, the blade's
fire at rest, in a move, in an NS at T2 and in 爆炎, the tier readers, the smear's look 4, and the stances' fire per tier (art S3). %YA-CONS-PER's
rows."
  (flet ((hz (kind z size life age &key (delay 0) (heat 0f0) (hits 1) owner track)
           (make-hazard :kind kind :x 0f0 :z z :size size :life life :age age :delay delay :hits-left hits :owner owner
                        :data (list :hot 9999 :x 1f0 :heat heat :track track))))
    (let* ((sp (list (hz :wave -4f0 1f0 34 15) (hz :wave -4f0 1f0 34 15 :heat 12f0) (hz :wave -4f0 1f0 34 15 :heat 25f0)))
           (ln (list (hz :wave -5f0 0.6f0 33 10) (hz :wave -5f0 0.6f0 33 10 :heat 12f0) (hz :wave -5f0 0.6f0 33 10 :heat 25f0)))
           (cl (list (hz :ya-col -5f0 1.2f0 30 3) (hz :ya-col -5f0 1.2f0 30 3 :heat 12f0) (hz :ya-col -5f0 1.2f0 30 3 :heat 25f0)))
           (tell (hz :ya-col -5f0 1.2f0 30 0 :delay 5))
           (tn (list (hz :wave -4f0 1.75f0 48 20) (hz :wave -4f0 1.75f0 48 20 :heat 12f0) (hz :wave -4f0 1.75f0 48 20 :heat 25f0)))
           (rg (list (hz :ya-ring -4f0 1.6f0 90 30 :hits 2) (hz :ya-ring -4f0 1.6f0 90 30 :hits 1) (hz :ya-ring -4f0 1.6f0 90 30 :hits 0)))
           (dm (list (hz :ya-dome -4f0 1.6f0 40 6) (hz :ya-dome -4f0 1.6f0 40 6 :heat 12f0) (hz :ya-dome -4f0 1.6f0 40 6 :heat 25f0)))
           (own (hz :wave -4f0 1f0 34 15 :owner *p1*))
           (pos (pos-of *p1*)) (yaw (yaw-of *p1*)) (fp (fighter *p1*))
           (tp (let ((v (make-f32 3))) (setf (aref v 0) 0.4f0 (aref v 1) 1.2f0 (aref v 2) -0.6f0) v))
           (bs (let ((v (make-f32 3))) (setf (aref v 0) 0.3f0 (aref v 1) 1.0f0 (aref v 2) -0.1f0) v))
           (tr (let ((tr (make-trail))) (dotimes (i 5 tr) (trail-push tr 0f0 1f0 (- -0.3f0 (* 0.1f0 i)) (* 0.25f0 i) 1.5f0 -1.2f0))))
           (sm (make-f32 12)) (rows nil))
      (macrolet ((tiers (name f l)                     ; (three direct calls, each row's name made at expansion)
                   `(progn ,@(loop for i below 3
                                   collect `(let ((h (nth ,i ,l))) (push (%ya-cons-per ,(format nil "~a-~d" name i) (,f h 0.016f0)) rows))))))
        (tiers "spiral-t" yama-spiral-look sp) (tiers "lance-t" yama-lance-look ln) (tiers "column-t" yama-column-look cl)
        (push (%ya-cons-per "column-tell" (yama-column-look tell 0.016f0)) rows)
        (tiers "tornado-t" yama-tornado-look tn) (tiers "ring-hits" yama-ring-look (reverse rg)) (tiers "dome-t" yama-dome-look dm))
      (let ((j1r0 (hz :ya-ring -4f0 1.6f0 90 1 :hits 2)) (j1r2 (hz :ya-ring -4f0 1.6f0 90 30 :hits 2 :heat 25f0))   ; (batch J1: the
            (j1d0 (hz :ya-dome -4f0 1.6f0 40 0)) (j1d1 (hz :ya-dome -4f0 1.6f0 40 1 :heat 25f0))                    ;  rising pillars, the
            (j1d3 (hz :ya-dome -4f0 1.6f0 40 3)) (j1d4 (hz :ya-dome -4f0 1.6f0 40 4 :heat 25f0))                    ;  closed dome, the
            (j1l0 (hz :wave -5f0 0.6f0 33 0)))                                                                     ;  boom, the flash; never named D0 / F0 / N0: %YA-CONS-PER binds those)
        (push (%ya-cons-per "ring-rise" (yama-ring-look j1r0 0.016f0)) rows)
        (push (%ya-cons-per "ring-t2" (yama-ring-look j1r2 0.016f0)) rows)
        (push (%ya-cons-per "dome-seethe" (yama-dome-look j1d0 0.016f0)) rows)
        (push (%ya-cons-per "dome-seethe-t2" (yama-dome-look j1d1 0.016f0)) rows)
        (push (%ya-cons-per "dome-boom" (yama-dome-look j1d3 0.016f0)) rows)
        (push (%ya-cons-per "dome-boom-t2" (yama-dome-look j1d4 0.016f0)) rows)
        (push (%ya-cons-per "lance-flash" (yama-lance-look j1l0 0.016f0)) rows))
      (push (%ya-cons-per "spiral-owned" (yama-spiral-look own 0.016f0)) rows)
      (push (%ya-cons-per "blade-rest" (yama-blade-fire tp bs 0 0 0.016f0)) rows)
      (push (%ya-cons-per "blade-move" (yama-blade-fire tp bs 1 0 0.016f0)) rows)
      (push (%ya-cons-per "blade-ns-t2" (yama-blade-fire tp bs 2 2 0.016f0)) rows)
      (push (%ya-cons-per "blade-blaze" (yama-blade-fire tp bs 11 2 0.016f0)) rows)
      (push (%ya-cons-per "pommel" (%ya-pommel-fire tp)) rows)
      (push (%ya-cons-per "nade-cut" (yama-sk-moves pos yaw 1 14 0)) rows)
      (push (%ya-cons-per "nade-seam-t0" (yama-sk-moves pos yaw 1 42 0)) rows)
      (push (%ya-cons-per "nade-seam-t2" (yama-sk-moves pos yaw 1 42 2)) rows)
      (push (%ya-cons-per "halo" (yama-sk-moves pos yaw 2 18 0)) rows)
      (push (%ya-cons-per "halo-blaze" (yama-sk-moves pos yaw 3 18 2)) rows)
      (push (%ya-cons-per "as1" (yama-sk-moves pos yaw 5 11 0)) rows)
      (push (%ya-cons-per "n2a-fan-sweep" (yama-sk-moves pos yaw 9 19 0)) rows)   ; (art batch B: NS2a's flame fan per tier, and burning out)
      (push (%ya-cons-per "n2a-fan-t0" (yama-sk-moves pos yaw 9 20 0)) rows)
      (push (%ya-cons-per "n2a-fan-t1" (yama-sk-moves pos yaw 9 20 1)) rows)
      (push (%ya-cons-per "n2a-fan-t2" (yama-sk-moves pos yaw 9 20 2)) rows)
      (push (%ya-cons-per "n2a-fan-out" (yama-sk-moves pos yaw 9 26 2)) rows)
      (push (%ya-cons-per "tier-move" (ya-sk-tier *p1* fp (fighter-move fp))) rows)
      (push (%ya-cons-per "tier-hz" (ya-hz-tier own)) rows)
      (push (%ya-cons-per "smear-4" (vfx-smear tr sm 4)) rows)
      (push (%ya-cons-per "stance-1-t0" (yama-stance-fire tp bs 1 0)) rows)   ; (art S3: the stances' fire per tier, the stance tier)
      (push (%ya-cons-per "stance-1-t1" (yama-stance-fire tp bs 1 1)) rows)
      (push (%ya-cons-per "stance-1-t2" (yama-stance-fire tp bs 1 2)) rows)
      (push (%ya-cons-per "stance-2-t0" (yama-stance-fire tp bs 2 0)) rows)
      (push (%ya-cons-per "stance-2-t1" (yama-stance-fire tp bs 2 1)) rows)
      (push (%ya-cons-per "stance-2-t2" (yama-stance-fire tp bs 2 2)) rows)
      (push (%ya-cons-per "stance-3-ember" (yama-stance-fire tp bs 3 0)) rows)   ; (J3, §28.5)
      (push (%ya-cons-per "tier-stance" (ya-stance-tier *p1* nil)) rows)
      (let ((jm (model-joints (model *p1*))) (yaw (yaw-of *p1*)) (mv-ik (kit-move (find-kit :yamamoto :blaze) :ya-b-j3))
            (en0 (hz :ya-col 0f0 2.5f0 30 0 :heat 25f0)) (en (hz :ya-col 0f0 2.5f0 30 8 :heat 25f0)) (en-end (hz :ya-col 0f0 2.5f0 30 24 :heat 25f0))   ; (art batch B: the disc)
            (tl (hz :wave -4f0 1.75f0 48 20 :heat 25f0 :owner *p1* :track 60f0)))
        (push (%ya-cons-per "scars-100" (yama-scar-glow jm 100f0)) rows)   ; (art S4: 爆炎's looks)
        (push (%ya-cons-per "scars-60" (yama-scar-glow jm 60f0)) rows)
        (push (%ya-cons-per "scars-20" (yama-scar-glow jm 20f0)) rows)
        (push (%ya-cons-per "scars-5" (yama-scar-glow jm 5f0)) rows)
        (push (%ya-cons-per "ennetsu-rise" (yama-ennetsu-look en0 0.016f0)) rows)
        (push (%ya-cons-per "ennetsu-full" (yama-ennetsu-look en 0.016f0)) rows)
        (push (%ya-cons-per "ennetsu-dying" (yama-ennetsu-look en-end 0.016f0)) rows)
        (push (%ya-cons-per "tornado-lean" (yama-tornado-look tl 0.016f0)) rows)
        (push (%ya-cons-per "ring-close" (yama-ring-close *p1* 13)) rows)
        (push (%ya-cons-per "blaze-in-edge" (yama-blaze-in-look tp bs 8)) rows)
        (push (%ya-cons-per "blaze-in-ring" (yama-blaze-in-look tp bs 14)) rows)
        (push (%ya-cons-per "fist" (%ya-fist-fire tp yaw 10)) rows)
        (push (%ya-cons-per "nade-seam-8m" (yama-sk-moves pos yaw 8 44 2)) rows)
        (push (%ya-cons-per "smear-5" (vfx-smear tr sm 5)) rows)
        (push (%ya-cons-per "plant-spot-ikkotsu" (yama-planted *p1* fp mv-ik)) rows))
      (macrolet ((cine (name f frames)                 ; (art S5: the Kikon cinematics' looks at their busiest frames, P1 and P2 as the
                   `(progn ,@(loop for cf in frames      ;  actors, in P1's form; each run with the whole batch, as a frame)
                                   collect `(push (%ya-cons-per ,(format nil "~a-~d" name cf) (,f *p1* *p2* ,cf) t) rows)))))
        (cine "shiranui" yama-shiranui-look (30 50 60 100 118 124 130 160))   ; (124: the columns and the tornado, §28.5)
        (cine "ennetsu" yama-ennetsu-cine-look (26 50 62 100 114 132 150 168))
        (cine "nadegiri" yama-nadegiri-cine-look (40 86 100 130))   ; (re-timed, §28.5)
        (push (%ya-cons-per "s5-cine-p" (yama-s5-cine-p *p1*)) rows))
      (log-msg "yama shikai consing (10 draws, B): ~{~a~^, ~}" (nreverse rows)))))
