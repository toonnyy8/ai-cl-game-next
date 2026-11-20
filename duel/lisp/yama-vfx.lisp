;;;; yama-vfx.lisp — YAMAMOTO GENRYUSAI's effects (moved out of vfx.lisp, refactor round 2, the user 2026-10-21): the Bankai's
;;;; blade embers, the fireball, Tenchi Kaijin's slash and ash (the Shikai's fire looks, the blade's fire among them, are yama-look.lisp's
;;;; since art S1, DUEL_YAMA_CORE §22: the old wave / pillar / dome looks left with their placeholders),
;;;; the skeleton dust, Taimatsu's cone, and the stamp looks only he uses (%ST-CONE %ST-BOOM %ST-GARB-GUARD %ST-SCORCH
;;;; %ST-FLARE %ST-GUTTER %ST-NADE %ST-EMBER %ST-SLIT %ST-WISPS) with their VFX-* wrappers. The universal stamp system
;;;; (STAMP, WITH-STAMP, %STAR ..., STAMPS-DRAW) is vfx-stamps.lisp's; STAMPS-DRAW calls these looks by name, so this file
;;;; loads after it. Same rules as vfx.lisp: cosmetic only (RND01, never SIM-RND01), x y z metres, AGE / LIFE / DT seconds.
(in-package :duel)

;;; ---------------------------------------------------------------- Yamamoto: the Bankai's blade embers
;;; Signature looks (docs/style/STYLE_STORM_DESIGN.md §4.1 / §4.2, Phase 3): drawn toon shapes in the layer order of §3.4 —
;;; a darker backing (ember, charcoal), the drawn mass (FIRE / REIATSU / EMBER), a thin additive T光 line, and
;;; scraps (toon particles) flying off. Shapes are re-drawn on the fx clock's drawings (DRAWING: twos, 12 a second),
;;; so they hold still between drawings like the universal effects; positions the game depends on never step
;;; (DRAWING-NO, engine fx.lisp).
(defun-fast vfx-blade-embers (x0 y0 z0 x1 y1 z1 dt)
  "Zanka no Tachi (§4.1 Bankai): every flame is gone. One thin EMBER line along the charred blade (drawn just in
front of it, a glowing additive core in it), its presence breathing (continuously since the flow sweep, STYLE_STORM_DESIGN §15.7;
on threes before), and a few ember flecks drifting up; the heat is the :HEAT aura's
charcoal wisps. Under the Bankai grade (spot-keep, hue 10) this line is the only colour in the frame."
  (with-floats (x0 y0 z0 x1 y1 z1 dt)
    (let* ((bx (- x1 x0)) (by (- y1 y0)) (bz (- z1 z0)) (fp (flow-ph)) (pal +pal-ember+)
           (pk (toon-a pal (+ 0.75f0 (* 0.2f0 (flow01 0f0 2.3f0 4f0))))) (sd -2f0))
      (declare (single-float bx by bz fp pal pk sd))
      (%away-from-eye (x0 y0 z0) -0.03f0
        (toon-ribbon (x0 y0 z0) (bx by bz) (0.026f0 0.016f0) :heat (1f0 0.5f0) :seed sd :wob 0.05f0 :k pk :ph fp :segs 3)
        (fx-ribbon x0 y0 z0 bx by bz 0.012f0 0.008f0 1f0 0.3f0 0.08f0 -0.9f0 1f0 0.3f0 0.08f0 -0.7f0 0f0 0f0 :segs 1))
      (dotimes (i (n-of 5f0 dt))
        (let* ((u (rnd01)))
          (declare (single-float u))
          (%t-blob (+ x0 (* u bx)) (+ y0 (* u by)) (+ z0 (* u bz)) (rnd-range -0.15f0 0.15f0) (rnd-range 0.3f0 0.7f0)
                   (rnd-range -0.15f0 0.15f0) (rnd-range 0.8f0 1.4f0) (rnd-range 0.015f0 0.028f0) -0.3f0 0.1f0 pal))))))

;;; ---------------------------------------------------------------- fireball

