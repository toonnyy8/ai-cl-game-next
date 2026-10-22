# SOUL DUEL: a roguelite run built on ENDLESS (working name DANGAI 斷界行)

Status: **design, 2026-10-22; batch 1 (the skeleton) built the same day** ("Built: batch 1" at the end). The user's request and decisions are in §0; the research behind them is
`docs/research/roguelike/digest.md`. The existing ENDLESS mode (`DUEL_ENDLESS.md`) stays as it is; this is a new MODE
row that reuses its run machinery. Open items for the user are in §11.

## 0. Request and decisions (2026-10-22)

- Request: 「我接下來想將 endless 模式融合 roguelike 要素創造新模式，請研究並蒐集、彙整 roguelike 的設計要點後與我討論詳細規劃。」
- Decisions, each the option the user picked, in the order they were asked:

| # | Question | The user's pick | Meaning |
|---|---|---|---|
| R1 | The shape of a run | 「有終點＋續打」 | 10 steps (an elite every third, a boss at 10); a win at 10 clears the run; then an optional endless continuation |
| R2 | Rewards in version 1 | 「通用＋角色專屬改招」 | generic passives and per-character move changes, both in the first version |
| R3 | A route choice between stages | 「兩扇門預告」 | two doors after each step, each previewing its opponent, its condition and its reward type; sometimes a rest point |
| R4 | The boss | 「強化角色＋專屬規則」 | one of the roster, awakened at FIGHT, Reishi 150 %, HARD, plus one rule of its own |
| R5 | Across runs | 「解鎖＋難度階梯」 | unlocks add rewards to the pool; a per-character ladder (靈壓階) of cumulative difficulty; no permanent stats |
| R6 | Reishi / Konpaku between stages | 「沿用 ENDLESS」 | ENDLESS's carry unchanged: Reishi full, Konpaku +2 (max 9), CONTINUE / REVERT |
| R7 | Holding limits | 「獎勵我想設計成幾種類別分組，每種類別只能持有 1~2 個來限制總持有上限」 | six categories with 1 or 2 slots each, 9 in all (§4.1) |
| R8 | A category already full | 「可以替換」 | its rewards still appear, marked REPLACE; taking one drops a held one of that category back into the pool |

- Approach (A, recommended with the draft): the mode sits on ENDLESS's run (the carry, the bag, the ramp, STAGE CLEAR)
  instead of a second copy (B) or turning ENDLESS itself into the roguelite (C, against 「創造新模式」).

## 1. Principles (from the research, not up for each feature)

