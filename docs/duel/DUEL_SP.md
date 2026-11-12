# DUEL_SP — SP spending on the flash-step gauge (design, 2026-11-12)

Status: **rules final (the user, 2026-11-12), not built.** Implementation plan: §8 (to be written with the Fable advisor's review).

## 1. The request and its intent

The user (【討論】, 2026-11-12): 「我想讓對戰避免隨意的 NS 空揮並獎勵相消與其後的 AS/SA 看破，因此想引入 SP 量表。讓 SP 攻擊會消耗 SP 量表，當量表
不足時還是能強行發出一段攻擊，因此不會有打不出 NS1 的情形（會扣至 0）。當用 NS 打出相消時會停止消耗 SP 量表。使用 ATK（包含 J 與 SA）造成傷害會恢復
SP，ATK 相消則會恢復更多 SP。當相消後突破對手防線將會奪取對方全數 SP。」 Later: 「我其中一個意圖也是讓 SP 變成一種緊湊的資源循環，只要足夠積極就不用害怕
消耗。」, 「不讓 SP 能自然恢復就是為了抑制透過等待回到平等局勢，而是鼓勵角色發起進攻奪回優勢。」

History: the old SP / Reiatsu gauge was removed on 2026-10-27 (「原本的 SP 量表已經沒有作用，可以拿掉了」, DUEL_CORE "No Reiatsu gauge"). Its
internals still fill in the sim and become dead code once this is built (§7).

The post-cancel read this rewards already exists since the symmetric cancel (DUEL_CORE §2.1): after an NA-vs-NS cancel the NA side picks a J
link or the AS, the NS side its next segment or the SA: AS beats NS, SA beats J, J vs NS cancels again, AS vs SA the later start wins.

## 2. One gauge: the flash-step gauge pays SP

The user, asked whether the flash-step gauge could be the SP gauge, proposed the guards that make it work: 「如果最後一格永遠不會被拿走、自然恢復的
上限是一格、爆氣期間的 SP 攻擊不消耗、三色爆氣皆改成一格可放，這樣的設計呢？」 (the lead recommended it, the Fable advisor agreed).

| Rule | Value |
|---|---|
| The gauge | the flash-step gauge, 0-300, three cells of 100; starts full and is kept through Kikon / Konpaku resets (the user: 「可以」) |
| Natural regen | `*fs-regen*` 4.5 / s after the 60 f delay, **only while below one cell** (fills to 100, no further) |
| Hoho | 100, as now |
| Bursts | **all three start from one cell** (`*fs-burst*` 200 -> 100); BLUE still burns one cell, WHITE / ORANGE drain to 0 |
| During a burst | **SP attacks cost nothing** (bursts still gain nothing) |
| The last cell | **never taken** by any steal: a victim at 100 or less loses nothing |

## 3. Paying

| Rule | Value |
|---|---|
| What pays | every NS segment and every AS segment (the user: 「AS 要花，規則跟 NS 一樣」), charged when it starts |
| A hit | still costs (the tight loop by intent) |
| A cancel | 「只要這段 SP 發生相消就不扣除量表」: a segment that takes part in a cancel (either side of it, DUEL_CORE §2.1) is refunded what it actually paid |
| Short of the cost, NS | 「NS 的每一段只要量表不是 0 都可以強行出，但是會受到傷害折算」: any segment starts while the gauge is above 0 and pays what is left; NSa (a route's first segment) also starts at 0 (「不會有打不出 NSa 的情形」); a later segment at 0 is refused |
| Short of the cost, AS | 「就算量表不夠支付，依舊能打完整套 AS，但讓傷害折算」: every AS segment starts, also at 0 |
| Damage scaling | a segment that paid P of its cost C deals damage x (0.5 + 0.5 x P / C) (the floor 50 %: the user 「可以」); only the damage: reactions, stun, knockdowns, the Kikon hold unchanged; a refunded (cancelled) segment dealt no damage anyway |
| The Kikon hold | free (「接毀魂不用花」) |
| The pointer switch | costs only SP: the first segment of the pointer switched to, as an ordinary NS segment; refused at 0 (「拒絕」); opens once the awakening gauge **has been** full (「量表滿過就能開」), the DRIVE threshold `*drive-switch*` goes |
| DRIVE / SUBLIMATION gains | halved (the user) |

## 4. Costs by segment strength (「依據每段 NS 的強度調整消耗量」)

- Default per segment: cost = its total damage x 0.4, rounded to 5, clamped 10-60 (multi-hit: the sum; a wave: the wave's damage; a setup
  segment with no hit of its own, e.g. Ichigo's NS2a / b, KESSA's clone summons, Kenpachi's NS3a: 10). A move may override it in its data.
- Kenpachi pays Reishi for his SP attacks, so his costs come back to the roster's mean (the user: 「劍八的 SP 攻擊會扣除自身血量，作為交換，請將他 SP
  造成的消耗降回平均水準」): a per-form multiplier on his kits making each form's mean segment cost equal Ichigo's and Hisagi's (23.2):
  base x0.76, Shikai (NOZARASHI) x0.68, Bankai x0.71, Bankai-2 x0.51.

Route totals of the first table (Hoho = 100):

| Kit / form | NS1 | NS2 | NS3 | AS1 | AS2 | AS3 | AS4 |
|---|---|---|---|---|---|---|---|
| Kenpachi base | 60 | 55 | 65 | 25 | 50 | 70 | — |
| Kenpachi Shikai | 85 | 125 | — | 80 | 110 | 25 | 25 |
| Kenpachi Bankai | 70 | — | — | 30 | 50 | 70 | 90 |
| Kenpachi Bankai-2 | 85 | — | — | 30 | 50 | 70 | 90 |
| Ichigo Shikai | 85 | 80 | 70 | 20 | 45 | 90 | — |
| Ichigo KESSA | 75 | 80 | 30 | 20 | 45 | 80 | — |
| Hisagi Shikai | 75 | 75 | 25 | 25 | 45 | 80 | — |
| Hisagi ranged | 40 | 80 | — | 15 | 55 | 35 | — |
| Hisagi bind | 65 | 80 | — | 20 | 50 | 70 | — |

## 5. Earning

| Source | Value |
|---|---|
| A J hit | +10 |
| An SA hit | +15 |
| An ATK (J / SA) that takes part in a cancel | +30 (a same-class J tie: both sides +30) |
| SP-kind and Kikon contacts (KOSEI) | 0 (`*kosei-kind*` :sp / :kikon -> 0; the other KOSEI flash-step goes with the table above) |
| Being hit | kept: `*fs-taken*` 0.135 x damage x the combo bonus (the user: 「維持」) |
| Natural regen | only up to one cell (§2) |
| Bursts | nothing while one runs (as now) |

## 6. Breaking through after a cancel

- Any real hit after a cancel counts, J included (「都算」), by either side of it, until both are back in neutral (the exchange keyed on the
  two moves' start ticks, as `hs-bind-clash` does).
- It takes **50 %** (「50%」) of the victim's flash-step above the last cell (the last cell is never taken): the victim loses that amount, the
  attacker gains half of it, capped at 300. Once per exchange.
- Projectiles join the triangle (「將飛行道具回歸相消的攻擊體系中」, 「OK」 on the lead's definitions): a hazard's class is the segment that fired
  it; a cancel removes it and refunds that segment even after the move ended; an owner no longer in a move gets only the refund (no
  "landed"); wave vs wave stays as it is (ichigo.lisp); DUEL_CORE's "a wave beats every class at range" is overturned (Ichigo's pointer 2
  changes); PRACTICE's GUARD ALL dummy must try to cancel waves too. The live hazards: Ichigo's waves and KESSA's clone replays (Hisagi's
  chains are melee windows, already judged).
- The AS1 flash-step steals (DUEL_CORE §2.2: per hit, 50 % conversion) keep their values but never take the last cell.

## 7. Consequences and dead code

- Dead once built: the Reiatsu gauge's internals in the core path (gains, regen, `kikon-refund`'s Reiatsu read), `*drive-switch*`.
  Already dead (found 2026-11-12, the user: those designs no longer exist): the DRIVE-full Bankai gate (`drive-full-p` through
  `kit-bankai-form`, nil on every live kit), pointer locks (`:locks`, `core-pointer-locked-p`), the arm meter pips (`:pips`,
  `core-pips-ok-p`, `arm-spend!`). For the refactor's cleanup.
- Watch at the playtest: ORANGE with free SP attacks for its whole drain is the strongest offensive state; a defender at the floor spends
  his only cell on a BLUE; J is free and earns SP, and SA (the answer to J) lives only in an NS gap.
- CPU: the core CPU, the fuzzy rules, the MCTS light model and the strategy tables know nothing of costs: rule statements to add, nothing
  retuned. G2 moves. No balance gates (the user's rule): balance by playtest.
- HUD: the three cells and the 爆 dial already show the gauge; costs, refunds, scaled damage and the steal need cues.

## 8. Implementation plan

To be written (the lead with the Fable advisor's review), together with the paused refactor's re-plan (docs/engine/REFACTOR_2026-11.md).
