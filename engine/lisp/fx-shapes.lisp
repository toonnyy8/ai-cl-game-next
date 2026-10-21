;;;; fx-shapes.lisp — the fx-batch drawing kit, stateless (loads before fx.lisp, whose pools use its macros): the toon clock,
;;;; palettes and envelope, the 0 B toon kit macros and shape bodies (stars, shards, crescents, walls, discs, HASH01,
;;;; %TRING, TOON-RIBBON, ...), camera-facing ribbons (FX-RIBBON), flat ground sectors (FX-SECTOR) and the screen
;;;; punctuation (focus / speed lines, ink splash). Pools (particles, rings, debris, trails) stay in fx.lisp.
(in-package :engine)

;;; ---------------------------------------------------------------- toon effects: clock, palettes, envelope
;;; The toon fx batch (WITH-FX-VERTS :toon, fx-toon.frag.wgsl; docs/style/STYLE_STORM_DESIGN.md §3) draws hard,
;;; inked shapes in one of 16 palettes. A toon vertex's colour lanes are HEAT (0..1: ribbons run base 1 to
;;; tip 0.2; fan shapes: 0 centre .. 1 outline), SEED (a shape's noise, 0..999; < 0 = "along" shape, +1000 =
;;; the charcoal style), WOBBLE (0..0.5 silhouette boil) and TOON-A (palette + presence K 0.01..0.98, + 16 for a
;;; fan shape). Presence erodes the shape: 0.98 whole, toward 0 gone (matter perforates, ribbons lose
;;; their tip first). Their noise steps on the FX CLOCK (24 Hz ticks: fire / energy on twos, matter on
;;; threes), which advances only by the effects' dt: it stops while the game pauses.
(defconstant +pal-fire+ 0f0) (defconstant +pal-ember+ 1f0) (defconstant +pal-reiatsu+ 2f0) (defconstant +pal-ink+ 3f0)
(defconstant +pal-steel+ 4f0) (defconstant +pal-hit+ 5f0) (defconstant +pal-smoke+ 6f0) (defconstant +pal-dust+ 7f0)
(defconstant +pal-ash+ 8f0) (defconstant +pal-soul+ 9f0) (defconstant +pal-blood+ 10f0) (defconstant +pal-black-smoke+ 11f0)
(defconstant +pal-blue+ 12f0 "SOUL DUEL's BLUE burst (energy, a coloured edge).")
(defconstant +pal-jade+ 13f0 "SOUL DUEL's muted jade (an ink tone, not a spot hue: energy with a coloured edge).")
(defconstant +pal-gold+ 14f0 "SOUL DUEL's muted gold #B89A5A (energy with a coloured edge).")
(defconstant +pal-flame+ 15f0 "SOUL DUEL's orange flame (fire style; core #FADBA5, body #F18349, shade #8E4737): Yamamoto's Bankai
West garb (canon manga colour). Palette 15 is the last: 16 is TOON-A's fan flag.")

(defmacro fx-clock () "The fx clock in seconds (*FX-CLOCK*, render.lisp)." `(aref (the f32vec *fx-clock*) 0))
(defun-fast fx-clock-advance (dt)
  "Advance the fx clock by DT, this frame's effect seconds (0 while paused, held or frozen)."
  (declare (single-float dt))
  (let* ((c *fx-clock*)) (declare (type f32vec c)) (setf (aref c 0) (+ (aref c 0) dt)))
  nil)
(defmacro sage (age rate)
  "AGE (seconds) quantised to the fx clock's drawings of RATE ticks (1 ones, 2 twos, 3 threes at 24 Hz):
AGE - mod(clock, RATE/24), at least 0. Every effect sampled with it changes on the same drawings as the
toon shader's noise. AGE and RATE: single-float forms."
  `(f-max 0f0 (- ,age (f-mod (fx-clock) (/ ,rate 24f0)))))
(defmacro toon-a (p k &optional fan)
  "The toon vertex's alpha lane: palette P (0..15, a +PAL-...+ constant or a float form) + presence K
clamped to 0.01..0.98; FAN T adds 16 (the fan-shape flag of FX-STAR / FX-SHARD)."
  `(+ ,(if (numberp p) (float (+ p (if fan 16 0)) 1f0) (if fan `(+ 16f0 ,p) p)) (f-clamp ,k 0.01f0 0.98f0)))
(defmacro %h01 (i seed)
  "Stable pseudo-random 0..1 of the float forms I and SEED (a sine hash: shapes that must not change per frame)."
  `(let* ((%v (* 43758.547f0 (f-sin (+ (* ,i 12.9898f0) (* ,seed 78.233f0)))))) (declare (single-float %v)) (- %v (i->f (f->i %v)))))
;; HASH01 is the same sine hash folded differently: |v| mod 1 where %H01 is v - floor(v). They agree for v >= 0 only,
;; so the two give different (both stable) shapes: never alias one to the other (the looks built on each would change).
(defmacro hash01 (i seed)
  "Stable pseudo-random 0..1 of (I SEED) — for shapes that must not change every frame."
  `(f-mod (f-abs (* 43758.547f0 (f-sin (+ (* ,i 12.9898f0) (* ,seed 78.233f0))))) 1f0))