(defun-fast vfx-fireball (x y z size dirx dirz dt)
  "Shiranui (§4.1, Phase 5): a drawn FIRE disc of radius SIZE m (wobble 0.3), 5 tongues licking (flowing: §15.7)
back along the flight (DIRX DIRZ, unit) and curling up, a white-hot HIT core disc, flame scraps and a BLACK SMOKE wake
left behind (toon puffs, stepped on threes). The position never steps (the hazard moves it)."
  (with-floats (x y z size dirx dirz dt)
    (let* ((s size) (fp (flow-ph)) (sd 0f0))
      (declare (single-float s fp sd))
      (dotimes (k 5)                                     ; the tongues first: they stand behind the disc
        (let* ((f (i->f k)) (a (+ (* 1.2566f0 f) (* 0.6f0 (flow01 f 2.1f0)))) (ca (f-cos a)) (sa (f-sin a))
               (l (* s (+ 1.5f0 (* 1.1f0 (flow01 f 4.7f0)))))
               (ox (* 0.6f0 s ca (- dirz))) (oy (* 0.6f0 s sa)) (oz (* 0.6f0 s ca dirx)))
          (declare (single-float f a ca sa l ox oy oz))
          (%tongue (+ x ox) (+ y oy) (+ z oz) (+ (* (- l) dirx) (* 0.5f0 ox)) (+ (* 0.35f0 l) (* 0.5f0 oy)) (+ (* (- l) dirz) (* 0.5f0 oz))
                   (* 0.42f0 s) +pal-fire+ 0.95f0 (+ 40f0 (* 3f0 f) sd) (+ fp f) 0.04f0 :segs 5)))
      (fx-disc x y z s 0.3f0 (+ 30f0 sd) +pal-fire+ 0.95f0 :push (* 0.5f0 s))
      (fx-disc x y z (* 0.3f0 s) 0.2f0 (+ 35f0 sd) +pal-hit+ 0.98f0 :push (* 0.6f0 s))   ; the white-hot core (was a soft sprite)
      (dotimes (i (n-of 12f0 dt))                        ; scraps
        (%t-blob (+ x (* s (rnd-range -0.6f0 0.6f0))) (+ y (* s (rnd-range -0.4f0 0.6f0))) (+ z (* s (rnd-range -0.6f0 0.6f0)))
                 (* -2f0 dirx) (rnd-range 0.8f0 1.6f0) (* -2f0 dirz) (rnd-range 0.25f0 0.4f0) (* s (rnd-range 0.18f0 0.3f0)) -1f0 0.3f0
                 +pal-fire+))
      (dotimes (i (n-of 16f0 dt))                        ; the wake: black smoke left behind as it flies
        (%t-blob (- x (* 0.9f0 s dirx)) (+ y (* s (rnd-range -0.3f0 0.3f0))) (- z (* 0.9f0 s dirz)) (rnd-range -0.2f0 0.2f0)
                 (rnd-range 0.3f0 0.6f0) (rnd-range -0.2f0 0.2f0) (rnd-range 0.5f0 0.8f0) (* s (rnd-range 0.3f0 0.45f0)) -0.3f0 0.3f0
                 +pal-black-smoke+))
      (%light x y z 1f0 0.5f0 0.15f0 8f0 2f0 7))))


;;; ---------------------------------------------------------------- Tenchi Kaijin's slash (UI space)
(defvar *ts-c0* (make-f32 4)) (defvar *ts-c1* (make-f32 4))
(defun vfx-tenchi-slash (age life)
  "Tenchi Kaijin: a full-screen hard white slash (UI space) with an ink border, sweeping lower-left → upper-right
in 0.07 s, then thinning out over LIFE (no translucent wedge, no flash: the cinematic's two-tone frame is the
flash). Pair with the grey grade and VFX-ASH-BURST."
  (let* ((w (window-width)) (h (window-height)) (v (min 1.0 (/ age (max life 0.01))))
         (sweep (min 1.0 (/ age 0.07))) (th (* h 0.016 (+ 1 (* 2 (max 0.0 (- 1 (/ age 0.17))))) (- 1 (* v v v))))
         (ax (* -0.05 w)) (ay (* 0.8 h)) (bx (+ ax (* sweep 1.1 w))) (by (+ ay (* sweep -0.6 h)))
         (mx (* 0.5 (+ ax bx))) (my (* 0.5 (+ ay by)))
         (len (max 1.0 (sqrt (+ (expt (- bx ax) 2) (expt (- by ay) 2)))))
         (nx (/ (- ay by) len)) (ny (/ (- bx ax) len)))
    (flet ((spindle (k c)
             (%ui-poly4 ax ay (+ mx (* k nx)) (+ my (* k ny)) bx by bx by c c)
             (%ui-poly4 ax ay (- mx (* k nx)) (- my (* k ny)) bx by bx by c c)))
      (spindle (+ th (* 3 (ui-scale))) (%ui-col *ts-c0* 0.03 0.03 0.047 (- 1 (* v v))))
      (spindle th (%ui-col *ts-c1* 1 1 1 (- 1 (* v v)))))
    nil))

