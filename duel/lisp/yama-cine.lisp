;;;; yama-cine.lisp — Yamamoto's cinematics on his core kit (DUEL_YAMA_CORE §7.3, batch 1 stage C): the old kit's two that still run on
;;;; today's cinema API, back from the branch `retired-kits` (`git show retired-kits:duel/lisp/yama.lisp`) unchanged but for two lines
;;;; (below). The grammar is cinema.lisp's (docs/style/STYLE_STORM_DESIGN.md §5). VFX-AWAKEN-BURST's :bankai / :bankai-burst looks came
;;;; with art K1 (DUEL_YAMA_CORE §16). Art K4 (§15.3, §19): the Bankai's 東 / 西 / 南 Kikon cinematics (YAMA-HIGASHI-CINE, YAMA-NISHI-CINE,
;;;; YAMA-MINAMI-CINE) and their looks, each look one DEFUN-FAST of the cinematic frame and the actors' places (0 B: debug 87448).
(in-package :duel)

(defcine yama-tenchi-cine (a v :len 168 :hold 26)
  "Tenchi Kaijin (北's Kikon: the NS 北 wave's strike and AS 北 carry it as their :cine; §4.1 of DUEL_YAMA_REWORK, paced by user review 3):
beat 0 in the Bankai's grey; a long black card, Yamamoto silhouetted with a white back-rim under the 北 / 天地灰尽 stamp, silence; the slash:
a white / ink two-tone frame with the hard white slash, then a manga page; the victim flakes into ash (an ink splash) in the same shot; a
low wide of him standing in the grey world. (The old script hid the victim's body after the ash, MODEL-ALPHA 0, which nothing restores
after the reset: dropped.)"
  (at 0 (face-each-other a v 2.4)
      (cine-clip a :ya-tenchi :blend 2 :speed (/ 18.0 68.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (cine-grade :spot))
  (at 12 (card :black a) (back-rim 56) (shot-on a 70 3.2 0.9 :look 1.2 :off 0.8) (lens 42 -8) (silence 56)
      (caption "天地灰尽" :mark "北" :reading "TENCHI KAIJIN" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (during (68 168) (vfx-tenchi-slash (/ (- cf 68) 60.0) 0.8))
  (at 68 (card nil) (play-sfx :kikon-slash) (impact-frame :two-tone 4) (shot-pair a v 1 5.0 1.4) (lens 55))
  (at 72 (impact-frame :manga 12))
  (at 86 (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-ash-burst x y z) (vfx-konpaku-shatter x y z 3))
      (impact-splash-at v 0.0 14 0.07)
      (play-sfx :konpaku-shatter) (play-sfx :sizzle) (shake 0.2 0.3))
  (at 110 (shot-on a -35 4.6 0.5 :look 1.3) (lens 48) (caption-exit)))

(defcine yama-bankai-cine (a v :len 138 :hold 72)
  "BANKAI (the awakening's, the kit :bankai's :cine; paced by user review 3): beat 0; every flame in the arena is drawn into the blade
(close, low, wide-angle, focus lines); from behind, in silence, the world drains to grey; the reveal, held long: a negative, then Yamamoto
a black silhouette on a white card, the only colour the ember line of the charred blade, the 卍解 / 残火の太刀 stamp in black with its
splash; the charcoal burst and the plaza cracks in the grey world."
  (at 0 (cine-clip a :ya-bankai :blend 3 :speed (/ 2.2 1.8)) (cine-clip v (kit-stance (kit-of v)) :blend 6)
      (setf (model-weapon (model a)) :ryujin-jakka)
      (hold-both a v 12) (impact-frame :negative 2)
      (play-sfx :awaken-rise))
  (at 12 (let ((p (pos-of a))) (vfx-awaken-burst (aref p 0) 0.0 (aref p 2) :bankai))   ; every flame sucked in (L11)
      (shot-on a 25 1.5 0.45 :look 1.45) (lens 88 6) (focus-lines 36))
  (during (12 60) (let ((p (pos-of a)))
                    (vfx-charge (aref p 0) 2.4 (aref p 2) u (cine-dt))
                    (vfx-aura (aref p 0) 0.0 (aref p 2) 2.2 :hellfire (/ cf 60.0) (cine-dt) :k (- 1.0 u))))
  (at 40 (silence 20) (shot-on a 200 3.0 0.8 :look 1.4) (lens 50))
  (at 44 (cine-grade :spot))                             ; the form's grey (main.lisp FORM-GRADE takes over after)
  (at 60 (setf (model-weapon (model a)) :zanka)
      (impact-frame :negative 2) (card :white a) (silhouette-black a)
      (caption "卍解" :kanji2 "残火の太刀" :reading "BANKAI" :sub "ZANKA NO TACHI" :side 0 :ink t)
      (play-sfx :awaken-boom) (shake 0.25 0.4)
      (shot-on a 15 4.4 0.6 :look 1.25 :off 0.9) (lens 40))
  (at 118 (card nil) (unsilhouette) (shot-on a -30 6.5 1.6 :look 1.1) (lens 50)
      (let ((p (pos-of a)))                              ; back in the grey world: the charcoal burst, the plaza cracks
        (vfx-awaken-burst (aref p 0) 0.0 (aref p 2) :bankai-burst)
        (stage-crack-add (aref p 0) (aref p 2) 3.0)
        (stage-crack-add (+ (aref p 0) 3.5) (- (aref p 2) 2.0) 2.2)
        (stage-crack-add (- (aref p 0) 3.0) (+ (aref p 2) 2.5) 2.4))))

;;; ================================================================ art K4: the Bankai's 東 / 西 / 南 Kikons (DUEL_YAMA_CORE §15.3, §19)
;;; Kept apart (§15.3): 東 = absence (a tap, nothing, then the floor behind the victim is gone), 西 = heat at arm's length (the foe strikes,
;;; his weapon dies on the garb, the old man walks him down and passes through him), 南 = the crowd and his back (he never touches the
;;; victim). Colour (D4 「只有西和北有火」): 東 and 南 are ink / charcoal, bone-ash white and an ember hairline; orange flame only in 西.
;;; None uses 天地灰尽's black card. The AT events cut and stamp (step mode); each cinematic's DURING calls one look below, a pure
;;; function of the cinematic frame and the actors' places (draw mode, 0 B: rnd01 only, the toon macros).
(declaim (type f32vec *ya-ct* *ya-cb* *ya-cw*))
(defvar *ya-ct* (make-f32 3) "The K4 looks' scratch point (the victim's weapon tip).")
(defvar *ya-cb* (make-f32 3) "... and the weapon's base.")
(defvar *ya-cw* (let ((v (make-f32 2))) (setf (aref v 0) 1f0 (aref v 1) 0.25f0) v)
  "西: the victim's weapon's length and blade base (grip to tip / base, WEAPON-LEN / -BASE), kept at f40 (YAMA-WEAPON-KEEP) so the
look reads no boxed struct float.")
(defvar *ya-chz* (make-hazard :kind :ya-col :size 1.2f0 :life 400)
  "南's hands at cinematic scale: a stand-in hazard for YAMA-HANDS-LOOK (a plain struct, never an entity: the sim never sees it).")
(defvar *ya-cpz* (make-hazard :kind :ya-col :size 1.4f0 :life 400) "... and 南's pile: the same for YAMA-PILE-LOOK.")

(defmacro %ya-line ((px pz qx qz fx fz rx rz d) a v &body body)
  "Bind A's and V's feet (PX PZ, QX QZ), the unit from A to V (FX FZ), its right normal (RX RZ) and their distance D (single floats)."
  `(let* ((%p (pos-of ,a)) (%q (pos-of ,v)) (,px (aref %p 0)) (,pz (aref %p 2)) (,qx (aref %q 0)) (,qz (aref %q 2))
          (,d (f-max 0.01f0 (f-hypot (- ,qx ,px) (- ,qz ,pz)))) (,fx (/ (- ,qx ,px) ,d)) (,fz (/ (- ,qz ,pz) ,d)) (,rx (- ,fz)) (,rz ,fx))
     (declare (type f32vec %p %q) (single-float ,px ,pz ,qx ,qz ,d ,fx ,fz ,rx ,rz) (ignorable ,px ,pz ,qx ,qz ,d ,fx ,fz ,rx ,rz))
     ,@body))

;;; ---------------------------------------------------------------- 東 旭日刃 KYOKUJITSUJIN (§15.3.1, 168 f)
(defun-fast yama-higashi-look (a v cf)
  "東's look at cinematic frame CF: the void (D3 「黑色虛空帶」, §15.3.4 flag 1: no stage geometry is removed, a flat INK wedge on the
floor shot from above) opens from where the tip touched, 1.86 m ahead of him (NS1c's tip by FK), through the victim's spot: a ragged
radial tear (YAMA-TEAR, the user's §20) whose body runs 0.8 m wide at the tip to 5 m at 12 m in 10 f from f84, 16 spikes a side and 5 round
each end growing out over 14 f; no ember hairline (§20.1); ash falling into it to the end. A look; 0 B."
  (declare (fixnum cf))
  (when (>= cf 84)
    (%ya-line (px pz qx qz fx fz rx rz d) a v
      (let* ((tx (+ px (* 1.86f0 fx))) (tz (+ pz (* 1.86f0 fz))) (u (f-min 1f0 (/ (i->f (- cf 84)) 10f0))) (l (* 12f0 u))
             (w0 0.4f0) (w1 (+ 0.4f0 (* 2.1f0 u))) (pk (toon-a +pal-ink+ 0.98f0 t)) (rdt (aref *ya-rdt* 0)))
        (declare (single-float tx tz u l w0 w1 pk rdt))
        (when (> l 0.05f0)                                ; the tear (YAMA-TEAR, §20.1): its spikes out over 14 f, a fixed seed
          (yama-tear tx tz fx fz l w0 w1 0.35f0 (f-min 1f0 (/ (i->f (- cf 83)) 14f0)) 16 5 78f0 pk)
          (dotimes (i (n-of 60f0 rdt))                    ; ash falling into it
            (let* ((s (rnd-range 0f0 l)) (w (* (+ w0 (* (- w1 w0) (/ s 12f0))) (rnd-range -0.9f0 0.9f0))))
              (declare (single-float s w))
              (%t-blob (+ tx (* s fx) (* w rx)) (rnd-range 0.8f0 2.4f0) (+ tz (* s fz) (* w rz)) 0f0 (rnd-range -1.1f0 -0.5f0) 0f0
                       (rnd-range 0.9f0 1.4f0) (rnd-range 0.04f0 0.08f0) 0.2f0 0.2f0 +pal-ash+)))))))
  nil)

(defcine yama-higashi-cine (a v :len 168 :hold 96)
  "旭日刃 KYOKUJITSUJIN, the Bankai's 東 Kikon (DUEL_YAMA_CORE §15.3.1, §19): beat 0, the blade held high (NS1c's raised pose); on him
in front, low, the 旭日刃 stamp in silence, the only colour the blade's ember edge; side-on in slow motion the diagonal comes down past
his face and only the tip taps the floor at the victim's feet; at the tip on the ground, nothing happens, the smoke thread rises; from high
behind him the floor beyond the tip is gone, a black wedge through the victim's spot to the arena's edge, the boom late; behind the
victim, half on the black, his Konpaku shatters; low across the void, the old man lets the blade hang."
  (at 0 (cine-place a v 2.2)
      (cine-clip a :ya-kyoku :blend 2 :time (/ 15.0 60.0) :speed 0.0) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (cine-grade :spot) (play-sfx :whoosh-heavy :pitch 0.8))
  (at 12 (shot-on a -45 2.6 0.6 :look 1.5 :off 0.8) (lens 44 -6) (silence 32)   ; (-45 deg, not 30: the victim 2.2 m ahead and his
                                                                              ;  weapon stood in front of the lens)
      (caption "旭日刃" :mark "東" :reading "KYOKUJITSUJIN" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (at 44 (shot-pair a v 1 (if (portrait-p) 7.0 5.0) 1.0) (lens 50) (cine-slow 0.35)
      (cine-clip a :ya-kyoku :blend 0 :time (/ 15.0 60.0)) (play-sfx :whoosh-heavy :pitch 0.6))
  (at 58 (cine-clip a :ya-kyoku :blend 0 :time (/ 20.0 60.0) :speed 0.0)   ; only the tip on the plaza (NS1c from f20), held
      (play-sfx :hs-tip :pitch 1.4 :gain 0.6)
      (%ya-line (px pz qx qz fx fz rx rz d) a v           ; a pinch of ash at the tip
        (dotimes (i 10)
          (%t-blob (+ px (* 1.86f0 fx) (rnd-range -0.08f0 0.08f0)) 0.05f0 (+ pz (* 1.86f0 fz) (rnd-range -0.08f0 0.08f0))
                   (rnd-range -0.3f0 0.3f0) (rnd-range 0.2f0 0.6f0) (rnd-range -0.3f0 0.3f0) (rnd-range 0.6f0 1.0f0)
                   (rnd-range 0.03f0 0.06f0) -0.1f0 0.2f0 +pal-ash+))))
  (at 62 (cine-slow 1) (silence 22) (lens 70)          ; at the tip on the ground, the victim's feet behind it: nothing
      (%ya-line (px pz qx qz fx fz rx rz d) a v
        (let ((tx (+ px (* 1.86f0 fx))) (tz (+ pz (* 1.86f0 fz))))
          (cine-cam (+ tx (* -1.2f0 fx) (* 1.05f0 rx)) 0.15 (+ tz (* -1.2f0 fz) (* 1.05f0 rz)) (+ tx (* 0.3f0 fx)) 0.35 (+ tz (* 0.3f0 fz))))))
  (at 84 (shot-on a 180 6.5 7.0 :look 0.0 :ahead 4.0) (lens 40))
  (at 88 (play-sfx :ground-crack) (play-sfx :explode :pitch 0.4) (shake 0.5 0.5))   ; the boom, 4 f late
  (during (84 168) (yama-higashi-look a v cf))
  (at 100 (shot-on v 150 (if (portrait-p) 5.6 4.0) 1.0 :look 1.0) (lens 50))   ; (portrait: past the close-up line, so he is in it too)
  (at 104 (impact-frame :negative 2) (cine-clip v :sh-crumple :blend 3)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 0.0 14 0.08) (play-sfx :konpaku-shatter) (shake 0.3 0.4))
  (at 106 (impact-frame :manga 10))
  (at 130 (shot-on a 25 7.0 0.4 :look 1.0) (lens 40) (caption-exit)   ; (25 deg off the line: the crumpled victim hid him)
      (cine-clip a :ya-e-stance :blend 14)))              ; he lifts the point off the floor and lets the blade hang

;;; ---------------------------------------------------------------- 西 殘日獄衣 ZANJITSU GOKUI (§15.3.2, the user's storyboard, 180 f)
(defmacro %ya-garb (x z rx rz g k seed)
  "西's garb at full (§15.3.2; batch J2, §28: 殘日獄衣, YA-GARB flared as the moves flare it: 1 + 0.9 G, G 0..1 its growth, x the
presence K), the molten ring at his soles with a white-hot core (the garb brings its own light). (RX RZ), his right, unused since J2 (Z1's
mantle lay in it; the call kept). Single-float forms; 0 B."
  (declare (ignore rx rz))
  `(let* ((%k ,k))
     (declare (single-float %k))
     (ya-garb ,x ,z (* %k (+ 1f0 (* 0.9f0 ,g))))
     (%tring ,x 0f0 ,z 0.6f0 0.07f0 +pal-flame+ %k (+ ,seed 3f0))
     (%tring ,x 0.008f0 ,z 0.6f0 0.02f0 +pal-hit+ (* 0.8f0 %k) (+ ,seed 4f0))))

(defun-fast yama-nishi-look (a v cf)
  "西's look at cinematic frame CF: f40-52 the victim's weapon turning to ash from the tip toward the hilt (§15.3.4 flag 4: ash drawn over
it, the model untouched; at f52 the cinematic hides what is left, CINE-END's REFRESH-LOOK gives it back however it ends); the garb at full
from f52 (built in 4 f, guttering from f156); molten footprints behind him on the walk (f72-124); the white-hot streak of the pass
(f124-134); the column of flame rising off the victim (f130-170: 西's fire); the ash streaming up off his charred body from f134, black
smoke from f150. A look; 0 B."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((rdt (aref *ya-rdt* 0)) (seed 37f0) (dr (flow-ph)))   ; (DR: a flowing phase, §15.7; SEED a literal: his position
                                                                   ;  churned the noise through the walk, §15.8)
      (declare (single-float rdt seed dr))
      (when (and (<= 40 cf) (< cf 53))                    ; the ash creeping from the tip toward the hilt
        (let ((m (model v)))
          (when (model-weapon m)                          ; (BODY-WEAPON-TIP / -BASE's points, their lengths kept at f40)
            (joint-point! *ya-ct* (model-joints m) (ji :weapon-r) 0f0 0f0 (- (aref *ya-cw* 0)))
            (joint-point! *ya-cb* (model-joints m) (ji :weapon-r) 0f0 0f0 (- (aref *ya-cw* 1)))
            (let* ((tp *ya-ct*) (bs *ya-cb*) (u (f-min 1f0 (/ (i->f (- cf 39)) 12f0)))
                   (x0 (aref tp 0)) (y0 (aref tp 1)) (z0 (aref tp 2))
                   (ddx (- (aref bs 0) x0)) (ddy (- (aref bs 1) y0)) (ddz (- (aref bs 2) z0)))
              (declare (type f32vec tp bs) (single-float u x0 y0 z0 ddx ddy ddz))
              (dotimes (i 9)                              ; ash clumps over the blade, tip first
                (let ((s (* u (/ (i->f i) 8f0))))
                  (declare (single-float s))
                  (fx-disc (+ x0 (* s ddx)) (+ y0 (* s ddy)) (+ z0 (* s ddz)) (+ 0.05f0 (* 0.02f0 (hash01 (i->f i) seed))) 0.3f0
                           (+ seed (i->f i)) +pal-ash+ 0.95f0 :push 0.08f0)))
              (fx-disc (+ x0 (* u ddx)) (+ y0 (* u ddy)) (+ z0 (* u ddz)) 0.05f0 0.2f0 (+ seed 20f0) +pal-ember+ 0.9f0 :push 0.1f0)
              (dotimes (i (n-of 90f0 rdt))                ; flakes shed as it goes
                (let ((s (rnd-range 0f0 u)))
                  (declare (single-float s))
                  (%t-shard (+ x0 (* s ddx)) (+ y0 (* s ddy)) (+ z0 (* s ddz)) (rnd-range -0.4f0 0.4f0) (rnd-range -0.2f0 0.4f0)
                            (rnd-range -0.4f0 0.4f0) (rnd-range 0.8f0 1.3f0) (rnd-range 0.03f0 0.06f0) 0.6f0 +pal-ash+)))))))
      (when (and (<= 52 cf) (< cf 168))                   ; the garb at full
        (%ya-garb px pz (if (< cf 124) rx (- rx)) (if (< cf 124) rz (- rz))   ; (his right: from f124 he stands turned away)
                  (f-min 1f0 (* 0.34f0 (i->f (- cf 52))))   ; (from the stance's size to full in 3 f)
                  (if (< cf 56) (* 0.25f0 (i->f (- cf 52))) (if (< cf 156) 0.98f0 (* 0.98f0 (/ (i->f (- 168 cf)) 12f0))))
                  seed))
      (when (and (<= 72 cf) (< cf 124))                   ; molten footprints: where he stood every 9 f (he walks 0.029 m a frame)
        (dotimes (i 6)
          (let ((fi (+ 72 (* 9 i))))
            (declare (fixnum fi))
            (when (<= fi cf)
              (let* ((back (* 0.029f0 (i->f (- cf fi)))) (sd (if (evenp i) 0.14f0 -0.14f0))
                     (k (f-clamp (- 0.95f0 (* 0.012f0 (i->f (- cf fi)))) 0f0 0.95f0))
                     (x (+ px (* (- back) fx) (* sd rx))) (z (+ pz (* (- back) fz) (* sd rz))))
                (declare (single-float back sd k x z))
                (toon-ground-seg (- x (* 0.12f0 fx)) (- z (* 0.12f0 fz)) (+ x (* 0.12f0 fx)) (+ z (* 0.12f0 fz)) 0.014f0 0.06f0 1f0 0.4f0
                                 (+ seed (i->f i)) 0.2f0 (toon-a +pal-flame+ k)))))))
      (when (and (<= 124 cf) (< cf 134))                  ; the pass: a white-hot streak from his old side through the victim to him
        (let* ((k (* 0.98f0 (/ (i->f (- 134 cf)) 10f0))) (x0 (+ px (* 0.2f0 fx))) (z0 (+ pz (* 0.2f0 fz)))
               (x1 (+ qx (* 1.3f0 fx))) (z1 (+ qz (* 1.3f0 fz))))
          (declare (single-float k x0 z0 x1 z1))
          (fx-crescent x0 1.0f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.15f0 (* 0.5f0 (+ z0 z1)) 0.2f0 :lens 0.08f0 (+ seed 30f0) +pal-flame+ k :push 0.15f0)
          (fx-crescent x0 1.0f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.15f0 (* 0.5f0 (+ z0 z1)) 0.08f0 :lens 0.05f0 (+ seed 31f0) +pal-hit+ k :push 0.2f0)))
      (when (and (<= 130 cf) (< cf 170))                  ; the column rising off him (西's fire)
        (let* ((g (f-min 1f0 (/ (i->f (- cf 129)) 6f0))) (hc (* 3.0f0 g))
               (k (if (< cf 154) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- 170 cf)) 16f0)) 0f0 0.98f0))))
          (declare (single-float g hc k))
          (dotimes (i 10)                                 ; (thin and apart: the charred body shows between them)
            (let* ((f (i->f i)) (an (+ (* 0.6283f0 f) (* 0.3f0 (hash01 f seed)))) (c (f-cos an)) (s (f-sin an))
                   (hh (* hc (+ 0.55f0 (* 0.6f0 (flow01 f 5.5f0))))))
              (declare (single-float f an c s hh))
              (%tongue (+ qx (* 0.55f0 c)) 0.04f0 (+ qz (* 0.55f0 s)) (* -0.05f0 hh c) hh (* -0.05f0 hh s) 0.11f0 +pal-flame+ k
                       (+ f 50f0) (+ dr f) 0.06f0 :segs 6)))
          (%tring qx 0f0 qz 0.7f0 0.06f0 +pal-flame+ k (+ seed 60f0))
          (%light qx 1.5f0 qz 1f0 0.5f0 0.2f0 7f0 (* 3f0 k) 8)))
      (when (>= cf 134)                                   ; ash streaming up off the charred body, then black smoke
        (dotimes (i (n-of (if (< cf 160) 80f0 25f0) rdt))
          (%t-blob (+ qx (rnd-range -0.3f0 0.3f0)) (rnd-range 0.1f0 1.5f0) (+ qz (rnd-range -0.3f0 0.3f0)) (rnd-range -0.2f0 0.2f0)
                   (rnd-range 0.8f0 1.8f0) (rnd-range -0.2f0 0.2f0) (rnd-range 1.0f0 1.6f0) (rnd-range 0.04f0 0.08f0) -0.3f0 0.25f0 +pal-ash+))
        (when (>= cf 150)
          (dotimes (i (n-of 10f0 rdt))
            (%t-blob (+ qx (rnd-range -0.3f0 0.3f0)) 0.3f0 (+ qz (rnd-range -0.3f0 0.3f0)) 0f0 (rnd-range 0.5f0 1.0f0) 0f0
                     (rnd-range 1.4f0 2.0f0) (rnd-range 0.2f0 0.35f0) -0.3f0 0.3f0 +pal-black-smoke+))))))
  nil)

