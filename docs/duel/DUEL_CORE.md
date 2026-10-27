# DUEL_CORE — the simplified core system (the "triangle" rework)

Decided with the user on 2026-10-27 (a grilling session; DEVLOG §410). The source design is the user's own note,
[`DUEL_CORE_DOC.zh-TW.md`](DUEL_CORE_DOC.zh-TW.md) (kept verbatim). This file is the engineering record: the user's answers
quoted, the defaults I chose where the note is silent, the knobs, the tests and the gates.

User's request (2026-10-27): 「我打算以 簡化格鬥遊戲：核心系統設計.md 重新設計遊戲系統，請與我討論後再開始修改」 then 「沒問題，請自行完成整個實作流程」.

## 1. Scope (decisions)

| Question | Answer (verbatim) |
|---|---|
| Replace or coexist | 「取代」 — the new core replaces SOUL DUEL's fight system inside `duel/`. |
| Roster | 「妥」 (first batch only Ichigo / Kenpachi / Hisagi, 「好」). Yamamoto, Rukia, Senjumaru, Lille leave `playable-roster`; code and clips stay. |
| Non-core mechanics | 「只拿掉防禦，使用<功能鍵>+攻擊＝SP, <功能鍵>+步法＝hoho（閃步）, <功能鍵>+爆氣＝覺醒」 |
| Movement | 「要」 — stick = walk and facing only; attack and SP take no direction. |
| HP / K.O. | 「沿用」 |
| Hoho | 「Hoho 跟步法保持跟原版一樣的使用功能」, 「保留無敵幀，所謂沒有防禦只是改三角相剋環，但還是能保留其他設計來增加戰鬥維度」 |
| Burst / awaken | 「是」 — every key has a Mod version: Burst key = the old Burst (escape), Mod + Burst key = awaken. |
| Phone | 「在手機上直接用手勢控制與拆開按鍵的方式來處理，只有電腦上用功能鍵進行組合」; 「Hoho 是長按後快速上滑，單純快速滑動是使用步法」 |
| Input leniency | 「可以」 — keep the existing rule (Mod held or pressed in the same step; 10-step buffer). |
| Moves come from | 「可以，先重組成新系統後再來重畫」 — retag existing clips and hit volumes first, redraw later. |

### Keys (PC)

| Key | Plain | With Mod (Shift) |
|---|---|---|
| J | attack | SP |
| Space | Step | Hoho |
| P | Burst (escape from hitstun, as the old Mod+J) | Awaken |
| stick | walk / facing | |

K, L, U (guard), I (breaker) and O (Kikon) are unbound. (The summary read to the user listed "only guard removed" and a key
list of J / Mod / Space / P; the key list is what is built. Kikon survives as a hold, §4.) The old code of those commands stays in the
frozen characters' files; only the command table and the bindings change.

## 2. The cycle (the note's rules, as built)

Classes: **NA** (attack from neutral; a string NA1 → NA2 → NA3, each needs a hit or a cancel), **NS** (SP from neutral; a rhythm of
1–4 segments that continue whether or not they connect), **AS** (SP after an attack hit; the combo's last strike, writes the
pointer), **SA** (an attack inserted between two NS segments; a turn move). Hit-confirmed attack → SP is always AS (rule 5).

Table (note's table, unchanged except where marked):

| me \ opp | NA / A-cont | NS / S-cont | AS | SA |
|---|---|---|---|---|
| NA / A-cont | first hit wins; same frame = cancel | cancel | cancel | SA wins |
| NS / S-cont | cancel | first hit wins; same frame = cancel | AS wins | cancel |
| AS | cancel | AS wins | later start wins; same start = cancel | later start wins |
| SA | SA wins | cancel | later start wins | later start wins |

- 「先打到的贏，如果同時打中就相消。而且不管是哪種都不會出現 SA 對 SA 與 AS 對 AS 的情形」 → same-class ties cancel back to neutral; the
  note's open item "two turn moves on the same frame" is void.
- Turn moves carry **super armor from move frame 6 to the end of their own startup** (the existing `:armor-hits` window): 「可以」.
- "Later start" = the move whose startup began on the later frame; the same frame cancels. 「可以」.
- A **cancel** (note rule 1) is a mutual no-damage bounce; the attacker's chain opens as if the hit landed ("treated as a hit").
  A same-class same-frame tie cancels to neutral (no continuation).

### Defaults I chose where the note is silent

1. The table applies while the defender is in a classed move's **startup or active frames**. A hit on recovery is a clean hit.
2. NS continues on a fresh SP press in the segment's continue window whether or not it hit (its own chain rule, separate from
   `chain-open-p`, which needs contact). An unpressed NS ends.