;;; ---------------------------------------------------------------- victim marks
(defun-fast vfx-ash-burst (x y z)
  "Tenchi Kaijin's victim flaking into ash (x y z = the feet; §4.1, Phase 5): 44 ASH shards peeling off the whole body
and drifting sideways (toon: matter, on threes), 16 ASH flakes and 6 BLACK SMOKE puffs. One-shot, mono."
  (with-floats (x y z)
    (let* ((sd (if (< (rnd01) 0.5f0) -1f0 1f0)))
      (declare (single-float sd))
      (dotimes (i 44)
        (%t-shard (+ x (rnd-range -0.3f0 0.3f0)) (+ y (rnd-range 0.1f0 1.8f0)) (+ z (rnd-range -0.3f0 0.3f0))
                  (* sd (rnd-range 0.8f0 2.2f0)) (rnd-range 0.2f0 0.9f0) (rnd-range -0.6f0 0.6f0) (rnd-range 1.2f0 2.2f0)
                  (rnd-range 0.06f0 0.14f0) -0.15f0 +pal-ash+))
      (dotimes (i 16)
        (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) (+ y (rnd-range 0.2f0 1.7f0)) (+ z (rnd-range -0.3f0 0.3f0)) (* sd (rnd-range 0.5f0 1.5f0))
                 (rnd-range 0.3f0 1f0) (rnd-range -0.4f0 0.4f0) (rnd-range 1f0 1.8f0) (rnd-range 0.04f0 0.08f0) -0.1f0 0.2f0 +pal-ash+))
      (dotimes (i 6)
        (%t-blob (+ x (rnd-range -0.25f0 0.25f0)) (+ y (rnd-range 0.3f0 1.5f0)) (+ z (rnd-range -0.25f0 0.25f0)) (* sd 0.6f0)
                 (rnd-range 0.4f0 0.9f0) 0f0 (rnd-range 0.9f0 1.3f0) (rnd-range 0.2f0 0.35f0) -0.3f0 0.3f0 +pal-black-smoke+)))
    nil))

(defun-fast vfx-skeleton-dust (x z)
  "Earth bursting where a South hand claws out (x z): 1 low DUST puff and 2 inked rocks (toon; more dust hid the arm).
One-shot."
  (with-floats (x z)
    (%t-blob x 0.1f0 z (rnd-range -0.8f0 0.8f0) (rnd-range 0.2f0 0.5f0) (rnd-range -0.8f0 0.8f0) 0.5f0 0.2f0 -0.2f0 0.25f0 +pal-dust+)
    (dotimes (i 2)
      (%t-shard x 0.2f0 z (rnd-range -2f0 2f0) (rnd-range 2f0 4f0) (rnd-range -2f0 2f0) (rnd-range 0.5f0 0.8f0)
                (rnd-range 0.07f0 0.12f0) 9f0 +pal-dust+))))

;;; ---------------------------------------------------------------- one-shots
(defun-fast vfx-fire-cone (x z yaw &key (reach 4.0) (half 0.785))
  "Taimatsu (§4.1, Phase 5): the drawn sweep of fire over the REACH m / +-HALF rad sector toward YAW, a :CONE stamp
(%ST-CONE: a white flash, 9 FIRE flames fanned over the sector rolling out and up, a FIRE ground sector for 2 drawings,
5 pale SMOKE puffs at the lip), a few flame scraps and an orange flash light. One-shot; call on the first active frame."
  (with-floats (x z yaw reach half)
    (let* ((fx (- (f-sin yaw))) (fz (- (f-cos yaw))))
      (declare (single-float fx fz))
      (stamp :cone x 0f0 z :dx fx :dz fz :scale reach :n half)
      (dotimes (i 8)
        (let* ((a (+ yaw (rnd-range (- half) half))) (sp (rnd-range 4f0 8f0)))
          (declare (single-float a sp))
          (%t-blob x 1f0 z (* sp (- (f-sin a))) (rnd-range 0.5f0 2.5f0) (* sp (- (f-cos a))) (rnd-range 0.3f0 0.5f0) (rnd-range 0.1f0 0.18f0)
                   -1f0 0.3f0 +pal-fire+)))
      (flash-light (+ x (* 0.5f0 reach fx)) 1.2 (+ z (* 0.5f0 reach fz)) 1.0 0.5 0.12)
      nil)))

