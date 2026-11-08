;;;; ken.lisp — ZARAKI KENPACHI (TYBW), design-v1 §5.2: his moves (DEFMOVE) and his forms (DEFKIT): :base (the sealed katana),
;;;; :nozarashi (the Shikai since V3, DUEL_KEN_V3: two pointers by grip and the unlock level L; the cups KATATE / RYOTE / NOMIHOSE and
;;;; KATAUDE went 2026-11-03) and the two Bankai :bankai (狂嵐 KYORAN) / :bankai-2 (斬壞 ZANKAI). He wears no eyepatch in any form (the user's decision;
;;;; canon TYBW keeps a strapless patch).
;;;; Clip names are the art contract (ken-art.lisp). Below the data: his hook functions and his
;;;; cinematics (DEFCINE).
(in-package :duel)

;;; ================================================================ base
;;; (the old system's J / K grid and commands, kept as every core kit keeps them: unreachable in a core match, DUEL_KEN_V3 §43)
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

;;; ================================================================ V3's sealed form (DUEL_KEN_V3 §6 / §35, 2026-11-05): the katana, three pointers
;;; by grip: 1 the drag (rising cuts, pressure), 2 the shoulder (each segment takes one hit, KEN-ARMOR), 3 chūdan (the tame catches a melee hit,
;;; :parry, and the thrust answers it: the kit's :land string). J1-J5, AS n by press (the core's 1 1 2 2 3), one SA a pointer.
;;; Their own clips since the art round (DUEL_KEN_V3 §36-§38).
(defmove :ke-z-j1 :kind :quick :clip :ke-z-cut1 :clip-s 6 :startup 6 :active 3 :recovery 12 :dmg 35 :adv-block -2
  :reach 1.8 :arc 100 :on-hit :flinch :slide 0.6)
(defmove-copy :ke-z-j2 :ke-z-j1 :clip :ke-z-cut2 :slide 0.0)
(defmove-copy :ke-z-j3 :ke-z-j1 :clip :ke-z-cut3 :clip-s 7 :startup 7 :dmg 40)
(defmove-copy :ke-z-j4 :ke-z-j1 :clip :ke-z-cut4 :clip-s 8 :startup 8 :recovery 13 :dmg 45 :slide 0.0)
(defmove :ke-z-j5 :kind :quick :clip :ke-z-cut5 :clip-s 10 :startup 10 :active 4 :recovery 18 :dmg 55 :adv-block -4
  :reach 1.8 :arc 120 :on-hit :stagger :slide 0.8)
;; pointer 1, the drag: the drag-up cut, the back-hand chop, the flat sweep; the free-hand shove
(defmove :ke-z-sa1 :kind :quick :clip :ke-z-shove :clip-s 8 :startup 8 :active 3 :recovery 14 :dmg 30 :adv-block -2
  :reach 1.0 :arc 80 :on-hit :stagger :kb 1.5)
(defmove :ke-z-n1c :kind :flash :clip :ke-z-p1c :clip-s 12 :startup 12 :active 4 :recovery 20 :dmg 70 :adv-block -4
  :reach 1.9 :arc 180 :on-hit :crumple :params (:sa :ke-z-sa1))
(defmove :ke-z-n1b :kind :flash :clip :ke-z-p1b :clip-s 10 :startup 10 :active 3 :recovery 18 :dmg 55 :adv-block -4
  :reach 1.8 :arc 110 :on-hit :stagger :params (:ns-next :ke-z-n1c :sa :ke-z-sa1))
(defmove :ke-z-n1a :kind :flash :clip :ke-z-p1a :clip-s 14 :callout "KIRIAGE" :startup 14 :active 4 :recovery 20 :dmg 65 :adv-block -4
  :reach 1.9 :arc 100 :on-hit :stagger :slide 1.2 :params (:ns-next :ke-z-n1b :sa :ke-z-sa1))
(defmove-copy :ke-z-as1 :ke-z-n1a :kind :sp :clip :ke-z-as1 :clip-s 12 :callout "KITTE MIRO YO" :startup 12 :dmg 90 :on-hit :knockdown :params nil)
;; pointer 2, the shoulder: two drops, each through one hit from frame 6 to the end of its active frames; the forearm shove
(defmove-copy :ke-z-sa2 :ke-z-sa1 :clip :ke-z-ram :dmg 35 :kb 1.0)
(defmove :ke-z-n2b :kind :flash :clip :ke-z-p2b :clip-s 14 :startup 14 :active 4 :recovery 22 :dmg 95 :adv-block -4
  :reach 1.8 :arc 110 :on-hit :stagger :slide 0.6 :armor-hits 1 :params (:armor-act t :sa :ke-z-sa2))
(defmove :ke-z-n2a :kind :flash :clip :ke-z-p2a :clip-s 16 :callout "KATAGIRI" :startup 16 :active 4 :recovery 22 :dmg 85 :adv-block -4
  :reach 1.8 :arc 100 :on-hit :crumple :slide 1.0 :armor-hits 1 :params (:armor-act t :ns-next :ke-z-n2b :sa :ke-z-sa2))
(defmove-copy :ke-z-as2b :ke-z-n1a :kind :sp :clip :ke-z-scoop :clip-s 12 :callout nil :startup 12 :dmg 100 :on-hit :launch :slide 0.6 :params nil)   ; the rising cut
(defmove-copy :ke-z-as2 :ke-z-n2a :kind :sp :callout nil :startup 14 :dmg 60 :on-hit :stagger :armor-hits 0 :params (:ns-next :ke-z-as2b))
;; pointer 3, chūdan: the tame (a counter: a melee hit in f2-28 is caught, the thrust starts at once), the thrust, the men cut; the kote cut
(defmove-copy :ke-z-sa3 :ke-z-j1 :clip :ke-z-kote :clip-s 7 :startup 7 :dmg 40 :slide 0.4)
(defmove :ke-z-n3c :kind :flash :clip :ke-z-men :clip-s 14 :callout "MEN" :startup 14 :active 4 :recovery 20 :dmg 95 :adv-block -4
  :reach 1.9 :arc 70 :on-hit :crumple :params (:sa :ke-z-sa3))
(defmove :ke-z-n3b :kind :flash :clip :ke-z-tsuki :clip-s 12 :callout "TSUKI" :startup 12 :active 4 :recovery 20 :dmg 70 :adv-block -4
  :reach 2.3 :arc 30 :on-hit :stagger :slide 1.5 :params (:ns-next :ke-z-n3c :sa :ke-z-sa3))
(defmove :ke-z-n3a :kind :flash :clip :ke-z-tame :clip-s 14 :callout "TAME" :startup 14 :active 0 :recovery 16 :flags (:parry)
  :params (:window (2 28) :ns-next :ke-z-n3b :sa :ke-z-sa3))
(defmove-copy :ke-z-as3c :ke-z-n3b :kind :sp :clip :ke-z-tsuki2 :clip-s 14 :callout nil :startup 14 :dmg 140 :on-hit :knockdown :flags (:guard-crush) :params nil)
(defmove-copy :ke-z-as3b :ke-z-sa3 :kind :sp :startup 10 :dmg 50 :on-hit :stagger :params (:ns-next :ke-z-as3c))   ; the kote
(defmove-copy :ke-z-as3 :ke-z-n3b :kind :sp :callout nil :dmg 50 :params (:ns-next :ke-z-as3b))

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
;; the Bankai's burst AS (DUEL_KEN_V3 §32; the user, 2026-11-05: 「卍解的瞬間不再接入特寫，改成引爆大量靈壓並將對手彈飛的特殊 AS」): SP after J7;
;; he gathers, the reiatsu detonates round him on 12 (3.2 m all round, the victim blown 5 m away), the Bankai of his pointer on 15 (no
;; cinematic; nothing restored, §26.3); no Kikon off it
(defmove :ke-s-bankai :kind :sp :clip :ke-s-bankai :clip-s 12 :blend 3 :callout "BANKAI" :startup 12 :active 3 :recovery 24 :dmg 100
  :adv-block -10 :reach 3.2 :arc 360 :on-hit :knockdown :kb 5.0 :params (:no-kikon t)
  :on-frame ((12 ken-bankai-burst) (15 ken-bankai-enter)))
(defmove :ke-s-sp1 :kind :sp :clip :ke-s-wheel :clip-s 12 :callout "DAISHARIN" :startup 12 :active 14 :recovery 26 :adv-block -10
  :reach 3.0 :arc 360 :hits ((12 14 :dmg 60 :on-hit :stagger) (18 20 :dmg 60 :on-hit :stagger) (24 26 :dmg 120 :on-hit :launch)))
(defmove :ke-s-sp2 :kind :sp :clip :ke-s-meteor :clip-s 20 :callout "INSEKI-GIRI" :startup 20 :active 4 :recovery 30 :dmg 260 :adv-block -12
  :reach 3.0 :arc 90 :on-hit :knockdown :slide 3.0)

;;; ================================================================ forms
(defkit :kenpachi :base
  :name "KENPACHI" :body :kenpachi :weapon :ken-katana :stance :ke-stance
  :intro :ke-intro :win :ke-win
  :walk *walk-kenpachi* :run *run-kenpachi* :run-clips (:ke-run :ke-skate-b :ke-slide-r :ke-slide-l) :reishi *reishi-max* :aura :reiatsu
  :cornered *cornered-per-konpaku* :cornered-max *cornered-max* :reset-reiatsu *reset-reiatsu-bonus*
  :absorb-sfx :laugh
  :stun-tolerance 26.0                          ; the hidden stun (DUEL_DESIGN.md): he takes the most before he flies
  :open-s nil :hs-dmg *ken-hs-dmg*             ; V3's sealed form as written (§35); every form inherits :hs-dmg
  :commands (:q :ke-z-j1 :f :ke-k1 :sig :ke-stance :sp1 :ke-buttagiru :sp2 :ke-charge
             :breaker :ke-breaker :kikon nil)   ; (no O rush since 2026-11-05: DUEL_KEN_V3 §43)
  :grid (:ke-j1 :ke-j2 :ke-j3 :ke-k1 :ke-k2 :ke-k3 :ke-j2s :ke-k2s)   ; (the old J / K grid: unreachable in a core match, kept as every core kit keeps it)
  ;; V3's sealed form (DUEL_KEN_V3 §6 / §35): J1-J5, three pointers by grip (the drag / the shoulder / chūdan), AS n by press
  :core (:ns (:ke-z-n1a :ke-z-n2a :ke-z-n3a) :as (:ke-z-as1 :ke-z-as2 :ke-z-as3) :sa :ke-z-sa1 :mult 1.2
         :as-by-press (1 1 2 2 3)
         :stances (:ke-z-st-1 :ke-z-st-2 :ke-z-st-3)             ; the drag / the shoulder / chūdan (DUEL_KEN_V3 §36)
         :kikon-cines (ken-z-kikon1-cine ken-z-kikon2-cine ken-z-kikon3-cine))   ; 鈴 / 斬ってみろよ / 両断 (§39)
  :strings ((:ke-z-j1 :q :ke-z-j2) (:ke-z-j2 :q :ke-z-j3) (:ke-z-j3 :q :ke-z-j4) (:ke-z-j4 :q :ke-z-j5)
            (:ke-z-n3a :land :ke-z-n3b)                             ; the tame's catch answers with the thrust (combat.lisp :parried)
            (:ke-charge :land :ke-flurry))
  :awaken-form :nozarashi
  :hooks (:boss ken-boss :armor ken-armor :dmg-mult ken-dmg-mult)                       ; the DANGAI boss: the Bankai at FIGHT, the arm never spent (ken-meter.lisp)
  :ai (:intents (:approach 2 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.0 4.0) :pressure (1.0 2.6) :zone (4.0 6.0) :defend (3.0 5.0))
       :moves ((0.0 1.3 :q 5 :f 2 :breaker 1 :sp2 1 :sig 2 nil 3)    ; J up close only (DUEL_STRINGS §13), K beyond
               (1.3 3.0 :f 4 :breaker 1 :sp2 1 :sig 2 nil 3)
               (3.0 4.0 :f 1 :sp1 2 :step 1 nil 2)
               (4.0 6.0 :sp1 4 :sp2 2 nil 1)
               (6.0 99.0 :step 1 :kikon 1 nil 1))                      ; the charge / leap as a poke
       :guard 0.35 :hoho 0.2 :awaken-above 0.0 :sp-cancel-bars 1 :dash 0.8 :kikon-range 9.0
       :react (:projectile :sig :flash-startup :sig) :block-string 0.8))   ; a blocked string goes on (guard pressure)

