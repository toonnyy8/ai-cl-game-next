;;;; vfx-stamps.lisp — SOUL DUEL's universal one-shot effects, the STAMP system (moved out of vfx.lisp, refactor round 2, the
;;;; user 2026-10-21): the slot array and its envelope (STAMP, WITH-STAMP, %STAR %FLASH %STREAK %SHARDS-OUT), the drawings every
;;;; character shares (%ST-HIT ... %ST-RING, %ST-GASH), STAMPS-DRAW (the dispatch over the kind numbers, which calls
;;;; yama-vfx.lisp's looks by name), and the VFX-* calls the game makes (VFX-HIT, -HOHO, -BURST, -KONPAKU-SHATTER, -KIKON-RUSH,
;;;; -RUSH-DASH, -RIFT, -RIFT-GASH, -SMOKE-PUFFS, -STEP-DUST, -SHOCKWAVE). Cosmetic only (RND01, never SIM-RND01).
;;;; vfx.lisp (fx helpers, lights, auras, ground cuts, awaken burst) loads first, yama-vfx.lisp after this file.
(in-package :duel)

;;; ---------------------------------------------------------------- universal effects (toon, §4.3)
;;; Drawn in the notan world: hits, guard, clash, Hoho, Burst and Konpaku are mono (HIT white, STEEL,
;;; SOUL glass, DUST, INK) with a dark hairline; red (BLOOD) marks only Kikon, counters, guard breaks and
;;; blood droplets. A one-shot is a STAMP: kind, place, direction, age; STAMPS-DRAW redraws every live
;;; stamp each frame through FX-ENVELOPE on SAGE'd ages (so its shape changes on drawings, in step with
;;; the toon shader's noise), and frees it when its envelope ends. Scraps that fly (dust, blood, flame,
;;; glass) are toon particles emitted once. Hit flashes step on ones for their first 2 ticks, then twos.
(defconstant +stamp-n+ 48)
(defconstant +stamp-stride+ 12)
(declaim (type f32vec *stamps*))
(defvar *stamps* (make-f32 (* +stamp-n+ +stamp-stride+))
  "Live drawn one-shots: kind x y z dx dy dz age scale seed n flag (kind 0 = a free slot).")
(defparameter *stamp-kinds*
  '(:cut 1 :heavy 2 :fire 3 :counter 4 :guard 5 :guard-break 6 :clash 7 :hoho-out 8 :hoho-in 9 :burst 10
    :konpaku 11 :rush 12 :land 13 :guard-crush 14 :reiatsu 15 :ember 16 :slit 17 :garb 18 :wisps 20
    :cone 21 :boom 22 :ring 23 :gash 24 :garb-guard 25 :scorch 26 :flare 27 :gutter 28 :nade 29 :tip 30)
  "Stamp kind -> its code in *STAMPS*.")
(defvar *stamp-seed* 0.0 "Advances per stamp: every one-shot draws its own irregular shape.")

(defun stamp (kind x y z &key (dx 0.0) (dy 0.0) (dz -1.0) (scale 1.0) (n 0))
  "Start the drawn one-shot KIND (a key of *STAMP-KINDS*) at (x y z), direction (dx dy dz) (unit)."
  (let* ((s *stamps*) (best 0) (oldest -1.0))
    (dotimes (i +stamp-n+)                              ; a free slot, else the oldest
      (let ((o (* i +stamp-stride+)))
        (when (= (aref s o) 0f0) (setf best i) (return))
        (when (> (aref s (+ o 7)) oldest) (setf oldest (aref s (+ o 7)) best i))))
    (let ((o (* best +stamp-stride+)))
      (setf *stamp-seed* (mod (+ *stamp-seed* 7.31) 40.0)
            (aref s o) (f32 (getf *stamp-kinds* kind)) (aref s (+ o 1)) (f32 x) (aref s (+ o 2)) (f32 y) (aref s (+ o 3)) (f32 z)
            (aref s (+ o 4)) (f32 dx) (aref s (+ o 5)) (f32 dy) (aref s (+ o 6)) (f32 dz) (aref s (+ o 7)) 0f0
            (aref s (+ o 8)) (f32 scale) (aref s (+ o 9)) (f32 *stamp-seed*) (aref s (+ o 10)) (f32 n) (aref s (+ o 11)) 0f0))
    nil))

(defun stamps-clear () (fill *stamps* 0f0))