;;; Phase 5 stamps (docs/style/STYLE_STORM_DESIGN.md §4.1 / §4.2 rows done in Phase 5): Taimatsu's cone, Jokaku Enjo's
;;; detonation, KUKAN-GIRI's ink gash, West's garb guard / scorch / flare / burnout, Nadegiri's cut
(defun-fast %st-cone (o)
  "Taimatsu (:cone): X Y Z the feet, DX DZ the facing, SC the reach, N the half angle (rad). Envelope 1 3 4 30: a white
flash, then 9 FIRE flames (a big tongue and a small one beside it) fanned over the sector, rolling out and up; a FIRE
ground sector for its first 2 drawings; 5 pale SMOKE puffs at the lip from the hold on (they perforate as it erodes)."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 2f0)) (yaw (f-atan2 (- dx) (- dz))) (dr drawing) (d5 (i->f (mod (f->i drawing) 5))))
      (declare (single-float a yaw dr d5))
      (fx-envelope (es k fl ph) (a 1 3 4 30)
        (cond ((= ph 1) (%flash (+ x (* 0.45f0 sc dx)) 0.9f0 (+ z (* 0.45f0 sc dz)) 0.35f0 seed))
              ((< ph 5)
               (when (< a 0.2f0)
                 (%sector-verts :toon 12 x 0f0 z 0.3f0 (* sc es) yaw n 1f0 (+ seed 7f0) 0.2f0 (toon-a +pal-fire+ (* 0.95f0 k))))
               (dotimes (i 9)
                 (let* ((f (i->f i)) (u (- (* 0.25f0 f) 1f0)) (an (+ yaw (* u n 0.85f0) (* 0.12f0 (- (hash01 f seed) 0.5f0))))
                        (fx (- (f-sin an))) (fz (- (f-cos an))) (d (+ (* sc (+ 0.25f0 (* 0.7f0 (hash01 (+ f 2.3f0) seed)))) (* 1.2f0 a)))
                        (bx (+ x (* d fx))) (bz (+ z (* d fz))) (by (* 0.9f0 a))
                        (hh (* es (+ 1f0 (* 0.7f0 (hash01 (+ f dr) seed))) (- 1f0 (* 0.3f0 u u)))))
                   (declare (single-float f u an fx fz d bx bz by hh))
                   (%tongue bx by bz (* 0.5f0 hh fx) (* 1.6f0 hh) (* 0.5f0 hh fz) (* 0.3f0 es) +pal-fire+ k (+ seed f (* 9f0 d5)) (+ dr f) 0.06f0
                            :segs 6)                     ; a big flame rolling out, a smaller one licking beside it
                   (%tongue (+ bx (* 0.35f0 fz)) by (- bz (* 0.35f0 fx)) (* 0.3f0 hh fx) (* 0.9f0 hh) (* 0.3f0 hh fz) (* 0.18f0 es) +pal-fire+ k
                            (+ seed f 20f0 d5) (+ dr f 0.5f0) 0.04f0 :segs 4)))
               (when (>= ph 3)
                 (dotimes (j 5)
                   (let* ((f (i->f j)) (an (+ yaw (* (- (* 0.5f0 f) 1f0) n 0.8f0))) (d (+ sc (* 0.8f0 a))))
                     (declare (single-float f an d))
                     (fx-disc (- x (* d (f-sin an))) (+ 0.5f0 (* 1.3f0 a)) (- z (* d (f-cos an))) (+ 0.3f0 (* 0.5f0 a)) 0.25f0
                              (+ seed f 30f0) +pal-smoke+ k))))))
        (= ph 5)))))

