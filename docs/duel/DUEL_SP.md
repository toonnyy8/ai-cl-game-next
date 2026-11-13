# DUEL_SP — SP spending on the flash-step gauge (design, 2026-11-12)

Status: **rules final (the user, 2026-11-12); S0-S4, S6 and S8 built and merged (2026-11-13); S5 built (2026-11-13, branch); S7, S9 to come.** Implementation plan: §8 (written 2026-11-12, batches S0-S9, open rule questions in §8.6).

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
| DRIVE / SUBLIMATION gains | halved (the user: 「還要把 DRIVE 跟 SUBLIMATION 的恢復速率減半。」) |

## 4. Costs by segment strength (「依據每段 NS 的強度調整消耗量」)

- Default per segment: cost = its total damage x 0.4, rounded to 5, clamped 10-60 (multi-hit: the sum; a wave: the wave's damage; a setup
  segment with no hit of its own, e.g. Ichigo's NS2a / b, KESSA's clone summons, Kenpachi's NS3a: 10). A move may override it in its data.
- Kenpachi pays Reishi for his SP attacks, so his costs come back to the roster's mean (the user: 「劍八的 SP 攻擊會扣除自身血量，作為交換，請將他 SP
  造成的消耗降回平均水準」): a per-form multiplier on his kits bringing each form's mean segment cost to about Ichigo's and Hisagi's (23.2; set before the table's correction, kept):
  base x0.76, Shikai (NOZARASHI) x0.68, Bankai x0.71, Bankai-2 x0.51.

Route totals (Hoho = 100). Corrected 2026-11-12 by S0's host test (the table is computed from the kits' move data by the rule above, one
rounding, multi-hit segments summed): ten Kenpachi cells of the first version had been rounded twice (after x0.4 and again after the
multiplier) and his Shikai / Bankai NS1's two-hit ND counted once. The rule stands; the numbers follow the data. His AS pointers past
the table are priced by the same rule from their damage (S2, 2026-11-13; the note's earlier "no damage: 10" was wrong, they all hit):
the Shikai's AS5 DAISHARIN 60 (240 x 0.4 x 0.68, clamped), AS6 INSEKI-GIRI 60 (260), AS7 the Bankai burst 25 (100); the Bankai's AS5
CHIGIRI 60 (300), the Bankai-2's AS5 TATE-GOTO 60 (320). The table's AS3 / AS4 of the Shikai are its two bursts (100 each).

| Kit / form | NS1 | NS2 | NS3 | AS1 | AS2 | AS3 | AS4 |
|---|---|---|---|---|---|---|---|
| Kenpachi base | 55 | 55 | 60 | 25 | 50 | 75 | — |
| Kenpachi Shikai | 100 | 120 | — | 85 | 110 | 25 | 25 |
| Kenpachi Bankai | 90 | — | — | 30 | 55 | 75 | 95 |
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
- It takes **everything** of the victim's flash-step above the last cell (the last cell is never taken by a breakthrough) and the attacker gains **50 %** of it (the user, 2026-11-13: 「這邊是要奪取第一格以上的全部，並以 50% 效率轉換成自身量表」; built 2026-11-12/13 as 50 % taken, the lead having read 「50%」 as the share: `*sp-break-share*` 0.5 -> 1.0, `*sp-break-gain*` 0.5). Once per exchange.
- Projectiles join the triangle (「將飛行道具回歸相消的攻擊體系中」, 「OK」 on the lead's definitions): a hazard's class is the segment that fired
  it; a cancel removes it and refunds that segment even after the move ended; an owner no longer in a move gets only the refund (no
  "landed"); wave vs wave stays as it is (ichigo.lisp); DUEL_CORE's "a wave beats every class at range" is overturned (Ichigo's pointer 2
  changes); PRACTICE's GUARD ALL dummy must try to cancel waves too. The live hazards: Ichigo's waves and KESSA's clone replays (Hisagi's
  chains are melee windows, already judged).
- The AS1 flash-step steals (DUEL_CORE §2.2: per hit, 50 % conversion) **can take the last cell** (the user, 2026-11-13: 「AS1 能奪取最後一格，不受影響」; S1 had floored them at it) and are **halved** (「將現有 AS1 的奪取量減半」): Ichigo's RAKUGA 80 -> 40, KESSA's KUSARI-BIKI 30 -> 15 a hit, Hisagi's TSUMUJI 10 / 20 / 30 / 40 -> 5 / 10 / 15 / 20.

## 7. Consequences and dead code

- Dead once built: the Reiatsu gauge's internals in the core path (gains, regen, `kikon-refund`'s Reiatsu read), `*drive-switch*`.
  (The Reiatsu half went before SP, 2026-11-13, REFACTOR_2026-11 R6: `pay-gauges (e fs)`, `hit-gains` -> fs aw sfs, `kosei-gain`
  -> fs m, `kikon-refund (fs)`, `deal-damage (att def dmg &optional n)`; no `gauges-reiatsu`, no command cost check.)
  Already dead (found 2026-11-12, the user: those designs no longer exist): the DRIVE-full Bankai gate (`drive-full-p` through
  `kit-bankai-form`, nil on every live kit), pointer locks (`:locks`, `core-pointer-locked-p`), the arm meter pips (`:pips`,
  `core-pips-ok-p`, `arm-spend!`). For the refactor's cleanup.
- Watch at the playtest: ORANGE with free SP attacks for its whole drain is the strongest offensive state; a defender at the floor spends
  his only cell on a BLUE; J is free and earns SP, and SA (the answer to J) lives only in an NS gap.