(defmacro with-stamp ((o) &body body)
  "Name the stamp at offset O: X Y Z, DX DY DZ, AGE, SC (scale), SEED, N, and SDX SDY (its direction on
screen: camera right / up) and DRAWING (the fx clock's drawing number on twos, 0..63, for per-drawing
hashes). Symbol macros: a float a stamp kind does not use costs nothing (an unused bound float boxes)."
  `(let* ((%sv *stamps*) (%rt (camera-right *camera*)) (%up (camera-upv *camera*)))
     (declare (type f32vec %sv %rt %up) (ignorable %rt %up))
     (symbol-macrolet ((x (aref %sv (+ ,o 1))) (y (aref %sv (+ ,o 2))) (z (aref %sv (+ ,o 3)))
                       (dx (aref %sv (+ ,o 4))) (dy (aref %sv (+ ,o 5))) (dz (aref %sv (+ ,o 6))) (age (aref %sv (+ ,o 7)))
                       (sc (aref %sv (+ ,o 8))) (seed (aref %sv (+ ,o 9))) (n (aref %sv (+ ,o 10)))
                       (sdx (+ (* dx (aref %rt 0)) (* dy (aref %rt 1)) (* dz (aref %rt 2))))
                       (sdy (+ (* dx (aref %up 0)) (* dy (aref %up 1)) (* dz (aref %up 2))))
                       (drawing (i->f (logand (f->i (* 12f0 (fx-clock))) 63))))
       ,@body)))

(defmacro hit-age (age)
  "A hit flash's stepped age: on ones for its first 2 ticks, then on twos."
  `(if (< ,age 0.0834f0) (sage ,age 1f0) (sage ,age 2f0)))

(defmacro %star (x y z r0 r1 n sdx sdy wob seed pal k &optional (push 0.35f0))
  "An irregular hit star (FX-STAR) whose spikes reshuffle every drawing (the SEED plus the drawing)."
  `(fx-star ,x ,y ,z ,r0 ,r1 ,n (* 6.2831855f0 (hash01 1.7f0 (+ ,seed drawing))) ,sdx ,sdy ,wob (+ ,seed drawing) ,pal ,k
            :push ,push))

(defmacro %flash (x y z r seed)
  "Drawing 1 of a hit: the white flash, a round burst with a jagged rim (12 short hashed spikes)."
  `(fx-star ,x ,y ,z (* 0.8f0 ,r) (* 1.15f0 ,r) 12 (* 6.2831855f0 (hash01 0.3f0 ,seed)) 0f0 0f0 0.1f0 ,seed +pal-hit+ 0.98f0
            :push 0.45f0))

(defmacro %streak (x0 y0 z0 x1 y1 z1 w pal k seed)
  "A straight tapered toon streak (a lens crescent) from (X0..) to (X1..): speed lines, shards of light."
  `(let* ((%x0 ,x0) (%y0 ,y0) (%z0 ,z0) (%x1 ,x1) (%y1 ,y1) (%z1 ,z1))
     (declare (single-float %x0 %y0 %z0 %x1 %y1 %z1))
     (fx-crescent %x0 %y0 %z0 %x1 %y1 %z1 (* 0.5f0 (+ %x0 %x1)) (* 0.5f0 (+ %y0 %y1)) (* 0.5f0 (+ %z0 %z1))
                  ,w :comet 0.05f0 ,seed ,pal ,k :push 0.3f0)))

(defmacro %shards-out (n x y z sdx sdy age speed len w pal k seed &optional (spread 1.2f0) (push 0.3f0))
  "N shards flying out of (X Y Z) around the screen direction (SDX SDY) (+-SPREAD rad), SPEED m/s at AGE."
  `(let* ((%base (f-atan2 ,sdy ,sdx)))
     (declare (single-float %base))
     (dotimes (%i ,n)
       (let* ((%f (i->f %i)) (%a (+ %base (* ,spread 2f0 (- (hash01 %f ,seed) 0.5f0))))
              (%c (f-cos %a)) (%sn (f-sin %a)) (%rt (camera-right *camera*)) (%up (camera-upv *camera*))
              (%wx (+ (* %c (aref %rt 0)) (* %sn (aref %up 0)))) (%wy (+ (* %c (aref %rt 1)) (* %sn (aref %up 1))))
              (%wz (+ (* %c (aref %rt 2)) (* %sn (aref %up 2))))
              (%d (+ 0.15f0 (* ,age ,speed (+ 0.6f0 (* 0.8f0 (hash01 (+ %f 3.1f0) ,seed)))))))
         (declare (single-float %f %a %c %sn %wx %wy %wz %d) (type f32vec %rt %up))
         (fx-shard (+ ,x (* %d %wx)) (+ ,y (* %d %wy)) (+ ,z (* %d %wz)) %wx %wy %wz
                   (* ,len (+ 0.7f0 (* 0.6f0 (hash01 (+ %f 5.3f0) ,seed)))) ,w 0.06f0 (+ ,seed %f) ,pal ,k :push ,push)))))