(defun yama-victim-attack (v &optional (later 0) frozen)
  "西's f10: the victim's own first attack (his kit's J, CINE-SLOW 0.3 from now), started so its hit pose lands on f40 (30 frames x 0.3 =
9 frames of clip before S); a generic flinch-in when his kit has none (§15.3.4 flag 5). Art S5 (撫斬): LATER frames of clip on and FROZEN
(speed 0) hold him there mid-swing."
  (let* ((kit (kit-of v)) (mv (kit-command-move kit :q)))
    (if (and mv (mv-clip mv))
        (cine-clip v (kit-move-clip kit (mv-clip mv)) :blend (if frozen 0 4) :speed (if frozen 0.0 (mv-clip-speed mv))
                   :time (/ (* (+ (max 0 (- (mv-s mv) 9)) later) (mv-clip-speed mv)) 60.0))
        (cine-clip v :sh-clash :blend 4 :speed (if frozen 0.0 1.0)))))

(defun yama-weapon-keep (v)
  "西's f40: keep the victim's weapon's length and blade base for the ash look (*YA-CW*)."
  (let ((w (model-weapon (model v))))
    (when w (let ((wp (find-weapon w))) (setf (aref *ya-cw* 0) (weapon-len wp) (aref *ya-cw* 1) (weapon-base wp))))))

