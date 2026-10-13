;;;; barro.lisp — LILLE BARRO II (roster index 6, kit :barro, display name "LILLE II"), version 3 (docs/duel/DUEL_LILLE_V3.md;
;;;; the earlier versions' record: DUEL_LILLE_V2.md). A separate fighter built from a copy of lille.lisp (the old Lille stays
;;;; as he is, index 5). Version 3 (the user, 2026-10-10, decisions R1 / R2; revised 2026-10-11, R3): one grammar in every
;;;; form, the base stance's. The attack state is the form's J / K strings (the man with Diagramm, JILLIEL's wing cuts KIN,
;;;; the owl's claws); L enters THE STANCE (the base form's 狙擊架式 move, the awakened forms' ranged mode EN; from a link
;;;; the same plain entry), whose first press picks one of three strings of short several-hit shots (4 m: nothing spent,
;;;; no long reach), each ending back in the attack state: L L gathers the special resource (the base's 狙擊 pips, cap 3;
;;;; the awakened wings, cap 8), K K hits hard, J J refills flash step and Reiatsu; J J and K K go on into L L, 萬物貫通
;;;; lines that spend one a line (K K's for damage, J J's for more refill). SP1 reads the count (flash step back); SP2
;;;; spends every special for damage, slow on its own, quick off a K K that hit. A burst in an awakened form turns him into
;;;; the owl until it ends (one buff set); the owl's SP2 is the full volley. Awakened, a hit during his own attack spends 4
;;;; wings (the owl 2) and the attack goes on. U guards in every form. 萬物貫通 THE X-AXIS on every spending line (a block
;;;; drains 40 of the guard gauge and lets 30 % through, the line runs 31 m).
;;;; Sim code shares nothing with lille.lisp (every function, knob, struct, move and hazard here is BR- / :BR-). The art is
;;;; shared by reference: his moves name Lille's clips, bodies (:lille :lille-jilliel :lille-jilliel-kin :lille-shin), weapon
;;;; :diagramm, his kits Lille's cinematics and draw hook; barro-art.lisp holds his own clips and looks.
;;;; Plain CL above the hooks: the host rules test loads it.
(in-package :duel)

