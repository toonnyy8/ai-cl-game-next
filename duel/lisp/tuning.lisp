;;;; tuning.lisp — SOUL DUEL's balance knobs in one place (design-v1 §1–§4, §8, §14). Change a
;;;; number here and rebuild; nothing else needs to know. Units: frames are 60 Hz fixed steps,
;;;; distances metres, speeds m/s, angles degrees, Reishi integer points, fractions 0..1.
;;;; Per-move frame data (startup, damage, block advantage) lives with the moves (yama.lisp,
;;;; ken.lisp); a kit may also name a knob here by symbol (:walk *walk-yamamoto*): kit.lisp
;;;; resolves *EARMUFFED* symbols in kit/move data to their value at load.
;;;; Plain Common Lisp: loaded on the host by tests/duel-rules-test.lisp.
(in-package :duel)

;;; ================================================================ §1 rules
(defparameter *reishi-max* 1300
  "Reishi (health) of every fighter at the start, integer points. 1100 -> 1300 (guard v3, the user's decision
2026-09-26: real human matches run much faster than CPU vs CPU, so longer CvC matches are fine; the seed gate's
median window moved from 125-180 s to 125-210 s).")
(defparameter *konpaku-max* 9 "Konpaku (soul pips) per fighter, as in RoS; the one at 0 loses.")
(defparameter *red-threshold* 0.30
  "Red = Reishi below this fraction of max: the Kikon rush's dash-in follow-up can't be guarded (rules
KIKON-FOLLOW-UNGUARDABLE-P; above red he may guard it).
The §8 gate's pacing knob if seeded CPU matches run long (fix round: 0.10 .. 0.30 moved the gate
medians by only ~10 s, see p2-log).")
(defparameter *kikon-konpaku* 2 "Konpaku a Kikon removes (a kit's default :kikon-konpaku).")
(defparameter *kikon-konpaku-awakened* 3 "Konpaku a Kikon removes when the attacker is awakened (the default of an awakened kit).")
(defparameter *soul-break-extra* 1 "A Soul Break (Reishi reached 0) removes the attacker's current Kikon count + this ...")
(defparameter *kikon-max-event* 4
  "... but a Kikon never removes more than this (Nozarashi v2 §2.7) ...")
