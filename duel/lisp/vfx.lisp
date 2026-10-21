;;;; vfx.lisp — SOUL DUEL's shared visual effects: the fx helpers and lights, the smear, auras, ground cuts, sky split,
;;;; awakening bursts and the K.O. / Nozarashi accents. Split since refactor round 2 (the user 2026-10-21): the universal
;;;; one-shot STAMP system (hit sparks, Hoho, shatters, shockwaves) is vfx-stamps.lisp; Yamamoto's fire (blade, wave,
;;;; fireball, charge, pillars, dome, Tenchi's slash and ash, Taimatsu, the garb and Bankai stamp looks) is yama-vfx.lisp.
;;;; Everything is cosmetic: RND01 only (never SIM-RND01), no gameplay state.
;;;; Units: x y z metres (y up), YAW radians with forward = (-sin yaw, -cos yaw) (the duel/RAVEN
;;;; convention), AGE seconds since the effect started, LIFE its total seconds, DT real seconds of
;;;; this frame (particles are emitted at RATE x DT x *FIRE-DENSITY*).
;;;; Kinds of calls:
;;;;   per-frame looks  VFX-SMEAR … VFX-SOUL-FLAME (and yama-vfx.lisp's VFX-BLADE-FIRE …): call every rendered frame while the thing
;;;;                    exists (after the camera is set, before END-FRAME). Bodies are fx quads
;;;;                    written with WITH-FX-VERTS (0 bytes consed); a few particles top them up.
;;;;   one-shots        VFX-AWAKEN-BURST here; yama-vfx.lisp: VFX-FIRE-CONE, VFX-ASH-BURST, VFX-SKELETON-DUST, VFX-GARB-BLOCK,
;;;;                    VFX-SCORCH, VFX-GARB-FLARE, VFX-BURNOUT, VFX-NADEGIRI; vfx-stamps.lisp: VFX-RIFT-GASH: stamps and toon particles once.
;;;;   Every look is a drawn toon shape since Phase 5 of the restyle (docs/style/STYLE_STORM_DESIGN.md §14): the last soft
;;;;   additive ones (Shiranui, the charge, Taimatsu, the Ennetsu pillars, the Jokaku dome, the Hellfire / Evolution /
;;;;   Breaker auras, Tenchi's ash, the rift) were redrawn; since Phase 6 the only additive shapes left are the thin T光
;;;;   core lines (1-2 px: the blade fire's, the embers', the fire wave's base), a layer of §3.4 by design.
;;;;   toon universal   (vfx-stamps.lisp) VFX-HIT, VFX-HOHO, VFX-BURST, VFX-KONPAKU-SHATTER, VFX-KIKON-RUSH, VFX-STEP-DUST,
;;;;                    VFX-SHOCKWAVE start STAMPS (drawn one-shots, STAMPS-DRAW every frame) + toon
;;;;                    particles; VFX-SOUL-FLAME and the :KIKON aura are per-frame toon shapes
;;;;                    (docs/style/STYLE_STORM_DESIGN.md §4.3: mono + the BLOOD spot, stepped on the fx clock).
;;;;   lights           effects call ADD-POINT-LIGHT with a priority; LIGHTS-FLUSH once per
;;;;                    frame adds the hit flash.
;;;;   UI               UI-BITMAP, UI-KANJI, VFX-TENCHI-SLASH, VFX-SKY-SPLIT (screen space).
;;;; The frame still needs the engine's FX-UPDATE / FX-DRAW-PARTICLES / FX-RINGS-UPDATE.
;;;; Budgets (design §14): ≤ 1200 live particles (emission stops at +LIVE-CAP+), flame half-size
;;;; ≤ 0.35 m, bodies as quads; worst scene (Ennetsu + fire wave + Hellfire + blade + stage) is
;;;; measured by tests/duel-vfx.lisp.
(in-package :duel)

(defvar *fire-density* 1.0 "0..1: scales every VFX emission (tuning.lisp owns the value).")
(defconstant +live-cap+ 1150 "No new VFX particles while the pool holds this many (budget 1200).")

;;; ---------------------------------------------------------------- small hot-path helpers
;;; (The game-agnostic toon kit these looks are written with — WITH-FLOATS, HASH01, WITH-CAM, %T-BLOB, %T-SHARD,
;;; %TRING, %SECTOR-VERTS, %LIGHT, DRAWING-NO, %AWAY-FROM-EYE, %NEAR-CAM, %TONGUE, TOON-RIBBON — is the engine's:
;;; engine/lisp/fx.lisp, package.lisp.)
(defmacro n-of (rate dt)
  "How many particles to emit this frame for RATE per second: floor(RATE·DT·density + U), so the
average is exact at any frame rate. 0 once the pool is near the budget."
  `(if (< *plive* +live-cap+) (f->i (+ (* ,rate ,dt (the single-float (f32 *fire-density*))) (rnd01))) 0))

(defmacro clock () "The fx clock's seconds (phase for flicker): it stops while the game pauses." `(the single-float (fx-clock)))

;;; ---------------------------------------------------------------- lights (engine priorities)
;;; Effects call ADD-POINT-LIGHT with a PRIORITY (its last argument): the engine keeps the 8 highest
;;; (then nearest). The stage's two fire lights use priority 10, so effects share the other 6. Priorities:
;;; 9 detonation / awakening burst, 8 awakening auras, 7 projectile, 6 hit flash, 5 charge /
;;; Breaker, 3-4 hazards.
(declaim (type f32vec *flash-light*))
(defvar *flash-light* (make-f32 8) "hit flash: x y z r g b start-time (fx clock s)")

(defun lights-flush ()
  "Add the 0.15 s hit flash while it lasts. Call once per frame, before END-FRAME."
  (let* ((fl *flash-light*) (age (- (fx-clock) (aref fl 6))))
    (when (< -0.001 age 0.15)
      (add-point-light (aref fl 0) (aref fl 1) (aref fl 2) (aref fl 3) (aref fl 4) (aref fl 5)
                       6.0 (* 2.0 (- 1.0 (/ age 0.15))) 6))
    nil))

(defun flash-light (x y z r g b)
  "Start the 0.15 s hit-flash light at (x y z)."
  (let ((fl *flash-light*))
    (setf (aref fl 0) (f32 x) (aref fl 1) (f32 y) (aref fl 2) (f32 z)
          (aref fl 3) (f32 r) (aref fl 4) (f32 g) (aref fl 5) (f32 b) (aref fl 6) (fx-clock))))

;;; the fire wave's base polyline: scratch for FX-WALL, shared by yama-vfx.lisp's wave and VFX-LINE-CUT's wall
(declaim (type f32vec *wave-xs* *wave-zs*))
(defvar *wave-xs* (make-f32 9) "The fire wave's base polyline (x), for FX-WALL.")
(defvar *wave-zs* (make-f32 9) "The fire wave's base polyline (z).")

(defun-fast vfx-smear (tr sm look)
  "The sword smear (docs/style/STYLE_STORM_DESIGN.md §2.6, §4.1 blade fire, §4.2 cleaves): a comet crescent through the
blade's 0.7 point over the trail samples of the last drawing (at most 5), fat at the blade, its tail thinning and
eroding. It is captured into SM when a new drawing (twos) starts and held for that drawing. LOOK 0 = FIRE
(Ryujin Jakka), 1 = REIATSU (Kenpachi: a white-cored yellow comet, every form), 2 = charcoal ink wash (Zanka no
Tachi). SM: x0 y0 z0 x1 y1 z1 bx by bz, half-width, drawing, presence."
  (declare (type f32vec tr sm) (fixnum look))
  (let* ((n (f->i (trail-count tr))) (dr (drawing-no)))
    (declare (fixnum n) (single-float dr))
    (fx-smear-capture! tr sm n dr 0.7f0 (len (* 0.33f0 len)) (if (>= n 5) 0.98f0 0.6f0))   ; through the blade's 0.7 points
    (when (> (aref sm 11) 0f0)
      (fx-crescent (aref sm 0) (aref sm 1) (aref sm 2) (aref sm 3) (aref sm 4) (aref sm 5) (aref sm 6) (aref sm 7) (aref sm 8)
                   (aref sm 9) :comet 0.06f0 (if (= look 2) (+ 1000f0 dr) (+ 5f0 dr))
                   (case look (0 +pal-fire+) (1 +pal-reiatsu+) (t +pal-black-smoke+)) (aref sm 11) :push 0.15f0))
    nil))

;;; ---------------------------------------------------------------- auras
(defmacro %brush-aura (x y z h k pal n rad w white)
  "A brush-flame aura (docs/style/STYLE_STORM_DESIGN.md §4.2 reiatsu, §4.3 Kikon rush): N tongues of palette PAL around
the body at radius RAD (half-width W at the base), drawn only behind and at the sides (the ones between the camera and the body are left
out, so the fighter stays readable inside), H tall x 0.8..1.25 with a lean, both re-drawn every drawing (twos),
the palette's dark hairline, and when WHITE is 1 a white core line in the back ones. K = presence. PAL may carry a glass
level (+ 32 x g, fx-toon.frag.wgsl: see-through); the white cores take the same level. A macro (the auras run every
frame: 0 B); N and WHITE literal fixnums."
  `(let* ((x ,x) (y ,y) (z ,z) (h ,h) (k ,k) (pal ,pal) (rad ,rad) (w ,w) (e (camera-eye *camera*)) (ex (- (aref e 0) x)) (ez (- (aref e 2) z)) (el (f-max 0.01f0 (f-hypot ex ez)))
         (dr (drawing-no)) (pk (toon-a pal (* 0.95f0 k))) (step (/ 6.2831855f0 ,(float n 1f0)))
         (wpal (+ +pal-hit+ (* 32f0 (i->f (f->i (/ pal 32f0)))))))   ; the white cores' palette, the same glass level
    (declare (single-float x y z h k pal rad w) (type f32vec e) (single-float ex ez el dr pk step wpal) (ignorable wpal))
    (dotimes (i ,n)
      (let* ((f (i->f i)) (ang (+ (* step f) (* 0.3f0 (hash01 f 1.3f0))))
             (c (f-cos ang)) (sn (f-sin ang)) (front (/ (+ (* ex c) (* ez sn)) el)))
        (declare (single-float f ang c sn front))
        (when (< front 0.35f0)                        ; behind and at the sides only
          (let* ((hh (* h (+ 0.8f0 (* 0.45f0 (hash01 (+ f dr) 3.7f0))))) (lean (* 0.25f0 (- (hash01 (+ f dr) 5.9f0) 0.5f0)))
                 (bx (+ x (* rad c))) (bz (+ z (* rad sn))) (sd (- -1f0 (+ f (* 3f0 (i->f (mod (f->i dr) 5)))))))
            (declare (single-float hh lean bx bz sd))
            (toon-ribbon (bx y bz) ((* lean c) hh (* lean sn)) (w 0f0) :seed sd :k pk :ph (+ f dr) :sway 0.12f0)
            (when ,(if (eql white 1) '(< front -0.4f0) nil)
              (toon-ribbon (bx (+ y 0.1f0) bz) ((* 0.7f0 lean c) (* 0.6f0 hh) (* 0.7f0 lean sn)) (0.035f0 0f0) :seed sd :wob 0.1f0 :pal wpal
                           :k (* 0.95f0 k) :segs 3))))))
     nil))

(defmacro %kikon-aura (x y z h k)
  "The Kikon rush aura (the :KIKON kind of VFX-AURA): 7 BLOOD brush-flame tongues behind the body (radius 0.5 m),
white core lines in the back three, and a flat BLOOD ring at the feet. A macro: 0 B."
  `(let* ((x ,x) (y ,y) (z ,z) (h ,h) (k ,k) (dr (drawing-no)))
    (declare (single-float x y z h k dr))
    (%brush-aura x y z h k +pal-blood+ 7 0.5f0 0.2f0 1)
    (%tring x y z (+ 0.72f0 (* 0.06f0 (hash01 dr 8.3f0))) 0.07f0 +pal-blood+ (* 0.95f0 k) (i->f (mod (f->i dr) 7)))
    nil))

(defmacro %reiatsu-aura (x y z h k awake glass)
  "Kenpachi's reiatsu, yellow in every form (§4.2, user review 1). Base (AWAKE 0): 7 REIATSU tongues behind him at
0.45 m, 0.8 x his height, white core lines, white flecks rising. Nozarashi (AWAKE 1): 9 wider tongues at 0.5 m, 1.05 x,
3 thin inner white tongues, a flat REIATSU ring at the feet and a yellow light (its soft additive glow cut in Phase 6).
GLASS (0..3): the tongues, cores and ring see-through, GLASS / 4 of them drawn (*REIATSU-GLASS*; the user's request
2026-09-28: cup 3's pillar hid the view). A macro: 0 B."
  `(let* ((x ,x) (y ,y) (z ,z) (h ,h) (k ,k) (dr (drawing-no)) (g (* 32f0 (i->f ,glass))))
    (declare (single-float x y z h k dr g))
    (if (= ,awake 1)
        (progn
          (%brush-aura x y z (* 1.05f0 h) k (+ +pal-reiatsu+ g) 9 0.5f0 0.19f0 1)
          (%brush-aura x y z (* 0.7f0 h) k (+ +pal-hit+ g) 3 0.3f0 0.06f0 0)
          (%tring x y z (+ 0.8f0 (* 0.06f0 (hash01 dr 8.3f0))) 0.06f0 (+ +pal-reiatsu+ g) (* 0.95f0 k) (i->f (mod (f->i dr) 7)))
          (%light x (+ y 1.2f0) z 1f0 0.8f0 0.25f0 5f0 0.7f0 8))
        (%brush-aura x y z (* 0.8f0 h) k (+ +pal-reiatsu+ g) 7 0.45f0 0.16f0 1))
    nil))

(defparameter *reiatsu-glass* '(:reiatsu 3 :nozarashi 3 :nomihose 2 :oni 2 :oni-ink 3)
  "Kenpachi's reiatsu, see-through (the glass level, 4 = opaque): the yellow, cups 1 / 2 draw 3 of 4 MSAA samples, cup 3's
pillar 2 (the user's request 2026-09-28: it hid the view); the Bankai's red-and-black pillar (:oni, the same day): its
BLOOD tongues 2, its taller INK tongues 3 (at 2 the black read as a grey smear). Render only.")

;;; the burst modes' colours and names (docs/duel/DUEL_DESIGN.md "Burst modes"): the HUD bar, the word, the aura
(defvar *c-burst-white* (list 0.95 0.96 1.0 1.0))
(defvar *c-burst-blue* (list 0.4 0.66 1.0 1.0))
(defvar *c-burst-orange* (list 1.0 0.58 0.18 1.0))
(defun burst-color (mode)
  "The RGBA list of burst MODE (:white :blue :orange); callers may change its alpha (ALPHA!)."
  (case mode (:white *c-burst-white*) (:blue *c-burst-blue*) (t *c-burst-orange*)))
(defun burst-name (mode) (case mode (:white "SOUL REVERSE") (:blue "BURST REVERSE") (t "CHAIN REVERSE")))

(defvar *aura-now* (vector nil nil) "Per side: the body aura drawn now (main.lisp DRAW-AURA) ...")
(defvar *aura-was* (vector nil nil) "... the one before it ...")
(declaim (type f32vec *aura-t*))
(defvar *aura-t* (make-f32 2) "... and the FX-CLOCK it changed (a form switch, a burnout, a reignite).")

(defvar *aura-cap* 1.0
  "0.5..1: alpha cap of every body aura this frame. HUD-DRAW (AURA-CAP-UPDATE) lowers it while the
fighters stand within ~3 m, where two auras (or one over the other fighter) summed to a white blob.")

(defun-fast vfx-aura (x y z height kind age dt &key (k 1.0))
  "Body aura at the feet (x y z) of a fighter HEIGHT m tall, every kind a drawn toon look (Phase 5 redrew the last soft
ones). KIND: :hellfire (a bonfire of FIRE tongues + a ring at the feet), :heat (Bankai East: 4 charcoal wisps),
:garb (Bankai West wrapped in orange flame, winged at the shoulders; K > 1 flares it taller and wider), :evolution
(mono STEEL tongues), :reiatsu / :nozarashi / :nomihose (Kenpachi's yellow brush-flame aura, base /
awakened / cup 3's pillar: %REIATSU-AURA), :bound (ash at the held feet), :kikon (the BLOOD rush aura), :breaker /
:breaker-fire / :breaker-ember (the owner's colour over an INK backing; K 0.5..2 grows it over the strike's startup).
K is the presence (0..1). :heat also fades by *AURA-CAP* and when the camera is within ~4 m. AGE is unused (kept: 22 callers)."
  (declare (ignorable age))
  (with-floats (x y z height dt k)
    (let* ((h height) (eye (camera-eye *camera*))
           (ex (- (aref eye 0) x)) (ey (- (aref eye 1) (+ y (* 0.6f0 h)))) (ez (- (aref eye 2) z))
           (near (f-clamp (/ (- (f-hypot ex ey ez) 1.5f0) 2.5f0) 0.35f0 1f0))
           (ka (* near (the single-float (f32 *aura-cap*)) (f-clamp k 0f0 1f0))))
      (declare (type f32vec eye) (single-float h ex ey ez near ka))
      (case kind
        (:hellfire                                       ; Hellfire (Gokuen, §4 mapping, Phase 5): a bonfire round him — 7 FIRE
                                                         ; brush tongues behind and at the sides (0.8 x his height), a ring of 8
                                                         ; short FIRE tongues licking at his feet, an EMBER scorch ring, scraps
         (let* ((kc (f-clamp k 0f0 1f0)) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))))
           (declare (single-float kc dr sd))
           (%brush-aura x y z (* 0.8f0 h) kc +pal-fire+ 7 0.38f0 0.17f0 0)
           (dotimes (j 8)
             (let* ((f (i->f j)) (an (+ (* 0.7854f0 f) (* 0.3f0 (hash01 f 7.1f0)))) (hh (* 0.3f0 (+ 0.7f0 (* 0.7f0 (hash01 (+ f dr) 2.9f0))))))
               (declare (single-float f an hh))
               (%tongue (+ x (* 0.55f0 (f-cos an))) (+ y 0.02f0) (+ z (* 0.55f0 (f-sin an))) 0f0 hh 0f0 0.09f0 +pal-fire+ (* 0.95f0 kc)
                        (+ 70f0 f (* 8f0 sd)) (+ dr f) 0.02f0 :segs 3)))
           (%tring x y z 0.55f0 0.07f0 +pal-ember+ (* 0.9f0 kc) sd 24)
           (dotimes (i (n-of (* 16f0 kc) dt))
             (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) (+ y (* h (rnd-range 0.1f0 0.8f0))) (+ z (rnd-range -0.35f0 0.35f0))
                      (rnd-range -0.2f0 0.2f0) (rnd-range 1.2f0 2.2f0) (rnd-range -0.2f0 0.2f0) (rnd-range 0.3f0 0.5f0)
                      (rnd-range 0.05f0 0.1f0) -1f0 0.3f0 +pal-fire+))
           (%light x (+ y 0.6f0) z 1f0 0.4f0 0.1f0 4.5f0 (* 0.8f0 kc) 8)))
        (:garb                                           ; Bankai West, Zanjitsu Gokui (canon manga colour, DUEL_YAMA_TYBW §3.1,
                                                         ; canon-looks §4.3; red until 2026-10-13): orange FLAME tongues from the
                                                         ; feet up round the body (behind and at the sides: the silhouette stays
                                                         ; readable), flaring at the shoulders into two wings (a fan of 3 tongues
                                                         ; each, to the camera's left and right so the shape reads from any camera:
                                                         ; out ~30 deg from the shoulders, the tips ~0.5 m over his head and
                                                         ; ~0.6 m out to each side), a molten ring
                                                         ; at his feet, flame scraps rising, a warm light; K > 1 flares it all
         (let* ((kc (f-clamp k 0f0 1f0)) (fl (f-max 1f0 k)) (fr (+ 1f0 (* 0.3f0 (- fl 1f0))))   ; taller and wider
                (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))) (pk (toon-a +pal-flame+ (* 0.95f0 kc))))
           (declare (single-float kc fl fr dr sd pk))
           (%brush-aura x y z (* 0.8f0 h fl) kc +pal-flame+ 9 (* 0.34f0 fr) (* 0.16f0 fr) 0)
           (%brush-aura x y z (* 0.62f0 h fl) kc +pal-flame+ 6 (* 0.25f0 fr) (* 0.12f0 fr) 0)
           (with-cam (rx ry rz ux uy uz)
             (let* ((rl (f-max 1f-3 (f-hypot rx rz))) (hx (/ rx rl)) (hz (/ rz rl)))
               (declare (single-float rl hx hz))
               (dotimes (sg 2)
                 (dotimes (j 3)                          ; (base out, base up, tip out, tip up, half-width) x h / m
                   (let* ((sgn (if (= sg 0) 1f0 -1f0)) (jf (i->f j))
                          (b-out (case j (0 0.12f0) (1 0.1f0) (t 0.16f0))) (b-up (case j (0 0.7f0) (1 0.62f0) (t 0.66f0)))
                          (t-out (case j (0 0.55f0) (1 0.36f0) (t 0.66f0))) (t-up (case j (0 1.2f0) (1 1.27f0) (t 1.0f0)))
                          (w (* fr (case j (0 0.17f0) (1 0.12f0) (t 0.13f0))))
                          (vary (+ 0.92f0 (* 0.16f0 (hash01 (+ jf (* 3f0 (i->f sg)) dr) 4.7f0))))
                          (bx (+ x (* sgn b-out fr hx))) (by (+ y (* b-up h))) (bz (+ z (* sgn b-out fr hz)))
                          (ax (* sgn (- t-out b-out) fr fl hx)) (ay (* (- t-up b-up) h fl vary)) (az (* sgn (- t-out b-out) fr fl hz))
                          (wsd (- -40f0 jf (* 3f0 (i->f sg)) (* 7f0 sd))))
                     (declare (single-float sgn jf b-out b-up t-out t-up w vary bx by bz ax ay az wsd))
                     (%away-from-eye (bx by bz) 0.22f0
                       (toon-ribbon (bx by bz) (ax ay az) (w 0f0) :seed wsd :wob 0.3f0 :k pk :ph (+ dr jf) :sway 0.07f0
                                    :segs 6)))))))
           (%tring x y z (* 0.48f0 fr) 0.07f0 +pal-flame+ (* 0.95f0 kc) sd 24)   ; the plaza melting under him
           (%tring x y z (* 0.34f0 fr) 0.03f0 +pal-flame+ (* 0.8f0 kc) (+ sd 2f0) 24)
           (dotimes (i (n-of (* 14f0 kc) dt))
             (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.2f0 0.9f0))) (+ z (rnd-range -0.4f0 0.4f0))
                      (rnd-range -0.2f0 0.2f0) (rnd-range 1.2f0 2.2f0) (rnd-range -0.2f0 0.2f0) (rnd-range 0.3f0 0.5f0)
                      (rnd-range 0.06f0 0.11f0) -1f0 0.3f0 +pal-flame+))
           (%light x (+ y 1.0f0) z 1f0 0.58f0 0.28f0 5f0 (* 1.2f0 kc fl) 8)))
        (:heat                                           ; Bankai East: the heat as 4 slow charcoal ink-wash wisps (threes)
         (let* ((e (camera-eye *camera*)) (ex (- (aref e 0) x)) (ez (- (aref e 2) z)) (el (f-max 0.01f0 (f-hypot ex ez)))
                (d3 (drawing-no 8f0)))
           (declare (type f32vec e) (single-float ex ez el d3))
           (dotimes (j 4)
             (let* ((f (i->f j)) (ang (+ (* 1.5708f0 f) 0.785f0 (* 0.4f0 (f-sin (+ (* 0.0375f0 (i->f (f->i (* 8f0 (clock))))) f)))))
                    (c (f-cos ang)) (sn (f-sin ang)))
               (declare (single-float f ang c sn))
               (when (< (/ (+ (* ex c) (* ez sn)) el) 0.3f0)
                 (let* ((hh (* h (+ 0.75f0 (* 0.3f0 (hash01 (+ f d3) 2.9f0))))) (lean (* 0.35f0 (- (hash01 (+ f d3) 6.1f0) 0.5f0)))
                        (sd (- -1001f0 f (* 4f0 (i->f (mod (f->i d3) 3))))))
                   (declare (single-float hh lean sd))
                   (toon-ribbon ((+ x (* 0.42f0 c)) (+ y (* 0.25f0 h)) (+ z (* 0.42f0 sn))) ((* lean c) hh (* lean sn)) (0.15f0 0.01f0) :seed sd
                                :wob 0.35f0 :pal +pal-black-smoke+ :k (* 0.9f0 ka) :ph (+ f d3) :sway 0.3f0 :segs 7)))))))
        ((:burst-white :burst-blue :burst-orange)        ; a running burst (docs/duel/DUEL_DESIGN.md "Burst modes"): 8 brush
                                                         ; tongues in its colour (white HIT / BLUE / orange FIRE) with white
                                                         ; cores, a ring at the feet, flecks rising
         (let* ((kc (f-clamp k 0f0 1f0)) (dr (drawing-no))
                (pal (case kind (:burst-white +pal-hit+) (:burst-blue +pal-blue+) (t +pal-fire+))))
           (declare (single-float kc dr pal))
           (%brush-aura x y z (* 0.95f0 h) kc pal 8 0.46f0 0.15f0 1)
           (%tring x y z (+ 0.7f0 (* 0.05f0 (hash01 dr 4.1f0))) 0.05f0 pal (* 0.9f0 kc) (i->f (mod (f->i dr) 5)))
           (dotimes (i (n-of 8f0 dt))
             (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.1f0 0.8f0))) (+ z (rnd-range -0.4f0 0.4f0))
                      0f0 (rnd-range 1.2f0 2.2f0) 0f0 (rnd-range 0.3f0 0.5f0) (rnd-range 0.02f0 0.035f0) 0f0 0.1f0 pal))))
        (:evolution                                      ; EVOLUTION ready (universal: mono, Phase 5): 5 thin STEEL brush tongues
                                                         ; behind him and white flecks rising (RGB is ignored)
         (%brush-aura x y z (* 0.85f0 h) (* 0.8f0 (f-clamp k 0f0 1f0)) +pal-steel+ 5 0.33f0 0.09f0 0)
         (dotimes (i (n-of 8f0 dt))
           (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) (+ y (* h (rnd-range 0.1f0 0.8f0))) (+ z (rnd-range -0.35f0 0.35f0))
                    0f0 (rnd-range 0.8f0 1.6f0) 0f0 (rnd-range 0.4f0 0.7f0) (rnd-range 0.015f0 0.03f0) 0f0 0.1f0 +pal-hit+)))
        ((:reiatsu :nozarashi :nomihose)                  ; cups 1 / 2 / 3: base, awakened, pillar-scale (x1.6 tall)
         (%reiatsu-aura x y z (if (eq kind :nomihose) (* 1.6f0 h) h) ka (if (eq kind :reiatsu) 0 1)   ; (ka: the near-
                        (the fixnum (getf *reiatsu-glass* kind 0)))                                   ; camera fade)
         (dotimes (i (n-of (case kind (:nomihose 22f0) (:nozarashi 12f0) (t 5f0)) dt))   ; white flecks rising
           (%t-blob (+ x (rnd-range -0.45f0 0.45f0)) (+ y (* h (rnd-range 0.1f0 0.8f0))) (+ z (rnd-range -0.45f0 0.45f0))
                    0f0 (rnd-range 1.2f0 2.4f0) 0f0 (rnd-range 0.3f0 0.6f0) (rnd-range 0.015f0 0.03f0) 0f0 0.1f0 +pal-hit+)))
        (:bound                                          ; South's hold: ASH drifting up from the held feet (threes)
         (dotimes (i (n-of 10f0 dt))
           (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) 0.1f0 (+ z (rnd-range -0.35f0 0.35f0)) (rnd-range -0.2f0 0.2f0)
                    (rnd-range 0.4f0 0.9f0) (rnd-range -0.2f0 0.2f0) (rnd-range 0.8f0 1.2f0) (rnd-range 0.04f0 0.07f0)
                    -0.1f0 0.2f0 +pal-ash+)))
        (:oni                                            ; Kenpachi's Bankai (docs/duel/DUEL_KEN_BANKAI.md §12): a vertical pillar
                                                         ; (x1.4 tall) of BLOOD tongues over taller INK tongues, BLOOD flecks
                                                         ; rising; K < 1 during his Kikon rush: a smoulder (the rush's own
                                                         ; horizontal BLOOD trail stays the tell)
         (let* ((kc (f-clamp k 0f0 1f0))                ; see-through (*REIATSU-GLASS* :oni / :oni-ink: the user's
                (gb (* 32f0 (i->f (the fixnum (getf *reiatsu-glass* :oni 0)))))        ; request 2026-09-28), the ink
                (gi (* 32f0 (i->f (the fixnum (getf *reiatsu-glass* :oni-ink 0))))))   ; denser so it stays black
           (declare (single-float kc gb gi))
           (%brush-aura x y z (* 1.35f0 h) kc (+ +pal-ink+ gi) 9 0.5f0 0.2f0 0)
           (%brush-aura x y z (* 1.05f0 h) kc (+ +pal-blood+ gb) 9 0.4f0 0.16f0 1)
           (dotimes (i (n-of (* 18f0 kc) dt))
             (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.1f0 1.2f0))) (+ z (rnd-range -0.4f0 0.4f0))
                      0f0 (rnd-range 1.5f0 3f0) 0f0 (rnd-range 0.4f0 0.7f0) (rnd-range 0.02f0 0.04f0) 0f0 0.15f0 +pal-blood+))
           (%light x (+ y 1.2f0) z 1f0 0.15f0 0.12f0 5f0 (* 0.9f0 kc) 8)))
        (:kikon (%kikon-aura x y z (* 0.95f0 h) (f-clamp k 0.3f0 1f0))
         (dotimes (i (n-of 10f0 dt))
           (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.2f0 0.9f0))) (+ z (rnd-range -0.4f0 0.4f0))
                    0f0 (rnd-range 1f0 2f0) 0f0 (rnd-range 0.4f0 0.7f0) (rnd-range 0.025f0 0.045f0) 0f0 0.2f0 +pal-blood+))
         (add-point-light x (+ y 1.0) z 1.0 0.15 0.2 4.5 1.0 6))
        ((:breaker :breaker-fire :breaker-ember)          ; the Breaker (§4 mapping, Phase 5): the owner's colour (REIATSU / FIRE /
                                                         ; EMBER) over an INK backing (7 black tongues, taller, behind), the
                                                         ; BLOOD edge is the ring (VFX-BREAKER-RING); K 0.5 aura, 1 dash, 1..2
                                                         ; the strike's startup (it grows)
         (let* ((pal (case kind (:breaker-fire +pal-fire+) (:breaker-ember +pal-ember+) (t +pal-reiatsu+)))
                (pk (f-clamp (+ 0.55f0 (* 0.45f0 k)) 0f0 1f0)) (gr (+ 1f0 (* 0.25f0 (f-clamp (- k 1f0) 0f0 1f0)))))
           (declare (single-float pal pk gr))
           (%brush-aura x y z (* 1.1f0 h gr) pk +pal-ink+ 7 0.5f0 0.2f0 0)
           (%brush-aura x y z (* 0.9f0 h gr) pk pal 7 0.4f0 0.16f0 1)
           (dotimes (i (n-of (* 14f0 pk) dt))
             (%t-blob (+ x (rnd-range -0.4f0 0.4f0)) (+ y (* h (rnd-range 0.2f0 0.9f0))) (+ z (rnd-range -0.4f0 0.4f0))
                      0f0 (rnd-range 1f0 2f0) 0f0 (rnd-range 0.3f0 0.6f0) (rnd-range 0.03f0 0.05f0) 0f0 0.2f0 +pal-blood+))
           (%light x (+ y 1f0) z 1f0 0.3f0 0.2f0 5f0 (* 1.2f0 pk) 5)))
        (t (when (and kind (fboundp kind)) (funcall kind x y z h ka dt))))   ; a draw function (Rukia's ice auras)
      nil)))

(defun-fast vfx-breaker-ring (x z age)
  "The ground rings under a Breaker's aura and dash (§4 mapping, Phase 5; call every frame with its AGE): a steady BLOOD
ring (the Breaker's red edge) and an INK ripple running out every 0.4 s (on twos)."
  (with-floats (x z age)
    (let* ((sa (sage age 2f0)) (f (/ (f-mod sa 0.4f0) 0.4f0)) (dr (drawing-no)))
      (declare (single-float sa f dr))
      (%tring x 0f0 z 0.8f0 0.08f0 +pal-blood+ 0.95f0 (i->f (mod (f->i dr) 5)) 24)
      (%tring x 0f0 z (+ 0.95f0 (* 1.4f0 f)) 0.05f0 +pal-ink+ (* 0.95f0 (- 1f0 f)) 3f0 24))))

;;; ---------------------------------------------------------------- ground cuts, sky split, Tenchi Kaijin
(defmacro %crack (x0 z0 x1 z1 w kg kc seed)
  "A jagged ground cut (x0 z0)→(x1 z1) of drawn toon strips (§4.2 Split the Meteor / Buttagiru): a DUST gash of
half-width W (narrow at both ends, a heavy dark edge) with a REIATSU core line; KG / KC their presences (0..1: the
far end erodes first). A macro: 0 B."
  `(let* ((x0 ,x0) (z0 ,z0) (x1 ,x1) (z1 ,z1) (w ,w) (kg ,kg) (kc ,kc) (seed ,seed) (dx (- x1 x0)) (dz (- z1 z0)) (l (f-hypot dx dz)) (n (max 2 (f->i (* 1.5f0 l))))
         (px (/ (- dz) (f-max l 1f-4))) (pz (/ dx (f-max l 1f-4))) (ox x0) (oz z0) (oh 1f0)
         (pg (toon-a +pal-dust+ kg)) (pc (toon-a +pal-reiatsu+ kc)))
    (declare (single-float x0 z0 x1 z1 w kg kc seed dx dz l px pz ox oz oh pg pc) (fixnum n))
    (when (> kg 0.02f0)
      (dotimes (i n)
        (let* ((u (/ (i->f (1+ i)) (i->f n))) (jag (if (= i (1- n)) 0f0 (* 0.35f0 (- (hash01 (i->f i) seed) 0.5f0))))
               (nx (+ x0 (* u dx) (* jag px))) (nz (+ z0 (* u dz) (* jag pz))) (nh (- 1f0 (* 0.8f0 u)))
               (ww (* w (+ 0.35f0 (* 0.65f0 (- 1f0 (f-abs (- (* 2f0 u) 1f0))))))))
          (declare (single-float u jag nx nz nh ww))
          (toon-ground-seg ox oz nx nz 0.03f0 ww oh nh seed 0.3f0 pg)
          (when (> kc 0.02f0) (toon-ground-seg ox oz nx nz 0.037f0 (* 0.28f0 ww) oh nh (+ seed 3f0) 0.15f0 pc))
          (setf ox nx oz nz oh nh))))))

(defun-fast vfx-line-cut (x0 z0 x1 z1 age life kind &key (dt 0.0))
  "A cut along the ground (x0 z0)→(x1 z1). KIND :meteor (Nozarashi: the ground
splits, a light sheet flashes and a shockwave runs out on both sides), :crack (Buttagiru: a 3 m
ground crack with dust), :enjo (the Kikon module ENJO: a FIRE line runs along the lane from 1 m, then
four FIRE walls rise along it one after another over 16 frames, each over an EMBER backing, hold,
and erode), :kyoku (KYOKUJITSUJIN's heat sheet), :south (South's ring crack), :kyokko (KYOKKO's ray). DT (optional) feeds the particles; 0 = none."
  (with-floats (x0 z0 x1 z1 age life dt)
    (let* ((dx (- x1 x0)) (dz (- z1 z0)) (l (f-max 1f-3 (f-hypot dx dz)))
           (px (/ (- dz) l)) (pz (/ dx l)) (v (f-clamp (/ age (f-max life 0.01f0)) 0f0 1f0))
           (fade (- 1f0 (* v v))) (seed (+ x0 (* 3f0 z0))))
      (declare (single-float dx dz l px pz v fade seed))
      (case kind
        (:meteor                                         ; §4.2: gash + core, a light sheet for 3 drawings, rocks, dust
         (let* ((open (f-clamp (/ age 0.12f0) 0f0 1f0)) (glow (f-clamp (- 1f0 (/ age (* 0.6f0 life))) 0f0 1f0))
                (in (f-clamp (/ age 0.03f0) 0f0 1f0))     ; nothing at age 0 (a hazard frozen by a cinematic)
                (sa (sage age 2f0)) (dr (drawing-no)) (wave (* in (f-clamp (- 1f0 (/ age 0.6f0)) 0f0 1f0)))
                (off (+ 0.4f0 (* 9f0 (f-sqrt (sage age 3f0))))))
           (declare (single-float open glow in sa dr wave off))
           (%crack x0 z0 (+ x0 (* open dx)) (+ z0 (* open dz)) 0.42f0 (* in 0.98f0 fade) (* in glow) seed)
           (when (> wave 0.05f0)                         ; the ground heaving out on both sides (DUST, threes)
             (toon-ground-seg (+ x0 (* off px)) (+ z0 (* off pz)) (+ x1 (* off px)) (+ z1 (* off pz)) 0.04f0 0.22f0 1f0 0.2f0
                              (+ seed 7f0) 0.35f0 (toon-a +pal-dust+ wave))
             (toon-ground-seg (- x0 (* off px)) (- z0 (* off pz)) (- x1 (* off px)) (- z1 (* off pz)) 0.04f0 0.22f0 1f0 0.2f0
                              (+ seed 8f0) 0.35f0 (toon-a +pal-dust+ wave)))
           (when (and (> in 0f0) (< sa 0.25f0))          ; the light sheet standing on the cut
             (dotimes (k 5)
               (let* ((u (* 0.25f0 (i->f k))) (sd (- -2f0 (i->f k) (* 5f0 dr))) (pk (toon-a +pal-hit+ (- 0.98f0 (* 3f0 sa)))))
                 (declare (single-float u sd pk))
                 (toon-ribbon ((+ x0 (* u dx)) 0f0 (+ z0 (* u dz))) (0f0 5f0 0f0) ((f-min 0.35f0 (* 0.05f0 l)) 0.03f0) :seed sd :wob 0.15f0 :k pk
                              :ph dr :segs 2))))
           (when (< age 0.2f0)                           ; <= 20 particles: 8 inked rocks, 10 dust puffs
             (dotimes (i (n-of 40f0 dt))
               (let* ((u (rnd01)) (sd (if (< (rnd01) 0.5f0) -1f0 1f0)) (sp (rnd-range 3f0 6f0)))
                 (declare (single-float u sd sp))
                 (%t-shard (+ x0 (* u dx)) 0.2f0 (+ z0 (* u dz)) (* sd sp px) (rnd-range 2f0 5f0) (* sd sp pz)
                           (rnd-range 0.6f0 0.9f0) (rnd-range 0.1f0 0.2f0) 9f0 +pal-dust+)))
             (dotimes (i (n-of 50f0 dt))
               (let* ((u (rnd01)) (sd (if (< (rnd01) 0.5f0) -1f0 1f0)) (sp (rnd-range 1.5f0 3f0)))
                 (declare (single-float u sd sp))
                 (%t-blob (+ x0 (* u dx)) 0.2f0 (+ z0 (* u dz)) (* sd sp px) (rnd-range 0.3f0 1f0) (* sd sp pz)
                          (rnd-range 0.6f0 1f0) (rnd-range 0.25f0 0.4f0) -0.2f0 0.25f0 +pal-dust+))))))
        (:enjo                                           ; the lane of fire walls (§4.1 row ENJO)
         (let* ((sa (sage age 2f0)) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 7))) (ux (/ dx l)) (uz (/ dz l))
                (k (if (< sa (- life 0.25f0)) 0.98f0 (f-max 0f0 (* 0.98f0 (/ (- life sa) 0.25f0)))))
                (e (camera-eye *camera*)) (vx (- (* 0.5f0 (+ x0 x1)) (aref e 0))) (vz (- (* 0.5f0 (+ z0 z1)) (aref e 2)))
                (vl (f-max 0.01f0 (f-hypot vx vz))) (ox (* 0.3f0 (/ vx vl))) (oz (* 0.3f0 (/ vz vl))))
           (declare (single-float sa dr sd ux uz k vx vz vl ox oz) (type f32vec e))
           (toon-ground-seg (+ x0 ux) (+ z0 uz) x1 z1 0.03f0 0.12f0 1f0 0.3f0 (+ 40f0 sd) 0.3f0
                            (toon-a +pal-fire+ (* k (f-clamp (* 8f0 sa) 0f0 0.98f0))))
           (dotimes (i 4)
             (let* ((fi (i->f i)) (rise (f-clamp (/ (- sa (* 0.0667f0 fi)) 0.07f0) 0f0 1f0)) (hgt (* 2.4f0 rise))
                    (a0 (+ 1f0 (* 2f0 fi))))
               (declare (single-float fi rise hgt a0))
               (when (> rise 0f0)
                 (dotimes (j 5)                          ; this wall's base: 2 m of the lane
                   (let* ((u (+ a0 (* 0.5f0 (i->f j)))))
                     (declare (single-float u))
                     (setf (aref *wave-xs* j) (+ x0 (* u ux) ox) (aref *wave-zs* j) (+ z0 (* u uz) oz))))
                 (fx-wall *wave-xs* *wave-zs* 5 (* 1.2f0 hgt) 5 0.25f0 (+ 20f0 sd fi) +pal-ember+ k)   ; the backing
                 (dotimes (j 5) (setf (aref *wave-xs* j) (- (aref *wave-xs* j) ox) (aref *wave-zs* j) (- (aref *wave-zs* j) oz)))
                 (fx-wall *wave-xs* *wave-zs* 5 hgt 5 0.2f0 (+ 3f0 sd fi) +pal-fire+ k))))
           (when (> k 0.3f0)
             (dotimes (i (n-of 16f0 dt))                  ; flame scraps off the crests
               (let* ((u (rnd-range 1f0 9f0)))
                 (declare (single-float u))
                 (%t-blob (+ x0 (* u ux)) (rnd-range 1f0 2f0) (+ z0 (* u uz)) (rnd-range -1f0 1f0) (rnd-range 0.5f0 1.5f0)
                          (rnd-range -1f0 1f0) (rnd-range 0.25f0 0.4f0) (rnd-range 0.08f0 0.14f0) -1f0 0.3f0 +pal-fire+))))
           (%light (* 0.5f0 (+ x0 x1)) 1.2f0 (* 0.5f0 (+ z0 z1)) 1f0 0.45f0 0.12f0 7f0 (* 2.5f0 k) 7)))
        (:kyoku                                          ; KYOKUJITSUJIN: the ink gash where the tip bites, then a flat
                                                         ; 25 deg heat sheet racing 9 m over 3 drawings (HIT core, EMBER
                                                         ; body, a charcoal backing), then ASH lifting along it
         (let* ((sa (sage age 2f0)) (run (f-clamp (/ sa 0.25f0) 0f0 1f0)) (yaw (f-atan2 (- dx) (- dz)))
                (k (f-clamp (- 0.98f0 (* 2.8f0 (f-max 0f0 (- sa 0.25f0)))) 0f0 0.98f0)) (dr (drawing-no))
                (sd (i->f (mod (f->i dr) 7))) (r1 (* 9f0 run)) (half 0.2182f0))
           (declare (single-float sa run yaw k dr sd r1 half))
           (when (> k 0.02f0)
             (toon-ground-seg (+ x0 (* 0.5f0 px)) (+ z0 (* 0.5f0 pz)) (+ x0 (* 2.4f0 (/ dx l))) (+ z0 (* 2.4f0 (/ dz l)))
                              0.03f0 0.16f0 1f0 0.3f0 (+ seed 2f0) 0.25f0 (toon-a +pal-ink+ k))
             (when (> r1 0.6f0)                          ; (no dark backing: the effects carry no black rim)
               (%sector-verts :toon 8 x0 0.01f0 z0 0.5f0 r1 yaw half 0.8f0 (+ 61f0 sd) 0.25f0 (toon-a +pal-ember+ (* 0.9f0 k)))
               (%sector-verts :toon 6 x0 0.03f0 z0 0.55f0 (* 0.95f0 r1) yaw (* 0.7f0 half) 1f0 (+ 62f0 sd) 0.1f0 (toon-a +pal-hit+ k))))
           (when (and (> sa 0.25f0) (> k 0.3f0))
             (dotimes (i (n-of 18f0 dt))
               (let* ((u (rnd-range 0.1f0 1f0)) (w (* 2f0 u (rnd-range -1f0 1f0))))
                 (declare (single-float u w))
                 (%t-blob (+ x0 (* 9f0 u (/ dx l)) (* w px)) 0.1f0 (+ z0 (* 9f0 u (/ dz l)) (* w pz)) 0f0 (rnd-range 0.5f0 1.1f0) 0f0
                          (rnd-range 0.8f0 1.3f0) (rnd-range 0.05f0 0.1f0) -0.2f0 0.25f0 +pal-ash+))))
           (%light (+ x0 (* 0.5f0 r1 (/ dx l))) 0.6f0 (+ z0 (* 0.5f0 r1 (/ dz l))) 1f0 0.5f0 0.2f0 6f0 (* 2f0 k) 7)))
        (:south                                          ; South: (x0 z0) the grab point, L its radius: an INK ring crack
                                                         ; with an EMBER rim pulsing on twos over the tell, 5 radial cracks,
                                                         ; then eroding while the feet are held
         (let* ((sa (sage age 2f0)) (dr (drawing-no)) (tell (< age 0.28f0)) (sd (i->f (mod (f->i dr) 5)))
                (k (f-clamp (* 0.98f0 fade) 0f0 0.98f0)) (pulse (if (evenp (f->i dr)) 0.98f0 0.55f0)))
           (declare (single-float sa dr sd k pulse))
           (%tring x0 0f0 z0 l 0.11f0 +pal-ink+ k (+ seed 1f0))
           (%tring x0 0.005f0 z0 (* 0.93f0 l) 0.04f0 +pal-ember+ (* k (if tell pulse 0.4f0)) (+ seed sd))
           (dotimes (i 5)
             (let* ((a (+ (* 1.2566f0 (i->f i)) (hash01 (i->f i) seed))) (c (f-cos a)) (sn (f-sin a)) (r2 (* l (+ 1.3f0 (* 0.6f0 (hash01 (i->f i) 3.1f0))))))
               (declare (single-float a c sn r2))
               (toon-ground-seg (+ x0 (* 0.4f0 l c)) (+ z0 (* 0.4f0 l sn)) (+ x0 (* r2 c)) (+ z0 (* r2 sn)) 0.03f0 0.05f0 1f0 0.3f0
                                (+ seed (i->f i)) 0.2f0 (toon-a +pal-ink+ k))))
           (when (and tell (< sa 0.2f0))
             (dotimes (i (n-of 30f0 dt))
               (let* ((a (rnd-range 0f0 6.2832f0)))
                 (declare (single-float a))
                 (%t-blob (+ x0 (* l (f-cos a))) 0.1f0 (+ z0 (* l (f-sin a))) (* 0.8f0 (f-cos a)) (rnd-range 0.5f0 1.5f0) (* 0.8f0 (f-sin a))
                          (rnd-range 0.5f0 0.8f0) (rnd-range 0.15f0 0.25f0) -0.2f0 0.25f0 +pal-dust+))))
           (%light x0 0.3f0 z0 1f0 0.4f0 0.12f0 4f0 (* 1.5f0 k (if tell pulse 0.3f0)) 6)))
        (:kyokko                                         ; KYOKKO: the ray along the line at chest height: an EMBER lens
                                                         ; with a white HIT core, a small INK sun with an EMBER fill at its
                                                         ; tip; eroding over its life
         (let* ((k (f-clamp (* 0.98f0 (- 1f0 (* v v v))) 0f0 0.98f0)) (dr (drawing-no)) (sd (i->f (mod (f->i dr) 5)))
                (y 1.1f0) (mx (* 0.5f0 (+ x0 x1))) (mz (* 0.5f0 (+ z0 z1))))
           (declare (single-float k dr sd y mx mz))
           (when (> k 0.02f0)
             (fx-crescent x0 y z0 x1 y z1 mx (+ y 0.02f0) mz 0.1f0 :lens 0.06f0 (+ 30f0 sd) +pal-ember+ k :push 0.2f0)
             (fx-crescent x0 y z0 x1 y z1 mx (+ y 0.02f0) mz 0.035f0 :lens 0.03f0 (+ 35f0 sd) +pal-hit+ k :push 0.24f0)
             (fx-disc x1 y z1 0.3f0 0.1f0 (+ 40f0 sd) +pal-ink+ k :push 0.1f0)
             (fx-disc x1 y z1 0.22f0 0.1f0 (+ 41f0 sd) +pal-ember+ k :push 0.14f0)
             (%light x1 y z1 1f0 0.6f0 0.3f0 4f0 (* 2f0 k) 7))))
        (t                                               ; :crack (Buttagiru): gash + core, dust, a few rocks
         (let* ((open (f-clamp (/ age 0.08f0) 0f0 1f0)) (glow (f-clamp (- 1f0 (/ age (* 0.5f0 life))) 0f0 1f0)))
           (declare (single-float open glow))
           (%crack x0 z0 (+ x0 (* open dx)) (+ z0 (* open dz)) 0.2f0 (* 0.98f0 fade) glow seed)
           (when (< age 0.2f0)
             (dotimes (i (n-of 20f0 dt))
               (let* ((u (rnd01)) (sd (if (< (rnd01) 0.5f0) -1f0 1f0)))
                 (declare (single-float u sd))
                 (%t-shard (+ x0 (* u dx)) 0.15f0 (+ z0 (* u dz)) (* sd 2.5f0 px) (rnd-range 2f0 4f0) (* sd 2.5f0 pz)
                           (rnd-range 0.5f0 0.8f0) (rnd-range 0.08f0 0.14f0) 9f0 +pal-dust+)))
             (dotimes (i (n-of 35f0 dt))
               (let* ((u (rnd01)) (sd (if (< (rnd01) 0.5f0) -1f0 1f0)))
                 (declare (single-float u sd))
                 (%t-blob (+ x0 (* u dx)) 0.15f0 (+ z0 (* u dz)) (* sd 2f0 px) (rnd-range 0.5f0 1.2f0) (* sd 2f0 pz)
                          (rnd-range 0.5f0 0.8f0) (rnd-range 0.18f0 0.3f0) -0.2f0 0.25f0 +pal-dust+)))))))
      nil)))

(defvar *sky-c0* (make-f32 4)) (defvar *sky-c1* (make-f32 4)) (defvar *sky-scr* (make-f32 3))
(defun %ui-col (v r g b a) (setf (aref v 0) (f32 r) (aref v 1) (f32 g) (aref v 2) (f32 b) (aref v 3) (f32 a)) v)

(defun vfx-sky-split (x z yaw age life)
  "Nozarashi Kikon: a vertical line of light across the whole screen through ground point (x z)
(UI space, so it always spans the sky), the ground split 16 m along YAW (a :meteor line cut), and
for the first 0.2 s the screen halves sheared apart along the centre line (*GRADE-SPLIT*; 0 after,
END-CINE also resets it). Shoot it down the cut (camera on the cut line) so seam and split meet."
  (let* ((age (f32 age)) (v (min 1.0 (/ age (max life 0.01)))) (fade (- 1.0 (* v v v)))
         (fx (- (sin yaw))) (fz (- (cos yaw))) (s *sky-scr*)
         (sx (if (world-to-screen s (f32 x) 1f0 (f32 z)) (aref s 0) (* 0.5 (window-width))))
         (h (window-height)) (ui (ui-scale))
         (wide (* ui (+ 3.0 (* 40.0 (max 0.0 (- 1.0 (/ age 0.12))))))))
    (vfx-line-cut (- x (* 8 fx)) (- z (* 8 fz)) (+ x (* 8 fx)) (+ z (* 8 fz)) age life :meteor)
    (setf *grade-split* (f32 (* 0.035 h (max 0.0 (min 1.0 (/ age 0.03) (/ (- 0.2 age) 0.05))))))
    (let ((iw (+ wide (* ui 5))))                        ; a hard white band with ink borders (no glow: the frame's
      (ui-rect (- sx (* 0.5 iw)) 0 iw h (%ui-col *sky-c0* 0.03 0.03 0.047 fade))   ; negative / manga page is the flash)
      (ui-rect (- sx (* 0.5 wide)) 0 wide h (%ui-col *sky-c1* 1 1 0.97 fade)))
    nil))

;;; ---------------------------------------------------------------- one-shots
(defun-fast vfx-awaken-burst (x y z kind)
  "Awakening one-shots at the feet (x y z), drawn toon (docs/style/STYLE_STORM_DESIGN.md §4.1 / §4.2). KIND :bankai (every
flame within 6 m pulled into the blade: FIRE flames and EMBER shards rushing in to the hands, ~0.45 s), :bankai-burst
(the reveal: a charcoal double ring with an ember line, charcoal puffs, ash shards: no fire), :nozarashi (the
yellow reiatsu pillar: REIATSU flames shooting up, a flat ring), :nozarashi-half (a later cup 3's: half as tall)."
  (with-floats (x y z)
    (case kind
      (:bankai
       (dotimes (i 36)
         (let* ((a (rnd-range 0f0 6.2832f0)) (r (rnd-range 2.5f0 6f0)) (h (rnd-range 0.2f0 3.2f0))
                (px (* r (f-cos a))) (pz (* r (f-sin a))) (k (rnd-range 2f0 2.4f0)))
           (declare (single-float a r h px pz k))
           (%t-blob (+ x px) (+ y h) (+ z pz) (* (- k) px) (* k (- 1.4f0 h)) (* (- k) pz) (/ 1f0 k) (rnd-range 0.2f0 0.35f0)
                    0f0 0.3f0 +pal-fire+)))
       (dotimes (i 16)
         (let* ((a (rnd-range 0f0 6.2832f0)) (r (rnd-range 3f0 6f0)) (h (rnd-range 0.3f0 3f0))
                (px (* r (f-cos a))) (pz (* r (f-sin a))))
           (declare (single-float a r h px pz))
           (%t-shard (+ x px) (+ y h) (+ z pz) (* -2.4f0 px) (* 2.4f0 (- 1.4f0 h)) (* -2.4f0 pz) 0.4f0 0.12f0 0f0 +pal-ember+))))
      (:bankai-burst
       (stamp :garb x y z :scale 1.2)
       (dotimes (i 6)
         (let* ((a (+ (* 1.047f0 (i->f i)) (rnd-range -0.3f0 0.3f0))) (sp (rnd-range 1.2f0 2.2f0)))
           (declare (single-float a sp))
           (%t-blob (+ x (* 0.6f0 (f-cos a))) (+ y (rnd-range 0.3f0 1.4f0)) (+ z (* 0.6f0 (f-sin a))) (* sp (f-cos a)) (rnd-range 0.5f0 1.2f0)
                    (* sp (f-sin a)) (rnd-range 0.9f0 1.3f0) (rnd-range 0.35f0 0.55f0) -0.3f0 0.3f0 +pal-black-smoke+)))
       (dotimes (i 10)
         (let* ((a (rnd-range 0f0 6.2832f0)) (sp (rnd-range 3f0 6f0)))
           (declare (single-float a sp))
           (%t-shard x (+ y (rnd-range 0.5f0 1.8f0)) z (* sp (f-cos a)) (rnd-range 0.5f0 2.5f0) (* sp (f-sin a))
                     (rnd-range 0.6f0 1.0f0) (rnd-range 0.1f0 0.2f0) 4f0 +pal-ash+)))
       (flash-light x (+ y 1.0) z 1.0 0.4 0.12))
      (:oni                                            ; Kenpachi's Bankai: the BLOOD pillar shooting up over INK flames
       (dotimes (i 28)
         (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) (+ y (rnd-range 0f0 1f0)) (+ z (rnd-range -0.35f0 0.35f0))
                  (rnd-range -0.3f0 0.3f0) (rnd-range 10f0 20f0) (rnd-range -0.3f0 0.3f0)
                  (rnd-range 0.35f0 0.6f0) (rnd-range 0.3f0 0.5f0) 0f0 0.3f0 +pal-blood+))
       (dotimes (i 14)
         (%t-blob (+ x (rnd-range -0.5f0 0.5f0)) (+ y (rnd-range 0f0 0.6f0)) (+ z (rnd-range -0.5f0 0.5f0))
                  (rnd-range -0.4f0 0.4f0) (rnd-range 6f0 12f0) (rnd-range -0.4f0 0.4f0)
                  (rnd-range 0.4f0 0.7f0) (rnd-range 0.35f0 0.55f0) 0f0 0.3f0 +pal-ink+))
       (flash-light x (+ y 1.0) z 1.0 0.15 0.12))
      (:arm-burst                                      ; the arm bursting (x y z = the forearm): BLOOD spray, ink shards
       (dotimes (i 16)
         (%t-blob x y z (rnd-range -3f0 3f0) (rnd-range 0.5f0 4f0) (rnd-range -3f0 3f0) (rnd-range 0.4f0 0.7f0)
                  (rnd-range 0.03f0 0.06f0) 9f0 0.3f0 +pal-blood+))
       (dotimes (i 10)
         (%t-shard x y z (rnd-range -4f0 4f0) (rnd-range 1f0 5f0) (rnd-range -4f0 4f0) (rnd-range 0.5f0 0.8f0)
                   (rnd-range 0.05f0 0.1f0) 9f0 +pal-ink+))
       (flash-light x y z 1.0 0.15 0.12))
      (:arm-crack                                      ; a pip spent / cracked (x y z = the forearm): a BLOOD crack flash
       (dotimes (i 6)
         (%t-shard x y z (rnd-range -1.5f0 1.5f0) (rnd-range 0.5f0 2f0) (rnd-range -1.5f0 1.5f0) (rnd-range 0.2f0 0.35f0)
                   (rnd-range 0.03f0 0.05f0) 4f0 +pal-blood+)))
      ((:nozarashi :nozarashi-half)                    ; (half: a later cup 3's flare, half as tall: Phase 6)
       (let ((vk (if (eq kind :nozarashi) 1f0 0.5f0)))
         (declare (single-float vk))
         (dotimes (i (if (eq kind :nozarashi) 28 18))
           (%t-blob (+ x (rnd-range -0.35f0 0.35f0)) (+ y (rnd-range 0f0 1f0)) (+ z (rnd-range -0.35f0 0.35f0))
                    (rnd-range -0.3f0 0.3f0) (* vk (rnd-range 10f0 20f0)) (rnd-range -0.3f0 0.3f0)
                    (rnd-range 0.35f0 0.6f0) (rnd-range 0.3f0 0.5f0) 0f0 0.3f0 +pal-reiatsu+))
         (stamp :land x y z :scale (* 2.4f0 vk)))       ; (no dust puffs: on the black card they hid him)
       (flash-light x (+ y 1.0) z 1.0 0.85 0.3)))
    nil))

;;; ---------------------------------------------------------------- Phase 6: the Nozarashi skull, the K.O. rain
(defun-fast vfx-skull (x y z k)
  "The skull in the Nozarashi pillar (§5, Phase 6): Kenpachi's reiatsu taking the shape of a skull, drawn in the screen
plane at (X Y Z): an INK cranium and jaw (the black shape with the white hairline, cut out of the yellow), REIATSU eye
sockets and nose (the pillar showing through, the sockets' white cores glaring), 6 white fangs; re-drawn on twos
(the boil). K: presence. 0 B."
  (declare (single-float x y z k))
  (let* ((dr (drawing-no)) (sd (i->f (mod (f->i dr) 5))))
    (declare (single-float dr sd))
    (with-cam (rx ry rz ux uy uz)
      (macrolet ((at ((px py) &body body)                ; bind X1 Y1 Z1 = the screen-plane point (px, py) m off the centre
                   `(let* ((x1 (+ x (* ,px rx) (* ,py ux))) (y1 (+ y (* ,px ry) (* ,py uy))) (z1 (+ z (* ,px rz) (* ,py uz))))
                      (declare (single-float x1 y1 z1))
                      ,@body)))
        (at (0f0 0.08f0) (fx-disc x1 y1 z1 0.56f0 0.06f0 (+ 70f0 sd) +pal-ink+ k :push 0.1f0))            ; the cranium
        (at (0f0 -0.42f0) (fx-star x1 y1 z1 0.36f0 0.3f0 6 0.52f0 0f0 0f0 0.05f0 (+ 71f0 sd) +pal-ink+ k :push 0.12f0))  ; the jaw
        (at (-0.21f0 0.04f0) (fx-disc x1 y1 z1 0.15f0 0.1f0 (+ 72f0 sd) +pal-reiatsu+ k :push 0.2f0))     ; the sockets
        (at (0.21f0 0.04f0) (fx-disc x1 y1 z1 0.15f0 0.1f0 (+ 73f0 sd) +pal-reiatsu+ k :push 0.2f0))
        (at (0f0 -0.2f0) (fx-star x1 y1 z1 0.08f0 0.06f0 3 3.1416f0 0f0 0f0 0.05f0 (+ 74f0 sd) +pal-reiatsu+ k :push 0.2f0))
        (dotimes (i 6)                                     ; the fangs along the jaw
          (let* ((f (i->f i)) (px (* 0.09f0 (- f 2.5f0))))
            (declare (single-float f px))
            (at (px -0.4f0) (fx-shard x1 y1 z1 (- ux) (- uy) (- uz) (if (member i '(0 5)) 0.16f0 0.11f0) 0.03f0 0.05f0 (+ f dr)
                                      +pal-hit+ k :push 0.22f0))))))
    nil))

(defun-fast vfx-rain (cx cz age k)
  "The K.O.'s rain (§6: rain as an emotional accent, Phase 6): 110 thin white HIT streaks (grey hairline) slanting down through a 14 m box
round (CX CZ), falling 14 m/s on threes (the streaks re-drawn every 1/8 s), and 10 small white splash rings on the
ground each drawing; AGE s since it began (the fx clock), K presence (a fade in). No particles: 0 B."
  (declare (single-float cx cz age k))
  (let* ((a (sage age 3f0)) (dr (drawing-no 8f0)) (l (f-sqrt (+ 1f0 0.0225f0 0.0025f0))) (dx (/ 0.15f0 l)) (dy (/ -1f0 l)) (dz (/ 0.05f0 l)))
    (declare (single-float a dr l dx dy dz))
    (dotimes (i 110)
      (let* ((f (i->f i)) (y (- 9f0 (f-mod (+ (* 9f0 (hash01 f 1.3f0)) (* 14f0 a)) 9f0))))
        (declare (single-float f y))
        (fx-shard (+ cx (* 14f0 (- (hash01 f 2.7f0) 0.5f0))) (+ y 0.2f0) (+ cz (* 14f0 (- (hash01 f 5.9f0) 0.5f0)))
                  dx dy dz 0.9f0 0.018f0 0f0 f +pal-hit+ k :push 0f0)))
    (dotimes (i 10)
      (let* ((f (+ (i->f i) (* 10f0 dr))))
        (declare (single-float f))
        (%tring (+ cx (* 12f0 (- (hash01 f 3.3f0) 0.5f0))) 0f0 (+ cz (* 12f0 (- (hash01 f 7.1f0) 0.5f0))) 0.12f0 0.02f0
                +pal-hit+ (* 0.9f0 k) f 12)))
    nil))

(declaim (type f32vec *acc-v*))
(defvar *acc-v* (make-f32 3) "VFX-FACE-ACCENT: the head point.")
(defun-fast vfx-face-accent (jm kind ms)
  "The expression accent at gameplay distance (Phase 6: the faces are ~12 px tall there), over the head of the body
posed in JM, MS milliseconds after the face changed. KIND 1 (shout): 6 ink strokes (BLACK SMOKE: dark, a white hairline)
bursting out of the head's upper half
(the manga roar), grown over 2 drawings, re-drawn on twos, eroding after 250 ms, gone at 350; KIND 2 (hurt): 3 white
HIT drops flung off the head, falling, gone at 400 ms. 0 B."
  (declare (type f32vec jm) (fixnum kind ms))
  (let* ((v *acc-v*) (age (* 0.001f0 (i->f ms))) (a (sage age 2f0)) (dr (drawing-no)))
    (declare (type f32vec v) (single-float age a dr))
    (joint-point! v jm (ji :head) 0f0 0.12f0 0.02f0)
    (with-cam (rx ry rz ux uy uz)
      (let* ((hx (aref v 0)) (hy (aref v 1)) (hz (aref v 2)))
        (declare (single-float hx hy hz))
        (if (= kind 1)
            (when (< ms 350)
              (let* ((k (* 0.98f0 (f-clamp (/ (- 0.35f0 a) 0.1f0) 0f0 1f0))) (g (f-min 1f0 (+ 0.6f0 (* 5f0 a)))))
                (declare (single-float k g))
                (dotimes (i 6)
                  (let* ((f (i->f i)) (th (+ 0.35f0 (* 0.49f0 f) (* 0.14f0 (- (hash01 (+ f dr) 3.1f0) 0.5f0))))
                         (c (f-cos th)) (sn (f-sin th)) (l (* g (+ 0.28f0 (* 0.14f0 (hash01 (+ f dr) 1.7f0)))))
                         (dx (+ (* c rx) (* sn ux))) (dy (+ (* c ry) (* sn uy))) (dz (+ (* c rz) (* sn uz))) (r (+ 0.3f0 (* 0.5f0 l))))
                    (declare (single-float f th c sn l dx dy dz r))
                    (fx-shard (+ hx (* r dx)) (+ hy (* r dy)) (+ hz (* r dz)) dx dy dz l 0.045f0 0.05f0 (+ f dr) +pal-black-smoke+ k
                              :push 0.3f0)))))
            (when (< ms 400)
              (dotimes (i 3)
                (let* ((f (i->f i)) (side (if (= i 1) -1f0 1f0)) (vx (* side (+ 1.2f0 (* 0.5f0 f)))) (vy (- 1.6f0 (* 0.3f0 f)))
                       (px (* vx a)) (py (- (* vy a) (* 4.9f0 a a))) (ty (- vy (* 9.8f0 a)))
                       (tl (f-max 1f-3 (f-hypot vx ty))) (k (* 0.98f0 (f-clamp (/ (- 0.4f0 a) 0.1f0) 0f0 1f0))))
                  (declare (single-float f side vx vy px py ty tl k))
                  (fx-shard (+ hx (* (+ (* side 0.1f0) px) rx) (* py ux)) (+ hy (* (+ (* side 0.1f0) px) ry) (* py uy))
                            (+ hz (* (+ (* side 0.1f0) px) rz) (* py uz))
                            (/ (+ (* vx rx) (* ty ux)) tl) (/ (+ (* vx ry) (* ty uy)) tl) (/ (+ (* vx rz) (* ty uz)) tl)
                            0.2f0 0.07f0 0.05f0 (+ 7f0 f) +pal-hit+ k :push 0.3f0)))))))
    nil))

(defun-fast vfx-soul-flame (x y z age)
  "The red soul flame floating over a Kikon-able victim (x y z = the flame's base, e.g. 0.4 m over the
head): one BLOOD ribbon with a dark hairline, boiling through 3 drawings (its seed cycles), a small
white core. AGE (s) bobs it; no particles."
  (with-floats (x y z age)
    (let* ((y (+ y (* 0.05f0 (f-sin (* 3f0 (sage age 2f0))))))
           (dr (i->f (mod (f->i (* 12f0 (fx-clock))) 3))) (seed (+ 11f0 (* 5f0 dr)))
           (h (+ 0.9f0 (* 0.12f0 (hash01 dr 2.7f0)))) (lean (* 0.08f0 (- (hash01 dr 4.1f0) 0.5f0))))
      (declare (single-float y dr seed h lean))
      (toon-ribbon (x y z) (lean h 0f0) (0.22f0 0f0) :seed (- seed) :pal +pal-blood+ :k 0.95f0 :ph (* 2f0 dr) :sway 0.07f0)
      (toon-ribbon ((+ x 0.1f0) (+ y 0.05f0) z) ((+ 0.1f0 lean) (* 0.55f0 h) 0f0) (0.1f0 0f0) :seed (- -3f0 seed) :pal +pal-blood+ :k 0.95f0
                   :ph (+ 1f0 dr) :sway 0.05f0 :segs 4)
      (toon-ribbon (x (+ y 0.04f0) z) ((* 0.5f0 lean) (* 0.5f0 h) 0f0) (0.035f0 0f0) :seed (- -5f0 seed) :wob 0.1f0 :pal +pal-hit+ :k 0.95f0
                   :ph (* 2f0 dr) :sway 0.03f0 :segs 3))))