;;; the stamp kinds' drawings: each a DEFUN-FAST of the slot offset (no float arguments: 0 B), T when done
(defun-fast %st-hit (o)
  "Hits :cut (6-spike HIT star, 4 shards, envelope 1 2 2 6), :heavy (8 spikes r 0.9, an impact crescent
held 3 drawings, 6 shards; envelope 1 2 3 8), :fire (FIRE star), :counter (BLOOD star)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((kind (aref %sv o)) (heavy (= kind 2f0))
           (pal (cond ((= kind 3f0) +pal-fire+) ((= kind 4f0) +pal-blood+) ((= kind 15f0) +pal-reiatsu+) (t +pal-hit+)))
           (a (hit-age age)))
      (declare (single-float kind pal a))
      (fx-envelope (es k fl ph) (a 1 2 (if heavy 3f0 2f0) (if heavy 8f0 6f0))
        (with-cam (rx ry rz ux uy uz)
          (if (= ph 1)
              (%flash x y z (* sc (if heavy 0.26f0 0.18f0)) seed)
              (when (< ph 5)
                (let* ((r1 (* sc es (if heavy 0.9f0 (if (= kind 4f0) 0.75f0 0.55f0)))))
                  (declare (single-float r1))
                  (%star x y z (* 0.22f0 r1) r1 (if heavy 8 6) sdx sdy 0.06f0 seed pal k)
                  (%shards-out (if heavy 6 4) x y z sdx sdy a 5f0 (* sc 0.3f0) (* sc 0.045f0) pal k seed 0.7f0)
                  (when (and heavy (< a 0.25f0))                          ; the impact mark: held 3 drawings
                    (let* ((l (* sc 0.65f0)) (px (- sdy)) (py sdx)
                           (ax (+ x (* l (+ (* px rx) (* py ux))))) (ay (+ y (* l (+ (* px ry) (* py uy))))) (az (+ z (* l (+ (* px rz) (* py uz)))))
                           (bx (- x (* l (+ (* px rx) (* py ux))))) (by (- y (* l (+ (* px ry) (* py uy))))) (bz (- z (* l (+ (* px rz) (* py uz)))))
                           (cx (+ x (* 0.5f0 l (+ (* sdx rx) (* sdy ux))))) (cy (+ y (* 0.5f0 l (+ (* sdx ry) (* sdy uy)))))
                           (cz (+ z (* 0.5f0 l (+ (* sdx rz) (* sdy uz))))))
                      (declare (single-float l px py ax ay az bx by bz cx cy cz))
                      (fx-crescent ax ay az bx by bz cx cy cz (* sc 0.07f0) :lens 0.08f0 seed +pal-hit+ 0.98f0 :push 0.5f0)))))))
        (= ph 5)))))

(defun-fast %st-guard (o)
  "Guard: a hex-faceted STEEL plate (a regular FX-STAR) held 2 drawings + 4 steel shards thrown back."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 0 1 4 5)
        (when (< ph 5)
          (fx-star x y z 1f0 (* sc 0.5f0 es) 6 (* 0.5236f0 (hash01 2.1f0 seed)) 0f0 0f0 0.03f0 seed +pal-steel+ k :push 0.4f0)
          (fx-star x y z 1f0 (* sc 0.26f0 es) 6 (* 0.5236f0 (hash01 2.1f0 seed)) 0f0 0f0 0.03f0 (+ seed 1f0) +pal-hit+ k :push 0.42f0)
          (%shards-out 4 x y z (- sdx) (- sdy) a 4f0 (* sc 0.22f0) (* sc 0.04f0) +pal-steel+ k seed 1.1f0))
        (= ph 5)))))

(defun-fast %st-guard-break (o)
  "Guard break: a HIT star and 12 INK shards with BLOOD edges (a red kite behind each black one)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 2 3 10)
        (if (= ph 1)
            (%flash x y z (* sc 0.3f0) seed)
            (when (< ph 5)
              (%star x y z (* sc 0.2f0) (* sc es 0.85f0) 8 sdx sdy 0.06f0 seed +pal-hit+ k)
              (%shards-out 12 x y z sdx sdy a 4.5f0 (* sc 0.42f0) (* sc 0.11f0) +pal-blood+ k seed 3.1f0)
              (%shards-out 12 x y z sdx sdy a 4.5f0 (* sc 0.34f0) (* sc 0.075f0) +pal-ink+ k seed 3.1f0 0.36f0)))
        (= ph 5)))))