(defun-fast %st-boom (o)
  "Jokaku Enjo's detonation (:boom, SC the dome radius): envelope 1 3 6 24 — a white flash, then a 14-spike FIRE star
over a larger EMBER one (its dark-red backing) with a white core for 2 drawings, eroding."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 2f0)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 3 6 24)
        (cond ((= ph 1) (%flash x y z (* 0.6f0 sc) seed))
              ((< ph 5)
               (%star x y z (* 0.5f0 sc) (* 1.55f0 sc es) 14 0f0 0f0 0.12f0 (+ seed 3f0) +pal-ember+ k 0.2f0)
               (%star x y z (* 0.45f0 sc) (* 1.3f0 sc es) 14 0f0 0f0 0.12f0 seed +pal-fire+ k 0.3f0)
               (when (< ph 4) (%star x y z (* 0.15f0 sc) (* 0.4f0 sc es) 9 0f0 0f0 0.08f0 (+ seed 5f0) +pal-hit+ k 0.4f0))))
        (= ph 5)))))

(defun-fast %st-garb-guard (o)
  "A hit the garb guard blocks (:garb-guard; West, §4.1 GOKUI GAESHI row, Phase 5): the guard's hexagon drawn in fire —
an EMBER hexagon with a white HIT core hexagon (it reads as a block by shape, as a burn by value) — 5 EMBER sparks flung
back along DX DZ (toward the attacker) and two BLACK SMOKE curls rising off it. Envelope 1 2 3 10."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)) (dr drawing))
      (declare (single-float a dr))
      (fx-envelope (es k fl ph) (a 1 2 3 10)
        (cond ((= ph 1) (%flash x y z (* sc 0.2f0) seed))
              ((< ph 5)
               (fx-star x y z 1f0 (* sc 0.46f0 es) 6 (* 0.5236f0 (hash01 2.1f0 seed)) 0f0 0f0 0.05f0 seed +pal-ember+ k :push 0.4f0)
               (when (< ph 4)
                 (fx-star x y z 1f0 (* sc 0.24f0 es) 6 (* 0.5236f0 (hash01 2.1f0 seed)) 0f0 0f0 0.03f0 (+ seed 1f0) +pal-hit+ k :push 0.44f0))
               (%shards-out 5 x y z sdx sdy a 5f0 (* sc 0.22f0) (* sc 0.035f0) +pal-ember+ k seed 1.2f0 0.46f0)
               (dotimes (j 2)
                 (let* ((f (i->f j)) (off (* sc (- (* 0.3f0 f) 0.15f0))))
                   (declare (single-float f off))
                   (%tongue (+ x off) (+ y 0.1f0) z (* 0.1f0 (- (hash01 (+ f dr) seed) 0.5f0)) (* sc es (+ 0.35f0 (* 1.2f0 a))) 0f0
                            (* sc 0.06f0) +pal-black-smoke+ k (+ seed f (* 3f0 (i->f (mod (f->i dr) 3))) 200f0) (+ dr f) 0.08f0 :segs 5 :wob 0.35f0)))))
        (= ph 5)))))

(defun-fast %st-scorch (o)
  "The garb scorching an attacker (:scorch, at his sword hand; Phase 5): a small white flash, an EMBER star for 2
drawings, then two BLACK SMOKE curls rising off the arm (mono: a white burn, black smoke; the ember is the only
colour). Envelope 1 2 4 16."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)) (dr drawing))
      (declare (single-float a dr))
      (fx-envelope (es k fl ph) (a 1 2 4 16)
        (cond ((= ph 1) (%flash x y z 0.12f0 seed))
              ((< ph 5)
               (when (< ph 4) (%star x y z 0.05f0 (* 0.22f0 es) 7 0f0 1f0 0.06f0 seed +pal-ember+ k 0.35f0))
               (dotimes (j 2)
                 (let* ((f (i->f j)))
                   (declare (single-float f))
                   (%tongue (+ x (* 0.12f0 (- f 0.5f0))) y z (* 0.15f0 (- (hash01 (+ f dr) seed) 0.5f0)) (+ 0.3f0 (* 1.4f0 a)) 0f0 0.07f0
                            +pal-black-smoke+ k (+ seed f (* 3f0 (i->f (mod (f->i dr) 3))) 210f0) (+ dr f) 0.08f0 :segs 5 :wob 0.35f0)))))
        (= ph 5)))))

