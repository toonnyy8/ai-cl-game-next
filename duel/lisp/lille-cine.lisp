;;;; lille-cine.lisp — Lille's HUD pips, sounds and cinematics (the four DEFCINEs: JILLIEL, KIKON, JILLIEL KIKON, TROMPETE) and their
;;;; looks (split out of lille-art.lisp 2026-10-21, refactor round 2). DEFSOUND and DEFCINE order is the slot / numbering order:
;;;; do not reorder them.
(in-package :duel)

;;; ================================================================ the HUD's pieces (barro-art.lisp's meter draws them)
(defparameter *c-lb-jade* (list 0.61 0.77 0.67 1.0) "The HUD's jade (the eye, MUJITTAI's outline; an ink tone).")

(defun-fast %lb-pip (state)
  "One eye pip (the reticle glyph: four arcs, four ticks pointing in) centred at *LB-HUD* [0 1], radius [2]: STATE 0
unspent (the shut eye ― in a white ring), 1 spent (the open eye in jade, a jade ring), 2 unspent and flashing."
  (declare (fixnum state))
  (let* ((v *lb-hud*) (cx (aref v 0)) (cy (aref v 1)) (r (aref v 2)) (ri (* 0.74f0 r))
         (cr (if (= state 1) 0.61f0 0.93f0)) (cg (if (= state 1) 0.77f0 0.93f0)) (cb (if (= state 1) 0.67f0 0.9f0))
         (ca (if (= state 2) (+ 0.4f0 (* 0.6f0 (%pulse (aref v 3) 6.0))) 1f0)))
    (declare (type f32vec v) (single-float cx cy r ri cr cg cb ca))
    (dotimes (q 4)                                       ; the four arcs (3 segments each, +-30 degrees)
      (dotimes (k 3)
        (let* ((a0 (+ (* 1.5707964f0 (i->f q)) (* 0.34906584f0 (i->f (- k 1))) -0.17453292f0)) (a1 (+ a0 0.34906584f0))
               (c0 (f-cos a0)) (s0 (f-sin a0)) (c1 (f-cos a1)) (s1 (f-sin a1)))
          (declare (single-float a0 a1 c0 s0 c1 s1))
          (%hq (+ cx (* r c0)) (+ cy (* r s0)) (+ cx (* r c1)) (+ cy (* r s1)) (+ cx (* ri c1)) (+ cy (* ri s1))
               (+ cx (* ri c0)) (+ cy (* ri s0)) cr cg cb ca))))
    (dotimes (q 4)                                       ; the four ticks pointing in, at the diagonals
      (let* ((a (+ 0.7853982f0 (* 1.5707964f0 (i->f q)))) (c (f-cos a)) (s (f-sin a)) (w (* 0.09f0 r))
             (x0 (+ cx (* 0.98f0 r c))) (y0 (+ cy (* 0.98f0 r s))) (x1 (+ cx (* 0.58f0 r c))) (y1 (+ cy (* 0.58f0 r s))))
        (declare (single-float a c s w x0 y0 x1 y1))
        (%hq (- x0 (* w s)) (+ y0 (* w c)) (+ x0 (* w s)) (- y0 (* w c)) (+ x1 (* w s)) (- y1 (* w c)) (- x1 (* w s)) (+ y1 (* w c))
             cr cg cb ca)))
    (if (= state 1)                                      ; the open eye: a jade almond, the dark pupil
        (progn (%hq (- cx (* 0.5f0 r)) cy cx (- cy (* 0.28f0 r)) (+ cx (* 0.5f0 r)) cy cx (+ cy (* 0.28f0 r)) 0.43f0 0.6f0 0.5f0 1f0)
               (%hrect (- cx (* 0.12f0 r)) (- cy (* 0.12f0 r)) (* 0.24f0 r) (* 0.24f0 r) 0.06f0 0.06f0 0.08f0 1f0))
        (%hrect (- cx (* 0.42f0 r)) (- cy (* 0.06f0 r)) (* 0.84f0 r) (* 0.12f0 r) cr cg cb ca))   ; the shut eye ―
    nil))

(defun lb-side-of (g) "The fighter whose gauges are G." (if (and *p1* (eq (gauges *p1*) g)) *p1* *p2*))

