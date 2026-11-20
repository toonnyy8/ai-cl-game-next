;;;; yama-look.lisp — YAMAMOTO's Bankai looks, art batch K1 (docs/duel/DUEL_YAMA_CORE.md §15.2.1 L1-L11, §16): the dead of 南 (the hands, the
;;;; swarm, the bone wall and its fall, the pile), KYOKUJITSUJIN's void line, KYOKKO's lance, 西's flare and armour, 北's band. Each look sits
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

;;; ---------------------------------------------------------------- L3 the bone wall (:ya-wall), L4 its fall, L5 the pile
(defmacro %ya-rampart (x z yaw rise k seed)
  "The bone wall (L3) centred at (X Z) across YAW: four piles of the dead (charcoal torsos, a skull on top with red sockets, red rib
hairlines) at -1.35 / -0.45 / 0.45 / 1.35 m across, each 0.5 m wide, so it spans the hazard's 3.2 m with three 0.4 m gaps (the centre one
straight ahead: the behind camera sees the foe through it); 1.1-1.4 m high (RISE x: 0 sunk .. 1 standing). Single-float forms; 0 B."
  `(let* ((%fx (- (f-sin ,yaw))) (%fz (- (f-cos ,yaw))) (%acx (- %fz)) (%acz %fx) (%ri ,rise) (%k ,k))
     (declare (single-float %fx %fz %acx %acz %ri %k))
     (when (> %ri 0.02f0)
       (toon-ground-seg (- ,x (* 1.6f0 %acx)) (- ,z (* 1.6f0 %acz)) (+ ,x (* 1.6f0 %acx)) (+ ,z (* 1.6f0 %acz)) 0.011f0 0.16f0 1f0 1f0
                        (+ ,seed 5f0) 0.3f0 (toon-a +pal-ink+ (* 0.9f0 %k)))
       (dotimes (%i 4)
         (let* ((%f (i->f %i)) (%u (- (* 0.9f0 %f) 1.35f0)) (%h (* %ri (if (or (= %i 0) (= %i 3)) 1.4f0 1.15f0)))
                (%bx (+ ,x (* %u %acx))) (%bz (+ ,z (* %u %acz))) (%sk (- %h 0.13f0)))
           (declare (single-float %f %u %h %bx %bz %sk))
           (fx-disc %bx (* 0.24f0 %h) %bz 0.27f0 0.2f0 (+ ,seed %f) +pal-black-smoke+ %k)            ; the heap's base
           (fx-disc (+ %bx (* 0.08f0 %acx)) (* 0.55f0 %h) (+ %bz (* 0.08f0 %acz)) 0.22f0 0.2f0 (+ ,seed %f 3f0) +pal-ink+ %k)   ; a torso
           (fx-crescent (- %bx (* 0.15f0 %acx)) (* 0.5f0 %h) (- %bz (* 0.15f0 %acz)) (+ %bx (* 0.2f0 %acx)) (* 0.52f0 %h) (+ %bz (* 0.2f0 %acz))
                        %bx (* 0.58f0 %h) %bz 0.008f0 :lens 0.05f0 (+ ,seed %f 6f0) +pal-blood+ %k :push 0.3f0)   ; a rib's red edge
           (dotimes (%b 2)                               ; two bones jutting out of the heap
             (let* ((%sd (if (= %b 0) -1f0 1f0)) (%y0 (* %h (+ 0.35f0 (* 0.3f0 (hash01 (+ %f %sd) ,seed))))))
               (declare (single-float %sd %y0))
               (fx-crescent %bx %y0 %bz (+ %bx (* %sd 0.42f0 %acx)) (+ %y0 (* 0.25f0 %h)) (+ %bz (* %sd 0.42f0 %acz))
                            (+ %bx (* %sd 0.2f0 %acx)) (+ %y0 0.18f0) (+ %bz (* %sd 0.2f0 %acz)) 0.03f0 :lens 0.1f0 (+ ,seed %f %sd 11f0)
                            +pal-ink+ %k :push 0.2f0)))
           (fx-disc %bx %sk %bz 0.13f0 0.08f0 (+ ,seed %f 8f0) +pal-ink+ %k :push 0.15f0)              ; the skull
           (fx-disc (- %bx (* 0.045f0 %acx)) (+ %sk 0.02f0) (- %bz (* 0.045f0 %acz)) 0.022f0 0f0 (+ ,seed %f 9f0) +pal-blood+ %k :push 0.3f0)
           (fx-disc (+ %bx (* 0.045f0 %acx)) (+ %sk 0.02f0) (+ %bz (* 0.045f0 %acz)) 0.022f0 0f0 (+ ,seed %f 10f0) +pal-blood+ %k :push 0.3f0))))))

(defun-fast yama-wall-look (hz rdt)
  "南's bone wall (L3: the hitless :ya-wall, 1.2 m ahead, half width 1.6, *YA-WALL-LIFE* frames): the rampart standing (it rose over NS3c's
startup: YAMA-BK-MOVES), crumbling into ash over its last 10 f. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (left (- (hazard-life hz) (hazard-age hz)))
         (u (f-clamp (/ (i->f left) 10f0) 0f0 1f0)) (seed (+ x z)))
    (declare (single-float x z yaw u seed) (fixnum left))
    (%ya-rampart x z yaw (+ 0.3f0 (* 0.7f0 u)) (* 0.98f0 u) seed)
    (when (< left 12)
      (dotimes (i (n-of 60f0 rdt))
        (let* ((v (rnd-range -1.6f0 1.6f0)))
          (declare (single-float v))
          (%t-blob (+ x (* v (f-cos yaw))) (rnd-range 0.2f0 1.2f0) (- z (* v (f-sin yaw))) (rnd-range -0.3f0 0.3f0) (rnd-range 0.2f0 0.8f0)
                   (rnd-range -0.3f0 0.3f0) (rnd-range 0.6f0 1.1f0) (rnd-range 0.06f0 0.12f0) -0.1f0 0.25f0 +pal-ash+))))
    nil))

(defun-fast yama-fall-look (hz rdt)
  "南's wall falling (L4: NS3c's hit, a disc of HAZARD-SIZE 3 m ahead, hot 4 f): ten bones and skulls toppling from the wall's crest (1.8 m
nearer him, 1.3 m up) onto the disc in 4 f, lying there till they erode by 30; an ASH ring opening to the disc's edge, an ember hairline
on it while it is hot. A look."
  (declare (single-float rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (u (f-min 1f0 (/ (i->f (1+ age)) 4f0)))
         (k (f-clamp (* 0.98f0 (/ (i->f (- 30 age)) 20f0)) 0f0 0.98f0)) (seed (+ (* 2f0 x) z)))
    (declare (single-float x z r yaw fx fz px pz u k seed) (fixnum age))
    (%tring x 0f0 z (* r u) 0.07f0 +pal-ash+ k (+ seed 1f0))
    (when (< age 4) (%tring x 0.006f0 z r 0.02f0 +pal-ember+ 0.9f0 (+ seed 2f0)))
    (dotimes (i 10)
      (let* ((f (i->f i)) (sx (* 1.4f0 (- (* 2f0 (hash01 f seed)) 1f0)))
             (a (* 6.2832f0 (hash01 (+ f 3f0) seed))) (rr (* 0.9f0 r (f-sqrt (hash01 (+ f 5f0) seed))))
             (x0 (+ x (* -1.8f0 fx) (* sx px))) (z0 (+ z (* -1.8f0 fz) (* sx pz)))
             (x1 (+ x (* rr (f-cos a)))) (z1 (+ z (* rr (f-sin a)))) (y (+ 0.1f0 (* 1.2f0 (- 1f0 u) (- 1f0 u))))
             (sk (< i 3)))
        (declare (single-float f sx a rr x0 z0 x1 z1 y))
        (fx-disc (+ x0 (* u (- x1 x0))) (if sk (+ y 0.04f0) y) (+ z0 (* u (- z1 z0))) (if sk 0.13f0 0.16f0) 0.2f0 (+ seed f)
                 (if sk +pal-ink+ +pal-black-smoke+) k)))
    (when (< age 8)
      (dotimes (i (n-of 50f0 rdt))
        (let* ((a (rnd-range 0f0 6.2832f0)) (rr (rnd-range 0f0 r)))
          (declare (single-float a rr))
          (%t-blob (+ x (* rr (f-cos a))) 0.1f0 (+ z (* rr (f-sin a))) (* 1.5f0 (f-cos a)) (rnd-range 0.3f0 1.2f0) (* 1.5f0 (f-sin a))
                   (rnd-range 0.5f0 0.8f0) (rnd-range 0.12f0 0.25f0) -0.2f0 0.25f0 +pal-ash+))))
    nil))

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

;;; ---------------------------------------------------------------- L10 北's band (NS 北: the :wave)
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

(defun-fast yama-north-look (hz rdt)
  "北's band (L10, the NS wave: 2 x HAZARD-SIZE = 4 m wide, 20 m/s): one white band rising diagonally across its whole width (0.2 m up at
his left end to 2.0 m at his right, 0.64 m tall: the passing cut, ~25 deg; the gaps under and over it keep the foe in view), an orange
flame rim above and below it (北 is one of the two places with fire, D4), an INK band just behind; a scorched ASH strip on the floor from
where it started. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5)))
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0))
         (trav (* 0.3333f0 (i->f age))))                  ; (20 m/s, 北's wave only: HAZARD-SPEED's read boxed a float, 16 B a draw)
    (declare (single-float x z w yaw fx fz px pz dr sd k trav) (fixnum age life))
    (toon-ground-seg (- x (* trav fx)) (- z (* trav fz)) x z 0.012f0 (* 0.5f0 w) 0.2f0 1f0 (+ 3f0 sd) 0.3f0 (toon-a +pal-ash+ (* 0.5f0 k)))
    (toon-ground-seg (- x (* trav fx)) (- z (* trav fz)) x z 0.014f0 (* 0.3f0 w) 0.2f0 1f0 (+ 4f0 sd) 0.2f0 (toon-a +pal-ink+ (* 0.8f0 k)))
    (%ya-band (+ x (* 0.2f0 fx)) (+ z (* 0.2f0 fz)) px pz (+ w 0.1f0) 0.05f0 1.8f0 0.95f0 +pal-ink+ k (+ 40f0 sd))   ; the ink behind it
    (%ya-band x z px pz w 0.12f0 1.8f0 0.8f0 +pal-flame+ k (+ 45f0 sd))                     ; the flame rims (above and below the white)
    (%ya-band (- x (* 0.03f0 fx)) (- z (* 0.03f0 fz)) px pz w 0.2f0 1.8f0 0.64f0 +pal-hit+ k (+ 50f0 sd))   ; the white band
    (%light x 1.3f0 z 1f0 0.55f0 0.3f0 6f0 (* 2f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- 殘日獄衣's mantle (batch Z1, DUEL_YAMA_CORE §27; L8 since then)
;;; One closed flame mantle round him, traced from the user's reference image (2026-11-20; round 2 after the lead's review, §27.6): narrow
;;; at the ankles (the sandals show), a rounded lobe curling out at each knee-hip, two wings of three swept lobes rising outward (the
;;; outer the longest, its tip hooked back), a column of five tall tongues over his head to 1.47x his height, apart from the wings by a
;;; valley at the neck. The outline is a smooth Catmull-Rom curve through keys in metres on a cylindrical billboard: U along the camera's
;;; horizontal right from his vertical axis, V up from the floor (so it reads the same from the front, the side and behind). Every outline
;;; point has an anchor on a skeleton tree inside the shape (the trunk, the hem lobes' branches, the wing spines and the lobes'); a fill
;;; is the strip between the anchor chain and the outline (a walk, (:walk au av), keeps the outline point and moves its anchor along the
;;; tree, so the anchor chain runs the tree's edges and the strips leave no gap). Flat manga bands (F-Q1, STYLE_STORM_DESIGN §15): a
;;; yellow-white fill (FIRE's core), a white-hot band deeper than 0.3 m from the outline (HIT), an orange band 0.05 m inside the outline
;;; (FLAME's body, its outer edge feathered by the soft-flame pass), a clean white rim (HIT, no boil); curved flame strokes licking up
;;; inside (FIRE / EMBER comets), white sparks. The sheet sits behind his body on the view ray; at full size a see-through front layer
;;; (*YA-SKIRT-KEYS*, glass 3) wraps his torso and legs below the neck. Z-Q2: from behind the fill turns see-through (glass 2), the rim
;;; and the strokes stay. Without MSAA a glass shape would be opaque: there the hollow drops the fill and the front layer is not drawn.
(defparameter *ya-mantle-keys*
  '((0.00 0.13 0.00 0.45 0.0) (0.17 0.13 0.00 0.45 0.0) (0.24 0.26 0.00 0.55 0.1)        ; the hem's edge above the sandals
    (0.34 0.36 0.12 0.57 0.3) (0.48 0.47 0.30 0.60 0.4) (0.58 0.60 0.42 0.65 0.6)        ; the lobe curling out at the knee-hip
    (0.64 0.78 0.50 0.77 0.8) (0.66 0.93 0.56 0.86 1.0) (0.62 1.01 0.56 0.86 1.0)        ;  its tip, hooked back in
    (0.53 0.99 0.53 0.82 0.8) (0.46 0.90 0.44 0.68 0.5)
    (:walk 0.40 0.62) (:walk 0.00 0.55)
    (0.36 1.08 0.00 1.00 0.3) (0.30 1.20 0.00 1.24 0.2) (:walk 0.00 1.42)                ; the notch under the wing
    (0.40 1.31 0.10 1.443 0.3) (0.66 1.43 0.60 1.56 0.4) (0.95 1.62 0.92 1.736 0.5)     ; the wing's underside, rising
    (1.20 1.82 1.20 1.869 0.7)
    (1.36 1.90 1.30 1.91 0.9) (1.48 1.95 1.30 1.91 1.0) (1.55 2.04 1.30 1.91 1.0)        ; the outer lobe's tip, 1.55 m out,
    (1.47 2.09 1.30 1.91 1.0) (1.36 2.06 1.30 1.91 0.9)                                    ;  hooked back over
    (1.25 2.08 1.22 1.877 0.7) (:walk 1.00 1.78)
    (1.14 2.16 1.01 1.92 0.8) (1.04 2.22 1.02 2.06 1.0) (0.92 2.16 1.01 1.95 0.8)        ; the middle lobe
    (0.82 1.98 1.00 1.78 0.5) (:walk 0.66 1.593)
    (0.76 2.04 0.68 1.75 0.8) (0.70 2.10 0.70 1.92 1.0) (0.62 2.02 0.68 1.75 0.8)        ; the inner lobe
    (0.48 1.80 0.66 1.593 0.4) (:walk 0.60 1.56) (:walk 0.00 1.42) (:walk 0.00 1.60)      ; the valley at the neck
    (0.48 2.00 0.30 1.80 0.6) (0.48 2.16 0.40 2.10 0.8) (0.43 2.33 0.42 2.16 1.0)        ; the column's outer tongue
    (0.36 2.18 0.38 2.04 0.8) (0.30 2.04 0.33 1.89 0.5)
    (:walk 0.24 1.76) (:walk 0.00 1.60) (:walk 0.00 1.80)
    (0.27 2.16 0.12 2.00 0.7) (0.21 2.34 0.20 2.14 1.0) (0.15 2.20 0.16 2.07 0.8)        ; its inner tongue
    (0.10 2.10 0.06 1.90 0.6) (:walk 0.00 1.80)
    (0.06 2.28 0.00 2.12 0.8) (0.00 2.42 0.00 2.20 1.0))                                  ; the centre tongue (1.47 x 1.65 m)
  "殘日獄衣's outline, the right half from the bottom centre up to the top centre (YA-MANTLE-SAMPLE mirrors it): (u v au av flex) an
outline key in metres (U out from his axis, V up), its anchor (AU AV) on the skeleton tree, FLEX how far it billows (0 the hem's edge
.. 1 a tip); (:walk au av) the same outline point with its anchor moved along the tree. Traced on the user's reference at its scale
(1.65 m tall, §27.6): the wing tips 1.55 m out (<= 1.9: the spec), the top 2.42 m (~1.4 x), the hem 0.13 m. Host-checked
(tests/duel-rules/art.lisp).")
(defparameter *ya-skirt-keys*
  '((0.00 0.13 0.00 0.40 0.0) (0.15 0.13 0.00 0.40 0.0) (0.22 0.30 0.00 0.45 0.1) (0.27 0.60 0.00 0.65 0.2)
    (0.30 0.90 0.00 0.90 0.3) (0.31 1.15 0.00 1.12 0.3) (0.30 1.32 0.00 1.25 0.4) (0.22 1.40 0.00 1.28 0.5)
    (0.13 1.37 0.00 1.28 0.4) (0.00 1.31 0.00 1.24 0.3))
  "The mantle's front layer at full size (*YA-MANTLE-KEYS*'s format): his torso and legs, 0.15 m at the ankle, 0.31 m at the hip and
chest, the shoulders at 1.40 m and a dip under the chin (1.31 m), so the head and beard show above it and his hands and blade beside it;
drawn see-through (glass 3) so his body shows dimly through.")

(defun ya-mantle-sample (keys sub)
  "The closed outline of a key table KEYS (*YA-MANTLE-KEYS*'s format): a list of (u v au av flex) from the bottom centre up the right side,
over the top and down the left side (the right half mirrored), SUB samples a key gap on a Catmull-Rom curve (the ends' neighbours their
mirror images: smooth across the axis), the anchors and the flex lerped; a walk adds a point at the same place with the next anchor. Pure."
  (let ((groups nil))
    (dolist (e keys)
      (if (eq (first e) :walk)
          (setf (second (first groups)) (append (second (first groups)) (list (list (second e) (third e)))))
          (push (list e (list (list (third e) (fourth e)))) groups)))
    (let* ((gv (coerce (nreverse groups) 'vector)) (n (length gv)) (out nil))
      (flet ((key (i) (cond ((< i 0) (let ((p (first (aref gv 1)))) (list (- (first p)) (second p))))   ; (the mirror images)
                            ((>= i n) (let ((p (first (aref gv (- n 2))))) (list (- (first p)) (second p))))
                            (t (first (aref gv i))))))
        (dotimes (i n)
          (destructuring-bind (p anc) (aref gv i)
            (dolist (a anc) (push (list (first p) (second p) (first a) (second a) (fifth p)) out))
            (when (< i (1- n))
              (destructuring-bind (q anq) (aref gv (1+ i))
                (let ((p0 (key (1- i))) (p3 (key (+ i 2))) (a0 (car (last anc))) (a1 (first anq)))
                  (loop for s from 1 below sub
                        do (let ((tt (/ s sub)))
                             (flet ((cr (k) (let ((x0 (nth k p0)) (x1 (nth k p)) (x2 (nth k q)) (x3 (nth k p3)))
                                              (* 0.5 (+ (* 2 x1) (* (- x2 x0) tt) (* (+ (* 2 x0) (* -5 x1) (* 4 x2) (- x3)) tt tt)
                                                        (* (+ (- x0) (* 3 x1) (* -3 x2) x3) tt tt tt))))))
                               (push (list (cr 0) (cr 1) (+ (first a0) (* tt (- (first a1) (first a0))))
                                           (+ (second a0) (* tt (- (second a1) (second a0)))) (+ (fifth p) (* tt (- (fifth q) (fifth p)))))
                                     out))))))))))
      (let ((right (nreverse out)))
        (append right (mapcar (lambda (e) (destructuring-bind (u v au av w) e (list (- u) v (- au) av w)))
                              (reverse (butlast (rest right)))))))))

(defun ya-mantle-table (keys sub)
  "YA-MANTLE-SAMPLE of KEYS as an f32vec, 8 floats a point: u v au av flex, the outward normal (nu nv: from the neighbours that stand
elsewhere, a walk's twin skipped) and the length along the outline (the billow's phase, the bands' noise coordinate). Built once at load."
  (let* ((pts (coerce (ya-mantle-sample keys sub) 'vector)) (n (length pts)) (tb (make-f32 (* 8 n))) (s 0.0))
    (flet ((other (i dir) (let ((p (aref pts i)))
                            (loop for k from 1 below n
                                  for q = (aref pts (mod (+ i (* dir k)) n))
                                  unless (and (= (first q) (first p)) (= (second q) (second p))) return q
                                  finally (return p)))))
      (dotimes (i n tb)
        (let* ((p (aref pts i)) (a (other i -1)) (b (other i 1))
               (tx (- (first b) (first a))) (ty (- (second b) (second a))) (l (max 1e-6 (sqrt (+ (* tx tx) (* ty ty))))))
          (when (> i 0)
            (let ((q (aref pts (1- i)))) (incf s (sqrt (+ (expt (- (first p) (first q)) 2) (expt (- (second p) (second q)) 2))))))
          (loop for x in (list (first p) (second p) (third p) (fourth p) (fifth p) (/ ty l) (/ (- tx) l) s)
                for k from 0 do (setf (aref tb (+ (* 8 i) k)) (f32 x))))))))

(declaim (type f32vec *ya-mantle* *ya-skirt* *ya-mt-args* *ya-mt-buf*))
(defparameter *ya-mantle* (ya-mantle-table *ya-mantle-keys* 2) "The mantle's outline (YA-MANTLE-TABLE, 2 samples a key gap).")
(defparameter *ya-skirt* (ya-mantle-table *ya-skirt-keys* 3) "Its front layer's.")
(defvar *ya-mt-args* (make-f32 6) "YA-MANTLE's arguments: x z rx rz g k (YA-MANTLE-DRAW reads them: no boxed float).")
(defvar *ya-mt-buf* (make-f32 (* 4 256)) "The shaped points of the table being drawn: u v au av each (YA-MANTLE-DRAW).")
(assert (<= (floor (length *ya-mantle*) 8) 256))

(defmacro ya-mantle (x z rx rz g k)
  "Draw 殘日獄衣's mantle (YA-MANTLE-DRAW) at his feet (X Z), (RX RZ) his right (a unit), G its size (0 西's stance: the wings 0.60 m out,
the top 1.74 m; 1 full: the wings 1.55 m, the top 2.42 m, the front layer on), K its presence (0.98 whole; below 0.7 the fill erodes from
the outline in). Single-float forms, written into *YA-MT-ARGS*: 0 B."
  `(let ((%a *ya-mt-args*))
     (declare (type f32vec %a))
     (setf (aref %a 0) ,x (aref %a 1) ,z (aref %a 2) ,rx (aref %a 3) ,rz (aref %a 4) ,g (aref %a 5) ,k)
     (ya-mantle-draw)))

