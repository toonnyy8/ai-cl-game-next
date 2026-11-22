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
  (at 86 (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-ash-burst x y z) (vfx-konpaku-shatter x y z (fighter-kikon-n (fighter a))))
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
rhombus (YAMA-TEAR, the user's §41; §20's radial tear before) running out to 12 m in 10 f from f84 and opening out to 2.5 m a side at its
widest over 14 f, 18 stations a side; a dust kick along it while it runs out (f85-91, §41); no ember hairline (§20.1); ash falling into
it to the end. A look; 0 B."
  (declare (fixnum cf))
  (when (>= cf 84)
    (%ya-line (px pz qx qz fx fz rx rz d) a v
      (let* ((tx (+ px (* 1.86f0 fx))) (tz (+ pz (* 1.86f0 fz))) (u (f-min 1f0 (/ (i->f (- cf 84)) 10f0))) (l (* 12f0 u))
             (g (f-min 1f0 (/ (i->f (- cf 83)) 14f0))) (w 2.5f0) (pk (toon-a +pal-ink+ 0.98f0 t)) (rdt (aref *ya-rdt* 0)))
        (declare (single-float tx tz u l g w pk rdt))
        (when (> l 0.05f0)                                ; the tear (YAMA-TEAR, §41): opening over 14 f, a fixed seed
          (yama-tear tx tz fx fz l w g 18 78f0 pk)
          (when (< cf 92)                                 ; the dust kick along it as the floor splits (f85-91, its run out: ~8 puffs)
            (%ya-tear-dust tx tz fx fz l (* w (- 1f0 (* (- 1f0 g) (- 1f0 g)))) 70f0 0.28f0 rdt))
          (dotimes (i (n-of 60f0 rdt))                    ; ash falling into it
            (let* ((s (rnd-range 0f0 l)) (w (* w (%ya-tent (/ s l)) (rnd-range -0.9f0 0.9f0))))
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

;;; The walk (§29.3, f66-216, real time at 南's pace): :SH-WALK-F at speed 0.55 (a 0.9 s cycle: 49.1 f a step) from f66, so the three steps
;;; land at f115 / f164 / f213 (115 + 49 i); the flash behind the victim follows at f216. YAMA-NISHI-WALKED / -BACKED are the metres walked /
;;; backed off by a frame, so the step-mode mover (YAMA-NISHI-WALK) and the look (the prints, the rings) agree.
(defun-fast-inline yama-nishi-walked (c)
  "西's walk (§29.3): the metres Yamamoto has walked by cinematic frame C (a single float): 0.02 m a frame from f66 to f213 (南's walk,
YAMA-MINAMI-WALK), 2.94 m in all. Pure; 0 B."
  (declare (single-float c))
  (* 0.02f0 (f-clamp (- c 66f0) 0f0 147f0)))

(defun-fast-inline yama-nishi-backed (c)
  "... and the metres the victim has backed off by frame C: 0.3 m eased out over the 10 frames after each of the first two steps (he
recoils from the heat; after the third the flash comes at once), 0.6 m in all, so the gap closes from 4 m to about 1.7 m at the flash.
Pure; 0 B."
  (declare (single-float c))
  (let ((s 0f0))
    (declare (single-float s))
    (dotimes (i 2 s)
      (let ((u (f-clamp (/ (- c (+ 115f0 (* 49f0 (i->f i)))) 10f0) 0f0 1f0)))
        (declare (single-float u))
        (setf s (+ s (* 0.3f0 u (- 2f0 u))))))))

(defun-fast-inline yama-nishi-garb-k (c)
  "西's garb at frame C of the walk (§29: 「每走一步都會讓火焰的威勢擴大」; §29.3: 「每走完一步就放大火焰」): the stance's K 1 until the first
step lands, then a step up as each lands (f115 / f164 / f213), to 1.3, 1.6 and 2.0 (the last above the play flare's peak 1.9, %YA-FLARE),
each snapped in over 2 frames with a 0.15 overshoot fading over 6: a jump per step, not a ramp. Pure; 0 B."
  (declare (single-float c))
  (let ((k 1f0))
    (declare (single-float k))
    (dotimes (i 3 k)
      (let ((d (- c (+ 115f0 (* 49f0 (i->f i))))))
        (declare (single-float d))
        (when (>= d 0f0)
          (setf k (+ k (* (if (= i 2) 0.4f0 0.3f0) (f-min 1f0 (/ (+ d 1f0) 2f0))) (* 0.15f0 (f-max 0f0 (- 1f0 (/ d 6f0)))))))))))

(defun-fast-inline yama-nishi-lean (c)
  "西's garb trailing on the walk (§29.3: 「全身的火焰朝後方飄蕩」): the lean the cinematic sets (the tips' trail per metre, as *YA-LEAN*'s)
at frame C: 0 before f66, eased in to 1 by f90, held to the flash (f216). The tongues lean 0.48 x it (§29.3; §29.6 the user: 「其他火焰照之前的
步行設定」), the wings lie flat by it (70 deg off upright at 1, GARB-TILT-ANGLE: 「只有毀魂技才平倒，而且僅限於肩膀的火焰」). Pure; 0 B."
  (declare (single-float c))
  (if (or (< c 66f0) (>= c 216f0))
      0f0
      (let ((u (f-clamp (/ (- c 66f0) 24f0) 0f0 1f0)))
        (declare (single-float u))
        (* u u (- 3f0 (* 2f0 u))))))

(defun-fast yama-nishi-look (a v cf)
  "西's look at cinematic frame CF: f40-52 the victim's weapon turning to ash from the tip toward the hilt (§15.3.4 flag 4: ash drawn over
it, the model untouched; at f52 the cinematic hides what is left, CINE-END's REFRESH-LOOK gives it back however it ends); the garb at the
stance's size from f0 (the play garb carried on; the coordinator, 2026-11-21: through the whole 西 form), stepping up as each step of the
walk lands (YAMA-NISHI-GARB-K, §29, §29.3), at full after the pass (guttering from f248); at each footfall a heat ring out from the foot and
a molten print cooling where it landed (f115-216); the white-hot streak of the pass (f216-226); the column of flame rising off the victim
(f222-262: 西's fire); the ash streaming up off his charred body from f226, black smoke from f242. The garb trails behind him (§29.1: his
side's spring, YAMA-LEAN-USE; on the walk the cinematic's own lean, YAMA-NISHI-LEAN, §29.3). A look; 0 B."
  (declare (fixnum cf))
  (yama-lean-use (fighter-side (fighter a)))
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
      (let ((l (yama-nishi-lean (i->f cf))))              ; the walk: the whole garb trails back (§29.3), whatever the spring says
        (declare (single-float l))
        (when (> l 0f0)
          (let ((ar *ya-garb-args*))
            (declare (type f32vec ar))
            (setf (aref ar 3) (* -0.48f0 l fx) (aref ar 4) (* -0.48f0 l fz) (aref ar 5) l))))   ; (§29.6: the wings flat)
      (when (< cf 216)                                    ; the garb (§29): the stance's size from f0 (YAMA-DRAW leaves 西's form
                                                          ;  aura to this look; the weapon dies on it at f40), a step up as each step lands
        (ya-garb px pz (yama-nishi-garb-k (i->f cf))))
      (when (and (<= 216 cf) (< cf 260))                  ; the garb at full after the pass (his right: he stands turned away)
        (%ya-garb px pz (- rx) (- rz) 1f0 (if (< cf 248) 0.98f0 (* 0.98f0 (/ (i->f (- 260 cf)) 12f0))) seed))
      (when (and (<= 115 cf) (< cf 216))                  ; each footfall: a heat ring out from the foot, a molten print cooling
        (let ((w (yama-nishi-walked (i->f cf))))
          (declare (single-float w))
          (dotimes (i 3)
            (let ((fi (+ 115 (* 49 i))))
              (declare (fixnum fi))
              (when (<= fi cf)
                (let* ((age (i->f (- cf fi))) (ah (- 0.22f0 (- w (yama-nishi-walked (i->f fi))))) (fl (i->f i))   ; (the landing foot,
                       (sd (if (= i 1) 0.15f0 -0.15f0))                                                          ;  0.22 m ahead: left,
                       (x (+ px (* ah fx) (* sd rx))) (z (+ pz (* ah fz) (* sd rz)))                             ;  right, left)
                       (kp (f-clamp (- 0.98f0 (* 0.008f0 age)) 0.35f0 0.98f0)) (kc (- 0.98f0 (* 0.07f0 age))))
                  (declare (single-float age ah fl sd x z kp kc))
                  (toon-ground-seg (- x (* 0.24f0 fx)) (- z (* 0.24f0 fz)) (+ x (* 0.24f0 fx)) (+ z (* 0.24f0 fz)) 0.012f0 0.17f0 0.8f0 0.8f0
                                   (+ seed 66f0 fl) 0.3f0 (toon-a +pal-ember+ kp))   ; the print: a pool of molten plaza (ep. 372),
                  (toon-ground-seg (- x (* 0.18f0 fx)) (- z (* 0.18f0 fz)) (+ x (* 0.18f0 fx)) (+ z (* 0.18f0 fz)) 0.015f0 0.11f0 1f0 0.7f0
                                   (+ seed 70f0 fl) 0.25f0 (toon-a +pal-flame+ kp))   ;  ember rim, flame
                  (when (> kc 0f0)                        ; its white-hot core, cooling
                    (toon-ground-seg (- x (* 0.12f0 fx)) (- z (* 0.12f0 fz)) (+ x (* 0.12f0 fx)) (+ z (* 0.12f0 fz)) 0.018f0 0.055f0 1f0 0.6f0
                                     (+ seed 74f0 fl) 0.2f0 (toon-a +pal-hit+ kc)))
                  (when (< age 14f0)                      ; the heat ring, wider each step
                    (let ((u (/ age 14f0)))
                      (declare (single-float u))
                      (%tring x 0f0 z (+ 0.2f0 (* (+ 1.4f0 (* 0.4f0 fl)) u)) (* 0.07f0 (- 1f0 (* 0.5f0 u))) +pal-flame+ (* 0.98f0 (- 1f0 u))
                              (+ seed 80f0 fl))
                      (when (< age 4f0) (%tring x 0.008f0 z (+ 0.2f0 (* (+ 1.4f0 (* 0.4f0 fl)) u)) 0.025f0 +pal-hit+ 0.98f0 (+ seed 84f0 fl)))
                      (%light x 0.3f0 z 1f0 0.55f0 0.25f0 4f0 (* 2.5f0 (- 1f0 u)) 7)))))))))
      (when (and (<= 216 cf) (< cf 226))                  ; the pass: a white-hot streak from his old side through the victim to him
        (let* ((k (* 0.98f0 (/ (i->f (- 226 cf)) 10f0))) (x0 (+ px (* 0.2f0 fx))) (z0 (+ pz (* 0.2f0 fz)))
               (x1 (+ qx (* 1.3f0 fx))) (z1 (+ qz (* 1.3f0 fz))))
          (declare (single-float k x0 z0 x1 z1))
          (fx-crescent x0 1.0f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.15f0 (* 0.5f0 (+ z0 z1)) 0.2f0 :lens 0.08f0 (+ seed 30f0) +pal-flame+ k :push 0.15f0)
          (fx-crescent x0 1.0f0 z0 x1 1.1f0 z1 (* 0.5f0 (+ x0 x1)) 1.15f0 (* 0.5f0 (+ z0 z1)) 0.08f0 :lens 0.05f0 (+ seed 31f0) +pal-hit+ k :push 0.2f0)))
      (when (and (<= 222 cf) (< cf 262))                  ; the column rising off him (西's fire)
        (let* ((g (f-min 1f0 (/ (i->f (- cf 221)) 6f0))) (hc (* 3.0f0 g))
               (k (if (< cf 246) 0.98f0 (f-clamp (* 0.98f0 (/ (i->f (- 262 cf)) 16f0)) 0f0 0.98f0))))
          (declare (single-float g hc k))
          (dotimes (i 10)                                 ; (thin and apart: the charred body shows between them)
            (let* ((f (i->f i)) (an (+ (* 0.6283f0 f) (* 0.3f0 (hash01 f seed)))) (c (f-cos an)) (s (f-sin an))
                   (hh (* hc (+ 0.55f0 (* 0.6f0 (flow01 f 5.5f0))))))
              (declare (single-float f an c s hh))
              (%tongue (+ qx (* 0.55f0 c)) 0.04f0 (+ qz (* 0.55f0 s)) (* -0.05f0 hh c) hh (* -0.05f0 hh s) 0.11f0 +pal-flame+ k
                       (+ f 50f0) (+ dr f) 0.06f0 :segs 6)))
          (%tring qx 0f0 qz 0.7f0 0.06f0 +pal-flame+ k (+ seed 60f0))
          (%light qx 1.5f0 qz 1f0 0.5f0 0.2f0 7f0 (* 3f0 k) 8)))
      (when (>= cf 226)                                   ; ash streaming up off the charred body, then black smoke
        (dotimes (i (n-of (if (< cf 252) 80f0 25f0) rdt))
          (%t-blob (+ qx (rnd-range -0.3f0 0.3f0)) (rnd-range 0.1f0 1.5f0) (+ qz (rnd-range -0.3f0 0.3f0)) (rnd-range -0.2f0 0.2f0)
                   (rnd-range 0.8f0 1.8f0) (rnd-range -0.2f0 0.2f0) (rnd-range 1.0f0 1.6f0) (rnd-range 0.04f0 0.08f0) -0.3f0 0.25f0 +pal-ash+))
        (when (>= cf 242)
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

(defun yama-nishi-wide (a v)
  "西's f52 shot (§29): side-on from his left, wide and still, framed on where the pair will stand once the victim has leapt back (2 m
ahead of him, 4 m apart): 5.6 m off that middle (portrait 7.6), 1.3 m up. No subject (a pair shot)."
  (setf *cine-close* nil *cine-subject* nil)
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((mx (+ px (* 2f0 fx))) (mz (+ pz (* 2f0 fz))) (dd (if (portrait-p) 7.6f0 5.6f0)))
      (declare (single-float mx mz dd))
      (cine-cam (- mx (* dd rx)) 1.3 (- mz (* dd rz)) mx 1.0 mz))))

(defun yama-nishi-leap (a v cf)
  "西's f53-64 (§29: 「隨即拉開距離」): the weaponless victim leaps back from 1.4 m to 4 m in front of him (eased out, a 0.4 m hop); he
does not move. Given back at CINE-END (CINE-SAVE)."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let* ((u (f-clamp (/ (i->f (- cf 52)) 12f0) 0f0 1f0)) (g (+ 1.4f0 (* 2.6f0 u (- 2f0 u)))) (q (pos-of v)))
      (declare (single-float u g) (type f32vec q))
      (setf (aref q 0) (+ px (* g fx)) (aref q 1) (* 1.6f0 u (- 1f0 u)) (aref q 2) (+ pz (* g fz))))))

(defun yama-nishi-track (a v)
  "西's walk shot (§29.4, the user: 「改成後方 15° 拍攝，並將鏡頭拉近」; §29.2's 「平視」): 15 deg off straight behind him on his right
(165 deg off his front), 4.3 m back on lens 50 (portrait 3.8, %PORTRAIT-DOLLY backs it off), at his eye height (1.5 m x his drawn scale),
looking level along the walk at the pair's middle at the same height: he on the left, the victim just past his right side, partly behind
the garb as they close. (§29.2-§29.3: 30 deg from 7.0 m on lens 38; §29: 145 deg on his left from 5 m back and 3.4 m up looking down.) A CINE-CAM with no subject: %KEEP-SUBJECT would centre him on a phone, in front of the victim."
  (setf *cine-close* nil *cine-subject* nil)
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let* ((dd (if (portrait-p) 3.8f0 4.3f0)) (ey (* 1.5f0 (draw-scale-of a)))
           (bx (+ (* -0.9659f0 fx) (* 0.2588f0 rx))) (bz (+ (* -0.9659f0 fz) (* 0.2588f0 rz))))   ; (cos / sin 165 deg; his right = +R)
      (declare (single-float dd ey bx bz))
      (cine-cam (+ px (* dd bx)) ey (+ pz (* dd bz)) (* 0.5f0 (+ px qx)) ey (* 0.5f0 (+ pz qz))))))

(defun yama-nishi-walk (a v cf)
  "西's walk, one step (f66-215, §29.3): he moves on by YAMA-NISHI-WALKED's gain since the last frame, the victim backs off by
YAMA-NISHI-BACKED's (both along their line); the shot follows (YAMA-NISHI-TRACK). Given back at CINE-END (CINE-SAVE)."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let* ((c (i->f cf)) (dw (- (yama-nishi-walked c) (yama-nishi-walked (- c 1f0))))
           (db (- (yama-nishi-backed c) (yama-nishi-backed (- c 1f0)))) (p (pos-of a)) (q (pos-of v)))
      (declare (single-float c dw db) (type f32vec p q))
      (setf (aref p 0) (+ px (* dw fx)) (aref p 2) (+ pz (* dw fz))
            (aref q 0) (+ qx (* db fx)) (aref q 2) (+ qz (* db fz)))))
  (yama-nishi-track a v))

