;;;; hisagi-draw.lisp — Hisagi's draw code (cosmetic; the sim's points, 0 B a frame): the looks (the Shikai's and the Bankai's 風死絞縄),
;;;; the orb, the chains, HISAGI-DRAW, the HUD's sickle icon (the kit meter's :draw / :label, :deck) and his glyphs' name (split out of
;;;; hisagi-art.lisp 2026-10-21, refactor round 2). Loads after hisagi-art.lisp (the clips) and hisagi.lisp (the kits the meter
;;;; registrations name), before hisagi-cine.lisp and hisagi-stills.lisp.
(in-package :duel)

;;; ---------------------------------------------------------------- looks (cosmetic; the sim's points, 0 B a frame)
;; (every float crosses a call through these f32vecs: a float argument boxes; 0 B a frame, debug 83901)
(declaim (type f32vec *hs-v* *hs-w* *hs-q* *hs-a* *hs-m* *hs-m2* *hs-ml* *hs-lo* *hs-pt* *hs-grip-v*))
(defvar *hs-v* (make-f32 3) "The left sickle's grip (world).")
(defvar *hs-w* (make-f32 3) "A chain end (world).")
(defvar *hs-q* (make-f32 3) "A point (world).")
(defvar *hs-a* (make-f32 4) "HISAGI-DRAW's floats: [0] his facing yaw, [1] the flight's reach (m), [2] the bolt's length
(*HS-BOLTS*), [3] the Shikai's looks (1: the chain through the left fist, the flat spinning disc; 0: the Bankai's forms).")
(defvar *hs-m* (m4) "The left sickle's world matrix.")
(defvar *hs-m2* (m4) "A joint's matrix (scratch).")
(defvar *hs-ml* (m4) "The let-out left sickle's world matrix (%HS-LETOUT!).")
(defvar *hs-lo* (make-f32 16)
  "The let-outs (%HS-LETOUT!): [0] the right one's u (0 in the fist .. 1 out; HS-POSE, read by the draw hook of the same
fighter right after), [1-3] its fist, [4-6] its butt, [7] its point's distance from his feet (m, the tip table); [8] the
left one's u, [9-11] its fist, [12-14] its butt, [15] its point's distance.")
(defvar *hs-pt* (make-f32 3) "The left sickle's point the draw hook placed (%HS-POINT code 5: the windmill, SHIBARI's wrap).")
(declaim (type f32vec *hs-foe-d*))
(defvar *hs-foe-d* (make-f32 1)
  "A1 (DUEL_HISAGI §24.1): [0] how far (m, on the ground) the last draw placed the left sickle off the victim's feet on an
*HS-FOE-PATHS* path (-1: none; debug 83902).")
(defvar *hs-grip-v* (make-f32 3) "[0-1] each side's drawn grip slide (m, HS-POSE eases it to its clip's *HS-GRIP*); [2] the
last draw's effect seconds (HISAGI-DRAW keeps it for the next pose: the pose hook has no dt).")

(declaim (type f32vec *hs-ks*))
(defvar *hs-ks* (let ((v (make-f32 3))) (setf (aref v 0) 1f0 (aref v 1) (f32 (mv-reach (find-move :hs-k1))) (aref v 2) (f32 *hs-charge-step*)) v)
  "S1 (DUEL_HISAGI §23.1): [0] the drawn fighter's charge x (%HS-KS!: the windmill's disc, the K string's strikes), [1] K1
NAGE's line at x1 (its flight grows by it: HS-SCALED-TIP), [2] *HS-CHARGE-STEP*.")
(defun-fast %hs-ks! (n)
  "*HS-KS* [0] := the reach x of a charge of N frames (HS-CHARGE-SCALE's, in f32). 0 B."
  (declare (fixnum n))
  (let ((n (min n *hs-charge-max*))) (declare (fixnum n)) (setf (aref *hs-ks* 0) (+ 1f0 (* (aref *hs-ks* 2) (i->f n)))))
  nil)
(defun-fast %hs-fa-ks! (fa)
  "FA [1] (a flight's drawn reach) grown by the charge: + K1's line x (x - 1) (HS-SCALED-TIP; x1 elsewhere). 0 B."
  (declare (type f32vec fa))
  (setf (aref fa 1) (+ (aref fa 1) (* (aref *hs-ks* 1) (- (aref *hs-ks* 0) 1f0))))
  nil)

(declaim (type f32vec *hs-lk*))   ; (batches 2a / 2b, §28.11: undeclared, every %HS-LK-R read boxed: the stretched links consed 1-6 KB a call)
(defvar *hs-lk* (make-f32 5)
  "§25.13 (the ranged route links strike the victim where he is, HS-R-LINK-SEG): [0] his distance from Hisagi's feet (m,
capped at *HS-R-LINK-REACH*), [1] the link's drawn reach as authored (*HS-LK-REACH*), [2] 1 while a link is drawn, else 0.
%HS-LK-R stretches the link's chain to him. §28.15 (a bind reel, HS-KB-LK!): [3] 1 when [4] holds his bearing from
Hisagi's feet (rad, as a yaw), which %HS-LETOUT! then aims along instead of Hisagi's facing; 0 for the ranged links. A look.")
(defparameter *hs-lk-reach*
  '((:hs-r-k2s 5.0) (:hs-r-k3 5.0) (:hs-r-k2 5.0) (:hs-r-k3g 5.0) (:hs-r-as3b 5.0) (:hs-r-as3c 5.0))
  "The ranged moves that chase the victim (HS-R-LINK-SEG) -> the reach their clips' chains were authored to (§25.3 / §25.5:
J 6.0, K 5.0 m). §28.11 (batch 2a): J2 / J3 / J2s / J3G out (their chase gone since §28.10: drawn to their bands' edges),
AS3b MAKI / AS3c KAKE in (the core AS3's two chases, authored to 5.0).")
(defun-fast %hs-lk-set! (on rr pos opos)
  "*HS-LK* := ON (1 / 0), the authored reach RR, the distance from POS to OPOS (capped). 0 B."
  (declare (fixnum on) (single-float rr) (type f32vec pos opos))
  (setf (aref *hs-lk* 0) (f-min (the single-float *hs-r-link-reach*)
                                (f-hypot (- (aref opos 0) (aref pos 0)) (- (aref opos 2) (aref pos 2))))
        (aref *hs-lk* 1) rr (aref *hs-lk* 2) (i->f on) (aref *hs-lk* 3) 0f0)
  nil)
(defun hs-lk! (e)
  "*HS-LK* for E this frame: on in the ranged mode's route links (their move, its main phase), off else. 0 B."
  (let* ((f (fighter e)) (o (opp-of e))
         (row (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (eq (fighter-form f) :bankai) o
                   (assoc (mv-name (fighter-move f)) *hs-lk-reach*))))
    (if row (%hs-lk-set! 1 (second row) (pos-of e) (pos-of o)) (setf (aref *hs-lk* 2) 0f0 (aref *hs-lk* 3) 0f0))))
(defmacro %hs-lk-r (r)
  "R (a chain end's distance from his feet, m) stretched for a route link (*HS-LK*): x (1 + (k - 1) u^2), k the victim's
distance / the authored reach, u = R / the authored reach (<= 1): his strike point lands on the victim, the windup's near
keys barely move. R as is otherwise."
  `(let ((%r ,r)) (declare (single-float %r))
     (if (< (aref *hs-lk* 2) 0.5f0)
         %r
         (let* ((%rr (aref *hs-lk* 1)) (%u (f-min 1f0 (/ %r %rr))))
           (declare (single-float %rr %u))
           (* %r (+ 1f0 (* (- (/ (aref *hs-lk* 0) %rr) 1f0) %u %u)))))))

(defun-fast %hs-kb-lk-set! (rr pos opos bear)
  "*HS-LK* := on, the authored reach RR, the distance from POS to OPOS capped at RR (batch 2b, §28.12: a bind reel's
let-out on the victim, HS-KB-LK!); BEAR 1: [3] on, [4] the bearing from POS to OPOS (§28.15). 0 B."
  (declare (single-float rr) (type f32vec pos opos) (fixnum bear))
  (let ((dx (- (aref opos 0) (aref pos 0))) (dz (- (aref opos 2) (aref pos 2))))
    (declare (single-float dx dz))
    (setf (aref *hs-lk* 0) (f-min rr (f-hypot dx dz))
          (aref *hs-lk* 1) rr (aref *hs-lk* 2) 1f0 (aref *hs-lk* 3) (i->f bear)
          (aref *hs-lk* 4) (if (> (f-hypot dx dz) 0.05f0) (f-atan2 (- dx) (- dz)) 0f0)))
  nil)
(defun hs-kb-lk! (e clip)
  "Batch 2b (§28.12): after HS-LK!, when CLIP is one of *HS-KB-REELS* (the bind's hooks, MATOI's wrap), *HS-LK* on for it:
its let-out lies on the victim (his distance, at most its reach: as HS-B-HOOK-SEG's far end). §28.15: and along his
bearing (the hooks always: HS-CHAIN-SEG-TO aims at him; a :line reel, MATOI's volume along the facing, only once its move
touched him, a hit or a block, so a whiff stays on its line). Else nothing. 0 B."
  (let ((row (assoc clip *hs-kb-reels*)) (o (opp-of e)))
    (when (and row o)
      (%hs-kb-lk-set! (second row) (pos-of e) (pos-of o)
                      (if (or (null (third row)) (fighter-contact (fighter e))) 1 0)))))

(defparameter *hs-letout-v*
  (loop for (clip side f0 f1 f2 f3 r h az bulge) in *hs-letout*
        for sw = (consp az) for a1 = (if sw (second az) az)
        collect (list* clip side (coerce (mapcar #'f32 (list f0 f1 f2 f3 r (or h 0) (or a1 0) bulge (if az 1 0) (if h 1 0)
                                                             (if sw (first az) 0) (if sw (third az) 0) (if sw 1 0)))
                                         'f32vec)))
  "*HS-LETOUT* as (clip side . f32vec): f0 f1 f2 f3 r h az bulge az-p h-p, then a sweep's a0 a2 sweep-p (az its a1).")
(defun hs-letout-of (name side)
  "The let-out entry (an f32vec) of clip NAME's SIDE (:r / :l), or NIL. 0 B."
  (loop for x in *hs-letout-v* when (and (eq (first x) name) (eq (second x) side)) return (cddr x)))

(defun-fast %hs-letout! (m jm wj upper pos yaw kv fr out o)
  "M := a let-out sickle's weapon matrix (KV its *HS-LETOUT-V* entry at clip frame FR, FR an f32vec [0]): WJ its weapon
joint as the clip posed it (the fist; the held rod along its -Z), UPPER the shoulder (the arm's line), POS his feet, YAW
(an f32vec [0]) his facing. OUT[O] := u (smoothstep: 0 in the fist .. 1 out at R m from his feet), OUT[O+1..3] := the fist
(the chain's near end), OUT[O+4..6] := the sickle's butt (its far end). Its point: from the held point (u 0) to R m out
along the fist's bearing from his feet (or AZ degrees off his facing, or a sweep's; §28.15: off the victim's bearing
when *HS-LK* [3] says so, a bind reel), H m up (or on the arm's line), BULGE m higher
midway (a third of it coming back); the rod pointing away from the fist, the blades 35 degrees off flat. 0 B."
  (declare (type f32vec m jm pos yaw kv fr out) (fixnum wj upper o))
  (let* ((f (aref fr 0)) (f0 (aref kv 0)) (f1 (aref kv 1)) (f2 (aref kv 2)) (f3 (aref kv 3))
         (x (cond ((or (< f f0) (>= f f3)) 0f0)
                  ((< f f1) (/ (- f f0) (f-max 1f0 (- f1 f0))))
                  ((< f f2) 1f0)
                  (t (- 1f0 (/ (- f f2) (f-max 1f0 (- f3 f2)))))))
         (u (* x x (- 3f0 (* 2f0 x))))
         (wo (* 16 wj)) (so (* 16 upper))
         (fx (aref jm (+ wo 12))) (fy (aref jm (+ wo 13))) (fz (aref jm (+ wo 14)))
         (dhx (- (aref jm (+ wo 8)))) (dhy (- (aref jm (+ wo 9)))) (dhz (- (aref jm (+ wo 10))))
         (px (aref pos 0)) (pz (aref pos 2)) (dx (- fx px)) (dz (- fz pz)) (rf (f-hypot dx dz))
         (az (cond ((< (aref kv 12) 0.5f0) (aref kv 6))      ; (A1: a sweep, a0 -> a1 out to F1, -> a2 by F2)
                   ((< f f1) (+ (aref kv 10) (* x (- (aref kv 6) (aref kv 10)))))
                   ((< f f2) (+ (aref kv 6) (* (/ (- f f1) (f-max 1f0 (- f2 f1))) (- (aref kv 11) (aref kv 6)))))
                   (t (aref kv 11))))
         (a (+ (if (> (aref *hs-lk* 3) 0.5f0) (aref *hs-lk* 4) (aref yaw 0)) (* 0.017453292f0 az)))   ; (§28.15: a reel on his bearing)
         (bx (cond ((> (aref kv 8) 0.5f0) (- (f-sin a))) ((> rf 0.05f0) (/ dx rf)) (t (- (f-sin (aref yaw 0))))))
         (bz (cond ((> (aref kv 8) 0.5f0) (- (f-cos a))) ((> rf 0.05f0) (/ dz rf)) (t (- (f-cos (aref yaw 0))))))
         (r (%hs-lk-r (* (aref kv 4) (aref *hs-ks* 0))))   ; (S1: KARI-OTOSHI's arc at the charge, x1 elsewhere;
                                                             ;  §25.13: a route link's to the victim)
         (sh (f-hypot (- fx (aref jm (+ so 12))) (- fz (aref jm (+ so 14)))))
         (slope (f-clamp (/ (- fy (aref jm (+ so 13))) (f-max 0.05f0 sh)) -0.8f0 0.8f0))
         (ty (if (> (aref kv 9) 0.5f0) (aref kv 5) (+ fy (* slope (- r rf)))))
         (lift (* (aref kv 7) (f-sin (* 3.1415927f0 u)) (if (>= f f2) 0.33f0 1f0)))
         (k (* 0.75f0 (- 1f0 u)))
         (qx (+ fx (* u (- (+ px (* r bx)) fx)) (* k dhx)))
         (qy (+ fy (* u (- ty fy)) lift (* k dhy)))
         (qz (+ fz (* u (- (+ pz (* r bz)) fz)) (* k dhz)))
         (ex (- qx fx)) (ey (- qy fy)) (ez (- qz fz)) (el (f-hypot ex ey ez))
         (yx (if (> el 0.05f0) (/ ex el) dhx)) (yy (if (> el 0.05f0) (/ ey el) dhy)) (yz (if (> el 0.05f0) (/ ez el) dhz))
         (zl (f-hypot yz yx))
         (hx (if (> zl 0.05f0) (/ (- yz) zl) (f-cos (aref yaw 0)))) (hz (if (> zl 0.05f0) (/ yx zl) (- (f-sin (aref yaw 0)))))
         (z0x (* 0.82f0 hx)) (z0y 0.57f0) (z0z (* 0.82f0 hz))      ; (the blades tilted 35 degrees off flat: they read
         (dot (+ (* z0x yx) (* z0y yy) (* z0z yz)))                  ;  from a level camera and from above)
         (z1x (- z0x (* dot yx))) (z1y (- z0y (* dot yy))) (z1z (- z0z (* dot yz)))
         (zn (f-max 0.001f0 (f-hypot z1x z1y z1z)))
         (zx (/ z1x zn)) (zy (/ z1y zn)) (zz (/ z1z zn))
         (xx (- (* yy zz) (* yz zy))) (xy (- (* yz zx) (* yx zz))) (xz (- (* yx zy) (* yy zx)))
         (ox (- qx (* 0.75f0 yx))) (oy (- qy (* 0.75f0 yy))) (oz (- qz (* 0.75f0 yz))))
    (declare (single-float f f0 f1 f2 f3 x u fx fy fz dhx dhy dhz px pz dx dz rf az a bx bz r sh slope ty lift k qx qy qz
                           ex ey ez el yx yy yz zl hx hz z0x z0y z0z dot z1x z1y z1z zn zx zy zz xx xy xz ox oy oz)
             (fixnum wo so))
    (setf (aref m 0) xx (aref m 1) xy (aref m 2) xz (aref m 3) 0f0
          (aref m 4) yx (aref m 5) yy (aref m 6) yz (aref m 7) 0f0
          (aref m 8) zx (aref m 9) zy (aref m 10) zz (aref m 11) 0f0
          (aref m 12) ox (aref m 13) oy (aref m 14) oz (aref m 15) 1f0
          (aref out o) u (aref out (+ o 1)) fx (aref out (+ o 2)) fy (aref out (+ o 3)) fz
          (aref out (+ o 4)) (- ox (* 0.22f0 yx)) (aref out (+ o 5)) (- oy (* 0.22f0 yy)) (aref out (+ o 6)) (- oz (* 0.22f0 yz))
          (aref out (+ o 7)) (f-hypot (- qx px) (- qz pz))))
  nil)

(declaim (type f32vec *hs-fr* *hs-yaw*))
(defvar *hs-fr* (make-f32 1) "The clip frame %HS-LETOUT! reads.")

(defvar *hs-yaw* (make-f32 1) "His facing for %HS-LETOUT!.")
(defun-fast hs-pose (e m)
  "His kit's :pose hook (draw.lisp DRAW-FIGHTER, right after the FK; the FK origin in *POSE-AT*): the J strings' short grip
(*HS-GRIP*: the right rod slid back through his fist, eased at 4 m/s) and the right sickle let out on its chain
(*HS-LETOUT*: its :weapon-r joint moved where it flies, so the body draw puts it there). Other clips: nothing. A look. 0 B."
  (let* ((an (model-anim m)) (c (anim-clip an)) (name (if c (clip-name c) nil)) (jm (model-joints m)) (gv *hs-grip-v*)
         (side (if (eq e *p1*) 0 1)) (g (assoc name *hs-grip*))
         (target (if g (the single-float (second g)) 0f0)) (cur (aref gv side)) (step (* 4f0 (aref gv 2)))
         (o (* 16 (ji :weapon-r))) (kv (hs-letout-of name :r)))
    (declare (type f32vec jm gv) (fixnum side o) (single-float target cur step))
    (%hs-ks! (hss-charge (hs e)))
    (hs-lk! e)                                             ; (§25.13: a route link's chain stretched to the victim)
    (hs-kb-lk! e name)                                     ; (batch 2b: the bind's reels, onto the victim)
    (setf cur (cond ((<= step 0f0) target)                 ; (frozen effects, a still: the clip's grip at once)
                     ((< cur target) (f-min target (+ cur step))) (t (f-max target (- cur step))))
          (aref gv side) cur
          (aref *hs-lo* 0) 0f0)
    (when (> cur 0f0)
      (dotimes (i 3) (setf (aref jm (+ o 12 i)) (+ (aref jm (+ o 12 i)) (* cur (aref jm (+ o 8 i)))))))
    (when kv
      (let ((p *pose-at*) (fr *hs-fr*) (yw *hs-yaw*) (w *hs-m2*) (lo *hs-lo*))
        (declare (type f32vec p fr yw w lo))
        (setf (aref fr 0) (* 60f0 (the single-float (anim-time an))) (aref yw 0) (aref p 3))
        (%hs-letout! w jm (ji :weapon-r) (ji :upper-arm-r) p yw (the f32vec kv) fr lo 0)
        (when (> (aref lo 0) 0f0)                       ; the joint's axes from the weapon frame's (*WEAPON-M*'s inverse)
          (dotimes (i 3)
            (setf (aref jm (+ o i)) (- (aref w i)) (aref jm (+ o 4 i)) (- (aref w (+ 8 i)))
                  (aref jm (+ o 8 i)) (- (aref w (+ 4 i))) (aref jm (+ o 12 i)) (aref w (+ 12 i))))))))
  nil)

(declaim (fixnum *hs-chain-black*))
(defvar *hs-chain-black* 0
  "1 while the Bankai's chains are drawn (%HS-ORB-DRAW): VFX-HS-CHAIN's links are solid black kites in the alpha batch
(%HS-BLACK-KITE: no toon INK palette's white edge or core, no steel glint). The user, 2026-10-18: 「我希望鎖鏈是黑色的」.")
(declaim (fixnum *hs-chain-ink*))
(defvar *hs-chain-ink* 0
  "1 while P2's Hisagi is drawn (HISAGI-DRAW): %HS-BLACK-KITE draws the original ink link instead (the toon INK palette:
its white edge), so a mirror's two sets of chains read apart. The user, 2026-10-18: 「始解的鎖鏈也同樣改成黑色，而 P2 的鎖鏈則
改成原本的白色」.")
(defmacro %hs-black-kite (x y z ux uy uz len w &optional (push 0.1f0))
  "A solid black camera-facing kite centred at (X Y Z) along the unit (UX UY UZ), LEN long (0.6 ahead), half-width W,
pushed PUSH (0.1) m toward the eye (FX-SHARD's shape without its palette): the alpha batch at uv 0 is opaque, unshaded.
While *HS-CHAIN-INK* is 1 (P2) the original ink link instead (FX-SHARD, +PAL-INK+, W / 0.7: the width the black ones
lost). 0 B."
  `(let* ((%x0 ,x) (%y0 ,y) (%z0 ,z) (%ux ,ux) (%uy ,uy) (%uz ,uz) (%len ,len) (%w0 ,w))
     (declare (single-float %x0 %y0 %z0 %ux %uy %uz %len %w0))
     (if (= *hs-chain-ink* 1)
         (fx-shard %x0 %y0 %z0 %ux %uy %uz %len (* 1.43f0 %w0) 0.03f0 (+ 700f0 (* 100f0 %w0)) +pal-ink+ 0.9f0)
         (let* ((%e (camera-eye *camera*)) (%x %x0) (%y %y0) (%z %z0)
                (%dx (- (aref %e 0) %x)) (%dy (- (aref %e 1) %y)) (%dz (- (aref %e 2) %z))
                (%d (f-max 1f-3 (f-hypot %dx %dy %dz))) (%p (f-min ,push (* 0.5f0 %d))) (%sc (/ (- %d %p) %d))
                (%x (+ %x (* %p (/ %dx %d)))) (%y (+ %y (* %p (/ %dy %d)))) (%z (+ %z (* %p (/ %dz %d))))
                (%sx (- (* %uy %dz) (* %uz %dy))) (%sy (- (* %uz %dx) (* %ux %dz))) (%sz (- (* %ux %dy) (* %uy %dx)))
                (%w (/ (* %w0 %sc) (f-max 1f-5 (f-hypot %sx %sy %sz)))) (%f (* 0.6f0 %len %sc)) (%b (* 0.4f0 %len %sc)))
           (declare (type f32vec %e) (single-float %x %y %z %dx %dy %dz %d %p %sc %sx %sy %sz %w %f %b))
           (with-fx-verts (%v %o :alpha 6)
             (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (+ %x (* %w %sx)) (+ %y (* %w %sy)) (+ %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (+ %x (* %f %ux)) (+ %y (* %f %uy)) (+ %z (* %f %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %b %ux)) (- %y (* %b %uy)) (- %z (* %b %uz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0)
             (vtx (- %x (* %w %sx)) (- %y (* %w %sy)) (- %z (* %w %sz)) 0f0 0f0 0.035f0 0.035f0 0.05f0 1f0))))))

(defun-fast vfx-hs-chain (a b sag k)
  "Kazeshini's chain from point A to point B (f32vecs), sagging SAG m at its middle (a parabola; SAG < 0: -SAG m of slack
beyond the straight span, the sag that length gives, its lowest link kept 3 cm off the floor): ink links along the curve
turned alternately, a steel glint every other one, presence K (SAG and K: literals)."
  (declare (type f32vec a b) (single-float sag k))
  (let* ((x0 (aref a 0)) (y0 (aref a 1)) (z0 (aref a 2)) (dx (- (aref b 0) x0)) (dy (- (aref b 1) y0)) (dz (- (aref b 2) z0))
         (l (f-max 0.01f0 (f-hypot dx dy dz)))
         (sag (if (< sag 0f0)                                          ; (arc ~ span + 8 s^2 / 3 span)
                  (f-min (f-sqrt (* 0.375f0 l (- sag))) (f-max 0f0 (- (* 0.5f0 (+ y0 (aref b 1))) 0.03f0)))
                  sag))
         (n (min 48 (max 2 (f->i (/ (+ l (/ (* 2.67f0 sag sag) l)) 0.12f0))))) (dr (drawing-no)))
    (declare (single-float x0 y0 z0 dx dy dz l sag dr) (fixnum n))
    (dotimes (i n)
      (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (s (* 4f0 sag u (- 1f0 u)))
             (px (+ x0 (* u dx))) (py (- (+ y0 (* u dy)) s)) (pz (+ z0 (* u dz)))
             (ty (- dy (* 4f0 sag (- 1f0 (* 2f0 u))))) (tl (f-max 0.001f0 (f-hypot dx ty dz)))
             (ux (/ dx tl)) (uy (/ ty tl)) (uz (/ dz tl)))
        (declare (single-float u s px py pz ty tl ux uy uz))
        (if (= *hs-chain-black* 1)
            (%hs-black-kite px py pz ux uy uz 0.13f0 (if (evenp i) 0.028f0 0.013f0))   ; (x0.7: solid black reads heavier)
            (progn
              (fx-shard px py pz ux uy uz 0.13f0 (if (evenp i) 0.04f0 0.018f0) 0.03f0 (+ (i->f i) 700f0 dr) +pal-ink+ k)
              (when (evenp i) (fx-shard px py pz ux uy uz 0.06f0 0.01f0 0.03f0 (+ (i->f i) 760f0) +pal-steel+ k :push 0.14f0)))))))
  nil)

(defun-fast %hs-coil (c)
  "SHIBARI's wrap: three turns of chain round the victim's body, centred at C (an f32vec: his feet), 0.42 m round, at
0.8 / 1.05 / 1.3 m (eight chords each, VFX-HS-CHAIN). 0 B."
  (declare (type f32vec c))
  (let ((a *hs-w*) (b *hs-q*))
    (declare (type f32vec a b))
    (dotimes (ring 3)
      (dotimes (i 8)
        (let* ((h (+ 0.8f0 (* 0.25f0 (i->f ring)))) (a0 (* 0.7853982f0 (+ (i->f i) (* 0.33f0 (i->f ring)))))
               (a1 (+ a0 0.7853982f0)))
          (declare (single-float h a0 a1))
          (setf (aref a 0) (+ (aref c 0) (* 0.42f0 (f-sin a0))) (aref a 1) (+ h (* 0.04f0 (i->f i)))
                (aref a 2) (+ (aref c 2) (* 0.42f0 (f-cos a0)))
                (aref b 0) (+ (aref c 0) (* 0.42f0 (f-sin a1))) (aref b 1) (+ h (* 0.04f0 (i->f (1+ i))))
                (aref b 2) (+ (aref c 2) (* 0.42f0 (f-cos a1))))
          (vfx-hs-chain a b 0f0 0.9f0)))))
  nil)

(defparameter *hs-tsumuji-orbit* 0.45
  "AS1 TSUMUJI's drawn sickle circles the victim this far from his centre (m; %HS-POINT code 12, §27.10; within 0.15 m of
its hit, the chain's capsule of *HS-SEG-R* 0.35 m round the line to his centre): its blades
(0.5 m round their crossing) pass through him, the disc stays outside his silhouette. A look.")
(defun-fast %hs-point (out code jm pos fa anchor vpos)
  "OUT := one of the left sickle's points: CODE 0 the left fist (:weapon-l), 1 the thrown grip (FA[1] - the sickle's length
along his facing FA[0], 1.1 m up: its point at FA[1]), 2 the anchor (hooked: the victim's chest when he is within
*HS-HOOK-R* of it, else on the ground), 3 the windmill's circle (1.9 m round him, 1.7 m up, the fx clock), 4 the sim hand
(HS-HAND's point: the pulls' chain end), 5 the grip under the point the draw hook placed (*HS-PT*: the Shikai's windmill,
SHIBARI's wrap); A1's (*HS-FOE-PATHS*): 6 the victim's centre (*HS-ANCHOR-UP* over his feet: HS-FOE-SEG's end), 7 / 8 3.0 /
3.8 m over his feet, 9 the saw's wheel (0.8 m round the left fist, upright in his facing's plane, by the clip frame), 10 K1's
sweep end (6.0 m x the charge, 40 degrees to his right, 1.0 m up), 11 HS-CORE-SEG's far end (the victim's centre, or
*HS-CORE-CHAIN* m along the line to him), 12 AS1 TSUMUJI's orbit (§27.10): *HS-TSUMUJI-ORBIT* m round 11 in the tipped
flat plane, a quarter turn every 4 clip frames, at each %HS-TSUMUJI-CUTS arc's head on its hit frame."
  (declare (type f32vec out jm pos fa anchor vpos) (fixnum code))
  (let* ((yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
    (declare (single-float yaw fx fz))
    (case code
      (0 (joint-point! out jm (ji :weapon-l) 0f0 0f0 0f0))
      (1 (let ((d (- (aref fa 1) 0.75f0)))
           (declare (single-float d))
           (setf (aref out 0) (+ (aref pos 0) (* d fx)) (aref out 1) 1.1f0 (aref out 2) (+ (aref pos 2) (* d fz)))))
      (2 (let* ((ax (aref anchor 0)) (az (aref anchor 1)) (hx (- (aref vpos 0) ax)) (hz (- (aref vpos 2) az))
                (hr (the single-float *hs-hook-r*)))
           (declare (single-float ax az hx hz hr))
           (if (< (+ (* hx hx) (* hz hz)) (* hr hr))
               (setf (aref out 0) (aref vpos 0) (aref out 1) (+ (aref vpos 1) 1.1f0) (aref out 2) (aref vpos 2))
               (setf (aref out 0) ax (aref out 1) 0.06f0 (aref out 2) az))))
      (3 (let ((a (* 12f0 (fx-clock))))
           (declare (single-float a))
           (setf (aref out 0) (+ (aref pos 0) (* 1.9f0 (f-sin a))) (aref out 1) 1.7f0 (aref out 2) (+ (aref pos 2) (* 1.9f0 (f-cos a))))))
      (5 (let ((p *hs-pt*)) (declare (type f32vec p)) (replace out p)))
      ((6 7 8) (let ((h (case code (6 (the single-float *hs-anchor-up*)) (7 3.0f0) (t 3.8f0))))
                 (declare (single-float h))
                 (setf (aref out 0) (aref vpos 0) (aref out 1) (+ (aref vpos 1) h) (aref out 2) (aref vpos 2))))
      (9 (let* ((fr (aref *hs-fr* 0)) (g (- fr 8f0)) (th (- 1.5707964f0 (* 0.1f0 g g))))   ; (spun up: faster each turn,
           (declare (single-float fr g th))                                                 ;  rolling forward)
           (joint-point! out jm (ji :weapon-l) 0f0 0f0 0f0)
           (setf (aref out 0) (+ (aref out 0) (* 0.8f0 (f-cos th) fx)) (aref out 1) (+ (aref out 1) (* 0.8f0 (f-sin th)))
                 (aref out 2) (+ (aref out 2) (* 0.8f0 (f-cos th) fz)))))
      (10 (let* ((r (* 6f0 (aref *hs-ks* 0))) (a (- yaw 0.6981317f0)))
            (declare (single-float r a))
            (setf (aref out 0) (- (aref pos 0) (* r (f-sin a))) (aref out 1) 1.0f0 (aref out 2) (- (aref pos 2) (* r (f-cos a))))))
      ((11 12) (let* ((dx (- (aref vpos 0) (aref pos 0))) (dz (- (aref vpos 2) (aref pos 2))) (d (f-hypot dx dz))   ; (HS-CHAIN-
                      (cc (the single-float *hs-core-chain*)) (k (if (> d cc) (/ cc d) 1f0)))              ;  SEG-TO's far end)
                 (declare (single-float dx dz d cc k))
                 (setf (aref out 0) (+ (aref pos 0) (* k dx)) (aref out 1) (+ (aref vpos 1) (the single-float *hs-anchor-up*))
                       (aref out 2) (+ (aref pos 2) (* k dz)))
                 (when (= code 12)                                      ; (the orbit: at each cut's head on its hit frame)
                   (let* ((r (the single-float *hs-tsumuji-orbit*)) (b (+ 4.4434609f0 (* 0.3926991f0 (- (aref *hs-fr* 0) 14f0))))
                          (a (+ yaw b)))
                     (declare (single-float r b a))
                     (setf (aref out 0) (- (aref out 0) (* r (f-sin a))) (aref out 1) (+ (aref out 1) (* 0.404f0 r (f-cos b)))
                           (aref out 2) (- (aref out 2) (* r (f-cos a))))))))
      (t (setf (aref out 0) (+ (aref pos 0) (* (the single-float *hs-hand-ahead*) fx))
               (aref out 1) (+ (aref pos 1) (the single-float *hs-hand-up*))
               (aref out 2) (+ (aref pos 2) (* (the single-float *hs-hand-ahead*) fz))))))
  nil)

(defun-fast %hs-place! (m v fa spin)
  "M := the flying sickle's world matrix: its grip at V, turned to his facing FA[0], its blade pitched forward (SPIN 0),
tumbling with the fx clock (SPIN 1), or spun flat about its blades' crossing (SPIN 2: the Shikai's thrown disc, the
crossing 0.6 m short of V's point, so its far edge stays within 0.15 m of it); A1's: SPIN 3 the upright saw (its blades'
crossing at V), 4 point down (its point at V); §27.10: 5 AS1 TSUMUJI's flat disc (its blades' crossing at V, spun in the
horizontal plane with its far edge tipped 22 degrees up, so from the behind camera it reads as a spinning disc, not a
line). M4-EULER!'s layout, inline (its float arguments would box)."
  (declare (type f32vec m v fa) (fixnum spin))
  (when (= spin 5)                                                    ; §27.10: the plane's in-plane axes P = his right
    (let* ((fx (- (f-sin (aref fa 0)))) (fz (- (f-cos (aref fa 0))))  ;  S (fz, 0, -fx) and Q = his facing tipped up
           (a (* -40f0 (fx-clock))) (c (f-cos a)) (s (f-sin a))         ;  (ct fx, st, ct fz); Y = c P + s Q, Z = c Q - s P,
           (ct 0.9271839f0) (st 0.3746066f0))                           ;  X = P x Q
      (declare (single-float fx fz a c s ct st))
      (setf (aref m 0) (* fx st) (aref m 1) (- ct) (aref m 2) (* fz st) (aref m 3) 0f0
            (aref m 4) (+ (* c fz) (* s ct fx)) (aref m 5) (* s st) (aref m 6) (+ (* c (- fx)) (* s ct fz)) (aref m 7) 0f0
            (aref m 8) (- (* c ct fx) (* s fz)) (aref m 9) (* c st) (aref m 10) (- (* c ct fz) (* s (- fx))) (aref m 11) 0f0
            (aref m 15) 1f0)
      (dotimes (i 3) (setf (aref m (+ 12 i)) (- (aref v i) (* 0.5f0 (aref m (+ 4 i)))))))
    (return-from %hs-place! nil))
  (when (>= spin 3)                                                   ; A1: 3 the upright saw (its crossing at V, spun
    (let* ((fx (- (f-sin (aref fa 0)))) (fz (- (f-cos (aref fa 0))))  ;  rolling forward in his facing's plane, its top
           (a (* -30f0 (fx-clock))) (c (if (= spin 3) (f-cos a) 0f0))  ;  leant 30 degrees to his left so it reads as a
           (s (if (= spin 3) (f-sin a) -1f0))                          ;  disc from behind), 4 point down (its point at
           (kr (if (= spin 3) 0.5f0 0f0)) (ku (if (= spin 3) 0.8660254f0 1f0))   ;  V: the plunge); its plane's up
           (ux (* kr fz)) (uz (* (- kr) fx)))                          ;  U' = (KR fz, KU, -KR fx)
      (declare (single-float fx fz a c s kr ku ux uz))
      (setf (aref m 0) (* (- ku) fz) (aref m 1) kr (aref m 2) (* ku fx) (aref m 3) 0f0   ; (X = F x U')
            (aref m 4) (+ (* c fx) (* s ux)) (aref m 5) (* s ku) (aref m 6) (+ (* c fz) (* s uz)) (aref m 7) 0f0
            (aref m 8) (- (* c ux) (* s fx)) (aref m 9) (* c ku) (aref m 10) (- (* c uz) (* s fz)) (aref m 11) 0f0
            (aref m 15) 1f0)
      (let ((k (if (= spin 3) 0.5f0 0.75f0)))                         ; (the crossing 0.5 up the rod, the point 0.75)
        (declare (single-float k))
        (dotimes (i 3) (setf (aref m (+ 12 i)) (- (aref v i) (* k (aref m (+ 4 i))))))))
    (return-from %hs-place! nil))
  (if (= spin 2)
      (let* ((a (+ (aref fa 0) (* 25f0 (fx-clock)))) (yx (- (f-sin a))) (yz (- (f-cos a)))
             (fx (- (f-sin (aref fa 0)))) (fz (- (f-cos (aref fa 0))))
             (cx (+ (aref v 0) (* 0.15f0 fx))) (cz (+ (aref v 2) (* 0.15f0 fz))))   ; (V's point 0.75 ahead: the crossing 0.6)
        (declare (single-float a yx yz fx fz cx cz))
        (setf (aref m 0) 0f0 (aref m 1) -1f0 (aref m 2) 0f0 (aref m 3) 0f0
              (aref m 4) yx (aref m 5) 0f0 (aref m 6) yz (aref m 7) 0f0
              (aref m 8) (- yz) (aref m 9) 0f0 (aref m 10) yx (aref m 11) 0f0
              (aref m 12) (- cx (* 0.5f0 yx)) (aref m 13) (aref v 1) (aref m 14) (- cz (* 0.5f0 yz)) (aref m 15) 1f0))
      (let* ((yaw (aref fa 0)) (pitch (if (= spin 0) -1.5708f0 (* 9f0 (fx-clock))))
             (cy (f-cos yaw)) (sy (f-sin yaw)) (cp (f-cos pitch)) (sp (f-sin pitch)))
        (declare (single-float yaw pitch cy sy cp sp))
        (setf (aref m 0) cy (aref m 1) 0f0 (aref m 2) (- sy) (aref m 3) 0f0
              (aref m 4) (* sy sp) (aref m 5) cp (aref m 6) (* cy sp) (aref m 7) 0f0
              (aref m 8) (* sy cp) (aref m 9) (- sp) (aref m 10) (* cy cp) (aref m 11) 0f0
              (aref m 12) (aref v 0) (aref m 13) (aref v 1) (aref m 14) (aref v 2) (aref m 15) 1f0)))
  nil)

(defvar *hs-hw* (make-f32 3) "The hawser's hanging end, then the hung sickle's point (%HS-HAWSER).")
(defun-fast %hs-hawser (jm fa w v q m tint)
  "Pointer 2's stance (:hs-st-bind, DUEL_HISAGI §26): the chain from W (the right rod's butt) up to the left fist at his
chest, over his left shoulder and down his back to the left sickle hanging there point down (V, Q scratch; M its matrix).
A look. 0 B."
  (declare (type f32vec jm fa w v q m))
  (let* ((h *hs-hw*) (yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
    (declare (type f32vec h) (single-float yaw fx fz))
    (joint-point! q jm (ji :weapon-l) 0f0 0f0 0f0)                 ; the fist at his chest
    (vfx-hs-chain w q 0.08f0 0.9f0)
    (joint-point! v jm (ji :shoulder-l) 0f0 0f0 0f0)
    (setf (aref v 1) (+ (aref v 1) 0.1f0))                         ; over the shoulder
    (vfx-hs-chain q v 0.02f0 0.9f0)
    (setf (aref h 0) (- (aref v 0) (* 0.24f0 fx) (* -0.2f0 fz)) (aref h 1) (- (aref v 1) 0.3f0)   ; behind him and out to his left
          (aref h 2) (- (aref v 2) (* 0.24f0 fz) (* 0.2f0 fx)))                                   ;  (outside his silhouette)
    (vfx-hs-chain v h 0.02f0 0.9f0)                                ; down his back to the sickle's butt
    (setf (aref h 1) (- (aref h 1) 0.97f0)                         ; (its point: the butt 0.97 m above it)
          (aref fa 0) (+ (aref fa 0) 0.785f0))                     ; (its blades turned 45 degrees: read from behind and the side)
    (%hs-place! m h fa 4)
    (setf (aref fa 0) (- (aref fa 0) 0.785f0))
    (draw-weapon :kazeshini m :tint tint))
  nil)

(defun-fast %hs-sparks (a b n)
  "Pointer 3's stance (:hs-st-raiden, DUEL_HISAGI §26): N (4) small sparks crawling down the taut chain from B (the raised
left rod's butt) to A, flickering on the fx clock (jade, a white crackle); §27.5: CHIKUDEN's / TAME's charge along the
binding chain from his fist to the sickle on the victim (N 10: twice the size, jigged twice as far, and a jade star
crackling round the sickle at A). A look. 0 B."
  (declare (type f32vec a b) (fixnum n))
  (let* ((dx (- (aref a 0) (aref b 0))) (dy (- (aref a 1) (aref b 1))) (dz (- (aref a 2) (aref b 2)))
         (l (f-max 0.01f0 (f-hypot dx dy dz))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
         (nl (f-max 0.01f0 (f-hypot uy ux 0f0))) (nx (/ (- uy) nl)) (ny (/ ux nl))
         (tm (* 1.4f0 (fx-clock))) (dr (drawing-no 24f0)) (du (/ 1f0 (i->f (max 1 n)))) (g (if (> n 4) 2f0 1f0)))
    (declare (single-float dx dy dz l ux uy uz nl nx ny tm dr du g))
    (dotimes (i n)
      (let* ((s (+ tm (* du (i->f i)))) (u (- s (i->f (f->i s))))
             (jig (* 0.05f0 g (f-sin (+ dr (* 2.3f0 (i->f i))))))
             (px (+ (aref b 0) (* u dx) (* jig nx))) (py (+ (aref b 1) (* u dy) (* jig ny))) (pz (+ (aref b 2) (* u dz))))
        (declare (single-float s u jig px py pz))
        (fx-shard px py pz ux uy uz (* 0.16f0 g) (* 0.03f0 g) 0.1f0 (+ (i->f i) 860f0 dr) +pal-jade+ 0.95f0 :push 0.14f0)
        (fx-shard px py pz nx ny 0f0 (* 0.1f0 g) (* 0.012f0 g) 0.08f0 (+ (i->f i) 880f0 dr) +pal-hit+ 0.95f0 :push 0.18f0)))
    (when (> n 4)
      (fx-star (aref a 0) (aref a 1) (aref a 2) 0.08f0 0.34f0 7 dr 0f0 0f0 0.25f0 (+ 890f0 dr) +pal-jade+ 0.9f0)))
  nil)

;;; §27.5 (batch 2, presentation only): pointer 2 刈's wound chain, 放電 HODEN's burst on the victim, 餘電 ZANDEN's sparks on him
(declaim (type f32vec *hs-wd0* *hs-wd1*))
(defvar *hs-wd0* (make-f32 3) "%HS-WOUND / %HS-HODEN-BURST / %HS-ZAN's scratch point.")
(defvar *hs-wd1* (make-f32 3) "Their second scratch point.")
(defun-fast %hs-wrist-coil (jm j)
  "The chain wound twice round the wrist of forearm joint J (JM's; 3.5-8 cm above the hand, 6.5 cm round, 12 chords, solid
black links as the chain's): §27.5's %HS-WOUND, batch 2b's 絞 stance (the right fist's). A look. 0 B."
  (declare (type f32vec jm) (fixnum j))
  (let ((p *hs-wd0*) (q *hs-wd1*))
    (declare (type f32vec p q))
    (dotimes (i 12)
      (let* ((a0 (* 1.0471976f0 (i->f i))) (a1 (+ a0 1.0471976f0))
             (y0 (- -0.19f0 (* 0.0045f0 (i->f i)))) (y1 (- y0 0.0045f0)))
        (declare (single-float a0 a1 y0 y1))
        (joint-point! p jm j (* 0.065f0 (f-sin a0)) y0 (* 0.065f0 (f-cos a0)))
        (joint-point! q jm j (* 0.065f0 (f-sin a1)) y1 (* 0.065f0 (f-cos a1)))
        (let* ((dx (- (aref q 0) (aref p 0))) (dy (- (aref q 1) (aref p 1))) (dz (- (aref q 2) (aref p 2)))
               (l (f-max 1f-4 (f-hypot dx dy dz))))
          (declare (single-float dx dy dz l))
          (%hs-black-kite (aref p 0) (aref p 1) (aref p 2) (/ dx l) (/ dy l) (/ dz l) 0.06f0
                          (if (evenp i) 0.022f0 0.01f0))))))
  nil)
(defun-fast %hs-wound (jm)
  "Pointer 2 刈 (§27.5): the chain wound twice round each wrist (%HS-WRIST-COIL, the right then the left): his stance and the
刈 strikes (lo 8192). A look. 0 B."
  (declare (type f32vec jm))
  (%hs-wrist-coil jm (ji :lower-arm-r))
  (%hs-wrist-coil jm (ji :lower-arm-l))
  nil)
(defun-fast %hs-kb-wrap (jm vpos f0 f1)
  "Batch 2b (§28.12, *HS-KB-WRAPS*): on clip frames F0 <= *HS-FR* < F1, the chain wound three times round the victim (VPOS his
feet: %HS-COIL) and run taut from Hisagi's left fist (JM his joints) to its top turn, toward him. A look. 0 B."
  (declare (type f32vec jm vpos) (fixnum f0 f1))
  (let ((f (aref *hs-fr* 0)) (a *hs-wd0*) (b *hs-wd1*))
    (declare (single-float f) (type f32vec a b))
    (when (and (>= f (i->f f0)) (< f (i->f f1)))
      (%hs-coil vpos)
      (joint-point! a jm (ji :weapon-l) 0f0 0f0 0f0)
      (let* ((dx (- (aref a 0) (aref vpos 0))) (dz (- (aref a 2) (aref vpos 2))) (d (f-max 0.01f0 (f-hypot dx dz))))
        (declare (single-float dx dz d))
        (setf (aref b 0) (+ (aref vpos 0) (* 0.42f0 (/ dx d))) (aref b 1) 1.3f0 (aref b 2) (+ (aref vpos 2) (* 0.42f0 (/ dz d)))))
      (vfx-hs-chain a b 0f0 0.9f0)))
  nil)

(defun-fast %hs-draw (jm pos fa anchor vpos a b n d tint lightning lo)
  "The left sickle and the chain: in the left fist (A = B = 0: the chain slack between the fists), else at the point
between codes A and B at N / D (%HS-POINT), its point out along his facing, the chain to it from the right fist; the
pulls (B 4) draw the chain along HS-CHAIN-SEG's segment (anchor to the sim hand). LIGHTNING 1: TSUZURI RAIDEN's bolt along
his line, 0.5 m to FA[2] (*HS-BOLTS*). LO, the Shikai's looks (bits; 0: B2a's, the Bankai's): 1 the right sickle let out (HS-POSE: the chain from
its butt to the right fist), 2 the left one (*HS-ML*, *HS-LO* [8-14]), 4 the chain from the right rod through the left fist
to the out sickle (the thrower's hand), 64 the flat spinning disc (a flight), 8 the garrote (the slack through the victim's neck), 16 the
pull's tail (the sim hand to the left fist), 32 SHIBARI's wrap round the victim, 128 MAKI's curl (the flight bowed 1.1 m
out to his left midway: the left-to-right wrap); the core system's pointer stances (§26): 2048 the bind's hawser
(%HS-HAWSER), 4096 the lightning's taut chain and its sparks (%HS-SPARKS); §27.5: 8192 pointer 2 刈's chain wound round
both wrists (%HS-WOUND; in the stance a short taut span between the fists), 16384 CHIKUDEN's / TAME's charge running
along the chain to the sickle on the victim (%HS-SPARKS, ten); §27.6: 32768 縛雷's binding chain drawn taut from the left
fist to the sickle wound on him."
  (declare (type f32vec jm pos fa anchor vpos) (fixnum a b n d lightning lo))
  (let ((v *hs-v*) (w *hs-w*) (q *hs-q*) (m *hs-m*) (m2 *hs-m2*) (l *hs-lo*))
    (declare (type f32vec v w q m m2 l))
    (joint-point! w jm (ji :weapon-r) 0f0 0f0 0.22f0)                 ; the right rod's forked butt: the chain fixes there
    (when (logtest lo 1)                                              ; let out: butt -> right fist; the slack from the fist
      (setf (aref q 0) (aref l 1) (aref q 1) (aref l 2) (aref q 2) (aref l 3))
      (vfx-hs-chain w q 0.06f0 0.9f0)
      (replace w q))
    (if (and (= a 0) (= b 0))
        (if (logtest lo 2048)
            (%hs-hawser jm fa w v q m tint)
        (progn
          (if (logtest lo 2)
              (progn (draw-weapon :kazeshini *hs-ml* :tint tint)
                     (setf (aref v 0) (aref l 9) (aref v 1) (aref l 10) (aref v 2) (aref l 11)
                           (aref q 0) (aref l 12) (aref q 1) (aref l 13) (aref q 2) (aref l 14))
                     (if (> (aref l 15) 5.5f0)                        ; (V: the left fist, the middle's far end;
                         (%hs-chain2 v q)                              ;  A1: K1's sweep taut, in two pieces)
                         (vfx-hs-chain v q 0.06f0 0.9f0)))
              (let ((j (* 16 (ji :weapon-l))))
                (replace m2 jm :start2 j :end2 (+ j 16))
                (m4-mul! m m2 *weapon-m*)
                (draw-weapon :kazeshini m :tint tint)
                (joint-point! v jm (ji :weapon-l) 0f0 0f0 0.22f0)))   ; butt to butt, 1.2 m of slack (§11.1)
          (cond ((logtest lo 8)                                       ; the garrote: through his neck
                 (setf (aref q 0) (aref vpos 0) (aref q 1) (+ (aref vpos 1) 1.45f0) (aref q 2) (aref vpos 2))
                 (vfx-hs-chain w q 0.02f0 0.9f0) (vfx-hs-chain q v 0.02f0 0.9f0))
                ((logtest lo 3) (vfx-hs-chain w v -0.5f0 0.9f0))
                ((logtest lo 4096) (vfx-hs-chain w v 0.03f0 0.9f0) (%hs-sparks w v 4))   ; (§26: taut, sparking)
                ((logtest lo 8192) (vfx-hs-chain w v 0.05f0 0.9f0))        ; (§27.5: 刈's short span, fist to fist)
                (t (vfx-hs-chain w v -1.2f0 0.9f0)))
          (when (logtest lo 8192) (%hs-wound jm))))
        (let* ((u (f-clamp (/ (i->f n) (i->f (max 1 d))) 0f0 1f0)) (ov (logand 7 (ash lo -8)))   ; (A1: a path's spin)
               (spin (cond ((> ov 0) ov) ((and (logtest lo 64) (/= a 2) (/= b 2) (/= b 4)) 2) ((= a b) 0) (t 1))))
          (declare (single-float u) (fixnum ov spin))
          (%hs-point v a jm pos fa anchor vpos)
          (%hs-point q b jm pos fa anchor vpos)
          (dotimes (i 3) (setf (aref v i) (+ (aref v i) (* u (- (aref q i) (aref v i))))))
          (setf (aref *hs-foe-d* 0)                                   ; (A1: how far it is placed off the victim, 83902)
                (if (> ov 0) (f-hypot (- (aref v 0) (aref vpos 0)) (- (aref v 2) (aref vpos 2))) -1f0))
          (when (logtest lo 128)                                      ; MAKI's curl: out to his left midway, in from there
            (let ((k (* 1.1f0 (f-sin (* 3.1415927f0 u)))) (yaw (aref fa 0)))
              (declare (single-float k yaw))
              (setf (aref v 0) (- (aref v 0) (* k (f-cos yaw))) (aref v 2) (+ (aref v 2) (* k (f-sin yaw))))))
          (%hs-place! m v fa spin)
          (draw-weapon :kazeshini m :tint tint)
          (when (or (= spin 3) (= spin 5))                            ; (A1: the saw's spin, three ink smears trailing
            (let ((dr (drawing-no)))                                  ;  its blades round V in its plane: M's Y and Z)
              (declare (single-float dr))
              (dotimes (j 3)
                (let* ((h (* 2.0943951f0 (i->f j))) (tq (+ h 1.5707964f0)) (mq (+ h 0.7853982f0))
                       (ch (* 0.55f0 (f-cos h))) (sh (* 0.55f0 (f-sin h))) (ct (* 0.55f0 (f-cos tq))) (st (* 0.55f0 (f-sin tq)))
                       (cm (* 0.7778f0 (f-cos mq))) (sm (* 0.7778f0 (f-sin mq))))
                  (declare (single-float h tq mq ch sh ct st cm sm))
                  (fx-crescent (+ (aref v 0) (* ct (aref m 4)) (* st (aref m 8))) (+ (aref v 1) (* ct (aref m 5)) (* st (aref m 9)))
                               (+ (aref v 2) (* ct (aref m 6)) (* st (aref m 10)))
                               (+ (aref v 0) (* ch (aref m 4)) (* sh (aref m 8))) (+ (aref v 1) (* ch (aref m 5)) (* sh (aref m 9)))
                               (+ (aref v 2) (* ch (aref m 6)) (* sh (aref m 10)))
                               (+ (aref v 0) (* cm (aref m 4)) (* sm (aref m 8))) (+ (aref v 1) (* cm (aref m 5)) (* sm (aref m 9)))
                               (+ (aref v 2) (* cm (aref m 6)) (* sm (aref m 10)))
                               0.06f0 :comet 0.03f0 (+ 900f0 dr (i->f j)) +pal-ink+ 0.85f0 :push 0.2f0)))))
          (if (>= spin 2)                                             ; (the disc, the saw, the plunge: its butt off M)
              (dotimes (i 3) (setf (aref v i) (+ (aref m (+ 12 i)) (* -0.22f0 (aref m (+ 4 i))))))
              (dotimes (i 3) (setf (aref v i) (- (aref v i) (* 0.22f0 (aref m (+ 4 i)))))))   ; (its butt: the rod is M's +Y)
          (if (logtest lo 4)                                          ; the thrower's hand: right rod -> left fist -> sickle
              (progn (joint-point! q jm (ji :weapon-l) 0f0 0f0 0f0)
                     (vfx-hs-chain w q -0.4f0 0.9f0)
                     (cond ((> ov 0) (%hs-chain2 q v))                ; (A1's paths: taut)
                           ((logtest lo 32768) (vfx-hs-chain q v 0.03f0 0.9f0))   ; (§27.6: 縛雷's binding chain, taut)
                           ((= a b) (vfx-hs-chain q v 0.12f0 0.9f0)) (t (vfx-hs-chain q v 0.04f0 0.9f0)))
                     (when (logtest lo 16384) (%hs-sparks v q 10)))     ; (§27.5: the charge, fist -> victim)
              (if (= a b) (vfx-hs-chain w v 0.12f0 0.9f0) (vfx-hs-chain w v 0.04f0 0.9f0)))
          (when (= b 4)                                               ; the pull: the chain taut along the sim's segment
            (setf (aref v 0) (aref anchor 0) (aref v 1) (the single-float *hs-anchor-up*) (aref v 2) (aref anchor 1))
            (%hs-point q 4 jm pos fa anchor vpos)
            (vfx-hs-chain v q 0f0 0.7f0)
            (when (logtest lo 16)                                     ; (and on, over his guiding arm, to the hauling fist)
              (joint-point! v jm (ji :weapon-l) 0f0 0f0 0f0)
              (vfx-hs-chain q v 0.05f0 0.8f0)))
          (when (logtest lo 32) (%hs-coil vpos))))
    (when (= lightning 1)
      (let* ((yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (dr (drawing-no 24f0))
             (nb (1+ (f->i (* 2f0 (- (aref fa 2) 0.5f0))))))
        (declare (single-float yaw fx fz dr) (fixnum nb))
        (dotimes (i nb)
          (let* ((s (+ 0.5f0 (* 0.5f0 (i->f i)))) (jig (* 0.12f0 (f-sin (+ dr (* 2.3f0 (i->f i))))))
                 (px (+ (aref pos 0) (* s fx) (* jig fz))) (pz (- (+ (aref pos 2) (* s fz)) (* jig fx))))
            (declare (single-float s jig px pz))
            (fx-shard px 1.1f0 pz fx 0f0 fz 0.55f0 0.05f0 0.12f0 (+ (i->f i) 800f0 dr) +pal-jade+ 0.95f0 :push 0.12f0)
            (fx-shard px 1.1f0 pz fx 0f0 fz 0.5f0 0.016f0 0.08f0 (+ (i->f i) 840f0 dr) +pal-hit+ 0.95f0 :push 0.16f0))))))
  nil)

(defun hs-flight-codes (st name sf s a)
  "The left sickle's draw codes for move NAME at move frame SF (S, A its frames; *HS-FLIGHTS*' moves): values A B N D."
  (let* ((fl (assoc name *hs-flights*)) (end (+ s a)) (throw (third fl)))
    (cond ((< sf (- s 4)) (values 0 0 0 1))
          ((< sf s) (values 0 1 (- sf (- s 4)) 4))
          ((and throw (hss-anchored st)) (values 2 2 0 1))
          ((< sf end) (values 1 1 0 1))
          (throw (values 2 2 0 1))
          ((< (- sf end) 6) (values 1 0 (- sf end) 6))
          (t (values 0 0 0 1)))))

(defun-fast %hs-kaza-point (out pos fa sf)
  "OUT := the Shikai windmill's sickle grip at move frame SF (KAZAGURUMA S 6, A 60, R 14), its point R m out: let out low and
swung round (f0-6), the push at the waist 2.0 m round him (the volume's r: f6-9), lifted to circle flat above his head
1.6 m round, 2.3 m up (f10-16 on), one turn in 12 f (counter-clockwise from above); FA[0] := its bearing (the sickle drawn
pointing out, %HS-PLACE! spin 0). 0 B."
  (declare (type f32vec out pos fa) (fixnum sf))
  (let* ((f (i->f sf)) (k (f-clamp (/ (- f 9f0) 7f0) 0f0 1f0)) (e (* k k (- 3f0 (* 2f0 k))))
         (r (* (aref *hs-ks* 0) (if (< f 6f0) (+ 0.8f0 (* 1.2f0 (/ f 6f0))) (- 2.0f0 (* 0.4f0 e)))))   ; (S1: grows with the charge)
         (h (+ 0.95f0 (* 1.35f0 e))) (a (+ (aref fa 0) 1.5707964f0 (* 0.5235988f0 f))) (g (- r 0.75f0)))
    (declare (single-float f k e r h a g))
    (setf (aref fa 0) a
          (aref out 0) (+ (aref pos 0) (* g (- (f-sin a)))) (aref out 1) h (aref out 2) (+ (aref pos 2) (* g (- (f-cos a))))))
  nil)

(declaim (type f32vec *hs-g*))
(defvar *hs-g* (make-f32 4) "HISAGI-DRAW's readings (%HS-GEO!): [0] the opponent's distance, [1] how far ahead of him he is.")
(defun-fast %hs-geo! (an p q fa tr shikai rdt)
  "HISAGI-DRAW's float work (a plain DEFUN's arithmetic and float reads box): his facing (TR his transform) into FA[0] and
*HS-YAW*, FA[3] := SHIKAI (1 / 0), RDT (the draw's effect seconds) kept for the next pose (HS-POSE), his clip frame into
*HS-FR*, the opponent's distance and how far ahead he stands into *HS-G*, his chest (1.1 m up) into *HS-PT*;
the flags (a fixnum): 1 the right let-out is out, 2 the opponent 0.5-5.5 m ahead, 4 within 1.8 m, 8 the clip frame < 24,
16 within 2.1 m, 32 within the chain's *HS-CORE-CHAIN* (§27.6: 縛雷's bind drawn wound on him). 0 B."
  (declare (type f32vec p q fa) (fixnum shikai))
  (let* ((g *hs-g*) (pt *hs-pt*) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (yaw (the single-float (transform-yaw tr))))
    (declare (type f32vec g pt) (single-float dx dz yaw))
    (setf (aref fa 0) yaw (aref fa 3) (if (= shikai 1) 1f0 0f0)
          (aref *hs-grip-v* 2) (if (typep rdt 'single-float) (the single-float rdt) 0.0167f0)
          (aref *hs-fr* 0) (* 60f0 (the single-float (anim-time an))) (aref *hs-yaw* 0) yaw
          (aref g 0) (f-hypot dx dz) (aref g 1) (- (* dx (- (f-sin yaw))) (* dz (f-cos yaw)))
          (aref pt 0) (aref q 0) (aref pt 1) (+ (aref q 1) 1.1f0) (aref pt 2) (aref q 2))
    (logior (if (> (aref *hs-lo* 0) 0f0) 1 0) (if (< 0.5f0 (aref g 1) 5.5f0) 2 0) (if (< (aref g 0) 1.8f0) 4 0)
            (if (< (aref *hs-fr* 0) 24f0) 8 0) (if (< (aref g 0) 2.1f0) 16 0)
            (if (<= (aref g 0) (the single-float *hs-core-chain*)) 32 0))))
(defun-fast %hs-left-out-p () "The left let-out is out (*HS-LO* [8] > 0): 1 / 0. 0 B." (if (> (aref *hs-lo* 8) 0f0) 1 0))

(defun-fast %hs-hoden-burst (vjm age)
  "放電 HODEN's burst on the victim (§27.5, the user: 「使敵人原地炸開高額電擊傷害，且距離越近傷害越高」): AGE frames after its hit
(18 in all: a white flash 2, the grow 4, the hold 4, the erode 8; FX-ENVELOPE), at his chest (the joints VJM): a jade star,
eight jagged bolts out of him (three kinks each, a white core), ink flecks at their ends, a jade ring on the ground and a
jade light; sized by the distance factor (*HS-G* [0]: x0.8 at 6.5 m .. x1.4 at <= 1.6 m, as HS-HODEN-X's x1.0 .. x2.0;
the 餘電 part is used up by the hit, not drawn). Shapes hashed on the fx clock's drawings (no RNG). A look. 0 B."
  (declare (type f32vec vjm) (fixnum age))
  (let* ((p *hs-wd0*) (d (aref *hs-g* 0))
         (cc (the single-float *hs-core-chain*)) (nr (the single-float *hs-hoden-near*))
         (x (f-clamp (/ (- cc d) (- cc nr)) 0f0 1f0))
         (sc (+ 0.8f0 (* 0.6f0 x))) (dr (drawing-no 24f0)))
    (declare (type f32vec p) (single-float d cc nr x sc dr))
    (joint-point! p vjm (ji :chest) 0f0 0f0 0f0)
    (fx-envelope (s k fl ph) ((/ (i->f age) 60f0) 2 4 4 8)
      (when (< ph 5)
        (let* ((x0 (aref p 0)) (y0 (aref p 1)) (z0 (aref p 2)) (r (* s sc)))
          (declare (single-float x0 y0 z0 r))
          (when (> fl 0.5f0) (fx-disc x0 y0 z0 (* 0.5f0 r) 0.1f0 (+ 990f0 dr) +pal-hit+ 0.98f0))
          (fx-star x0 y0 z0 (* 0.2f0 r) (* 0.8f0 r) 9 dr 0f0 0f0 0.2f0 (+ 950f0 dr) +pal-jade+ k)
          (dotimes (i 8)
            (let* ((fi (i->f i)) (a (* 6.2831855f0 (+ (* 0.125f0 fi) (* 0.08f0 (hash01 fi dr)))))
                   (e (* 1.1f0 (- (hash01 (+ fi 3f0) dr) 0.5f0)))
                   (ux (* (f-cos e) (f-cos a))) (uy (f-sin e)) (uz (* (f-cos e) (f-sin a)))
                   (hl (f-max 0.01f0 (f-hypot ux uz))) (nx (/ (- uz) hl)) (nz (/ ux hl))
                   (px x0) (py y0) (pz z0))
              (declare (single-float fi a e ux uy uz hl nx nz px py pz))
              (dotimes (j 3)
                (let* ((rj (* r (+ 0.4f0 (* 0.36f0 (i->f j)))))
                       (sj (* r 0.09f0 (if (evenp j) 1f0 -1f0) (+ 0.5f0 (hash01 (+ fi (* 7f0 (i->f j))) dr))))
                       (qx (+ x0 (* rj ux) (* sj nx))) (qy (+ y0 (* rj uy))) (qz (+ z0 (* rj uz) (* sj nz)))
                       (ex (- qx px)) (ey (- qy py)) (ez (- qz pz)) (el (f-max 0.01f0 (f-hypot ex ey ez)))
                       (mx (* 0.5f0 (+ px qx))) (my (* 0.5f0 (+ py qy))) (mz (* 0.5f0 (+ pz qz))) (sd (+ 960f0 (* 3f0 fi) (i->f j) dr)))
                  (declare (single-float rj sj qx qy qz ex ey ez el mx my mz sd))
                  (fx-shard mx my mz (/ ex el) (/ ey el) (/ ez el) (* 1.15f0 el) 0.045f0 0.1f0 sd +pal-jade+ k :push 0.14f0)
                  (fx-shard mx my mz (/ ex el) (/ ey el) (/ ez el) el 0.014f0 0.06f0 (+ sd 40f0) +pal-hit+ k :push 0.18f0)
                  (setf px qx py qy pz qz)))
              (fx-shard px py pz ux uy uz (* 0.18f0 r) 0.03f0 0.2f0 (+ 1000f0 fi dr) +pal-ink+ k :push 0.12f0)))
          (joint-point! p vjm (ji :pelvis) 0f0 0f0 0f0)
          (%tring (aref p 0) 0f0 (aref p 2) (* 1.3f0 r) (* 0.05f0 sc) +pal-jade+ k (+ 970f0 dr))
          (%light x0 y0 z0 0.62f0 1f0 0.86f0 (* 4f0 sc) (* 3f0 k) 8)))))
  nil)

(defun-fast %hs-zan (vjm zan)
  "餘電 ZANDEN (§27.5, 「下一串連擊附帶電擊傷害」): ZAN frames of the residual charge left on the victim (HSS-ZAN, 480 at most):
seven crawling sparks on his body (the joints VJM: the chest, the upper and lower arms, the thighs), hopping to other
joints twelve times a second, some drawings dropped (the crackle), fading out over the last 60 frames. A look. 0 B."
  (declare (type f32vec vjm) (fixnum zan))
  (let* ((p *hs-wd0*) (k (* 0.95f0 (f-min 1f0 (/ (i->f zan) 60f0)))) (dr (drawing-no 12f0)) (dn (f->i dr)))
    (declare (type f32vec p) (single-float k dr) (fixnum dn))
    (dotimes (i 7)
      (let* ((fi (i->f i)) (h0 (hash01 fi dr)) (h1 (hash01 (+ fi 5f0) dr)) (h2 (hash01 (+ fi 9f0) dr))
             (j (case (mod (+ (* 3 i) dn) 7)
                  (0 (ji :chest)) (1 (ji :upper-arm-r)) (2 (ji :upper-arm-l)) (3 (ji :lower-arm-r)) (4 (ji :lower-arm-l))
                  (5 (ji :thigh-r)) (t (ji :thigh-l)))))
        (declare (single-float fi h0 h1 h2) (fixnum j))
        (when (> h2 0.2f0)
          (joint-point! p vjm j (* 0.16f0 (- h0 0.5f0)) (* -0.2f0 h1) (* 0.16f0 (- h1 0.5f0)))
          (let* ((a (* 6.2831855f0 h0)) (vx (* 0.8f0 (f-cos a))) (vy (* 0.6f0 (- (* 2f0 h2) 1f0))) (vz (* 0.8f0 (f-sin a)))
                 (ul (f-max 0.01f0 (f-hypot vx vy vz))) (ux (/ vx ul)) (uy (/ vy ul)) (uz (/ vz ul)))
            (declare (single-float a vx vy vz ul ux uy uz))
            (fx-shard (aref p 0) (aref p 1) (aref p 2) ux uy uz 0.27f0 0.045f0 0.12f0 (+ 1100f0 fi dr) +pal-jade+ k :push 0.22f0)
            (fx-shard (+ (aref p 0) (* 0.11f0 uz)) (+ (aref p 1) 0.07f0) (- (aref p 2) (* 0.11f0 ux)) (- uz) 0.3f0 ux 0.2f0
                      0.035f0 0.12f0 (+ 1110f0 fi dr) +pal-jade+ k :push 0.22f0)
            (fx-shard (aref p 0) (aref p 1) (aref p 2) ux uy uz 0.22f0 0.014f0 0.06f0 (+ 1120f0 fi dr) +pal-hit+ k :push 0.26f0))))))
  nil)

;;; §27.6 (presentation only; the user, 2026-10-28: 「NS3 的蓄電怎麼了會是投擲鐮刀出去，應該是要沿著綑綁的鎖鏈延伸電擊才對，放電也一樣是
;;; 沿著最初綑綁的鎖鏈炸開電擊」): the lightning along the binding chain
(declaim (type f32vec *hs-vt0* *hs-vt1* *hs-vt2* *hs-vt3*))
(defvar *hs-vt0* (make-f32 3) "%HS-VOLT's chain start: his left fist.")
(defvar *hs-vt1* (make-f32 3) "%HS-VOLT's chain end: the sickle wound on the victim (*HS-PT*, his chest).")
(defvar *hs-vt2* (make-f32 3) "%HS-VOLT's scratch point (a coil point, a fork's root).")
(defvar *hs-vt3* (make-f32 3) "%HS-VOLT's second scratch point (the next coil point, a fork's end).")
(defun-fast %hs-bolt-seg (p q k0 k1 seed wd k)
  "TSUZURI RAIDEN's jagged lightning (HS-CINE-BOLT's look: jade shards with a white core, jigged on the fx clock's drawings)
from K0 to K1 per cent of the segment P -> Q, WD per cent wide, presence K per cent, SEED its jig's phase (all fixnums:
a float argument boxes). A look. 0 B."
  (declare (type f32vec p q) (fixnum k0 k1 seed wd k))
  (when (> k1 k0)
    (let* ((dx (- (aref q 0) (aref p 0))) (dy (- (aref q 1) (aref p 1))) (dz (- (aref q 2) (aref p 2)))
           (l (f-max 0.01f0 (f-hypot dx dy dz))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
           (hl (f-max 0.01f0 (f-hypot ux uz))) (sx (/ uz hl)) (sz (/ (- ux) hl))
           (a0 (* 0.01f0 (i->f k0))) (a1 (* 0.01f0 (i->f k1))) (w (* 0.01f0 (i->f wd))) (kk (* 0.01f0 (i->f k)))
           (sd (i->f seed)) (n (max 1 (f->i (+ 0.999f0 (/ (* (- a1 a0) l) 0.3f0))))) (dr (drawing-no 24f0)))
      (declare (single-float dx dy dz l ux uy uz hl sx sz a0 a1 w kk sd dr) (fixnum n))
      (dotimes (i n)
        (let* ((fi (i->f i)) (s (* l (+ a0 (* (- a1 a0) (/ (+ fi 0.5f0) (i->f n))))))
               (j (* 0.09f0 w (f-sin (+ dr sd (* 2.3f0 fi))))) (jy (* 0.07f0 w (f-cos (+ (* 1.7f0 dr) sd (* 3.1f0 fi)))))
               (x (+ (aref p 0) (* s ux) (* j sx))) (y (+ (aref p 1) (* s uy) jy)) (z (+ (aref p 2) (* s uz) (* j sz))))
          (declare (single-float fi s j jy x y z))
          (fx-shard x y z ux uy uz 0.42f0 (* 0.05f0 w) 0.12f0 (+ fi 800f0 dr sd) +pal-jade+ kk :push 0.12f0)
          (fx-shard x y z ux uy uz 0.38f0 (* 0.016f0 w) 0.08f0 (+ fi 840f0 dr sd) +pal-hit+ kk :push 0.16f0)))))
  nil)
(defun-fast %hs-volt (jm vpos mode sf)
  "§27.6: pointer 3 縛雷's lightning along the binding chain, from his left fist (the joints JM) to the sickle wound on the
victim (*HS-PT*: his chest; VPOS his feet, the coil's centre as %HS-COIL's). MODE 1 CHIKUDEN at move frame SF (S 20): the
bolt's front runs down the chain f10-20 (a third of it lit behind the head, a jade star at the head), then the coil lights
on S (FX-ENVELOPE flash 1, grow 3, hold 4, erode 8: bolts along its three turns, a jade star and light on him); MODE 2
放電 HODEN (S 10): the chain lit end to end and flickering wider f2-9 (the charge), then the burst along it on S
(FX-ENVELOPE 2 4 4 8: the bolt at 2.2x width, a fork off it at seven points, alternately to each side, up to 0.6 m, a jade
light at its middle); %HS-HODEN-BURST adds the explosion on him on a hit. A look. 0 B."
  (declare (type f32vec jm vpos) (fixnum mode sf))
  (let ((a *hs-vt0*) (b *hs-vt1*) (p *hs-vt2*) (q *hs-vt3*) (dr (drawing-no 24f0)))
    (declare (type f32vec a b p q) (single-float dr))
    (joint-point! a jm (ji :weapon-l) 0f0 0f0 0f0)
    (replace b *hs-pt*)
    (if (= mode 1)
        (progn
          (when (and (<= 10 sf) (< sf 21))                              ; the front, down the chain
            (let* ((u (min 100 (* 10 (- sf 10)))) (fu (* 0.01f0 (i->f u))))
              (declare (fixnum u) (single-float fu))
              (%hs-bolt-seg a b (max 0 (- u 35)) u 0 100 95)
              (fx-star (+ (aref a 0) (* fu (- (aref b 0) (aref a 0)))) (+ (aref a 1) (* fu (- (aref b 1) (aref a 1))))
                       (+ (aref a 2) (* fu (- (aref b 2) (aref a 2)))) 0.06f0 0.26f0 7 dr 0f0 0f0 0.25f0 (+ 1200f0 dr)
                       +pal-jade+ 0.95f0)))
          (when (and (<= 20 sf) (< sf 36))                              ; the coil lit on S
            (fx-envelope (s k fl ph) ((/ (i->f (- sf 20)) 60f0) 1 3 4 8)
              (when (< ph 5)
                (let ((kk (f->i (* 100f0 k))))
                  (declare (fixnum kk))
                  (dotimes (ring 3)
                    (dotimes (i 4)
                      (let* ((h (+ 0.8f0 (* 0.25f0 (i->f ring)))) (i0 (* 2 i))
                             (a0 (* 0.7853982f0 (+ (i->f i0) (* 0.33f0 (i->f ring))))) (a1 (+ a0 0.7853982f0)))
                        (declare (single-float h a0 a1) (fixnum i0))
                        (setf (aref p 0) (+ (aref vpos 0) (* 0.42f0 (f-sin a0))) (aref p 1) (+ h (* 0.04f0 (i->f i0)))
                              (aref p 2) (+ (aref vpos 2) (* 0.42f0 (f-cos a0)))
                              (aref q 0) (+ (aref vpos 0) (* 0.42f0 (f-sin a1))) (aref q 1) (+ h (* 0.04f0 (i->f (1+ i0))))
                              (aref q 2) (+ (aref vpos 2) (* 0.42f0 (f-cos a1))))
                        (%hs-bolt-seg p q 0 100 (+ (* 5 ring) i) 80 kk))))
                  (fx-star (aref b 0) (aref b 1) (aref b 2) (* 0.1f0 s) (* 0.5f0 s) 9 dr 0f0 0f0 0.2f0 (+ 1210f0 dr) +pal-jade+ k)
                  (%light (aref b 0) (aref b 1) (aref b 2) 0.62f0 1f0 0.86f0 3f0 (* 2f0 k) 8))))))
        (progn
          (when (and (<= 2 sf) (< sf 10))                               ; the charge: the chain lit end to end
            (%hs-bolt-seg a b 0 100 7 (+ 40 (* 8 sf)) 90))
          (when (and (<= 10 sf) (< sf 28))                              ; the burst along it
            (fx-envelope (s k fl ph) ((/ (i->f (- sf 10)) 60f0) 2 4 4 8)
              (when (< ph 5)
                (let* ((kk (f->i (* 100f0 k)))
                       (dx (- (aref b 0) (aref a 0))) (dz (- (aref b 2) (aref a 2))) (hl (f-max 0.01f0 (f-hypot dx dz)))
                       (sx (/ dz hl)) (sz (/ (- dx) hl)))
                  (declare (fixnum kk) (single-float dx dz hl sx sz))
                  (%hs-bolt-seg a b 0 100 3 220 kk)
                  (dotimes (i 7)
                    (let* ((fi (i->f i)) (u (* 0.125f0 (+ fi 1f0))) (sg (if (evenp i) 1f0 -1f0))
                           (ln (* s (+ 0.3f0 (* 0.3f0 (hash01 fi dr))))) (up (* s 0.35f0 (- (hash01 (+ fi 5f0) dr) 0.3f0))))
                      (declare (single-float fi u sg ln up))
                      (dotimes (c 3) (setf (aref p c) (+ (aref a c) (* u (- (aref b c) (aref a c))))))
                      (setf (aref q 0) (+ (aref p 0) (* sg ln sx)) (aref q 1) (+ (aref p 1) up) (aref q 2) (+ (aref p 2) (* sg ln sz)))
                      (%hs-bolt-seg p q 0 100 (+ 11 (* 3 i)) 90 kk)))
                  (%light (* 0.5f0 (+ (aref a 0) (aref b 0))) (* 0.5f0 (+ (aref a 1) (aref b 1))) (* 0.5f0 (+ (aref a 2) (aref b 2)))
                          0.62f0 1f0 0.86f0 (* 4f0 s) (* 3f0 k) 8))))))))
  nil)

(declaim (type f32vec *hs-tsumuji-cut-y*))
(defparameter *hs-tsumuji-cut-y* (coerce (mapcar #'f32 '(0.15 -0.1 0.25 -0.05)) 'f32vec)
  "%HS-TSUMUJI-CUTS: each cut's height off the victim's centre (m), so the four read as separate passes.")
(defun-fast %hs-tsumuji-cuts (jm pos fa anchor vpos sf)
  "AS1 旋風 TSUMUJI's cuts (§27.10, a look): at move frame SF, for each of its four hits (f14 / 18 / 22 / 26) an 8 f flat
slash round the victim (FX-ENVELOPE 1 2 1 4) at HS-CORE-SEG's far end (%HS-POINT code 11, where the spinning sickle
sits): a 140 degree comet arc 0.7 m round him in the sickle's plane (flat, its far side tipped up 22 degrees as
%HS-PLACE! spin 5's; each a quarter turn on from the last, in the sickle's turning sense, at *HS-TSUMUJI-CUT-Y*), black ink with a white edge, a white star at its head on the flash.
JM / ANCHOR only for %HS-POINT. 0 B."
  (declare (type f32vec jm pos fa anchor vpos) (fixnum sf))
  (let ((c *hs-wd1*) (dr (drawing-no 24f0)))
    (declare (type f32vec c) (single-float dr))
    (when (and (<= 14 sf) (< sf 34))
      (%hs-point c 11 jm pos fa anchor vpos)
      (dotimes (i 4)
        (let ((age (- sf (+ 14 (* 4 i)))))
          (declare (fixnum age))
          (when (and (<= 0 age) (< age 8))
            (fx-envelope (s k fl ph) ((/ (i->f age) 60f0) 1 2 1 4)
              (when (< ph 5)
                (let* ((r (* 0.7f0 s)) (b0 (+ (* 1.5707964f0 (i->f i)) 2.0f0)) (b1 (+ b0 2.4434609f0)) (bm (* 0.5f0 (+ b0 b1)))
                       (a0 (+ (aref fa 0) b0)) (a1 (+ (aref fa 0) b1)) (am (+ (aref fa 0) bm)) (rc (* r 1.64f0))
                       (y (+ (aref c 1) (aref *hs-tsumuji-cut-y* i)))                 ; (tipped as the disc: the far
                       (y0 (+ y (* 0.404f0 r (f-cos b0)))) (y1 (+ y (* 0.404f0 r (f-cos b1))))   ;  side up 22 degrees)
                       (ym (+ y (* 0.404f0 rc (f-cos bm))))
                       (x0 (- (aref c 0) (* r (f-sin a0)))) (z0 (- (aref c 2) (* r (f-cos a0))))
                       (x1 (- (aref c 0) (* r (f-sin a1)))) (z1 (- (aref c 2) (* r (f-cos a1))))
                       (xm (- (aref c 0) (* rc (f-sin am)))) (zm (- (aref c 2) (* rc (f-cos am)))) (sd (+ 1300f0 (* 7f0 (i->f i)) dr)))
                  (declare (single-float r b0 b1 bm a0 a1 am rc y y0 y1 ym x0 z0 x1 z1 xm zm sd))
                  (fx-crescent x0 y0 z0 x1 y1 z1 xm ym zm (* 0.11f0 s) :comet 0.03f0 sd +pal-ink+ k :push 0.25f0)
                  (fx-crescent x0 y0 z0 x1 y1 z1 xm ym zm (* 0.04f0 s) :comet 0.02f0 (+ sd 3f0) +pal-hit+ k :push 0.3f0)
                  (when (> fl 0.5f0)
                    (fx-star x1 y1 z1 0.06f0 0.3f0 7 dr 0f0 0f0 0.25f0 (+ sd 5f0) +pal-hit+ 0.95f0))))))))))
  nil)

;;; ---------------------------------------------------------------- the Bankai 風死絞縄's look (DUEL_HISAGI §21.6)
;; Presentation only (motion-refs §4.3; `BBSHisagi_s_Bankai`, `Hisagi_s_Bankai_CFYOW`): both modes wear the Shikai's body
;; with his own chain coiled round the neck and the right upper arm and forearm (:HISAGI-BANKAI, a BODY-VARIANT: the same
;; rig and hurt cylinder), keep the Shikai's Kazeshini in both hands (the user, 2026-10-17: 「不是 卍解的刀造型跟始解一樣」),
;; and HISAGI-DRAW adds (%HS-ORB-DRAW) the jet-black orb of chains high overhead (out of the match camera's frame), a
;; curtain of chains hanging from it at his left and right down to waist-to-floor height, a bundle of four chains twisted
;; together from it down to his neck (and its slack tail), a pale light patch under it (canon's inverted shadow) and, in a
;; bind, the same bundle tied round the opponent's neck (the noose). The orb sits off to his right (the bundles lean off
;; the line between the two fighters from the behind camera): over his right shoulder in the ranged mode, over the pair's
;; midpoint in the bind. (The user, 2026-10-17: 「鎖鏈球可以高到超出鏡頭，自身周遭有許多從鎖鏈球垂下來的鎖鏈，其中有數條鎖鏈捆成束後捆在
;; 自己（與對手）的脖子上」.)
(defun hs-coil-parts (r y0 y1 turns n)
  "N chain links on a helix of radius R round the joint's up axis from Y0 to Y1 (TURNS turns), alternately flat on the
coil and edge-on, every fourth a steel glint: shape specs for BODY-VARIANT."
  (loop for i below n
        for u = (/ (+ i 0.5) n) for a = (* 2 pi turns u) for flat = (evenp i)
        collect (list :box 0.034 (if flat 0.02 0.007) (if flat 0.007 0.018)
                      :at (list (* r (sin a)) (+ y0 (* u (- y1 y0))) (* r (cos a)))
                      :rot (list (- (* (/ 180 pi) a)) 0 0) :c (if (zerop (mod i 4)) :link :chain))))

(body-variant :hisagi-bankai :hisagi
  :palette '((:chain #x1A1A20) (:link #x5A5A66))
  :parts (list (cons :neck (hs-coil-parts 0.062 0.0 0.125 3 33))
               (cons :upper-arm-r (hs-coil-parts 0.066 -0.04 -0.27 3.5 40))
               (cons :lower-arm-r (hs-coil-parts 0.057 -0.02 -0.235 4 40))))

(defun hs-mb-orb (mb)
  "The orb (motion-refs §4.3: \"a jet-black orb made of chains\"): a black core 0.8 m round wound with eleven loops of
chain 0.84-0.92 m round in planes tilted the golden angle apart (a tangle), 28 links a loop, alternately flat and
edge-on, every third a steel glint."
  (mbc mb #x09090C)
  (mb-sphere mb 0.8 :segments 16 :rings 12)
  (dotimes (k 11)
    (let ((r (+ 0.84 (* 0.008 (mod (* k 7) 11)))))
      (mb-at (mb :yaw (* k 2.39996) :pitch (acos (- 1 (/ (* 2 (+ k 0.5)) 11))))
        (dotimes (i 28)
          (mbc mb (if (zerop (mod i 3)) #x3C3C46 #x16161C))
          (mb-at (mb :yaw (* 2 pi (/ i 28)))
            (mb-at (mb :z r)
              (mb-box mb 0.1 (if (evenp i) 0.05 0.018) (if (evenp i) 0.018 0.045)))))))))

(defweapon :hs-orb (:length 0.9)
  (:solid (hs-mb-orb mb)))

(declaim (type f32vec *hs-orb-v* *hs-om* *hs-oc* *hs-b0* *hs-b1*))
(defvar *hs-orb-v* (make-f32 8)
  "Each side's orb centre as last drawn ([0-2] P1's, [3-5] P2's) and [6-7] whether it has one (1: eased from there).")
(defvar *hs-om* (m4) "The orb's world matrix.")
(defvar *hs-oc* (make-f32 3) "The orb's centre this frame.")
(defvar *hs-b0* (make-f32 3) "A bundle segment's near end (%HS-BUNDLE).")
(defvar *hs-b1* (make-f32 3) "A bundle segment's far end (%HS-BUNDLE).")
(declaim (type f32vec *hs-cl*))
(defvar *hs-cl* (make-f32 5)
  "The B5 cinematics' hold on the orb's look (DUEL_HISAGI §22.7; HISAGI-DRAW fills it every call, %HS-CINE-LOOK! inside his
own cinematics): [0] the orb's growth 0-1 (its size, the light patch), [1] the curtain's drop 0-1 (each hanging chain's
length from the orb), [2] the neck bundle's descent 0-1 (below 1 it hangs that share of the way down, untied, no tail),
[3] metres added to the orb's height, [4] 1: the orb placed at once (no easing). The match: 1 1 1 0 0.")
(defparameter *hs-orb-scale* 1.7
  "The orb's drawn size: its mesh (a 0.8 m core, chain loops to ~0.95 m) x 1.7, so ~1.6 m round (Brave Souls draws it
larger than him; DUEL_HISAGI §21.6: the lead's proposal, 2026-10-17; canon gives no size).")
(defparameter *hs-orb-h* 8.0
  "The orb's centre height (m), both modes: overhead and out of the 2 m / 6 m behind camera's frame (the user, 2026-10-17:
「鎖鏈球可以高到超出鏡頭」); its chains come down into the frame.")
(defparameter *hs-orb-side* 1.5 "How far to his right the orb hangs (m), both modes: the neck bundles lean off the line
between the fighters from the behind camera.")
(defparameter *hs-orb-back* 0.5 "How far behind him the orb hangs in the ranged mode (m); a bind puts it over the midpoint.")
(defparameter *hs-curtain*
  '((70.0 1.5 0.95) (100.0 1.7 0.45) (125.0 1.45 0.75) (150.0 1.65 0.3) (210.0 1.6 0.6) (235.0 1.45 0.9) (260.0 1.7 0.35)
    (290.0 1.5 0.8))
  "The chains hanging from the orb round him (the user, 2026-10-17: 「自身周遭有許多從鎖鏈球垂下來的鎖鏈」; 「攻擊可以從周遭垂下來的鎖鏈
或自己頸部的鎖鏈發動」): (bearing in degrees from his facing, counter-clockwise from above; distance from his feet, m; the
free end's height, m). Two curtains, at his left and his right: none ahead (the opponent) and none behind (the behind
camera's line), every end 1.45-1.7 m from him at 0.3-0.95 m up (waist to floor: a clip can snap one out level).")
(declaim (type f32vec *hs-curtain-v*))
(defvar *hs-curtain-v* (coerce (mapcar #'f32 (apply #'append *hs-curtain*)) 'f32vec) "*HS-CURTAIN* flat, as floats.")

(defun-fast %hs-bundle (top bot n tw r0 r1)
  "N chains twisted round each other from TOP down to BOT (f32vecs): a helix of TW turns, its radius R0 at the bottom
(tight round a neck) to R1 at the top (fanning out under the orb, growing as u^3), 14 straight pieces a chain, each drawn
by VFX-HS-CHAIN (R0 R1 TW: f32vec-free single floats, literals at the call). 0 B."
  (declare (type f32vec top bot) (fixnum n) (single-float tw r0 r1))
  (let* ((p *hs-b0*) (q *hs-b1*)
         (dx (- (aref top 0) (aref bot 0))) (dy (- (aref top 1) (aref bot 1))) (dz (- (aref top 2) (aref bot 2)))
         (l (f-max 0.1f0 (f-hypot dx dy dz))) (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l))
         (hl (f-hypot ux uz)) (ax (if (> hl 0.01f0) (/ uz hl) 1f0)) (az (if (> hl 0.01f0) (/ (- ux) hl) 0f0))
         (bx (* uy az)) (by (- (* uz ax) (* ux az))) (bz (- (* uy ax))))      ; (A horizontal, B = U x A)
    (declare (type f32vec p q) (single-float dx dy dz l ux uy uz hl ax az bx by bz))
    (dotimes (c n)
      (dotimes (i 15)
        (let* ((u (/ (i->f i) 14f0)) (ph (+ (* 6.2831855f0 tw u) (/ (* 6.2831855f0 (i->f c)) (i->f n))))
               (r (+ r0 (* (- r1 r0) u u u))) (cp (* r (f-cos ph))) (sp (* r (f-sin ph))))
          (declare (single-float u ph r cp sp))
          (setf (aref q 0) (+ (aref bot 0) (* u dx) (* cp ax) (* sp bx))
                (aref q 1) (+ (aref bot 1) (* u dy) (* sp by))
                (aref q 2) (+ (aref bot 2) (* u dz) (* cp az) (* sp bz)))
          (when (> i 0) (vfx-hs-chain p q 0f0 0.9f0))
          (replace p q)))))
  nil)

(defun-fast %hs-tie (top jm)
  "A neck bundle (§21.6): four chains twisted together (%HS-BUNDLE) from TOP (an f32vec: the orb's bottom) down to a knot
0.24 m above and 0.2 m behind the neck joint of the joints JM (clear of the head), then each of the four from the knot to
one side of the neck (the noose's tie). Uses *HS-W* and *HS-Q*. 0 B."
  (declare (type f32vec top jm))
  (let ((w *hs-w*) (q *hs-q*))
    (declare (type f32vec w q))
    (joint-point! w jm (ji :neck) 0f0 0.24f0 0.2f0)
    (%hs-bundle top w 4 3.0f0 0.05f0 0.45f0)
    (joint-point! q jm (ji :neck) 0.075f0 0.07f0 0f0) (vfx-hs-chain w q 0.03f0 0.9f0)
    (joint-point! q jm (ji :neck) -0.075f0 0.07f0 0f0) (vfx-hs-chain w q 0.03f0 0.9f0)
    (joint-point! q jm (ji :neck) 0f0 0.07f0 0.075f0) (vfx-hs-chain w q 0.02f0 0.9f0)
    (joint-point! q jm (ji :neck) 0f0 0.07f0 -0.075f0) (vfx-hs-chain w q 0.03f0 0.9f0)))

(declaim (type f32vec *hs-e* *hs-kn* *hs-mid* *hs-tipv*))
(defvar *hs-e* (make-f32 3) "A Bankai chain strike's free end (%HS-BK-STRIKE).")
(defvar *hs-kn* (make-f32 3) "A Bankai chain strike's top, then its knee (%HS-BK-STRIKE).")
(defvar *hs-mid* (make-f32 3) "%HS-CHAIN2's midpoint.")
(defvar *hs-tipv* (make-f32 2)
  "The last Bankai draw's farthest chain-strike free end on its strike / hold frames: [0] its distance from his feet, [1]
how far along his facing (m; HISAGI-DRAW zeroes it; the tip table, debug 83902).")
(defun-fast %hs-chain2 (a b)
  "A taut chain from A to B (f32vecs), in two pieces past 5 m (VFX-HS-CHAIN's 48 links span ~5.8 m). 0 B."
  (declare (type f32vec a b))
  (let ((m *hs-mid*))
    (declare (type f32vec m))
    (if (> (f-hypot (- (aref b 0) (aref a 0)) (- (aref b 1) (aref a 1)) (- (aref b 2) (aref a 2))) 5f0)
        (progn (dotimes (i 3) (setf (aref m i) (* 0.5f0 (+ (aref a i) (aref b i)))))
               (vfx-hs-chain a m 0f0 0.9f0) (vfx-hs-chain m b 0f0 0.9f0))
        (vfx-hs-chain a b 0f0 0.9f0)))
  nil)

(defun-fast %hs-bk-mask (ks)
  "The hanging chains (bits 0-7) and the neck bundle's tail (bit 8) the chain strikes KS use at the clip frame *HS-FR*. 0 B."
  (let ((mask 0) (f (aref *hs-fr* 0)))
    (declare (fixnum mask) (single-float f))
    (dolist (x ks mask)
      (let ((kv x))
        (declare (type f32vec kv))
        (when (and (>= f (aref kv 1)) (< f (aref kv 5))) (setf mask (logior mask (ash 1 (f->i (aref kv 0))))))))))

;;; The carousel, the lashes, the bundle (batch A2, DUEL_HISAGI §24.2; a look, 0 B a frame)
(declaim (type f32vec *hs-car* *hs-cz* *hs-lt* *hs-lt2* *hs-rp* *hs-fr2* *hs-bundle-rest-v*))
(defvar *hs-car* (make-f32 10)
  "The carousel (§22.1's 旋鎖陣): [0-1] each side's orb phase (rad), [2-3] each side's last jerk (%HS-CAR!), [4-5] each
side's bundle weight, [6] this draw's phase (the orb's turn, the hanging chains' bearing), [7] this draw's bundle weight
(0 the eight hanging chains apart .. 1 bound into one bundle), [8] the orb's underside height this draw.")
(defvar *hs-car-clip* (make-array 2 :initial-element nil)
  "Each side's clip at the last draw: a strike's jerk is banked into the phase when the clip changes (no jump when a link
cuts it short).")
(defvar *hs-cz* (make-f32 (* 9 14))
  "Each chain's cubic this draw (%HS-CURVE!): the eight hanging chains then the bundle (8), each p0 p1 p2 p3 (12 floats),
its taper (its lash weight) and its width x.")
(defvar *hs-lt* (make-f32 8) "%HS-LASH-TIP!'s end: [0-2] the free end (world), [3] the bend, [4] the lash weight, [5] r, [6] az.")
(defvar *hs-lt2* (make-f32 8) "%HS-LASH-TIP!'s end at an earlier frame (the lag, the trail).")
(defvar *hs-rp* (make-f32 4) "%HS-REST-POLAR!: [0] r, [1] h, [2] az (degrees off his facing), [3] the sway (m).")
(defvar *hs-fr2* (make-f32 1) "An earlier clip frame for %HS-LASH-TIP!.")
(defvar *hs-bundle-rest-v* (coerce (mapcar #'f32 *hs-bundle-rest*) 'f32vec) "*HS-BUNDLE-REST* as floats.")
(defmacro %hs-wrap180 (x)
  "X (degrees) into -180 .. 180."
  `(let ((%a ,x)) (declare (single-float %a))
     (loop while (> %a 180f0) do (decf %a 360f0))
     (loop while (< %a -180f0) do (incf %a 360f0))
     %a))

(defun-fast %hs-car! (an side sv bv)
  "The carousel for the fighter on SIDE (0 / 1) at his clip frame *HS-FR* (AN his anim): the orb's phase turned *HS-CAR-W*
x the draw's effect seconds plus his strike clip's jerk (SV its *HS-SPINS-V* f32vec or NIL: TURNS turns, eased in from F0,
fastest at F1, out by F2; banked into the phase when his clip changes) -> *HS-CAR* [6]; the bundle weight (BV its
*HS-BUNDLED-V* ramp or NIL; coming apart at 4 /s out of it, at once on a still) -> [7]. 0 B."
  (declare (fixnum side))
  (let* ((cv *hs-car*) (f (aref *hs-fr* 0)) (dt (aref *hs-grip-v* 2)) (c (anim-clip an)) (cc *hs-car-clip*)
         (off 0f0) (tb 0f0))
    (declare (type f32vec cv) (type simple-vector cc) (single-float f dt off tb))
    (when sv
      (let* ((v sv) (f0 (aref v 0)) (f1 (aref v 1)) (f2 (aref v 2))
             (e (cond ((<= f f0) 0f0)
                      ((< f f1) (let ((x (/ (- f f0) (f-max 1f0 (- f1 f0))))) (declare (single-float x)) (* 0.35f0 x x)))
                      ((< f f2) (let ((y (- 1f0 (/ (- f f1) (f-max 1f0 (- f2 f1)))))) (declare (single-float y))
                                  (- 1f0 (* 0.65f0 y y))))
                      (t 1f0))))
        (declare (type f32vec v) (single-float f0 f1 f2 e))
        (setf off (* 6.2831855f0 (aref v 3) e))))
    (when bv
      (let ((v bv)) (declare (type f32vec v))
        (setf tb (f-clamp (/ (- f (aref v 0)) (f-max 0.5f0 (- (aref v 1) (aref v 0)))) 0f0 1f0))))
    (unless (eq c (svref cc side))
      (setf (aref cv side) (+ (aref cv side) (aref cv (+ 2 side))) (svref cc side) c))
    (setf (aref cv side) (f-mod (+ (aref cv side) (* (the single-float *hs-car-w*) (f-max 0f0 dt))) 6.2831855f0)
          (aref cv (+ 2 side)) off
          (aref cv 6) (+ (aref cv side) off)
          (aref cv (+ 4 side)) (if (> dt 0f0) (f-max tb (- (aref cv (+ 4 side)) (* 4f0 dt))) tb)
          (aref cv 7) (aref cv (+ 4 side))))
  nil)

(defun-fast %hs-rest-polar! (rp j)
  "RP := hanging chain J's rest (0-7: *HS-CURTAIN* turned by the carousel's phase *HS-CAR* [6], lifted 2.4 m and drawn in
where it passes ahead of him or behind him, so that none hangs between the fighters or before the behind camera; §21.6)
or the bundle's (8: *HS-BUNDLE-REST*, swaying): [0] r, [1] h, [2] az (degrees off his facing), [3] its sway (m). 0 B."
  (declare (type f32vec rp) (fixnum j))
  (let ((tm (fx-clock)))
    (declare (single-float tm))
    (if (< j 8)
        (let* ((cv *hs-curtain-v*) (b (aref cv (* 3 j))) (az (+ b (* 57.29578f0 (aref *hs-car* 6))))
               (s (f-abs (f-sin (* 0.017453292f0 az))))
               (x (f-clamp (/ (- s 0.3f0) 0.4f0) 0f0 1f0)) (wf (- 1f0 (* x x (- 3f0 (* 2f0 x))))))
          (declare (type f32vec cv) (single-float b az s x wf))
          (setf (aref rp 0) (* (aref cv (+ 1 (* 3 j))) (- 1f0 (* 0.35f0 wf)))
                (aref rp 1) (+ (aref cv (+ 2 (* 3 j))) (* 2.4f0 wf))
                (aref rp 2) az
                (aref rp 3) (* 0.05f0 (f-sin (+ (* 1.1f0 tm) b)))))
        (let ((br *hs-bundle-rest-v*))
          (declare (type f32vec br))
          (setf (aref rp 0) (aref br 1) (aref rp 1) (aref br 2) (aref rp 2) (+ (aref br 0) (* 4f0 (f-sin (* 0.7f0 tm))))
                (aref rp 3) 0f0))))
  nil)

(defun-fast %hs-lash-of (lk j)
  "The *HS-LASHES-V* entry of LK (his clip's) that moves chain J (0-7, 8 the bundle) at the clip frame *HS-FR*, or NIL."
  (declare (fixnum j))
  (let ((f (aref *hs-fr* 0)) (out nil))
    (declare (single-float f))
    (dolist (x lk out)
      (let ((kv x))
        (declare (type f32vec kv))
        (when (and (null out) (logbitp j (f->i (aref kv 0))) (>= f (aref kv 3)) (< f (aref kv 4))) (setf out kv))))))

(defun-fast %hs-lash-tip! (out kv fr rank j pos fa)
  "OUT := the free end of chain J (rank RANK in the entry KV, *HS-LASHES-V*) at the clip frame FR[0] less RANK x its
stagger: the keys' r h az bend (eased between keys 4 f or more apart, linear nearer, az the short way round), blended
from its rest (%HS-REST-POLAR!) before the first key and back to it after the last: [0-2] the end (world, from his feet
POS along FA[0] his facing), [3] the bend, [4] the lash weight (0 at rest .. 1 on the keys), [5] r, [6] az (deg). 0 B."
  (declare (type f32vec out kv fr pos fa) (fixnum rank j))
  (let* ((rk (i->f rank)) (f (- (aref fr 0) (* rk (aref kv 1))))
         (fs (aref kv 3)) (fe (aref kv 4)) (n (f->i (aref kv 5))) (kl (+ 6 (* 6 (1- n))))
         (rp *hs-rp*) (r 0f0) (h 0f0) (az 0f0) (bd 0f0) (lw 1f0))
    (declare (single-float rk f fs fe r h az bd lw) (fixnum n kl) (type f32vec rp))
    (%hs-rest-polar! rp j)
    (cond ((< f (aref kv 6))                                           ; from rest to the first key
           (let* ((x (f-clamp (/ (- f fs) (f-max 1f0 (- (aref kv 6) fs))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x))))
                  (a1 (+ (aref kv 9) (* rk (aref kv 10)))))
             (declare (single-float x u a1))
             (setf r (+ (aref rp 0) (* u (- (aref kv 7) (aref rp 0)))) h (+ (aref rp 1) (* u (- (aref kv 8) (aref rp 1))))
                   az (+ (aref rp 2) (* u (%hs-wrap180 (- a1 (aref rp 2))))) bd (* u (aref kv 11)) lw u)))
          ((>= f (aref kv kl))                                         ; from the last key back to rest
           (let* ((x (f-clamp (/ (- f (aref kv kl)) (f-max 1f0 (- fe (aref kv kl)))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x))))
                  (a1 (+ (aref kv (+ kl 3)) (* rk (aref kv (+ kl 4))))))
             (declare (single-float x u a1))
             (setf r (+ (aref kv (+ kl 1)) (* u (- (aref rp 0) (aref kv (+ kl 1)))))
                   h (+ (aref kv (+ kl 2)) (* u (- (aref rp 1) (aref kv (+ kl 2)))))
                   az (+ a1 (* u (%hs-wrap180 (- (aref rp 2) a1)))) bd (* (- 1f0 u) (aref kv (+ kl 5))) lw (- 1f0 u))))
          (t (let ((i 6))                                               ; between two keys
               (declare (fixnum i))
               (loop while (and (< (+ i 6) kl) (>= f (aref kv (+ i 6)))) do (incf i 6))
               (let* ((f0 (aref kv i)) (f1 (aref kv (+ i 6))) (x (/ (- f f0) (f-max 0.001f0 (- f1 f0))))
                      (u (if (>= (- f1 f0) 4f0) (* x x (- 3f0 (* 2f0 x))) x))
                      (a0 (+ (aref kv (+ i 3)) (* rk (aref kv (+ i 4))))) (a1 (+ (aref kv (+ i 9)) (* rk (aref kv (+ i 10))))))
                 (declare (single-float f0 f1 x u a0 a1))
                 (setf r (+ (aref kv (+ i 1)) (* u (- (aref kv (+ i 7)) (aref kv (+ i 1)))))
                       h (+ (aref kv (+ i 2)) (* u (- (aref kv (+ i 8)) (aref kv (+ i 2)))))
                       az (+ a0 (* u (%hs-wrap180 (- a1 a0))))
                       bd (+ (aref kv (+ i 5)) (* u (- (aref kv (+ i 11)) (aref kv (+ i 5)))))
                       lw 1f0)))))
    (setf r (%hs-lk-r r))                                              ; (§25.13: a route link's to the victim)
    (let ((a (+ (aref fa 0) (* 0.017453292f0 az))))
      (declare (single-float a))
      (setf (aref out 0) (+ (aref pos 0) (* r (- (f-sin a)))) (aref out 1) h (aref out 2) (+ (aref pos 2) (* r (- (f-cos a))))
            (aref out 3) bd (aref out 4) lw (aref out 5) r (aref out 6) az)))
  nil)

(defparameter *hs-flow-period* 1.0
  "Seconds the K tip's flow takes down a hanging chain (§25.27, the user, 2026-10-23: 「幫我將 K 添加白色流光流過鎖鏈作為提示
（p2 則是黑色流光）」; 0.7 the lead's number; 0.7 -> 1.0 the same day, §25.33: 「流光的落下速度跟頻率都改成 1s 看看」).")
(defparameter *hs-flow-every* 1.0
  "Seconds between one chain's flows (§25.28: it runs *HS-FLOW-PERIOD*, then the chain rests; 0.7, back to back, until the
user, 2026-10-23: 「降低流光的頻率」; 1.8 the lead's number; 1.8 -> 1.0 the same day, §25.29: 「流光改成 1 秒」; 1.0 -> 0.7,
§25.31: 「流光改回 0.7s」: back to back again, as §25.27; 0.7 -> 1.0 with the run, §25.33: still back to back).")
(declaim (type f32vec *hs-tg*))
(defvar *hs-tg* (make-f32 1)
  "The chain-tip cue this draw (DUEL_HISAGI §25.26-§25.28; HISAGI-DRAW sets it): 0 none, 1 the opponent on K1's tip (the
flow down the hanging chains), 2 on J1's (the hanging chains' free ends glint; the right crescent's glint gone since
§25.28).")
(defun-fast %hs-curve! (cz o tp e e2 pos)
  "CZ[O..O+11] := a chain's cubic from TP (its top under the orb) to E (its free end, as *HS-LT*: [3] the bend, [4] the
lash weight): at rest a straight line; lashing (weight 1) down from the orb past a knee near him (0.3 of the way out, 0.9 m
over its height, lower by a negative bend), then out to the end, its middle lifted by the bend and dragged back toward E2 (the end two frames
earlier: the lag, at most 1.8 m), no point under the floor; CZ[O+12] := the lash weight (its taper). 0 B."
  (declare (type f32vec cz tp e e2 pos) (fixnum o))
  (let* ((lw (aref e 4)) (ex (aref e 0)) (ey (aref e 1)) (ez (aref e 2)) (tx (aref tp 0)) (ty (aref tp 1)) (tz (aref tp 2))
         (lx (* 0.45f0 (- (aref e2 0) ex))) (ly (* 0.45f0 (- (aref e2 1) ey))) (lz (* 0.45f0 (- (aref e2 2) ez)))
         (ll (f-hypot lx ly lz)) (lk (if (> ll 1.8f0) (/ 1.8f0 ll) 1f0))
         (kx (+ (aref pos 0) (* 0.3f0 (- ex (aref pos 0))))) (kz (+ (aref pos 2) (* 0.3f0 (- ez (aref pos 2)))))
         (ky (f-max 1.3f0 (+ ey 0.5f0)))
         (s1x (+ tx (* 0.333f0 (- ex tx)))) (s1y (+ ty (* 0.333f0 (- ey ty)))) (s1z (+ tz (* 0.333f0 (- ez tz))))
         (s2x (+ tx (* 0.667f0 (- ex tx)))) (s2y (+ ty (* 0.667f0 (- ey ty)))) (s2z (+ tz (* 0.667f0 (- ez tz))))
         (q2x (+ (* 0.5f0 (+ kx ex)) (* lk lx))) (q2y (+ (* 0.5f0 (+ ky ey)) (aref e 3) (* lk ly)))
         (q2z (+ (* 0.5f0 (+ kz ez)) (* lk lz))))
    (declare (single-float lw ex ey ez tx ty tz lx ly lz ll lk kx kz ky s1x s1y s1z s2x s2y s2z q2x q2y q2z))
    (setf (aref cz o) tx (aref cz (+ o 1)) ty (aref cz (+ o 2)) tz
          (aref cz (+ o 3)) (+ s1x (* lw (- kx s1x)))                   ; (a chain laid on the floor: its knee lower)
          (aref cz (+ o 4)) (f-max 0f0 (+ s1y (* lw (- (+ ky 0.9f0 (f-min 0f0 (aref e 3))) s1y))))
          (aref cz (+ o 5)) (+ s1z (* lw (- kz s1z)))
          (aref cz (+ o 6)) (+ s2x (* lw (- q2x s2x))) (aref cz (+ o 7)) (f-max 0f0 (+ s2y (* lw (- q2y s2y))))
          (aref cz (+ o 8)) (+ s2z (* lw (- q2z s2z)))
          (aref cz (+ o 9)) ex (aref cz (+ o 10)) ey (aref cz (+ o 11)) ez
          (aref cz (+ o 12)) lw))
  nil)

(defun-fast %hs-cubic-chain (cz o j)
  "Draw hanging chain J's cubic CZ[O..] (%HS-CURVE!) link by link in black (%HS-BLACK-KITE), tapered toward its free end
by its lash weight, its width x CZ[O+13]; with the bundle weight *HS-CAR* [7] it is drawn that far onto the bundle's
cubic (CZ[112..]: the eight twisted round it, 4 turns, tight below, fanning out under the orb). On K1's tip (*HS-TG* 1,
§25.27) a resting chain carries the flow: a streak of light running down it from 0.35 of its length to its end in
*HS-FLOW-PERIOD* s, once every *HS-FLOW-EVERY* s (each chain its own phase), white on P1's black links, solid black on P2's ink ones (x1.5 wide: the ink links are lighter and wider). 0 B."
  (declare (type f32vec cz) (fixnum o j))
  (let* ((bw (aref *hs-car* 7)) (ob 112) (cw (- 1f0 bw))
         (len (+ (* cw (+ (f-hypot (- (aref cz (+ o 3)) (aref cz o)) (- (aref cz (+ o 4)) (aref cz (+ o 1))) (- (aref cz (+ o 5)) (aref cz (+ o 2))))
                          (f-hypot (- (aref cz (+ o 6)) (aref cz (+ o 3))) (- (aref cz (+ o 7)) (aref cz (+ o 4))) (- (aref cz (+ o 8)) (aref cz (+ o 5))))
                          (f-hypot (- (aref cz (+ o 9)) (aref cz (+ o 6))) (- (aref cz (+ o 10)) (aref cz (+ o 7))) (- (aref cz (+ o 11)) (aref cz (+ o 8))))))
                 (* bw (+ (f-hypot (- (aref cz (+ ob 3)) (aref cz ob)) (- (aref cz (+ ob 4)) (aref cz (+ ob 1))) (- (aref cz (+ ob 5)) (aref cz (+ ob 2))))
                          (f-hypot (- (aref cz (+ ob 6)) (aref cz (+ ob 3))) (- (aref cz (+ ob 7)) (aref cz (+ ob 4))) (- (aref cz (+ ob 8)) (aref cz (+ ob 5))))
                          (f-hypot (- (aref cz (+ ob 9)) (aref cz (+ ob 6))) (- (aref cz (+ ob 10)) (aref cz (+ ob 7))) (- (aref cz (+ ob 11)) (aref cz (+ ob 8))))))))
         (n (min 120 (max 2 (f->i (/ len 0.12f0)))))
         (tp (+ (* cw (aref cz (+ o 12))) (* bw (aref cz (+ ob 12))))) (wx (aref cz (+ o 13))) (jp (* 0.7853982f0 (i->f j)))
         (flow (and (= (aref *hs-tg* 0) 1f0) (or (and (< tp 0.01f0) (< bw 0.01f0)) (> bw 0.99f0))))   ; (§28.11: or down
                                                                        ;  the bundle, bound in the 聚 stance)
         (pu (+ 0.35f0 (* 0.65f0 (/ (* (the single-float *hs-flow-every*)
                                         (f-mod (+ (/ (fx-clock) (the single-float *hs-flow-every*)) (* 0.37f0 (i->f j))) 1f0))
                                      (the single-float *hs-flow-period*))))))   ; (past 1: resting till its next)
    (declare (single-float bw cw len tp wx jp pu) (fixnum ob n))
    (dotimes (i n)
      (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (v (- 1f0 u))
             (a (* v v v)) (b (* 3f0 v v u)) (c (* 3f0 v u u)) (d (* u u u))
             (da (* 3f0 v v)) (db (* 6f0 v u)) (dc (* 3f0 u u)))
        (declare (single-float u v a b c d da db dc))
        (macrolet ((bz (o k) `(+ (* a (aref cz (+ ,o ,k))) (* b (aref cz (+ ,o 3 ,k))) (* c (aref cz (+ ,o 6 ,k)))
                                 (* d (aref cz (+ ,o 9 ,k)))))
                   (bt (o k) `(+ (* da (- (aref cz (+ ,o 3 ,k)) (aref cz (+ ,o ,k))))
                                 (* db (- (aref cz (+ ,o 6 ,k)) (aref cz (+ ,o 3 ,k))))
                                 (* dc (- (aref cz (+ ,o 9 ,k)) (aref cz (+ ,o 6 ,k)))))))
          (let* ((px (bz o 0)) (py (bz o 1)) (pz (bz o 2)) (tx (bt o 0)) (ty (bt o 1)) (tz (bt o 2)))
            (declare (single-float px py pz tx ty tz))
            (when (> bw 0.001f0)                                           ; onto the bundle, twisted round it
              (let* ((bx (bz ob 0)) (by (bz ob 1)) (bzz (bz ob 2)) (gx (bt ob 0)) (gy (bt ob 1)) (gz (bt ob 2))
                     (gl (f-max 1f-4 (f-hypot gx gy gz))) (hl (f-hypot gx gz))
                     (n1x (if (> hl 1f-3) (/ (- gz) hl) 1f0)) (n1z (if (> hl 1f-3) (/ gx hl) 0f0))
                     (n2x (/ (* gy n1z) gl)) (n2y (/ (- (* gz n1x) (* gx n1z)) gl)) (n2z (/ (- (* gy n1x)) gl))
                     (rr (+ 0.05f0 (* 0.45f0 v v v v))) (ph (+ (* 25.132741f0 u) jp))
                     (ox (* rr (+ (* (f-cos ph) n1x) (* (f-sin ph) n2x)))) (oy (* rr (f-sin ph) n2y))
                     (oz (* rr (+ (* (f-cos ph) n1z) (* (f-sin ph) n2z)))))
                (declare (single-float bx by bzz gx gy gz gl hl n1x n1z n2x n2y n2z rr ph ox oy oz))
                (setf px (+ (* cw px) (* bw (+ bx ox))) py (+ (* cw py) (* bw (+ by oy))) pz (+ (* cw pz) (* bw (+ bzz oz)))
                      tx (+ (* cw tx) (* bw gx)) ty (+ (* cw ty) (* bw gy)) tz (+ (* cw tz) (* bw gz)))))
            (let ((tl (f-max 1f-4 (f-hypot tx ty tz))))
              (declare (single-float tl))
              (%hs-black-kite px (f-max 0.03f0 py) pz (/ tx tl) (/ ty tl) (/ tz tl) 0.13f0
                              (* (if (evenp i) 0.028f0 0.013f0) wx (- 1f0 (* 0.55f0 tp u))))
              (when flow                                                   ; (§25.27: the flow, K1's tip)
                (let ((dd (f-abs (- u pu))))
                  (declare (single-float dd))
                  (when (< dd 0.07f0)
                    (let ((fw (* 0.045f0 (- 1f0 (/ dd 0.07f0)))))
                      (declare (single-float fw))
                      (if (= *hs-chain-ink* 1)
                          (progn (setf *hs-chain-ink* 0)
                                 (%hs-black-kite px (f-max 0.03f0 py) pz (/ tx tl) (/ ty tl) (/ tz tl) 0.18f0 (* 1.5f0 fw) 0.14f0)
                                 (setf *hs-chain-ink* 1))
                          (fx-shard px (f-max 0.03f0 py) pz (/ tx tl) (/ ty tl) (/ tz tl) 0.16f0 fw 0.02f0 (+ jp u)
                                    +pal-hit+ 0.95f0 :push 0.14f0))))))))))))
  nil)

(defun-fast %hs-trail (kv rank j pos fa)
  "A lash's trail: chain J's free end (rank RANK in KV) back over the last 2 frames (*HS-LT* at the frame, *HS-LT2* at
each quarter frame back), a tapered black ribbon, when it moves faster than 1.2 m a frame (a strike, not a haul; the
bundle's twice as wide). 0 B."
  (declare (type f32vec kv pos fa) (fixnum rank j))
  (let* ((e *hs-lt*) (e2 *hs-lt2*) (fr2 *hs-fr2*) (q *hs-mid*) (f (aref *hs-fr* 0)) (w0 (if (= j 8) 0.06f0 0.03f0)))
    (declare (type f32vec e e2 fr2 q) (single-float f w0))
    (setf (aref fr2 0) (- f 1f0))
    (%hs-lash-tip! e2 kv fr2 rank j pos fa)
    (when (and (> (aref e 4) 0.5f0)
               (> (f-hypot (- (aref e 0) (aref e2 0)) (- (aref e 1) (aref e2 1)) (- (aref e 2) (aref e2 2))) 1.2f0))
      (setf (aref q 0) (aref e 0) (aref q 1) (aref e 1) (aref q 2) (aref e 2))
      (loop for k from 1 to 8
            do (setf (aref fr2 0) (- f (* 0.25f0 (i->f k))))
               (%hs-lash-tip! e2 kv fr2 rank j pos fa)
               (let* ((dx (- (aref q 0) (aref e2 0))) (dy (- (aref q 1) (aref e2 1))) (dz (- (aref q 2) (aref e2 2)))
                      (l (f-max 1f-3 (f-hypot dx dy dz))))
                 (declare (single-float dx dy dz l))
                 (%hs-black-kite (* 0.5f0 (+ (aref q 0) (aref e2 0))) (f-max 0.03f0 (* 0.5f0 (+ (aref q 1) (aref e2 1))))
                                 (* 0.5f0 (+ (aref q 2) (aref e2 2))) (/ dx l) (/ dy l) (/ dz l) (* 1.15f0 l)
                                 (* w0 (- 1f0 (/ (i->f k) 9f0))))
                 (setf (aref q 0) (aref e2 0) (aref q 1) (aref e2 1) (aref q 2) (aref e2 2))))))
  nil)

(defun-fast %hs-glint (p j)
  "A chain-tip glint at P (an f32vec, world): a small 4-point white star twinkling on the drawings, glint J's (0-7) own phase
and spikes (§25.26; since §25.28 on J1's tip only: HS-R-TIP-CMD). 0 B."
  (declare (type f32vec p) (fixnum j))
  (let* ((jf (i->f j)) (dr (i->f (logand (f->i (* 12f0 (fx-clock))) 63)))
         (tw (f-abs (f-sin (+ (* 0.7f0 jf) (* 0.5f0 dr))))) (r (* 0.15f0 (+ 0.45f0 (* 0.55f0 tw)))))
    (declare (single-float jf dr tw r))
    (fx-star (aref p 0) (aref p 1) (aref p 2) (* 0.12f0 r) r 4 (* 0.3f0 (hash01 jf 4.7f0)) 0f0 0f0 0.02f0 (+ jf dr) +pal-hit+
             0.95f0 :push 0.3f0))
  nil)

(defun-fast %hs-curtain-draw (pos fa c lk mask)
  "The hanging chains round him (§21.6) on the carousel, lashing and bound (batch A2, §24.2): each of the eight
*HS-CURTAIN* chains not in MASK (a §21.8 chain strike draws that one: %HS-BK-STRIKE) from its top under the orb (C its
centre) to its free end, at rest where the carousel has it (%HS-REST-POLAR!; a cinematic's drop *HS-CL* [1]) or lashing
on its entry of LK (his clip's *HS-LASHES-V*: %HS-LASH-TIP!, the lag, the trail), bound into one bundle by the weight
*HS-CAR* [7] (whose own entry, 256, moves it). POS his feet, FA[0] his facing. Its farthest free end on the keys into
*HS-TIPV*. 0 B."
  (declare (type f32vec pos fa c) (fixnum mask))
  (let* ((cz *hs-cz*) (e *hs-lt*) (e2 *hs-lt2*) (tp *hs-q*) (rp *hs-rp*) (fr *hs-fr*) (fr2 *hs-fr2*) (tv *hs-tipv*)
         (bot (aref *hs-car* 8)) (cl1 (aref *hs-cl* 1)) (bw (aref *hs-car* 7)) (yaw (aref fa 0)))
    (declare (type f32vec cz e e2 tp rp fr fr2 tv) (single-float bot cl1 bw yaw))
    (dotimes (jj 9)
      (let* ((j (if (= jj 0) 8 (1- jj))) (kv (%hs-lash-of lk j)) (o (* 14 j)))
        (declare (fixnum j o))
        (when (or (< j 8) kv (> bw 0.001f0))
          (%hs-rest-polar! rp j)
          (let* ((a (+ yaw (* 0.017453292f0 (aref rp 2)))) (r (aref rp 0))
                 (gx (+ (aref pos 0) (* r (- (f-sin a))))) (gz (+ (aref pos 2) (* r (- (f-cos a))))))
            (declare (single-float a r gx gz))
            (if (= j 8)
                (setf (aref tp 0) (aref c 0) (aref tp 1) bot (aref tp 2) (aref c 2))
                (setf (aref tp 0) (+ (aref c 0) (* 0.6f0 (- gx (aref c 0)))) (aref tp 1) bot
                      (aref tp 2) (+ (aref c 2) (* 0.6f0 (- gz (aref c 2))))))
            (if kv
                (let* ((kv kv) (rank (if (= j 8) 0 (logcount (logand (f->i (aref kv 0)) (1- (ash 1 j)))))))
                  (declare (type f32vec kv) (fixnum rank))   ; (bound, not a free declaration: a typed aref, 0 B)
                  (setf (aref fr2 0) (- (aref fr 0) 2f0))
                  (%hs-lash-tip! e2 kv fr2 rank j pos fa)
                  (%hs-lash-tip! e kv fr rank j pos fa)
                  (setf (aref cz (+ o 13)) (aref kv 2))
                  (when (>= (aref e 4) 0.99f0)
                    (setf (aref tv 0) (f-max (aref tv 0) (aref e 5))
                          (aref tv 1) (f-max (aref tv 1) (* (aref e 5) (f-cos (* 0.017453292f0 (aref e 6)))))))
                  (%hs-curve! cz o tp e e2 pos)
                  (when (and (= j 8) (> bw 0.5f0) (= (aref *hs-tg* 0) 2f0)) (%hs-glint e 0))   ; (§28.11: J1's tip cue on
                  (%hs-trail kv rank j pos fa))                                                 ;  the 聚 stance's bundle end)
                (progn
                  (setf (aref e 0) (+ gx (aref rp 3)) (aref e 1) (aref rp 1) (aref e 2) gz (aref e 3) 0f0 (aref e 4) 0f0
                        (aref cz (+ o 13)) 1f0)
                  (when (< cl1 1f0)                                     ; (a cinematic's drop: that share of its length)
                    (dotimes (i 3) (setf (aref e i) (+ (aref tp i) (* cl1 (- (aref e i) (aref tp i)))))))
                  (when (and (< j 8) (< bw 0.5f0) (= (aref *hs-tg* 0) 2f0)) (%hs-glint e j))   ; (§25.28: on J1's tip;
                                                                        ;  §28.11: not on chains bound into the bundle)
                  (%hs-curve! cz o tp e e tp)))))))
    (dotimes (j 8)
      (unless (logbitp j mask) (%hs-cubic-chain cz (* 14 j) j))))
  nil)

(defun-fast %hs-bk-strike (kv pos fa c jm ojm hk)
  "One Bankai chain strike (*HS-BK-CHAINS*: KV its f32vec) at the clip frame *HS-FR*, drawn black: the hanging chain from
the orb's underside (C its centre) to its free end, the neck bundle's tail from the back of his neck (JM his joints, over
his right shoulder once out), or a chain dropped out of the orb; the free end hauled up taut (or whirled) in the windup,
snapped out on S to its strike point (R m along AZ off his facing FA[0] from his feet POS, H m up; swept, held, home),
hooked in the victim's neck (OJM) on a hit when HK is 1 and the strike hooks. Its farthest end on the strike / hold
frames into *HS-TIPV*. 0 B."
  (declare (type f32vec kv pos fa c jm ojm) (fixnum hk))
  (let* ((f (aref *hs-fr* 0)) (f0 (aref kv 1)) (f1 (aref kv 2)) (f2 (aref kv 3)) (f3 (aref kv 4)) (f4 (aref kv 5)))
    (declare (single-float f f0 f1 f2 f3 f4))
    (when (and (>= f f0) (< f f4))
      (let* ((src (f->i (aref kv 0))) (fl (f->i (aref kv 11))) (e *hs-e*) (kn *hs-kn*) (q *hs-q*) (tp *hs-tipv*)
             (yaw (aref fa 0)) (px (aref pos 0)) (pz (aref pos 2)) (r (%hs-lk-r (aref kv 6))) (h (aref kv 7))
             (k (f-clamp (/ (- f f1) (f-max 1f0 (- f2 f1))) 0f0 1f0))
             (a (+ yaw (* 0.017453292f0 (+ (aref kv 8) (* k (- (aref kv 9) (aref kv 8)))))))
             (tx (+ px (* r (- (f-sin a))))) (tz (+ pz (* r (- (f-cos a)))))
             (bot (- (aref c 1) (* 0.75f0 (the single-float *hs-orb-scale*))))
             (rx tx) (ry 7f0) (rz tz) (ax tx) (ay 7f0) (az tz))
        (declare (fixnum src fl) (type f32vec e kn q tp) (single-float yaw px pz r h k a tx tz bot rx ry rz ax ay az))
        (cond ((< src 8)                                               ; a hanging chain: its rest end (on the
               (let* ((rp *hs-rp*) (cr (progn (%hs-rest-polar! rp src) (aref rp 0)))   ;  carousel, A2), its top
                      (ca (+ yaw (* 0.017453292f0 (aref rp 2))))
                      (gx (+ px (* cr (- (f-sin ca))))) (gz (+ pz (* cr (- (f-cos ca))))))
                 (declare (type f32vec rp) (single-float cr ca gx gz))
                 (setf rx (+ gx (aref rp 3)) ry (aref rp 1) rz gz
                       ax (+ (aref c 0) (* 0.6f0 (- gx (aref c 0)))) ay bot az (+ (aref c 2) (* 0.6f0 (- gz (aref c 2)))))))
              ((= src 8)                                               ; the neck bundle's tail
               (joint-point! kn jm (ji :neck) 0f0 0.07f0 0.06f0)
               (setf ax (aref kn 0) ay (aref kn 1) az (aref kn 2))
               (joint-point! kn jm (ji :spine) 0.12f0 -0.05f0 0.2f0)
               (setf rx (aref kn 0) ry (aref kn 1) rz (aref kn 2))))
        (if (< f f1)
            (let* ((x (f-clamp (/ (- f f0) (f-max 1f0 (* 0.6f0 (- f1 f0)))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x)))))
              (declare (single-float x u))
              (cond ((= src 9)                                         ; dropped: falling in the last 3 frames
                     (setf (aref e 0) tx (aref e 1) (+ 7f0 (* (f-clamp (/ (- f (- f1 3f0)) 3f0) 0f0 1f0) (- h 7f0)))
                           (aref e 2) tz))
                    ((logtest fl 2)                                    ; whirled overhead
                     (let ((wa (+ yaw (* 0.45f0 f))))
                       (declare (single-float wa))
                       (setf (aref e 0) (+ rx (* u (- (+ px (* 0.9f0 (- (f-sin wa)))) rx)))
                             (aref e 1) (+ ry (* u (- 2.6f0 ry)))
                             (aref e 2) (+ rz (* u (- (+ pz (* 0.9f0 (- (f-cos wa)))) rz))))))
                    ((logtest fl 12)                                   ; hauled up into his fist
                     (joint-point! q jm (if (logtest fl 4) (ji :weapon-r) (ji :weapon-l)) 0f0 0f0 0f0)
                     (setf (aref e 0) (+ rx (* u (- (aref q 0) rx))) (aref e 1) (+ ry (* u (- (aref q 1) ry)))
                           (aref e 2) (+ rz (* u (- (aref q 2) rz)))))
                    (t (setf (aref e 0) (+ rx (* u 0.35f0 (- px rx)))   ; hauled up taut, a tremble at the peak
                             (aref e 1) (+ ry (* u (aref kv 10)) (* 0.03f0 u (f-sin (* 2.7f0 f))))
                             (aref e 2) (+ rz (* u 0.35f0 (- pz rz)))))))
            (progn
              (if (and (= hk 1) (logtest fl 1))                        ; out: on the strike point, or hooked in him
                  (joint-point! e ojm (ji :neck) 0f0 0.07f0 0f0)
                  (setf (aref e 0) tx (aref e 1) h (aref e 2) tz))
              (if (>= f f3)                                            ; home
                  (let* ((x (f-clamp (/ (- f f3) (f-max 1f0 (- f4 f3))) 0f0 1f0)) (u (* x x (- 3f0 (* 2f0 x)))))
                    (declare (single-float x u))
                    (setf (aref e 0) (+ (aref e 0) (* u (- rx (aref e 0)))) (aref e 1) (+ (aref e 1) (* u (- ry (aref e 1))))
                          (aref e 2) (+ (aref e 2) (* u (- rz (aref e 2))))))
                  (let ((dx (- (aref e 0) px)) (dz (- (aref e 2) pz)))
                    (declare (single-float dx dz))
                    (setf (aref tp 0) (f-max (aref tp 0) (f-hypot dx dz))
                          (aref tp 1) (f-max (aref tp 1) (- (* dx (- (f-sin yaw))) (* dz (f-cos yaw)))))))))
        (setf (aref kn 0) ax (aref kn 1) ay (aref kn 2) az)
        (cond ((= src 9) (when (< (aref e 1) 6.9f0) (%hs-chain2 kn e)))
              ((< f f1) (%hs-chain2 kn e))
              ((= src 8)                                               ; over his right shoulder, then out
               (joint-point! q jm (ji :upper-arm-r) 0f0 0.1f0 0f0)
               (%hs-chain2 kn q) (%hs-chain2 q e))
              (t (setf (aref q 0) rx (aref q 1) (aref e 1) (aref q 2) rz) ; hanging to its rest end, then level out
                 (%hs-chain2 kn q) (%hs-chain2 q e))))))
  nil)

(declaim (type f32vec *hs-gc0* *hs-gc1*))
(defvar *hs-gc0* (make-f32 3) "%HS-GRIP-CHAIN's piece start (scratch).")
(defvar *hs-gc1* (make-f32 3) "%HS-GRIP-CHAIN's piece end (scratch).")
(defun-fast %hs-grip-chain (a b gv)
  "The bind's held chain from his fist A to the opponent's noose B (f32vecs; GV his clip's *HS-KB-GRIPS-V* entry) at the
clip frame *HS-FR*, black: nothing from F1 on; four pieces along a parabola, sagging 0.5 m eased out to taut by FT, then
taut with a tremble (2-4 cm, fast) while FT > 0. 0 B."
  (declare (type f32vec a b gv))
  (let* ((f (aref *hs-fr* 0)) (f1 (aref gv 0)) (ft (aref gv 1)) (g *hs-gc0*) (h *hs-gc1*)
         (x (if (> ft 0f0) (f-clamp (- 1f0 (/ f ft)) 0f0 1f0) 0f0)) (sag (* 0.5f0 x x))
         (tr (if (and (> ft 0f0) (>= f ft)) (* 0.03f0 (f-sin (* 2.9f0 f))) 0f0)))
    (declare (type f32vec g h) (single-float f f1 ft x sag tr))
    (when (< f f1)
      (if (and (<= sag 0f0) (= tr 0f0))
          (%hs-chain2 a b)
          (progn
            (dotimes (i 3) (setf (aref g i) (aref a i)))
            (dotimes (k 4)
              (let* ((u (* 0.25f0 (i->f (1+ k)))) (s (+ (* 4f0 sag u (- 1f0 u)) (* tr (f-sin (* 3.1415927f0 u))))))
                (declare (single-float u s))
                (setf (aref h 0) (+ (aref a 0) (* u (- (aref b 0) (aref a 0))))
                      (aref h 1) (- (+ (aref a 1) (* u (- (aref b 1) (aref a 1)))) s)
                      (aref h 2) (+ (aref a 2) (* u (- (aref b 2) (aref a 2)))))
                (vfx-hs-chain g h 0f0 0.9f0)
                (dotimes (i 3) (setf (aref g i) (aref h i)))))))))
  nil)

(defun-fast %hs-orb-draw (jm pos fa opos ojm side bound tint ks hk lk gp)
  "The Bankai's orb (DUEL_HISAGI §21.6), drawn by HISAGI-DRAW in both modes: its centre *HS-ORB-H* up and *HS-ORB-SIDE* to
his right, *HS-ORB-BACK* behind him (BOUND 1, a bind: over the pair's midpoint), eased there at 2.5 /s (placed at once on
a still or a jump > 8 m; SIDE 0 / 1 his slot in *HS-ORB-V*), swaying, turning slowly, *HS-ORB-SCALE* x its mesh; the pale
light patch under it (the inverted shadow); the curtain of chains hanging from it round him (*HS-CURTAIN*, moving with
him); the bundle of four chains twisted together from it down to the back of his neck (JM his joints, POS his feet, FA[0]
his facing) and its slack tail down his back; in a bind the same bundle to the opponent's neck (OPOS, OJM), tied twice
round it (BOUND 2, UNWIND: that ring sliding down him, slack). KS: his clip's chain strikes (*HS-BK-CHAINS-V*, §21.8):
each hanging chain or the tail one uses is drawn by %HS-BK-STRIKE instead (HK 1: his move hit). TINT: his body's (the
mirror's P2). Batch A2 (§24.2): the orb turns with the carousel's phase (%HS-CAR!, jerked on each strike), the hanging
chains orbit with it and lash or bind into the bundle on LK (his clip's *HS-LASHES-V*: %HS-CURTAIN-DRAW); GP in a bind
(his clip's *HS-KB-GRIPS-V* or NIL): his left fist holds a chain to the opponent's noose (%HS-GRIP-CHAIN). BOUND 3 (batch
A3, §24.3: KAIBAKU-GEKI from its S): the noose thrown off the opponent's neck and reeled up into the orb. 0 B."
  (declare (type f32vec jm pos fa opos ojm) (fixnum side bound))
  (let* ((ov *hs-orb-v*) (c *hs-oc*) (m *hs-om*) (v *hs-v*) (w *hs-w*) (q *hs-q*)
         (tm (fx-clock)) (yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
         (cl *hs-cl*) (gr (aref cl 0))                                  ; (the B5 cinematics' hold: *HS-CL*)
         (sd (the single-float *hs-orb-side*)) (bk (the single-float *hs-orb-back*))
         (sc (* (f-max 0.05f0 gr) (the single-float *hs-orb-scale*)))
         (tx (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 0) (aref opos 0))) (* sd rx)) (+ (aref pos 0) (* sd rx) (- (* bk fx)))))
         (tz (if (= bound 1) (+ (* 0.5f0 (+ (aref pos 2) (aref opos 2))) (* sd rz)) (+ (aref pos 2) (* sd rz) (- (* bk fz)))))
         (tx (+ tx (* 0.1f0 (f-sin (+ (* 0.6f0 tm) (* 2f0 (i->f side)))))))
         (ty (+ (the single-float *hs-orb-h*) (aref cl 3) (* 0.08f0 (f-sin (* 0.9f0 tm)))))
         (o (* 3 side)) (dt (aref *hs-grip-v* 2))
         (ex (- tx (aref ov o))) (ey (- ty (aref ov (+ o 1)))) (ez (- tz (aref ov (+ o 2))))
         (k (if (or (<= dt 0f0) (< (aref ov (+ 6 side)) 0.5f0) (> (+ (* ex ex) (* ey ey) (* ez ez)) 64f0) (> (aref cl 4) 0.5f0)) 1f0
                (f-min 1f0 (* 2.5f0 dt))))
         (s (aref *hs-car* 6)) (cs (* sc (f-cos s))) (ss (* sc (f-sin s))) (bot 0f0) (mask 0))   ; (the carousel, A2)
    (declare (type f32vec ov c m v w q cl) (fixnum o mask)
             (single-float tm gr yaw fx fz rx rz sd bk sc tx tz ty dt ex ey ez k s cs ss bot))
    (setf (aref ov o) (+ (aref ov o) (* k ex)) (aref ov (+ o 1)) (+ (aref ov (+ o 1)) (* k ey))
          (aref ov (+ o 2)) (+ (aref ov (+ o 2)) (* k ez)) (aref ov (+ 6 side)) 1f0
          (aref c 0) (aref ov o) (aref c 1) (aref ov (+ o 1)) (aref c 2) (aref ov (+ o 2))
          bot (- (aref c 1) (* 0.75f0 sc)) (aref *hs-car* 8) bot)
    (setf (aref m 0) cs (aref m 1) 0f0 (aref m 2) (- ss) (aref m 3) 0f0
          (aref m 4) 0f0 (aref m 5) sc (aref m 6) 0f0 (aref m 7) 0f0
          (aref m 8) ss (aref m 9) 0f0 (aref m 10) cs (aref m 11) 0f0
          (aref m 12) (aref c 0) (aref m 13) (aref c 1) (aref m 14) (aref c 2) (aref m 15) 1f0)
    (draw-weapon :hs-orb m :tint tint)
    (setf *hs-chain-black* 1 mask (%hs-bk-mask ks))
    ;; the inverted shadow: a pale patch on the ground under it
    (%sector-verts :add 20 (aref c 0) 0f0 (aref c 2) 0f0 (* 1.1f0 sc) 0f0 3.1415927f0 (* 0.2f0 gr) (* 0.21f0 gr) (* 0.2f0 gr)
                   0.5f0)
    (%hs-curtain-draw pos fa c lk mask)                                 ; the curtain round him (the carousel, A2)
    ;; his neck bundle: four chains twisted from the orb down behind his head, tied round his neck; its slack tail
    (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
    (if (< (aref cl 2) 1f0)                                             ; (a cinematic's descent: untied, partway down)
        (progn (joint-point! w jm (ji :neck) 0f0 0.24f0 0.2f0)
               (dotimes (i 3) (setf (aref w i) (+ (aref v i) (* (aref cl 2) (- (aref w i) (aref v i))))))
               (when (> (aref cl 2) 0.02f0) (%hs-bundle v w 4 3.0f0 0.05f0 0.45f0)))
        (%hs-tie v jm))
    (unless (or (logtest mask 256) (< (aref cl 2) 1f0))
      (joint-point! w jm (ji :neck) 0f0 0.07f0 0.06f0)
      (joint-point! v jm (ji :spine) 0.12f0 -0.05f0 0.2f0)
      (vfx-hs-chain w v 0.15f0 0.9f0))
    (dolist (x ks) (%hs-bk-strike x pos fa c jm ojm hk))                ; his chain strikes (§21.8)
    (when (= bound 2)                                                  ; UNWIND: the noose's ring slides off him, slack
      (let ((u (f-clamp (/ (aref *hs-fr* 0) 20f0) 0f0 1f0)))
        (declare (single-float u))
        (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
        (dotimes (i 20)
          (let* ((a (* 0.62831855f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)) (rr (+ 0.085f0 (* 0.3f0 u)))
                 (y (- (if (< i 10) -0.015f0 0.02f0) (* 1.4f0 u u))))
            (declare (single-float a ca sa rr y))
            (%hs-black-kite (+ (aref w 0) (* rr ca)) (+ (aref w 1) y) (+ (aref w 2) (* rr sa)) (- sa) 0f0 ca
                            0.075f0 (if (evenp i) 0.026f0 0.012f0))))))
    (when (= bound 1)                                                  ; the noose: the same bundle round his neck
      (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
      (%hs-tie v ojm)
      (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
      (dotimes (i 20)
        (let* ((a (* 0.62831855f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)) (y (if (< i 10) -0.015f0 0.02f0)))
          (declare (single-float a ca sa y))
          (%hs-black-kite (+ (aref w 0) (* 0.085f0 ca)) (+ (aref w 1) y) (+ (aref w 2) (* 0.085f0 sa)) (- sa) 0f0 ca
                          0.075f0 (if (evenp i) 0.026f0 0.012f0))))
      (when gp                                                         ; (A2: the bind's stance; A3: KOJO, KAIBAKU)
        (joint-point! w jm (ji :weapon-l) 0f0 0f0 0f0)
        (joint-point! q ojm (ji :neck) 0f0 0.24f0 0.2f0)
        (%hs-grip-chain w q gp)
        (when (> (length (the f32vec gp)) 2)                           ; (batch 2b, §28.12: *HS-KB-GRIPS*' FL)
          (let ((fl (f->i (aref gp 2))))
            (declare (fixnum fl))
            (joint-point! w jm (ji :weapon-r) 0f0 0f0 0f0)
            (when (logtest fl 1) (%hs-grip-chain w q gp))              ; SHIME: the right fist's chain to the noose too
            (when (logtest fl 2)                                       ; the 絞 stance: wound on the right fist, taut
              (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))   ;  straight up to the orb
              (%hs-chain2 w v)
              (%hs-wrist-coil jm (ji :lower-arm-r)))))))
    (when (= bound 3)                                                  ; (A3: KAIBAKU-GEKI) thrown off, reeled up
      (let* ((u (f-clamp (/ (- (aref *hs-fr* 0) 18f0) 12f0) 0f0 1f0)) (k (* u u)) (rr (+ 0.085f0 (* 0.4f0 u))))   ; (its S 18)
        (declare (single-float u k rr))
        (when (< u 1f0)
          (setf (aref v 0) (aref c 0) (aref v 1) bot (aref v 2) (aref c 2))
          (joint-point! w ojm (ji :neck) 0f0 0.07f0 0f0)
          (setf (aref w 0) (+ (aref w 0) (* k (- (aref v 0) (aref w 0))) (* 1.2f0 u (- 1f0 u) rx))   ; (flung out to his right,
                (aref w 1) (+ (aref w 1) (* k (- (aref v 1) (aref w 1))) (* 1.6f0 u (- 1f0 u)))      ;  up, into the orb)
                (aref w 2) (+ (aref w 2) (* k (- (aref v 2) (aref w 2))) (* 1.2f0 u (- 1f0 u) rz)))
          (dotimes (i 20)
            (let* ((a (* 0.31415927f0 (i->f i))) (ca (f-cos a)) (sa (f-sin a)))
              (declare (single-float a ca sa))
              (%hs-black-kite (+ (aref w 0) (* rr ca)) (+ (aref w 1) (* 0.3f0 rr sa)) (+ (aref w 2) (* rr sa)) (- sa) 0f0 ca
                              (* 0.08f0 (+ 1f0 (* 3f0 u))) (if (evenp i) 0.026f0 0.012f0))))
          (%hs-bundle v w 4 3.0f0 0.05f0 0.45f0)))))
  (setf *hs-chain-black* 0)
  nil)

(defparameter *hs-crack-ds* (coerce (mapcar #'f32 '(0.9 1.25 1.6 1.95 2.3 2.65 3.0 3.35 3.7 4.05 4.4)) 'f32vec)
  "AS2b JIBASHIRI's crack (§28.11): its zigzag's points, m from his feet along his facing (to its line's 4.5 m).")
(defun-fast %hs-crack (pos fa)
  "AS2b 地走 JIBASHIRI's crack (batch 2a, DUEL_HISAGI §28.11; a look, keyed on his clip :hs-k-jibashiri): from clip frame 34
(the bundle driven in) a black zigzag on the floor runs out along his facing FA[0] from POS (his feet) to 4.4 m by frame 37
(the hit, S 36, its end on the line's), held, then fades (thinner) by frame 62. 0 B."
  (declare (type f32vec pos fa))
  (let* ((f (aref *hs-fr* 0)) (ds *hs-crack-ds*) (yaw (aref fa 0)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw)))
         (rx (f-cos yaw)) (rz (- (f-sin yaw))) (front (+ 0.9f0 (* 1.2f0 (- f 34f0))))
         (w (* 0.05f0 (f-clamp (/ (- 62f0 f) 14f0) 0f0 1f0))) (q *hs-q*) (px 0f0) (pz 0f0))
    (declare (type f32vec ds q) (single-float f yaw fx fz rx rz front w px pz))
    (when (and (>= f 34f0) (< f 62f0))
      (dotimes (i 11)
        (let* ((d (aref ds i)) (off (* (if (evenp i) 0.12f0 -0.12f0) (+ 0.6f0 (* 0.4f0 (hash01 (i->f i) 3.1f0)))))
               (x (+ (aref pos 0) (* d fx) (* off rx))) (z (+ (aref pos 2) (* d fz) (* off rz))))
          (declare (single-float d off x z))
          (when (and (> i 0) (<= d front))
            (let* ((dx (- x px)) (dz (- z pz)) (l (f-max 1f-3 (f-hypot dx 0f0 dz))))
              (declare (single-float dx dz l))
              (setf (aref q 0) (* 0.5f0 (+ x px)) (aref q 2) (* 0.5f0 (+ z pz)))
              (%hs-black-kite (aref q 0) 0.02f0 (aref q 2) (/ dx l) 0f0 (/ dz l) (* 1.1f0 l) w 0.02f0)))
          (setf px x pz z)))))
  nil)

(defun hisagi-draw (e rdt)
  "His :draw hook (on the posed body): the left sickle (in his fist, flying, out at the anchor, returning, let out on its
chain), the chain, the windmill, the lightning. A look: every point is the sim's (the anchor, *HS-FLIGHTS*' reach,
HS-CHAIN-SEG's ends) or the clip's let-out (*HS-LETOUT*, at the strike's volume edge on its hit frames). The Shikai's looks
(DUEL_HISAGI §21.4) only in his base form; the Bankai's forms (§21.6, §21.8): the crescents in hand or let out on their hand
chains, the bolt (*HS-BOLTS*), KOSHU's garrote, plus the orb, its curtain, the neck bundle, a bind's noose and the chain
strikes (%HS-ORB-DRAW). Nothing while the sealed sword is in hand (the intro). In his own cinematics (B5, HS-CINE-OF) the
script's frame drives the rest (%HS-CINE-LOOK!: the awakening's Shikai look and the orb forming, KOSA's curtain hauled up,
KOSHU's noose and sinking orb, the Shikai Kikon's sickle flight HS-KARE-CODES)."
  (let* ((f (fighter e)) (m (model e)) (st (hs e)) (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (name (and mv (hs-look-name mv))) (sf (fighter-sf f)) (o (opp-of e)) (fa *hs-a*) (bolt 0) (volt 0)
         (ck (hs-cine-of e)) (cf (if (> ck 0) (cine-cf *cine*) 0)) (cfl (%hs-cine-look! ck cf))
         (shikai (or (eq (fighter-form f) :base) (logtest cfl 1))) (lo 0) (geo 0) (an (model-anim m)) (c (anim-clip an))
         (cn (and c (clip-name c))))
    (when (and (> (model-alpha m) 0.5) (entity-alive-p o) (eq (model-weapon m) :kazeshini))
      (%hs-ks! (hss-charge st))                                       ; (S1: the charge's x for the windmill / K string)
      (hs-lk! e)                                                      ; (§25.13: a route link's chain to the victim)
      (hs-kb-lk! e cn)                                                ; (batch 2b: the bind's reels, onto the victim)
      (setf geo (%hs-geo! an (pos-of e) (pos-of o) fa (transform e) (if shikai 1 0) rdt))
      (when (logtest geo 1) (setf lo 1))
      (let ((kv (hs-letout-of cn :l)))
        (if kv
            (progn
              (%hs-letout! *hs-ml* (model-joints m) (ji :weapon-l) (ji :upper-arm-l) (pos-of e) *hs-yaw* kv *hs-fr* *hs-lo* 8)
              (when (= 1 (%hs-left-out-p)) (setf lo (logior lo 2))))
            (setf (aref *hs-lo* 8) 0f0)))
      (let ((bl (and mv (assoc cn *hs-bolts*))))                        ; TSUZURI RAIDEN's bolt, every form's
        (setf (aref fa 2) (if bl (second bl) 6.5)
              bolt (if (and bl (< (- (mv-s mv) 3) sf (+ (mv-s mv) (mv-a mv) 5))) 1 0)))
      (multiple-value-bind (a b n d)
          (cond ((= ck 1) (values 0 0 0 1))                            ; (the awakening: the sickle in his fist)
                ((= ck 2)                                              ; (the Shikai Kikon's throw, return, KUBIKAKE)
                 (multiple-value-bind (a b n d l)
                     (hs-kare-codes cf fa (if (and (eq cn :hs-s-kubikake) (logtest geo 8) (logtest geo 4) (< cf 98)) 1 0))
                   (setf lo (logior lo l))
                   (values a b n d)))
                ((and shikai (eq (fighter-state f) :move) (eq (fighter-phase f) :follow))   ; the O's zip: hooked in him
                 (setf lo (logior lo 4)) (values 5 5 0 1))
                ((and shikai (fighter-follow f) (eq name :hs-kikon)) (values 0 0 0 1))   ; (the follow-up: a close cut)
                ((and shikai (member name *hs-kazas*))                 ; the windmill (S 6, A 60, R 14)
                 (let ((top (+ (mv-s mv) (mv-a mv))))
                   (%hs-kaza-point *hs-pt* (pos-of e) fa (min sf top))
                   (setf lo (logior lo 4))
                   (if (< sf top) (values 5 5 0 1) (values 5 0 (- sf top) (mv-r mv)))))
                ((and shikai (= ck 0) mv (member (mv-name mv) '(:hs-n3a :hs-n3b :hs-sa-hoden))   ; §27.6: 縛雷's bind, kept
                      (or (not (eq (mv-name mv) :hs-n3a)) (<= (- (mv-s mv) 4) sf)))   ;  wound on him (by the move's name)
                 (let ((on (logtest geo 32)) (k (mv-name mv)))         ; (within the chain's 6.5 m: on him, hit or not;
                   (setf (aref fa 1) 4.85 lo (logior lo 4))            ;  beyond, the cast lies at its 4.85 m)
                   (cond ((eq k :hs-n3a)                               ; NS3a: SHIBARI's cast, flown to his chest
                          (cond ((< sf (mv-s mv)) (setf lo (logior lo 64)) (values 0 (if on 5 1) (- sf (- (mv-s mv) 4)) 4))
                                (on (setf lo (logior lo 32 32768)) (values 5 5 0 1))
                                (t (values 1 1 0 1))))
                         ((not on) (setf lo (logior lo 16384)) (values 1 1 0 1))
                         ((eq k :hs-n3b)                               ; CHIKUDEN (48 f): the charge along it, the
                          (if (< sf 42)                                ;  chain reeled back over its last 6 f
                              (progn (setf lo (logior lo 32 32768 16384) volt 1) (values 5 5 0 1))
                              (values 5 0 (- sf 42) 6)))
                         ((< sf 24)                                    ; 放電 (37 f): the burst along it, the coil
                          (setf lo (logior lo 32 32768 (if (< sf 10) 16384 0)) volt 2) (values 5 5 0 1))   ;  burnt off,
                         ((< sf 32) (values 5 0 (- sf 24) 8))           ;  the sickle reeled back f24-32
                         (t (values 0 0 0 1)))))
                ((and shikai (eq name :hs-shibari) (<= (- (mv-s mv) 4) sf) (< sf 52))   ; SHIBARI: cast, wrapped, heaved
                 (setf (aref fa 1) 4.85 lo (logior lo 4))
                 (if (and (fighter-contact f) (logtest geo 2)) (setf lo (logior lo 32)) (setf lo (logior lo 64)))
                 (cond ((< sf (mv-s mv)) (values 0 1 (- sf (- (mv-s mv) 4)) 4))
                       ((logtest lo 32) (values 5 5 0 1))
                       ((< sf 50) (values 1 1 0 1))
                       (t (values 1 0 (- sf 50) 2))))
                ((and shikai mv (assoc cn *hs-foe-paths*))             ; A1: NOKO / TSUI placed on the victim (§24.1)
                 (let ((g (loop for g in (cdr (assoc cn *hs-foe-paths*)) when (and (<= (first g) sf) (< sf (second g))) return g)))
                   (if g
                       (destructuring-bind (f0 f1 a b sp) g
                         (setf lo (logior lo 4 (* 256 sp)))
                         (when (and (eq (mv-name mv) :hs-as3b) (>= sf 16))   ; (§27.5: TAME's charge down the chain;
                           (setf lo (logior lo 16384)))                       ;  CHIKUDEN's is §27.6's, above)
                         (values (if (and (= a 10) (eq name :hs-k2j)) 0 a) b (- sf f0) (- f1 f0)))   ; (K2J: off J1, from the fist)
                       (values 0 0 0 1))))
                ((and mv (assoc name *hs-flights*))
                 (setf (aref fa 1) (second (assoc name *hs-flights*)))
                 (%hs-fa-ks! fa)                                       ; (S1: NAGE at the charge's reach)
                 (when shikai (setf lo (logior lo (if (eq name :hs-k2s) 196 68))))
                 (hs-flight-codes st name sf (mv-s mv) (mv-a mv)))
                ((and mv (member name *hs-pulls*))
                 (when shikai (setf lo (logior lo 16)))
                 (if (< sf (mv-s mv)) (values 2 2 0 1) (values 2 4 (- sf (mv-s mv)) (+ (mv-a mv) 2))))
                ((eq name :hs-modoshi) (when shikai (setf lo (logior lo 4))) (values 2 0 sf 6))
                ((eq (hss-state st) :ret) (when shikai (setf lo (logior lo 4)))
                 (values 2 0 (- *hs-return-frames* (hss-ret-t st)) *hs-return-frames*))
                ((eq (hss-state st) :out) (when shikai (setf lo (logior lo 4))) (values 2 2 0 1))
                (t (when (or (and (eq cn :hs-s-kubikake) (logtest geo 8) (logtest geo 4))
                             (and mv (eq cn :hs-kb-koshu) (>= sf (mv-s mv)) (logtest geo 16))
                             (and (= ck 4) (eq cn :hs-kb-koshu) (logtest geo 16) (= 1 (%hs-fr-from 8))))   ; (KOSHU's)
                     (setf lo (logior lo 8)))                          ; (KUBIKAKE's, KOSHU's garrote: through his neck)
                   (when shikai                                        ; (§26: the pointer stances' chain)
                     (case cn (:hs-st-bind (setf lo (logior lo 2048))) (:hs-st-raiden (setf lo (logior lo 4096)))
                       ((:hs-st-kari :hs-kr-tan :hs-kr-ren :hs-kr-sen :hs-kr-ko :hs-kr-age   ; (§27.5; the 刈 Kikon's, §27.8)
                         :hs-cine-kr-spin :hs-cine-kr-pass :hs-cine-kr-chiburi) (setf lo (logior lo 8192)))))
                   (values 0 0 0 1)))
        (setf *hs-chain-black* 1 *hs-chain-ink* (if (eq e *p1*) 0 1))  ; (black, both forms; P2 the original ink: the user, 2026-10-18)
        (when (< ck 5)                                                 ; (首掛 / 綴雷電: their scripts draw them, §26.6)
          (%hs-draw (model-joints m) (pos-of e) fa (hss-anchor st) (pos-of o) a b n d (model-tint m) bolt lo))
        (when (> volt 0) (%hs-volt (model-joints m) (pos-of o) volt sf))   ; (§27.6: the lightning along the binding chain)
        (let ((wr (and mv (eq (fighter-contact f) :hit) (assoc cn *hs-kb-wraps*))))   ; (batch 2b: MATOI's chain wound round him)
          (when wr (%hs-kb-wrap (model-joints m) (pos-of o) (second wr) (third wr))))
        (when (and shikai (= ck 0) mv (eq (mv-name mv) :hs-as1))      ; (§27.10: TSUMUJI's four flat cuts round him;
          (%hs-tsumuji-cuts (model-joints m) (pos-of e) fa (hss-anchor st) (pos-of o) sf)   ;  his right rod never
          (setf (trail-count (blade-points (blade e))) 0f0))           ;  swings: the leap's slide and landing would
                                                                       ;  smear it into a beam, DRAW-FIGHTER's trail dropped)
        (when (and shikai mv (eq (mv-name mv) :hs-sa-hoden) (eq (fighter-contact f) :hit)   ; (§27.5: 放電's burst on him)
                   (<= (mv-s mv) sf) (< sf (+ (mv-s mv) 18)))
          (%hs-hoden-burst (model-joints (model o)) (- sf (mv-s mv))))
        (when (plusp (hss-zan st)) (%hs-zan (model-joints (model o)) (hss-zan st))))   ; (§27.5: 餘電 on him)
      (unless (or shikai (logtest cfl 2))                              ; the Bankai: the orb, its chains, the noose (§21.6)
        (setf (aref *hs-tipv* 0) 0f0 (aref *hs-tipv* 1) 0f0)            ; (and the chain strikes, §21.8)
        (setf (aref *hs-tg* 0)                                          ; §25.26: the chain-tip glint, free in the ranged mode
              (let ((cmd (and (= ck 0) (eq (fighter-form f) :bankai) (not (hss-bound st))
                              (member (fighter-state f) '(:idle :walk :guard :run :step))   ; (:step since 2026-10-26: 「在過程
                                                        ;  中只要經過尖端的範圍就會起動提示」)
                              (hs-tip-band *hs-g*))))
                (case cmd (1 1f0) (2 2f0) (t 0f0))))
        (%hs-car! an (if (eq e *p1*) 0 1) (cdr (assoc cn *hs-spins-v*))   ; (A2: the carousel; §28.11: a move's own
                  (cdr (or (and mv (assoc name *hs-bundled-v*)) (assoc cn *hs-bundled-v*))))   ;  bundle first, the gathered SA)
        (when (and mv (eq cn :hs-k-jibashiri)) (%hs-crack (pos-of e) fa))   ; (§28.11: AS2b's crack along its line)
        (%hs-orb-draw (model-joints m) (pos-of e) fa (pos-of o) (model-joints (model o)) (if (eq e *p1*) 0 1)
                      (cond ((and mv (eq name :hs-b-sp2) (>= sf (mv-s mv))) 3)   ; (A3: KAIBAKU-GEKI's release)
                            ((or (hss-bound st) (logtest cfl 4)) 1) ((eq cn :hs-kb-unwind) 2) (t 0)) (model-tint m)
                      (cdr (assoc cn *hs-bk-chains-v*)) (if (and mv (eq (fighter-contact f) :hit)) 1 0)
                      (cdr (or (and mv (assoc name *hs-lashes-v*)) (assoc cn *hs-lashes-v*)))   ; (§28.11: a move's own first)
                      (and (hss-bound st) (cdr (assoc cn *hs-kb-grips-v*))))))))

(defun hs-tip-fx (att def x y z &rest more)
  "His :hit-fx hook (FEEDBACK-SYSTEM, after the hit's spark; DUEL_HISAGI §25.26): a hit on the chain tip (HS-DMG-MULT's
HSS-TIP-HIT: x1.71, a route link by its opener's read) adds the :tip stamp (the white flash, the steel cross of light) and
the :hs-tip ring. A look."
  (declare (ignore more))
  (let ((st (hs att)))
    (when (and st (hss-tip-hit st))
      (multiple-value-bind (dx dz) (hit-dir att def) (stamp :tip x y z :dx dx :dz dz))
      (sfx-at :hs-tip x y z :gain 0.8))))

;;; ---------------------------------------------------------------- the HUD: the sickle icon (the kit meter's :draw / :label, :deck)
(defun hs-hud-label (g kit) "The portrait label." (declare (ignore g kit)) "KAZESHINI")
(defun hs-hud-tag (e)
  "His :hud-tag hook: the page's status tag (webhud.lisp, DUEL_WEBUI §7), the sickle as his meter row reads it: in hand, out,
returning."
  (case (hss-state (hs e)) (:in "KAZESHINI IN") (:ret "KAZESHINI ...") (t "KAZESHINI OUT")))
(defun hs-hud-meter (e kit x y w h right tm lx ly ls)
  "His kit-meter row: the sickle icon by his Reiatsu (§8.3): lit white in hand, a dark outline OUT, half lit RETURNING; the
label KAZESHINI IN / OUT."
  (declare (ignore kit tm))
  (let* ((s (hss-state (hs e))) (hh (* 2.4 h)) (iw (* 0.9 hh)) (ix (if right (- (+ x w) iw) x)) (iy (- (+ y (* 0.5 h)) (* 0.5 hh))))
    (ui-rect ix iy iw hh '(0.1 0.1 0.12 0.8))
    (case s
      (:in (ui-rect (+ ix 2) (+ iy 2) (- iw 4) (- hh 4) '(0.93 0.93 0.9 1.0)))
      (:ret (ui-rect (+ ix 2) (+ iy (* 0.5 hh)) (- iw 4) (- (* 0.5 hh) 2) '(0.93 0.93 0.9 0.8)))
      (t (ui-rect (+ ix 2) (+ iy 2) (- iw 4) (- hh 4) '(0.3 0.3 0.34 0.7))))
    (when lx
      (hud-text (case s (:in "KAZESHINI IN") (:ret "KAZESHINI ...") (t "KAZESHINI OUT")) lx ly ls '(0.93 0.93 0.9 1.0)
                :align (if right :right :left)))))
(setf (kit-meter (find-kit :hisagi :base)) (list :name "KAZESHINI" :max 1 :draw 'hs-hud-meter :label 'hs-hud-label))
;; (B2b: the Bankai's two modes show no sickle row: a meter of their own with no :draw, so the HUD neither inherits the
;; Shikai's, which overlapped the awakened forms' L COOLDOWN row, nor draws one; no sim reads it: no :start / :full-form)
(dolist (f '(:bankai :bankai-bind)) (setf (kit-meter (find-kit :hisagi f)) (list :name "FUSHI NO KOJO" :max 1)))
(defun hs-deck (e cx cy d)
  "His :deck hook (one hand): a dot above the thumb, lit while the sickle is in hand."
  (let ((r (* d 52.0)))
    (ui-rect (- cx (* 3 d)) (- cy r (* 3 d)) (* 6 d) (* 6 d)
             (if (eq (hss-state (hs e)) :in) '(0.93 0.93 0.9 1.0) '(0.3 0.3 0.32 0.6)))))

;;; ---------------------------------------------------------------- name
(setf *brush-names* (append (remove :hisagi *brush-names* :key #'first) '((:hisagi "檜佐木修兵" "HISAGI SHUHEI"))))

