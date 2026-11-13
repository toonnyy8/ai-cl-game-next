;;;; tuning.lisp — SOUL DUEL's balance knobs in one place (design-v1 §1–§4, §8, §14). Change a
;;;; number here and rebuild; nothing else needs to know. Units: frames are 60 Hz fixed steps,
;;;; distances metres, speeds m/s, angles degrees, Reishi integer points, fractions 0..1.
;;;; Per-move frame data (startup, damage, block advantage) lives with the moves (ken.lisp,
;;;; ichigo.lisp, hisagi.lisp); a kit may also name a knob here by symbol (:mult *bankai-ken-mult*): kit.lisp
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
(defparameter *walk-kenpachi* 4.4 "Kenpachi's walk / strafe speed.")
(defparameter *step-distance* 2.5 "Step hop length (stick direction; neutral = back).")
(defparameter *step-frames* 24 "Step total frames.")
(defparameter *step-iframes* '(3 9) "Step invulnerable frames, inclusive.")
(defparameter *step-j-cancel* 12
  "From this Step frame (the hop's slide is over) J cancels the rest of the Step into J1 (the user, 2026-10-02).")
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

;;; ---------------------------------------------------------------- the combo bonus on hit gains
;;; (The Reiatsu gauge's knobs left 2026-11-13, REFACTOR_2026-11 R6: *REIATSU-MAX* 300, *REIATSU-BAR* 100, *REIATSU-REGEN* 3 / s,
;;; *REIATSU-KIND*, *REIATSU-KIND-OTHER* 4, *REIATSU-TAKEN* 0.15, *COST-SP* 1, *COST-SP-AWAKENED* 2, *KOSEI-REIATSU* 0.20,
;;; *WHITE-REIATSU* 15, *KIKON-REIATSU-REFUND* 100, *RESET-REIATSU-BONUS* 10: no SP had spent the gauge since the core system,
;;; 2026-10-27, DUEL_CORE §6.)
(defparameter *combo-gain-step* 0.1
  "The combo bonus on hit gains (the flash-step of damage taken, KOSEI's points): x(1 + this x (n - 1)) at the combo's nth hit
(its HIT-DAMAGE index) ... (the user 2026-10-26: 「每多一下 +10%，上限 ×2」; named *REIATSU-COMBO-STEP* until 2026-11-13, R6)")
(defparameter *combo-gain-max* 2.0 "... at most this (the 11th hit on; *REIATSU-COMBO-MAX* until 2026-11-13).")

;;; ---------------------------------------------------------------- flash-step gauge (design v3 G.1): Hoho, Burst
;; (the gauge x3, the user 2026-10-29: 「幫我將閃步量表改成 0-300，並且將 hoho 消費改成 100，爆氣設為 200，其他恢復量也做對應的提昇」; DUEL_DESIGN "Flash-step gauge 0-300", DEVLOG §504: the max, every gain and the drain x3,
;; the Hoho 30 -> 100 and the burst 70 -> 200 as asked, so a Hoho is 1/3 of the gauge (was 0.3) and a burst 2/3 (was 0.7))
(defparameter *fs-max* 300.0 "Flash-step gauge maximum (100 -> 300); full at the match start, kept through Kikon resets.")
(defparameter *fs-hoho* 100.0 "Flash-step a Hoho costs (30 -> 100).")
(defparameter *steal-fs-gain* 0.5
  "Share of the flash-step a stealing AS (:steal-fs, per hit) takes that the attacker gains (the victim loses all of it). New 2026-11-12, the
user: 「不限制吸取上限，然後吸取的轉換率設為 50%」 (this replaced a per-use cap of 100, `*steal-fs-max*`, 2026-11-12, 「當前角色吸取對手閃步量表的能力改成最多削減一格的量」, removed the same day).")
(defparameter *fs-cell* 100.0
  "One cell of the flash-step gauge (the HUD's three cells; the Hoho's price). New 2026-11-12, the user's SP design (DUEL_SP §2): the last cell is never taken by a steal (`steal-take`, S1 2026-11-13) and regen stops at one cell (`fs-regen`); the literal 100 lived in `*fs-hoho*` and lhud-deck's `+fs-burst+`.")
(defparameter *sp-cost-rate* 0.4
  "SP an NS / AS segment costs per point of its damage (cost = damage x this x the kit's multiplier, rounded to 5, clamped `*sp-cost-min*` .. `*sp-cost-max*`). New 2026-11-12, the user: 「依據每段 NS 的強度調整消耗量」 (DUEL_SP §3-§4).")
(defparameter *sp-cost-min* 10.0 "Cheapest SP segment (also a setup segment with no damage). New 2026-11-12, the user's SP design, DUEL_SP §4.")
(defparameter *sp-cost-max* 60.0 "Dearest SP segment. New 2026-11-12, the user's SP design, DUEL_SP §4.")
(defparameter *sp-gain-j* 10.0 "SP a J hit (each damaging hit window) earns. New 2026-11-12, the user: 「J 命中 +10」, DUEL_SP §5, §8.6 Q3.")
(defparameter *sp-gain-sa* 15.0 "SP an SA hit (each damaging hit window) earns. New 2026-11-12, the user's SP design, DUEL_SP §5.")
(defparameter *sp-gain-cancel* 30.0 "SP an ATK (J / SA) that takes part in a cancel earns, instead of its hit gain. New 2026-11-12, the user's SP design, DUEL_SP §5.")
(defparameter *sp-break-share* 1.0
  "Share of the victim's flash-step above the last cell a breakthrough after a cancel takes. New 2026-11-12 at 0.5 (the lead read the user's
「50%」 as the share taken); 0.5 -> 1.0 on 2026-11-13, the user: 「這邊是要奪取第一格以上的全部，並以 50% 效率轉換成自身量表」 (the 50 % is the
conversion, *SP-BREAK-GAIN*), DUEL_SP §6.")
(defparameter *sp-break-gain* 0.5 "Share of a breakthrough's take the attacker gains (the victim loses all of it). New 2026-11-12, the user's SP design, DUEL_SP §6.")
(defparameter *fs-burst* 100.0 "Flash-step every burst mode needs to start (70 -> 200: two of the HUD's three cells; 200 -> 100 on 2026-11-13, S1 of DUEL_SP §2, the user: 「三色爆氣皆改成一格可放」; the drain is the cost).")
(defparameter *fs-regen* 4.5 "Flash-step per second (3 -> 9 -> 4.5: 2026-11-12, the user: 「閃步量表的自然恢復速度減半」; a Hoho from empty in 23.2 s) ...")
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
;; Since 2026-11-01 (DUEL_SUBLIMATION §18) only attacking fills SUBLIMATION and DRIVE: damage dealt, Konpaku taken, a WHITE Burst.
(defparameter *sub-max* 100.0 "SUBLIMATION gauge maximum (filled by attacking once the awakening gauge is full).")
(defparameter *sub-attack-mult* 1.5
  "SUBLIMATION / SPIRIT DRIVE per point of damage dealt = *AWAKEN-DEALT* x this (x ORANGE's gain): 0.0525, about 1905 damage to fill (the
user, 2026-11-01: 「幫我將 3 倍改成 1.5 倍」, DUEL_SUBLIMATION §18.1; 3.0 (0.105, about 950) from 「×3（約 950 點滿）」 the same day, §18; before, x1.0 of every awakening source, damage taken and lost Konpaku included).")
(defparameter *sub-gain* 1.0
  "Every SUBLIMATION / SPIRIT DRIVE gain x this (AWAKEN-OVERFLOW: damage dealt, Konpaku taken, WHITE's; the awakening gauge itself
unchanged): 1.0 -> 2.0 (the user, 2026-11-07: 「並幫我將 sublimation 跟 drive 的累積速度改成目前的 2 倍」, DUEL_SUBLIMATION §20 / DEVLOG §616):
about 952 damage dealt fills one. 2.0 -> 1.0 (the user, 2026-11-12: 「還要把 DRIVE 跟 SUBLIMATION 的恢復速率減半。」, DUEL_SP §3, S6; the one knob halves both gauges' fill):
about 1905 damage dealt fills one again.")
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
(defparameter *roll-distance* 4.0
  "A wake-up roll's slide (m): the stick held as :down ends rolls him this far that way, still invulnerable, still *REACTION-FRAMES*'
:wakeup long (Step 2.5). New 2026-11-07 (the user: 「如果被打倒後起身時有按下方向鍵，請對該方向增加翻滾拉開距離」; DEVLOG §614).")
(defparameter *roll-frames* 20 "... over this many frames; the rest of the wake-up turns him to face the opponent.")
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
(defparameter *blue-burn* 100.0 "BLUE burns only this much flash-step (one HUD cell, = *FS-HOHO*) at *BURST-DRAIN*, then the burst ends and the rest of the
gauge is kept; a Hoho in it spends what is left of it (BURST-BURN, HOHO-COST). New 2026-11-12 (the user: 「將藍色爆氣改成只燃燒一格的量，期間發動閃步就將那燃燒中的格子用完，不會消耗到其他的閃步量表」); WHITE / ORANGE still drain to 0.
Before: BLUE drained the whole gauge like them (300 -> 0 in 5.6 s).")
(defparameter *white-reishi* 70.0 "WHITE (and the awakening's regen): Reishi regenerated per second (integer points; 12 -> 24 -> 70, the user
2026-09-30: a full-length run, 5.55 s, restores ~30 % of 1300).")
(defparameter *white-awaken* 1.4 "WHITE: awakening gauge per second (2.0 x the slower gauge's 0.7).")
(defparameter *blue-gg-mult* 2.0 "BLUE: the guard gauge's normal refill rate x this (no delay) when not guarding ...")
(defparameter *blue-gg-guarding* 0.5 "... and x this even while guarding (GUARD HOLD stops it otherwise).")
(defparameter *chain-window* 12 "ORANGE: frames after the cancel in which the next move started has its startup cut ...")
(defparameter *chain-cut* 0.4 "... by this fraction (at least 1 f of startup left).")
(defparameter *orange-gain* 1.5 "ORANGE: awakening (and SUBLIMATION / SPIRIT DRIVE) from hits dealt x this (its Reiatsu from hits dealt and KOSEI
left with the gauge, 2026-11-13, R6).")
(defparameter *kikon-fs-refund* 105.0 "A Kikon that connects (or a Soul Break: the user 2026-09-30) gives its user this flash-step (35 -> 105 with the
0-300 gauge), after any burst ended (and a Reiatsu bar until the gauge left, 2026-11-13, R6).")

;;; ================================================================ §4 damage multipliers
(defparameter *nozarashi-mult* 1.0 "Damage x in Nozarashi's first cup, KATATE (v2: x1.15 before the ladder).")
(defparameter *cornered-per-konpaku* 0.05 "Cornered: + this damage fraction per Konpaku lost ...")
(defparameter *cornered-max* 0.25 "... up to this.")

;;; ================================================================ §5 form numbers (used by the kits)
(defparameter *hellfire-burn* 0.05 "Hellfire burns this fraction of max Reishi per second (floor 1).")
;;; the parry (a :parry move's window)
(defparameter *parry-window* '(2 25) "GOKUI GAESHI: the move frames (inclusive) its parry catches a melee hit (f2-25, KUSARI-TATE's
window: the user 2026-10-01; was f4-15) ...")
(defparameter *parry-stun* 32 "... the parried attacker staggers this long (his move ends) ...")
(defparameter *parry-slide* 0.5 "... sliding this far.")
;;; Kenpachi's cadence by form (the user, 2026-11-02, DUEL_KEN_CORE §7.2): the startup of every NS first segment that hits
;;; (kit :open-s) = the weapon's weight (the katana lightest, the Bankai's one-hand axe next, the Shikai's cleaver heaviest:
;;; base 14 / 18 / 22), faster for two hands (-3) and for a fiercer form (up to -3), never under 14.
(defparameter *ken-hs-dmg* '(4 30 10 4 14)
  "Kenpachi's hitstop by damage (kit :hs-dmg, base zero per lo hi): 4 + (damage - 30) / 10 rounded, 4 .. 14 frames (the user,
2026-11-02: 「依傷害大小縮放」). Was 4 for a J / SA, 8 for every other hit.")
;;; Nozarashi v2, NOME (呑め): the three-cup ladder (docs/duel/DUEL_NOZARASHI_V2.md). The meter is the kit meter
;;; (GAUGES-METER); a rung is a kit form, changed only while he is free (ken-meter.lisp KEN-NOME-STEP)
(defparameter *stance-in* 6 "Stance Signature: frames to enter the stance (hit = counter-hit).")
(defparameter *stance-hold-max* 60 "Longest stance hold before the cut comes out by itself.")
(defparameter *stance-store-rate* 1.0 "Stance stores this x the damage it absorbs...")
(defparameter *stance-store-cap* 200 "... up to this.")
(defparameter *stance-base-damage* 100 "Stance cut damage before the stored bonus.")
(defparameter *stance-crush-at* 150 "Stored >= this: the cut crushes guard.")
;;; Kenpachi's Bankai (DUEL_KEN_V3 §26: the Shikai's burst AS; the arm meter UDE and 片腕 KATAUDE left with V3)
(defparameter *bankai-ken-mult* 1.2 "Damage x in Kenpachi's Bankai.")
(defparameter *bankai-konpaku* 4
  "Was: Kenpachi may enter his Bankai (P in cup 3) with at most this many of his own Konpaku left (the user's decision
2026-09-28, replacing the red-Reishi condition). Since 2026-10-31 the entry is a full SPIRIT DRIVE (DUEL_SUBLIMATION §3); this is
only the debug scene's cap.")
;;; hazard shapes and timing (hazards.lisp)
(defparameter *hazard-rehit* 16 "Frames a multi-hit hazard waits between two hits.")
(defparameter *wave-box* '(1.2 0.5) "A wave's box: half-height, half-length (half-width = its :width / 2).")

;;; ================================================================ §8 CPU AI
(defparameter *ai-delay* '(:easy 24 :normal 14 :hard 8) "Perception delay (frames) per difficulty.")
(defparameter *ai-strafe-time* '(40 80) "The strafe direction is re-rolled every this + 0..that frames.")
(defparameter *ai-mash-window* 120 "J mashing (the user 2026-10-02): his J starts seen within this many frames ...")
(defparameter *ai-mash-starts* 4 "... at least this many (a J string is 3): he mashes J (AI-MASH-P).")
(defparameter *ai-burst-low* 0.5 "Burst is worth it below this fraction of Reishi ...")
(defparameter *ai-dash-frames* 70 "Longest the CPU holds a dash.")

;;; ================================================================ §14 budgets
(defparameter *fire-density* 1.0 "Scales every fire emitter's rate (0.5 if the perf gate fails).")

;;; ---------------------------------------------------------------- the core system (docs/duel/DUEL_CORE.md, 2026-10-27)
(defparameter *core-clash-slowmo-scale* 0.2 "Time scale of the slow motion on a cancel (the triangle's mutual no-damage clash): a beat to read the next move
(the user, 2026-10-27: 「抵消的瞬間要有慢動作讓人有一瞬間能思考接下來的行動」; the perfect Hoho's is 0.25).")
(defparameter *core-clash-slowmo-seconds* 0.7 "Real seconds of that slow motion (the last 0.1 s eases back to full speed).")
(defparameter *core-kikon-confirm* 12
  "Frames of a held SP's dash-in (phase :follow, after the hitstop) the button must still be down for: a let-go inside them drops
the Kikon, both back to neutral (CORE-FOLLOW-STEP). 0 -> 12, 2026-10-28, the user: 「把毀魂技的按住判定時間拉長」 (asked which way,
「打中後要多按住幾幀」; the frames left to me). Before, only the hit frame was judged. Since 2026-11-04 the hit stays an ordinary one
for these frames, the Kikon's knockback and dash-in start once they pass (CORE-KIKON-DEFER; the user: 「就算沒觸發毀魂技有時候也會將對手彈開」,
asked: 「確認後才擊退」).")
(defparameter *kikon-air-hold* 4
  "Frames past *CORE-KIKON-CONFIRM* that a held SP's knockdown / launch keeps the victim on his feet in a stagger instead (APPLY-HIT),
so the Kikon's strike can still reach him (in the air he lands and is down, unhittable, before it); a let-go inside the confirm gives
the knockdown then (CORE-KIKON-UNDO!). New 2026-11-05 (DUEL_KEN_V3 §39: the sealed AS1 / AS2's Kikon never landed).")
(defparameter *core-kikon-confirm-touch* :dash
  "The phone's confirm (ONE-HAND's P1): :DASH = the whole dash-in, to the frame the follow-up strike starts (KIKON-FOLLOW-WAIT of
the SP's startup: 41 - S, 19-27 frames), so a hold must stay down 27-35 frames (0.45-0.58 s) after the hit, not 20 (0.33 s); or a
frame count. 12 -> :dash, 2026-11-04, the user: 「目前手持模式很容易誤觸毀魂技，請延長啟動觸發的判定」 (DUEL_CORE §4).")
(defparameter *core-damage* 0.42
  "x every hit of a fighter whose kit has a :core (KIT-ATK-MODS). The first core build ended matches in ~55 s median (Ichigo mirror 43 s,
KI 61 s, HK 57 s; target 125-210 s): the pointer-3 Soul Break takes up to 5 of 9 Konpaku, so the Reishi (1300) is the pace. 1.0 before.")
(defvar *core-on* t "NIL: KIT-ATK-MODS leaves the core system's damage scale (*CORE-DAMAGE* x the kit's :core :mult) out (the host tests of the old damage numbers).")
