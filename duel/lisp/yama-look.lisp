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

;;; ---------------------------------------------------------------- the moves' own looks (the :draw hook: YAMA-DRAW)
(defmacro %ya-flare (x z u k seed)
  "西's flare (L8) at his feet (X Z), U frames after its pulse: 14 orange flame tongues thrown out round him, leaning out, never past 2.0 m
(the burn's radius); the molten ring on that 2.0 m edge; a white-hot ring on the pulse's first two frames; the shoulder wings (two fans of
three ribbons, 0.9 m out each side). Single-float forms; 0 B."
  `(let* ((%g (f-min 1f0 (/ (+ ,u 1f0) 3f0))) (%k ,k) (%rr (+ 0.35f0 (* 1.2f0 %g))) (%dr (drawing-no)))
     (declare (single-float %g %k %rr %dr))
     (dotimes (%i 14)
       (let* ((%f (i->f %i)) (%a (+ (* 0.4488f0 %f) (* 0.3f0 (hash01 %f ,seed)))) (%c (f-cos %a)) (%s (f-sin %a))
              (%hh (* (- 1.3f0 (* 0.5f0 %g)) (+ 0.7f0 (* 0.5f0 (hash01 (+ %f %dr) ,seed)))
                      (let ((%n (%near-cam (+ ,x (* %rr %c)) (+ ,z (* %rr %s)) 1.5f0 4.5f0))) (declare (single-float %n))
                        (+ 0.08f0 (* 0.92f0 %n %n))))))   ; (small by the lens: the behind camera keeps the fight)
         (declare (single-float %f %a %c %s %hh))
         (%tongue (+ ,x (* %rr %c)) 0.04f0 (+ ,z (* %rr %s)) (* 0.3f0 %hh %c) %hh (* 0.3f0 %hh %s) 0.16f0 +pal-flame+ %k (+ ,seed %f %dr)
                  (+ %dr %f) 0.03f0 :segs 4)))
     (%tring ,x 0f0 ,z 2.0f0 0.06f0 +pal-flame+ %k (+ ,seed 3f0))
     (when (< ,u 2f0)
       (%tring ,x 0.01f0 ,z 2.0f0 0.025f0 +pal-hit+ 0.98f0 (+ ,seed 4f0))
       (%tring ,x 0.01f0 ,z 0.45f0 0.05f0 +pal-hit+ 0.98f0 (+ ,seed 5f0)))
     (dotimes (%j 6)
       (let* ((%f (i->f %j)) (%sd (if (< %j 3) -1f0 1f0)) (%q (i->f (mod %j 3))))
         (declare (single-float %f %sd %q))
         (toon-ribbon (,x 1.3f0 ,z) ((* %sd 0.9f0 (- 1f0 (* 0.25f0 %q))) (+ 0.2f0 (* 0.35f0 %q)) 0f0) (0.14f0 0.02f0)
                      :seed (- -70f0 %f (f-mod %dr 3f0)) :wob 0.3f0 :pal +pal-flame+ :k (* %k %g) :segs 4 :sway 0.06f0 :ph (+ %dr %f))))))

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
                                                        ;  spikes out in 4 f; the seed his feet on a 0.25 m grid (one shape a cast)
                 (let* ((k (if (< sf (+ s 20)) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- (+ s 31) sf)) 11f0)) 0f0 0.98f0)))
                        (g (f-min 1f0 (/ (i->f (+ 1 (- sf s))) 4f0)))
                        (ts (+ (* 3f0 (i->f (f->i (* 4f0 x)))) (i->f (f->i (* 4f0 z))) (i->f code))))
                   (declare (single-float k g ts))
                   (yama-tear (+ x (* 0.2f0 fx)) (+ z (* 0.2f0 fz)) fx fz (- len 0.2f0) (* 0.7f0 hw) hw 0.15f0 g
                              (if (= code 2) 12 4) (if (= code 2) 4 3) ts (toon-a +pal-ink+ k t))
                   (dotimes (i (n-of (if (< sf (+ s 20)) 18f0 60f0) rdt))   ; ash falling in (more as it fills)
                     (let* ((u (rnd-range 0.2f0 len)) (v (rnd-range (- hw) hw)))
                       (declare (single-float u v))
                       (%t-blob (+ x (* u fx) (* v px)) (rnd-range 0.6f0 1.6f0) (+ z (* u fz) (* v pz)) 0f0 (rnd-range -0.9f0 -0.4f0) 0f0
                                (rnd-range 0.8f0 1.2f0) (rnd-range 0.04f0 0.08f0) 0.2f0 0.2f0 +pal-ash+)))))))
      (4 (when (<= 16 sf 35) (%ya-flare x z (i->f (if (< sf 26) (- sf 16) (- sf 26))) (if (< sf 26) (if (< sf 23) 0.98f0 0.6f0)
                                                                                         (f-clamp (* 0.98f0 (/ (i->f (- 36 sf)) 6f0)) 0f0 0.98f0))
                                   seed)))
      (5 (when (<= 14 sf 23) (%ya-flare x z (i->f (- sf 14)) (f-clamp (* 0.98f0 (/ (i->f (- 24 sf)) 6f0)) 0f0 0.98f0) seed)))
      (6 (when (<= 12 sf 21) (%ya-flare x z (i->f (- sf 12)) (f-clamp (* 0.98f0 (/ (i->f (- 22 sf)) 6f0)) 0f0 0.98f0) seed)))
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
:YA-ST-NISHI 西's low garb (L8 at rest, the user's D4: 西 has fire): ten orange tongues round his feet up to the knee and two small
wings of two ribbons at his shoulders, breathing on the effect clock (2.4 s, as the clip; the clip's own time boxed a float);
:YA-ST-MINAMI 南's faint ember cracks (six thin ink cracks out to 0.45-0.7 m with ember cores pulsing with the same breath, no ring).
東 has the blade's smoke thread only (YAMA-DRAW). A look; 0 B."
  (declare (type f32vec pos) (single-float yaw))
  (let* ((c (anim-clip an)) (nm (and c (clip-name c))))
    (when (or (eq nm :ya-st-nishi) (eq nm :ya-st-minami))
      (let* ((x (aref pos 0)) (z (aref pos 2)) (dr (drawing-no)) (seed (+ (* 3f0 x) z))
             (b (+ 0.5f0 (* 0.5f0 (f-sin (* 2.618f0 (fx-clock)))))))   ; the breath 0..1 (2.4 s, the stance clips' loop)
        (declare (single-float x z dr seed b))
        (if (eq nm :ya-st-minami)
            (dotimes (i 6)                               ; six thin cracks out from under his feet, no ring (faint: not L1's tell)
              (let* ((f (i->f i)) (a (+ (* 1.0472f0 f) (hash01 f seed))) (co (f-cos a)) (si (f-sin a))
                     (r2 (+ 0.45f0 (* 0.25f0 (hash01 f 3.1f0)))))
                (declare (single-float f a co si r2))
                (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* r2 co)) (+ z (* r2 si)) 0.01f0 0.022f0 1f0 0.3f0
                                 (+ seed f) 0.2f0 (toon-a +pal-ink+ 0.6f0))
                (toon-ground-seg (+ x (* 0.18f0 co)) (+ z (* 0.18f0 si)) (+ x (* 0.85f0 r2 co)) (+ z (* 0.85f0 r2 si)) 0.013f0 0.008f0
                                 0.3f0 0.3f0 (+ seed f 9f0) 0.1f0 (toon-a +pal-ember+ (* 0.6f0 (+ 0.45f0 (* 0.4f0 b)))))))
            (let* ((px (f-cos yaw)) (pz (- (f-sin yaw))))   ; (his right, as YAMA-BK-MOVES's (- fz) fx)
              (declare (single-float px pz))
              (dotimes (i 10)                            ; the tongues to the knee
                (let* ((f (i->f i)) (a (+ (* 0.6283f0 f) (* 0.3f0 (hash01 f seed)))) (co (f-cos a)) (si (f-sin a))
                       (hh (* (+ 0.36f0 (* 0.12f0 b)) (+ 0.75f0 (* 0.35f0 (hash01 (+ f dr) seed))))))
                  (declare (single-float f a co si hh))
                  (%tongue (+ x (* 0.32f0 co)) 0.03f0 (+ z (* 0.32f0 si)) (* 0.15f0 hh co) hh (* 0.15f0 hh si) 0.07f0 +pal-flame+ 0.9f0
                           (+ seed f dr) (+ dr f) 0.03f0 :segs 4)))
              (dotimes (j 4)                             ; the small wings: two ribbons a side, out from the shoulders
                (let* ((sd (if (< j 2) -1f0 1f0)) (q (i->f (mod j 2))) (w (+ 0.36f0 (* 0.06f0 b) (* -0.1f0 q))))
                  (declare (single-float sd q w))
                  (toon-ribbon ((+ x (* sd 0.2f0 px)) 1.32f0 (+ z (* sd 0.2f0 pz))) ((* sd w px) (+ 0.1f0 (* 0.18f0 q)) (* sd w pz))
                               (0.07f0 0.01f0) :seed (- -90f0 (i->f j) (f-mod dr 3f0)) :wob 0.3f0 :pal +pal-flame+ :k 0.85f0 :segs 4
                               :sway 0.05f0 :ph (+ dr (i->f j))))))))))
  nil)

;;; ---------------------------------------------------------------- art K3 (§18): the planted blade, 北's burn
(defparameter *ya-plants*
  '((:ya-e-as2 4 26 (0.14f0 0.5f0)) (:ya-e-as2b 0 30 (0.14f0 0.5f0) :carried)   ; the grab / the throw: at his right (YA-E-PLANT-R)
    (:ya-e-as3b 0 24 (0.79f0 0.2f0)) (:ya-e-as3c 0 6 (0.79f0 0.2f0) :carried))     ; the dead's AS: by his front foot (YA-E-AS3A-HIT)
  "The Bankai moves whose blade stands in the plaza, the hand off it: (move from to (ahead right) [:carried]), planted from frame FROM up
to TO (the clip's hand leaves the hilt after FROM, or it was left by the segment before: :CARRIED; it is back on it at TO), at (ahead
right) m from his feet. The spots are the clips' grips by FK (the planted weapon's grip stands 0.76 m up, BODY.LISP DRAW-PLANTED-WEAPON;
host-checked in tests/duel-rules/art.lisp).")
(defun yama-planted (e f mv)
  "The Bankai's KIT-HOOK :planted (DRAW.LISP PLANTED-SPOT): the constant (ahead right) of *YA-PLANTS* while MV's main phase is inside its
window, else NIL (the blade in his hand). A look; 0 B."
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

;;; ---------------------------------------------------------------- the consing probe (debug 87448)
(defvar *ya-dq-n* (find-symbol "*DQ-N*" :engine) "The engine's draw count (render.lisp, not exported): the probe rewinds it.")
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
    (macrolet ((cons-per (name form)                    ; (debug.lisp's CONS-PER, which loads after this file, plus a warm-up: the
                 `(let ((n0 (symbol-value *ya-dq-n*))     ;  engine's draw queue doubles at a new high-water mark, so the
                        (f0 (stream-buffer-fill *fx-toon*)) (f1 (stream-buffer-fill *fx-add*))   ;  measured draws get the room
                        (f2 (stream-buffer-fill *fx-alpha*)) (d0 *fx-dropped*))                ;  the warm-up made: the steady
                    (flet ((rewind () (setf (symbol-value *ya-dq-n*) n0 (stream-buffer-fill *fx-toon*) f0   ;  state; art K4: the fx
                                            (stream-buffer-fill *fx-add*) f1 (stream-buffer-fill *fx-alpha*) f2)))   ;  batches are
                      (dotimes (i 10) ,form)              ;  rewound too, so no look is measured on a full batch's skip path:
                      (rewind)                            ;  "(dropped)" if one still overflowed)
                      (let ((c0 (cons-bytes)) (d1 *fx-dropped*))
                        (dotimes (i 10) ,form)
                        (prog1 (format nil "~a ~d~:[~; (dropped)~]" ,name (- (cons-bytes) c0) (/= d1 *fx-dropped*))
                          (rewind) (setf *fx-dropped* d0)))))))
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
                     (cons-per "garb" (yama-stance-look pos yaw an-n))   ; (art K2)
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
                     (cons-per "west-walk" (yama-nishi-look *p1* *p2* 100))
                     (cons-per "west-pass" (yama-nishi-look *p1* *p2* 128))
                     (cons-per "west-column" (yama-nishi-look *p1* *p2* 140))
                     (cons-per "south-dead" (yama-minami-look *p1* *p2* 90))
                     (cons-per "south-pile" (yama-minami-look *p1* *p2* 130))
                     (cons-per "south-burst" (yama-minami-look *p1* *p2* 150))))))
    (ya-dead-reset)))