;;; ================================================================ his sounds (synthesized at startup; sounds.lisp's toolkit)
(defsound :lb-crack (:peak 0.95)                      ; the X-axis shot: a dry crack through everything, a low thump, a tail
  (let ((b (au-buf 1.0)))
    (au-mix! b (au-fnoise 0.025 :hp 2500 :decay 0.012) 0.0 1.0)
    (au-thump! b 0.0 180 45 0.05 0.18 0.9)
    (au-ping! b 0.0 1250 0.06 0.35 :glide 0.6)
    (au-mix! b (au-whoosh 0.5 4000 600 :q 1.5 :peak 0.12) 0.02 0.5)
    (au-reverb! b 0.3 :size 1.3)))

(defsound :lb-lock (:peak 0.6)                        ; the lock: a small dial click and a high glint (the line turns jade)
  (let ((b (au-buf 0.35)))
    (au-mix! b (au-fnoise 0.01 :bp 3000 :q 3 :decay 0.004) 0.0 0.8)
    (au-ping! b 0.005 2637 0.08 0.5)
    (au-ping! b 0.05 3951 0.1 0.3)
    b))

(defsound :lb-trumpet (:peak 0.85)                    ; 神の喇叭: a brass note swelling and rising a fourth (Trompete's tell)
  (let ((b (au-buf 1.8)) (pad (au-buf 1.8)))
    (au-render (pad) ((p1 0.0) (p2 0.0) (p3 0.0))
      (let ((f (* (au-sweep tt 233.0 311.0 1.6) (+ 1.0 (* 0.006 (au-sin (* 5.5 tt)))))))
        (au-ph+ p1 f) (au-ph+ p2 (* 1.5 f)) (au-ph+ p3 (* 2.0 f))
        (* (min 1.0 (* 2.0 tt)) (if (> tt 1.5) (* 3.3 (- 1.8 tt)) 1.0)
           (+ (au-saw p1) (* 0.5 (au-saw p2)) (* 0.3 (au-sqr p3))))))
    (au-svf! pad :lp :from 900 :to 4200 :q 1.2 :time 1.5)
    (au-mix! b pad 0.0 0.7)
    (au-reverb! b 0.35 :size 1.6)))

;;; ================================================================ the cinematics' looks (cosmetic; DURING forms)
(defun vfx-lb-reticle-view (v k)
  "万物貫通's reticle view: the eye mark round V's chest, facing the camera, closing as K goes 1 -> 0."
  (multiple-value-bind (x y z) (actor-point v 1.25)
    (let* ((eye (camera-eye *camera*)) (dx (- (aref eye 0) x)) (dy (- (aref eye 1) y)) (dz (- (aref eye 2) z))
           (dl (max 1e-3 (hypot dx dy dz))))
      (%lb-frame! *lb-m* (f32 x) (f32 y) (f32 z) (f32 (/ dx dl)) (f32 (/ dy dl)) (f32 (/ dz dl)) 0f0 1f0 0f0
                  (f32 (+ 0.45 (* 0.9 k))))
      (draw-weapon :lb-reticle-jade *lb-m*))))

(defun vfx-lb-shot-line (a k)
  "万物貫通's shot: the jade line from his muzzle along his facing, through everything to the wall, a white core, the muzzle's
cross flash; K its presence."
  (let* ((p (pos-of a)) (yaw (yaw-of a)) (ux (fwd-x yaw)) (uz (fwd-z yaw))
         (x (+ (aref p 0) (* 1.6 ux))) (z (+ (aref p 2) (* 1.6 uz))))
    (with-floats (x z ux uz k)
      (toon-ribbon (x 1.45f0 z) ((* 30f0 ux) 0f0 (* 30f0 uz)) ((* 0.09f0 k) (* 0.06f0 k)) :heat (1f0 0.8f0) :seed -81f0 :wob 0.02f0 :pal +pal-jade+
                   :k k :segs 2)
      (toon-ribbon (x 1.45f0 z) ((* 30f0 ux) 0f0 (* 30f0 uz)) ((* 0.035f0 k) (* 0.025f0 k)) :heat (1f0 1f0) :seed -82f0 :wob 0f0 :pal +pal-hit+ :k k
                   :segs 2)
      (fx-star x 1.45f0 z (* 0.1f0 k) (* 0.5f0 k) 4 0.785f0 0f0 0f0 0.05f0 83f0 +pal-hit+ k :push 0.3f0))))

(defun vfx-lb-cross-hole (v k)
  "万物貫通's hole: a cross of white light through V's silhouette (the muzzle's cross), K its presence."
  (multiple-value-bind (x y z) (actor-point v 1.2)
    (with-floats (x y z k)
      (with-cam (rx ry rz ux uy uz)
        (dotimes (i 4)
          (let* ((sx (if (< i 2) rx ux)) (sy (if (< i 2) ry uy)) (sz (if (< i 2) rz uz)) (sg (if (evenp i) 1f0 -1f0)))
            (declare (single-float sx sy sz sg))
            (fx-shard (+ x (* 0.32f0 sg sx)) (+ y (* 0.32f0 sg sy)) (+ z (* 0.32f0 sg sz)) (* sg sx) (* sg sy) (* sg sz)
                      0.8f0 0.09f0 0.02f0 (+ 31f0 (i->f i)) +pal-hit+ k :push 0.6f0)))
        (fx-star x y z 0.08f0 0.2f0 4 0.785f0 0f0 0f0 0.03f0 35f0 +pal-hit+ k :push 0.6f0)))))

(defun-fast vfx-lb-judge (a v cf)
  "The Kikon cinematic's lines and holes at its frame CF (decision 56's storyboard and Amendment 2; A Lille, V the
opponent), on its effect time (*LB-JUDGE-TIME*: slowed on the first three hits): each pierce's jade line (a white core)
flies from its hole (*LB-HOLES*) to V in *LB-JUDGE-FLY* frames, goes 3 m on through him over 2 more and fades over 5; a
star where it enters, growing over 3; from the hit a white hole in V (*LB-JUDGE-PIERCE*: facing the camera, pushed over
his silhouette), until the verdict (frame 268). From the frame alone: nothing outlives the cinematic. 0 B but its two
position reads."
  (declare (fixnum cf))
  (let* ((p (pos-of a)) (q (pos-of v)) (side (if (eql a *p1*) 0 1)) (hs *lb-holes*) (pp *lb-judge-pierce*)
         (sv *lb-judge-shots*) (tc (%lb-judge-t cf)) (fly (the single-float *lb-judge-fly*))
         (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2))) (dl (f-max 0.01f0 (f-hypot dx dz)))
         (rx (- (/ dz dl))) (rz (/ dx dl)) (qx (aref q 0)) (qy (aref q 1)) (qz (aref q 2)))   ; (his right, facing A)
    (declare (type f32vec p q hs pp) (type (simple-array fixnum (*)) sv) (fixnum side)
             (single-float tc fly dx dz dl rx rz qx qy qz))
    (when (< cf 268)
      (dotimes (n 48)
        (let ((sf (aref sv n)))
          (declare (fixnum sf))
          (when (<= sf cf)
            (let* ((o (* 3 n)) (u (aref pp o)) (tx (+ qx (* u rx))) (ty (+ qy (aref pp (+ o 1)))) (tz (+ qz (* u rz)))
                   (age (- tc (%lb-judge-t sf))) (sd (i->f n)))
              (declare (fixnum o) (single-float u tx ty tz age sd))
              (when (>= age fly)                         ; the hole, from the hit
                (fx-disc tx ty tz (aref pp (+ o 2)) 0.04f0 (+ 600f0 sd) +pal-hit+ 0.98f0 :push 0.35f0))
              (when (< age (+ fly 7f0))                  ; the line: flying, through him, fading
                (let* ((k (if (< age (+ fly 2f0)) 1f0 (- 1f0 (* 0.2f0 (- age fly 2f0)))))
                       (h (* 3 (+ (* 24 side) (%lb-judge-hole n))))
                       (x0 (aref hs h)) (y0 (aref hs (+ h 1))) (z0 (aref hs (+ h 2)))
                       (ax (- tx x0)) (ay (- ty y0)) (az (- tz z0)) (al (f-max 0.01f0 (f-hypot ax ay az)))
                       (e (if (< age fly) (/ age fly) (/ (+ al (* 3f0 (f-min 1f0 (* 0.5f0 (- age fly))))) al)))
                       (ex (* ax e)) (ey (* ay e)) (ez (* az e)))
                  (declare (single-float k x0 y0 z0 ax ay az al e ex ey ez) (fixnum h))
                  (toon-ribbon (x0 y0 z0) (ex ey ez) ((* 0.065f0 k) (* 0.05f0 k)) :heat (1f0 0.8f0) :seed (- -151f0 sd) :wob 0.02f0 :pal +pal-jade+
                               :k k :segs 2)
                  (toon-ribbon (x0 y0 z0) (ex ey ez) ((* 0.018f0 k) (* 0.014f0 k)) :heat (1f0 1f0) :seed (- -251f0 sd) :wob 0f0 :pal +pal-hit+ :k k
                               :segs 2)
                  (when (and (>= age fly) (< age (+ fly 3f0)))   ; the star where it enters, growing
                    (let ((g (+ 0.5f0 (* 0.25f0 (- age fly)))))
                      (declare (single-float g))
                      (fx-star tx ty tz (* 0.06f0 g) (* 0.3f0 g) 6 (* 0.9f0 sd) 0f0 0f0 0.1f0 (+ 700f0 sd) +pal-jade+
                               0.95f0 :push 0.4f0))))))))))
    nil))