(defmacro fx-envelope ((scale k flash phase) (age flash-f grow hold out &key (anticipate 0)) &body body)
  "Bind SCALE, K (presence), FLASH (1 on the flash frame) and PHASE (0 anticipation, 1 flash, 2 grow,
3 hold, 4 out, 5 done) for AGE seconds into a one-shot drawn effect, then run BODY. The counts are 60 Hz
frames (docs/style/STYLE_STORM_DESIGN.md §3.4): ANTICIPATE (scale 1 -> 0.8; the caller adds converging
shards), FLASH (a white disc), GROW (scale 0.6 -> 1.1, ease-out), HOLD (1.0), OUT (K 0.98 -> 0 erodes
the shape, scale 1.0 -> 1.05). Pass a SAGE'd age so the envelope steps with the drawings. All numbers
single-float forms or literals; zero consing."
  (let ((f (gensym "F")) (a (gensym "A")) (fl (gensym "FL")) (gr (gensym "GR")) (ho (gensym "HO")) (ou (gensym "OU")) (u (gensym "U")))
    `(let* ((,f (* ,age 60f0)) (,a (float ,anticipate 1f0)) (,fl (float ,flash-f 1f0)) (,gr (float ,grow 1f0))
            (,ho (float ,hold 1f0)) (,ou (float ,out 1f0)) (,u 0f0)
            (,scale 1f0) (,k 0.98f0) (,flash 0f0) (,phase 0))
       (declare (single-float ,f ,a ,fl ,gr ,ho ,ou ,u ,scale ,k ,flash) (fixnum ,phase) (ignorable ,scale ,k ,flash ,phase))
       (if (< ,f ,a)
           (setf ,scale (- 1f0 (* 0.2f0 (/ ,f (f-max ,a 1f0)))))
           (progn
             (setf ,f (- ,f ,a))
             (cond ((< ,f ,fl) (setf ,scale 0.6f0 ,flash 1f0 ,phase 1))
                   ((< ,f (+ ,fl ,gr)) (setf ,u (/ (- ,f ,fl) (f-max ,gr 1f0))
                                             ,scale (+ 0.6f0 (* 0.5f0 (- 1f0 (* (- 1f0 ,u) (- 1f0 ,u))))) ,phase 2))
                   ((< ,f (+ ,fl ,gr ,ho)) (setf ,phase 3))
                   ((< ,f (+ ,fl ,gr ,ho ,ou)) (setf ,u (/ (- ,f ,fl ,gr ,ho) (f-max ,ou 1f0))
                                                    ,k (* 0.98f0 (- 1f0 ,u)) ,scale (+ 1f0 (* 0.05f0 ,u)) ,phase 4))
                   (t (setf ,k 0f0 ,phase 5)))))
       ,@body)))

(defmacro %toward-eye ((x y z sc) push &body body)
  "Rebind X Y Z moved PUSH metres toward the camera eye (at most half way) and SC = the size factor that
keeps the screen size (new distance / old). Toon billboards and fans are pushed so they never slice
bodies or the floor with a straight depth line."
  `(let* ((%e (camera-eye *camera*)) (%dx (- (aref %e 0) ,x)) (%dy (- (aref %e 1) ,y)) (%dz (- (aref %e 2) ,z))
          (%d (f-max 1f-3 (f-hypot %dx %dy %dz))) (%p (f-min ,push (* 0.5f0 %d)))
          (,x (+ ,x (* %p (/ %dx %d)))) (,y (+ ,y (* %p (/ %dy %d)))) (,z (+ ,z (* %p (/ %dz %d)))) (,sc (/ (- %d %p) %d)))
     (declare (type f32vec %e) (single-float %dx %dy %dz %d %p ,x ,y ,z ,sc))
     ,@body))

;;; ---------------------------------------------------------------- the toon kit (0 B macros)
;;; Small macros the toon looks are written with: every argument a single-float form, nothing consed. Shapes on
;;; the ground (%TRING, %SECTOR-VERTS) and along an axis (TOON-RIBBON, %TONGUE) write the toon batch directly;
;;; %T-BLOB / %T-SHARD are toon particles; %LIGHT is ADD-POINT-LIGHT without boxing; the rest place a layer
;;; (the camera's axes, the view ray, the fx clock's drawings).
(defmacro drawing-no (&optional (per-second 12f0))
  "The fx clock's drawing number (0..63): 12 a second = twos (fire, energy), 8 = threes (smoke, charcoal)."
  `(i->f (logand (f->i (* ,per-second (fx-clock))) 63)))

(defmacro with-cam ((rx ry rz ux uy uz) &body body)
  "Bind the caller's six names RX RY RZ UX UY UZ to the camera's right / up axes for camera-facing shapes:
(with-cam (rx ry rz ux uy uz) ...). The names come from the call, so they are the caller's own symbols."
  `(let* ((%rt (camera-right *camera*)) (%up (camera-upv *camera*)))
     (declare (type f32vec %rt %up) (ignorable %rt %up))
     (let* ((,rx (aref %rt 0)) (,ry (aref %rt 1)) (,rz (aref %rt 2))
            (,ux (aref %up 0)) (,uy (aref %up 1)) (,uz (aref %up 2)))
       (declare (single-float ,rx ,ry ,rz ,ux ,uy ,uz) (ignorable ,rx ,ry ,rz ,ux ,uy ,uz))
       ,@body)))

(defmacro %away-from-eye ((x y z) d &body body)
  "Rebind X Y Z moved D metres along the view ray (away from the camera eye; negative D = toward it): a layer
that must sit behind (or in front of) another camera-facing layer without fighting it for depth."
  `(let* ((%e (camera-eye *camera*)) (%dx (- ,x (aref %e 0))) (%dy (- ,y (aref %e 1))) (%dz (- ,z (aref %e 2)))
          (%l (f-max 1f-3 (f-hypot %dx %dy %dz)))
          (,x (+ ,x (* ,d (/ %dx %l)))) (,y (+ ,y (* ,d (/ %dy %l)))) (,z (+ ,z (* ,d (/ %dz %l)))))
     (declare (type f32vec %e) (single-float %dx %dy %dz %l ,x ,y ,z))
     ,@body))

(defmacro %near-cam (x z near far)
  "0 when the camera eye stands within NEAR m (on the ground plane) of the point (X Z), rising to 1 at FAR: tall
columns thin and shorten close to the lens (e.g. a pillar beside a behind-the-shoulder camera would fill the frame)."
  `(let* ((%e (camera-eye *camera*)) (%dx (- ,x (aref %e 0))) (%dz (- ,z (aref %e 2))))
     (declare (type f32vec %e) (single-float %dx %dz))
     (f-clamp (/ (- (f-hypot %dx %dz) ,near) (- ,far ,near)) 0f0 1f0)))

(defmacro %t-blob (x y z vx vy vz life size grav wob pal)
  "One toon particle puff / flame / droplet (+P-T-BLOB+)."
  `(fx-emit +p-t-blob+ ,x ,y ,z ,vx ,vy ,vz ,life ,size ,grav ,wob 0f0 0f0 ,pal))
(defmacro %t-shard (x y z vx vy vz life size grav pal)
  "One toon shard particle (+P-T-SHARD+): a kite along its velocity."
  `(fx-emit +p-t-shard+ ,x ,y ,z ,vx ,vy ,vz ,life ,size ,grav 0.05f0 0f0 0f0 ,pal))

