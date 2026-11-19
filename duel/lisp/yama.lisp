;;;; yama.lisp — YAMAMOTO GENRYUSAI SHIGEKUNI on the core system (docs/duel/DUEL_YAMA_CORE.md; roster index 0). Batch 1 stage A
;;;; (§7.4): the Shikai RYUJIN JAKKA as a :core kit, §7.1's table: NA J1-J2-J3, three pointers (1 不知火 SHIRANUI, 2 城郭炎上
;;;; JOKAKU ENJO, 3 撫斬 NADEGIRI) of three NS segments each, AS1 / AS2 / AS3 of 1 / 2 / 3 segments, the SA TAIMATSU. Stage B adds
;;;; the heat gauge and 爆炎 (the seam: YAMA-SEG-X), stage C the Bankai (until then :no-awaken: Mod + P does nothing).
;;;; Fresh file: the old kit's frame data and hazard numbers only (`git show retired-kits:duel/lisp/yama.lisp`); its art and fire
;;;; looks are yama-art.lisp / yama-vfx.lisp. His fire is hazards (DUEL_CORE §2: a hazard is judged with the class of the segment
;;;; that fired it, spawned inside that segment so SPAWN-HAZARD freezes its class, SP scale and start tick at the fire frame):
;;;; :wave (the generic moving box), and three of his own kinds through YAMA-HZ: :ya-col (a column at a point, NS1b), :ya-ring (the
;;;; burning ring, no collision: crossing it burns, Y8; one at a time), :ya-dome (the walls closed on the ring, NS2c / AS2b).
(in-package :duel)

;;; ================================================================ knobs (debug 87000-87999, YAMA-DEBUG)
(defparameter *ya-walk* 3.2 "Walk m/s (the old kit's *WALK-YAMAMOTO*).")
(defparameter *ya-run* 8.0 "Run m/s (the old kit's *RUN-YAMAMOTO*).")
(defparameter *ya-mult* 1.0 "The Shikai's damage x (the kit's own; the core :mult below is DUEL_YAMA_CORE §7.4's 1.0, tuned by play).")
(defparameter *ya-taken* 1.0 "... and the damage it takes x.")
(defparameter *ya-ring-band* 0.25 "The burning ring's half width (m): a hurt cylinder within this of the circle is in the fire (Y8).")
(defparameter *ya-fire-h* 2.4 "How high his ground fire reaches (m): the ring, the column, the dome.")

;;; ================================================================ the Shikai RYUJIN JAKKA (§7.1)
;;; NA: the unmovable pivot. J1 HISEN (the old clip retimed: :clip-s 9 at S14, the opener's tell), J2 KAESHIBI, J3 TSUKABI's burning
;;; pommel (a stagger, no knockdown and no :ender push: the AS follows). Reach 1.0 / 0.96 / 0.88 as written, raised to *J-REACH-MIN*.
(defmove :ya-j1 :kind :quick :clip :ya-q1 :clip-s 9 :startup 14 :active 3 :recovery 12 :dmg 34 :adv-block -2
  :reach 1.0 :arc 100 :on-hit :flinch)
(defmove :ya-j2 :kind :quick :clip :ya-q2 :startup 8 :active 3 :recovery 13 :dmg 34 :adv-block -2
  :reach 0.96 :arc 100 :on-hit :flinch)
(defmove :ya-j3 :kind :quick :clip :ya-tsuka :startup 9 :active 3 :recovery 18 :dmg 42 :adv-block -4
  :reach 0.88 :arc 140 :on-hit :stagger)
;; a hazard segment's Kikon (§7.4, Ichigo's wave rule): its fire hit with the SP held, he flash-steps in and this cut is the follow-up,
;; classed as the segment (BUILD-CORE-CLASSES tags it): one copy per class
(defmove-copy :ya-ns-strike :ya-j1 :reach 1.6 :params (:follow-cap 40.0 :look :flash-step))
(defmove-copy :ya-as-strike :ya-ns-strike)

