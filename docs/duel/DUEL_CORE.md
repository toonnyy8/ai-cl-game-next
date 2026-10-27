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
damage; **AS2** launches (knock-away), medium damage; **AS3** high damage. A character may tune details, but each position keeps its job.

## 4. Kikon, Soul Break

- 「如果 SP 發生有效攻擊後持續按住按鍵就接入 Kikon」 → after an NS or an AS connects, holding the SP button continues into that
  move's Kikon. 「兩者都能發動毀魂技，然後具體是打出哪一招取決於指針改變前的 SP」 → the Kikon move and its profile belong to the SP
  that landed (for an AS, the pointer value **before** the AS wrote it).
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

## 6. Status

See DEVLOG §410 onward for each stage's numbers.
