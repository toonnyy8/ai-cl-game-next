;;;; hisagi.lisp — HISAGI SHUHEI (檜佐木修兵), roster index 7, kit :hisagi (docs/duel/DUEL_HISAGI.md). Batch B2a: the
;;;; Shikai 風死 KAZESHINI (:base); batch B2b: the Bankai 風死絞縄 (§17): the ranged mode (:bankai, prefix hs-r-), the
;;;; binding throw KUBIKAKE on P, the bind mode (:bankai-bind, prefix hs-b-) and the bind's bookkeeping behind B1b's shared
;;;; hooks (:bind :bind-damage :bind-pool :bind-heal :bind-step :bind-resolve :bind-snapshot, :p :p-label).
;;;; The Shikai (§7-§8): two kusarigama joined by a chain. The sickle has three states (§7.1): IN (in hand), OUT (thrown:
;;;; NAGE / MAKI at their S frame, the anchor written at the first contact or the line's end), RETURNING (the 8 f
;;;; auto-retrieve). The 60 f auto-retrieve timer counts only frames out of his moves, so the state changes only at a
;;;; throw's / pull's S frame, the auto-retrieve, a reset, never inside a move, and every route's state follows from its
;;;; start state: two static string graphs (§7.2), the IN graph as the kit's :strings and the OUT graph's neutral J1 / K
;;;; through the :command hook (one-handed J, K = MODOSHI the no-hit retrieve). The pulls (HIKI, HODOKI) hit along the
;;;; chain from the anchor to his hand (:seg-fn HS-CHAIN-SEG). L is the windmill KAZAGURUMA (:ranged-ward, Q3 A).
;;;; Everything of his lives here and in hisagi-art.lisp; the shared files only call his :hooks. Plain CL above the hooks:
;;;; the host rules test loads it.
(in-package :duel)
(declaim (special *p1* *p2* *match-tick* *match-seed* *pacing* *pacing-log*))   ; (flow.lisp's, components.lisp's)

;;; ================================================================ knobs (DUEL_HISAGI §7-§8, debug 83000-83999)
(defparameter *hs-walk* 3.8 "Walk m/s, the Shikai (the lead's proposal 2026-10-16, DUEL_HISAGI §8.1: Rukia's 3.8).")
(defparameter *hs-run* 9.0 "Run m/s, the Shikai (the lead's proposal 2026-10-16, §8.1).")
(defparameter *hs-mult* 1.15
  "Damage dealt x, the Shikai: the first pacing knob (the lead's proposal 2026-10-16, §8.1; 83100+k: 0.5 + k / 100).")
(defparameter *hs-taken* 1.0 "Damage taken x, the Shikai (the lead's proposal 2026-10-16, §8.1; 83200+k).")
(defparameter *hs-out-frames* 60
  "Frames out of his moves after which a thrown sickle comes back by itself (the user, 2026-10-16: 「1 秒自動收回」, §5, §7.1).")
(defparameter *hs-return-frames* 8 "The auto-retrieve's flight, frames: the sickle RETURNING, no hit (the lead's proposal, §7.1).")
(defparameter *hs-chain-max* 6.5
  "Out of his moves, his hand farther than this (m) from the anchor starts the auto-retrieve at once (the lead's proposal, §7.1).")