(defkit :kenpachi :nozarashi :inherit :base    ; the Shikai (DUEL_KEN_V3 §3-§9): two pointers by grip, the unlock level L (the kit meter)
  :awakening t :mult *nozarashi-mult* :startup-add 0 :reach-mult 1.0 :open-s nil   ; (as written: §9's figures; the base's cadence off)
  :passives (:projectile-cut) :form-name "SHIKAI" :kikon-konpaku 2
  :endless-form :nozarashi                      ; ENDLESS (frozen): the Shikai
  :weapon :nozarashi :stance :ke-s-st-1 :aura :reiatsu :swing-sfx :whoosh-cleaver
  :enter-clips (:ke-release :ke-nome) :cine ken-nozarashi-cine :respect-callout "OMOSHIREE!"
  :meter (:name "KAIHO" :max 3 :start 0 :lv t :draw ken-hud-meter :label ken-hud-label) :meter-gain nil   ; L 0-3 (KEN-HIT raises it)
  :hooks (:p ken-card-bankai :armor ken-armor :dmg-mult ken-dmg-mult
          :lv ken-lv :as-pick ken-as-pick :hit ken-hit :link-ok ken-link-ok :draw ken-draw)   ; (P: DANGAI's 隨時卍解 card, frozen;
                                                                                              ;  :draw the sword wind by L, ken-look.lisp)
  :commands (:q :ke-s-j1 :f nil :sig nil :sp1 nil :sp2 nil)   ; (the core system: J and SP only; the Breaker the base's)
  :strings ((:ke-s-j1 :q :ke-s-j2) (:ke-s-j2 :q :ke-s-j3) (:ke-s-j3 :q :ke-s-j4) (:ke-s-j4 :q :ke-s-j5) (:ke-s-j5 :q :ke-s-j6)
            (:ke-s-j6 :q :ke-s-j7))                                      ; (J4-J7: L3, KEN-LINK-OK)
  ;; AS: J1-J2 + SP pointer 1's, J3+ pointer 2's (§5.2 「看 J 打幾段」); KEN-AS-PICK turns one that writes the other pointer into the burst
  ;; (:as entries 3 / 4) and J4-J6 / J7 into the special AS (5 / 6) / the Bankai
  :core (:ns (:ke-s-n1a :ke-s-n2a) :as (:ke-s-as1 :ke-s-as2 :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2 :ke-s-bankai) :sa :ke-s-sa :mult 1.2
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
       :react (:projectile :sig :flash-startup :sig) :block-string 0.8))

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
  :reach 2.4 :arc 360 :on-hit :knockdown :params (:dmg-at 40)                                          ; 千切, the space-cutting draw (§5.4):
  :on-frame ((0 ken-bk-special) (12 ken-chigiri-open) (16 ken-chigiri-still) (34 ken-chigiri-quake)
             (40 ken-chigiri-burst)))                                                                  ;  the damage on the burst (§30.5)
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
     :hooks (:tick ken-bk-tick :armor ken-armor :dmg-mult ken-dmg-mult :draw ken-draw :hit-fx ken-bk-hit-fx)   ; (§31)
     :endless-form :nozarashi :enter-clips (:ke-release :ke-nome) :respect-callout "OMOSHIREE!"
     :awakening t :mult *bankai-ken-mult* :form-name ,name :kikon-konpaku 4 :open-s nil
     :bankai-form nil :passives (:projectile-cut)
     :body :kenpachi-oni :weapon :ke-broken :stance ,stance :aura :oni
     :hide (:haori :sleeve-long :arm-wreck :crack-1 :crack-2 :crack-3 :crack-4)
     :run-clips (:ke-b-run :ke-b-skate-b :ke-b-slide-r :ke-b-slide-l)
     :cine ken-bankai-cine :enter-hook nil :swing-sfx :whoosh-cleaver
     :commands (:q ,(first (first strings)) :f nil :sig nil :sp1 nil :sp2 nil)
     :strings ,strings
     :core (:ns (,ns) :as ,as :sa ,sa :mult 1.2 :as-writes (1 1 1 1 1)
            :stances (,stance) :kikon-cines (,kikon-cine))
     :ai (:intents (:approach 3 :pressure 6 :zone 0 :defend 0)
          :ranges (:approach (1.8 3.6) :pressure (1.0 2.4) :zone (4.0 6.0) :defend (3.0 5.0))
          :moves ((0.0 1.6 :q 5 :breaker 1 nil 2) (1.6 3.4 :breaker 1 :step 1 nil 2) (3.4 99.0 :step 1 nil 1))
          :guard 0.2 :hoho 0.2 :awaken-above 0.0 :sp-cancel-bars 1 :dash 1.0 :kikon-range 5.0 :kikon-p 0.4 :o-ender 0.3
          :block-string 0.85)))