(defun-fast %st-guard-crush (o)
  "Guard crush (the guard gauge ran out on a block): the STEEL hexagon held one drawing, then shattered
into 12 STEEL shards around a HIT star (mono: the negative frame is the feedback's)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 0 1 3 10)
        (when (< ph 5)
          (if (< a 0.05f0)
              (fx-star x y z 1f0 (* sc 0.5f0) 6 (* 0.5236f0 (hash01 2.1f0 seed)) 0f0 0f0 0.03f0 seed +pal-steel+ 0.98f0 :push 0.4f0)
              (progn
                (%star x y z (* sc 0.18f0) (* sc es 0.7f0) 8 sdx sdy 0.06f0 seed +pal-hit+ k)
                (%shards-out 12 x y z sdx sdy a 4f0 (* sc 0.3f0) (* sc 0.08f0) +pal-steel+ k seed 3.1f0))))
        (= ph 5)))))

(defun-fast %st-clash (o)
  "Clash: an 8-spike HIT star (r 1.2) and a flat ground ring running out (envelope 1 2 4 10)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 2 4 10)
        (if (= ph 1)
            (%flash x y z (* sc 0.34f0) seed)
            (when (< ph 5)
              (%star x y z (* sc 0.25f0) (* sc es 1.2f0) 8 0f0 1f0 0.06f0 seed +pal-hit+ k)
              (%shards-out 6 x y z 1f0 0f0 a 6f0 (* sc 0.35f0) (* sc 0.05f0) +pal-hit+ k seed 3.1f0)))
        (when (< ph 5) (%tring x 0f0 z (+ 0.4f0 (* 6f0 (sage age 2f0))) 0.07f0 +pal-hit+ (* 0.98f0 k) seed))
        (= ph 5)))))

(defun-fast %st-hoho (o)
  "Hoho vanish (:hoho-out): 6 horizontal speed streaks at body height (drawings 1-2), then DUST puffs on
the ground (drawing 3 on); the ink afterimage is the fighter's (DRAW-FIGHTER). Appear (:hoho-in): 6
streaks converging for 3 drawings, then a small HIT star."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((kind (aref %sv o)) (a (sage age 2f0)) (hx (- dz)) (hz dx) (gy (f-max 0f0 (- y 1f0))))  ; hx hz: the side
      (declare (single-float kind a hx hz gy))
      (if (= kind 8f0)
          (fx-envelope (es k fl ph) (a 0 0 10 14)
            (when (< a 0.17f0)
              (dotimes (i 6)
                (let* ((f (i->f i)) (h (+ gy 0.3f0 (* 0.26f0 f))) (sd (if (evenp i) 1f0 -1f0))
                       (l0 (+ 0.2f0 (* 0.5f0 (hash01 f seed)))) (l1 (+ l0 1.2f0 (* 9f0 a))))
                  (declare (single-float f h sd l0 l1))
                  (%streak (+ x (* sd l0 hx)) h (+ z (* sd l0 hz)) (+ x (* sd l1 hx)) h (+ z (* sd l1 hz))
                           (* sc 0.035f0) +pal-hit+ (- 0.98f0 (* 4f0 a)) (+ seed f)))))
            (when (>= a 0.16f0)
              (dotimes (i 3)
                (let* ((f (i->f i)) (ang (+ (* 2.1f0 f) seed)) (r (+ 0.3f0 (* 1.2f0 (- a 0.16f0)))))
                  (declare (single-float f ang r))
                  (fx-disc (+ x (* r (f-cos ang))) (+ gy 0.18f0) (+ z (* r (f-sin ang))) (* sc (+ 0.2f0 (* 0.3f0 a))) 0.2f0
                           (+ seed f) +pal-dust+ k))))
            (= ph 5))
          (fx-envelope (es k fl ph) (a 0 0 6 6 :anticipate 6)
            (if (= ph 0)
                (dotimes (i 6)
                  (let* ((f (i->f i)) (ang (+ seed (* 1.047f0 f))) (c (f-cos ang)) (sn (f-sin ang))
                         (r1 (- 2.2f0 (* 16f0 a))) (r0 (- r1 0.9f0)))
                    (declare (single-float f ang c sn r1 r0))
                    (when (> r0 0.05f0)
                      (%streak (+ x (* r1 c hx)) (+ y (* 0.9f0 r1 sn)) (+ z (* r1 c hz)) (+ x (* r0 c hx)) (+ y (* 0.9f0 r0 sn))
                               (+ z (* r0 c hz)) (* sc 0.03f0) +pal-hit+ 0.98f0 (+ seed f)))))
                (when (< ph 5)
                  (%star x y z (* sc 0.08f0) (* sc es 0.4f0) 6 0f0 0f0 0.05f0 seed +pal-hit+ k)))
            (= ph 5))))))