(defmacro %ya-mt-at ((px py pz) u v d &body body)
  "Inside YA-MANTLE-DRAW: bind PX PY PZ to the mantle point (U V) moved D m along the view ray (+ away from the eye: behind his body; the
same screen point). Single-float forms."
  `(let* ((,px (+ x (* ,u lx))) (,py ,v) (,pz (+ z (* ,u lz)))
          (%dx (- ,px ex)) (%dy (- ,py ey)) (%dz (- ,pz ez)) (%l (/ ,d (f-max 1f-3 (f-hypot %dx %dy %dz)))))
     (declare (single-float ,px ,py ,pz %dx %dy %dz %l))
     (setf ,px (+ ,px (* %l %dx)) ,py (+ ,py (* %l %dy)) ,pz (+ ,pz (* %l %dz)))
     ,@body))

(defmacro %ya-mt-shape! (tbl n sw sh amp)
  "Inside YA-MANTLE-DRAW: *YA-MT-BUF* := TBL's N points and anchors shaped for the size (SW: the wings' and the column's spread and their
height over 1.3 m; SH: the hem lobes' reach out of the body's 0.24 m) and the outline billowing by its flex x AMP m: a smooth, slow sway out
and lick up whose phase runs along the outline (one wave across a lobe, never point by point), on the continuous effect clock (CLK)."
  `(dotimes (i ,n)
     (let* ((o (* 8 i)) (b (* 4 i)) (fi (* 1.3f0 (aref ,tbl (+ o 7)))) (w (* (aref ,tbl (+ o 4)) ,amp)))
       (declare (fixnum o b) (single-float fi w))
       (dotimes (h 2)
         (let* ((u (aref ,tbl (+ o h h))) (v (aref ,tbl (+ o h h 1))) (au (f-abs u))
                (up (f-clamp (/ (- v 0.95f0) 0.4f0) 0f0 1f0)) (up (* up up (- 3f0 (* 2f0 up))))   ; (a smoothstep: the hips .. the shoulders)
                (hem (* (if (< u 0f0) -1f0 1f0) (+ (f-min au 0.24f0) (* ,sh (f-max 0f0 (- au 0.24f0))))))
                (u2 (+ hem (* up (- (* u ,sw) hem)))) (v2 (if (> v 1.3f0) (+ 1.3f0 (* ,sw (- v 1.3f0))) v)))
           (declare (single-float u v au up hem u2 v2))
           (when (= h 0)
             (setf u2 (+ u2 (* w (f-sin (+ (* 1.9f0 clk) fi))))
                   v2 (+ v2 (* w (+ 0.5f0 (* 0.5f0 (f-sin (+ (* 2.6f0 clk) (* 0.8f0 fi)))))))))
           (setf (aref bf (+ b h h)) u2 (aref bf (+ b h h 1)) v2))))))

