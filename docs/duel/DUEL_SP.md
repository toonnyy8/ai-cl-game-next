# DUEL_SP — SP spending on the flash-step gauge (design, 2026-11-12)

Status: **rules final (the user, 2026-11-12), not built.** Implementation plan: §8 (written 2026-11-12, batches S0-S9, open rule questions in §8.6).

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
