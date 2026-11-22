;;;; yama.lisp — YAMAMOTO GENRYUSAI SHIGEKUNI on the core system (docs/duel/DUEL_YAMA_CORE.md; roster index 0). Batch 1 stage A
;;;; (§7.4): the Shikai RYUJIN JAKKA as a :core kit, §7.1's table: NA J1-J2-J3, three pointers (1 不知火 SHIRANUI, 2 城郭炎上
;;;; JOKAKU ENJO, 3 撫斬 NADEGIRI) of three NS segments each, AS1 / AS2 / AS3 of 1 / 2 / 3 segments, the SA TAIMATSU. Stage B (§3, §7.2,
;;;; §7.4): the heat gauge (the kit meter, GAUGES-METER: a hit or a cancel adds, an NS segment spends for its boost) and 爆炎 GOKUEN (the
;;;; form :blaze, its own move set, entered / left at his next neutral; decay, the Reishi drain, free NS / AS, the cancel burn). Stage C (§4,
;;;; §7.3, §7.4): the Bankai ZANKA NO TACHI by the awakening (the form :bankai: 東 / 西 / 南 pointers, the marks an AS lands). §30 (2026-11-21):
;;;; 西's NSa / NSb charge the garb (Ichigo's Getsuga charges: the string after their SA hits harder and further). §31-§33 (2026-11-22): 北
;;;; TENCHI KAIJIN is J4's AS4, its power by the marks held (no 北 form since §33).
;;;; Fresh file: the old kit's frame data and hazard numbers only (`git show retired-kits:duel/lisp/yama.lisp`); its art and fire
;;;; looks are yama-art.lisp / yama-vfx.lisp. His fire is hazards (DUEL_CORE §2: a hazard is judged with the class of the segment
;;;; that fired it, spawned inside that segment so SPAWN-HAZARD freezes its class, SP scale and start tick at the fire frame):
;;;; :wave (the generic moving box), and three of his own kinds through YAMA-HZ: :ya-col (a column at a point, NS1b), :ya-ring (the
;;;; burning ring, no collision: crossing it burns, Y8; one at a time), :ya-dome (the walls closed on the ring, NS2c / AS2b); 南's
;;;; skeleton tower (§30.3, §38): :ya-tower (hitless, one at a time) and :ya-fall (its topple, a 2 m wide line).
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
(defparameter *ya-blaze-ns-share* (/ 1.0 3.0)
  "爆炎's NS segment spends this share of *YA-HEAT-NS* (§32, the user 2026-11-22: 「始解進入爆炎狀態時，NS 消耗的量表太多了，請減少到 1/3」:
25 -> 8.33; was 1, Y9).")
(defparameter *ya-heat-boost* 0.3 "A Shikai NS segment's damage x 1 + this x paid / *YA-HEAT-NS* (§3, Y3: in proportion to what it paid).")
(defparameter *ya-blaze-decay* 10.0 "Heat 爆炎 loses a second (§3: 10 s from full), live sim steps only (§7.4).")
(defparameter *ya-blaze-drain* 0.02 "爆炎's Reishi drain, a fraction of max a second (§3), never below 1 (Y4: BURN).")
(defparameter *ya-blaze-burn* 0.25 "爆炎's cancel burn: this x his cancelled move's base damage, at least 1, the opponent's Reishi never below 1 (Y10).")
(defparameter *ya-blaze-in-frames* 24 "爆炎's entry pose (§2 「told the user」: a short invulnerable pose at the next neutral), frames.")

;;; ================================================================ the Shikai RYUJIN JAKKA (§7.1)
;;; NA: the unmovable pivot. J1 HISEN (its own clip at S14 with the opener's held tell, art S2; :blend 4: it starts from three stances),
;;; J2 KAESHIBI, J3 TSUKABI's burning
;;; pommel (a stagger, no knockdown and no :ender push: the AS follows). Reach 1.0 / 0.96 / 0.88 as written, raised to *J-REACH-MIN*.
(defmove :ya-j1 :kind :quick :clip :ya-hisen :blend 4 :startup 14 :active 3 :recovery 12 :dmg 34 :adv-block -2
  :reach 1.0 :arc 100 :on-hit :flinch)
(defmove :ya-j2 :kind :quick :clip :ya-q2 :startup 8 :active 3 :recovery 13 :dmg 34 :adv-block -2
  :reach 0.96 :arc 100 :on-hit :flinch)
(defmove :ya-j3 :kind :quick :clip :ya-tsuka :startup 9 :active 3 :recovery 18 :dmg 42 :adv-block -4
  :reach 0.88 :arc 140 :on-hit :stagger)
;; a hazard segment's Kikon (§7.4, Ichigo's wave rule): its fire hit with the SP held, he flash-steps in and this cut is the follow-up,
;; classed as the segment (BUILD-CORE-CLASSES tags it): one copy per class
(defmove-copy :ya-ns-strike :ya-j1 :clip :ya-strike :reach 1.6 :params (:follow-cap 40.0 :look :flash-step))
(defmove-copy :ya-as-strike :ya-ns-strike)

;;; ---------------------------------------------------------------- pointer 1 不知火 SHIRANUI: heavy damage, long reach
;; a: the thrust casts a spiral of fire down the lane (a :wave, 8 m); b: the "unknown fire", a column at the victim's bearing 4-7 m
;; ahead, the point taken on S, erupting 12 f later (:delay 13: a hazard spawned on frame S counts its first frame there), the
;; active window 13 so the eruption is inside it (no next segment before it); c: the tornado, a wide column travelling (a :wave)
(defmove :ya-n1a :kind :flash :clip :ya-n1a :startup 22 :active 2 :recovery 24 :reach 8.0
  :on-frame ((0 yama-ns-start) (22 yama-wave-fire)) :callout "SHIRANUI"
  :params (:ns-next :ya-n1b :width 2.0 :speed 14.0 :range 8.0 :dmg 70 :react :stagger :look yama-spiral-look :kikon-strike :ya-ns-strike))
(defmove :ya-n1b :kind :flash :clip :ya-f2 :startup 16 :active 13 :recovery 20 :reach 7.0
  :on-frame ((0 yama-ns-start) (16 yama-column-fire))
  :params (:ns-next :ya-n1c :near 4.0 :far 7.0 :radius 1.2 :delay 13 :dmg 70 :react :stagger :kikon-strike :ya-ns-strike))