(declaim (type f32vec *burst-flag*))
(defvar *burst-flag* (make-f32 1) "[0] 1 once a Burst stamp's ring fired: main.lisp gives it its beat (a negative frame, the back-rim).")
(defun-fast %st-burst (o)
  "Burst Reverse at the feet: anticipation (4 f, 8 lines converging on the chest), then a flat expanding
double ring (a thick white leading edge, a thin STEEL trailing one, both with a dark hairline) and 8
steel shards. The frame it fires: a 1 f negative frame and a 3 f white back-rim (N = the stamp's flag)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 1f0)) (cy (+ y 1.1f0)))
      (declare (single-float a cy))
      (fx-envelope (es k fl ph) (a 0 3 3 16 :anticipate 4)
        (cond ((= ph 0)
               (dotimes (i 8)
                 (let* ((f (i->f i)) (ang (+ seed (* 0.785f0 f))) (c (f-cos ang)) (sn (f-sin ang))
                        (r1 (- 2.4f0 (* 25f0 a))) (r0 (- r1 1.0f0)))
                   (declare (single-float f ang c sn r1 r0))
                   (when (> r0 0.1f0)
                     (%streak (+ x (* r1 c)) (+ cy (* r1 sn)) z (+ x (* r0 c)) (+ cy (* r0 sn)) z (* sc 0.035f0) +pal-steel+ 0.98f0 (+ seed f))))))
              ((< ph 5)
               (when (< (aref %sv (+ o 11)) 0.5f0)
                 (setf (aref %sv (+ o 11)) 1f0 (aref (the f32vec *burst-flag*) 0) 1f0))
               (let* ((r (* sc (+ 0.5f0 (* 7f0 (- a 0.066f0))))))
                 (declare (single-float r))
                 (%tring x y z r 0.16f0 +pal-hit+ k seed)
                 (%tring x y z (f-max 0.1f0 (- r 0.55f0)) 0.05f0 +pal-steel+ k (+ seed 1f0)))
               (%shards-out 8 x cy z 0f0 1f0 a 7f0 (* sc 0.3f0) (* sc 0.05f0) +pal-steel+ k seed 3.1f0)))
        (= ph 5)))))

(defun-fast %st-konpaku (o)
  "A lost Konpaku: a SOUL star and a SOUL ring (the 3N glass shards are toon particles)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 2 3 10)
        (if (= ph 1)
            (%flash x y z (* sc 0.22f0) seed)
            (when (< ph 5)
              (%star x y z (* sc 0.15f0) (* sc es 0.7f0) 7 0f0 1f0 0.05f0 seed +pal-soul+ k)
              (%tring x (- y 1.1f0) z (+ 0.3f0 (* 3f0 a)) 0.05f0 +pal-soul+ k seed)))
        (= ph 5)))))

(defun-fast %st-ring (o)
  "Ground rings: :rush (the Kikon rush starts: a BLOOD ring and an inner one running out), :land (DUST), :garb (the ward's
charcoal double ring with an ember line) and :ring (a shockwave in the palette N: FIRE, REIATSU, HIT)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((kind (aref %sv o)) (rush (= kind 12f0)) (garb (= kind 18f0)) (ring (= kind 23f0)) (a (sage age 2f0))
           (pal (cond (rush +pal-blood+) (garb +pal-black-smoke+) (ring n) (t +pal-dust+))))
      (declare (single-float kind a pal))
      (fx-envelope (es k fl ph) (a 0 2 3 14)
        (when (< ph 5)
          (%tring x y z (* sc (+ 0.4f0 (* (cond (ring 7f0) ((or rush garb) 5f0) (t 2.5f0)) a))) (* sc (if (or rush garb ring) 0.12f0 0.06f0))
                  pal k seed)
          (when (or rush ring) (%tring x y z (* sc (+ 0.3f0 (* (if ring 4.5f0 2.5f0) a))) 0.04f0 pal k (+ seed 1f0)))
          (when garb (%tring x y z (* sc (+ 0.3f0 (* 3.6f0 a))) 0.04f0 +pal-black-smoke+ k (+ seed 1f0))
                     (%tring x (+ y 0.01f0) z (* sc (+ 0.25f0 (* 4.2f0 a))) 0.025f0 +pal-ember+ k (+ seed 2f0))))
        (= ph 5)))))