(defun vfx-lb-horizon (a k)
  "神の喇叭's Kikon: the beam out of the bell, erasing the horizon (a wide gold band, a white core), K its presence."
  (let* ((p (pos-of a)) (yaw (yaw-of a)) (ux (fwd-x yaw)) (uz (fwd-z yaw))
         (x (+ (aref p 0) (* 2.0 ux))) (z (+ (aref p 2) (* 2.0 uz))))
    (with-floats (x z ux uz k)
      (toon-ribbon (x 1.7f0 z) ((* 70f0 ux) 1.2f0 (* 70f0 uz)) ((* 1.6f0 k) (* 6f0 k)) :heat (1f0 0.7f0) :seed -61f0 :wob 0.05f0 :pal +pal-gold+
                   :k (* 0.98f0 k) :k1 (* 0.9f0 k) :segs 4)
      (toon-ribbon (x 1.7f0 z) ((* 70f0 ux) 1.2f0 (* 70f0 uz)) ((* 0.6f0 k) (* 2.5f0 k)) :heat (1f0 1f0) :seed -62f0 :wob 0.05f0 :pal +pal-hit+
                   :k (* 0.95f0 k) :k1 (* 0.9f0 k) :segs 4)
      (fx-star x 1.7f0 z (* 0.4f0 k) (* 1.1f0 k) 12 (* 2f0 (fx-clock)) 0f0 0f0 0.12f0 63f0 +pal-gold+ k :push 0.6f0))))

