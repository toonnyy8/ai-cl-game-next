;;;; ken.lisp — ZARAKI KENPACHI (TYBW), design-v1 §5.2: his moves (DEFMOVE) and his forms (DEFKIT): :base (the sealed katana),
;;;; :nozarashi (the Shikai since V3, DUEL_KEN_V3: two pointers by grip and the unlock level L; the cups KATATE / RYOTE / NOMIHOSE and
;;;; KATAUDE went 2026-11-03) and :bankai (the old Bankai until its own V3 batch). He wears no eyepatch in any form (the user's decision;
;;;; canon TYBW keeps a strapless patch).
;;;; Clip names are the art contract (ken-art.lisp). Below the data: his hook functions and his
;;;; cinematics (DEFCINE).
(in-package :duel)

;;; ================================================================ base
;;; the J / K strings (docs/duel/DUEL_STRINGS.md §3.3): no school, a street fighter with a sword who kicks. The grid as
;;; Yamamoto's (yama.lisp): up to three links, switching J / K at most once (the reach since the J cut, DUEL_STRINGS §13: J 0.4x; J1 / J2 1.4 since §20,
;;; K nearly as long as before: his long swings); every K at link 2 / 3 at S_eff 14, at 80 % of
;;; the design's damage (the seed gate: 75 -> 60, 100 -> 80; RYOTE 85 -> 68, 115 -> 92)
(defmove :ke-j1 :kind :quick :clip :ke-q1 :startup 7 :active 3 :recovery 12 :dmg 35 :adv-block -2
  :reach 1.4 :arc 100 :on-hit :flinch :slide 0.8)                    ; ARAGIRI: a lazy slash, lunge 0.8 m
(defmove :ke-j2 :kind :quick :clip :ke-q2 :startup 7 :active 3 :recovery 13 :dmg 35 :adv-block -2
  :reach 1.4 :arc 100 :on-hit :flinch)                               ; KAESHIGIRI: the backhand
(defmove :ke-j3 :kind :quick :clip :ke-kick :startup 8 :active 3 :recovery 18 :dmg 42 :adv-block -4
  :reach 0.88 :arc 60 :on-hit :stagger :flags (:ender))              ; KENKA-GERI: a front kick to the gut
(defmove :ke-k1 :kind :flash :clip :ke-f1 :startup 16 :active 4 :recovery 20 :dmg 70 :adv-block -3
  :reach 2.8 :arc 120 :on-hit :stagger)                              ; OBURI: the huge two-handed swing
(defmove :ke-k2 :kind :flash :clip :ke-f2 :enter 6 :startup 20 :active 4 :recovery 24 :dmg 60 :adv-block -3
  :reach 2.5 :arc 90 :on-hit :stagger)                               ; KIRIAGE: from the floor up
(defmove :ke-k3 :kind :flash :clip :ke-q3 :clip-s 11 :enter 6 :startup 20 :active 5 :recovery 34 :dmg 80 :adv-block -20
  :reach 2.7 :arc 360 :on-hit :crumple :flags (:ender))              ; BUNMAWASHI: the full spin
(defmove-copy :ke-j2s :ke-j2)
(defmove-copy :ke-k2s :ke-k2)
;; "KITTE MIRO YO": :hold = 6 f in (hit = counter-hit), then super armour up to 60 f storing damage;
;; release (or 60 f) -> the cut, 100 + stored, guard-crushing when stored >= 150 (the hooks decide)
(defmove :ke-stance :kind :sig :clip :ke-stance-hold :clip-2 :ke-stance-cut :callout "KITTE MIRO YO"
  :hold (*stance-in* *stance-hold-max*) :flags (:stance) :blend 6
  :startup 8 :active 4 :recovery 24 :dmg *stance-base-damage* :adv-block -14
  :reach 2.8 :arc 120 :on-hit :knockback :kb 3.0
  :release ken-stance-release)
