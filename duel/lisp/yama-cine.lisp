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
floor shot from above) opens from where the tip touched, 1.86 m ahead of him (NS1c's tip by FK), through the victim's spot: 0.8 m wide at
the tip to 5 m at 12 m, in 10 f from f84; an ember hairline on its sides and its near end (heat 0.3, the ember's red body, as L6); ash
falling into it to the end. A look; 0 B."
  (declare (fixnum cf))
  (when (>= cf 84)
    (%ya-line (px pz qx qz fx fz rx rz d) a v
      (let* ((tx (+ px (* 1.86f0 fx))) (tz (+ pz (* 1.86f0 fz))) (u (f-min 1f0 (/ (i->f (- cf 84)) 10f0))) (l (* 12f0 u))
             (w0 0.4f0) (w1 (+ 0.4f0 (* 2.1f0 u))) (ex (+ tx (* l fx))) (ez (+ tz (* l fz)))
             (pk (toon-a +pal-ink+ 0.98f0)) (ek (toon-a +pal-ember+ 0.98f0)) (rdt (aref *ya-rdt* 0)))
        (declare (single-float tx tz u l w0 w1 ex ez pk ek rdt))
        (when (> l 0.05f0)
          (with-fx-verts (dd o :toon 6)                   ; the wedge: field across it (both long edges inked), heat 1
            (vtx (- tx (* w0 rx)) 0.012f0 (- tz (* w0 rz)) -1f0 0f0 1f0 -78f0 0.05f0 pk)
            (vtx (+ tx (* w0 rx)) 0.012f0 (+ tz (* w0 rz)) 1f0 0f0 1f0 -78f0 0.05f0 pk)
            (vtx (+ ex (* w1 rx)) 0.012f0 (+ ez (* w1 rz)) 1f0 0f0 1f0 -78f0 0.05f0 pk)
            (vtx (- tx (* w0 rx)) 0.012f0 (- tz (* w0 rz)) -1f0 0f0 1f0 -78f0 0.05f0 pk)
            (vtx (+ ex (* w1 rx)) 0.012f0 (+ ez (* w1 rz)) 1f0 0f0 1f0 -78f0 0.05f0 pk)
            (vtx (- ex (* w1 rx)) 0.012f0 (- ez (* w1 rz)) -1f0 0f0 1f0 -78f0 0.05f0 pk))
          (toon-ground-seg (+ tx (* w0 rx)) (+ tz (* w0 rz)) (+ ex (* w1 rx)) (+ ez (* w1 rz)) 0.016f0 0.025f0 0.3f0 0.3f0 81f0 0.05f0 ek)
          (toon-ground-seg (- tx (* w0 rx)) (- tz (* w0 rz)) (- ex (* w1 rx)) (- ez (* w1 rz)) 0.016f0 0.025f0 0.3f0 0.3f0 82f0 0.05f0 ek)
          (toon-ground-seg (- tx (* w0 rx)) (- tz (* w0 rz)) (+ tx (* w0 rx)) (+ tz (* w0 rz)) 0.016f0 0.025f0 0.3f0 0.3f0 83f0 0.05f0 ek)
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
(defmacro %ya-garb (x z rx rz h k seed)
  "西's garb at full (§15.3.2, L8's parts round his body): 10 thin orange tongues from his feet up to about H, leaning out (his body shows
between them), two shoulder wings of three flame
ribbons ~1.2 m out (RX RZ his right), the molten ring at his soles with a white-hot core, an orange light. Single-float forms; 0 B."
  `(let* ((%dr (drawing-no)) (%k ,k) (%h ,h))
     (declare (single-float %dr %k %h))
     (dotimes (%i 10)
       (let* ((%f (i->f %i)) (%a (+ (* 0.6283f0 %f) (* 0.3f0 (hash01 %f ,seed)))) (%c (f-cos %a)) (%s (f-sin %a))
              (%hh (* %h (+ 0.65f0 (* 0.55f0 (hash01 (+ %f %dr) ,seed))))))
         (declare (single-float %f %a %c %s %hh))
         (%tongue (+ ,x (* 0.36f0 %c)) 0.04f0 (+ ,z (* 0.36f0 %s)) (* 0.22f0 %hh %c) %hh (* 0.22f0 %hh %s) 0.1f0 +pal-flame+ %k
                  (+ ,seed %f %dr) (+ %dr %f) 0.04f0 :segs 5)))
     (%tring ,x 0f0 ,z 0.6f0 0.07f0 +pal-flame+ %k (+ ,seed 3f0))
     (%tring ,x 0.008f0 ,z 0.6f0 0.02f0 +pal-hit+ (* 0.8f0 %k) (+ ,seed 4f0))
     (dotimes (%j 6)
       (let* ((%f (i->f %j)) (%sd (if (< %j 3) -1f0 1f0)) (%q (i->f (mod %j 3))) (%w (* %sd (- 1.2f0 (* 0.3f0 %q)))))
         (declare (single-float %f %sd %q %w))
         (toon-ribbon ((+ ,x (* %sd 0.2f0 ,rx)) 1.32f0 (+ ,z (* %sd 0.2f0 ,rz))) ((* %w ,rx) (+ 0.25f0 (* 0.35f0 %q)) (* %w ,rz)) (0.15f0 0.02f0)
                      :seed (- -110f0 %f (f-mod %dr 3f0)) :wob 0.3f0 :pal +pal-flame+ :k %k :segs 4 :sway 0.07f0 :ph (+ %dr %f))))
     (%light ,x 1.0f0 ,z 1f0 0.5f0 0.2f0 5f0 (* 2f0 %k) 7)))

(defun-fast yama-nishi-look (a v cf)
  "西's look at cinematic frame CF: f40-52 the victim's weapon turning to ash from the tip toward the hilt (§15.3.4 flag 4: ash drawn over
it, the model untouched; at f52 the cinematic hides what is left, CINE-END's REFRESH-LOOK gives it back however it ends); the garb at full
from f52 (built in 4 f, guttering from f156); molten footprints behind him on the walk (f72-124); the white-hot streak of the pass
(f124-134); the column of flame rising off the victim (f130-170: 西's fire); the ash streaming up off his charred body from f134, black
smoke from f150. A look; 0 B."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((rdt (aref *ya-rdt* 0)) (seed (+ (* 3f0 px) pz)) (dr (drawing-no)))
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
              (fx-disc (+ x0 (* u ddx)) (+ y0 (* u ddy)) (+ z0 (* u ddz)) 0.05f0 0.2f0 (+ seed 20f0 dr) +pal-ember+ 0.9f0 :push 0.1f0)
              (dotimes (i (n-of 90f0 rdt))                ; flakes shed as it goes
                (let ((s (rnd-range 0f0 u)))
                  (declare (single-float s))
                  (%t-shard (+ x0 (* s ddx)) (+ y0 (* s ddy)) (+ z0 (* s ddz)) (rnd-range -0.4f0 0.4f0) (rnd-range -0.2f0 0.4f0)
                            (rnd-range -0.4f0 0.4f0) (rnd-range 0.8f0 1.3f0) (rnd-range 0.03f0 0.06f0) 0.6f0 +pal-ash+)))))))
      (when (and (<= 52 cf) (< cf 168))                   ; the garb at full
        (%ya-garb px pz rx rz (if (< cf 156) 1.3f0 (* 1.3f0 (/ (i->f (- 168 cf)) 12f0)))
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
                   (hh (* hc (+ 0.55f0 (* 0.6f0 (hash01 (+ f dr) seed))))))
              (declare (single-float f an c s hh))
              (%tongue (+ qx (* 0.55f0 c)) 0.04f0 (+ qz (* 0.55f0 s)) (* -0.05f0 hh c) hh (* -0.05f0 hh s) 0.11f0 +pal-flame+ k
                       (+ seed f dr 50f0) (+ dr f) 0.06f0 :segs 6)))
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

(defun yama-victim-attack (v)
  "西's f10: the victim's own first attack (his kit's J, CINE-SLOW 0.3 from now), started so its hit pose lands on f40 (30 frames x 0.3 =
9 frames of clip before S); a generic flinch-in when his kit has none (§15.3.4 flag 5)."
  (let* ((kit (kit-of v)) (mv (kit-command-move kit :q)))
    (if (and mv (mv-clip mv))
        (cine-clip v (kit-move-clip kit (mv-clip mv)) :blend 4 :speed (mv-clip-speed mv)
                   :time (/ (* (max 0 (- (mv-s mv) 9)) (mv-clip-speed mv)) 60.0))
        (cine-clip v :sh-clash :blend 4))))

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