(defun-fast %st-flare (o)
  "The garb flaring as it absorbs a ranged hit (:flare, at the feet; Phase 5): 12 FIRE tongues thrown out round him, low
and leaning out, and an EMBER ring running out. Envelope 1 2 3 12."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)) (dr drawing) (d5 (i->f (mod (f->i drawing) 5))))
      (declare (single-float a dr d5))
      (fx-envelope (es k fl ph) (a 1 2 3 12)
        (when (and (> ph 0) (< ph 5))
          (dotimes (i 12)
            (let* ((f (i->f i)) (an (+ (* 0.5236f0 f) (* 0.3f0 (hash01 f seed)))) (c (f-cos an)) (sn (f-sin an))
                   (r (+ 0.35f0 (* 2.2f0 a))) (hh (* es (+ 0.7f0 (* 0.6f0 (hash01 (+ f dr) seed))))))
              (declare (single-float f an c sn r hh))
              (%tongue (+ x (* r c)) (+ y 0.05f0) (+ z (* r sn)) (* 0.5f0 hh c) hh (* 0.5f0 hh sn) 0.14f0 +pal-fire+ k (+ seed f (* 12f0 d5)) (+ dr f)
                       0.03f0 :segs 4)))
          (%tring x y z (+ 0.4f0 (* 4.5f0 a)) 0.06f0 +pal-ember+ k seed))
        (= ph 5)))))

(defun-fast %st-gutter (o)
  "A burnout (:gutter, at the feet; §4.1 Burnout, Phase 5): West's garb (N 1) gutters out — 9 FIRE tongues sinking for
the first 2 drawings (threes) — then 6 BLACK SMOKE wisps rise off the shoulders and an ASH ring runs out at the feet
(mono). Envelope 0 2 6 30 on threes."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 3f0)) (d3 (i->f (logand (f->i (* 8f0 (fx-clock))) 63))))
      (declare (single-float a d3))
      (fx-envelope (es k fl ph) (a 0 2 6 30)
        (when (< ph 5)
          (when (and (< a 0.2f0) (> n 0.5f0))
            (dotimes (i 9)
              (let* ((f (i->f i)) (an (+ (* 0.698f0 f) (* 0.3f0 (hash01 f seed))))   ; (the fire sinks and licks continuously, §15.7)
                     (hh (* (- 1f0 (* 5f0 age)) (+ 0.7f0 (* 0.6f0 (flow01 f seed))))))
                (declare (single-float f an hh))
                (when (> hh 0.05f0)
                  (%tongue (+ x (* 0.4f0 (f-cos an))) (+ y 0.05f0) (+ z (* 0.4f0 (f-sin an))) 0f0 hh 0f0 0.15f0 +pal-fire+ 0.9f0 (+ seed f)
                           (+ (flow-ph) f) 0.03f0 :segs 4)))))
          (dotimes (j 6)
            (let* ((f (i->f j)) (an (+ (* 1.0472f0 f) (* 0.3f0 (hash01 f (+ seed 1f0))))) (c (f-cos an)) (sn (f-sin an))
                   (hh (* es (+ 0.5f0 (* 1.5f0 a)) (+ 0.8f0 (* 0.4f0 (hash01 (+ f d3) seed))))))
              (declare (single-float f an c sn hh))
              (%tongue (+ x (* 0.25f0 c)) (+ y 1.1f0) (+ z (* 0.25f0 sn)) (* 0.2f0 c) hh (* 0.2f0 sn) 0.13f0 +pal-black-smoke+ k
                       (+ 1100f0 seed f (* 6f0 (i->f (mod (f->i d3) 3)))) (+ d3 f) 0.25f0 :segs 6 :wob 0.35f0)))
          (%tring x y z (+ 0.4f0 (* 3f0 a)) 0.09f0 +pal-ash+ k seed))
        (= ph 5)))))