(defmove :ya-n1c :kind :flash :clip :ya-n1c :startup 18 :active 2 :recovery 30 :reach 8.0
  :on-frame ((0 yama-ns-start) (18 yama-wave-fire))
  :params (:width 3.5 :speed 10.0 :range 8.0 :dmg 90 :react :knockback :kb 3.0 :look yama-tornado-look :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 2 城郭炎上 JOKAKU ENJO: control, the lane shaped by fire
;; close (0-3 m) since §30.1 (the user, 2026-11-21: 「目前始解的遠距離攻擊方式太多了」, R1): a: a melee flame slash (arc 120, 2.4 m; the
;; stream's clip for now: its blade falls short, the flame carries the rest; was a lance of fire down the lane, a :wave, 10 m); b: the
;; ring lands round the victim at his bearing (0-3 m, was 0-8; r 1.6 m, 90 f; one at a time; its burn :ring-dmg on a crossing, its SP
;; the setup minimum); c: the walls close into a dome on the ring (it is spent), or at his bearing (0-3 m, was 0-8) when none stands.
;; :near 0 (was 3.0 until batch J1, the user 2026-11-20: 「現在 NS 的火圈在靠太近時反而包不住人」, DUEL_YAMA_CORE §28.3): a victim closer
;; than :near stood outside the ring and the dome
(defmove :ya-n2a :kind :flash :clip :ya-n2a :startup 20 :active 2 :recovery 22 :dmg 40 :reach 2.4 :arc 120 :on-hit :stagger
  :on-frame ((0 yama-ns-start)) :callout "JOKAKU ENJO" :params (:ns-next :ya-n2b))
(defmove :ya-n2b :kind :flash :clip :ya-n2b :startup 16 :active 2 :recovery 20 :reach 3.0
  :on-frame ((0 yama-ns-start) (16 yama-ring-fire))
  :params (:ns-next :ya-n2c :near 0.0 :far 3.0 :radius 1.6 :life 90 :hits 2 :ring-dmg 20 :react :flinch :sp-cost 10
           :kikon-strike :ya-ns-strike))
(defmove :ya-n2c :kind :flash :clip :ya-n2c :startup 18 :active 2 :recovery 30 :reach 3.0
  :on-frame ((0 yama-ns-start) (18 yama-dome-fire))
  :params (:near 0.0 :far 3.0 :radius 1.6 :dmg 80 :react :crumple :kikon-strike :ya-ns-strike))

;;; ---------------------------------------------------------------- pointer 3 撫斬 NADEGIRI: the finisher
;; a: the walking jab of the point; b: the closing step-cut; c: NADEGIRI, one snap, the hit on S (the split is a look 24 f later)
(defmove :ya-n3a :kind :flash :clip :ya-n3a :startup 18 :active 3 :recovery 18 :dmg 40 :reach 1.6 :arc 90 :slide 1.0
  :on-hit :stagger :callout "NADEGIRI" :on-frame ((0 yama-ns-start)) :params (:ns-next :ya-n3b))
(defmove :ya-n3b :kind :flash :clip :ya-n3b :startup 12 :active 3 :recovery 18 :dmg 50 :reach 1.6 :arc 110 :slide 2.0
  :on-hit :stagger :on-frame ((0 yama-ns-start)) :params (:ns-next :ya-n3c))
(defmove :ya-n3c :kind :flash :clip :ya-nadegiri :startup 14 :active 4 :recovery 34 :dmg 110 :reach 2.4 :arc 100
  :on-hit :crumple :on-frame ((0 yama-ns-start) (14 yama-nade-split)))

;;; ---------------------------------------------------------------- the AS (as-by-press (1 2 3): J1 -> AS1, J2 -> AS2, J3 -> AS3)
;; AS1: the spiral thrust point-blank, stealing flash-step (:steal-fs 30, §7.4)
(defmove :ya-as1 :kind :sp :clip :ya-as1 :startup 10 :active 3 :recovery 24 :dmg 50 :reach 1.6 :arc 90
  :on-hit :knockdown :callout "SHIRANUI" :params (:steal-fs 30))
;; AS2: the ring snaps round him at the contact (40, its own hit; the ring left there) -> the dome on it (NS2c's copy: 60, a launch)
(defmove-copy :ya-as2b :ya-n2c :kind :sp :clip :ya-as2b :callout "JOKAKU ENJO" :reach 8.0   ; (its reach as before §30.1)
  :params (:near 0.0 :far 8.0 :radius 1.6 :dmg 60 :react :launch :kikon-strike :ya-as-strike))
(defmove :ya-as2 :kind :sp :clip :ya-as2a :startup 12 :active 3 :recovery 16 :dmg 40 :reach 2.0 :arc 120
  :on-hit :stagger :on-land yama-ring-snap
  :params (:ns-next :ya-as2b :radius 1.6 :life 90 :hits 2 :ring-dmg 20 :react :flinch :kikon-strike :ya-as-strike))
;; AS3: the back cut -> the turning cut -> NADEGIRI (NS3c's copy: 110, a knockdown)
(defmove-copy :ya-as3c :ya-n3c :kind :sp :clip :ya-as3c :on-hit :knockdown :callout "NADEGIRI")
(defmove :ya-as3b :kind :sp :clip :ya-as3b :startup 10 :active 3 :recovery 16 :dmg 50 :reach 2.0 :arc 160
  :on-hit :stagger :params (:ns-next :ya-as3c))
(defmove :ya-as3 :kind :sp :clip :ya-as3a :startup 8 :active 3 :recovery 14 :dmg 40 :reach 1.8 :arc 120
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
  :smear 4                                      ; (the swing's smear: a thin FIRE wash with an orange hairline, not REIATSU yellow: art S1,
                                                ;  DUEL_YAMA_CORE §21 F4, §22; 爆炎 has its own trail, look 5, since art S4)
  :commands (:q :ya-j1)
  :strings ((:ya-j1 :q :ya-j2) (:ya-j2 :q :ya-j3))
  :core (:ns (:ya-n1a :ya-n2a :ya-n3a) :as (:ya-as1 :ya-as2 :ya-as3) :sa :ya-sa
         :stances (:ya-shiranui :ya-st-enjo :ya-st-cane)   ; by pointer: the blade drawn back level at the hip / the point held out at the
                                                           ;  foe / the blade stood point-down at his right front (art S2, §23)
         :kikon-cines (yama-shiranui-cine yama-ennetsu-cine yama-nadegiri-cine)   ; 不知火 / 焱熱地獄 / 撫斬 (art S5, §26; the Soul Break
                                                                                    ;  under a pointer plays its one too)
         :as-by-press (1 2 3)
         :ns-range ((3.0 7.0) nil nil)   ; the CPU casts the spiral from range under pointer 1 (pointer 2 close since §30.1)
         :mult 1.0)
  :awaken-form :bankai                         ; the Bankai ZANKA NO TACHI (stage C; 爆炎 inherits it: awakening there ends 爆炎, §3)
  :meter (:name "HEAT" :max 100 :label yama-hud-label)   ; the heat gauge (GAUGES-METER, 0-100; the plate's kit strip: lhud-plate.lisp)
  :hooks (:pose yama-pose :draw yama-draw :dmg-mult yama-dmg-mult
          :tick yama-tick :hit yama-hit :cancel yama-cancel   ; heat, 爆炎 (stage B; the :blaze form inherits them)
          :planted yama-planted))                      ; (爆炎's IKKOTSU leaves the blade in the plaza: a look, art S4; NIL for every
                                                       ;  other Shikai move, so the default planted rule is never reached)

;;; ================================================================ 爆炎 GOKUEN (§7.2): the kit :blaze, every move a variant (「變招」)
;;; The first build gives each its own move entry, a copy with new numbers (the art may diverge later; DEFMOVE-COPY carries every key, so
;;; each copy states its :params whole: no Shikai :ns-next leaks in). x1.3 where §7.2 gives no number (the lead's placeholders, §11 B).
;;; Bared to the waist (:yamamoto-bare). Entered at his next neutral after heat reaches 100 (the entry pose :ya-blaze-in), left at the next
;;; neutral after heat 0; NS / AS free of flash-step (:core :sp-free); every NS segment spends 25 heat at the move's fixed power (Y9).
(defmove :ya-blaze-in :kind :flash :clip :ya-blaze-in :blend 4 :startup 23 :active 1 :recovery 0 :reach 0.0)   ; the entry pose (24 f; its own
                                                                                                  ;  clip since art S4)
(defmove-copy :ya-b-j1 :ya-j1 :dmg 40)          ; J1 / J2: the same clips (the flame trail: art), 40 / 40
(defmove-copy :ya-b-j2 :ya-j2 :dmg 40)
(defmove :ya-b-j3 :kind :quick :clip :ya-ikkotsu :startup 9 :active 3 :recovery 18 :dmg 55 :adv-block -4   ; J3 IKKOTSU, the fist
  :reach 0.88 :arc 100 :on-hit :stagger :callout "IKKOTSU")
;; NS1 不知火 x1.3; c: the tornado tracks him (:track 60 deg/s, YAMA-HZ)
(defmove-copy :ya-b-n1a :ya-n1a
  :params (:ns-next :ya-b-n1b :width 2.0 :speed 14.0 :range 8.0 :dmg 91 :react :stagger :look yama-spiral-look :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n1b :ya-n1b
  :params (:ns-next :ya-b-n1c :near 4.0 :far 7.0 :radius 1.2 :delay 13 :dmg 91 :react :stagger :kikon-strike :ya-ns-strike))
(defmove-copy :ya-b-n1c :ya-n1c
  :params (:width 3.5 :speed 10.0 :range 8.0 :dmg 117 :react :knockback :kb 3.0 :track 60.0 :look yama-tornado-look
           :kikon-strike :ya-ns-strike))
;; NS2 城郭炎上 (close since §30.1): a the melee flame slash x1.3; b the ring closes at once (b and c in one: the dome at his bearing 0-3 m,
;; was 0-8; a stagger mid-route); c ENNETSU, a disc of fire round him (r 2.5 m: a :ya-col on his feet; was rows of pillars along the lane,
;; a :wave 9 m). ENNETSU is its own DEFMOVE: a copy of NS2a would carry NS2a's melee window
(defmove-copy :ya-b-n2a :ya-n2a :dmg 52 :params (:ns-next :ya-b-n2b))
(defmove-copy :ya-b-n2b :ya-n2c :clip :ya-b-n2b :startup 16 :recovery 20 :on-frame ((0 yama-ns-start) (16 yama-dome-fire))
  :params (:ns-next :ya-b-n2c :near 0.0 :far 3.0 :radius 1.6 :dmg 80 :react :stagger :kikon-strike :ya-ns-strike))
(defmove :ya-b-n2c :kind :flash :clip :ya-b-n2c :startup 18 :active 2 :recovery 30 :reach 2.5 :callout "ENNETSU JIGOKU"   ; (its own clip: art S4)
  :on-frame ((0 yama-ns-start) (18 yama-column-fire))
  :params (:near 0.0 :far 0.0 :radius 2.5 :delay 0 :dmg 104 :react :crumple :kikon-strike :ya-ns-strike   ; (its own look since art
           :look yama-ennetsu-look))                                                                          ;  batch B: the ground fire)
;; NS3 撫斬 x1.3; c the true NADEGIRI: 200, a long recovery (RoS's "huge opening", B)
(defmove-copy :ya-b-n3a :ya-n3a :dmg 52 :params (:ns-next :ya-b-n3b))
(defmove-copy :ya-b-n3b :ya-n3b :dmg 65 :params (:ns-next :ya-b-n3c))
(defmove-copy :ya-b-n3c :ya-n3c :clip :ya-b-n3c :dmg 200 :recovery 60 :callout "NADEGIRI")   ; (its own clip: art S4)
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
  :smear 5                                        ; (the flame trail: a FIRE wash with tongues off its upper edge, every swing; art S4)
  :burn *ya-blaze-drain*                          ; the Reishi drain (YAMA-TICK through BURN-AMOUNT / BURN: never below 1, Y4)
  :commands (:q :ya-b-j1)
  :strings ((:ya-b-j1 :q :ya-b-j2) (:ya-b-j2 :q :ya-b-j3))
  :core (:ns (:ya-b-n1a :ya-b-n2a :ya-b-n3a) :as (:ya-b-as1 :ya-b-as2 :ya-b-as3) :sa :ya-b-sa
         :stances (:ya-shiranui :ya-st-enjo :ya-st-cane)
         :kikon-cines (yama-shiranui-cine yama-ennetsu-cine yama-nadegiri-cine)   ; (the Shikai's three, drawn bared: §21.8 Q2)
         :as-by-press (1 2 3)
         :ns-range ((3.0 7.0) nil nil)
         :sp-free t                                  ; NS / AS free of flash-step, as in a burst (§3; KIT-SP-FREE-P)
         :also (:ya-blaze-in)                         ; (the entry pose, in the kit's table)
         :mult 1.0))

;;; ================================================================ the Bankai ZANKA NO TACHI (§4, §7.3, §7.4; batch 1 stage C)
;;; The awakening (Mod + P) as every kit: the kit :bankai (its own :core, no :inherit, no heat: YAMA-BANKAI-ENTER zeroes the meter, so heat
;;; leaves with the Shikai and an awakening in 爆炎 ends it). The TYBW battle dress, the charred blade ZANKA. Every clip an old one at the
;;; right reach (placeholders, §8); damage before :mult 1.0. A mark is fighter state (YSS-MARKS) given by an AS's first real hit (its
;;; :params :mark); the marks held power AS4 天地灰尽 (§31) and clear at his neutral after it (no 北 form since §33).
(defparameter *ya-bind-stun* 60 "南's binds (the tower's climbs, the shatter): frames the victim's feet are held (the old kit's *BIND-STUN*; the
lead's placeholder, §14).")
(defparameter *ya-tower-stand* 90 "南's skeleton tower: frames it stands after the segment that last raised it ends (§30.3; NSc or the SA spends it).")
(defparameter *ya-tower-ahead* 1.5 "南's tower: how far before him it rises, at the victim's bearing (m, §30.3 R3; 2.5 until 2026-11-22, the user:
「長出的位置請更靠近山本」 -> 1.5, §35; yama-look.lisp's +YA-TOWER-AHEAD+ copies it).")
(defparameter *ya-tower-h* 2.0 "南's tower: its height a level (m): the topple's line is as long as the tower is tall (2 / 4 m, §30.3; 3.0
(3 / 6 m) until 2026-11-22, the user: 「南 NS 的骷髏塔縮小規模」, §38; yama-look.lisp's +YA-TOWER-H+ copies it).")
(defparameter *ya-charge-reach* '(0.8 1.6)
  "西's garb charge (§30.2, the user 2026-11-21): the reach (m) the string after the SA of NSa / NSb (charge 1 / 2, x1.4 / x1.7: the SA copies'
:charge-mult) adds to E-J2, E-J3 and the melee AS segments (*YA-REACH-MOVES*; 南's hazard AS stays unboosted). New, §30.2.")
(defparameter *ya-as4-mark-x* 0.25
  "AS4 天地灰尽 (§31, the user 2026-11-22: 「只要持有越多方位標記 AS4 與毀魂技的傷害就越高」): each mark held adds this to its damage x
(0 / 1 / 2 / 3 marks: x1.0 / 1.25 / 1.5 / 1.75: 200 / 250 / 300 / 350 since its one cut, §40). The lead's placeholder, tuned by play. New, §31.")
(defparameter *ya-as4-konpaku* '(2 3 4 5)
  "AS4's Kikon (§31): the Konpaku it takes by the marks held (0-3), over the pointer's profile (YAMA-KIKON-N; 5 = a Soul Break's cap,
past *CORE-KIKON-MAX* 4). The lead's placeholder. New, §31.")

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
;; E-J4 (§31, the user 2026-11-22: 「增加 J4 可以接入 AS4」): the string's fourth link, the only one AS4 follows (:as-by-press (1 2 3 4)).
;; Its own clip since art batch D (§34: the user's 「踏步袈裟斬」, the stepping kesa cut; was E-J1's at :clip-s 14).
(defmove :ya-e-j4 :kind :quick :clip :ya-e-q4 :startup 9 :active 3 :recovery 20 :dmg 46 :adv-block -6
  :reach 1.52 :arc 100 :on-hit :stagger)
;; the hazard segments' Kikon strikes (one per class, §7.4); 北's wave has its own, carrying 天地灰尽's cinematic (the Kikon's cinematic is the
;; landing strike's :cine, round.lisp SETTLE-SOULS)
(defmove-copy :ya-e-ns-strike :ya-e-j1 :reach 1.6 :params (:follow-cap 40.0 :look :flash-step))
(defmove-copy :ya-e-as-strike :ya-e-ns-strike)

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
;; The garb charge (§30.2, the user 2026-11-21: 「讓 NSa 跟 NSb 會放大火衣，放大的火衣會強化之後會到中立前的攻擊力與攻擊範圍」; R2 charge only, no
;; hit, as Ichigo's Getsuga charges, DUEL_CORE §423): a SHONETSU, no swing, the garb flares (charge 1); b the charge in place (no slide since §39, the user 2026-11-22: 「為什麼西的 NS 會位移」 -> rooted; was the advance, slide 1.5) under the
;; turn moves' armour (f6 to S: an NA is absorbed, an AS still beats it, CORE-TURN-ARMOR-VERDICT) (charge 2); neither hits (setup segments,
;; the SP minimum). Each names its gap's SA (:params :sa), a charged copy of the SA (:ya-e-sa-c1 / -c2 below) whose :charge-mult x1.4 / x1.7
;; the string after it carries (E-J2 / E-J3, the AS: CORE-CHARGE-MULT), with its reach + *YA-CHARGE-REACH* (YAMA-REACH-SWAP), until his next
;; neutral, NS or opener. c: the counter-cut (Y11), armoured the same way, always swinging (no catch: not a parry), at charge 2 baked in
;; (x1.7: 90 -> 153, reach 2.0 + 1.6: it follows NSb only, and an NS resets the carried x, CORE-NOTE-START!)
(defmove :ya-e-n2a :kind :flash :clip :ya-shonetsu :startup 16 :active 12 :recovery 24 :callout "SHONETSU JIGOKU"
  :params (:ns-next :ya-e-n2b :sa :ya-e-sa-c1 :sp-cost 10))
(defmove :ya-e-n2b :kind :flash :clip :ya-e-advance :startup 14 :active 3 :recovery 20   ; no slide since §39 (was 1.5)
  :params (:ns-next :ya-e-n2c :sa :ya-e-sa-c2 :turn-armor t :sp-cost 10))
(defmove :ya-e-n2c :kind :flash :clip :ya-e-gokui-cut :startup 12 :active 3 :recovery 24 :dmg 153 :adv-block -12 :slide 0.6
  :reach 3.6 :arc 120 :on-hit :knockback :kb 3.0 :callout "ZANJITSU GOKUI" :params (:turn-armor t))
;; AS2: the grab after the hit (40) > the flare throws him (70, a launch, the burn round him r 2.0; NSb's hit until §30.2); mark 西
(defmove :ya-e-as2b :kind :sp :clip :ya-e-throw :startup 12 :active 3 :recovery 24 :dmg 70 :reach 2.0 :arc 360 :on-hit :launch
  :params (:mark 2))
(defmove :ya-e-as2 :kind :sp :clip :ya-e-grab :startup 12 :active 3 :recovery 16 :dmg 40 :reach 1.6 :arc 120 :on-hit :stagger
  :callout "ZANJITSU GOKUI" :params (:ns-next :ya-e-as2b :mark 2))

;;; ---------------------------------------------------------------- 3 南 DAISOJIN: the dead rise
;; The skeleton tower (§30.3, the user 2026-11-21: 「南的 NSa 與 NSb 會召喚骷髏群聚攀爬成高塔（這時候對敵人有定身效果），NSc 會讓高塔向敵人傾倒
;; 砸毀，SA 則會主動打碎高塔使無數骷髏向前方飛散（對手被打中有定身效果）」, R3: before him). The tower is a hitless :ya-tower hazard (its level
;; in its data); each segment's hit is its own hazard (YAMA-FIRE: frozen in that segment). a: the dead swarm up into a tower *YA-TOWER-AHEAD*
;; m before him at the victim's bearing, the point taken on S, its base's hands 16 f later (:delay 17 inside A 17, as NS1b's column: a Step
;; after S dodges), r 1.2 (1.6 until §38), a bind; b: it climbs to level 2 and binds again; c: it topples toward the victim (a line from its base as long as
;; it is tall, 2 / 4 m (3 / 6 until §38), 2 m wide: YAMA-HZ :ya-fall), spent. The binds keep (:keep-bind: COMBO-STEP keeps a bind inside the route and counts
;; the hit). The SA in a or b's gap is the shatter (their :sa). Was (§7.3): the hands at the victim's bearing 4-10 m, the swarm's :wave,
;; the bone wall that stopped waves
(defmove :ya-e-n3a :kind :flash :clip :ya-kaka :startup 22 :active 17 :recovery 20 :reach 2.7 :callout "DAISOJIN"   ; (the disc's far rim: 1.5 + 1.2; 4.1 until §38)
  :on-frame ((22 yama-tower-fire))
  :params (:ns-next :ya-e-n3b :sa :ya-e-sa3 :radius 1.2 :delay 17 :dmg 40 :react :bind :stun *ya-bind-stun* :keep-bind t
           :kikon-strike :ya-e-ns-strike :look yama-hands-look))
(defmove :ya-e-n3b :kind :flash :clip :ya-e-minami-b :startup 16 :active 2 :recovery 22 :reach 2.7
  :on-frame ((16 yama-tower-fire))
  :params (:ns-next :ya-e-n3c :sa :ya-e-sa3 :level 2 :radius 1.2 :delay 0 :dmg 50 :react :bind :stun *ya-bind-stun* :keep-bind t
           :kikon-strike :ya-e-ns-strike :look yama-hands-look))
(defmove :ya-e-n3c :kind :flash :clip :ya-e-minami-c :startup 18 :active 2 :recovery 30 :reach 6.0   ; (level 2's line end 5.5 + 0.5; 8.0 until §38)
  :on-frame ((18 yama-topple-fire))
  :params (:dmg 70 :dmg-2 100 :react :crumple :kikon-strike :ya-e-ns-strike))
;; the SA in NSa / NSb's gap: the shatter, the skeletons flung forward: its own window, a 60 deg sector 6 m from him along his facing
;; (:ranged: no parry catches it), 55, a bind that keeps (the window's :keep-bind); the tower spent (YAMA-SHATTER-FIRE). A window, not a
;; hazard: an SA's string (J2) and its AS read his own contact (core-sim.lisp's SA > AS, FIGHTER-CONTACT). The Bankai SA's clip
(defmove :ya-e-sa3 :kind :quick :clip :ya-w-counter :startup 6 :active 3 :recovery 24 :dmg 55 :reach 6.0 :arc 60 :on-hit :bind
  :hits ((6 9 :stun *ya-bind-stun*)) :flags (:keep-bind :ranged) :on-frame ((6 yama-shatter-fire)))
;; AS3 (§30.3): the hands seize at him (40, a stagger) > the tower climbs round him (50, a stagger; was the swarm's :wave) > the pile topples
;; on him (100, a knockdown); mark 南
(defmove :ya-e-as3c :kind :sp :clip :ya-e-as3c :startup 12 :active 3 :recovery 30 :reach 4.0 :on-frame ((12 yama-column-fire))
  :params (:near 0.0 :far 4.0 :radius 1.4 :delay 0 :dmg 100 :react :knockdown :mark 3 :kikon-strike :ya-e-as-strike :look yama-pile-look))
(defmove :ya-e-as3b :kind :sp :clip :ya-e-as3b :startup 10 :active 2 :recovery 18 :reach 4.0 :on-frame ((10 yama-column-fire))
  :params (:ns-next :ya-e-as3c :near 0.0 :far 4.0 :radius 1.4 :delay 0 :dmg 50 :react :stagger :mark 3 :kikon-strike :ya-e-as-strike
           :look yama-as3b-look))   ; (the tower round him, §34 A)
(defmove :ya-e-as3 :kind :sp :clip :ya-e-as3a :startup 10 :active 3 :recovery 16 :reach 4.0 :callout "DAISOJIN"
  :on-frame ((10 yama-column-fire))
  :params (:ns-next :ya-e-as3b :near 0.0 :far 4.0 :radius 1.2 :delay 0 :dmg 40 :react :stagger :mark 3 :kikon-strike :ya-e-as-strike
           :look yama-hands-look))

;;; ---------------------------------------------------------------- AS4 天地灰尽 (§31, §40): J4's AS (北 is no form since §33)
;;; The user, 2026-11-22: 「天地灰盡改成 AS4 與接入的特殊毀魂技好了，只要持有越多方位標記 AS4 與毀魂技的傷害就越高」, 「增加 J4 可以接入 AS4，AS4
;;; 能使出特殊毀魂技，當使用過 AS4 並回到中立後就會消除目前的方位記號」; then 「AS4 請改成只有一刀「帶有斬穿空間特效」的斬擊」 (§40): ONE cut, 200,
;;; a knockdown (the user's exception to AS n = n segments, DUEL_CORE §6; it was four: the ash grip 40 > cut 50 > line 60 > 天地灰尽 140).
;;; It (:params :as4) does x (1 + *YA-AS4-MARK-X* x the marks held) (YAMA-DMG-MULT: 200 / 250 / 300 / 350) and Kikons into 天地灰尽's
;;; cinematic (:cine: ROUND's SETTLE-SOULS reads the struck move's) taking *YA-AS4-KONPAKU* by the marks (YAMA-KIKON-N). It writes no
;;; pointer (:as-writes nil) and gives no mark; once used, his next neutral clears the marks (YAMA-AS4-START, YAMA-AS4-SPENT). West's charge
;;; x still carries into it (CORE-CHARGE-MULT). S10 A2 R30: the old last segment's frames (its clip; the knockdown's advantage and the
;;; block punish unchanged). Looks: the clip :ya-e-as4, the white band, the victim's ash and the screen split along the cut (yama-look.lisp).
(defmove :ya-e-as4 :kind :sp :clip :ya-e-as4 :startup 10 :active 2 :recovery 30 :dmg 200 :reach 2.4 :arc 110
  :on-hit :knockdown :callout "TENCHI KAIJIN" :cine yama-tenchi-cine :on-frame ((0 yama-as4-start)) :params (:as4 t))
;; SA (J in an NS gap, any pointer): a short backhand at chest height (the old counter's clip, its home since art K3; it follows any NS
;; segment's S+A, six poses, so its frame 0 matches none: a blend over its fast wind-up drew a larger jump, DUEL_YAMA_CORE §18.3)
(defmove :ya-e-sa :kind :quick :clip :ya-w-counter :startup 6 :active 3 :recovery 24 :dmg 60 :adv-block -12 :slide 0.6 :reach 2.0 :arc 120
  :on-hit :stagger)
;; 西's charged SAs (§30.2): the SA in NSa's / NSb's gap at its level, its own damage and reach baked (x1.4 / x1.7: 84 / 102, reach 2.0 +
;; 0.8 / + 1.6; CORE-CHARGE-MULT skips the move carrying :charge-mult); the string after it carries the x
(defmove-copy :ya-e-sa-c1 :ya-e-sa :dmg 84 :reach 2.8 :params (:charge-mult 1.4))
(defmove-copy :ya-e-sa-c2 :ya-e-sa :dmg 102 :reach 3.6 :params (:charge-mult 1.7))
;; ... and the string's reach (Hisagi's precedent, *HS-K1-SCALED*): same-name copies of E-J2, E-J3 and the melee AS segments parsed at
;; (r + add) / r (PARSE-MOVE :reach-mult: the arc's r), one list per charge level, so the strings, the hooks, the SP table and the CPU see the
;; moves they know; YAMA-REACH-SWAP puts the level's copy in play (classed as its move: below the kit)
(defparameter *ya-reach-moves* '(:ya-e-j2 :ya-e-j3 :ya-e-j4 :ya-e-as1 :ya-e-as2 :ya-e-as2b)
  "The moves 西's charge reaches further with (§30.2; not 南's hazard AS, not E-J1: an SA's string goes on at J2).")
(defparameter *ya-reach-copies*
  (coerce (loop for add in *ya-charge-reach*
                collect (loop for n in *ya-reach-moves*
                              collect (let* ((mv (find-move n)) (r (mv-reach mv)))
                                        (parse-move n (mv-spec mv) :reach-mult (/ (+ r add) r)))))
          'simple-vector)
  "*YA-REACH-MOVES*' copies by charge level 1 / 2 (index 0 / 1): each reach + its *YA-CHARGE-REACH*.")

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
  :strings ((:ya-e-j1 :q :ya-e-j2) (:ya-e-j2 :q :ya-e-j3) (:ya-e-j3 :q :ya-e-j4))   ; (E-J4: §31)
  :core (:ns (:ya-e-n1a :ya-e-n2a :ya-e-n3a) :as (:ya-e-as1 :ya-e-as2 :ya-e-as3 :ya-e-as4) :sa :ya-e-sa
         :stances (:ya-st-higashi :ya-st-nishi :ya-st-minami) ; 東 the blade level across / 西 the arms open low / 南 the blade
                                                              ;  upright beside the face (art K2, DUEL_YAMA_CORE §17)
         :kikon-cines (yama-higashi-cine yama-nishi-cine yama-minami-cine)   ; 旭日刃 / 殘日獄衣 / 火火十万億死大葬陣 (art K4, §19)
         :as-by-press (1 2 3 4) :as-writes (1 2 3 nil)   ; (J4 > AS4 天地灰尽, no pointer written: §31)
         :ns-range ((2.0 5.5) nil (0.3 2.7))   ; the CPU lunges KYOKKO from mid range, raises 南's tower 1.5 m ahead where its bind disc (r 1.2) reaches him
                                               ;  (§38; (0.5 3.0) at r 1.6 until then, 2.5 m / (1.0 4.0) before §35, 4-9 m before §30.3)
         :mult 1.0)
  :hooks (:pose yama-pose :draw yama-draw :hit yama-bk-hit :dmg-mult yama-dmg-mult :kikon-n yama-kikon-n   ; (its hazards carry x 1.0: no heat)
          :tick yama-bk-tick :hud-tag yama-bk-tag     ; (西's charged reach; 北 at the next neutral after the third mark: §30)
          :armored-fx yama-armored-fx                  ; (西's armour absorbing an NA: L9, a look, art K1; it replaces the spark, K3)
          :planted yama-planted                        ; (the blade left in the plaza: the grab / throw, AS3b / AS3c; a look, art K3)
          :victim-look yama-victim-look))              ; (天地灰尽's ash on the victim's drawn body; a look, art batch D)
(let ((k (find-kit :yamamoto :bankai)))   ; 西's reach copies classed as their moves (KIT-CLASS is by object: COMBAT's AS hit, the CPU's reads)
  (loop for copies across *ya-reach-copies*
        do (dolist (c copies) (setf (gethash c (kit-cls k)) (kit-class k (kit-move k (mv-name c)))))))

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
爆炎 (BLAZE: its variants are the strong set, the spend only shortens it; it pays *YA-BLAZE-NS-SHARE* of *YA-HEAT-NS*, §32)."
  (let ((paid (if hit-p (max 0.0 (min (if blaze (* *ya-heat-ns* *ya-blaze-ns-share*) *ya-heat-ns*) heat)) 0.0)))
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

;; the Bankai's marks and 西's charge (§4, §7.4, §30, §31): pure, of numbers; the sim's side below (YAMA-BK-HIT, YAMA-BK-TICK)
(defun ya-mark-add (marks n)
  "The marks after AS N's first hit (§4, Y6: AS1 東, AS2 西, AS3 南): MARKS (bits 1 / 2 / 4) with mark N set (one already held stays one;
all three no longer enter 北: §33)."
  (logior marks (ash 1 (1- n))))

(defun ya-charge-level (cm)
  "西's garb charge carried by a string whose charged SA's x is CM (FIGHTER-CHARGE-MULT, §30.2): 2 at x1.7, 1 at x1.4, else 0. Its
thresholds are inlined (no boxed float) in yama-look.lisp's YAMA-GARB-K and YAMA-WEST-FLAME: keep the three equal."
  (cond ((>= cm 1.65) 2) ((>= cm 1.35) 1) (t 0)))

(defun ya-reach-copy (name lv)
  "Move NAME (one of *YA-REACH-MOVES*) at 西's charge level LV (1 / 2): its copy with the level's reach, or NIL."
  (let ((i (position name *ya-reach-moves*)))
    (and i (<= 1 lv 2) (nth i (svref *ya-reach-copies* (1- lv))))))

(defun yama-seg-x (e mv)
  "The damage x a segment of E's (MV) carries, frozen when it starts (YAMA-NS-START; a hazard's copied when it fires): his heat boost
(§3, §7.4: 1 + 0.3 x paid / 25) while MV is the NS segment the boost was stored for, else 1.0. APPLY-HIT multiplies it with the SP
short-pay x (SP-SCALE) and, for a hazard, the SP x frozen at its fire frame (HAZARD-SP-SCALE)."
  (let* ((s (and e (yss e))) (f (and s (fighter e))))
    (if (and f mv (eq mv (fighter-move f)) (= (yss-seg-t s) (fighter-cls-t f))) (yss-x s) 1.0)))

(defun ya-as4-x (marks)
  "AS4's damage x by the MARKS held (bits 東 1 / 西 2 / 南 4; §31): 1 + *YA-AS4-MARK-X* per mark."
  (+ 1.0 (* *ya-as4-mark-x* (logcount marks))))

(defun ya-as4-konpaku (marks n)
  "AS4's Kikon by the MARKS held (§31): *YA-AS4-KONPAKU*'s entry for their count, over the pointer profile's N."
  (declare (ignore n))
  (nth (logcount marks) *ya-as4-konpaku*))

(defun yama-dmg-mult (att def hw mv hazard d2)
  "KIT-HOOK :dmg-mult: a hazard's segment x as frozen at its fire frame (its data :x), else his own move's (YAMA-SEG-X); AS4's
x by the marks held (YA-AS4-X, §31)."
  (declare (ignore def hw d2))
  (cond (hazard (or (getf (hazard-data hazard) :x) 1.0))
        ((and mv (getf (mv-params mv) :as4)) (ya-as4-x (yss-marks (ys att))))
        (t (yama-seg-x att mv))))

(defun yama-kikon-n (att n)
  "KIT-HOOK :kikon-n (CORE-SET-KIKON-N!): a Kikon off AS4 takes YA-AS4-KONPAKU by the marks held (§31); else the profile's N."
  (let ((mv (fighter-move (fighter att))))
    (if (and mv (getf (mv-params mv) :as4)) (ya-as4-konpaku (yss-marks (ys att)) n) n)))

;;; ================================================================ heat and 爆炎 in the sim (§3, §7.4)
;;; Heat is the kit meter (GAUGES-METER: 0 at each match's fresh fighter, kept through a Konpaku reset with the form). His own state: a
;;; component on his fighter entity (made on its first use), the NS segment's spend and boost, the gain / burn once-guards.
(defcomponent yss
  "Yamamoto's own state (YS): the heat bookkeeping (the NS segment that last spent: its start tick SEG-T, what it PAID, its damage X, whether
a cancel gave it BACK; the start tick of the move or segment that last gained heat, GAIN-T: once each; the tick of the last cancel burn,
BURN-T: once a step), the Bankai's MARKS and AS4's use AS4. On his fighter entity, so they live through every form change and Konpaku
reset for the match (§7.4)."
  (seg-t -1 :type fixnum) (paid 0f0 :type single-float) (x 1f0 :type single-float) (back nil)
  (gain-t -1 :type fixnum) (burn-t -1 :type fixnum)
  (marks 0 :type fixnum)                       ; the Bankai's marks (bits 東 1 / 西 2 / 南 4): kept for the match, until AS4 spends them (§31)
  (as4 nil))                                   ; AS4 used since his last neutral: the next one clears the marks (§31, YAMA-AS4-SPENT)
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
  "The HITWIN of his fire: DMG, REACT, the move's :kb and :stun, a heavy hitstop; the move's :keep-bind as the window's flag."
  (make-hitwin :dmg dmg :react react :kb (or (move-param e :kb) 0.0) :hs *hitstop-heavy* :stun (move-param e :stun)
               :flags (and (move-param e :keep-bind) '(:keep-bind))))   ; (南's binds keep inside a route: COMBO-STEP, §30.3)

(defun yama-fire (e kind x z &key (size 1.0) (life 30) (delay 0) (hits 1) (hot life) look hw (yaw (yaw-of e)))
  "Spawn his fire hazard KIND at (X Z) facing YAW (his, by default), in his segment now (its class, SP scale, start tick: SPAWN-HAZARD's
defaults), its segment x frozen (YAMA-SEG-X: the data's :x); HOT: frames it may hit after its delay (then it is only a look)."
  (spawn-hazard kind e :x x :z z :yaw yaw :size size :life life :delay delay :hits hits :look look :hook 'yama-hz
                       :hw hw :data (list :hot hot :x (yama-seg-x e (fighter-move (fighter e))) :heat (yama-seg-heat e)
                                        :mark (move-param e :mark))))

(defun yama-hz (h hz ev &optional tx ty tz tr th)
  "His fire's hazard hook: :step closes the hit after its HOT frames (the look stays); :touches is its shape."
  (declare (ignore h))
  (case ev
    (:step (when (and (<= (hazard-delay hz) 0) (>= (hazard-age hz) (getf (hazard-data hz) :hot 0)))
             (setf (hazard-hits-left hz) 0))
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
            (:ya-fall (obox-cyl-hit-p (hazard-x hz) 1f0 (hazard-z hz) (hazard-yaw hz) 1f0 1.2f0 (hazard-size hz) tx ty tz tr th))   ; 南's
                                                        ;  topple: a 2 m wide line, 2 x HAZARD-SIZE long, centred on the hazard
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

(defun yama-live-ring (e) "E's burning ring now (a :ya-ring hazard entity), or NIL." (yama-live-hz e :ya-ring))

(defun yama-ring-at (e x z)
  "A burning ring round (X Z) from the move's :params (:radius :life :hits :ring-dmg :react); one at a time: the old one goes out."
  (let ((old (yama-live-ring e))) (when old (destroy-entity old) (clog "~a ring out (one at a time)" (side-name e))))
  (yama-fire e :ya-ring x z :size (move-param e :radius) :life (move-param e :life) :hits (move-param e :hits)
             :look 'yama-ring-look :hw (yama-fire-hw e (move-param e :ring-dmg) (move-param e :react)))
  (clog "~a ring at ~,2f ~,2f, ~,2f m from him" (side-name e) x z (let ((p (pos-of e))) (sqrt (+ (expt (- x (aref p 0)) 2) (expt (- z (aref p 2)) 2)))))
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

;; 南's skeleton tower (§30.3): a hitless :ya-tower hazard (its level in its data), one at a time; each segment's hit its own hazard
(defun yama-live-hz (e kind)
  "E's live hazard of KIND now (an entity: his ring, his tower), or NIL."
  (let ((found nil))
    (do-entities (h (hz hazard))
      (when (and (eq (hazard-kind hz) kind) (eql (hazard-owner hz) e) (< (hazard-age hz) (hazard-life hz))) (setf found h)))
    found))

(defun yama-tower-spot (e)
  "Where 南's tower rises: *YA-TOWER-AHEAD* m before E at the victim's bearing, inside the arena. Values x z."
  (let ((p (pos-of e)) (q (pos-of (opp-of e))))
    (ya-bearing-point (aref p 0) (aref p 2) (aref q 0) (aref q 2) *ya-tower-ahead* *ya-tower-ahead*)))

(defun yama-tower-fire (e)
  "南 NSa / NSb on S: the tower rises at YAMA-TOWER-SPOT (or the standing one climbs) to the move's :level (1 by default) and stands
*YA-TOWER-STAND* frames after this segment ends; the dead clawing up at its base are the hit (:dmg :react :stun :keep-bind, r :radius,
:delay frames later, hot 6)."
  (let* ((tw (yama-live-hz e :ya-tower)) (hz (and tw (hazard tw))) (f (fighter e)) (lv (or (move-param e :level) 1))
         (life (+ (- (mv-total (fighter-move f)) (fighter-sf f)) *ya-tower-stand*)))
    (multiple-value-bind (x z) (if hz (values (hazard-x hz) (hazard-z hz)) (yama-tower-spot e))
      (if hz
          (setf (hazard-life hz) (+ (hazard-age hz) life) (getf (hazard-data hz) :level) lv)
          (spawn-hazard :ya-tower e :x x :z z :yaw (yaw-of e) :size (move-param e :radius) :life life :hook 'yama-hz :look 'yama-tower-look
                                   :data (list :level lv)))
      (yama-fire e :ya-col x z :size (move-param e :radius) :delay (move-param e :delay) :life 30 :hot 6 :look (move-param e :look)
                 :hw (yama-fire-hw e (move-param e :dmg) (move-param e :react)))
      (clog "~a tower level ~d at ~,2f ~,2f, ~,2f m from him (~d f)" (side-name e) lv x z
            (let ((p (pos-of e))) (sqrt (+ (expt (- x (aref p 0)) 2) (expt (- z (aref p 2)) 2)))) life)
      (emit :sfx :ground-crack e))))

(defun ya-topple-dir (bx bz qx qz yaw)
  "The way 南's tower at (BX BZ) falls: toward the victim at (QX QZ), or along YAW (his facing) when the victim is within 0.5 m of its
base. Values the unit vector x z."
  (let* ((dx (- qx bx)) (dz (- qz bz)) (d (sqrt (+ (* dx dx) (* dz dz)))))
    (if (> d 0.5) (values (/ dx d) (/ dz d)) (values (fwd-x yaw) (fwd-z yaw)))))

(defun yama-topple-fire (e)
  "南 NSc on S: the tower (or, none standing, a level-1 one at YAMA-TOWER-SPOT) topples toward the victim: a line from its base as long as
it is tall (*YA-TOWER-H* x level), 2 m wide (YAMA-HZ :ya-fall), :dmg at level 1, :dmg-2 at level 2, hot 4; the tower is spent."
  (let* ((tw (yama-live-hz e :ya-tower)) (hz (and tw (hazard tw))) (lv (if hz (getf (hazard-data hz) :level 1) 1)) (q (pos-of (opp-of e))))
    (multiple-value-bind (bx bz) (if hz (values (hazard-x hz) (hazard-z hz)) (yama-tower-spot e))
      (when tw (destroy-entity tw))
      (multiple-value-bind (ux uz) (ya-topple-dir bx bz (aref q 0) (aref q 2) (yaw-of e))
        (let ((half (* 0.5 *ya-tower-h* lv)))
          (yama-fire e :ya-fall (+ bx (* half ux)) (+ bz (* half uz)) :size half :yaw (dir-yaw ux uz) :life 30 :hot 4 :look 'yama-topple-look
                     :hw (yama-fire-hw e (move-param e (if (>= lv 2) :dmg-2 :dmg)) (move-param e :react)))
          (clog "~a tower topples: level ~d, ~,1f m from ~,2f ~,2f" (side-name e) lv (* 2 half) bx bz))))
    (emit :sfx :ground-crack e)))

(defun yama-shatter-fire (e)
  "南's SA (the shatter) on S: the tower, if one stands, is spent (its hit is the move's own window); the skeletons flung over the sector's
6 m, a look (YAMA-SHATTER-LOOK)."
  (let ((tw (yama-live-hz e :ya-tower)))
    (when tw (destroy-entity tw))
    (multiple-value-bind (x z) (ahead e 3.0)
      (spawn-look e 'yama-shatter-look :x x :z z :yaw (yaw-of e) :size 3.0 :life 30))
    (clog "~a shatter~:[~; (the tower spent)~]" (side-name e) tw)
    (emit :sfx :ground-crack e)))

;;; ================================================================ the Bankai in the sim (§4, §7.4): the marks, 北, the awakening
(defun yama-bankai-enter (e)
  "The Bankai's :enter-hook (SET-FORM, by the awakening): heat leaves with the Shikai (§3: 爆炎 ends, the Bankai has no heat)."
  (let ((g (gauges e)))
    (clog "~a ZANKA NO TACHI: heat ~,1f -> 0 (marks ~d)" (side-name e) (gauges-meter g) (yss-marks (ys e)))
    (setf (gauges-meter g) 0f0)))

(defun yama-mark! (e n)
  "E's AS N landed: its mark (YA-MARK-ADD)."
  (let* ((s (ys e)) (m (ya-mark-add (yss-marks s) n)))
    (unless (= m (yss-marks s))
      (setf (yss-marks s) m)
      (clog "~a MARK ~a (marks ~d)" (side-name e) (svref #("" "EAST" "WEST" "SOUTH") n) m))))

(defun yama-bk-hit (att def res hw mv hazard ranged)
  "The Bankai's KIT-HOOK :hit: a real hit of an AS segment (or of the hazard it fired) gives its :mark (§7.4: when the AS lands; a cancel,
a block or the Kikon's follow-up strike gives none; AS4 has no mark). A hit of 西's charged string logs its x, reach and distance
(§30.2: the playtest's and the scripted scenes' reading)."
  (declare (ignore def hw ranged))
  (when (member res '(:hit :counter))
    (let ((f (fighter att)))
      (when (and mv (not hazard) (plusp (ya-charge-level (fighter-charge-mult f))))
        (clog "~a WEST charge x~,1f: ~a reach ~,2f at ~,2f m" (side-name att) (fighter-charge-mult f) (mv-name mv) (mv-reach mv)
              (fighter-dist f)))
      (multiple-value-bind (cls tick) (yama-part att mv hazard)
        (declare (ignore tick))
        (let ((n (and (eq cls :as) (eq (fighter-form f) :bankai)
                      (if hazard (getf (hazard-data hazard) :mark) (getf (mv-params mv) :mark)))))
          (when n (yama-mark! att n)))))))

(defun yama-reach-swap (f)
  "西's charged string (§30.2): while F carries a charge (FIGHTER-CHARGE-MULT, YA-CHARGE-LEVEL), a move of *YA-REACH-MOVES* in play is
swapped for its copy at the level's reach (YA-REACH-COPY: the same name, so the string, the SP table and the CPU see the move they know;
a cancel's dead mark follows it). Every live step, so a link swaps before its first active frame (each has S >= 7). 0 B."
  (let* ((mv (fighter-move f)) (lv (ya-charge-level (fighter-charge-mult f))))
    (when (and mv (plusp lv) (member (mv-name mv) *ya-reach-moves*))
      (let ((c (ya-reach-copy (mv-name mv) lv)))
        (unless (eq c mv)
          (when (eq (fighter-dead-mv f) mv) (setf (fighter-dead-mv f) c))
          (setf (fighter-move f) c))))))

(defun yama-bk-tick (e f g)
  "The Bankai's KIT-HOOK :tick (live sim steps only): 西's charged reach (YAMA-REACH-SWAP); the marks spent at his neutral after AS4
(YAMA-AS4-SPENT, §31)."
  (declare (ignore g))
  (yama-reach-swap f)
  (yama-as4-spent e f))

(defun yama-as4-start (e)
  "AS4's frame 0 (§31): AS4 is used (the next neutral clears the marks: YAMA-AS4-SPENT)."
  (setf (yss-as4 (ys e)) t))

(defun yama-as4-spent (e f)
  "At E's first neutral after AS4 (§31, the user 2026-11-22: 「當使用過 AS4 並回到中立後就會消除目前的方位記號」): the marks clear."
  (let ((s (ys e)))
    (when (and (yss-as4 s) (yama-free-p f))
      (setf (yss-as4 s) nil)
      (clog "~a AS4 spent: marks ~d -> 0" (side-name e) (yss-marks s))
      (setf (yss-marks s) 0))))

(defparameter *ya-bk-tags* (vector nil "MARK 1" "MARK 2" "MARK 12" "MARK 3" "MARK 13" "MARK 23" "MARK 123")
  "The Bankai's plate tag by the marks held (bits 東 1 / 西 2 / 南 4): constant strings (the Lisp HUD remakes its strings only when the
tag changes, by EQ).")
(defun yama-bk-tag (e)
  "The Bankai's KIT-HOOK :hud-tag: the marks held (MARK 1 / 12 / ... : LHUD-MARKS draws them next to the pointer), else NIL."
  (let ((s (yss e))) (and s (svref *ya-bk-tags* (yss-marks s)))))
;;; ================================================================ debug (87000-87999), probes
(defun yama-probe-line (tag)
  "A `duel probe yamamoto` line: P1's form, state, move, pointer, flash-step, heat (the kit meter), Reishi, the marks, 西's charge x, his live ring; P2's state and Reishi; the distance."
  (let* ((f (fighter *p1*)) (r (yama-live-ring *p1*)) (hz (and r (hazard r))))
    (log-msg "duel probe yamamoto ~a t ~d p1 ~a ~a ~a ptr ~d fs ~,1f heat ~,1f r~d marks ~d charge ~,1f ring ~a | p2 ~a r~d | d ~,2f"
             tag *match-tick* (fighter-form f) (state-of *p1*) (and (fighter-move f) (mv-name (fighter-move f))) (fighter-ptr f)
             (gauges-fs (gauges *p1*)) (gauges-meter (gauges *p1*)) (gauges-reishi (gauges *p1*)) (yss-marks (ys *p1*)) (fighter-charge-mult f)
             (if hz (format nil "~,2f ~,2f age ~d" (hazard-x hz) (hazard-z hz) (hazard-age hz)) "-")
             (state-of *p2*) (gauges-reishi (gauges *p2*)) (fighter-dist f))))

(defun yama-cine-at (name &optional (form :bankai))
  "Stills (art K4): the Kikon cinematic NAME from frame 0, P1 Yamamoto in FORM (the Bankai; art S5: the Shikai :base or 爆炎 :blaze, the
latter with heat 100 for the scars) 3 m from an idle Kenpachi, both set down mid-stage first (CINE-STAGE, as SETTLE-SOULS does); no AFTER
(the round goes on). When NAME already runs in FORM, nothing (87601+k holds it)."
  (unless (and *cine* (eq (cine-name *cine*) name) (eq (fighter-form (fighter *p1*)) form))
    (abort-cine) (stamps-clear)                          ; (the last one's stamps: the stills run one after another)
    (setf *cine-hold* nil)
    (ensure-battle :yamamoto :kenpachi) (place *p1* *p2* 3.0) (full-gauges! *p1*) (full-gauges! *p2*)
    (unless (eq (fighter-form (fighter *p1*)) form)      ; (the K4 stills run 87446 first: its callout gone)
      (setf (gauges-awakened (gauges *p1*)) (eq form :bankai)) (set-form *p1* form) (to-idle *p1* 0)
      (unless (eq form :bankai) (setf *words* nil)))   ; (art S5: the form's callout left out of the stills)
    (when (eq form :blaze) (setf (gauges-meter (gauges *p1*)) 100f0))
    (cine-stage *p1* *p2*)
    (start-cine name *p1* *p2*)))

(defun yama-topdown-cam ()
  "Debug 87480 (art S1's footprint stills): a camera looking down on the stage 4.5 m ahead of P1 from 9.5 m up (tilted 7 deg: a lens straight
down has no up), or the game's camera again. A shot (CINE-CAM) outside a cinematic: the next cinematic drops it."
  (if *cine-cam*
      (setf *cine-cam* nil)
      (let* ((p (pos-of *p1*)) (yaw (yaw-of *p1*)) (cx (+ (aref p 0) (* 4.5 (fwd-x yaw)))) (cz (+ (aref p 2) (* 4.5 (fwd-z yaw)))))
        (cine-cam (- cx (* 1.2 (fwd-x yaw))) 9.5 (- cz (* 1.2 (fwd-z yaw))) cx 0.0 cz))))

(defun yama-footprints (e)
  "Debug 87481: E's fire hazards' sim footprints on the floor in cyan (a :wave's box, 2 x size across and 2 x the box's half-length along;
a disc of HAZARD-SIZE; the ring's band), to set against the looks' ground edges. Debug only (it conses)."
  (do-entities (h (hz hazard))
    (when (and (eql (hazard-owner hz) e) (hazard-hw hz))
      (let ((x (hazard-x hz)) (z (hazard-z hz)) (s (hazard-size hz)) (yaw (hazard-yaw hz)))
        (case (hazard-kind hz)
          (:wave (let* ((l (second *wave-box*)) (fx (fwd-x yaw)) (fz (fwd-z yaw)) (px (- fz)) (pz fx)
                        (c (list (list (+ (* l fx) (* s px)) (+ (* l fz) (* s pz))) (list (- (* l fx) (* s px)) (- (* l fz) (* s pz)))
                                 (list (- (- (* l fx)) (* s px)) (- (- (* l fz)) (* s pz))) (list (+ (- (* l fx)) (* s px)) (+ (- (* l fz)) (* s pz))))))
                   (loop for (a b) on (append c (list (first c))) while b
                         do (fx-line (+ x (first a)) 0.04 (+ z (second a)) (+ x (first b)) 0.04 (+ z (second b)) 0.02 0.2 1.0 1.0 1.0))))
          (:ya-ring (draw-circle x 0.04 z (- s *ya-ring-band*) 0.2 1.0 1.0 :segments 48 :width 0.02 :alpha 1.0)
                    (draw-circle x 0.04 z (+ s *ya-ring-band*) 0.2 1.0 1.0 :segments 48 :width 0.02 :alpha 1.0))
          (t (draw-circle x 0.04 z s 0.2 1.0 1.0 :segments 48 :width 0.02 :alpha 1.0)))))))

(defun yama-debug (c)
  "His debug commands (docs/duel/DUEL_GAMEPLAY.md \"Debug commands\", 87000-87999): 87000+k human P1 Yamamoto vs an idle Kenpachi
(both CPUs off, full gauges), k / 10 m apart (k 0-199); 87200+n the same vs Ichigo (n 0) / Hisagi (1) 2.0 m apart; 87301-87303 P1's
pointer 1-3; 87400+n P1 starts his NS under the pointer (n 0) / J1 (1); 87410+i P1 starts NS segment i of NS1a b c NS2a b c (0-5) on
its own (CORE-START!: paid as a press); 87500+h P1's heat h (h 0-100: 100 enters 爆炎 at his next neutral); 87700+r P1's Reishi r, 87800+r
P2's (r 1-99); 87900 the probe line; 87901 the phone's deck on (*ONE-HAND* as the setting would have it: a portrait window). The Bankai
(stage C): 87420+i P1 starts Bankai segment i of 東 a b c, 西 a b c, 南 a b c, AS4 (0-9; was 北's NS c until §31; AS4's first segment until §40) on its own (CORE-START!; P1 in the Bankai); 87440 P1 awakens now (AWAKEN!, the
cinematic); 87441-87443 P1 gets mark 東 / 西 / 南 (YAMA-MARK!); 87444 free (P1 into the 北 form until §33); 87445 P1's marks cleared; 87446 P1 into the Bankai at once (no cinematic, awakened); 87447 a `duel yamamoto
switch` line: may P1 switch pointer now (CORE-SWITCH-OPEN-P). Art K1 (§16): 87430+i P1 starts Bankai AS segment i of AS1, AS2a / b, AS3a / b /
c, AS4 (0-6; its last segment until §40) on its own (CORE-START!); 87455 free (AS4's third segment until §40;
87453-87458 were 北's segments until §33, the others free); 
87437 an :armored event on P1 (FEEDBACK-SYSTEM only: 西's armour look); 87438 P1 starts 南's
SA, the shatter, on its own (§30.3: CORE-START!, P1 in the Bankai; it spends a standing tower); 87448 the consing of every
Bankai look (yama-look.lisp YAMA-LOOK-CONSING; art K2: the stances' garb / cracks and the smear too; art K3:
the planted blade, 北's burn, the :planted hook; art K4: the three Kikon cinematics' looks). Art K4 (§19): 87450+i the Bankai's Kikon
cinematic i (東 / 西 / 南, 0-2) from frame 0, P1 in the Bankai 3 m from an idle Kenpachi, set down mid-stage as a Kikon is (YAMA-CINE-AT;
nothing when it already runs); 87601-87699 the running cinematic held at frame 2 x (c - 87600) (it runs on to it: the stills), 87910-87999 at 2 x (c - 87810)
(frames 200-378: the 西 Kikon is 272 f since §29.3). Art S1
(§22): 87416+i P1 starts NS3a / b / c or the SA (i 0-3) on its own; 87460+i the Shikai's AS segment i of AS1, AS2a / b, AS3a / b / c (0-5);
87470+i 爆炎's segment i of NS1a-c, NS2a-c, NS3a-c, the SA (0-9; P1 in 爆炎); 87480 the top-down camera on / off (YAMA-TOPDOWN-CAM); 87481
his hazards' footprints outlined on / off (YAMA-FOOTPRINTS); 87449 the consing of every Shikai look (YAMA-SHIKAI-CONSING). Art S4 (§25):
87490 P2 moved 3 m to P1's right (the off-axis victim of 爆炎's tornado lean). Art S5 (§26): 87482+i the Shikai's Kikon cinematic i
(不知火 / 焱熱地獄 / 撫斬, 0-2) from frame 0, P1 in the Shikai, and 87485+i the same in 爆炎 (heat 100), 3 m from an idle Kenpachi, set down
mid-stage (YAMA-CINE-AT; nothing when it already runs in that form); 87601-87699 holds them as K4's. (87491-87493, batch Z1's orbit cameras for
its mantle, left with the mantle: batch J2, §28.) The probe line carries 北's ticks left and 西's charge x (§30)."
  (flet ((scene (c2 dist)
           (ensure-battle :yamamoto c2)
           (place *p1* *p2* dist)
           (full-gauges! *p1*) (full-gauges! *p2*))
         (km (name) (or (gethash name (kit-moves (kit-of *p1*))) (find-move name))))   ; (P1's kit's move, else the plain one: no error)
    (cond ((< c 87200) (scene :kenpachi (/ (- c 87000) 10.0)))
          ((< c 87300) (scene (if (= c 87200) :ichigo :hisagi) 2.0))
          ((<= 87301 c 87303) (setf (fighter-ptr (fighter *p1*)) (- c 87300)))
          ((= c 87400) (core-sp-start! *p1* (fighter *p1*)))
          ((= c 87401) (force-cmd *p1* :q))
          ((<= 87410 c 87415)                       ; (a segment on its own: the column without the wave first, the dome with no ring)
           (core-start! *p1* (find-move (nth (- c 87410) '(:ya-n1a :ya-n1b :ya-n1c :ya-n2a :ya-n2b :ya-n2c)))))
          ((<= 87416 c 87419)                       ; (art S1's stills: NS3 a / b / c, the SA on their own)
           (core-start! *p1* (find-move (nth (- c 87416) '(:ya-n3a :ya-n3b :ya-n3c :ya-sa)))))
          ((<= 87460 c 87465)                       ; (art S1: the Shikai's AS segments on their own)
           (core-start! *p1* (find-move (nth (- c 87460) '(:ya-as1 :ya-as2 :ya-as2b :ya-as3 :ya-as3b :ya-as3c)))))
          ((<= 87470 c 87479)                       ; (art S1: 爆炎's segments on their own; P1 in 爆炎)
           (core-start! *p1* (kit-move (kit-of *p1*) (nth (- c 87470) '(:ya-b-n1a :ya-b-n1b :ya-b-n1c :ya-b-n2a :ya-b-n2b :ya-b-n2c
                                                                      :ya-b-n3a :ya-b-n3b :ya-b-n3c :ya-b-sa)))))
          ((= c 87480) (yama-topdown-cam))
          ((= c 87481) (setf *ya-footprints* (not *ya-footprints*)))
          ((= c 87449) (yama-shikai-consing))
          ((= c 87490) (let ((q (pos-of *p2*)) (yaw (yaw-of *p1*)))   ; (art S4: the tornado lean's off-axis victim, 3 m to P1's right)
                         (setf (aref q 0) (f32 (+ (aref q 0) (* 3.0 (cos yaw)))) (aref q 2) (f32 (- (aref q 2) (* 3.0 (sin yaw)))))))
          ((<= 87420 c 87429)
           (core-start! *p1* (km (nth (- c 87420) '(:ya-e-n1a :ya-e-n1b :ya-e-n1c :ya-e-n2a :ya-e-n2b :ya-e-n2c
                                                    :ya-e-n3a :ya-e-n3b :ya-e-n3c :ya-e-as4)))))   ; (AS4: one move since §40)
          ((<= 87430 c 87436)                       ; (art K1's stills: an AS segment on its own)
           (core-start! *p1* (km (nth (- c 87430) '(:ya-e-as1 :ya-e-as2 :ya-e-as2b :ya-e-as3 :ya-e-as3b :ya-e-as3c :ya-e-as4)))))
          ((= c 87437) (let ((p (pos-of *p1*))) (emit :armored *p1* (aref p 0) 1.2 (aref p 2))))   ; (西's armour look, L9: an event only)
          ((= c 87438) (core-start! *p1* (kit-move (kit-of *p1*) :ya-e-sa3)))   ; (§30.3: 南's SA, the shatter, on its own; P1 in the Bankai)
          ((= c 87440) (awaken! *p1*))
          ((<= 87441 c 87443) (yama-mark! *p1* (- c 87440)))
          ((= c 87445) (setf (yss-marks (ys *p1*)) 0 (yss-as4 (ys *p1*)) nil))
          ((= c 87446) (setf (gauges-awakened (gauges *p1*)) t) (set-form *p1* :bankai) (to-idle *p1* 0))
          ((= c 87448) (yama-look-consing))
          ((<= 87450 c 87452) (yama-cine-at (nth (- c 87450) '(yama-higashi-cine yama-nishi-cine yama-minami-cine))))   ; (art K4)
          ((<= 87482 c 87487) (yama-cine-at (nth (mod (- c 87482) 3) *ya-s5-cines*) (if (< c 87485) :base :blaze)))   ; (art S5)
          ((<= 87601 c 87699) (when *cine* (setf (cine-hold *cine*) (* 2 (- c 87600)))))
          ((<= 87910 c 87999) (when *cine* (setf (cine-hold *cine*) (* 2 (- c 87810)))))   ; (frames 200-378: the 西 Kikon's 272 f, §29.3)
          ((= c 87447) (log-msg "duel yamamoto switch t ~d open ~a form ~a" *match-tick* (and (core-switch-open-p *p1* (fighter *p1*)) t)
                                (fighter-form (fighter *p1*))))
          ((<= 87500 c 87600) (setf (gauges-meter (gauges *p1*)) (f32 (- c 87500))))
          ((<= 87701 c 87799) (setf (gauges-reishi (gauges *p1*)) (- c 87700)))
          ((<= 87801 c 87899) (setf (gauges-reishi (gauges *p2*)) (- c 87800)))
          ((= c 87900))
          ((= c 87901) (setf *one-hand* (one-hand-effective-p)))   ; (the phone's deck: run with --mobile --size 390x844)
          (t (log-msg "duel yamamoto: no debug command ~d" c))))
  (yama-probe-line (format nil "cmd ~d" c)))
(define-debug-range (87000 87999) yama-debug)
