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
(defparameter *br-kamae-max* 90 "... and at most while L is held; then R 14 (copied 2026-10-09).")
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
(defparameter *br-s-k-dmg* 28 "Stance K 高攻: K1 / K2's one hit (R7: 2 x 14 -> 28; R3, 45 a shot before) ...")
(defparameter *br-s-k3-dmg* 42 "... K3's (R7: 3 x 14 -> 42; a string 98 as before) ...")
(defparameter *br-s-kl-dmg* 45
  "... its L L follow-up (R3: K K -> L L, 「兩者都花資源」): each line's damage, one special spent a line (a 萬物貫通 line, 31 m;
none left: no follow-up). The K K -> J J follow-up's 15 + 30 before (new 2026-10-11 [G]).")
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
(defparameter *br-k-mult* 1.20 "... its damage x this, rounded ...")
(defparameter *br-k-adv* -4 "... and its block advantage this many frames lower (decision V8).")

;; JILLIEL
(defparameter *br-walk-en* 3.0 "Walk m/s, the awakened stance EN (afloat; the old *WALK-JILLIEL*, copied 2026-10-09).")
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
:enter + (*BR-K-SLOW* - *BR-K-LINK-SLOW*)); its hit-frame hooks follow the new startup; :clip-s the old startup. A new plist."
  (let* ((j (member route '(:j :jn))) (std (eq route :jn)) (s0 (getf spec :startup)) (r0 (getf spec :recovery))
         (s1 (cond (std s0) (j (max *br-j-min-s* (- s0 *br-j-speed*))) (t (+ s0 *br-k-slow*))))
         (r1 (cond (std r0) (j (max *br-j-min-r* (- r0 *br-j-speed*))) (t (+ r0 *br-k-slow*))))
         (new (list :startup s1 :recovery r1
                    :dmg (round (* (getf spec :dmg) (if j *br-j-mult* *br-k-mult*)))
                    :adv-block (+ (getf spec :adv-block) (if j *br-j-adv* *br-k-adv*))
                    :on-frame (br-v8-shift (getf spec :on-frame) s0 (- s1 s0))
                    :enter (let ((n (or (getf spec :enter) 0)))
                             (if (and (not j) (plusp n)) (+ n (- *br-k-slow* *br-k-link-slow*)) n))
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
;; (clip authored-startup) by segment (:l1 .. :kl3; the clip plays at authored / S speed); ADV the owl's +1 (R one less).
(eval-when (:compile-toplevel :load-toplevel :execute)   ; (BR-DEFSTANCE reads it while it expands)
(defparameter *br-w-near-r* 0.4
  "The awakened stances' openers (decision R4, the user 2026-10-11: 「所有起手連段一律用近距離攻擊」): a wing / claw strike's
volume radius, metres; its reach each hit's drawn tip (*BR-W-TIPS*; new 2026-10-11 [G]).")
(defparameter *br-w-kb* 0.05
  "The awakened stances' melee openers (R4): each hit's push, metres (the shots' 0.3 pushed him out of a 1.4-2.2 m reach within
a string: L1 + L2 1.3 -> 2.3 m in the browser; new 2026-10-11 [G]).")
(defparameter *br-w-tips*
  '(("BR-E" ("L1" 1.85) ("L2" 1.85) ("L3" 1.85) ("J1" 2.85) ("J2" 2.8)
     ("J3" 2.4) ("K1" 2.0) ("K2" 1.35) ("K3" 1.2))
    ("BR-OE" ("L1" 1.7) ("L2" 1.7) ("L3" 1.7) ("J1" 2.8) ("J2" 2.75)
     ("J3" 2.4) ("K1" 1.75) ("K2" 1.35) ("K3" 1.15)))
  "The awakened stances' melee openers (decision R4): each hit's reach, metres (its volume's edge), = the striking wing tip's
/ claw's distance ahead on that hit frame in its clip (barro-art.lisp :br-en-* / :br-oen-*, the host FK test: drawn reach =
hit reach, +-0.15 m). By the move prefix, then the segment. R5 (the user 2026-10-11: the motion modules, the reach
「跟著動作走」; 「長鞭可以連成大砍刀，砲擊也可以接在近距離毆打後面」): L 陀螺 the flat wing / claw (1.6-1.8 before), J 長鞭 the
stretched whip's tip (*BR-W-STRETCH*; 1.35-1.7 before) and J3's last the cleaver it stiffens into, K1 大刀 the joined great
blade, K2 / K3's first two the folded wings' close blows, K3's last 零距離砲擊 point blank (K 1.5-2.2 before).")
(defparameter *br-s-l-whiff* 8
  "A whiffed stance L segment recovers R + this (decision R5, the user 2026-10-11: 「架式 > L 只要沒打中就進入硬直」, 「就跟一般的
J / K 普攻一樣」: a J link's *WHIFF-EXTRA-J*; the :sig moves' *WHIFF-EXTRA* 6 before).")
(defparameter *br-w-segs*
  '(("J3" 14 14) ("K1" 16 18))
  "The awakened stances' melee openers timed apart from *BR-S-SEGS*: name, startup, recovery (decision R6, the user
2026-10-11: 「大砍刀的動作要更緩慢沉重、扭轉身體、砍刀後拉，每次只用一隻光翼揮砍」; one hit a press since R7): J3 the cleaver
(startup 8 -> 14), K1 the great-sword chop (12 -> 16) ([G]).")
(defparameter *br-w-l-slow* 1.5
  "The awakened stance's L segments: startup and hit spacing x this (decision R4, the user 2026-10-11: 「架式 L 的動作太快了」,
「出手和間隔都放慢」: startup 8 -> 12, L1 / L2 every 8 -> 12 f, L3 every 6 -> 9 f; [G]).")
(defparameter *br-s-segs*
  ;; name kind startup hit-offsets recovery damage react-between react-last role extra
  ;; (decision R7, the user 2026-10-11: 「我希望段數跟操作時的點擊次數一致，這樣玩家才能輕鬆確認到底打到哪一段」: one hit a
  ;; segment, a press; the openers had 2-4 hits a segment before)
  '(("L1" :sig 8 (0) 14 *br-s-l-dmg* :flinch :flinch :l (:gain 0))
    ("L2" :sig 8 (0) 14 *br-s-l-dmg* :flinch :flinch :l (:gain 1))
    ("L3" :sig 8 (0) 18 *br-s-l3-dmg* :stagger :stagger :l (:gain 2))
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
(defmacro br-defstance (prefix clips &key (adv 0) melee (l-slow 1))
  "The stance's moves of PREFIX (*BR-S-SEGS*). CLIPS by segment; ADV the owl's +1 (R one less). MELEE (the awakened forms, R4:
「所有起手連段一律用近距離攻擊」): the openers (the segments that spend nothing) strike in reach (each hit its own melee volume,
*BR-W-TIPS*; not :ranged, no line drawn) instead of the 4 m shots. L-SLOW (R4: 「架式 L 的動作太快了」): the L segments' startup and their
hits' spacing x this (the clip slowed with them, its recovery as written); MELEE also times *BR-W-SEGS*' segments their own
way (R6)."
  (let ((l-slow (if (symbolp l-slow) (symbol-value l-slow) l-slow)))
    `(progn
       ,@(loop for (sn kind st00 offs00 r00 dmg mid last role extra) in *br-s-segs*
               collect
               (let* ((ov (and melee (cdr (assoc sn *br-w-segs* :test #'string=))))
                      (st0 (if ov (first ov) st00)) (offs0 offs00) (r0 (if ov (second ov) r00))
                      (name (intern (format nil "~a-~a" prefix sn) :keyword))
                      (clip (getf clips (intern sn :keyword)))
                      (slow (if (eq role :l) l-slow 1))
                      (st (round (* st0 slow))) (offs (mapcar (lambda (o) (round (* o slow))) offs0))
                      (far (getf extra :spend))
                      (cut (and melee (not far)))
                      (r (max 4 (- r0 adv))) (a (+ 2 (car (last offs))))
                      (n (length offs)))
                 `(defmove ,name :kind ,kind :clip ,(first clip) :clip-s ,(second clip)
                    :startup ,st :active ,a :recovery ,r
                    ,@(when (eq role :l) `(:whiff ,(+ r *br-s-l-whiff*)))   ; (R5: a whiffed L recovers as a J link)
                    :dmg ,dmg :adv-block ,(max (+ -12 adv) (- 1 (+ a r))) :track 720.0   ; (>= 1 f of blockstun)
                    :vol ,(cond (cut `(:cap 0.4 ,(- (reduce #'max (cdr (assoc sn (cdr (assoc prefix *br-w-tips* :test #'string=))
                                                                                :test #'string=)))
                                                    *br-w-near-r*)
                                              1.2 ,*br-w-near-r*))
                                (far '(:cap 0.6 *br-x-len* 1.2 0.25))
                                (t '(:cap 0.6 *br-s-near* 1.2 0.25)))
                    :on-hit ,last :kb ,(if cut *br-w-kb* 0.3)
                    ,@(cond (far '(:chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable)))
                            (cut nil)
                            (t '(:flags (:ranged))))
                    :hits ,(loop for o in offs for i from 1
                                 for tip in (if cut (cdr (assoc sn (cdr (assoc prefix *br-w-tips* :test #'string=))
                                                                :test #'string=))
                                                (make-list n))
                                 collect `(,(+ st o) ,(+ st o 2) :on-hit ,(if (= i n) last mid)
                                           ,@(when cut `(:vol (:cap 0.4 ,(- tip *br-w-near-r*) 1.2 ,*br-w-near-r*)))))
                    :tick br-s-tick
                    :on-frame ((0 ,(if far 'br-s-spend 'br-s-start))
                               ,@(unless cut (loop for o in offs collect `(,(+ st o) br-shot-fire))))
                    :params (:stance ,role :len ,(cond (far '*br-x-len*) (cut 2.0) (t '*br-s-near*)) ,@extra)))))))
(defun br-stance-strings (prefix sp2)
  "The kit strings of PREFIX's stance (BR-DEFSTANCE): J1 -> J2 -> J3, K1 -> K2 -> K3 by the J / K latch; L1 -> L2 -> L3, J3 ->
JL1 -> JL2 -> JL3, K3 -> KL1 -> KL2 -> KL3 by BR-S-TICK's latch (command :lchain); every J / K / JL / KL segment that hit -> the form's
charge-less SP2 SP2 (:sp2c, decision R3)."
  (flet ((nm (s) (intern (format nil "~a-~a" prefix s) :keyword)))
    `((,(nm "J1") :q ,(nm "J2")) (,(nm "J2") :q ,(nm "J3")) (,(nm "K1") :f ,(nm "K2")) (,(nm "K2") :f ,(nm "K3"))
      (,(nm "L1") :lchain ,(nm "L2")) (,(nm "L2") :lchain ,(nm "L3"))
      (,(nm "J3") :lchain ,(nm "JL1")) (,(nm "JL1") :lchain ,(nm "JL2")) (,(nm "JL2") :lchain ,(nm "JL3"))
      (,(nm "K3") :lchain ,(nm "KL1")) (,(nm "KL1") :lchain ,(nm "KL2")) (,(nm "KL2") :lchain ,(nm "KL3"))
      ,@(loop for sg in '("J1" "J2" "J3" "JL1" "JL2" "JL3" "K1" "K2" "K3" "KL1" "KL2" "KL3") collect `(,(nm sg) :sp2c ,sp2)))))

;;; ================================================================ the base form
;; the J / K strings: the old Lille's frames and clips, decision V8 on top
(br-defstring :j :br-j1 :kind :quick :clip :lb-q1 :startup 8 :active 3 :recovery 12 :dmg 26 :adv-block -2
  :reach 1.45 :arc 100 :on-hit :flinch)
(br-defstring :j :br-j2 :kind :quick :clip :lb-q2 :startup 7 :active 3 :recovery 13 :dmg 22 :adv-block -2
  :reach 1.45 :arc 110 :on-hit :flinch)
(br-defstring :j :br-j3 :kind :quick :clip :lb-jab :startup 9 :active 3 :recovery 18 :dmg 28 :adv-block -4
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
(br-defstance "BR-S" (:l1 (:br-sk-l1 8) :l2 (:br-sk-l2 8) :l3 (:br-sk-l3 8) :j1 (:br-sk-j1 8) :j2 (:br-sk-j2 8)
                      :j3 (:br-sk-j3 8) :k1 (:br-sk-k1 12) :k2 (:br-sk-k2 12) :k3 (:br-sk-k3 12)
                      :jl1 (:br-sk-jl1 8) :jl2 (:br-sk-jl2 8) :jl3 (:br-sk-jl3 8) :kl1 (:br-sk-kl1 10) :kl2 (:br-sk-kl2 10)
                      :kl3 (:br-sk-kl3 10)))
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
(br-defstring :k :br-w-k1 :kind :flash :clip :lb-w-f1 :startup 17 :active 4 :recovery 21 :dmg 50 :adv-block -3
  :reach 2.2 :arc 150 :on-hit :stagger)
(br-defstring :k :br-w-k2 :kind :flash :clip :lb-w-f2 :enter 6 :startup 20 :active 4 :recovery 24 :dmg 50 :adv-block -3
  :reach 2.2 :arc 110 :on-hit :stagger)
(br-defstring :k :br-w-k3 :kind :flash :clip :lb-w-f3 :enter 7 :startup 21 :active 5 :recovery 34 :dmg 72 :adv-block -20
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
(br-defstance "BR-E" (:l1 (:br-en-l1 8) :l2 (:br-en-l2 8) :l3 (:br-en-l3 8) :j1 (:br-en-j1 8) :j2 (:br-en-j2 8)
                      :j3 (:br-en-j3 8) :k1 (:br-en-k1 12) :k2 (:br-en-k2 12) :k3 (:br-en-k3 12)
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
(br-defstring :k :br-o-k1 :kind :flash :clip :lb-o-f1 :startup 17 :active 4 :recovery 20 :dmg 54 :adv-block -2
  :reach 2.3 :arc 150 :on-hit :stagger :tick br-s-tick :on-frame ((0 br-s-start)))
(br-defstring :k :br-o-k2 :kind :flash :clip :lb-o-f2 :enter 6 :startup 20 :active 4 :recovery 23 :dmg 54 :adv-block -2
  :reach 2.3 :arc 110 :on-hit :stagger :tick br-s-tick :on-frame ((7 br-s-start)))   ; (its V8 :enter, 6 + 1)
(br-defstring :k :br-o-k3 :kind :flash :clip :lb-o-f3 :enter 7 :startup 21 :active 5 :recovery 33 :dmg 78 :adv-block -19
  :reach 2.3 :arc 90 :on-hit :crumple :flags (:ender) :tick br-s-tick :on-frame ((8 br-s-start)) :params (:end t))   ; (7 + 1)
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
(br-defstance "BR-OE" (:l1 (:br-oen-l1 8) :l2 (:br-oen-l2 8) :l3 (:br-oen-l3 8) :j1 (:br-oen-j1 8) :j2 (:br-oen-j2 8)
                       :j3 (:br-oen-j3 8) :k1 (:br-oen-k1 12) :k2 (:br-oen-k2 12) :k3 (:br-oen-k3 12)
                       :jl1 (:br-oe-jf1 8) :jl2 (:br-oe-jf2 8) :jl3 (:br-oe-jf3 8) :kl1 (:br-oe-kf1 10) :kl2 (:br-oe-kf2 10)
                       :kl3 (:br-oe-kf3 10))
              :adv 1 :melee t :l-slow *br-w-l-slow*)

;;; His own moves' clips (barro-art.lisp): the owl's twins through its kits' :clip-map
(defparameter *br-owl-clip-map* '(:br-recall :br-o-recall :br-rc0 :br-o-rc0 :br-rc1 :br-o-rc1 :br-rc2 :br-o-rc2
                                  :br-rc3 :br-o-rc3 :br-rc4 :br-o-rc4 :br-to-en :br-o-to-en)
  "The owl kits' :clip-map: the shared moves (the volley, its strings, the turn) on the claws' own clips.")

;;; ================================================================ forms
(defparameter *barro-hooks* '(:tick barro-tick :ok barro-ok :hit barro-hit :struck barro-struck :armor barro-armor
                               :step barro-step :draw br-draw)
  "His mechanics (kit.lisp KIT-HOOK): the burst owl, the owl's wings, the stance's end (:tick); the stance links (:ok); the
specials and the recovery shots' gains (:hit); the wing armour's price (:struck) and its test (:armor, fighter.lisp
DEFENDER-STATE); EN's fast Step (:step, decision R3); his looks (:draw, barro-art.lisp).")

(defparameter *br-kamae-strings*
  (append (loop for s in '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
                append (loop for c in '(:kamae-l :kamae-j :kamae-k :kamae-sp1 :kamae-sp2 :kamae-step)
                             collect (list s c (br-kamae-pick c))))
          '((:br-k-dash :kamae-back :br-kamae-re) (:br-k-dash :kamae-j :br-s-j1))
          (br-stance-strings "BR-S" :br-k-hiren-c))
  "The base stance's picks: non-button strings (KIT-NEXT) its :tick starts (BR-KAMAE-TICK); the Step, its way back into the
stance and its J (the stance's J J); the stance's three strings (BR-DEFSTANCE).")
(defparameter *br-melee-strings*
  (append '((:br-recall :rc0 :br-rc0) (:br-recall :rc1 :br-rc1) (:br-recall :rc2 :br-rc2) (:br-recall :rc3 :br-rc3)
            (:br-recall :rc4 :br-rc4))
          (br-stance-strings "BR-E" :br-w-nijushi-c) (br-stance-strings "BR-OE" :br-recall)
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
  :ai (:intents (:approach 3 :pressure 3 :zone 1 :defend 2)            ; (R3: the stance's openers reach 4 m, he closes in)
       :ranges (:approach (2.2 8.0) :pressure (1.3 3.5) :zone (3.5 8.0) :defend (5.0 9.0))
       :moves ((0.0 2.2 :q 4 :f 2 :breaker 1 :step 2 :sig 2)
               (2.2 4.0 :step 1 :sp1 1 :sig 4 nil 1)
               (4.0 99.0 :sp1 1 nil 3))
       :guard 0.5 :hoho 0.3 :dash 0.6 :dash-back 0.3 :block-string 0.3 :o-ender 0.3 :l-after-k 0.6 :l-after-j 0.3 :kikon-range 7.7
       :awaken (:min-taken 150) :reflex br-ai-reflex
       :zone (:p 0.5 :in 4.0)                                      ; (the stance inside its reach, one roll a window)
       :stance (:gather 0.6 :recover-fs 40.0 :recover-bars 1 :step 0.4 :follow 0.6 :sp2-at 2 :sp2 0.8)))

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
  :l-after-k :br-to-en :l-after-j :br-to-en
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.4 6.0) :pressure (1.4 2.4) :zone (3.0 6.0) :defend (3.0 6.0))
       :moves ((0.0 2.4 :q 4 :f 4 :breaker 1 :sig 1)
               (2.4 4.0 :sig 3 :step 1 :sp1 1 nil 1)
               (4.0 99.0 :step 1 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :block-string 0.3 :o-ender 0.3 :kikon-range 8.5
       :string-k 0.6 :l-after-k 0.4 :l-after-j 0.3
       :burst (:p 0.5 :wings 5 :in 6.0) :reflex br-ai-reflex
       :stance (:follow 0.6 :sp2-at 4 :sp2 0.8)))

;; JILLIEL EN, the stance (afloat): L / J / K start the stance's strings, each ending back in KIN (BARRO-TICK)
(defkit :barro :jilliel :inherit :jilliel-kin
  :form-name "JILLIEL" :walk *br-walk-en* :run *br-run-en* :body :lille-jilliel
  :commands (:q :br-e-j1 :f :br-e-k1 :sig :br-e-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)            ; (R5: the whips 2.8, the top 1.85, the K beating 1.2-2.0 m)
       :ranges (:approach (2.6 8.0) :pressure (1.0 2.6) :zone (3.5 8.0) :defend (5.0 9.0))
       :moves ((0.0 1.4 :f 4 :sig 2 :q 2 :step 1)
               (1.4 1.9 :sig 3 :q 3 :f 1)
               (1.9 2.8 :q 4 :step 1)
               (2.8 99.0 :sp1 1 :step 2 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :dash-back 0.2 :kikon-range 8.5
       :burst (:p 0.5 :wings 5 :in 6.0) :reflex br-ai-reflex
       :stance (:follow 0.6 :sp2-at 4 :sp2 0.8)))

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
               (2.6 4.0 :sig 3 :step 1 :sp1 1 nil 1)
               (4.0 99.0 :step 1 nil 3))
       :guard 0.3 :hoho 0.3 :dash 0.9 :block-string 0.3 :o-ender 0.2 :kikon-range 9.0
       :string-k 0.8 :l-after-k 0.5 :l-after-j 0.2 :reflex br-ai-reflex
       :stance (:follow 0.7 :sp2-at 3 :sp2 0.9)))

(defkit :barro :shin :inherit :shin-kin
  :lift *br-owl-lift* :form-name "SHIN" :walk *br-walk-en* :run *br-run-en* :stance :lb-oe-stance
  :commands (:q :br-oe-j1 :f :br-oe-k1 :sig :br-oe-l1)
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.6 8.0) :pressure (1.0 2.6) :zone (3.5 8.0) :defend (5.0 9.0))   ; (R5: arm whips 2.75, spin 1.7, K 1.15-1.75 m)
       :moves ((0.0 1.4 :f 4 :sig 1 :q 2 :step 1)
               (1.4 1.75 :sig 2 :q 3 :f 1)
               (1.75 2.75 :q 4 :step 1)
               (2.75 99.0 :sp1 1 :step 2 nil 3))
       :guard 0.4 :hoho 0.3 :dash 0.8 :dash-back 0.2 :kikon-range 9.0 :reflex br-ai-reflex
       :stance (:follow 0.7 :sp2-at 3 :sp2 0.9)))

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
  (armored 0 :type fixnum)                ; hits his wing armour took (the pacing log)
  (ai-t -999 :type fixnum)                ; his CPU's last stance / burst window (one roll a window)
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
*BR-KAMAE-DASH-FS* flash step (short of it: the plain Step)."
  (let* ((f (fighter e)) (st (br e)) (g (gauges e)))
    (when (and (br-ranged-form-p (fighter-form f)) (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g)))
      (spend-fs g *br-kamae-dash-fs*)
      (setf (brs-dashed st) t)
      (multiple-value-bind (to sd) (stick-relative e f)
        (multiple-value-bind (to sd) (step-direction to sd)
          (multiple-value-bind (dx dz) (world-dir e f to sd)
            (set-slide e *br-kamae-dash* *br-kamae-dash-f* dx dz))))
      (pace e :en-dash)
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
  (declare (ignore def ranged))
  (let ((st (br att)) (c (contact-of res)) (role (and mv (not hazard) (getf (mv-params mv) :stance))))
    (when (and role (member c '(:hit :block)) (not (brs-gained st)))
      (setf (brs-gained st) t)
      (case role
        (:l (let ((k (br-l-gain c (getf (mv-params mv) :gain 0))) (form (fighter-form (fighter att))))
              (when (plusp k) (setf (brs-ammo st) (br-ammo-add (brs-ammo st) k form)) (pace att :ammo-gain k))))
        ((:j :jl) (multiple-value-bind (fs sp) (br-recover-gain c role (brs-spent st))
                    (pay-gauges att sp fs)
                    (pace att (if (and (eq role :jl) (brs-spent st)) :recover-big :recover))))))
    (when (and role (eq c :hit) (brs-slow st))
      (setf (brs-slow st) nil)
      (slowmo *br-fresh-scale* *br-fresh-secs*) (pace att :slow-fresh) (clog "~a stance slow motion" (side-name att)))
    (when (and mv (not hazard) (eq c :hit) (member (mv-name mv) '(:br-rc3 :br-rc4))
               (eq hw (svref (mv-hits mv) (1- (length (mv-hits mv))))))
      (slowmo *br-volley-scale* *br-volley-secs*) (pace att :slow-volley) (clog "~a volley slow motion" (side-name att)))
    (when (and hw (br-x-hit-p hw))
      (pace att (if (eq c :hit) :x-hit :x-guarded)))))

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
      (t (start-move e (kit-next kit (mv-name mv) cmd)) (pace e cmd) t))))

(defun br-kamae-tick (e)
  "One step of the base stance: it turns at *BR-AIM-TRACK*; from f6 the first L / J / K / SP1 / SP2 / Step picks (his
CPU's: BR-AI-KAMAE); past the hold (30 f, 90 while L is held) the stance recovers (R 14)."
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and (eq (fighter-state f) :move) mv (member (mv-name mv) '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)))
      (let* ((st (br e)) (sf (fighter-sf f)) (vp (pilot-vpad (pilot e))) (b (br-tick-brain e)))
        (turn-to-opp e f (track-step *br-aim-track*))
        (when (>= sf *br-kamae-up*)
          (let ((cmd (if b (br-ai-kamae e f st b) (br-kamae-pressed vp))))
            (when cmd
              (let ((button (getf '(:kamae-j :quick :kamae-k :flash :kamae-l :sig :kamae-sp1 :flash :kamae-sp2 :sig
                                    :kamae-step :step)
                                  cmd)))
                (if (br-kamae-go e f st mv cmd)
                    (progn (unless b (vpad-consume! vp button)) (return-from br-kamae-tick nil))
                    (if b (setf (brs-k-plan st) :kamae-l) (vpad-consume! vp button)))))))
        (when (br-kamae-hold-over-p sf (vpad-down vp :sig))
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
    (cond ((and sp2 (getf (mv-params mv) :end) (eq (fighter-contact f) :hit) (>= (reiatsu-bars e) 2) (>= n (getf k :sp2-at 3))
                (< r (br-ai-chance (getf k :sp2 0.0) d)))
           :sp2)
          ((null next) :no)
          ((not (getf (mv-params next) :spend)) :go)
          ((and (br-follow-ok-p n) (< r (br-ai-chance (getf k :follow 0.0) d))) :go)
          (t (pace e :ai-follow-no) :no))))

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
                   (when (try-command e f :sp2 nil nil sp2) (pace e :k-sp2)))
                  ((and (brs-l-next st) next)
                   (setf (brs-l-next st) nil (brs-sp2-next st) nil)
                   (cond ((null (fighter-contact f)) (pace e :l-whiff))   ; (R5: a whiff ends it, as a J / K string)
                         ((or (not (getf (mv-params next) :spend)) (br-follow-ok-p (brs-ammo st)))
                          (start-move e next) (pace e :l-chain))
                         (t (pace e :follow-empty)))))))))))

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
  (let ((mv (fighter-move (fighter e))))
    (br-spawn-look e :shot (or (move-param e :len) *br-x-len*) 0.05 (and (member :x-axis (mv-flags mv)) t))
    (emit :sfx :lb-crack e)))
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
  "The turn's last frame: the stance EN."
  (let* ((form (fighter-form (fighter e))) (to (br-ranged-of form)))
    (unless (eq to form) (set-form e to) (pace e :to-ranged))))
(defun br-halt-tick (e) "The turn, the volley: no string chase." (halt! e))
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
;;; ================================================================ AI (DUEL_LILLE_V3 §6.3)
;;; His CPU: his kits' :ai keys (every chance x *BR-AI-DIFF* by difficulty: EASY <= NORMAL <= HARD), the generic bands and
;;; string reflex (the stances' J1 -> J2 / K1 -> K2 go on by the J / K latch like any string) and these, each one roll per
;;; window (*BR-AI-EVERY* f) or event:
;;;   base     the stance inside :zone's :in m (L), then its pick (BR-AI-STANCE-PLAN: L L below :gather of the cap, J J when
;;;            the flash step is under :recover-fs or the bars short, else K K; the Step off his attack); L after a K / J
;;;            link (:l-after-k / -j) -> the stance at f4
;;;   KIN      the generic strings, L after a link (the turn); the burst into the owl with :burst's wings and flash step
;;;            inside :in m
;;;   EN       the generic bands press L / K / J: the stance's strings (each ends in KIN)
;;;   stance   at the end of a move's hits one call (BR-S-CPU-CALL, the kit's :stance): K K that hit -> SP2 (:sp2-at
;;;            specials, the bars, :sp2), else the L L follow-up (:follow, a special to spend)
(defparameter *br-ai-diff* '(:easy 0.5 :normal 1.0 :hard 1.5)
  "His CPU's chances (his kits' :ai :p values) x this by difficulty, at most 1 (the old Lille's *LB-AI-DIFF*).")
(defparameter *br-ai-every* 30 "Frames between two of his window rolls (the base stance from range, the burst; new 2026-10-09).")

;; pure: host-tested
(defun br-ai-chance (p difficulty) "A chance P of his kit's :ai at DIFFICULTY: x *BR-AI-DIFF*, at most 1." (min 1.0 (* p (getf *br-ai-diff* difficulty 1.0))))
(defun br-ai-stance-plan (r ammo cap fs bars k &optional threat)
  "His CPU's base stance pick from one roll R (K: the kit's :stance): his attack coming (THREAT) the Step (:step of the time);
the specials (AMMO of CAP) under :gather of the cap: L L; the flash step FS under :recover-fs or the Reiatsu BARS under
:recover-bars: J J; else K K (its SP2: BR-S-CPU-CALL; the stance's own SP2 on its own is the slow one, decision R3)."
  (cond ((and threat (< r (getf k :step 0.0))) :kamae-step)
        ((< ammo (* (getf k :gather 0.5) cap)) :kamae-l)
        ((or (< fs (getf k :recover-fs 40.0)) (< bars (getf k :recover-bars 1))) :kamae-j)
        (t :kamae-k)))
(defun br-ai-burst-p (r ammo fs d k difficulty)
  "Does his awakened CPU burst into the owl (K: the kit's :burst) from one roll R: AMMO >= :wings, FS >= the burst's
*FS-BURST*, him inside :in m, :p x the DIFFICULTY?"
  (and k (>= ammo (getf k :wings 5)) (>= fs *fs-burst*) (< d (getf k :in 6.0))
       (< r (br-ai-chance (getf k :p 0.0) difficulty))))

(defun br-ai-kamae (e f st b)
  "His CPU's pick in the base stance (BR-KAMAE-TICK, from f6): once a stance (one roll, BR-AI-STANCE-PLAN; a learner's read
may change it, BR-LEARN-KAMAE); a Step plan clears itself so the window after it picks again."
  (unless (brs-k-plan st)
    (let* ((k (ai-table e :stance)) (g (gauges e)) (s (br-ai-seen b))
           (threat (and s (eq (snap-state s) :move) (< (fighter-dist f) 4.0))))
      (setf (brs-k-plan st)
            (br-learn-kamae e b (br-ai-stance-plan (sim-rnd01) (brs-ammo st) (br-ammo-cap (fighter-form f)) (gauges-fs g)
                                                   (reiatsu-bars e) k threat)))
      (when (and (eq (brs-k-plan st) :kamae-step) (not (br-kamae-step-ok-p (brs-dashed st) (gauges-fs g))))
        (setf (brs-k-plan st) :kamae-l))
      (pace e (intern (format nil "AI-~a" (brs-k-plan st)) :keyword))
      (why b :kamae (brs-k-plan st))))
  (let ((plan (brs-k-plan st)))
    (when (eq plan :kamae-step) (setf (brs-k-plan st) nil))
    plan))

(defun br-ai-seen (b)
  "The SNAP brain B perceives this step (BRAIN-PERCEIVE's ring at the delay; NIL before it holds one): for his ticks, which
run inside moves where the reflexes don't (the old LB-AI-SEEN)."
  (let* ((ring (brain-ring b)) (n (length ring)))
    (and (plusp n) (svref ring (mod (- (brain-head b) 1 (brain-delay b)) n)))))

(defun br-ai-reflex (e b s d)
  "Every form's :reflex (ai.lisp AI-REFLEX, free states): the base stance inside its reach (:zone :in, decision R3: the
openers reach 4 m); awakened, the burst into the owl (BR-AI-BURST-P). One roll a window (*BR-AI-EVERY* f). A command or
NIL."
  (declare (ignore s))
  (let* ((f (fighter e)) (st (br e)) (form (fighter-form f)) (g (gauges e)))
    (when (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
               (>= (- *match-tick* (brs-ai-t st)) *br-ai-every*))
      (setf (brs-ai-t st) *match-tick*)
      (cond ((eq form :base)
             (let ((k (ai-table e :zone)))
               (when (and k (< d (getf k :in 4.0)) (< (sim-rnd01) (br-ai-chance (getf k :p 0.0) (brain-difficulty b))))
                 (pace e :ai-zone) (why b :zone :sig))))
            ((br-jilliel-form-p form)
             (when (br-ai-burst-p (sim-rnd01) (brs-ammo st) (gauges-fs g) d (ai-table e :burst) (brain-difficulty b))
               (when (burst-ok-p e) (pace e :ai-burst) (why b :owl :burst))))))))

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
