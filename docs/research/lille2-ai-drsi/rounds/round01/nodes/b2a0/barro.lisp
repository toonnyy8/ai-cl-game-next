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
                    :dmg ,(cond (dash '*br-w-cut-dmg*) (sniper '*br-snipe-dmg-1*) (t dmg)) :adv-block ,(max (+ -12 adv) (- 1 (+ a r))) :track 720.0   ; (>= 1 f of blockstun)
                    :vol ,(cond (dash `(:cap 0.0 ,*br-w-dash-reach* 1.2 ,*br-w-dash-r*))
                                (cut `(:cap 0.4 ,(- (reduce #'max (cdr (assoc sn (cdr (assoc prefix *br-w-tips* :test #'string=))
                                                                                :test #'string=)))
                                                    *br-w-near-r*)
                                              1.2 ,*br-w-near-r*))
                                (far '(:cap 0.6 *br-x-len* 1.2 0.25))
                                (t '(:cap 0.6 *br-s-near* 1.2 0.25)))
                    :on-hit ,last :kb ,(if cut *br-w-kb* 0.3)
                    ,@(cond (far '(:chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable)))
                            (dash '(:flags (:through)))
                            (cut nil)
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
  :vol (:cap 0.6 *br-x-len* 1.2 0.25) :chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable)
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
  :ai (:intents (:approach 2 :pressure 2 :zone 4 :defend 1)            ; (cell b0a0: the snipe from range, the stance off J links)
       :ranges (:approach (2.0 6.0) :pressure (1.4 2.4) :zone (6.0 10.0) :defend (4.0 8.0))
       :moves ((0.0 2.0 :q 5 :f 2 :breaker 1 :step 1)                ; (a stance from neutral is Hoho'd: J pokes, L off them)
               (2.0 3.2 :step 2 nil 2)
               (3.2 99.0 :sig 2 nil 3))
       :guard 0.5 :neutral-guard 0.1 :hoho 0.3 :dash 0.6 :dash-back 0.6 :block-string 0.3 :o-ender 0.3 :l-after-k 0.6 :l-after-j 0.8 :kikon-range 0.0
       :awaken (:min-taken 150) :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :zone (:p 0.4 :from 5.0 :to 14.0 :punish 0.5)                ; (the snipe from range, one roll a window; the punish)
       :stance (:step 0.3 :k 0.6 :link-k 0.0 :follow 0.6 :sp2-at 4 :sp2-j 1 :sp2 0.8 :sp2-empty 0.5)))

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
  :ai (:intents (:approach 2 :pressure 1 :zone 4 :defend 1)            ; (KIN loses the close J exchanges: the dash's range)
       :ranges (:approach (2.4 6.0) :pressure (1.4 2.4) :zone (4.5 7.5) :defend (4.0 7.0))
       :moves ((0.0 2.4 :q 5 :f 3 :breaker 1)
               (2.4 8.0 :sig 3 :step 1 nil 1)
               (8.0 99.0 :step 1 nil 3))
       :guard 0.4 :neutral-guard 0.1 :hoho 0.3 :dash 0.8 :dash-back 0.6 :block-string 0.3 :o-ender 0.3 :kikon-range 0.0
       :string-k 0.6 :l-after-k 0.7 :l-after-j 0.9
       :burst (:p 0.6 :wings 3 :in 8.0) :reflex br-ai-reflex :sig-hold br-ai-sig-hold   ; (cell b2a0: the owl sooner)
       :zone (:p 0.6 :from 3.0 :to 8.6)                              ; (the charged dash from mid range)
       :stance (:step 0.3 :k 0.7 :link-k 0.8 :follow 0.6 :sp2-at 7 :sp2-j 2 :sp2 0.8 :sp2-empty 0.4)))

;; JILLIEL EN, the stance (afloat): L / J / K start the stance's strings, each ending back in KIN (BARRO-TICK)
(defkit :barro :jilliel :inherit :jilliel-kin
  :form-name "JILLIEL" :walk *br-walk-en* :run *br-run-en* :body :lille-jilliel
  :commands (:q :br-e-j1 :f :br-e-k1 :sig :br-e-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)            ; (rooted: BR-AI-EN decides; the bands a fallback)
       :ranges (:approach (2.8 8.0) :pressure (1.0 2.8) :zone (3.5 8.0) :defend (5.0 9.0))
       :moves ((0.0 1.8 :q 4 :f 2)
               (1.8 3.0 :f 4 :q 1)
               (3.0 8.6 :sig 3)
               (8.6 99.0 nil 3))
       :guard 0.4 :hoho 0.3 :kikon-range 0.0
       :burst (:p 0.6 :wings 3 :in 8.0) :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :stance (:step 0.3 :k 0.7 :link-k 0.8 :follow 0.6 :sp2-at 7 :sp2-j 2 :sp2 0.8 :sp2-empty 0.4)))

;; the owl (a burst in either JILLIEL form, decision R1; back when it ends): the claws, SP1 裁きの光明, SP2 the full volley
;; (every wing, decision R3; Trompete gone); x1.2 dealt (its buff), a wing every 2 s, the armour 2 wings; Kikon 4
(defkit :barro :shin-kin :inherit :jilliel-kin
  :lift 0.0 :form-name "SHIN KIN" :mult *br-owl-mult* :taken *br-owl-taken* :kikon-konpaku 4
  :body :lille-shin :stance :lb-o-stance :cine nil :clip-map *br-owl-clip-map*
  :commands (:q :br-o-j1 :f :br-o-k1 :sig :br-to-en :sp1 :br-misuji :sp2 :br-recall-s :breaker :br-o-breaker :kikon :br-o-kikon)
  :grid (:br-o-j1 :br-o-j2 :br-o-j3 :br-o-k1 :br-o-k2 :br-o-k3 :br-o-j2s :br-o-k2s)
  :ai (:intents (:approach 2 :pressure 2 :zone 3 :defend 0)
       :ranges (:approach (2.6 8.0) :pressure (1.4 2.6) :zone (4.5 7.5) :defend (4.0 7.0))
       :moves ((0.0 2.6 :q 4 :f 5 :breaker 1)
               (2.6 8.0 :sig 3 :step 1 nil 1)
               (8.0 99.0 :step 1 nil 3))
       :guard 0.3 :neutral-guard 0.1 :hoho 0.3 :dash 0.9 :dash-back 0.6 :block-string 0.3 :o-ender 0.2 :kikon-range 0.0
       :string-k 0.8 :l-after-k 0.3 :l-after-j 0.9 :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :zone (:p 0.6 :from 3.0 :to 8.6)
       :stance (:step 0.3 :k 0.7 :link-k 0.9 :follow 0.7 :sp2-at 4 :sp2-j 3 :sp2 0.9 :sp2-empty 0.5)))

(defkit :barro :shin :inherit :shin-kin
  :lift *br-owl-lift* :form-name "SHIN" :walk *br-walk-en* :run *br-run-en* :stance :lb-oe-stance
  :commands (:q :br-oe-j1 :f :br-oe-k1 :sig :br-oe-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)            ; (rooted: BR-AI-EN decides; the bands a fallback)
       :ranges (:approach (2.7 8.0) :pressure (1.0 2.7) :zone (3.5 8.0) :defend (5.0 9.0))
       :moves ((0.0 1.7 :q 4 :f 2)
               (1.7 2.9 :f 4 :q 1)
               (2.9 8.6 :sig 3)
               (8.6 99.0 nil 3))
       :guard 0.4 :hoho 0.3 :kikon-range 0.0 :reflex br-ai-reflex :sig-hold br-ai-sig-hold
       :stance (:step 0.3 :k 0.7 :link-k 0.9 :follow 0.7 :sp2-at 4 :sp2-j 3 :sp2 0.9 :sp2-empty 0.5)))

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
  (l-lv 0 :type fixnum)                   ; the awakened L dash's charge level 1-3 (its S: BR-W-DASH; decision R10)
  (armored 0 :type fixnum)                ; hits his wing armour took (the pacing log)
  (ai-t -999 :type fixnum)                ; his CPU's last stance / burst window (one roll a window)
  (ai-key -1 :type fixnum)                ; his CPU: the opponent's action (its SNAP start) its event roll belongs to
  (ai-roll 0f0 :type single-float)        ; ... that roll (BR-AI-EVENT-ROLL: one per opponent action)
  (ai-en -999 :type fixnum)               ; his CPU: the tick of its last decision in the awakened stance EN
  (ai-ward -999 :type fixnum)             ; his CPU: the tick of its last ward roll (BR-AI-WARD, cell b2a0)
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
                     (spend-fs (gauges e) *br-kamae-dash-fs*) (setf (brs-dashed st) t)
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
  "The Step's f11: back in the stance at its f6 (:br-kamae-re: a fresh window, the Step spent), the aim snapped onto him."
  (start-move e (kit-next (kit-of e) :br-k-dash :kamae-back))
  (turn-to-opp e (fighter e) 10.0))

(defun br-k-dash-tick (e)
  "The stance Step: from its *BR-DASH-SNAP-F* a J (a human's press, buffered) cancels it into the stance's J J, facing him."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :main) (br-dash-snap-p (fighter-sf f)) (null (br-tick-brain e)))
      (let ((vp (pilot-vpad (pilot e))))
        (when (vpad-command-pressed-p vp :quick nil)
          (vpad-consume! vp :quick)
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
  "His CPU's call at the end of stance move MV's hits (one roll, the kit's :stance): SP2 off a J / K string's last segment
or its follow-up's (:end) that hit (SP2: its charge-less SP2; the bars for it and :sp2-at specials, :sp2 of the time),
else the :lchain follow-up NEXT (L1 -> L2 -> L3 always; a spending one with a special, :follow of the time). :SP2, :GO
or :NO."
  (let* ((k (ai-table e :stance)) (b (br-tick-brain e)) (r (sim-rnd01)) (n (brs-ammo st))
         (d (if b (brain-difficulty b) :normal)))
    (cond ((and next (not (getf (mv-params next) :spend))) :go)   ; (L1 -> L2 -> L3: no spend; the base's / awakened L is one move now)
          (t (let ((call (br-ai-call r n (reiatsu-bars e)
                                     (and sp2 (getf (mv-params mv) :end) (eq (fighter-contact f) :hit) t)
                                     next k d (eq (getf (mv-params mv) :stance) :j))))
               (when (eq call :no) (pace e :ai-follow-no))
               call)))))

(defun br-s-tick (e)
  "A stance move (no chase: its J / K links are :quick / :flash). Its L links (:lchain: L1 -> L2 -> L3, J3 -> JL1 -> JL2 ->
JL3, K3 -> KL1 -> KL2 -> KL3, decision R3) start unchained: a human's L pressed during it is latched and starts the next from the end
of its hits, the move having touched him (a hit or a block; a whiff ends the string, as a J / K string's links: decision R5, the
user 2026-10-11: 「架式 > L 只要沒打中就進入硬直」「就跟一般的 J / K 普攻一樣」), a spending follow-up only with a special to
spend (BR-FOLLOW-OK-P; none, the string ends). Any J / K / JL /
KL segment: a human's SP2 (Shift+L) is latched and, the move having hit, cancels into the form's charge-less SP2 there
(:sp2c; 「必須接在 KK 後執行」, 「SP2 接在 J 連段後面也可以」).
His CPU makes one call there (BR-S-CPU-CALL)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (st (br e)))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :hold) (br-tick-brain e))   ; (his CPU's charge: BR-AI-CHARGE-TICK)
      (br-ai-charge-tick e f (br-tick-brain e)))
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
    (pace e (svref #(:w-dash-1 :w-dash-2 :w-dash-3) (1- lv)))
    (turn-to-opp e f 360.0)
    (let ((yaw (yaw-of e))) (set-slide e d *br-w-dash-f* (fwd-x yaw) (fwd-z yaw)))
    (pace e :w-dash)
    (emit :sfx :whoosh-heavy e)))

(defun br-s-snipe-release (e)
  "The base stance's L, the charged snipe (R15, DUEL_LILLE_V3 §19: 「蓄力狙擊」), released: its gains unpaid (BR-S-START: a held
move's f0 hooks never run), its level by the frames held (BR-W-L-LEVEL); level 2 / 3 the longer shots (:br-s-l1-2 /
:br-s-l1-3, started in its place; level 1 the move goes on)."
  (let* ((f (fighter e)) (st (br e)) (lv (br-w-l-level (fighter-charge f))))
    (br-s-start e)
    (setf (brs-l-lv st) lv)
    (pace e (svref #(:snipe-1 :snipe-2 :snipe-3) (1- lv)))
    (when (> lv 1)
      (start-move e (find-move (if (= lv 2) :br-s-l1-2 :br-s-l1-3)))
      (turn-to-opp e f 10.0))))

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
frames' hooks run), L in its charge (held). His CPU: the turn as before."
  (halt! e)
  (let* ((f (fighter e)) (vp (pilot-vpad (pilot e))) (b (br-tick-brain e)))
    (when (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main))
      (let ((cmd (if b
                     (br-ai-link-cmd e f b)                     ; (his CPU's own means, cell b0a0: BR-AI-LINK-CMD)
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
;;; ================================================================ AI (DUEL_LILLE_V3 §22: the action policy, dream-rsi cells b0a0, b2a0)
;;; His CPU: his kits' :ai keys (every chance x *BR-AI-DIFF* by difficulty: EASY <= NORMAL <= HARD), the generic bands and
;;; string reflex (the stances' J1 -> J2 / K1 -> K2 go on by the J / K latch like any string) and these, each one roll per
;;; window (*BR-AI-EVERY* f), per opponent action (BR-AI-EVENT-ROLL) or per stance:
;;;   L pressed   how long L is held is the plan (BR-AI-SIG-HOLD, every form's :sig-hold): near him a tap (the stance for
;;;               its melee strings), farther the charge: the base's snipe to level 2 / 3 (12 m / the 31 m line, +2 / +3
;;;               pips), awakened the dash through him to level 2 / 3 (8 / 10 m, 4 / 6 hits, +2 / +3 wings). A charge lets
;;;               go early when his attack comes near (BR-AI-CHARGE-TICK)
;;;   base        the snipe from range (:zone's :from .. :to m, one roll a window); the stance as a punish (his recovery
;;;               long enough for the stance's K1 / J1, one roll per action of his); L after a J / K link -> the stance at
;;;               f4; in the stance one pick (BR-AI-STANCE-PLAN): the Step off his attack, out of the melee the charged
;;;               snipe, K when he can't answer K1's startup or isn't attacking, else J
;;;   KIN         the generic strings, L after a link: the turn, whose CPU skips into the stance K1 / J1 (R17's link,
;;;               BR-AI-LINK-CMD); the charged dash from mid range (:zone, one roll a window); the burst into the owl
;;;   EN          rooted, 30 f: one decision every *BR-AI-EN-EVERY* f (BR-AI-EN): the fast Step off his attack, the dash
;;;               out of the melee, K / J in it
;;;   stance      at the end of a move's hits one call (BR-S-CPU-CALL, the kit's :stance): enough specials -> SP2 (every
;;;               special spent), else the L L follow-up spending them (:follow), and at a string's very end SP2 with what
;;;               is left (:sp2-empty)
;;;   his reach   (cell b2a0) a model of the opponent read off his kit and his perceived motion (BR-AI-ENVELOPE: his J1's
;;;               reach + lunge + his closing speed): free in it while he is free, one roll a window (BR-AI-WARD): a dash
;;;               back out of it when he comes in (the kite), else a short guard; a snipe let go short of level 2 is held
;;;               into it (BR-AI-LET-GO-HOLD), the dash's done charge waits while he strafes (BR-AI-CHARGE-TICK)
;;;   openings    (cell b2a0) the Kikon only on a red opponent open long enough for its 28 f lane shot (BR-AI-KIKON;
;;;               :kikon-range 0: no neutral rush); a long guard up close: a dash back to the snipe's / dash's range instead
;;;               of the Breaker (BR-AI-UNGUARD); his Breaker met by the reach model (BR-AI-ANTI-BREAKER, cell b1a0's); the
;;;               owl at 3 wings within 8 m
(defparameter *br-ai-diff* '(:easy 0.15 :normal 0.3 :hard 1.5)
  "His CPU's chances (his kits' :ai :p values) x this by difficulty, at most 1 (the old Lille's *LB-AI-DIFF*).")
(defparameter *br-ai-every* 30 "Frames between two of his window rolls (the snipe / the dash from range, the burst; new 2026-10-09).")
(defparameter *br-ai-hold* '(26 46)
  "Frames his CPU holds L for a level-2 / level-3 charge (the snipe, the dash: the levels at *BR-W-L-LEVELS* 20 / 40 f held,
+ a margin) (cell b0a0, 2026-10-12).")
(defparameter *br-ai-snipe-far* 5.0 "The base snipe: from this far a level-3 charge (the 31 m line), nearer level 2 (12 m).")
(defparameter *br-ai-dash-far* 5.6 "The awakened dash: from this far a level-3 charge (10 m), nearer level 2 (8 m).")
(defparameter *br-ai-tap-in* 3.2 "The base form: L pressed nearer than this is a tap (the stance for its melee strings), farther the snipe's charge.")
(defparameter *br-ai-dash-in* 2.9 "Awakened: L pressed nearer than this is a tap (EN's melee strings), farther the dash's charge.")
(defparameter *br-ai-dash-max* 8.6 "The charged dash from at most this far (level 3's 10 m ends *BR-W-DASH-PAST* past him).")
(defparameter *br-ai-threat-m* 0.8 "His live attack within its reach + this is a threat to the stance / a charge.")
(defparameter *br-ai-facing* 1.0 "Radians: him reeling farther round than this from his facing (after the dash through him), he turns before a follow-up.")
(defparameter *br-ai-turn-p* '(:easy 0.2 :normal 0.4 :hard 1.0)
  "... of the time by difficulty (one roll per action of his: BR-AI-EVENT-ROLL), else the generic follow-up at once.")
(defparameter *br-ai-en-every* 10 "Frames between two of his CPU's decisions in the awakened stance EN (it stands *BR-EN-HOLD* 30 f).")
(defparameter *br-ai-let-go-min* 12
  "A base snipe his CPU lets go (his attack near) at this many held frames or more but short of level 2 is held into level 2
(BR-AI-LET-GO-HOLD: level 1's 16 f wind-up after the release hit later than level 2's 8; it was the Hoho's bait; cell b2a0).")
(defparameter *br-ai-dash-wait* 56 "The awakened dash's charge, done: held on at most to this many frames while he moves across its line ...")
(defparameter *br-ai-dash-wait-v* 0.05 "... at more than this many m / f across it (a strafing target the dash would miss; cell b2a0).")
(defparameter *br-ai-ward-p* '(:easy 0.05 :normal 0.1 :hard 0.8)
  "His ward (BR-AI-WARD, cell b2a0): free in his opponent's first-strike envelope, him free, one roll a *BR-AI-WARD-EVERY*
window: the kite (him coming in) or a short guard (*BR-AI-WARD-HOLD*) this share of the windows by difficulty, instead of
standing / walking into it.")
(defparameter *br-ai-ward-every* 24 "Frames between two of his ward rolls.")
(defparameter *br-ai-ward-kite-v* 0.03 "His ward, him perceived closing faster than this (m / f): a dash back out of his reach ...")
(defparameter *br-ai-ward-kite* 2.0 "... to his envelope + this many metres (else the guard).")
(defparameter *br-ai-ward-hold* '(12 8) "His ward's guard: held this + 0..that frames (under a CPU's Breaker-a-guard 24 f).")
(defparameter *br-ai-ward-margin* 0.5 "His opponent's first-strike envelope: his J1's reach + its lunge (at most 0.8 m) + this ...")
(defparameter *br-ai-ward-lead* 15 "... + his closing speed x this many frames (his J1 and his reaction).")
(defparameter *br-ai-kikon-p* '(:easy 0.05 :normal 0.15 :hard 1.0)
  "His Kikon (BR-AI-KIKON, cell b2a0): only on a red opponent perceived open long enough for its lane shot (the aura + its
startup + *BR-AI-KIKON-LEAD*), within *BR-AI-KIKON-IN*; this share of his openings by difficulty (his react roll: one per
action of his). Every form's :kikon-range 0: the generic neutral / reeling rush never fires (28 f of wind-up on a free
opponent: Hoho'd, guarded, side-stepped -- 34 Perfect Hohos and 47 blocks of 99 tries vs HARD Ichigo in 8 seeds).")
(defparameter *br-ai-kikon-lead* 2 "... frames to spare over the aura + startup ...")
(defparameter *br-ai-kikon-in* 11.0 "... and within this many metres (the lane shot runs 12 m).")
(defparameter *br-ai-unguard-p* '(:easy 0.0 :normal 0.1 :hard 1.0)
  "His answer to a long guard up close (BR-AI-UNGUARD, cell b2a0), this share of his guards by difficulty: he backs off to
*BR-AI-UNGUARD-TO* (his snipe's / his dash's range) instead of the generic Breaker (his Breakers broke a guard or hit 45
times of ~200 tries in 80 HARD matches, and were Hoho'd / J'd out of the rest).")
(defparameter *br-ai-unguard-to* 5.5 "... metres he backs off to.")
(defparameter *br-ai-breaker-v* 0.16 "A Breaker dash's metres per frame (9-10 m/s: *BREAKER-SPEED-MIN* / -MAX), his CPU's timing (cell b1a0's model).")
(defparameter *br-ai-anti-breaker* '(:easy 0.1 :normal 0.3 :hard 1.0)
  "His CPU answers a Breaker by the reach model (BR-AI-ANTI-BREAKER), this share of the Breakers by difficulty (one roll
each: his react roll); cell b1a0's (his J1's 1.45 m met the generic J1 too late), taken over in cell b2a0.")

;; pure: host-tested
(defun br-ai-chance (p difficulty) "A chance P of his kit's :ai at DIFFICULTY: x *BR-AI-DIFF*, at most 1." (min 1.0 (* p (getf *br-ai-diff* difficulty 1.0))))
(defun br-ai-hold-frames (d far)
  "Frames his CPU holds L for a charge at D metres: level 3 from FAR on, else level 2 (*BR-AI-HOLD*)."
  (if (>= d far) (second *br-ai-hold*) (first *br-ai-hold*)))
(defun br-ai-stance-plan (r d jr kr open js ks threat k &optional (difficulty :normal))
  "His CPU's pick in a stance from one roll R (K: the kit's :stance; D his distance, JR / KR the stance J1's / K1's reach to
him, JS / KS their startups, OPEN the frames he is perceived open (reeling / recovering; 0 free), THREAT his attack near):
the Step off his attack (:step of the time); out of the melee the charge (:kamae-l); K when he can't answer K1 (OPEN >= KS),
J when he can't answer J1; under his attack J (in reach) / K; else K :k of the time when J reaches, else K (:step and :k x
the DIFFICULTY, BR-AI-CHANCE)."
  (cond ((and threat (< r (br-ai-chance (getf k :step 0.0) difficulty))) :kamae-step)
        ((> d kr) :kamae-l)
        ((>= open ks) :kamae-k)
        ((and (>= open js) (<= d jr)) :kamae-j)
        (threat (if (<= d jr) :kamae-j :kamae-k))
        ((<= d jr) (if (< r (br-ai-chance (getf k :k 0.7) difficulty)) :kamae-k :kamae-j))
        (t :kamae-k)))
(defun br-ai-call (r n bars end follow-next k difficulty &optional j-route)
  "His CPU's call at the end of a stance move's hits that touched him (BR-S-CPU-CALL), from one roll R: N specials, BARS of
Reiatsu, END its string's last segment (SP2 may follow), FOLLOW-NEXT its L L follow-up exists (spending; NIL none). SP2 at
:sp2-at specials or more (:sp2 of the time); else the follow-up with a special (:follow); else at the end SP2 with what is
left (:sp2-empty). :SP2, :GO or :NO (SP2 needs 2 bars and END)."
  (let ((sp2-ok (and end (>= bars 2))))
    (cond ((and sp2-ok (>= n (getf k (if j-route :sp2-j :sp2-at) 3)) (< r (br-ai-chance (getf k :sp2 0.0) difficulty))) :sp2)
          ((and follow-next (br-follow-ok-p n) (< r (br-ai-chance (getf k :follow 0.0) difficulty))) :go)
          ((and sp2-ok (not follow-next) (< r (br-ai-chance (getf k :sp2-empty 0.0) difficulty))) :sp2)
          (t :no))))
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

(defun br-ai-event-roll (st s)
  "One roll per opponent action (his perceived SNAP S's start): the same roll until he starts another (his state ST)."
  (when (/= (snap-start s) (brs-ai-key st))
    (setf (brs-ai-key st) (snap-start s) (brs-ai-roll st) (f32 (sim-rnd01))))
  (brs-ai-roll st))

(defun br-ai-threat-p (s e d)
  "Is his perceived attack S a threat to E at D: a live move within its reach + *BR-AI-THREAT-M* (an :x-axis line: E on
it), or him running in within 2.5 m?"
  (and s (or (and (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
                  (snap-live-p s) (snap-near-p s e d *br-ai-threat-m*))
             (and (eq (snap-state s) :run) (< d 2.5)))))

(defun br-ai-open (s b)
  "Frames he is perceived open (reeling or recovering, less the perception delay), 0 when free or attacking."
  (if (and s (snap-punishable-p s)) (max 0 (snap-left-seen s b)) 0))

(defun br-ai-reach (e pre seg)
  "The stance move PRE-SEG's whole reach to his body (BR-MOVE-REACH + his hurt radius) for E."
  (+ (br-move-reach (find-move (intern (format nil "~a-~a" pre seg) :keyword))) (body-hurt-r (model-body (model (opp-of e))))))

(defun br-ai-sig-hold (kit d e)
  "Every form's :sig-hold (ai.lisp AI-COMMAND, the CPU's L): frames L is held. The base stance (:br-kamae): a tap nearer than
*BR-AI-TAP-IN*, farther the snipe's charge (held into it, BR-KAMAE-TICK); KIN's turn (:br-to-en): a tap nearer than
*BR-AI-DASH-IN*, farther held into the dash's charge (BR-GO-RANGED); EN's L, the dash: always the charge. Level 3 from
*BR-AI-SNIPE-FAR* / *BR-AI-DASH-FAR*, else 2 (BR-AI-HOLD-FRAMES)."
  (declare (ignore e))
  (let ((mv (kit-command-move kit :sig)))
    (case (and mv (mv-name mv))
      (:br-kamae (if (< d *br-ai-tap-in*) 1 (br-ai-hold-frames d *br-ai-snipe-far*)))
      (:br-to-en (if (< d *br-ai-dash-in*) 1 (br-ai-hold-frames d *br-ai-dash-far*)))
      ((:br-e-l1 :br-oe-l1) (br-ai-hold-frames d *br-ai-dash-far*))
      (t 1))))

(defun br-ai-charge (e b)
  "His CPU starts holding L for the charge of the base stance's snipe (BR-AI-KAMAE), its level by the distance."
  (ai-press b :sig (br-ai-hold-frames (fighter-dist (fighter e)) *br-ai-snipe-far*))
  (pace e :ai-charge))

(defun br-ai-let-go-hold (held)
  "Frames more his CPU holds a base snipe it lets go at HELD frames (cell b2a0): a level-1 snipe fires *BR-SNIPE-S1* after the
release, a level-2 one 8 after level 2's *BR-W-L-LEVELS* frame, so from *BR-AI-LET-GO-MIN* held frames on level 2 hits
sooner (and harder) than level 1: hold on to it; else 0 (let go now)."
  (let ((l2 (first *br-w-l-levels*)))
    (if (and (>= held *br-ai-let-go-min*) (< held l2)) (- l2 held) 0)))

(defun br-ai-closing (b s d e)
  "His perceived velocity (m / f) from the SNAP S and the one before it in brain B's ring, split into the part toward E
(closing, > 0: coming) and the part across the line between them (lateral, >= 0)."
  (let* ((ring (brain-ring b)) (n (length ring))
         (s1 (and (plusp n) (svref ring (mod (- (brain-head b) 2 (brain-delay b)) n)))) (p (pos-of e)))
    (if (or (null s1) (null s) (< d 0.01))
        (values 0.0 0.0)
        (let* ((vx (- (snap-x s) (snap-x s1))) (vz (- (snap-z s) (snap-z s1)))
               (ux (/ (- (aref p 0) (snap-x s)) d)) (uz (/ (- (aref p 2) (snap-z s)) d))
               (along (+ (* vx ux) (* vz uz))))
          (values along (abs (- (* vx uz) (* vz ux))))))))

(defun br-ai-charge-tick (e f b)
  "His CPU holding L in a charge (the snipe, the dash; their :hold phase, BR-S-TICK): let go now (the shot / the dash at the
level reached) when his attack comes near as perceived (BR-AI-THREAT-P), a base snipe held into level 2 when that hits
sooner (BR-AI-LET-GO-HOLD); the awakened dash, its charge done, waits while he is perceived moving across its line
(*BR-AI-DASH-WAIT-V*, up to *BR-AI-DASH-WAIT* held frames: the dash released on his commitment, cell b2a0). No roll: a
reaction."
  (when (and (eq (brain-press b) :sig) (plusp (brain-press-left b)))
    (let* ((s (br-ai-seen b)) (d (fighter-dist f)) (mv (fighter-move f)) (held (fighter-hold f))
           (snipe (eq (mv-name mv) :br-s-l1)))
      (cond ((br-ai-threat-p s e d)
             (let ((more (if snipe (br-ai-let-go-hold held) 0)))
               (unless (and (plusp more) (<= (brain-press-left b) more))   ; (already let go there)
                 (setf (brain-press-left b) more)
                 (pace e (if (plusp more) :ai-hold-on :ai-let-go)))))
            ((and (not snipe) (= (brain-press-left b) 1) (< held *br-ai-dash-wait*) s
                  (member (snap-state s) '(:run :step :hoho :idle))
                  (> (nth-value 1 (br-ai-closing b s d e)) *br-ai-dash-wait-v*))
             (incf (brain-press-left b))
             (pace e :ai-dash-wait))))))

(defun br-ai-kamae (e f st b)
  "His CPU's pick in the base stance (BR-KAMAE-TICK, from f6): none while it still holds L into the snipe's charge (the
stance hands it on at *BR-TO-DASH-HELD*); once a stance (one roll, BR-AI-STANCE-PLAN; a learner's read may change K,
BR-LEARN-KAMAE); a Step plan clears itself so the window after it picks again; the snipe planned: L held for its level."
  (when (and (eq (brain-press b) :sig) (plusp (brain-press-left b)) (vpad-down (pilot-vpad (pilot e)) :sig))
    (return-from br-ai-kamae nil))
  (unless (brs-k-plan st)
    (let* ((k (ai-table e :stance)) (g (gauges e)) (s (br-ai-seen b)) (d (fighter-dist f))
           (link (member (mv-name (fighter-move f)) '(:br-kamae-k :br-kamae-j)))   ; (off a J / K link that hit)
           (open (if link (if (< (sim-rnd01) (br-ai-chance (getf k :link-k 0.0) (brain-difficulty b))) 99 12) (br-ai-open s b)))
           (threat (and (not link) (br-ai-threat-p s e d)))
           (plan (br-ai-stance-plan (sim-rnd01) d (br-ai-reach e "BR-S" "J1") (br-ai-reach e "BR-S" "K1")
                                    open
                                    (mv-s (find-move :br-s-j1)) (mv-s (find-move :br-s-k1)) threat k (brain-difficulty b))))
      (when (ai-mash-p b) (when (eq plan :kamae-k) (setf plan :kamae-j)))   ; (a masher's J beats K1's startup)
      (setf (brs-k-plan st) (br-learn-kamae e b plan))
      (when (and (eq (brs-k-plan st) :kamae-step) (not (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g))))
        (setf (brs-k-plan st) (if (<= d (br-ai-reach e "BR-S" "J1")) :kamae-j :kamae-l)))
      (pace e (intern (format nil "AI-~a" (brs-k-plan st)) :keyword))
      (why b :kamae (brs-k-plan st))
      (when (eq (brs-k-plan st) :kamae-l) (br-ai-charge e b))))
  (let ((plan (brs-k-plan st)))
    (when (eq plan :kamae-step) (setf (brs-k-plan st) nil))
    plan))

(defun br-ai-link-cmd (e f b)
  "His CPU in KIN's turn off a J / K link that hit (:br-to-en-l, BR-TO-EN-LINK-TICK; R17's link, a human's by his press):
on the turn's first frame the stance's K1 (in its reach, :link-k of the time) or J1 (in its reach) at once, the turn's
frames its startup's; else NIL (the turn goes on). One roll a turn (its first frame only)."
  (when (= (fighter-sf f) 1)
    (let* ((pre (if (br-owl-form-p (fighter-form f)) "BR-OE" "BR-E")) (d (fighter-dist f))
           (kr (br-ai-reach e pre "K1")) (jr (br-ai-reach e pre "J1"))
           (k (ai-table e :stance)) (r (sim-rnd01)))
      (cond ((and (<= d kr) (< r (br-ai-chance (getf k :link-k 0.0) (brain-difficulty b)))) (pace e :ai-link-k) :f)
            ((<= d jr) (pace e :ai-link-j) :q)
            ((<= d kr) (pace e :ai-link-k) :f)))))

(defun br-ai-en (e b s d f st)
  "His CPU in the awakened stance EN (rooted, it ends after *BR-EN-HOLD* f standing): one decision every *BR-AI-EN-EVERY*
frames, its roll with it: the fast Step off his attack (:step of the time, the Step unspent: BARRO-STEP); out of the melee
the dash (charged, BR-AI-SIG-HOLD) from at most *BR-AI-DASH-MAX*, farther nothing (the stance lapses into KIN, which walks);
in reach K when he can't answer K1 or (:k of the time) isn't attacking, else J. A command or NIL."
  (when (>= (- *match-tick* (brs-ai-en st)) *br-ai-en-every*)
    (setf (brs-ai-en st) *match-tick*)
    (let* ((pre (if (br-owl-form-p (fighter-form f)) "BR-OE" "BR-E"))
           (k (ai-table e :stance)) (r (sim-rnd01)) (threat (br-ai-threat-p s e d))
           (plan (br-ai-stance-plan r d (br-ai-reach e pre "J1") (br-ai-reach e pre "K1") (br-ai-open s b)
                                    (mv-s (find-move (intern (format nil "~a-J1" pre) :keyword)))
                                    (mv-s (find-move (intern (format nil "~a-K1" pre) :keyword))) threat k (brain-difficulty b))))
      (when (and (eq plan :kamae-k) (ai-mash-p b)) (setf plan :kamae-j))
      (case plan
        (:kamae-step (and (br-kamae-step-ok-p (brs-dashed st) (gauges-fs (gauges e))) (why b :en-step :step)))
        (:kamae-l (and (<= d *br-ai-dash-max*) (why b :en-dash :sig)))
        (:kamae-k (why b :en-k :f))
        (:kamae-j (why b :en-j :q))))))

(defun br-ai-envelope (e b s d)
  "His first-strike envelope (m) as E's CPU sees it: his form's J1 (its kit's :q) reach + its lunge (at most 0.8 m) +
*BR-AI-WARD-MARGIN*, + his perceived closing speed x *BR-AI-WARD-LEAD* (cell b2a0)."
  (let ((q (kit-command-move (kit-of (opp-of e)) :q)))
    (+ (if q (+ (mv-reach q) (min 0.8 (mv-slide q))) 1.6) *br-ai-ward-margin*
       (* *br-ai-ward-lead* (max 0.0 (br-ai-closing b s d e))))))

(defun br-ai-ward (e b s d f st)
  "His ward (cell b2a0): free in neutral, him perceived free (idle, walking, running, stepping) inside his first-strike
envelope (BR-AI-ENVELOPE): one roll a *BR-AI-WARD-EVERY* window (*BR-AI-WARD-P* by difficulty): him perceived closing
faster than *BR-AI-WARD-KITE-V* (or no guard left), a dash back to the envelope + *BR-AI-WARD-KITE* (the kite: his first
strike whiffs, the snipe / the dash have their range); else a short guard (*BR-AI-WARD-HOLD*), so his opening J meets a
guard, not a man walking (the opponents' first strikes opened him most; a guard alone fed Kenpachi's J1 pressure loop
into a guard crush). :PRESSED or NIL."
  (when (and (member (fighter-state f) '(:idle :run)) (zerop (brain-press-left b))
             (member (snap-state s) '(:idle :run :step :guard))
             (>= (- *match-tick* (brs-ai-ward st)) *br-ai-ward-every*)
             (<= d (br-ai-envelope e b s d)))
    (setf (brs-ai-ward st) *match-tick*)
    (when (< (sim-rnd01) (getf *br-ai-ward-p* (brain-difficulty b) 0.0))
      (cond ((or (> (br-ai-closing b s d e) *br-ai-ward-kite-v*) (not (plusp (ai-guard-k e))))   ; (him coming in: out of reach)
             (ai-dash b -1.0 (+ (br-ai-envelope e b s d) *br-ai-ward-kite*))
             (pace e :ai-kite)
             (why b :kite :pressed))
            (t (ai-press b :guard (+ (first *br-ai-ward-hold*) (floor (* (sim-rnd01) (1+ (second *br-ai-ward-hold*))))))
               (pace e :ai-ward)
               (why b :ward :pressed))))))

(defun br-ai-anti-breaker (e b s d)
  "His Breaker in its aura / dash within 6 m (one roll per Breaker, BRAIN-REACT-ROLL; cell b1a0's reach model): where it is
when our K1 / J1 would be active (its dash at *BR-AI-BREAKER-V* from where we saw it a perception delay ago) and when its
strike lands (the trigger range, then its startup): K1 when it gets there in K1's reach before the strike, else J1, else a
Hoho close to the strike; meanwhile :WAIT (the generic J1 would come late). The attack-state forms only."
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

(defun br-ai-kikon (e b s d)
  "His Kikon by opportunity (cell b2a0): him red (KIKON-READY-P), perceived reeling or recovering (SNAP-PUNISHABLE-P) with
at least the rush's aura + startup + *BR-AI-KIKON-LEAD* frames left past the perception delay, within *BR-AI-KIKON-IN*; one
roll per action of his (BRAIN-REACT-ROLL, *BR-AI-KIKON-P*); not when the hits would finish him (AI-SB-FINISH-P). :KIKON or NIL."
  (let ((mv (kit-command-move (kit-of e) :kikon)))
    (when (and mv (kikon-ready-p e) (snap-punishable-p s) (< (snap-left s) 99) (<= d *br-ai-kikon-in*)
               (>= (snap-left-seen s b) (+ (or (rush-param mv :aura) 0) (mv-s mv) *br-ai-kikon-lead*))
               (kit-command-ok-p e :kikon) (not (ai-sb-finish-p e))
               (< (brain-react-roll b) (getf *br-ai-kikon-p* (brain-difficulty b) 0.0)))
      (pace e :ai-kikon)
      (why b :kikon-punish :kikon))))

(defun br-ai-unguard (e b s d f)
  "His answer to a long guard (cell b2a0): him perceived guarding at least *AI-GUARD-BREAK-HOLD* frames within
*AI-GUARD-BREAK-RANGE* (the generic Breaker's moment): once per guard of his (that guard's generic Breaker roll is taken:
BRAIN-BREAK-KEY), *BR-AI-UNGUARD-P* of the time by difficulty, a dash back to *BR-AI-UNGUARD-TO* (the snipe's / the dash's
range), else the generic answer. :PRESSED or NIL."
  (when (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
             (/= (brain-break-key b) (snap-start s)) (member (fighter-state f) '(:idle :run :guard)))
    (when (< (brain-react-roll b) (getf *br-ai-unguard-p* (brain-difficulty b) 0.0))
      (setf (brain-break-key b) (snap-start s))
      (ai-dash b -1.0 *br-ai-unguard-to*)
      (pace e :ai-unguard)
      (why b :unguard :pressed))))

(defun br-ai-reflex (e b s d)
  "Every form's :reflex (ai.lisp AI-REFLEX, free states): in EN its decisions (BR-AI-EN); else the base stance as a punish
(his perceived recovery long enough for the stance's opener, inside its reach: one roll per action of his, :zone :punish);
then one roll a window (*BR-AI-EVERY* f): awakened the burst into the owl (BR-AI-BURST-P); the charge from range (:zone
:from .. :to m, his attack not on him: L, held by BR-AI-SIG-HOLD). A command or NIL (nothing to do: the generic answers
and AI-DECIDE's neutral go on)."
  (let* ((f (fighter e)) (st (br e)) (form (fighter-form f)) (g (gauges e)) (diff (brain-difficulty b)))
    (when (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f)))
      (if (br-ranged-form-p form)
          (or (br-ai-kikon e b s d) (br-ai-en e b s d f st))
          (let ((k (ai-table e :zone)) (r (br-ai-event-roll st s)))
            (cond ((br-ai-anti-breaker e b s d))
                  ((br-ai-kikon e b s d))
                  ((br-ai-unguard e b s d f))
                  ((and (member (snap-state s) '(:stun :air))   ; (he reels behind him, after the dash through him: turn first,
                        (< r (getf *br-ai-turn-p* diff 1.0))
                        (> (abs (angle-wrap (- (face-yaw-to e (snap-x s) (snap-z s)) (yaw-of e)))) *br-ai-facing*))   ;  no whiffed J)
                   (why b :ai-turn :wait))
                  ((and k (eq form :base) (snap-punishable-p s) (<= d (br-ai-reach e "BR-S" "K1"))
                        (>= (snap-left-seen s b) (+ *br-kamae-up* (mv-s (find-move :br-s-j1))))
                        (< r (br-ai-chance (getf k :punish 0.0) diff)))
                   (pace e :ai-punish) (why b :punish :sig))
                  ((and (>= (- *match-tick* (brs-ai-t st)) *br-ai-every*)
                        (progn (setf (brs-ai-t st) *match-tick*) t)
                   (cond ((and (br-jilliel-form-p form)
                               (br-ai-burst-p (sim-rnd01) (brs-ammo st) (gauges-fs g) d (ai-table e :burst) diff)
                               (burst-ok-p e))
                          (pace e :ai-burst) (why b :owl :burst))
                         ((and k (<= (getf k :from 5.0) d (getf k :to 12.0)) (not (br-ai-threat-p s e d))
                               (not (and (eq form :base) (eq (snap-state s) :run)))   ; (the snipe: not into his run-in)
                               (< (sim-rnd01) (br-ai-chance (getf k :p 0.0) diff)))
                          (pace e :ai-zone) (why b :zone :sig)))))
                  ((br-ai-ward e b s d f st))))))))

;;; ================================================================ AI: the learning CPU's situation (DUEL_LILLE_V3 §6.3)
;;; Only a learner runs this (a CPU facing a human). :shot = his base stance's K K on a free opponent: the human's answer
;;; (:guard :hoho :step :attack :back :take). Read at the stance's pick (one roll): a guard -> K K stays (its 萬物貫通 drain);
;;; a Step / backing off -> J J (quicker); a Hoho / an attack -> the stance Step, else L L.
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

(defstruct (brl (:conc-name brl-))
  "His learner's own state within a match (LRN-KDATA)."
  (own-mv nil) (ox 0f0 :type single-float) (oz 0f0 :type single-float) (ux 0f0 :type single-float) (uz 0f0 :type single-float)
  (len 0 :type fixnum))
(defun br-learn-state (l) (or (lrn-kdata l) (setf (lrn-kdata l) (make-brl))))
(defun br-learn-l (b) "Brain B's learner when it reads his situations (LRN-KIT), else NIL." (let ((l (and b (brain-learn b)))) (and l (lrn-kit l) l)))

(defun br-learn-step (e b s d l)
  "His learner's step (LEARN-DEF-KIT's :step): the :shot onset (his stance's K1 starting on a free opponent), its answer
(BR-LEARN-ANSWER; at its end :TAKE, or :GUARD held through)."
  (declare (ignore b d))
  (let* ((k (br-learn-state l)) (f (fighter e)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (hs (snap-state s)) (hprev (lrn-hstate l)) (new (/= (snap-start s) (lrn-hstart l))))
    (when (and mv (not (eq mv (brl-own-mv k))) (member (mv-name mv) '(:br-s-k1 :br-e-k1 :br-oe-k1)) (< (lrn-ksit l) 0)
               (member hs '(:idle :run :guard)))
      (let* ((dx (- (snap-x s) (aref (pos-of e) 0))) (dz (- (snap-z s) (aref (pos-of e) 2))) (m (max 1e-3 (hypot dx dz))))
        (setf (brl-ox k) (snap-x s) (brl-oz k) (snap-z s) (brl-ux k) (f32 (/ dx m)) (brl-uz k) (f32 (/ dz m))
              (brl-len k) (+ *br-learn-episode* (brain-delay (brain e)))))
      (learn-kit-open l :shot))
    (setf (brl-own-mv k) mv)
    (when (>= (lrn-ksit l) 0)
      (let ((end (>= (incf (lrn-kep-t l)) (brl-len k)))
            (away (+ (* (- (snap-x s) (brl-ox k)) (brl-ux k)) (* (- (snap-z s) (brl-oz k)) (brl-uz k)))))
        (cond ((member hs '(:stun :air :down :wakeup)) (learn-kit-close l :take))
              (t (let ((ans (br-learn-answer hprev hs new away)))
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

(learn-def-kit :barro :situations #(:shot) :actions #(:guard :hoho :step :attack :back :take) :step 'br-learn-step)

;;; ================================================================ ASSIST AUTO COMBO's routes (DUEL_LILLE_V3 §6.3)
;;; "You press J, the CPU chooses": the routes press his buttons as a human's, the AUTO tag.
;;;   attack state  his J in a J / K link that hit, on its land frame: a J link -> its K link; a K link -> L (the stance:
;;;                 the base's at f4, the awakened turn)
;;;   stance        his J while the stance is up (the base stance's window, the awakened stance free): K (K K, whose J J
;;;                 the generic latch takes on his next J)
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
    (cond ((and mv (member (mv-name mv) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)))
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