- CPU: the core CPU, the fuzzy rules, the MCTS light model and the strategy tables know nothing of costs: rule statements to add, nothing
  retuned. G2 moves. No balance gates (the user's rule): balance by playtest.
- HUD: the three cells and the 爆 dial already show the gauge; costs, refunds, scaled damage and the steal need cues.

## 8. Implementation plan

Written 2026-11-12 by the Fable advisor (the user: 「規劃實作的同時也幫我重新安排之前為完成的程式優化與整合」), a plan, nothing built. The refactor's
half and the combined timeline: docs/engine/REFACTOR_2026-11.md §11. Line numbers are main 172e65a4.

### 8.1 Shape (judged against AGENTS.md "Design principles")

- **One new plain-CL file `duel/lisp/sp.lisp`** (after `core.lisp` in the MANIFEST; like `core.lisp` it loads on the host): every SP rule
  as a pure function of numbers, tested by a new `tests/duel-rules/sp.lisp`. The sim side stays in the named mutation places that exist:
  `core-sim.lisp` (starts, verdicts, on-hit), `combat.lisp` (`pay-gauges`, `gain-gauges`, `kosei!`, `burst-*`, `gauge-system`),
  `fighter.lisp` (`spend-fs`, the only place the gauge is spent), `hazards.lisp`.
- **State is component slots only, no new special.** The ECS stores are snapshotted by the engine, so the in-game MCTS, `snaptest` and
  `fulltest` cover new slots without a `snapshot-roots` edit; a batch that adds a slot still runs both. Any slot that changes what the
  sim does next goes into the `duel hash` line (gate.lisp:20) in the same batch.
- **No on / off flag.** The "old behaviour proves identical" step of each batch is done with the batch's own knobs at their neutral
  values (cost x 0, regen cap 300, `*fs-burst*` 200, steal floor 0, the old KOSEI table): G2 identical with them, then the shipped values
  and G2 regenerated (`tests/style-cvc-ref.txt`, header note + "Before:", every quote of the II / IK / KK lines). The knobs stay as
  ordinary `tuning.lisp` knobs (docstring: old -> new, date, the user's words).
- **Core kits only by construction, not by a test**: the plan assumes the retired kits and frozen modes are already out of main
  (REFACTOR §11 R2-R4 first). Reason: S1 changes shared rules (`fs-regen`, `burst-allowed-p`, `hit-gains`' callers) that the retired kits'
  ~500 host checks, `scripted.lisp`, `ai.lisp` and DANGAI's `rmod-x :fs-regen / :hoho-cost` also read; with them gone no rule needs a
  `core-kit-p` branch. If the main session chooses SP first instead, S1-S3 each need such a branch and it is removed again with D1.

### 8.2 Pure functions (sp.lisp unless a file is named)

| Function | Returns | Used by |
|---|---|---|
| `(sp-cost damage &optional (mult 1.0) override)` | the segment's cost: OVERRIDE, else damage x `*sp-cost-rate*` 0.4 x MULT, rounded to 5, clamped `*sp-cost-min*` 10 .. `*sp-cost-max*` 60 | `parse-move` time (kit.lisp): the cost is computed once per move into a `move` slot `sp-cost`, never per frame |
| `(sp-start-p cls first fs bursting)` | T when a segment of class :ns / :as may start: AS always; NS when FIRST (NSa) or `fs` > 0 or BURSTING | `core-sp-start!`, `core-move-sp!`, `core-latch-step` |
| `(sp-pay fs cost bursting)` | (values new-fs paid): 0 paid in a burst, else min(cost, fs) | `core-start!` |
| `(sp-scale paid cost)` | 0.5 + 0.5 x paid / cost; 1.0 when cost is 0 (or the segment was free in a burst) | `apply-hit`'s damage, a hazard's damage |
| `(sp-refund fs paid)` | fs + paid, capped `*fs-max*` | `core-nohit!`, the hazard cancel |
| `(sp-atk-gain cls cancel)` | `*sp-gain-j*` 10 / `*sp-gain-sa*` 15, `*sp-gain-cancel*` 30 when CANCEL; 0 for :ns / :as / Kikon | `apply-hit`, `core-nohit!` |
| `(sp-break-take victim-fs)` | (values take gain): take = `*sp-break-share*` 0.5 x max(0, victim-fs - `*fs-cell*`), gain = take x `*sp-break-gain*` 0.5 | `apply-hit` (S4) |
| `(sp-exchange-open-p xch-a xch-b)` | T when both fighters carry the same live exchange id | S4 |
| `(sp-switch-ok-p fs was-full switched routes)` | the pointer switch's gate (replaces `core-switch-open-p`'s body) | S6 |
| rules.lisp `(fs-regen fs idle &optional rate (cap *fs-regen-cap*))` | regen stops at CAP (`*fs-regen-cap*` 300 -> 100) | `gauge-system` |
| rules.lisp `(burst-allowed-p mode fs active)` | unchanged body; `*fs-burst*` 200 -> 100 | |
| rules.lisp `(steal-take want victim-fs &optional (floor *fs-cell*))` | take never brings the victim under FLOOR | `core-on-hit!` |

`*fs-cell*` 100 is new (today the literal lives in `*fs-hoho*` and lhud-deck's `+fs-burst+`); Kenpachi's multipliers are a `:core` plist
entry `:sp-cost-mult` on each of his four kits (0.76 / 0.68 / 0.71 / 0.51), a move's override is `:params :sp-cost`.

### 8.3 State slots

| Component | Slot | Meaning | Hash |
|---|---|---|---|
| fighter | `sp-paid` single-float, `sp-cost` single-float | what the segment he is in paid / owed (set by `core-start!`, cleared by `start-move` for any other move); the scale is derived, not stored | yes (paid) |
| fighter | `sp-back` boolean | this segment was already refunded (a cancel refunds once; a multi-hit tie gives two verdicts) | no (derived within the step) |
| fighter | `sp-gain-t` fixnum | the move start tick that last paid an ATK gain (one gain per J link / SA, see Q3) | no |
| fighter | `xch` fixnum, `xch-done` boolean | the exchange id (the cancel's tick, -1: none), and "the breakthrough was taken" | yes (xch) |
| hazard | `cls`, `sp-paid` single-float, `sp-scale` single-float, `sp-src` fixnum | the firing segment's class, what it paid (the refund's amount), its damage scale frozen at the fire frame, the owner's move start tick (so a refund after the move ended is still paid once) | no (hazards are not in the hash line today; snaptest's digest covers the store) |
| gauges | `aw-full` boolean | the awakening gauge has been full this match (latched in `awaken-fill!`; an awakened fighter counts) | yes |

### 8.4 Batches

Proof bar of every batch: host tests (the runner + `tests/duel-rules/sp.lisp`), `tools/pkgcheck.sh duel`, `./build.sh duel`, the smoke
(`tools/run.mjs ... --secs 8`), its scripted scene (`tests/scripts/duel.py` section -> `duel-sp-*.json`, both sides' inputs written, `duel sp`
log lines asserted), `tests/debug-ranges-check.py`, `snaptest` + `fulltest`, G2 by the neutral-knob method (8.1). No balance gates.
Debug range to claim in DUEL_GAMEPLAY before S1: **2820-2859 "SP scenes"** (next to PRACTICE's 2800-2815; confirm free with the checker).
Each scene sets both gauges, places the fighters and prints a `duel sp t .. p1 fs paid cost scale xch | p2 ..` line (one shared
`sp-line`, as `steal-fs-line`).

| # | Batch | Scope and touch points | Scenes (scripted, both sides) | Docs | Model |
|---|---|---|---|---|---|
| **S0** | sp.lisp, pure | The table of 8.2 with its knobs in tuning.lisp, `tests/duel-rules/sp.lisp` (cost table of §4 reproduced for all nine forms from the kits' data: the test fails if a move's damage and the doc's route totals disagree), the MANIFEST line, the runner's load list. No call site: G2 and the build are untouched. | none | §8 status | Sonnet |
| **S1** | Gauge rules | `fs-regen` cap (rules.lisp:743, `gauge-system` combat.lisp:1024); `*fs-burst*` 100 (`burst-allowed-p`; `burst-drain` / `burst-budget` / `burst-burn` re-read: BLUE burns one cell, WHITE / ORANGE to 0; `hoho-cost` in a burst); the steal floor (`steal-take`, `core-on-hit!` core-sim.lisp:382); `*kosei-kind*` :sp / :kikon -> 0; the reset keeps the gauge (check `reset-fighters` / combat.lisp:1001 and PRACTICE's refill flow.lisp:342, which is `*gauges-inf*` only and stays); lhud-deck's `+fs-burst+` 2/3 -> 1/3 read from the knob; CPU readers of `*fs-burst*` (rules.lisp:953 `*ai-burst-low*`, `cpu-ki-ichigo.lisp:510-517`, `cpu-ki-ken.lisp:613`) left as they read (they follow the knob; G2 moves) | burst at exactly 100 for each colour; regen stops at 100 from 40 and does not move at 180; TSUMUJI / RAKUGA / KUSARI-BIKI on a victim at 100, 130 and 300 (extend `duel-steal-cap.json`) | DUEL_CORE §2.2, "Bursts"; the manual | Sonnet |
| **S2** | Costs | kit.lisp `parse-move`: the `sp-cost` slot (damage sum of the segment's windows, a wave's `:params :dmg`, setup 10, `:sp-cost` override, the kit's `:sp-cost-mult`); `core-start!` (core-sim.lisp:41) becomes the one paying place: `sp-pay` through `spend-fs` (fighter.lisp:426, which resets `fs-idle`), sets `sp-paid` / `sp-cost`; refusal by `sp-start-p` in `core-sp-start!` (never: NSa), `core-move-sp!` / `core-latch-step` (a later NS segment at 0: the latch is refused with `(emit :refused e :sp)`, the press eaten), `core-as-start!` (never refused; an `:as-pick` move pays as the move it names; `:taken`: no cost); the Kikon hold and `core-wave-follow!`'s strike free (class not :ns / :as, or `:kikon-strike`); the refund in `core-nohit!`'s `landed!` for either side whose class is :ns / :as (`sp-back` once); the scale in `apply-hit` (combat.lisp:351, one multiply beside the charge / SUBLIMATION multipliers; damage only, no reaction field) | each kit: NS route at 300 (totals = §4), at 30 (first segment scaled, second pays the rest, third refused), at 0 (NSa starts at x0.5, NSb refused); a full AS3 at 0 (every segment, x0.5); NS vs NS tie and J vs NS cancel: both `paid` back; a scaled hit's reaction and stun equal the full hit's (asserted from the log) | DUEL_CORE (a new § "SP"), DUEL_KEN_CORE (multipliers), the manual, tutorial | **Opus** |
| **S3** | ATK gains | `apply-hit`: a J / SA hit pays `sp-atk-gain` through `pay-gauges` (so nothing in a burst); `core-nohit!` :cancel pays +30 to each side whose class is :na / :sa; the KOSEI flash-step of :quick / :flash kinds leaves (`kosei-gain`'s fs for core kits is the §5 table; its other outputs unchanged); `*fs-taken*` kept | J1-J2-J3 on a standing dummy: +10 each; SA: +15; J vs J tie: both +30; J vs NS cancel: J side +30 and NS side refunded; no gain in ORANGE | DUEL_CORE, DUEL_STRINGS §5 note, the manual | Sonnet |
| **S4** | Breakthrough | `core-nohit!` :cancel and `core-kikon-cancel!` stamp both fighters' `xch` with the tick; a step in `gauge-system` (or `core-hold-step`'s neighbour) clears it when both are neutral (Q11); `apply-hit` on a real hit with `sp-exchange-open-p` and not `xch-done`: `sp-break-take`, victim -take, attacker +gain, `xch-done` on both, a `BREAK` log line and a `:sp-break` event for the HUD | cancel then AS (AS side takes); cancel then SA beats J; cancel then a second cancel then a hit (one take); victim at 100: nothing; both walk to neutral, then a hit: nothing; with an AS1 steal on the same hit (order, Q10) | DUEL_CORE §2.1 | **Opus** |
| **S5** | Projectiles | `spawn-hazard` (hazards.lisp:21) records `cls` / `sp-paid` / `sp-scale` / `sp-src` from the firing fighter; the two places a blade removes a wave today without any verdict (combat.lisp:652-662 in `collect-melee`, and Ichigo's JUJISHO ichigo.lisp:504) and the wave's own hit (`core-verdicts` treats a hazard as a clean hit, core-sim.lisp:189) go through `core-verdict` with the hazard's class: :cancel removes it, refunds the owner (`sp-src` still current: also "landed"; else the refund only), stamps the exchange with the owner, pays an ATK side +30; a win for the wave lets it through; KESSA's clone replays (ichigo.lisp:771, `:sp-mv nil` today) carry the replayed segment's class and the summon's scale; wave vs wave unchanged; DUEL_CORE's "a wave beats every class at range" rewritten; PRACTICE's `dummy-cancel-press` (control.lisp:235) also times a wave's arrival | Getsuga vs J / NS / AS / SA at the hit frame, each verdict; a wave cancelled after Ichigo is idle (refund, no landed); a clone replay cancelled; GUARD ALL dummy vs Getsuga (2800-range scene) | DUEL_CORE §2, §9; DUEL_ICHIGO pointer 2; the manual | **Opus** |
| **S6** | Switch + awakening | `aw-full` latched in `awaken-fill!`; `core-switch-open-p` -> `sp-switch-ok-p` (fs > 0, `aw-full`); `core-latch-step`'s `:sw` branch pays through `core-start!` instead of the DRIVE `decf`s (core-sim.lisp:167-176), log "(SP)"; `*drive-switch*` and its docs removed; `*sub-gain*` and the DRIVE fill halved (tuning.lisp:278-295: the two gain knobs only; maxima, bonuses, `*sub-keep*` untouched) | switch before / after the first full gauge; at 0: refused; at 20: starts scaled; DRIVE unchanged by a switch; gauge fill per hit half of the 2026-11-11 value (extend the sublimation host test) | DUEL_SUBLIMATION §17, the manual | Sonnet |
| **S7** | CPU statements | Statements, no weights retuned: `core-ai.lisp` does not press a later NS segment the sim would refuse (reads `sp-start-p`; else it stalls on an eaten press); the SP press's fuzzy input "fs cells" available (fuzzy.lisp term, unused by the shipped rules unless a rule needs it to stop a refused press); `cai-switch-press` reads the new gate; the full-sim rollouts (`cpu-mcts.lisp`) see costs for free; **the light model (`mcts-lite.lisp`) ignores SP** (its `+f-hoho+` is a 0 / 1 flag, no gauge): stated in DUEL_AI_MCTS, with a `mc-fidelity.py` run reported, not gated; strategy tables untouched | a CPU at fs 0 in an NS route (scripted opponent, CPU side fixed by seed and `39000` rule): no refused-press loop in the log; `fulltest` | DUEL_AI_MCTS, skill `duel-character-cpu` | Opus |
| **S8** | HUD cues | `webhud.lisp` publishes cost-of-next (the pointer's NSa cost), `sp-paid` / scale and the `:sp-break` / refund events into the model (`lhud-model`); `lhud-plate.lisp`: a spend tick and a refund flash on the cells, a "x0.5-x0.9" dim mark on a scaled segment's callout, the steal's cell fly-over; `lhud-deck.lisp`: the dial arms at one cell, the SP button shows "short" / "empty". Preallocated, 0 B / frame (measured with the HUD's existing allocation probe); `lhud-charset` test if a new glyph is used | `tests/lhud-compare.py` sheets of four states (full, short, empty, break) for the user; no byte gate | DUEL_LISP_HUD (a new §), the manual | Sonnet |
| **S9** | PRACTICE + docs | a GAUGES row (FS: FULL / ONE CELL / EMPTY / KEEP, both sides; `control.lisp` settings row + `flow.lisp` `practice-step`, beside `*gauges-inf*`); the dummy pays like a player (Q19); manual.html, TUTORIAL.zh-TW, DUEL_DESIGN's move tables gain a cost column (generated from `sp-cost`, checked by S0's test), skills `duel-move-modules` / `sim-balance-gates` one paragraph each; the dead-code list of §7 handed to REFACTOR §11 R1 / R6 | the row's four settings (`duel-practice-*.json`) | as listed | Sonnet (docs: Haiku for the tables) |

**Status:** S0 done on branch worktree-agent-abefea47b36f0d068 (sp.lisp, nine knobs in tuning.lisp, tests/duel-rules/sp.lisp; no call site). The test reproduces §4 from the kits' data: Ichigo's and Hisagi's cells agree; ten Kenpachi cells differ (reported to the main session, pinned in the test).

**S1 done (2026-11-13, branch worktree-agent-a3a3efe73cef5c998, not merged):** knobs and rules, old -> new: `*fs-burst*` 200 -> 100 (the user: 「三色爆氣皆改成一格可放」;
`burst-allowed-p` reads it; `burst-drain` / `burst-budget` / `burst-burn` / `hoho-cost` needed no change: BLUE burns one cell, WHITE / ORANGE drain
to 0, so a burst from 100 lasts 1.85 s); `fs-regen` stops at `*fs-cell*` (40 -> 100; a gauge at or above 100, 180 or 300, is never lowered);
`steal-take` = `min(want, victim - *fs-cell*)`; `*kosei-kind*` :sp 27 -> 0 and :kikon 20 -> 0; lhud-deck's `+fs-burst+` constant (2/3) is gone, the dial
arms at `*fs-burst* / *fs-max*` (1/3). Q18 applied: `core-on-hit!` pays the victim through `spend-fs` (only when something is taken) and the
attacker through `pay-gauges`; the Kikon / Soul Break bar is `(pay-gauges att *kikon-fs-refund*)` (`kikon-refund` removed). The round reset already
kept the gauge (no reset path writes `gauges-fs`; PRACTICE's `*gauges-inf*` refill unchanged). CPU readers (`ai-hoho-spare-p`, `cpu-ki-*`) follow the
knob untouched. Debug range 2820-2859 claimed; 2820-2822 set P2's flash-step to 100 / 130 / 300. Tests: host runner 2939 -> 2949 checks ALL PASS
(burst at exactly 100 for each colour, regen 40 -> 100 and 180 unchanged, steal at 100 / 130 / 300, pay-gauges in a burst, KOSEI kinds), control 116,
input 33, touch 100, cine 18, hud-engine 121, pkgcheck only `DUEL::APP`, debug ranges 0 errors. `duel-steal-cap.json` (110 s) runs the three steals
at a victim of 100 / 130 / 300 (the victim is first fed by the J1's damage-taken gain, so the first hits at 100 take only that excess and leave P2 at
exactly 100): victim 100: TSUMUJI 5.1 / 1.9 / 2.1 / 2.3, RAKUGA 5.9, KUSARI-BIKI 3.2 / 1.1 / 1.2 / 1.3, P2 ends 100.0; victim 130: TSUMUJI 10.0 / 20.0 /
9.2 / 2.3, RAKUGA 35.9, KUSARI-BIKI 30.0 / 4.3 / 1.2 / 1.3 (the last cell kept); victim 300: TSUMUJI 10 / 20 / 30 / 40, RAKUGA 80, KUSARI-BIKI 30 x 4
(unchanged). G2 moved as expected (the CPUs read the gauge and the burst price): II 39 lines (P1 3-1, 389.6 s) -> 28 (P1 6-0, 273.3 s), IK 36 (P1 2-0,
354.0 s) -> 25 (P1 3-0, 247.3 s), KK 28 (P2 0-5, 275.4 s) -> 38 (P1 1-0, 380.6 s); `tests/style-cvc-ref.txt` regenerated, native `--cvc` and the browser
`style-gates.py cvc` both PASS against it. No balance gates run. wasm 10.25 MB, smoke (desktop and `--mobile 390x844`) exit 0.

**S2 done (2026-11-13, merged to main; DEVLOG §743; reviewed by the main session, which kept the defaults below).** Three commits.
1. **The seam** (REFACTOR_2026-11 §11.5.4 / §11.5.7 item 4): `apply-hit`'s damage factor is the pure `(hit-px charge sub-frac dmg-mult
   &optional (sp-scale 1.0))` in rules.lisp, host-checked bit for bit against the old inline product; G2 identical natively.
2. **The data**: costs live in a per-kit table by move name (`kit-sp`, filled by `build-sp-costs` at registration; `kit-sp-cost kit mv`),
   not in a MOVE slot as §8.2 planned: a kit's `:sp-cost-mult` is unknown when a move is parsed, the rule rounds once after it, and
   `kit-cadence` copies a form's moves. `mv-sp-damage` (kit.lisp) is the segment's damage (its windows' sum, else a wave's `:params :dmg`,
   else 0). Kenpachi's `:sp-cost-mult` in his four `:core` plists (0.76 / 0.68 / 0.71 / 0.51). The host test pins every pointer of every
   form from the kits' own tables (§4's cells plus the five extra AS above), each kit's multiplier, and a cost on every NS / AS move but a
   wave's Kikon strike (free), none on anything else.
3. **The sim** (slots of §8.3: FIGHTER `sp-paid`, `sp-cost` single-float and `sp-back`; `sp-gain-t`, `xch` and GAUGES `aw-full` wait for
   S3 / S4 / S6): `core-start! (e mv &optional (button :quick))` is the one paying place (`sp-start-p`, `sp-pay`, `spend-fs`, the slots,
   a `SP <seg> fs F cost C paid P xS` log line; refused: `(emit :refused e :sp)`, `SP <seg> refused`, NIL). Starts that bypassed it now go
   through it: `hoho-resume!`'s NS segment (a refusal there eats the press too) and combat.lisp's `:parried` catch (Kenpachi's tame ->
   thrust). `start-move` clears the three slots for any move. `refund-fs` (fighter.lisp, beside `spend-fs`) is the refund writer;
   `core-nohit!`'s `:cancel` refunds each NS / AS side once. `apply-hit` passes `(sp-scale paid cost)` to `hit-px` for the attacker's own
   hit (a hazard: 1.0 until S5), and logs `dealt D: <reaction> stun N` per hit. The hash line: `h<heat>` out, `s<sp-paid>` in; BRAIN `heat`,
   its write in `deal-damage` and the debug 2104 overlay's H column out; `ai-event-rolls`' leftover third `sim-rnd01` out (the CPU stream
   moved once, with the format).
- **Defaults taken** (beyond §8.6): paying 0 at 0 still goes through `spend-fs` (the regen waits again; with only paid > 0 the regen's trickle
  gave 2.0 within 26 frames and opened every later segment at 0); in a burst `spend-fs` is not called. The tame's catch pays and is refused at 0
  like a pressed segment (§3: every NS segment, charged when it starts). Q14's switch keeps its DRIVE path until S6 (it would pay twice).
  Q5-Q8, Q16, Q17 as the defaults: an absorb neither refunds nor gains; a multi-hit segment refunds once; the price is fixed at the start (a
  burst's free segment records cost 0: full damage); hazards wait for S5; the CPU and the dummy pay like a player; "first" = in the kit's
  `:core :ns` list, wherever it starts. Feedback still plays `:refused` (a dud tick); the HUD cue is S8's (done, below).
- **Readers keyed on damage** (§8.7 risk 2): the gains follow the scaled, dealt damage (`gain-gauges`, the SUBLIMATION / DRIVE fill, the
  victim's `*fs-taken*`, `combo-dmg`); prices (Kenpachi's Bankai Reishi, `*ken-bk-cost*`) and the hitstop (`:hs-dmg`, from move data) do not.
  A blocked hit's chip uses the base damage (unchanged); an armoured / absorbed hit uses the scaled one.
- **Tests**: host 2939 -> 2960 (hit-px 3; the cost table 16 more: the extra pointers, the multipliers, the row widths, the coverage and SA checks; refund-fs 2); control 116,
  input 33, touch 100, cine 18, hud-engine 121; pkgcheck only `DUEL::APP`; debug ranges 0 errors; snaptest IK straight = pollute (stats and
  timings only); fulltest IK 144 / FT_VS 57 / KK 61 checks, 0 differ. `tests/sp-costs-check.py` (native trials, 65 checks, all pass): every NS
  route of the nine forms at 300 pays its §4 total in full; at 30 the first segment pays (scaled when it costs more), the rest pay what is left
  (the hits' KOSEI flash-step, until S3, refills 2.4-2.9 between segments, so most routes go on at x0.53-0.69 instead of being refused;
  Hisagi's NS1 and ranged NS2 show "full, the rest, refused"); at 0 (whiffed, so no KOSEI) NSa x0.50 and NSb refused in all 22 routes; AS3 from
  0: AS3a 12.3 (the J string's KOSEI) x0.81, AS3b / c at 0 x0.50; the six AS hits at x0.5-0.81 vs x1: damage 20/25, 5/10 x4, 27/55, every
  reaction and stun equal; NS1a vs NS1a tie: one CANCEL, P1 and P2 each refunded 25 once; J1 vs NS1a: two CANCEL verdicts, P2 refunded 25 once;
  the tame's catch pays NS3b's 20. The cost-0 diagnostic (§8.1's neutral knobs: rate 0, minimum 0, the draw kept): II and KK identical to the
  S1 reference, IK left it at its first refused segment (t 3469), so nothing but the refusal moved.
- **G2** (native = browser, reference regenerated with a header note): II 28 lines (P1 6-0, 273.3 s) -> 38 (P1 5-5 on time, 380.3 s), IK 25
  (P1 3-0, 247.3 s) -> 41 (P1 4-4 on time, 402.9 s), KK 38 (P1 1-0, 380.6 s) -> 14 (P2 0-8, 139.2 s). **Watch**: II and IK now go to the timer:
  the CPUs know nothing of costs (S7) and run their gauges low (SP starts at full price 119 / 162 / 87 of 348 / 344 / 119, mean scale 0.76 /
  0.81 / 0.91; refused presses 28 / 19 / 1, so no stall loop). No balance gate run; nothing retuned.
- The browser G2 ran on the build before a comment / docstring reflow (code identical); rebuilt after: index.wasm 10,252,128 B, smoke desktop
  and `--mobile 390x844` exit 0. `sp-paid` stays on the fighter after his route ends (only `start-move` clears it), so the hash's `s` shows
  the last segment's payment while idle or reeling; damage and refunds read it only inside that segment (`own`, `cls`). For S3: once KOSEI's
  flash-step leaves, tighten `sp-costs-check.py`'s at-30 and AS3-from-0 asserts to exact refusals / x0.50.

**S3 done (2026-11-13, merged; DEVLOG §745).**
- **The gains** (DUEL_CORE §11): `apply-hit` calls `sp-atk-hit!` (combat.lisp) for every damaging hit window of the attacker's own move (`own`, not a hazard,
  dealt > 0) whose class is `:na` / `:sa`: `sp-atk-gain` x the kit's `:sp-gain-mult` hook, through `pay-gauges` (nothing in a burst, x SUBLIMATION). Per hit window
  (Q3 as the user changed it), so a multi-hit SA pays per hit; a :dmg-at move (Kenpachi's delayed cuts) pays at the hit, not when the damage lands. A log line
  `SP hit gain G (fs F)` shows what the gauge really gained. `core-nohit!`'s `:cancel` pays `sp-atk-gain :cancel` (+30) to each side whose class is `:na` / `:sa`,
  once per move (`fighter-sp-gain-t` = the move's `cls-t`; not in the hash, a fighter is made fresh each match), log `SP cancel gain`; the move that cancels
  earns no hit gain from that verdict. `pay-gauges`' pure core is `fs-gain` (rules.lisp, Q18).
- **KOSEI is gone, not just its flash-step**: after the A1 fix (SP segments) and S1 (:sp / :kikon kinds) the remaining :quick / :flash / :sig kinds left too, and
  KOSEI paid nothing else, so `kosei!`, `kosei-mult` / `-base` / `-gain`, the four `*kosei-...*` knobs, debug 27000+k and their tests are removed (not zeros left in a
  table). Q15's "KOSEI's guard-gauge multiplier no longer applies to flash-step" is then simply true. `*fs-taken*` and its combo bonus stay. The manual's 攻勢 KŌSEI §
  (manual.html `#kosei`) still describes the old rule: the lead's to rewrite.
- **Hisagi** (A1 playtest (3), 「沿用 ×1.3」): a kit hook `:sp-gain-mult` (both Bankai modes' hook lists): `hs-dmg-base` marks the hit's factor on `hss-sp-x`
  (tip x1.3 when the hit's tip read says so, x1.3 more for a move of `*hs-r-spread-moves*`: J1, J2, J3, J4, J5, K2s, K3), `hs-sp-gain-mult` returns it; knobs
  `*hs-r-tip-sp-mult*` / `*hs-r-spread-sp-mult*` 1.3 in hisagi.lisp. Not a Hisagi branch in combat. Default taken: the spread list is the J1-opened chain's moves by name (the
  doc's "J1 and its links J2 / K2s / J3 / K3" predates the J1 > J2 > J3 > J4 > J5 string, so `na3` / `na4` are in); the gathered links and the Shikai get x1.
  Measured: J1 at the tip +16.9, off the tip in the spread band +13.0, Shikai J1 +10.
- **Tests**: host 2960 -> 2957 (KOSEI's checks out, `fs-gain` and the hook's marks in), control 116, input 33, touch 100, cine 18,
  hud-engine 121; pkgcheck only `DUEL::APP`; debug ranges 0 errors. `tests/sp-costs-check.py` (trial.lisp gained `:burst` and `:p2-fs`) 94 checks pass (86 before): J1-J3 +10 each
  (110 / 120 / 130), NS1a then its SA +15 only, J vs J tie +30 each (no refund), J vs NS1a +30 and the NS side's 25 back, J1-J3 in ORANGE / WHITE / BLUE +0 each,
  Hisagi 16.9 / 13.0 / 10. The at-30 asserts are exact: each start is the last one's fs - paid and a gauge at 0 refuses the next (no KOSEI income); AS3 from 0 is no longer "every
  segment at x0.5": its J string's five +10 (plus the first second's regen trickle) put AS3a at 54.2, so AS3a / b pay in full (20, 30) and AS3c the 4.2 left (x0.55: 30 of 55 damage, reaction and stun equal).
- **G2**: native `--cvc` regenerated, browser `style-gates.py cvc` PASS (= native, 37 / 41 / 36 lines): II 37 lines (P1 7-6, 371.5 s), IK 41 (P2 1-3, 403.5 s), KK 36 (P1 3-0, 361.0 s); before II 37 (P2 7-7, 367.9 s), IK 37 (P2 0-5, 371.5 s),
  KK 43 (P1 3-1, 426.0 s). No balance gates. Not done here: `core-kikon-cancel!`'s victim J / SA +30 (Q12) waits for S4 with the exchange.

**S6 done (2026-11-13, merged; DEVLOG §747; DUEL_SUBLIMATION §17.8).**
- **Built** (all of the §8.4 row): `aw-full` is a GAUGES slot latched in `awaken-fill!` (an awakened fighter counts); `aw-full-p g` (combat.lisp) is the one reader:
  the latch, or awakened, or `awaken >= *awaken-max*` (PRACTICE's rows and the debug scenes write the gauge without `awaken-fill!`; the three scene setters and the
  practice row below full clear the latch). `core-switch-open-p e f` (core-sim.lisp, kept as the sim-side feeder: the CPU's `cai-dswitch` / `cpu-hisagi-range`
  call it) is now `sp-switch-ok-p` over `(gauges-fs)`, `(aw-full-p)`, `(plusp fighter-tmp)` and the NS route count; the DRIVE / SUBLIMATION price is gone and
  `*drive-switch*` with it. `core-latch-step`'s `:sw` branch starts the target route's NS1 through `core-start!` (the one paying place; Q14: a gauge between 0 and
  the cost starts it scaled, at 0 the gate refuses before) and logs `NS pointer a -> b (SP; DRIVE d SUB s unchanged)`. **Item 6**: `core-switch-ready-p` (the brain's
  act `:switch` let a CPU through) is deleted; `core-switch-target` and the thumb's flick (onehand.lisp) read `core-switch-open-p`; the sim reads only the vpad and the
  gauges, and whether a CPU presses is core-ai's (`cai-switch-press`'s docstring says so). `*sub-gain*` 2.0 -> 1.0 (the one knob multiplies both the SUBLIMATION and the
  DRIVE fill, so "the two gain knobs" is one; maxima, bonuses, `*sub-keep*`, `*sub-attack-mult*` untouched): about 1905 damage dealt fills one again.
- **Hash**: cheap, so in: the `w` column prints `^` after the awakening gauge has been full (`w100^`; `aw-full-p`, not the raw slot, so a scene-set gauge shows it too).
- **Defaults taken** (beyond §8.6): the gate is also evaluated only when the press latches (not again when the segment starts: between them nothing spends SP);
  at SP 0 the plain next-segment press that the failed switch falls back to is itself refused (a later NS segment at 0), the same as without a stick; the gain
  halving is the single knob `*sub-gain*` (§20's doubling reverted), not a second DRIVE-only knob (none exists: `awaken-overflow` multiplies both).
- **Tests**: host 2960 -> 2968 (sublimation.lisp: `*drive-switch*` gone, `*sub-gain*` 1.0, the overflow lines 36 / 12, the fill per hit equal to XS, the latch and the
  derived reader; sp.lisp had the gate); control 116, input 33, touch 100, cine 18, hud-engine 121; pkgcheck only `DUEL::APP`; debug ranges 0 errors. Scripts
  (`duel-drive-switch.json`, `duel-drive-switch-phone.json`, `duel-switch-routes.json`; debug 86107 now "gauge never full", new 86111 SP 15 / 86112 SP 0):
  D+SP in KESSA's NS1 gap, fs 300, `NS pointer 1 -> 2 (SP; DRIVE 61.7 SUB 0.0 unchanged)` (DRIVE rose from 60 by hits only, never paid), A+SP `1 -> 3`; a second
  switch inside the route: plain `IC-K-N2B`; SUBLIMATION 60 Shikai (gauge full) `1 -> 2 (DRIVE 0.0 SUB 62.2 unchanged)`; never full (86107): plain next
  segment, no switch, also on the phone (the flick stays a STEP); SP 15 (86111): `SP IC-K-N3A fs 16.5 paid 10.0`, then the switch `SP IC-K-N1A fs 6.5 cost 25.0
  paid 6.5 x0.63` (`NS pointer 3 -> 1 (SP; ...)`); SP 0 (86112): `SP IC-K-N3B refused (fs 0.0)`, no switch. Phone: both flicks switch (`1 -> 2`, `1 -> 3`) after a
  gesture STEP. The routes script was stale before this batch (its distance log, debug 83099, became a Bankai trace scene and turned the Shikai into the Bankai on
  main too: nothing switched): it logs with 83900 now and all nine switches of the routes run (`1 -> 3` x7 with SUB 63-70 unchanged, the Bankai's `1 -> 2` x2 with DRIVE 61.0).
- **G2**: with `*sub-gain*` held at 2.0 the three matches are identical to the S2 reference but for the `^` in the hash (the switch rule and item 6 move nothing: the
  shipped CPU never switches); with 1.0 (the awakened fighters' bonus is half) II 37 -> 38 lines (P2 7-7, 367.9 s -> P1 6-5, 372.5 s), IK 37 -> 40 (P2 0-5, 371.5 s ->
  P1 4-2, 401.0 s), KK 43 -> 40 (P1 3-1, 426.0 s -> P1 4-0, 401.9 s); native = browser (below), reference regenerated; the lead regenerates on the merged head. No balance gate run.

**S4 done (2026-11-13, branch worktree-agent-a589f59909b73bb9e, not merged).**
- **Built** (the §8.4 row; DUEL_CORE §2.1 "The exchange and its breakthrough"): FIGHTER `xch` (fixnum, -1) and `xch-done`. `core-xch-open!` (core-sim.lisp)
  stamps both fighters from `core-nohit!`'s `:cancel` and from `core-kikon-cancel!`, which also pays the victim the cancel's +30 (`sp-atk-gain :na t`
  through `pay-gauges`: he presses J in his reel, so no move class to read; Q12, S3's leftover). `core-break!` runs in `apply-hit` on a `:hit` / `:counter`
  after the `:hit` / `:struck` hooks, so both an own AS's steal (`core-on-hit!`) and a KESSA clone replay's (`clone-replay-hit!`, from Ichigo's `:hit` hook)
  come first (Q10); `sp-break-take` through `spend-fs` (only when take > 0), the gain through `pay-gauges`, `xch-done` on both, a `BREAK` log line, `:sp-break`
  (only when take > 0). `core-xch-step` (the last of `sim-systems`, run on a cinematic's first frame too) ends it when both are `sp-neutral-p` (sp.lisp, new, host-tested) or a cinematic has begun (Q11); `reset-round`
  clears it; `trial.lisp` clears it per trial. Hash: ` x<tick>` after `s` while open, `*` once taken (DUEL_GAMEPLAY). HUD: o+5, DUEL_LISP_HUD §17. Debug 2827 / 2828.
- **Defaults taken** (beyond §8.6): **neutral** (Q11's "no move, no reaction") = not `:move` / `:stun` / `:guard-hit` / `:air` / `:down` / `:wakeup`, **and not
  standing while still sliding** (`motion-kb-left` > 0 in `:idle`): `core-bounce!` sends both to `:idle` in the cancel's own step, so without this every tie's and
  every Kikon cancel's exchange closed at once (Q12 would be empty); the 12-frame push (plus the hitstop and the clash slow motion: about 44 ticks in the
  scenes) is "a reaction the exchange caused". A Step, a run, a Hoho and a guard are neutral (Q11 literally). **The first real hit is the breakthrough even when it
  takes nothing** (a victim at or under 100), and later hits of that exchange take nothing (once per exchange). The victim's gauge is read **after** the hit's own
  damage-taken gain (`*fs-taken*`, applied in `deal-damage` before), as S1's steal does, so a victim at exactly 100 loses half of that excess (2.4 of 4.8 in the
  scene). Every real hit counts, a hazard's or a clone's too (§6 「都算」; S5 adds the hazards' own cancels). A cancel inside an open exchange or after its
  breakthrough restamps (a fresh exchange).
- **Tests**: host 2965 -> 2969 (`sp-neutral-p`), control 116, input 33, touch 100, cine 18, hud-engine 121; pkgcheck only `DUEL::APP`; debug ranges 0 errors.
  `tests/sp-costs-check.py` 94 -> 102 checks, all pass (P1 at 100 so the cap hides nothing; `BREAK fs T from P2 (fs V), gains G (fs F)`):
  J1 vs NS1a then Kenpachi's AS1: `P1 BREAK fs 100.0 from P2 (fs 200.0), gains 50.0 (fs 155.0)`; Ichigo's AS1 RAKUGA (Q10): `P1 STEAL fs 80.0 from P2, gains 40.0`
  then `P1 BREAK fs 60.0 from P2 (fs 160.0), gains 30.0 (fs 180.0)` (on 300 - 80); NS1a cancelled by P2's J1, its SA beats J2: `P1 SP hit gain 15.0` then
  `P1 BREAK fs 100.0 from P2 (fs 200.0), gains 50.0 (fs 265.0)`; two cancels (ticks 173, 215) then AS1: one BREAK (60); victim at 100: `BREAK fs 2.4 ... (fs 102.4)`;
  at 80: `BREAK fs 0.0 from P2 (fs 84.9), gains 0.0`; cancel, `exchange over` (both neutral), then a J1 hit: no BREAK; the Kikon follow-up cancelled (Q12): `P2
  cancels the Kikon follow-up`, `P2 SP cancel gain 30.0 (fs 135.0)`, no `exchange over` through the bounce, Hisagi's Bankai J1 from 5 m: `P2 BREAK fs 88.8 from P1
  (fs 188.8), gains 44.5 (fs 196.4)` (x his SUBLIMATION / DRIVE bonus). snaptest IK / KK straight = pollute (46 / 39 lines, 0 differ); fulltest IK 152, FT_VS 83, KK 122
  checks, 0 differ.
- **G2**: with `*sp-break-share*` 0 and the Kikon cancel's +30 at 0, the native matches were identical to the S6 reference with the x column stripped (42 hash lines
  carried an open exchange); shipped: II 38 -> 40 lines (P1 7-6, 373.1 s -> P1 5-3, 398.3 s), IK 41 -> 39 (P2 1-3, 403.6 s -> P1 3-2, 384.0 s), KK 44 -> 32 (P1 2-0,
  439.7 s -> P2 0-3, 317.9 s); native `--cvc` and the browser `style-gates.py cvc` PASS against the regenerated reference. No balance gates. wasm 10,271,254 B;
  smoke desktop and `--mobile 390x844` exit 0.

**S5 done (2026-11-13, branch, not merged).**
- **Built** (the §8.4 row; DUEL_CORE §2 "Projectiles are in the triangle"): HAZARD slots `cls`, `sp-paid`, `sp-scale`, `sp-src`; `spawn-hazard` fills them
  for a hit hazard (one with a HITWIN) from its owner's classed move now (`sp-paid` 0 once that segment was refunded, `fighter-sp-back`, so a J
  that cancels NS2c in its startup and the wave it still fires at f20 cannot refund twice). `core-verdicts` judges a hazard's hit with its
  class and start tick (a classless hazard stays a clean hit). `core-nohit!` hands a hazard's verdict to `core-hazard-nohit!` (core-sim.lisp, new):
  **cancel**: the owner refunded `sp-paid` once (`refund-fs`; still in the segment, `fighter-cls-t` = `sp-src`, through the lifted
  `core-cancel-landed!`, so also "landed" and the `sp-back` guard; else `SP refund P (fs F), out of the move`), the other side's move landed
  (his refund or +30), the exchange opened with the owner, `core-clash!`, the cancel's hitstop / slow motion / `:clash` at the wave, no
  bounce, log `P1 wave ns x P2: CANCEL`; **absorb** (his class beats it): spent, nothing else, log `P2 beats P1's wave ns`. hit-apply's
  `hazard-connected` spends it after either verdict. `cut-hazards` (NOZARASHI's `:projectile-cut`: the "blade removes a wave" site, combat.lisp:652
  in the plan) asks `core-verdict` the same way (the wave's class against the blade's window): `:hit` the wave flies on; a cancel or absorb goes
  through `core-hazard-nohit!` and the wave is destroyed; a classless side keeps today's cut (Q9); log `P2 blade x P1's wave ns: cancel / absorb / passes`. `apply-hit`'s damage reads the hazard's frozen
  `sp-scale` (Q8). KESSA: `icc-sscale` (the summon segment's scale, set in `ichigo-ns-clone`) and `icc-rt` (the replayed move's start tick, kept by
  `clone-replay-next`); `clone-replay-sp` passes class / 0 paid / scale / tick to the replay's `ichigo-strike` and `clone-wave`. PRACTICE:
  `wave-arrival` (control.lisp, pure: frames until a moving wave box first touches a standing cylinder) and `dummy-wave-threat` (flow.lisp);
  `dummy-cancel-input` answers the sooner of the melee hit and a classed wave (gap 0, the wave's class).
- **Defaults taken** (beyond §8.6): **JUJISHO's cut of other waves (`ichigo-cut`) is wave vs wave** and stays (§6), so the only blade site is
  `cut-hazards`; the plan's `collect-melee` cut had already moved there. **NS3 / AS3's own clone cuts and ZANZO's echoes stay classless**
  (`ichigo-strike` passes `:cls nil`: they are not projectiles, §6 names only the waves and the replays). **A replay pays nothing** (`sp-paid` 0:
  the summon paid for the clone, so a cancelled replay refunds nothing), and its `sp-src` is the replayed move's tick, so a replay cancelled
  while Ichigo is still in that J counts as landed for him (the literal rule). **`core-clash!` fires** on a hazard cancel (a cancel is a
  cancel: each kit's :clash hook). **No bounce** (a wave is no body). **A beaten wave is cut without a hitstop** (as the old cut). The
  :simul of a wave's same-class tie is the defender's own hit on the owner that step (rarely true at range: an NS wave hits an NS).
  Ponytail: one refund per hazard (one segment fires one wave today); a segment refunded after its hazard spawned inside its own window, then
  the hazard cancelled after the segment ended, would refund twice (no wave segment fires inside its window: NS2c / AS2b fire at f = S).
- **Tests**: host 2969 (unchanged), control 116 -> 124 (`wave-arrival` against `obox-cyl-hit-p` stepped frame by frame, six offsets; beside,
  behind, touching, out of life; the dummy's J against an NS / AS wave at the lead); input 33, touch 100, cine 18, hud-engine 121; pkgcheck only
  `DUEL::APP`; debug ranges 0 errors. `tests/sp-costs-check.py` 102 -> 112 checks, all pass (trial.lisp gained `:p2-start` (P2 starts a move by
  name through `core-start!`, a written debug drive), `:p1-cmd` and a per-trial `clear-hazards`): JUJISHO (NS2c, paid 60) at 6 m on a standing
  Kenpachi `dealt 82`; vs J1 started 3 frames before it arrives: `P1 SP refund 60.0 (fs 280.0)`, `P2 SP cancel gain 30.0 (fs 130.0)`, `P1 wave
  ns x P2: CANCEL`, `exchange over`; vs SA the same; vs NS1a `P1 WAVE -> P2 HIT 150`, `dealt 82`; vs AS1 `P2 beats P1's wave ns` (no refund, no
  exchange); from 10 m after NS2c ended `P1 SP refund 60.0 (fs 280.0), out of the move`; fired at fs 30 `SP IC-N2C fs 30.0 cost 60.0 paid 30.0
  x0.75` then `dealt 61`; NOZARASHI's J1 started 15 frames early meets it in front of him through `cut-hazards` (`P2 blade x P1's wave ns: cancel`, then CANCEL, refunded) and his NS1a blade lets it through (`... : passes` x3, NS vs NS, then `dealt 82`); KESSA with two NS3 clones (74904): `P1 IC-K-J1 x P2: CANCEL` then the replay
  `P1 ic-hit na x P2: CANCEL`, one refund (P2's NS1a, 20). snaptest IK / KK straight = pollute (stats and timings only); fulltest IK 152, FT_VS
  83, KK 122 checks, 0 differ.
- **G2**: II and KK identical (KK has no classed hazard; in II no wave met a classed window); IK moved only in its Reishi columns: its JUJISHO
  at t 4128 paid 31.9 of 60 (x0.77) and dealt 63 instead of 82 at t 4152; the same lines and result: II 40 (P1 5-3, 398.3 s), IK 39 (P1 3-2,
  384.0 s), KK 32 (P2 0-3, 317.9 s); in none of the three did a wave meet a classed window (no hazard CANCEL / beats line). Native `--cvc`
  PASS on the regenerated reference; the browser `style-gates.py cvc` PASS against it (= native). wasm 10,282,312 B; smoke desktop and `--mobile 390x844` exit 0. No balance gates.
- **Evidence scope**: no hazard cancel or beat happened in the three G2 matches, so snaptest / fulltest prove the new slots ride the
  snapshot, not the cancel path's writes; the cancel path is proven by the native trials above and the practice-cancel browser run. AS2b's
  `:as` wave and a scaled summon's replay follow from the table and the same code, untested by a scene.
- **PRACTICE** (`duel-practice-cancel.json`, browser): 40 scenes, exit 0; scene h (2.2 m): the dummy's J1 starts on the tick the wave reaches it, `P1 SP refund 60.0 (fs 280.0)`, `P1 wave ns x P2: CANCEL` (then its J1 lands on Ichigo's recovery, 35); new scene h2 (6 m): J1 five ticks before, the same two lines; the six pairs' counts as DUEL_CORE §9 lists them.

### 8.5 Order and parallelism

- **S0 -> S1 -> S2** serial (S2 needs S1's cell knob; both edit `core-on-hit!` / rules.lisp). S0 may start at once, in parallel with the
  refactor's removals (a new file).
- After S2: **S3 ∥ S6** (S3: `apply-hit` gains + `kosei-gain`; S6: the switch branch + tuning) in two worktrees; then **S4**, then **S5**
  (both rewrite `core-nohit!` / `core-verdicts`: serial, S4 first because S5's cancel stamps S4's exchange).
- **S8 ∥ S4 / S5** from S2 on (Lisp HUD files only; it reads slots S2 defines and one event S4 adds: the event name is fixed here,
  `:sp-break att def take gain`). **S7 after S5** (the CPU must see the final rules). **S9 last.**
- Conflicts to expect on every merge: `tests/scripts/duel.py` (one section per batch, appended), `tests/style-cvc-ref.txt` (regenerated
  by the lead on the merged head, never merged by hand), DUEL_GAMEPLAY's debug table (the range is claimed once, before S1),
  `tuning.lisp` (knobs added in S0 only), `duel/MANIFEST` (S0 only), the manual (S9 collects the player-facing text; S1-S6 write the
  design docs only).
- Playtest Artifacts: after S2 (the loop is playable: costs, refunds, scaling, one-cell bursts), after S5 (the whole rule set), after S8
  (cues). Each publish: `index.js` with `index.wasm`, hashes compared.

### 8.6 Open rule questions (not settled by §2-§6; the default is what the plan builds unless the main session says otherwise)

| # | Question | Default |
|---|---|---|
| Q1 | Does paying SP restart the 60 f regen delay, and does a refund? | Paying does (it goes through `spend-fs`); a refund does not touch `fs-idle` |
| Q2 | Do ATK gains take the SUBLIMATION `*sub-fs*` bonus and the burst's "nothing"? | Yes to both: they go through `pay-gauges` like every other flash-step gain |
| Q3 | "+10 per J hit": per hit window or per link? An SA with several windows? | Once per move start (a link, an SA), on its first damaging hit; the cancel's +30 also once per move, and it replaces, not adds to, the hit gain of that move |
| Q4 | A Kikon / Soul Break gives a flash-step bar back today (`kikon-refund`, `*kikon-fs-refund*`, combat.lisp:970). Kept? | Kept (the user's 「接毀魂不用花」 speaks of the cost only); its Reiatsu half goes with R6. Flag at the playtest: +100 per Kikon is ten J hits |
| Q5 | An :absorb verdict (armour): refund, gain? | Neither: it is not a cancel |
| Q6 | A multi-hit segment that dealt damage and then cancels: full refund? | Yes, what it paid, once (§3's wording is unconditional) |
| Q7 | A segment started free in a burst that ends mid-segment; a segment paid before a burst starts | The price is fixed at the start: free stays free (scale 1.0), paid stays paid |
| Q8 | A hazard's damage scale: read when it hits or frozen when fired? KESSA's replays? | Frozen at the fire frame (`sp-scale` slot); a replay uses the summon segment's scale (the summon costs 10) on top of its own x0.1 |
| Q9 | Today any melee hit window cuts an opponent wave with no verdict (combat.lisp:652). Under the triangle a wave that wins is not cut. Which verdict when the blade's class beats the wave's? | The wave is removed with no refund and no exchange (it lost); only :cancel refunds. Classless windows (a retired / unclassed move) keep cutting |
| Q10 | An AS1 steal and the breakthrough on the same hit | The AS's own steal first, then the breakthrough on what is left above the cell; two log lines |
| Q11 | "Until both are back in neutral": is hitstun neutral? | The exchange ends at the first step where neither fighter is in a move nor in a reaction the exchange caused, or when the breakthrough is taken, or at a reset / cinematic |
| Q12 | `core-kikon-cancel!` (the victim attacks a non-red Kikon follow-up): a cancel for +30 and an exchange? | Yes (it already calls `core-clash!`): the victim's J / SA +30, an exchange opens; nothing to refund |
| Q13 | Hisagi's bind clash (`hs-bind-clash`) and Kenpachi's parry window (`:parry` skips the triangle) | Only verdicts of `core-nohit!` and Q12 count; a parry is not a cancel (no refund, no +30) |
| Q14 | The switch at 0 < fs < cost | Starts scaled, like any NS segment (only fs = 0 is refused, §3) |
| Q15 | Does the attacker's hit still earn flash-step from `hit-gains`? | It never did (only TAKEN x `*fs-taken*`); with KOSEI's :quick / :flash flash-step replaced by §5's table the only attacker income is §5. KOSEI's guard-gauge multiplier (x1-x3) no longer applies to flash-step |
| Q16 | The PRACTICE dummy's and the CPU's costs | They pay like a player; S9's GAUGES row is the practice answer |
| Q17 | An NS route's first segment reached by a route restart inside a combo (not from neutral) | "First" = the route's first segment (`mv-ns-next` has no predecessor), wherever it starts |

**Decided 2026-11-12** (the user: 「按你建議的做」, on the main session's recommendations; DEVLOG §730):

- **Order: the removals first** (REFACTOR §11.2): R1-R6 before S1; the first SP playtest waits for M1. S0 runs in parallel at step 1.
- **Q3 changed from the default: +10 / +15 per damaging hit window**, not once per move (the user's 「J 命中 +10」 read literally): every hit
  window of a J link or an SA that deals damage pays its gain; a multi-hit SA pays per hit. The cancel's +30 stays once per move per
  exchange (guarded by `sp-gain-t`), and a move that cancels gets no hit gain from that verdict (no damage was dealt).
- **Q4** kept (+100 back per Kikon; watched at the playtest). **Q9** as the default (a blade that beats a wave removes it, no refund, no
  exchange; only a cancel refunds). **Q12** as the default (the Kikon follow-up's cancel is a cancel: +30, an exchange opens).
- The other thirteen questions: the defaults above.
- **A1 playtest (the user, 2026-11-13).** (1) 「設定上 NS 如果量表已歸 0 不足要被拒絕出招，但現在打中對手還是能強行接續」: the cause was KOSEI's flash-step
  (by move kind, +2.4-2.9 a hit) on an NS segment's contact, lifting the gauge above 0 so the next segment passed `sp-start-p`; S2's check
  only tried whiffs. Fixed at once (S3's §5 rule pulled forward for SP segments): an NS / AS segment's contact pays no KOSEI flash-step
  (combat.lisp `apply-hit`); `tests/sp-costs-check.py` gained "at 0, NSa hits: NSb refused" for every route (86 checks); G2 regenerated.
  (2) 「我覺得應該要出完招式再確認要不要扣量表，目前扣完又退回視覺上挺異常的，但這部份需要更多討論」: asked with three options (a reserve
  shown on the gauge / pay at the move's end / pay at its verdict); the user chose **「預扣顯示」**: the rule stays (a segment reserves its
  price at its start, so its scale is known and the reserve cannot be spent on a Hoho or a burst or stolen), the HUD draws the reserved part
  as a dim reserve on the gauge while the segment runs, it fades at the segment's end, and on a cancel it turns back to lit ink with no drop
  and refill. Presentation only (G2 unchanged); built in **S8** (the reserve = `sp-paid` while the fighter is in that NS / AS segment and
  `sp-back` is not set: `sp-paid` stays on the fighter after a route, so the HUD must check the move and class).
  (3) Hisagi's Bankai tip / spread-route bonuses (DUEL_HISAGI §25.5 / §25.11, x1.3 / x1.3 on the old Reiatsu "SP recovery", removed with it
  by R6): asked whether §5's new ATK gains take them; the user: **「沿用 ×1.3」**: a tip hit's J / SA gain x1.3, a spread-route hit's x1.3,
  both x1.69. Built in **S3** (a `:sp-gain-mult` hook beside `hs-dmg-mult`'s tip read; the knobs return as `*hs-r-tip-sp-mult*` /
  `*hs-r-spread-sp-mult*` 1.3).
- **S8 done (2026-11-13; the HUD cues, DUEL_LISP_HUD §17).** The A1 playtest's 「預扣顯示」 replaced the row's "spend tick and refund flash": the
  model publishes the reserve (`sp-paid` while the fighter is in an NS / AS segment and `sp-back` is not set), the next NSa's price, the running
  scale and a refused-press serial (o+26..29); the plate's cells and the phone's dial draw the reserve as dim ink on the gauge (it does not
  drop when a segment pays, it turns lit when a cancel refunds, it fades at the segment's end); a price tick on the cells; "x0.5-x0.9" on a
  scaled callout; the SP button's SHORT / EMPTY words and a refused-press cue (the label's shake and flash, the cells' blood flash). The
  breakthrough event and the steal's fly-over wait for S4. Presentation only: G2 identical; 0 B / frame.
- **Q18 (the main session, 2026-11-13, from REFACTOR_2026-11 §11.5.7 item 5): one named writer per gauge direction.** Every flash-step
  loss but the burst's own drain goes through `spend-fs` (the regen waits again): the SP payment, Hoho, the AS1 steal's and the
  breakthrough's victim side (today the steal writes the slot directly; under S1's regen cap and steal floor the idle reset changes
  nothing for a victim left at or above the last cell). Every earned gain goes through `pay-gauges` (nothing during a burst, x the
  SUBLIMATION bonus): §5's ATK gains (Q2), damage taken, KOSEI, the AS1 steal's and the breakthrough's attacker side (today the steal
  bypasses both), and Q4's +100 Kikon bar (a flat gain, not a return of what was paid; today it bypasses both). A **refund** returns
  exactly what a segment paid: a third writer `refund-fs` (cap `*fs-max*`, no SUBLIMATION factor, `fs-idle` untouched as Q1 says;
  a segment started free in a burst paid nothing, so nothing returns). S1 moves the steal and the Kikon bar onto these paths (G2 moves
  with S1 anyway); S2 adds `refund-fs`; S3 splits `pay-gauges`' pure core (`fs-gain`); S4's breakthrough uses the two writers.
  Why: the principle's "mutation kept to named places"; a transfer that skipped the burst rule would refuel a burst, which §2's
  "no gain of any kind during a burst" (`burst-fs-gain`) rules out.
- Before cutting, R1 checks Kenpachi's arm meter (printed in the hash line, gate.lisp:20) and R6 checks Hisagi's reads of the Reiatsu
  gauge (hisagi.lisp:1354, 1378): only what nothing live consumes is removed.

### 8.7 Risks

1. **`core-nohit!` / `core-verdicts` are rewritten three times** (S2 refund, S4 exchange, S5 hazards). Serial, one Opus agent each, the
   previous batch's scenes re-run as regression.
2. **The scale must be damage-only.** `apply-hit` derives reactions and stun from the move, but any damage-keyed side effect (guard
   crush, the SUBLIMATION fill, `*fs-taken*` on the victim, Kenpachi's Reishi price) will follow the scaled number: S2 lists each reader
   and states which follow (default: gains follow the dealt damage, prices do not).
3. **CPU stalls**, not CPU strength: a refused later segment, a burst now legal at one cell (the CPU bursts three times as often), the
   strategy tables scored under free SP. G2 will move a lot in S1 and S2; that is expected and is not a balance verdict.
4. **Determinism**: every new float goes through `f32`; costs are integers fixed at `parse-move`; the native sim and the browser G2
   must both be regenerated and agree.
5. **§4's table vs the kits' data**: S0's test is the arbiter; a mismatch is reported to the main session (an override or a doc fix),
   never silently rounded.
