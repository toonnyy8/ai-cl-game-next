;;;; yama.lisp — YAMAMOTO GENRYUSAI SHIGEKUNI on the core system (docs/duel/DUEL_YAMA_CORE.md; roster index 0). Batch 1 stage A
;;;; (§7.4): the Shikai RYUJIN JAKKA as a :core kit, §7.1's table: NA J1-J2-J3, three pointers (1 不知火 SHIRANUI, 2 城郭炎上
;;;; JOKAKU ENJO, 3 撫斬 NADEGIRI) of three NS segments each, AS1 / AS2 / AS3 of 1 / 2 / 3 segments, the SA TAIMATSU. Stage B (§3, §7.2,
;;;; §7.4): the heat gauge (the kit meter, GAUGES-METER: a hit or a cancel adds, an NS segment spends for its boost) and 爆炎 GOKUEN (the
;;;; form :blaze, its own move set, entered / left at his next neutral; decay, the Reishi drain, free NS / AS, the cancel burn). Stage C (§4,
;;;; §7.3, §7.4): the Bankai ZANKA NO TACHI by the awakening (the form :bankai: 東 / 西 / 南 pointers, the marks an AS lands, 北 TENCHI KAIJIN
;;;; armed by the third distinct mark: a flag on his component, never a pointer value).
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
;; the heat gauge and 爆炎 (DUEL_YAMA_CORE §3; the lead's first numbers, 2026-11-19, tuned by play)
(defparameter *ya-heat-max* 100.0 "The heat gauge's top (§3 *ya-heat-max*): reaching it enters 爆炎 at his next neutral (§7.4).")
(defparameter *ya-heat-gain* '(:na 8.0 :sa 10.0 :as 12.0)
  "Heat a move of each class adds on its first hit or cancel (§3, Y1: 「命中或相消才加」; NS adds nothing, a whiff nothing). Once a move
(an AS: once a segment).")
(defparameter *ya-heat-ns* 25.0 "Heat each NS segment spends, or what is left when short (§3, Y2 / Y3; 爆炎's too, Y9).")
(defparameter *ya-heat-boost* 0.3 "A Shikai NS segment's damage x 1 + this x paid / *YA-HEAT-NS* (§3, Y3: in proportion to what it paid).")
(defparameter *ya-blaze-decay* 10.0 "Heat 爆炎 loses a second (§3: 10 s from full), live sim steps only (§7.4).")
(defparameter *ya-blaze-drain* 0.02 "爆炎's Reishi drain, a fraction of max a second (§3), never below 1 (Y4: BURN).")
(defparameter *ya-blaze-burn* 0.25 "爆炎's cancel burn: this x his cancelled move's base damage, at least 1, the opponent's Reishi never below 1 (Y10).")
(defparameter *ya-blaze-in-frames* 24 "爆炎's entry pose (§2 「told the user」: a short invulnerable pose at the next neutral), frames.")

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
  :on-frame ((0 yama-ns-start) (22 yama-wave-fire)) :callout "SHIRANUI"
  :params (:ns-next :ya-n1b :width 2.0 :speed 14.0 :range 8.0 :dmg 70 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove :ya-n1b :kind :flash :clip :ya-f2 :clip-s 22 :startup 16 :active 13 :recovery 20 :reach 7.0
  :on-frame ((0 yama-ns-start) (16 yama-column-fire))
  :params (:ns-next :ya-n1c :near 4.0 :far 7.0 :radius 1.2 :delay 13 :dmg 70 :react :stagger :kikon-strike :ya-ns-strike))
(defmove :ya-n1c :kind :flash :clip :ya-sig :clip-s 40 :startup 18 :active 2 :recovery 30 :reach 8.0
  :on-frame ((0 yama-ns-start) (18 yama-wave-fire))
  :params (:width 3.5 :speed 10.0 :range 8.0 :dmg 90 :react :knockback :kb 3.0 :look yama-tornado-look :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 2 城郭炎上 JOKAKU ENJO: control, the lane shaped by fire
;; a: the stream, a lance of fire down the lane (a :wave, 10 m); b: the ring lands round the victim at his bearing (3-8 m, r 1.6 m,
;; 90 f; one at a time; its burn :ring-dmg on a crossing, its SP the setup minimum); c: the walls close into a dome on the ring (it is
;; spent), or at his bearing when none stands
(defmove :ya-n2a :kind :flash :clip :ya-enjo :startup 20 :active 2 :recovery 22 :reach 10.0
  :on-frame ((0 yama-ns-start) (20 yama-wave-fire)) :callout "JOKAKU ENJO"
  :params (:ns-next :ya-n2b :width 1.2 :speed 18.0 :range 10.0 :dmg 40 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove :ya-n2b :kind :flash :clip :ya-enjo :clip-s 20 :startup 16 :active 2 :recovery 20 :reach 8.0
  :on-frame ((0 yama-ns-start) (16 yama-ring-fire))
  :params (:ns-next :ya-n2c :near 3.0 :far 8.0 :radius 1.6 :life 90 :hits 2 :ring-dmg 20 :react :flinch :sp-cost 10
           :kikon-strike :ya-ns-strike))
(defmove :ya-n2c :kind :flash :clip :ya-f3 :clip-s 22 :startup 18 :active 2 :recovery 30 :reach 8.0
  :on-frame ((0 yama-ns-start) (18 yama-dome-fire))
  :params (:near 3.0 :far 8.0 :radius 1.6 :dmg 80 :react :crumple :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 3 撫斬 NADEGIRI: the finisher
;; a: the walking jab of the point; b: the closing step-cut; c: NADEGIRI, one snap, the hit on S (the split is a look 24 f later)
(defmove :ya-n3a :kind :flash :clip :ya-q2 :clip-s 8 :startup 18 :active 3 :recovery 18 :dmg 40 :reach 1.6 :arc 90 :slide 1.0
  :on-hit :stagger :callout "NADEGIRI" :on-frame ((0 yama-ns-start)) :params (:ns-next :ya-n3b))
(defmove :ya-n3b :kind :flash :clip :ya-q1 :clip-s 9 :startup 12 :active 3 :recovery 18 :dmg 50 :reach 1.6 :arc 110 :slide 2.0
  :on-hit :stagger :on-frame ((0 yama-ns-start)) :params (:ns-next :ya-n3c))
(defmove :ya-n3c :kind :flash :clip :ya-nadegiri :clip-s 20 :startup 14 :active 4 :recovery 34 :dmg 110 :reach 2.4 :arc 100
  :on-hit :crumple :on-frame ((0 yama-ns-start) (14 yama-nade-split)))

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
         :mult 1.0)
  :awaken-form :bankai                         ; the Bankai ZANKA NO TACHI (stage C; 爆炎 inherits it: awakening there ends 爆炎, §3)
  :meter (:name "HEAT" :max 100 :label yama-hud-label)   ; the heat gauge (GAUGES-METER, 0-100; the plate's kit strip: lhud-plate.lisp)
  :hooks (:pose yama-pose :draw yama-draw :dmg-mult yama-dmg-mult
          :tick yama-tick :hit yama-hit :cancel yama-cancel))   ; heat, 爆炎 (stage B; the :blaze form inherits them)

;;; ================================================================ 爆炎 GOKUEN (§7.2): the kit :blaze, every move a variant (「變招」)
;;; The first build gives each its own move entry, a copy with new numbers (the art may diverge later; DEFMOVE-COPY carries every key, so
;;; each copy states its :params whole: no Shikai :ns-next leaks in). x1.3 where §7.2 gives no number (the lead's placeholders, §11 B).
;;; Bared to the waist (:yamamoto-bare). Entered at his next neutral after heat reaches 100 (the entry pose :ya-blaze-in), left at the next
;;; neutral after heat 0; NS / AS free of flash-step (:core :sp-free); every NS segment spends 25 heat at the move's fixed power (Y9).
(defmove :ya-blaze-in :kind :flash :clip :ya-hellfire :clip-s 57 :startup 23 :active 1 :recovery 0 :reach 0.0)   ; the entry pose (24 f)
(defmove-copy :ya-b-j1 :ya-j1 :dmg 40)          ; J1 / J2: the same clips (the flame trail: art), 40 / 40
(defmove-copy :ya-b-j2 :ya-j2 :dmg 40)
(defmove :ya-b-j3 :kind :quick :clip :ya-ikkotsu :startup 9 :active 3 :recovery 18 :dmg 55 :adv-block -4   ; J3 IKKOTSU, the fist
  :reach 0.88 :arc 100 :on-hit :stagger :callout "IKKOTSU")
;; NS1 不知火 x1.3; c: the tornado tracks him (:track 60 deg/s, YAMA-HZ)
(defmove-copy :ya-b-n1a :ya-n1a
  :params (:ns-next :ya-b-n1b :width 2.0 :speed 14.0 :range 8.0 :dmg 91 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n1b :ya-n1b
  :params (:ns-next :ya-b-n1c :near 4.0 :far 7.0 :radius 1.2 :delay 13 :dmg 91 :react :stagger :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n1c :ya-n1c
  :params (:width 3.5 :speed 10.0 :range 8.0 :dmg 117 :react :knockback :kb 3.0 :track 60.0 :look yama-tornado-look
           :kikon-strike :ya-ns-strike))
;; NS2 城郭炎上: a the stream x1.3; b the ring closes at once (b and c in one: the dome at his bearing, a stagger mid-route); c ENNETSU, the
;; pillars along the lane (a :wave drawn as columns)
(defmove-copy :ya-b-n2a :ya-n2a
  :params (:ns-next :ya-b-n2b :width 1.2 :speed 18.0 :range 10.0 :dmg 52 :react :stagger :look yama-wave-look :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n2b :ya-n2c :startup 16 :recovery 20 :on-frame ((0 yama-ns-start) (16 yama-dome-fire))
  :params (:ns-next :ya-b-n2c :near 3.0 :far 8.0 :radius 1.6 :dmg 80 :react :stagger :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n2c :ya-n2a :clip-s 20 :startup 18 :recovery 30 :callout "ENNETSU JIGOKU"
  :on-frame ((0 yama-ns-start) (18 yama-wave-fire))
  :params (:width 2.4 :speed 12.0 :range 9.0 :dmg 104 :react :crumple :look yama-tornado-look :kikon-strike :ya-ns-strike))
;; NS3 撫斬 x1.3; c the true NADEGIRI: 200, a long recovery (RoS's "huge opening", B)
(defmove-copy :ya-b-n3a :ya-n3a :dmg 52 :params (:ns-next :ya-b-n3b))
(defmove-copy :ya-b-n3b :ya-n3b :dmg 65 :params (:ns-next :ya-b-n3c))
(defmove-copy :ya-b-n3c :ya-n3c :dmg 200 :recovery 60 :callout "NADEGIRI")
;; AS1 / 2 / 3 x1.3 (free of flash-step: the kit's :sp-free)
(defmove-copy :ya-b-as1 :ya-as1 :dmg 65)
(defmove-copy :ya-b-as2b :ya-as2b :params (:near 0.0 :far 8.0 :radius 1.6 :dmg 78 :react :launch :kikon-strike :ya-as-strike))
(defmove-copy :ya-b-as2 :ya-as2 :dmg 52
  :params (:ns-next :ya-b-as2b :radius 1.6 :life 90 :hits 2 :ring-dmg 26 :react :flinch :kikon-strike :ya-as-strike))
(defmove-copy :ya-b-as3c :ya-as3c :dmg 143)
(defmove-copy :ya-b-as3b :ya-as3b :dmg 65 :params (:ns-next :ya-b-as3c))
(defmove-copy :ya-b-as3 :ya-as3 :dmg 52 :params (:ns-next :ya-b-as3b))
(defmove-copy :ya-b-sa :ya-sa :reach 3.2)        ; TAIMATSU r 3.2

(defkit :yamamoto :blaze :inherit :base
  :form-name "GOKUEN" :callout "GOKUEN" :body :yamamoto-bare :hide (:haori :kosode) :aura :hellfire :blade (:fire 1.3)
  :burn *ya-blaze-drain*                          ; the Reishi drain (YAMA-TICK through BURN-AMOUNT / BURN: never below 1, Y4)
  :commands (:q :ya-b-j1)
  :strings ((:ya-b-j1 :q :ya-b-j2) (:ya-b-j2 :q :ya-b-j3))
  :core (:ns (:ya-b-n1a :ya-b-n2a :ya-b-n3a) :as (:ya-b-as1 :ya-b-as2 :ya-b-as3) :sa :ya-b-sa
         :stances (:ya-shiranui :ya-st-enjo :ya-st-cane)
         :kikon-cines (soul-break-cine soul-break-cine soul-break-cine)
         :as-by-press (1 2 3)
         :ns-range ((3.0 7.0) (3.0 9.0) nil)
         :sp-free t                                   ; NS / AS free of flash-step, as in a burst (§3; KIT-SP-FREE-P)
         :also (:ya-blaze-in)                         ; (the entry pose, in the kit's table)
         :mult 1.0))

;;; ================================================================ the Bankai ZANKA NO TACHI (§4, §7.3, §7.4; batch 1 stage C)
;;; The awakening (Mod + P) as every kit: the kit :bankai (its own :core, no :inherit, no heat: YAMA-BANKAI-ENTER zeroes the meter, so heat
;;; leaves with the Shikai and an awakening in 爆炎 ends it). The TYBW battle dress, the charred blade ZANKA. Every clip an old one at the
;;; right reach (placeholders, §8); damage before :mult 1.0. A mark is fighter state (YSS-MARKS) given by an AS's first real hit (its
;;; :params :mark); the third distinct mark arms 北 (YSS-NORTH, a flag): the next NS / AS is 天地灰尽's (the :ns-pick / :as-pick hooks), which
;;; on its frame 0 clears the marks and takes pointer 3's Kikon profile (YAMA-NORTH-START); the pointer itself stays 1-3.
(defparameter *ya-bind-stun* 60 "南 NSa's bind: frames the victim's feet are held (the old kit's *BIND-STUN*; the lead's placeholder, §14).")
(defparameter *ya-wall-life* 90 "南 NSc's bone wall: frames it stands, stopping the opponent's waves (§7.3).")

;; NA: the fencer's lunge (§6, A): E-J1 S14 (its own clip at S14 since art K2: the opener's held tell) > E-J2 the rising backhand S7 >
;; E-J3 the dropped-knee thrust S8 (a stagger, no knockdown, no :ender push: the AS follows). Reach the old clips' drawn tips (1.52 / 1.59 /
;; 1.71). E-J1's :blend 4 (art K3, §18): it starts from any pointer's stance (a 1.83 m jump of the tip from 東's), so its first frames
;; fade in; a look only (PLAY-CLIP is MV-BLEND's one reader), the Kikon strikes below inherit it.
(defmove :ya-e-j1 :kind :quick :clip :ya-e-q1 :blend 4 :startup 14 :active 3 :recovery 12 :dmg 34 :adv-block -2
  :reach 1.52 :arc 100 :on-hit :flinch)
(defmove :ya-e-j2 :kind :quick :clip :ya-e-q2 :startup 7 :active 3 :recovery 13 :dmg 38 :adv-block -2
  :reach 1.59 :arc 100 :on-hit :flinch)
(defmove :ya-e-j3 :kind :quick :clip :ya-e-q3 :startup 8 :active 3 :recovery 18 :dmg 42 :adv-block -4
  :reach 1.71 :arc 60 :on-hit :stagger)
;; the hazard segments' Kikon strikes (one per class, §7.4); 北's wave has its own, carrying 天地灰尽's cinematic (the Kikon's cinematic is the
;; landing strike's :cine, round.lisp SETTLE-SOULS)
(defmove-copy :ya-e-ns-strike :ya-e-j1 :reach 1.6 :params (:follow-cap 40.0 :look :flash-step))
(defmove-copy :ya-e-as-strike :ya-e-ns-strike)
(defmove-copy :ya-e-n4-strike :ya-e-ns-strike :cine yama-tenchi-cine)

;;; ---------------------------------------------------------------- 1 東 KYOKUJITSUJIN: short, exact reach, the highest single hits
;; a: KYOKKO, the longest lunge (a 4.6 m line, slide 1.6); b: the sunrise, a rising cut out of the lunge; c: the tip touches the floor and the
;; line ahead is erased (a low line, 6 m)
(defmove :ya-e-n1a :kind :flash :clip :ya-e-kyokko :startup 20 :active 3 :recovery 26 :dmg 80 :adv-block -12 :slide 1.6
  :vol (:cap 0.2 4.6 1.1 0.3) :on-hit :stagger :callout "KYOKKO" :params (:ns-next :ya-e-n1b))
(defmove :ya-e-n1b :kind :flash :clip :ya-e-f2 :startup 14 :active 4 :recovery 24 :dmg 70 :adv-block -3 :slide 1.6
  :vol (:cap 0.2 1.56 1.3 0.35) :on-hit :stagger :params (:ns-next :ya-e-n1c))
(defmove :ya-e-n1c :kind :flash :clip :ya-kyoku :startup 18 :active 5 :recovery 26 :dmg 120 :adv-block -16
  :vol (:cap 0.2 6.0 0.3 0.4) :on-hit :knockback :kb 3.0 :callout "KYOKUJITSUJIN")
;; AS1: the tip-touch point-blank, stealing flash-step (30, §7.4); mark 東
(defmove :ya-e-as1 :kind :sp :clip :ya-e-as1 :startup 10 :active 3 :recovery 24 :dmg 50 :reach 1.6 :arc 90
  :on-hit :knockdown :callout "KYOKUJITSUJIN" :params (:steal-fs 30 :mark 1))

;;; ---------------------------------------------------------------- 2 西 ZANJITSU GOKUI: close pressure, armour, the burning body
;; a: SHONETSU, no swing: the garb flares, a burn round him (r 2 m, 2 hits x 45); b: the advance (slide 1.5) under the turn moves' armour
;; (f6 to S: an NA is absorbed, an AS still beats it, CORE-TURN-ARMOR-VERDICT), the burn round him its own NS hit; c: the counter-cut (Y11),
;; armoured the same way, always swinging (no catch: not a parry)
(defmove :ya-e-n2a :kind :flash :clip :ya-shonetsu :startup 16 :active 12 :recovery 24 :reach 2.0 :arc 360 :callout "SHONETSU JIGOKU"
  :hits ((16 18 :dmg 45 :on-hit :stagger) (26 28 :dmg 45 :on-hit :stagger)) :params (:ns-next :ya-e-n2b))
(defmove :ya-e-n2b :kind :flash :clip :ya-e-advance :startup 14 :active 3 :recovery 20 :dmg 40 :reach 2.0 :arc 360 :slide 1.5
  :on-hit :stagger :params (:ns-next :ya-e-n2c :turn-armor t))
(defmove :ya-e-n2c :kind :flash :clip :ya-e-gokui-cut :startup 12 :active 3 :recovery 24 :dmg 90 :adv-block -12 :slide 0.6
  :reach 2.0 :arc 120 :on-hit :knockback :kb 3.0 :callout "ZANJITSU GOKUI" :params (:turn-armor t))
;; AS2: the grab after the hit (40) > the flare throws him (70, a launch); mark 西
(defmove-copy :ya-e-as2b :ya-e-n2b :kind :sp :clip :ya-e-throw :startup 12 :recovery 24 :dmg 70 :slide 0.0 :on-hit :launch :params (:mark 2))
(defmove :ya-e-as2 :kind :sp :clip :ya-e-grab :startup 12 :active 3 :recovery 16 :dmg 40 :reach 1.6 :arc 120 :on-hit :stagger
  :callout "ZANJITSU GOKUI" :params (:ns-next :ya-e-as2b :mark 2))

;;; ---------------------------------------------------------------- 3 南 DAISOJIN: the dead rise
;; a: the plant: dead hands at the victim's bearing 4-10 m (r 1.2), the point taken on S, the hands 16 f later (:delay 17 inside A 17, as
;; NS1b's column: a Step after S dodges), a bind; b: the swarm crawls along the floor (a :wave, 6 m/s); c: the bone wall rises before him
;; (its fall the hit, a disc 3 m ahead, r 1.6) and stands *YA-WALL-LIFE* frames, stopping the opponent's waves (YAMA-HZ :ya-wall)
(defmove :ya-e-n3a :kind :flash :clip :ya-kaka :startup 22 :active 17 :recovery 20 :reach 10.0 :callout "DAISOJIN"
  :on-frame ((22 yama-column-fire))
  :params (:ns-next :ya-e-n3b :near 4.0 :far 10.0 :radius 1.2 :delay 17 :dmg 40 :react :bind :stun *ya-bind-stun*
           :kikon-strike :ya-e-ns-strike :look yama-hands-look))
(defmove :ya-e-n3b :kind :flash :clip :ya-e-minami-b :startup 16 :active 2 :recovery 22 :reach 8.0
  :on-frame ((16 yama-wave-fire))
  :params (:ns-next :ya-e-n3c :width 2.0 :speed 6.0 :range 8.0 :dmg 50 :react :stagger :look yama-swarm-look :kikon-strike :ya-e-ns-strike))
(defmove :ya-e-n3c :kind :flash :clip :ya-e-minami-c :startup 18 :active 2 :recovery 30 :reach 4.0
  :on-frame ((18 yama-wall-fire))
  :params (:ahead 3.0 :radius 1.6 :dmg 70 :react :crumple :kikon-strike :ya-e-ns-strike))
;; AS3: the hands seize at him (40, a stagger: a bind inside a combo would be a flinch, COMBO-STEP) > the swarm (50) > the pile collapses
;; (100, a knockdown); mark 南
(defmove :ya-e-as3c :kind :sp :clip :ya-e-as3c :startup 12 :active 3 :recovery 30 :reach 4.0 :on-frame ((12 yama-column-fire))
  :params (:near 0.0 :far 4.0 :radius 1.4 :delay 0 :dmg 100 :react :knockdown :mark 3 :kikon-strike :ya-e-as-strike :look yama-pile-look))
(defmove :ya-e-as3b :kind :sp :clip :ya-e-as3b :startup 10 :active 2 :recovery 18 :reach 6.0 :on-frame ((10 yama-wave-fire))
  :params (:ns-next :ya-e-as3c :width 2.0 :speed 8.0 :range 6.0 :dmg 50 :react :stagger :look yama-swarm-look :mark 3
           :kikon-strike :ya-e-as-strike))
(defmove :ya-e-as3 :kind :sp :clip :ya-e-as3a :startup 10 :active 3 :recovery 16 :reach 4.0 :callout "DAISOJIN"
  :on-frame ((10 yama-column-fire))
  :params (:ns-next :ya-e-as3b :near 0.0 :far 4.0 :radius 1.2 :delay 0 :dmg 40 :react :stagger :mark 3 :kikon-strike :ya-e-as-strike
           :look yama-hands-look))

;;; ---------------------------------------------------------------- 北 TENCHI KAIJIN (armed by the third mark; one move, NS or AS)
;; NS: flame gathers (S24), one enormous wave (4 m wide, 14 m), a knockdown; AS: the same cut point-blank (180), after any J count (the
;; :as-pick hook ignores the press count). Neither writes a pointer or a mark; frame 0 clears the marks (YAMA-NORTH-START)
(defmove :ya-e-n4 :kind :flash :clip :ya-e-tenchi :blend 4 :startup 24 :active 2 :recovery 30 :reach 14.0 :callout "TENCHI KAIJIN"
  :on-frame ((0 yama-north-start) (24 yama-wave-fire))
  :params (:width 4.0 :speed 20.0 :range 14.0 :dmg 220 :react :knockdown :look yama-north-look :north t :kikon-strike :ya-e-n4-strike))
(defmove :ya-e-as4 :kind :sp :clip :ya-e-f1 :startup 10 :active 2 :recovery 30 :dmg 180 :reach 2.4 :arc 110
  :on-hit :knockdown :callout "TENCHI KAIJIN" :cine yama-tenchi-cine :on-frame ((0 yama-north-start)) :params (:north t))
;; SA (J in an NS gap, any pointer): a short backhand at chest height (the old counter's clip, its home since art K3; it follows any NS
;; segment's S+A, six poses, so its frame 0 matches none: a blend over its fast wind-up drew a larger jump, DUEL_YAMA_CORE §18.3)
(defmove :ya-e-sa :kind :quick :clip :ya-w-counter :startup 6 :active 3 :recovery 24 :dmg 60 :adv-block -12 :slide 0.6 :reach 2.0 :arc 120
  :on-hit :stagger)

(defkit :yamamoto :bankai
  :awakening t :form-name "ZANKA NO TACHI" :name "YAMAMOTO" :body :yamamoto-tybw :hide (:haori) :weapon :zanka :stance :ya-e-stance
  :intro :ya-intro :win :ya-win :intro-callout "BANSHO ISSAI KAIJIN TO NASE" :intro-weapon (:ya-cane 81) :callout "ZANKA NO TACHI"
  :walk *ya-walk* :run *ya-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *ya-mult* :taken *ya-taken*
  :stun-tolerance 18.0 :grade :spot :aura :heat :blade (:embers 1.4)
  :smear 3                                      ; (the swing's smear: ink with an ember hairline, not REIATSU yellow: D4, art K2 §17)
  :cine yama-bankai-cine                        ; (the old kit's awakening cinematic: yama-cine.lisp)
  :enter-hook yama-bankai-enter                 ; heat leaves with the Shikai (§3)
  :meter (:name "ZANKA" :max 1)                 ; (its own: the HUD inherits no heat strip; no sim reads it)
  :commands (:q :ya-e-j1)
  :strings ((:ya-e-j1 :q :ya-e-j2) (:ya-e-j2 :q :ya-e-j3))
  :core (:ns (:ya-e-n1a :ya-e-n2a :ya-e-n3a) :as (:ya-e-as1 :ya-e-as2 :ya-e-as3) :sa :ya-e-sa
         :ns-extra (:ya-e-n4) :as-extra (:ya-e-as4)          ; 北: outside the pointer grammar, picked by the hooks (KIT CORE-ROUTES)
         :stances (:ya-st-higashi :ya-st-nishi :ya-st-minami) ; 東 the blade level across / 西 the arms open low / 南 the blade
                                                              ;  upright beside the face (art K2, DUEL_YAMA_CORE §17)
         :kikon-cines (soul-break-cine soul-break-cine soul-break-cine)   ; (placeholders: the storyboards come last; 北's: its moves' :cine)
         :as-by-press (1 2 3)
         :ns-range ((2.0 5.5) nil (4.0 9.0))   ; the CPU lunges KYOKKO from mid range, plants 南's hands from range
         :mult 1.0)
  :hooks (:pose yama-pose :draw yama-draw :hit yama-bk-hit :dmg-mult yama-dmg-mult   ; (its hazards carry x 1.0: no heat)
          :ns-pick yama-ns-pick :as-pick yama-as-pick :switch-ok yama-switch-ok :hud-tag yama-bk-tag
          :armored-fx yama-armored-fx                  ; (西's armour absorbing an NA: L9, a look, art K1; it replaces the spark, K3)
          :planted yama-planted))                      ; (the blade left in the plaza: the grab / throw, AS3b / AS3c; a look, art K3)

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

;; the heat gauge and 爆炎 (§3, §7.4): pure, of numbers; the sim's side below (YAMA-NS-START, YAMA-HIT, YAMA-CANCEL, YAMA-TICK)
(defun ya-heat-gain (heat cls)
  "Heat after a hit or a cancel of a move of class CLS (§3, Y1): + *YA-HEAT-GAIN*'s (NA 8, SA 10, an AS segment 12; NS / none 0), capped
at *YA-HEAT-MAX*."
  (min *ya-heat-max* (+ heat (getf *ya-heat-gain* cls 0.0))))

(defun ya-ns-spend (heat hit-p blaze)
  "An NS segment starting at HEAT (§3, §7.4; Y2 / Y3 / Y9): values (heat it pays, its damage x). It pays *YA-HEAT-NS* or what is left;
nothing when it has no hit of its own (HIT-P NIL: NS2b's ring). Its x: 1 + *YA-HEAT-BOOST* x paid / *YA-HEAT-NS* in the Shikai, 1 in
爆炎 (BLAZE: its variants are the strong set, the spend only shortens it)."
  (let ((paid (if hit-p (max 0.0 (min *ya-heat-ns* heat)) 0.0)))
    (values paid (if blaze 1.0 (+ 1.0 (* *ya-heat-boost* (/ paid *ya-heat-ns*)))))))

(defun ya-heat-refund (heat paid)
  "Heat after a cancelled NS segment gets back what it PAID (§7.4, the SP rule), capped at *YA-HEAT-MAX*."
  (min *ya-heat-max* (+ heat paid)))

(defun ya-blaze-decay (heat)
  "爆炎's heat after one live sim step: *YA-BLAZE-DECAY* a second, never below 0."
  (max 0.0 (- heat (/ *ya-blaze-decay* 60.0))))

(defun ya-form-next (form heat free)
  "The form change due now (§7.4: both ways latched to the next neutral): FREE (he can act) in the Shikai (:base) with HEAT at the top ->
:blaze; in 爆炎 with HEAT 0 -> :base; else NIL (mid-route the route ends in the kit it started in)."
  (cond ((not free) nil)
        ((and (eq form :base) (>= heat *ya-heat-max*)) :blaze)
        ((and (eq form :blaze) (<= heat 0.0)) :base)))

(defun ya-burn-amount (base)
  "爆炎's cancel burn of his cancelled move's BASE damage: *YA-BLAZE-BURN* of it, at least 1 (Y10; the Reishi floor is BURN's)."
  (max 1 (round (* *ya-blaze-burn* base))))

;; the Bankai's marks and 北 (§4, §7.4): pure, of numbers / flags; the sim's side below (YAMA-BK-HIT, YAMA-NORTH-START, the pick hooks)
(defun ya-mark-add (marks n)
  "The marks after AS N's first hit (§4, Y6: AS1 東, AS2 西, AS3 南): MARKS (bits 1 / 2 / 4) with mark N set (one already held stays one).
Values the marks, and T when all three are held (the third distinct mark: 北 armed)."
  (let ((m (logior marks (ash 1 (1- n))))) (values m (= m 7))))

(defun ya-north-pick (armed ns as)
  "The move an NS (NS) / AS (AS) press picks while 北 is ARMED: 天地灰尽's (its NS or AS move), else NIL (the pointer's, §7.4: the armed flag
replaces the pick, never the pointer)."
  (and armed (values ns as)))

(defun ya-north-start (marks armed)
  "A 北 move starts (§7.4: when it starts, not when it lands): values the marks 0 and the flag NIL (MARKS / ARMED ignored)."
  (declare (ignore marks armed))
  (values 0 nil))

(defun ya-switch-ok-p (armed in-north)
  "May he switch pointer (DUEL_SP §3)? Not while 北 is ARMED, nor in a 北 move (IN-NORTH: a switch out of its gap would skip it) (§7.4)."
  (not (or armed in-north)))

(defun yama-seg-x (e mv)
  "The damage x a segment of E's (MV) carries, frozen when it starts (YAMA-NS-START; a hazard's copied when it fires): his heat boost
(§3, §7.4: 1 + 0.3 x paid / 25) while MV is the NS segment the boost was stored for, else 1.0. APPLY-HIT multiplies it with the SP
short-pay x (SP-SCALE) and, for a hazard, the SP x frozen at its fire frame (HAZARD-SP-SCALE)."
  (let* ((s (and e (yss e))) (f (and s (fighter e))))
    (if (and f mv (eq mv (fighter-move f)) (= (yss-seg-t s) (fighter-cls-t f))) (yss-x s) 1.0)))

(defun yama-dmg-mult (att def hw mv hazard d2)
  "KIT-HOOK :dmg-mult: a hazard's segment x as frozen at its fire frame (its data :x), else his own move's (YAMA-SEG-X)."
  (declare (ignore def hw d2))
  (if hazard (or (getf (hazard-data hazard) :x) 1.0) (yama-seg-x att mv)))

;;; ================================================================ heat and 爆炎 in the sim (§3, §7.4)
;;; Heat is the kit meter (GAUGES-METER: 0 at each match's fresh fighter, kept through a Konpaku reset with the form). His own state: a
;;; component on his fighter entity (made on its first use), the NS segment's spend and boost, the gain / burn once-guards.
(defcomponent yss
  "Yamamoto's own state (YS): the heat bookkeeping (the NS segment that last spent: its start tick SEG-T, what it PAID, its damage X, whether
a cancel gave it BACK; the start tick of the move or segment that last gained heat, GAIN-T: once each; the tick of the last cancel burn,
BURN-T: once a step) and the Bankai's MARKS and NORTH (armed). On his fighter entity, so they live through every form change and Konpaku
reset for the match (§7.4)."
  (seg-t -1 :type fixnum) (paid 0f0 :type single-float) (x 1f0 :type single-float) (back nil)
  (gain-t -1 :type fixnum) (burn-t -1 :type fixnum)
  (marks 0 :type fixnum) (north nil))          ; the Bankai's marks (bits 東 1 / 西 2 / 南 4) and 北 armed (§4, §7.4): kept for the match
(defun ys (e)
  "E's heat state (his YSS component, attached on the first call: a new match's fighter gets a fresh one)."
  (or (yss e) (let ((st (make-yss))) (add-component e st) st)))

(defun yama-hud-label (g kit)
  "The kit meter's label (the plate's tag, read by the Lisp HUD as the kit strip's kind): HEAT in the Shikai, GOKUEN in 爆炎."
  (declare (ignore g))
  (if (eq (kit-form kit) :blaze) "GOKUEN" "HEAT"))

(defun yama-ns-start (e)
  "Every NS segment's frame 0 (:on-frame): the heat it spends and the damage x it carries, frozen now (§7.4; YA-NS-SPEND). A copy of an
NS segment played as an AS (AS2b, AS3c) spends nothing."
  (let ((f (fighter e)))
    (when (eq (fighter-cls f) :ns)
      (let* ((g (gauges e)) (s (ys e)) (heat (gauges-meter g)) (mv (fighter-move f)))
        (multiple-value-bind (paid x) (ya-ns-spend heat (plusp (mv-sp-damage mv)) (eq (fighter-form f) :blaze))
          (setf (gauges-meter g) (f32 (- heat paid))
                (yss-seg-t s) (fighter-cls-t f) (yss-paid s) (f32 paid) (yss-x s) (f32 x) (yss-back s) nil)
          (clog "~a HEAT ~a spends ~,1f x~,2f (heat ~,1f)" (side-name e) (mv-name mv) paid x (gauges-meter g)))))))

(defun yama-part (e mv hz)
  "Values class and start tick of E's part in a hit or a cancel: his hazard HZ (the segment that fired it), or his own move MV while he
is in it (not the Kikon's follow-up strike: Kikon strikes add nothing, §7.4); else NIL."
  (let ((f (fighter e)))
    (cond (hz (values (hazard-cls hz) (hazard-sp-src hz)))
          ((and mv (eq mv (fighter-move f)) (not (fighter-follow f))) (values (fighter-cls f) (fighter-cls-t f))))))

(defun yama-heat-gain! (e cls tick why)
  "E's move or segment of class CLS started on TICK hit or took part in a cancel (WHY): its heat (YA-HEAT-GAIN), once, in the Shikai only
(爆炎: no gain until it ends), never during his burst (§7.4 「burst hits add nothing」: as PAY-GAUGES gains nothing in one)."
  (let ((g (gauges e)) (s (ys e)))
    (when (and (eq (fighter-form (fighter e)) :base) (null (gauges-burst g)) (plusp (getf *ya-heat-gain* cls 0.0))
               (/= tick (yss-gain-t s)))
      (let ((h0 (gauges-meter g)))      ; ponytail: one guard (the last gainer); a segment's hazard hitting after a later one gained could add twice (AS2a's ring is spent by AS2b's dome first)
        (setf (yss-gain-t s) tick (gauges-meter g) (f32 (ya-heat-gain h0 cls)))
        (clog "~a HEAT +~,1f ~(~a~) ~a (heat ~,1f)" (side-name e) (- (gauges-meter g) h0) cls why (gauges-meter g))))))

(defun yama-hit (att def res hw mv hazard ranged)
  "KIT-HOOK :hit (the end of APPLY-HIT): a real hit of his NA / SA / AS adds its heat (Y1)."
  (declare (ignore def hw ranged))
  (when (member res '(:hit :counter))
    (multiple-value-bind (cls tick) (yama-part att mv hazard)
      (when cls (yama-heat-gain! att cls tick "hit")))))

(defun yama-cancel (e other mv hz)
  "KIT-HOOK :cancel (CORE-CANCEL-HOOK!): his move MV or hazard HZ took part in a cancel with OTHER. An NA / SA / AS adds its heat (Y1); a
cancelled NS segment gets back the heat it paid, once (§7.4); in 爆炎 OTHER is burnt (YAMA-BURN!, Y10)."
  (multiple-value-bind (cls tick) (yama-part e mv hz)
    (when cls
      (yama-heat-gain! e cls tick "cancel")
      (when (eq cls :ns) (yama-heat-back! e tick hz))
      (when (eq (fighter-form (fighter e)) :blaze) (yama-burn! e other mv hz)))))

(defun yama-seg-heat (e)
  "The heat E's NS segment in play paid and has not got back (0 for any other move): what a hazard it fires carries for its refund."
  (let* ((f (fighter e)) (s (yss e)))
    (if (and s (eq (fighter-cls f) :ns) (= (yss-seg-t s) (fighter-cls-t f)) (not (yss-back s))) (yss-paid s) 0f0)))

(defun yama-heat-back! (e tick hz)
  "A cancelled NS segment (started on TICK) gets back the heat it paid, once (§7.4): through its hazard HZ's own copy (data :heat, taken at
its fire frame, so a wave cancelled after the next segment started is still paid back; zeroed), else the segment's while it is the one in
play. Either way the other path is closed: the segment marked BACK, its live hazards' copies zeroed."
  (let* ((s (ys e)) (g (gauges e))
         (paid (cond (hz (getf (hazard-data hz) :heat 0f0))
                     ((and (= tick (yss-seg-t s)) (not (yss-back s))) (yss-paid s))
                     (t 0f0))))
    (when (plusp paid)
      (when (= tick (yss-seg-t s)) (setf (yss-back s) t))
      (when hz (setf (getf (hazard-data hz) :heat) 0f0))
      (do-entities (h (x hazard))
        (when (and (eql (hazard-owner x) e) (= (hazard-sp-src x) tick) (getf (hazard-data x) :heat))
          (setf (getf (hazard-data x) :heat) 0f0)))
      (setf (gauges-meter g) (f32 (ya-heat-refund (gauges-meter g) paid)))
      (clog "~a HEAT refund ~,1f (heat ~,1f)" (side-name e) paid (gauges-meter g)))))

(defun yama-burn! (e other mv hz)
  "爆炎's cancel burn (Y10): OTHER loses YA-BURN-AMOUNT of E's cancelled part's base damage (a hazard's hit, else the move's MV-SP-DAMAGE),
his Reishi never below 1 (BURN); no hitstun, no combo count. Once a step (a same-class tie's two verdicts)."
  (let ((s (ys e)))
    (unless (= (yss-burn-t s) *match-tick*)
      (let* ((base (cond (hz (if (hazard-hw hz) (hw-dmg (hazard-hw hz)) 0)) (mv (mv-sp-damage mv)) (t 0)))
             (n (ya-burn-amount base)) (g (gauges other)) (r0 (gauges-reishi g)))
        (setf (yss-burn-t s) *match-tick* (gauges-reishi g) (burn r0 n))
        (emit :sfx :explode other)
        (clog "~a GOKUEN BURN ~d (base ~d) on ~a: reishi ~d -> ~d" (side-name e) n base (side-name other) r0 (gauges-reishi g))))))

(defun yama-free-p (f)
  "Can F act (neutral, guarding or running, no input lock)? A form change waits for it (§7.4)."
  (and (member (fighter-state f) '(:idle :guard :run)) (zerop (fighter-lock f))))

(defun yama-tick (e f g)
  "KIT-HOOK :tick (GAUGE-SYSTEM: live sim steps only, no hitstop or cinematic): in 爆炎 outside its entry pose the heat decays
(YA-BLAZE-DECAY) and the Reishi drains (the form's :burn through BURN-AMOUNT / BURN, never below 1: Y4); then the form change due at his
next neutral (YA-FORM-NEXT): into 爆炎 (YAMA-BLAZE-IN!) or back to the Shikai, heat 0."
  (when (and (eq (fighter-form f) :blaze) (not (eq (fighter-move f) (find-move :ya-blaze-in))))
    (setf (gauges-meter g) (f32 (ya-blaze-decay (gauges-meter g))))
    (let ((r0 (gauges-reishi g)))
      (setf (gauges-reishi g) (burn r0 (burn-amount (gauges-reishi-max g) (kit-burn (fighter-kit f)) (gauges-burn-step g))))
      (incf (gauges-burn-step g))
      (when (and (> r0 1) (= (gauges-reishi g) 1)) (clog "~a GOKUEN drain held at reishi 1" (side-name e)))))
  (case (ya-form-next (fighter-form f) (gauges-meter g) (yama-free-p f))
    (:blaze (yama-blaze-in! e f g))
    (:base (set-form e :base)
     (setf (gauges-meter g) 0f0)
     (clog "~a GOKUEN over: the Shikai, heat 0" (side-name e)))))

(defun yama-blaze-in! (e f g)
  "Heat at the top and he is free: 爆炎 (§7.2), heat full, the entry pose (:ya-blaze-in, *YA-BLAZE-IN-FRAMES* invulnerable; the decay and
the drain wait for its end)."
  (set-form e :blaze)
  (setf (gauges-meter g) (f32 *ya-heat-max*))
  (start-move e (find-move :ya-blaze-in))
  (setf (fighter-invuln f) *ya-blaze-in-frames*)
  (emit :hellfire e)
  (clog "~a GOKUEN: the entry pose, invulnerable ~d f" (side-name e) *ya-blaze-in-frames*))

;;; ================================================================ his fire (hazards; the on-frame hooks of the moves above)
(defun yama-fire-hw (e dmg react)
  "The HITWIN of his fire: DMG, REACT, the move's :kb, a heavy hitstop."
  (make-hitwin :dmg dmg :react react :kb (or (move-param e :kb) 0.0) :hs *hitstop-heavy* :stun (move-param e :stun)))

(defun yama-fire (e kind x z &key (size 1.0) (life 30) (delay 0) (hits 1) (hot life) look hw)
  "Spawn his fire hazard KIND at (X Z), in his segment now (its class, SP scale, start tick: SPAWN-HAZARD's defaults), its segment x
frozen (YAMA-SEG-X: the data's :x); HOT: frames it may hit after its delay (then it is only a look)."
  (spawn-hazard kind e :x x :z z :yaw (yaw-of e) :size size :life life :delay delay :hits hits :look look :hook 'yama-hz
                       :hw hw :data (list :hot hot :x (yama-seg-x e (fighter-move (fighter e))) :heat (yama-seg-heat e)
                                        :mark (move-param e :mark))))

(defun yama-hz (h hz ev &optional tx ty tz tr th)
  "His fire's hazard hook: :step closes the hit after its HOT frames (the look stays); :touches is its shape."
  (declare (ignore h))
  (case ev
    (:step (when (and (<= (hazard-delay hz) 0) (>= (hazard-age hz) (getf (hazard-data hz) :hot 0)))
             (setf (hazard-hits-left hz) 0))
           (when (and (eq (hazard-kind hz) :ya-wall) (<= (hazard-delay hz) 0)) (yama-wall-stop hz))   ; 南's wall stops waves
           (let ((tr (getf (hazard-data hz) :track)) (o (hazard-target hz)))   ; 爆炎's tornado turns after him (deg / s)
             (when (and tr o)
               (let ((q (pos-of o)))
                 (setf (hazard-yaw hz) (turn-toward (hazard-yaw hz) (dir-yaw (- (aref q 0) (hazard-x hz)) (- (aref q 2) (hazard-z hz)))
                                                    (track-step tr))))))
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
                            :hook 'yama-hz :data (list :hot 9999 :x (yama-seg-x e (fighter-move (fighter e))) :heat (yama-seg-heat e)
                                              :track (move-param e :track) :mark (move-param e :mark)))))
  (emit :sfx :whoosh-heavy e))

(defun yama-column-fire (e)
  "NS1b on S (南's hands, NSa and AS3a / AS3c, the same way): the point at the victim's bearing (:near .. :far) taken now; the column
erupts there :delay frames later, hot 6 frames."
  (let ((p (pos-of e)) (q (pos-of (opp-of e))))
    (multiple-value-bind (x z) (ya-bearing-point (aref p 0) (aref p 2) (aref q 0) (aref q 2) (move-param e :near) (move-param e :far))
      (yama-fire e :ya-col x z :size (move-param e :radius) :delay (move-param e :delay) :life 30 :hot 6
                 :look (or (move-param e :look) 'yama-column-look)
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

(defun yama-wall-fire (e)
  "南 NSc on S: the bone wall rises before him and falls forward: its hit (:dmg, :react) on a disc :ahead m out (r :radius, hot 4); the wall
itself a hitless :ya-wall 1.2 m out that stands *YA-WALL-LIFE* frames, stopping the opponent's waves (YAMA-WALL-STOP)."
  (multiple-value-bind (x z) (ahead e (move-param e :ahead))
    (yama-fire e :ya-col x z :size (move-param e :radius) :life 30 :hot 4 :look 'yama-fall-look   ; (the looks: yama-look.lisp, art K1)
               :hw (yama-fire-hw e (move-param e :dmg) (move-param e :react))))
  (multiple-value-bind (x z) (ahead e 1.2)
    (spawn-hazard :ya-wall e :x x :z z :yaw (yaw-of e) :size 1.6 :life *ya-wall-life* :hook 'yama-hz :look 'yama-wall-look))
  (clog "~a bone wall (~d f)" (side-name e) *ya-wall-life*)
  (emit :sfx :ground-crack e))

(defun yama-wall-stop (wall)
  "His bone wall (a :ya-wall hazard) each step: every opponent :wave / :fireball whose centre comes within its half width + the wave's of it
is spent there (CORE-HAZARD-NOHIT! :absorb, as a classless blade cuts one: no refund, no exchange). His own hook, no shared machinery."
  (let ((owner (hazard-owner wall)))
    (do-entities (h (hz hazard))
      (when (and (not (eql (hazard-owner hz) owner)) (member (hazard-kind hz) '(:wave :fireball)) (<= (hazard-delay hz) 0)
                 (< (+ (expt (- (hazard-x hz) (hazard-x wall)) 2) (expt (- (hazard-z hz) (hazard-z wall)) 2))
                    (expt (+ (hazard-size wall) (hazard-size hz)) 2)))
        (clog "~a's bone wall stops ~a's ~(~a~)" (side-name owner) (side-name (hazard-owner hz)) (hazard-kind hz))
        (core-hazard-nohit! hz owner :absorb)
        (destroy-entity h)))))

;;; ================================================================ the Bankai in the sim (§4, §7.4): the marks, 北, the awakening
(defun yama-bankai-enter (e)
  "The Bankai's :enter-hook (SET-FORM, by the awakening): heat leaves with the Shikai (§3: 爆炎 ends, the Bankai has no heat)."
  (let ((g (gauges e)))
    (clog "~a ZANKA NO TACHI: heat ~,1f -> 0 (marks ~d, 北 ~:[off~;armed~])" (side-name e) (gauges-meter g) (yss-marks (ys e)) (yss-north (ys e)))
    (setf (gauges-meter g) 0f0)))

(defun yama-mark! (e n)
  "E's AS N landed: its mark (YA-MARK-ADD); the third distinct one arms 北."
  (let ((s (ys e)))
    (multiple-value-bind (m all) (ya-mark-add (yss-marks s) n)
      (unless (= m (yss-marks s))
        (setf (yss-marks s) m)
        (clog "~a MARK ~a (marks ~d)" (side-name e) (svref #("" "EAST" "WEST" "SOUTH") n) m))
      (when (and all (not (yss-north s)))
        (setf (yss-north s) t)
        (clog "~a NORTH armed (pointer ~d)" (side-name e) (fighter-ptr (fighter e)))))))

(defun yama-bk-hit (att def res hw mv hazard ranged)
  "The Bankai's KIT-HOOK :hit: a real hit of an AS segment (or of the hazard it fired) gives its :mark (§7.4: when the AS lands; a cancel,
a block or the Kikon's follow-up strike gives none; 北's AS has no mark)."
  (declare (ignore def hw ranged))
  (when (member res '(:hit :counter))
    (let ((f (fighter att)))
      (multiple-value-bind (cls tick) (yama-part att mv hazard)
        (declare (ignore tick))
        (let ((n (and (eq cls :as) (eq (fighter-form f) :bankai)
                      (if hazard (getf (hazard-data hazard) :mark) (getf (mv-params mv) :mark)))))
          (when n (yama-mark! att n)))))))

(defun yama-ns-pick (e f)
  "The Bankai's KIT-HOOK :ns-pick (CORE-SP-START!): 天地灰尽's NS while 北 is armed (YA-NORTH-PICK), else NIL (the pointer's)."
  (let ((s (yss e)))
    (and s (ya-north-pick (yss-north s) (kit-move (fighter-kit f) :ya-e-n4) nil))))

(defun yama-as-pick (e f n)
  "The Bankai's KIT-HOOK :as-pick (CORE-AS-START!): 天地灰尽's AS after any J count while 北 is armed, writing no pointer (values the move,
NIL); else NIL (AS N, writing N)."
  (declare (ignore n))
  (let ((s (yss e)))
    (when (and s (yss-north s))
      (values (nth-value 1 (ya-north-pick t nil (kit-move (fighter-kit f) :ya-e-as4))) nil))))

(defun yama-switch-ok (e f)
  "The Bankai's KIT-HOOK :switch-ok (CORE-SWITCH-OPEN-P): refused while 北 is armed or a 北 move is in play (YA-SWITCH-OK-P)."
  (let ((s (yss e)) (mv (fighter-move f)))
    (ya-switch-ok-p (and s (yss-north s)) (and mv (eq (fighter-state f) :move) (getf (mv-params mv) :north)))))

(defun yama-north-start (e)
  "A 北 move's frame 0 (§7.4): the marks clear and the flag drops (YA-NORTH-START), the pointer stays n (the third AS's write: 北 never
touched it), and the SP in play takes pointer 3's Kikon / Soul Break profile (§2 「told the user」; FIGHTER-SP-PTR)."
  (let ((f (fighter e)) (s (ys e)))
    (multiple-value-bind (m a) (ya-north-start (yss-marks s) (yss-north s))
      (setf (yss-marks s) m (yss-north s) a (fighter-sp-ptr f) 3))
    (clog "~a NORTH ~a: marks cleared, pointer ~d (the Kikon profile 3)" (side-name e) (mv-name (fighter-move f)) (fighter-ptr f))))

(defparameter *ya-bk-tags* (vector nil "MARK 1" "MARK 2" "MARK 12" "MARK 3" "MARK 13" "MARK 23" "MARK 123")
  "The Bankai's plate tag by the marks held (bits 東 1 / 西 2 / 南 4): constant strings (the Lisp HUD remakes its strings only when the
tag changes, by EQ).")
(defun yama-bk-tag (e)
  "The Bankai's KIT-HOOK :hud-tag: NORTH while 北 is armed (lhud-data.lisp's \"ZANKA NO TACHI NORTH\" seals: every name 北 · TENCHI KAIJIN),
else the marks held (MARK 1 / 12 / ... : LHUD-MARKS draws them next to the pointer), else NIL."
  (let ((s (yss e)))
    (cond ((null s) nil) ((yss-north s) "NORTH") (t (svref *ya-bk-tags* (yss-marks s))))))

;;; ================================================================ debug (87000-87999), probes
(defun yama-probe-line (tag)
  "A `duel probe yamamoto` line: P1's form, state, move, pointer, flash-step, heat, Reishi, his live ring; P2's state and Reishi; the distance."
  (let* ((f (fighter *p1*)) (r (yama-live-ring *p1*)) (hz (and r (hazard r))))
    (log-msg "duel probe yamamoto ~a t ~d p1 ~a ~a ~a ptr ~d fs ~,1f heat ~,1f r~d marks ~d north ~:[-~;armed~] ring ~a | p2 ~a r~d | d ~,2f"
             tag *match-tick* (fighter-form f) (state-of *p1*) (and (fighter-move f) (mv-name (fighter-move f))) (fighter-ptr f)
             (gauges-fs (gauges *p1*)) (gauges-meter (gauges *p1*)) (gauges-reishi (gauges *p1*)) (yss-marks (ys *p1*)) (yss-north (ys *p1*))
             (if hz (format nil "~,2f ~,2f age ~d" (hazard-x hz) (hazard-z hz) (hazard-age hz)) "-")
             (state-of *p2*) (gauges-reishi (gauges *p2*)) (fighter-dist f))))

(defun yama-debug (c)
  "His debug commands (docs/duel/DUEL_GAMEPLAY.md \"Debug commands\", 87000-87999): 87000+k human P1 Yamamoto vs an idle Kenpachi
(both CPUs off, full gauges), k / 10 m apart (k 0-199); 87200+n the same vs Ichigo (n 0) / Hisagi (1) 2.0 m apart; 87301-87303 P1's
pointer 1-3; 87400+n P1 starts his NS under the pointer (n 0) / J1 (1); 87410+i P1 starts NS segment i of NS1a b c NS2a b c (0-5) on
its own (CORE-START!: paid as a press); 87500+h P1's heat h (h 0-100: 100 enters 爆炎 at his next neutral); 87700+r P1's Reishi r, 87800+r
P2's (r 1-99); 87900 the probe line; 87901 the phone's deck on (*ONE-HAND* as the setting would have it: a portrait window). The Bankai
(stage C): 87420+i P1 starts Bankai segment i of 東 a b c, 西 a b c, 南 a b c, 北's NS (0-9) on its own (CORE-START!; P1 in the Bankai);
87440 P1 awakens now (AWAKEN!, the cinematic); 87441-87443 P1 gets mark 東 / 西 / 南 (YAMA-MARK!: the third arms 北); 87444 P1's 北 armed
(all three marks); 87445 P1's marks and 北 cleared; 87446 P1 into the Bankai at once (no cinematic, awakened); 87447 a `duel yamamoto
switch` line: may P1 switch pointer now (CORE-SWITCH-OPEN-P). Art K1 (§16): 87430+i P1 starts Bankai AS segment i of AS1, AS2a / b, AS3a / b /
c, AS 北 (0-6) on its own (CORE-START!); 87437 an :armored event on P1 (FEEDBACK-SYSTEM only: 西's armour look); 87448 the consing of every
Bankai look (yama-look.lisp YAMA-LOOK-CONSING; art K2: the stances' garb / cracks and the smear too; art K3:
the planted blade, 北's burn, the :planted hook)."
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
          ((<= 87420 c 87429)
           (core-start! *p1* (kit-move (kit-of *p1*) (nth (- c 87420) '(:ya-e-n1a :ya-e-n1b :ya-e-n1c :ya-e-n2a :ya-e-n2b :ya-e-n2c
                                                                       :ya-e-n3a :ya-e-n3b :ya-e-n3c :ya-e-n4)))))
          ((<= 87430 c 87436)                       ; (art K1's stills: an AS segment on its own)
           (core-start! *p1* (kit-move (kit-of *p1*) (nth (- c 87430) '(:ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c
                                                                       :ya-e-as4)))))
          ((= c 87437) (let ((p (pos-of *p1*))) (emit :armored *p1* (aref p 0) 1.2 (aref p 2))))   ; (西's armour look, L9: an event only)
          ((= c 87440) (awaken! *p1*))
          ((<= 87441 c 87443) (yama-mark! *p1* (- c 87440)))
          ((= c 87444) (dolist (n '(1 2 3)) (yama-mark! *p1* n)))
          ((= c 87445) (let ((s (ys *p1*))) (setf (yss-marks s) 0 (yss-north s) nil)))
          ((= c 87446) (setf (gauges-awakened (gauges *p1*)) t) (set-form *p1* :bankai) (to-idle *p1* 0))
          ((= c 87448) (yama-look-consing))
          ((= c 87447) (log-msg "duel yamamoto switch t ~d open ~a north ~a" *match-tick* (and (core-switch-open-p *p1* (fighter *p1*)) t)
                                (yss-north (ys *p1*))))
          ((<= 87500 c 87600) (setf (gauges-meter (gauges *p1*)) (f32 (- c 87500))))
          ((<= 87701 c 87799) (setf (gauges-reishi (gauges *p1*)) (- c 87700)))
          ((<= 87801 c 87899) (setf (gauges-reishi (gauges *p2*)) (- c 87800)))
          ((= c 87900))
          ((= c 87901) (setf *one-hand* (one-hand-effective-p)))   ; (the phone's deck: run with --mobile --size 390x844)
          (t (log-msg "duel yamamoto: no debug command ~d" c))))
  (yama-probe-line (format nil "cmd ~d" c)))
(define-debug-range (87000 87999) yama-debug)