(defun-fast %st-nade (o)
  "Nadegiri (:nade; §4.1, Phase 5): X Y Z the feet, DX DZ his facing, SC the line's length. Envelope 1 2 4 30: a white
flash, a white HIT lens crescent across his front held 2 drawings (then an EMBER hairline), and on the ground an
ink-edged scorch line (an INK strip with an EMBER core) racing out along the cut, eroding from its far end."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)) (rx (- dz)) (rz dx) (run (f-clamp (/ a 0.1f0) 0f0 1f0))
           (ex (+ x (* sc run dx))) (ez (+ z (* sc run dz))))
      (declare (single-float a rx rz run ex ez))
      (fx-envelope (es k fl ph) (a 1 2 4 30)
        (cond ((= ph 1) (%flash (+ x (* 1.3f0 dx)) (+ y 1f0) (+ z (* 1.3f0 dz)) 0.3f0 seed))
              ((< ph 5)
               (let* ((ax (+ x (* 1.2f0 dx) (* 1.6f0 rx))) (az (+ z (* 1.2f0 dz) (* 1.6f0 rz)))
                      (bx (+ x (* 1.2f0 dx) (* -1.6f0 rx))) (bz (+ z (* 1.2f0 dz) (* -1.6f0 rz))))
                 (declare (single-float ax az bx bz))
                 (if (< ph 4)
                     (fx-crescent ax (+ y 0.85f0) az bx (+ y 1.05f0) bz (+ x (* 2.9f0 dx)) (+ y 0.95f0) (+ z (* 2.9f0 dz)) (* 0.11f0 es) :lens 0.1f0
                                  seed +pal-hit+ k :push 0.2f0)
                     (fx-crescent ax (+ y 0.85f0) az bx (+ y 1.05f0) bz (+ x (* 2.9f0 dx)) (+ y 0.95f0) (+ z (* 2.9f0 dz)) 0.03f0 :lens 0.9f0
                                  seed +pal-ember+ k :push 0.2f0)))
               (toon-ground-seg (+ x (* 0.5f0 dx)) (+ z (* 0.5f0 dz)) ex ez 0.03f0 0.11f0 1f0 0.3f0 (+ seed 2f0) 0.25f0 (toon-a +pal-ink+ k))
               (toon-ground-seg (+ x (* 0.5f0 dx)) (+ z (* 0.5f0 dz)) ex ez 0.037f0 0.035f0 1f0 0.3f0 (+ seed 3f0) 0.15f0
                                (toon-a +pal-ember+ k))))
        (= ph 5)))))

;;; the Bankai stances (design v3 §D; STYLE §4.1): EMBER + charcoal, the only warm hue a thin ember line

(defun-fast %st-slit (o)
  "KYOKUJITSUJIN's down-cut: a white vertical lens slit from overhead to the ground ahead (DX DZ), held 3
drawings; envelope 0 1 3 6."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 2f0)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 0 1 3 6)
        (when (< ph 5)
          (fx-crescent (+ x (* 0.5f0 dx)) (+ y 2.3f0) (+ z (* 0.5f0 dz)) (+ x (* 2.2f0 dx)) 0.05f0 (+ z (* 2.2f0 dz))
                       (+ x (* 1.8f0 dx)) (+ y 1.6f0) (+ z (* 1.8f0 dz)) (* sc es 0.12f0) :lens 0.1f0 seed +pal-hit+ k :push 0.3f0))
        (= ph 5)))))

(defun-fast %st-wisps (o)
  "GOKUI GAESHI up: a column of 6 charcoal wisps rising round him for its 12 f window (twos); envelope 0 2 8 6."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (sage age 2f0)) (dr drawing))
      (declare (single-float a dr))
      (fx-envelope (es k fl ph) (a 0 2 8 6)
        (when (< ph 5)
          (dotimes (j 6)
            (let* ((f (i->f j)) (ang (+ (* 1.0472f0 f) (* 0.3f0 (hash01 f seed)))) (c (f-cos ang)) (sn (f-sin ang))
                   (hh (* es (+ 1.6f0 (* 0.6f0 (hash01 (+ f dr) seed))))) (sd (- -1201f0 f (* 6f0 (i->f (mod (f->i dr) 3))))))
              (declare (single-float f ang c sn hh sd))
              (toon-ribbon ((+ x (* 0.55f0 c)) y (+ z (* 0.55f0 sn))) ((* 0.1f0 c) hh (* 0.1f0 sn)) (0.12f0 0.01f0) :seed sd :pal +pal-black-smoke+
                           :k k :ph (+ f dr) :sway 0.2f0 :segs 5))))
        (= ph 5)))))


(defun-fast vfx-kyoku-slit (x z dx dz)
  "KYOKUJITSUJIN f18 at feet (x z) facing (dx dz): the white down-cut slit."
  (with-floats (x z dx dz)
    (stamp :slit x 0.0 z :dx dx :dz dz)
    nil))