(defun-fast %st-tip (o)
  "Hisagi's chain tip landing (:tip, at the hit, over its :cut / :heavy spark; DUEL_HISAGI §25.26): the white flash, then a
long 4-point STEEL glint (a cross of light) round a white 8-spike core, held 3 drawings, and 6 STEEL shards thrown along
the hit. Envelope 1 2 3 9."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 2 3 9)
        (if (= ph 1)
            (%flash x y z (* sc 0.24f0) seed)
            (when (< ph 5)
              (fx-star x y z (* sc 0.05f0) (* sc es 1.1f0) 4 (* 0.4f0 (hash01 0.9f0 seed)) 0f0 0f0 0.02f0 seed +pal-steel+ k
                       :push 0.5f0)
              (%star x y z (* sc 0.1f0) (* sc es 0.42f0) 8 sdx sdy 0.04f0 (+ seed 1f0) +pal-hit+ k 0.52f0)
              (%shards-out 6 x y z sdx sdy a 5.5f0 (* sc 0.32f0) (* sc 0.04f0) +pal-steel+ k seed 0.8f0)))
        (= ph 5)))))

(defun-fast %st-gash (o)
  "KUKAN-GIRI's rift cutting (:gash): X Y Z its near end, DX DY DZ along it, SC its length. Envelope 0 1 4 16: an INK
gash (a black lens with a white edge) hanging in the air along the rift, a white HIT line in it while it holds, and
4 ink shards thrown up."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 2f0)) (x1 (+ x (* sc dx))) (y1 (+ y (* sc dy))) (z1 (+ z (* sc dz))))
      (declare (single-float a x1 y1 z1))
      (fx-envelope (es k fl ph) (a 0 1 4 16)
        (when (< ph 5)
          (fx-crescent x y z x1 y1 z1 (* 0.5f0 (+ x x1)) (+ 0.06f0 (* 0.5f0 (+ y y1))) (* 0.5f0 (+ z z1)) (* 0.13f0 es) :lens 0.1f0 seed
                       +pal-ink+ k :push 0.2f0)
          (when (< ph 4)
            (fx-crescent x y z x1 y1 z1 (* 0.5f0 (+ x x1)) (+ 0.06f0 (* 0.5f0 (+ y y1))) (* 0.5f0 (+ z z1)) 0.03f0 :lens 0.05f0 (+ seed 1f0)
                         +pal-hit+ 0.98f0 :push 0.25f0))
          (%shards-out 4 (* 0.5f0 (+ x x1)) (* 0.5f0 (+ y y1)) (* 0.5f0 (+ z z1)) 0f0 1f0 a 4f0 0.25f0 0.05f0 +pal-ink+ k seed 1.4f0))
        (= ph 5)))))

(defun-fast stamps-draw (dt)
  "Age every live stamp by DT (effect seconds: 0 while paused) and draw it; free the finished ones."
  (declare (single-float dt))
  (let* ((s *stamps*))
    (declare (type f32vec s))
    (dotimes (i +stamp-n+)
      (let* ((o (* i +stamp-stride+)) (kind (f->i (aref s o))))
        (declare (fixnum o kind))
        (when (> kind 0)
          (setf (aref s (+ o 7)) (+ (aref s (+ o 7)) dt))
          (when (case kind
                  ((1 2 3 4 15) (%st-hit o)) (5 (%st-guard o)) (6 (%st-guard-break o)) (7 (%st-clash o)) (14 (%st-guard-crush o))
                  ((8 9) (%st-hoho o)) (10 (%st-burst o)) (11 (%st-konpaku o)) ((12 13 18) (%st-ring o))
                  (16 (%st-ember o)) (17 (%st-slit o)) (20 (%st-wisps o))
                  (21 (%st-cone o)) (22 (%st-boom o)) (23 (%st-ring o)) (24 (%st-gash o)) (25 (%st-garb-guard o)) (26 (%st-scorch o))
                  (27 (%st-flare o)) (28 (%st-gutter o)) (29 (%st-nade o)) (30 (%st-tip o)) (t t))
            (setf (aref s o) 0f0)))))
    nil))

