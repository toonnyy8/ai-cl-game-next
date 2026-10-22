# SOUL DUEL: a roguelite run built on ENDLESS (working name DANGAI 斷界行)

Status: **design, 2026-10-22; not built.** The user's request and decisions are in §0; the research behind them is
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
- **Pairs (duo rewards)**: offered only while both prerequisites are held; taking one replaces one prerequisite and takes
  its slot (the total never exceeds 9). Version 1 has 3–5 pairs.
- **Tiers**: COMMON → RARE → LEGEND, the tier scales the reward's numbers only. RARE offers come from elites and RARE doors;
  UPGRADE (rest points, elite rewards) raises one held reward one tier.
- **Offers**: 3 cards, never a reward the character cannot use, never the same reward twice in one offer; the MOVE door's
  offer is all 解 cards.

### 4.2 Generic rewards (about 20)

Implemented as one **run modifier table** on P1 (a plist on the fighter, nil outside a run), read at a few rule points
(damage dealt, perfect guard, flash step, Kikon taken, gauge gains). With no table every point reads its old value.

### 4.3 Move changes (解, 3–4 per character)

- Each one a `defmove-copy` override of one move (frame data, damage, armour hits, cooldown, hit count), applied to **P1's
  own copy of its kit** for the run, so a mirror opponent keeps the stock move.
- **Reach is not changed** by default: drawn reach must equal hit reach, so a reach change needs a new clip. Any candidate
  that changes reach goes to the user separately.
- The candidates per character are a list for the user to pick from before the batch that builds them (§11).

## 5. Conditions, elites, the boss

- **Normal step**: one condition. Candidates: opponent Reishi 130 %; both sides' Reiatsu regen ×2; the opponent's SP has
  one armour hit; the CPU favours its ranged moves; the stage timer 180 s.
- **Elite**: the ramp one level up from the step's own, two conditions, the reward RARE.
- **Boss** (R4): drawn from the bag; awakened at FIGHT, Reishi 150 %, HARD, plus its own rule, a new kit key `:boss`
  (data in the character's file; a list for the user, §11).
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

- `duel/lisp/rogue-rules.lisp`: pure (the layout, doors, offers, slots and replacement, pairs, tiers, unlocks, ranks),
  host-tested.
- `duel/lisp/rogue.lisp`: the mode (the run state on top of ENDLESS's, the screens, the record, debug entries).
- Shared files get hook lines only (flow, hud, the rule points of §4.2, kit for `:boss` and the per-fighter kit copy).
- Each character's 解 rewards and `:boss` rule live in its own files.
- Debug range **84000–84999** (claimed in DUEL_GAMEPLAY "Debug commands" when the first batch lands).

## 9. Tests and gates

- Host tests: the layout; doors never repeat a character; offers obey slots and never offer the unusable; REPLACE puts
  the dropped reward back; pairs only with both prerequisites; tiers; ranks monotone; the generator replays and never
  reads `sim-rnd`.
- Byte-identity with no run: simgate's 816 lines, cvc, looks 115 stills (every batch that touches a shared file).
- **Run autopilot** (like ENDLESS's 80990): P1 a HARD CPU, offers taken by a random and a greedy policy; per character at
  rank 0: the clear rate, the step reached, and each reward's pick-to-win rate to find dominant ones.
- Each character's 解 batch: its pairings' sim gate with the reward forced on, as a reach / damage sanity check (not a
  balance gate).

## 10. Batches

1. The skeleton: the mode row, the layout, doors, elites and the boss without rules, REWARD / DOORS screens, the record.
2. Generic rewards: the modifier table, its rule points, categories, slots, REPLACE, pairs, tiers.
3. Conditions and the seven `:boss` rules.
4. 解 rewards: one batch per character (parallel worktrees), after the user picks the candidates.
5. Unlocks, 靈壓階, the record, the manual, the autopilot gate.

Not in version 1 (YAGNI): rerolls and banish, a daily seed (easy later: the run is deterministic), a full route map,
a new boss character, rewards for the CPU, online boards.

## 11. Open for the user

- The mode's name (working name DANGAI 斷界行).
- The seven bosses' rules (a candidate list before batch 3).
- Each character's 3–4 解 candidates (a list before batch 4).
- The generic reward list and the pairs (a list before batch 2), with the slot counts of §4.1.