(defun yama-nishi-fall (v i)
  "西's footfall I (0-2: f115 / f164 / f213, §29.3): the step lands (南's step, :STEP at pitch 0.6) with the heat roar growing each time;
after the first two the victim recoils (after the third the flash comes at once). The garb's step up, the heat ring and the print are the
look's. No camera shake (§29.2, the user: 「走路時不要震動鏡頭」; §29 shook 0.1 / 0.2 / 0.3)."
  (let ((g (* 0.1 (1+ i))))
    (play-sfx :step :pitch 0.6) (play-sfx :sizzle :pitch 0.7 :gain (+ 0.4 g))
    (play-sfx :awaken-rise :pitch (+ 0.5 g) :gain (+ 0.3 (* 2 g))))
  (when (< i 2) (cine-clip v :sh-stagger :blend 3)))

(defun yama-nishi-pass (a v)
  "西's f216, the instant (§15.3.2: a hard cut between two placements, no body crossing): he stands 2 m beyond the victim, the two back
to back (each turned away from the other); CINE-END gives the places back and RESET-ROUND / the K.O. face them again."
  (face-each-other a v -2.0)
  (dolist (e (list a v)) (setf (transform-yaw (transform e)) (f32 (+ (yaw-of e) 3.1415927)))))

(defcine yama-nishi-cine (a v :len 272 :hold 232)
  "殘日獄衣 ZANJITSU GOKUI, the Bankai's 西 Kikon: the user's storyboard (2026-11-20, DUEL_YAMA_CORE §15.3.2: 「西 殘日獄衣：對手先出手，
武器碰到火衣就從刀尖化成灰。山本燃起灼熱的火衣並緩步走向不知所措的對手。最終瞬間穿過對手，使其被升騰的高溫烈焰燒成灰燼。」). Beat 0, he
stands chin up, the blade low; over the victim's shoulder in slow motion the victim strikes first and he does not move; on his chest the
weapon meets the garb and turns to ash from the tip; side-on and wide the weaponless victim leaps back to 4 m (re-boarded 2026-11-21,
§29: 「對手靠近攻擊後武器損毀，隨即拉開距離」); from 30 deg behind him on his right at eye level (§29.2) he walks three steps at 南's
pace, the whole garb trailing back, stepping up as each step lands with a heat ring and a molten print, the 残日獄衣 stamp on the first,
the victim recoiling (「從斜後放拍攝山本緩步向前，每走一步都會讓火焰的威勢擴大」; §29.3: 「毀魂技走路節奏請做成跟火火十萬億死的節奏一樣…
總共走三步後就瞬移到對手身後」); right after the third the instant: a white-hot streak, a hard cut, he stands beyond the victim, back to back; low in
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
  (at 52 (yama-weapon-ash v) (cine-slow 1) (yama-nishi-wide a v) (lens 40)   ; (§29: the old ignition beat left; the garb at the
      (play-sfx :sizzle :pitch 0.8 :gain 0.7))                                ;  stance's size, he does not move)
  (at 53 (cine-clip v :sh-step-b :blend 2 :speed 1.7) (play-sfx :whoosh-heavy :pitch 0.7 :gain 0.7))   ; (the leap back: 24 f in 14)
  (when (and step-p (< 52 cf 65)) (yama-nishi-leap a v cf))
  (at 64 (cine-clip v :sh-stagger :blend 2) (play-sfx :land :pitch 0.9 :gain 0.5))   ; (lands off balance)
  (at 66 (lens 50) (cine-clip a :sh-walk-f :blend 8 :speed 0.55))   ; the walk from behind at 南's pace, real time (§29.3): a step
  (when (and step-p (<= 66 cf 215)) (yama-nishi-walk a v cf))       ;  each 49.1 f, landing f115 / f164 / f213
  (at 115 (yama-nishi-fall v 0) (caption "残日獄衣" :mark "西" :reading "ZANJITSU GOKUI" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (at 164 (yama-nishi-fall v 1))
  (at 80 (cine-clip v :sh-kikon-victim :blend 10)) (at 141 (cine-clip v :sh-kikon-victim :blend 10))   ; (cowering between
  (at 190 (cine-clip v :sh-kikon-victim :blend 10))                                                      ;  the recoils)
  (at 213 (yama-nishi-fall v 2))
  (at 216 (yama-nishi-pass a v) (impact-frame :negative 2) (play-sfx :cut-heavy :pitch 1.2) (cine-slow 1)
      (cine-clip a :ya-st-nishi :blend 0) (cine-clip v :sh-kikon-victim :blend 0)
      (shot-on v 0 2.6 1.4 :look 1.3) (lens 50))
  (at 222 (lens 40) (play-sfx :explode :pitch 0.7) (play-sfx :sizzle)   ; low, in front of him, looking past him at the victim
      (%ya-line (px pz qx qz fx fz rx rz d) a v
        (cine-cam (+ px (* -1.5f0 fx) (* 3.5f0 rx)) 0.4 (+ pz (* -1.5f0 fz) (* 3.5f0 rz)) (+ px (* 1.2f0 fx)) 1.1 (+ pz (* 1.2f0 fz)))))   ; (off to his
                                                                              ;  side: his garb and the column read apart)
  (at 226 (impact-frame :negative 2) (silhouette-black v) (cine-clip v :sh-crumple :blend 3)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (play-sfx :konpaku-shatter) (shake 0.4 0.4))
  (at 228 (impact-frame :manga 10))
  (at 242 (cine-clip v :sh-down :blend 10) (caption-exit))   ; (out before the wide: there he stands under its column)
  (at 252 (shot-pair a v 1 (if (portrait-p) 9.0 7.0) 1.6) (lens 44)
      (let ((p (pos-of a))) (vfx-burnout (aref p 0) (aref p 2) t)))
  (during (0 272) (yama-nishi-look a v cf)))

;;; ---------------------------------------------------------------- 南 火火十万億死大葬陣 DAISOJIN (§15.3.3, §36, §37: 300 f)
;;; §36 (the user, 2026-11-22: 「南的毀魂技我希望呈現從地底湧出數以萬計的骷髏，並從四面八方將對手逐漸拖入地下覆蓋」): the dead surge
;;; out of the whole plaza and drag the victim under from every side. "Tens of thousands" in the 16384-vertex toon batch (render.c
;;; R_FX_VERTS) is tiers: near, bone hands out of the floor on his joints and the vector climbers (%YA-CLIMBER) behind him; mid, a skull
;;; face (bone cranium, two ink sockets, a jaw) with one or two raised three-fingered bone hands (%YA-WIGHT); far, a skull and on half a raised hand; under
;;; them the charcoal ground they boil out of (one flat annulus, its uv on the plaza). The sea's spots are a fixed polar grid round the victim (HASH01: nothing
;;; flickers), culled to the lens, the mid tier and the whole sea each capped by vertex count (+YA-SEA-MID+ / +YA-SEA-ALL+). The victim
;;; sinks by his root height (pos y, given back at CINE-END), so the plaza's floor cuts him like Doré's mire (the Inferno VIII reference).
(declaim (type f32vec *ya-sea* *ya-web*))
(defvar *ya-sea* (make-f32 1) "南's cinematic: [0] the victim's drawn height (m), kept at f0 so no look reads a boxed struct float.")
(defvar *ya-web* (make-f32 (* 13 4 2)) "南's crack web: each of its 13 rays' four points (x z), written by the look as it draws them.")
(defconstant +ya-sea-mid+ 3600 "南's sea: the mid tier's dead are drawn while the sea has used fewer toon verts than this (then specks).")
(defconstant +ya-sea-all+ 8000 "南's sea: nothing more once it has used this many toon verts (7600 from above, 5000 once the mound stands, 3200 in the wide; 16384 a frame for every toon look).")

(defmacro %ya-ease (u) "Smoothstep of U clamped to 0..1 (a single-float form; 0 B)."
  `(let ((%e (f-clamp ,u 0f0 1f0))) (declare (single-float %e)) (* %e %e (- 3f0 (* 2f0 %e)))))

(defmacro %ya-sink (h c)
  "南's victim's root height at cinematic frame C (a single-float form) for his drawn height H (§36, round 2: the sink must be
visible; §37, slowed): 0 until f72, -0.6 m by f130 (ankles, then knees under), his waist (-H/2) by f170, his chest (-0.7 H) by f215
in three tugs (the struggle close-up: smoothstep steps of 5 f over f175 / f190 / f205, with :SH-STRUGGLE's yanks), only his head and
the reaching hand left (-(H - 0.35)) by f240, under (-(H + 0.15)) by f252, held there; 0 again from f266 (lying, in the wide). A
macro (0 B)."
  `(let ((%h ,h) (%c ,c))
     (declare (single-float %h %c))
     (cond ((< %c 72f0) 0f0)
           ((< %c 130f0) (* -0.6f0 (%ya-ease (/ (- %c 72f0) 58f0))))
           ((< %c 170f0) (- -0.6f0 (* (- (* 0.5f0 %h) 0.6f0) (%ya-ease (/ (- %c 130f0) 40f0)))))
           ((< %c 215f0) (- (* -0.5f0 %h) (* 0.0667f0 %h (+ (%ya-ease (/ (- %c 175f0) 5f0)) (%ya-ease (/ (- %c 190f0) 5f0))
                                                            (%ya-ease (/ (- %c 205f0) 5f0))))))
           ((< %c 240f0) (- (* -0.7f0 %h) (* (- (* 0.3f0 %h) 0.35f0) (%ya-ease (/ (- %c 215f0) 25f0)))))
           ((< %c 266f0) (- 0.35f0 %h (* 0.5f0 (%ya-ease (/ (- %c 240f0) 12f0)))))
           (t 0f0))))

(defmacro %ya-skull (x y z r k seed jaw crx cry crz cux cuy cuz)
  "A skull face toward the lens (§36, round 2, after Ep 372 / ch. 508: two sockets and a jaw, never one centred dot): an ASH (bone) cranium
of radius R at (X Y Z), two INK sockets side by side along the camera's right (CR), a little above its middle, and, when JAW, an ASH jaw
hanging below it along the camera's down (CU = the camera's up). Single-float forms (JAW a boolean form); 18 toon verts (+12 the jaw); 0 B."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%r ,r) (%k ,k) (%sd ,seed) (%crx ,crx) (%cry ,cry) (%crz ,crz) (%cux ,cux) (%cuy ,cuy) (%cuz ,cuz))
     (declare (single-float %x %y %z %r %k %sd %crx %cry %crz %cux %cuy %cuz))
     (fx-disc %x %y %z %r 0.06f0 %sd +pal-ash+ %k :push 0.12f0)
     (when ,jaw
       (fx-shard (- %x (* 0.95f0 %r %cux)) (- %y (* 0.95f0 %r %cuy)) (- %z (* 0.95f0 %r %cuz)) (- %cux) (- %cuy) (- %cuz) (* 0.95f0 %r)
                 (* 0.55f0 %r) 0.04f0 (+ %sd 3f0) +pal-ash+ %k :push 0.13f0))
     (dotimes (%e 2)
       (let ((%o (if (= %e 0) -0.4f0 0.4f0)))
         (declare (single-float %o))
         (fx-disc (+ %x (* %o %r %crx) (* 0.05f0 %r %cux)) (+ %y (* %o %r %cry) (* 0.05f0 %r %cuy)) (+ %z (* %o %r %crz) (* 0.05f0 %r %cuz))
                  (* 0.27f0 %r) 0.05f0 (+ %sd 1f0 (i->f %e)) +pal-ink+ %k :push 0.2f0)))))

