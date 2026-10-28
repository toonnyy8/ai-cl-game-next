;;;; hisagi.lisp — HISAGI SHUHEI (檜佐木修兵), roster index 7, kit :hisagi (docs/duel/DUEL_HISAGI.md). Batch B2a: the
;;;; Shikai 風死 KAZESHINI (:base); batch B2b: the Bankai 風死絞縄 (§17): the ranged mode (:bankai, prefix hs-r-), the
;;;; binding throw KUBIKAKE (on P; on SP2 since B4c), the bind mode (:bankai-bind, prefix hs-b-) and the bind's bookkeeping behind B1b's shared
;;;; hooks (:bind :bind-damage :bind-pool :bind-heal :bind-step :bind-resolve :bind-snapshot, :p :p-label).
;;;; The Shikai (§7-§8): two kusarigama joined by a chain. The sickle has three states (§7.1): IN (in hand), OUT (thrown:
;;;; NAGE / MAKI at their S frame, the anchor written at the first contact or the line's end), RETURNING (the 8 f
;;;; auto-retrieve). The 60 f auto-retrieve timer counts only frames out of his moves, so the state changes only at a
;;;; throw's / pull's S frame, the auto-retrieve, a reset, never inside a move, and every route's state follows from its
;;;; start state: two static string graphs (§7.2), the IN graph as the kit's :strings and the OUT graph's neutral J1 / K
;;;; through the :command hook (one-handed J, K = MODOSHI the no-hit retrieve). The pulls (HIKI, HODOKI) hit along the
;;;; chain from the anchor to his hand (:seg-fn HS-CHAIN-SEG). L is the windmill KAZAGURUMA (:ranged-ward, Q3 A).
;;;; Everything of his lives here and in his other files; the shared files only call his :hooks. His files (the art ones split
;;;; 2026-10-21, refactor round 2): this one (knobs, kit, rules, state, hooks, the Bankai's rules and moves, the debug tail),
;;;; hisagi-ai.lisp (the Shikai's and the Bankai's CPU, the learner, ASSIST, and the *HS-AI-...* knobs: loads right after this file;
;;;; the three knobs the kit data reads at load stay here, with *HS-AI-RELEASE-MARGIN*, which a rule function reads), hisagi-art.lisp (body, Kazeshini, clips), hisagi-draw.lisp (looks,
;;;; HISAGI-DRAW, the HUD icon), hisagi-cine.lisp (the cinematics), hisagi-stills.lisp (debug stills and probes). Plain CL above
;;;; the hooks: the host rules test loads it.
(in-package :duel)
(declaim (special *match-seed* *pacing* *pacing-log*))   ; (flow.lisp's, components.lisp's; the host test loads this file before them)

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
;; S1 (DUEL_HISAGI §23, §23.1; the user, 2026-10-18: 「然後始解的 L 我想讓 L 能變成 J 與 K 之間的銜接連段。並增加 L 蓄力越長，接上 K
;; 連段時攻擊距離越遠的特性」): L a bridge off a J1 / J2 / J3 hit into the windmill, K from it a full K string whose reach grows
;; with the frames L was held (「連續：每幀 +1%，上限 ×1.6」, 「接下來整串 K」; the neutral windmill too: 「中立的風車可以蓄力接 K」)
(defparameter *hs-kaza-cooldown* 0 "The windmill's cooldown from the press (90 -> 0, 2026-10-18, the user: 「拿掉冷卻」).")
(defparameter *hs-charge-step* 0.01
  "Each frame L holds the windmill up adds this to the next K string's reach x (none -> +1 %, 2026-10-18, the user:
「連續：每幀 +1%，上限 ×1.6」) ...")
(defparameter *hs-charge-max* 60 "... counted at most this many frames (the windmill's 60 active: x1.6, the user's cap).")
(defparameter *hs-k-dead* 3.0
  "The Shikai's K1 misses a victim nearer than this (m, centre to centre: :min-reach) (none -> 2.0, 2026-10-18, the user:
「K 串改成純遠距離，近距離打不中」, 「2.0 m（推薦）」, §23.2; 2.0 -> 3.0, 2026-10-18, the user: 「將 K1 能打中的最近距離拉遠」,
「始解 K1 薙」, 「3.0 m（推薦）」, §24.4; K2 / K3 follow the victim: no dead zone, §23.3).")
(defparameter *hs-k1-arc* 90
  "K1 NAGI's sweep, degrees (S1's pick for 「K1 是鎖鏈拉動鐮刀橫向遠程揮擊」: NAGE's 6 m line made a sideways swing, 2026-10-18,
§23.3).")
(defparameter *hs-bridge-kb* 2.5
  "The bridge windmill's push :kb (m; the neutral windmill keeps 1.5): far enough that K1 out of a J1 -> L reaches past its
dead zone (1.5 (the windmill's) -> 2.5, 2026-10-18, the user: 「3.0 m，風車銀接推更遠（推薦）」, §24.4).")
(defparameter *hs-kaza-k-from* 9
  "K starts the K string from this windmill frame on (its push window's end, f6-8: the push lands first) to its last
(hold or recovery; S1's pick, 2026-10-18, §23.1).")
;; S2 (§23.4-§23.5; the user, 2026-10-18: 「始解 KJJ, KKJ 時 J 會跳近對手進行攻擊」): a J link after a K leaps in
(defparameter *hs-leap-s* 14
  "The J links after a K (J2K after K1, J3K after K2): their startup, the leap in (J2's 8 / J3's 9 -> 14; S2's pick: the hit
lands 14 f after the K's chain opens, 18 f after its hit, inside its 26 f stagger) ...")
(defparameter *hs-leap-max* 9.6
  "... the leap covers at most this many m (its speed cap, 60 x this / (S - 1) m/s: K1's 6.0 x the charge's 1.6; S2's pick,
the spec's bound) toward the victim's position each frame, to J's chase goal (1.0 m) as the hit window opens ...")
(defparameter *hs-leap-block* -6
  "... and their block advantage (J2's -2 / J3's -4 -> -6, -9 for the defender with the J's +3: his J1 punishes a blocked
leap; S2's pick, the spec: 「punishable sensibly on block」).")
;; the CPU (DUEL_HISAGI §10; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-string-k* 0.0
  "His CPU's K after a link the generic string reflex picks for (the kit's :string-k, §10: 0.7 -> 0.0, cell b0a0: HS-AI-MOVE picks
every J / K link; this one only opens a string off a Breaker hit, where K1's 3.0 m dead zone whiffs: J1 there).")
(defparameter *hs-ai-l-after-j* 0.3
  "His CPU's L off a J link that hit (the kit's :l-after-j, one roll per hit; S1 §23.1, 2026-10-18): the bridge into the
windmill.")
(defparameter *hs-ai-awaken* '(:min-taken 3000)
  "His Shikai's :awaken gate (AI-AWAKEN-P, a kit gate; cell b0a0): the awakening waits until he has taken this much damage
in the match: the Shikai's chain is the fight, the Bankai his last stand (its combo break, the 20 % heal, KUBIKAKE into
the bind). (None -> 3000: the shipped CPU awoke at once and its ranged mode dealt 5 a second against 38 taken at HARD.)
(Cell b3a0, with b1a0's fence in the Bankai: 3000 -> HARD 0.37 -> 0.31, 2000 -> 0.24 at 10 seeds; 4500 kept.) Round01 cell
b3a0 on §25.13's rules, with round01 b1a0's route styles, the waking noose and the bind's ledger: 4500 -> 3000 (HARD over
1200 matches, seeds 1-40 + 101-160: 2000 0.419 / 0.460, 2500 0.446 / 0.463, 3000 0.490 / 0.467, 3500 0.467 / 0.440, 4500
0.465 / 0.444 before the reap's 3 steps; the ranged + bind share of his damage 0.01 -> 0.12).")
;;; ---------------------------------------------------------------- the Bankai 風死絞縄 (§17, batch B2b)
(defparameter *hs-r-walk* 2.8
  "Walk m/s, the Bankai's ranged mode (the lead's proposal 2026-10-17, §17.1: Lille's base 3.4; 3.4 -> 2.8, 2026-10-18, the
user: 「可以」 to DUEL_HISAGI §22.1: he stands his ground, the chains move).")
(defparameter *hs-r-run* 8.5 "Run m/s, the ranged mode (§17.1).")
(defparameter *hs-r-mult* 1.0
  "Damage dealt x, the ranged mode: the first pacing knob (the lead's proposal 2026-10-17, §17.1; 83300+k: 0.5 + k / 100).")
(defparameter *hs-r-taken* 1.0 "Damage taken x, the ranged mode (§17.1; 83400+k).")
(defparameter *hs-b-walk* 3.8 "Walk m/s, the bind mode (§17.3: Rukia's).")
(defparameter *hs-b-run* 9.0 "Run m/s, the bind mode (§17.3).")
(defparameter *hs-r-push-reach* 7.5
  "The ranged mode's K ender push is measured from this (kit :push-reach, §17.1: K1 TSUISA's old 7.5 m line; kept for B4c's
K3 / K3G, ~7.95 m: inside the O's 9 m lane and SP1's 9 m line, though K1 綁束 reaches 3.0 now, §22.6; 4.0 since B4d, §22.8).")
(defparameter *hs-b-push-reach* 2.95
  "The bind mode's K ender push is measured from this (kit :push-reach): K1 HIKIGIRI's capsule is 2.6 m long but 0.35 m
thick, so the generic push from its 2.6 m (to ~3.0 m) left the victim inside a restarted K1 (it touches him out to ~3.3
m); from 2.6 + the capsule's 0.35 the push reaches ~3.35 m (none -> 2.95, 2026-10-18, the user: 「修 A」, DUEL_HISAGI
§22.9).")
(defparameter *hs-saharai-hit* 3.5
  "L SAHARAI's hit pushes him to this many metres from Hisagi (18 f, §17.1) (6.5 -> 3.5, 2026-10-18, the user: 「L 將對手推開
的距離必須讓 J1, K1 能打中」, then 「卍解遠程 L 推到 3.5 公尺」, §23.2: inside J1's 3.0-5.0 and K1's 2.0-4.0) ...")
(defparameter *hs-saharai-block* 3.5 "... its block to this many (the block slide) (4.5 -> 3.5, the same: 「被擋也推到」).")
(defparameter *hs-saharai-frames* 18 "SAHARAI's push, frames (the block's: 12).")
;; B4d (§22.8; the user, 2026-10-18: 「近身的敵人要靠 L 快速擊退（去掉遠程時 L 的冷卻，一樣調整前後搖來控制出招的主動性）」; the
;; numbers the lead's for that direction, 2026-10-18): the ranged L SAHARAI loses its cooldown (120 -> 0)
(defparameter *hs-saharai-s* 18
  "The ranged L SAHARAI's startup (14 -> 10: 「快速擊退」; 10 -> 18, 2026-10-19, the user: 「把 L 的前搖加長，並把前搖時蓄力的
動作模組做的更容易辨識」, 「10→18 幀」, §25.7: the charge drawn) ...")
(defparameter *hs-saharai-r* 32 "... its recovery (22 -> 32: 「調整前後搖來控制出招的主動性」) ...")
(defparameter *hs-saharai-adv* -16 "... and its block advantage (-4 -> -16): a quick repel with real commitment.")
(defparameter *hs-saharai-armor* 1
  "... and its armour: the hits it takes from move frame *ARMOR-FROM* to S-1, its charge (0 -> 1, 2026-10-21, the user:
「把修兵卍解的遠距 L 多加一層的霸體，讓他可以扛下一次攻擊」, DUEL_HISAGI §25.23): damage, no reaction; a Breaker, an
unguardable or a rend still breaks it (rules ARMOR).")
(defparameter *hs-ame-aim* 6 "SP2 KUSARI-AME aims this many frames from its first, then its lane is locked (§17.1).")
(defparameter *hs-kubi-reiatsu* 200.0
  "KUBIKAKE binds only with this much of his own Reiatsu, checked at the press and at contact (the user, 2026-10-17:
「至少要有兩格 reiatus 才能開啟捆綁」, §17.2). The throw itself costs nothing.")
(defparameter *hs-kubi-whiff* 60
  "KUBIKAKE's whiff recovery (frames): its price now that it has no cooldown (cooldown 180 -> none, whiff 42 -> 60, 2026-10-18,
the user: 「SP2 的捆縛去除冷卻，一樣用打空的後搖來控制出招成本」, the lead's number; §24.5).")
(defparameter *hs-kubi-yank* 2.0 "KUBIKAKE's hit yanks the victim to this many metres ...")
(defparameter *hs-kubi-yank-frames* 12 "... over this many frames (§17.2).")
(defparameter *hs-kubi-cut* 14 "On a hit KUBIKAKE's recovery is cut to this many frames from the hit (+16 on the 30 f reel, §17.2).")
(defparameter *hs-bind-reel* 30 "The opponent reels this many frames when the bind ends, either way (the user, 2026-10-17: 「捆綁結束時讓對手硬直 30f」).")
(defparameter *hs-pull-to* 2.0 "Bind L KOJO (HIKIYOSE until B4c) drags the opponent to this many metres ...")
(defparameter *hs-pull-speed* 60.0
  "... at this many m/s, motion only (never a hit) (18 -> 60, 2026-10-18, S1 §23.3: the drag starts at f20 now, so from 8 m
he arrives by f26, 4 f before the strike: the user's 「前 20 幀預備，拉到後 4 幀就打」) ...")
;; the bind's L 絞縄 KOJO and SP2 解縛擊 KAIBAKU-GEKI (B4c, §22.6; the user, 2026-10-18: 「絞縄改成給捆綁的 L，捆綁的 SP2 換成解除
;; 並附加傷害（有專屬動畫、可被防禦）」, 「絞縄本身帶拉近」, 「不冷卻，降低傷害並增加大前搖，通過降低優勢來控制出招動機」,
;; 「先還原再打，傷害 120（推薦）」; the numbers the lead's for that direction, 2026-10-18)
(defparameter *hs-kojo-s* 30
  "Bind L 絞縄 KOJO's startup (as the SP2 20 -> 30: 「增加大前搖」; the lead's number, 2026-10-18); no cooldown, no cost ...")
(defparameter *hs-kojo-r* 36 "... its recovery (30 -> 36: 「通過降低優勢來控制出招動機」: on hit 40 crumple - 40 = 0, neutral) ...")
(defparameter *hs-kojo-dmg* 83
  "... its damage (160 -> 70: 「降低傷害」; 70 -> 83, 2026-10-19, the user: 「把捆縛提高到沒有乘上近身倍率依舊能高於平均值 1.2 倍」:
with the yank's 20, 103 >= 1.2 x the awakened L mean 85.5, §25.13) ...")
(defparameter *hs-kojo-block* -24 "... its block advantage (-16 -> -24) ...")
(defparameter *hs-kojo-pull-at* 20
  "... and the frame its noose starts dragging the victim to *HS-PULL-TO* (「絞縄本身帶拉近」; the drag stops at S) (6 -> 20,
2026-10-18, the user: 「L 將對手拉近時，增加拉近對手前的動作識別度與前搖時間，並減少攻擊效果的前搖」, 「前 20 幀預備，拉到後 4 幀
就打（推薦）」, §23.2: f0-19 the tell, S 30 kept).")
(defparameter *hs-kojo-yank-dmg* 20
  "... and the noose's yank at *HS-KOJO-PULL-AT*: a hit of its own along the chain (HS-FOE-SEG, any distance in the bind,
blockable; a flinch, the drag goes on and the reap combos after it) for this damage (none -> 20, 2026-10-19, the user:
「卍解近距離 L 拉扯的那一下也算入傷害判定」, §25.7; the lead's number, the windmill push's) ...")
(defparameter *hs-kojo-yank-to* 22 "... its window ends at this frame (2 f; the reap's own window S 30-33 unchanged).")
(defparameter *hs-kaibaku-dmg* 120
  "Bind SP2 解縛擊 KAIBAKU-GEKI: the release at its S (the snapshot back, the pool to the opponent first), then its strike's
real damage (the user, 2026-10-18: 「先還原再打，傷害 120（推薦）」); no bars spent; blockable (blocked: the release, no damage).")

;;; ---------------------------------------------------------------- the two Bankai modes made distinct (§22.1, batch B4a)
;;; The user, 2026-10-18: 「目前近遠程的攻擊模組看不出各自的特色」 -> A (the ranged mode a placed zone game) + C (looks) + D
;;; (distance sweet spots) + 「遠程攻擊有效利用鎖鏈球拉動垂鏈迴轉對遠程進行抽打」; 「可以」 to the proposal (§22.1).
(defparameter *hs-r-dead* 2.0
  "The ranged mode's dead zone: every attack of it but L SAHARAI (and the universal Breaker) misses a victim nearer than
this (m, centre to centre: the moves' :min-reach) (none -> 2.0, 2026-10-18, the user, §22.1; B4c: K1 綁束 had none, the
user: 「身旁旋轉會打到」, §22.4; B4d: K1 has it again, 「讓 K1 只能打中遠方的敵人」, §22.8). The bind's SP1 KUSARI-AME has
none since B4d (「鎖雨改成近距離也打得中」).")
(defparameter *hs-r-tip* 0.5
  "The chain tip: a ranged-mode hit in the outer this many m of its volume (an arc / annulus: by his distance from the arc's
r; a line / lane: along it, from its far end) ... (none -> 1.0, 2026-10-18, the user, §22.1; HS-DIST-MULT; 1.0 -> 0.5,
2026-10-23, the user: 「幫我將鏈尖加成縮短至 0.5m」: J 5.5-6 m, K 4.5-5 m; 0.5 -> 0.75 the same day, §25.30: 「尖端距離改成
0.75m」: J 5.25-6 m, K 4.25-5 m; 0.75 -> 0.5, 2026-10-24, §25.35: 「尖端範圍及改成 0.5m J 範圍改回 3~6m K 範圍改 2.5~4.5m」: J 5.5-6 m, K 4.0-4.5 m) ...")
(defparameter *hs-r-tip-mult* 1.71
  "... deals x this, else x1.0 (x1.0 -> x1.3, 2026-10-18, the user, §22.1; 1.3 -> 1.71, 2026-10-19, the user: 「將遠距的鏈尖
加成提高到能讓 K 串傷害能到平均值的 1.3 倍」, 「共用 1.71」: K1 -> K2 -> K3G all on the tip 313, 1.3 x the 21 awakened forms'
K string mean 240.3, DUEL_HISAGI §25.13). A route link (links 2-3) takes its opener's (J1 / K1's) tip read, not its own
distance (§25.13: 「鏈尖判定會直接延續 J1 / K1 打中時的判斷狀態」; HSS-ROUTE-TIP) ...")
(defparameter *hs-r-tip-sp-mult* 1.3
  "... and the Reiatsu (SP) that hit earns him is x this on top (x1.0 -> x1.3, 2026-10-18, the user: 「卍解遠距的鎖鏈尾端除了
傷害加成以外也增加 SP 恢復量的加成」, §25.5; the lead's number, the damage's: with it x1.69 a non-tip hit's).")
(defparameter *hs-b-close* 1.2 "A bind-mode hit within this many m (centre to centre) ...")
(defparameter *hs-b-close-mult* 1.3
  "... deals x this, else x1.0 (x1.0 -> x1.2, 2026-10-18, the user, §22.1; 1.2 -> 1.3, 2026-10-19, the user: 「近身加成升到
1.3 倍」, §25.13).")
(defparameter *hs-bind-drain-rate* (/ 1.0 3)
  "The bind's pool loses this much per nominal damage of either fighter (rules BIND-DRAIN's rate; 0.5 -> 0.25, 2026-10-19,
the user: 「延長近身的時長（SP 與血量互換從 1:2 改成 1:3）」 then 「1:4」, §25.13; 0.25 -> 1/3 the same day: 「捆綁模式的 SP 血量
互換率還是改成 1:3 好了」, §25.13); an SP still spends it 1:1.")
(defparameter *hs-r-j-dead* 3.0
  "The ranged mode's J (J1 / J2 / J3, the gathered J2s / J3G) dead zone, m (the moves' :min-reach): an annulus out to
*HS-R-J-REACH* (J1's 2.0 -> 3.0 and the other links' *HS-R-DEAD* 2.0 -> 3.0, 2026-10-18, the user: 「J 的範圍改 3~6」, §25.3;
J1's own since S1, 「J1 範圍設 3.0–5 m」, §23.3; 3.0 -> 4.0, 2026-10-23, the user: 「J 的攻擊範圍修改成 4~7 m，K 的攻擊範圍修改成 2.5~5.5 m」, §25.34; back to 3.0,
2026-10-24, §25.35) ...")
(defparameter *hs-r-j-reach* 6.0
  "... and its far edge, m (an arc's r, a line's end + its r) (J1 / J3 / J3G 5.0, J2 4.5, J2s 5.5 -> 6.0, the same; the tip
x1.3 on 5.0-6.0; x1.71 on 5.5-6.0 since §25.26, 5.25-6.0 since §25.30; 6.0 -> 7.0, §25.34: the tip 6.25-7.0; back to 6.0, §25.35: the
tip 5.5-6.0).")
(defparameter *hs-r-k-dead* 2.5
  "The ranged mode's K (K1, the spread K2s / K3, the gathered K2 / K3G) dead zone, m: an annulus out to *HS-R-K-REACH*
(*HS-R-DEAD* 2.0 -> 1.0, 2026-10-18, the user: 「K 的範圍改 1~4」, §25.3; 1.0 -> 2.0, the same day: 「卍解遠距 K 改成 2~5 m」,
§25.5; 2.0 -> 2.5, 2026-10-23, §25.34) ...")
(defparameter *hs-r-k-reach* 4.5
  "... and its far edge, m (K1 4.0, K2s / K3 / K3G 6.0, K2 8.5 -> 4.0, §25.3; 4.0 -> 5.0, §25.5; the tip x1.3 on 4.0-5.0; x1.71 on 4.5-5.0
since §25.26, 4.25-5.0 since §25.30; 5.0 -> 5.5, §25.34: the tip 4.75-5.5; 5.5 -> 4.5, 2026-10-24, §25.35: the tip 4.0-4.5).")
(defparameter *hs-r-link-reach* 7.0
  "The ranged route links (links 2-3: J2 / K2s / J3 / K3, K2 / J2s / K3G / J3G) strike the victim where he is, along the
chain (HS-R-LINK-SEG: no dead zone), out to this many m from his feet (+ the victim's body); farther, they miss. They
replace the 3.5 m placement of J1 / J2 / K1 / K2's slam (B4a's push, §22.1; a placement since §25.3; gone 2026-10-19, the
user: 「拿掉定位，改成後續接上的 J / K 會自動調整判定範圍」, 「7.0 m 可以」, DUEL_HISAGI §25.13).")
(defparameter *hs-r-j3-push* 6.6 "J3 旋鎖's ender push: to this many m (J1's 4.5 + body + 0.05 = 4.91 -> 5.5, 2026-10-18, the user, §22.1;
5.5 -> 6.6, 2026-10-18, §25.3: out of J1's 6.0 + a body 0.45 + 0.05 again, the lead's number from the same rule; 6.6 -> 7.55,
2026-10-23, §25.34: out of J1's 7.0 by the same rule, + the ender push's 0.05 the host checks; back to 6.6 with J1's 6.0,
§25.35).")
;;; ---------------------------------------------------------------- the ranged strings by route (§22.4, batch B4c)
;;; The user, 2026-10-18: 「K1 將垂降的鎖鏈在身旁旋轉並捆成一束 ... J1 接續的 K2 K3 則會更採用散開的鎖鏈發動攻擊 / 散開的鎖鏈攻擊更快，
;;; 聚合的鎖鏈攻擊更痛」; 「身旁旋轉會打到」, 「拿掉落點」 (B4a's placed marks gone), 「散 −3 幀×0.85／聚 +3 幀×1.3」, 「可以」 to
;;; the segment table (§22.4). The opener decides the route of links 2-3: J1-opened = spread (the thin hanging chains),
;;; K1-opened = gathered (K1 binds them into one bundle). The moves carry the numbers (host-pinned against these).
(defparameter *hs-r-spread-s* -3
  "A spread link's (J1-opened: J2, K2s, J3, K3) startup vs its base move's (B4a's J S 13, the K S 24) (none -> -3, the user,
2026-10-18: 「散 −3 幀×0.85」, §22.4) ...")
(defparameter *hs-r-spread-mult* 0.85 "... and its damage x (rounded) (none -> x0.85, the user, 2026-10-18).")
(defparameter *hs-r-gather-s* 3
  "A gathered link's (K1-opened: K2, J2s, K3, J3) startup vs its base move's (none -> +3, the user, 2026-10-18:
「聚 +3 幀×1.3」, §22.4) ...")
(defparameter *hs-r-gather-mult* 1.3 "... and its damage x (rounded; K2's 57 split 25 + 32) (none -> x1.3, the user, 2026-10-18).")
(defparameter *hs-r-spread-sp-mult* 1.3
  "The spread route's hits (J1 and its links J2 / K2s / J3 / K3) earn their Reiatsu (SP) gain x this, on top of the tip's
x1.3 (x1.69 a tip hit of the route) (none -> x1.3, 2026-10-19, the user: 「幫我把遠距 J1 起手的散路線再增加額外的 SP 回收量」,
「×1.3」, 「起手也加」, DUEL_HISAGI §25.11; HS-DMG-MULT marks, HS-BK-HIT pays).")
(defparameter *hs-r-gather-guard-mult* 1.3
  "The gathered route's guard damage (K1 and its links K2 / J2s / K3G / J3G): their :guard x this, rounded, written into the
moves (none -> x1.3, 2026-10-19, the user: 「K1 起手的聚路線增加削防值」, 「×1.3」, 「起手也加」, §25.11: K1 / K2 14 -> 18,
J2s 8 -> 10, K3G 18 -> 23, J3G 12 -> 16; host-pinned against these).")
(defparameter *hs-r-k2-launch-kb* 0.5
  "Gathered K2's tail (its launch) :kb: the airborne slide x0.6 = 0.3 m, so the victim (placed at 3.5 m until §25.13; the
links reach him anywhere inside *HS-R-LINK-REACH* since) lands his K3G (1-4 m) and J3G (3-6 m) still (none: the generic 1.0 m -> 0.5, 2026-10-18, §25.3: the K 1-4 m, the lead's number; K 2-5 since §25.5).")
;;; ================================================================ the Shikai 風死 (§8.2, §8.3)
;;; J: the chain held short, one sickle whirled round the body (H1: 1.4 m, 110°, J3 200°, Q5 A). The one-handed copies
;;; (the OUT graph, KJJ) are the same clips at x0.8 written in, :params :one-hand (the empty-hand look).
(defparameter *hs-j-reach* 1.7
  "The Shikai's J1 / J2 / J3 reach, m (the J floor *J-REACH-MIN*'s 1.4 -> 1.7, 2026-10-19, the user: 「然後幫我把始解的 J 範圍稍微
加長」, the lead's number, §25.9; the leaps J2K / J3K are their copies; the sickles let out on their chains to it).")
(defmove :hs-j1 :kind :quick :clip :hs-na1 :clip-s 14 :startup 14 :active 3 :recovery 12 :dmg 30 :adv-block -2 :guard 8
  :reach *hs-j-reach* :arc 110 :on-hit :flinch :slide 0.3)                ; 旋 SEN
(defmove :hs-j2 :kind :quick :clip :hs-q2 :startup 8 :active 3 :recovery 13 :dmg 30 :adv-block -2 :guard 8
  :reach *hs-j-reach* :arc 110 :on-hit :flinch)                           ; 返旋 KAESHI-SEN
(defmove :hs-j3 :kind :quick :clip :hs-spin :startup 9 :active 3 :recovery 18 :dmg 38 :adv-block -4 :guard 12
  :reach *hs-j-reach* :arc 200 :on-hit :stagger :flags (:ender))          ; 輪 RIN, the full spin
(defmove-copy :hs-j1-1h :hs-j1 :dmg 24 :params (:one-hand t))             ; SEN-1H (the OUT graph's J1)
(defmove-copy :hs-j2-1h :hs-j2 :dmg 24 :params (:one-hand t) :clip :hs-s-kaeshi-1h)   ; KAESHI-SEN-1H (the IN graph's J2s,
                                                                          ;  the OUT J2: the reversed backhand, §21.4)
(defmove-copy :hs-j3-1h :hs-j3 :dmg 30 :params (:one-hand t) :clip :hs-s-rin-1h)         ; RIN-1H (the arm-length pivot)
;; K (S1, §23.2-§23.3; the user, 2026-10-18: 「K 串改成純遠距離，近距離打不中，K1 是鎖鏈拉動鐮刀橫向遠程揮擊，K2 是鐮刀快速旋轉變成
;; 像圓鋸一樣豎直向前切割後被鎖鍊上拉，K3 將飛上天空的鐮刀用力下扯墜擊。K2, K3 的攻擊距離會按照對手的位置決定，所以一定打的中」,
;; 「系統的設計邏輯本來就是 J1, K1 打中才能接後續攻擊」, 「2.0 m（推薦）」): the chain, pure range. K1 薙 NAGI swings the sickle
;; sideways on its chain: an arc *HS-K1-ARC* wide out to 6.0 m with a *HS-K-DEAD* dead zone (:min-reach), turning 30 deg/s
;; in its startup, no generic close-in; the windmill's charge scales its reach (HS-SCALED). K2 鋸 NOKO (the spinning saw,
;; hauled up: a stagger) and K3 墜 TSUI (flung up, yanked down: the ender) follow a hit or a block (S2, §23.5: 「被防禦後也
;; 能繼續接連段」; S1's :hit-only gone) and strike along the chain from his hand to the victim wherever he is (:seg-fn
;; HS-FOE-SEG: they always connect, blockable; no dead zone: J1 -> K2 at J range). No move leaves the sickle out any more: the OUT / RETURNING states, the OUT graph
;; (SEN-1H, MODOSHI), MAKI and HODOKI below are dormant (§23.3). Their own clips since A1 (§24.1, a look): K1 the sweep,
;; K2 the saw, K3 the plunge (hisagi-art.lisp; K2 / K3 drawn on the victim, *HS-FOE-PATHS*)
(defmove :hs-k1 :kind :flash :clip :hs-s-nagi :startup 18 :active 4 :recovery 22 :dmg 62 :adv-block -3 :guard 14
  :reach 6.0 :arc *hs-k1-arc* :height (0.2 2.0) :min-reach *hs-k-dead* :track 30.0 :on-hit :stagger
  :flags (:ranged :no-close) :params (:melee-range 2.0))                  ; 薙 NAGI
(defmove :hs-k2 :kind :flash :clip :hs-s-noko :enter 6 :startup 20 :active 4 :recovery 24 :dmg 56 :adv-block -3 :guard 14
  :reach 6.0 :on-hit :stagger :flags (:ranged) :hits ((20 24 :seg-fn hs-foe-seg)) :params (:melee-range 2.0))   ; 鋸 NOKO
;; MAKI (K2s after J1, Q8 A): the chain flung round his body (a 3.2 m line), the sickle OUT, anchored on him
(defmove :hs-k2s :kind :flash :clip :hs-maki :enter 6 :startup 20 :active 4 :recovery 24 :dmg 52 :adv-block -3 :guard 14
  :vol (:cap 0.3 3.2 1.1 0.35) :on-hit :stagger :on-frame ((20 hs-throw-out)) :params (:throw 3.2))   ; 巻 MAKI
;; K3 墜 TSUI after NOKO or KAESHI-SEN (above); its push ~6.45 m (the kit's :push-reach, Q6 B: out of a restarted K1's 6.0)
(defmove :hs-k3 :kind :flash :clip :hs-s-tsui :enter 8 :startup 22 :active 5 :recovery 34 :dmg 80 :adv-block -20 :guard 18
  :reach 6.0 :on-hit :crumple :flags (:ender :ranged) :hits ((22 27 :seg-fn hs-foe-seg))
  :params (:melee-range 2.0))                                             ; 墜 TSUI
;; S2 (§23.5): the cross link J1 -> K2 its own copy (K2J: no J after it, the grid's one switch: no JKJ), so K1 -> K2 can go
;; on with J (KKJ); and the J links after a K (KJJ's J2K, KKJ's J3K: the leap, HS-LEAP-TICK; their own clips since A1,
;; §24.1: the crouch, the leap and J2's / J3's strike on landing, authored at S 14)
(defmove-copy :hs-k2j :hs-k2)
(defmove-copy :hs-j2k :hs-j2 :startup *hs-leap-s* :clip :hs-s-tobi-kaeshi :adv-block *hs-leap-block* :tick hs-leap-tick)
(defmove-copy :hs-j3k :hs-j3 :startup *hs-leap-s* :clip :hs-s-tobi-rin :adv-block *hs-leap-block* :tick hs-leap-tick)
(defparameter *hs-leaps* '(:hs-j2k :hs-j3k) "The leap J copies (S2, §23.5): one a combo since §24.4 (HS-LINK-OK).")
;; (dormant since S1, §23.3: HODOKI, MAKI's K3, the OUT graph's MODOSHI)
(defmove :hs-k3h :kind :flash :clip :hs-hodoki :enter 8 :startup 22 :active 5 :recovery 34 :dmg 78 :adv-block -20 :guard 18
  :reach 3.2 :on-hit :crumple :flags (:ender) :on-frame ((22 hs-sickle-in))
  :hits ((22 27 :seg-fn hs-chain-seg)))                                   ; 解 HODOKI
;; MODOSHI (K while the sickle is out): the retrieve, no hit window, IN at f6; not a string link
(defmove :hs-modoshi :kind :flash :clip :hs-modoshi :startup 6 :active 0 :recovery 6 :on-frame ((6 hs-sickle-in)))   ; 戻
;; L 風車 KAZAGURUMA, the windmill (§8.3, Q3 A): up at f6, held 20-60 f (HS-KAZA-TICK), R 14; one push hit as it comes up
;; (20, 1.5 m, 8 f: no lock), 360 deg r 2.0; while it runs, hazards and :ranged windows are guarded from every side
;; (:ranged-ward: their full guard value, the usual chip, no blockstun; unguardables through; a crush drops it). Rooted,
;; free; refused while the sickle is out (HS-OK). S1 (§23.1): no cooldown; L held from its up frame charges the next K
;; string (HS-CHARGE-NEXT), K from f9 starts it (HS-KAZA-TICK)
(defmove :hs-kaza :kind :sig :clip :hs-kaza :startup 6 :active 60 :recovery 14 :whiff 14 :cooldown *hs-kaza-cooldown* :dmg 20
  :vol (:arc 2.0 360 0.2 2.0) :on-hit :flinch :kb 1.5 :hits ((6 9 :stun 8)) :tick hs-kaza-tick :flags (:ranged-ward)
  :on-frame ((0 hs-kaza-start) (6 hs-kaza-up)))
;; ... the bridge (the kit's :l-after-j, S1): the same windmill off a J1 / J2 / J3 link, its push a stagger (26 f) so a K
;; pressed by f14 (charge <= 9 frames) combos into K1; a longer charge trades the combo for reach (§23.1)
(defmove-copy :hs-kaza-j :hs-kaza :on-hit :stagger :kb *hs-bridge-kb* :hits ((6 9)))
(defparameter *hs-kazas* '(:hs-kaza :hs-kaza-j) "The windmill and its J bridge copy (S1).")
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
;; ================================================================ the core system's Shikai (DUEL_HISAGI §26; the user, 2026-10-28:
;; 「幫我用新系統的邏輯重製修兵」; pointers 1 投 the throw, 2 首掛 the bind, 3 綴雷電 the lightning; the chain a long melee volume the
;; triangle judges: 「當作很長的近戰判定」). Copies of his Shikai moves with their clips (redrawn after the playtest); a link segment
;; keeps its source's :enter (its startup counted from there: NOKO's 20 - 6 = 14) and strikes along the chain to the victim within
;; *HS-CORE-CHAIN* (HS-CORE-SEG); :look-as names the old move whose look it borrows (HS-LOOK-NAME). Only a route's last segment
;; knocks down or launches.
(defparameter *hs-core-chain* 6.5
  "The chain's length under the core system (m): a link segment strikes the victim within it (HS-CORE-SEG), the SA drags him from
within it (HS-YOSE) (the lead's default, 2026-10-28, DUEL_HISAGI §26.1: a whiffed opener's next segment reaches, not across the stage).")
(defparameter *hs-yose-to* 1.6 "The SA 引寄 YOSE drags the opponent to this distance on its frame 0 (m; §26.2).")
;; §27 (the user, 2026-10-28: 「縛雷放 3」「J 與所有 NS/AS 都 +8」「留下餘電」; the numbers the lead's draft, §27.2)
(defparameter *hs-zan-frames* 480 "餘電 ZANDEN's length (frames): set by AS3's last hit, or by NS3's CHIKUDEN with no 放電 after it.")
(defparameter *hs-zan-bonus* 8 "餘電: added to each of his J / NS / AS hits while it lasts (HS-CORE-DMG-MULT).")
(defparameter *hs-zan-hoden* 1.6 "餘電: the next 放電 HODEN x this, and it is used up.")
(defparameter *hs-hoden-near* 1.6 "放電: at or inside this distance (m) its damage x *HS-HODEN-NEAR-X*; x1.0 at *HS-CORE-CHAIN*, linear between.")
(defparameter *hs-hoden-near-x* 2.0 "放電's damage x up close (§27.2: 「距離越近傷害越高」).")
;; NA: five J (J1 SEN's coil S 14 > KAESHI-SEN > SEN > KAESHI-SEN > RIN); an AS after J1-2 is AS1, J3-4 AS2, J5 AS3
(defmove-copy :hs-na3 :hs-j1 :clip :hs-q1 :startup 8 :clip-s 8)   ; (J1's cut without the coil)
(defmove-copy :hs-na4 :hs-j2)
;; pointer 1 投: NAGI's 6 m sweep > HIKI, the sickle back into him > USHIRO-NAGI, the backward swing (198); AS1 KAGI-BIKI hooks
;; him and drags him in, stealing flash step
(defmove-copy :hs-n1c :hs-k3 :callout "USHIRO-NAGI" :startup 24 :clip-s 22 :on-hit :knockdown :flags nil
  :hits ((24 29 :seg-fn hs-core-seg)) :params (:melee-range 2.0 :look-as :hs-k3))
(defmove-copy :hs-n1b :hs-k2 :hits ((20 24 :seg-fn hs-core-seg)) :params (:melee-range 2.0 :ns-next :hs-n1c :look-as :hs-k2))
(defmove-copy :hs-n1a :hs-k1 :startup 20 :clip-s 18 :params (:melee-range 2.0 :ns-next :hs-n1b))
(defmove-copy :hs-as1 :hs-k3 :kind :sp :callout "KAGI-BIKI" :startup 24 :clip-s 22 :dmg 50 :on-hit :knockdown :flags nil
  :on-land hs-kagi-pull :hits ((24 29 :seg-fn hs-core-seg)) :params (:melee-range 2.0 :steal-fs 40 :pull 1.6 :look-as :hs-k3))
;; pointer 2 刈 KARI (§27.3, 「刈 短鎖貼身收割」: the chain wound short, 1-2.5 m): TAN-GARI's stepping cross cut > REN-GARI > SEN-GARI's
;; spin, the chain let out to a 3 m circle (180); AS2 KO-GARI > KARI-AGE, the rising reap (the launch). Their own clips since
;; batch 2 (§27.5, presentation only), each authored at its S: hisagi-art.lisp :hs-kr-*
(defmove-copy :hs-n2c :hs-j3 :kind :flash :clip :hs-kr-sen :callout "SEN-GARI" :startup 16 :clip-s 16 :dmg 85 :reach 3.0 :arc 360 :on-hit :knockdown
  :flags nil)
(defmove-copy :hs-n2b :hs-j1 :kind :flash :clip :hs-kr-ren :callout "REN-GARI" :startup 12 :clip-s 12 :dmg 50 :on-hit :stagger
  :slide 0.0 :params (:ns-next :hs-n2c))
(defmove-copy :hs-n2a :hs-j2 :kind :flash :clip :hs-kr-tan :callout "TAN-GARI" :startup 16 :clip-s 16 :dmg 45 :reach 2.5 :slide 1.0 :on-hit :stagger
  :params (:ns-next :hs-n2b))
(defmove-copy :hs-as2b :hs-j3 :kind :sp :clip :hs-kr-age :clip-s 9 :callout "KARI-AGE" :dmg 60 :reach 2.4 :on-hit :launch :flags nil)
(defmove-copy :hs-as2 :hs-j2 :kind :sp :clip :hs-kr-ko :clip-s 8 :callout "KO-GARI" :dmg 45 :reach 2.4 :slide 1.4 :on-hit :stagger
  :params (:ns-next :hs-as2b))
;; pointer 3 縛雷 (§27, the bind and the lightning merged): SHIBARI's cast binds (its gap's SA 引寄 drags him in) > CHIKUDEN, the
;; charge along the binding chain (its gap's SA 放電 HODEN bursts him in place, closer = harder); no third segment. AS3 MATOI >
;; TAME > TSUZURI RAIDEN, which leaves 餘電 ZANDEN on him (HS-ZAN-HIT)
(defmove-copy :hs-n3b :hs-k2 :callout "CHIKUDEN" :dmg 25 :on-hit :stagger :hits ((20 24 :seg-fn hs-core-seg))
  :params (:melee-range 2.0 :sa :hs-sa-hoden :zan :pend :look-as :hs-k2))
(defmove-copy :hs-n3a :hs-shibari :kind :flash :callout nil :startup 18 :active 4 :recovery 26 :clip-s 16 :dmg 40
  :hits ((18 22 :on-hit :bind :stun 40)) :params (:melee-range 2.0 :ns-next :hs-n3b :look-as :hs-shibari))
(defmove-copy :hs-sa-hoden :hs-raiden :kind :quick :callout "HODEN" :startup 10 :clip-s 20 :dmg 60 :on-hit :stagger :flags nil
  :hits ((10 13 :seg-fn hs-core-seg)) :on-frame nil :params (:melee-range 2.0 :hoden t))
(defmove-copy :hs-as3c :hs-raiden :startup 16 :clip-s 20 :dmg 110 :on-hit :knockdown :hits ((16 19)) :on-frame nil
  :params (:melee-range 2.0 :zan :set))
(defmove-copy :hs-as3b :hs-k2 :kind :sp :callout "TAME" :dmg 35 :hits ((20 24 :seg-fn hs-core-seg))
  :params (:melee-range 2.0 :ns-next :hs-as3c :look-as :hs-k2))
(defmove-copy :hs-as3 :hs-j3 :kind :sp :callout "MATOI" :dmg 45 :on-hit :stagger :flags nil :reach 2.4 :slide 1.4
  :params (:ns-next :hs-as3b))
;; the SA 引寄 YOSE (「鎖鏈把對手拉過來再斬」): frame 0 the chain drags him to *HS-YOSE-TO*, then one cut; J2 goes on
(defmove-copy :hs-sa :hs-j1 :clip :hs-q1 :dmg 40 :reach 2.4 :slide 1.4 :startup 10 :clip-s 8 :on-hit :stagger :on-frame ((0 hs-yose))
  :params (:pull 1.6))

;; I: the universal Breaker, drawn as 首掛け KUBIKAKE (ch. 337 / 384); allowed while out
(defmove :hs-breaker :kind :breaker :clip :hs-breaker :clip-2 :hs-kubikake :callout "KUBIKAKE")
;; O, the Kikon module 刈 KARI: aura 6 (aim 120 deg/s), no dash, the strike along a 7 m lane locked (the sickle hooks him);
;; the follow-up's generic dash drawn as a zip along the chain; cooldown 90; allowed while out
(defmove :hs-kikon :kind :kikon :clip :hs-kari-aim :clip-2 :hs-kari-o :callout "KARE, KAZESHINI" :cine hs-kare-cine
  :startup 20 :active 2 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 7.0 1.2 1.0)
  :on-hit :knockback :kb 2.0 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 0.0 :dash-max 0 :ender-dash 0 :dash-track 0.0 :look :lane :follow-speed 14.0))

(defparameter *hs-throws* '(:hs-k2s) "The moves that throw the sickle (OUT at S; their :params :throw = the line's length;
since S1 only the dormant MAKI, §23.3).")
(defparameter *hs-pulls* '(:hs-k2 :hs-k2j :hs-k3 :hs-k3h)
  "The chain strikes drawn from the anchor (HODOKI's HS-CHAIN-SEG, dormant; S1's K2 / K3 along HS-FOE-SEG, the anchor kept
on the victim for the look: HS-TICK).")
(defparameter *hs-at-foe* '(:hs-k2 :hs-k2j :hs-k3) "S1: the K links placed on the victim (HS-FOE-SEG; S2: K2J).")
;; S1 (§23.1): the K string a windmill feeds plays its moves at the charge's reach: each a copy parsed at x (1 + n / 100)
;; (PARSE-MOVE's :reach-mult: NAGE's line and its anchor :throw, HIKI's :reach (its chain is the anchor's), KARI-OTOSHI's
;; arc), the same name, so the strings, the hooks and the CPU see the move they know; HS-TICK swaps it in
;; (§23.2: the charge scales K1 only; K2 / K3 follow the victim anyway)
(defparameter *hs-k-string* '(:hs-k1 :hs-k2 :hs-k3) "The K string (K1 NAGI -> K2 NOKO -> K3 TSUI) a windmill starts.")
(defun hs-charge-scale (n) "The reach x of a charge of N frames (*HS-CHARGE-STEP* each, capped)." (+ 1.0 (* *hs-charge-step* (min n *hs-charge-max*))))
(defparameter *hs-k1-scaled*
  (let ((mv (find-move :hs-k1)))
    (coerce (loop for n from 0 to *hs-charge-max*
                  collect (if (zerop n) mv (parse-move :hs-k1 (mv-spec mv) :reach-mult (hs-charge-scale n))))
            'simple-vector))
  "K1 NAGI's copies by charge frames 0-60 (0: the move itself; its arc's r x the charge, the dead zone kept).")
(defun hs-scaled (name n)
  "K string move NAME at a charge of N frames: K1's copy; K2 / K3 themselves (they follow the victim)."
  (if (eq name :hs-k1) (svref *hs-k1-scaled* (min n *hs-charge-max*)) (find-move name)))
(defun hs-scaled-tip (drawn line n)
  "A drawn strike's reach DRAWN (m, at x1) at a charge of N: its volume's LINE (a cap's end, an arc's r) grows, its radius
not (the art's %HS-FA-KS! / %HS-LETOUT!, host-tested against the copies)."
  (+ drawn (* line (- (hs-charge-scale n) 1.0))))
(defparameter *hs-hooks* '(:tick hs-tick :ok hs-ok :command hs-command :hit hs-hit :struck hs-struck :reset hs-reset
                           :hash hs-hash :draw hisagi-draw :pose hs-pose :deck hs-deck :link-ok hs-link-ok :boss hs-boss
                           :dmg-mult hs-core-dmg-mult))
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
  :core (:ns (:hs-n1a :hs-n2a :hs-n3a) :as (:hs-as1 :hs-as2 :hs-as3) :sa :hs-sa
         :stances (:hs-s-stance :hs-st-kari :hs-st-raiden)       ; by pointer: the reveal / 刈's wound chain (§27.5) / the taut chain
         :kikon-cines (hs-kare-cine hs-kubikake-cine hs-raiden-cine)   ; 刈れ / (首掛 until 刈's, §27.3) / 綴雷電 (§26.6)
         :as-by-press (1 1 2 2 3)
         :ns-range ((3.6 6.2) nil nil)                           ; the CPU throws NAGI from 3.6-6.2 m under pointer 1
         :no-awaken t :mult 1.7)                                 ; (the Bankai: its own design round, §26.1)
  ;; S2 (§23.5): the grid's six routes JJJ JJK JKK KKK KJJ KKJ (one switch at most): the J string close (every link
  ;; combos), the K string the chain at range; K2 NOKO / K3 TSUI follow the victim (after J1 / J2 too: the cross links, K2J
  ;; J1's own copy); a J after a K leaps in (J2K, J3K; then J2K's J3 the plain one); then the OUT graph's J string (dormant:
  ;; no move leaves the sickle out since S1)
  :strings ((:hs-j1 :q :hs-j2) (:hs-j1 :f :hs-k2j) (:hs-k1 :f :hs-k2) (:hs-k1 :q :hs-j2k)
            (:hs-j2 :q :hs-na3) (:hs-na3 :q :hs-na4) (:hs-na4 :q :hs-j3)   ; (five J since §26: J2 > J3 > J4 > RIN)
            (:hs-j2 :f :hs-k3) (:hs-k2 :f :hs-k3) (:hs-k2 :q :hs-j3k)
            (:hs-j2k :q :hs-j3) (:hs-k2j :f :hs-k3)
            (:hs-j1-1h :q :hs-j2-1h) (:hs-j2-1h :q :hs-j3-1h))
  :awaken-form :bankai                          ; the Bankai's ranged mode (§17.1; batch B2b)
  :l-after-j :hs-kaza-j                         ; L off a J1 / J2 / J3 link: the windmill bridge (S1, §23.1)
  :hooks *hs-hooks*
  ;; an all-rounder at 2-6 m (§6): the throw at 3.5-6.2 m, J strings up close, the windmill against projectiles (his
  ;; :reflex), SP2 / the Breaker at mid range
  :ai (:intents (:approach 2 :pressure 2 :zone 3 :defend 1)
       :ranges (:approach (3.0 5.5) :pressure (1.2 2.2) :zone (3.5 6.0) :defend (4.0 6.0))
       ;; (cell b0a0: SHIBARI only as an ender (its neutral whiffs fed the counters), K1 rarer from neutral (its 18 f
       ;; startup is Hoho'd: HS-AI-REFLEX's punish K1 instead), the windmill's charge at K range too)
       :moves ((0.0 2.0 :q 5)                          ; (S1: K1 has a 2.0 m dead zone, §23.3; 3.0 since §24.4)
               (2.0 3.0 :step 1 nil 2)
               (3.0 3.5 :f 1 :step 1 nil 2)
               (3.5 6.2 :f 2 nil 3)     ; (cell b3a0: no neutral windmill: its charge stood still in his reach, punished
               (6.2 9.0 nil 3)          ; by every rushdown and zoner: HARD 0.37 -> 0.39-0.44; the bridge and the ward keep it)
               (9.0 99.0 nil 2))
       ;; (cell b0a0 on §25.15 tried :hoho 0.3 -> 0.15, its counter being plain damage (1.4 -> 0.8 % of his at HARD): the
       ;; key is every difficulty's, and NORMAL's never-awaken HK / HB A/B rows fell to 14-18 / 12-16 of 60; 0.3 kept)
       :guard 0.35 :neutral-guard 0.1 :hoho 0.3 :dash 0.25 :dash-back 0.3 :block-string 0.25 :sp-cancel-bars 1 :string-k *hs-ai-string-k*
       :l-after-j *hs-ai-l-after-j* :awaken *hs-ai-awaken*
       :kikon-range 0.0 :o-ender 0.0 :reflex hs-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-ai-ender :sig-hold hs-ai-sig-hold
       :move-reflex hs-ai-move))                ; (S2: KJJ / KKJ, the leap, §23.5)

;;; ================================================================ the Bankai 風死絞縄 (§17; batch B2b)
;;; Two modes, each a kit form: :bankai the ranged mode (the default after the awakening; prefix hs-r-), :bankai-bind the
;;; bind mode (prefix hs-b-). The switch between them is a SET-FORM made by HS-BK-TICK only out of a move (after
;;; KUBIKAKE's cut recovery on entry, on UNWIND's last frame on either end). The look (§21.6) and every move's own clip
;;; (§21.8, batch B3b: the approved slot plan, exaggerated windups inside the startups; hisagi-art.lisp :hs-k- / :hs-kb-)
;;; are presentation only: the drawn strike (a crescent on its hand chain, a hanging chain, the neck bundle, the orb's
;;; chains) at each volume's edge on its hit frames.
;;;
;;; The ranged mode (§17.1, the user: 「由鎖鏈球設計與揮打鎖鏈為攻擊主體，此時前搖大、攻擊距離長， L 會將人推開」). Beyond
;;; 2.0 m every hit is :ranged (the chain, not the blade). J = chains swung from his hands, K / SP / O = from the orb.
;; B4a (§22.1-§22.2): J 旋鞭 / 旋鎖, an annulus (*HS-R-DEAD* .. the arc's r: the moves' :min-reach); J3's hit pushes him to
;; *HS-R-J3-PUSH* (J1 / J2's placement gone since §25.13: the links reach him where he is, *HS-R-LINK-REACH*). B4c (§22.4, §22.6): the opener decides the route of links 2-3 (the
;; ranged kit's :strings): J1 -> spread (J2, K2s, then J3 / K3: the base S *HS-R-SPREAD-S*, damage x *HS-R-SPREAD-MULT*),
;; K1 綁束 -> gathered (K2, J2s, then K3G / J3G: *HS-R-GATHER-S*, x *HS-R-GATHER-MULT*). The openers keep the dead zone;
;; the links have none since §25.13. The clips are B3b's, played to the new startups (:clip-s); the route links B3b had no clip for are drawn as their
;; own clips by the art pass's batch A2 (DUEL_HISAGI §24.2: hisagi-art.lisp, :clip-s their S)
(defmove :hs-r-j1 :kind :quick :clip :hs-k-saben :clip-s 12 :startup 14 :active 3 :recovery 12 :dmg 22 :adv-block -2 :guard 8
  :reach *hs-r-j-reach* :arc 100 :on-hit :flinch :hits ((14 17 :stun 24)) :flags (:ranged :no-close) :params (:melee-range 2.0)
  :min-reach *hs-r-j-dead*)                                                                                      ; 旋鞭 SENBEN
;; K1 綁束 HOSOKU (the gathered opener): the hanging chains spun round him and bound into one bundle; the spin hits all
;; round, no close-in; the base K1's A / R / guard / block (§17.1). B4d (§22.8, the user 2026-10-18: 「讓 K1 只能打中遠方的
;; 敵人」): the dead zone back and farther, an annulus 2.0-4.0 m (r 3.0 -> 4.0, no dead zone -> *HS-R-DEAD*); the tip x1.3
;; on its outer 1.0 m (3.0-4.0)
(defmove :hs-r-k1 :kind :flash :clip :hs-k-hosoku :clip-s 16 :startup 16 :active 4 :recovery 22 :dmg 40 :adv-block -3 :guard 18
  :vol (:arc *hs-r-k-reach* 360 0.2 2.0) :on-hit :stagger :flags (:ranged :no-close) :params (:melee-range 2.0)
  :min-reach *hs-r-k-dead*)                                                                                      ; 綁束 HOSOKU
;; spread (J1 ->): the thin hanging chains. J2 the other side's curtain (B4a's J2), K2s a fan of chains whipping the ground,
;; J3 the full turn (B4a's J3), K3 every chain lashed forward at once
(defmove :hs-r-j2 :kind :quick :clip :hs-k-kaeshi :clip-s 11 :startup 10 :active 3 :recovery 13 :dmg 19 :adv-block -2 :guard 8
  :reach *hs-r-link-reach* :on-hit :flinch :hits ((10 13 :stun 24 :seg-fn hs-r-link-seg)) :flags (:ranged)
  :params (:melee-range 2.0))                                                                                  ; 旋鞭 (back)
(defmove :hs-r-k2s :kind :flash :clip :hs-k-s-k2 :clip-s 21 :enter 6 :startup 21 :active 4 :recovery 24 :dmg 37 :adv-block -3
  :guard 14 :reach *hs-r-link-reach* :on-hit :stagger :hits ((21 25 :seg-fn hs-r-link-seg)) :flags (:ranged)
  :params (:melee-range 2.0))                                                                                  ; 散鞭
(defmove :hs-r-j3 :kind :quick :clip :hs-k-sensa :clip-s 13 :startup 10 :active 3 :recovery 18 :dmg 26 :adv-block -4 :guard 12
  :reach *hs-r-link-reach* :on-hit :stagger :hits ((10 13 :seg-fn hs-r-link-seg)) :flags (:ender :ranged)
  :params (:melee-range 2.0) :on-land hs-r-j3-push)                                                            ; 旋鎖 SENSA
(defmove :hs-r-k3 :kind :flash :clip :hs-k-s-k3 :clip-s 21 :enter 6 :startup 21 :active 5 :recovery 34 :dmg 56 :adv-block -20
  :guard 18 :reach *hs-r-link-reach* :on-hit :crumple :hits ((21 26 :seg-fn hs-r-link-seg)) :flags (:ender :ranged)
  :params (:melee-range 2.0))                                                                                  ; 散撃
;; gathered (K1 ->): the bundle. K2 the U -> L (the bundle arcs over and slams onto him, a stagger; then its tail lashes on
;; along the ground and knocks him off his feet: a launch, so the K3 / J3 after it still combo; the bundle left lying ahead
;; is the art's), J2s a straight lash, K3G the lying bundle hauled into a 360 deg spin, J3G a flat sweep. §25.13: every
;; route link strikes him where he is (HS-R-LINK-SEG, out to *HS-R-LINK-REACH*), no placement
(defmove :hs-r-k2 :kind :flash :clip :hs-k-g-k2 :clip-s 27 :enter 6 :startup 27 :active 10 :recovery 24 :dmg 25 :adv-block -3
  :guard 18 :reach *hs-r-link-reach* :on-hit :stagger :flags (:ranged) :params (:melee-range 2.0)
  :hits ((27 31 :seg-fn hs-r-link-seg) (33 37 :dmg 32 :on-hit :launch :kb *hs-r-k2-launch-kb* :seg-fn hs-r-link-seg)))   ; 束打 SOKUDA
(defmove :hs-r-j2s :kind :quick :clip :hs-k-g-j2 :clip-s 16 :startup 16 :active 3 :recovery 13 :dmg 29 :adv-block -2 :guard 10
  :reach *hs-r-link-reach* :on-hit :flinch :hits ((16 19 :stun 24 :seg-fn hs-r-link-seg)) :flags (:ranged)
  :params (:melee-range 2.0))                                                                                  ; 束鞭 SOKUBEN
(defmove :hs-r-k3g :kind :flash :clip :hs-k-g-k3 :clip-s 27 :enter 6 :startup 27 :active 5 :recovery 34 :dmg 86 :adv-block -20
  :guard 23 :reach *hs-r-link-reach* :on-hit :crumple :hits ((27 32 :seg-fn hs-r-link-seg)) :flags (:ender :ranged)
  :params (:melee-range 2.0))                                                                                  ; 束旋 SOKUSEN
(defmove :hs-r-j3g :kind :quick :clip :hs-k-g-j3 :clip-s 16 :startup 16 :active 3 :recovery 18 :dmg 39 :adv-block -4 :guard 16
  :reach *hs-r-link-reach* :on-hit :stagger :hits ((16 19 :seg-fn hs-r-link-seg)) :flags (:ender :ranged)
  :params (:melee-range 2.0) :on-land hs-r-j3-push)                                                            ; 束薙 SOKUTEI
(defparameter *hs-r-strings*
  '((:hs-r-j1 :q :hs-r-j2) (:hs-r-j1 :f :hs-r-k2s) (:hs-r-j2 :q :hs-r-j3) (:hs-r-j2 :f :hs-r-k3) (:hs-r-k2s :f :hs-r-k3)
    (:hs-r-k1 :f :hs-r-k2) (:hs-r-k1 :q :hs-r-j2s) (:hs-r-k2 :f :hs-r-k3g) (:hs-r-k2 :q :hs-r-j3g) (:hs-r-j2s :q :hs-r-j3g))
  "The ranged mode's J / K strings by route (§22.4; STRING-GRID's shape, JJJ JJK JKK KKK KKJ KJJ, one switch): J1-opened
spread (J2 / K2s, J3 / K3), K1-opened gathered (K2 / J2s, K3G / J3G).")
(defparameter *hs-r-spread-links* '(:hs-r-j2 :hs-r-k2s :hs-r-j3 :hs-r-k3) "The spread route's links 2-3 (J1-opened).")
(defparameter *hs-r-gather-links* '(:hs-r-k2 :hs-r-j2s :hs-r-k3g :hs-r-j3g) "The gathered route's links 2-3 (K1-opened).")
(defparameter *hs-r-clip-stand-ins*
  '()
  "Clip names -> the clip each plays until the art pass draws it (a look, through the Bankai's :clip-map; the art pass
deletes each entry it draws). Empty: the seven ranged route links' were drawn by batch A2 (DUEL_HISAGI §24.2), the bind
SP2 KAIBAKU-GEKI's (HIKIYOSE's gesture until then) by batch A3 (§24.3). The host's drawn-reach checks skip these moves.")
;; L 鎖払 SAHARAI: the chains whirled round him (360 deg r 3.0); a hit or a block pushes him to 3.5 m (S1, §23.3; HS-R-PUSH,
;; HS-BK-HIT). B4d (§22.8): his only close-in tool, no cooldown (120 -> 0), S *HS-SAHARAI-S* / R *HS-SAHARAI-R* / block
;; *HS-SAHARAI-ADV*; its clip redrawn at S 10 / R 32 by batch A3 (DUEL_HISAGI §24.3: speed 1, the recovery drawn), its
;; windup at S 18 with the charge (§25.7)
(defmove :hs-r-l :kind :sig :clip :hs-k-saharai :startup *hs-saharai-s* :active 4 :recovery *hs-saharai-r* :dmg 30
  :adv-block *hs-saharai-adv* :guard 14 :vol (:arc 3.0 360 0.2 2.0) :on-hit :knockback :on-land hs-r-push
  :armor-hits *hs-saharai-armor*   ; §25.23 (the user, 2026-10-21): one hit taken through the charge
  :params (:r-cancel (:q :f)))   ; §25.5 (the user, 2026-10-18: 「卍解的遠距 J / K 能取消 L 的後搖」): from its first recovery
                                 ; frame, on a hit only, J / K start J1 / K1 (MOVE-COMMANDS); blocked or whiffed, none
                                 ; (§25.8, 2026-10-19: 「讓遠距 L 鎖払被擋下後不能通過 J/K 取消後搖」, 「打空也一樣不能取消」)
(defmove :hs-r-sp1 :kind :sp :clip :hs-k-raiden :callout "TSUZURI RAIDEN" :startup 20 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :guard 22 :vol (:cap 0.3 9.0 1.1 0.3) :track 30.0 :flags (:ranged) :on-hit :bind :hits ((20 23 :stun 40))
  :params (:melee-range 2.0) :min-reach *hs-r-dead*)                                                          ; 綴雷電
;; 鎖雨 KUSARI-AME: a 10 m x 2 m lane, aimed 120 deg/s for its first 6 f then locked (HS-R-AME-AIM); two windows; off a
;; J / K string hit the charge-less copy (:enter 10, S_eff 20: HS-BK-COMMAND). The ranged mode's SP2 until B4c; since then
;; the bind mode's SP1 (the user, 2026-10-18: 「鎖雨移到捆綁的 SP1」: its data kept, the SP1 cost from the shared pool). B4d
;; (§22.8, 「鎖雨改成近距離也打得中」): no dead zone (*HS-R-DEAD* -> none), it hits at any range of its lane
(defmove :hs-r-sp2 :kind :sp :clip :hs-k-ame :callout "KUSARI-AME" :startup 30 :active 14 :recovery 30 :dmg 112
  :adv-block -18 :guard 22 :vol (:cap 1.0 10.0 1.2 1.0) :track 120.0 :flags (:ranged) :params (:melee-range 2.0)
  :tick hs-r-ame-aim :hits ((30 34 :on-hit :flinch) (40 44 :dmg 144 :on-hit :knockdown)))
(defmove-copy :hs-r-sp2c :hs-r-sp2 :enter 10)
;; O 降鎖 KOSA: chains rain along a 9 m lane, no dash (it reaches the 7.95 m K ender push from where he stands)
(defmove :hs-r-kikon :kind :kikon :clip :hs-k-kosa-aim :clip-2 :hs-k-kosa :callout "KOSA" :cine hs-kosa-cine
  :startup 20 :active 2 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 9.0 1.2 1.0)
  :on-hit :knockback :kb 2.0 :cooldown 90 :min-reach *hs-r-dead*                 ; (its follow-up strike: no dead zone)
  :params (:aura 6 :aim 120.0 :speed 0.0 :dash-max 0 :ender-dash 0 :dash-track 0.0 :look :lane :follow-speed 14.0))
;; SP2 首掛 KUBIKAKE, the binding throw (§17.2; on P until B4c, the user, 2026-10-18: 「把卍解捆綁給到 SP2，但發動不會消耗
;; SP」): a 7 m line from his hand, no bars spent (:cost 0); his own 200 checked at the press (HS-BK-OK: refused with the
;; cue under it, cooling, a bind up) and at contact (HS-KUBI-LAND); the cooldown set at its start (HS-KUBI-START); a hit
;; yanks him to 2.0 m into a 30 f reel, the recovery cut to 14, and the bind starts at the end of the step (HS-BK-TICK); a
;; block / whiff is punishable (-20 / R 42). Off a J / K string hit the cancel copy (「可以，命中確認後接」: :enter 6, S_eff
;; 18, so the hit-confirm combos off every link: HS-BK-COMMAND, SP2's copy pattern)
(defmove :hs-r-kubikake :kind :flash :clip :hs-k-kubikake :callout "KUBIKAKE" :startup 24 :active 4 :recovery 30 :whiff *hs-kubi-whiff*
  :dmg 40 :adv-block -20 :guard 14 :vol (:cap 0.3 7.0 1.1 0.35) :track 30.0 :on-hit :stagger :hits ((24 28 :stun 30))
  :flags (:ranged :no-close) :params (:melee-range 2.0) :on-land hs-kubi-land :min-reach *hs-r-dead* :cost 0
  :on-frame ((0 hs-kubi-start)))
(defmove-copy :hs-r-kubikake-c :hs-r-kubikake :enter 6 :on-frame ((6 hs-kubi-start)))
(defparameter *hs-kubi-moves* '(:hs-r-kubikake :hs-r-kubikake-c) "KUBIKAKE and its cancel copy (B4c).")

;;; The bind mode (§17.3, the user: 「攻擊模組切換成近戰，此時的 L 會將對手拉近」): the melee set at the §2.1 budget
(defmove :hs-b-j1 :kind :quick :clip :hs-kb-gen :startup 8 :active 3 :recovery 12 :dmg 45 :adv-block -2 :guard 8
  :reach 1.5 :arc 110 :on-hit :flinch :slide 0.3)                                                              ; 弦 GEN
(defmove :hs-b-j2 :kind :quick :clip :hs-kb-kaeshi :startup 8 :active 3 :recovery 13 :dmg 45 :adv-block -2 :guard 8
  :reach 1.5 :arc 110 :on-hit :flinch)                                                                         ; 返弦
(defmove-copy :hs-b-j2s :hs-b-j2)
(defmove :hs-b-j3 :kind :quick :clip :hs-kb-sogen :startup 9 :active 3 :recovery 18 :dmg 55 :adv-block -4 :guard 12
  :reach 1.5 :arc 200 :on-hit :stagger :flags (:ender))                                                        ; 双弦 SOGEN
;; Step + J 穿弦 SENGEN (§25.10, the user, 2026-10-19: 「給檜佐木的卍解捆縛狀態新增一個 step+J 能使出的新招式，這招打中
;;對手的話能接 J1 取消後搖」): the Step's J (HS-BK-COMMAND, from the hop's *STEP-J-CANCEL*) is this lunge instead of J1, the
;; right crescent hurled straight out on its chain to 2.2 m; a hit cancels its recovery into J1 (:r-cancel, from S + A);
;; blocked -10, whiffed R 22 (the cancel only on a hit)
(defmove :hs-b-sj :kind :quick :clip :hs-kb-sengen :startup 10 :active 3 :recovery 22 :dmg 40 :adv-block -10 :guard 10
  :reach 2.2 :arc 60 :on-hit :stagger :slide 0.6 :params (:r-cancel (:q)))                                    ; 穿弦 SENGEN
(defmove :hs-b-k1 :kind :flash :clip :hs-kb-hikigiri :startup 18 :active 4 :recovery 20 :dmg 93 :adv-block -3 :guard 14
  :vol (:cap 0.3 2.6 1.1 0.35) :on-hit :stagger)                                                               ; 引斬 HIKIGIRI
(defmove :hs-b-k2 :kind :flash :clip :hs-kb-makigiri :enter 6 :startup 20 :active 4 :recovery 24 :dmg 81 :adv-block -3 :guard 14
  :reach 2.8 :arc 140 :on-hit :stagger)                                                                        ; 巻斬 MAKIGIRI
(defmove-copy :hs-b-k2s :hs-b-k2)
(defmove :hs-b-k3 :kind :flash :clip :hs-kb-shibori :enter 8 :startup 22 :active 5 :recovery 34 :dmg 116 :adv-block -20 :guard 18
  :reach 3.0 :arc 120 :on-hit :crumple :flags (:ender))                                                        ; 絞 SHIBORI
;; L 絞縄 KOJO (B4c: the old SP2, 引寄 HIKIYOSE's pull in it): at *HS-KOJO-PULL-AT* the noose drags him toward Hisagi to
;; 2.0 m at 18 m/s (HS-PULL-STEP: motion only, until S), then the reap 3.0 m arc 160; no cooldown, no cost; on hit 0, on
;; block -24; its clip drawn at S 30 by batch A3 (DUEL_HISAGI §24.3: the 20 f heave, the drag, the reap; speed 1)
(defmove :hs-b-l :kind :sig :clip :hs-kb-kojo :callout "KOJO" :startup *hs-kojo-s* :active 4 :recovery *hs-kojo-r*
  :dmg *hs-kojo-dmg* :adv-block *hs-kojo-block* :guard 30 :reach 3.0 :arc 160 :on-hit :crumple :track 30.0
  :hits ((*hs-kojo-pull-at* *hs-kojo-yank-to* :dmg *hs-kojo-yank-dmg* :on-hit :flinch :guard 8 :seg-fn hs-foe-seg)
         (30 34))                                                                ; (§25.7: the yank a hit, then the reap)
  :on-frame ((*hs-kojo-pull-at* hs-pull-go)))                                                                 ; 絞縄 KOJO
;; (the bind's SP1 TSUZURI RAIDEN until B4c: KUSARI-AME took its slot, 「鎖雨移到捆綁的 SP1」; kept for its clip strip, 83524)
(defmove :hs-b-sp1 :kind :sp :clip :hs-kb-raiden :callout "TSUZURI RAIDEN" :startup 14 :active 3 :recovery 24 :dmg 110
  :adv-block -14 :guard 22 :vol (:cap 0.3 4.0 1.1 0.3) :on-hit :bind :hits ((14 17 :stun 40)))
;; SP2 解縛擊 KAIBAKU-GEKI (B4c): no bars; at S the release (HS-KAIBAKU-GO: the release as P's, applied at the step's release
;; slot, his move kept: no UNWIND; the opponent's reel after the step's hits, HS-BK-TICK), then its strike, real damage;
;; blockable (blocked or whiffed: the release, no damage). Frame data the lead's pick (§22.6); its own clip, drawn by batch
;; A3 (DUEL_HISAGI §24.3: the noose thrown off at S, the blow)
(defmove :hs-b-sp2 :kind :sp :clip :hs-kb-kaibaku :callout "KAIBAKU" :startup 18 :active 4 :recovery 28 :dmg *hs-kaibaku-dmg*
  :adv-block -14 :guard 22 :reach 3.0 :arc 140 :on-hit :knockback :kb 2.0 :cost 0 :on-frame ((18 hs-kaibaku-go)))     ; 解縛擊
(defmove :hs-b-kikon :kind :kikon :clip :hs-kb-koshu-run :clip-2 :hs-kb-koshu :callout "KOSHU" :cine hs-koshu-cine
  :startup 8 :active 3 :recovery 24 :dmg 111 :adv-block -14 :reach 2.0 :arc 120 :on-hit :knockback :kb 2.5 :cooldown 90
  :params (:aura 6 :aim 120.0 :speed 14.0 :dash-max 30 :dash-track 0.0 :look :flash-step :sfx :hoho-out))      ; 絞首 KOSHU
;; UNWIND: the chains fall slack (20 f, no hit, no iframes): where either end of the bind leaves him (HS-BIND-END-EFFECTS!)
(defmove :hs-b-unwind :kind :flash :clip :hs-kb-unwind :startup 20 :active 0 :recovery 0 :track 0)

(defparameter *hs-r-hooks* '(:tick hs-bk-tick :ok hs-bk-ok :command hs-bk-command :hit hs-bk-hit :reset hs-reset
                             :hash hs-hash :draw hisagi-draw :pose hs-pose :deck hs-deck
                             :bind hs-binding :bind-damage hs-bind-damage :bind-pool hs-bind-pool :bind-heal hs-bind-heal
                             :bind-step hs-bind-step :bind-resolve hs-bind-resolve :bind-snapshot hs-bind-snapshot
                             :dmg-mult hs-dmg-mult :struck hs-bk-struck :hit-fx hs-tip-fx :step-dist hs-step-dist
                             :unscaled hs-tip-now-p)
  "The ranged mode's hooks: the Bankai's (*HS-BK-HOOKS*) without :p / :p-label: P does nothing there since KUBIKAKE moved
to SP2 (B4c, the user 2026-10-18), so the touch deck hides its AWAKEN chip; the bind mode's P the release FREE (gone in
§24.5, back since §25.14).")
(defparameter *hs-bk-hooks* '(:tick hs-bk-tick :ok hs-bk-ok :command hs-bk-command :hit hs-bk-hit :reset hs-reset
                              :hash hs-hash :draw hisagi-draw :pose hs-pose :deck hs-deck :p hs-p-press :p-label hs-p-label
                              :bind hs-binding :bind-damage hs-bind-damage :bind-pool hs-bind-pool :bind-heal hs-bind-heal
                              :bind-step hs-bind-step :bind-resolve hs-bind-resolve :bind-snapshot hs-bind-snapshot
                              :dmg-mult hs-dmg-mult :struck hs-bk-struck :hit-fx hs-tip-fx)
  "The Bankai's hooks (both modes): the bind's state lives on the binder's HSS, so both modes answer B1b's bind hooks; the
:pose hook (HS-POSE: the right crescent let out on its hand chain) is a look, as the Shikai's.")
(defparameter *hs-bk-clips* (append '(:hs-breaker :hs-k-breaker :hs-kubikake :hs-k-hammer) *hs-r-clip-stand-ins*)
  "The Bankai's :clip-map (both modes; a look, DUEL_HISAGI §21.8): the shared Breaker's dash and strike on its own clips
(every Bankai move names its own clip), and the stand-ins still waiting for the art pass (*HS-R-CLIP-STAND-INS*).")
(defparameter *hs-bk-looks* '(:sh-walk-f :hs-k-walk-f :sh-walk-b :hs-k-walk-b :sh-strafe-r :hs-k-strafe-r
                              :sh-strafe-l :hs-k-strafe-l)
  "The Bankai's :look-clips: the shared walk's legs under his hanging arms (§21.8).")
(defparameter *hs-kb-looks* '(:sh-walk-f :hs-kb-walk-f :sh-walk-b :hs-kb-walk-b :sh-strafe-r :hs-kb-strafe-r
                              :sh-strafe-l :hs-kb-strafe-l)
  "The bind mode's :look-clips (batch A2, DUEL_HISAGI §24.2): the walk in the bind's low gripped stance.")

(defkit :hisagi :bankai
  :awakening t :form-name "FUSHI NO KOJO" :name "HISAGI" :body :hisagi-bankai :weapon :kazeshini :stance :hs-k-stance
  :intro :hs-intro :win :hs-win :intro-callout "KARE, KAZESHINI" :cine hs-awaken-cine   ; (the awakening's, B5: §22.7)
  :clip-map *hs-bk-clips* :look-clips *hs-bk-looks* :run-clips (:hs-k-run :hs-k-skate-b :hs-k-slide-r :hs-k-slide-l)
  :walk *hs-r-walk* :run *hs-r-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult *hs-r-mult* :taken *hs-r-taken*
  :push-reach *hs-r-push-reach*
  :commands (:q :hs-r-j1 :f :hs-r-k1 :sig :hs-r-l :sp1 :hs-r-sp1 :sp2 :hs-r-kubikake :breaker :hs-breaker :kikon :hs-r-kikon)
  :strings *hs-r-strings*
  :hooks *hs-r-hooks*
  ;; the ranged mode by route (B4c, §22.4, §22.6): he holds 2-4.5 m; K1 綁束 (the gathered opener) at 2-3 m first (the
  ;; damage), J1 (the spread one) at 3-5 m (S1, §23.3); his :move-reflex picks each link (the K for damage, the J when only it reaches,
  ;; the end when neither does); beyond 5 m SP1 now and then (nothing else of his reaches there); KUBIKAKE (SP2) cancelled
  ;; off a confirmed J / K hit with his 200 (his :move-reflex / :sp-ender); his SP1 only off a link 3 above 300 (keeps the
  ;; 200). B4d (§22.8): K1 an annulus 2.0-4.0 m, so no K1 inside 2 m (L SAHARAI takes its weight there, plus his :reflex's
  ;; roll per entry, or a back Step) and K1 at 3-4 m too (its tip), shared with J1. Round01 cell b1a0 (§25.13's tip x1.71 for
  ;; the whole route): his intents hold the chain tips' distance, 4-5.6 m (K1's tip 4-5, J1's 5-6), 2.5-4.5 before
  :ai (:intents (:approach 1 :pressure 2 :zone 5 :defend 2)
       :ranges (:approach (4.0 4.5) :pressure (3.5 4.5) :zone (4.0 6.0) :defend (5.5 6.5))   ; (§25.35: the tips K1 4-4.5,
                                                                                ;  J1 5.5-6; §25.34's 4.75 5.5 / 4.0 5.0 / 4.75 6.6 / 6.0 7.5;
                                                                                ;  4.0 5.0 / 3.5 4.5 / 4.2 5.6 / 5.0 6.5 before)
       :moves ((0.0 2.5 :sig 1 :step 4)     ; (§25.5: K 2.0-5.0 m, J 3.0-6.0 m; §25.34: K 2.5-5.5, J 4-7; §25.35: K 2.5-4.5,
                                             ;  J 3-6; b1a0: the back Step, not L)
               ;; (round01 cell b3a1: b1a1's 待鎖 MACHI-GUSARI, the waiting chain, ported: no J1 / K1 / Step from the bands
               ;; beyond 2 m, no dash in, no KOSA / SP1 from afar: his J1 / K1 come only off his :reflex's answers (b1a1, HARD,
               ;; the awakening forced, 240 matches: 0.338 -> 0.425))
               (2.5 3.0 nil 6)               ; (b1a1: :f 5 :step 1 -> nothing; 2.0-3.0, §25.34's 2.5-4.0)
               (3.0 4.5 nil 7)               ; (b1a1: :f 3 :q 3 :step 1 -> nothing; 3.0-5.0, 4.0-5.5)
               (4.5 6.0 nil 6)               ; (b1a1: :q 5 :step 1 -> nothing; 5.0-6.0, 5.5-7.0)
               (6.0 99.0 nil 4))             ; (b1a1: no KOSA / SP1 from afar; 6.0-, 7.0-)
       :guard 0.85 :neutral-guard 0.2 :hoho 0.9 :dash 0.0 :dash-back 0.8 :block-string 0.4 :sp-cancel-bars 4 :string-k 1.0
       ;; (b1a0: the fence: :guard 0.5 -> 0.85 against a committed move, the neutral guard 0.2 (a held guard up close fed
       ;; the opponents' Breaker), :hoho 0.3 -> 0.9 (his slow J / K lose every close trade; the Hoho's iframes don't),
       ;; :dash-back 0.6 -> 0.8, :string-k 1.0 (the Breaker's string opens with K1); the 0-2 m band the back Step, not L)
       ;; (b1a1 via cell b3a1: :dash 0.3 -> 0 above; :kikon-range 9.0 -> 0, :o-ender 0: the Kikon only as the O ender forced on
       ;; a red victim)
       :kikon-range 0.0 :o-ender 0.0 :reflex hs-r-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-r-ai-ender :move-reflex hs-r-ai-move))

(defkit :hisagi :bankai-bind
  :awakening t :form-name "FUSHI NO KOJO" :name "HISAGI" :body :hisagi-bankai :weapon :kazeshini :stance :hs-kb-stance
  :intro :hs-intro :win :hs-win :intro-callout "KARE, KAZESHINI"   ; (A2, §24.2: its own stance and walk, a look)
  :clip-map *hs-bk-clips* :look-clips *hs-kb-looks* :run-clips (:hs-k-run :hs-k-skate-b :hs-k-slide-r :hs-k-slide-l)
  :endless-form :bankai :push-reach *hs-b-push-reach*
  :walk *hs-b-walk* :run *hs-b-run* :reishi *reishi-max* :swing-sfx :whoosh-heavy :mult 1.0 :taken 1.0
  :commands (:q :hs-b-j1 :f :hs-b-k1 :sig :hs-b-l :sp1 :hs-r-sp2 :sp2 :hs-b-sp2 :breaker :hs-breaker :kikon :hs-b-kikon)
  :grid (:hs-b-j1 :hs-b-j2 :hs-b-j3 :hs-b-k1 :hs-b-k2 :hs-b-k3 :hs-b-j2s :hs-b-k2s)
  :hooks *hs-bk-hooks*
  ;; the melee rushdown inside the bind, close in (x1.2 within 1.2 m, B4a); L KOJO (pull + strike) now and then at 2.5-4 m,
  ;; the release and the SPs his :reflex / :sp-ender's (HS-B-AI-REFLEX: behind on grey -> SP2 KAIBAKU-GEKI in its reach,
  ;; else the plain P FREE rarely (gone in §24.5, back in §25.14); ahead -> SP1 the rain off a link 3, B4c); no generic SP
  ;; cancel (the pool is shared)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (1.2 3.0) :pressure (0.8 1.2) :zone (2.0 3.0) :defend (2.5 4.0))
       :moves ((0.0 1.2 :q 5)                          ; (b1a0: no Breaker in the bands; round01 b2a1 via cell b3a2: no
               (1.2 1.8 :q 3 nil 1)                    ; neutral K1, -24 net a press at HARD; the J1 +162: the cinching
               (1.8 3.2 nil 3)                         ; route makes its K; :f 4 :q 1 :step 1 -> he walks in, HS-B-AI-REFLEX)
               (3.2 99.0 nil 2))
       :guard 0.4 :hoho 0.9 :dash 0.8 :dash-back 0.1 :block-string 0.6 :sp-cancel-bars 7   ; (b1a0: :hoho 0.3 -> 0.9)
       ;; (b1a1 via cell b3a1: :kikon-range 3.0 -> 0, :o-ender 0: no Kikon rush, no O ender off a victim not red)
       :kikon-range 0.0 :o-ender 0.0 :reflex hs-b-ai-reflex :opp-reflex hs-ai-opp :sp-ender hs-b-ai-ender
       :move-reflex hs-b-ai-move))              ; (round01 b2a0 / b2a1 via cell b3a2: the bind's TODOME, the cinching route)

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
(defun hs-charge-next (n held let sf s top)
  "The windmill's charge one frame on (S1, §23.1): +1 while L is HELD and has not been let go in it (LET), from its up
frame S to its last held frame (TOP), at most *HS-CHARGE-MAX*."
  (if (and held (not let) (<= s sf) (< sf top)) (min *hs-charge-max* (1+ n)) n))
(defun hs-kstr-keep-p (name kstr)
  "Does the charge live on (S1, §23.1) with his move NAME (NIL: none): in a windmill, or in the K string one started (KSTR)
-- K1 / K2 / K3; any other move, a hit taken, neutral: no (reset)."
  (or (and (member name *hs-kazas*) t) (and kstr (member name *hs-k-string*) t)))
(defun hs-leap-speed (d reach s sf)
  "S2 (§23.5): a J-after-K link's leap speed (m/s toward the victim) at its move frame SF of startup S, the victim D m away:
STRING-CHASE-SPEED to J's REACH (its goal 1.0 m) as the hit window opens, at most 60 x *HS-LEAP-MAX* / (S - 1) (so the
whole leap covers at most *HS-LEAP-MAX* m); 0 from the hit window on."
  (if (< sf s) (string-chase-speed d reach (- s sf) (/ (* 60.0 *hs-leap-max*) (max 1 (1- s)))) 0.0))
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
  (charge 0 :type fixnum)                     ; S1: the windmill's charge (frames L held), the K string's reach after it
  (kstr nil)                                  ; S1: the K string he is in was started by a windmill (its reach x the charge)
  (kz-let nil)                                ; S1: L was let go in this windmill (the charge stops)
  (leapt nil)                                 ; §24.4: he leapt (J2K / J3K) in the combo the victim is in now (HS-LINK-OK)
  (zan 0 :type fixnum) (zan-pend nil)         ; §27: 餘電's frames left on his opponent; CHIKUDEN hit, its 放電 not yet known
  (tip-r nil)                                 ; §25.5: a tip hit's Reiatsu before its gains (HS-DMG-MULT), read by HS-BK-HIT
  (tip-x 0.0)                                 ; §25.11: that hit's extra gain factor (the tip's and the spread route's, - 1)
  (route-tip nil)                             ; §25.13: his last opener's (J1 / K1) contact was on the tip (its links take it)
  (tip-hit nil)                               ; §25.26: his last hit was on the tip (a look: HS-TIP-FX's flash; no sim reads it)
  (tip-now nil)                               ; the hit HS-DMG-MULT just read is a ranged-mode tip hit: no combo scaling
  (throw-n 0 :type fixnum)                    ; S1: the charge of the throw out now (its chain length x it, HS-TICK)
  (ai-kz nil) (ai-kz-threat nil)              ; S1, his CPU: K out of this windmill (rolled at the press); the press is a ward
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
  (rel nil) (rel-held nil)                    ; the release: due at the step's release slot (FREE, KAIBAKU-GEKI's S) /
                                              ;  FREE pressed during his own move (§25.14)
  (rel-strike nil) (rel-reel nil)             ; B4c: the due release is KAIBAKU-GEKI's (no UNWIND) / its reel after the hits
  (pull nil)                                  ; L KOJO's drag runs
  (aim-yaw 0f0 :type single-float)            ; SP2 KUSARI-AME's lane (locked after *HS-AME-AIM* frames)
  (ai-band nil) (ai-rolled nil)               ; his CPU (the bind): the band he is in, rolled for this entry
  (ai-rel-key -1 :type fixnum)                ; his CPU in a bind: the change event it last rolled the release for
  (ai-end nil)                                ; his CPU (ranged): the link whose string it chose to end (HS-R-AI-MOVE, B4c)
  (ai-style nil)                              ; his CPU's style this match (*HS-AI-STYLES*: rolled on its first use, a fresh HSS a match)
  (ai-pk -1 :type fixnum)                     ; his CPU: the opponent action (its start tick) it last rolled a punish for
  ;; cell b3a0, the reaping fence (HS-AI-FENCE; CPU-only, never hashed)
  (ai-pd 0f0 :type single-float) (ai-pt -1 :type fixnum)   ; the distance he perceived last step, and that step's tick
  (ai-app nil) (ai-app-go nil)                ; he is seen closing in (an approach); this approach's reap roll
  (ai-fz nil) (ai-fz-rolled nil)              ; he stands inside K1's dead zone (a stay, with hysteresis); its hop roll
  (ai-app-n 0 :type fixnum)                   ; cell b3a0 (§25.15): perceived steps in a row he closed in (the approach's proof)
  ;; cell b0a0 (this freeze; CPU-only, never hashed)
  (ai-hk -1 :type fixnum)                     ; the charge of his (its start tick) the windmill read rolled for
  ;; cell b0a1 (CPU-only, never hashed)
  (ai-hr-n 0 :type fixnum) (ai-hr-k 0 :type fixnum)   ; the read: his K1s into an opponent able to Hoho, and those perfect-Hoho'd
  (ai-hr-key -1 :type fixnum) (ai-hr-p0 0 :type fixnum) (ai-hr-ready nil)   ; the K1 being read: its start, his perfects then, able
  (ai-hseen -999 :type fixnum)                ; the last step he was seen in a Hoho
  (ai-cz nil) (ai-cz-rolled nil)              ; the close-in band he stands in (:step / :far / NIL), rolled for this stay
  ;; cell b0a2 (CPU-only, never hashed): the combo's route plan (HS-AI-PLAN)
  (ai-plan nil) (ai-plan-k 0 :type fixnum)    ; the plan of the combo he is in (*HS-AI-PLAN-ROUTES*' name, :none), its K strings
  (ai-plan-hits 0 :type fixnum) (ai-plan-t -999 :type fixnum)   ; the victim's combo hits and the tick at his last link hit
  ;; the Bankai's styles and fence (b1a0's, merged here; CPU-only, never hashed)
  (ai-form nil) (ai-rstyle nil)               ; the form his CPU last decided in; the ranged style rolled at its entry
  (ai-run nil) (ai-run-go nil)                ; he was seen running in at the last look; this run's anti-approach roll
  (ai-rel nil)                                ; in a bind: the release rolled for, fired once he isn't attacking
  (ai-wake nil) (ai-wake-t -1 :type fixnum)   ; cell b3a0: the waking noose rolled for this awakening, and its tick
  ;; round01 cell b2a2 (CPU-only, never hashed): the bind's bite (HS-B-AI-BITE; merged by the b3a2+b2a2 combination)
  (ai-bite-from -1 :type fixnum)              ; the bind (its start tick) whose bite was decided
  ;; ASSIST's AUTO COMBO routes on a human's fighter (HS-ASSIST-COMBO, DUEL_HISAGI §25.20; never hashed)
  (as-key -1 :type fixnum) (as-cmd nil)       ; the move (its start tick) the route decided for, and its entry (HS-AS-ENTRY)
  (boss-unhit 0 :type fixnum))                ; DANGAI's boss (HS-BOSS-STEP): sim frames since a hit last touched him
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
(defun hs-foe-seg (e)
  "S1's K2 NOKO / K3 TSUI :seg-fn (§23.3): the chain from E's sim hand to his opponent's centre this frame (its radius
*HS-SEG-R*), so the strike lands where the victim is. Values ax ay az bx by bz r."
  (let ((q (pos-of (opp-of e))))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (values (f32 (aref q 0)) (f32 (+ (aref q 1) *hs-anchor-up*)) (f32 (aref q 2)) (f32 hx) (f32 hy) (f32 hz) (f32 *hs-seg-r*)))))
(defun hs-chain-seg-to (e reach)
  "The chain from E's sim hand toward his opponent's centre, its far end there or REACH m from E's feet on that line, whichever is
nearer (radius *HS-SEG-R*). Values ax ay az bx by bz r."
  (let* ((p (pos-of e)) (q (pos-of (opp-of e))) (dx (- (aref q 0) (aref p 0))) (dz (- (aref q 2) (aref p 2)))
         (d (hypot dx dz)) (k (if (> d reach) (/ reach d) 1.0)))
    (multiple-value-bind (hx hy hz) (hs-hand e)
      (values (f32 (+ (aref p 0) (* k dx))) (f32 (+ (aref q 1) *hs-anchor-up*)) (f32 (+ (aref p 2) (* k dz)))
              (f32 hx) (f32 hy) (f32 hz) (f32 *hs-seg-r*)))))
(defun hs-r-link-seg (e)
  "The ranged route links' :seg-fn (§25.13): the chain to the victim within *HS-R-LINK-REACH* (HS-CHAIN-SEG-TO): the link strikes
him where he is within the chain's length."
  (hs-chain-seg-to e *hs-r-link-reach*))
(defun hs-core-seg (e)
  "The core system's link segments' :seg-fn (§26): the chain to the victim within *HS-CORE-CHAIN* (HS-CHAIN-SEG-TO)."
  (hs-chain-seg-to e *hs-core-chain*))
(defun hs-yose (e)
  "The SA 引寄 YOSE's frame 0 (§26.2): the chain drags E's opponent to *HS-YOSE-TO* m, from within *HS-CORE-CHAIN*."
  (when (<= (fighter-dist (fighter e)) *hs-core-chain*) (ichigo-pull-to e *hs-yose-to* 6)))
(defun hs-kagi-pull (e) "AS1 KAGI-BIKI's hit: the hooked victim dragged to :pull m (§26.2)." (ichigo-pull-to e (move-param e :pull) 10))
(defun hs-hoden-x (d)
  "放電 HODEN's distance x at D m (§27.2): *HS-HODEN-NEAR-X* inside *HS-HODEN-NEAR*, 1.0 at *HS-CORE-CHAIN*, linear between."
  (let ((k (/ (- (min (max d *hs-hoden-near*) *hs-core-chain*) *hs-hoden-near*) (- *hs-core-chain* *hs-hoden-near*))))
    (+ *hs-hoden-near-x* (* k (- 1.0 *hs-hoden-near-x*)))))
(defun hs-core-dmg-mult (att def hw mv hazard d2)
  "His Shikai's :dmg-mult hook (combat.lisp APPLY-HIT, §27): 放電 at its distance x, x*HS-ZAN-HODEN* on 餘電; while 餘電 lasts his J / NS
/ AS hits +*HS-ZAN-BONUS* (as a x on the window's damage)."
  (declare (ignore def d2))
  (let ((zan (> (hss-zan (hs att)) 0)))
    (cond ((or hazard (null mv)) 1.0)
          ((getf (mv-params mv) :hoden)
           (let ((x (* (hs-hoden-x (fighter-dist (fighter att))) (if zan *hs-zan-hoden* 1.0))))
             (clog "~a HODEN x~,2f~:[~; (zanden)~]" (side-name att) x zan)
             x))
          ((and zan (plusp (hw-dmg hw)) (member (kit-class (fighter-kit (fighter att)) mv) '(:na :ns :as)))
           (clog "~a ZANDEN +~d" (side-name att) *hs-zan-bonus*)
           (+ 1.0 (/ (float *hs-zan-bonus*) (hw-dmg hw))))
          (t 1.0))))
(defun hs-zan-hit (st mv)
  "A real hit of MV (HS-HIT): AS3's last segment sets 餘電, CHIKUDEN holds it pending (HS-ZAN-TICK), 放電 uses it up (§27)."
  (case (getf (mv-params mv) :zan) (:set (setf (hss-zan st) *hs-zan-frames*)) (:pend (setf (hss-zan-pend st) t)))
  (when (getf (mv-params mv) :hoden) (setf (hss-zan st) 0)))
(defun hs-zan-tick (e st mv)
  "Each step (HS-TICK): 餘電 counts down; CHIKUDEN's pending charge is 放電's (used then) or, once any other move or none is in
play, 餘電 (「留下餘電」)."
  (when (plusp (hss-zan st)) (decf (hss-zan st)))
  (when (hss-zan-pend st)
    (let ((name (and mv (mv-name mv))))
      (cond ((eq name :hs-sa-hoden) (setf (hss-zan-pend st) nil))
            ((not (eq name :hs-n3b)) (setf (hss-zan-pend st) nil (hss-zan st) *hs-zan-frames*)
             (clog "~a ZANDEN (no HODEN)" (side-name e)))))))
(defun hs-look-name (mv)
  "The move whose look MV borrows (a core copy's :params :look-as, §26), else its own name."
  (or (getf (mv-params mv) :look-as) (mv-name mv)))
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
    (setf (hss-state st) :out (hss-anchored st) nil (hss-out-t st) 0 (hss-throw-t st) *match-tick*
          (hss-throw-n st) (if (hss-kstr st) (hss-charge st) 0))
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
  (let ((st (hs e))) (setf (hss-state st) :in (hss-out-t st) 0 (hss-ret-t st) 0 (hss-anchored st) nil
                           (hss-charge st) 0 (hss-kstr st) nil (hss-leapt st) nil
                           (hss-zan st) 0 (hss-zan-pend st) nil)))
(defun hs-pull-to (e to frames)
  "E's chain drags his victim to TO m over FRAMES (his slide replaced; ICHIGO-PULL-TO's rule); T when it moved him."
  (let* ((v (opp-of e)) (p (pos-of e)) (q (pos-of v)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
         (dist (hypot dx dz)))
    (when (> dist to)
      (set-slide v (- dist to) frames dx dz)
      (emit :sfx :chain-snap e)
      t)))
(defun hs-kaza-up (e) "The windmill's up frame (f6): counted." (declare (ignorable e)) (pace e :windmill))
(defun hs-kaza-start (e)
  "The windmill's frame 0 (both copies; not a :hold move, so it runs): no charge yet, no K string (S1)."
  (let ((st (hs e))) (setf (hss-charge st) 0 (hss-kstr st) nil (hss-kz-let st) nil))
  (setf (fighter-ward-until (fighter e)) 0)
  (when (eq (mv-name (fighter-move (fighter e))) :hs-kaza-j) (pace e :bridge)))
(defun hs-leap-tick (e)
  "J2K / J3K's :tick (S2, §23.5): in the startup the leap toward the victim's position (HS-LEAP-SPEED; the move step's own
velocity replaced, a J link has no chase). The look is the move's own clip (A1, §24.1: the crouch, the leap, the J)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (sf (fighter-sf f)) (s (mv-s mv))
         (sp (hs-leap-speed (fighter-dist f) (mv-reach mv) s sf)))
    (when (= sf 1) (pace e :leap) (setf (hss-leapt (hs e)) t))
    (when (> sp 0)
      (let* ((p (pos-of e)) (dx (- (fighter-ox f) (aref p 0))) (dz (- (fighter-oz f) (aref p 2))) (l (max 1e-4 (hypot dx dz)))
             (v (motion-vel (motion e))))
        (setf (aref v 0) (f32 (* sp (/ dx l))) (aref v 2) (f32 (* sp (/ dz l))))))))
(defun hs-tick-brain (e)
  "The brain his windmill decides on: his own CPU's; NIL for a human (no brain, one switched off, the ASSIST gate's masher)."
  (let ((b (brain e))) (and b (not (brain-off b)) (not (eq (brain-habit b) :dumb)) b)))
(defun hs-kaza-k-free-p (f)
  "May the windmill start its K string now (F its fighter)? Not while a ranged hit it caught would still hold a plain
guard (the user, 2026-10-23, Hisagi's Shikai mirror: 「擋下後給硬直」 over 「為什麼修兵一擋下遠攻後就可以直接發動 K 攻擊？甚至能打斷
對手繼續出招」, DUEL_HISAGI §25.24): the blockstun that hit gives (FIGHTER-WARD-UNTIL, set at the catch: combat.lisp
APPLY-HIT), then, as the guard lock does, while the attacker's move can still go on (CHAIN-MORE-P). No catch this
windmill (HS-KAZA-START clears it), no wait: the J bridge into it is unchanged."
  (let ((u (fighter-ward-until f)))
    (or (zerop u)
        (and (>= *match-tick* u)
             (let* ((o (fighter-opp f)) (fo (and o (entity-alive-p o) (fighter o)))
                    (mv (and fo (eq (fighter-state fo) :move) (fighter-move fo))))
               (not (and mv (chain-more-p o fo mv))))))))
(defun hs-kaza-tick (e)
  "The windmill, each frame: L held charges the next K string (HS-CHARGE-NEXT; let go, the charge stops); from
*HS-KAZA-K-FROM* a K (his CPU's: HS-AI-KAZA-K) starts K1, the K string at the charge's reach (HS-TICK swaps each link in;
S1, §23.1); once it has been up *HS-KAZA-MIN* frames, L let go ends the hold (its recovery R 14 next); the clip follows
(a look)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (sf (fighter-sf f)) (s (mv-s mv)) (top (+ s (mv-a mv))) (st (hs e))
         (vp (pilot-vpad (pilot e))) (held (vpad-down vp :sig)) (b (hs-tick-brain e)) (auto nil))
    (setf (hss-charge st) (hs-charge-next (hss-charge st) held (hss-kz-let st) sf s top))
    (unless held (setf (hss-kz-let st) t))
    ;; §25.25 (the user, 2026-10-23: 「風車每次擋下對手攻擊後的硬直時間不計入風車的延續時長中，以免在對手的連擊過程中被中斷風車」):
    ;; while a catch holds the K (HS-KAZA-K-FREE-P), the hold's frame stands still, its clip with it (a look)
    (when (and (<= *hs-kaza-k-from* sf) (< sf top) (not (hs-kaza-k-free-p f)))
      (decf (fighter-sf f))
      (let ((an (model-anim (model e)))) (setf (anim-time an) (- (anim-time an) (/ 1f0 60f0)))))
    (when (and (>= sf *hs-kaza-k-from*) (hs-kaza-k-free-p f)
               (if b
                   (hs-ai-kaza-k e f st)
                   (or (vpad-command-pressed-p vp :flash nil)
                       ;; §25.20: a windmill ASSIST pressed (AUTO COMBO's bridge): the K its press rolled (HS-AI-SIG-HOLD),
                       ;; at his CPU's frame (HS-AI-KAZA-K); a human's own windmill never (not FIGHTER-ASSISTED)
                       (and (fighter-assisted f) (hss-ai-kz st) (setf auto (hs-ai-kaza-k e f st))))))
      (setf (hss-kstr st) t)
      (when auto (setf (fighter-assist-next f) t))   ; (the K string the assist pressed: x*ASSIST-MULT*, as its every press)
      (when (try-command e f :f :flash)
        (if b
            (setf (brain-press-left b) 0)   ; (his CPU lets L go: its hold would keep his reflexes off through the K string)
            (let ((ab (and auto (svref *assist-brains* (fighter-side f)))))
              (vpad-consume! vp :flash)
              (when ab (setf (brain-press-left ab) 0))))   ; (the assist lets its held L go)
        (pace e :kaza-k) (pace e :charge (hss-charge st))
        (clog "~a windmill -> K string x~,2f" (side-name e) (hs-charge-scale (hss-charge st)))
        (return-from hs-kaza-tick nil))
      (setf (hss-kstr st) nil)
      (when auto (setf (fighter-assist-next f) nil)))
    (when (hs-kaza-release-p sf s top held)
      (setf (fighter-sf f) top)
      (play-clip e (kit-move-clip (fighter-kit f) (mv-clip mv)) :blend 2 :time (/ top 60.0)))))

;;; ================================================================ his hooks
(defun hs-command (e cmd)
  "His :command hook (kit.lisp KIT-COMMAND-MOVE): the OUT graph's J1 / K while the sickle is out (HS-COMMAND-FOR); :HOLD
for K while it returns (fighter.lisp TRY-COMMAND starts nothing, the press stays buffered: it throws on the arrival)."
  (let ((name (hs-command-for (hss-state (hs e)) cmd)))
    (cond ((eq name :hold) :hold)
          (name (find-move name)))))
(defun hs-link-ok (e next)
  "His Shikai's :link-ok hook (fighter.lisp, a latched J / K link as it starts): a leap J (J2K / J3K) refused once he has
leapt in this combo (HSS-LEAPT, cleared when the victim is back in neutral: HS-TICK), so K -> J -> L -> K can't loop (§24.4,
the user: 「一套連段只能跳近一次」); the string ends there."
  (not (and (member (mv-name next) *hs-leaps*) (hss-leapt (hs e)))))
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
      (when (member name *hs-pulls*) (pace att (if (eq (contact-of res) :hit) :pull-hit :pull-touch)))
      (when (and (eq (contact-of res) :hit) (eq (fighter-move (fighter att)) mv)) (hs-zan-hit st mv)))))
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
  (let* ((st (hs e)) (mv (current-move f)) (sf (fighter-sf f)) (o (opp-of e)))
    (when (and (hss-leapt st) (or (null o) (zerop (fighter-combo-hits (fighter o)))))   ; §24.4: his leap's combo is over
      (setf (hss-leapt st) nil))
    (cond ((not (hs-kstr-keep-p (and mv (mv-name mv)) (hss-kstr st)))   ; S1 (§23.1): the charge ends with its K string
           (setf (hss-charge st) 0 (hss-kstr st) nil))
          ((and (hss-kstr st) (member (mv-name mv) *hs-k-string*) (not (eq mv (hs-scaled (mv-name mv) (hss-charge st)))))   ; its link at the charge's reach
           (setf mv (hs-scaled (mv-name mv) (hss-charge st)) (fighter-move f) mv)))
    (when (and mv (member (hs-look-name mv) *hs-at-foe*))     ; S1: K2 / K3's chain drawn to him (the look reads the anchor; §26's copies too)
      (let ((q (pos-of (opp-of e)))) (hs-anchor! e (aref q 0) (aref q 2))))
    (when (and mv (eq (fighter-phase f) :main) (hs-throw-name-p (mv-name mv)) (eq (hss-state st) :out)
               (not (hss-anchored st)) (= sf (+ (mv-s mv) (mv-a mv) -1)))
      (let ((p (pos-of e)))
        (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of e) (getf (mv-params mv) :throw))
          (hs-anchor! e x z)))
      (pace e :throw-whiff))
    (case (hss-state st)
      (:out (multiple-value-bind (s n) (hs-out-next :out (hss-out-t st) mv
                                                    (and (not mv) (> (hs-hand-dist e) (* *hs-chain-max* (hs-charge-scale (hss-throw-n st))))))
              (setf (hss-out-t st) n)
              (when (eq s :ret)
                (setf (hss-state st) :ret (hss-ret-t st) *hs-return-frames*)
                (pace e (if (>= n *hs-out-frames*) :auto-return :far-return))
                (clog "~a SICKLE RETURNING" (side-name e)))))
      (:ret (when (<= (decf (hss-ret-t st)) 0)
              (setf (hss-state st) :in (hss-out-t st) 0)
              (clog "~a SICKLE IN (returned)" (side-name e)))))
    (setf (hss-kaza st) (and mv (member (mv-name mv) *hs-kazas*) t))
    (hs-zan-tick e st mv)
    (when *pacing-log*
      (unless (eq (hss-state st) :in) (pace e :out-frames))
      (pace e (hs-band (fighter-dist f))))))
(defun hs-hash (e)
  "His :hash hook (debug.lisp STATE-HASH-LINE): the sickle's state, the anchor (cm), the timers; the bind (B16): bound, the
pool (x10), the snapshot, the release flags, KUBIKAKE's cooldown (B4a's marks and RAKUSA's spot gone with them, B4c); S1:
the charge, the K string's flag, L let go, the throw's charge."
  (let ((st (hs e)))
    (format nil "s~a ~d ~d o~d r~d b~a p~d ~d/~d ~d/~d ~a~a c~d k~d~a~a~d z~d~a" (case (hss-state st) (:in "I") (:out "O") (t "R"))
            (round (* 100 (aref (hss-anchor st) 0))) (round (* 100 (aref (hss-anchor st) 1))) (hss-out-t st) (hss-ret-t st)
            (if (hss-bound st) 1 0) (round (* 10 (hss-pool st))) (hss-r0 st) (hss-k0 st) (hss-or0 st) (hss-ok0 st)
            (if (hss-rel st) "R" "-") (if (hss-rel-held st) "H" "-") 0
            (hss-charge st) (if (hss-kstr st) "K" "-") (if (hss-kz-let st) "L" "-") (hss-throw-n st)
            (hss-zan st) (if (hss-zan-pend st) "P" "-"))))

;;; ================================================================ the Bankai: pure rules (host-tested)
(defun hs-kubi-ready-p (reiatsu bound &optional (need *hs-kubi-reiatsu*))
  "May SP2 start KUBIKAKE (§17.2; B4c: its states the generic SP2's, from neutral or as a cancel off a J / K hit): his own
Reiatsu at NEED (*HS-KUBI-REIATSU*; DANGAI's boss HS-KUBI-NEED), no bind on the field (B15)? (No cooldown since §24.5: its
whiff recovery is the price.)"
  (and (>= reiatsu need) (not bound) t))
(defun hs-release-shares (pool self-first)
  "A released bind's POOL left given back (BIND-RELEASE-SPLIT): values the opponent's share and the binder's; the
opponent's first (B8), or the binder's first when SELF-FIRST (DANGAI's boss, DUEL_ROGUE §5)."
  (multiple-value-bind (a r) (bind-release-split pool) (if self-first (values r a) (values a r))))
(defun hs-rel-free-p (state free)
  "May P (FREE) release the bind now (§17.3; back since §25.14): from idle / walk / guard / blockstun / a run at once; in
hitstun / airborne under the Burst rule (FREE: AWAKEN-STATE-P, past the combo's 2nd hit, Q9 A). During his own move the
press is held (HS-REL-DUE-P)."
  (or (and (member state '(:idle :guard :guard-hit :run)) t) (and free (member state '(:stun :air)) t)))
(defun hs-rel-due-p (sf end)
  "A release held during his own move fires on its last frame (move frame SF = END - 1, END its MOVE-END-FRAME): never a
cancel of a whiffed or blocked recovery (§17.5 #6)."
  (>= sf (1- end)))
(defun hs-dist-mult (form cap edge d along)
  "A hit's damage x by distance (§22.1, D): in the ranged mode (FORM :bankai) the chain tip, *HS-R-TIP-MULT* when the victim
is within *HS-R-TIP* m of the volume's far EDGE or past it (an arc / annulus: his distance D; a line, CAP: ALONG it), else
1.0 (EDGE NIL, no volume: 1.0); in the bind (:bankai-bind) *HS-B-CLOSE-MULT* within *HS-B-CLOSE* m; else 1.0."
  (case form
    (:bankai (if (and edge (>= (if cap along d) (- edge *hs-r-tip*))) *hs-r-tip-mult* 1.0))
    (:bankai-bind (if (<= d *hs-b-close*) *hs-b-close-mult* 1.0))
    (t 1.0)))
(defparameter *hs-step-min* 1.75
  "The ranged mode's Step lands on a chain tip (HS-STEP-LENGTH, §25.32): its hop shortened down to this many m (from
*STEP-DISTANCE* 2.5), never lengthened (the user, 2026-10-23: 「選 1 但改成長度在 1.75~2.5 之間自動調整」).")
(defun hs-step-length (d0 c &optional (len *step-distance*))
  "His ranged-mode Step's hop (m) with the opponent D0 m away and the hop's cosine C toward him (§25.32): a forward one
(C >= 0.7) lands in the nearest chain-tip band inward (J1's 5.25-6.0 m first, then K1's 4.25-5.0), a back one
(C <= -0.7) the nearest outward (K1's first), each band 0.05 m in from its edges, its middle when the hop can reach it,
else the nearest point it can; the hop LEN (2.5, or her field's) shortened to at most *HS-STEP-MIN*. No band in reach,
or a side Step: LEN."
  (if (< (abs c) 0.7)
      len
      (flet ((dist (l) (sqrt (max 0.0 (+ (* d0 d0) (* -2 l d0 c) (* l l))))))
        (let* ((a (dist *hs-step-min*)) (b (dist len)) (lo (min a b)) (hi (max a b)) (m 0.05)
               (bands (list (list (- *hs-r-k-reach* *hs-r-tip*) *hs-r-k-reach*)
                            (list (- *hs-r-j-reach* *hs-r-tip*) *hs-r-j-reach*))))
          (dolist (bd (if (> c 0) (reverse bands) bands) len)
            (let ((x (max lo (+ (first bd) m))) (y (min hi (- (second bd) m))))
              (when (<= x y)
                (let* ((tt (min y (max x (* 0.5 (+ (first bd) (second bd))))))
                       (disc (sqrt (max 0.0 (- (* tt tt) (* d0 d0 (- 1 (* c c))))))))
                  (return (min len (max *hs-step-min* (if (> c 0) (- (* d0 c) disc) (+ (* d0 c) disc)))))))))))))
(defun hs-step-dist (e f to st len)
  "His ranged mode's :step-dist hook (fighter.lisp START-STEP): the hop HS-STEP-LENGTH gives for the stick TO / ST (after
STEP-DIRECTION) and the opponent where the Step reads him (FIGHTER-OX / -OZ)."
  (let* ((p (pos-of e)) (d0 (hypot (- (fighter-ox f) (aref p 0)) (- (fighter-oz f) (aref p 2)))) (n (hypot to st)))
    (if (< n 1e-4) len (hs-step-length d0 (/ to n) len))))
(defun hs-grey-loss (r0 r k0 k)
  "A fighter's grey loss since the bind's start (Konpaku x *REISHI-MAX* + Reishi: his CPU's release read, §17.5 #16)."
  (+ (* *reishi-max* (- k0 k)) (- r0 r)))

;;; ================================================================ the bind's bookkeeping (§17.3 B0-B16)
(defun hs-binding (x) "His :bind hook (combat.lisp BIND-OF): does X bind now?" (let ((st (hss x))) (and st (hss-bound st))))
(defun hs-bind-snapshot (b e)
  "His :bind-snapshot hook: E's Reishi and Konpaku at the start of B's bind (the HUD's grey band and grey souls)."
  (let ((st (hs b))) (if (eq e b) (values (hss-r0 st) (hss-k0 st)) (values (hss-or0 st) (hss-ok0 st)))))
(defun hs-bind-damage (b att def n)
  "His :bind-damage hook (DEAL-DAMAGE in a bind): the pool loses *HS-BIND-DRAIN-RATE* per nominal damage of either fighter
(B3, rules BIND-DRAIN; 1 per 3 since §25.13); the grey counters."
  (declare (ignore def))
  (let ((st (hs b)))
    (setf (hss-pool st) (f32 (bind-drain (hss-pool st) n *hs-bind-drain-rate*)))
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
    (setf (hss-bound st) t (hss-rel st) nil (hss-rel-held st) nil (hss-bind-from st) *match-tick*
          (hss-r0 st) (gauges-reishi g) (hss-k0 st) (gauges-konpaku g)
          (hss-or0 st) (gauges-reishi go) (hss-ok0 st) (gauges-konpaku go)
          (hss-pool st) (f32 (+ (gauges-reiatsu g) (gauges-reiatsu go))) (hss-ai-rel-key st) -1)
    (pace e :binds)
    (pace e :pool-start (round (hss-pool st)))
    (when (eq e *run-boss*) (log-msg "duel boss hisagi bind reiatsu ~,1f pool ~,1f" (gauges-reiatsu g) (hss-pool st)))
    (emit :sfx :chain-snap e)
    (clog "~a BIND pool ~,1f" (side-name e) (hss-pool st))))
(defun hs-bind-off! (b key)
  "The bind is over (KEY: the end's counter): the flags off, the pool at the end counted."
  (let ((st (hs b)))
    (pace b key)
    (pace b :pool-end (round (hss-pool st)))
    (setf (hss-bound st) nil (hss-rel st) nil (hss-rel-held st) nil (hss-pull st) nil (hss-rel-strike st) nil)))
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
    (multiple-value-bind (to-o to-b) (hs-release-shares (hss-pool st) (eq b *run-boss*))   ; (the boss: his share first)
      (when (eq b *run-boss*) (log-msg "duel boss hisagi release pool ~,1f self ~,1f opp ~,1f" (hss-pool st) to-b to-o))
      (pace b :rel-opp (round to-o))
      (pace b :rel-self (round to-b))
      (hs-bind-off! b :end-released)
      (setf (gauges-reishi g) (hss-r0 st) (gauges-konpaku g) (hss-k0 st)
            (gauges-reishi go) (hss-or0 st) (gauges-konpaku go) (hss-ok0 st)
            (gauges-reiatsu go) (f32 to-o) (gauges-reiatsu g) (f32 to-b))
      (clog "~a BIND RELEASED: ~,1f to the opponent, ~,1f back" (side-name b) to-o to-b))))
(defun hs-bind-reel! (b)
  "Either end's effects on the field and the opponent (B9): every hazard cleared; the opponent's move ends and he reels
*HS-BIND-REEL* f (the longer of that and a reaction he is in; airborne / down: his fall stands)."
  (let* ((o (opp-of b)) (fo (fighter o)) (p (pos-of b)))
    (clear-hazards)
    (unless (member (fighter-state fo) '(:air :down :wakeup :cine))
      (when (eq (fighter-state fo) :hoho) (setf (model-alpha (model o)) 1f0))
      (unless (and (eq (fighter-state fo) :stun) (>= (- (fighter-stun fo) (fighter-sf fo)) *hs-bind-reel*))
        (set-reaction o :stagger *hs-bind-reel* (aref p 0) (aref p 2) 0.0)))
    (emit :sfx :chain-snap b)))
(defun hs-bind-end-effects! (b)
  "Either end's effects when no soul is settled (B9): HS-BIND-REEL!; Hisagi's move (hitstun included) ends into UNWIND 20 f
(airborne / down: his fall stands); the ranged mode once he is out of it (HS-BK-TICK)."
  (hs-bind-reel! b)
  (unless (member (state-of b) '(:air :down :wakeup :cine))
    (start-move b (find-move :hs-b-unwind))))
(defun hs-bind-step (b phase)
  "His :bind-step hook: :release (after both fighters stepped, where a Burst applies, before the hits) applies a due
release (B8, B9); :hits (after the step's hits, before SETTLE-SOULS) ends a drained bind (B7; a pool at 0 from this step's
SPs too, B5). A release and a drain on one step: the release wins (§17.5 #11)."
  (let ((st (hs b)))
    (case phase
      (:release (when (hss-rel st)
                  (let ((strike (hss-rel-strike st)))
                    (hs-bind-released! b)
                    (if strike (setf (hss-rel-reel st) t) (hs-bind-end-effects! b)))))   ; (KAIBAKU-GEKI: its strike next)
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
  "His :p hook (the bind mode's FREE: fighter.lisp TRY-COMMAND, P once he is awakened; FREE = AWAKEN-STATE-P): in a bind the
release (HS-REL-FREE-P; else NIL, the press stays buffered as a Burst's): at the step's release slot the bind ends, the
opponent's move ends into a *HS-BIND-REEL* f reel, his own hitstun into UNWIND (HS-BIND-END-EFFECTS!). T = the press taken.
(Gone in §24.5, back since §25.14, the user 2026-10-19: 「恢復 FREE 按鍵」; the ranged mode has no :p since B4c.)"
  (let* ((f (fighter e)) (st (hs e)) (s (fighter-state f)))
    (when (and (hss-bound st) (hs-rel-free-p s free))
      (setf (hss-rel st) t)
      (pace e :release-press)
      (clog "~a KAIBAKU" (side-name e))
      t)))
(defun hs-p-label (e) "His :p-label hook (the bind mode's): the touch chip's label." (declare (ignore e)) "FREE")
(defun hs-kubi-start (e) "KUBIKAKE's first frame (its cancel copy's :enter): the counter (no cooldown since §24.5)." (pace e :kubi))
(defun hs-kubi-land (e)
  "KUBIKAKE's first real hit (:on-land): the noose yanks him to *HS-KUBI-YANK* m, his recovery cut to *HS-KUBI-CUT* f, the
throw re-armed; with his own 200 still there (Senjumaru's 星 may have drained it) and no bind on the field, the bind is
due at the step's end (HS-BK-TICK); else a plain hit."
  (let* ((st (hs e)) (f (fighter e)) (mv (fighter-move f)))
    (hs-pull-to e *hs-kubi-yank* *hs-kubi-yank-frames*)
    (when (and mv (member (mv-name mv) *hs-kubi-moves*))
      (setf (fighter-sf f) (max (fighter-sf f) (- (mv-total mv) *hs-kubi-cut*))))
    (if (and (>= (gauges-reiatsu (gauges e)) (hs-kubi-need e)) (not (bind-of e)))
        (progn (setf (hss-bind-t st) *match-tick*) (pace e :kubi-hit))
        (pace e :kubi-plain))))
(defun hs-push-to (e to frames)
  "Push E's opponent out to TO m from E over FRAMES (PUSH-APART: the wall pushes E back instead)."
  (let ((d (hypot (- (aref (pos-of e) 0) (aref (pos-of (opp-of e)) 0)) (- (aref (pos-of e) 2) (aref (pos-of (opp-of e)) 2)))))
    (when (< d to) (push-apart e (opp-of e) (- to d) frames))))
(defun hs-r-push (e) "SAHARAI's hit: pushed to *HS-SAHARAI-HIT* m." (hs-push-to e *hs-saharai-hit* *hs-saharai-frames*) (pace e :saharai-hit))
(defun hs-r-j3-push (e)
  "J3 旋鎖's first real hit (:on-land, after the generic ender push, which it replaces): to *HS-R-J3-PUSH* m (§22.1)."
  (hs-push-to e *hs-r-j3-push* *ender-push-frames*) (pace e :j3-push))

(defun hs-dmg-mult (att def hw mv hazard d2)
  "The Bankai's :dmg-mult hook (combat.lisp APPLY-HIT): HS-DIST-MULT for his move's hit by his form, its window's first
volume, the victim's distance (D2 squared, from the hit's source) and his distance along ATT's facing; a ranged opener
(J1 / K1) records its tip read for its route, a route link (links 2-3) takes it instead of its own (§25.13); and marks a
tip or a spread-route hit for its SP gain (HS-BK-HIT: §25.5, §25.11); x1.0 for L SAHARAI (unchanged, §22.1), the bind's SP2
KAIBAKU-GEKI (its real 120, B4c), the universal Breaker, a hazard and any other :seg-fn window (no volume)."
  (declare (ignore hazard))
  (setf (hss-tip-now (hs att)) nil)
  (if (or (null mv) (eq (mv-kind mv) :breaker) (member (mv-name mv) '(:hs-r-l :hs-b-sp2)))   ; (KAIBAKU-GEKI: its 120 exact)
      1.0
      (let* ((st (hs att)) (name (mv-name mv)) (bk (eq (fighter-form (fighter att)) :bankai))
             (link (and bk (or (member name *hs-r-spread-links*) (member name *hs-r-gather-links*))))
             (x (if link
                    (if (hss-route-tip st) *hs-r-tip-mult* 1.0)
                    (let* ((v (first (hw-vols hw))) (cap (and v (> (aref v 0) 0.5))) (yaw (yaw-of att)) (p (pos-of att))
                           (q (pos-of def)))
                      (hs-dist-mult (fighter-form (fighter att)) cap (and v (if cap (aref v 2) (aref v 1))) (sqrt d2)
                                    (+ (* (- (aref q 0) (aref p 0)) (fwd-x yaw)) (* (- (aref q 2) (aref p 2)) (fwd-z yaw)))))))
             (tip (> x 1.0))
             (spread (and bk (member name '(:hs-r-j1 :hs-r-j2 :hs-r-k2s :hs-r-j3 :hs-r-k3))))
             (sx (* (cond ((and bk tip) (rmod att :hs-tip-sp *hs-r-tip-sp-mult*))   ; (DANGAI's 尖端 cards: P1's own)
                          (bk (rmod att :hs-flat-sp 1.0))
                          (t 1.0))
                    (if spread *hs-r-spread-sp-mult* 1.0))))
        (when (and bk (member name '(:hs-r-j1 :hs-r-k1))) (setf (hss-route-tip st) tip))
        (setf (hss-tip-hit st) (and bk tip) (hss-tip-now st) (and bk tip))
        (setf (hss-tip-r st) (and (> sx 1.0) (gauges-reiatsu (gauges att))) (hss-tip-x st) (- sx 1.0))
        (cond ((not bk) x)                              ; DANGAI's 尖端強化 / 尖端平均 (DUEL_ROGUE §4.3): the ranged mode's
              (tip (rmod att :hs-tip-dmg x))            ;  tip and other hits at the card's x (x3.42 / x0.1; x1.355 both)
              (t (rmod att :hs-flat-dmg x))))))
(defun hs-tip-now-p (att)
  "The ranged mode's :unscaled hook (combat.lisp APPLY-HIT, after its :dmg-mult): is this hit on the chain tip (HS-DMG-MULT's
read)? Then it ignores the combo scaling (the user 2026-10-25: 「修兵卍解遠距的尖端判定也設成不受連擊衰減的影響」)."
  (hss-tip-now (hs att)))
(defun hs-r-ame-aim (e)
  "KUSARI-AME's :tick: the lane aims (the move's :track 120) for its first *HS-AME-AIM* frames, then it is locked."
  (let* ((f (fighter e)) (st (hs e)) (tr (transform e)))
    (if (<= (fighter-sf f) (+ (mv-enter (fighter-move f)) *hs-ame-aim*))
        (setf (hss-aim-yaw st) (transform-yaw tr))
        (setf (transform-yaw tr) (hss-aim-yaw st)))))
(defun hs-pull-go (e) "KOJO's *HS-KOJO-PULL-AT*: the noose drags." (setf (hss-pull (hs e)) t) (pace e :pull) (emit :sfx :chain-snap e))
(defun hs-kaibaku-go (e)
  "KAIBAKU-GEKI's S: the release due at this step's release slot (as P's), his move kept (HS-BIND-STEP); nothing unbound."
  (let ((st (hs e)))
    (when (hss-bound st)
      (setf (hss-rel st) t (hss-rel-strike st) t (hss-rel-held st) nil)
      (pace e :kaibaku)
      (clog "~a KAIBAKU-GEKI" (side-name e)))))
(defun hs-pull-step (e f st)
  "KOJO's drag (HIKIYOSE's until B4c), each step after the fighters moved: the opponent moved toward him at
*HS-PULL-SPEED* (motion only, added to his own) until *HS-PULL-TO* m or the strike's S; a Hoho / cinematic or his move
ending stops it."
  (let ((mv (fighter-move f)) (o (opp-of e)))
    (if (or (not (eq (fighter-state f) :move)) (not (eq (mv-name mv) :hs-b-l)) (member (state-of o) '(:hoho :cine))
            (>= (fighter-sf f) (mv-s mv)))
        (setf (hss-pull st) nil)
        (let* ((p (pos-of e)) (q (pos-of o)) (dx (- (aref p 0) (aref q 0))) (dz (- (aref p 2) (aref q 2)))
               (dd (max 1e-4 (hypot dx dz))) (step (min (/ *hs-pull-speed* 60.0) (- dd *hs-pull-to*))))
          (when (> step 0)
            (setf (aref q 0) (f32 (+ (aref q 0) (* step (/ dx dd)))) (aref q 2) (f32 (+ (aref q 2) (* step (/ dz dd))))))
          (when (<= (- dd (max step 0.0)) (+ *hs-pull-to* 0.01))
            (setf (hss-pull st) nil)
            (pace e :pull-arrive))))))
(defun hs-bk-ok (e cmd combo)
  "The Bankai's :ok hook: the ranged SP2 KUBIKAKE without his own 200, cooling or with a bind up (HS-KUBI-READY-P); the
bind SP2 KAIBAKU-GEKI with no bind up (B4c). A refusal: the cue."
  (declare (ignore combo))
  (let ((f (fighter e)))
    (case (fighter-form f)
      (:bankai-bind (or (not (eq cmd :sp2)) (hss-bound (hs e))))
      (:bankai (or (not (eq cmd :sp2))
                   (hs-kubi-ready-p (gauges-reiatsu (gauges e)) (bind-of e) (hs-kubi-need e))))
      (t t))))
(defun hs-bk-command (e cmd)
  "The Bankai's :command hook: in a bind, the Step's J is SENGEN (§25.10); off a J / K string hit, the ranged SP2 KUBIKAKE's cancel copy (:enter 6) and the bind's SP1
KUSARI-AME's charge-less copy (:enter 10) (B4c; the bind's SP2 KAIBAKU-GEKI as written, the generic SP cancel)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (bind (eq (fighter-form f) :bankai-bind)))
    (when (and bind (eq cmd :q) (eq (fighter-state f) :step))   ; the Step's J: 穿弦 SENGEN (§25.10)
      (return-from hs-bk-command (find-move :hs-b-sj)))
    (when (and (eq cmd (if bind :sp1 :sp2))
               (eq (fighter-state f) :move) mv (member (mv-kind mv) '(:quick :flash)) (eq (fighter-contact f) :hit))
      (find-move (if bind :hs-r-sp2c :hs-r-kubikake-c)))))
(defun hs-bk-hit (att def res hw mv hazard ranged)
  "The Bankai's :hit hook: SAHARAI's block pushes him to *HS-SAHARAI-BLOCK* m; KUBIKAKE's block counted; a chain-tip hit
(HS-DMG-MULT marked it) earns its Reiatsu gain x *HS-R-TIP-SP-MULT*, a spread-route hit x *HS-R-SPREAD-SP-MULT*, both
multiplied (§25.5, §25.11: the gain since the mark, x the extra)."
  (declare (ignore def hw hazard ranged))
  (let* ((st (hs att)) (r0 (hss-tip-r st)))
    (when r0
      (setf (hss-tip-r st) nil)
      (let ((gain (- (gauges-reiatsu (gauges att)) r0)))
        (when (> gain 0) (reiatsu-gain! att (* gain (hss-tip-x st))) (pace att :tip-sp)))))
  (when (and mv res (eq (contact-of res) :block))
    (case (mv-name mv)
      (:hs-r-l (hs-push-to att *hs-saharai-block* 12) (pace att :saharai-block))
      ((:hs-r-kubikake :hs-r-kubikake-c) (pace att :kubi-block)))))
(defun hs-try-bind! (e)
  "KUBIKAKE hit this step (HSS-BIND-T = now: a step that settled a Kikon or a Soul Break started a cinematic, so this tick
came later and the hit is stale: no bind, B2 / §17.2): the bind starts unless one is up or both throws hit in this step
(the mirror, B15: neither binds)."
  (let* ((o (opp-of e)) (os (hss o)))
    (if (or (bind-of e) (and os (= (hss-bind-t os) *match-tick*)))
        (pace e :kubi-nobind)
        (hs-bind-start! e))))
(defun hs-p-pressed! (e)
  "Is P buffered on E's vpad (then consumed)? FREE pressed during his own move (HS-BK-TICK)."
  (let ((vp (pilot-vpad (pilot e))))
    (when (vpad-command-pressed-p vp :awaken :any) (vpad-consume! vp :awaken) t)))
(defun hs-bk-tick (e f g)
  "The Bankai's :tick hook (every step, after the hits and SETTLE-SOULS): the bind's start, the release held through his
own move, KOJO's drag, the mode = the bind (a SET-FORM only out of a move), KUBIKAKE's cooldown, KAIBAKU-GEKI's reel after
its strike (B4c: the opponent's *HS-BIND-REEL*, unless the step ended the round), the counters; DANGAI's boss rule (HS-BOSS-STEP)."
  (let* ((st (hs e)) (s (fighter-state f)) (mv (and (eq s :move) (fighter-move f))))
    (when (eq e *run-boss*) (hs-boss-step e g st))
    (setf (hss-state st) :in)                           ; (no out-of-hand state in the Bankai: the scythes come back)
    (when (hss-rel-reel st)
      (setf (hss-rel-reel st) nil)
      (unless (member (state-of (opp-of e)) '(:win :lose)) (hs-bind-reel! e)))
    (when (and mv (member (mv-name mv) *hs-kubi-moves*) (eq (fighter-phase f) :main) (= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
               (null (fighter-contact f)))
      (pace e :kubi-whiff))
    (when (= (hss-bind-t st) *match-tick*) (hs-try-bind! e))
    (when (hss-bound st)
      (pace e :bind-frames)
      (when (and mv (not (eq (mv-name mv) :hs-b-unwind)) (hs-p-pressed! e))   ; FREE during his own move: held
        (setf (hss-rel-held st) t))
      (when (and (hss-rel-held st) (not (hss-rel st))
                 (if mv
                     (and (eq (fighter-phase f) :main)
                          (hs-rel-due-p (fighter-sf f) (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) (fighter-contact f)
                                                                       (zerop (length (mv-hits mv))) (mv-kind mv))))
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

;;; ================================================================ DANGAI's boss (DUEL_ROGUE §5, batch 3)
;; the user, 2026-10-22: 「BOSS 檜佐木改成只要沒受到攻擊（防禦算受到攻擊）每秒回 1% Reishi，只要有一格 SP 就能發動捆綁，且主動解除捆綁時
;; SP 優先歸還自身」. Every path is guarded by (EQ E *RUN-BOSS*): with no run nothing here runs.
(defparameter *hs-boss-kubi-reiatsu* 100.0 "The boss's KUBIKAKE binds with this much of his own Reiatsu (1 bar, not 2).")
(defparameter *hs-boss-regen* 0.01
  "The boss's Reishi regen, of his max a second, after *RUN-REGEN-DELAY* (3 s, as 回生: the lead's reading) with no hit
touching him (a hit, a block, an armour hit, a parry: any contact, from any source).")
(defun hs-kubi-need (e) "E's own Reiatsu KUBIKAKE needs to bind: the boss's 1 bar, else *HS-KUBI-REIATSU*."
  (if (eq e *run-boss*) *hs-boss-kubi-reiatsu* *hs-kubi-reiatsu*))
(defun hs-boss (e)
  "His base kit's :boss hook (rogue.lisp ROGUE-STAGE-START, the boss step's spawn, already in his Bankai): the rule's line."
  (setf (hss-boss-unhit (hs e)) 0)
  (log-msg "duel boss hisagi rule regen ~,2f/s after ~d f unhit bind at ~,1f release self first form ~(~a~) reishi ~d/~d"
           *hs-boss-regen* *run-regen-delay* *hs-boss-kubi-reiatsu* (fighter-form (fighter e)) (gauges-reishi (gauges e))
           (gauges-reishi-max (gauges e))))
(defun hs-bk-struck (def att res hw mv hazard ranged)
  "The Bankai's :struck hook: a contact on the boss (any RESULT) restarts his regen's wait (HS-BOSS-STEP)."
  (declare (ignore att res hw mv hazard ranged))
  (when (eq def *run-boss*) (setf (hss-boss-unhit (hs def)) 0)))
(defun hs-boss-step (e g st)
  "The boss's regen, each sim step (HS-BK-TICK): *HS-BOSS-REGEN* of his Reishi max a second once *RUN-REGEN-DELAY* frames
passed with no contact (RUN-REGEN-HEAL); its log lines (the regen's start, his Reishi every 10 s)."
  (let* ((u (setf (hss-boss-unhit st) (min 99999 (1+ (hss-boss-unhit st)))))
         (n (run-regen-heal u (gauges-reishi-max g) *hs-boss-regen*)))
    (when (plusp n) (heal! e n))
    (when (= u (1+ *run-regen-delay*)) (log-msg "duel boss hisagi regen on t ~d reishi ~d" *match-tick* (gauges-reishi g)))
    (when (zerop (mod *match-tick* 600))
      (log-msg "duel boss hisagi state t ~d form ~(~a~) reishi ~d/~d reiatsu ~,1f unhit ~d bound ~:[no~;yes~]" *match-tick*
               (fighter-form (fighter e)) (gauges-reishi g) (gauges-reishi-max g) (gauges-reiatsu g) u (hss-bound st)))))

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
    (log-msg "duel probe hisagi ~a t ~d p1 ~a ~a sickle ~a anchor ~,2f ~,2f out ~d ret ~d rei ~,1f charge ~d~a | p2 ~a r~d gg ~d | d ~,2f"
             tag *match-tick* (fighter-form (fighter *p1*)) (state-of *p1*) (hss-state st) (aref (hss-anchor st) 0) (aref (hss-anchor st) 1)
             (hss-out-t st) (hss-ret-t st) (gauges-reiatsu (gauges *p1*)) (hss-charge st) (if (hss-kstr st) " K" "")
             (state-of *p2*) (gauges-reishi g2)
             (round (gauges-gg g2)) (fighter-dist (fighter *p1*))))
  (let ((st (hs *p1*)) (g1 (gauges *p1*)) (g2 (gauges *p2*)))
    (log-msg "duel probe hisagi-bind ~a t ~d bound ~a pool ~,1f p1 rei ~d/~d k ~d/~d ra ~,1f | p2 rei ~d/~d k ~d/~d ra ~,1f ~a | cd ~d"
             tag *match-tick* (hss-bound st) (hss-pool st) (gauges-reishi g1) (hss-r0 st) (gauges-konpaku g1) (hss-k0 st)
             (gauges-reiatsu g1) (gauges-reishi g2) (hss-or0 st) (gauges-konpaku g2) (hss-ok0 st) (gauges-reiatsu g2)
             (state-of *p2*) 0)))

(defun hisagi-test (k)
  "83000+k (human P1 Hisagi, P2's CPU off unless noted, P1's Reiatsu full; a \"duel probe hisagi\" line): 0 2 m from an idle
Kenpachi; 1 6 m from him; 2 4 m from him, the sickle out (anchored 3 m ahead, the timer at 0); 3 8 m from Yamamoto, his L
wave started, the windmill started (blocked from every side); 4 5 m from Kenpachi, NAGE started (the throw); 5 the mirror,
both CPUs, 6 m apart; 6 2 m from Kenpachi, J1 started (the JKK: K K for MAKI, HODOKI); S1 (§23.1): 7 2 m from him, J1
started with L latched (the bridge: hold L to charge, K for the K string); 8 8 m from him, the windmill started (hold L,
K: the charged K1 at range); S2 (§23.5): 9 5 m from him, K1 started with J latched (KJ: J2K leaps in; J again: KJJ); 19
5 m from him, K1 started with K latched (KK; J during K2: KKJ's J3K leaps in). The Bankai (B2b; P1 awakened,
HS-AWAKEN-NOW!): 10 the ranged mode 6 m from Kenpachi; 11 5 m from him, KUBIKAKE started (SP2 since B4c: the bind on a hit); 12 a bind
3 m from him with grey values (he dealt 300, took 200: the pool 600 -> 350); 13 as 12, the release pressed (applied this
step: the snapshot back, the pool's 350 split 300 / 50, the reel, UNWIND); 14 as 12, the pool at 1 and a 10 hit (the
drained end at this step's hits); 15 the Bankai mirror, both CPUs awakened, 6 m apart. B4c (§22.6): 16 the ranged mode
2.5 m from an idle Kenpachi (the gathered route, K1 綁束 at 2.0-4.0 m: press K K K / K K J / K J J); 17 the ranged mode
3.5 m from him (the spread route off J1: J J J / J J K / J K K); 18 the ranged mode 4 m from a CPU Rukia, P1's CPU on (a
fresh CPU battle); §25.20: 20 / 21 P1 the button-masher with ASSIST ALWAYS + COMBO + BREAK vs a CPU, 6 m: the Shikai vs
Lille, the Bankai's ranged mode vs Kenpachi; §25.26: 22 / 23 the ranged mode 4.25 / 5.75 m (§25.35's tips) from an idle Kenpachi (on K1's /
J1's tip: the cues); §25.27: 24 the Bankai mirror 4.25 m apart, both CPUs off (P1's white flow, P2's black); any other k
the probe line only."
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
      (7 (setup :kenpachi 2.0) (force-cmd *p1* :q) (setf (fighter-queued (fighter *p1*)) :sig))
      (8 (setup :kenpachi 8.0) (force-cmd *p1* :sig))
      ((9 19) (setup :kenpachi 5.0) (force-cmd *p1* :f) (setf (fighter-queued (fighter *p1*)) (if (= k 9) :q :f)))
      (10 (setup :kenpachi 6.0) (hs-awaken-now! *p1*))
      (11 (setup :kenpachi 5.0) (hs-awaken-now! *p1*) (start-move *p1* (find-move :hs-r-kubikake)))
      ((12 13 14) (setup :kenpachi 3.0) (hs-awaken-now! *p1*) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind)
       (deal-damage *p1* *p2* 300) (deal-damage *p2* *p1* 200)
       (case k
         (13 (setf (hss-rel (hs *p1*)) t))
         (14 (setf (hss-pool (hs *p1*)) 1f0) (deal-damage *p1* *p2* 10))))
      (15 (setup :hisagi 6.0 :cpu t) (hs-awaken-now! *p1*) (hs-awaken-now! *p2*))
      (16 (setup :kenpachi 2.5) (hs-awaken-now! *p1*))
      (17 (setup :kenpachi 3.5) (hs-awaken-now! *p1*))
      (18 (setup :rukia 4.0 :cpu t) (hs-awaken-now! *p1*))   ; (Rukia: no other scene starts that battle, so a fresh CPU one)
      ((22 23) (setup :kenpachi (if (= k 22) 4.25 5.75)) (hs-awaken-now! *p1*))    ; §25.26: on K1's / J1's tip (the cues; §25.35's)
      (24 (setup :hisagi 4.25) (hs-awaken-now! *p1*) (hs-awaken-now! *p2*))         ; §25.27: the mirror on K1's tip (both flows)
      ;; §25.20: P1 the ASSIST gate's button-masher (habit :dumb, an EASY CPU's eyes) with ASSIST ALWAYS + COMBO + BREAK
      ;; against a CPU: 20 the Shikai vs Lille 6 m (her shots: AUTO GUARD's windmill; J mashed: the route plans), 21 the
      ;; Bankai's ranged mode vs Kenpachi 6 m (the tip opener, the routes, the noose and the bind's cinching route)
      ((20 21) (setup (if (= k 20) :barro :kenpachi) 6.0 :cpu t)
       (when (= k 21) (hs-awaken-now! *p1*))
       (setf (brain-habit (brain *p1*)) :dumb (brain-delay (brain *p1*)) (getf *ai-delay* :easy) *assist-debug* (list 2 t t))))
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