(defparameter *hs-drag-to* 1.6 "A NAGE / HIKI hit drags the victim to this many metres (§7.4 M2, M3: ICHIGO-PULL-TO's rule) ...")
(defparameter *hs-drag-frames* 10 "... over this many frames (the lead's proposal 2026-10-16, §7.4).")
(defparameter *hs-push-reach* 6.0
  "The K enders' push is measured from this reach (kit :push-reach): out of the throw's full reach, ~6.45 m by the victim
(the user, 2026-10-17: Q6 B, §13).")
(defparameter *hs-arena-in* 0.3 "An anchor is clamped this far inside the arena's wall (§7.1).")
(defparameter *hs-hand-ahead* 0.45 "The sim's hand (the chain's near end, HS-HAND): this far ahead of his feet ...")
(defparameter *hs-hand-up* 1.1 "... this high (m; a sim point, not the drawn hand: the art draws the chain along HS-CHAIN-SEG).")
(defparameter *hs-anchor-up* 1.0 "The anchor's height (m: the victim's centre).")
(defparameter *hs-seg-r* 0.35 "The pulls' chain capsule radius (m, §8.2 HIKI).")
(defparameter *hs-hook-r* 0.5 "The sickle is drawn hooked in the victim while he is within this of the anchor (m, §7.1; a look).")
(defparameter *hs-kaza-min* 20 "The windmill is held at least this many frames from its up frame (f6) ...")
(defparameter *hs-kaza-max* 60 "... at most this many (its move's active frames), then R 14 (the lead's proposal, §8.3).")
;; the CPU (DUEL_HISAGI §10; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-string-k* 0.7 "His CPU's pull (K) after a NAGE contact, else the one-handed J (the kit's :string-k, §10).")
(defparameter *hs-ai-modoshi-p* '(:easy 0.3 :normal 0.5 :hard 0.7)
  "His CPU, once per OUT start (keyed by the throw's tick): MODOSHI as soon as he is free, else wait for the auto-retrieve.")
(defparameter *hs-ai-windmill-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "His CPU: the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), once per threat (its rising edge).")
(defparameter *hs-ai-windmill-hold* 36 "... L held this many frames (the threat passes).")
(defparameter *hs-ai-sp-ender-p* '(:easy 0.1 :normal 0.3 :hard 0.8)
  "His CPU's SP off a link-3 hit (:sp-ender): SP2 after RIN (IN, 4.5 m line), SP1 after a K ender (6.5 m line).")
(defparameter *hs-ai-opp-step-p* '(:easy 0.1 :normal 0.25 :hard 0.5)
  "A CPU facing him (:opp-reflex): a side Step against NAGE / SP1 (the Bankai's TSUISA / SP1 / KUBIKAKE too, B2b), once per
throw start, while its line will reach it.")

;;; ---------------------------------------------------------------- the Bankai 風死絞縄 (§17, batch B2b)
(defparameter *hs-r-walk* 3.4 "Walk m/s, the Bankai's ranged mode (the lead's proposal 2026-10-17, §17.1: Lille's base).")
(defparameter *hs-r-run* 8.5 "Run m/s, the ranged mode (§17.1).")
(defparameter *hs-r-mult* 1.0
  "Damage dealt x, the ranged mode: the first pacing knob (the lead's proposal 2026-10-17, §17.1; 83300+k: 0.5 + k / 100).")
(defparameter *hs-r-taken* 1.0 "Damage taken x, the ranged mode (§17.1; 83400+k).")
(defparameter *hs-b-walk* 3.8 "Walk m/s, the bind mode (§17.3: Rukia's).")
(defparameter *hs-b-run* 9.0 "Run m/s, the bind mode (§17.3).")
(defparameter *hs-r-push-reach* 7.5 "The ranged mode's K ender push is measured from K1 TSUISA's 7.5 m (kit :push-reach, §17.1).")
(defparameter *hs-tsuisa-to* 3.5 "K1 TSUISA's hit drags the victim to this many metres (inside J's 4.0 m: KJJ reaches; §17.1) ...")
(defparameter *hs-tsuisa-frames* 10 "... over this many frames.")
(defparameter *hs-saharai-hit* 6.5 "L SAHARAI's hit pushes him to this many metres from Hisagi (18 f, §17.1) ...")
(defparameter *hs-saharai-block* 4.5 "... its block to this many (the block slide).")
(defparameter *hs-saharai-frames* 18 "SAHARAI's push, frames (the block's: 12).")
(defparameter *hs-ame-aim* 6 "SP2 KUSARI-AME aims this many frames from its first, then its lane is locked (§17.1).")
(defparameter *hs-kubi-reiatsu* 200.0
  "KUBIKAKE binds only with this much of his own Reiatsu, checked at the press and at contact (the user, 2026-10-17:
「至少要有兩格 reiatus 才能開啟捆綁」, §17.2). The throw itself costs nothing.")
(defparameter *hs-kubi-cooldown* 180 "KUBIKAKE's cooldown from the press after a whiff / block; a hit clears it (Q13 C, §17.2).")
(defparameter *hs-kubi-yank* 2.0 "KUBIKAKE's hit yanks the victim to this many metres ...")
(defparameter *hs-kubi-yank-frames* 12 "... over this many frames (§17.2).")
(defparameter *hs-kubi-cut* 14 "On a hit KUBIKAKE's recovery is cut to this many frames from the hit (+16 on the 30 f reel, §17.2).")
(defparameter *hs-bind-reel* 30 "The opponent reels this many frames when the bind ends, either way (the user, 2026-10-17: 「捆綁結束時讓對手硬直 30f」).")
(defparameter *hs-pull-to* 2.0 "Bind L HIKIYOSE drags the opponent to this many metres ...")
(defparameter *hs-pull-speed* 18.0 "... at this many m/s (*CHASE-MAX*'s speed, §17.3), motion only (never a hit) ...")
(defparameter *hs-pull-min* 2.5 "... refused within this many metres.")
;; his CPU in the Bankai (§17.5 #16; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-throw-p* '(:easy 0.2 :normal 0.45 :hard 0.7)
  "His CPU, ranged mode: KUBIKAKE once per entry into 4-7 m with his own 200 (§17.5 #16).")
(defparameter *hs-ai-saharai-p* '(:easy 0.3 :normal 0.6 :hard 0.85)
  "His CPU, ranged mode: L SAHARAI once per entry within *HS-AI-CLOSE* m (§17.1: the escape at close range).")
(defparameter *hs-ai-close* 2.5 "... the close band, m.")
(defparameter *hs-ai-release-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "His CPU in a bind: the release once per change event (a soul turned grey, every 100 of the pool drained) while his grey
loss exceeds the opponent's by *HS-AI-RELEASE-MARGIN* (Konpaku x 1300 + Reishi, §17.5 #16).")
(defparameter *hs-ai-release-margin* 300 "... the margin (Reishi points).")
(defparameter *hs-ai-pull-p* '(:easy 0.3 :normal 0.6 :hard 0.85) "His CPU in a bind: L HIKIYOSE once per entry beyond 4 m.")
(defparameter *hs-ai-bind-sp-p* '(:easy 0.1 :normal 0.35 :hard 0.7)
  "His CPU in a bind: an SP off a link-3 hit (:sp-ender) only while he is ahead on grey (it drains the pool, §17.5 #16).")

;;; ================================================================ the Shikai 風死 (§8.2, §8.3)
;;; J: the chain held short, one sickle whirled round the body (H1: 1.4 m, 110°, J3 200°, Q5 A). The one-handed copies
;;; (the OUT graph, KJJ) are the same clips at x0.8 written in, :params :one-hand (the empty-hand look).
(defmove :hs-j1 :kind :quick :clip :hs-q1 :startup 8 :active 3 :recovery 12 :dmg 30 :adv-block -2 :guard 8
  :reach 1.4 :arc 110 :on-hit :flinch :slide 0.3)                         ; 旋 SEN
(defmove :hs-j2 :kind :quick :clip :hs-q2 :startup 8 :active 3 :recovery 13 :dmg 30 :adv-block -2 :guard 8
  :reach 1.4 :arc 110 :on-hit :flinch)                                    ; 返旋 KAESHI-SEN
(defmove :hs-j3 :kind :quick :clip :hs-spin :startup 9 :active 3 :recovery 18 :dmg 38 :adv-block -4 :guard 12
  :reach 1.4 :arc 200 :on-hit :stagger :flags (:ender))                   ; 輪 RIN, the full spin
(defmove-copy :hs-j1-1h :hs-j1 :dmg 24 :params (:one-hand t))             ; SEN-1H (the OUT graph's J1)
(defmove-copy :hs-j2-1h :hs-j2 :dmg 24 :params (:one-hand t) :clip :hs-s-kaeshi-1h)   ; KAESHI-SEN-1H (the IN graph's J2s,
                                                                          ;  the OUT J2: the reversed backhand, §21.4)
(defmove-copy :hs-j3-1h :hs-j3 :dmg 30 :params (:one-hand t) :clip :hs-s-rin-1h)         ; RIN-1H (the arm-length pivot)
;; K: the chain. NAGE throws one sickle along a 6 m line (the blade within 2.0 m, the chain beyond: :ranged), turning
;; 30 deg/s in its startup (§7.4 A1), no generic close-in (:no-close): a hit drags him to 1.6 m (HS-DRAG). The sickle is
;; OUT from its S frame, whatever its result (HS-THROW-OUT); the anchor at the first contact (HS-HIT) or its line's end
;; on its last active frame (HS-TICK)
(defmove :hs-k1 :kind :flash :clip :hs-nage :startup 18 :active 4 :recovery 22 :dmg 62 :adv-block -3 :guard 14
  :vol (:cap 0.3 6.0 1.1 0.3) :track 30.0 :on-hit :stagger :flags (:ranged :no-close) :on-land hs-drag
  :on-frame ((18 hs-throw-out)) :params (:melee-range 2.0 :throw 6.0))     ; 投 NAGE
;; HIKI (K2 after NAGE): the pull from behind (ch. 325): the chain from the anchor to his hand (:seg-fn), the sickle IN at
;; its S; a hit drags him to 1.6 m. An explicit :reach for the generic CPU's range reads
(defmove :hs-k2 :kind :flash :clip :hs-hiki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 56 :adv-block -3 :guard 14
  :reach 6.0 :on-hit :stagger :flags (:ranged) :on-land hs-drag :on-frame ((20 hs-sickle-in))
  :hits ((20 24 :seg-fn hs-chain-seg)) :params (:melee-range 2.0))       ; 引 HIKI
;; MAKI (K2s after J1, Q8 A): the chain flung round his body (a 3.2 m line), the sickle OUT, anchored on him
(defmove :hs-k2s :kind :flash :clip :hs-maki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 52 :adv-block -3 :guard 14
  :vol (:cap 0.3 3.2 1.1 0.35) :on-hit :stagger :on-frame ((20 hs-throw-out)) :params (:throw 3.2))   ; 巻 MAKI
;; K3: KARI-OTOSHI after KAESHI-SEN or HIKI (the overhead drop), HODOKI after MAKI (unwound: the hit from behind along the
;; chain, the sickle IN at its S); both push ~6.45 m (the kit's :push-reach, Q6 B)
(defmove :hs-k3 :kind :flash :clip :hs-kari :enter 8 :startup 22 :active 5 :recovery 34 :dmg 80 :adv-block -20 :guard 18
  :reach 2.8 :arc 120 :on-hit :crumple :flags (:ender))                   ; 刈落 KARI-OTOSHI
(defmove :hs-k3h :kind :flash :clip :hs-hodoki :enter 8 :startup 22 :active 5 :recovery 34 :dmg 78 :adv-block -20 :guard 18
  :reach 3.2 :on-hit :crumple :flags (:ender) :on-frame ((22 hs-sickle-in))
  :hits ((22 27 :seg-fn hs-chain-seg)))                                   ; 解 HODOKI
;; MODOSHI (K while the sickle is out): the retrieve, no hit window, IN at f6; not a string link
(defmove :hs-modoshi :kind :flash :clip :hs-modoshi :startup 6 :active 0 :recovery 6 :on-frame ((6 hs-sickle-in)))   ; 戻
;; L 風車 KAZAGURUMA, the windmill (§8.3, Q3 A): up at f6, held 20-60 f (HS-KAZA-TICK), R 14; one push hit as it comes up
;; (20, 1.5 m, 8 f: no lock), 360 deg r 2.0; while it runs, hazards and :ranged windows are guarded from every side
;; (:ranged-ward: their full guard value, the usual chip, no blockstun; unguardables through; a crush drops it). Rooted,
;; free; refused while the sickle is out (HS-OK); cooldown 90 from the press
(defmove :hs-kaza :kind :sig :clip :hs-kaza :startup 6 :active 60 :recovery 14 :whiff 14 :cooldown 90 :dmg 20
  :vol (:arc 2.0 360 0.2 2.0) :on-hit :flinch :kb 1.5 :hits ((6 9 :stun 8)) :tick hs-kaza-tick :flags (:ranged-ward)
  :on-frame ((6 hs-kaza-up)))
;; Shift+K, SP1 破道の十一 綴雷電 TSUZURI RAIDEN (ch. 337): lightning down its own 6.5 m line in every state, the sickle IN
;; at its S; a hit paralyses 40 f (KUSARI-BIKI's)
(defmove :hs-raiden :kind :sp :clip :hs-raiden :callout "TSUZURI RAIDEN" :startup 20 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :vol (:cap 0.3 6.5 1.1 0.3) :track 30.0 :flags (:ranged) :on-hit :bind :hits ((20 23 :stun 40))
  :on-frame ((20 hs-sickle-in)) :params (:melee-range 2.0))
;; Shift+L, SP2 縛 SHIBARI (vs Ayon, ch. 336): one move, two windows on a 4.5 m line: the bind f16-19 (46 f), the slam
;; f46-49 (90, a knockdown); hit before f46 he loses the slam. Refused while the sickle is out (HS-OK)
(defmove :hs-shibari :kind :sp :clip :hs-shibari :callout "SHIBARI" :startup 16 :active 34 :recovery 26 :dmg 60
  :adv-block -14 :vol (:cap 0.3 4.5 1.1 0.35)
  :hits ((16 20 :on-hit :bind :stun 46) (46 50 :dmg 90 :on-hit :knockdown)))
;; I: the universal Breaker, drawn as 首掛け KUBIKAKE (ch. 337 / 384); allowed while out
(defmove :hs-breaker :kind :breaker :clip :hs-breaker :clip-2 :hs-kubikake :callout "KUBIKAKE")
;; O, the Kikon module 刈 KARI: aura 6 (aim 120 deg/s), no dash, the strike along a 7 m lane locked (the sickle hooks him);
;; the follow-up's generic dash drawn as a zip along the chain; cooldown 90; allowed while out
(defmove :hs-kikon :kind :kikon :clip :hs-kari-aim :clip-2 :hs-kari-o :callout "KARE, KAZESHINI" :cine hs-kikon-cine
  :startup 20 :active 2 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 7.0 1.2 1.0)
  :on-hit :knockback :kb 2.0 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 0.0 :dash-max 0 :ender-dash 0 :dash-track 0.0 :look :lane :follow-speed 14.0))

(defparameter *hs-throws* '(:hs-k1 :hs-k2s) "The moves that throw the sickle (OUT at S; their :params :throw = the line's length).")
(defparameter *hs-pulls* '(:hs-k2 :hs-k3h) "The pulls (the chain from the anchor: HS-CHAIN-SEG).")
(defparameter *hs-hooks* '(:tick hs-tick :ok hs-ok :command hs-command :hit hs-hit :struck hs-struck :reset hs-reset
                           :hash hs-hash :draw hisagi-draw :pose hs-pose :deck hs-deck))
(defparameter *hs-shikai-clips* '(:hs-q1 :hs-s-sen :hs-q2 :hs-s-kaeshi :hs-spin :hs-s-rin :hs-nage :hs-s-nage
                                   :hs-hiki :hs-s-hiki :hs-maki :hs-s-maki :hs-kari :hs-s-kari :hs-hodoki :hs-s-hodoki
                                   :hs-modoshi :hs-s-modoshi :hs-kaza :hs-s-kaza :hs-raiden :hs-s-raiden
                                   :hs-shibari :hs-s-shibari :hs-breaker :hs-s-breaker :hs-kubikake :hs-s-kubikake
                                   :hs-kari-aim :hs-s-kari-aim :hs-kari-o :hs-s-kari-o)
  "The Shikai's :clip-map (a look: the clips are hisagi-art.lisp's, the slot plan DUEL_HISAGI §21.3; the one-handed
KAESHI-SEN-1H / RIN-1H name their own clips; SEN-1H plays J1's).")
(defparameter *hs-shikai-looks* '(:sh-walk-f :hs-s-walk-f :sh-walk-b :hs-s-walk-b :sh-strafe-r :hs-s-strafe-r
                                  :sh-strafe-l :hs-s-strafe-l)
  "The Shikai's :look-clips: the shared walk's legs with his own stance's arms (the chain loop dragging).")
(defparameter *hs-forms* '(:base :bankai :bankai-bind)
  "His forms: the Shikai, the Bankai's ranged mode and its bind mode (§17: a mode is a form, switched only out of a move).")

(defkit :hisagi :base
  :name "HISAGI" :body :hisagi :weapon :kazeshini :stance :hs-s-stance
  :intro :hs-s-intro :win :hs-s-win :intro-callout "KARE, KAZESHINI" :intro-weapon (:hs-sealed 70)
  ;; the Shikai's own clips (hisagi-art.lisp, DUEL_HISAGI §21.3-§21.4; a look: the Bankai's forms keep B2a's until their
  ;; motion-style pass): its moves' through :clip-map, the walk through :look-clips, the run set under his arms
  :clip-map *hs-shikai-clips* :look-clips *hs-shikai-looks* :run-clips (:hs-s-run :hs-s-skate-b :hs-s-slide-r :hs-s-slide-l)
  :walk *hs-walk* :run *hs-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *hs-mult* :taken *hs-taken*
  :push-reach *hs-push-reach*
  :commands (:q :hs-j1 :f :hs-k1 :sig :hs-kaza :sp1 :hs-raiden :sp2 :hs-shibari :breaker :hs-breaker :kikon :hs-kikon)
  ;; the IN graph (§7.2): JJJ JJK JKK KKK KKJ KJJ, K3 by route (KARI-OTOSHI after KAESHI-SEN / HIKI, HODOKI after MAKI);
  ;; then the OUT graph's J string (its J1 SEN-1H started by HS-COMMAND; a K during it is eaten)
  :strings ((:hs-j1 :q :hs-j2) (:hs-j1 :f :hs-k2s) (:hs-k1 :f :hs-k2) (:hs-k1 :q :hs-j2-1h)
            (:hs-j2 :q :hs-j3) (:hs-j2 :f :hs-k3) (:hs-k2 :f :hs-k3) (:hs-k2 :q :hs-j3)
            (:hs-j2-1h :q :hs-j3-1h) (:hs-k2s :f :hs-k3h)
            (:hs-j1-1h :q :hs-j2-1h))
  :awaken-form :bankai                          ; the Bankai's ranged mode (§17.1; batch B2b)
  :hooks *hs-hooks*
  ;; an all-rounder at 2-6 m (§6): the throw at 3.5-6.2 m, J strings up close, the windmill against projectiles (his
  ;; :reflex), SP2 / the Breaker at mid range
  :ai (:intents (:approach 2 :pressure 2 :zone 3 :defend 1)
       :ranges (:approach (3.0 5.5) :pressure (1.2 2.2) :zone (3.5 6.0) :defend (4.0 6.0))
       :moves ((0.0 1.8 :q 5 :f 1 :breaker 1 :sp2 1)
               (1.8 3.5 :f 3 :q 1 :sp2 2 :step 1)
               (3.5 6.2 :f 5 :sp1 1 :step 1)
               (6.2 9.0 :sp1 1 :kikon 1 nil 2)
               (9.0 99.0 :kikon 1 nil 2))
       :guard 0.4 :hoho 0.3 :dash 0.6 :dash-back 0.3 :block-string 0.6 :sp-cancel-bars 1 :string-k *hs-ai-string-k*
       :kikon-range 7.0 :reflex hs-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-ai-ender :sig-hold hs-ai-sig-hold))

;;; ================================================================ the Bankai 風死絞縄 (§17; batch B2b)
;;; Two modes, each a kit form: :bankai the ranged mode (the default after the awakening; prefix hs-r-), :bankai-bind the
;;; bind mode (prefix hs-b-). The switch between them is a SET-FORM made by HS-BK-TICK only out of a move (after
;;; KUBIKAKE's cut recovery on entry, on UNWIND's last frame on either end). The look is B2a's body and sickles as they are
;;; (the lead's / the user's decision 2026-10-17: the Bankai's art and clips wait for a motion-style pass): moves play
;;; B2a's clips (the K links the pulls', which fall short of the K volumes as the host FK test allows a K), except the
;;; ranged J (their own frames, the thrown sickle drawn to the arc's edge: *HS-FLIGHTS*, the J's +-0.15 m).
;;;
;;; The ranged mode (§17.1, the user: 「由鎖鏈球設計與揮打鎖鏈為攻擊主體，此時前搖大、攻擊距離長， L 會將人推開」). Beyond
;;; 2.0 m every hit is :ranged (the chain, not the blade). J = chains swung from his hands, K / SP / O = from the orb.
(defmove :hs-r-j1 :kind :quick :clip :hs-r-q1 :startup 12 :active 3 :recovery 12 :dmg 22 :adv-block -2 :guard 8
  :reach 4.0 :arc 100 :on-hit :flinch :hits ((12 15 :stun 24)) :flags (:ranged :no-close) :params (:melee-range 2.0))   ; 鎖鞭 SABEN
(defmove :hs-r-j2 :kind :quick :clip :hs-r-q2 :startup 11 :active 3 :recovery 13 :dmg 22 :adv-block -2 :guard 8
  :reach 4.0 :arc 100 :on-hit :flinch :hits ((11 14 :stun 24)) :flags (:ranged) :params (:melee-range 2.0))   ; 返鞭 KAESHI-BEN
(defmove-copy :hs-r-j2s :hs-r-j2)
(defmove :hs-r-j3 :kind :quick :clip :hs-r-spin :startup 13 :active 3 :recovery 18 :dmg 30 :adv-block -4 :guard 12
  :reach 4.4 :arc 180 :on-hit :stagger :flags (:ender :ranged) :params (:melee-range 2.0))                     ; 旋鎖 SENSA
;; K1 TSUISA: a 7.5 m line from the orb, turning 30 deg/s in its startup, no close-in; a hit drags him to 3.5 m (HS-R-DRAG)
(defmove :hs-r-k1 :kind :flash :clip :hs-hiki :startup 22 :active 4 :recovery 22 :dmg 52 :adv-block -3 :guard 14
  :vol (:cap 0.3 7.5 1.1 0.35) :track 30.0 :on-hit :stagger :flags (:ranged :no-close) :params (:melee-range 2.0)
  :on-land hs-r-drag)                                                                                          ; 墜鎖 TSUISA
(defmove :hs-r-k2 :kind :flash :clip :hs-hiki :enter 6 :startup 24 :active 4 :recovery 24 :dmg 44 :adv-block -3 :guard 14
  :reach 6.0 :arc 140 :on-hit :stagger :flags (:ranged) :params (:melee-range 2.0))                            ; 薙鎖 NAGISA
(defmove-copy :hs-r-k2s :hs-r-k2)
(defmove :hs-r-k3 :kind :flash :clip :hs-hodoki :enter 6 :startup 24 :active 5 :recovery 34 :dmg 66 :adv-block -20 :guard 18
  :vol (:cap 0.3 7.5 1.1 0.5) :on-hit :crumple :flags (:ender :ranged) :params (:melee-range 2.0))              ; 落鎖 RAKUSA
;; L 鎖払 SAHARAI: the chains whirled round him (360 deg r 3.0); a hit pushes him to 6.5 m, a block to 4.5 m (HS-R-PUSH,
;; HS-BK-HIT); cooldown 120 from the press
(defmove :hs-r-l :kind :sig :clip :hs-kaza :startup 14 :active 4 :recovery 22 :dmg 30 :adv-block -4 :guard 14
  :vol (:arc 3.0 360 0.2 2.0) :on-hit :knockback :cooldown 120 :on-land hs-r-push)
(defmove :hs-r-sp1 :kind :sp :clip :hs-raiden :callout "TSUZURI RAIDEN" :startup 20 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :guard 22 :vol (:cap 0.3 9.0 1.1 0.3) :track 30.0 :flags (:ranged) :on-hit :bind :hits ((20 23 :stun 40))
  :params (:melee-range 2.0))                                                                                  ; 綴雷電
;; SP2 鎖雨 KUSARI-AME: a 10 m x 2 m lane, aimed 120 deg/s for its first 6 f then locked (HS-R-AME-AIM); two windows;
;; off a J / K string hit the charge-less copy (:enter 10, S_eff 20: HS-BK-COMMAND)
(defmove :hs-r-sp2 :kind :sp :clip :hs-shibari :callout "KUSARI-AME" :startup 30 :active 14 :recovery 30 :dmg 70
  :adv-block -18 :guard 22 :vol (:cap 1.0 10.0 1.2 1.0) :track 120.0 :flags (:ranged) :params (:melee-range 2.0)
  :tick hs-r-ame-aim :hits ((30 34 :on-hit :flinch) (40 44 :dmg 90 :on-hit :knockdown)))
(defmove-copy :hs-r-sp2c :hs-r-sp2 :enter 10)
;; O 降鎖 KOSA: chains rain along a 9 m lane, no dash (it reaches the 7.95 m K ender push from where he stands)
(defmove :hs-r-kikon :kind :kikon :clip :hs-kari-aim :clip-2 :hs-kari-o :callout "KOSA" :cine hs-kikon-cine
  :startup 20 :active 2 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 9.0 1.2 1.0)
  :on-hit :knockback :kb 2.0 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 0.0 :dash-max 0 :ender-dash 0 :dash-track 0.0 :look :lane :follow-speed 14.0))
;; P 首掛 KUBIKAKE, the binding throw (§17.2): a 7 m line from his hand; his own 200 checked at the press (HS-P-PRESS) and
;; at contact (HS-KUBI-LAND); a hit yanks him to 2.0 m into a 30 f reel, the recovery cut to 14, and the bind starts at the
;; end of the step (HS-BK-TICK); a block / whiff is punishable (-20 / R 42)
(defmove :hs-r-kubikake :kind :flash :clip :hs-nage :callout "KUBIKAKE" :startup 24 :active 4 :recovery 30 :whiff 42 :dmg 40
  :adv-block -20 :guard 14 :vol (:cap 0.3 7.0 1.1 0.35) :track 30.0 :on-hit :stagger :hits ((24 28 :stun 30))
  :flags (:ranged :no-close) :params (:melee-range 2.0) :on-land hs-kubi-land)

;;; The bind mode (§17.3, the user: 「攻擊模組切換成近戰，此時的 L 會將對手拉近」): the melee set at the §2.1 budget
(defmove :hs-b-j1 :kind :quick :clip :hs-q1 :startup 8 :active 3 :recovery 12 :dmg 32 :adv-block -2 :guard 8
  :reach 1.5 :arc 110 :on-hit :flinch :slide 0.3)                                                              ; 弦 GEN
(defmove :hs-b-j2 :kind :quick :clip :hs-q2 :startup 8 :active 3 :recovery 13 :dmg 32 :adv-block -2 :guard 8
  :reach 1.5 :arc 110 :on-hit :flinch)                                                                         ; 返弦
(defmove-copy :hs-b-j2s :hs-b-j2)
(defmove :hs-b-j3 :kind :quick :clip :hs-spin :startup 9 :active 3 :recovery 18 :dmg 40 :adv-block -4 :guard 12
  :reach 1.5 :arc 200 :on-hit :stagger :flags (:ender))                                                        ; 双弦 SOGEN
(defmove :hs-b-k1 :kind :flash :clip :hs-hiki :startup 18 :active 4 :recovery 20 :dmg 64 :adv-block -3 :guard 14
  :vol (:cap 0.3 2.6 1.1 0.35) :on-hit :stagger)                                                               ; 引斬 HIKIGIRI
(defmove :hs-b-k2 :kind :flash :clip :hs-hiki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 56 :adv-block -3 :guard 14
  :reach 2.8 :arc 140 :on-hit :stagger)                                                                        ; 巻斬 MAKIGIRI
(defmove-copy :hs-b-k2s :hs-b-k2)
(defmove :hs-b-k3 :kind :flash :clip :hs-hodoki :enter 8 :startup 22 :active 5 :recovery 34 :dmg 80 :adv-block -20 :guard 18
  :reach 3.0 :arc 120 :on-hit :crumple :flags (:ender))                                                        ; 絞 SHIBORI
;; L 引寄 HIKIYOSE: no hit window; at f16 the noose drags him to 2.0 m at 18 m/s (HS-PULL-STEP: motion only, he keeps every
;; other input), then R 8; refused within 2.5 m (HS-BK-OK); cooldown 90
(defmove :hs-b-l :kind :sig :clip :hs-hiki :startup 16 :active 40 :recovery 8 :cooldown 90 :track 30.0
  :on-frame ((16 hs-pull-go)))
(defmove :hs-b-sp1 :kind :sp :clip :hs-raiden :callout "TSUZURI RAIDEN" :startup 14 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :guard 22 :vol (:cap 0.3 4.0 1.1 0.3) :on-hit :bind :hits ((14 17 :stun 40)))
(defmove :hs-b-sp2 :kind :sp :clip :hs-kari :callout "KOJO" :startup 20 :active 4 :recovery 30 :dmg 160 :adv-block -16
  :guard 30 :reach 3.0 :arc 160 :on-hit :crumple)                                                              ; 絞縄 KOJO
(defmove-copy :hs-b-sp2c :hs-b-sp2 :enter 6)
(defmove :hs-b-kikon :kind :kikon :clip :sh-run :clip-2 :hs-kari-o :callout "KOSHU" :cine hs-kikon-cine
  :startup 8 :active 3 :recovery 24 :dmg 70 :adv-block -14 :reach 2.0 :arc 120 :on-hit :knockback :kb 2.5 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 14.0 :dash-max 30 :dash-track 0.0 :look :flash-step :sfx :hoho-out))      ; 絞首 KOSHU