(defmacro %ya-bone-hand (x y z dx dy dz len w k seed tx ty tz fingers)
  "A bone arm reaching (§36, round 2: raised open hands with fingers everywhere): an ASH stroke from (X Y Z) LEN m along the unit (DX DY
DZ), half-width W, a small ASH palm at its end and FINGERS (2 or 3) ASH fingers splayed along the unit T. Single-float forms (FINGERS a
fixnum form); 18 toon verts + 12 a finger; 0 B."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%dx ,dx) (%dy ,dy) (%dz ,dz) (%l ,len) (%w ,w) (%k ,k) (%sd ,seed) (%tx ,tx) (%ty ,ty) (%tz ,tz)
          (%hx (+ %x (* %l %dx))) (%hy (+ %y (* %l %dy))) (%hz (+ %z (* %l %dz))) (%n ,fingers))
     (declare (single-float %x %y %z %dx %dy %dz %l %w %k %sd %tx %ty %tz %hx %hy %hz) (fixnum %n))
     (fx-shard (+ %x (* 0.4f0 %l %dx)) (+ %y (* 0.4f0 %l %dy)) (+ %z (* 0.4f0 %l %dz)) %dx %dy %dz %l %w 0.04f0 %sd +pal-ash+ %k :push 0.1f0)
     (fx-disc %hx %hy %hz (* 1.6f0 %w) 0.05f0 (+ %sd 1f0) +pal-ash+ %k :push 0.12f0)
     (dotimes (%g %n)
       (let* ((%e (if (= %n 2) (if (= %g 0) -0.35f0 0.35f0) (* 0.5f0 (- (i->f %g) 1f0))))
              (%fx (+ %dx (* %e %tx))) (%fy (+ %dy (* %e %ty))) (%fz (+ %dz (* %e %tz)))
              (%fl (f-max 0.01f0 (f-sqrt (+ (* %fx %fx) (* %fy %fy) (* %fz %fz))))) (%f (* 0.3f0 %l)))
         (declare (single-float %e %fx %fy %fz %fl %f))
         (setf %fx (/ %fx %fl) %fy (/ %fy %fl) %fz (/ %fz %fl))
         (fx-shard (+ %hx (* 0.4f0 %f %fx)) (+ %hy (* 0.4f0 %f %fy)) (+ %hz (* 0.4f0 %f %fz)) %fx %fy %fz %f (* 0.55f0 %w) 0.04f0
                   (+ %sd 2f0 (i->f %g)) +pal-ash+ %k :push 0.13f0)))))