- **Fair failure**: every threat is shown before the player commits (the doors' preview, the INTRO card). A stage's
  conditions are constant for the whole fight: no random triggers, no unblockable attacks, nothing hides the fighters
  (the lessons of MK11's Towers of Time and MK1's Invasions, digest §5).
- **Choices, not grind**: the run's power comes from picks inside the run; across runs only options unlock (digest §4).
- **Readable at speed**: one line a reward, at most two conditions on a stage, no reward that needs frame data to read.
- **Determinism**: doors, offers and conditions come from their own generator keyed on (run seed, step), never
  `sim-rnd`, so how a fight goes never changes what is offered and a run replays from its seed and P1's inputs.
- **The versus game does not move**: with no run active every hook reads nil, so the seed gate's 816 lines, cvc and the
  115 looks stills stay byte-identical.

## 2. Flow

- **MODE**: a new row under ENDLESS. SELECT is ENDLESS's (P1, then START difficulty and, once unlocked, the 靈壓階).
- **A run** is 10 steps: `N N E N N E N N E B` (N normal, E elite, B boss). Each step is either a fight or a rest (a
  rest takes only an N step). Step 1 has no doors: ENDLESS's stage-1 opponent, one condition, a GENERIC reward.
- **After a fight won** (and after a rest): STAGE CLEAR (ENDLESS's screen and rows, CONTINUE / REVERT / QUIT) →
  **REWARD** (pick 1 of 3, §4) → **DOORS** (pick 1 of 2, §3) → the next step's INTRO, which names its conditions.
- **The boss won** = the run cleared: the record is written, then **CONTINUE THE RUN / END**. The continuation keeps the
  ramp at the boss's level, keeps doors and rewards, and counts steps; it has no further boss.
- **Over** on a loss, a draw, RETIRE or QUIT, as in ENDLESS. RESULTS adds the build (the held rewards) and the step reached.

## 3. Doors

- Two doors after every step, each previewing: **the opponent** (drawn from ENDLESS's bag; the two doors never show the
  same character), **its conditions** (§5), **its reward type**: GENERIC, MOVE (the character's own, §4.3), KONPAKU +3,
  or RARE.
- The step type is fixed by the run's layout (an elite step offers two elites; the boss step offers one door).
- **Rest**: from step 4, at most twice a run, one door may be a rest point: no fight, pick one of KONPAKU +3 or UPGRADE
  one held reward.
- The doors and offers use their own LCG keyed on (run seed, step), like the bag.

## 4. Rewards

### 4.1 Categories and slots (R7)

| Category | Slots | What | Examples (to be listed in full at build time) |
|---|---|---|---|
| **斬 ZAN** attack | 2 | damage, strings, guard break | damage +10 %; +20 % from the third hit of a string |
| **守 MAMORI** defence | 2 | guard gauge, perfect guard, armour | a perfect guard refills Reiatsu; one armour hit for 2 s after taking a Kikon |
| **瞬 SHUN** movement | 1 | flash step, Reiatsu | flash step cost −30 %; +15 % on the first move after a flash step |
| **靈 REI** awakening and Reishi | 1 | awakening gauge, Reishi, SP | awakening gauge +25 %; Reishi max +15 % |
| **契 CHIGIRI** pact | 1 | strong, paid for in Konpaku or caps | Konpaku cap 9 → 7 for damage +20 % |
| **解 KAI** own moves | 2 | the character's move changes (§4.3) | Hisagi: SAHARAI one more armour hit |

- 9 slots in all. **Full category (R8)**: its rewards are still offered, the card reads REPLACE; taking one asks which held
  reward of that category to drop; the dropped one goes back into the pool.
- **Traits (追加特性)**: a pair or a composite is never a card and takes no slot: it switches on by itself while all its
  prerequisites are held and off when one is replaced away (the user, 2026-10-22: 「我想將合體改成追加特性，這樣就不會有吃掉
  的問題（但也沒辦法空出格子）」). No tiers. A card that would complete a trait names it (`+ 死線`).
- **Tiers**: COMMON → RARE → LEGEND, the tier scales the reward's numbers only. RARE offers come from elites and RARE doors;
  UPGRADE (rest points, elite rewards) raises one held reward one tier.
- **Offers**: 3 cards, never a reward the character cannot use, never the same reward twice in one offer; the MOVE door's
  offer is all 解 cards.

### 4.2 Generic rewards (26, and 8 traits)

Implemented as one **run modifier table** on P1 (a plist on the fighter, nil outside a run), read at a few rule points
(damage dealt, perfect guard, flash step, Kikon taken, gauge gains). With no table every point reads its old value.

- **No awakening-gauge rewards** (the user, 2026-10-22, on the first candidate list: 「覺醒槽提昇量沒什麼用處，因為通常第一場就能
  滿槽開覺醒了」): the gauge fills in the first stage anyway and ENDLESS's carry keeps it, so 靈 rewards act on the
  awakened state, the awakening's moment or Reiatsu / Reishi / SP, never on how fast the gauge fills.
- **魄鎧 HAKUGAI, the Kikon always guarded** (the user, 2026-10-22: 「增加一個必定自動防禦 Kikon（紅血時也一樣），設計上可能可以
  讓 AI 檢測到這個效果時就不出 Kikon 只打到 Soul Break」): 守, RARE doors and elites only, no tiers (nothing to scale). The
  Kikon (the rush's follow-up strike, KIKON-OUTCOME :kikon) on its holder is guarded automatically in any state (red, hit
  stun, GUARD CRUSH, mid-move): no Konpaku lost, no guard drain, no chip. The rush's first strike is unchanged. Konpaku
  then goes only through Soul Breaks (the Kikon count + 1, at most 5) and time-up. **The CPU** reads it: one predicate
  (the Soul Break finish's AI-SB-FINISH-P widened to "the Kikon is futile") closes every Kikon site in ai.lisp (the
  neutral rush on a red opponent, the O ender, the rush on hitstun), so the CPU fights on to the Soul Break. It may be held with 殘心 (12).
- **Traits cross categories**: a trait's prerequisites never overfill a category (two in a 1-slot category could not be held together).

**The list** (the user's picks of 2026-10-22 on the first candidate list: 「砍 15 縮地、16 返し」, the changes to 6 and 25
quoted below, 17 and 20 reworked by the no-gauge rule, 27 and 28 added; 19 and 21 both stay: 「21 必殺跟 19 靈體效果不是
不一樣嗎？」). Numbers are COMMON; RARE / LEGEND scale them about x1.5 / x2. "rule" = a new rule point, "gauge" = a gauge
number only.

| # | Cat | Name | Effect (COMMON) | Kind |
|---|---|---|---|---|
| 1 | 斬 | 鋭刃 | all damage +10 % | rule |
| 2 | 斬 | 連撃 | link-3 enders (J3 / K3) +25 % | rule |
| 3 | 斬 | 破鎧 | hits on guard drain the guard gauge +40 % | rule |
| 4 | 斬 | 背水 | damage +25 % while red | rule |
| 5 | 斬 | 追擊 | the first hit after a Hoho or a Burst Reverse +30 % | rule |
| 6 | 斬 | 斷魂 (RARE+) | a Kikon takes 1 more Konpaku, **outside the per-event cap of 4** (「Kikon 多拿 1 魂魄，不受單次上限 4 的限制」) | rule |
| 7 | 守 | 堅守 | guard gauge max +30 %, regen +30 % | gauge |
| 8 | 守 | 見切 | a perfect Hoho refills 25 % flash step and half a Reiatsu bar | rule |
| 9 | 守 | 不屈 | one armour hit for 3 s after losing Konpaku to a Kikon or a Soul Break | rule |
| 10 | 守 | 鐵甲 | chip and Breaker damage taken −40 % | rule |
| 11 | 守 | 回生 | after 3 s unhit, 1 % Reishi a second (not while red) | rule |
| 12 | 守 | 殘心 (RARE+) | once a stage, when Konpaku reaches 0, 1 Konpaku comes back (LEGEND 2) and the fight goes on (「每關一次，魂魄歸零的時候會恢復一魂魄」); a lethal trade (both at 0) is then P1's win | rule |
| 28 | 守 | 魄鎧 (RARE only, no tiers) | the Kikon always guarded (above) | rule |
| 13 | 瞬 | 疾風 | flash-step gauge regen +30 % | gauge |
| 14 | 瞬 | 瞬歩 | Hoho cost −30 % | gauge |
| 17 | 靈 | 威壓 | damage taken −15 % while awakened | rule |
| 18 | 靈 | 靈力 | Reiatsu regen +30 % | gauge |
| 19 | 靈 | 靈體 | Reishi max +15 % | gauge |
| 20 | 靈 | 解放 | the awakening's heal 20 → 40 % of max Reishi | gauge |
| 21 | 靈 | 必殺 | SP1 / SP2 damage +20 % | rule |
| 27 | 靈 | 覇氣 | one armour hit for 3 s after the awakening's cinematic | rule |
| 22 | 契 | 血契 | Konpaku cap 9 → 7; damage +20 % | gauge + rule |
| 23 | 契 | 狂契 | guard gauge max −40 %; damage +15 %, Reiatsu regen +30 % | gauge + rule |
| 24 | 契 | 時契 | the stage timer 300 → 150 s; a clear gives Konpaku +3 (not +2) | run |
| 25 | 契 | 捨身 | Reishi max −20 %; every soul break (Kikon and Soul Break) takes 1 more Konpaku (「Reishi 上限 −20% → 毀魂時（Kikon 跟 Soul Break）多拿 1 魂魄」) | gauge + rule |
| 26 | 契 | 賭契 | no Konpaku at a clear; one extra reward pick at every clear | run |

Cut: 15 縮地 (dash speed, it moves the CPU's range reads) and 16 返し (Burst Reverse cost, too close to 14). 瞬 keeps two.
The first 鬥氣 (awakening gauge +25 %) is gone by the no-gauge rule.

**Konpaku taken, with 6 and 25**: the Kikon's (or Soul Break's) count, + 1 for 捨身, then the usual cap (4 a Kikon, 5 a
Soul Break); then + 1 for 斷魂 on a Kikon, past the cap. So holding both, an awakened Kikon: 3 + 1 = 4 (cap) + 1 = 5.

**Pair traits** (on while both are held):

| | Name | Needs | Effect |
|---|---|---|---|
| A | 死線 | 背水 + 不屈 | damage +35 % while red; an armour hit refilled every 5 s while red |
| B | 瞬閧 | 追擊 + 疾風 | the first hit after a Hoho +45 %, and on hit 15 % flash step back |
| C | 卍禍 | 必殺 + 連撃 | an SP within 1 s of a link-3 ender +40 % |
| D | 鬼道 | 見切 + 鐵甲 | damage taken −60 % for 2 s after a perfect Hoho |
| E | 修羅 | 血契 + 斷魂 | a Kikon takes 2 more Konpaku past the cap; Konpaku cap 6 |

**Composite traits** (the user, 2026-10-22: 「新增一個名為『真劍勝負』的複合型合體」, then, shown three drafts:
「你說的這三種合體都新增進來，分別是『最古最強』『真劍勝負』跟『劍八』」): on while all three are held, on top of the three
rewards' own effects and of any pair trait they also complete (背水 + 不屈 under 劍八 also gives 死線). The first draft
folded the three into one slot; traits take none and free none.

| | Name | Needs | Its own effect |
|---|---|---|---|
| F | 最古最強 | 魄鎧 + 殘心 + 斷魂 (守 守 斬) | P1's Soul Break takes 1 more Konpaku, past the cap |
| G | 真劍勝負 | 背水 + 魄鎧 + 血契 (斬 守 契) | both sides' Reishi max halved; the Kikon sealed for both (the O button and the O ender do nothing; Konpaku goes only by Soul Break); P1's damage +30 % |
| H | 劍八 | 不屈 + 背水 + 覇氣 (守 斬 靈) | while red: one armour hit always (refilled 2 s after it breaks), damage +40 %, no guard |

### 4.3 Move changes (解, 3–4 per character)

- Each one a `defmove-copy` override of one move (frame data, damage, armour hits, cooldown, hit count), applied to **P1's
  own copy of its kit** for the run, so a mirror opponent keeps the stock move.
- **Reach is not changed** by default: drawn reach must equal hit reach, so a reach change needs a new clip. Any candidate
  that changes reach goes to the user separately.
- **Applied by re-parsing the move under its own name** into P1's kit copy (every form holding it, and its load-time copies
  such as `-k` / `-1..6`), not as a renamed `defmove-copy`: many hooks look moves up by name. Shared knobs a card changes
  (a clone's cost, Lille's charge levels) get a per-fighter read in the character's file, so a mirror opponent keeps them.
- **Candidates**: 4 per character (+ a spare and the reach ideas that need clips) in
  `docs/research/roguelike/kai-candidates-A.md` (Yamamoto, Kenpachi, Rukia, Ichigo) and `-B.md` (Senjumaru, Lille,
  Hisagi), shown to the user 2026-10-22; the picks are pending. Added by the user the same day:
  - Hisagi 「尖端強化 100%，非尖端削弱 90%」: the ranged mode's tip damage x1.71 -> **x3.42**, a non-tip hit x1.0 ->
    **x0.1** (the user's pick of the readings: 「尖端 ×3.42、非尖端 ×0.1」; damage only, the tip's SP x1.3 unchanged).
  - Hisagi 「尖端與非尖端效果平均」: tip and non-tip hits both at the mean, damage **x1.355**, SP gain **x1.15**. The two
    Hisagi tip cards are twins (below).
  - Kenpachi 「卍解隨時可開，且不扣除魂魄」: the Bankai from any Nozarashi cup (awakened), not red-only, Konpaku kept (not ->
    1), Reishi still refilled, once a stage (the user's pick: 「覺醒後隨時、照樣回血」).
  - Kenpachi 「無手臂限制」 (asked as one more card, 2026-10-22: 「再多加一項『無手臂限制』」): in the Bankai no command spends a UDE
    pip, so no KATAUDE: the Bankai lasts the rest of the stage (the boss's arm rule as a player card).
- **Twin cards (孿生卡)** (the user, 2026-10-22: 「將其設成孿生卡，另一個效果還是會再度出現，但是只能二擇一。劍八的『隨時卍解』跟
  『無手臂限制』也做成孿生卡的機制。我希望你能為其他角色也設計類似的破格但有侷限性的孿生卡。」): two rule-breaking 解 cards
  of one character, each with its own limit; only one is held at a time; while one is held the other still appears, marked
  TWIN, and taking it swaps them (the held one goes back into the pool). Each character has one twin pair:
  Settled: Hisagi's and Kenpachi's. The other five are **kept as they stand, to be redesigned later** (the user,
  2026-10-22: 「除了檜佐木、劍八之外的孿生卡效果我都先保留，以後再重新設計」).

| Character | Twin A | Twin B |
|---|---|---|
| Hisagi | 尖端強化: tip x3.42, non-tip x0.1 | 尖端平均: every hit x1.355, SP x1.15 |
| Kenpachi | 隨時卍解: the Bankai from any cup, Konpaku kept, Reishi refilled, once a stage | 無手臂限制: no UDE pip spent, no KATAUDE |
| Yamamoto (lead's draft) | 旭日刃: East's pierce chip k 0.1–0.45 -> 1.0 (a guard takes the full hit); limit: guarding never turns him to West | 殘日獄衣: West's ward never drops (West the rest of the stage); limit: only West's commands, walk −30 % |
| Rukia (from 永久凍土, R4; the user: 「露琪亞請以永久凍土為基礎設計孿生卡」) | 永久凍土: −273 °C's L REIDO TOKETSU costs no cold (L never drops her out of zero); limit: no ward at −273 °C (hits land as usual; still rooted) | 瞬凍: at −50 °C L is REIDO TOKETSU (100 cold, as at zero; the zero kit's move on P1's −50 copy); limit: she never enters −273 °C |
| Ichigo (from 虛影 I2 and 分身亂舞 I4; the user: 「一護將虛影跟分身亂舞重新設計成孿生卡」) | 虛影: SP2 ZANZO costs 1 bar and its echo state lasts until he is hit (not 6 s); limit: no clones while the echo is on | 分身亂舞: a clone costs no guard gauge (15 -> 0); limit: no SP2 ZANZO (sealed) |
| Senjumaru (lead's draft) | 天衣無縫: a hit while weaving no longer voids the hank; limit: a pass takes 30 f (not 20) | 一越千針: every pass weaves 2; limit: any hit taken voids the live hank (not only while weaving) |
| Lille (lead's draft) | 神梟: the owl burst lasts the rest of the stage; limit: no wing regen in it (wings only from hits) | 萬翼: wing armour spends no wing; limit: no owl (his burst is a plain one) |


## 5. Conditions, elites, the boss

- **Normal step**: one condition. Candidates: opponent Reishi 130 %; both sides' Reiatsu regen ×2; the opponent's SP has
  one armour hit; the CPU favours its ranged moves; the stage timer 180 s.
- **Elite**: the ramp one level up from the step's own, two conditions, the reward RARE.
- **Boss** (R4): drawn from the bag; awakened at FIGHT, Reishi 150 %, HARD, plus its own rule, a new kit key `:boss`
  (data in the character's file). The rules (the user's list of 2026-10-22 over the lead's drafts; Yamamoto and Rukia
  took no note, so the lead's drafts stand for them):

| Boss | Rule | The user's words |
|---|---|---|
| Yamamoto | 殘火灼身: Reishi **200 %** (not 150), burning 0.5 % of max a second | (the lead's draft) |
| Kenpachi | the Bankai at FIGHT; the arm is never spent (no UDE pip spent, no KATAUDE): the Bankai the whole fight | 「BOSS 劍八卍解解除手臂（不扣臂、無時限）」 |
| Rukia | 永凍: never warms back to −18 °C (the floor is −50 °C); −273 °C entered as usual | (the lead's draft) |
| Ichigo | KESSA; a clone never spends the BUNSHIN meter; SP2's clone afterimages always on | 「BOSS 一護改成分身不扣除量表，且常駐 SP2 的分身殘影」 |
| Senjumaru | TSUJI always fully woven (the top hank form at FIGHT, never unwoven) | 「BOSS 千手丸永遠是織滿的狀態」 |
| Lille | JILLIEL KIN at FIGHT, the wings refilling over time as in the burst (the owl's wing every 2 s); his first Konpaku lost puts him in the owl (SHIN KIN) for the rest of the fight | 「BOSS 利傑改成開場時就在 JILLIEL KIN，且會有跟爆氣一樣隨時間自動補充『翼』的特性，第一次失去魂魄就進入常駐梟型態」 |
| Hisagi | 1 % Reishi a second while not attacked (a guarded hit counts as attacked; the lead's reading: 3 s clear before it starts, as 回生); the bind needs 1 bar (100) of his Reiatsu, not 2; when he releases the bind the pool left goes **to him first**, the rest to the opponent | 「BOSS 檜佐木改成只要沒受到攻擊（防禦算受到攻擊）每秒回 1% Reishi，只要有一格 SP 就能發動捆綁，且主動解除捆綁時 SP 優先歸還自身」 |

- The CPU never holds rewards; conditions are the only thing that changes it, and they act through existing knobs
  (gauges, `brain-difficulty`, the AI plists' weights).

## 6. Across runs (R5)

- **Unlocks**: only part of the reward pool is open at first; goals open more (a run cleared with a character, step N
  reached, a boss beaten). Stored in the page's storage, every access in try/catch, like ENDLESS's record.
- **靈壓階 (pressure rank) 0–5 per character**, cumulative, the next one opening when a run is cleared at the current one:
  1. the opponents' Reishi +10 %
  2. elites take a third condition
  3. Konpaku +1 a clear instead of +2
  4. the boss's Reishi 180 %
  5. rewards are 1 of 2
- **Record per character**: the highest rank cleared and the best continuation step; new page slots, ENDLESS's untouched.

## 7. Screens

- REWARD and DOORS: big cards (landscape side by side, portrait in the thumb zone), 1.0 s input lock as STAGE CLEAR,
  tap to pick, one line per card plus the category glyph and tier colour.
- The pause adds BUILD (the held rewards by category). RESULTS lists the build.

## 8. Code layout

- `duel/lisp/rogue-rules.lisp`: pure (the layout, doors, offers, slots and replacement, traits, tiers, unlocks, ranks),
  host-tested.
- `duel/lisp/rogue.lisp`: the mode (the run state on top of ENDLESS's, the screens, the record, debug entries).
- Shared files get hook lines only (flow, hud, the rule points of §4.2, kit for `:boss` and the per-fighter kit copy).
- Each character's 解 rewards and `:boss` rule live in its own files.
- Debug range **84000–84999** (claimed in DUEL_GAMEPLAY "Debug commands" when the first batch lands).

## 9. Tests and gates

- Host tests: the layout; doors never repeat a character; offers obey slots and never offer the unusable; REPLACE puts
  the dropped reward back (and its traits off); a trait on exactly while its prerequisites are held; tiers; ranks monotone; the generator replays and never
  reads `sim-rnd`.
- Byte-identity with no run: simgate's 816 lines, cvc, looks 115 stills (every batch that touches a shared file).
- **Run autopilot** (like ENDLESS's 80990): P1 a HARD CPU, offers taken by a random and a greedy policy; per character at
  rank 0: the clear rate, the step reached, and each reward's pick-to-win rate to find dominant ones.
- Each character's 解 batch: its pairings' sim gate with the reward forced on, as a reach / damage sanity check (not a
  balance gate).

## 10. Batches

1. The skeleton: the mode row, the layout, doors, elites and the boss without rules, REWARD / DOORS screens, the record.
2. Generic rewards: the modifier table, its rule points, categories, slots, REPLACE, traits, tiers.
3. Conditions and the seven `:boss` rules.
4. 解 rewards: one batch per character (parallel worktrees), after the user picks the candidates.
5. Unlocks, 靈壓階, the record, the manual, the autopilot gate.

Not in version 1 (YAGNI): rerolls and banish, a daily seed (easy later: the run is deterministic), a full route map,
a new boss character, rewards for the CPU, online boards.

## 11. Open for the user

- The twin cards of Yamamoto, Rukia, Ichigo, Senjumaru and Lille (kept as placeholders, §4.3).

- The mode's name (working name DANGAI 斷界行).
- Each character's 3–4 解 candidates (a list before batch 4).
- The generic reward list and the traits (picked 2026-10-22, §4.2), with the slot counts of §4.1.

## Built: batch 1 (2026-10-22)

The user: 「先走 2」 (start building before the 解 picks). Plan: `DUEL_ROGUE_B1_PLAN.md`.

- **What exists**: the MODE row DANGAI (row 2; PRACTICE … MANUAL moved down one); the run is an ENDLESS run (`*mode*`
  `:endless`) with `*rogue*` set (flow.lisp), so the carry, STAGE CLEAR (CONTINUE / REVERT / QUIT), RETIRE and the
  RESULTS are ENDLESS's; `rogue-rules.lisp` (pure: the layout, the ramp per step, rests, doors, a rest's carry) and
  `rogue.lisp` (the DOORS screen, flow state `:doors`). STAGE CLEAR's NEXT line names the step's kind (ELITE / BOSS)
  instead of the bag's opponent; step 10 cleared reads RUN CLEAR there and on the RESULTS; the continuation is CONTINUE
  after step 10 (no further boss; elites every third step). The record: page 50 + 2i / 51 + 2i (`soulduel.rogue.<k-50>`),
  ENDLESS's untouched. Debug 84000–84999 (DUEL_GAMEPLAY).
- **Numbers**: an elite is ENDLESS's row two stages on with one more difficulty step (step 3 at a NORMAL floor: HARD,
  awakening 50); the boss `(10 2 100 t 150)`: HARD from any floor, awakened, Reishi 150 %; rests from step 4, normal
  steps only, a 1-in-3 draw, at most 2, Konpaku + 3.
- **Log**: `duel rogue door i step n fight|rest [opponent]`, then ENDLESS's lines.
- **Deviations from the design**: the doors are STAGE CLEAR-style rows (a note line over them), not cards yet; both doors
  draw from the roster minus the last opponent (not ENDLESS's bag); the doors don't show a reward type until batch 2;
  REST gives only Konpaku + 3 (UPGRADE needs rewards); the HUD tag stays "STAGE n".
- **Gates**: host 9888 -> 9899 ALL PASS; pkgcheck 0; build 0 warnings; smoke; simgate 28 x 10 seeds 816 lines identical
  to the parent's; cvc 3/3; looks 113 of 115 byte-identical, the two MODE stills (menus/mode, mobile/mode) changed by the
  new row (the BASE rendered with the parent's own script, which reaches SETTINGS one row higher); `duel-rogue.json`
  (two doors taken, the elite at HARD with awakening 50, RETIRE -> "DANGAI" RESULTS); flow / practice scripts reach
  their rows; `duel-endless.json`'s log equals the parent's where both ran (both stop after stage 2: its stage-3 Bankai
  step no longer clears, a drift that predates this batch).