;;; the calls the game makes (events, cinematics)
(defun-fast vfx-hit (x y z kind &key (dx 0.0) (dz -1.0))
  "Hit spark at (x y z); (dx dz) = the hit direction (attacker -> victim). KIND :cut :heavy :fire
:counter :guard :guard-crush :guard-break :clash (:breaker = :guard-break). Heavy hits throw 3 DUST puffs and 5-8
ink-blood droplets, fire hits 4 flame scraps. Also starts the 0.15 s hit light (white: no warm pixels)."
  (with-floats (x y z dx dz)
    (let* ((l (f-max 0.01f0 (f-hypot dx dz))) (dx (/ dx l)) (dz (/ dz l))
           (kind (if (eq kind :breaker) :guard-break kind)))
      (declare (single-float l dx dz))
      (stamp kind x y z :dx dx :dy 0.0 :dz dz)
      (case kind
        (:heavy (dotimes (i 3)
                  (%t-blob (+ x (rnd-range -0.2f0 0.2f0)) (- y 0.3f0) (+ z (rnd-range -0.2f0 0.2f0)) (* 1.2f0 dx) 0.6f0 (* 1.2f0 dz)
                           (rnd-range 0.5f0 0.8f0) (rnd-range 0.16f0 0.26f0) -0.2f0 0.2f0 +pal-dust+))
                (dotimes (i (+ 5 (f->i (* 3.99f0 (rnd01)))))
                  (let* ((sp (rnd-range 2.5f0 5f0)))
                    (declare (single-float sp))
                    (%t-blob x y z (* sp (+ dx (rnd-range -0.4f0 0.4f0))) (rnd-range 0.5f0 2.5f0) (* sp (+ dz (rnd-range -0.4f0 0.4f0)))
                             (rnd-range 0.35f0 0.6f0) (rnd-range 0.03f0 0.06f0) 9f0 0.3f0 +pal-blood+))))
        (:fire (dotimes (i 4)
                 (%t-blob x y z (* 2f0 (+ dx (rnd-range -0.6f0 0.6f0))) (rnd-range 1f0 2.5f0) (* 2f0 (+ dz (rnd-range -0.6f0 0.6f0)))
                          (rnd-range 0.3f0 0.5f0) (rnd-range 0.1f0 0.16f0) -2f0 0.3f0 +pal-fire+)))
        (:guard-break (dotimes (i 4)
                        (%t-blob x y z (* 3f0 (+ dx (rnd-range -0.5f0 0.5f0))) (rnd-range 0.5f0 2.5f0) (* 3f0 (+ dz (rnd-range -0.5f0 0.5f0)))
                                 (rnd-range 0.35f0 0.55f0) (rnd-range 0.03f0 0.05f0) 9f0 0.3f0 +pal-blood+))))
      (flash-light x y z 1.0 1.0 1.0)
      nil)))

(defun-fast vfx-hoho (x y z appear-p &key (dx 0.0) (dz -1.0))
  "Flash step, (x y z) = the body's centre (~1 m up): vanish (APPEAR-P NIL: streaks, then DUST puffs;
the ink afterimage is drawn by the fighter) or appear (converging streaks, then a small HIT star).
(DX DZ): the fighter's facing (the streaks run sideways to it)."
  (with-floats (x y z dx dz)
    (stamp (if appear-p :hoho-in :hoho-out) x y z :dx dx :dz dz)
    nil))

(defun-fast vfx-burst (x y z)
  "Burst Reverse at the user's feet (x y z): see %ST-BURST."
  (with-floats (x y z)
    (stamp :burst x y z)
    (flash-light x (+ y 1f0) z 0.85 0.9 1.0)
    nil))

(defun-fast vfx-konpaku-shatter (x y z n)
  "N soul-glass Konpaku lost at (x y z): 3N SOUL shards burst out (toon particles), a SOUL star, a ring."
  (declare (fixnum n))
  (with-floats (x y z)
    (stamp :konpaku x y z)
    (dotimes (i (* 3 n))
      (let* ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 2.5f0 5.5f0)))
        (declare (single-float a sp))
        (%t-shard x y z (* sp (f-cos a)) (rnd-range 0.5f0 4f0) (* sp (f-sin a)) (rnd-range 0.6f0 1.0f0) (rnd-range 0.12f0 0.22f0) 7f0
                  +pal-soul+)))
    (flash-light x y z 0.8 0.9 1.0)
    nil))

(defun-fast vfx-kikon-rush (x z)
  "The Kikon rush starts at feet (x z): a BLOOD ground ring running out and DUST puffs kicked up."
  (with-floats (x z)
    (stamp :rush x 0.0 z)
    (dotimes (i 5)
      (let* ((a (rnd-range 0f0 6.2832f0)))
        (declare (single-float a))
        (%t-blob (+ x (* 0.4f0 (f-cos a))) 0.15f0 (+ z (* 0.4f0 (f-sin a))) (* 2.5f0 (f-cos a)) 0.5f0 (* 2.5f0 (f-sin a))
                 (rnd-range 0.5f0 0.8f0) (rnd-range 0.2f0 0.3f0) -0.3f0 0.25f0 +pal-dust+)))
    nil))

(defun-fast vfx-rush-dash (x z dx dz look)
  "A Kikon rush module takes off at feet (x z), dashing along (dx dz), by LOOK: :flash-step the Hoho's
vanish streaks, :leap a DUST ring and dust (the take-off), else (:charge) dust kicked back."
  (with-floats (x z dx dz)
    (case look
      (:flash-step (stamp :hoho-out x 1.0 z :dx dx :dz dz))
      (:leap (stamp :land x 0.0 z :scale 1.2) (vfx-step-dust x z dx dz))
      (t (vfx-step-dust x z dx dz)))
    nil))