(defmacro %ya-wight (x y z vx vz sc k seed ph arms lean jaw crx cry crz cux cuy cuz)
  "One of 南's sea (§36, round 2): standing at (X Y Z) (Y < 0: still coming out of the ground), its skull (%YA-SKULL) 0.4 SC m up, ARMS
(0-2) bone arms with three-fingered hands (%YA-BONE-HAND) raised from its shoulders, leaning LEAN toward the unit (VX VZ) on the ground
(the victim; more as the sea flows in), PH swinging them. Single-float forms (ARMS a fixnum, JAW a boolean form); 18-30 toon verts + 54
an arm; 0 B."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%vx ,vx) (%vz ,vz) (%sc ,sc) (%k ,k) (%sd ,seed) (%ph ,ph) (%ln ,lean) (%tx (- %vz)) (%tz %vx))
     (declare (single-float %x %y %z %vx %vz %sc %k %sd %ph %ln %tx %tz))
     (%ya-skull (+ %x (* 0.08f0 %sc %vx)) (+ %y (* 0.4f0 %sc)) (+ %z (* 0.08f0 %sc %vz)) (* 0.085f0 %sc) %k %sd ,jaw
                ,crx ,cry ,crz ,cux ,cuy ,cuz)
     (dotimes (%b ,arms)
       (let* ((%sg (if (= %b 0) 1f0 -1f0)) (%w (* %sg (+ 0.25f0 (* 0.15f0 (f-sin (+ %ph (* 2.1f0 %sg)))))))
              (%dx (+ (* %ln %vx) (* %w %tx))) (%dy (+ 0.9f0 (* 0.2f0 (f-sin (* 0.7f0 %ph))))) (%dz (+ (* %ln %vz) (* %w %tz)))
              (%l (f-max 0.01f0 (f-sqrt (+ (* %dx %dx) (* %dy %dy) (* %dz %dz))))))
         (declare (single-float %sg %w %dx %dy %dz %l))
         (setf %dx (/ %dx %l) %dy (/ %dy %l) %dz (/ %dz %l))
         (%ya-bone-hand (+ %x (* 0.11f0 %sg %sc %tx)) (+ %y (* 0.3f0 %sc)) (+ %z (* 0.11f0 %sg %sc %tz)) %dx %dy %dz (* 0.38f0 %sc)
                        (* 0.022f0 %sc) %k (+ %sd 5f0 (* 4f0 %sg)) %tx 0f0 %tz 3)))))