(defmacro %tring (x y z r w pal k seed &optional (segs 32))
  "A flat toon ring on the ground at height Y (+2 cm), radius R, band half-width W, both band edges inked.
The ring is an along shape whose heat varies around it, so it breaks into arcs as K fades. SEGS must be a literal
(it is folded at expansion time)."
  `(let* ((cx ,x) (cy (+ ,y 0.02f0)) (cz ,z) (ri (f-max 0f0 (- ,r ,w))) (ro (+ ,r ,w)) (pk (toon-a ,pal ,k))
          (sd (- -1f0 ,seed)) (da (/ 6.2831855f0 ,(float segs 1f0))))
     (declare (single-float cx cy cz ri ro pk sd da))
     (with-fx-verts (d o :toon ,(* 6 segs))
       (dotimes (i ,segs)
         (let* ((a0 (* da (i->f i))) (a1 (+ a0 da)) (c0 (f-cos a0)) (s0 (f-sin a0)) (c1 (f-cos a1)) (s1 (f-sin a1))
                (h0 (+ 0.3f0 (* 0.7f0 (f-abs (f-sin (+ (* 2.5f0 a0) sd)))))) (h1 (+ 0.3f0 (* 0.7f0 (f-abs (f-sin (+ (* 2.5f0 a1) sd)))))))
           (declare (single-float a0 a1 c0 s0 c1 s1 h0 h1))
           (vtx (+ cx (* ri c0)) cy (+ cz (* ri s0)) -1f0 0f0 h0 sd 0.12f0 pk)
           (vtx (+ cx (* ro c0)) cy (+ cz (* ro s0)) 1f0 0f0 h0 sd 0.12f0 pk)
           (vtx (+ cx (* ro c1)) cy (+ cz (* ro s1)) 1f0 0f0 h1 sd 0.12f0 pk)
           (vtx (+ cx (* ri c0)) cy (+ cz (* ri s0)) -1f0 0f0 h0 sd 0.12f0 pk)
           (vtx (+ cx (* ro c1)) cy (+ cz (* ro s1)) 1f0 0f0 h1 sd 0.12f0 pk)
           (vtx (+ cx (* ri c1)) cy (+ cz (* ri s1)) -1f0 0f0 h1 sd 0.12f0 pk))))))

(declaim (type f32vec *light-v*))
(defvar *light-v* (make-f32 8) "%LIGHT's record (ADD-POINT-LIGHT-V: no boxed float arguments).")
(defmacro %light (x y z r g b radius intensity priority)
  "ADD-POINT-LIGHT for computed single-float positions without boxing them (0 B)."
  `(let* ((%v *light-v*))
     (declare (type f32vec %v))
     (setf (aref %v 0) ,x (aref %v 1) ,y (aref %v 2) ,z (aref %v 3) ,r (aref %v 4) ,g (aref %v 5) ,b
           (aref %v 6) ,radius (aref %v 7) ,intensity)
     (add-point-light-v %v 0 ,priority)))

;;; Toon shape primitives: macros that write their float arguments into *TN-ARGS* and call the body
;;; (%FX-STAR ...), so a call conses nothing (the FX-RIBBON pattern). PAL = palette (0..11), K = presence.
(declaim (type f32vec *tn-args*))
(defvar *tn-args* (make-f32 16) "FX-STAR / FX-SHARD / FX-CRESCENT / FX-WALL arguments (see each).")
(defmacro %tn-call (fn args &rest fixargs)
  (let ((a (gensym "A")))
    `(let* ((,a *tn-args*))
       (declare (type f32vec ,a))
       (setf ,@(loop for x in args for i from 0 append `((aref ,a ,i) ,x)))
       (,fn ,@fixargs))))
(defmacro fx-star (x y z r0 r1 n rot dirx diry wobble seed pal k &key (push 0.3f0))
  "An irregular toon star (hit spark; docs/style/STYLE_STORM_DESIGN.md §3.4) facing the camera at (X Y Z): N spikes
of length R1 x 0.5..1.4 (hashed from SEED), valleys at R0, angles jittered +-12 degrees, ROT turning it;
the spike nearest the screen direction (DIRX DIRY) (camera right / up; 0 0 = none) is 1.7x long, a second
one opposite on odd seeds 1.25x. R0 >= R1 = a regular N-gon (the guard hexagon). One outline (a fan shape:
its field is 0 at the centre, 1 on the straight edges). Pushed PUSH m toward the eye (screen size kept).
Float forms except N (fixnum)."
  `(%tn-call %fx-star (,x ,y ,z ,r0 ,r1 ,rot ,dirx ,diry ,wobble ,seed ,pal ,k ,push) ,n))
(defmacro fx-shard (x y z dx dy dz len w wobble seed pal k &key (push 0.1f0))
  "A toon kite (shard) centred at (X Y Z) pointing along the unit direction (DX DY DZ), LEN long (0.6 ahead,
0.4 behind), half-width W, facing the camera; a fan shape (one outline)."
  `(%tn-call %fx-shard (,x ,y ,z ,dx ,dy ,dz ,len ,w ,wobble ,seed ,pal ,k ,push)))
(defmacro fx-crescent (x0 y0 z0 x1 y1 z1 bx by bz w profile wobble seed pal k &key (push 0.15f0))
  "A toon crescent: a camera-facing strip along the quadratic Bezier (X0..) -> (X1..) with control point
(BX BY BZ), 8 segments. PROFILE :lens = half-width W sin(pi u); :comet = W u^0.4 (1-u)^0.15 with u from the
tail (x0) to the blade (x1): a sword smear or an impact mark. An along shape: the tail erodes first."
  `(%tn-call %fx-crescent (,x0 ,y0 ,z0 ,x1 ,y1 ,z1 ,bx ,by ,bz ,w ,wobble ,seed ,pal ,k ,push)
             ,(if (keywordp profile) (if (eq profile :comet) 1 0) `(if (eq ,profile :comet) 1 0))))
(defmacro fx-disc (x y z r wobble seed pal k &key (push -1f0))
  "A toon disc / puff of radius R facing the camera at (X Y Z) (FX-BILLBOARD :toon without the boxed call),
pushed PUSH m toward the eye (default 0.8 R) at the same screen size. Matter palettes draw a lit puff."
  `(%tn-call %fx-disc (,x ,y ,z ,r ,wobble ,seed ,pal ,k ,push)))
(defmacro fx-wall (xs zs n height scallops wobble seed pal k)
  "A continuous toon wall (a flame wall) standing on the ground polyline of N points XS / ZS (f32vecs),
HEIGHT m at its middle (0.6 x at the quarter points: tallest in the middle), its top cut into SCALLOPS
pointed tongues (5-7, each 0.75..1 x high, hashed from SEED: pass a seed that changes per drawing to
re-draw them) over rounded valleys at 0.45 x, tapering to the ground at both ends. An along shape:
uv.x = the height fraction (the field; the silhouette follows the top), uv.y = 0.8 x the distance along
the wall (only the noise reads it, so the core and shade break up along the wall), heat 1 at the base ..
0.2 at the top, so fire keeps its dark edge on the lower third (the ends and valleys) and fades from the top.
N and SCALLOPS fixnums."
  `(%tn-call %fx-wall (,height ,wobble ,seed ,pal ,k) ,xs ,zs ,n ,scallops))

