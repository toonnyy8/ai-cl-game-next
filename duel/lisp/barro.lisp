;;;; barro.lisp — LILLE BARRO II (roster index 6, kit :barro, display name "LILLE II"), version 3 (docs/duel/DUEL_LILLE_V3.md;
;;;; the earlier versions' record: DUEL_LILLE_V2.md). A separate fighter built from a copy of lille.lisp (the old Lille stays
;;;; as he is, index 5). Version 3 (the user, 2026-10-10, decisions R1 / R2): one grammar in every form, the base stance's.
;;;; The attack state is the form's J / K strings (the man with Diagramm, JILLIEL's wing cuts KIN, the owl's claws); L enters
;;;; THE STANCE (the base form's 狙擊架式 move, the awakened forms' ranged mode EN), whose first press picks one of three
;;;; strings, each ending back in the attack state: L L gathers the special resource (the base's 狙擊 pips, cap 3; the
;;;; awakened wings, cap 8), K K hits hard and may go on into J J that spends one a hit for damage, J J refills flash step and
;;;; Reiatsu and may go on into K K that spends one a hit for more. SP1 / SP2 read the count (SP1 more flash step back, SP2 a
;;;; shorter charge). A burst in an awakened form turns him into the owl until it ends (one buff set); the owl's K3 -> L is
;;;; the full volley, the one move that spends every wing for damage. Awakened, a hit during his own attack spends 4 wings
;;;; (the owl 2) and the attack goes on. U guards in every form. 萬物貫通 THE X-AXIS on every line (a block drains 40 of the
;;;; guard gauge and lets 30 % through, the line runs 31 m).
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
(defparameter *br-kamae-dash* 3.5
  "The stance's Step 飛廉脚: metres in the stick direction (neutral: away from him) over *BR-KAMAE-DASH-F* (the old
*LB-KAMAE-DASH*, copied 2026-10-10, decision V6) ...")
(defparameter *br-kamae-dash-f* 12 "... frames; back in the stance on its f6 at *BR-KAMAE-BACK* (copied 2026-10-10) ...")
(defparameter *br-kamae-back* 11 "... this frame of the step (the old :lb-k-dash's f11 -> the stance's f6, a fresh window) ...")
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
;; 消耗資源提高傷害 3. 架勢 > JJ： 高額閃步/SP 量表恢復，可以再銜接 KK 消耗資源提高恢復量」; 「每下花 1 翼」; 「連段打完自動回近戰」).
;; Every number [G], DUEL_LILLE_V3 §3.2; damage before the form's multiplier
(defparameter *br-s-l-dmg* 10 "Stance L L 回收: each shot's damage, 萬物貫通 (new 2026-10-10 [G]) ...")
(defparameter *br-s-l-gain* '(1 2)
  "... the special each of its two shots gives on a hit or a block (L1 +1, L2 +2: a full string +3; new 2026-10-10 [G]).")