;;; ---------------------------------------------------------------- pointer 1 不知火 SHIRANUI: heavy damage, long reach
;; a: the thrust casts a spiral of fire down the lane (a :wave, 8 m); b: the "unknown fire", a column at the victim's bearing 4-7 m
;; ahead, the point taken on S, erupting 12 f later (:delay 13: a hazard spawned on frame S counts its first frame there), the
;; active window 13 so the eruption is inside it (no next segment before it); c: the tornado, a wide column travelling (a :wave)
(defmove :ya-n1a :kind :flash :clip :ya-f1 :clip-s 18 :startup 22 :active 2 :recovery 24 :reach 8.0
  :on-frame ((22 yama-wave-fire)) :callout "SHIRANUI"
  :params (:ns-next :ya-n1b :width 2.0 :speed 14.0 :range 8.0 :dmg 70 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove :ya-n1b :kind :flash :clip :ya-f2 :clip-s 22 :startup 16 :active 13 :recovery 20 :reach 7.0
  :on-frame ((16 yama-column-fire))
  :params (:ns-next :ya-n1c :near 4.0 :far 7.0 :radius 1.2 :delay 13 :dmg 70 :react :stagger :kikon-strike :ya-ns-strike))
(defmove :ya-n1c :kind :flash :clip :ya-sig :clip-s 40 :startup 18 :active 2 :recovery 30 :reach 8.0
  :on-frame ((18 yama-wave-fire))
  :params (:width 3.5 :speed 10.0 :range 8.0 :dmg 90 :react :knockback :kb 3.0 :look yama-tornado-look :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 2 城郭炎上 JOKAKU ENJO: control, the lane shaped by fire
;; a: the stream, a lance of fire down the lane (a :wave, 10 m); b: the ring lands round the victim at his bearing (3-8 m, r 1.6 m,
;; 90 f; one at a time; its burn :ring-dmg on a crossing, its SP the setup minimum); c: the walls close into a dome on the ring (it is
;; spent), or at his bearing when none stands
(defmove :ya-n2a :kind :flash :clip :ya-enjo :startup 20 :active 2 :recovery 22 :reach 10.0
  :on-frame ((20 yama-wave-fire)) :callout "JOKAKU ENJO"
  :params (:ns-next :ya-n2b :width 1.2 :speed 18.0 :range 10.0 :dmg 40 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove :ya-n2b :kind :flash :clip :ya-enjo :clip-s 20 :startup 16 :active 2 :recovery 20 :reach 8.0
  :on-frame ((16 yama-ring-fire))
  :params (:ns-next :ya-n2c :near 3.0 :far 8.0 :radius 1.6 :life 90 :hits 2 :ring-dmg 20 :react :flinch :sp-cost 10
           :kikon-strike :ya-ns-strike))
(defmove :ya-n2c :kind :flash :clip :ya-f3 :clip-s 22 :startup 18 :active 2 :recovery 30 :reach 8.0
  :on-frame ((18 yama-dome-fire))
  :params (:near 3.0 :far 8.0 :radius 1.6 :dmg 80 :react :crumple :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 3 撫斬 NADEGIRI: the finisher
;; a: the walking jab of the point; b: the closing step-cut; c: NADEGIRI, one snap, the hit on S (the split is a look 24 f later)
(defmove :ya-n3a :kind :flash :clip :ya-q2 :clip-s 8 :startup 18 :active 3 :recovery 18 :dmg 40 :reach 1.6 :arc 90 :slide 1.0
  :on-hit :stagger :callout "NADEGIRI" :params (:ns-next :ya-n3b))
(defmove :ya-n3b :kind :flash :clip :ya-q1 :clip-s 9 :startup 12 :active 3 :recovery 18 :dmg 50 :reach 1.6 :arc 110 :slide 2.0
  :on-hit :stagger :params (:ns-next :ya-n3c))
(defmove :ya-n3c :kind :flash :clip :ya-nadegiri :clip-s 20 :startup 14 :active 4 :recovery 34 :dmg 110 :reach 2.4 :arc 100
  :on-hit :crumple :on-frame ((14 yama-nade-split)))

;;; ---------------------------------------------------------------- the AS (as-by-press (1 2 3): J1 -> AS1, J2 -> AS2, J3 -> AS3)
;; AS1: the spiral thrust point-blank, stealing flash-step (:steal-fs 30, §7.4)
(defmove :ya-as1 :kind :sp :clip :ya-shiranui-throw :clip-s 2 :startup 10 :active 3 :recovery 24 :dmg 50 :reach 1.6 :arc 90
  :on-hit :knockdown :callout "SHIRANUI" :params (:steal-fs 30))
;; AS2: the ring snaps round him at the contact (40, its own hit; the ring left there) -> the dome on it (NS2c's copy: 60, a launch)
(defmove-copy :ya-as2b :ya-n2c :kind :sp :callout "JOKAKU ENJO"
  :params (:near 0.0 :far 8.0 :radius 1.6 :dmg 60 :react :launch :kikon-strike :ya-as-strike))
(defmove :ya-as2 :kind :sp :clip :ya-enjo :clip-s 20 :startup 12 :active 3 :recovery 16 :dmg 40 :reach 2.0 :arc 120
  :on-hit :stagger :on-land yama-ring-snap
  :params (:ns-next :ya-as2b :radius 1.6 :life 90 :hits 2 :ring-dmg 20 :react :flinch :kikon-strike :ya-as-strike))
;; AS3: the back cut -> the turning cut -> NADEGIRI (NS3c's copy: 110, a knockdown)
(defmove-copy :ya-as3c :ya-n3c :kind :sp :on-hit :knockdown :callout "NADEGIRI")
(defmove :ya-as3b :kind :sp :clip :ya-f1 :clip-s 18 :startup 10 :active 3 :recovery 16 :dmg 50 :reach 2.0 :arc 160
  :on-hit :stagger :params (:ns-next :ya-as3c))
(defmove :ya-as3 :kind :sp :clip :ya-q2 :startup 8 :active 3 :recovery 14 :dmg 40 :reach 1.8 :arc 120
  :on-hit :stagger :params (:ns-next :ya-as3b))
;; SA (J in an NS gap, any pointer): TAIMATSU, the halo of fire round him (360 deg, r 2.4 m; the old kit's S16 A8 R24); a turn move:
;; its armour is the class's (SA absorbs NA)
(defmove :ya-sa :kind :quick :clip :ya-taimatsu :startup 16 :active 8 :recovery 24 :dmg 55 :reach 2.4 :arc 360 :on-hit :stagger
  :callout "TAIMATSU")

(defkit :yamamoto :base
  :name "YAMAMOTO" :body :yamamoto :weapon :ryujin-jakka :stance :ya-stance
  :intro :ya-intro :win :ya-win :intro-callout "BANSHO ISSAI KAIJIN TO NASE" :intro-weapon (:ya-cane 81)
  :walk *ya-walk* :run *ya-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *ya-mult* :taken *ya-taken*
  :stun-tolerance 18.0                          ; (the old kit's: the old man stands a long beating)
  :commands (:q :ya-j1)
  :strings ((:ya-j1 :q :ya-j2) (:ya-j2 :q :ya-j3))
  :core (:ns (:ya-n1a :ya-n2a :ya-n3a) :as (:ya-as1 :ya-as2 :ya-as3) :sa :ya-sa
         :stances (:ya-shiranui :ya-st-enjo :ya-st-cane)   ; by pointer: the blade drawn back at the hip / the point held out / on the
                                                           ;  planted blade as on the cane (placeholders on the old poses, §8)
         :kikon-cines (soul-break-cine soul-break-cine soul-break-cine)   ; (placeholders: the storyboards come last, §7.4)
         :as-by-press (1 2 3)
         :ns-range ((3.0 7.0) (3.0 9.0) nil)   ; the CPU casts the spiral / the stream from range under pointers 1 / 2
         :no-awaken t                          ; (stage C: the Bankai; until then Mod + P does nothing)
         :mult 1.0)
  :hooks (:pose yama-pose :draw yama-draw :dmg-mult yama-dmg-mult))

;;; ================================================================ pure rules (host-tested: tests/duel-rules/yamamoto.lisp)
(defun ya-bearing-point (px pz qx qz near far)
  "Where his fire lands at the victim's bearing: from (PX PZ) toward (QX QZ), at the victim's distance clamped to NEAR .. FAR m, kept
inside the arena. Values x z."
  (let* ((dx (- qx px)) (dz (- qz pz)) (d (sqrt (+ (* dx dx) (* dz dz))))
         (r (max near (min far d))) (ux (if (> d 1e-4) (/ dx d) 0.0)) (uz (if (> d 1e-4) (/ dz d) 1.0)))
    (clamp-to-circle (+ px (* r ux)) (+ pz (* r uz)) (- *arena-radius* 0.5))))

(defun ya-ring-touch-p (cx cz r band tx tz tr)
  "Is a hurt cylinder at (TX TZ), radius TR, in the burning ring round (CX CZ) of radius R, BAND m either side of the circle (Y8: a
ring of fire, no collision; inside or outside it is free, crossing it burns)?"
  (<= (abs (- (sqrt (+ (expt (- tx cx) 2) (expt (- tz cz) 2))) r)) (+ band tr)))

(defun yama-seg-x (e mv)
  "The damage x a segment of E's (MV) carries, frozen when it starts (a hazard's when it fires): 1.0 in stage A. Stage B's heat boost
(DUEL_YAMA_CORE §3, §7.4: 1 + 0.3 x paid / 25) goes here; APPLY-HIT multiplies it with the SP short-pay x (SP-SCALE) and, for a hazard,
the SP x frozen at its fire frame (HAZARD-SP-SCALE)."
  (declare (ignore e mv))
  1.0)

(defun yama-dmg-mult (att def hw mv hazard d2)
  "KIT-HOOK :dmg-mult: a hazard's segment x as frozen at its fire frame (its data :x), else his own move's (YAMA-SEG-X)."
  (declare (ignore def hw d2))
  (if hazard (or (getf (hazard-data hazard) :x) 1.0) (yama-seg-x att mv)))

;;; ================================================================ his fire (hazards; the on-frame hooks of the moves above)
(defun yama-fire-hw (e dmg react)
  "The HITWIN of his fire: DMG, REACT, the move's :kb, a heavy hitstop."
  (make-hitwin :dmg dmg :react react :kb (or (move-param e :kb) 0.0) :hs *hitstop-heavy*))

(defun yama-fire (e kind x z &key (size 1.0) (life 30) (delay 0) (hits 1) (hot life) look hw)
  "Spawn his fire hazard KIND at (X Z), in his segment now (its class, SP scale, start tick: SPAWN-HAZARD's defaults), its segment x
frozen (YAMA-SEG-X: the data's :x); HOT: frames it may hit after its delay (then it is only a look)."
  (spawn-hazard kind e :x x :z z :yaw (yaw-of e) :size size :life life :delay delay :hits hits :look look :hook 'yama-hz
                       :hw hw :data (list :hot hot :x (yama-seg-x e (fighter-move (fighter e))))))

(defun yama-hz (h hz ev &optional tx ty tz tr th)
  "His fire's hazard hook: :step closes the hit after its HOT frames (the look stays); :touches is its shape."
  (declare (ignore h))
  (case ev
    (:step (when (and (<= (hazard-delay hz) 0) (>= (hazard-age hz) (getf (hazard-data hz) :hot 0)))
             (setf (hazard-hits-left hz) 0))
           nil)
    (:touches
     (and (<= ty *ya-fire-h*)
          (case (hazard-kind hz)
            (:ya-ring (ya-ring-touch-p (hazard-x hz) (hazard-z hz) (hazard-size hz) *ya-ring-band* tx tz tr))
            (t (cyl-cyl-hit-p (hazard-x hz) 0f0 (hazard-z hz) (hazard-size hz) (f32 *ya-fire-h*) tx ty tz tr th)))))))

(defun yama-wave-fire (e)
  "NS1a / NS1c / NS2a: a :wave from the move's :params (:width :speed :range :dmg :react :kb :look), 1 m ahead."
  (let ((speed (move-param e :speed)))
    (multiple-value-bind (x z) (ahead e 1.0)
      (spawn-hazard :wave e :x x :z z :yaw (yaw-of e) :speed speed :size (* 0.5 (move-param e :width))
                            :life (round (* 60 (/ (move-param e :range) speed))) :look (move-param e :look)
                            :hw (yama-fire-hw e (move-param e :dmg) (move-param e :react))
                            :hook 'yama-hz :data (list :hot 9999 :x (yama-seg-x e (fighter-move (fighter e)))))))
  (emit :sfx :whoosh-heavy e))

(defun yama-column-fire (e)
  "NS1b on S: the point at the victim's bearing (:near .. :far) taken now; the column erupts there :delay frames later, hot 6 frames."
  (let ((p (pos-of e)) (q (pos-of (opp-of e))))
    (multiple-value-bind (x z) (ya-bearing-point (aref p 0) (aref p 2) (aref q 0) (aref q 2) (move-param e :near) (move-param e :far))
      (yama-fire e :ya-col x z :size (move-param e :radius) :delay (move-param e :delay) :life 30 :hot 6 :look 'yama-column-look
                 :hw (yama-fire-hw e (move-param e :dmg) (move-param e :react))))))

(defun yama-live-ring (e)
  "E's burning ring now (a :ya-ring hazard entity), or NIL."
  (let ((found nil))
    (do-entities (h (hz hazard))
      (when (and (eq (hazard-kind hz) :ya-ring) (eql (hazard-owner hz) e) (< (hazard-age hz) (hazard-life hz))) (setf found h)))
    found))

(defun yama-ring-at (e x z)
  "A burning ring round (X Z) from the move's :params (:radius :life :hits :ring-dmg :react); one at a time: the old one goes out."
  (let ((old (yama-live-ring e))) (when old (destroy-entity old) (clog "~a ring out (one at a time)" (side-name e))))
  (yama-fire e :ya-ring x z :size (move-param e :radius) :life (move-param e :life) :hits (move-param e :hits)
             :look 'yama-ring-look :hw (yama-fire-hw e (move-param e :ring-dmg) (move-param e :react)))
  (clog "~a ring at ~,2f ~,2f" (side-name e) x z)
  (emit :sfx :explode e))

(defun yama-ring-fire (e)
  "NS2b on S: the ring lands round the victim at his bearing (:near .. :far)."
  (let ((p (pos-of e)) (q (pos-of (opp-of e))))
    (multiple-value-bind (x z) (ya-bearing-point (aref p 0) (aref p 2) (aref q 0) (aref q 2) (move-param e :near) (move-param e :far))
      (yama-ring-at e x z))))

(defun yama-ring-snap (e)
  "AS2a's hit (:on-land): the ring snaps round the victim where he stands."
  (let ((q (pos-of (opp-of e)))) (yama-ring-at e (aref q 0) (aref q 2))))

(defun yama-dome-fire (e)
  "NS2c / AS2b on S: the walls close into a dome on his ring (spent by it), or at the victim's bearing (:near .. :far) when none stands;
hot 4 frames."
  (let ((ring (yama-live-ring e)) (p (pos-of e)) (q (pos-of (opp-of e))))
    (multiple-value-bind (x z)
        (if ring
            (let ((hz (hazard ring))) (values (hazard-x hz) (hazard-z hz)))
            (ya-bearing-point (aref p 0) (aref p 2) (aref q 0) (aref q 2) (move-param e :near) (move-param e :far)))
      (when ring (destroy-entity ring))
      (clog "~a dome at ~,2f ~,2f~:[~; (on the ring)~]" (side-name e) x z ring)
      (yama-fire e :ya-dome x z :size (move-param e :radius) :life 40 :hot 4 :look 'yama-dome-look
                 :hw (yama-fire-hw e (move-param e :dmg) (move-param e :react)))
      (emit :sfx :explode e))))

(defun yama-nade-split (e)
  "NADEGIRI on S: the hit is the move's own; the split is a look, drawn 24 f later where the cut ran (§7.1, Y: a look only)."
  (multiple-value-bind (x z) (ahead e 0.4)
    (spawn-look e 'yama-nade-look :x x :z z :yaw (yaw-of e) :delay 24 :life 2))
  (emit :sfx :kikon-slash e))

;;; ================================================================ debug (87000-87999), probes
(defun yama-probe-line (tag)
  "A `duel probe yamamoto` line: P1's form, state, move, pointer, flash-step, his live ring; P2's state and Reishi; the distance."
  (let* ((f (fighter *p1*)) (r (yama-live-ring *p1*)) (hz (and r (hazard r))))
    (log-msg "duel probe yamamoto ~a t ~d p1 ~a ~a ~a ptr ~d fs ~,1f ring ~a | p2 ~a r~d | d ~,2f"
             tag *match-tick* (fighter-form f) (state-of *p1*) (and (fighter-move f) (mv-name (fighter-move f))) (fighter-ptr f)
             (gauges-fs (gauges *p1*)) (if hz (format nil "~,2f ~,2f age ~d" (hazard-x hz) (hazard-z hz) (hazard-age hz)) "-")
             (state-of *p2*) (gauges-reishi (gauges *p2*)) (fighter-dist f))))

(defun yama-debug (c)
  "His debug commands (docs/duel/DUEL_GAMEPLAY.md \"Debug commands\", 87000-87999): 87000+k human P1 Yamamoto vs an idle Kenpachi
(both CPUs off, full gauges), k / 10 m apart (k 0-199); 87200+n the same vs Ichigo (n 0) / Hisagi (1) 2.0 m apart; 87301-87303 P1's
pointer 1-3; 87400+n P1 starts his NS under the pointer (n 0) / J1 (1); 87410+i P1 starts NS segment i of NS1a b c NS2a b c (0-5) on
its own (CORE-START!: paid as a press); 87900 the probe line."
  (flet ((scene (c2 dist)
           (ensure-battle :yamamoto c2)
           (place *p1* *p2* dist)
           (full-gauges! *p1*) (full-gauges! *p2*)))
    (cond ((< c 87200) (scene :kenpachi (/ (- c 87000) 10.0)))
          ((< c 87300) (scene (if (= c 87200) :ichigo :hisagi) 2.0))
          ((<= 87301 c 87303) (setf (fighter-ptr (fighter *p1*)) (- c 87300)))
          ((= c 87400) (core-sp-start! *p1* (fighter *p1*)))
          ((= c 87401) (force-cmd *p1* :q))
          ((<= 87410 c 87415)                       ; (a segment on its own: the column without the wave first, the dome with no ring)
           (core-start! *p1* (find-move (nth (- c 87410) '(:ya-n1a :ya-n1b :ya-n1c :ya-n2a :ya-n2b :ya-n2c)))))
          ((= c 87900))
          (t (log-msg "duel yamamoto: no debug command ~d" c))))
  (yama-probe-line (format nil "cmd ~d" c)))
(define-debug-range (87000 87999) yama-debug)