(defmacro %bb-verts (x y z sx sy sz ux uy uz r g b a)
  "Emit a camera-facing quad inside WITH-FX-VERTS: half axes S (right) and U (up)."
  `(progn
     (vtx (- ,x ,sx ,ux) (- ,y ,sy ,uy) (- ,z ,sz ,uz) -1f0 -1f0 ,r ,g ,b ,a)
     (vtx (- (+ ,x ,sx) ,ux) (- (+ ,y ,sy) ,uy) (- (+ ,z ,sz) ,uz) 1f0 -1f0 ,r ,g ,b ,a)
     (vtx (+ ,x ,sx ,ux) (+ ,y ,sy ,uy) (+ ,z ,sz ,uz) 1f0 1f0 ,r ,g ,b ,a)
     (vtx (- ,x ,sx ,ux) (- ,y ,sy ,uy) (- ,z ,sz ,uz) -1f0 -1f0 ,r ,g ,b ,a)
     (vtx (+ ,x ,sx ,ux) (+ ,y ,sy ,uy) (+ ,z ,sz ,uz) 1f0 1f0 ,r ,g ,b ,a)
     (vtx (+ (- ,x ,sx) ,ux) (+ (- ,y ,sy) ,uy) (+ (- ,z ,sz) ,uz) -1f0 1f0 ,r ,g ,b ,a)))

;;; ---------------------------------------------------------------- ribbons (camera-facing tapered strips)
;;; A tapering strip from a base point along an axis, turned to face the camera around that axis,
;;; soft across its width, colour/alpha lerped base → tip, width and sideways sway flickering with
;;; PH. Flames, pillars, dome walls, auras and blade sheaths are layers of it.
;;; FX-RIBBON (a macro) writes its arguments into *RIBBON-ARGS*, so the call conses nothing.
(declaim (type f32vec *ribbon-args*))
(defvar *ribbon-args* (make-f32 18) "x y z ax ay az w0 w1 r0 g0 b0 a0 r1 g1 b1 a1 phase sway")

(defun-fast %fx-ribbon (segs mode)
  "FX-RIBBON's body: SEGS segments into the MODE (:add / :alpha) fx batch."
  (declare (fixnum segs))
  (let* ((rb *ribbon-args*) (eye (camera-eye *camera*)) (rt (camera-right *camera*))
         (x (aref rb 0)) (y (aref rb 1)) (z (aref rb 2)) (ax (aref rb 3)) (ay (aref rb 4)) (az (aref rb 5))
         (l (f-hypot ax ay az)))
    (declare (type f32vec rb eye rt) (single-float x y z ax ay az l))
    (when (> l 1f-4)
      (let* ((nx (/ ax l)) (ny (/ ay l)) (nz (/ az l))
             (ex (- (aref eye 0) x)) (ey (- (aref eye 1) y)) (ez (- (aref eye 2) z))
             (sx (- (* ny ez) (* nz ey))) (sy (- (* nz ex) (* nx ez))) (sz (- (* nx ey) (* ny ex)))
             (sl (f-hypot sx sy sz))
             (w0 (aref rb 6)) (w1 (aref rb 7)) (ph (aref rb 16)) (sw (aref rb 17))
             (inv (/ 1f0 (i->f segs)))
             (lx 0f0) (ly 0f0) (lz 0f0) (qx 0f0) (qy 0f0) (qz 0f0) (pr 0f0) (pg 0f0) (pb 0f0) (pa 0f0))
        (declare (single-float nx ny nz ex ey ez sx sy sz sl w0 w1 ph sw inv lx ly lz qx qy qz pr pg pb pa))
        (if (< sl 1f-5)
            (setf sx (aref rt 0) sy (aref rt 1) sz (aref rt 2))
            (setf sx (/ sx sl) sy (/ sy sl) sz (/ sz sl)))
        (with-fx-verts (d o mode (* 6 segs))
          (dotimes (i (1+ segs))
            (let* ((u (* (i->f i) inv))
                   (off (* sw u (+ (f-sin (+ ph (* 5f0 u))) (* 0.5f0 (f-sin (+ (* 1.7f0 ph) (* 11f0 u)))))))
                   (w (* (+ w0 (* (- w1 w0) u)) (+ 1f0 (* 0.14f0 (f-sin (+ (* 2.3f0 ph) (* 9f0 u)))))))
                   (cx (+ x (* ax u) (* sx off))) (cy (+ y (* ay u) (* sy off))) (cz (+ z (* az u) (* sz off)))
                   (r (+ (aref rb 8) (* u (- (aref rb 12) (aref rb 8)))))
                   (g (+ (aref rb 9) (* u (- (aref rb 13) (aref rb 9)))))
                   (b (+ (aref rb 10) (* u (- (aref rb 14) (aref rb 10)))))
                   (a (+ (aref rb 11) (* u (- (aref rb 15) (aref rb 11)))))
                   (mx (- cx (* sx w))) (my (- cy (* sy w))) (mz (- cz (* sz w)))
                   (kx (+ cx (* sx w))) (ky (+ cy (* sy w))) (kz (+ cz (* sz w))))
              (declare (single-float u off w cx cy cz r g b a mx my mz kx ky kz))
              (when (> i 0)
                (vtx lx ly lz -1f0 0f0 pr pg pb pa) (vtx qx qy qz 1f0 0f0 pr pg pb pa) (vtx kx ky kz 1f0 0f0 r g b a)
                (vtx lx ly lz -1f0 0f0 pr pg pb pa) (vtx kx ky kz 1f0 0f0 r g b a) (vtx mx my mz -1f0 0f0 r g b a))
              (setf lx mx ly my lz mz qx kx qy ky qz kz pr r pg g pb b pa a))))))))

(defmacro fx-ribbon (x y z ax ay az w0 w1 r0 g0 b0 a0 r1 g1 b1 a1 ph sway &key (segs 6) (mode :add))
  "Draw a ribbon from (X Y Z) along the axis (AX AY AZ): half-width W0 at the base, W1 at the tip,
colour (R0 G0 B0 A0) at the base, (R1 G1 B1 A1) at the tip, PH the flicker phase, SWAY the sideways
sway amplitude (m), SEGS segments. All numeric arguments must be single-float expressions (no
boxing). A0/A1 < 0 = additive without the white hot core; > 0 whitens the centre line (hot core)."
  (let ((rb (gensym "RB")))                       ; a gensym: the arguments may name any variable
    `(let* ((,rb *ribbon-args*))
       (declare (type f32vec ,rb))
       (setf (aref ,rb 0) ,x (aref ,rb 1) ,y (aref ,rb 2) ,z (aref ,rb 3) ,ax (aref ,rb 4) ,ay (aref ,rb 5) ,az
             (aref ,rb 6) ,w0 (aref ,rb 7) ,w1 (aref ,rb 8) ,r0 (aref ,rb 9) ,g0 (aref ,rb 10) ,b0 (aref ,rb 11) ,a0
             (aref ,rb 12) ,r1 (aref ,rb 13) ,g1 (aref ,rb 14) ,b1 (aref ,rb 15) ,a1 (aref ,rb 16) ,ph (aref ,rb 17) ,sway)
       (%fx-ribbon ,segs ,mode))))