(defun yama-weapon-ash (v)
  "西's f52: what is left of the victim's weapon falls as ash (one-shot shards along it) and the cinematic hides it (REFRESH-LOOK at
CINE-END gives it back, played, skipped or aborted)."
  (let ((m (model v)))
    (when (model-weapon m)
      (body-weapon-tip (model-body m) (model-weapon m) (model-joints m) *ya-ct*)
      (body-weapon-base (model-body m) (model-weapon m) (model-joints m) *ya-cb*)
      (let ((tp *ya-ct*) (bs *ya-cb*))
        (dotimes (i 30)
          (let ((s (rnd01)))
            (%t-shard (+ (aref tp 0) (* s (- (aref bs 0) (aref tp 0)))) (+ (aref tp 1) (* s (- (aref bs 1) (aref tp 1))))
                      (+ (aref tp 2) (* s (- (aref bs 2) (aref tp 2)))) (rnd-range -0.6f0 0.6f0) (rnd-range -0.3f0 0.6f0)
                      (rnd-range -0.6f0 0.6f0) (rnd-range 1.0f0 1.6f0) (rnd-range 0.04f0 0.08f0) 1.2f0 +pal-ash+))))
      (setf (model-weapon m) nil))))

(defun yama-nishi-walk (a v)
  "西's walk, one step (f73-123): he drags forward 0.029 m a frame, the lost victim backs away 0.026 m (each ~1.5 m over the shot); the
tracking side-on pair. Their places are given back at CINE-END (CINE-SAVE)."
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((p (pos-of a)) (q (pos-of v)))
      (setf (aref p 0) (+ px (* 0.029f0 fx)) (aref p 2) (+ pz (* 0.029f0 fz))
            (aref q 0) (+ qx (* 0.026f0 fx)) (aref q 2) (+ qz (* 0.026f0 fz)))))
  (shot-pair a v 1 (if (portrait-p) 6.4 4.6) 1.2))

(defun yama-nishi-pass (a v)
  "西's f124, the instant (§15.3.2: a hard cut between two placements, no body crossing): he stands 2 m beyond the victim, the two back
to back (each turned away from the other); CINE-END gives the places back and RESET-ROUND / the K.O. face them again."
  (face-each-other a v -2.0)
  (dolist (e (list a v)) (setf (transform-yaw (transform e)) (f32 (+ (yaw-of e) 3.1415927)))))

(defcine yama-nishi-cine (a v :len 180 :hold 140)
  "殘日獄衣 ZANJITSU GOKUI, the Bankai's 西 Kikon: the user's storyboard (2026-11-20, DUEL_YAMA_CORE §15.3.2: 「西 殘日獄衣：對手先出手，
武器碰到火衣就從刀尖化成灰。山本燃起灼熱的火衣並緩步走向不知所措的對手。最終瞬間穿過對手，使其被升騰的高溫烈焰燒成灰燼。」). Beat 0, he
stands chin up, the blade low; over the victim's shoulder in slow motion the victim strikes first and he does not move; on his chest the
weapon meets the garb and turns to ash from the tip; low in front the garb ignites under the 残日獄衣 stamp; tracking side-on he walks the
lost victim down, molten footprints behind; the instant: a white-hot streak, a hard cut, he stands beyond the victim, back to back; low in
front of him, looking past him, the flames rise off the victim, his Konpaku shatters, he chars black and the ash streams up as he falls;
wide, the old man never turns, the garb gutters out."
  (at 0 (cine-place a v 1.4)
      (cine-clip a :ya-st-nishi :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 10) (impact-frame :negative 2) (cine-grade :spot))
  (at 10 (shot-on v 145 (if (portrait-p) 3.0 2.2) 1.5 :look 1.3) (lens 60) (cine-slow 0.3)   ; (145 deg, not 160: he shows past
                                                                              ;  the victim's shoulder)
      (yama-victim-attack v) (play-sfx :sizzle :pitch 0.7 :gain 0.6))
  (at 40 (shot-on a 70 1.8 1.35 :look 1.25 :ahead 0.4) (lens 80) (silence 12) (cine-slow 0.5) (yama-weapon-keep v)   ; contact: the garb takes the blow
      (%ya-line (px pz qx qz fx fz rx rz d) a v
        (vfx-garb-block (+ px (* 0.35f0 fx)) 1.2 (+ pz (* 0.35f0 fz)) fx fz))
      (let ((h *ya-ct*)) (joint-point! h (model-joints (model v)) (ji :hand-r) 0f0 0f0 0f0) (vfx-scorch (aref h 0) (aref h 1) (aref h 2))))
  (at 44 (cine-clip v :sh-flinch :blend 2))
  (at 52 (yama-weapon-ash v) (cine-slow 1)
      (shot-on a 40 (if (portrait-p) 4.6 3.4) 0.5 :look 1.1) (lens 40) (cine-clip a :ya-e-advance :blend 4 :speed 0.0)   ; (its frame 0: the arms open)
      (play-sfx :explode :pitch 0.5) (play-sfx :awaken-rise :pitch 0.7) (shake 0.15 0.3))
  (at 56 (caption "残日獄衣" :mark "西" :reading "ZANJITSU GOKUI" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (at 72 (lens 46) (cine-clip a :ya-e-advance :blend 4) (cine-clip v :sh-stagger :blend 4 :speed 0.5) (yama-nishi-walk a v))
  (when (and step-p (< 72 cf 124)) (yama-nishi-walk a v))
  (at 80 (play-sfx :step :pitch 0.7)) (at 89 (cine-clip a :ya-e-advance :blend 4)) (at 97 (play-sfx :step :pitch 0.7))
  (at 98 (cine-clip v :sh-stagger :blend 4 :speed 0.5)) (at 106 (cine-clip a :ya-e-advance :blend 4)) (at 114 (play-sfx :step :pitch 0.7))
  (at 124 (yama-nishi-pass a v) (impact-frame :negative 2) (play-sfx :cut-heavy :pitch 1.2)
      (cine-clip a :ya-st-nishi :blend 0) (cine-clip v :sh-kikon-victim :blend 0)
      (shot-on v 0 2.6 1.4 :look 1.3) (lens 50))
  (at 130 (lens 40) (play-sfx :explode :pitch 0.7) (play-sfx :sizzle)   ; low, in front of him, looking past him at the victim
      (%ya-line (px pz qx qz fx fz rx rz d) a v
        (cine-cam (+ px (* -1.5f0 fx) (* 3.5f0 rx)) 0.4 (+ pz (* -1.5f0 fz) (* 3.5f0 rz)) (+ px (* 1.2f0 fx)) 1.1 (+ pz (* 1.2f0 fz)))))   ; (off to his
                                                                              ;  side: his garb and the column read apart)
  (at 134 (impact-frame :negative 2) (silhouette-black v) (cine-clip v :sh-crumple :blend 3)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (shake 0.4 0.4))
  (at 136 (impact-frame :manga 10))
  (at 150 (cine-clip v :sh-down :blend 10) (caption-exit))   ; (out before the wide: there he stands under its column)
  (at 160 (shot-pair a v 1 (if (portrait-p) 9.0 7.0) 1.6) (lens 44)
      (let ((p (pos-of a))) (vfx-burnout (aref p 0) (aref p 2) t)))
  (during (0 180) (yama-nishi-look a v cf)))

;;; ---------------------------------------------------------------- 南 火火十万億死大葬陣 DAISOJIN (§15.3.3, 192 f)
(defun-fast yama-minami-look (a v cf)
  "南's look at cinematic frame CF: the ember crack from where the blade went in to the victim (f50, run out in 6 f); the dead breaking
the floor round him (L1 at his feet through a stand-in hazard, then one more every 5 f to 8 bodies, §15.3.4 flag 3: YA-DEAD, cap 8);
the pile climbing over him from f96 (L5, a stand-in hazard), an arm clawing out of its crest; it bursts to ash from f140. A look; 0 B."
  (declare (fixnum cf))
  (ya-dead-reset)
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((rdt (aref *ya-rdt* 0)) (seed (+ qx (* 3f0 qz))))
      (declare (single-float rdt seed))
      (when (>= cf 50)                                    ; the crack from the blade (4.1 m short of the victim) to him
        (let* ((l (* 4.1f0 (f-min 1f0 (/ (i->f (- cf 49)) 6f0)))) (x0 (- qx (* 4.1f0 fx))) (z0 (- qz (* 4.1f0 fz)))
               (x1 (+ x0 (* l fx))) (z1 (+ z0 (* l fz))))
          (declare (single-float l x0 z0 x1 z1))
          (toon-ground-seg x0 z0 x1 z1 0.012f0 0.06f0 1f0 0.5f0 (+ seed 1f0) 0.35f0 (toon-a +pal-ink+ 0.95f0))
          (toon-ground-seg x0 z0 x1 z1 0.016f0 0.018f0 0.3f0 0.3f0 (+ seed 2f0) 0.3f0 (toon-a +pal-ember+ 0.95f0))))
      (when (and (<= 56 cf) (< cf 100))                   ; L1 at his feet: the crack star and three of the dead
        (let ((hz *ya-chz*))                              ; (its place is set at f56: YAMA-MINAMI-STAND-INS; a float slot's SETF boxes)
          (setf (hazard-age hz) (min 16 (- cf 56)))
          (yama-hands-look hz rdt)))
      (when (and (<= 61 cf) (< cf 112))                   ; one more of the dead every 5 f, clawing at his knees and sword arm
        (dotimes (j 5)
          (let ((sp (+ 61 (* 5 j))))
            (declare (fixnum sp))
            (when (<= sp cf)
              (let* ((f (i->f j)) (an (+ 0.9f0 (* 1.2566f0 f))) (c (f-cos an)) (s (f-sin an)) (r (if (evenp j) 0.55f0 0.7f0)))
                (declare (single-float f an c s r))
                (%ya-at (+ qx (* r c)) (f-min 0.3f0 (+ -0.6f0 (* 0.15f0 (i->f (- cf sp))))) (+ qz (* r s)) (f-atan2 c s))
                (ya-dead :sk-grab (min 40 (+ 8 (- cf sp)))))))))
      (when (and (<= 96 cf) (< cf 172))                   ; L5: the pile closing over him, held, bursting at f140
        (let ((hz *ya-cpz*))
          (setf (hazard-age hz) (cond ((< cf 110) (- cf 96)) ((< cf 140) 14) (t (+ 16 (floor (- cf 140) 2)))))
          (yama-pile-look hz rdt)))
      (when (and (<= 126 cf) (< cf 140))                  ; an arm last, out of the crest
        (%ya-at qx 1.0f0 qz (f-atan2 fx fz))
        (ya-dead :sk-grab (+ 8 (- cf 126))))))
  nil)

(defun yama-minami-stand-ins (v)
  "南's f0: the stand-in hazards (L1's hands, L5's pile) at the victim's feet, who does not move in this cinematic."
  (let ((q (pos-of v)))
    (dolist (hz (list *ya-chz* *ya-cpz*)) (setf (hazard-x hz) (aref q 0) (hazard-z hz) (aref q 2) (hazard-delay hz) 0 (hazard-age hz) 0))))

(defun yama-minami-walk (a v)
  "南's walk, one step (f97 on): he walks away from the victim 0.02 m a frame, his back to him (his place is given back at CINE-END)."
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((p (pos-of a))) (setf (aref p 0) (- px (* 0.02f0 fx)) (aref p 2) (- pz (* 0.02f0 fz))))))

