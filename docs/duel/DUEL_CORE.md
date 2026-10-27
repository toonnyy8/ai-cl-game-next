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
- **A hold, not a mash** (2026-10-27, the user: 「毀魂技的觸發判定有點怪異，我是要求『按住』才發動，但目前連打也會觸發」): the first build
  read only whether the button was down on the hit frame, so a mashed SP that happened to be down counted. Now each NS / AS segment
  starts with `fighter-sp-held` set and `core-hold-step` clears it on any step the button is up; the Kikon needs it still set at the
  hit (`apply-hit`). A latched next segment pressed during the last one starts held only if the button is still down. Browser check
  (Ichigo, keyboard): Shift + J held 1.6 s → `IC-N1A`, `KIKON FOLLOW-UP`, `KIKON 68`; Shift held + J tapped every 0.1 s → `IC-N1A`,
  `IC-N1B`, `IC-N1C`, no Kikon.
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
  still judges them as NS while they run). Looks: `ichigo-charge-look` rides a crescent on each charged blade (1.4 m) while the charge or its
  SA lasts; the charged SAs spawn a 2.8 m crescent / a 3.2 m cross at the strike. CPU: in a charge's gap with the opponent inside 2.6 m it
  takes that SA on its turn roll (`*cai-turn-p*`). Browser: SP J J J → `IC-N2A`, `IC-SA-G1` 55, `IC-J2` 32, `IC-J3` 40; SP SP J → `IC-SA-G2` 80;
  SP SP SP → `IC-N2C`, `WAVE -> P2 HIT 150`.
  Gates (10 seeds): KK 148.8, IK 202.8, HK 146.3, HI 173.7, HH 164.9 s, all K.O.; the Ichigo mirror at 20 seeds 214.7 s with 19 K.O.s and one
  300 s time-out: open, the user's call (DEVLOG §421).
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