(defun-fast yama-minami-sea (a v cf)
  "南's sea at cinematic frame CF (§36): a polar grid round the victim, rings 0.55 m apart out to 10 m, the dead 0.55 m apart round each
(about 1200 spots); each comes out of the ground over 9 f when the front passes it (the front closes from 10 m at f62 to 0.6 m at f96:
from the outside in), reaching toward him; drawn in and round (a spiral, the inner ones all the way into the mound) over f215-260, their
arms leaning in harder; back into the ground over f268-296, each at its own frame (§37: the flow and after +55-60 f). Left out: a clearing
of 1.2 m round the old man and nothing past him (he walks out of it, his back to it), outside the arena, within 5 m of the lens (1.1 m in
the struggle close-up, f170-215, whose lens stands 2 m from him), out of the frame. Mid tier (a skull with
a jaw, one or two raised hands, %YA-WIGHT) while near enough to read (the half frame height there under 2.5 m) and under +YA-SEA-MID+;
then the far tier to +YA-SEA-ALL+ (7600 from above, f215; 5000 once the mound stands; 3200 from f260): a skull (two from above), a raised two-fingered hand on half
of them. A look; 0 B."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (with-cam (crx cry crz cux cuy cuz)
    (let* ((c (i->f cf)) (e (camera-eye *camera*)) (cw (camera-forward *camera*))
           (ex (aref e 0)) (ey (aref e 1)) (ez (aref e 2)) (cfx (aref cw 0)) (cfy (aref cw 1)) (cfz (aref cw 2))
           (tn (/ (f-sin (* 0.5f0 *lens-fov*)) (f-cos (* 0.5f0 *lens-fov*))))
           (cone (/ 1f0 (f-sqrt (+ 1f0 (* 6.25f0 tn tn)))))   ; (the frame's corner: 2.5 x the vertical half, a phone's widened lens too)
           (w (%ya-ease (/ (- c 215f0) 45f0))) (lean (+ 0.45f0 (* 0.8f0 w)))
           (k (* 0.98f0 (- 1f0 (%ya-ease (/ (- c 286f0) 12f0))))) (dr (drawing-no)) (used 0)
           (cap (cond ((>= cf 260) 3200) ((>= cf 240) 5000) ((>= cf 215) 7600) (t +ya-sea-all+)))
           (close (and (<= 170 cf) (< cf 215))) (lc (if close 1.1f0 5f0))   ; (§37: the struggle close-up's lens is 2 m from him)
           (vl (f-max 0.01f0 (f-hypot (- ex qx) (- ez qz)))) (ux (/ (- ex qx) vl)) (uz (/ (- ez qz) vl)))
      (declare (type f32vec e cw) (single-float c ex ey ez cfx cfy cfz tn cone w lean k dr lc vl ux uz) (fixnum used cap))
      (when (> k 0.02f0)
        (dotimes (j 18)
          (let* ((fj (i->f j)) (rj (+ 0.6f0 (* 0.55f0 fj))) (m (f->i (/ (* 6.2832f0 rj) 0.55f0))))
            (declare (single-float fj rj) (fixnum m))
            (dotimes (i m)
              (let* ((fi (i->f i)) (h1 (hash01 (+ fi (* 31f0 fj)) 3.7f0)) (h2 (hash01 (+ fi (* 31f0 fj)) 8.3f0))
                     (r0 (+ rj (* 0.36f0 (- h2 0.5f0)))) (fr (+ 62f0 (* 34f0 (- 1f0 (/ (- r0 0.6f0) 9.4f0))) (* 5f0 h1)))
                     (u (f-clamp (/ (- c fr) 9f0) 0f0 1f0))
                     (down (* 0.75f0 (%ya-ease (/ (- c 268f0 (* 18f0 h2)) 10f0)))))   ; (back in, each at its own frame f268-296)
                (declare (single-float fi h1 h2 r0 fr u down))
                (when (and (> u 0f0) (< down 0.74f0))
                  (let* ((rr (f-max 0f0 (- r0 (* w (f-min r0 (+ 1.6f0 (* 0.2f0 r0)))))))
                         (an (+ (* 6.2832f0 (/ (+ fi (* 0.5f0 (i->f (logand j 1))) (* 0.4f0 h1)) (i->f m))) (/ (* 1.3f0 w) (+ 1f0 (* 0.3f0 r0)))))
                         (ca (f-cos an)) (sa (f-sin an)) (x (+ qx (* rr ca))) (z (+ qz (* rr sa)))
                         (y (- (* -0.5f0 (- 1f0 (* u (- 2f0 u)))) down))
                         (sc (* (+ 0.9f0 (* 0.3f0 h2)) (f-clamp (/ (- rr 0.35f0) 0.4f0) 0f0 1f0)))
                         (gx (- x ex)) (gy (- 0.3f0 ey)) (gz (- z ez)) (de (f-max 0.01f0 (f-sqrt (+ (* gx gx) (* gy gy) (* gz gz))))))
                    (declare (single-float rr an ca sa x z y sc gx gy gz de))
                    (when (and (> sc 0.05f0)
                               (> rr (cond ((< cf 170) 1.3f0) (close 0.8f0) ((< cf 246) 0.8f0) (t 0f0)))   ; (his own dead first, his head last;
                                                                                                    ;  §37: at his waterline in the close-up)
                               (> (f-hypot (- x px) (- z pz)) 1.2f0)                         ; the old man's clearing
                               (< (- (+ (* (- x qx) fx) (* (- z qz) fz))) (+ d 0.6f0))     ; nothing past him
                               (< (+ (* x x) (* z z)) 200f0)                                  ; inside the arena (14.1 m)
                               (> de lc)                                                      ; not near the lens
                               (or (not close) (< (+ (* (- x qx) ux) (* (- z qz) uz)) 0.2f0)   ; (§37: none between him and the
                                   (> (f-abs (- (* (- x qx) uz) (* (- z qz) ux))) 0.9f0))      ;  close-up's lens)
                               (> (+ (* gx cfx) (* gy cfy) (* gz cfz)) (- (* cone de) 0.7f0)))   ; in the frame
                      (if (and (< used +ya-sea-mid+) (< (* de tn) 2.5f0))
                          (let ((arms (cond ((< h1 0.1f0) 0) ((< h1 0.8f0) 1) (t 2))))
                            (declare (fixnum arms))
                            (%ya-wight x y z (- ca) (- sa) sc k (+ (* 7f0 fi) fj) (+ (* 0.8f0 dr) (* 6.2832f0 h2)) arms lean t
                                       crx cry crz cux cuy cuz)
                            (incf used (+ 30 (* 54 arms))))
                          (when (< used cap)                                             ; far: a skull, a raised hand on a third
                            (%ya-skull x (+ y (* 0.36f0 sc)) z (* 0.09f0 sc) k (+ (* 7f0 fi) fj) nil crx cry crz cux cuy cuz)
                            (incf used 18)
                            (when (< cfy -0.6f0)                                        ; (from above: a second skull)
                              (%ya-skull (- x (* 0.27f0 sa)) (+ y (* 0.3f0 sc)) (+ z (* 0.27f0 ca)) (* 0.09f0 sc) k (+ (* 7f0 fi) fj 20f0) nil
                                         crx cry crz cux cuy cuz)
                              (incf used 18))
                            (when (< h1 0.5f0)
                              (let* ((hx (+ (* -0.5f0 ca lean) (* 0.3f0 (- h2 0.3f0) (- sa)))) (hz (+ (* -0.5f0 sa lean) (* 0.3f0 (- h2 0.3f0) ca)))
                                     (hl (f-sqrt (+ (* hx hx) 0.81f0 (* hz hz)))))
                                (declare (single-float hx hz hl))
                                (%ya-bone-hand (+ x (* 0.1f0 sa)) (+ y (* 0.3f0 sc)) (- z (* 0.1f0 ca)) (/ hx hl) (/ 0.9f0 hl) (/ hz hl)
                                               (* 0.4f0 sc) (* 0.024f0 sc) k (+ (* 7f0 fi) fj 9f0) (- sa) 0f0 ca 2))
                              (incf used 42))))))))))))
      used)))
  nil)