;;; ================================================================ knobs (DUEL_LILLE_V3 §3)
;; 萬物貫通 THE X-AXIS (DUEL_LILLE_V2 §3, decision V1)
(defparameter *br-x-guard* 40
  "萬物貫通: the guard gauge a blocked line drains (gauge 100, a usual block ~30; the 3rd blocked one breaks guard). New,
2026-10-09, the user's decision V1 「被擋扣 40、穿透 30%」 (the old Lille's *LB-X-GUARD* 30).")
(defparameter *br-x-chip* 0.30
  "萬物貫通: the fraction of a blocked line's damage that goes through (the chip rule: it never kills). New, 2026-10-09, the
user's decision V1 (the old 0.15).")
(defparameter *br-x-len* 31.0
  "萬物貫通 「射程距離無限」: a line's length, metres (the arena's diameter, radius 15, + 1; the old shot's). New, 2026-10-09,
the user (as metres).")

;; the base form
(defparameter *br-walk* 3.4 "Walk m/s, the base form (the old Lille's *WALK-LILLE*, copied 2026-10-09).")
(defparameter *br-run* 8.5 "Run m/s, the base form (copied 2026-10-09).")
(defparameter *br-mult* 1.3 "Damage dealt x, the base form (the old *LILLE-MULT* 1.3, copied 2026-10-09; [G] a gate knob).")
(defparameter *br-taken* 1.0 "Damage taken x, the base form (copied 2026-10-09).")
(defparameter *br-aim-track* 60.0 "Degrees / s he turns in the base stance (copied 2026-10-09).")
(defparameter *br-kamae-up* 6 "The base stance's frame where it is up: its strings start from here (copied 2026-10-09).")
(defparameter *br-kamae-tap* 30 "Frames the base stance holds past its f6 on a tap of L (copied 2026-10-09) ...")
(defparameter *br-kamae-max* 90
  "... and at most while L is held; then R 14 (copied 2026-10-09; R15, DUEL_LILLE_V3 §19: L held is the stance L's charge,
BR-KAMAE-TICK, so the stance stands *BR-KAMAE-TAP* whatever L does).")
(defparameter *br-to-dash-held* 10
  "L held this many frames from its press into a stance -- KIN's turn (:br-to-en, read on its f11: R13, the user 2026-10-11:
「我希望非架式時短按 L 就切入架式、長按 L 就直接進入衝刺斬的續力」) or the base stance once it is up (R15, §19) -- starts
the stance's L in its charge at once, the frames held so far counted (BR-GO-RANGED, BR-KAMAE-TICK; [G]).")
(defparameter *br-snipe-len-2* 12.0
  "The base stance's L, the charged snipe (R15, DUEL_LILLE_V3 §19: 「蓄力狙擊」): its shot's length at the charge level 2
(*BR-W-L-LEVELS*), metres; level 1 *BR-S-NEAR*'s 4, level 3 *BR-X-LEN*'s 31, the 萬物貫通 line (through guard,
uncatchable) ...")
(defparameter *br-snipe-dmg-1* 16 "... its damage at level 1 ...")
(defparameter *br-snipe-dmg-2* 32 "... at level 2 ...")
(defparameter *br-snipe-dmg-3* 48 "... at level 3 (the specials by the level: *BR-W-L-GAIN*) ([G]).")
(defparameter *br-sanren-dmg* 30 "SP1 outside the stance: each of three lines, 20 m, no 萬物貫通 (new 2026-10-09 [G]).")
(defparameter *br-hiren-dmg* 40 "SP2 outside the stance: the shot after the slide, 20 m, no 萬物貫通 (new 2026-10-09 [G]).")
(defparameter *br-plain-len* 20.0 "SP1 / SP2 outside the stance: their lines' length, metres (new 2026-10-09 [G]).")
(defparameter *br-k-sanren-dmg* 30 "SP1 in the stance: each of its three 萬物貫通 lines (new 2026-10-09 [G]).")
(defparameter *br-k-hiren-dmg* 50 "SP2 in the stance: the shot after the 6 m back-slide, 萬物貫通 (new 2026-10-09 [G]).")
;; the base stance's Step 飛廉脚 (DUEL_LILLE_V2 decision V6, kept)
(defparameter *br-kamae-dash* 5.0
  "The stance's Step 飛廉脚: metres in the stick direction (neutral: away from him) over *BR-KAMAE-DASH-F* (decision R3,
the user 2026-10-11: 「進入架式後靠 step 快速移動一次」: 3.5 m / 12 f -> 5 m / 10 f, and the awakened stance EN's first Step
the same, BARRO-STEP; [G]) ...")
(defparameter *br-kamae-dash-f* 10 "... frames (12 -> 10, R3); back in the stance on its f6 at *BR-KAMAE-BACK* ...")
(defparameter *br-kamae-back* 9 "... this frame of the step (11 -> 9, R3; the stance's f6, a fresh window) ...")
(defparameter *br-kamae-dash-iframes* 8 "... invulnerable on its frames 0-7 (decision V6) ...")
(defparameter *br-kamae-dash-fs* 10.0
  "... its flash-step price, once per stance; refused (the press ignored) when short or already used (decision V6).")
(defparameter *br-dash-snap-f* 3
  "The stance Step's frame from which a J starts the stance's J J (v3, 2026-10-10 [G]: the Step cancelled there; it was the
snap shot's frame, decision V9c).")

;; the special resource (decision R2, the user 2026-10-10: 「架勢 > LL：回收特殊資源」; 「常態也一起改」)
(defparameter *br-ammo-max* 3
  "The base form's special resource, 狙擊 pips: at most this many (decision V1's 3, kept by R2: 「常態也一起改」 with the pips).")
(defparameter *br-wing-max* 8
  "The awakened forms' special resource, the wings: at most this many (Jilliel's eight blades; DUEL_LILLE_V3 rev. 1 [G],
R1: 「消耗四片翼」). The base's pips carry in at the awakening (3 pips -> 3 wings).")

;; the stance's strings (decision R2: 「架勢用 L 進入（兩個相同的符號代表連擊）1. 架勢 > LL：回收特殊資源 2. 架勢 > KK： 高攻擊，可以再銜接 JJ
;; 消耗資源提高傷害 3. 架勢 > JJ： 高額閃步/SP 量表恢復，可以再銜接 KK 消耗資源提高恢復量」; 「每下花 1 翼」; 「連段打完自動回近戰」), revised by
;; decision R3 (the user, 2026-10-11): 「架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊」, 「架勢中的 JJ / KK 由銜接 KK / JJ 改成統一銜接
;; LL，風格延續」 (「兩者都花資源」), 「沒有消耗資源的話就不能有遠距離攻擊」, 「現在的資源回收量太高了，請下降至少 50%」.
;; Every number [G], DUEL_LILLE_V3 §8; damage before the form's multiplier
(defparameter *br-s-near* 4.0
  "The stance's openers (L L, J J, K K: nothing spent): their shots' reach, metres; plain shots, no 萬物貫通 (decision R3:
「沒有消耗資源的話就不能有遠距離攻擊」; they were 31 m 萬物貫通 lines; new 2026-10-11 [G]).")
(defparameter *br-s-l-dmg* 16
  "Stance L 回收: L1 / L2's one hit (decision R7, the user 2026-10-11: 「段數跟操作時的點擊次數一致」, one hit a press, 「每段總傷害
不變」: 2 x 8 -> 16; R3, 10 a shot before; [G]) ...")
(defparameter *br-s-l3-dmg* 24 "... L3's (R7: 3 x 8 -> 24) ...")
(defparameter *br-s-l-gain* '(0 0 1)
  "... the special each of its three segments gives on a hit or a block (L3 +1: a full string +1; it was +1 / +2 = +3,
R3 「下降至少 50%」, 2026-10-11 [G]).")
(defparameter *br-s-k-dmg* 46
  "Stance K 高攻: K1 / K2's one hit (R7: 2 x 14 -> 28; R3, 45 a shot before; 28 -> 36, R13, the user 2026-10-11: 「降低普通 K
的傷害，並提高架式 K > L 的重斬與砲擊傷害」; 36 -> 46, R14: 「我希望 K 之後的 LL 傷害大於架式 K 又大於普通 K」, each segment
above the attack state's K at its place, every form: BR-K-ORDER-P) ...")
(defparameter *br-s-k3-dmg* 66 "... K3's (R7: 3 x 14 -> 42; a string 98 as before; 42 -> 54, R13: a string 126; 54 -> 66, R14: 158) ...")
(defparameter *br-s-kl-dmg* 70
  "... its L L follow-up (R3: K K -> L L, 「兩者都花資源」): each line's damage, one special spent a line (a 萬物貫通 line, 31 m;
none left: no follow-up). The K K -> J J follow-up's 15 + 30 before (new 2026-10-11 [G]; 45 -> 56, R13: three 168; 56 -> 70, R14: above the stance K3, three 210).")
(defparameter *br-s-j-dmg* 15 "Stance J 回復: each segment's one hit (R7: 3 x 5 -> 15, J3's too; R3, 15 a shot before) ...")
(defparameter *br-s-j-fs* 3.0
  "... each segment's hit gives this much flash step (a string 9; it was 10 a segment, 20 a string: R3 「下降至少 50%」) ...")
(defparameter *br-s-j-sp* 5.0 "... and this much Reiatsu (a string 15, it was 30; a block x *BR-S-BLOCK*) ...")
(defparameter *br-s-jl-dmg* 15
  "... its L L follow-up (R3: J J -> L L): each line's damage, one special spent a line (a 萬物貫通 line, 31 m); its hit gives
J J's, and ...")
(defparameter *br-s-jl-fs* 10.0 "... + this much flash step (20 -> 10, R3) ...")
(defparameter *br-s-jl-sp* 15.0 "... + this much Reiatsu (30 -> 15, R3; new 2026-10-10 [G]).")
(defparameter *br-s-block* 0.5 "A blocked recovery shot's share of its gains (new 2026-10-10 [G]).")

;; SP1 / SP2 by the special count (decision R1: 「依據特殊資源數量不同，SP1 與 SP2 會有相對應的變化」; read, never spent)
(defparameter *br-sp-tiers* '(4 8)
  "The awakened forms' SP tiers by the wings: 0-3 tier 0, 4-7 tier 1, 8 tier 2 (new 2026-10-10 [G]) ...")
(defparameter *br-sp-tiers-base* '(2 3) "... the base form's by the pips: 0-1, 2, 3 (new 2026-10-10 [G]).")
(defparameter *br-sp1-fs* '(9.0 18.0 35.0)
  "SP1 gives this much flash step back by its tier on its f0 (R1's SP1 「恢復閃步」 side of the loop; 18 / 35 / 70 halved by
decision R3 「現在的資源回收量太高了，請下降至少 50%」, 2026-10-11 [G]).")

;; SP2 spends every special for damage (decision R3, the user 2026-10-11: 「高資源換取高傷害的定位設計給 SP2 佔有，並讓其單發破綻大、
;; 必須接在 KK 後執行才能有效利用」; 「花光全部，每單位加傷害」; the owl's: 「併入梟頭的 SP2」, the full volley)
(defparameter *br-sp2-unit* 40
  "The base form's SP2 (HIRENKYAKU, in and out of the stance): + this damage a pip spent (40 + 3 x 40 = 160; new 2026-10-11
[G]) ...")
(defparameter *br-w-sp2-unit* 25 "... JILLIEL's (NIJUSHI-KO 180 -> 60, + this a wing: 60 + 8 x 25 = 260; new 2026-10-11 [G]).")
(defparameter *br-sp2-slow-r* 20
  "Every SP2's recovery + this many frames (「單發破綻大」, new 2026-10-11 [G]); started on its own the charge plays in full;
cancelled off a stance K K that hit (K2 / its follow-up's last line) the charge-less copy (「必須接在 KK 後執行」).")
(defparameter *br-recall-charge* 30
  "The owl's SP2 (the full volley) started on its own: frames before its string (the K K cancel's *BR-RECALL-F*; new
2026-10-11 [G]) ...")
(defparameter *br-recall-charge-fire* 29 "... its string starts on this frame (*BR-RECALL-CHARGE* - 1).")

;; the 4-wing armour (decision R1: 「攻擊時如果被攻擊可以消耗四片翼使自己不會被打斷（不足時不觸發效果）」)
(defparameter *br-armor-wings* 4 "Wings a hit during his own attack spends so it does not interrupt him, awakened (R1) ...")
(defparameter *br-owl-armor-wings* 2 "... the burst owl's (its buff, new 2026-10-10 [G]).")

;; the burst owl (decision R1: 「取消掉再覺醒，改成爆氣時會進入梟頭模式與獲得對應的 buff」; R2: 「buff 不分顏色」)
(defparameter *br-owl-mult* 1.2 "Damage dealt x, the burst owl (its buff; the old revival's 1.1 -> 1.2, new 2026-10-10 [G]).")
(defparameter *br-owl-taken* 1.1 "Damage taken x, the owl (JILLIEL's; copied 2026-10-09).")
(defparameter *br-owl-wing-every* 120
  "The burst owl gains a wing every this many frames (its buff; 60 -> 120 by decision R3 「下降至少 50%」, 2026-10-11 [G]).")
(defparameter *br-owl-adv* 1
  "The owl's J / K strings recover this many frames sooner than JILLIEL's (+1 on hit and block; the old *SHIN-ADV*,
copied 2026-10-09; the moves carry the numbers).")

;; the slow motion (moved off the traces, DUEL_LILLE_V3 rev. 1 [G]; the old Lille's numbers, decision V9l)
(defparameter *br-fresh-scale* 0.1 "The stance's first hit slows the whole match to this time scale (SLOWMO) ...")
(defparameter *br-fresh-secs* 0.2 "... for this many real seconds (the old *LB-FRESH-SECS*).")
(defparameter *br-volley-scale* 0.2 "The full volley's last beam on a hit slows it to this ...")
(defparameter *br-volley-secs* 0.5 "... for this many real seconds (the old *LB-CROSS-SECS*).")

;; the two routes (decision V8, kept: the J / K feel split in every form)
(defparameter *br-j-speed* 2 "Decision V8, the J route: a J's startup and recovery each this many frames shorter ...")
(defparameter *br-j-min-s* 4 "... the startup at least this ...")
(defparameter *br-j-min-r* 6 "... the recovery at least this ...")
(defparameter *br-j-mult* 0.85 "... its damage x this, rounded ...")
(defparameter *br-j-adv* 2 "... and its block advantage this many frames higher (decision V8). The awakened forms' J strings
keep the damage and the block advantage but not the speed (route :JN, decision R3, the user 2026-10-11: 「覺醒後所有的 JJ 都太快了請
回到標準速度」).")
(defparameter *br-k-slow* 2 "Decision V8, the K route: a K's startup and recovery each this many frames longer ...")
(defparameter *br-k-link-slow* 1 "... but a K link's effective startup only this many longer, 14 -> 15 ...")
(defparameter *br-k-mult* 0.80
  "... its damage x this, rounded (1.20 -> 1.00, R13, the user 2026-10-11: 「降低普通 K 的傷害」: every form's attack-state K
string, the base's, KIN's and the owl's; 1.00 -> 0.80, R14: below the stance K, BR-K-ORDER-P) ...")
(defparameter *br-k-adv* -4 "... and its block advantage this many frames lower (decision V8).")

;; JILLIEL
(defparameter *br-walk-en* 0.0
  "Walk m/s, the awakened stance EN (afloat; the old *WALK-JILLIEL* 3.0, copied 2026-10-09; 3.0 -> 0.0, R12, the user
2026-10-11: 「我希望架式時只能像常態架槍一樣通過一次 step 高速移動，然後過一小段時間就會自動解除架式」: rooted as the base
stance, its one fast Step its only move, no run (BARRO-TICK), *BR-EN-HOLD* then back to KIN).")
(defparameter *br-en-hold* 30
  "The awakened stance EN (R12): this many frames standing in it (idle or guarding: from its entry, a fresh window after its
fast Step) and it ends, back to KIN (the base stance's *BR-KAMAE-TAP*; [G]).")
(defparameter *br-run-en* 8.0 "Run m/s, EN (the old *RUN-JILLIEL*, copied 2026-10-09).")
(defparameter *br-walk-kin* 3.8 "Walk m/s, KIN (the old *WALK-KIN*, copied 2026-10-09).")
(defparameter *br-run-kin* 8.5 "Run m/s, KIN (the old *RUN-KIN*, copied 2026-10-09).")
(defparameter *br-jilliel-mult* 1.0 "Damage dealt x, JILLIEL (copied 2026-10-09).")
(defparameter *br-jilliel-taken* 1.1 "Damage taken x, JILLIEL (copied 2026-10-09).")
(defparameter *br-jilliel-lift* 0.5 "JILLIEL is drawn this many metres up (kit :lift; a look; copied 2026-10-09).")
(defparameter *br-owl-lift* 0.35 "The owl's EN is drawn this many metres up (a look; copied 2026-10-09).")
(defparameter *br-to-en-f* 12 "L into the awakened stance: the turn, frames (new 2026-10-09 [G]).")

;; the full volley (the recall's derivative strings): the owl's SP2 since decision R3 (「併入梟頭的 SP2」, 2026-10-11)
(defparameter *br-recall-f* 8
  "The owl's SP2 cancelled off a stance K K that hit: frames before its derivative string (K3 -> L's until R3; new
2026-10-09 [G]).")
(defparameter *br-recall-tiers* '((0 0) (1 1) (2 1) (3 2) (4 2) (5 3) (6 3) (7 3))
  "The full volley's tier by the wings spent (n tier); 8: tier 4 (decision V8's five tiers 0 / 1-2 / 3-5 / 6-9 / 10+ cut to
the wings' 8, DUEL_LILLE_V3 rev. 1 [G]: 0 / 1-2 / 3-4 / 5-7 / 8).")
(defparameter *br-rc0-dmg* 30 "Volley tier 0 空收: one 萬物貫通 line (decision V8: 30).")
(defparameter *br-rc1-dmg* 35 "Volley tier 1 二連: each of two lines (decision V8: 70 in all).")
(defparameter *br-rc2-dmg* 37 "Volley tier 2 四連: each of the first three lines ...")
(defparameter *br-rc2-last* 49 "... and the launching fourth (3 x 37 + 49 = 160, decision V8).")
(defparameter *br-rc3-dmg* 43 "Volley tier 3 裁き: each of the first four lines ...")
(defparameter *br-rc3-last* 128 "... and the fifth (4 x 43 + 128 = 300, decision V8).")
(defparameter *br-rc4-dmg* 40 "Volley tier 4 裁き・極: each of the six beats ...")
(defparameter *br-rc4-last* 240 "... and the beam at f48, a knockdown (6 x 40 + 240 = 480, decision V8).")
(defparameter *br-rc4-clip* :br-rc4 "The clip :BR-RC4 plays (its own, drawn 2026-10-10; the owl's :br-o-rc4 through the clip map).")
(defparameter *br-rc-stun* 28 "The volley's lines before the last stagger this many frames: the next line combos (new 2026-10-09 [G]).")
(defparameter *br-rc-track* 360.0 "Degrees / s he turns at the opponent through the volley (new 2026-10-09 [G]).")

;; the owl's SPs (the old KIN's, copied from lille.lisp under BR- names, 2026-10-09)
(defparameter *br-misuji-from* 1.0 "Owl SP1 裁きの光明: the ground line starts this many metres ahead (copied 2026-10-09) ...")
(defparameter *br-misuji-to* 18.0 "... and runs to this many (copied 2026-10-09).")
(defparameter *br-misuji-speed* 40.0 "... erupting outward at this many m/s (copied 2026-10-09).")
(defparameter *br-misuji-life* 24 "Frames each point of the line burns (copied 2026-10-09).")
(defparameter *br-misuji-width* 0.6 "The line's width, metres (copied 2026-10-09).")

;;; ================================================================ rules (pure: host-tested)
(defun br-owl-form-p (form) "Is FORM one of the owl's (KIN, EN)?" (and (member form '(:shin-kin :shin)) t))
(defun br-awake-form-p (form) "Is FORM awakened (JILLIEL's or the owl's, KIN or EN)?"
  (and (member form '(:jilliel-kin :jilliel :shin-kin :shin)) t))
(defun br-jilliel-form-p (form) "Is FORM one of JILLIEL's two?" (and (member form '(:jilliel-kin :jilliel)) t))
(defun br-ranged-form-p (form) "Is FORM the awakened stance EN (JILLIEL's or the owl's)?" (and (member form '(:jilliel :shin)) t))
(defun br-melee-form-p (form) "Is FORM an awakened attack state KIN (JILLIEL's or the owl's)?" (and (member form '(:jilliel-kin :shin-kin)) t))
(defun br-ranged-of (form) "The stance of FORM's pair (KIN -> EN; else FORM)." (case form (:jilliel-kin :jilliel) (:shin-kin :shin) (t form)))
(defun br-melee-of (form) "The attack state of FORM's pair (EN -> KIN; else FORM)." (case form (:jilliel :jilliel-kin) (:shin :shin-kin) (t form)))
(defun br-owl-switch (form burst)
  "The form a step's BURST (the running burst mode, or NIL) puts him in from FORM (decision R1: 「爆氣時會進入梟頭模式」): a
JILLIEL form in a burst its owl twin, an owl form out of one its JILLIEL twin, else NIL (no change; the base form's burst
is a plain burst)."
  (cond ((and burst (eq form :jilliel-kin)) :shin-kin)
        ((and burst (eq form :jilliel)) :shin)
        ((and (not burst) (eq form :shin-kin)) :jilliel-kin)
        ((and (not burst) (eq form :shin)) :jilliel)))

(defun br-x-hit-p (hw)
  "Does hit window HW carry 萬物貫通: an :x-axis line through guard (:uncatchable) with *BR-X-GUARD* / *BR-X-CHIP*?"
  (and (member :x-axis (hw-flags hw)) (member :uncatchable (hw-flags hw)) (member :ranged (hw-flags hw))
       (eql (hw-guard hw) *br-x-guard*) (hw-chip hw) (< (abs (- (hw-chip hw) *br-x-chip*)) 1e-6) t))

(defun br-ammo-cap (form) "The special resource's cap in FORM: the base's pips *BR-AMMO-MAX*, awakened the wings *BR-WING-MAX*."
  (if (br-awake-form-p form) *br-wing-max* *br-ammo-max*))
(defun br-ammo-add (n k form) "N specials + K, at most FORM's cap (BR-AMMO-CAP), never below 0." (max 0 (min (br-ammo-cap form) (+ n k))))
(defun br-l-gain (contact step)
  "The specials a stance L shot gives (decision R2: 「LL：回收特殊資源」): STEP 0 / 1 / 2 (L1 / L2 / L3) on CONTACT :hit or
:block,
*BR-S-L-GAIN*'s; a whiff 0."
  (if (member contact '(:hit :block)) (nth step *br-s-l-gain*) 0))
(defun br-recover-gain (contact role spent)
  "The flash step and Reiatsu a recovery move gives (decision R2: 「JJ：高額閃步/SP 量表恢復」; R3: its follow-up L L 「兩者都花
資源」): ROLE :j a J J move, :jl its L L follow-up (SPENT: a special was spent on it); CONTACT :hit in full, :block x
*BR-S-BLOCK*, else nothing. Values fs sp."
  (let ((k (case contact (:hit 1.0) (:block *br-s-block*) (t 0.0)))
        (extra (and (eq role :jl) spent)))
    (values (* k (+ *br-s-j-fs* (if extra *br-s-jl-fs* 0.0)))
            (* k (+ *br-s-j-sp* (if extra *br-s-jl-sp* 0.0))))))
(defun br-spend (n)
  "One special spent by a follow-up line (decision R2: 「每下花 1 翼」): values what is left and whether one was (N >= 1)."
  (if (>= n 1) (values (1- n) t) (values n nil)))
(defun br-follow-ok-p (n)
  "May a stance L L follow-up (J J -> L L, K K -> L L; decision R3) start with N specials: one to spend (none: the string
ends; 「沒有消耗資源的話就不能有遠距離攻擊」)?"
  (>= n 1))
(defun br-sp2-bonus (n form)
  "SP2's damage on top of its own for N specials spent in FORM (decision R3: 「花光全部，每單位加傷害」): the base's
*BR-SP2-UNIT* a pip, JILLIEL's *BR-W-SP2-UNIT* a wing; the owl's SP2 is the full volley (its tiers), 0 here."
  (cond ((br-owl-form-p form) 0) ((br-awake-form-p form) (* n *br-w-sp2-unit*)) (t (* n *br-sp2-unit*))))
(defun br-sp-tier (n form)
  "SP1 / SP2's tier (0-2) at N specials in FORM (decision R1, read not spent): *BR-SP-TIERS* (the wings), the base's
*BR-SP-TIERS-BASE* (the pips)."
  (destructuring-bind (a b) (if (br-awake-form-p form) *br-sp-tiers* *br-sp-tiers-base*)
    (cond ((>= n b) 2) ((>= n a) 1) (t 0))))
(defun br-sp1-fs (tier) "The flash step SP1 of TIER gives back (*BR-SP1-FS*)." (nth tier *br-sp1-fs*))
(defun br-armor-cost (form) "The wings his armour spends in FORM: the owl's *BR-OWL-ARMOR-WINGS*, else *BR-ARMOR-WINGS*."
  (if (br-owl-form-p form) *br-owl-armor-wings* *br-armor-wings*))
(defun br-armor-p (form kind phase wings)
  "Does a hit on him now meet the wing armour (decision R1: 「攻擊時如果被攻擊可以消耗四片翼使自己不會被打斷（不足時不觸發效果）」): an
awakened FORM, his own attack (move KIND :quick :flash :sig :sp, PHASE :main: startup to recovery; not a Breaker or a
Kikon rush) and WINGS >= its cost (BR-ARMOR-COST)? Fewer: never (「不足時不觸發」)."
  (and (br-awake-form-p form) (member kind '(:quick :flash :sig :sp)) (eq phase :main) (>= wings (br-armor-cost form)) t))
(defun br-recall-tier (n) "The full volley's tier (0-4) for N wings (*BR-RECALL-TIERS*; 8: 4)." (or (second (assoc n *br-recall-tiers*)) 4))
(defun br-recall-move (tier) "The volley string's move for TIER." (svref #(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4) tier))
(defun br-recall-damage (tier)
  "The damages of TIER's lines in order, before the form's x (the host test's view of the moves' windows)."
  (case tier
    (0 (list *br-rc0-dmg*)) (1 (list *br-rc1-dmg* *br-rc1-dmg*))
    (2 (list *br-rc2-dmg* *br-rc2-dmg* *br-rc2-dmg* *br-rc2-last*))
    (3 (list *br-rc3-dmg* *br-rc3-dmg* *br-rc3-dmg* *br-rc3-dmg* *br-rc3-last*))
    (t (append (make-list 6 :initial-element *br-rc4-dmg*) (list *br-rc4-last*)))))
(defun br-kamae-pick (cmd)
  "The base stance's move for its first press CMD (:kamae-l -j -k -sp1 -sp2 -step): the three strings' openers (decision R2),
the stance's SPs, its Step."
  (getf '(:kamae-l :br-s-l1 :kamae-j :br-s-j1 :kamae-k :br-s-k1 :kamae-sp1 :br-k-sanren :kamae-sp2 :br-k-hiren
          :kamae-step :br-k-dash)
        cmd))
(defun br-kamae-hold-over-p (sf held)
  "Does the stance (move frame SF, L HELD) end its hold now: past its tap with L up, before the held maximum?"
  (and (<= (+ *br-kamae-up* *br-kamae-tap*) sf) (< sf (+ *br-kamae-up* *br-kamae-max*)) (not held)))
(defun br-kamae-step-ok-p (dashed fs)
  "May the stance's Step (飛廉脚) start: not yet used in this stance (DASHED) and FS >= *BR-KAMAE-DASH-FS* (decision V6)?"
  (and (not dashed) (>= fs *br-kamae-dash-fs*)))
(defun br-dash-snap-p (sf) "May a J in the stance Step at its frame SF start the stance's J J: from *BR-DASH-SNAP-F*?" (>= sf *br-dash-snap-f*))
(defun br-misuji-span (age)
  "The burning part of a 裁きの光明 ground line AGE frames after it erupted: values from to (metres ahead)."
  (let* ((front (min *br-misuji-to* (+ *br-misuji-from* (* *br-misuji-speed* (/ age 60.0)))))
         (tail (max *br-misuji-from* (+ *br-misuji-from* (* *br-misuji-speed* (/ (- age *br-misuji-life*) 60.0))))))
    (values (min tail front) front)))
(defun br-misuji-frames () "A 裁きの光明 line's life." (+ (ceiling (* 60 (- *br-misuji-to* *br-misuji-from*)) *br-misuji-speed*) *br-misuji-life*))

;;; ================================================================ the two routes' strings (decision V8, kept)
(defun br-v8-shift (on-frame s0 ds)
  "ON-FRAME ((frame hook) ...) with every frame from the old startup S0 on moved by DS (the hit-frame hooks follow the hit)."
  (loop for (fr fn) in on-frame collect (list (if (>= fr s0) (+ fr ds) fr) fn)))
(defun br-v8-spec (route spec)
  "Decision V8 (the user 2026-10-10, the two routes): a J / K string move's SPEC (written with its old numbers) for ROUTE :J
(startup and recovery - *BR-J-SPEED*, floors *BR-J-MIN-S* / *BR-J-MIN-R*, damage x *BR-J-MULT*, block advantage +
*BR-J-ADV*), :JN (the awakened forms', decision R3: :J at the standard speed) or :K (startup and recovery + *BR-K-SLOW*, damage x *BR-K-MULT*, block advantage + *BR-K-ADV*; a K link's
:enter + (*BR-K-SLOW* - *BR-K-LINK-SLOW*)) or :KN (the awakened forms' K, R12: :K, its link's :enter + *BR-K-SLOW*: the
standard link, so J1 -> K2 / J2 -> K3 off the :JN J combo, the user 2026-10-11: 「覺醒的普通攻擊 J1 > K2 與 J2 > K3 現在 hits
計數會斷開」; a K link's effective startup 15 -> 14, the K -> K links too; K1 as :K); its hit-frame hooks follow the new startup; :clip-s the old startup. A
new plist."
  (let* ((j (member route '(:j :jn))) (std (eq route :jn)) (s0 (getf spec :startup)) (r0 (getf spec :recovery))
         (s1 (cond (std s0) (j (max *br-j-min-s* (- s0 *br-j-speed*))) (t (+ s0 *br-k-slow*))))
         (r1 (cond (std r0) (j (max *br-j-min-r* (- r0 *br-j-speed*))) (t (+ r0 *br-k-slow*))))
         (new (list :startup s1 :recovery r1
                    :dmg (round (* (getf spec :dmg) (if j *br-j-mult* *br-k-mult*)))
                    :adv-block (+ (getf spec :adv-block) (if j *br-j-adv* *br-k-adv*))
                    :on-frame (br-v8-shift (getf spec :on-frame) s0 (- s1 s0))
                    :enter (let ((n (or (getf spec :enter) 0)))
                             (if (and (not j) (plusp n)) (+ n (- *br-k-slow* (if (eq route :kn) 0 *br-k-link-slow*))) n))
                    :clip-s (or (getf spec :clip-s) s0))))
    (append new (loop for (k v) on spec by #'cddr unless (member k '(:startup :recovery :dmg :adv-block :on-frame :clip-s :enter))
                      append (list k v)))))
(defmacro br-defstring (route name &rest spec)
  "DEFMOVE for one of his attack-state J (ROUTE :J) / K (:K) string links: SPEC with the old numbers, BR-V8-SPEC applies V8."
  `(register-move ',name (br-v8-spec ,route ',spec)))

;; the stance's three strings in one form (decision R2, revised by R3, the user 2026-10-11): the openers L (L1 L2 L3), J
;; (J1 J2 J3), K (K1 K2 K3) are three segments of several quick plain shots each, 4 m (*BR-S-NEAR*: nothing spent, no long
;; reach), each string its own rhythm (「差異明顯的數段連擊」; 「JJ KK LL 都不表示只要二連擊，只是簡化多段攻擊的描述方式」): L even
;; taps, J rapid bursts, K heavy pairs; the J and K strings go on into L (JL1 JL2 JL3, KL1 KL2 KL3: 「統一銜接 LL，風格延續」;
;; three segments too, 「每段花 1，共 3」, the user 2026-10-11; 「最後一段 LL 會依據前面 J/K 有不同的動作模組」: their own clips,
;; barro-art.lisp's J route 疾射 / K route 重砲), one 萬物貫通 line a segment (31 m), each spending one special
;; (「兩者都花資源」; none: no follow-up, BR-FOLLOW-OK-P). Every segment of the J and K strings and their follow-ups that hit
;; cancels into the form's charge-less SP2 (:sp2c; 「SP2 接在 J 連段後面也可以」, 「任一段打中都能接」). CLIPS: a plist of
;; (clip authored-startup [charge-clip]) by segment (:l1 .. :kl3; the clip plays at authored / S speed; a charge clip, R10:
;; the move's :clip while L is held, the clip its :clip-2); ADV the owl's +1 (R one less).
(eval-when (:compile-toplevel :load-toplevel :execute)   ; (BR-DEFSTANCE reads it while it expands)
(defparameter *br-w-near-r* 0.4
  "The awakened stances' openers (decision R4, the user 2026-10-11: 「所有起手連段一律用近距離攻擊」): a wing / claw strike's
volume radius, metres; its reach each hit's drawn tip (*BR-W-TIPS*; new 2026-10-11 [G]).")
(defparameter *br-w-kb* 0.05
  "The awakened stances' melee openers (R4): each hit's push, metres (the shots' 0.3 pushed him out of a 1.4-2.2 m reach within
a string: L1 + L2 1.3 -> 2.3 m in the browser; new 2026-10-11 [G]).")
(defparameter *br-w-tips*
  '(("BR-S" ("J1" 1.9) ("J2" 1.9) ("J3" 1.9) ("K1" 2.6) ("K2" 2.5) ("K3" 2.6))   ; (R15: the gun-kata's muzzle, the rifle swung)
    ("BR-E" ("J1" 1.85) ("J2" 1.85) ("J3" 1.85) ("K1" 2.95) ("K2" 2.75) ("K3" 2.95))
    ("BR-OE" ("J1" 1.7) ("J2" 1.7) ("J3" 1.7) ("K1" 2.85) ("K2" 2.6) ("K3" 2.85)))
  "The awakened stances' melee openers (decision R4): each hit's reach, metres (its volume's edge), = the striking wing tip's
/ claw's distance ahead on that hit frame in its clip (barro-art.lisp :br-en-* / :br-oen-*, the host FK test: drawn reach =
hit reach, +-0.15 m). By the move prefix, then the segment. R5 (the user 2026-10-11: the motion modules, the reach
「跟著動作走」; 「長鞭可以連成大砍刀，砲擊也可以接在近距離毆打後面」): L 陀螺 the flat wing / claw (1.6-1.8 before), J 長鞭 the
stretched whip's tip (*BR-W-STRETCH*; 1.35-1.7 before) and J3's last the cleaver it stiffens into, K1 大刀 the joined great
blade, K2 / K3's first two the folded wings' close blows, K3's last 零距離砲擊 point blank (K 1.5-2.2 before). R6 / R7
(DUEL_LILLE_V3 §11, §12: one hit a press): one reach a segment; J3 and K1 the one-wing great blade swung grown (J3 2.4, K1
2.0 / 1.75 before), J2 the left whip (2.8 / 2.75 before). R8 (§13): K1's charged slash lands its blade longer (stretch 1.0
/ 1.1 on the hit frame, 0.5 / 0.6 before: 2.45 / 2.35 -> 2.95 / 2.85); the body's squash (BR-DEFORM) never scales his
facing axis. R9 (§14): J the top's flat wing (1.85 / 1.7), K2 the backhand (2.75 / 2.6), K3 the overhead split (2.95 /
2.85); L the dash, no row.")
(defparameter *br-s-l-whiff* 8
  "A whiffed stance L segment recovers R + this (decision R5, the user 2026-10-11: 「架式 > L 只要沒打中就進入硬直」, 「就跟一般的
J / K 普攻一樣」: a J link's *WHIFF-EXTRA-J*; the :sig moves' *WHIFF-EXTRA* 6 before).")
(defparameter *br-w-segs*
  '(("K1" 16 18) ("K3" 18 22))
  "The awakened stances' melee openers timed apart from *BR-S-SEGS*: name, startup, recovery (decision R6, the user
2026-10-11: 「大砍刀的動作要更緩慢沉重」; one hit a press since R7; R9: the great sword is K's whole string, J3 back to 8): K1 the
charged slash (startup 12 -> 16), K3 the turn and the overhead split (12 -> 18) ([G]).")
(defparameter *br-s-kata-segs*
  '(("J1" 10 14) ("J2" 10 14) ("J3" 10 16))
  "The base stance's J, the gun-kata, timed apart from *BR-S-SEGS*: name, startup, recovery (R16, the user 2026-10-12: 「架勢 J 的
槍鬥術跟普通攻擊的 J3 幫我插入更多關鍵幀並放慢一些速度」: startup 8 -> 10, recovery 12 / 12 / 14 -> 14 / 14 / 16; [G]).")
(defparameter *br-snipe-s1* 16
  "The base stance's L at the charge level 1 (R16, the user 2026-10-12: 「增加第 1 階 L 射擊的前搖」): its startup after the
release, 8 -> 16 (levels 2 / 3, the copies :br-s-l1-2 / -3, keep 8: their wind-up was the charge; [G]).")
(defparameter *br-w-dash-f* 8
  "The awakened stance's L (decision R9, the user 2026-10-11: 「八翼往後收、身體前傾高速衝向對手，如果有碰到對手就穿過對方並造
成連續斬擊」): the dash's frames from S (its hit window the same frames + 2) ...")
(defparameter *br-w-dash-past* 1.6 "... it ends this far past him (m) ...")
(defparameter *br-w-dash-min* 2.0 "... at least this long (m) ...")
(defparameter *br-w-dash-max* 6.0 "... at most this long (m: farther, it stops short) ...")
(defparameter *br-w-dash-reach* 0.9 "... its hit volume: from him to this far ahead ...")
(defparameter *br-w-dash-r* 0.7 "... this wide (m: his body, the folded wings; the drawn reach is the dash) ([G]).")
(defparameter *br-w-l-hold* 60
  "The awakened L dash (decision R10, the user 2026-10-11: 「L 衝刺改成只能衝一次不能連接，但可以三階段續力，隨著續力階段增加衝
刺距離與交叉斬痕（增加傷害）並提昇特殊資源回收量」): L held at most this many frames before the dash ([G]) ...")
(defparameter *br-w-l-levels* '(20 40) "... held this many frames: level 2, level 3 (else 1) ...")
;; (R10: above BARRO-HIT, which reads the gain)
(defparameter *br-w-l-dash-max* '(6.0 8.0 10.0) "The L dash's longest by its level 1 / 2 / 3, metres ([G]) ...")
(defparameter *br-w-l-cuts* '(2 4 6)
  "... its hits by the level (R11, DUEL_LILLE_V3 §16, the user 2026-10-11: 「我希望衝刺 L 依據蓄力階段給出多段的斬擊特效與 combo
計數」): the dash's touch, then the cuts that appear on him once it passed him (BR-W-CUTS), *BR-W-CUT-DMG* each: 16 / 32 / 48
before the form's x and the combo scaling (R10: one hit 16 + 0 / 16 / 32) ...")
(defparameter *br-w-cut-dmg* 8 "... each hit's damage ...")
(defparameter *br-w-cut-step* 3 "... the cuts this many frames apart (+ each hit's hitstop, *BR-W-CUT-HS*), the first one frame after the dash's end ...")
(defparameter *br-w-cut-hs* 2 "... each cut's hitstop (frames; a Quick hit's 4: the cuts come fast) ...")
(defparameter *br-w-cut-life* 14 "... each cut's look this many frames from its hit ...")
(defparameter *br-w-l-gain* '(1 2 3) "... the specials (wings) its hit or block gives (the string's +1 before) ([G]).")
(defparameter *br-w-l-slow* 1.5
  "The awakened stance's L segments: startup and hit spacing x this (decision R4, the user 2026-10-11: 「架式 L 的動作太快了」,
「出手和間隔都放慢」: startup 8 -> 12, L1 / L2 every 8 -> 12 f, L3 every 6 -> 9 f; [G]).")
(defparameter *br-s-segs*
  ;; name kind startup hit-offsets recovery damage react-between react-last role extra
  ;; (decision R7, the user 2026-10-11: 「我希望段數跟操作時的點擊次數一致，這樣玩家才能輕鬆確認到底打到哪一段」: one hit a
  ;; segment, a press; the openers had 2-4 hits a segment before)
  '(("L1" :sig 8 (0) 14 *br-s-l-dmg* :flinch :flinch :l (:gain 0))
    ("L2" :sig 8 (0) 14 *br-s-l-dmg* :flinch :flinch :l (:gain 1))
    ("L3" :sig 8 (0) 18 *br-s-l3-dmg* :stagger :stagger :l (:gain 2 :end t))
    ("J1" :quick 8 (0) 12 *br-s-j-dmg* :flinch :flinch :j nil)
    ("J2" :quick 8 (0) 12 *br-s-j-dmg* :flinch :flinch :j nil)
    ("J3" :quick 8 (0) 14 *br-s-j-dmg* :stagger :stagger :j (:end t))
    ("K1" :flash 12 (0) 18 *br-s-k-dmg* :stagger :stagger :k nil)
    ("K2" :flash 12 (0) 18 *br-s-k-dmg* :stagger :stagger :k nil)
    ("K3" :flash 12 (0) 22 *br-s-k3-dmg* :stagger :stagger :k (:end t))
    ("JL1" :sig 8 (0) 14 *br-s-jl-dmg* :flinch :flinch :jl (:spend t))
    ("JL2" :sig 8 (0) 14 *br-s-jl-dmg* :flinch :flinch :jl (:spend t))
    ("JL3" :sig 8 (0) 16 *br-s-jl-dmg* :knockback :knockback :jl (:spend t :end t))
    ("KL1" :sig 10 (0) 16 *br-s-kl-dmg* :stagger :stagger :kl (:spend t))
    ("KL2" :sig 10 (0) 16 *br-s-kl-dmg* :stagger :stagger :kl (:spend t))
    ("KL3" :sig 10 (0) 20 *br-s-kl-dmg* :knockback :knockback :kl (:spend t :end t)))
  "The stance's moves (BR-DEFSTANCE, decision R3 [G]): name, kind, startup, the hits' frames after it (a 2-frame window
each), recovery, damage a hit, the reaction of the hits before the last and of the last, role, extra params (L's :gain
step, the follow-ups' :spend, a string's last segment :end: his CPU's SP2 call)."))
(defmacro br-defstance (prefix clips &key (adv 0) melee snipe (l-slow 1))
  "The stance's moves of PREFIX (*BR-S-SEGS*). CLIPS by segment; ADV the owl's +1 (R one less). MELEE (the awakened forms, R4:
「所有起手連段一律用近距離攻擊」): the openers (the segments that spend nothing) strike in reach (each hit its own melee volume,
*BR-W-TIPS*; not :ranged, no line drawn) instead of the 4 m shots. L-SLOW (R4: 「架式 L 的動作太快了」): the L segments' startup and their
hits' spacing x this (the clip slowed with them, its recovery as written); MELEE also times *BR-W-SEGS*' segments their own
way (R6). SNIPE (the base form, R15, DUEL_LILLE_V3 §19): its L the charged snipe (held, BR-S-SNIPE-RELEASE; its level 2 / 3
copies -L1-2 / -L1-3 after the form) instead of the dash, its J / K MELEE as the awakened forms'."
  (let ((l-slow (if (symbolp l-slow) (symbol-value l-slow) l-slow)))
    `(progn
       ,@(loop for (sn kind st00 offs00 r00 dmg mid last role extra) in *br-s-segs*
               unless (and (or melee snipe) (member sn '("L2" "L3") :test #'string=))   ; (R10: one charged L; R15 the base's)
               collect
               (let* ((ov (or (and (string= prefix "BR-S") (cdr (assoc sn *br-s-kata-segs* :test #'string=)))   ; (R16)
                              (and melee (cdr (assoc sn *br-w-segs* :test #'string=)))))
                      (st0 (if ov (first ov) st00)) (offs0 offs00) (r0 (if ov (second ov) r00))
                      (name (intern (format nil "~a-~a" prefix sn) :keyword))
                      (clip (getf clips (intern sn :keyword)))
                      (slow (if (eq role :l) l-slow 1))
                      (st (if (and snipe (eq role :l)) *br-snipe-s1* (round (* st0 slow))))   ; (R16: level 1's wind-up)
                      (offs (mapcar (lambda (o) (round (* o slow))) offs0))
                      (far (getf extra :spend))
                      (sniper (and snipe (eq role :l)))   ; (R15: the base's L the charged snipe, a shot)
                      (cut (and melee (not far) (not sniper)))
                      (dash (and cut (eq role :l)))   ; (R9: the awakened L a dash through him)
                      (r (max 4 (- r0 adv))) (a (if dash (+ 2 *br-w-dash-f*) (+ 2 (car (last offs)))))
                      (mid (if dash :stagger mid)) (last (if dash :stagger last))   ; (the dash's hit lands late: a stagger links)
                      (n (length offs)))
                 `(defmove ,name :kind ,kind :clip ,(or (third clip) (first clip)) :clip-s ,(second clip)
                    ,@(when (third clip) `(:clip-2 ,(first clip)))   ; (R10, DUEL_LILLE_V3 §15: the charge pose while held, the dash)
                    :startup ,st :active ,a :recovery ,r
                    ,@(when (eq role :l) `(:whiff ,(+ r *br-s-l-whiff*)))   ; (R5: a whiffed L recovers as a J link)
                    ,@(when (or dash sniper) '(:hold (0 *br-w-l-hold*)))   ; (R10: held to charge, 3 levels)
                    ,@(when sniper '(:release br-s-snipe-release))   ; (R15: its level, the level 2 / 3 copies)
                    :dmg ,(cond (dash '*br-w-cut-dmg*) (sniper '*br-snipe-dmg-1*) (t dmg)) :adv-block ,(max (+ -12 adv) (- 1 (+ a r))) :track ,(if (or sniper dash) 0.0 720.0)   ; (>= 1 f of blockstun; R18: the charged L aims where he faced)
                    :vol ,(cond (dash `(:cap 0.0 ,*br-w-dash-reach* 1.2 ,*br-w-dash-r*))
                                (cut `(:cap 0.4 ,(- (reduce #'max (cdr (assoc sn (cdr (assoc prefix *br-w-tips* :test #'string=))
                                                                                :test #'string=)))
                                                    *br-w-near-r*)
                                              1.2 ,*br-w-near-r*))
                                (far '(:cap 0.6 *br-x-len* 1.2 0.25))
                                (t '(:cap 0.6 *br-s-near* 1.2 0.25)))
                    :on-hit ,last :kb ,(if cut *br-w-kb* 0.3)
                    ,@(cond (far '(:chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable)))
                            (dash '(:flags (:through :step-branch)))   ; (R18: its charge takes Step, BR-SNIPE-STEP)
                            (cut nil)
                            (sniper '(:flags (:ranged :step-branch)))
                            (t '(:flags (:ranged))))
                    :hits ,(loop for o in offs for i from 1
                                 for tip in (if (and cut (not dash)) (cdr (assoc sn (cdr (assoc prefix *br-w-tips* :test #'string=))
                                                                :test #'string=))
                                                (make-list n))
                                 collect `(,(+ st o) ,(+ st o (if dash (+ 2 *br-w-dash-f*) 2)) :on-hit ,(if (= i n) last mid)
                                           ,@(when (and cut (not dash)) `(:vol (:cap 0.4 ,(- tip *br-w-near-r*) 1.2 ,*br-w-near-r*)))))
                    :tick br-s-tick
                    :on-frame ((0 ,(if far 'br-s-spend 'br-s-start))
                               ,@(when dash `((,st br-w-dash)))
                               ,@(unless cut (loop for o in offs collect `(,(+ st o) br-shot-fire))))
                    :params (:stance ,role :len ,(cond (far '*br-x-len*) (cut 2.0) (t '*br-s-near*)) ,@(when dash '(:dash t))
                             ,@(when sniper '(:charged t)) ,@extra)))))))
(defun br-stance-strings (prefix sp2 &optional melee)
  "The kit strings of PREFIX's stance (BR-DEFSTANCE): J1 -> J2 -> J3, K1 -> K2 -> K3 by the J / K latch; L1 -> L2 -> L3, J3 ->
JL1 -> JL2 -> JL3, K3 -> KL1 -> KL2 -> KL3 by BR-S-TICK's latch (command :lchain); every J / K / JL / KL segment that hit -> the form's
charge-less SP2 SP2 (:sp2c, decision R3)."
  (flet ((nm (s) (intern (format nil "~a-~a" prefix s) :keyword)))
    `((,(nm "J1") :q ,(nm "J2")) (,(nm "J2") :q ,(nm "J3")) (,(nm "K1") :f ,(nm "K2")) (,(nm "K2") :f ,(nm "K3"))
      ,@(unless melee `((,(nm "L1") :lchain ,(nm "L2")) (,(nm "L2") :lchain ,(nm "L3"))))   ; (R10: the awakened L one dash)
      (,(nm "J3") :lchain ,(nm "JL1")) (,(nm "JL1") :lchain ,(nm "JL2")) (,(nm "JL2") :lchain ,(nm "JL3"))
      (,(nm "K3") :lchain ,(nm "KL1")) (,(nm "KL1") :lchain ,(nm "KL2")) (,(nm "KL2") :lchain ,(nm "KL3"))
      ,@(loop for sg in '("J1" "J2" "J3" "JL1" "JL2" "JL3" "K1" "K2" "K3" "KL1" "KL2" "KL3") collect `(,(nm sg) :sp2c ,sp2)))))

;;; ================================================================ the base form
;; the J / K strings: the old Lille's frames and clips, decision V8 on top
(br-defstring :j :br-j1 :kind :quick :clip :lb-q1 :startup 8 :active 3 :recovery 12 :dmg 26 :adv-block -2
  :reach 1.45 :arc 100 :on-hit :flinch)
(br-defstring :j :br-j2 :kind :quick :clip :lb-q2 :startup 7 :active 3 :recovery 13 :dmg 22 :adv-block -2
  :reach 1.45 :arc 110 :on-hit :flinch)
;; (R16, the user 2026-10-12: 「普通攻擊的 J3 幫我插入更多關鍵幀並放慢一些速度」: its own clip :br-jab, startup 7 -> 10, recovery
;; 16 -> 18 after V8; Lille's :lb-jab is the old Lille's)
(br-defstring :j :br-j3 :kind :quick :clip :br-jab :clip-s 10 :startup 12 :active 3 :recovery 20 :dmg 28 :adv-block -4
  :reach 1.6 :arc 70 :on-hit :stagger :flags (:ender))
(br-defstring :k :br-k1 :kind :flash :clip :lb-f1 :startup 17 :active 4 :recovery 21 :dmg 48 :adv-block -3
  :reach 2.05 :arc 150 :on-hit :stagger)
(br-defstring :k :br-k2 :kind :flash :clip :lb-f2 :enter 6 :startup 20 :active 4 :recovery 24 :dmg 48 :adv-block -3
  :reach 2.05 :arc 100 :on-hit :stagger)
(br-defstring :k :br-k3 :kind :flash :clip :lb-f3 :enter 7 :startup 21 :active 5 :recovery 34 :dmg 70 :adv-block -20
  :reach 2.15 :arc 60 :on-hit :crumple :flags (:ender))
(defmove-copy :br-j2s :br-j2)
(defmove-copy :br-k2s :br-k2)
;; L 狙擊架式: up at f6, held 30 f (90 while L is held), R 14; turning 60 deg/s; from f6 the first L / J / K / SP1 / SP2 / Step
;; picks (BR-KAMAE-TICK). L after a J or K link opens it at f4 (not after a stance string: BARRO-OK)
(defmove :br-kamae :kind :sig :clip :lb-kamae :startup 6 :active 0 :recovery 104 :track 60.0 :tick br-kamae-tick
  :flags (:step-branch) :on-frame ((0 br-kamae-enter)))
(defmove-copy :br-kamae-k :br-kamae :enter 4 :on-frame ((4 br-kamae-enter)))
(defmove-copy :br-kamae-j :br-kamae :enter 4 :on-frame ((4 br-kamae-enter)))
(defmove-copy :br-kamae-re :br-kamae :enter *br-kamae-up* :on-frame nil)
(defmove :br-k-dash :kind :sig :clip :lb-k-dash :startup *br-kamae-dash-f* :active 0 :recovery 0 :tick br-k-dash-tick
  :on-frame ((0 br-kamae-dash) (*br-kamae-back* br-kamae-back)))
;; (R18, DUEL_LILLE_V3 §23) the awakened stance's fast Step out of its L dash's charge: the base Step's frames and flash step,
;; the stance's step clip, no J cancel; back in the charge at its f9 (BR-KAMAE-BACK)
(defmove-copy :br-w-charge-step :br-k-dash :clip :sh-step-b :tick nil)
;; the stance's strings (decision R3), Diagramm's shots, each segment its own clip at its frames (barro-art.lisp, the base
;; stance's strings): L shouldered (GATHER), J one-handed from the hip (REFILL), K braced at the waist (HEAVY); the J route's
;; L L 疾射 one-handed (a whip, a spin, a hop), the K route's 重砲 two-handed (a stamp, a kneel, the finisher from the knee)
(br-defstance "BR-S" (:l1 (:br-sk-l1s 16 :br-sk-lc) :j1 (:br-sk-j1 10) :j2 (:br-sk-j2 10)
                      :j3 (:br-sk-j3 10) :k1 (:br-sk-k1 16) :k2 (:br-sk-k2 12) :k3 (:br-sk-k3 18)
                      :jl1 (:br-sk-jl1 8) :jl2 (:br-sk-jl2 8) :jl3 (:br-sk-jl3 8) :kl1 (:br-sk-kl1 10) :kl2 (:br-sk-kl2 10)
                      :kl3 (:br-sk-kl3 10))
  :melee t :snipe t)   ; (R15, DUEL_LILLE_V3 §19: 「用覺醒狀態的系統邏輯與動作模組的設計風格重製常態模式」)
;; the base stance's L, charged (R15): its level 2 / 3 shots, started by BR-S-SNIPE-RELEASE on the release (no hold)
;; (R16: their startup 8, level 1's *BR-SNIPE-S1* not theirs: its hit and its shot at 8)
(defmove-copy :br-s-l1-2 :br-s-l1 :hold nil :release nil :clip :br-sk-l1 :clip-2 nil :dmg *br-snipe-dmg-2*
  :startup 8 :clip-s 8 :hits ((8 10 :on-hit :flinch)) :on-frame ((0 br-s-start) (8 br-shot-fire))
  :vol (:cap 0.6 *br-snipe-len-2* 1.2 0.25) :params (:stance :l :charged t :len *br-snipe-len-2*))
(defmove-copy :br-s-l1-3 :br-s-l1 :hold nil :release nil :clip :br-sk-l1 :clip-2 nil :dmg *br-snipe-dmg-3*
  :startup 8 :clip-s 8 :hits ((8 10 :on-hit :flinch)) :on-frame ((0 br-s-start) (8 br-shot-fire))
  :vol (:cap 0.6 *br-x-len* 1.2 0.25) :chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable :step-branch)
  :params (:stance :l :charged t :len *br-x-len*))
;; the stance's SPs: SANREN's three 萬物貫通 lines, HIRENKYAKU's slide and shot; outside the stance the plain ones (20 m, no
;; 萬物貫通). SP1 gives flash step back by the pips (BR-SP1-FS-GO); SP2 spends every pip, + *BR-SP2-UNIT* each (BR-SP2-SPEND,
;; decision R3), its recovery + *BR-SP2-SLOW-R* (22 -> 42) and -30 on block (「單發破綻大」); off a stance K K that hit
;; the charge-less :br-k-hiren-c (「必須接在 KK 後執行」)
(defmove :br-k-sanren :kind :sp :clip :lb-sanren :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg *br-k-sanren-dmg*
  :adv-block -14 :track 90 :vol (:cap 0.6 *br-x-len* 1.2 0.25) :on-hit :flinch :kb 0.5 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len *br-x-len*))
(defmove :br-k-hiren :kind :sp :clip :lb-hiren :callout "HIRENKYAKU" :startup 20 :active 2 :recovery 42 :dmg *br-k-hiren-dmg*
  :adv-block -30 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.25) :on-hit :stagger :kb 1.0 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :tick br-slide-tick :on-frame ((0 br-sp2-spend) (0 br-slide) (20 br-shot-fire))
  :params (:slide 6.0 :slide-f 14 :lock 14 :len *br-x-len*))
(defmove-copy :br-k-hiren-c :br-k-hiren :enter 18 :on-frame ((18 br-sp2-spend) (20 br-shot-fire)))
(defmove :br-sanren :kind :sp :clip :lb-sanren :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg *br-sanren-dmg*
  :adv-block -14 :track 90 :vol (:cap 0.6 *br-plain-len* 1.2 0.25) :on-hit :flinch :kb 0.5 :flags (:ranged)
  :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len *br-plain-len*))
(defmove :br-hiren :kind :sp :clip :lb-hiren :callout "HIRENKYAKU" :startup 20 :active 2 :recovery 42 :dmg *br-hiren-dmg*
  :adv-block -30 :track 0 :vol (:cap 0.6 *br-plain-len* 1.2 0.25) :on-hit :stagger :kb 1.0 :flags (:ranged)
  :tick br-slide-tick :on-frame ((0 br-sp2-spend) (0 br-slide) (20 br-shot-fire))
  :params (:slide 6.0 :slide-f 14 :lock 14 :len *br-plain-len*))
(defmove :br-breaker :kind :breaker :clip :lb-breaker :clip-2 :lb-butt :callout "SHOBI-UCHI")
(defmove :br-kikon :kind :kikon :clip :lb-aim :clip-2 :lb-fire :clip-s 4 :callout "BANBUTSU KANTSU" :cine lb-kikon-cine
  :startup 20 :active 3 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 12.0 1.2 1.2)
  :on-hit :knockback :kb 2.0 :cooldown 90 :on-frame ((20 br-lane-shot))
  :params (:aura 8 :aim 120.0 :speed 0.0 :dash-max 0 :dash-track 0.0 :look :lane :follow-speed 14.0 :len 12.0))

;;; ================================================================ JILLIEL
;; KIN, the attack state: the wing blades (plain strings: no resource in or out, decision R1 「避免同質化」)
(br-defstring :jn :br-w-j1 :kind :quick :clip :lb-w-q1 :startup 8 :active 3 :recovery 12 :dmg 24 :adv-block -2
  :reach 1.6 :arc 110 :on-hit :flinch)
(br-defstring :jn :br-w-j2 :kind :quick :clip :lb-w-q2 :startup 7 :active 3 :recovery 13 :dmg 24 :adv-block -2
  :reach 1.6 :arc 110 :on-hit :flinch)
(br-defstring :jn :br-w-j3 :kind :quick :clip :lb-w-q3 :startup 9 :active 3 :recovery 18 :dmg 30 :adv-block -4
  :reach 1.7 :arc 120 :on-hit :stagger :flags (:ender))
(br-defstring :kn :br-w-k1 :kind :flash :clip :lb-w-f1 :startup 17 :active 4 :recovery 21 :dmg 50 :adv-block -3
  :reach 2.2 :arc 150 :on-hit :stagger)
(br-defstring :kn :br-w-k2 :kind :flash :clip :lb-w-f2 :enter 6 :startup 20 :active 4 :recovery 24 :dmg 50 :adv-block -3
  :reach 2.2 :arc 110 :on-hit :stagger)
(br-defstring :kn :br-w-k3 :kind :flash :clip :lb-w-f3 :enter 7 :startup 21 :active 5 :recovery 34 :dmg 72 :adv-block -20
  :reach 2.3 :arc 90 :on-hit :crumple :flags (:ender))
(defmove-copy :br-w-j2s :br-w-j2)
(defmove-copy :br-w-k2s :br-w-k2)
;; SP1 SANREN on his wings (3 lines 20 m, 30 each, chip 15 %, guard 12; flash step back by the wings) and SP2 NIJUSHI-KO (the
;; 40 f tell, a 1.2 m beam; 180 -> 60 + *BR-W-SP2-UNIT* a wing spent, every wing spent, decision R3; R 30 -> 50, -30 on
;; block; off a stance K K that hit the charge-less :br-w-nijushi-c)
(defmove :br-w-sanren :kind :sp :clip :lb-w-sanren :clip-s 12 :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg 30
  :adv-block -14 :track 90 :vol (:cap 0.6 20.0 1.2 0.25) :on-hit :flinch :kb 0.5 :chip 0.15 :guard 12
  :flags (:ranged :x-axis :uncatchable) :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len 20.0))
(defmove :br-w-nijushi :kind :sp :clip :lb-w-nijushi :callout "NIJUSHI-KO" :startup 40 :active 6 :recovery 50 :dmg 60
  :adv-block -30 :track 0 :vol (:cap 0.6 31.0 1.2 1.2) :on-hit :knockback :kb 2.0 :chip 0.15 :guard 45
  :flags (:ranged :x-axis :uncatchable) :tick br-planted-tick
  :on-frame ((0 br-sp2-spend) (0 br-nijushi-tell) (40 br-beam-shot)) :params (:lock 20 :track 60.0 :width 1.2))
(defmove-copy :br-w-nijushi-c :br-w-nijushi :enter 38
  :on-frame ((38 br-sp2-spend) (38 br-nijushi-tell) (40 br-beam-shot)))
;; L into the stance (12 f, EN at f11): from neutral or a J / K link alike (decision R3: 「JJ 與 KK 接入 L 不再有特殊動作，只是
;; 普通的接入架式」: J3 -> L's backstep and the owl's K3 -> L volley gone)
(defmove :br-to-en :kind :sig :clip :br-to-en :callout "EN" :startup *br-to-en-f* :active 0 :recovery 0 :tick br-halt-tick
  :on-frame ((0 br-stance-arm) (11 br-go-ranged)))
;; ... off a KIN J / K link (L after J / K, R17, DUEL_LILLE_V3 §21: 「如果是從普攻 J/K 按 L 切入架勢並直接接入架勢 J1/K1/L 發
;; 動攻擊的話，就取消切架勢的前後搖，使連段能銜接起來」): a J / K / L pressed in it skips the turn (BR-TO-EN-LINK-TICK)
(defmove-copy :br-to-en-l :br-to-en :tick br-to-en-link-tick)
(defmove :br-recall :kind :sig :clip :br-recall :callout "KAISHU" :startup *br-recall-f* :active 0 :recovery 0
  :tick br-halt-tick :on-frame ((0 br-recall-go) (7 br-recall-fire)))
;; the full volley's strings: every line 萬物貫通 from him at the opponent (BR-RC-TICK keeps him on him); the owl's SP2
;; since R3: every recovery + *BR-SP2-SLOW-R* (24 / 24 / 24 / 26 / 30 -> 44 / 44 / 44 / 46 / 50, 「單發破綻大」)
(defmove :br-rc0 :kind :sig :clip :br-rc0 :callout "KAISHU" :startup 6 :active 2 :recovery 44 :dmg *br-rc0-dmg* :adv-block -14
  :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 1.0 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :tick br-rc-tick :on-frame ((6 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc1 :kind :sig :clip :br-rc1 :callout "NIREN" :startup 6 :active 12 :recovery 44 :dmg *br-rc1-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.5 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :hits ((6 8 :stun *br-rc-stun*) (16 18)) :tick br-rc-tick
  :on-frame ((6 br-rc-shot) (16 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc2 :kind :sig :clip :br-rc2 :callout "YONREN" :startup 6 :active 28 :recovery 44 :dmg *br-rc2-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.3 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable)
  :hits ((6 8 :stun *br-rc-stun*) (14 16 :stun *br-rc-stun*) (22 24 :stun *br-rc-stun*) (32 34 :dmg *br-rc2-last* :on-hit :launch))
  :tick br-rc-tick :on-frame ((6 br-rc-shot) (14 br-rc-shot) (22 br-rc-shot) (32 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc3 :kind :sig :clip :br-rc3 :callout "SABAKI" :startup 6 :active 32 :recovery 46 :dmg *br-rc3-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.3 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable)
  :hits ((6 8 :stun *br-rc-stun*) (12 14 :stun *br-rc-stun*) (18 20 :stun *br-rc-stun*) (24 26 :stun *br-rc-stun*)
         (36 38 :dmg *br-rc3-last* :on-hit :knockback :kb 2.0))
  :tick br-rc-tick :on-frame ((6 br-rc-shot) (12 br-rc-shot) (18 br-rc-shot) (24 br-rc-shot) (36 br-beam-shot))
  :params (:lock 0 :len *br-x-len* :width 1.2))
(defmove :br-rc4 :kind :sig :clip *br-rc4-clip* :callout "SABAKI KIWAMI" :startup 6 :active 44 :recovery 50 :dmg *br-rc4-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.3 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable)
  :hits ((6 8 :stun *br-rc-stun*) (12 14 :stun *br-rc-stun*) (18 20 :stun *br-rc-stun*) (24 26 :stun *br-rc-stun*)
         (30 32 :stun *br-rc-stun*) (36 38 :stun *br-rc-stun*)
         (48 50 :dmg *br-rc4-last* :on-hit :knockdown :kb 2.0))
  :tick br-rc-tick :on-frame ((6 br-rc-shot) (12 br-rc-shot) (18 br-rc-shot) (24 br-rc-shot) (30 br-rc-shot) (36 br-rc-shot)
                              (38 br-nijushi-tell) (48 br-beam-shot))
  :params (:lock 0 :len *br-x-len* :width 1.2))
(defmove :br-w-breaker :kind :breaker :clip :lb-w-breaker :clip-2 :lb-w-ram :callout "JILLIEL")
(defmove :br-w-kikon :kind :kikon :clip :lb-w-kikon :clip-2 :lb-w-kikon-fire :callout "KAMI NO SABAKI"
  :cine lb-jilliel-kikon-cine :startup 20 :active 3 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0
  :vol (:cap 0.5 12.0 1.2 1.2) :on-hit :knockback :kb 2.0 :cooldown 90 :on-frame ((20 br-lane-shot))
  :params (:aura 8 :aim 120.0 :speed 0.0 :dash-max 0 :dash-track 0.0 :look :lane :follow-speed 14.0 :len 12.0))
;; EN, the stance (decision R3: 「架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊」): the strings' own clips (barro-art.lisp
;; :br-en-*: L the gathering casts, J the rapid flicks, K the heavy throws; the follow-ups :br-e-jf* 疾射 / :br-e-kf* 重砲,
;; 「最後一段 LL 會依據前面 J/K 有不同的動作模組」); the openers wing strikes in reach (R4, the user 2026-10-11: 「所有起手連段一律用
;; 近距離攻擊」), L slower (「架式 L 的動作太快了」: *BR-W-L-SLOW*)
(br-defstance "BR-E" (:l1 (:br-en-l1 8 :br-en-lc) :j1 (:br-en-j1 8) :j2 (:br-en-j2 8)
                      :j3 (:br-en-j3 8) :k1 (:br-en-k1 16) :k2 (:br-en-k2 12) :k3 (:br-en-k3 18)
                      :jl1 (:br-e-jf1 8) :jl2 (:br-e-jf2 8) :jl3 (:br-e-jf3 8) :kl1 (:br-e-kf1 10) :kl2 (:br-e-kf2 10)
                      :kl3 (:br-e-kf3 10))
              :melee t :l-slow *br-w-l-slow*)

;;; ================================================================ the owl: the burst's form (decision R1)
(br-defstring :jn :br-o-j1 :kind :quick :clip :lb-o-q1 :startup 8 :active 3 :recovery 11 :dmg 26 :adv-block -1
  :reach 1.7 :arc 110 :on-hit :flinch)
(br-defstring :jn :br-o-j2 :kind :quick :clip :lb-o-q2 :startup 7 :active 3 :recovery 12 :dmg 26 :adv-block -1
  :reach 1.7 :arc 110 :on-hit :flinch)
(br-defstring :jn :br-o-j3 :kind :quick :clip :lb-o-q3 :startup 9 :active 3 :recovery 17 :dmg 32 :adv-block -3
  :reach 1.7 :arc 120 :on-hit :stagger :flags (:ender))
(br-defstring :kn :br-o-k1 :kind :flash :clip :lb-o-f1 :startup 17 :active 4 :recovery 20 :dmg 54 :adv-block -2
  :reach 2.3 :arc 150 :on-hit :stagger :tick br-s-tick :on-frame ((0 br-s-start)))
(br-defstring :kn :br-o-k2 :kind :flash :clip :lb-o-f2 :enter 6 :startup 20 :active 4 :recovery 23 :dmg 54 :adv-block -2
  :reach 2.3 :arc 110 :on-hit :stagger :tick br-s-tick :on-frame ((8 br-s-start)))   ; (its :enter, 6 + 2: :KN, R12)
(br-defstring :kn :br-o-k3 :kind :flash :clip :lb-o-f3 :enter 7 :startup 21 :active 5 :recovery 33 :dmg 78 :adv-block -19
  :reach 2.3 :arc 90 :on-hit :crumple :flags (:ender) :tick br-s-tick :on-frame ((9 br-s-start)) :params (:end t))   ; (7 + 2)
(defmove-copy :br-o-j2s :br-o-j2)
(defmove-copy :br-o-k2s :br-o-k2)
;; SP1 裁きの光明 (the old MISUJI: three ground lines at -20 / 0 / +20 deg, one hit group, 70 each, 18 m; flash step back by
;; the wings)
(defmove :br-misuji :kind :sp :clip :lb-o-chop :clip-s 16 :callout "SABAKI NO KOMYO" :startup 18 :active 0 :recovery 25
  :reach 18.0 :track 90 :on-frame ((0 br-sp1-fs-go) (18 br-misuji)) :params (:dmg 70 :guard 18 :fan (-20.0 0.0 20.0)))
;; SP2 the full volley (decision R3: 「併入梟頭的 SP2」; Trompete gone): every wing spent, the tiers by the count; on its
;; own a *BR-RECALL-CHARGE* wind-up (NIJUSHI-KO's glow its tell), off a stance K K that hit the quick :br-recall
(defmove-copy :br-recall-s :br-recall :callout "KAISHU" :startup *br-recall-charge*
  :on-frame ((0 br-recall-go) (0 br-nijushi-tell) (*br-recall-charge-fire* br-recall-fire)))
(defmove :br-o-breaker :kind :breaker :clip :lb-o-breaker :clip-2 :lb-o-stamp :callout "KAGIZUME")
(defmove :br-o-kikon :kind :kikon :clip :lb-o-trompete :clip-2 :lb-o-chop :clip-s 4 :callout "TROMPETE"
  :cine lb-trompete-cine :startup 20 :active 3 :recovery 30 :whiff 30 :dmg 80 :adv-block -14 :track 0
  :vol (:cap 0.5 12.0 1.4 1.4) :on-hit :knockback :kb 2.0 :cooldown 90 :on-frame ((20 br-lane-shot))
  :params (:aura 10 :aim 120.0 :speed 0.0 :dash-max 0 :dash-track 0.0 :look :lane :follow-speed 14.0 :len 12.0))
;; the owl's stance EN: the same strings on its claws (barro-art.lisp :br-oen-*, the follow-ups :br-oe-jf* / -kf*; R one
;; less: *BR-OWL-ADV*); the openers claw strikes in reach, L slower (R4)
(br-defstance "BR-OE" (:l1 (:br-oen-l1 8 :br-oen-lc) :j1 (:br-oen-j1 8) :j2 (:br-oen-j2 8)
                       :j3 (:br-oen-j3 8) :k1 (:br-oen-k1 16) :k2 (:br-oen-k2 12) :k3 (:br-oen-k3 18)
                       :jl1 (:br-oe-jf1 8) :jl2 (:br-oe-jf2 8) :jl3 (:br-oe-jf3 8) :kl1 (:br-oe-kf1 10) :kl2 (:br-oe-kf2 10)
                       :kl3 (:br-oe-kf3 10))
              :adv 1 :melee t :l-slow *br-w-l-slow*)

;;; His own moves' clips (barro-art.lisp): the owl's twins through its kits' :clip-map
(defparameter *br-owl-clip-map* '(:br-recall :br-o-recall :br-rc0 :br-o-rc0 :br-rc1 :br-o-rc1 :br-rc2 :br-o-rc2
                                  :br-rc3 :br-o-rc3 :br-rc4 :br-o-rc4 :br-to-en :br-o-to-en)
  "The owl kits' :clip-map: the shared moves (the volley, its strings, the turn) on the claws' own clips.")

;;; ================================================================ forms
(defparameter *barro-hooks* '(:tick barro-tick :ok barro-ok :hit barro-hit :struck barro-struck :armor barro-armor
                               :step barro-step :draw br-draw :pose br-deform :charge br-charge)
  "His mechanics (kit.lisp KIT-HOOK): the burst owl, the owl's wings, the stance's end (:tick); the stance links (:ok); the
specials and the recovery shots' gains (:hit); the wing armour's price (:struck) and its test (:armor, fighter.lisp
DEFENDER-STATE); EN's fast Step (:step, decision R3); his looks (:draw, barro-art.lisp) and his body's squash and stretch (:pose, BR-DEFORM: R8, DUEL_LILLE_V3 §13);
the base stance's snipe charge at the muzzle (:charge, BR-CHARGE, a look in place of the generic fire charge: R15, §19).")

(defparameter *br-kamae-strings*
  (append (loop for s in '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
                append (loop for c in '(:kamae-l :kamae-j :kamae-k :kamae-sp1 :kamae-sp2 :kamae-step)
                             collect (list s c (br-kamae-pick c))))
          '((:br-k-dash :kamae-back :br-kamae-re) (:br-k-dash :kamae-j :br-s-j1))
          (br-stance-strings "BR-S" :br-k-hiren-c t))   ; (R15: one charged L, no L link)
  "The base stance's picks: non-button strings (KIT-NEXT) its :tick starts (BR-KAMAE-TICK); the Step, its way back into the
stance and its J (the stance's J J); the stance's three strings (BR-DEFSTANCE).")
(defparameter *br-melee-strings*
  (append '((:br-recall :rc0 :br-rc0) (:br-recall :rc1 :br-rc1) (:br-recall :rc2 :br-rc2) (:br-recall :rc3 :br-rc3)
            (:br-recall :rc4 :br-rc4))
          (br-stance-strings "BR-E" :br-w-nijushi-c t) (br-stance-strings "BR-OE" :br-recall t)
          ;; the owl's own K string -> its charge-less SP2, the full volley (R4, the user 2026-10-11: 「爆氣後的 K 沒辦法連
          ;; SP2」; BR-S-TICK latches Shift+L, the move having hit)
          '((:br-o-k1 :sp2c :br-recall) (:br-o-k2 :sp2c :br-recall) (:br-o-k2s :sp2c :br-recall) (:br-o-k3 :sp2c :br-recall)))
  "The awakened forms' non-button strings: the volley's (the owl's SP2), the stances' strings and their K K / J J -> SP2 (every
awakened form inherits these).")

(defkit :barro :base
  :name "LILLE II" :body :lille :weapon :diagramm :stance :lb-stance :calm t
  :intro :lb-intro :win :lb-win :intro-callout "THE X-AXIS"
  :walk *br-walk* :run *br-run* :reishi *reishi-max* :swing-sfx :whoosh-light :mult *br-mult* :taken *br-taken*
  :commands (:q :br-j1 :f :br-k1 :sig :br-kamae :sp1 :br-sanren :sp2 :br-hiren :breaker :br-breaker :kikon :br-kikon)
  :grid (:br-j1 :br-j2 :br-j3 :br-k1 :br-k2 :br-k3 :br-j2s :br-k2s)
  :strings *br-kamae-strings*
  :l-after-k :br-kamae-k                        ; L after K1 / K2 / K3: the stance at f4 (the old rule)
  :l-after-j :br-kamae-j                        ; L after J1 / J2 / J3: the same (decision V9c)
  :awaken-form :jilliel-kin :kikon-konpaku 2 :hooks *barro-hooks*
  :ai (:intents (:approach 1 :pressure 1 :zone 5 :defend 1)            ; (round 2 b1a1: the line's distance; b1a0 2 2 3 1)
       :ranges (:approach (1.6 6.0) :pressure (1.2 2.6) :zone (6.0 12.0) :defend (4.0 8.0))
       :moves ((0.0 1.7 :q 4 :f 1 :breaker 1 :sig 2)                ; (J pokes confirm into the stance; L the stance's pick)
               (1.7 2.9 :f 1 :sig 3 :step 1)                        ; (the stance K, the rifle, reaches 2.6 m)
               (2.9 5.0 :step 2 :sig 1 nil 2)
               (5.0 99.0 :sig 2 nil 2))                             ; (the stance's snipe, charged by the distance)
       :guard 0.5 :hoho 0.3 :dash 0.6 :dash-back 0.3 :block-string 0.3 :o-ender 0.3 :l-after-k 1.0 :l-after-j 0.0 :kikon-range 0.0
       :string-k 1.0   ; (dream-rsi b2a0: a J link that hit -> its K link K2s (0.8 -> 1.0), whose hit -> L (:l-after-k 1.0)
                       ;  -> the rifle K K K and its L L lines; :l-after-j 1.0 -> 0.0 (b1a2's J -> L -> the gun-kata: 3 x 15
                       ;  off a confirm, the never-awakened base form's damage gone: its awaken A/B 0-1 of 60 vs K / R / S)
       :awaken (:min-taken 150) :reflex br-ai-reflex :sig-hold br-ai-sig-hold :sp-ender br-ai-keep-burst
       :far-snipe (:p (:easy 0.2 :normal 0.5 :hard 1.0) :in 4.5)
                                     ; (the stance from afar for the charged snipe or, the pips full, HIRENKYAKU; a window; b1a2 0.5 -> 0.7;
                                     ;  round 2 b1a0 :in 4.5 -> *BR-AI-SNIPE-MIN* 6: out of the CPUs' threat envelope;
                                     ;  round 2 b1a2 6 -> 4.5 back: the envelope's Step out now fires the re-aimed shot at
                                     ;  once, *BR-AI-STEP-FIRE-MIN*; the base backs off to 6.5 m still, BR-AI-BACK-TO;
                                     ;  b2a0: :p its own table, HARD as before)
       :neutral-guard 0.1            ; (b2a0 / round 2 b0a2: no long neutral guard for the opponents' Breaker-a-guard)
       :stance (:recover-fs 40.0 :recover-bars 1 :j-share 1.0 :step 0.4 :far 7.0 :charge (:easy 0.2 :normal 0.5 :hard 1.0)
                :punish 0.6 :follow (:easy 0.3 :normal 0.8 :hard 1.0) :sp2-at 0 :sp2 (:easy 0.3 :normal 0.6 :hard 1.0))))

;; JILLIEL KIN (the awakening enters it): the wing strings, SP1 by the wings, SP2 NIJUSHI-KO every wing spent, L into the
;; stance (from a link too: the plain turn, decision R3), U a guard (decision R1), a burst the owl (BARRO-TICK)
(defkit :barro :jilliel-kin :inherit :base
  :lift *br-jilliel-lift* :awakening t :form-name "JILLIEL KIN" :walk *br-walk-kin* :run *br-run-kin*
  :mult *br-jilliel-mult* :taken *br-jilliel-taken* :kikon-konpaku 3 :endless-form :jilliel-kin
  :body :lille-jilliel-kin :weapon nil :stance :lb-w-stance :cine lb-jilliel-cine :swing-sfx :whoosh-heavy
  :commands (:q :br-w-j1 :f :br-w-k1 :sig :br-to-en :sp1 :br-w-sanren :sp2 :br-w-nijushi :breaker :br-w-breaker
             :kikon :br-w-kikon)
  :grid (:br-w-j1 :br-w-j2 :br-w-j3 :br-w-k1 :br-w-k2 :br-w-k3 :br-w-j2s :br-w-k2s)
  :strings *br-melee-strings*
  :l-after-k :br-to-en-l :l-after-j :br-to-en-l   ; (R17: a stance opener pressed in it skips the turn)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)           ; (dream-rsi b1a0: J / K confirm into EN, the dash from afar)
       :ranges (:approach (2.0 6.0) :pressure (1.2 2.4) :zone (3.0 6.0) :defend (3.0 6.0))
       :moves ((0.0 2.4 :q 4 :f 3 :breaker 1 :sig 1)
               (2.4 3.4 :sig 2 :step 1 :f 1)
               (3.4 10.0 :sig 3 :step 1 nil 1)                      ; (L held: the turn, the dash's charge at once)
               (10.0 99.0 :step 1 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :block-string 0.3 :o-ender 0.3 :kikon-range 0.0
       :string-k 0.6 :l-after-k 1.0 :l-after-j 1.0   ; (every link that hit -> the R17 link: no plain K2s bridge; b1a2)
       :burst (:p 0.6 :wings 2 :in 8.0) :reflex br-ai-reflex :sig-hold br-ai-sig-hold   ; (the owl early: its x1.2, its volley)
       :far-dash (:p (:easy 0.05 :normal 0.15 :hard 1.0) :in 3.4)   ; (HARD at once, b1a1; round 2 b1a1 0.35, combo b1a2+b2a0 0.15 back: NORMAL band)
       :stance (:j-share 0.25 :charge 0.7 :punish 0.6 :follow 0.7 :sp2-at 0 :sp2 0.7 :keep 4 :sp2-all 8)))

;; JILLIEL EN, the stance (afloat): L / J / K start the stance's strings, each ending back in KIN (BARRO-TICK)
(defkit :barro :jilliel :inherit :jilliel-kin
  :form-name "JILLIEL" :walk *br-walk-en* :run *br-run-en* :body :lille-jilliel
  :commands (:q :br-e-j1 :f :br-e-k1 :sig :br-e-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)            ; (R9: J the top 1.85, K the great sword 2.6-2.95, L the dash)
       :ranges (:approach (2.8 8.0) :pressure (1.0 2.8) :zone (3.5 8.0) :defend (5.0 9.0))
       :moves ((0.0 1.8 :q 4 :f 2 :step 1)
               (1.8 2.8 :f 4 :q 1)
               (2.8 5.5 :sig 3 :step 1)
               (5.5 99.0 :sp1 1 :step 2 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :dash-back 0.2 :kikon-range 0.0
       :burst (:p 0.5 :wings 5 :in 6.0) :reflex br-ai-reflex :sig-hold br-ai-sig-hold   ; (EN: BR-AI-EN's plan a window)
       :stance (:j-share 0.25 :charge 0.7 :punish 0.6 :follow 0.7 :sp2-at 0 :sp2 0.7 :keep 4 :sp2-all 8)))

;; the owl (a burst in either JILLIEL form, decision R1; back when it ends): the claws, SP1 裁きの光明, SP2 the full volley
;; (every wing, decision R3; Trompete gone); x1.2 dealt (its buff), a wing every 2 s, the armour 2 wings; Kikon 4
(defkit :barro :shin-kin :inherit :jilliel-kin
  :lift 0.0 :form-name "SHIN KIN" :mult *br-owl-mult* :taken *br-owl-taken* :kikon-konpaku 4
  :body :lille-shin :stance :lb-o-stance :cine nil :clip-map *br-owl-clip-map*
  :commands (:q :br-o-j1 :f :br-o-k1 :sig :br-to-en :sp1 :br-misuji :sp2 :br-recall-s :breaker :br-o-breaker :kikon :br-o-kikon)
  :grid (:br-o-j1 :br-o-j2 :br-o-j3 :br-o-k1 :br-o-k2 :br-o-k3 :br-o-j2s :br-o-k2s)
  :ai (:intents (:approach 4 :pressure 4 :zone 0 :defend 0)
       :ranges (:approach (2.6 8.0) :pressure (1.4 2.6) :zone (3.0 6.0) :defend (3.0 6.0))
       :moves ((0.0 2.6 :q 3 :f 5 :breaker 1 :sig 1)
               (2.6 3.4 :sig 2 :step 1 :f 1)
               (3.4 10.0 :sig 3 :step 1 nil 1)                      ; (L held: the turn, the dash's charge at once)
               (10.0 99.0 :step 1 nil 3))
       :guard 0.3 :hoho 0.3 :dash 0.9 :block-string 0.3 :o-ender 0.2 :kikon-range 0.0
       :string-k 0.8 :l-after-k 1.0 :l-after-j 1.0 :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :far-dash (:p (:easy 0.05 :normal 0.15 :hard 1.0) :in 3.4)   ; (HARD at once, b1a1; round 2 b1a1 0.35, combo b1a2+b2a0 0.15 back: NORMAL band)
       :stance (:j-share 0.25 :charge 0.7 :punish 0.6 :follow 0.7 :sp2-at 3 :sp2 0.9 :keep 2 :sp2-all 5 :volley-at 8)))

(defkit :barro :shin :inherit :shin-kin
  :lift *br-owl-lift* :form-name "SHIN" :walk *br-walk-en* :run *br-run-en* :stance :lb-oe-stance
  :commands (:q :br-oe-j1 :f :br-oe-k1 :sig :br-oe-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.7 8.0) :pressure (1.0 2.7) :zone (3.5 8.0) :defend (5.0 9.0))   ; (R9: J the claw top 1.7, K 2.5-2.85, L the dash)
       :moves ((0.0 1.7 :q 4 :f 2 :step 1)
               (1.7 2.7 :f 4 :q 1)
               (2.7 5.5 :sig 3 :step 1)
               (5.5 99.0 :sp1 1 :step 2 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :dash-back 0.2 :kikon-range 0.0 :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :stance (:j-share 0.25 :charge 0.7 :punish 0.6 :follow 0.7 :sp2-at 3 :sp2 0.9 :keep 2 :sp2-all 5 :volley-at 8)))

(defparameter *br-forms* '(:base :jilliel-kin :jilliel :shin-kin :shin) "Every form of his (the HUD meter, the host tests).")

;; his names in the brush tables (brush.lisp): the intro's column and the technique columns (not on the host)
(when (boundp '*brush-names*)
  (setf *brush-names* (append (remove :barro *brush-names* :key #'first) '((:barro "リジェ・バロ" "LILLE II")))
        *brush-callouts*
        (append (remove-if (lambda (c) (eql 0 (search "BR-" (symbol-name (first c))))) *brush-callouts*)
                '((:br-k-sanren "三連" "SANREN" nil) (:br-k-hiren "飛廉脚" "HIRENKYAKU" nil) (:br-k-hiren-c "飛廉脚" "HIRENKYAKU" nil)
                  (:br-sanren "三連" "SANREN" nil) (:br-hiren "飛廉脚" "HIRENKYAKU" nil)
                  (:br-w-sanren "三連" "SANREN" nil) (:br-w-nijushi "二十四孔" "NIJUSHI-KO" nil)
                  (:br-w-nijushi-c "二十四孔" "NIJUSHI-KO" nil)
                  (:br-misuji "裁きの光明" "SABAKI NO KOMYO" nil)
                  (:br-to-en "遠" "EN" nil)
                  (:br-recall "回収" "KAISHU" nil) (:br-recall-s "回収" "KAISHU" nil) (:br-rc0 "回収" "KAISHU" nil) (:br-rc1 "二連" "NIREN" nil)
                  (:br-rc2 "四連" "YONREN" nil) (:br-rc3 "裁き" "SABAKI" nil) (:br-rc4 "裁き" "SABAKI KIWAMI" nil)
                  (:br-k-dash "飛廉脚" "HIRENKYAKU" nil)))))

;;; ================================================================ his state (the sim's): a component on his fighter entity
(defcomponent brs
  "Lille II's state: on his fighter entity, made on its first use, so a new match's fighter starts fresh."
  (ammo 0 :type fixnum)                   ; the special resource: the base's 狙擊 pips 0-3, awakened the wings 0-8
  (spent nil)                             ; the running follow-up shot spent one (BR-S-SPEND)
  (gained nil)                            ; the running stance shot paid its gains (once a move)
  (k-plan nil)                            ; his CPU's base stance pick (once a stance)
  (cpu-go nil)                            ; his CPU's follow-up / SP2 call for the running stance move (one roll)
  (l-next nil)                            ; a stance move: an L latched for its :lchain follow-up
  (dash-dir 0f0 :type single-float)       ; his CPU's stance Step: the strafe (0 straight back)
  (dashed nil)                            ; the stance's fast Step used (once per stance: the base's, EN's first Step)
  (in-string nil)                         ; a stance string runs in the awakened stance (its end: back to KIN)
  (slow nil)                              ; the stance's first hit may slow the match (armed at its entry)
  (owl-t 0 :type fixnum)                  ; frames in the owl (its wing a second)
  (recall-n 0 :type fixnum)               ; the volley's count (its f0) for its string (its f7)
  (sp2-next nil)                          ; a stance J / K segment: SP2 latched for the cancel (decision R3)
  (cut nil)                               ; the awakened L dash's cuts started (BR-W-CUTS; R11)
  (en-t 0 :type fixnum)                   ; frames standing in the stance EN (BARRO-TICK, *BR-EN-HOLD*; R12)
  (snipe-hold nil)                        ; the charged L's (move . frames held) kept through its Step (BR-SNIPE-STEP; R18)
  (l-lv 0 :type fixnum)                   ; the awakened L dash's charge level 1-3 (its S: BR-W-DASH; decision R10)
  (armored 0 :type fixnum)                ; hits his wing armour took (the pacing log)
  (ai-t -999 :type fixnum)                ; his CPU's last stance / burst window (one roll a window)
  (ai-step-key -999 :type fixnum)         ; his CPU: the opponent's Step it rolled for (its start tick; dream-rsi b1a1)
  (ai-step-go nil)                        ; ... that roll's answer: interrupt it (T) or not
  (ai-form nil)                           ; his CPU: the form of its last free step (the stance's exit; dream-rsi b1a1)
  (ai-kite -999 :type fixnum)             ; his CPU's last kite window (BR-AI-KITE; dream-rsi b1a1)
  (ai-restep nil)                         ; his learner read a Step / backing off to his charge: its Step re-aims (BR-LEARN-CHARGE)
  (ai-let-go nil)                         ; his CPU: this charge may be let go (one roll a charge, BR-AI-CHARGE-TICK) ...
  (ai-charge-key -999 :type fixnum)       ; ... the charge it rolled for (its start tick)
  (ai-line 0 :type fixnum)                ; his CPU: this charge's target level when the line releases it (0: the planned hold;
                                          ;  dream-rsi round 2 b1a0, BR-AI-LINE-CALL)
  (ai-resume nil)                         ; ... its Step out: the charge resumed after it keeps this charge's rolls
  (ai-stepped nil)                        ; ... this charge is the one back from its Step (re-aimed on him by the sim)
  (ai-cash-t -1 :type fixnum)             ; his CPU: the tick its last cash-out (the base stance's HIRENKYAKU) started (-1: read)
  (ai-cash-hp 0 :type fixnum)             ; ... his damage taken then (his own gauges)
  (ai-cash-read 0 :type fixnum)           ; ... cash-outs this match the opponent made him pay for (BR-AI-CASH-READ)
  (ai-hoho-key -999 :type fixnum)         ; his CPU: the charge whose answer to his Hoho it rolled (dream-rsi b2a0)
  (awake-t -1 :type fixnum) (owl-at -1 :type fixnum))   ; ticks of the awakening and the first burst owl (the pacing log)
(defvar *br-test-awake* nil
  "Debug 82041 (82040 off): the ASSIST gate's masher as him (P1, habit :dumb) plays every match from JILLIEL KIN (forced at
its first free step: the masher never awakens itself).")
(defvar *br-test-diff* nil
  "Debug 82050 / 82051 / 82052 (82053 off): his CPU plays EASY / NORMAL / HARD whatever the gate's *DIFFICULTY*.")
(defvar *br-keep-owl* nil "Debug: a forced owl form stays without a burst (BARRO-TICK's switch skipped).")
(defun br (e)
  "E's Lille II state (his BRS component, attached on the first call: a new fighter entity, a new match, gets a fresh one)."
  (or (brs e) (let ((st (make-brs))) (add-component e st) st)))
(defun br-ammo-look (e)
  "E's special resource count for his looks (barro-art.lisp BR-DRAW: the lit wings, the spend flash, the armour's shatter),
read in a DO-ENTITIES pass over the BRS components (a component getter conses 8 B in this build; the pass does not); 0
before his state exists. Read only (never makes the state)."
  (do-entities (h (st brs))
    (when (eql h e) (return-from br-ammo-look (brs-ammo st))))
  0)
(defun br-set-ammo (e n)
  "Debug (barro-art.lisp's art stills, BR-ART-SCENE / BR-ART-AMMO): E's special resource set to N. Here, not there: that
file compiles before the BRS component, so a SETF of its accessor there is an undefined function at run time."
  (setf (brs-ammo (br e)) n))

;;; ================================================================ hooks
(defun br-tick-brain (e)
  "The brain his ticks decide on: his own CPU's; NIL for a human (no brain, or one switched off) and for the ASSIST gate's
button-masher (habit :dumb, read as a human)."
  (let ((b (brain e))) (and b (not (brain-off b)) (not (eq (brain-habit b) :dumb)) b)))

(defun br-stance-move-p (mv) "Is MV one of the stances' string shots (BR-DEFSTANCE: :params :stance)?" (and mv (getf (mv-params mv) :stance) t))

(defun barro-ok (e command combo)
  "His kit's refusals: an L link off a stance string (the stance is not re-entered from its own strings: they end in the
attack state, decision R2); SP2 out of any move but the base stance's window, except a stance J / K segment's own charge-less
SP2 (COMBO, its :sp2c; decision R3: 「必須接在 KK 後執行才能有效利用」: no generic SP cancel)."
  (let* ((f (fighter e)) (cur (and (eq (fighter-state f) :move) (fighter-move f))))
    (cond ((and (eq command :sp2) cur (not (member (mv-name cur) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re))))
           (and (typep combo 'move) (eq combo (kit-next (fighter-kit f) (mv-name cur) :sp2c))))
          (t (not (and (typep combo 'move) (eq (mv-kind combo) :sig) cur (br-stance-move-p cur)))))))

(defun barro-step (e)
  "His kit's :step (fighter.lisp START-STEP, the Step's take-off): in the awakened stance EN the first Step after its entry is
the stance's fast Step (decision R3: 「進入架式後靠 step 快速移動一次」): *BR-KAMAE-DASH* m over *BR-KAMAE-DASH-F* for
*BR-KAMAE-DASH-FS* flash step (short of it: the plain Step), its standing clock fresh (*BR-EN-HOLD*); a Step after it leaves
the stance, KIN's plain Step (R12: 「只能像常態架槍一樣通過一次 step 高速移動」)."
  (let* ((f (fighter e)) (st (br e)) (g (gauges e)) (form (fighter-form f)))
    (when (and (br-ranged-form-p form) (brs-dashed st))   ; (R12: one Step a stance; the next leaves it, KIN's plain Step)
      (set-form e (br-melee-of form)) (pace e :stance-out-step)
      (return-from barro-step nil))
    (when (and (br-ranged-form-p form) (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g)))
      (spend-fs g *br-kamae-dash-fs*)
      (setf (brs-dashed st) t (brs-en-t st) 0)
      (multiple-value-bind (to sd) (stick-relative e f)
        (multiple-value-bind (to sd) (step-direction to sd)
          (multiple-value-bind (dx dz) (world-dir e f to sd)
            (set-slide e *br-kamae-dash* *br-kamae-dash-f* dx dz))))
      (pace e :en-dash)
      (let ((p (pos-of e))) (emit :hoho-out e (aref p 0) (aref p 2)))   ; (R13: the base stance Step's flash-step vanish)
      (emit :sfx :whoosh-light e))))

(defun barro-armor (e f mv)
  "His kit's :armor (fighter.lisp DEFENDER-STATE): the wing armour holds for this hit (BR-ARMOR-P: awakened, his own
attack, the wings for it)."
  (br-armor-p (fighter-form f) (mv-kind mv) (fighter-phase f) (brs-ammo (br e))))

(defun barro-tick (e f g)
  "Per step (his kit's :tick): the burst owl (BR-OWL-SWITCH: a burst in a JILLIEL form turns him into the owl, its end back,
once he is out of a move;
the owl's wing every *BR-OWL-WING-EVERY* frames); the awakened stance's string end (back to KIN, decision R2); the
specials' cap; the pacing clocks."
  (when (or *br-test-awake* *br-test-diff*) (br-test-tick e f))
  (let* ((st (br e)) (form (fighter-form f))
         (to (and (not *br-keep-owl*) (not (eq (fighter-state f) :move))   ; (never inside a move: its string's links are
                  (br-owl-switch form (gauges-burst g)))))                     ;  its form's; the gate's crash, 2026-10-10)
    (when to
      (set-form e to)
      (setf (brs-owl-t st) 0 form to)
      (pace e (if (br-owl-form-p to) :owl-in :owl-out))
      (when (and (br-owl-form-p to) (minusp (brs-owl-at st))) (setf (brs-owl-at st) *match-tick*) (pace e :owl-tick *match-tick*))
      (emit :sfx (if (br-owl-form-p to) :awaken-boom :rift-open) e))
    (when (br-owl-form-p form)
      (when (and (>= (incf (brs-owl-t st)) *br-owl-wing-every*) (zerop (fighter-freeze f)))
        (setf (brs-owl-t st) 0 (brs-ammo st) (br-ammo-add (brs-ammo st) 1 form))
        (pace e :owl-wing)))
    (setf (brs-ammo st) (br-ammo-add (brs-ammo st) 0 form))
    (when (br-ranged-form-p form)                       ; (R12: the stance EN rooted, one Step, a short stand)
      (case (fighter-state f)
        (:run (to-idle e 4))                            ; (no run off its Step)
        ((:idle :guard)
         (when (and (not (brs-in-string st)) (>= (incf (brs-en-t st)) *br-en-hold*))
           (setf (brs-en-t st) 0 form (br-melee-of form))
           (set-form e form) (pace e :stance-timeout)))))
    (let ((mv (and (eq (fighter-state f) :move) (fighter-move f))))
      (cond ((and mv (br-stance-move-p mv) (br-ranged-form-p form)) (setf (brs-in-string st) t))
            ((and (brs-in-string st) (member (fighter-state f) '(:idle :run :guard)))
             (setf (brs-in-string st) nil)
             (when (br-ranged-form-p form) (set-form e (br-melee-of form)) (pace e :stance-out)))
            ((not mv) (setf (brs-in-string st) nil)))
      (unless (and mv (eq (mv-tick mv) 'br-s-tick)) (setf (brs-sp2-next st) nil (brs-l-next st) nil))   ; (+ the owl's K, R4)
      (when (and (br-awake-form-p form) (minusp (brs-awake-t st)))
        (setf (brs-awake-t st) *match-tick*) (pace e :awaken-tick *match-tick*)))))

(defun barro-hit (att def res hw mv hazard ranged)
  "After a hit he dealt (his kit's :hit): a stance shot's gains, once a move (decision R2): L the specials (BR-L-GAIN, a hit
or a block), J J / its L L follow-up flash step and Reiatsu (BR-RECOVER-GAIN), the first contact of the move's hits; the stance's first hit and the volley's
last beam slow the match; the pacing log."
  (declare (ignore ranged))
  (let ((st (br att)) (c (contact-of res)) (role (and mv (not hazard) (getf (mv-params mv) :stance))))
    (when (and role (member c '(:hit :block)) (not (brs-gained st)))
      (setf (brs-gained st) t)
      (case role
        (:l (let ((k (if (or (getf (mv-params mv) :dash) (getf (mv-params mv) :charged))   ; (R10 / R15: by its charge level)
                         (if (member c '(:hit :block)) (nth (1- (max 1 (brs-l-lv st))) *br-w-l-gain*) 0)
                         (br-l-gain c (getf (mv-params mv) :gain 0))))
                  (form (fighter-form (fighter att))))
              (when (plusp k)
                (setf (brs-ammo st) (br-ammo-add (brs-ammo st) k form)) (pace att :ammo-gain k)
                (clog "~a specials +~d -> ~d" (side-name att) k (brs-ammo st)))))
        ((:j :jl) (multiple-value-bind (fs sp) (br-recover-gain c role (brs-spent st))
                    (pay-gauges att sp fs)
                    (pace att (if (and (eq role :jl) (brs-spent st)) :recover-big :recover))))))
    (when (and *combat-log* (eq c :hit)                           ; (the combat log only: tools/aieval.py's signature tag,
               (or (and role (getf (mv-params mv) :dash) (>= (brs-l-lv st) 2))   ;  the awakened L dash and its cuts charged
                                                                                   ;  to level 2 / 3;
                   (and hazard (eq (hazard-kind hazard) :br-cut) (>= (the fixnum (second (hazard-data hazard))) 2))))   ; DUEL_LILLE_V3 §22)
      (clog "~a br-sig charged" (side-name att)))
    (when (and role (eq c :hit) (getf (mv-params mv) :dash) (not (brs-cut st)))   ; (R11: the dash's cuts, once a dash)
      (setf (brs-cut st) t)
      (br-w-cuts att def mv))
    (when (and role (eq c :hit) (getf (mv-params mv) :end) (not (getf (mv-params mv) :dash)))
      (br-s-end-push att def mv))
    (when (and role (eq c :hit) (brs-slow st))
      (setf (brs-slow st) nil)
      (slowmo *br-fresh-scale* *br-fresh-secs*) (pace att :slow-fresh) (clog "~a stance slow motion" (side-name att)))
    (when (and mv (not hazard) (eq c :hit) (member (mv-name mv) '(:br-rc3 :br-rc4))
               (eq hw (svref (mv-hits mv) (1- (length (mv-hits mv))))))
      (slowmo *br-volley-scale* *br-volley-secs*) (pace att :slow-volley) (clog "~a volley slow motion" (side-name att)))
    (when (and hw (br-x-hit-p hw))
      (pace att (if (eq c :hit) :x-hit :x-guarded)))))

(defparameter *br-s-end-margin* 0.3
  "A stance string's end push (BR-S-END-PUSH): past the first segment's whole reach (BR-MOVE-REACH) + the victim's body by
this many metres (R12, the user 2026-10-11: 「架式 J/K 完的推離距離不夠遠，導致架式 J1/K1 還是能打中對手」: the generic
*ENDER-PUSH* 0.05 on MV-REACH, a capsule's end without its radius, left J1 0.35 m in reach; [G]).")
(defun br-k-order-p ()
  "R14 (the user 2026-10-11: 「我希望 K 之後的 LL 傷害大於架式 K 又大於普通 K」): in every form, each attack-state K string link's
damage below the stance K segment at its place (K1 K2 K3), and every stance K segment below a K route L L line (the same
form's multiplier on both: compared as written)?"
  (and (every (lambda (pre)
                (every (lambda (n)
                         (let ((s (mv-dmg (find-move (intern (format nil "~a-K~d" pre n) :keyword)))))
                           (< s (mv-dmg (find-move (intern (format nil "~a-KL~d" pre n) :keyword))))))
                       '(1 2 3)))
              '("BR-S" "BR-E" "BR-OE"))
       (every (lambda (row)
                (destructuring-bind (pre . ks) row
                  (loop for k in ks for n from 1
                        always (< (mv-dmg (find-move k)) (mv-dmg (find-move (intern (format nil "~a-K~d" pre n) :keyword)))))))
              '(("BR-S" :br-k1 :br-k2 :br-k3) ("BR-E" :br-w-k1 :br-w-k2 :br-w-k3) ("BR-OE" :br-o-k1 :br-o-k2 :br-o-k3)))))
(defun br-move-reach (mv)
  "MV's whole reach (m): the farthest edge of its hit windows' volumes (a capsule's end + its radius, an arc's radius, a
sphere's distance + its radius); MV-REACH without volumes."
  (let ((best 0.0))
    (loop for w across (mv-hits mv)
          do (loop for v in (hw-vols w)
                   do (setf best (max best (case (round (aref v 0))
                                             (0 (aref v 1)) (1 (+ (aref v 2) (aref v 4))) (2 (+ (aref v 1) (aref v 3)))
                                             (t 0.0))))))
    (if (plusp best) best (mv-reach mv))))
(defun br-s-end-push (e o mv)
  "A stance string's last segment MV (:end: L3, J3, K3, JL3, KL3) just hit O: O is pushed out of the reach of the string's
first segment (L1 after L3, J1 after J3 / JL3, K1 after K3 / KL3, the same prefix) as a J / K string's ender (ENDER-PUSH's
rule on its whole reach, BR-MOVE-REACH, + *BR-S-END-MARGIN*, R12; the user 2026-10-11: 「架式連段結束後要像 J/K 結尾一樣將對手推離初始起手勢的攻擊範圍避免無限壓制」). The
awakened L (one dash, R10) leaves him behind it, 1.6 m past: no push. What starts off it chases him (BR-S-TICK's SP2)."
  (let* ((name (symbol-name (mv-name mv))) (pre (subseq name 0 (position #\- name :from-end t)))
         (first (case (getf (mv-params mv) :stance) (:l "L1") ((:j :jl) "J1") (t "K1")))
         (opener (gethash (intern (format nil "~a-~a" pre first) :keyword) *moves*))
         (push (and opener (not (getf (mv-params opener) :dash))
                    (- (+ (br-move-reach opener) (mv-slide opener) (body-hurt-r (model-body (model o))) *br-s-end-margin*)
                       (fighter-dist (fighter e))))))
    (when (and push (plusp push) (eq (fighter-state (fighter o)) :stun))
      (multiple-value-bind (mb ma) (push-apart e o push *ender-push-frames*)
        (pace e :end-push)
        (clog "~a stance end push ~a ~,1f m (attacker ~,1f)" (side-name e) (mv-name mv) mb ma)))))

(defun barro-struck (def att res hw mv hazard ranged)
  "After a hit he took (his kit's :struck): the wing armour held (RESOLVE-CONTACT :armored: his moves carry no :armor-hits,
so every :armored is the wings'): its wings spent (BR-ARMOR-COST), the flash."
  (declare (ignore att hw mv hazard ranged))
  (when (eq res :armored)
    (let* ((st (br def)) (form (fighter-form (fighter def))))
      (setf (brs-ammo st) (br-ammo-add (brs-ammo st) (- (br-armor-cost form)) form))
      (incf (brs-armored st))
      (pace def :armored)
      (emit :sfx :lb-crack def)
      (clog "~a wing armour: ~d wings left" (side-name def) (brs-ammo st)))))

;;; ---------------------------------------------------------------- the base stance
(defun br-kamae-enter (e)
  "A fresh stance (L from neutral at f0, or after a link at f4): no CPU pick yet, its Step unspent, its first hit armed."
  (setf (brs-k-plan (br e)) nil (brs-dashed (br e)) nil (brs-slow (br e)) t)
  (pace e :kamae))

(defun br-kamae-pressed (vp)
  "The stance's pick a human pressed (buffered): :kamae-sp2 / -sp1 (Shift+L / Shift+K) / -j / -k / -l / -step, or NIL."
  (cond ((vpad-command-pressed-p vp :sig t) :kamae-sp2) ((vpad-command-pressed-p vp :flash t) :kamae-sp1)
        ((vpad-command-pressed-p vp :quick nil) :kamae-j) ((vpad-command-pressed-p vp :flash nil) :kamae-k)
        ((vpad-command-pressed-p vp :sig nil) :kamae-l) ((vpad-command-pressed-p vp :step nil) :kamae-step)))

(defun br-kamae-go (e f st mv cmd)
  "Start the stance's pick CMD from stance move MV: a string's opener (decision R2), the stance's SP1 / SP2 under their
command's bars (TRY-COMMAND's WITH), the Step once per stance for its flash step (refused: the press is ignored). T when
it started."
  (let ((kit (fighter-kit f)))
    (case cmd
      (:kamae-step (when (br-kamae-step-ok-p (brs-dashed st) (gauges-fs (gauges e)))
                     (spend-fs (gauges e) *br-kamae-dash-fs*) (setf (brs-dashed st) t (brs-snipe-hold st) nil)
                     (start-move e (kit-next kit (mv-name mv) cmd)) t))
      ((:kamae-sp1 :kamae-sp2)
       (when (try-command e f (if (eq cmd :kamae-sp1) :sp1 :sp2) nil nil (kit-next kit (mv-name mv) cmd))
         (pace e cmd) t))
      (t (let ((m (kit-next kit (mv-name mv) cmd)))
           (start-move e m (and (mv-hold m) :sig))   ; (R15: the snipe held by L)
           (pace e cmd) t)))))

(defun br-kamae-tick (e)
  "One step of the base stance: it turns at *BR-AIM-TRACK*; from f6 the first L / J / K / SP1 / SP2 / Step picks (his
CPU's: BR-AI-KAMAE); past the hold (30 f, 90 while L is held) the stance recovers (R 14)."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and (eq (fighter-state f) :move) mv (member (mv-name mv) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)))
      (let* ((st (br e)) (sf (fighter-sf f)) (vp (pilot-vpad (pilot e))) (b (br-tick-brain e)))
        (turn-to-opp e f (track-step *br-aim-track*))
        (when (and (>= sf *br-kamae-up*) (>= (vpad-held vp :sig) *br-to-dash-held*))   ; (R15: L held, the snipe's charge)
          (start-move e (find-move :br-s-l1) :sig)
          (setf (fighter-hold f) (min (vpad-held vp :sig) (1- *br-w-l-hold*)))
          (pace e :to-snipe)
          (return-from br-kamae-tick nil))
        (when (>= sf *br-kamae-up*)
          (let ((cmd (if b (br-ai-kamae e f st b) (br-kamae-pressed vp))))
            (when cmd
              (let ((button (getf '(:kamae-j :quick :kamae-k :flash :kamae-l :sig :kamae-sp1 :flash :kamae-sp2 :sig
                                    :kamae-step :step)
                                  cmd)))
                (if (br-kamae-go e f st mv cmd)
                    (progn (unless b (vpad-consume! vp button)) (return-from br-kamae-tick nil))
                    (if b (setf (brs-k-plan st) :kamae-l) (vpad-consume! vp button)))))))
        (when (br-kamae-hold-over-p sf nil)   ; (R15: L held is the snipe's charge, no longer a longer stand)
          (setf (fighter-sf f) (+ *br-kamae-up* *br-kamae-max*)))))))

(defun br-kamae-dash (e)
  "The stance's Step 飛廉脚 f0 (decision V6): *BR-KAMAE-DASH* m in the stick direction (neutral: away from him; his CPU's
straight back) over *BR-KAMAE-DASH-F*, iframes f0-7, the flash step's vanish."
  (let* ((f (fighter e)) (p (pos-of e)))
    (multiple-value-bind (to st) (if (br-tick-brain e) (values 0.0 0.0) (stick-relative e f))
      (multiple-value-bind (to st) (step-direction to st -1.0)
        (multiple-value-bind (dx dz) (world-dir e f to st)
          (set-slide e *br-kamae-dash* *br-kamae-dash-f* dx dz))))
    (setf (fighter-invuln f) (max (fighter-invuln f) *br-kamae-dash-iframes*))
    (pace e :k-dash)
    (emit :hoho-out e (aref p 0) (aref p 2))
    (emit :sfx :whoosh-light e)))
(defun br-kamae-back (e)
  "The Step's f11: back in the stance at its f6 (:br-kamae-re: a fresh window, the Step spent), the aim snapped onto him. A Step
out of the snipe's charge (BR-SNIPE-STEP, R18): back in that charge instead, its frames held as they were (L let go in the
Step: it fires at once, re-aimed)."
  (let* ((f (fighter e)) (st (br e)) (held (brs-snipe-hold st)))
    (setf (brs-snipe-hold st) nil)
    (cond (held (start-move e (car held) :sig)   ; (the charge's move, its frames held)
                (setf (fighter-hold f) (cdr held))
                (pace e :snipe-back))
          ((eq (mv-name (fighter-move f)) :br-w-charge-step) (to-idle e 4))   ; (never: its Step always keeps a charge)
          (t (start-move e (kit-next (kit-of e) :br-k-dash :kamae-back))))
    (turn-to-opp e f 10.0)))

(defun br-snipe-step (e f st vp mv)
  "The charged L's charge (MV held: the base snipe :br-s-l1, R18, DUEL_LILLE_V3 §23: 「我希望在架槍續力狙擊時能透過 step 閃身保持續力
並重新瞄準對手」; the awakened dash :br-e-l1 / :br-oe-l1, 「覺醒後的衝刺 L 也套用一樣的規則」): a human's Step (buffered; a
one-hand flick, the moves :step-branch) there is the stance's fast Step (the base's 飛廉脚 :br-k-dash, the awakened stance's
:br-w-charge-step: the flash step's vanish, iframes; once a stance and its flash steps, BR-KAMAE-STEP-OK-P; refused: the press
ignored, the charge goes on), the charge's move and frames kept (BRS-SNIPE-HOLD, the Step's frames not counted); BR-KAMAE-BACK
resumes the charge, the aim snapped onto him. T when it stepped."
  (when (vpad-command-pressed-p vp :step nil)
    (vpad-consume! vp :step)
    (br-charge-step-go e f st mv)))
(defun br-charge-step-go (e f st mv)
  "The charge's Step (BR-SNIPE-STEP's, his CPU's on a learner's read: BR-AI-RESTEP): under BR-KAMAE-STEP-OK-P, the stance's
fast Step started, MV's charge kept for BR-KAMAE-BACK. T when it stepped."
  (when (br-kamae-step-ok-p (brs-dashed st) (gauges-fs (gauges e)))
    (spend-fs (gauges e) *br-kamae-dash-fs*)
    (let ((held (cons mv (fighter-hold f))))
      (start-move e (if (eq (fighter-form f) :base) (kit-next (fighter-kit f) :br-kamae :kamae-step) (find-move :br-w-charge-step)))
      (setf (brs-dashed st) t (brs-en-t st) 0 (brs-snipe-hold st) held))
    (pace e :snipe-step)
    t))

(defun br-k-dash-tick (e)
  "The stance Step: from its *BR-DASH-SNAP-F* a J (a human's press, buffered) cancels it into the stance's J J, facing him."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :main) (br-dash-snap-p (fighter-sf f)) (null (br-tick-brain e)))
      (let ((vp (pilot-vpad (pilot e))))
        (when (vpad-command-pressed-p vp :quick nil)
          (vpad-consume! vp :quick)
          (setf (brs-snipe-hold (br e)) nil)   ; (R18: a snipe's Step cancelled into J drops the charge)
          (turn-to-opp e f 10.0)
          (start-move e (kit-next (fighter-kit f) :br-k-dash :kamae-j))
          (pace e :dash-j))))))

;;; ---------------------------------------------------------------- the stance's strings (decision R2, R3)
(defun br-s-start (e)
  "A stance move's f0 (its move's entry frame: START-MOVE runs it): its gains not yet paid, nothing spent, no latch, his CPU's
call not yet made."
  (let ((st (br e))) (setf (brs-gained st) nil (brs-spent st) nil (brs-l-next st) nil (brs-sp2-next st) nil (brs-cpu-go st) nil)))

(defun br-s-spend (e)
  "A follow-up line's f0 (J J -> L L, K K -> L L, decision R3): BR-S-START, then one special spent (BR-SPEND; 「每下花 1
翼」, BR-S-TICK started it only with one): J J's follow-up's gains raised on its hit (BRS-SPENT, BARRO-HIT)."
  (br-s-start e)
  (let ((st (br e)))
    (multiple-value-bind (left spent) (br-spend (brs-ammo st))
      (setf (brs-ammo st) left (brs-spent st) spent)
      (pace e (if spent :spend :spend-none)))))

(defun br-s-cpu-call (e f st mv sp2 next)
  "His CPU's call at the end of stance move MV's hits (one roll, the kit's :stance; dream-rsi b1a0): the spending L L
follow-up NEXT while a special is left to pay it (:follow of the time: the specials' sink, 「資源循環」); at a string's last
segment (:end) that hit with no follow-up to pay (none, or the follow-up's own last line) the charge-less SP2 with the bars
for it (:sp2 of the time: every special left, its damage + a unit each); a free link (L1 -> L2) always. :SP2, :GO or :NO."
  (let* ((k (ai-table e :stance)) (b (br-tick-brain e)) (r (sim-rnd01)) (n (brs-ammo st))
         (d (if b (brain-difficulty b) :normal))
         (refill (or (< (gauges-fs (gauges e)) (getf k :recover-fs 40.0)) (< (reiatsu-bars e) 2)
                     (>= n (br-ammo-cap (fighter-form f)))))
         (call (br-ai-call r n (reiatsu-bars e) (and sp2 (getf (mv-params mv) :end) (eq (fighter-contact f) :hit))
                           (and next (getf (mv-params next) :spend)
                                (or refill (not (eq (getf (mv-params next) :stance) :jl))))   ; (the J route's L L: its refill)
                           (br-owl-form-p (fighter-form f)) k d)))
    (cond (call call)
          ((and next (not (getf (mv-params next) :spend))) :go)
          (t (pace e :ai-follow-no) :no))))

(defun br-ai-call (r n bars end pay owl k difficulty)
  "His CPU's stance call from one roll R (pure; dream-rsi b1a1 on b1a0's call, the reserve as cell b3a0 measured it): N
specials, BARS of Reiatsu, END (a string's last segment that hit: SP2 may follow), PAY (a spending L L line follows and
may be paid), OWL, K the kit's :stance. The wings are his armour first (BR-ARMOR-P's price, :keep): no line below :keep,
SP2 (it spends every one) only short of :keep or at :sp2-all; the owl's full volley at once at :volley-at. :SP2, :GO or
NIL (no call)."
  (let* ((keep (getf k :keep 0))
         (sp2 (and end (>= bars 2) (>= n (getf k :sp2-at 0)) (< r (br-ai-p k :sp2 difficulty))))
         (cash (or (zerop keep) (< n keep) (>= n (getf k :sp2-all 99)))))
    (cond ((and sp2 owl (>= n (getf k :volley-at 99))) :sp2)
          ((and pay (br-follow-ok-p n) (> n keep) (< r (br-ai-p k :follow difficulty))) :go)
          ((and sp2 cash) :sp2))))

(defun br-s-tick (e)
  "A stance move (no chase: its J / K links are :quick / :flash). Its L links (:lchain: L1 -> L2 -> L3, J3 -> JL1 -> JL2 ->
JL3, K3 -> KL1 -> KL2 -> KL3, decision R3) start unchained: a human's L pressed during it is latched and starts the next from the end
of its hits, the move having touched him (a hit or a block; a whiff ends the string, as a J / K string's links: decision R5, the
user 2026-10-11: 「架式 > L 只要沒打中就進入硬直」「就跟一般的 J / K 普攻一樣」), a spending follow-up only with a special to
spend (BR-FOLLOW-OK-P; none, the string ends). Any J / K / JL /
KL segment: a human's SP2 (Shift+L) is latched and, the move having hit, cancels into the form's charge-less SP2 there
(:sp2c; 「必須接在 KK 後執行」, 「SP2 接在 J 連段後面也可以」).
His CPU makes one call there (BR-S-CPU-CALL); holding a charge (the :hold phase) it lets go as BR-AI-CHARGE-TICK says."
  (let* ((f (fighter e)) (mv (fighter-move f)) (st (br e)))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :hold))   ; (his CPU's charge only: dream-rsi b1a1)
      (let ((b (br-tick-brain e)))
        (when b
          (br-ai-charge-tick e f b mv)
          (when (and (brs-ai-restep st) (eq (fighter-move f) mv) (eq (fighter-phase f) :hold))
            (br-ai-restep e f st b mv)))))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :hold) (member (mv-name mv) '(:br-s-l1 :br-e-l1 :br-oe-l1))
               (zerop (fighter-lock f)) (null (br-tick-brain e)))   ; (R18: the charged L's charge, a human's Step)
      (br-snipe-step e f st (pilot-vpad (pilot e)) mv))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :main) (zerop (fighter-lock f)))
      (let* ((kit (fighter-kit f)) (next (kit-next kit (mv-name mv) :lchain)) (sp2 (kit-next kit (mv-name mv) :sp2c))
             (b (br-tick-brain e)) (vp (pilot-vpad (pilot e))))
        (when (or next sp2)
          (unless b
            (when (and sp2 (vpad-command-pressed-p vp :sig t)) (vpad-consume! vp :sig) (setf (brs-sp2-next st) t))
            (when (and next (vpad-command-pressed-p vp :sig nil)) (vpad-consume! vp :sig) (setf (brs-l-next st) t)))
          (when (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
            (when (and b (null (brs-cpu-go st)))
              (setf (brs-cpu-go st) (br-s-cpu-call e f st mv sp2 next))
              (case (brs-cpu-go st) (:sp2 (setf (brs-sp2-next st) t)) (:go (setf (brs-l-next st) t))))
            (cond ((and (brs-sp2-next st) sp2 (eq (fighter-contact f) :hit))
                   (setf (brs-sp2-next st) nil (brs-l-next st) nil)
                   (turn-to-opp e f 10.0)
                   (when (try-command e f :sp2 nil nil sp2)
                     (when (getf (mv-params mv) :end) (setf (fighter-end-chase f) t))   ; (BR-S-END-PUSH: it chases him)
                     (pace e :k-sp2)))
                  ((and (brs-l-next st) next)
                   (setf (brs-l-next st) nil (brs-sp2-next st) nil)
                   (cond ((null (fighter-contact f)) (pace e :l-whiff))   ; (R5: a whiff ends it, as a J / K string)
                         ((or (not (getf (mv-params next) :spend)) (br-follow-ok-p (brs-ammo st)))
                          (start-move e next) (pace e :l-chain))
                         (t (pace e :follow-empty)))))))))))

(defun br-w-l-level (held)
  "The awakened L dash's charge level for HELD frames (*BR-W-L-LEVELS*): 1, 2 or 3."
  (destructuring-bind (a b) *br-w-l-levels* (cond ((>= held b) 3) ((>= held a) 2) (t 1))))

(defun br-w-dash (e)
  "The awakened L's S (decision R9; R10: charged): its gains unpaid (BR-S-START: a held move's f0 hooks never run, START-MOVE
runs them only for a move entered in its main phase -- the R10 dash gave no specials, R11, DUEL_LILLE_V3 §16), its level by
the frames L was held (BR-W-L-LEVEL); facing him, a dash *BR-W-DASH-PAST* m past him (clamped *BR-W-DASH-MIN* .. the
level's *BR-W-L-DASH-MAX*) over *BR-W-DASH-F* frames; the move is :through (no body push: he passes through). Its hit
starts the level's cuts (BARRO-HIT, BR-W-CUTS)."
  (let* ((f (fighter e)) (st (br e)) (lv (br-w-l-level (fighter-charge f)))
         (d (max *br-w-dash-min* (min (nth (1- lv) *br-w-l-dash-max*) (+ (fighter-dist f) *br-w-dash-past*)))))
    (br-s-start e)
    (setf (brs-l-lv st) lv (brs-cut st) nil)
    (pace e (svref #(:w-dash-1 :w-dash-2 :w-dash-3) (1- lv)))   ; (R18: no turn onto him, the dash goes where he faces)
    (let ((yaw (yaw-of e))) (set-slide e d *br-w-dash-f* (fwd-x yaw) (fwd-z yaw)))
    (pace e :w-dash)
    (emit :sfx :whoosh-heavy e)))

(defun br-s-snipe-release (e)
  "The base stance's L, the charged snipe (R15, DUEL_LILLE_V3 §19: 「蓄力狙擊」), released: its gains unpaid (BR-S-START: a held
move's f0 hooks never run), its level by the frames held (BR-W-L-LEVEL); level 2 / 3 the longer shots (:br-s-l1-2 /
:br-s-l1-3, started in its place; level 1 the move goes on). The shot goes where he faces (R18, DUEL_LILLE_V3 §23: its :track 0,
no turn here; the stance aimed it at *BR-AIM-TRACK*, the charge's Step re-aims it: BR-SNIPE-STEP)."
  (let* ((f (fighter e)) (st (br e)) (lv (br-w-l-level (fighter-charge f))))
    (br-s-start e)
    (setf (brs-l-lv st) lv)
    (pace e (svref #(:snipe-1 :snipe-2 :snipe-3) (1- lv)))
    (when (> lv 1)   ; (R18: no turn onto him at the shot, 「射擊的一瞬間會強制面對對手變成必中狀態。我不希望這樣」)
      (start-move e (find-move (if (= lv 2) :br-s-l1-2 :br-s-l1-3))))))

(defun br-w-cuts (e o mv)
  "The awakened L dash MV just hit O (R11, DUEL_LILLE_V3 §16: 「我希望衝刺 L 依據蓄力階段給出多段的斬擊特效與 combo 計數」): the
level's *BR-W-L-CUTS* cuts on him where he stands, the first one frame after the dash's end, *BR-W-CUT-STEP* frames apart
(:br-cut hazards: the first the touch's own, drawn only; each next one a hit of *BR-W-CUT-DMG*, a stagger in place, a combo
hit), each drawn by barro-art.lisp's BR-CUT-LOOK for *BR-W-CUT-LIFE* frames from its hit."
  (let* ((f (fighter e)) (lv (max 1 (brs-l-lv (br e)))) (n (nth (1- lv) *br-w-l-cuts*))
         (rem (max 0 (- (+ (mv-s mv) (mv-a mv)) (fighter-sf f)))) (q (pos-of o)) (yaw (yaw-of e)))
    (dotimes (i n)
      (spawn-hazard :br-cut e :x (aref q 0) :z (aref q 2) :yaw yaw :size 1.0 :delay (+ rem 1 (* i *br-w-cut-step*))
                              :life *br-w-cut-life* :hook 'br-hz :look 'br-cut-look :data (list i lv)
                              :hw (and (plusp i) (make-hitwin :dmg *br-w-cut-dmg* :react :stagger :kb 0.0 :hs *br-w-cut-hs*))))
    (pace e :w-cuts n)))

(defun br-stance-arm (e)
  "The awakened stance's entry: its first hit armed (the slow motion), its fast Step unspent (BARRO-STEP, decision R3)."
  (setf (brs-slow (br e)) t (brs-dashed (br e)) nil))

;;; ---------------------------------------------------------------- SP1 / SP2 by the special count (decision R1)
(defun br-sp1-fs-go (e)
  "SP1's f0: flash step back by its tier (BR-SP-TIER, BR-SP1-FS; read, not spent)."
  (let* ((f (fighter e)) (tier (br-sp-tier (brs-ammo (br e)) (fighter-form f))))
    (pay-gauges e 0.0 (br-sp1-fs tier))
    (pace e (svref #(:sp1-t0 :sp1-t1 :sp1-t2) tier))))

(defun br-sp2-spend (e)
  "HIRENKYAKU's / NIJUSHI-KO's f0 (its charge-less copy's entry frame): every special spent, + BR-SP2-BONUS damage for them
(FIGHTER-DMG-BONUS; decision R3: 「花光全部，每單位加傷害」), facing him."
  (let* ((f (fighter e)) (st (br e)) (n (brs-ammo st)))
    (setf (fighter-dmg-bonus f) (br-sp2-bonus n (fighter-form f)) (brs-ammo st) 0)
    (turn-to-opp e f 10.0)
    (pace e :sp2-spend n)))

;;; ---------------------------------------------------------------- shots and their looks
(defun br-shot-fire (e)
  "A shot's fire frame: the line's look (jade with 萬物貫通), the crack."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    ;; (R8, DUEL_LILLE_V3 §13: the awakened K route's L L drawn as balls of light, barro-art.lisp %BR-KL-BALLS; the look
    ;; hazard is spawned all the same, only its kind differs: the hit and the hazard count are the line's)
    ;; (R10, §15: 「J 陀螺完之後還是射擊不是長鞭呀」: the awakened J route's L L drawn as the whip reaching him, barro-art.lisp
    ;; %BR-WHIP-LASH since R11, §16; its look :whip, which LB-LOOK does not draw either)
    (br-spawn-look e (if (eq (fighter-form f) :base) :shot (case (getf (mv-params mv) :stance) (:kl :ball) (:jl :whip) (t :shot)))
                   (or (move-param e :len) *br-x-len*) 0.05 (and (member :x-axis (mv-flags mv)) t))
    ;; (R11, §16: 「現在的架式 J > L 看起來依舊是射擊？」: the awakened J route's L L sound a whip's crack, barro-art.lisp's
    ;; :br-whip-crack; the base form's stay the gunshot)
    (emit :sfx (if (and (not (eq (fighter-form f) :base)) (eq (getf (mv-params mv) :stance) :jl)) :br-whip-crack :lb-crack) e)))
(defun br-line-shot (e)
  "SANREN's shots (f12, f22, f32): the line's look."
  (br-spawn-look e :shot (move-param e :len) 0.04 (and (member :uncatchable (mv-flags (fighter-move (fighter e)))) t))
  (emit :sfx :rift-cut e))
(defun br-lane-shot (e)
  "A Kikon module's lane: its look (the hit is the move's lane)."
  (br-spawn-look e :lane (move-param e :len) 0.5 t)
  (emit :sfx :kikon-slash e))
(defun br-beam-shot (e)
  "NIJUSHI-KO's / Trompete's / the volley's last line: the beam's look."
  (br-spawn-look e :beam 31.0 (or (move-param e :width) 1.2) t)
  (emit :sfx :explode e))
(defun br-sanren-tick (e)
  "SANREN: he turns 90 deg/s between the shots."
  (let* ((f (fighter e)) (sf (fighter-sf f)))
    (when (and (eq (fighter-phase f) :main) (< 14 sf 32) (not (<= 22 sf 24)))
      (turn-to-opp e f (track-step 90.0)))))
(defun br-slide (e)
  "HIRENKYAKU's / TAISHA's f0: the back-slide, the move's :slide metres over :slide-f frames (no iframes)."
  (let* ((p (pos-of e)) (f (fighter e)))
    (set-slide e (move-param e :slide) (move-param e :slide-f) (- (aref p 0) (fighter-ox f)) (- (aref p 2) (fighter-oz f)))
    (emit :sfx :hoho-out e)))
(defun br-slide-tick (e)
  "The back-slides: he keeps turning to the opponent while he slides, then the line is fixed (from :lock)."
  (let ((f (fighter e)))
    (when (and (eq (fighter-phase f) :main) (< (fighter-sf f) (move-param e :lock))) (turn-to-opp e f (track-step 90.0)))))
(defun br-planted-tick (e)
  "A planted wind-up (NIJUSHI-KO, Trompete): turning at the move's :track until its :lock frame, then locked."
  (let ((f (fighter e)))
    (when (and (eq (fighter-phase f) :main) (< (fighter-sf f) (move-param e :lock)))
      (turn-to-opp e f (track-step (move-param e :track))))))
(defun br-nijushi-tell (e) "NIJUSHI-KO f0: the 24 holes glow (the tell)." (setf (model-super (model e)) 0.6) (emit :sfx :awaken-rise e))
(defun br-spawn-look (e kind len width lock)
  "A look-only hazard of his along his facing: a shot, a beam or a lane (Lille's LB-LOOK draws it; no hit)."
  (let ((p (pos-of e))) (br-spawn-look-at e kind (aref p 0) (aref p 2) (yaw-of e) len width lock)))
(defun br-spawn-look-at (e kind x z yaw len width lock)
  "BR-SPAWN-LOOK from (X Z) along YAW."
  (spawn-hazard :br-fx e :x x :z z :yaw yaw :size len :life (case kind ((:beam :judge) 30) (t 16))
                         :hook 'br-hz :data (make-lbh :kind kind :len (f32 len) :width (f32 width) :lock lock) :look 'lb-look))

;;; ---------------------------------------------------------------- the awakened stance, the routes, the volley
(defun br-go-ranged (e)
  "The turn's last frame: the stance EN (its standing clock from 0, R12); L still held *BR-TO-DASH-HELD* frames or more (a
long press, R13): the stance's L, the dash, in its charge at once, the frames held so far its charge's (FIGHTER-HOLD, at
most its *BR-W-L-HOLD*)."
  (let* ((f (fighter e)) (form (fighter-form f)) (to (br-ranged-of form)) (vp (pilot-vpad (pilot e))))
    (setf (brs-en-t (br e)) 0)
    (unless (eq to form) (set-form e to) (pace e :to-ranged))
    (let ((held (vpad-held vp :sig)) (dash (kit-command-move (fighter-kit f) :sig)))
      (when (and (>= held *br-to-dash-held*) dash (mv-hold dash) (br-ranged-form-p (fighter-form f)))
        (start-move e dash :sig)
        (setf (fighter-hold f) (min held (1- *br-w-l-hold*)))
        (pace e :to-dash)))))
(defun br-halt-tick (e) "The turn, the volley: no string chase." (halt! e))
(defparameter *br-link-k-s* 14
  "R17 (DUEL_LILLE_V3 §21): the stance K1 started off the link's turn enters this far from its hit (its startup 16 cut to the
roster's K link 14: a KIN J1 / J2 that hit combos into it); the stance J1 (S 8) and L (its charge, held) as they are ([G]).")
(defun br-to-en-link-tick (e)
  "The turn into the stance off a KIN J / K link (:br-to-en-l, R17: 「取消切架勢的前後搖，使連段能銜接起來」): halted as the turn;
a human's J / K / L pressed in it (buffered) skips it: the stance EN at once (its stand from 0) and its J1 / K1 / L started now,
the turn's frames so far counted as the opener's startup (K1's cut to *BR-LINK-K-S* first; at least 1 f left; its skipped
frames' hooks run), L in its charge (held). His CPU makes the same link by its own call (BR-AI-LINK-CMD, dream-rsi b1a0: its
L held by its brain for the dash's level)."
  (halt! e)
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (b (br-tick-brain e)))
    (when (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main))
      (let ((cmd (if b
                     (br-ai-link-cmd e f b)
                     (cond ((vpad-command-pressed-p vp :quick nil) :q) ((vpad-command-pressed-p vp :flash nil) :f)
                           ((vpad-command-pressed-p vp :sig nil) :sig)))))
        (when cmd
          (unless b (vpad-consume! vp (case cmd (:q :quick) (:f :flash) (t :sig))))
          (let ((form (br-ranged-of (fighter-form f))) (spent (fighter-sf f)))   ; (the turn's frames gone: the opener's)
            (unless (eq form (fighter-form f)) (set-form e form) (pace e :to-ranged))
            (setf (brs-en-t (br e)) 0)
            (pace e :link-cut)
            (let ((mv (kit-command-move (fighter-kit f) cmd)))
              (start-move e mv (and (mv-hold mv) :sig))
              (when (and b (mv-hold mv))                                          ; (his CPU: L held for the level)
                (let ((lv (br-ai-dash-level (br-ai-seen-d e (br-ai-seen b)))))
                  (ai-press b :sig (nth (1- (br-learn-charge e b (if lv (br-ai-plan-level (br-ai-charge-p e b) lv
                                                                                    (br-ai-dash-floor (br-ai-seen-d e (br-ai-seen b))))
                                                                      1)))
                                        *br-ai-hold*)
                            :act :hold)))
              (turn-to-opp e f 10.0)
              (when (and (member cmd '(:q :f)) (eq (fighter-phase f) :main))
                (let ((cut (min (1- (mv-s mv)) (+ spent (if (eq cmd :f) (max 0 (- (mv-s mv) *br-link-k-s*)) 0)))))
                  (loop for fr from 1 to cut while (eq (fighter-move f) mv)
                        do (loop for (hf hook) in (mv-on-frame mv) when (= hf fr) do (funcall hook e)))
                  (when (eq (fighter-move f) mv)
                    (setf (fighter-sf f) cut)
                    (play-clip e (kit-move-clip (fighter-kit f) (mv-clip mv)) :blend 0 :speed (mv-clip-speed mv)
                               :time (/ (* cut (mv-clip-speed mv)) 60.0))))))))))))
(defun br-recall-go (e)
  "The owl's SP2, f0: every wing spent and counted (the full volley, decision R3: 「併入梟頭的 SP2」, the one spend-all of
the owl)."
  (let ((st (br e)))
    (setf (brs-recall-n st) (brs-ammo st) (brs-ammo st) 0)
    (pace e :volley) (pace e (intern (format nil "VOLLEY-T~d" (br-recall-tier (brs-recall-n st))) :keyword))
    (emit :sfx :rift-open e)))
(defun br-recall-fire (e)
  "The volley's f7 (on its own, its charge's last frame): the derivative string for its count (BR-RECALL-TIER), facing him."
  (let* ((f (fighter e)) (tier (br-recall-tier (brs-recall-n (br e)))))
    (turn-to-opp e f 10.0)
    (start-move e (kit-next (fighter-kit f) :br-recall (svref #(:rc0 :rc1 :rc2 :rc3 :rc4) tier)))))
(defun br-rc-tick (e)
  "The volley's strings: he keeps on the opponent (*BR-RC-TRACK*)."
  (halt! e)
  (turn-to-opp e (fighter e) (track-step *br-rc-track*)))
(defun br-rc-shot (e) "A volley line: its look." (br-spawn-look e :shot *br-x-len* 0.05 t) (emit :sfx :lb-crack e))

(defun br-hz (h hz ev &optional a b c dd ee)
  "His hazards' hook: a 裁きの光明 ground line's burning span; the looks touch nothing."
  (declare (ignore h))
  (case ev
    (:touches
     (when (eq (hazard-kind hz) :br-cut)                 ; (R11: a cut of the L dash, on him: his body's column)
       (return-from br-hz (cyl-cyl-hit-p (hazard-x hz) 0f0 (hazard-z hz) (hazard-size hz) 2.4f0 a b c dd ee)))
     (when (eq (hazard-kind hz) :br-misuji)
       (multiple-value-bind (from to) (br-misuji-span (hazard-age hz))
         (and (> to from)
              (let* ((yaw (hazard-yaw hz)) (mid (* 0.5 (+ from to))))
                (obox-cyl-hit-p (f32 (+ (hazard-x hz) (* mid (fwd-x yaw)))) 1f0 (f32 (+ (hazard-z hz) (* mid (fwd-z yaw))))
                                yaw (f32 (* 0.5 *br-misuji-width*)) 1.2f0 (f32 (* 0.5 (- to from)))
                                a b c dd ee))))))
    (t nil)))

;;; ---------------------------------------------------------------- the owl's SPs (the old KIN's, copied)
(defun br-misuji (e)
  "The chop's frame: a 裁きの光明 ground line per :fan angle (one hit group: one line at most hits him), each erupting from
1 m to 18 m (BR-MISUJI-SPAN), through guard (chip 15 %, the :guard drain), once."
  (let* ((p (pos-of e)) (fan (move-param e :fan)) (group (make-hit-group 1)))
    (dolist (a fan)
      (spawn-hazard :br-misuji e :x (aref p 0) :z (aref p 2) :yaw (+ (yaw-of e) (deg a)) :size *br-misuji-to*
                                 :life (br-misuji-frames) :group group :hook 'br-hz :look 'lb-look
                                 :data (make-lbh :kind :sabaki :len (f32 *br-misuji-to*) :width (f32 *br-misuji-width*))
                                 :hw (make-hitwin :dmg (move-param e :dmg) :react :stagger :kb 1.0 :hs *hitstop-heavy*
                                                  :chip 0.15 :guard (move-param e :guard)
                                                  :flags '(:ranged :x-axis :uncatchable))))
    (pace e :misuji)
    (emit :sfx :ground-crack e)))
;;; ================================================================ AI (DUEL_LILLE_V3 §6.3; the route CPU, dream-rsi b1a0, §22)
;;; His CPU: his kits' :ai keys (every chance x *BR-AI-DIFF* by difficulty: EASY <= NORMAL <= HARD, one roll per event or
;;; window, never per step), the generic bands and string reflex, and these. The policy is a set of ROUTES, each picked once
;;; at its event from his own state and the perceived opponent; the stance is never a place to wait:
;;;   confirm  an attack-state J / K link that hit -> L (:l-after-j / -k) -> the stance's string at once: the base stance J
;;;            (the gun-kata, S 10) off a J link, its K (the rifle, S 16) off a K link (BR-AI-STANCE-PLAN :combo); awakened
;;;            the turn skipped (R17's link, his CPU's own call in BR-TO-EN-LINK-TICK: BR-AI-LINK-CMD) into EN K1 / J1
;;;   string   the stance's J / K strings go on by the generic latch; at the link points one call (BR-S-CPU-CALL): the
;;;            spending L L follow-up while a special is left, SP2 at a string's end when no follow-up can be paid
;;;   charge   the specials come from the charged L: the base snipe held to level 2 / 3 by the distance (the stance's L,
;;;            BR-AI-KAMAE presses and holds L), the awakened dash held to level 2 / 3 (BR-AI-SIG-HOLD, the kit's :sig-hold:
;;;            KIN's L held is the dash's charge at the turn's end, R13); the far window (BR-AI-REFLEX) opens them
;;;   EN       the rooted stance: one plan per standing window (BR-AI-EN-PLAN: K / J in reach, else the charged dash, else
;;;            the fast Step in), never a wait
;;;   base     the stance's pick by the distance (BR-AI-STANCE-PLAN): J / K in their reach, else the snipe; his attack coming
;;;            the stance Step 飛廉脚 (iframes) and a fresh pick from 5 m out
;;;   cash     (dream-rsi b1a2) every link that hit goes into the stance (:l-after-j / -k 1.0 in the attack states: no plain
;;;            K2s / K3 bridge, the base's J the gun-kata); the base stance at the pips' cap cashes them from range
;;;            (BR-AI-CASH-PLAN: HIRENKYAKU's slide back and 萬物貫通 line instead of a snipe whose gain is lost); :charge /
;;;            :follow / :sp2 0.6 -> 0.7 (HARD x1.5: every charge, line and cash-out; NORMAL x0.3 0.18 -> 0.21)
;;;   base     (dream-rsi b2a0, combined onto round 2 b1a2's line-reader) the never-awakened base form's own plan, the
;;;            rifle's ladder: every J link that hit -> its K link (K2s) -> L -> the stance K string (the rifle swung, 46 /
;;;            46 / 66) whose L L lines spend the pips (70 a pip), never the gun-kata's 15s off a confirm (:l-after-j 0,
;;;            :string-k 1); the pips loaded from range (:charge / :far-snipe its own tables, a failed roll the line's floor,
;;;            BR-AI-SNIPE-FLOOR), spent in close (:follow / :sp2 its own tables); the range by the pips (BR-AI-LADDER:
;;;            loading the zone, full the pressure); the far snipe only in sight (BR-AI-SIGHT-P: his offset and drift
;;;            across the line small by the shot); a Hoho on a charge the line does not read answered by the charge's Step
;;;            (*BR-AI-HOHO-STEP-P*); no long neutral guard (:neutral-guard 0.1) and no stance K1 into a free man in J's
;;;            reach (:j-share 1)
(defparameter *br-ai-diff* '(:easy 0.2 :normal 0.3 :hard 1.5)
  "His CPU's chances (his kits' :ai :p values) x this by difficulty, at most 1 (the old Lille's *LB-AI-DIFF*).")
(defparameter *br-ai-every* 30 "Frames between two of his window rolls (the far snipe / dash, the burst; new 2026-10-09).")
(defparameter *br-ai-hold* '(1 24 44)
  "Frames his CPU holds L for a charged L of level 1 / 2 / 3 (the levels at 20 / 40 f held, *BR-W-L-LEVELS*; dream-rsi b1a0).")
(defparameter *br-ai-dash-reach* '(4.5 10.2)
  "The awakened dash at level 2 / 3: his CPU charges level 2 inside the first (m), level 3 inside the second (the dash's
longest 10 m + its 0.9 m volume - the 0.5 m it must still pass); farther, the fast Step first (dream-rsi b1a0; b1a1: level 2
only inside 4.5 m, 6.4 before: level 3's six cuts and three wings from mid range, the let-go covering the longer hold).")
(defparameter *br-ai-dash-min* 3.0 "Closer than this (m) his awakened L is a tap (the stance's strings reach; dream-rsi b1a0).")
(defparameter *br-ai-facing* 1.0
  "Radians: him reeling farther round than this from his facing (the dash leaves him 1.6 m behind Lille), his CPU turns before
a follow-up (dream-rsi b1a1: the generic follow-up J1 whiffed 253 of 258 times after the dash in b1a0's logs).")
(defparameter *br-ai-turn-p* '(:easy 0.2 :normal 0.3 :hard 1.0)
  "... this share of his actions by difficulty (one roll per action of his: the react roll), else the generic follow-up at once.")
(defparameter *br-ai-kikon-p* '(:easy 0.05 :normal 0.15 :hard 1.0)
  "His Kikon only on an opening (BR-AI-KIKON, dream-rsi b1a1, cell b2a0's rule): him red, perceived reeling / recovering with
the rush's aura + startup + 2 f left past the perception delay, within 11 m; this share of his actions by difficulty. Every
form's :kikon-range 0: the generic neutral / reeling rush never fires (b1a0: 253 Kikons, 54 hits, 45 openings on him).")
(defparameter *br-ai-unguard-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "His answer to a long guard up close (the generic Breaker's moment), this share of his guards by difficulty: back off to his
L's range (BR-AI-UNGUARD; dream-rsi b1a1: b1a0's guard-break Breakers hit 31 of 160 and opened 66 combos on him).")
(defparameter *br-ai-unguard-to* 5.5 "... to this many metres (the snipe's / the dash's range).")

;; pure: host-tested
(defun br-ai-chance (p difficulty) "A chance P of his kit's :ai at DIFFICULTY: x *BR-AI-DIFF*, at most 1." (min 1.0 (* p (getf *br-ai-diff* difficulty 1.0))))
(defun br-ai-p (k key difficulty)
  "Pure: the chance KEY of the kit table K (its :stance, :far-snipe) at DIFFICULTY: a difficulty table (:easy .. :normal ..
:hard ..) as it reads (dream-rsi b2a0: the base form's own tables), else a plain chance x *BR-AI-DIFF* (BR-AI-CHANCE)."
  (let ((v (getf k key 0.0)))
    (if (consp v) (getf v difficulty 0.0) (br-ai-chance v difficulty))))
(defun br-ai-snipe-level (d k)
  "The base snipe's level his CPU charges at the distance D (K: the kit's :stance): 3 from :far m (the 31 m line through
guard), else 2 (the 12 m shot)."
  (if (>= d (getf k :far 7.0)) 3 2))
(defun br-ai-dash-level (d)
  "The awakened dash's level his CPU charges at the distance D (*BR-AI-DASH-REACH*): 2, 3, or NIL (closer than
*BR-AI-DASH-MIN*: the strings; farther than level 3 reaches: the fast Step)."
  (cond ((< d *br-ai-dash-min*) nil)
        ((<= d (first *br-ai-dash-reach*)) 2)
        ((<= d (second *br-ai-dash-reach*)) 3)))
;; (dream-rsi round 2 b1a1, the line-reader refined) the line has a length: a charge is never released at a level whose line
;; cannot reach him. The failed charge roll (NORMAL x0.3: 4 L presses of 5) used to be a tap: the level-1 snipe (4 m) from
;; the far window's 6 m+, the level-1 dash (6 m) from 7-10 m, a whiff and a punish every time (round 2 b1a0's NORMAL logs).
;; The roll now decides only the level by the plan (BR-AI-SNIPE-LEVEL / -DASH-LEVEL); a failed one takes the lowest level
;; that still reaches (BR-AI-FLOOR-LEVEL): a rule, the same at every difficulty, not a chance.
(defparameter *br-ai-dash-floor* '(6.4 8.4)
  "The awakened dash's lowest reaching level by the distance (m): level 1 inside the first (its 6 m + the 0.9 m volume -
0.5 m it must still pass), level 2 inside the second (8 m + 0.9 - 0.5), else level 3 (dream-rsi round 2 b1a1).")
(defun br-ai-floor-level (d reach1 reach2)
  "Pure: the lowest charge level whose line reaches D m (REACH1 / REACH2: level 1's / level 2's reach): 1, 2 or 3."
  (cond ((<= d reach1) 1) ((<= d reach2) 2) (t 3)))
(defun br-ai-plan-level (charged lv floor)
  "Pure: the level his CPU holds a charge for: CHARGED (the :charge roll passed) the planned LV, never under FLOOR (the lowest
level that reaches him: BR-AI-FLOOR-LEVEL); else FLOOR."
  (if charged (max lv floor) floor))
(defun br-ai-snipe-floor (e d)
  "The base snipe's lowest reaching level at D m (the level-1 shot's reach on him, level 2's 12 m)."
  (br-ai-floor-level d (br-ai-reach e :br-s-l1) (+ *br-snipe-len-2* (body-hurt-r (model-body (model (opp-of e)))))))
(defun br-ai-dash-floor (d)
  "The awakened dash's lowest reaching level at D m (*BR-AI-DASH-FLOOR*)."
  (br-ai-floor-level d (first *br-ai-dash-floor*) (second *br-ai-dash-floor*)))

(defun br-ai-stance-plan (r d jr kr fs bars k &key threat combo from-k)
  "His CPU's base stance pick from one roll R at the distance D (JR / KR: the stance J1's / K1's reach on him; K: the kit's
:stance): his attack coming (THREAT, not in a COMBO) the Step (:step of the time); a COMBO (the stance opened off a link
that hit): the K string in its reach off a K link (FROM-K) or out of J's reach, else J (they combo: J S 10 off J's flinch,
K S 16 off K's stagger); in J's reach J when the flash step FS is under :recover-fs or the Reiatsu BARS under :recover-bars
or :j-share of the time, else K (the damage); in K's reach K; farther the snipe, :KAMAE-L (its level: BR-AI-SNIPE-LEVEL)."
  (cond ((and threat (not combo) (< r (getf k :step 0.0))) :kamae-step)
        ((and combo (<= d kr) (or from-k (> d jr))) :kamae-k)
        ((and combo (<= d jr)) :kamae-j)
        ((<= d jr) (if (or (< fs (getf k :recover-fs 40.0)) (< bars (getf k :recover-bars 1)) (< r (getf k :j-share 0.3)))
                       :kamae-j :kamae-k))
        ((<= d kr) :kamae-k)
        (t :kamae-l)))
(defun br-ai-en-plan (r d jr kr k dashed)
  "His CPU's plan for one standing window of the awakened stance EN (one roll R; D the distance, JR / KR the stance J1's /
K1's reach on him; K the kit's :stance; DASHED its fast Step spent): K in its reach (in J's reach :j-share of the time J,
the top's refill), the charged dash where it reaches (BR-AI-DASH-LEVEL), else the fast Step in (NIL: spent, the window runs out back to KIN). :Q, :F, :SIG, :STEP or NIL."
  (cond ((<= d jr) (if (< r (getf k :j-share 0.25)) :q :f))
        ((<= d kr) :f)
        ((br-ai-dash-level d) :sig)
        ((not dashed) :step)))
(defun br-ai-burst-p (r ammo fs d k difficulty)
  "Does his awakened CPU burst into the owl (K: the kit's :burst) from one roll R: AMMO >= :wings, FS >= the burst's
*FS-BURST*, him inside :in m, :p x the DIFFICULTY?"
  (and k (>= ammo (getf k :wings 5)) (>= fs *fs-burst*) (< d (getf k :in 6.0))
       (< r (br-ai-chance (getf k :p 0.0) difficulty))))

(defun br-ai-seen (b)
  "The SNAP brain B perceives this step (BRAIN-PERCEIVE's ring at the delay; NIL before it holds one): for his ticks, which
run inside moves where the reflexes don't (the old LB-AI-SEEN)."
  (let* ((ring (brain-ring b)) (n (length ring)))
    (and (plusp n) (svref ring (mod (- (brain-head b) 1 (brain-delay b)) n)))))
(defun br-ai-seen-d (e s)
  "The distance from E to the opponent as perceived (SNAP S; NIL: the real one)."
  (if s
      (let ((p (pos-of e))) (sqrt (+ (expt (- (snap-x s) (aref p 0)) 2) (expt (- (snap-z s) (aref p 2)) 2))))
      (fighter-dist (fighter e))))
(defun br-ai-reach (e name)
  "Move NAME's whole reach on E's opponent (BR-MOVE-REACH + his body)."
  (+ (br-move-reach (find-move name)) (body-hurt-r (model-body (model (opp-of e))))))
(defun br-ai-threat-p (e s d)
  "Is his perceived move S coming at E (live, in reach + 1 m: SNAP-NEAR-P)?"
  (and s (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
       (snap-live-p s) (snap-near-p s e d 1.0)))
(defun br-ai-charge-p (e b)
  "One roll per press: does his CPU charge this L (the kit's :stance :charge x the difficulty)?"
  (< (sim-rnd01) (br-ai-p (ai-table e :stance) :charge (brain-difficulty b))))

(defparameter *br-ai-cash-p* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "His base stance's cash-out (dream-rsi b1a2): the pips full (*BR-AMMO-MAX*: a snipe's gain would be lost) and SP2's bars
there, a snipe plan (him out of the melee strings' reach) becomes the stance's SP2 HIRENKYAKU (the 6 m slide back and its
萬物貫通 line, every pip spent: 50 + 40 a pip), this share of those stances by difficulty (one roll a stance). b1a1's logs: 218
level-2 snipes in 40 HARD matches ended at 3 pips, most of them at the cap already (their +2 lost).")

(defun br-ai-cash-plan (plan n cap ok r p)
  "Pure: the base stance's PLAN with N pips (CAP the most), OK (SP2 may start: its bars, him not down), one roll R against P:
:KAMAE-SP2 for a snipe plan (:KAMAE-L) at the cap, else PLAN."
  (if (and (eq plan :kamae-l) (>= n cap) ok (< r p)) :kamae-sp2 plan))

(defun br-ai-kamae (e f st b)
  "His CPU's pick in the base stance (BR-KAMAE-TICK, from f6): once a stance (one roll, BR-AI-STANCE-PLAN; a learner's read
may change it, BR-LEARN-KAMAE); the snipe's L pressed and held for its level (*BR-AI-HOLD*, BR-AI-SNIPE-LEVEL; :charge of
the time, else a tap); a Step plan clears itself so the window after it (5 m out) picks again."
  (unless (brs-k-plan st)
    (let* ((k (ai-table e :stance)) (g (gauges e)) (s (br-ai-seen b)) (d (br-ai-seen-d e s))
           (left (if (and s (snap-punishable-p s) (< (snap-left s) 99)) (snap-left-seen s b) 0))   ; (his frames left)
           (combo (or (member (mv-name (fighter-move f)) '(:br-kamae-j :br-kamae-k))
                      (>= left (+ (mv-s (find-move :br-s-j1)) 2))))
           (plan (br-ai-stance-plan (sim-rnd01) d (br-ai-reach e :br-s-j1) (br-ai-reach e :br-s-k1) (gauges-fs g)
                                    (reiatsu-bars e) k :threat (br-ai-threat-p e s d) :combo combo
                                    :from-k (or (eq (mv-name (fighter-move f)) :br-kamae-k)
                                                (>= left (+ (mv-s (find-move :br-s-k1)) 2))))))
      (setf plan (br-learn-kamae e b plan))
      (setf plan (br-ai-cash-plan plan (brs-ammo st) (br-ammo-cap :base)   ; (the pips full: cash them from range)
                                  (and s (not (member (snap-state s) '(:down :wakeup)))
                                       (kit-command-ok-p e :sp2 (fighter-kit f) nil
                                                         (kit-next (fighter-kit f) (mv-name (fighter-move f)) :kamae-sp2)))
                                  (sim-rnd01) (getf *br-ai-cash-p* (brain-difficulty b) 0.0)))
      (setf plan (br-ai-cash-wary plan (brs-ai-cash-read st) left))   ; (round 2 b1a2: a Hoho reader read)
      (when (eq plan :kamae-sp2)                          ; (its answer read at his next free step: BR-AI-CASH-READ)
        (setf (brs-ai-cash-t st) *match-tick* (brs-ai-cash-hp st) (+ (gauges-taken-melee g) (gauges-taken-ranged g))))
      (when (and (eq plan :kamae-step) (not (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g))))
        (setf plan :kamae-l))
      (setf (brs-k-plan st) plan (brs-ai-resume st) nil)
      (when (eq plan :kamae-l)                            ; (the snipe: L held from its start, BR-KAMAE-GO's hold phase)
        (ai-press b :sig (nth (1- (br-learn-charge e b (br-ai-plan-level (br-ai-charge-p e b) (br-ai-snipe-level d k)
                                                                          (br-ai-snipe-floor e d))))
                              *br-ai-hold*)
                  :act :hold))
      (pace e (intern (format nil "AI-~a" plan) :keyword))
      (why b :kamae plan)))
  (let ((plan (brs-k-plan st)))
    (when (eq plan :kamae-step) (setf (brs-k-plan st) nil))
    plan))

(defun br-ai-sig-hold (kit d &optional e)
  "His kits' :sig-hold (ai.lisp AI-COMMAND, the ASSIST's too: the brain through AI-BRAIN): frames L is held. The base form's
L and a link's L are taps (the stance's own pick holds the snipe: BR-AI-KAMAE); awakened from neutral (KIN: the turn, then
the dash's charge at once; EN: the dash) the dash charged by the distance (BR-AI-DASH-LEVEL, *BR-AI-HOLD*; :charge of the
time), else a tap (the stance's strings in reach, the fast Step from afar)."
  (declare (ignore kit))
  (let* ((f (and e (fighter e))) (b (and e (ai-brain e))) (lv (br-ai-dash-level d)))
    (if (and f b lv (not (eq (fighter-form f) :base)) (not (eq (fighter-state f) :move)))
        (nth (1- (br-learn-charge e b (br-ai-plan-level (br-ai-charge-p e b) lv (br-ai-dash-floor d)))) *br-ai-hold*)
        1)))

(defun br-ai-link-cmd (e f b)
  "His CPU's own R17 link (BR-TO-EN-LINK-TICK, the turn off a KIN J / K link that hit: his CPU pressed L there only on a hit):
the stance's opener now, the turn skipped: K1 in its reach (cut to *BR-LINK-K-S*: it combos), J1 in J's, else the dash
(:SIG, charged by the distance). One call a turn (its first frame)."
  (when (<= (fighter-sf f) 1)
    (let* ((form (br-ranged-of (fighter-form f))) (pre (if (br-owl-form-p form) "BR-OE" "BR-E"))
           (d (br-ai-seen-d e (br-ai-seen b))))
      (cond ((<= d (br-ai-reach e (intern (format nil "~a-K1" pre) :keyword))) :f)
            ((<= d (br-ai-reach e (intern (format nil "~a-J1" pre) :keyword))) :q)
            ((br-ai-dash-level d) :sig)))))

(defparameter *br-ai-breaker-v* 0.16 "A Breaker dash's metres per frame (9-10 m/s: *BREAKER-SPEED-MIN* / -MAX), his CPU's timing.")
(defparameter *br-ai-anti-breaker* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "His CPU answers a Breaker by the reach model (BR-AI-ANTI-BREAKER), this share of the Breakers by difficulty (one roll
each: its react roll; NORMAL low: his NORMAL must stay a fair game, DUEL_LILLE_V3 §22's band); his J1's 1.45 m met the generic J1 too late (the strike landed 4-5 f into it: 75 of 106 Breaker hits on
the base form, dream-rsi b1a0).")
(defun br-ai-anti-breaker (e b s d)
  "His Breaker in its aura / dash within 6 m (one roll per Breaker, BRAIN-REACT-ROLL): where it is when our K1 / J1 would be
active (its dash at *BR-AI-BREAKER-V* from where we saw it a perception delay ago) and when its strike lands (the trigger
range, then its startup): K1 when it gets there in K1's reach before the strike, else J1, else a Hoho close to the strike;
meanwhile :WAIT (the generic J1 would come late). The attack-state forms only."
  (when (and (eq (snap-kind s) :breaker) (member (snap-phase s) '(:aura :dash)) (< d 6.0)
             (< (brain-react-roll b) (getf *br-ai-anti-breaker* (brain-difficulty b) 0.0)))
    (let* ((kit (kit-of e)) (v *br-ai-breaker-v*) (dl (brain-delay b)) (trig *breaker-trigger*)
           (dash (if (eq (snap-phase s) :dash) dl (- dl *breaker-aura*)))
           (wait (max 0 (- dash)))
           (de (- d (* v (max 0 dash))))
           (strike (+ wait (/ (max 0.0 (- de trig)) v) *breaker-startup*)))
      (flet ((fits (cmd)
               (let ((mv (kit-command-move kit cmd)))
                 (and mv (kit-command-ok-p e cmd) (< (+ (mv-s mv) 1) strike)
                      (<= (max trig (- de (* v (max 0 (- (mv-s mv) wait))))) (+ (mv-reach mv) 0.3))))))
        (cond ((fits :f) (why b :anti-breaker :f))
              ((fits :q) (why b :anti-breaker :q))
              ((and (<= strike 13) (hoho-ready-p e)) (why b :anti-breaker :hoho))
              ((> strike 13) :wait))))))

(defun br-ai-stance-punish (e b s d f form)
  "Free, him recovering or reeling as perceived with time for the stance's opener (the base stance up in 6 f + its J1, the
awakened turn 12 f + EN's J1; :punish of the time on his react roll, one per action of his) and in its reach: L, the stance
(its pick then sees the frames left: J, K when they fit, BR-AI-KAMAE; EN's plan, BR-AI-EN) instead of a plain J1: the punish
a signature string (dream-rsi b1a0)."
  (let ((k (ai-table e :stance)))
    (when (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f)) (getf k :punish)
               (snap-punishable-p s) (< (snap-left s) 99) (not (br-ranged-form-p form)))
      (let* ((base (eq form :base)) (pre (cond (base "BR-S") ((br-owl-form-p (br-ranged-of form)) "BR-OE") (t "BR-E")))
             (jr (br-ai-reach e (intern (format nil "~a-J1" pre) :keyword)))
             (lead (+ (if base *br-kamae-up* *br-to-en-f*) (mv-s (find-move (intern (format nil "~a-J1" pre) :keyword))) 2)))
        (when (and (>= (snap-left-seen s b) lead) (<= d jr) (kit-command-ok-p e :sig)
                   (< (brain-react-roll b) (br-ai-p k :punish (brain-difficulty b))))
          (pace e :ai-stance-punish) (why b :stance-punish :sig))))))

(defun br-ai-en (e b s d f st)
  "The awakened stance EN, free: one plan per standing window (its epoch: the tick its standing clock started, BRS-EN-T),
BR-AI-EN-PLAN, pressed at once (the window lasts *BR-EN-HOLD* f); his attack coming: NIL (the generic guard)."
  (let ((epoch (- *match-tick* (brs-en-t st))))
    (unless (or (= epoch (brs-ai-t st)) (br-ai-threat-p e s d) (member (snap-state s) '(:down :wakeup :hoho))
                (and (not (br-ai-facing-p e s))   ; (the dash goes where he faces: wait for the turn, round 2 b1a0)
                     (> d (br-ai-reach e (if (br-owl-form-p (fighter-form f)) :br-oe-k1 :br-e-k1)))))
      (setf (brs-ai-t st) epoch)
      (let* ((pre (if (br-owl-form-p (fighter-form f)) "BR-OE" "BR-E"))
             (plan (br-ai-en-plan (sim-rnd01) d (br-ai-reach e (intern (format nil "~a-J1" pre) :keyword))
                                  (br-ai-reach e (intern (format nil "~a-K1" pre) :keyword)) (ai-table e :stance)
                                  (brs-dashed st))))
        (pace e (intern (format nil "AI-EN-~a" plan) :keyword))
        (case plan
          ((nil) nil)
          (:step (ai-press b :step 2 :act :dash) (setf (brain-dash b) 1f0 (brain-dash-to b) 0f0)
                 (why b :en-step :pressed))
          (t (why b :en plan)))))))

(defparameter *br-ai-step-in-p* '(:easy 0.03 :normal 0.08 :hard 1.0)
  "His answer to the opponent's Step in (BR-AI-STEP-IN, dream-rsi b1a1): this share of his Steps by difficulty (one roll a
Step), his J1 timed to land past the Step's iframes, before its J cancel's hit (b1a0 / v1 logs: the opponents' STEP-IN ->
STEP-J was the most common opener on his idle attack-state forms).")
(defparameter *br-ai-step-in-v* 0.08 "... the Step perceived closing on him faster than this (m / f; a Step's hop is 0.21) ...")
(defparameter *br-ai-step-in-late* 18 "... and our J1's hit landing by his Step's frame this (his J cancel f12 + a J1's startup).")

(defun br-ai-closing (b s d e)
  "His perceived speed toward E (m / f, > 0 coming): the SNAP S and the one before it in brain B's ring."
  (let* ((ring (brain-ring b)) (n (length ring))
         (s1 (and (plusp n) (svref ring (mod (- (brain-head b) 2 (brain-delay b)) n)))) (p (pos-of e)))
    (if (or (null s1) (null s) (< d 0.01))
        0.0
        (+ (* (- (snap-x s) (snap-x s1)) (/ (- (aref p 0) (snap-x s)) d))
           (* (- (snap-z s) (snap-z s1)) (/ (- (aref p 2) (snap-z s)) d))))))

(defun br-ai-step-in-plan (sf delay js closing d reach)
  "Pure: his Step perceived at its frame SF (a perception DELAY ago), closing at CLOSING m / f, D metres off; our J1's startup
JS and its REACH on him. Our J1 pressed now hits at his Step's frame SF + DELAY + JS: :GO when that is past the iframes
(*STEP-IFRAMES*) and by *BR-AI-STEP-IN-LATE* with him then in reach (his hop: CLOSING a frame up to its f12); :WAIT while
it would land in his iframes; else NIL."
  (let ((k (+ sf delay js)))
    (cond ((< closing *br-ai-step-in-v*) nil)
          ((> k *br-ai-step-in-late*) nil)
          ((<= (- d (* closing (max 0 (- (min k *step-j-cancel*) (min sf *step-j-cancel*))))) reach)
           (if (<= k (second *step-iframes*)) :wait :go)))))

(defun br-ai-step-in (e b s d f st)
  "His opponent's Step in (perceived): one roll a Step (*BR-AI-STEP-IN-P*); his J1 (the form's :q) timed by
BR-AI-STEP-IN-PLAN: it meets him as he lands, before his Step's J (the R17 link / the stance from that J's hit). :Q, :WAIT
or NIL. The attack-state forms, free."
  (when (and (eq (snap-state s) :step) (member (fighter-state f) '(:idle :run :guard)) (kit-command-ok-p e :q))
    (let ((key (- *match-tick* (brain-delay b) (snap-sf s))))
      (unless (= key (brs-ai-step-key st))
        (setf (brs-ai-step-key st) key
              (brs-ai-step-go st) (< (sim-rnd01) (getf *br-ai-step-in-p* (brain-difficulty b) 0.0))))
      (when (brs-ai-step-go st)
        (let* ((q (kit-command-move (kit-of e) :q))
               (plan (br-ai-step-in-plan (snap-sf s) (brain-delay b) (mv-s q) (br-ai-closing b s d e) d
                                         (+ (br-move-reach q) (body-hurt-r (model-body (model (opp-of e))))))))
          (case plan
            (:go (setf (brs-ai-step-go st) nil) (pace e :ai-step-in) (why b :step-in :q))
            (:wait (why b :step-in-wait :wait))))))))

(defparameter *br-ai-exit-p* '(:easy 0.05 :normal 0.15 :hard 1.0)
  "His exit from the awakened stance (BR-AI-EXIT, dream-rsi b1a1): the first free step back in KIN after EN (a string's end
pushed him out to ~2.8 m: the opponents' J1 found him standing there, b1a0 / v2 logs), this share of the exits by
difficulty (one roll an exit): back into the stance while the wing armour covers the turn, else a dash back.")

(defun br-ai-exit-plan (d wings cost dash)
  "Pure: his exit at D metres with WINGS (COST: the armour's price), DASH the charged dash's level there (BR-AI-DASH-LEVEL):
:SIG (L held: the armoured turn into the charged dash) when the armour holds and the dash reaches; else :BACK (a dash back to *BR-AI-UNGUARD-TO*, the dash's range) when he is nearer; else NIL. (Measured: the
re-entry into EN's K1 / J1 from 2.8 m was punished, v3.)"
  (cond ((and (>= wings cost) dash) :sig)
        ((< d *br-ai-unguard-to*) :back)))

(defun br-ai-exit (e b s d f st)
  "The first free step in KIN after the stance EN (BRS-AI-FORM): one roll (*BR-AI-EXIT-P*), BR-AI-EXIT-PLAN; not while his
attack is on him (the guard), nor on a downed opponent. :SIG, :PRESSED or NIL."
  (when (and (not (member (snap-state s) '(:down :wakeup))) (not (br-ai-threat-p e s d))
             (< (sim-rnd01) (getf *br-ai-exit-p* (brain-difficulty b) 0.0)))
    (let ((plan (br-ai-exit-plan d (brs-ammo st) (br-armor-cost (fighter-form f))
                                 (and (br-ai-facing-p e s) (br-ai-dash-level d)))))   ; (the dash where he faces: round 2 b1a0)
      (pace e (if plan (intern (format nil "AI-EXIT-~a" plan) :keyword) :ai-exit-none))
      (case plan
        (:sig (why b :exit :sig))
        (:back (ai-dash b -1.0 *br-ai-unguard-to*) (why b :exit-back :pressed))))))

(defparameter *br-ai-kite-p* '(:easy 0.01 :normal 0.03 :hard 0.8)
  "His kite (BR-AI-KITE, dream-rsi b1a1 after cell b2a0's ward): free in an attack-state form inside the opponent's
first-strike envelope (BR-AI-ENVELOPE), him free, one roll a *BR-AI-KITE-EVERY* window: a dash back to the envelope +
*BR-AI-KITE-OUT* (v4 logs: Kenpachi's FIRST-STRIKE J1 opened him 37 times on an idle KIN in 12 matches, ~350 a combo).")
(defparameter *br-ai-kite-every* 24 "Frames between two of his kite rolls.")
(defparameter *br-ai-kite-out* 2.0 "... out to his envelope + this many metres (the dash's range: the far-dash window picks it).")

(defun br-ai-envelope (e b s d)
  "His first-strike envelope (m): his form's J1 reach + its lunge (at most 0.8 m) + 0.5 m + his perceived closing speed x
15 f (his J1 and his reaction; cell b2a0's model)."
  (let ((q (kit-command-move (kit-of (opp-of e)) :q)))
    (+ (if q (+ (mv-reach q) (min 0.8 (mv-slide q))) 1.6) 0.5 (* 15 (max 0.0 (br-ai-closing b s d e))))))

(defparameter *br-ai-snipe-back* 0.5
  "The base form backs off (the kite, the unguard) to the far snipe's range + this (m): *BR-AI-SNIPE-MIN* + 0.5 = 6.5 m (round 2
b1a1: b1a0 moved the far snipe out to 6 m but its kite still stopped at his envelope + 2 m, ~5-5.7 m, and the unguard at
5.5 m: the base form backed off to where its snipe never starts).")
(defun br-ai-back-to (form to)
  "Pure: the distance (m) his CPU backs off to in FORM, TO the attack state's own: the base form's no nearer than the far
snipe's range (*BR-AI-SNIPE-MIN* + *BR-AI-SNIPE-BACK*); KIN keeps TO (the dash's range)."
  (if (eq form :base) (max to (+ *br-ai-snipe-min* *br-ai-snipe-back*)) to))

(defun br-ai-kite (e b s d f st)
  "Free in an attack-state form, him free (idle, walking, running, guarding) inside his envelope: one roll a window
(*BR-AI-KITE-P*), a dash back out of it to the dash's / the snipe's range. :PRESSED or NIL."
  (when (and (member (fighter-state f) '(:idle :run)) (zerop (brain-press-left b))
             (member (snap-state s) '(:idle :run :guard))
             (>= (- *match-tick* (brs-ai-kite st)) *br-ai-kite-every*)
             (<= d (br-ai-envelope e b s d)))
    (setf (brs-ai-kite st) *match-tick*)
    (when (< (sim-rnd01) (getf *br-ai-kite-p* (brain-difficulty b) 0.0))
      (ai-dash b -1.0 (br-ai-back-to (fighter-form f) (+ (br-ai-envelope e b s d) *br-ai-kite-out*)))
      (pace e :ai-kite)
      (why b :kite :pressed))))

(defparameter *br-ai-let-go* '(12 20)
  "His CPU holding a charge (BR-AI-CHARGE-TICK, dream-rsi b1a1): his attack (or his run in) perceived on him lets L go at
once, but a base snipe held this many frames or more short of level 2 (*BR-W-L-LEVELS*' first) holds on into level 2 (its
S 8 lands no later than level 1's S 16 from there, and harder: cell b2a0's finding); the dash lets go at any level (v5
logs: 41 + 49 openings in the charges' hold, 90 of ~800 snipes Perfect-Hoho'd or hit while held).")

(defparameter *br-ai-let-go-p* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "... this share of his charges by difficulty (one roll a charge: its start tick, *MATCH-TICK* - FIGHTER-HOLD).")

(defun br-ai-let-go-p (held snipe threat)
  "Pure: let a charge HELD frames go now, his THREAT perceived? SNIPE: the base snipe (held into level 2 from
*BR-AI-LET-GO*'s first to its second)."
  (and threat (or (not snipe) (not (<= (first *br-ai-let-go*) held (1- (second *br-ai-let-go*)))))))

;;; ---------------------------------------------------------------- the line (dream-rsi round 2, cell b1a0)
;;; R18 froze the charged L's aim at its start (the snipe and the dash go where he faces). Round 2's baseline still released
;;; every charge at its planned hold, wherever the opponent had walked: in its HARD logs 25 % of the dashes left with him
;;; > 1.2 m off the line (1 % hit), and the base snipe started inside the CPUs' threat envelope (the charge move's 4 m reach +
;;; the generic 1.5 m margin: a Hoho on it puts him 1.6 m BEHIND the rooted stance; 153 openings, 30 k damage, in 60 matches,
;;; mostly the generic PUNISH J1 on the whiffed shot's recovery). Here a charge is a held threat: released the frame the
;;; predicted line meets him (BR-AI-LINE-CALL), at the highest level that still lands; the snipe never sits inside his
;;; envelope (the stance Step out, its iframes, and the charge goes on re-aimed: BR-CHARGE-STEP-GO).
(defparameter *br-ai-line-p* '(:easy 0.2 :normal 0.5 :hard 1.0)
  "His charges released by the line (BR-AI-LINE-CALL), this share of them by difficulty (one roll a charge); the rest at
the planned hold (the old rule).")
(defparameter *br-ai-line-margin* 0.1
  "Metres taken off a charged L's half-width on him (its volume's radius + his body's hurt radius) when his CPU reads the line.")
(defparameter *br-ai-line-k* 6 "Steps of the perceived ring his lateral speed is measured over (BR-AI-LINE-OF).")
(defparameter *br-ai-snipe-min* 6.0
  ;; (round 2 b1a2: the far window opens the stance from :far-snipe :in 4.5 again; this stays the line's own range, where
  ;;  his back-offs stop, BR-AI-BACK-TO)
  "The base snipe starts from no nearer (m): the charge move's reach (*BR-S-NEAR* 4) + the CPUs' threat margin
(*AI-THREAT-MARGIN* 1.5) + 0.5: inside it a CPU's Hoho / guard roll answers the charge (the far window's :in 4.5 before).")

(defun br-ai-line-of (e b s &optional (k *br-ai-line-k*))
  "His perceived feet against E's facing line (the frozen aim of a charge): values PERP (signed m off it), ALONG (m ahead of
E) and VPERP (his speed across it, signed m / f, over K steps of brain B's ring; 0 before the ring holds them)."
  (let* ((p (pos-of e)) (yaw (yaw-of e)) (fx (fwd-x yaw)) (fz (fwd-z yaw))
         (dx (- (snap-x s) (aref p 0))) (dz (- (snap-z s) (aref p 2)))
         (ring (brain-ring b)) (n (length ring))
         (s1 (and (< (+ k 1 (brain-delay b)) n) (svref ring (mod (- (brain-head b) 1 k (brain-delay b)) n)))))
    (values (- (* dx fz) (* dz fx)) (+ (* dx fx) (* dz fz))
            (if s1 (/ (- (* (- (snap-x s) (snap-x s1)) fz) (* (- (snap-z s) (snap-z s1)) fx)) k) 0.0))))

(defun br-ai-line-call (lv target perp vperp along to-hit width lo reach next-f next-reach)
  "Pure: his CPU's call on a charge this hold frame (LV the level reached, TARGET the planned one): him PERP m off the frozen
line, crossing it at VPERP m / f, ALONG m ahead; the shot / dash meets him TO-HIT frames after a release, WIDTH its
half-width on him, LO .. REACH its length now, NEXT-F held frames to the next level whose length is NEXT-REACH. :LOST (him
behind its start: a Hoho, a cross-up), :FIRE (the predicted line on him at a level >= 2 and nothing better to wait for: the
target reached, or the next level would find him off it) or :HOLD (level 1, or the line off him: he may walk back onto it)."
  (flet ((on (f r) (and (<= (abs (+ perp (* vperp f))) width) (<= lo along r))))
    (cond ((< along lo) :lost)
          ((< lv 2) :hold)
          ((>= lv target) (if (on to-hit reach) :fire :hold))
          ((and (on to-hit reach) (not (on (+ to-hit next-f) next-reach))) :fire)
          (t :hold))))

(defun br-ai-envelope-p (d closing delay)
  "Pure: is he (D m off, CLOSING m / f, seen DELAY frames ago) inside the CPUs' threat envelope of the base snipe's charge
(*BR-S-NEAR* + *AI-THREAT-MARGIN*): a Hoho / guard roll answers it there."
  (< (- d (* (max 0.0 closing) delay)) (+ *br-s-near* *ai-threat-margin*)))

(defparameter *br-ai-face-max* 0.35
  "Radians: his CPU starts a charge (the snipe's stance, KIN's turn into the dash, EN's dash) only facing him within this: the
charge never turns (R18) and the idle turn (*FACE-RATE*) puts him on his line within a few frames (round 2's baseline
dashed away from him off a dash through him: 25 of 1 300 dash charges began with him behind).")
(defun br-ai-facing-p (e s)
  "Does E face his perceived feet (SNAP S) within *BR-AI-FACE-MAX*?"
  (<= (abs (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))) *br-ai-face-max*))

(defparameter *br-ai-hoho-step-p* '(:easy 0.1 :normal 0.4 :hard 1.0)
  "His answer to a Hoho on a charge the line does not read (BR-AI-CHARGE-TICK, dream-rsi b2a0; round 2 b0a0's piece): his
Hoho perceived (he reappears behind the rooted charge: the shot would go forward into nothing, his PUNISH after it), the
charge's own Step (R18: iframes, 5 m away, the charge kept and re-aimed onto him at its end), this share of those charges
by difficulty (one roll a charge). The line's charges (*BR-AI-LINE-P*) Step out of a Hoho by their own rule.")

(defun br-ai-charge-tick (e f b mv)
  "His CPU's charge (the snipe, the dash; their hold phase, BR-S-TICK), one roll a charge (keyed on its start tick): the
let-go (*BR-AI-LET-GO-P*: his attack perceived in reach + 1 m, or him running / stepping in within 3 m: L let go at the level
reached, BR-AI-LET-GO-P) and the line (*BR-AI-LINE-P*: L held up to the cap, released by BR-AI-LINE-CALL; the snipe inside
his envelope or with him behind it: the charge's Step out, re-aimed, once a stance; refused, the shot). The charge back
from that Step (the sim re-aimed it on him) goes at once at level 2 / 3 from *BR-AI-STEP-FIRE-MIN* m (round 2 b1a2). A
charge the line does not read Steps out of his Hoho (*BR-AI-HOHO-STEP-P*, one roll a charge; b2a0)."
  (let* ((s (br-ai-seen b)) (d (br-ai-seen-d e s)) (st (br e)) (dif (brain-difficulty b)))
    (let ((key (- *match-tick* (fighter-hold f))))
      (when (and (/= key (brs-ai-charge-key st)) (brs-ai-resume st))   ; (the charge back after its Step: the same rolls)
        (setf (brs-ai-resume st) nil (brs-ai-charge-key st) key (brs-ai-stepped st) t))
      (unless (= key (brs-ai-charge-key st))
        (let ((lv (if (and (eq (brain-press b) :sig) (plusp (brain-press-left b)))
                      (br-w-l-level (+ (fighter-hold f) (brain-press-left b)))
                      1)))
          (setf (brs-ai-charge-key st) key (brs-ai-stepped st) nil
                (brs-ai-let-go st) (< (sim-rnd01) (getf *br-ai-let-go-p* dif 0.0))
                (brs-ai-line st) (if (and (>= lv 2) (< (sim-rnd01) (getf *br-ai-line-p* dif 0.0))) lv 0))
          (when (plusp (brs-ai-line st))   ; (L held to the cap: the line ends the press)
            (setf (brain-press-left b) (max (brain-press-left b) (- *br-w-l-hold* (fighter-hold f))))))))
    (when (and s (eq (brain-press b) :sig) (plusp (brain-press-left b)))
      (let* ((snipe (getf (mv-params mv) :charged)) (held (fighter-hold f)) (lv (br-w-l-level held))
             (closing (br-ai-closing b s d e)))
        (flet ((fire (why) (setf (brain-press-left b) 0) (pace e why) t)
               (step-out () (and (br-charge-step-go e f st mv) (setf (brs-ai-resume st) t) (pace e :ai-line-step) t)))
          (cond ((and (brs-ai-let-go st)
                      (br-ai-let-go-p held snipe (or (br-ai-threat-p e s d)
                                                     (and (member (snap-state s) '(:run :step)) (< d 3.0) (> closing 0.05)))))
                 (fire :ai-let-go))
                ((and (brs-ai-stepped st) (>= lv 2) (not (eq (snap-state s) :hoho)) (>= d *br-ai-step-fire-min*))
                 (fire :ai-step-fire))
                ((and (zerop (brs-ai-line st)) (eq (snap-state s) :hoho) (/= (brs-ai-charge-key st) (brs-ai-hoho-key st)))
                 ;; (b2a0: a charge the line does not read meets his Hoho with its Step, one roll a charge; back re-aimed,
                 ;;  the step-fire above; the line's charges have their own Step out below)
                 (setf (brs-ai-hoho-key st) (brs-ai-charge-key st))
                 (when (and (< (sim-rnd01) (getf *br-ai-hoho-step-p* dif 0.0)) (br-charge-step-go e f st mv))
                   (incf (brain-press-left b) (1+ *br-kamae-dash-f*))   ; (L held through the Step: the charge's level kept)
                   (setf (brs-ai-resume st) t)
                   (pace e :ai-hoho-step)))
                ((zerop (brs-ai-line st)))
                ((and snipe (or (eq (snap-state s) :hoho) (br-ai-envelope-p d closing (brain-delay b))))
                 ;; (inside his envelope: on the line at level 2+ the shot; level 2 near (b2a0's hold-on), held; else out)
                 (multiple-value-bind (perp along vperp) (br-ai-line-of e b s)
                   (let ((call (br-ai-line-call lv lv perp vperp along (+ (brain-delay b) 9)
                                                (- (+ 0.25 (body-hurt-r (model-body (model (opp-of e))))) *br-ai-line-margin*)
                                                0.6 (+ (if (= lv 3) *br-x-len* *br-snipe-len-2*) 0.3) 0 0.0)))
                     (cond ((and (not (eq (snap-state s) :hoho)) (eq call :fire)) (fire :ai-env-fire))
                           ((and (not (eq (snap-state s) :hoho)) (< lv 2) (>= held (first *br-ai-let-go*))))
                           ((step-out))
                           ((eq (snap-state s) :hoho))   ; (round 2 b1a1: no shot into his Hoho: he reappears, then the line)
                           ((>= lv 2) (fire :ai-env-shot))))))
                (t
                 (multiple-value-bind (perp along vperp) (br-ai-line-of e b s)
                   (let* ((hurt (body-hurt-r (model-body (model (opp-of e)))))
                          (lvls *br-w-l-levels*) (target (brs-ai-line st))
                          (next-f (cond ((< held (first lvls)) (- (first lvls) held)) ((< held (second lvls)) (- (second lvls) held)) (t 0)))
                          (call (if snipe
                                    (br-ai-line-call lv target perp vperp along (+ (brain-delay b) 9)
                                                     (- (+ 0.25 hurt) *br-ai-line-margin*) 0.6
                                                     (+ (if (= lv 3) *br-x-len* *br-snipe-len-2*) hurt) next-f *br-x-len*)
                                    (br-ai-line-call lv target perp vperp along (+ (brain-delay b) (mv-s mv) 5)
                                                     (- (+ *br-w-dash-r* hurt) *br-ai-line-margin*) 0.0
                                                     (+ (nth (1- lv) *br-w-l-dash-max*) *br-w-dash-reach*)
                                                     next-f (+ (nth (min 2 lv) *br-w-l-dash-max*) *br-w-dash-reach*)))))
                     (case call
                       (:fire (fire :ai-line-fire))
                       (:lost (or (step-out) (fire :ai-line-lost)))))))))))))

(defun br-ai-turn-wait (e b s)
  "He reels (stun / air) farther round than *BR-AI-FACING* from Lille's facing (after the dash through him): :WAIT (the
fighter turns to him) instead of the generic follow-up that whiffs, *BR-AI-TURN-P* of his actions (the react roll)."
  (when (and (member (snap-state s) '(:stun :air))
             (> (abs (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))) *br-ai-facing*)
             (< (brain-react-roll b) (getf *br-ai-turn-p* (brain-difficulty b) 1.0)))
    (pace e :ai-turn)
    (why b :turn :wait)))

(defun br-ai-kikon (e b s d)
  "His Kikon on an opening only: him red, perceived reeling / recovering with the rush's aura + startup + 2 frames left, within
11 m, not when the hits would finish him; *BR-AI-KIKON-P* of his actions (the react roll). :KIKON or NIL."
  (let ((mv (kit-command-move (kit-of e) :kikon)))
    (when (and mv (kikon-ready-p e) (snap-punishable-p s) (< (snap-left s) 99) (<= d 11.0)
               (>= (snap-left-seen s b) (+ (or (rush-param mv :aura) 0) (mv-s mv) 2))
               (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e))
               (< (brain-react-roll b) (getf *br-ai-kikon-p* (brain-difficulty b) 0.0)))
      (pace e :ai-kikon)
      (why b :kikon-punish :kikon))))

;;; ---------------------------------------------------------------- dream-rsi round 2, cell b1a2 (refines b1a1, the line-reader)
(defparameter *br-ai-keep-burst* '(:easy 0.2 :normal 0.5 :hard 1.0)
  "The burst kept for the owl (BR-AI-KEEP-BURST: round 1 b0a2's piece, round 2 b0a1's measure, taken here by b1a2): in the
base form, at a string's end that no stance call cashed (no SP2 / L L line), this share by difficulty skips the generic SP2
cancel / CHAIN REVERSE (ORANGE): every burst drains the whole flash step, and only an awakened burst becomes the owl, his best
form (b1a1's 40-seed HARD logs: the base's ORANGE chain J1 0.26 % of his damage, plain).")
(defun br-ai-keep-burst (e kit)
  "The base form's :sp-ender (ai.lisp STRING-REFLEX, a string link that hit with no link after it, its first step): his own
CPU only (BR-TICK-BRAIN: NIL for a human the ASSIST plays and for the gate's masher), one roll (*BR-AI-KEEP-BURST* by the
deciding brain's difficulty, AI-BRAIN): :KEEP-BURST (a command no form has: nothing pressed, the generic SP2 cancel / ORANGE
after it skipped for this hit), else NIL (the generic ender)."
  (declare (ignore kit))
  (let ((b (and (br-tick-brain e) (ai-brain e))))
    (when (and b (< (sim-rnd01) (getf *br-ai-keep-burst* (brain-difficulty b) 0.0)))
      (pace e :ai-keep-burst)
      :keep-burst)))

(defparameter *br-ai-step-fire-min* 2.5
  "His charge back from its Step (R18: the sim re-aimed it on him at the Step's f9) is let go at once at level 2 / 3 when he
is perceived at least this far (m); nearer (he chased the Step down) the line / the envelope decide as before (b1a2's logs:
the re-aimed shot hit 630 of 848 from 6.5-10 m, its whiffs sat under 2 m).")
(defparameter *br-ai-cash-wary-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "His read of a Hoho reader (BR-AI-CASH-READ): a cash-out the opponent made him pay for (his damage taken between the
cash-out and his next free step) counts, this share of those events by difficulty (one roll an event). b1a1's 40-seed HARD
logs: HIRENKYAKU from neutral was Perfect-Hoho'd 112 of 205 times by Ichigo and 92 of 229 by Rukia (their timed Hohos), never
by the other three: 204 counters, 23 k of his damage taken (4 %), four of his six lost matches against Ichigo.")
(defparameter *br-ai-cash-commit* 20
  "Read once (BR-AI-CASH-READ), his cash-out from neutral waits for an opponent perceived committed this many frames or more
(a move's recovery, a stagger: HIRENKYAKU's line comes at f20, a Hoho from f8 to f20 is perfect); else the stance's snipe.")
(defun br-ai-cash-read (e b st)
  "His free step after a cash-out (BRS-AI-CASH-T): his damage taken since it started (his own gauges) means the opponent
answered it (a Perfect Hoho's counter, a punish): one roll (*BR-AI-CASH-WARY-P*), a read (BRS-AI-CASH-READ). Always NIL (it
only remembers)."
  (when (>= (brs-ai-cash-t st) 0)
    (let ((g (gauges e)))
      (when (> (+ (gauges-taken-melee g) (gauges-taken-ranged g)) (brs-ai-cash-hp st))
        (when (< (sim-rnd01) (getf *br-ai-cash-wary-p* (brain-difficulty b) 0.0))
          (incf (brs-ai-cash-read st))
          (pace e :ai-cash-read)))
      (setf (brs-ai-cash-t st) -1)))
  nil)
(defun br-ai-cash-wary (plan read left)
  "Pure: the base stance's PLAN after the cash-out's (BR-AI-CASH-PLAN) with READ cash-outs answered this match and the
opponent perceived committed LEFT frames: a read cash-out (:KAMAE-SP2) waits for LEFT >= *BR-AI-CASH-COMMIT*, else the
snipe (:KAMAE-L); any other PLAN as it is."
  (if (and (eq plan :kamae-sp2) (plusp read) (< left *br-ai-cash-commit*)) :kamae-l plan))

(defun br-ai-unguard (e b s d f)
  "A long guard of his up close (the generic Breaker's moment: guarding *AI-GUARD-BREAK-HOLD* f within
*AI-GUARD-BREAK-RANGE*): once per guard (its generic Breaker roll taken, BRAIN-BREAK-KEY), *BR-AI-UNGUARD-P* by difficulty,
a dash back to *BR-AI-UNGUARD-TO* (his L's range: the charge, not a Breaker he Hohos). :PRESSED or NIL."
  (when (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
             (/= (brain-break-key b) (snap-start s)) (member (fighter-state f) '(:idle :run :guard))
             (< (brain-react-roll b) (getf *br-ai-unguard-p* (brain-difficulty b) 0.0)))
    (setf (brain-break-key b) (snap-start s))
    (ai-dash b -1.0 (br-ai-back-to (fighter-form f) *br-ai-unguard-to*))
    (pace e :ai-unguard)
    (why b :unguard :pressed)))

;;; ---------------------------------------------------------------- dream-rsi round 2, cell b2a0 (the rifleman's ladder)
(defparameter *br-ai-sight-gap* 0.6
  "The base form's sight (BR-AI-SIGHT-P, dream-rsi b2a0): the far snipe's window opens only when the shot's predicted miss
(his offset from where Lille faces + his perceived drift across the line until the level-2 shot lands) is at most this (m:
the line's 0.25 + his body's ~0.4 - a margin); else it waits for a still / approaching target and the stance's turn (the
window kept).")
(defparameter *br-ai-sight-f* 38
  "... the frames from the window to the level-2 shot's hit (the stance's 6 + L held 24 + its startup 8), + the perception delay.")
(defparameter *br-ai-sight-k* 4
  "... his drift measured over this many steps of the perceived ring (BR-AI-LINE-OF; b2a0's own BR-AI-LATERAL folded into the
line-reader's: the same cross-line speed, the facing gate keeps the two within a few %).")

(defun br-ai-sight-p (d dyaw lateral frames)
  "Pure: does a snipe started now find him (D m away, DYAW rad off Lille's facing, drifting LATERAL m / f across the line as
perceived, the shot FRAMES away)? His predicted miss D sin|DYAW| + |LATERAL| FRAMES within *BR-AI-SIGHT-GAP*."
  (<= (+ (* d (sin (min 1.5 (abs dyaw)))) (* (abs lateral) frames)) *br-ai-sight-gap*))

(defparameter *br-ai-ladder-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "The base form's ladder (BR-AI-LADDER, dream-rsi b2a0): at each intent re-pick (*AI-REPICK* f, after any respect) this
share by difficulty picks the intent by his pips (BR-AI-LADDER-INTENT) instead of the kit's weights (one roll a re-pick).")

(defun br-ai-ladder-intent (pips cap)
  "Pure: the base form's intent for PIPS of CAP: loading (short of the cap) :ZONE, the snipe's range (6-12 m: the charged
shot fills them, +2 / +3 even on a block); full :PRESSURE, in for the confirm whose rifle string's L L lines spend them
(70 a pip, the base's best damage a pip buys)."
  (if (>= pips cap) :pressure :zone))

(defun br-ai-ladder (e b st f)
  "The base form's range by its pips (his own CPU's neutral, free: idle / run): when ai.lisp's intent is due for its re-pick,
one roll (*BR-AI-LADDER-P*) sets it by BR-AI-LADDER-INTENT for the next *AI-REPICK* frames. NIL (the reflex goes on)."
  (declare (ignore e))
  (when (and (member (fighter-state f) '(:idle :run)) (<= (brain-intent-t b) 1))
    (when (< (sim-rnd01) (getf *br-ai-ladder-p* (brain-difficulty b) 0.0))
      (setf (brain-intent b) (br-ai-ladder-intent (brs-ammo st) (br-ammo-cap :base))
            (brain-intent-t b) *ai-repick*)))
  nil)

(defun br-ai-reflex (e b s d)
  "Every form's :reflex (ai.lisp AI-REFLEX, free states; NIL when there is nothing to do): the awakened stance EN's plan per
window (BR-AI-EN); else one roll a window (*BR-AI-EVERY* f) with the opponent not attacking: the base form the far snipe
(the stance from :far-snipe :in m, its pick the charged L), awakened the burst into the owl (BR-AI-BURST-P) or the
charged dash from afar (:far-dash, the dash's reach; its :p a table by difficulty)."
  (let* ((f (fighter e)) (st (br e)) (form (fighter-form f)) (g (gauges e)) (dif (brain-difficulty b))
         (was (brs-ai-form st)))
    (setf (brs-ai-form st) form)
    (br-ai-cash-read e b st)
    (when (eq form :base) (br-ai-ladder e b st f))   ; (dream-rsi b2a0: the base form's range by its pips; never answers)
    (cond ((br-ranged-form-p form)
           (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
                (or (br-ai-kikon e b s d) (br-ai-en e b s d f st))))
          ((br-ai-turn-wait e b s))
          ((and (br-ranged-form-p was) (br-melee-form-p form) (member (fighter-state f) '(:idle :run :guard))
                (zerop (fighter-lock f)) (br-ai-exit e b s d f st)))
          ((br-ai-anti-breaker e b s d))
          ((br-ai-step-in e b s d f st))
          ((br-ai-kikon e b s d))
          ((br-ai-unguard e b s d f))
          ((br-ai-kite e b s d f st))
          ((br-ai-stance-punish e b s d f form))
          ((and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
                (>= (- *match-tick* (brs-ai-t st)) *br-ai-every*) (not (br-ai-threat-p e s d))
                (br-ai-facing-p e s))   ; (a charge goes where he faces: the window waits for the idle turn, round 2 b1a0)
           (setf (brs-ai-t st) *match-tick*)
           (cond ((eq form :base)
                  (let ((k (ai-table e :far-snipe)))
                    (when (and k (>= d (getf k :in 5.0)))
                      (if (not (br-ai-sight-p d (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))
                                              (nth-value 2 (br-ai-line-of e b s *br-ai-sight-k*))
                                              (+ *br-ai-sight-f* (brain-delay b))))
                          (setf (brs-ai-t st) -999)   ; (b2a0: not in sight, the window waits unspent)
                          (when (< (sim-rnd01) (br-ai-p k :p dif))
                            (pace e :ai-far-snipe) (why b :far-snipe :sig))))))
                 ((and (br-jilliel-form-p form)
                       (br-ai-burst-p (sim-rnd01) (brs-ammo st) (gauges-fs g) d (ai-table e :burst) dif) (burst-ok-p e))
                  (pace e :ai-burst) (why b :owl :burst))
                 (t (let ((k (ai-table e :far-dash)))
                      (when (and k (br-ai-dash-level d) (>= d (getf k :in 3.4)) (< (sim-rnd01) (getf (getf k :p) dif 0.0)))
                        (pace e :ai-far-dash) (why b :far-dash :sig)))))))))

;;; ================================================================ AI: the learning CPU's situations (DUEL_LILLE_V3 §6.3, §22.3)
;;; Only a learner runs this (a CPU facing a human). :shot = his base stance's K K on a free opponent: the human's answer
;;; (:guard :hoho :step :attack :back :take). Read at the stance's pick (one roll): a guard -> K K stays (its 萬物貫通 drain);
;;; a Step / backing off -> J J (quicker); a Hoho / an attack -> the stance Step, else L L.
;;; :charge (the integration of the dream-rsi CPU, §22.3: 「學玩家習慣」) = his charged L (the base snipe, the awakened dash)
;;; entering its charge on a free opponent: the human's answer, a walk off the line (> *LEARN-BACK* m sideways) a Step too.
;;; Read when his CPU picks the charge's level (one roll a charge): a guard -> level 3 (the 31 m line through guard, the dash's
;;; six cuts); a Hoho / an attack -> a tap (nothing held for him to answer); a Step / backing off -> the charge as planned, and
;;; its Step (R18) re-aims once he is seen stepping (BR-AI-RESTEP).
(defparameter *br-learn-diff* '(:easy 0.5 :normal 1.0 :hard 1.5) "His learner's read chance x this by difficulty.")
(defparameter *br-learn-episode* 24 "Frames the :shot situation waits for his answer, + the perception delay.")

(defun br-learn-answer (hprev hs new away)
  "His answer starting this step (perceived HPREV -> HS, NEW: a new move of his, AWAY: metres he moved away since the onset):
:HOHO, :STEP, :ATTACK, :GUARD, :BACK, or NIL."
  (cond ((and (eq hs :hoho) (not (eq hprev :hoho))) :hoho)
        ((and (eq hs :step) (not (eq hprev :step))) :step)
        ((and (eq hs :move) (or (not (eq hprev :move)) new)) :attack)
        ((and (eq hs :guard) (not (eq hprev :guard))) :guard)
        ((> away *learn-back*) :back)))
(defun br-learn-kamae-plan (read plan step-ok)
  "The stance's pick instead of PLAN for his predicted answer READ to K K: a Step / backing off J J, a Hoho / an attack the
stance Step (STEP-OK) else L L; else PLAN."
  (case read
    ((:step :back) :kamae-j)
    ((:hoho :attack) (if step-ok :kamae-step :kamae-l))
    (t plan)))

(defun br-learn-charge-plan (read lv)
  "Pure: the charge's level instead of LV for his predicted answer READ to the charged L, and whether its Step re-aims:
values level, restep."
  (case read
    (:guard (values 3 nil))
    ((:hoho :attack) (values 1 nil))
    ((:step :back) (values lv (> lv 1)))
    (t (values lv nil))))
(defun br-learn-charge (e b lv)
  "His CPU's charge level LV (1 a tap) as a learner's read of :charge leaves it (one roll a charge, only for a charge: LV > 1);
BRS-AI-RESTEP set for it. The level."
  (let ((l (br-learn-l b)) (st (br e)))
    (setf (brs-ai-restep st) nil)
    (if (and l (> lv 1))
        (let ((r (learn-kit-read l :charge (float (getf *br-learn-diff* (brain-difficulty b) 1.0) 1.0))))
          (multiple-value-bind (lv2 restep) (br-learn-charge-plan r lv)
            (setf (brs-ai-restep st) restep)
            (when r (learn-count-read e l r) (pace e (intern (format nil "READ-CHARGE-~a" r) :keyword))
                  (clog "~a read charge ~a -> level ~d~@[ restep~]" (side-name e) r lv2 restep))
            lv2))
        lv)))
(defun br-ai-restep (e f st b mv)
  "His charge on a learner's read of a Step (BRS-AI-RESTEP): him seen stepping -> the charge's Step (BR-CHARGE-STEP-GO,
re-aimed at its end); once a charge."
  (let ((s (br-ai-seen b)))
    (when (and s (eq (snap-state s) :step))
      (setf (brs-ai-restep st) nil)
      (when (br-charge-step-go e f st mv) (pace e :ai-restep)))))

(defstruct (brl (:conc-name brl-))
  "His learner's own state within a match (LRN-KDATA)."
  (own-mv nil) (ox 0f0 :type single-float) (oz 0f0 :type single-float) (ux 0f0 :type single-float) (uz 0f0 :type single-float)
  (len 0 :type fixnum))
(defun br-learn-state (l) (or (lrn-kdata l) (setf (lrn-kdata l) (make-brl))))
(defun br-learn-l (b) "Brain B's learner when it reads his situations (LRN-KIT), else NIL." (let ((l (and b (brain-learn b)))) (and l (lrn-kit l) l)))

(defun br-learn-step (e b s d l)
  "His learner's step (LEARN-DEF-KIT's :step): the :shot onset (his stance's K1 starting on a free opponent), the :charge
onset (his charged L entering its charge on a free opponent), their answer (BR-LEARN-ANSWER; :charge's walk off the line a
Step; at its end :TAKE, or :GUARD held through)."
  (declare (ignore b d))
  (let* ((k (br-learn-state l)) (f (fighter e)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (hs (snap-state s)) (hprev (lrn-hstate l)) (new (/= (snap-start s) (lrn-hstart l)))
         (sit (and mv (not (eq mv (brl-own-mv k))) (< (lrn-ksit l) 0) (member hs '(:idle :run :guard))
                   (cond ((member (mv-name mv) '(:br-s-k1 :br-e-k1 :br-oe-k1)) :shot)
                         ((and (member (mv-name mv) '(:br-s-l1 :br-e-l1 :br-oe-l1)) (eq (fighter-phase f) :hold)
                               (not (and (brl-own-mv k) (member (mv-name (brl-own-mv k)) '(:br-k-dash :br-w-charge-step)))))
                          :charge)))))   ; (a charge resumed after its Step: the same episode's, not a new one)
    (when sit
      (let* ((dx (- (snap-x s) (aref (pos-of e) 0))) (dz (- (snap-z s) (aref (pos-of e) 2))) (m (max 1e-3 (hypot dx dz))))
        (setf (brl-ox k) (snap-x s) (brl-oz k) (snap-z s) (brl-ux k) (f32 (/ dx m)) (brl-uz k) (f32 (/ dz m))
              (brl-len k) (+ *br-learn-episode* (brain-delay (brain e)))))
      (learn-kit-open l sit))
    (setf (brl-own-mv k) mv)
    (when (>= (lrn-ksit l) 0)
      (let* ((end (>= (incf (lrn-kep-t l)) (brl-len k)))
             (ox (- (snap-x s) (brl-ox k))) (oz (- (snap-z s) (brl-oz k)))
             (away (+ (* ox (brl-ux k)) (* oz (brl-uz k))))
             (side (abs (- (* ox (brl-uz k)) (* oz (brl-ux k))))))   ; (metres off his line)
        (cond ((member hs '(:stun :air :down :wakeup)) (learn-kit-close l :take))
              (t (let ((ans (or (br-learn-answer hprev hs new away)
                                (and (learn-kit-open-p l :charge) (> side *learn-back*) :step))))
                   (cond (ans (learn-kit-close l ans))
                         (end (learn-kit-close l (if (member hs '(:guard :guard-hit)) :guard :take)))))))))))

(defun br-learn-kamae (e b plan)
  "The base stance's PLAN (his CPU, once a stance): K K on a free opponent is read (one roll: :shot) and answered
(BR-LEARN-KAMAE-PLAN); anything else, or no learner, as planned."
  (let ((l (br-learn-l b)))
    (if (and l (eq plan :kamae-k) (not (member (state-of (opp-of e)) '(:stun :air))))
        (let* ((r (learn-kit-read l :shot (float (getf *br-learn-diff* (brain-difficulty b) 1.0) 1.0)))
               (p (br-learn-kamae-plan r plan (br-kamae-step-ok-p (brs-dashed (br e)) (gauges-fs (gauges e))))))
          (unless (eq p plan) (learn-count-read e l p) (pace e p) (clog "~a read ~a" (side-name e) p))
          p)
        plan)))

(learn-def-kit :barro :situations #(:shot :charge) :actions #(:guard :hoho :step :attack :back :take) :step 'br-learn-step)

;;; ================================================================ ASSIST AUTO COMBO's routes (DUEL_LILLE_V3 §6.3)
;;; "You press J, the CPU chooses": the routes press his buttons as a human's, the AUTO tag.
;;;   attack state  his J in a J / K link that hit, on its land frame: a J link -> its K link; a K link -> L (the stance:
;;;                 the base's at f4, the awakened turn)
;;;   stance        his J while the stance is up (the base stance's window, the awakened stance free): K (K K, whose J J
;;;                 the generic latch takes on his next J)
;;;   R17's turn    his J in KIN's turn into the stance off a link (:br-to-en-l): K (the stance K1 at once, it combos)
;;;   the strings   his J in a stance string's segment once its hits are over, the segment having touched him: L (its L L
;;;                 follow-up, a spending one only with a special to pay it), else at a string's last segment that hit
;;;                 with 2 bars Shift+L (the charge-less SP2, every special) (§22.3: the new rules' 「資源循環」)
(defstruct (bras (:conc-name bras-))
  (b nil) (mv nil) (sf -1 :type fixnum) (j nil) (done nil))
(defvar *br-as* (vector (make-bras) (make-bras)) "Per side: the ASSIST routes' state (BR-ASSIST-COMBO).")

(defun br-as-track (f b vp)
  "The route state of F's side for brain B, its move instance brought up to date, his J this step noted."
  (let* ((side (fighter-side f)) (a (svref *br-as* side)) (mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (unless (eq (bras-b a) b) (setf a (make-bras :b b) (svref *br-as* side) a))
    (cond ((null mv) (setf (bras-mv a) nil (bras-j a) nil (bras-done a) nil))
          ((or (not (eq mv (bras-mv a))) (< (fighter-sf f) (bras-sf a)))
           (setf (bras-mv a) mv (bras-j a) nil (bras-done a) nil)))
    (when mv
      (setf (bras-sf a) (fighter-sf f))
      (when (or (vpad-command-pressed-p vp :quick nil) (eq (fighter-queued f) :q)) (setf (bras-j a) t)))
    a))

(defun br-assist-combo (e f b s d vp)
  "His kits' :assist-combo (assist.lisp AUTO-ROUTE): the routes above. A command, :NONE (the route holds the step) or NIL
(the generic AUTO COMBO)."
  (declare (ignore s d))
  (let* ((a (br-as-track f b vp)) (mv (bras-mv a)) (kit (fighter-kit f)) (form (fighter-form f)))
    (cond ((and mv (eq (mv-name mv) :br-to-en-l))
           (cond ((bras-done a) (vpad-consume! vp :quick) :none)
                 ((bras-j a) (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-link-k) :f)))
          ((and mv (br-stance-move-p mv) (eq (fighter-phase f) :main))
           (let* ((name (mv-name mv)) (next (kit-next kit name :lchain)) (sp2 (kit-next kit name :sp2c))
                  (end (and sp2 (getf (mv-params mv) :end))))
             (cond ((not (or next end)) nil)
                   ((bras-done a) (vpad-consume! vp :quick) :none)
                   ((not (and (bras-j a) (fighter-contact f) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))) nil)
                   ((and next (or (not (getf (mv-params next) :spend)) (br-follow-ok-p (brs-ammo (br e)))))
                    (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-follow) :sig)
                   ((and end (eq (fighter-contact f) :hit) (>= (reiatsu-bars e) 2))
                    (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-sp2) :sp2))))
          ((and mv (member (mv-name mv) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)))
           (cond ((bras-done a) (vpad-consume! vp :quick) :none)
                 ((and (>= (1+ (fighter-sf f)) *br-kamae-up*) (bras-j a))
                  (setf (bras-done a) t) (vpad-consume! vp :quick) (pace e :as-stance-k) :f)))
          ((and (null mv) (br-ranged-form-p form) (member (fighter-state f) '(:idle :run :guard))
                (vpad-command-pressed-p vp :quick nil))
           (pace e :as-stance-k) :f)
          ((and mv (member (mv-kind mv) '(:quick :flash)) (not (br-stance-move-p mv)))
           (let ((name (mv-name mv)) (l (kit-l-link kit (mv-name mv))))
             (cond ((bras-done a) (vpad-consume! vp :quick) (when (eq (fighter-queued f) :q) (setf (fighter-queued f) nil)) :none)
                   ((not (and (bras-j a) (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)))) nil)
                   ((and (kit-j-link-p kit name) (kit-next kit name :f)) (setf (bras-done a) t) (pace e :as-k-link) :f)
                   ((and l (kit-k-link-p kit name) (kit-command-ok-p e :sig kit nil l))
                    (setf (bras-done a) t) (pace e :as-stance) :sig)
                   ((kit-next kit name :f) (setf (bras-done a) t) (pace e :as-k-link) :f)))))))

;; every form of his names it (assist.lisp AUTO-ROUTE reads the key off the form's kit)
(dolist (form *br-forms*)
  (let ((k (find-kit :barro form)))
    (unless (getf (kit-ai k) :assist-combo)
      (setf (kit-ai k) (list* :assist-combo 'br-assist-combo (kit-ai k))))))

;;; ================================================================ debug: tests, the pacing log (debug.lisp dispatches)
(defun barro-acc-line ()
  "After a gate row: a \"duel barro\" line per side that played him (the pacing log)."
  (dolist (e (list *p1* *p2*))
    (when (and (entity-alive-p e) (eq (fighter-character (fighter e)) :barro))
      (let ((st (br e)))
        (log-msg "duel barro ~a seed ~d awakened ~a form ~a ammo ~d armored ~d ~{~(~a~) ~a~^ ~}" (side-name e) *match-seed*
                 (gauges-awakened (gauges e)) (fighter-form (fighter e)) (brs-ammo st) (brs-armored st)
                 (svref *pacing* (fighter-side (fighter e))))))))

(defun barro-probe-line (tag)
  (let ((g1 (gauges *p1*)) (g2 (gauges *p2*)) (st (br *p1*)))
    (log-msg "duel probe barro ~a t ~d p1 ~a ~a r~d k~d fs ~d rei ~,1f ammo ~d burst ~a | p2 ~a r~d gg ~d | d ~,2f"
             tag *match-tick* (fighter-form (fighter *p1*)) (state-of *p1*) (gauges-reishi g1) (gauges-konpaku g1)
             (round (gauges-fs g1)) (gauges-reiatsu g1) (brs-ammo st) (gauges-burst g1)
             (state-of *p2*) (gauges-reishi g2) (round (gauges-gg g2)) (fighter-dist (fighter *p1*)))))

(defun barro-test (k)
  "82000+k (human P1 Lille II, P2's CPU off unless noted; a \"duel probe barro\" line): 0 the base form 2.2 m from Kenpachi;
1 the base form 14 m out; 2 JILLIEL KIN 5 m out; 3 JILLIEL EN (the stance) 3 m out; 4 the owl KIN 5 m out (kept: no
burst needed); 5 the base form 3 m out with 3 pips; 6 KIN 1.4 m out with 8 wings; 7 the base form 3 m out with 3 pips, the
stance started (K K -> SP2: HIRENKYAKU, every pip); 8 EN 3 m out with 8 wings (K K -> SP2: NIJUSHI-KO, every wing); 9 the owl
EN 3 m out; 10 EN 3 m out with 8 wings; 11 KIN 2 m out with 4 wings, P2's CPU on (the wing armour); 12 the base form 3 m
out, the stance started; 13 KIN 4 m out with 8 wings and the flash step full (a burst: the owl); 14 the owl EN 3 m out with 8
wings (K K -> SP2: the full volley, 裁き・極); 15 the base form 3 m out with 0 pips, the stance started; 16 the same with 3
pips, 20 flash step and no Reiatsu (J J -> L L's gains); 17 KIN 1.5 m out with 4 wings, his K1 and P2's J1 started together
(the wing armour); 20 both CPUs (the mirror) 12 m apart; 30 / 31 *BR-KEEP-OWL* off / on; any other k the probe line only."
  (flet ((setup (c2 form dist &key cpu (ammo 0))
           (ensure-battle :barro c2 :cpu cpu)
           (when (brain *p1*) (setf (brain-off (brain *p1*)) (not cpu)))
           (unless (eq (fighter-form (fighter *p1*)) form) (force-form *p1* form))
           (place *p1* *p2* dist)
           (setf (gauges-reiatsu (gauges *p1*)) *reiatsu-max* (gauges-fs (gauges *p1*)) (f32 *fs-max*)
                 (brs-ammo (br *p1*)) ammo)))
    (case k
      (0 (setup :kenpachi :base 2.2))
      (1 (setup :kenpachi :base 14.0))
      (2 (setup :kenpachi :jilliel-kin 5.0))
      (3 (setup :kenpachi :jilliel 3.0))
      (4 (setf *br-keep-owl* t) (setup :kenpachi :shin-kin 5.0))
      (5 (setup :kenpachi :base 3.0 :ammo 3))
      (6 (setup :kenpachi :jilliel-kin 1.4 :ammo 8))
      (7 (setup :kenpachi :base 3.0 :ammo 3) (force-cmd *p1* :sig))
      (8 (setup :kenpachi :jilliel 3.0 :ammo 8))
      (9 (setf *br-keep-owl* t) (setup :kenpachi :shin 3.0))
      (10 (setup :kenpachi :jilliel 3.0 :ammo 8))
      (11 (setup :kenpachi :jilliel-kin 2.0 :ammo 4)
          (when (brain *p2*) (setf (brain-off (brain *p2*)) nil)))
      (12 (setup :kenpachi :base 3.0) (force-cmd *p1* :sig))
      (13 (setup :kenpachi :jilliel-kin 4.0 :ammo 8))
      (14 (setf *br-keep-owl* t) (setup :kenpachi :shin 3.0 :ammo 8))
      (15 (setup :kenpachi :base 3.0) (force-cmd *p1* :sig))
      (16 (setup :kenpachi :base 3.0 :ammo 3) (force-cmd *p1* :sig)
          (setf (gauges-fs (gauges *p1*)) 20f0 (gauges-reiatsu (gauges *p1*)) 0f0))
      (17 (setup :kenpachi :jilliel-kin 1.5 :ammo 4) (force-cmd *p1* :f) (force-cmd *p2* :q))   ; (P2's J1 into his K1)
      (20 (setup :barro :base 12.0 :cpu t))
      ((30 31) (setf *br-keep-owl* (= k 31))))
    (barro-probe-line (format nil "test ~d" k))))

(defun br-test-tick (e f)
  "His per-step debug overrides (BARRO-TICK): *BR-TEST-AWAKE*, *BR-TEST-DIFF*. Nothing when both are off (the gates)."
  (let ((b (brain e)))
    (when (and *br-test-awake* b (eq (brain-habit b) :dumb) (zerop (fighter-side f)) (eq (fighter-form f) :base)
               (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f)))
      (force-form e :jilliel-kin))
    (when (and *br-test-diff* b (not (brain-habit b)) (not (eq (brain-difficulty b) *br-test-diff*)))
      (setf (brain-difficulty b) *br-test-diff* (brain-delay b) (getf *ai-delay* *br-test-diff*)))))

(defun barro-debug (c)
  "His debug commands (debug.lisp *CHAR-DEBUG*, the range 82000-82999, docs/duel/DUEL_GAMEPLAY.md): 82000+k BARRO-TEST k;
82040 / 82041 *BR-TEST-AWAKE* off / on; 82050-82052 *BR-TEST-DIFF* EASY / NORMAL / HARD, 82053 off (gate flags, no probe
line)."
  (cond ((<= 82040 c 82041) (setf *br-test-awake* (= c 82041)))
        ((<= 82050 c 82053) (setf *br-test-diff* (nth (- c 82050) '(:easy :normal :hard nil))))
        ((< c 82100) (barro-test (- c 82000)))
        (t (log-msg "duel barro: no debug command ~d" c))))
(pushnew '(82000 82999 barro-debug) *char-debug* :test #'equal)
(pushnew '(82100 82399 barro-art-debug) *char-debug* :test #'equal)   ; (the art stills, barro-art.lisp: ahead of the above)

;;; ================================================================ the HUD (barro-art.lisp's functions; not on the host)
(when (fboundp 'br-hud-meter)
  (let ((meter (list :name "SN" :max 3 :draw 'br-hud-meter :label 'br-hud-label)))
    (dolist (form *br-forms*)
      (setf (kit-meter (find-kit :barro form)) meter))))
