;;;; ichigo-look.lisp — KUROSAKI ICHIGO's looks, hooks, sounds and cinematics (the tail of ichigo-art.lisp, moved out in refactor round 2,
;;;; the user 2026-10-21): the crescents, the clones and afterimages, the parry's flare, the cloak and impact looks, his six
;;;; sounds, his glyphs and brush names, and his cinematics: the Cero Getsuga (the Shikai Kikon; the one place gold and
;;;; pink-violet are allowed), 千影 (KESSA's Kikon), 漆黒の月牙天衝 (his Soul Break) and the awakening. Cosmetic code that runs every
;;;; frame or in a cinematic (RND01, the fx clock). ichigo-art.lisp (body, weapons, poses, clips) loads first; *P1* *P2* *IC-POSE-ANG*
;;;; are declaimed special there.
(in-package :duel)

;;; ---------------------------------------------------------------- looks (cosmetic: RND01, the fx clock)
(defun-fast vfx-ic-crescent (x y z yaw w k tilt core)
  "A Getsuga crescent at (x y z) (its middle), flying along YAW, W m tip to tip, its tips TILT (-1..1) up / down: an ink
crescent bulging forward, a white rim (CORE 0), a BLOOD rim (1: KESSA's), a BLOOD core in a white rim (2: the Gran
Rey Cero); presence K."
  (with-floats (x y z yaw w k tilt)
    (let* ((fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (hw (* 0.5f0 w)) (dr (drawing-no))
           (dy (* 0.3f0 w tilt)) (x0 (- x (* hw px))) (z0 (- z (* hw pz))) (x1 (+ x (* hw px))) (z1 (+ z (* hw pz)))
           (bx (+ x (* 0.5f0 w fx))) (bz (+ z (* 0.5f0 w fz))) (rw (* 0.035f0 w)) (ahead (* 0.04f0 w)))
      (declare (single-float fx fz px pz hw dr dy x0 z0 x1 z1 bx bz rw ahead))
      (fx-crescent x0 (- y dy) z0 x1 (+ y dy) z1 bx y bz (* 0.15f0 w) :lens 0.06f0 (+ 300f0 dr) +pal-ink+ k :push 0.1f0)
      (fx-crescent (+ x0 (* ahead fx)) (- y dy) (+ z0 (* ahead fz)) (+ x1 (* ahead fx)) (+ y dy) (+ z1 (* ahead fz))
                   (+ bx (* 1.5f0 ahead fx)) y (+ bz (* 1.5f0 ahead fz)) rw :lens 0.04f0 (+ 310f0 dr)
                   (if (= (the fixnum core) 1) +pal-blood+ +pal-hit+) k :push 0.16f0)
      (when (= (the fixnum core) 2)
        (fx-crescent x0 (- y dy) z0 x1 (+ y dy) z1 (+ bx (* ahead fx)) y (+ bz (* ahead fz)) (* 0.06f0 w) :lens 0.05f0 (+ 320f0 dr)
                     +pal-blood+ k :push 0.13f0)))
    nil))

(defun-fast vfx-ic-chain (x0 y0 z0 x1 y1 z1 k)
  "A blood chain from (x0 y0 z0) to (x1 y1 z1): an ink line of links (shards turned alternately), a BLOOD core, presence K."
  (with-floats (x0 y0 z0 x1 y1 z1 k)
    (let* ((dx (- x1 x0)) (dy (- y1 y0)) (dz (- z1 z0)) (l (f-max 0.01f0 (f-hypot dx dy dz)))
           (ux (/ dx l)) (uy (/ dy l)) (uz (/ dz l)) (n (min 40 (max 2 (f->i (/ l 0.14f0))))) (dr (drawing-no)))
      (declare (single-float dx dy dz l ux uy uz dr) (fixnum n))
      (dotimes (i n)
        (let* ((u (/ (+ 0.5f0 (i->f i)) (i->f n))) (px (+ x0 (* u dx))) (py (+ y0 (* u dy))) (pz (+ z0 (* u dz))))
          (declare (single-float u px py pz))
          (fx-shard px py pz ux uy uz 0.16f0 (if (evenp i) 0.045f0 0.02f0) 0.05f0 (+ (i->f i) 400f0 dr) +pal-ink+ k)
          (when (evenp i) (fx-shard px py pz ux uy uz 0.08f0 0.012f0 0.05f0 (+ (i->f i) 460f0) +pal-blood+ k :push 0.14f0)))))
    nil))

(defun ichigo-at (x z)
  "The fighter standing at (X Z) (an aura's own: DRAW-FIGHTER passes his feet), or NIL."
  (dolist (e (list *p1* *p2*))
    (when (and e (entity-alive-p e) (fighter e))
      (let ((p (pos-of e))) (when (and (< (abs (- (aref p 0) x)) 1e-3) (< (abs (- (aref p 2) z)) 1e-3)) (return e))))))

(declaim (type f32vec *ic-v* *ic-w*))
(defvar *ic-v* (make-f32 3) "A world point (a chain's anchor).")
(defvar *ic-w* (make-f32 3) "A world point (a chain's end).")

(defun ic-joint (e j &optional (out *ic-v*) (lx 0f0) (ly 0f0) (lz 0f0))
  "OUT = the world point of E's joint J (a local offset LX LY LZ)."
  (joint-point! out (model-joints (model e)) j lx ly lz) out)

;;; the hazards' draw functions (HAZARD-DRAW: (fn hazard rdt))
(defun ic-wave-k (hz)
  "A flying crescent's presence: whole while it flies, eroding over its last 8 f (and gone once spent)."
  (min 0.95 (/ (max 0 (- (hazard-life hz) (hazard-age hz))) 8.0)))

(defun ichigo-getsuga-look (hz rdt)
  "GETSUGA TENSHO: the ink crescent, its white rim, as wide as its hit box."
  (declare (ignore rdt))
  (when (<= (hazard-delay hz) 0)
    (vfx-ic-crescent (hazard-x hz) 1.2 (hazard-z hz) (hazard-yaw hz) (* 2 (hazard-size hz)) (ic-wave-k hz) 0.9 0)))

(defun ichigo-juji-look (hz rdt)
  "GETSUGA JUJISHO: the two crescents crossed into an X."
  (declare (ignore rdt))
  (when (<= (hazard-delay hz) 0)
    (let ((k (ic-wave-k hz)) (w (* 2 (hazard-size hz))))
      (vfx-ic-crescent (hazard-x hz) 1.1 (hazard-z hz) (hazard-yaw hz) w k 0.8 0)
      (vfx-ic-crescent (hazard-x hz) 1.1 (hazard-z hz) (hazard-yaw hz) w k -0.8 0))))

(defun ichigo-form-look (hz rdt)
  "JUJISHO's first crescent forming on the long blade before the fusion."
  (declare (ignore rdt))
  (vfx-ic-crescent (hazard-x hz) 1.2 (hazard-z hz) (hazard-yaw hz) (* (hazard-size hz) (min 1.0 (/ (hazard-age hz) 4.0)))
                   0.9 0.8 0))

(defun ichigo-charge-look (hz rdt)
  "NS2's charge: a small crescent riding each charged blade (HAZARD-DATA: (joint lx ly lz) ...), while its owner is still in the charge
or its SA (gone the moment he is hit or the string moves on)."
  (declare (ignore rdt))
  (let* ((e (hazard-owner hz)) (f (and (entity-alive-p e) (fighter e))) (mv (and f (fighter-move f))))
    (when (and mv (eq (fighter-state f) :move) (member (mv-name mv) '(:ic-n2a :ic-n2b :ic-sa-g1 :ic-sa-g2)))
      (let ((k (* (min 1.0 (/ (1+ (hazard-age hz)) 6.0)) (+ 0.75 (* 0.15 (sin (* 0.5 (hazard-age hz))))))))
        (dolist (b (hazard-data hz))
          (destructuring-bind (j lx ly lz) b
            (let ((v (ic-joint e (joint-index j) *ic-v* (f32 lx) (f32 ly) (f32 lz))))
              (vfx-ic-crescent (aref v 0) (aref v 1) (aref v 2) (yaw-of e) 1.4 k 0.8 0))))))))

(defun ichigo-flare-look (hz rdt)
  "KUSARI-TATE: the chains flaring out of his neck, wrists and ankles (the parry's tell)."
  (declare (ignore rdt))
  (let ((e (hazard-owner hz)))
    (when (and (entity-alive-p e) (fighter e))
      (let ((k (max 0.02 (- 0.95 (* 0.045 (hazard-age hz))))) (g (min 1.0 (/ (1+ (hazard-age hz)) 3.0))) (p (pos-of e)))
        (loop for j in '(:neck :hand-r :hand-l :foot-r :foot-l)
              do (let* ((v (ic-joint e (joint-index j))) (x (aref v 0)) (y (aref v 1)) (z (aref v 2))
                        (dx (- x (aref p 0))) (dz (- z (aref p 2))) (l (max 0.05 (hypot dx dz)))
                        (r (* 0.9 g)))
                   (vfx-ic-chain x y z (+ x (* r (/ dx l))) (+ y (* 0.3 g)) (+ z (* r (/ dz l))) k)))))))

;;; the clones, their bursts, the afterimages (their data: ichigo.lisp ICC / ICE)
(defvar *ic-clone-anim* (vector (make-anim) (make-anim)) "Per side: the clone's anim (posed afresh for each drawing).")
(defvar *ic-clone-joints* (vector (make-f32 (* +nj+ 16)) (make-f32 (* +nj+ 16))) "Per side: its posed joints.")

(defvar *ic-clone-rim* nil "The clones' BLOOD rim (RIM-VEC, made at load in the art file).")
(setf *ic-clone-rim* (rim-vec #xD0101C 1.4))

(defvar *ic-mist-tint* (hexc #x1E1E1E) "The clones' grey-black cast (the user 2026-09-29: a hazy grey-black phantom).")
(defvar *ic-mist-rim* nil "The clones' rim: a white edge light round the grey phantom (the user 2026-09-29; RIM-VEC, made at load).")
(setf *ic-mist-rim* (rim-vec #xFFFFFF 1.6))

(defun ic-mist (x z alpha seed)
  "Grey-black mist rising off a phantom at (X Z): six soft wisps climbing from its feet past its head, widening and fading."
  (let ((clk (fx-clock)))
    (dotimes (i 6)
      (let* ((ph (mod (+ (* 0.5 clk) (/ i 6.0) (* 0.13 seed)) 1.0)) (a (+ (* 2.1 i) seed (* 0.6 clk)))
             (r (+ 0.18 (* 0.2 ph))) (x0 (+ x (* r (cos a)))) (z0 (+ z (* r (sin a)))) (y0 (+ 0.1 (* 1.9 ph)))
             (k (* alpha 0.8 (sin (* pi ph)))))
        (fx-line x0 y0 z0 (+ x0 (* 0.15 (cos (+ a 1.0)))) (+ y0 0.55) (+ z0 (* 0.15 (sin (+ a 1.0))))
                 (+ 0.25 (* 0.3 ph)) 0.2 0.2 0.21 k :end-width (+ 0.45 (* 0.4 ph)) :end-alpha 0.0 :mode :alpha)))))

(defun ic-ghost (hz clip tm alpha rim &key (mist nil))
  "Draw KESSA's body at HZ's spot and facing, posed at time TM of CLIP, at ALPHA; RIM: a BLOOD ring at its feet. MIST (a
clone): a grey-black phantom with no clear outline (drawn twice, the second copy drifting a few cm, the dull rim) and mist
rising off it; else pale (an echo)."
  (let* ((o (hazard-owner hz)) (side (if (and (entity-alive-p o) (fighter o)) (fighter-side (fighter o)) 0))
         (an (svref *ic-clone-anim* side)) (jm (svref *ic-clone-joints* side)) (b (find-body :ichigo))
         (x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (hide (svref (hide-set '(:shikai :mark)) 0)))
    (anim-play an clip :blend 0 :time (f32 (max 0.0 tm)))
    (flet ((copy (x z a)
             (pose-fk! jm (anim-eval an) (f32 x) 0f0 (f32 z) (f32 yaw) (body-scale b) (body-hunch b) (body-props b))
             (if mist
                 (draw-body b jm x 0.0 z yaw :weapon :tensa :hide hide :alpha (f32 a) :tint *ic-mist-tint* :flash 0.25
                                             :shadow nil :rim *ic-mist-rim*)
                 (draw-body b jm x 0.0 z yaw :weapon :tensa :hide hide :alpha (f32 a) :flash 0.35 :shadow nil
                                             :rim *ic-clone-rim*))))
      (cond (mist (let* ((clk (fx-clock)) (dx (* 0.06 (sin (* 5.0 clk)))) (dz (* 0.06 (cos (* 4.0 clk)))))
                    (copy x z (* 0.75 alpha))
                    (copy (+ x dx) (+ z dz) (* 0.4 alpha))
                    (ic-mist x z alpha (hazard-x hz))))
            (t (copy x z alpha))))
    (when rim (with-floats (x z alpha) (%tring x 0f0 z 0.55f0 0.04f0 +pal-blood+ (* 1.8f0 alpha) 3f0 24)))))

(defun ichigo-clone-look (hz rdt)
  "分身 a clone: a grey-black phantom of KESSA at alpha 0.45, mist rising off it (IC-GHOST :mist), a BLOOD ring at its feet: idle in the stance, turning to
him; answering, the answer's clip at its frame; charging, the run; fading over its last 20 f / 8 f."
  (declare (ignore rdt))
  (let* ((c (hazard-data hz)) (st (icc-state c)) (age (/ (hazard-age hz) 60.0))
         (a (* 0.45 (min 1.0 (/ (max 0 (icc-life c)) 20.0)) (min 1.0 (/ (hazard-age hz) 6.0)))))
    (case st
      (:answer (let ((mv (icc-mv c))) (ic-ghost hz (mv-clip mv) (/ (* (max 0 (icc-sf c)) (mv-clip-speed mv)) 60.0) (max a 0.3) t :mist t)))
      (:charge (ic-ghost hz :sh-run (* 1.5 age) 0.6 t :mist t))
      (:fade (ic-ghost hz :ic-k-stance age (* 0.45 (max 0.0 (- 1.0 (/ (icc-fade c) 8.0)))) nil :mist t))
      (t (ic-ghost hz :ic-k-stance age a t :mist t)))))

(defun ichigo-echo-look (hz rdt)
  "残像 an afterimage: his move replayed behind him, alpha 0.35, pale, no ring."
  (declare (ignore rdt))
  (let* ((d (hazard-data hz)) (mv (ice-mv d)) (clip (if (eq (mv-kind mv) :kikon) (mv-clip-2 mv) (mv-clip mv))))
    (when (>= (ice-sf d) 0)
      (ic-ghost hz clip (/ (* (ice-sf d) (mv-clip-speed mv)) 60.0) (* 0.35 (min 1.0 (/ (- (ice-end d) (ice-sf d)) 6.0))) nil))))

(defun-fast ichigo-burst-look (hz rdt)
  "A clone bursting (O's charge) or puffing out (he was hit): ink shards and white, BLOOD sparks."
  (declare (ignore rdt))
  (let* ((x (hazard-x hz)) (z (hazard-z hz)) (s (hazard-size hz)) (age (hazard-age hz)) (k (max 0.02 (- 1.0 (/ age 16.0)))))
    (with-floats (x z s k)
      (fx-disc x 1.0f0 z (* s (+ 0.5f0 (* 0.08f0 (i->f age)))) 0.2f0 (+ 700f0 x) +pal-ink+ k)
      (fx-disc x 1.0f0 z (* s 0.35f0) 0.1f0 710f0 +pal-hit+ (* 0.8f0 k) :push 0.3f0)
      (when (< age 3)
        (dotimes (i 10)
          (let ((a (* 0.628f0 (i->f i))))
            (%t-shard x 1.0f0 z (* 5f0 s (f-cos a)) (rnd-range 0.5f0 3f0) (* 5f0 s (f-sin a)) 0.35f0 (rnd-range 0.03f0 0.07f0)
                      4f0 (if (evenp i) +pal-ink+ +pal-blood+))))))))

(defun-fast ichigo-zanzo-look (hz rdt)
  "残像 on: a pale ring round his feet, a white wisp peeling off him now and then."
  (let* ((e (hazard-owner hz)))
    (when (and (entity-alive-p e) (fighter e))
      (let* ((p (pos-of e)) (x (aref p 0)) (z (aref p 2))
             (k (* 0.6 (min 1.0 (/ (- (hazard-life hz) (hazard-age hz)) 30.0)))))
        (with-floats (x z k rdt)
          (%tring x 0f0 z 0.7f0 0.03f0 +pal-hit+ k 5f0 24)
          (when (< (rnd01) (* 6f0 rdt))
            (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) (rnd-range 0.4f0 1.6f0) (+ z (rnd-range -0.3f0 0.3f0))
                     0f0 0.4f0 0f0 0.5f0 (rnd-range 0.04f0 0.07f0) -0.1f0 0.05f0 +pal-hit+)))))))

;;; the auras (DRAW-AURA: (fn x y z h k dt))
(defun ichigo-aura-base (x y z h k dt)
  "The Shikai: no aura; SOGA's and TSUKIWATARI's flash steps leave the ink afterimages (TENCHI's) over their startup."
  (declare (ignore y h k dt))
  (let* ((e (ichigo-at x z)) (f (and e (fighter e))) (mv (and f (eq (fighter-state f) :move) (fighter-move f))))
    (when (and mv (member (mv-name mv) '(:ic-soga :ic-tsuki-dash)) (eq (fighter-phase f) :main) (< (fighter-sf f) (mv-s mv))
               (zerop (mod (fighter-sf f) 4)))
      (start-ghost e))))

(defun-fast ichigo-aura-kessa (x y z h k dt)
  "KESSA: a smoulder of dark blood wisps at the neck, wrists and ankles (never a pillar: the Kikon's BLOOD stays the tell;
a trace in his own Kikon rush)."
  (declare (ignore y h))
  (let* ((e (ichigo-at x z)) (f (and e (fighter e))) (mv (and f (eq (fighter-state f) :move) (fighter-move f)))
         (kk (if (and mv (eq (mv-kind mv) :kikon)) (* 0.2 k) k)))
    (when e
      (with-floats (dt kk)
        (dolist (j '(:neck :hand-r :hand-l :shin-r :shin-l))
          (let ((v (ic-joint e (joint-index j))))
            (when (< (rnd01) (* 3f0 dt kk))
              (%t-blob (aref v 0) (aref v 1) (aref v 2) (rnd-range -0.2f0 0.2f0) (rnd-range 0.3f0 0.7f0) (rnd-range -0.2f0 0.2f0)
                       (rnd-range 0.3f0 0.5f0) (rnd-range 0.02f0 0.035f0) -0.1f0 0.05f0 +pal-blood+))))))))

;;; ---------------------------------------------------------------- the cloak and the impact looks (his :pose / :draw hooks)
;;; DUEL_ICHIGO_TYBW §3.1 / §3.3, cosmetic: the sim never reads a joint or a look; no random number but the shared
;;; debris's; 0 B a frame (debug 74906). ICHIGO-CLOAK-POSE swings the Shikai's pelvis (the white cloak hangs on it) by Yamamoto's
;;; hem spring (yama-art.lisp %YA-HEM-POSE / %YA-HEM-STEP and their knobs *YA-HEM-*: the cloak trails his travel and turns,
;;; overshoots once when he stops, breathes while he stands). ICHIGO-DRAW steps it and draws, per move named in
;;; *IC-EDGE-MOVES*, 月牙の残光 the crescent edge: through each hit window (from 2 f before it to 4 f after), an ink
;;; crescent from the drawn blade's tip out to the hit volume's edge (reached on the hit frame), bulging along the tip's
;;; travel (the cut), a white rim (KESSA: a BLOOD hairline); and, on the hit frame of *IC-GROUND-MOVES*, the plaza's crack
;;; and rubble where the tip meets it (or at the volume's far end) and a short shake, once a move.
(defparameter *ic-edge-moves*
  '((:ic-k1) (:ic-k2) (:ic-k3) (:ic-k2s) (:ic-tsuki-j 0 2) (:ic-tsuki-k) (:ic-soga) (:ic-kikon) (:ic-breaker)
    (:ic-k-k1) (:ic-k-k2) (:ic-k-k3) (:ic-k-gaeshi) (:ic-k-kikon) (:ic-c-heavy) (:ic-c-heavy3))
  "The crescent edge's moves: (move hit-index ...), the listed windows (0-based) cut by the short blade (its point, the
:weapon-l joint's (0 -0.90 0)), every other by the held blade's tip. New 2026-10-14 (DUEL_ICHIGO_TYBW §3.3, the lead's).
(The clones' :ic-c-* are drawn by ICHIGO-CLONE-LOOK: listed for a hook that sees them, none does yet.)")
(defparameter *ic-ground-moves* '(:ic-k3 :ic-tsuki-k :ic-k-k3 :ic-k-gaeshi)
  "The moves whose first hit frame cracks the plaza (STAGE-MARK :crack, STAGE-DEBRIS, SHAKE). New 2026-10-14 (§3.3).")
(defparameter *ic-edge-w* 0.12 "The crescent's half-width per m of its span (0.08-0.2 m).")
(defparameter *ic-edge-bulge* 0.28 "Its bulge along the cut per m of span.")

(declaim (type f32vec *ic-look* *ic-tip* *ic-tip-l* *ic-far*))
(defvar *ic-look* (make-f32 64)
  "Per side (32 floats): [0..15] the cloak spring (%YA-HEM-POSE / -STEP's layout), [16..18] the held blade's tip at the last
draw, [19..21] the short blade's, [22..24] the held tip's cut direction (unit), [25..27] the short's, [28] the move frame
of the last draw (-1: none).")
(defvar *ic-tip* (make-f32 3) "ICHIGO-DRAW's held blade's tip.")
(defvar *ic-tip-l* (make-f32 3) "... and the short blade's point.")
(defvar *ic-far* (make-f32 5) "The hit volume's far point (%IC-FAR), [3] the crescent's growth, [4] its presence.")

(defun ichigo-cloak-pose (e m)
  "KIT-HOOK :pose (the Shikai): the cloak's swing on the posed pelvis."
  (%ya-hem-pose (model-joints m) *ic-look* (* 32 (fighter-side (fighter e))) 1))

(defun-fast %ic-frame (st i sf)
  "ST[I] = the move frame SF; the frame it held before (a fixnum)."
  (declare (type f32vec st) (fixnum i sf))
  (prog1 (f->i (aref st i)) (setf (aref st i) (i->f sf))))

(defun-fast %ic-held-tip (jm tip len)
  "TIP = the held weapon's tip: the :weapon-r joint's point (0 0 -LEN), JOINT-POINT!'s sum inline (BODY-WEAPON-TIP's
call boxes the float)."
  (declare (type f32vec jm tip) (single-float len))
  (let ((o (* 16 (ji :weapon-r))))
    (declare (fixnum o))
    (dotimes (i 3) (setf (aref tip i) (- (aref jm (+ o 12 i)) (* len (aref jm (+ o 8 i)))))))
  nil)

(defun-fast %ic-track (st o d tip)
  "Track a blade's tip: ST[O..O+2] its last point; ST[D..D+2] the unit direction it last moved in (kept while it stands,
or across a jump over 1.5 m)."
  (declare (type f32vec st tip) (fixnum o d))
  (let* ((x (aref tip 0)) (y (aref tip 1)) (z (aref tip 2))
         (dx (- x (aref st o))) (dy (- y (aref st (+ o 1)))) (dz (- z (aref st (+ o 2)))) (l (f-hypot dx dy dz)))
    (declare (single-float x y z dx dy dz l))
    (when (and (> l 0.01f0) (< l 1.5f0))
      (setf (aref st d) (/ dx l) (aref st (+ d 1)) (/ dy l) (aref st (+ d 2)) (/ dz l)))
    (setf (aref st o) x (aref st (+ o 1)) y (aref st (+ o 2)) z))
  nil)

(defun-fast %ic-far (v p yaw tip out)
  "OUT = the far point of hit volume V for a fighter at P (his feet) facing YAW: an arc's rim on the bearing of TIP, a
capsule's end, a sphere's far side; its height the tip's, clamped to 0.1-1.5 m (a sphere's: its centre). NIL for none.
(No float crosses a call here or below: a boxed argument is a cons.)"
  (declare (type f32vec v p tip out) (single-float yaw))
  (let ((ty (f-clamp (aref tip 1) 0.1f0 1.5f0)) (k (aref v 0))
        (px (aref p 0)) (pz (aref p 2)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
    (declare (single-float ty k px pz fx fz))
    (cond ((< k 0.5f0)
           (let* ((bx (- (aref tip 0) px)) (bz (- (aref tip 2) pz)) (l (f-hypot bx bz)) (r (aref v 1)))
             (declare (single-float bx bz l r))
             (if (< l 0.05f0) (setf bx fx bz fz) (setf bx (/ bx l) bz (/ bz l)))
             (setf (aref out 0) (+ px (* r bx)) (aref out 1) ty (aref out 2) (+ pz (* r bz)))
             t))
          ((< k 1.5f0)
           (let* ((yo (aref v 5)) (c (f-cos yo)) (sn (f-sin yo))
                  (ux (+ (* fx c) (* fz sn))) (uz (- (* fz c) (* fx sn))) (b (aref v 2)))
             (declare (single-float yo c sn ux uz b))
             (setf (aref out 0) (+ px (* b ux)) (aref out 1) ty (aref out 2) (+ pz (* b uz)))
             t))
          ((< k 2.5f0)
           (let ((d (+ (aref v 1) (aref v 3))))
             (declare (single-float d))
             (setf (aref out 0) (+ px (* d fx)) (aref out 1) (aref v 2) (aref out 2) (+ pz (* d fz)))
             t))
          (t nil))))

(defun-fast %ic-edge (st d tip far blood)
  "The crescent edge from TIP toward FAR (FAR[3] the fraction of the way, FAR[4] its presence), bulging along the cut
direction ST[D..D+2]: an ink lens, a white rim on its leading side (BLOOD 1: a BLOOD hairline)."
  (declare (type f32vec st tip far) (fixnum d blood))
  (let* ((g (aref far 3)) (k (aref far 4)) (x0 (aref tip 0)) (y0 (aref tip 1)) (z0 (aref tip 2))
         (x1 (+ x0 (* g (- (aref far 0) x0)))) (y1 (+ y0 (* g (- (aref far 1) y0)))) (z1 (+ z0 (* g (- (aref far 2) z0))))
         (cx (- x1 x0)) (cy (- y1 y0)) (cz (- z1 z0)) (span (f-hypot cx cy cz)))
    (declare (single-float g k x0 y0 z0 x1 y1 z1 cx cy cz span))
    (when (> span 0.15f0)
      (let* ((ux (/ cx span)) (uy (/ cy span)) (uz (/ cz span))
             (dx (aref st d)) (dy (aref st (+ d 1))) (dz (aref st (+ d 2))) (du (+ (* dx ux) (* dy uy) (* dz uz)))
             (px (- dx (* du ux))) (py (- dy (* du uy))) (pz (- dz (* du uz)))   ; the cut, across the chord
             (b (* (the single-float (f32 *ic-edge-bulge*)) span))
             (w (f-clamp (* (the single-float (f32 *ic-edge-w*)) span) 0.08f0 0.2f0))
             (mx (* 0.5f0 (+ x0 x1))) (my (* 0.5f0 (+ y0 y1))) (mz (* 0.5f0 (+ z0 z1)))
             (dr (drawing-no)))
        (declare (single-float ux uy uz dx dy dz du px py pz b w mx my mz dr))
        (fx-crescent x0 y0 z0 x1 y1 z1 (+ mx (* b px)) (f-max 0.05f0 (+ my (* b py))) (+ mz (* b pz)) w :lens 0.05f0
                     (+ 330f0 dr) +pal-ink+ k :push 0.1f0)
        (let ((a (* 0.6f0 w)))                                                       ; the rim, a little ahead
          (declare (single-float a))
          (fx-crescent (+ x0 (* a px)) (+ y0 (* a py)) (+ z0 (* a pz)) (+ x1 (* a px)) (+ y1 (* a py)) (+ z1 (* a pz))
                       (+ mx (* (+ b a) px)) (f-max 0.05f0 (+ my (* (+ b a) py))) (+ mz (* (+ b a) pz))
                       (if (= blood 1) (* 0.12f0 w) (* 0.25f0 w)) :lens 0.03f0 (+ 340f0 dr)
                       (if (= blood 1) +pal-blood+ +pal-hit+) k :push 0.16f0)))))
  nil)

(defun-fast %ic-hit-look (st d v p yaw tip sf from to blood ground)
  "One hit window's looks at move frame SF (window FROM-TO, volume V; the fighter's feet P, facing YAW): the crescent edge
from TIP (its cut direction ST[D..]) grown over the 3 f to FROM, fading over the 4 f after TO; GROUND 1: the plaza's
crack, rubble and a shake where TIP meets it (under 0.4 m), else at the volume's far point."
  (declare (type f32vec st v p tip) (fixnum d sf from to blood ground))   ; (YAW passed on as it came)
  (let ((far *ic-far*))
    (when (%ic-far v p yaw tip far)
      (setf (aref far 3) (f-min 1f0 (/ (i->f (- sf (- from 3))) 3f0))
            (aref far 4) (* 0.9f0 (if (< sf to) 1f0 (/ (i->f (- (+ to 4) sf)) 4f0))))
      (%ic-edge st d tip far blood)
      (when (= ground 1)
        (let* ((low (< (aref tip 1) 0.4f0)) (gx (if low (aref tip 0) (aref far 0))) (gz (if low (aref tip 2) (aref far 2))))
          (declare (single-float gx gz))
          (stage-mark :crack gx gz 0.9f0) (stage-debris gx gz 4) (shake 0.06f0 0.15f0)))))
  nil)

(defun ichigo-draw (e rdt)
  "KIT-HOOK :draw (both forms): step the Shikai's cloak spring; the crescent edge and the ground contact (§3.3)."
  (let* ((f (fighter e)) (m (model e)) (o (* 32 (fighter-side f))) (st *ic-look*)
         (kessa (eq (kit-form (fighter-kit f)) :kessa))
         (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (sf (if mv (fighter-sf f) -1)) (prev (%ic-frame st (+ o 28) sf))
         (edge (and mv (assoc (mv-name mv) *ic-edge-moves*))))
    (declare (fixnum o sf prev))
    (unless kessa (%ya-hem-step st o (if (typep rdt 'single-float) rdt (f32 rdt))))   ; (F32 inline re-boxes)
    (when (and edge (model-weapon m) (> (model-alpha m) 0.5))
      (let ((jm (model-joints m)) (tip *ic-tip*) (tip-l *ic-tip-l*) (hits (mv-hits mv)))
        (declare (simple-vector hits))
        (when (rest edge)                                                       ; the short blade's point
          (joint-point! tip-l jm (ji :weapon-l) 0f0 -0.9f0 0f0)
          (%ic-track st (+ o 19) (+ o 25) tip-l))
        (%ic-held-tip jm tip (weapon-len (find-weapon (model-weapon m))))
        (%ic-track st (+ o 16) (+ o 22) tip)
        (dotimes (i (length hits))
          (let* ((hw (svref hits i)) (from (hw-from hw)) (to (hw-to hw)) (v (first (hw-vols hw))) (short (member i (rest edge))))
            (declare (fixnum from to))
            (when (and v (<= (- from 2) sf) (< sf (+ to 4)))
              (%ic-hit-look st (if short (+ o 25) (+ o 22)) v (pos-of e) (yaw-of e) (if short tip-l tip) sf from to
                            (if kessa 1 0)
                            (if (and (= i 0) (< prev from) (<= from sf) (member (mv-name mv) *ic-ground-moves*)) 1 0)))))))))

(defun ichigo-look-cons-check ()
  "Debug 74906 (P1 Ichigo, e.g. after 74000): bytes consed by 10 calls each of ICHIGO-CLOAK-POSE and ICHIGO-DRAW standing, and
of ICHIGO-DRAW frozen in K1's and RANGETSU's first hit frame (the cloak step, the tips, the crescent edge; the short blade's
point in RANGETSU). Each must be 0."
  (let* ((e *p1*) (f (fighter e)) (m (model e))
         (st (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f)) (sf (fighter-sf f)))
    (flet ((bytes (thunk) (let ((c0 (cons-bytes))) (dotimes (i 10) (funcall thunk)) (- (cons-bytes) c0)))
           (at (name) (let ((x (find-move name)))
                        (setf (fighter-state f) :move (fighter-move f) x (fighter-phase f) :main
                              (fighter-sf f) (hw-from (svref (mv-hits x) 0))))))
      (let* ((pose (bytes (lambda () (ichigo-cloak-pose e m))))
             (idle (bytes (lambda () (ichigo-draw e 0.016))))
             (k1 (progn (at :ic-k1) (bytes (lambda () (ichigo-draw e 0.016)))))
             (rg (progn (at :ic-tsuki-j) (bytes (lambda () (ichigo-draw e 0.016))))))
        (setf (fighter-state f) st (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf)
        (log-msg "duel ichigo look consing (10 calls, B): pose ~d, draw ~d, draw K1 hit ~d, draw RANGETSU hit ~d"
                 pose idle k1 rg)))))

;;; ---------------------------------------------------------------- sounds (docs/duel/DUEL_ICHIGO.md §10)
(defsound :chain-rattle (:peak 0.7)                    ; link clatter: the parry, the wall, a chain shot
  (let ((b (au-buf 0.6)))
    (dotimes (i 18)
      (let ((at (au-rrange 0.0 0.35)))
        (au-ping! b at (au-rrange 1800 4200) (au-rrange 0.02 0.05) (au-rrange 0.2 0.45) :attack 0.001)
        (au-mix! b (au-fnoise 0.02 :bp (au-rrange 2500 6000) :q 3 :decay 0.008) at 0.3)))
    (au-reverb! b 0.2)))

(defsound :chain-snap (:peak 0.85)                     ; a taut snap: a catch, the yank, the pull's hit
  (let ((b (au-buf 0.5)))
    (au-mix! b (au-fnoise 0.03 :bp 3000 :q 2 :decay 0.01) 0.0 1.0)
    (au-ping! b 0.0 2600 0.06 0.5 :attack 0.001)
    (au-ping! b 0.01 3900 0.04 0.35 :attack 0.001)
    (au-thump! b 0.0 140 60 0.02 0.08 0.5)
    (au-reverb! b 0.15)))

(defsound :getsuga (:peak 0.9)                         ; a deep tearing whoosh with a low resonance (every crescent)
  (let ((b (au-buf 1.1)))
    (au-mix! b (au-whoosh 0.6 200 5000 :q 1.1 :peak 0.25) 0.0 0.9)
    (au-mix! b (au-fnoise 0.4 :bp 900 :q 1.5 :decay 0.2) 0.1 0.5)
    (au-thump! b 0.12 70 40 0.1 0.35 0.7)
    (au-partials! b 0.1 '((110 0.4 0.6) (165 0.25 0.5)))
    (au-reverb! b 0.3 :size 1.2)))

(defsound :clone (:peak 0.6)                           ; a glassy shimmer: a clone appears / slashes
  (let ((b (au-buf 0.7)))
    (au-mix! b (au-whoosh 0.4 2000 9000 :q 2.0 :peak 0.3) 0.0 0.5)
    (loop for f in '(1568 2093 2637) for i from 0 do (au-ping! b (* 0.05 i) f 0.3 0.3 :attack 0.02))
    (au-reverb! b 0.35 :size 1.3)))

(defsound :parry-ting (:peak 0.9)                      ; the catch: a bright high kiin (3.2 kHz + a 6.4 kHz partial)
  (let ((b (au-buf 0.8)))
    (au-ping! b 0.0 3200 0.6 0.9 :attack 0.001)
    (au-ping! b 0.0 6400 0.35 0.4 :attack 0.001)
    (au-ping! b 0.005 4800 0.2 0.25 :attack 0.001)
    (au-mix! b (au-fnoise 0.02 :bp 7000 :q 2 :decay 0.006) 0.0 0.5)
    (au-reverb! b 0.35 :size 1.4)))

(defsound :parry-open (:peak 0.4)                      ; the window opens: a soft rising shimmer, 0.3 s
  (let ((b (au-buf 0.4)))
    (au-mix! b (au-whoosh 0.3 1500 6000 :q 2.5 :peak 0.2) 0.0 0.5)
    (loop for f in '(2093 2637 3136) for i from 0 do (au-ping! b (* 0.06 i) f 0.18 0.2 :attack 0.02))
    (au-reverb! b 0.25)))

;;; ---------------------------------------------------------------- brush names, callouts and glyphs
(setf *brush-names* (append *brush-names* '((:ichigo "黒崎一護" "KUROSAKI ICHIGO")))
      *brush-callouts*
      (append *brush-callouts*
              '((:ic-tsuki-l "月牙天衝" "GETSUGA TENSHO" nil)
                (:ic-juji "月牙十字衝" "GETSUGA JUJISHO" nil) (:ic-soga "双牙" "SOGA" nil)
                (:ic-k-hiki "鎖引" "KUSARI-BIKI" "血") (:ic-k-gaeshi "鎖盾" "KUSARI-TATE" "血")
                (:ic-k-zanzo "残像" "ZANZO" "血"))))

;; his extra brush glyphs (黒 崎 一 護 牙 衝 字 血 鎖 双 引 垣 王 虚 漆 影 待 分 身 像): glyphs-extra.lisp


;;; ---------------------------------------------------------------- cinematics (§5, §6; unskippable, SHOT-ON framed)
;; 王虚の閃光を込めた月牙天衝, the Shikai's Kikon (v2 §3, the three reference frames): the cinematic-only palette, the
;; user's decision (2026-09-29): gold on the raised blade, red and pink-violet on the Cero Getsuga; in play the Getsuga
;; stays mono
(defparameter +ic-gold+ '(1.0 0.76 0.23) "The Cero's gold rim #FFC23A (its core #FFF6D0).")
(defparameter +ic-violet+ '(0.75 0.25 0.91) "The pink-violet glow #C040E8.")
(defparameter +ic-cero-core+ '(0.35 0.04 0.06) "The ring's dark blood-red disc #5A0A10.")

(defun ic-rgb (c) (values (f32 (first c)) (f32 (second c)) (f32 (third c))))

(defun ic-blade (e)
  "Fill *IC-V* / *IC-W* with E's held blade's base and tip."
  (let ((m (model e)))
    (body-weapon-base (model-body m) (model-weapon m) (model-joints m) *ic-v*)
    (body-weapon-tip (model-body m) (model-weapon m) (model-joints m) *ic-w*)))

(defun vfx-ic-orb (x y z r k)
  "The gold orb on the blade's tip: a white-yellow core in a gold-orange rim, its light."
  (multiple-value-bind (gr gg gb) (ic-rgb +ic-gold+)
    (fx-line x (- y r) z x (+ y r) z (* 1.4 r) gr gg gb (* 0.8 k))
    (fx-line x (- y (* 0.6 r)) z x (+ y (* 0.6 r)) z (* 0.8 r) 1.0 0.96 0.82 k)
    (%light (f32 x) (f32 y) (f32 z) gr gg gb 5f0 (f32 (* 2.5 k)) 8)))

(defun vfx-ic-thread (e x y z k)
  "The thread of reiatsu from his horn's tip to the orb (gold, pulsing brighter every 6 f)."
  (let ((h (ic-joint e (joint-index :head) *ic-v* -0.26 0.215 0.06)))
    (multiple-value-bind (gr gg gb) (ic-rgb +ic-gold+)
      (fx-line (aref h 0) (aref h 1) (aref h 2) x y z 0.012 gr gg gb k))))

(defun vfx-ic-hook (x y z yaw s k)
  "The orb burst into a hooked flame crescent curling back over the blade's tip: gold-orange, a red inner band; S m."
  (let* ((fx (fwd-x yaw)) (fz (fwd-z yaw)) (n 10))
    (multiple-value-bind (gr gg gb) (ic-rgb +ic-gold+)
      (dotimes (i n)
        (let* ((a0 (* 3.9 (/ i (float n)))) (a1 (* 3.9 (/ (1+ i) (float n))))   ; a curl of ~225 deg, back over the tip
               (r0 (* s 0.5 (- 1.0 (* 0.12 (/ i (float n)))))) (r1 (* s 0.5 (- 1.0 (* 0.12 (/ (1+ i) (float n))))))
               (x0 (+ x (* r0 (sin a0) (- fx)))) (y0 (+ y (* r0 (- 1.0 (cos a0))))) (z0 (+ z (* r0 (sin a0) (- fz))))
               (x1 (+ x (* r1 (sin a1) (- fx)))) (y1 (+ y (* r1 (- 1.0 (cos a1))))) (z1 (+ z (* r1 (sin a1) (- fz))))
               (w (* s 0.09 (sin (* 3.14 (/ (+ i 0.5) n))))))
          (fx-line x0 y0 z0 x1 y1 z1 (* 1.6 w) gr gg gb (* 0.9 k))
          (fx-line x0 y0 z0 x1 y1 z1 (* 0.6 w) 0.85 0.1 0.12 k :mode :alpha)))
      (%light (f32 x) (f32 (+ y (* 0.4 s))) (f32 z) gr gg gb 7f0 (f32 (* 2.2 k)) 8))))

(defun vfx-ic-flame-body (e k tm)
  "The gold-orange flame of reiatsu swallowing his whole body, 1.5x his height, its edges torn into points: tongues of
gold round him licking up, flickering with TM (the cinematic frame)."
  (let ((p (pos-of e)))
    (multiple-value-bind (gr gg gb) (ic-rgb +ic-gold+)
      (dotimes (i 28)
        (let* ((a (+ (* i 0.2244) (* 0.05 (sin (* 0.7 i))))) (r (+ 0.55 (* 0.25 (sin (+ (* 3.1 i) (* 0.2 tm))))))
               (y0 (* 2.2 (/ (mod (* 7 i) 11) 11.0))) (l (+ 0.7 (* 0.6 (abs (sin (+ (* 1.7 i) (* 0.35 tm)))))))
               (x0 (+ (aref p 0) (* r (cos a)))) (z0 (+ (aref p 2) (* r (sin a)))))
          (fx-line x0 y0 z0 (+ x0 (* 0.2 (cos a))) (+ y0 l) (+ z0 (* 0.2 (sin a))) 0.2 gr gg gb (* 0.55 k) :end-width 0.0)
          (fx-line x0 y0 z0 (+ x0 (* 0.1 (cos a))) (+ y0 (* 0.6 l)) (+ z0 (* 0.1 (sin a))) 0.09 1.0 0.95 0.8 (* 0.5 k)
                   :end-width 0.0))))
    (%light (aref p 0) 1.4f0 (aref p 2) 1.0f0 0.62f0 0.2f0 6f0 (f32 (* 2.0 k)) 8)))

(defun vfx-ic-red-blade (e k)
  "The gold drained out of the blade: the whole length a red slash in a pink-violet glow."
  (ic-blade e)
  (let ((b *ic-v*) (w *ic-w*))
    (multiple-value-bind (vr vg vb) (ic-rgb +ic-violet+)
      (fx-line (aref b 0) (aref b 1) (aref b 2) (aref w 0) (aref w 1) (aref w 2) 0.22 vr vg vb (* 0.7 k))
      (fx-line (aref b 0) (aref b 1) (aref b 2) (aref w 0) (aref w 1) (aref w 2) 0.07 0.82 0.06 0.11 k :mode :alpha)
      (%light (aref w 0) (aref w 1) (aref w 2) vr vg vb 5f0 (f32 (* 2.0 k)) 8))))

(defun vfx-ic-cero-ring (x y z ux uz rot k)
  "The Cero Getsuga: a ring 8 m across of violet reiatsu, a dark blood-red disc filling it, four gold spike-slashes on
its outside at the diagonals (a diamond); its plane faces along (UX UZ), turned ROT radians about it."
  (let* ((rx (- uz)) (rz ux) (n 32) (r 4.0))
    (flet ((pt (a rr) (values (+ x (* rr (cos a) rx)) (+ y (* rr (sin a))) (+ z (* rr (cos a) rz)))))
      (multiple-value-bind (cr cg cb) (ic-rgb +ic-cero-core+)
        (dotimes (i 48)                                   ; the disc: an overlapping fan of dark wedges
          (let ((a (+ rot (* i 0.1309))))
            (multiple-value-bind (x1 y1 z1) (pt a (* 0.95 r))
              (fx-line x y z x1 y1 z1 0.05 cr cg cb (* 0.95 k) :mode :alpha :end-width 0.9)))))
      (multiple-value-bind (vr vg vb) (ic-rgb +ic-violet+)
        (dotimes (i n)                                    ; the violet band
          (multiple-value-bind (x0 y0 z0) (pt (+ rot (* i (/ 6.2832 n))) r)
            (multiple-value-bind (x1 y1 z1) (pt (+ rot (* (1+ i) (/ 6.2832 n))) r)
              (fx-line x0 y0 z0 x1 y1 z1 0.5 vr vg vb (* 0.9 k) :mode :alpha)
              (fx-line x0 y0 z0 x1 y1 z1 0.25 vr vg vb (* 0.5 k))))))
      (multiple-value-bind (gr gg gb) (ic-rgb +ic-gold+)
        (dotimes (i 4)                                    ; the four gold spikes at the diagonals
          (let ((a (+ rot 0.785 (* i 1.5708))))
            (multiple-value-bind (x0 y0 z0) (pt (- a 0.3) (* 1.15 r))
              (multiple-value-bind (x1 y1 z1) (pt (+ a 0.3) (* 1.15 r))
                (multiple-value-bind (x2 y2 z2) (pt a (* 1.45 r))
                  (fx-line x0 y0 z0 x2 y2 z2 0.22 gr gg gb k :end-width 0.02 :mode :alpha)
                  (fx-line x1 y1 z1 x2 y2 z2 0.22 gr gg gb k :end-width 0.02 :mode :alpha)))))))
      (%light (f32 x) (f32 y) (f32 z) 0.75f0 0.25f0 0.91f0 10f0 (f32 (* 3.0 k)) 9))))

(defcine ic-kikon-cine (a v :len 186 :hold 150)
  "月牙天衝 with a Gran Rey Cero, the Shikai's Kikon (v2 §3; the reference's three beats): beat 0, the X held; a white card,
the 月牙天衝 / 王虚の閃光 stamp, silence; the raise, from low in front: the cleaver overhead one-handed, a gold orb growing
on its tip, a thread of light from the horn to it; the ignition: the orb bursts into a hooked flame crescent, his body
swallowed in gold flame, then the blade a red slash in a pink-violet glow; the swing; from behind and below him, the pale
pink sky and the Cero Getsuga: a violet ring round a dark blood-red disc, four gold spikes in a diamond; the impact;
the plaza back, violet ash drifting."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.6 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-juji-x :blend 2 :time 0.15) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-heavy :pitch 1.1))
  (at 12 (card :white a) (shot-on a 30 3.2 0.7 :look 1.1 :off -0.8) (lens 44 -8) (silence 58)
      (caption "月牙天衝" :kanji2 "王虚の閃光" :reading "GETSUGA TENSHO" :sub "GRAN REY CERO  KIKON" :side 1 :ink t :hanko t))
  (at 70 (card :black a) (caption-exit) (face-each-other a v 7.0) (shot-on a 40 4.6 0.5 :look 2.3) (lens 46)
      (cine-clip a :ic-cero-raise :blend 6) (play-sfx :awaken-rise :pitch 0.8))
  (during (70 100) (let ((q (pos-of a)) (yaw (yaw-of a)))   ; a violet haze at the frame's right edge
                     (multiple-value-bind (vr vg vb) (ic-rgb +ic-violet+)
                       (fx-line (+ (aref q 0) (* 3.0 (fwd-z yaw)) (* -2.0 (fwd-x yaw))) 0.5 (- (aref q 2) (* 3.0 (fwd-x yaw)) (* 2.0 (fwd-z yaw)))
                                (+ (aref q 0) (* 3.4 (fwd-z yaw)) (* -2.0 (fwd-x yaw))) 3.5 (- (aref q 2) (* 3.4 (fwd-x yaw)) (* 2.0 (fwd-z yaw)))
                                1.2 vr vg vb 0.25))))
  (during (80 100) (progn (ic-blade a)                     ; the orb on the tip, the thread from the horn
                          (let* ((w *ic-w*) (x (aref w 0)) (y (aref w 1)) (z (aref w 2)))
                            (vfx-ic-orb x y z (+ 0.05 (* 0.3 u)) 0.95)
                            (vfx-ic-thread a x y z (if (< (mod cf 6) 2) 0.95 0.55)))))
  (at 100 (lens 52) (play-sfx :getsuga :pitch 1.2) (play-sfx :awaken-boom :pitch 0.7 :gain 0.6))
  (during (100 128) (progn (ic-blade a)
                           (let* ((w *ic-w*) (k (if (< cf 116) 0.95 (max 0.1 (- 0.95 (* 0.08 (- cf 116)))))))
                             (vfx-ic-hook (aref w 0) (aref w 1) (aref w 2) (yaw-of a) 1.6 k))
                           (vfx-ic-flame-body a (if (< cf 120) 0.95 0.5) cf)
                           (when (>= cf 116) (vfx-ic-red-blade a (min 1.0 (/ (- cf 114) 6.0))))))
  (at 128 (card nil) (shot-on a 90 4.2 1.2 :look 1.3) (lens 46) (cine-clip a :ic-getsuga :blend 0 :time 0.2) (play-sfx :getsuga))
  (during (128 138) (vfx-ic-red-blade a 0.9))
  (at 132 (impact-frame :negative 2))
  (at 138 (card :white) (shot-on a 200 5.2 0.5 :look 2.6 :off 0.8) (lens 36) (play-sfx :explode :pitch 0.6)
      (let ((e *env*)) (v3-set! (env-sky-top e) 0.94f0 0.85f0 0.86f0) (v3-set! (env-fog-color e) 0.94f0 0.85f0 0.86f0)))
  (during (138 162) (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
                           (d (max 0.1 (hypot dx dz))) (uu (min 1.0 (/ (- cf 136) 22.0))))
                      (vfx-ic-cero-ring (+ (aref p 0) (* dx (+ 0.3 (* 0.7 uu)))) 2.4 (+ (aref p 2) (* dz (+ 0.3 (* 0.7 uu))))
                                        (/ dx d) (/ dz d) (* 0.14 (/ cf 60.0)) 0.95)))
  (at 160 (card nil) (shot-on v 150 5.0 1.2 :look 1.3) (lens 58) (impact-frame :negative 2)
      (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-konpaku-shatter x (+ y 0.1) z 2) (vfx-hit x (+ y 0.3) z :heavy))
      (impact-splash-at v 0.0 14 0.08)
      (play-sfx :getsuga :pitch 0.7) (play-sfx :konpaku-shatter) (shake 0.3 0.4))
  (at 162 (impact-frame :manga 12))
  (during (160 172) (let ((q (pos-of v)))                  ; the ring bursting on him
                      (vfx-ic-cero-ring (aref q 0) 2.0 (aref q 2) 1.0 0.0 0.0 (max 0.05 (- 0.9 (* 1.2 u))))))
  (at 172 (shot-on a 170 5.2 1.0 :look 1.2) (lens 48) (cine-clip a :ic-stance :blend 8))
  (during (172 186) (let ((q (pos-of v)))                  ; violet ash drifting
                      (when (< (rnd01) 0.5)
                        (%t-blob (+ (aref q 0) (rnd-range -2f0 2f0)) (rnd-range 0.5f0 3f0) (+ (aref q 2) (rnd-range -2f0 2f0))
                                 0f0 0.3f0 0f0 1.2f0 0.05f0 -0.05f0 0.1f0 +pal-ash+)))))

;; the cinematics' clones and the C (draw mode: posed and drawn one after another in one buffer)
(defun ic-body-at (x z yaw clip tm alpha &key (y 0.0))
  "A clone of KESSA at (X Y Z) facing YAW, posed at time TM of CLIP, at ALPHA: the grey-black phantom (IC-GHOST's :mist
look) in a cinematic."
  (let ((an (svref *ic-clone-anim* 0)) (jm (svref *ic-clone-joints* 0)) (b (find-body :ichigo)))
    (anim-play an clip :blend 0 :time (f32 (max 0.0 tm)))
    (pose-fk! jm (anim-eval an) (f32 x) (f32 y) (f32 z) (f32 yaw) (body-scale b) (body-hunch b) (body-props b))
    (draw-body b jm x y z yaw :weapon :tensa :hide (svref (hide-set '(:shikai :mark)) 0) :alpha (f32 alpha)
                              :tint *ic-mist-tint* :flash 0.12 :shadow nil :rim *ic-mist-rim*)   ; darker on a cinematic's black
    (ic-mist x z (* 0.6 alpha) (+ x z))))

(defun ic-c-point (px pz ux uz d th)
  "Values x y z of the C at angle TH (radians from its near point, over the top): the vertical ellipse in the plane of
the line from (PX PZ) along (UX UZ), its near side at P, its far side D metres out, 3.2 m tall about h 2.4; under the
plaza it runs along the ground (the crack)."
  (let ((h (* 0.5 d)))
    (values (+ px (* ux (- h (* h (cos th))))) (max 0.03 (+ 2.4 (* 3.2 (sin th)))) (+ pz (* uz (- h (* h (cos th))))))))

(defun ic-c-point-out (px pz ux uz d th o)
  "IC-C-POINT pushed O metres outward from the C's inner edge (both radii grown by O)."
  (let ((h (* 0.5 d)) (hx (+ (* 0.5 d) o)))
    (values (+ px (* ux (- h (* hx (cos th))))) (max 0.03 (+ 2.4 (* (+ 3.2 o) (sin th)))) (+ pz (* uz (- h (* hx (cos th))))))))

(defun vfx-ic-c-cut (px pz ux uz d k lo hi &key (scale 1.0) (flare 0.0))
  "漆黒の月牙天衝's C (the user's reference 2026-09-29: a thick pitch-black crescent with a smoky rim): the inner edge a
clean circle, the band grown outward, thickest opposite the gap (1.6 m) and tapering to the two points; black smoke
feathering off its outer edge on a pale backlight halo (it reads on a dark stage). Drawn from fraction LO to HI of its
arc (0 = the V tip over his head, 1 = the Ʌ tip at his knees; the gap +-32 deg round him), SCALE x its band (the
counter's small C), FLARE its halo brightened (the impact)."
  (let* ((g0 (deg 32)) (g1 (deg 328)) (n 40) (clk (fx-clock)))
    (flet ((w (u) (* scale (+ 0.3 (* 1.4 (expt (max 0.0 (sin (* pi u))) 0.6))))))   ; the crescent's thickness at U
      (dotimes (i n)
        (let* ((u0 (/ i (float n))) (u1 (/ (1+ i) (float n))))
          (when (and (> u1 lo) (< u0 hi))
            (let* ((v0 (max lo u0)) (v1 (min hi u1))
                   (t0 (+ g0 (* (- g1 g0) v0))) (t1 (+ g0 (* (- g1 g0) v1)))
                   (w0 (w v0)) (w1 (w v1)))
              (flet ((seg (f0 f1 wid r g b a &optional (fade 1.0))   ; a line from offset f0*w to f1*w (thickness fractions)
                       (multiple-value-bind (x0 y0 z0) (ic-c-point-out px pz ux uz d t0 (* f0 w0))
                         (multiple-value-bind (x1 y1 z1) (ic-c-point-out px pz ux uz d t1 (* f1 w1))
                           (fx-line x0 y0 z0 x1 y1 z1 (* wid w0) r g b a :end-width (* wid w1) :end-alpha (* fade a)
                                    :mode :alpha)))))
                ;; the pale halo behind the rim
                (seg 1.15 1.15 0.9 0.92 0.92 0.9 (min 1.0 (* k (+ 0.22 (* 0.5 flare)))))
                ;; the smoke: ragged dark wisps off the outer edge, flickering
                (dotimes (j 3)
                  (let* ((nz (sin (+ (* 12.9898 i) (* 78.233 j) (* 7.0 clk))))
                         (f (+ 1.0 (* 0.28 (abs nz)) (* 0.1 j))))
                    (seg f (+ f (* 0.25 (abs nz))) (+ 0.2 (* 0.15 (abs nz))) 0.06 0.06 0.07 (* k (- 0.6 (* 0.15 j))) 0.0)))
                ;; the pitch-black band, three layers from the inner edge out
                (seg 0.83 0.83 0.4 0.01 0.01 0.015 k)
                (seg 0.5 0.5 0.42 0.01 0.01 0.015 k)
                (seg 0.17 0.17 0.4 0.01 0.01 0.015 k)))))))))

(defun ic-line-from (a v)
  "Values px pz ux uz d: A's feet, the unit vector to V, the distance."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (max 0.5 (hypot dx dz))))
    (values (aref p 0) (aref p 2) (/ dx d) (/ dz d) d)))

(defparameter *cine-clone-waves* '(4 3) "千影: waves x clones per wave before the last all-round charge (12).")

(defun ic-cine-charge (vx vz ang start cf speed h0 clip)
  "One clone of 千影's charge: from 9 m out at angle ANG (and H0 m up) at SPEED m/s from frame START, through the victim
at (VX VZ), dissolving 1 m past him; a white slash where it passes."
  (let* ((tt (/ (- cf start) 60.0)) (r (- 9.0 (* speed tt))))
    (when (and (>= cf start) (> r -1.0))
      (let* ((x (+ vx (* r (cos ang)))) (z (+ vz (* r (sin ang)))) (y (* h0 (max 0.0 (/ r 9.0))))
             (yaw (dir-yaw (- (cos ang)) (- (sin ang)))) (a (if (< r 0.0) (* 0.5 (+ 1.0 r)) 0.5)))
        (ic-body-at x z yaw clip (* 0.3 tt) a :y y)
        (when (< (abs r) 1.2)                           ; passing through him: the ink streak and the white flash
          (fx-line (+ vx (* 1.5 (cos ang))) 1.1 (+ vz (* 1.5 (sin ang))) (- vx (* 1.5 (cos ang))) 1.0 (- vz (* 1.5 (sin ang)))
                   0.06 0.02 0.02 0.03 0.9 :mode :alpha)
          (fx-line (+ vx (* 1.2 (cos ang))) 1.1 (+ vz (* 1.2 (sin ang))) (- vx (* 1.2 (cos ang))) 1.0 (- vz (* 1.2 (sin ang)))
                   0.025 1.0 1.0 1.0 0.9))))))

(defcine ic-kessa-kikon-cine (a v :len 192 :hold 124)
  "千影 SEN'EI, KESSA's Kikon (v2 §5.5; SF6's Shun Goku Satsu): beat 0, the strike held; the plaza drops to black, the
victim alone, Ichigo gone in a flash step; clones on a 9 m ring charge through him from every quarter, four waves of
three, then twelve at once; one white frame; behind Ichigo, low, facing away, the victim collapsed beyond: the brush
千影, the hanko, the impact, the Konpaku; wide, the ink settling."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.8 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-k-uchi :blend 2 :time (/ 7.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)   ; (KAGE-UCHI's hit)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :clone :pitch 0.8))
  (at 12 (card :black v) (shot-on v 30 5.0 1.2 :look 1.2) (lens 50) (play-sfx :hoho-out) (silence 14))
  (at 30 (lens 40))
  (during (30 110) (let* ((q (pos-of v)) (ang (+ 0.5 (* 6.2832 u))))   ; orbiting him, one turn
                     (cine-cam (+ (aref q 0) (* 5.0 (cos ang))) 1.6 (+ (aref q 2) (* 5.0 (sin ang))) (aref q 0) 1.1 (aref q 2))))
  (during (30 116) (let ((q (pos-of v)) (clips '(:ic-k-f1 :ic-k-f3 :ic-k-cut)))
                     (destructuring-bind (waves per) *cine-clone-waves*
                       (dotimes (w waves)
                         (dotimes (i per)
                           (ic-cine-charge (aref q 0) (aref q 2) (+ 0.5 3.1416 (* 6.2832 (/ (+ 8 (* 16 w)) 80.0)) (* (- i 1) 0.6))
                                           (+ 30 (* 16 w)) cf 22.0 (if (= i 1) 3.5 0.0) (nth (mod (+ w i) 3) clips))))
                       (dotimes (i 12)                  ; the last: every direction at once
                         (ic-cine-charge (aref q 0) (aref q 2) (* i 0.5236) 96 cf 45.0 (if (oddp i) 2.5 0.0) (nth (mod i 3) clips))))))
  (at 34 (play-sfx :cut)) (at 50 (play-sfx :cut :pitch 1.1)) (at 66 (play-sfx :cut :pitch 0.95)) (at 82 (play-sfx :cut :pitch 1.15))
  (at 100 (play-sfx :cut-heavy) (play-sfx :clone :pitch 0.6) (shake 0.2 0.3))
  (at 110 (card nil) (ui-flash 1 1 1 1 6.0) (silence 10) (lens 50))
  (at 120 (face-each-other a v 3.2) (card :black) (back-rim 56 0.82 0.06 0.11) (shot-on a 155 3.2 0.55 :look 1.3 :off -0.5)
      (cine-clip a :ic-k-stance :blend 0) (cine-clip v :sh-crumple :blend 0)
      (caption "千影" :reading "SEN'EI" :sub "KESSA NO ICHIGO  KIKON" :side 1 :hanko t))
  (at 124 (impact-frame :negative 2)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (play-sfx :explode :pitch 0.6 :gain 0.6) (shake 0.3 0.4))
  (at 126 (impact-frame :manga 12))
  (at 176 (card nil) (caption-exit) (shot-on a 150 7.0 2.0 :look 1.4) (lens 50)))

(defcine ic-kessa-getsuga-cine (a v :len 180 :hold 124)
  "漆黒の月牙天衝, KESSA's Soul Break (v2 §5.4): beat 0, the blow held, silence; low and close: the slab overhead, a black
glow gathering on it; a black card, the brush 月牙天衝 / 漆黒; wide and side-on: one top-down cut whose trail keeps going
round into a huge C hanging in the air; from the C's centre, looking back through its gap at Ichigo framed by its two
points; the victim: the impact, the Konpaku; back inside the C as it burns away from its tips."
  (at 0 (face-each-other a v 6.0) (shot-on a 60 4.0 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-k-cut :blend 2 :time 0.15) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (silence 12))
  (at 12 (shot-on a 20 3.6 0.6 :look 2.2) (lens 60) (cine-clip a :ic-k-f3 :blend 6 :time (/ 13.0 60.0) :speed 0.0)
      (play-sfx :awaken-rise :pitch 0.5))
  (during (12 48) (let ((m (model a)) (w *ic-w*) (b *ic-v*))   ; the black glow gathering on the slab
                    (body-weapon-tip (model-body m) :tensa (model-joints m) w)
                    (body-weapon-base (model-body m) :tensa (model-joints m) b)
                    (fx-line (aref b 0) (aref b 1) (aref b 2) (aref w 0) (aref w 1) (aref w 2) (+ 0.08 (* 0.18 u)) 0.02 0.02 0.03
                             (* 0.9 u) :mode :alpha)
                    (dotimes (i 3)
                      (let ((f (rnd01)) (a0 (rnd-range 0f0 6.28f0)))
                        (%t-shard (+ (aref b 0) (* f (- (aref w 0) (aref b 0))) (* 1.2 (cos a0))) (+ (aref b 1) (* f (- (aref w 1) (aref b 1))))
                                  (+ (aref b 2) (* f (- (aref w 2) (aref b 2))) (* 1.2 (sin a0))) (* -3f0 (cos a0)) 0f0 (* -3f0 (sin a0))
                                  0.35f0 0.05f0 0f0 +pal-ink+)))))
  (at 48 (card :black a) (back-rim 52 0.82 0.06 0.11) (shot-on a 20 4.2 0.9 :look 1.1 :off 0.9) (lens 42)
      (caption "月牙天衝" :kanji2 "漆黒" :reading "GETSUGA TENSHO" :sub "KESSA NO ICHIGO  SOUL BREAK" :side 0 :hanko t))
  (at 100 (card nil) (caption-exit) (lens 40) (cine-clip a :ic-k-f3 :blend 0 :time (/ 17.0 60.0))
      (play-sfx :getsuga :pitch 0.6) (play-sfx :explode :pitch 0.5) (shake 0.35 0.5))
  (during (100 112) (multiple-value-bind (px pz ux uz d) (ic-line-from a v)   ; wide, side-on: the cut, its trail round
                      (cine-cam (+ px (* 0.5 d ux) (* 14.0 (- uz))) 2.6 (+ pz (* 0.5 d uz) (* 14.0 ux)) (+ px (* 0.5 d ux)) 2.4 (+ pz (* 0.5 d uz)))
                      (vfx-ic-c-cut px pz ux uz d 0.95 0.0 (min 1.0 (* 1.4 u)))))
  (at 112 (lens 74) (silence 20))
  (during (112 140) (multiple-value-bind (px pz ux uz d) (ic-line-from a v)   ; inside the C, looking back through the gap
                      (let ((c (- (* 0.84 d) (* 0.5 u))))
                        (cine-cam (+ px (* c ux)) 2.4 (+ pz (* c uz)) px 2.4 pz))
                      (vfx-ic-c-cut px pz ux uz d (+ 0.8 (* 0.15 (sin (* 0.4 cf)))) 0.0 1.0)))
  (at 140 (shot-on v 160 5.0 1.3 :look 1.3) (lens 58) (impact-frame :negative 2)
      (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-konpaku-shatter x (+ y 0.1) z 4) (vfx-hit x (+ y 0.3) z :heavy))
      (impact-splash-at v 0.0 14 0.1)
      (play-sfx :konpaku-shatter) (play-sfx :chain-snap) (shake 0.3 0.4))
  (at 142 (impact-frame :manga 12))
  (during (140 160) (multiple-value-bind (px pz ux uz d) (ic-line-from a v) (vfx-ic-c-cut px pz ux uz d 0.95 0.0 1.0 :flare (- 1.0 u))))
  (at 160 (cine-clip a :ic-k-stance :blend 10) (lens 74))
  (during (160 180) (multiple-value-bind (px pz ux uz d) (ic-line-from a v)   ; it burns away from both points inward
                      (cine-cam (+ px (* 0.8 d ux)) 2.4 (+ pz (* 0.8 d uz)) px 2.4 pz)
                      (vfx-ic-c-cut px pz ux uz d (- 0.9 (* 0.5 u)) (* 0.5 u) (- 1.0 (* 0.5 u))))))

(defcine ic-pose-cine (a v :len 9999 :hold 1)
  "Debug stills (ichigo.lisp ICHIGO-POSE, 74990+k): the camera on P1 at *IC-POSE-ANG* degrees."
  (at 0 (shot-on a *ic-pose-ang* 3.6 1.1 :look 1.0) (lens 42)))

(defcine ic-kessa-cine (a v :len 168 :hold 120)
  "血鎖の一護 KESSA NO ICHIGO (the awakening, 168 f): beat 0, the blades lowered, head down, silence; close on his face:
the Hollow marking on the left, a low drone; medium and low: the short blade brought into the long one's hole, a white
flash, one blade (Tensa); low and wide from behind: the blood chains burst from neck, wrists and ankles, the second
horn; a black card, a BLOOD back-rim, the 血鎖の一護 stamp (no hanko: not a Kikon); back in the plaza, the chains
drifting."
  (at 0 (setf (model-weapon (model a)) :zangetsu-long (model-hide (model a)) (hide-set '(:kessa :mark)) *aura-off* a)
      (shot-on a 30 3.4 1.0 :look 1.0) (lens 50)
      (cine-clip a :ic-awaken :blend 3) (cine-clip v (kit-stance (kit-of v)) :blend 6)
      (hold-both a v 12) (impact-frame :negative 2) (silence 12))
  (at 12 (shot-on a 20 1.3 1.62 :look 1.62) (lens 70) (play-sfx :awaken-rise :pitch 0.6))
  (at 26 (setf (model-hide (model a)) (hide-set '(:kessa))))   ; the marking crawls on (the Shikai's blades still in hand)
  (at 40 (shot-on a 40 3.0 0.5 :look 1.1 :off 0.4) (lens 64 -4))
  (at 58 (setf (model-weapon (model a)) :tensa (model-hide (model a)) (hide-set '(:shikai :kessa)))
      (ui-flash 1 1 1 1 20.0) (play-sfx :awaken-boom :pitch 1.2))
  (at 70 (shot-on a 170 3.6 0.35 :look 1.0) (lens 76 -6) (setf (model-hide (model a)) (hide-set '(:shikai :mark)))   ; the chains, the
      (play-sfx :chain-rattle) (play-sfx :awaken-boom))                                                         ; second horn
  (at 80 (play-sfx :chain-rattle :pitch 0.8) (shake 0.15 0.3))
  (during (70 168) (let ((g (min 1.0 (/ (- cf 70) 10.0))) (p (pos-of a)))   ; the chains bursting, then drifting
                     (loop for j in '(:neck :hand-r :hand-l :shin-r :shin-l) for i from 0
                           do (let* ((v (ic-joint a (joint-index j))) (x (aref v 0)) (y (aref v 1)) (z (aref v 2))
                                     (dx (- x (aref p 0))) (dz (- z (aref p 2))) (l (max 0.05 (hypot dx dz)))
                                     (r (* g (+ 0.8 (* 0.3 (sin (+ (* 0.1 cf) i)))))))
                                (vfx-ic-chain x y z (+ x (* r (/ dx l))) (+ y (* 0.4 g) (* 0.2 (sin (+ (* 0.13 cf) i))))
                                              (+ z (* r (/ dz l))) 0.9)))))
  (at 96 (card :black a) (back-rim 54 0.82 0.06 0.11) (shot-on a 20 4.4 0.9 :look 1.1 :off 0.9) (lens 42)
      (caption "血鎖の一護" :reading "KESSA NO ICHIGO" :sub "TENSA ZANGETSU" :side 0))
  (at 150 (card nil) (caption-exit) (shot-on a -30 6.0 1.4 :look 1.1) (lens 50) (setf *aura-off* nil)
      (cine-clip a :ic-k-stance :blend 10)))