;; UNWIND: the chains fall slack (20 f, no hit, no iframes): where either end of the bind leaves him (HS-BIND-END-EFFECTS!)
(defmove :hs-b-unwind :kind :flash :clip :hs-modoshi :startup 20 :active 0 :recovery 0 :track 0)

(defparameter *hs-bk-hooks* '(:tick hs-bk-tick :ok hs-bk-ok :command hs-bk-command :hit hs-bk-hit :reset hs-reset
                              :hash hs-hash :draw hisagi-draw :deck hs-deck :p hs-p-press :p-label hs-p-label
                              :bind hs-binding :bind-damage hs-bind-damage :bind-pool hs-bind-pool :bind-heal hs-bind-heal
                              :bind-step hs-bind-step :bind-resolve hs-bind-resolve :bind-snapshot hs-bind-snapshot)
  "The Bankai's hooks (both modes): the bind's state lives on the binder's HSS, so both modes answer B1b's bind hooks.")

(defkit :hisagi :bankai
  :awakening t :form-name "FUSHI NO KOJO" :name "HISAGI" :body :hisagi :weapon :kazeshini :stance :hs-stance
  :intro :hs-intro :win :hs-win :intro-callout "KARE, KAZESHINI"
  :walk *hs-r-walk* :run *hs-r-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *hs-r-mult* :taken *hs-r-taken*
  :push-reach *hs-r-push-reach*
  :commands (:q :hs-r-j1 :f :hs-r-k1 :sig :hs-r-l :sp1 :hs-r-sp1 :sp2 :hs-r-sp2 :breaker :hs-breaker :kikon :hs-r-kikon)
  :grid (:hs-r-j1 :hs-r-j2 :hs-r-j3 :hs-r-k1 :hs-r-k2 :hs-r-k3 :hs-r-j2s :hs-r-k2s)
  :hooks *hs-bk-hooks*
  ;; the ranged mode at 3.5-9 m (§17.5 #12): K at 4-7.8 m, J at 2-4.2 m, L SAHARAI / a back Step up close (his :reflex),
  ;; KUBIKAKE at 4-7 m once per entry with his 200 (his :reflex); his SP only off a link 3 above 300 (keeps the 200)
  :ai (:intents (:approach 1 :pressure 1 :zone 5 :defend 2)
       :ranges (:approach (4.5 7.0) :pressure (3.0 4.2) :zone (4.5 7.5) :defend (5.5 8.5))
       :moves ((0.0 2.0 :sig 2 :q 2 :step 3 :breaker 1)
               (2.0 4.2 :q 4 :f 1 :step 1)
               (4.2 7.8 :f 5 :step 1)
               (7.8 10.0 :f 1 :kikon 1 nil 2)
               (10.0 99.0 :kikon 1 nil 3))
       :guard 0.5 :hoho 0.3 :dash 0.3 :dash-back 0.6 :block-string 0.4 :sp-cancel-bars 4
       :kikon-range 9.0 :reflex hs-r-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-r-ai-ender))

(defkit :hisagi :bankai-bind
  :awakening t :form-name "FUSHI NO KOJO" :name "HISAGI" :body :hisagi :weapon :kazeshini :stance :hs-stance
  :intro :hs-intro :win :hs-win :intro-callout "KARE, KAZESHINI" :endless-form :bankai
  :walk *hs-b-walk* :run *hs-b-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult 1.0 :taken 1.0
  :commands (:q :hs-b-j1 :f :hs-b-k1 :sig :hs-b-l :sp1 :hs-b-sp1 :sp2 :hs-b-sp2 :breaker :hs-breaker :kikon :hs-b-kikon)
  :grid (:hs-b-j1 :hs-b-j2 :hs-b-j3 :hs-b-k1 :hs-b-k2 :hs-b-k3 :hs-b-j2s :hs-b-k2s)
  :hooks *hs-bk-hooks*
  ;; the melee rushdown inside the bind; L pulls beyond 4 m, the release and the SPs are his :reflex / :sp-ender's
  ;; (HS-B-AI-REFLEX: behind on grey -> release; ahead -> SP off a link 3); no generic SP cancel (the pool is shared)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.0 4.0) :pressure (1.0 1.8) :zone (2.0 3.0) :defend (2.5 4.0))
       :moves ((0.0 1.8 :q 5 :f 2 :breaker 1)
               (1.8 3.2 :f 4 :q 1 :step 1)
               (3.2 99.0 nil 2))
       :guard 0.4 :hoho 0.3 :dash 0.8 :dash-back 0.1 :block-string 0.6 :sp-cancel-bars 7
       :kikon-range 3.0 :reflex hs-b-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-b-ai-ender))