(defun-fast yama-minami-web (a v cf)
  "南's crack web from where the blade went in (f51, §36: 「from the blade across the whole plaza」): 13 rays 6-13 m long racing out in 9 f
(three kinked INK segments with an EMBER hairline each, a branch off each kink), then the chords between neighbouring rays' kinks (the
web) over 4 f; the old crack to the victim kept. Under the sea's ground until it sinks back. A look; 0 B."
  (declare (fixnum cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let* ((c (i->f cf)) (bx (- qx (* 4.1f0 fx))) (bz (- qz (* 4.1f0 fz))) (g (f-min 1f0 (/ (- c 50f0) 9f0))) (wb *ya-web*)
           (l1 (* 4.1f0 (f-min 1f0 (/ (- c 49f0) 6f0)))))
      (declare (single-float c bx bz g l1) (type f32vec wb))
      (toon-ground-seg bx bz (+ bx (* l1 fx)) (+ bz (* l1 fz)) 0.012f0 0.06f0 1f0 0.5f0 (+ qx 1f0) 0.35f0 (toon-a +pal-ink+ 0.95f0))
      (toon-ground-seg bx bz (+ bx (* l1 fx)) (+ bz (* l1 fz)) 0.016f0 0.018f0 0.3f0 0.3f0 (+ qx 2f0) 0.3f0 (toon-a +pal-ember+ 0.95f0))
      (dotimes (i 13)
        (let* ((fi (i->f i)) (th (+ (* 0.4833f0 fi) (* 0.35f0 (hash01 fi 2.9f0)))) (l (+ 6f0 (* 7f0 (hash01 fi 6.1f0))))
               (ct (f-cos th)) (st (f-sin th)) (gi (* 3f0 (f-clamp (- (* 1.15f0 g) (* 0.15f0 (hash01 fi 4.4f0))) 0f0 1f0)))
               (o (* 8 i)) (x0 bx) (z0 bz))
          (declare (single-float fi th l ct st gi x0 z0) (fixnum o))
          (setf (aref wb o) bx (aref wb (1+ o)) bz)
          (dotimes (q 3)
            (let* ((fk (i->f q)) (s1 (/ (+ fk 1f0) 3f0)) (jt (if (= q 2) 0f0 (* 0.2f0 l(- (hash01 (+ fi (* 3f0 fk)) 7.7f0) 0.5f0))))
                   (x1 (- (+ bx (* s1 l ct)) (* jt st))) (z1 (+ bz (* s1 l st) (* jt ct))) (u (f-clamp (- gi fk) 0f0 1f0))
                   (wd (* 0.055f0 (- 1f0 (* 0.28f0 fk)))) (sd (+ fi (* 3f0 fk) 40f0)))
              (declare (single-float fk s1 jt x1 z1 u wd sd))
              (setf (aref wb (+ o 2 (* 2 q))) x1 (aref wb (+ o 3 (* 2 q))) z1)
              (when (> u 0f0)
                (let ((xe (+ x0 (* u (- x1 x0)))) (ze (+ z0 (* u (- z1 z0)))))
                  (declare (single-float xe ze))
                  (toon-ground-seg x0 z0 xe ze 0.012f0 wd 1f0 0.5f0 sd 0.35f0 (toon-a +pal-ink+ 0.95f0))
                  (toon-ground-seg x0 z0 xe ze 0.016f0 (* 0.3f0 wd) 0.3f0 0.3f0 (+ sd 30f0) 0.3f0 (toon-a +pal-ember+ 0.95f0))
                  (when (and (>= u 1f0) (< q 2))                ; a branch off the kink
                    (let* ((ba (+ th (if (> (hash01 sd 1.3f0) 0.5f0) 0.7f0 -0.7f0))) (bl (* 0.18f0 l (+ 0.5f0 (hash01 sd 2.3f0)))))
                      (declare (single-float ba bl))
                      (toon-ground-seg x1 z1 (+ x1 (* bl (f-cos ba))) (+ z1 (* bl (f-sin ba))) 0.012f0 (* 0.6f0 wd) 1f0 0.3f0 (+ sd 60f0) 0.35f0
                                       (toon-a +pal-ink+ 0.95f0))))))
              (setf x0 x1 z0 z1)))))
      (when (> c 58f0)                                    ; the chords between neighbouring rays' kinks
        (let ((u (f-min 1f0 (/ (- c 58f0) 4f0))))
          (declare (single-float u))
          (dotimes (i 13)
            (dotimes (q 2)
              (let ((sd (+ (i->f i) (* 13f0 (i->f q)) 90f0)))
                (declare (single-float sd))
                (when (> (hash01 sd 5.9f0) 0.35f0)
                  (let* ((o (+ (* 8 i) 2 (* 2 q))) (o2 (+ (* 8 (mod (1+ i) 13)) 2 (* 2 q)))
                         (xa (aref wb o)) (za (aref wb (1+ o))) (xb (+ xa (* u (- (aref wb o2) xa)))) (zb (+ za (* u (- (aref wb (1+ o2)) za)))))
                    (declare (fixnum o o2) (single-float xa za xb zb))
                    (toon-ground-seg xa za xb zb 0.012f0 0.035f0 1f0 0.4f0 sd 0.35f0 (toon-a +pal-ink+ 0.95f0))
                    (toon-ground-seg xa za xb zb 0.016f0 0.011f0 0.3f0 0.3f0 (+ sd 50f0) 0.3f0 (toon-a +pal-ember+ 0.9f0)))))))))))
  nil)