(defparameter *soul-break-max-event* 5
  "... and a Soul Break never more than this (the user's decision 2026-09-27: the Soul Break's own cap, so NOMIHOSE's
4 + 1 = 5; a Kikon stays capped at *KIKON-MAX-EVENT*).")
;;; the Kikon rush (the Kikon button, any time): aura, dash, then the kit's strike (frame data per kit)
;;; (each character's rush module sets its own aura, dash speed and range: the move's :params)
(defparameter *kikon-trigger* 1.6
  "... and the strike starts as soon as the opponent is within this range (a blocked strike pushes
him 0.6 m back: 2.2 m, still inside both characters' Q1 reach, so the -14 is punishable).")
(defparameter *kikon-follow-kb* 2.5
  "A rush strike that hits with the button held knocks the victim this far back (a short stagger) ...")
(defparameter *kikon-follow-stun* 16
  "... for this long (a victim who isn't red; a red one reels until the Kikon lands: KIKON-FOLLOW-STUN) ...")
(defparameter *kikon-follow-gap* 24
  "... while the rusher dashes in after him: its strike (the Kikon) lands *KIKON-FOLLOW-STUN* + 1 + this many frames
after the O's hit (KIKON-FOLLOW-WAIT). 12 -> 24 (29 -> 41 frames from the O's hit to the Kikon), 2026-10-24, the user:
「請把所有角色 O 到毀魂技的空檔延長，然後只要被 O 打中，非紅血狀態就鎖定防禦（此狀態可防禦取消硬直並擋下毀魂技）以外的一切行為，紅血狀態則連同防禦都鎖定。」 Until then the victim (not red) was free for these frames (guard, Step, Hoho); since then he reels until the
strike lands, locked to the guard (not red: U cancels the reel into a guard that blocks it) or to nothing (red):
KIKON-LOCK-P, FIGHTER-KIKON-LOCK.")
(defparameter *kikon-track* 120.0 "Default :track (deg/s) of a Kikon rush strike's startup (like the Breaker's dash).")
(defparameter *armor-from* 6 "A move's armour (:armor-hits) starts on this move frame (no frame-1 reversals).")
(defparameter *reset-distance* 8.0 "After a Kikon / Soul Break both fighters are placed this far apart.")
(defparameter *reset-neutral* 48 "Frames of neutral (inputs ignored) after the reset (0.8 s).")
(defparameter *reset-reiatsu-bonus* 10.0 "Reiatsu a kit with :reset-reiatsu gets at each reset (Kenpachi).")
(defparameter *match-seconds* 300 "Match timer. Time-up: more Konpaku wins, then higher Reishi %, else draw.")
(defparameter *chip-fire* 0.12 "Chip-damage fraction of fire projectiles on block (never kills).")

;;; ================================================================ §2 controls
(defparameter *input-buffer* 10 "Frames a button press stays buffered in the vpad.")

;;; ================================================================ §3 universal mechanics
;;; ---------------------------------------------------------------- facing, walk, step, guard
(defparameter *face-rate* 18.0 "Degrees per frame a fighter auto-turns to the opponent (idle/walk/guard).")
(defparameter *track-quick* 360.0 "Default :track (deg/s turn allowed during startup) of Quick moves.")
(defparameter *track-heavy* 60.0 "Default :track of Flash, Signature and SP moves.")
(defparameter *track-breaker* 120.0
  "Default :track of the Breaker dash: a sideways Step from >= 3 m beats it, a back Step doesn't.")
(defparameter *walk-yamamoto* 3.2 "Yamamoto's walk / strafe speed.")
(defparameter *walk-kenpachi* 4.4 "Kenpachi's walk / strafe speed.")
(defparameter *step-distance* 2.5 "Step hop length (stick direction; neutral = back).")
(defparameter *step-frames* 24 "Step total frames.")
(defparameter *step-iframes* '(3 9) "Step invulnerable frames, inclusive.")
(defparameter *step-j-cancel* 12
  "From this Step frame (the hop's slide is over) J cancels the rest of the Step into J1 (the user, 2026-10-02).")
(defparameter *run-yamamoto* 8.0 "Yamamoto's run (dash) speed: Step held past the hop.")
(defparameter *run-kenpachi* 10.0 "Kenpachi's run speed.")
(defparameter *run-turn* 300.0 "Degrees per second a runner turns toward the stick direction.")
(defparameter *run-stop* 1.2 "A run toward the opponent stops this close to him.")
(defparameter *run-brake* 6 "Frames of braking after Step is released (committed, like recovery).")
(defparameter *run-carry* 1.0 "A move started out of a run slides this far along the run (momentum) ...")
(defparameter *run-carry-frames* 10 "... over this many frames (never past *RUN-STOP* from the opponent).")
(defparameter *guard-raise* 4
  "Frames of holding Guard before it blocks (2 -> 4, 2026-10-23, the user: 「拉長打空與被防禦的收招，但收招可以用防禦取消，進入防禦跟
解除防禦會有短暫的硬直」, the lead's medium numbers; 4 -> 6 the same day, 「幫我將拉長改成重度」: the heavy set; 6 -> 4, 「調回中間」; DUEL_DESIGN \"Whiff
and block recovery\").")
(defparameter *guard-exit* 4
  "Frames after letting go of a guard (leaving the :guard state) in which only Step and Hoho may start: no attack, no
walk (none -> 4, 2026-10-23, the same decision: 「只擋攻擊這個選項應該只能開放 step 跟 hoho，不能移動對吧？」; 4 -> 6, 「重度」; 6 -> 4, 「調回中間」).")
(defparameter *whiff-add* '(:quick 8 :flash 8 :kikon 8)
  "A J link (:quick), K link (:flash) or O (:kikon) that touched nothing recovers this much longer than its own whiff
recovery (none -> 8 each, 2026-10-23, the same decision: J R + 8 -> R + 16, K R + 12 -> R + 20, O whiff + 8; 8 -> 16 each,
「重度」: J R + 24, K R + 28, O whiff + 16; back to 8, 「調回中間」) ...")
(defparameter *block-add* '(:quick 4 :flash 6 :kikon 6)
  "... and one that was blocked and goes on into nothing (no link: a string's chain keeps its own timing) recovers R +
this, the defender's blockstun unchanged: his block advantage grows by as much (none -> J 4, K 6, O 6, the same
decision; -> J 8, K 10, O 10, 「重度」; back to J 4, K 6, O 6, 「調回中間」). Both recoveries may end in a guard over their last half (GUARD-CANCEL-OPEN-P).")
(defparameter *guard-arc* 200.0 "Guard covers this many degrees in front (while the guard gauge lasts).")
(defparameter *block-pushback* 0.6 "Metres a blocked hit pushes the defender back.")
(defparameter *whiff-extra* 6 "A move that touched nothing recovers R + this (a J / K link: the two below).")
(defparameter *whiff-extra-j* 8
  "A J link (a :quick move) that touched nothing recovers R + this, a single swing with no string after it
(docs/duel/DUEL_STRINGS.md §2.2, the user's decision 2026-09-27) ...")
(defparameter *whiff-extra-k* 12 "... and a K link (a :flash move) R + this.")
(defparameter *hazard-blockstun* 14
  "Blockstun of a blocked hazard hit (fire wave, Shiranui, pillars): a projectile has no
attacker recovery to measure advantage against, so it is a fixed stun.")
(defparameter *chain-lead* 3
  "On block a string's next link starts this many frames before the current link's recovery ends. With a -2 link
this leaves S_eff(next) - 2 frames of gap (J2 after J1: 5-7 f): Step / Hoho fit, J1 doesn't; a K link leaves >= 11 f,
so any J1 interrupts it (docs/duel/DUEL_STRINGS.md §2.1). On hit the chain opens at the end of the active frames
instead (true combos); on a whiff never (the contact gate, §2.2).")
(defparameter *guard-cancel* 0.75
  "The guard cancel (the user, 2026-10-01): a move whose own hit landed may end in a guard (Guard held) once only this
share of its recovery is left, so a hit doesn't leave its owner open (GUARD-CANCEL-OPEN-P); a J / K / O also blocked or
whiffed since 2026-10-23 (0.5 -> 0.75, 2026-10-23, the user: 「將防禦取消提早」: the last three quarters).")
(defparameter *assist-mult* 0.8
  "ASSIST (the user, 2026-10-01; docs/duel/DUEL_ASSIST.md): a move the assist pressed deals this x its damage (its Hoho is never
perfect): playing it by hand still pays.")
(defparameter *assist-tag-frames* 45 "Frames the AUTO tag shows over a fighter after the assist pressed for him.")
(defparameter *ender-push* 0.05
  "A J / K string's ender (J3 / K3) that hits pushes its victim at once out of the attacker's J1 (J3) / K1 (K3) reach:
that move's far edge (its reach, + a capsule's radius since 2026-10-24, the user: 「請修改推開規則，要將半徑也計算進去」,
MOVE-EDGE) + its lunge (:slide) + the victim's body + this many metres (his walk-in while both recover); the
attacker doesn't move (the user 2026-10-02: J1 / K1 must not reach him straight away). What the attacker starts off the
ender (the O ender's dash, L, SP, ORANGE's restart) chases him (FIGHTER-END-CHASE) ...")
(defparameter *ender-push-frames* 8 "... over this many frames.")
(defparameter *ender-o-dash* 24 "The O ender off a pushing J3 / K3 dashes at least this many frames ...")
(defparameter *ender-o-speed* 16.0 "... at least this fast (m/s), and on while he still slides (KIKON-RUSH-STEP): it reaches him.")
(defparameter *ender-chase-max* 40.0
  "A move started off a pushing J3 / K3 (L, SP, ORANGE's J1) chases him this fast at most (m/s): the follow-ups start as
the hitstop ends, while he is still being pushed (the user 2026-10-02: K3 -> O whiffed).")
(defparameter *string-pull-to* 0.7
  "A string's opener (J1 / K1) that HITS dashes its attacker in to this distance from his victim (the user 2026-10-02: the
links no longer chase, so a hit brings them point-blank; a block or a whiff never does) ...")
(defparameter *string-pull-frames* 6 "... over this many frames.")
(defparameter *quick-block-adv* 3
  "A blocked J (a :quick move) leaves its defender this many frames more than its written block advantage (the user,
2026-10-02: J strings alone shouldn't crush a guard; out of a blocked J the defender's own J comes sooner). The guard
lock still holds him through a string's links (GUARD-LOCKED-P): it counts once the string can't go on.")
(defparameter *counter-mult* 1.25 "Damage multiplier of a counter-hit (Breaker / stance hit during startup).")
(defparameter *counter-stun* 10 "Extra hitstun frames of a counter-hit.")

;;; ---------------------------------------------------------------- Breaker
(defparameter *breaker-aura* 12 "Aura frames before the Breaker dash starts.")
(defparameter *breaker-dash-min* 12 "Shortest dash (a tapped Breaker) before the strike.")
(defparameter *breaker-dash-max* 45 "Longest dash while the button is held.")
(defparameter *breaker-speed-min* 9.0 "Dash speed at the start of the dash (m/s)...")
(defparameter *breaker-speed-max* 10.0 "... rising to this at *breaker-dash-max*.")
(defparameter *breaker-trigger* 1.6
  "The strike starts when the opponent is within this range (centre to centre; 2.2 until the user's 2026-09-29 rule 防 > J >
I > 防, docs/duel/DUEL_STRINGS.md §14: the grab only from up close; 0.95 until the J floor, 2026-10-06, moved out with the reach).")
(defparameter *breaker-startup* 8 "Strike startup (the aura brightens over it: the 'hit it now' tell).")
(defparameter *breaker-active* 4 "Strike active frames.")
(defparameter *breaker-recovery* 18 "Strike recovery.")
(defparameter *breaker-whiff* 30 "Strike recovery after a whiff.")
(defparameter *breaker-damage* 150 "Strike damage on a non-guarding opponent.")
(defparameter *breaker-reach* 1.35
  "Strike hit reach (2.6 until 2026-09-29, 0.7 until the J floor 2026-10-06): under every form's J1 reach (*J-REACH-MIN*;
J beats I, 防 > J > I > 防), and with the thinnest hurt radius (0.34) past the trigger range, so a triggered strike connects.")
(defparameter *j-reach-min* 1.4
  "Every J link's (:quick move's) reach is at least this, after its form's :reach-mult (the user 2026-10-06: J reached
0.73-1.32 m in some forms; the Breaker moved out with it, still under it: J beats I).")
(defparameter *breaker-knockback* 0.3
  "Strike slide: a stagger in place (3.0 m knockback until 2026-10-02: the Breaker opens a combo, J1 / K1 cancel off it).")
(defparameter *guard-break-stun* 50 "Stun of a Guard Break.")
(defparameter *stance-break-stun* 40 "Crumple of a stance broken by a Breaker.")
(defparameter *clash-range* 3.0 "Breaker vs Breaker (both dashing/striking) within this range = CLASH.")
(defparameter *clash-push* 4.0 "A clash pushes both fighters this far apart ...")
(defparameter *clash-stun* 24 "... and stuns both this long.")
(defparameter *guard-break-kb* 0.8 "Slide of a guard-broken fighter.")
(defparameter *stance-break-kb* 0.5 "Slide of a broken stance.")

;;; ---------------------------------------------------------------- Reiatsu gauge (3 bars): SPs only
(defparameter *reiatsu-max* 300.0 "Reiatsu gauge maximum (3 bars).")
(defparameter *reiatsu-bar* 100.0 "One bar.")
(defparameter *reiatsu-regen* 3.0
  "Reiatsu per second, always (5 before the flash-step gauge took Hoho and Burst off it: design v3 G.3).")
(defparameter *reiatsu-kind* '(:quick 3.0 :flash 5.0 :sig 4.0 :sp 4.0 :kikon 7.0 :breaker 14.0)
  "Reiatsu a hit pays its attacker by its move's kind (J K L SP O Breaker), x the combo bonus (COMBO-GAIN-MULT); a move's
:reiatsu param overrides its kind's; a hazard keeps its move's at its spawn (the user 2026-10-26: 「不再按傷害，改成依據每招式
各自的基礎值 * combo 數加成」, 「依招式種類固定值」; before: *REIATSU-DEALT* 0.08 a point dealt, whose roster average per hit was
J 2.7 K 5.7 L 4.7 SP 5.6 O 6.9 Breaker 14.3). A hit that deals no damage pays nothing; chip and a drink pay nothing.")
(defparameter *reiatsu-kind-other* 4.0 "... a kind not in the table (a hazard spawned outside a move, the counter strike).")
(defparameter *reiatsu-taken* 0.15
  "Reiatsu per point of damage taken, x the combo bonus (2026-10-26: 「被打方改成受傷值 x combo 加成」; 0.10 -> 0.15 the same day:
「提高被攻擊方的恢復量」, 「兩種都 ×1.5」).")
(defparameter *reiatsu-combo-step* 0.1
  "The combo bonus on hit gains (dealt and taken): x(1 + this x (n - 1)) at the combo's nth hit (its HIT-DAMAGE index) ...
(the user 2026-10-26: 「每多一下 +10%，上限 ×2」)")
(defparameter *reiatsu-combo-max* 2.0 "... at most this (the 11th hit on).")
(defparameter *cost-sp* 1 "Bars an SP1 / SP2 costs.")
(defparameter *cost-sp-awakened* 2 "Bars an SP2 costs in an awakened form.")

;;; ---------------------------------------------------------------- KOSEI (攻勢), the aggression reward (docs/duel/DUEL_STRINGS.md §5)
;;; Every contact of the attacker's own melee hit window (hit, block, ward, DRINK, armour, absorb; not a parry, a
;;; hazard, a :ranged window or a Kikon) pays Reiatsu and flash-step, g x rate x m, g = the hit's guard value and
;;; m = 1 + *KOSEI-BONUS* x (1 - his own guard gauge / max): x1 at a full gauge ... x3 at an empty one.
(defparameter *kosei-bonus* 2.0 "KOSEI: the multiplier's range above 1 (x1 full gauge .. x(1 + this) empty).")
(defparameter *kosei-reiatsu* 0.20 "KOSEI: Reiatsu per point of a paying contact (*KOSEI-KIND*, x the combo bonus, x m).")
(defparameter *kosei-fs* 0.30 "KOSEI: flash-step per point of a paying contact (*KOSEI-KIND*, x the combo bonus, x m); 0.10 -> 0.30 with the
0-300 gauge (*FS-MAX*).")
(defparameter *kosei-kind* '(:quick 9.0 :flash 16.0 :sig 36.0 :sp 27.0 :kikon 20.0 :breaker 0.0)
  "KOSEI: a paying contact's points by its move's kind (J K L SP O Breaker), x the combo bonus (COMBO-GAIN-MULT: the combo's
nth hit, a block 1) and x m; a move's :kosei param overrides its kind's (the user 2026-10-26: 「閃步量表也做一樣的修改」,
「攻勢整個改成基礎值×combo×防禦量表越空乘越多」; before: the hit's guard value, whose roster mean per hit was J 8.8 K 16.2 L 35.6
SP 27.3 O 20, a Breaker's 0).")
(defparameter *kosei-kind-other* 16.0 "... a kind not in the table.")

;;; ---------------------------------------------------------------- flash-step gauge (design v3 G.1): Hoho, Burst
;; (the gauge x3, the user 2026-10-29: 「幫我將閃步量表改成 0-300，並且將 hoho 消費改成 100，爆氣設為 200，其他恢復量也做對應的提昇」; DUEL_DESIGN "Flash-step gauge 0-300", DEVLOG §504: the max, every gain and the drain x3,
;; the Hoho 30 -> 100 and the burst 70 -> 200 as asked, so a Hoho is 1/3 of the gauge (was 0.3) and a burst 2/3 (was 0.7))
(defparameter *fs-max* 300.0 "Flash-step gauge maximum (100 -> 300); full at the match start, kept through Kikon resets.")
(defparameter *fs-hoho* 100.0 "Flash-step a Hoho costs (30 -> 100).")
(defparameter *fs-burst* 200.0 "Flash-step every burst mode needs to start (70 -> 200: two of the HUD's three cells; the drain is the cost).")
(defparameter *fs-regen* 9.0 "Flash-step per second (3 -> 9) ...")
(defparameter *fs-delay* 60 "... once this many frames passed since the last spend.")
(defparameter *fs-taken* 0.135
  "Flash-step per point of damage taken, x the combo bonus (a full 1300 Reishi bar = +175.5 before it); 0.045 -> 0.135 with the
0-300 gauge (2026-10-29); 0.03 -> 0.045 and the
bonus (the user 2026-10-26: 「閃步量表也做一樣的修改，然後提高被攻擊方的恢復量」, 「兩種都 ×1.5」).")
;; (*FS-REFUND* 15, a perfect Hoho's flash-step back, removed 2026-10-18, the user: 「取消完美閃避能減少閃步量表消耗的設定」,
;; DUEL_DESIGN "Perfect Hoho without a refund": a perfect Hoho costs its full 30)

;;; ---------------------------------------------------------------- guard gauge (design v3 G.2)
(defparameter *gg-max* 100.0 "Guard gauge maximum; full at the start and after every Kikon reset (both).")
(defparameter *gg-kind* '(:quick 8 :flash 14 :sig 18 :sp 22 :kikon 20)
  "Guard value (the gauge a blocked hit drains) by move kind; a hitwin / move :guard overrides it.")
(defparameter *gg-hazard* 12 "Guard value of a blocked hazard hit without its own :guard.")
(defparameter *gg-ender* 4 "+ this for a string ender (Quick / Flash / Signature with block advantage <= *GG-ENDER-ADV*).")
(defparameter *gg-ender-adv* -10 "The block advantage that makes a Quick / Flash / Signature an ender.")
(defparameter *gg-breaker* 35 "A Breaker's Guard Break also drains this.")
(defparameter *gg-delay* 60
  "The gauge refills only after this many frames without a drain (the user: 45 -> 60), counting only frames he is
not guarding (GUARD HOLD, guard v3: while he guards, in :guard / :guard-hit, it neither refills nor counts; the
count is frozen, not restarted: a phone's resting thumb is a guard) ...")
(defparameter *gg-regen* 5.5
  "... at this per second (the user: 20 -> 12; then, the user's request 2026-09-27 (大幅減少防禦量表的恢復速度): 12 -> 5.5,
46 %) ...")
(defparameter *gg-regen-guardless* 6.5
  "... or this while guardless (the user: 25 -> 14; 2026-09-27: 14 -> 6.5, 46 %; 0 -> 100 in 15.4 s + the delay).")
(defparameter *guard-crush-stun* 40
  "A blocked hit that empties the gauge is still blocked, then the defender reels this long (GUARD CRUSH)
and can't guard until the gauge is full again.")

;;; ---------------------------------------------------------------- Hoho
(defparameter *hoho-distance* 1.6 "Hoho reappears this far behind the opponent, facing him.")
(defparameter *hoho-frames* 24 "Hoho total frames.")
(defparameter *hoho-iframes* '(1 14) "Hoho invulnerable frames, inclusive.")
(defparameter *hoho-lockout* 60 "Frames between two Hohos.")
(defparameter *hoho-resume-frames* 12
  "After a Hoho off a landed NA / SA / NS move, J or SP within this many frames still resumes its combo (a press during the Hoho waits
for its end); the victim's reaction is held meanwhile (DUEL_CORE §8; the user, 2026-10-28: 「讓攻擊中接入 hoho 後會延續攻擊 combo」;
the lead's default).")
(defparameter *perfect-lead* 12 "Perfect Hoho: an opponent hit volume active now or within this many frames (8 -> 12, the
user 2026-10-01: a wider timing; still inside the Hoho's iframes f1-14)...")
(defparameter *perfect-inflate* 1.0 "... overlapping our hurt cylinder grown by this (radius and height).")
(defparameter *perfect-slowmo-seconds* 0.45 "Perfect Hoho slow motion, both fighters.")
(defparameter *perfect-slowmo-scale* 0.25 "Perfect Hoho time scale.")
(defparameter *perfect-counter-damage* 60 "The automatic counter strike (can't be Hoho'd or Burst).")
(defparameter *perfect-counter-stun* 36 "Hitstun of the counter strike.")
(defparameter *perfect-lock* 40 "Frames the perfect-Hoho victim's inputs are locked.")
(defparameter *hoho-appear* 6 "Hoho frame on which the fighter reappears behind the opponent ...")
(defparameter *hoho-counter-pose* 10 "... a perfect Hoho's counter swing starts ...")
(defparameter *hoho-counter-strike* 14 "... and its strike lands.")

;;; ---------------------------------------------------------------- Fighting Spirit (awakening)
(defparameter *awaken-max* 100.0 "Awakening gauge maximum: full = EVOLUTION (once per match).")
;; the slower awakening gauge (the user 2026-09-30, 「降低覺醒條的上升速度」): every fill source x0.7
(defparameter *awaken-dealt* 0.035 "Awakening per point of damage dealt (0.05 until 2026-09-30).")
(defparameter *awaken-taken* 0.049 "Awakening per point of damage taken (0.07 until 2026-09-30).")
(defparameter *awaken-per-konpaku* 10.5 "Awakening per Konpaku lost (15 until 2026-09-30).")
(defparameter *awaken-heal* 0.20 "Every awakening heals this fraction of max Reishi at once (the user 2026-09-30; before it only
Nozarashi healed, 150).")

;;; SUBLIMATION / SPIRIT DRIVE (docs/duel/DUEL_SUBLIMATION.md; the user, 2026-10-31): the awakening gauge's second and third stage.
;; A full awakening gauge keeps filling a second gauge, SUBLIMATION (same sources, x1.0, no decay); its fraction s of B (the four
;; boosts below at a full gauge) is the fighter's bonus. The awakening freezes it at *SUB-KEEP* x s; SPIRIT DRIVE then fills the same
;; way and adds up to *DRIVE-ADD* x B (full B as the base: the user's answer). A full DRIVE opens Kenpachi's Bankai.
(defparameter *sub-max* 100.0 "SUBLIMATION gauge maximum (the awakening gauge's overflow fills it).")
(defparameter *drive-max* 100.0 "SPIRIT DRIVE gauge maximum (after the awakening).")
(defparameter *sub-dmg* 0.20 "Damage dealt x (1 + this x the bonus fraction).")
(defparameter *sub-taken* 0.20 "Damage taken x (1 - this x the bonus fraction).")
(defparameter *sub-speed* 0.10 "Walk / run speed x (1 + this x the bonus fraction).")
(defparameter *sub-fs* 0.30 "Flash-step gauge gained from hits x (1 + this x the bonus fraction) (the Reiatsu gauge is gone: DUEL_CORE §6).")
(defparameter *sub-keep* 0.5 "The share of the pre-awakening SUBLIMATION fraction the awakening keeps.")
(defparameter *drive-add* 0.5 "What a full SPIRIT DRIVE adds on top, as a share of B (not of the kept fraction).")

;;; ---------------------------------------------------------------- hit reactions, combos, hitstop
(defparameter *reaction-frames*
  '(:flinch 18 :stagger 26 :knockback 30 :launch 0 :knockdown 0 :guard-break 50 :crumple 40
    :down 30 :wakeup 30)
  "Stun frames per reaction. :launch / :knockdown are airborne / falling until they land (physics),
then :down + :wakeup (iframes in both).")
(defparameter *knockback-slide-frames* 18 "A grounded reaction's slide lasts at most this long.")
(defparameter *air-vy* '(:launch 7.5 :knockdown 3.5 :air 4.0)
  "Upward speed (m/s) given by a launch, a knockdown, and any other hit on an airborne fighter.")
(defparameter *air-slide* 0.6 "An airborne reaction slides this x the hit's :kb (1 m without one) ...")
(defparameter *air-slide-frames* 20 "... over this many frames.")
(defparameter *gravity* 22.0 "Airborne fighters fall at this (m/s^2).")
(defparameter *lunge-stop* 0.95
  "A lunging move (:slide) stops moving this close to the opponent (1.3 until the J cut of 2026-09-29, docs/duel/DUEL_STRINGS.md
§13: a J reaches ~1 m + his hurt radius, so the lunge and the chase stop inside that; above the widest pair of hurt radii, 0.9).")
;; the string follow-up's chase (docs/duel/DUEL_STRINGS.md §2.2, the user's decision 2026-09-28): once a link of the string
;; touched him, every later link closes in during its startup so its hit window reaches him (motion only: guard, Step /
;; Hoho / down iframes still work)
(defparameter *chase-max* 18.0 "A follow-up link closes in at most this fast (m/s; the Kikon dash's speed) ...")
(defparameter *chase-margin* 0.4 "... to this far inside its reach (never nearer than *LUNGE-STOP*) ...")
(defparameter *chase-track* 360.0 "... turning toward him at least this fast (deg/s; a K link's own is 60).")
(defparameter *callout-frames* 90 "Frames a move name stays above its user.")
(defparameter *combo-launches* 1 "Launches per combo; a later launch becomes a knockback.")
(defparameter *combo-air-hits* 3 "Airborne hits per combo; the last one knocks down.")
(defparameter *combo-full-hits* 3 "Hits 1..this deal full damage...")
(defparameter *combo-decay* 0.15
  "... then each hit deals this much less (0.10 -> 0.15, 2026-10-24, the user: 「幫我提高連段的傷害減免」: hit 4 85 %, 5 70 %, 6
55 %, 7 40 %) ...")
(defparameter *combo-floor* 0.20
  "... down to this fraction (0.40 -> 0.20, 2026-10-24, the user: 「減免最低 20%」: hit 8 25 %, 9 on the floor).")
(defparameter *orange-combo-decay* 0.10
  "While the attacker's ORANGE runs (the user, 2026-10-24: 「橙色爆氣會將減免補正重置，且期間減免速度改成 10%、最低 50%」): the
scaling counts again from the hit after it started (FIGHTER-COMBO-FROM) and each hit past *COMBO-FULL-HITS* deals this much
less ...")
(defparameter *orange-combo-floor* 0.50 "... down to this fraction (new 2026-10-24, the user).")
;; the hidden hit-stun tolerance (docs/duel/DUEL_DESIGN.md "Hidden hit-stun tolerance", the user 2026-09-29): every connected
;; hit fills the victim's hidden stun gauge; the hit that takes it past his kit's :stun-tolerance blows him away
(defparameter *stun-weights* '(:flinch 1 :bind 1 :stagger 2 :crumple 3 :knockback 3 :launch 3 :knockdown 3 :heavy 3)
  "Stun points a connected hit adds by its written reaction (any other: 1); :heavy is the floor of an SP / Kikon-rush strike.")
(defparameter *stun-blow-away* nil
  "Does a hit past the hidden stun's tolerance blow the victim away? T 2026-09-29 (DEVLOG §37, the user: 「所有角色應該要設一個
隱藏的受擊數值…」) -> NIL 2026-10-10 (DEVLOG §173, the user: 「現在的系統當角色吃下過多傷害或連段會在中途強制倒地，這導致覺醒的 K > L
回收的高傷害連段會在中途就強制中斷。」, then 「全角色取消暈眩值」): no blow-away for anyone. The stun still adds and decays (inert);
the tolerances and the pure rules stay for a later return.")
(defparameter *stun-tolerance* 16.0 "The stun a form without :stun-tolerance takes; the hit past it is the blow-away.")
(defparameter *stun-delay* 45 "Frames after the last hit before the stun decays ...")
(defparameter *stun-decay* 6.0 "... at this many points per second (never at once: a re-pin loop with gaps still fills it).")
(defparameter *stun-blow-kb* 8.0 "The blow-away's knockdown :kb (x *AIR-SLIDE*: a ~5 m slide away from the attacker).")
(defparameter *hitstop-light* 4 "Global hitstop of Quick hits.")
(defparameter *hitstop-heavy* 8 "Global hitstop of every other hit.")
(defparameter *hitstop-breaker* 10 "Global hitstop of a Breaker hit / Guard Break / clash.")
(defparameter *hitstop-block* 3 "Global hitstop of a blocked, armoured or absorbed hit.")
(defparameter *super-flash* 6 "SP start: frames of the rim-light super flash...")
(defparameter *super-freeze* 4 "... and frames the opponent alone is frozen.")

;;; ---------------------------------------------------------------- arena, Burst Reverse
(defparameter *arena-radius* 15.0 "Circular arena; fighters are clamped inside (invisible wall).")
(defparameter *burst-min-hits* 2
  "Burst Reverse (mod + Quick, *FS-BURST* flash-step) only in hitstun / airborne after this many hits of
a combo (critique-design 1.7: not from hit 1).")
(defparameter *burst-invuln* 20 "Frames the Burst user stays invulnerable (he is neutral at once).")
(defparameter *burst-push* 5.0 "Burst pushes the attacker this far (no stun; his move ends) ...")
(defparameter *burst-push-frames* 20 "... over this many frames.")
(defparameter *burst-hitstop* 8 "Global hitstop of a Burst.")
;; the three burst modes (docs/duel/DUEL_DESIGN.md "Burst modes", the user 2026-09-30): the state at the press picks WHITE /
;; BLUE / ORANGE; every one needs *FS-BURST*, spends nothing up front and drains the flash-step gauge to 0
(defparameter *burst-drain* 54.0 "Flash-step per second a running burst drains (18 -> 54 with the 0-300 gauge: 300 -> 0 in 5.6 s, 200 in 3.7 s).")
(defparameter *white-reishi* 70.0 "WHITE (and the awakening's regen): Reishi regenerated per second (integer points; 12 -> 24 -> 70, the user
2026-09-30: a full-length run, 5.55 s, restores ~30 % of 1300).")
(defparameter *white-reiatsu* 15.0 "WHITE: Reiatsu per second on top of *REIATSU-REGEN*.")
(defparameter *white-awaken* 1.4 "WHITE: awakening gauge per second (2.0 x the slower gauge's 0.7).")
(defparameter *blue-gg-mult* 2.0 "BLUE: the guard gauge's normal refill rate x this (no delay) when not guarding ...")
(defparameter *blue-gg-guarding* 0.5 "... and x this even while guarding (GUARD HOLD stops it otherwise).")
(defparameter *chain-window* 12 "ORANGE: frames after the cancel in which the next move started has its startup cut ...")
(defparameter *chain-cut* 0.4 "... by this fraction (at least 1 f of startup left).")
(defparameter *orange-gain* 1.5 "ORANGE: Reiatsu from hits dealt and KOSEI, awakening from hits dealt, x this.")
(defparameter *kikon-fs-refund* 105.0 "A Kikon that connects (or a Soul Break: the user 2026-09-30) gives its user this flash-step (35 -> 105 with the
0-300 gauge) ...")
(defparameter *kikon-reiatsu-refund* 100.0 "... and this Reiatsu (one bar); after any burst ended.")

;;; ================================================================ §4 damage multipliers
(defparameter *hellfire-mult* 1.30 "Damage x in Hellfire (Gokuen).")
(defparameter *nozarashi-mult* 1.0 "Damage x in Nozarashi's first cup, KATATE (v2: x1.15 before the ladder).")
(defparameter *ryote-mult* 1.15 "Damage x in the second cup, RYOTE.")
(defparameter *nomihose-mult* 1.20 "Damage x in the third cup, NOMIHOSE.")
(defparameter *bankai-taken* 1.5
  "Damage x Bankai East takes (the defender's :taken): the extreme stance. The Bankai rework (the user's spec
2026-09-27, docs/duel/DUEL_YAMA_REWORK.md): 1.2 -> 1.5, East only (West takes x1.0). Not a tuning knob: the spec's value.")
(defparameter *east-gg-regen* 0.25
  "Bankai East's guard gauge refills at this x of everyone's rate (the user 2026-09-30, 「大幅降低山本『東 旭日刃』時的
防禦量表恢復速度」: x0.5, then 「破防後恢復速度不變，但東的恢復速度改成原本的 1/4」: 5.5 -> 1.375 / s; guardless
unchanged, 6.5; West never refills, so this is his whole refill).")
(defparameter *pierce-min* 0.1
  "Bankai East's pierce (passive :pierce, rules PIERCE-RATE): k = this at an empty guard gauge ...")
(defparameter *pierce-max* 0.45
  "... rising linearly to this at a full one (the user's decision 2026-09-27: full gauge = sharpest). A hit deals
x(1 + k); a blocked hit lets k x its damage through as chip (never kills). East's balance knob: the spec's 0.5 -> 0.45
at the seed gate (with *WARD-MULT* 1.1: YK Yamamoto 10 / 20, medians YY 128.6 / YK 129.9 s; at 0.5 / 1.0 the YK
median fell to 123.6 s).")
(defparameter *ward-mult* 1.1
  "Bankai West's ward (passive :ward): a hit it blocks drains this x its guard value (after Kenpachi's cut). The main YK
balance knob of the rework (replaces the x1.3 Bankai drain, deleted: the user's decision 2026-09-27); 1.0 -> 1.1 at
the seed gate (see *PIERCE-MAX*).")
(defparameter *mujittai-mult* 1.0
  "An intangible ward (passive :ward with :intangible, Lille's MUJITTAI, docs/duel/DUEL_LILLE.md §5.2): a hit that passes
through him drains this x its guard value (instead of *WARD-MULT*), with no push and no chip of any kind (design
2026-10-06; decisions 3-5, 14).")
(defparameter *cornered-per-konpaku* 0.05 "Cornered: + this damage fraction per Konpaku lost ...")
(defparameter *cornered-max* 0.25 "... up to this.")

;;; ================================================================ §5 form numbers (used by the kits)
(defparameter *inferno-max* 100.0 "Inferno (Goen) gauge; full -> Hellfire.")
(defparameter *inferno-flash* 20.0 "Inferno per Flash hit.")
(defparameter *inferno-sig* 15.0 "Inferno per Signature hit (the cuts and the wave).")
(defparameter *meter-on-block* 5.0 "Kit meter (Inferno) for a blocked hazard that gains meter on hit (wave, Shiranui).")
(defparameter *hellfire-seconds* 10.0 "Hellfire length (the Inferno bar drains over it).")
(defparameter *hellfire-burn* 0.05 "Hellfire burns this fraction of max Reishi per second (floor 1).")
(defparameter *ennetsu-damage* 60 "Ennetsu Jigoku (Hellfire entry) pillar damage per hit...")
(defparameter *ennetsu-hits* 2 "... at most this many hits ...")
(defparameter *ennetsu-self-burn* 30 "... and it burns the caster for this (floor 1).")
(defparameter *ennetsu-pillars* 7 "Pillars in the Ennetsu ring.")
(defparameter *ennetsu-seconds* 0.8 "Ennetsu duration.")
;;; Bankai stances (docs/duel/DUEL_YAMA_REWORK.md): East / West are kit forms; U switches East -> West, an attack other
;;; than SP1 / L drops West back to East
(defparameter *scorch* 15 "West (:scorch): a melee hit his parry catches burns the attacker this much (never kills; the parry also refills his
guard gauge: the rework).")
(defparameter *parry-window* '(2 25) "GOKUI GAESHI: the move frames (inclusive) its parry catches a melee hit (f2-25, KUSARI-TATE's
window: the user 2026-10-01; was f4-15) ...")
(defparameter *parry-stun* 32 "... the parried attacker staggers this long (his move ends) ...")
(defparameter *parry-slide* 0.5 "... sliding this far.")
(defparameter *bind-stun* 60 "South (the bind): frames the victim's feet are held. Pacing knob (design v3 §E): 60 -> 45.")
(defparameter *nozarashi-reach* 1.3 "Nozarashi KATATE (cup 1): reach x of the inherited moves (1.4 before the ladder).")
(defparameter *nozarashi-startup* 2 "Nozarashi KATATE (cup 1): extra startup frames of the inherited moves (3 before: F1->F2 was a 0 gap).")
(defparameter *ryote-reach* 1.4 "RYOTE (cup 2): reach x of the base moves it doesn't list.")
(defparameter *ryote-startup* 3 "RYOTE (cup 2): extra startup frames of the base moves it doesn't list.")
;;; Nozarashi v2, NOME (呑め): the three-cup ladder (docs/duel/DUEL_NOZARASHI_V2.md). The meter is the kit meter
;;; (GAUGES-METER); a rung is a kit form, changed only while he is free (ken-meter.lisp KEN-NOME-STEP)
(defparameter *nome-max* 100.0 "The NOME gauge.")
(defparameter *nome-gulp* 20.0 "NOMIHOSE's AS2 finisher (the drink, ken-gulp): NOME gained on its first frame, capped at the gauge (new 2026-10-30, the user: 「AS2 結尾自動飲，回 NOME」, DUEL_KEN_NOMIHOSE).")
(defparameter *nome-awaken* 10.0 "NOME at the awakening (cup 1).")
(defparameter *nome-dealt* 0.08 "NOME per point of damage he deals ...")
(defparameter *nome-taken* 0.12 "... per point he loses (a drink's taken half too, the stance's absorbed points) ...")
(defparameter *nome-drunk* 0.30 "... and per point drunk: a DRINK's swallowed half, all the stance absorbs. Knob: 0.30 -> 0.20.")
(defparameter *nome-delay* 180 "RYOTE drains only after this many frames without a gain (guard v3: 60 -> 180) ...")
(defparameter *nome-drain-t2* 3.0 "... at this per second (guard v3: 3.0 -> 1.5; the user 2026-09-29: faster, x2 -> 3.0) ...")
(defparameter *nome-drain-t3* 20.0 "... NOMIHOSE drains this per second, always (no delay; the user 2026-09-29: faster, x2, 10 -> 20).")
(defparameter *nome-up-t2* 40.0 "Up to RYOTE at this ...")
(defparameter *nome-down-t2* 25.0 "... back to KATATE below this ...")
(defparameter *nome-up-t3* 100.0 "... up to NOMIHOSE at this ...")
(defparameter *nome-down-t3* 50.0 "... back to RYOTE below this.")
(defparameter *nomihose-chip* 0.2 "NOMIHOSE: blade chip through guard.")
(defparameter *cut-mult* 1.5
  "The cut (RYOTE and NOMIHOSE, passive :cut): his blocked Flash / Signature / SP hits drain this x their guard value
(no gauge-paid armour is left for it to cut).")
(defparameter *drink-adv* 4 "DRINK (NOMIHOSE's U): a drunk melee hit leaves the attacker this many frames worse off than a block.")
(defparameter *rift-delay* 20 "KUKAN-GIRI: the rift it leaves cuts this many frames after its blade (f20 -> f40). Knob: 20 -> 18.")
(defparameter *stance-in* 6 "Stance Signature: frames to enter the stance (hit = counter-hit).")
(defparameter *stance-hold-max* 60 "Longest stance hold before the cut comes out by itself.")
(defparameter *stance-store-rate* 1.0 "Stance stores this x the damage it absorbs...")
(defparameter *stance-store-cap* 200 "... up to this.")
(defparameter *stance-base-damage* 100 "Stance cut damage before the stored bonus.")
(defparameter *stance-crush-at* 150 "Stored >= this: the cut crushes guard.")
;;; Kenpachi's Bankai and 片腕 KATAUDE (docs/duel/DUEL_KEN_BANKAI.md; the user's decisions 2026-09-28): a second awakening from
;;; cup 3, red, P; his own Konpaku -> 1 and his Reishi -> full on entry; the arm meter UDE (the kit meter, GAUGES-METER)
;;; spends a pip per heavy command; at 0 the arm bursts (then 片腕 for the rest of the match)
(defparameter *bankai-ken-mult* 1.2 "Damage x in Kenpachi's Bankai.")
(defparameter *bankai-konpaku* 4
  "Was: Kenpachi may enter his Bankai (P in cup 3) with at most this many of his own Konpaku left (the user's decision
2026-09-28, replacing the red-Reishi condition). Since 2026-10-31 the entry is a full SPIRIT DRIVE (DUEL_SUBLIMATION §3); this is
only the debug scene's cap.")
(defparameter *arm-pips* 4 "The arm meter UDE: pips at the Bankai's entry (the 4th spent: the arm bursts).")
(defparameter *arm-crack* 300 "A pip cracks by itself after this many frames without a spend (paused while locked): <= 20 s of Bankai.")
(defparameter *arm-self* 60
  "Reishi each spent pip burns (BURN: never below 1). The design's 30 against a red Kenpachi; x2 now that the entry refills
him to full (the user's decision 2026-09-28): the gate's knob.")
(defparameter *arm-burst-self* 120 "Reishi the burst burns (the design's 60, x2 with the full refill).")
(defparameter *arm-burst-stun* 40 "The burst's self-inflicted crumple, frames.")
(defparameter *kataude-reach* 0.7 "片腕 KATAUDE: reach x of his sword moves (the kick, the Breaker and O as written).")
;;; Kuchiki Rukia (docs/duel/DUEL_RUKIA.md): frost, the one new status, and the cold gauge of 絶対零度 (the awakened bands
;;; :m18 :m50 :zero; the kit meter holds the cold C, 0 .. *COLD-MAX*, two stacked bars: rukia-meter.lisp RUKIA-COLD-STEP)
(defparameter *walk-rukia* 3.8 "Rukia's walk (Shikai).")
(defparameter *rukia-mult* 0.75
  "Damage x of the Shikai (the base kit's :mult; 58000+k at run time). 1.0 -> 0.75, the user 2026-10-25: 「請在將露琪亞的基礎傷害量減少 25%」, every form x0.75, DUEL_RUKIA_TYBW §17.7; 1.5 -> 1.0, the user 2026-10-24 (「將露琪亞的數值
調回正常區間」, DUEL_RUKIA_TYBW §11: x1.5 put her JJJ / KKK 46-49 % over the roster's mean; the other six 1.0-1.6, mean 1.17,
three of them 1.0). Was the seed gate's lever: the CPU's Shikai fights the opponents' awakened forms for most of a match
(docs/duel/DUEL_RUKIA.md, Measurements) ...")
(defparameter *rukia-taken* 1.0 "... and the damage it takes x this (60000+k; 0.8 -> 1.0, the user 2026-10-24, §11: the six's mean 0.96).")
(defparameter *rukia-awake-mult* 0.825 "Damage x at -18 C (48000+k sets zero's, the colder-never-weaker lever; 1.1 -> 0.825, x0.75 as the Shikai's, 2026-10-25; 1.15 -> 1.1, the user 2026-10-24, §11) ...")
(defparameter *rukia-m50-mult* 0.9375 "... at -50 C (1.25 -> 0.9375, x0.75, 2026-10-25; 1.5 -> 1.25, the user 2026-10-24) ...")
(defparameter *rukia-zero-mult* 1.2375 "... and at absolute zero (melee and ranged alike; 1.65 -> 1.2375, x0.75, 2026-10-25).")
(defparameter *rukia-awake-taken* 0.95 "Damage taken x at -18 C (61000+k scales every band) ...")
(defparameter *rukia-m50-taken* 0.85 "... at -50 C (hardened) ...")
(defparameter *rukia-zero-taken* 0.8 "... and at absolute zero (a ranged hit passes the ward: optic).")
(defparameter *run-rukia* 9.0 "Rukia's run (Shikai).")
(defparameter *walk-m18* 3.4 "-18 C: walk ...")
(defparameter *run-m18* 8.0 "... and run.")
(defparameter *walk-m50* 2.8 "-50 C: walk ...")
(defparameter *run-m50* 6.4 "... and run. Absolute zero: rooted (0).")
(defparameter *frost-slow* 0.7 "Frost: a frosted fighter walks and runs x this (Step, Hoho, lunges, dashes and frames untouched).")
(defparameter *frost-cap* 150 "Frost: the timer never exceeds this (a hit sets it to max(current, n): it never stacks).")
(defparameter *frost-touch* 30 "-18 C: every real hit of hers frosts this long (the kit's :frost-touch; a hit window's own :frost wins if longer) ...")
(defparameter *frost-touch-m50* 60 "... at -50 C ...")
(defparameter *frost-touch-zero* 90 "... at absolute zero.")
(defparameter *ru-layer-max* 3
  "霜の層 (DUEL_RUKIA_TYBW §4.4): the cap of the frost layers her Shikai lays on him (new 2026-10-24, the user).")
(defparameter *ru-chill-per* 2
  "冰凍值 points a 霜の層 takes (new 2026-10-24, the user: a K hit 1 point, two points a layer; 霜陣 a point a 30 f).")
(defparameter *ru-thaw* 150
  "霜の層: one layer thaws per this many frames without a new layer (a J hit of hers holds the timer; new 2026-10-24, the
user: §4.4's 150 f, the old frost cap).")
(defparameter *ru-layer-slow* '(1.0 0.85 0.70 0.55)
  "霜の層: his walk / run x this by layers 0-3 (Step, Hoho, dashes, frames untouched; new 2026-10-24, the user, §4.4).")
(defparameter *cold-max* 200.0 "The cold gauge: two stacked bars of *COLD-BAR* (the user's decision 2026-09-28).")
(defparameter *cold-bar* 100.0
  "One bar of cold. -18 -> -50 when C reaches it, -50 -> -18 when C falls to 0; -50 -> zero when C reaches *COLD-MAX*,
zero -> -50 when C falls to it (rules TEMP-BAND).")
(defparameter *ru-cool-rate* 90.0
  "Cold per second while she guards (the GUARD HOLD test; bracing at zero): a bar in 1.1 s, -18 -> zero in 2.2 s (the
user's decision 2026-09-28: cool faster; the design's pacing was 3.3 s; 46000+k).")
(defparameter *ru-block-cool* 1.5 "A blocked melee hit cools her this x its guard value (x1.5 with the faster cooling; 62000+k: x0.01).")
(defparameter *ru-hit-warm* 0.2 "A real hit taken warms her this x its damage (63000+k: x0.01).")
(defparameter *ru-warm-m18* 10.0 "Warming, cold per second while she isn't guarding, at -18 C (a full bar: 10 s) ...")
(defparameter *ru-warm-m50* 12.0 "... at -50 C (a bar: 8.3 s) ...")
(defparameter *ru-warm-zero* 5.0
  "... at absolute zero, the slowest (the user's decision 2026-09-28: zero is easier to hold; half of -18's; unbraced 20 s
to warm the top bar away; 55000+k).")
(defparameter *ru-cold-m18* '(:sig 25)
  "Cold each command spends at -18 C (the user's decision: only L; refused below its cost) ...")
(defparameter *ru-cold-m50* '(:q 6 :f 12 :sig 36 :sp1 40 :sp2 40 :kikon 20 :breaker 20 :step 12) "... at -50 C (a Hoho adds cold: rukia.lisp *RU-HOHO-COLD*) ...")
(defparameter *ru-cold-zero* '(:q 20 :f 40 :sig 100 :sp1 100 :sp2 100 :kikon 60)
  "... and at absolute zero (L and the SPs cash the whole top bar: she drops to -50; J / K / O 15 / 30 / 50 -> 20 / 40 / 60
with the faster cooling: the A/B).")
(defparameter *ru-field-m18* '(:r 3.0 :away 0.85 :step 1.0)
  "The cold field 寒域 at -18 C: within :r m of her the opponent walks / runs away from her x :away, his away Step x :step ...")
(defparameter *ru-field-m50* '(:r 4.0 :away 0.7 :step 0.9) "... at -50 C ...")
(defparameter *ru-field-zero* '(:r 5.5 :away 0.55 :step 0.75) "... at absolute zero (65000+k: :away x0.01).")
(defparameter *field-floor* 0.45 "The field x frost never slows the away walk below this (66000+k: x0.01).")
(defparameter *zero-brace-drain* 8.0 "Absolute zero: bracing (U held) stops the warming but drains the guard gauge this per second (44000+k).")
(defparameter *ru-thaw-lock* 120 "After a CRACK her guard doesn't cool for this many frames (51000+f).")
(defparameter *crack-self* 60 "The CRACK (the ward crushed or broken at zero) burns this much (never below 1) ...")
(defparameter *crack-stun* 30 "... and crumples her in place this long when she isn't in a reaction already.")
(defparameter *freeze-touch* 18 "Absolute zero: the first melee hit the ward blocks freezes its attacker this long (once per zero visit; the
design's 24 -> 18: the A/B).")
;;; hazard shapes and timing (hazards.lisp)
(defparameter *hazard-rehit* 16 "Frames a multi-hit hazard (pillars) waits between two hits.")
(defparameter *wave-box* '(1.2 0.5) "Fire wave box: half-height, half-length (half-width = its :width / 2).")
(defparameter *pillar-size* '(0.7 5.0) "Ennetsu pillar cylinder: radius, height.")
(defparameter *pillar-window* '(6 8) "Pillars hit from this many frames after they erupt until this many before they end.")

;;; ================================================================ §8 CPU AI
(defparameter *ai-delay* '(:easy 24 :normal 14 :hard 8) "Perception delay (frames) per difficulty.")
(defparameter *ai-repick* 12 "Frames between intent re-picks.")
(defparameter *ai-aggression* '(:pressure 0.45 :approach 0.3 :zone 0.5 :defend 0.1)
  "Chance a neutral decision is an attack, per intent (+ 0.04 per heat point, at most 0.9).")
(defparameter *ai-respect* 120 "Frames a CPU stays in DEFEND after a reaction / blockstun ends.")
(defparameter *ai-think* '(:easy 56 :normal 40 :hard 20)
  "Frames (+ 0..40 random) between two neutral decisions (attack / guard / wait): the CPU's tempo.")
(defparameter *ai-guard-hold* '(14 20) "A neutral guard is held this + 0..that frames.")
(defparameter *ai-strafe-time* '(40 80) "The strafe direction is re-rolled every this + 0..that frames.")
(defparameter *ai-punish-adv* -8 "Punish a recovering opponent whose advantage is at or below this.")
(defparameter *ai-block-punish-p* '(:easy 0.25 :normal 0.6 :hard 0.9)
  "Chance the CPU punishes, with Q1, a blocked move whose block advantage is <= *AI-PUNISH-ADV*. It
feels its own blockstun (no perception delay), so this is the only thing that decides it.")
(defparameter *ai-string-flash-p* 0.3
  "On hit, a string that can go on with J or K takes K this often (the design's 0.5; 0.3 at the seed gate: K links
are the heavy ones).")
(defparameter *ai-o-ender* 0.15
  "The O ender (a completed string: a link-3 hit) on an opponent who isn't red, per string: a kit's :o-ender, else
this (on a red one always). A pacing knob of the seed gate (docs/duel/DUEL_STRINGS.md §4, §6, §9: the design's 0.35 -> 0.15).")
(defparameter *ai-ru-l-after-k* 0.05
  "The CPU's L after a K link that hit, per hit (a kit's :ai :l-after-k; Rukia's Shikai, docs/duel/DUEL_STRINGS.md §12). A
pacing knob of the seed gate (debug 72000+k sets it to k / 100).")
(defparameter *ai-ru-l-after-k-awake* 0.1
  "The same in her awakened bands (the awaken A/B's knob: debug 73000+k sets it to k / 100).")
(defparameter *ai-follow-guard-p* '(:easy 0.6 :normal 0.85 :hard 0.95)
  "A CPU who isn't red guards a Kikon rush's dash-in follow-up with this chance (the B1 knob: DUEL_STRINGS §6).")
(defparameter *ai-j-beats-k-p* '(:easy 0.2 :normal 0.45 :hard 0.7)
  "J beats K: an opponent's K link still >= S(J1) + 2 frames from its hit, within J1's reach: J1 with this chance.")
(defparameter *ai-mash-window* 120 "J mashing (the user 2026-10-02): his J starts seen within this many frames ...")
(defparameter *ai-mash-starts* 4 "... at least this many (a J string is 3): he mashes J (AI-MASH-P).")
(defparameter *ai-anti-mash-j-p* 0.9 "Against a J masher, J out of his blocked J with this chance (else *AI-J-BEATS-K-P*) ...")
(defparameter *ai-anti-mash-hoho* 0.5 "... and Hoho his coming J with at least this chance (2 x the kit's :hoho, at least this).")
(defparameter *ai-sp-cancel-p* 0.3
  "A string that ends on a hit with no link left (link 3, or a link the CPU doesn't go on from) is cancelled into SP2
with this chance, one roll (the kit's :sp-cancel-bars permitting). Link 3 staggers / crumples, so SP2 always combos
off it (Kenpachi's flurry): a seed-gate pacing knob (docs/duel/DUEL_STRINGS.md §9).")
(defparameter *ai-block-k-p* 0.15
  "On block a string goes on with a K link only this x the kit's :block-string (a J link otherwise; never a K ender).")
(defparameter *ai-kosei-aggression* 0.2
  "KOSEI: a neutral decision attacks + this x (1 - its own guard gauge / max) more often.")
(defparameter *ai-guard-break-hold* 24 "Breaker a guard held longer than this (0.4 s) ...")
(defparameter *ai-guard-break-range* 3.0 "... within this range ...")
(defparameter *ai-guard-break-p* 0.4 "... with this probability.")
(defparameter *ai-anti-breaker-p* '(:easy 0.4 :normal 0.55 :hard 0.7) "Answer an incoming Breaker aura.")
(defparameter *ai-anti-breaker-range* 5.0 "... seen within this range: Hoho (a bar), Q1 beyond ...")
(defparameter *ai-anti-breaker-q* 1.8 "... this range, else a sideways Step (a Kikon rush).")
(defparameter *ai-anti-breaker-j* 1.4
  "A Breaker's dash: J1 once it is within J1's reach + this (J beats I, docs/duel/DUEL_STRINGS.md §14: the dash covers ~1.2-1.5 m
in J1's startup, so J1's active frames meet it inside J1's reach).")
(defparameter *ai-react-p* 0.7 "Chance of a kit :react answer (Kenpachi's stance) to what triggers it.")
(defparameter *ai-threat-margin* 1.5 "A committed opponent move is a threat within its reach + this.")
;; :x-axis lines (docs/duel/DUEL_LILLE.md §11.3, gap G1; docs/duel/DUEL_AI_V2.md ":x-axis lines"; new 2026-10-06, the Lille
;; Barro build the user asked for): inert for every move without :x-axis
(defparameter *ai-line-margin* 0.3
  "An :x-axis line is a threat to a CPU whose feet are within its radius + his hurt radius + this of the line (the
perceived muzzle along the perceived yaw), at any distance (its 31 m reach would make a distance test true everywhere).")
(defparameter *ai-opp-diff* '(:easy 0.3333 :normal 1.0 :hard 1.6667)
  "A chance read off the opponent's kit (:opp-aim, :opp-reflect) x this by difficulty, at most 1 (OPP-CHANCE: :opp-reflect
0.3 -> EASY 0.1 / NORMAL 0.3 / HARD 0.5, DUEL_LILLE §11.3).")
(defparameter *ai-aim-react* 8
  ":opp-aim: a CPU whose perception delay is at most this (HARD's 8) Steps on the lock it perceives; a slower one pre-Steps
at a rolled frame lock .. lock + *AI-AIM-PRE-STEP* (it would see the lock too late: the shot comes >= 10 f after it).")
(defparameter *ai-aim-pre-step* 10 "... the pre-Step's latest frame after the lock (rolled 0 .. this, once per aim).")
(defparameter *ai-reflect-guard-lead* 8
  ":opp-reflect: the guard is pressed this many frames before the blast (his move frame as perceived: SNAP-SF + the delay),
so FIGHTER-GUARD-T is 2-10 there (DUEL_LILLE §6.3: a guard started f50-f58 against the f60 blast).")
(defparameter *ai-reflect-hoho-lead* 10
  "... or, guard unavailable (a ward, a form whose U is a move, guardless), the Hoho this many before (f50: f48-f60 reflect).")
(defparameter *ai-reflect-quiet* 6
  "... and in this many frames before the press it presses nothing (a guard held from before is let go: the new press
must count FIGHTER-GUARD-T from 0).")
(defparameter *ai-projectile-range* 7.0 "An incoming projectile is 'seen' within this range.")
(defparameter *ai-heat-rate* 1.5 "Heat per second without dealing damage (reset by dealing any).")
(defparameter *ai-heat-far* 6.0 "Beyond this distance heat rises twice as fast (two zoners staring).")
(defparameter *ai-heat-range* 0.3 "Preferred range shrinks this much per heat point ...")
(defparameter *ai-min-range* 1.0 "... but never below this.")
(defparameter *ai-heat-breaker* 8.0 "At this heat the Breaker weight doubles.")
(defparameter *ai-burst-p* '(:easy 0.2 :normal 0.6 :hard 0.85)
  "Chance (one roll per combo) the CPU bursts once it is worth it (AI-BURST-WANTED-P), no sooner
than its perception delay after the combo's *BURST-MIN-HITS*th hit.")
(defparameter *ai-burst-low* 0.5 "Burst is worth it below this fraction of Reishi ...")
(defparameter *ai-orange-p* '(:easy 0.1 :normal 0.25 :hard 0.4)
  "Chance a CPU whose string hit and can't go on (no further link) CHAIN-REVERSEs (ORANGE) and restarts it with Q1.")
(defparameter *ai-white-p* 0.3 "(0.15 -> 0.3 and 6 -> 5 m, the user 2026-09-30: use WHITE more) Chance per neutral decision a CPU behind on Reishi SOUL-REVERSEs (WHITE) ...")
(defparameter *ai-white-behind* 0.15 "... behind by at least this fraction of its max Reishi ...")
(defparameter *ai-white-range* 5.0 "... and at least this far (m) from him.")
(defparameter *ai-sb-finish* 0.08
  "Under this fraction of his max Reishi the CPU finishes with hits (the Soul Break: the Kikon count + 1), no Kikon rush\n(2026-09-30, the base AI learning the newer rules; AI-SB-FINISH-P).")
(defparameter *ai-dash-gap* 2.5
  "The CPU dashes (the kit's :dash / :dash-back chance, at a neutral decision) when it stands this
far outside its preferred range: toward it from beyond, away from it from inside; it lets go in the
middle of the range.")
(defparameter *ai-dash-frames* 70 "Longest the CPU holds a dash.")
(defparameter *ai-wake-guard-p* '(:easy 0.25 :normal 0.4 :hard 0.85)
  "Out of a hit (the user 2026-10-02: a CPU caught by J strings had no way out but a burst): on its first free step
after a reaction or a wake-up, with him within *AI-WAKE-GUARD-RANGE*, the CPU holds Guard *AI-WAKE-GUARD-FRAMES* with
this chance (x its guard gauge's AI-GUARD-MULT), not waiting to see his next move (his J1 is faster than its perception
delay); the rest of the time it Hohos or Steps aside half the time (AI-WAKE-STEP).")
(defparameter *ai-gap-step-p* '(:easy 0.2 :normal 0.5 :hard 0.75)
  "Out of blocking a J masher's J that still recovers beyond our J1's reach: back-Step with this chance (AI-GAP-STEP-P).")
(defparameter *ai-step-in-p* '(:easy 0.05 :normal 0.12 :hard 0.25)
  "Step -> J (the user 2026-10-02): at a neutral decision where a forward Step lands within J1's reach, Step in with this
chance (AI-DECIDE) ...")
(defparameter *ai-step-j-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "... and out of any Step of ours that lands him within J1's reach + *AI-STEP-J-MARGIN* (he isn't mid-attack), J at
Step f10 with this chance (the latch starts J1 at *STEP-J-CANCEL*; AI-REFLEX).")
(defparameter *ai-step-j-margin* 0.1 "(J1's own lunge closes a little more.)")
(defparameter *ai-wake-guard-frames* 20 "... held this long (his restarted string comes in it; then J out of it: J-BEATS-K-P).")
(defparameter *ai-wake-guard-range* 3.0 "... when he is within this many metres (as perceived).")
(defparameter *ai-hold-guard* '(:easy 0.97 :normal 0.92 :hard 0.8)
  "In blockstun a CPU keeps holding Guard through the string with this chance per blocked hit, whatever its
guard gauge (turtling mid-string is what a Guard Crush punishes): the easier CPU turtles and gets crushed,
the harder one steps out. (Its neutral guard choice still shrinks with the gauge: AI-GUARD-MULT.)")
(defparameter *ai-kikon-p* 0.5
  "The CPU rushes a red opponent within its kit's :kikon-range (a stunned one at once) with this chance
per neutral decision; one who isn't red only as a poke (the kit's :moves bands).")

;;; ================================================================ §14 budgets
(defparameter *fire-density* 1.0 "Scales every fire emitter's rate (0.5 if the perf gate fails).")

;;; ---------------------------------------------------------------- the core system (docs/duel/DUEL_CORE.md, 2026-10-27)
(defparameter *core-clash-slowmo-scale* 0.2 "Time scale of the slow motion on a cancel (the triangle's mutual no-damage clash): a beat to read the next move
(the user, 2026-10-27: 「抵消的瞬間要有慢動作讓人有一瞬間能思考接下來的行動」; the perfect Hoho's is 0.25).")
(defparameter *core-clash-slowmo-seconds* 0.7 "Real seconds of that slow motion (the last 0.1 s eases back to full speed).")
(defparameter *core-kikon-confirm* 12
  "Frames of a held SP's dash-in (phase :follow, after the hitstop) the button must still be down for: a let-go inside them drops
the Kikon, both back to neutral (CORE-FOLLOW-STEP). 0 -> 12, 2026-10-28, the user: 「把毀魂技的按住判定時間拉長」 (asked which way,
「打中後要多按住幾幀」; the frames left to me). Before, only the hit frame was judged.")
(defparameter *core-damage* 0.42
  "x every hit of a fighter whose kit has a :core (KIT-ATK-MODS). The first core build ended matches in ~55 s median (Ichigo mirror 43 s,
KI 61 s, HK 57 s; target 125-210 s): the pointer-3 Soul Break takes up to 5 of 9 Konpaku, so the Reishi (1300) is the pace. 1.0 before.")
(defvar *core-on* t "NIL: KIT-ATK-MODS leaves the core system's damage scale (*CORE-DAMAGE* x the kit's :core :mult) out (the host tests of the old damage numbers).")
