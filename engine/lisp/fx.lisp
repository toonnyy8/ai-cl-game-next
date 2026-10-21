;;;; fx.lisp — the fx pools: camera shake, particles (mist, sparks, dust, homing orbs, feathers, glow, flame), rings,
;;;; rigid debris, sword-trail buffers (and the drawn smear captured from them), screen-edge vignettes and debug
;;;; outlines of hit volumes. The stateless drawing kit (toon shapes, envelope, ribbons, sectors) is fx-shapes.lisp,
;;;; loaded before this file. All real-time or sim-time driven by the caller; the colors / presets a game uses live in the game.
(in-package :engine)

;;; ---------------------------------------------------------------- camera shake (real time)
(defparameter *shake-mult* 1.0 "Scales every SHAKE request (tuning knob).")
(defparameter *shake-hz* 30f0 "Shake offsets change this many times a second (fewer = a drawn, stepped shake; 12 reads as drawn).")
(declaim (type f32vec *shake*))
(defvar *shake* (make-f32 8) "amp dur left noise-t ox oy oz")
(defun shake (amp dur)
  "Screen shake of AMP metres decaying linearly over DUR s. Concurrent: the max amplitude wins."
  (let* ((s *shake*) (amp (* (f32 amp) (f32 *shake-mult*)))
         (cur (if (> (aref s 1) 0) (* (aref s 0) (/ (aref s 2) (aref s 1))) 0f0)))
    (when (>= amp cur)
      (setf (aref s 0) amp (aref s 1) (f32 dur) (aref s 2) (f32 dur)))))

(defun-fast shake-update (dt)
  (declare (single-float dt))
  (let* ((s *shake*) (out (camera-shake *camera*)))
    (declare (type f32vec s out))
    (setf (aref s 2) (f-max 0f0 (- (aref s 2) dt))
          (aref s 3) (- (aref s 3) dt))
    (when (<= (aref s 3) 0f0)                          ; 30 Hz noise
      (setf (aref s 3) (/ 1f0 (f-max 1f0 (f32 *shake-hz*)))
            (aref s 4) (rnd-range -1f0 1f0) (aref s 5) (rnd-range -1f0 1f0) (aref s 6) (rnd-range -1f0 1f0)))
    (let* ((a (if (> (aref s 1) 0f0) (* (aref s 0) (/ (aref s 2) (aref s 1))) 0f0)))
      (declare (single-float a))
      (setf (aref out 0) (* a (aref s 4)) (aref out 1) (* a (aref s 5)) (aref out 2) (* a (aref s 6))))))