;;; his extra brush glyphs (the cinematics' captions, §10): glyphs-extra.lisp

;;; ================================================================ the cinematics (moved from the old Lille's lille.lisp, 2026-10-13)
;;; His four (barro.lisp's kits and moves name them: the awakening, the base Kikon, the Jilliel Kikon, the owl Kikon);
;;; the old Lille's revival went with him.
;;; The cinematics (60 Hz, review-3 pacing: fewer, longer shots; unskippable; every shot SHOT-ON its subject). He wears
;;; white: the black card, the back-rim in his form's colour (jade, the owl's gold). Each script's looks are driven from
;;; its frame by LILLE-DRAW (lille-art.lisp: the wings unfolding, the jade turning gold, the trumpet forming), so a
;;; skipped or aborted script leaves nothing behind (CINE-END's REFRESH-LOOK restores his body).
(defcine lb-jilliel-cine (a v :len 186 :hold 90)
  "The awakening 神の裁き JILLIEL (§10.1, ch. 646): close on the face, the left eye shut under the mark, silence; the eye
opens, the mark flares jade, a 1 f negative; the black card, jade back-rim: 万物貫通 / THE X-AXIS, then the brush 神の裁き / JILLIEL as he becomes the column; the cocoon: eight wings unfold one pair per 8 f, the
halo draws itself; from below, the winged column hovering, the opponent small."
  (at 0 (setf (model-body (model a)) (find-body :lille) (model-weapon (model a)) :diagramm)   ; the base face first
      (cine-clip a :lb-stance :blend 0) (cine-clip v (kit-stance (kit-of v)) :blend 6)   ; (no held pose: the
      (hold-pose v 12) (freeze 12) (impact-frame :negative 2) (silence 30)                  ; gameplay one is Jilliel's)
      (shot-on a 14 0.95 1.74 :look 1.72) (lens 36))
  (during (0 30) (shot-on a 14 (- 0.95 (* 0.12 u)) 1.74 :look 1.72))
  (at 30 (impact-frame :negative 1) (play-sfx :lb-lock) (play-sfx :hoho-out))
  (during (30 60) (shot-on a 14 (- 0.83 (* 0.13 u)) 1.74 :look 1.73))
  (at 60 (card :black a) (back-rim 60 0.61 0.77 0.67) (shot-on a 20 4.4 0.9 :look 1.3 :off 0.9) (lens 42)
      (caption "万物貫通" :reading "THE X-AXIS" :sub "BANBUTSU KANTSU" :side 0)   ; (his rule's name: no eye, DUEL_LILLE_V2 §12)
      (play-sfx :awaken-rise :pitch 0.8))
  (at 92 (setf (model-body (model a)) (find-body :lille-jilliel) (model-weapon (model a)) nil)
      (cine-clip a :lb-w-fold :blend 4) (impact-frame :negative 1) (play-sfx :awaken-boom)
      (caption "神の裁き" :reading "JILLIEL" :sub "VOLLSTANDIG" :side 0))
  (at 120 (card nil) (caption-exit) (shot-on a 32 3.6 1.4 :look 1.9) (lens 55) (cine-clip a :lb-w-stance :blend 12)
      (play-sfx :hoho-out))
  (at 128 (play-sfx :hoho-out)) (at 136 (play-sfx :hoho-out))
  (during (120 160) (shot-on a 32 (+ 3.6 (* 0.8 u)) 1.4 :look 1.9))
  (at 160 (shot-on a 165 6.5 0.25 :look 2.2) (lens 62)))

(defcine lb-kikon-cine (a v :len 168 :hold 90)
  "The base Kikon 万物貫通 (§10.2, ch. 601-602): beat 0, the aim held; over his shoulder down the barrel, the reticle (the
eye mark) closing round him, silence; the shot: the jade line through everything; on him: his silhouette on the white
card, a cross-shaped hole of light through it, held; the Konpaku shatter; the last card 万物貫通 / THE X-AXIS."
  (at 0 (face-each-other a v) (cine-clip a :lb-aim :blend 2) (cine-clip v :sh-bound :blend 4)
      (hold-both a v 10) (impact-frame :negative 2) (play-sfx :lb-lock))
  (at 10 (if (portrait-p)                       ; over his shoulder, the barrel (portrait: from straight behind and above,
             (shot-on a 162 5.4 2.6 :look 1.2 :ahead 2.5)  ; his back low in the tall frame, the line rising to the reticle)
             (shot-on a 152 2.7 1.9 :look 1.4 :ahead 2.2))
      (lens 40) (silence 50))
  (during (10 60) (vfx-lb-reticle-view v (- 1.0 (/ (- cf 10) 50.0))))
  (at 60 (cine-clip a :lb-fire :blend 1) (impact-frame :negative 2) (play-sfx :lb-crack) (shake 0.25 0.3))
  (during (60 76) (vfx-lb-shot-line a (- 1.0 (/ (- cf 60) 16.0))))
  (at 66 (shot-on v 20 3.2 1.25 :look 1.2) (lens 50) (cine-clip v :sh-kikon-victim :blend 3) (card :white v) (silhouette-black v))
  (during (66 120) (vfx-lb-cross-hole v (min 0.95 (/ (- cf 64) 6.0))))
  (at 72 (hold-both a v 44) (silence 44))
  (at 118 (impact-frame :negative 2) (cine-shatter v 2)
      (play-sfx :konpaku-shatter) (shake 0.2 0.3))
  (at 122 (unsilhouette) (card nil) (impact-frame :manga 10))
  (at 130 (card :black a) (back-rim 38 0.61 0.77 0.67) (shot-on a 20 4.2 0.9 :look 1.25 :off 0.9) (lens 42)
      (cine-clip a :lb-stance :blend 8)
      (caption "万物貫通" :reading "THE X-AXIS" :sub "BANBUTSU KANTSU  KIKON" :side 0)))

(defparameter *lb-judge-gap* 6.0
  "The Jilliel Kikon cinematic stages him this far from the opponent (CINE-PLACE; his place given back at its end): its
shots are framed for it (the user, 2026-10-08: 「我發現是隨著進入毀魂技時兩個的距離而影響視角ㄟ」).")
(defparameter *lb-judge-head* 1.65 "LB-SHOT-BEHIND: the opponent's head, metres over his feet ...")
(defparameter *lb-judge-keep* 0.35
  "... kept at most this share of the frame's half-height below its centre (the letterbox's bar starts at 0.82), on a
landscape screen (a portrait one widens the lens and backs off: %PORTRAIT-DOLLY, its framing kept as the user liked it).")

(defun lb-shot-behind (v a back side h look)
  "A shot from behind V toward A (decision 56's acceleration beat): the camera BACK m behind V on the A -> V line, SIDE m to
its right (+), H high, aimed at A's body LOOK m up; A is the subject (kept in the frame), V a silhouette in a low corner."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (max 0.01 (hypot dx dz))) (ux (/ dx d)) (uz (/ dz d)))
    (setf *cine-close* nil *cine-subject* a)
    ;; V's head kept above the letterbox (its bar covers the frame's bottom 9 %): the aim tilted down, if need be, until
    ;; his head sits *LB-JUDGE-KEEP* of the half-height below the centre (the user, 2026-10-08: on a desktop he went off
    ;; the bottom)
    (let* ((ex (+ (aref q 0) (* back ux) (* side (- uz)))) (ez (+ (aref q 2) (* back uz) (* side ux)))
           (dl (max 0.5 (sqrt (+ (expt (- (aref p 0) ex) 2) (expt (- (aref p 2) ez) 2)))))
           (dv (max 0.5 (sqrt (+ (expt (- (aref q 0) ex) 2) (expt (- (aref q 2) ez) 2)))))
           (ev (atan (- (+ (aref q 1) *lb-judge-head*) h) dv))
           (ea0 (atan (- look h) dl))
           (ea (if (> (window-height) (window-width)) ea0
                   (min ea0 (+ ev (atan (* *lb-judge-keep* (tan (* 0.5 *lens-fov*)))))))))
      (cine-cam ex h ez (aref p 0) (+ h (* dl (tan ea))) (aref p 2)))))
(defparameter *lb-judge-giant* 3.0
  "The Jilliel Kikon cinematic draws Lille this many times his size in beats 4-6 (f192-277 since Amendment 2; decision
56's amendment, the user 2026-10-08: 「Lille 放大約 3 倍」「第 4 到 6 段」): a look, CINE-SCALE.")
(defun lb-shot-pierce (a v n ang dist)
  "Close on pierce N's point in V (*LB-JUDGE-PIERCE*, the Kikon cinematic's slowed hits, Amendment 2): the camera DIST m
from it at ANG degrees round V's facing (0 = on the side of A, whom he faces), a little above, looking at it."
  (let* ((p (pos-of a)) (q (pos-of v)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
         (d (max 0.01 (hypot dx dz))) (fx (/ dx d)) (fz (/ dz d)) (rx (- fz)) (rz fx)
         (pp *lb-judge-pierce*) (u (aref pp (* 3 n))) (y (+ (aref q 1) (aref pp (1+ (* 3 n)))))
         (tx (+ (aref q 0) (* u rx))) (tz (+ (aref q 2) (* u rz)))
         (c (cos (deg ang))) (sn (sin (deg ang))) (ex (- (* c fx) (* sn rx))) (ez (- (* c fz) (* sn rz))))
    (setf *cine-close* t *cine-subject* nil)
    (cine-cam (+ tx (* dist ex)) (+ y 0.15) (+ tz (* dist ez)) tx y tz)))

(defcine lb-jilliel-kikon-cine (a v :len 305 :hold 215)
  "The Jilliel Kikon 神の裁き (§10.4; decision 56's storyboard and its amendments, DUEL_LILLE §23.37): 1 open (0-40), low
and close in a slow orbit: the wings gathered round him and shaking, snapped open into a ring on f24 (a negative, a
shake), held; 2 the black card (40-90), 神の裁き, from behind him the opponent framed through the ring, the 24 holes
lighting one by one; 3 the first shots (90-192) on the stage: each fired from diagonally behind him or before him (a
recoil, a crack) and on its hit the slow motion (CINE-SLOW: the clips and effects at 1/5 for 40 f, 1/3 for 25 f, 1/2 for
15 f; the lines and holes on the same effect time, *LB-JUDGE-TIME*), the camera close on the pierce, orbiting;
4 the acceleration (192-242): the white card, the opponent a black silhouette, the lines faster and faster (48 pierces in
all, VFX-LB-JUDGE), each a white hole in him, the camera low behind him looking up at Lille drawn x3 (*LB-JUDGE-GIANT*,
beats 4-6), pushing in; 5 the riddled silhouette held in silence before the giant (242-262); 6 the verdict (262-277): low
beside the opponent, the giant's wings close down and on that frame (268) he shatters (合翼即碎), a manga frame; 7 the card
gone, Lille x1 again, a wide shot, the wings settling (277-305). His wings' gathering, ring, lit holes and close are
LILLE-DRAW's, from the frame (%LB-SP-DRIVE!)."
  ;; 1 open: gathered and shaking, the snap on f24, held
  (at 0 (cine-place a v *lb-judge-gap*) (cine-clip a :lb-w-judge-open :blend 0) (cine-clip v :sh-bound :blend 4)
      (play-sfx :awaken-rise) (shot-on a 20 3.6 0.45 :look 2.0) (lens 56))
  (during (0 40) (shot-on a (+ 20 (* 30 u)) (- 3.6 (* 0.3 u)) 0.45 :look 2.0))   ; (the slow orbit)
  (at 24 (impact-frame :negative 2) (shake 0.2 0.25) (play-sfx :lb-lock))
  ;; 2 the card (DIST from the aim, AHEAD on)
  (at 40 (card :black) (back-rim 50 0.61 0.77 0.67) (shot-on a 173 9.6 2.4 :look 1.8 :ahead 6.0) (lens 40)
      (caption "神の裁き" :reading "KAMI NO SABAKI" :sub "KIKON" :side 0) (silence 48))
  (during (40 90) (shot-on a 173 (- 9.6 (* 0.6 u)) 2.4 :look 1.8 :ahead 6.0))
  (at 78 (caption-exit))                                ; (its 0.3 s slice done before the slowed hits)
  ;; 3 the first shots: each fired in view, its hit slowed with the camera on the pierce
  (at 90 (card nil) (shot-on a 148 6.8 1.7 :look 1.9 :ahead 2.4) (lens 46))
  (at 96 (cine-clip a :lb-w-judge-shot :blend 0) (play-sfx :lb-crack) (shake 0.2 0.25))
  (at 99 (cine-slow 0.2) (cine-clip v :sh-kikon-victim :blend 2) (lb-shot-pierce a v 0 40 1.5) (lens 40))
  (during (99 139) (lb-shot-pierce a v 0 (+ 40 (* 30 u)) (- 1.5 (* 0.3 u))))
  (at 139 (cine-slow 1) (shot-on a -142 7.4 1.4 :look 1.9 :ahead 2.6) (lens 44))
  (at 143 (cine-clip a :lb-w-judge-shot :blend 0) (play-sfx :lb-crack) (shake 0.2 0.25))
  (at 146 (cine-slow 0.33333334) (cine-clip v :sh-kikon-victim :blend 2) (lb-shot-pierce a v 1 55 1.6) (lens 40))
  (during (146 171) (lb-shot-pierce a v 1 (+ 55 (* 25 u)) (- 1.6 (* 0.2 u))))
  (at 171 (cine-slow 1) (shot-on a 35 6.0 0.6 :look 2.0) (lens 50))
  (at 174 (cine-clip a :lb-w-judge-shot :blend 0) (play-sfx :lb-crack) (shake 0.2 0.25))
  (at 177 (cine-slow 0.5) (cine-clip v :sh-kikon-victim :blend 2) (lb-shot-pierce a v 2 120 1.3) (lens 40))
  (during (177 192) (lb-shot-pierce a v 2 (+ 120 (* 20 u)) (- 1.3 (* 0.15 u))))
  ;; 4 the acceleration: the white card, his silhouette; Lille drawn x3 (to f277: CINE-SCALE), from low behind the
  ;; opponent looking up past him at the giant (his head and shoulders in a lower corner), pushing in
  (at 192 (cine-slow 1) (card :white) (silhouette-black v) (impact-frame :negative 1) (cine-clip a :lb-w-judge-volley :blend 2)
      (cine-scale a *lb-judge-giant*) (lens 46) (lb-shot-behind v a 5.0 1.8 0.5 6.2))
  (during (192 242) (lb-shot-behind v a (- 5.0 (* 0.8 u)) (- 1.8 (* 0.2 u)) 0.5 (+ 6.2 (* 0.4 u))))
  (when (and step-p (<= 192 cf 241))                    ; a crack for the first shots, then every other one
    (let ((n (position cf *lb-judge-shots*))) (when (and n (or (< n 14) (evenp n))) (play-sfx :lb-crack :pitch (+ 1.0 (* 0.01 (- cf 192)))))))
  (during (90 268) (vfx-lb-judge a v cf))
  ;; 5 the still
  (at 242 (shot-on v 150 3.6 0.5 :look 2.3) (lens 50) (hold-both a v 20) (silence 20))   ; (his back, the giant beyond)
  ;; 6 the verdict: the wings close down; on that frame he shatters
  (at 262 (lens 46) (lb-shot-behind v a 4.6 -1.7 0.5 6.0) (cine-clip a :lb-w-judge-close :blend 0))   ; (the giant's wings
  (at 268 (impact-frame :manga 10) (cine-shatter v 3)   ;  close
      (play-sfx :konpaku-shatter) (shake 0.3 0.4))                                                                     ;  over him)
  ;; 7 the end: the card goes with the giant (he never stands on the stage x3)
  (at 277 (unsilhouette) (card nil) (cine-scale a 1) (shot-on a 110 8.5 1.5 :look 1.8) (lens 50)
      (cine-clip a :lb-w-stance :blend 14)))

(defcine lb-trompete-cine (a v :len 186 :hold 90)
  "The owl Kikon 神の喇叭 (§10.4): beat 0, the fist at the beak, the note; the trumpet forming over him; the sound card,
神の喇叭 / TROMPETE, silence; the beam erases the horizon; the Konpaku shatter; and then there is silence."
  (at 0 (face-each-other a v) (cine-clip a :lb-o-trompete :blend 2) (cine-clip v :sh-bound :blend 4)
      (hold-both a v 10) (impact-frame :negative 2) (play-sfx :lb-trumpet))
  (at 10 (shot-on a 30 3.6 2.6 :look 2.4) (lens 50))
  (at 60 (card :black a) (back-rim 50 0.72 0.6 0.35) (shot-on a 62 6.0 1.6 :look 2.2 :off 0.9) (lens 42)
      (caption "神の喇叭" :reading "TROMPETE" :sub "KAMI NO RAPPA  KIKON" :side 0) (silence 50))
  (at 110 (card nil) (caption-exit) (shot-on a 118 9.0 3.0 :look 2.0 :ahead 8.0) (lens 60) (impact-frame :negative 2)
      (play-sfx :explode) (shake 0.4 0.5) (ui-flash 1.0 0.95 0.8 0.8 2.5))
  (during (110 150) (vfx-lb-horizon a (min 0.98 (- 1.6 (/ (- cf 110) 25.0)))))
  (at 116 (cine-shatter v 4) (play-sfx :konpaku-shatter)
      (impact-frame :manga 10))
  (at 140 (silence 46) (shot-on a 30 8.5 1.0 :look 1.8) (lens 50) (cine-clip a (kit-stance (kit-of a)) :blend 10))
  (during (140 186) (setf *grade-desat* (min 0.5 (* 0.02 (- cf 140))))))