(def-ken-bankai :bankai :name "KYORAN" :ns :ke-kr-na :sa :ke-kr-sa :stance :ke-b-kr-stance :kikon-cine ken-kr-kikon-cine
  :as (:ke-kr-as1 :ke-kr-as2 :ke-kr-as3 :ke-kr-as4 :ke-kr-sp)
  :strings ((:ke-kr-j1 :q :ke-kr-j2) (:ke-kr-j2 :q :ke-kr-j3) (:ke-kr-j3 :q :ke-kr-j4) (:ke-kr-j4 :q :ke-kr-j5)))
(def-ken-bankai :bankai-2 :name "ZANKAI" :ns :ke-zh-na :sa :ke-zh-sa :stance :ke-b-zh-stance :kikon-cine ken-zh-kikon-cine
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
  "千切's draw (DUEL_KEN_V3 §30.3, a look): the cuts opening round him (KEN-CHIGIRI-LOOK), a negative frame, the rift's shimmer."
  (spawn-look e 'ken-chigiri-look :life (+ *chigiri-burst* 4))
  (emit :ken-bk-burst e :chigiri-draw))
(defun ken-chigiri-still (e) "千切's still charge (a look): the world grey but the red, silent." (emit :ken-bk-burst e :chigiri-still))
(defun ken-chigiri-quake (e) "千切's last frames before the burst (a look): the swell, the tremor." (emit :ken-bk-burst e :chigiri-quake))
(defun ken-chigiri-burst (e)
  "千切: the roar and the cuts bursting, the space shattering, frozen *KEN-CHIGIRI-STOP* frames (§30.1; the damage lands on this
frame too: :dmg-at, DELAY-HIT)."
  (hitstop *ken-chigiri-stop*)
  (emit :ken-bk-burst e :chigiri))