(defun-fast yama-minami-look (a v cf)
  "南's look at cinematic frame CF (§36): the crack web from the blade (YAMA-MINAMI-WEB, f51 on); the charcoal ground of the sea (its uv the
plaza's x z, so its field is the distance from him) closing in from 10 m to him over f62-96 with an INK ring and an EMBER hairline on its front and dust thrown up along it, ragged as it sinks back; the sea (YAMA-MINAMI-SEA); on him eight bone hands out of the floor, each
under a skull breaking it (from f86, one every 6 f, none from the lens's side: the floor is seen to cut him), reaching to his knees, waist,
sword hand, arms and chest, each gone once its joint is under (round 2: the posed dead read as boulders at his shins); in the struggle
close-up (§37, f170-215) seven more, closer in, climbing his shoulders, arms and chest and at last his reaching wrist (one every 5 f from
f172); 14 of the bone dead (%YA-WIGHT) behind him (f96-246; on the lens's side only from f130, none between him and the close-up's lens;
drawn in over the flow); the mound of the bone dead over the spot (round 2b: not the tower's ink climbers) (f240, 1.6 m by f256) with one
last hand out of its crest (f248-266), the ember light and cracks under it at the Konpaku (f260), crumbling to ash as it sinks back
(f266-288); ash falling over the plaza from f260. A look; 0 B."
  (declare (fixnum cf))
  (when (>= cf 50) (yama-minami-web a v cf))
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let* ((c (i->f cf)) (rdt (aref *ya-rdt* 0)) (seed (+ qx (* 3f0 qz))) (dr (drawing-no)) (sink (let ((q (pos-of v))) (declare (type f32vec q)) (aref q 1)))
           (w (%ya-ease (/ (- c 215f0) 45f0))) (k (* 0.98f0 (- 1f0 (%ya-ease (/ (- c 276f0) 10f0)))))
           (rf (f-max 0.2f0 (- 10f0 (* 9.4f0 (f-clamp (/ (- c 62f0) 34f0) 0f0 1f0))))))   ; the front (the sea's rise frame inverted)
      (declare (single-float c rdt seed dr sink w k rf))
      (when (and (<= 62 cf) (< cf 298))                   ; the ground the dead boil out of
        (let ((ri (f-max 0f0 (- rf 0.3f0))) (pk (toon-a +pal-black-smoke+ (* 0.95f0 k))) (sd (+ 1061f0 (f-mod (f-abs seed) 100f0)))
              (wb (+ 0.3f0 (* 0.9f0 (%ya-ease (/ (- c 272f0) 20f0))))))   ; (ragged as it sinks back)
          (declare (single-float ri pk sd wb))            ; (charcoal; its uv the ground's x z over 10.7 m, so the field is the
          (with-fx-verts (o2 o :toon 288)                 ;  distance from him and the noise lies on the plaza in 2-D: a
            (dotimes (sg 48)                              ;  sector's uv runs only across its radii, which draws bands)
              (let* ((a0 (* 0.1309f0 (i->f sg))) (a1 (+ a0 0.1309f0)) (c0 (f-cos a0)) (s0 (f-sin a0)) (c1 (f-cos a1)) (s1 (f-sin a1))
                     (iu (/ ri 10.7f0)) (ou (/ 10.4f0 10.7f0)))
                (declare (single-float a0 a1 c0 s0 c1 s1 iu ou))
                (vtx (+ qx (* ri c0)) 0.03f0 (+ qz (* ri s0)) (* iu c0) (* iu s0) 1f0 sd wb pk)
                (vtx (+ qx (* 10.4f0 c0)) 0.03f0 (+ qz (* 10.4f0 s0)) (* ou c0) (* ou s0) 1f0 sd wb pk)
                (vtx (+ qx (* 10.4f0 c1)) 0.03f0 (+ qz (* 10.4f0 s1)) (* ou c1) (* ou s1) 1f0 sd wb pk)
                (vtx (+ qx (* ri c0)) 0.03f0 (+ qz (* ri s0)) (* iu c0) (* iu s0) 1f0 sd wb pk)
                (vtx (+ qx (* 10.4f0 c1)) 0.03f0 (+ qz (* 10.4f0 s1)) (* ou c1) (* ou s1) 1f0 sd wb pk)
                (vtx (+ qx (* ri c1)) 0.03f0 (+ qz (* ri s1)) (* iu c1) (* iu s1) 1f0 sd wb pk))))))
      (when (and (< 62 cf) (< cf 98))                     ; its front: ink, an ember hairline, dust thrown up
        (%tring qx 0.03f0 qz rf 0.09f0 +pal-ink+ 0.95f0 (+ seed 3f0))
        (%tring qx 0.04f0 qz (+ rf 0.06f0) 0.022f0 +pal-ember+ 0.9f0 (+ seed 4f0))
        (dotimes (i (if (> rf 2f0) (n-of 90f0 rdt) 0))
          (let* ((an (rnd-range 0f0 6.2832f0)) (e (camera-eye *camera*)))
            (declare (single-float an) (type f32vec e))
            (when (> (f-hypot (- (+ qx (* rf (f-cos an))) (aref e 0)) (- (+ qz (* rf (f-sin an))) (aref e 2))) 6f0)   ; (none near the lens)
            (%t-blob (+ qx (* rf (f-cos an))) 0.1f0 (+ qz (* rf (f-sin an))) (* -0.6f0 (f-cos an)) (rnd-range 0.3f0 1.2f0) (* -0.6f0 (f-sin an))
                     (rnd-range 0.4f0 0.7f0) (rnd-range 0.12f0 0.22f0) -0.2f0 0.25f0 +pal-dust+)))))
      (when (>= cf 62) (yama-minami-sea a v cf))
      (when (and (<= 86 cf) (< cf 256))                   ; bone hands out of the floor on his knees, waist, sword arm, arms, chest
        (with-cam (crx cry crz cux cuy cuz)               ; (round 2: none from the lens's side, so the floor is seen to cut him;
          (let* ((jm (model-joints (model v))) (hp *ya-ct*) (e (camera-eye *camera*))   ;  one every 6 f; dropped when the joint is under)
                 (be (f-atan2 (- (aref e 2) qz) (- (aref e 0) qx))))
            (declare (type f32vec jm hp e) (single-float be))
            (dotimes (i 15)                               ; (§37: 8-14 the struggle's, from f172 one every 5 f, 0.42 m out)
              (let* ((fi (i->f i)) (s2 (>= i 8))
                     (u (if s2 (f-clamp (/ (- c 172f0 (* 5f0 (- fi 8f0))) 6f0) 0f0 1f0) (f-clamp (/ (- c 86f0 (* 6f0 fi)) 8f0) 0f0 1f0))))
                (declare (single-float fi u))
                (when (> u 0f0)
                  (joint-point! hp jm (case i (0 (ji :shin-r)) (1 (ji :shin-l)) (2 (ji :pelvis)) (3 (ji :hand-r)) (4 (ji :lower-arm-l))
                                        (5 (ji :upper-arm-r)) (6 (ji :upper-arm-l)) (7 (ji :chest)) (8 (ji :shoulder-l))
                                        (9 (ji :lower-arm-r)) (10 (ji :shoulder-r)) (11 (ji :chest)) (12 (ji :upper-arm-l))
                                        (13 (ji :neck)) (t (ji :hand-l)))
                                0f0 0f0 0f0)
                  (let* ((an (if s2 (+ be 1.0f0 (* 0.61f0 (- fi 8f0)) (* 0.25f0 (hash01 fi 2.2f0))) (+ be 0.75f0 (* 0.68f0 fi))))
                         (ar (if s2 0.42f0 0.6f0)) (ax (+ qx (* ar (f-cos an)))) (az (+ qz (* ar (f-sin an))))
                         (jx (aref hp 0)) (jy (aref hp 1)) (jz (aref hp 2))
                         (dx (- jx ax)) (dy (- jy 0.08f0)) (dz (- jz az)) (l (f-max 0.05f0 (f-sqrt (+ (* dx dx) (* dy dy) (* dz dz)))))
                         (hl (f-max 0.01f0 (f-hypot dx dz))))
                    (declare (single-float an ar ax az jx jy jz dx dy dz l hl))
                    (when (> jy 0.15f0)
                      (%ya-skull ax 0.07f0 az 0.085f0 0.98f0 (+ seed 40f0 fi) nil crx cry crz cux cuy cuz)
                      (%ya-bone-hand ax 0.08f0 az (/ dx l) (/ dy l) (/ dz l) (* u (- l 0.08f0)) 0.03f0 0.98f0 (+ seed 50f0 (* 5f0 fi))
                                     (/ (- dz) hl) 0f0 (/ dx hl) 3)))))))))
      (with-cam (crx cry crz cux cuy cuz)                 ; (round 2b: the climbers here are the sea's bone dead, not the tower's ink
        (when (and (<= 96 cf) (< cf 246))                 ;  climbers, which read as black bombs on the climax frames)
          (let* ((e (camera-eye *camera*)) (ux (- (aref e 0) qx)) (uz (- (aref e 2) qz)) (ul (f-max 0.01f0 (f-hypot ux uz))))
            (declare (type f32vec e) (single-float ux uz ul))   ; 14 of the dead reaching in from every side behind him, drawn in at the end
            (dotimes (i 14)
              (let* ((fi (i->f i)) (h (hash01 fi 5.3f0)) (fr (+ 96f0 (* 2f0 (i->f (mod (* 5 i) 14))))) (u (f-clamp (/ (- c fr) 10f0) 0f0 1f0))
                     (an (+ (* 0.4488f0 fi) (* 0.3f0 h))) (ca (f-cos an)) (sa (f-sin an)))
                (declare (single-float fi h fr u an ca sa))
                (when (and (> u 0f0) (or (and (>= cf 130) (or (< cf 170) (>= cf 215)))   ; (not between him and the lens yet,
                                         (< (/ (+ (* ca ux) (* sa uz)) ul) (if (< cf 130) 0.7f0 0.35f0))))   ;  nor in the close-up)
                  (let* ((rr (* (+ 1.0f0 (* 0.5f0 h)) (- 1f0 (* 0.6f0 w))))
                         (y (+ (* -0.8f0 (- 1f0 (* u (- 2f0 u)))) -0.05f0 (* -0.2f0 h) (* 0.3f0 sink))))
                    (declare (single-float rr y))
                    (%ya-wight (+ qx (* rr ca)) y (+ qz (* rr sa)) (- ca) (- sa) (+ 1.15f0 (* 0.2f0 h)) 0.98f0 (+ seed (* 11f0 fi))
                               (+ (* 0.9f0 dr) (* 6.2832f0 h)) 2 1.0f0 t crx cry crz cux cuy cuz)))))))
        (when (and (<= 240 cf) (< cf 290))                ; the mound over the spot: rings of the bone dead heaped up, every arm
          (let* ((e1 (%ya-ease (/ (- c 240f0) 16f0))) (crum (f-clamp (/ (- c 266f0) 22f0) 0f0 1f0)) (h (* 1.6f0 e1))   ;  reaching up and in to
                 (yc (* h (- 1f0 (* 1.15f0 crum)))) (ce (camera-eye *camera*)) (ex (- (aref ce 0) qx)) (ez (- (aref ce 2) qz)))   ;  the crest, the
            (declare (single-float e1 crum h yc ex ez) (type f32vec ce))                                                   ;  near half drawn;
            (when (> h 0.1f0)                                                                                               ;  crumbling from the top
              (dotimes (j 5)
                (let* ((fj (i->f j)) (y0 (* h (/ (+ fj 0.2f0) 5f0))) (q (/ y0 h)) (r (+ (* 1.1f0 (- 1f0 q) (+ 1f0 (* 0.3f0 q))) 0.12f0))
                       (m (max 2 (f->i (/ (* 6.2832f0 r) 0.42f0)))))
                  (declare (single-float fj y0 q r) (fixnum m))
                  (dotimes (i m)
                    (let* ((fi (i->f i)) (hs (hash01 (+ fi (* 7f0 fj)) (+ seed 5f0)))
                           (an (+ (* 6.2832f0 (/ (+ fi (* 0.5f0 (i->f (logand j 1))) (* 0.3f0 hs)) (i->f m))) (* 1.6f0 (- 1f0 e1) (- 1f0 q))))
                           (ca (f-cos an)) (sa (f-sin an)) (f (if (> y0 yc) (f-clamp (/ (- y0 yc) (* 0.25f0 h)) 0f0 1f0) 0f0)))
                      (declare (single-float fi hs an ca sa f))
                      (when (and (< f 0.98f0) (> (+ (* ca ex) (* sa ez)) (* (if (>= cf 260) -0.2f0 -0.7f0) (f-hypot ex ez))))
                        (%ya-wight (+ qx (* r ca)) (- y0 (* 0.35f0 (- 1f0 q)) (* 0.8f0 f)) (+ qz (* r sa)) (- ca) (- sa) (+ 0.9f0 (* 0.25f0 hs))
                                   (* 0.98f0 (- 1f0 f)) (+ seed (* 13f0 fj) fi) (+ (* 0.9f0 dr) (* 6.2832f0 hs)) (if (> hs 0.75f0) 2 1)
                                   (+ 0.6f0 (* 0.5f0 (- 1f0 q))) t crx cry crz cux cuy cuz)))))))
          (%ya-tower-ash qx qz h 1.1f0 crum rdt)
          (when (and (>= cf 248) (< cf 266))              ; one last hand out of its crest
            (%ya-bone-hand (+ qx (* 0.1f0 rx)) (* 0.9f0 h) (+ qz (* 0.1f0 rz)) (* 0.33f0 rx) 0.89f0 (* 0.33f0 rz) 0.6f0 0.035f0 0.98f0
                           (+ seed 60f0) fx 0f0 fz 3)))))
      (when (and (<= 260 cf) (< cf 282))                  ; the Konpaku: ember light and cracks from under the mound
        (let ((g (- 1f0 (/ (- c 260f0) 22f0))))
          (declare (single-float g))
          (%ya-crack-star qx qz 1.1f0 (* 0.98f0 g) 0.98f0 (+ seed 9f0))
          (%light qx 0.3f0 qz 1f0 0.3f0 0.12f0 5f0 (* 2f0 g) 6)))
      (when (>= cf 260)                                   ; ash falling over the plaza
        (dotimes (i (n-of 70f0 rdt))
          (%t-blob (+ qx (rnd-range -7f0 7f0)) (rnd-range 1.5f0 4.5f0) (+ qz (rnd-range -7f0 7f0)) (rnd-range -0.2f0 0.2f0) -0.35f0
                   (rnd-range -0.2f0 0.2f0) (rnd-range 1.4f0 2.2f0) (rnd-range 0.04f0 0.09f0) 0.08f0 0.25f0 +pal-ash+)))))
  nil)

(defun yama-minami-walk (a v)
  "南's walk, one step (f131 on): he walks away from the victim 0.02 m a frame, his back to him (his place is given back at CINE-END)."
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((p (pos-of a))) (setf (aref p 0) (- px (* 0.02f0 fx)) (aref p 2) (- pz (* 0.02f0 fz))))))

(defun yama-minami-top (a v)
  "南's f215 shot (§36; f160 before §37): high over the victim, looking down 50 deg from the old man's side (round 2: 23 deg off vertical read as
bubbles; at 50 deg the dead and their raised hands show in profile), the sea flowing in round him. A CINE-CAM with no subject (as
YAMA-NISHI-TRACK): %KEEP-SUBJECT would move it on a phone."
  (setf *cine-close* nil *cine-subject* nil)
  (%ya-line (px pz qx qz fx fz rx rz d) a v
    (let ((hh (if (portrait-p) 6.6f0 5.6f0)))
      (declare (single-float hh))
      (cine-cam (- qx (* 0.84f0 hh fx)) hh (- qz (* 0.84f0 hh fz)) qx 0.3f0 qz))))