(defun-fast vfx-nishi (x z)
  "U to West (the ward goes up) at feet (x z): a charcoal double ring out to 2.6 m, an EMBER line inside it, 8 ASH shards."
  (with-floats (x z)
    (stamp :garb x 0.0 z :scale 0.52)
    (dotimes (i 8)
      (let* ((a (+ (* 0.785f0 (i->f i)) (rnd-range -0.2f0 0.2f0))) (sp (rnd-range 3f0 5f0)))
        (declare (single-float a sp))
        (%t-shard (+ x (* 0.5f0 (f-cos a))) (rnd-range 0.5f0 1.6f0) (+ z (* 0.5f0 (f-sin a))) (* sp (f-cos a)) (rnd-range 0.5f0 2f0)
                  (* sp (f-sin a)) (rnd-range 0.5f0 0.8f0) (rnd-range 0.1f0 0.18f0) 5f0 +pal-ash+)))
    (flash-light x 1.0 z 1.0 0.45 0.15)
    nil))

(defun-fast vfx-parry-up (x z)
  "GOKUI GAESHI's window opens at feet (x z): the column of charcoal wisps."
  (with-floats (x z)
    (stamp :wisps x 0.0 z)
    nil))

(defun-fast vfx-garb-block (x y z dx dz)
  "A hit West's garb guard blocks at (x y z); (DX DZ) = toward the attacker: the fire hexagon (%ST-GARB-GUARD)."
  (with-floats (x y z dx dz)
    (stamp :garb-guard x y z :dx dx :dz dz)
    (flash-light x y z 1.0 0.5 0.2)
    nil))

(defun-fast vfx-scorch (x y z)
  "The garb scorching an attacker's sword arm at (x y z): a white burn, an ember star, black smoke curls (%ST-SCORCH)."
  (with-floats (x y z)
    (stamp :scorch x y z)
    nil))

(defun-fast vfx-garb-flare (x z)
  "The garb flaring as it absorbs a ranged hit, at the feet (x z): the flung ring of flames (%ST-FLARE)."
  (with-floats (x z)
    (stamp :flare x 0f0 z)
    nil))

(defun-fast vfx-burnout (x z garb)
  "A Bankai stance burning out at the feet (x z): black smoke and an ash ring (%ST-GUTTER; GARB: West's flames gutter out
first), 5 BLACK SMOKE puffs off the shoulders and 12 ASH shards falling."
  (with-floats (x z)
    (stamp :gutter x 0f0 z :n (if garb 1 0))
    (dotimes (i 5)
      (%t-blob (+ x (rnd-range -0.3f0 0.3f0)) (rnd-range 1.1f0 1.5f0) (+ z (rnd-range -0.3f0 0.3f0)) (rnd-range -0.4f0 0.4f0)
               (rnd-range 0.8f0 1.6f0) (rnd-range -0.4f0 0.4f0) (rnd-range 0.8f0 1.2f0) (rnd-range 0.18f0 0.3f0) -0.4f0 0.3f0 +pal-black-smoke+))
    (dotimes (i 12)
      (%t-shard (+ x (rnd-range -0.4f0 0.4f0)) (rnd-range 0.8f0 1.7f0) (+ z (rnd-range -0.4f0 0.4f0)) (rnd-range -1f0 1f0) (rnd-range 0f0 1f0)
                (rnd-range -1f0 1f0) (rnd-range 0.8f0 1.3f0) (rnd-range 0.06f0 0.12f0) 1.5f0 +pal-ash+))
    nil))

(defun-fast vfx-nadegiri (x z dx dz)
  "Nadegiri's cut at the feet (x z), facing (DX DZ): the white crescent and the scorch line racing 8 m out (%ST-NADE)."
  (with-floats (x z dx dz)
    (stamp :nade x 0f0 z :dx dx :dz dz :scale 8.0)
    (flash-light (+ x (* 1.5f0 dx)) 1.0 (+ z (* 1.5f0 dz)) 1.0 0.6 0.3)
    nil))

(defun yama-nade-look (hz rdt)
  "The look of NADEGIRI's split entity (YAMA-NADE-SPLIT: :delay 24 :life 2): nothing since art S1 (DUEL_YAMA_CORE §22). The seam, SL7, is
drawn from the move's frames by YAMA-DRAW (14 f: longer than this entity lives); the entity stays, the state hash counts hazards (F6).
Before S1 it stamped the old crescent and 8 m scorch once and marked the hazard's data (F5: a look never writes)."
  (declare (ignore hz rdt))
  nil)