(defun-fast vfx-rift (x0 z0 x1 z1 cutting)
  "KUKAN-GIRI's rift along (x0 z0)->(x1 z1) at chest height (§4.2 cups row, Phase 5: drawn). While it waits: a thin
REIATSU lens slit (yellow with a white core) with a white HIT line in it, trembling on twos (the tell); CUTTING (its
2 f): a wide white HIT lens over a wider REIATSU one (the ink gash that stays is VFX-RIFT-GASH's stamp)."
  (with-floats (x0 z0 x1 z1)
    (let* ((dr (drawing-no)) (tr (* 0.05f0 (- (hash01 dr 3f0) 0.5f0))) (y (+ 1.15f0 tr)) (sd (i->f (mod (f->i dr) 5)))
           (mx (* 0.5f0 (+ x0 x1))) (mz (* 0.5f0 (+ z0 z1))))
      (declare (single-float dr tr y sd mx mz))
      (fx-crescent x0 y z0 x1 y z1 mx (+ y 0.02f0) mz (if cutting 0.2f0 0.065f0) :lens 0.08f0 (+ 20f0 sd) +pal-reiatsu+ 0.95f0 :push 0.2f0)
      (fx-crescent x0 y z0 x1 y z1 mx (+ y 0.02f0) mz (if cutting 0.1f0 0.018f0) :lens 0.04f0 (+ 25f0 sd) +pal-hit+ 0.98f0 :push 0.24f0)
      nil)))

(defun-fast vfx-rift-gash (x z dx dz)
  "KUKAN-GIRI's rift cuts: the ink gash along it (the rift's frame: X Z its owner's feet at the cut, (DX DZ) along it; the
rift runs 1.0 -> 4.4 m at 1.15 m, hazards.lisp)."
  (with-floats (x z dx dz)
    (stamp :gash (+ x dx) 1.15f0 (+ z dz) :dx dx :dy 0.0 :dz dz :scale 3.4)
    nil))

(defun-fast vfx-smoke-puffs (x y z n)
  "N BLACK SMOKE puffs rising at (x y z): a scorched attacker's arm, a burnout."
  (declare (fixnum n))
  (with-floats (x y z)
    (dotimes (i n)
      (%t-blob (+ x (rnd-range -0.15f0 0.15f0)) y (+ z (rnd-range -0.15f0 0.15f0)) (rnd-range -0.3f0 0.3f0) (rnd-range 0.8f0 1.6f0)
               (rnd-range -0.3f0 0.3f0) (rnd-range 0.6f0 1.0f0) (rnd-range 0.12f0 0.22f0) -0.4f0 0.3f0 +pal-black-smoke+))
    nil))

(defun-fast vfx-step-dust (x z dx dz)
  "Step / dash start at feet (x z) moving along (dx dz): 3 DUST puffs kicked back."
  (with-floats (x z dx dz)
    (dotimes (i 3)
      (%t-blob (+ x (rnd-range -0.2f0 0.2f0)) 0.12f0 (+ z (rnd-range -0.2f0 0.2f0))
               (- (* 2f0 dx) (rnd-range -0.6f0 0.6f0)) (rnd-range 0.3f0 0.8f0) (- (* 2f0 dz) (rnd-range -0.6f0 0.6f0))
               (rnd-range 0.4f0 0.6f0) (rnd-range 0.14f0 0.22f0) -0.2f0 0.25f0 +pal-dust+))
    nil))

(defun vfx-shockwave (x z r life &key rgb pal)
  "Expanding toon ground ring at (x z) to radius R (Phase 5: every shockwave is drawn). PAL (a toon palette) or RGB, mapped
to the nearest of the notan palettes: orange -> FIRE, yellow -> REIATSU, else HIT white; DUST (the :land stamp) also
kicks up 4 dust puffs. LIFE is kept for the call shape (the stamp's envelope times it)."
  (declare (ignore life))
  (let ((pal (or pal (if (and rgb (< (second rgb) 0.7)) +pal-fire+ (if (and rgb (< (third rgb) 0.6)) +pal-reiatsu+ +pal-hit+)))))
    (if (= pal +pal-dust+)
        (progn (stamp :land x 0.0 z :scale (/ r 2.5))
               (dotimes (i 4)
                 (let ((a (rnd-range 0.0 6.2832)))
                   (%t-blob (f32 (+ x (* 0.3 (cos a)))) 0.12f0 (f32 (+ z (* 0.3 (sin a)))) (f32 (* 2.0 (cos a))) 0.4f0 (f32 (* 2.0 (sin a)))
                            0.6f0 0.2f0 -0.2f0 0.25f0 +pal-dust+))))
        (stamp :ring x 0.0 z :scale (/ r 2.5) :n pal)))
  nil)