;; leap 5 m, overhead, a 3 m ground-crack line
(defmove :ke-buttagiru :kind :sp :clip :ke-buttagiru :callout "BUTTAGIRU"
  :startup 22 :active 4 :recovery 26 :dmg 180 :adv-block -14 :slide 5.0
  :vol (:cap 0.0 3.0 0.5 0.6) :on-hit :knockdown :kb 2.0 :flags (:ranged) :on-frame ((22 ken-ground-crack))
  :params (:melee-range 2.6))                          ; the blade within 2.6 m (Q1's reach until the J cut), the crack beyond: ranged
;; dash 6 m at 14 m/s during the 26 active frames (the tick hook); contact = flurry hit 1 of 5
;; (25 each), then :KE-FLURRY (4 more + a 60 launcher). Still holding at the dash: guard-crushing.
(defmove :ke-charge :kind :sp :clip :ke-charge :clip-2 :ke-flurry :callout "ORE NI KIRENEE MON WA NEE"
  :startup 14 :active 26 :recovery 24 :dmg 25 :adv-block -16
  :vol (:cap 0.0 1.4 1.1 0.6) :on-hit :flinch
  :tick ken-charge-tick :on-land ken-flurry
  :params (:dash-speed 14.0))
;; not a command: KEN-FLURRY starts it when the charge connects (the kit's (:ke-charge :land :ke-flurry)
;; string, so Nozarashi derives it too; clip cuts at f4 10 16 22 28, launch f40)
(defmove :ke-flurry :kind :sp :clip :ke-flurry :startup 10 :active 31 :recovery 24 :dmg 25 :adv-block -16
  :reach 2.2 :arc 120 :on-hit :flinch
  :hits ((10 11) (16 17) (22 23) (28 29) (40 41 :dmg 60 :on-hit :launch)))
(defmove :ke-breaker :kind :breaker :clip :ke-breaker :clip-2 :ke-shoulder :callout "SHOULDER CHARGE")
;; O, the Kikon rush module CHARGE: 5 f of aura, then a charge at 13 m/s for at most 36 f that keeps
;; turning at him (150 deg/s) and eats one hit on its armour (a Breaker or a second hit stops it), then
;; the stance's huge cross-body cut: 9.4 m, <= 50 f. A hit with O held: the Kikon on a red opponent,
;; else the follow-up (KIKON-OUTCOME). -14 on block. Cooldown 90.
(defmove :ke-kikon :kind :kikon :clip :ke-charge :clip-2 :ke-stance-cut :clip-s 8 :cine ken-kikon-cine
  :startup 9 :active 3 :recovery 24 :dmg 70 :adv-block -14 :reach 2.4 :arc 110 :on-hit :knockback :kb 2.5
  :armor-hits 1 :cooldown 90
  :params (:aura 5 :aim 120.0 :speed 13.0 :dash-max 36 :dash-track 150.0 :look :charge :sfx :laugh))

;;; ================================================================ Nozarashi
(defmove :ke-meteor :kind :sp :clip :ke-meteor :callout "SPLIT THE METEOR"
  :startup 26 :active 4 :recovery 30 :dmg 240 :adv-block -16
  :vol (:cap 0.3 12.0 0.5 0.5) :on-hit :knockdown :kb 3.0 :flags (:ranged) :on-frame ((26 ken-meteor-cut))
  :params (:melee-range 3.4))                          ; the cleaver within 3.4 m (KATATE's Q reach until the J cut), the line beyond: ranged
;; O in Nozarashi, LEAP CLEAVE (his own move: not derived): 8 f of crouch, then a leap at 18 m/s for at
;; most 30 f, the direction locked at take-off (the height is a look, :lift), then the widest cleave,
;; 3.08 m over 160 deg, and a gash where it lands: 10.6 m, <= 49 f. Cooldown 90.
(defmove :ke-kikon-n :kind :kikon :clip :ke-n-leap :clip-2 :ke-stance-cut :clip-s 8 :callout "SKY SPLIT" :cine ken-sky-split-cine
  :startup 11 :active 3 :recovery 24 :dmg 70 :adv-block -14 :reach 3.08 :arc 160 :on-hit :knockback :kb 2.5 :cooldown 90
  :on-frame ((11 ken-leap-cleave))
  :params (:aura 8 :aim 120.0 :speed 18.0 :dash-max 30 :dash-track 0.0 :look :leap :lift 1.6 :sfx :whoosh-cleaver))

;;; ---------------------------------------------------------------- RYOTE (cup 2): two-handed kendo, straight and long
;;; (their own clips, ken-art.lisp; :clip-s = the clip's authored S, so each plays at speed 1)
;;; ================================================================ the core system's moves (DUEL_KEN_CORE, 2026-10-29)
;;; Three pointers, three themes (the user, 2026-10-29): 1 the chain (連斬壓制: the K string, one cut after another), 2 the rush (霸體硬扛與
;;; 粗暴突進: NS2 takes one hit from its sixth frame to the end of its active frames, and every cancel it makes feeds its SA), 3 the kamae
;;; (劍道架式續力: three charges, each raising the reiatsu and the output of the SA, the J string and the AS after it).
;;; NS1: the K string 70 + 60 + 80; AS1: the drop (steals the flash-step).
(defmove-copy :ke-n1c :ke-k3 :flags nil)
(defmove-copy :ke-n1b :ke-k2 :params (:ns-next :ke-n1c))
(defmove-copy :ke-n1a :ke-k1 :params (:ns-next :ke-n1b))
(defmove-copy :ke-sa :ke-j1 :dmg 36 :reach 2.4 :slide 1.4 :startup 8 :clip-s 7)
;; NS2: BUTTAGIRU's leap > the kick; both take one hit through (:armor-hits 1, extended to the end of the active frames by KEN-ARMOR),
;; a cancel (the triangle's, no damage) neither spends it nor is a hit: it counts (KEN-CLASH) and raises the SA of the gap (KEN-DMG-MULT)
(defmove-copy :ke-n2b :ke-j3 :kind :flash :dmg 60 :flags nil :startup 14 :clip :ke-sweep :clip-s 14 :reach 2.4 :arc 140 :armor-hits 1 :slide 2.0
  :params (:armor-act t :clash-count t))
(defmove-copy :ke-n2a :ke-buttagiru :kind :flash :clip :ke-rush-a :dmg 90 :on-hit :stagger :armor-hits 1 :flags nil :on-frame nil
  :params (:melee-range 2.6 :ns-next :ke-n2b :sa :ke-sa-r :armor-act t :clash-count t))
(defmove-copy :ke-sa-r :ke-sa :params (:clash-scale 0.3))
;; NS3: three charges that hit nothing; each one's SA (J pressed in its gap) arms a bigger :charge-mult on the string after it
(defmove-copy :ke-sa-c1 :ke-sa :dmg 45 :params (:charge-mult 1.3 :aura-k 1.5))
(defmove-copy :ke-sa-c2 :ke-sa :dmg 60 :params (:charge-mult 1.6 :aura-k 2.2))
(defmove-copy :ke-sa-c3 :ke-sa :dmg 80 :params (:charge-mult 2.0 :aura-k 3.0))
(defmove :ke-n3c :kind :flash :clip :ke-chg3 :startup 16 :active 0 :recovery 20 :on-frame ((2 ken-charge-sfx))
  :params (:sa :ke-sa-c3 :aura-k 3.0 :charge-sa t))
(defmove :ke-n3b :kind :flash :clip :ke-chg2 :startup 16 :active 0 :recovery 14 :on-frame ((2 ken-charge-sfx))
  :params (:ns-next :ke-n3c :sa :ke-sa-c2 :aura-k 2.2 :charge-sa t))
(defmove :ke-n3a :kind :flash :clip :ke-chg1 :startup 20 :active 0 :recovery 14 :on-frame ((2 ken-charge-sfx))
  :params (:ns-next :ke-n3b :sa :ke-sa-c1 :aura-k 1.5 :charge-sa t))
;; AS n = n segments, each a fresh SP press; only the last knocks down or launches
(defmove-copy :ke-as1 :ke-k3 :kind :sp :callout "KITTE MIRO YO" :dmg 40 :on-hit :knockdown :flags nil)   ; (no flash-step steal since 2026-10-29: the user, 「不需要每個角色的 NS1 都剝奪閃步量表」)
(defmove-copy :ke-as2b :ke-buttagiru :on-hit :launch :dmg 100 :on-frame nil :params (:melee-range 2.6))
(defmove-copy :ke-as2 :ke-k1 :kind :sp :clip :ke-smash :clip-s 16 :reach 1.7 :arc 100 :dmg 55 :on-hit :stagger :params (:ns-next :ke-as2b))
(defmove-copy :ke-as3c :ke-meteor :dmg 170 :on-hit :knockdown :on-frame nil :params (:melee-range 3.4))
(defmove-copy :ke-as3b :ke-k2 :kind :sp :dmg 55 :on-hit :stagger :params (:ns-next :ke-as3c))
(defmove-copy :ke-as3 :ke-k1 :kind :sp :dmg 50 :on-hit :stagger :params (:ns-next :ke-as3b))

;;; ---------------------------------------------------------------- the Shikai, Nozarashi (DUEL_KEN_V3 §3-§9, 2026-11-03)
;;; Two pointers by grip: 1 the cleaver slung, half-crouched: the lunge, the spins, the one-hand dance; 2 the blade's back on the shoulder,
;;; the hilt forward: the hilt jab and flick, then both hands on the raised hilt, the great-sword swings. A segment's :params :lv is the
;;; unlock level L it needs (read at the route's start: CORE-SNAP-LV!, KEN-LV); :lv-up marks a same-pointer AS (its first clean hit raises
;;; L, as an NS route's does: KEN-HIT); the bursts (:burst, the damage by the old L: KEN-DMG-MULT) and the special ASs are picked by
;;; KEN-AS-PICK; J4-J7 (:lv 3) only at L3 (KEN-LINK-OK). Every figure §9's table (the user: 「可以，照這份做」; knobs until the playtest);
;;; every move has its own clip since the art round (DUEL_KEN_V3 §15; :clip-s = the startup: speed 1).
(defmove :ke-s-j1 :kind :quick :clip :ke-s-cut1 :clip-s 9 :startup 9 :active 3 :recovery 12 :dmg 40 :adv-block -2
  :reach 2.4 :arc 100 :on-hit :flinch :slide 0.8)
(defmove :ke-s-j2 :kind :quick :clip :ke-s-cut2 :clip-s 9 :startup 9 :active 3 :recovery 13 :dmg 40 :adv-block -2
  :reach 2.4 :arc 100 :on-hit :flinch)
(defmove :ke-s-j3 :kind :quick :clip :ke-s-cut3 :clip-s 11 :startup 11 :active 4 :recovery 18 :dmg 55 :adv-block -4
  :reach 3.85 :arc 140 :on-hit :stagger)                               ; (no :ender: J4 follows it at L3; reach: the drawn blade, §7.8:
                                                                       ;  the borrowed arm-locked spin reaches 3.77 m, FK; 4.00 m
                                                                       ;  with the lower grip, §12: 3.65 -> 3.85)
(defmove-copy :ke-s-j4 :ke-s-j1 :clip :ke-s-cut4 :clip-s 9 :dmg 45 :slide 0.0 :params (:lv 3 :special-as t))   ; the special string (L3): SP after J4-J6 = the
(defmove-copy :ke-s-j5 :ke-s-j2 :clip :ke-s-cut5 :clip-s 9 :dmg 45 :params (:lv 3 :special-as t))               ; pointer's special AS, after J7 = the Bankai
(defmove-copy :ke-s-j6 :ke-s-j1 :clip :ke-s-cut6 :clip-s 10 :startup 10 :dmg 50 :slide 0.0 :params (:lv 3 :special-as t))
(defmove-copy :ke-s-j7 :ke-s-j3 :clip :ke-s-cut7 :clip-s 12 :startup 12 :dmg 70 :params (:lv 3 :bankai-as t))
(defmove-copy :ke-s-sa :ke-s-j1 :clip :ke-s-cut-sa :clip-s 8 :startup 8 :dmg 40 :reach 2.2 :slide 1.4)          ; the one-hand cut in an NS gap
;; pointer 1 「突進迴旋」: the lunge cut (L0), the spin-through sweep (L1), the reverse spin (L2), the sword dance and the spinning leap (L3)
(defmove :ke-s-n1e :kind :flash :clip :ke-s-p1e :clip-s 14 :callout nil :startup 14 :active 4 :recovery 24 :dmg 100 :adv-block -6
  :reach 2.8 :arc 100 :on-hit :crumple :slide 2.0 :params (:lv 3))
(defmove :ke-s-n1d :kind :flash :clip :ke-s-p1d :clip-s 10 :startup 10 :active 8 :recovery 16 :adv-block -4 :reach 2.4 :arc 100
  :hits ((10 12 :dmg 35 :on-hit :flinch) (16 18 :dmg 35 :on-hit :stagger)) :params (:lv 3 :ns-next :ke-s-n1e))
(defmove :ke-s-n1c :kind :flash :clip :ke-s-p1c :clip-s 12 :startup 12 :active 4 :recovery 20 :dmg 65 :adv-block -4
  :reach 2.8 :arc 360 :on-hit :stagger :params (:lv 2 :ns-next :ke-s-n1d))
(defmove :ke-s-n1b :kind :flash :clip :ke-s-p1b :clip-s 12 :startup 12 :active 4 :recovery 20 :dmg 60 :adv-block -4
  :reach 2.8 :arc 360 :on-hit :stagger :params (:lv 1 :ns-next :ke-s-n1c))
(defmove :ke-s-n1a :kind :flash :clip :ke-s-p1a :clip-s 16 :callout "TOSSHIN" :startup 16 :active 4 :recovery 22 :dmg 70 :adv-block -4
  :reach 2.6 :arc 100 :on-hit :stagger :slide 3.0 :params (:ns-next :ke-s-n1b))
;; pointer 2 「扛肩柄擊」: the hilt jab and flick (L0), both hands, the overhead (L1), the sweep (L2), the turning cut (L3)
(defmove :ke-s-n2e :kind :flash :clip :ke-s-p2e :clip-s 18 :startup 18 :active 5 :recovery 28 :dmg 140 :adv-block -8
  :reach 3.0 :arc 120 :on-hit :crumple :params (:lv 3))
(defmove :ke-s-n2d :kind :flash :clip :ke-s-p2d :clip-s 14 :startup 14 :active 4 :recovery 20 :dmg 100 :adv-block -4
  :reach 2.8 :arc 140 :on-hit :stagger :params (:lv 2 :ns-next :ke-s-n2e))
(defmove :ke-s-n2c :kind :flash :clip :ke-s-p2c :clip-s 16 :startup 16 :active 5 :recovery 24 :dmg 110 :adv-block -6
  :reach 2.8 :arc 90 :on-hit :crumple :params (:lv 1 :ns-next :ke-s-n2d))
(defmove :ke-s-n2b :kind :flash :clip :ke-s-flick :clip-s 10 :startup 10 :active 3 :recovery 16 :dmg 50 :adv-block -4
  :reach 1.2 :arc 80 :on-hit :stagger :slide 0.6 :params (:ns-next :ke-s-n2c))
(defmove :ke-s-n2a :kind :flash :clip :ke-s-jab :clip-s 14 :callout "TSUKA-UCHI" :startup 14 :active 3 :recovery 16 :dmg 45 :adv-block -4
  :reach 1.4 :arc 70 :on-hit :stagger :slide 1.0 :params (:ns-next :ke-s-n2b))   ; (the hilt's short reach: a step in, the scripted
                                                                                  ;  2.2 m scene whiffed it without one)
;; the ASs that keep the pointer (:lv-up): one segment more per L; the last at L3 knocks down
(defmove-copy :ke-s-as1d :ke-s-n1e :kind :sp :dmg 110 :on-hit :knockdown :blend 3 :params (:lv 3 :lv-up t))   ; (blend 3: its clip
                                                                                                          ;  starts on NS1d's landing, the AS
                                                                                                          ;  comes from NS1c: no pop, §21)
(defmove-copy :ke-s-as1c :ke-s-n1c :kind :sp :params (:lv 2 :lv-up t :ns-next :ke-s-as1d))
(defmove-copy :ke-s-as1b :ke-s-n1b :kind :sp :params (:lv 1 :lv-up t :ns-next :ke-s-as1c))
(defmove-copy :ke-s-as1 :ke-s-n1a :kind :sp :startup 14 :params (:lv-up t :ns-next :ke-s-as1b))
(defmove-copy :ke-s-as2d :ke-s-n2e :kind :sp :dmg 150 :on-hit :knockdown :params (:lv 3 :lv-up t))
(defmove-copy :ke-s-as2c :ke-s-n2d :kind :sp :params (:lv 2 :lv-up t :ns-next :ke-s-as2d))
(defmove-copy :ke-s-as2b :ke-s-n2c :kind :sp :on-hit :stagger :params (:lv 1 :lv-up t :ns-next :ke-s-as2c))
(defmove-copy :ke-s-as2 :ke-s-n2a :kind :sp :startup 12 :dmg 50 :params (:lv-up t :ns-next :ke-s-as2b))
;; the bursts (an AS that writes the other pointer, §5.2: 「固定動作、提高傷害，只有 1~2 段」): one blow, 100 / 150 / 200 / 260 by the old L
(defmove :ke-s-burst1 :kind :sp :clip :ke-s-zangaeshi :clip-s 14 :callout "ZANGAESHI" :startup 14 :active 5 :recovery 26 :dmg 100 :adv-block -8
  :reach 2.8 :arc 120 :on-hit :knockdown :params (:burst (100 150 200 260)))     ; to pointer 1: off the shoulder, into the sling
(defmove :ke-s-burst2 :kind :sp :clip :ke-s-issen :clip-s 12 :callout "TOSSHIN-ISSEN" :startup 12 :active 5 :recovery 26 :dmg 100 :adv-block -8
  :reach 2.6 :arc 100 :on-hit :knockdown :slide 3.5 :params (:burst (100 150 200 260)))   ; to pointer 2: through him, onto the shoulder
;; the special ASs (SP after J4-J6 at L3)
(defmove :ke-s-sp1 :kind :sp :clip :ke-s-wheel :clip-s 12 :callout "DAISHARIN" :startup 12 :active 14 :recovery 26 :adv-block -10
  :reach 3.0 :arc 360 :hits ((12 14 :dmg 60 :on-hit :stagger) (18 20 :dmg 60 :on-hit :stagger) (24 26 :dmg 120 :on-hit :launch)))
(defmove :ke-s-sp2 :kind :sp :clip :ke-s-meteor :clip-s 20 :callout "INSEKI-GIRI" :startup 20 :active 4 :recovery 30 :dmg 260 :adv-block -12
  :reach 3.0 :arc 90 :on-hit :knockdown :slide 3.0)

;;; ================================================================ Bankai (卍解) and 片腕 KATAUDE (docs/duel/DUEL_KEN_BANKAI.md)
;;; The oni: the broken cleaver hacks, a fist, one gouge, one drop, the teeth, the shield-and-all cut, the punch and the
;;; split. Every K link, L, SP1, SP2, I and O spends a pip of the arm (UDE); the K links and the specials :rend (armour
;;; and his mirror's stance don't stop them). Frame data: the DUEL_STRINGS §2.1 budget (J 8 / 8 / 9, K1 17, K2 / K3 S_eff 14).
(defmove :ke-b-j1 :kind :quick :clip :ke-q1 :clip-s 7 :startup 8 :active 3 :recovery 12 :dmg 38 :adv-block -2
  :reach 1.28 :arc 100 :on-hit :flinch :slide 1.0)                  ; TATAKI-GIRI: hacked down, lunging like a beast
(defmove :ke-b-j2 :kind :quick :clip :ke-q2 :clip-s 7 :startup 8 :active 3 :recovery 13 :dmg 38 :adv-block -2
  :reach 1.28 :arc 100 :on-hit :flinch)                              ; NAGI-HARAI: the backhand sweep
(defmove :ke-b-j3 :kind :quick :clip :ke-b-hook :startup 9 :active 3 :recovery 18 :dmg 50 :adv-block -4
  :reach 0.8 :arc 60 :on-hit :stagger :slide 0.6 :flags (:ender))    ; GENKOTSU: a left hook to the face
(defmove :ke-b-k1 :kind :flash :clip :ke-f1 :clip-s 16 :startup 17 :active 4 :recovery 20 :dmg 120 :adv-block -3
  :reach 3.4 :arc 120 :on-hit :stagger :guard 28 :flags (:rend))     ; ONATA: the hatchet chop
(defmove :ke-b-k2 :kind :flash :clip :ke-f2 :enter 6 :startup 20 :active 4 :recovery 24 :dmg 100 :adv-block -3
  :reach 3.0 :arc 90 :on-hit :stagger :guard 28 :flags (:rend))      ; EGURI-AGE: gouging up from the floor
(defmove :ke-b-k3 :kind :flash :clip :ke-r-f2 :clip-s 21 :enter 7 :startup 21 :active 5 :recovery 34 :dmg 150 :adv-block -20
  :vol (:cap 0.3 3.7 1.2 0.55) :on-hit :crumple :guard 36 :flags (:ender :rend))   ; TATAKI-OTOSHI: the drop
(defmove-copy :ke-b-j2s :ke-b-j2)
(defmove-copy :ke-b-k2s :ke-b-k2)
;; L, KAMICHIGIRI: a short lunge, the left hand clamps, the teeth: nothing guards it (guard, DRINK, the ward, a parry, a
;; stance, armour); Step / Hoho iframes dodge it. +9 on hit: his J1 combos after it (knob: R 28 -> 30)
(defmove :ke-b-bite :kind :sig :clip :ke-b-bite :callout "KAMICHIGIRI" :startup 10 :active 3 :recovery 28 :dmg 120
  :reach 1.5 :arc 60 :slide 0.8 :on-hit :crumple :flags (:grab :unguardable :rend))
;; Shift+K, TATE-GOTO: through guard and arm together: the whole 6 m line guard-crushes (a Guard Break)
(defmove :ke-b-split :kind :sp :clip :ke-meteor :clip-s 26 :callout "TATE-GOTO" :startup 24 :active 4 :recovery 30 :dmg 260
  :adv-block -16 :vol (:cap 0.3 6.0 0.5 0.5) :on-hit :knockdown :kb 3.0 :flags (:ranged :guard-crush :rend)
  :on-frame ((24 ken-tate-goto)) :params (:melee-range 3.2))
;; Shift+L's follow-up, NAGURI-TOBASHI: the charge connects, then a left straight into the chest, 6 m (not a command: the
;; kit's (:ke-charge :land :ke-b-punch) string, which KEN-FLURRY starts)
(defmove :ke-b-punch :kind :sp :clip :ke-b-fist :clip-s 9 :callout "NAGURI-TOBASHI" :startup 6 :active 3 :recovery 30 :dmg 150
  :adv-block -16 :reach 2.0 :arc 90 :on-hit :knockback :kb 6.0 :guard 22 :flags (:rend))
;; O, MAPPUTATSU: LEAP CLEAVE with the Bankai's Kikon cinematic (the Gerard cleaved in two)
(defmove-copy :ke-b-kikon :ke-kikon-n :clip :ke-b-leap :callout "MAPPUTATSU" :cine ken-oni-kikon-cine)   ; (the oni's leap: art only)
;;; The Bankai on the core system (the user, 2026-11-02, DUEL_KEN_CORE §8: 「A 加 B 的自毀之臂」, the arm 「大招的燃料」): pointer 1 the
;;; maw (撓咬: claw, bite, rip), pointer 2 the broken cleaver as a one-hand axe (斷刀劈砍: leap cut, flat-side hammer), pointer 3 the
;;; self-destroying arm (自毀之臂: every segment burns a pip, :params :pips, CORE-PIPS-OK-P; none left: it doesn't start); AS3 in canon's
;;; order (ch. 670: the leap cut, the chin punch, the vertical split). An NS segment the SA can follow crumples, never knocks down (§443).
;;; Clips: the Bankai's existing ones as placeholders until the art round (the claw = the hook, the stances their own since DUEL_KEN_V3 §27).
(defmove-copy :ke-b-sa1 :ke-b-j3 :dmg 40 :startup 8 :clip-s 9 :flags nil :slide 0.8)                  ; the left hook
(defmove-copy :ke-b-n1c :ke-b-bite :kind :flash :callout nil :startup 14 :dmg 100 :on-hit :crumple :flags (:rend))   ; the rip
(defmove-copy :ke-b-n1b :ke-b-bite :kind :flash :startup 12 :dmg 90 :on-hit :stagger :params (:ns-next :ke-b-n1c))   ; KAMICHIGIRI
(defmove-copy :ke-b-n1a :ke-b-j3 :kind :flash :callout "TSUKAMI" :startup 16 :clip-s 9 :dmg 70 :reach 2.2 :arc 90 :slide 1.5
  :on-hit :stagger :flags (:rend) :params (:ns-next :ke-b-n1b :sa :ke-b-sa1))                        ; the claw lunge
(defmove-copy :ke-b-as1 :ke-b-bite :kind :sp :callout "KUICHIGIRI" :dmg 120 :on-hit :knockdown :flags (:unguardable :rend))   ; bites the arm off
(defmove-copy :ke-b-sa2 :ke-b-j1 :dmg 45 :startup 8)                                                  ; a short hack
(defmove-copy :ke-b-n2b :ke-b-k3 :startup 18 :dmg 100 :on-hit :crumple :flags (:rend))                ; the flat-side hammer
(defmove-copy :ke-b-n2a :ke-b-k1 :callout "TOBIGIRI" :startup 16 :dmg 90 :slide 3.0 :on-hit :stagger
  :params (:ns-next :ke-b-n2b :sa :ke-b-sa2))                                                          ; the leap cut
(defmove-copy :ke-b-as2b :ke-b-k1 :kind :sp :startup 18 :dmg 110 :on-hit :launch)                    ; the leap chop up
(defmove-copy :ke-b-as2 :ke-b-punch :callout "NAGURI-TOBASHI" :startup 12 :dmg 60 :on-hit :stagger :kb 1.0 :params (:ns-next :ke-b-as2b))
(defmove-copy :ke-b-sa3 :ke-b-j2 :dmg 50 :startup 8)                                                  ; the broken blade's sweep
(defmove-copy :ke-b-n3c :ke-b-split :kind :flash :startup 20 :dmg 220 :on-hit :crumple :kb 1.0 :on-frame nil :params (:melee-range 3.2 :pips 1))
(defmove-copy :ke-b-n3b :ke-b-k1 :callout nil :startup 14 :dmg 150 :on-hit :crumple :params (:pips 1 :ns-next :ke-b-n3c))
(defmove-copy :ke-b-n3a :ke-b-k2 :callout "UDE-KUDAKI" :startup 16 :dmg 130 :on-hit :stagger :params (:pips 1 :ns-next :ke-b-n3b :sa :ke-b-sa3))
(defmove-copy :ke-b-as3c :ke-b-split :dmg 200 :on-frame nil :params (:melee-range 3.2 :pips 1))      ; TATE-GOTO
(defmove-copy :ke-b-as3b :ke-b-punch :callout nil :startup 12 :dmg 60 :on-hit :stagger :kb 1.0 :slide 2.0   ; (the lunge: AS3a's push left him out of 2.0 m)
  :params (:ns-next :ke-b-as3c))
(defmove-copy :ke-b-as3 :ke-b-k1 :kind :sp :callout nil :startup 16 :dmg 55 :on-hit :stagger :params (:ns-next :ke-b-as3b))

;;; ================================================================ forms
(defkit :kenpachi :base
  :name "KENPACHI" :body :kenpachi :weapon :ken-katana :stance :ke-stance
  :intro :ke-intro :win :ke-win
  :walk *walk-kenpachi* :run *run-kenpachi* :run-clips (:ke-run :ke-skate-b :ke-slide-r :ke-slide-l) :reishi *reishi-max* :aura :reiatsu
  :cornered *cornered-per-konpaku* :cornered-max *cornered-max* :reset-reiatsu *reset-reiatsu-bonus*
  :absorb-sfx :laugh
  :stun-tolerance 26.0                          ; the hidden stun (DUEL_DESIGN.md): he takes the most before he flies
  :open-s *ken-open-base* :hs-dmg *ken-hs-dmg*  ; the cadence by form (DUEL_KEN_CORE §7.2; every form inherits :hs-dmg)
  :commands (:q :ke-j1 :f :ke-k1 :sig :ke-stance :sp1 :ke-buttagiru :sp2 :ke-charge
             :breaker :ke-breaker :kikon :ke-kikon)
  :grid (:ke-j1 :ke-j2 :ke-j3 :ke-k1 :ke-k2 :ke-k3 :ke-j2s :ke-k2s)
  :core (:ns (:ke-n1a :ke-n2a :ke-n3a) :as (:ke-as1 :ke-as2 :ke-as3) :sa :ke-sa :mult 1.2
         :stances (:ke-st-chain :ke-st-rush :ke-st-kamae)          ; the idle clip by SP pointer
         :kikon-cines (ken-kikon-cine ken-clash-kikon-cine ken-sky-split-cine))   ; (pointer 2's: DUEL_KEN_CORE §6)
  :strings ((:ke-charge :land :ke-flurry))
  :awaken-form :nozarashi
  :hooks (:boss ken-boss :armor ken-armor :clash ken-clash :dmg-mult ken-dmg-mult)                       ; the DANGAI boss: the Bankai at FIGHT, the arm never spent (ken-meter.lisp)
  :ai (:intents (:approach 2 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.0 4.0) :pressure (1.0 2.6) :zone (4.0 6.0) :defend (3.0 5.0))
       :moves ((0.0 1.3 :q 5 :f 2 :breaker 1 :sp2 1 :sig 2 nil 3)    ; J up close only (DUEL_STRINGS §13), K beyond
               (1.3 3.0 :f 4 :breaker 1 :sp2 1 :sig 2 nil 3)
               (3.0 4.0 :f 1 :sp1 2 :step 1 nil 2)
               (4.0 6.0 :sp1 4 :sp2 2 nil 1)
               (6.0 99.0 :step 1 :kikon 1 nil 1))                      ; the charge / leap as a poke
       :guard 0.35 :hoho 0.2 :awaken-above 0.0 :sp-cancel-bars 1 :dash 0.8 :kikon-range 9.0
       :react (:projectile :sig :flash-startup :sig) :block-string 0.8
       :reflex ken-ai-reflex :assist-guard ken-assist-guard :sp-ender ken-sp-ender :sig-hold ken-sig-hold))   ; a blocked string goes on (guard pressure)

(defkit :kenpachi :nozarashi :inherit :base    ; the Shikai (DUEL_KEN_V3 §3-§9): two pointers by grip, the unlock level L (the kit meter)
  :awakening t :mult *nozarashi-mult* :startup-add 0 :reach-mult 1.0 :open-s nil   ; (as written: §9's figures; the base's cadence off)
  :passives (:projectile-cut) :form-name "SHIKAI" :kikon-konpaku 2
  :endless-form :nozarashi                      ; ENDLESS (frozen): the Shikai
  :weapon :nozarashi :stance :ke-s-st-1 :aura :reiatsu :swing-sfx :whoosh-cleaver
  :enter-clips (:ke-release :ke-nome) :cine ken-nozarashi-cine :respect-callout "OMOSHIREE!"
  :meter (:name "KAIHO" :max 3 :start 0 :lv t :draw ken-hud-meter :label ken-hud-label) :meter-gain nil   ; L 0-3 (KEN-HIT raises it)
  :hooks (:p ken-card-bankai :armor ken-armor :clash ken-clash :dmg-mult ken-dmg-mult
          :lv ken-lv :as-pick ken-as-pick :hit ken-hit :link-ok ken-link-ok :draw ken-draw)   ; (P: DANGAI's 隨時卍解 card, frozen;
                                                                                              ;  :draw the sword wind by L, ken-look.lisp)
  :commands (:q :ke-s-j1 :f nil :sig nil :sp1 nil :sp2 nil :kikon :ke-kikon-n)   ; (the core system: J and SP only; the Breaker the base's)
  :strings ((:ke-s-j1 :q :ke-s-j2) (:ke-s-j2 :q :ke-s-j3) (:ke-s-j3 :q :ke-s-j4) (:ke-s-j4 :q :ke-s-j5) (:ke-s-j5 :q :ke-s-j6)
            (:ke-s-j6 :q :ke-s-j7))                                      ; (J4-J7: L3, KEN-LINK-OK)
  ;; AS: J1-J2 + SP pointer 1's, J3+ pointer 2's (§5.2 「看 J 打幾段」); KEN-AS-PICK turns one that writes the other pointer into the burst
  ;; (:as entries 3 / 4) and J4-J6 / J7 into the special AS (5 / 6) / the Bankai
  :core (:ns (:ke-s-n1a :ke-s-n2a) :as (:ke-s-as1 :ke-s-as2 :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2) :sa :ke-s-sa :mult 1.2
         :as-by-press (1 1 2)
         :stances (:ke-s-st-1 :ke-s-st-2)                               ; the slung hilt low / the shoulder (§14)
         :kikon-cines (ken-s-kikon1-cine ken-s-kikon2-cine))   ; KAITENZAN / TSUITENZAN (ken-look.lisp, DUEL_KEN_V3 §19)
  :ai (:intents (:approach 2 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.0 4.0) :pressure (1.2 3.0) :zone (4.0 6.0) :defend (3.0 5.0))
       :moves ((0.0 1.6 :q 5 :f 2 :sig 3 :breaker 1 :sp2 1 nil 3)
               (1.6 3.4 :f 4 :sig 3 :breaker 1 :sp2 1 nil 3)
               (3.4 4.2 :f 1 :sp1 2 :step 1 nil 2)
               (4.2 6.0 :sp1 4 :sp2 2 nil 1)
               (6.0 99.0 :step 1 :kikon 1 nil 1))
       :guard 0.35 :hoho 0.2 :awaken-above 0.0 :sp-cancel-bars 1 :dash 0.8 :kikon-range 5.0 :kikon-p 0.25 :o-ender 0.25
       :react (:projectile :sig :flash-startup :sig) :block-string 0.8
       :reflex ken-ai-reflex :assist-guard ken-assist-guard :sp-ender ken-sp-ender :sig-hold ken-sig-hold))

;;; ---------------------------------------------------------------- the two Bankai (DUEL_KEN_V3 §26, 2026-11-04)
;;; SP after the Shikai's J7 (KEN-AS-PICK, combat.lisp BANKAI!): the Bankai of the pointer he was on: 狂嵐 KYORAN from pointer 1 (fast,
;;; one hand: the lunge, the spins, the dance), 斬壞 ZANKAI from pointer 2 (heavy: the dropped chop, the dragged chop, the sweep, the turning
;;; chop). One pointer each, its own J1-J5; SP after Jn (n 1-4) = the one AS with n segments (its J link's :as-ptr names it: the first n - 1
;;; the NS's a, b, c, the last the finisher, knocking down); SP after J5 = the special AS (千切 CHIGIRI / TATE-GOTO), whose end takes him back
;;; to the Shikai on that pointer, L 0, -1 Konpaku unless it is his last (KEN-BK-TICK). Every NS / AS segment burns *KEN-BK-COST* of his
;;; Reishi, never below 1 (KEN-BK-COST). The user's answers: 「4 段（照表）」「只有一種 AS」「各自一串」 (§26.1). Clips: the Shikai's borrowed
;;; until the art round (:clip-s their own S); J1-J5 their own since the art round (§28: 1.8 / 1.9 m, drawn by FK), NS a-d and the
;;; finishers since §29 (:clip-s = S; a and the finisher :blend 3, entered from neutral or after a J or an NS segment).
(defparameter *ken-bk-cost* 40 "Reishi each Bankai NS / AS segment burns from him, never below 1 (DUEL_KEN_V3 §4 B2, §26: 「卍解每次使用 NS 與 AS 都會對自己
造成傷害，最多扣至剩 1 點血量」; 40 mine, about 3 % of 1300).")
;; 狂嵐 KYORAN (from pointer 1)
(defmove :ke-kr-j1 :kind :quick :clip :ke-kr-cut1 :clip-s 7 :startup 7 :active 3 :recovery 11 :dmg 40 :adv-block -2
  :reach 1.8 :arc 100 :on-hit :flinch :slide 0.8 :params (:as-ptr 1))
(defmove :ke-kr-j2 :kind :quick :clip :ke-kr-cut2 :clip-s 7 :startup 7 :active 3 :recovery 12 :dmg 40 :adv-block -2
  :reach 1.8 :arc 100 :on-hit :flinch :params (:as-ptr 2))
(defmove :ke-kr-j3 :kind :quick :clip :ke-kr-cut3 :clip-s 8 :startup 8 :active 3 :recovery 12 :dmg 45 :adv-block -2
  :reach 1.8 :arc 100 :on-hit :flinch :params (:as-ptr 3))
(defmove :ke-kr-j4 :kind :quick :clip :ke-kr-cut4 :clip-s 8 :startup 8 :active 3 :recovery 13 :dmg 45 :adv-block -2
  :reach 1.8 :arc 100 :on-hit :flinch :params (:as-ptr 4))
(defmove :ke-kr-j5 :kind :quick :clip :ke-kr-cut5 :clip-s 10 :startup 10 :active 4 :recovery 18 :dmg 65 :adv-block -4
  :reach 1.8 :arc 100 :on-hit :stagger :params (:as-ptr 5))
(defmove-copy :ke-kr-sa :ke-kr-j1 :startup 8 :params (:as-ptr 1))                                ; the cut in an NS gap
(defmove :ke-kr-nd :kind :flash :clip :ke-kr-ns-d :clip-s 8 :startup 8 :active 8 :recovery 14 :adv-block -4 :reach 1.8 :arc 100
  :hits ((8 10 :dmg 40 :on-hit :flinch) (13 15 :dmg 40 :on-hit :crumple)) :on-frame ((0 ken-bk-cost)))   ; the sword dance
(defmove :ke-kr-nc :kind :flash :clip :ke-kr-ns-c :clip-s 10 :startup 10 :active 4 :recovery 18 :dmg 70 :adv-block -4
  :reach 1.9 :arc 360 :on-hit :stagger :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-kr-nd))      ; the reverse spin
(defmove :ke-kr-nb :kind :flash :clip :ke-kr-ns-b :clip-s 10 :startup 10 :active 4 :recovery 18 :dmg 70 :adv-block -4
  :reach 1.9 :arc 360 :on-hit :stagger :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-kr-nc))      ; the spin
(defmove :ke-kr-na :kind :flash :clip :ke-kr-ns-a :clip-s 14 :blend 3 :callout "KYORAN" :startup 14 :active 4 :recovery 20 :dmg 80 :adv-block -4
  :reach 1.8 :arc 100 :on-hit :stagger :slide 3.0 :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-kr-nb))   ; the lunge cut
(defmove :ke-kr-fin :kind :sp :clip :ke-kr-fin :clip-s 12 :blend 3 :startup 12 :active 4 :recovery 22 :dmg 110 :adv-block -6
  :reach 1.8 :arc 100 :on-hit :knockdown :slide 2.0 :on-frame ((0 ken-bk-cost)))                       ; the AS's last: the spinning leap cut
(defmove-copy :ke-kr-as1 :ke-kr-fin :callout "KYORAN")                                                 ; AS after J1: the finisher alone
(defmove-copy :ke-kr-as2 :ke-kr-na :kind :sp :startup 12 :params (:ns-next :ke-kr-fin))                ; after J2: a, the finisher
(defmove-copy :ke-kr-as3b :ke-kr-nb :kind :sp :params (:ns-next :ke-kr-fin))
(defmove-copy :ke-kr-as3 :ke-kr-na :kind :sp :startup 12 :params (:ns-next :ke-kr-as3b))               ; after J3: a, b, the finisher
(defmove-copy :ke-kr-as4c :ke-kr-nc :kind :sp :params (:ns-next :ke-kr-fin))
(defmove-copy :ke-kr-as4b :ke-kr-nb :kind :sp :params (:ns-next :ke-kr-as4c))
(defmove-copy :ke-kr-as4 :ke-kr-na :kind :sp :startup 12 :params (:ns-next :ke-kr-as4b))               ; after J4: a, b, c, the finisher
(defmove :ke-kr-sp :kind :sp :clip :ke-kr-chigiri :clip-s 12 :callout "CHIGIRI" :startup 12 :active 4 :recovery 44 :dmg 300 :adv-block -10
  :reach 2.4 :arc 360 :on-hit :knockdown :params (:dmg-at 38)                                          ; 千切, the space-cutting draw (§5.4):
  :on-frame ((0 ken-bk-special) (12 ken-chigiri-open) (15 ken-chigiri-wave) (21 ken-chigiri-wave) (27 ken-chigiri-wave)
             (38 ken-chigiri-burst)))                                                                  ;  the damage on the burst (§30.1)
;; 斬壞 ZANKAI (from pointer 2)
(defmove :ke-zh-j1 :kind :quick :clip :ke-zh-cut1 :clip-s 9 :startup 9 :active 3 :recovery 12 :dmg 50 :adv-block -2
  :reach 1.9 :arc 100 :on-hit :flinch :slide 0.6 :params (:as-ptr 1))
(defmove :ke-zh-j2 :kind :quick :clip :ke-zh-cut2 :clip-s 10 :startup 10 :active 3 :recovery 13 :dmg 55 :adv-block -2
  :reach 1.9 :arc 100 :on-hit :flinch :params (:as-ptr 2))
(defmove :ke-zh-j3 :kind :quick :clip :ke-zh-cut3 :clip-s 10 :startup 10 :active 4 :recovery 16 :dmg 55 :adv-block -3
  :reach 1.9 :arc 140 :on-hit :flinch :params (:as-ptr 3))
(defmove :ke-zh-j4 :kind :quick :clip :ke-zh-cut4 :clip-s 11 :startup 11 :active 3 :recovery 16 :dmg 60 :adv-block -3
  :reach 1.9 :arc 100 :on-hit :flinch :params (:as-ptr 4))
(defmove :ke-zh-j5 :kind :quick :clip :ke-zh-cut5 :clip-s 13 :startup 13 :active 4 :recovery 20 :dmg 85 :adv-block -4
  :reach 1.9 :arc 100 :on-hit :stagger :on-frame ((13 ken-bk-slam)) :params (:as-ptr 5))
(defmove-copy :ke-zh-sa :ke-zh-j1 :params (:as-ptr 1))
(defmove :ke-zh-nd :kind :flash :clip :ke-zh-ns-d :clip-s 16 :startup 16 :active 5 :recovery 26 :dmg 130 :adv-block -6
  :reach 2.0 :arc 120 :on-hit :crumple :on-frame ((0 ken-bk-cost)))                                    ; the turning chop
(defmove :ke-zh-nc :kind :flash :clip :ke-zh-ns-c :clip-s 14 :startup 14 :active 4 :recovery 20 :dmg 100 :adv-block -4
  :reach 2.0 :arc 180 :on-hit :stagger :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-zh-nd))      ; both hands, the flat sweep
(defmove :ke-zh-nb :kind :flash :clip :ke-zh-ns-b :clip-s 12 :startup 12 :active 4 :recovery 20 :dmg 90 :adv-block -4
  :reach 1.9 :arc 140 :on-hit :stagger :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-zh-nc))      ; the dragged rising chop
(defmove :ke-zh-na :kind :flash :clip :ke-zh-ns-a :clip-s 16 :blend 3 :callout "ZANKAI" :startup 16 :active 5 :recovery 24 :dmg 100 :adv-block -6
  :reach 1.9 :arc 90 :on-hit :crumple :on-frame ((0 ken-bk-cost)) :params (:ns-next :ke-zh-nb))       ; the shoulder-drop overhead chop
(defmove :ke-zh-fin :kind :sp :clip :ke-zh-fin :clip-s 16 :blend 3 :startup 16 :active 5 :recovery 26 :dmg 150 :adv-block -8
  :reach 2.0 :arc 120 :on-hit :knockdown :on-frame ((0 ken-bk-cost)))                                  ; the AS's last: the turning chop
(defmove-copy :ke-zh-as1 :ke-zh-fin :callout "ZANKAI")
(defmove-copy :ke-zh-as2 :ke-zh-na :kind :sp :startup 12 :params (:ns-next :ke-zh-fin))
(defmove-copy :ke-zh-as3b :ke-zh-nb :kind :sp :params (:ns-next :ke-zh-fin))
(defmove-copy :ke-zh-as3 :ke-zh-na :kind :sp :startup 12 :params (:ns-next :ke-zh-as3b))
(defmove-copy :ke-zh-as4c :ke-zh-nc :kind :sp :params (:ns-next :ke-zh-fin))
(defmove-copy :ke-zh-as4b :ke-zh-nb :kind :sp :params (:ns-next :ke-zh-as4c))
(defmove-copy :ke-zh-as4 :ke-zh-na :kind :sp :startup 12 :params (:ns-next :ke-zh-as4b))
(defmove :ke-zh-sp :kind :sp :clip :ke-zh-tategoto :clip-s 20 :callout "TATE-GOTO" :startup 20 :active 4 :recovery 30 :dmg 320 :adv-block -12
  :reach 2.4 :arc 90 :on-hit :knockdown :params (:dmg-at 34)                                           ; TATE-GOTO (canon ch. 670): the
  :on-frame ((0 ken-bk-special) (20 ken-tategoto-split) (34 ken-tategoto-cut)))                       ;  damage as its rift cuts (§30.2)

;;; the Bankai kits: the oni's body and the broken cleaver, ×*BANKAI-KEN-MULT*; no meter, no arm (the arm's pips went with V3)
(defmacro def-ken-bankai (form &key name ns as sa strings stance kikon-cine)
  "One of his two Bankai kits (DUEL_KEN_V3 §26): one pointer, its own J string, NS, five AS entries (Jn + SP, n 1-5) and Kikon."
  `(defkit :kenpachi ,form :inherit :base
     :hooks (:tick ken-bk-tick :armor ken-armor :clash ken-clash :dmg-mult ken-dmg-mult)
     :endless-form :nozarashi :enter-clips (:ke-release :ke-nome) :respect-callout "OMOSHIREE!"
     :awakening t :mult *bankai-ken-mult* :form-name ,name :kikon-konpaku 4 :open-s nil
     :bankai-form nil :passives (:projectile-cut)
     :body :kenpachi-oni :weapon :ke-broken :stance ,stance :aura :oni
     :hide (:haori :sleeve-long :arm-wreck :crack-1 :crack-2 :crack-3 :crack-4)
     :run-clips (:ke-b-run :ke-b-skate-b :ke-b-slide-r :ke-b-slide-l)
     :cine ken-bankai-cine :enter-hook nil :swing-sfx :whoosh-cleaver
     :commands (:q ,(first (first strings)) :f nil :sig nil :sp1 nil :sp2 nil :kikon :ke-b-kikon)
     :strings ,strings
     :core (:ns (,ns) :as ,as :sa ,sa :mult 1.2 :as-writes (1 1 1 1 1)
            :stances (,stance) :kikon-cines (,kikon-cine))
     :ai (:intents (:approach 3 :pressure 6 :zone 0 :defend 0)
          :ranges (:approach (1.8 3.6) :pressure (1.0 2.4) :zone (4.0 6.0) :defend (3.0 5.0))
          :moves ((0.0 1.6 :q 5 :breaker 1 nil 2) (1.6 3.4 :breaker 1 :step 1 nil 2) (3.4 99.0 :step 1 nil 1))
          :guard 0.2 :hoho 0.2 :awaken-above 0.0 :sp-cancel-bars 1 :dash 1.0 :kikon-range 5.0 :kikon-p 0.4 :o-ender 0.3
          :block-string 0.85
          :reflex ken-ai-reflex :assist-guard ken-assist-guard :sp-ender ken-sp-ender :sig-hold ken-sig-hold)))
(def-ken-bankai :bankai :name "KYORAN" :ns :ke-kr-na :sa :ke-kr-sa :stance :ke-b-kr-stance :kikon-cine ken-oni-kikon-cine
  :as (:ke-kr-as1 :ke-kr-as2 :ke-kr-as3 :ke-kr-as4 :ke-kr-sp)
  :strings ((:ke-kr-j1 :q :ke-kr-j2) (:ke-kr-j2 :q :ke-kr-j3) (:ke-kr-j3 :q :ke-kr-j4) (:ke-kr-j4 :q :ke-kr-j5)))
(def-ken-bankai :bankai-2 :name "ZANKAI" :ns :ke-zh-na :sa :ke-zh-sa :stance :ke-b-zh-stance :kikon-cine ken-sky-split-cine
  :as (:ke-zh-as1 :ke-zh-as2 :ke-zh-as3 :ke-zh-as4 :ke-zh-sp)
  :strings ((:ke-zh-j1 :q :ke-zh-j2) (:ke-zh-j2 :q :ke-zh-j3) (:ke-zh-j3 :q :ke-zh-j4) (:ke-zh-j4 :q :ke-zh-j5)))

;;; ================================================================ hooks (called through the data's symbols)

(defun ken-bk-cost (e)
  "A Bankai NS / AS segment's frame 0: *KEN-BK-COST* of his Reishi burnt, never below 1 (DUEL_KEN_V3 §26)."
  (let ((g (gauges e)))
    (setf (gauges-reishi g) (burn (gauges-reishi g) *ken-bk-cost*))
    (clog "~a bankai cost ~d, reishi ~d" (side-name e) *ken-bk-cost* (gauges-reishi g))))

(defun ken-bk-special (e)
  "The special AS's frame 0 (千切 / TATE-GOTO): its cost, and the way back to the Shikai once it is over (KEN-BK-TICK)."
  (ken-bk-cost e)
  (setf (fighter-bk-out (fighter e)) t))

(defparameter *ken-chigiri-stop* 8 "Frames 千切's burst freezes the fight (HITSTOP; DUEL_KEN_V3 §30.1, mine: the beat's weight).")
(defun ken-chigiri-open (e)
  "千切's draw (DUEL_KEN_V3 §30, a look): the look that opens the cuts round him (KEN-CHIGIRI-LOOK)."
  (spawn-look e 'ken-chigiri-look :life 32))
(defun ken-chigiri-wave (e) "千切: a wave of three cuts opens while he gathers (a look: the shimmer, a tremor)." (emit :ken-bk-burst e :chigiri-wave))
(defun ken-chigiri-burst (e)
  "千切: the roar and the cuts bursting, the space shattering, frozen *KEN-CHIGIRI-STOP* frames (§30.1; the damage lands on this
frame too: :dmg-at, DELAY-HIT)."
  (hitstop *ken-chigiri-stop*)
  (emit :ken-bk-burst e :chigiri))
(defun ken-tategoto-split (e)
  "TATE-GOTO's chop lands (§30, a look): the space split from the sky 2.2 m before him (its rift: KEN-TATEGOTO-LOOK, cutting on 34:
KEN-TATEGOTO-CUT), the floor cracked 6 m, chips thrown up."
  (let ((p (pos-of e)) (yaw (yaw-of e)))
    (spawn-look e 'ken-tategoto-look :x (+ (aref p 0) (* 2.2 (fwd-x yaw))) :z (+ (aref p 2) (* 2.2 (fwd-z yaw))) :life (+ *tategoto-cut* 2))
    (spawn-ground-line e 6.0 50 :crack)
    (ground-scar p yaw '(1.9 3.4 4.9) 0.8)
    (emit :ken-bk-burst e :tategoto)))

(defparameter *ken-tategoto-stop* 10 "Frames TATE-GOTO's rift cutting freezes the fight (HITSTOP; DUEL_KEN_V3 §30.2, mine).")
(defun ken-tategoto-cut (e)
  "TATE-GOTO's rift cuts (§30.2, after KUKAN-GIRI): frozen *KEN-TATEGOTO-STOP* frames, the hit, the ink gash (the damage lands on this
frame too: :dmg-at, DELAY-HIT)."
  (hitstop *ken-tategoto-stop*)
  (emit :ken-bk-burst e :tategoto-cut))

(defun ken-bk-tick (e f g)
  "The Bankai kits' :tick (GAUGE-SYSTEM): the special AS over (he is out of it, past any Kikon and its cinematic), back to the Shikai on
the pointer he came from (狂嵐 1, 斬壞 2), L 0, -1 Konpaku unless it is his last (§4: 「照樣放出、不扣魂」; DUEL_KEN_V3 §4 B3, §26)."
  (when (and (fighter-bk-out f) (not (member (fighter-state f) '(:move :cine))))
    (let ((from (if (eq (fighter-form f) :bankai-2) 2 1)))
      (setf (fighter-bk-out f) nil)
      (when (> (gauges-konpaku g) 1)
        (decf (gauges-konpaku g))
        (emit :konpaku e 1))
      (set-form e :nozarashi)
      (setf (fighter-ptr f) from (gauges-meter g) 0f0)
      (when (eq (fighter-state f) :idle) (to-idle e 0))
      (clog "~a BANKAI ends: Shikai pointer ~d, konpaku ~d" (side-name e) from (gauges-konpaku g)))))





(defun ken-stance-release (e)
  "The stance is released: the cut deals 100 + stored and crushes guard at stored >= 150."
  (let ((f (fighter e)))
    (multiple-value-bind (dmg crush) (stance-release (fighter-stored f))
      (setf (fighter-dmg-bonus f) (- dmg *stance-base-damage*) (fighter-crush f) crush (fighter-stored f) 0)
      (when crush (callout e "KITTE MIRO YO!"))
      (emit :sfx (if crush :laugh :whoosh-heavy) e))))

(defun ken-ground-crack (e)
  "Buttagiru lands: a 3 m crack in the ground (a look)."
  (let ((p (pos-of e)))
    (spawn-ground-line e 3.5 50 :crack)
    (ground-scar p (yaw-of e) '(1.2 2.8) 0.9))
  (emit :sfx :ground-crack e))

(defun ken-bk-slam (e)
  "斬壞's J5 lands (DUEL_KEN_V3 §28): a short crack ahead where the head bit in (a look)."
  (spawn-ground-line e 2.4 40 :crack)
  (ground-scar (pos-of e) (yaw-of e) '(1.9) 0.7)
  (emit :sfx :ground-crack e))

(defun ground-scar (p yaw ds r)
  "A look: crack marks R m wide at DS metres ahead of P along YAW, that stay for the round, and chips thrown up
(stage.lisp STAGE-MARK / STAGE-DEBRIS; Phase 6 destruction)."
  (dolist (d ds)
    (let ((x (+ (aref p 0) (* d (fwd-x yaw)))) (z (+ (aref p 2) (* d (fwd-z yaw)))))
      (stage-mark :crack x z r) (stage-debris x z 3))))

(defun ken-charge-tick (e)
  "SP2 dash: 14 m/s during the active frames until it touches; still holding the button when the
dash starts = guard-crushing (the Breaker property)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (sf (fighter-sf f)))
    (when (eq (fighter-phase f) :main)
      (when (and (= sf (mv-s mv)) (vpad-down (pilot-vpad (pilot e)) (fighter-button f)))
        (setf (fighter-crush f) t))
      (when (and (<= (mv-s mv) sf) (< sf (+ (mv-s mv) (mv-a mv))) (null (fighter-contact f)) (> (fighter-dist f) 1.2))
        (let ((v (motion-vel (motion e))) (sp (move-param e :dash-speed)) (yaw (yaw-of e)))
          (setf (aref v 0) (f32 (* sp (fwd-x yaw))) (aref v 2) (f32 (* sp (fwd-z yaw)))))))))

(defun ken-flurry (e)
  "The SP2 dash connected: on a hit, the flurry (4 more cuts + a launcher)."
  (when (eq (fighter-contact (fighter e)) :hit)
    (start-move e (kit-next (kit-of e) :ke-charge :land))
    (setf (fighter-contact (fighter e)) :hit (fighter-land-sf (fighter e)) 0)))

(defun ken-leap-cleave (e)
  "LEAP CLEAVE lands: a short gash split into the ground ahead (a look)."
  (spawn-ground-line e 3.0 45 :meteor)
  (emit :sfx :ground-crack e))

(defun ken-meteor-cut (e)
  "Split the Meteor: the cleave splits the ground 12 m ahead (a look)."
  (let ((p (pos-of e)))
    (spawn-ground-line e 12.0 60 :meteor)
    (ground-scar p (yaw-of e) '(2.0 5.0 8.0 11.0) 1.2))
  (emit :sfx :ground-crack e))

(defun ken-tate-goto (e)
  "TATE-GOTO: the cut goes through guard and arm and splits the ground 6 m ahead (a look)."
  (let ((p (pos-of e)))
    (spawn-ground-line e 6.0 50 :meteor)
    (ground-scar p (yaw-of e) '(1.5 3.5 5.5) 1.0))
  (emit :sfx :ground-crack e))

;;; ================================================================ the CPU (his forms' :ai :reflex / :sp-ender / :sig-hold)
;;; AI v2 (docs/duel/DUEL_AI_V2.md; docs/research/ai-v2-drsi/kenpachi): the generic CPU (ai.lisp) plus his own answers, each
;;; a chance by difficulty (EASY <= NORMAL <= HARD; NORMAL near the shipped CPU, HARD the full version). He sees the
;;; opponent only through the perceived SNAP (and the HUD gauges, as ai.lisp does); dice from SIM-RND01.
;;;   J1 lunge      J1 slides 0.8 m (the Bankai's 1.0): punish and open from reach + slide (ai.lisp stops at reach +
;;;                 0.2); at mid range walk into that range instead of waiting there for a K1 (never into a J masher)
;;;   anti-Breaker  a Breaker in its aura / dash is :breaker (any hit counters it): K1's 2.8 m+ reach meets the dash
;;;                 while the strike is still far off, else J1, else a Hoho (ai.lisp's J1 at 2.4 m came too late)
;;;   Hoho a commit his K / L / SP whose hit falls inside the perfect-Hoho lead (perceived startup minus our delay)
;;;   anti-mash     he mashes J (AI-MASH-P) and stands out of his J's hit: the stance (KITTE MIRO YO) soaks the string,
;;;                 the cut returns it (100 + stored)
;;;   no slow reset a blocked string's reset with a J1 of >= 10 f (RYOTE's / NOMIHOSE's MEN) gets guarded: guard instead
;;;   enders        off a landed J3 / K3 the O ender more often (the push out of reach: the O's dash still connects),
;;;                 else the charge (SP2, it chases off the ender)
;;;   the Bankai    leaves him 1 Konpaku: at HARD only as a finisher (<= 2 left, 3 vs <= 4, 4 vs <= 2), a rule
;;;   first strike  (cell b0a1, from b1a0) his perceived closing speed (two ring SNAPs) times J1 into its lunge's reach /
;;;                 K1 into its reach outside his J's: in full against a J masher, a little against anyone else
;;;   far punish    he recovers / reels beyond J1's lunge: SP2's charge or SP1 when it lands before he is free (KEN-ARRIVE)
;;;   sig punish    (cell b0a2) he recovers / reels within J1's lunge: the charge (5 cuts + a launcher, ~185, all his own)
;;;                 instead of a J1 string when the bars allow and it lands before he is free (round 2: the line cut first)
;;;   SP1 ender     (round 2, b0a0) off a landed J3 / K3 the form's SP1 when it fits in the reel (it chases the pushed
;;;                 victim): Buttagiru / Split the Meteor / TATE-GOTO, one bar, before the O ender
(defparameter *ken-ai-anti-breaker* '(:easy 0.0 :normal 0.2 :hard 0.9) "Ken's CPU: answer a Breaker by the reach model.")
(defparameter *ken-ai-hoho* '(:easy 0.0 :normal 0.1 :hard 0.75) "... Hoho a K / L / SP into its perfect lead.")
(defparameter *ken-ai-mash-stance* '(:easy 0.0 :normal 0.005 :hard 0.35) "... the stance vs a J masher (per free step).")
(defparameter *ken-ai-no-reset* '(:easy 0.0 :normal 0.2 :hard 0.8) "... guard instead of a slow J1 reset.")
(defparameter *ken-ai-o-ender* '(:easy 0.0 :normal 0.1 :hard 0.85) "... the O ender's extra chance off a landed ender.")
(defparameter *ken-ai-lunge-punish* '(:easy 0.0 :normal 0.3 :hard 0.9) "... J1 from its lunge's reach on a punish.")
(defparameter *ken-ai-lunge* '(:easy 0.0 :normal 0.0 :hard 0.06) "... J1 from its lunge's reach in neutral (per step).")
(defparameter *ken-ai-walk-in* '(:easy 0.0 :normal 0.005 :hard 0.8) "... walk into J1's range (per step).")
(defparameter *ken-ai-bankai-strict* '(:easy 0.0 :normal 0.0 :hard 0.0) "... the Bankai only as a finisher (HARD: a rule; off since 2026-10-31: the Bankai no longer costs Konpaku, DUEL_SUBLIMATION §3).")
(defparameter *ken-ai-sp2-ender* '(:easy 0.0 :normal 0.1 :hard 0.6) "... else the SP2 ender (the charge) off it.")
(defparameter *ken-ai-far-punish* '(:easy 0.0 :normal 0.2 :hard 0.9) "... beyond J1's lunge: the charge / leap / K1 on a punish.")
(defparameter *ken-ai-first-strike* '(:easy 0.0 :normal 0.002 :hard 0.35) "... J1 / K1 timed to his closing speed vs a masher.")
(defparameter *ken-ai-first-strike-n* '(:easy 0.0 :normal 0.0 :hard 0.15) "... the same vs anyone else (per step).")
(defparameter *ken-ai-sig-punish* '(:easy 0.0 :normal 0.1 :hard 0.5) "... the charge (SP2) as a close punish when it lands in time.")
(defparameter *ken-ai-sp1-ender* '(:easy 0.0 :normal 0.1 :hard 0.9) "... SP1 (the line cut / the leap) off a landed ender when it lands in his reel.")
(defparameter *ken-charge-mpf* 0.233 "The charge's dash, metres per frame (14 m/s).")
(defparameter *ken-breaker-speed* 0.16 "A Breaker dash's metres per frame (9-10 m/s), for the anti-Breaker timing.")

(defun ken-ai-reflex (e b s d)
  "Kenpachi's :reflex (ai.lisp AI-REFLEX, free states, before the generic reflexes): a command or NIL."
  (ken-bankai-gate e b)
  (or (ken-anti-breaker e b s d)
      (ken-anti-mash e b s d)
      (ken-hoho-commit e b s d)
      (ken-no-reset e b d)
      (ken-sig-punish e b s d)
      (ken-far-punish e b s d)
      (ken-first-strike e b s d)
      (ken-lunge e b s d)
      (ken-walk-in e b s d)))

(defun ken-assist-guard (e b s d)
  "His forms' :assist-guard (assist.lisp AUTO GUARD): his defensive answers only, the timed anti-Breaker hit and the Hoho
into a K / L / SP's perfect lead."
  (or (ken-anti-breaker e b s d) (ken-hoho-commit e b s d)))

(defun ken-bankai-gate (e b)
  "The Bankai leaves him 1 Konpaku: at HARD (*KEN-AI-BANKAI-STRICT*) only as a finisher or with little to lose: <= 2 of his
own left, 3 with him at <= 4, 4 with him at <= 2; else this cup-3 stay's roll is spent (ai.lisp AI-BANKAI-P skips it). NIL."
  (let* ((kit (kit-of e)) (k (gauges-konpaku (gauges e))) (ko (gauges-konpaku (gauges (opp-of e)))))
    (when (and (kit-bankai-form kit) (not (brain-bankai-rolled b)) (bankai-allowed-p t (drive-full-p e))
               (not (or (<= k 2) (and (<= k 3) (<= ko 4)) (and (<= k 4) (<= ko 2))))
               (brain-roll b *ken-ai-bankai-strict*))
      (setf (brain-bankai-rolled b) t))
    nil))

(defun ken-walk-in (e b s d)
  "Neutral, he isn't attacking, between our J1's reach (with its lunge) and 3 m: walk in (strafing a little) toward J1's
range instead of waiting there for a K1 (*KEN-AI-WALK-IN* a step); not into a J masher (he comes: the stance, the
lunge); :WAIT (the stick is set here)."
  (let ((q (kit-command-move (kit-of e) :q)))
    (when (and q (member (snap-state s) '(:idle :run :guard)) (member (state-of e) '(:idle :run)) (not (ai-mash-p b))
               (> d (max (+ (ken-lunge-reach e) 0.1) (+ (mv-reach q) 0.3))) (< d 3.0)
               (brain-roll b *ken-ai-walk-in*))
      (vpad-stick! (pilot-vpad (pilot e)) (* 0.3 (brain-strafe b)) 1f0)
      (why b :walk-in :wait))))

(defun ken-lunge-reach (e)
  "How far his J1 reaches with its own lunge (:slide): reach + slide (ai.lisp counts reach + 0.2 only)."
  (let ((q (kit-command-move (kit-of e) :q))) (if q (+ (mv-reach q) (mv-slide q)) 0.0)))

(defun ken-lunge (e b s d)
  "J1 from its lunge's reach (beyond ai.lisp's reach + 0.2): punish his recovery or a reeling opponent when J1 lands before
he is free (one roll per move: *KEN-AI-LUNGE-PUNISH*), or open on him there in neutral when no move of his is coming
(*KEN-AI-LUNGE* a step)."
  (let* ((q (kit-command-move (kit-of e) :q)) (lr (ken-lunge-reach e)) (left (snap-left-seen s b)))
    (when (and q (> d (+ (mv-reach q) 0.2)) (<= d (+ lr 0.1)) (kit-command-ok-p e :q))
      (cond ((and (snap-punishable-p s)
                  (< (snap-left s) 99) (>= left (+ (mv-s q) 2))
                  (< (brain-react-roll b) (brain-chance b *ken-ai-lunge-punish*)))
             (why b :lunge-punish :q))
            ((and (member (snap-state s) '(:idle :run))
                  (brain-roll b *ken-ai-lunge*))
             (why b :lunge :q))))))

(defun ken-anti-breaker (e b s d)
  "His Breaker in its aura / dash within 6 m (one roll per Breaker): where it will be when our K1 / J1 is active (its dash
at *KEN-BREAKER-SPEED*, from where we saw it a perception delay ago) and when its strike lands (the trigger range, then 8 f):
K1 if it is within K1's reach before the strike, else J1, else a Hoho close to the strike; meanwhile wait (:WAIT)."
  (when (and (eq (snap-kind s) :breaker) (member (snap-phase s) '(:aura :dash)) (< d 6.0)
             (< (brain-react-roll b) (brain-chance b *ken-ai-anti-breaker*)))
    (let* ((kit (kit-of e)) (v *ken-breaker-speed*) (dl (brain-delay b)) (trig *breaker-trigger*)
           (dash (if (eq (snap-phase s) :dash) dl (- dl *breaker-aura*)))   ; frames it has dashed by now (< 0: aura left)
           (wait (max 0 (- dash)))                                          ; aura frames still to come
           (de (- d (* v (max 0 dash))))                                    ; its distance when the dash goes on from now
           (strike (+ wait (/ (max 0.0 (- de trig)) v) *breaker-startup*)))  ; frames until its strike is active
      (flet ((fits (cmd)
               (let ((mv (kit-command-move kit cmd)))
                 (and mv (kit-command-ok-p e cmd) (< (+ (mv-s mv) 1) strike)
                      (<= (max trig (- de (* v (max 0 (- (mv-s mv) wait))))) (+ (mv-reach mv) 0.3))))))
        (cond ((fits :f) (why b :anti-breaker :f))
              ((fits :q) (why b :anti-breaker :q))
              ((and (<= strike 13) (hoho-ready-p e))
               (why b :anti-breaker :hoho))
              ((> strike 13) :wait))))))                                     ; (not yet: the generic J1 would come early)

(defun ken-hoho-commit (e b s d)
  "His K / L / SP coming at us whose hit, as we see it, falls 1-12 f from now (the perfect-Hoho lead): Hoho it (one roll per
move), with flash-step to spare; a K whose startup the stance can still beat is left to the stance (the kit's :react)."
  (let* ((g (gauges e)) (left (snap-lead-seen s b)))
    (when (and (eq (snap-state s) :move) (member (snap-kind s) '(:flash :sig :sp)) (eq (snap-phase s) :main)
               (snap-live-p s) (<= 1 left *perfect-lead*) (snap-near-p s e d 1.0)   ; (an :x-axis line: on it, ai.lisp)
               (not (member :grab (snap-flags s))) (not (snap-reflect-p s))   ; (a reflect is :opp-reflect's)
               (hoho-ready-p e)
               (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g))
               (not (and (eq (snap-kind s) :flash) (getf (ai-table e :react) :flash-startup) (< d 4.0)
                         (>= left (+ *stance-in* 2)) (< (brain-react-roll b) *ai-react-p*)))
               (< (brain-hoho-roll b) (brain-chance b *ken-ai-hoho*)))
      (why b :hoho-commit :hoho))))

;;; (from cell b1a0: an arrival model per command and the opponent's perceived closing speed)
(defun ken-closing (e b s d)
  "His perceived closing speed toward us (m/f, > 0: coming), from the SNAP we see and the one before it in the ring."
  (let* ((ring (brain-ring b)) (n (length ring))
         (s1 (svref ring (mod (- (brain-head b) (brain-delay b) 2) n))) (p (pos-of e)))
    (if (or (null s1) (< d 0.01)) 0.0
        (/ (- (+ (* (- (snap-x s1) (snap-x s)) (- (snap-x s) (aref p 0)))
                 (* (- (snap-z s1) (snap-z s)) (- (snap-z s) (aref p 2)))))
           d))))

(defun ken-arrive (e cmd d)
  "Frames until command CMD's hit touches him at D metres (he stands), or NIL: out of its reach / can't start."
  (let ((mv (kit-command-move (kit-of e) cmd)))
    (when (and mv (kit-command-ok-p e cmd))
      (let ((r (mv-reach mv)) (sl (mv-slide mv)) (st (mv-s mv)))
        (cond ((eq (mv-name mv) :ke-charge)                        ; the dash runs until it touches
               (let ((run (max 0.0 (- d r 0.4)))) (and (<= run (* *ken-charge-mpf* 24)) (+ st (ceiling run *ken-charge-mpf*)))))
              ((> sl 2.0) (and (<= (- sl 1.0) d (+ sl r -0.5)) st))  ; the leap (Buttagiru): it lands sl ahead
              (t (and (<= d (+ r (min sl 0.8) 0.05)) st)))))))

(defun ken-punish (e b s d tag table near)
  "KEN-SIG-PUNISH (NEAR: within J1's lunge) and KEN-FAR-PUNISH (beyond it, under 9 m): he recovers or reels with more than
4 frames left as perceived, on the per-move roll below TABLE's chance: the first of KEN-SP-ORDER that gets there before he
is free, as why TAG."
  (let ((left (snap-left-seen s b)))
    (when (and (snap-punishable-p s)
               (< (snap-left s) 99) (> left 4)
               (if near (<= d (+ (ken-lunge-reach e) 0.1)) (and (> d (+ (ken-lunge-reach e) 0.1)) (< d 9.0)))
               (< (brain-react-roll b) (brain-chance b table)))
      (let ((c (loop for c in (ken-sp-order e)    ; (a loop, not FIND-IF's closure: its captured E D LEFT consed every call)
                     when (let ((t0 (ken-arrive e c d))) (and t0 (< t0 (1- left)))) return c)))
        (and c (why b tag c))))))

(defun ken-sp-order (e)
  "The punish SPs to try, best first: the line cut (SP1, one bar, 240 / 260) when the form's SP1 is one (not the leap, not
NOMIHOSE's cash-out), then the charge (SP2, two bars, ~185); else the charge, then SP1 (the leap: KEN-ARRIVE's own model)."
  (let ((sp (kit-command-move (kit-of e) :sp1)))
    (if (and sp (< (mv-slide sp) 2.0) t)
        '(:sp1 :sp2)
        '(:sp2 :sp1))))

(defun ken-sig-punish (e b s d)
  "He recovers or reels within J1's lunge (KEN-LUNGE's range and closer) and the charge (SP2: 5 cuts + a launcher, ~185,
all his own) lands before he is free: the charge instead of a J1 string, on the per-move roll below *KEN-AI-SIG-PUNISH*
(the rest goes on to J1)."
  (ken-punish e b s d :sig-punish *ken-ai-sig-punish* t))

(defun ken-far-punish (e b s d)
  "He recovers or reels beyond J1's lunge (KEN-LUNGE's range): the signature command that gets there before he is free
(SP2's charge, SP1's leap / cut), else K1; one roll per move (*KEN-AI-FAR-PUNISH*)."
  (ken-punish e b s d :far-punish *ken-ai-far-punish* nil))

(defun ken-first-strike (e b s d)
  "Neutral first strike timed to his perceived closing speed: J1 when he will be inside its lunge's reach as it lands,
else K1 when he walks into K1's reach outside his own J's (a masher walks into it); *KEN-AI-FIRST-STRIKE* a step."
  (when (and (member (snap-state s) '(:idle :run :guard)) (member (state-of e) '(:idle :run)) (< d 4.0)
             (brain-roll b (if (ai-mash-p b) *ken-ai-first-strike* *ken-ai-first-strike-n*)))
    (let ((cv (max 0.0 (ken-closing e b s d))) (his (kit-command-move (kit-of (opp-of e)) :q))
          (q (kit-command-move (kit-of e) :q)) (f (kit-command-move (kit-of e) :f)))
      (flet ((at (c mv) (and mv (kit-command-ok-p e c) (- d (* cv (+ (mv-s mv) (brain-delay b)))))))
        (let ((dq (at :q q)) (df (at :f f)))
          (cond ((and dq (<= dq (+ (mv-reach q) (min 0.8 (mv-slide q))))) (why b :first-strike :q))
                ((and df (> cv 0.02) (<= (if his (+ (mv-reach his) (mv-slide his) 0.2) 1.6) df (+ (mv-reach f) 0.1)))
                 (why b :first-strike :f))))))))

(defun ken-stance-p (kit)
  "Is KIT's L the stance (KITTE MIRO YO; the Bankai's L is the bite)?"
  (let ((mv (kit-command-move kit :sig))) (and mv (member :stance (mv-flags mv)))))

(defun ken-anti-mash (e b s d)
  "He mashes J (AI-MASH-P) within 2.4 m and no J of his is about to land (he walks, waits or recovers): the stance soaks
his string and cuts back (KEN-SIG-HOLD holds it through the string)."
  (let ((kit (kit-of e)))
    (when (and (ai-mash-p b) (< d 2.4) (ken-stance-p kit) (kit-command-ok-p e :sig)
               (or (not (eq (snap-state s) :move))
                   (and (eq (snap-kind s) :quick) (>= (snap-sf s) (snap-active-end s))))
               (not (member (snap-state s) '(:stun :air :down :wakeup)))
               (brain-roll b *ken-ai-mash-stance*))
      (why b :anti-mash :sig))))

(defun ken-no-reset (e b d)
  "Our blocked string just ended and he still guards: a J1 of 10 f or more is too slow a reset (his J beats it): guard."
  (let* ((f (fighter e)) (q (kit-command-move (kit-of e) :q)))
    (when (and (eq (brain-was b) :move) (eq (fighter-contact f) :block) q (>= (mv-s q) 10)
               (< d (+ (mv-reach q) 0.2)) (guarding-p (opp-of e))
               (brain-roll b *ken-ai-no-reset*))
      (why b :no-reset :guard))))

(defun ken-sp-ender (e kit)
  "His forms' :sp-ender (ai.lisp STRING-REFLEX: a landed string's last link, the O ender's own roll failed): the O ender
anyway, *KEN-AI-O-ENDER* by difficulty (not on a red opponent: that already rushes; not to finish a Soul Break), else
Shift+L (the charge into the flurry; it chases off the ender) *KEN-AI-SP2-ENDER*. (AI-BRAIN: the assist's for a human.)"
  (let ((b (ai-brain e)))
    (when b
      (cond ((ken-line-ender-p e kit b) :sp1)
            ((and (not (kikon-ready-p e)) (ai-o-ender-ok-p e kit)
                  (brain-roll b *ken-ai-o-ender*))
             :kikon)
            ((and (kit-command-ok-p e :sp2) (brain-roll b *ken-ai-sp2-ender*)) :sp2)))))

(defun ken-line-ender-p (e kit b)
  "Off a landed ender (J3 staggers 26 f, K3 crumples 40 f; the push leaves him out of reach, but an SP started off a
pushing ender chases), the form's SP1 when its startup + 2 fits in that reel: Buttagiru (22 f, 180, base / KATAUDE),
Split the Meteor (26 f, 240, KATATE / RYOTE: off a K3 only), TATE-GOTO (24 f, 260, the Bankai); one bar, all his own
damage, before the O ender (63) or the charge (two bars, ~185); not NOMIHOSE's cash-out (the kit's own rule spends it);
*KEN-AI-SP1-ENDER*."
  (let* ((mv (fighter-move (fighter e))) (hw (and mv (plusp (length (mv-hits mv))) (svref (mv-hits mv) 0)))
         (sp (kit-command-move kit :sp1)))
    (and hw sp (< (+ (mv-s sp) 2) (getf *reaction-frames* (hw-react hw) 0)) t
         (not (ai-sb-finish-p e)) (kit-command-ok-p e :sp1 kit)
         (brain-roll b *ken-ai-sp1-ender*))))

(defun ken-sig-hold (kit d &optional e)
  "Frames his CPU holds L: the stance against a J masher through his string (36 f), else as ai.lisp holds a stance."
  (declare (ignore d))
  (let ((mv (kit-command-move kit :sig)))
    (cond ((not (and mv (mv-hold mv))) 1)                                  ; (the Bankai's bite: a tap)
          ((and e (ai-brain e) (ken-stance-p kit) (ai-mash-p (ai-brain e))) 36)
          (t (+ 12 (floor (* (sim-rnd01) 40)))))))

;;; ================================================================ cinematics
;;; The grammar of every cinematic is in cinema.lisp (docs/style/STYLE_STORM_DESIGN.md §5); Kenpachi (black robe, black
;;; hair) goes on the white card.
(defcine ken-kikon-cine (a v :len 192 :hold 112)
  "Base Kikon (paced by user review 3): beat 0; Kenpachi on a white card, low and dutch under the 呑め、野晒 stamp in
black (his release words), silence; two reckless cuts from two sides, laughing; before the last a held close
wide-angle push in silence; the last cut through the victim: a negative, then a manga page (the blood and the yellow
stay), the Konpaku shatter and a splash; he laughs; a wide from behind."
  (at 0 (face-each-other a v 2.0)
      (cine-clip a :ke-kikon :blend 2 :speed (/ 72.0 142.0))   ; its old timing, slowed to the new beats (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2))
  (at 12 (card :white a) (shot-on a 30 3.0 0.6 :look 1.4 :off -0.8) (lens 44 -12) (silence 52)
      (caption "呑め、野晒" :reading "NOME, NOZARASHI" :sub "MOTTO TANOSHIMASETE KURE YO!" :side 1 :ink t :hanko t))
  (at 70 (card nil) (cine-slash v :cut) (shot-on v 120 3.8 1.2) (lens 55) (play-sfx :laugh))
  (at 98 (cine-slash v :cut) (shot-on v -110 3.6 1.0) (caption-exit))
  (at 122 (hold-both a v 20) (silence 20) (lens 86))
  (during (122 142) (shot-on a 20 (+ 1.5 (* 0.4 u)) 0.5 :look 1.45))   ; a slow pull, not cuts
  (at 142 (cine-slash v :heavy) (shot-pair a v (- (camera-side a)) 5.5 1.3) (lens 55)
      (impact-frame :negative 2)
      (cine-shatter v 3)
      (impact-splash-at v 0.0 16 0.07)
      (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (shake 0.3 0.35))
  (at 144 (impact-frame :manga 12))
  (at 152 (play-sfx :laugh))
  (at 162 (shot-on a 160 4.2 0.8 :look 1.3) (lens 50)))

(defun cine-slash (v kind)
  "A cinematic cut landing on V: sparks, sound, flash."
  (multiple-value-bind (x y z) (actor-point v 1.2) (vfx-hit x y z kind))
  (play-sfx (if (eq kind :heavy) :cut-heavy :cut))
  (setf (model-flash (model v)) 0.1))

(defcine ken-sky-split-cine (a v :len 162 :hold 40)
  "Nozarashi Kikon (§4.2 sky split; paced by user review 3): beat 0; a long black card, Kenpachi silhouetted with a
yellow back-rim under the 呑め、野晒 stamp, silence; the cleave: a negative, then a manga page, the line of light (white,
ink borders) splits the sky, focus lines, poses held 12 f, the screen halves shear apart; down the cut, then the ground
split from the side, then Kenpachi."
  (at 0 (face-each-other a v 2.6)
      (cine-clip a :ke-kikon-n :blend 2 :speed (/ 25.0 68.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :black a) (back-rim 56 1.0 0.85 0.23) (shot-on a 60 4.2 0.7 :look 1.6 :ahead 1.3 :off 0.8) (lens 46 8) (silence 56)
      (caption "呑め、野晒" :reading "NOME, NOZARASHI" :sub "SKY SPLIT" :side 0 :hanko t))
  (at 68 (card nil) (cine-slash v :heavy) (play-sfx :kikon-slash) (play-sfx :ground-crack) (shake 0.4 0.5)
      (impact-frame :negative 2) (hold-both a v 12) (focus-lines 30)
      (shot-on a 180 10.0 3.6 :look 1.2 :ahead 5.0) (lens 60)     ; down the cut: it splits the screen at its centre
      (cine-shatter v 3))
  (at 70 (impact-frame :manga 12))
  ;; (the ground split is part of the look, on the cine clock: a sim hazard would freeze with the sim)
  (during (68 162) (let ((q (pos-of v))) (vfx-sky-split (aref q 0) (aref q 2) (yaw-of a) (/ (- cf 68) 60.0) 1.5)))
  (at 102 (shot-on v 95 7.5 1.2 :look 1.0) (lens 50) (caption-exit))
  (at 132 (shot-on a -20 5.0 0.7 :look 1.4) (lens 45)))

;; pointer 2's Kikon (DUEL_KEN_CORE §6: 「新做硬扛衝撞演出」): he takes the first blow and drives through it
(defcine ken-clash-kikon-cine (a v :len 176 :hold 100)
  "Pointer 2's Kikon: beat 0; Kenpachi on a white card, low and dutch, the stamp 来いよ in black, silence; the shoulder charge
drives the victim into the ground (heavy cut, a shake); a held close wide-angle push in silence; the smash through him: a
negative, then a manga page, the Konpaku shatter and a splash; he laughs; a wide from behind."
  (at 0 (face-each-other a v 2.2)
      (cine-clip a :ke-rush-a :blend 2 :speed (/ 26.0 60.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2))
  (at 12 (card :white a) (shot-on a 30 3.0 0.6 :look 1.4 :off -0.8) (lens 44 -12) (silence 52)
      (caption "来いよ" :reading "KOI YO" :sub "ORE WA TOMARANEE" :side 1 :ink t :hanko t))
  (at 70 (card nil) (cine-slash v :heavy) (shot-on v 120 3.8 1.2) (lens 55) (play-sfx :ground-crack) (shake 0.4 0.5) (caption-exit))
  (at 98 (hold-both a v 20) (silence 20) (lens 86))
  (during (98 122) (shot-on a 20 (+ 1.5 (* 0.4 u)) 0.5 :look 1.45))
  (at 122 (cine-clip a :ke-smash :blend 2 :speed 0.6)
      (cine-slash v :heavy) (shot-pair a v (- (camera-side a)) 5.5 1.3) (lens 55)
      (impact-frame :negative 2)
      (cine-shatter v 3)
      (impact-splash-at v 0.0 16 0.07)
      (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (shake 0.3 0.35))
  (at 124 (impact-frame :manga 12))
  (at 134 (play-sfx :laugh))
  (at 146 (shot-on a 160 4.2 0.8 :look 1.3) (lens 50)))

(defcine ken-nozarashi-cine (a v :len 108 :hold 84)
  "NOME, NOZARASHI (§5; paced by user review 3; no eyepatch in any form, TYBW: the release is the whole first beat):
beat 0 on the face close-up, the head down, the reiatsu rising round him; NOME: the head thrown back grinning as it
bursts (a negative); the yellow reiatsu pillar held long on a black card, Kenpachi silhouetted with a yellow back-rim
(the only time yellow floods the frame), a skull flashing in it for 2 drawings (f40-49); close, low and wide-angle while the katana grows into the cleaver, in silence;
the 野晒 / 呑め、 stamp in black on a white card."
  (at 0 (cine-clip a :ke-release :blend 3 :speed (/ 1.0 1.5)) (cine-clip v (kit-stance (kit-of v)) :blend 6)
      (setf (model-weapon (model a)) :ken-katana)
      (shot-on a 10 1.9 1.9 :look 1.85)
      (hold-both a v 10) (impact-frame :negative 2) (play-sfx :awaken-rise))
  (at 26 (let ((p (pos-of a)))
        (vfx-awaken-burst (aref p 0) 1.0 (aref p 2) :nozarashi)
        (vfx-shockwave (aref p 0) (aref p 2) 7.0 0.6 :rgb '(1.0 0.9 0.3)))
      (impact-frame :negative 2) (play-sfx :awaken-boom) (shake 0.2 0.3))
  (at 28 (card :black a) (back-rim 30 1.0 0.85 0.23) (shot-on a 0 4.6 0.8 :look 1.6) (lens 52))
  (during (0 108) (let ((p (pos-of a)))                 ; rising through the face close-up (it lifts the hair), full at NOME
                    (vfx-aura (aref p 0) 0.0 (aref p 2) (cond ((< cf 28) 2.0) ((< cf 58) 6.5) (t 3.2)) :nozarashi (/ cf 60.0) (cine-dt)
                              :k (if (< cf 26) (+ 0.1 (* 0.02 cf)) 1.0))))   ; 28-58: the pillar
  (during (40 50) (let* ((p (pos-of a)) (yaw (yaw-of a)))   ; the skull in the pillar, 2 drawings (Phase 6)
                    (vfx-skull (- (aref p 0) (* 0.25 (fwd-x yaw))) 2.9 (- (aref p 2) (* 0.25 (fwd-z yaw))) 0.98)))
  (at 54 (cine-clip a :ke-nome :blend 2))
  (at 58 (card nil) (shot-on a 30 1.6 0.45 :look 1.5) (lens 86 -8) (silence 20))
  (at 78 (setf (model-weapon (model a)) :nozarashi)
      (impact-frame :negative 2) (card :white a) (shot-on a 20 4.4 0.8 :look 1.3 :off 0.9) (lens 42)
      (caption "野晒" :kanji2 "呑め、" :reading "NOME, NOZARASHI" :side 0 :ink t)
      (play-sfx :whoosh-cleaver))
  (at 80 (impact-frame :manga 10)))

;;; ---------------------------------------------------------------- the Bankai (docs/duel/DUEL_KEN_BANKAI.md §1.2, §3.1)
(defparameter *forest-trunks* '((0.03 0.05) (0.1 0.022) (0.62 0.04) (0.71 0.018) (0.8 0.06) (0.93 0.03))
  "The forest card's ink trunks: (x-fraction width-fraction) of the screen; Kenpachi kneels in the gap at the left third.")

(defun ken-forest (cf)
  "The Kusajishi forest (anime ep. 44, [A]; the user's decision 2026-09-28: Yachiru a tiny mono ink silhouette): on the
white card, black ink trunks (a few branches), white petals falling on twos over them, and for two drawings (f24-31) a
small ink child cut-out in front of him. UI space, a look (the cine clock CF)."
  (let* ((w (window-width)) (h (window-height)) (ink '(0.03 0.03 0.047 1)) (paper '(0.96 0.96 0.94 1))
         (dr (floor cf 2)))
    (loop for (fx fw) in *forest-trunks* for i from 0
          do (let* ((x (* fx w)) (tw (* fw w)) (lean (* (if (evenp i) 0.02 -0.015) w)))
               (%ui-poly4 (+ x lean) 0 (+ x lean tw) 0 (+ x (* 1.2 tw)) h (- x (* 0.2 tw)) h ink ink)
               (let ((by (* h (+ 0.18 (* 0.11 (mod i 3))))) (dir (if (evenp i) 1 -1)))      ; a branch
                 (%ui-poly4 (+ x (* 0.5 tw)) by (+ x (* 0.5 tw) (* dir 0.09 w)) (- by (* 0.07 h))
                            (+ x (* 0.5 tw) (* dir 0.09 w)) (- by (* 0.06 h)) (+ x (* 0.5 tw)) (+ by (* 0.02 h)) ink ink))))
    (dotimes (k 18)                                      ; the petals, re-drawn every drawing
      (let* ((px (* w (mod (+ (* k 0.137) (* 0.003 dr) (* 0.01 (sin (+ k dr)))) 1.0)))
             (py (* h (mod (+ (* k 0.071) (* 0.012 dr)) 1.0))) (r (* 0.006 h)))
        (%ui-poly4 px (- py r) (+ px r) py px (+ py r) (- px r) py paper paper)
        (ui-rect-outline (- px r) (- py r) (* 2 r) (* 2 r) ink 1)))
    (when (<= 24 cf 31)                                  ; Yachiru: 2 drawings, then gone
      (let* ((cx (* 0.52 w)) (base (* 0.8 h)) (u (* 0.05 h)) (j (if (< cf 28) 0 (* 0.08 u))))
        (%ui-poly4 (- cx (* 0.35 u)) (- base (* 1.3 u)) (+ cx (* 0.35 u)) (- base (* 1.3 u))
                   (+ cx (* 0.6 u)) base (- cx (* 0.6 u)) base ink ink)                          ; the little kimono
        (dotimes (k 8)                                                                             ; the head
          (let ((a0 (* k 0.785)) (a1 (* (1+ k) 0.785)) (hx cx) (hy (- base (* 1.75 u) j)) (r (* 0.42 u)))
            (%ui-poly4 hx hy (+ hx (* r (cos a0))) (+ hy (* r (sin a0))) (+ hx (* r (cos a1))) (+ hy (* r (sin a1))) hx hy ink ink)))
        (%ui-poly4 (+ cx (* 0.2 u)) (- base (* 2.1 u) j) (+ cx (* 0.55 u)) (- base (* 2.35 u) j)
                   (+ cx (* 0.5 u)) (- base (* 1.95 u) j) (+ cx (* 0.3 u)) (- base (* 1.9 u) j) ink ink)))))   ; a tuft

(defcine ken-bankai-cine (a v :len 186 :hold 120)
  "The Bankai (paced like user review 3: long holds, few shots; the user's decisions 2026-09-28): beat 0, Kenpachi down on
one knee, head bowed, silence (ch. 669: beaten, bleeding out); the Kusajishi forest on a white card, ink trunks, petals,
Yachiru a small ink cut-out for two drawings, the distorted doubled call (anime ep. 44); he rises into the crimson oni,
the BLOOD pillar and two rings, a negative then a manga page; close, low, wide-angle on the face: horns, white irisless
eyes, the roar held in silence; the black card, a BLOOD back-rim, the 卍解 column with the red hanko; a wide from behind,
the pillar on ones. The rules are already settled (his Konpaku 1, Reishi full): only the looks here."
  (at 0 (face-each-other a v)
      ;; (the base body without the Bankai kit's hide list: its :haori tag would take his whole torso, DUEL_KEN_REWORK §8.1;
      ;; REFRESH-LOOK at 58 puts the oni and the list back)
      (setf (model-body (model a)) (find-body :kenpachi) (model-weapon (model a)) :nozarashi (model-hide (model a)) nil
            *aura-off* a)
      (cine-clip a :sh-crumple :blend 0 :time 0.95) (cine-clip v (kit-stance (kit-of v)) :blend 6)
      (shot-on a 35 3.0 0.7 :look 0.9 :off -0.7) (lens 50 -6)
      (hold-pose v 12) (freeze 12) (impact-frame :negative 2) (silence 12)   ; (a held pose would keep his standing one)
      (impact-splash-at a 0.4 10 0.05))
  (at 12 (card :white a) (shot-on a 20 3.6 0.8 :look 0.9 :off -1.0) (lens 44)
      (caption "草鹿" :reading "KUSAJISHI" :sub "KEN-CHAN" :side 1 :ink t))
  (at 14 (play-sfx :yachiru-call))
  (during (12 58) (ken-forest cf))
  (at 58 (card nil) (refresh-look a) (setf *aura-off* nil) (caption-exit)
      (cine-clip a :ke-b-roar :blend 2)
      (let ((p (pos-of a)))
        (vfx-awaken-burst (aref p 0) 0.0 (aref p 2) :oni)
        (vfx-shockwave (aref p 0) (aref p 2) 7.0 0.6 :pal +pal-blood+)
        (vfx-shockwave (aref p 0) (aref p 2) 4.0 0.4 :pal +pal-ink+))
      (shot-on a 25 5.2 1.0 :look 1.6) (lens 55)
      (impact-frame :negative 1) (play-sfx :awaken-boom) (play-sfx :laugh :pitch 0.7) (shake 0.25 0.35))
  (at 60 (impact-frame :manga 12))
  (at 78 (shot-on a 14 1.05 1.5 :look 1.58) (lens 80 -8) (silence 20) (face-beat a :shout 0.6))
  (at 108 (card :black a) (back-rim 58 0.82 0.06 0.11) (shot-on a 20 4.4 0.8 :look 1.3 :off 0.9) (lens 42)
      (cine-clip a (kit-stance (kit-of a)) :blend 8)   ; (狂嵐 / 斬壞's own, DUEL_KEN_V3 §27)
      (caption "卍解" :reading "BANKAI" :side 0 :hanko t))
  (at 166 (card nil) (shot-on a 165 5.6 1.7 :look 1.4) (lens 50) (caption-exit))
  (during (58 186) (let ((p (pos-of a)))                ; the pillar: full from the burst, on ones in the wide
                     (vfx-aura (aref p 0) 0.0 (aref p 2) 2.4 :oni (/ cf 60.0) (cine-dt) :k (if (< cf 78) 1.0 0.8)))))

(defcine ken-oni-kikon-cine (a v :len 162 :hold 40)
  "The Bankai's Kikon MAPPUTATSU (also its Soul Break cinematic, the user's decision 2026-09-27): the sky split re-cut in the
oni's colours: beat 0; the black card, a BLOOD back-rim, the oni silhouetted with the broken cleaver raised under 卍解 /
MAPPUTATSU and the hanko, silence; one vertical cut: a negative, then a manga page, the white line splitting the victim
and the screen, the halves shearing apart (ch. 669: the Vollständig Gerard cut in two); the split from the side, ash;
Kenpachi laughing, head back."
  (at 0 (face-each-other a v 2.6) (setf *aura-off* a)      ; (the pillar smoulders out: the cut reads)
      (cine-clip a :ke-b-kikon :blend 2 :speed (/ 25.0 68.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :black a) (back-rim 56 0.82 0.06 0.11) (shot-on a 60 4.2 0.7 :look 1.6 :ahead 1.3 :off 0.8) (lens 46 8)
      (silence 56) (caption "卍解" :reading "BANKAI" :sub "MAPPUTATSU" :side 0 :hanko t))
  (at 68 (card nil) (cine-slash v :heavy) (play-sfx :kikon-slash) (play-sfx :ground-crack) (shake 0.45 0.5)
      (impact-frame :negative 2) (hold-both a v 12) (focus-lines 30)
      (shot-on v 0 5.5 1.3 :look 1.1) (lens 55)                  ; face on: the line splits him and the screen
      (cine-shatter v 3)
      (impact-splash-at v 1.0 16 0.08))
  (at 70 (impact-frame :manga 12))
  (during (68 162) (let ((q (pos-of v))) (vfx-sky-split (aref q 0) (aref q 2) (yaw-of a) (/ (- cf 68) 60.0) 1.5)))
  (at 102 (shot-on v 95 7.5 1.2 :look 1.0) (lens 50) (caption-exit))
  (at 132 (shot-on a 60 4.6 0.7 :look 1.4) (lens 45) (face-beat a :shout 1.0 t) (play-sfx :laugh :pitch 0.8)))

;;; ================================================================ debug (KEN-DEBUG through *CHAR-DEBUG*; out of debug.lisp 2026-10-21)
(declaim (special *probe*))   ; (debug.lisp's)

(defun bankai-test (k)
  "Kenpachi's Bankai tests 2387+K (docs/duel/DUEL_KEN_BANKAI.md; human P1 Kenpachi, P2 an idle Yamamoto CPU; the script presses
the keys): 1 in the Bankai at once (no cinematic), 2.2 m: KKK, a whiffed K, JJJ ...; 2 in the Bankai with 1 pip, 2.2 m: the 4th strike,
then the burst. (0, the cup-3 entry, and 3, 片腕, went with the cups and KATAUDE: DUEL_KEN_V3 §8.)"
  (setf *probe* nil)
  (ensure-battle :kenpachi :yamamoto)
  (force-form *p1* :nozarashi)
  (place *p1* *p2* (if (zerop k) 3.0 2.2))
  (full-gauges! *p1* 100f0)
  (let ((g (gauges *p1*)))
    (setf (gauges-reishi g) 300 (gauges-arm-pending g) nil
          (gauges-konpaku g) (min (gauges-konpaku g) *bankai-konpaku*)   ; (<= 4 Konpaku: the scene's, the entry was so until 2026-10-31)
          (gauges-awakened g) t (gauges-drive g) *drive-max*))     ; the entry: SPIRIT DRIVE full (2026-10-31)
  (setf (gauges-reishi (gauges *p2*)) (gauges-reishi-max (gauges *p2*)))
  (case k
    ((1 2) (let ((*skip-cines* t)) (bankai! *p1*))
     (when (= k 2) (setf (gauges-meter (gauges *p1*)) 1f0) (refresh-look *p1*))
     (place *p1* *p2* 2.2))))

(defparameter *grip-torso*
  '((:chest 0.105 -0.005 0.236 0.165 0.154) (:spine 0.11 -0.005 0.208 0.125 0.143) (:pelvis 0.0 0.0 0.165 0.09 0.127))
  "Kenpachi's torso boxes for GRIP-FRONT (ken-art.lisp: each box's half size x girth x :width 1.18, in the joint's frame,
before the body's scale): (joint centre-u centre-f half-r half-u half-f).")

(defun grip-front (jm)
  "The left arm against the torso, on joint matrices after GRIP-LEFT! (2392; allocates). In the chest's frame (world m):
the elbow's and the fist's signed distance to the chest's frontal plane (through the chest joint; + = in front), the
worst of the arm's points (the elbow, the forearm at 1/3 and 2/3, the wrist, the fist) below the shoulders (chest-frame
up < 0.2 m), each against the frontal plane of the torso segment at its height (the chest box's, else the spine's, else
the pelvis's: a twisted chest can't hide an arm behind the waist), and the deepest of them inside a *GRIP-TORSO* box.
The back plane is 0.165 m behind the frontal one: an arm point below the shoulders there is the left arm wrapped round
his back (the user, 2026-10-21: 「改完之後手反而會跑到背後欸」,
DUEL_KEN_REWORK §6.2.2)."
  (labels ((pt (j) (let ((o (* 16 j))) (list (aref jm (+ o 12)) (aref jm (+ o 13)) (aref jm (+ o 14)))))
           (ax (j k) (let ((o (+ (* 16 j) (* 4 k)))) (list (aref jm o) (aref jm (+ o 1)) (aref jm (+ o 2)))))
           (dot (a b) (reduce #'+ (mapcar #'* a b)))
           (in-frame (j p)                                   ; P in joint J's frame: (r u f), world m
             (let ((d (mapcar #'- p (pt j))))
               (loop for k below 3 for a = (ax j k) for v = (/ (dot d a) (sqrt (dot a a))) collect (if (= k 2) (- v) v)))))
    (let* ((e (pt (ji :lower-arm-l))) (h (pt (ji :hand-l))) (fist (pt (ji :weapon-l)))
           (pts (list e (mapcar (lambda (a b) (+ a (* 0.33 (- b a)))) e h) (mapcar (lambda (a b) (+ a (* 0.67 (- b a)))) e h) h fist))
           (low 1.0) (deep 0.0))
      (dolist (p pts)
        (when (< (second (in-frame (ji :chest) p)) 0.2)
          (setf low (min low (loop for (j cu nil nil hu) in *grip-torso*            ; the segment at its height
                                   for jj = (joint-index j) for s = (sqrt (dot (ax jj 0) (ax jj 0))) for l = (in-frame jj p)
                                   when (or (eq j :pelvis) (>= (second l) (* s (- cu hu)))) return (third l)))))
        (loop for (j cu cf hr hu hf) in *grip-torso*
              for jj = (joint-index j) for s = (sqrt (dot (ax jj 0) (ax jj 0)))
              for l = (in-frame jj p)
              do (setf deep (max deep (* s (min (- hr (/ (abs (first l)) s)) (- hu (/ (abs (- (second l) (* s cu))) s))
                                                (- hf (/ (abs (- (third l) (* s cf))) s))))))))
      (values (third (in-frame (ji :chest) e)) (third (in-frame (ji :chest) fist)) low deep))))

(defun grip-front-check (clip b jm an)
  "2392's front rows: CLIP sampled at 120 Hz on body B after GRIP-LEFT! (GRIP-FRONT): 'grip front <clip> (mm, + = in
front of the chest): elbow min …, fist min …, below the shoulders min … ('--': none there) (… of … samples behind the back plane), in the
torso max …'. Returns the below-the-shoulders min (m)."
  (let ((one (fv 1)) (el 1.0) (fi 1.0) (lo 1.0) (dp 0.0) (back 0) (n (1+ (floor (* 120 (clip-dur (find-clip clip)))))))
    (anim-play an clip :blend 0)
    (dotimes (i n)
      (pose-fk! jm (anim-eval an) 0.0 0.0 0.0 0.0 (body-scale b) (body-hunch b) (body-props b))
      (grip-left! jm one)
      (multiple-value-bind (e f l d) (grip-front jm)
        (setf el (min el e) fi (min fi f) lo (min lo l) dp (max dp d))
        (when (< l -0.165) (incf back)))
      (anim-advance an (/ 1f0 120)))
    (log-msg "grip front ~a (mm, + = in front of the chest): elbow min ~d, fist min ~d, below the shoulders min ~a (~d of ~d samples behind the back plane), in the torso max ~d"
             clip (round (* 1000 el)) (round (* 1000 fi)) (if (< lo 1.0) (round (* 1000 lo)) "--") back n (round (* 1000 dp)))
    lo))

(defun grip-drift-check ()
  "2392: the left fist's gap to the cleaver's handle over every grip clip and every grip-clip -> grip-clip transition
(a 4 f crossfade from 0.1 s before the first one's end), sampled at 60 Hz on P1's body, raw and after GRIP-LEFT! (W 1):
'grip drift: raw max … mm, IK max … mm'."
  (let* ((b (model-body (model *p1*))) (jm (make-f32 (* 16 +nj+))) (an (make-anim)) (raw 0.0) (ik 0.0) (worst nil) (iw nil)
         (one (fv 1)) (per '()))
    (flet ((sample (tag)
             (pose-fk! jm (anim-eval an) 0.0 0.0 0.0 0.0 (body-scale b) (body-hunch b) (body-props b))
             (let ((g (grip-gap jm)))
               (when (> g raw) (setf raw g worst tag))
               (grip-left! jm one)
               (let ((g2 (grip-gap jm)))
                 (when (> g2 ik) (setf ik g2 iw tag))
                 (let ((e (assoc tag per :test #'equal)))
                   (if e (setf (second e) (max (second e) g) (third e) (max (third e) g2)) (push (list tag g g2) per)))))))
      (dolist (a *grip-clips*)
        (anim-play an a :blend 0)
        (let ((fr '()))
          (loop for i from 0 below (floor (* 60 (clip-dur (find-clip a)))) do
            (pose-fk! jm (anim-eval an) 0.0 0.0 0.0 0.0 (body-scale b) (body-hunch b) (body-props b))
            (push (round (* 1000 (grip-gap jm))) fr)
            (grip-left! jm one) (push (round (* 1000 (grip-gap jm))) fr)
            (sample a) (anim-advance an (/ 1f0 60)))
          (log-msg "grip ~a (raw/IK mm): ~{~d/~d~^ ~}" a (reverse fr)))
        (dolist (c *grip-clips*)
          (anim-play an a :blend 0)
          (loop repeat (max 1 (floor (* 60 (- (clip-dur (find-clip a)) 0.1)))) do (anim-advance an (/ 1f0 60)))
          (anim-play an c :blend 4f0)
          (loop repeat 18 do (sample (list a c)) (anim-advance an (/ 1f0 60))))))
    (dolist (e (reverse per)) (when (> (second e) 0.03) (log-msg "grip drift ~a: raw ~,0f mm, IK ~,0f mm" (first e) (* 1000 (second e)) (* 1000 (third e)))))
    (log-msg "grip drift: raw max ~,0f mm (~a), IK max ~,0f mm (~a)" (* 1000 raw) worst (* 1000 ik) iw)
    (let ((lo (loop for a in *grip-clips* minimize (grip-front-check a b jm an))))   ; (the left arm in front, §6.2.2)
      (log-msg "grip front: below the shoulders min ~d mm" (round (* 1000 lo))))))

(defun ken-debug (c)
  "His debug commands (docs/duel/DUEL_GAMEPLAY.md \"Debug commands\"): 2387 / 2388 BANKAI-TEST 1 / 2, 2392 GRIP-DRIFT-CHECK; the Bankai's
knobs 32000+k *ARM-SELF*, 33000+k *ARM-BURST-SELF*, 34000+k *ARM-CRACK*; 71000 his reiatsu opaque / see-through, 71001 the Shikai, 71004
the Bankai stills. (NOME-TEST 2380-2385, the cup-3 entry 2386, 片腕 2389 and the CPU's cup-3 Bankai knobs 37000 / 38000 went with the cups,
DUEL_KEN_V3 §8.)"
  (cond ((<= 2387 c 2388) (bankai-test (- c 2386)))
        ((= c 2392) (grip-drift-check))
        ((<= 32000 c 32999) (setf *arm-self* (- c 32000)))
        ((<= 33000 c 33999) (setf *arm-burst-self* (- c 33000)))
        ((<= 34000 c 34999) (setf *arm-crack* (- c 34000)))
        ((= c 71000) (setf *reiatsu-glass*                      ; review stills: Kenpachi's reiatsu opaque / see-through
                           (if (zerop (getf *reiatsu-glass* :nomihose)) '(:reiatsu 3 :nozarashi 3 :nomihose 2 :oni 2 :oni-ink 3)
                               '(:reiatsu 0 :nozarashi 0 :nomihose 0 :oni 0 :oni-ink 0))))
        ((member c '(71001 71004)) (ensure-battle :kenpachi :yamamoto) (place *p1* *p2* 3.0)   ; the Shikai / the Bankai
                                   (force-form *p1* (if (= c 71001) :nozarashi :bankai))
                                   (setf (gauges-meter (gauges *p1*)) (f32 (if (= c 71001) 0 4)) (gauges-meter-idle (gauges *p1*)) 0))))
(dolist (r '((2387 2388 ken-debug) (2392 2392 ken-debug) (32000 34999 ken-debug) (71000 71004 ken-debug)))
  (pushnew r *char-debug* :test #'equal))

;;; ================================================================ the core system's hooks (DUEL_KEN_CORE)
(defparameter *ken-clash-max* 5 "Cancels NS2's SA counts at most (the user, 2026-10-29: 「抵銷越多次 SA 傷害越高」; the cap is mine).")
(defun ken-armor (e f mv)
  "His :armor hook (fighter.lisp OWN-ARMOR-P): NS2's armour (:armor-hits 1, spent in COMBAT) lasts through the active frames, not only
the startup (the user, 2026-10-29: 「前搖到 active 吃一發不退」)."
  (declare (ignore e))
  (and (getf (mv-params mv) :armor-act) (plusp (fighter-armor-left f)) (eq (fighter-phase f) :main)
       (<= *armor-from* (fighter-sf f)) (< (fighter-sf f) (+ (mv-s mv) (mv-a mv)))))
(defun ken-clash (x other)
  "His :clash hook (CORE-CLASH!): a cancel while he is in an NS2 segment counts, for the SA of its gap."
  (declare (ignore other))
  (let* ((f (fighter x)) (mv (fighter-move f)))
    (when (and (eq (fighter-state f) :move) mv (getf (mv-params mv) :clash-count))
      (setf (fighter-clash-n f) (min *ken-clash-max* (1+ (fighter-clash-n f))))
      (clog "~a NS2 cancel ~d" (side-name x) (fighter-clash-n f)))))
(defun ken-dmg-mult (att def hw mv hazard d2)
  "His :dmg-mult hook (combat.lisp APPLY-HIT): NS2's SA (:clash-scale) hits 1 + scale x the cancels the route made; the Shikai's burst
(:params :burst, one damage per old L: DUEL_KEN_V3 §5.2) hits that damage (the L read at its start, FIGHTER-LV-CAP)."
  (declare (ignore def d2))
  (let ((s (and mv (not hazard) (getf (mv-params mv) :clash-scale)))
        (b (and mv (not hazard) (getf (mv-params mv) :burst))))
    (cond (s (let ((x (+ 1.0 (* s (fighter-clash-n (fighter att)))))) (clog "~a NS2 SA x~,2f" (side-name att) x) x))
          ((and b (plusp (hw-dmg hw)))
           (let ((d (nth (max 0 (min (1- (length b)) (fighter-lv-cap (fighter att)))) b)))
             (clog "~a BURST ~d (L~d)" (side-name att) d (fighter-lv-cap (fighter att)))
             (/ d (float (hw-dmg hw)))))
          (t 1.0))))

;;; ---------------------------------------------------------------- the Shikai's unlock (DUEL_KEN_V3 §3-§5)
(defparameter *ken-lv-max* 3 "The Shikai's top unlock level L (DUEL_KEN_V3 §4 S1, 2026-11-03: mine, a knob).")

(defun ken-lv (e)
  "His Shikai's :lv hook (CORE-SNAP-LV!): the unlock level L, held in the kit meter (0 at the awakening: its :start)."
  (round (gauges-meter (gauges e))))

(defun ken-link-ok (e next)
  "His Shikai's :link-ok hook (fighter.lisp, a J link as it starts): J4-J7 (:params :lv 3) only at L3 (§5.2 「最高階一次開放」)."
  (<= (getf (mv-params next) :lv 0) (ken-lv e)))

(defun ken-hit (att def res hw mv hazard ranged)
  "His Shikai's :hit hook (combat.lisp APPLY-HIT): the first clean hit (「打中才算」: not a block, a cancel or an armour) of an NS segment,
the temporary switch's included, or of an AS that keeps the pointer (:params :lv-up) raises L by one, up to *KEN-LV-MAX* (§4 S2); once a
combo (the victim's: his first hit starts a new one; the user 2026-11-03: 「一整套攻擊」中有用上一段 NS 或 AS 才解放一階段, §13)."
  (declare (ignore hw ranged))
  (let ((f (fighter att)))
    (when (and (member res '(:hit :counter)) (<= (fighter-combo-hits (fighter def)) 1))
      (setf (fighter-lv-got f) nil))                   ; a new combo
    (when (and mv (not hazard) (member res '(:hit :counter)) (not (fighter-lv-got f))
               (or (eq (fighter-cls f) :ns) (getf (mv-params mv) :lv-up)))
      (setf (fighter-lv-got f) t)
      (let ((g (gauges att)))
        (when (< (ken-lv att) *ken-lv-max*)
          (setf (gauges-meter g) (f32 (1+ (ken-lv att))))
          (clog "~a L~d" (side-name att) (ken-lv att)))))))

(defun ken-as-pick (e f n)
  "His Shikai's :as-pick hook (CORE-AS-START!, N the AS of the press count): SP after J7 = the Bankai (:params :bankai-as), after J4-J6 =
the pointer's special AS (:special-as; the pointer kept); an AS that writes the other pointer = the burst to it (its own move; the old L is
the route's level, the damage KEN-DMG-MULT's), L back to 0 (§4 S5, §5.2); else NIL: the pointer's AS, its segments by L."
  (let* ((mv (fighter-move f)) (p (and mv (mv-params mv))) (cur (fighter-ptr f))
         (as (getf (kit-core (fighter-kit f)) :as)))
    (flet ((nth-as (i) (gethash (nth i as) (kit-moves (fighter-kit f)))))
      (cond ((getf p :bankai-as)
             (clog "~a BANKAI from pointer ~d" (side-name e) cur)
             (bankai! e (if (= cur 2) :bankai-2 :bankai) nil)   ; (the Bankai of the pointer he is on: 狂嵐 / 斬壞, §26; a special
                                                                ;  form, not an awakening: nothing restored, §26.3)
             :taken)
            ((getf p :special-as) (values (nth-as (+ 3 cur)) nil))
            ((/= n cur)
             (setf (gauges-meter (gauges e)) 0f0)
             (clog "~a BURST to pointer ~d (L~d)" (side-name e) n (fighter-lv-cap f))
             (values (nth-as (1+ n)) n))))))
(defun ken-charge-sfx (e) "NS3's charge: the kamae gathers (its sound)." (emit :sfx :whoosh-heavy e))

(defun ken-core-debug (c)
  "84000 / 84001 / 84010 / 84011 (DUEL_KEN_CORE, DUEL_GAMEPLAY \"Debug commands\"): 84000 the scene (84001: Kenpachi in the Shikai,
awakened, L 0, DUEL_KEN_V3; 84004 / 84005 V3's Bankai 狂嵐 / 斬壞, §26; 84090+k the Shikai's L = k), human P1 Kenpachi and an idle Ichigo P2
2.2 m apart, both CPUs off, gauges full; on the running scene 84010 P2 starts his NS now (NS against NS: the first hit wins), 84011
his J1 now (NA against NS: a cancel). The scripts time the presses."
  (case c
    ((84000 84001 84004 84005) (ensure-battle :kenpachi :ichigo :cpu nil)
           (when (brain *p1*) (setf (brain-off (brain *p1*)) t))
           (place *p1* *p2* 2.2)
           (full-gauges! *p1*) (full-gauges! *p2*)
           (let ((g (gauges *p1*))) (setf (gauges-awakened g) nil (gauges-awaken g) 0f0 (gauges-sub g) 0f0 (gauges-sub-s g) 0f0 (gauges-drive g) 0f0))
           (case c                                                  ; 84001: the same, in the Shikai (awakened, L 0)
             (84001 (force-form *p1* :nozarashi) (setf (gauges-awakened (gauges *p1*)) t (gauges-meter (gauges *p1*)) 0f0))
             ((84004 84005) (force-form *p1* (if (= c 84004) :bankai :bankai-2))   ; 84004 / 84005: V3's Bankai from pointer 1 / 2 (§26)
              (setf (gauges-awakened (gauges *p1*)) t) (refresh-look *p1*))))
    ((84094 84095) (ken-core-debug 84001) (place *p1* *p2* 3.0)   ; the Shikai's pointer 1 / 2 Kikon cinematic, played (DUEL_KEN_V3 §19)
     (setf *cine-hold* nil) (start-cine (if (= c 84094) 'ken-s-kikon1-cine 'ken-s-kikon2-cine) *p1* *p2*))
    (84010 (core-sp-start! *p2* (fighter *p2*)))
    (84011 (force-cmd *p2* :q))
    (t (let ((g (gauges *p1*)))                                    ; DUEL_SUBLIMATION §7, on the running 84000 scene (P1's gauges)
         (cond ((<= 84020 c 84030)                                 ; 84020+k: the awakening gauge full, SUBLIMATION at 10k %
                (setf (gauges-awakened g) nil (gauges-awaken g) *awaken-max* (gauges-sub g) (f32 (* 10 (- c 84020)))))
               ((<= 84040 c 84050)                                ; 84040+k: awakened with s = 0.4 frozen, SPIRIT DRIVE at 10k %
                (setf (gauges-awakened g) t (gauges-awaken g) 0f0 (gauges-sub-s g) 0.4f0 (gauges-drive g) (f32 (* 10 (- c 84040)))))
               ((<= 84090 c 84093)                                ; 84090+k: the Shikai's unlock level L = k (DUEL_KEN_V3 §4)
                (setf (gauges-meter g) (f32 (- c 84090))))
               ((<= 84080 c 84084)                                ; 84080+k: the Bankai's arm at k pips (DUEL_KEN_CORE §8)
                (setf (gauges-meter g) (f32 (- c 84080)) (gauges-arm-pending g) nil) (refresh-look *p1*))
               ((= c 84060)                                       ; the real awakening with SUBLIMATION at 50 %
                (setf (gauges-awakened g) nil (gauges-awaken g) *awaken-max* (gauges-sub g) 50f0)
                (awaken! *p1*))
               ((= c 84070)                                       ; a probe line: both sides' stage and bonus
                (dolist (e (list *p1* *p2*))
                  (let ((g (gauges e)))
                    (log-msg "duel sub ~a awakened ~a awaken ~,1f sub ~,1f s ~,2f drive ~,1f frac ~,3f fs ~,1f speed x~,3f"
                             (side-name e) (and (gauges-awakened g) t) (gauges-awaken g) (gauges-sub g) (gauges-sub-s g)
                             (gauges-drive g) (sub-of e) (gauges-fs g) (sub-speed-mult e))))))))))
(pushnew '(84000 84099 ken-core-debug) *char-debug* :test #'equal)