3. One SA per character at first (`J` pressed in an NS gap, after the segment's active frames).
4. The pointer position of an AS in an NS sequence counts the **attack presses** since neutral (NA1/NA2/NA3 → 1/2/3); an SA counts as one attack
   press. The pointer is clamped to 1–3.
5. 「只有『攻擊 → SP』跟『SP → 攻擊 → SP』這兩種，只要攻擊接入 SP 就會結束連段」 → AS ends the combo, so a combo holds at most one AS.
   AS landing = **hard knockdown**; the attacker gets the initiative at the wake-up (「可以」).
6. The pointer is per fighter, starts at 1 each match, survives Kikon / Soul Break resets, shows 1-2-3 on the HUD.
7. A Soul Break uses the attacker's **current** pointer's profile (the one that struck).

## 3. The SP pointer

AS after NA n writes pointer n; the next neutral SP is **NS n**.

| Pointer | NS style | Kikon konpaku vs base | Soul Break vs base |
|---|---|---|---|
| 1 | heavy damage, long reach | −1 (min 1) | +1 (unchanged) |
| 2 | "equal": red == zero | = Soul Break count when the victim is red | +1 |
| 3 | finisher | −1 (min 1) | +2 (cap 5) |

「可以」 for all three. The three AS (per position), 「可以」: **AS1** recovers the user's / drains the opponent's flash-step or Reiatsu, lowest
  (Since 2026-10-27 flash-step only: the Reiatsu gauge is gone, 「原本的 SP 量表已經沒有作用，可以拿掉了」, §6.)
damage; **AS2** launches (knock-away), medium damage; **AS3** high damage. A character may tune details, but each position keeps its job.

## 4. Kikon, Soul Break

- 「如果 SP 發生有效攻擊後持續按住按鍵就接入 Kikon」 → after an NS or an AS connects, holding the SP button continues into that
  move's Kikon. 「兩者都能發動毀魂技，然後具體是打出哪一招取決於指針改變前的 SP」 → the Kikon move and its profile belong to the SP
  that landed (for an AS, the pointer value **before** the AS wrote it).
- **Changed 2026-10-28** (the user: 「幫我把毀魂技的聯動改成依據目前指針指向的 NS 來決定，而不是由切換前的 NS 決定」): an AS's Kikon now
  follows the pointer the AS **writes** (AS n → pointer n's cinematic and Konpaku profile, and the Soul Break profile while it is in
  play), so AS n's Kikon is its own theme (§5b). An NS still uses the pointer it started under (the same value). One line:
  `core-as-start!` sets `fighter-sp-ptr` to n, not to the old pointer. The move of the follow-up is unchanged (the AS's strike again).
- **A hold, not a mash** (2026-10-27, the user: 「毀魂技的觸發判定有點怪異，我是要求『按住』才發動，但目前連打也會觸發」): the first build
  read only whether the button was down on the hit frame, so a mashed SP that happened to be down counted. Now each NS / AS segment
  starts with `fighter-sp-held` set and `core-hold-step` clears it on any step the button is up; the Kikon needs it still set at the
  hit (`apply-hit`). A latched next segment pressed during the last one starts held only if the button is still down. Browser check
  (Ichigo, keyboard): Shift + J held 1.6 s → `IC-N1A`, `KIKON FOLLOW-UP`, `KIKON 68`; Shift held + J tapped every 0.1 s → `IC-N1A`,
  `IC-N1B`, `IC-N1C`, no Kikon.
- **The phone's hold: a re-press** (2026-10-28, the user: 「手機模式目前常常有毀魂技感測不到的情況……實際在觸控時的判斷應該改為『打中後是否有
  再次點擊並長按 SP』」; asked when, 「打中前按下」). A tap fires on its lift, so the thumb was always up on the step after the SP started
  and the hold was cleared at once (only a latched segment that began with the thumb already back down could Kikon). Now an NS / AS
  segment of P1 in ONE-HAND starts with `fighter-sp-held` = `:rearm`; the first step a contact is on the pad (`touch-active-p`, any
  touch, no 120 ms rest needed) makes it `t`, and from there it is the keyboard's rule: a lift clears it, and the contact must still be
  down at the hit. Browser check (`--mobile`, Ichigo, debug 2502 + 2393): the SP tap, a re-press 0.1 s later held 1.6 s → `IC-N1A`,
  `KIKON FOLLOW-UP`, `KIKON 68`, `IC-HEAVY-KIKON-CINE`; the tap alone → `IC-N1A`, no Kikon; taps every 0.12 s → `IC-N1A`, `IC-N1B`,
  `IC-N1C`, no Kikon. The CPU and the keyboard are unchanged (the sim gate has no touch).
- 「用攻擊抵銷毀魂技並彈開雙方回到中立狀態」 and 「沒必要其他手段，只留攻擊抵銷」 → the Kikon follow-up is cancelled only by an attack
  (both bounce to neutral); Hoho and Burst do not stop it. A **red** victim cannot do even that (red = the Kikon must-hit line).
- The 1.5 s Kikon cooldown is dropped with the O key (it was a standalone key); the hold is gated by the SP landing.

## 5. CPU, gates, process

- CPU: a new generic CPU first (one roll per event for "when to turn", scaled EASY ≤ NORMAL ≤ HARD); dream-rsi later. ASSIST, the learner, ENDLESS and ROGUE are frozen
  (files stay, not maintained).
- Gates: only Ichigo / Kenpachi / Hisagi pairings (6 plus 3 mirrors), match-time window 125–210 s as the first target; G2 references and the looks baseline
  are regenerated once the system is stable (the looks gate is not run: the change is intended to move pixels).
- Anti-passive play: no new rule; measure first, act only if matches run past 210 s or time out often.
- Order: docs → pure rules (host-tested) → Ichigo → Kenpachi, Hisagi → input / phone / HUD → CPU → gates.

## 5b. Design rule: a pointer's NS, its AS and its Kikon go together

The user, 2026-10-28: 「以後每個指針的 NS 與指向他的 AS 以及對應的毀魂技都要有風格與效果上的連動關係」. For every character and form, pointer n's
NS, the AS that writes pointer n (AS n) and pointer n's Kikon (kit `:core :kikon-cines`) share one theme in look and effect. Status at the
rule (2026-10-28): KESSA 2 (Getsuga: NS2 charges / AS2 Getsuga / 漆黒の月牙天衝) and 3 (clones: NS3 / AS3 / 千影) linked; KESSA 1 (chains:
NS1 / AS1) has no chain Kikon yet (it plays the Soul Break's Getsuga); the Shikai's three are not linked yet; Kenpachi and Hisagi not
reworked. Then (§433, the user: 「幫我為聯動製作新的動畫與動作模組」) every pointer of both forms linked:

| Form | Pointer | NS | AS | Kikon cinematic (`:core :kikon-cines`) |
|---|---|---|---|---|
| Shikai | 1 the cleaver's weight | the cleaver overhead, the K string | AS1 RAKUGA's drop (50, steals 40 flash-step) | `ic-heavy-kikon-cine` (new) |
| Shikai | 2 the Getsuga | two charges > JUJISHO | AS2 SOGA > a point-blank yellow-white Getsuga (6 m, 60, the launch) | `ic-kikon-cine` (the Cero Getsuga) |
| Shikai | 3 the rush | RANGETSU > TSUKI-OTOSHI | AS3 SOSEN-GIRI > RANGETSU > TSUKI-OTOSHI | `ic-rush-kikon-cine` (new) |
| KESSA | 1 the blood chains | three lashes | AS1 the four-lash whip | `ic-chain-kikon-cine` (new) |
| KESSA | 2 the Getsuga | the black flame's charges > the 漆黒 crescent | AS2 SOGA in black flame > the 漆黒 crescent | `ic-kessa-getsuga-cine` (漆黒の月牙天衝) |
| KESSA | 3 the clones | a clone a press > their X | AS3 his cuts with the clones > their X | `ic-kessa-kikon-cine` (千影) |

KESSA's AS3 copies now come from the old sources (`:ic-k2s` / `:ic-j3` / `:ic-k3`), since the Shikai's AS3 changed. Debug stills of the
cinematics: 75000 + 80 i + k (frame 3k; i 4 / 5 / 6 the new ones).

## 6. Ichigo's three NS, the tells, the stances, the clash slow motion (2026-10-27)

User's request (verbatim): 「我接下來要從一護開始重構角色」, then 「請幫我重新設計三種不同的 NS，其中一招能透過月牙天衝達成遠距離牽制，然後在不同的 NS 下會有不同的中立站姿讓人能清楚分辨。此外 NS 跟 NA 的起手都要有足夠明顯的前搖讓人能看穿並抵消，最好抵消的瞬間要有慢動作讓人有一瞬間能思考接下來的行動」.

How I read it (defaults, nothing was asked): the NS you will get is chosen by the SP pointer, so **the neutral stance follows the pointer**
(the opponent reads which NS is coming before it starts); **the three NS are three roles**; **a cancel** (the triangle's mutual no-damage clash,
including a cancelled Kikon follow-up) **gets a slow motion**; **only the opening strike** of an NA string or an NS needs a long tell (the
follow-up links keep their speed).

| Pointer | NS | Role | Segments (S = startup) | Stance (idle clip) |
|---|---|---|---|---|
| 1 | NS1 | close, heavy (the cleaver's string, 212 base if all land) | `ic-n1a` S 22 cleaver lifted overhead and held (new clip `:ic-ns1`) → `ic-n1b` (K2) → `ic-n1c` (K3) | `:ic-st-heavy`: upright and square, the cleaver held low at his right side, point down (since §417: the first pass, the cleaver straight up, read as pointer 2's) |
| 2 | NS2 | **long range**: GETSUGA TENSHO twice | `ic-n2a` S 22 (clip `:ic-ns2`, the cleaver cocked behind the shoulder, held), a 16 m/s, 10 m, 2.4 m wide wave, 45 → `ic-n2b` S 14, the same wave, 60. | `:ic-tsuki` (the old 月待 stance: side-on, cleaver cocked high behind the shoulder) |
| 2 (since §421) | NS2 | the Getsuga's charge | `ic-n2a` charge 1, the short blade (S 20, clip `:ic-chg1`) → `ic-n2b` charge 2, both blades (S 16, `:ic-chg2`) → `ic-n2c` GETSUGA JUJISHO (the cross wave, 3.6 m wide, 14 m/s over 12 m, 150). An attack in a charge's gap is that charge's own SA: `ic-sa-g1` (the SA's short-blade sweep + a crescent, 55) / `ic-sa-g2` (KOGA's X of both blades + the cross, 80, S 10) | as above |
| 3 | NS3 | the rush / finisher | `ic-n3a` S 18 deep crouch held (clip `:ic-ns3`) then RANGETSU's four cuts → `ic-n3b` TSUKI-OTOSHI (the pounce, 4 m, 100) | `:ic-st-rush`: a low crouch leaning in, both blades trailing behind |

- **NS2 rebuilt** (2026-10-27, the user: 「一護月牙天衝的那個 NS 幫我設計成：NS[1]: 一階段（短刀）續力 -> 接 SA 時短刀攻擊會帶有額外的月牙靈壓特效並提高傷害 /
  NS[2]: 二階段（短刀+長刀）續力 -> 接 SA 時短刀+長刀攻擊會帶有額外的月牙靈壓特效並提高傷害 / NS[3]: 月牙十字衝」): the GETSUGA TENSHO x2 row above is
  replaced by the row after it. System side: an NS segment's `:params :sa` names the SA its gap starts (`mv-sa-move`, `core-latch-step`;
  `core-segment-sas` registers, classes and strings them like the kit's SA, so each goes on into J2). The charges hit nothing (the triangle
  still judges them as NS while they run). Looks (since §422, the user: 「始解狀態的月牙是黃白色光輝，而且蓄力後接續的 SA 不是要把月牙射出去，
  而是纏繞在刀刃上揮砍，所以每次攻擊都會留下黃白光輝的軌跡」, 「是 SA 與後續的一連串攻擊都會纏繞著月牙靈壓」): the Shikai's crescents are
  yellow-white (`vfx-ic-crescent` core 3: the REIATSU body, a white rim; the old ink body stays for nothing of the Shikai); from a charge
  through its SA and the whole string after it (J2, J3, the AS segments) the charged blades (1 the short one, 2 both) wear a yellow-white
  wrap and every swing leaves a yellow-white comet trail (`ichigo-charged-blades`, Ichigo's :draw hook; the charged SAs throw nothing).
- **KESSA (the Bankai) looks of the same NS2** (§423, the user: 「卍解對應的招式則是在大劍上積蓄黑色焰氣 / 一階的焰氣較小，二階焰氣更明顯，並且呈現不規則的
  十字形，第三段則是揮出跟毀魂技類似、但規模較小的月牙斬痕」): the same moves (the sim is shared), drawn by the owner's form: black flame
  on the slab (`%ic-black-flame`: a smoky band, an ink core, tongues; charge 2 larger with a ragged band across the blade, an irregular
  cross), ink-wash trails on the string, and the third press's wave a smaller 漆黒 crescent like his Soul Break's C (`vfx-ic-crescent` core 4:
  a black band, a black-smoke rim on a pale halo). The callout still reads GETSUGA JUJISHO.
- **The charge powers the whole string** (§423, the user: 「月牙靈壓帶來的強化效果除了後續的 J2 J3 以外，連同插入的 SP 結尾也都會一併受到強化」): a
  charged SA's `:params :charge-mult` (1.4 / 1.7) is armed on the fighter when it starts (`core-note-start!`, `fighter-charge-mult`), kept by
  the string's links (an NA link or an AS started from a move), dropped by any opener, NS or `to-idle`; `core-charge-mult` multiplies every
  hit of the string after the SA (not the SA itself, its 55 / 80 written high; not a hazard). Browser (Reishi lost, from 1300): J2 14 →
  20 after SA1 (x1.43), AS2 22 → 31 (x1.41). Gates (10 seeds): KK 148.8, IK 185.7, II 235.2 (all K.O.: §421's time-out gone), HK 146.3,
  HI 181.7, HH 164.9 s. CPU: in a charge's gap with the opponent inside 2.6 m it
  takes that SA on its turn roll (`*cai-turn-p*`). Browser: SP J J J → `IC-N2A`, `IC-SA-G1` 55, `IC-J2` 32, `IC-J3` 40; SP SP J → `IC-SA-G2` 80;
  SP SP SP → `IC-N2C`, `WAVE -> P2 HIT 150`.
  Gates (10 seeds): KK 148.8, IK 202.8, HK 146.3, HI 173.7, HH 164.9 s, all K.O.; the Ichigo mirror at 20 seeds 214.7 s with 19 K.O.s and one
  300 s time-out: open, the user's call (DEVLOG §421).
- **KESSA's NS3: the clones' rush** (§425, the user: 「然後開始改動卍解的動作模組，將原本衝刺連砍的 NS 改成產生分身向前揮砍（NS[1] 先產生一個、NS[2] 在產生另一個、
  NS[3] 兩個分身會以鏡像姿勢揮出斜劈而呈現X的斬擊），然後銜接到 SA 時本體會往前突進斬出一刀，隨後的 J 與 AS 都會跟著交出的分身一同攻擊」, 「X 劈砍時用兩手持刀，
  就不會有鏡像的姿勢問題了」, 「卍解也要依據當前的 NS 指針來改變主立站姿」): KESSA's `:core` has its own NS3, `ic-k-n3a` → `ic-k-n3b` → `ic-k-n3c` (a command
  gesture `:ic-k-summon`, S 18 / 14 / 14, no hit of his own). Press 1 makes a free clone at his right (0.5 m ahead, 1.1 m aside), press 2
  one at his left, each swinging at once (the light answer, 26 x 0.7); press 3 both cut inward together, two-handed, the right one
  `:ic-c-xa` (`:ic-k-xa`, over his right shoulder down to his left) and the left one its mirror `:ic-c-xb` (`:ic-k-xb` =
  `defclip-mirror` of it, a new engine helper: the left / right channels swapped, the middle twist / side and the root's yaw / sideways
  offset negated; both hands on the hilt, so the blade mirrors too), 55 x 0.7 each, knockdown, with a black X mark where they cross
  (`ichigo-kx-look`). An attack in any of its gaps is `ic-k-sa`, his flash-step lunge (3 m, 50), alone: the clones answer no plain J that
  starts an SA (`ichigo-tick`); every later J and every SP that is an AS, they answer with him (the heavy answer). NS3's clones stay after
  each of their strings while his attack goes on (`ichigo-ns-clone-p`), flash back to his side before each answer (`ichigo-ns-regroup`), so
  they cut with him wherever his lunge took him, and fade the moment his attack is over (idle while he is in no move; §426, the user:
  「Step 不再產生分身，且結束攻擊後分身就直接消失不在留於場上」). Under the core system no Step and no Hoho makes a clone (the Hoho's would
  fade at once); NS3 is the only source. Gates (Ichigo's pairings only, §424; 10 seeds): IK 186.7 s (Ichigo 2:8; 5:5 at §423), II 253.8, HI 191.2 s, all K.O.:
  Ichigo's IK win rate is open (the user's call). Browser: SP SP SP → clone hits 18, 18, then the X 38 + 38; SP SP J J Shift+J → the SA 50, J2 30 with
  the clones 35 + 35, AS2 50 with 35 + 35. KESSA's stances by pointer: `:ic-st-rush` / `:ic-tsuki` / `:ic-k-stance` (low, the slab trailing /
  cocked high behind / hanging point-down; the slab on the shoulder at 1 read too close to 2's).
- **KESSA's own core set** (§428, the user: 「要，都幫我換一換」, 「另外指針一的 NS 幫我換成使用血鎖進行近身抽打，中立站姿也改成血鎖圍繞在身邊，並且切換成指針一的 AS
  也做成血鎖的攻擊」, 「指針三的毀魂技使用之前的「千影」動畫」): KESSA's `:core` is `:ns (:ic-k-n1a :ic-k-n2a :ic-k-n3a) :as (:ic-k-as1 :ic-k-as2 :ic-k-as3)
  :sa :ic-k-sa1`; no Shikai clip is played in KESSA (a host check). NS1 is the blood chains from his left fist: `ic-k-n1a` a wide lash (S 22,
  60) → `ic-k-n1b` the backhand (S 14, 55) → `ic-k-n1c` overhead into the plaza (S 18, 80, crumple), reach 3.0 / 3.0 / 3.2 m; AS1 is
  KUSARI-BIKI as a whip (§430, the user: 「血鎖 AS 也改成多段的鞭擊」: `ic-k-as1`, clip `:ic-k-whip`, four lashes in one press, 14 each, left /
  right in turn, the last a knockdown; 10 flash-step stolen a lash). The chains come out of both wrists and both ankles (§430: 「血鎖是從手腕、
  腳踝延伸出來的」, `*ic-chain-roots*`): the left wrist's lashes, the other three reach for the same tip, fainter; a multi-hit move sweeps once
  per hit window. The chain is a look: a move's
  `:params :chain (from-deg to-deg length from-y to-y)` swept over S-4 .. S+A+4 (`ichigo-chain-lash`). Pointer 1's rest `:ic-k-st-chain`,
  a chain out of each wrist and ankle curling round him (`ichigo-chain-rest`). The SAs (`ic-k-sa1`, `ic-k-sa-g1` ITA-NAGI's chop; `ic-k-sa-g2` KAESHI-ITA), NS2
  (`ic-k-n2a/b` new charge clips `:ic-k-chg1/2`, `ic-k-n2c` cut down with `:ic-k-f3`), AS2 (`:ic-k-f1` > `:ic-k-f2`) and AS3 (`:ic-k-f2` >
  `:ic-k-wrap` > `:ic-k-f3`) are the Shikai's moves with KESSA's clips. Kikon cinematic by pointer: kit `:core :kikon-cines`, one per
  pointer (`core-kikon-cine`): KESSA's pointer 3 plays 千影 (`ic-kessa-kikon-cine`), else his Soul Break's 漆黒の月牙天衝. Browser: SP SP SP →
  `IC-K-N1A` 60, `IC-K-N1B` 55, `IC-K-N1C` 80; J SP → `IC-K-AS1` 40; under pointer 3, J and SP held → `KIKON`, `cine IC-KESSA-KIKON-CINE`.
- **KESSA's AS2 and AS3** (§431, the user: 「幫我將指向指針二的 AS 改成給月牙天衝有關的攻擊，指向指針三的 AS 則改成與分身相關的攻擊」): AS2 = SOGA's cut with
  the black flame on the slab (50) > the 漆黒 crescent thrown point-blank (`ic-k-as2b`: a 3 m wide wave, 18 m/s over 6 m, 60, the launch);
  AS3 = his cuts with NS3's clones joining one a press: `ic-k-as3` (45) + the right clone, `ic-k-as3b` (45) + the left clone, `ic-k-as3c`
  their X (38 + 38) with his drop (on-frames after the copies' `:enter` 6 / 7: at 4 / 2 they were skipped). Browser: J J SP SP → 50, WAVE 60;
  J J J SP SP SP → 45 + 18, 45, X 38 + 38 (the X knocks him down first, so the drop's 100 whiffs).
- **The wave is a hazard**: the triangle never judges it (`core-verdicts`: a hazard's hit is a clean hit), so it beats NA / NS / AS in their
  startup at range; the counters are a side Step, a Hoho or closing in. No Kikon off a wave (`apply-hit`'s `(not hazard)`), no AS.
- **Tells**: NA1 (`:ic-j1`) S 7 → 14 with a new coil clip `:ic-na1` (the short blade drawn far to his left and held); NS first segments S 22 / 22 / 18.
  The SA keeps S 8 and the old `:ic-q1` clip (`:clip :ic-q1`, `:clip-s 7`). A move's clip plays at `clip-s / S` speed, so a new clip is authored
  at the new S (`clip-s` = S: speed 1).
- **Stances**: kit `:core :stances` (one clip per pointer); `fighter-stance-clip` (fighter.lisp) replaces `(kit-stance …)` at the five idle
  sites; a kit or a form without `:stances` (KESSA, Kenpachi, Hisagi) rests in its `:stance`. Looks: one first pass, redrawn later with the rest.
- **Slow motion**: `*core-clash-slowmo-scale*` 0.2 for `*core-clash-slowmo-seconds*` 0.7 real seconds, started by `core-nohit!` (`:cancel`) and
  `core-kikon-cancel!`; the same `slowmo` the perfect Hoho uses (0.25 / 0.45), so it is sim-timed and deterministic.
- **Slow motion drawn smooth** (2026-10-27, the user: 「目前進入慢動作時，畫面會不自然的抖動，請幫我去除」): at 0.2 a sim frame ran every
  fifth step, so the bodies, their clips and the waves moved in jumps while the camera and the effects ran on real time. Now each sim
  frame first keeps every fighter's and hazard's place and yaw (`slow-snapshot`, main.lisp); while `slowmo-scale` < 1 the frame is
  drawn between that and now by `*slow-acc*`, each clip one sim frame's share back in time, and everything is put back after the HUD
  (`slow-draw-begin` / `slow-draw-end`). A look only: G2 identical before and after (II 29, IK 30, KK 23 lines), native == browser.
  Check (2513 = 3 s of this slow motion, P1 walking): consecutive 60 Hz shots differ on every frame the full-speed run differs on
  (the run.mjs shot cadence repeats one frame in three at either speed), none of the 4-in-5 still frames of a stepped sim.
- **CPU**: kit `:core :ns-range (nil (3.6 6.6) nil)`: under pointer 2, walking in from 3.6-6.6 m he shoots with `*cai-ranged-p*` 0.5 per decision,
  then waits `*cai-ranged-gap*` 80 steps (one roll per event; the first version always shot and the matches crawled: 78 waves a match).
- **Pace**: the long tells (more cancels, fewer landed hits) made the Ichigo mirror 261 s with two time-outs at damage x1.0; Ichigo's `:core :mult` 1.3
  (Shikai and KESSA; Kenpachi's is 1.2) brought the 10-seed gate to KK 150.7, IK 176.9, II 213.3 (a mirror may pass 210), HK 146.3, HI 203.6, HH 164.9 s, every match K.O.'d. Ichigo still loses to Kenpachi 2:8 and Hisagi to Ichigo 2:8: open.
- **AS segments** (2026-10-27, the user: 「我希望 AS 也能設計成不同段數的連擊」; asked, answered 「每段再按 SP」 and
  「AS1=1 AS2=2 AS3=3」): AS n has n segments, each on a fresh SP press, hit or not, through the same `:ns-next` chain as an NS
  (`core-segments`, `build-core-classes` tags every segment AS; `core-move-sp!` takes `:as` like `:ns`). Only the last segment knocks
  down / launches; the earlier ones stagger. Ichigo: AS1 TSUKI-OTOSHI (steals, 40, knockdown); AS2 SOGA 50 → SHOGA 60 (launch);
  AS3 KOGA 45 → SOSEN-GIRI 45 (reach 2.4, a 1.6 m lunge: at 1.44 it whiffed after KOGA's push) → RAKUGA 100 (190; it was one 150).
  Browser: J J → SP SP → `IC-AS2` 50, `IC-AS2B` 60; J J J → SP SP SP → 45, 45, 100. CPU: presses the next AS segment with
  `*cai-cont-p*` unless it holds for the Kikon. Kenpachi's and Hisagi's AS stay single until their own reworks.
- **No Reiatsu gauge** (2026-10-27, the user: 「原本的 SP 量表已經沒有作用，可以拿掉了」): no core SP spends Reiatsu (`core-sp-start!` /
  `core-as-start!` check no cost); its last use was AS1's steal (`:steal-rei 100`), which fed nothing. The HUD's REIATSU row is not drawn for a
  kit with `:core` (FLASH STEP and AWAKEN move up into its place, hud.lisp); `:steal-rei` is gone from `core-on-hit!` and the three AS1s
  (they steal 40 flash-step). The gauge itself still fills in the sim (KOSEI, hits, regen) and the frozen modes still read it.
- **No guard gauge** (the same day: 「防禦量表也一樣沒用了，可以移除」): there is no guard, so the bar under the Reishi and the KOSEI tag at
  its end are not drawn for a `:core` kit, in the landscape and the portrait (phone) panels; the portrait's last row is then FLASH STEP +
  AWAKEN at half width each (+ the kit meter where there is one). Shots: 1280x720 and 390x844 (DEVLOG §420). The sim still keeps the gauge
  (KESSA's clones still spend 15 of it, unseen: left for his rework).
- Debug: 2510+p sets P1's pointer (stance shots, DUEL_GAMEPLAY).
- Tests: `tests/duel-rules/triangle.lisp` (+7: tells >= 14 f, NS2 a wave with no melee hit, stance by pointer); `core.lisp`'s J1 budget and the clip
  list (`:ic-na1 :ic-ns1 :ic-ns2 :ic-ns3`), `art.lisp`'s striker table (`:ic-na1`).

## 7. Status

See DEVLOG §410 onward for each stage's numbers.