;;; ================================================================ pure rules (host-tested: tests/duel-rules-test.lisp)
(defun hs-throw-name-p (name) "Does move NAME throw the sickle?" (and (member name *hs-throws*) t))
(defun hs-anchor-point (x z yaw len)
  "The whiffed throw's anchor: LEN m from (X Z) along facing YAW, clamped into the arena (r *ARENA-RADIUS* - *HS-ARENA-IN*).
Values x z."
  (clamp-to-circle (+ x (* len (fwd-x yaw))) (+ z (* len (fwd-z yaw))) (- *arena-radius* *hs-arena-in*)))
(defun hs-out-next (state out-t in-move far)
  "The sickle's next state and out timer one step on, out of a throw's / pull's S frame (§7.1): IN stays; OUT counts a frame
only out of his moves (IN-MOVE NIL) and starts RETURNING at *HS-OUT-FRAMES*, or at once when FAR (his hand past
*HS-CHAIN-MAX* of the anchor, out of his moves); RETURNING stays (its own countdown: HS-TICK). Values state out-t."
  (case state
    (:out (let ((n (if in-move out-t (1+ out-t))))
            (if (and (not in-move) (or far (>= n *hs-out-frames*))) (values :ret n) (values :out n))))
    (t (values state out-t))))
(defun hs-command-for (state cmd)
  "The OUT graph (§7.2): the move name COMMAND starts from neutral in sickle STATE, :HOLD (K while RETURNING: the press
waits buffered, it throws on the arrival), or NIL (the kit's :commands entry)."
  (unless (eq state :in)
    (case cmd (:q :hs-j1-1h) (:f (if (eq state :ret) :hold :hs-modoshi)))))
