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
Rey Cero), a yellow-white glow (3: the Shikai's Getsuga, the user 2026-10-27: 「始解狀態的月牙是黃白色光輝」: the REIATSU body, a white
rim), pitch black (4: KESSA's, the Soul Break's 漆黒 C in small, the user 2026-10-27: a black band, a ragged black-smoke rim on a
pale halo, flickering); presence K."
  (with-floats (x y z yaw w k tilt)
    (let* ((fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (px (- fz)) (pz fx) (hw (* 0.5f0 w)) (dr (drawing-no))
           (dy (* 0.3f0 w tilt)) (x0 (- x (* hw px))) (z0 (- z (* hw pz))) (x1 (+ x (* hw px))) (z1 (+ z (* hw pz)))
           (bx (+ x (* 0.5f0 w fx))) (bz (+ z (* 0.5f0 w fz))) (rw (* 0.035f0 w)) (ahead (* 0.04f0 w)))
      (declare (single-float fx fz px pz hw dr dy x0 z0 x1 z1 bx bz rw ahead))
      (when (= (the fixnum core) 4)                          ; the pale halo behind, the smoke off its edge
        (fx-crescent x0 (- y dy) z0 x1 (+ y dy) z1 (+ bx (* ahead fx)) y (+ bz (* ahead fz)) (* 0.24f0 w) :lens 0.1f0 (+ 330f0 dr)
                     +pal-smoke+ (* 0.55f0 k) :push 0.06f0)
        (fx-crescent x0 (- y dy) z0 x1 (+ y dy) z1 (+ bx (* 2.5f0 ahead fx)) y (+ bz (* 2.5f0 ahead fz)) (* 0.2f0 w) :lens 0.18f0
                     (+ 340f0 dr) +pal-black-smoke+ (* 0.8f0 k) :push 0.08f0))
      (fx-crescent x0 (- y dy) z0 x1 (+ y dy) z1 bx y bz (* 0.15f0 w) :lens 0.06f0 (+ 300f0 dr)
                   (if (= (the fixnum core) 3) +pal-reiatsu+ +pal-ink+) k :push 0.1f0)
      (fx-crescent (+ x0 (* ahead fx)) (- y dy) (+ z0 (* ahead fz)) (+ x1 (* ahead fx)) (+ y dy) (+ z1 (* ahead fz))
                   (+ bx (* 1.5f0 ahead fx)) y (+ bz (* 1.5f0 ahead fz)) rw :lens 0.04f0 (+ 310f0 dr)
                   (case (the fixnum core) (1 +pal-blood+) (4 +pal-black-smoke+) (t +pal-hit+)) k :push 0.16f0)
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
    (vfx-ic-crescent (hazard-x hz) 1.2 (hazard-z hz) (hazard-yaw hz) (* 2 (hazard-size hz)) (ic-wave-k hz) 0.9 3)))

(defun ic-kessa-owner-p (hz) "Was HZ thrown by KESSA (the Bankai: his Getsuga black)?"
  (let ((e (hazard-owner hz))) (and (entity-alive-p e) (fighter e) (eq (kit-form (fighter-kit (fighter e))) :kessa))))

(defun ichigo-juji-look (hz rdt)
  "GETSUGA JUJISHO: the two crescents crossed into an X (yellow-white); thrown by KESSA, NS2's third press is a smaller 漆黒 crescent
like his Soul Break's (the user, 2026-10-27: 「第三段則是揮出跟毀魂技類似、但規模較小的月牙斬痕」), its tips up and down."
  (declare (ignore rdt))
  (when (<= (hazard-delay hz) 0)
    (let ((k (ic-wave-k hz)) (w (* 2 (hazard-size hz))))
      (if (ic-kessa-owner-p hz)
          (vfx-ic-crescent (hazard-x hz) 1.4 (hazard-z hz) (hazard-yaw hz) (* 0.9 w) k 1.0 4)   ; (KESSA's: the clean 漆黒 crescent; the flame sheets were tried and dropped, 2026-10-31)
          (progn (vfx-ic-crescent (hazard-x hz) 1.1 (hazard-z hz) (hazard-yaw hz) w k 0.8 3)
                 (vfx-ic-crescent (hazard-x hz) 1.1 (hazard-z hz) (hazard-yaw hz) w k -0.8 3))))))

(defun ichigo-form-look (hz rdt)
  "JUJISHO's first crescent forming on the long blade before the fusion (black for KESSA's)."
  (declare (ignore rdt))
  (vfx-ic-crescent (hazard-x hz) 1.2 (hazard-z hz) (hazard-yaw hz) (* (hazard-size hz) (min 1.0 (/ (hazard-age hz) 4.0)))
                   0.9 0.8 (if (ic-kessa-owner-p hz) 4 3)))

(defun ichigo-kx-look (hz rdt)
  "KESSA's NS3 X: two black crescents crossed where the clones' cuts meet (vfx-ic-crescent's 漆黒, tips tilted both ways), fading."
  (declare (ignore rdt))
  (let ((k (max 0.02 (- 0.95 (* 0.05 (hazard-age hz))))) (w (* 2 (hazard-size hz))))
    (vfx-ic-crescent (hazard-x hz) 1.3 (hazard-z hz) (hazard-yaw hz) w k 0.9 4)
    (vfx-ic-crescent (hazard-x hz) 1.3 (hazard-z hz) (hazard-yaw hz) w k -0.9 4)))

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
         (an (svref *ic-clone-anim* side)) (jm (svref *ic-clone-joints* side)) (b (find-body :ichigo-kessa))
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
      ((:answer :replay) (let ((mv (icc-mv c))) (ic-ghost hz (mv-clip mv) (/ (* (max 0 (icc-sf c)) (mv-clip-speed mv)) 60.0) (max a 0.3) t :mist t)))
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

;;; NS2's charge on the blades (the user, 2026-10-27: 「蓄力後接續的 SA 不是要把月牙射出去，而是纏繞在刀刃上揮砍，所以每次攻擊都會留下黃白光輝
;;;的軌跡」): from a charge through its SA and the J2 / J3 after it, the Getsuga wraps the charged blades (1 the short blade, 2 both) in a
;;; yellow-white glow, and every swing of a charged blade leaves a yellow-white trail (VFX-SMEAR's REIATSU comet); 「是 SA 與後續的一連串攻擊
;;; 都會纏繞著月牙靈壓」: the whole string after the SA (its J2 / J3, the AS segments) until it ends
(defvar *ic-charged* (make-array 2 :initial-element 0) "Per side: the blades charged (0 none, 1 the short blade, 2 both).")
(defvar *ic-charge-trails* (vector (make-trail) (make-trail) (make-trail) (make-trail)) "Per side x blade (short, cleaver): its trail.")
(defvar *ic-charge-smears* (vector (make-f32 12) (make-f32 12) (make-f32 12) (make-f32 12)) "... and its held smear.")
(declaim (type f32vec *ic-cb* *ic-ct*))
(defvar *ic-cb* (make-f32 3) "A charged blade's base.")
(defvar *ic-ct* (make-f32 3) "A charged blade's tip.")

(defun %ic-black-flame (x0 y0 z0 x1 y1 z1 big seed fx fz)
  "KESSA's charge (the user, 2026-10-27: 「卍解對應的招式則是在大劍上積蓄黑色焰氣 / 一階的焰氣較小，二階焰氣更明顯，並且呈現不規則的十字形」):
black flame gathered along the slab from (x0 y0 z0) to its tip (x1 y1 z1): a smoky band, its ink core, tongues licking up off it; BIG
(the second charge) larger, with a ragged band across the blade (facing FX FZ: toward him) into an irregular cross. SEED the drawing."
  (let* ((fl (+ 0.8 (* 0.3 (hash01 seed 4.1f0)))) (w (* fl (if big 0.22 0.11)))
         (mx (* 0.5 (+ x0 x1))) (my (+ 0.05 (* 0.5 (+ y0 y1)))) (mz (* 0.5 (+ z0 z1))))
    (fx-crescent x0 y0 z0 x1 y1 z1 mx my mz w :lens 0.14f0 (+ 620f0 seed) +pal-black-smoke+ 0.85f0 :push 0.1f0)
    (fx-crescent x0 y0 z0 x1 y1 z1 mx my mz (* 0.4 w) :lens 0.06f0 (+ 630f0 seed) +pal-ink+ 0.95f0 :push 0.14f0)
    (dotimes (i (if big 5 3))                                   ; the tongues
      (let* ((u (/ (+ 0.5 i) (if big 5.0 3.0))) (px (+ x0 (* u (- x1 x0)))) (py (+ y0 (* u (- y1 y0)))) (pz (+ z0 (* u (- z1 z0))))
             (h (* (if big 0.55 0.3) (+ 0.6 (* 0.6 (hash01 (+ seed i) 7.3f0))))) (sw (* 0.15 (- (hash01 (+ seed i) 9.1f0) 0.5))))
        (fx-crescent px py pz (+ px (* sw fz)) (+ py h) (- pz (* sw fx)) (+ px (* 2 sw fz)) (+ py (* 0.5 h)) (- pz (* 2 sw fx))
                     (* 0.45 w) :comet 0.1f0 (+ 640f0 seed i) +pal-black-smoke+ 0.8f0 :push 0.12f0)))
    (when big                                                   ; the band across: an irregular cross
      (let* ((bx (- x1 x0)) (by (- y1 y0)) (bz (- z1 z0))
             (cx (- (* by (- fz)) 0.0)) (cy (- (* bz fx) (* bx (- fz)))) (cz (- 0.0 (* by fx)))   ; blade x facing
             (cl (max 1e-3 (sqrt (+ (* cx cx) (* cy cy) (* cz cz))))) (l (* 0.42 (sqrt (+ (* bx bx) (* by by) (* bz bz)))))
             (u 0.62) (ox (+ x0 (* u bx))) (oy (+ y0 (* u by))) (oz (+ z0 (* u bz)))
             (j0 (+ 0.8 (* 0.4 (hash01 seed 11.7f0)))) (j1 (+ 0.8 (* 0.4 (hash01 seed 13.9f0)))) (tw (* 0.12 (- (hash01 seed 15.1f0) 0.5))))
        (setf cx (/ cx cl) cy (/ cy cl) cz (/ cz cl))
        (let ((ax (- ox (* l j0 cx))) (ay (- oy (* l j0 cy) tw)) (az (- oz (* l j0 cz)))
              (ex (+ ox (* l j1 cx))) (ey (+ oy (* l j1 cy) tw)) (ez (+ oz (* l j1 cz))))
          (fx-crescent ax ay az ex ey ez ox (+ oy 0.06) oz (* 0.9 w) :lens 0.16f0 (+ 660f0 seed) +pal-black-smoke+ 0.85f0 :push 0.1f0)
          (fx-crescent ax ay az ex ey ez ox (+ oy 0.06) oz (* 0.35 w) :lens 0.06f0 (+ 670f0 seed) +pal-ink+ 0.95f0 :push 0.14f0))))))

(defun ichigo-charged-blades (e f m)
  "Step side E's charge (*IC-CHARGED*: set by the move he is in) and draw its glow and trails on the posed body (KESSA: the black flame
on the slab, ink trails)."
  (let* ((side (fighter-side f)) (kessa (eq (kit-form (fighter-kit f)) :kessa)) (mv (and (eq (fighter-state f) :move) (fighter-move f))) (n (and mv (mv-name mv)))
         (c (case n ((:ic-n2a :ic-sa-g1 :ic-k-n2a :ic-k-sa-g1 :ic-k-as2) 1) ((:ic-n2b :ic-sa-g2 :ic-k-n2b :ic-k-sa-g2 :ic-k-as2b :ic-as2 :ic-as2b) 2)   ; (KESSA's AS2:
                  ((:ic-j2 :ic-j3 :ic-na3 :ic-na4 :ic-k-na3 :ic-k-na4 :ic-as1 :ic-as3 :ic-as3b :ic-as3c   ; the string the SA goes on into        ;  the Getsuga's flame)
                    :ic-k-j2 :ic-k-j3 :ic-k-as1 :ic-k-as3 :ic-k-as3b :ic-k-as3c)
                   (svref *ic-charged* side))
                  (t 0)))
         (swing (and mv (eq (fighter-phase f) :main) (>= (fighter-sf f) (- (mv-s mv) 4)) (< (fighter-sf f) (+ (mv-s mv) (mv-a mv) 3))))
         (jm (model-joints m)) (dr (drawing-no)))
    (setf (svref *ic-charged* side) c)
    (dotimes (b 2)
      (let ((tr (svref *ic-charge-trails* (+ (* 2 side) b))))
        (if (and (< b (if kessa (min c 1) c)) (model-weapon m) (> (model-alpha m) 0.5))   ; (KESSA: one slab)
            (let ((base *ic-cb*) (tip *ic-ct*))
              (if (and (= b 0) (not kessa))
                  (progn (joint-point! base jm (ji :weapon-l) 0f0 0f0 0f0) (joint-point! tip jm (ji :weapon-l) 0f0 -0.9f0 0f0))
                  (progn (joint-point! base jm (ji :weapon-r) 0f0 0f0 0f0)
                         (%ic-held-tip jm tip (weapon-len (find-weapon (model-weapon m))))))
              (let* ((x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)) (x1 (aref tip 0)) (y1 (aref tip 1)) (z1 (aref tip 2))
                     (mx (* 0.5 (+ x0 x1))) (my (+ 0.06 (* 0.5 (+ y0 y1)))) (mz (* 0.5 (+ z0 z1)))
                     (fl (+ 0.85 (* 0.15 (hash01 (+ dr b) 2.3f0)))))
                (if kessa
                    (%ic-black-flame x0 y0 z0 x1 y1 z1 (= c 2) (+ dr side) (fwd-x (yaw-of e)) (fwd-z (yaw-of e)))
                    (progn
                      (fx-crescent x0 y0 z0 x1 y1 z1 mx my mz (* 0.09 fl) :lens 0.05f0 (+ 600f0 dr b) +pal-reiatsu+ 0.9f0 :push 0.12f0)   ; the wrap
                      (fx-crescent x0 y0 z0 x1 y1 z1 mx my mz (* 0.03 fl) :lens 0.03f0 (+ 610f0 dr b) +pal-hit+ 0.95f0 :push 0.16f0)))   ; its core
                (if swing (trail-push tr x0 y0 z0 x1 y1 z1) (trail-decay tr))))
            (trail-decay tr))
        (vfx-smear tr (svref *ic-charge-smears* (+ (* 2 side) b)) (if kessa 2 1))))))   ; (KESSA's trail an ink wash)

;;; KESSA's blood chains (DUEL_CORE §6, 2026-10-28): a chain move's lash (its :params :chain), and pointer 1's rest, the chains
;;; circling him (the user: 「中立站姿也改成血鎖圍繞在身邊」)
(defparameter *ic-chain-roots* '((:hand-l 0.0 -0.06 0.0) (:hand-r 0.0 -0.06 0.0) (:foot-l 0.0 0.05 0.0) (:foot-r 0.0 0.05 0.0))
  "Where KESSA's blood chains come out: both wrists, both ankles (the user, 2026-10-28: 「血鎖是從手腕、腳踝延伸出來的」); the first is the
lashing one.")

(defun ichigo-chain-lash (e f m)
  "A chain move (its :params :chain (from-deg to-deg len from-y to-y)): the chain cast from the left wrist, swept from FROM to TO degrees off
his facing (0 = at him) and drawn back, its tip from FROM-Y to TO-Y m up; the other wrist's and both ankles' chains reach for the same tip,
fainter and a beat behind. One sweep over S-4 .. S+A+4, or one per hit window (a multi-hit lash: alternating directions)."
  (let* ((mv (and (eq (fighter-state f) :move) (fighter-move f))) (ch (and mv (getf (mv-params mv) :chain))))
    (when (and ch (> (model-alpha m) 0.5))
      (destructuring-bind (a0 a1 len y0 y1) ch
        (let* ((sf (fighter-sf f)) (p (pos-of e)) (hits (mv-hits mv)) (n (length hits)))
          (dotimes (w (max 1 (if (> n 1) n 1)))
            (multiple-value-bind (lo span) (if (> n 1)
                                               (let ((hw (svref hits w))) (values (- (hw-from hw) 3) (+ (- (hw-to hw) (hw-from hw)) 6)))
                                               (values (- (mv-s mv) 4) (+ (mv-a mv) 8)))
              (let ((b0 (if (evenp w) a0 a1)) (b1 (if (evenp w) a1 a0)))
                (loop for (j lx ly lz) in *ic-chain-roots* for r from 0
                      do (let ((u (/ (- sf lo (* 2 r)) (float span))))
                           (when (< 0.0 u 1.0)
                             (let* ((v (ic-joint e (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                                    (ang (+ (yaw-of e) (deg (+ b0 (* u (- b1 b0))))))
                                    (l (* len (if (= r 0) 1.0 0.8) (min 1.0 (* 4 u) (* 4 (- 1.0 u)))))
                                    (tx (+ (aref p 0) (* l (fwd-x ang)))) (ty (+ y0 (* u (- y1 y0)))) (tz (+ (aref p 2) (* l (fwd-z ang)))))
                               (vfx-ic-chain (aref v 0) (aref v 1) (aref v 2) tx ty tz (if (= r 0) 0.95 0.5))))))))))))))

(defun ichigo-chain-rest (e f)
  "KESSA resting under pointer 1: a blood chain out of each wrist and each ankle, curling round him and swaying (two links of arc each)."
  (when (and *core-on* (= (fighter-ptr f) 1) (member (fighter-state f) '(:idle :guard)))
    (let ((p (pos-of e)) (tm (fx-clock)) (w *ic-ct*))
      (loop for (j lx ly lz) in *ic-chain-roots* for i from 0
            do (let* ((v (ic-joint e (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                      (x0 (aref v 0)) (y0 (aref v 1)) (z0 (aref v 2))
                      (ang (+ (* 0.8 tm) (* i 1.571))) (r 0.85) (hy (+ 0.5 (* 0.35 (mod i 2)) (* 0.15 (sin (+ (* 1.7 tm) i))))))
                 (dotimes (k 3)
                   (let* ((a1 (+ ang (* (1+ k) 0.6))) (x1 (+ (aref p 0) (* r (cos a1)))) (z1 (+ (aref p 2) (* r (sin a1))))
                          (y1 (+ hy (* 0.25 k))))
                     (setf (aref w 0) (f32 x1) (aref w 1) (f32 y1) (aref w 2) (f32 z1))
                     (vfx-ic-chain x0 y0 z0 x1 y1 z1 0.85)
                     (setf x0 x1 y0 y1 z0 z1))))))))

(defparameter *ic-wisp-roots* '((:hand-l 0.0 -0.06 0.0) (:hand-r 0.0 -0.06 0.0) (:foot-l 0.0 0.05 0.0) (:foot-r 0.0 0.05 0.0) (:neck 0.0 0.07 0.0))
  "Where KESSA's red flames hang: both wrists, both ankles and the neck (the user, 2026-10-31: 「手腕腳踝跟頸部圍繞的是飄盪的紅色燄氣」).")

(defun ichigo-red-wisps (e)
  "Red flame drifting round KESSA's wrists, ankles and neck: at each root smooth toon tongues (blood red, an ember core beside each),
swaying with their own phases. The limbs' rise and lean against his motion; the neck's, while he stands still, spread out on every side
(six tongues round the neck, turning slowly, only a little up; the user, 2026-10-31: 「脖子的焰氣不動時請向四方擴散，不要只往上」) and trail
back against his motion as he moves."
  (let* ((tm (fx-clock)) (v (motion-vel (motion e))) (spd (sqrt (+ (* (aref v 0) (aref v 0)) (* (aref v 2) (aref v 2)))))
         (still (max 0.0 (- 1.0 (* 0.5 spd)))))
    (loop for (j lx ly lz) in *ic-wisp-roots* for i from 0
          do (let* ((r (ic-joint e (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                    (x0 (aref r 0)) (y0 (aref r 1)) (z0 (aref r 2)) (neck (eq j :neck)) (n (if neck 6 3)))
               (dotimes (k n)
                 (let* ((ph (+ (* 2.4 tm) (* 1.9 i) (* 2.1 k))) (len (* (if neck 0.42 0.5) (+ 0.85 (* 0.25 (sin (* 1.3 ph))))))
                        (ang (+ (* 6.2832 (/ k (float n))) (* 0.25 tm)))
                        (lean (if neck
                                  (+ (* still 0.4 (cos ang)) (* -0.1 (aref v 0)))
                                  (+ (* -0.08 (aref v 0)) (* 0.12 (cos (* 2.1 k))))))
                        (lean-z (if neck
                                    (+ (* still 0.4 (sin ang)) (* -0.1 (aref v 2)))
                                    (+ (* -0.08 (aref v 2)) (* 0.12 (sin (* 2.1 k))))))
                        (rise (if neck (* len (+ 0.3 (* 0.7 (- 1.0 still)))) len))
                        (sd (+ i (* 3 k) (drawing-no))))
                   (%tongue (f32 x0) (f32 y0) (f32 z0) (f32 lean) (f32 rise) (f32 lean-z) 0.06f0 +pal-blood+ 0.95f0 (f32 sd) (f32 ph) 0.08f0 :segs 6 :wob 0.04)
                   (%tongue (f32 x0) (f32 y0) (f32 z0) (f32 (* 0.8 lean)) (f32 (* 0.7 rise)) (f32 (* 0.8 lean-z)) 0.03f0 +pal-ember+ 0.9f0
                            (f32 (+ sd 40.0)) (f32 (+ ph 0.7)) 0.05f0 :segs 5 :wob 0.04)))))))

(defun ichigo-renzan-look (hz rdt)
  "One of KAGE-RENZAN's cuts bursting on the opponent's body: a black-red slash and a white core across him at the angle of its number
(HAZARD-DATA 1-3), a flash, fading over its few frames."
  (declare (ignore rdt))
  (let* ((n (hazard-data hz)) (age (hazard-age hz)) (k (max 0.0 (- 1.0 (/ age 9.0)))) (th (nth (1- (max 1 (min 3 n))) '(0.7 -0.8 1.5)))
         (x (hazard-x hz)) (z (hazard-z hz)) (c (cos th)) (s (sin th)) (rx 1.0) (rz 0.0) (y 1.1))
    (let ((o (hazard-owner hz)))
      (when (and (entity-alive-p o) (fighter o))                       ; the slash plane faces the attacker's side
        (let* ((p (pos-of o)) (dx (- (aref p 0) x)) (dz (- (aref p 2) z)) (l (max 0.01 (sqrt (+ (* dx dx) (* dz dz))))))
          (setf rx (/ (- dz) l) rz (/ dx l)))))
    (let ((ax (+ x (* rx 1.5 c))) (ay (+ y (* 1.5 s))) (az (+ z (* rz 1.5 c))) (bx (- x (* rx 1.5 c))) (by (- y (* 1.5 s))) (bz (- z (* rz 1.5 c))))
      (fx-line ax ay az bx by bz (* 0.34 k) 0.55 0.04 0.05 (* 0.9 k) :mode :alpha :end-width 0.0)
      (fx-line ax ay az bx by bz (* 0.1 k) 1.0 0.92 0.85 k :end-width 0.0)
      (%light (f32 x) (f32 y) (f32 z) 1.0f0 0.3f0 0.2f0 4f0 (f32 (* 1.8 k)) 6))))

(defun ichigo-draw (e rdt)
  "KIT-HOOK :draw (both forms): step the Shikai's cloak spring; the crescent edge and the ground contact (§3.3)."
  (let* ((f (fighter e)) (m (model e)) (o (* 32 (fighter-side f))) (st *ic-look*)
         (kessa (eq (kit-form (fighter-kit f)) :kessa))
         (mv (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-move f)))
         (sf (if mv (fighter-sf f) -1)) (prev (%ic-frame st (+ o 28) sf))
         (edge (and mv (assoc (mv-name mv) *ic-edge-moves*))))
    (declare (fixnum o sf prev))
    (unless kessa (%ya-hem-step st o (if (typep rdt 'single-float) rdt (f32 rdt))))   ; (F32 inline re-boxes)
    (ichigo-charged-blades e f m)
    (when kessa (ichigo-chain-lash e f m) (ichigo-chain-rest e f)
      (when (> (model-alpha m) 0.5) (ichigo-red-wisps e)))
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
(defun ic-body-at (x z yaw clip tm alpha &key (y 0.0) (shikai nil))
  "A clone of KESSA at (X Y Z) facing YAW, posed at time TM of CLIP, at ALPHA: the grey-black phantom (IC-GHOST's :mist
look) in a cinematic. SHIKAI: the Shikai's two blades instead (the rush Kikon's afterimages)."
  (let ((an (svref *ic-clone-anim* 0)) (jm (svref *ic-clone-joints* 0)) (b (find-body (if shikai :ichigo :ichigo-kessa))))
    (anim-play an clip :blend 0 :time (f32 (max 0.0 tm)))
    (pose-fk! jm (anim-eval an) (f32 x) (f32 y) (f32 z) (f32 yaw) (body-scale b) (body-hunch b) (body-props b))
    (draw-body b jm x y z yaw :weapon (if shikai :zangetsu-long :tensa)
                              :hide (svref (hide-set (if shikai '(:kessa :mark) '(:shikai :mark))) 0) :alpha (f32 alpha)
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

(defun ic-cine-charge (vx vz ang start cf speed h0 clip &optional shikai)
  "One clone of 千影's charge: from 9 m out at angle ANG (and H0 m up) at SPEED m/s from frame START, through the victim
at (VX VZ), dissolving 1 m past him; a white slash where it passes. SHIKAI: a Shikai afterimage (the rush Kikon)."
  (let* ((tt (/ (- cf start) 60.0)) (r (- 9.0 (* speed tt))))
    (when (and (>= cf start) (> r -1.0))
      (let* ((x (+ vx (* r (cos ang)))) (z (+ vz (* r (sin ang)))) (y (* h0 (max 0.0 (/ r 9.0))))
             (yaw (dir-yaw (- (cos ang)) (- (sin ang)))) (a (if (< r 0.0) (* 0.5 (+ 1.0 r)) 0.5)))
        (ic-body-at x z yaw clip (* 0.3 tt) a :y y :shikai shikai)
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

(defcine ic-haste-kikon-cine (a v :len 160 :hold 110)
  "超速連斬 CHOSOKU RENZAN, KESSA's pointer-2 Kikon (DUEL_SUBLIMATION §9): beat 0, the strike held; the plaza drops to black, the
victim alone, Ichigo gone; white streaks from every angle cross him faster and faster; one white frame; behind Ichigo, low,
facing away, the victim collapsed beyond: the brush 超速連斬, the hanko, the impact, the Konpaku; wide, the ink settling."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.8 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-k-f1 :blend 2 :time (/ 14.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :clone :pitch 0.8))
  (at 12 (card :black v) (shot-on v 30 5.0 1.2 :look 1.2) (lens 45) (play-sfx :hoho-out) (silence 14))
  (during (24 96) (let ((q (pos-of v)) (ang (+ 0.5 (* 4.0 u))))   ; a slow orbit while the streaks fly
                    (cine-cam (+ (aref q 0) (* 4.6 (cos ang))) 1.5 (+ (aref q 2) (* 4.6 (sin ang))) (aref q 0) 1.1 (aref q 2))))
  (during (24 100) (let ((q (pos-of v)))                          ; a streak every second frame, quicker toward the end, each fading over five
                     (dotimes (back 5)
                       (let* ((k (- cf back)) (th (* 2.399963 k)) (dy (* 0.7 (sin (* 1.3 k)))) (fade (- 1.0 (* 0.2 back))))
                         (when (zerop (mod k 2))
                           (fx-line (+ (aref q 0) (* 1.9 (cos th))) (+ 1.1 dy) (+ (aref q 2) (* 1.9 (sin th)))
                                    (- (aref q 0) (* 1.9 (cos th))) (- 1.1 dy) (- (aref q 2) (* 1.9 (sin th)))
                                    0.03 1.0 1.0 1.0 fade))))))
  (at 30 (play-sfx :cut)) (at 44 (play-sfx :cut :pitch 1.1)) (at 56 (play-sfx :cut :pitch 0.95)) (at 66 (play-sfx :cut :pitch 1.15))
  (at 74 (play-sfx :cut :pitch 1.2)) (at 80 (play-sfx :cut-heavy) (shake 0.2 0.3))
  (at 96 (card nil) (ui-flash 1 1 1 1 6.0) (silence 10) (lens 50))
  (at 106 (face-each-other a v 3.2) (card :black) (back-rim 56 0.82 0.06 0.11) (shot-on a 155 3.2 0.55 :look 1.3 :off -0.5)
      (cine-clip a :ic-k-stance :blend 0) (cine-clip v :sh-crumple :blend 0)
      (caption "超速連斬" :reading "CHOSOKU RENZAN" :sub "KESSA NO ICHIGO  KIKON" :side 1 :hanko t))
  (at 110 (impact-frame :negative 2)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (play-sfx :explode :pitch 0.6 :gain 0.6) (shake 0.3 0.4))
  (at 112 (impact-frame :manga 12))
  (at 148 (card nil) (caption-exit) (shot-on a 150 7.0 2.0 :look 1.4) (lens 50)))

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

;;; the pointer-linked Kikons (DUEL_CORE §5b / §6, the user 2026-10-28: each SP pointer's NS, its AS and its Kikon share one
;;; theme): the Shikai's pointer 1 (the cleaver's weight) and 3 (the rush), KESSA's pointer 1 (the blood chains)
(defun vfx-ic-glow-blade (e k)
  "The Shikai's yellow-white reiatsu gathered along E's held cleaver (the Getsuga's colour, core 3), presence K."
  (ic-blade e)
  (let ((b *ic-v*) (w *ic-w*))
    (fx-line (aref b 0) (aref b 1) (aref b 2) (aref w 0) (aref w 1) (aref w 2) (+ 0.1 (* 0.2 k)) 1.0 0.86 0.45 (* 0.6 k) :mode :alpha)
    (fx-line (aref b 0) (aref b 1) (aref b 2) (aref w 0) (aref w 1) (aref w 2) (+ 0.03 (* 0.06 k)) 1.0 0.97 0.85 k)
    (%light (aref w 0) (aref w 1) (aref w 2) 1.0f0 0.86f0 0.45f0 5f0 (f32 (* 2.0 k)) 8)))

(defun vfx-ic-split (px pz ux uz l k)
  "RAKUGA's split: a jagged ink gash L m along the plaza from (PX PZ) along (UX UZ), a yellow-white ember in it, presence K."
  (let ((n 14) (rx (- uz)) (rz ux))
    (dotimes (i n)
      (flet ((pt (j) (let ((s (* l (/ j (float n)))) (o (* 0.18 (sin (* 2.7 j)) (- 1.0 (/ j (float n))))))
                       (values (+ px (* s ux) (* o rx)) (+ pz (* s uz) (* o rz))))))
        (multiple-value-bind (x0 z0) (pt i)
          (multiple-value-bind (x1 z1) (pt (1+ i))
            (let ((w (* 0.32 (- 1.0 (* 0.8 (/ i (float n)))))))
              (fx-line x0 0.03 z0 x1 0.03 z1 w 0.02 0.02 0.03 k :end-width (* 0.85 w) :mode :alpha)
              (fx-line x0 0.04 z0 x1 0.04 z1 (* 0.3 w) 1.0 0.9 0.55 (* 0.9 k) :end-width (* 0.25 w)))))))))

(defcine ic-heavy-kikon-cine (a v :len 180 :hold 124)
  "落牙 RAKUGA, the Shikai's pointer-1 Kikon (the cleaver's weight, like NS1 / AS1): beat 0, the overhead cut held; a white
card, the brush 落牙 and the hanko, silence; low in front: the cleaver raised overhead and held, yellow-white reiatsu
gathering on it, the plaza's dust lifting; side-on and wide: the hop and the crushing drop, the plaza split ahead of
him to the victim and beyond, the shake; on the victim as the split reaches him: the impact, the Konpaku; from behind
Ichigo low, the gash smoking; wide."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.6 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-drop :blend 2 :time (/ 23.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-heavy :pitch 0.9))
  (at 12 (card :white a) (shot-on a 30 3.2 0.7 :look 1.1 :off -0.8) (lens 44 -8) (silence 40)
      (caption "落牙" :reading "RAKUGA" :sub "ICHIGO  KIKON" :side 1 :ink t :hanko t))
  (at 52 (card nil) (caption-exit) (face-each-other a v 4.2) (shot-on a 50 5.0 0.5 :look 1.7) (lens 50)
      (cine-clip a :ic-ns1 :blend 6 :time (/ 16.0 60.0) :speed 0.0) (play-sfx :awaken-rise :pitch 0.6))
  (during (58 112) (vfx-ic-glow-blade a (min 1.0 (* 1.5 u))))
  (during (60 112) (let ((p (pos-of a)))                       ; the plaza's dust lifting round him
                     (when (< (rnd01) 0.6)
                       (%t-blob (+ (aref p 0) (rnd-range -1.6f0 1.6f0)) 0.1f0 (+ (aref p 2) (rnd-range -1.6f0 1.6f0))
                                0f0 0.6f0 0f0 0.9f0 0.06f0 -0.05f0 0.1f0 +pal-ash+))))
  (at 84 (shake 0.08 0.4) (play-sfx :awaken-rise :pitch 0.8 :gain 0.6))
  (at 100 (shot-on a 90 7.0 1.0 :look 1.2 :ahead 2.0) (lens 44)
      (cine-clip a :ic-drop :blend 0 :time (/ 9.0 60.0)) (play-sfx :whoosh-heavy :pitch 0.7))
  (at 112 (impact-frame :negative 2) (play-sfx :ground-crack) (play-sfx :explode :pitch 0.5) (shake 0.45 0.6)
      (multiple-value-bind (px pz ux uz) (ic-line-from a v)
        (stage-crack-add (+ px (* 1.6 ux)) (+ pz (* 1.6 uz)) 2.6)
        (vfx-shockwave (+ px (* 1.6 ux)) (+ pz (* 1.6 uz)) 4.0 0.5 :rgb '(1.0 0.9 0.5))))
  (at 114 (impact-frame :manga 6))
  (during (112 180) (multiple-value-bind (px pz ux uz d) (ic-line-from a v)   ; the split running out to him and beyond
                      (let ((l (* (+ d 6.0) (min 1.0 (/ (- cf 112) 12.0)))) (k (if (< cf 150) 0.95 (max 0.0 (- 0.95 (* 0.03 (- cf 150)))))))
                        (vfx-ic-split (+ px (* 1.6 ux)) (+ pz (* 1.6 uz)) ux uz l k)
                        (when (and (< cf 136) (< (rnd01) 0.7))      ; ink debris kicked up along it
                          (let ((s (rnd-range 0f0 (f32 l))))
                            (%t-shard (+ px (* (+ 1.6 s) ux)) 0.1f0 (+ pz (* (+ 1.6 s) uz)) (rnd-range -1f0 1f0) (rnd-range 3f0 6f0)
                                      (rnd-range -1f0 1f0) 0.3f0 0.06f0 0f0 +pal-ink+))))))
  (at 118 (shot-on v 150 5.0 1.0 :look 1.2) (lens 50))
  (at 124 (impact-frame :negative 2) (cine-clip v :sh-crumple :blend 3)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-hit x (+ y 0.3) z :heavy))
      (impact-splash-at v 0.0 14 0.08)
      (stage-crack-add (aref (pos-of v) 0) (aref (pos-of v) 2) 2.0)
      (play-sfx :konpaku-shatter) (play-sfx :explode :pitch 0.6 :gain 0.6) (shake 0.3 0.4))
  (at 126 (impact-frame :manga 12))
  (at 142 (shot-on a 165 4.6 0.5 :look 1.0) (lens 40) (cine-clip a :ic-stance :blend 12))
  (at 166 (shot-on a 150 7.5 2.2 :look 1.2) (lens 50)))

(defparameter *cine-rush-dirs* '(0.4 3.0 5.2 1.7 4.1 0.9)
  "連斬: the six flash-step dashes' directions through the victim (radians round him), one every 12 f from frame 22.")

(defcine ic-rush-kikon-cine (a v :len 180 :hold 124)
  "連斬 RENZAN, the Shikai's pointer-3 Kikon (the rush, like NS3 / AS3): beat 0, the last RANGETSU cut held; the plaza to
black, the victim alone, Ichigo gone; orbiting the victim: six flash-step dashes through him from six quarters, each a
grey Shikai afterimage, a yellow-white streak and a white slash where it passes; one white frame; side-on, the pounce
TSUKI-OTOSHI, both blades slammed down on him; a black card, behind Ichigo low, the brush 連斬 and the hanko, the
impact, the Konpaku; wide."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.8 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-rangetsu :blend 2 :time (/ 17.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :cut :pitch 0.9))
  (at 12 (card :black v) (shot-on v 30 5.0 1.2 :look 1.2) (lens 50) (play-sfx :hoho-out) (silence 10))
  (at 22 (lens 40))
  (during (22 98) (let* ((q (pos-of v)) (ang (+ 0.5 (* 4.4 u))))   ; orbiting him
                    (cine-cam (+ (aref q 0) (* 5.5 (cos ang))) 1.5 (+ (aref q 2) (* 5.5 (sin ang))) (aref q 0) 1.1 (aref q 2))))
  (during (22 104) (let ((q (pos-of v)))
                     (loop for ang in *cine-rush-dirs* for i from 0
                           do (let* ((st (+ 22 (* 12 i))) (r (- 9.0 (* 40.0 (/ (- cf st) 60.0)))))
                                (ic-cine-charge (aref q 0) (aref q 2) ang st cf 40.0 0.0 (if (evenp i) :ic-rangetsu :ic-f1) t)
                                (when (and (>= cf st) (< r 8.0) (> r -6.0))   ; the flash step's yellow-white streak behind it
                                  (let ((r0 (min 9.0 (+ r 6.0))) (r1 (max -6.0 r)) (k (min 0.8 (* 0.12 (+ r 6.0)))))
                                    (fx-line (+ (aref q 0) (* r0 (cos ang))) 1.0 (+ (aref q 2) (* r0 (sin ang)))
                                             (+ (aref q 0) (* r1 (cos ang))) 1.0 (+ (aref q 2) (* r1 (sin ang)))
                                             0.03 1.0 0.9 0.55 k :end-width 0.12)))))))
  (at 36 (play-sfx :cut) (cine-clip v :sh-stagger :blend 2)) (at 48 (play-sfx :cut :pitch 1.1))
  (at 60 (play-sfx :cut :pitch 0.95) (cine-clip v :sh-flinch :blend 2)) (at 72 (play-sfx :cut :pitch 1.15))
  (at 84 (play-sfx :cut :pitch 1.05) (cine-clip v :sh-stagger :blend 2)) (at 96 (play-sfx :cut-heavy) (shake 0.2 0.3))
  (at 100 (card nil) (ui-flash 1 1 1 1 6.0) (silence 6))
  (at 104 (face-each-other a v 2.4) (shot-on a 80 6.0 1.3 :look 1.4 :ahead 1.2) (lens 44)
      (cine-clip a :ic-tsuki-otoshi :blend 0 :time (/ 6.0 60.0)) (cine-clip v :sh-stagger :blend 0) (play-sfx :whoosh-heavy))
  (during (104 116) (vfx-ic-glow-blade a 0.9))
  (at 116 (impact-frame :negative 2) (play-sfx :cut-heavy) (play-sfx :explode :pitch 0.6) (shake 0.35 0.5)
      (let ((q (pos-of v))) (stage-crack-add (aref q 0) (aref q 2) 2.2) (vfx-shockwave (aref q 0) (aref q 2) 3.5 0.5 :rgb '(1.0 0.9 0.5))))
  (at 118 (face-each-other a v 3.2) (card :black) (back-rim 56 1.0 0.86 0.45) (shot-on a 155 3.2 0.55 :look 1.3 :off -0.5)
      (cine-clip a :ic-stance :blend 0) (cine-clip v :sh-crumple :blend 0)
      (caption "連斬" :reading "RENZAN" :sub "ICHIGO  KIKON" :side 1 :hanko t))
  (at 124 (impact-frame :negative 2)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (play-sfx :explode :pitch 0.6 :gain 0.6) (shake 0.3 0.4))
  (at 126 (impact-frame :manga 12))
  (at 166 (card nil) (caption-exit) (shot-on a 150 7.0 2.0 :look 1.4) (lens 50)))

(defparameter *cine-chain-grips* '(:upper-arm-l :upper-arm-r :thigh-l :thigh-r)
  "血鎖: where each of KESSA's four chains (*IC-CHAIN-ROOTS*' order) binds the victim.")

(defun vfx-ic-chain-bind (a v reach k)
  "KESSA's four blood chains (wrists, ankles) cast at V: each tip REACH (0..1) of the way from its root to its grip on V,
arcing up on the way; presence K."
  (loop for (j lx ly lz) in *ic-chain-roots* for g in *cine-chain-grips* for i from 0
        do (let* ((r (ic-joint a (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                  (w (ic-joint v (joint-index g) *ic-ct*)) (s (min 1.0 (max 0.0 (- (* 1.2 reach) (* 0.05 i)))))
                  (x0 (aref r 0)) (y0 (aref r 1)) (z0 (aref r 2)))
             (when (> s 0.0)
               (vfx-ic-chain x0 y0 z0 (+ x0 (* s (- (aref w 0) x0))) (+ y0 (* s (- (aref w 1) y0)) (* 0.9 (sin (* pi s)) (- 1.0 s)))
                             (+ z0 (* s (- (aref w 2) z0))) (if (= i 0) k (* 0.85 k)))))))

(defun vfx-ic-chain-wrap (v tm k)
  "Two coils of blood chain round V's chest and thighs, turning with TM; presence K."
  (let ((q (pos-of v)))
    (dolist (hy '(1.2 0.6))
      (dotimes (i 8)
        (let ((a0 (+ (* 0.05 tm hy) (* i 0.785))) (a1 (+ (* 0.05 tm hy) (* (1+ i) 0.785))))
          (vfx-ic-chain (+ (aref q 0) (* 0.42 (cos a0))) (+ hy (* 0.04 i)) (+ (aref q 2) (* 0.42 (sin a0)))
                        (+ (aref q 0) (* 0.42 (cos a1))) (+ hy (* 0.04 (1+ i))) (+ (aref q 2) (* 0.42 (sin a1))) k))))))

(defcine ic-chain-kikon-cine (a v :len 180 :hold 124)
  "血鎖 KESSA, KESSA's pointer-1 Kikon (the blood chains, like NS1 / AS1): beat 0, the whip's slam held; a black card, a
BLOOD back-rim, the brush 血鎖 and the hanko, his four chains (wrists, ankles) uncoiling round him; wide from behind:
the chains lash out and bind the victim, coiled round chest and thighs; on the victim, caught; Ichigo yanks him in
across the plaza; the slab's cut, a blood slash; the chains snap off, the impact, the Konpaku; wide, the chains back
round him."
  (at 0 (face-each-other a v 2.6) (shot-on a 60 3.8 1.1 :look 1.1) (lens 50)
      (cine-clip a :ic-k-whip :blend 2 :time (/ 26.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :chain-snap))
  (at 12 (card :black a) (back-rim 40 0.82 0.06 0.11) (shot-on a 20 4.2 0.9 :look 1.1 :off 0.9) (lens 42) (silence 20)
      (cine-clip a :ic-k-st-chain :blend 6) (play-sfx :chain-rattle :pitch 0.7)
      (caption "血鎖" :reading "KESSA" :sub "KESSA NO ICHIGO  KIKON" :side 0 :hanko t))
  (during (12 52) (let ((p (pos-of a)) (g (min 1.0 (* 2.0 u))))   ; the chains uncoiling round him
                    (loop for (j lx ly lz) in *ic-chain-roots* for i from 0
                          do (let* ((r (ic-joint a (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                                    (x0 (aref r 0)) (y0 (aref r 1)) (z0 (aref r 2)))
                               (dotimes (k 3)
                                 (let* ((an (+ (* 0.06 cf) (* i 1.571) (* (1+ k) 0.6))) (rr (* g (+ 0.7 (* 0.25 k))))
                                        (x1 (+ (aref p 0) (* rr (cos an)))) (z1 (+ (aref p 2) (* rr (sin an))))
                                        (y1 (+ 0.4 (* 0.35 (mod i 2)) (* g 0.3 k))))
                                   (vfx-ic-chain x0 y0 z0 x1 y1 z1 0.9)
                                   (setf x0 x1 y0 y1 z0 z1)))))))
  (at 52 (card nil) (caption-exit) (face-each-other a v 7.0) (shot-on a 150 5.0 1.6 :look 1.1 :off 0.6) (lens 44)
      (cine-clip a :ic-k-whip :blend 3 :time (/ 6.0 60.0)) (play-sfx :chain-rattle))
  (during (52 66) (vfx-ic-chain-bind a v u 0.95))
  (at 66 (play-sfx :chain-snap) (shake 0.15 0.3) (cine-clip v :sh-stagger :blend 2) (impact-frame :negative 1))
  (during (66 108) (vfx-ic-chain-bind a v 1.0 0.95))
  (during (70 108) (vfx-ic-chain-wrap v cf (min 0.9 (* 4.0 u))))
  (at 72 (shot-on v 35 3.8 0.9 :look 1.1) (lens 52) (play-sfx :chain-rattle :pitch 0.8))
  (at 88 (shot-on a 90 7.5 1.3 :look 1.1 :ahead 2.5) (lens 44)
      (cine-clip a :ic-k-yank :blend 0 :time (/ 14.0 60.0)) (play-sfx :chain-snap :pitch 0.8) (shake 0.2 0.3))
  (when (and step-p (< 88 cf 100)) (face-each-other a v (- 7.0 (* 0.4 (- cf 88)))))   ; reeled in, 7 m -> 2.2 m
  (at 100 (cine-clip a :ic-k-f3 :blend 0 :time (/ 17.0 60.0)) (cine-clip v :sh-launch :blend 0)
      (shot-on a 60 5.2 1.2 :look 1.2 :ahead 1.2) (lens 44) (impact-frame :negative 2)
      (play-sfx :cut-heavy) (play-sfx :chain-snap) (shake 0.3 0.4))
  (during (100 112) (let ((q (pos-of v)) (yaw (yaw-of v)) (k (- 0.95 (* 0.8 u))))   ; the slab's blood slash across him
                      (fx-line (+ (aref q 0) (* 1.0 (fwd-z yaw))) 2.0 (- (aref q 2) (* 1.0 (fwd-x yaw)))
                               (- (aref q 0) (* 1.0 (fwd-z yaw))) 0.3 (+ (aref q 2) (* 1.0 (fwd-x yaw))) 0.16 0.82 0.06 0.11 k :mode :alpha)
                      (fx-line (+ (aref q 0) (* 1.0 (fwd-z yaw))) 2.0 (- (aref q 2) (* 1.0 (fwd-x yaw)))
                               (- (aref q 0) (* 1.0 (fwd-z yaw))) 0.3 (+ (aref q 2) (* 1.0 (fwd-x yaw))) 0.04 1.0 1.0 1.0 k)))
  (at 112 (card :black) (back-rim 40 0.82 0.06 0.11) (shot-on v 150 3.8 1.1 :look 1.1) (lens 50) (cine-clip v :sh-crumple :blend 4))
  (at 124 (impact-frame :negative 2)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-hit x (+ y 0.3) z :heavy))
      (impact-splash-at v 0.0 14 0.1)
      (play-sfx :konpaku-shatter) (play-sfx :chain-snap) (play-sfx :explode :pitch 0.6 :gain 0.6) (shake 0.3 0.4))
  (at 126 (impact-frame :manga 12))
  (at 150 (card nil) (shot-on a -30 6.0 1.4 :look 1.1) (lens 50) (cine-clip a :ic-k-stance :blend 10))
  (during (150 180) (let ((p (pos-of a)) (g (min 1.0 (* 3.0 u))))   ; the chains back round him
                      (loop for (j lx ly lz) in *ic-chain-roots* for i from 0
                            do (let* ((r (ic-joint a (joint-index j) *ic-cb* (f32 lx) (f32 ly) (f32 lz)))
                                      (an (+ (* 0.05 cf) (* i 1.571))) (rr (* g 0.85)))
                                 (vfx-ic-chain (aref r 0) (aref r 1) (aref r 2) (+ (aref p 0) (* rr (cos an))) (+ 0.5 (* 0.3 (mod i 2)))
                                               (+ (aref p 2) (* rr (sin an))) 0.8))))))

;;; ---------------------------------------------------------------- the Getsuga's flame: a PREVIEW (the user, 2026-10-31: 「調整月牙天衝的特效設計，變成更加自然滑順的燄氣
;;; 效果。請在實作進遊戲前先以純粹的角色模組展現給我確認」): the crescent is a row of smooth flame tongues (the engine's toon ribbons, as the
;;; fire of Senjumaru / Lille), black with a violet-blue rim, flowing back off the arc and curling at the tips like the reference's
;;; torn ribbons; nothing in the game calls it (only the cinematic below, debug 86130)
(defun ic-flame-tongues (cx cy cz yaw r span k tm n)
  "N flame tongues along an arc of radius R, SPAN radians, in the vertical plane of YAW centred on (CX CY CZ) (its convex side
forward): each flows back (and curls along the arc toward its tip), longest at the middle, a black body, a violet-blue rim tongue
beside it; K presence, TM the phase."
  (let ((fx (fwd-x yaw)) (fz (fwd-z yaw)) (pi* 3.14159))
    (dotimes (i n)
      (let* ((u (/ (+ i 0.5) n)) (a (* span (- u 0.5))) (ca (cos a)) (sa (sin a)) (sg (if (< a 0.0) -1.0 1.0))
             (env (sin (* pi* u)))
             (px (+ cx (* r ca fx))) (py (+ cy (* r sa))) (pz (+ cz (* r ca fz)))
             (len (* r (+ 0.45 (* 1.15 env)) (+ 0.85 (* 0.15 (sin (+ (* 5.0 tm) (* 1.3 i)))))))
             (cur (* 0.8 (- 1.0 env)))                       ; the tips curl along the arc
             (ax (* len (+ (* -0.9 fx) (* cur sg (- sa) fx)))) (ay (* len (* cur sg ca))) (az (* len (+ (* -0.9 fz) (* cur sg (- sa) fz))))
             (w (* r (+ 0.035 (* 0.1 env)))) (sway (* 0.1 len)) (ph (+ (* 4.0 tm) (* 1.7 i))) (sd (+ (* 1.0 i) (drawing-no))))
        (%tongue (f32 px) (f32 py) (f32 pz) (f32 ax) (f32 ay) (f32 az) (f32 w) +pal-black-smoke+ (f32 (* 0.95 k)) (f32 sd) (f32 ph) (f32 sway) :segs 10 :wob 0.02)
        (when (evenp i)
          (%tongue (f32 (+ px (* 0.03 r fx))) (f32 py) (f32 (+ pz (* 0.03 r fz))) (f32 (* 0.8 ax)) (f32 (* 0.8 ay)) (f32 (* 0.8 az))
                   (f32 (* 0.45 w)) +pal-blood+ (f32 (* 0.8 k)) (f32 (+ sd 50.0)) (f32 (+ ph 1.1)) (f32 (* 1.3 sway)) :segs 8 :wob 0.02))))))

(defun ic-flame-sheets (cx cy cz yaw r span k tm n)
  "N wide flat flame ribbons (sheets) along the same arc as IC-FLAME-TONGUES, each flowing back and curling at the tips, broad at the
base and narrowing to a point, a blood-red sheet riding on every black one and an ember core on every third (red-black, the user, 2026-10-31: 「卍解的月牙顏色是紅黑色不是藍黑色的」; 「片狀絲帶的焰氣特效」)."
  (let ((fx (fwd-x yaw)) (fz (fwd-z yaw)) (pi* 3.14159))
    (dotimes (i n)
      (let* ((u (/ (+ i 0.5) n)) (a (* span (- u 0.5))) (ca (cos a)) (sa (sin a)) (sg (if (< a 0.0) -1.0 1.0))
             (env (sin (* pi* u)))
             (px (+ cx (* r ca fx))) (py (+ cy (* r sa))) (pz (+ cz (* r ca fz)))
             (len (* r (+ 0.9 (* 1.7 env)) (+ 0.9 (* 0.1 (sin (+ (* 4.0 tm) (* 1.9 i)))))))
             (cur (* 0.9 (- 1.0 env)))
             (ax (* len (+ (* -0.9 fx) (* cur sg (- sa) fx)))) (ay (* len (* cur sg ca))) (az (* len (+ (* -0.9 fz) (* cur sg (- sa) fz))))
             (w (* r (+ 0.14 (* 0.3 env)))) (sway (* 0.14 len)) (ph (+ (* 3.0 tm) (* 1.3 i))) (sd (+ (* 2.0 i) (drawing-no))))
        (%tongue (f32 px) (f32 py) (f32 pz) (f32 ax) (f32 ay) (f32 az) (f32 w) +pal-black-smoke+ (f32 (* 0.95 k)) (f32 sd) (f32 ph) (f32 sway) :segs 12 :wob 0.0)
        (%tongue (f32 (+ px (* 0.04 r fx))) (f32 py) (f32 (+ pz (* 0.04 r fz))) (f32 (* 0.85 ax)) (f32 (* 0.85 ay)) (f32 (* 0.85 az))
                 (f32 (* 0.8 w)) +pal-blood+ (f32 (* 0.85 k)) (f32 (+ sd 50.0)) (f32 (+ ph 1.1)) (f32 (* 1.2 sway)) :segs 10 :wob 0.0)
        (when (zerop (mod i 3))
          (%tongue (f32 (+ px (* 0.06 r fx))) (f32 py) (f32 (+ pz (* 0.06 r fz))) (f32 (* 0.7 ax)) (f32 (* 0.7 ay)) (f32 (* 0.7 az))
                   (f32 (* 0.3 w)) +pal-ember+ (f32 (* 0.8 k)) (f32 (+ sd 90.0)) (f32 (+ ph 2.0)) (f32 (* 1.1 sway)) :segs 8 :wob 0.0))))))

(defun ic-getsuga-flame (cx cy cz yaw r k tm)
  "KESSA's Getsuga crescent as flame: nine broad flat ribbons and nothing finer (the thin tongues read as strands of hair: the user,
2026-10-31: 「月牙本身不要有像髮絲的焰氣」)."
  (ic-flame-sheets cx cy cz yaw r 3.2 k tm 9))

(defun ic-flame-preview (e cf)
  "The preview's Getsuga at frame CF of its loop (90 f): gathering on the blade (to f14), thrown (f14-24), flying on and thinning out."
  (let* ((p (pos-of e)) (yaw (yaw-of e)) (fx (fwd-x yaw)) (fz (fwd-z yaw))
         (g (max 0.0 (- cf 14.0))) (k (* (min 1.0 (/ g 6.0)) (- 1.0 (min 1.0 (/ (max 0.0 (- cf 62.0)) 24.0)))))
         (r (+ 0.5 (min 0.9 (* 0.05 g)))) (d (+ 0.9 (min 1.7 (* 0.06 g)))))
    (when (> k 0.01)
      (ic-getsuga-flame (+ (aref p 0) (* d fx)) 1.35 (+ (aref p 2) (* d fz)) yaw r k (/ cf 60.0))
      (%light (f32 (+ (aref p 0) (* d fx))) 1.35f0 (f32 (+ (aref p 2) (* d fz))) 0.45f0 0.25f0 0.9f0 5f0 (f32 (* 1.5 k)) 8))))

(defcine ic-flame-cine (a v :len 9999 :hold 1)
  "The Getsuga flame preview (debug 86130): KESSA alone on a white card, side-on, his swing (K1's clip) at 1x, the flame loop on it."
  (at 0 (card :white) (face-each-other a v 9.0) (shot-on a 90 9.0 1.4 :look 1.2) (lens 42)
      (cine-clip a :ic-k-f1 :blend 0) (cine-clip v :sh-kikon-victim :blend 0))
  (during (0 9999) (ic-flame-preview a (mod cf 90))))

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