(defcine yama-minami-cine (a v :len 192 :hold 120)
  "火火十万億死大葬陣 DAISOJIN, the Bankai's 南 Kikon (DUEL_YAMA_CORE §15.3.3, §19): beat 0, the blade upright before his face; close and
low in front, the incantation, the blade splitting his face, the two-column stamp; from high in front, the blade driven down, an ember
crack running out to the victim; at the victim on the ground the dead break the floor round him, three then eight, and take his ankles,
knees and sword arm; in front of the old man, long lens: he has turned his back and walks toward us while far behind him the pile climbs
over the victim; the Konpaku, unseen by him: the pile bursts; wide and high, the ash falls, the victim lies in the cracks, he walks on."
  (at 0 (cine-place a v 5.0) (yama-minami-stand-ins v)
      (cine-clip a :ya-kaka :blend 2 :time (/ 16.0 60.0) :speed 0.0) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (cine-grade :spot))
  (at 12 (shot-on a 15 2.2 1.0 :look 1.45 :off 0.6) (lens 50 6) (silence 38) (play-sfx :awaken-rise :pitch 0.5 :gain 0.6)
      (caption "火火十万億死" :kanji2 "大葬陣" :mark "南" :reading "DAISOJIN" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (at 48 (cine-clip a :ya-kaka :blend 0 :time (/ 19.0 60.0)))   ; lifted on f19, driven down f20-21: in the plaza on f51
  (at 50 (shot-on a 0 4.0 4.5 :look 0.0 :ahead 1.5) (lens 44))
  (at 51 (play-sfx :ground-crack) (shake 0.3 0.4)
      (%ya-line (px pz qx qz fx fz rx rz d) a v           ; the ember cracks along the line (the stage's marks, kept for the round)
        (dolist (s '(1.6 2.8 4.0)) (stage-crack-add (+ px (* s fx)) (+ pz (* s fz)) 0.9))))
  (at 60 (cine-clip a :ya-kaka :blend 2 :time (/ 30.0 60.0) :speed 0.0))   ; kneeling, the point in the plaza
  (at 56 (shot-on v 140 (if (portrait-p) 4.6 3.6) 0.3 :look 0.6) (lens 50)   ; (50: at 32 deg his back filled the frame, the dead hidden)
      (cine-clip v :sh-bound :blend 6) (play-sfx :bones))
  (at 61 (play-sfx :bones :pitch 0.9)) (at 71 (play-sfx :bones :pitch 1.1)) (at 81 (play-sfx :bones :pitch 0.8))
  (at 96 (setf (transform-yaw (transform a)) (f32 (+ (yaw-of a) 3.1415927)))   ; his back to the victim
      (cine-clip a :sh-walk-f :blend 8 :speed 0.55)
      (shot-on a 20 9.0 1.1 :look 1.2) (lens 30) (play-sfx :step :pitch 0.6))   ; (a long lens: 30 deg here, 20 deg off the line so the
                                                                                ;  pile shows beside him)
  (when (and step-p (> cf 96)) (yama-minami-walk a v))
  (at 120 (play-sfx :step :pitch 0.6)) (at 130 (play-sfx :bones :pitch 0.7))
  (at 140 (impact-frame :negative 2) (back-rim 6) (caption-exit)   ; (out before the wide: there he walks under its column)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (shake 0.35 0.4))
  (at 142 (impact-frame :manga 10))
  (at 146 (shot-pair a v 1 (if (portrait-p) 13.0 9.5) (if (portrait-p) 4.0 3.0)) (lens 44) (cine-clip v :sh-down :blend 6)
      (multiple-value-bind (x y z) (actor-point v 0.0)
        (vfx-ash-burst x y z) (vfx-ash-burst (+ x 0.5) y z) (vfx-ash-burst x y (+ z 0.5))))
  (during (0 192) (yama-minami-look a v cf)))

;;; ================================================================ art S5: the Shikai's 不知火 / 焱熱地獄 / 撫斬 Kikons (DUEL_YAMA_CORE §21.5, §26)
;;; Kept apart (§21.5): 1 = fire that comes from nowhere (he thrusts, nothing leaves the blade; lights wake round the victim, stand up as
;;; columns and close into one tornado), 2 = the cage (the fire runs down the edge into the floor, draws its circles, the pillars rise round
;;; both and close into a dome with him inside it: Q3 「照原作」, a look only, no Reishi taken), 3 = nothing happens, then it has (the cut is
;;; never shown; he turns away; the split comes late). 爆炎 plays the same three (Q2 「沿用始解的，換爆炎裝扮」): DEFCINE draws his current
;;; model (bared, the scars by heat: YAMA-DRAW), and every fire here is white-cored (T2) and x1.2 high in 爆炎 (%YA-CFORM); in the Shikai the
;;; small fires are T1 and the beats the storyboards mark T2 are T2. Full colour (no :spot grade: the Shikai is the orange form). While one
;;; runs, YAMA-DRAW leaves the blade's fire (SL0, the stance fire) to the cinematic's look (YAMA-S5-CINE-P), which draws it per beat.
;;; Same grammar as K4: AT events cut, play clips and stamp (step mode); one DURING calls one DEFUN-FAST look of the cinematic frame and the
;;; actors' places (draw mode, 0 B: debug 87449's rows; rnd01 only).
(defparameter *ya-s5-cines* '(yama-shiranui-cine yama-ennetsu-cine yama-nadegiri-cine)
  "The Shikai's (and 爆炎's) three Kikon cinematics, by pointer (art S5): YAMA-S5-CINE-P, the debug commands 87482-87487.")

(defun yama-s5-cine-p (e)
  "Is E the attacker of a running S5 cinematic (YAMA-DRAW then leaves the blade's fire to its look)? Reads only."
  (let ((c *cine*)) (and c (eql e (cine-a c)) (member (cine-name c) *ya-s5-cines*) t)))

(defmacro %ya-cform ((bl ti hs) a &body body)
  "Bind BL (A is in 爆炎), TI (the cinematic's small-fire tier: 2 in 爆炎, else 1) and HS (its fire's height factor: 1.2 in 爆炎, else 1)."
  `(let* ((,bl (eq (kit-form (fighter-kit (fighter ,a))) :blaze)) (,ti (if ,bl 2 1)) (,hs (if ,bl 1.2f0 1f0)))
     (declare (fixnum ,ti) (single-float ,hs) (ignorable ,bl ,ti ,hs))
     ,@body))

(defmacro %ya-feet ((px pz qx qz) a v &body body)
  "Bind A's and V's feet (PX PZ, QX QZ; single floats). (%YA-LINE's unit vectors left unused cost a boxed float a draw on the probe:
a look that needs only the feet binds them here.)"
  `(let* ((%p (pos-of ,a)) (%q (pos-of ,v)) (,px (aref %p 0)) (,pz (aref %p 2)) (,qx (aref %q 0)) (,qz (aref %q 2)))
     (declare (type f32vec %p %q) (single-float ,px ,pz ,qx ,qz) (ignorable ,px ,pz ,qx ,qz))
     ,@body))

(defmacro %ya-cpillar (x z lx lz r h k ti seed)
  "A cinematic column of flame (§21.5.4 row 1, §28.5: no longer a cone): from the floor at (X Z) along (LX H LZ) (its lean at the top),
base half-width R, nearly as wide at the top (0.6 R) as at the foot, as the canon's Ennetsu columns (sheet_EnnetsuJigoku 11-20 s): an
EMBER backing behind it, two FIRE masses side by side swaying out of step (the sides ragged, licking), an EMBER stripe twisting up its
front (batch 1's VFX-FIRE-PILLAR's spiral), the tier's white core (TI 1 / 2: 25 / 42 % of the width, wavering), two tongues licking off
its sides and three flaring out of its top, flowing (FLOW01 / FLOW-PH, §15.7; re-drawn on twos before). K the presence (0 .. 0.98). Single-float forms (TI fixnum); about 450
vertices; 0 B."
  `(let* ((%x ,x) (%z ,z) (%lx ,lx) (%lz ,lz) (%r ,r) (%h ,h) (%k0 ,k) (%k (%ya-k %k0)) (%ti ,ti) (%dr (flow-ph))
          (%s0 (f-abs ,seed)) (%sd (- -5f0 %s0)) (%ux (/ %lx (f-max 0.01f0 %h))) (%uz (/ %lz (f-max 0.01f0 %h)))
          (%rt (camera-right *camera*)) (%rx (aref %rt 0)) (%rz (aref %rt 2)))   ; (the camera's right on the floor: the masses side by side)
     (declare (single-float %x %z %lx %lz %r %h %k0 %k %dr %s0 %sd %ux %uz %rx %rz) (fixnum %ti) (type f32vec %rt))
     (let ((%bx %x) (%by 0f0) (%bz %z))
       (declare (single-float %bx %by %bz))
       (%away-from-eye (%bx %by %bz) 0.14f0
         (toon-ribbon (%bx %by %bz) ((* 1.04f0 %lx) (* 1.06f0 %h) (* 1.04f0 %lz)) ((* 1.2f0 %r) (* 0.8f0 %r)) :heat (0.3f0 0.15f0)
                      :seed (- %sd 20f0) :wob 0.3f0 :pal +pal-ember+ :k %k :ph %dr :sway (* 0.05f0 %h) :segs 6)))
     (dotimes (%m 2)                                     ; the two masses, a quarter of the width apart, swaying out of step
       (let* ((%o (* %r (if (= %m 0) -0.3f0 0.3f0))) (%mf (if (= %m 0) 1f0 (+ 0.82f0 (* 0.12f0 (flow01 0f0 %s0)))))
              (%ox (* %o %rx)) (%oz (* %o %rz)))
         (declare (single-float %o %mf %ox %oz))
         (toon-ribbon ((+ %x %ox) 0f0 (+ %z %oz)) ((* %lx %mf) (* %h %mf) (* %lz %mf)) ((* 0.78f0 %r) (* 0.45f0 %r)) :heat (0.3f0 0.15f0)
                      :seed (- %sd (* 7f0 (i->f %m))) :wob 0.3f0 :pal +pal-fire+ :k %k :ph (+ %dr (* 2.1f0 (i->f %m))) :sway (* 0.045f0 %h) :segs 7)))
     (let ((%sx %x) (%sy 0.1f0) (%sz %z))                ; the EMBER stripe twisting up its front
       (declare (single-float %sx %sy %sz))
       (%away-from-eye (%sx %sy %sz) -0.06f0
         (toon-ribbon (%sx %sy %sz) ((* 0.95f0 %lx) (* 0.9f0 %h) (* 0.95f0 %lz)) ((* 0.16f0 %r) (* 0.1f0 %r)) :heat (0.3f0 0.2f0)
                      :seed (- %sd 9f0) :wob 0.15f0 :pal +pal-ember+ :k %k :ph (* 2f0 %dr) :sway (* 0.09f0 %h) :segs 8)))
     (when (> %ti 0)
       (let ((%cx %x) (%cy 0f0) (%cz %z) (%cw (if (= %ti 1) 0.25f0 0.42f0)))   ; (narrower than a tongue's: a column's core is a seam, §28.5)
         (declare (single-float %cx %cy %cz %cw))
         (%away-from-eye (%cx %cy %cz) -0.1f0
           (toon-ribbon (%cx %cy %cz) ((* 0.8f0 %lx) (* 0.78f0 %h) (* 0.8f0 %lz)) ((* %cw %r) (* 0.45f0 %cw %r)) :heat (0.3f0 0.15f0)
                        :seed (- %sd 40f0) :wob 0.25f0 :pal +pal-hit+ :k %k :ph (+ %dr 1f0) :sway (* 0.035f0 %h) :segs 5))))
     (dotimes (%j 5)                                     ; two licks off the sides, three flaring out of the top (flowing: FLOW01)
       (let* ((%f (i->f %j)) (%hq (flow01 %f %s0)) (%top (>= %j 2))
              (%u (if %top 0.9f0 (+ 0.35f0 (* 0.35f0 %hq))))
              (%sd2 (if %top (* 0.55f0 (- %f 3f0)) (if (= %j 0) -1f0 1f0)))
              (%cx (+ %x (* %u %lx) (* %sd2 0.55f0 %r %rx))) (%cy (* %u %h)) (%cz (+ %z (* %u %lz) (* %sd2 0.55f0 %r %rz)))
              (%tl (* (if %top 0.2f0 0.13f0) %h (+ 0.65f0 (* 0.5f0 %hq)))))
         (declare (single-float %f %hq %u %sd2 %cx %cy %cz %tl))
         (%ya-tongue %cx %cy %cz (+ (* %tl %ux) (* %sd2 0.45f0 %tl %rx)) %tl (+ (* %tl %uz) (* %sd2 0.45f0 %tl %rz))
                     (* (if %top 0.32f0 0.22f0) %r) %ti %k0 (+ %s0 (* 31f0 %f)) (+ %dr %f) :back nil :segs 3)))))

(defmacro %ya-sight-blocks (x z e ax az)
  "Does a cinematic pillar at (X Z) stand on the camera eye E's line to an actor at (AX AZ), on the floor plane: between them (0.5 m clear
of each end) and within 0.45 m (the pillar's FIRE half-width) + 0.3 m (the actor's) scaled by its share of the distance? Pure; 0 B."
  `(let* ((%ex (aref ,e 0)) (%ez (aref ,e 2)) (%dx (- ,ax %ex)) (%dz (- ,az %ez)) (%l (f-max 0.01f0 (f-hypot %dx %dz)))
          (%vx (- ,x %ex)) (%vz (- ,z %ez)) (%al (/ (+ (* %vx %dx) (* %vz %dz)) %l)) (%lat (/ (f-abs (- (* %vx %dz) (* %vz %dx))) %l)))
     (declare (single-float %ex %ez %dx %dz %l %vx %vz %al %lat))
     (and (> %al 0.5f0) (< %al (- %l 0.5f0)) (< %lat (+ 0.45f0 (* 0.3f0 (/ %al %l)))))))

(defmacro %ya-cblade ((tip base) a &body body)
  "Bind TIP and BASE to A's drawn blade's ends (*YA-CT* / *YA-CB*: :ryujin-jakka's length / blade base, as YAMA-DRAW's) and run BODY,
when he holds a blade."
  `(let ((%m (model ,a)))
     (when (model-weapon %m)
       (joint-point! *ya-ct* (model-joints %m) (ji :weapon-r) 0f0 0f0 -0.95f0)
       (joint-point! *ya-cb* (model-joints %m) (ji :weapon-r) 0f0 0f0 -0.25f0)
       (let ((,tip *ya-ct*) (,base *ya-cb*))
         (declare (type f32vec ,tip ,base))
         ,@body))))

(defun-fast yama-s5-blade (a cf code)
  "The blade's fire in an S5 cinematic at frame CF (YAMA-DRAW leaves it to the cinematic: YAMA-S5-CINE-P), CODE 1 不知火: the rest sheath
(SL0) to f62 and from f150, and f10-62 the spiral winding down the blade from the tip to the guard, tightening (f10-40), going out on the
thrust (f58-62); CODE 2 焱熱地獄: the rest sheath throughout, and f22-34 the fire running down the edge into the floor (a white-cored
strand growing guard to point). It leaves the tip in *YA-CT* (焱熱地獄's floor line starts there). A look; 0 B."
  (declare (fixnum cf code))
  (%ya-cform (bl ti hs) a
    (let ((dr (flow-ph)))                                 ; (DR: a flowing phase, §15.7)
      (declare (single-float dr))
      (%ya-cblade (tip base) a
        (if (= code 1)
            (progn
              (when (or (< cf 62) (>= cf 150)) (yama-blade-fire tip base (if bl 10 0) ti 0f0))   ; (the rest sheath: no scraps, so no rate)
          (when (and (<= 10 cf) (< cf 62))
            (let* ((x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2))
                   (bx (- (aref tip 0) x0)) (by (- (aref tip 1) y0)) (bz (- (aref tip 2) z0))
                   (bl2 (f-max 0.01f0 (f-sqrt (+ (* bx bx) (* by by) (* bz bz))))) (ax (/ bx bl2)) (ay (/ by bl2)) (az (/ bz bl2))
                   (n1x (- az)) (n1z ax) (nl (f-max 0.01f0 (f-sqrt (+ (* n1x n1x) (* n1z n1z))))) (n1x (/ n1x nl)) (n1z (/ n1z nl))
                   (n2x (* n1z ay)) (n2y (- (* n1x az) (* n1z ax))) (n2z (- (* n1x ay)))
                   (cov (f-min 1f0 (/ (i->f (- cf 10)) 24f0))) (rr (* hs (- 0.17f0 (* 0.09f0 (f-min 1f0 (/ (i->f (- cf 10)) 30f0))))))
                   (k (if (< cf 58) 0.95f0 (* 0.95f0 (/ (i->f (- 62 cf)) 4f0)))) (spin (flow-ph 37.699112f0)))   ; (180 deg a drawing: turning smoothly)
              (declare (single-float x0 y0 z0 bx by bz bl2 ax ay az n1x n1z nl n2x n2y n2z cov rr k spin))
              (dotimes (s 2)                             ; two strands, 1.1 turns over what they cover, from the tip down
                (dotimes (i 8)
                  (let* ((w0 (* 0.125f0 (i->f i))) (w1 (+ w0 0.125f0)) (u0 (- 1f0 (* cov w0))) (u1 (- 1f0 (* cov w1)))
                         (ph (* 3.1416f0 (i->f s))) (a0 (+ spin ph (* 7f0 u0))) (a1 (+ spin ph (* 7f0 u1)))
                         (c0 (* rr (f-cos a0))) (s0 (* rr (f-sin a0))) (c1 (* rr (f-cos a1))) (s1 (* rr (f-sin a1))))
                    (declare (single-float w0 w1 u0 u1 ph a0 a1 c0 s0 c1 s1))
                    (%ya-seg (+ x0 (* u0 bx) (* c0 n1x) (* s0 n2x)) (+ y0 (* u0 by) (* s0 n2y)) (+ z0 (* u0 bz) (* c0 n1z) (* s0 n2z))
                             (+ x0 (* u1 bx) (* c1 n1x) (* s1 n2x)) (+ y0 (* u1 by) (* s1 n2y)) (+ z0 (* u1 bz) (* c1 n1z) (* s1 n2z))
                             (* 0.03f0 hs) (* 0.024f0 hs) ti k (+ 400f0 (* 9f0 (i->f s)) (i->f i)) (+ dr (i->f i)))))))))
            (progn
              (yama-blade-fire tip base (if bl 10 0) ti 0f0)
              (when (and (<= 22 cf) (< cf 34))
                (let ((u (f-min 1f0 (/ (i->f (- cf 21)) 6f0))) (x0 (aref base 0)) (y0 (aref base 1)) (z0 (aref base 2)))
                  (declare (single-float u x0 y0 z0))
                  (%ya-seg x0 y0 z0 (+ x0 (* u (- (aref tip 0) x0))) (+ y0 (* u (- (aref tip 1) y0))) (+ z0 (* u (- (aref tip 2) z0)))
                           (* 0.05f0 hs) (* 0.08f0 hs) 2 0.98f0 500f0 dr))))))))
  nil)

;;; ---------------------------------------------------------------- 1 不知火 SHIRANUI (§21.5.1, 174 f)
(defun-fast yama-shiranui-look (a v cf)
  "不知火's look at cinematic frame CF: the blade's rest fire (SL0) to f62 and from f150; f10-62 the spiral winding down the blade from the
tip to the guard and tightening (f10-40), going out on the thrust (f58-62); the nine ghost lights waking round the victim on a 4 m circle,
one every 2 f from f40 (pale flames over EMBER marks); from f64 each stands up as a column (8 f), and f76-126 they circle him faster, the
circle closing from 4 m to 0.8 m, leaning together (an EMBER ring on the floor at their radius); f124 one tornado at his spot (§28.5: one
twisting body up to 10 m, a FIRE mass behind him over an EMBER rim, six strands wound 1.3 turns up it, FIRE on the camera's side and
EMBER on the far one, gaps between the turns for the victim, tongues licking off the rim), white-cored, guttering to embers f150-166, black smoke off
the victim from f150. T2 (the storyboard's) for the columns and the tornado; x1.2 in 爆炎. The blade: YAMA-S5-BLADE. A look; 0 B."
  (declare (fixnum cf))
  (yama-s5-blade a cf 1)
  (%ya-cform (bl ti hs) a
    (%ya-feet (px pz qx qz) a v
      (let ((dr (flow-ph)) (rdt (aref *ya-rdt* 0)) (seed (+ qx (* 3f0 qz))) (e (camera-eye *camera*)))   ; (DR: flowing, §15.7)
        (declare (single-float dr rdt seed) (type f32vec e))
        (when (and (<= 40 cf) (< cf 126))                ; the nine lights, then the columns
          (let* ((rise (f-clamp (/ (i->f (- cf 64)) 8f0) 0f0 1f0)) (u (f-clamp (/ (i->f (- cf 76)) 44f0) 0f0 1f0))
                 (rad (if (< cf 120) (- 4f0 (* 3.2f0 u)) (- 0.8f0 (* 0.07f0 (i->f (- cf 120))))))
                 (spin (+ (* 0.15f0 rise) (* 1.4f0 u) (* 3.2f0 u u))) (lean (* 0.85f0 u))
                 (kc (if (< cf 122) 0.98f0 (* 0.98f0 (/ (i->f (- 126 cf)) 4f0)))))
            (declare (single-float rise u rad spin lean kc))
            (when (>= cf 76) (%tring qx 0f0 qz rad 0.06f0 +pal-ember+ (* 0.8f0 kc) (+ seed 1f0) 24))
            (dotimes (i 9)
              (when (<= (+ 40 (* 2 i)) cf)
                (let* ((fi (i->f i)) (an (+ (* 0.6981f0 fi) (* 0.3f0 (hash01 fi seed)) spin)) (c (f-cos an)) (s (f-sin an))
                       (lx (+ qx (* rad c))) (lz (+ qz (* rad s))))
                  (declare (single-float fi an c s lx lz))
                  (if (< cf 64)
                      (let ((pulse (+ 0.775f0 (* 0.175f0 (f-cos (+ (flow-ph 37.699112f0) (* 3.1415927f0 fi))))))   ; (6 Hz, smooth: §15.7)
                            (y (+ 0.35f0 (* 0.4f0 (hash01 (+ fi 3f0) seed)))))
                        (declare (single-float pulse y))
                        (%tring lx 0f0 lz 0.35f0 0.06f0 +pal-ember+ pulse (+ seed fi 2f0) 8)
                        (%ya-tongue lx (+ y (* 0.05f0 (f-sin (+ dr fi)))) lz 0f0 (* 0.8f0 (+ 0.7f0 (* 0.3f0 pulse))) 0f0 0.15f0 0
                                    (* 0.95f0 pulse) (+ 410f0 fi seed) (+ dr fi) :back nil :segs 3 :pal +pal-hit+))
                      (let* ((h (* hs rise (+ 3.2f0 (* 1.6f0 u)) (+ 0.85f0 (* 0.25f0 (flow01 fi seed)))))
                             (ws (f-max 0.2f0 (%near-cam lx lz 0.5f0 4f0))))
                        (declare (single-float h ws))
                        (%ya-cpillar lx lz (* (- lean) c) (* (- lean) s) (* 0.45f0 ws (+ 0.4f0 (* 0.6f0 rise))) (* h (+ 0.3f0 (* 0.7f0 ws))) kc 2 (+ 420f0 fi seed)))))))))
        (when (and (<= 124 cf) (< cf 166))               ; the tornado at his spot, then its embers
          (let* ((h (* 10f0 hs (f-min 1f0 (/ (i->f (- cf 123)) 6f0)))) (k (if (< cf 150) 0.98f0 (* 0.98f0 (/ (i->f (- 166 cf)) 16f0))))
                 (ex (- (aref e 0) qx)) (ez (- (aref e 2) qz)))
            (declare (single-float h k ex ez))
            (%tring qx 0f0 qz 1.3f0 0.25f0 +pal-ember+ (* 0.7f0 k) (+ seed 5f0) 24)
            (let ((bx qx) (by 0f0) (bz qz) (cx qx) (cy 0f0) (cz qz))   ; (§28.5: one twisting body, not stacked rings) its far wall: a FIRE
              (declare (single-float bx by bz cx cy cz))                ;  mass behind him over an EMBER rim, widening as it rises (his black
              (%away-from-eye (bx by bz) 1.7f0                          ;  silhouette reads on it)
                (toon-ribbon (bx by bz) (0f0 (* 1.04f0 h) 0f0) ((* 0.16f0 h) (* 0.33f0 h)) :heat (0.3f0 0.15f0) :seed (- -431f0 (f-abs seed))
                             :wob 0.35f0 :pal +pal-ember+ :k (%ya-k k) :ph (+ dr 1f0) :sway (* 0.06f0 h) :segs 8))
              (%away-from-eye (cx cy cz) 1.3f0
                (toon-ribbon (cx cy cz) (0f0 h 0f0) ((* 0.13f0 h) (* 0.28f0 h)) :heat (0.3f0 0.15f0) :seed (- -430f0 (f-abs seed))
                             :wob 0.35f0 :pal +pal-fire+ :k (%ya-k k) :ph dr :sway (* 0.06f0 h) :segs 8)))
            (dotimes (st 6)                              ; six strands wound up it (1.3 turns floor to top), the radius widening
              (dotimes (i 9)                             ; 1.0 -> 2.6 m: EMBER on the far side, FIRE T2 on the camera's (gaps between turns)
                (let* ((u0 (/ (i->f i) 9f0)) (u1 (/ (i->f (1+ i)) 9f0)) (sp (+ (flow-ph 6.6f0) (* 1.0472f0 (i->f st))))
                       (a0 (+ sp (* 8.17f0 u0))) (a1 (+ sp (* 8.17f0 u1)))
                       (r0 (* (/ h 10f0) (+ 1f0 (* 1.6f0 u0)))) (r1 (* (/ h 10f0) (+ 1f0 (* 1.6f0 u1))))
                       (ca0 (f-cos a0)) (sa0 (f-sin a0)) (ca1 (f-cos a1)) (sa1 (f-sin a1))
                       (w0 (* h (+ 0.016f0 (* 0.022f0 u0)))) (w1 (* h (+ 0.016f0 (* 0.022f0 u1))))
                       (far (< (+ (* ex (+ ca0 ca1)) (* ez (+ sa0 sa1))) 0f0)))
                  (declare (single-float u0 u1 sp a0 a1 r0 r1 ca0 sa0 ca1 sa1 w0 w1))
                  (if far
                      (%ya-seg (+ qx (* r0 ca0)) (* h u0) (+ qz (* r0 sa0)) (+ qx (* r1 ca1)) (* h u1) (+ qz (* r1 sa1))
                               (* 0.8f0 w0) (* 0.8f0 w1) 0 k (+ seed (* 12f0 (i->f st)) (i->f i)) (+ dr (i->f i)) :pal +pal-ember+)
                      (%ya-seg (+ qx (* r0 ca0)) (* h u0) (+ qz (* r0 sa0)) (+ qx (* r1 ca1)) (* h u1) (+ qz (* r1 sa1))
                               w0 w1 2 k (+ seed (* 12f0 (i->f st)) (i->f i)) (+ dr (i->f i)))))))
            (dotimes (j 6)                               ; tongues licking off its rim (flowing since §15.7)
              (let* ((fj (i->f j)) (an (+ (flow-ph 3.6f0) (* 1.0472f0 fj))) (u (+ 0.25f0 (* 0.12f0 fj))) (ra (* (/ h 10f0) (+ 1f0 (* 1.6f0 u))))
                     (c (f-cos an)) (s (f-sin an)) (tl (* h (+ 0.06f0 (* 0.06f0 (flow01 fj seed))))))
                (declare (single-float fj an u ra c s tl))
                (when (> (+ (* ex c) (* ez s)) 0f0)
                  (%ya-tongue (+ qx (* ra c)) (* h u) (+ qz (* ra s)) (* 0.6f0 tl c) tl (* 0.6f0 tl s) (* 0.04f0 h) 2 k (+ 440f0 fj seed) (+ dr fj)
                              :back nil :segs 3))))
            (%light qx 2f0 qz 1f0 0.45f0 0.12f0 7f0 (* 1.2f0 k) 8)))
        (when (>= cf 150)                                ; embers rising, then black smoke off the victim
          (dotimes (i (n-of (if (< cf 166) 70f0 20f0) rdt))
            (let ((an (rnd-range 0f0 6.2832f0)) (r (rnd-range 0.3f0 1.6f0)))
              (declare (single-float an r))
              (%t-blob (+ qx (* r (f-cos an))) (rnd-range 0.1f0 2.5f0) (+ qz (* r (f-sin an))) (rnd-range -0.2f0 0.2f0) (rnd-range 0.6f0 1.4f0)
                       (rnd-range -0.2f0 0.2f0) (rnd-range 0.8f0 1.4f0) (rnd-range 0.03f0 0.06f0) -0.4f0 0.3f0 +pal-fire+)))
          (dotimes (i (n-of 10f0 rdt))
            (%t-blob (+ qx (rnd-range -0.3f0 0.3f0)) 0.3f0 (+ qz (rnd-range -0.3f0 0.3f0)) 0f0 (rnd-range 0.5f0 1.0f0) 0f0
                     (rnd-range 1.4f0 2.0f0) (rnd-range 0.2f0 0.35f0) -0.3f0 0.3f0 +pal-black-smoke+))))))
  nil)

(defcine yama-shiranui-cine (a v :len 174 :hold 100)
  "不知火 SHIRANUI, the Shikai's pointer 1 Kikon (DUEL_YAMA_CORE §21.5.1, §26): beat 0 in stance 1's coil; on him, the spiral winds down
the blade under the 不知火 stamp in silence; from high behind the victim, pale lights wink on round him, one every 2 f, nine; side-on, slowed,
the level thrust, and nothing leaves the blade: far off the nine lights stand up as columns; from above the victim the columns circle him,
faster, closing in; on him the wall arrives and his Konpaku shatters; low, looking up, one tornado ten metres tall, the victim black inside
it; behind the old man, the tornado gutters, he lowers the blade, the victim down and smoking."
  (at 0 (cine-place a v 6.0)
      (cine-clip a :ya-shiranui :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 10) (impact-frame :negative 2) (play-sfx :whoosh-heavy :pitch 0.8))
  (at 10 (shot-on a 60 (if (portrait-p) 2.6 1.8) 0.9 :look 1.1 :off 0.6) (lens 50 5) (silence 30)   ; (portrait 2.6 m: the blade in the frame)
      (caption "不知火" :reading "SHIRANUI" :sub "RYUJIN JAKKA" :side 0 :hanko t))
  (at 40 (shot-on v 180 (if (portrait-p) 9.0 7.0) 4.5 :look 0.4) (lens 44))
  (when (and step-p (<= 40 cf 56) (evenp cf)) (play-sfx :hs-tip :pitch (+ 1.5 (* 0.02 cf)) :gain 0.3))   ; a soft tick a light
  (at 58 (shot-pair a v 1 (if (portrait-p) 12.0 9.0) 1.2) (lens 46) (cine-slow 0.4)
      (cine-clip a :ya-n1a :blend 0 :time (/ 18.0 60.0)))   ; (NS1a's release: its S20 lands on f63 at x0.4)
  (at 63 (play-sfx :cut-heavy :pitch 1.6 :gain 0.6))      ; one dry crack, and nothing leaves the blade
  (at 66 (play-sfx :awaken-rise :pitch 0.6 :gain 0.8))    ; the roar starts, far away
  (at 76 (cine-slow 1) (shot-on v 0 2.0 (if (portrait-p) 12.0 10.0) :look 0.0) (lens 40) (shake 0.1 0.4))
  (at 90 (shake 0.2 0.4)) (at 102 (shake 0.3 0.4)) (at 112 (shake 0.4 0.4))
  (at 120 (shot-on v 0 3.2 0.5 :look 1.0) (lens 36))
  (at 122 (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 0.0 14 0.08) (play-sfx :konpaku-shatter) (shake 0.3 0.4))
  (at 124 (impact-frame :manga 10) (play-sfx :explode :pitch 0.5))
  (at 126 (shot-on v 30 5.0 0.3 :look 3.0) (lens 60) (silhouette-black v) (cine-clip v :sh-crumple :blend 3) (play-sfx :sizzle))
  (at 150 (shot-on a 160 (if (portrait-p) 5.0 3.5) 1.6 :look 1.3) (lens 44) (caption-exit)
      (cine-clip v :sh-down :blend 10) (cine-clip a :ya-stance :blend 14))
  (during (0 174) (yama-shiranui-look a v cf)))

;;; ---------------------------------------------------------------- 2 城郭炎上 → 焱熱地獄 ENNETSU JIGOKU (§21.5.2, Q3 「照原作」, 186 f)
(defun-fast yama-ennetsu-cine-look (a v cf)
  "焱熱地獄's look at cinematic frame CF, round M (the midpoint of the two, 1.5 m from each): the blade's rest fire (SL0) throughout, and
f22-30 the fire running down the edge into the floor (a white-cored strand growing guard to point); the floor pattern (A ch. 393: \"branches
in circle patterns\"; drawn in the look, no stage marks): an EMBER line from the point to M (f30-36), 8 spokes out from M to 6 m (f34-46) and
rings at 2 / 4 / 6 m growing both ways from each spoke (f38-58), enclosing both; f60 twelve marks on the 4 m ring ignite (small flames);
f66-102 a pillar rises from each, one every 3 f, to 6 m in 6 f, leaning in from f96; f110-118 they join into one squat dome (r 5 m, 4 m
high, 20 walls leaning in, INK on the far side, dark gaps), held to f160 with white fire round the victim (f130-136) and round him, his hem
alight (f136-160); f160-172 the dome falls outward to a scorched ring; ash, black smoke off the victim from f150. x1.2 in 爆炎. The blade:
YAMA-S5-BLADE. A look; 0 B."
  (declare (fixnum cf))
  (yama-s5-blade a cf 2)
  (%ya-cform (bl ti hs) a
    (%ya-feet (px pz qx qz) a v
      (let* ((dr (flow-ph)) (rdt (aref *ya-rdt* 0)) (mx (* 0.5f0 (+ px qx)))   ; (DR: flowing, §15.7)
             (mz (* 0.5f0 (+ pz qz))) (seed (+ (* 3f0 mx) mz))
             (e (camera-eye *camera*)) (kp (if (< cf 160) 0.95f0 (f-clamp (* 0.95f0 (/ (i->f (- 186 cf)) 26f0)) 0f0 0.95f0)))
             (th0 (f-atan2 (- qz pz) (- qx px))))       ; (§28.5: the pattern and the marks turn with the pair's line, so the side-on shot
        (declare (single-float dr rdt mx mz seed kp th0) (type f32vec e))   ;  looks through the gap between two pillars at each of them)
        (when (and (<= 30 cf) (< cf 186))                ; the floor pattern: the line from the point (*YA-CT*: YAMA-S5-BLADE's) to M
          (let* ((tx (aref *ya-ct* 0)) (tz (aref *ya-ct* 2)) (u (f-min 1f0 (/ (i->f (- cf 29)) 6f0))))
            (declare (single-float tx tz u))
            (toon-ground-seg tx tz (+ tx (* u (- mx tx))) (+ tz (* u (- mz tz))) 0.012f0 0.05f0 1f0 0.5f0 (+ seed 1f0) 0.2f0
                             (toon-a +pal-ember+ kp))))
        (when (and (<= 34 cf) (< cf 186))                ; the spokes and the rings
          (let ((us (f-min 1f0 (/ (i->f (- cf 33)) 12f0))))
            (declare (single-float us))
            (dotimes (j 8)
              (let* ((th (+ th0 (* 0.7854f0 (i->f j)))) (c (f-cos th)) (s (f-sin th)))
                (declare (single-float th c s))
                (toon-ground-seg mx mz (+ mx (* 6f0 us c)) (+ mz (* 6f0 us s)) 0.012f0 0.045f0 1f0 0.4f0 (+ seed 2f0 (i->f j)) 0.2f0
                                 (toon-a +pal-ember+ kp))
                (dotimes (ri 3)                          ; each ring's arc grows both ways from the spoke (2 strips a side)
                  (let* ((rr (* 2f0 (i->f (1+ ri)))) (p (f-clamp (/ (i->f (- cf (+ 38 (* 4 ri)))) 12f0) 0f0 1f0)))
                    (declare (single-float rr p))
                    (when (and (> p 0f0) (>= (* 6f0 us) rr))
                      (dotimes (q 4)
                        (let* ((sd (if (< q 2) 1f0 -1f0)) (qq (i->f (mod q 2)))
                               (b0 (+ th (* sd 0.3927f0 p (* 0.5f0 qq)))) (b1 (+ th (* sd 0.3927f0 p (* 0.5f0 (+ qq 1f0))))))
                          (declare (single-float sd qq b0 b1))
                          (toon-ground-seg (+ mx (* rr (f-cos b0))) (+ mz (* rr (f-sin b0))) (+ mx (* rr (f-cos b1))) (+ mz (* rr (f-sin b1)))
                                           0.012f0 0.045f0 1f0 0.6f0 (+ seed 10f0 (* 4f0 (i->f j)) (i->f q) (* 40f0 rr)) 0.2f0
                                           (toon-a +pal-ember+ kp)))))))))))
        (when (and (<= 60 cf) (< cf 118))                ; the twelve marks on the 4 m ring, then the pillars
          (let ((lean (* 1.5f0 (f-clamp (/ (i->f (- cf 96)) 12f0) 0f0 1f0)))
                (kj (if (< cf 110) 0.98f0 (* 0.98f0 (/ (i->f (- 118 cf)) 8f0)))))
            (declare (single-float lean kj))
            (dotimes (i 12)
              (let* ((fi (i->f i)) (an (+ th0 0.2618f0 (* 0.5236f0 fi))) (c (f-cos an)) (s (f-sin an)) (x (+ mx (* 4f0 c))) (z (+ mz (* 4f0 s)))
                     (g (f-clamp (/ (i->f (- cf (+ 66 (* 3 i)))) 6f0) 0f0 1f0)))   ; (full pillars all round: 15 deg either side of the line's
                (declare (single-float fi an c s x z g))                        ;  normal, the two nearest the lens frame the pair, §28.5)
                (unless (or (%ya-sight-blocks x z e px pz) (%ya-sight-blocks x z e qx qz))   ; (a pillar on the lens's line to either actor is
                  (if (<= g 0f0)                                                          ;  left out: the portrait side shot, §28.5)
                      (%ya-tongue x 0.02f0 z 0f0 (* 0.5f0 hs) 0f0 0.1f0 ti 0.95f0 (+ 510f0 fi seed) (+ dr fi) :back nil :segs 3)
                      (%ya-cpillar x z (* (- lean) c) (* (- lean) s) 0.4f0 (* 6f0 hs g) kj ti (+ 520f0 fi seed))))))))
        (when (and (<= 110 cf) (< cf 172))               ; the dome: closed f110-118, held, falling outward f160-172
          (let* ((g (f-min 1f0 (/ (i->f (- cf 109)) 8f0))) (fall (f-clamp (/ (i->f (- cf 160)) 12f0) 0f0 1f0))
                 (k (if (< cf 160) 0.98f0 (* 0.98f0 (- 1f0 fall)))) (h (* 4f0 hs (+ 0.5f0 (* 0.5f0 g)) (- 1f0 (* 0.8f0 fall))))
                 (lean (* 4.2f0 (- (* 0.95f0 g) (* 1.3f0 fall)))) (ex (- (aref e 0) mx)) (ez (- (aref e 2) mz))
                 (inside (< (f-hypot ex ez) 5f0)))
            (declare (single-float g fall k h lean ex ez))
            (dotimes (i 20)
              (let* ((fi (i->f i)) (an (+ (* 0.31416f0 fi) (* 0.1f0 (hash01 fi seed)))) (c (f-cos an)) (s (f-sin an))
                     (bx (+ mx (* 5f0 c))) (bz (+ mz (* 5f0 s))) (far (< (+ (* ex c) (* ez s)) 0f0))
                     (hh (* h (+ 0.85f0 (* 0.25f0 (flow01 fi seed))))) (wd 0.62f0))
                (declare (single-float fi an c s bx bz hh wd))
                (when (and far (not inside))
                  (let ((kx bx) (ky 0f0) (kz bz))
                    (declare (single-float kx ky kz))
                    (%away-from-eye (kx ky kz) 0.15f0
                      (toon-ribbon (kx ky kz) ((* -1.05f0 lean c) (* 1.05f0 hh) (* -1.05f0 lean s)) ((* 1.3f0 wd) 0f0) :heat (0.3f0 0.12f0)
                                   :seed (- -530f0 fi (f-abs seed)) :wob 0.3f0 :pal +pal-ink+ :k (%ya-k k) :ph (+ dr fi) :sway 0.04f0 :segs 4))))
                (%ya-tongue bx 0.02f0 bz (* (- lean) c) hh (* (- lean) s) wd 2 k (+ 540f0 fi seed) (+ dr fi) :back nil)))
            (%light mx 2f0 mz 1f0 0.45f0 0.12f0 8f0 (* 1.2f0 k) 8)))
        (when (and (<= 128 cf) (< cf 160))               ; inside: white fire round the victim, then round him, his hem alight
          (let* ((on-v (< cf 136)) (cx (if on-v qx px)) (cz (if on-v qz pz)) (k (if (< cf 154) 0.98f0 (* 0.98f0 (/ (i->f (- 160 cf)) 6f0)))))
            (declare (single-float cx cz k))
            (dotimes (i 10)
              (let* ((fi (i->f i)) (an (+ (* 0.6283f0 fi) (* 0.4f0 (flow01 fi seed)))) (r (+ 1.2f0 (* 0.8f0 (hash01 fi seed))))
                     (x (+ cx (* r (f-cos an)))) (z (+ cz (* r (f-sin an)))) (hh (* hs (+ 1.4f0 (* 0.9f0 (flow01 (+ fi 7f0) seed))))))
                (declare (single-float fi an r x z hh))
                (%ya-tongue x 0.02f0 z (* -0.15f0 hh (f-cos an)) hh (* -0.15f0 hh (f-sin an)) 0.22f0 2 k (+ 560f0 fi seed) (+ dr fi) :back nil)))
            (unless on-v                                 ; his hem alight (爆炎: the hakama's hem, bared to the waist)
              (let ((hy (if bl 0.12f0 0.55f0)) (hr (if bl 0.26f0 0.34f0)))
                (declare (single-float hy hr))
                (dotimes (i 7)
                  (let* ((fi (i->f i)) (an (+ (* 0.8976f0 fi) (* 0.3f0 (flow01 fi seed)))))
                    (declare (single-float fi an))
                    (%ya-tongue (+ px (* hr (f-cos an))) hy (+ pz (* hr (f-sin an))) 0f0 (* 0.24f0 (+ 0.7f0 (* 0.3f0 (flow01 fi 2.1f0)))) 0f0
                                0.05f0 ti k (+ 580f0 fi seed) (+ dr fi) :back nil :segs 3)))))))
        (when (>= cf 160)                                ; the scorched ring, ash, black smoke
          (%tring mx 0f0 mz 5f0 0.3f0 +pal-ember+ (* 0.8f0 kp) (+ seed 7f0) 40))
        (when (>= cf 150)
          (dotimes (i (n-of (if (< cf 176) 40f0 15f0) rdt))
            (let ((an (rnd-range 0f0 6.2832f0)))
              (declare (single-float an))
              (%t-blob (+ mx (* 5f0 (f-cos an))) (rnd-range 0.2f0 2.0f0) (+ mz (* 5f0 (f-sin an))) (rnd-range -0.3f0 0.3f0) (rnd-range 0.5f0 1.2f0)
                       (rnd-range -0.3f0 0.3f0) (rnd-range 1.0f0 1.6f0) (rnd-range 0.04f0 0.08f0) -0.3f0 0.25f0 +pal-ash+)))
          (dotimes (i (n-of 10f0 rdt))
            (%t-blob (+ qx (rnd-range -0.3f0 0.3f0)) 0.3f0 (+ qz (rnd-range -0.3f0 0.3f0)) 0f0 (rnd-range 0.5f0 1.0f0) 0f0
                     (rnd-range 1.4f0 2.0f0) (rnd-range 0.2f0 0.35f0) -0.3f0 0.3f0 +pal-black-smoke+))))))
  nil)

(defcine yama-ennetsu-cine (a v :len 186 :hold 120)
  "焱熱地獄 ENNETSU JIGOKU, the Shikai's pointer 2 Kikon (DUEL_YAMA_CORE §21.5.2, Q3 「照原作」, §26): beat 0 in stance 2's point; low on the
sword hand, he turns the blade point-down into the plaza and the fire runs down the edge into the ground, under the 焱熱地獄 stamp; from
above, ember lines run out over the floor and branch into circles round both, twelve marks on the 4 m ring ignite; side-on and low, twelve
pillars rise behind both, one every 3 f, and lean in, the victim looking for a way out, he does not move; far outside, the pillars join into
one squat dome over both, silence, a low boom; inside, on the victim, white fire from every side, his Konpaku shatters; inside, on the old
man, a dark shape standing in the flames, the blade still down, his hem alight (a look: no Reishi is taken); wide, the dome falls outward to
a scorched ring, the victim down and smoking, he points the blade at where it stood."
  (at 0 (cine-place a v 3.0)
      (cine-clip a :ya-st-enjo :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 10) (impact-frame :negative 2) (play-sfx :whoosh-heavy :pitch 0.8))
  (at 10 (shot-on a 30 2.0 0.5 :look 0.8 :off 0.5) (lens 50) (silence 20)
      (cine-clip a :ya-blaze-in :blend 3 :speed 0.6)      ; (爆炎's entry clip: the point lowered into the plaza at his right)
      (caption "焱熱地獄" :reading "ENNETSU JIGOKU" :sub "JOKAKU ENJO" :side 0 :hanko t))
  (at 24 (cine-clip a :ya-blaze-in :blend 0 :time (/ 10.0 60.0) :speed 0.0))   ; (held with the point in the plaza)
  (at 30 (play-sfx :sizzle :pitch 0.8))
  (at 34 (shot-on a 0 2.0 (if (portrait-p) 13.0 10.0) :look 0.0 :ahead 1.5) (lens 44))
  (at 60 (play-sfx :explode :pitch 0.4 :gain 0.6))
  (at 66 (shot-pair a v 1 (if (portrait-p) 7.5 5.5) 0.6) (lens 46) (cine-clip v :sh-stagger :blend 4 :speed 0.5)
      (play-sfx :awaken-rise :pitch 0.7) (shake 0.2 0.6))
  (at 96 (play-sfx :explode :pitch 0.6 :gain 0.7) (shake 0.2 0.4))
  (at 110 (shot-pair a v 1 (if (portrait-p) 15.0 12.0) 2.5) (lens 40) (silence 12))
  (at 122 (play-sfx :awaken-boom :pitch 0.6) (shake 0.3 0.5))
  (at 130 (shot-on v 0 2.6 1.4 :look 1.2) (lens 50))
  (at 132 (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 0.0 14 0.08) (cine-clip v :sh-crumple :blend 3) (play-sfx :konpaku-shatter) (shake 0.4 0.4))
  (at 134 (impact-frame :manga 10))
  (at 136 (shot-on a 15 2.4 1.3 :look 1.2) (lens 44 -4) (silhouette-black a) (play-sfx :sizzle :pitch 0.6))
  (at 150 (cine-clip v :sh-down :blend 10))
  (at 160 (unsilhouette) (shot-pair a v 1 (if (portrait-p) 12.0 9.0) 2.0) (lens 44) (caption-exit)
      (cine-clip a :ya-st-enjo :blend 10) (play-sfx :explode :pitch 0.5))
  (during (0 186) (yama-ennetsu-cine-look a v cf)))

;;; ---------------------------------------------------------------- 3 撫斬 NADEGIRI (§21.5.3, 156 f)
(defun-fast yama-nadegiri-cine-look (a v cf)
  "撫斬's look at cinematic frame CF (re-timed §28.5): no fire on the blade at all; f40-41 the cut, never shown: one INK hairline across
the whole frame at the victim's neck; f84-122 a white seam down the victim (crown to floor in 4 f, over his black silhouette: the model is
never cut); f92-144 fire bursts from it and parts left and right (a V of 12 walls a side along the line, tallest at him, 3 m), an INK and
EMBER scorch line running away behind him along the floor (8 m in 10 f, held); embers to the end. T2 in both forms (the storyboard's); x1.2 in 爆炎. A
look; 0 B."
  (declare (fixnum cf))
  (%ya-cform (bl ti hs) a
    (%ya-line (px pz qx qz fx fz rx rz d) a v
      (let ((dr (flow-ph)) (rdt (aref *ya-rdt* 0)) (seed (+ qx (* 3f0 qz))))   ; (DR: flowing, §15.7)
        (declare (single-float dr rdt seed))
        (when (<= 40 cf 41)                              ; the hairline across the frame, at the victim's neck
          (let ((cx (- qx (* 0.3f0 fx))) (cz (- qz (* 0.3f0 fz))))
            (declare (single-float cx cz))
            (fx-crescent (+ cx (* -6f0 rx)) 1.45f0 (+ cz (* -6f0 rz)) (+ cx (* 6f0 rx)) 1.45f0 (+ cz (* 6f0 rz))
                         (+ cx (* 0.8f0 fx)) 1.5f0 (+ cz (* 0.8f0 fz)) 0.025f0 :lens 0.02f0 (+ 600f0 seed) +pal-ink+ 0.98f0 :push 0.3f0)))
        (when (and (<= 84 cf) (< cf 122))                ; the white seam down him
          (let* ((u (f-min 1f0 (/ (i->f (- cf 83)) 4f0))) (k (if (< cf 114) 0.98f0 (* 0.98f0 (/ (i->f (- 122 cf)) 8f0))))
                 (sx qx) (sy 1.9f0) (sz qz))
            (declare (single-float u k sx sy sz))
            (%away-from-eye (sx sy sz) -0.4f0
              (toon-ribbon (sx sy sz) (0f0 (* -1.9f0 u) 0f0) (0.04f0 0.08f0) :heat (0.6f0 0.3f0) :seed (- -610f0 (f-abs seed)) :wob 0.15f0
                           :pal +pal-hit+ :k k :ph dr :sway 0.01f0 :segs 4))))
        (when (and (<= 92 cf) (< cf 144))                ; the V of fire along the line through him, and the scorch line
          (let* ((g (f-min 1f0 (/ (i->f (- cf 91)) 4f0))) (k (if (< cf 132) 0.98f0 (* 0.98f0 (/ (i->f (- 144 cf)) 12f0))))
                 (sl (* 8f0 (f-min 1f0 (/ (i->f (- cf 91)) 10f0)))))
            (declare (single-float g k sl))
            (dotimes (j 24)                              ; 12 a side, from 0.6 m before him to 6 m behind him
              (let* ((sd (if (< j 12) -1f0 1f0)) (i (i->f (mod j 12))) (s (+ -0.6f0 (* 6.6f0 (/ (+ i 0.5f0) 12f0))))
                     (x0 (+ qx (* s fx))) (z0 (+ qz (* s fz))) (off (* sd (+ 0.08f0 (* 0.45f0 g (f-min 1f0 (+ 0.3f0 (* 0.3f0 (f-abs s))))))))
                     (x (+ x0 (* off rx))) (z (+ z0 (* off rz))) (nq (f-max 0.15f0 (%near-cam x z 0.8f0 3.5f0)))
                     (hh (* hs g nq (- 3f0 (* 0.32f0 (f-abs s))) (+ 0.8f0 (* 0.3f0 (flow01 (+ i (* 12f0 sd)) seed))))))
                (declare (single-float sd i s x0 z0 off x z nq hh))
                (%ya-tongue x 0.02f0 z (* sd 0.4f0 hh rx) hh (* sd 0.4f0 hh rz) (* 0.18f0 nq) 2 k (+ 620f0 i (* 12f0 sd) seed) (+ dr i) :back nil)))
            (toon-ground-seg qx qz (+ qx (* sl fx)) (+ qz (* sl fz)) 0.012f0 0.07f0 1f0 0.6f0 (+ seed 3f0) 0.15f0 (toon-a +pal-ink+ 0.95f0))
            (toon-ground-seg qx qz (+ qx (* sl fx)) (+ qz (* sl fz)) 0.014f0 0.025f0 1f0 0.6f0 (+ seed 4f0) 0.1f0 (toon-a +pal-ember+ k))
            (%light qx 1f0 qz 1f0 0.45f0 0.12f0 4f0 (* 0.9f0 k) 7)))
        (when (>= cf 144)                                ; the scorch line kept, embers
          (toon-ground-seg qx qz (+ qx (* 8f0 fx)) (+ qz (* 8f0 fz)) 0.012f0 0.07f0 1f0 0.6f0 (+ seed 3f0) 0.15f0 (toon-a +pal-ink+ 0.95f0)))
        (when (>= cf 96)
          (dotimes (i (n-of (if (< cf 144) 50f0 15f0) rdt))
            (let ((s (rnd-range 0f0 6f0)))
              (declare (single-float s))
              (%t-blob (+ qx (* s fx) (rnd-range -0.5f0 0.5f0)) (rnd-range 0.1f0 1.5f0) (+ qz (* s fz) (rnd-range -0.5f0 0.5f0))
                       (rnd-range -0.2f0 0.2f0) (rnd-range 0.6f0 1.4f0) (rnd-range -0.2f0 0.2f0) (rnd-range 0.8f0 1.4f0) (rnd-range 0.03f0 0.06f0)
                       -0.4f0 0.3f0 +pal-fire+)))))))
  nil)

(defun yama-turn-back (a)
  "撫斬's f56: he turns his back on the victim (yaw + 180, as 南's turn; CINE-END / RESET-ROUND face them again)."
  (setf (transform-yaw (transform a)) (f32 (+ (yaw-of a) 3.1415927))))

(defcine yama-nadegiri-cine (a v :len 156 :hold 64)
  "撫斬 NADEGIRI, the Shikai's pointer 3 Kikon (DUEL_YAMA_CORE §21.5.3, §26; A ch. 338; re-timed §28.5, the length kept): beat 0 in
NADEGIRI's draw, the blade at his left hip; on his face, a long lens, eyes shut, nothing moves, the 撫斬 stamp in silence; over his shoulder,
slowed, the victim, unharmed, starts his own attack; the cut, never shown: one hairline across the frame, and his arm is already out;
side-on, the victim frozen mid-swing, the old man turns his back and lowers the blade; on the victim, a white seam opens down him, his
Konpaku shatters; low behind the victim, the fire bursts from the seam and parts in a V, a scorch line runs past us, he crumples and falls;
wide, the old man has not looked back while the V gutters."
  (at 0 (cine-place a v 2.0)
      (cine-clip a :ya-nadegiri :blend 2 :time (/ 9.0 60.0) :speed 0.0) (cine-clip v :sh-kikon-victim :blend 4)
      (face-beat a :neutral 2.6)                          ; (eyes shut, calm: never the cinematic attacker's shout)
      (hold-both a v 12) (impact-frame :negative 2))
  (at 12 (shot-on a 35 (if (portrait-p) 3.0 2.2) 1.35 :look 1.3 :off 0.25) (lens 20) (silence 16)   ; (35 deg, not 10: at 10 the victim, 2 m ahead,
                                                                                ;  stood in front of the lens; 16 f, was 28: §28.5)
      (caption "撫斬" :reading "NADEGIRI" :sub "RYUJIN JAKKA" :side 0 :hanko t))
  (at 28 (shot-on a 200 2.4 1.5 :look 1.3 :ahead 1.6) (lens 50) (cine-slow 0.3) (yama-victim-attack v))
  (at 40 (cine-slow 1) (impact-frame :negative 2) (play-sfx :hs-tip :pitch 1.8 :gain 0.5)
      (yama-victim-attack v 4 t))                         ; (frozen mid-swing: 12 frames x 0.3 of his clip after its start)
  (at 41 (cine-clip a :ya-b-n3c :blend 0 :time (/ 16.0 60.0) :speed 0.0))   ; (the arm already out: the cut's S+2)
  (at 44 (shot-pair a v 1 (if (portrait-p) 6.0 4.2) 1.2) (lens 46) (yama-turn-back a)
      (cine-clip a :ya-b-n3c :blend 6 :time (/ 19.0 60.0) :speed 1.0))   ; (the true NADEGIRI's 40 f lowering at x1: 40 f, was 54 at x0.74)
  (at 84 (shot-on v 35 2.6 1.4 :look 1.2) (lens 50) (silhouette-black v))
  (at 86 (impact-frame :negative 2) (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 0.0 14 0.08) (play-sfx :konpaku-shatter) (shake 0.2 0.3))
  (at 88 (impact-frame :manga 10))
  (at 92 (shot-on v 155 3.6 0.4 :look 1.0 :ahead 1.0) (lens 40) (cine-clip v :sh-crumple :blend 3) (play-sfx :sizzle))   ; (155 deg,
                                                                                ;  not 180: on the line the victim hid him)
  (at 96 (play-sfx :explode :pitch 0.6) (shake 0.3 0.4))   ; (the boom 4 f late)
  (at 106 (cine-clip v :sh-down :blend 10))
  (at 128 (shot-pair a v 1 (if (portrait-p) 9.0 7.0) 1.6) (lens 44) (caption-exit))
  (during (0 156) (yama-nadegiri-cine-look a v cf)))