(defmacro %ya-mt-fill (n d in0 in1 pk uvx uvy)
  "Inside YA-MANTLE-DRAW: a flat band of the shaped points (*YA-MT-BUF*, N of them) D m along the view ray: the strip from IN0 m in from
the outline (0: the outline) to IN1 m in (each toward the point's anchor and never past it: a large IN1 reaches the anchors), a fan shape
whose heat runs 0 at an anchor .. 0.7 on the outline (the presence erodes it from the outline in), its UV (UVX UVY) on a palette spot (a
flat colour, no shade, no edge), PK the palette + presence + glass lane. 6 N vertices."
  `(with-fx-verts (dd o :toon (* 6 ,n))
     (dotimes (i ,n)
       (let* ((j (if (= i (1- ,n)) 0 (1+ i))) (i4 (* 4 i)) (j4 (* 4 j))
              (pu (aref bf i4)) (pv (aref bf (+ i4 1))) (qu (aref bf j4)) (qv (aref bf (+ j4 1)))
              (iau (- (aref bf (+ i4 2)) pu)) (iav (- (aref bf (+ i4 3)) pv)) (jau (- (aref bf (+ j4 2)) qu)) (jav (- (aref bf (+ j4 3)) qv))
              (id (f-max 1f-3 (f-hypot iau iav))) (jd (f-max 1f-3 (f-hypot jau jav)))
              (i0 (f-min 1f0 (/ ,in0 id))) (i1 (f-min 1f0 (/ ,in1 id))) (j0 (f-min 1f0 (/ ,in0 jd))) (j1 (f-min 1f0 (/ ,in1 jd))))
         (declare (fixnum j i4 j4) (single-float pu pv qu qv iau iav jau jav id jd i0 i1 j0 j1))
         (%ya-mt-at (ax ay az) (+ pu (* i1 iau)) (+ pv (* i1 iav)) ,d
           (%ya-mt-at (bx by bz) (+ pu (* i0 iau)) (+ pv (* i0 iav)) ,d
             (%ya-mt-at (cx cy cz) (+ qu (* j0 jau)) (+ qv (* j0 jav)) ,d
               (%ya-mt-at (gx gy gz) (+ qu (* j1 jau)) (+ qv (* j1 jav)) ,d
                 (vtx ax ay az ,uvx ,uvy (* 0.7f0 (- 1f0 i1)) 7f0 0f0 ,pk) (vtx bx by bz ,uvx ,uvy (* 0.7f0 (- 1f0 i0)) 7f0 0f0 ,pk)
                 (vtx cx cy cz ,uvx ,uvy (* 0.7f0 (- 1f0 j0)) 7f0 0f0 ,pk)
                 (vtx ax ay az ,uvx ,uvy (* 0.7f0 (- 1f0 i1)) 7f0 0f0 ,pk) (vtx cx cy cz ,uvx ,uvy (* 0.7f0 (- 1f0 j0)) 7f0 0f0 ,pk)
                 (vtx gx gy gz ,uvx ,uvy (* 0.7f0 (- 1f0 j1)) 7f0 0f0 ,pk)))))))))

(defmacro %ya-mt-band (tbl n d w0 w1 x0 x1 pk)
  "Inside YA-MANTLE-DRAW: a smooth band along the shaped outline (*YA-MT-BUF*, N points; their normals from TBL) from W0 to W1 m out along
the normal, D m along the view ray: an along shape, UV.X X0 .. X1 across it (|UV.X| near 1 is its silhouette: the soft-flame feather on a
flame palette), UV.Y the length along the outline, heat 1, no wobble (a clean line); PK the palette + presence + glass lane. 6 N vertices
(a walk's twin a zero-area quad)."
  `(with-fx-verts (dd o :toon (* 6 ,n))
     (dotimes (i ,n)
       (let* ((j (if (= i (1- ,n)) 0 (1+ i))) (i4 (* 4 i)) (j4 (* 4 j)) (io (* 8 i)) (jo (* 8 j))
              (pu (aref bf i4)) (pv (aref bf (+ i4 1))) (qu (aref bf j4)) (qv (aref bf (+ j4 1)))
              (inu (aref ,tbl (+ io 5))) (inv (aref ,tbl (+ io 6))) (jnu (aref ,tbl (+ jo 5))) (jnv (aref ,tbl (+ jo 6)))
              (is (* 0.8f0 (aref ,tbl (+ io 7)))) (js (* 0.8f0 (aref ,tbl (+ jo 7)))))
         (declare (fixnum j i4 j4 io jo) (single-float pu pv qu qv inu inv jnu jnv is js))
         (%ya-mt-at (ax ay az) (+ pu (* ,w0 inu)) (+ pv (* ,w0 inv)) ,d
           (%ya-mt-at (bx by bz) (+ pu (* ,w1 inu)) (+ pv (* ,w1 inv)) ,d
             (%ya-mt-at (cx cy cz) (+ qu (* ,w1 jnu)) (+ qv (* ,w1 jnv)) ,d
               (%ya-mt-at (gx gy gz) (+ qu (* ,w0 jnu)) (+ qv (* ,w0 jnv)) ,d
                 (vtx ax ay az ,x0 is 1f0 -17f0 0f0 ,pk) (vtx bx by bz ,x1 is 1f0 -17f0 0f0 ,pk) (vtx cx cy cz ,x1 js 1f0 -17f0 0f0 ,pk)
                 (vtx ax ay az ,x0 is 1f0 -17f0 0f0 ,pk) (vtx cx cy cz ,x1 js 1f0 -17f0 0f0 ,pk)
                 (vtx gx gy gz ,x0 js 1f0 -17f0 0f0 ,pk)))))))))

(defun-fast ya-mantle-draw ()
  "殘日獄衣's mantle from *YA-MT-ARGS* (YA-MANTLE). Z-Q2's solidity S from where the eye stands: 1 from the front round to 90 deg (the SIDE
camera stands 78 deg round), 0 from 100 deg (the match camera: 106 deg round at 2 m apart and closer, 112 at 4 m, 141 at 12 m; portrait
108; 87448's line). The outline is shaped for the size G and billows on the continuous effect clock; then, 0.5 m behind his body on the
view ray: the yellow-white fill, the white-hot band deeper than 0.3 m (full size only), the orange band 0.05 m inside the outline and
0.035 m outside it (feathered), the clean white rim (-0.018 .. +0.022 m x the size), 7-16 flame strokes licking up inside, 6-12 white sparks; at full
size the front layer 0.35 m in front of his body, see-through (glass 3) and fading with S; an orange light. Seen from behind (S < 0.9) the
fill turns see-through by S (glass 3, then 2 from S < 0.45; glass 1 read as an empty outline) in FIRE's red-orange body (the yellow,
half-covered, greys under the Bankai's grade), the white-hot band left out; the rim and strokes stay; without MSAA (a glass shape would be opaque) the hollow
drops the fills and the front layer is not drawn. Vertices (*YA-MANTLE* N points, *YA-SKIRT* M): 4 x 6 N + the strokes' 48 and the
sparks' 6 each + 6 M (87448's line). A look; 0 B."
  (let* ((ar *ya-mt-args*) (x (aref ar 0)) (z (aref ar 1)) (rx (aref ar 2)) (rz (aref ar 3)) (g (f-clamp (aref ar 4) 0f0 1f0))
         (k (aref ar 5)) (e (camera-eye *camera*)) (ex (aref e 0)) (ey (aref e 1)) (ez (aref e 2)) (rt (camera-right *camera*))
         (lx (aref rt 0)) (lz (aref rt 2)) (ll (f-hypot lx lz)) (hx (- ex x)) (hz (- ez z)) (hl (f-max 1f-3 (f-hypot hx hz)))
         (fr (/ (- (* rz hx) (* rx hz)) hl))            ; his facing (rz, -rx) . the way to the eye: 1 the camera in front, -1 behind
         (s (f-clamp (+ 1f0 (/ fr 0.17f0)) 0f0 1f0))
         (msaa (> (the fixnum *msaa-samples*) 1))
         (gl (cond ((>= s 0.9f0) 0f0) ((>= s 0.45f0) 96f0) (t 64f0)))   ; (the fills' glass lane, 32 x level: 3, then 2 behind)
         (fills (or msaa (= gl 0f0)))
         (clk (fx-clock)) (dr (drawing-no))
         (sw (+ 0.39f0 (* 0.61f0 g))) (sh (+ 0.6f0 (* 0.4f0 g))) (sz (+ 0.6f0 (* 0.4f0 g))) (amp (+ 0.025f0 (* 0.045f0 g)))
         (tb *ya-mantle*) (bf *ya-mt-buf*) (n (floor (length tb) 8)) (d 0.5f0)
         (nm (if (> g 0.5f0) 16 7)) (ns (if (> g 0.5f0) 12 6)))
    (declare (type f32vec ar e rt tb bf) (fixnum n nm ns)
             (single-float x z rx rz g k ex ey ez lx lz ll hx hz hl fr s gl clk dr sw sh sz amp d))
    (if (> ll 1f-4) (setf lx (/ lx ll) lz (/ lz ll)) (setf lx rx lz rz))
    (%ya-mt-shape! tb n sw sh amp)
    (when fills
      (if (= gl 0f0)
          (%ya-mt-fill n d 0f0 9f0 (toon-a +pal-fire+ k t) 0.15f0 -0.35f0)                       ; the yellow-white fill (FIRE's core)
          (%ya-mt-fill n d 0f0 9f0 (+ gl (toon-a +pal-fire+ k t)) -1f0 0.3f0))   ; see-through: FIRE's body (a yellow half-covered
                                                                                  ;  greys under the Bankai's spot-keep grade; the
                                                                                  ;  red-orange keeps its hue)
      (when (and (> g 0.5f0) (= gl 0f0))
        (%ya-mt-fill n (- d 0.01f0) (* 0.3f0 sz) 9f0 (+ gl (toon-a +pal-hit+ k t)) 0.15f0 -0.35f0))   ; the white-hot band
      (%ya-mt-band tb n (- d 0.02f0) (* -0.05f0 sz) (* 0.035f0 sz) 0f0 -1f0 (+ gl (toon-a +pal-flame+ k))))   ; orange (FLAME's body)
    (%ya-mt-band tb n (- d 0.03f0) (* -0.018f0 sz) (* 0.022f0 sz) -0.6f0 0.6f0 (toon-a +pal-hit+ k))   ; the white rim
    (dotimes (m nm)                                     ; the flame strokes: curved comets licking up, wide at the base, from inside
      (let* ((fm (i->f m)) (h2 (hash01 fm 5.3f0)) (h3 (hash01 fm 8.9f0))
             (i (mod (f->i (* (hash01 fm 3.7f0) (i->f n))) n)) (i4 (* 4 i))
             (ph (f-mod (+ (* 0.45f0 clk) h3) 1f0)) (tt (+ 0.2f0 (* 0.3f0 h2)))
             (au (aref bf (+ i4 2))) (av (aref bf (+ i4 3)))
             (mu (+ au (* tt (- (aref bf i4) au)))) (mv (+ av (* tt (- (aref bf (+ i4 1)) av)) (* 0.1f0 sz ph)))
             (hh (* sz (+ 0.28f0 (* 0.2f0 h3)) (- 1f0 (* 0.4f0 ph)))) (bend (* (if (evenp m) 0.35f0 -0.35f0) hh))
             (lean (* 0.25f0 hh (aref tb (+ (* 8 i) 5)))) (kk (* k (f-min 1f0 (* 4f0 (- 1f0 ph))))))
        (declare (single-float fm h2 h3 ph tt au av mu mv hh bend lean kk) (fixnum i i4))
        (%ya-mt-at (bx by bz) mu mv (- d 0.05f0)
          (%ya-mt-at (tx ty tz) (+ mu lean) (+ mv hh) (- d 0.05f0)
            (%ya-mt-at (cx cy cz) (+ mu (* 0.5f0 lean) bend) (+ mv (* 0.5f0 hh)) (- d 0.05f0)
              (fx-crescent tx ty tz bx by bz cx cy cz (* 0.075f0 sz) :comet 0f0 (+ fm (* 3f0 dr)) (if (= 0 (mod m 3)) +pal-ember+ +pal-fire+) kk
                           :push 0f0))))))
    (dotimes (m ns)                                     ; the sparks: off the outline, rising, smaller as they go
      (let* ((fm (i->f m)) (i (mod (f->i (* (hash01 fm 11.3f0) (i->f n))) n)) (i4 (* 4 i)) (o (* 8 i))
             (ph (f-mod (+ (* 0.5f0 clk) (hash01 fm 17.7f0)) 1f0)) (off (* sz (+ 0.06f0 (* 0.3f0 (hash01 fm 13.1f0)))))
             (su (+ (aref bf i4) (* off (aref tb (+ o 5))))) (sv (+ (aref bf (+ i4 1)) (* off (aref tb (+ o 6))) (* 0.6f0 sz ph))))
        (declare (single-float fm ph off su sv) (fixnum i i4 o))
        (%ya-mt-at (bx by bz) su sv (- d 0.06f0)
          (fx-disc bx by bz (* 0.022f0 sz (- 1.2f0 ph)) 0.2f0 (+ fm 40f0) +pal-hit+ k :push 0f0))))
    (when (and msaa (> g 0.5f0) (> s 0.02f0))           ; the front layer over his torso and legs, see-through (its presence x S)
      (let* ((tb *ya-skirt*) (n (floor (length tb) 8)) (ks (* k s)))
        (declare (type f32vec tb) (fixnum n) (single-float ks))
        (%ya-mt-shape! tb n 1f0 1f0 (* 0.5f0 amp))
        (%ya-mt-fill n -0.35f0 0f0 9f0 (+ 96f0 (toon-a +pal-fire+ ks t)) 0.15f0 -0.35f0)))
    (%light x 1.3f0 z 1f0 0.55f0 0.2f0 6f0 (* 2f0 k) 7))
  nil)

;;; ---------------------------------------------------------------- the moves' own looks (the :draw hook: YAMA-DRAW)
(defmacro %ya-flare (x z rx rz u k seed)
  "西's flare (L8; batch Z1, §27: the garb flares to the full mantle) at his feet (X Z), (RX RZ) his right, U frames after its pulse: the
mantle grows from the stance's size to full over 2 frames (YA-MANTLE); the molten ring on the burn's 2.0 m edge; a white-hot ring on the
pulse's first two frames. Before Z1: 14 orange tongues thrown out round him and two fans of ribbon wings 0.9 m out. Single-float forms;
0 B."
  `(let* ((%g (f-min 1f0 (/ (+ ,u 1f0) 3f0))) (%k ,k))
     (declare (single-float %g %k))
     (ya-mantle ,x ,z ,rx ,rz %g %k)
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

(defun-fast yama-bk-moves (pos yaw code sf rdt)
  "The Bankai moves' own looks at his feet POS facing YAW, frame SF of the move CODE (YAMA-DRAW's table): 1 KYOKKO's lance (L7, S20-22), 2
KYOKUJITSUJIN's slit and void line (L6, S18: the full 6 m at once as a ragged tear, YAMA-TEAR, held 20 f, then filled by ash), 3 AS1's
notch (L6, S10), 4 SHONETSU's two pulses (L8, f16 and f26), 5 / 6 the advance's / the throw's flare (L8, S14 / S12), 7 the bone wall
rising (L3, f6 to S18), 8 北's AS crescent (L10, S10). RDT: the frame's effect seconds (the ash). A look; 0 B."
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
      (4 (when (<= 16 sf 35) (%ya-flare x z px pz (i->f (if (< sf 26) (- sf 16) (- sf 26))) (if (< sf 26) (if (< sf 23) 0.98f0 0.6f0)
                                                                                         (f-clamp (* 0.98f0 (/ (i->f (- 36 sf)) 6f0)) 0f0 0.98f0))
                                   seed)))
      (5 (when (<= 14 sf 23) (%ya-flare x z px pz (i->f (- sf 14)) (f-clamp (* 0.98f0 (/ (i->f (- 24 sf)) 6f0)) 0f0 0.98f0) seed)))
      (6 (when (<= 12 sf 21) (%ya-flare x z px pz (i->f (- sf 12)) (f-clamp (* 0.98f0 (/ (i->f (- 22 sf)) 6f0)) 0f0 0.98f0) seed)))
      (7 (when (<= 6 sf 17)                              ; (from S18 the :ya-wall hazard draws it: YAMA-WALL-LOOK)
           (%ya-rampart (+ x (* 1.2f0 fx)) (+ z (* 1.2f0 fz)) yaw (/ (i->f (- sf 5)) 13f0) 0.98f0 (+ (* 1.2f0 fx) x z))))
      (8 (when (<= 10 sf 15)                             ; the crescent: from over his right shoulder down to his low left, its far edge 2.4 m
           (let* ((k (if (<= sf 12) 0.98f0 (* 0.98f0 (/ (i->f (- 16 sf)) 4f0))))
                  (ax (+ x (* 1.26f0 fx) (* 1.8f0 px))) (az (+ z (* 1.26f0 fz) (* 1.8f0 pz)))
                  (bx (+ x (* 1.26f0 fx) (* -1.8f0 px))) (bz (+ z (* 1.26f0 fz) (* -1.8f0 pz)))
                  (cx (+ x (* 3.54f0 fx))) (cz (+ z (* 3.54f0 fz))))
             (declare (single-float k ax az bx bz cx cz))
             (fx-crescent ax 2.0f0 az bx 0.35f0 bz cx 1.2f0 cz 0.26f0 :lens 0.08f0 (+ 60f0 sd) +pal-ink+ k :push 0.1f0)
             (fx-crescent ax 2.0f0 az bx 0.35f0 bz cx 1.2f0 cz 0.19f0 :lens 0.08f0 (+ 61f0 sd) +pal-flame+ k :push 0.15f0)
             (fx-crescent ax 2.0f0 az bx 0.35f0 bz cx 1.2f0 cz 0.12f0 :lens 0.06f0 (+ 62f0 sd) +pal-hit+ k :push 0.2f0)))))
    nil))

(defun yama-bk-code (mv)
  "YAMA-BK-MOVES's code for the Bankai move MV, or 0."
  (case (mv-name mv)
    (:ya-e-n1a 1) (:ya-e-n1c 2) (:ya-e-as1 3) (:ya-e-n2a 4) (:ya-e-n2b 5) (:ya-e-as2b 6) (:ya-e-n3c 7) (:ya-e-as4 8) (t 0)))

;;; ---------------------------------------------------------------- the pointer stances' looks (art K2, §17: YAMA-DRAW)
(defun-fast yama-stance-look (pos yaw an)
  "The Bankai's pointer stances, while his idle clip AN plays one (art K2, DUEL_YAMA_CORE §15.2.2 / §17), at his feet POS facing YAW:
:YA-ST-NISHI 西's garb at rest (L8, the user's D4: 西 has fire; batch Z1, §27 Z-Q1: 殘日獄衣's mantle small, YA-MANTLE at size
0.08 x the breath: the wings 0.60 m out, the top 1.74 m), breathing on the effect clock's twos (2.4 s, as the clip; the clip's own
time boxed a float; before Z1: ten orange tongues to the knee and two small wings of two ribbons);
:YA-ST-MINAMI 南's faint ember cracks (six thin ink cracks out to 0.45-0.7 m with ember cores pulsing with the same breath, no ring).
東 has the blade's smoke thread only (YAMA-DRAW). A look; 0 B."
  (declare (type f32vec pos) (single-float yaw))
  (let* ((c (anim-clip an)) (nm (and c (clip-name c))))
    (when (or (eq nm :ya-st-nishi) (eq nm :ya-st-minami))
      (let* ((x (aref pos 0)) (z (aref pos 2)) (seed (+ (* 3f0 x) z))
             (b (+ 0.5f0 (* 0.5f0 (f-sin (* 2.618f0 (fx-clock)))))))   ; the breath 0..1 (2.4 s, the stance clips' loop)
        (declare (single-float x z seed b))
        (if (eq nm :ya-st-minami)
            (dotimes (i 6)                               ; six thin cracks out from under his feet, no ring (faint: not L1's tell)
              (let* ((f (i->f i)) (a (+ (* 1.0472f0 f) (hash01 f seed))) (co (f-cos a)) (si (f-sin a))
                     (r2 (+ 0.45f0 (* 0.25f0 (hash01 f 3.1f0)))))
                (declare (single-float f a co si r2))
                (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* r2 co)) (+ z (* r2 si)) 0.01f0 0.022f0 1f0 0.3f0
                                 (+ seed f) 0.2f0 (toon-a +pal-ink+ 0.6f0))
                (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* 0.85f0 r2 co)) (+ z (* 0.85f0 r2 si)) 0.013f0 0.008f0
                                 0.3f0 0.3f0 (+ seed f 9f0) 0.1f0 (toon-a +pal-ember+ (* 0.6f0 (+ 0.45f0 (* 0.4f0 b)))))))
            (let* ((px (f-cos yaw)) (pz (- (f-sin yaw)))   ; (his right, as YAMA-BK-MOVES's (- fz) fx)
                   (clk (fx-clock)) (bq (+ 0.5f0 (* 0.5f0 (f-sin (* 2.618f0 (- clk (f-mod clk 0.083333f0))))))))   ; (the breath on twos)
              (declare (single-float px pz clk bq))
              (unless (let ((c *cine*)) (and c (eq (cine-name c) 'yama-nishi-cine)))   ; (the 西 Kikon draws the full one, then gutters it out)
                (ya-mantle x z px pz (* 0.08f0 bq) 0.9f0)))))))   ; the small mantle (Z-Q1, §27), breathing 8 % of the way to full
  nil)

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
           (dr (drawing-no)) (bx (aref base 0)) (by (aref base 1)) (bz (aref base 2))
           (dx (- (aref tip 0) bx)) (dy (- (aref tip 1) by)) (dz (- (aref tip 2) bz)) (seed (+ (* 3f0 bx) bz)))
      (declare (single-float k dr bx by bz dx dy dz seed))
      (dotimes (i 5)
        (let* ((f (i->f i)) (u (+ 0.2f0 (* 0.19f0 f))) (h (* (+ 0.32f0 (* 0.08f0 f)) (+ 0.75f0 (* 0.5f0 (hash01 (+ f dr) seed))))))
          (declare (single-float f u h))
          (%tongue (+ bx (* u dx)) (+ by (* u dy)) (+ bz (* u dz)) (* -0.25f0 dx h) h (* -0.25f0 dz h) 0.08f0 +pal-flame+ k
                   (+ seed f dr) (+ dr f) 0.03f0 :segs 4)))))
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
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (drawing-no))
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0))
         (tail (f-min 2.5f0 (* (i->f age) (/ +ya-spiral-speed+ 60f0)))) (len (+ +ya-wave-half+ tail))
         (hx (+ x (* +ya-wave-half+ fx))) (hz2 (+ z (* +ya-wave-half+ fz)))
         (rv (* 0.75f0 hf)) (yc (+ 0.2f0 rv)) (spin (* 1.5708f0 dr)) (seed (* 7f0 yaw)))
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
    (dotimes (st 2)                                    ; the two strands, wound round the axis (they turn on twos)
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
      (let* ((f (i->f j)) (an (+ (* 1.0472f0 f) (* 0.5f0 spin))) (l (* (+ 0.32f0 (* 0.18f0 (hash01 (+ f dr) 4.7f0))) (+ 0.5f0 (* 0.5f0 hf))))
             (ca (f-cos an)) (sa (f-sin an)))
        (declare (single-float f an l ca sa))
        (when (<= (hash01 f 6.1f0) hf)
          (%ya-tongue (- x (* 0.12f0 fx)) yc (- z (* 0.12f0 fz)) (* l (- (* 0.7f0 ca) 0.3f0) fx) (* l sa) (* l (- (* 0.7f0 ca) 0.3f0) fz)
                      0.13f0 ti k (+ 50f0 f seed) (+ dr f)))))
    (%light x yc z 1f0 0.45f0 0.12f0 3f0 (* 0.7f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- SL4 NS2a's lance (the :wave, 1.2 m, 18 m/s)
(defun-fast yama-lance-look (hz rdt)
  "NS2a's stream (SL4: the :wave 2 x HAZARD-SIZE = 1.2 m wide): a lance of fire at 1.1 m, a FIRE lens whose point is the box's front, its
tail 2.4 m back (its first 8 f tied back to where it left the blade, 1 m ahead of him); tongues licking off its back; on the floor an EMBER
patch the box's size under the point and a thin EMBER scorch line over the last 20 f of the lane (a mark, no flame). By tier: the lens'
thickness and tongues, the white core. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (cw (%ya-core ti)) (o (hazard-owner hz))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5)))
         (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 5f0)) 0f0 0.98f0))
         (x1 (+ x (* +ya-wave-half+ fx))) (z1 (+ z (* +ya-wave-half+ fz)))   ; the point: the box's front
         (x0 (- x1 (* 2.4f0 fx))) (z0 (- z1 (* 2.4f0 fz))) (th (* 0.34f0 hf)) (seed (* 5f0 yaw)))
    (declare (single-float x z w yaw hf cw fx fz dr sd k x1 z1 x0 z0 th seed) (fixnum age life ti))
    (when (and o (entity-alive-p o) (< age 8))        ; the first 8 f: the tail still at the blade (1 m ahead of him, where it left)
      (let ((p (pos-of o))) (declare (type f32vec p)) (setf x0 (+ (aref p 0) fx) z0 (+ (aref p 2) fz))))
    (%ya-floor-box x z fx fz w (* 0.5f0 k) (+ 22f0 seed))
    (let ((sc (* (i->f (min age 20)) (/ +ya-lance-speed+ 60f0))))   ; the scorch line: the last 20 f of the lane
      (declare (single-float sc))
      (toon-ground-seg (- x (* +ya-wave-half+ fx)) (- z (* +ya-wave-half+ fz)) (- x (* sc fx)) (- z (* sc fz)) 0.012f0 0.035f0 1f0 0.2f0
                       (+ 23f0 seed) 0.15f0 (toon-a +pal-ember+ (* 0.9f0 k))))
    (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.12f0 (* 0.5f0 (+ z0 z1)) (* 1.3f0 th) :lens 0.08f0 (+ 60f0 sd) +pal-ember+ k
                 :push 0.1f0)
    (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.12f0 (* 0.5f0 (+ z0 z1)) th :lens 0.08f0 (+ 61f0 sd) +pal-fire+ k :push 0.16f0)
    (when (> ti 0)
      (fx-crescent x0 1.1f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.12f0 (* 0.5f0 (+ z0 z1)) (* cw th) :lens 0.05f0 (+ 62f0 sd) +pal-hit+ k
                   :push 0.2f0))
    (dotimes (j 5)                                     ; tongues licking up off its back half
      (let* ((f (i->f j)) (u (+ 0.15f0 (* 0.16f0 f))) (hh (* hf (+ 0.25f0 (* 0.2f0 (hash01 (+ f dr) 3.3f0))))))
        (declare (single-float f u hh))
        (when (<= (hash01 f 7.7f0) hf)
          (%ya-tongue (+ x0 (* u (- x1 x0))) 1.15f0 (+ z0 (* u (- z1 z0))) (* -0.3f0 hh fx) hh (* -0.3f0 hh fz) 0.07f0 ti k
                      (+ 70f0 f seed) (+ dr f) :back nil))))
    (%light x1 1.1f0 z1 1f0 0.45f0 0.12f0 3f0 (* 0.7f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- SL2 NS1b's ghost lights and column (:ya-col, r 1.2)
(defun-fast yama-column-look (hz rdt)
  "NS1b's 'unknown fire' (SL2: the :ya-col disc of HAZARD-SIZE at his bearing, :delay 13, hot 6, life 30). Through the delay the tell: an
EMBER ring on the disc's edge pulsing on twos and five small flames (不知火, ghost lights) hovering 0.3-0.8 m over it, circling in. On the
eruption (age 0, the hit frame: full at once) one FIRE column as wide as the disc at its foot, tapering, a crown of tongues, *YA-FIRE-H* x
the tier's share high (2.4 m at T2: the hit's height), EMBER behind it, the tier's white core; it holds through the hot frames and erodes
from 12 to 30. The ring on the edge stays (the footprint). A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (d (hazard-delay hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (cw (%ya-core ti)) (dr (drawing-no)) (seed (+ x (* 3f0 z)))
         (q (%near-cam x z 2f0 8f0)) (ws (f-max 0.15f0 (%near-cam x z 0f0 9f0)))
         (k (if (> d 0) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- life age)) 18f0)) 0f0 0.98f0))))
    (declare (single-float x z r dr seed hf cw q ws k) (fixnum d age life ti))
    (if (> d 0)
        (let ((p (- 1f0 (/ (i->f d) +ya-col-delay+))) (pulse (if (evenp (f->i dr)) 0.95f0 0.55f0)))
          (declare (single-float p pulse))
          (%tring x 0f0 z r 0.05f0 +pal-ember+ pulse (+ seed 1f0))
          (dotimes (i 5)                               ; the ghost lights circling in
            (let* ((f (i->f i)) (an (+ (* 1.2566f0 f) (* 3f0 p))) (rr (* r (- 0.95f0 (* 0.6f0 p))))
                   (y (+ 0.3f0 (* 0.5f0 (hash01 f seed)) (* 0.06f0 (f-sin (+ dr f))))) (lx (+ x (* rr (f-cos an)))) (lz (+ z (* rr (f-sin an)))))
              (declare (single-float f an rr y lx lz))
              (%ya-tongue lx (- y 0.06f0) lz 0f0 (* 0.22f0 (+ 0.7f0 (* 0.3f0 pulse))) 0f0 0.06f0 0 (* 0.9f0 pulse) (+ 80f0 f seed) (+ dr f)
                          :back nil :segs 3))))
        (let* ((h (* +ya-fire-h+ hf (+ 0.4f0 (* 0.6f0 q))))  ; (near the lens a column shortens and thins: the behind camera keeps the fight)
               (sd (- -3f0 (i->f (mod (f->i dr) 7)) (f-abs seed))))
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
            (let* ((f (i->f j)) (an (+ (* 1.0472f0 f) (* 0.5f0 (hash01 (+ f dr) 5.1f0)))) (hc (* 0.35f0 h (+ 0.6f0 (* 0.4f0 (hash01 (+ f dr) 2.3f0))))))
              (declare (single-float f an hc))
              (when (<= (hash01 f 8.3f0) hf)
                (%ya-tongue (+ x (* 0.2f0 r ws (f-cos an))) (* 0.85f0 h) (+ z (* 0.2f0 r ws (f-sin an))) (* 0.5f0 hc (f-cos an)) hc
                            (* 0.5f0 hc (f-sin an)) (* 0.14f0 ws) ti k (+ 90f0 f seed) (+ dr f) :back nil))))
          (%light x 1.2f0 z 1f0 0.45f0 0.12f0 3.5f0 (* 0.7f0 k) 7)))
    nil))

;;; ---------------------------------------------------------------- SL3 NS1c's tornado (the :wave, 3.5 m, 10 m/s)
(defun-fast yama-tornado-look (hz rdt)
  "NS1c's tornado (SL3: the :wave 2 x HAZARD-SIZE = 3.5 m wide): four stacked, tilted bands of fire turning on twos, FIRE on the camera's
side and INK on the far one, gaps between them (the foe in view from behind); the lowest band is the box (an ellipse 2 x size across, 2 x
+YA-WAVE-HALF+ along), the upper ones narrow across, up to 3.2 m x the tier's share; an EMBER stripe climbing round them; on the floor the
box as an EMBER patch (the footprint: never the round funnel's). Near the lens the bands shorten. By tier: height, share, core; T2 the scorch
30 f back. 爆炎's tornado (its data's :track: it turns after the victim, art S4) leans its upper bands toward the victim's side of its
travel, up to 1.0 m at the top (its turn rate is not stored; the lowest band, the footprint, never leans). A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (e (camera-eye *camera*))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (drawing-no)) (seed (* 9f0 yaw))
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
             (yb (* hs (+ 0.18f0 (* 0.85f0 bf)))) (tk (* 0.17f0 hs)) (spin (+ (* 0.55f0 dr) (* 0.9f0 bf))) (tilt (* 0.18f0 hs))
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
(defun-fast yama-ring-look (hz rdt)
  "城郭炎上's burning ring (SL5: :ya-ring, radius HAZARD-SIZE, band ±+YA-RING-BAND+; NS2b, AS2a's snap): an EMBER ring on the floor exactly
the band (the footprint), and a low wall of 24 FIRE tongues on it, 1.0 m high on the camera's side and 1.4 m on the far side (x the tier's
share), coiling in from the point nearest him in 4 f. It shows its charge (HAZARD-HITS-LEFT): 2 full, 1 thinner and lower, 0 only the
embers (a spent ring cannot burn). Its last 15 f gutter. Near the lens the tongues sink. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz)) (hl (hazard-hits-left hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (e (camera-eye *camera*)) (yaw (hazard-yaw hz)) (dr (drawing-no)) (seed (+ x (* 5f0 z)))
         (ex (- (aref e 0) x)) (ez (- (aref e 2) z)) (el (f-max 0.01f0 (f-hypot ex ez)))
         (g (f-clamp (/ (i->f (- life age)) 15f0) 0f0 1f0)) (k (* 0.98f0 (f-min 1f0 (* 2f0 g))))
         (coil (f-min 1f0 (/ (i->f (1+ age)) 4f0))) (a0 (f-atan2 (f-cos yaw) (f-sin yaw)))
         (ch (case hl (0 0f0) (1 0.7f0) (t 1f0))))
    (declare (single-float x z r hf dr seed ex ez el g k coil a0 ch yaw) (type f32vec e) (fixnum age life hl ti))
    (%tring x 0f0 z r +ya-ring-band+ +pal-ember+ (* (if (= hl 0) 0.6f0 0.75f0) k) (+ seed 1f0))
    (when (> ch 0f0)
      (dotimes (i 24)
        (let* ((f (i->f i)) (u (/ f 24f0)) (an (+ a0 (* 6.2832f0 (if (evenp i) (* 0.5f0 u) (- 1f0 (* 0.5f0 u))))))   ; (both ways from a0)
               (c (f-cos an)) (s (f-sin an)) (tx (+ x (* r c))) (tz (+ z (* r s)))
               (front (/ (+ (* ex c) (* ez s)) el))
               (nq (%near-cam tx tz 1.2f0 4f0))
               (hh (* hf ch g (if (> front 0f0) 1.0f0 1.4f0) (+ 0.7f0 (* 0.3f0 (hash01 (+ f dr) seed))) (+ 0.1f0 (* 0.9f0 nq)))))
          (declare (single-float f u an c s tx tz front nq hh))
          (when (and (<= u coil) (<= (hash01 f 4.1f0) (* hf (if (= hl 1) 0.7f0 1f0))) (> hh 0.03f0))
            (%ya-tongue tx 0.02f0 tz (* 0.1f0 hh c) hh (* 0.1f0 hh s) (* +ya-ring-band+ (if (= hl 1) 0.55f0 0.8f0)) ti k
                        (+ 100f0 f seed) (+ dr f))))))
    (%light x 0.8f0 z 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k ch) 6)
    nil))

;;; ---------------------------------------------------------------- SL6 the dome (:ya-dome, r 1.6, hot 4, life 40)
(defun-fast yama-dome-look (hz rdt)
  "The dome (SL6: :ya-dome, radius HAZARD-SIZE; NS2c, AS2b, 爆炎's NS2b): 12 FIRE tongues on the disc's edge leaning in, closed at 2.4 m x
the tier's share on its first frame (the hit's: full at once), INK backings on the far side so its inside reads dark, dark gaps between
them; it holds to 16, then the walls fall open and erode by 40. An EMBER ring on the edge (the footprint); T2 a scorch disc. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (r (hazard-size hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (e (camera-eye *camera*)) (dr (drawing-no)) (seed (+ (* 3f0 x) z))
         (ex (- (aref e 0) x)) (ez (- (aref e 2) z))
         (op (f-clamp (/ (i->f (- age 16)) 14f0) 0f0 1f0)) (k (f-clamp (* 0.98f0 (/ (i->f (- life age)) 14f0)) 0f0 0.98f0))
         (h (* +ya-fire-h+ hf (- 1f0 (* 0.5f0 op)))) (lean (* 0.88f0 (- 1f0 (* 0.8f0 op)))) (q (%near-cam x z 2f0 7f0)))
    (declare (single-float x z r hf dr seed ex ez op k h lean q) (type f32vec e) (fixnum age life ti))
    (%tring x 0f0 z r 0.06f0 +pal-ember+ k (+ seed 1f0))
    (when (= ti 2) (%tring x 0f0 z (* 0.5f0 r) (* 0.5f0 r) +pal-ember+ (* 0.45f0 k) (+ seed 2f0)))
    (dotimes (i 12)
      (let* ((f (i->f i)) (an (+ (* 0.5236f0 f) (* 0.2f0 (hash01 f seed)))) (c (f-cos an)) (s (f-sin an))
             (bx (+ x (* r c))) (bz (+ z (* r s))) (far (< (+ (* ex c) (* ez s)) 0f0))
             (hh (* h (+ 0.85f0 (* 0.25f0 (hash01 (+ f dr) seed))) (+ 0.35f0 (* 0.65f0 q))))
             (ax (* (- lean) r c)) (az (* (- lean) r s)) (wd (* 0.3f0 (/ (* 6.2832f0 r) 12f0))))
        (declare (single-float f an c s bx bz hh ax az wd))
        (when (<= (hash01 f 9.7f0) hf)
          (when far
            (let ((kx bx) (ky 0f0) (kz bz))
              (declare (single-float kx ky kz))
              (%away-from-eye (kx ky kz) 0.1f0
                (toon-ribbon (kx ky kz) ((* 1.05f0 ax) (* 1.05f0 hh) (* 1.05f0 az)) ((* 1.3f0 wd) 0f0) :heat (0.3f0 0.12f0)
                             :seed (- -120f0 f (f-abs seed)) :wob 0.3f0 :pal +pal-ink+ :k (%ya-k k) :ph (+ dr f) :sway 0.04f0 :segs 4))))
          (%ya-tongue bx 0.02f0 bz ax hh az wd ti k (+ 130f0 f seed) (+ dr f)))))
    (%light x 1.4f0 z 1f0 0.45f0 0.12f0 4f0 (* 0.7f0 k) 7)
    nil))

;;; ---------------------------------------------------------------- the moves' own looks (YAMA-DRAW): SL0 the blade, SL7-SL9
(defun-fast yama-blade-fire (tip base mode ti rdt)
  "SL0, Ryujin Jakka engulfed (canon: the blade lit from the tip down; %BLADE-FIRE's drawing, revived): a FIRE sheath along the blade BASE ..
TIP, three tongues licking up on twos, a thin warm line in it, the tier's white core; flame scraps only inside a move (MODE 1: none at rest,
so the cosmetic stream stays as it was there). Power: 0.5 at rest (MODE 0), 1.0 in a move's startup to S + A (MODE 1), the tier's share in
an NS (MODE 2), x 1.3 in 爆炎 (MODE + 10, always cored). A look; 0 B."
  (declare (type f32vec tip base) (fixnum mode ti) (single-float rdt))
  (let* ((blaze (>= mode 10)) (m (mod mode 10)) (tier (if blaze 2 ti))
         (p (* (if blaze 1.3f0 1f0) (case m (0 0.5f0) (1 1f0) (t (%ya-hf tier)))))
         (x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (bx (- (aref tip 0) x0)) (by (- (aref tip 1) y0)) (bz (- (aref tip 2) z0))
         (dr (drawing-no)) (sd (- -3f0 (i->f (mod (f->i dr) 5)))) (cw (if (= m 0) (if blaze 0.4f0 0f0) (%ya-core tier))))
    (declare (single-float p x0 y0 z0 bx by bz dr sd cw) (fixnum m tier))
    (toon-ribbon (x0 y0 z0) (bx by bz) ((* 0.075f0 p) (* 0.045f0 p)) :heat (0.3f0 0.15f0) :seed sd :wob 0.2f0 :pal +pal-fire+ :k 0.95f0 :ph dr
                 :sway 0.01f0 :segs 4)
    (when (> cw 0f0)
      (let ((cx x0) (cy y0) (cz z0))
        (declare (single-float cx cy cz))
        (%away-from-eye (cx cy cz) -0.02f0
          (toon-ribbon (cx cy cz) ((* 0.9f0 bx) (* 0.9f0 by) (* 0.9f0 bz)) ((* cw 0.06f0 p) (* cw 0.03f0 p)) :heat (0.3f0 0.15f0)
                       :seed (- sd 30f0) :wob 0.15f0 :pal +pal-hit+ :k 0.95f0 :ph dr :segs 3))))
    (dotimes (j 3)
      (let* ((f (i->f j)) (u (+ 0.25f0 (* 0.27f0 f))) (h (* p (+ 0.26f0 (* 0.26f0 (hash01 (+ f dr) 3.1f0)))))
             (lx (* 0.14f0 (- (hash01 (+ f dr) 5.3f0) 0.5f0))) (lz (* 0.14f0 (- (hash01 (+ f dr) 7.9f0) 0.5f0)))
             (tx (+ x0 (* u bx))) (ty (+ y0 (* u by))) (tz (+ z0 (* u bz))))
        (declare (single-float f u h lx lz tx ty tz))
        (%away-from-eye (tx ty tz) 0.04f0
          (toon-ribbon (tx ty tz) (lx h lz) ((* 0.09f0 p) 0f0) :heat (0.3f0 0.12f0) :seed (- sd (* 7f0 (+ f 1f0))) :wob 0.25f0 :pal +pal-fire+
                       :k 0.95f0 :ph (+ dr f) :sway 0.03f0 :segs 5))))
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
  (let* ((x (aref v 0)) (y (aref v 1)) (z (aref v 2)) (dr (drawing-no)))
    (declare (single-float x y z dr))
    (dotimes (j 2)
      (let ((f (i->f j)))
        (declare (single-float f))
        (%ya-tongue x (- y 0.04f0) z (* 0.06f0 (- (hash01 (+ f dr) 2.7f0) 0.5f0)) (+ 0.16f0 (* 0.08f0 (hash01 (+ f dr) 1.9f0))) 0f0 0.06f0 0 0.95f0
                    (+ 140f0 f) (+ dr f) :segs 3))))
  nil)

;;; the pointer stances' fire on the blade (art S3, DUEL_YAMA_CORE §21.3 / §24; out of a move, over SL0's rest sheath; 撫斬's stance has none)
(defun-fast yama-stance-fire (tip base code ti)
  "The Shikai's stance looks on the blade BASE .. TIP, at the tier TI of the heat his next segment would pay (YA-STANCE-TIER): CODE 1 不知火,
a slow corkscrew of fire, two strands wound 1.5 turns round the blade, turning once in 4 s; CODE 2 城郭炎上, a drip of fire off the point: a
flame hanging 0.26 m from the tip and three drops falling from it 0.8 m in turn, one every 0.4 s, thinning as they fall. By tier: the size
and the white core (%YA-SEG). Pure of the fx clock (no random stream). A look; 0 B."
  (declare (type f32vec tip base) (fixnum code ti))
  (let* ((x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (tx (aref tip 0)) (ty (aref tip 1)) (tz (aref tip 2))
         (bx (- tx x0)) (by (- ty y0)) (bz (- tz z0)) (c (fx-clock)) (dr (drawing-no)) (hf (%ya-hf ti)))
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
             (%ya-seg tx (+ y (* 0.13f0 hf)) tz tx y tz w (* 0.5f0 w) ti (- 0.95f0 (* 0.5f0 ph)) (+ 220f0 (i->f j)) (+ dr (i->f j)))))))
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
NADEGIRI (art S4): code 1's hairline, then from f38 the seam to 8 m (§21.4), its V tallest at the reach, lower past it, gone by f65. A look;
0 B."
  (declare (type f32vec pos) (single-float yaw) (fixnum code sf ti))
  (let* ((x (aref pos 0)) (z (aref pos 2)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (dr (drawing-no))
         (hf (%ya-hf ti)) (seed (+ (* 3f0 x) z)))
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
                      (off (* sd (+ 0.05f0 (* 0.3f0 g u)))) (hh (* hf g (+ 0.4f0 (* 1.4f0 u)) (+ 0.8f0 (* 0.3f0 (hash01 (+ i dr sd) seed))))))
                 (declare (single-float sd i u along off hh))
                 (when (<= (hash01 (+ i (* 3f0 sd)) 6.3f0) hf)
                   (%ya-tongue (+ x (* along fx) (* off px)) 0.02f0 (+ z (* along fz) (* off pz)) (* sd 0.35f0 hh px) hh (* sd 0.35f0 hh pz)
                               0.13f0 ti k (+ 160f0 i sd seed) (+ dr i)))))
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
                            (hh (* hf (+ 0.75f0 (* 0.5f0 (hash01 (+ f dr) seed))) (+ 0.08f0 (* 0.92f0 nq nq)))))
                       (declare (single-float f an c s tx tz nq hh))
                       (when (<= (hash01 f 3.7f0) hf)
                         (%ya-tongue tx 0.03f0 tz (* 0.35f0 hh c) hh (* 0.35f0 hh s) 0.17f0 ti k (+ 180f0 f seed) (+ dr f))))))
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
                      (off (* sd (+ 0.05f0 (* 0.3f0 g (f-min 1f0 (* 3f0 u)))))) (hh (* hf g rise (+ 0.8f0 (* 0.3f0 (hash01 (+ i dr sd) seed))))))
                 (declare (single-float sd i u along rise off hh))
                 (%ya-tongue (+ x (* along fx) (* off px)) 0.02f0 (+ z (* along fz) (* off pz)) (* sd 0.35f0 hh px) hh (* sd 0.35f0 hh pz)
                             0.13f0 ti k (+ 160f0 i sd seed) (+ dr i) :back nil)))
             (%light (+ x (* 2.4f0 fx)) 0.8f0 (+ z (* 2.4f0 fz)) 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k) 7))))
      (5 (when (<= 10 sf 14)                            ; AS1: the point-blank corkscrew to the reach
           (let* ((k (if (<= sf 12) 0.98f0 (* 0.98f0 (/ (i->f (- 15 sf)) 3f0)))) (spin (* 1.5708f0 dr)))
             (declare (single-float k spin))
             (dotimes (st 2)
               (dotimes (i 5)
                 (let* ((u0 (* 0.2f0 (i->f i))) (u1 (+ u0 0.2f0)) (ph (* 3.1416f0 (i->f st)))
                        (s0 (+ 0.2f0 (* 1.4f0 u0))) (s1 (+ 0.2f0 (* 1.4f0 u1))) (a0 (+ spin ph (* 4f0 s0))) (a1 (+ spin ph (* 4f0 s1)))
                        (r0 (* 0.3f0 hf (- 1f0 (* 0.5f0 u0)))) (r1 (* 0.3f0 hf (- 1f0 (* 0.5f0 u1)))))
                   (declare (single-float u0 u1 ph s0 s1 a0 a1 r0 r1))
                   (%ya-seg (+ x (* s0 fx) (* r0 (f-cos a0) px)) (+ 1.1f0 (* r0 (f-sin a0))) (+ z (* s0 fz) (* r0 (f-cos a0) pz))
                            (+ x (* s1 fx) (* r1 (f-cos a1) px)) (+ 1.1f0 (* r1 (f-sin a1))) (+ z (* s1 fz) (* r1 (f-cos a1) pz))
                            (* 0.09f0 (- 1f0 (* 0.5f0 u0))) (* 0.09f0 (- 1f0 (* 0.5f0 u1))) ti k (+ 190f0 seed (* 7f0 (i->f st)) (i->f i))
                            (+ dr (i->f i))))))))))
    nil))

(defun yama-sk-code (mv)
  "YAMA-SK-MOVES's code for the Shikai / 爆炎 move MV, or 0."
  (case (mv-name mv)
    ((:ya-n3c :ya-as3c :ya-b-as3c) 1) (:ya-sa 2) (:ya-b-sa 3) ((:ya-as1 :ya-b-as1) 5) (:ya-b-n3c 8) (t 0)))

(defun ya-sk-tier (e f mv)
  "The tier of E's own move MV (fighter F) for SL0 / SL7-SL9: 2 in 爆炎; in the Shikai the heat his NS segment in play paid (YAMA-SEG-HEAT),
0 for an AS, the SA or J. Reads only."
  (ya-heat-tier (if (and mv (eq (fighter-cls f) :ns)) (yama-seg-heat e) 0f0) (eq (fighter-form f) :blaze)))

;;; ================================================================ 爆炎's looks (art batch S4: DUEL_YAMA_CORE §21.4, §25)
;;; The scars by heat, ENNETSU's rows of pillars, NS2b's ring closing before its dome, the entry pose's fire, IKKOTSU's fist; the
;;; tornado's lean is in YAMA-TORNADO-LOOK, the true NADEGIRI's seam YAMA-SK-MOVES code 8, the flame trail VFX-SMEAR look 5. Every 爆炎
;;; fire is T2 (white-cored). Read only, 0 B (debug 87449's rows), cosmetics on the fx clock / HASH01 / RND.
(defconstant +ya-ennetsu-speed+ 12f0 "爆炎 NS2c ENNETSU's :speed (host-checked): where its rows of pillars stand.")
(defconstant +ya-dome-near+ 3f0 "爆炎 NS2b's :near (host-checked): the ring's predicted spot (YAMA-RING-CLOSE).")
(defconstant +ya-dome-far+ 8f0 "爆炎 NS2b's :far (host-checked).")
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
  "爆炎 NS2c ENNETSU JIGOKU (§21.4: the :wave 2 x HAZARD-SIZE = 2.4 m wide, 12 m/s over 9 m): rows of pillars, three abreast across the box
(each a third of its width). The front row rides the box (its far face near the box's front: the footprint, full on age 0, the hit frame);
behind it a row stands every 1.0 m of the lane the box has crossed, each full for 16 f from when the box passed it, then eroding over 4; on the
floor an EMBER circle at each pillar spot of the next row ahead of the box (the tell: outside the footprint by design) and a scorch under
the rows. Every row fades over the hazard's last 6 f (its life cannot grow: the state hash counts hazards). T2 in 爆炎. A look."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (w (hazard-size hz)) (yaw (hazard-yaw hz)) (age (hazard-age hz)) (life (hazard-life hz))
         (ti (ya-hz-tier hz)) (hf (%ya-hf ti)) (cw (%ya-core ti)) (dr (drawing-no))
         (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx)
         (step (/ +ya-ennetsu-speed+ 60f0)) (trav (* step (i->f age))) (sx (- x (* trav fx))) (sz (- z (* trav fz)))
         (r (/ w 3f0)) (kend (f-clamp (* 0.98f0 (/ (i->f (- life age)) 6f0)) 0f0 0.98f0)) (seed (* 11f0 yaw)))
    (declare (single-float x z w yaw hf cw dr fx fz px pz step trav sx sz r kend seed) (fixnum age life ti))
    (macrolet ((pillar (cx cz k back)                  ; one pillar of radius R at (CX CZ), presence K: FIRE, the core, a crown of two; BACK:
                 `(let* ((%x ,cx) (%z ,cz) (%k ,k) (%q (%near-cam %x %z 2f0 8f0)) (%ws (f-max 0.15f0 (%near-cam %x %z 0f0 9f0)))   ;  EMBER behind
                         (%h (* +ya-fire-h+ hf (+ 0.45f0 (* 0.55f0 %q)) (+ 0.85f0 (* 0.25f0 (hash01 (+ %x %z dr) seed)))))
                         (%sd (- -5f0 (i->f (mod (f->i dr) 7)) (f-abs (+ %x %z)))))
                    (declare (single-float %x %z %k %q %ws %h %sd))
                    ,@(when back
                        `((let ((%bx %x) (%by 0f0) (%bz %z))
                            (declare (single-float %bx %by %bz))
                            (%away-from-eye (%bx %by %bz) 0.12f0
                              (toon-ribbon (%bx %by %bz) (0f0 (* 1.08f0 %h) 0f0) ((* 1.1f0 r %ws) (* 0.3f0 r %ws)) :heat (0.3f0 0.15f0)
                                           :seed (- %sd 20f0) :wob 0.25f0 :pal +pal-ember+ :k (%ya-k %k) :ph dr :sway 0.05f0 :segs 4)))))
                    (toon-ribbon (%x 0f0 %z) (0f0 %h 0f0) ((* r %ws) (* 0.25f0 r %ws)) :heat (0.3f0 0.15f0) :seed %sd :wob 0.25f0 :pal +pal-fire+
                                 :k (%ya-k %k) :ph dr :sway 0.04f0 :segs 4)
                    (when (> ti 0)
                      (let ((%cx %x) (%cy 0f0) (%cz %z))
                        (declare (single-float %cx %cy %cz))
                        (%away-from-eye (%cx %cy %cz) -0.08f0
                          (toon-ribbon (%cx %cy %cz) (0f0 (* 0.8f0 %h) 0f0) ((* cw 0.6f0 r %ws) (* cw 0.15f0 r %ws)) :heat (0.3f0 0.15f0)
                                       :seed (- %sd 40f0) :wob 0.2f0 :pal +pal-hit+ :k (%ya-k %k) :ph dr :sway 0.04f0 :segs 3))))
                    (dotimes (%j 2)
                      (let* ((%f (i->f %j)) (%an (+ (* 3.1416f0 %f) (hash01 (+ %f dr) seed))) (%hc (* 0.3f0 %h (+ 0.6f0 (* 0.4f0 (hash01 (+ %f dr) 2.3f0))))))
                        (declare (single-float %f %an %hc))
                        (%ya-tongue (+ %x (* 0.25f0 r %ws (f-cos %an))) (* 0.85f0 %h) (+ %z (* 0.25f0 r %ws (f-sin %an))) (* 0.4f0 %hc (f-cos %an)) %hc
                                    (* 0.4f0 %hc (f-sin %an)) (* 0.32f0 r %ws) 0 %k (+ 300f0 %f seed) (+ dr %f) :back nil :segs 3))))))
      (%ya-floor-box x z fx fz w (* 0.55f0 kend) (+ 26f0 seed))
      (dotimes (n 9)                                   ; the rows the box has passed (every 1.0 m from where it was spawned)
        (let* ((d (+ 0.5f0 (i->f n))) (ra (- (i->f age) (/ d step))))   ; (the row's age, frames since the box's centre crossed it)
          (declare (single-float d ra))
          (when (and (>= ra 3f0) (< ra 20f0))          ; (younger: the front row covers it; 16 f full, then 4 f eroding)
            (let ((k (f-min kend (if (< ra 16f0) 0.98f0 (* 0.98f0 (/ (- 20f0 ra) 4f0))))) (rx (+ sx (* d fx))) (rz (+ sz (* d fz))))
              (declare (single-float k rx rz))
              (when (= ti 2)
                (toon-ground-seg (- rx (* 0.45f0 fx)) (- rz (* 0.45f0 fz)) (+ rx (* 0.45f0 fx)) (+ rz (* 0.45f0 fz)) 0.011f0 w 0.8f0 0.2f0
                                 (+ 27f0 seed d) 0.3f0 (toon-a +pal-ember+ (* 0.45f0 k))))
              (dotimes (i 3) (let ((u (* (- (i->f i) 1f0) 2f0 r))) (declare (single-float u)) (pillar (+ rx (* u px)) (+ rz (* u pz)) k nil)))))))
      (dotimes (i 3)                                   ; the front row, on the box
        (let ((u (* (- (i->f i) 1f0) 2f0 r))) (declare (single-float u)) (pillar (+ x (* u px)) (+ z (* u pz)) kend t)))
      (let* ((nn (f->i (+ trav 0.5f0 0.5f0))) (d (+ 0.5f0 (i->f nn))))   ; the tell: the next row's spots ahead of the box's front
        (declare (fixnum nn) (single-float d))
        (when (<= d 9f0)
          (dotimes (i 3)
            (let ((u (* (- (i->f i) 1f0) 2f0 r)))
              (declare (single-float u))
              (%tring (+ sx (* d fx) (* u px)) 0f0 (+ sz (* d fz) (* u pz)) r 0.04f0 +pal-ember+ (* 0.9f0 kend) (+ seed 3f0 (i->f i)) 10)))))
      (%light x 1.3f0 z 1f0 0.45f0 0.12f0 4.5f0 (* 0.8f0 kend) 7))
    nil))

(defun-fast yama-ring-close (e sf)
  "爆炎 NS2b, the ring closing at once (§21.4): through the move's last 4 frames before S (f12-15) the burning ring coils in round the spot
its dome will take (his live ring's, else the victim's bearing 3-8 m, YA-BEARING-POINT's rule, read now: the victim may still step), low
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
    (let* ((coil (f-min 1f0 (/ (i->f (- sf 11)) 4f0))) (dr (drawing-no)) (seed (+ x (* 5f0 z)))
           (a0 (f-atan2 (- (aref p 2) z) (- (aref p 0) x))))   ; (from the point nearest him, both ways round)
      (declare (single-float coil dr seed a0))
      (%tring x 0f0 z 1.6f0 +ya-ring-band+ +pal-ember+ 0.8f0 (+ seed 1f0))
      (dotimes (i 24)
        (let* ((f (i->f i)) (u (/ f 24f0)) (an (+ a0 (* 6.2832f0 (if (evenp i) (* 0.5f0 u) (- 1f0 (* 0.5f0 u))))))
               (c (f-cos an)) (s (f-sin an)) (hh (* 0.55f0 (+ 0.7f0 (* 0.3f0 (hash01 (+ f dr) seed))))))
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
           (bx (- tx x0)) (by (- (aref tip 1) y0)) (bz (- tz z0)) (dr (drawing-no)) (seed (+ (* 3f0 tx) tz))
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
                   (hh (* (- 0.75f0 (* 0.15f0 rr)) (+ 0.7f0 (* 0.3f0 (hash01 (+ f dr) seed))))))
              (declare (single-float f an c s hh))
              (%ya-tongue (+ tx (* rr c)) 0.02f0 (+ tz (* rr s)) (* 0.25f0 hh c) hh (* 0.25f0 hh s) 0.12f0 2 k (+ 240f0 f seed) (+ dr f)))))
        (%light tx 0.5f0 tz 1f0 0.45f0 0.12f0 3.5f0 (* 0.8f0 k) 7))))
  nil)

(defun-fast %ya-fist-fire (v yaw sf)
  "爆炎 IKKOTSU's fist (§21.4): a short FIRE burst on the fist V on S (f9, full: the hit frame), driven along his facing YAW, to S+A,
fading by f13. White-cored (T2). A look; 0 B."
  (declare (type f32vec v) (single-float yaw) (fixnum sf))
  (when (<= 9 sf 13)
    (let* ((x (aref v 0)) (y (aref v 1)) (z (aref v 2)) (dr (drawing-no)) (k (if (<= sf 11) 0.98f0 (* 0.98f0 (/ (i->f (- 14 sf)) 3f0))))
           (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
      (declare (single-float x y z dr k fx fz))
      (dotimes (j 6)
        (let* ((f (i->f j)) (an (* 1.0472f0 f)) (l (* 0.32f0 (+ 0.6f0 (* 0.4f0 (hash01 (+ f dr) 3.9f0))))) (c (f-cos an)) (s (f-sin an)))
          (declare (single-float f an l c s))
          (%ya-tongue x y z (* l (+ fx (* 0.45f0 c fz))) (* l 0.45f0 s) (* l (- fz (* 0.45f0 c fx))) 0.06f0 2 k (+ 250f0 f) (+ dr f) :segs 3)))
      (%light x y z 1f0 0.5f0 0.15f0 2.5f0 (* 0.8f0 k) 7)))
  nil)

;;; ---------------------------------------------------------------- the consing probe (debug 87448)
(defvar *ya-dq-n* (find-symbol "*DQ-N*" :engine) "The engine's draw count (render.lisp, not exported): the probe rewinds it.")
(defmacro %ya-cons-per (name form)
  "The consing probes' row (87448, 87449): bytes consed by 10 runs of FORM after 10 unmeasured ones, as \"NAME n\" (debug.lisp's CONS-PER,
which loads after this file, plus a warm-up: the engine's draw queue doubles at a new high-water mark, so the measured draws get the room
the warm-up made: the steady state; art K4: the fx batches are rewound too, so no look is measured on a full batch's skip path:
\"(dropped)\" if one still overflowed; batch Z1: rewound after every run, a mantle being 2.5-3.4 k of the toon batch's 16384 vertices). The
probe's draws are taken off the frame's queue again."
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
art K5 the 東 tear (YAMA-TEAR) while its spikes grow (void-grow, east-open) and at full (east-full)."
  (let ((hands (make-hazard :kind :ya-col :x 0f0 :z -5f0 :size 1.2f0 :life 30 :age 3))
        (tell (make-hazard :kind :ya-col :x 0f0 :z -5f0 :size 1.2f0 :life 30 :delay 5))
        (swarm (make-hazard :kind :wave :x 0f0 :z -4f0 :px 0f0 :pz -3.9f0 :size 1f0 :life 80 :age 20 :speed 6f0))
        (wall (make-hazard :kind :ya-wall :x 0f0 :z -1.2f0 :size 1.6f0 :life 90 :age 84))
        (fall (make-hazard :kind :ya-col :x 0f0 :z -3f0 :size 1.6f0 :life 30 :age 2))
        (pile (make-hazard :kind :ya-col :x 0f0 :z -1f0 :size 1.4f0 :life 30 :age 17))
        (north (make-hazard :kind :wave :x 0f0 :z -6f0 :px 0f0 :pz -5.67f0 :size 2f0 :life 42 :age 15 :speed 20f0))
        (pos (pos-of *p1*)) (yaw (yaw-of *p1*))
        (an-n (let ((a (make-anim))) (anim-play a :ya-st-nishi :blend 0) (setf (anim-time a) 0.6f0) a))
        (an-m (let ((a (make-anim))) (anim-play a :ya-st-minami :blend 0) a))
        (tr (let ((tr (make-trail))) (dotimes (i 5 tr) (trail-push tr 0f0 1f0 (- -0.3f0 (* 0.1f0 i)) (* 0.25f0 i) 1.5f0 -1.2f0))))
        (sm (make-f32 12))
        (px (aref (pos-of *p1*) 0)) (pz (aref (pos-of *p1*) 2)) (sp (fourth (first *ya-plants*)))   ; (art K3: boxed once, as DRAW-FIGHTER's)
        (tp (let ((v (make-f32 3))) (setf (aref v 0) 0.4f0 (aref v 1) 0.2f0 (aref v 2) 0.6f0) v))
        (bs (let ((v (make-f32 3))) (setf (aref v 0) 0.3f0 (aref v 1) 0.8f0 (aref v 2) 0.1f0) v))
        (fp (fighter *p1*)) (mv-as2 (kit-move (find-kit :yamamoto :bankai) :ya-e-as2)))
    (macrolet ((cons-per (name form) `(%ya-cons-per ,name ,form)))
     (flet ((fresh () (ya-dead-reset)))
      (log-msg "yama look consing (10 draws, B): ~{~a~^, ~}"
               (list (cons-per "hands" (progn (fresh) (yama-hands-look hands 0.016f0)))
                     (cons-per "tell" (progn (fresh) (yama-hands-look tell 0.016f0)))
                     (cons-per "swarm" (progn (fresh) (yama-swarm-look swarm 0.016f0)))
                     (cons-per "wall" (yama-wall-look wall 0.016f0))
                     (cons-per "fall" (yama-fall-look fall 0.016f0))
                     (cons-per "pile" (progn (fresh) (yama-pile-look pile 0.016f0)))
                     (cons-per "north" (yama-north-look north 0.016f0))
                     (cons-per "lance" (yama-bk-moves pos yaw 1 21 0.016f0))
                     (cons-per "void" (yama-bk-moves pos yaw 2 30 0.016f0))
                     (cons-per "void-grow" (yama-bk-moves pos yaw 2 19 0.016f0))   ; (art K5: the tear's spikes growing)
                     (cons-per "notch" (yama-bk-moves pos yaw 3 12 0.016f0))
                     (cons-per "flare" (yama-bk-moves pos yaw 4 17 0.016f0))
                     (cons-per "rise" (yama-bk-moves pos yaw 7 12 0.016f0))
                     (cons-per "crescent" (yama-bk-moves pos yaw 8 11 0.016f0))
                     (cons-per "garb" (yama-stance-look pos yaw an-n))   ; (art K2; batch Z1: the small mantle)
                     (cons-per "mantle-flare" (yama-bk-moves pos yaw 5 17 0.016f0))   ; (batch Z1: the full mantle, NS2b's flare)
                     (cons-per "mantle-throw" (yama-bk-moves pos yaw 6 13 0.016f0))   ; (AS2b's, growing)
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
                     (cons-per "west-ignite" (yama-nishi-look *p1* *p2* 54))   ; (batch Z1: the mantle building, then full)
                     (cons-per "west-full" (yama-nishi-look *p1* *p2* 62))
                     (cons-per "west-walk" (yama-nishi-look *p1* *p2* 100))
                     (cons-per "west-pass" (yama-nishi-look *p1* *p2* 128))
                     (cons-per "west-column" (yama-nishi-look *p1* *p2* 140))
                     (cons-per "south-dead" (yama-minami-look *p1* *p2* 90))
                     (cons-per "south-pile" (yama-minami-look *p1* *p2* 130))
                     (cons-per "south-burst" (yama-minami-look *p1* *p2* 150))))))
    (let ((f0 (stream-buffer-fill *fx-toon*)) (n0 (symbol-value *ya-dq-n*)) (rows nil))   ; (batch Z1: one draw's toon vertices, this camera)
      (macrolet ((vc (name form)
                   `(progn ,form (push (format nil "~a ~d" ,name (floor (- (stream-buffer-fill *fx-toon*) f0) 9)) rows)
                           (setf (stream-buffer-fill *fx-toon*) f0 (symbol-value *ya-dq-n*) n0))))
        (vc "stance" (yama-stance-look pos yaw an-n)) (vc "flare" (yama-bk-moves pos yaw 5 17 0.016f0))
        (vc "cine" (yama-nishi-look *p1* *p2* 62)))
      (let* ((e (camera-eye *camera*)) (p (pos-of *p1*)) (yw (yaw-of *p1*)) (hx (- (aref e 0) (aref p 0))) (hz (- (aref e 2) (aref p 2))))
        (log-msg "yama mantle toon verts (one draw, of 16384): ~{~a~^, ~} | the eye ~,1f deg round from P1's front"   ; (Z-Q2's angle)
                 (nreverse rows) (* (/ 180 pi) (acos (max -1.0 (min 1.0 (/ (+ (* (- (sin yw)) hx) (* (- (cos yw)) hz)) (max 1e-3 (sqrt (+ (* hx hx) (* hz hz))))))))))))
    (ya-dead-reset)))

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
      (push (%ya-cons-per "tier-move" (ya-sk-tier *p1* fp (fighter-move fp))) rows)
      (push (%ya-cons-per "tier-hz" (ya-hz-tier own)) rows)
      (push (%ya-cons-per "smear-4" (vfx-smear tr sm 4)) rows)
      (push (%ya-cons-per "stance-1-t0" (yama-stance-fire tp bs 1 0)) rows)   ; (art S3: the stances' fire per tier, the stance tier)
      (push (%ya-cons-per "stance-1-t1" (yama-stance-fire tp bs 1 1)) rows)
      (push (%ya-cons-per "stance-1-t2" (yama-stance-fire tp bs 1 2)) rows)
      (push (%ya-cons-per "stance-2-t0" (yama-stance-fire tp bs 2 0)) rows)
      (push (%ya-cons-per "stance-2-t1" (yama-stance-fire tp bs 2 1)) rows)
      (push (%ya-cons-per "stance-2-t2" (yama-stance-fire tp bs 2 2)) rows)
      (push (%ya-cons-per "tier-stance" (ya-stance-tier *p1* nil)) rows)
      (let ((jm (model-joints (model *p1*))) (yaw (yaw-of *p1*)) (mv-ik (kit-move (find-kit :yamamoto :blaze) :ya-b-j3))
            (en0 (hz :wave -4f0 1.2f0 45 0 :heat 25f0)) (en (hz :wave -4f0 1.2f0 45 24 :heat 25f0)) (en-end (hz :wave -4f0 1.2f0 45 42 :heat 25f0))
            (tl (hz :wave -4f0 1.75f0 48 20 :heat 25f0 :owner *p1* :track 60f0)))
        (push (%ya-cons-per "scars-100" (yama-scar-glow jm 100f0)) rows)   ; (art S4: 爆炎's looks)
        (push (%ya-cons-per "scars-60" (yama-scar-glow jm 60f0)) rows)
        (push (%ya-cons-per "scars-20" (yama-scar-glow jm 20f0)) rows)
        (push (%ya-cons-per "scars-5" (yama-scar-glow jm 5f0)) rows)
        (push (%ya-cons-per "ennetsu-front" (yama-ennetsu-look en0 0.016f0)) rows)
        (push (%ya-cons-per "ennetsu-rows" (yama-ennetsu-look en 0.016f0)) rows)
        (push (%ya-cons-per "ennetsu-end" (yama-ennetsu-look en-end 0.016f0)) rows)
        (push (%ya-cons-per "tornado-lean" (yama-tornado-look tl 0.016f0)) rows)
        (push (%ya-cons-per "ring-close" (yama-ring-close *p1* 13)) rows)
        (push (%ya-cons-per "blaze-in-edge" (yama-blaze-in-look tp bs 8)) rows)
        (push (%ya-cons-per "blaze-in-ring" (yama-blaze-in-look tp bs 14)) rows)
        (push (%ya-cons-per "fist" (%ya-fist-fire tp yaw 10)) rows)
        (push (%ya-cons-per "nade-seam-8m" (yama-sk-moves pos yaw 8 44 2)) rows)
        (push (%ya-cons-per "smear-5" (vfx-smear tr sm 5)) rows)
        (push (%ya-cons-per "plant-spot-ikkotsu" (yama-planted *p1* fp mv-ik)) rows))
      (log-msg "yama shikai consing (10 draws, B): ~{~a~^, ~}" (nreverse rows)))))