(defmacro toon-ribbon ((x y z) (ax ay az) (w0 w1) &key (heat '(1f0 0.2f0)) seed (wob 0.3f0) pal k k1 (ph 0f0) (sway 0f0)
                                                       (segs 6))
  "FX-RIBBON :mode :toon with its colour lanes named: HEAT (base tip) = the heat lanes, SEED and WOB (both ends), and
the presence lanes: with PAL, (TOON-A PAL K) at the base and (TOON-A PAL K1) at the tip (K1 defaults to K); without
PAL, K / K1 are the lane values themselves (an already made TOON-A). Expands to the one FX-RIBBON call with the
argument forms in its positional order (forms repeated there are repeated here, as written by hand)."
  (destructuring-bind (h0 h1) heat
    (let ((a0 (if pal `(toon-a ,pal ,k) k)) (a1 (if pal `(toon-a ,pal ,(or k1 k)) (or k1 k))))
      `(fx-ribbon ,x ,y ,z ,ax ,ay ,az ,w0 ,w1 ,h0 ,seed ,wob ,a0 ,h1 ,seed ,wob ,a1 ,ph ,sway :segs ,segs :mode :toon))))

(defmacro %tongue (x y z ax ay az w pal k seed ph sway &key (segs 6) (wob 0.3f0))
  "One toon flame tongue (an along ribbon, w1 = 0: heat 1 at the base .. 0.2 at the tip, so it erodes from the tip
as K fades) from (X Y Z) along (AX AY AZ), base half-width W, palette PAL, presence K; SEED (made negative: along)
re-draws it when it changes (pass a per-drawing seed). A macro: 0 B."
  `(let* ((%sd (- -1f0 (f-abs ,seed))) (%pk (toon-a ,pal ,k)))
     (declare (single-float %sd %pk))
     (toon-ribbon (,x ,y ,z) (,ax ,ay ,az) (,w 0f0) :seed %sd :wob ,wob :k %pk :ph ,ph :sway ,sway :segs ,segs)))

;;; ---------------------------------------------------------------- ground sectors
(defmacro %sector-verts (mode segs x y z r0 r1 yaw half l0 l1 l2 l3)
  "FX-SECTOR's shape as a macro (0 B: no boxed arguments): a flat sector at height Y (+3 cm) between radii R0 and R1,
centred on YAW (forward = FWD-X / FWD-Z of it), +-HALF radians, SEGS segments (a literal or a variable: it is evaluated several
times) into the MODE batch (:toon: L0..L3 = heat seed wobble TOON-A; else r g b a); uv across the radii.
Single-float forms."
  `(let* ((cx ,x) (cy (+ ,y 0.03f0)) (cz ,z) (ri ,r0) (ro ,r1) (a0 (- ,yaw ,half))
          (da (/ (* 2f0 ,half) ,(if (integerp segs) (float segs 1f0) `(i->f ,segs))))
          (ht ,l0) (sd ,l1) (wb ,l2) (pk ,l3))
     (declare (single-float cx cy cz ri ro a0 da ht sd wb pk))
     (with-fx-verts (d o ,mode ,(if (integerp segs) (* 6 segs) `(* 6 ,segs)))
       (dotimes (k ,segs)
         (let* ((t0 (+ a0 (* da (i->f k)))) (t1 (+ t0 da))
                (c0 (- (f-sin t0))) (s0 (- (f-cos t0))) (c1 (- (f-sin t1))) (s1 (- (f-cos t1))))
           (declare (single-float t0 t1 c0 s0 c1 s1))
           (vtx (+ cx (* ri c0)) cy (+ cz (* ri s0)) 0f0 -1f0 ht sd wb pk)
           (vtx (+ cx (* ro c0)) cy (+ cz (* ro s0)) 0f0 1f0 ht sd wb pk)
           (vtx (+ cx (* ro c1)) cy (+ cz (* ro s1)) 0f0 1f0 ht sd wb pk)
           (vtx (+ cx (* ri c0)) cy (+ cz (* ri s0)) 0f0 -1f0 ht sd wb pk)
           (vtx (+ cx (* ro c1)) cy (+ cz (* ro s1)) 0f0 1f0 ht sd wb pk)
           (vtx (+ cx (* ri c1)) cy (+ cz (* ri s1)) 0f0 -1f0 ht sd wb pk))))))

(defun-fast fx-sector (x y z r0 r1 yaw half r g b a &key (mode :add) (segs 16))
  "Flat annular sector between radii R0 and R1 at height Y, centred on direction YAW (forward =
(FWD-X yaw, FWD-Z yaw)), spanning ±HALF radians (HALF ≥ pi = full ring). Soft toward both radii.
A telegraph cone, a fire front, a shock ring."
  (declare (fixnum segs))
  (let* ((x (f32 x)) (y (f32 y)) (z (f32 z)) (r0 (f32 r0)) (r1 (f32 r1)) (yaw (f32 yaw)) (half (f32 half))
         (r (f32 r)) (g (f32 g)) (b (f32 b)) (a (f32 a)))
    (declare (single-float x y z r0 r1 yaw half r g b a))
    (%sector-verts mode segs x y z r0 r1 yaw half r g b a)))

;;; ---------------------------------------------------------------- toon shape primitives (bodies)
(defun-fast %fx-star (n)
  (declare (fixnum n))
  (let* ((a *tn-args*) (x (aref a 0)) (y (aref a 1)) (z (aref a 2)) (r0 (aref a 3)) (r1 (aref a 4)) (rot (aref a 5))
         (dx (aref a 6)) (dy (aref a 7)) (wob (aref a 8)) (seed (aref a 9)) (pk (toon-a (aref a 10) (aref a 11) t))
         (push (aref a 12)) (rt (camera-right *camera*)) (up (camera-upv *camera*))
         (n (max 3 n)) (m (* 2 n)) (dl (f-hypot dx dy)) (poly (>= r0 r1))
         (step (/ 6.2831855f0 (i->f m))) (near (f-cos (/ 3.1415927f0 (i->f n)))))
    (declare (type f32vec a rt up) (fixnum n m)
             (single-float x y z r0 r1 rot dx dy wob seed pk push dl step near))
    (%toward-eye (x y z sc) push
      (let* ((r0 (* r0 sc)) (r1 (* r1 sc)) (px 0f0) (py 0f0) (pz 0f0) (pu 0f0) (pv 0f0))
        (declare (single-float r0 r1 px py pz pu pv))
        (with-fx-verts (d o :toon (* 3 m))
          (dotimes (j (1+ m))
            (let* ((jj (if (= j m) 0 j)) (jf (i->f jj)) (tip (evenp jj))
                   (ang (+ rot (* step jf) (if poly 0f0 (* 0.42f0 (- (%h01 jf seed) 0.5f0)))))
                   (ca (f-cos ang)) (sa (f-sin ang))
                   (dir (if (> dl 1f-4) (/ (+ (* ca dx) (* sa dy)) dl) 0f0))
                   (len (cond (poly (if tip r1 (* r1 near)))
                              (tip (* r1 (+ 0.5f0 (* 0.9f0 (%h01 (+ jf 7.1f0) seed)))
                                      (cond ((> dir near) 1.7f0)
                                            ((and (< dir (- near)) (> (%h01 3.3f0 seed) 0.5f0)) 1.25f0)
                                            (t 1f0))))
                              (t (* r0 (+ 0.75f0 (* 0.5f0 (%h01 (+ jf 3.3f0) seed)))))))
                   (ox (* len (+ (* ca (aref rt 0)) (* sa (aref up 0)))))
                   (oy (* len (+ (* ca (aref rt 1)) (* sa (aref up 1)))))
                   (oz (* len (+ (* ca (aref rt 2)) (* sa (aref up 2)))))
                   (wx (+ x ox)) (wy (+ y oy)) (wz (+ z oz)))
              (declare (fixnum jj) (single-float jf ang ca sa dir len ox oy oz wx wy wz))
              (when (> j 0)
                (vtx x y z 0f0 0f0 0f0 seed wob pk)
                (vtx px py pz pu pv 1f0 seed wob pk)
                (vtx wx wy wz ca sa 1f0 seed wob pk))
              (setf px wx py wy pz wz pu ca pv sa)))))))
  nil)

(defun-fast %fx-shard ()
  (let* ((a *tn-args*) (x (aref a 0)) (y (aref a 1)) (z (aref a 2)) (dx (aref a 3)) (dy (aref a 4)) (dz (aref a 5))
         (len (aref a 6)) (w (aref a 7)) (wob (aref a 8)) (seed (aref a 9)) (pk (toon-a (aref a 10) (aref a 11) t))
         (push (aref a 12)))
    (declare (type f32vec a) (single-float x y z dx dy dz len w wob seed pk push))
    (%toward-eye (x y z sc) push
      (let* ((e (camera-eye *camera*)) (ex (- (aref e 0) x)) (ey (- (aref e 1) y)) (ez (- (aref e 2) z))
             (sx (- (* dy ez) (* dz ey))) (sy (- (* dz ex) (* dx ez))) (sz (- (* dx ey) (* dy ex)))
             (sl (f-max 1f-5 (f-hypot sx sy sz)))
             (len (* len sc)) (w (/ (* w sc) sl)) (f (* 0.6f0 len)) (b (* 0.4f0 len))
             (tx (+ x (* f dx))) (ty (+ y (* f dy))) (tz (+ z (* f dz)))
             (bx (- x (* b dx))) (by (- y (* b dy))) (bz (- z (* b dz)))
             (lx (+ x (* w sx))) (ly (+ y (* w sy))) (lz (+ z (* w sz)))
             (rx (- x (* w sx))) (ry (- y (* w sy))) (rz (- z (* w sz))))
        (declare (type f32vec e) (single-float ex ey ez sx sy sz sl len w f b tx ty tz bx by bz lx ly lz rx ry rz))
        (with-fx-verts (d o :toon 12)
          (vtx x y z 0f0 0f0 0f0 seed wob pk) (vtx tx ty tz 0f0 1f0 1f0 seed wob pk) (vtx lx ly lz -1f0 0f0 1f0 seed wob pk)
          (vtx x y z 0f0 0f0 0f0 seed wob pk) (vtx lx ly lz -1f0 0f0 1f0 seed wob pk) (vtx bx by bz 0f0 -1f0 1f0 seed wob pk)
          (vtx x y z 0f0 0f0 0f0 seed wob pk) (vtx bx by bz 0f0 -1f0 1f0 seed wob pk) (vtx rx ry rz 1f0 0f0 1f0 seed wob pk)
          (vtx x y z 0f0 0f0 0f0 seed wob pk) (vtx rx ry rz 1f0 0f0 1f0 seed wob pk) (vtx tx ty tz 0f0 1f0 1f0 seed wob pk)))))
  nil)

(defun-fast %fx-crescent (comet)
  (declare (fixnum comet))
  (let* ((a *tn-args*) (x0 (aref a 0)) (y0 (aref a 1)) (z0 (aref a 2)) (x1 (aref a 3)) (y1 (aref a 4)) (z1 (aref a 5))
         (bx (aref a 6)) (by (aref a 7)) (bz (aref a 8)) (w (aref a 9)) (wob (aref a 10))
         (seed (- -1f0 (f-abs (aref a 11)))) (pal (aref a 12)) (kk (aref a 13)) (push (aref a 14))
         (pk (toon-a pal kk)) (e (camera-eye *camera*))
         (lx 0f0) (ly 0f0) (lz 0f0) (rx 0f0) (ry 0f0) (rz 0f0) (lh 0f0))
    (declare (type f32vec a e) (single-float x0 y0 z0 x1 y1 z1 bx by bz w wob seed pal kk push pk lx ly lz rx ry rz lh))
    (with-fx-verts (d o :toon 48)
      (dotimes (i 9)
        (let* ((u (* 0.125f0 (i->f i))) (v (- 1f0 u))
               (px (+ (* v v x0) (* 2f0 u v bx) (* u u x1))) (py (+ (* v v y0) (* 2f0 u v by) (* u u y1)))
               (pz (+ (* v v z0) (* 2f0 u v bz) (* u u z1)))
               (tx (+ (* 2f0 v (- bx x0)) (* 2f0 u (- x1 bx)))) (ty (+ (* 2f0 v (- by y0)) (* 2f0 u (- y1 by))))
               (tz (+ (* 2f0 v (- bz z0)) (* 2f0 u (- z1 bz))))
               (ex (- (aref e 0) px)) (ey (- (aref e 1) py)) (ez (- (aref e 2) pz))
               (el (f-max 1f-3 (f-hypot ex ey ez))) (pp (f-min push (* 0.5f0 el)))
               (px (+ px (* pp (/ ex el)))) (py (+ py (* pp (/ ey el)))) (pz (+ pz (* pp (/ ez el))))
               (sx (- (* ty ez) (* tz ey))) (sy (- (* tz ex) (* tx ez))) (sz (- (* tx ey) (* ty ex)))
               (sl (f-max 1f-6 (f-hypot sx sy sz)))
               (hw (if (= comet 1)
                       (* w (ffi:c-inline (u) (:float) :float "powf(#0,0.4f)" :one-liner t)
                          (ffi:c-inline (v) (:float) :float "powf(fmaxf(#0,0.0f),0.15f)" :one-liner t))
                       (* w (f-sin (* 3.1415927f0 u)))))
               (hw (/ (* hw (/ (- el pp) el)) sl))
               (heat (+ 0.2f0 (* 0.8f0 u)))
               (mx (- px (* hw sx))) (my (- py (* hw sy))) (mz (- pz (* hw sz)))
               (nx (+ px (* hw sx))) (ny (+ py (* hw sy))) (nz (+ pz (* hw sz))))
          (declare (single-float u v px py pz tx ty tz ex ey ez el pp sx sy sz sl hw heat mx my mz nx ny nz))
          (when (> i 0)
            (vtx lx ly lz -1f0 0f0 lh seed wob pk) (vtx rx ry rz 1f0 0f0 lh seed wob pk) (vtx nx ny nz 1f0 0f0 heat seed wob pk)
            (vtx lx ly lz -1f0 0f0 lh seed wob pk) (vtx nx ny nz 1f0 0f0 heat seed wob pk) (vtx mx my mz -1f0 0f0 heat seed wob pk))
          (setf lx mx ly my lz mz rx nx ry ny rz nz lh heat)))))
  nil)

(defun-fast %fx-wall (xs zs n scallops)
  (declare (type f32vec xs zs) (fixnum n scallops))
  (let* ((a *tn-args*) (height (aref a 0)) (wob (aref a 1)) (seed (aref a 2)) (pk (toon-a (aref a 3) (aref a 4)))
         (sd (- -1f0 (f-abs seed)))                     ; negative: an along shape
         (cols (* 6 (max 1 scallops))) (inv (/ 1f0 (i->f cols)))   ; 6 columns a tongue: tips and valleys on columns
         (lx 0f0) (lz 0f0) (lh 0f0) (lv 0f0) (v 0f0))
    (declare (type f32vec a) (single-float height wob seed sd pk inv lx lz lh lv v) (fixnum cols))
    (when (>= n 2)
      (with-fx-verts (d o :toon (* 6 cols))
        (dotimes (c (1+ cols))
          (let* ((p (* (i->f (1- n)) inv (i->f c))) (seg (min (- n 2) (f->i p))) (f (- p (i->f seg)))
                 (x (+ (aref xs seg) (* f (- (aref xs (1+ seg)) (aref xs seg)))))
                 (z (+ (aref zs seg) (* f (- (aref zs (1+ seg)) (aref zs seg)))))
                 (u (* inv (i->f c))) (m (- (* 2f0 u) 1f0))
                 (q (* (i->f scallops) u)) (j (min (1- scallops) (f->i q)))  ; the tongue this column is in
                 (tri (- 1f0 (f-abs (- (* 2f0 (- q (i->f j))) 1f0))))       ; 0 valley .. 1 tip
                 (tip (* tri (f-sqrt tri)))                                  ; ^1.5: pointed tips, round valleys
                 (h (* height (- 1f0 (* 0.4f0 m m)) (f-min 1f0 (* 5f0 (f-min u (- 1f0 u))))
                       (+ 0.45f0 (* 0.55f0 tip (+ 0.75f0 (* 0.25f0 (%h01 (i->f j) seed))))))))
            (declare (fixnum seg j) (single-float p f x z u m q tri tip h))
            (when (> c 0)                              ; uv.y = 0.8 x the distance along the wall (the noise's second axis)
              (setf v (+ lv (* 0.8f0 (f-hypot (- x lx) (- z lz)))))
              (vtx lx 0.02f0 lz 0f0 lv 1f0 sd wob pk) (vtx x 0.02f0 z 0f0 v 1f0 sd wob pk) (vtx x h z 1f0 v 0.2f0 sd wob pk)
              (vtx lx 0.02f0 lz 0f0 lv 1f0 sd wob pk) (vtx x h z 1f0 v 0.2f0 sd wob pk) (vtx lx lh lz 1f0 lv 0.2f0 sd wob pk))
            (setf lx x lz z lh h lv v))))))
  nil)

;;; ---------------------------------------------------------------- screen punctuation (UI layer, 0 B per call)
;;; Manga screen effects drawn into the UI batch; DRAWING is the drawing number (a new one reshuffles the
;;; lines: pass the fx clock's drawings, e.g. (floor (* 12 (fx-clock))), so they change on twos).
(defun-fast ui-focus-lines (cx cy n rmin rmax col drawing)
  "Focus lines: N thin wedges from RMAX (off screen) pointing at (CX CY), their tips at RMIN (hashed
+-25 %), hashed angles and widths per DRAWING. COL = (r g b a)."
  (declare (single-float cx cy rmin rmax) (fixnum n drawing))
  (let* ((seed (* 0.37f0 (i->f drawing))) (tau 6.2831855f0) (nf (i->f (max 1 n))))
    (declare (single-float seed tau nf))
    (%col-floats (r g b al) col
      (with-ui-verts (d o (* 3 n))
        (dotimes (i n)
          (let* ((f (i->f i)) (ang (* tau (/ (+ f (* 0.8f0 (- (%h01 f seed) 0.5f0))) nf)))
                 (r0 (* rmin (+ 0.75f0 (* 0.5f0 (%h01 (+ f 1.7f0) seed)))))
                 (w (* rmax (+ 0.003f0 (* 0.011f0 (%h01 (+ f 4.1f0) seed)))))
                 (c (f-cos ang)) (s (f-sin ang)))
            (declare (single-float f ang r0 w c s))
            (uvtx (+ cx (* r0 c)) (+ cy (* r0 s)) r g b al)
            (uvtx (- (+ cx (* rmax c)) (* w s)) (+ cy (* rmax s) (* w c)) r g b al)
            (uvtx (+ cx (* rmax c) (* w s)) (- (+ cy (* rmax s)) (* w c)) r g b al))))))
  nil)

(defun-fast ui-speed-lines (dir n col drawing)
  "Speed lines: N long thin wedges across the screen parallel to the screen angle DIR (radians, 0 =
pointing right, heads toward +DIR), hashed positions and lengths per DRAWING. COL = (r g b a)."
  (declare (single-float dir) (fixnum n drawing))
  (let* ((w (i->f (window-width))) (h (i->f (window-height))) (c (f-cos dir)) (s (f-sin dir))
         (diag (f-hypot w h)) (px (/ h 720f0)) (seed (* 0.53f0 (i->f drawing))))
    (declare (single-float w h c s diag px seed))
    (%col-floats (r g b al) col
      (with-ui-verts (d o (* 3 n))
        (dotimes (i n)
          (let* ((f (i->f i)) (off (* diag (- (%h01 f seed) 0.5f0))) (along (* 0.6f0 diag (- (%h01 (+ f 2.3f0) seed) 0.5f0)))
                 (hl (* 0.5f0 diag (+ 0.15f0 (* 0.3f0 (%h01 (+ f 5.9f0) seed)))))
                 (wd (* px (+ 1.5f0 (* 4f0 (%h01 (+ f 8.3f0) seed)))))
                 (mx (- (+ (* 0.5f0 w) (* along c)) (* off s))) (my (+ (* 0.5f0 h) (* along s) (* off c))))
            (declare (single-float f off along hl wd mx my))
            (uvtx (- mx (* hl c)) (- my (* hl s)) r g b al)
            (uvtx (- (+ mx (* hl c)) (* wd s)) (+ my (* hl s) (* wd c)) r g b al)
            (uvtx (+ mx (* hl c) (* wd s)) (- (+ my (* hl s)) (* wd c)) r g b al))))))
  nil)

(defun-fast ui-ink-splash (cx cy rad seed col drawing)
  "An ink splash (Kubo's title-page splash) centred at (CX CY), radius RAD px: a main blob (a 14-gon of
hashed radius), 5-9 thin spikes and 6-12 satellite droplets along them, all hashed from SEED. It grows
over DRAWING 0 (x0.6) and holds from drawing 1. COL = (r g b a): black on white cards, white on black."
  (declare (single-float cx cy rad seed) (fixnum drawing))
  (let* ((rad (* rad (if (< drawing 1) 0.6f0 1f0))) (tau 6.2831855f0)
         (ns (+ 5 (f->i (* 4.99f0 (%h01 1.3f0 seed))))) (nd (+ 6 (f->i (* 6.99f0 (%h01 2.9f0 seed)))))
         (lx 0f0) (ly 0f0))
    (declare (single-float rad tau lx ly) (fixnum ns nd))
    (%col-floats (r g b al) col
      (with-ui-verts (d o (+ 42 (* 3 ns) (* 18 nd)))
        (dotimes (j 15)                                   ; the blob
          (let* ((jj (mod j 14)) (f (i->f jj)) (ang (* tau (/ f 14f0)))
                 (rr (* rad (+ 0.7f0 (* 0.45f0 (%h01 f seed)))))
                 (x (+ cx (* rr (f-cos ang)))) (y (+ cy (* rr (f-sin ang)))))
            (declare (fixnum jj) (single-float f ang rr x y))
            (when (> j 0) (uvtx cx cy r g b al) (uvtx lx ly r g b al) (uvtx x y r g b al))
            (setf lx x ly y)))
        (dotimes (j ns)                                   ; spikes
          (let* ((f (i->f j)) (ang (* tau (+ (/ f (i->f ns)) (* 0.1f0 (%h01 (+ f 11f0) seed)))))
                 (c (f-cos ang)) (s (f-sin ang)) (w (* rad (+ 0.05f0 (* 0.06f0 (%h01 (+ f 13f0) seed)))))
                 (l (* rad (+ 1.3f0 (* 0.9f0 (%h01 (+ f 17f0) seed))))) (bb (* 0.6f0 rad)))
            (declare (single-float f ang c s w l bb))
            (uvtx (- (+ cx (* bb c)) (* w s)) (+ cy (* bb s) (* w c)) r g b al)
            (uvtx (+ cx (* bb c) (* w s)) (- (+ cy (* bb s)) (* w c)) r g b al)
            (uvtx (+ cx (* l c)) (+ cy (* l s)) r g b al)))
        (dotimes (j nd)                                   ; droplets: hexagons out along the spikes
          (let* ((f (i->f j)) (sp (f->i (* (i->f ns) (%h01 (+ f 23f0) seed))))
                 (ang (* tau (+ (/ (i->f sp) (i->f ns)) (* 0.1f0 (%h01 (+ (i->f sp) 11f0) seed)) (* 0.04f0 (- (%h01 (+ f 29f0) seed) 0.5f0)))))
                 (dist (* rad (+ 1.4f0 (* 1.1f0 (%h01 (+ f 31f0) seed)))))
                 (dr (* rad (+ 0.03f0 (* 0.07f0 (%h01 (+ f 37f0) seed)))))
                 (ox (+ cx (* dist (f-cos ang)))) (oy (+ cy (* dist (f-sin ang)))) (qx 0f0) (qy 0f0))
            (declare (fixnum sp) (single-float f ang dist dr ox oy qx qy))
            (dotimes (q 7)
              (let* ((qa (* tau (/ (i->f (mod q 6)) 6f0))) (x (+ ox (* dr (f-cos qa)))) (y (+ oy (* dr (f-sin qa)))))
                (declare (single-float qa x y))
                (when (> q 0) (uvtx ox oy r g b al) (uvtx qx qy r g b al) (uvtx x y r g b al))
                (setf qx x qy y))))))))
  nil)

(defun-fast %fx-disc ()
  (let* ((a *tn-args*) (x (aref a 0)) (y (aref a 1)) (z (aref a 2)) (r (aref a 3)) (wob (aref a 4)) (seed (aref a 5))
         (pk (toon-a (aref a 6) (aref a 7))) (push (if (< (aref a 8) 0f0) (* 0.8f0 r) (aref a 8)))
         (rt (camera-right *camera*)) (up (camera-upv *camera*)))
    (declare (type f32vec a rt up) (single-float x y z r wob seed pk push))
    (%toward-eye (x y z sc) push
      (let* ((r (* r sc)) (sx (* r (aref rt 0))) (sy (* r (aref rt 1))) (sz (* r (aref rt 2)))
             (vx (* r (aref up 0))) (vy (* r (aref up 1))) (vz (* r (aref up 2))))
        (declare (single-float r sx sy sz vx vy vz))
        (with-fx-verts (d o :toon 6)
          (%bb-verts x y z sx sy sz vx vy vz 1f0 seed wob pk)))))
  nil)