(defun ken-tategoto-split (e)
  "TATE-GOTO's chop lands (§30, a look): the space split from the sky 2.2 m before him (its rift: KEN-TATEGOTO-LOOK, cutting on 34:
KEN-TATEGOTO-CUT), the sword wave racing 16 m down the floor and the floor split behind it (§30.4), chips thrown up."
  (let ((p (pos-of e)) (yaw (yaw-of e)))
    (spawn-look e 'ken-tategoto-look :x (+ (aref p 0) (* 2.2 (fwd-x yaw))) :z (+ (aref p 2) (* 2.2 (fwd-z yaw))) :life (+ *tategoto-cut* 2))
    (spawn-look e 'ken-tategoto-wave :yaw yaw :life 14)                       ; the sword wave down the floor (§30.4)
    (spawn-ground-line e *tategoto-wave-len* 70 :meteor)                       ; the floor split behind it
    (ground-scar p yaw '(1.9 4.0 6.5 9.0 11.5 14.0) 0.9)
    (emit :ken-bk-burst e :tategoto)))

(defparameter *ken-tategoto-stop* 10 "Frames TATE-GOTO's rift cutting freezes the fight (HITSTOP; DUEL_KEN_V3 §30.2, mine).")
(defun ken-tategoto-cut (e)
  "TATE-GOTO's rift cuts (§30.2, after KUKAN-GIRI): frozen *KEN-TATEGOTO-STOP* frames, the hit, the ink gash (the damage lands on this
frame too: :dmg-at, DELAY-HIT)."
  (hitstop *ken-tategoto-stop*)
  (emit :ken-bk-burst e :tategoto-cut))

(defun ken-bankai-burst (e) "The Bankai's burst AS detonates (§32, a look): the reiatsu bursting off him." (emit :ken-bk-burst e :bankai))
(defun ken-bankai-enter (e)
  "The Bankai's burst AS, 3 frames after the detonation (§32): the Bankai of the pointer he is on (狂嵐 / 斬壞, §26), no cinematic, nothing
restored (§26.3)."
  (let ((cur (fighter-ptr (fighter e))))
    (clog "~a BANKAI from pointer ~d" (side-name e) cur)
    (bankai! e (if (= cur 2) :bankai-2 :bankai) nil nil)))

(defun ken-bk-hit-fx (att def x y z hs counter dmg kind)
  "The Bankai kits' :hit-fx hook (FEEDBACK-SYSTEM, after the hit's spark; DUEL_KEN_V3 §31, a sound): a bright ring over every hit (the
space cut's slash), a low boom under a heavy one (a strike of 80 or more, or not a J)."
  (declare (ignore att def hs counter))
  (sfx-at :rift-cut x y z :gain 0.55)
  (when (or (>= dmg 80) (not (eq kind :quick))) (sfx-at :awaken-boom x y z :gain 0.4)))

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









;;; (from cell b1a0: an arrival model per command and the opponent's perceived closing speed)
(defun ken-closing (e b s d)
  "His perceived closing speed toward us (m/f, > 0: coming), from the SNAP we see and the one before it in the ring."
  (let* ((ring (brain-ring b)) (n (length ring))
         (s1 (svref ring (mod (- (brain-head b) (brain-delay b) 2) n))) (p (pos-of e)))
    (if (or (null s1) (< d 0.01)) 0.0
        (/ (- (+ (* (- (snap-x s1) (snap-x s)) (- (snap-x s) (aref p 0)))
                 (* (- (snap-z s1) (snap-z s)) (- (snap-z s) (aref p 2)))))
           d))))













;;; ================================================================ cinematics
;;; The grammar of every cinematic is in cinema.lisp (docs/style/STYLE_STORM_DESIGN.md §5); Kenpachi (black robe, black
;;; hair) goes on the white card.
(defun cine-slash (v kind)
  "A cinematic cut landing on V: sparks, sound, flash."
  (multiple-value-bind (x y z) (actor-point v 1.2) (vfx-hit x y z kind))
  (play-sfx (if (eq kind :heavy) :cut-heavy :cut))
  (setf (model-flash (model v)) 0.1))

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

;;; ---------------------------------------------------------------- V3's Bankai Kikon (DUEL_KEN_V3 §33; the user, 2026-11-05: 「可以開始做了」)
;;; Each Bankai's Kikon (and its Soul Break: CORE-SOUL-BREAK-CINE) on its special AS's theme: 狂嵐 千切 grown (more cuts, the screen
;;; shattering like glass, the roar), 斬壞 TATE-GOTO grown (the rift from the top of the screen to the bottom held, then cut, the floor split).
(declaim (special *ke-kk*))   ; (ken-look.lisp's: the Kikon line, KE-KK-LINE)
(declaim (type f32vec *ke-ui-c0* *ke-ui-c1* *ke-ui-c2*))
(defvar *ke-ui-c0* (make-f32 4)) (defvar *ke-ui-c1* (make-f32 4)) (defvar *ke-ui-c2* (make-f32 4))
(defparameter *ke-glass-rays* 14 "The rays of 狂嵐's Kikon glass shatter (KE-GLASS).")
(defparameter *ke-glass-rings* '(0.0 0.11 0.27 0.8) "... and its rings, fractions of the screen's longer side from the centre.")

(defun ke-ui-seg (x0 y0 x1 y1 w c)
  "A UI stroke from (x0 y0) to (x1 y1), W px wide, colour C."
  (let* ((dx (- x1 x0)) (dy (- y1 y0)) (l (max 0.001 (sqrt (+ (* dx dx) (* dy dy)))))
         (nx (* 0.5 w (/ (- dy) l))) (ny (* 0.5 w (/ dx l))))
    (%ui-poly4 (+ x0 nx) (+ y0 ny) (+ x1 nx) (+ y1 ny) (- x1 nx) (- y1 ny) (- x0 nx) (- y0 ny) c c)))

(defun ke-glass-pt (i k w h)
  "Values: the screen point of the glass's ray I on ring K (the screen centre for K 0), each jittered by its own hash."
  (let* ((n *ke-glass-rays*) (i (mod i n))
         (a (+ (* i (/ 6.2832 n)) (* 0.32 (- (hash01 (f32 i) 3.3f0) 0.5))))
         (r (* (max w h) (nth k *ke-glass-rings*) (+ 1.0 (* 0.3 (- (hash01 (f32 i) (f32 (+ 11 k))) 0.5))))))
    (values (+ (* 0.5 w) (* r (cos a))) (+ (* 0.45 h) (* r (sin a))))))

(defun ke-glass (age)
  "狂嵐's Kikon burst (KEN-KR-KIKON-CINE), in UI space (the engine cannot break the rendered image): AGE < 8 frames, the screen cracked from
its centre, *KE-GLASS-RAYS* rays and two rings in ink with a white core; then the pieces between them fly out and fall, their edges inked,
a faint white glaze, gone by 40."
  (let* ((w (window-width)) (h (window-height)) (ui (ui-scale)) (n *ke-glass-rays*)
         (ink *ke-ui-c0*) (wh *ke-ui-c1*) (glaze *ke-ui-c2*))
    (if (< age 8)
        (progn
          (%ui-col ink 0.03 0.03 0.047 1) (%ui-col wh 1 1 0.97 1)
          (dotimes (i n)
            (dotimes (k 3)
              (multiple-value-bind (x0 y0) (ke-glass-pt i k w h)
                (multiple-value-bind (x1 y1) (ke-glass-pt i (1+ k) w h)
                  (ke-ui-seg x0 y0 x1 y1 (* ui 7) ink) (ke-ui-seg x0 y0 x1 y1 (* ui 2.5) wh))
                (when (< 0 k)                                ; the rings
                  (multiple-value-bind (x1 y1) (ke-glass-pt (1+ i) k w h)
                    (ke-ui-seg x0 y0 x1 y1 (* ui 6) ink) (ke-ui-seg x0 y0 x1 y1 (* ui 2) wh)))))))
        (let* ((u (min 1.0 (/ (- age 8) 32.0))) (tt (/ (- age 8) 60.0)) (o (- 1.0 u)))
          (when (< u 1.0)
            (%ui-col ink 0.03 0.03 0.047 o) (%ui-col wh 1 1 0.97 o) (%ui-col glaze 1 1 1 (* 0.3 o))
            (dotimes (i n)
              (dotimes (k 3)
                (multiple-value-bind (ax ay) (ke-glass-pt i k w h)
                  (multiple-value-bind (bx by) (ke-glass-pt (1+ i) k w h)
                    (multiple-value-bind (cx cy) (ke-glass-pt (1+ i) (1+ k) w h)
                      (multiple-value-bind (dx dy) (ke-glass-pt i (1+ k) w h)
                        (let* ((mx (* 0.25 (+ ax bx cx dx))) (my (* 0.25 (+ ay by cy dy)))
                               (ox (- mx (* 0.5 w))) (oy (- my (* 0.45 h))) (ol (max 1.0 (sqrt (+ (* ox ox) (* oy oy)))))
                               (sp (* (max w h) (+ 0.35 (* 0.4 (hash01 (f32 i) (f32 (+ 21 k)))))))
                               (tx (* sp tt (/ ox ol))) (ty (+ (* sp tt (/ oy ol)) (* 1.4 h tt tt)))
                               (s (- 1.0 (* 0.35 u))))
                          (flet ((px (x) (+ mx tx (* s (- x mx)))) (py (y) (+ my ty (* s (- y my)))))
                            (%ui-poly4 (px ax) (py ay) (px bx) (py by) (px cx) (py cy) (px dx) (py dy) glaze glaze)
                            (ke-ui-seg (px ax) (py ay) (px bx) (py by) (* ui 5) ink) (ke-ui-seg (px bx) (py by) (px cx) (py cy) (* ui 5) ink)
                            (ke-ui-seg (px cx) (py cy) (px dx) (py dy) (* ui 5) ink) (ke-ui-seg (px dx) (py dy) (px ax) (py ay) (* ui 5) ink)
                            (ke-ui-seg (px ax) (py ay) (px dx) (py dy) (* ui 1.5) wh)))))))))))))
  nil)

(defun ke-rift-band (x z age cut)
  "斬壞's Kikon rift (KEN-ZH-KIKON-CINE), in UI space so it always runs from the top of the screen to the bottom, through ground point (x z),
AGE frames after the chop: until CUT a thin BLOOD band with a white core and ink borders trembling on twos and slowly widening; from CUT a
wide white flare narrowing over 10 frames while the screen halves shear apart (*GRADE-SPLIT*, 18 frames); then its ink scar, gone by
CUT + 50."
  (let* ((s *sky-scr*) (w (window-width)) (h (window-height)) (ui (ui-scale)) (dr (drawing-no))
         (sx (if (world-to-screen s (f32 x) 1f0 (f32 z)) (aref s 0) (* 0.5 w)))
         (ink *ke-ui-c0*) (red *ke-ui-c1*) (wh *ke-ui-c2*) (v (- age cut)))
    (setf *grade-split* (f32 (if (< -1 v 18) (* 0.04 h (max 0.0 (min 1.0 (/ (+ v 1) 2.0) (/ (- 18 v) 4.0)))) 0.0)))
    (cond ((< v 0)                                      ; held, trembling
           (let* ((bw (* ui (+ 11 (* 4 (hash01 dr 9f0)) (* 10 (/ age (float cut)))))) (cx (+ sx (* ui 4 (- (hash01 dr 5f0) 0.5)))))
             (ui-rect (- cx (* 0.5 bw) (* 2.5 ui)) 0 (+ bw (* 5 ui)) h (%ui-col ink 0.03 0.03 0.047 1))
             (ui-rect (- cx (* 0.5 bw)) 0 bw h (%ui-col red 0.816 0.063 0.11 1))
             (ui-rect (- cx (* 0.15 bw)) 0 (* 0.3 bw) h (%ui-col wh 1 1 0.97 1))))
          ((< v 10)                                     ; it cuts
           (let ((bw (* ui (+ 8 (* 90 (- 1.0 (/ v 10.0)))))))
             (ui-rect (- sx (* 0.5 bw) (* 4 ui)) 0 (+ bw (* 8 ui)) h (%ui-col ink 0.03 0.03 0.047 1))
             (ui-rect (- sx (* 0.5 bw)) 0 bw h (%ui-col wh 1 1 0.97 1))))
          ((< v 50)                                     ; the scar
           (ui-rect (- sx (* 2 ui)) 0 (* 4 ui) h (%ui-col ink 0.03 0.03 0.047 (- 1.0 (/ (- v 10) 40.0)))))))
  nil)

(defun ke-kk-cam (s hc sl hl)
  "The camera on the Kikon line (*KE-KK*, KE-KK-LINE): at S m from the victim's mark toward Kenpachi's side, HC high, looking at SL m along it,
HL high (S < 0: past him). The rift and the shear stay on the screen's centre line."
  (setf *cine-subject* nil *cine-close* nil)
  (let ((l *ke-kk*))
    (cine-cam (+ (aref l 0) (* s (aref l 2))) hc (+ (aref l 1) (* s (aref l 3)))
              (+ (aref l 0) (* sl (aref l 2))) hl (+ (aref l 1) (* sl (aref l 3))))))

(defun ke-zh-chips (a)
  "Floor chips floating up round fighter A while 斬壞's head is hauled out of the floor (KEN-ZH-KIKON-CINE, every other step)."
  (let ((p (pos-of a)))
    (dotimes (i 2)
      (let ((ang (rnd-range 0f0 6.2832f0)) (r (rnd-range 0.4f0 2.2f0)))
        (declare (single-float ang r))
        (%t-shard (+ (aref p 0) (* r (f-cos ang))) 0.1f0 (+ (aref p 2) (* r (f-sin ang))) 0f0 (rnd-range 0.8f0 1.6f0) 0f0
                  (rnd-range 0.7f0 1.0f0) (rnd-range 0.06f0 0.14f0) 0.6f0 +pal-dust+)))))

(defcine ken-kr-kikon-cine (a v :len 180 :hold 100)
  "狂嵐 KYORAN's Kikon 千切・極 (DUEL_KEN_V3 §33): 千切 grown. Beat 0; the black card, a BLOOD back-rim, the oni gathering into the iai under
千切 / 狂嵐 and the hanko, silence; side-on, the iai held, trembling; the draw: a white flash, the cut on the victim; the world ink and paper but
the red while the camera circles him half way round and two dozen cuts open in the air round him and the lens, Kenpachi still, head down,
in silence; close on the face: the head thrown back, the roar, the cuts shaking; the burst: red and ink held 8 frames, the screen
shattering like glass, the shards and rings, the Konpaku; he is blown 7 m away and lands; Kenpachi laughs; wide."
  (at 0 (face-each-other a v 2.0) (ke-kk-line a v) (setf *aura-off* a)
      (cine-clip a :ke-kr-chigiri :blend 2 :speed 0.05) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 1) (play-sfx :whoosh-cleaver))
  (at 12 (card :black a) (back-rim 18 0.82 0.06 0.11) (shot-on a 60 4.2 0.7 :look 1.5 :ahead 1.0 :off 0.8) (lens 46 8) (silence 26)
      (cine-clip a :ke-kr-chigiri :blend 4 :speed (/ 8.0 18.0))                 ; the gathering, into the iai (its key 8) by f30
      (caption "千切" :kanji2 "狂嵐" :reading "CHIGIRI" :sub "KYORAN" :side 0 :hanko t))
  (at 30 (card nil) (shot-on a 85 3.4 1.0 :look 1.2) (lens 50)                    ; side-on: the iai held, trembling (keys 8-11)
      (cine-clip a :ke-kr-chigiri :blend 0 :time (/ 8.0 60.0) :speed 0.3))
  (at 40 (cine-clip a :ke-kr-chigiri :blend 0 :time (/ 11.0 60.0))               ; the draw: S on f41
      (impact-frame :negative 1) (ui-flash 1 1 1 0.8 6.0) (cine-slash v :heavy) (cine-clip v :sh-stagger :blend 1)
      (play-sfx :whoosh-cleaver) (play-sfx :kikon-slash) (shake 0.2 0.25) (focus-lines 6))
  (at 42 (cine-grade :manga))                                                     ; ink and paper but the red, to the roar
  (at 46 (silence 42))
  (at 52 (cine-clip a :ke-kr-chigiri :blend 0 :time (/ 22.0 60.0) :speed (/ 12.0 38.0)))   ; head down, still: keys 22-34 over f52-90
  (during (40 90) (shot-on v (+ 30 (* 170 u)) (- 4.6 (* 0.8 u)) (+ 1.3 (* 0.5 u)) :look 1.3) (lens 50 (* 6 u)))   ; half way round him
  (during (40 112) (ken-chigiri-cuts (aref *ke-kk* 0) (aref *ke-kk* 1) (- cf 40) 24 1.6 1.4 60 10 8))
  (at 90 (cine-grade nil) (impact-frame :negative 1) (card :black a) (back-rim 10 0.82 0.06 0.11)   ; the roar alone on the card
      (shot-on a -40 1.8 0.6 :look 1.25 :ahead 0.4) (lens 62 8) (face-beat a :shout 1.2 t)
      (cine-clip a :ke-kr-chigiri :blend 0 :time (/ 34.0 60.0) :speed 0.6)       ; the last six keys shaking, over f90-100
      (play-sfx :oni-roar) (play-sfx :laugh :pitch 0.6))
  (when (and step-p (<= 90 cf 99)) (shake (* 0.03 (- cf 88)) 0.1))               ; the tremor swelling into the burst
  (at 100 (card nil) (impact-frame :red 8) (hold-both a v 8) (caption-exit)
      (cine-clip a :ke-kr-chigiri :blend 0 :time (/ 40.0 60.0))                  ; the roar (ch-r)
      (shot-on v 90 7.5 1.5 :look 1.2) (lens 55)
      (let ((q (pos-of v)))
        (vfx-ken-bk-burst (aref q 0) (aref q 2) :chigiri) (vfx-ken-bk-burst (aref q 0) (aref q 2) :chigiri)
        (vfx-shockwave (aref q 0) (aref q 2) 9.0 0.7 :pal +pal-blood+) (vfx-shockwave (aref q 0) (aref q 2) 5.0 0.5 :pal +pal-ink+))
      (cine-shatter v (fighter-kikon-n (fighter a)))
      (impact-splash-at v 1.0 16 0.09)
      (play-sfx :rift-cut) (play-sfx :explode) (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (play-sfx :awaken-boom)
      (shake 0.6 0.6))
  (during (100 140) (ke-glass (- cf 100)))
  (at 108 (cine-clip v :sh-launch :blend 1) (shot-pair a v 1 10.0 1.8) (lens 50))
  (during (108 130) (ke-kk-at v (* -7.0 (- 1.0 (expt (- 1.0 u) 2))) (* 1.6 (sin (* 3.1416 u)))))   ; blown away
  (at 130 (ke-kk-at v -7.0) (cine-clip v :sh-down :blend 2)
      (let ((q (pos-of v))) (vfx-shockwave (aref q 0) (aref q 2) 2.5 0.4 :pal +pal-dust+))
      (play-sfx :ground-crack) (shake 0.2 0.25))
  (at 136 (shot-on a 30 4.4 0.9 :look 1.4) (lens 46) (face-beat a :shout 1.4 t) (play-sfx :laugh :pitch 0.8))
  (at 156 (shot-on a 160 7.0 1.8 :look 1.2) (lens 50)))

(defcine ken-zh-kikon-cine (a v :len 180 :hold 96)
  "斬壞 ZANKAI's Kikon 盾ごと・極 (DUEL_KEN_V3 §33): TATE-GOTO grown, after KUKAN-GIRI (the space cut held, then cut). Beat 0; the black card, a
BLOOD back-rim, the oni under 盾ごと / 斬壞 and the hanko, silence; low, looking up: both hands haul the head out of the floor overhead, slow
then fast, chips floating up; up with him into the leap; the chop: a white flash held 6 frames; down the cut from behind him: one rift from the
top of the screen to the bottom through the victim, the sword wave racing 30 m down the floor and the floor splitting to the edge; reversed,
from behind the victim, the rift trembling; it cuts: the screen halves shear apart, red and ink held 8 frames, the ink gash, the shards, the
Konpaku; he is blown 7 m away; from the side, Kenpachi wrenches the head out of the floor; he laughs."
  (at 0 (face-each-other a v 2.4) (ke-kk-line a v) (setf *aura-off* a)
      (cine-clip a :ke-zh-tategoto :blend 2 :speed 0.05) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 1) (play-sfx :whoosh-cleaver))
  (at 12 (card :black a) (back-rim 24 0.82 0.06 0.11) (shot-on a 60 4.2 0.7 :look 1.6 :ahead 1.3 :off 0.8) (lens 46 8) (silence 38)
      (caption "盾ごと" :kanji2 "斬壞" :reading "TATE-GOTO" :sub "ZANKAI" :side 0 :hanko t))
  (at 36 (card nil) (shot-on a 110 3.4 0.25 :look 1.8) (lens 72 -6)               ; low, up at him: the head hauled overhead
      (cine-clip a :ke-zh-tategoto :blend 2 :time (/ 3.0 60.0) :speed (/ 11.0 14.0)))   ; keys 3-14 over f36-50, its own slow-to-fast
  (when (and step-p (<= 36 cf 54) (evenp cf)) (ke-zh-chips a))
  (at 50 (cine-clip a :ke-zh-tategoto :blend 0 :time (/ 14.0 60.0)))             ; held trembling, the leap (18), the chop S on f56
  (at 52 (play-sfx :whoosh-heavy :pitch 0.7))
  (during (50 56) (shot-on a 110 4.2 (+ 0.4 (* 2.4 u)) :look (+ 1.6 (* 1.6 u))) (lens 60))
  (at 56 (impact-frame :negative 2) (ui-flash 1 1 1 0.7 12.0) (hold-both a v 6) (focus-lines 20)
      (cine-slash v :heavy) (cine-clip v :sh-stagger :blend 1) (lens 55)
      (play-sfx :kikon-slash) (play-sfx :ground-crack) (play-sfx :whoosh-cleaver :pitch 0.7) (shake 0.45 0.5))
  (at 62 (cine-clip a :ke-zh-tategoto :blend 0 :time (/ 20.0 60.0) :speed (/ 13.0 34.0)))   ; landed, head down: keys 20-33 over f62-96
  (during (56 76) (ke-kk-cam 10.0 5.6 -6.0 1.0))                                 ; down the cut from behind him
  (during (76 96) (ke-kk-cam -5.5 1.4 3.0 2.0))                                  ; reversed: from behind the victim
  (during (96 104) (ke-kk-cam 10.0 5.6 -6.0 1.0))                                ; the cut, down the line again (the shear)
  (during (56 160) (ke-rift-band (aref *ke-kk* 0) (aref *ke-kk* 1) (- cf 56) 40))
  (during (62 76) (let ((p (pos-of a))) (ken-tategoto-wave-at (aref p 0) (aref p 2) (yaw-of a) (- cf 62) 30.0)))
  (during (60 180) (let* ((p (pos-of a)) (yaw (yaw-of a)) (fx (fwd-x yaw)) (fz (fwd-z yaw)))   ; the floor split to the edge
                     (vfx-line-cut (+ (aref p 0) (* 0.8 fx)) (+ (aref p 2) (* 0.8 fz)) (+ (aref p 0) (* 30.0 fx)) (+ (aref p 2) (* 30.0 fz))
                                   (/ (- cf 60) 60.0) 1.5 :meteor)))
  (at 96 (impact-frame :red 8) (hold-both a v 8) (caption-exit)
      (vfx-ken-tategoto-cut (aref *ke-kk* 0) (aref *ke-kk* 1)) (vfx-ken-bk-burst (aref *ke-kk* 0) (aref *ke-kk* 1) :chigiri)
      (cine-shatter v (fighter-kikon-n (fighter a)))
      (play-sfx :rift-cut) (play-sfx :explode) (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (play-sfx :cut-heavy)
      (shake 0.6 0.6))
  (at 104 (cine-clip v :sh-launch :blend 1) (shot-pair a v 1 11.0 1.6) (lens 50)
      (cine-clip a :ke-zh-tategoto :blend 2 :time (/ 33.0 60.0) :speed 0.5))     ; the wrench (34), the head out, back to the stance
  (during (104 126) (ke-kk-at v (* -7.0 (- 1.0 (expt (- 1.0 u) 2))) (* 1.4 (sin (* 3.1416 u)))))
  (at 126 (ke-kk-at v -7.0) (cine-clip v :sh-down :blend 2)
      (let ((q (pos-of v))) (vfx-shockwave (aref q 0) (aref q 2) 2.5 0.4 :pal +pal-dust+))
      (play-sfx :ground-crack) (shake 0.2 0.25))
  (at 140 (shot-on a 40 4.6 0.9 :look 1.4) (lens 46) (face-beat a :shout 1.4 t) (play-sfx :laugh :pitch 0.8))
  (at 160 (shot-on a 160 7.0 1.8 :look 1.2) (lens 50)))

;;; ---------------------------------------------------------------- the sealed form's Kikon (DUEL_KEN_V3 §39; the user, 2026-11-05: 「同意」)
;;; One per pointer, its theme: 1 the drag (鈴: gone, the bells behind you, the cut up from the floor), 2 the shoulder (斬ってみろよ: he takes
;;; the cut on his open chest, laughs, cuts back), 3 chūdan (両断: aimed, raised, held, one cut that splits the floor and him).
(defun ke-kk-yaw (e ang)
  "Turn E to the line's direction (*KE-KK*: toward Kenpachi's side) plus ANG degrees."
  (setf (transform-yaw (transform e)) (f32 (+ (dir-yaw (aref *ke-kk* 2) (aref *ke-kk* 3)) (deg ang)))))
(defun ke-z-dust (e n)
  "N dust puffs kicked out round E's feet."
  (let ((p (pos-of e)))
    (dotimes (i n)
      (let ((ang (rnd-range 0f0 6.2832f0)) (sp (rnd-range 0.8f0 2.2f0)))
        (declare (single-float ang sp))
        (%t-blob (+ (aref p 0) (rnd-range -0.3f0 0.3f0)) 0.15f0 (+ (aref p 2) (rnd-range -0.3f0 0.3f0))
                 (* sp (f-cos ang)) (rnd-range 0.2f0 0.9f0) (* sp (f-sin ang))
                 (rnd-range 0.6f0 1.1f0) (rnd-range 0.18f0 0.32f0) -0.2f0 0.4f0 +pal-dust+)))))
(defun ke-z-blood (e n)
  "N drops of blood out of E's chest, forward and up."
  (let* ((p (pos-of e)) (yaw (yaw-of e)) (fx (fwd-x yaw)) (fz (fwd-z yaw)))
    (dotimes (i n)
      (let ((sp (rnd-range 1.5f0 3.5f0)))
        (declare (single-float sp))
        (%t-blob (+ (aref p 0) (* 0.25 fx)) 1.35f0 (+ (aref p 2) (* 0.25 fz))
                 (* sp (+ fx (rnd-range -0.5f0 0.5f0))) (rnd-range 0.5f0 2.5f0) (* sp (+ fz (rnd-range -0.5f0 0.5f0)))
                 (rnd-range 0.4f0 0.7f0) (rnd-range 0.03f0 0.07f0) 9f0 0.3f0 +pal-blood+)))))

(defcine ken-z-kikon1-cine (a v :len 196 :hold 104)
  "鈴 RIN, the sealed pointer-1 Kikon (the drag): beat 0, the drag stance held; a white card, low and dutch, the brush 鈴 and the hanko,
silence; both side-on, then he is gone, only the dust where he stood; the victim looks round, left, right; the bells behind him, the
camera over his shoulder turning back; Kenpachi is there, the tip on the floor; the cut up from the floor through him: a negative,
focus lines, a manga page, the Konpaku; he flies; Kenpachi laughs; wide."
  (at 0 (cine-place a v 3.0) (ke-kk-line a v) (shot-on a 50 3.6 1.0 :look 1.1) (lens 50) (setf *aura-off* a)   ; (no aura: he can vanish)
      (cine-clip a :ke-z-st-1 :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :white a) (shot-on a 25 3.0 0.5 :look 1.2 :off -0.8) (lens 44 -10) (silence 40)
      (caption "鈴" :reading "RIN" :sub "KENPACHI  KIKON" :side 1 :ink t :hanko t))
  (at 52 (card nil) (caption-exit) (shot-pair a v 1 7.0 1.0) (lens 46))
  (at 62 (ke-z-dust a 10) (cine-scale a 0.001) (play-sfx :whoosh-heavy :pitch 1.3)   ; gone
      (let ((p (pos-of a))) (vfx-shockwave (aref p 0) (aref p 2) 1.6 0.4 :pal +pal-dust+)))
  (when (and step-p (<= 64 cf 76) (evenp cf)) (ke-z-dust a 2))                       ; (the dust hangs where he stood)
  (at 78 (ke-kk-at a -1.6) (ke-kk-yaw a 0)                                            ; (behind him, unseen)
      (ke-kk-cam 3.4 1.4 0.0 1.3) (lens 50))                                           ; the victim, face on
  (during (78 108) (ke-kk-yaw v (* 55 (sin (* 6.2832 (min 1.0 (* 1.15 u)))))))        ; he looks left, right
  (at 108 (play-sfx :ken-bells) (silence 30))
  (during (108 122) (let* ((l *ke-kk*) (q (pos-of v)) (px (aref l 3)) (pz (- (aref l 2))) (k (* u u (- 3 (* 2 u)))))   ; over his shoulder, turning back
                      (ke-kk-yaw v (* 120 k))
                      (cine-cam (+ (aref q 0) (* 1.3 (aref l 2)) (* 1.5 px)) 1.8 (+ (aref q 1) (* 1.3 (aref l 3)) (* 1.5 pz))
                                (+ (aref q 0) (* (- 1.0 (* 2.6 k)) (aref l 2))) (- 1.6 (* 0.4 k)) (+ (aref q 1) (* (- 1.0 (* 2.6 k)) (aref l 3))))))
  (at 114 (cine-scale a 1) (cine-clip a :ke-z-st-1 :blend 0))                         ; there
  (at 122 (shot-pair a v 1 5.2 0.6) (lens 50))                                         ; side-on, low: the tip on the floor behind him
  (at 128 (cine-clip a :ke-z-as1 :blend 2 :speed 0.75) (play-sfx :whoosh-cleaver :pitch 0.8))   ; (its S, clip frame 12: f144)
  (at 144 (cine-slash v :heavy) (cine-clip v :sh-launch :blend 1) (impact-frame :negative 2) (focus-lines 14)
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 1.0 :dy 0.1)
      (impact-splash-at v 1.0 16 0.08)
      (play-sfx :kikon-slash) (play-sfx :konpaku-shatter) (shake 0.35 0.45))
  (at 146 (impact-frame :manga 12))
  (during (144 172) (ke-kk-at v (* 3.4 (- 1.0 (expt (- 1.0 u) 2))) (* 2.6 (sin (* 3.1416 u)))))   ; up and away from him
  (at 172 (ke-kk-at v 3.4) (cine-clip v :sh-down :blend 2) (ke-z-dust v 6) (play-sfx :ground-crack) (shake 0.15 0.2))
  (at 174 (shot-on a 30 4.2 0.9 :look 1.4) (lens 46) (face-beat a :shout 1.2 t) (play-sfx :laugh)
      (cine-clip a :ke-z-st-1 :blend 12))
  (at 186 (shot-on a 160 6.0 1.6 :look 1.2) (lens 50)))

(defcine ken-z-kikon2-cine (a v :len 206 :hold 100)
  "斬ってみろよ KITTE MIRO YO, the sealed pointer-2 Kikon (the shoulder): beat 0, the shoulder rest held; a white card, low and dutch, the
brush 斬ってみろよ and the hanko, silence; face on, he flings both arms wide, the chest open; the victim cuts him across the chest, the
blood out, he does not move; close: he looks down at the wound, in silence; low and wide-angle on the face: the head thrown back, the
laugh; both hands up and the drop straight down through him: a negative, focus lines, a manga page, the floor cracked, the Konpaku;
he laughs; wide."
  (at 0 (cine-place a v 1.9) (ke-kk-line a v) (shot-on a 50 3.4 1.0 :look 1.2) (lens 50)
      (cine-clip a :ke-z-st-2 :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :white a) (shot-on a 25 3.0 0.6 :look 1.3 :off -0.8) (lens 44 -10) (silence 40)
      (caption "みろよ" :kanji2 "斬って" :reading "KITTE MIRO YO" :sub "KENPACHI  KIKON" :side 1 :ink t :hanko t))
  (at 52 (card nil) (caption-exit) (shot-on a 50 3.0 1.1 :look 1.3) (lens 46)
      (cine-clip a :ke-z-open :blend 10) (play-sfx :laugh :pitch 0.7))
  (at 74 (shot-pair a v 1 4.6 1.2) (lens 50)
      (let ((mv (kit-command-move (kit-of v) :q)))                                     ; the victim's own J1, its hit on f84
        (when mv
          (let ((cs (mv-clip-speed mv)))
            (cine-clip v (kit-move-clip (kit-of v) (mv-clip mv)) :blend 2 :speed cs
                       :time (/ (max 0.0 (- (* (mv-s mv) cs) (* 10 cs))) 60.0))))))
  (at 84 (multiple-value-bind (x y z) (actor-point a 1.35) (vfx-hit x y z :heavy))
      (setf (model-flash (model a)) 0.1) (ke-z-blood a 12)
      (impact-frame :negative 2) (play-sfx :cut-heavy) (shake 0.2 0.25))
  (when (and step-p (<= 86 cf 104) (evenp cf)) (ke-z-blood a (if (< cf 94) 4 2)))
  (at 92 (cine-clip v :sh-kikon-victim :blend 8) (ke-kk-at v -1.2) (shot-on a 20 1.7 1.35 :look 1.4) (lens 56) (silence 30))   ; (he backs off)
  (at 98 (cine-clip a :ke-z-wound :blend 10))
  (at 122 (shot-on a 20 1.6 1.0 :look 1.8) (lens 80 -8) (face-beat a :shout 1.4 t)   ; the laugh
      (play-sfx :laugh) (shake 0.12 0.3))                                             ; (from the head-down pose: the open one's chin is up already)
  (at 140 (ke-kk-at v 0.0) (shot-pair a v -1 5.4 0.8) (lens 50)
      (cine-clip a :ke-z-p2a :blend 3 :time (/ 3.0 60.0) :speed 0.8))                 ; up and held (keys 7-14), its S on f156
  (at 152 (play-sfx :whoosh-cleaver :pitch 0.7))
  (at 156 (cine-slash v :heavy) (cine-clip v :sh-crumple :blend 1) (impact-frame :negative 2) (focus-lines 14)
      (let ((q (pos-of v))) (stage-crack-add (aref q 0) (aref q 2) 1.4) (stage-debris (aref q 0) (aref q 2) 6 1.0)
        (vfx-shockwave (aref q 0) (aref q 2) 4.0 0.5 :pal +pal-dust+))
      (cine-shatter v (fighter-kikon-n (fighter a)) :up 0.8 :dy 0.1)
      (impact-splash-at v 0.8 16 0.08)
      (play-sfx :kikon-slash) (play-sfx :ground-crack) (play-sfx :konpaku-shatter) (shake 0.45 0.5))
  (at 158 (impact-frame :manga 12))
  (at 176 (shot-on a 35 4.2 0.9 :look 1.4) (lens 46) (face-beat a :shout 1.2 t) (play-sfx :laugh :pitch 0.8)
      (cine-clip a :ke-z-st-2 :blend 14))
  (at 192 (shot-on a 160 6.0 1.6 :look 1.2) (lens 50)))

(defcine ken-z-kikon3-cine (a v :len 204 :hold 100)
  "両断 RYODAN, the sealed pointer-3 Kikon (chūdan): beat 0, chūdan held; a black card, a pale back-rim, the brush 両断 and the hanko,
silence; close along the blade, the tip settling on him; low, up at him: both fists raised over the head; held still, a slow push, in
silence; the cut: a negative, a white flash, down the cut from behind him the floor splitting 30 m to the edge and the line of light
through the victim, the screen shearing apart, the Konpaku; from behind the victim, the split running past; he falls; Kenpachi in his
zanshin, a short laugh; wide."
  (at 0 (cine-place a v 3.0) (ke-kk-line a v) (shot-on a 50 3.6 1.0 :look 1.2) (lens 50)
      (cine-clip a :ke-z-st-3 :blend 2) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (play-sfx :whoosh-cleaver))
  (at 12 (card :black a) (back-rim 40) (shot-on a 60 4.2 0.7 :look 1.5 :ahead 1.0 :off 0.8) (lens 46 8) (silence 40)
      (caption "両断" :reading "RYODAN" :sub "KENPACHI  KIKON" :side 0 :hanko t))
  (at 52 (card nil) (caption-exit) (shot-on a 70 1.6 1.4 :look 1.4 :ahead 0.6) (lens 60)    ; along the blade
      (cine-clip a :ke-z-tame :blend 6 :speed 0.45))
  (at 78 (shot-on a -80 3.4 0.4 :look 1.8) (lens 52)                                   ; low, up at him: raised
      (cine-clip a :ke-z-men :blend 10 :time (/ 6.0 60.0) :speed 0.3) (play-sfx :awaken-rise :pitch 0.6))
  (at 98 (cine-clip a :ke-z-men :blend 4 :time (/ 12.0 60.0) :speed 0.01) (silence 22))   ; held still
  (during (98 120) (shot-on a 25 (- 3.0 (* 0.8 u)) 1.6 :look 1.7) (lens 58))
  (at 120 (cine-clip a :ke-z-men :blend 0 :time (/ 12.0 60.0)) (play-sfx :whoosh-cleaver :pitch 0.8))   ; the cut, S on f122
  (at 122 (impact-frame :negative 2) (ui-flash 1 1 1 0.5 12.0) (hold-both a v 4) (focus-lines 20)
      (cine-slash v :heavy) (cine-clip v :sh-stagger :blend 1)
      (cine-shatter v (fighter-kikon-n (fighter a)))
      (impact-splash-at v 1.0 16 0.08)
      (play-sfx :kikon-slash) (play-sfx :ground-crack) (play-sfx :rift-cut) (play-sfx :konpaku-shatter) (shake 0.5 0.55))
  (at 122 (ke-kk-cam 10.0 5.6 -6.0 1.0) (lens 55))                                  ; down the cut from behind him
  (during (122 204) (let ((q (pos-of v))) (vfx-sky-split (aref q 0) (aref q 2) (yaw-of a) (/ (- cf 122) 60.0) 1.4)))
  (during (124 204) (let* ((p (pos-of a)) (yaw (yaw-of a)) (fx (fwd-x yaw)) (fz (fwd-z yaw)))   ; the floor split to the edge
                      (vfx-line-cut (+ (aref p 0) (* 1.2 fx)) (+ (aref p 2) (* 1.2 fz)) (+ (aref p 0) (* 30.0 fx)) (+ (aref p 2) (* 30.0 fz))
                                    (/ (- cf 124) 60.0) 1.4 :meteor)))
  (at 146 (ke-kk-cam -5.5 1.4 3.0 1.6) (cine-clip v :sh-crumple :blend 3))            ; from behind him: he falls
  (at 168 (shot-on a 30 4.4 1.0 :look 1.4) (lens 46) (cine-clip a :ke-z-st-3 :blend 16) (play-sfx :laugh :pitch 0.9))
  (at 188 (shot-on a 160 6.0 1.6 :look 1.2) (lens 50)))

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
      (setf (aref one 0) (f32 (if (grip-target-ok-p jm) (min 1.0 (+ (aref one 0) (/ 10 120.0))) (max 0.0 (- (aref one 0) (/ 10 120.0))))))   ; (GRIP-STEP's
      (when (> (aref one 0) 0f0) (grip-left! jm one))                                                                                  ;  easing and release, §47)
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
(defun ken-armor (e f mv)
  "His :armor hook (fighter.lisp OWN-ARMOR-P): NS2's armour (:armor-hits 1, spent in COMBAT) lasts through the active frames, not only
the startup (the user, 2026-10-29: 「前搖到 active 吃一發不退」)."
  (declare (ignore e))
  (and (getf (mv-params mv) :armor-act) (plusp (fighter-armor-left f)) (eq (fighter-phase f) :main)
       (<= *armor-from* (fighter-sf f)) (< (fighter-sf f) (+ (mv-s mv) (mv-a mv)))))
(defun ken-dmg-mult (att def hw mv hazard d2)
  "His :dmg-mult hook (combat.lisp APPLY-HIT): the Shikai's burst (:params :burst, one damage per old L: DUEL_KEN_V3 §5.2) hits that
damage (the L read at its start, FIGHTER-LV-CAP). (The old NS2 SA's :clash-scale and its :clash hook KEN-CLASH went 2026-11-05, §43.)"
  (declare (ignore def d2))
  (let ((b (and mv (not hazard) (getf (mv-params mv) :burst))))
    (cond ((and b (plusp (hw-dmg hw)))
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
      (cond ((getf p :bankai-as) (values (nth-as 6) nil))   ; the Bankai's burst AS (§32): the reiatsu detonating, then the form
            ((getf p :special-as) (values (nth-as (+ 3 cur)) nil))
            ((/= n cur)
             (setf (gauges-meter (gauges e)) 0f0)
             (clog "~a BURST to pointer ~d (L~d)" (side-name e) n (fighter-lv-cap f))
             (values (nth-as (1+ n)) n))))))

(defun ken-core-debug (c)
  "84000 / 84001 / 84010 / 84011 (DUEL_KEN_CORE, DUEL_GAMEPLAY \"Debug commands\"): 84000 the scene (84001: Kenpachi in the Shikai,
awakened, L 0, DUEL_KEN_V3; 84004 / 84005 V3's Bankai 狂嵐 / 斬壞, §26; 84090+k the Shikai's L = k; 84006-84008 the sealed Kikon cinematics, §39), human P1 Kenpachi and an idle Ichigo P2
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
    ((84096 84097) (ken-core-debug (if (= c 84096) 84004 84005)) (place *p1* *p2* 3.0)   ; the Bankai's Kikon 狂嵐 / 斬壞, played (§33)
     (setf *cine-hold* nil (fighter-kikon-n (fighter *p1*)) 4) (cine-stage *p1* *p2*)
     (start-cine (if (= c 84096) 'ken-kr-kikon-cine 'ken-zh-kikon-cine) *p1* *p2*))
    ((84006 84007 84008) (ken-core-debug 84000) (place *p1* *p2* 3.0)   ; the sealed form's Kikon 鈴 / 斬ってみろよ / 両断, played (§39)
     (setf *cine-hold* nil (fighter-kikon-n (fighter *p1*)) 3) (cine-stage *p1* *p2*)
     (start-cine (case c (84006 'ken-z-kikon1-cine) (84007 'ken-z-kikon2-cine) (t 'ken-z-kikon3-cine)) *p1* *p2*))
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