(defparameter *br-s-k-dmg* 45 "Stance K K 高攻: each shot's damage, 萬物貫通 (new 2026-10-10 [G]); no resource back ...")
(defparameter *br-s-kj-dmg* 15 "... its J J follow-up: each shot's damage without a special to spend (new 2026-10-10 [G]) ...")
(defparameter *br-s-kj-bonus* 30 "... + this with one spent (15 -> 45; R2 「每下花 1 翼」; new 2026-10-10 [G]).")
(defparameter *br-s-j-dmg* 15 "Stance J J 回復: each shot's damage, 萬物貫通 (new 2026-10-10 [G]) ...")
(defparameter *br-s-j-fs* 10.0 "... its hit gives this much flash step ...")
(defparameter *br-s-j-sp* 15.0 "... and this much Reiatsu (a block x *BR-S-BLOCK*; new 2026-10-10 [G]) ...")
(defparameter *br-s-jk-dmg* 20 "... its K K follow-up: each shot's damage (new 2026-10-10 [G]); its hit gives J J's, and with a
special spent ...")
(defparameter *br-s-jk-fs* 20.0 "... + this much flash step ...")
(defparameter *br-s-jk-sp* 30.0 "... + this much Reiatsu (new 2026-10-10 [G]).")
(defparameter *br-s-block* 0.5 "A blocked recovery shot's share of its gains (new 2026-10-10 [G]).")

;; SP1 / SP2 by the special count (decision R1: 「依據特殊資源數量不同，SP1 與 SP2 會有相對應的變化」; read, never spent)
(defparameter *br-sp-tiers* '(4 8)
  "The awakened forms' SP tiers by the wings: 0-3 tier 0, 4-7 tier 1, 8 tier 2 (new 2026-10-10 [G]) ...")
(defparameter *br-sp-tiers-base* '(2 3) "... the base form's by the pips: 0-1, 2, 3 (new 2026-10-10 [G]).")
(defparameter *br-sp1-fs* '(18.0 35.0 70.0)
  "SP1 gives this much flash step back by its tier on its f0 (tier 2: a burst's worth; R1's SP1 「恢復閃步」 side of the loop,
V9j: 「約 2 格 SP 換 1 格閃步」; new 2026-10-10 [G]).")

;; the 4-wing armour (decision R1: 「攻擊時如果被攻擊可以消耗四片翼使自己不會被打斷（不足時不觸發效果）」)
(defparameter *br-armor-wings* 4 "Wings a hit during his own attack spends so it does not interrupt him, awakened (R1) ...")
(defparameter *br-owl-armor-wings* 2 "... the burst owl's (its buff, new 2026-10-10 [G]).")

;; the burst owl (decision R1: 「取消掉再覺醒，改成爆氣時會進入梟頭模式與獲得對應的 buff」; R2: 「buff 不分顏色」)
(defparameter *br-owl-mult* 1.2 "Damage dealt x, the burst owl (its buff; the old revival's 1.1 -> 1.2, new 2026-10-10 [G]).")
(defparameter *br-owl-taken* 1.1 "Damage taken x, the owl (JILLIEL's; copied 2026-10-09).")
(defparameter *br-owl-wing-every* 60 "The burst owl gains a wing every this many frames (its buff, new 2026-10-10 [G]).")
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
(defparameter *br-j-adv* 2 "... and its block advantage this many frames higher (decision V8).")
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
(defparameter *br-backstep* 5.0 "J3 -> L 後撤: metres back over *BR-BACKSTEP-F* into the stance (new 2026-10-09 [G]) ...")
(defparameter *br-backstep-f* 14 "... frames (new 2026-10-09 [G]) ...")
(defparameter *br-backstep-iframes* 9 "... invulnerable on its frames 0-8 (decision V6). Free since v3 (no trace to pay).")

;; the full volley (the recall's derivative strings, the owl's only since v3, decision R1 / R2)
(defparameter *br-recall-f* 8 "K3 -> L 回收: frames before its derivative string (new 2026-10-09 [G]).")
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
(defparameter *br-reflect-hoho* '(48 59) "Owl SP2 Trompete: reflected by a perfect Hoho started on these frames (copied 2026-10-09).")
(defparameter *br-reflect-guard* '(2 10) "... or a guard whose FIGHTER-GUARD-T at its f59 is in this range (copied 2026-10-09).")
(defparameter *br-reflect-k* 0.5 "The reflect: he takes this share of Trompete's damage x his form's (copied 2026-10-09) ...")
(defparameter *br-reflect-stun* 60 "... and staggers this many frames (copied 2026-10-09).")

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
  "The specials a stance L shot gives (decision R2: 「LL：回收特殊資源」): STEP 0 / 1 (L1 / L2) on CONTACT :hit or :block,
*BR-S-L-GAIN*'s; a whiff 0."
  (if (member contact '(:hit :block)) (nth step *br-s-l-gain*) 0))
(defun br-recover-gain (contact role spent)
  "The flash step and Reiatsu a recovery shot gives (decision R2: 「JJ：高額閃步/SP 量表恢復，可以再銜接 KK 消耗資源提高恢復量」): ROLE
:j a J J shot, :jk its K K follow-up (SPENT: a special was spent on it); CONTACT :hit in full, :block x *BR-S-BLOCK*, else
nothing. Values fs sp."
  (let ((k (case contact (:hit 1.0) (:block *br-s-block*) (t 0.0)))
        (extra (and (eq role :jk) spent)))
    (values (* k (+ *br-s-j-fs* (if extra *br-s-jk-fs* 0.0)))
            (* k (+ *br-s-j-sp* (if extra *br-s-jk-sp* 0.0))))))
(defun br-spend (n)
  "One special spent by a follow-up shot (decision R2: 「每下花 1 翼」): values what is left and whether one was (N >= 1); none
left, the plain shot."
  (if (>= n 1) (values (1- n) t) (values n nil)))
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
(defun br-l-route (cur-kind cur-ender owl)
  "The move an L pressed in an awakened KIN link starts (the kits' :l-after-k / :l-after-j name the router :BR-L-LINK): off
K3 (a :flash ender) in the OWL the full volley (decision R2: the owl's only), off J3 (a :quick ender) the backstep into
the stance, else the turn into the stance (v3: K3 -> L outside the owl is the stance too)."
  (cond ((and cur-ender (eq cur-kind :flash) owl) :br-recall)
        ((and cur-ender (eq cur-kind :quick)) :br-backstep)
        (t :br-to-en)))
(defun br-kamae-pick (cmd)
  "The base stance's move for its first press CMD (:kamae-l -j -k -sp1 -sp2 -step): the three strings' openers (decision R2),
the stance's SPs, its Step."
  (getf '(:kamae-l :br-s-l1 :kamae-j :br-s-j1 :kamae-k :br-s-k1 :kamae-sp1 :br-k-sanren :kamae-sp2 :br-k-sp2
          :kamae-step :br-k-dash)
        cmd))
(defun br-kamae-hold-over-p (sf held)
  "Does the stance (move frame SF, L HELD) end its hold now: past its tap with L up, before the held maximum?"
  (and (<= (+ *br-kamae-up* *br-kamae-tap*) sf) (< sf (+ *br-kamae-up* *br-kamae-max*)) (not held)))
(defun br-kamae-step-ok-p (dashed fs)
  "May the stance's Step (飛廉脚) start: not yet used in this stance (DASHED) and FS >= *BR-KAMAE-DASH-FS* (decision V6)?"
  (and (not dashed) (>= fs *br-kamae-dash-fs*)))
(defun br-dash-snap-p (sf) "May a J in the stance Step at its frame SF start the stance's J J: from *BR-DASH-SNAP-F*?" (>= sf *br-dash-snap-f*))
(defun br-sp2-sealed-p (command form sealed)
  "Is COMMAND refused in FORM because Trompete was reflected (SEALED): the owl's SP2 (the old rule)."
  (and (eq command :sp2) (br-owl-form-p form) sealed t))
(defun br-reflect-hoho-p (start) "A perfect Hoho started on Trompete frame START reflects it (*BR-REFLECT-HOHO*)?"
  (<= (first *br-reflect-hoho*) start (second *br-reflect-hoho*)))
(defun br-reflect-guard-p (guard-t) "A guard at FIGHTER-GUARD-T = GUARD-T on Trompete's f59 reflects it (*BR-REFLECT-GUARD*)?"
  (<= (first *br-reflect-guard*) guard-t (second *br-reflect-guard*)))
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
*BR-J-ADV*) or :K (startup and recovery + *BR-K-SLOW*, damage x *BR-K-MULT*, block advantage + *BR-K-ADV*; a K link's
:enter + (*BR-K-SLOW* - *BR-K-LINK-SLOW*)); its hit-frame hooks follow the new startup; :clip-s the old startup. A new plist."
  (let* ((j (eq route :j)) (s0 (getf spec :startup)) (r0 (getf spec :recovery))
         (s1 (if j (max *br-j-min-s* (- s0 *br-j-speed*)) (+ s0 *br-k-slow*)))
         (r1 (if j (max *br-j-min-r* (- r0 *br-j-speed*)) (+ r0 *br-k-slow*)))
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

;; the stance's three strings in one form (decision R2): L L (L1, L2), K K (K1, K2) -> J J (KJ1, KJ2), J J (J1, J2) -> K K
;; (JK1, JK2). Every shot a 萬物貫通 line at him (hitscan, 31 m); a button always plays the same clips (the follow-up looks
;; like the other string's opener). CLIPS: (clip startup active recovery) for L1 L2 J1 J2 K1 K2; ADV the owl's +1
(defmacro br-defstance (prefix l1 l2 j1 j2 k1 k2 &optional (adv 0))
  (flet ((nm (s) (intern (format nil "~a-~a" prefix s) :keyword)))
    (flet ((shot (name kind spec role dmg react &key spend gain)
             (destructuring-bind (clip s a r) spec
               `(defmove ,name :kind ,kind :clip ,clip :startup ,s :active ,a :recovery ,(max 4 (- r adv)) :dmg ,dmg
                  :adv-block ,(max (+ -12 adv) (- 1 (+ a (max 4 (- r adv))))) :track 720.0   ; (>= 1 f of blockstun)
                  :vol (:cap 0.6 *br-x-len* 1.2 0.25) :on-hit ,react :kb 0.3
                  :chip *br-x-chip* :guard *br-x-guard* :flags (:ranged :x-axis :uncatchable) :tick br-s-tick
                  :on-frame (,@(when spend '((0 br-s-spend))) (,s br-shot-fire))
                  :params (:stance ,role :len *br-x-len* ,@(when gain (list :gain gain)))))))
      `(progn
         ,(shot (nm "L1") :sig l1 :l '*br-s-l-dmg* :flinch :gain 0)
         ,(shot (nm "L2") :sig l2 :l '*br-s-l-dmg* :flinch :gain 1)
         ,(shot (nm "J1") :quick j1 :j '*br-s-j-dmg* :flinch)
         ,(shot (nm "J2") :quick j2 :j '*br-s-j-dmg* :stagger)
         ,(shot (nm "K1") :flash k1 :k '*br-s-k-dmg* :stagger)
         ,(shot (nm "K2") :flash k2 :k '*br-s-k-dmg* :stagger)
         ,(shot (nm "KJ1") :quick j1 :kj '*br-s-kj-dmg* :flinch :spend t)
         ,(shot (nm "KJ2") :quick j2 :kj '*br-s-kj-dmg* :knockback :spend t)
         ,(shot (nm "JK1") :flash k1 :jk '*br-s-jk-dmg* :stagger :spend t)
         ,(shot (nm "JK2") :flash k2 :jk '*br-s-jk-dmg* :knockback :spend t)))))
(defun br-stance-strings (prefix)
  "The kit strings of PREFIX's stance (BR-DEFSTANCE): J J -> K K, K K -> J J by the J / K latch; L L by BR-S-TICK's latch
(command :lchain)."
  (flet ((nm (s) (intern (format nil "~a-~a" prefix s) :keyword)))
    `((,(nm "J1") :q ,(nm "J2")) (,(nm "J2") :f ,(nm "JK1")) (,(nm "JK1") :f ,(nm "JK2"))
      (,(nm "K1") :f ,(nm "K2")) (,(nm "K2") :q ,(nm "KJ1")) (,(nm "KJ1") :q ,(nm "KJ2"))
      (,(nm "L1") :lchain ,(nm "L2")))))

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
;; the stance's strings (decision R2), Diagramm's shots: L the shoulder shot and the hip snap, J the snap and HOSHA's leap
;; (Lille's spare :lb-k-hosha), K the locked shot and TAISHA's back-slide
(br-defstance "BR-S" (:lb-fire 6 2 18) (:lb-snap 6 2 18) (:lb-snap 6 2 16) (:lb-k-hosha 6 2 18)
              (:lb-k-shot 10 2 20) (:lb-k-taisha 16 2 24))
;; the stance's SPs: SANREN's three 萬物貫通 lines, HIRENKYAKU's slide and shot; outside the stance the plain ones (20 m, no
;; 萬物貫通). SP1 gives flash step back by the pips (BR-SP1-FS-GO); SP2's charge by the pips (the router BR-SP2-GO)
(defmove :br-k-sanren :kind :sp :clip :lb-sanren :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg *br-k-sanren-dmg*
  :adv-block -14 :track 90 :vol (:cap 0.6 *br-x-len* 1.2 0.25) :on-hit :flinch :kb 0.5 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len *br-x-len*))
(defmove :br-k-hiren :kind :sp :clip :lb-hiren :callout "HIRENKYAKU" :startup 20 :active 2 :recovery 22 :dmg *br-k-hiren-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.25) :on-hit :stagger :kb 1.0 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :tick br-slide-tick :on-frame ((0 br-slide) (20 br-shot-fire))
  :params (:slide 6.0 :slide-f 14 :lock 14 :len *br-x-len*))
(defmove-copy :br-k-hiren-1 :br-k-hiren :enter 10 :on-frame ((10 br-slide) (20 br-shot-fire)))
(defmove-copy :br-k-hiren-2 :br-k-hiren :enter 18 :on-frame ((20 br-shot-fire))
  :flags (:ranged :x-axis :uncatchable :guard-crush))
(defmove :br-sanren :kind :sp :clip :lb-sanren :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg *br-sanren-dmg*
  :adv-block -14 :track 90 :vol (:cap 0.6 *br-plain-len* 1.2 0.25) :on-hit :flinch :kb 0.5 :flags (:ranged)
  :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len *br-plain-len*))
(defmove :br-hiren :kind :sp :clip :lb-hiren :callout "HIRENKYAKU" :startup 20 :active 2 :recovery 22 :dmg *br-hiren-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-plain-len* 1.2 0.25) :on-hit :stagger :kb 1.0 :flags (:ranged)
  :tick br-slide-tick :on-frame ((0 br-slide) (20 br-shot-fire)) :params (:slide 6.0 :slide-f 14 :lock 14 :len *br-plain-len*))
(defmove-copy :br-hiren-1 :br-hiren :enter 10 :on-frame ((10 br-slide) (20 br-shot-fire)))
(defmove-copy :br-hiren-2 :br-hiren :enter 18 :on-frame ((20 br-shot-fire)) :flags (:ranged :guard-crush))
;; SP2's routers (a command's move that lives no frame: its f0 starts the tier's SP2, BR-SP2-GO; the bars were paid by the
;; command)
(defmove :br-sp2 :kind :sig :clip :lb-stance :startup 1 :active 0 :recovery 0 :on-frame ((0 br-sp2-go))
  :params (:tiers (:br-hiren :br-hiren-1 :br-hiren-2)))
(defmove :br-k-sp2 :kind :sig :clip :lb-kamae :startup 1 :active 0 :recovery 0 :on-frame ((0 br-sp2-go))
  :params (:tiers (:br-k-hiren :br-k-hiren-1 :br-k-hiren-2)))
(defmove :br-breaker :kind :breaker :clip :lb-breaker :clip-2 :lb-butt :callout "SHOBI-UCHI")
(defmove :br-kikon :kind :kikon :clip :lb-aim :clip-2 :lb-fire :clip-s 4 :callout "BANBUTSU KANTSU" :cine lb-kikon-cine
  :startup 20 :active 3 :recovery 30 :whiff 30 :dmg 70 :adv-block -14 :track 0 :vol (:cap 0.5 12.0 1.2 1.2)
  :on-hit :knockback :kb 2.0 :cooldown 90 :on-frame ((20 br-lane-shot))
  :params (:aura 8 :aim 120.0 :speed 0.0 :dash-max 0 :dash-track 0.0 :look :lane :follow-speed 14.0 :len 12.0))

;;; ================================================================ JILLIEL
;; KIN, the attack state: the wing blades (plain strings: no resource in or out, decision R1 「避免同質化」)
(br-defstring :j :br-w-j1 :kind :quick :clip :lb-w-q1 :startup 8 :active 3 :recovery 12 :dmg 24 :adv-block -2
  :reach 1.6 :arc 110 :on-hit :flinch)
(br-defstring :j :br-w-j2 :kind :quick :clip :lb-w-q2 :startup 7 :active 3 :recovery 13 :dmg 24 :adv-block -2
  :reach 1.6 :arc 110 :on-hit :flinch)
(br-defstring :j :br-w-j3 :kind :quick :clip :lb-w-q3 :startup 9 :active 3 :recovery 18 :dmg 30 :adv-block -4
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
;; 40 f tell, a 1.2 m beam, 180; the wings shorten the charge: 20 f at 4, none and a guard break on block at 8)
(defmove :br-w-sanren :kind :sp :clip :lb-w-sanren :clip-s 12 :callout "SANREN" :startup 12 :active 22 :recovery 24 :dmg 30
  :adv-block -14 :track 90 :vol (:cap 0.6 20.0 1.2 0.25) :on-hit :flinch :kb 0.5 :chip 0.15 :guard 12
  :flags (:ranged :x-axis :uncatchable) :hits ((12 14) (22 24) (32 34)) :tick br-sanren-tick
  :on-frame ((0 br-sp1-fs-go) (12 br-line-shot) (22 br-line-shot) (32 br-line-shot)) :params (:len 20.0))
(defmove :br-w-nijushi :kind :sp :clip :lb-w-nijushi :callout "NIJUSHI-KO" :startup 40 :active 6 :recovery 30 :dmg 180
  :adv-block -14 :track 0 :vol (:cap 0.6 31.0 1.2 1.2) :on-hit :knockback :kb 2.0 :chip 0.15 :guard 45
  :flags (:ranged :x-axis :uncatchable) :tick br-planted-tick :on-frame ((0 br-nijushi-tell) (40 br-beam-shot))
  :params (:lock 20 :track 60.0 :width 1.2))
(defmove-copy :br-w-nijushi-1 :br-w-nijushi :enter 20 :on-frame ((20 br-nijushi-tell) (40 br-beam-shot)))
(defmove-copy :br-w-nijushi-2 :br-w-nijushi :enter 38 :on-frame ((38 br-nijushi-tell) (40 br-beam-shot))
  :flags (:ranged :x-axis :uncatchable :guard-crush))
(defmove :br-w-sp2 :kind :sig :clip :lb-w-stance :startup 1 :active 0 :recovery 0 :on-frame ((0 br-sp2-go))
  :params (:tiers (:br-w-nijushi :br-w-nijushi-1 :br-w-nijushi-2)))
;; L into the stance (12 f, EN at f11); J3 -> L 後撤 the backstep (5 m / 14 f, iframes f0-8, EN at its f0); K3 -> L in the
;; owl the full volley (its derivative strings by the wings spent: :strings :rc0 .. :rc4)
(defmove :br-to-en :kind :sig :clip :br-to-en :callout "EN" :startup *br-to-en-f* :active 0 :recovery 0 :tick br-halt-tick
  :on-frame ((0 br-stance-arm) (11 br-go-ranged)))
;; L latched in a KIN J / K link (the kits' :l-after-k / :l-after-j): a router that lives no frame: its f0 starts the move
;; BARRO-OK routed off the link it was pressed in (BR-L-ROUTE)
(defmove :br-l-link :kind :sig :clip :lb-w-stance :startup 1 :active 0 :recovery 0 :on-frame ((0 br-l-link-go)))
(defmove :br-backstep :kind :sig :clip :lb-w-tenshin :callout "KOTAI" :startup *br-backstep-f* :active 0 :recovery 8
  :tick br-halt-tick :on-frame ((0 br-backstep-go)))
(defmove :br-recall :kind :sig :clip :br-recall :callout "KAISHU" :startup *br-recall-f* :active 0 :recovery 0
  :tick br-halt-tick :on-frame ((0 br-recall-go) (7 br-recall-fire)))
;; the full volley's strings: every line 萬物貫通 from him at the opponent (BR-RC-TICK keeps him on him)
(defmove :br-rc0 :kind :sig :clip :br-rc0 :callout "KAISHU" :startup 6 :active 2 :recovery 24 :dmg *br-rc0-dmg* :adv-block -14
  :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 1.0 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :tick br-rc-tick :on-frame ((6 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc1 :kind :sig :clip :br-rc1 :callout "NIREN" :startup 6 :active 12 :recovery 24 :dmg *br-rc1-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.5 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable) :hits ((6 8 :stun *br-rc-stun*) (16 18)) :tick br-rc-tick
  :on-frame ((6 br-rc-shot) (16 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc2 :kind :sig :clip :br-rc2 :callout "YONREN" :startup 6 :active 28 :recovery 24 :dmg *br-rc2-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.3 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable)
  :hits ((6 8 :stun *br-rc-stun*) (14 16 :stun *br-rc-stun*) (22 24 :stun *br-rc-stun*) (32 34 :dmg *br-rc2-last* :on-hit :launch))
  :tick br-rc-tick :on-frame ((6 br-rc-shot) (14 br-rc-shot) (22 br-rc-shot) (32 br-rc-shot)) :params (:lock 0 :len *br-x-len*))
(defmove :br-rc3 :kind :sig :clip :br-rc3 :callout "SABAKI" :startup 6 :active 32 :recovery 26 :dmg *br-rc3-dmg*
  :adv-block -14 :track 0 :vol (:cap 0.6 *br-x-len* 1.2 0.3) :on-hit :stagger :kb 0.3 :chip *br-x-chip* :guard *br-x-guard*
  :flags (:ranged :x-axis :uncatchable)
  :hits ((6 8 :stun *br-rc-stun*) (12 14 :stun *br-rc-stun*) (18 20 :stun *br-rc-stun*) (24 26 :stun *br-rc-stun*)
         (36 38 :dmg *br-rc3-last* :on-hit :knockback :kb 2.0))
  :tick br-rc-tick :on-frame ((6 br-rc-shot) (12 br-rc-shot) (18 br-rc-shot) (24 br-rc-shot) (36 br-beam-shot))
  :params (:lock 0 :len *br-x-len* :width 1.2))
(defmove :br-rc4 :kind :sig :clip *br-rc4-clip* :callout "SABAKI KIWAMI" :startup 6 :active 44 :recovery 30 :dmg *br-rc4-dmg*
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
;; EN, the stance (decision R2): the casts. L the V8 swing (spare since V8b) and the old EN J3, J the old EN J1 / J2, K the
;; old EN K1 / K2 (their own frames)
(br-defstance "BR-E" (:br-e-swing 7 3 6) (:lb-e-q3 5 3 9) (:lb-e-q1 4 3 6) (:lb-e-q2 4 3 6)
              (:lb-e-f1 9 4 10) (:lb-e-f2 10 4 12))

;;; ================================================================ the owl: the burst's form (decision R1)
(br-defstring :j :br-o-j1 :kind :quick :clip :lb-o-q1 :startup 8 :active 3 :recovery 11 :dmg 26 :adv-block -1
  :reach 1.7 :arc 110 :on-hit :flinch)
(br-defstring :j :br-o-j2 :kind :quick :clip :lb-o-q2 :startup 7 :active 3 :recovery 12 :dmg 26 :adv-block -1
  :reach 1.7 :arc 110 :on-hit :flinch)
(br-defstring :j :br-o-j3 :kind :quick :clip :lb-o-q3 :startup 9 :active 3 :recovery 17 :dmg 32 :adv-block -3
  :reach 1.7 :arc 120 :on-hit :stagger :flags (:ender))
(br-defstring :k :br-o-k1 :kind :flash :clip :lb-o-f1 :startup 17 :active 4 :recovery 20 :dmg 54 :adv-block -2
  :reach 2.3 :arc 150 :on-hit :stagger)
(br-defstring :k :br-o-k2 :kind :flash :clip :lb-o-f2 :enter 6 :startup 20 :active 4 :recovery 23 :dmg 54 :adv-block -2
  :reach 2.3 :arc 110 :on-hit :stagger)
(br-defstring :k :br-o-k3 :kind :flash :clip :lb-o-f3 :enter 7 :startup 21 :active 5 :recovery 33 :dmg 78 :adv-block -19
  :reach 2.3 :arc 90 :on-hit :crumple :flags (:ender))
(defmove-copy :br-o-j2s :br-o-j2)
(defmove-copy :br-o-k2s :br-o-k2)
;; SP1 裁きの光明 (the old MISUJI: three ground lines at -20 / 0 / +20 deg, one hit group, 70 each, 18 m; flash step back by
;; the wings)
(defmove :br-misuji :kind :sp :clip :lb-o-chop :clip-s 16 :callout "SABAKI NO KOMYO" :startup 18 :active 0 :recovery 25
  :reach 18.0 :track 90 :on-frame ((0 br-sp1-fs-go) (18 br-misuji)) :params (:dmg 70 :guard 18 :fan (-20.0 0.0 20.0)))
;; SP2 神の喇叭 TROMPETE (60 f wind-up, a 2.4 m beam 30 f, 240; reflected by a perfect Hoho f48-f59 or a guard f50-f58: he
;; takes half, staggers, SP2 sealed for the match); the wings shorten the charge (tier 2: no wind-up to read, not
;; reflectable, a guard break on block); after the volley the charge-less copy (decision V9l)
(defmove :br-trompete :kind :sp :clip :lb-o-trompete :callout "TROMPETE" :startup 60 :active 30 :recovery 39 :dmg 240
  :adv-block -13 :track 0 :vol (:cap 0.6 31.0 1.4 1.2) :on-hit :knockback :kb 3.0 :chip 0.15 :guard 60
  :flags (:ranged :x-axis :uncatchable :reflectable) :tick br-planted-tick :on-frame ((0 br-trompete-tell) (60 br-beam-shot))
  :params (:lock 40 :blast 60 :track 30.0 :width 1.2))
(defmove-copy :br-trompete-1 :br-trompete :enter 30 :on-frame ((30 br-trompete-tell) (60 br-beam-shot)))
(defmove-copy :br-trompete-2 :br-trompete :enter 58 :on-frame ((58 br-trompete-tell) (60 br-beam-shot))
  :flags (:ranged :x-axis :uncatchable :guard-crush))
(defmove-copy :br-trompete-c :br-trompete :enter 58 :flags (:ranged :x-axis :uncatchable))   ; (after the volley: V9l)
(defmove :br-o-sp2 :kind :sig :clip :lb-o-stance :startup 1 :active 0 :recovery 0 :on-frame ((0 br-sp2-go))
  :params (:tiers (:br-trompete :br-trompete-1 :br-trompete-2)))
(defmove :br-o-breaker :kind :breaker :clip :lb-o-breaker :clip-2 :lb-o-stamp :callout "KAGIZUME")
(defmove :br-o-kikon :kind :kikon :clip :lb-o-trompete :clip-2 :lb-o-chop :clip-s 4 :callout "TROMPETE"
  :cine lb-trompete-cine :startup 20 :active 3 :recovery 30 :whiff 30 :dmg 80 :adv-block -14 :track 0
  :vol (:cap 0.5 12.0 1.4 1.4) :on-hit :knockback :kb 2.0 :cooldown 90 :on-frame ((20 br-lane-shot))
  :params (:aura 10 :aim 120.0 :speed 0.0 :dash-max 0 :dash-track 0.0 :look :lane :follow-speed 14.0 :len 12.0))
;; the owl's stance EN: its casts (R one less: *BR-OWL-ADV*)
(br-defstance "BR-OE" (:br-oe-swing 7 3 5) (:lb-oe-q3 5 3 8) (:lb-oe-q1 4 3 5) (:lb-oe-q2 4 3 5)
              (:lb-oe-f1 9 4 9) (:lb-oe-f2 10 4 11) 1)

;;; His own moves' clips (barro-art.lisp): the owl's twins through its kits' :clip-map
(defparameter *br-owl-clip-map* '(:br-recall :br-o-recall :br-rc0 :br-o-rc0 :br-rc1 :br-o-rc1 :br-rc2 :br-o-rc2
                                  :br-rc3 :br-o-rc3 :br-rc4 :br-o-rc4 :br-to-en :br-o-to-en :lb-w-tenshin :br-o-backstep)
  "The owl kits' :clip-map: the shared moves (the volley, its strings, the turn, the backstep) on the claws' own clips.")

;;; ================================================================ forms
(defparameter *barro-hooks* '(:tick barro-tick :ok barro-ok :hit barro-hit :struck barro-struck :armor barro-armor
                               :draw br-draw)
  "His mechanics (kit.lisp KIT-HOOK): the burst owl, the owl's wings, the stance's end, Trompete's reflect (:tick); the stance
links, the seal (:ok); the specials and the recovery shots' gains (:hit); the wing armour's price (:struck) and its test
(:armor, fighter.lisp DEFENDER-STATE); his looks (:draw, barro-art.lisp).")

(defparameter *br-kamae-strings*
  (append (loop for s in '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
                append (loop for c in '(:kamae-l :kamae-j :kamae-k :kamae-sp1 :kamae-sp2 :kamae-step)
                             collect (list s c (br-kamae-pick c))))
          '((:br-k-dash :kamae-back :br-kamae-re) (:br-k-dash :kamae-j :br-s-j1))
          (br-stance-strings "BR-S"))
  "The base stance's picks: non-button strings (KIT-NEXT) its :tick starts (BR-KAMAE-TICK); the Step, its way back into the
stance and its J (the stance's J J); the stance's three strings (BR-DEFSTANCE).")
(defparameter *br-melee-strings*
  (append '((:br-recall :rc0 :br-rc0) (:br-recall :rc1 :br-rc1) (:br-recall :rc2 :br-rc2) (:br-recall :rc3 :br-rc3)
            (:br-recall :rc4 :br-rc4)
            (:br-l-link :br-recall :br-recall) (:br-l-link :br-backstep :br-backstep) (:br-l-link :br-to-en :br-to-en)
            (:br-recall :rc-sp2 :br-trompete-c))   ; (the charge-less SP2 after the volley: V9l)
          (br-stance-strings "BR-E") (br-stance-strings "BR-OE"))
  "The awakened forms' non-button strings: the volley's, the L router's three targets, the stances' strings (every awakened
form inherits these).")

(defkit :barro :base
  :name "LILLE II" :body :lille :weapon :diagramm :stance :lb-stance :calm t
  :intro :lb-intro :win :lb-win :intro-callout "THE X-AXIS"
  :walk *br-walk* :run *br-run* :reishi *reishi-max* :swing-sfx :whoosh-light :mult *br-mult* :taken *br-taken*
  :commands (:q :br-j1 :f :br-k1 :sig :br-kamae :sp1 :br-sanren :sp2 :br-sp2 :breaker :br-breaker :kikon :br-kikon)
  :grid (:br-j1 :br-j2 :br-j3 :br-k1 :br-k2 :br-k3 :br-j2s :br-k2s)
  :strings *br-kamae-strings*
  :l-after-k :br-kamae-k                        ; L after K1 / K2 / K3: the stance at f4 (the old rule)
  :l-after-j :br-kamae-j                        ; L after J1 / J2 / J3: the same (decision V9c)
  :awaken-form :jilliel-kin :kikon-konpaku 2 :hooks *barro-hooks*
  :ai (:intents (:approach 1 :pressure 1 :zone 5 :defend 2)
       :ranges (:approach (2.2 8.0) :pressure (1.3 2.2) :zone (8.0 20.0) :defend (5.0 9.0))
       :moves ((0.0 2.2 :q 4 :f 2 :breaker 1 :step 2 :sig 1)
               (2.2 6.0 :sp2 1 :step 2 :sp1 1 :sig 3 nil 1)
               (6.0 99.0 :sig 6 :sp1 1 nil 1))
       :guard 0.5 :hoho 0.3 :dash 0.3 :dash-back 0.7 :block-string 0.3 :o-ender 0.3 :l-after-k 0.6 :l-after-j 0.3 :kikon-range 7.7
       :awaken (:min-taken 150) :reflex br-ai-reflex
       :zone (:p 0.5 :near 6.0)                                    ; (the stance from range, one roll a window)
       :stance (:gather 0.8 :recover-fs 40.0 :recover-bars 1 :step 0.4 :step-in 3.0 :sp 0.2)))

;; JILLIEL KIN (the awakening enters it): the wing strings, SP1 / SP2 by the wings, L into the stance (J3 -> L the
;; backstep), U a guard (decision R1), a burst the owl (BARRO-TICK)
(defkit :barro :jilliel-kin :inherit :base
  :lift *br-jilliel-lift* :awakening t :form-name "JILLIEL KIN" :walk *br-walk-kin* :run *br-run-kin*
  :mult *br-jilliel-mult* :taken *br-jilliel-taken* :kikon-konpaku 3 :endless-form :jilliel-kin
  :body :lille-jilliel-kin :weapon nil :stance :lb-w-stance :cine lb-jilliel-cine :swing-sfx :whoosh-heavy
  :commands (:q :br-w-j1 :f :br-w-k1 :sig :br-to-en :sp1 :br-w-sanren :sp2 :br-w-sp2 :breaker :br-w-breaker
             :kikon :br-w-kikon)
  :grid (:br-w-j1 :br-w-j2 :br-w-j3 :br-w-k1 :br-w-k2 :br-w-k3 :br-w-j2s :br-w-k2s)
  :strings *br-melee-strings*
  :l-after-k :br-l-link :l-after-j :br-l-link
  :ai (:intents (:approach 3 :pressure 4 :zone 0 :defend 1)
       :ranges (:approach (2.4 6.0) :pressure (1.4 2.4) :zone (3.0 6.0) :defend (3.0 6.0))
       :moves ((0.0 2.4 :q 4 :f 4 :breaker 1)
               (2.4 8.0 :sig 2 :step 1 :sp1 1 nil 1)
               (8.0 99.0 :sig 4 :step 1 nil 1))
       :guard 0.4 :hoho 0.3 :dash 0.8 :block-string 0.3 :o-ender 0.3 :kikon-range 8.5
       :string-k 0.6 :l-after-k 0.4 :l-after-j 0.3 :backstep (:p 0.5)
       :burst (:p 0.5 :wings 5 :in 6.0) :sp-ender br-ai-sp-ender :reflex br-ai-reflex))

;; JILLIEL EN, the stance (afloat): L / J / K start the stance's strings, each ending back in KIN (BARRO-TICK)
(defkit :barro :jilliel :inherit :jilliel-kin
  :form-name "JILLIEL" :walk *br-walk-en* :run *br-run-en* :body :lille-jilliel
  :commands (:q :br-e-j1 :f :br-e-k1 :sig :br-e-l1)
  :ai (:intents (:approach 1 :pressure 0 :zone 5 :defend 2)
       :ranges (:approach (6.0 12.0) :pressure (6.0 9.0) :zone (4.0 14.0) :defend (8.0 12.0))
       :moves ((0.0 3.0 :q 2 :f 2 :step 1)
               (3.0 99.0 :sig 2 :f 2 :q 2 :sp1 1 :sp2 1 nil 1))
       :guard 0.4 :hoho 0.3 :dash 0.4 :dash-back 0.6 :kikon-range 8.5
       :burst (:p 0.5 :wings 5 :in 6.0) :reflex br-ai-reflex))

;; the owl (a burst in either JILLIEL form, decision R1; back when it ends): the claws, SP1 裁きの光明, SP2 Trompete (reflect
;; and seal), K3 -> L the full volley; x1.2 dealt (its buff), a wing a second, the armour 2 wings; Kikon 4
(defkit :barro :shin-kin :inherit :jilliel-kin
  :lift 0.0 :form-name "SHIN KIN" :mult *br-owl-mult* :taken *br-owl-taken* :kikon-konpaku 4
  :body :lille-shin :stance :lb-o-stance :cine nil :clip-map *br-owl-clip-map*
  :commands (:q :br-o-j1 :f :br-o-k1 :sig :br-to-en :sp1 :br-misuji :sp2 :br-o-sp2 :breaker :br-o-breaker :kikon :br-o-kikon)
  :grid (:br-o-j1 :br-o-j2 :br-o-j3 :br-o-k1 :br-o-k2 :br-o-k3 :br-o-j2s :br-o-k2s)
  :ai (:intents (:approach 4 :pressure 4 :zone 0 :defend 0)
       :ranges (:approach (2.6 8.0) :pressure (1.4 2.6) :zone (3.0 6.0) :defend (3.0 6.0))
       :moves ((0.0 2.6 :q 3 :f 5 :breaker 1)
               (2.6 8.0 :step 1 :sp1 1 nil 1)
               (8.0 99.0 :sp2 2 :sig 1 :step 1 nil 1))
       :guard 0.3 :hoho 0.3 :dash 0.9 :block-string 0.3 :o-ender 0.2 :kikon-range 9.0
       :string-k 0.8 :l-after-k 0.0 :l-after-j 0.2 :volley (:p 0.9 :n 1) :backstep (:p 0.3)
       :sp-ender br-ai-sp-ender :reflex br-ai-reflex))

(defkit :barro :shin :inherit :shin-kin
  :lift *br-owl-lift* :form-name "SHIN" :walk *br-walk-en* :run *br-run-en* :stance :lb-oe-stance
  :commands (:q :br-oe-j1 :f :br-oe-k1 :sig :br-oe-l1)
  :ai (:intents (:approach 1 :pressure 0 :zone 5 :defend 2)
       :ranges (:approach (6.0 12.0) :pressure (6.0 9.0) :zone (4.0 14.0) :defend (8.0 12.0))
       :moves ((0.0 3.0 :q 2 :f 2 :step 1)
               (3.0 99.0 :sig 1 :f 3 :q 1 :sp1 1 :sp2 1 nil 1))
       :guard 0.4 :hoho 0.3 :dash 0.4 :dash-back 0.6 :kikon-range 9.0 :reflex br-ai-reflex))

(defparameter *br-forms* '(:base :jilliel-kin :jilliel :shin-kin :shin) "Every form of his (the HUD meter, the host tests).")

;; his names in the brush tables (brush.lisp): the intro's column and the technique columns (not on the host)
(when (boundp '*brush-names*)
  (setf *brush-names* (append (remove :barro *brush-names* :key #'first) '((:barro "リジェ・バロ" "LILLE II")))
        *brush-callouts*
        (append (remove-if (lambda (c) (eql 0 (search "BR-" (symbol-name (first c))))) *brush-callouts*)
                '((:br-k-sanren "三連" "SANREN" nil) (:br-k-hiren "飛廉脚" "HIRENKYAKU" nil) (:br-k-hiren-1 "飛廉脚" "HIRENKYAKU" nil)
                  (:br-k-hiren-2 "飛廉脚" "HIRENKYAKU" nil) (:br-sanren "三連" "SANREN" nil) (:br-hiren "飛廉脚" "HIRENKYAKU" nil)
                  (:br-hiren-1 "飛廉脚" "HIRENKYAKU" nil) (:br-hiren-2 "飛廉脚" "HIRENKYAKU" nil)
                  (:br-w-sanren "三連" "SANREN" nil) (:br-w-nijushi "二十四孔" "NIJUSHI-KO" nil)
                  (:br-w-nijushi-1 "二十四孔" "NIJUSHI-KO" nil) (:br-w-nijushi-2 "二十四孔" "NIJUSHI-KO" nil)
                  (:br-misuji "裁きの光明" "SABAKI NO KOMYO" nil) (:br-trompete "神の喇叭" "TROMPETE" nil)
                  (:br-trompete-1 "神の喇叭" "TROMPETE" nil) (:br-trompete-2 "神の喇叭" "TROMPETE" nil)
                  (:br-trompete-c "神の喇叭" "TROMPETE" nil)
                  (:br-to-en "遠" "EN" nil) (:br-backstep "後退" "KOTAI" nil)
                  (:br-recall "回収" "KAISHU" nil) (:br-rc0 "回収" "KAISHU" nil) (:br-rc1 "二連" "NIREN" nil)
                  (:br-rc2 "四連" "YONREN" nil) (:br-rc3 "裁き" "SABAKI" nil) (:br-rc4 "裁き" "SABAKI KIWAMI" nil)
                  (:br-k-dash "飛廉脚" "HIRENKYAKU" nil)))))

;;; ================================================================ his state (the sim's): a component on his fighter entity
(defcomponent brs
  "Lille II's state: on his fighter entity, made on its first use, so a new match's fighter starts fresh."
  (ammo 0 :type fixnum)                   ; the special resource: the base's 狙擊 pips 0-3, awakened the wings 0-8
  (spent nil)                             ; the running follow-up shot spent one (BR-S-SPEND)
  (gained nil)                            ; the running stance shot paid its gains (once a move)
  (k-plan nil)                            ; his CPU's base stance pick (once a stance)
  (l-to :br-to-en)                        ; the KIN L router's target (BARRO-OK, BR-L-ROUTE), started at its f0
  (l-next nil)                            ; a stance L1: an L latched for L2
  (dash-dir 0f0 :type single-float)       ; his CPU's stance Step: the strafe (0 straight back)
  (dashed nil)                            ; the base stance's Step used (once per stance)
  (in-string nil)                         ; a stance string runs in the awakened stance (its end: back to KIN)
  (slow nil)                              ; the stance's first hit may slow the match (armed at its entry)
  (owl-t 0 :type fixnum)                  ; frames in the owl (its wing a second)
  (recall-n 0 :type fixnum)               ; the volley's count (its f0) for its string (its f7)
  (rc-sp2 nil)                            ; the volley's string: SP2 latched for its recovery (V9k)
  (sealed nil)                            ; the owl's Trompete was reflected: SP2 sealed for the match
  (armored 0 :type fixnum)                ; hits his wing armour took (the pacing log)
  (ai-t -999 :type fixnum)                ; his CPU's last stance / burst window (one roll a window)
  (awake-t -1 :type fixnum) (owl-at -1 :type fixnum))   ; ticks of the awakening and the first burst owl (the pacing log)
(defvar *br-test-awake* nil
  "Debug 82041 (82040 off): the ASSIST gate's masher as him (P1, habit :dumb) plays every match from JILLIEL KIN (forced at
its first free step: the masher never awakens itself).")
(defvar *br-test-diff* nil
  "Debug 82050 / 82051 / 82052 (82053 off): his CPU plays EASY / NORMAL / HARD whatever the gate's *DIFFICULTY*.")
(defvar *br-keep-owl* nil "Debug: a forced owl form stays without a burst (BARRO-TICK's switch skipped).")
(defvar *br-reflect-test* nil "Debug 82007 / 82008: P2 reflects P1's Trompete by a guard (:guard) / a perfect Hoho (:hoho).")
(defun br (e)
  "E's Lille II state (his BRS component, attached on the first call: a new fighter entity, a new match, gets a fresh one)."
  (or (brs e) (let ((st (make-brs))) (add-component e st) st)))

;;; ================================================================ hooks
(defun br-tick-brain (e)
  "The brain his ticks decide on: his own CPU's; NIL for a human (no brain, or one switched off) and for the ASSIST gate's
button-masher (habit :dumb, read as a human)."
  (let ((b (brain e))) (and b (not (brain-off b)) (not (eq (brain-habit b) :dumb)) b)))

(defun br-stance-move-p (mv) "Is MV one of the stances' string shots (BR-DEFSTANCE: :params :stance)?" (and mv (getf (mv-params mv) :stance) t))

(defun barro-ok (e command combo)
  "His kit's refusals: the owl's SP2 once sealed; an L link off a stance string (the stance is not re-entered from its own
strings: they end in the attack state, decision R2); the KIN L router routed off the link it was pressed in (BR-L-ROUTE,
kept in BRS-L-TO for its f0)."
  (let* ((f (fighter e)) (form (fighter-form f)) (cur (and (eq (fighter-state f) :move) (fighter-move f))))
    (cond ((br-sp2-sealed-p command form (brs-sealed (br e))) nil)
          ((and (eq command :sig) (typep combo 'move))
           (and cur (not (br-stance-move-p cur))
                (progn (when (eq (mv-name combo) :br-l-link)
                         (setf (brs-l-to (br e))
                               (br-l-route (mv-kind cur) (and (member :ender (mv-flags cur)) t) (br-owl-form-p form))))
                       t)))
          (t t))))

(defun barro-armor (e f mv)
  "His kit's :armor (fighter.lisp DEFENDER-STATE): the wing armour holds for this hit (BR-ARMOR-P: awakened, his own
attack, the wings for it)."
  (br-armor-p (fighter-form f) (mv-kind mv) (fighter-phase f) (brs-ammo (br e))))

(defun barro-tick (e f g)
  "Per step (his kit's :tick): the burst owl (BR-OWL-SWITCH: a burst in a JILLIEL form turns him into the owl, its end back;
the owl's wing every *BR-OWL-WING-EVERY* frames); the awakened stance's string end (back to KIN, decision R2); the
specials' cap; Trompete's reflect check on its f59; the pacing clocks."
  (when (or *br-test-awake* *br-test-diff*) (br-test-tick e f))
  (let* ((st (br e)) (form (fighter-form f)) (to (and (not *br-keep-owl*) (br-owl-switch form (gauges-burst g)))))
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
      (unless (and mv (member (mv-tick mv) '(br-rc-tick br-halt-tick))) (setf (brs-rc-sp2 st) nil))
      (when (and (br-awake-form-p form) (minusp (brs-awake-t st)))
        (setf (brs-awake-t st) *match-tick*) (pace e :awaken-tick *match-tick*))
      (when (and mv (eq (mv-name mv) :br-trompete) (eq (fighter-phase f) :main))
        (when *br-reflect-test* (br-reflect-test-step e f))
        (when (= (fighter-sf f) 59) (br-reflect-check e st mv))))))

(defun barro-hit (att def res hw mv hazard ranged)
  "After a hit he dealt (his kit's :hit): a stance shot's gains, once a move (decision R2): L the specials (BR-L-GAIN, a hit
or a block), J J / its K K follow-up flash step and Reiatsu (BR-RECOVER-GAIN); the stance's first hit and the volley's
last beam slow the match; the pacing log."
  (declare (ignore def ranged))
  (let ((st (br att)) (c (contact-of res)) (role (and mv (not hazard) (getf (mv-params mv) :stance))))
    (when (and role (member c '(:hit :block)) (not (brs-gained st)))
      (setf (brs-gained st) t)
      (case role
        (:l (let ((k (br-l-gain c (getf (mv-params mv) :gain 0))) (form (fighter-form (fighter att))))
              (when (plusp k) (setf (brs-ammo st) (br-ammo-add (brs-ammo st) k form)) (pace att :ammo-gain k))))
        ((:j :jk) (multiple-value-bind (fs sp) (br-recover-gain c role (brs-spent st))
                    (pay-gauges att sp fs)
                    (pace att (if (and (eq role :jk) (brs-spent st)) :recover-big :recover))))))
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

;;; ---------------------------------------------------------------- the stance's strings (decision R2)
(defun br-s-spend (e)
  "A follow-up shot's f0 (K K -> J J, J J -> K K): one special spent if there is one (BR-SPEND; 「每下花 1 翼」): J J's damage +
*BR-S-KJ-BONUS* (FIGHTER-DMG-BONUS), K K's gains raised on its hit (BRS-SPENT, BARRO-HIT)."
  (let* ((st (br e)) (f (fighter e)) (role (move-param e :stance)))
    (multiple-value-bind (left spent) (br-spend (brs-ammo st))
      (setf (brs-ammo st) left (brs-spent st) spent)
      (when (and spent (eq role :kj)) (setf (fighter-dmg-bonus f) *br-s-kj-bonus*))
      (pace e (if spent :spend :spend-none)))))

(defun br-s-tick (e)
  "A stance shot: no chase (BR-HALT-TICK's halt, its slide kept: none); its gains unpaid at its f0; L1: a human's L pressed
during it is latched and starts L2 from the end of its active frames (his CPU always goes on)."
  (let* ((f (fighter e)) (mv (fighter-move f)) (st (br e)))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :main))
      (let ((sf (fighter-sf f)))
        (when (= sf (mv-enter mv)) (setf (brs-gained st) nil))
        (let ((next (kit-next (fighter-kit f) (mv-name mv) :lchain)))
          (when (and next (zerop (fighter-lock f)))
            (let ((b (br-tick-brain e)) (vp (pilot-vpad (pilot e))))
              (if b
                  (setf (brs-l-next st) t)
                  (when (vpad-command-pressed-p vp :sig nil) (vpad-consume! vp :sig) (setf (brs-l-next st) t)))
              (when (and (brs-l-next st) (>= sf (+ (mv-s mv) (mv-a mv))))
                (setf (brs-l-next st) nil)
                (start-move e next)
                (pace e :l-chain)))))))))

(defun br-stance-arm (e) "The awakened stance's entry: its first hit armed (the slow motion)." (setf (brs-slow (br e)) t))

;;; ---------------------------------------------------------------- SP1 / SP2 by the special count (decision R1)
(defun br-sp1-fs-go (e)
  "SP1's f0: flash step back by its tier (BR-SP-TIER, BR-SP1-FS; read, not spent)."
  (let* ((f (fighter e)) (tier (br-sp-tier (brs-ammo (br e)) (fighter-form f))))
    (pay-gauges e 0.0 (br-sp1-fs tier))
    (pace e (svref #(:sp1-t0 :sp1-t1 :sp1-t2) tier))))

(defun br-sp2-go (e)
  "An SP2 router's f0: the SP2 of its tier (BR-SP-TIER: the charge shortened; the move's :tiers), facing him."
  (let* ((f (fighter e)) (tier (br-sp-tier (brs-ammo (br e)) (fighter-form f)))
         (name (nth tier (move-param e :tiers))))
    (turn-to-opp e f 10.0)
    (start-move e (kit-move (fighter-kit f) name))
    (pace e (svref #(:sp2-t0 :sp2-t1 :sp2-t2) tier))))

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
(defun br-trompete-tell (e) "Trompete f0: the rising pitch (the tell)." (setf (model-super (model e)) 1.0) (emit :sfx :lb-trumpet e))
(defun br-spawn-look (e kind len width lock)
  "A look-only hazard of his along his facing: a shot, a beam or a lane (Lille's LB-LOOK draws it; no hit)."
  (let ((p (pos-of e))) (br-spawn-look-at e kind (aref p 0) (aref p 2) (yaw-of e) len width lock)))
(defun br-spawn-look-at (e kind x z yaw len width lock)
  "BR-SPAWN-LOOK from (X Z) along YAW."
  (spawn-hazard :br-fx e :x x :z z :yaw yaw :size len :life (case kind ((:beam :judge) 30) (t 16))
                         :hook 'br-hz :data (make-lbh :kind kind :len (f32 len) :width (f32 width) :lock lock) :look 'lb-look))

;;; ---------------------------------------------------------------- the awakened stance, the routes, the volley
(defun br-go-ranged (e)
  "The turn's last frame / the backstep's first: the stance EN."
  (let* ((form (fighter-form (fighter e))) (to (br-ranged-of form)))
    (unless (eq to form) (set-form e to) (pace e :to-ranged))))
(defun br-l-link-go (e)
  "The KIN L router's f0: the move BARRO-OK routed it to (the owl's volley off K3, the backstep off J3, else the turn)."
  (let ((f (fighter e)))
    (start-move e (kit-next (fighter-kit f) :br-l-link (brs-l-to (br e))))
    (pace e (case (brs-l-to (br e)) (:br-recall :l-recall) (:br-backstep :l-backstep) (t :l-to-en)))))
(defun br-halt-tick (e) "The turn, the backstep, the volley: no string chase (the slide is their only movement)." (halt! e))
(defun br-backstep-go (e)
  "J3 -> L f0: *BR-BACKSTEP* m straight back from him over *BR-BACKSTEP-F*, iframes f0-8, the stance EN now (free)."
  (let* ((f (fighter e)) (p (pos-of e)))
    (set-slide e *br-backstep* *br-backstep-f* (- (aref p 0) (fighter-ox f)) (- (aref p 2) (fighter-oz f)))
    (setf (fighter-invuln f) (max (fighter-invuln f) *br-backstep-iframes*))
    (br-stance-arm e)
    (br-go-ranged e)
    (pace e :backstep)
    (emit :hoho-out e (aref p 0) (aref p 2))
    (emit :sfx :whoosh-light e)))
(defun br-recall-go (e)
  "The owl's K3 -> L, f0: every wing spent and counted (the full volley, decision R2: the one spend-all)."
  (let ((st (br e)))
    (setf (brs-recall-n st) (brs-ammo st) (brs-ammo st) 0)
    (pace e :volley) (pace e (intern (format nil "VOLLEY-T~d" (br-recall-tier (brs-recall-n st))) :keyword))
    (emit :sfx :rift-open e)))
(defun br-recall-fire (e)
  "The volley's f7: the derivative string for its count (BR-RECALL-TIER), facing him."
  (let* ((f (fighter e)) (tier (br-recall-tier (brs-recall-n (br e)))))
    (turn-to-opp e f 10.0)
    (start-move e (kit-next (fighter-kit f) :br-recall (svref #(:rc0 :rc1 :rc2 :rc3 :rc4) tier)))))
(defun br-rc-tick (e)
  "The volley's strings: he keeps on the opponent (*BR-RC-TRACK*); a human's SP2 pressed at any frame of the string is
latched and cancels its recovery from its last active frame's end into the charge-less Trompete (decision V9k / V9l)."
  (halt! e)
  (let* ((f (fighter e)) (mv (fighter-move f)) (st (br e)))
    (turn-to-opp e f (track-step *br-rc-track*))
    (when (and (eq (fighter-state f) :move) mv (eq (fighter-phase f) :main) (zerop (fighter-lock f)) (null (br-tick-brain e)))
      (let ((vp (pilot-vpad (pilot e))))
        (when (vpad-command-pressed-p vp :sig t) (vpad-consume! vp :sig) (setf (brs-rc-sp2 st) t))
        (when (and (brs-rc-sp2 st) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))
          (setf (brs-rc-sp2 st) nil)
          (turn-to-opp e f 10.0)
          (when (try-command e f :sp2 nil nil (kit-next (fighter-kit f) :br-recall :rc-sp2)) (pace e :rc-sp2)))))))
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
(defun br-reflect-check (e st mv)
  "Trompete at the end of its f59: the opponent in a perfect Hoho started f48-f59, or in a guard pressed f50-f58 (facing
him, not a ward) reflects it."
  (let* ((o (opp-of e)) (fo (fighter o)) (go (gauges o)) (p (pos-of e)) (q (pos-of o))
         (src (cond ((and (eq (fighter-state fo) :hoho) (fighter-perfect fo) (br-reflect-hoho-p (- 59 (fighter-sf fo)))) :hoho)
                    ((and (eq (fighter-state fo) :guard) (not (passive-p o :ward)) (br-reflect-guard-p (fighter-guard-t fo))
                          (can-guard-p (gauges-gg go) (gauges-guardless go))
                          (in-front-p (yaw-of o) (aref q 0) (aref q 2) (aref p 0) (aref p 2) *guard-arc*))
                     :guard))))
    (when src (br-reflect! e o st mv src))))
(defun br-reflect! (e o st mv src)
  "The reflect: he takes *BR-REFLECT-K* of Trompete x his form's damage as a real hit, staggers *BR-REFLECT-STUN*; SP2 is
sealed in the owl for the match. The reflector takes nothing."
  (let* ((dmg (round (* *br-reflect-k* (hw-dmg (svref (mv-hits mv) 0)) (kit-mult (kit-of e))))) (q (pos-of o)) (p (pos-of e)))
    (setf (brs-sealed st) t (fighter-perfect (fighter o)) nil)
    (callout o "REFLECT")
    (pace e (if (eq src :hoho) :reflect-hoho :reflect-guard))
    (hitstop *hitstop-breaker*)
    (emit :hit o e (aref p 0) (+ (aref p 1) 1.1) (aref p 2) *hitstop-breaker* nil dmg :sp)
    (unless (deal-damage o e dmg)
      (set-reaction e :stagger *br-reflect-stun* (aref q 0) (aref q 2) 1.0))
    (clog "~a TROMPETE REFLECTED by ~a (~a): ~d, sealed" (side-name e) (side-name o) src dmg)))
(defun br-reflect-test-step (e f)
  "Debug 82007 / 82008 (*BR-REFLECT-TEST*): the opponent's (CPU-off) brain presses guard on Trompete's f54, or Hoho on f52."
  (let* ((o (opp-of e)) (b (brain o)) (sf (fighter-sf f)))
    (when b
      (cond ((and (eq *br-reflect-test* :guard) (= sf 53)) (ai-press b :guard 200 :act :hold))
            ((and (eq *br-reflect-test* :hoho) (= sf 51)) (ai-press b :step 1 :modded t :act :hoho))))))

;;; ================================================================ AI (DUEL_LILLE_V3 §6.3)
;;; His CPU: his kits' :ai keys (every chance x *BR-AI-DIFF* by difficulty: EASY <= NORMAL <= HARD), the generic bands and
;;; string reflex (the stances' J / K strings go on by the J / K latch like any string: the follow-ups spend when they can)
;;; and these, each one roll per window (*BR-AI-EVERY* f) or event:
;;;   base     the stance from :zone's range (L), then its pick (BR-AI-STANCE-PLAN: L L below :gather of the cap, J J when
;;;            the flash step is under :recover-fs or the bars short, else K K; the Step off his attack; SP at :sp); L
;;;            after a K / J link (:l-after-k / -j) -> the stance at f4
;;;   KIN      the generic strings; J3 -> L the backstep into the stance (:backstep), K3 -> L in the owl the volley
;;;            (:volley, wings >= :n); the burst into the owl with :burst's wings and flash step inside :in m
;;;   EN       the generic bands press L / K / J: the stance's strings (each ends in KIN)
(defparameter *br-ai-diff* '(:easy 0.5 :normal 1.0 :hard 1.5)
  "His CPU's chances (his kits' :ai :p values) x this by difficulty, at most 1 (the old Lille's *LB-AI-DIFF*).")
(defparameter *br-ai-every* 30 "Frames between two of his window rolls (the base stance from range, the burst; new 2026-10-09).")

;; pure: host-tested
(defun br-ai-chance (p difficulty) "A chance P of his kit's :ai at DIFFICULTY: x *BR-AI-DIFF*, at most 1." (min 1.0 (* p (getf *br-ai-diff* difficulty 1.0))))
(defun br-ai-stance-plan (r ammo cap fs bars k &optional threat)
  "His CPU's base stance pick from one roll R (K: the kit's :stance): his attack coming (THREAT) the Step (:step of the time);
the specials (AMMO of CAP) under :gather of the cap: L L; the flash step FS under :recover-fs or the Reiatsu BARS under
:recover-bars: J J; with a bar SP2 :sp of the time; else K K."
  (cond ((and threat (< r (getf k :step 0.0))) :kamae-step)
        ((< ammo (* (getf k :gather 0.5) cap)) :kamae-l)
        ((or (< fs (getf k :recover-fs 40.0)) (< bars (getf k :recover-bars 1))) :kamae-j)
        ((and (>= bars 2) (< r (getf k :sp 0.0))) :kamae-sp2)
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
  "Every form's :reflex (ai.lisp AI-REFLEX, free states): the base stance from range (:zone); awakened, the burst into the
owl (BR-AI-BURST-P). One roll a window (*BR-AI-EVERY* f). A command or NIL."
  (declare (ignore s))
  (let* ((f (fighter e)) (st (br e)) (form (fighter-form f)) (g (gauges e)))
    (when (and (member (fighter-state f) '(:idle :run :guard)) (zerop (fighter-lock f))
               (>= (- *match-tick* (brs-ai-t st)) *br-ai-every*))
      (setf (brs-ai-t st) *match-tick*)
      (cond ((eq form :base)
             (let ((k (ai-table e :zone)))
               (when (and k (>= d (getf k :near 6.0)) (< (sim-rnd01) (br-ai-chance (getf k :p 0.0) (brain-difficulty b))))
                 (pace e :ai-zone) (why b :zone :sig))))
            ((br-jilliel-form-p form)
             (when (br-ai-burst-p (sim-rnd01) (brs-ammo st) (gauges-fs g) d (ai-table e :burst) (brain-difficulty b))
               (when (burst-ok-p e) (pace e :ai-burst) (why b :owl :burst))))))))

(defun br-ai-sp-ender (e kit)
  "The KIN forms' :sp-ender (ai.lisp STRING-REFLEX: a landed J3 / K3): K3 -> L the owl's volley with :volley's wings, J3 -> L
the backstep into the stance (:backstep), one roll on the land frame x the difficulty. :SIG, or NIL."
  (let* ((b (ai-brain e)) (f (fighter e)) (mv (fighter-move f)) (st (br e)) (form (kit-form kit)))
    (when (and b mv (member :ender (mv-flags mv)) (br-melee-form-p form))
      (let* ((to (br-l-route (mv-kind mv) t (br-owl-form-p form)))
             (k (getf (kit-ai kit) (if (eq to :br-recall) :volley :backstep))))
        (when (and k (or (not (eq to :br-recall)) (>= (brs-ammo st) (getf k :n 1)))
                   (not (eq to :br-to-en))
                   (kit-command-ok-p e :sig kit nil (kit-l-link kit (mv-name mv)))
                   (< (sim-rnd01) (br-ai-chance (getf k :p 0.0) (brain-difficulty b))))
          (pace e (if (eq to :br-recall) :ai-volley :ai-backstep))
          :sig)))))

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
;;;                 the base's at f4, the awakened turn / backstep / the owl's volley)
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
        (log-msg "duel barro ~a seed ~d awakened ~a form ~a ammo ~d armored ~d sealed ~a ~{~(~a~) ~a~^ ~}" (side-name e) *match-seed*
                 (gauges-awakened (gauges e)) (fighter-form (fighter e)) (brs-ammo st) (brs-armored st) (brs-sealed st)
                 (svref *pacing* (fighter-side (fighter e))))))))

(defun barro-probe-line (tag)
  (let ((g1 (gauges *p1*)) (g2 (gauges *p2*)) (st (br *p1*)))
    (log-msg "duel probe barro ~a t ~d p1 ~a ~a r~d k~d fs ~d rei ~,1f ammo ~d burst ~a | p2 ~a r~d gg ~d | d ~,2f"
             tag *match-tick* (fighter-form (fighter *p1*)) (state-of *p1*) (gauges-reishi g1) (gauges-konpaku g1)
             (round (gauges-fs g1)) (gauges-reiatsu g1) (brs-ammo st) (gauges-burst g1)
             (state-of *p2*) (gauges-reishi g2) (round (gauges-gg g2)) (fighter-dist (fighter *p1*)))))

(defun barro-test (k)
  "82000+k (human P1 Lille II, P2's CPU off unless noted; a \"duel probe barro\" line): 0 the base form 2.2 m from Kenpachi;
1 the base form 14 m out; 2 JILLIEL KIN 5 m out; 3 JILLIEL EN (the stance) 8 m out; 4 the owl KIN 5 m out (kept: no
burst needed); 5 the base form 4 m out with 3 pips; 6 KIN 1.4 m out with 8 wings (K K K -> L: the stance, in the owl the
volley); 7 / 8 the owl KIN 6 m out, Trompete started, P2 reflecting it by a guard on f54 / a Hoho on f52; 9 the owl EN 8 m
out; 10 EN 6 m out with 8 wings; 11 KIN 2 m out with 4 wings, P2's CPU on (the wing armour); 12 the base form 6 m out, the
stance started; 16 the same with 3 pips, 20 flash step and no Reiatsu (J J -> K K's gains); 13 KIN 4 m out with 8 wings and the flash step full (a burst: the owl); 14 the owl KIN 1.4 m out with 8
wings (K K K -> L: the volley, 裁き・極); 15 the base form 4 m out with 0 pips, the stance started; 20 both CPUs (the
mirror) 12 m apart; 30 / 31 *BR-KEEP-OWL* off / on; any other k the probe line only."
  (flet ((setup (c2 form dist &key cpu (ammo 0))
           (ensure-battle :barro c2 :cpu cpu)
           (when (brain *p1*) (setf (brain-off (brain *p1*)) (not cpu)))
           (unless (eq (fighter-form (fighter *p1*)) form) (force-form *p1* form))
           (place *p1* *p2* dist)
           (setf (gauges-reiatsu (gauges *p1*)) *reiatsu-max* (gauges-fs (gauges *p1*)) (f32 *fs-max*)
                 (brs-ammo (br *p1*)) ammo)))
    (setf *br-reflect-test* nil)
    (case k
      (0 (setup :kenpachi :base 2.2))
      (1 (setup :kenpachi :base 14.0))
      (2 (setup :kenpachi :jilliel-kin 5.0))
      (3 (setup :kenpachi :jilliel 8.0))
      (4 (setf *br-keep-owl* t) (setup :kenpachi :shin-kin 5.0))
      (5 (setup :kenpachi :base 4.0 :ammo 3))
      (6 (setup :kenpachi :jilliel-kin 1.4 :ammo 8))
      ((7 8) (setf *br-keep-owl* t) (setup :kenpachi :shin-kin 6.0) (setf *br-reflect-test* (if (= k 7) :guard :hoho))
       (force-cmd *p1* :sp2))
      (9 (setf *br-keep-owl* t) (setup :kenpachi :shin 8.0))
      (10 (setup :kenpachi :jilliel 6.0 :ammo 8))
      (11 (setup :kenpachi :jilliel-kin 2.0 :ammo 4)
          (when (brain *p2*) (setf (brain-off (brain *p2*)) nil)))
      (12 (setup :kenpachi :base 6.0) (force-cmd *p1* :sig))
      (13 (setup :kenpachi :jilliel-kin 4.0 :ammo 8))
      (14 (setf *br-keep-owl* t) (setup :kenpachi :shin-kin 1.4 :ammo 8))
      (15 (setup :kenpachi :base 4.0) (force-cmd *p1* :sig))
      (16 (setup :kenpachi :base 4.0 :ammo 3) (force-cmd *p1* :sig)
          (setf (gauges-fs (gauges *p1*)) 20f0 (gauges-reiatsu (gauges *p1*)) 0f0))
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