(defcine yama-minami-cine (a v :len 300 :hold 188)
  "火火十万億死大葬陣 DAISOJIN, the Bankai's 南 Kikon (DUEL_YAMA_CORE §15.3.3, §19; re-boarded §36, the user 2026-11-22: 「南的毀魂技我希望
呈現從地底湧出數以萬計的骷髏，並從四面八方將對手逐漸拖入地下覆蓋」): beat 0, the blade upright before his face; close and low in front,
the incantation, the blade splitting his face, the two-column stamp; from high in front, the blade driven down and the cracks racing out
from it across the whole plaza; low at the victim the ground boils, the dead breaking out in rings from the outside in, hands from every
side on his ankles, knees and sword arm, and he starts to sink; in front of the old man, long lens: he has turned his back and walks
toward us while behind him the whole plaza is a sea of the dead, the victim small in it, sunk to his waist; close on him (§37, the user
2026-11-22: 「請放慢被吞噬的速度並給對手增加掙扎的特寫」) he struggles, pushing on the floor, one arm reaching up, the torso wrenching,
while bone hands climb his shoulders, arms and throat and yank him down to the chest in three tugs; from high above the sea
flows in from every side until only his head and a reaching hand are left and he goes under, the dead heaping over the spot; the
Konpaku, unseen by him: ember light from under the mound, an ash burst; wide and high, the sea sinks back into the ground, ash falling,
the victim lies in the cracks, he walks on."
  (at 0 (cine-place a v 5.0) (setf (aref *ya-sea* 0) (body-hurt-h (model-body (model v))))
      (cine-clip a :ya-kaka :blend 2 :time (/ 16.0 60.0) :speed 0.0) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (cine-grade :spot))
  (at 12 (shot-on a 15 2.2 1.0 :look 1.45 :off 0.6) (lens 50 6) (silence 38) (play-sfx :awaken-rise :pitch 0.5 :gain 0.6)
      (caption "火火十万億死" :kanji2 "大葬陣" :mark "南" :reading "DAISOJIN" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (at 48 (cine-clip a :ya-kaka :blend 0 :time (/ 19.0 60.0)))   ; lifted on f19, driven down f20-21: in the plaza on f51
  (at 50 (shot-on a 0 4.0 4.5 :look 0.0 :ahead 1.5) (lens 44))
  (at 51 (play-sfx :ground-crack) (shake 0.3 0.4))
  (at 296 (%ya-line (px pz qx qz fx fz rx rz d) a v      ; the ember cracks along the line (the stage's marks, kept for the round): laid
            (dolist (s '(3.4 2.2 1.0)) (stage-crack-add (- qx (* s fx)) (- qz (* s fz)) 0.9))))   ;  once the sea has gone (round 2:
                                                                                                     ;  they drew over it); f51's places
  (at 60 (cine-clip a :ya-kaka :blend 2 :time (/ 30.0 60.0) :speed 0.0)   ; kneeling, the point in the plaza
      (shot-on v 35 (if (portrait-p) 6.6 4.6) 0.45 :look 0.55) (lens 40)
      (cine-clip v :sh-bound :blend 6) (play-sfx :ground-crack :pitch 0.6 :gain 0.6) (play-sfx :bones))
  (at 68 (play-sfx :bones :pitch 0.9)) (at 76 (play-sfx :bones :pitch 1.1)) (at 84 (play-sfx :bones :pitch 0.8))
  (at 92 (play-sfx :bones :pitch 1.0))
  (when step-p (setf (aref (pos-of v) 1) (%ya-sink (aref *ya-sea* 0) (i->f cf))))   ; dragged under (given back at CINE-END)
  (at 130 (setf (transform-yaw (transform a)) (f32 (+ (yaw-of a) 3.1415927)))   ; his back to the victim
      (cine-clip a :sh-walk-f :blend 8 :speed 0.55)
      (shot-on a 20 9.0 2.0 :look 1.0) (lens 26) (play-sfx :step :pitch 0.6) (play-sfx :bones :pitch 0.7))
  (when (and step-p (> cf 130)) (yama-minami-walk a v))
  (at 179 (play-sfx :step :pitch 0.6)) (at 228 (play-sfx :step :pitch 0.6)) (at 277 (play-sfx :step :pitch 0.6))
  (at 170 (shot-on v 25 (if (portrait-p) 3.0 2.4) 0.6 :look 0.55) (lens 45)   ; §37: the struggle, chest up, a 3/4 front at eye level
      (cine-clip v :sh-struggle :blend 3) (play-sfx :bones :pitch 0.8))       ;  (a fixed lens: he is seen to go down)
  (at 175 (play-sfx :bones :pitch 0.6) (shake 0.12 0.15))                     ; the three tugs (%YA-SINK)
  (at 190 (play-sfx :bones :pitch 0.7) (shake 0.15 0.15) (play-sfx :ground-crack :pitch 0.8 :gain 0.4))
  (at 205 (play-sfx :bones :pitch 0.5) (shake 0.18 0.2))
  (at 215 (yama-minami-top a v) (lens 36) (cine-clip v :sh-swallowed :blend 10) (play-sfx :bones :pitch 0.6))
  (at 236 (play-sfx :bones :pitch 0.5)) (at 250 (play-sfx :ground-crack :pitch 0.5 :gain 0.7))
  (at 260 (impact-frame :negative 2) (back-rim 6) (caption-exit)   ; (out before the wide: there he walks under its column)
      (%ya-line (px pz qx qz fx fz rx rz d) a v           ; (at the mound: the victim is under the floor)
        (vfx-konpaku-shatter qx 0.9f0 qz (fighter-kikon-n (fighter a)))
        (vfx-ash-burst qx 0.5f0 qz) (vfx-ash-burst (+ qx 0.5f0) 0.4f0 qz) (vfx-ash-burst qx 0.4f0 (+ qz 0.5f0)))
      (play-sfx :konpaku-shatter) (shake 0.35 0.4))
  (at 262 (impact-frame :manga 10))
  (at 266 (shot-pair a v 1 (if (portrait-p) 13.0 10.0) (if (portrait-p) 5.0 4.2)) (lens 44) (cine-clip v :sh-down :blend 0)
      (play-sfx :bones :pitch 0.5 :gain 0.6))
  (during (0 300) (yama-minami-look a v cf)))

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