(defun hs-refused-p (state cmd) "Is COMMAND refused in sickle STATE (L, SP2 while out or returning: Q4 A)?"
  (and (not (eq state :in)) (member cmd '(:sig :sp2)) t))
(defun hs-kaza-release-p (sf s top held)
  "Does the windmill (S its up frame, TOP = S + A its last held frame) leave its hold at move frame SF: up at least
*HS-KAZA-MIN* frames and L no longer HELD (else it stays up to TOP)?"
  (and (>= sf (+ s *hs-kaza-min*)) (< sf top) (not held)))
(defun hs-band (d)
  "The time-at-range probe's band of distance D (§6): :at-close < 1.8, :at-mid < 4, :at-far <= 6.5, else :at-out."
  (cond ((< d 1.8) :at-close) ((< d 4.0) :at-mid) ((<= d 6.5) :at-far) (t :at-out)))

;;; ================================================================ his state (the sim's): a component on his fighter entity
(defcomponent hss
  "Hisagi's state (HS): on his fighter entity, made on its first use, so a new match's (and PRACTICE's reset's) fighter
starts fresh; a Kikon / Soul Break reset puts the sickle IN (HS-RESET)."
  (state :in)                                 ; the sickle: :in :out :ret (§7.1)
  (anchor (make-f32 2) :type f32vec)          ; the anchor x z (a fixed world point, never moved by art; an f32vec: 0 B reads)
  (anchored nil)                              ; the current throw wrote its anchor (contact or line end)
  (out-t 0 :type fixnum) (ret-t 0 :type fixnum)   ; the out timer (frames out of his moves), the return's countdown
  (throw-t -1 :type fixnum)                   ; the tick the sickle last went out (the CPU's one roll per OUT start)
  (kaza nil)                                  ; he was in the windmill at the last tick (HS-STRUCK's counters)
  (ai-out -1 :type fixnum) (ai-modoshi nil)   ; his CPU: the OUT start it rolled for, and its pick
  (ai-threat nil)                             ; his CPU: a ranged threat seen last step (the windmill's rising edge)
  (opp-key -1 :type fixnum) (opp-go nil)      ; a CPU FACING him (on that fighter's own component): the throw start it
                                              ; rolled for and its pick (HS-AI-OPP)
  ;; the Bankai (§17): the bind lives on the binder's component (B0-B16)
  (bound nil)                                 ; he binds now (his :bind hook)
  (pool 0f0 :type single-float)               ; the shared Reiatsu (B0, B3, B5): it only falls
  (r0 0 :type fixnum) (k0 0 :type fixnum)     ; his Reishi / Konpaku at the bind's start (B0; a real heal raises R0: B6)
  (or0 0 :type fixnum) (ok0 0 :type fixnum)   ; the opponent's
  (bind-t -1 :type fixnum)                    ; the tick his KUBIKAKE hit with his 200 (the bind starts at that step's end)
  (bind-from -1 :type fixnum)                 ; the tick the bind started
  (rel nil) (rel-held nil)                    ; the release: due at the step's release slot / pressed during his own move
  (kubi-cd 0 :type fixnum)                    ; KUBIKAKE's cooldown (180 f after a whiff / block)
  (pull nil)                                  ; L HIKIYOSE's drag runs
  (aim-yaw 0f0 :type single-float)            ; SP2 KUSARI-AME's lane (locked after *HS-AME-AIM* frames)
  (ai-band nil) (ai-rolled nil) (ai-go nil)   ; his CPU (Bankai): the band he is in, rolled for this entry, the pick
  (ai-rel-key -1 :type fixnum))               ; his CPU in a bind: the change event it last rolled the release for
(defun hs (e)
  "E's state (his HSS component, attached on the first call)."
  (or (hss e) (let ((st (make-hss))) (add-component e st) st)))

;;; ================================================================ the chain's geometry (sim points)
(defun hs-hand (e)
  "Values x y z of E's sim hand: the chain's near end (*HS-HAND-AHEAD* ahead of his feet, *HS-HAND-UP* up)."
  (let ((p (pos-of e)) (yaw (yaw-of e)))
    (values (+ (aref p 0) (* *hs-hand-ahead* (fwd-x yaw))) (+ (aref p 1) *hs-hand-up*) (+ (aref p 2) (* *hs-hand-ahead* (fwd-z yaw))))))
(defun hs-chain-seg (e)
  "The pulls' :seg-fn (kit.lisp WINDOW-TOUCHES-P, SEG-GAP): the chain from E's anchor to his hand this frame, its radius.
Values ax ay az bx by bz r."
  (let ((st (hs e)))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (values (aref (hss-anchor st) 0) (f32 *hs-anchor-up*) (aref (hss-anchor st) 1) (f32 hx) (f32 hy) (f32 hz) (f32 *hs-seg-r*)))))
(defun hs-hand-dist (e)
  "How far E's sim hand is from his anchor, on the ground."
  (let ((st (hs e)))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (declare (ignore hy))
      (hypot (- hx (aref (hss-anchor st) 0)) (- hz (aref (hss-anchor st) 1))))))
(defun hs-anchor! (e x z)
  "E's anchor := (X Z), clamped into the arena."
  (let ((st (hs e)))
    (multiple-value-bind (x z) (clamp-to-circle x z (- *arena-radius* *hs-arena-in*))
      (setf (aref (hss-anchor st) 0) (f32 x) (aref (hss-anchor st) 1) (f32 z) (hss-anchored st) t))))

;;; ================================================================ the state machine's events
(defun hs-throw-out (e)
  "A throw's S frame (NAGE / MAKI): the sickle OUT, whatever the result; its anchor still to write."
  (let ((st (hs e)))
    (setf (hss-state st) :out (hss-anchored st) nil (hss-out-t st) 0 (hss-throw-t st) *match-tick*)
    (pace e (if (eq (mv-name (fighter-move (fighter e))) :hs-k1) :throw :maki))
    (clog "~a SICKLE OUT ~a" (side-name e) (mv-name (fighter-move (fighter e))))))
(defun hs-sickle-in (e)
  "A pull's / MODOSHI's / SP1's S frame: the sickle IN."
  (let ((st (hs e)) (name (mv-name (fighter-move (fighter e)))))
    (unless (eq (hss-state st) :in)
      (pace e (case name (:hs-modoshi :modoshi) (:hs-raiden :raiden-in) (t :pull)))
      (clog "~a SICKLE IN ~a" (side-name e) name))
    (setf (hss-state st) :in (hss-out-t st) 0 (hss-ret-t st) 0)))
(defun hs-reset (e)
  "His :reset hook (combat.lisp RESET-ROUND: a Kikon / Soul Break reset): the sickle IN."
  (let ((st (hs e))) (setf (hss-state st) :in (hss-out-t st) 0 (hss-ret-t st) 0 (hss-anchored st) nil)))
(defun hs-pull-to (e to frames)
  "E's chain drags his victim to TO m over FRAMES (his slide replaced; ICHIGO-PULL-TO's rule); T when it moved him."
  (let* ((v (opp-of e)) (p (pos-of e)) (q (pos-of v)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
         (dist (hypot dx dz)))
    (when (> dist to)
      (set-slide v (- dist to) frames dx dz)
      (emit :sfx :chain-snap e)
      t)))
(defun hs-drag (e)
  "NAGE's / HIKI's first real hit (:on-land): the chain drags the victim to *HS-DRAG-TO* m over *HS-DRAG-FRAMES*."
  (when (hs-pull-to e *hs-drag-to* *hs-drag-frames*) (pace e :drag)))
(defun hs-kaza-up (e) "The windmill's up frame (f6): counted." (declare (ignorable e)) (pace e :windmill))
(defun hs-kaza-tick (e)
  "The windmill, each frame: once it has been up *HS-KAZA-MIN* frames, L let go ends the hold (its recovery R 14 next);
the clip follows (a look)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (sf (fighter-sf f)) (top (+ (mv-s mv) (mv-a mv))))
    (when (hs-kaza-release-p sf (mv-s mv) top (vpad-down (pilot-vpad (pilot e)) :sig))
      (setf (fighter-sf f) top)
      (play-clip e (kit-move-clip (fighter-kit f) (mv-clip mv)) :blend 2 :time (/ top 60.0)))))

;;; ================================================================ his hooks
(defun hs-command (e cmd)
  "His :command hook (kit.lisp KIT-COMMAND-MOVE): the OUT graph's J1 / K while the sickle is out (HS-COMMAND-FOR); :HOLD
for K while it returns (fighter.lisp TRY-COMMAND starts nothing, the press stays buffered: it throws on the arrival)."
  (let ((name (hs-command-for (hss-state (hs e)) cmd)))
    (cond ((eq name :hold) :hold)
          (name (find-move name)))))
(defun hs-ok (e cmd combo)
  "His :ok hook: L and SP2 refused while the sickle is out or returning (the cue; Q4 A)."
  (declare (ignore combo))
  (not (hs-refused-p (hss-state (hs e)) cmd)))
(defun hs-hit (att def res hw mv hazard ranged)
  "His :hit hook: a throw's first contact of any kind (hit, block, armour, absorb, a parry, a catch) writes the anchor at
the victim's centre (§7.1); the counters."
  (declare (ignore hw hazard ranged))
  (when (and mv res)
    (let ((st (hs att)) (name (mv-name mv)))
      (when (and (hs-throw-name-p name) (eq (fighter-move (fighter att)) mv) (not (hss-anchored st)))
        (let ((q (pos-of def))) (hs-anchor! att (aref q 0) (aref q 2)))
        (pace att (if (eq (contact-of res) :hit) :throw-hit :throw-touch)))
      (when (member name *hs-pulls*) (pace att (if (eq (contact-of res) :hit) :pull-hit :pull-touch))))))
(defun hs-struck (def att res hw mv hazard ranged)
  "His :struck hook: the windmill's counters (a ranged hit warded, a crush)."
  (declare (ignore att hw mv hazard))
  (let ((f (fighter def)))
    (when (and ranged res (hss-kaza (hs def)))
      (pace def (if (and (eq (fighter-state f) :stun) (eq (fighter-phase f) :guard-break)) :windmill-crush :windmill-block)))))
(defun hs-tick (e f g)
  "His :tick hook in the Shikai (every step, after the hits): the whiffed throw's anchor on its last active frame, the out
timer (only out of his moves) and the auto-retrieve, the return's arrival; the counters."
  (declare (ignore g))
  (let* ((st (hs e)) (mv (and (eq (fighter-state f) :move) (fighter-move f))) (sf (fighter-sf f)))
    (when (and mv (eq (fighter-phase f) :main) (hs-throw-name-p (mv-name mv)) (eq (hss-state st) :out)
               (not (hss-anchored st)) (= sf (+ (mv-s mv) (mv-a mv) -1)))
      (let ((p (pos-of e)))
        (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of e) (getf (mv-params mv) :throw))
          (hs-anchor! e x z)))
      (pace e :throw-whiff))
    (case (hss-state st)
      (:out (multiple-value-bind (s n) (hs-out-next :out (hss-out-t st) mv (and (not mv) (> (hs-hand-dist e) *hs-chain-max*)))
              (setf (hss-out-t st) n)
              (when (eq s :ret)
                (setf (hss-state st) :ret (hss-ret-t st) *hs-return-frames*)
                (pace e (if (>= n *hs-out-frames*) :auto-return :far-return))
                (clog "~a SICKLE RETURNING" (side-name e)))))
      (:ret (when (<= (decf (hss-ret-t st)) 0)
              (setf (hss-state st) :in (hss-out-t st) 0)
              (clog "~a SICKLE IN (returned)" (side-name e)))))
    (setf (hss-kaza st) (and mv (eq (mv-name mv) :hs-kaza) t))
    (when *pacing-log*
      (unless (eq (hss-state st) :in) (pace e :out-frames))
      (pace e (hs-band (fighter-dist f))))))
(defun hs-hash (e)
  "His :hash hook (debug.lisp STATE-HASH-LINE): the sickle's state, the anchor (cm), the timers; the bind (B16): bound, the
pool (x10), the snapshot, the release flags, KUBIKAKE's cooldown."
  (let ((st (hs e)))
    (format nil "s~a ~d ~d o~d r~d b~a p~d ~d/~d ~d/~d ~a~a c~d" (case (hss-state st) (:in "I") (:out "O") (t "R"))
            (round (* 100 (aref (hss-anchor st) 0))) (round (* 100 (aref (hss-anchor st) 1))) (hss-out-t st) (hss-ret-t st)
            (if (hss-bound st) 1 0) (round (* 10 (hss-pool st))) (hss-r0 st) (hss-k0 st) (hss-or0 st) (hss-ok0 st)
            (if (hss-rel st) "R" "-") (if (hss-rel-held st) "H" "-") (hss-kubi-cd st))))

;;; ================================================================ the CPU (his kit's :ai; DUEL_HISAGI §10)
(defun hs-p (b plist) "PLIST's chance (:easy :normal :hard) at brain B's difficulty." (getf plist (brain-difficulty b) (getf plist :normal 0.0)))
(defun hs-ai-reflex (e b s d)
  "His :reflex (free): the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), one roll per threat; MODOSHI once
per OUT start (*HS-AI-MODOSHI-P*), else he waits the auto-retrieve out. A command or NIL."
  (let* ((st (hs e)) (threat (and (eq (hss-state st) :in) (ranged-threat-in e b s d 4 24)))
         (edge (and threat (not (hss-ai-threat st)))))
    (setf (hss-ai-threat st) threat)
    (cond ((and edge (kit-command-ok-p e :sig) (< (sim-rnd01) (hs-p b *hs-ai-windmill-p*)))
           (pace e :ai-windmill)
           (why b :windmill :sig))
          ((and (eq (hss-state st) :out) (not (eql (hss-ai-out st) (hss-throw-t st))))
           (setf (hss-ai-out st) (hss-throw-t st) (hss-ai-modoshi st) (< (sim-rnd01) (hs-p b *hs-ai-modoshi-p*)))
           nil)
          ((and (eq (hss-state st) :out) (hss-ai-modoshi st))
           (setf (hss-ai-modoshi st) nil)
           (pace e :ai-modoshi)
           (why b :modoshi :f)))))
(defun hs-ai-sig-hold (kit d &optional e)
  "His :sig-hold (AI-COMMAND): the windmill held *HS-AI-WINDMILL-HOLD* frames."
  (declare (ignore kit d e))
  *hs-ai-windmill-hold*)
(defun hs-ai-ender (e kit)
  "His :sp-ender (ai.lisp STRING-REFLEX, a link-3 hit): SP2 SHIBARI after RIN with the sickle in (its 4.5 m line reaches
the 2.15 m push), else SP1 TSUZURI RAIDEN (6.5 m: after a K ender's 6.45 m push), *HS-AI-SP-ENDER-P* of the time."
  (declare (ignore kit))
  (let ((b (ai-brain e)) (f (fighter e)))
    (when (and b (>= (reiatsu-bars e) 1) (< (sim-rnd01) (hs-p b *hs-ai-sp-ender-p*)))
      (let ((c (if (and (eq (mv-kind (fighter-move f)) :quick) (kit-command-ok-p e :sp2)) :sp2 :sp1)))
        (when (kit-command-ok-p e c) (pace e (if (eq c :sp2) :ai-sp2 :ai-sp1)) c)))))
(defun hs-ai-opp (e b s d)
  "His kit's :opp-reflex (a CPU facing him): his perceived NAGE / SP1 in its startup, one roll per start (*HS-AI-OPP-STEP-P*);
a yes side-Steps once the line will reach E within 0-14 f (RANGED-THREAT-IN: beyond the blade's 2.0 m)."
  (let ((mv (snap-move s)) (st (hs e)))   ; (his HSS on the CPU's own fighter: a fresh one each match)
    (when (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (member (mv-name mv) '(:hs-k1 :hs-raiden :hs-r-k1 :hs-r-sp1 :hs-r-kubikake))
               (< (snap-sf s) (mv-s mv)) (not (kit-rooted (kit-of e))))
      (unless (eql (hss-opp-key st) (snap-start s))
        (setf (hss-opp-key st) (snap-start s) (hss-opp-go st) (< (sim-rnd01) (hs-p b *hs-ai-opp-step-p*))))
      (when (and (hss-opp-go st) (ranged-threat-in e b s d 0 14))
        (setf (hss-opp-go st) nil)
        (pace (opp-of e) (if (eq (mv-name mv) :hs-r-kubikake) :opp-step-kubi :opp-side-step))
        (why b :anti-throw :side-step)))))

;;; ================================================================ the Bankai: pure rules (host-tested)
(defun hs-kubi-ok-p (state reiatsu cd bound)
  "May P start KUBIKAKE (§17.2): free (idle / walk / guard / a run; not blockstun, never a cancel), his own Reiatsu at
*HS-KUBI-REIATSU*, not cooling down, no bind on the field (B15)?"
  (and (member state '(:idle :guard :run)) (>= reiatsu *hs-kubi-reiatsu*) (<= cd 0) (not bound) t))
(defun hs-rel-free-p (state free)
  "May P release the bind now (§17.3): from idle / walk / guard / blockstun / a run at once; in hitstun / airborne under
the Burst rule (FREE: AWAKEN-STATE-P, past the combo's 2nd hit, Q9 A). During his own move the press is held (HS-REL-DUE-P)."
  (or (and (member state '(:idle :guard :guard-hit :run)) t) (and free (member state '(:stun :air)) t)))
(defun hs-rel-due-p (sf end)
  "A release held during his own move fires on its last frame (move frame SF = END - 1, END its MOVE-END-FRAME): never a
cancel of a whiffed or blocked recovery (§17.5 #6)."
  (>= sf (1- end)))
(defun hs-grey-loss (r0 r k0 k)
  "A fighter's grey loss since the bind's start (Konpaku x *REISHI-MAX* + Reishi: his CPU's release read, §17.5 #16)."
  (+ (* *reishi-max* (- k0 k)) (- r0 r)))
(defun hs-release-wanted-p (mine theirs)
  "His CPU's release read: his grey loss MINE exceeds the opponent's THEIRS by *HS-AI-RELEASE-MARGIN*."
  (> (- mine theirs) *hs-ai-release-margin*))

;;; ================================================================ the bind's bookkeeping (§17.3 B0-B16)
(defun hs-binding (x) "His :bind hook (combat.lisp BIND-OF): does X bind now?" (let ((st (hss x))) (and st (hss-bound st))))
(defun hs-bind-snapshot (b e)
  "His :bind-snapshot hook: E's Reishi and Konpaku at the start of B's bind (the HUD's grey band and grey souls)."
  (let ((st (hs b))) (if (eq e b) (values (hss-r0 st) (hss-k0 st)) (values (hss-or0 st) (hss-ok0 st)))))
(defun hs-bind-damage (b att def n)
  "His :bind-damage hook (DEAL-DAMAGE in a bind): the pool loses 1 per 2 nominal damage of either fighter (B3, rules
BIND-DRAIN); the grey counters."
  (declare (ignore def))
  (let ((st (hs b)))
    (setf (hss-pool st) (f32 (bind-drain (hss-pool st) n)))
    (if (eq att b) (pace b :grey-dealt n) (pace b :grey-taken n))))
(defun hs-bind-pool (b &optional (n 0))
  "His :bind-pool hook (REIATSU-OF / REIATSU-SPEND!): the pool after spending N of it (an SP of either fighter, B5: it
floors at 0, the drained end follows at the step's hits)."
  (let ((st (hs b)))
    (when (plusp n)
      (pace b :pool-sp (round n))
      (setf (hss-pool st) (f32 (max 0.0 (- (hss-pool st) n)))))
    (hss-pool st)))
(defun hs-bind-heal (b e n)
  "His :bind-heal hook (HEAL! in a bind): a heal is real, so E's snapshot rises with it, capped at his max (B6)."
  (let ((st (hs b)) (mx (gauges-reishi-max (gauges e))))
    (if (eq e b)
        (setf (hss-r0 st) (min mx (+ (hss-r0 st) n)))
        (setf (hss-or0 st) (min mx (+ (hss-or0 st) n))))))
(defun hs-bind-start! (e)
  "The bind starts (B0, at the end of KUBIKAKE's hit step): both fighters' Reishi and Konpaku snapshot, the pool = both
Reiatsu bars (200-600), the throw re-armed (Q13 C)."
  (let* ((st (hs e)) (o (opp-of e)) (g (gauges e)) (go (gauges o)))
    (setf (hss-bound st) t (hss-rel st) nil (hss-rel-held st) nil (hss-kubi-cd st) 0 (hss-bind-from st) *match-tick*
          (hss-r0 st) (gauges-reishi g) (hss-k0 st) (gauges-konpaku g)
          (hss-or0 st) (gauges-reishi go) (hss-ok0 st) (gauges-konpaku go)
          (hss-pool st) (f32 (+ (gauges-reiatsu g) (gauges-reiatsu go))) (hss-ai-rel-key st) -1)
    (pace e :binds)
    (pace e :pool-start (round (hss-pool st)))
    (emit :sfx :chain-snap e)
    (clog "~a BIND pool ~,1f" (side-name e) (hss-pool st))))
(defun hs-bind-off! (b key)
  "The bind is over (KEY: the end's counter): the flags off, the pool at the end counted."
  (let ((st (hs b)))
    (pace b key)
    (pace b :pool-end (round (hss-pool st)))
    (setf (hss-bound st) nil (hss-rel st) nil (hss-rel-held st) nil (hss-pull st) nil)))
(defun hs-bind-drained! (b &optional (key :end-drained))
  "The drained end (B7, before SETTLE-SOULS; time-up's too, B10): the grey becomes real (the live values stay), both
Reiatsu bars 0, the grey counts cleared; each fighter at Reishi 0 or out of Konpaku who isn't this step's Kikon victim is
queued a Soul Break, the opponent's first (then SETTLE-SOULS: one cinematic, the trade rule, a draw). T when a soul is
settled this step (a Kikon or a Soul Break: the reset or the finish follows), else NIL."
  (let ((o (opp-of b)))
    (hs-bind-off! b key)
    (dolist (x (list b o))
      (let ((g (gauges x))) (setf (gauges-reiatsu g) 0f0 (gauges-grey g) 0)))
    (dolist (x (list o b))
      (let ((g (gauges x)))
        (when (and (or (soul-break-p (gauges-reishi g)) (<= (gauges-konpaku g) 0)) (not (find x *kikons* :key #'second)))
          (queue-soul-break! (opp-of x) x))))
    (clog "~a BIND DRAINED (~a)" (side-name b) key)
    (and (or *kikons* *soul-breaks*) t)))
(defun hs-bind-released! (b)
  "The released end (B8): both fighters' Reishi and Konpaku = the snapshot (the heals in it, the grey Kikons undone); the
pool left to the opponent first up to his 300, the rest to Hisagi (rules BIND-RELEASE-SPLIT)."
  (let* ((st (hs b)) (o (opp-of b)) (g (gauges b)) (go (gauges o)))
    (multiple-value-bind (to-o to-b) (bind-release-split (hss-pool st))
      (pace b :rel-opp (round to-o))
      (pace b :rel-self (round to-b))
      (hs-bind-off! b :end-released)
      (setf (gauges-reishi g) (hss-r0 st) (gauges-konpaku g) (hss-k0 st)
            (gauges-reishi go) (hss-or0 st) (gauges-konpaku go) (hss-ok0 st)
            (gauges-reiatsu go) (f32 to-o) (gauges-reiatsu g) (f32 to-b))
      (clog "~a BIND RELEASED: ~,1f to the opponent, ~,1f back" (side-name b) to-o to-b))))
(defun hs-bind-end-effects! (b)
  "Either end's effects when no soul is settled (B9): every hazard cleared; the opponent's move ends and he reels
*HS-BIND-REEL* f (the longer of that and a reaction he is in; airborne / down: his fall stands); Hisagi's move (hitstun
included) ends into UNWIND 20 f (airborne / down: his fall stands); the ranged mode once he is out of it (HS-BK-TICK)."
  (let* ((o (opp-of b)) (fo (fighter o)) (p (pos-of b)))
    (clear-hazards)
    (unless (member (fighter-state fo) '(:air :down :wakeup :cine))
      (when (eq (fighter-state fo) :hoho) (setf (model-alpha (model o)) 1f0))
      (unless (and (eq (fighter-state fo) :stun) (>= (- (fighter-stun fo) (fighter-sf fo)) *hs-bind-reel*))
        (set-reaction o :stagger *hs-bind-reel* (aref p 0) (aref p 2) 0.0)))
    (unless (member (state-of b) '(:air :down :wakeup :cine))
      (start-move b (find-move :hs-b-unwind)))
    (emit :sfx :chain-snap b)))
(defun hs-bind-step (b phase)
  "His :bind-step hook: :release (after both fighters stepped, where a Burst applies, before the hits) applies a due
release (B8, B9); :hits (after the step's hits, before SETTLE-SOULS) ends a drained bind (B7; a pool at 0 from this step's
SPs too, B5). A release and a drain on one step: the release wins (§17.5 #11)."
  (let ((st (hs b)))
    (case phase
      (:release (when (hss-rel st) (hs-bind-released! b) (hs-bind-end-effects! b)))
      (:hits (when (<= (hss-pool st) 0f0)
               (unless (hs-bind-drained! b) (hs-bind-end-effects! b)))))))
(defun hs-bind-resolve (b)
  "His :bind-resolve hook (time-up during a bind, B10, Q11 A): resolved as drained, the Soul Breaks' Konpaku counted, no
cinematic, no reset; then flow.lisp TIME-UP reads the winner."
  (setf (hss-pool (hs b)) 0f0)
  (hs-bind-drained! b :end-timeup)
  (loop for (att . def) in (reverse *soul-breaks*) do (settle-konpaku att def t))
  (setf *soul-breaks* nil))

;;; ================================================================ the Bankai: P, the moves' hooks
(defun hs-p-press (e free)
  "His :p hook (fighter.lisp TRY-COMMAND, P once he is awakened; FREE = AWAKEN-STATE-P): in a bind the release KAIBAKU
(HS-REL-FREE-P; else NIL, the press stays buffered as a Burst's); in the ranged mode KUBIKAKE (HS-KUBI-OK-P; refused: the
cue, the press eaten). T = the press taken."
  (let* ((f (fighter e)) (st (hs e)) (s (fighter-state f)))
    (cond ((hss-bound st)
           (when (hs-rel-free-p s free)
             (setf (hss-rel st) t)
             (pace e :release-press)
             (clog "~a KAIBAKU" (side-name e))
             t))
          ((not (eq (fighter-form f) :bankai)) nil)
          ((hs-kubi-ok-p s (gauges-reiatsu (gauges e)) (hss-kubi-cd st) (bind-of e))
           (setf (hss-kubi-cd st) *hs-kubi-cooldown*)
           (start-move e (find-move :hs-r-kubikake))
           (pace e :kubi)
           t)
          (t (emit :refused e :awaken)
             (pace e :kubi-refused)
             (clog "~a refused KUBIKAKE" (side-name e))
             t))))
(defun hs-p-label (e) "His :p-label hook: the touch chip's label." (if (hss-bound (hs e)) "FREE" "BIND"))
(defun hs-kubi-land (e)
  "KUBIKAKE's first real hit (:on-land): the noose yanks him to *HS-KUBI-YANK* m, his recovery cut to *HS-KUBI-CUT* f, the
throw re-armed; with his own 200 still there (Senjumaru's 星 may have drained it) and no bind on the field, the bind is
due at the step's end (HS-BK-TICK); else a plain hit."
  (let* ((st (hs e)) (f (fighter e)) (mv (fighter-move f)))
    (hs-pull-to e *hs-kubi-yank* *hs-kubi-yank-frames*)
    (setf (hss-kubi-cd st) 0)
    (when (and mv (eq (mv-name mv) :hs-r-kubikake))
      (setf (fighter-sf f) (max (fighter-sf f) (- (mv-total mv) *hs-kubi-cut*))))
    (if (and (>= (gauges-reiatsu (gauges e)) *hs-kubi-reiatsu*) (not (bind-of e)))
        (progn (setf (hss-bind-t st) *match-tick*) (pace e :kubi-hit))
        (pace e :kubi-plain))))
(defun hs-r-drag (e) "TSUISA's first real hit: dragged to *HS-TSUISA-TO* m." (when (hs-pull-to e *hs-tsuisa-to* *hs-tsuisa-frames*) (pace e :tsuisa-drag)))
(defun hs-push-to (e to frames)
  "Push E's opponent out to TO m from E over FRAMES (PUSH-APART: the wall pushes E back instead)."
  (let ((d (hypot (- (aref (pos-of e) 0) (aref (pos-of (opp-of e)) 0)) (- (aref (pos-of e) 2) (aref (pos-of (opp-of e)) 2)))))
    (when (< d to) (push-apart e (opp-of e) (- to d) frames))))
(defun hs-r-push (e) "SAHARAI's hit: pushed to *HS-SAHARAI-HIT* m." (hs-push-to e *hs-saharai-hit* *hs-saharai-frames*) (pace e :saharai-hit))
(defun hs-r-ame-aim (e)
  "KUSARI-AME's :tick: the lane aims (the move's :track 120) for its first *HS-AME-AIM* frames, then it is locked."
  (let* ((f (fighter e)) (st (hs e)) (tr (transform e)))
    (if (<= (fighter-sf f) (+ (mv-enter (fighter-move f)) *hs-ame-aim*))
        (setf (hss-aim-yaw st) (transform-yaw tr))
        (setf (transform-yaw tr) (hss-aim-yaw st)))))
(defun hs-pull-go (e) "HIKIYOSE's f16: the noose drags." (setf (hss-pull (hs e)) t) (pace e :pull) (emit :sfx :chain-snap e))
(defun hs-pull-step (e f st)
  "HIKIYOSE's drag, each step after the fighters moved: the opponent moved toward him at *HS-PULL-SPEED* (motion only,
added to his own) until *HS-PULL-TO* m, then Hisagi's R 8; a Hoho / cinematic or his move ending stops it."
  (let ((mv (fighter-move f)) (o (opp-of e)))
    (if (or (not (eq (fighter-state f) :move)) (not (eq (mv-name mv) :hs-b-l)) (member (state-of o) '(:hoho :cine)))
        (setf (hss-pull st) nil)
        (let* ((p (pos-of e)) (q (pos-of o)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
               (dd (max 1e-4 (hypot dx dz))) (step (min (/ *hs-pull-speed* 60.0) (- dd *hs-pull-to*))))
          (when (> step 0)
            (setf (aref q 0) (f32 (+ (aref q 0) (* step (/ dx dd)))) (aref q 2) (f32 (+ (aref q 2) (* step (/ dz dd))))))
          (when (<= (- dd (max step 0.0)) (+ *hs-pull-to* 0.01))
            (setf (hss-pull st) nil (fighter-sf f) (max (fighter-sf f) (+ (mv-s mv) (mv-a mv))))
            (pace e :pull-arrive))))))
(defun hs-bk-ok (e cmd combo)
  "The Bankai's :ok hook: bind L HIKIYOSE refused within *HS-PULL-MIN* m (the cue)."
  (declare (ignore combo))
  (let ((f (fighter e))) (not (and (eq cmd :sig) (eq (fighter-form f) :bankai-bind) (< (fighter-dist f) *hs-pull-min*)))))
(defun hs-bk-command (e cmd)
  "The Bankai's :command hook: SP2 off a J / K string hit is the charge-less copy (KUSARI-AME :enter 10, KOJO :enter 6)."
  (when (eq cmd :sp2)
    (let* ((f (fighter e)) (mv (fighter-move f)))
      (when (and (eq (fighter-state f) :move) mv (member (mv-kind mv) '(:quick :flash)) (eq (fighter-contact f) :hit))
        (find-move (if (eq (fighter-form f) :bankai) :hs-r-sp2c :hs-b-sp2c))))))
(defun hs-bk-hit (att def res hw mv hazard ranged)
  "The Bankai's :hit hook: SAHARAI's block pushes him to *HS-SAHARAI-BLOCK* m; KUBIKAKE's block counted."
  (declare (ignore def hw hazard ranged))
  (when (and mv res (eq (contact-of res) :block))
    (case (mv-name mv)
      (:hs-r-l (hs-push-to att *hs-saharai-block* 12) (pace att :saharai-block))
      (:hs-r-kubikake (pace att :kubi-block)))))
(defun hs-try-bind! (e)
  "KUBIKAKE hit this step (HSS-BIND-T = now: a step that settled a Kikon or a Soul Break started a cinematic, so this tick
came later and the hit is stale: no bind, B2 / §17.2): the bind starts unless one is up or both throws hit in this step
(the mirror, B15: neither binds)."
  (let* ((o (opp-of e)) (os (hss o)))
    (if (or (bind-of e) (and os (= (hss-bind-t os) *match-tick*)))
        (pace e :kubi-nobind)
        (hs-bind-start! e))))
(defun hs-p-pressed! (e)
  "Is P buffered on E's vpad (then consumed)? The release pressed during his own move (HS-BK-TICK)."
  (let ((vp (pilot-vpad (pilot e))))
    (when (vpad-command-pressed-p vp :awaken :any) (vpad-consume! vp :awaken) t)))
(defun hs-bk-tick (e f g)
  "The Bankai's :tick hook (every step, after the hits and SETTLE-SOULS): the bind's start, the release held through his
own move, HIKIYOSE's drag, the mode = the bind (a SET-FORM only out of a move), KUBIKAKE's cooldown, the counters."
  (declare (ignore g))
  (let* ((st (hs e)) (s (fighter-state f)) (mv (and (eq s :move) (fighter-move f))))
    (setf (hss-state st) :in)                           ; (no out-of-hand state in the Bankai: the scythes come back)
    (when (plusp (hss-kubi-cd st)) (decf (hss-kubi-cd st)))
    (when (and mv (eq (mv-name mv) :hs-r-kubikake) (eq (fighter-phase f) :main) (= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
               (null (fighter-contact f)))
      (pace e :kubi-whiff))
    (when (= (hss-bind-t st) *match-tick*) (hs-try-bind! e))
    (when (hss-bound st)
      (pace e :bind-frames)
      (when (and mv (not (eq (mv-name mv) :hs-b-unwind)) (hs-p-pressed! e))   ; P during his own move: held
        (setf (hss-rel-held st) t))
      (when (and (hss-rel-held st) (not (hss-rel st))
                 (if mv
                     (and (eq (fighter-phase f) :main)
                          (hs-rel-due-p (fighter-sf f) (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) (fighter-contact f)
                                                                       (zerop (length (mv-hits mv))))))
                     (hs-rel-free-p s (awaken-state-p e f))))
        (setf (hss-rel st) t (hss-rel-held st) nil)
        (pace e :release-held)))
    (when (hss-pull st) (hs-pull-step e f st))
    (let ((want (if (hss-bound st) :bankai-bind :bankai)))
      (unless (or (eq (fighter-form f) want) (member s '(:move :cine)))
        (set-form e want)))
    (when *pacing-log*
      (let ((d (fighter-dist f)))
        (if (hss-bound st)
            (when (< d 2.0) (pace e :b-near))
            (progn (pace e :r-frames)
                   (cond ((< d 2.0) (pace e :r-near)) ((<= 3.5 d 9.0) (pace e :r-mid)))))))))

;;; ================================================================ the Bankai's CPU (§17.5 #16)
(defun hs-r-ai-reflex (e b s d)
  "His :reflex in the ranged mode (free): once per entry into a band, one roll: within *HS-AI-CLOSE* m L SAHARAI (the
escape), at 4-7 m KUBIKAKE with his own 200 (rolled when it can go: the first such step of the entry)."
  (declare (ignore s))
  (let* ((st (hs e)) (band (cond ((< d *hs-ai-close*) :close) ((<= 4.0 d 7.0) :throw))))
    (unless (eq band (hss-ai-band st)) (setf (hss-ai-band st) band (hss-ai-rolled st) nil (hss-ai-go st) nil))
    (case band
      (:close (when (and (not (hss-ai-rolled st)) (kit-command-ok-p e :sig))
                (setf (hss-ai-rolled st) t)
                (when (< (sim-rnd01) (hs-p b *hs-ai-saharai-p*))
                  (pace e :ai-saharai)
                  (why b :saharai :sig))))
      (:throw (when (and (not (hss-ai-rolled st))
                         (hs-kubi-ok-p (fighter-state (fighter e)) (gauges-reiatsu (gauges e)) (hss-kubi-cd st) (bind-of e)))
                (setf (hss-ai-rolled st) t)
                (when (< (sim-rnd01) (hs-p b *hs-ai-throw-p*))
                  (pace e :ai-throw)
                  (why b :kubikake :awaken)))))))
(defun hs-r-ai-ender (e kit)
  "His :sp-ender in the ranged mode (a link-3 hit): SP1 (9 m line: after the 7.95 m K push too) only above 300 Reiatsu,
so the throw's 200 stays (*HS-AI-SP-ENDER-P*)."
  (declare (ignore kit))
  (let ((b (ai-brain e)))
    (when (and b (>= (reiatsu-of e) (+ *hs-kubi-reiatsu* *reiatsu-bar*)) (kit-command-ok-p e :sp1)
               (< (sim-rnd01) (hs-p b *hs-ai-sp-ender-p*)))
      (pace e :ai-sp1)
      :sp1)))
(defun hs-grey-margin (e)
  "E's grey loss minus his opponent's in E's bind (positive: E is behind)."
  (let* ((st (hs e)) (o (opp-of e)) (g (gauges e)) (go (gauges o)))
    (- (hs-grey-loss (hss-r0 st) (gauges-reishi g) (hss-k0 st) (gauges-konpaku g))
       (hs-grey-loss (hss-or0 st) (gauges-reishi go) (hss-ok0 st) (gauges-konpaku go)))))
(defun hs-b-ai-reflex (e b s d)
  "His :reflex in the bind mode (free): the release once per change event (either Konpaku changed: a grey Kikon; every
100 of the pool drained) when behind (HS-RELEASE-WANTED-P, *HS-AI-RELEASE-P*), else let it drain; L HIKIYOSE once per
entry beyond 4 m."
  (declare (ignore s))
  (let* ((st (hs e)))
    (when (hss-bound st)
      (let ((key (+ (* 10000 (floor (hss-pool st) 100)) (* 100 (gauges-konpaku (gauges (opp-of e)))) (gauges-konpaku (gauges e)))))
        (unless (= key (hss-ai-rel-key st))
          (setf (hss-ai-rel-key st) key)
          (when (and (> (hs-grey-margin e) *hs-ai-release-margin*) (< (sim-rnd01) (hs-p b *hs-ai-release-p*)))
            (pace e :ai-release)
            (return-from hs-b-ai-reflex (why b :kaibaku :awaken))))))
    (let ((band (and (> d 4.0) :far)))
      (unless (eq band (hss-ai-band st)) (setf (hss-ai-band st) band (hss-ai-rolled st) nil))
      (when (and band (not (hss-ai-rolled st)) (kit-command-ok-p e :sig))
        (setf (hss-ai-rolled st) t)
        (when (< (sim-rnd01) (hs-p b *hs-ai-pull-p*))
          (pace e :ai-pull)
          (why b :hikiyose :sig))))))
(defun hs-b-ai-ender (e kit)
  "His :sp-ender in the bind mode (a link-3 hit): only while not behind on grey, SP2 KOJO (2 bars of the pool) else SP1
(*HS-AI-BIND-SP-P*); behind, nothing (the pool is his clock too)."
  (declare (ignore kit))
  (let ((b (ai-brain e)))
    (when (and b (hss-bound (hs e)) (<= (hs-grey-margin e) 0) (< (sim-rnd01) (hs-p b *hs-ai-bind-sp-p*)))
      (let ((c (if (kit-command-ok-p e :sp2) :sp2 :sp1)))
        (when (kit-command-ok-p e c) (pace e (if (eq c :sp2) :ai-bsp2 :ai-bsp1)) c)))))

;;; ================================================================ the gate line, probes, debug (83000-83999)
(defun hisagi-acc-line ()
  "After a gate row: a \"duel hisagi\" line per side that played him (the pacing log: throws, pulls, auto-returns, the
windmill's holds / blocks / crushes, out frames, the time-at-range bands)."
  (dolist (e (list *p1* *p2*))
    (when (and (entity-alive-p e) (eq (fighter-character (fighter e)) :hisagi))
      (log-msg "duel hisagi ~a seed ~d form ~a ~{~(~a~) ~a~^ ~}" (side-name e) *match-seed* (fighter-form (fighter e))
               (svref *pacing* (fighter-side (fighter e)))))))

(defun hisagi-probe-line (tag)
  (let ((st (hs *p1*)) (g2 (gauges *p2*)))
    (log-msg "duel probe hisagi ~a t ~d p1 ~a ~a sickle ~a anchor ~,2f ~,2f out ~d ret ~d rei ~,1f | p2 ~a r~d gg ~d | d ~,2f"
             tag *match-tick* (fighter-form (fighter *p1*)) (state-of *p1*) (hss-state st) (aref (hss-anchor st) 0) (aref (hss-anchor st) 1)
             (hss-out-t st) (hss-ret-t st) (gauges-reiatsu (gauges *p1*)) (state-of *p2*) (gauges-reishi g2)
             (round (gauges-gg g2)) (fighter-dist (fighter *p1*))))
  (let ((st (hs *p1*)) (g1 (gauges *p1*)) (g2 (gauges *p2*)))
    (log-msg "duel probe hisagi-bind ~a t ~d bound ~a pool ~,1f p1 rei ~d/~d k ~d/~d ra ~,1f | p2 rei ~d/~d k ~d/~d ra ~,1f ~a | cd ~d"
             tag *match-tick* (hss-bound st) (hss-pool st) (gauges-reishi g1) (hss-r0 st) (gauges-konpaku g1) (hss-k0 st)
             (gauges-reiatsu g1) (gauges-reishi g2) (hss-or0 st) (gauges-konpaku g2) (hss-ok0 st) (gauges-reiatsu g2)
             (state-of *p2*) (hss-kubi-cd st))))

(defun hisagi-test (k)
  "83000+k (human P1 Hisagi, P2's CPU off unless noted, P1's Reiatsu full; a \"duel probe hisagi\" line): 0 2 m from an idle
Kenpachi; 1 6 m from him; 2 4 m from him, the sickle out (anchored 3 m ahead, the timer at 0); 3 8 m from Yamamoto, his L
wave started, the windmill started (blocked from every side); 4 5 m from Kenpachi, NAGE started (the throw); 5 the mirror,
both CPUs, 6 m apart; 6 2 m from Kenpachi, J1 started (the JKK: K K for MAKI, HODOKI). The Bankai (B2b; P1 awakened,
HS-AWAKEN-NOW!): 10 the ranged mode 6 m from Kenpachi; 11 5 m from him, KUBIKAKE started (P: the bind on a hit); 12 a bind
3 m from him with grey values (he dealt 300, took 200: the pool 600 -> 350); 13 as 12, the release pressed (applied this
step: the snapshot back, the pool's 350 split 300 / 50, the reel, UNWIND); 14 as 12, the pool at 1 and a 10 hit (the
drained end at this step's hits); 15 the Bankai mirror, both CPUs awakened, 6 m apart; any other k the probe line only."
  (flet ((setup (c2 dist &key cpu)
           (ensure-battle :hisagi c2 :cpu cpu)
           (when (brain *p1*) (setf (brain-off (brain *p1*)) (not cpu)))
           (place *p1* *p2* dist)
           (hs-reset *p1*)
           (full-gauges! *p1*) (full-gauges! *p2*)))
    (case k
      (0 (setup :kenpachi 2.0))
      (1 (setup :kenpachi 6.0))
      (2 (setup :kenpachi 4.0)
         (let ((st (hs *p1*)) (p (pos-of *p1*)))
           (setf (hss-state st) :out (hss-out-t st) 0 (hss-throw-t st) *match-tick*)
           (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of *p1*) 3.0) (hs-anchor! *p1* x z))))
      (3 (setup :yamamoto 8.0) (force-cmd *p2* :sig) (force-cmd *p1* :sig))
      (4 (setup :kenpachi 5.0) (force-cmd *p1* :f))
      (5 (setup :hisagi 6.0 :cpu t))
      (6 (setup :kenpachi 2.0) (force-cmd *p1* :q))
      (10 (setup :kenpachi 6.0) (hs-awaken-now! *p1*))
      (11 (setup :kenpachi 5.0) (hs-awaken-now! *p1*) (hs-p-press *p1* t))
      ((12 13 14) (setup :kenpachi 3.0) (hs-awaken-now! *p1*) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind)
       (deal-damage *p1* *p2* 300) (deal-damage *p2* *p1* 200)
       (case k
         (13 (setf (hss-rel (hs *p1*)) t))
         (14 (setf (hss-pool (hs *p1*)) 1f0) (deal-damage *p1* *p2* 10))))
      (15 (setup :hisagi 6.0 :cpu t) (hs-awaken-now! *p1*) (hs-awaken-now! *p2*)))
    (hisagi-probe-line (format nil "test ~d" k))))

(defun hs-awaken-now! (e)
  "A scene's awakening (no cinematic, no heal): E in the Bankai's ranged mode, the gauge spent."
  (let ((g (gauges e))) (setf (gauges-awakened g) t (gauges-awaken g) 0f0 (gauges-evolution g) nil))
  (set-form e :bankai)
  (to-idle e 0))

(defun hisagi-debug (c)
  "His debug commands (debug.lisp *CHAR-DEBUG*, 83000-83999, docs/duel/DUEL_GAMEPLAY.md): 83000+k HISAGI-TEST k; 83100+k /
83200+k the Shikai's damage dealt / taken x (0.5 + k / 100); 83300+k / 83400+k the ranged mode's (B2b); 83900 the probe
lines."
  (cond ((< c 83100) (hisagi-test (- c 83000)))
        ((< c 83200) (setf (kit-mult (find-kit :hisagi :base)) (+ 0.5 (/ (- c 83100) 100.0))))
        ((< c 83300) (setf (kit-taken (find-kit :hisagi :base)) (+ 0.5 (/ (- c 83200) 100.0))))
        ((< c 83400) (setf (kit-mult (find-kit :hisagi :bankai)) (+ 0.5 (/ (- c 83300) 100.0))))
        ((< c 83500) (setf (kit-taken (find-kit :hisagi :bankai)) (+ 0.5 (/ (- c 83400) 100.0))))
        ((= c 83900) (hisagi-probe-line "probe"))
        (t (log-msg "duel hisagi: no debug command ~d" c))))
(pushnew '(83000 83999 hisagi-debug) *char-debug* :test #'equal)
