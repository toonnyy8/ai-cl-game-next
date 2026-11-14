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
- A **cancel** (note rule 1) is a mutual no-damage bounce, and it is symmetric: both fighters' classed moves count as landed, their
  links, AS and SP / Hoho cancels open, the side still in its startup only from its own first hit frame (§2.1, the user 2026-11-12:
  「相消不該有所謂的攻擊方與受擊方，是一個平等的狀態」; before: only the attacker's chain opened, "treated as a hit").
  A same-class same-frame tie cancels to neutral (no continuation).
- **Projectiles are in the triangle** (DUEL_SP §6, batch S5, 2026-11-13; the user: 「將飛行道具回歸相消的攻擊體系中」, 「OK」 on the lead's
  definitions; it overturns "a wave beats every class at range", §6 below): a hit hazard carries the class of the segment that fired it
  (`spawn-hazard`'s `cls`, with what the segment paid, its damage scale frozen at the fire frame and its start tick), and `core-verdicts`
  judges its hit like that segment's blade. A **cancel** removes it (`core-hazard-nohit!`): the owner gets back what the segment paid,
  once, even after the move ended; still in that segment it also counts as landed for him, else only the refund; the defender's move
  counts as landed (his refund or +30); an exchange opens (§2.1); no bounce. A class that **beats** it (`:absorb`: an AS against an NS
  wave) spends it: no refund, no exchange (Q9). A **win** for the wave (an NS against an NS wave, the first hit) lets it through. Against
  JUJISHO (NS2c, `:ns`): J and SA cancel, AS beats it, NS is hit. A NOZARASHI blade (`:projectile-cut`, `cut-hazards`) touching a wave is
  judged the same way (a classless blade or wave keeps cutting). Wave vs wave (`ichigo-cut`) is unchanged. KESSA's clone replays carry the
  replayed move's class and the summon segment's scale, pay nothing (a cancelled replay refunds nothing); NS3 / AS3's own clone cuts and
  ZANZO's echoes stay classless (clean hits: not projectiles).

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

### 2.1 A cancel is symmetric (the user, 2026-11-12)

Question: 「為什麼檜佐木遠距 J1 相消後接不了 J2 與 AS？」. Ruling: 「相消不該有所謂的攻擊方與受擊方，是一個平等的狀態」.

This supersedes rule 1 of the user's own note (docs/duel/DUEL_CORE_DOC.zh-TW.md, kept verbatim: 「攻擊方視同命中，可以接下一下」): both sides now
count as landed.

**Cause.** `core-nohit!` (core-sim.lisp) set contact `:hit` and the land frame only for the fighter whose hit the step's pending hit
belonged to. In PRACTICE with GUARD ALL at 2.2 m, Hisagi's ranged J1 has no hit of its own (its 3 m dead zone); the dummy's NS hit lands
on him in J1 and is the one judged (`P2 KE-Z-N1A x P1: CANCEL`), so his contact stayed NIL and J2 (`chain-open-p`) and the AS
(`core-move-sp!`: contact `:hit` + `cancel-open-p`) never started, while KIN turned on (the `:clash` hook runs for both). At 4.5 m his J1
is the one judged (`P1 HS-R-J1 x P2: CANCEL`) and both started.

**The rule.** A cross-class cancel counts as landed for both fighters: the side whose hit was judged and the side in whose classed window
it was. Each gets contact `:hit` and a land frame from the pure `core-cancel-land-sf` (core.lisp): one already set is kept; else his move
frame, but not before his move's first hit frame (`mv-first-hit`, S for a move without a hit window). The judged side is on its hit frame,
as before; the other is often still in his startup, and a real hit never opens his AS / SP / Hoho / guard cancels or ORANGE out of a
startup, so neither does a cancel (the mirror, not a copy). J links need nothing more: `chain-open-p` with `:hit` waits for the end of the
active frames. The other side gets it only while he is still in a classed move's startup / active frames when the verdict is applied
(`core-window-class`, re-read: an earlier hit of the same step may have moved him). A same-class tie sets both before `core-bounce!`;
`to-idle` keeps contact / land frame (as it always did for the judged side), but every sim reader is gated on a move in progress and
`start-move` clears both, so nothing stale reaches the next move (the stale value is read only by Hisagi's chain drawing). `:absorb`
and the AS / SA later-start rule are not cancels: unchanged. One build-unit change besides: `apply-hit`'s "first real hit" (its
`:on-land`: WA / TATAKI / J3 pushes, the bind hooks) is now the pure `first-land-p` (rules.lisp): contact not `:hit`, or `:hit` with no
window of his own touched (window bits 0), so the other side's later real hit still runs its `:on-land`; after a cancel of his own hit
(that window's bit set) a later window's is not the first, as before. Host tests: 10310 (5 + 4 in triangle.lisp: the land frame, every
move's windows in order so the judged side's value is unchanged, `first-land-p`; 5 in sim.lisp: both sides after a cross-class cancel,
the other side out of his window gets nothing, a same-class tie sets both before the bounce).

**Audit** (every reader of `fighter-contact` / `fighter-land-sf` and of "the attacker of a cancel"):

| Reader | Verdict |
|---|---|
| J links (`chain-open-p` in `move-commands`) | now also for the other side, intended (from the end of its active frames) |
| `core-move-sp!` NA / SA → AS | now also for the other side, intended (from its first hit frame) |
| `cancel-into` (SP / Hoho / `:cancel` L), the O ender, the Breaker's J1 / K1 (`cancel-open-p`) | now also, from its first hit frame; Hoho's combo resume (`start-hoho`, §8) too |
| `guard-cancel-open-p`, `move-end-frame` / `recovery-pace` | now also: his move ends after R, not its whiff recovery (Hisagi's dead-zone J1 at 2.2 m: KIN off 95 → 115-138 because J2 / the AS follow); a core kit never guards, so the guard cancel stays unread |
| ORANGE (`burst-mode-of`: `cancel-open-p`) | now also, from its first hit frame (never out of a startup) |
| `string-opener-p` dash-in, `ender-push`, `combo-hits` / damage scaling, KOSEI, the Kikon counts, `core-on-hit!` | unchanged: only a real hit (`apply-hit`) touches them; a cancel is no hit |
| `:on-land` (`apply-hit`'s first real hit) | changed to `first-land-p`, so the other side keeps it (see above); the judged side as before |
| `start-move`'s off-ender chase (contact `:hit` on an `:ender` J / K: the next move chases) | now also for the other side, as for the judged side |
| the guard lock (`chain-more-p`, `guard-lock-of`) | unread: a core kit never guards |
| Kenpachi's SP2 `ke-charge` dash (`(null (fighter-contact f))`), `ken-flurry` | unchanged: a move without a class is never in a classed window, so never a cancel's other side (and :sp2 is not bound in the core system) |
| `kikon-lock-p` (the rusher's contact) | unchanged in practice: only a Kikon follow-up holds the lock, and its victim cannot start a classed move under it |
| `core-clash!` / kit `:clash` hooks (Hisagi's KIN `hs-clash`, the bind's Reishi `hs-bind-clash`), `core-kikon-cancel!`, `core-bounce!` | unchanged: already both sides |
| the CANCEL log line | unchanged: it names whose hit was judged (a fact of the step, not a side of the rule) |
| `dummy-starts` (flow.lisp, GUARD ALL) | now also: the dummy's NA / SA link opens after a cancel of its J1 by the player's hit (§9) |
| core-ai `cai-move-step` (NA / SA → AS or the next J; NS / AS going on: the fuzzy `:hit` input) | now also for the CPU on the other side, intended; no chance, threshold, table or strategy retuned |
| cpu-hisagi-range (WA / TABA routes, `hr-home`), cpu-ki-ken, cpu-ki-ichigo route reads | now also, intended, untuned |
| mcts-lite's light model (`(:cancel 0)`), cpu-mcts | unchanged: a cancel ends the rollout at 0 for both sides, already symmetric |
| webhud's AS cue, scripted.lisp `:on :hit`, ichigo.lisp's pacing counter | now also count the other side's cancel as landed (cue / test / stats) |
| ai.lisp, hisagi-ai.lisp, assist.lisp `(= sf land-sf)` hit-step reads | unchanged: the old CPU / ASSIST, never run for a `:core` kit (`brain-step` hands a core kit to `core-brain-step`) |
| Hisagi's draw (`hs-kb-lk!`, chain wraps) | presentation: a cancel's other side now draws as touched |

**Scenes** (debug 83811-83814, `tests/scripts/duel-hisagi-j1-cancel.json`: Hisagi's ranged J1, then J or SP 0.2 / 0.35 / 0.5 / 0.7 s
later, PRACTICE vs Kenpachi; ticks from the scene command, J1 starts at 18 in a page's first scene and 19 after):

| Scene | Before | After |
|---|---|---|
| 2.2 m GUARD ALL, J1 then J | `P2 KE-Z-N1A x P1: CANCEL` 34-35, KIN on, no J2 at any offset, KIN off 95-96 | the same CANCEL 34-35, `P1 move HS-R-J2` 42 / 43 / 53 / 63; the dummy's NS1b answers it (`P1 HS-R-J2 x P2: CANCEL` 77-82), at +0.2 / +0.35 its NS1b then lands (`HIT 55`); KIN off 115-138 |
| 2.2 m GUARD ALL, J1 then SP | CANCEL 34-35, no AS, KIN off 95-96 | CANCEL 35, `P1 move HS-R-AS1` 43 / 43 / 53 / 63, `HS-R-AS1 -> P2 HIT 43` 83-87 (KIN: inside the 3 m dead zone at d 1.09), KIN off 130-134 |
| 4.5 m GUARD ALL, J1 then J / SP | `P1 HS-R-J1 x P2: CANCEL` 32 / 33, J2 50 / 51 / 51 / 61, AS1 40 / 46 / 51 / 66 | identical (relative to J1's start) |
| 2.2 m STAND | no contact, no J2 / AS (SP at +0.7: a fresh NS1a, `HIT 26`) | identical |
| 4.5 m STAND | J1 `HIT 19` 32-33, J2 39-61, AS1 37-63 | identical |

**G2** (`tests/style-cvc-ref.txt`): with the other side's half switched off (a temporary special, removed) the native `--cvc` matched the
reference line for line (II 33, IK 35, KK 26); on, regenerated (native = browser): II 33 → 40 lines (P1 6-0 329.6 s → P2 1-2 397.9 s),
IK 35 → 33 (P2 0-2 351.9 s → P2 0-5 330.5 s), KK 26 → 28 (P1 3-0 261.5 s → P2 0-5 275.4 s). snaptest / fulltest on G2's IK clean. No
balance gates.

**The exchange and its breakthrough** (DUEL_SP §6, batch S4, 2026-11-13; the user: 「當相消後突破對手防線將會奪取對方全數 SP」, then 「50%」,
「都算」). A cancel opens an **exchange** between the two fighters, still with no attacker and no defender: `core-nohit!`'s `:cancel` and
`core-kikon-cancel!` (Q12: the victim's attack against a non-red Kikon follow-up; it also pays him the cancel's +30, nothing is refunded)
stamp both fighters' `xch` with the tick (`core-xch-open!`; a later cancel restamps). The **first real hit** of either side in it (`apply-hit`,
result `:hit` / `:counter`, J included, a hazard's or a clone's too) is the **breakthrough** (`core-break!`): `sp-break-take` takes 50 % of
the victim's flash-step above the last cell (`*sp-break-share*`) through `spend-fs`, the attacker gains half of that (`*sp-break-gain*`)
through `pay-gauges` (nothing in his burst, x SUBLIMATION; Q18); once per exchange (`xch-done` on both), also when it takes nothing (a
victim at or under 100). It runs after the hit's own effects, so an AS1's steal comes first and the breakthrough takes from what is left
(Q10). The exchange ends at the first step both fighters are back in neutral (`core-xch-step`, the last of `sim-systems`, the pure `sp-neutral-p`:
no move, no reel / blockstun / air / down / wake-up, and not standing in a clash's bounce push, so a tie's or a Kikon cancel's exchange
lives through the push; a Step, a run, a Hoho, a guard count as neutral, Q11), on the frame a cinematic begins, and at a reset (`reset-round`). A parry and Hisagi's bind
clash are not cancels (Q13). Log: `P1 BREAK fs T from P2 (fs V), gains G (fs F)`; event `:sp-break att def take gain` (only when T > 0: the
HUD's cue, DUEL_LISP_HUD §17); the hash line's ` x<tick>` (`*` once taken).

#### 2.1.1 The cancel's out: an NS segment's SA opens at once (the user, 2026-11-14)

The user (verbatim): 「我發現劍八的壓制能力異常強大，跟其他角色相消後換攻擊時必勝，這是為何？」, 「尤其是 J1 到 AS 的切換」; shown the cause
and two changes (1: Kenpachi's sealed J1 / AS1 frames, DUEL_KEN_V3 §48; 2: this rule), 「好 1+2，然後再以此修改 AI 的策略，然後盡量讓 AI
積極相消互動」. The CPU's strategy is a later phase; nothing in the CPU changed here.

**Why.** After a J × NS cancel both moves count as landed (§2.1), but the two sides were not equal after it: the J side may start its AS
on the first step after the cancel's hitstop (`core-move-sp!`: contact `:hit`, `cancel-open-p` from its hit frame), while the NS side was
held in its segment: no Hoho before its own hit frame (`core-cancel-land-sf`) and a latched SA only after its active frames
(`core-latch-step`). AS × NS is a hit, and AS vs SA is `core-later` (core.lisp: the later start wins), so the J side always had a free
AS: Kenpachi's sealed J1 (S 6) → AS1 (S 12) swept the J1 → AS matrix 21 / 0 / 0. A pre-input SA that fired at once would not have helped:
started on the cancel frame it starts before the AS, and the later start wins anyway.

**The rule** (old → new). An NS segment's SA (an attack pressed in it) started once its active frames were over → **also at once from the
frame the segment took part in a cancel**. "Took part" = an exchange opened on or after the segment's start tick: a cancel stamps both
fighters' `xch` (`core-xch-open!`, §2.1's exchange), so `xch >= cls-t` (the pure `core-cancelled-p`, core.lisp) is true only for a segment
that was in a cancel, either side of it (its own hit judged, the other's hit in its window, a wave it fired cancelled while it is still in
the segment, its blade cutting a wave); a whiff or a real hit opens no exchange. `core-sa-open-p sf s a cancelled` (core.lisp) is the
gate. In the sim (core-sim.lisp): a J press after the cancel starts the SA in `core-sa-start!` at once (no latch); `core-sa-move` is the
one place that picks it (the carried charge, the segment's `:sa`, the kit's) for both paths.

- **A latched SA from before the cancel** (chosen, the brief's simplest reading): it fires on the first step after the cancel's hitstop
  and **counts as started on the cancel's tick** (`fighter-cls-t` := `fighter-xch`): a guess. A J side's AS started after the hitstop is
  the later start and beats it. (Without that stamp it would start on the same step as an AS pressed at once, the same tick, a `core-later`
  tie: the outcome left to the two moves' frames.) A fresh press on that same first step does start on that tick: the same tick as an
  instant AS, a cancel between them.
- **Scope**: only the NS segment's SA (the one class whose follow-up was gated on its own frames). An AS segment has no SA and is
  unchanged; an NA's links and its AS are §2.1's. The Hoho lock after a cancel (`core-cancel-land-sf`: no cancel before the move's own hit
  frame) stays: the SA is the NS's own follow-up, not a cancel. All three fighters, every form.
- **The reaction window** (decisive scenes, sealed Kenpachi J1 → AS1 at 1.5 m; the AS's super freeze holds the NS side 4 frames and a
  press inside it survives, the SA starting on the first free frame): AS1 starts 1 step after the cancel and hits on its frame 16; the SA
  must start by then (in its startup / active window the AS's hit is absorbed, `core-later`): a J press from the AS's start up to its
  frame 15 wins (16 frames, 4 of them inside the freeze), one on its frame 16 or later is too late (AS1 HIT 90).

| Scene (both side orders checked) | Before | After |
|---|---|---|
| A: sealed Kenpachi J1 → AS1 vs Ichigo NS1, SA latched on frame 3 | AS1 HIT 90 | SA starts with AS1 (stamped at the cancel) → AS1 absorbs it, AS1 HIT 90 |
| A: the same, J pressed 0 / 1 / 2 / 5 / 9 / 13 / 14 / 15 frames after AS1 starts (16, 17: too late) | (latched: SA after NS1's active end, AS1 HIT first) | `IC-SA -> HIT 34` every time (AS1 absorbed when it lands first) |
| C: the same vs Hisagi NS1, SA latched on frame 3 | AS1 HIT 90 | AS1 absorbs the SA, AS1 HIT 90 |
| C: J pressed 1 / 5 / 9 frames after AS1 starts | — | `HS-SA-KIRI -> HIT 40` every time |
| Swapped (Ichigo / Hisagi as P1 with NS1 + SA, Kenpachi P2 J1 → AS1 at sim frame 9 / 10 / 11) | — | latched: AS1 wins all six; reacting (J 12 / 16 / 20 frames after NS1): the SA wins all six |

**The J1 → AS matrix** (both press on the same frame at 1.5 m: P1 J1 then SP on contact; P2 J, NS n, NS n + an SA latched on frame 3
(a guess), and new NS n + SAr: J pressed 8 frames after P1's AS starts (a reaction); first real hit, P1 / p2 / none against the other
characters' forms; Kz sealed Kenpachi, Ks his Shikai, Ib Ichigo, Ik KESSA, Hb Hisagi):

| J1 → AS side | old seven answers, before → after | reactive SA, before → after | all, before → after |
|---|---|---|---|
| Kz | 21 / 0 / 0 → 18 / 3 / 0 | 9 / 0 → 0 / 9 | 30 / 0 → 18 / 12 |
| Ks | 15 / 6 → 18 / 3 | 5 / 4 → 0 / 9 | 20 / 10 → 18 / 12 |
| Ib | 8 / 10 / 1 → 15 / 3 / 1 | 1 / 7 → 1 / 7 | 9 / 17 / 1 → 16 / 10 / 1 |
| Ik | 17 / 2 → 19 / 0 | 7 / 1 → 1 / 7 | 24 / 3 → 20 / 7 |
| Hb | 19 / 6 / 1 → 19 / 6 / 1 | 10 / 1 → 10 / 1 | 29 / 7 / 1 → 29 / 7 / 1 |

The sweep is gone against a reaction; a guessed SA (latched before the cancel) now loses where it used to win by firing after the AS's
start (the NS side's wins on the seven old answers: against Ib 10 → 3, Ks 6 → 3, Ik 2 → 0), as the brief's case (a) asked (「a guess too
early is punished」). So on the seven old answers alone (all their SAs are pre-cancel latches) the J1 → AS side still nearly sweeps (Kz
18 / 3, Ik 19 / 0): the lead's call whether that is the intended reading. Hisagi's AS1 TSUMUJI (16 active frames, four hits) still beats the
reactive SA: TSUMUJI carries him back to 3-4 m (traced: 1.2 m at the cancel, 3.3 m at the SA's hit frame), so the SA absorbs two of
its hits, whiffs on distance (reach 2.4 + slide 1.4), and its window ends before TSUMUJI's; a property of that move, not of the rule.

**HARD CPU logs** (information; 10 seeds, pairings KK IK II HK HI HH, the next real hit after each cancel, `run.py` / `analyze.py` of the
investigation): the CPU (unchanged) does not use the out yet: e.g. Kenpachi's J × Hisagi's NS 232 cancels (231 AS hits) → 94 (93), Ichigo's
J × Hisagi's NS 47 (46) → 30 (30), Kenpachi's J × Kenpachi's NS 33 (AS 10, SA 19) → 34 (AS 20, SA 9).

**Tests**: `tests/duel-rules/triangle.lisp` (`core-cancelled-p`: a cancel in the segment, on its first frame, none, an earlier move's;
`core-sa-open-p`: open after a cancel in the startup, closed without one until S + A). G2 regenerated (`tests/style-cvc-ref.txt` header:
II 36 → 37 lines, P1 2-0 355.6 s → P1 5-5 368.4 s; IK 31 → 39, P1 2-0 307.3 s → P2 0-1 382.8 s; KK 19 → 23, P1 6-0 188.0 s → P1 4-0
232.1 s; native = browser); snaptest (seeded gate matches with rollouts: equal) and fulltest on G2's IK (80 checks, 0 differ) clean. No
balance gates.

#### 2.1.2 No Hoho while an exchange is open (the user, 2026-11-14)

The user (verbatim): 「那我第一點真正想要的是 B 選項，要正面對決而不是比誰手速快。在相消的過程不該能進行閃步。」 Context (DUEL_AI_STRATEGY
§11.18's leftover): after a J x NS cancel the side whose hit was judged may Hoho at once (its cancel windows open on its own hit frame,
`core-cancel-land-sf`), and its perfect Hoho over the segment's later hits counters, while the other side is held to its own hit frame:
scripted, the J side's Hoho out beat every NS answer 19 : 0 : 6. A race of who presses first, not a face-off. Also asked: shorten Hisagi's
AS1 TSUMUJI (it carries him to 3.3 m and beats the reactive SA)? The user: 「先不用」. TSUMUJI stays as it is.

**The rule.** "相消的過程" = the exchange a cancel opens (§2.1's exchange: `core-xch-open!` from `core-nohit!`'s `:cancel` and
`core-kikon-cancel!`, ended by `core-xch-step` at the first step both are back in neutral, by a cinematic, by the reset). While it is open
**neither fighter may start a Hoho**, all three fighters, every form, whoever's hit was judged.
- The predicate: `core-hoho-open-p xch` (core.lisp, pure, host-tested in triangle.lisp). It is true when `xch` < 0. A fighter's own
  `fighter-xch` is enough: every writer sets both sides together (`core-xch-open!`, `core-xch-step`, `reset-round`).
- Where it is read: `hoho-ready-p` (fighter.lisp). So every CPU's Hoho test inherits it: the generic, the style CPUs, the MCTS's legal
  actions and light model, the strategy cue `:hoho`, the one-hand perfect hint.
- The refusal: `try-command`'s `:hoho`, both from neutral (`command!`) and out of a move (`cancel-into`, once its cancel window is open).
  The press is refused **and eaten** with the `:refused` cue (the dud tick only; the SP HUD flash means "not enough SP" and is not reused)
  and the log line `P1 refused hoho: exchange`. A refused Hoho used to stay buffered for `*input-buffer*` (10 frames); here it would then
  fire on the step the exchange ends, which brings the race back. A press that never reaches `try-command` (during a reel, or in a
  segment before its own hit frame) stays buffered as any press does, up to 10 frames, and may start the Hoho once the exchange is over:
  allowed.
- An MCTS plan picked a reaction before the cancel (`mc-plan-apply`) drops a Hoho that is no longer allowed.

**Decided with it.**
- **Step and the guard stay as they are.** The user named 閃步 (Hoho, Mod+Space). A Step is no instant escape: `move-commands` takes no Step
  out of a move, so the J side can Step only once its J has recovered. Scripted (`steps.py`, all 25 form pairings at 1.5 m, P1 J1 into
  P2's NS1, P1 Step on his first free frame): the NS side's next hit lands first 23 / 25 (it carries on) and 21 / 25 (it stops); the rest
  have no hit. These numbers are the same before and after the rule. A core kit never guards (§2.1's audit).
- **A Hoho already running at the cancel**: cannot happen. A cancel needs both fighters in a classed move's window, and a Hoho is no
  classed move (`start-hoho` leaves the move). One that started earlier is not touched: the rule gates the start only.
- **The exchange outlives its breakthrough.** The exchange stays open after the first real hit, while the victim reels. So a combo that
  started from a cancel gets no Hoho of either side (§8's combo Hoho off a hit, a BLUE burst's Hoho) until both are back in neutral. A combo
  from a clean hit opens no exchange and keeps them. HARD logs before the rule (30 seeds, KK IK II HK HI HH, 180 matches): 3,674 Hohos.
  - Inside an exchange: 2,042 before its breakthrough, 1,091 of them perfect.
  - Inside an exchange after its breakthrough: 634, 338 of them perfect.
  - Combo-Hoho resumes (`HOHO ->`) inside an exchange: 787.

  That was the first, literal build. **The lead chose the narrow reading (2026-11-14)**: 相消的過程 is the undecided clash, from the cancel
  to its first real hit (the breakthrough, `fighter-xch-done`) or both back in neutral. It still stops the user's case (the J side's Hoho
  out comes before any breakthrough), and a combo won out of the clash keeps §8's combo Hoho and the BLUE burst's Hoho, as a combo from a
  clean hit does: `core-hoho-open-p (xch done)`. The scenes below (all before any breakthrough) are the same under both readings; the
  measurements are the literal build's.

**Scenes** (native, `tools/simgate/trial.lisp` copies driving both sides; first real hit after the cancel, J side : NS side : none, 25 form
pairings each: Kz sealed Kenpachi, Ks his Shikai, Ib Ichigo, Ik KESSA, Hb Hisagi):

| Scene | Before | After |
|---|---|---|
| J hit first; P1 J1 → Hoho on contact, any NS answer | 19 : 0 : 6 (the perfect-Hoho counter) | refused (P1's press refused in all 125 trials); 0 : 21-25, exactly the "hold" row |
| P1 J1 → AS on contact vs the reactive SA | 5 : 20 | 5 : 20 (unchanged; the 5 are TSUMUJI) |
| P1 J1 → AS on contact vs P2 mashing Hoho after the cancel | 14 : 11 | 25 : 0 (her Hoho refused, the AS lands) |
| NS hit first (P1 NS1, P2 J at frame 6 / 9); her Hoho vs his AS | J 8 : NS 17 / J 5 : NS 20 | J 25 : NS 0, both (refused, as "none") |
| NS hit first; his Hoho vs her SA at once | J 25 : NS 0 / J 23 : NS 2 | J 0 : NS 25, both (his Hoho refused, the SA lands) |
| P2 NS side mashing Hoho 1-19 frames after the cancel | a Hoho inside the exchange in 18 / 25 | none in 25 / 25; refused presses logged in 18, none fires when the exchange ends |
| P1 Hoho 40 frames after he is free (P2 stopped: both neutral, the exchange over) | Hoho 25 / 25 | Hoho 25 / 25 |
| Decisive A / C (§2.1.1) and the reactive SA by press frame | as in §2.1.1 | identical; A2 (her Hoho mash) is now refused, the same AS1 HIT 90 |

**The CPU**: DUEL_AI_STRATEGY §11.19. **Tests**:
- triangle.lisp: `core-hoho-open-p` with no exchange, an open one, tick 0.
- sim.lisp: after a cross-class cancel, both sides carry the exchange, neither is `hoho-ready-p`, and `try-command :hoho` returns NIL. The
  move goes on and the press is eaten. With the exchange over, both may Hoho again.

### 2.2 A stealing AS: per-hit flash-step take, no cap, 50 % to the attacker (the user, 2026-11-12)

Requests (verbatim, 2026-11-12): 「檜佐木始解 AS1「旋」改 10/20/30/40」, 「一護始解 AS1「落牙」改 80」, 「一護血鎖 AS1「鎖引」改 30/30/30/30」,
「不限制吸取上限，然後吸取的轉換率設為 50%」. Current rule: each landed hit of an AS with a steal value takes that value from the victim's
flash-step (never more than he has); the attacker gains `*steal-fs-gain*` = **0.5** of what was taken (capped by `*fs-max*`). No per-use cap.

- **Per-hit values**: a hit window's own `:steal-fs` (kit.lisp, `hitwin-steal`), else the move's `:params :steal-fs`. Hisagi's Shikai AS1
  TSUMUJI `:hs-as1` 10 / 20 / 30 / 40 on its 1st-4th window; Ichigo's Shikai AS1 RAKUGA `:ic-as1` 80; KESSA's AS1 KUSARI-BIKI `:ic-k-as1`
  30 x 4 (unchanged). A KESSA clone's replay (x0.1, `clone-replay-hit!`) uses the move-level value (no window passed; KUSARI-BIKI is uniform).
- **Pure rule**: `steal-take want victim-fs` (rules.lisp) -> `(values take gain)`; `core-on-hit!` (core-sim.lisp) only applies it and logs
  `P1 STEAL fs 30.0 from P2, gains 15.0` (a clog, no hash line). Knob `*steal-fs-gain*` (tuning.lisp).
- **History**: earlier the same day (commit 683979c2) a per-use cap `*steal-fs-max*` = 100 (one HUD cell; 「當前角色吸取對手閃步量表的能力改成最多削減一格的量」,
  values RAKUGA 120, KUSARI-BIKI 30 x 4, TSUMUJI 120 x 4, the attacker gaining all of it) with the fighter slot `steal-taken` and its reset
  in `core-note-start!`; all removed by the requests above (before the cap: unbounded, RAKUGA / TSUMUJI 120).
- **Scenes** (`tests/scripts/duel-steal-cap.json`, debug 83815 / 83816, 74904, 74908 / 74909; P1's flash-step 100, P2's 300, J1 then SP): measured: TSUMUJI 10 / 20 / 30 / 40 (gains 5 / 10 / 15 / 20; P2 300 -> 200, P1 100 -> 150), RAKUGA 80 (gains 40; P2 -> 220, P1 -> 140),
  KUSARI-BIKI 30 x 4 (gains 15 each; P2 -> 180, P1 -> 160), the same with two NS3 clones (their replays did not land). Six seconds later
  (regen, damage gains): P1 189.7 / 167.0 / 205.8 / 205.9, P2 225.2 / 240.7 / 203.9 / 203.9.
- **S1 of DUEL_SP, 2026-11-13: the last cell is never taken.** `steal-take` now takes `min(want, victim - *fs-cell*)` (0 at a victim of 100 or less, 30 at 130,
  up to 200 at 300). `core-on-hit!` routes the victim's loss through `spend-fs` (only when something is taken) and the attacker's gain through
  `pay-gauges` (nothing during a burst, x the SUBLIMATION bonus; DUEL_SP Q18). The Kikon / Soul Break flash-step bar is `pay-gauges` too.
  Scenes: `duel-steal-cap.json` runs each steal against a victim at 100 / 130 / 300 (debug 2820-2822, "SP scenes"); numbers in DUEL_SP §8.4 "S1 done".
- **Host tests**: `tests/duel-rules/triangle.lisp` (the knob, `steal-take`'s cases, the per-window values of the three moves).
- **G2**: with the old values and the cap switched on temporarily native `--cvc` matched the reference (II 40, IK 33, KK 28 lines); the new
  rule moves it: regenerated (tests/style-cvc-ref.txt header). No balance gates.

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
- **Reverted 2026-11-07** (the user: 「幫我將觸發的毀魂技改回【AS 改變指針前指向的毀魂技】」, DEVLOG §615): an AS's Kikon is the pointer
  **before** the AS wrote it again: its cinematic, its Konpaku profile and, while it is in play, the Soul Break profile. AS n still writes
  pointer n for the next NS. `core-as-start!` sets `fighter-sp-ptr` to the old `fighter-ptr`. Hisagi's host test pins it (Bankai pointer 1,
  AS2 writes 2, the Kikon's pointer 1).
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
- **The Soul Break's cinematic by the pointer** (2026-10-28, the user: 「如果是血量歸零自動釋放到毀魂技，一樣選擇當前指針對應的毀魂技」): a
  Soul Break (the Reiatsu at zero) of a core kit plays the current pointer's Kikon cinematic (`core-soul-break-cine`: `:core
  :kikon-cines` by `fighter-ptr`; during an AS the pointer is already the one it wrote, so it agrees with the Konpaku profile), else
  the kit's own as before (`kit-kikon-cine`: KESSA's `:soul-break-cine` hook, the :kikon move's). Browser (2502 + 2314, NS1 ×3 three
  times at pointer 1): `SOUL BREAK on P2: -3 konpaku`, `cine IC-HEAVY-KIKON-CINE` (was the Shikai's `IC-KIKON-CINE`).
- **A wave's Kikon** (2026-10-28, the user: 「我發現月牙天衝揮出去後都無法打出毀魂技」; asked how, 「打中後瞬步衝過去補一刀」). A hazard's hit
  was never a Kikon (`apply-hit`'s rush needed a melee hit). Now a hazard records the core NS / AS segment that fired it when that
  segment has `:params :kikon-strike` (`hazard-sp-mv`, set in `spawn-hazard`); its hit, with the hold kept since that segment
  (`fighter-sp-held` `t` and the button down) and the owner still in it or idle, is the Kikon's first strike (`core-wave-strike`):
  the victim is knocked back as by any held SP, the owner starts the strike move in phase `:follow` (`core-wave-follow!`), flash-steps
  in (`:look :flash-step`: afterimages only; `:follow-cap` 40 m/s instead of 22, so it closes from 12 m) and the strike's hit is the
  Kikon, cancellable by an attack as every follow-up. The strikes are classed as their segment (`build-core-classes` tags a
  segment's `:kikon-strike` with its class): Ichigo's Shikai `:ic-wave-strike` (NS2c JUJISHO) / `:ic-wave-strike-as` (AS2b), KESSA's
  `:ic-k-wave-strike` / `-as`, the charged X of both blades (80, its swing replayed on the strike by `:clip-2`, the Getsuga glow by
  `:charge-mult` 1.7). Browser check (debug 2502 + 2511): NS2 ×3 held at 2.2 m and at 6.8 m → `WAVE -> P2 HIT 150`,
  `IC-WAVE-STRIKE`, `KIKON FOLLOW-UP`, `KIKON 80`, −2 Konpaku, `IC-KIKON-CINE`; J ×3 > AS2 ×2 held → `WAVE -> P2 HIT 60`,
  `IC-WAVE-STRIKE-AS`, `KIKON 80`. Gates: Ichigo's three pairings at 10 seeds identical to the run before it (the CPU never
  holds through a wave), G2 unchanged.
- **The hold confirmed after the hit** (2026-10-28, the user: 「把毀魂技的按住判定時間拉長」; asked which way, 「打中後要多按住幾幀」, the
  frames left to me). The hit frame alone decided it; now the button (the phone: the contact) must also stay down for the first
  `*core-kikon-confirm*` = 12 frames of the dash-in (phase `:follow`, after the hit's 8-frame hitstop: 20 frames, 0.33 s, after the
  hit). A let-go inside them drops the Kikon (`P1 lets go: no Kikon`, `core-kikon-undo!`): the hit becomes the ordinary one it would
  have been (`apply-hit` keeps it in `fighter-kikon-undo`: the victim in the move's own reaction, stun and knockback, the frames he
  already reeled taken off, the lock cleared) and the SP goes on in its move where it hit (phase `:main`), so a string's next segment
  still follows; a wave's strike ends with the owner free. The follow-up's cues (the KIKON call-out, the take-off) wait for the dash-in's
  first frame (`core-follow-cues`), so a tap released in the hitstop shows none. A wave's strike is judged the same way. The CPU, held
  at the hit, keeps the press through the confirm (`core-brain-step`), so its Kikons are as before. Browser check (debug 2502 + 2510 +
  2393, Shift + J held from 0.02 s, NS1a hits at +0.37 s): held 1.6 s → `KIKON 68`; let go at 0.30 s → no follow-up (as before); at
  0.40 / 0.50 / 0.60 s → `KIKON FOLLOW-UP`, then `lets go: no Kikon`.
- **The phone's confirm: the whole dash-in** (2026-11-04, the user: 「目前手持模式很容易誤觸毀魂技，請延長啟動觸發的判定」): the phone's hold
  starts with any new contact in the SP zone, so a thumb resting there through the 12-frame confirm still slipped into Kikons. Now
  ONE-HAND's P1 is judged on the whole dash-in (`*core-kikon-confirm-touch*` :dash, `core-confirm-frames`: KIKON-FOLLOW-WAIT = 41 − S,
  19–27 frames), so the contact must stay down 27–35 frames (0.45–0.58 s) after the hit instead of 20 (0.33 s); the HUD's hold ring
  counts the same frames. Keyboard, pad and the CPU unchanged (12). Browser (`--mobile --size 390x844`, KK 2503 + 2393, an SP tap then
  a re-press held): 0.35 s and 0.55 s → `lets go: no Kikon` (0.55 s was a Kikon before), 0.75 s and 1.6 s → `KIKON 70`. Host tests
  9831, touch-test 100 pass, G2 identical.
- **The knockback waits for the confirm** (2026-11-04, the user: 「目前會有個問題是就算沒觸發毀魂技有時候也會將對手彈開」; asked, 「確認後才擊退」):
  an SP still down at its hit knocked the victim 2.5 m back (`*kikon-follow-kb*`) on the hit frame and the dash-in started, so a
  let-go inside the 12-frame confirm turned it back into an ordinary hit with the victim already slid away (scripted: 狂嵐 NS a held
  0.3 s, Ichigo ~2 m off; tapped 0.08 s, he stays in reach). Now a core SP's held hit (`apply-hit`) puts the victim in the move's own
  reaction, stun and knockback; the striker stands for `core-kikon-defer` = `*core-kikon-confirm*` frames after the hitstop; still
  held then, `core-kikon-knock!` gives the Kikon's reel (`kikon-follow-stun`) and the 2.5 m knockback and the cues, and the dash-in
  runs its `kikon-follow-wait` from there (so a Kikon's follow-up lands 12 frames, 0.2 s, later than before). A let-go inside the
  defer leaves the victim as he is (`core-kikon-undo!` sets him back only after it: the phone's later let-go, its confirm being the
  whole dash). An old-style rush (`:kikon` moves) and `*core-kikon-confirm*` 0 are unchanged. Scripted (84004 / 84005, Shift + J held):
  0.3 / 0.36 s → `lets go: no Kikon`, the victim where the tap leaves him; 0.6 s (狂嵐) / 0.9 s (斬壞) → `KIKON`, 62 frames after the
  hit (50 before). A shared rule (every core kit, the CPU holds through the confirm): G2 not run at this stage (DEVLOG §576).
  Since 2026-11-05 (DUEL_KEN_V3 §39) a held SP's **knockdown / launch** waits on his feet instead: in the air he landed and was down,
  unhittable, before the follow-up strike, so the Kikon of a one-segment knockdown AS (the sealed AS1, AS2's launch, 狂嵐's AS1) never
  landed. `apply-hit` gives a stagger for `*core-kikon-confirm*` + `*kikon-air-hold*` (4) frames, no knockback; a let-go inside the
  confirm gives the knockdown / launch then (`core-kikon-undo!`).
  G2 for both (run 2026-11-05 after the sealed form, DUEL_KEN_V3 §42): each moved all three pairs, II included (Ichigo's Kikons go
  through the same path): II 279.9 -> 365.5 s after the confirm wait, -> 399.2 s (P2 0-1) after the stagger.
- **Shikai AS3's tap** (2026-10-28, the user: 「常態的 AS3 不知為何非常容易誤觸出毀魂技」): SOSEN-GIRI (`ic-as3`) hits 8 frames after the SP
  press that starts it, sooner than a tap is up, so a tap was "held" at the hit. The confirm above is the fix: the tap is released in
  the 8-frame hitstop, so the dash-in's first frame undoes it and the AS goes on. Browser (2502 + 2393, J ×5 then Shift + J): held 0.15
  / 0.25 s → `KIKON FOLLOW-UP`, `lets go` 9 frames later, then the next SP's RANGETSU 18 ×4; held 1.2 s → `KIKON 45`,
  `IC-RUSH-KIKON-CINE`.
- **The phone's hold in the SP zone** (2026-10-28, the user: 「程式的毀魂技觸控判定並沒有區分 SP 跟攻擊的差異，所以如果打完 SP 後按住攻擊的區域也一樣會
  觸發毀魂技」): the re-press counted any contact on the pad. Now only one that went down above the tap split, the SP's zone, counts
  (`core-touch-sp-p`: `touch-oy` < `touch-split-y`, a tap's own test), for the `:rearm` and for the hold. Browser (`--mobile --size
  390x844`, 2502 + 2393): the SP tap at y 530, then held at y 530 → `KIKON 68`; held at y 697 (the attack's zone) → `IC-N1A` hit, no
  follow-up (§436's check had held the attack's zone).
- **The phone fires on the press inside a move** (2026-10-28, the user: 「如果我將攻擊的觸發判定都修改成「點擊觸發」會有什麼衝突嗎」; told every
  drag, flick (Step), rested up-flick (Hoho) and down-flick (Burst) starts with the same touch-down, three options offered, the user
  chose 「1」: on the press inside his own move, on the lift in neutral). The recogniser has a game flag `touch-press-tap` (set each frame
  by `onehand-frame` while P1 is in state `:move`) and a knob `press-ms` 40: a contact still inside the slop for 40 ms is its tap then
  (`%tap!`, the zone where it went down), and its lift gives none (`touch-pressed`); one that leaves the slop sooner is a flick (an
  attack's up-flick Hoho fires no attack), one lifted sooner is the usual lift tap. In neutral nothing changed. So inside a string an
  SP pressed and kept down is its own Kikon hold (the `:rearm` turns `t` on the next step, the contact being in the SP zone), no
  re-press. Host: `tests/touch-test.lisp` (three cases, 71 checks). Browser (`--mobile --size 390x844`, 2502 + 2393; a low tap, J1 hits,
  then the SP zone 0.25 s later): held 1.6 s → `IC-AS1`, `KIKON FOLLOW-UP`, `KIKON 50`; tapped 30 ms / 100 ms → `IC-AS1` hit 50, no
  follow-up; an up-flick in the attack zone → `HOHO`, no attack. The sim gates have no touch: unchanged.
- Gates for the four above and §6's NS3 fixes (all six pairings; G2's three CPU matches unchanged, native == browser): the confirm alone,
  before the CPU kept its press through it, lengthened Ichigo's matches (10 seeds: IK 201.1, HI 204.1 s); with it, KK 167.2, HK 146.3,
  HH 172.4 s (10 seeds, identical before and after the NS3 fixes), and after them IK 192.6 s (20 seeds, Ichigo 8:12), HI 196.5 s
  (20, Ichigo 10:10), all K.O.; the Ichigo mirror 221.4 s at 60 seeds with 2 time-outs of 60 (211.3 s and 20 K.O.s at 20 seeds before
  the NS3 fixes): accepted as an exception (the user, 2026-10-28: 「列為例外」, DEVLOG §445).
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
| Shikai | 1 the cleaver's weight | the cleaver overhead, the K string | AS1 RAKUGA's drop (50, steals 80 flash-step, the attacker gaining 50 %; 120 before 2026-11-12, 40 of 100 before 2026-10-29, §2.2) | `ic-heavy-kikon-cine` (new) |
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
  the clones 35 + 35, AS2 50 with 35 + 35.
- **NS3 fixes** (2026-10-28, the user: 「如果點太快的話，NS3[2] 的斬擊會直接被跳過接成 NS3[3]」, 「NS3[3] 打完後對手會強制倒地導致後續的 SA 攻擊接不上
  （還是說這是刻意設計的？）」; not meant). (1) A clone's swing began after `*clone-lag*` (6), so NS3[2]'s landed on its frame 18 while
  NS3[3] can start on frame 14 and takes both clones for the X on its frame 2: a quick third press ate the cut. NS3's clones now swing
  with no lag (`ichigo-ns-clone`), on frame 12. (2) The X (`:ic-c-xa` / `-xb`) knocked down, so the SA after it whiffed; it staggers now.
  Browser (74001 + 2512, SP at 0 / 0.32 / 0.58 s, J at 0.75 s): before, clone hits 18 (NS-A) and none for NS-B, X 38 + 38, the SA no
  hit; after, 18, 18, X 38 + 38, `IC-K-SA -> P2 HIT 50`.
  **The clones replay him** (2026-10-28, the user: 「請幫我設計讓卍解的分身會重現本體的行為（包含 J 與 SP），每個分身在重現動作時的傷害與效果
  （像是剝奪閃步量表等等）是本體的 10%，同時也能受到蓄力月牙的加成」; asked: 「一個慢 4f 一個慢 8f」, the SA his alone, waves and the chain's
  pull replayed too, 「應該只包含 NS3 之後接的 J 跟 AS」). The heavy / light answers to his presses are gone under the core system; each J
  and each AS he starts while NS3's clones are out (not AS3, whose clone cuts are its own theme; not the SA; not a Kikon's dash-in
  strike) is queued on each clone (`clone-replay-watch`, by the move's start tick) and played back `*clone-replay-lags*` behind (the
  right clone 4, the left 8): the clone stands where he stood then (`hist-at`) at its side, faces the opponent, strikes each of the
  move's hit windows (`ichigo-strike`) and fires each of its waves (`clone-wave`, never a Kikon's first strike: `:sp-mv nil`) at
  `*clone-replay-scale*` 0.1 × his charged Getsuga's x (`core-charge-mult`); a landed replay hit does the move's effects at that x
  (`clone-replay-hit!`: an AS's flash-step steal via `core-on-hit!`'s new MULT, the chain's pull toward the clone). (The charge's x
  and the clones never meet in the current routes: the charges arm only in NS2's string, the clones live only in NS3's.) A clone's hits in the
  air no longer count as clones (`clone-p` checks the clone's hook: they doubled the replays and filled the cap of 3). Browser
  (74001 + 2512): NS3 ×2, the SA, J ×3, SP ×2 → each J2 / J3 / J4 / AS2 / AS2b replayed once per clone (`clone NS-A replays …
  x0.10`), hits 3 for the body's 30, the clones' waves 6 + 6 for his 60; NS3 ×2, the SA, SP → AS1's four lashes 14 each and the
  clones' lashes 1 each, P2's flash step 100 → 69 after three of his and one of theirs (10 + 10 + 10 + 1).
  KESSA's stances by pointer: `:ic-st-rush` / `:ic-tsuki` / `:ic-k-stance` (low, the slab trailing /
  cocked high behind / hanging point-down; the slab on the shoulder at 1 read too close to 2's).
- **KESSA's own core set** (§428, the user: 「要，都幫我換一換」, 「另外指針一的 NS 幫我換成使用血鎖進行近身抽打，中立站姿也改成血鎖圍繞在身邊，並且切換成指針一的 AS
  也做成血鎖的攻擊」, 「指針三的毀魂技使用之前的「千影」動畫」): KESSA's `:core` is `:ns (:ic-k-n1a :ic-k-n2a :ic-k-n3a) :as (:ic-k-as1 :ic-k-as2 :ic-k-as3)
  :sa :ic-k-sa1`; no Shikai clip is played in KESSA (a host check). NS1 is the blood chains from his left fist: `ic-k-n1a` a wide lash (S 22,
  60) → `ic-k-n1b` the backhand (S 14, 55) → `ic-k-n1c` overhead into the plaza (S 18, 80, crumple), reach 3.0 / 3.0 / 3.2 m; AS1 is
  KUSARI-BIKI as a whip (§430, the user: 「血鎖 AS 也改成多段的鞭擊」: `ic-k-as1`, clip `:ic-k-whip`, four lashes in one press, 14 each, left /
  right in turn, the last a knockdown; 30 flash-step stolen a lash, 10 on the 0–100 gauge). The chains come out of both wrists and both ankles (§430: 「血鎖是從手腕、
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
  **Overturned 2026-11-13** (DUEL_SP §6, S5; §2 "Projectiles are in the triangle"): the wave is judged as the segment that fired it, so
  JUJISHO (NS2c) is cancelled by a J or an SA meeting it (Ichigo refunded its 60), beaten by an AS, and hits an NS; AS2b's wave (`:as`) is
  cancelled by a J, hits an NS, and against an AS / SA the later start wins. The Kikon off a wave (§4, 2026-10-28) stands.
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
  (they steal flash-step since the 0–300 gauge, 2026-10-29 (120, 40 before); per-hit values and a 50 % gain since 2026-11-12, no cap, §2.2). The gauge itself still fills in the sim (KOSEI, hits, regen) and the frozen modes still read it.
- **No guard gauge** (the same day: 「防禦量表也一樣沒用了，可以移除」): there is no guard, so the bar under the Reishi and the KOSEI tag at
  its end are not drawn for a `:core` kit, in the landscape and the portrait (phone) panels; the portrait's last row is then FLASH STEP +
  AWAKEN at half width each (+ the kit meter where there is one). Shots: 1280x720 and 390x844 (DEVLOG §420). The sim still keeps the gauge
  (KESSA's clones still spend 15 of it, unseen: left for his rework).
- Debug: 2510+p sets P1's pointer (stance shots, DUEL_GAMEPLAY).
- Tests: `tests/duel-rules/triangle.lisp` (+7: tells >= 14 f, NS2 a wave with no melee hit, stance by pointer); `core.lisp`'s J1 budget and the clip
  list (`:ic-na1 :ic-ns1 :ic-ns2 :ic-ns3`), `art.lisp`'s striker table (`:ic-na1`).

## 7. Status

See DEVLOG §410 onward for each stage's numbers.

## 8. A Hoho off a hit continues the combo (the user, 2026-10-28)

The user's request (verbatim): 「讓攻擊中接入 hoho 後會延續攻擊 combo」. Asked (AskUserQuestion): what continues — **「接下一段，並保住連段
（推薦）」** (rejected: the combo count only, J restarting at J1; the next link only, the victim's stun not held); which attacks — **「J 與
NS 段（推薦）」** (rejected: J only; J, NS and AS).

- A Hoho cancelled out of a landed NA link, an SA or an NS segment remembers that move. During the Hoho (and for
  `*hoho-resume-frames*` after it) J or SP goes on from it: after an NA link / the SA, J is the string's next link and SP the AS of the
  press count; after an NS segment, SP is its next segment and J that gap's SA. The press count, the pointer and a charged SA's x carry
  over. An AS is an ender: no resume from it.
- The victim's reaction cannot end while the Hoho holds him: the attacker in that Hoho, in the resume window, or in the resumed move's
  startup / active frames (as the guard lock holds a blockstun). The combo count and its damage scaling go on.
- As built: `fighter.lisp` `START-HOHO` records the move (`fighter-hoho-from`, its class, press count, charge x), `HOHO-STEP`
  latches J / SP and resumes at its end (`HOHO-RESUME!`), `NEUTRAL-STEP` takes a press in the window (`HOHO-RESUME-PRESS!`,
  `*hoho-resume-frames*` 12, tuning.lisp), `STUN-STEP` holds the victim (`HOHO-HOLDS-P`); `CANCEL-INTO` lets a Hoho out of any NA / SA /
  NS move (an NS of kind `:sp` too). Browser (Hisagi at 2 m from an idle Kenpachi): J1 > Hoho > J → `HOHO -> HS-J2`, then J3 (the HUD
  2 HITs after J2); J pressed 0.1 s after the Hoho's end resumes; J1 > Hoho > SP → AS1 50; NS2a > Hoho > SP → NS2b, then NS2c; NS2a >
  Hoho > J → the SA KIRI. The CPU never Hohos off a hit, so the sim gates and G2 are identical to before: KK 167.2, IK 192.6, II 231.6,
  HK 183.8, HI 190.4, HH 295.7 s (10 seeds; HH's 4 time-outs are §27.9's, Hisagi's), cvc ii / ik / kk PASS. Teaching the CPU this is
  left for later.

Since 2026-11-14 (§2.1.2) no Hoho starts while an exchange is open, so this combo Hoho is refused in a combo that began from a cancel until
both fighters are back in neutral; a combo from a clean hit keeps it.

## 9. PRACTICE's GUARD ALL cancels (the user, 2026-11-12)

Request: 「練習模式 DUMMY 的「GUARD ALL」會自動使出能跟對手相消的攻擊」. A `:core` kit never guards, so GUARD ALL held a guard that did
nothing for the three live kits; it now means "cancel all": the dummy answers each incoming hit with a press that puts it inside the
startup / active frames of a move the triangle (§2) cancels that hit with. A retired, non-core dummy keeps the old guard; STAND,
GUARD AFTER HIT and CPU are unchanged; the label stays GUARD ALL (the manual: 自動出招與你相消).

- **The rule** (`dummy-cancel-press`, control.lisp, pure and host-tested; flow.lisp `dummy-cancel-input` gathers its inputs each sim frame
  and presses J or SP on P2's pad for one step, nothing else). Only presses a player could make: from neutral J (NA1) or SP (the pointer's
  NS) on the next step; inside its own move the latched continuation (the next NS segment, the SA in an NS gap, the next J link once its
  attack touched him, the next AS segment), which starts when the current segment's active frames end and can be latched until its
  recovery ends. No invulnerability, no state edits. Nothing when no hit is coming (the player idle, in recovery, every window spent,
  out of reach + slide + 1 m), so the dummy never starts a fight.
- **The answer** (`core-verdict` with the dummy's move starting later): his NA → NS (SP), his SA → NS, his NS → NA (J) or, inside its
  own NS, the SA (J), his AS → NA. Never his own class (a same-class tie cancels only on the same frame); a non-turn move (NA / NS) over a
  turn move; no press while its own window already covers his hit.
- **When**: as late as it still works, `*dummy-cancel-lead*` = 2 frames before his hit is due, or on the latest frame that also lets its
  own hit land inside his window (then his move is cancelled even when his hit whiffs: a dead zone, a step out of reach), or on its
  latch's last frame. So against a J string it rides its NS segments, each started just before the J it answers; its own hit lands on him
  only once he stops attacking.
- **What cannot be cancelled** (the hit lands, as the rules say): a classless hazard (NS3 / AS3's own clone cuts; until S5 every hazard,
  scene h `WAVE -> P2 HIT 150`); a Kikon's follow-up (not a main-phase move); the SA after his NS (the dummy answered the NS with NA, and from an NA
  only J links or an AS start: NA takes an SA's hit, the AS's armour only absorbs it; `KE-Z-SA1 -> P2 HIT 30`); his AS after a J it
  cancelled (only NA cancels an AS, and the dummy is in its NS: `KE-Z-AS1 -> P2 HIT 90`, against Ichigo its NS's hit `ABSORBED` by the
  AS's armour); a J string longer than the dummy's NS route (Kenpachi's three segments cover four of Hisagi's five J: `HS-J3 -> P2 HIT
  38`); a hit too far away (scene i: no answer); a hit while the dummy is in recovery or a reaction.
- **Hisagi's trait** (§29 of DUEL_HISAGI): a cancel turns `KIN` on, but GUARD ALL then cancels the route that follows too, so his NS1b /
  c reach the dummy inside the 3 m dead zone (`P1 HS-N1B x P2: CANCEL` at d 1.70; against DUMMY STAND the same presses make no contact at
  all) without landing. J1 → cancel → `KIN on` works, but J1 → SP is an AS (rule 5) and neutral turns KIN off, so "J1, then NS1" cannot
  carry it.
- **Tests**: 16 host checks in `tests/duel-control-test.lisp` (24 since S5's waves, 2026-11-13; the table, the lead's edges one frame each side, the double-cover frame,
  nothing when idle / no class, a latch's last frame, no press while covered, never the same class, NS segment vs SA inside an NS, a
  retired kit's guard); debug 2800-2815 (DUEL_GAMEPLAY) and `tests/scripts/duel-practice-cancel.json`. Cancelled / total of the
  player's hits (native = browser): J1 1/1 in all six pairs (KK KI IK IH HK HI); the five J 5/5 (HK 4/5); NS x3 3/3 (Hisagi's NS1a whiffs
  in its dead zone, cancelled by the dummy's J1, then 2/2); NS then SA 1/2 (0/1 for Hisagi); J then AS 1/2 (Hisagi's four-hit AS1: 1/5);
  the dummy's own hit landed on the player 4 times in 30 scenes, all after a lone J1 (KK, KI, IH, HI). Idle 3 s: no press. G2 identical.
- **After the symmetric cancel** (§2.1, 2026-11-12): the dummy's move counts as landed when the player's hit is the one cancelled too, so
  its J link / AS / SP cancels open (`dummy-starts` offers the next J at once). Rerun of `duel-practice-cancel.json` (no before log per
  scene, only the counts above): every count above unchanged, all six pairs and scenes g-k (39 scenes; the wave lands, 6 m: no answer, STAND / GUARD AFTER HIT / CPU / COUNTER as before) (after a lone J1 the dummy's NS still
  goes on and lands, `KE-Z-N1A -> P1 HIT 65` in KK; the SA after the player's NS still lands, NA cannot cancel an SA; idle 3 s: no press). The dummy presses only to cancel, so it
  never uses the AS that now opens for it.
- **Waves** (DUEL_SP §6, S5, 2026-11-13: the dummy tries to cancel waves too): `dummy-wave-threat` (flow.lisp) finds the soonest of the
  player's classed waves to reach the standing dummy (`wave-arrival`, control.lisp, pure, host-tested against `obox-cyl-hit-p`) and
  `dummy-cancel-input` answers the sooner of that and his melee hit (gap 0, the wave's class: J against JUJISHO's NS). Browser rerun of
  `duel-practice-cancel.json` (40 scenes, exit 0): scene h (2.2 m) `P2 move KE-Z-J1` and `P1 wave ns x P2: CANCEL` on the same tick (the wave
  is spawned 1 m ahead and arrives a frame later; the dummy's J1 then lands on Ichigo's recovery, `KE-Z-J1 -> P1 HIT 35`), new scene h2
  (6 m) J1 five frames before the wave, `P1 SP refund 60.0 (fs 280.0)`, `P1 wave ns x P2: CANCEL`; every other count above unchanged.

## 10. SP: segments pay the flash-step gauge (DUEL_SP, batch S2, 2026-11-13)

The user (2026-11-12): 「讓 SP 攻擊會消耗 SP 量表，當量表不足時還是能強行發出一段攻擊……當用 NS 打出相消時會停止消耗 SP 量表。」 The rules are
DUEL_SP §3-§4; what the core system does with them:

- **Who pays**: every NS and AS segment (one with a cost in its kit's table, `kit-sp-cost`; built once per kit at registration,
  `build-sp-costs`: the segment's damage x 0.4 x the kit's `:core :sp-cost-mult`, rounded to 5, 10-60, or a `:params :sp-cost`). Free:
  NA links, the SA, the Kikon hold and a wave's Kikon strike, the pointer switch's DRIVE path (until S6).
- **Where**: `core-start!` (core-sim.lisp) is the one paying place. It is reached by the neutral SP (NSa), the latch (the next NS / AS
  segment), the AS (an `:as-pick` move pays as the move it names; `:taken` pays nothing), a Hoho's resume (`hoho-resume!`, now through
  `core-start!`) and a parry's catch (combat.lisp `:parried`: Kenpachi's tame -> thrust is an NS segment and pays like one).
- **Refused**: a later NS segment at 0 (`sp-start-p`: an AS always starts; NSa, a route's first segment wherever it starts, always): nothing
  starts, the press was already eaten at its latch, `(emit :refused e :sp)` (feedback.lisp plays its dud tick; no HUD cue yet: S8).
- **Paid**: min(cost, gauge) through `spend-fs`, which restarts the 60 f regen wait, also when it paid nothing at 0 (else the regen's
  trickle opens every later segment of a route at 0); nothing in a burst (`spend-fs` not called; the segment's cost is recorded as 0, so
  full damage, Q7). The fighter keeps `sp-paid` / `sp-cost` of his last segment until his next move starts (`start-move` clears them for any move; idle, Hoho, Step and a reaction keep them, so a reader of the scale checks `cls` and the move, as `apply-hit` does with `own`; S8's HUD mark must too).
- **Scaled**: `apply-hit`'s damage factor is the pure `hit-px` (rules.lisp: charge x SUBLIMATION x the kit's `:dmg-mult` x `sp-scale`),
  so only the damage scales (0.5 + 0.5 x paid / cost); reaction, stun, knockback, combo counts are read beside it. A hazard's hit is
  unscaled until S5; since S5 (2026-11-13) a hazard's damage uses the scale frozen when it was fired (`hazard-sp-scale`; a KESSA replay the summon segment's). The damage-keyed readers follow the dealt damage (gains, SUBLIMATION fill, the
  victim's `*fs-taken*`); the prices (Kenpachi's Bankai Reishi cost) and the hitstop (from move data) do not.
- **Refunded**: `core-nohit!`'s `:cancel` gives each side whose segment is NS / AS what it paid, once (`sp-back`), through `refund-fs`
  (capped at 300, no SUBLIMATION factor, nothing withheld in a burst, the regen wait untouched). An `:absorb` is not a cancel (Q5).
- **The hash line**: `s<sp-paid>` per side replaced the dead `h<heat>` (DUEL_GAMEPLAY "Log lines").

## 11. SP: the ATK gains, KOSEI gone (DUEL_SP, batch S3, 2026-11-13)

The user (2026-11-12): 「使用 ATK（包含 J 與 SA）造成傷害會恢復 SP，ATK 相消則會恢復更多 SP」, 「J 命中 +10」; Q3 changed to per hit window (DUEL_SP §8.6).

- **A hit** (combat.lisp `apply-hit` -> `sp-atk-hit!`): every damaging hit window of the attacker's own J link (class `:na`) pays +10 and of
  his SA (`:sa`) +15 (`sp-atk-gain`, sp.lisp; `*sp-gain-j*` / `*sp-gain-sa*`), through `pay-gauges` (nothing in a burst, x the SUBLIMATION
  bonus: its pure core is `fs-gain`, rules.lisp, Q2 / Q18). A multi-hit SA pays per hit window; a block, a whiff, a hazard, a Kikon strike
  and every NS / AS contact pay nothing. A kit may scale it with a `:hooks :sp-gain-mult` function of the attacker (Hisagi's Bankai: the tip
  and spread-route x1.3, below); no hook: x1.
- **A cancel** (`core-nohit!`'s `:cancel`): each side whose move is a J / SA takes +30 (`*sp-gain-cancel*`), once per move (`fighter-sp-gain-t`
  = the move's `cls-t`, so a tie's two verdicts pay once each), instead of any hit gain (a cancel deals no damage); an NS / AS side is
  refunded (S2). A tie of two J's: both +30; J vs NS: the J side +30, the NS side its payment back.
- **KOSEI is gone**: its only output was flash-step, which the table above replaces (the user's design: SP moves pay SP, ATK earns it).
  `kosei!`, `kosei-mult` / `kosei-base` / `kosei-gain`, `*kosei-bonus*` / `*kosei-fs*` / `*kosei-kind*` / `*kosei-kind-other*` and debug
  27000+k left; the combo bonus (`combo-gain-mult`) still scales the damage-taken gain. `*fs-taken*` (damage taken) is kept. DUEL_STRINGS §5 is the record of the old rule.
- **Tests**: `tests/sp-costs-check.py` (native scripts, both sides' inputs): J1-J3 on a dummy +10 each; NS1a then its SA +15 (the NS hit nothing); J tie
  +30 both, once; J vs NS1a +30 / refund; J1-J3 in ORANGE / WHITE / BLUE +0 (the gauge only drains); Hisagi's Bankai J1 at the tip +16.9, off
  the tip +13.0, Shikai +10; AS3 from 0 refills by its J string's five +10; a route at 30 follows exactly (fs' = fs - paid) and the segment at 0 is refused. Host: `fs-gain`, the hook's marks.