;;; ---------------------------------------------------------------- particles
;;; Pool of +PMAX+ particles, stride 15:
;;; [0-2] pos [3-5] vel [6] life [7] max [8] size [9] grav [10] r [11] g [12] b [13] type
;;; [14] alpha scale (FX-EMIT's optional ALPHA, 1 = the kind's own alpha; multiplies it when drawn)
(defconstant +pmax+ 2000)
(defconstant +pstride+ 15)
;;; Types (how a particle moves and draws; its color is per particle):
;;;   mist / dust  soft alpha puffs that grow and fade (mist darkens), with drag
;;;   spark        velocity-stretched additive streak, falls
;;;   orb-a/orb-b  additive glow balls that home to *ORB-TARGET* after 0.4 s and call
;;;                *ON-ORB-ABSORBED* with :A / :B when they reach it (pickups)
;;;   feather      narrow alpha quad, slow fall      glow  additive ball that shrinks
;;;   flame        additive ball, mild drag, shrinks; its color runs from the emit color (give a
;;;                white-yellow hot core) through orange to dark red over its life, and only the
;;;                first 10 % of its life gets the additive batch's white center. It rises when the
;;;                caller passes a negative GRAV (FX-BURST uses -2). Its peak alpha is 0.8; FX-EMIT's
;;;                ALPHA scales that (additive: brightness), e.g. 0.3-0.5 so flames do not saturate
;;;                to white over a bright sky.
;;; Every kind's alpha is multiplied by the particle's ALPHA (default 1 = unchanged).
;;; Toon kinds (the toon batch, docs/style/STYLE_STORM_DESIGN.md §3.4): R = wobble, ALPHA = the palette (0..15);
;;; presence K = the life left, seed = the slot. Drawn stepped on the fx clock (at pos - vel x the time
;;; since the drawing began: twos, threes for the matter palettes), so a burst of scraps moves in drawings.
;;;   t-blob       a pushed billboard puff or flame (the palette's style decides): matter grows, the rest shrinks
;;;   t-shard      a kite along its velocity (rock, glass, ink shards)
(defconstant +p-mist+ 0f0) (defconstant +p-spark+ 1f0) (defconstant +p-dust+ 2f0)
(defconstant +p-orb-a+ 3f0) (defconstant +p-orb-b+ 4f0) (defconstant +p-feather+ 5f0)
(defconstant +p-glow+ 6f0) (defconstant +p-flame+ 7f0) (defconstant +p-t-blob+ 8f0) (defconstant +p-t-shard+ 9f0)
(defmacro %matter-pal-p (p) "Palettes 6 7 8 11 (smoke, dust, ash, black smoke) are matter: threes."
  `(or (= ,p 6f0) (= ,p 7f0) (= ,p 8f0) (= ,p 11f0)))
(declaim (type f32vec *parts* *orb-target*) (type fixnum *pcursor* *plive*))
(defvar *parts* (make-f32 (* +pmax+ +pstride+)))
(defvar *pcursor* 0)
(defvar *plive* 0)
(defvar *orb-target* (make-f32 3) "World point orb particles home to (e.g. the player's chest); set it each frame.")
(defvar *on-orb-absorbed* nil "NIL or a function of :A / :B, called when an orb particle reaches *ORB-TARGET*.")

;; FX-EMIT is a function (for #'fx-emit) plus a compiler macro: a direct call expands to %FX-PUT
;; in place, so the 12-13 float arguments are never boxed (a call boxed ~210 B). Only %FX-SLOT (no
;; float arguments) is called.
(defun-fast %fx-slot ()
  "Offset in *PARTS* of the slot the next particle takes (a dead one near the cursor, else the
oldest), advancing the cursor."
  (let* ((p *parts*) (i *pcursor*) (tries 0))
    (declare (type f32vec p) (fixnum i tries))
    (loop while (and (< tries 64) (> (aref p (+ (* i +pstride+) 6)) 0f0)) do
      (incf i) (incf tries) (when (>= i +pmax+) (setf i 0)))
    (let* ((o (* i +pstride+)))
      (declare (fixnum o))
      (incf i) (when (>= i +pmax+) (setf i 0))
      (setf *pcursor* i)
      o)))

(defmacro %fx-put (type x y z vx vy vz life size grav r g b &optional (alpha 1f0))
  "FX-EMIT's body, inline: evaluate the arguments left to right as single-floats, write one slot."
  (let* ((args (list type x y z vx vy vz life size grav r g b alpha))
         (vars (loop repeat (length args) collect (gensym "A"))) (p (gensym "P")) (o (gensym "O")))
    `(let* (,@(mapcar #'list vars args))
       (declare (single-float ,@vars))
       (let* ((,p *parts*) (,o (%fx-slot)))
         (declare (type f32vec ,p) (fixnum ,o))
         (setf ,@(loop for v in (list (nth 1 vars) (nth 2 vars) (nth 3 vars) (nth 4 vars) (nth 5 vars) (nth 6 vars)
                                      (nth 7 vars) (nth 7 vars) (nth 8 vars) (nth 9 vars) (nth 10 vars) (nth 11 vars)
                                      (nth 12 vars) (nth 0 vars) (nth 13 vars))
                       for k from 0 append `((aref ,p (+ ,o ,k)) ,v))))
       nil)))

(defun-fast fx-emit (type x y z vx vy vz life size grav r g b &optional (alpha 1f0))
  "Spawn one particle (overwrites the oldest slot when full). ALPHA scales the kind's alpha (for the
additive kinds: brightness), e.g. 0.3 for flames that must not saturate on a bright sky. A direct
call compiles in place (compiler macro): unboxed float arguments cost no consing."
  (declare (single-float type x y z vx vy vz life size grav r g b))
  (%fx-put type x y z vx vy vz life size grav r g b (f32 alpha)))
(eval-when (:compile-toplevel :load-toplevel :execute)   ; ECL: else not seen by the compiler
  (define-compiler-macro fx-emit (&rest args) `(%fx-put ,@args)))

(defun-fast fx-burst (type n x y z dx dy dz spread smin smax life size r g b)
  "N particles from (x y z): direction (dx dy dz) (zero = omni) jittered by SPREAD, speed
SMIN..SMAX, LIFE s (±25 %), SIZE radius (0.5x..1x)."
  (declare (single-float type x y z dx dy dz spread smin smax life size r g b) (fixnum n))
  (let* ((grav (cond ((= type +p-spark+) 9.8f0) ((= type +p-mist+) -0.4f0) ((= type +p-dust+) -0.3f0)
                     ((= type +p-feather+) 1.2f0) ((= type +p-glow+) 0f0) ((= type +p-flame+) -2f0)
                     (t 2.5f0))))
    (declare (single-float grav))
    (dotimes (k n)
      (let* ((rx (+ dx (* spread (rnd-range -1f0 1f0)))) (ry (+ dy (* spread (rnd-range -1f0 1f0))))
             (rz (+ dz (* spread (rnd-range -1f0 1f0))))
             (l (f-hypot rx ry rz)) (sp (rnd-range smin smax)))
        (declare (single-float rx ry rz l sp))
        (when (< l 1f-4) (setf rx 0f0 ry 1f0 rz 0f0 l 1f0))
        (setf sp (/ sp l))
        (fx-emit type x y z (* rx sp) (* ry sp) (* rz sp) (* life (rnd-range 0.75f0 1.25f0))
                 (* size (rnd-range 0.5f0 1f0)) grav r g b)))))

(defun-fast fx-update (dt)
  "Advance particles by DT (real seconds). Orbs home to *ORB-TARGET* and call *ON-ORB-ABSORBED*."
  (declare (single-float dt))
  (let* ((p *parts*) (tg *orb-target*) (live 0))
    (declare (type f32vec p tg) (fixnum live))
    (dotimes (i +pmax+)
      (let* ((o (* i +pstride+)) (life (aref p (+ o 6))))
        (declare (fixnum o) (single-float life))
        (when (> life 0f0)
          (incf live)
          (let* ((type (aref p (+ o 13))) (nl (- life dt)))
            (declare (single-float type nl))
            (setf (aref p (+ o 6)) nl)
            (if (or (= type +p-orb-a+) (= type +p-orb-b+))
                (let* ((age (- (aref p (+ o 7)) nl))
                       (dx (- (aref tg 0) (aref p o))) (dy (- (aref tg 1) (aref p (+ o 1))))
                       (dz (- (aref tg 2) (aref p (+ o 2))))
                       (d (f-hypot dx dy dz)))
                  (declare (single-float age dx dy dz d))
                  (cond ((and (> age 0.4f0) (< d 0.6f0))
                         (setf (aref p (+ o 6)) 0f0)
                         (let ((hook *on-orb-absorbed*))
                           (when hook (funcall hook (if (= type +p-orb-a+) :a :b)))))
                        ((and (> age 0.4f0) (< d 8f0))
                         (let* ((k (/ 12f0 (f-max d 0.01f0))))
                           (setf (aref p (+ o 3)) (* dx k) (aref p (+ o 4)) (* dy k) (aref p (+ o 5)) (* dz k))))
                        (t (let* ((dr (f-max 0f0 (- 1f0 (* 3f0 dt)))))
                             (setf (aref p (+ o 3)) (* dr (aref p (+ o 3)))
                                   (aref p (+ o 4)) (- (* dr (aref p (+ o 4))) (* 2f0 dt))
                                   (aref p (+ o 5)) (* dr (aref p (+ o 5))))))))
                (let* ((drag (cond ((or (= type +p-mist+) (= type +p-dust+) (= type +p-feather+))
                                    (f-max 0f0 (- 1f0 (* 3.5f0 dt))))
                                   ((= type +p-flame+) (f-max 0f0 (- 1f0 (* 1.5f0 dt))))
                                   (t 1f0))))
                  (declare (single-float drag))
                  (setf (aref p (+ o 3)) (* drag (aref p (+ o 3)))
                        (aref p (+ o 4)) (- (* drag (aref p (+ o 4))) (* (aref p (+ o 9)) dt))
                        (aref p (+ o 5)) (* drag (aref p (+ o 5))))))
            (setf (aref p o) (+ (aref p o) (* dt (aref p (+ o 3))))
                  (aref p (+ o 1)) (+ (aref p (+ o 1)) (* dt (aref p (+ o 4))))
                  (aref p (+ o 2)) (+ (aref p (+ o 2)) (* dt (aref p (+ o 5)))))
            (when (< (aref p (+ o 1)) 0.03f0)            ; the ground (y = 0)
              (setf (aref p (+ o 1)) 0.03f0 (aref p (+ o 4)) (* -0.3f0 (aref p (+ o 4)))
                    (aref p (+ o 3)) (* 0.6f0 (aref p (+ o 3))) (aref p (+ o 5)) (* 0.6f0 (aref p (+ o 5)))))))))
    (setf *plive* live)))

(defun-fast fx-draw-particles ()
  "Queue all live particles into the fx batches (inline vertex writes, no consing)."
  (let* ((p *parts*) (rt (camera-right *camera*)) (up (camera-upv *camera*)) (eye (camera-eye *camera*))
         (rx (aref rt 0)) (ry (aref rt 1)) (rz (aref rt 2)) (ux (aref up 0)) (uy (aref up 1)) (uz (aref up 2)))
    (declare (type f32vec p rt up eye) (single-float rx ry rz ux uy uz))
    (dotimes (i +pmax+)
      (let* ((o (* i +pstride+)) (life (aref p (+ o 6))))
        (declare (fixnum o) (single-float life))
        (when (> life 0f0)
          (let* ((type (aref p (+ o 13))) (u (/ life (aref p (+ o 7)))) (s (aref p (+ o 8)))
                 (x (aref p o)) (y (aref p (+ o 1))) (z (aref p (+ o 2)))
                 (r (aref p (+ o 10))) (g (aref p (+ o 11))) (b (aref p (+ o 12))) (ka (aref p (+ o 14))))
            (declare (single-float type u s x y z r g b ka))
            (cond
              ((>= type +p-t-blob+)                      ; toon kinds: stepped position, pushed toward the eye
               (let* ((pal ka) (rate (if (%matter-pal-p pal) 3f0 2f0)) (age (- (aref p (+ o 7)) life))
                      (since (f-mod (fx-clock) (/ rate 24f0))) (lag (f-min age since))
                      (u (f-min 1f0 (/ (+ life lag) (aref p (+ o 7)))))   ; life left when the drawing began
                      (vx (aref p (+ o 3))) (vy (aref p (+ o 4))) (vz (aref p (+ o 5)))
                      (x (- x (* lag vx))) (y (- y (* lag vy))) (z (- z (* lag vz)))
                      (seed (* 40f0 (%h01 (i->f i) 0.618f0))) (k (+ 0.12f0 (* 0.86f0 u))) (wob r))
                 (declare (single-float pal rate age since lag u vx vy vz x y z seed k wob))
                 (cond
                   ((< age since) nil)                   ; born during this drawing: it shows from the next one
                   ((= type +p-t-blob+)
                     (let* ((sz (* s (if (%matter-pal-p pal) (+ 1f0 (* 0.8f0 (- 1f0 u))) (+ 0.4f0 (* 0.6f0 u))))))
                       (declare (single-float sz))
                       (%toward-eye (x y z sc) (* 0.8f0 sz)
                         (let* ((sz (* sz sc)) (sx (* sz rx)) (sy (* sz ry)) (sz2 (* sz rz)) (vx (* sz ux)) (vy (* sz uy)) (vz (* sz uz))
                                (a (toon-a pal k)))
                           (declare (single-float sz sx sy sz2 vx vy vz a))
                           (with-fx-verts (d o2 :toon 6)
                             (%bb-verts x y z sx sy sz2 vx vy vz 1f0 seed wob a))))))
                   (t
                     (let* ((l (f-hypot vx vy vz)))
                       (declare (single-float l))
                       (if (> l 1f-3)
                           (fx-shard x y z (/ vx l) (/ vy l) (/ vz l) s (* 0.3f0 s) wob seed pal k)
                           (fx-shard x y z rx ry rz s (* 0.3f0 s) wob seed pal k)))))))
              ((= type +p-spark+)                        ; velocity-stretched additive line
               (let* ((vx (aref p (+ o 3))) (vy (aref p (+ o 4))) (vz (aref p (+ o 5)))
                      (x1 (- x (* 0.035f0 vx))) (y1 (- y (* 0.035f0 vy))) (z1 (- z (* 0.035f0 vz)))
                      (dx (- x1 x)) (dy (- y1 y)) (dz (- z1 z))
                      (ex (- (aref eye 0) x)) (ey (- (aref eye 1) y)) (ez (- (aref eye 2) z))
                      (cx (- (* dy ez) (* dz ey))) (cy (- (* dz ex) (* dx ez))) (cz (- (* dx ey) (* dy ex)))
                      (cl (f-hypot cx cy cz)) (w (* s u)))
                 (declare (single-float vx vy vz x1 y1 z1 dx dy dz ex ey ez cx cy cz cl w))
                 (when (> cl 1f-6)
                   (setf cx (* w (/ cx cl)) cy (* w (/ cy cl)) cz (* w (/ cz cl)))
                   (with-fx-verts (d o2 :add 3)
                     (vtx (- x cx) (- y cy) (- z cz) 0f0 -1f0 r g b (* ka u))
                     (vtx (+ x cx) (+ y cy) (+ z cz) 0f0 1f0 r g b (* ka u))
                     (vtx x1 y1 z1 0f0 0f0 r g b 0f0)))))
              ((or (= type +p-mist+) (= type +p-dust+))  ; soft alpha puff that grows and darkens
               (let* ((sz (* s (+ 1f0 (* 1.2f0 (- 1f0 u))))) (a (* ka (* (if (= type +p-mist+) 0.85f0 0.45f0) u)))
                      (k (if (= type +p-mist+) (+ 0.5f0 (* 0.5f0 u)) 1f0))
                      (sx (* sz rx)) (sy (* sz ry)) (sz2 (* sz rz)) (vx (* sz ux)) (vy (* sz uy)) (vz (* sz uz)))
                 (declare (single-float sz a k sx sy sz2 vx vy vz))
                 (with-fx-verts (d o2 :alpha 6)
                   (%bb-verts x y z sx sy sz2 vx vy vz (* k r) (* k g) (* k b) a))))
              ((= type +p-feather+)
               (let* ((a (* ka (* 0.9f0 u))) (sx (* s rx 0.45f0)) (sy (* s ry 0.45f0)) (sz2 (* s rz 0.45f0))
                      (vx (* s ux)) (vy (* s uy)) (vz (* s uz)))
                 (declare (single-float a sx sy sz2 vx vy vz))
                 (with-fx-verts (d o2 :alpha 6)
                   (%bb-verts x y z sx sy sz2 vx vy vz r g b a))))
              ((= type +p-flame+)                        ; additive, shrinking, hot core -> orange -> dark red
               (let* ((age (- 1f0 u))
                      (k1 (f-min 1f0 (* 5f0 age)))                            ; age 0..0.2: emit color -> orange
                      (k2 (f-clamp (* 2.857f0 (- age 0.2f0)) 0f0 1f0))        ; age 0.2..0.55: orange -> dark red
                      (cr (+ r (* (- 1f0 r) k1))) (cg (+ g (* (- 0.42f0 g) k1))) (cb (+ b (* (- 0.06f0 b) k1)))
                      (a (* ka (if (< age 0.1f0) (* 0.8f0 u) (* -0.8f0 u))))   ; faint layers; < 0: no white core (fx.frag)
                      (sz (* s (+ 0.3f0 (* 0.7f0 u)))) (sx (* sz rx)) (sy (* sz ry)) (sz2 (* sz rz))
                      (vx (* sz ux)) (vy (* sz uy)) (vz (* sz uz)))
                 (declare (single-float age k1 k2 cr cg cb a sz sx sy sz2 vx vy vz))
                 (setf cr (+ cr (* (- 0.45f0 cr) k2)) cg (+ cg (* (- 0.05f0 cg) k2)) cb (+ cb (* (- 0.02f0 cb) k2)))
                 (with-fx-verts (d o2 :add 6)
                   (%bb-verts x y z sx sy sz2 vx vy vz cr cg cb a))))
              (t                                          ; orbs + glow: additive
               (let* ((fl (if (> type 4.5f0) u 1f0)) (a (* ka (if (< life 0.5f0) (* 2f0 life) 1f0)))
                      (sz (* s fl)) (sx (* sz rx)) (sy (* sz ry)) (sz2 (* sz rz))
                      (vx (* sz ux)) (vy (* sz uy)) (vz (* sz uz)))
                 (declare (single-float fl a sz sx sy sz2 vx vy vz))
                 (with-fx-verts (d o2 :add 6)
                   (%bb-verts x y z sx sy sz2 vx vy vz r g b a)))))))))))

;;; ---------------------------------------------------------------- rings (parry / shockwave)
(defconstant +ring-n+ 16)
(declaim (type f32vec *rings*))
(defconstant +ring-stride+ 13)
(defvar *rings* (make-f32 (* +ring-stride+ +ring-n+)) "x y z r0 r1 age dur r g b flat width palette (-1 = soft)")
(defun fx-ring (x y z r0 r1 dur r g b &key flat (width 0.05) palette)
  "Expanding ring: camera-facing (parry) or FLAT on the ground (shockwave). PALETTE (0..15, see
TOON-A): drawn as a toon shape instead (the band's two edges inked, eroding as it fades; R G B unused)."
  (let* ((s *rings*) (best 0) (ba -1f0))
    (dotimes (i +ring-n+)
      (let ((rem (- (aref s (+ (* i +ring-stride+) 6)) (aref s (+ (* i +ring-stride+) 5)))))
        (when (or (< ba 0) (< rem ba)) (setf ba rem best i))))
    (let ((o (* best +ring-stride+)))
      (setf (aref s (+ o 12)) (if palette (f32 palette) -1f0))
      (setf (aref s o) (f32 x) (aref s (+ o 1)) (f32 y) (aref s (+ o 2)) (f32 z) (aref s (+ o 3)) (f32 r0)
            (aref s (+ o 4)) (f32 r1) (aref s (+ o 5)) 0f0 (aref s (+ o 6)) (f32 dur)
            (aref s (+ o 7)) (f32 r) (aref s (+ o 8)) (f32 g) (aref s (+ o 9)) (f32 b)
            (aref s (+ o 10)) (if flat 1f0 0f0) (aref s (+ o 11)) (f32 width)))))

(defun-fast fx-rings-update (dt)
  (declare (single-float dt))
  (let* ((s *rings*) (rt (camera-right *camera*)) (up (camera-upv *camera*)))
    (declare (type f32vec s rt up))
    (dotimes (i +ring-n+)
      (let* ((o (* i +ring-stride+)) (age (aref s (+ o 5))) (dur (aref s (+ o 6))))
        (declare (fixnum o) (single-float age dur))
        (when (< age dur)
          (setf (aref s (+ o 5)) (+ age dt))
          (let* ((u (/ age dur)) (rad (+ (aref s (+ o 3)) (* u (- (aref s (+ o 4)) (aref s (+ o 3))))))
                 (a (- 1f0 u)) (w (aref s (+ o 11))) (flat (> (aref s (+ o 10)) 0.5f0))
                 (x (aref s o)) (y (aref s (+ o 1))) (z (aref s (+ o 2)))
                 (r (aref s (+ o 7))) (g (aref s (+ o 8))) (b (aref s (+ o 9))) (pal (aref s (+ o 12))))
            (declare (single-float u rad a w x y z r g b pal))
            (when (>= pal 0f0)                 ; toon ring: uv (0, -1..1) across the band, seed = the slot
              (setf r 1f0 g (+ 1f0 (i->f i)) b 0.12f0 a (toon-a pal (* 0.98f0 (- 1f0 (* u u)))) y (+ y 0.02f0)))
            (with-fx-verts (d o2 (if (>= pal 0f0) :toon :add) (* 6 24))
              (dotimes (k 24)
                (let* ((a0 (* (i->f k) 0.2618f0)) (a1 (+ a0 0.2618f0))
                       (c0 (f-cos a0)) (s0 (f-sin a0)) (c1 (f-cos a1)) (s1 (f-sin a1))
                       (ri (- rad w)) (ro (+ rad w)))
                  (declare (single-float a0 a1 c0 s0 c1 s1 ri ro))
                  (macrolet ((pt (c sn rr)      ; point on the ring plane
                               `(if flat
                                    (values (+ x (* ,rr ,c)) (+ y 0.03f0) (+ z (* ,rr ,sn)))
                                    (values (+ x (* ,rr (+ (* ,c (aref rt 0)) (* ,sn (aref up 0)))))
                                            (+ y (* ,rr (+ (* ,c (aref rt 1)) (* ,sn (aref up 1)))))
                                            (+ z (* ,rr (+ (* ,c (aref rt 2)) (* ,sn (aref up 2)))))))))
                    (multiple-value-bind (x0 y0 z0) (pt c0 s0 ri)
                      (multiple-value-bind (x1 y1 z1) (pt c0 s0 ro)
                        (multiple-value-bind (x2 y2 z2) (pt c1 s1 ro)
                          (multiple-value-bind (x3 y3 z3) (pt c1 s1 ri)
                            (declare (single-float x0 y0 z0 x1 y1 z1 x2 y2 z2 x3 y3 z3))
                            (if (>= pal 0f0)
                                (progn (vtx x0 y0 z0 0f0 -1f0 r g b a) (vtx x1 y1 z1 0f0 1f0 r g b a) (vtx x2 y2 z2 0f0 1f0 r g b a)
                                       (vtx x0 y0 z0 0f0 -1f0 r g b a) (vtx x2 y2 z2 0f0 1f0 r g b a) (vtx x3 y3 z3 0f0 -1f0 r g b a))
                                (progn (vtx x0 y0 z0 0f0 1f0 r g b a) (vtx x1 y1 z1 0f0 0f0 r g b a) (vtx x2 y2 z2 0f0 0f0 r g b a)
                                       (vtx x0 y0 z0 0f0 1f0 r g b a) (vtx x2 y2 z2 0f0 0f0 r g b a) (vtx x3 y3 z3 0f0 1f0 r g b a)))))))))))))))))

;;; ---------------------------------------------------------------- rigid debris (limbs, death parts)
;;; Slot stride 32: [0-15] rotation*scale (no translation) [16-18] pos [19-21] vel [22-24] euler
;;; [25-27] angular velocity [28] age [29] bounced
(defconstant +deb-n+ 128)
(declaim (type f32vec *deb* *deb-m* *deb-t*) (type simple-vector *deb-mesh*) (type fixnum *deb-cursor*))
(defvar *deb* (make-f32 (* 32 +deb-n+)))
(defvar *deb-mesh* (make-array +deb-n+ :initial-element nil))
(defvar *deb-cursor* 0)
(defvar *deb-m* (make-f32 16))
(defvar *deb-t* (make-f32 16))
(defparameter *debris-life* 2.4 "s before a debris part is gone (shrinks over the last 0.4 s)")

(defun-fast fx-debris (mesh m mo vx vy vz spin)
  "Detach MESH drawn with the world matrix at M[MO..MO+15] as a physics piece with velocity
(vx vy vz) and random angular velocity up to SPIN rad/s."
  (declare (type f32vec m) (fixnum mo) (single-float vx vy vz spin))
  (let* ((d *deb*) (i *deb-cursor*) (o (* i 32)))
    (declare (type f32vec d) (fixnum i o))
    (setf (svref *deb-mesh* i) mesh)
    (replace d m :start1 o :start2 mo :end2 (+ mo 12))
    (setf (aref d (+ o 12)) 0f0 (aref d (+ o 13)) 0f0 (aref d (+ o 14)) 0f0 (aref d (+ o 15)) 1f0
          (aref d (+ o 16)) (aref m (+ mo 12)) (aref d (+ o 17)) (aref m (+ mo 13)) (aref d (+ o 18)) (aref m (+ mo 14))
          (aref d (+ o 19)) vx (aref d (+ o 20)) vy (aref d (+ o 21)) vz
          (aref d (+ o 22)) 0f0 (aref d (+ o 23)) 0f0 (aref d (+ o 24)) 0f0
          (aref d (+ o 25)) (rnd-range (- spin) spin) (aref d (+ o 26)) (rnd-range (- spin) spin)
          (aref d (+ o 27)) (rnd-range (- spin) spin) (aref d (+ o 28)) 0f0 (aref d (+ o 29)) 0f0)
    (incf i) (when (>= i +deb-n+) (setf i 0))
    (setf *deb-cursor* i)
    nil))

(defun-fast fx-debris-update (dt)
  "Integrate and draw debris (DT = sim seconds: debris freezes with hitstop)."
  (declare (single-float dt))
  (let* ((d *deb*) (m *deb-m*) (tm *deb-t*) (life (the single-float *debris-life*)))
    (declare (type f32vec d m tm) (single-float life))
    (dotimes (i +deb-n+)
      (let* ((mesh (svref *deb-mesh* i)) (o (* i 32)))
        (declare (fixnum o))
        (when mesh
          (let* ((age (+ (aref d (+ o 28)) dt)))
            (declare (single-float age))
            (setf (aref d (+ o 28)) age)
            (if (> age life)
                (setf (svref *deb-mesh* i) nil)
                (progn
                  (setf (aref d (+ o 20)) (- (aref d (+ o 20)) (* 18f0 dt)))
                  (dotimes (k 3)
                    (setf (aref d (+ o 16 k)) (+ (aref d (+ o 16 k)) (* dt (aref d (+ o 19 k))))
                          (aref d (+ o 22 k)) (+ (aref d (+ o 22 k)) (* dt (aref d (+ o 25 k))))))
                  (when (< (aref d (+ o 17)) 0.08f0)
                    (setf (aref d (+ o 17)) 0.08f0)
                    (if (< (aref d (+ o 29)) 0.5f0)
                        (setf (aref d (+ o 20)) (* -0.3f0 (aref d (+ o 20))) (aref d (+ o 29)) 1f0)
                        (setf (aref d (+ o 20)) 0f0))
                    (setf (aref d (+ o 19)) (* 0.8f0 (aref d (+ o 19))) (aref d (+ o 21)) (* 0.8f0 (aref d (+ o 21)))
                          (aref d (+ o 25)) (* 0.9f0 (aref d (+ o 25))) (aref d (+ o 26)) (* 0.9f0 (aref d (+ o 26)))
                          (aref d (+ o 27)) (* 0.9f0 (aref d (+ o 27)))))
                  (let* ((s (if (> age (- life 0.4f0)) (f-max 0.001f0 (/ (- life age) 0.4f0)) 1f0)))
                    (declare (single-float s))
                    (%euler! tm 0 (aref d (+ o 16)) (aref d (+ o 17)) (aref d (+ o 18))
                             (aref d (+ o 23)) (aref d (+ o 22)) (aref d (+ o 24)) s)
                    (%affine-mul! m 0 tm 0 d o)
                    (draw-mesh mesh m))))))))))

(defun fx-clear-debris () (fill *deb-mesh* nil))

(defun fx-clear ()
  "Remove every particle, ring and debris piece and stop the shake (a new round / scene)."
  (let ((p *parts*) (s *rings*))
    (declare (type f32vec p s))
    (dotimes (i +pmax+) (setf (aref p (+ (* i +pstride+) 6)) 0f0))
    (dotimes (i +ring-n+) (setf (aref s (+ (* i +ring-stride+) 6)) 0f0))    ; dur 0: age >= dur = finished
    (setf *plive* 0))
  (fill *shake* 0f0)
  (fill (camera-shake *camera*) 0f0)
  (fx-clear-debris))

(defun fx-clear-orbs ()
  "Kill in-flight orb particles (e.g. a retry must not collect pickups after a checkpoint restore)."
  (let ((p *parts*))
    (declare (type f32vec p))
    (dotimes (i +pmax+)
      (let* ((o (* i +pstride+)) (ty (aref p (+ o 13))))
        (when (or (= ty +p-orb-a+) (= ty +p-orb-b+)) (setf (aref p (+ o 6)) 0f0))))))

;;; ---------------------------------------------------------------- sword trails
;;; A trail is an f32vec: +TRAIL-N+ samples x (base xyz, tip xyz), oldest first, count at [60].
;;; Push a blade's base/tip each sim step while it swings, decay otherwise, draw it with FX-TRAIL.
;;; %TRAIL-PUSH / %TRAIL-DROP are the 0 B macro forms (a DEFUN-FAST call boxes its float arguments; REPLACE of a
;;; vector onto itself allocates, so the samples move with an explicit forward copy).
(defconstant +trail-n+ 10)
(defun make-trail () (make-f32 (+ (* 6 +trail-n+) 1)))
(defmacro trail-count (tr)
  "Samples in trail TR (a float; SETF-able, e.g. to 0 to drop the trail at once)."
  `(aref ,tr (* 6 +trail-n+)))

(defmacro %trail-drop (tr n)
  "Drop trail TR's oldest of its N samples (N >= 1; an explicit forward copy: REPLACE of a vector onto itself allocates). 0 B."
  `(let ((%tr ,tr) (%n ,n))
     (declare (type f32vec %tr) (fixnum %n))
     (dotimes (%i (* 6 (1- %n))) (setf (aref %tr %i) (aref %tr (+ %i 6))))
     (setf (trail-count %tr) (i->f (1- %n)))))
(defmacro %trail-push (tr bx by bz tx ty tz)
  "TRAIL-PUSH as a macro (a DEFUN-FAST call boxes its floats): one sample, the oldest dropped when full. 0 B."
  `(let* ((%tr ,tr) (%n (f->i (trail-count %tr))))
     (declare (type f32vec %tr) (fixnum %n))
     (when (>= %n +trail-n+)
       (%trail-drop %tr %n)
       (setf %n (1- +trail-n+)))
     (let ((%o (* 6 %n)))
       (declare (fixnum %o))
       (setf (aref %tr %o) ,bx (aref %tr (+ %o 1)) ,by (aref %tr (+ %o 2)) ,bz
             (aref %tr (+ %o 3)) ,tx (aref %tr (+ %o 4)) ,ty (aref %tr (+ %o 5)) ,tz
             (trail-count %tr) (i->f (1+ %n))))))

(defun-fast trail-push (tr bx by bz tx ty tz)
  "Add one base / tip sample to trail TR, the oldest dropped when it is full."
  (declare (type f32vec tr) (single-float bx by bz tx ty tz))
  (%trail-push tr bx by bz tx ty tz))

(defun-fast trail-decay (tr)
  "Drop the oldest sample (called each sim step when not emitting)."
  (declare (type f32vec tr))
  (let* ((n (f->i (aref tr 60))))
    (declare (fixnum n))
    (when (> n 0)
      (%trail-drop tr n))))

(defmacro fx-smear-capture! (tr sm n dr u (len width) k)
  "Capture a drawn sword smear (e.g. a comet crescent) from trail TR into SM when the drawing number DR is new:
SM = x0 y0 z0 x1 y1 z1 bx by bz (a quadratic Bezier through the point U (0 base .. 1 tip) of the oldest, middle and
newest of the last <= 5 samples), half-width WIDTH, drawing, presence K (0 = none: fewer than 3 samples). WIDTH may
use the variable LEN, bound to the newest sample's base -> tip length; K may use N (the sample count). TR SM N DR:
variables; U WIDTH K: single-float forms. The caller draws SM (FX-CRESCENT ... :comet) while its presence is > 0. 0 B.
  (fx-smear-capture! tr sm n dr 0.7f0 (len (* 0.33f0 len)) (if (>= n 5) 0.98f0 0.6f0))"
  `(when (/= (aref ,sm 10) ,dr)                          ; a new drawing: re-capture from the trail
     (setf (aref ,sm 10) ,dr (aref ,sm 11) 0f0)
     (when (>= ,n 3)
       (let* ((%i0 (max 0 (- ,n 5))) (%im (floor (+ %i0 ,n -1) 2)) (%i1 (1- ,n)) (%o0 (* 6 %i0)) (%om (* 6 %im)) (%o1 (* 6 %i1)))
         (declare (fixnum %i0 %im %i1 %o0 %om %o1))
         (dotimes (%c 3)                                  ; the U points: oldest, middle, newest -> control through the middle
           (let* ((%u ,u)
                  (%p0 (+ (aref ,tr (+ %o0 %c)) (* %u (- (aref ,tr (+ %o0 %c 3)) (aref ,tr (+ %o0 %c))))))
                  (%pm (+ (aref ,tr (+ %om %c)) (* %u (- (aref ,tr (+ %om %c 3)) (aref ,tr (+ %om %c))))))
                  (%p1 (+ (aref ,tr (+ %o1 %c)) (* %u (- (aref ,tr (+ %o1 %c 3)) (aref ,tr (+ %o1 %c)))))))
             (declare (single-float %u %p0 %pm %p1))
             (setf (aref ,sm %c) %p0 (aref ,sm (+ %c 3)) %p1 (aref ,sm (+ %c 6)) (- (* 2f0 %pm) (* 0.5f0 (+ %p0 %p1))))))
         ,(if (labels ((uses (x) (or (eq x len) (and (consp x) (or (uses (car x)) (uses (cdr x))))))) (uses width))
              `(let* ((%lx (- (aref ,tr (+ %o1 3)) (aref ,tr %o1))) (%ly (- (aref ,tr (+ %o1 4)) (aref ,tr (+ %o1 1))))
                      (%lz (- (aref ,tr (+ %o1 5)) (aref ,tr (+ %o1 2)))) (,len (f-hypot %lx %ly %lz)))
                 (declare (single-float %lx %ly %lz ,len))
                 (setf (aref ,sm 9) ,width
                       (aref ,sm 11) ,k))
              `(setf (aref ,sm 9) ,width                ; (LEN unused: not computed, an unread float binding boxes)
                     (aref ,sm 11) ,k))))))

;;; ---------------------------------------------------------------- screen effects (UI layer)
(defun edge-vignette (r g b a frac)
  "Darken toward the screen edges with color (r g b) at alpha A; FRAC = band size."
  (let* ((w (window-width)) (h (window-height)) (bw (* w frac)) (bh (* h frac))
         (c1 (list r g b a)) (c0 (list r g b 0)))
    (ui-gradient 0 0 w bh c1 c0)
    (ui-gradient 0 (- h bh) w bh c0 c1)
    (ui-gradient 0 0 bw h c1 c0 :vertical nil)
    (ui-gradient (- w bw) 0 bw h c0 c1 :vertical nil)))

;;; ---------------------------------------------------------------- debug drawing: hit volumes
;;; Overlays for tuning hits (a debug key / command): hurt cylinders as two circles, attack
;;; volumes (hitvol.lisp) as FX-LINE outlines. Not for shipping frames (they cons: generic math).
(defun draw-circle (x y z r cr cg cb &key (segments 16) (width 0.012) (alpha 0.8))
  "Debug: horizontal circle of radius R centred on (X Y Z), in colour (CR CG CB)."
  (dotimes (i segments)
    (let ((a0 (* i (/ (* 2 pi) segments))) (a1 (* (1+ i) (/ (* 2 pi) segments))))
      (fx-line (+ x (* r (sin a0))) y (+ z (* r (cos a0))) (+ x (* r (sin a1))) y (+ z (* r (cos a1)))
               width cr cg cb alpha))))

(defun draw-vol (v ax ay az yaw &optional tx ty tz)
  "Debug: outline attack volume V (MAKE-VOL) of an attacker whose feet are at (AX AY AZ), facing
YAW, in red. A TSPH is drawn around the target point (TX TY+1.1 TZ) when it is given."
  (let ((fx (fwd-x (f32 yaw))) (fz (fwd-z (f32 yaw))))
    (case (round (aref v 0))
      (0 (let ((r (aref v 1)) (half (aref v 2)))                      ; ARC: both rims + the edges
           (dolist (hy (list (aref v 3) (aref v 4)))
             (let* ((n 12) (y (+ ay hy)))
               (dotimes (i n)
                 (let* ((t0 (+ yaw (- half) (* (/ (* 2 half) n) i))) (t1 (+ t0 (/ (* 2 half) n))))
                   (fx-line (- ax (* r (sin t0))) y (- az (* r (cos t0))) (- ax (* r (sin t1))) y (- az (* r (cos t1)))
                            0.015 1 0.2 0.2 0.9)))
               (when (< half 3.1)
                 (fx-line ax y az (- ax (* r (sin (+ yaw half)))) y (- az (* r (cos (+ yaw half)))) 0.015 1 0.2 0.2 0.9)
                 (fx-line ax y az (- ax (* r (sin (- yaw half)))) y (- az (* r (cos (- yaw half)))) 0.015 1 0.2 0.2 0.9))))))
      (1 (let ((y (+ ay (aref v 3))))                                   ; CAP: a thick line
           (fx-line (+ ax (* fx (aref v 1))) y (+ az (* fz (aref v 1))) (+ ax (* fx (aref v 2))) y (+ az (* fz (aref v 2)))
                    (aref v 4) 1 0.2 0.2 0.25)))
      (2 (draw-circle (+ ax (* fx (aref v 1))) (+ ay (aref v 2)) (+ az (* fz (aref v 1))) (aref v 3) 1 0.2 0.2))
      (3 (when tx (draw-circle tx (+ ty 1.1) tz (aref v 1) 1 0.2 0.2))))))
